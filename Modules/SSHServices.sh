# AutoBuild Script Module by Hyy2001

SSHServices() {
Update=2020.08.27
Module_Version=V1.0-BETA
while :
do
	clear
	Say="SSH Services Script $Module_Version" && Color_B
	List_SSHProfile
	Say="\nn.创建配置文件" && Color_Y
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
		Mode=0
		C_SSH_Profile
	;;
	d)
		rm -f $Home/Configs/SSH/*  > /dev/null 2>&1
		Say="\n[All Profiles]删除成功!" && Color_Y
		sleep 2
	;;
	*)
		if [ $Choose -le $Max_ProfileList_Line ];then
			SSHProfile_File=`sed -n ${Choose}p $SSHProfileList_File`
			if [ -f $Home/Configs/SSH/$SSHProfile_File ];then
				SSHServices_Menu
			else
				Say="未检测到对应的配置文件!" && Color_R
				sleep 2
			fi
		else
			Say="\n输入错误,请输入正确的数字!" && Color_R
			sleep 2
		fi
	;;
	esac
done
}

SSHServices_Menu() {
while :
do
	SSH_IP=`awk -F'[="]+' '/IP/{print $2}' $Home/Configs/SSH/$SSHProfile_File`
	SSH_Port=`awk -F'[="]+' '/Port/{print $2}' $Home/Configs/SSH/$SSHProfile_File`
	SSH_User=`awk -F'[="]+' '/Username/{print $2}' $Home/Configs/SSH/$SSHProfile_File`
	SSH_Password=`awk -F'[="]+' '/Password/{print $2}' $Home/Configs/SSH/$SSHProfile_File`
	clear
	echo -e "$Blue配置文件:$Yellow[$SSHProfile_File]$White"
	echo -e "$Blue连接参数:$Yellow[ssh $SSH_User@$SSH_IP -p $SSH_Port]$White\n"
	Say="1.直接连接" && Color_Y
	echo "2.编辑"
	echo "3.重命名配置"
	echo "4.删除配置"
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
		Mode=1
		SSH_Profile="$SSHProfile_File"
		C_SSH_Profile
	;;
	3)
		echo " "
		read -p '请输入新的配置名称:' SSHProfile_NN
		cd $Home/Configs/SSH
		mv "$SSHProfile_File" "$SSHProfile_NN" > /dev/null 2>&1
		Say="\n重命名 [$SSHProfile_File] > [$SSHProfile_NN]" && Color_Y
		SSHProfile_File="$SSHProfile_NN"
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

C_SSH_Profile() {
cd $Home
echo " "
if [ $Mode == 0 ];then
	read -p '请输入配置名称:' SSH_Profile
fi
read -p '请输入IP地址:' SSH_IP
read -p '请输入端口号[默认为22]:' SSH_Port
read -p '请输入用户名:' SSH_User
read -p '请输入密码:' SSH_Password
echo "IP=$SSH_IP" > ./Configs/SSH/"$SSH_Profile"
echo "Port=$SSH_Port" >> ./Configs/SSH/"$SSH_Profile"
echo "Username=$SSH_User" >> ./Configs/SSH/"$SSH_Profile"
echo "Password=$SSH_Password" >> ./Configs/SSH/"$SSH_Profile"
Say="\n配置文件已保存到'$Home/Configs/SSH/$SSH_Profile'" && Color_Y
sleep 2
}

List_SSHProfile() {
if [ ! "`ls -A $Home/Configs/SSH`" = "" ];then
	cd $Home/Configs/SSH
	ls -A | cat > $Home/TEMP/SSH_Profile.List
	SSHProfileList_File=$Home/TEMP/SSH_Profile.List
	Max_ProfileList_Line=`sed -n '$=' $SSHProfileList_File`
	Say="\n配置文件列表\n" && Color_B
	for ((i=1;i<=$Max_ProfileList_Line;i++));
		do   
			SSHProfile=`sed -n ${i}p $SSHProfileList_File`
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
