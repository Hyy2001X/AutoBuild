# AutoBuild Script Module by Hyy2001

StorageDetails() {
Update=2020.08.14
Module_Version=V2.3.1

clear
cd $Home
Say="Loading Configuration..." && Color_Y
Backups_Size=`du -sh Backups | awk '{print $1}'`
Firmware_Size=`du -sh Firmware | awk '{print $1}'`
Lede_Size=`du -sh ./Projects/Lede | awk '{print $1}'`
Openwrt_Size=`du -sh ./Projects/Openwrt | awk '{print $1}'`
Lienol_Size=`du -sh ./Projects/Lienol | awk '{print $1}'`

clear
Say="Storage Details Script $Module_Version" && Color_B
Decoration
echo -e "$Skyb项目名称	存储位置				存储占用$White"
echo " "
Type_Space="				"
StorageDetails_Mod Lede /Projects/Lede $Lede_Size
Type_Space="			"
StorageDetails_Mod Openwrt /Projects/Openwrt $Openwrt_Size
StorageDetails_Mod Lienol /Projects/Lienol $Lienol_Size
Type_Space="				"
StorageDetails_Mod 固件 /Firmware $Firmware_Size
StorageDetails_Mod 备份 /Backups $Backups_Size
Decoration
Enter
}

StorageDetails_Mod() {
Say="$1		$2$Type_Space$3" && Color_Y
}
