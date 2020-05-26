# AutoBuild Script Module by Hyy2001

Settings() {
Update=2020.05.26
Module_Version=V1.1

while :
do
	ColorfulUI_Check
	clear
	Say="脚本设置[临时]" && Color_B
	echo " "
	if [ $DeveloperMode == 0 ];then
		Say="1.调试模式		[OFF]" && Color_R
	else
		Say="1.调试模式		[ON]" && Color_Y
	fi
	if [ $SimpleCompilation == 0 ];then
		Say="2.轻松编译		[OFF]" && Color_R
	else
		Say="2.轻松编译		[ON]" && Color_Y
	fi
	if [ $ColorfulUI == 0 ];then
		Say="3.彩色UI		[OFF]" && Color_R
	else
		Say="3.彩色UI		[ON]" && Color_Y
	fi
	if [ $GitSource == 0 ];then
		Say="4.源码下载源		[Github]" && Color_Y
	else
		Say="4.源码下载源		[Gitee]" && Color_B
	fi
	if [ $SaveCompileLog == 0 ];then
		Say="5.保存编译日志		[OFF]" && Color_R
	else
		Say="5.保存编译日志		[ON]" && Color_Y
	fi
	if [ $CustomSources == 0 ];then
		Say="6.自定义源码		[OFF]" && Color_R
	else
		Say="6.自定义源码		[ON]" && Color_Y
	fi
	echo " "
	echo "x.恢复所有默认设置"
	echo "q.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	x)
		Default_Settings
	;;
	1)
		if [ $DeveloperMode == 0 ];then
			DeveloperMode=1
		else
			DeveloperMode=0
		fi
	;;
	2)
		if [ $SimpleCompilation == 0 ];then
			SimpleCompilation=1
		else
			SimpleCompilation=0
		fi
	;;
	3)
		if [ $ColorfulUI == 0 ];then
			ColorfulUI=1
		else
			ColorfulUI=0
		fi
	;;
	4)
		if [ $GitSource == 0 ];then
			GitSource=1
		else
			GitSource=0
		fi
	;;
	5)
		if [ $SaveCompileLog == 0 ];then
			SaveCompileLog=1
		else
			SaveCompileLog=0
		fi
	;;
	6)
		if [ $CustomSources == 0 ];then
			CustomSources=1
		else
			CustomSources=0
		fi
	;;
	esac
done
}

Default_Settings() { 
DeveloperMode=0
SimpleCompilation=1
ColorfulUI=1
GitSource=0
SaveCompileLog=0
CustomSources=1
}
