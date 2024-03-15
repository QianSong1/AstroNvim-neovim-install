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
function define_shell_env_file() {
	shell_type=$(echo "${SHELL}" | awk -F '/' '{print $NF}')
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

# install nvim
function install_nvim() {
	create_dir
	un_tar_file
	define_shell_env_file
	sed -ri '/# config neovim PATH/d' "${env_file}"
	sed -ri '/n(.*)vim(.*)\/bin/d' "${env_file}"
	echo '# config neovim PATH' >>"${env_file:?}"
	echo "export PATH=\"${nvim_install_dir}/nvim-linux64/bin:\$PATH\"" >>"${env_file:?}"
	export PATH="${nvim_install_dir}/nvim-linux64/bin:$PATH"
	sleep 1
	echo -e "\033[1;32mInsatll sucessfully.You can run \033[34mexec ${shell_type} && nvim\033[0m \033[1;32mto start editer!!!\033[0m"
	exit
}

# print excuting msg
function print_excuting_msg() {
	message=$1
	local cahr_1="${message}."
	local cahr_2="${message}.."
	local cahr_3="${message}..."
	local cahr_4="${message}...."
	local cahr_5="${message}....."
	local i=1
	while [[ "${i}" -le 5 ]]; do
		r_char="\$cahr_${i}"
		msg=$(eval "echo -e \"${r_char}\"")
		echo -ne "\033[?25l${msg}\033[0m"
		echo -ne "\r\r"
		i=$((i + 1))
		sleep 0.3
	done
	echo -e "\033[?25h\033[0m"
	echo -e "\033[2A\033[0m"
}

# uninstall nvim
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

# exit SIG capture
function exit_shell() {
	echo
	echo -e "\033[31m\033[1mAre you sure want exit now? [y/N]:\033[0m "
	echo -n "> "
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

select_option
