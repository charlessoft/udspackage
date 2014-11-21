#!/bin/bash 

source ./config

function accessPortArr()
{
    PORTTMP=/tmp/porttmp; 
    for i in ${IPTABLES_ACCESS_PORT[@]}; do 
        echo $i
    echo "设置$1 允许的端口号: $i"

    #判断端口号是否已经存在iptables中
    grep "$i\>" ${IPTABLES_FILE} > /dev/null 
    if [ $? -ne 0 ]; then \
        echo "增加允许端口"; \
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

function accessPort()
{
    PORTTMP=/tmp/porttmp; 
    ACCPORT=$2
    echo "设置允许端口信息$1 ${ACCPORT}"

    #判断是否已经存在端口列表
    grep "${ACCPORT}\>" ${IPTABLES_FILE} > /dev/null 
    if [ $? -ne 0 ]; then \
        echo "增加允许端口" ; \
        grep -n "22\>" ${IPTABLES_FILE} | awk -F: 'NR==1 \
              { \
                  sub(/22/,"'${ACCPORT}'",$2 ); printf("%s\n%s",$1,$2) ; \
              }'  > ${PORTTMP}
        
    LINE=`sed -n '1p' ${PORTTMP}`
    CONTENT=`sed -n '2p' ${PORTTMP}`
    #echo "sed -i '"${LINE}" a"${CONTENT}"' ${IPTABLES_FILE}"
    sed -i "${LINE} a ${CONTENT}" ${IPTABLES_FILE}
    #做法不好,需要改进
    #sed -i '$d' ${IPTABLES_FILE} 
    #cat ${PORTTMP} >> ${IPTABLES_FILE}
    #echo "COMMIT" >> ${IPTABLES_FILE}

    else 
        echo "已经设置了允许端口 $2"; \
    fi
#
    service iptables restart

}


function doaccessPort()
{

    echo "Riak 增加允许端口 ${RIAK_HTTP_PORT} "; \
    for i in ${RIAK_RINK[@]}; do 
        echo $i
            ssh -p ${SSH_PORT} "$i" \
                "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh iptables.sh accessPort $i ${RIAK_HTTP_PORT}"

        res=$?
        if [ ${res} -ne 0 ]; then \
            exit ${res};
        fi
        
    done
}


if [ "$1" = accessPort ]
then 
    echo "accessPort ====="
    #$2 为ip 
    #$3 为端口
    #accessPort $2 $3
    accessPortArr $2
fi
