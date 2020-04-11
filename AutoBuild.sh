#!/bin/bash
# AutoBuild Script by Hyy2001
# Supported Devices:All [Test]
# Supported Linux Systems:Ubuntu 19.10、Ubuntu 18.04 LTS
Update=2020.04.11
Version=V2.7.1

function Second_Menu() {
while :
do
	cd $Home
	Dir_Check
	if [ -f "./Projects/$Project/feeds.conf.default" ];then
		Say="源码文件:已检测到,当前项目:$Project" && Color_Y
		Say="项目位置:'$Home/Projects/$Project'" && Color_Y
		if [ $Project == Lede ];then
			if [ -f ./Projects/$Project/package/lean/default-settings/files/zzz-default-settings ];then
				cd ./Projects/$Project/package/lean/default-settings/files
				Version=`egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" zzz-default-settings`
				Say="版本号:$Version" && Color_Y
			else
				:
			fi
		fi
	else
		Say="源码文件:未检测到,请前往[高级选项]下载!" && Color_R
	fi
	echo " "
	echo "1.更新$Project源代码和Feeds"
	echo "2.打开固件配置界面"
	echo "3.备份与恢复"
	echo "4.执行编译"
	echo "5.高级选项"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
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

function Compile_Firmware() {
while :
do
	cd $Home/Projects/$Project
	if [ -f .config ];then
		TARGET_BOARD=`awk -F'[="]+' '/TARGET_BOARD/{print $2}' .config`
		TARGET_SUBTARGET=`awk -F'[="]+' '/TARGET_SUBTARGET/{print $2}' .config`
		TARGET_ARCH_PACKAGES=`awk -F'[="]+' '/TARGET_ARCH_PACKAGES/{print $2}' .config`
		PROFILE=`awk -F'[="]+' '/TARGET_PROFILE/{print $2}' .config`
		if [ ! $TARGET_BOARD == x86 ];then
			if [ ! $PROFILE == Default ];then
				TARGET_PROFILE=${PROFILE:7}
				Default_Check=0
			else
				Default_Check=1
				TARGET_PROFILE=编译所有$TARGET_SUBTARGET设备
			fi
			X86_Check=0
		else
			TARGET_PROFILE=$PROFILE
			X86_Check=1
		fi
		clear
		Say="Simple Compile Script by Hyy2001" && Color_B
		Decoration
		echo -e "CPU 架构:$Yellow$TARGET_BOARD$White"
		echo -e "CPU 型号:$Yellow$TARGET_SUBTARGET$White"
		echo -e "Arch架构:$Yellow$TARGET_ARCH_PACKAGES$White"
		echo -e "设备名称:$Yellow$TARGET_PROFILE$White"
		echo ""
		echo -e "用户CPU参数:$Yellow$CPU_Cores核心$CPU_Threads线程$White"
	else
		echo " "
		Say="未检测到配置文件,无法进行编译!" && Color_R
		sleep 3
		break
	fi
	echo " "
	Say="选择编译参数" && Color_B
	echo "1.make -j1"
	echo "2.make -j1 V=s"
	echo "3.make -j4"
	echo "4.make -j4 V=s"
	echo -e "5.$Yellow自动选择$White"
	echo "6.手动输入参数"
	echo "q.返回"
	Decoration
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		Threads=1
		Print_CompileLog=0
	;;
	2)
		Threads=1
		Print_CompileLog=1
	;;
	3)
		Threads=4
		Print_CompileLog=0
	;;
	4)
		Threads=4
		Print_CompileLog=1
	;;
	5)
		Threads=$CPU_Threads
	;;
	6)
		read -p '请输入编译参数:' Threads
	esac
	if [ ! $Choose == 6 ];then
		if [ ! $Choose == 5 ];then
			if [ $Print_CompileLog == 0 ];then
				Thread="make -j$Threads"
				Compile_Say="编译参数:$Skyb$Threads线程编译,不在屏幕上输出日志[快]$White"
			else
				Thread="make -j$Threads V=s"
				Compile_Say="编译参数:$Skyb$Threads线程编译,并在屏幕上输出日志[慢]$White"
			fi
		else
			Compile_Say="自动选择:$Skyb$Threads线程编译$White"
			Thread="make -j$Threads"
		fi
	else
		Thread=$Threads
	fi
	if [ $Default_Check == 0 ];then
		Firmware_Name=openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.bin
		if [ $Project == Lede ];then
			read -p '请输入附加信息:' Extra
			NEW_Firmware_Name="AutoBuild-$TARGET_PROFILE-$Project-$Version`(date +-%Y%m%d-$Extra.bin)`"
			cd $Home
			while [ -f "./Packages/$NEW_Firmware_Name" ]
			do
				read -p '包含该附加信息的名称已存在!请重新添加:' Extra
				NEW_Firmware_Name="AutoBuild-$TARGET_PROFILE-$Project-$Version`(date +-%Y%m%d-$Extra.bin)`"
			done
		else
			read -p '请输入附加信息:' Extra
			NEW_Firmware_Name="AutoBuild-$TARGET_PROFILE-$Project`(date +-%Y%m%d-$Extra.bin)`"
			cd $Home
			while [ -f "./Packages/$NEW_Firmware_Name" ]
			do
				read -p '包含该附加信息的名称已存在!请重新添加:' Extra
				NEW_Firmware_Name="AutoBuild-$TARGET_PROFILE-$Project`(date +-%Y%m%d-$Extra.bin)`"
			done
		fi
	else
		:
	fi
	clear
	if [ ! $Choose == 6 ];then
		echo -e "$Yellow$Compile_Say$White"
	else
		:
	fi
	if [ $X86_Check == 0 ];then
		if [ $Default_Check == 0 ];then
			echo -e "$Yellow预期名称:$Blue$NEW_Firmware_Name$White"
		else
			:
		fi
	else
		:
	fi
	echo " "
	Say="开始编译$Project..." && Color_Y
	Compile_START=`date +'%Y-%m-%d %H:%M:%S'`
	cd $Home/Projects/$Project
	if [ $LogOutput == 0 ];then
		$Thread
	else
		$Thread 2>&1 | tee $Home/Log/$Project-`(date +%m%d_%H:%M)`.log
	fi
	echo " "
	if [ $X86_Check == 0 ];then
		if [ $Default_Check == 0 ];then
			if [ -f ./bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Firmware_Name ];then
				Compile_END=`date +'%Y-%m-%d %H:%M:%S'`
				Start_Seconds=$(date --date="$Compile_START" +%s);
				End_Seconds=$(date --date="$Compile_END" +%s);
				echo -ne "$Skyb$Compile_START --> $Compile_END "
				Compile_TIME=`awk 'BEGIN{printf "本次编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'`
				echo -ne "$Compile_TIME$White"
				echo " "
				mv ./bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Firmware_Name $Home/Packages/$NEW_Firmware_Name
				cd $Home/Packages
				Firmware_Size=`ls -l $NEW_Firmware_Name | awk '{print $5}'`
				Say="$Project编译成功!固件已自动移动到'$Home/Packages' " && Color_Y
				echo -e "$Yellow固件名称:$Blue$NEW_Firmware_Name$White"
				Firmware_Size_MB=`awk 'BEGIN{printf "固件大小:%.2fMB\n",'$((Firmware_Size))'/1000000}'`
				Say="$Firmware_Size_MB" && Color_Y
			else
				echo " "
				Compile_END=`date +'%Y-%m-%d %H:%M:%S'`
				Start_Seconds=$(date --date="$Compile_START" +%s);
				End_Seconds=$(date --date="$Compile_END" +%s);
				echo -ne "$Red$Compile_START --> $Compile_END$White "
				Compile_TIME=`awk 'BEGIN{printf "本次编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'`
				echo -ne "$Red$Compile_TIME$White"
				echo " "
				Say="编译失败!" && Color_R
			fi
		else
			Say="编译结束." && Color_Y
			echo "所选编译设备为Default，请前往'$Project/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET'查看结果."
		fi
	else
		Say="编译结束." && Color_Y
		echo "所选编译设备为X86架构，请前往'$Project/bin/targets/$TARGET_BOARD'查看结果."
	fi
	echo " "
	Enter
	break
