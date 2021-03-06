#!/bin/bash 
. ./config
. ./env.sh
. ./config_patch.sh
export DEPLOY_FILE=bin/${DEPLOY_FILE}
#todoooooo需要连接到zookeepr上
#ZOOKEEPER_NODE_ARR


#------------------------------
# fsdeploy_install
# description:  启动fscontent
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsdeploy_install()
{
    HOSTIP=$1
    unzip -o ${DEPLOY_FILE}.zip  -d ${DEPLOY_FILE} >/dev/null 2>&1;
    if [ $? -eq 0 ]
    then 
        cfont -green "deploy install success!\n" -reset ; 
    else 
        cfont -red "deploy install fail!\n" -reset;
    fi

}

#------------------------------
# fsdeploy_refresh_storageresource_cfg
# description:  刷新zookeeper storage 节点配置
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function fsdeploy_refresh_storageresource_cfg()
{
    if [ $# -eq 1 ]
    then 
        HOSTIP=$1 
    else 
        #跳过deal_zookeeper_storageresource_confg 
        shift 
    fi
    #sh config_patch.sh deal_zookeeper_storageresource_confg "$@"
    deal_zookeeper_storageresource_confg "$@"

    initenv ${HOSTIP}
    ZOOKEEPER_STORAGERESOURCE_CONFIG_CONTENT=`cat ./${UDS_ZOOKEEPER_STORAGE_CONFIG}`
    echo ${ZOOKEEPER_STORAGERESOURCE_CONFIG_CONTENT};

    cd ${DEPLOY_FILE} && \
        java -jar ${DEPLOY_FILE_NAME}  \
        ${ZOOKEEPER_STORAGERESOURCE_CONFIG_CONTENT}
    cd ../../../
}

#------------------------------
# fsdeploy_refresh_zookeeper_cfg
# description:  刷新zookeeper 配置
# return success 0, fail 1
#------------------------------
function fsdeploy_refresh_zookeeper_cfg()
{
    initenv
    ZOOKEEPER_CONFIG_CONTENT=`cat ./${UDS_ZOOKEEPER_CONFIG}`

    cd ${DEPLOY_FILE} && \
        echo ${PWD}; \
        java -jar ${DEPLOY_FILE_NAME} ${ZOOKEEPER_CONFIG_CONTENT}
    cd ../../../
    sleep 2s;

}


#------------------------------
# fsdeploy_refresh_zookeeper_cfg
# description:  刷新zookeeper cluster配置
# return success 0, fail 1
#------------------------------
function fsdeploy_refresh_zookeeper_cluster_cfg()
{
    initenv
    ZOOKEEPER_CONFIG_CLUSTER_CONTENT=`cat ./${UDS_ZOOKEEPER_CLUSTER_CONFIG}`
    echo ${ZOOKEEPER_CONFIG_CLUSTER_CONTENT}

    cd ${DEPLOY_FILE} && \
        java -jar ${DEPLOY_FILE_NAME}  ${ZOOKEEPER_CONFIG_CLUSTER_CONTENT}
    cd ../../../
    sleep 2s;

}


#------------------------------
# fsdeploy_refresh_zookeeper_cfg
# description:  刷新mongodb 配置
# return success 0, fail 1
#------------------------------
function fsdeploy_refresh_mongodb_cfg()
{

    if [ $# -eq 1 ]
    then 
        HOSTIP=$1 
    else 
        #跳过deal_zookeeper_storageresource_confg 
        shift 
    fi
    sh config_patch.sh deal_mongodb_config "$@"

    initenv ${HOSTIP}
    MONGODB_CONFIG_CONTENT=`cat ./${UDS_MONGODB_CONFIG}`
    echo ${MONGODB_CONFIG_CONTENT}
    cd ${DEPLOY_FILE} && \
        java -jar ${DEPLOY_FILE_NAME}  ${MONGODB_CONFIG_CONTENT}
    cd ../../../ 
    sleep 2s;
}


#------------------------------
# fsdeploy_storageresource_log
# description:  调用ssh命令登陆指定服务器调用fsdeploy_storageresource_log收集日志
# return success 0, fail 1
#------------------------------
function fsdeploy_storageresource_log()
{
    HOSTIP=$1
    echo "${HOSTIP} collect deploy stroageresource log";
    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_ZOOKEEPER_STORAGE_FILE} ./log/";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_ZOOKEEPER_STORAGE_FILE} ./log/
    if [ $? -eq 0 ] 
    then 
        cfont -green "collect deploy zookeeper storageresource log success!\n" -reset ;
    else 
        cfont -red "collecg deploy zookeeper storageresource log fail!\n" -reset;
    fi
}

#------------------------------
# fsdeploy_zookeeper_cluster_log
# description:  调用ssh命令登陆指定服务器调用fsdeploy_zookeeper_cluster_log 收集日志
# return success 0, fail 1
#------------------------------
function fsdeploy_zookeeper_cluster_log()
{
    HOSTIP=$1
    echo "${HOSTIP} collect deploy zookeeper cluster log";
    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_ZOOKEEPER_CLUSTER_FILE} ./log/";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/log/${DEPLOY_LOG_ZOOKEEPER_CLUSTER_FILE} ./log/

    if [ $? -eq 0 ] 
    then 
        cfont -green "collect deploy zookeeper cluster log success!\n" -reset ;
    else 
        cfont -red "collecg deploy zookeeper cluster log fail!\n" -reset;
    fi
}


