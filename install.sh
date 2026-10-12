#!/bin/bash
#
#******************************************************************************************
#Author:                QianSong
#QQ:                    xxxxxxxxxx
#Date:                  2023-08-29
#FileName:              install.sh
#URL:                   https://github.com
#Description:           The auto install nvchad nvim script
#Copyright (C):         QianSong 2023 All rights reserved
#******************************************************************************************

# 遵循 Google 编程风格的严格脚本示例

# 开启全局严格模式
set -o errexit
set -o nounset
set -o pipefail

# 定义颜色变量 bold color
bold_hei_color="\033[1;30m"
bold_hong_color="\033[1;31m"
bold_lv_color="\033[1;32m"
bold_huang_color="\033[1;33m"
bold_lan_color="\033[1;34m"
bold_zi_color="\033[1;35m"
bold_tianlan_color="\033[1;36m"
bold_bai_color="\033[1;37m"
bold_normal_color="\033[0m"

# 定义颜色变量 color
hei_color="\033[30m"
hong_color="\033[31m"
lv_color="\033[32m"
huang_color="\033[33m"
lan_color="\033[34m"
zi_color="\033[35m"
tianlan_color="\033[36m"
bai_color="\033[37m"
normal_color="\033[0m"

# 全局变量
work_dir="$(dirname "$(realpath -s "$0")")"
nvim_config_dir=""
nvim_plugin_dir=""
nvim_install_dir=""
time_str="$(date +"%F_%H%M%S")"

#######################################
# 标准危险信息输出
# Globals:
#   none
# Arguments:
#   $*: 传入整条消息
# Outputs:
#   none
# Returns:
#   none
#######################################
function log_danger() {

    echo -e "🈲 ${hong_color}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [DANGER]${normal_color} $*" >&2
}

#######################################
# 标准信息输出
# Globals:
#   none
# Arguments:
#   $*: 传入整条消息
# Outputs:
#   none
# Returns:
#   none
#######################################
function log_info() {

    echo -e "🟢 ${lv_color}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [INFO]${normal_color} $*"
}

#######################################
# 标准错误信息输出
# Globals:
#   none
# Arguments:
#   $*: 传入整条消息
# Outputs:
#   none
# Returns:
#   none
#######################################
function log_error() {

    echo -e "🔴 ${hong_color}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR]${normal_color} $*" >&2
}

#######################################
# 初始化安全家目录，如果家目录 HOME 被篡改，终止执行
# Globals:
#   ${security_home_path}
# Arguments:
#   none
# Outputs:
#   none
# Returns:
#   none
#######################################
function init_security_home_path() {

    # HOME="/home/../etc"

    security_home_path="${HOME:-}"

    if readlink -m "${security_home_path}" >/dev/null 2>&1; then
        security_home_path="$(readlink -m "${security_home_path}")"
        security_home_path="${security_home_path%/}"
    else
        security_home_path=""
    fi

    local real_home_path

    real_home_path="$(getent passwd "${EUID}" | cut -d ":" -f 6)"
    real_home_path="${real_home_path%/}"
    readonly real_home_path

    if [[ -z "${security_home_path}" ]]; then
        log_danger "$0 行${LINENO}: 警告：检测到 HOME 是空值，不允许继续执行。"
        exit 1
    elif [[ "${security_home_path}" != "/root" ]] && [[ "${security_home_path}" != "${real_home_path}" ]]; then
        log_danger "$0 行${LINENO}: 警告：检测到 HOME 被篡改，不允许继续执行。"
        exit 1
    fi

    readonly security_home_path

    # sleep 2000
}

#######################################
# 设置安全安装目录变量
# Globals:
#   {nvim_config_dir} ${nvim_plugin_dir} ${nvim_install_dir}
# Arguments:
#   none
# Outputs:
#   none
# Returns:
#   none
#######################################
function set_nvim_config_global_var() {

    nvim_config_dir="${security_home_path}/.config"
    nvim_plugin_dir="${security_home_path}/.local/share"
    nvim_install_dir="${security_home_path}/.soft"
}