done
}

function Sources_Download() {
cd $Home
if [ -f "./Projects/$Project/Makefile" ];then
	echo " "
	if [ -f ./Configs/$Project.branch ];then
		GET_Branch=`(awk 'NR==1' ./Configs/$Project.branch)`
		Say="已检测到$Project源码,当前分支:$GET_Branch" && Color_Y
	else
		Say="已检测到$Project源码,无需下载!" && Color_Y
	fi
	sleep 3
else
	clear
	cd $Home/Projects
	if  [ $Project == 'Lede' ];then
	while :
	do
		Say="$Project源码下载-分支选择" && Color_B
		Say="$GitSource_Out仓库:$Lede_git" && Color_Y
		echo " "
		Branch_1=master
		echo "1.$Branch_1[默认]"
		if [ $DeveloperMode == 0 ];then
			echo -e "2.$Blue恢复[$Project源代码]$White"
		else
			:
		fi
		echo "q.返回"
		echo " "
		read -p '请从上方选择一个分支:' Branch
		case $Branch in
		q)
			break
		;;
		1)
			clear
			git clone $Lede_git $Project
			Branch=master
		;;
		2)
			Sources_Recover
		;;
		esac
		if [ ! $Branch == 2 ];then
			Sources_Download_Check
		else
			:
		fi
		break
	done
	elif [ $Project == 'Openwrt' ];then
	while :
	do
		Say="$Project源码下载-分支选择" && Color_B
		Say="$GitSource_Out仓库:$Openwrt_git" && Color_Y
		echo " "
		Branch_1=master
		Branch_2=lede-17.01
		Branch_3=openwrt-18.06
		Branch_4=openwrt-19.07
		echo "1.$Branch_1[默认]"
		echo "2.$Branch_2"
		echo "3.$Branch_3"
		echo "4.$Branch_4"
		if [ $DeveloperMode == 0 ];then
			echo -e "5.$Blue恢复[$Project源代码]$White"
		else
			:
		fi
		echo "q.返回"
		echo ""
		read -p '请从上方选择一个分支:' Branch
		case $Branch in
		q)
			break
		;;
		1)
			clear
			git clone $Openwrt_git $Project
			Branch=master
		;;
		2)
			clear
			git clone -b $Branch_2 $Openwrt_git $Project
			Branch=$Branch_2
		;;
		3)
			clear
			git clone -b $Branch_3 $Openwrt_git $Project
			Branch=$Branch_3
		;;
		4)
			clear
			git clone -b $Branch_4 $Openwrt_git $Project
			Branch=$Branch_4
		;;
		5)
			Sources_Recover
		;;
		esac
		if [ ! $Branch == 5 ];then
			Sources_Download_Check
		else
			:
		fi
		break
	done
	elif [ $Project == 'Lienol' ];then			
	while :
	do
		Say="$Project源码下载-分支选择" && Color_B
		Say="$GitSource_Out仓库:$Openwrt_git" && Color_Y
		echo " "
		Branch_1=dev-19.07
		Branch_2=dev-lean-lede
		Branch_3=dev-master
		echo "1.$Branch_1[默认]"
		echo "2.$Branch_2"
		echo "3.$Branch_3"
		if [ $DeveloperMode == 0 ];then
			echo -e "4.$Blue恢复[$Project源代码]$White"
		else
			:
		fi
		echo "q.返回"
		echo ""
		read -p '请从上方选择一个分支:' Branch
		case $Branch in
		q)
			break
		;;
		1)
			clear
			git clone -b $Branch_1 $Lienol_git $Project
			Branch=$Branch_1
		;;
		2)
			clear
			git clone -b $Branch_2 $Lienol_git $Project
			Branch=$Branch_2
		;;
		3)
			clear
			git clone -b $Branch_3 $Lienol_git $Project
			Branch=$Branch_3
		;;
		4)
			Sources_Recover
		;;
		esac
		if [ ! $Branch == 4 ];then
			Sources_Download_Check
		else
			:
		fi
		break
	done
	else 
		:
	fi
