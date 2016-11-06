#!/bin/bash
usage(){
	echo "Usage of this scripts: ./iostat_counter.sh <iostat_log> <output_log>"
}

if [ $# -lt 2 ] || [ $1 == "-help" ] ; then
	usage
	exit
fi

output_log=$2
counter=0
r_s=0
r_w=0

time_await=0
service_time=0
avgrq_sz=0
util=0

#删除以Linux开头的行，删除以Device开头的行，删除空行，将多个空格替换为#
#格式：Device: rrqm/s wrqm/s r/s w/s rsec/s wsec/s avgrq-sz avgqu-sz await r_await w_await svctm %util
for item in $(cat $1 | sed '/^Linux/d' | sed '/^Device/d' | sed '/^$/d' | sed 's/  */#/g')
do
	let counter++
	tmp_rs=$(echo "$item" | cut -d "#" -f4)
	tmp_rw=$(echo "$item" | cut -d "#" -f5)
	tmp_await=$(echo "$item" | cut -d "#" -f10)
	tmp_service_time=$(echo "$item" | cut -d "#" -f13)
	tmp_util=$(echo "$item" | cut -d "#" -f14)
	tmp_avgrq_sz=$(echo "$item" | cut -d "#" -f7)
	r_s=`echo $tmp_rs+$r_s | bc`
	r_w=`echo $tmp_rw+$r_w | bc`
	service_time=`echo $tmp_service_time+$service_time | bc`
	time_await=`echo $tmp_await+$time_await | bc`
	avgrq_sz=`echo $tmp_avgrq_sz+$avgrq_sz | bc`
	util=`echo $tmp_util+$util | bc`

done
ave_rs=`echo "scale=3;$r_s/$counter" | bc`
ave_rw=`echo "scale=3;$r_w/$counter" | bc`
ave_await_time=`echo "scale=3;$time_await/$counter" | bc`
ave_service_time=`echo "scale=3;$service_time/$counter" | bc`
ave_util=`echo "scale=3;$util/$counter" | bc`
ave_avgrq=`echo "scale=3;$avgrq_sz/$counter" | bc`
waiting_time=`echo "scale=3;$ave_await_time-$ave_service_time" | bc`

printf "################result of iostat log analyzing################\n" >> $output_log
printf "r_s  r_w  time_await  service_time  waiting_time  ave_avgrq  util\n" >> $output_log
printf "$ave_rs\t$ave_rw\t$time_await\t$service_time\t$waiting_time\t$ave_avgrq\t$util\n" >> $output_log




