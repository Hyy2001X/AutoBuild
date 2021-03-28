# AutoBuild/更方便地编译Openwrt

测试通过的操作系统: `Ubuntu 20.04、Ubuntu 19.10、Ubuntu 18.04、Deepin 20`

## 使用方法/Usage: 

1.打开终端[Ctrl+Alt+A],更新系统软件包列表
	`sudo apt-get update`

2.安装 AutoBuild 的必要依赖
	`sudo apt-get -y install git httping ntpdate subversion ssh lm-sensors expect`

3.克隆 `AutoBuild 项目`到电脑
	`git clone https://github.com/Hyy2001X/AutoBuild.git AutoBuild`

4.进入 AutoBuild 目录
	`cd ./AutoBuild`

5.为脚本设置可运行权限
	`chmod +x AutoBuild.sh`

6.运行脚本
	`./AutoBuild.sh`

步骤 `4 - 6` 快捷脚本
	`cd ./AutoBuild && chmod +x AutoBuild.sh && ./AutoBuild.sh`
	
AutoBuild 支持使用自定义源码地址以及分支,修改 `Additional/GitLink_*` 即可实现自定义.
