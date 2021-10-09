#!/bin/bash
# Project	AutoBuild
# Author	Hyy2001
# Github	https://github.com/Hyy2001X/AutoBuild

Update=2021.7.13
Version=V4.3.4

Second_Menu() {
	while :
	do
		clear
		if [[ -f ${Home}/Projects/${Project}/Makefile ]];then
			MSG_COM "源码位置:${Home}/Projects/${Project}"
			if [[ ${Project} == Lede ]];then
				if [[ -f ${Home}/Projects/${Project}/package/lean/default-settings/files/zzz-default-settings ]];then
					cd ${Home}/Projects/${Project}/package/lean/default-settings/files
					Lede_Version=$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" ./zzz-default-settings)
					MSG_COM "源码版本:${Lede_Version}"
				fi
			fi
			cd ${Home}
			if [[ -f ./Configs/${Project}_Recently_Updated ]];then
				Recently_Updated=$(cat ./Configs/${Project}_Recently_Updated)
				MSG_COM "最近更新:$Recently_Updated"
			fi
			cd ${Home}/Projects/${Project}
			Branch=$(git branch | sed 's/* //g')
		else
			MSG_COM R "警告:未检测到[${Project}]源码,请前往[高级选项]下载!"
		fi
		echo
		echo "1.更新源代码和Feeds"
		echo "2.打开固件配置菜单"
		echo "3.备份与恢复"
		echo "4.编译选项"
		echo "5.高级选项"
		MSG_COM G "\nm.主菜单"
		echo "q.返回"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		m)
			AutoBuild_Core
		;;
		1)
			Enforce_Update=0
			Sources_Update_Check
		;;
		2)
			Make_Menuconfig
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
	while :
	do
		cd ${Home}/Projects/${Project}
		clear
		MSG_TITLE "源码高级选项"
		echo "1.下载源代码"
		echo "2.强制更新源代码和Feeds"
		MSG_COM Y "3.添加主题包"
		MSG_COM G "4.添加软件包"
		echo "5.空间清理"
		echo "6.删除配置文件"
		echo "7.下载[dl]库"
		echo "8.源代码更新日志"
		MSG_COM G "\nm.主菜单"
		echo "q.返回"
		GET_Choose
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
			Enforce_Update=1
			Sources_Update_Check
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
			rm -f ${Home}/Projects/${Project}/.config*
			MSG_SUCC "[配置文件] 删除成功!"
			sleep 2
		;;
		7)
			Make_Download
		;;
		8)
			clear
			if [[ -d ${Home}/Projects/${Project}/.git ]];then
				cd ${Home}/Projects/${Project}
				git log -10 --graph --all --branches --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%cr)%C(reset) %C(bold green)(%ai)%C(reset) %C(white)%s'
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
		MSG_TITLE "备份与恢复"
		echo "1.备份[.config]"
		echo "2.恢复[.config]"
		echo "3.备份[${Project}]源代码"
		echo "4.恢复[${Project}]源代码"
		MSG_COM G "5.链接[dl]库"
		echo -e "\nq.返回"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		1)
			while :;do
				cd ${Home}
				clear
				MSG_TITLE "备份[.config]"
				echo -e "1.固定名称"
				echo "2.自定义名称"
				echo -e "\nq.返回"
				GET_Choose
				case ${Choose} in
				q)
					break
				;;
				1)
					Backup_Config=${Project}-$(date +%m%d_%H:%M)
					if [[ -f ./Projects/${Project}/.config ]];then
						cp ./Projects/${Project}/.config ./Backups/Configs/${Backup_Config}
						MSG_SUCC "备份成功![.config] 已备份到:'/Backups/Configs/${Backup_Config}'"
					else
						MSG_ERR "[.config] 备份失败!"
					fi
				;;
				2)
					read -p '请输入自定义名称:' Backup_Config
					if [[ -f ./Projects/${Project}/.config ]];then
						cp ./Projects/${Project}/.config ./Backups/Configs/"${Backup_Config}"
						MSG_SUCC "备份成功![.config] 已备份到:'/Backups/Configs/${Backup_Config}'"
					else
						MSG_ERR "[.config] 备份失败!"
					fi
				;;
				esac
				sleep 2
			done
		;;
		2)
			if [[ -n "$(ls -A ${Home}/Backups/Configs)" ]];then
				while :
				do
					clear
					MSG_TITLE "恢复[.config]"
					cd ${Home}/Backups/Configs
					ls -A | cat > ${Home}/TEMP/Config.List
					ConfigList_File=${Home}/TEMP/Config.List
					Max_ConfigList_Line=$(sed -n '$=' ${ConfigList_File})
					for ((i=1;i<=${Max_ConfigList_Line};i++));
					do
						ConfigFile_Name=$(sed -n ${i}p $ConfigList_File)
						echo -e "${i}.${Yellow}${ConfigFile_Name}${White}"
					done
					echo -e "\nq.返回\n"
					read -p '请从上方选择一个文件:' Choose
					case ${Choose} in
					q)
						break
					;;
					*)
						if [[ ${Choose} -le ${Max_ConfigList_Line} ]] 2>/dev/null ;then
							if [[ ! ${Choose} == 0 ]] 2>/dev/null ;then
								ConfigFile=$(sed -n ${Choose}p $ConfigList_File)
								if [[ -f "${ConfigFile}" ]];then
									ConfigFile_Dir="${Home}/Backups/Configs/$ConfigFile"
									cp "$ConfigFile_Dir" ${Home}/Projects/${Project}/.config
									echo "${ConfigFile}" > ${Home}/Configs/${Project}_Recently_Config
									MSG_SUCC "配置文件 [$ConfigFile] 恢复成功!"
									sleep 2
								else
									MSG_ERR "未检测到对应的配置文件!"
									sleep 2
								fi
							else
								MSG_ERR "输入错误,请输入正确的数字!"
								sleep 2
							fi
						else
							MSG_ERR "输入错误,请输入正确的数字!"
							sleep 2
						fi
					;;
					esac
				done
			else
				MSG_ERR "未找到备份文件,恢复失败!"
				sleep 2
			fi
		;;
		3)
			MSG_WAIT "正在备份[${Project}]源代码..."
			[ ! -d ${Home}/Backups/Projects/${Project} ] && mkdir -p ${Home}/Backups/Projects/${Project}
			cd ${Home}/Backups/Projects/${Project}
			for LB in $(cat ${Home}/Additional/Backups.list)
			do
				cp -a ${Home}/Projects/${Project}/$LB ./
			done
			chmod 777 -R ${Home}/Backups/Projects/${Project}
			MSG_SUCC "备份成功![${Project}]源代码已备份到:'Backups/Projects/${Project}'"
			MSG_SUCC "存储占用:$(du -sh ${Home}/Backups/Projects/${Project} | awk '{print $1}')B"
			Enter
		;;
		4)
			if [[ -f ${Home}/Backups/Projects/${Project}/Makefile ]];then
				echo
				MSG_WAIT "正在恢复[${Project}]源代码..."
				cp -a ${Home}/Backups/Projects/${Project} ${Home}/Projects/ > /dev/null 2>&1
				MSG_SUCC "恢复成功![${Project}]源代码已恢复到:'Projects/${Project}'"
				Enter
			else
				MSG_ERR "未找到备份文件,恢复失败!"
				sleep 2
			fi
		;;
		5)
			cd ${Home}/Projects
			if [[ ! -h ./${Project}/dl ]];then
				[ -d ./${Project}/dl ] && mv -f ./${Project}/dl/* ${Home}/Backups/dl
				rm -rf ./${Project}/dl
				ln -s ${Home}/Backups/dl ${Home}/Projects/${Project}/dl
			fi
			MSG_SUCC "已创建链接:'${Home}/Backups/dl' -> '${Home}/Projects/${Project}/dl'"
			sleep 3
		;;
		esac
	done
}

Advanced_Options() {
	while :
	do
		clear
		MSG_TITLE "高级选项"
		MSG_COM "1.更新系统软件包"
		MSG_COM G "2.安装编译环境"
		echo "3.SSH 服务"
		echo "4.同步网络时间"
		echo "5.快捷指令启动"
		echo "6.系统信息"
		echo "7.系统下载源"
		MSG_COM "\nx.更新脚本"
		MSG_COM G "q.主菜单"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			Module_Updater
		;;
		1)
			clear
			sudo apt-get update
			sudo apt-get upgrade
			Enter
		;;
		2)
			clear
			Update_Times=1
			sudo apt-get update
			while [ $Update_Times -le 3 ];
			do
				clear
				MSG_WAIT "开始第 $Update_Times 次安装..."
				sleep 2
				sudo apt-get -y install $Dependency $Extra_Dependency
				Update_Times=$(($Update_Times + 1))
				sleep 1
			done
			sudo apt-get clean
			Enter
		;;
		3)
			Module_SSHServices
		;;
		4)
			echo
			sudo ntpdate ntp1.aliyun.com
			sudo hwclock --systohc
			sleep 2
		;;
		5)
			echo
			read -p '请输入快速启动的指令:' FastOpen	
			[ -f ~/.bashrc ] && echo "alias ${FastOpen}='${Home}/AutoBuild.sh'" >> ~/.bashrc || {
				sudo echo "alias ${FastOpen}='${Home}/AutoBuild.sh'" >> /etc/profile
			}
			MSG_SUCC "创建成功!下次登录在终端输入 ${FastOpen} 即可启动 AutoBuild."
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
		MSG_TITLE "空间清理"
		echo "1.执行 [make clean]"
		echo "2.执行 [make dirclean]"
		echo "3.执行 [make distclean]"
		MSG_COM R "4.删除 [${Project}] 项目"
		echo "5.清理 [临时文件/编译缓存]"
		echo "6.清理 [更新日志]"
		echo "7.清理 [编译日志]"
		echo "q.返回"
		GET_Choose
		cd ${Home}/Projects/${Project}
		case ${Choose} in
		q)
			break
		;;
		1)
			echo
			MSG_WAIT "正在执行[make clean],请耐心等待..."
			make clean > /dev/null 2>&1
		;;
		2)
			echo
			MSG_WAIT "正在执行[make dirclean],请耐心等待..."
			make dirclean > /dev/null 2>&1
		;;
		3)
			echo
			MSG_WAIT "正在执行[make distclean],请耐心等待..."
			make distclean > /dev/null 2>&1
		;;
		4)
			echo
			MSG_WAIT "正在删除[${Project}],请耐心等待..."
			rm -rf ${Home}/Projects/${Project}/*
			rm -f ${Home}/Configs/${Project}_Recently_*
			rm -f ${Home}/Log/*_${Project}_*
		;;
		5)
			rm -rf ${Home}/Projects/${Project}/tmp
			MSG_SUCC "[临时文件/编译缓存] 删除成功!"
		;;
		6)
			rm -f ${Home}/Log/SourceUpdate_${Project}_*
			MSG_SUCC "[更新日志] 删除成功!"
		;;
		7)
			rm -f ${Home}/Log/BuildOpenWrt_${Project}_*
			MSG_SUCC "[编译日志] 删除成功!"
		;;
		esac
		sleep 2
	done
}

Module_Updater() {
	timeout 3 ping -c 1 -w 2 223.5.5.5 > /dev/null 2>&1
	if [[ $? != 0 ]];then
		clear
		MSG_WAIT "正在更新[AutoBuild],请耐心等待..."
		cd ${Home}/Backups
		if [[ -z $(ls -A ./AutoBuild-Update) ]];then
			git clone https://github.com/Hyy2001X/AutoBuild AutoBuild-Update
		fi
		cd ./AutoBuild-Update
		Update_Logfile=${Home}/Log/Script_Update_$(date +%Y%m%d_%H:%M).log
		git pull 2>&1 | tee $Update_Logfile || Update_Failed=1
		if [[ -z ${Update_Failed} ]];then
			MSG_COM "\n合并到本地文件..."
			Old_Version=$(awk 'NR==7' ${Home}/AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}')
			Old_Version_Dir=${Old_Version}-$(date +%Y%m%d_%H:%M)
			Backups_Dir=${Home}/Backups/OldVersion/AutoBuild-Core-${Old_Version}
			[ -d ${Backups_Dir} ] && rm -rf ${Backups_Dir}
			mkdir -p ${Backups_Dir}
			mv ${Home}/AutoBuild.sh ${Backups_Dir}/AutoBuild.sh
			mv ${Home}/README.md ${Backups_Dir}/README.md
			mv ${Home}/LICENSE ${Backups_Dir}/LICENSE
			mv ${Home}/Additional ${Backups_Dir}/Additional 2>/dev/null 
			cp -a * ${Home}
			MSG_SUCC "[AutoBuild] 更新成功!"
			Enter
			${Home}/AutoBuild.sh
		else
			MSG_ERR "[AutoBuild] 更新失败!"
			Enter
		fi
	else
		MSG_ERR "网络连接错误,[AutoBuild] 更新失败!"
		sleep 2
	fi
}

Sources_Update_Check() {
	if [[ -f ${Home}/Projects/${Project}/Makefile ]];then
		timeout 3 ping -c 1 -w 2 223.5.5.5 > /dev/null 2>&1
		if [[ $? != 0 ]];then
			Sources_Update_Core
			read -p "" Key
		else
			MSG_ERR "网络连接错误,[${Project}]源码更新失败!"
			sleep 2
		fi
	else
		MSG_ERR "未检测到[${Project}]源码,更新失败!"
		sleep 2
	fi
}

Make_Download() {
	if [[ -f ${Home}/Projects/${Project}/.config ]];then
		timeout 3 ping -c 1 -w 2 223.5.5.5 > /dev/null 2>&1
		if [[ $? != 0 ]];then
			cd ${Home}/Projects/${Project}
			clear
			MSG_WAIT "开始执行 [make download]..."
			echo
			dl_Logfile=${Home}/Log/dl_${Project}_$(date +%Y%m%d_%H:%M).log
			if [[ -d dl ]];then
				mv dl/* ${Home}/Backups/dl > /dev/null 2>&1
				rm -rf dl
			fi
			ln -s ${Home}/Backups/dl ${Home}/Projects/${Project}/dl > /dev/null 2>&1
			make -j$CPU_Threads download V=s 2>&1 | tee -a $dl_Logfile
			find dl -size -1024c -exec rm -f {} \;
			ln -s ${Home}/Backups/dl ${Home}/Projects/${Project}/dl > /dev/null 2>&1
			Enter
		else
			MSG_ERR "网络连接错误,执行失败!"
			sleep 2
		fi
	else
		MSG_ERR "未检测到[.config]文件,无法执行 [make download]!"
		sleep 2
	fi
}

Make_Menuconfig() {
	clear
	cd ${Home}/Projects/${Project}
	MSG_COM B "Loading ${Project} Configuration..."
	make menuconfig
	Enter
}

Sources_Update_Core() {
	clear
	MSG_WAIT "开始更新[${Project}],请耐心等待..."
	echo
	echo "$(date +%Y-%m-%d_%H:%M)" > ${Home}/Configs/${Project}_Recently_Updated
	cd ${Home}/Projects/${Project}
	if [[ $Enforce_Update == 1 ]];then
		git fetch --all
		git reset --hard origin/$Branch
	fi
	Update_Logfile=${Home}/Log/SourceUpdate_${Project}_$(date +%Y%m%d_%H:%M).log
	git pull 2>&1 | tee $Update_Logfile
	./scripts/feeds update -a 2>&1 | tee -a $Update_Logfile
	./scripts/feeds install -a 2>&1 | tee -a $Update_Logfile
	MSG_SUCC "[源代码和Feeds]更新结束!"
}

Multi_Sources_Update() {
	if [[ -f ${Home}/Projects/$1/Makefile ]];then
		Project=$1
		Enforce_Update=0
		Sources_Update_Core
		sleep 2
	fi
}

Project_Details() {
	if [[ -f ./Projects/$1/Makefile ]];then
		echo -e "${White}$2.$1$DE${Yellow}[已检测到]${Blue}	$3"
	else
		echo -e "${White}$2.$1$DE${Red}[未检测到]${Blue}	$3"
	fi
}

Sources_Download() {
	if [[ -f ${Home}/Projects/${Project}/Makefile ]];then
		MSG_SUCC "已检测到[${Project}]源代码,当前分支:[$Branch]"
		sleep 3
	else
		clear
		MSG_TITLE "${Project}源码下载-分支选择"
		Github_File=${Home}/Additional/Projects/${Project}
		Github_Source_Link=$(sed -n 1p $Github_File)
		MSG_COM "仓库地址:$Github_Source_Link\n"
		Max_All_Line=$(sed -n '$=' $Github_File)
		Max_Branch_Line=$(expr $Max_All_Line - 1)
		for ((i=2;i<=$Max_All_Line;i++));
		do
			Github_File_Branch=$(sed -n ${i}p $Github_File)
			x=$(expr $i - 1)
			echo "${x}.${Github_File_Branch}"
		done
		echo -e "\nq.返回\n"
		read -p '请从上方选择一个分支:' Choose_Branch
		case ${Choose_Branch} in
		q)
			break
		;;
		*)
			if [[ ${Choose_Branch} -le ${Max_Branch_Line} ]] 2>/dev/null ;then
				if [[ ! ${Choose_Branch} == 0 ]];then
					clear
					Branch_Line=$(expr ${Choose_Branch} + 1)
					Github_Source_Branch=$(sed -n ${Branch_Line}p $Github_File)
					echo -e "${Blue}下载地址:${Yellow}$Github_Source_Link"
					echo -e "${Blue}远程分支:${Yellow}$Github_Source_Branch\n"
					cd ${Home}/Projects
					[ -d ./${Project} ] && rm -rf ./${Project}
					MSG_WAIT "开始下载[${Project}]源代码..."
					echo
					git clone -b $Github_Source_Branch $Github_Source_Link ${Project}
					Sources_Download_Check
				else
					MSG_ERR "输入错误,请输入正确的数字!"
					sleep 2
					Sources_Download
				fi
			else
				MSG_ERR "输入错误,请输入正确的数字!"
				sleep 2
				Sources_Download
			fi
		;;
		esac
	fi
	}

Sources_Download_Check() {
	if [[ -f ${Home}/Projects/${Project}/Makefile ]];then
		cd ${Home}/Projects/${Project}
		[ ${Project} == Lede ] && sed -i "s/#src-git helloworld/src-git helloworld/g" ./feeds.conf.default
		ln -s ${Home}/Backups/dl ${Home}/Projects/${Project}/dl
		MSG_SUCC "[${Project}]源代码下载成功!"
		Enter
		Second_Menu
	else
		MSG_ERR "[${Project}]源代码下载失败!"
		Enter
	fi
}

Second_Menu_Check() {
	Project=$1
	if [[ -f ./Projects/${Project}/Makefile ]];then
		Second_Menu
	else
		if [[ $DeveloperMode == 1 ]];then
			Second_Menu
		else
			Sources_Download
		fi
	fi
}

AutoBuild_Core() {
	while :
	do
		Settings_Props
		ColorfulUI_Check
		clear
		MSG_TITLE "${AutoBuild_Title}"
		MSG_COM G "1.项目菜单"
		echo "2.网络测试"
		echo "3.高级选项"
		echo "4.脚本设置"
		echo "q.退出"
		GET_Choose
		case ${Choose} in
		q)
			rm -rf ${Home}/TEMP
			clear
			exit
		;;
		1)
		while :
		do
			clear
			MSG_TITLE "${AutoBuild_Title}"
			cd ${Home}
			MSG_COM G "项目名称		[项目状态]	维护者\n"
			DE="			"
			Project_Details Lede 1 coolsnowwolf
			DE="		"
			Project_Details Openwrt 2 Openwrt	
			Project_Details Lienol 3 Lienol
			Project_Details ImmortalWrt 4 ImmortalWrt
			MSG_COM B "\nx.更新所有源代码和Feeds"
			MSG_COM G "q.主菜单\n"
			read -p '请从上方选择一个项目:' Choose
			case ${Choose} in
			q)
				break
			;;
			x)
				timeout 3 ping -c 1 -w 2 223.5.5.5 > /dev/null 2>&1
				if [[ $? != 0 ]];then
					cd ${Home}/Projects
					Multi_Sources_Update Lede
					Multi_Sources_Update Openwrt
					Multi_Sources_Update Lienol
					Multi_Sources_Update ImmortalWrt
				else
					MSG_ERR "网络连接错误,更新失败!"
					sleep 2	
				fi
			;;
			1)
				Second_Menu_Check Lede
			;;
			2)
				Second_Menu_Check Openwrt
			;;
			3)
				Second_Menu_Check Lienol
			;;
			4)
				Second_Menu_Check ImmortalWrt
			;;
			esac
		done
		;;
		2)
			Module_Network_Test
		;;
		3)
			Advanced_Options
		;;
		4)
			Settings
		;;
		esac
	done
}

Module_Builder() {
	Build_Path=${Home}/Projects/${Project}
	[[ ${LOGNAME} == root ]] && {
		MSG_ERR "无法使用 [root] 用户进行编译!"
		sleep 3
		return 1
	}
	if [ ! -f ${Build_Path}/.config ]
	then
		MSG_ERR "未检测到[.config]文件!"
		sleep 3
		return 1
	fi
	while :
	do
		cd ${Build_Path}
		Openwrt_Repository=$(grep "https://github.com/[a-zA-Z0-9]" ${Build_Path}/.git/config | cut -c8-100 | sed 's/^[ \t]*//g')
		Openwrt_Branch=$(GET_Branch $(pwd))
		Openwrt_Author=$(echo ${Openwrt_Repository} | cut -d "/" -f4)
		Openwrt_Reponame=$(echo ${Openwrt_Repository} | cut -d "/" -f5)
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
		CPU_TEMP=$(echo "$(sensors 2> /dev/null | grep Core | awk '{Sum += $3};END {print Sum}') / $(sensors 2>/dev/null | grep Core | wc -l)" | bc 2>/dev/null)
		clear
		MSG_TITLE "AutoBuild 固件编译"
		MSG_COM G "设备信息:${CPU_Model} ${CPU_Cores} Cores ${CPU_Threads} Threads ${CPU_TEMP}\n"
		if [ -f .config ];then
			if [ -f ${Home}/Configs/${Project}_Recently_Config ];then
				echo -e "${Yellow}最近配置文件:${Blue}[$(cat ${Home}/Configs/${Project}_Recently_Config)]${White}\n"
			fi
			if [ $DIFF_CONFIG == 0 ];then
				echo -e "源码信息:${Yellow} ${Openwrt_Author}/${Openwrt_Reponame}:${Openwrt_Branch}${White}"
				echo -e "设备名称:${Yellow} ${TARGET_PROFILE}${White}"
				echo -e "CPU 架构:${Yellow} ${TARGET_BOARD}${White}"
				echo -e "CPU 型号:${Yellow} ${TARGET_SUBTARGET}${White}"
				echo -e "软件架构:${Yellow} ${TARGET_ARCH_PACKAGES}${White}"
			else
				MSG_COM R "[Diff Config] 请先执行 make defconfig !"
			fi
		else
			MSG_COM R "警告:未检测到配置文件,部分操作将不可用!"
		fi
		echo -e "${Yellow}\n1.make -j1 V=s"
		echo "2.make -j2 V=s"
		echo "3.make -j${CPU_Threads}"
		echo -e "4.make -j${CPU_Threads} V=s${White}"
		echo "5.make menuconfig"
		echo "6.make defconfig"
		echo "7.手动输入参数"
		MSG_COM G "8.高级选项"
		echo "q.返回"
		if [ -f ${Home}/Configs/${Project}_Recently_Compiled ];then
			Recently_Compiled=$(awk 'NR==1' ${Home}/Configs/${Project}_Recently_Compiled)
			Recently_Compiled_Stat=$(awk 'NR==2' ${Home}/Configs/${Project}_Recently_Compiled)
			echo -e "\n${Yellow}最近编译时间:${Blue}[${Recently_Compiled}${Recently_Compiled_Stat}]${White}"
		fi
		echo
		read -p '请从上方选择一个操作:' Choose_1
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
			Make_Menuconfig
		;;
		6)
			echo
			MSG_WAIT "正在执行 [make defconfig],请耐心等待..."
			make defconfig
		;;
		7)
			echo
			read -p '请输入编译参数:' Compile_Threads
			[[ -z "$Compile_Threads" ]] && MSG_ERR "未输入任何参数,无法执行!" && sleep 2 || {
				clear
				MSG_WAIT "即将执行自定义参数 [${Compile_Threads}]..."
				echo && ${Compile_Threads} && echo
				MSG_WAIT "自定义参数执行结束!"
				Enter
			}
		;;
		8)
			while :;do
				clear
				MSG_TITLE "AutoBuild Firmware 高级选项"
				echo "1.执行 [make kernel_menuconfig]"
				echo "2.执行 [make download]"
				echo "3.分离 [.config] > defconfig"
				echo "4.删除 [.config]"
				echo "5.更多空间清理"
				echo -e "\nq.返回"
				MSG_COM G "m.主菜单"
				GET_Choose
				case ${Choose} in
				1)
					clear
					MSG_WAIT "正在执行 [make kernel_menuconfig],请耐心等待..."
					make kernel_menuconfig
				;;
				2)
					Make_Download
				;;
				3)
					if [ -f .config ];then
						./scripts/diffconfig.sh > ${Home}/Backups/Configs/defconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)
						MSG_SUCC "新配置文件已保存到:'Backups/Configs/defconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)'"
					else
						MSG_ERR "未检测到[.config]文件!"
					fi
					sleep 2
				;;
				4)
					rm -f ${Build_Path}/.config*
					MSG_SUCC "[配置文件] 删除成功!"
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
				AutoBuild_Firmware='AutoBuild-${Openwrt_Reponame}-${TARGET_PROFILE}-${CURRENT_Version}-${FW_Boot_Type}-$(Get_SHA256 $1).${Firmware_Format_Defined}'
			;;
			*)
				AutoBuild_Firmware='AutoBuild-${Openwrt_Reponame}-${TARGET_PROFILE}-${CURRENT_Version}-$(Get_SHA256 $1).${Firmware_Format_Defined}'
			;;
			esac
			
			Firmware_Path="${Build_Path}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
			MSG_COM Y "固件信息: ${CURRENT_Version}\n"
			MSG_WAIT "开始编译 ${TARGET_PROFILE} ..."
			Compile_Date=$(date +%Y%m%d-%H:%M)
			Compile_Started=$(date +"%Y-%m-%d %H:%M:%S")
			echo "${Compile_Started}" > ${Home}/Configs/${Project}_Recently_Compiled
			if [[ ${SaveCompileLog} == 0 ]];then
				${Compile_Threads} || Compile_Failed=1
			else
				${Compile_Threads} 2>&1 | tee ${Home}/Log/BuildOpenWrt_${Project}_${Compile_Date}.log || Compile_Failed=1
			fi
			Checkout_Package
			cd ${Firmware_Path}
			SHA256_File="${Firmware_Path}/sha256sums"
			case "${TARGET_BOARD}" in
			x86)
				[[ ${Checkout_Virtual_Images} == true ]] && {
					Process_Firmware $(List_Format)
				} || {
					Process_Firmware ${Firmware_Format}
				}
			;;
			*)
				Process_Firmware ${Firmware_Format}
			;;
			esac
			[[ $(ls) =~ 'AutoBuild-' ]] && cp -a AutoBuild-* ${Build_Path}/Firmware
			Enter
		;;
		esac
	done
}

