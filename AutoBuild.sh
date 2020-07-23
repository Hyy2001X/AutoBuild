#!/bin/bash
# Project	AutoBuild
# Author	Hyy2001
# Github	https://github.com/Hyy2001X/AutoBuild
# Supported System:Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04、Deepin 20 Beta
Update=2020.07.23
Version=V3.7.2

Second_Menu() {
while :
do
	clear
	Dir_Check
	if [ -f ./Projects/$Project/Makefile ];then
		Say="项目位置:$Home/Projects/$Project" && Color_Y
		if [ $Project == Lede ];then
			if [ -f ./Projects/$Project/package/lean/default-settings/files/zzz-default-settings ];then
				cd ./Projects/$Project/package/lean/default-settings/files
				Lede_Version=`egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" zzz-default-settings`
				Say="源码版本:$Lede_Version" && Color_Y
			fi
		fi
	else
		Say="未检测到[$Project]源码,请前往[高级选项]下载!" && Color_R
	fi
	cd $Home
	if [ -f ./Configs/${Project}_Lasted_Update ];then
		Lasted_Update=`cat ./Configs/${Project}_Lasted_Update`
		echo -e "$Blue最近更新:$Lasted_Update$White"
	fi
	cd $Home/Projects/$Project
	Branch=`git branch | sed 's/* //g'`
	echo " "
	echo "1.更新源代码和Feeds"
	echo "2.打开固件配置菜单"
	echo "3.备份与恢复"
	echo "4.编译选项"
	echo "5.高级选项"
	echo " "
	echo "m.主菜单"
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
		Sources_Update
	;;
	2)
		Make_Menuconfig
	;;
	3)
		Backup_Recovery
	;;
	4)
		SimpleCompilation_Check
	;;
	5)
		Advanced_Options_2
	;;
	esac
done
}

Sources_Download() {
cd $Home
if [ -f ./Projects/$Project/Makefile ];then
	echo " "
	Say="已检测到$Project源代码,无需下载!" && Color_Y
	Say="当前源代码分支:$Branch" && Color_Y
	sleep 2
else
	clear
	cd $Home/Projects
	Say="$Project源代码下载-选择内核" && Color_B
	if  [ $Project == Lede ];then
	while :
	do
		Say="仓库地址1:$Lede_Git" && Color_Y
		Say="仓库地址2:$Lede_Old_Git" && Color_Y
		echo " "
		Branch_1="内核版本 5.4.x "
		Branch_2="内核版本 4.14.x"
		echo "1.$Branch_1"
		echo "2.$Branch_2"
		echo "q.返回"
		echo " "
		read -p '请从上方选择一个内核:' Choose
		clear
		case $Choose in
		q)
			break
		;;
		1)
			git clone $Lede_Git $Project
		;;
		2)
			git clone -b lede-17.01 $Lede_Old_Git $Project
		;;
		esac
		Sources_Download_Check
		break
	done
	elif [ $Project == Openwrt ];then
	while :
	do
		Say="仓库地址:$Openwrt_Git" && Color_Y
		echo " "
		Branch_1=master
		Branch_2=lede-17.01
		Branch_3=openwrt-18.06
		Branch_4=openwrt-19.07
		echo "1.$Branch_1[默认]"
		echo "2.$Branch_2"
		echo "3.$Branch_3"
		echo "4.$Branch_4"
		echo "q.返回"
		echo " "
		read -p '请从上方选择一个分支:' Choose
		clear
		case $Choose in
		q)
			break
		;;
		1)
			git clone $Openwrt_Git $Project
		;;
		2)
			git clone -b $Branch_2 $Openwrt_Git $Project
		;;
		3)
			git clone -b $Branch_3 $Openwrt_Git $Project
		;;
		4)
			git clone -b $Branch_4 $Openwrt_Git $Project
		;;
		esac
		Sources_Download_Check
		break
	done
	elif [ $Project == Lienol ];then			
	while :
	do
		Say="仓库地址:$Lienol_Git" && Color_Y
		echo " "
		Branch_1=dev-master
		Branch_2=dev
		Branch_3=dev-19.07
		echo "1.$Branch_1[推荐]"
		echo "2.$Branch_2"
		echo "3.$Branch_3"
		echo "q.返回"
		echo " "
		read -p '请从上方选择一个分支:' Choose
		clear
		case $Choose in
		q)
			break
		;;
		1)
			Branch=$Branch_1
		;;
		2)
			Branch=$Branch_2
		;;
		3)
			Branch=$Branch_3
		esac
		git clone -b $Branch $Lienol_Git $Project
		Sources_Download_Check
		break
	done
	fi
