#!/bin/bash 
. ./config 
. ./env.sh



#------------------------------
# deal_sudoers
# description: 设置/etc/sudoer是配置,设置用户允许使用sudo功能
# return success 0, fail 1
#------------------------------
function deal_sudoers()
{
    if [ -f "${SUDOERS_PATH}_bak" ] 
    then 
        echo "exist sudoers"; 
        cp ${SUDOERS_PATH}_bak ${SUDOERS_PATH}; 
    else 
        cp ${SUDOERS_PATH} ${SUDOERS_PATH}_bak;
    fi
    #echo "sed -e 's/Defaults\ \ \ \ requiretty/#Defaults    requiretty' ${SUDOERS_PATH}_bak > ${SUDOERS_PATH}"
    #echo "设置终端可运行"
    sed -e 's/Defaults\ \ \ \ requiretty/#Defaults    requiretty/g' ${SUDOERS_PATH}_bak > ${SUDOERS_PATH};
}



#------------------------------
# deal_riakconf
# description: 修改riakconf 配置
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function deal_riakconf()
{
    #echo "IP:$1"
    HOSTIP=$1
    MINNUM=`echo ${RIAK_ERLANG_PORT_RANGE}|cut -d- -f 1`;
    MAXNUM=`echo ${RIAK_ERLANG_PORT_RANGE}|cut -d- -f 2`;
    #if [ -f "${RIAK_CONF_BAK}" ] 
    #then 
        #cp ${RIAK_CONF_BAK} ${RIAK_CONF}; 
    #else
        #cp ${RIAK_CONF} ${RIAK_CONF_BAK}; 
    #fi

    echo "set riak conf";
    sed -e 's/nodename\ =\ riak@1.1.1.1/nodename = riak@'$1'/g' "conf/riak.conf" | \
        sed -e 's/MINNUM/'${MINNUM}'/g' | \
        sed -e 's/MAXNUM/'${MAXNUM}'/g' | \
        sed -e 's#TMPPLATFORM_DATA_DIR# '${RIAK_PLATFORM_DATA_DIR}'#g' | \
        sed -e 's#TMP8098#'${RIAK_HTTP_PORT}'#g' | \
        sed -e 's#TMP8087#'${RIAK_PROTOBUF_PORT}'#g' | \
        sed -e 's#TMPMULTI#'${RIAK_STORAGE_BACKEND}'#g' \
        > riak_${HOSTIP}.cfg

    #if [ $? -ne 0 ] 
    #then 
        #cfont -red "set riak conf fail!\n" -reset;
    #else
        #cfont -green "set riak conf success!\n" -reset;
    #fi

}

if [ "$1" = "" ] 
then 
    cfont -red "params need ip address!\n"; exit 1;
fi

#HOSTIP=$1

if [ "$1" = deal_sudoers ]
then 
    HOSTIP=$2;
    echo "deal_sudoers..."; 
    deal_sudoers ${HOSTIP};
fi

if [ "$1" = deal_riakconf ]
then 
    HOSTIP=$2;
    echo "deal_riakconf..."; 
    deal_riakconf ${HOSTIP};
fi

