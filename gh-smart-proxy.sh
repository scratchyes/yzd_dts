#!/bin/bash

# =================配置区域=================
# 1. 优先级最高的镜像 (HK)
PRIMARY_MIRROR="https://hk.gh-proxy.org/"

# 2. 优先级次高的镜像 (EdgeOne)
SECONDARY_MIRROR="https://edgeone.gh-proxy.org/"

# 3. 备选池（参与实时测速竞争）
BACKUP_MIRRORS=(
    "https://gh-proxy.org/"
    "https://v6.gh-proxy.org/"
    "https://cdn.gh-proxy.org/"
)
# =========================================

# 测速函数：返回延迟最低的镜像地址
function _get_fastest_mirror() {
    local fastest_time=1000000
    local best_mirror=""
    
    # 静默测速，不输出干扰信息
    for mirror in "${BACKUP_MIRRORS[@]}"; do
        local domain=$(echo "$mirror" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
        local ping_res=$(ping -c 1 -W 1 "$domain" 2>/dev/null | grep 'time=' | head -1)
        
        if [ -n "$ping_res" ]; then
            local time_ms=$(echo "$ping_res" | sed -E 's/.*time=([0-9.]+).*/\1/')
            local time_int=${time_ms%.*}
            if [ "$time_int" -lt "$fastest_time" ]; then
                fastest_time=$time_int
                best_mirror="$mirror"
            fi
        fi
    done

    echo "$best_mirror"
}

# 核心重试逻辑
function _try_gh_smart_proxy() {
    local cmd_type="$1"
    local original_url="$2"
    shift 2
    local args=("$@")

    local attempt_list=("$PRIMARY_MIRROR" "$SECONDARY_MIRROR")

    # === 优化：直连检测 (防刷屏 + 超时) ===
    echo -ne "\033[33m[AutoProxy] 直连测试 (3s超时)... \033[0m"
    
    # 使用 curl 测试 github.com 连通性，最大3秒
    local direct_success=0
    if command -v curl >/dev/null 2>&1; then
        if curl -s -I -m 3 https://github.com >/dev/null 2>&1; then
            direct_success=1
        fi
    else
        # 备选 wget 测试
        if wget -q --spider --timeout=3 https://github.com >/dev/null 2>&1; then
            direct_success=1
        fi
    fi

    if [ $direct_success -eq 1 ]; then
        echo -e "\033[32m[通畅]\033[0m"
        # 尝试��连
        command "$cmd_type" "${args[@]}"
        local res=$?
        if [ $res -eq 0 ]; then
            return 0
        fi
        echo -e "\n\033[31m[直连中断] 错误码: $res，切换加速镜像...\033[0m"
    else
        echo -e "\033[31m[超时/失败] 自动切换\033[0m"
    fi

    # === 智能代理逻辑 ===
    
    # 2. 尝试固定高优节点
    for mirror in "${attempt_list[@]}"; do
        _exec_proxy_cmd "$cmd_type" "$mirror" "$original_url" "${args[@]}"
        if [ $? -eq 0 ]; then return 0; fi
    done

    # 3. 测速备用节点
    echo -e "\033[33m[AutoProxy] 主力节点连接超时，正在测速寻找最快备点...\033[0m"
    local best_backup=$(_get_fastest_mirror)
    
    if [ -n "$best_backup" ]; then
        echo -e "\033[32m[AutoProxy] 选中最优节点: $best_backup\033[0m"
        _exec_proxy_cmd "$cmd_type" "$best_backup" "$original_url" "${args[@]}"
        if [ $? -eq 0 ]; then return 0; fi
    fi

    echo -e "\033[31m[AutoProxy] 所有镜像均无法连接。\033[0m"
    return 1
}

function _exec_proxy_cmd() {
    local cmd_type="$1"
    local mirror="$2"
    local original_url="$3"
    shift 3
    local args=("$@")
    
    local proxy_url="${mirror}${original_url}"
    
    # 替换参数中的 URL
    local new_args=("${args[@]}")
    for i in "${!new_args[@]}"; do
        if [[ "${new_args[$i]}" == "$original_url" ]]; then
            new_args[$i]="$proxy_url"
        fi
    done
    
    echo -e "\033[34m[尝试镜像] $mirror ...\033[0m"

    if [ "$cmd_type" == "git" ]; then
        command git "${new_args[@]}"
        local res=$?
        if [ $res -eq 0 ]; then
            local repo_name=$(basename "$original_url" .git)
            if [ -d "$repo_name" ]; then
                (cd "$repo_name" && command git remote set-url origin "$original_url")
            fi
            return 0
        fi
    elif [ "$cmd_type" == "wget" ]; then
        command wget "${new_args[@]}"
        return $?
    fi
    return 1
}

# 劫持 git
function git() {
    local is_clone=0
    local target_url=""
    if [[ "$1" == "clone" ]]; then
        for arg in "$@"; do
            if [[ "$arg" == https://github.com/* ]]; then
                is_clone=1
                target_url="$arg"
                break
            fi
        done
    fi

    if [[ $is_clone -eq 1 ]]; then
        _try_gh_smart_proxy "git" "$target_url" "$@"
    else
        command git "$@"
    fi
}

# 劫持 wget
function wget() {
    local target_url=""
    for arg in "$@"; do
        if [[ "$arg" == https://github.com/* ]]; then
            target_url="$arg"
            break
        fi
    done

    if [[ -n "$target_url" ]]; then
        _try_gh_smart_proxy "wget" "$target_url" "$@"
    else
        command wget "$@"
    fi
}