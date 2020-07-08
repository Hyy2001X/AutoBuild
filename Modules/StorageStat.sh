# AutoBuild Script Module by Hyy2001

StorageStat() {
Update=2020.07.09
Module_Version=V2.0-BETA

clear
Say="Loading Configuration..." && Color_Y
echo " "
cd $Home/Projects
Lede_Size=`du -sh Lede | awk '{print $1}'`
Openwrt_Size=`du -sh Openwrt | awk '{print $1}'`
Lienol_Size=`du -sh Lienol | awk '{print $1}'`
cd $Home
Backups_Size=`du -sh Backups | awk '{print $1}'`
Packages_Size=`du -sh Packages | awk '{print $1}'`
clear
Say="Storage Statistics Script $Module_Version" && Color_B
Decoration
echo -e "$Skyb项目名称	存储位置				存储占用$White"
echo " "
if [ ! $Lede_Size == 0 ];then
	Say="Lede		/Projects/Lede				$Lede_Size" && Color_Y
else
	Say="Lede		未检测到				0KB" && Color_R
fi

if [ ! $Openwrt_Size == 0 ];then
	Say="Openwrt		/Projects/Openwrt			$Openwrt_Size" && Color_Y
else
	Say="Openwrt		未检测到				0KB" && Color_R
fi

if [ ! $Lienol_Size == 0 ];then
	Say="Lienol		/Projects/Lienol			$Lienol_Size" && Color_Y
else
	Say="Lienol		未检测到				0KB" && Color_R
fi
echo " "
if [ ! $Backups_Size == 0 ];then
	Say="备份		/Backups				$Backups_Size" && Color_Y
else
	Say="备份		未检测到				0KB" && Color_R
fi

if [ ! $Packages_Size == 0 ];then
	Say="生成的固件	/Packages				$Packages_Size" && Color_Y
else
	Say="生成的固件	未检测到				0KB" && Color_R
fi
Decoration
echo " "
Enter
}
