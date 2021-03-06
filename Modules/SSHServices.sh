# AutoBuild Script Module by Hyy2001

SSHServices() {
Update=2020.12.03
Module_Version=V1.3.7

while :
do
	clear
	MSG_TITLE "SSH Services Script $Module_Version"
	List_SSHProfile
	MSG_COM G "\nn.创建新配置文件"
	[ ! "`ls -A $Home/Configs/SSH`" = "" ] && MSG_COM R "d.删除所有配置文件"
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
		MSG_SUCC "已删除所有 [SSH] 配置文件!"
		sleep 2
	;;
	*)
		if [ $Choose -gt 0 ] > /dev/null 2>&1 ;then
			if [ $Choose -le $SSHProfileList_MaxLine ] > /dev/null 2>&1 ;then
				SSHProfile_File=$(sed -n ${Choose}p $SSHProfileList)
				SSHServices_Menu
			else
				MSG_ERR "[SSH] 输入错误,请输入正确的数字!"
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
	. "$Home/Configs/SSH/$SSHProfile_File"
	clear
	echo -e "${Blue}配置文件:${Yellow}[$SSHProfile_File]${White}"
	echo -e "${Blue}连接参数:${Yellow}[ssh $SSH_User@$SSH_IP -p $SSH_Port]${White}\n"
	MSG_COM "1.连接SSH"
	echo "2.编辑"
	echo "3.重命名"
	MSG_COM R "4.删除配置文件[$SSHProfile_File]"
	echo "5.重置[RSA Key Fingerprint]"
	echo -e "\nq.返回"
	GET_Choose
	case $Choose in
	q)
		break
	;;
	1)
		ssh-keygen -R $SSH_IP > /dev/null 2>&1
		SSH_Login
	;;
	2)
		Edit_Mode=1
		SSH_Profile="$SSHProfile_File"
		Create_SSHProfile
	;;
	3)
		echo " "
		read -p '[SSH] 请输入新的配置名称:' SSHProfile_RN
		if [ ! -z "$SSHProfile_RN" ];then
			cd $Home/Configs/SSH
			mv "$SSHProfile_File" "$SSHProfile_RN" > /dev/null 2>&1
			MSG_SUCC "重命名 [$SSHProfile_File] > [$SSHProfile_RN] 成功!"
			SSHProfile_File="$SSHProfile_RN"
		else
			MSG_ERR "[SSH] 配置名称不能为空!"
		fi
		sleep 2
	;;
	4)
		rm -f $Home/Configs/SSH/"$SSHProfile_File"
		MSG_SUCC "[SSH] 配置文件[$SSHProfile_File]删除成功!"
		sleep 2
		break
	;;
	5)
		
		ssh-keygen -R $SSH_IP > /dev/null 2>&1
		MSG_SUCC "[SSH] [RSA Key Fingerprint]重置成功!"
		sleep 2
	;;
	esac
done
}

Create_SSHProfile() {
cd $Home
echo " "
if [ $Edit_Mode == 0 ];then
	read -p '[SSH] 请输入新的配置名称:' SSH_Profile
	while [ -z "$SSH_Profile" ]
	do
		MSG_ERR "[SSH] 配置名称不能为空!"
		echo ""
		read -p '请输入新配置名称:' SSH_Profile
	done
fi
read -p '[SSH] 请输入IP地址:' SSH_IP
[ -z "$SSH_IP" ] && SSH_IP="192.168.1.1"
read -p '[SSH] 请输入端口号:' SSH_Port
[ -z "$SSH_Port" ] && SSH_Port=22
read -p '[SSH] 请输入用户名:' SSH_User
while [ -z "$SSH_User" ]
do
	MSG_ERR "[SSH] 用户名不能为空!"
	echo ""
	read -p '[SSH] 请输入用户名:' SSH_User
done
read -p '[SSH] 请输入密码:' SSH_Password
echo "SSH_IP=$SSH_IP" > $Home/Configs/SSH/"$SSH_Profile"
echo "SSH_Port=$SSH_Port" >> $Home/Configs/SSH/"$SSH_Profile"
echo "SSH_User=$SSH_User" >> $Home/Configs/SSH/"$SSH_Profile"
echo "SSH_Password=$SSH_Password" >> $Home/Configs/SSH/"$SSH_Profile"
MSG_SUCC "[SSH] 配置文件已保存到'Configs/SSH/$SSH_Profile'"
sleep 2
[ $Edit_Mode == 0 ] && SSH_Login
}

List_SSHProfile() {
if [ ! -z "`ls -A $Home/Configs/SSH`" ];then
	cd $Home/Configs/SSH
	ls -A | cat > $Home/TEMP/SSHProfileList
	SSHProfileList=$Home/TEMP/SSHProfileList
	SSHProfileList_MaxLine=$(sed -n '$=' $SSHProfileList)
	MSG_COM G "配置文件列表"
	echo ""
	for ((i=1;i<=$SSHProfileList_MaxLine;i++));
	do   
		SSHProfile=$(sed -n ${i}p $SSHProfileList)
		echo -e "${i}.${Yellow}${SSHProfile}${White}"
	done
else
	MSG_COM R "[未检测到配置文件]"
fi
}

SSH_Login() {
clear
echo -e "${Blue}连接参数:${Yellow}[ssh $SSH_User@$SSH_IP -p $SSH_Port]${White}\n"
expect -c "
	set timeout 1
	spawn ssh $SSH_User@$SSH_IP -p $SSH_Port
	expect {
		*yes/no* { send \"yes\r\"; exp_continue }
		*password:* { send \"$SSH_Password\r\" }  
	}
	interact
"
}
