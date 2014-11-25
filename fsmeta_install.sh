#!/bin/bash 
. ./config 
. ./env.sh

export META_FILE=bin/${META_FILE}
function fsmeta_status()
{
    HOSTIP=$1
    echo "${HOSTIP} meta status";
    ps -ef | grep "fs-metaserver" | grep -v "grep" 2>&1 >/dev/null
    res=$?
    if [ ${res} -eq 0 ]; then \
        echo "${HOSTIP} fs-metaserver 正在运行"; \
    else
        echo "${HOSTIP} fs-metaserver 未运行"; \
    fi
    return ${res}
}

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
    fsmeta_status
    if [ $? -eq 0 ]; then \
        echo "${HOSTIP} fs-metaserver 正在运行"; exit 0;
    fi

    echo "${HOSTIP} meta start";
    cd ${META_FILE}/target && \
        java -jar -server ${META_SERVER_PARAMS} fs-metaserver-1.0-SNAPSHOT.jar
    cd ../../
}


function fsmate_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} meta stop";

    fsmeta_status
    if [ $? -eq 0 ]; then \
        #kill 
        kill `ps -ef |grep "fs-metaserver" |grep -v "grep" | awk '{print $2}'`; \
            if [ $? -eq 0 ]; then \
                echo "${HOSTIP} fsmetaserver成功关闭进程";
            fi
    fi
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
        nohup sh fsmeta_install.sh fsmeta_start ${META_SERVER} \
        > log/fsmeta_log.log 2>&1 &"
}

function dofsmeta_stop()
{
    echo "dofsmeta_stop";
    ssh -p "${SSH_PORT}" "${META_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsmeta_install.sh fsmate_stop ${META_SERVER};"
}


function dofsmeta_status()
{
    echo "fsdometa_status";

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

