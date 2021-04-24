#!/bin/bash
# Project	AutoBuild
# Author	Hyy2001、Nxiz
# Github	https://github.com/Hyy2001X/AutoBuild
# Supported System:Ubuntu 16.04-20.10 LTS、Deepin 20
Update=2021.4.24
Version=V4.3.2

Second_Menu() {
while :
do
	clear
	if [ -f $Home/Projects/$Project/Makefile ];then
		MSG_COM "源码位置:$Home/Projects/$Project"
		if [ $Project == Lede ];then
			if [ -f $Home/Projects/$Project/package/lean/default-settings/files/zzz-default-settings ];then
				cd $Home/Projects/$Project/package/lean/default-settings/files
				Lede_Version=$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" ./zzz-default-settings)
				MSG_COM "源码版本:$Lede_Version"
			fi
		fi
		cd $Home
		if [ -f ./Configs/${Project}_Recently_Updated ];then
			Recently_Updated=$(cat ./Configs/${Project}_Recently_Updated)
			MSG_COM "最近更新:$Recently_Updated"
		fi
		cd $Home/Projects/$Project
		Branch=$(git branch | sed 's/* //g')
	else
		MSG_COM R "警告:未检测到[$Project]源码,请前往[高级选项]下载!"
	fi
	echo ""
	echo "1.更新源代码和Feeds"
	echo "2.打开固件配置菜单"
	echo "3.备份与恢复"
	echo "4.编译选项"
	echo "5.高级选项"
	MSG_COM G "\nm.主菜单"
	echo "q.返回"
	GET_Choose
	case $Choose in
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
		BuildFirmware_Check
	;;
	5)
		Project_Options
	esac
done
}

