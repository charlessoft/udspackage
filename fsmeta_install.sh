#!/bin/bash 
. ./config 
. ./env.sh

export META_FILE=bin/${META_FILE}

function fsmeta_status()
{
    HOSTIP=$1
    echo "${HOSTIP} meta status";
    ps -ef | grep "fs-metaserver" | grep -v "grep" 
    res=$?
    if [ ${res} -eq 0 ]; then \
        cfont -green "${HOSTIP} fs-metaserver is running\n" -reset; \
        echo "${HOSTIP} fs-metaserver check success!" > ${META_CHECK_LOG}; \
    else
        cfont -red "${HOSTIP} fs-metaserver is probably not running\n" -reset; \
        echo "${HOSTIP} fs-metaserver check fail!" > ${META_CHECK_LOG}; \
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
        cfont -red "jdk environment error! fsmeta-server start fail!\n" -reset; exit 1;
    fi
    fsmeta_status
    if [ $? -eq 0 ]; then \
        cfont -green "${HOSTIP} fs-metaserver is running\n" -reset; exit 0;
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
                cfont -green "${HOSTIP} fsmetaserver stop success\n" -reset; \
            else 
                cfont -green "${HOSTIP} fsmetaserver stoped!\n" -reset;
            fi
    fi
}


function dofsmeta_install()
{
    echo "dofsmeta_install";
}

function fsmeta_log()
{

   echo "${META_SERVER} collect log";
   echo "scp ${META_SERVER}:${UDSPACKAGE_PATH}/log/${META_LOG_FILE} ./log/";
   scp ${META_SERVER}:${UDSPACKAGE_PATH}/log/${META_LOG_FILE} ./log/

   if [ $? -eq 0 ]; then \
       cfont -green "collect ${META_LOG_FILE} log success!\n" -reset ;
   else \
       cfont -red "collecg ${META_LOG_FILE} log fail!\n" -reset;
   fi
}

function dofsmeta_start()
{
    echo "dofsmeta_start";
    ssh -p "${SSH_PORT}" "${META_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsmeta_install.sh fsmeta_start ${META_SERVER} \
        > log/${META_LOG_FILE} 2>&1 &"
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