#######################################
# 创建配置、插件、安装目录
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   none
# Returns:
#   none
#######################################
function create_dir() {

    # create nvim config dir
    if [[ ! -d "${nvim_config_dir}" ]]; then
        if is_path_safe "${nvim_config_dir}"; then
            log_info "路径可以安全操作: ${nvim_config_dir}"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_config_dir}"
            exit 1
        fi

        echo "Creating ${nvim_config_dir} ..."
        mkdir -p "${nvim_config_dir}"
    fi

    # create nvim plugin dir
    if [[ ! -d "${nvim_plugin_dir}" ]]; then
        if is_path_safe "${nvim_plugin_dir}"; then
            log_info "路径可以安全操作: ${nvim_plugin_dir}"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_plugin_dir}"
            exit 1
        fi

        echo "Creating ${nvim_plugin_dir} ..."
        mkdir -p "${nvim_plugin_dir}"
    fi

    # create nvim insatll dir
    if [[ ! -d "${nvim_install_dir}" ]]; then
        if is_path_safe "${nvim_install_dir}"; then
            log_info "路径可以安全操作: ${nvim_install_dir}"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_install_dir}"
            exit 1
        fi

        echo "Creating ${nvim_install_dir} ..."
        mkdir -p "${nvim_install_dir}"
    fi
}

#######################################
# 检查路径是否符合安全操作规范 (使用 readlink 规范化)
# Globals:
#   none
# Arguments:
#   $1: 待检查的路径 (支持相对路径、带 .. 的路径等)
# Outputs:
#   none
# Returns:
#   0: 路径安全且规范
#   1: 路径非法或试图越权
#######################################
function is_path_safe() {

    # 定义允许操作的正则模式（必须是规范化后的绝对路径）
    # ^/tmp/.+      : 匹配 /tmp/ 下的文件或子目录
    # ^/var/log/.+  : 匹配 /var/log/ 下的文件或子目录
    # ^${HOME}/.+   : 匹配家目录下的文件或子目录
    local -r allowed_path_regex="^(/tmp/|/var/log/|${security_home_path}/).+"

    local -r input_path_regex="^[\~]"

    local -r input_path_is_contain_space="[[:space:]]"

    local input_path="$1"

    # 1. 参数校验
    if [[ -z "${input_path}" ]]; then
        log_error "$0 行${LINENO}: 错误：未提供路径参数。"
        return 1
    fi

    # 2. 【核心修改】硬性拦截包含空格的路径
    # 使用 Bash 原生正则匹配任何空白字符（空格、制表符等）
    if [[ "${input_path}" =~ ${input_path_is_contain_space} ]]; then
        log_danger "$0 行${LINENO}: 拒绝操作：路径 [${input_path}] 包含空格，出于安全考虑，禁止执行。"
        return 1
    fi

    # 3. 手动处理波浪号 (Tilde Expansion)
    # 即使路径被单引号包裹传入，这里也能将其识别并替换
    if [[ "${input_path}" =~ ${input_path_regex} ]]; then
        # 替换第一个 ~ 为当前用户的 HOME 变量
        input_path="${input_path/\~/${security_home_path}}"
    fi

    # 4. 路径规范化 (Canonicalize)
    # -m 选项：如果路径不存在也处理，解析所有符号链接并消除 ./ 与 ../
    local normalized_path

    if ! normalized_path="$(readlink -m "${input_path}")"; then
        log_error "$0 行${LINENO}: 错误：规范化路径出错。"
        return 1
    fi

    # 5. 空值检查
    if [[ -z "${normalized_path}" ]]; then
        log_error "$0 行${LINENO}: 错误：规范化路径出现空值。"
        return 1
    fi

    # 6. 正则匹配检查
    # 使用规范化后的绝对路径进行对比，彻底杜绝 ../../ 绕过
    # 额外逻辑：readlink -m 会去掉末尾斜杠，正则 .+ 确保了它不是目录本身
    if [[ "${normalized_path}" =~ ${allowed_path_regex} ]]; then
        log_info "允许操作：路径 [${input_path}] (规范化为: ${normalized_path}) 在允许范围。"
        return 0
    else
        log_danger "$0 行${LINENO}: 拒绝操作：路径 [${input_path}] (规范化为: ${normalized_path}) 不在允许范围。"
        return 1
    fi
}

