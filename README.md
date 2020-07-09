# AutoBuild/更方便地编译Openwrt

使用方法: 
-
1.打开终端，更新系统软件包
	`sudo apt-get update`

2.安装 AutoBuild 依赖
	`sudo apt install git httping ntpdate subversion openssh-client lm-sensors`

3.克隆此项目到任意目录
	`git clone https://github.com/Hyy2001X/AutoBuild.git AutoBuild`

4.进入 AutoBuild 目录
	`cd ./AutoBuild`

5.为脚本设置可运行权限
	`chmod +x AutoBuild.sh`

6.启动脚本
	`./AutoBuild.sh`

AutoBuild 支持的操作系统`Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04、Deepin 20 Beta`
