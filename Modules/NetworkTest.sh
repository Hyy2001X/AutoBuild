# AutoBuild Script Module by Hyy2001

function Network_Test() {
Update=2020.04.05
Module_Version=V2.0

function Network_Test_Mod() {
echo -ne "\r$Blue检测中...$White\r"
timeout 3 httping -c 1 $Net_URL > /dev/null 2>&1
if [ $? -eq 0 ];then
	timeout 3 httping -c 1 $Net_URL > $Home/TEMP/Network
	Net_IP=`egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $Home/TEMP/Network`
	echo -e "$Net_URL		$Net_IP		$Yellow正常$White"
else
	echo -e "$Net_URL		无法获取		$Red错误$White"
fi
}

clear
Say="Network Test Script $Module_Version by Hyy2001" && Color_B
echo " "
echo -e "$Skyb网址			IP地址			连接状态$White"

Net_URL=www.baidu.com
Network_Test_Mod

Net_URL=www.gitee.com
Network_Test_Mod

Net_URL=www.github.com
Network_Test_Mod

Net_URL=www.google.com
Network_Test_Mod

echo ""
Enter	
}
