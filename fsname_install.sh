#!/bin/bash 
. ./config 
. ./env.sh

function fsname_install()
{
    HOSTIP=$1
    echo "${HOSTIP} name install";
}

function fsname_start()
{
    HOSTIP=$1
    initenv
    if [ $? -ne 0 ]; then \
        echo "环境变量不正确无法启动 fsname-server"; exit 1;
    fi
    echo "${HOSTIP} name start";
    #java -version
    cd fs-nameserver/target && \
        java -jar -server -Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M fs-nameserver-1.0-SNAPSHOT.jar
    cd ../../
}


function fsname_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} name stop";
}

function name_status()
{
    HOSTIP=$1
    echo "${HOSTIP} name status";
}

function dofsname_install()
{
    echo "dofsname_install";
}

function dofsname_start()
{
    echo "dofsname_start";
    ssh -p "${SSH_PORT}" "${NAME_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsname_install.sh fsname_start ${NAME_SERVER};"
}

function dofsname_stop()
{
    echo "doname_status";
    ssh -p "${SSH_PORT}" "${NAME_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsname_install.sh fsname_stop ${NAME_SERVER};"
}


function doname_status()
{
    echo "doname_status";

    ssh -p "${SSH_PORT}" "${NAME_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsname_install.sh name_status ${NAME_SERVER};"

}

#================
#main

if [ "$1" = fsname_install ]
then 
    HOSTIP=$2
    echo "fsname_install ====="
    fsname_install ${HOSTIP}
fi



if [ "$1" = fsname_start ]
then 
    HOSTIP=$2
    echo "fsname_start ====="
    fsname_start ${HOSTIP}
fi


if [ "$1" = fsname_stop ]
then 
    HOSTIP=$2
    echo "fsname_stop ====="
    fsname_stop ${HOSTIP}
fi


if [ "$1" = fsname_status ]
then 
    HOSTIP=$2
    echo "fsname_status ====="
    fsname_status ${HOSTIP}
fi

