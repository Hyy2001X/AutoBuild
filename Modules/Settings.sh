# AutoBuild Script Module by Hyy2001

Settings() {
Update=2020.09.27
Module_Version=V2.1

while :
do
	Settings_Props
	ColorfulUI_Check
	clear
	Say="脚本设置[实验性]\n" && Color_B
	if [ $ColorfulUI == 0 ];then
		Say="1.高亮显示		[关闭]" && Color_R
	else
		Say="1.高亮显示		[打开]" && Color_Y
	fi
	if [ $DeveloperMode == 0 ];then
		Say="2.调试模式		[关闭]" && Color_R
	else
		Say="2.调试模式		[打开]" && Color_Y
	fi
	if [ $SaveCompileLog == 0 ];then
		Say="3.保存编译日志		[关闭]" && Color_R
	else
		Say="3.保存编译日志		[打开]" && Color_Y
	fi
	if [ $ScriptUpdater == 0 ];then
		Say="4.脚本更新模式		[新版]" && Color_Y
	else
		Say="4.脚本更新模式		[旧版]" && Color_B
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
		Set_Default_Settings
	;;
	1)
		if [ $ColorfulUI == 0 ];then
			ColorfulUI=1
			sed -i "s/ColorfulUI=0/ColorfulUI=1/g" ./Settings
		else
			ColorfulUI=0
			sed -i "s/ColorfulUI=1/ColorfulUI=0/g" ./Settings
		fi
	;;
	2)
		if [ $DeveloperMode == 0 ];then
			DeveloperMode=1
			sed -i "s/DeveloperMode=0/DeveloperMode=1/g" ./Settings
		else
			DeveloperMode=0
			sed -i "s/DeveloperMode=1/DeveloperMode=0/g" ./Settings
		fi
	;;
	3)
		if [ $SaveCompileLog == 0 ];then
			SaveCompileLog=1
			sed -i "s/SaveCompileLog=0/SaveCompileLog=1/g" ./Settings
		else
			SaveCompileLog=0
			sed -i "s/SaveCompileLog=1/SaveCompileLog=0/g" ./Settings
		fi
	;;
	4)
		if [ $ScriptUpdater == 0 ];then
			ScriptUpdater=1
			sed -i "s/ScriptUpdater=0/ScriptUpdater=1/g" ./Settings
		else
			SaveCompileLog=0
			sed -i "s/ScriptUpdater=1/ScriptUpdater=0/g" ./Settings
		fi
	esac
done
}

Default_Settings() { 
DeveloperMode=0
ColorfulUI=1
SaveCompileLog=0
ScriptUpdater=0
}

Set_Default_Settings() {
Default_Settings
echo "DeveloperMode=$DeveloperMode" > $Home/Configs/Settings
echo "ColorfulUI=$ColorfulUI" >> $Home/Configs/Settings
echo "SaveCompileLog=$SaveCompileLog" >> $Home/Configs/Settings
echo "ScriptUpdater=$ScriptUpdater" >> $Home/Configs/Settings
}

Settings_Props() {
cd $Home/Configs
if [ ! -f $Home/Configs/Settings ];then
	Set_Default_Settings
else
	. $Home/Configs/Settings
fi
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
echo -e "$White"
read -p '请从上方选择一个操作:' Choose
}

Enter() {
echo -e "$White"
read -p "按下[回车]键以继续..." Key
}

Decoration() {
echo -ne "$Skyb"
printf "%-70s\n" "-" | sed 's/\s/-/g'
echo -ne "$White"
}
