#!/bin/bash 
. ./config 
. ./env.sh 

function deal_zookeeper_config()
{
    #MYID=`echo $i | awk -F= '{print $1}'| \
        #awk -F\. '{print $2}'`
    ZOOKEEPER_HOSTIP=`echo ${ZOOKEEPER_NODE_ARR} | awk -F= '{print $2}' | \
        awk -F: '{print $1}'`
    echo "zookeeper connect=${ZOOKEEPER_HOSTIP}:${ZOOKEEPER_PORT} \
        user=${ZOOKEEPER_USER} \
        password=${ZOOKEEPER_PASSWORD} \
        ${ZOOKEEPER_CONFIG_NAME}=${UDSPACKAGE_PATH}/configuration.json"  > ${UDS_ZOOKEEPER_CONFIG}

}

function deal_mongodb_config()
{
    RIAKHOSTIP=${RIAK_RINK}

    echo "addUser riakcon=${RIAKHOSTIP}:${RIAK_PROTOBUF_PORT} \
        riakbuk=userBucket \
        mongocon=${MONGODB_MASTER}:${MONGODB_MASTER_PORT} \
        mongousr=${MONGODB_USER} \
        mongopwd=${MONGODB_PASSWORD} \
        mongodbn=uds_fs \
        mongocol=${MONGODB_COL} \
        username=${MONGODB_ADDUSERNAME} \
        password=${MONGODB_ADDPASSWORD} buckets=uds" > ${UDS_MONGODB_CONFIG}

}

function deal_configuration()
{
    RIAK_RINK_LIST=`echo ${RIAK_RINK[@]}`;
    #echo ${RIAK_RINK_LIST//\ /,}
    sed -e 's/META_SERVER/'${META_SERVER}'/g' ./conf/configuration.json | \
        sed -e 's/MONGODB_HOST/'${MONGODB_MASTER}'/g' | \
        sed -e 's/MONGODB_PORT/'${MONGODB_MASTER_PORT}'/g' | \
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
