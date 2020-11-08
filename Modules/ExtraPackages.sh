# AutoBuild Script Module by Hyy2001

ExtraPackages() {
Update=2020.11.08
Module_Version=V4.8.6-BETA

ExtraPackages_mkdir
while :
do
	cd $PKG_Dir
	clear
	MSG_TITLE "Extra Packages Script $Module_Version"
	echo "1.SmartDNS"
	echo "2.AdGuardHome"
	echo "3.OpenClash"
	echo "4.Clash"
	echo "5.OpenAppFilter"
	echo "6.Passwall"
	echo "7.[依赖包] Passwall"
	echo "8.MentoHust"
	echo "9.[微信推送] ServerChan "
	echo "10.[端口转发] Socat"
	echo "11.[Hello World] luci-app-vssr"
	echo "12.[京东签到] luci-app-jd-dailybonus"
	echo "13.[Argon配置] luci-app-argon-config"
	MSG_COM B "w.Li2nOnline's Packages Source"
	echo -e "\nq.返回\n"
	read -p '请从上方选择一个软件包:' Choose
	echo " "
	case $Choose in
	q)
		break
	;;
	w)
		SRC_NAME=lienol
		SRC_URL=https://github.com/xiaorouji/openwrt-package
		ExtraPackages_src-git
	;;
	1)
		grep "git.openwrt.org/project/luci.git" $Home/Projects/$Project/feeds.conf.default > /dev/null
		if [ $? -ne 0 ]; then
			PKG_NAME=smartdns
			PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t/smartdns
			ExtraPackages_svn
			PKG_NAME=luci-app-smartdns
			if [ $Project == Lede ];then
				PKG_URL="-b lede https://github.com/pymumu/luci-app-smartdns"
			else
				PKG_URL="https://github.com/pymumu/luci-app-smartdns"
			fi
			ExtraPackages_git
			rm -rf $Home/Projects/$Project/tmp
		else
			MSG_ERR "无法添加 SmartDNS"
			sleep 2
		fi
	;;
	2)
		PKG_NAME=luci-app-adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/trunk/package/diy/luci-app-adguardhome
		ExtraPackages_svn
		PKG_NAME=adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/trunk/package/diy/adguardhome
		ExtraPackages_svn
	;;
	3)
		SRC_NAME=OpenClash
		SRC_URL="https://github.com/vernesong/OpenClash;master"
		ExtraPackages_src-git
	;;
	4)
		PKG_NAME=luci-app-clash
		PKG_URL=https://github.com/frainzy1477/luci-app-clash
		ExtraPackages_git
	;;
	5)
		PKG_NAME=OpenAppFilter
		PKG_URL=https://github.com/Lienol/openwrt-OpenAppFilter
		ExtraPackages_git
	;;
	6)
		PKG_NAME=luci-app-passwall
		PKG_URL=https://github.com/xiaorouji/openwrt-package/trunk/lienol/luci-app-passwall
		ExtraPackages_svn
	;;
	7)
		clear
		for PD in $(cat  $Home/Additional/Passwall_Dependency)
		do
			PKG_NAME=$PD
			PKG_URL=https://github.com/xiaorouji/openwrt-package/trunk/package/$PD
			ExtraPackages_svn
		done
	;;
	8)
		PKG_NAME=luci-app-mentohust
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-app-mentohust
		ExtraPackages_svn
		PKG_NAME=mentohust
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/mentohust
		ExtraPackages_svn
	;;
	9)
		PKG_NAME=luci-app-serverchan
		PKG_URL=https://github.com/tty228/luci-app-serverchan
		ExtraPackages_git
	;;
	10)
		PKG_NAME=luci-app-socat
		PKG_URL=https://github.com/xiaorouji/openwrt-package/trunk/lienol/luci-app-socat
		ExtraPackages_svn
	;;
	11)
		PKG_NAME=luci-app-vssr
		PKG_URL=https://github.com/jerrykuku/luci-app-vssr
		ExtraPackages_git
	;;
	12)
		PKG_NAME=luci-app-jd-dailybonus
		PKG_URL=https://github.com/jerrykuku/luci-app-jd-dailybonus
		ExtraPackages_git
	;;
	13)
		PKG_NAME=luci-app-argon-config
		PKG_URL=https://github.com/jerrykuku/luci-app-argon-config
		ExtraPackages_git
	;;
	esac
done
}