fi
}

Advanced_Options_2() {
while :
do
	cd $Home/Projects/$Project
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.下载源代码"
	echo "2.强制更新源代码和Feeds"
	echo "3.添加第三方主题"
	echo "4.添加软件包"
	echo "5.空间清理"
	echo "6.删除配置文件"
	echo "7.下载[dl]库"
	echo " "
	echo "m.主菜单"
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
		Sources_Update
	;;
	3)
		ExtraThemes
	;;
	4)
		ExtraPackages
	;;
	5)
	while :
	do
		clear
		Say="空间清理" && Color_B
		echo " "
		echo "1.make clean"
		echo "2.make dirclean"
		echo "3.make distclean"
		Say="4.删除[$Project]项目" && Color_R
		echo "5.清理[临时文件/编译缓存]"
		echo "6.清理[更新日志]"
		echo "7.清理[编译日志]"
		echo "q.返回"
		GET_Choose
		cd $Home/Projects/$Project
		case $Choose in
		q)
			break
		;;
		1)	
			make clean
		;;
		2)
			make dirclean
		;;
		3)
			make distclean
		;;
		4)
			cd $Home/Projects
			echo " "
			Say="正在删除$Project..." && Color_B
			echo " "
			rm -rf $Project
			if [ ! -d ./$Project ];then
				Say="删除成功!" && Color_Y
			else 
				Say="删除失败!" && Color_R
			fi
		;;
		5)
			echo " "
			rm -rf $Home/Projects/$Project/tmp
			Say="$Yellow[临时文件/编译缓存]删除成功!" && Color_Y
		;;
		6)
			echo " "
			rm -f $Home/Log/Update_${Project}_*
			Say="$Yellow[更新日志]删除成功!" && Color_Y
		;;
		7)
			echo " "
			rm -f $Home/Log/Compile_${Project}_*
			Say="$Yellow[编译日志]删除成功!" && Color_Y
		;;
		esac
		sleep 2
	done
	;;
	6)
		cd $Home/Projects/$Project
		rm -f ./.config*
		echo " "
		Say="[配置文件]删除成功!" && Color_Y
		sleep 2
	;;
	7)
		echo " "
		timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
		if [ $? -eq 0 ];then
			clear
			make -j$CPU_Threads download V=s
			find dl -size -1024c -exec ls -l {} \;
			find dl -size -1024c -exec rm -f {} \;
			echo " "
			Enter
		else
			Say="网络连接错误,[dl]库下载失败!" && Color_R
			sleep 2
		fi
	;;
	esac
done
}

