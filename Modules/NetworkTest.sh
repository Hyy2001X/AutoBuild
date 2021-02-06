# AutoBuild Script Module by Hyy2001

Network_Test() {
Update=2021.02.07
Module_Version=V3.0.1

	clear
	TMP_FILE=$Home/TEMP/NetworkTest_Core.log
	MSG_TITLE "Network Test Script $Module_Version"
	MSG_COM G "网址			次数	延迟/Min	延迟/Avg	延迟/Max	状态\n"
	
	PING_MODE=httping
	# PING_MODE=ping

	TestCore www.baidu.com 2
	TestCore git.openwrt.com 3
	TestCore www.google.com 3
	TestCore www.github.com 3

	Enter
}

TestCore() {
	_URL=$1
	_COUNT=$2
	_TIMEOUT=$((${_COUNT}*2+1))
	[[ -z $1 ]] || [[ -z $2 ]] && return
	[ ! ${_COUNT} -gt 0 ] 2>/dev/null && return
	timeout 3 ${PING_MODE} ${_URL} -c 1 > /dev/null 2>&1
	if [ $? -eq 0 ];then
		echo -ne "\r${Skyb}测试中...${White}\r"
		timeout ${_TIMEOUT} ${PING_MODE} ${_URL} -c ${_COUNT} > ${TMP_FILE}
		_IP=$(egrep -o "[0-9]+.[0-9]+.[0-9]+.[0-9]" ${TMP_FILE} | awk 'NR==1')
		_PING=$(egrep -o "[0-9].+/[0-9]+.[0-9]+" ${TMP_FILE})
		_PING_MIN=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==1')
		_PING_AVG=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==2')
		_PING_MAX=$(echo ${_PING} | egrep -o "[0-9]+.[0-9]+" | awk 'NR==3')
		_PING_PROC=$(echo ${_PING_AVG} | egrep -o "[0-9]+" | awk 'NR==1')
		if [[ ${_PING_PROC} -le 50 ]];then
			_TYPE="${Yellow}优秀"
		elif [[ ${_PING_PROC} -le 100 ]];then
			_TYPE="${Blue}良好"
		elif [[ ${_PING_PROC} -le 200 ]];then
			_TYPE="${Skyb}一般"
		elif [[ ${_PING_PROC} -le 250 ]];then
			_TYPE="${Red}较差"
		else
			_TYPE="${Red}很差"
		fi
		echo -e "${_URL}		${_COUNT}	${_PING_MIN}		${_PING_AVG}		${_PING_MAX}		${_TYPE}${White}"
	else
		echo -e "${_URL}		${Red}错误${White}"	
	fi
}