#------------------------------
# fsdeploy_zookeeper_log
# description:  收集zookeeper 刷配置日志
# return success 0, fail 1
#------------------------------
function fsdeploy_zookeeper_log()
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


#------------------------------
# fsdeploy_mongodb_log
# description:  收集mongodb 刷配置日志
# return success 0, fail 1
#------------------------------
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


function dofsdeploy_install()
{

    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_install ${ZOOKEEPER_FIRST_NODE_HOSTIP}"
}

#------------------------------
# dofsdeploy_refresh_zookeeper_cluster_cfg
# description:  调用ssh命令登陆指定服务器调用fsdeploy_refresh_zookeeper_cluster_cfg 刷新配置
# return success 0, fail 1
#------------------------------
function dofsdeploy_refresh_zookeeper_cluster_cfg()
{
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsdeploy_install.sh fsdeploy_refresh_zookeeper_cluster_cfg ${ZOOKEEPER_FIRST_NODE_HOSTIP}  \
        > log/${DEPLOY_LOG_ZOOKEEPER_CLUSTER_FILE} 2>&1 &"
    #sleep 2s;
}



#------------------------------
# dofsdeploy_refresh_storageresource_cfg
# description:  调用ssh命令登陆指定服务器调用fsdeploy_refresh_storageresource_cfg刷新配置
# return success 0, fail 1
#------------------------------
function dofsdeploy_refresh_storageresource_cfg()
{
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsdeploy_install.sh fsdeploy_refresh_storageresource_cfg ${ZOOKEEPER_FIRST_NODE_HOSTIP} "$@" \
        > log/${DEPLOY_LOG_ZOOKEEPER_STORAGE_FILE} 2>&1 &"
    #sleep 2s;
}

#------------------------------
# dofsdeploy_refresh_zookeeper_cfg
# description:  调用ssh命令登陆指定服务器调用fsdeploy_refresh_zookeeper_cfg刷新配置
# return success 0, fail 1
#------------------------------
function dofsdeploy_refresh_zookeeper_cfg()
{
    echo "dofsdeply_refresh zookeeper cfg";
    echo ${DEPLOY_LOG_ZOOKEEPER_FILE};
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsdeploy_install.sh fsdeploy_refresh_zookeeper_cfg ${ZOOKEEPER_FIRST_NODE_HOSTIP}  \
        > log/${DEPLOY_LOG_ZOOKEEPER_FILE} 2>&1 &"
    #sleep 2s;
}


