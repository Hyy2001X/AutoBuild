# AutoBuild Script Module by Hyy2001

ExtraPackages() {
	Update=2021.07.09
	Module_Version=V4.9.8

	ExtraPackages_mkdir
	while :
	do
		cd $PKG_Dir
		clear
		MSG_TITLE "Extra Packages Script $Module_Version"
		echo "1.SmartDNS"
		echo "2.[AdGuardHome] luci-app-adguardhome"
		echo "3.OpenClash"
		echo "4.Clash"
		echo "5.OpenAppFilter"
		echo "6.Passwall"
		echo "7.MentoHust"
		echo "8.[微信推送] ServerChan "
		echo "9.[端口转发] Socat"
		echo "10.[Hello World] luci-app-vssr"
		echo "11.[Argon 配置] luci-app-argon-config"
		echo "12.[关机/重启] luci-app-shutdown"
		echo -e "\nq.返回\n"
		read -p '请从上方选择一个软件包:' Choose
		case $Choose in
		q)
			break
		;;
		1)
			PKG_NAME=smartdns
			PKG_URL=https://github.com/kenzok8/openwrt-packages/trunk/smartdns
			ExtraPackages_svn
			PKG_NAME=luci-app-smartdns
			if [[ $Project == Lede ]];then
				PKG_URL="-b lede https://github.com/pymumu/luci-app-smartdns"
			else
				PKG_URL="https://github.com/pymumu/luci-app-smartdns"
			fi
			ExtraPackages_git
			rm -rf $Home/Projects/$Project/tmp
		;;
		2)
			PKG_NAME=luci-app-adguardhome
			PKG_URL=https://github.com/Hyy2001X/luci-app-adguardhome
			ExtraPackages_git
		;;
		3)
			SRC_NAME=OpenClash
			SRC_URL="https://github.com/vernesong/OpenClash"
			ExtraPackages_git
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
			PKG_URL=https://github.com/xiaorouji/openwrt-passwall
			ExtraPackages_git
		;;
		7)
			PKG_NAME=luci-app-mentohust
			PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-app-mentohust
			ExtraPackages_svn
			PKG_NAME=mentohust
			PKG_URL=https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/mentohust
			ExtraPackages_svn
		;;
		8)
			PKG_NAME=luci-app-serverchan
			PKG_URL=https://github.com/tty228/luci-app-serverchan
			ExtraPackages_git
		;;
		9)
			PKG_NAME=luci-app-socat
			PKG_URL=https://github.com/Lienol/openwrt-package/trunk/luci-app-socat
			ExtraPackages_svn
		;;
		10)
			PKG_NAME=luci-app-vssr
			PKG_URL=https://github.com/jerrykuku/luci-app-vssr
			ExtraPackages_git
		;;
		11)
			PKG_NAME=luci-app-argon-config
			PKG_URL=https://github.com/jerrykuku/luci-app-argon-config
			ExtraPackages_git
		;;
		12)
			PKG_NAME=luci-app-shutdown
			PKG_URL=https://github.com/Hyy2001X/luci-app-shutdown
			ExtraPackages_git
		;;
		esac
	done
}

ExtraThemes() {
	ExtraPackages_mkdir

	while :
	do
		clear
		MSG_TITLE "添加第三方主题包"
		if [[ -f $PKG_Home/lean/luci-theme-argon/Makefile ]];then
			Theme_Version="$(cat $PKG_Home/lean/luci-theme-argon/Makefile | grep 'PKG_VERSION' | cut -c14-20)"
			echo -e "1.${Yellow}luci-theme-argon [${Theme_Version}]${White}"
		else
			echo "1.luci-theme-argon"
		fi
		cd $PKG_Dir
		ExtraThemesList_File=$Home/Additional/ExtraThemes_List
		List_MaxLine=$(sed -n '$=' $ExtraThemesList_File)
		rm -f $Home/TEMP/Checked_Themes > /dev/null 2>&1
		for ((i=1;i<=$List_MaxLine;i++));
			do
				Theme=$(sed -n ${i}p $ExtraThemesList_File | awk '{print $2}')
				if [[ -f $PKG_Dir/$Theme/Makefile ]];then
					if [[ $(cat $PKG_Dir/$Theme/Makefile) =~ PKG_VERSION ]];then
						GET_Version="$(cat $PKG_Dir/$Theme/Makefile | grep 'PKG_VERSION' | cut -c14-20)"
						Theme_Version=" [${GET_Version}]"
						if [[ $(cat $PKG_Dir/$Theme/Makefile) =~ PKG_RELEASE ]];then
							GET_Release="$(cat $PKG_Dir/$Theme/Makefile | grep 'PKG_RELEASE' | cut -c14-20)"
							Theme_Version=" [${GET_Version}-${GET_Release}]"
						fi
						echo -e "$(($i + 1)).${Yellow}${Theme}${Theme_Version}${White}"
					else
						echo -e "$(($i + 1)).${Yellow}${Theme}${White}"
					fi
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
			if [[ -f $Home/TEMP/Checked_Themes ]];then
				clear
				cat $Home/TEMP/Checked_Themes | while read Theme
				do
					MSG_WAIT "正在更新 $Theme ..."
					cd ./$Theme
					svn update > /dev/null 2>&1
					git pull > /dev/null 2>&1
					cd ..
				done
				Enter
			else
				MSG_ERR "未安装任何主题包!"
				sleep 2
			fi
		;;
		q)
			break
		;;
		1)
			PKG_NAME=luci-theme-argon
			if [[ $Project == Lede ]];then
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
			if [[ $Choose -gt 0 ]] > /dev/null 2>&1 ;then
				if [[ $(($Choose - 1)) -le $List_MaxLine ]] > /dev/null 2>&1 ;then
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
	[[ -d $PKG_Dir/$PKG_NAME ]] && rm -rf $PKG_Dir/$PKG_NAME
	git clone $PKG_URL $PKG_NAME > /dev/null 2>&1
	if [[ -f $PKG_Dir/$PKG_NAME/Makefile || -f $PKG_Dir/$PKG_NAME/README.md || -n $(ls -A $PKG_Dir/$PKG_NAME) ]];then
		MSG_SUCC "[GIT] 已添加 $PKG_NAME"
	else
		MSG_ERR "[GIT] 未添加 $PKG_NAME"
	fi
	sleep 2
}

ExtraPackages_svn() {
	[[ -d $PKG_Dir/$PKG_NAME ]] && rm -rf $PKG_Dir/$PKG_NAME
	svn checkout $PKG_URL $PKG_NAME > /dev/null 2>&1
	if [[ -f $PKG_Dir/$PKG_NAME/Makefile || -f $PKG_Dir/$PKG_NAME/README.md || -n $(ls -A $PKG_Dir/$PKG_NAME) ]];then
		MSG_SUCC "[SVN] 已添加 $PKG_NAME"
	else
		MSG_ERR "[SVN] 未添加 $PKG_NAME"
	fi
	sleep 2
}

ExtraPackages_src-git() {
	if [[ ! $(cat $Home/Projects/$Project/feeds.conf.default) =~ "src-git $SRC_NAME" ]];then
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
	[[ ! -d $PKG_Home/ExtraPackages ]] && mkdir -p $PKG_Home/ExtraPackages
	PKG_Dir=$PKG_Home/ExtraPackages
}
