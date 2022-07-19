#!/bin/bash
# Project	AutoBuild
# Author	Hyy2001
# Github	https://github.com/Hyy2001X/AutoBuild

Update=2022.07.19
Version=V4.4.6

Second_Menu() {
	Project=$1
	Build_Path=${Home}/Projects/$1
	[[ ! -s ${Build_Path}/Makefile ]] && Sources_Download

	while :
	do
		clear
		if [[ -s ${Build_Path}/Makefile ]]
		then
			cd ${Build_Path}
			ECHO G "源码位置: ${Build_Path}:$(GET_Branch ${Build_Path})"
			Version=$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" package/lean/default-settings/files/zzz-default-settings 2> /dev/null)
			[[ -n ${Version} ]] && ECHO "源码版本: ${Version}"
			unset Version
			if [[ -s ${Home}/Configs/${Project}_Recently_Updated ]]
			then
				ECHO "最近更新: $(cat ${Home}/Configs/${Project}_Recently_Updated)"
			fi
		else
			return
		fi
		echo
		echo "1. 更新源代码"
		echo "2. 打开固件配置菜单"
		echo "3. 备份与恢复"
		echo "4. 编译选项"
		echo "5. 高级选项"
		ECHO X "\nm. 主菜单"
		echo "q. 返回"
		GET_Choose Choose
		case ${Choose} in
		q)
			AutoBuild_Second
		;;
		m)
			AutoBuild_Core
		;;
		1)
			Sources_Update common ${Project}
		;;
		2)
			Menuconfig $(pwd)
		;;
		3)
			BackupServices
		;;
		4)
			Module_Builder
		;;
		5)
			Project_Options
		esac
	done
}

Project_Options() {
	while :;do
		cd ${Build_Path}
		clear
		ECHO X "源码高级选项\n"
		echo "1. 下载源代码"
		echo "2. 强制更新源代码"
		ECHO Y "3. 添加主题包"
		ECHO X "4. 添加软件包"
		echo "5. 空间清理"
		echo "6. 下载公共源码库"
		echo "7. 源代码更新日志"
		ECHO X "\nm. 主菜单"
		echo "q. 返回"
		GET_Choose Choose
		case ${Choose} in
		q)
			break
		;;
		m)
			AutoBuild_Core
		;;
		1)
			Sources_Download
		;;
		2)
			Sources_Update force ${Project}
		;;
		3)
			ExtraThemes
		;;
		4)
			ExtraPackages
		;;
		5)
			Space_Cleaner
		;;
		6)
			Make_Download
		;;
		7)
			clear
			if [[ -d .git ]]
			then
				git log -20 --graph --all --branches --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%cr)%C(reset) %C(bold green)(%ai)%C(reset) %C(white)%s'
				Enter
			fi
		;;
		esac
	done
}

