#!/bin/bash
# Project	AutoBuild
# Author	Hyy2001、Nxiz
# Github	https://github.com/Hyy2001X/AutoBuild
# Supported System:Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04、Deepin 20
Update=2020.08.14
Version=V3.9.2-b

Second_Menu() {
while :
do
	Dir_Check
	clear
	if [ -f ./Projects/$Project/Makefile ];then
		Say="源码位置:$Home/Projects/$Project" && Color_Y
		if [ $Project == Lede ];then
			if [ -f ./Projects/$Project/package/lean/default-settings/files/zzz-default-settings ];then
				cd ./Projects/$Project/package/lean/default-settings/files
				Lede_Version=`egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" zzz-default-settings`
				Say="源码版本:$Lede_Version" && Color_Y
			fi
		fi
		cd $Home
		if [ -f ./Configs/${Project}_Lasted_Update ];then
			Lasted_Update=`cat ./Configs/${Project}_Lasted_Update`
			echo -e "$Yellow最近更新:$Blue$Lasted_Update$White"
		fi
		cd $Home/Projects/$Project
		Branch=`git branch | sed 's/* //g'`
	else
		Say="未检测到[$Project]源码,请前往[高级选项]下载!" && Color_R
	fi
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
		Sources_Update_Check
	;;
	2)
		Make_Menuconfig
	;;
	3)
		Backup_Restore
	;;
	4)
		SimpleCompilation_Check
	;;
	5)
		Project_Options
	;;
	esac
done
}

Sources_Download() {
if [ -f $Home/Projects/$Project/Makefile ];then
	Say="\n已检测到[$Project]项目,当前分支:$Branch" && Color_Y
	sleep 3
else
	clear
	Say="$Project源代码下载-选择分支" && Color_B
	Github_File=$Home/Additional/GitLink_$Project
	Final_GitLink=`sed -n 1p $Github_File`
	echo "Github仓库地址:$Final_GitLink"
	echo " "
	Max_All_Line=`sed -n '$=' $Github_File`
	Max_Branch_Line=`expr $Max_All_Line - 1`
	for ((i=2;i<=$Max_All_Line;i++));
	do   
		Github_File_Branch=`sed -n ${i}p $Github_File`
		x=`expr $i - 1`
		echo "${x}.${Github_File_Branch}"
	done
	echo "q.返回"
	echo " "
	read -p '请从上方选择一个分支:' Choose_Branch
	case $Choose_Branch in
	q)
		break
	;;
	*)
		clear
		if [ $Choose_Branch -le $Max_Branch_Line ];then
			Branch_Line=`expr $Choose_Branch + 1`
			Final_GitBranch=`sed -n ${Branch_Line}p $Github_File`
			echo -e "$Blue下载地址:$Yellow$Final_GitLink$White"
			echo -e "$Blue下载分支:$Yellow$Final_GitBranch$White"
			echo " "
			cd $Home/Projects/
			git clone -b $Final_GitBranch $Final_GitLink $Project
			Sources_Download_Check
		else
			Sources_Download
		fi
	;;
	esac
fi
}

Project_Options() {
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
		Sources_Update_Check
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
			Say="\n正在删除$Project..." && Color_B
			echo " "
			rm -rf $Project
			break
		;;
		5)
			rm -rf $Home/Projects/$Project/tmp
			Say="\n$Yellow[临时文件/编译缓存]删除成功!" && Color_Y
		;;
		6)
			rm -f $Home/Log/Update_${Project}_*
			Say=\n"$Yellow[更新日志]删除成功!" && Color_Y
		;;
		7)
			rm -f $Home/Log/Compile_${Project}_*
			Say="\n$Yellow[编译日志]删除成功!" && Color_Y
		;;
		esac
		sleep 2
	done
	;;
	6)
		cd $Home/Projects/$Project
		rm -f ./.config*
		Say="\n[配置文件]删除成功!" && Color_Y
		sleep 2
	;;
	7)
		echo " "
		timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
		if [ $? -eq 0 ];then
			cd $Home/Projects/$Project
			clear
			make -j$CPU_Threads download V=s
			find dl -size -1024c -exec rm -f {} \;
			awk 'BEGIN { cmd="cp -ri ./dl/* ../../Backups/dl/"; print "n" |cmd; }' > /dev/null 2>&1
			Say="\n[dl]库下载结束,存储占用:$(du -sh dl | awk '{print $1}')B" && Color_B
			Enter
		else
			Say="网络连接错误,[dl]库下载失败!" && Color_R
			sleep 2
		fi
	;;
	esac
done
}

