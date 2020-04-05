# AutoBuild Script Module by Hyy2001

function Network_Test() {
Update=2020.04.02
Module_Version=V1.0.1

clear
Say="Network Test Script $Module_Version by Hyy2001" && Color_B
echo " "
Network_OK="$Yellow连接正常$White"
Network_ERROR="$Red连接错误$White"

Net_URL=www.baidu.com
timeout 3 httping -c 1 $Net_URL > /dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "$Net_URL		$Network_OK" 
else
	echo -e "$Net_URL		$Network_ERROR"
fi
Net_URL=www.gitee.com
timeout 3 httping -c 1 $Net_URL > /dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "$Net_URL		$Network_OK" 
else
	echo -e "$Net_URL		$Network_ERROR"
fi
Net_URL=www.github.com
timeout 3 httping -c 1 www.github.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "$Net_URL		$Network_OK" 
else
	echo -e "$Net_URL		$Network_ERROR"
fi
Net_URL=www.google.com
timeout 3 httping -c 1 www.google.com > /dev/null 2>&1
if [ $? -eq 0 ];then
	echo -e "$Net_URL		$Network_OK" 
else
	echo -e "$Net_URL		$Network_ERROR"
fi
echo ""
Enter	
}