BackupServices() {
	while :
	do
		clear
		ECHO X "备份与恢复\n"
		echo "1. 备份 [.config]"
		echo "2. 恢复 [.config]"
		echo "3. 备份 [${Project}] 源码"
		echo "4. 恢复 [${Project}] 源码"
		ECHO X "5. 链接 [dl]库"
		echo -e "\nq. 返回"
		GET_Choose Choose
		case ${Choose} in
		q)
			break
		;;
		1)
			cd ${Build_Path}
			while :;do
				clear
				ECHO X "备份 [.config]\n"
				echo -e "1. 固定名称"
				echo "2. 自定义名称"
				echo -e "\nq. 返回"
				GET_Choose Choose
				case ${Choose} in
				q)
					break
				;;
				1)
					if [ -f .config ]
					then
						cp .config ${Home}/Backups/Configs/Config_${Project}_$(date +%Y%m%d-%H%M%S)
						ECHO Y "\n[.config] 备份成功!"
					else
						ECHO R "\n[.config] 备份失败!"
					fi
				;;
				2)
					read -p '请输入自定义名称:' Backup_Config
					if [ -f .config ]
					then
						cp .config ${Home}/Backups/Configs/"${Backup_Config}"
						ECHO Y "\n[.config] 备份成功"
					else
						ECHO R "\n[.config] 备份失败!"
					fi
				;;
				esac
				sleep 2
			done
		;;
		2)
			if [[ -n $(ls -A ${Home}/Backups/Configs) ]]
			then
				while :;do
					clear
					ECHO X "恢复 [.config]\n"
					cd ${Home}/Backups/Configs
					ls -A | cat > ${Cache_Path}/Config.List
					ConfigList_File=${Cache_Path}/Config.List
					Max_ConfigList_Line=$(sed -n '$=' ${ConfigList_File})
					for ((i=1;i<=${Max_ConfigList_Line};i++));
					do
						ConfigFile_Name=$(sed -n ${i}p $ConfigList_File)
						echo -e "${i}. ${Yellow}${ConfigFile_Name}${White}"
					done
					echo -e "\nq.返回"
					GET_Choose Choose
					case ${Choose} in
					q)
						break
					;;
					*)
						if [[ ${Choose} -le ${Max_ConfigList_Line} ]] 2> /dev/null
						then
							if [[ ! ${Choose} == 0 ]] 2> /dev/null
							then
								ConfigFile=$(sed -n ${Choose}p $ConfigList_File)
								if [[ -f ${ConfigFile} ]]
								then
									ConfigFile_Dir="${Home}/Backups/Configs/$ConfigFile"
									cp "${ConfigFile_Dir}" ${Build_Path}/.config
									echo "${ConfigFile}" > ${Home}/Configs/${Project}_Recently_Config
									ECHO Y "\n配置文件 [$ConfigFile] 恢复成功!"
									sleep 2
								else
									ECHO R "\n未检测到对应的配置文件!"
									sleep 2
								fi
							else
								ECHO R "\n输入错误,请输入正确的数字!"
								sleep 2
							fi
						else
							ECHO R "\n输入错误,请输入正确的数字!"
							sleep 2
						fi
					;;
					esac
				done
			else
				ECHO R "\n未找到备份文件,恢复失败!"
				sleep 2
			fi
		;;
		3)
			ECHO X "\n正在备份 [${Project}] 源码,请稍后 ..."
			[[ ! -d ${Home}/Backups/Projects/${Project} ]] && mkdir -p ${Home}/Backups/Projects/${Project}
			rm -rf ${Home}/Backups/Projects/${Project}/*
			for X in $(echo ${Backup_List[@]})
			do
				cp -a ${Build_Path}/${X} ${Home}/Backups/Projects/${Project}
			done
			unset X
			ECHO Y "\n备份成功!源码已备份到 'Backups/Projects/${Project}'"
			ECHO Y "\n存储占用:$(du -sh ${Home}/Backups/Projects/${Project} | awk '{print $1}')B"
			sleep 3
		;;
		4)
			if [[ -f ${Home}/Backups/Projects/${Project}/Makefile ]]
			then
				ECHO X "\n正在恢复 [${Project}] 源码,请稍后 ..."
				for X in $(echo ${Backup_List[@]})
				do
					rm -rf ${Home}/Projects/${X}
					cp -a ${Home}/Backups/Projects/${Project}/${X} ${Home}/Projects/${Projects}/${X} > /dev/null 2>&1
				done
				ECHO Y "\n恢复成功!源码文件已恢复到 'Projects/${Project}'"
				sleep 3
			else
				ECHO R "\n未找到备份文件!"
				sleep 2
			fi
		;;
		5)
			if [[ ! -h ${Build_Path}/dl ]]
			then
				[[ -d ${Build_Path}/dl ]] && mv -f ${Build_Path}/dl/* ${Home}/Backups/dl
				rm -rf ${Build_Path}/dl
				ln -s ${Home}/Backups/dl ${Build_Path}/dl
			fi
			ECHO Y "\n已创建软链接:'${Home}/Backups/dl' -> '${Build_Path}/dl'"
			sleep 3
		;;
		esac
	done
}

Advanced_Options() {
	while :
	do
		clear
		ECHO X "高级选项\n"
		ECHO "1. 更新系统软件包"
		ECHO X "2. 安装编译环境"
		echo "3. SSH 服务"
		echo "4. 同步网络时间"
		echo "5. 快捷指令启动"
		echo "6. 系统信息"
		echo "7. 系统下载源"
		ECHO "\nx. 更新脚本"
		ECHO X "q. 主菜单"
		GET_Choose Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			Module_Updater
		;;
		1)
			clear
			$(command -v sudo) apt-get -y update
			$(command -v sudo) apt-get -y upgrade
			$(command -v sudo) apt-get -y clean
			Enter
		;;
		2)
			echo
			read -p "是否启用单个软件包安装?[Y/n]:" if_Single
			clear
			$(command -v sudo) apt-get -y update
			local i=1;while [[ $i -le 3 ]];do
				clear
				ECHO X "开始第 $i 次安装...\n"
				sleep 2
				if [[ ${if_Single} == [Yy] ]]
				then
					for X in ${Dependency[@]} ${Extra_Dependency[@]};do
						$(command -v sudo) apt-get -y install ${X} > /dev/null 2>&1
						if [[ $? == 0 ]]
						then
							ECHO Y "已成功安装: ${X}"
						else
							ECHO R "未成功安装: ${X}"
						fi
					done
				else
					$(command -v sudo) apt-get -y install ${Dependency[@]}
					$(command -v sudo) apt-get -y install ${Extra_Dependency[@]}
				fi
				i=$(($i + 1))
				sleep 1
			done
			unset i X
			$(command -v sudo) apt-get clean
			Enter
		;;
		3)
			Module_SSHServices
		;;
		4)
			echo
			$(command -v sudo) ntpdate ntp1.aliyun.com
			$(command -v sudo) hwclock --systohc
			sleep 2
		;;
		5)
			echo
			read -p '请输入快速启动的指令:' FastOpen
			_SHELL=$(basename $(echo $SHELL))
			for i in $(echo ~/.${_SHELL}rc /etc/profile);do
				if [[ -r $i ]]
				then
					ECHO B "\n写入到文件: [$i] ..."
					$(command -v sudo) sed -i "/AutoBuild.sh/d" ~/.bashrc
					$(command -v sudo) echo "alias ${FastOpen}='${Home}/AutoBuild.sh'" >> ~/.bashrc
					if [[ $? == 0 ]]
					then
						FastOpen_result=true
					else
						continue
					fi
					break
				fi
			done
			if [[ ${FastOpen_result} == true ]]
			then
				ECHO Y "\n创建成功!下次登录在终端输入 ${FastOpen} 即可启动 AutoBuild."
			else
				ECHO R "\n创建失败!请检查相关权限设置!"
			fi
			sleep 3
		;;
		6)
			Module_Systeminfo
		;;
		7)
			Module_SourcesList
		;;
		esac
	done
}

Space_Cleaner() {
	while :
	do
		clear
		ECHO X "空间清理\n"
		echo "1. 执行 [make clean]"
		echo "2. 执行 [make dirclean]"
		echo "3. 执行 [make distclean]"
		echo "4. 清理 [临时文件/编译缓存]"
		echo "5. 清理 [更新日志]"
		echo "6. 清理 [编译日志]"
		ECHO G "7. 删除 [${Project}] 源码"
		echo "q. 返回"
		GET_Choose Choose
		cd ${Build_Path}
		case ${Choose} in
		q)
			break
		;;
		1)
			ECHO X "\n正在执行 [make clean],请稍后 ..."
			make clean > /dev/null 2>&1
		;;
		2)
			ECHO X "\n正在执行 [make dirclean],请稍后 ..."
			make dirclean > /dev/null 2>&1
		;;
		3)
			ECHO X "\n正在执行 [make distclean],请稍后 ..."
			make distclean > /dev/null 2>&1
		;;
		4)
			rm -rf ${Build_Path}/tmp
			ECHO Y "\n[临时文件/编译缓存] 删除成功!"
		;;
		5)
			rm -f ${Home}/Log/SourceUpdate_${Project}_*
			ECHO Y "\n[更新日志] 删除成功!"
		;;
		6)
			rm -f ${Home}/Log/BuildOpenWrt_${Project}_*
			ECHO Y "\n[编译日志] 删除成功!"
		;;
		7)
			ECHO X "\n正在删除 [${Project}] 源码,请稍后 ..."
			rm -rf ${Build_Path}/*
			rm -f ${Home}/Configs/${Project}_Recently_*
			rm -f ${Home}/Log/*_${Project}_*
			AutoBuild_Second
		;;
		esac
		sleep 3
	done
}

Module_Updater() {
	if [[ $(NETWORK_CHECK 223.5.5.5) == 0 ]]
	then
		clear
		ECHO X "正在更新 [AutoBuild] 程序,请稍后 ...\n"
		if [[ -z $(ls -A ${Home}/Backups/AutoBuild-Update) ]]
		then
			git clone https://github.com/Hyy2001X/AutoBuild ${Home}/Backups/AutoBuild-Update
		fi
		cd ${Home}/Backups/AutoBuild-Update
		Update_Logfile=${Home}/Log/AutoBuild_Update_$(date +%Y%m%d_%H:%M).log
		git fetch --all | tee -a ${Update_Logfile}
		git reset --hard origin/master | tee -a ${Update_Logfile} || Update_Failed=1
		git pull 2>&1 | tee ${Update_Logfile} || Update_Failed=1
		if [[ -z ${Update_Failed} ]]
		then
			Old_Version=$(awk 'NR==7' ${Home}/AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}')
			Backups_Dir=${Home}/Backups/OldVersion/AutoBuild-${Old_Version}-$(date +%Y%m%d-%H%M)
			mkdir -p ${Backups_Dir}
			mv ${Home}/AutoBuild.sh ${Backups_Dir}/AutoBuild.sh
			mv ${Home}/README.md ${Backups_Dir}/README.md
			mv ${Home}/LICENSE ${Backups_Dir}/LICENSE
			mv ${Home}/Depends ${Backups_Dir}/Depends 2> /dev/null 
			cp -a * ${Home}
			ECHO Y "\n[AutoBuild] 程序更新成功!"
			Enter
			chmod 777 ${Home}/AutoBuild.sh && exec ${Home}/AutoBuild.sh
		else
			ECHO R "\n[AutoBuild] 程序更新失败!"
			Enter
		fi
	else
		ECHO R "\n网络连接错误,[AutoBuild] 更新失败!"
		sleep 2
	fi
}

Make_Download() {
	if [[ ! -s ${Build_Path}/.config ]]
	then
		ECHO R "\n未检测到 [.config],无法执行 [make download]!"
		sleep 2
	fi
	if [[ $(NETWORK_CHECK 223.5.5.5) == 1 ]]
	then
		ECHO R "\n网络连接错误,执行失败!"
		sleep 2
	fi
	clear
	cd ${Build_Path}
	ECHO X "开始执行 [make download] ...\n"
	dl_Logfile=${Home}/Log/dl_${Project}_$(date +%Y%m%d_%H:%M).log
	if [[ -n $(ls -A dl) ]]
	then
		mv dl/* ${Home}/Backups/dl 2> /dev/null
		rm -rf dl
	fi
	ln -s ${Home}/Backups/dl ${Build_Path}/dl 2> /dev/null
	make -j${CPU_Threads} download V=s 2>&1 | tee -a ${dl_Logfile}
	find dl -size -1024c -exec rm -f {} \;
	ln -s ${Home}/Backups/dl ${Build_Path}/dl 2> /dev/null
	Enter
}

Menuconfig() {
	cd $1
	echo
	read -p "是否删除旧配置文件?[Y/n]:" Choose
	clear
	ECHO B "Loading ${Project} Configuration..."
	case ${Choose} in
	[Yy])
		rm -rf .config*
	;;
	esac
	make menuconfig
	Enter
}

Sources_Download() {
	while :;do
		if [[ -s ${Build_Path}/Makefile ]]
		then
			ECHO Y "\n已检测到 [${Project}]源代码,当前分支:[$(GET_Branch ${Build_Path})]"
			sleep 3
			return
		fi
		clear
		Github_File=${Home}/Depends/Projects/${Project}
		Github_URL=$(egrep "http|https|git@" ${Github_File} | awk 'NR==1')
		ECHO X "[${Project}] 源码下载: 分支选择\n"
		ECHO G "仓库地址: ${Github_URL}\n"
		ECHO "请从下方选择一个分支:\n"
		Github_Branch_Array=($(egrep -v "http|https|git@" ${Github_File}))
		local i=0;while :;do
			echo "$(($i + 1)). ${Github_Branch_Array[$i]}"
			i=$(($i + 1))
			[[ $i == ${#Github_Branch_Array[@]} ]] && break
		done
		echo -e "\nq.返回"
		GET_Choose Choose_Branch
		case ${Choose_Branch} in
		q)
			break
		;;
		[0-9])
			if [[ ${Choose_Branch} -le ${#Github_Branch_Array[@]} && ${Choose_Branch} != 0 ]] 2> /dev/null
			then
				if [[ ${Github_URL} =~ github.com ]]
				then
					echo
					read -p "是否启用 [Ghproxy] 镜像加速?[Y/n]:" if_Ghproxy
					case ${if_Ghproxy} in
					[Yy])
						Github_URL="https://ghproxy.com/${Github_URL}"
					;;
					esac
				fi
				clear
				Github_Branch=${Github_Branch_Array[$((${Choose_Branch} - 1))]}
				ECHO B "下载地址: ${Yellow}${Github_URL}"
				ECHO B "远程分支: ${Yellow}${Github_Branch}\n"
				rm -rf ${Build_Path}
				ECHO X "开始克隆 [${Project}] ...\n"
				git clone -b ${Github_Branch} ${Github_URL} ${Build_Path}
				if [[ $? == 0 ]]
				then
					ln -s ${Home}/Backups/dl ${Build_Path}/dl
					ECHO Y "\n[${Project}] 源码下载成功!"
					Enter
					Second_Menu ${Project}
				else
					ECHO R "\n[${Project}] 源码下载失败!"
					Enter
				fi
			fi
		;;
		esac
	done
}

Module_Builder() {
	if [[ ${LOGNAME} == root ]]
	then
		ECHO R "\n无法使用 [root] 用户进行编译!"
		sleep 3
		return 1
	fi
	if [[ ! -f ${Build_Path}/.config ]]
	then
		ECHO R "\n未检测到设备配置文件,请先执行 [make menuconfig]"
		sleep 3
		return 1
	fi
	while :;do
		cd ${Build_Path}
		Openwrt_Repository=$(egrep -o "git.*" ${Build_Path}/.git/config)
		Openwrt_Branch=$(GET_Branch $(pwd))
		Openwrt_Author=$(echo ${Openwrt_Repository} | cut -d "/" -f2)
		Openwrt_Reponame=$(echo ${Openwrt_Repository} | cut -d "/" -f3)
		case "${Openwrt_Author}/${Openwrt_Reponame}" in
		coolsnowwolf/[Ll]ede)
			Version_File=package/lean/default-settings/files/zzz-default-settings
			CURRENT_Version="$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" ${Version_File})"
		;;
		*)
			CURRENT_Version="R$(echo ${Openwrt_Branch} | egrep -o "[0-9]+.[0-9]+")"
		;;
		esac
		while [[ -z ${x86_Test} ]];do
			x86_Test="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/CONFIG_TARGET_(.*)_DEVICE_(.*)=y/\1/')"
			[[ -n ${x86_Test} ]] && break
			x86_Test="$(egrep -o "CONFIG_TARGET.*Generic=y" .config | sed -r 's/CONFIG_TARGET_(.*)_Generic=y/\1/')"
			[[ -z ${x86_Test} ]] && break
		done
		[[ ${x86_Test} == x86_64 ]] && {
			TARGET_PROFILE=x86_64
		} || {
			TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
		}
		TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
		[[ $(du .config | awk '{print $1}') -lt 100 ]] && {
			DIFF_CONFIG=1
		} || DIFF_CONFIG=0
		case "${TARGET_BOARD}" in
		ramips | reltek | ipq40xx | ath79 | ipq807x)
			Firmware_Format=bin
		;;
		rockchip | x86)
			[[ $(cat .config) =~ CONFIG_TARGET_IMAGES_GZIP=y ]] && {
				Firmware_Format=img.gz || Firmware_Format=img
			}
		;;
		esac
		TARGET_SUBTARGET=$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)
		TARGET_ARCH_PACKAGES=$(awk -F '[="]+' '/TARGET_ARCH_PACKAGES/{print $2}' .config)
		clear
		ECHO X "AutoBuild 固件编译 [${Openwrt_Repository}]\n"
		ECHO X "设备信息:${CPU_Model} ${CPU_Cores} Cores ${CPU_Threads} Threads\n"
		if [ -f .config ]
		then
			if [[ -f ${Home}/Configs/${Project}_Recently_Config ]]
			then
				echo -e "${Yellow}最近配置文件:${Blue}[$(cat ${Home}/Configs/${Project}_Recently_Config)]${White}\n"
			fi
			if [[ ${DIFF_CONFIG} == 0 ]]
			then
				echo -e "源码信息:${Yellow} ${Openwrt_Author}/${Openwrt_Reponame}:${Openwrt_Branch}${White}"
				echo -e "设备名称:${Yellow} ${TARGET_PROFILE}${White}"
				echo -e "CPU 架构:${Yellow} ${TARGET_BOARD}${White}"
				echo -e "CPU 型号:${Yellow} ${TARGET_SUBTARGET}${White}"
				echo -e "软件架构:${Yellow} ${TARGET_ARCH_PACKAGES}${White}"
			else
				ECHO R "[Diff Config] 请先执行 make defconfig !"
			fi
		else
			ECHO R "警告:未检测到配置文件,部分操作将不可用!"
		fi
		echo -e "${Yellow}\n1. make -j1 V=s"
		echo "2. make -j2 V=s"
		echo "3. make -j${CPU_Threads}"
		echo -e "4. make -j${CPU_Threads} V=s${White}"
		echo "5. make menuconfig"
		echo "6. make defconfig"
		ECHO X "7. 高级选项"
		echo "q. 返回"
		if [[ -f ${Home}/Configs/${Project}_Recently_Compiled ]]
		then
			Recently_Compiled=$(awk 'NR==1' ${Home}/Configs/${Project}_Recently_Compiled)
			Recently_Compiled_Stat=$(awk 'NR==2' ${Home}/Configs/${Project}_Recently_Compiled)
			echo -e "\n${Yellow}最近编译时间: ${Blue}[${Recently_Compiled}${Recently_Compiled_Stat}]${White}"
		fi
		GET_Choose Choose_1
		case ${Choose_1} in
		q)
			break
		;;
		1)
			Compile_Threads="make -j1 V=s"
		;;
		2)
			Compile_Threads="make -j2 V=s"
		;;
		3)
			Compile_Threads="make -j${CPU_Threads}"
		;;
		4)
			Compile_Threads="make -j${CPU_Threads} V=s"
		;;
		5)
			Menuconfig $(pwd)
		;;
		6)
			echo
			ECHO X "正在执行 [make defconfig],请稍后 ..."
			make defconfig
		;;
		7)
			while :;do
				clear
				ECHO X "AutoBuild Firmware 高级选项\n"
				echo "1. 执行 [make kernel_menuconfig]"
				echo "2. 执行 [make download]"
				echo "3. 分离 [.config] > defconfig"
				echo "4. 删除 [.config]"
				echo "5. 更多空间清理"
				echo -e "\nq. 返回"
				ECHO X "m. 主菜单"
				GET_Choose Choose
				case ${Choose} in
				1)
					clear
					ECHO X "正在执行 [make kernel_menuconfig],请稍后 ..."
					make kernel_menuconfig
				;;
				2)
					Make_Download
				;;
				3)
					if [ -f .config ]
					then
						./scripts/diffconfig.sh > ${Home}/Backups/Configs/diffconfig_${Project}_$(date +%Y%m%d-%H%M%S)
						ECHO Y "\n新配置文件已保存到: 'Backups/Configs/diffconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)'"
					else
						ECHO R "\n未检测到 [.config]文件!"
					fi
					sleep 2
				;;
				4)
					rm -f ${Build_Path}/.config*
					ECHO Y "\n[配置文件] 删除成功!"
					sleep 2
				;;
				5)
					Space_Cleaner
				;;
				q)
					break
				;;
				m)
					AutoBuild_Core
				;;
				esac
			done
		;;
		esac	
		case ${Choose_1} in
		1 | 2 | 3 | 4)
			clear
			case "${TARGET_BOARD}" in
			x86)
				AutoBuild_Firmware='AutoBuild-${Openwrt_Reponame}-${TARGET_PROFILE}-${CURRENT_Version}-${FW_Boot_Type}-$(GET_SHA256 $1).${Firmware_Format_Defined}'
			;;
			*)
				AutoBuild_Firmware='AutoBuild-${Openwrt_Reponame}-${TARGET_PROFILE}-${CURRENT_Version}-$(GET_SHA256 $1).${Firmware_Format_Defined}'
			;;
			esac
			Firmware_Path="${Build_Path}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
			Packages_Path=${Home}/Packages
			rm -rf ${Firmware_Path}
			ECHO Y "执行指令: [${Compile_Threads}]\n"
			ECHO X "开始编译: [${TARGET_PROFILE}] ..."
			Compile_Date=$(date +%Y%m%d-%H:%M)
			Compile_Started=$(date +"%Y-%m-%d %H:%M:%S")
			echo "${Compile_Started}" > ${Home}/Configs/${Project}_Recently_Compiled
			${Compile_Threads} 2>&1 | tee ${Home}/Log/BuildOpenWrt_${Project}_${Compile_Date}.log
			if [[ $? != 0 ]]
			then
				ECHO R "\n编译失败!"
				Enter
				continue
			fi
			mkdir -p ${Home}/Packages/${TARGET_ARCH_PACKAGES}
			mkdir -p "${Packages_Path}/${TARGET_ARCH_PACKAGES}/Kernel Modules"
			echo
			ECHO X "备份当前 dl 库到 '${Home}/Backups/dl' ..."
			awk "BEGIN { cmd=\"cp -a ${Build_Path}/dl/* ${Home}/Backups/dl\"; print "n" | cmd; }" > /dev/null 2>&1
			ECHO X "备份软件包到 '${Home}/Packages' ...\n"
			rm -rf ${Cache_Path}/Packages && mkdir -p ${Cache_Path}/Packages
			mv -f $(find ${Build_Path}/bin -type f -name "*.ipk") ${Cache_Path}/Packages > /dev/null 2>&1
			mv -f $(find ${Cache_Path}/Packages -type f -name "kmod-*.ipk") "${Packages_Path}/${TARGET_ARCH_PACKAGES}/Kernel Modules" > /dev/null 2>&1
			mv -f $(find ${Cache_Path}/Packages -type f -name "*_${TARGET_ARCH_PACKAGES}.ipk") ${Packages_Path}/${TARGET_ARCH_PACKAGES} > /dev/null 2>&1
			mv -f $(find ${Cache_Path}/Packages -type f -name "luci-app-*.ipk") ${Packages_Path}/luci-app-common > /dev/null 2>&1
			mv -f $(find ${Cache_Path}/Packages -type f -name "luci-i18n-*.ipk") ${Packages_Path}/luci-app-common > /dev/null 2>&1
			mv -f $(find ${Cache_Path}/Packages -type f -name "luci-theme-*.ipk") ${Packages_Path}/luci-theme-common > /dev/null 2>&1
			mv -f $(find ${Cache_Path}/Packages -type f -name "*.ipk") ${Packages_Path} > /dev/null 2>&1
			mv -f $(find ${Build_Path}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET} -type f -name "kmod-*.ipk") "${Packages_Path}/${TARGET_ARCH_PACKAGES}/Kernel Modules" > /dev/null 2>&1
			mv -f $(find ${Build_Path}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET} -type f -name "*.ipk") ${Packages_Path}/${TARGET_ARCH_PACKAGES} > /dev/null 2>&1
			cd ${Firmware_Path}
			SHA256_File="${Firmware_Path}/sha256sums"
			case "${TARGET_BOARD}" in
			x86)
				Process_Firmware $(List_Format)
			;;
			*)
				Process_Firmware ${Firmware_Format}
			;;
			esac
			mkdir -p ${Home}/Firmware/${TARGET_PROFILE}
			[[ $(ls) =~ 'AutoBuild-' ]] && mv -f AutoBuild-* ${Home}/Firmware/${TARGET_PROFILE}
			Enter
		;;
		esac
	done
}

GET_SHA256() {
	List_REGEX | grep "$1" | cut -c1-5
}

Process_Firmware() {
	while [[ $1 ]];do
		Rename_Firmware $1 $(List_Firmware $1)
		shift
	done
}

Rename_Firmware() {
	Firmware_Format_Defined=$1
	shift
	while [[ $1 ]];do
		case "${TARGET_BOARD}" in
		x86)
			[[ $1 =~ efi ]] && {
				FW_Boot_Type=UEFI
			} || {
				FW_Boot_Type=BIOS
			}
		;;
		esac
		eval AutoBuild_Firmware=${AutoBuild_Firmware}
		[[ -f $1 ]] && {
			echo -e "${Yellow}固件名称: ${AutoBuild_Firmware}"
			cp -a $1 ${AutoBuild_Firmware}
		}
		shift
	done
}

List_Firmware() {
	[[ -z $* ]] && {
		List_REGEX | while read X;do
			echo $X | cut -d "*" -f2
		done
	} || {
		while [[ $1 ]];do
			for X in $(echo $(List_REGEX));do
				[[ $X == *$1 ]] && echo "$X" | cut -d "*" -f2
			done
			shift
		done
	}
}

List_Format() {
	echo "$(List_REGEX | cut -d "*" -f2 | cut -d "." -f2-3)" | sort | uniq
}

List_REGEX() {
	egrep -v "packages|buildinfo|sha256sums|manifest|kernel|rootfs|factory" ${SHA256_File} | tr -s '\n'
}

GET_Branch() {
    git -C $1 rev-parse --abbrev-ref HEAD | grep -v HEAD || \
    git -C $1 describe --exact-match HEAD || \
    git -C $1 rev-parse HEAD
}

Compile_Stopped() {
	Compile_Ended=$(date +"%Y-%m-%d %H:%M:%S")
	Start_Seconds=$(date -d "$Compile_Started" +%s)
	End_Seconds=$(date -d "$Compile_Ended" +%s)
	let Compile_Cost=($End_Seconds-$Start_Seconds)/60
	ECHO Y "\n$Compile_Started --> $Compile_Ended 编译用时:$Compile_Cost分钟"
}

ExtraPackages() {
	ExtraPackages_mkdir
	while :
	do
		cd ${ExtraPackages_Path}
		clear
		ECHO X "Extra Packages"
		echo "1. SmartDNS"
		echo "2. AdGuard Home"
		echo "3. OpenClash"
		echo "4. Clash"
		echo "5. OpenAppFilter"
		echo "6. Passwall"
		echo "7. MentoHust"
		echo "8. [微信推送] ServerChan "
		echo "9. [端口转发] Socat"
		echo "10. [Hello World] luci-app-vssr"
		echo "11. [Argon 配置] luci-app-argon-config"
		echo "12. iPerf3 服务器"
		echo "13. NPS 客户端"
		echo -e "\nq. 返回\n"
		read -p '请从上方选择一个软件包:' Choose
		case ${Choose} in
		q)
			break
		;;
		1)
			PKG_NAME=smartdns
			PKG_URL=https://github.com/kenzok8/openwrt-packages/trunk/smartdns
			ExtraPackages_svn
			PKG_NAME=luci-app-smartdns
			if [[ ${Project} == Lede ]]
			then
				PKG_URL="-b lede https://github.com/pymumu/luci-app-smartdns"
			else
				PKG_URL="https://github.com/pymumu/luci-app-smartdns"
			fi
			ExtraPackages_git
			rm -rf ${Build_Path}/tmp
		;;
		2)
			PKG_NAME=luci-app-adguardhome
			PKG_URL=https://github.com/Hyy2001X/AutoBuild-Packages/trunk/luci-app-adguardhome
			ExtraPackages_svn
		;;
		3)
			SRC_NAME=OpenClash
			SRC_URL=https://github.com/vernesong/OpenClash/trunk/luci-app-openclash
			ExtraPackages_svn
		;;
		4)
			PKG_NAME=luci-app-clash
			PKG_URL=https://github.com/frainzy1477/luci-app-clash
			ExtraPackages_git
		;;
		5)
			PKG_NAME=OpenAppFilter
			PKG_URL=https://github.com/Lienol/openwrt-OpenAppFilter
			ExtraPackages_git
		;;
		6)
			PKG_NAME=luci-app-passwall
			PKG_URL=https://github.com/xiaorouji/openwrt-passwall
			ExtraPackages_git
		;;
		7)
			PKG_NAME=luci-app-mentohust
			PKG_URL=https://github.com/immortalwrt/luci/branches/openwrt-18.06/applications/luci-app-mentohust
			ExtraPackages_svn
			PKG_NAME=mentohust
			PKG_URL=https://github.com/immortalwrt/packages/branches/openwrt-18.06/net/mentohust
			ExtraPackages_svn
		;;
		8)
			PKG_NAME=luci-app-serverchan
			PKG_URL=https://github.com/tty228/luci-app-serverchan
			ExtraPackages_git
		;;
		9)
			PKG_NAME=luci-app-socat
			PKG_URL=https://github.com/Lienol/openwrt-package/trunk/luci-app-socat
			ExtraPackages_svn
		;;
		10)
			PKG_NAME=luci-app-vssr
			PKG_URL=https://github.com/jerrykuku/luci-app-vssr
			ExtraPackages_git
		;;
		11)
			PKG_NAME=luci-app-argon-config
			PKG_URL=https://github.com/jerrykuku/luci-app-argon-config
			ExtraPackages_git
		;;
		12)
			PKG_NAME=luci-app-iperf3-server
			PKG_URL=https://github.com/Hyy2001X/AutoBuild-Packages/trunk/luci-app-iperf3-server
			ExtraPackages_svn
		;;
		13)
			PKG_NAME=luci-app-npc
			PKG_URL=https://github.com/Hyy2001X/AutoBuild-Packages/trunk/luci-app-npc
			ExtraPackages_svn
		;;
		esac
	done
}

ExtraThemes() {
	ExtraPackages_mkdir
	while :
	do
		clear
		ECHO X "添加第三方主题包\n"
		if [[ -f ${PKG_Path}/lean/luci-theme-argon/Makefile ]]
		then
			Theme_Version="$(cat ${PKG_Path}/lean/luci-theme-argon/Makefile | grep 'PKG_VERSION' | cut -c14-20)"
			echo -e "1. ${Yellow}luci-theme-argon [${Theme_Version}]${White}"
		else
			echo "1. luci-theme-argon"
		fi
		cd ${ExtraPackages_Path}
		ExtraThemesList_File=${Home}/Depends/Themes.list
		List_MaxLine=$(sed -n '$=' $ExtraThemesList_File)
		rm -f ${Cache_Path}/Checked_Themes > /dev/null 2>&1
		for ((i=1;i<=${List_MaxLine};i++));
			do
				Theme=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
				if [[ -f ${ExtraPackages_Path}/${Theme}/Makefile ]]
				then
					if [[ $(cat ${ExtraPackages_Path}/${Theme}/Makefile) =~ PKG_VERSION ]]
					then
						GET_Version="$(cat ${ExtraPackages_Path}/${Theme}/Makefile | grep 'PKG_VERSION' | cut -c14-20)"
						Theme_Version=" [${GET_Version}]"
						if [[ $(cat ${ExtraPackages_Path}/${Theme}/Makefile) =~ PKG_RELEASE ]]
						then
							GET_Release="$(cat ${ExtraPackages_Path}/${Theme}/Makefile | grep 'PKG_RELEASE' | cut -c14-20)"
							Theme_Version=" [${GET_Version}-${GET_Release}]"
						fi
						echo -e "$(($i + 1)). ${Yellow}${Theme}${Theme_Version}${White}"
					else
						echo -e "$(($i + 1)). ${Yellow}${Theme}${White}"
					fi
					echo "${Theme}" >> ${Cache_Path}/Checked_Themes
				else
					echo "$(($i + 1)). ${Theme}"
				fi
		done
		ECHO X "\na. 添加所有主题包"
		ECHO "u. 更新已安装的主题包"
		echo -e "q. 返回\n"
		read -p '请从上方选择一个主题包:' Choose
		case ${Choose} in
		a)
			clear
			for ((i=1;i<=${List_MaxLine};i++));
			do
				URL_TYPE=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $1}')
				PKG_NAME=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
				PKG_URL=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $3}')
				case ${URL_TYPE} in
				git)
					ExtraPackages_git
				;;
				svn)
					ExtraPackages_svn
				esac
			done
			Enter
		;;
		u)
			if [[ -f ${Cache_Path}/Checked_Themes ]]
			then
				clear
				cat ${Cache_Path}/Checked_Themes | while read Theme
				do
					ECHO X "正在更新 ${Theme} ..."
					cd ./${Theme}
					svn update > /dev/null 2>&1
					git pull > /dev/null 2>&1
					cd ..
				done
				Enter
			else
				ECHO R "\n未安装任何主题包!"
				sleep 2
			fi
		;;
		q)
			break
		;;
		1)
			PKG_NAME=luci-theme-argon
			if [[ ${Project} == Lede ]]
			then
				if [[ -d ${PKG_Path}/lean/luci-theme-argon ]]
				then
					rm -rf ${PKG_Path}/lean/luci-theme-argon
				fi
				PKG_URL=" -b 18.06 https://github.com/jerrykuku/luci-theme-argon"
				ExtraPackages_git
				mv ${ExtraPackages_Path}/luci-theme-argon ${PKG_Path}/lean/luci-theme-argon
			else
				PKG_URL="https://github.com/jerrykuku/luci-theme-argon"
				ExtraPackages_git
			fi
		;;
		*)
			if [[ ${Choose} -gt 0 ]] > /dev/null 2>&1
			then
				if [[ $((${Choose} - 1)) -le ${List_MaxLine} ]] > /dev/null 2>&1
				then
					Choose=$((${Choose} - 1))
					URL_TYPE=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $1}')
					PKG_NAME=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $2}')
					PKG_URL=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $3}')
					case ${URL_TYPE} in
					git)
						ExtraPackages_git
					;;
					svn)
						ExtraPackages_svn
					;;
					*)
						ECHO R "\n[第 ${Choose} 行：${URL_TYPE}] 格式错误!请检查 '/Depends/ExtraThemes_List' ..."
						sleep 3
					esac
				else
					ECHO R "\n输入错误,请输入正确的数字!"
					sleep 2
				fi
			else
				ECHO R "\n输入错误,请输入正确的数字!"
				sleep 2
			fi
		esac
	done
}

ExtraPackages_git() {
	[[ -d ${ExtraPackages_Path}/${PKG_NAME} ]] && rm -rf ${ExtraPackages_Path}/${PKG_NAME}
	git clone ${PKG_URL} ${PKG_NAME} > /dev/null 2>&1
	if [[ -f ${ExtraPackages_Path}/${PKG_NAME}/Makefile || -f ${ExtraPackages_Path}/${PKG_NAME}/README.md || -n $(ls -A ${ExtraPackages_Path}/${PKG_NAME}) ]]
	then
		ECHO Y "\n已添加 ${PKG_NAME}"
	else
		ECHO R "\n未添加 ${PKG_NAME}"
	fi
	sleep 2
}

ExtraPackages_svn() {
	[[ -d ${ExtraPackages_Path}/${PKG_NAME} ]] && rm -rf ${ExtraPackages_Path}/${PKG_NAME}
	svn checkout ${PKG_URL} ${PKG_NAME} > /dev/null 2>&1
	if [[ -f ${ExtraPackages_Path}/${PKG_NAME}/Makefile || -f ${ExtraPackages_Path}/${PKG_NAME}/README.md || -n $(ls -A ${ExtraPackages_Path}/${PKG_NAME}) ]]
	then
		ECHO Y "\n已添加 ${PKG_NAME}"
	else
		ECHO R "\n未添加 ${PKG_NAME}"
	fi
	sleep 2
}

ExtraPackages_mkdir() {
	PKG_Path=${Build_Path}/package
	mkdir -p ${PKG_Path}/ExtraPackages
	ExtraPackages_Path=${PKG_Path}/ExtraPackages
}

Module_Network_Test() {
	clear
	TMP_FILE=${Cache_Path}/NetworkTest.log
	PING_MODE=httping
	[[ -z $(which ${PING_MODE}) ]] && PING_MODE=ping
	ECHO X "网络测试 [${PING_MODE}]\n"
	ECHO G "网址			次数	延迟/Min	延迟/Avg	延迟/Max	状态\n"
	Run_Test www.baidu.com 2
	Run_Test git.openwrt.com 3
	Run_Test www.google.com 3
	Run_Test www.github.com 3
	Enter
}

Run_Test() {
	_URL=$1
	_COUNT=$2
	_TIMEOUT=$((${_COUNT}*2+1))
	[[ -z $1 || -z $2 ]] && return
	[[ ! ${_COUNT} -gt 0 ]] 2> /dev/null && return
	timeout 3 ${PING_MODE} ${_URL} -c 1 > /dev/null 2>&1
	if [[ $? == 0 ]]
	then
		echo -ne "\r${Grey}测试中...${White}\r"
		timeout ${_TIMEOUT} ${PING_MODE} ${_URL} -c ${_COUNT} > ${TMP_FILE}
		_IP=$(egrep -o "[0-9]+.[0-9]+.[0-9]+.[0-9]" ${TMP_FILE} | awk 'NR==1')
		_PING=$(egrep -o "[0-9].+/[0-9]+.[0-9]+" ${TMP_FILE})
		_PING_MIN=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==1')
		_PING_AVG=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==2')
		_PING_MAX=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==3')
		_PING_PROC=$(echo ${_PING_AVG} | egrep -o "[0-9]+" | awk 'NR==1')
		if [[ ${_PING_PROC} -le 50 ]]
		then
			_TYPE="${Yellow}优秀"
		elif [[ ${_PING_PROC} -le 100 ]]
		then
			_TYPE="${Blue}良好"
		elif [[ ${_PING_PROC} -le 200 ]]
		then
			_TYPE="${Grey}一般"
		elif [[ ${_PING_PROC} -le 250 ]]
		then
			_TYPE="${Red}较差"
		else
			_TYPE="${Red}差"
		fi
		echo -e "${_URL}		${_COUNT}	${_PING_MIN}		${_PING_AVG}		${_PING_MAX}		${_TYPE}${White}"
	else
		echo -e "${_URL}		${Red}错误${White}"	
	fi
}

Module_SourcesList() {
	local Mirror=${Home}/Depends/Sources_List/Mirror
	local Codename=${Home}/Depends/Sources_List/Codename
	local Source_Template=${Home}/Depends/Sources_List/Template
	local BAK_FILE=${Home}/Backups/sources.list.bak

	if [[ ${Short_OS} != Ubuntu ]]
	then
		ECHO R "\n暂不支持此操作系统,当前支持的操作系统: [Ubuntu]"
		sleep 2 && return 1
	else
		OS_ID=$(awk -F '[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
		OS_Version=$(awk -F '[="]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
		if [[ ${Short_OS} != Ubuntu ]]
		then
			ECHO R "\n暂不支持此操作系统,当前支持的操作系统: [Ubuntu]"
			sleep 2 && return 1
		fi
		if [[ ! $(cat ${Codename} | awk '{print $1}') =~ ${OS_Version} ]]
		then
			ECHO R "\n暂不支持此 Ubuntu 系统版本: [${OS_Version}]"
			sleep 2 && return 1
		fi	
	fi
	while :;do
		clear
		ECHO X "替换系统下载源\n"
		ECHO "操作系统${Yellow}: [${OS_ID}:${OS_Version}]"
		ECHO "当前系统源${Yellow}: [$(grep -v '#' /etc/apt/sources.list | awk '{print $2}' | sed -r 's/htt[ps]+:\/\/(.*)\/ubuntu\//\1/' | awk 'NR==1')]\n"
		if [[ -f ${Mirror} ]]
		then
			local i=1;for Mirror_Name in $(cat ${Mirror} | awk '{print $1}');do
				echo -e "${i}. ${Yellow}${Mirror_Name}${White}"
				i=$(($i + 1))
			done
		else
			ECHO R "[未检测到镜像列表 ${Mirror}]"
		fi
		ECHO X "\nx. 恢复默认源"
		echo "q. 返回"
		GET_Choose Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			if [[ -f ${BAK_FILE} ]]
			then
				$(command -v sudo) mv ${BAK_FILE} /etc/apt/sources.list
				ECHO Y "\n[默认源] 恢复成功!"
			else
				ECHO R "\n未找到备份: [${BAK_FILE}],恢复失败!"
			fi
			sleep 2
		;;
		[0-9])
			if [[ ${Choose} -gt 0 && ! ${Choose} -gt $(($i - 1)) ]] > /dev/null 2>&1
			then
				Server_Url=$(sed -n ${Choose}p ${Mirror} | awk '{print $2}')
				Server_Name=$(sed -n ${Choose}p ${Mirror} | awk '{print $1}')
				Code_Name=$(grep "${OS_Version}" ${Codename} | awk '{print $2}')
				if [[ -z ${Server_Url} || -z ${Server_Name} || -z ${Code_Name} ]]
				then
					ECHO R "\n参数获取失败,请尝试更新 [AutoBuild] 后重试!"
					sleep 2
					continue
				fi
				if [[ -f /etc/apt/sources.list && ! -f ${BAK_FILE} ]]
				then
					$(command -v sudo) cp -a /etc/apt/sources.list ${BAK_FILE}
					$(command -v sudo) chmod 777 ${BAK_FILE}
					ECHO Y "\n当前系统源已自动备份到 '${BAK_FILE}'"
				fi
				$(command -v sudo) cp ${Source_Template} /etc/apt/sources.list
				$(command -v sudo) sed -i "s?ServerUrl?${Server_Url}?g" /etc/apt/sources.list
				$(command -v sudo) sed -i "s?Codename?${Code_Name}?g" /etc/apt/sources.list
				ECHO Y "\n系统源已切换到: [${Server_Name}]"
				sleep 2
			fi
		;;
		esac
	done
}

ECHO() {
	local Color
	case $# in
	1)
		echo -e "${White}${*}${White}"
	;;
	2)
		case $1 in
		R) Color="${Red}";;
		G) Color="${Green}";;
		B) Color="${Blue}";;
		Y) Color="${Yellow}";;
		X) Color="${Grey}";;
		*) Color="${White}";;
		esac
		shift
		echo -e "${Color}${*}${White}"
	;;
	esac
}

GET_Choose() {
	echo -e "${White}"
	read -p '请从上方选择一个选项或操作:' $1
}

Enter() {
	echo -e "${White}"
	read -p "按下[回车]键以继续..." Key
}

Decoration() {
	printf "${Grey}%-${1}s${White}\n" "$2" | sed "s/\s/$2/g"
}

Module_SSHServices() {
	while :;do
		clear
		ECHO X "SSH Services"
		if [[ -n $(ls -A ${Home}/Configs/SSH) ]]
		then
			cd ${Home}/Configs/SSH
			echo "$(ls -A)" > ${Cache_Path}/SSHProfileList
			SSHProfileList=${Cache_Path}/SSHProfileList
			SSHProfileList_MaxLine=$(sed -n '$=' $SSHProfileList)
			ECHO X "配置文件列表"
			echo
			for ((i=1;i<=${SSHProfileList_MaxLine};i++));
			do   
				SSHProfile=$(sed -n ${i}p $SSHProfileList)
				echo -e "${i}. ${Yellow}${SSHProfile}${White}"
			done
		else
			ECHO R "\n[未检测到任何配置文件]"
		fi
		ECHO X "\nn. 创建新配置文件"
		[[ -n $(ls -A ${Home}/Configs/SSH) ]] && ECHO R "d. 删除所有配置文件"
		echo "x. 重置 [RSA Key Fingerprint]"
		echo -e "q. 返回\n"
		read -p '请从上方选择一个操作:' Choose
		case ${Choose} in
		q)
			return 0
		;;
		n)
			Create_SSHProfile
		;;
		d)
			rm -f ${Home}/Configs/SSH/*  2> /dev/null
			ECHO Y "\n已删除所有 [SSH] 配置文件!"
			sleep 2
		;;
		x)
			rm -rf ~/.ssh
			ECHO Y "\n[SSH] [RSA Key Fingerprint] 重置成功!"
			sleep 2
		;;
		*)
			if [[ ${Choose} -gt 0 ]] > /dev/null 2>&1
			then
				if [[ ${Choose} -le $SSHProfileList_MaxLine ]] > /dev/null 2>&1
				then
					SSHProfile_File="${Home}/Configs/SSH/$(sed -n ${Choose}p ${SSHProfileList})"
					Module_SSHServices_Menu
				else
					ECHO R "\n[SSH] 输入错误,请输入正确的数字!"
					sleep 2
				fi
			fi
		;;
		esac
	done
}

Module_SSHServices_Menu() {
	while :;do
		. "$SSHProfile_File"
		clear
		echo -e "${Blue}配置文件: ${Yellow}[$SSHProfile_File]${White}"
		echo -e "${Blue}连接参数: ${Yellow}[ssh ${SSH_User}@${SSH_IP} -p ${SSH_Port}: ${SSH_Password}]${White}\n"
		ECHO "1. 连接到 SSH"
		echo "2. 编辑配置"
		echo "3. 重命名配置"
		echo "4. 修改密码"
		ECHO R "5. 删除此配置文件"
		echo "6. 重置[RSA Key Fingerprint]"
		echo -e "\nq. 返回"
		GET_Choose Choose
		case ${Choose} in
		q)
			break
		;;
		1)
			ssh-keygen -R $SSH_IP > /dev/null 2>&1
			SSH_Login
		;;
		2)
			SSH_Profile="$SSHProfile_File"
			read -p '[SSH] 请输入新的 IP 地址[回车即跳过修改]:' SSH_IP_New
			[[ -n $SSH_IP_New ]] && {
				sed -i "s?SSH_IP=${SSH_IP}?SSH_IP=${SSH_IP_New}?g" "$SSH_Profile"
				SSH_IP=$SSH_IP_New 
			}
			read -p '[SSH] 请输入新的端口号:' SSH_Port_New
			[[ -n $SSH_Port_New ]] && {
				sed -i "s?SSH_Port=${SSH_Port}?SSH_Port=${SSH_Port_New}?g" "$SSH_Profile"
				SSH_Port=$SSH_Port_New
			}
			read -p '[SSH] 请输入新的用户名:' SSH_User_New
			[[ -n $SSH_User_New ]] && {
				sed -i "s?SSH_User=${SSH_User}?SSH_User=${SSH_User_New}?g" "$SSH_Profile"
				SSH_User=$SSH_User_New
			}
			read -p '[SSH] 请输入新密码:' SSH_Password_New
			[[ -n $SSH_Password_New ]] && {
				if [[ -z $SSH_Password ]]
				then
					sed -i '/SSH_Password/d' "$SSHProfile"
					echo "SSH_Password=$SSH_Password_New" >> "$SSHProfile"
				else
					sed -i "s?SSH_Password=${SSH_Password}?SSH_Password=${SSH_Password_New}?g" "$SSH_Profile"
				fi
				SSH_Password=$SSH_Password_New
			}
		;;
		3)
			echo
			read -p '[SSH] 请输入新的配置名称:' SSHProfile_RN
			if [[ ! -z "$SSHProfile_RN" ]]
			then
				cd ${Home}/Configs/SSH
				mv "$SSHProfile_File" "$SSHProfile_RN" > /dev/null 2>&1
				ECHO Y "\n重命名 [$SSHProfile_File] > [$SSHProfile_RN] 成功!"
				SSHProfile_File="$SSHProfile_RN"
			else
				ECHO R "\n[SSH] 配置名称不能为空!"
			fi
			sleep 2
		;;
		4)
			echo
			read -p '[SSH] 请输入新的密码:' SSH_Password
			sed -i '/SSH_Password/d' "$SSHProfile_File"
			echo "SSH_Password=$SSH_Password" >> "$SSHProfile_File"
			ECHO Y "\n[SSH] 配置文件已保存!"
			sleep 2
		;;
		5)
			rm -f "$SSHProfile_File"
			ECHO Y "\n[SSH] 配置文件 [$SSHProfile_File] 删除成功!"
			sleep 2
			break
		;;
		6)
			ssh-keygen -R $SSH_IP > /dev/null 2>&1
			ECHO Y "\n[SSH] [RSA Key Fingerprint] 重置成功!"
			sleep 2
		;;
		esac
	done
}

Create_SSHProfile() {
	cd ${Home}
	echo
	read -p '请输入新配置名称:' SSH_Profile
	[[ -z $SSH_Profile ]] && SSH_Profile="${Home}/Configs/SSH/ssh-$(openssl rand -base64 4 | tr -d =)" || SSH_Profile=${Home}/Configs/SSH/"$SSH_Profile"
	[[ -f $SSH_Profile ]] && {
		ECHO R "\n[SSH] 已存在相同名称的配置文件!"
		sleep 2
		return
	}
	read -p '[SSH] 请输入IP地址:' SSH_IP
	[[ -z $SSH_IP ]] && SSH_IP="192.168.1.1"
	read -p '[SSH] 请输入端口号:' SSH_Port
	[[ -z $SSH_Port ]] && SSH_Port=22
	read -p '[SSH] 请输入用户名:' SSH_User
	while [[ -z $SSH_User ]]
	do
		ECHO R "\n[SSH] 用户名不能为空!"
		echo
		read -p '[SSH] 请输入用户名:' SSH_User
	done
	read -p '[SSH] 请输入密码:' SSH_Password
	echo "SSH_IP=$SSH_IP" > "$SSH_Profile"
	echo "SSH_Port=$SSH_Port" >> "$SSH_Profile"
	echo "SSH_User=$SSH_User" >> "$SSH_Profile"
	echo "SSH_Password=$SSH_Password" >> "$SSH_Profile"
	ECHO Y "\n[SSH] 配置文件已保存到 '$SSH_Profile'"
	sleep 2
	SSH_Login
}

SSH_Login() {
	clear
	echo -e "${Blue}连接参数:${Yellow}[ssh ${SSH_User}@${SSH_IP} -p ${SSH_Port}]${White}\n"
	expect -c "
	set timeout 3
	spawn ssh ${SSH_User}@${SSH_IP} -p ${SSH_Port}
	expect {
		*yes/no* { send \"yes\r\"; exp_continue }
		*password:* { send \"${SSH_Password}\r\" }  
	}
	interact"
	sleep 1
}

Module_Systeminfo() {
	GET_System_Info 2
	clear
	ECHO X "系统信息\n"
	Decoration 70 =
	ECHO X "操作系统${Yellow}		${Short_OS}"
	ECHO X "系统版本${Yellow}		${OS_INFO}"
	ECHO X "计算机名称${Yellow}		${Computer_Name}"
	ECHO X "登陆用户名${Yellow}		${USER}"
	ECHO X "内核版本${Yellow}		${Kernel_Version}"
	ECHO X "物理内存${Yellow}		${MemTotal_GB}GB/${MemTotal_MB}MB"
	ECHO X "可用内存${Yellow}		${MemFree_GB}GB/${MemFree}MB"
	ECHO X "CPU 型号${Yellow}		${CPU_Model}"
	ECHO X "CPU 频率${Yellow}		${CPU_Freq}"
	ECHO X "CPU 架构${Yellow}		${CPU_Info}"
	ECHO X "CPU 核心数量${Yellow}		${CPU_Cores}"
	ECHO X "CPU 当前频率${Yellow}		${Current_Freq}MHz"
	ECHO X "CPU 当前温度${Yellow}		${Current_Temp}"
	ECHO X "IP 地址${Yellow}			${IP_Address}"
	ECHO X "开机时长${Yellow}		${Computer_Startup}"
	Decoration 70 =
	Enter
}

GET_OS() {
	[[ -f /etc/redhat-release ]] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
	[[ -f /etc/os-release ]] && awk -F '[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
	[[ -f /etc/lsb-release ]] && awk -F '[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
		
GET_System_Info() {
	case $1 in
	1)
		CPU_Model=$(awk -F ':[ ]' '/model name/{printf ($2);exit}' /proc/cpuinfo)
		CPU_Cores=$(cat /proc/cpuinfo | grep processor | wc -l)
		CPU_Threads=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
		CPU_Freq=$(awk '/model name/{print ""$NF;exit}' /proc/cpuinfo)
		OS_INFO=$(GET_OS)
		Short_OS=$(echo ${OS_INFO} | awk '{print $1}')
		System_Bit=$(getconf LONG_BIT)
		CPU_Base=$(uname -m)
		[[ -z ${CPU_Base} ]] && CPU_Info="${System_Bit}" || CPU_Info="${System_Bit} (${CPU_Base} Bit)"
		Computer_Name=$(hostname)
		MemTotal_MB=$(free -m | awk '{print $2}' | awk 'NR==2')
		MemTotal_GB=$(echo "scale=1; $MemTotal_MB / 1000" | bc)
	;;
	2)
		Current_Freq=$(echo "$(grep 'MHz' /proc/cpuinfo | awk '{Freq_Sum += $4};END {print Freq_Sum}') / ${CPU_Threads}" | bc)
		Current_Temp=$(echo "$(sensors 2> /dev/null | grep Core | awk '{Sum += $3};END {print Sum}') / ${CPU_Cores}" | bc 2> /dev/null | awk '{a=$1;b=32+$1*1.8} {printf("%d°C | %.1f°F\n",a,b)}')
		Kernel_Version=$(uname -r)
		Computer_Startup=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=($1%60)} {printf("%d 天 %d 小时 %d 分钟 %d 秒\n",a,b,c,d)}' /proc/uptime)
		IP_Address=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | awk 'NR==1')
		MemFree=$(free -m | awk '{print $7}' | awk 'NR==2')
		MemFree_GB=$(echo "scale=1; $MemFree / 1000" | bc)
	;;
	esac
}

NETWORK_CHECK() {
	if [[ -z $(command -v ping) ]]
	then
		echo 0
		return 0
	fi
	ping $1 -c 1 -W 3 > /dev/null 2>&1
	[[ $? == 0 ]] && echo 0 || echo 1
}

AutoBuild_Core() {
	while :
	do
		clear
		ECHO X "${AutoBuild_Title}\n"
		ECHO X "1. 项目菜单"
		echo "2. 网络测试"
		echo "3. 高级选项"
		echo "q. 退出脚本"
		GET_Choose Choose
		case ${Choose} in
		q | exit)
			rm -rf ${Cache_Path}/* 2> /dev/null
			exit
		;;
		1)
			AutoBuild_Second
		;;
		2)
			Module_Network_Test
		;;
		3)
			Advanced_Options
		;;
		esac
	done
}


AutoBuild_Second() {
	while :;do
	clear
		cd ${Home}
		ECHO X "${AutoBuild_Title}\n"
		ECHO X "项目名称		[项目状态]\n"
		for ((i=0;i<=${#Project_List[@]};i++));do
			e=$(($i + 1))
			[[ -n ${Project_List[i]} ]] && Project_Details ${e} ${Project_List[i]}
		done
		unset e i
		ECHO G "\nx. 更新所有源代码"
		ECHO X "m. 主菜单\n"
		read -p '请从上方选择一个项目:' Choose
		[[ ${Choose} =~ [0-9] ]] && Choose=$((${Choose} - 1))
		case ${Choose} in
		q | m | exit)
			AutoBuild_Core
		;;
		x)
			for X in $(echo ${Project_List[@]});do
				Sources_Update common ${X}
			done
		;;
		[0-9])
			[[ -n ${Project_List[${Choose}]} ]] && \
				Second_Menu ${Project_List[${Choose}]}
		;;
		esac
	done
}

Project_Details() {
	if [[ -f ${Home}/Projects/$2/Makefile ]]
	then
		printf "%s. %-20s ${Yellow}%-19s${Grey}\n${White}" $1 $2 [已检测到]
	else
		printf "%s. %-20s ${Red}%-19s${Grey}\n${White}" $1 $2 [未检测到]
	fi
}

Sources_Update() {
	if [[ ! -s ${Build_Path}/Makefile ]]
	then
		ECHO R "\n未检测到[${Project}]源码,更新失败!"
		sleep 2
		return
	fi
	if [[ $(NETWORK_CHECK 223.5.5.5) == 1 ]]
	then
		ECHO R "\n网络连接错误,更新失败!"
		sleep 2
		return
	fi
	clear
	Update_Logfile=${Home}/Log/SourceUpdate_${Project}_$(date +%Y%m%d_%H:%M).log
	cd ${Home}/Projects/$2
	case $1 in
	force)
		ECHO X "开始强制更新[${Project}],请稍后 ...\n"
		git fetch --all | tee -a ${Update_Logfile}
		git reset --hard origin/$(GET_Branch ${Build_Path}) | tee -a ${Update_Logfile}
	;;
	common)
		ECHO X "开始更新[${Project}],请稍后 ...\n"
	;;
	esac
	echo "$(date +%Y-%m-%d_%H:%M)" > ${Home}/Configs/${Project}_Recently_Updated
	git pull 2>&1 | tee ${Update_Logfile}
	./scripts/feeds update -a 2>&1 | tee -a ${Update_Logfile}
	./scripts/feeds install -a 2>&1 | tee -a ${Update_Logfile}
	ECHO Y "\n[${Project}] 源码文件更新结束!"
	sleep 3
}

Home=$(cd $(dirname $0); pwd)
Cache_Path=${Home}/Cache

White="\e[0m"
Yellow="\e[33m"
Red="\e[31m"
Blue="\e[34m"
Grey="\e[36m"
Green="\e[32m"

Path_Depends=(
	Projects
	Cache
	Packages
	Packages/luci-app-common
	Packages/luci-theme-common
	Firmware
	Backups
	Backups/AutoBuild-Update
	Backups/Projects
	Backups/OldVersion
	Backups/Configs
	Backups/dl
	Configs
	Configs/SSH
	Log
	Depends/Sources_List
	Depends/Projects
)

Backup_List=(
	config
	include
	package
	scripts
	target
	toolchain
	tools
	Config.in
	Makefile
	BSDmakefile
	feeds.conf.default
	rules.mk
)

Project_List=(Lede Openwrt Lienol ImmortalWrt)

Dependency=(build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc-s1 libc6-dev-i386 subversion flex uglifyjs git gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync)
Extra_Dependency=(ntpdate httping ssh lm-sensors net-tools expect inetutils-ping)

for X in $(echo ${Path_Depends[@]});do
	[[ ! -d ${Home}/${X} ]] && mkdir -p ${Home}/${X} 2> /dev/null
done
unset X Path_Depends

GET_System_Info 1
AutoBuild_Title="AutoBuild Core ${Version}-${Update} [${Short_OS}] [${LOGNAME}]"
AutoBuild_Core
