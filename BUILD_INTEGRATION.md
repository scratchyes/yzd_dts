# Armbian构建集成指南

本文档说明如何将RK3399-YZD DTS集成到Armbian构建系统中。

## 方法1：使用ophub/amlogic-s9xxx-armbian构建系统

### 1. 准备构建环境

```bash
# 克隆Armbian构建仓库
git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-armbian.git
cd amlogic-s9xxx-armbian
```

### 2. 添加RK3399-YZD DTS文件

将DTS文件放置到构建系统中：

```bash
# 创建设备配置目录（如果不存在）
mkdir -p build/config/rockchip/rk3399/

# 复制DTS文件
cp /path/to/rk3399-yzd.dts build/config/rockchip/rk3399/rk3399-yzd.dts

# 或者使用DTB文件
cp /path/to/rk3399-yzd-linux.dtb build/config/rockchip/rk3399/
```

### 3. 修改构建配置

在 `build-armbian/armbian-files/platform-files/rockchip/` 目录下创建或修改配置：

**创建 `rk3399-yzd.conf`:**

```bash
#!/bin/bash

# RK3399-YZD Board Configuration
BOARD_NAME="rk3399-yzd"
FDTFILE="rockchip/rk3399-yzd.dtb"
UBOOT_TARGET_MAP="u-boot-dtb.bin;;u-boot.bin u-boot-dtb.bin"
BOOTCONFIG="rk3399_defconfig"
KERNEL_TARGET="current,edge"
CPUFREQ_REGULATOR="vdd_cpu_l,vdd_cpu_b"

# WiFi/BT Firmware
WIFI_FIRMWARE="brcmfmac4356-sdio"
BT_FIRMWARE="BCM4356A2"

# Additional packages
PACKAGE_LIST_BOARD="brcmfmac-firmware-ap6356s wireless-tools wpasupplicant"
```

### 4. 编译Armbian

```bash
cd amlogic-s9xxx-armbian

# 方法A: 使用GitHub Actions（推荐）
# 1. Fork本仓库
# 2. 在Actions中运行"Build armbian"工作流
# 3. 选择armbian_board: 添加rk3399-yzd到选项中

# 方法B: 本地编译
sudo ./rebuild -b rk3399-yzd -k 6.1.y
```

## 方法2：使用Armbian官方构建系统

### 1. 克隆Armbian构建仓库

```bash
git clone --depth 1 https://github.com/armbian/build.git
cd build
```

### 2. 添加板级支持文件

**创建 `config/boards/rk3399-yzd.conf`:**

```bash
# RK3399-YZD board configuration
BOARD_NAME="RK3399-YZD"
BOARDFAMILY="rk3399"
BOARD_MAINTAINER="YourName"
BOOTCONFIG="rk3399-yzd_defconfig"
KERNEL_TARGET="current,edge"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3399-yzd.dtb"
```

### 3. 添加DTS文件到内核源码

将DTS文件放入内核源码树：

