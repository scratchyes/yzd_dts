#!/bin/bash
#
# Armbian custom extension to enhance apt-get update robustness
# This adds retry logic and cache clearing to handle mirror sync issues
#
# Extension name: apt-retry-extension
#

function extension_prepare_config__apt_retry() {
    display_alert "Loading apt-retry extension" "增强apt-get update可靠性" "info"
}

# Custom function to perform robust apt-get update with retry logic
function robust_chroot_apt_update() {
    display_alert "执行带重试逻辑的apt-get update" "custom function" "info"
    
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        display_alert "尝试apt-get update" "第 ${attempt}/${max_attempts} 次" "info"
        
        # Clean apt cache before retry attempts (skip first attempt)
        if [ $attempt -gt 1 ]; then
            display_alert "清理apt缓存" "attempt ${attempt}" "info"
            if ! run_host_command_logged chroot "${SDCARD}" /bin/bash -c "apt-get clean"; then
                display_alert "apt-get clean失败" "continuing anyway" "wrn"
            fi
            if ! run_host_command_logged chroot "${SDCARD}" /bin/bash -c "rm -rf /var/lib/apt/lists/*"; then
                display_alert "清理/var/lib/apt/lists失败" "continuing anyway" "wrn"
            fi
            # Wait with exponential backoff
            local wait_time=$((attempt * 5))
            display_alert "等待后重试" "${wait_time}秒" "info"
            sleep $wait_time
        fi
        
        # Try apt-get update with error handling flags
        if run_host_command_logged chroot "${SDCARD}" /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get -q -o APT::Update::Error-Mode=any -o Acquire::Retries=1 update"; then
            display_alert "apt-get update成功" "attempt ${attempt}" "info"
            return 0
        fi
        
        display_alert "apt-get update失败" "attempt ${attempt}" "wrn"
        attempt=$((attempt+1))
    done
    
    display_alert "apt-get update在${max_attempts}次尝试后仍然失败" "critical error" "err"
    return 1
}

# Hook to run before installing packages - override apt update
function pre_install_distribution_specific__robust_apt_update() {
    display_alert "应用健壮的apt-get update逻辑" "pre_install hook" "info"
    
    # Call our robust update function
    robust_chroot_apt_update || {
        exit_with_error "无法更新软件包列表，即使重试多次"
    }
}

# Also hook after adding repositories to ensure updates work
function post_repo_apt_update__robust_retry() {
    display_alert "后置仓库更新：使用健壮重试逻辑" "post_repo hook" "info"
    
    # Override the default behavior with our robust implementation
    robust_chroot_apt_update || {
        exit_with_error "添加仓库后无法更新软件包列表"
    }
}