Process_Firmware() {
	while [[ $1 ]];do
		Process_Firmware_Core $1 $(List_Firmware $1)
		shift
	done
}

Process_Firmware_Core() {
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

Checkout_Package() {
	cd ${Build_Path}
	echo
	MSG_WAIT "备份当前 dl 库到'${Home}/Backups/dl' ..."
	awk 'BEGIN { cmd="cp -a ./dl/* ../../Backups/dl/"; print "n" |cmd; }' > /dev/null 2>&1
	MSG_WAIT "备份软件包到'${Home}/Packages' ..."
	cd ${Home}/Packages
	Packages_Dir=${Build_Path}/bin
	mkdir -p ${Home}/Packages/${TARGET_ARCH_PACKAGES}
	cp -a $(find ${Old_Package_Path}/packages/${TARGET_ARCH_PACKAGES} -type f -name "*.ipk") ./ > /dev/null 2>&1
	mv -f $(find ./ -type f -name "*_${TARGET_ARCH_PACKAGES}.ipk") ./${TARGET_ARCH_PACKAGES} > /dev/null 2>&1
	mv -f $(find ./ -type f -name "luci-app-*.ipk") ./luci-app-common > /dev/null 2>&1
	mv -f $(find ./ -type f -name "luci-theme-*.ipk") ./luci-theme-common > /dev/null 2>&1
	cp -a $(find ${Old_Package_Path}/targets/$TARGET_BOARD/$TARGET_SUBTARGET/ -type f -name "*.ipk") ./${TARGET_ARCH_PACKAGES} > /dev/null 2>&1
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
	MSG_SUCC "$Compile_Started --> $Compile_Ended 编译用时:$Compile_Cost分钟"
}

ExtraPackages() {
	ExtraPackages_mkdir
	while :
	do
		cd $PKG_Dir
		clear
		MSG_TITLE "Extra Packages"
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
		echo -e "\nq.返回\n"
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
			if [[ ${Project} == Lede ]];then
				PKG_URL="-b lede https://github.com/pymumu/luci-app-smartdns"
			else
				PKG_URL="https://github.com/pymumu/luci-app-smartdns"
			fi
			ExtraPackages_git
			rm -rf ${Home}/Projects/${Project}/tmp
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
		MSG_TITLE "添加第三方主题包"
		if [[ -f $PKG_Home/lean/luci-theme-argon/Makefile ]];then
			Theme_Version="$(cat $PKG_Home/lean/luci-theme-argon/Makefile | grep 'PKG_VERSION' | cut -c14-20)"
			echo -e "1.${Yellow}luci-theme-argon [${Theme_Version}]${White}"
		else
			echo "1.luci-theme-argon"
		fi
		cd $PKG_Dir
		ExtraThemesList_File=${Home}/Additional/Themes.list
		List_MaxLine=$(sed -n '$=' $ExtraThemesList_File)
		rm -f ${Home}/TEMP/Checked_Themes > /dev/null 2>&1
		for ((i=1;i<=$List_MaxLine;i++));
			do
				Theme=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
				if [[ -f $PKG_Dir/$Theme/Makefile ]];then
					if [[ $(cat $PKG_Dir/$Theme/Makefile) =~ PKG_VERSION ]];then
						GET_Version="$(cat $PKG_Dir/$Theme/Makefile | grep 'PKG_VERSION' | cut -c14-20)"
						Theme_Version=" [${GET_Version}]"
						if [[ $(cat $PKG_Dir/$Theme/Makefile) =~ PKG_RELEASE ]];then
							GET_Release="$(cat $PKG_Dir/$Theme/Makefile | grep 'PKG_RELEASE' | cut -c14-20)"
							Theme_Version=" [${GET_Version}-${GET_Release}]"
						fi
						echo -e "$(($i + 1)).${Yellow}${Theme}${Theme_Version}${White}"
					else
						echo -e "$(($i + 1)).${Yellow}${Theme}${White}"
					fi
					echo "$Theme" >> ${Home}/TEMP/Checked_Themes
				else
					echo "$(($i + 1)).${Theme}"
				fi
		done
		MSG_COM G "\na.添加所有主题包"
		MSG_COM "u.更新已安装的主题包"
		echo -e "q.返回\n"
		read -p '请从上方选择一个主题包:' Choose
		case ${Choose} in
		a)
			clear
			for ((i=1;i<=$List_MaxLine;i++));
			do
				URL_TYPE=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $1}')
				PKG_NAME=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
				PKG_URL=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $3}')
				case $URL_TYPE in
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
			if [[ -f ${Home}/TEMP/Checked_Themes ]];then
				clear
				cat ${Home}/TEMP/Checked_Themes | while read Theme
				do
					MSG_WAIT "正在更新 $Theme ..."
					cd ./$Theme
					svn update > /dev/null 2>&1
					git pull > /dev/null 2>&1
					cd ..
				done
				Enter
			else
				MSG_ERR "未安装任何主题包!"
				sleep 2
			fi
		;;
		q)
			break
		;;
		1)
			PKG_NAME=luci-theme-argon
			if [[ ${Project} == Lede ]];then
				if [ -d $PKG_Home/lean/luci-theme-argon ];then
					rm -rf $PKG_Home/lean/luci-theme-argon
				fi
				PKG_URL=" -b 18.06 https://github.com/jerrykuku/luci-theme-argon"
				ExtraPackages_git
				mv $PKG_Dir/luci-theme-argon $PKG_Home/lean/luci-theme-argon
			else
				PKG_URL="https://github.com/jerrykuku/luci-theme-argon"
				ExtraPackages_git
			fi
		;;
		*)
			if [[ ${Choose} -gt 0 ]] > /dev/null 2>&1 ;then
				if [[ $((${Choose} - 1)) -le $List_MaxLine ]] > /dev/null 2>&1 ;then
					Choose=$((${Choose} - 1))
					URL_TYPE=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $1}')
					PKG_NAME=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $2}')
					PKG_URL=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $3}')
					case $URL_TYPE in
					git)
						ExtraPackages_git
					;;
					svn)
						ExtraPackages_svn
					;;
					*)
						MSG_ERR "[第 ${Choose} 行：$URL_TYPE] 格式错误!请检查'/Additional/ExtraThemes_List'是否填写正确."
						sleep 3
					esac
				else
					MSG_ERR "输入错误,请输入正确的数字!"
					sleep 2
				fi
			else
				MSG_ERR "输入错误,请输入正确的数字!"
				sleep 2
			fi
		esac
	done
}

