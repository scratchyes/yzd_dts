# Makefile for RK3399-YZD Armbian Integration
# 用于构建RK3399-YZD的Armbian固件

.PHONY: all clean dtb armbian-prep armbian-build help install-deps firmware

# 配置变量
DTS_FILE := rk3399-yzd.dts
DTB_FILE := rk3399-yzd-linux.dtb
ARMBIAN_BUILD_DIR := $(HOME)/armbian-build
BOARD_NAME := rk3399-yzd
RELEASE := bookworm
KERNEL_VERSION := 6.1.y

# 颜色输出
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

# 默认目标
all: help

help:
	@echo "$(GREEN)================================$(NC)"
	@echo "$(GREEN)RK3399-YZD Armbian构建工具$(NC)"
	@echo "$(GREEN)================================$(NC)"
	@echo ""
	@echo "可用命令:"
	@echo "  $(YELLOW)make help$(NC)              - 显示此帮助信息"
	@echo "  $(YELLOW)make dtb$(NC)               - 编译DTS为DTB文件"
	@echo "  $(YELLOW)make install-deps$(NC)      - 安装构建依赖"
	@echo "  $(YELLOW)make armbian-prep$(NC)      - 准备Armbian构建环境"
	@echo "  $(YELLOW)make firmware$(NC)          - 下载AP6356S固件文件"
	@echo "  $(YELLOW)make armbian-build$(NC)     - 编译完整Armbian镜像"
	@echo "  $(YELLOW)make clean$(NC)             - 清理生成文件"
	@echo "  $(YELLOW)make clean-all$(NC)         - 清理所有文件（包括构建目录）"
	@echo ""
	@echo "配置:"
	@echo "  BOARD_NAME      = $(BOARD_NAME)"
	@echo "  RELEASE         = $(RELEASE)"
	@echo "  KERNEL_VERSION  = $(KERNEL_VERSION)"
	@echo ""

# 安装构建依赖
install-deps:
	@echo "$(GREEN)安装构建依赖...$(NC)"
	sudo apt-get update
	sudo apt-get install -y \
		device-tree-compiler \
		git \
		build-essential \
		wget \
		curl
	@echo "$(GREEN)依赖安装完成!$(NC)"

# 编译DTB
dtb: $(DTS_FILE)
	@echo "$(GREEN)编译DTS到DTB...$(NC)"
	@if [ ! -f "$(DTS_FILE)" ]; then \
		echo "错误: $(DTS_FILE) 不存在!"; \
		exit 1; \
	fi
	dtc -I dts -O dtb -o $(DTB_FILE) $(DTS_FILE) 2>&1 | grep -v "Warning" || true
	@if [ -f "$(DTB_FILE)" ]; then \
		echo "$(GREEN)DTB文件生成成功: $(DTB_FILE)$(NC)"; \
		ls -lh $(DTB_FILE); \
	else \
		echo "错误: DTB编译失败!"; \
		exit 1; \
	fi

# 下载AP6356S固件
firmware:
	@echo "$(GREEN)下载AP6356S WiFi/BT固件...$(NC)"
	@mkdir -p firmware/brcm
	@echo "下载 brcmfmac4356-sdio.bin..."
	@wget -q --show-progress -O firmware/brcm/brcmfmac4356-sdio.bin \
		https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.bin || \
		echo "警告: 无法下载 brcmfmac4356-sdio.bin"
	@echo "下载 brcmfmac4356-sdio.txt..."
	@wget -q --show-progress -O firmware/brcm/brcmfmac4356-sdio.txt \
		https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.txt || \
		echo "警告: 无法下载 brcmfmac4356-sdio.txt"
	@echo "下载 brcmfmac4356-sdio.clm_blob..."
	@wget -q --show-progress -O firmware/brcm/brcmfmac4356-sdio.clm_blob \
		https://github.com/armbian/firmware/raw/master/brcm/brcmfmac4356-sdio.clm_blob || \
		echo "警告: 无法下载 clm_blob (可选文件)"
	@echo "$(GREEN)固件下载完成!$(NC)"
	@ls -lh firmware/brcm/

