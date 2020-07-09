# AutoBuild Script Module by Hyy2001

StorageStat() {
Update=2020.07.09
Module_Version=V2.2-BETA

cd $Home
clear

Say="Loading Configuration..." && Color_Y
Backups_Size=`du -sh Backups | awk '{print $1}'`
Packages_Size=`du -sh Packages | awk '{print $1}'`
Lede_Size=`du -sh ./Projects/Lede | awk '{print $1}'`
Openwrt_Size=`du -sh ./Projects/Openwrt | awk '{print $1}'`
Lienol_Size=`du -sh ./Projects/Lienol | awk '{print $1}'`

clear
Say="Storage Statistics Script $Module_Version" && Color_B
Decoration
echo -e "$Skyb项目名称	存储位置				存储占用$White"
echo " "

Type_Name=Lede
Type_Size=$Lede_Size
Type_Path=/Projects/Lede
Type_Space="				"
StorageStat_Mod

Type_Name=Openwrt
Type_Size=$Openwrt_Size
Type_Path=/Projects/Openwrt
Type_Space="			"
StorageStat_Mod

Type_Name=Lienol
Type_Size=$Lienol_Size
Type_Path=/Projects/Lienol
Type_Space="			"
StorageStat_Mod

Type_Name=备份
Type_Size=$Backups_Size
Type_Path=/Backups
Type_Space="				"
StorageStat_Mod

Type_Name=固件
Type_Size=$Packages_Size
Type_Path=/Packages
Type_Space="				"
StorageStat_Mod

Decoration
echo " "
Enter
}

StorageStat_Mod() {
Say="$Type_Name		$Type_Path$Type_Space$Type_Size" && Color_Y
}
