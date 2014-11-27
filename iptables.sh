#!/bin/bash 

. ./config

PORTTMP=/tmp/porttmp; 
function initporttable()
{
    rm -fr ${PORTTMP}
    for i in ${ZOOKEEPER_NODE_ARR[*]}; do 
        echo $i | awk -F: '{printf("%s\n%s\n", $2,$3)}' >> ${PORTTMP}
    done 

    for i in ${IPTABLES_ACCESS_PORT[*]}; do 
        echo $i >> ${PORTTMP}
    done 

    echo ${RIAK_HTTP_PORT} >> ${PORTTMP} 
    echo ${RIAK_HTTP_PORT} >> ${PORTTMP}
    echo ${RIAK_EPMD_PORT} >> ${PORTTMP}
    echo ${RIAK_HANDOFF_PORT} >> ${PORTTMP}
    echo ${RIAK_DEFPORT} >> ${PORTTMP}

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
    service iptables stop 
    return 0
}

#function accessPort()
#{
    #PORTTMP=/tmp/porttmp; 
    #ACCPORT=$2
    #echo "设置允许端口信息$1 ${ACCPORT}"

    ##判断是否已经存在端口列表
    #grep "${ACCPORT}\>" ${IPTABLES_FILE} > /dev/null 
    #if [ $? -ne 0 ]; then \
        #echo "增加允许端口" ; \
        #grep -n "22\>" ${IPTABLES_FILE} | awk -F: 'NR==1 \
              #{ \
                  #sub(/22/,"'${ACCPORT}'",$2 ); printf("%s\n%s",$1,$2) ; \
              #}'  > ${PORTTMP}
        
    #LINE=`sed -n '1p' ${PORTTMP}`
    #CONTENT=`sed -n '2p' ${PORTTMP}`
    ##echo "sed -i '"${LINE}" a"${CONTENT}"' ${IPTABLES_FILE}"
    #sed -i "${LINE} a ${CONTENT}" ${IPTABLES_FILE}

    #else 
        #echo "已经设置了允许端口 $2"; \
    #fi
##
    #service iptables restart

#}


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
