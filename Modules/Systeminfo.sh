# AutoBuild Script Module by Hyy2001

Systeminfo() {
Update=2020.08.14
Module_Version=V1.7.1

clear
Current_Freq=`awk -F'[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo`
Current_Temp=`sensors | grep 'Core 0' | cut -c17-24`
CPU_Base=`uname -m`
System_Bit=`getconf LONG_BIT`
Kernel_Version=`uname -r`
Computer_Name=`hostname`
Computer_Startup=`awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d 天 %d 小时 %d 分钟\n",a,b,c)}' /proc/uptime`
IP_Address=`ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:"`
MemTotal_MB=`free -m | awk  '{print $2}' | awk 'NR==2'`
MemTotal_GB=`echo "scale=1; $MemTotal_MB / 1000" | bc`
MemFree=`free -m | awk  '{print $7}' | awk 'NR==2'`
MemFree_GB=`echo "scale=1; $MemFree / 1000" | bc`

Get_OS() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
OS_INFO=$( Get_OS )

clear
Say="System info Script $Module_Version" && Color_B
Decoration
echo -e "$Skyb操作系统$Yellow		$OS_INFO"
echo -e "$Skyb计算机名称$Yellow		$Computer_Name"
echo -e "$Skyb内核版本$Yellow		$Kernel_Version"
echo -e "$Skyb物理内存$Yellow		${MemTotal_GB}GB/${MemTotal_MB}MB"
echo -e "$Skyb可用内存$Yellow		${MemFree_GB}GB"
echo -e "${Skyb}CPU 型号$Yellow		$CPU_Model"
echo -e "${Skyb}CPU 频率$Yellow		$CPU_Freq"
echo -e "${Skyb}CPU 架构$Yellow		$CPU_Base ($System_Bit Bit)"
echo -e "${Skyb}CPU 核心数量$Yellow		$CPU_Cores"
echo -e "${Skyb}CPU 当前频率$Yellow		${Current_Freq}MHz"
echo -e "${Skyb}CPU 当前温度$Yellow		${Current_Temp}"
echo -e "${Skyb}IP地址$Yellow			$IP_Address"
echo -e "$Skyb开机时长$Yellow		$Computer_Startup"
Decoration
Enter
}