# un tar file in to dir
#######################################
# 解压安装包、插件、配置文件等等
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   输出解压项目的提示信息
# Returns:
#   none
#######################################
function un_tar_file() {

    # untar nvim_install file
    if is_path_safe "${nvim_install_dir}"; then
        log_info "路径可以安全操作: ${nvim_install_dir}"
    else
        log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_install_dir}"
        exit 1
    fi

    if [[ -d "${nvim_install_dir}/nvim-linux64" ]]; then
        rm -rf "${nvim_install_dir:?}/nvim-linux64" >/dev/null 2>&1
        cd "${work_dir}" || exit
        echo -e "${huang_color}Untaring neovim installeler package.... ${lv_color}OK${normal_color}"
        tar --no-same-owner -xf nvim-installer.tar.gz -C "${nvim_install_dir}"
    else
        cd "${work_dir}" || exit
        echo -e "${huang_color}Untaring neovim installeler package.... ${lv_color}OK${normal_color}"
        tar --no-same-owner -xf nvim-installer.tar.gz -C "${nvim_install_dir}"
    fi
    sleep 1

    # untar nvim_config file
    if is_path_safe "${nvim_config_dir}"; then
        log_info "路径可以安全操作: ${nvim_config_dir}"
    else
        log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_config_dir}"
        exit 1
    fi

    if [[ -d "${nvim_config_dir}/nvim" ]]; then
        mv "${nvim_config_dir}/nvim" "${nvim_config_dir}/nvim.bak${time_str}"
        cd "${work_dir}" || exit
        echo -e "${huang_color}Untaring neovim config file.... ${lv_color}OK${normal_color}"
        tar --no-same-owner -xf nvim-config.tar.gz -C "${nvim_config_dir}"
    else
        cd "${work_dir}" || exit
        echo -e "${huang_color}Untaring neovim config file.... ${lv_color}OK${normal_color}"
        tar --no-same-owner -xf nvim-config.tar.gz -C "${nvim_config_dir}"
    fi
    sleep 1

    # untar nvim_plugin file
    if is_path_safe "${nvim_plugin_dir}"; then
        log_info "路径可以安全操作: ${nvim_plugin_dir}"
    else
        log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_plugin_dir}"
        exit 1
    fi

    if [[ -d "${nvim_plugin_dir}/nvim" ]]; then
        mv "${nvim_plugin_dir}/nvim" "${nvim_plugin_dir}/nvim.bak${time_str}"
        cd "${work_dir}" || exit
        echo -e "${huang_color}Untaring neovim plugin file.... ${lv_color}OK${normal_color}"
        tar --no-same-owner -xf nvim-plugin.tar.gz -C "${nvim_plugin_dir}"
    else
        cd "${work_dir}" || exit
        echo -e "${huang_color}Untaring neovim plugin file.... ${lv_color}OK${normal_color}"
        tar --no-same-owner -xf nvim-plugin.tar.gz -C "${nvim_plugin_dir}"
    fi
    sleep 1
}

# define shell env fire VAR
#######################################
# 确认用户使用的登录shell类型，获取该shell配置文件
# Globals:
#   ${env_file}、${shell_type}、
# Arguments:
#   none
# Outputs:
#   如果获取失败，将输出错误提示并退出脚本
# Returns:
#   none
#######################################
function define_shell_env_file() {

    shell_type="$(echo "${SHELL}" | awk -F '/' '{print $NF}')"

    case "${shell_type}" in
    "zsh")
        env_file="${security_home_path}/.zshrc"
        ;;
    "bash" | "sh")
        env_file="${security_home_path}/.bashrc"
        ;;
    *)
        echo -e "$0 行${LINENO}: ${hong_color}Error for set env file type. Exitting.....${normal_color}"
        exit 1
        ;;
    esac
}

