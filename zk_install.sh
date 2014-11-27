#!/bin/bash 
. ./config 
. ./env.sh
export ZOOKEEPER_FILE=bin/${ZOOKEEPER_FILE}

function zk_install()
{

    HOSTIP=$1
    MYID=$2
    echo "${HOSTIP}:${MYID} zk_install...";

    if [  ! -d ${ZOOKEEPER_FILE} ] && [ -f ${ZOOKEEPER_FILE}.tar.gz  ]; then \
        tar zxvf ${ZOOKEEPER_FILE}.tar.gz -C ./bin 2>&1 >/dev/null;
        if [ $? -ne 0 ]; then \
            cfont -red "zookeeper install fail!\n" -reset; \
        else 
            cfont -green "zookeeper install success!\n" -reset;
        fi 
    else \
        cfont -green "zookeeper already installed!\n" -reset;
    fi

    #echo "cp ./zoo_${HOSTIP}.cfg  ./${ZOOKEEPER_FILE}/conf/zoo.cfg";
    if [ ! -f ./zoo_${HOSTIP}.cfg ]; then \
        cfont -red "zoo_${HOSTIP}.cfg No such file!\n" --reset; exit 1;
    fi

    cp ./zoo_${HOSTIP}.cfg  ./${ZOOKEEPER_FILE}/conf/zoo.cfg;
    mkdir ${ZOOKEEPER_DATADIR} -p
    mkdir ${ZOOKEEPER_LOGDIR} -p
    echo "${MYID}" > ${ZOOKEEPER_DATADIR}/myid

}




function zk_start()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_start...";
    
    initenv ${HOSTIP}
    if [ $? -ne 0 ]; then \
        return 1;
    fi

    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh start > tmp.log
        sleep 3s;
        cfont -green 
        echo `cat tmp.log`;
        cfont -reset
    cd ../../

}

function zk_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_stop...";
    initenv ${HOSTIP}
    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh stop > tmp.log
        sleep 2s;
        cfont -green 
        echo `cat tmp.log`; 
        cfont -reset;

    cd ../../
}

function zk_destroy()
{
    echo "$1 zk_destroy";

    zk_stop 
    echo $1
    echo ${PWD}
    echo "rm -fr ${ZOOKEEPER_DATADIR}"
    echo "rm -fr ${ZOOKEEPER_LOGDIR}"
    echo "rm -fr ${ZOOKEEPER_FILE}"
    rm -fr ${ZOOKEEPER_DATADIR};
    echo "RESSS=$?"

    rm -fr ${ZOOKEEPER_LOGDIR}
    echo "RESSS=$?"

    rm -fr ${ZOOKEEPER_FILE}
    echo "RESSS=$?"
}

function dozk_destroy()
{

    echo "dozk_destroy..."
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`
        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_destroy ${HOSTIP} ${MYID} \
            "
    done
}

function zk_status()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_status..."
    initenv ${HOSTIP}

    if [ -d ${ZOOKEEPER_FILE}/bin ]; then \
        cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh status > /tmp/tmp.log
        sleep 2s;
        grep -rin "error" /tmp/tmp.log 2>&1 >/dev/null;
        if [ $? -eq 0 ]; then \
            cfont -red
            echo `cat /tmp/tmp.log`
            cfont -reset
        else \
            cfont -green 
            echo `cat /tmp/tmp.log`
            cfont -reset
        fi
        cd ../../../;
        sed -e 's/\(.*\)/'${HOSTIP}' zookeeper \1/g' /tmp/tmp.log > ${ZOOKEEPER_CHECK_LOG}
    else 
        echo "${HOSTIP} zookeeper check fail!" > ${ZOOKEEPER_CHECK_LOG}
    fi
}


function zk_collectlog()
{
    echo "zk_collectionlog";
}


function dozk_install()
{
    echo "dozk_install..."
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_install ${HOSTIP} ${MYID} \
            "
    done
}

function dozk_start()
{
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_start ${HOSTIP} \
            "
        if [ $? -ne 0 ]; then \
            exit 1;
        fi
    done
}


function dozk_stop()
{
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_stop ${HOSTIP} \
            "
    done
}


function dozk_status()
{
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_status ${HOSTIP} \
            "
    done
}



if [ "$1" = zk_install ]
then 
    HOSTIP=$2
    MYID=$3
    zk_install ${HOSTIP} ${MYID}
fi

if [ "$1" = zk_start ]
then 
    HOSTIP=$2
    zk_start ${HOSTIP} 
fi


if [ "$1" = zk_status ]
then 
    HOSTIP=$2
    zk_status ${HOSTIP} 
fi



if [ "$1" = zk_stop ]
then 
    HOSTIP=$2
    zk_stop ${HOSTIP} 
fi


if [ "$1" = zk_destroy ]
then 
    echo "zk_destroy ====="
    HOSTIP=$2
    zk_destroy ${HOSTIP} 
fi
