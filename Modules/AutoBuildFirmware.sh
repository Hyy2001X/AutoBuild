# AutoBuild Script Module by Hyy2001

BuildFirmware_UI() {
Update=2021.07.09
Module_Version=V3.2.6

while :
do
	Build_Path=${Home}/Projects/${Project}
	cd ${Build_Path}
	Source_Repo="$(grep "https://github.com/[a-zA-Z0-9]" ${Build_Path}/.git/config | cut -c8-100)"
	Source_Owner="$(echo "${Source_Repo}" | egrep -o "[a-z]+" | awk 'NR==4')"
	Current_Branch="$(git branch | sed 's/* //g')"
	[[ ! ${Current_Branch} == master ]] && {
		Current_Branch="$(echo ${Current_Branch} | egrep -o "[0-9]+.[0-9]+")"
		Openwrt_Version_="R${Current_Branch}-"
	} || {
		Openwrt_Version_="R18.06-"
	}
	case ${Source_Owner} in
	coolsnowwolf)
		Version_File=$Home/Projects/$Project/package/lean/default-settings/files/zzz-default-settings
	;;
	immortalwrt)
		Version_File=$Home/Projects/$Project/package/base-files/files/etc/openwrt_release
	;;
	esac
	while [[ -z "${x86_Test}" ]]
	do
		x86_Test="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/CONFIG_TARGET_(.*)_DEVICE_(.*)=y/\1/')"
		[[ -n "${x86_Test}" ]] && break
		x86_Test="$(egrep -o "CONFIG_TARGET.*Generic=y" .config | sed -r 's/CONFIG_TARGET_(.*)_Generic=y/\1/')"
		[[ -z "${x86_Test}" ]] && break
	done
	[[ "${x86_Test}" == "x86_64" ]] && {
		TARGET_PROFILE="x86_64"
	} || {
		TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
	}
	[[ "${TARGET_PROFILE}" == x86_64 ]] && {
		[[ "$(cat ${Build_Path}/.config)" =~ "CONFIG_TARGET_IMAGES_GZIP=y" ]] && {
			Firmware_Type=img.gz
		} || {
			Firmware_Type=img
		}
	}
	TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
	[[ ! "$(cat .config)" =~ "TARGET_BOARD" ]] && {
		DEFCONFIG=1
	} || DEFCONFIG=0
	case ${TARGET_BOARD} in
	ramips | reltek | ipq40xx | ath79)
		Firmware_Type=bin
	;;
	rockchip)
		Firmware_Type=img.gz
	;;
	esac
	TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
	TARGET_ARCH_PACKAGES=$(awk -F '[="]+' '/TARGET_ARCH_PACKAGES/{print $2}' .config)
	CPU_TEMP=$(sensors | grep 'Core 0' | cut -c17-24)
	[[ -z "$CPU_TEMP" ]] && CPU_TEMP=0
	clear
	MSG_TITLE "AutoBuild Firmware Script ${Module_Version}"
	MSG_COM G "电脑信息:${CPU_Model} ${CPU_Cores} Cores ${CPU_Threads} Threads ${CPU_TEMP}\n"
	if [ -f $Home/Projects/$Project/.config ];then
		if [ -f $Home/Configs/${Project}_Recently_Config ];then
			echo -e "${Yellow}最近配置文件:${Blue}[$(cat $Home/Configs/${Project}_Recently_Config)]${White}\n"
		fi
		if [ $DEFCONFIG == 0 ];then
			echo -e "设备名称:${Yellow}${TARGET_PROFILE}${White}"
			echo -e "CPU 架构:${Yellow}${TARGET_BOARD}${White}"
			echo -e "CPU 型号:${Yellow}${TARGET_SUBTARGET}${White}"
			echo -e "软件架构:${Yellow}${TARGET_ARCH_PACKAGES}${White}"
		else
			MSG_COM R "Warning: Please run 'make defconfig' First!"
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
	if [ -f $Home/Configs/${Project}_Recently_Compiled ];then
		Recently_Compiled=$(awk 'NR==1' $Home/Configs/${Project}_Recently_Compiled)
		Recently_Compiled_Stat=$(awk 'NR==2' $Home/Configs/${Project}_Recently_Compiled)
		echo -e "\n${Yellow}最近编译时间:${Blue}[${Recently_Compiled}${Recently_Compiled_Stat}]${White}"
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
		Compile_Threads="make -j${CPU_Threads}"
	;;
	4)
		Compile_Threads="make -j${CPU_Threads} V=s"
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
		echo ""
		read -p '请输入编译参数:' Compile_Threads
		[[ -z "$Compile_Threads" ]] && MSG_ERR "未输入任何参数,无法执行!" && sleep 2 || {
			clear
			MSG_WAIT "即将执行自定义参数 [$Compile_Threads]..."
			echo "" && $Compile_Threads && echo ""
			MSG_WAIT "自定义参数执行结束!"
			Enter
		}
	;;
	8)
		BuildFirmware_Adv
	;;
	esac	
	case $Choose_1 in
	1 | 2 | 3 | 4)
		BuildFirmware_Core
	esac
