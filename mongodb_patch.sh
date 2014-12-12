#!/bin/bash 
source ./config



#------------------------------
# deal_mongodb_patch
# description: 修改mongodb 配置文件
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function deal_mongodb_patch()
{
    MONGODB_ARR_TMP=tmp/mongodbarr.tmp
    echo ${MONGODB_SLAVE_ARR[*]}| sed -e 's/\ /\n/g' > ${MONGODB_ARR_TMP}
    echo ${MONGODB_MASTER} >> ${MONGODB_ARR_TMP}
    echo ${MONGODB_ARBITER}>> ${MONGODB_ARR_TMP}
    MONGODB_ARR=`cat ${MONGODB_ARR_TMP}`
    
    echo ${MONGODB_ARR[@]}
    for i in ${MONGODB_ARR[*]} 
    do
        sed -e 's#TEMP_DBPATH#'${MONGODB_DBPATH}'#g' "conf/mongodb_bak.conf" | \
            sed -e 's#TEMP_MONGODBLOG#'${MONGODB_LOGPATH}'#g' | \
            sed -e 's/port\ =\ 27017/port\ =\ '${MONGODB_PORT}'/g' | \
            sed -e 's#TEMP_PIDFILEPATH#'${MONGODB_PIDFILEPATH}'#g' > mongodb_$i.conf
    done

    num=${#MONGODB_ARR[@]} 
    if [ ${num} -eq 1 ]
    then
        echo ${PWD};
        sed -i 's/replSet=udsfs/#replSet=udsfs/g' mongodb_${MONGODB_MASTER}.conf
    fi



}

function deal_mongodb_db_auth_js_patch()
{

    MONGODB_DB_AUTH_JS=mongodb_db_auth.js
    rm -fr ./${MONGODB_DB_AUTH_JS}
    echo "var db = connect('${MONGODB_MASTER}:${MONGODB_PORT}/admin');" >> ${MONGODB_DB_AUTH_JS};
    echo "db.createUser({user:\"${MONGODB_SUPPER_USER}\", pwd:\"${MONGODB_SUPPER_PASSWORD}\", roles:[\"root\"]})" >> ${MONGODB_DB_AUTH_JS}
    echo "var udsdb = connect('${MONGODB_MASTER}:${MONGODB_PORT}/uds_fs');" >> ${MONGODB_DB_AUTH_JS};
    echo "udsdb.createUser({user:\"${MONGODB_DBUSER}\", pwd:\"${MONGODB_DBPASSWORD}\", roles:[{ role: \"readWrite\", db: \"${MONGODB_DBNAME}\" }]})" >> ${MONGODB_DB_AUTH_JS}
}


#------------------------------
# deal_mongodb_cluster_js_patch
# description: 修改mongodb_cluster.js 集群配置文件
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function deal_mongodb_cluster_js_patch()
{
    MONGODB_CLUSTER_JS=mongodb_cluster.js;
    rm -fr ./${MONGODB_CLUSTER_JS};
    
    nIndex=0;
    MAXPRIORITY=100;
    #生成mongodb js 脚本
    echo "var db = connect('${MONGODB_MASTER}:${MONGODB_PORT}/admin');" >> ${MONGODB_CLUSTER_JS};
    echo "var cfg={
        \"_id\":\"udsfs\",
        \"members\":[" >> ${MONGODB_CLUSTER_JS};

    #生成master 
    echo "
        {
        \"_id\":${nIndex},
        \"host\":\"${MONGODB_MASTER}:${MONGODB_PORT}\",
        \"priority\":${MAXPRIORITY}
        }" >> ${MONGODB_CLUSTER_JS};

    #生成slave

    for i in ${MONGODB_SLAVE_ARR[@]}; do 
        let nIndex=$nIndex+1;
        let npriority=${MAXPRIORITY}-${nIndex};
        echo "
        ,{
        \"_id\":${nIndex},
        \"host\":\"${i}:${MONGODB_PORT}\",
        \"priority\":${npriority}
        }" >> ${MONGODB_CLUSTER_JS};
    done



    #生成arbiter
    let nIndex=$nIndex+1;
    #写入arbiter
    echo "
        ,{
        \"_id\":${nIndex},
        \"host\":\"${MONGODB_ARBITER}:${MONGODB_PORT}\",
        \"arbiterOnly\":true
        }" >> ${MONGODB_CLUSTER_JS};
        

    echo "]}">> ${MONGODB_CLUSTER_JS};
    echo "printjson(rs.initiate(cfg));" >> ${MONGODB_CLUSTER_JS};
    echo "printjson(rs.config());" >> ${MONGODB_CLUSTER_JS};
        #]
#printjson(rs.config());


}

function deal_mongodb_cluster_status_js_patch()
{

    MONGODB_CLUSTER_STATUS_JS=mongodb_cluster_status.js;
    rm -fr ./${MONGODB_CLUSTER_STATUS_JS};

    echo "var db = connect('${MONGODB_MASTER}:${MONGODB_PORT}/admin');" >> ${MONGODB_CLUSTER_STATUS_JS};
    echo "printjson(rs.status());" >> ${MONGODB_CLUSTER_STATUS_JS};

}



#-------------------------------
#根据传递的参数执行命令
#-------------------------------



if [ "$1" = deal_mongodb_db_auth_js_patch ]
then 
    HOSTIP=$2;
    echo "deal_mongodb_db_auth_js_patch";
    #deal_mongodb_cluster_js_patch ${HOSTIP};
    deal_mongodb_db_auth_js_patch ${HOSTIP}
fi

if [ "$1" = deal_mongodb_cluster_js_patch ]
then 
    HOSTIP=$2;
    echo "deal_mongodb_cluster_js_patch ...";
    deal_mongodb_cluster_js_patch ${HOSTIP};
fi

if [ "$1" = deal_mongodb_cluster_js_patch ]
then 
    HOSTIP=$2;
    echo "deal_mongodb_cluster_js_patch ...";
    deal_mongodb_cluster_js_patch ${HOSTIP};
fi

if [ "$1" = deal_mongodb_patch ]
then 
    HOSTIP=$2
    echo "deal_mongodb_patch...";
    deal_mongodb_patch ${HOSTIP};
fi

if [ "$1" = deal_mongodb_cluster_status_js_patch ]
then 
    HOSTIP=$2;
    echo "deal_mongodb_cluster_status_js_patch...";
    deal_mongodb_cluster_status_js_patch ${HOSTIP};
fi
