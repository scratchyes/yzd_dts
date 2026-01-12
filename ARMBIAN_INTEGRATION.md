# Armbian Integration Guide for RK3399-YZD Board

本指南说明如何将RK3399-YZD的设备树集成到Armbian固件中。

## 硬件支持现状

### ✅ 已在DTS中配置的功能

1. **HDMI输出** 
   - 节点: `hdmi@ff940000`
   - 状态: 已启用
   - DDC I2C: `i2c@ff110000`

2. **千兆以太网**
   - 节点: `ethernet@fe300000`
   - PHY: Realtek RTL8211E (RGMII模式)
   - 状态: 已启用
   - TX延迟: 0x25, RX延迟: 0x24

3. **USB 3.0 Type-C**
   - USB OTG: `usb@fe800000/dwc3@fe800000`
   - USB Host: `usb@fe900000/dwc3@fe900000`
   - 支持: OTG和Host模式
   - 状态: 已启用

4. **WiFi (AP6356S)**
   - 接口: SDIO (dwmmc@fe310000)
   - 芯片: Broadcom AP6356S
   - 频率: 150MHz
   - 状态: 已启用
   - 配置: 支持SDR104模式

5. **蓝牙 (AP6356S)**
   - 接口: UART4
   - 芯片: Broadcom AP6356S
   - 状态: 已启用

6. **音频**
   - Codec: RT5651 (i2c@ff110000/rt5651@1a)
   - I2S接口: i2s@ff890000
   - 状态: 已启用

7. **SD卡槽**
   - 节点: dwmmc@fe320000
   - 状态: 已禁用（可根据需要启用）

8. **eMMC存储**
   - 节点: sdhci@fe330000
   - 支持: HS400增强选通模式
   - 状态: 已启用

9. **PCIe**
   - 节点: pcie@f8000000
   - 状态: 已禁用（可根据需要启用）

## ⚠️ 重要提示

**在使用本DTS之前，请注意：**
1. 本DTS基于Android BSP转换而来，部分GPIO和硬件配置可能需要根据您的实际硬件板调整
2. 请确认您的板子与YZD开发板的硬件设计一致
3. 使用不兼容的U-Boot或设备树可能导致设备无法启动
4. 建议先在测试环境验证所有功能

## Armbian集成步骤

### 1. 准备设备树文件

当前DTS已经转换为Linux兼容格式，包含以下修改：
- 移除了 `"rockchip,android"` 兼容字符串
- 禁用了Android固件节点
- 禁用了Android uboot-charge配置

### 2. 编译设备树

```bash
# 使用设备树编译器编译
dtc -I dts -O dtb -o rk3399-yzd-linux.dtb rk3399-yzd.dts

# 或者在Armbian构建系统中
# 将rk3399-yzd.dts复制到: 
# build/userpatches/overlay/rk3399-yzd.dts
```

### 3. Armbian构建配置

在Armbian构建系统中，需要确保以下内核配置启用：

#### WiFi/蓝牙驱动 (AP6356S)
```
CONFIG_BRCMFMAC=m
CONFIG_BRCMFMAC_SDIO=y
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_BCM=y
```

#### 以太网驱动
```
CONFIG_STMMAC_ETH=y
CONFIG_DWMAC_GENERIC=y
CONFIG_ROCKCHIP_PHY=y
CONFIG_REALTEK_PHY=y
```

#### USB驱动
```
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_DUAL_ROLE=y
CONFIG_EXTCON_USB_GPIO=y
```

#### 音频驱动
```
CONFIG_SND_SOC_ROCKCHIP=y
CONFIG_SND_SOC_ROCKCHIP_I2S=y
CONFIG_SND_SOC_RT5651=m
CONFIG_SND_SIMPLE_CARD=m
```

#### HDMI驱动
```
CONFIG_DRM_ROCKCHIP=y
CONFIG_ROCKCHIP_DW_HDMI=y
```

### 4. WiFi固件安装

AP6356S需要Broadcom固件文件：

```bash
# 固件文件位置
/lib/firmware/brcm/brcmfmac4356-sdio.bin
/lib/firmware/brcm/brcmfmac4356-sdio.txt

# 对于某些内核版本，可能还需要nvram文件
/lib/firmware/brcm/brcmfmac4356-sdio.clm_blob

# 参考Fine3399项目或Armbian固件仓库获取固件
# https://github.com/QXY716/Fine3399-rk3399-armbian
# https://github.com/armbian/firmware
```

### 5. U-Boot配置

⚠️ **警告：使用不兼容的U-Boot可能导致设备变砖！**

根据Fine3399项目经验，需要使用兼容的U-Boot版本。参考：
- https://github.com/QXY716/u-boot/blob/main/u-boot/rockchip/fine3399/uboot-bozz-rk3399.bin

**使用U-Boot前必须：**
1. 验证MD5/SHA256校验和
2. 确认与您的硬件版本兼容
3. 准备好恢复方案（如Maskrom模式刷机工具）
4. 在测试设备上先行验证

### 6. 设备树在Armbian中的位置

```
# 编译后的DTB文件应放置在：
/boot/dtb/rockchip/rk3399-yzd-linux.dtb

# 在/boot/armbianEnv.txt中配置：
fdtfile=rockchip/rk3399-yzd-linux.dtb
```

## 驱动验证

### WiFi测试
```bash
# 检查WiFi接口
ip link show wlan0

# 扫描WiFi网络
sudo iwlist wlan0 scan

# 使用NetworkManager连接
nmcli device wifi connect "SSID" password "PASSWORD"
```

### 蓝牙测试
```bash
# 检查蓝牙服务
systemctl status bluetooth

# 扫描蓝牙设备
bluetoothctl scan on
```

### 网卡测试
```bash
# 检查以太网接口
ip link show eth0

# 测试连接速度
ethtool eth0
```

### HDMI测试
```bash
# 检查显示输出
xrandr

# 检查HDMI音频
aplay -l
```

### USB测试
```bash
# 列出USB设备
lsusb

# 检查USB3.0速度
lsusb -t
```

## 已知问题和解决方案

### 1. WiFi无法启动
- 确认固件文件已正确安装
- 检查sdio-pwrseq配置
- 验证GPIO配置正确

### 2. 蓝牙无法连接
- 确认UART4已正确配置
- 检查蓝牙固件加载
- 验证GPIO重置引脚

### 3. HDMI无输出
- 检查DDC I2C总线
- 验证电源域配置
- 确认内核HDMI驱动已加载

## 参考资源

- **Fine3399 Armbian项目**: https://github.com/QXY716/Fine3399-rk3399-armbian
- **Fine3399 DTS参考**: https://github.com/cm9vdA/build-linux/blob/master/boot/dts/rockchip/mainline/rk3399-fine3399.dts
- **Ophub Armbian项目**: https://github.com/ophub/amlogic-s9xxx-armbian
- **RK3399技术参考手册**: Rockchip官方文档

## 技术支持

如需进一步的技术支持或遇到问题，请参考：
- Armbian官方论坛
- RK3399相关社区
- Fine3399项目Issues
