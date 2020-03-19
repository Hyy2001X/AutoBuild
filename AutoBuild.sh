#!/bin/bash
# AutoBuild Script by Hyy2001
# Device Support:ALL Device [TEST]
# AutoBuild WorkFolder:[home/username/Openwrt]、[~/Openwrt]
# Support System:Ubuntu 19.10、Ubuntu 18.04 [WSL]
Update=2020.03.19
Main_Version=BETA-V1.1-RC2

function Second_Menu() {
while :
do
	clear
	cd ~/Openwrt
	Dir_Check
	if [ -f "./$Project/feeds.conf.default" ];then
		Say="源码文件:已检测到,当前项目:$Project" && Color_Y
		cd ~/Openwrt/
		if [ $Project == Lede ];then
			if [ -f ./$Project/package/lean/default-settings/files/zzz-default-settings ];then
				cp ./$Project/package/lean/default-settings/files/zzz-default-settings ./TEMP/default.TEMP
				cd ~/Openwrt/TEMP
				Version=$(awk '/DISTRIB_REVISION=/{print}' default.TEMP);
				echo "$Version" > default.TEMP2
				sed -i 's/\"//g' default.TEMP2
				Version=`(awk 'NR==1' default.TEMP2)`
				cd .. && rm -rf TEMP
				Version=${Version:22}
				Version=${Version%>>*}
				Say="版本号:$Version" && Color_Y
			else
				Say="版本号:未知" && Color_R
			fi
		elif [ $Project == Openwrt ];then
			rm -rf TEMP
		elif [ $Project == Lienol ];then
			if [ -f ./$Project/package/default-settings/files/zzz-default-settings ];then
				cp ./$Project/package/default-settings/files/zzz-default-settings ./TEMP/default.TEMP
				cd ~/Openwrt/TEMP
				Version=$(awk '/DISTRIB_REVISION=/{print}' default.TEMP);
				echo "$Version" > default.TEMP2
				sed -i 's/\"//g' default.TEMP2
				Version=`(awk 'NR==1' default.TEMP2)`
				cd .. && rm -rf TEMP
				Version=${Version:22}
				Version=${Version%>>*}
				Say="版本号:$Version" && Color_Y
			else
				Say="版本号:未知" && Color_R
			fi
		else
			:
		fi
		Sources_ERROR=0
	else
		Say="源码文件:错误,请前往[高级选项]下载!" && Color_R
		rm -rf TEMP
		Sources_ERROR=1
	fi
	echo " "
	echo "1.更新$Project源代码和Feeds"
	echo "2.打开固件配置界面"
	echo "3.备份与恢复"
	echo "4.执行编译"
	echo "5.高级选项"
	echo "q.返回"
	if [ $Sources_ERROR == 0 ];then
		GET_Choose
	elif [ $Sources_ERROR == 1 ];then
		echo " "
		read -p '请从上方选择一个操作[部分功能不可用]:' Choose
	else
		:
	fi
	case $Choose in
	q)
		break
	;;
	1)
		Update		
	;;
	2)
		Edit_Menuconfig
	;;
	3)
		Backup_Recovery
	;;
	4)
		Compile_Firmware
	;;
	5)
		Adv_Option
	;;
	esac
done
}

function Update() {
	clear
	cd ~/Openwrt/$Project
	git pull
	./scripts/feeds update -a
	./scripts/feeds install -a
	echo " "
	Say="$Project源代码和Feeds更新完成!" && Color_Y
	Enter
}

