#!/bin/bash 
. ./config 
. ./env.sh

function fsmeta_install()
{
    HOSTIP=$1
    echo "${HOSTIP} meta install";
}

function fsmeta_start()
{
    HOSTIP=$1
    initenv
    if [ $? -ne 0 ]; then \
        echo "环境变量不正确无法启动 fsmeta-server"; exit 1;
    fi
    echo "${HOSTIP} meta start";
    #java -version
    cd fs-metaserver/target && \
        java -jar -server -Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M fs-metaserver-1.0-SNAPSHOT.jar
    cd ../../
}


function fsmate_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} meta stop";
}

function fsmeta_status()
{
    HOSTIP=$1
    echo "${HOSTIP} meta status";
}

function dofsmeta_install()
{
    echo "dofsmeta_install";
}

function dofsmeta_start()
{
    echo "dofsmeta_start";
    ssh -p "${SSH_PORT}" "${META_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsmeta_install.sh fsmeta_start ${META_SERVER};"
}

function dofsmate_stop()
{
    echo "dometa_status";
    ssh -p "${SSH_PORT}" "${META_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsmeta_install.sh fsmate_stop ${META_SERVER};"
}


function dometa_status()
{
    echo "dometa_status";

    ssh -p "${SSH_PORT}" "${META_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsmeta_install.sh fsmeta_status ${META_SERVER};"

}

#================
#main

if [ "$1" = fsmeta_install ]
then 
    HOSTIP=$2
    echo "fsmeta_install ====="
    fsmeta_install ${HOSTIP}
fi



if [ "$1" = fsmeta_start ]
then 
    HOSTIP=$2
    echo "fsmeta_start ====="
    fsmeta_start ${HOSTIP}
fi


if [ "$1" = fsmate_stop ]
then 
    HOSTIP=$2
    echo "fsmate_stop ====="
    fsmate_stop ${HOSTIP}
fi


if [ "$1" = fsmeta_status ]
then 
    HOSTIP=$2
    echo "fsmeta_status ====="
    fsmeta_status ${HOSTIP}
fi

