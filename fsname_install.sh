#!/bin/bash 
. ./config 
. ./env.sh

export NAME_FILE=bin/${NAME_FILE}
function fsname_status()
{
    HOSTIP=$1
    echo "${HOSTIP} name status";
    ps -ef | grep "fs-nameserver" | grep -v "grep"
    return $?
}

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
    fsname_status
    if [ $? -eq 0 ]; then \
        echo "${HOSTIP} fs-nameserver正在运行"; exit 0;
    fi

    echo "${HOSTIP} name start";
    #java -version
    cd ${NAME_FILE}/target && \
        java -jar -server ${NAME_SERVER_PARAMS} fs-nameserver-1.0-SNAPSHOT.jar
    cd ../../
}


function fsname_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} name stop";

    fsname_status
    if [ $? -eq 0 ]; then \
        kill `ps -ef | grep "fs-nameserver" | grep -v "grep" | awk '{print $2}'`; \
            if [ $? -eq 0 ]; then \
                echo "${HOSTIP} 成功关闭 fsnameserver 进程";
            fi
        else 
            echo "${HOSTIP} fsnameserver程序未启动";
    fi
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
        nohup sh fsname_install.sh fsname_start ${NAME_SERVER} \
        > log/fsname_log.log 2>&1 &"

}

function dofsname_stop()
{
    echo "doname_status";
    ssh -p "${SSH_PORT}" "${NAME_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsname_install.sh fsname_stop ${NAME_SERVER};"
}


function dofsname_status()
{
    echo "dofsname_status";

    ssh -p "${SSH_PORT}" "${NAME_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsname_install.sh fsname_status ${NAME_SERVER};"

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

