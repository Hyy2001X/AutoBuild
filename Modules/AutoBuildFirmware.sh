# AutoBuild Script Module by Hyy2001

BuildFirmware_UI() {
Update=2020.12.18
Module_Version=V3.2-TEST

while :
do
	GET_TARGET_INFO
	CPU_TEMP=$(sensors | grep 'Core 0' | cut -c17-24)
	[ -z $CPU_TEMP ] && CPU_TEMP=0
	clear
	MSG_TITLE "AutoBuild Firmware Script $Module_Version"
	MSG_COM G "电脑信息:$CPU_Model $CPU_Cores核心$CPU_Threads线程 $CPU_TEMP\n"
	if [ -e $Home/Projects/$Project/.config ];then
		if [ -e $Home/Configs/${Project}_Recently_Config ];then
			echo -e "${Yellow}最近配置文件:${Blue}[$(cat $Home/Configs/${Project}_Recently_Config)]${White}\n"
		fi
		if [ ! $Firmware_Type == x86 ];then
			if [ $PROFILE_MaxLine -gt 1 ];then
				echo -e "设备数量:$PROFILE_MaxLine"
				Firmware_Type=Multi_Profile
			else
				echo -e "设备名称:${Yellow}$TARGET_PROFILE${White}"
				Firmware_Type=Common
			fi
		fi
		if [ $DEFCONFIG == 0 ];then
			echo -e "CPU 架构:${Yellow}$TARGET_BOARD${White}"
			echo -e "CPU 型号:${Yellow}$TARGET_SUBTARGET${White}"
			echo -e "软件架构:${Yellow}$TARGET_ARCH_PACKAGES${White}"
			echo -e "编译类型:${Blue}$Firmware_Type/${Firmware_sfx}"
		else
			echo ""
			MSG_COM R "Warning: Please run 'make defconfig' first!"
		fi
	else
		MSG_COM R "警告:未检测到[.config]文件,部分操作将不可用!"
	fi
	
	echo -e "${Yellow}\n1.make -j1 V=s"
	echo "2.make -j2 V=s"
	echo "3.make -j4"
	echo -e "4.make -j4 V=s${White}"
	echo "5.make menuconfig"
	echo "6.make defconfig"
	echo "7.手动输入参数"
	MSG_COM G "8.高级选项"
	echo "q.返回"
	if [ -e $Home/Configs/${Project}_Recently_Compiled ];then
		Recently_Compiled=$(awk 'NR==1' $Home/Configs/${Project}_Recently_Compiled)
		Recently_Compiled_Stat=$(awk 'NR==2' $Home/Configs/${Project}_Recently_Compiled)
		echo -e "\n${Yellow}最近编译:${Blue}$Recently_Compiled $Recently_Compiled_Stat${White}"
	fi
	echo ""
	read -p '请从上方选择一个操作:' Choose_1
	case $Choose_1 in
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
		Compile_Threads="make -j4"
	;;
	4)
		Compile_Threads="make -j4 V=s"
	;;
	5)
		Make_Menuconfig
	;;
	6)
		echo ""
		MSG_WAIT "正在执行 [make defconfig],请耐心等待..."
		make defconfig
	;;
	7)
		read -p '请输入编译参数:' Compile_Threads
	;;
	8)
		BuildFirmware_Adv
	;;
	esac
	[ $Choose_1 -gt 0 ]&&[ ! $Choose_1 == 5 ]&&[ ! $Choose_1 == 5 ]&&[ ! $Choose_1 == 6 ]&&[ ! $Choose_1 == 8 ]&&[ $Choose_1 -le 8 ] && BuildFirmware_Core
done
}

BuildFirmware_Core() {
Firmware_PATH="$Home/Projects/$Project/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
rm -rf $Firmware_PATH > /dev/null 2>&1
clear
case $Firmware_Type in
x86)
	X86_Images_Check
	MSG_TITLE "已选择的X86固件:"
	for TARGET_IMAGES in $(cat $Home/TEMP/Choosed_FI)
	do
		MSG_COM B "	$TARGET_IMAGES"
	done
	if [ $Project == Lede ];then
		Firmware_INFO="AutoBuild-$TARGET_BOARD-$TARGET_SUBTARGET-$Project-$Lede_Version-$(date +%Y%m%d-%H:%M:%S)"
	else
		Firmware_INFO="AutoBuild-$TARGET_BOARD-$TARGET_SUBTARGET-$Project-$(date +%Y%m%d-%H:%M:%S)"
	fi
	echo ""
