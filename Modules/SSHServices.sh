# AutoBuild Script Module by Hyy2001

SSHServices() {
Update=2020.09.16
Module_Version=V1.3.1

while :
do
	clear
	Say="Easy SSH Services Script $Module_Version" && Color_B
	List_SSHProfile
	Say="\nn.创建新配置文件" && Color_G
	if [ ! "`ls -A $Home/Configs/SSH`" = "" ];then
		Say="d.删除所有配置文件" && Color_R
	fi
	echo -e "q.返回\n"
	read -p '请从上方选择一个操作:' Choose
	case $Choose in
	q)
		break
	;;
	n)
		Edit_Mode=0
		Create_SSHProfile
	;;
	d)
		rm -f $Home/Configs/SSH/*  > /dev/null 2>&1
		Say="\n已删除所有配置文件!" && Color_Y
		sleep 2
	;;
	*)
		if [ $Choose -gt 0 ] > /dev/null 2>&1 ;then
			if [ $Choose -le $SSHProfileList_MaxLine ] > /dev/null 2>&1 ;then
				SSHProfile_File=`sed -n ${Choose}p $SSHProfileList`
				SSHServices_Menu
			else
				Say="\n输入错误,请输入正确的数字!" && Color_R
				sleep 2
			fi
		fi
	;;
	esac
done
}

SSHServices_Menu() {
while :
do
	SSH_IP=`awk -F'[="]+' '/IP/{print $2}' "$Home/Configs/SSH/$SSHProfile_File"`
	SSH_Port=`awk -F'[="]+' '/Port/{print $2}' "$Home/Configs/SSH/$SSHProfile_File"`
	SSH_User=`awk -F'[="]+' '/Username/{print $2}' "$Home/Configs/SSH/$SSHProfile_File"`
	SSH_Password=`awk -F'[="]+' '/Password/{print $2}' "$Home/Configs/SSH/$SSHProfile_File"`
	clear
	echo -e "$Blue配置文件:$Yellow[$SSHProfile_File]$White"
	echo -e "$Blue连接参数:$Yellow[ssh $SSH_User@$SSH_IP -p $SSH_Port]$White\n"
	Say="1.连接SSH" && Color_Y
	echo "2.编辑"
	echo "3.重命名"
	Say="4.删除配置文件" && Color_R
	echo "5.重置[RSA Key Fingerprint]"
	echo -e "\nq.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		SSH_Login
	;;
	2)
		Edit_Mode=1
		SSH_Profile="$SSHProfile_File"
		Create_SSHProfile
	;;
	3)
		echo " "
		read -p '请输入新的配置名称:' SSHProfile_RN
		if [ ! "$SSHProfile_RN" == "" ];then
			cd $Home/Configs/SSH
			mv "$SSHProfile_File" "$SSHProfile_RN" > /dev/null 2>&1
			Say="\n重命名 [$SSHProfile_File] > [$SSHProfile_RN] 成功!" && Color_Y
			SSHProfile_File="$SSHProfile_RN"
		else
			Say="\n配置名称不能为空!" && Color_R
		fi
		sleep 2
	;;
	4)
		rm -f $Home/Configs/SSH/"$SSHProfile_File"
		Say="\n配置[$SSHProfile_File]删除成功!" && Color_Y
		sleep 2
		break
	;;
	5)
		
		ssh-keygen -R $SSH_IP > /dev/null 2>&1
		Say="\n[RSA Key Fingerprint]重置成功!" && Color_Y
		sleep 2
	;;
	esac
done
}

Create_SSHProfile() {
cd $Home
echo " "
if [ $Edit_Mode == 0 ];then
	read -p '请输入新的配置名称:' SSH_Profile
	while [ "$SSH_Profile" == "" ]
	do
		Say="\n配置名称不能为空!\n" && Color_R
		read -p '请输入新配置名称:' SSH_Profile
	done
fi
read -p '请输入IP地址:' SSH_IP
while [ "$SSH_IP" == "" ]
do
	Say="\nIP地址不能为空!\n" && Color_R
	read -p '请输入IP地址:' SSH_IP
done
read -p '请输入端口号:' SSH_Port
if [ "$SSH_Port" == "" ];then
	SSH_Port=22
fi
read -p '请输入用户名:' SSH_User
while [ "$SSH_User" == "" ]
do
	Say="\n用户名不能为空!\n" && Color_R
	read -p '请输入用户名:' SSH_User
done
read -p '请输入密码:' SSH_Password
echo "IP=$SSH_IP" > $Home/Configs/SSH/"$SSH_Profile"
echo "Port=$SSH_Port" >> $Home/Configs/SSH/"$SSH_Profile"
echo "Username=$SSH_User" >> $Home/Configs/SSH/"$SSH_Profile"
echo "Password=$SSH_Password" >> $Home/Configs/SSH/"$SSH_Profile"
Say="\n配置文件已保存到'Configs/SSH/$SSH_Profile'" && Color_Y
sleep 2
if [ $Edit_Mode == 0 ];then
	SSH_Login
fi
}

List_SSHProfile() {
if [ ! "`ls -A $Home/Configs/SSH`" = "" ];then
	cd $Home/Configs/SSH
	ls -A | cat > $Home/TEMP/SSHProfileList
	SSHProfileList=$Home/TEMP/SSHProfileList
	SSHProfileList_MaxLine=`sed -n '$=' $SSHProfileList`
	Say="\n配置文件列表\n" && Color_B
	for ((i=1;i<=$SSHProfileList_MaxLine;i++));
	do   
		SSHProfile=`sed -n ${i}p $SSHProfileList`
		echo -e "${i}.$Yellow${SSHProfile}$White"
	done
fi
}

SSH_Login() {
clear
expect -c "
	set timeout 1
	spawn ssh $SSH_User@$SSH_IP -p $SSH_Port
	expect {
		*yes/no* { send \"yes\r\"; exp_continue }
		*password:* { send \"$SSH_Password\r\" }  
	}
	interact
"
Enter
}
