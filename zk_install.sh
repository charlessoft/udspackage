#!/bin/bash 
. ./config 
. ./env.sh
function zk_install()
{
    echo "zk_install..."

    HOSTIP=$1
    MYID=$2

    if [  ! -d ${ZOOKEEPER_FILE} ] && [ -f ${ZOOKEEPER_FILE}.tar.gz  ]; then \
        tar zxvf ${ZOOKEEPER_FILE}.tar.gz 2>&1 >/dev/null;
    fi

    echo "cp ./zoo_${HOSTIP}.cfg  ./${ZOOKEEPER_FILE}/conf/zoo.cfg";
    cp ./zoo_${HOSTIP}.cfg  ./${ZOOKEEPER_FILE}/conf/zoo.cfg;
    mkdir ${ZOOKEEPER_DATADIR} -p
    mkdir ${ZOOKEEPER_LOGDIR} -p
    echo "${MYID}" > ${ZOOKEEPER_DATADIR}/myid

}




function zk_start()
{
    echo "$1 zk_start..."
    
    initenv
    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh start
    cd ../../

}

function zk_stop()
{
    echo "zk_stop...";
    initenv 
    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh stop
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
    echo "zk_status..."
    initenv
    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh status
    cd ../../
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
    echo "zk_install ====="
    HOSTIP=$2
    MYID=$3
    zk_install ${HOSTIP} ${MYID}
fi

if [ "$1" = zk_start ]
then 
    echo "zk_start ====="
    HOSTIP=$2
    zk_start ${HOSTIP} 
fi


if [ "$1" = zk_status ]
then 
    echo "zk_status ====="
    HOSTIP=$2
    zk_status ${HOSTIP} 
fi



if [ "$1" = zk_stop ]
then 
    echo "zk_stop ====="
    HOSTIP=$2
    zk_stop ${HOSTIP} 
fi


if [ "$1" = zk_destroy ]
then 
    echo "zk_destroy ====="
    HOSTIP=$2
    zk_destroy ${HOSTIP} 
fi