function Compile_Firmware() {
while :
do
	cd ~Openwrt
	if [ ! -d ./TEMP ];then
		mkdir TEMP
	else
		:
	fi
	cd ~/Openwrt/$Project
	if [ -f ".config" ];then
		clear
		cp ~/Openwrt/$Project/.config ~/Openwrt/TEMP/$Project.TEMP
		cd ~/Openwrt/TEMP
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
		NEW_BOARD=${PROCESSED_BOARD:20}
		NEW_SUBTARGET=${PROCESSED_SUBTARGET:24}	
		if [ ! $NEW_BOARD == x86 ];then
			NEW_PROFILE=${PROCESSED_PROFILE:29}
			X86SET=0
		else
			NEW_PROFILE=${PROCESSED_PROFILE:22}
			X86SET=1
		fi
		echo CPU架构:$NEW_BOARD
		echo 处理器型号:$NEW_SUBTARGET
		echo 设备名称:$NEW_PROFILE
	else
		echo " "
		Say="未检测到配置文件,无法进行编译!" && Color_R
		sleep 3
		break
	fi
	echo " "
	echo "1.make"
	echo "2.make V=s"
	echo "3.make -j4"
	echo "4.make -j4 V=s"
	echo "5.make -j8"
	echo "6.make -j8 V=s"	
	Say="7.make -j16" && Color_R
	Say="8.make -j16 V=s" && Color_R
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		j=1
		LOG=0
	;;
	2)
		j=1
		LOG=1
	;;
	3)
		j=4
		LOG=0
	;;
	4)
		j=4
		LOG=1
	;;
	5)
		j=8
		LOG=0
	;;
	6)
		j=8
		LOG=1
	;;
	7)
		j=16
		LOG=0
	;;
	8)
		j=16
		LOG=1
	;;
	esac
	if [ $LOG == 0 ];then
		Thread="make -j$j"
		Compile_Say="当前选择:使用$j线程编译,不在屏幕上输出日志[快]"
	else
		Thread="make -j$j V=s"
		Compile_Say="当前选择:使用$j线程编译,并在屏幕上输出日志[慢]"
	fi
	echo -e "\e[33m$Compile_Say\e[0m"
	Firmware_Name=openwrt-$NEW_BOARD-$NEW_SUBTARGET-$NEW_PROFILE-squashfs-sysupgrade.bin
	read -p '请输入附加信息:' Extra
	NEW_Firmware_Name="AutoBuild-$NEW_PROFILE-$Project`(date +-%Y%m%d-$Extra.bin)`"
	cd ~/Openwrt
	while [ -f "./Packages/$NEW_Firmware_Name" ]
	do
		read -p '附加信息重复!请重新添加:' Extra
		NEW_Firmware_Name="AutoBuild-$NEW_PROFILE-$Project`(date +-%Y%m%d-$Extra.bin)`"
	done
	rm -rf ./TEMP
	clear
	echo -e "\e[33m$Compile_Say\e[0m"
	Say="开始编译$Project..." && Color_Y
	Compile_START=`date +'%Y-%m-%d %H:%M:%S'`
	cd ~/Openwrt/$Project
	$Thread
	echo " "
	if [ $X86SET == 0 ];then
		if [ -f ./bin/targets/$NEW_BOARD/$NEW_SUBTARGET/$Firmware_Name ];then
			Compile_END=`date +'%Y-%m-%d %H:%M:%S'`
			Start_Seconds=$(date --date="$Compile_START" +%s);
			End_Seconds=$(date --date="$Compile_END" +%s);
			echo " "
			echo -ne "\e[34m$Compile_START --> $Compile_END "
			awk 'BEGIN{printf "本次编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'
			echo -ne "\e[0m"
			mv ./bin/targets/$NEW_BOARD/$NEW_SUBTARGET/$Firmware_Name ~/Openwrt/Packages/$NEW_Firmware_Name
			cd ~/Openwrt/Packages
			Firmware_Size=`ls -l $NEW_Firmware_Name | awk '{print $5}'`	
			echo -e "\e[33m编译完成!固件已自动移动到'主目录/Openwrt/Packages' "
			echo "固件名称:$NEW_Firmware_Name"
			awk 'BEGIN{printf "固件大小:%.2fMB\n",'$((Firmware_Size))'/1000000}'
			echo -ne "\e[0m"
		else
			echo " "
			Compile_END=`date +'%Y-%m-%d %H:%M:%S'`
			Start_Seconds=$(date --date="$Compile_START" +%s);
			End_Seconds=$(date --date="$Compile_END" +%s);
			echo -ne "\e[34m$Compile_START --> $Compile_END "
			awk 'BEGIN{printf "本次编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'
			Say="编译失败!" && Color_R
			Say="可能原因如下:" && Color_R
			Say="	1.编译可能成功了,但是设备可能不受AutoBuild支持,请自行前往'主目录/Openwrt/$Project/bin/'查看." && Color_R
			Say="	2.编译出错,请使用日志输出编译以进行分析" && Color_R
			Say="	3.网络原因导致依赖包下载失败,使用梯子进行编译"
		fi
	else
		echo "本次编译为X86架构，请自行前往'主目录/Openwrt/$Project/bin/targets/$NEW_BOARD/$NEW_SUBTARGET'查看结果."
	fi
	echo " "
	Enter
	break
