# GitHub Actions 自动构建说明

## 使用方法

1. **启动构建**
   - 进入仓库的 Actions 标签页
   - 选择 "Build RK3399-YZD Armbian" 工作流
   - 点击 "Run workflow" 按钮

2. **选择构建选项**
   - **OS Release**: 选择 Debian/Ubuntu 发行版 (推荐 bookworm)
   - **Kernel Version**: 选择内核版本 (推荐 6.1.y)
   - **Rootfs Type**: 选择文件系统类型 (ext4 或 btrfs)

3. **等待构建完成**
   - 构建过程大约需要 1-2 小时
   - 可以在 Actions 页面查看实时日志

4. **下载固件**
   - 构建完成后，固件会自动上传到 Releases
   - 在 Releases 页面下载 `Armbian_RK3399-YZD_*.img.xz` 文件

## 构建流程

工作流会自动执行以下步骤：

1. ✅ 从修改后的 `rk3399-yzd.dts` 编译 DTB
2. ✅ 下载 Armbian 构建系统
3. ✅ 准备 RK3399-YZD 设备树文件
4. ✅ 下载 AP6356S WiFi/BT 固件
5. ✅ 编译 Armbian 基础镜像
6. ✅ 集成 RK3399-YZD DTB 到镜像
7. ✅ 上传固件到 Releases

## 特性

- 自动使用仓库中修改过的 DTS 文件
- 预装 AP6356S WiFi/Bluetooth 固件
- 自动配置设备树为 RK3399-YZD
- 生成优化的压缩镜像

## 注意事项

- 首次构建可能需要下载较多依赖
- 确保仓库有足够的 Actions 配额
- 构建日志可用于排查问题
