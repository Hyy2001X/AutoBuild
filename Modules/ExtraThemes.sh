# AutoBuild Script Module by Hyy2001

function ExtraThemes() {
Update=2020.07.07
Module_Version=V2.4.6
PKGHome=$Home/Projects/$Project/package

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
echo -e "https://github.com/rosywrt$White"
echo " "
echo -e "${Skyb}感谢以上作者的贡献!"
Decoration
echo " "
Enter
}


ExtraThemes_mod_git() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="已添加主题包 $PKG_NAME" && Color_Y
else
	Say="$PKG_NAME 添加失败!" && Color_R
fi
sleep 3
}

ExtraThemes_mod_svn() {
if [ -d ./$PKG_NAME ];then
	rm -rf ./$PKG_NAME
fi
svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
if [ -f ./$PKG_NAME/Makefile ] || [ -f ./$PKG_NAME/README.md ];then
	Say="已添加主题包 $PKG_NAME" && Color_Y
	rm -rf ./$PKG_NAME/.svn
else
	Say="$PKG_NAME 添加失败!" && Color_R
fi
sleep 2
}

while :
do
	cd $Home/Projects/$Project/package
	if [ ! -d ./theme ];then
		mkdir theme
	fi
	cd theme
	clear
	echo -e "${Blue}Extra Themes Script $Module_Version by Hyy2001${White}"
	echo -e "$Yellow"
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
			ExtraThemes_mod_git
			mv $PKGHome/theme/luci-theme-argon $PKGHome/lean/luci-theme-argon
		else
			PKG_URL="https://github.com/jerrykuku/luci-theme-argon"
			ExtraThemes_mod_git
		fi
	;;
	2)
		PKG_NAME=luci-theme-argon-mc
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/$PKG_NAME
		ExtraThemes_mod_svn
	;;
	3)
		PKG_NAME=luci-theme-argon-dark-mod
		PKG_URL=https://github.com/Lienol/openwrt-package/trunk/lienol/$PKG_NAME
		ExtraThemes_mod_svn
	;;
	4)
		PKG_NAME=luci-theme-argon-light-mod
		PKG_URL=https://github.com/Lienol/openwrt-package/trunk/lienol/$PKG_NAME
		ExtraThemes_mod_svn
	;;
	5)
		PKG_NAME=luci-theme-bootstrap-mod
		PKG_URL=https://github.com/Lienol/openwrt-package/trunk/lienol/$PKG_NAME
		ExtraThemes_mod_svn
	;;
	6)
		PKG_NAME=luci-theme-rosy
		PKG_URL=https://github.com/rosywrt/$PKG_NAME/trunk/
		ExtraThemes_mod_svn
	;;
	7)
		PKG_NAME=luci-theme-atmaterial
		PKG_URL=https://github.com/openwrt-develop/$PKG_NAME
		ExtraThemes_mod_git
	;;
	8)
		PKG_NAME=luci-theme-darkmatter
		PKG_URL=https://github.com/Lienol/$PKG_NAME/trunk/
		ExtraThemes_mod_svn
	;;
	9)
		PKG_NAME=luci-theme-opentomcat
		PKG_URL=https://github.com/Leo-Jo-My/$PKG_NAME
		ExtraThemes_mod_git
	;;
	10)
		PKG_NAME=luci-theme-opentomato
		PKG_URL=https://github.com/Leo-Jo-My/$PKG_NAME
		ExtraThemes_mod_git
	;;
	11)
		PKG_NAME=luci-theme-Butterfly
		PKG_URL=https://github.com/Leo-Jo-My/$PKG_NAME
		ExtraThemes_mod_git
	;;
	12)
		PKG_NAME=luci-theme-Butterfly-dark
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/$PKG_NAME
		ExtraThemes_mod_svn
	;;
	13)
		PKG_NAME=luci-theme-netgearv2
		PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/$PKG_NAME
		ExtraThemes_mod_svn
	;;
	esac
done
}
