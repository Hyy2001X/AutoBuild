# AutoBuild Script Module by Hyy2001

Network_Test() {
Update=2020.07.16
Module_Version=V2.6.0

clear
Say="Network Test Script $Module_Version" && Color_B
Decoration
echo -e "$Skyb网址			IP地址			状态		延迟$White"
echo " "

Network_Mod www.baidu.com
Network_Mod www.github.com
Network_Mod www.google.com
Network_Mod www.github.io
Network_Mod dl.google.com

echo " " && Decoration && echo " "
Enter
}

Network_Mod() {
echo -ne "\r$Blue检测中...$White\r"
timeout 3 httping -c 1 $1 > /dev/null 2>&1
if [ $? -eq 0 ];then
	timeout 3 httping -c 1 $1 > $Home/TEMP/Network
	Net_IP=`egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $Home/TEMP/Network`
	egrep -o "/[0-9]+\.[0-9]+\/" $Home/TEMP/Network > $Home/TEMP/Network_PING
	Net_PING=`egrep -o "[0-9]+\.[0-9]+" $Home/TEMP/Network_PING`
	echo -e "$1		$Net_IP		$Yellow正常$White 		$Net_PING"
else
	echo -e "$1		$Red无法获取		错误		错误$White"
fi
}
