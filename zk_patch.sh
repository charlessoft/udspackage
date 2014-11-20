#!/bin/bash 
. ./config 
function deal_zkconfig()
{
    #echo ${ZOOKEEPER_DATADIR};
    #echo ${ZOOKEEPER_LOGDIR};
    
    HOSTIP=$1
    echo "生成${HOSTIP} zoo.cfg"
    if [ ! -n "${HOSTIP}" ]; then \
        echo "需要输入HOSTIP地址";  \
        exit 1;
    fi

    sed -e 's#TEMP_ZKDATADIR#'${ZOOKEEPER_DATADIR}'#g' "zoo_bak.cfg" | \
        sed -e 's#TEMP_ZKDATALOGDIR#'${ZOOKEEPER_LOGDIR}'#g' > zoo_${HOSTIP}.cfg
    
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        echo "$i" >> zoo_${HOSTIP}.cfg
    done
    if [ $? -eq 0 ]; then \
        echo "ok";
    fi
}

