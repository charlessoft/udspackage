#!/bin/bash 
. ./config 


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

    sed -e 's#TEMP_ZKDATADIR#'${ZOOKEEPER_DATADIR}'#g' "zoo_bak.cfg" | \
        sed -e 's#TEMP_ZKDATALOGDIR#'${ZOOKEEPER_LOGDIR}'#g' > zoo_${HOSTIP}.cfg;
    
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        echo "$i" >> zoo_${HOSTIP}.cfg;
    done
    if [ $? -ne 0 ] 
    then 
        cfont -red "generate ${HOSTIP} fail!\n" -reset; exit 1;
    fi
}

