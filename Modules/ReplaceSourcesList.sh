# AutoBuild Script Module by Hyy2001

ReplaceSourcesList() {
	Update=2021.02.09
	Module_Version=V1.4

	SOURCE_PATH=${Home}/Additional/Sources_List
	BAK_FILE=${Home}/Backups/sources.list.bak
	SOURCE_LIB=${Home}/Additional/Sources_List.check
	SOURCE_DL=https://raw.githubusercontent.com/Hyy2001X/AutoBuild/master/Additional/Sources_List

	if [ ! -f /etc/lsb-release ];then
		MSG_ERR "暂不支持此操作系统!"
		sleep 2 && return
	else
		OS_ID=$(awk -F '[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
		OS_Version=$(awk -F '[="]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
		if [[ ! "${OS_ID}" == Ubuntu ]];then
			MSG_ERR "暂不支持此操作系统!"
			sleep 2 && return
		fi
	fi
	case ${OS_Version} in
	19.10 | 18.04 | 20.04 | 20.10)
		while :
		do
			clear
			echo -e "${Skyb}当前操作系统${Yellow}:${OS_ID} ${OS_Version}${White}\n"
			echo "1.阿里源"
			echo "2.清华源"
			echo -e "3.Ubuntu 中国服务器\n"
			MSG_COM Y "c.检查列表完整性"
			MSG_COM G "x.恢复默认源"
			echo -e "\nq.返回"
			GET_Choose
			case ${Choose} in
			q)
				break
			;;
			x)
				if [ -f ${BAK_FILE} ];then
					sudo mv ${BAK_FILE} /etc/apt/sources.list
					MSG_SUCC "[默认源] 恢复成功!"
				else
					MSG_ERR "未找到备份: [${BAK_FILE}],恢复失败!"
				fi
				sleep 2
			;;
			c)
				Check_Sources_List
			;;
			1)
				ReplaceSources_mod 阿里源 Ubuntu-${OS_Version}-Aliyun
			;;
			2)
				ReplaceSources_mod 清华源 Ubuntu-${OS_Version}-Tuna
			;;
			3)
				ReplaceSources_mod Ubuntu中国源 Ubuntu-${OS_Version}-CN
			;;
			esac
		done
	;;
	*)
		MSG_ERR "当前支持的操作系统:Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04"
		sleep 2
	;;
	esac
}

ReplaceSources_mod() {
	if [ -f /etc/apt/sources.list ];then
		if [ ! -f ${BAK_FILE} ];then
			sudo cp /etc/apt/sources.list ${BAK_FILE}
			sudo chmod 777 ${BAK_FILE}
			MSG_SUCC "未检测到备份,当前系统源已自动备份至 [${BAK_FILE}] !"
		fi
	fi
	if [ -f ${SOURCE_PATH}/$2 ] && [ -s ${SOURCE_PATH}/$2 ];then
		sudo cp ${SOURCE_PATH}/$2 /etc/apt/sources.list
		MSG_SUCC "当前已切换到: [$1]"
	else
		MSG_ERR "未找到对应文件或文件损坏: [$2],切换失败!"
	fi
	sleep 2
}

Check_Sources_List() {
	if [ ! -f ${SOURCE_LIB} ];then
		MSG_ERR "未检测到列表文件: [${SOURCE_LIB}],检查失败!"
		sleep 2 && return
	fi
	clear
	MSG_TITLE "Source List 完整性检查工具"
	for SL in $(cat ${SOURCE_LIB})
	do
		if [ -f ${SOURCE_PATH}/${SL} ] && [ -s ${SOURCE_PATH}/${SL} ];then
			MSG_COM Y "[Check] 已检测到: [${SL}]"
		else
			MSG_COM R "[Check] 未检测到: [${SL}],开始下载..."
			rm -f ${SOURCE_PATH}/${SL}
			wget -q ${SOURCE_DL}/${SL} -O ${SOURCE_PATH}/${SL}
			if [[ $? -eq 0 ]];then
				MSG_COM Y "[DL] 已检测到: [${SL}]"
			else
				MSG_COM R "[DL] [${SL}] 下载失败!"
				rm -f ${SOURCE_PATH}/${SL}
			fi
		fi
	done
	Enter
}
