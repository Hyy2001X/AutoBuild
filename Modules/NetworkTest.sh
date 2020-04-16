# AutoBuild Script Module by Hyy2001

function Network_Test() {
Update=2020.04.16
Module_Version=V2.3

function Network_Test_Mod() {
echo -ne "\r$Blue检测中...$White\r"
timeout 3 httping -c 1 $Net_URL > /dev/null 2>&1
if [ $? -eq 0 ];then
	timeout 3 httping -c 1 $Net_URL > $Home/TEMP/Network
	Net_IP=`egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $Home/TEMP/Network`
	egrep -o "/[0-9]+\.[0-9]+\/" $Home/TEMP/Network > $Home/TEMP/Network_PING
	Net_PING=`egrep -o "[0-9]+\.[0-9]+" $Home/TEMP/Network_PING`
	echo -e "$Net_URL		$Net_IP		$Yellow正常$White 		$Net_PING"
else
	echo -e "$Net_URL		$Red无法获取		错误		错误$White"
fi
}

clear
Say="Network Test Script $Module_Version by Hyy2001" && Color_B
Decoration
echo -e "$Skyb网址			IP地址			连接状态	延迟$White"
echo " "

Net_URL=www.baidu.com
Network_Test_Mod

Net_URL=www.gitee.com
Network_Test_Mod

Net_URL=www.github.com
Network_Test_Mod

Net_URL=www.google.com
Network_Test_Mod

Net_URL=dl.google.com
Network_Test_Mod

echo " "
Decoration
echo " "
Enter	
}