Backup_Recovery() {
while :
do
	clear
	Say="备份与恢复" && Color_B
	echo " "
	Say="1.备份[.config]" && Color_Y
	Say="2.恢复[.config]" && Color_Y
	Say="3.备份[dl]库" && Color_B
	Say="4.恢复[dl]库" && Color_B
	Say="5.备份[$Project]源代码" && Color_G
	Say="6.恢复[$Project]源代码" && Color_G
	echo "q.返回"
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
		Say="备份[.config]" && Color_Y && echo " "
		if [ $Project == Lede ];then
			echo -e "1.标准名称/$Yellow文件格式:[$Project-版本号-日期_时间]$White"
		else
			echo "1.标准名称文件格式:[$Project-日期_时间]"
		fi
		echo "2.自定义名称"
		echo "q.返回"
		GET_Choose
		echo " "
		case $Choose in
		q)
			break
		;;
		1)
			if [ $Project == Lede ];then
				Backup_Config=$Project-$Lede_Version-`(date +%m%d_%H:%M)`
			else
				Backup_Config=$Project-`(date +%m%d_%H:%M)`
			fi	
			if [ -f ./Projects/$Project/.config ];then
				cp ./Projects/$Project/.config ./Backups/Configs/$Backup_Config
				Say="备份成功!备份文件存放于:'$Home/Backups/Configs/$Backup_Config'" && Color_Y
			else
				Say="备份失败!" && Color_R
			fi
		;;
		2)
			read -p '请输入自定义名称:' Backup_Config
			echo " "
			if [ -f ./Projects/$Project/.config ];then
				cp ./Projects/$Project/.config ./Backups/Configs/$Backup_Config
				Say="备份成功!备份文件存放于:'$Home/Backups/Configs/$Backup_Config'" && Color_Y
			else
				Say="备份失败!" && Color_R
			fi
		;;	
		esac
		sleep 2
	done
	;;
	2)
	while :
	do
		clear
		Say="恢复[.config]" && Color_B && echo " "
		cd $Home/Backups/Configs
		echo -n "备份文件"
		ls -lh -u -o
		echo " "
		read -p '请从上方选出你想要恢复的配置文件[q.返回]:' Recover_Config
		echo " "
		if [ $Recover_Config == q ];then
			break
		fi
		if [ -f $Recover_Config ];then
			Recover_PATH=$Home/Projects/$Project/.config
			if [ -f $Recover_PATH ];then
				rm $Recover_PATH
			fi
			cp $Recover_Config $Recover_PATH
			Say="[$Recover_Config]恢复成功!" && Color_Y
			sleep 2
			break
		else
			Say="未找到[$Recover_Config],恢复失败!" && Color_R
			sleep 2
		fi
	done
	;;
	3)
		echo " "
		cd $Home/Projects
		if [ ! -d ./$Project/dl ];then
			Say="未找到'$Home/Projects/$Project/dl',备份失败!" && Color_R
		else
			echo -ne "\r$Yellow正在备份[dl]库...$White\r"
			cp -a $Home/Projects/$Project/dl $Home/Backups/
			Say="备份成功![dl]库已备份到:'$Home/Backups/dl'" && Color_Y
			Say="存储占用:$(du -sh $Home/Backups/dl | awk '{print $1}')B" && Color_B
		fi
		echo " "
		Enter
	;;
	4)
		echo " "
		cd $Home
		if [ ! -d ./Backups/dl ];then
			Say="未找到'$Home/Backups/dl',恢复失败!" && Color_R
		else
			echo -ne "\r$Blue正在恢复[dl]库...$White\r"
			cp -a $Home/Backups/dl $Home/Projects/$Project
			Say="恢复成功![dl]库已恢复到:'$Home/Projects/$Project/dl'" && Color_B
			Say="存储占用:$(du -sh $Home/Projects/$Project/dl | awk '{print $1}')B" && Color_B
		fi
		echo " "
		Enter
	;;
	5)
		echo " "
		echo -ne "\r$Yellow正在备份[$Project]源代码...$White\r"
		if [ -f $Home/Backups/Projects/$Project/Makefile ];then
			rm -rf $Home/Backups/Projects/$Project
		fi
		sudo cp -a $Home/Projects/$Project $Home/Backups/Projects
		Say="备份成功![$Project]源代码已备份到:'$Home/Backups/Projects/$Project'" && Color_Y
		Say="存储占用:$(du -sh $Home/Backups/Projects/$Project | awk '{print $1}')B" && Color_B
		echo " "
		Enter
	;;
	6)
		echo " "
		if [ -f $Home/Backups/Projects/$Project/Makefile ];then
			echo -ne "\r$Yellow正在恢复[$Project]源代码...$White\r"
			sudo cp -a $Home/Backups/Projects/$Project $Home/Projects/
			Say="恢复成功![$Project]源代码已恢复到:'$Home/Projects/$Project'" && Color_Y
			Say="存储占用:$(du -sh $Home/Projects/$Project | awk '{print $1}')B" && Color_B
			echo " "
			Enter
		else
			Say="未找到[$Project]源代码,恢复失败!" && Color_R
			sleep 2
		fi
	;;
	esac