ExtraPackages_git() {
	[[ -d $PKG_Dir/$PKG_NAME ]] && rm -rf $PKG_Dir/$PKG_NAME
	git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
	if [[ -f $PKG_Dir/$PKG_NAME/Makefile || -f $PKG_Dir/$PKG_NAME/README.md || -n $(ls -A $PKG_Dir/$PKG_NAME) ]];then
		MSG_SUCC "[GIT] 已添加 $PKG_NAME"
	else
		MSG_ERR "[GIT] 未添加 $PKG_NAME"
	fi
	sleep 2
}

ExtraPackages_svn() {
	[[ -d $PKG_Dir/$PKG_NAME ]] && rm -rf $PKG_Dir/$PKG_NAME
	svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
	if [[ -f $PKG_Dir/$PKG_NAME/Makefile || -f $PKG_Dir/$PKG_NAME/README.md || -n $(ls -A $PKG_Dir/$PKG_NAME) ]];then
		MSG_SUCC "[SVN] 已添加 $PKG_NAME"
	else
		MSG_ERR "[SVN] 未添加 $PKG_NAME"
	fi
	sleep 2
}

ExtraPackages_mkdir() {
	PKG_Home=${Home}/Projects/${Project}/package
	[[ ! -d $PKG_Home/ExtraPackages ]] && mkdir -p $PKG_Home/ExtraPackages
	PKG_Dir=$PKG_Home/ExtraPackages
}