fi
}

function Advanced_Options_2() {
while :
do
	cd $Home/Projects/$Project
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.从$GitSource_Out拉取$Project源代码"
	echo "2.强制更新$Project源代码和Feeds"
	echo "3.添加第三方主题包"
	echo "4.磁盘清理"
	echo "5.删除配置文件"
	echo "6.添加第三方软件包"
	echo "7.下载[dl]库"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		Sources_Download
	;;
	2)
		Enforce_Sources_Update
	;;
	3)
		clear
		cd $Home/Projects
		if [ -d ./$Project/package/themes ];then
			:
		else
			cd ./$Project/package
			mkdir themes
		fi
		clear
		if [ $Project == 'Lede' ];then
			cd $Home/Projects/$Project/package/lean
			rm -rf luci-theme-argon
			git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
			cd $Home/Projects/$Project/package/themes
			rm -rf luci-theme-rosy
			git clone https://github.com/rosywrt/luci-theme-rosy luci-theme-rosy
			cd $Home/Projects/$Project
			grep "darkmatter" feeds.conf.default > /dev/null
			if [ $? -eq 0 ]; then
				:
			else
				echo "src-git darkmatter https://github.com/Lienol/luci-theme-darkmatter;luci-18.06" >> feeds.conf.default
				Say="已添加luci-theme-darkmatter到feeds.conf.default" && Color_Y
			fi
			scripts/feeds update darkmatter
			scripts/feeds install luci-theme-darkmatter
			echo " "
			if [ -d ./package/lean/luci-theme-argon ];then
				Say="已添加主题包 luci-theme-argon" && Color_Y
			else
				Say="主题包 luci-theme-argon 添加失败!" && Color_R
			fi
			if [ -d ./package/themes/luci-theme-rosy ];then
				Say="已添加主题包 luci-theme-rosy" && Color_Y
			else
				Say="主题包 luci-theme-rosy 添加失败!" && Color_R
			fi
			if [ -d ./feeds/darkmatter ];then
				Say="已添加主题包 luci-theme-darkmatter" && Color_Y
			else
				Say="主题包 luci-theme-darkmatter 添加失败!" && Color_R
			fi	
		else
			cd $Home/Projects/$Project/package/themes
			rm -rf luci-theme-argon
			git clone https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
			echo " "
			if [ -d ./luci-theme-argon ];then
				Say="已添加主题包 luci-theme-argon" && Color_Y
			else
				Say="主题包 luci-theme-argon 添加失败!" && Color_R
			fi
		fi
		Enter
	;;
	4)
	while :
	do
		clear
		Say="磁盘清理" && Color_R
		echo " "
		echo "1.make clean"
		echo "2.make dirclean"
		echo "3.make distclean"
		echo "4.删除$Project项目"
		echo "q.返回"
		GET_Choose
		cd $Home/Projects/$Project
		case $Choose in
		q)
			break
		;;
		1)	
			make clean
			sleep 3
			break
		;;
		2)
			make dirclean
			sleep 3
			break
		;;
		3)
			make distclean
			sleep 3
			break
		;;
		4)
			cd $Home/Projects
			echo " "
			Say="正在删除$Project项目,请耐心等待..." && Color_B
			echo " "
			rm -rf $Project
			if [ ! -d ./$Project ];then
				cd $Home
				if [ -f ./Configs/$Project.branch ];then
					rm ./Configs/$Project.branch
					Say="已删除'$Home/Configs/$Project.branch'" && Color_Y
				else
					:
				fi
				Say="[$Project]项目删除成功!" && Color_Y
			else 
				Say="[$Project]项目删除失败!" && Color_R
			fi
			sleep 3
			break
		esac
	done
	;;
	5)
		cd $Home/Projects/$Project
		if [ -f .config ];then
			rm .config
		elif [ -f .config.old ];then
			rm .config.old
		else
			:
		fi
		echo " "
		Say="删除成功!" && Color_Y
		sleep 3
	;;
	6)
		Add_Packages
	;;
	7)
		clear
		Say="开始下载[dl]库,线程数:$CPU_Threads" && Color_Y
		make -j$CPU_Threads download V=s
		echo " "
		Enter
	;;
	esac
