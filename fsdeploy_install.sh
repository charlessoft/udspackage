#!/bin/bash 
. ./config
. ./env.sh

export DEPLOY_FILE=bin/${DEPLOY_FILE}
function fsdeploy_refresh_zookeeper_cfg()
{
    initenv
    ZOOKEEPER_CONFIG_CONTENT=`cat ./udszookeeper.cfg`
    echo ${ZOOKEEPER_CONFIG_CONTENT}
    echo ${PWD};

    cd ${DEPLOY_FILE}/target && \
        java -jar uds-deploy-3.0.0-SNAPSHOT.jar ${ZOOKEEPER_CONFIG_CONTENT}
    cd ../../../
    sleep 5s;

}

function fsdeploy_refresh_mongodb_cfg()
{
    initenv
    MONGODB_CONFIG_CONTENT=`cat ./udsmongodb.cfg`
    echo ${MONGODB_CONFIG_CONTENT}
    cd ${DEPLOY_FILE}/target && \
        java -jar uds-deploy-3.0.0-SNAPSHOT.jar  ${MONGODB_CONFIG_CONTENT}
    cd ../../../ 
    sleep 5s;
}


function dofsdeploy_refresh_zookeeper_cfg()
{
    echo "dofsdeply_refresh zookeeper cfg";
    echo ${DEPLOY_LOG_ZOOKEEPER_FILE};
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsdeploy_install.sh fsdeploy_refresh_zookeeper_cfg ${CONTENT_SERVER}  \
        > log/${DEPLOY_LOG_ZOOKEEPER_FILE} 2>&1 &"
    #sleep 2s;
}


function dofsdeploy_refresh_mongodb_cfg()
{
    echo "dofsdeply_refresh mongodb cfg";
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsdeploy_install.sh fsdeploy_refresh_mongodb_cfg ${CONTENT_SERVER}  \
        > log/${DEPLOY_LOG_MONGODB_FILE} 2>&1 &"
    sleep 2s;


}

function fsdeploy_zk_log()
{

    HOSTIP=$1
    echo "${HOSTIP} collect deploy zookeeper log";
    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_ZOOKEEPER_FILE} ./log/";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_ZOOKEEPER_FILE} ./log/${HOSTIP}_${DEPLOY_LOG_ZOOKEEPER_FILE}

    if [ $? -eq 0 ] 
    then 
        cfont -green "collect deploy zookeeper log success!\n" -reset ;
else 
    cfont -red "collecg deploy zookeeper log fail!\n" -reset;
   fi
}


function fsdeploy_mongodb_log()
{

    HOSTIP=$1
    echo "${HOSTIP} collect deploy mongodb log";
    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_MONGODB_FILE} ./log/";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_MONGODB_FILE} ./log/${HOSTIP}_${DEPLOY_LOG_MONGODB_FILE}

    if [ $? -eq 0 ] 
    then 
        cfont -green "collect deploy mongodb log success!\n" -reset ;
else 
    cfont -red "collecg deploy mongodb log fail!\n" -reset;
   fi
}

#------------------------------
# dofsdeploy_zookeeper_log
# description:  使用ssh 命令登陆到指定服务器收集log
# return success 0, fail 1
#------------------------------
function dofsdeploy_zookeeper_log()
{
    echo "dodeploy_zookeeper_collect log";
    
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_zk_log ${CONTENT_SERVER}  
       " 

}


#------------------------------
# dofsdeploy_mongodb_log
# description:  使用ssh 命令登陆到指定服务器收集log
# return success 0, fail 1
#------------------------------
function dofsdeploy_mongodb_log()
{
    echo "dodeploy_mongodb_collect log";
    
    ssh -p "${SSH_PORT}" "${CONTENT_SERVER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_mongodb_log ${CONTENT_SERVER}
    "       
    sleep 2s;

}


#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = fsdeploy_refresh_zookeeper_cfg ]
then 
    HOSTIP=$2;
    echo "fsdeploy_refresh_zookeeper_cfg..."; 
    fsdeploy_refresh_zookeeper_cfg ${HOSTIP};
fi

if [ "$1" = fsdeploy_refresh_mongodb_cfg ]
then 
    HOSTIP=$2
    echo "fsdeploy_refresh_mongodb_cfg...";
    fsdeploy_refresh_mongodb_cfg ${HOSTIP}
fi



if [ "$1" = fsdeploy_zk_log ]
then 
    HOSTIP=$2
    echo "fsdeploy_zk_log";
    fsdeploy_zk_log ${HOSTIP}
fi



if [ "$1" = fsdeploy_mongodb_log ]
then 
    HOSTIP=$2
    echo "fsdeploy_mongodb_log";
    fsdeploy_mongodb_log ${HOSTIP}
fi
