# AutoBuild Script Module by Hyy2001

Systeminfo() {
	Update=2021.03.25
	Module_Version=V1.8

	GET_System_Info 2

	clear
	MSG_TITLE "System info Script $Module_Version"
	Decoration
	echo -e "${Skyb}操作系统${Yellow}		${Short_OS}"
	echo -e "${Skyb}系统版本${Yellow}		${OS_INFO}"
	echo -e "${Skyb}计算机名称${Yellow}		${Computer_Name}"
	echo -e "${Skyb}登陆用户名${Yellow}		${USER}"
	echo -e "${Skyb}内核版本${Yellow}		${Kernel_Version}"
	echo -e "${Skyb}物理内存${Yellow}		${MemTotal_GB}GB/${MemTotal_MB}MB"
	echo -e "${Skyb}可用内存${Yellow}		${MemFree_GB}GB/${MemFree}MB"
	echo -e "${Skyb}CPU 型号${Yellow}		${CPU_Model}"
	echo -e "${Skyb}CPU 频率${Yellow}		${CPU_Freq}"
	echo -e "${Skyb}CPU 架构${Yellow}		${CPU_Info}"
	echo -e "${Skyb}CPU 核心数量${Yellow}		${CPU_Cores}"
	echo -e "${Skyb}CPU 当前频率${Yellow}		${Current_Freq}MHz"
	echo -e "${Skyb}CPU 当前温度${Yellow}		${Current_Temp}"
	echo -e "${Skyb}IP地址${Yellow}			${IP_Address}"
	echo -e "${Skyb}开机时长${Yellow}		${Computer_Startup}"
	Decoration
	Enter
}

GET_System_Info() {
	case $1 in
	1)
		CPU_Model=$(awk -F ':[ ]' '/model name/{printf ($2);exit}' /proc/cpuinfo)
		CPU_Cores=$(cat /proc/cpuinfo | grep processor | wc -l)
		CPU_Threads=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
		CPU_Freq=$(awk '/model name/{print ""$NF;exit}' /proc/cpuinfo)
		Get_OS() {
			[ -e /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
			[ -e /etc/os-release ] && awk -F '[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
			[ -e /etc/lsb-release ] && awk -F '[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
		}
		OS_INFO=$(Get_OS)
		Short_OS=$(echo ${OS_INFO} | awk '{print $1}')
		System_Bit=$(getconf LONG_BIT)
		CPU_Base=$(uname -m)
		[[ -z "${CPU_Base}" ]] && CPU_Info="${System_Bit}" || CPU_Info="${System_Bit} (${CPU_Base} Bit)"
		Computer_Name=$(hostname)
		MemTotal_MB=$(free -m | awk '{print $2}' | awk 'NR==2')
		MemTotal_GB=$(echo "scale=1; $MemTotal_MB / 1000" | bc)
	;;
	2)
		Current_Freq=$(awk -F '[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo)
		Current_Temp=$(sensors | grep 'Core 0' | cut -c17-24)
		Kernel_Version=$(uname -r)
		Computer_Startup=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d 天 %d 小时 %d 分钟\n",a,b,c)}' /proc/uptime)
		IP_Address=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | awk 'NR==1')
		MemFree=$(free -m | awk '{print $7}' | awk 'NR==2')
		MemFree_GB=$(echo "scale=1; $MemFree / 1000" | bc)
	;;
	esac
}
