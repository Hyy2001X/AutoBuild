# AutoBuild
更方便地编译自己的Openwrt

一、AutoBuild使用方法如下: 

		1.打开终端更新软件包，输入sudo apt update
		2.安装git[如果已经安装请忽略这一步]，输入sudo apt install git
		5.克隆此项目到主目录,依次输入以下内容:
		cd ~
		git clone https://github.com/Hyy2001X/AutoMAKE.git Openwrt
		6.进入Openwrt文件夹
		cd ~/Openwrt
		7.为脚本设置权限,依次输入以下内容:
		chmod 777 AutoBuild.sh
		chmod +x AutoBuild.sh
		8.启动脚本
		~/Openwrt/AutoBuild.sh
	注：如需更新脚本，输入git pull即可


注：	

	1.Lede即为使用Lean大的源码，项目地址：https://github.com/coolsnowwolf/lede/
	2.Openwrt即为使用Openwrt官方源码，项目地址：https://github.com/openwrt/openwrt
	3.Lienol即为使用Lienol源码，项目地址：https://github.com/Lienol/openwrt
