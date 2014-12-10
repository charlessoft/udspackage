#!/bin/bash 
. ./config 
. ./env.sh

#------------------------------
# deal_zkconfig
# description: 设置zookeeper配置文件
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function deal_zkconfig()
{
    HOSTIP=$1
    echo "zookeeper generate ${HOSTIP} zoo.cfg";
    if [ ! -n "${HOSTIP}" ] 
    then 
        cfont -red "need HOSTIP address\n" -reset;  
        exit 1;
    fi

    sed -e 's#TEMP_ZKDATADIR#'${ZOOKEEPER_DATADIR}'#g' "conf/zoo_bak.cfg" | \
        sed -e 's#TEMP_ZKDATALOGDIR#'${ZOOKEEPER_LOGDIR}'#g' > zoo_${HOSTIP}.cfg;
    
    for i in ${ZOOKEEPER_NODE_ARR[@]}
    do 
        echo "$i" >> zoo_${HOSTIP}.cfg;
    done
    if [ $? -ne 0 ] 
    then 
        cfont -red "generate ${HOSTIP} fail!\n" -reset; exit 1;
    fi
}

function deal_zkperproperty()
{

    MYHOST=
    for i in ${ZOOKEEPER_NODE_ARR[@]}
    do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`;
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`;
        #echo ${MYID}
        #echo ${HOSTIP}
        MYHOST=${MYHOST}${HOSTIP}:${ZOOKEEPER_PORT}","
    done
    MYHOST=${MYHOST%,*}
    sed -e 's/=.*/='${MYHOST}'/g' conf/zookeeper.properties > zookeeper.properties
}


#if [ "$1" = zk_zookeeperproperty ]
#then 
    #echo "zk_zookeeperproperty...";
    #zk_zookeeperproperty 
#fi