Backup_Restore() {
while :
do
	clear
	Say="备份与恢复" && Color_B
	echo " "
	echo "1.备份[.config]"
	echo "2.恢复[.config]"
	echo "3.备份[dl]库"
	echo "4.恢复[dl]库"
	echo "5.备份[$Project]源代码"
	echo "6.恢复[$Project]源代码"
	echo " "
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
				cp ./Projects/$Project/.config ./Backups/Configs/"$Backup_Config"
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
	if [ ! "`ls -A $Home/Backups/Configs`" = "" ];then
	while :
	do
		clear
		Say="恢复[.config]" && Color_B && echo " "
		cd $Home/Backups/Configs
		ls -A | cat > $Home/TEMP/Config.List
		ConfigList_File=$Home/TEMP/Config.List
		Max_ConfigList_Line=`sed -n '$=' $ConfigList_File`
		for ((i=1;i<=$Max_ConfigList_Line;i++));
		do   
			ConfigFile_Name=`sed -n ${i}p $ConfigList_File`
			echo -e "${i}.$Yellow${ConfigFile_Name}$White"
		done
		echo -e "\nq.返回\n"
		read -p '请从上方选择一个文件:' Choose
		case $Choose in
		q)
			break
		;;
		*)
			if [ $Choose -le $Max_ConfigList_Line ];then
				echo " "
				ConfigFile=`sed -n ${Choose}p $ConfigList_File`
				if [ -f "$ConfigFile" ];then
					ConfigFile_Dir="$Home/Backups/Configs/$ConfigFile"
					cp "$ConfigFile_Dir" $Home/Projects/$Project/.config
					Say="[$ConfigFile]恢复成功!" && Color_Y
					sleep 2
				else
					Say="未检测到对应的配置文件!" && Color_R
					sleep 2
				fi
			else
				Say="输入错误,请输入正确的数字!" && Color_R
				sleep 2
			fi
		;;
		esac
	done
	else
		Say="\n未检测到备份文件!" && Color_R
		sleep 2
	fi
	;;
	3)
		echo " "
		cd $Home/Projects
		if [ ! -d ./$Project/dl ];then
			Say="未找到'$Home/Projects/$Project/dl',备份失败!" && Color_R
			sleep 2
		else
			echo -ne "\r$Yellow正在备份[dl]库...$White\r"
			cp -a $Home/Projects/$Project/dl $Home/Backups/
			Say="备份成功![dl]库已备份到:'$Home/Backups/dl'" && Color_Y
			Say="存储占用:$(du -sh $Home/Backups/dl | awk '{print $1}')B" && Color_B
			Enter
		fi
	;;
	4)
		echo " "
		cd $Home
		if [ ! -d ./Backups/dl ];then
			Say="未找到'$Home/Backups/dl',恢复失败!" && Color_R
			sleep 2
		else
			echo -ne "\r$Blue正在恢复[dl]库...$White\r"
			cp -a $Home/Backups/dl $Home/Projects/$Project
			Say="恢复成功![dl]库已恢复到:'$Home/Projects/$Project/dl'" && Color_Y
			Say="存储占用:$(du -sh $Home/Projects/$Project/dl | awk '{print $1}')B" && Color_B
			Enter
		fi
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
		Enter
	;;
	6)
		echo " "
		if [ -f $Home/Backups/Projects/$Project/Makefile ];then
			echo -ne "\r$Yellow正在恢复[$Project]源代码...$White\r"
			sudo cp -a $Home/Backups/Projects/$Project $Home/Projects/
			Say="恢复成功![$Project]源代码已恢复到:'$Home/Projects/$Project'" && Color_Y
			Say="存储占用:$(du -sh $Home/Projects/$Project | awk '{print $1}')B" && Color_B
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
Say="Loading $Project Configuration..." && Color_B
make menuconfig
Enter
}

