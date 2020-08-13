# AutoBuild/更方便地编译Openwrt

使用方法/Usage: 
-
1.首先装好 AutoBuild 支持的操作系统`Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04、Deepin 20`

2.打开终端，更新系统软件包
	`sudo apt-get update`

3.安装 AutoBuild 必要依赖
	`sudo apt-get -y install git httping ntpdate subversion openssh-client lm-sensors expect`

4.克隆此项目到任意目录
	`git clone https://github.com/Hyy2001X/AutoBuild.git AutoBuild`

5.进入 AutoBuild 目录
	`cd ./AutoBuild`

6.为脚本设置可运行权限
	`chmod +x AutoBuild.sh`

7.启动脚本
	`./AutoBuild.sh`


快捷脚本
	`cd ./AutoBuild && chmod +x AutoBuild.sh && ./AutoBuild.sh`
	
AutoBuild 支持使用自定义源码地址以及分支,修改位于 Additional/GitLink_* 的文件即可实现自定义.

AutoBuild 支持自定义Command指令启动,首先启动AutoBuild,选择[3.高级选项/6.创建快捷启动],输入你想要的指令即可.
