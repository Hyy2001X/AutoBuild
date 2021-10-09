# AutoBuild Script Module by Hyy2001

Update=2021.10.07
	
ReplaceSourcesList() {
	MIRROR_LIST=${Home}/Additional/SourcesList/Mirror
	CODENAME_LIST=${Home}/Additional/SourcesList/Codename
	TEMPLATE=${Home}/Additional/SourcesList/ServerUrl_Template
	BAK_FILE=${Home}/Backups/sources.list.bak

	if [[ ! -f /etc/lsb-release ]];then
		MSG_ERR "暂不支持此操作系统,当前支持的操作系统: [Ubuntu]"
		sleep 2 && return
	else
		OS_ID=$(awk -F '[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
		OS_Version=$(awk -F '[="]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
		if [[ ! ${OS_ID} == Ubuntu ]];then
			MSG_ERR "暂不支持此操作系统,当前支持的操作系统: [Ubuntu]"
			sleep 2 && return
		fi
		if [[ ! $(cat ${CODENAME_LIST} | awk '{print $1}') =~ ${OS_Version} ]];then
			MSG_ERR "暂不支持当前 [Ubuntu] 版本: [${OS_Version}]"
			echo -ne "${Red}当前支持的 [Ubuntu] 版本:"
			for CN in $(cat ${CODENAME_LIST} | awk '{print $1}')
			do
				echo -n "${CN} "
			done
			sleep 3 && return
		fi	
	fi
	while :
	do
		clear
		MSG_TITLE "Replace SourcesList"
		echo -e "${Skyb}操作系统${Yellow}: [${OS_ID} ${OS_Version}]${White}"
		Current_Server=$(egrep -o "[a-z]+[.][a-z]+[.][a-z]+" /etc/apt/sources.list | awk 'NR==1')
		echo -e "${Skyb}当前系统源${Yellow}: [${Current_Server}]${White}\n"
		if [[ -f ${MIRROR_LIST} ]];then
			Server_Count=$(sed -n '$=' ${MIRROR_LIST})
			for ((i=1;i<=${Server_Count};i++));
			do   
				ServerName=$(sed -n ${i}p ${MIRROR_LIST} | awk '{print $1}')
				echo -e "${i}.${Yellow}${ServerName}${White}"
			done
		else
			MSG_COM R "[未检测到 ${MIRROR_LIST}]"
		fi
		MSG_COM G "\nx.恢复默认源"
		MSG_COM B "u.更新软件源"
		echo "q.返回"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			if [[ -f ${BAK_FILE} ]];then
				sudo mv ${BAK_FILE} /etc/apt/sources.list
				MSG_SUCC "[默认源] 恢复成功!"
			else
				MSG_ERR "未找到备份: [${BAK_FILE}],恢复失败!"
			fi
			sleep 2
		;;
		u)
			clear
			sudo apt update
			Enter
		;;
		*)
			Choose_Server
		;;
		esac
	done
}

Choose_Server() {
	if [[ ${Choose} -gt 0 ]] > /dev/null 2>&1 ;then
		if [[ ${Choose} -le ${Server_Count} ]] > /dev/null 2>&1 ;then
			ServerUrl=$(sed -n ${Choose}p ${MIRROR_LIST} | awk '{print $2}')
			ServerName=$(sed -n ${Choose}p ${MIRROR_LIST} | awk '{print $1}')
			Codename=$(cat ${CODENAME_LIST} | grep "${OS_Version}" | awk '{print $2}')
			if [[ -z ${Codename} || -z ${ServerUrl} || -z ${ServerName} ]];then
				MSG_ERR "参数获取失败,请尝试更新 [AutoBuild] 后重试!"
			fi
			Replace_Server
		else
			MSG_ERR "输入错误,请输入正确的选项!"
			sleep 1
		fi
	fi
}

Replace_Server() {
	if [[ -f /etc/apt/sources.list ]];then
		if [[ ! -f ${BAK_FILE} ]];then
			sudo cp /etc/apt/sources.list ${BAK_FILE}
			sudo chmod 777 ${BAK_FILE}
			MSG_SUCC "未检测到备份,当前系统源已自动备份至 [${BAK_FILE}] !"
		fi
	else
		MSG_ERR "未检测到: [/etc/apt/sources.list],备份失败!"
	fi
	sudo cp ${TEMPLATE} /etc/apt/sources.list
	sudo sed -i "s?ServerUrl?${ServerUrl}?g" /etc/apt/sources.list
	sudo sed -i "s?Codename?${Codename}?g" /etc/apt/sources.list
	MSG_SUCC "系统源已切换到: [${ServerName}]"
	sleep 2
}
