# AutoBuild Script Module by Hyy2001

ExtraPackages() {
Update=2020.07.20
Module_Version=V4.1

while :
do
	cd $Home/Projects/$Project/package
	if [ ! -d ./custom ];then
		mkdir custom
	fi
	cd custom
	clear
	Say="Extra Packages Script $Module_Version" && Color_B
	echo " "
	echo -e "1.SmartDNS"
	echo -e "2.AdGuardHome"
	echo -e "3.Openclash"
	echo -e "4.Clash"
	Say="w.[软件库]Lienol" && Color_B
	echo " "
	echo "q.返回"
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
		ExtraPackages_git
		mv ./openwrt-smartdns smartdns
		PKG_NAME=luci-app-smartdns
		if [ $Project == Lede ];then
			PKG_URL="-b lede https://github.com/pymumu/luci-app-smartdns"
		else
			PKG_URL="https://github.com/pymumu/luci-app-smartdns"
		fi
		ExtraPackages_git
		rm -rf ../../tmp
	;;
	2)
		PKG_NAME=luci-app-adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/branches/dev-master/package/diy/luci-app-adguardhome
		ExtraPackages_svn
		PKG_NAME=adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/branches/dev-master/package/diy/adguardhome
		ExtraPackages_svn
	;;
	3)
		SRC_NAME=Openclash
		SRC_URL=https://github.com/vernesong/OpenClash;master
		ExtraPackages_src-git
	;;
	4)
		PKG_NAME=luci-app-clash
		PKG_URL=https://github.com/frainzy1477/luci-app-clash
		ExtraPackages_git
	;;
	w)
		SRC_NAME=lienol
		SRC_URL=https://github.com/Lienol/openwrt-package
		ExtraPackages_src-git
	;;
	esac
done
}

ExtraThemes() {
while :
do
	cd $Home/Projects/$Project/package
	if [ ! -d ./theme ];then
		mkdir theme
	fi
	cd theme
	clear
	echo -e "${Blue}添加第三方主题包${Yellow}"
	echo "1.luci-theme-argon"
	echo "2.luci-theme-argon-mc"
	echo "3.luci-theme-argon-dark-mod"
	echo "4.luci-theme-argon-light-mod"
	echo "5.luci-theme-bootstrap-mod"
	echo "6.luci-theme-rosy"
	echo "7.luci-theme-atmaterial"
	echo "8.luci-theme-darkmatter"
	echo "9.luci-theme-opentomcat"
	echo "10.luci-theme-opentomato"
	echo "11.luci-theme-Butterfly"
	echo "12.luci-theme-Butterfly-dark"
	echo "13.luci-theme-netgearv2"
	echo "14.luci-theme-edge"
	echo "15.luci-theme-btmod"
	echo -e "${White}"
	echo "x.关于主题"
	echo "q.返回"
	echo " "
	read -p '请从上方选择一个主题包:' Choose
	echo " "
	case $Choose in
	q)
		break
	;;
	x)
		ExtraThemes_info
	;;
	1)
		PKG_NAME=luci-theme-argon
		if [ $Project == Lede ];then
			if [ -d ../lean/luci-theme-argon ];then
				rm -rf ../lean/luci-theme-argon
			fi
			PKG_URL=" -b 18.06 https://github.com/jerrykuku/luci-theme-argon"
			ExtraThemes_git
			mv $Home/Projects/$Project/package/theme/luci-theme-argon $Home/Projects/$Project/package/lean/luci-theme-argon
		else
			PKG_URL="https://github.com/jerrykuku/luci-theme-argon"
			ExtraThemes_git
		fi
	;;
	2)
		PKG_NAME=luci-theme-argon-mc
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-argon-mc
		ExtraThemes_svn
	;;
	3)
		PKG_NAME=luci-theme-argon-dark-mod
		PKG_URL=https://github.com/Lienol/openwrt-package/trunk/lienol/luci-theme-argon-dark-mod
		ExtraThemes_svn
	;;
	4)
		PKG_NAME=luci-theme-argon-light-mod
		PKG_URL=https://github.com/Lienol/openwrt-package/trunk/lienol/luci-theme-argon-light-mod
		ExtraThemes_svn
	;;
	5)
		PKG_NAME=luci-theme-bootstrap-mod
		PKG_URL=https://github.com/Lienol/openwrt-package/trunk/lienol/luci-theme-bootstrap-mod
		ExtraThemes_svn
	;;
	6)
		PKG_NAME=luci-theme-rosy
		PKG_URL=https://github.com/rosywrt/luci-theme-rosy/trunk/
		ExtraThemes_svn
	;;
	7)
		PKG_NAME=luci-theme-atmaterial
		PKG_URL=https://github.com/openwrt-develop/luci-theme-atmaterial
		ExtraThemes_git
	;;
	8)
		PKG_NAME=luci-theme-darkmatter
		PKG_URL=https://github.com/Lienol/luci-theme-darkmatter/trunk/
		ExtraThemes_svn
	;;
	9)
		PKG_NAME=luci-theme-opentomcat
		PKG_URL=https://github.com/Leo-Jo-My/luci-theme-opentomcat
		ExtraThemes_git
	;;
	10)
		PKG_NAME=luci-theme-opentomato
		PKG_URL=https://github.com/Leo-Jo-My/luci-theme-opentomato
		ExtraThemes_git
	;;
	11)
		PKG_NAME=luci-theme-Butterfly
		PKG_URL=https://github.com/Leo-Jo-My/luci-theme-Butterfly
		ExtraThemes_git
	;;
	12)
		PKG_NAME=luci-theme-Butterfly-dark
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-Butterfly-dark
		ExtraThemes_svn
	;;
	13)
		PKG_NAME=luci-theme-netgearv2
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-netgearv2
		ExtraThemes_svn
	;;
	14)
		PKG_NAME=luci-theme-edge
		if [ $Project == Lede ];then
			PKG_URL=" -b 18.06 https://github.com/garypang13/luci-theme-edge"
		else
			PKG_URL="https://github.com/garypang13/luci-theme-edge"
		fi
		ExtraThemes_git
	;;
	15)
		PKG_NAME=luci-theme-btmod
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-btmod
		ExtraThemes_svn
	;;
	esac