done
}
function Adv_Option() {
cd ~/Openwrt/$Project
while :
do
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.从Github拉取$Project源代码"
	echo "2.强制更新源代码且合并到本地"
	echo "3.加载第三方主题"
	Say="4.磁盘清理" && Color_R
	echo "5.删除配置文件"
	echo "6.添加第三方软件包"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		cd ~/Openwrt
		if [ -f "./$Project/LICENSE" ];then
			echo " "
			Say="已检测到$Project项目,无需下载!" && Color_R
			sleep 3
		else
			clear
			if  [ $Project == 'Lede' ];then
				git clone https://github.com/coolsnowwolf/lede $Project
				Sources_Download_Check
			elif [ $Project == 'Openwrt' ];then
			while :
			do
				clear
				Say="$Project分支选择" && Color_B && echo " "
				Branch_1=master
				Branch_2=lede-17.01
				Branch_3=openwrt-18.06
				Branch_4=openwrt-19.07
				echo "1.$Branch_1[Default]" && echo "2.$Branch_2"
				echo "3.$Branch_3" && echo "4.$Branch_4"
				echo "q.返回"
				echo ""
				read -p '请从上方选择一个分支:' Branch
				clear
				case $Branch in
				q)
					break
				;;
				1)
					git clone https://github.com/openwrt/openwrt $Project
				;;
				2)
					git clone -b $Branch_2 https://github.com/openwrt/openwrt $Project
				;;
				3)
					git clone -b $Branch_3 https://github.com/openwrt/openwrt $Project
				;;
				4)
					git clone -b $Branch_4 https://github.com/openwrt/openwrt $Project
				;;
				esac
					Sources_Download_Check
				break
			done
			elif [ $Project == 'Lienol' ];then			
			while :
			do
				clear
				Say="$Project分支选择" && Color_B && echo " "
				Branch_1=dev-19.07
				Branch_2=dev-lean-lede
				Branch_3=dev-master
				echo "1.$Branch_1[Default]" && echo "2.$Branch_2"
				echo "3.$Branch_3"
				echo "q.返回"
				echo ""
				read -p '请从上方选择一个分支:' Branch
				clear
				case $Branch in
				q)
					break
				;;
				1)
					git clone -b $Branch_1 https://github.com/Lienol/openwrt $Project
				;;
				2)
					git clone -b $Branch_2 https://github.com/Lienol/openwrt $Project
				;;
				3)
					git clone -b $Branch_3 https://github.com/Lienol/openwrt $Project
				;;
				esac
					Sources_Download_Check
				break
			done
			else 
					:
			fi
		fi
	;;
	2)
		cd ~/Openwrt/$Project
		clear
		git fetch --all
		git reset --hard origin/master
		git pull
		Enter
	;;
	3)
		clear
		cd ~/Openwrt
		if [ -d ./$Project/package/themes ];then
			:
		else
			cd ~/Openwrt/$Project/package
			mkdir themes
		fi
		clear
		if [ $Project == 'Lede' ];then
			cd ~/Openwrt/Lede/package/lean
			rm -rf luci-theme-argon
			Say="已删除'Lede/package/lean/luci-theme-argon'" && Color_Y
			git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
			cd ~/Openwrt/Lede/package/themes
			rm -rf luci-theme-rosy
			Say="已删除'$Project/package/themes/luci-theme-rosy'" && Color_Y
			git clone https://github.com/rosywrt/luci-theme-rosy luci-theme-rosy
			cd ~/Openwrt/Lede
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
				Say="已更新主题包 luci-theme-argon" && Color_Y
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
			cd ~/Openwrt/$Project/package/themes
			rm -rf luci-theme-argon
			Say="已删除'$Project/package/themes/luci-theme-argon'" && Color_Y
			git clone https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
			echo " "
			Say="已添加主题包 luci-theme-argon" && Color_Y
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
		case $Choose in
		q)
			break
		;;
		1)
			cd ~/Openwrt/$Project
			make clean
			sleep 3
			break
		;;
		2)
			cd ~/Openwrt/$Project
			make dirclean
			sleep 3
			break
		;;
		3)
			cd ~/Openwrt/$Project
			make distclean
			sleep 3
			break
		;;
		4)
			cd ~/Openwrt
			echo " "
			Say="正在删除$Project,请耐心等待..." && Color_B
			rm -rf $Project
			if [ ! -d ./$Project ];then
				Say="删除成功!" && Color_Y
			else 
				Say="删除失败,请重试!" && Color_R
			fi
			sleep 3
			break
		esac
	done
	;;
	5)
		cd ~/Openwrt/$Project
		rm .config
		rm .config.old
		Say="删除成功!" && Color_Y
		sleep 3
	;;
	6)
	while :
	do
		cd ~/Openwrt/$Project/package
		if [ ! -d ./custom ];then
			mkdir custom
		else
			:
		fi
		clear
		Say="手动添加软件包" && Color_B
		echo " "
		echo "1.SmartDNS"
		echo "2.AdGuardHome"
		echo "3.Lienol软件源"
		echo "q.返回"
		cd ~/Openwrt/$Project/package/custom
		GET_Choose
		case $Choose in
		q)
			break	
		;;
		1)
			clear
			if [ ! -d ./SmartDNS ];then
				:
			else
				rm -rf SmartDNS
				Say="已删除软件包 luci-app-smartdns" && Color_Y
				Say="已删除软件包 smartdns" && Color_Y
			fi
			git clone https://github.com/Hyy2001X/SmartDNS.git
			echo " "
			if [ -f ./SmartDNS/luci-app-smartdns/Makefile ];then
				Say="已成功添加软件包 luci-app-smartdns" && Color_Y
			else
				Say="未成功添加软件包 luci-app-smartdns,请重试!" && Color_R
			fi
			if [ -f ./SmartDNS/smartdns/Makefile ];then
				Say="已成功添加软件包 smartdns" && Color_Y
			else
				Say="未成功添加软件包 smartdns,请重试!" && Color_R
			fi
			Enter
		;;
		2)
			clear
			if [ ! -d ./AdGuardHome ];then
				:
			else
				rm -rf AdGuardHome
				Say="已删除软件包 luci-app-adguardhome" && Color_Y
				Say="已删除软件包 adguardhome" && Color_Y
			fi
			git clone https://github.com/Hyy2001X/AdGuardHome.git
			echo " "
			if [ -f ./AdGuardHome/luci-app-adguardhome/Makefile ];then
				Say="已成功添加软件包 luci-app-adguardhome" && Color_Y
			else
				Say="未成功添加软件包 luci-app-adguardhome,请重试!" && Color_R
			fi
			if [ -f ./AdGuardHome/adguardhome/Makefile ];then
				Say="已成功添加软件包 adguardhome" && Color_Y
			else
				Say="未成功添加软件包 adguardhome,请重试!" && Color_R
			fi
			Enter
		;;
		3)
			cd ~/Openwrt/$Project
			grep "lienol" feeds.conf.default > /dev/null
			if [ $? -eq 0 ]; then
				echo " "
				Say="已检测到Lienol软件源,无需添加!" && Color_Y
			else
				echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default
				echo " "
				grep "lienol" feeds.conf.default > /dev/null
				if [ $? -eq 0 ]; then
					Say="已添加Lienol软件源到feeds.conf.default" && Color_Y
				else
					Say="添加失败!" && Color_R
				fi
			fi
			sleep 3
		;;
		esac
	done
	;;	
	esac