Project_Options() {
while :
do
	cd $Home/Projects/$Project
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
	case $Choose in
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
		rm -f $Home/Projects/$Project/.config*
		MSG_SUCC "[配置文件] 删除成功!"
		sleep 2
	;;
	7)
		Make_Download
	;;
	8)
		clear
		if [ -d $Home/Projects/$Project/.git ];then
			cd $Home/Projects/$Project
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
	echo "3.备份[$Project]源代码"
	echo "4.恢复[$Project]源代码"
	MSG_COM G "5.链接[dl]库"
	echo -e "\nq.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
	while :
	do
		cd $Home
		clear
		MSG_TITLE "备份[.config]"
		if [ $Project == Lede ];then
			echo -e "1.标准名称/${Yellow}文件格式:[$Project-版本号-日期_时间]${White}"
		else
			echo -e "1.标准名称/${Yellow}文件格式:[$Project-日期_时间]${White}"
		fi
		echo "2.自定义名称"
		echo -e "\nq.返回"
		GET_Choose
		case $Choose in
		q)
			break
		;;
		1)
			if [ $Project == Lede ];then
				Backup_Config=$Project-$Lede_Version-$(date +%m%d_%H:%M)
			else
				Backup_Config=$Project-$(date +%m%d_%H:%M)
			fi	
			if [ -f ./Projects/$Project/.config ];then
				cp ./Projects/$Project/.config ./Backups/Configs/$Backup_Config
				MSG_SUCC "备份成功![.config] 已备份到:'/Backups/Configs/$Backup_Config'"
			else
				MSG_ERR "[.config] 备份失败!"
			fi
		;;
		2)
			read -p '请输入自定义名称:' Backup_Config
			if [ -f ./Projects/$Project/.config ];then
				cp ./Projects/$Project/.config ./Backups/Configs/"$Backup_Config"
				MSG_SUCC "备份成功![.config] 已备份到:'/Backups/Configs/$Backup_Config'"
			else
				MSG_ERR "[.config] 备份失败!"
			fi
		;;
		esac
		sleep 2
	done
	;;
	2)
	if [ ! -z "$(ls -A $Home/Backups/Configs)" ];then
	while :
	do
		clear
		MSG_TITLE "恢复[.config]"
		cd $Home/Backups/Configs
		ls -A | cat > $Home/TEMP/Config.List
		ConfigList_File=$Home/TEMP/Config.List
		Max_ConfigList_Line=$(sed -n '$=' $ConfigList_File)
		for ((i=1;i<=$Max_ConfigList_Line;i++));
		do
			ConfigFile_Name=$(sed -n ${i}p $ConfigList_File)
			echo -e "${i}.${Yellow}${ConfigFile_Name}${White}"
		done
		echo -e "\nq.返回\n"
		read -p '请从上方选择一个文件:' Choose
		case $Choose in
		q)
			break
		;;
		*)
			if [ $Choose -le $Max_ConfigList_Line ] 2>/dev/null ;then
				if [ ! $Choose == 0 ] 2>/dev/null ;then
					ConfigFile=$(sed -n ${Choose}p $ConfigList_File)
					if [ -f "$ConfigFile" ];then
						ConfigFile_Dir="$Home/Backups/Configs/$ConfigFile"
						cp "$ConfigFile_Dir" $Home/Projects/$Project/.config
						echo "$ConfigFile" > $Home/Configs/${Project}_Recently_Config
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
		MSG_WAIT "正在备份[$Project]源代码..."
		[ ! -d $Home/Backups/Projects/$Project ] && mkdir -p $Home/Backups/Projects/$Project
		cd $Home/Backups/Projects/$Project
		for LB in $(cat $Home/Additional/Backup_List)
		do
			cp -a $Home/Projects/$Project/$LB ./
		done
		chmod 777 -R $Home/Backups/Projects/$Project
		MSG_SUCC "备份成功![$Project]源代码已备份到:'Backups/Projects/$Project'"
		MSG_SUCC "存储占用:$(du -sh $Home/Backups/Projects/$Project | awk '{print $1}')B"
		Enter
	;;
	4)
		if [ -f $Home/Backups/Projects/$Project/Makefile ];then
			echo ""
			MSG_WAIT "正在恢复[$Project]源代码..."
			cp -a $Home/Backups/Projects/$Project $Home/Projects/ > /dev/null 2>&1
			MSG_SUCC "恢复成功![$Project]源代码已恢复到:'Projects/$Project'"
			Enter
		else
			MSG_ERR "未找到备份文件,恢复失败!"
			sleep 2
		fi
	;;
	5)
		cd $Home/Projects
		if [ ! -h ./$Project/dl ];then
			[ -d ./$Project/dl ] && mv -f ./$Project/dl/* $Home/Backups/dl
			rm -rf ./$Project/dl
			ln -s $Home/Backups/dl $Home/Projects/$Project/dl
		fi
		MSG_SUCC "已创建链接:'$Home/Backups/dl' -> '$Home/Projects/$Project/dl'"
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
	echo "5.存储空间统计"
	echo "6.快捷指令启动"
	echo "7.系统信息"
	echo "8.系统下载源"
	MSG_COM "\nx.更新脚本"
	MSG_COM G "q.主菜单"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	x)
		AutoBuild_Updater
	;;
	1)
		clear
		sudo apt-get update
		sudo apt-get upgrade
		sudo apt-get clean
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
		done
		sudo apt-get clean
		Enter
	;;
	3)
		SSHServices
	;;
	4)
		echo ""
		sudo ntpdate ntp1.aliyun.com
		sudo hwclock --systohc
		sleep 2
	;;
	5)
		StorageDetails
	;;
	6)
		echo ""
		read -p '请输入快速启动的指令:' FastOpen		
		echo "alias $FastOpen='$Home/AutoBuild.sh'" >> ~/.bashrc
		source ~/.bashrc
		MSG_SUCC "创建成功!在终端输入 $FastOpen 即可启动 AutoBuild [需要重启终端]."
		sleep 3
	;;
	7)
		Systeminfo
	;;
	8)
		ReplaceSourcesList
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
	MSG_COM R "4.删除 [$Project] 项目"
	echo "5.清理 [临时文件/编译缓存]"
	echo "6.清理 [更新日志]"
	echo "7.清理 [编译日志]"
	echo "q.返回"
	GET_Choose
	cd $Home/Projects/$Project
	case $Choose in
	q)
		break
	;;
	1)
		echo ""
		MSG_WAIT "正在执行[make clean],请耐心等待..."
		make clean > /dev/null 2>&1
	;;
	2)
		echo ""
		MSG_WAIT "正在执行[make dirclean],请耐心等待..."
		make dirclean > /dev/null 2>&1
	;;
	3)
		echo ""
		MSG_WAIT "正在执行[make distclean],请耐心等待..."
		make distclean > /dev/null 2>&1
	;;
	4)
		echo ""
		MSG_WAIT "正在删除[$Project],请耐心等待..."
		rm -rf $Home/Projects/$Project/*
		rm -f $Home/Configs/${Project}_Recently_*
		rm -f $Home/Log/*_${Project}_*
	;;
	5)
		rm -rf $Home/Projects/$Project/tmp
		MSG_SUCC "[临时文件/编译缓存] 删除成功!"
	;;
	6)
		rm -f $Home/Log/SourceUpdate_${Project}_*
		MSG_SUCC "[更新日志] 删除成功!"
	;;
	7)
		rm -f $Home/Log/BuildOpenWrt_${Project}_*
		MSG_SUCC "[编译日志] 删除成功!"
	;;
	esac
	sleep 2
done
}

AutoBuild_Updater() {
timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	clear
	MSG_WAIT "正在更新[AutoBuild],请耐心等待..."
	cd $Home/Backups
	if [ -z "$(ls -A ./AutoBuild-Update)" ];then
		git clone https://github.com/Hyy2001X/AutoBuild AutoBuild-Update
	fi
	cd ./AutoBuild-Update
	Update_Logfile=$Home/Log/Script_Update_$(date +%Y%m%d_%H:%M).log
	git pull 2>&1 | tee $Update_Logfile || Update_Failed=1
	if [ -z ${Update_Failed} ];then
		MSG_COM "\n合并到本地文件..."
		Old_Version=$(awk 'NR==7' $Home/AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}')
		Old_Version_Dir=$Old_Version-$(date +%Y%m%d_%H:%M)
		Backups_Dir=$Home/Backups/OldVersion/AutoBuild-Core-$Old_Version_Dir
		[ -d $Backups_Dir ] && rm -rf $Backups_Dir
		mkdir -p $Backups_Dir
		mv $Home/AutoBuild.sh $Backups_Dir/AutoBuild.sh
		mv $Home/README.md $Backups_Dir/README.md
		mv $Home/LICENSE $Backups_Dir/LICENSE
		mv $Home/Additional $Backups_Dir/Additional 2>/dev/null 
		mv $Home/Modules $Backups_Dir/Modules
		cp -a * $Home
		MSG_SUCC "[AutoBuild] 更新成功!"
		Enter
		$Home/AutoBuild.sh
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
if [ -f $Home/Projects/$Project/Makefile ];then
	timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
	if [ $? -eq 0 ];then
		Sources_Update_Core
		read -p "" Key
	else
		MSG_ERR "网络连接错误,[$Project]源代码更新失败!"
		sleep 2
	fi
else
	MSG_ERR "未检测到[$Project]源代码,更新失败!"
	sleep 2
fi
}

Make_Download() {
if [ -f $Home/Projects/$Project/.config ];then
	timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
	if [ $? -eq 0 ];then
		cd $Home/Projects/$Project
		clear
		MSG_WAIT "开始执行 [make download]..."
		echo ""
		dl_Logfile=$Home/Log/dl_${Project}_$(date +%Y%m%d_%H:%M).log
		if [ -d dl ];then
			mv dl/* $Home/Backups/dl > /dev/null 2>&1
			rm -rf dl
		fi
		ln -s $Home/Backups/dl $Home/Projects/$Project/dl > /dev/null 2>&1
		make -j$CPU_Threads download V=s 2>&1 | tee -a $dl_Logfile
		find dl -size -1024c -exec rm -f {} \;
		ln -s $Home/Backups/dl $Home/Projects/$Project/dl > /dev/null 2>&1
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
	cd $Home/Projects/$Project
	MSG_COM B "Loading $Project Configuration..."
	make menuconfig
	Enter
}

Sources_Update_Core() {
	clear
	MSG_WAIT "开始更新[$Project],请耐心等待..."
	echo ""
	echo "$(date +%Y-%m-%d_%H:%M)" > $Home/Configs/${Project}_Recently_Updated
	cd $Home/Projects/$Project
	if [ $Enforce_Update == 1 ];then
		git fetch --all
		git reset --hard origin/$Branch
		if [ $Project == Lede ];then
			sed -i "s/#src-git helloworld/src-git helloworld/g" ./feeds.conf.default
		fi
	fi
	Update_Logfile=$Home/Log/SourceUpdate_${Project}_$(date +%Y%m%d_%H:%M).log
	git pull 2>&1 | tee $Update_Logfile
	./scripts/feeds update -a 2>&1 | tee -a $Update_Logfile
	./scripts/feeds install -a 2>&1 | tee -a $Update_Logfile
	MSG_SUCC "[源代码和Feeds]更新结束!"
}

Multi_Sources_Update() {
	if [ -f $Home/Projects/$1/Makefile ];then
		Project=$1
		Enforce_Update=0
		Sources_Update_Core
		sleep 2
	fi
}

Project_Details() {
	if [ -f ./Projects/$1/Makefile ];then
		echo -e "${White}$2.$1$DE${Yellow}[已检测到]${Blue}	$3"
	else
		echo -e "${White}$2.$1$DE${Red}[未检测到]${Blue}	$3"
	fi
}

Sources_Download() {
if [ -f $Home/Projects/$Project/Makefile ];then
	MSG_SUCC "已检测到[$Project]源代码,当前分支:[$Branch]"
	sleep 3
else
	clear
	MSG_TITLE "$Project源码下载-分支选择"
	Github_File=$Home/Additional/Projects/GitLink_$Project
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
	case $Choose_Branch in
	q)
		break
	;;
	*)
		if [ $Choose_Branch -le $Max_Branch_Line ] 2>/dev/null ;then
			if [ ! $Choose_Branch == 0 ];then
				clear
				Branch_Line=$(expr $Choose_Branch + 1)
				Github_Source_Branch=$(sed -n ${Branch_Line}p $Github_File)
				echo -e "${Blue}下载地址:${Yellow}$Github_Source_Link"
				echo -e "${Blue}远程分支:${Yellow}$Github_Source_Branch\n"
				cd $Home/Projects
				[ -d ./$Project ] && rm -rf ./$Project
				MSG_WAIT "开始下载[$Project]源代码..."
				echo ""
				git clone -b $Github_Source_Branch $Github_Source_Link $Project
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
	if [ -f $Home/Projects/$Project/Makefile ];then
		cd $Home/Projects/$Project
		[ $Project == Lede ] && sed -i "s/#src-git helloworld/src-git helloworld/g" ./feeds.conf.default
		ln -s $Home/Backups/dl $Home/Projects/$Project/dl
		MSG_SUCC "[$Project]源代码下载成功!"
		Enter
		Second_Menu
	else
		MSG_ERR "[$Project]源代码下载失败!"
		Enter
	fi
}

Dir_Check() {
	cd $Home
	for WD in $(cat ./Additional/Working_Directory)
	do
	[ ! -d ./$WD ] && mkdir -p $WD
	done
	touch $Home/Log/AutoBuild.log
}

Startup_Check() {
	if [ ! -f $Home/Configs/Username ];then
		read -p '首次启动,请创建一个用户名:' Username
		echo "$Username" > $Home/Configs/Username
	else
		Username=$(cat $Home/Configs/Username)
	fi
}

Second_Menu_Check() {
	Project=$1
	if [ -f ./Projects/$Project/Makefile ];then
		Second_Menu
	else
		if [ $DeveloperMode == 1 ];then
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
	MSG_COM G "1.Get Started!"
	echo "2.网络测试"
	echo "3.高级选项"
	echo "4.脚本设置"
	echo "q.退出"
	GET_Choose
	case $Choose in
	q)
		rm -rf $Home/TEMP
		clear
		exit
	;;
	1)
	while :
	do
		clear
		MSG_TITLE "${AutoBuild_Title}"
		cd $Home
		MSG_COM G "项目名称		[项目状态]	维护者\n"
		DE="			"
		Project_Details Lede 1 coolsnowwolf
		DE="		"
		Project_Details Openwrt 2 Openwrt	
		Project_Details Lienol 3 Lienol
		Project_Details ImmortalWrt 4 "Project ImmortalWrt"
		MSG_COM B "\nx.更新所有源代码和Feeds"
		MSG_COM G "q.主菜单\n"
		read -p '请从上方选择一个项目:' Choose
		case $Choose in
		q)
			break
		;;
		x)
			timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
			if [ $? -eq 0 ];then
				cd $Home/Projects
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
		Network_Test
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

Home=$(cd $(dirname $0); pwd)

echo "Loading all AutoBuild modules ..."
chmod +x -R $Home/Modules
for Module in $Home/Modules/*.sh
do
	source $Module
done

GET_System_Info 1
AutoBuild_Title="AutoBuild Core Script $Version [${Short_OS}]"
Dependency="$(cat $Home/Additional/Depends_Openwrt)"
Extra_Dependency="ntpdate httping ssh lm-sensors net-tools expect inetutils-ping"

Dir_Check
Startup_Check
AutoBuild_Core
