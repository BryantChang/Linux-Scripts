#!/bin/bash

function usage() {
    echo -e "usage:$0 -op startall/stopall/restartall/startdfs/stopdfs/restartdfs/startyarn/stopyarn/restartyarn\n-h for help"
}

function miss_hadoop_env(){
    echo "missing the hadoop_env.sh, you should rename the templet file to the hadoop_env.sh"
}
function empty_hadoop_home() {
    echo "The HADOOP_HOME is not configured, please check and configure it"
    echo "You can configure it by modify the hadoop_env.sh or set the system environment variable"
}


THIS=`dirname "$0"`
THIS=`cd "${THIS}"; pwd`
THIS=`readlink -f ${THIS}`
rootdir=`cd "${THIS}"; pwd`
CONFDIR=${rootdir}/conf
if [[ $# -lt 1 ]]; then
    usage
    exit
fi


if [[ ! -f  ${CONFDIR}/hadoop_env.sh ]]; then
    miss_env_file
    exit
fi
. ${CONFDIR}/hadoop_env.sh

OPTION=$1

if [[ "${OPTION}" == "-h" || "${OPTION}" == "--help" || "${OPTION}" == "-help" ]]; then
    usage
    exit
fi

if [[ "${OPTION}" != "" && "${OPTION}" != "-op" ]]; then
    usage
    exit
fi

if [[ -z ${SPARK_HOME} ]]; then
    empty_hadoop_home
    exit
fi

if [[ "${OPTION}" == "-op" ]]; then
    case $2 in
        "startall" )
            sh ${HADOOP_HOME}/sbin/start-all.sh
        ;;
        "stopall" )
            sh ${HADOOP_HOME}/sbin/stop-all.sh
        ;;
        "restartall" )
            sh ${HADOOP_HOME}/sbin/stop-all.sh
            sh ${HADOOP_HOME}/sbin/start-all.sh
        ;;
        "startdfs" )
            sh ${HADOOP_HOME}/sbin/start-dfs.sh
        ;;
        "stopdfs" )
            sh ${HADOOP_HOME}/sbin/stop-dfs.sh
        ;;
        "restartdfs" )
            sh ${HADOOP_HOME}/sbin/stop-dfs.sh
            sh ${HADOOP_HOME}/sbin/start-dfs.sh
        ;;
        "startyarn" )
            sh ${HADOOP_HOME}/sbin/start-yarn.sh
        ;;
        "stopyarn" )
            sh ${HADOOP_HOME}/sbin/stop-yarn.sh
        ;;
        "restartyarn" )
            sh ${HADOOP_HOME}/sbin/stop-yarn.sh
            sh ${HADOOP_HOME}/sbin/start-yarn.sh
        ;;
        * )
            usage
            exit
        ;;
    esac
    shift
    shift
fi