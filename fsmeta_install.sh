#!/bin/bash 
. ./config 
. ./env.sh

export META_FILE=bin/${META_FILE}

META_ZK_PROPERTIES_BAK=${META_FILE}/zookeeper.properties_bak
META_ZK_PROPERTIES=${META_FILE}/zookeeper.properties


#------------------------------
# fsmeta_patchzookeeper
# description:  替换fs-common SNAPSHOT.jar 的zookeeper 文件
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsmeta_patchzookeeper()
{
    initenv 
    mkdir ${META_FILE}/lib/config -p 
    cp ./zookeeper.properties ${META_FILE}/lib/config
    cd ${META_FILE}/lib && \
        jar uvf fs-common-1.0-SNAPSHOT.jar config/zookeeper.properties
    cd ../../../ 
    rm -fr ${META_FILE}/lib/config


}

#------------------------------
# fsmeta_install
# description:  安装fsname
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsmeta_install()
{

    HOSTIP=$1
    unzip -o ${META_FILE}.zip  -d ${META_FILE} >/dev/null 2>&1;

    if [ $? -eq 0 ]
    then
        fsmeta_patchzookeeper
    else 
        cfont -red "unzip ${META_FILE} fail!\n" -reset;
    fi
    
}

#------------------------------
# fsmeta_start
# description:启动fsmeta
# params HOSTIP- ip address 
# return success 0, fail 1
#------------------------------
function fsmeta_start()
{
    HOSTIP=$1
    initenv ${HOSTIP}
    if [ $? -ne 0 ] 
    then 
        cfont -red "jdk environment error! fsmeta-server start fail!\n" -reset; exit 1;
    fi
    fsmeta_status ${HOSTIP}
    if [ $? -eq 0 ] 
    then 
        cfont -green "${HOSTIP} fs-metaserver is running\n" -reset; exit 0;
    fi

    echo "${HOSTIP} fs-metaserver start";
    cd ${META_FILE} && \
        #java -jar -server ${META_SERVER_PARAMS} fs-metaserver-1.0-SNAPSHOT.jar
    sh fs-metaserver.sh
    cd ../../
    sleep 5s;
}

#------------------------------
# fsmeta_status
# description: 获取meta运行状态
# params HOSTIP- ip address 
# return success 0, fail 1
#------------------------------
function fsmeta_status()
{
    HOSTIP=$1
    echo "${HOSTIP} fs-metaserver status";
    ps -ef | grep "fs-metaserver" | grep -v "grep" 
    res=$?
    if [ ${res} -eq 0 ] 
    then 
        cfont -green "${HOSTIP} fs-metaserver is running!\n" -reset; 
        echo "${HOSTIP} fs-metaserver check success!" > ${META_CHECK_LOG}; 
    else
        cfont -red "${HOSTIP} fs-metaserver is probably not running\n" -reset; 
        echo "${HOSTIP} fs-metaserver check fail!" > ${META_CHECK_LOG}; 
    fi
    return ${res}
}


#------------------------------
# fsmeta_stop
# description:停止fsmeta
# params HOSTIP- ip address 
# return success 0, fail 1
#------------------------------
function fsmate_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} meta stop";

    fsmeta_status ${HOSTIP}
    if [ $? -eq 0 ] 
    then 
        #kill 
        kill `ps -ef |grep "fs-metaserver" |grep -v "grep" | awk '{print $2}'`; 
            if [ $? -eq 0 ] 
            then 
                cfont -green "${HOSTIP} fsmetaserver stop success\n" -reset; 
            else 
                cfont -green "${HOSTIP} fsmetaserver stoped!\n" -reset;
            fi
    fi
}


#------------------------------
# fsmeta_log
# description:收集fsmeta 日志
# return success 0, fail 1
#------------------------------
function fsmeta_log()
{
    HOSTIP=$1
    echo "${HOSTIP} collect log";
    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/${META_FILE}/${META_LOG_FILE} ./log/${HOSTIP}_${META_LOG_FILE}";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/${META_FILE}/${META_LOG_FILE} ./log/${HOSTIP}_${META_LOG_FILE}

    if [ $? -eq 0 ]
    then 
        cfont -green "collect ${META_LOG_FILE} log success!\n" -reset ;
    else 
        cfont -red "collecg ${META_LOG_FILE} log fail!\n" -reset;
    fi
}


function dofsmeta_log()
{
    for i in ${META_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsmeta_install.sh fsmeta_log $i"
    done
}


#------------------------------
# dofsmeta_install
# description: 使用ssh 命令登陆到fsmetaserver服务器,调用fsmeta_install
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dofsmeta_install()
{

    echo "dofsname_install"
    for i in ${META_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsmeta_install.sh fsmeta_install ${i}"
    done
}
#------------------------------
# dofsmeta_start
# description:调用ssh命令 登陆指定服务器运行fsmeta
# return success 0, fail 1
#------------------------------
function dofsmeta_start()
{
    echo "dofsmeta_start";

    for i in ${META_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsmeta_install.sh fsmeta_start ${i}"
    done
}



#------------------------------
# dofsmeta_stop
# description:调用ssh命令 登陆指定服务器停止fsmeta
# return success 0, fail 1
#------------------------------
function dofsmeta_stop()
{
    echo "dofsmeta_stop";
    for i in ${META_SERVER[@]}
    do
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsmeta_install.sh fsmate_stop ${i};"
    done
}


#------------------------------
# dofsmeta_status
# description:调用ssh命令 登陆指定服务器获取fsmeta状态
# return success 0, fail 1
#------------------------------
function dofsmeta_status()
{
    echo "fsdometa_status";

    for i in ${META_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsmeta_install.sh fsmeta_status ${i};"
    done

}

#-------------------------------
#根据传递的参数执行命令
#-------------------------------

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


if [ "$1" = fsmeta_log ]
then 
    HOSTIP=$2
    echo "fsmeta_log ====="
    fsmeta_log ${HOSTIP}
fi
