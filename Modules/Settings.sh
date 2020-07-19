# AutoBuild Script Module by Hyy2001

Settings() {
Update=2020.07.19
Module_Version=V1.4.0

while :
do
	ColorfulUI_Check
	clear
	Say="脚本设置[实验性]" && Color_B
	echo " "
	if [ $SimpleCompilation == 0 ];then
		Say="1.高级编译		[关闭]" && Color_R
	else
		Say="1.高级编译		[打开]" && Color_Y
	fi
	if [ $ColorfulUI == 0 ];then
		Say="2.高亮显示		[关闭]" && Color_R
	else
		Say="2.高亮显示		[打开]" && Color_Y
	fi
	if [ $DeveloperMode == 0 ];then
		Say="3.调试模式		[关闭]" && Color_R
	else
		Say="3.调试模式		[打开]" && Color_Y
	fi
	if [ $SaveCompileLog == 0 ];then
		Say="4.保存编译日志		[关闭]" && Color_R
	else
		Say="4.保存编译日志		[打开]" && Color_Y
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
		if [ $SimpleCompilation == 0 ];then
			SimpleCompilation=1
		else
			SimpleCompilation=0
		fi
	;;
	2)
		if [ $ColorfulUI == 0 ];then
			ColorfulUI=1
		else
			ColorfulUI=0
		fi
	;;
	3)
		if [ $DeveloperMode == 0 ];then
			DeveloperMode=1
		else
			DeveloperMode=0
		fi
	;;
	4)
		if [ $SaveCompileLog == 0 ];then
			SaveCompileLog=1
		else
			SaveCompileLog=0
		fi
	esac
done
}

Default_Settings() { 
DeveloperMode=0
SimpleCompilation=1
ColorfulUI=1
SaveCompileLog=0
}

ColorfulUI_Check() {
if [ $ColorfulUI == 1 ];then
	White="\e[0m"
	Yellow="\e[33m"
	Red="\e[31m"
	Blue="\e[34m"
	Skyb="\e[36m"
else
	White="\e[0m"
	Yellow="\e[0m"
	Red="\e[0m"
	Blue="\e[0m"
	Skyb="\e[0m"
fi
}

Color_Y() {
echo -e "$Yellow$Say$White"
}

Color_R() {
echo -e "$Red$Say$White"
}

Color_B() {
echo -e "$Blue$Say$White"
}

Color_G() {
echo -e "$Skyb$Say$White"
}

GET_Choose() {
echo " "
read -p '请从上方选择一个操作:' Choose
}

Enter() {
read -p "按下[回车]键以继续..." Key
}

Decoration() {
echo -ne "$Skyb"
printf "%-70s\n" "-" | sed 's/\s/-/g'
echo -ne "$White"
}
