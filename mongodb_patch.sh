#!/bin/bash 
source ./config
function deal_mongody_patch()
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

#echo ${MONGODB_MASTER}
#deal_mongody_patch  10.211.55.21
