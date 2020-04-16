# AutoBuild Script Module by Hyy2001

function ExtraThemes() {
Update=2020.04.16
Module_Version=V1.0-DEV

clear
cd $Home/Projects
if [ -d ./$Project/package/themes ];then
	:
else
	cd ./$Project/package
	mkdir themes	
fi
clear
if [ $Project == Lede ];then
	cd $Home/Projects/$Project/package/lean
	rm -rf luci-theme-argon
	git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
	cd $Home/Projects/$Project/package/themes
	rm -rf luci-theme-rosy
	git clone https://github.com/rosywrt/luci-theme-rosy luci-theme-rosy
	cd $Home/Projects/$Project
	grep "darkmatter" feeds.conf.default > /dev/null
	if [ $? -eq 0 ]; then
		:
	else
		echo "src-git darkmatter https://github.com/Lienol/luci-theme-darkmatter;luci-18.06" >> feeds.conf.default
		Say="已添加luci-theme-darkmatter到feeds.conf.default" && Color_Y
	fi
	scripts/feeds update darkmatter
	scripts/feeds install luci-theme-darkmatter
	echo " "
	if [ -d ./package/lean/luci-theme-argon ];then
		Say="已添加主题包 luci-theme-argon" && Color_Y
	else
		Say="主题包 luci-theme-argon 添加失败!" && Color_R
	fi
	if [ -d ./package/themes/luci-theme-rosy ];then
		Say="已添加主题包 luci-theme-rosy" && Color_Y
	else
		Say="主题包 luci-theme-rosy 添加失败!" && Color_R
	fi
	if [ -d ./feeds/darkmatter ];then
		Say="已添加主题包 luci-theme-darkmatter" && Color_Y
	else
		Say="主题包 luci-theme-darkmatter 添加失败!" && Color_R
	fi	
else
	cd $Home/Projects/$Project/package/themes
	rm -rf luci-theme-argon
	git clone https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
	echo " "
	if [ -d ./luci-theme-argon ];then
		Say="已添加主题包 luci-theme-argon" && Color_Y
	else
		Say="主题包 luci-theme-argon 添加失败!" && Color_R
	fi
fi	
Enter
}