Module_Network_Test() {
	clear
	[[ -z ${PingMode} ]] && PingMode=httping
	[[ -z ${Home} ]] && Home=/tmp
	TMP_PATH=${Home}/TEMP
	TMP_FILE=${TMP_PATH}/NetworkTest.log
	PING_MODE=${PingMode}
	MSG_TITLE "Network Test [${PING_MODE}]"
	MSG_COM G "网址			次数	延迟/Min	延迟/Avg	延迟/Max	状态\n"

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
	[[ ! ${_COUNT} -gt 0 ]] 2>/dev/null && return
	timeout 3 ${PING_MODE} ${_URL} -c 1 > /dev/null 2>&1
	if [ $? != 0 ];then
		echo -ne "\r${Skyb}测试中...${White}\r"
		timeout ${_TIMEOUT} ${PING_MODE} ${_URL} -c ${_COUNT} > ${TMP_FILE}
		_IP=$(egrep -o "[0-9]+.[0-9]+.[0-9]+.[0-9]" ${TMP_FILE} | awk 'NR==1')
		_PING=$(egrep -o "[0-9].+/[0-9]+.[0-9]+" ${TMP_FILE})
		_PING_MIN=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==1')
		_PING_AVG=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==2')
		_PING_MAX=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==3')
		_PING_PROC=$(echo ${_PING_AVG} | egrep -o "[0-9]+" | awk 'NR==1')
		if [[ ${_PING_PROC} -le 50 ]];then
			_TYPE="${Yellow}优秀"
		elif [[ ${_PING_PROC} -le 100 ]];then
			_TYPE="${Blue}良好"
		elif [[ ${_PING_PROC} -le 200 ]];then
			_TYPE="${Skyb}一般"
		elif [[ ${_PING_PROC} -le 250 ]];then
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
	MIRROR_LIST=${Home}/Additional/SourcesList/Mirror
	CODENAME_LIST=${Home}/Additional/SourcesList/Codename
	TEMPLATE=${Home}/Additional/SourcesList/ServerUrl_Template
	BAK_FILE=${Home}/Backups/sources.list.bak

	if [[ ! -f /etc/lsb-release ]];then
		MSG_ERR "暂不支持此操作系统,当前支持的操作系统: [Ubuntu]"
		sleep 2 && return
	else
		OS_ID=$(awk -F '[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
		OS_Version=$(awk -F '[="]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
		if [[ ! ${OS_ID} == Ubuntu ]];then
			MSG_ERR "暂不支持此操作系统,当前支持的操作系统: [Ubuntu]"
			sleep 2 && return
		fi
		if [[ ! $(cat ${CODENAME_LIST} | awk '{print $1}') =~ ${OS_Version} ]];then
			MSG_ERR "暂不支持当前 [Ubuntu] 版本: [${OS_Version}]"
			echo -ne "${Red}当前支持的 [Ubuntu] 版本:"
			for CN in $(cat ${CODENAME_LIST} | awk '{print $1}')
			do
				echo -n "${CN} "
			done
			sleep 3 && return
		fi	
	fi
	while :
	do
		clear
		MSG_TITLE "Replace SourcesList"
		echo -e "${Skyb}操作系统${Yellow}: [${OS_ID} ${OS_Version}]${White}"
		Current_Server=$(egrep -o "[a-z]+[.][a-z]+[.][a-z]+" /etc/apt/sources.list | awk 'NR==1')
		echo -e "${Skyb}当前系统源${Yellow}: [${Current_Server}]${White}\n"
		if [[ -f ${MIRROR_LIST} ]];then
			Server_Count=$(sed -n '$=' ${MIRROR_LIST})
			for ((i=1;i<=${Server_Count};i++));
			do   
				ServerName=$(sed -n ${i}p ${MIRROR_LIST} | awk '{print $1}')
				echo -e "${i}.${Yellow}${ServerName}${White}"
			done
		else
			MSG_COM R "[未检测到 ${MIRROR_LIST}]"
		fi
		MSG_COM G "\nx.恢复默认源"
		MSG_COM B "u.更新软件源"
		echo "q.返回"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			if [[ -f ${BAK_FILE} ]];then
				sudo mv ${BAK_FILE} /etc/apt/sources.list
				MSG_SUCC "[默认源] 恢复成功!"
			else
				MSG_ERR "未找到备份: [${BAK_FILE}],恢复失败!"
			fi
			sleep 2
		;;
		u)
			clear
			sudo apt update
			Enter
		;;
		*)
			Choose_Server
		;;
		esac
	done
}

