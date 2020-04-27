# AutoBuild Script Module by Hyy2001

function ReplaceSourcesList() {
Update=2020.04.27
Module_Version=V1.1

ReplaceSources_mod() {
if [ -f /etc/apt/sources.list ];then
	if [ ! -f $Home/Backups/sources.list.bak ];then
		sudo cp /etc/apt/sources.list $Home/Backups/sources.list.bak
		sudo chmod 777 $Home/Backups/sources.list.bak
	else
		:
	fi
else
	:
fi
sudo cp $Home/Additional/$Sources_File /etc/apt/sources.list
echo " "
Say="已切换到$Sources_Name." && Color_Y
}

if [ -f /etc/lsb-release ];then
	OS_ID=`awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release`
	OS_Version=`awk -F'[="]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release`
	if [ $OS_ID == Ubuntu ];then
		if [ $OS_Version == 19.10 ] || [ $OS_Version == 18.04 ] || [ $OS_Version == 20.04 ];then
		while :
		do
			clear
			echo -e "$Skyb操作系统$Yellow:$OS_ID $OS_Version$White"
			echo " "
			echo "1.阿里源"
			echo "2.清华源"
			echo "3.恢复默认源"
			echo "q.返回"
			GET_Choose
			case $Choose in
			q)
				break
			;;
			1)
				Sources_Name="阿里源"
				Sources_File="Ubuntu-$OS_Version-Aliyun"
				ReplaceSources_mod
			;;
			2)
				Sources_Name="清华源"
				Sources_File="Ubuntu-$OS_Version-Tuna"
				ReplaceSources_mod
			;;
			3)
				sudo mv $Home/Backups/sources.list.bak /etc/apt/sources.list
				echo " "
				Say="恢复成功!" && Color_Y
			;;
			esac
			sleep 3
		done
		else
			echo " "
			Say="当前仅支持:Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04" && Color_R
			sleep 3
		fi
	else
	echo " "
	echo -e "$Red暂不支持您的操作系统!$White"
	sleep 3
	fi
else
echo " "
echo -e "$Red暂不支持您的操作系统!$White"
sleep 3
fi

}