done
}

function Backup_Recovery() {
while :
do
clear
Say="备份与恢复" && Color_B
echo " "
echo "1.备份[.config]"
echo "2.恢复[.config]"
echo "3.备份[dl]库"
echo "4.恢复[dl]库"
echo "5.恢复[$Project]源代码"
echo "q.返回"
GET_Choose
case $Choose in
q)
	break
;;
1)
while :
do
	clear
	Say="当前操作:备份[.config]" && Color_B && echo " "
	if [ $Project == Lede ];then
		echo "1.标准名称/文件格式:[$Project-版本号-日期_时间]"
	else
		echo "1.标准名称/文件格式:[$Project-日期_时间]"
	fi
	echo "2.自定义文件名称"
	echo "q.返回"
	GET_Choose
	echo " "
	case $Choose in
	q)
		break
	;;
	1)
		if [ $Project == Lede ];then
			Config_Name=$Project-$Version-`(date +%m%d_%H:%M)`
		else
			Config_Name=$Project-`(date +%m%d_%H:%M)`
		fi
		cp $Home/Projects/$Project/.config $Home/Backups/$Config_Name
	;;
	2)
		read -p '请输入你想要的文件名:' Config_Name
		echo " "
		cp $Home/Projects/$Project/.config $Home/Backups/$Config_Name
	;;	
	esac
	Say="备份成功!备份文件存放于:$Home/Backups" && Color_Y
	Say="文件名称:$Config_Name" && Color_Y
	sleep 2
