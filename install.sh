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
# ding yi VAR
work_dir="$(dirname "$(realpath "$0")")"
nvim_config_dir="${HOME}/.config"
nvim_plugin_dir="${HOME}/.local/share"
nvim_install_dir="${HOME}/.soft"
time_str="$(date +"%F_%H%M%S")"

# source os-release fiele
if [[ -f /etc/os-release ]]; then
	. /etc/os-release
fi

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
		mkdir -p "${nvim_config_dir}"
	fi

	# create nvim plugin dir
	if [[ ! -d "${nvim_plugin_dir}" ]]; then
		mkdir -p "${nvim_plugin_dir}"
	fi

	# create nvim insatll dir
	if [[ ! -d "${nvim_install_dir}" ]]; then
		mkdir -p "${nvim_install_dir}"
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
	if [[ -d "${nvim_install_dir}/nvim-linux64" ]]; then
		rm -rf "${nvim_install_dir:?}/nvim-linux64" >/dev/null 2>&1
		cd "${work_dir}" || exit
		echo -e "\033[1;33mUntaring neovim installeler package....\033[1;32mOK\033[0m"
		tar -xf nvim-installer.tar.gz -C "${nvim_install_dir}"
	else
		cd "${work_dir}" || exit
		echo -e "\033[1;33mUntaring neovim installeler package....\033[1;32mOK\033[0m"
		tar -xf nvim-installer.tar.gz -C "${nvim_install_dir}"
	fi
	echo " "
	sleep 1

	# untar nvim_config file
	if [[ -d "${nvim_config_dir}/nvim" ]]; then
		mv "${nvim_config_dir}/nvim" "${nvim_config_dir}/nvim.bak${time_str}"
		cd "${work_dir}" || exit
		echo -e "\033[1;33mUntaring neovim config file....\033[1;32mOK\033[0m"
		tar -xf nvim-config.tar.gz -C "${nvim_config_dir}"
	else
		cd "${work_dir}" || exit
		echo -e "\033[1;33mUntaring neovim config file....\033[1;32mOK\033[0m"
		tar -xf nvim-config.tar.gz -C "${nvim_config_dir}"
	fi
	echo " "
	sleep 1

	# untar nvim_plugin file
	if [[ -d "${nvim_plugin_dir}/nvim" ]]; then
		mv "${nvim_plugin_dir}/nvim" "${nvim_plugin_dir}/nvim.bak${time_str}"
		cd "${work_dir}" || exit
		echo -e "\033[1;33mUntaring neovim plugin file....\033[1;32mOK\033[0m"
		tar -xf nvim-plugin.tar.gz -C "${nvim_plugin_dir}"
	else
		cd "${work_dir}" || exit
		echo -e "\033[1;33mUntaring neovim plugin file....\033[1;32mOK\033[0m"
		tar -xf nvim-plugin.tar.gz -C "${nvim_plugin_dir}"
	fi
	echo " "
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
		env_file="${HOME}/.zshrc"
		;;
	"bash" | "sh")
		env_file="${HOME}/.bashrc"
		;;
	*)
		echo -e "\033[1;31mError for set env file type. Exitting.....\033[0m"
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

	if [ ! -f "${HOME}/.shellcheckrc" ]; then
		touch "${HOME}/.shellcheckrc"
	fi

	sed -ri '/# 禁用数据流分析防止内存过度占用/d' "${HOME}/.shellcheckrc"
	sed -ri '/extended-analysis=/d' "${HOME}/.shellcheckrc"
	sed -ri '/# 忽略以下代码的语法警告检测/d' "${HOME}/.shellcheckrc"
	sed -ri '/disable=/d' "${HOME}/.shellcheckrc"

	{
		echo "# 禁用数据流分析防止内存过度占用"
		echo "extended-analysis=false"
		echo "# 忽略以下代码的语法警告检测"
		echo "disable=SC2034,SC2043,SC2002,SC2181,SC2126"
	} >>"${HOME:?}/.shellcheckrc"
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
		echo -e "\033[31merror detected!\033[0m installer *tar.gz file NOT FOUND in ${work_dir}"
		echo -e "-------"
		local iterm
		for iterm in "${not_found_installer_package[@]}"; do
			echo "${iterm}"
		done
		echo -e "-------"
		echo -e "\033[35myou can download them from:\033[0m https://github.com/QianSong1/AstroNvim-neovim-install/releases"
		echo -e "\033[34mGood Bye!!!\033[0m"
		print_excuting_msg "Quiting"
		exit 1
	fi
	create_dir
	un_tar_file
	define_shell_env_file
	sed -ri '/# config neovim PATH/d' "${env_file}"
	sed -ri '/n(.*)vim(.*)\/bin/d' "${env_file}"
	echo '# config neovim PATH' >>"${env_file:?}"
	echo "export PATH=\"${nvim_install_dir}/nvim-linux64/bin:\$PATH\"" >>"${env_file:?}"
	export PATH="${nvim_install_dir}/nvim-linux64/bin:$PATH"
	config_shellcheck_rc_file
	sleep 1
	echo -e "\033[1;32mInsatll sucessfully.You can run \033[34mexec ${shell_type} && nvim\033[0m \033[1;32mto start editer!!!\033[0m"
	exit
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
	local cahr_1="${message}."
	local cahr_2="${message}.."
	local cahr_3="${message}..."
	local cahr_4="${message}...."
	local cahr_5="${message}....."
	local i=1
	while [[ "${i}" -le 5 ]]; do
		r_char="\$cahr_${i}"
		msg="$(eval "echo -e \"${r_char}\"")"
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
		echo -e "\033[1;31mUninstalling.....\033[32mOK\033[0m"
		rm -rf "${nvim_install_dir:?}/nvim-linux64" >/dev/null 2>&1
		rm -rf "${nvim_config_dir:?}/nvim"* >/dev/null 2>&1
		rm -rf "${nvim_plugin_dir:?}/nvim"* >/dev/null 2>&1
		rm -rf "${HOME:?}/.cache/nvim"* >/dev/null 2>&1
		rm -rf "${HOME:?}/.local/state/nvim"* >/dev/null 2>&1
		exit
	else
		echo -e "\033[1;33mIt seems you have not install neovim yet, do you want to install?\033[0m [y/N]"
		local you_zl
		read -rp "> " you_zl
		while true; do
			case "${you_zl}" in
			y | yes | Y)
				install_nvim
				;;
			n | no | N)
				echo -e "\033[34mGood Bye!!!\033[0m"
				print_excuting_msg "Quiting"
				exit
				;;
			*)
				echo -e "\033[1;33mIt seems you have not install neovim yet, do you want to install?\033[0m [y/N]"
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
	echo -e "\033[33mPlease selsct one option to work\033[0m"
	echo '---------'
	echo -e "\033[1;33m1.\033[0m Install neovim"
	echo -e "\033[1;33m2.\033[0m UnInstall neovim"
	echo '---------'
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
	echo -e "\033[31m\033[1mAre you sure want exit now? [y/N]:\033[0m "
	echo -n "> "
	local you_zl
	read -r you_zl
	case "${you_zl}" in
	y | Y | yes)
		echo -e "\033[34mGood Bye!!!\033[0m"
		print_excuting_msg "Quiting"
		exit
		;;
	n | N | no)
		select_option
		;;
	*)
		exit_shell
		;;
	esac
}

# 捕获目标信号执行对应操作函数exit_shell
for i in HUP INT QUIT TSTP; do
	trap_cmd="trap \"exit_shell\" ${i}"
	eval "${trap_cmd}"
done

main "$@"