done
}

ExtraPackages_git() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="已添加软件包 $PKG_NAME" && Color_Y
	rm -rf ./$PKG_NAME/.git
else
	Say="未添加软件包 $PKG_NAME" && Color_R
fi
sleep 2
}

ExtraPackages_svn() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="已添加软件包 $PKG_NAME" && Color_Y
	rm -rf ./$PKG_NAME/.svn
else
	Say="未添加软件包 $PKG_NAME" && Color_R
fi
sleep 2
}

ExtraPackages_src-git() {
cd $Home/Projects/$Project
grep "$SRC_NAME" feeds.conf.default > /dev/null
if [ $? -ne 0 ]; then
	clear
	echo "src-git $SRC_NAME $SRC_URL" >> feeds.conf.default
	./scripts/feeds update $SRC_NAME
	./scripts/feeds install -a
	echo " "
	Enter
else
	Say="添加失败,无法重复添加!" && Color_Y
	sleep 2
fi
}

ExtraThemes_git() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="已添加主题包 $PKG_NAME" && Color_Y
else
	Say="未添加主题包 $PKG_NAME" && Color_R
fi
sleep 3
}

ExtraThemes_svn() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="已添加主题包 $PKG_NAME" && Color_Y
	rm -rf ./$PKG_NAME/.svn
else
	Say="未添加主题包 $PKG_NAME" && Color_R
fi
sleep 2
}

ExtraThemes_info() {
clear
echo -e "${Blue}Extra Themes Script $Module_Version by Hyy2001${White}"
Decoration
echo -e "${Skyb}主题源码来自以下作者:$Yellow"
echo " "
echo "https://github.com/jerrykuku"
echo "https://github.com/project-openwrt"
echo "https://github.com/Lienol"
echo "https://github.com/openwrt-develop"
echo "https://github.com/Leo-Jo-My"
echo "https://github.com/garypang13"
echo -e "https://github.com/rosywrt$White"
echo " "
Decoration
echo " "
Enter
}