```bash
# 编译时，DTS应该放在：
# build/cache/sources/linux-rockchip-rk3xxx/current/arch/arm64/boot/dts/rockchip/
# 
# 您可以通过patch方式添加：
mkdir -p config/kernel/rockchip-rk3xxx-current.config

# 创建patch文件
cat > config/kernel/linux-rockchip-rk3xxx-current/rk3399-yzd-add-dts.patch << 'EOF'
From: Your Name <your.email@example.com>
Date: Sat, 11 Jan 2026 00:00:00 +0000
Subject: [PATCH] arm64: dts: rockchip: Add support for RK3399-YZD board

Add device tree for RK3399-YZD board with:
- AP6356S WiFi/Bluetooth
- Dual Gigabit Ethernet
- HDMI output
- USB Type-C
- Audio codec

Signed-off-by: Your Name <your.email@example.com>
---
 arch/arm64/boot/dts/rockchip/Makefile        |    1 +
 arch/arm64/boot/dts/rockchip/rk3399-yzd.dts  | 4500 +++++++++++++++++
 2 files changed, 4501 insertions(+)
 create mode 100644 arch/arm64/boot/dts/rockchip/rk3399-yzd.dts

diff --git a/arch/arm64/boot/dts/rockchip/Makefile b/arch/arm64/boot/dts/rockchip/Makefile
index xxx..xxx 100644
--- a/arch/arm64/boot/dts/rockchip/Makefile
+++ b/arch/arm64/boot/dts/rockchip/Makefile
@@ -xx,x +xx,x @@ dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-rockpro64.dtb
 dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-sapphire.dtb
 dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-sapphire-excavator.dtb
+dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3399-yzd.dtb
 dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-bpi-r2pro.dtb
 dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3568-evb1-v10.dtb
diff --git a/arch/arm64/boot/dts/rockchip/rk3399-yzd.dts b/arch/arm64/boot/dts/rockchip/rk3399-yzd.dts
new file mode 100644
index 000000000000..xxxxxx
--- /dev/null
+++ b/arch/arm64/boot/dts/rockchip/rk3399-yzd.dts
@@ -0,0 +1,4500 @@
+// 此处粘贴完整的rk3399-yzd.dts内容
EOF
```

### 4. 添加固件文件

AP6356S需要的固件文件应放置在：

```bash
# 创建固件目录
mkdir -p config/overlay/rockchip/lib/firmware/brcm/

# 从Armbian固件仓库获取
wget -O config/overlay/rockchip/lib/firmware/brcm/brcmfmac4356-sdio.bin \
  https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.bin

wget -O config/overlay/rockchip/lib/firmware/brcm/brcmfmac4356-sdio.txt \
  https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.txt

# 可选：clm_blob文件
wget -O config/overlay/rockchip/lib/firmware/brcm/brcmfmac4356-sdio.clm_blob \
  https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.clm_blob
```

### 5. 运行构建

```bash
# 编译Armbian
./compile.sh \
  BOARD=rk3399-yzd \
  BRANCH=current \
  RELEASE=bookworm \
  BUILD_MINIMAL=no \
  BUILD_DESKTOP=no \
  KERNEL_CONFIGURE=no
```

## 方法3：手动集成到现有Armbian镜像

如果您已有Armbian镜像，可以手动集成DTB：

### 1. 挂载Armbian镜像

```bash
# 解压镜像（如果是压缩的）
xz -d Armbian_xxx.img.xz

# 挂载镜像
sudo losetup -f --show --partscan Armbian_xxx.img
# 假设输出为 /dev/loop0

# 挂载boot分区
sudo mount /dev/loop0p1 /mnt
```

### 2. 替换DTB文件

```bash
# 备份原DTB
sudo cp /mnt/dtb/rockchip/rk3399-xxx.dtb /mnt/dtb/rockchip/rk3399-xxx.dtb.bak

# 复制新DTB
sudo cp rk3399-yzd-linux.dtb /mnt/dtb/rockchip/rk3399-yzd.dtb

# 修改启动配置
sudo nano /mnt/armbianEnv.txt
# 修改或添加：
# fdtfile=rockchip/rk3399-yzd.dtb
```

### 3. 添加WiFi固件

```bash
# 挂载rootfs分区
sudo mount /dev/loop0p2 /mnt2

# 复制固件
sudo cp brcmfmac4356-sdio.* /mnt2/lib/firmware/brcm/
```

### 4. 卸载并刷入

```bash
# 卸载分区
sudo umount /mnt /mnt2
sudo losetup -d /dev/loop0

# 刷入到SD卡或eMMC
sudo dd if=Armbian_xxx.img of=/dev/sdX bs=4M status=progress
```

## Makefile构建脚本

创建 `Makefile` 简化构建流程：