Choose_Server() {
	if [[ ${Choose} -gt 0 ]] > /dev/null 2>&1 ;then
		if [[ ${Choose} -le ${Server_Count} ]] > /dev/null 2>&1 ;then
			ServerUrl=$(sed -n ${Choose}p ${MIRROR_LIST} | awk '{print $2}')
			ServerName=$(sed -n ${Choose}p ${MIRROR_LIST} | awk '{print $1}')
			Codename=$(cat ${CODENAME_LIST} | grep "${OS_Version}" | awk '{print $2}')
			if [[ -z ${Codename} || -z ${ServerUrl} || -z ${ServerName} ]];then
				MSG_ERR "参数获取失败,请尝试更新 [AutoBuild] 后重试!"
			fi
			Replace_Server
		else
			MSG_ERR "输入错误,请输入正确的选项!"
			sleep 1
		fi
	fi
}

Replace_Server() {
	if [[ -f /etc/apt/sources.list ]];then
		if [[ ! -f ${BAK_FILE} ]];then
			sudo cp /etc/apt/sources.list ${BAK_FILE}
			sudo chmod 777 ${BAK_FILE}
			MSG_SUCC "未检测到备份,当前系统源已自动备份至 [${BAK_FILE}] !"
		fi
	else
		MSG_ERR "未检测到: [/etc/apt/sources.list],备份失败!"
	fi
	sudo cp ${TEMPLATE} /etc/apt/sources.list
	sudo sed -i "s?ServerUrl?${ServerUrl}?g" /etc/apt/sources.list
	sudo sed -i "s?Codename?${Codename}?g" /etc/apt/sources.list
	MSG_SUCC "系统源已切换到: [${ServerName}]"
	sleep 2
}