done
}

Make_Menuconfig() {
clear
cd $Home/Projects/$Project
Say="Loading $Project Configuration..." && Color_Y
make menuconfig
Enter
}

Advanced_Options_1() {
while :
do
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.更新系统软件包"
	Say="2.安装编译环境" && Color_G
	echo "3.SSH服务"
	echo "4.同步网络时间"
	echo "5.存储空间占用统计"
	echo "6.创建快捷启动"
	echo "7.查看磁盘信息"
	echo "8.定时任务"
	echo "9.系统信息"
	echo "10.更换软件源"
	echo " "
	echo -e "x.$Yellow更新脚本$White"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	x)
		Script_Update
	;;
	1)
		clear
		sudo apt-get update
		sudo apt-get upgrade
		echo " "
		Enter
	;;
	2)
		clear
		Update_Times=1
		sudo apt-get update
		while [ $Update_Times -le 3 ];
		do
			clear
			echo -ne "\r开始第$Update_Times次安装...\r"
			sleep 2
			sudo apt-get -y install $Dependency $Extra_Dependency
			Update_Times=$(($Update_Times + 1))
		done
		echo " "
		Enter
	;;
	3)
		echo " "
		cd $Home
		if [ ! -f ./Configs/SSH ];then
			read -p '请输入路由器的用户名:' SSH_User
			read -p '请输入路由器的IP地址:' SSH_IP
			echo "Username=$SSH_User" > ./Configs/SSH
			echo "IP=$SSH_IP" >> ./Configs/SSH
			echo " "
			Say="配置已保存到'$Home/Configs/SSH'" && Color_Y
			sleep 2
			ssh-keygen -R $SSH_IP
			clear
			ssh $SSH_User@$SSH_IP
		else
			SSH_User=`awk -F'[="]+' '/Username/{print $2}' ./Configs/SSH`
			SSH_IP=`awk -F'[="]+' '/IP/{print $2}' ./Configs/SSH`
		fi
		while :
		do
			clear
			Say="SSH连接路由器" && Color_B
			echo " "
			echo "1.使用上次保存的配置连接"
			echo "2.创建[新的配置文件]"
			echo "3.删除[现有配置文件]"
			echo "4.重置[RSA Key Fingerprint]"
			echo "q.返回"
			GET_Choose
			case $Choose in
			q)
				break
			;;
			1)
				clear
				ssh $SSH_User@$SSH_IP
			;;
			2)
				echo " "
				if [ ! -f ./Configs/SSH ];then
					read -p '请输入路由器的用户名:' SSH_User
					read -p '请输入路由器的IP地址:' SSH_IP
					echo "Username=$SSH_User" > ./Configs/SSH
					echo "IP=$SSH_IP" >> ./Configs/SSH
					echo " "
					Say="配置已保存到'$Home/Configs/SSH'" && Color_Y
				else
					Say="若要创建新的配置文件,请先删除旧配置文件." && Color_R
				fi
				sleep 2
			;;
			3)
				echo " "
				if [ -f ./Configs/SSH ];then
					rm $Home/Configs/SSH
					Say="[现有配置文件]删除成功!" && Color_Y
				else
					Say="[现有配置文件]删除失败!" && Color_R
				fi
				sleep 2
			;;
			4)
				ssh-keygen -R $SSH_IP
				echo " "
				Say="[RSA Key Fingerprint]重置成功!" && Color_Y
				sleep 2
			esac
		done
	;;
	4)
		echo " "
		sudo ntpdate ntp1.aliyun.com
		sudo hwclock --systohc
		Say="时间同步完成!" && Color_Y
		sleep 2
	;;
	5)
		StorageStat
	;;
	6)
		echo " "
		cd ~
		if [ -f .bashrc ];then
			read -p '请输入快捷启动的名称:' FastOpen		
			echo "alias $FastOpen='$Home/AutoBuild.sh'" >> ~/.bashrc
			source ~/.bashrc
			echo " "
			Say="创建成功!在终端输入 $FastOpen 即可启动AutoBuild[需要重启终端]." && Color_Y
		else
			Say="创建失败!" && Color_R
		fi
		sleep 3
	;;
	7)
		clear
		df -h
		echo " "
		Enter
	;;
	8)
	while :
	do
		clear
		Say="定时任务" && Color_B
		echo " "
		echo "1.立刻关机"
		echo "2.立刻重启"
		echo "3.定时关机"
		echo "4.定时重启"
		echo "5.取消所有定时任务"
		echo "q.返回"
		GET_Choose
		echo " "
		case $Choose in
		q)
			break
		;;
		1)
			shutdown -h now
		;;
		2)
			shutdown -r now
		;;
		3)
			read -p '请输入关机等待时间:' Time_wait
			echo " "
			shutdown -h $Time_wait
			Say="系统将在 $Time_wait 分钟后关机." && Color_Y
		;;
		4)
			read -p '请输入重启等待时间:' Time_wait
			echo " "
			shutdown -rh $Time_wait
			Say="系统将在 $Time_wait 分钟后重启." && Color_Y
		;;
		5)
			shutdown -c
			Say="已取消所有定时任务." && Color_Y
		;;
		esac
		sleep 3
	done
	;;
	9)
		Systeminfo
	;;
	10)
		ReplaceSourcesList
	;;
	esac
