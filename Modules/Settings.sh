# AutoBuild Script Module by Hyy2001

Update=2021.07.09

Settings() {
	while :
	do
		Settings_Props
		ColorfulUI_Check
		clear
		MSG_TITLE "脚本设置[实验性]"
		if [[ $ColorfulUI == 0 ]];then
			MSG_COM  R "1.彩色 UI		[关闭]"
		else
			MSG_COM Y "1.彩色 UI		[打开]"
		fi
		if [[ $DeveloperMode == 0 ]];then
			MSG_COM  R "2.调试模式		[关闭]"
		else
			MSG_COM Y "2.调试模式		[打开]"
		fi
		if [[ $SaveCompileLog == 0 ]];then
			MSG_COM  R "3.保存编译日志		[关闭]"
		else
			MSG_COM Y "3.保存编译日志		[打开]"
		fi
		if [[ $PingMode == httping ]];then
			MSG_COM  B "4.Ping Mode		[httping]"
		else
			MSG_COM Y "4.Ping Mode		[ping]"
		fi
		MSG_COM G "\nx.恢复所有默认设置"
		echo "q.返回"
		GET_Choose
		case ${Choose} in
		q)
			break
		;;
		x)
			Set_Default_Settings
		;;
		1)
			if [[ $ColorfulUI == 0 ]];then
				ColorfulUI=1
				sed -i "s/ColorfulUI=0/ColorfulUI=1/g" ./Settings
			else
				ColorfulUI=0
				sed -i "s/ColorfulUI=1/ColorfulUI=0/g" ./Settings
			fi
		;;
		2)
			if [[ $DeveloperMode == 0 ]];then
				DeveloperMode=1
				sed -i "s/DeveloperMode=0/DeveloperMode=1/g" ./Settings
			else
				DeveloperMode=0
				sed -i "s/DeveloperMode=1/DeveloperMode=0/g" ./Settings
			fi
		;;
		3)
			if [[ $SaveCompileLog == 0 ]];then
				SaveCompileLog=1
				sed -i "s/SaveCompileLog=0/SaveCompileLog=1/g" ./Settings
			else
				SaveCompileLog=0
				sed -i "s/SaveCompileLog=1/SaveCompileLog=0/g" ./Settings
			fi
		;;
		4)
			if [[ $PingMode == httping ]];then
				PingMode=ping
				sed -i "s/PingMode=httping/PingMode=ping/g" ./Settings
			else
				PingMode=httping
				sed -i "s/PingMode=ping/PingMode=httping/g" ./Settings
			fi
		;;
		esac
	done
}

Default_Settings() { 
	DeveloperMode=0
	ColorfulUI=1
	SaveCompileLog=0
	PingMode=httping
}

Set_Default_Settings() {
	Default_Settings
	echo "DeveloperMode=$DeveloperMode" > ${Home}/Configs/Settings
	echo "ColorfulUI=$ColorfulUI" >> ${Home}/Configs/Settings
	echo "SaveCompileLog=$SaveCompileLog" >> ${Home}/Configs/Settings
	echo "PingMode=$PingMode" >> ${Home}/Configs/Settings
}

Settings_Props() {
	cd ${Home}/Configs
	if [[ ! -f ${Home}/Configs/Settings ]];then
		Set_Default_Settings
	else
		source ${Home}/Configs/Settings
	fi
}

ColorfulUI_Check() {
	if [[ $ColorfulUI == 1 ]];then
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

MSG_COM() {
	if [[ $# -gt 1 ]];then
		case $1 in
		Y)
			MSG_Color=${Yellow}
		;;
		R)
			MSG_Color=${Red}
		;;
		B)
			MSG_Color=${Blue}
		;;
		G)
			MSG_Color=${Skyb}
		;;
		esac
		echo -e "${MSG_Color}${2}${White}"
	else
		echo -e "${Yellow}${*}${White}"
	fi
}

MSG_WAIT() {
	echo -e "${Blue}${*}${White}"
	echo "[$(date +%Y/%m/%d-%H:%M:%S)] [WAIT] ${*}" >> ${Home}/Log/AutoBuild.log
}

MSG_ERR() {
	echo -e "\n${Red}${*}${White}"
	echo "[$(date +%Y/%m/%d-%H:%M:%S)] [ERR] ${*}" >> ${Home}/Log/AutoBuild.log
}

MSG_SUCC() {
	echo -e "\n${Yellow}${*}${White}"
	echo "[$(date +%Y/%m/%d-%H:%M:%S)] [SUCC] ${*}" >> ${Home}/Log/AutoBuild.log
}

MSG_TITLE() {
	echo -e "${Blue}${*}${White}\n"
}

GET_Choose() {
	echo -e "${White}"
	read -p '请从上方选择一个操作:' Choose
}

Enter() {
	echo -e "${White}"
	read -p "按下[回车]键以继续..." Key
}

Decoration() {
	echo -ne "${Skyb}"
	printf "%-70s\n" "-" | sed 's/\s/-/g'
	echo -ne "${White}"
}
