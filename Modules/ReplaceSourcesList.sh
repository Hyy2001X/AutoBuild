# AutoBuild Script Module by Hyy2001

ReplaceSourcesList() {
Update=2020.08.14
Module_Version=V1.3.4

if [ -f /etc/lsb-release ];then
	OS_ID=`awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release`
	OS_Version=`awk -F'[="]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release`
	if [ $OS_ID == Ubuntu ];then
		if [ $OS_Version == 19.10 ] || [ $OS_Version == 18.04 ] || [ $OS_Version == 20.04 ];then
		while :
		do
			clear
			echo -e "$Skyb当前操作系统$Yellow:$OS_ID $OS_Version$White\n"
			echo "1.阿里源"
			echo "2.清华源"
			echo "3.Ubuntu 中国服务器"
			echo "4.恢复默认源"
			echo -e "\nq.返回"
			GET_Choose
			case $Choose in
			q)
				break
			;;
			1)
				ReplaceSources_mod 阿里源 Ubuntu-$OS_Version-Aliyun
			;;
			2)
				ReplaceSources_mod 清华源 Ubuntu-$OS_Version-Tuna
			;;
			3)
				ReplaceSources_mod Ubuntu中国源 Ubuntu-$OS_Version-CN
			;;
			4)
				sudo mv $Home/Backups/sources.list.bak /etc/apt/sources.list
				Say="\n恢复成功!" && Color_Y
			;;
			esac
			sleep 2
		done
		else
			Say="\n当前支持的操作系统:Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04" && Color_R
			sleep 2
		fi
	else
		Say="\n暂不支持此操作系统!" && Color_R
		sleep 2
	fi
else
	echo " "
	Say="暂不支持此操作系统!" && Color_R
	sleep 2
fi
}

ReplaceSources_mod() {
if [ -f /etc/apt/sources.list ];then
	if [ ! -f $Home/Backups/sources.list.bak ];then
		sudo cp /etc/apt/sources.list $Home/Backups/sources.list.bak
		sudo chmod 777 $Home/Backups/sources.list.bak
	fi
fi
if [ -f $Home/Additional/Sources_List/$2 ];then
	sudo cp $Home/Additional/Sources_List/$2 /etc/apt/sources.list
	Say="\n已切换到$1." && Color_Y
else
	Say="\n未找到对应文件,切换失败!" && Color_R
fi
}
