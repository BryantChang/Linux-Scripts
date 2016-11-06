#!/bin/bash
THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS"; pwd`
CONFDIR=$rootdir/conf
CUR_USR=`whoami`

function usage() {
    echo -e "usage:$0 -op startall/stopall/restartall/startdfs/stopdfs/restartdfs/killall\n-h for help"
}
function empty_hadoop_home() {
    echo "The HADOOP_HOME is not configured, please check and configure it"
    echo "You can configure it by modify the spark_env.sh or set the system environment variable"
}

##get the -op
OPTION=$1

if [[ $# -lt 1 ]]; then
    usage
    exit 
fi

##get_hadoop_master
if [[ $# -eq 3 ]]; then
    HADOOP_MASTER=$3
else
    HADOOP_MASTER=`ifconfig | grep "inet addr" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}'`

    if [ -z $HADOOP_MASTER ] 
    then
        HADOOP_MASTER=`ifconfig | grep "inet 地址" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F ':' '{print $2}'`
    fi
fi

##some judgement
if [[ "$OPTION" == "-h" || "$OPTION" == "--help" || "$OPTION" == "-help" ]]; then
    usage
    exit
fi

if [[ "$OPTION" != "" && "$OPTION" != "-op" ]]; then
    usage
    exit
fi

##check the HADOOP_HOME
if [[ -z $HADOOP_HOME ]]; then
    source $CONFDIR/hadoop_env.sh
    if [[ -z $HADOOP_HOME ]]; then
        empty_hadoop_home
        exit
    fi
fi

if [[ "$OPTION" == "-op" ]]; then
    case $2 in
        "startall" )
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/start-all.sh
        ;;
        "stopall" )
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/stop-all.sh
        ;;
        "restartall" )
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/stop-all.sh
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/start-all.sh
        ;;
        "startdfs" )
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/start-dfs.sh
        ;;
        "stopdfs" )
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/stop-dfs.sh
        ;;
        "restartdfs" )
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/stop-dfs.sh
            ssh $CUR_USR@$HADOOP_MASTER sh $HADOOP_HOME/sbin/start-dfs.sh
        ;;
        * )
            usage
            exit
        ;;
    esac
    shift
    shift
fi