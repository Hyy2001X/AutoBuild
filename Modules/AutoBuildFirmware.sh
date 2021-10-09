# AutoBuild Script Module by Hyy2001

Update=2021.10.07

BuildFirmware_UI() {
	Build_Path=${Home}/Projects/${Project}
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
			[[ $(cat ${Home}/.config) =~ CONFIG_TARGET_IMAGES_GZIP=y ]] && {
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
		if [ -f ${Build_Path}/.config ];then
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
		echo ""
		read -p '请从上方选择一个操作:' Choose_1
		case ${Choose}_1 in
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
			Advanced
		;;
		esac	
		case ${Choose}_1 in
		1 | 2 | 3 | 4)
			BuildFirmware_Core
		esac
	done
}

BuildFirmware_Core() {
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

Advanced() {
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
}

Checkout_Package() {
	cd ${Build_Path}
	echo ""
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

BuildFirmware_Check() {
	[[ ${LOGNAME} == root ]] && {
		MSG_ERR "无法使用 [root] 用户进行编译!"
		sleep 3
	}
	if [[ ! -f ${Home}/Projects/${Project}/.config ]];then
		MSG_ERR "未检测到[.config]文件!"
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
