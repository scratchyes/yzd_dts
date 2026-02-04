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
    
    echo -e "\033[36m[智能测速] 正在测试备选节点延迟...\033[0m" >&2

    for mirror in "${BACKUP_MIRRORS[@]}"; do
        # 提取域名进行 ping 测试 (去除 https:// 和 /)
        local domain=$(echo "$mirror" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
        
        # 使用 ping 发送 1 个包，超时 1 秒
        local ping_res=$(ping -c 1 -W 1 "$domain" 2>/dev/null | grep 'time=' | head -1)
        
        if [ -n "$ping_res" ]; then
            # 提取时间 (ms)
            local time_ms=$(echo "$ping_res" | sed -E 's/.*time=([0-9.]+).*/\1/')
            # 转换为整数方便比较
            local time_int=${time_ms%.*}
            
            echo -e "  - $domain: ${time_ms}ms" >&2
            
            if [ "$time_int" -lt "$fastest_time" ]; then
                fastest_time=$time_int
                best_mirror="$mirror"
            fi
        else
            echo -e "  - $domain: 超时/不可达" >&2
        fi
    done

    if [ -n "$best_mirror" ]; then
        echo "$best_mirror"
    else
        echo ""
    fi
}

# 核心重试逻辑
function _try_gh_smart_proxy() {
    local cmd_type="$1"
    local original_url="$2"
    shift 2
    local args=("$@")

    # 定义尝试顺序的数组
    local attempt_list=("$PRIMARY_MIRROR" "$SECONDARY_MIRROR")

    # 1. 尝试直连
    echo -e "\033[33m[尝试直连] $original_url ...\033[0m"
    if [ "$cmd_type" == "git" ]; then
        git "${args[@]}" && return 0
    elif [ "$cmd_type" == "wget" ]; then
        wget "${args[@]}" && return 0
    fi

    echo -e "\033[31m[直连失败] 进入智能代理模式...\033[0m"

    # 2. 尝试 HK 和 EdgeOne
    for mirror in "${attempt_list[@]}"; do
        _exec_proxy_cmd "$cmd_type" "$mirror" "$original_url" "${args[@]}"
        if [ $? -eq 0 ]; then return 0; fi
    done

    # 3. 如果前面都失败，进行测速，选一个最快的
    echo -e "\033[35m[主力节点失败] 启动备选节点测速...\033[0m"
    local best_backup=$(_get_fastest_mirror)
    
    if [ -n "$best_backup" ]; then
        echo -e "\033[32m[测速胜出] 选中: $best_backup\033[0m"
        _exec_proxy_cmd "$cmd_type" "$best_backup" "$original_url" "${args[@]}"
        if [ $? -eq 0 ]; then return 0; fi
    else
        echo -e "\033[31m[错误] 所有备选节点均不可达\033[0m"
    fi

    return 1
}

# 执行代理命令的辅助函数
function _exec_proxy_cmd() {
    local cmd_type="$1"
    local mirror="$2"
    local original_url="$3"
    shift 3
    local args=("$@")
    
    local proxy_url="${mirror}${original_url}"
    echo -e "\033[34m[尝试镜像] $mirror ...\033[0m"

    local new_args=("${args[@]}")
    # 替换参数中的 URL
    for i in "${!new_args[@]}"; do
        if [[ "${new_args[$i]}" == "$original_url" ]]; then
            new_args[$i]="$proxy_url"
        fi
    done

    if [ "$cmd_type" == "git" ]; then
        git "${new_args[@]}"
        local res=$?
        if [ $res -eq 0 ]; then
            # 成功后还原 remote
            local repo_name=$(basename "$original_url" .git)
            if [ -d "$repo_name" ]; then
                echo -e "\033[32m[系统] 还原 git remote 为原始地址...\033[0m"
                (cd "$repo_name" && git remote set-url origin "$original_url")
            fi
            return 0
        fi
    elif [ "$cmd_type" == "wget" ]; then
        wget "${new_args[@]}"
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