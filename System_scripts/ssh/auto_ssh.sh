#!/bin/bash
#introduce the usage of this tools
export CUR_NAME=`whoami`
usage() {
	echo "usage: ./auto_ssh.sh <password config> <CUR_NAME>"
}

#the config file is not found
passwd_file_not_found() { 
	echo "the passwd file is not found,please check!"
}

check_expect() {
	type expect >/dev/null 2>&1 || { echo -e >&2 "Expect is not install\nInstall method:\nfor centos: yum -y install expect\nfor ubuntu: apt-get install expect" && exit 1; }
}





# #Check if the count of params is leagle
if [ $# -lt 1 ] || [ "$1" = "-help" ]
then
	usage
	exit
fi

##check if the expect has been installed
check_expect


ip_list_file=$1
#check if the passwd config file is leagle
if [ ! -f "$ip_list_file" ]
then
	passwd_file_not_found
	exit
fi


#env values
if [ $CUR_NAME = "root" ]
then
	export FILELOC="/root"
	export KNOWNHOSTSFILE="$FILELOC/.ssh/known_hosts"
else
	export FILELOC="/home/$CUR_NAME"
	export KNOWNHOSTSFILE="/home/$CUR_NAME/.ssh/known_hosts"
fi 
export SIGN="@"
export SSHLOC="$FILELOC/.ssh"
export RSAFILE="$SSHLOC/id_rsa"
export RSAPUBFILE="$SSHLOC/id_rsa.pub"
export AUTHFILE="$SSHLOC/authorized_keys"

#get the master ip, and the master_ip is configurable

if [[ $# -eq 2 ]]; then
	master_ip=$2
else
	master_ip=`ifconfig | grep "inet addr" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}'`

	if [ -z $master_ip ] 
	then
		master_ip=`ifconfig | grep "inet 地址" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}'`
	fi
fi

#ensure the yes/no question
if [ -f "$KNOWNHOSTSFILE" ]  
then
	echo "before excute this script you'd better use the following command to delete the known_hosts file"
	echo "rm -rf $KNOWNHOSTSFILE"
	exit
fi

#generate ssh keys on all nodes in config file
for config_line in $(sed 's/ //g' $ip_list_file)
do 
	#ignore the '#'
	if [ ${config_line:0:1} == "#" ] 
	then
		continue;
	fi
	ip=`echo "$config_line" | cut -f1 -d "="`
	passwd=`echo "$config_line" | cut -f2 -d "="`
	if [ $ip = $master_ip ]
	then
		echo "###############################################"
		echo "Generating RSA keys for master host $master_ip"
		echo "###############################################"
		expect -c "
			set timeout 3600
			spawn ssh $CUR_NAME@$ip
			expect \"yes/no\"
			send -- \"yes\r\"
			expect \"password:\"
			send -- \"$passwd\r\"
			expect \"$SIGN\"
			send -- \"ssh-keygen -t rsa -P '' -f $RSAFILE\r\"
			expect \"$SIGN\"
			send -- \"rm -rf $SSHLOC/known_hosts\r\"
			expect \"$SIGN\"
			send -- \"ssh-copy-id -i $RSAPUBFILE $master_ip\r\"
			expect \"yes/no\"
			send -- \"yes\r\"
			expect \"password:\"
			send -- \"$passwd\r\"
			expect \"$SIGN\"
			send -- \"exit\r\"
			expect eof
		"
	else
		echo ''
		echo "###############################################"
		echo "Generating RSA keys for other host $ip"
		echo "###############################################"
		expect -c "
			set timeout 3600
			spawn ssh $CUR_NAME@$ip
			expect \"yes/no\"
			send -- \"yes\r\"
			expect \"password:\"
			send -- \"$passwd\r\"
			expect \"$SIGN\"
			send -- \"ssh-keygen -t rsa -P '' -f $RSAFILE\r\"
			expect \"$SIGN\"
			send -- \"rm -rf $SSHLOC/known_hosts\r\"
			expect \"$SIGN\"
			send -- \"ssh-copy-id -i $RSAPUBFILE $master_ip\r\"
			expect \"yes/no\"
			send -- \"yes\r\"
			expect \"password:\"
			send -- \"$passwd\r\"
			expect \"$SIGN\"
			send -- \"exit\r\"
			expect eof

		"
	fi
done
for config_line in $(sed 's/ //g' $ip_list_file)
do 
	#ignore the '#'
	if [ ${config_line:0:1} == "#" ] 
	then
		continue;
	fi
	ip=`echo "$config_line" | cut -f1 -d "="`
	passwd=`echo "$config_line" | cut -f2 -d "="`
	if [ $ip = $master_ip ]
	then
		continue
	else
		echo ''
    		echo "############################################################################"
    		echo "Copying authorized_keys to host $ip from the MASTER host $master_ip..."
    		echo "############################################################################"
    		echo ''
    		expect -c "
    			set timeout 3600
    			spawn scp $AUTHFILE $CUR_NAME@$ip:$SSHLOC
    			expect \"password:\"
        		send -- \"$passwd\r\"
        		expect eof
    		"
	fi
	echo "all finish"
done