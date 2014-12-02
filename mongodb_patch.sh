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
    #echo ${MONGODB_MASTER}
    if [ "$1" = "${MONGODB_MASTER}" ]; then \
        echo "master: $1"; \
        sed -e 's#TEMP_DBPATH#'${MONGODB_MASTER_DBPATH}'#g' "mongodb_bak.conf" | \
        sed -e 's#TEMP_MONGODBLOG#'${MONGODB_MASTER_LOGPATH}'#g' | \
        sed -e 's#TEMP_PIDFILEPATH#'${MONGODB_MASTER_PIDFILEPATH}'#g'  > mongodb_$1.conf

    elif [ "$1" = "${MONGODB_ARBITER}" ]; then \
        echo "arbiter: $1"; \
        sed -e 's#TEMP_DBPATH#'${MONGODB_ARBITER_DBPATH}'#g' "mongodb_bak.conf" | \
        sed -e 's#TEMP_MONGODBLOG#'${MONGODB_ARBITER_LOGPATH}'#g' | \
        sed -e 's#TEMP_PIDFILEPATH#'${MONGODB_ARBITER_PIDFILEPATH}'#g'  > mongodb_$1.conf  
    else 
        echo "slave: $1"; \
        #可能需要判断下.是否就是slave
        sed -e 's#TEMP_DBPATH#'${MONGODB_SLAVE_DBPATH}'#g' "mongodb_bak.conf" | \
        sed -e 's#TEMP_MONGODBLOG#'${MONGODB_SLAVE_LOGPATH}'#g' | \
        sed -e 's#TEMP_PIDFILEPATH#'${MONGODB_SLAVE_PIDFILEPATH}'#g'  > mongodb_$1.conf 
    fi

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
    echo "var db = connect('${MONGODB_MASTER}:${MONGODB_MASTER_PORT}/admin');" >> ${MONGODB_CLUSTER_JS};
    echo "var cfg={
        \"_id\":\"testrs\",
        \"members\":[" >> ${MONGODB_CLUSTER_JS};

    #生成master 
    echo "
        {
        \"_id\":${nIndex},
        \"host\":\"${MONGODB_MASTER}:${MONGODB_MASTER_PORT}\",
        \"priority\":${MAXPRIORITY}
        }" >> ${MONGODB_CLUSTER_JS};

    #生成slave

    for i in ${MONGODB_SLAVE_ARR[@]}; do 
        let nIndex=$nIndex+1;
        let npriority=${MAXPRIORITY}-${nIndex};
        echo "
        ,{
        \"_id\":${nIndex},
        \"host\":\"${i}:${MONGODB_SLAVE_PORT}\",
        \"priority\":${npriority}
        }" >> ${MONGODB_CLUSTER_JS};
    done



    #生成arbiter
    let nIndex=$nIndex+1;
    #写入arbiter
    echo "
        ,{
        \"_id\":${nIndex},
        \"host\":\"${MONGODB_ARBITER}:${MONGODB_ARBITER_PORT}\",
        \"arbiterOnly\":true
        }" >> ${MONGODB_CLUSTER_JS};
        

    echo "]}">> ${MONGODB_CLUSTER_JS};
    echo "printjson(rs.initiate(cfg));" >> ${MONGODB_CLUSTER_JS};
    echo "printjson(rs.config());" >> ${MONGODB_CLUSTER_JS};
        #]
#printjson(rs.config());


}




#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = deal_mongodb_cluster_js_patch ]
then 
    HOSTIP=$2;
    echo "deal_mongodb_cluster_js_patch ...";
    deal_mongodb_cluster_js_patch ${HOSTIP};
fi
