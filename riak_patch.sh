#!/bin/bash 
source ./config 

function deal_sudoers()
{
    if [ -f "${SUDOERS_PATH}_bak" ]; then \
        echo "存在sudoers "; \
        cp ${SUDOERS_PATH}_bak ${SUDOERS_PATH}; \
    else 
        cp ${SUDOERS_PATH} ${SUDOERS_PATH}_bak
    fi
    #echo "sed -e 's/Defaults\ \ \ \ requiretty/#Defaults    requiretty' ${SUDOERS_PATH}_bak > ${SUDOERS_PATH}"
    echo "set sudo allow term can run riak";
    sed -e 's/Defaults\ \ \ \ requiretty/#Defaults    requiretty/g' ${SUDOERS_PATH}_bak > ${SUDOERS_PATH}
}



function deal_riakconf()
{
    echo "IP:$1"
    MINNUM=`echo ${RIAK_ERLANG_PORT_RANGE}|cut -d- -f 1`;
    MAXNUM=`echo ${RIAK_ERLANG_PORT_RANGE}|cut -d- -f 2`;
    if [ -f "${RIAK_CONF_BAK}" ]; then \
        cp ${RIAK_CONF_BAK} ${RIAK_CONF}; \
    else
        cp ${RIAK_CONF} ${RIAK_CONF_BAK}; \
    fi

    #echo "sed -e 's/nodename\ =\ riak@1.1.1.1/namenode = riak@$1' "riak.conf"  > ${RIAK_CONF}"
    echo "set riak conf"
    sed -e 's/nodename\ =\ riak@1.1.1.1/nodename = riak@'$1'/g' "riak.conf" | \
        sed -e 's/MINNUM/'${MINNUM}'/g' | \
        sed -e 's/MAXNUM/'${MAXNUM}'/g' \
        > ${RIAK_CONF};

    if [ $? -ne 0 ]; then \
        cfont -red "set riak conf fail!\n" -reset;
    fi

}

if [ "$1" = "" ]; then \
    echo "需要指定修改的ip地址"; exit 1;
fi
deal_sudoers
deal_riakconf $1
