#!/bin/bash

function usage() {
   echo "Usage: $0 <opType>(start,stop,init)"
}

function miss_env_file() {
    echo "missing the zoo_env.sh, you should rename the templet file to the zoo_env.sh"
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



op_type=$1

if [[ ${op_type} = "start" ]]; then
    for line in `cat ${ZK_SCRIPT_DIR}/serverlist`; do
         if [[ "${line:0:1}" = "#" ]]; then
            continue;
        fi
        hostname=`echo ${line} | cut -d ':' -f 1`
        echo "on ${hostname} starting zk server..."
        ssh ${hostname} "${ZOO_HOME}/bin/zkServer.sh start"
        echo "succ"
    done
elif [[ ${op_type} = "stop" ]]; then
    for line in `cat ${ZK_SCRIPT_DIR}/serverlist`; do
         if [[ "${line:0:1}" = "#" ]]; then
            continue;
        fi
        hostname=`echo ${line} | cut -d ':' -f 1`
        echo "on ${hostname} stopping zk server..."
        ssh ${hostname} "${ZOO_HOME}/bin/zkServer.sh stop"
        echo "succ"
    done
elif [[ ${op_type} = "init" ]]; then
    for line in `cat ${ZK_SCRIPT_DIR}/serverlist`; do
         if [[ "${line:0:1}" = "#" ]]; then
            continue;
        fi
        hostname=`echo ${line} | cut -d ':' -f 1`
        myid=`echo ${line} | cut -d ':' -f 2`
        echo "on ${hostname} initializing zk server..."
        ssh ${hostname} "echo ${myid} > ${ZOO_HOME}/data/myid"
        echo "succ"
    done
fi