;;
Common)
	Firmware_Name="openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.${Firmware_sfx}"
	if [ $Project == Lede ];then
		Firmware_INFO="AutoBuild-$TARGET_PROFILE-$Project-$Lede_Version-$(date +%Y%m%d-%H:%M:%S)"
	else
		Firmware_INFO="AutoBuild-$TARGET_PROFILE-$Project-$(date +%Y%m%d-%H:%M:%S)"
	fi
	AB_Firmware="${Firmware_INFO}.${Firmware_sfx}"
	Firmware_Detail="$Home/Firmware/Details/${Firmware_INFO}.detail"
	echo -e "${Yellow}固件名称:${Blue}$AB_Firmware${White}\n"
;;
Multi_Profile)
	rm -f $Home/TEMP/Multi_TARGET > /dev/null 2>&1
	for TARGET_PROFILE in $(cat  $Home/TEMP/TARGET_PROFILE)
	do
		echo "openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.${Firmware_sfx}" >> $Home/TEMP/Multi_TARGET
	done
;;
esac
if [ $Project == Lede ];then
	cd $Home/Projects/$Project/package/lean/default-settings/files
	Date=$(date +%Y/%m/%d)
	if [ ! $(grep -o "Compiled by $Username" ./zzz-default-settings | wc -l) = "1" ];then
		sed -i "s?$Lede_Version?$Lede_Version Compiled by $Username [$Date]?g" ./zzz-default-settings
	fi
	Old_Date=$(egrep -o "[0-9]+\/[0-9]+\/[0-9]+" ./zzz-default-settings)
	if [ ! $Date == $Old_Date ];then
		sed -i "s?$Old_Date?$Date?g" ./zzz-default-settings
	fi
	cd $Home/Projects/$Project/package/base-files/files/etc
	echo "$Lede_Version-$(date +%Y%m%d)" > openwrt_info
fi
MSG_WAIT "开始编译$Project..."
cd $Home/Projects/$Project
Compile_Started=$(date +"%Y-%m-%d %H:%M:%S")
Compile_Date=$(date +%Y%m%d_%H:%M)
echo $Compile_Started > $Home/Configs/${Project}_Recently_Compiled
if [ $SaveCompileLog == 0 ];then
	$Compile_Threads
else
	$Compile_Threads 2>&1 | tee $Home/Log/BuildOpenWrt_${Project}_${Compile_Date}.log
fi
case $Firmware_Type in
x86)
	Compile_Stopped
	cd $Firmware_PATH
	find ./ -size +20480k -exec echo $@ > $Home/TEMP/Compiled_FI {} \;
	IMAGES_MaxLine=$(sed -n '$=' $Home/TEMP/Compiled_FI)
	echo ""
	if [ ! -z $IMAGES_MaxLine ];then
		mkdir -p $Home/Firmware/$Firmware_INFO
		for Compiled_FI in $(cat $Home/TEMP/Compiled_FI)
		do
			Compiled_FI=${Compiled_FI##*/}
			MSG_SUCC "已检测到: $Compiled_FI"
			mv $Compiled_FI $Home/Firmware/$Firmware_INFO
			MD5=$(md5sum $Compiled_FI | cut -d ' ' -f1)
			SHA256=$(sha256sum $Compiled_FI | cut -d ' ' -f1)
			echo -e "MD5:$MD5\nSHA256:$SHA256" > $Home/Firmware/$Firmware_INFO/${Compiled_FI}.detail
		done
		MSG_SUCC "固件位置:Firmware/$Firmware_INFO"
	fi
	MSG_SUCC "编译结束!"
;;
Common)
	Compile_Stopped
	if [ -e $Firmware_PATH/$Firmware_Name ];then
		Checkout_Package
		echo "成功" >> $Home/Configs/${Project}_Recently_Compiled
		cd $Home/Projects/$Project
		mv $Firmware_PATH/$Firmware_Name $Home/Firmware/$AB_Firmware
		cd $Home/Firmware
		MSG_SUCC "固件位置:$Home/Firmware"
		echo -e "${Yellow}固件名称:${Blue}$AB_Firmware"
		Size=$(awk 'BEGIN{printf "%.2fMB\n",'$((`ls -l $AB_Firmware | awk '{print $5}'`))'/1000000}')
		echo -e "${Yellow}固件大小:${Blue}$Size${White}"
		MD5=$(md5sum $AB_Firmware | cut -d ' ' -f1)
		SHA256=$(sha256sum $AB_Firmware | cut -d ' ' -f1)
		MSG_COM B "\nMD5:$MD5"
		MSG_COM B "SHA256:$SHA256"
		echo -e "编译日期:$Compile_Started\n固件大小:$Size\n" > $Firmware_Detail
		echo -e "MD5:$MD5\nSHA256:$SHA256" >> $Firmware_Detail
	else
		MSG_ERR "编译失败!"
	fi