Settings() {
	while :
	do
		Settings_Props
		ColorfulUI_Check
		clear
		MSG_TITLE "脚本设置[实验性]"
		if [[ $ColorfulUI == 0 ]];then
			MSG_COM  R "1.彩色 UI		[关闭]"
		else
			MSG_COM Y "1.彩色 UI		[打开]"
		fi
		if [[ $DeveloperMode == 0 ]];then
			MSG_COM  R "2.调试模式		[关闭]"
		else
			MSG_COM Y "2.调试模式		[打开]"
		fi
		if [[ $SaveCompileLog == 0 ]];then
			MSG_COM  R "3.保存编译日志		[关闭]"
		else
			MSG_COM Y "3.保存编译日志		[打开]"
		fi
		if [[ $PingMode == httping ]];then
			MSG_COM  B "4.Ping Mode		[httping]"
		else
			MSG_COM Y "4.Ping Mode		[ping]"
		fi
		MSG_COM G "\nx.恢复所有默认设置"
		echo "q.返回"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			Set_Default_Settings
		;;
		1)
			if [[ $ColorfulUI == 0 ]];then
				ColorfulUI=1
				sed -i "s/ColorfulUI=0/ColorfulUI=1/g" ./Settings
			else
				ColorfulUI=0
				sed -i "s/ColorfulUI=1/ColorfulUI=0/g" ./Settings
			fi
		;;
		2)
			if [[ $DeveloperMode == 0 ]];then
				DeveloperMode=1
				sed -i "s/DeveloperMode=0/DeveloperMode=1/g" ./Settings
			else
				DeveloperMode=0
				sed -i "s/DeveloperMode=1/DeveloperMode=0/g" ./Settings
			fi
		;;
		3)
			if [[ $SaveCompileLog == 0 ]];then
				SaveCompileLog=1
				sed -i "s/SaveCompileLog=0/SaveCompileLog=1/g" ./Settings
			else
				SaveCompileLog=0
				sed -i "s/SaveCompileLog=1/SaveCompileLog=0/g" ./Settings
			fi
		;;
		4)
			if [[ $PingMode == httping ]];then
				PingMode=ping
				sed -i "s/PingMode=httping/PingMode=ping/g" ./Settings
			else
				PingMode=httping
				sed -i "s/PingMode=ping/PingMode=httping/g" ./Settings
			fi
		;;
		esac
	done
}