Advanced_Options() {
while :
do
	clear
	Say="高级选项" && Color_B
	echo " "
	echo "1.更新系统软件包"
	Say="2.安装编译环境" && Color_G
	echo "3.SSH Services"
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
		Enter
	;;
	3)
		echo " "
		cd $Home
		if [ ! -f ./Configs/SSH ];then
			SSH_Profile
			sleep 2
			SSH_Login
		else
			SSH_IP=`awk -F'[="]+' '/IP/{print $2}' ./Configs/SSH`
			SSH_User=`awk -F'[="]+' '/Username/{print $2}' ./Configs/SSH`
			SSH_Password=`awk -F'[="]+' '/Password/{print $2}' ./Configs/SSH`
		fi
		while :
		do
			clear
			Say="SSH Services Script by Hyy2001" && Color_B
			echo " "
			echo "1.使用上次保存的配置连接"
			echo "2.创建[新的配置文件]"
			echo "3.删除[现有配置文件]"
			echo "4.重置[RSA Key Fingerprint]"
			echo -e "\nq.返回"
			GET_Choose
			case $Choose in
			q)
				break
			;;
			1)
				SSH_Login
			;;
			2)
				echo " "
				if [ ! -f ./Configs/SSH ];then
					SSH_Profile
				else
					Say="若要创建[新的配置文件],请先删除[现有配置文件]." && Color_B
				fi
				sleep 3
			;;
			3)
				echo " "
				if [ -f ./Configs/SSH ];then
					rm $Home/Configs/SSH
					Say="[配置文件]删除成功!" && Color_Y
				else
					Say="[配置文件]删除失败!" && Color_R
				fi
				sleep 2
			;;
			4)
				ssh-keygen -R $SSH_IP
				Say="\n[RSA Key Fingerprint]重置成功!" && Color_Y
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
		StorageDetails
	;;
	6)
		echo " "
		cd ~
		if [ -f .bashrc ];then
			read -p '请输入快捷启动的名称:' FastOpen		
			echo "alias $FastOpen='$Home/AutoBuild.sh'" >> ~/.bashrc
			source ~/.bashrc
			Say="\n创建成功!在终端输入 $FastOpen 即可启动AutoBuild[需要重启终端]." && Color_Y
		else
			Say="创建失败!" && Color_R
		fi
		sleep 3
	;;
	7)
		clear
		df -h
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

Script_Update_Beta() {
timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	clear
	Say="正在下载更新...\n" && Color_Y
	cd $Home/Backups
	if [ "`ls -A ./AutoBuild-Update`" = "" ];then
		git clone https://github.com/Hyy2001X/AutoBuild AutoBuild-Update
	fi
	cd ./AutoBuild-Update
	Update_Logfile=$Home/Log/Script_Update_`(date +%Y%m%d_%H:%M)`.log
	git pull 2>&1 | tee $Update_Logfile
	if [ $(grep -o "fatal: 无法访问" $Update_Logfile | wc -l) = "0" ];then
		if [ $(grep -o "已经是最新的" $Update_Logfile | wc -l) = "1" ];then
			Say="\n强制合并到本地文件..." && Color_Y
		else
			Say="\n合并到本地文件..." && Color_Y
		fi
		Old_Version=`awk 'NR==7' $Home/AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}'`
		Old_Version_Dir=$Old_Version-`(date +%Y%m%d_%H:%M)`
		Backups_Dir=$Home/Backups/OldVersion/AutoBuild-Core-$Old_Version_Dir
		mkdir $Backups_Dir
		mv $Home/AutoBuild.sh $Backups_Dir/AutoBuild.sh
		mv $Home/README.md $Backups_Dir/README.md
		mv $Home/LICENSE $Backups_Dir/LICENSE
		mv $Home/Additional $Backups_Dir/Additional
		mv $Home/Modules $Backups_Dir/Modules
		cp -a * $Home
		Say="\nAutoBuild 已自动备份到'/Backups/OldVersion/AutoBuild-Core-$Old_Version_Dir'" && Color_B
		echo -e "$Yellow"
		read -p "AutoBuild 更新成功!" Key
		$Home/AutoBuild.sh
	else
		echo -e "$Red"
		read -p "AutoBuild 更新失败!" Key
	fi
else
	Say="\n网络连接错误,更新失败!" && Color_R
	sleep 2
fi
}

