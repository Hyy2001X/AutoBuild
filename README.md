# AutoBuild/更方便地编译Openwrt

AutoBuild使用方法: 
-
		1.打开终端，更新系统软件包
			sudo apt update
		2.安装AutoBuild依赖
			sudo apt install git httping ntpdate subversion
		3.克隆此项目到任意目录
			`git clone https://github.com/Hyy2001X/AutoBuild.git
		4.进入AutoBuild目录
			cd ./AutoBuild
		5.为脚本设置运行权限
			chmod +x AutoBuild.sh
		6.启动脚本
			./AutoBuild.sh
