#!/bin/bash 
. ./config 
. ./env.sh

function fscontent_install()
{
    HOSTIP=$1
    echo "${HOSTIP} content install";
}

function fscontent_start()
{
    HOSTIP=$1
    initenv
    if [ $? -ne 0 ]; then \
        echo "环境变量不正确无法启动 fscontent-server"; exit 1;
    fi
    echo "${HOSTIP} fscontent start";
    #java -version
    cd fs-contentserver/target && \
        java -jar -server -Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M fs-contentserver-1.0-SNAPSHOT.jar
    cd ../../
}


function fscontent_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} fscontent stop";
}

function fscontent_status()
{
    HOSTIP=$1
    echo "${HOSTIP} fscontent status";
}

function dofscontent_install()
{
    echo "dofscontent_install";
}

function dofscontent_start()
{
    echo "dofscontent_start";
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_start ${CONTENT_SERVER};"
}

function dofscontent_stop()
{
    echo "dofscontent_status";
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_stop ${CONTENT_SERVER};"
}


function dofscontent_status()
{
    echo "dofscontent_status";

    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_status ${CONTENT_SERVER};"

}

#================
#main

if [ "$1" = fscontent_install ]
then 
    HOSTIP=$2
    echo "fscontent_install ====="
    fscontent_install ${HOSTIP}
fi



if [ "$1" = content_start ]
then 
    HOSTIP=$2
    echo "fscontent_start ====="
    fscontent_start ${HOSTIP}
fi


if [ "$1" = content_stop ]
then 
    HOSTIP=$2
    echo "fscontent_stop ====="
    fscontent_stop ${HOSTIP}
fi


if [ "$1" = content_status ]
then 
    HOSTIP=$2
    echo "fscontent_status ====="
    fscontent_status ${HOSTIP}
fi
