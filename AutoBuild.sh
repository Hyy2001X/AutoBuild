#!/bin/bash
# AutoBuild Script by Hyy2001
# Device Support:ALL Device [TEST]
# Support System:Ubuntu 19.10、Ubuntu 18.04 [WSL]
Update=2020.04.01
Version=V2.5.5

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

function Sources_Update() {
timeout 3 httping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
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

function Custom_Second_Menu() {
	:
}

function Compile_Firmware() {
while :
do
	cd $Home/Projects/$Project
	if [ -f ".config" ];then
		clear
		cp .config $Home/TEMP/$Project.TEMP
		cd $Home/TEMP
		GET_BOARD=$(awk '/CONFIG_TARGET_BOARD=/{print}' $Project.TEMP);
		GET_SUBTARGET=$(awk '/CONFIG_TARGET_SUBTARGET=/{print}' $Project.TEMP);
		GET_PROFILE=$(awk '/CONFIG_TARGET_PROFILE=/{print}' $Project.TEMP);
		echo $GET_BOARD > $Project.TEMP2
		echo $GET_SUBTARGET >> $Project.TEMP2
		echo $GET_PROFILE >> $Project.TEMP2
		sed -i 's/\"//g' $Project.TEMP2
		PROCESSED_BOARD=`(awk 'NR==1' $Project.TEMP2)`
		PROCESSED_SUBTARGET=`(awk 'NR==2' $Project.TEMP2)`
		PROCESSED_PROFILE=`(awk 'NR==3' $Project.TEMP2)`
		TARGET_BOARD=${PROCESSED_BOARD:20}
		TARGET_SUBTARGET=${PROCESSED_SUBTARGET:24}	
		if [ ! $TARGET_BOARD == x86 ];then
			TARGET_PROFILE=${PROCESSED_PROFILE:29}
			X86_Check=0
		else
			TARGET_PROFILE=${PROCESSED_PROFILE:22}
			X86_Check=1
		fi
		Say="配置文件解析" && Color_B
		echo CPU架构:$TARGET_BOARD
		echo 处理器型号:$TARGET_SUBTARGET
		echo 设备名称:$TARGET_PROFILE
		echo ""
		echo -e "用户CPU参数:$Yellow$CPU_Cores核$CPU_Threads线程$White"
	else
		echo " "
		Say="未检测到配置文件,无法进行编译!" && Color_R
		sleep 3
		break
	fi
	echo " "
	Say="编译参数" && Color_B
	echo "1.make -j1"
	echo "2.make -j1 V=s"
	echo "3.make -j4"
	echo "4.make -j4 V=s"
	echo -e "5.$Yellow自动选择$White"
	echo "6.手动输入参数"
	echo "q.返回"
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
				Compile_Say="当前选择:使用$Threads线程编译,不在屏幕上输出日志[快]"
			else
				Thread="make -j$Threads V=s"
				Compile_Say="当前选择:使用$Threads线程编译,并在屏幕上输出日志[慢]"
			fi
		else
			Compile_Say="自动选择:使用$Threads线程编译"
			Thread="make -j$Threads"
		fi
	else
		Thread=$Threads
	fi
	Firmware_Name=openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.bin
	read -p '请输入附加信息:' Extra
	NEW_Firmware_Name="AutoBuild-$TARGET_PROFILE-$Project-$Version`(date +-%Y%m%d-$Extra.bin)`"
	cd $Home
	while [ -f "./Packages/$NEW_Firmware_Name" ]
	do
		read -p '包含该附加信息的名称已存在!请重新添加:' Extra
		NEW_Firmware_Name="AutoBuild-$TARGET_PROFILE-$Project-$Version`(date +-%Y%m%d-$Extra.bin)`"
	done
	rm -rf ./TEMP
	clear
	if [ ! $Choose == 6 ];then
		echo -e "\e[33m$Compile_Say\e[0m"
	else
		:
	fi
	Say="预期名称:$NEW_Firmware_Name" && Color_Y
	echo " "
	Say="开始编译$Project..." && Color_Y
	Compile_START=`date +'%Y-%m-%d %H:%M:%S'`
	cd $Home/Projects/$Project
	$Thread
	echo " "
	if [ $X86_Check == 0 ];then
		if [ -f ./bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Firmware_Name ];then
			Compile_END=`date +'%Y-%m-%d %H:%M:%S'`
			Start_Seconds=$(date --date="$Compile_START" +%s);
			End_Seconds=$(date --date="$Compile_END" +%s);
			echo " "
			echo -ne "\e[34m$Compile_START --> $Compile_END "
			awk 'BEGIN{printf "本次编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'
			echo -ne "\e[0m"
			mv ./bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Firmware_Name $Home/Packages/$NEW_Firmware_Name
			cd $Home/Packages
			Firmware_Size=`ls -l $NEW_Firmware_Name | awk '{print $5}'`
			echo -e "$Yellow编译成功!固件已自动移动到'$Home/Packages' "
			echo "固件名称:$NEW_Firmware_Name"
			awk 'BEGIN{printf "固件大小:%.2fMB\n",'$((Firmware_Size))'/1000000}'
			echo -ne "$White"
		else
			echo " "
			Compile_END=`date +'%Y-%m-%d %H:%M:%S'`
			Start_Seconds=$(date --date="$Compile_START" +%s);
			End_Seconds=$(date --date="$Compile_END" +%s);
			echo -ne "\e[34m$Compile_START --> $Compile_END "
			awk 'BEGIN{printf "本次编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'
			Say="编译失败!" && Color_R
		fi
	else
		echo "所选编译设备为X86架构，请自行前往'$Home/Projects/$Project/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET'查看结果."
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
	if [ -f ./Config/$Project.branch ];then
		GET_Branch=`(awk 'NR==1' ./Config/$Project.branch)`
		Say="已检测到$Project源码,当前分支:$GET_Branch" && Color_Y
	else
		Say="已检测到$Project源码!" && Color_Y
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
	echo "2.强制更新源代码且合并到本地"
	echo "3.添加第三方主题包"
	echo -e "4.$Red磁盘清理$White"
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
		cd $Home/Projects/$Project
		clear
		git fetch --all
		git reset --hard origin/master
		git pull
		Enter
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
				if [ -f ./Config/$Project.branch ];then
					rm ./Config/$Project.branch
					Say="已删除$Project.branch" && Color_Y
				else
					:
				fi
				Say="[$Project项目]删除成功!" && Color_Y
			else 
				Say="[$Project项目]删除失败!" && Color_R
			fi
			sleep 3
			break
		esac
	done
	;;
	5)
		cd $Home/Projects/$Project
		rm .config
		rm .config.old
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
echo "5.恢复[$Project源代码]"
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
	echo "1.标准名称/文件格式:[$Project-版本号-日期_时间]"
	echo "2.自定义文件名称"
	echo "q.返回"
	GET_Choose
	echo " "
	case $Choose in
	q)
		break
	;;
	1)
		Config_Name=$Project-$Version-`(date +%m%d_%H:%M)`
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
	sleep 3
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
		rm $Config_PATH_NAME
		cp ./Backups/$Config_Recovery $Config_PATH_NAME
		if [ -f $Config_PATH_NAME ];then
			Say="恢复成功!" && Color_Y
		else
			Say="恢复失败!" && Color_R
		fi
		sleep 3
		break
	else
		Say="未找到'$Config_Recovery',请检查是否输入正确!" && Color_R
		sleep 3
	fi
