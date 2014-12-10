#!/bin/bash 
. ./config 
. ./env.sh

export CONTENT_FILE=bin/${CONTENT_FILE}

CONTENT_ZK_PROPERTIES_BAK=${CONTENT_FILE}/zookeeper.properties_bak
CONTENT_ZK_PROPERTIES=${CONTENT_FILE}/zookeeper.properties


#------------------------------
# fscontent_patchzookeeper
# description:  替换fs-common SNAPSHOT.jar 的zookeeper 文件
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fscontent_patchzookeeper()
{
    initenv
    mkdir ${CONTENT_FILE}/lib/config -p 
    cp ./zookeeper.properties  ${CONTENT_FILE}/lib/config
    cd ${CONTENT_FILE}/lib && \
        jar uvf fs-common-1.0-SNAPSHOT.jar config/zookeeper.properties
    cd ../../../
    rm -fr ${CONTENT_FILE}/lib/config

}

#------------------------------
# fscontent_install
# description:  启动fscontent
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fscontent_install()
{
    HOSTIP=$1
    unzip -o ${CONTENT_FILE}.zip  -d ${CONTENT_FILE};

    if [ $? -eq 0 ]
    then
        fscontent_patchzookeeper
    else 
        cfont -red "unzip ${CONTENT_FILE} fail!\n" -reset;
    fi
}


#------------------------------
# fscontent_start
# description:  启动fscontent
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fscontent_start()
{
    HOSTIP=$1
    initenv ${HOSTIP}
    if [ $? -ne 0 ] 
    then 
        cfont -red "jdk environment error ! fs-contentserver start fail\n" -reset; 
        exit 1;
    fi

    fscontent_status ${HOSTIP}
    if [ $? -eq 0 ] 
    then 
        cfont -red "${HOSTIP} fs-contentserver already start\n" -reset; exit 0;
    fi

    echo "${HOSTIP} fscontent start";
    #java -version
    cd ${CONTENT_FILE} && \
        #java -jar -server ${CONTENT_SERVER_PARAMS} fs-contentserver-1.0-SNAPSHOT.jar
        sh fs-contentserver.sh
    cd ../../
    sleep 5s;
}


#------------------------------
# fscontent_stop
# description:  停止fscontentserver
# params HOSTIP - ip address
# return success 0, fail 1
#------------------------------
function fscontent_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} fscontent stop";
    fscontent_status ${HOSTIP};

    if [ $? -eq 0 ] 
    then 
        #kill 
        kill `ps -ef | grep "fs-content" | grep -v "grep" | awk '{print $2}'`; 
        if [ $? -eq 0 ] 
        then 
            cfont -green "${HOSTIP} fs-contentserver stop success\n" -reset;
        fi
    fi

}

#------------------------------
# fscontent_status
# description:  查询 fscontentserver 状态
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fscontent_status()
{
    HOSTIP=$1
    echo "${HOSTIP} fscontent status";
    ps -ef | grep "fs-content" | grep -v "grep"
    res=$?
    if [ ${res} -eq 0 ] 
    then 
        cfont -green "${HOSTIP} fs-contentserver is running\n" -reset; 
        echo "${HOSTIP} fs-contentserver check success!" > ${CONTENT_CHECK_LOG}
    else 
        cfont -red "${HOSTIP} fs-contentserver is probably not running.\n" -reset; 
        echo "${HOSTIP} fs-contentserver check fail!" > ${CONTENT_CHECK_LOG}
    fi
    return ${res}
}



#------------------------------
# fscontent_log
# description:  收集fscontent log
# return success 0, fail 1
#------------------------------
function fscontent_log()
{
   echo "${CONTENT_SERVER} collect log";
   echo "scp ${CONTENT_SERVER}:${UDSPACKAGE_PATH}/bin/${CONTENT_FILE}/${CONTENT_LOG_FILE} ./log/";
   scp ${CONTENT_SERVER}:${UDSPACKAGE_PATH}/bin/${CONTENT_FILE}/${CONTENT_LOG_FILE} ./log/;

   if [ $? -eq 0 ] 
   then 
       cfont -green "collect fscontent log success!\n" -reset ;
   else 
       cfont -red "collecg fscontent log fail!\n" -reset;
   fi

}



#------------------------------
# dofscontent_install
# description:  使用ssh登陆到fscontent服务器安装fscontentserver
# return success 0, fail 1
#------------------------------
function dofscontent_install()
{
    echo "dofscontent_install"
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_install ${CONTENT_SERVER}"
    
}

#------------------------------
# dofscontent_start
# description:  使用ssh登陆到fscontent服务器启动fscontentserver
# return success 0, fail 1
#------------------------------
function dofscontent_start()
{
    echo "dofscontent_start";
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_start ${CONTENT_SERVER}"

}


#------------------------------
# dofscontent_stop
# description:  使用ssh登陆到fscontent服务器停止fscontentserver服务
# return success 0, fail 1
#------------------------------
function dofscontent_stop()
{
    echo "dofscontent_stop";
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_stop ${CONTENT_SERVER};"
}




#------------------------------
# fscontent_status
# description:  使用ssh登陆到fscontent服务器查看fscontentserver状态
# return success 0, fail 1
#------------------------------
function dofscontent_status()
{
    echo "dofscontent_status";

    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fscontent_install.sh content_status ${CONTENT_SERVER};"

}

#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = fscontent_install ]
then 
    HOSTIP=$2;
    echo "fscontent_install ...";
    fscontent_install ${HOSTIP};
fi



if [ "$1" = content_start ]
then 
    HOSTIP=$2;
    echo "fscontent_start ...";
    fscontent_start ${HOSTIP};
fi


if [ "$1" = content_stop ]
then 
    HOSTIP=$2;
    echo "fscontent_stop ...";
    fscontent_stop ${HOSTIP};
fi


if [ "$1" = content_status ]
then 
    HOSTIP=$2;
    echo "fscontent_status ...";
    fscontent_status ${HOSTIP};
fi

if [ "$1" = content_install ]
then 
    HOSTIP=$2;
    echo "fscontent_install ...";
    fscontent_install ${HOSTIP};
fi