done
;;
2)
while :
do
	clear
	Say="当前操作:恢复[.config]" && Color_B && echo " "
	cd $Home/Backups
	echo -n "备份文件"
	ls -lh -u -o
	echo " "
	read -p '请从上方选出你想要恢复的文件[q.返回]:' Config_Recovery
	echo " "
	if [ ! $Config_Recovery == q ];then
		:
	else
		break
	fi
	if [ -f ./$Config_Recovery ];then
		cd $Home
		Config_PATH_NAME=./Projects/$Project/.config
		if [ -f $Config_PATH_NAME ];then
			rm $Config_PATH_NAME
		else
			:
		fi
		cp ./Backups/$Config_Recovery $Config_PATH_NAME
		if [ -f $Config_PATH_NAME ];then
			Say="恢复成功!" && Color_Y
		else
			Say="恢复失败!" && Color_R
		fi
		sleep 2
		break
	else
		Say="未找到'$Config_Recovery',请检查是否输入正确!" && Color_R
		sleep 2
	fi
done
;;
3)
	echo " "
	cd $Home/Projects
	if [ ! -d ./$Project/dl ];then
		Say="没有找到'$Home/Projects/$Project/dl',无法进行备份!" && Color_R
	else
		echo -ne "\r$Blue正在备份[dl]库...$White\r"
		cp -a $Home/Projects/$Project/dl $Home/Backups/
		Say="备份成功![dl]库已备份到:'$Home/Backups/dl'" && Color_Y
		cd $Home/Backups
		dl_Size=$((`du --max-depth=1 dl |awk '{print $1}'`))
		dl_Size_MB=`awk 'BEGIN{printf "存储占用:%.2fMB\n",'$((dl_Size))'/1000}'`
		Say="$dl_Size_MB" && Color_Y
	fi
	echo " "
	Enter
;;
4)
	echo " "
	cd $Home
	if [ ! -d ./Backups/dl ];then
		Say="没有找到'$Home/Backups/dl',无法进行恢复!" && Color_R
	else
		echo -ne "\r$Blue正在恢复[dl]库...$White\r"
		cp -a $Home/Backups/dl $Home/Projects/$Project
		Say="恢复成功![dl]库已恢复到:'$Home/Projects/$Project/dl'" && Color_Y
		cd $Home/Projects/$Project
		dl_Size=$((`du --max-depth=1 dl |awk '{print $1}'`))
		dl_Size_MB=`awk 'BEGIN{printf "存储占用:%.2fMB\n",'$((dl_Size))'/1000}'`
		Say="$dl_Size_MB" && Color_Y
	fi
	echo " "
	Enter
;;
5)
	echo " "
	Sources_Recover
;;
esac
done
}

function Sources_Recover() {
cd $Home
if [ -f ./Backups/Projects/$Project/Makefile ];then
	Say="恢复中,请耐心等待!" && Color_B
	cp -a $Home/Backups/Projects/$Project $Home/Projects
	echo " "
	Say="恢复成功!" && Color_Y
	Say="[$Project源代码]已恢复到:'$Home/Projects/'" && Color_Y
else
	Say="没有找到'$Home/Backups/Projects/$Project'文件夹,无法进行恢复!" && Color_R
	Say="您似乎还没有进行过备份." && Color_R
fi
sleep 3
}


function Add_Packages() {
while :
do
	cd $Home/Projects/$Project/package
	if [ ! -d ./custom ];then
		mkdir custom
	else
		:
	fi
	cd ./custom
	clear
	Say="手动添加软件包" && Color_B
	echo " "
	echo "1.SmartDNS"
	echo "2.AdGuardHome"
	echo "3.Clash"
	echo -e "4.${Yellow}[软件库]${Blue}Lienol's Package Sources${White}"
	echo -e "5.${Yellow}[软件库]${Blue}Lean's Package Sources${White}"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break	
	;;
	1)
		PKG_NAME=SmartDNS
		PKG_URL=https://github.com/Hyy2001X/SmartDNS.git
		Add_Packages_mod
	;;
	2)
		PKG_NAME=luci-app-adguardhome
		PKG_URL=https://github.com/rufengsuixing/luci-app-adguardhome.git
		Add_Packages_mod
	;;
	3)
		PKG_NAME=luci-app-clash
		PKG_URL=https://github.com/frainzy1477/luci-app-clash.git
		Add_Packages_mod
	;;
	4)
		cd $Home/Projects/$Project
		grep "lienol" feeds.conf.default > /dev/null
		if [ $? -eq 0 ]; then
			echo " "
			Say="已检测到Lienol's Package Sources,无需添加!" && Color_Y
		else
			echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default
			echo " "
			grep "lienol" feeds.conf.default > /dev/null
			if [ $? -eq 0 ]; then
				Say="添加成功!" && Color_Y
			else
				Say="添加失败!" && Color_R
			fi
		fi
	;;
	5)
		cd $Home/Projects/$Project
		clear
		if [ -d ./package/lean ];then
			rm -rf ./package/lean
		else
			:
		fi
		svn checkout $Lede_git/trunk/package/lean ./package/lean
		echo " "
		if [ $? -eq 0 ]; then
			Say="下载成功!" && Color_Y
		else
			Say="下载失败!" && Color_R
		fi
	;;
	esac
	sleep 3
