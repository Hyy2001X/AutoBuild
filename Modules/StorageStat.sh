# AutoBuild Script Module by Hyy2001
Update=2020.04.02
Version=V1.0.0

function StorageStat() {
Decoration() {
	echo -ne "$Skyb"
	printf "%-70s\n" "-" | sed 's/\s/-/g'
	echo -ne "$White"
}

clear
Say="Loading Configuration..." && Color_Y
cd $Home/Projects
if [ -d ./Lede ];then
	Lede_Size=$((`du -s Lede |awk '{print $1}'`))
	Lede_Check=1
else
	Lede_Check=0
fi
if [ -d ./Openwrt ];then
	Openwrt_Size=$((`du -s Openwrt |awk '{print $1}'`))
	Openwrt_Check=1
else
	Openwrt_Check=0
fi
if [ -d ./Lienol ];then
	Lienol_Size=$((`du -s Lienol |awk '{print $1}'`))	
	Lienol_Check=1
else
	Lienol_Check=0
fi
cd $Home
if [ -d ./Backups ];then
	Backups_Size=$((`du -s Backups |awk '{print $1}'`))
	Backups_Check=1
else
	Backups_Check=0
fi
if [ -d ./Packages ];then
	Packages_Size=$((`du -s Packages |awk '{print $1}'`))
	Packages_Check=1
else
	Packages_Check=0
fi

clear
Say="Storage Statistics Script $Version by Hyy2001" && Color_B
Decoration
echo -e "$Skyb项目名称	位置				存储占用$White"
echo " "
if [ $Lede_Check == 1 ];then
	echo -ne "${Yellow}"
	awk 'BEGIN{printf "Lede		/Projects/Lede			%.2fGB\n",'$((Lede_Size))'/1048576}'
	echo -ne "${White}"
else
	echo -e "${Red}Lede		未检测到			0KB${White}"
fi

if [ $Openwrt_Check == 1 ];then
	echo -ne "${Yellow}"
	awk 'BEGIN{printf "Openwrt		/Projects/Openwrt		%.2fGB\n",'$((Openwrt_Size))'/1048576}'
	echo -ne "${White}"
else
	echo -e "${Red}Openwrt		未检测到			0KB${White}"
fi

if [ $Lienol_Check == 1 ];then
	echo -ne "${Yellow}"
	awk 'BEGIN{printf "Lienol		/Projects/Lienol		%.2fGB\n",'$((Lienol_Size))'/1048576}'
	echo -ne "${White}"
else
	echo -e "${Red}Lienol		未检测到			0KB${White}"
fi
echo " "
if [ $Backups_Check == 1 ];then
	echo -ne "${Yellow}"
	awk 'BEGIN{printf "Backups		/Backups			%.2fMB\n",'$((Backups_Size))'/1024}'
	echo -ne "${White}"
else
	echo -e "${Red}Backups		未检测到			0KB${White}"
fi

if [ $Packages_Check == 1 ];then
	echo -ne "${Yellow}"
	awk 'BEGIN{printf "Packages	/Packages			%.2fMB\n",'$((Packages_Size))'/1024}'
	echo -ne "${White}"
else
	echo -e "${Red}Packages	未检测到			0KB${White}"
fi
echo " "
Decoration
echo " "
Enter
}
