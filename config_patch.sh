#!/bin/bash 
. ./config 
. ./env.sh 

#------------------------------
# deal_zookeeper_config
# description: 刷zookeeper配置文件
# return success 0 ,fail 1
#------------------------------
function deal_zookeeper_config()
{
    echo "generate zookeeper config...";
    echo "zookeeper connect=${ZOOKEEPER_FIRST_NODE_HOSTIP}:${ZOOKEEPER_PORT} \
        user=${ZOOKEEPER_USER} \
        password=${ZOOKEEPER_PASSWORD} \
        ${ZOOKEEPER_CONFIG_NAME}=${UDSPACKAGE_PATH}/configuration.json"  > ${UDS_ZOOKEEPER_CONFIG}

}

#------------------------------
# deal_zookeeper_storageresource_confg
# description: 刷zookeeper storage配置文件
# return success 0 ,fail 1
#------------------------------
function deal_zookeeper_storageresource_confg()
{
    #生成udsstorage
    if [ $# -eq 3 ]
    then 
        shift #
        ZOOKEEPER_STORAGERESOURCE_NAME=$1
        ZOOKEEPER_STORAGERESOURCE_PATH=$2

    else 
        ZOOKEEPER_STORAGERESOURCE_PATH=${UDSPACKAGE_PATH}/${ZOOKEEPER_STORAGERESOURCE_PATH}
    fi
    echo ${ZOOKEEPER_STORAGERESOURCE_NAME}
    echo ${ZOOKEEPER_STORAGERESOURCE_PATH}

    echo "generage zookeeper storage resource config...";
    echo "zookeeper connect=${ZOOKEEPER_FIRST_NODE_HOSTIP}:${ZOOKEEPER_PORT} \
        user=${ZOOKEEPER_USER} \
        password=${ZOOKEEPER_PASSWORD} \
        ${ZOOKEEPER_STORAGERESOURCE_NAME}=${ZOOKEEPER_STORAGERESOURCE_PATH}"  > ${UDS_ZOOKEEPER_STORAGE_CONFIG}
    deal_storageresource 

}


#------------------------------
# deal_zookeeper_cluster_config
# description: 刷zookeeper cluster配置文件
# return success 0 ,fail 1
#------------------------------
function deal_zookeeper_cluster_config()
{

    echo "generate zookeeper cluster config...";
    #ZOOKEEPER_HOSTIP=`echo ${ZOOKEEPER_NODE_ARR} | awk -F= '{print $2}' | \
        #awk -F: '{print $1}'`
    echo "zookeeper connect=${ZOOKEEPER_FIRST_NODE_HOSTIP}:${ZOOKEEPER_PORT} \
        user=${ZOOKEEPER_USER} \
        password=${ZOOKEEPER_PASSWORD} \
        ${ZOOKEEPER_CLUSTER_NAME}=${UDSPACKAGE_PATH}/cluster"  > ${UDS_ZOOKEEPER_CLUSTER_CONFIG}
    echo "cluster" > cluster
    
}

#------------------------------
# deal_mongodb_config
# description: 刷mongodb 配置文件
# return success 0 ,fail 1
#------------------------------
function deal_mongodb_config()
{

    echo "generate mongodb config...";
    #RIAKHOSTIP=${RIAK_RINK}

    if [ $# -eq 4 ]
    then 
        shift
        MONGODB_DBUSER=$1
        MONGODB_ADDUSERNAME=$2
        MONGODB_ADDPASSWORD=$3

    fi
    echo ${MONGODB_DBUSER}
    echo ${MONGODB_ADDUSERNAME}
    echo ${MONGODB_ADDPASSWORD}


    echo "addUser riakcon=${RIAK_FIRST_NODE}:${RIAK_PROTOBUF_PORT} \
        riakbuk=userBucket \
        mongocon=${MONGODB_MASTER}:${MONGODB_PORT} \
        mongousr=${MONGODB_DBUSER} \
        mongopwd=${MONGODB_DBPASSWORD} \
        mongodbn=${MONGODB_DBNAME} \
        mongocol=${MONGODB_COL} \
        username=${MONGODB_ADDUSERNAME} \
        password=${MONGODB_ADDPASSWORD} \
        buckets=${MONGODB_BUCKETS}" > ${UDS_MONGODB_CONFIG}

}


#------------------------------
# deal_configuration
# description: 修改configure.json模板
# return success 0 ,fail 1
#------------------------------
function deal_configuration()
{

    echo "generate configration...";
    RIAK_RINK_LIST=`echo ${RIAK_RINK[@]}`;
    CONTENT_SERVER_LIST=`echo ${CONTENT_SERVER[@]} | sed -e 's/\ /,/g'`
    sed -e 's/META_SERVER/'${META_SERVER},10.211.55.4'/g' ./conf/configuration.json | \
        sed -e 's/MONGODB_HOST/'${MONGODB_MASTER}:${MONGODB_PORT}'/g' | \
        sed -e 's/MONGODB_PORT/'${MONGODB_PORT}'/g' | \
        sed -e 's/MONGODB_DBNAME/'${MONGODB_DBNAME}'/g' | \
        sed -e 's/MONGODB_DBUSER/'${MONGODB_DBUSER}'/g' | \
        sed -e 's/MONGODB_DBPASSWORD/'${MONGODB_DBPASSWORD}'/g' | \
        sed -e 's/NAME_SERVER/'${NAME_SERVER},10.211.55.4'/g' | \
        sed -e 's/PROTOBUF_PORT/'${RIAK_PROTOBUF_PORT}'/g' | \
        sed -e 's/CONTENT_SERVER/'${CONTENT_SERVER_LIST},10.211.55.4'/g' | \
        sed -e 's#FILE_TMP_PATH#'${FILE_TMP_PATH}'#g' | \
        sed -e 's/RIAK_RINK/'${RIAK_RINK_LIST//\ /,}'/g' > ./configuration.json

}

#------------------------------
# deal_storageresource
# description: 生成storageresource.json
# return success 0 ,fail 1
#------------------------------
function deal_storageresource()
{
    echo "generate storageresource...";
    #需要content_server数组 "127.0.01","1239.9..01"
    CONTENT_SERVER_LIST_SPLIT=
    for i in ${CONTENT_SERVER[@]}
    do 
        CONTENT_SERVER_LIST_SPLIT="\""$i\",${CONTENT_SERVER_LIST_SPLIT}
    done
    CONTENT_SERVER_LIST_SPLIT=${CONTENT_SERVER_LIST_SPLIT%,*}


    sed -e 's/TMPCONTENT/'${CONTENT_SERVER_LIST_SPLIT}'/g' ./conf/storageResource-default.json | \
        sed -e 's/TMPLIMITSIZE/'${ZOOKEEPER_STORAGERESOURCE_LIMITSIZE}'/g' | \
        sed -e 's#TMPSTORAGERESOURCE_PATH#'\"${ZOOKEEPER_STORAGERESOURCE_NAME}\"'#g' > ./storageresource.json

}

if [ "$1" = deal_zookeeper_config ]
then 
    deal_zookeeper_config
fi

if [ "$1" = deal_mongodb_config ]
then 
    deal_mongodb_config $@
fi


if [ "$1" = deal_configuration ]
then 
    deal_configuration
fi

if [ "$1" = deal_zookeeper_cluster_config ]
then 
    deal_zookeeper_cluster_config
fi

if [ "$1" = deal_storageresource ]
then 
    deal_storageresource "$@"
fi

if [ "$1" = deal_zookeeper_storageresource_confg ]
then 
    deal_zookeeper_storageresource_confg "$@"
fi