done
}

function Add_Packages_mod() {
clear
if [ ! -d ./$PKG_NAME ];then
	:
else
	rm -rf $PKG_NAME
	Say="已删除软件包 $PKG_NAME" && Color_Y
fi
	git clone $PKG_URL $PKG_NAME
	echo " "
	if [ -f ./$PKG_NAME/Makefile ];then
	Say="已成功添加软件包 $PKG_NAME" && Color_Y
	else
	Say="未成功添加软件包 $PKG_NAME,请重试!" && Color_R
	fi
}

function Make_Menuconfig() {
clear
cd $Home/Projects/$Project
Say="Loading $Project Configuration..." && Color_B
make menuconfig
echo " "
Enter
}

Advanced_Options_1() {
while :
do
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.更新系统软件包"
	echo -e "2.$Skyb安装编译环境$White"
	echo "3.通过SSH访问路由器"
	echo "4.同步网络时间"
	echo "5.空间占用统计"
	echo "6.创建快捷启动"
	echo "7.查看磁盘信息"
	echo "8.定时关机"
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
		sudo apt update
		sudo apt upgrade
		echo " "
		Enter
	;;
	2)
		clear
		Update_Times=1
		sudo apt-get update
		while [ $Update_Times -le 3 ];
		do
			echo -ne "\r准备执行第$Update_Times次安装...\r"
			sleep 2
			sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf
			sudo apt-get -y install $Extra_Packages
			Update_Times=$(($Update_Times + 1))
		done
		echo " "
		Enter
	;;
	3)
		ssh-keygen -R 192.168.1.1
		clear
		ssh root@192.168.1.1
	;;
	4)
		sudo ntpdate ntp1.aliyun.com
		sudo hwclock --systohc
	;;
	5)
		StorageStat
	;;
	6)
		echo " "
		cd ~
		if [ -f .bashrc ];then
		
			read -p '请创建一个快捷启动的名称:' FastOpen		
			echo "alias $FastOpen='$Home/AutoBuild.sh'" >> ~/.bashrc
			source ~/.bashrc
			echo " "
			Say="创建成功!下次在终端输入 $FastOpen 即可启动AutoBuild[需要重启终端]." && Color_Y
		else
			Say="未检测到.bashrc,无法创建快捷启动!" && Color_R
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
		Say="定时关机" && Color_B
		echo " "
		echo "1.立刻关机"
		echo "2.X分钟后关机"
		echo "3.立刻重启"
		echo "4.终止关机/重启任务"
		echo "q.返回"
		GET_Choose
		case $Choose in
		q)
			break
		;;
		1)
			shutdown -h now
		;;
		2)
			read -p '请输入时间X[X分钟后关机]:' Time_wait
			echo " "
			shutdown -h $Time_wait
			Say="已设置$Time_wait分钟后自动关机." && Color_Y
		;;
		3)
			shutdown -r now
		;;
		4)
			shutdown -c
			echo " "
			Say="已取消关机/重启任务." && Color_Y
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

function Script_Update() {
echo " "
echo -ne "\r$Blue检查网络连接...$White\r"
timeout 3 httping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	Say="连接正常,开始更新脚本..." && Color_Y
	cd $Home
	rm $Home/AutoBuild.sh
	rm $Home/README.md
	rm -rf $Home/TEMP
	rm -rf $Home/Modules
	rm -rf $Home/Additional
	svn checkout $AutoBuild_git/trunk ./TEMP
	echo " "
	if [ -f ./TEMP/AutoBuild.sh ];then
		mv ./TEMP/AutoBuild.sh $Home/AutoBuild.sh
		mv ./TEMP/README.md $Home/README.md
		mv ./TEMP/Modules $Home
		mv ./TEMP/Additional $Home
		chmod +x AutoBuild.sh
		chmod +x -R $Home/Modules
		Say="更新成功!" && Color_Y
		sleep 3
		./AutoBuild.sh
	else
		Say="更新失败!" && Color_R
	fi
else
	Say="无网络连接,无法更新!" && Color_R
fi
sleep 3
}

