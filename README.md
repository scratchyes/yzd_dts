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
- `ARMBIAN_INTEGRATION.md` - Armbian集成详细指南（中文）
- `CHANGES.md` - Android到Linux转换的技术文档

### 快速开始

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

请参阅 [BUILD_INTEGRATION.md](BUILD_INTEGRATION.md) 获取详细的集成指南，包括：
- 三种集成方法（ophub构建系统、Armbian官方构建、手动集成）
- Makefile自动化构建
- GitHub Actions自动构建
- 板级配置文件

**快速构建：**

```bash
# 安装依赖
make install-deps

# 编译DTB
make dtb

# 下载固件
make firmware

# 准备Armbian构建环境
make armbian-prep

# 编译Armbian镜像
make armbian-build
```

详细配置请参阅 [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) 获取详细的集成指南，包括：
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
- `ARMBIAN_INTEGRATION.md` - Detailed Armbian integration guide (Chinese)
- `CHANGES.md` - Technical documentation of Android to Linux conversion

### Quick Start

#### 1. Using Precompiled DTB

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

See [BUILD_INTEGRATION.md](BUILD_INTEGRATION.md) for detailed integration guide, including:
- Three integration methods (ophub build system, official Armbian build, manual integration)
- Makefile automation
- GitHub Actions automated builds
- Board configuration files

**Quick Build:**

```bash
# Install dependencies
make install-deps

# Compile DTB
make dtb

# Download firmware
make firmware

# Prepare Armbian build environment
make armbian-prep

# Build Armbian image
make armbian-build
```

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