done
}

function Dir_Check() {
	cd ~/Openwrt
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
	
#	if [ ! -d ./Config ];then
#		mkdir Config
#	else
#		:
#	fi
}

function Backup_Recovery() {
while :
do
clear
Say="备份与恢复" && Color_B
echo " "
echo "1.备份[.config]"
echo "2.恢复[.config]"
echo "3.备份[dl]文件夹"
echo "4.恢复[dl]文件夹"
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
	echo "1.标准名称/文件格式:[$Project-当前日期_时间]"
	echo "2.自定义文件名称"
	echo "q.返回"
	GET_Choose
	echo " "
	case $Choose in
	q)
		break
	;;
	1)
		cp ~/Openwrt/$Project/.config ~/Openwrt/Backups/$Project-`(date +%m%d_%H:%M)`
		Say="备份完成!备份文件存放于:主目录/Openwrt/Backups/$Project-`(date +%m%d_%H:%M)`" && Color_Y
	;;
	2)
		read -p '请输入你想要的文件名[名称不能为'q']:' Config_Backup
		echo " "
		cp ~/Openwrt/$Project/.config ~/Openwrt/Backups/$Config_Backup
		Say="备份完成!备份文件存放于:主目录/Openwrt/Backups/$Config_Backup" && Color_Y
	;;	
	esac
	Enter