function Sources_Update() {
echo " "
echo -ne "\r$Blue检查网络连接...$White\r"
timeout 3 httping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	Say="网络连接正常,准备开始更新..." && Color_Y
	sleep 1
	clear
	cd $Home/Projects/$Project
	git pull
	./scripts/feeds update -a
	./scripts/feeds install -a
	echo " "
	if [ $? -eq 0 ]; then
		Say="更新成功!" && Color_Y
	else
		Say="更新失败!" && Color_R
	fi
else
	echo " "
	Say="无网络连接,无法更新!" && Color_R
fi
sleep 3
}

Enforce_Sources_Update() {
echo " "
echo -ne "\r$Blue检查网络连接...$White\r"
timeout 3 httping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	Say="连接正常,准备开始强制更新..." && Color_Y
	sleep 1
	cd $Home/Projects/$Project
	clear
	git fetch --all
	git reset --hard origin/master
	git pull
	echo " "
	if [ $? -eq 0 ]; then
		Say="强制更新成功!" && Color_Y
	else
		Say="强制更新失败!" && Color_R
	fi
else
	echo " "
	Say="无网络连接,无法更新!" && Color_R
fi
sleep 3
}

function GET_Choose() {
echo " "
read -p '请从上方选择一个操作:' Choose
}

function Enter() {
read -p "按下[回车]键以继续..." Key
}

function Color_Y() {
echo -e "$Yellow$Say$White"
}

function Color_R() {
echo -e "$Red$Say$White"
}

function Color_B() {
echo -e "$Blue$Say$White"
}

function Decoration() {
	echo -ne "$Skyb"
	printf "%-70s\n" "-" | sed 's/\s/-/g'
	echo -ne "$White"
}

function Sources_Download_Check() {
cd $Home
echo " "
if [ -f "./Projects/$Project/feeds.conf.default" ];then
	echo "$Branch" > $Home/Configs/$Project.branch
	cd $Home
	if [ -d ./Backups/Projects/$Project ];then
		rm -rf $Home/Backups/Projects/$Project
	else
		:
	fi
	cp -r $Home/Projects/$Project $Home/Backups/Projects/$Project
	Say="$Project源码下载成功,已自动备份到'$Home/Backups/Projects/$Project'" && Color_Y
else
	Say="$Project源码下载失败,请检查网络后重试!" && Color_R
fi
echo " "
Enter
}

function Dir_Check() {
	cd $Home
	if [ ! -d ./Projects ];then
		mkdir Projects
	else
		:
	fi
	if [ ! -d ./TEMP ];then
		mkdir TEMP
	else
		:
	fi
	if [ ! -d ./Packages ];then
		mkdir Packages
	else
		:
	fi
	if [ ! -d ./Backups ];then
		mkdir Backups
	else
		:
	fi
	if [ ! -d ./Backups/Projects ];then
		mkdir Backups/Projects
	else
		:
	fi
	if [ ! -d ./Configs ];then
		mkdir Configs
	else
		:
	fi
	if [ ! -d ./Log ];then
		mkdir Log
	else
		:
	fi
	clear
}

function Second_Menu_Check() {
if [ -f ./Projects/$Project/feeds.conf.default ];then
	Second_Menu
else
	if [ $DeveloperMode == 1 ];then
		Second_Menu
	else
		Sources_Download
	fi
fi
}

function SimpleCompilation_Check() {
if [ $SimpleCompilation == 1 ];then
	Compile_Firmware
else
	clear
	cd $Home/Projects/$Project
	make -j$(($(nproc) + 1)) V=s
	echo " "
	Enter
fi
}