Default_Settings() { 
	DeveloperMode=0
	ColorfulUI=1
	SaveCompileLog=0
	PingMode=httping
}

Set_Default_Settings() {
	Default_Settings
	echo "DeveloperMode=$DeveloperMode" > ${Home}/Configs/Settings
	echo "ColorfulUI=$ColorfulUI" >> ${Home}/Configs/Settings
	echo "SaveCompileLog=$SaveCompileLog" >> ${Home}/Configs/Settings
	echo "PingMode=$PingMode" >> ${Home}/Configs/Settings
}

Settings_Props() {
	cd ${Home}/Configs
	if [[ ! -f ${Home}/Configs/Settings ]];then
		Set_Default_Settings
	else
		source ${Home}/Configs/Settings
	fi
}

ColorfulUI_Check() {
	if [[ $ColorfulUI == 1 ]];then
		White="\e[0m"
		Yellow="\e[33m"
		Red="\e[31m"
		Blue="\e[34m"
		Skyb="\e[36m"
	else
		White="\e[0m"
		Yellow="\e[0m"
		Red="\e[0m"
		Blue="\e[0m"
		Skyb="\e[0m"
	fi
}

MSG_COM() {
	if [[ $# -gt 1 ]];then
		case $1 in
		Y)
			MSG_Color=${Yellow}
		;;
		R)
			MSG_Color=${Red}
		;;
		B)
			MSG_Color=${Blue}
		;;
		G)
			MSG_Color=${Skyb}
		;;
		esac
		echo -e "${MSG_Color}${2}${White}"
	else
		echo -e "${Yellow}${*}${White}"
	fi
}

MSG_WAIT() {
	echo -e "${Blue}${*}${White}"
}

MSG_ERR() {
	echo -e "\n${Red}${*}${White}"
}

MSG_SUCC() {
	echo -e "\n${Yellow}${*}${White}"
}

MSG_TITLE() {
	echo -e "${Blue}${*}${White}\n"
}

GET_Choose() {
	echo -e "${White}"
	read -p '请从上方选择一个操作:' Choose
}

Enter() {
	echo -e "${White}"
	read -p "按下[回车]键以继续..." Key
}

Decoration() {
	echo -ne "${Skyb}"
	printf "%-70s\n" "-" | sed 's/\s/-/g'
	echo -ne "${White}"
}

