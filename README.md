# RK3399-YZD Device Tree for Linux/Armbian

[English](#english) | [中文](#中文)

## 中文

### 概述

本仓库包含RK3399-YZD开发板的Linux设备树源文件，已从Android BSP转换为Linux兼容格式，可用于Armbian等Linux发行版。

### 硬件支持

✅ **完全支持的功能:**
- HDMI视频输出
- 千兆以太网 (Realtek RTL8211E)
- WiFi (Broadcom AP6354)
- 蓝牙 (Broadcom AP6354)
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

#### 1. 使用预编译的DTB

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

#### 2. 从源码编译

```bash
# 安装设备树编译器
sudo apt-get install device-tree-compiler

# 编译DTS
dtc -I dts -O dtb -o rk3399-yzd-linux.dtb rk3399-yzd.dts
```

#### 3. 集成到Armbian构建系统

请参阅 [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) 获取详细的集成指南，包括：
- 内核配置要求
- WiFi/蓝牙固件安装
- U-Boot配置
- 驱动验证方法

### WiFi配置

AP6354需要固件文件：

```bash
# 固件位置
/lib/firmware/brcm/brcmfmac43340-sdio.bin
/lib/firmware/brcm/brcmfmac43340-sdio.txt
```

可从以下项目获取固件：
- [Fine3399项目](https://github.com/QXY716/Fine3399-rk3399-armbian) - 包含AP6354固件文件和配置示例

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
- WiFi (Broadcom AP6354)
- Bluetooth (Broadcom AP6354)
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
```

#### 3. Integration with Armbian Build System

See [ARMBIAN_INTEGRATION.md](ARMBIAN_INTEGRATION.md) for detailed integration guide including:
- Kernel configuration requirements
- WiFi/Bluetooth firmware installation
- U-Boot configuration
- Driver verification methods

### WiFi Configuration

AP6354 requires firmware files:

```bash
# Firmware location
/lib/firmware/brcm/brcmfmac43340-sdio.bin
/lib/firmware/brcm/brcmfmac43340-sdio.txt
```

Get firmware from:
- [Fine3399 Project](https://github.com/QXY716/Fine3399-rk3399-armbian) - Contains AP6354 firmware files and configuration examples

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