function ColorfulUI_Check() {
if [ $ColorfulUI == 1 ];then
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

function GitSource_Check() {
if [ $GitSource == 1 ];then
	Lede_git=https://gitee.com/Hyy2001X/Lede
	Openwrt_git=https://gitee.com/Hyy2001X/Openwrt
	Lienol_git=https://gitee.com/Hyy2001X/Lienol
	AutoBuild_git=https://gitee.com/Hyy2001X/AutoBuild
	GitSource_Out=Gitee
else
	Lede_git=https://github.com/coolsnowwolf/lede
	Openwrt_git=https://github.com/openwrt/openwrt
	Lienol_git=https://github.com/lienol/openwrt
	AutoBuild_git=https://github.com/Hyy2001X/AutoBuild
	GitSource_Out=Github
fi
}

function Settings() {
while :
do
	ColorfulUI_Check
	clear
	Say="设置[实验性]" && Color_B
	echo " "
	if [ $DeveloperMode == 0 ];then
		Say="1.开发者模式		[OFF]" && Color_R
	else
		Say="1.开发者模式		[ON]" && Color_Y
	fi
	if [ $SimpleCompilation == 0 ];then
		Say="2.轻松编译		[OFF]" && Color_R
	else
		Say="2.轻松编译		[ON]" && Color_Y
	fi
	if [ $ColorfulUI == 0 ];then
		Say="3.彩色UI		[OFF]" && Color_R
	else
		Say="3.彩色UI		[ON]" && Color_Y
	fi
	if [ $GitSource == 0 ];then
		Say="4.默认下载源		[Github]" && Color_Y
	else
		Say="4.默认下载源		[Gitee]" && Color_B
	fi
	if [ $LogOutput == 0 ];then
		Say="5.输出编译日志		[OFF]" && Color_R
	else
		Say="5.输出编译日志		[ON]" && Color_Y
	fi
	echo " "
	echo "x.恢复默认设置"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	x)
		Default_Settings
	;;
	1)
		if [ $DeveloperMode == 0 ];then
			DeveloperMode=1
		else
			DeveloperMode=0
		fi
	;;
	2)
		if [ $SimpleCompilation == 0 ];then
			SimpleCompilation=1
		else
			SimpleCompilation=0
		fi
	;;
	3)
		if [ $ColorfulUI == 0 ];then
			ColorfulUI=1
		else
			ColorfulUI=0
		fi
	;;
	4)
		if [ $GitSource == 0 ];then
			GitSource=1
		else
			GitSource=0
		fi
	;;
	5)
		if [ $LogOutput == 0 ];then
			LogOutput=1
		else
			LogOutput=0
		fi

	;;
	esac
done
}

function Default_Settings() { 
DeveloperMode=0
SimpleCompilation=1
ColorfulUI=1
GitSource=0
LogOutput=0
}

Home=$(cd $(dirname $0); pwd)
Extra_Packages="ntpdate httping subversion"

CPU_Cores=`cat /proc/cpuinfo | grep processor | wc -l`
CPU_Threads=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`

chmod +x -R $Home/Modules
source $Home/Modules/NetworkTest.sh
source $Home/Modules/Systeminfo.sh
source $Home/Modules/StorageStat.sh
source $Home/Modules/ReplaceSourcesList.sh
Default_Settings

################################################################Main code
while :
do
Dir_Check
ColorfulUI_Check
GitSource_Check
clear
Say="AutoBuild AIO $Version by Hyy2001" && Color_B
echo ""
echo -e "1.${Yellow}Get Started!$White"
echo "2.网络测试"
echo "3.高级选项"
echo "4.设置"
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
	Say="AutoBuild AIO $Version by Hyy2001" && Color_B
	echo " "
	cd $Home
	if [ -f ./Projects/Lede/feeds.conf.default ];then
		echo -e "1.Lede			$Yellow[已检测到]$White"
	else
		echo -e "1.Lede			$Red[未检测到]$White"
	fi
	if [ -f ./Projects/Openwrt/feeds.conf.default ];then
		echo -e "2.Openwrt_Offical	$Yellow[已检测到]$White"
	else
		echo -e "2.Openwrt_Offical	$Red[未检测到]$White"
	fi
	if [ -f ./Projects/Lienol/feeds.conf.default ];then
		echo -e "3.Lienol		$Yellow[已检测到]$White"
	else
		echo -e "3.Lienol		$Red[未检测到]$White"
	fi
	echo "q.返回"
	GET_Choose
	if [ $Choose == 1 ]; then
		Project=Lede
	elif [ $Choose == 2 ]; then
		Project=Openwrt
	elif [ $Choose == 3 ]; then
		Project=Lienol
	else
		:
	fi
	case $Choose in
	q)
		break
	;;
	1)
		Second_Menu_Check
	;;
	2)
		Second_Menu_Check
	;;
	3)
		Second_Menu_Check
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
