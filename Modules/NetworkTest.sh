# AutoBuild Script Module by Hyy2001

Network_Test() {
Update=2020.11.08
Module_Version=V2.9

clear
MSG_TITLE "Network Test Script $Module_Version"
Decoration
MSG_COM G "$Skyb网址			IP地址			状态		延迟$White\n"
Network_Mod www.baidu.com 2
Network_Mod www.github.com 2
Network_Mod www.google.com 2
Network_Mod git.openwrt.org 2
Network_Mod dl.google.com 2

echo " " && Decoration
Enter
}

Network_Mod() {
echo -ne "\r$Blue检测中...$White\r"
timeout 3 httping -c 1  $1 > /dev/null 2>&1
if [ $? -eq 0 ];then
	timeout $(($2*3)) httping -c $2 $1 > $Home/TEMP/Network_Test
	Net_IP=$(awk 'NR==2' $Home/TEMP/Network_Test | egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")
	Net_PING=$(egrep -o "/[0-9]+\.[0-9]+\/" $Home/TEMP/Network_Test | egrep -o "[0-9]+\.[0-9]+")
	echo -e "$1		$Net_IP		$Yellow正常$White 		$Net_PING"
else
	echo -e "$1		$Red无法获取		错误		错误$White"
fi
}
