# AutoBuild Script Module by Hyy2001

function ExtraPackages() {
Update=2020.05.19
Module_Version=V2.3
PKGHome=$Home/Projects/$Project/package

ExtraPackages_mod_git() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="$PKG_NAME 添加成功!" && Color_Y
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

while :
do
	cd $Home/Projects/$Project/package
	if [ ! -d ./custom ];then
		mkdir custom
	fi
	cd custom
	clear
	Say="Extra Packages Script $Module_Version by Hyy2001" && Color_B
	echo -e "$Skyb"
	echo "1.SmartDNS"
	echo "2.AdGuardHome"
	echo "3.OpenClash"
	echo "4.luci-app-clash"
	echo "5.luci-app-passwall"
	echo -e "${Yellow}w.[软件库]Lienol$White"
	echo -e "${White}"
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
		PKG_URL=https://github.com/pymumu/$PKG_NAME
		ExtraPackages_mod_git
		PKG_NAME=luci-app-smartdns
		if [ $Project == Lede ];then
			PKG_URL="-b lede https://github.com/pymumu/$PKG_NAME"
		else
			PKG_URL="https://github.com/pymumu/$PKG_NAME"
		fi
		ExtraPackages_mod_git
	;;
	2)
		PKG_NAME=luci-app-adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/trunk/package/diy/$PKG_NAME
		ExtraPackages_mod_svn
		PKG_NAME=adguardhome
		PKG_URL=https://github.com/Lienol/openwrt/trunk/package/diy/$PKG_NAME
		ExtraPackages_mod_svn
	;;
	3)
		PKG_NAME=luci-app-openclash
		PKG_URL=https://github.com/vernesong/OpenClash/trunk/$PKG_NAME
		ExtraPackages_mod_svn
	;;
	4)
		PKG_NAME=luci-app-clash
		PKG_URL=https://github.com/frainzy1477/$PKG_NAME
		ExtraPackages_mod_git
	;;
	5)
		PKG_NAME=luci-app-passwall
		PKG_URL=https://github.com/Hyy2001X/$PKG_NAME
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
