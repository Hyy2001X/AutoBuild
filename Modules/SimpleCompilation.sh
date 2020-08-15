# AutoBuild Script Module by Hyy2001

SimpleCompilation() {
Update=2020.08.15
Module_Version=V2.3.3-b

ROOTFS_SQUASHFS=0
ROOTFS_EXT4FS=0
ROOTFS_CPIOGZ=0
ROOTFS_TARGZ=0

while :
do
	if [ -f $Home/Projects/$Project/.config ];then
		cd $Home/Projects/$Project
		grep "CONFIG_TARGET_ROOTFS_CPIOGZ=y" .config > /dev/null
		if [ $? -eq 0 ]; then
			ROOTFS_CPIOGZ=1
			Filesystem_Archives=cpio.gz
		fi
		grep "CONFIG_TARGET_ROOTFS_TARGZ=y" .config > /dev/null
		if [ $? -eq 0 ]; then
			ROOTFS_TARGZ=1
			Filesystem_Archives=tar.gz
		fi
		grep "CONFIG_TARGET_ROOTFS_SQUASHFS=y" .config > /dev/null
		if [ $? -eq 0 ]; then
			ROOTFS_SQUASHFS=1
			Filesystem_images=squashfs
		fi
		grep "CONFIG_TARGET_ROOTFS_EXT4FS=y" .config > /dev/null
		if [ $? -eq 0 ]; then
			ROOTFS_EXT4FS=1
			Filesystem_images=ext4
		fi
		Filesystem_All=`expr $ROOTFS_SQUASHFS + $ROOTFS_EXT4FS`
		Filesystem_Archives_All=`expr $ROOTFS_CPIOGZ + $ROOTFS_TARGZ`
		TARGET_BOARD=`awk -F'[="]+' '/TARGET_BOARD/{print $2}' .config`
		TARGET_SUBTARGET=`awk -F'[="]+' '/TARGET_SUBTARGET/{print $2}' .config`
		TARGET_ARCH_PACKAGES=`awk -F'[="]+' '/TARGET_ARCH_PACKAGES/{print $2}' .config`
		PROFILE=`awk -F'[="]+' '/TARGET_PROFILE/{print $2}' .config`
		TARGET_PROFILE=`grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/'`
		grep 'MULTI_PROFILE=y' .config > /dev/null 2>&1
		if [ $? -eq 0 ];then
			MULTI_PROFILE_Check=1
			Default_Check=0
		else
			if [ $PROFILE == Default ];then
				Default_Check=1
			else
				Default_Check=0
			fi
			MULTI_PROFILE_Check=0
		fi
		if [ $TARGET_BOARD == x86 ];then
			X86_Check=1
		else
			X86_Check=0
		fi
		CPU_TEMP=`sensors | grep 'Core 0' | cut -c17-24`
		clear
		Say="Simple Compilation Script $Module_Version" && Color_B
		Say="\nCPU 信息:$CPU_Model $CPU_Cores核心$CPU_Threads线程 $CPU_TEMP" && Color_Y
		Decoration
		if [ $MULTI_PROFILE_Check == 0 ];then
			if [ $Default_Check == 0 ];then
				echo -e "设备名称:${Yellow}$TARGET_PROFILE${White}"
			else
				echo -e "设备名称:${Blue}Default Profile${White}"
			fi
		else
			echo -e "设备名称:${Blue}Multiple Devices$White"
		fi
		echo -e "CPU 架构:$Yellow$TARGET_BOARD$White"
		echo -e "CPU 型号:$Yellow$TARGET_SUBTARGET$White"
		echo -e "软件架构:$Yellow$TARGET_ARCH_PACKAGES$White"
		if [ ! $Filesystem_Archives_All == 0 ];then
			if [ $Filesystem_Archives_All == 2 ];then
				echo -e "固件压缩:${Yellow}cpio.gz tar.gz$White"
			else
				echo -e "固件压缩:$Yellow$Filesystem_Archives$White"
			fi
		fi
		if [ ! $Filesystem_All == 0 ];then
			if [ $Filesystem_All == 2 ];then
				echo -e "固件格式:${Yellow}squashfs ext4$White"
			else
				echo -e "固件格式:$Yellow$Filesystem_images$White"
			fi
		fi
	else
		Say="\n未检测到配置文件,无法编译!" && Color_R
		sleep 3
		break
	fi
	Say="\n编译参数" && Color_B
	echo "1.make -j1"
	echo "2.make -j1 V=s"
	echo "3.make -j4"
	echo "4.make -j4 V=s"
	echo "5.自动选择"
	echo "6.手动输入参数"
	echo "q.返回"
	echo " "
	if [ -f $Home/Configs/${Project}_Lasted_Compile ];then
		Lasted_Compile=`awk 'NR==1' $Home/Configs/${Project}_Lasted_Compile`
		Lasted_Compile_Stat=`awk 'NR==2' $Home/Configs/${Project}_Lasted_Compile`
		echo -e "$Blue最近编译:$Yellow$Lasted_Compile $Lasted_Compile_Stat"
	fi
	Decoration
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		Compile_Parameter="make -j1"
	;;
	2)
		Compile_Parameter="make -j1 V=s"
	;;
	3)
		Compile_Parameter="make -j4"
	;;
	4)
		Compile_Parameter="make -j4 V=s"
	;;
	5)
		Compile_Parameter="make -j$CPU_Threads V=s"
	;;
	6)
		read -p '请输入编译参数:' Compile_Parameter
	;;
	*)
		SimpleCompilation
	;;
	esac
	if [ $X86_Check == 0 ];then
		if [ $MULTI_PROFILE_Check == 0 ];then
			if [ $Default_Check == 0 ];then
				Firmware_Name=openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.bin
				cd $Home
				if [ $Project == Lede ];then
					read -p '请输入附加信息:' Extra
					AutoBuild_Firmware="AutoBuild-$TARGET_PROFILE-$Project-$Lede_Version`(date +-%Y%m%d-$Extra.bin)`"
					while [ -f ./Firmware/$AutoBuild_Firmware ]
					do
						read -p '包含该附加信息的名称已存在!请重新添加:' Extra
						AutoBuild_Firmware="AutoBuild-$TARGET_PROFILE-$Project-$Lede_Version`(date +-%Y%m%d-$Extra.bin)`"
					done
					Firmware_Detail="AutoBuild-$TARGET_PROFILE-$Project-$Lede_Version`(date +-%Y%m%d-$Extra.detail)`"
				else
					read -p '请输入附加信息:' Extra
					AutoBuild_Firmware="AutoBuild-$TARGET_PROFILE-$Project`(date +-%Y%m%d-$Extra.bin)`"
					while [ -f ./Firmware/$AutoBuild_Firmware ]
					do
						read -p '包含该附加信息的名称已存在,请重新添加:' Extra
						AutoBuild_Firmware="AutoBuild-$TARGET_PROFILE-$Project`(date +-%Y%m%d-$Extra.bin)`"
					done
					Firmware_Detail="AutoBuild-$TARGET_PROFILE-$Project`(date +-%Y%m%d-$Extra.detail)`"
				fi
			fi
		fi
	fi
	clear
	if [ $X86_Check == 0 ];then
		rm -rf $Home/Projects/$Project/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET
		if [ $MULTI_PROFILE_Check == 0 ];then
			if [ $Default_Check == 0 ];then
				echo -e "$Yellow固件名称:$Blue$AutoBuild_Firmware$White"
				echo " "
			fi
		fi
	fi
	Say="开始编译$Project..." && Color_Y
	Compile_Start=`date +'%Y-%m-%d %H:%M:%S'`
	echo `(date +%Y-%m-%d_%H:%M)` > $Home/Configs/${Project}_Lasted_Compile
	cd $Home/Projects/$Project
	if [ $SaveCompileLog == 0 ];then
		$Compile_Parameter
	else
		Compile_Date=`(date +%Y%m%d_%H:%M)`
		$Compile_Parameter 2>&1 | tee $Home/Log/Compile_${Project}_${Compile_Date}.log
	fi
	Say="\n检出[dl]库到'$Home/Backups/dl'..." && Color_Y
	awk 'BEGIN { cmd="cp -ri ./dl/* ../../Backups/dl/"; print "n" |cmd; }' > /dev/null 2>&1
	if [ $X86_Check == 0 ];then
		if [ $MULTI_PROFILE_Check == 0 ];then
			if [ $Default_Check == 0 ];then
				if [ -f ./bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Firmware_Name ];then
					Say="检出软件包到'$Home/Packages'...\n" && Color_Y
					cd $Home/Packages
					mkdir -p $TARGET_ARCH_PACKAGES
					Packages_Dir=$Home/Projects/$Project/bin
					cp -a $(find $Packages_Dir/packages -type f -name "*.ipk") ./$TARGET_ARCH_PACKAGES
					mv -f $(find ./$TARGET_ARCH_PACKAGES/ -type f -name "*all.ipk") ./
					echo "成功" >> $Home/Configs/${Project}_Lasted_Compile
					Compile_Time_End
					cd $Home/Projects/$Project
					mv ./bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Firmware_Name $Home/Firmware/$AutoBuild_Firmware
					Say="\n固件位置:$Home/Firmware" && Color_Y
					echo -e "$Yellow固件名称:$Blue$AutoBuild_Firmware$White"
					cd $Home/Firmware
					Firmware_Size=`ls -l $AutoBuild_Firmware | awk '{print $5}'`
					Firmware_Size_MB=`awk 'BEGIN{printf "固件大小:%.2fMB\n",'$((Firmware_Size))'/1000000}'`
					Firmware_MD5=`md5sum $AutoBuild_Firmware | cut -d ' ' -f1`
					Firmware_SHA256=`sha256sum $AutoBuild_Firmware | cut -d ' ' -f1`
					Say="$Firmware_Size_MB" && Color_Y
					Say="\nMD5:$Firmware_MD5" && Color_B
					Say="SHA256:$Firmware_SHA256" && Color_B
					echo "固件名称:$AutoBuild_Firmware" > ./Details/$Firmware_Detail
					echo "$Firmware_Size_MB" >> ./Details/$Firmware_Detail
					echo "$Compile_TIME" >> ./Details/$Firmware_Detail
					echo " " >> ./Details/$Firmware_Detail
					echo "MD5:$Firmware_MD5" >> ./Details/$Firmware_Detail
					echo "SHA256:$Firmware_SHA256" >> ./Details/$Firmware_Detail
				else
					echo " "
					Compile_Time_End
					Say="\n编译失败!" && Color_R
					echo "失败" >> $Home/Configs/${Project}_Lasted_Compile
				fi
			else
				Compile_Time_End
				Say="\n[Default Profile]编译结束." && Color_Y
				
			fi
		else
			Compile_Time_End
			Say="\n[Multiple Devices]编译结束." && Color_Y
		fi
	else
		Compile_Time_End
		Say="\n[x86 Devices]编译结束." && Color_Y
	fi
	Enter
	break
done
}

SimpleCompilation_Check() {
if [ $SimpleCompilation == 1 ];then
	SimpleCompilation
else
	clear
	cd $Home/Projects/$Project
	make -j$(($(nproc) + 1)) V=s
	Enter
fi
}

Compile_Time_End() {
Compile_End=`date +'%Y-%m-%d %H:%M:%S'`
Start_Seconds=$(date --date="$Compile_Start" +%s)
End_Seconds=$(date --date="$Compile_End" +%s)
echo -ne "$Skyb$Compile_Start --> $Compile_End "
Compile_TIME=`awk 'BEGIN{printf "编译用时:%.2f分钟\n",'$((End_Seconds-Start_Seconds))'/60}'`
echo -ne "$Compile_TIME$White"
echo " "
}