done
;;
3)
	echo " "
	cd $Home/Projects
	if [ ! -d ./$Project/dl ];then
		Say="没有找到'$Home/$Project/dl'文件夹,无法进行备份!" && Color_R
		Say="您似乎还没有下载$Project源代码或编译." && Color_R
	else
		Say="备份中,请耐心等待!" && Color_B
		cp -a $Home/Projects/$Project/dl $Home/Backups/
		echo " "
		Say="备份成功![dl]库已备份到:'$Home/Backups/dl'" && Color_Y
		cd $Home/Backups
		dl_Size=$((`du --max-depth=1 dl |awk '{print $1}'`))
		awk 'BEGIN{printf "存储占用:%.2fMB\n",'$((dl_Size))'/1000}'
	fi
	echo " "
	Enter
;;
4)
	echo " "
	cd $Home
	if [ ! -d ./Backups/dl ];then
		Say="没有找到'$Home/Backups/dl'文件夹,无法进行恢复!" && Color_R
		Say="您似乎还没有进行过备份." && Color_R
	else
		Say="恢复中,请耐心等待!" && Color_B
		cp -a $Home/Backups/dl $Home/Projects/$Project
		echo " "
		Say="恢复成功![dl]库已恢复到:'$Home/Projects/$Project/dl'" && Color_Y
		cd $Home/Projects/$Project
		dl_Size=$((`du --max-depth=1 dl |awk '{print $1}'`))
		awk 'BEGIN{printf "存储占用:%.2fMB\n",'$((dl_Size))'/1000}'
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
	echo -e "4.$Yellow[软件库]$BlueLienol's Package Sources$White"
	echo -e "5.$Yellow[软件库]$BlueLean's Package Sources$White"
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
Enter
}

Advanced_Options_1() {
while :
do
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.更新系统软件包"
	echo "2.安装编译所需的依赖包"
	echo "3.SSH访问路由器"
	echo "4.同步网络时间"
	echo "5.清理DNS缓存"
	echo "6.为AutoBuild添加快捷启动"
	echo "7.查看磁盘空间大小"
	echo "8.定时关机"
	echo -e "9.$Yellow更新脚本$White"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
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
		sudo apt-get update
		sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib
		sudo apt-get -y install $Extra_Packages
		echo " "
		Enter
	;;
	3)
		ssh-keygen -R 192.168.1.1
		clear
		echo "路由器默认地址为192.168.1.1"
		ssh root@192.168.1.1
	;;
	4)
		sudo ntpdate cn.pool.ntp.org
		sudo hwclock --systohc
	;;
	5)
		sudo systemctl restart systemd-resolved.service
		sudo systemd-resolve --flush-caches
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
			Say="未检测到.bashrc,无法创建!" && Color_R
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
		Script_Update
	;;
	esac
