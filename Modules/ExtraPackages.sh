# AutoBuild Script Module by Hyy2001

function ExtraPackages() {
Update=2020.06.16
Module_Version=V3.0-BETA

ExtraPackages_mod_git() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="$PKG_NAME 添加成功!" && Color_Y
	rm -rf ./$PKG_NAME/.git
else
	Say="$PKG_NAME 添加失败!" && Color_R
fi
sleep 2
}

ExtraPackages_mod_svn() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="$PKG_NAME 添加成功!" && Color_Y
	rm -rf ./$PKG_NAME/.svn
else
	Say="$PKG_NAME 添加失败!" && Color_R
fi
sleep 2
}

ExtraPackages_Check1() {
if [ -f ./$PKG_NAME/Makefile ];then
	Package_Stat=$Yellow已检测到$Yellow
else
	Package_Stat=$Red未检测到$Yellow
fi
}

ExtraPackages_Check2() {
if [ -f ./$PKG_NAME/Makefile ] && [ -f ./luci-app-$PKG_NAME/Makefile ];then
	Package_Stat=$Yellow已检测到$Yellow
else
	Package_Stat=$Red未检测到$Yellow
fi
}

while :
do
	cd $Home/Projects/$Project/package
	if [ ! -d ./custom ];then
		mkdir custom
	fi
	cd custom
	clear
	Say="Extra Packages Script $Module_Version by Hyy2001" && Color_B
	Decoration
	echo -e "$Skyb软件包			状态$Yellow"
	PKG_NAME=smartdns
	ExtraPackages_Check2
	echo -e "1.SmartDNS		$Package_Stat"
	PKG_NAME=adguardhome
	ExtraPackages_Check2
	if [ $Project == Lienol ];then
		Package_Stat=$Yellow已检测到$Yellow
	fi
	echo -e "2.AdGuardHome		$Package_Stat"
	PKG_NAME=luci-app-openclash
	ExtraPackages_Check1
	echo -e "3.$PKG_NAME	$Package_Stat"
	PKG_NAME=luci-app-clash
	ExtraPackages_Check1
	echo -e "4.$PKG_NAME	$Package_Stat"
	PKG_NAME=luci-app-passwall
	ExtraPackages_Check1
	echo -e "5.$PKG_NAME	$Package_Stat"
	echo -e "${Blue}w.[软件库]Lienol$White"
	echo " "
	echo "q.返回"
	Decoration
	echo " "
	read -p '请从上方选择一个软件包:' Choose
	echo " "
	case $Choose in
	q)
		break
	;;
	1)
		PKG_NAME=openwrt-smartdns
		PKG_URL=https://github.com/pymumu/openwrt-smartdns
		ExtraPackages_mod_git
		mv ./openwrt-smartdns smartdns
		PKG_NAME=luci-app-smartdns
		if [ $Project == Lede ];then
			PKG_URL="-b lede https://github.com/pymumu/luci-app-smartdns"
		else
			PKG_URL="https://github.com/pymumu/luci-app-smartdns"
		fi
		ExtraPackages_mod_git
	;;
	2)
		PKG_NAME=luci-app-adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/branches/dev-master/package/diy/luci-app-adguardhome
		ExtraPackages_mod_svn
		PKG_NAME=adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/branches/dev-master/package/diy/adguardhome
		ExtraPackages_mod_svn
	;;
	3)
		PKG_NAME=luci-app-openclash
		PKG_URL=https://github.com/vernesong/OpenClash/branches/master/luci-app-openclash
		ExtraPackages_mod_svn
	;;
	4)
		PKG_NAME=luci-app-clash
		PKG_URL=https://github.com/frainzy1477/luci-app-clash
		ExtraPackages_mod_git
	;;
	5)
		PKG_NAME=luci-app-passwall
		PKG_URL=https://github.com/Hyy2001X/luci-app-passwall
		ExtraPackages_mod_git
	;;
	w)
		cd $Home/Projects/$Project
		grep "lienol" feeds.conf.default > /dev/null
		if [ $? -ne 0 ]; then
			clear
			echo "src-git lienol https://github.com/Lienol/openwrt-package" >> feeds.conf.default
			./scripts/feeds update lienol
			./scripts/feeds install -a
			echo " "
			Enter
		else
			Say="无法重复添加[Lienol]软件库!" && Color_Y
			sleep 2
		fi
	;;
	esac
done
}
