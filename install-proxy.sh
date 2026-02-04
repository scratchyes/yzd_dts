#!/bin/bash
set -e

# ================= 配置项 =================
REPO="scratchyes/yzd_dts"
BRANCH="main"
# 修改为根目录路径
REMOTE_PATH="gh-smart-proxy.sh"
# 构造 Raw URL
DOWNLOAD_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${REMOTE_PATH}"
# 本地安装路径
INSTALL_DIR="$HOME"
INSTALL_FILE="${INSTALL_DIR}/.gh-smart-proxy.sh"
# =========================================

echo "==============================================="
echo "   GitHub Smart Proxy 自动安装程序"
echo "   仓库: $REPO"
echo "==============================================="

# 1. 下载脚本
echo -e "\n[1/3] 正在下载代理脚本..."
echo "下载地址: $DOWNLOAD_URL"

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$INSTALL_FILE" "$DOWNLOAD_URL"
else
    echo "错误: 未找到 curl 或 wget，无法下载。"
    exit 1
fi

if [ ! -s "$INSTALL_FILE" ]; then
    echo "错误: 下载失败或文件为空，请检查网络或仓库地址。"
    exit 1
fi

chmod +x "$INSTALL_FILE"
echo "下载完成: $INSTALL_FILE"

# 2. 检测 Shell 配置文件
echo -e "\n[2/3] 配置 Shell 环境..."
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    # 默认尝试 .bashrc，如果不存在则尝试 .profile
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -f "$HOME/.profile" ]; then
        SHELL_RC="$HOME/.profile"
    else
        echo "警告: 未找到常见的 Shell 配置文件 (.bashrc/.zshrc)，跳过自动配置。"
    fi
fi

# 3. 写入配置
if [ -n "$SHELL_RC" ]; then
    SOURCE_CMD="source \"$INSTALL_FILE\""
    
    if grep -q "$INSTALL_FILE" "$SHELL_RC"; then
        echo "配置已存在于 $SHELL_RC，跳过写入。"
    else
        echo "" >> "$SHELL_RC"
        echo "# GitHub Smart Proxy (Auto Installed)" >> "$SHELL_RC"
        echo "$SOURCE_CMD" >> "$SHELL_RC"
        echo "已将配置写入 $SHELL_RC"
    fi
    
echo -e "\n[3/3] 安装成功！"
    echo "请执行以下命令使配置立即生效："
    echo -e "\033[32m    source $SHELL_RC\033[0m"
else
    echo -e "\n[3/3] 安装完成（需手动配置）"
    echo "请手动将以下内容添加到你的 shell 配置文件中："
    echo "source \"$INSTALL_FILE\""
fi