done
;;
2)
while :
do
	clear
	Say="当前操作:恢复[.config]" && Color_B && echo " "
	cd ~/Openwrt/Backups
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
		cp ~/Openwrt/Backups/$Config_Recovery ~/Openwrt/$Project/.config
		Say="恢复完成!" && Color_Y
		Enter
		break
	else
		Say="未找到'$Config_Recovery',请确认是否输入正确!按下[回车]键重试" && Color_R
		read -p "" Key
	fi
done
;;
3)
	echo " "
	cd ~/Openwrt/
	if [ ! -d ./$Project/dl ];then
		Say="没有找到'主目录/Openwrt/$Project/dl'文件夹,无法进行备份!" && Color_R
		Say="您似乎还没有下载$Project源代码或编译." && Color_R
	else
		Say="备份中,请耐心等待!" && Color_B
		cp -a ~/Openwrt/$Project/dl ~/Openwrt/Backups/
		Say="完成![dl]文件夹已备份到:'主目录/Openwrt/Backups/dl'" && Color_Y
		cd ~/Openwrt/Backups
		dl_Size=$((`du --max-depth=1 dl |awk '{print $1}'`))
		awk 'BEGIN{printf "存储占用:%.2fMB\n",'$((dl_Size))'/1000}'
	fi
	echo " "
	Enter
;;
4)
	echo " "
	cd ~/Openwrt
	if [ ! -d ./Backups/dl ];then
		Say="没有找到'主目录/Openwrt/Backups/dl'文件夹,无法进行恢复!" && Color_R
		Say="您似乎还没有进行过备份." && Color_R
	else
		Say="恢复中,请耐心等待!" && Color_B
		cp -a ~/Openwrt/Backups/dl ~/Openwrt/$Project
		Say="完成![dl]文件夹已恢复到:'主目录/Openwrt/$Project/dl'" && Color_Y
		cd ~/Openwrt/$Project
		dl_Size=$((`du --max-depth=1 dl |awk '{print $1}'`))
		awk 'BEGIN{printf "存储占用:%.2fMB\n",'$((dl_Size))'/1000}'
		
	fi
	echo " "
	Enter
