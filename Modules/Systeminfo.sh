# AutoBuild Script Module by Hyy2001

function Systeminfo() {
Update=2020.04.02
Module_Version=V1.0.0

clear
CPU_Model=`awk -F':[ ]' '/model name/{printf ($2);exit}' /proc/cpuinfo`
CPU_Freq=` awk '/model name/{print ""$NF;exit}' /proc/cpuinfo`
Current_Freq=$( awk -F'[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo )
CPU_Cores=`cat /proc/cpuinfo| grep "processor"| wc -l`
CPU_Physical_Cores=`cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
CPU_Base=`uname -m`
System_Bit=`getconf LONG_BIT`
Kernel_Version=`uname -r`
Computer_Name=`hostname`
System_Startup=`awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d 天 %d 小时 %d 分钟\n",a,b,c)}' /proc/uptime`
IP=`ip addr show | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' | egrep -v "127.0.0.1" | xargs`
MemTotal_KB=`awk '/MemTotal/' /proc/meminfo | tr -cd "[0-9]"`
((MemTotal_MB=$MemTotal_KB/1024))
MemTotal_GB=`echo "scale=2; $MemTotal_KB / 1024000" | bc`

Get_OS() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
OS_INFO=$( Get_OS )

Decoration() {
	echo -ne "$Skyb"
	printf "%-70s\n" "-" | sed 's/\s/-/g'
	echo -ne "$White"
}

Say="System info Script $Module_Version by Hyy2001" && Color_B

Decoration
echo -e "$Skyb计算机名称$Yellow		$Computer_Name$White"
echo -e "$Skyb操作系统$Yellow		$OS_INFO$White"
echo -e "$Skyb架构$Yellow			$CPU_Base ($System_Bit Bit)$White"
echo -e "$Skyb内核版本$Yellow		$Kernel_Version$White"
echo -e "$Skyb物理内存$Yellow		Total ${MemTotal_MB}MB/$Blue${MemTotal_GB}GB$White"
echo -e "${Skyb}CPU 型号$Yellow		$CPU_Model$White"
echo -e "${Skyb}CPU 频率$Yellow		$CPU_Freq$White"
echo -e "$Skyb当前CPU频率$Yellow		${Current_Freq}MHz$White"
echo -e "$Skyb物理CPU数量$Yellow		$CPU_Physical_Cores$White"
echo -e "$Skyb逻辑CPU数量$Yellow		$CPU_Cores$White"
echo -e "$Skyb开机时长$Yellow		$System_Startup$White"
echo -e "${Skyb}IP地址$Yellow			$IP$White"
Decoration
echo " "
Enter
}