done
}

Script_Update() {
timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	clear
	cd $Home
	Old_Version=`awk 'NR==6' ./AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}'`
	Backups_Dir=$Home/Backups/OldVersion/AutoBuild-Core-$Old_Version
	if [ -d $Backups_Dir ];then
		rm -rf $Backups_Dir
	fi
	mkdir $Backups_Dir
	cp $Home/AutoBuild.sh $Backups_Dir/AutoBuild.sh
	cp $Home/README.md $Backups_Dir/README.md
	cp $Home/LICENSE $Backups_Dir/LICENSE
	cp -a $Home/Additional $Backups_Dir/Additional
	cp -a $Home/Modules $Backups_Dir/Modules
	rm -rf Modules
	rm -rf Additional
	rm -rf TEMP
	svn checkout $AutoBuild_Git/trunk ./TEMP
	echo " "
	if [ -f ./TEMP/AutoBuild.sh ];then
		mv ./TEMP/* $Home
		chmod +x -R $Home/AutoBuild.sh
		chmod +x -R $Home/Modules
		rm -rf TEMP
		Say="AutoBuild更新成功!" && Color_Y
		sleep 2
		./AutoBuild.sh
	else
		Say="AutoBuild更新失败!" && Color_R
		sleep 2
	fi
else
	Say="网络连接错误,更新失败!" && Color_R
	sleep 2
fi
}

Sources_Update() {
timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	clear
	cd $Home/Configs
	echo `(date +%Y-%m-%d_%H:%M)` > ${Project}_Lasted_Update
	cd $Home/Projects/$Project
	if [ $Enforce_Update == 1 ];then
		git fetch --all
		git reset --hard origin/$Branch
	fi
	Update_Logfile=$Home/Log/Update_${Project}_`(date +%Y%m%d_%H:%M)`.log
	git pull 2>&1 | tee $Update_Logfile
	./scripts/feeds update -a 2>&1 | tee -a $Update_Logfile
	./scripts/feeds install -a 2>&1 | tee -a $Update_Logfile
	echo " "
	Updated_Check=$(cat $Update_Logfile | grep -o error )
	if [ "$Updated_Check" == "error" ]; then
		Say="源代码和Feeds更新失败!" && Color_R
	else
		Say="源代码和Feeds更新成功!" && Color_Y
	fi
	echo " "
	Enter
else
	echo " "
	Say="网络连接错误,更新失败!" && Color_R
	sleep 2
fi
}

Project_Choose() {
if [ ! $1 == Lede ];then
	if [ -f ./Projects/$1/Makefile ];then
		echo -e "${White}$2.$1		$Yellow[已检测到]$Blue	$3"
	else
		echo -e "${White}$2.$1		$Red[未检测到]$Blue	$3"
	fi
else
	if [ -f ./Projects/$1/Makefile ];then
		echo -e "${White}$2.$1			$Yellow[已检测到]$Blue	$3"
	else
		echo -e "${White}$2.$1			$Red[未检测到]$Blue	$3"
	fi
fi

}

Sources_Download_Check() {
echo " "
cd $Home/Projects/$Project
if [ -f ./Makefile ];then
	cp ./feeds.conf.default $Home/Backups/$Project.feeds.conf.default
	if [ $Project == Lede ];then
		sed -i "s/#src-git helloworld/src-git helloworld/g" feeds.conf.default
	fi
	Say="[$Project]源代码下载成功!" && Color_Y
else
	Say="[$Project]源代码下载失败!" && Color_R
fi
echo " "
Enter
}

Dir_Check() {
cd $Home
for WD in `cat  ./Additional/Working_Directory`
do
	if [ ! -d ./$WD ];then
		mkdir $WD
	fi
done
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
	Dir_Check
	ColorfulUI_Check
	clear
	Say="AutoBuild Core Script $Version" && Color_B
	echo " "
	Say="1.Get Started!" && Color_G
	echo "2.网络测试"
	echo "3.高级选项"
	echo "4.脚本设置"
	echo "q.退出"
	GET_Choose
	case $Choose in
	q)
		rm -rf $Home/TEMP
		clear
		break
	;;
	1)
	while :
	do
		clear
		Say="AutoBuild Core Script $Version" && Color_B
		Decoration
		cd $Home
		Say="项目名称		[项目状态]	维护者" && Color_G
		echo " "
		Project_Choose Lede 1 coolsnowwolf
		Project_Choose Openwrt 2 Openwrt_Team	
		Project_Choose Lienol 3 Lienol
		echo "q.返回"
		Decoration
		echo " "
		read -p '请从上方选择一个项目:' Choose
		case $Choose in
		q)
			break
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
		esac
	done
	;;
	2)
		Network_Test
	;;
	3)
		Advanced_Options_1
	;;
	4)
		Settings
	;;
	esac
done
}

Home=$(cd $(dirname $0); pwd)
set -u

Dependency="build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget swig"
Extra_Dependency="ntpdate httping openssh-client lm-sensors"

CPU_Model=`awk -F':[ ]' '/model name/{printf ($2);exit}' /proc/cpuinfo`
CPU_Cores=`cat /proc/cpuinfo | grep processor | wc -l`
CPU_Threads=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`
CPU_Freq=`awk '/model name/{print ""$NF;exit}' /proc/cpuinfo`

Lede_Git=`awk '/Lede/{print $2}' $Home/Additional/Download_Sources_Link`
Lede_Old_Git=`awk '/lede-17.01/{print $2}' $Home/Additional/Download_Sources_Link`
Openwrt_Git=`awk '/Openwrt/{print $2}' $Home/Additional/Download_Sources_Link`
Lienol_Git=`awk '/Lienol/{print $2}' $Home/Additional/Download_Sources_Link`
AutoBuild_Git=`awk '/AutoBuild/{print $2}' $Home/Additional/Download_Sources_Link`

chmod +x -R $Home/Modules
for Module in $Home/Modules/*
do
	source $Module
done

Default_Settings
AutoBuild_Core
