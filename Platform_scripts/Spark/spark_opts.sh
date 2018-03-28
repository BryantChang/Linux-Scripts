#!/bin/bash

function usage() {
    echo -e "usage:$0 -op start/stop/restart\n-h for help"
}

function miss_spark_env(){
    echo "missing the spark_env.sh, you should rename the templet file to the spark_env.sh"
}
function empty_spark_home() {
    echo "The SPARK_HOME is not configured, please check and configure it"
    echo "You can configure it by modify the spark_env.sh or set the system environment variable"
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

if [[ ! -f  ${CONFDIR}/spark_env.sh ]]; then
    miss_env_file
    exit
fi
. ${CONFDIR}/spark_env.sh

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
    empty_spark_home
    exit
fi

if [[ "${OPTION}" == "-op" ]]; then
    case $2 in
        "start" )
            sh ${SPARK_HOME}/sbin/start-all.sh
        ;;
        "stop" )
            sh ${SPARK_HOME}/sbin/stop-all.sh
        ;;
        "restart" )
            sh ${SPARK_HOME}/sbin/stop-all.sh
            sh ${SPARK_HOME}/sbin/start-all.sh
        ;;
        * )
            usage
            exit
        ;;
    esac
    shift
    shift
fi