done
}

function Script_Update() {
	cd $Home
	rm -rf $Home/TEMP
	rm -rf $Home/Modules
	svn checkout $AutoBuild_git/trunk ./TEMP
	echo " "
	if [ -f ./TEMP/AutoBuild.sh ];then
		mv ./TEMP/AutoBuild.sh $Home/AutoBuild.sh
		mv ./TEMP/README.md $Home/README.md
		mv ./TEMP/Modules $Home
		chmod +x AutoBuild.sh
		chmod +x -R $Home/Modules
		Say="更新成功!" && Color_Y
		sleep 3
		./AutoBuild.sh
	else
		Say="更新失败!" && Color_R
		sleep 3
	fi
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

function Sources_Download_Check() {
cd $Home
echo " "
if [ -f "./Projects/$Project/feeds.conf.default" ];then
	cd $Home/Config
	echo "$Branch" > $Project.branch
	cp -r $Home/Projects/$Project $Home/Backups/Projects/$Project
	Say="$Project源码下载成功,已自动备份到'$Home/Backups/Projects/$Project'" && Color_Y
else
	Say="下载失败,请检查网络后重试!" && Color_R
fi
	Enter
}

function Dir_Check() {
	cd $Home
	if [ ! -d ./Projects ];then
		mkdir Projects
	else
		:
	fi
	if [ ! -d ./Modules ];then
		mkdir Modules
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
	if [ ! -d ./Config ];then
		mkdir Config
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
else
	White="\e[0m"
	Yellow="\e[0m"
	Red="\e[0m"
	Blue="\e[0m"
fi
}

function GitSource_Check() {
if [ $GitSource == 1 ];then
	Lede_git=https://gitee.com/Hyy2001X/Lede
	Openwrt_git=https://gitee.com/Hyy2001X/Openwrt
	Lienol_git=https://gitee.com/Hyy2001X/Lienol
	GitSource_Out=Gitee
else
	Lede_git=https://github.com/coolsnowwolf/lede
	Openwrt_git=https://github.com/openwrt/openwrt
	Lienol_git=https://github.com/lienol/openwrt
	GitSource_Out=Github
fi
}


function GET_Choose() {
echo " "
read -p '请从上方选择一个操作:' Choose
}

function Settings_1() {
while :
do
	ColorfulUI_Check
	clear
	Say="设置[实验性]" && Color_B
	echo " "
	if [ $DeveloperMode == 0 ];then
		Say="1.开发者模式	[OFF]" && Color_R
	else
		Say="1.开发者模式	[ON]" && Color_Y
	fi
	if [ $SimpleCompilation == 0 ];then
		Say="2.轻松编译	[OFF]" && Color_R
	else
		Say="2.轻松编译	[ON]" && Color_Y
	fi
	if [ $ColorfulUI == 0 ];then
		Say="3.彩色UI	[OFF]" && Color_R
	else
		Say="3.彩色UI	[ON]" && Color_Y
	fi
	if [ $GitSource == 0 ];then
		Say="4.默认下载源	[Github]" && Color_Y
	else
		Say="4.默认下载源	[Gitee]" && Color_B
	fi
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
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
	esac
done
}

Home=$(cd $(dirname $0); pwd)
Extra_Packages="ntpdate httping subversion"

CPU_Cores=`cat /proc/cpuinfo | grep processor | wc -l`
CPU_Threads=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`

AutoBuild_git=https://github.com/Hyy2001X/AutoBuild

DeveloperMode=0
SimpleCompilation=1
ColorfulUI=1
GitSource=0

chmod +x -R $Home/Modules
source $Home/Modules/NetworkTest.sh

################################################################Main code
while :
do
Dir_Check
ColorfulUI_Check
GitSource_Check
clear
Say="AutoBuild AIO $Version by Hyy2001" && Color_B
echo ""
echo "1.Choose a Project"
echo "2.检查网络连通性"
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
#	if [ -f ./Projects/Custom/feeds.conf.default ];then
#		echo -e "4.Custom_Sources	$Yellow[已检测到]$White"
#	else
#		echo -e "4.Custom_Sources	$Red[未检测到]$White"
#	fi
	echo "q.返回"
	GET_Choose
	if [ $Choose == 1 ]; then
		Project=Lede
	elif [ $Choose == 2 ]; then
		Project=Openwrt
	elif [ $Choose == 3 ]; then
		Project=Lienol
	elif [ $Choose == 4 ]; then
		Project=Custom
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
	4)
		Custom_Second_Menu
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
	Settings_1
;;
esac
done