;;
Multi_Profile)
	Compile_Stopped
	MSG_SUCC "编译结束!"
;;
esac
Enter
}

BuildFirmware_Adv() {
while :
do
	clear
	MSG_TITLE "AutoBuild Firmware 高级选项"
	echo "1.执行 [make kernel_menuconfig]"
	echo "2.执行 [make download]"
	echo "3.分离[.config] > defconfig"
	echo "4.删除[.config]"
	echo "5.空间清理"
	echo -e "\nq.返回"
	MSG_COM G "m.主菜单"
	GET_Choose
	case $Choose in
	1)
		clear
		MSG_WAIT "正在执行 [make kernel_menuconfig],请耐心等待..."
		make kernel_menuconfig
	;;
	2)
		Make_Download
	;;
	3)
		if [ -e .config ];then
			./scripts/diffconfig.sh > $Home/Backups/Configs/defconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)
			MSG_SUCC "配置文件已保存到:'Backups/Configs/defconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)'"
		else
			MSG_ERR "未检测到[.config]文件,无法分离!"
		fi
		sleep 2
	;;
	4)
		if [ -e .config* ];then
			rm -f $Home/Projects/$Project/.config*
			MSG_SUCC "[配置文件] 删除成功!"
		else
			MSG_ERR "未检测到[.config]文件,无法删除!"
		fi
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
}

X86_Images_Check() {
	cd $Home/Projects/$Project
	source $Home/Additional/X86_IMAGES
	egrep -e "IMAGES*=y" -e "IMAGES_GZIP=y" -e "ROOTFS_SQUASHFS=y" .config > $Home/TEMP/X86_IMAGES
	source $Home/TEMP/X86_IMAGES
	touch $Home/TEMP/Choosed_FI
	Firmware_INFO="openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE"
	if [ ! $CONFIG_TARGET_ROOTFS_SQUASHFS == n ];then
		if [ $CONFIG_GRUB_IMAGES == y ];then
			[ $CONFIG_ISO_IMAGES == y ] && echo "$Firmware_INFO-image.iso" >> $Home/TEMP/Choosed_FI
			[ $CONFIG_VDI_IMAGES == y ] && echo "$Firmware_INFO-squashfs-combind.vdi" >> $Home/TEMP/Choosed_FI
			[ $CONFIG_VMDK_IMAGES == y ] && echo "$Firmware_INFO-squashfs-combind.vmdk" >> $Home/TEMP/Choosed_FI
			if [ $CONFIG_TARGET_IMAGES_GZIP == y ];then
				echo "$Firmware_INFO-squashfs-combind.img.gz" >> $Home/TEMP/Choosed_FI
				echo "$Firmware_INFO-squashfs-rootfs.img.gz" >> $Home/TEMP/Choosed_FI
			fi
		fi
		if [ $CONFIG_GRUB_EFI_IMAGES == y ];then
			[ $CONFIG_ISO_IMAGES == y ] && echo "$Firmware_INFO-image-efi.iso" >> $Home/TEMP/Choosed_FI
			[ $CONFIG_VDI_IMAGES == y ] && echo "$Firmware_INFO-squashfs-combind-efi.vdi" >> $Home/TEMP/Choosed_FI
			[ $CONFIG_VMDK_IMAGES == y ] && echo "$Firmware_INFO-squashfs-combind-efi.vmdk" >> $Home/TEMP/Choosed_FI
			[ $CONFIG_TARGET_IMAGES_GZIP == y ] && echo "$Firmware_INFO-squashfs-combind-efi.img.gz" >> $Home/TEMP/Choosed_FI
		fi
	fi
}

