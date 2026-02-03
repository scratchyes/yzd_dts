#!/bin/bash
# RK3399-YZD 一键安装脚本
# 将boot文件夹内容部署到目标设备
# 
# 使用方法:
#   sudo ./install.sh              # 自动检测boot分区
#   sudo ./install.sh /dev/mmcblk0p1  # 指定boot分区
#   sudo ./install.sh /boot        # 指定挂载点

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_SOURCE="${SCRIPT_DIR}/boot"

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示横幅
show_banner() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║        RK3399-YZD 一键安装脚本                        ║"
    echo "║        RK3399-YZD One-Click Install Script           ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 sudo 运行此脚本 / Please run with sudo"
        echo "Usage: sudo $0 [boot_partition_or_mount_point]"
        exit 1
    fi
}

# 检查源文件是否存在
check_source() {
    if [ ! -d "$BOOT_SOURCE" ]; then
        print_error "boot 源目录不存在: $BOOT_SOURCE"
        exit 1
    fi
    
    if [ ! -f "${BOOT_SOURCE}/Image-4.4.194" ]; then
        print_error "内核镜像不存在: ${BOOT_SOURCE}/Image-4.4.194"
        exit 1
    fi
    
    if [ ! -f "${BOOT_SOURCE}/rk3399-yzd-linux.dtb" ]; then
        print_error "设备树文件不存在: ${BOOT_SOURCE}/rk3399-yzd-linux.dtb"
        exit 1
    fi
    
    print_success "源文件检查通过"
}

# 自动检测boot分区
detect_boot_partition() {
    print_info "正在检测 boot 分区..."
    
    # 检查 /boot 是否已挂载
    if mountpoint -q /boot 2>/dev/null; then
        echo "/boot"
        return 0
    fi
    
    # 检查常见的boot分区位置
    for dev in /dev/mmcblk*p1 /dev/sd*1; do
        if [ -b "$dev" ]; then
            # 检查是否包含extlinux
            MOUNT_POINT=$(mktemp -d)
            if mount -o ro "$dev" "$MOUNT_POINT" 2>/dev/null; then
                if [ -d "${MOUNT_POINT}/extlinux" ] || [ -f "${MOUNT_POINT}/Image"* ]; then
                    umount "$MOUNT_POINT"
                    rmdir "$MOUNT_POINT"
                    echo "$dev"
                    return 0
                fi
                umount "$MOUNT_POINT"
            fi
            rmdir "$MOUNT_POINT" 2>/dev/null || true
        fi
    done
    
    return 1
}

# 挂载分区
mount_partition() {
    local target="$1"
    
    # 如果是目录且已挂载，直接返回
    if [ -d "$target" ] && mountpoint -q "$target" 2>/dev/null; then
        echo "$target"
        return 0
    fi
    
    # 如果是目录但未挂载
    if [ -d "$target" ]; then
        echo "$target"
        return 0
    fi
    
    # 如果是设备，需要挂载
    if [ -b "$target" ]; then
        MOUNT_POINT=$(mktemp -d)
        print_info "挂载 $target 到 $MOUNT_POINT"
        mount "$target" "$MOUNT_POINT"
        echo "$MOUNT_POINT"
        return 0
    fi
    
    print_error "无法识别目标: $target"
    return 1
}

# 备份原有文件
backup_files() {
    local target_dir="$1"
    local backup_dir="${target_dir}/backup_$(date +%Y%m%d_%H%M%S)"
    
    print_info "备份原有文件到 ${backup_dir}..."
    mkdir -p "$backup_dir"
    
    # 备份关键文件
    for file in Image* initrd* *.dtb; do
        if [ -f "${target_dir}/${file}" ]; then
            cp -v "${target_dir}/${file}" "$backup_dir/" 2>/dev/null || true
        fi
    done
    
    # 备份extlinux配置
    if [ -d "${target_dir}/extlinux" ]; then
        cp -r "${target_dir}/extlinux" "$backup_dir/"
    fi
    
    print_success "备份完成: ${backup_dir}"
}

# 复制boot文件
copy_boot_files() {
    local target_dir="$1"
    
    print_info "复制 boot 文件..."
    
    # 复制内核和initrd
    cp -v "${BOOT_SOURCE}/Image-4.4.194" "${target_dir}/"
    cp -v "${BOOT_SOURCE}/initrd-4.4.194" "${target_dir}/"
    
    # 复制设备树
    cp -v "${BOOT_SOURCE}/rk3399-yzd-linux.dtb" "${target_dir}/"
    
    # 复制其他DTB作为备份
    cp -v "${BOOT_SOURCE}/rk-kernel.dtb" "${target_dir}/" 2>/dev/null || true
    cp -v "${BOOT_SOURCE}/rk3399-sw799.dtb" "${target_dir}/" 2>/dev/null || true
    
    # 复制配置文件
    cp -v "${BOOT_SOURCE}/System.map-4.4.194" "${target_dir}/" 2>/dev/null || true
    cp -v "${BOOT_SOURCE}/config-4.4.194" "${target_dir}/" 2>/dev/null || true
    
    # 复制logo
    cp -v "${BOOT_SOURCE}/logo.bmp" "${target_dir}/" 2>/dev/null || true
    cp -v "${BOOT_SOURCE}/logo_kernel.bmp" "${target_dir}/" 2>/dev/null || true
    
    # 复制extlinux配置
    mkdir -p "${target_dir}/extlinux"
    cp -v "${BOOT_SOURCE}/extlinux/extlinux.conf" "${target_dir}/extlinux/"
    
    print_success "Boot 文件复制完成"
}

