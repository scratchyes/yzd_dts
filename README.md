# RK3399-YZD Device Tree for Linux/Armbian

[English](#english) | [中文](#中文)

## 中文

### 概述

本仓库包含RK3399-YZD开发板的Linux设备树源文件，已从Android BSP转换为Linux兼容格式，可用于Armbian等Linux发行版。

### 硬件支持

✅ **完全支持的功能:**
- HDMI视频输出
- 千兆以太网 (Realtek RTL8211E)
- WiFi (Broadcom AP6356S)
- 蓝牙 (Broadcom AP6356S)
- USB 3.0 Type-C (OTG + Host)
- 音频 (RT5651 Codec)
- eMMC存储
- GPIO LED
- 按键输入

⚠️ **部分支持/可选:**
- SD卡 (默认禁用，可启用)
- PCIe (默认禁用，可启用)

### 文件说明

- `rk3399-yzd.dts` - Linux设备树源文件
- `rk3399-yzd-linux.dtb` - 编译后的设备树二进制文件
- `QUICK_GUIDE.md` - **30秒快速选择指南** ⚡
- `COMPARISON.md` - **YZD与EVB板卡详细对比文档** 📊
- `ARMBIAN_INTEGRATION.md` - Armbian集成详细指南（中文）
- `CHANGES.md` - Android到Linux转换的技术文档
- `boot/` - 完整的可启动系统文件，已配置YZD专用设备树，硬件功能完全支持

### boot文件夹说明

`boot/` 文件夹包含完整的Linux启动配置文件，已配置使用本仓库的 `rk3399-yzd-linux.dtb` 设备树，可以在RK3399-YZD主板上完整运行。

**硬件兼容性状态:**

| 功能 | 状态 | 说明 |
|------|------|------|
| HDMI | ✅ 正常 | 视频输出正常工作 |
| RJ45 以太网 | ✅ 正常 | 千兆以太网 (RTL8211E) |
| WiFi 无线网卡 | ✅ 正常 | Broadcom AP6356S (需要固件) |
| 蓝牙 | ✅ 正常 | Broadcom AP6356S |
| USB 3.0 Type-C | ✅ 正常 | OTG + Host 模式 |
| USB 2.0 | ✅ 正常 | USB 2.0端口可用 |
| 音频 | ✅ 正常 | RT5651 Codec |
| eMMC存储 | ✅ 正常 | eMMC存储正常 |

> ℹ️ **WiFi固件:** AP6356S WiFi需要固件文件，请参考下方的WiFi配置部分安装固件。

**文件内容:**
- `Image-4.4.194` - Linux 4.4.194内核镜像 (ARM64)
- `initrd-4.4.194` - 初始化内存盘
- `config-4.4.194` - 内核编译配置文件
- `System.map-4.4.194` - 内核符号表
- `rk3399-yzd-linux.dtb` - RK3399-YZD专用设备树 (已配置)
- `rk-kernel.dtb` / `rk3399-sw799.dtb` - 原始SW799设备树 (备份)
- `extlinux/extlinux.conf` - 启动加载器配置文件
- `logo.bmp` / `logo_kernel.bmp` - 启动画面图片

**使用方法:**
将 `boot/` 文件夹内容复制到目标设备的boot分区即可启动系统。

### 📋 板卡选择指南

**不确定使用哪个板卡？**
- **快速决策**：查看 [QUICK_GUIDE.md](QUICK_GUIDE.md) - 30秒快速选择指南 ⚡
- **详细对比**：查看 [COMPARISON.md](COMPARISON.md) - 完整技术对比文档 📊

包含内容：
- 硬件配置差异
- 功能特性对比
- 应用场景推荐
- 实际案例分析
- 技术规格总结

### 快速开始

#### 方法1: 使用一键安装脚本（推荐）

**如果没有安装 git，先安装:**
```bash
apt update && apt install -y git wget curl
```

**下载并运行脚本:**
```bash
# 方式A: 使用git克隆（推荐）
git clone https://github.com/scratchyes/yzd_dts.git
cd yzd_dts
sudo ./install.sh

# 方式B: 不使用git，直接下载压缩包
wget https://github.com/scratchyes/yzd_dts/archive/refs/heads/main.zip
unzip main.zip
cd yzd_dts-main
sudo ./install.sh

# 方式C: 使用curl下载
curl -LO https://github.com/scratchyes/yzd_dts/archive/refs/heads/main.zip
unzip main.zip
cd yzd_dts-main
sudo ./install.sh
```

脚本功能：
- ✅ 自动检测 boot 分区
- ✅ 备份原有文件
- ✅ 复制所有 boot 文件
- ✅ 自动下载安装 WiFi 固件
- ✅ 验证安装完整性

#### 方法2: 手动复制

```bash
# 复制boot文件夹内容
sudo cp -r boot/* /boot/

# 安装WiFi固件
sudo mkdir -p /lib/firmware/brcm
sudo wget -O /lib/firmware/brcm/brcmfmac4356-sdio.bin \
    https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.bin
sudo wget -O /lib/firmware/brcm/brcmfmac4356-sdio.txt \
    https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.txt

# 重启
sudo reboot
```

### 使用预编译的DTB

```bash
# 复制DTB到boot分区
sudo cp rk3399-yzd-linux.dtb /boot/dtb/rockchip/

# 编辑启动配置
sudo nano /boot/armbianEnv.txt

# 添加或修改fdtfile行：
fdtfile=rockchip/rk3399-yzd-linux.dtb

# 重启
sudo reboot
```

### 从源码编译

```bash
# 安装设备树编译器
sudo apt-get install device-tree-compiler

# 编译DTS
dtc -I dts -O dtb -o rk3399-yzd-linux.dtb rk3399-yzd.dts

# 注意：编译过程会产生大量警告信息，这是正常的
# 这些警告不会影响DTB文件的功能，可以安全忽略
# 只要退出码为0（成功），DTB文件就可以使用
```

**关于编译警告：**
DTS编译时会产生许多警告（如 `clocks_property`、`gpios_property` 等）。这是正常现象，因为DTS是从Android DTB反编译而来，使用了十六进制phandle引用。这些警告**不影响功能** - 只要编译退出码为0，DTB即可正常工作。

### 集成到Armbian构建系统

有三种方式构建Armbian固件：

**方式1: GitHub Actions 自动构建（推荐）**

```bash
# 1. Fork 本仓库到您的 GitHub 账号
# 2. 进入 Actions 标签页
# 3. 选择 "Build RK3399-YZD Armbian" 工作流
# 4. 点击 "Run workflow" 选择构建选项
# 5. 等待 1-2 小时后从 Releases 下载固件
```

详细说明见 [.github/workflows/README.md](.github/workflows/README.md)

**方式2: 使用 Makefile 本地构建**

```bash
make install-deps      # 安装依赖
make dtb              # 编译DTB
make firmware         # 下载固件
make armbian-prep     # 准备构建环境
make armbian-build    # 编译Armbian镜像
```

**方式3: 手动集成**

请参阅 [BUILD_INTEGRATION.md](BUILD_INTEGRATION.md) 获取详细的集成指南，包括：
- 内核配置要求
- WiFi/蓝牙固件安装
- U-Boot配置
- 驱动验证方法

### WiFi配置

AP6356S需要固件文件：

```bash
# 固件位置
/lib/firmware/brcm/brcmfmac4356-sdio.bin
/lib/firmware/brcm/brcmfmac4356-sdio.txt
```

可从以下项目获取固件：
- [Fine3399项目](https://github.com/QXY716/Fine3399-rk3399-armbian) - 包含AP6356S固件文件和配置示例
- [Armbian固件仓库](https://github.com/armbian/firmware)

### 与Android DTS的主要差异

1. 移除了 `"rockchip,android"` 兼容字符串
2. 禁用了Android固件节点
3. 禁用了Android特定的充电配置
4. 保留了所有硬件配置不变

### 参考项目

本项目参考了以下优秀项目：
- [Fine3399 Armbian](https://github.com/QXY716/Fine3399-rk3399-armbian) - Fine3399板的Armbian适配
- [cm9vdA的DTS](https://github.com/cm9vdA/build-linux) - Fine3399主线DTS
- [Ophub Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) - Armbian构建系统

### 技术支持

遇到问题？
1. 查看 [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) 中的故障排除部分
2. 参考Fine3399项目的Issues和文档
3. 在本仓库提交Issue

### 许可证

本项目遵循设备树文件的原始许可证。

---

## English

### Overview

This repository contains Linux Device Tree Source files for the RK3399-YZD development board, converted from Android BSP to Linux-compatible format for use with Armbian and other Linux distributions.

### Hardware Support

✅ **Fully Supported:**
- HDMI video output
- Gigabit Ethernet (Realtek RTL8211E)
- WiFi (Broadcom AP6356S)
- Bluetooth (Broadcom AP6356S)
- USB 3.0 Type-C (OTG + Host)
- Audio (RT5651 Codec)
- eMMC storage
- GPIO LEDs
- Button inputs

⚠️ **Partial Support/Optional:**
- SD card (disabled by default, can be enabled)
- PCIe (disabled by default, can be enabled)

### Files

- `rk3399-yzd.dts` - Linux Device Tree Source
- `rk3399-yzd-linux.dtb` - Compiled Device Tree Binary
- `QUICK_GUIDE.md` - **30-Second Selection Guide** ⚡
- `COMPARISON.md` - **Detailed YZD vs EVB Board Comparison** 📊
- `ARMBIAN_INTEGRATION.md` - Detailed Armbian integration guide (Chinese)
- `CHANGES.md` - Technical documentation of Android to Linux conversion
- `boot/` - Complete bootable system files configured for RK3399-YZD with full hardware support

### Boot Folder

The `boot/` folder contains complete Linux boot configuration files, pre-configured with the `rk3399-yzd-linux.dtb` device tree for full hardware support on the RK3399-YZD board.

**Hardware Compatibility Status:**

| Feature | Status | Notes |
|---------|--------|-------|
| HDMI | ✅ Working | Video output works correctly |
| RJ45 Ethernet | ✅ Working | Gigabit Ethernet (RTL8211E) |
| WiFi | ✅ Working | Broadcom AP6356S (firmware required) |
| Bluetooth | ✅ Working | Broadcom AP6356S |
| USB 3.0 Type-C | ✅ Working | OTG + Host mode |
| USB 2.0 | ✅ Working | USB 2.0 ports available |
| Audio | ✅ Working | RT5651 Codec |
| eMMC Storage | ✅ Working | eMMC storage works |

> ℹ️ **WiFi Firmware:** AP6356S WiFi requires firmware files. See the WiFi Configuration section below for installation.

**Contents:**
- `Image-4.4.194` - Linux 4.4.194 kernel image (ARM64)
- `initrd-4.4.194` - Initial RAM disk
- `config-4.4.194` - Kernel build configuration
- `System.map-4.4.194` - Kernel symbol table
- `rk3399-yzd-linux.dtb` - RK3399-YZD specific Device Tree (configured)
- `rk-kernel.dtb` / `rk3399-sw799.dtb` - Original SW799 Device Tree (backup)
- `extlinux/extlinux.conf` - Boot loader configuration
- `logo.bmp` / `logo_kernel.bmp` - Boot splash images

**Usage:**
Copy the contents of the `boot/` folder to the boot partition of the target device to boot the system.

### 📋 Board Selection Guide

**Not sure which board to use?**
- **Quick Decision**: Check [QUICK_GUIDE.md](QUICK_GUIDE.md) - 30-second selection guide ⚡
- **Detailed Comparison**: Check [COMPARISON.md](COMPARISON.md) - Complete technical comparison 📊

Including:
- Hardware configuration differences
- Feature comparisons
- Application scenario recommendations
- Real-world case studies
- Technical specifications summary

### Quick Start

#### Method 1: One-Click Install Script (Recommended)

**If git is not installed, install it first:**
```bash
apt update && apt install -y git wget curl
```

**Download and run script:**
```bash
# Option A: Clone with git (Recommended)
git clone https://github.com/scratchyes/yzd_dts.git
cd yzd_dts
sudo ./install.sh

# Option B: Download zip without git
wget https://github.com/scratchyes/yzd_dts/archive/refs/heads/main.zip
unzip main.zip
cd yzd_dts-main
sudo ./install.sh

# Option C: Download with curl
curl -LO https://github.com/scratchyes/yzd_dts/archive/refs/heads/main.zip
unzip main.zip
cd yzd_dts-main
sudo ./install.sh
```

Script features:
- ✅ Auto-detect boot partition
- ✅ Backup existing files
- ✅ Copy all boot files
- ✅ Auto-download and install WiFi firmware
- ✅ Verify installation integrity

#### Method 2: Manual Copy

```bash
# Copy boot folder contents
sudo cp -r boot/* /boot/

# Install WiFi firmware
sudo mkdir -p /lib/firmware/brcm
sudo wget -O /lib/firmware/brcm/brcmfmac4356-sdio.bin \
    https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.bin
sudo wget -O /lib/firmware/brcm/brcmfmac4356-sdio.txt \
    https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.txt

# Reboot
sudo reboot
```

#### Method 3: Using Precompiled DTB Only

```bash
# Copy DTB to boot partition
sudo cp rk3399-yzd-linux.dtb /boot/dtb/rockchip/

# Edit boot configuration
sudo nano /boot/armbianEnv.txt

# Add or modify the fdtfile line:
fdtfile=rockchip/rk3399-yzd-linux.dtb

# Reboot
sudo reboot
```

#### 2. Compile from Source

```bash
# Install device tree compiler
sudo apt-get install device-tree-compiler

# Compile DTS
dtc -I dts -O dtb -o rk3399-yzd-linux.dtb rk3399-yzd.dts

# Note: You will see many warnings during compilation, this is normal
# These warnings do not affect functionality and can be safely ignored
# As long as the exit code is 0 (success), the DTB file is usable
```

**About Compilation Warnings:**
The DTS compilation generates many warnings (e.g., `clocks_property`, `gpios_property`, etc.). This is normal because the DTS was decompiled from an Android DTB and uses hexadecimal phandle references. These warnings **do not affect functionality** - if the compilation exits with code 0, the DTB works correctly.

### Integration with Armbian Build System

Three ways to build Armbian firmware:

**Method 1: GitHub Actions Auto-build (Recommended)**

```bash
# 1. Fork this repository to your GitHub account
# 2. Go to the Actions tab
# 3. Select "Build RK3399-YZD Armbian" workflow
# 4. Click "Run workflow" and select build options
# 5. Wait 1-2 hours and download firmware from Releases
```

See [.github/workflows/README.md](.github/workflows/README.md) for details

**Method 2: Local build with Makefile**

```bash
make install-deps      # Install dependencies
make dtb              # Compile DTB
make firmware         # Download firmware
make armbian-prep     # Prepare build environment
make armbian-build    # Build Armbian image
```

**Method 3: Manual integration**

For detailed configuration, see [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) for:
- Kernel configuration requirements
- WiFi/Bluetooth firmware installation
- U-Boot configuration
- Driver verification methods

### WiFi Configuration

AP6356S requires firmware files:

```bash
# Firmware location
/lib/firmware/brcm/brcmfmac4356-sdio.bin
/lib/firmware/brcm/brcmfmac4356-sdio.txt
```

Get firmware from:
- [Fine3399 Project](https://github.com/QXY716/Fine3399-rk3399-armbian) - Contains AP6356S firmware files and configuration examples
- [Armbian Firmware Repository](https://github.com/armbian/firmware)

### Key Differences from Android DTS

1. Removed `"rockchip,android"` compatible string
2. Disabled Android firmware nodes
3. Disabled Android-specific charging configuration
4. Preserved all hardware configurations

### Reference Projects

This project is inspired by:
- [Fine3399 Armbian](https://github.com/QXY716/Fine3399-rk3399-armbian) - Armbian adaptation for Fine3399
- [cm9vdA's DTS](https://github.com/cm9vdA/build-linux) - Mainline DTS for Fine3399
- [Ophub Armbian](https://github.com/ophub/amlogic-s9xxx-armbian) - Armbian build system

### Support

Having issues?
1. Check troubleshooting section in [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md)
2. Refer to Fine3399 project Issues and documentation
3. Submit an Issue in this repository

### License

This project follows the original license of the device tree files.