Checkout_Package() {
	cd $Home/Projects/$Project
	echo ""
	MSG_WAIT "检出[dl]库到'$Home/Backups/dl'..."
	awk 'BEGIN { cmd="cp -ri ./dl/* ../../Backups/dl/"; print "n" |cmd; }' > /dev/null 2>&1
	MSG_WAIT "检出软件包到'$Home/Packages'..."
	cd $Home/Packages
	Packages_Dir=$Home/Projects/$Project/bin
	[ ! -d $TARGET_ARCH_PACKAGES ] && mkdir -p $Home/Packages/$TARGET_ARCH_PACKAGES
	[ ! -d luci-app-common ] && mkdir -p $Home/Packages/luci-app-common
	[ ! -d luci-theme-common ] && mkdir -p $Home/Packages/luci-theme-common
	cp -a $(find $Packages_Dir/packages/$TARGET_ARCH_PACKAGES -type f -name "*.ipk") ./
	mv -f $(find ./ -type f -name "*_$TARGET_ARCH_PACKAGES.ipk") ./$TARGET_ARCH_PACKAGES
	mv -f $(find ./ -type f -name "luci-app-*.ipk") ./luci-app-common
	mv -f $(find ./ -type f -name "luci-theme-*.ipk") ./luci-theme-common
	cp -a $(find $Packages_Dir/targets/$TARGET_BOARD/$TARGET_SUBTARGET/ -type f -name "*.ipk") ./$TARGET_ARCH_PACKAGES
}

GET_TARGET_INFO() {
	rm -rf $Home/TEMP/* > /dev/null 2>&1
	cd $Home/Projects/$Project
	grep "CONFIG_TARGET_x86=y" .config > /dev/null 2>&1
	if [ ! $? -ne 0 ]; then
		Firmware_Type=x86
	else
		Firmware_Type=Common
	fi
	TARGET_BOARD=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config | awk 'NR==1')
	grep 'TARGET_BOARD' .config > /dev/null 2>&1
	if [ ! $? -eq 0 ];then
		DEFCONFIG=1
	else
		DEFCONFIG=0
	fi
	TARGET_SUBTARGET=$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)
	TARGET_PROFILE=$(grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/')
	TARGET_ARCH_PACKAGES=$(awk -F '[="]+' '/TARGET_ARCH_PACKAGES/{print $2}' .config)
	egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > $Home/TEMP/TARGET_PROFILE
	PROFILE_MaxLine=$(sed -n '$=' $Home/TEMP/TARGET_PROFILE)
	[ -z $PROFILE_MaxLine ] && PROFILE_MaxLine=0
	GET_CONFIG_ARCH=$(awk -F '[="]+' '/CONFIG_ARCH/{print $2}' .config | awk 'END {print}')
	if [ $GET_CONFIG_ARCH == aarch64 ];then
		Firmware_sfx=img.gz
	else
		Firmware_sfx=bin
	fi
}

BuildFirmware_Check() {
if [ ! -f $Home/Projects/$Project/.config ];then
	MSG_ERR "未检测到[.config]文件,无法编译!"
	sleep 3
else
	BuildFirmware_UI
fi
}

Compile_Stopped() {
	Compile_Ended=$(date +"%Y-%m-%d %H:%M:%S")
	Start_Seconds=$(date -d "$Compile_Started" +%s)
	End_Seconds=$(date -d "$Compile_Ended" +%s)
	let Compile_Cost=($End_Seconds-$Start_Seconds)/60
	MSG_SUCC "$Compile_Started --> $Compile_Ended 编译用时:$Compile_Cost分钟"
}
