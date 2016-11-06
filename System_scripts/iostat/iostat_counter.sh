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
r_kb=0
w_kb=0

time_await=0
service_time=0
avgrq_sz=0
util=0

if [[ -f $2 ]]; then
	rm -rf $2
fi

#删除以Linux开头的行，删除以Device开头的行，删除空行，将多个空格替换为#
#格式：Device: rrqm/s wrqm/s r/s w/s rKB/s wkB/s avgrq-sz avgqu-sz await r_await w_await svctm %util
for item in $(cat $1 | sed '/^Linux/d' | sed '/^Device/d' | sed '/^$/d' | sed 's/  */#/g')
do
	let counter++
	tmp_rkb=$(echo "$item" | cut -d "#" -f6)
	tmp_wkb=$(echo "$item" | cut -d "#" -f7)
	tmp_await=$(echo "$item" | cut -d "#" -f10)
	tmp_service_time=$(echo "$item" | cut -d "#" -f13)
	tmp_util=$(echo "$item" | cut -d "#" -f14)
	tmp_avgrq_sz=$(echo "$item" | cut -d "#" -f7)
	r_kb=`echo $tmp_rkb+$r_kb | bc`
	w_kb=`echo $tmp_wkb+$w_kb | bc`
	service_time=`echo $tmp_service_time+$service_time | bc`
	time_await=`echo $tmp_await+$time_await | bc`
	avgrq_sz=`echo $tmp_avgrq_sz+$avgrq_sz | bc`
	util=`echo $tmp_util+$util | bc`

done
##rKB/s
ave_rkb=`echo "scale=3;$r_kb/$counter" | bc`
##rKB/s
ave_wkb=`echo "scale=3;$w_kb/$counter" | bc`
##wating_time
ave_await_time=`echo "scale=3;$time_await/$counter" | bc`
ave_service_time=`echo "scale=3;$service_time/$counter" | bc`
waiting_time=`echo "scale=3;$ave_await_time-$ave_service_time" | bc`
##Disk utilization
ave_util=`echo "scale=3;$util/$counter" | bc`
ave_avgrq=`echo "scale=3;$avgrq_sz/$counter" | bc`


printf "################result of iostat log analyzing################\n" >> $output_log
printf "ave_rkb  ave_wkb  time_await  service_time  waiting_time  ave_avgrq  util\n" >> $output_log
printf "$ave_rkb\t$ave_wkb\t$time_await\t$service_time\t$waiting_time\t$ave_avgrq\t$util\n" >> $output_log




