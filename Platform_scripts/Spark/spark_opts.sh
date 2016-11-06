#!/bin/bash
THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS"; pwd`
CONFDIR=$rootdir/conf
CUR_USR=`whoami`

function usage() {
    echo -e "usage:$0 -op start/stop/restart/killall\n-h for help"
}
function empty_spark_home() {
    echo "The SPARK_HOME is not configured, please check and configure it"
    echo "You can configure it by modify the spark_env.sh or set the system environment variable"
}

OPTION=$1

if [[ $# -lt 1 ]]; then
    usage
    exit 
fi

if [[ $# -eq 3 ]]; then
    SPARK_MASTER=$3
else
    SPARK_MASTER=`ifconfig | grep "inet addr" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}'`

    if [ -z $SPARK_MASTER ] 
    then
        SPARK_MASTER=`ifconfig | grep "inet 地址" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}'`
    fi
fi

if [[ "$OPTION" == "-h" || "$OPTION" == "--help" || "$OPTION" == "-help" ]]; then
    usage
    exit
fi

if [[ "$OPTION" != "" && "$OPTION" != "-op" ]]; then
    usage
    exit
fi

if [[ -z $SPARK_HOME ]]; then
    source $CONFDIR/spark_env.sh
    if [[ -z $SPARK_HOME ]]; then
        empty_spark_home
        exit
    fi
fi

if [[ "$OPTION" == "-op" ]]; then
    case $2 in
        "start" )
            ssh $CUR_USR@$SPARK_MASTER sh $SPARK_HOME/sbin/start-all.sh
        ;;
        "stop" )
            ssh $CUR_USR@$SPARK_MASTER sh $SPARK_HOME/sbin/stop-all.sh
        ;;
        "restart" )
            ssh $CUR_USR@$SPARK_MASTER sh $SPARK_HOME/sbin/stop-all.sh
            ssh $CUR_USR@$SPARK_MASTER sh $SPARK_HOME/sbin/start-all.sh
        ;;
        * )
            usage
            exit
        ;;
    esac
    shift
    shift
fi