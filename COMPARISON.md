# RK3399设备树对比：YZD vs EVB板卡

[中文](#中文) | [English](#english)

---

## 中文

### 概述

本文档详细对比了三个RK3399开发板的设备树配置：

1. **rk3399-yzd.dts** - YZD开发板（从Android DTB转换）
2. **rk3399-evb.dts** - 标准EVB评估板
3. **rk3399-evb-ind-lpddr4-linux.dts** - EVB IND LPDDR4工业级板卡

### 1. 文件结构对比

| 特性 | YZD | EVB | EVB-IND-LPDDR4 |
|------|-----|-----|----------------|
| **文件格式** | 编译后的DTS（扁平化，数字phandle） | 源代码DTS（层次化，标签节点） | 源代码DTS（包含文件） |
| **包含文件** | 无（独立文件） | `rk3399.dtsi` | `rk3399-evb-ind.dtsi`, `rk3399-linux.dtsi` |
| **总行数** | ~4356行 | ~485行 | ~377行 |
| **兼容性字符串** | `rockchip,rk3399-excavator-edp` | `rockchip,rk3399-evb` | `rockchip,rk3399-evb-ind-lpddr4-linux` |
| **板卡型号** | "Excavator Board edp (Linux)" | "Evaluation Board" | "EVB IND LPDDR4 Board edp (Linux)" |

**分析：**
- YZD是从Android DTB反编译的完整配置，包含所有硬件定义
- EVB是精简的参考设计，依赖包含文件
- EVB-IND-LPDDR4采用模块化设计，使用多个dtsi文件

### 2. 硬件平台定位

#### YZD (Excavator平台)
- **定位**：多媒体Android设备转Linux
- **特点**：完整的音视频I/O功能
- **目标**：消费电子产品

#### EVB (评估板)
- **定位**：开发参考平台
- **特点**：最小化硬件配置
- **目标**：开发学习和原型验证

#### EVB-IND-LPDDR4 (工业级)
- **定位**：工业应用产品
- **特点**：增强电源管理和相机支持
- **目标**：工业视觉和嵌入式系统

### 3. 主要硬件配置对比

#### 3.1 显示系统

| 板卡 | 显示接口 | 面板配置 | 背光控制 | 特殊功能 |
|------|----------|----------|----------|----------|
| **YZD** | EDP + HDMI | 编译时配置 | PWM控制 | DP音频支持 |
| **EVB** | EDP | LG LP079QX1 | PWM (pwm0) | 强制HPD |
| **EVB-IND-LPDDR4** | EDP + HDMI | Simple panel (1536x2048) | PWM (gpio1_13) | 显示子系统路由 |

**关键差异：**
- YZD支持完整的HDMI输入/输出功能
- EVB使用特定的LG面板
- EVB-IND-LPDDR4支持高分辨率工业显示器

#### 3.2 网络连接

| 板卡 | 以太网 | WiFi | 蓝牙 |
|------|--------|------|------|
| **YZD** | ✅ RTL8211E (RGMII) | ✅ AP6356S | ✅ AP6356S |
| **EVB** | ✅ RGMII配置 | ❌ | ❌ |
| **EVB-IND-LPDDR4** | ❌ 未配置 | ❌ | ❌ |

**YZD以太网配置：**
```dts
ethernet@fe300000 {
    phy-mode = "rgmii";
    snps,reset-gpio = <0x19 0xf 0x1>;
    tx_delay = <0x25>;
    rx_delay = <0x24>;
    status = "okay";
};
```

**WiFi/蓝牙配置：**
- 芯片型号：Broadcom AP6356S
- 固件需求：`brcmfmac4356-sdio.bin`
- SDIO接口，支持1.8V电压

#### 3.3 音频系统

| 板卡 | 音频编解码器 | I2S接口 | 特殊功能 |
|------|--------------|---------|----------|
| **YZD** | RT5651, ES8316, ES7210 | 多路I2S | HDMI音频输入 (TC358749x) |
| **EVB** | 无 | 未配置 | 无 |
| **EVB-IND-LPDDR4** | RK809集成 | i2s0, i2s1, i2s2 | RK809音频 |

**YZD音频特性：**
- **RT5651**: 主音频编解码器
  - I2C地址：0x1a
  - 支持耳机检测
  - PA增益控制
- **ES8316**: 备用音频编解码器（默认禁用）
- **ES7210**: 麦克风阵列（MicArray_0）
  - I2C地址：0x43
  - 256倍采样频率
- **TC358749x**: HDMI输入桥接器（默认禁用）

#### 3.4 存储配置

| 板卡 | eMMC | SD卡 | SDIO (WiFi) |
|------|------|------|-------------|
| **YZD** | ✅ HS400 | ✅ (禁用) | ✅ AP6356S |
| **EVB** | ✅ HS400增强选通 | ❌ | ❌ |
| **EVB-IND-LPDDR4** | ✅ 通过dtsi | ❌ | ❌ |

**YZD存储详情：**
```dts
sdhci@fe330000 {
    bus-width = <0x8>;
    mmc-hs400-1_8v;
    mmc-hs400-enhanced-strobe;
    non-removable;
    status = "okay";
};
```

#### 3.5 USB配置

| 板卡 | USB 3.0 OTG | USB 3.0 Host | USB 2.0 Host | Type-C |
|------|-------------|--------------|--------------|--------|
| **YZD** | ✅ dwc3 (OTG模式) | ✅ dwc3 | ✅ EHCI/OHCI x2 | ✅ |
| **EVB** | ❌ | ❌ | ✅ EHCI/OHCI x2 | ❌ |
| **EVB-IND-LPDDR4** | ❌ | ❌ | ❌ 未配置 | ❌ |

**YZD USB特性：**
- USB3.0 OTG支持热插拔检测（fusb302）
- 双USB 3.0控制器
- 完整的PHY配置（u2phy0, u2phy1, typec_phy0, typec_phy1）

#### 3.6 相机系统

| 板卡 | ISP | MIPI CSI | 相机模组 |
|------|-----|----------|----------|
| **YZD** | ✅ ISP0, ISP1 | ✅ 支持 | ✅ 配置但禁用 |
| **EVB** | ❌ | ❌ | ❌ |
| **EVB-IND-LPDDR4** | ✅ | ✅ DPHY RX0 | ✅ OV13850 + VM149C |

**EVB-IND-LPDDR4相机配置：**
```dts
ov13850@10 {
    compatible = "ovti,ov13850";
    reset-gpios = <&gpio1 RK_PA3 GPIO_ACTIVE_HIGH>;
    pwdn-gpios = <&gpio1 RK_PD0 GPIO_ACTIVE_HIGH>;
    lens-focus = <&vm149c>;
};
```

### 4. 电源管理对比

#### YZD电源系统
**PMIC**: RK808 @ I2C0地址0x1b
- **DCDC通道**：
  - DCDC_REG1: vdd_center (0.75-1.35V)
  - DCDC_REG2: vdd_cpu_l (0.75-1.35V)
  - DCDC_REG3: vcc_ddr
  - DCDC_REG4: vcc_1v8 (1.8V)
- **LDO通道**：
  - LDO1-8：各种电压供应
  - 支持睡眠模式电压调整
- **开关稳压器**：
  - SWITCH_REG1: vcc3v3_s3
  - SWITCH_REG2: vcc3v3_s0

**外部稳压器**：
- SYR827 @ 0x40: vdd_cpu_b (0.7125-1.5V)
- SYR828 @ 0x41: vdd_gpu (0.7125-1.5V)
- PWM稳压器: vdd_log (PWM2控制)

#### EVB电源系统
**简化配置**：
- RK808 PMIC + Silergy稳压器
- PWM控制的vdd_center

#### EVB-IND-LPDDR4电源系统
**工业级增强**：
- vcca_0v9: 0.9V始终开启（工业级稳定性）
- vcc0v9_soc: 0.9V SOC供电
- 增强的电源管理用于LPDDR4内存

### 5. GPIO和引脚配置

#### 引脚控制复杂度对比

| 板卡 | Pinctrl节点数 | 配置范围 | 特殊GPIO |
|------|--------------|----------|----------|
| **YZD** | ~100+ | 完整3500+行 | LED, 按键, 音频控制 |
| **EVB** | ~3 | 最小化 | PMIC中断, USB电源 |
| **EVB-IND-LPDDR4** | ~5 | 中等 | LCD复位, 相机控制 |

**YZD关键GPIO配置：**
- **LED控制**: 
  - gpio0_11 (工作LED)
  - gpio0_12 (用户LED)
- **按键输入**:
  - gpio0_5 (电源键)
  - ADC按键：音量上/下、菜单、返回
- **音频控制**:
  - gpio4_30 (PA使能)
  - gpio4_21 (PA测试)
- **显示控制**:
  - gpio4_29 (背光使能)
  - gpio1_0 (LCD电源)

### 6. 独特功能对比

#### YZD独特功能
1. **完整的Android硬件支持**
   - Ramoops内存调试支持
   - FIQ调试器
   - Android固件节点（已禁用）

2. **多媒体处理**
   - HDMI输入桥接器 (TC358749x)
   - 麦克风阵列支持
   - 多音频编解码器切换

3. **用户交互**
   - 7键输入系统（电源、音量、菜单等）
   - 耳机检测通过ADC
   - 摇杆式耳机按键支持

4. **高级网络**
   - 千兆以太网
   - 双频WiFi (2.4G/5G)
   - BT 4.2支持

#### EVB独特功能
1. **开发友好**
   - 简洁的参考设计
   - 易于修改和扩展
   - PCIe预留（可启用）

2. **标准接口**
   - 标准的EVB引脚布局
   - 与Rockchip文档一致

#### EVB-IND-LPDDR4独特功能
1. **工业级特性**
   - 增强的电源管理
   - LPDDR4内存支持
   - 工业温度范围

2. **视觉应用**
   - 1300万像素相机
   - 自动对焦电机控制
   - ISP图像处理管线

3. **Linux优化**
   - 显示子系统路由
   - 优化的MIPI配置
   - RK809音频集成

### 7. 应用场景推荐

#### 选择YZD，如果您需要：
- ✅ 完整的多媒体功能
- ✅ WiFi/蓝牙连接
- ✅ Android转Linux项目
- ✅ 丰富的音频I/O
- ✅ 现成的硬件配置

**适用场景**：
- 智能音箱
- 多媒体播放器
- Android TV盒子改Linux
- 开发板快速原型

#### 选择EVB，如果您需要：
- ✅ 学习RK3399开发
- ✅ 简单的参考设计
- ✅ 自定义硬件配置
- ✅ 最小化启动系统

**适用场景**：
- 教学和学习
- 硬件开发验证
- 定制系统原型
- PCIe扩展项目

#### 选择EVB-IND-LPDDR4，如果您需要：
- ✅ 工业级稳定性
- ✅ 相机视觉应用
- ✅ LPDDR4内存性能
- ✅ 生产级产品

**适用场景**：
- 机器视觉系统
- 工业控制器
- 人脸识别设备
- 智能监控系统

### 8. 技术规格总结

| 特性类别 | YZD | EVB | EVB-IND-LPDDR4 |
|----------|-----|-----|----------------|
| **复杂度** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **功能完整性** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **易用性** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **可扩展性** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **生产就绪** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |

### 9. 迁移建议

#### 从YZD迁移到EVB
- 需要重新配置WiFi/BT驱动
- 音频系统需要完全重写
- GPIO映射需要调整

#### 从EVB迁移到YZD
- 可以复用大部分YZD硬件
- 需要禁用不需要的外设
- 建议保留网络和音频配置

#### 从EVB-IND-LPDDR4迁移到YZD
- 相机配置需要适配
- 电源管理差异较大
- 可以参考YZD的ISP配置

### 10. 参考资源

#### YZD相关
- 本仓库：设备树和集成指南
- [Fine3399项目](https://github.com/QXY716/Fine3399-rk3399-armbian)：类似硬件参考

#### EVB相关
- Rockchip官方文档
- Linux内核文档：`Documentation/devicetree/bindings/arm/rockchip.yaml`

#### EVB-IND-LPDDR4相关
- Rockchip工业板文档
- RK809音频驱动文档

---

## English

### Overview

This document provides a detailed comparison of three RK3399 development board device trees:

1. **rk3399-yzd.dts** - YZD Board (converted from Android DTB)
2. **rk3399-evb.dts** - Standard EVB Evaluation Board
3. **rk3399-evb-ind-lpddr4-linux.dts** - EVB IND LPDDR4 Industrial Board

### 1. File Structure Comparison

| Feature | YZD | EVB | EVB-IND-LPDDR4 |
|---------|-----|-----|----------------|
| **File Format** | Compiled DTS (flat, numeric phandles) | Source DTS (hierarchical, labeled nodes) | Source DTS (with includes) |
| **Includes** | None (standalone) | `rk3399.dtsi` | `rk3399-evb-ind.dtsi`, `rk3399-linux.dtsi` |
| **Total Lines** | ~4356 | ~485 | ~377 |
| **Compatible** | `rockchip,rk3399-excavator-edp` | `rockchip,rk3399-evb` | `rockchip,rk3399-evb-ind-lpddr4-linux` |
| **Model** | "Excavator Board edp (Linux)" | "Evaluation Board" | "EVB IND LPDDR4 Board edp (Linux)" |

**Analysis:**
- YZD is a complete decompiled Android DTB with all hardware definitions
- EVB is a minimal reference design relying on include files
- EVB-IND-LPDDR4 uses modular design with multiple dtsi files

### 2. Hardware Platform Positioning

#### YZD (Excavator Platform)
- **Positioning**: Multimedia Android-to-Linux device
- **Features**: Complete audio/video I/O functionality
- **Target**: Consumer electronics products

#### EVB (Evaluation Board)
- **Positioning**: Development reference platform
- **Features**: Minimized hardware configuration
- **Target**: Learning and prototype validation

#### EVB-IND-LPDDR4 (Industrial Grade)
- **Positioning**: Industrial application product
- **Features**: Enhanced power management and camera support
- **Target**: Industrial vision and embedded systems

### 3. Major Hardware Configuration Comparison

#### 3.1 Display System

| Board | Display Interface | Panel Config | Backlight | Special Features |
|-------|------------------|--------------|-----------|------------------|
| **YZD** | EDP + HDMI | Compile-time config | PWM control | DP audio support |
| **EVB** | EDP | LG LP079QX1 | PWM (pwm0) | Force HPD |
| **EVB-IND-LPDDR4** | EDP + HDMI | Simple panel (1536x2048) | PWM (gpio1_13) | Display subsystem routing |

**Key Differences:**
- YZD supports full HDMI input/output functionality
- EVB uses specific LG panel
- EVB-IND-LPDDR4 supports high-resolution industrial displays

#### 3.2 Network Connectivity

| Board | Ethernet | WiFi | Bluetooth |
|-------|----------|------|-----------|
| **YZD** | ✅ RTL8211E (RGMII) | ✅ AP6356S | ✅ AP6356S |
| **EVB** | ✅ RGMII config | ❌ | ❌ |
| **EVB-IND-LPDDR4** | ❌ Not configured | ❌ | ❌ |

**YZD Ethernet Configuration:**
```dts
ethernet@fe300000 {
    phy-mode = "rgmii";
    snps,reset-gpio = <0x19 0xf 0x1>;
    tx_delay = <0x25>;
    rx_delay = <0x24>;
    status = "okay";
};
```

**WiFi/Bluetooth Configuration:**
- Chip: Broadcom AP6356S
- Firmware: `brcmfmac4356-sdio.bin`
- SDIO interface, 1.8V support

#### 3.3 Audio System

| Board | Audio Codec | I2S Interface | Special Features |
|-------|-------------|---------------|------------------|
| **YZD** | RT5651, ES8316, ES7210 | Multiple I2S | HDMI audio input (TC358749x) |
| **EVB** | None | Not configured | None |
| **EVB-IND-LPDDR4** | RK809 integrated | i2s0, i2s1, i2s2 | RK809 audio |

**YZD Audio Features:**
- **RT5651**: Primary audio codec
  - I2C address: 0x1a
  - Headset detection support
  - PA gain control
- **ES8316**: Alternative audio codec (disabled by default)
- **ES7210**: Microphone array (MicArray_0)
  - I2C address: 0x43
  - 256x sampling frequency
- **TC358749x**: HDMI input bridge (disabled by default)

#### 3.4 Storage Configuration

| Board | eMMC | SD Card | SDIO (WiFi) |
|-------|------|---------|-------------|
| **YZD** | ✅ HS400 | ✅ (disabled) | ✅ AP6356S |
| **EVB** | ✅ HS400 enhanced strobe | ❌ | ❌ |
| **EVB-IND-LPDDR4** | ✅ via dtsi | ❌ | ❌ |

**YZD Storage Details:**
```dts
sdhci@fe330000 {
    bus-width = <0x8>;
    mmc-hs400-1_8v;
    mmc-hs400-enhanced-strobe;
    non-removable;
    status = "okay";
};
```

#### 3.5 USB Configuration

| Board | USB 3.0 OTG | USB 3.0 Host | USB 2.0 Host | Type-C |
|-------|-------------|--------------|--------------|--------|
| **YZD** | ✅ dwc3 (OTG mode) | ✅ dwc3 | ✅ EHCI/OHCI x2 | ✅ |
| **EVB** | ❌ | ❌ | ✅ EHCI/OHCI x2 | ❌ |
| **EVB-IND-LPDDR4** | ❌ | ❌ | ❌ Not configured | ❌ |

**YZD USB Features:**
- USB 3.0 OTG with hotplug detection (fusb302)
- Dual USB 3.0 controllers
- Complete PHY configuration (u2phy0, u2phy1, typec_phy0, typec_phy1)

#### 3.6 Camera System

| Board | ISP | MIPI CSI | Camera Module |
|-------|-----|----------|---------------|
| **YZD** | ✅ ISP0, ISP1 | ✅ Supported | ✅ Configured but disabled |
| **EVB** | ❌ | ❌ | ❌ |
| **EVB-IND-LPDDR4** | ✅ | ✅ DPHY RX0 | ✅ OV13850 + VM149C |

**EVB-IND-LPDDR4 Camera Configuration:**
```dts
ov13850@10 {
    compatible = "ovti,ov13850";
    reset-gpios = <&gpio1 RK_PA3 GPIO_ACTIVE_HIGH>;
    pwdn-gpios = <&gpio1 RK_PD0 GPIO_ACTIVE_HIGH>;
    lens-focus = <&vm149c>;
};
```

### 4. Power Management Comparison

#### YZD Power System
**PMIC**: RK808 @ I2C0 address 0x1b
- **DCDC Channels**:
  - DCDC_REG1: vdd_center (0.75-1.35V)
  - DCDC_REG2: vdd_cpu_l (0.75-1.35V)
  - DCDC_REG3: vcc_ddr
  - DCDC_REG4: vcc_1v8 (1.8V)
- **LDO Channels**:
  - LDO1-8: Various voltage supplies
  - Sleep mode voltage adjustment
- **Switch Regulators**:
  - SWITCH_REG1: vcc3v3_s3
  - SWITCH_REG2: vcc3v3_s0

**External Regulators**:
- SYR827 @ 0x40: vdd_cpu_b (0.7125-1.5V)
- SYR828 @ 0x41: vdd_gpu (0.7125-1.5V)
- PWM regulator: vdd_log (PWM2 control)

#### EVB Power System
**Simplified Configuration**:
- RK808 PMIC + Silergy regulators
- PWM-controlled vdd_center

#### EVB-IND-LPDDR4 Power System
**Industrial Grade Enhancement**:
- vcca_0v9: 0.9V always-on (industrial stability)
- vcc0v9_soc: 0.9V SOC supply
- Enhanced power management for LPDDR4 memory

### 5. GPIO and Pin Configuration

#### Pinctrl Complexity Comparison

| Board | Pinctrl Nodes | Configuration Scope | Special GPIOs |
|-------|--------------|---------------------|---------------|
| **YZD** | ~100+ | Complete 3500+ lines | LEDs, buttons, audio control |
| **EVB** | ~3 | Minimal | PMIC interrupt, USB power |
| **EVB-IND-LPDDR4** | ~5 | Medium | LCD reset, camera control |

**YZD Key GPIO Configurations:**
- **LED Control**: 
  - gpio0_11 (work LED)
  - gpio0_12 (user LED)
- **Button Inputs**:
  - gpio0_5 (power key)
  - ADC keys: volume up/down, menu, back
- **Audio Control**:
  - gpio4_30 (PA enable)
  - gpio4_21 (PA test)
- **Display Control**:
  - gpio4_29 (backlight enable)
  - gpio1_0 (LCD power)

### 6. Unique Features Comparison

#### YZD Unique Features
1. **Complete Android Hardware Support**
   - Ramoops memory debugging support
   - FIQ debugger
   - Android firmware nodes (disabled)

2. **Multimedia Processing**
   - HDMI input bridge (TC358749x)
   - Microphone array support
   - Multiple audio codec switching

3. **User Interaction**
   - 7-key input system (power, volume, menu, etc.)
   - Headset detection via ADC
   - Inline remote support

4. **Advanced Networking**
   - Gigabit Ethernet
   - Dual-band WiFi (2.4G/5G)
   - BT 4.2 support

#### EVB Unique Features
1. **Developer Friendly**
   - Clean reference design
   - Easy to modify and extend
   - PCIe reserved (can enable)

2. **Standard Interfaces**
   - Standard EVB pin layout
   - Consistent with Rockchip documentation

#### EVB-IND-LPDDR4 Unique Features
1. **Industrial Grade Features**
   - Enhanced power management
   - LPDDR4 memory support
   - Industrial temperature range

2. **Vision Applications**
   - 13MP camera
   - Auto-focus motor control
   - ISP image processing pipeline

3. **Linux Optimization**
   - Display subsystem routing
   - Optimized MIPI configuration
   - RK809 audio integration

### 7. Application Scenario Recommendations

#### Choose YZD if you need:
- ✅ Complete multimedia functionality
- ✅ WiFi/Bluetooth connectivity
- ✅ Android-to-Linux projects
- ✅ Rich audio I/O
- ✅ Ready-made hardware configuration

**Use Cases**:
- Smart speakers
- Multimedia players
- Android TV box to Linux
- Quick prototyping

#### Choose EVB if you need:
- ✅ Learning RK3399 development
- ✅ Simple reference design
- ✅ Custom hardware configuration
- ✅ Minimal boot system

**Use Cases**:
- Teaching and learning
- Hardware development verification
- Custom system prototyping
- PCIe expansion projects

#### Choose EVB-IND-LPDDR4 if you need:
- ✅ Industrial grade stability
- ✅ Camera vision applications
- ✅ LPDDR4 memory performance
- ✅ Production-grade products

**Use Cases**:
- Machine vision systems
- Industrial controllers
- Face recognition devices
- Smart surveillance systems

### 8. Technical Specifications Summary

| Feature Category | YZD | EVB | EVB-IND-LPDDR4 |
|-----------------|-----|-----|----------------|
| **Complexity** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Feature Completeness** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **Ease of Use** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Extensibility** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Production Ready** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |

### 9. Migration Guidelines

#### Migrating from YZD to EVB
- Need to reconfigure WiFi/BT drivers
- Audio system requires complete rewrite
- GPIO mapping needs adjustment

#### Migrating from EVB to YZD
- Can reuse most YZD hardware
- Need to disable unnecessary peripherals
- Recommend keeping network and audio configuration

#### Migrating from EVB-IND-LPDDR4 to YZD
- Camera configuration needs adaptation
- Significant power management differences
- Can reference YZD ISP configuration

### 10. Reference Resources

#### YZD Related
- This repository: Device tree and integration guides
- [Fine3399 Project](https://github.com/QXY716/Fine3399-rk3399-armbian): Similar hardware reference

#### EVB Related
- Rockchip official documentation
- Linux kernel docs: `Documentation/devicetree/bindings/arm/rockchip.yaml`

#### EVB-IND-LPDDR4 Related
- Rockchip industrial board documentation
- RK809 audio driver documentation

---

## Conclusion

**Quick Decision Guide:**

| If you want... | Choose... | Because... |
|----------------|-----------|------------|
| Ready-to-use Linux board with WiFi | **YZD** | Complete hardware support |
| Learning platform | **EVB** | Simple and well-documented |
| Production with cameras | **EVB-IND-LPDDR4** | Industrial grade + vision |
| Android TV box alternative | **YZD** | Multimedia optimized |
| Custom development | **EVB** | Flexible and extensible |
| Industrial automation | **EVB-IND-LPDDR4** | Robust and reliable |

For most users migrating from Android devices or wanting a full-featured Linux board, **YZD** is recommended. For production industrial applications with camera requirements, **EVB-IND-LPDDR4** is the better choice. For learning and custom development, start with **EVB**.