;;
esac
done
}

function Edit_Menuconfig() {
clear
cd ~/Openwrt/$Project
Say="Loading $Project Configuration..." && Color_B
make menuconfig
Enter
}

function Danger_Enter() {
read -p "危险动作!请按下[回车]键以继续操作!" Key
read -p "请再次按下[回车]键以确认操作!" Key
}

function Enter() {
read -p "按下[回车]键以继续..." Key
}

function Color_Y() {
echo -e "\e[33m$Say\e[0m"
}

function Color_R() {
echo -e "\e[31m$Say\e[0m"
}

function Color_B() {
echo -e "\e[34m$Say\e[0m"
}

function Sources_Download_Check() {
echo " "
if [ -f "./$Project/feeds.conf.default" ];then
	Say="$Project源代码下载完成!" && Color_Y	
else
	Say="下载失败,请检查网络后重试!" && Color_R
fi
	Enter
}

function GET_Choose() {
echo " "
read -p '请从上方选择一个操作:' Choose
}

################################################################MainBuild
################################################################MainBuild
while :
do
Dir_Check
clear
Say="AutoBuild AIO $Main_Version by Hyy2001" && Color_B
echo ""
echo "1.Choose a Project"
echo "2.检查网络连通性"
echo "3.高级选项"
echo "q.退出"
GET_Choose
case $Choose in
q)
	rm -rf ~/Openwrt/TEMP
	clear
	break
;;
1)
while :
do
	clear
	cd ~/Openwrt
	Say="AutoBuild AIO $Main_Version by Hyy2001" && Color_B
	echo " "
	if [ -f ./Lede/feeds.conf.default ];then
		echo -e "1.Lede		\e[33m[已检测到]\e[0m"
	else
		echo -e "1.Lede		\e[31m[未检测到]\e[0m"
	fi
	if [ -f ./Openwrt/feeds.conf.default ];then
		echo -e "2.Openwrt	\e[33m[已检测到]\e[0m"
	else
		echo -e "2.Openwrt	\e[31m[未检测到]\e[0m"
	fi
	if [ -f ./Lienol/feeds.conf.default ];then
		echo -e "3.Lienol	\e[33m[已检测到]\e[0m"
	else
		echo -e "3.Lienol	\e[31m[未检测到]\e[0m"
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
		Second_Menu
	;;
	2)
		Second_Menu
	;;
	3)
		Second_Menu
	;;
	esac
done
;;
2)
	clear
	Say="Network Connectivity Test" && Color_B
	echo " "
	Network_OK="\e[33m连接正常\e[0m"
	Network_ERROR="\e[31m连接错误\e[0m"
	httping -c 1 www.baidu.com > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -e "Baidu       $Network_OK" 
	else
		echo -e "Baidu       $Network_ERROR"
	fi
	httping -c 1 www.github.com > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -e "Github      $Network_OK" 
	else
		echo -e "Github      $Network_ERROR"
	fi
	httping -c 1 www.google.com > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -e "Google      $Network_OK" 
	else
		echo -e "Google      $Network_ERROR"
	fi
	echo ""
	Enter	
;;
3)
while :
do
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.更新系统软件包"
	echo "2.安装编译所需的依赖包"
	echo "3.SSH访问路由器"
	echo "4.同步系统时间"
	echo "5.清理DNS缓存"
	echo "6.为AutoBuild添加快捷启动"
	echo "7.查看磁盘空间大小"
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
		sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler ntpdate httping
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
		read -p '请创建一个快捷启动的名称:' FastOpen		
		echo "alias $FastOpen='~/Openwrt/AutoBuild.sh'" >> ~/.bashrc
		source ~/.bashrc
		Say="创建完成!下次在终端输入 $FastOpen 即可启动AutoBuild[需要重启终端]." && Color_Y
		Enter
	;;
	7)
		clear
		df -h
		echo " "
		Enter
	;;
	esac
done
;;
esac
done