ExtraThemes() {
ExtraPackages_mkdir

while :
do
	cd $PKG_Dir
	clear
	MSG_TITLE "添加第三方主题包"
	echo "1.luci-theme-argon"
	ExtraThemesList_File=$Home/Additional/ExtraThemes_List
	List_MaxLine=$(sed -n '$=' $ExtraThemesList_File)
	rm -f $Home/TEMP/Checked_Themes > /dev/null 2>&1
	for ((i=1;i<=$List_MaxLine;i++));
		do   
			Theme=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
			if [ -f $PKG_Dir/$Theme/Makefile ];then
				echo -e "$(($i + 1)).${Yellow}${Theme}${White}"
				echo "$Theme" >> $Home/TEMP/Checked_Themes
			else
				echo "$(($i + 1)).${Theme}"
			fi
	done
	MSG_COM G "\na.添加所有主题包"
	MSG_COM "u.更新已安装的主题包"
	echo -e "q.返回\n"
	read -p '请从上方选择一个主题包:' Choose
	case $Choose in
	a)
		clear
		for ((i=1;i<=$List_MaxLine;i++));
		do
			URL_TYPE=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $1}')
			PKG_NAME=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
			PKG_URL=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $3}')
			case $URL_TYPE in
			git)
				ExtraPackages_git
			;;
			svn)
				ExtraPackages_svn
			esac
		done
		Enter
	;;
	u)
		clear
		cat $Home/TEMP/Checked_Themes | while read Theme
		do
			echo -e "$Yellow正在更新 $Blue$Theme $Yellow...$White"
			cd ./$Theme
			svn update > /dev/null 2>&1
			git pull > /dev/null 2>&1
			cd ..
		done
		Enter
	;;
	q)
		break
	;;
	1)
		PKG_NAME=luci-theme-argon
		if [ $Project == Lede ];then
			if [ -d $PKG_Home/lean/luci-theme-argon ];then
				rm -rf $PKG_Home/lean/luci-theme-argon
			fi
			PKG_URL=" -b 18.06 https://github.com/jerrykuku/luci-theme-argon"
			ExtraPackages_git
			mv $PKG_Dir/luci-theme-argon $PKG_Home/lean/luci-theme-argon
		else
			PKG_URL="https://github.com/jerrykuku/luci-theme-argon"
			ExtraPackages_git
		fi
	;;
	*)
		if [ $Choose -gt 0 ] > /dev/null 2>&1 ;then
			if [ $(($Choose - 1)) -le $List_MaxLine ] > /dev/null 2>&1 ;then
				Choose=$(($Choose - 1))
				URL_TYPE=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $1}')
				PKG_NAME=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $2}')
				PKG_URL=$(sed -n ${Choose}p $ExtraThemesList_File | awk '{print $3}')
				case $URL_TYPE in
				git)
					ExtraPackages_git
				;;
				svn)
					ExtraPackages_svn
				;;
				*)
					MSG_ERR "[第 $Choose 行：$URL_TYPE] 格式错误!请检查'/Additional/ExtraThemes_List'是否填写正确."
					sleep 3
				esac
			else
				MSG_ERR "输入错误,请输入正确的数字!"
				sleep 2
			fi
		else
			MSG_ERR "输入错误,请输入正确的数字!"
			sleep 2
		fi
	esac
done
}

ExtraPackages_git() {
[ -d $PKG_Dir/$PKG_NAME ] && rm -rf $PKG_Dir/$PKG_NAME
git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f $PKG_Dir/$PKG_NAME/Makefile ] || [ -f $PKG_Dir/$PKG_NAME/README.md ];then
	MSG_SUCC "[GIT] 已添加 $PKG_NAME"
else
	MSG_ERR "[GIT] 未添加 $PKG_NAME"
fi
sleep 2
}

ExtraPackages_svn() {
[ -d $PKG_Dir/$PKG_NAME ] && rm -rf $PKG_Dir/$PKG_NAME
svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f $PKG_Dir/$PKG_NAME/Makefile ] || [ -f $PKG_Dir/$PKG_NAME/README.md ];then
	MSG_SUCC "[SVN] 已添加 $PKG_NAME"
else
	MSG_ERR "[SVN] 未添加 $PKG_NAME"
fi
sleep 2
}

ExtraPackages_src-git() {
grep "$SRC_NAME" $Home/Projects/$Project/feeds.conf.default > /dev/null
if [ $? -ne 0 ]; then
	cd $Home/Projects/$Project
	clear
	echo "src-git $SRC_NAME $SRC_URL" >> feeds.conf.default
	./scripts/feeds update $SRC_NAME
	./scripts/feeds install -a
	Enter
else
	MSG_ERR "添加失败,[$SRC_NAME] 无法重复添加!"
	sleep 2
fi
}

ExtraPackages_mkdir() {
PKG_Home=$Home/Projects/$Project/package
[ ! -d $PKG_Home/ExtraPackages ] && mkdir -p $PKG_Home/ExtraPackages
PKG_Dir=$PKG_Home/ExtraPackages
}
