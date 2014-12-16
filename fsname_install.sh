#!/bin/bash 
. ./config 
. ./env.sh

export NAME_FILE=bin/${NAME_FILE}

NAME_ZK_PROPERTIES_BAK=${NAME_FILE}/zookeeper.properties_bak
NAME_ZK_PROPERTIES=${NAME_FILE}/zookeeper.properties



#------------------------------
# fsname_patchzookeeper
# description:  替换fs-common SNAPSHOT.jar 的zookeeper 文件
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsname_patchzookeeper()
{
    initenv

    mkdir ${NAME_FILE}/lib/config -p 
    cp ./zookeeper.properties ${NAME_FILE}/lib/config
    cd ${NAME_FILE}/lib && \
        jar uvf fs-common-1.0-SNAPSHOT.jar config/zookeeper.properties

    cd ../../../ 
    rm -fr ${NAME_FILE}/lib/config

}
#------------------------------
# fsname_install
# description:  安装fsname
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsname_install()
{

    HOSTIP=$1
    unzip -o ${NAME_FILE}.zip  -d ${NAME_FILE} >/dev/null 2>&1;
    
    if [ $? -eq 0 ]
    then
        fsname_patchzookeeper
    else 
        cfont -red "unzip ${NAME_FILE} fail!\n" -reset;
    fi

}



#------------------------------
# fsname_start
# description:  启动fsnameserver
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsname_start()
{
    HOSTIP=$1
    initenv ${HOSTIP}
    if [ $? -ne 0 ]
    then 
        cfont -red "jdk environment error! fsname-server start fail\n" -reset; exit 1;
    fi
    fsname_status ${HOSTIP}
    if [ $? -eq 0 ] 
    then 
        cfont -red "${HOSTIP} fs-nameserver already start\n" -reset; exit 0;
    fi

    echo "${HOSTIP} name start";
    #java -version
    cd ${NAME_FILE} && \
        sh fs-nameserver.sh
    cd ../../
    sleep 5s;
}


#------------------------------
# fsname_stop
# description:  停止fsnameserver
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsname_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} name stop";

    fsname_status ${HOSTIP}
    if [ $? -eq 0 ] 
    then 
        kill `ps -ef | grep "fs-nameserver" | grep -v "grep" | awk '{print $2}'`; 
        if [ $? -eq 0 ] 
        then 
            cfont -green "${HOSTIP} stop fsnameserver success\n" -reset;
        fi
    else 
        cfont -green "${HOSTIP} fsnameserver stoped\n" -reset;
    fi
    }


#------------------------------
# fsname_status
# description:  获取fsnameserver状态
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsname_status()
{
    HOSTIP=$1
    echo "${HOSTIP} name status";
    ps -ef | grep "fs-nameserver" | grep -v "grep"
    res=$?
    if [ ${res} -eq 0 ] 
    then 
        cfont -green "${HOSTIP} fs-nameserver is running\n" -reset; 
        echo "${HOSTIP} fs-nameserver check success!" > ${NAME_CHECK_LOG};
    else 
        cfont -red "${HOSTIP} fs-nameserver is probably not running.\n" -reset; 
        echo "${HOSTIP} fs-nameserver check fail!" > ${NAME_CHECK_LOG}; 
    fi
    return ${res};
}


#------------------------------
# fsname_log
# description:  获取fsnameserver log
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsname_log()
{
    HOSTIP=$1
    echo "${HOSTIP} collect log";

    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/${NAME_FILE}/${NAME_LOG_FILE} ./log/${HOSTIP}_${NAME_LOG_FILE}";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/${NAME_FILE}/${NAME_LOG_FILE} ./log/${HOSTIP}_${NAME_LOG_FILE}
    if [ $? -eq 0 ] 
    then 
        cfont -green "collect ${HOSTIP} fsnameserver log success!\n" -reset ;
    else 
        cfont -red "collecg ${HOSTIP} fsnameserver log fail!\n" -reset;
    fi

}

function dofsname_log()
{
    for i in ${NAME_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsname_install.sh fsname_log $i"
    done
}


#------------------------------
# dofsname_install
# description: 使用ssh 命令登陆到fsnameserver服务器,调用fsname_install
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dofsname_install()
{

    echo "dofsname_install"
    for i in ${NAME_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsname_install.sh fsname_install ${i}"
    done
}

#------------------------------
# dofsname_start
# description: 使用ssh 命令登陆到fsnameserver服务器,调用 fsname_start 启动fsnameserver
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dofsname_start()
{
    echo "dofsname_start";
    for i in ${NAME_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsname_install.sh fsname_start ${i}"
    done

}


#------------------------------
# dofsname_stop
# description:  使用ssh 命令登陆到fsnameserver服务器,调用fsname_stop 停止fsnameserver服务
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dofsname_stop()
{
    echo "doname_status";
    for i in ${NAME_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsname_install.sh fsname_stop ${i};"
    done
}


#------------------------------
# dofsname_status
# description: 使用ssh命令登录到fsnameserver服务器,调用fsname_status获取fsnameserver运行状态
# return success 0, fail 1
#------------------------------
function dofsname_status()
{
    echo "dofsname_status";

    for i in ${NAME_SERVER[@]}
    do 
        ssh -p "${SSH_PORT}" "${i}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh fsname_install.sh fsname_status ${i};"
    done

}


#-------------------------------
#根据传递的参数执行命令
#-------------------------------
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


if [ "$1" = fsname_log ]
then 
    HOSTIP=$2
    echo "fsname_log ===="
    fsname_log ${HOSTIP}
fi