done
}

BuildFirmware_Core() {
	clear
	Firmware_PATH="${Build_Path}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
	Compile_Date=$(date +%Y%m%d-%H:%M)
	Display_Date=$(date +%Y/%m/%d)
	case ${Source_Owner} in
	immortalwrt)
		_Firmware=immortalwrt
		Openwrt_Version="${Openwrt_Version_}${Compile_Date}"
	;;
	coolsnowwolf)
		_Firmware=openwrt
		Old_Version="$(egrep -o "R[0-9]+\.[0-9]+\.[0-9]+" ${Version_File})"
		Openwrt_Version="${Old_Version}-${Compile_Date}"
	;;
	*)
		_Firmware=openwrt
		Openwrt_Version="${Openwrt_Version_}${Compile_Date}"
	;;
	esac
	case "${TARGET_PROFILE}" in
	x86_64)
		Firmware_INFO="AutoBuild-$TARGET_BOARD-$TARGET_SUBTARGET-$Project-$Openwrt_Version"
	;;
	*)
		Firmware_Name="${_Firmware}-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.${Firmware_Type}"
		Firmware_INFO="AutoBuild-$TARGET_PROFILE-$Project-$Openwrt_Version"
		AB_Firmware="${Firmware_INFO}.${Firmware_Type}"
		Firmware_Detail="$Home/Firmware/Details/${Firmware_INFO}.detail"
		echo -e "${Yellow}固件名称:${Blue}$AB_Firmware${White}\n"
	;;
	esac
	cp -a $Home/Additional/Files/profile package/base-files/files/etc
	case ${Source_Owner} in
	coolsnowwolf)
		if [ ! $(grep -o "Compiled by $Username" $Version_File | wc -l) == 1 ];then
			sed -i "s?${Old_Version}?${Old_Version} Compiled by ${Username} [${Display_Date}]?g" ${Version_File}
		fi
		Old_Date=$(egrep -o "[0-9]+\/[0-9]+\/[0-9]+" ${Version_File})
		if [ ! ${Display_Date} == ${Old_Date} ];then
			sed -i "s?${Old_Date}?${Display_Date}?g" ${Version_File}
		fi
	;;
	immortalwrt)
		cp -a $Home/Additional/Files/banner package/lean/default-settings/files/openwrt_banner
		cp -a $Home/Additional/Files/ImmortalWrt_release package/base-files/files/etc/openwrt_release
		sed -i "s?By?By ${Username}?g" package/lean/default-settings/files/openwrt_banner
		sed -i "s?Openwrt?ImmortalWrt ${Openwrt_Version}?g" package/lean/default-settings/files/openwrt_banner
	;;
	*)
		cp -a $Home/Additional/Files/banner package/base-files/files/etc
		sed -i "s?By?By ${Username}?g" package/base-files/files/etc/banner
		sed -i "s?Openwrt?Openwrt ${Openwrt_Version} ?g" package/base-files/files/etc/banner
	;;
	esac
	MSG_WAIT "开始编译$Project..."
	Compile_Started=$(date +"%Y-%m-%d %H:%M:%S")
	echo "$Compile_Started" > $Home/Configs/${Project}_Recently_Compiled
	if [ $SaveCompileLog == 0 ];then
		$Compile_Threads || Compiled_Failed=1
	else
		$Compile_Threads 2>&1 | tee $Home/Log/BuildOpenWrt_${Project}_${Compile_Date}.log || Compiled_Failed=1
	fi
	case "${TARGET_PROFILE}" in
	x86_64)
		Compile_Stopped
		find $Firmware_PATH -size +20480k -exec echo $@ > $Home/TEMP/Compiled_FI {} \;
		echo ""
		if [[ -n $Compiled_Failed ]];then
			Checkout_Package
			mkdir -p $Home/Firmware/$Firmware_INFO
			for Compiled_FI in $(cat $Home/TEMP/Compiled_FI)
			do
				Compiled_FI=${Compiled_FI##*/}
				echo ""
				MSG_COM "已检测到固件: $Compiled_FI"
				mv $Firmware_PATH/$Compiled_FI $Home/Firmware/$Firmware_INFO
				MD5=$(md5sum $Home/Firmware/$Firmware_INFO/$Compiled_FI | cut -d ' ' -f1)
				SHA256=$(sha256sum $Home/Firmware/$Firmware_INFO/$Compiled_FI | cut -d ' ' -f1)
				echo -e "MD5:$MD5\nSHA256:$SHA256" > $Home/Firmware/$Firmware_INFO/${Compiled_FI}.detail
			done
			MSG_SUCC "固件位置:Firmware/$Firmware_INFO"
			MSG_SUCC "x86 设备编译结束!"
		else
			MSG_ERR "编译失败!"
		fi
	;;
	*)
		Compile_Stopped
		if [ -f $Firmware_PATH/$Firmware_Name ];then
			Checkout_Package
			echo " 成功" >> $Home/Configs/${Project}_Recently_Compiled
			mv $Firmware_PATH/$Firmware_Name $Home/Firmware/$AB_Firmware
			MSG_SUCC "固件位置:$Home/Firmware"
			echo -e "${Yellow}固件名称:${Blue}$AB_Firmware"
			Size=$(awk 'BEGIN{printf "%.2fMB\n",'$((`ls -l $Home/Firmware/$AB_Firmware | awk '{print $5}'`))'/1000000}')
			echo -e "${Yellow}固件大小:${Blue}${Size}${White}"
			MD5=$(md5sum $Home/Firmware/$AB_Firmware | cut -d ' ' -f1)
			SHA256=$(sha256sum $Home/Firmware/$AB_Firmware | cut -d ' ' -f1)
			MSG_COM B "\nMD5:$MD5"
			MSG_COM B "SHA256:$SHA256"
			echo -e "编译日期:$Compile_Started\n固件大小:$Size\n" > $Firmware_Detail
			echo -e "MD5:$MD5\nSHA256:$SHA256" >> $Firmware_Detail
		else
			echo " 失败" >> $Home/Configs/${Project}_Recently_Compiled
			MSG_ERR "编译失败!"
		fi
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
	echo "3.分离 [.config] > defconfig"
	echo "4.删除 [.config]"
	echo "5.更多空间清理"
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
		if [ -f .config ];then
			./scripts/diffconfig.sh > $Home/Backups/Configs/defconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)
			MSG_SUCC "新配置文件已保存到:'Backups/Configs/defconfig_${Project}_$(date +%Y%m%d-%H:%M:%S)'"
		else
			MSG_ERR "未检测到[.config]文件,无法执行!"
		fi
		sleep 2
	;;
	4)
		rm -f $Home/Projects/$Project/.config*
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
	cp -a $(find $Packages_Dir/packages/$TARGET_ARCH_PACKAGES -type f -name "*.ipk") ./ > /dev/null 2>&1
	mv -f $(find ./ -type f -name "*_$TARGET_ARCH_PACKAGES.ipk") ./$TARGET_ARCH_PACKAGES > /dev/null 2>&1
	mv -f $(find ./ -type f -name "luci-app-*.ipk") ./luci-app-common > /dev/null 2>&1
	mv -f $(find ./ -type f -name "luci-theme-*.ipk") ./luci-theme-common > /dev/null 2>&1
	cp -a $(find $Packages_Dir/targets/$TARGET_BOARD/$TARGET_SUBTARGET/ -type f -name "*.ipk") ./$TARGET_ARCH_PACKAGES > /dev/null 2>&1
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
