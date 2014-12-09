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
    ZOOKEEPER_HOSTIP=`echo ${ZOOKEEPER_NODE_ARR} | awk -F= '{print $2}' | \
        awk -F: '{print $1}'`
    echo "zookeeper connect=${ZOOKEEPER_HOSTIP}:${ZOOKEEPER_PORT} \
        user=${ZOOKEEPER_USER} \
        password=${ZOOKEEPER_PASSWORD} \
        ${ZOOKEEPER_CONFIG_NAME}=${UDSPACKAGE_PATH}/configuration.json"  > ${UDS_ZOOKEEPER_CONFIG}

}


#------------------------------
# deal_zookeeper_cluster_config
# description: 刷zookeeper cluster配置文件
# return success 0 ,fail 1
#------------------------------
function deal_zookeeper_cluster_config()
{

    echo "generate zookeeper cluster config...";
    ZOOKEEPER_HOSTIP=`echo ${ZOOKEEPER_NODE_ARR} | awk -F= '{print $2}' | \
        awk -F: '{print $1}'`
    echo "zookeeper connect=${ZOOKEEPER_HOSTIP}:${ZOOKEEPER_PORT} \
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
    RIAKHOSTIP=${RIAK_RINK}

    echo "addUser riakcon=${RIAKHOSTIP}:${RIAK_PROTOBUF_PORT} \
        riakbuk=userBucket \
        mongocon=${MONGODB_MASTER}:${MONGODB_PORT} \
        mongousr=${MONGODB_DBUSER} \
        mongopwd=${MONGODB_DBPASSWORD} \
        mongodbn=${MONGODB_DBNAME} \
        mongocol=${MONGODB_COL} \
        username=${MONGODB_ADDUSERNAME} \
        password=${MONGODB_ADDPASSWORD} buckets=uds" > ${UDS_MONGODB_CONFIG}

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
    #echo ${RIAK_RINK_LIST//\ /,}
    sed -e 's/META_SERVER/'${META_SERVER}'/g' ./conf/configuration.json | \
        sed -e 's/MONGODB_HOST/'${MONGODB_MASTER}'/g' | \
        sed -e 's/MONGODB_PORT/'${MONGODB_PORT}'/g' | \
        sed -e 's/MONGODB_DBNAME/'${MONGODB_DBNAME}'/g' | \
        sed -e 's/MONGODB_DBUSER/'${MONGODB_DBUSER}'/g' | \
        sed -e 's/MONGODB_DBPASSWORD/'${MONGODB_DBPASSWORD}'/g' | \
        sed -e 's/NAME_SERVER/'${NAME_SERVER}'/g' | \
        sed -e 's/PROTOBUF_PORT/'${RIAK_PROTOBUF_PORT}'/g' | \
        sed -e 's/CONTENT_SERVER/'${CONTENT_SERVER}'/g' | \
        sed -e 's#FILE_TMP_PATH#'${FILE_TMP_PATH}'#g' | \
        sed -e 's/RIAK_RINK/'${RIAK_RINK_LIST//\ /,}'/g' > ./configuration.json

}

deal_zookeeper_config
deal_mongodb_config
deal_configuration
deal_zookeeper_cluster_config