# 准备Armbian构建环境
armbian-prep: dtb
	@echo "$(GREEN)准备Armbian构建环境...$(NC)"
	@if [ ! -d "$(ARMBIAN_BUILD_DIR)" ]; then \
		echo "克隆Armbian构建仓库..."; \
		git clone --depth 1 https://github.com/armbian/build.git $(ARMBIAN_BUILD_DIR); \
	else \
		echo "Armbian构建目录已存在: $(ARMBIAN_BUILD_DIR)"; \
	fi
	@echo "创建板级配置目录..."
	@mkdir -p $(ARMBIAN_BUILD_DIR)/config/boards
	@mkdir -p $(ARMBIAN_BUILD_DIR)/userpatches/overlay
	@mkdir -p $(ARMBIAN_BUILD_DIR)/userpatches/overlay/lib/firmware/brcm
	@echo "复制DTS文件..."
	@cp -v $(DTS_FILE) $(ARMBIAN_BUILD_DIR)/userpatches/overlay/
	@cp -v $(DTB_FILE) $(ARMBIAN_BUILD_DIR)/userpatches/overlay/
	@if [ -d "firmware/brcm" ]; then \
		echo "复制固件文件..."; \
		cp -v firmware/brcm/* $(ARMBIAN_BUILD_DIR)/userpatches/overlay/lib/firmware/brcm/ 2>/dev/null || true; \
	fi
	@echo "创建板级配置文件..."
	@echo '# RK3399-YZD Board Configuration' > $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'BOARD_NAME="RK3399-YZD"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'BOARDFAMILY="rk3399"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'BOARD_MAINTAINER=""' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'BOOTCONFIG="rk3399_defconfig"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'KERNEL_TARGET="current,edge"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'FULL_DESKTOP="yes"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'BOOT_LOGO="desktop"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'BOOT_FDT_FILE="rockchip/rk3399-yzd.dtb"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo 'PACKAGE_LIST_BOARD="wireless-tools wpasupplicant bluez bluez-tools"' >> $(ARMBIAN_BUILD_DIR)/config/boards/$(BOARD_NAME).conf
	@echo "$(GREEN)Armbian构建环境准备完成!$(NC)"
	@echo "构建目录: $(ARMBIAN_BUILD_DIR)"

# 编译Armbian镜像
armbian-build: armbian-prep
	@echo "$(GREEN)开始编译Armbian镜像...$(NC)"
	@echo "配置: BOARD=$(BOARD_NAME) RELEASE=$(RELEASE) KERNEL=$(KERNEL_VERSION)"
	cd $(ARMBIAN_BUILD_DIR) && \
		./compile.sh \
		BOARD=orangepi4-lts \
		BRANCH=current \
		RELEASE=$(RELEASE) \
		BUILD_MINIMAL=no \
		BUILD_DESKTOP=no \
		KERNEL_CONFIGURE=no
	@echo "$(GREEN)Armbian镜像编译完成!$(NC)"
	@echo "输出目录: $(ARMBIAN_BUILD_DIR)/output/images/"
	@ls -lh $(ARMBIAN_BUILD_DIR)/output/images/*.img 2>/dev/null || echo "未找到镜像文件"

# 清理生成文件
clean:
	@echo "$(GREEN)清理生成文件...$(NC)"
	rm -f $(DTB_FILE)
	rm -rf firmware/
	@echo "$(GREEN)清理完成$(NC)"

# 清理所有文件（包括Armbian构建目录）
clean-all: clean
	@echo "$(YELLOW)警告: 这将删除Armbian构建目录!$(NC)"
	@echo -n "确认删除 $(ARMBIAN_BUILD_DIR) ? [y/N] " && read ans && [ $${ans:-N} = y ]
	rm -rf $(ARMBIAN_BUILD_DIR)
	@echo "$(GREEN)全部清理完成$(NC)"

# 快速构建（包含所有步骤）
quick-build: install-deps dtb firmware armbian-prep
	@echo "$(GREEN)================================$(NC)"
	@echo "$(GREEN)快速构建准备完成!$(NC)"
	@echo "$(GREEN)================================$(NC)"
	@echo ""
	@echo "下一步请运行:"
	@echo "  $(YELLOW)make armbian-build$(NC)"
	@echo ""