Script_Update() {
timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	cd $Home
	clear
	Say="开始下载更新..." && Color_Y
	echo " "
	Old_Version=`awk 'NR==7' $Home/AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}'`
	Old_Version_Dir=$Old_Version-`(date +%Y%m%d_%H:%M)`
	Backups_Dir=$Home/Backups/OldVersion/AutoBuild-Core-$Old_Version_Dir
	if [ -d $Backups_Dir ];then
		rm -rf $Backups_Dir
	fi
	mkdir -p $Backups_Dir
	cp $Home/AutoBuild.sh $Backups_Dir/AutoBuild.sh
	cp $Home/README.md $Backups_Dir/README.md
	cp $Home/LICENSE $Backups_Dir/LICENSE
	cp -a $Home/Additional $Backups_Dir/Additional
	cp -a $Home/Modules $Backups_Dir/Modules
	Say="\nAutoBuild 已自动备份到'/Backups/OldVersion/AutoBuild-Core-$Old_Version_Dir'" && Color_B
	rm -rf ./TEMP
	svn checkout https://github.com/Hyy2001X/AutoBuild/trunk ./TEMP
	echo " "
	if [ -f ./TEMP/AutoBuild.sh ];then
		rm -rf ./Modules
		rm -rf ./Additional
		rm -f ./AutoBuild.sh
		mv ./TEMP/* $Home
		chmod +x $Home/AutoBuild.sh
		chmod +x -R $Home/Modules
		New_Version=`awk 'NR==7' $Home/AutoBuild.sh | awk -F'[="]+' '/Version/{print $2}'`
		echo -e "${Yellow}AutoBuild_Core ${Blue}$Old_Version --> $New_Version${Yellow}\n"
		read -p "AutoBuild 更新成功!" Key
		./AutoBuild.sh
	else
		Say="AutoBuild 更新失败!" && Color_R
		sleep 2
	fi
else
	Say="\n网络连接错误,更新失败!" && Color_R
	sleep 2
fi
}

Sources_Update_Check() {
timeout 3 ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	Sources_Update_Core
	Enter
else
	Say="\n网络连接错误,更新失败!" && Color_R
	sleep 2
fi
}

Sources_Update_Core() {
clear
Say="开始更新$Project..." && Color_Y
echo " "
echo `(date +%Y-%m-%d_%H:%M)` > $Home/Configs/${Project}_Lasted_Update
cd $Home/Projects/$Project
if [ $Enforce_Update == 1 ];then
	git fetch --all
	git reset --hard origin/$Branch
fi
Update_Logfile=$Home/Log/Update_${Project}_`(date +%Y%m%d_%H:%M)`.log
git pull 2>&1 | tee $Update_Logfile
./scripts/feeds update -a 2>&1 | tee -a $Update_Logfile
./scripts/feeds install -a 2>&1 | tee -a $Update_Logfile
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
if [ -f $Home/Projects/$Project/Makefile ];then
	cd $Home/Projects/$Project
	cp ./feeds.conf.default $Home/Backups/$Project.feeds.conf.default
	if [ $Project == Lede ];then
		sed -i "s/#src-git helloworld/src-git helloworld/g" ./feeds.conf.default
	fi
	echo -e "$Yellow"
	read -p "[$Project]源代码下载成功!" Key
	Second_Menu
else
	echo -e "$Red"
	read -p "[$Project]源代码下载失败!" Key
fi
}

SSH_Login() {
clear
expect -c "
	set timeout 1
	spawn ssh $SSH_User@$SSH_IP
	expect {
		*yes/no* { send \"yes\r\"; exp_continue }
		*password:* { send \"$SSH_Password\r\" }  
	}
	interact
"
}

SSH_Profile() {
read -p '请输入IP地址:' SSH_IP
read -p '请输入用户名:' SSH_User
read -p '请输入密码:' SSH_Password
echo "IP=$SSH_IP" > ./Configs/SSH
echo "Username=$SSH_User" >> ./Configs/SSH
echo "Password=$SSH_Password" >> ./Configs/SSH
Say="\nSSH配置已保存到'$Home/Configs/SSH'" && Color_Y
}

Dir_Check() {
cd $Home
for WD in `cat  ./Additional/Working_Directory`
do
	if [ ! -d ./$WD ];then
		mkdir -p $WD
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

Script_Update_Check() {
if [ $ScriptUpdater ==  ];then
	Script_Update_Beta
else
	Script_Update
fi

}

AutoBuild_Core() {
while :
do
	Dir_Check
	ColorfulUI_Check
	clear
	Say="AutoBuild Core Script $Version" && Color_B
	Say="\n1.Get Started!" && Color_G
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
		Project_Details Lede 1 coolsnowwolf
		Project_Details Openwrt 2 Openwrt_Team	
		Project_Details Lienol 3 Li2nOnline
		Say="\nx.更新所有源代码和Feeds" && Color_B
		echo "q.返回"
		Decoration
		echo " "
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
			else
				Say="\n网络连接错误,更新失败!" && Color_R
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
set -u

Dependency="build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget swig rsync"
Extra_Dependency="ntpdate httping openssh-client lm-sensors net-tools expect"

CPU_Model=`awk -F':[ ]' '/model name/{printf ($2);exit}' /proc/cpuinfo`
CPU_Cores=`cat /proc/cpuinfo | grep processor | wc -l`
CPU_Threads=`grep 'processor' /proc/cpuinfo | sort -u | wc -l`
CPU_Freq=`awk '/model name/{print ""$NF;exit}' /proc/cpuinfo`

chmod +x -R $Home/Modules
for Module in $Home/Modules/*
do
	source $Module
done

Dir_Check
Settings_Props
AutoBuild_Core