```makefile
# Makefile for RK3399-YZD Armbian Integration
.PHONY: all clean dtb armbian-prep armbian-compile help

DTS_FILE := rk3399-yzd.dts
DTB_FILE := rk3399-yzd-linux.dtb
ARMBIAN_BUILD := $(HOME)/armbian-build
BOARD_NAME := rk3399-yzd

help:
	@echo "RK3399-YZD Armbian构建工具"
	@echo ""
	@echo "使用方法:"
	@echo "  make dtb              - 编译DTS为DTB"
	@echo "  make armbian-prep     - 准备Armbian构建环境"
	@echo "  make armbian-compile  - 编译完整Armbian镜像"
	@echo "  make clean            - 清理生成文件"
	@echo "  make help             - 显示此帮助信息"

dtb:
	@echo "编译DTS到DTB..."
	dtc -I dts -O dtb -o $(DTB_FILE) $(DTS_FILE)
	@echo "DTB文件生成: $(DTB_FILE)"

armbian-prep:
	@echo "准备Armbian构建环境..."
	@if [ ! -d "$(ARMBIAN_BUILD)" ]; then \
		git clone --depth 1 https://github.com/armbian/build.git $(ARMBIAN_BUILD); \
	fi
	@echo "创建板级配置..."
	@mkdir -p $(ARMBIAN_BUILD)/config/boards
	@cp config/rk3399-yzd.conf $(ARMBIAN_BUILD)/config/boards/
	@echo "复制DTS文件..."
	@mkdir -p $(ARMBIAN_BUILD)/userpatches/overlay
	@cp $(DTS_FILE) $(ARMBIAN_BUILD)/userpatches/overlay/
	@echo "准备完成!"

armbian-compile: armbian-prep
	@echo "开始编译Armbian..."
	cd $(ARMBIAN_BUILD) && \
		./compile.sh \
		BOARD=$(BOARD_NAME) \
		BRANCH=current \
		RELEASE=bookworm \
		BUILD_MINIMAL=no \
		BUILD_DESKTOP=no \
		KERNEL_CONFIGURE=no

clean:
	@echo "清理生成文件..."
	rm -f $(DTB_FILE)
	@echo "清理完成"

all: dtb armbian-compile
```

使用Makefile：

```bash
# 查看帮助
make help

# 仅编译DTB
make dtb

# 准备Armbian构建环境
make armbian-prep

# 编译完整Armbian镜像
make armbian-compile

# 清理
make clean
```

## GitHub Actions自动构建

创建 `.github/workflows/build-yzd-armbian.yml`:

```yaml
name: Build RK3399-YZD Armbian

on:
  workflow_dispatch:
    inputs:
      release:
        description: 'OS Release'
        required: true
        default: 'bookworm'
        type: choice
        options:
          - bookworm
          - jammy
      kernel:
        description: 'Kernel Version'
        required: true
        default: '6.1.y'
        type: choice
        options:
          - 6.1.y
          - 6.6.y

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y device-tree-compiler

      - name: Compile DTB
        run: |
          dtc -I dts -O dtb -o rk3399-yzd-linux.dtb rk3399-yzd.dts

      - name: Setup Armbian Build
        run: |
          git clone --depth 1 https://github.com/armbian/build.git armbian
          mkdir -p armbian/userpatches/overlay
          cp rk3399-yzd.dts armbian/userpatches/overlay/

      - name: Build Armbian
        run: |
          cd armbian
          ./compile.sh \
            BOARD=orangepi4-lts \
            BRANCH=current \
            RELEASE=${{ inputs.release }} \
            BUILD_MINIMAL=no \
            BUILD_DESKTOP=no \
            KERNEL_CONFIGURE=no

      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: rk3399-yzd-armbian-${{ inputs.release }}
          path: |
            armbian/output/images/*.img
            rk3399-yzd-linux.dtb
```

## 注意事项

1. **U-Boot兼容性**：根据Fine3399经验，可能需要使用特定的U-Boot版本
2. **固件文件**：确保AP6356S固件文件正确放置
3. **内核配置**：确保内核启用了所有必需的驱动
4. **测试验证**：在实际硬件上测试所有功能

## 参考资源

- Fine3399项目：https://github.com/QXY716/Fine3399-rk3399-armbian
- Armbian构建文档：https://docs.armbian.com/Developer-Guide_Build-Preparation/
- Ophub构建系统：https://github.com/ophub/amlogic-s9xxx-armbian
