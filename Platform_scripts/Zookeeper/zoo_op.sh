#!/bin/bash

function usage() {
   echo "Usage: $0 <opType>(start,stop,init)"
}

function miss_env_file() {
    echo "missing the zoo_env.sh, you should rename the templet file to the zoo_env.sh"
}

function miss_zoo_home(){
    echo "ZOO_HOME is not set, please set ZOO_HOME in the zoo_env.sh"
}

function miss_zoo_cfg(){
    echo "missing zoo_cfg please create the zoo.cfg"
}

function miss_data_dir_cfg() {
    echo "parameter dataDir is not set, please check your zoo.cfg!!"
}

if [[ $# -lt 1 ]]; then
    usage
    exit
fi

##get the current path and initialize some constant values
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`

ZK_SCRIPT_DIR=${DIR}/Zookeeper

if [[ ! -f  ${ZK_SCRIPT_DIR}/zoo_env.sh ]]; then
    miss_env_file
    exit
fi

. ${ZK_SCRIPT_DIR}/zoo_env.sh

if [[ -z ${ZOO_HOME} ]]; then
    miss_zoo_home
    exit
fi




op_type=$1

for line in `cat ${ZK_SCRIPT_DIR}/serverlist`; do
    if [[ "${line:0:1}" = "#" ]]; then
        continue;
    fi
    hostname=`echo ${line} | cut -d ':' -f 1`
    if [[ ${op_type} = "start" ]]; then
        echo "on ${hostname} starting zk server..."
        ssh ${hostname} "${ZOO_HOME}/bin/zkServer.sh start"
        echo "succ"
    elif [[ ${op_type} = "stop" ]]; then
        echo "on ${hostname} stopping zk server..."
        ssh ${hostname} "${ZOO_HOME}/bin/zkServer.sh stop"
        echo "succ"
    elif [[ ${op_type} = "init" ]]; then
        if [[ ! -f ${ZOO_HOME}/conf/zoo.cfg ]]; then
            miss_zoo_cfg
            exit
        fi
        data_dir=`grep "dataDir=" ${ZOO_HOME}/conf/zoo.cfg | cut -d '=' -f 2`
        if [[ -z ${data_dir} ]]; then
            miss_data_dir_cfg
            exit
        fi
        echo "on ${hostname} initializing zk server..."
        mkdir -p ${data_dir}
        myid=`echo ${line} | cut -d ':' -f 2`
        ssh ${hostname} "echo ${myid} > ${data_dir}/myid"
        echo "succ"
    fi
done