# create shellcheck config file
#######################################
# 生成shellcheck配置文件
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   none
# Returns:
#   none
#######################################
function config_shellcheck_rc_file() {

    if is_path_safe "${security_home_path}/.shellcheckrc"; then
        log_info "路径可以安全操作: ${security_home_path}/.shellcheckrc"
    else
        log_error "$0 行${LINENO}: 路径不可以安全操作: ${security_home_path}/.shellcheckrc"
        exit 1
    fi

    echo "Creating ${security_home_path}/.shellcheckrc file ..."

    rm -f "${security_home_path:?}/.shellcheckrc" >/dev/null 2>&1

    if [ ! -f "${security_home_path}/.shellcheckrc" ]; then
        touch "${security_home_path}/.shellcheckrc"
    fi

    {
        echo "# 禁用数据流分析防止内存过度占用"
        echo "extended-analysis=false"
        echo "# 忽略以下代码的语法警告检测"
        echo "disable=SC2034,SC2043,SC2002,SC2181,SC2126"
    } >>"${security_home_path:?}/.shellcheckrc"
}

# check if installer tar.gz files exist
#######################################
# 检测安装包、插件包、配置包是否存在于工作目录
# Globals:
#   ${not_found_installer_package[@]}、
# Arguments:
#   none
# Outputs:
#   none
# Returns:
#   0 或 1，0表示包存在，1表示至少有一个包不存在
#######################################
function check_installer_tar_gz_files_exist() {

    local installer_package=()
    local iterm

    for iterm in "nvim-config.tar.gz" "nvim-plugin.tar.gz" "nvim-installer.tar.gz"; do
        installer_package+=("${iterm}")
    done

    not_found_installer_package=()
    local package

    for package in "${installer_package[@]}"; do
        if [ ! -f "${work_dir}/${package}" ]; then
            not_found_installer_package+=("${package}")
        fi
    done

    if [ "${#not_found_installer_package[@]}" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# install nvim
#######################################
# 安装neovim函数
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   安装成功输出成功信息，反之输出失败信息
# Returns:
#   none
#######################################
function install_nvim() {

    if check_installer_tar_gz_files_exist; then
        true
    else
        echo -e "${hong_color}Error detected!${normal_color} installer *tar.gz file NOT FOUND in ${work_dir}"
        echo -e "-------"

        local iterm

        for iterm in "${not_found_installer_package[@]}"; do
            echo "${iterm}"
        done

        echo -e "-------"
        echo -e "${zi_color}You can download them from:${normal_color} https://github.com/QianSong1/AstroNvim-neovim-install/releases"
        echo -e "${tianlan_color}Good Bye!!!${normal_color}"
        print_excuting_msg "Quiting"
        exit 1
    fi

    create_dir
    un_tar_file
    define_shell_env_file

    if is_path_safe "${env_file}"; then
        log_info "路径可以安全操作: ${env_file}"
    else
        log_error "$0 行${LINENO}: 路径不可以安全操作: ${env_file}"
        exit 1
    fi

    echo "Setting nvim PATH ..."

    sed -ri '/# config neovim PATH/d' "${env_file:?}"
    sed -ri '/n(.*)vim(.*)\/bin/d' "${env_file:?}"

    echo '# config neovim PATH' >>"${env_file:?}"
    echo "export PATH=\"${nvim_install_dir}/nvim-linux64/bin:\$PATH\"" >>"${env_file:?}"

    config_shellcheck_rc_file
    sleep 1

    echo -e "${bold_lv_color}Insatll sucessfully.You can run ${tianlan_color}exec ${shell_type} && nvim ${bold_lv_color}to start editer!!!${normal_color}"
    exit 0
}

# print excuting msg
#######################################
# 打印一个信息输出动画，如退出消息.....
# Globals:
#   none
# Arguments:
#   传入一个字符串类型消息参数
# Outputs:
#   输出一个处理消息动画
# Returns:
#   none
#######################################
function print_excuting_msg() {

    local msg
    local message="$1"
    local msg_1="${message}."
    local msg_2="${message}.."
    local msg_3="${message}..."
    local msg_4="${message}...."
    local msg_5="${message}....."

    local i=1

    while [[ "${i}" -le 5 ]]; do
        msg="\${msg_${i}}"
        msg="$(eval "echo \"${msg}\"")"
        echo -ne "\033[?25l${msg}\033[0m"
        echo -ne "\r\r"
        i=$((i + 1))
        sleep 0.3
    done

    echo -e "\033[?25h\033[0m"
    echo -e "\033[2A\033[0m"
}

# uninstall nvim
#######################################
# 卸载neovim
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   输出卸载的结果与提示等等
# Returns:
#   none
#######################################
function uninstall_nvim() {

    if [[ -d "${nvim_install_dir}/nvim-linux64" ]]; then
        print_excuting_msg "Uninstalling"

        if is_path_safe "${nvim_install_dir}/nvim-linux64"; then
            log_info "路径可以安全操作: ${nvim_install_dir}/nvim-linux64"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_install_dir}/nvim-linux64"
            exit 1
        fi
        echo "Removing ${nvim_install_dir}/nvim-linux64 ..."
        rm -rf "${nvim_install_dir:?}/nvim-linux64" >/dev/null 2>&1

        if is_path_safe "${nvim_config_dir}/nvim"; then
            log_info "路径可以安全操作: ${nvim_config_dir}/nvim"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_config_dir}/nvim"
            exit 1
        fi
        echo "Removing ${nvim_config_dir}/nvim ..."
        rm -rf "${nvim_config_dir:?}/nvim"* >/dev/null 2>&1

        if is_path_safe "${nvim_plugin_dir}/nvim"; then
            log_info "路径可以安全操作: ${nvim_plugin_dir}/nvim"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${nvim_plugin_dir}/nvim"
            exit 1
        fi
        echo "Removing ${nvim_plugin_dir}/nvim ..."
        rm -rf "${nvim_plugin_dir:?}/nvim"* >/dev/null 2>&1

        if is_path_safe "${security_home_path}/.cache/nvim"; then
            log_info "路径可以安全操作: ${security_home_path}/.cache/nvim"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${security_home_path}/.cache/nvim"
            exit 1
        fi
        echo "Removing ${security_home_path}/.cache/nvim ..."
        rm -rf "${security_home_path:?}/.cache/nvim"* >/dev/null 2>&1

        if is_path_safe "${security_home_path}/.local/state/nvim"; then
            log_info "路径可以安全操作: ${security_home_path}/.local/state/nvim"
        else
            log_error "$0 行${LINENO}: 路径不可以安全操作: ${security_home_path}/.local/state/nvim"
            exit 1
        fi
        echo "Removing ${security_home_path}/.local/state/nvim ..."
        rm -rf "${security_home_path:?}/.local/state/nvim"* >/dev/null 2>&1

        echo -e "${lv_color}Uninstalling..... OK${normal_color}"
        exit 0
    else
        echo -e "${huang_color}It seems you have not install neovim yet, do you want to install?${normal_color} [y/N]"

        local you_zl
        read -rp "> " you_zl

        while true; do
            case "${you_zl^^}" in
            Y | YES)
                install_nvim
                ;;
            N | NO)
                echo -e "${lv_color}Good Bye!!!${normal_color}"
                print_excuting_msg "Quiting"
                exit 0
                ;;
            *)
                echo -e "${hong_color}Invalid...${normal_color}"
                read -rp "> " you_zl
                ;;
            esac
        done
    fi
}