# 下载并安装WiFi固件
install_wifi_firmware() {
    local firmware_dir="/lib/firmware/brcm"
    
    print_info "安装 AP6356S WiFi 固件..."
    
    mkdir -p "$firmware_dir"
    
    # 检查是否有网络 (使用HTTP请求代替ping，因为ICMP可能被防火墙阻止)
    if ! curl -s --connect-timeout 5 https://github.com >/dev/null 2>&1 && \
       ! wget -q --spider --timeout=5 https://github.com 2>/dev/null; then
        print_warning "无法连接到网络 / Cannot connect to network"
        print_warning "请手动下载固件文件到 $firmware_dir"
        print_warning "Please manually download firmware to $firmware_dir"
        return 0
    fi
    
    # 下载固件文件
    local base_url="https://github.com/armbian/firmware/raw/master/brcm"
    
    for file in brcmfmac4356-sdio.bin brcmfmac4356-sdio.txt brcmfmac4356-sdio.clm_blob; do
        if [ ! -f "${firmware_dir}/${file}" ]; then
            print_info "下载 / Downloading ${file}..."
            if wget -q --show-progress -O "${firmware_dir}/${file}" "${base_url}/${file}" 2>/dev/null; then
                print_success "${file} 下载成功 / downloaded successfully"
            elif curl -sL -o "${firmware_dir}/${file}" "${base_url}/${file}" 2>/dev/null; then
                print_success "${file} 下载成功 / downloaded successfully"
            else
                print_warning "无法下载 / Failed to download ${file}"
                print_warning "请手动下载 / Please download manually: ${base_url}/${file}"
            fi
        else
            print_info "${file} 已存在 / already exists, 跳过 / skipping"
        fi
    done
    
    # 设置权限
    chmod 644 "${firmware_dir}"/brcmfmac4356-sdio.* 2>/dev/null || true
    
    print_success "WiFi 固件安装完成"
}

# 验证安装
verify_install() {
    local target_dir="$1"
    local errors=0
    
    print_info "验证安装..."
    
    # 检查关键文件
    for file in Image-4.4.194 initrd-4.4.194 rk3399-yzd-linux.dtb extlinux/extlinux.conf; do
        if [ -f "${target_dir}/${file}" ]; then
            print_success "✓ ${file}"
        else
            print_error "✗ ${file} 缺失"
            errors=$((errors + 1))
        fi
    done
    
    # 检查extlinux配置
    if grep -q "rk3399-yzd-linux.dtb" "${target_dir}/extlinux/extlinux.conf" 2>/dev/null; then
        print_success "✓ extlinux.conf 配置正确"
    else
        print_error "✗ extlinux.conf 配置可能不正确"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        print_success "安装验证通过!"
        return 0
    else
        print_error "安装验证失败，发现 $errors 个错误"
        return 1
    fi
}

# 显示安装后信息
show_post_install() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               安装完成 / Installation Complete       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}硬件支持状态 / Hardware Support Status:${NC}"
    echo "  ✅ HDMI          - 正常 / Working"
    echo "  ✅ RJ45 以太网   - 正常 / Working"
    echo "  ✅ WiFi          - 正常 / Working (需要固件)"
    echo "  ✅ 蓝牙          - 正常 / Working"
    echo "  ✅ USB 3.0/2.0   - 正常 / Working"
    echo "  ✅ 音频          - 正常 / Working"
    echo "  ✅ eMMC          - 正常 / Working"
    echo ""
    echo -e "${YELLOW}下一步 / Next Steps:${NC}"
    echo "  1. 重启设备 / Reboot the device"
    echo "  2. 如果WiFi不工作，请检查固件文件"
    echo "     WiFi firmware location: /lib/firmware/brcm/"
    echo ""
}

# 主函数
main() {
    show_banner
    check_root
    check_source
    
    local target="$1"
    local mount_point=""
    local need_umount=false
    
    # 如果没有指定目标，自动检测
    if [ -z "$target" ]; then
        print_info "未指定目标，尝试自动检测..."
        target=$(detect_boot_partition) || {
            print_error "无法自动检测 boot 分区"
            echo ""
            echo "请手动指定目标:"
            echo "  sudo $0 /dev/mmcblk0p1  # 指定分区"
            echo "  sudo $0 /boot           # 指定挂载点"
            exit 1
        }
        print_info "检测到 boot 位置: $target"
    fi
    
    # 挂载目标
    mount_point=$(mount_partition "$target")
    
    # 如果是临时挂载点，需要卸载
    if [[ "$mount_point" == /tmp/* ]]; then
        need_umount=true
    fi
    
    echo ""
    echo -e "${YELLOW}即将安装到 / Installing to: ${mount_point}${NC}"
    echo -e "${YELLOW}源目录 / Source: ${BOOT_SOURCE}${NC}"
    echo ""
    read -p "确认继续? Continue? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "安装已取消 / Installation cancelled"
        if $need_umount; then
            umount "$mount_point"
            rmdir "$mount_point"
        fi
        exit 0
    fi
    
    # 执行安装
    backup_files "$mount_point"
    copy_boot_files "$mount_point"
    
    # 询问是否安装WiFi固件
    echo ""
    read -p "是否安装 WiFi 固件? Install WiFi firmware? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        install_wifi_firmware
    fi
    
    # 验证安装
    verify_install "$mount_point"
    
    # 同步文件系统
    sync
    
    # 卸载临时挂载点
    if $need_umount; then
        print_info "卸载临时挂载点..."
        umount "$mount_point"
        rmdir "$mount_point"
    fi
    
    show_post_install
}

# 运行主函数
main "$@"