Module_SSHServices() {
	while :;do
		clear
		MSG_TITLE "SSH Services"
		List_SSHProfile
		MSG_COM G "\nn.创建新配置文件"
		[[ -n $(ls -A ${Home}/Configs/SSH) ]] && MSG_COM R "d.删除所有配置文件"
		echo "x.重置 [RSA Key Fingerprint]"
		echo -e "q.返回\n"
		read -p '请从上方选择一个操作:' Choose
		case ${Choose} in
		q)
			return 0
		;;
		n)
			Create_SSHProfile
		;;
		d)
			rm -f ${Home}/Configs/SSH/*  > /dev/null 2>&1
			MSG_SUCC "已删除所有 [SSH] 配置文件!"
			sleep 2
		;;
		x)
			rm -rf ~/.ssh
			MSG_SUCC "[SSH] [RSA Key Fingerprint] 重置成功!"
			sleep 2
		;;
		*)
			if [[ ${Choose} -gt 0 ]] > /dev/null 2>&1 ;then
				if [[ ${Choose} -le $SSHProfileList_MaxLine ]] > /dev/null 2>&1 ;then
					SSHProfile_File="${Home}/Configs/SSH/$(sed -n ${Choose}p ${SSHProfileList})"
					Module_SSHServices_Menu
				else
					MSG_ERR "[SSH] 输入错误,请输入正确的数字!"
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
		echo -e "${Blue}配置文件:${Yellow}[$SSHProfile_File]${White}"
		echo -e "${Blue}连接参数:${Yellow}[ssh ${SSH_User}@${SSH_IP} -p ${SSH_Port}: ${SSH_Password}]${White}\n"
		MSG_COM "1.连接到 SSH"
		echo "2.编辑配置"
		echo "3.重命名配置"
		echo "4.修改密码"
		MSG_COM R "5.删除此配置文件"
		echo "6.重置[RSA Key Fingerprint]"
		echo -e "\nq.返回"
		GET_Choose
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
				if [[ -z $SSH_Password ]];then
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
			if [[ ! -z "$SSHProfile_RN" ]];then
				cd ${Home}/Configs/SSH
				mv "$SSHProfile_File" "$SSHProfile_RN" > /dev/null 2>&1
				MSG_SUCC "重命名 [$SSHProfile_File] > [$SSHProfile_RN] 成功!"
				SSHProfile_File="$SSHProfile_RN"
			else
				MSG_ERR "[SSH] 配置名称不能为空!"
			fi
			sleep 2
		;;
		4)
			echo
			read -p '[SSH] 请输入新的密码:' SSH_Password
			sed -i '/SSH_Password/d' "$SSHProfile_File"
			echo "SSH_Password=$SSH_Password" >> "$SSHProfile_File"
			MSG_SUCC "[SSH] 配置文件已保存!"
			sleep 2
		;;
		5)
			rm -f "$SSHProfile_File"
			MSG_SUCC "[SSH] 配置文件 [$SSHProfile_File] 删除成功!"
			sleep 2
			break
		;;
		6)
			ssh-keygen -R $SSH_IP > /dev/null 2>&1
			MSG_SUCC "[SSH] [RSA Key Fingerprint] 重置成功!"
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
		MSG_ERR "[SSH] 已存在相同名称的配置文件!"
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
		MSG_ERR "[SSH] 用户名不能为空!"
		echo
		read -p '[SSH] 请输入用户名:' SSH_User
	done
	read -p '[SSH] 请输入密码:' SSH_Password
	echo "SSH_IP=$SSH_IP" > "$SSH_Profile"
	echo "SSH_Port=$SSH_Port" >> "$SSH_Profile"
	echo "SSH_User=$SSH_User" >> "$SSH_Profile"
	echo "SSH_Password=$SSH_Password" >> "$SSH_Profile"
	MSG_SUCC "[SSH] 配置文件已保存到 '$SSH_Profile'"
	sleep 2
	SSH_Login
}

List_SSHProfile() {
	if [[ -n $(ls -A ${Home}/Configs/SSH) ]];then
		cd ${Home}/Configs/SSH
		echo "$(ls -A)" > ${Home}/TEMP/SSHProfileList
		SSHProfileList=${Home}/TEMP/SSHProfileList
		SSHProfileList_MaxLine=$(sed -n '$=' $SSHProfileList)
		MSG_COM G "配置文件列表"
		echo
		for ((i=1;i<=$SSHProfileList_MaxLine;i++));
		do   
			SSHProfile=$(sed -n ${i}p $SSHProfileList)
			echo -e "${i}.${Yellow}${SSHProfile}${White}"
		done
	else
		MSG_COM R "[未检测到任何配置文件]"
	fi
}

SSH_Login() {
	clear
	echo -e "${Blue}连接参数:${Yellow}[ssh ${SSH_User}@${SSH_IP} -p ${SSH_Port}]${White}\n"
	expect -c "
	set timeout 1
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
	MSG_TITLE "System info"
	Decoration
	echo -e "${Skyb}操作系统${Yellow}		${Short_OS}"
	echo -e "${Skyb}系统版本${Yellow}		${OS_INFO}"
	echo -e "${Skyb}计算机名称${Yellow}		${Computer_Name}"
	echo -e "${Skyb}登陆用户名${Yellow}		${USER}"
	echo -e "${Skyb}内核版本${Yellow}		${Kernel_Version}"
	echo -e "${Skyb}物理内存${Yellow}		${MemTotal_GB}GB/${MemTotal_MB}MB"
	echo -e "${Skyb}可用内存${Yellow}		${MemFree_GB}GB/${MemFree}MB"
	echo -e "${Skyb}CPU 型号${Yellow}		${CPU_Model}"
	echo -e "${Skyb}CPU 频率${Yellow}		${CPU_Freq}"
	echo -e "${Skyb}CPU 架构${Yellow}		${CPU_Info}"
	echo -e "${Skyb}CPU 核心数量${Yellow}		${CPU_Cores}"
	echo -e "${Skyb}CPU 当前频率${Yellow}		${Current_Freq}MHz"
	echo -e "${Skyb}CPU 当前温度${Yellow}		${Current_Temp}"
	echo -e "${Skyb}IP地址${Yellow}			${IP_Address}"
	echo -e "${Skyb}开机时长${Yellow}		${Computer_Startup}"
	Decoration
	Enter
}

GET_System_Info() {
	case $1 in
	1)
		CPU_Model=$(awk -F ':[ ]' '/model name/{printf ($2);exit}' /proc/cpuinfo)
		CPU_Cores=$(cat /proc/cpuinfo | grep processor | wc -l)
		CPU_Threads=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
		CPU_Freq=$(awk '/model name/{print ""$NF;exit}' /proc/cpuinfo)
		Get_OS() {
			[[ -f /etc/redhat-release ]] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
			[[ -f /etc/os-release ]] && awk -F '[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
			[[ -f /etc/lsb-release ]] && awk -F '[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
		}
		OS_INFO=$(Get_OS)
		Short_OS=$(echo ${OS_INFO} | awk '{print $1}')
		System_Bit=$(getconf LONG_BIT)
		CPU_Base=$(uname -m)
		[[ -z ${CPU_Base} ]] && CPU_Info="${System_Bit}" || CPU_Info="${System_Bit} (${CPU_Base} Bit)"
		Computer_Name=$(hostname)
		MemTotal_MB=$(free -m | awk '{print $2}' | awk 'NR==2')
		MemTotal_GB=$(echo "scale=1; $MemTotal_MB / 1000" | bc)
	;;
	2)
		Current_Freq=$(awk -F '[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo)
		Current_Temp=$(sensors | grep 'Core 0' | cut -c17-24)
		Kernel_Version=$(uname -r)
		Computer_Startup=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d 天 %d 小时 %d 分钟\n",a,b,c)}' /proc/uptime)
		IP_Address=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | awk 'NR==1')
		MemFree=$(free -m | awk '{print $7}' | awk 'NR==2')
		MemFree_GB=$(echo "scale=1; $MemFree / 1000" | bc)
	;;
	esac
}

Home=$(cd $(dirname $0); pwd)

for RunPath in $(cat ${Home}/Additional/Dir.list);do
	[[ ! -d ${Home}/${RunPath} ]] && mkdir -p ${Home}/${RunPath}
done

GET_System_Info 1
Dependency="build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync"
Extra_Dependency="ntpdate httping ssh lm-sensors net-tools expect inetutils-ping"

AutoBuild_Title="AutoBuild Core Script $Version [${Short_OS}] [${LOGNAME}]"
AutoBuild_Core