# menu
#######################################
# 安装选项菜单
# Globals:
#   ${you_zl}、
# Arguments:
#   none
# Outputs:
#   一个菜单界面
# Returns:
#   none
#######################################
function select_menu() {

    echo -e "${huang_color}Please selsct one option to work${normal_color}"
    echo -e "---------"
    echo -e "📦 ${bold_lv_color}1.${normal_color} Install neovim"
    echo -e "🧻 ${bold_hong_color}2.${normal_color} UnInstall neovim"
    echo -e "---------"
    echo
    read -rp "> " you_zl
}

# select install or uninstall_nvim
#######################################
# 菜单选择函数，选择一个选项工作
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   none
# Returns:
#   none
#######################################
function select_option() {

    clear
    select_menu

    case "${you_zl}" in
    1)
        install_nvim
        ;;
    2)
        uninstall_nvim
        ;;
    *)
        select_option
        ;;
    esac
}

#######################################
# 打印工具安装状态并检查依赖。
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   none
# Returns:
#   0 如果所有工具都已安装
#   1 如果有任何工具缺失
#######################################
function check_dependencies() {

    local -a required_tools=("tar" "readlink" "getent")
    local tool
    local has_missing=0
    local status_msg
    local dot_padding="........................"

    echo "正在检查系统依赖状态:"

    for tool in "${required_tools[@]}"; do
        # 使用 printf 实现固定宽度的对齐效果
        # %-12s 表示左对齐，占用 12 个字符
        if command -v "${tool}" >/dev/null 2>&1; then
            status_msg="OK"
            printf "  - %s %s [%b%s%b]\n" \
                "${tool}" \
                "${dot_padding:${#tool}}" \
                "${lv_color}" \
                "${status_msg}" \
                "${normal_color}"
            sleep 0.5
        else
            status_msg="MISSING"
            printf "  - %s %s [%b%s%b]\n" \
                "${tool}" \
                "${dot_padding:${#tool}}" \
                "${hong_color}" \
                "${status_msg}" \
                "${normal_color}"
            sleep 0.5
            has_missing=1
        fi
    done

    if [[ "${has_missing}" -eq 1 ]]; then
        return 1
    fi

    return 0
}