#------------------------------
# dofsdeploy_refresh_mongodb_cfg
# description:  调用ssh命令登陆指定服务器调用fsdeploy_refresh_mongodb_cfg 刷新配置
# return success 0, fail 1
#------------------------------
function dofsdeploy_refresh_mongodb_cfg()
{
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        nohup sh fsdeploy_install.sh fsdeploy_refresh_mongodb_cfg ${ZOOKEEPER_FIRST_NODE_HOSTIP}  \
        > log/${DEPLOY_LOG_MONGODB_FILE} 2>&1 &"
    sleep 2s;


}


#------------------------------
# dofsdeploy_storageresource_log()
# description:  使用ssh 命令登陆到指定服务器收集log
# return success 0, fail 1
#------------------------------
function dofsdeploy_storageresource_log()
{
    echo "dofsdeploy_storageresource_log log";
    
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_storageresource_log ${ZOOKEEPER_FIRST_NODE_HOSTIP}  
       " 

}



#------------------------------
# dofsdeploy_zookeeper_log
# description:  使用ssh 命令登陆到指定服务器收集log
# return success 0, fail 1
#------------------------------
function dofsdeploy_zookeeper_log()
{
    echo "dodeploy_zookeeper_collect log";
    
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_zookeeper_log ${ZOOKEEPER_FIRST_NODE_HOSTIP}  
       " 

}

#------------------------------
# dofsdeploy_zookeeper_cluster_log
# description:  使用ssh 命令登陆到指定服务器收集zookeeper_cluster log
# return success 0, fail 1
#------------------------------
function dofsdeploy_zookeeper_cluster_log()
{
    echo "dofsdeploy_zookeeper_cluster_log log";
    
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_zookeeper_cluster_log ${ZOOKEEPER_FIRST_NODE_HOSTIP}  
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
    
    ssh -p "${SSH_PORT}" "${ZOOKEEPER_FIRST_NODE_HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh fsdeploy_install.sh fsdeploy_mongodb_log ${ZOOKEEPER_FIRST_NODE_HOSTIP}
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
    fsdeploy_refresh_mongodb_cfg "$@"
fi


if [ "$1" = fsdeploy_refresh_zookeeper_cluster_cfg ]
then 
    HOSTIP=$2
    echo "fsdeploy_refresh_zookeeper_cluster_cfg";
    fsdeploy_refresh_zookeeper_cluster_cfg  ${HOSTIP}
fi

if [ "$1" = fsdeploy_zookeeper_cluster_log ]
then 
    HOSTIP=$2
    echo "fsdeploy_zookeeper_cluster_log"
    fsdeploy_zookeeper_cluster_log  ${HOSTIP} 
fi



if [ "$1" = fsdeploy_zookeeper_log ]
then 
    HOSTIP=$2
    echo "fsdeploy_zookeeper_log";
    fsdeploy_zookeeper_log ${HOSTIP}
fi



if [ "$1" = fsdeploy_mongodb_log ]
then 
    HOSTIP=$2
    echo "fsdeploy_mongodb_log";
    fsdeploy_mongodb_log ${HOSTIP}
fi


if [ "$1" = fsdeploy_install ]
then 
    HOSTIP=$2
    echo "fsdeploy_install";
    fsdeploy_install ${HOSTIP}
fi

if [ "$1" = fsdeploy_refresh_storageresource_cfg ]
then 
    HOSTIP=$2
    echo "fsdeploy_refresh_storageresource_cfg "
    fsdeploy_refresh_storageresource_cfg  "$@"
fi

if [ "$1" = fsdeploy_storageresource_log ]
then 
    HOSTIP=$2
    echo "fsdeploy_storageresource_log "
    fsdeploy_storageresource_log ${HOSTIP}
fi
