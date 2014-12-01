#!/bin/bash 

. ./config

PORTTMP=/tmp/porttmp; 
function initporttable()
{
    rm -fr ${PORTTMP}
    for i in ${ZOOKEEPER_NODE_ARR[*]}; do 
        echo $i | awk -F: '{ printf("%s\n%s\n", $2,$3) }' >> ${PORTTMP}
    done 

    for i in ${IPTABLES_ACCESS_PORT[*]}; do 
        echo $i >> ${PORTTMP}
    done 

    echo ${RIAK_HTTP_PORT} >> ${PORTTMP} 
    echo ${RIAK_HTTP_PORT} >> ${PORTTMP}
    echo ${RIAK_EPMD_PORT} >> ${PORTTMP}
    echo ${RIAK_HANDOFF_PORT} >> ${PORTTMP}
    echo ${RIAK_DEFPORT} >> ${PORTTMP}
    echo ${RIAK_ERLANG_PORT_RANGE/-/:} >> ${PORTTMP}

    echo ${MONGODB_MASTER_PORT}  >> ${PORTTMP}
    echo ${MONGODB_SLAVE_PORT}  >> ${PORTTMP}
    echo ${MONGODB_ARBITER_PORT}  >> ${PORTTMP}
}

function accessPortArr()
{

    HOSTIP=$1
    initporttable    
    unset IPTABLES_ACCESS_PORT
    IPTABLES_ACCESS_PORT=`cat ${PORTTMP} | sort | uniq`;

    for i in ${IPTABLES_ACCESS_PORT[@]}; do 
    echo "set ${HOSTIP} allow port: $i"

    #判断端口号是否已经存在iptables中
    grep "$i\>" ${IPTABLES_FILE} > /dev/null 
    if [ $? -ne 0 ]; then \
        grep -n "22\>" ${IPTABLES_FILE} | awk -F: 'NR==1 \
            { \
                sub(/22/,"'$i'",$2); printf("%s\n%s",$1,$2); \
            }' > ${PORTTMP}

        LINE=`sed -n '1p' ${PORTTMP}`
        CONTENT=`sed -n '2p' ${PORTTMP}`
        sed -i "${LINE} a ${CONTENT}" ${IPTABLES_FILE}

    fi
    done
    service iptables start
    return 0
}


function doaccessPort()
{

    for i in ${RIAK_RINK[@]}; do 
            ssh -p ${SSH_PORT} "$i" \
                "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh iptables.sh accessPort $i "

        res=$?
        if [ ${res} -ne 0 ]; then \
            exit ${res};
        fi
        
    done
}


if [ "$1" = accessPort ]
then 
    echo "accessPort ====="
    HOSTIP=$2
    accessPortArr ${HOSTIP}
fi