#######################################
# 主函数main，程序的入口
# Globals:
#   none
# Arguments:
#   "$@"
# Outputs:
#   none
# Returns:
#   none
#######################################
function main() {

    # source os-release fiele
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
    fi

    local current_os
    current_os="${ID:-unknowos}"

    case "${current_os}" in
    almalinux | rocky | centos)
        echo -e "${lv_color}检测到 RHEL 系：${bai_color}${current_os}，${lv_color}该操作系统支持本安装程序...${normal_color}"
        sleep 1
        echo
        ;;
    ubuntu | debian | kali)
        echo -e "${lv_color}检测到 Debian 系：${bai_color}${current_os}，${lv_color}该操作系统支持本安装程序...${normal_color}"
        sleep 1
        echo
        ;;
    *)
        log_error "$0 行${LINENO}: 不支持的发行版: ${current_os}，请手动折腾安装AstroNvim..."
        print_excuting_msg "操作终止"
        echo
        exit 1
        ;;
    esac

    if ! check_dependencies; then
        echo
        log_error "$0 行${LINENO}: 错误: 缺少必要的系统工具，请安装后再试..."
        echo
        exit 1
    else
        echo
        log_info "所有依赖检查通过..."
        echo
        print_excuting_msg "进入安装菜单"
        sleep 3
    fi

    init_security_home_path
    set_nvim_config_global_var
    select_option
}

# exit SIG capture
#######################################
# 信号捕捉处理函数，捕捉用户信号作出响应，退出yes|no
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   输出询问，是否需要退出脚本
# Returns:
#   none
#######################################
function exit_shell() {

    echo
    echo -e "${hong_color}Are you sure want exit now?${normal_color} [y/N]"

    local you_zl
    read -rp "> " you_zl

    while true; do
        case "${you_zl^^}" in
        Y | YES)
            echo -e "${tianlan_color}Good Bye!!!${normal_color}"
            print_excuting_msg "Quiting"
            exit 0
            ;;
        N | NO)
            select_option
            ;;
        *)
            exit_shell
            ;;
        esac
    done
}

# 捕获目标信号执行对应操作函数exit_shell
for i in HUP INT QUIT TSTP; do
    trap_cmd="trap \"exit_shell\" ${i}"
    eval "${trap_cmd}"
done

main "$@"
