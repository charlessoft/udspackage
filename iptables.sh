#!/bin/bash 

. ./config
. ./env.sh
export PORTTMP=/tmp/porttmp; 


#------------------------------
# initporttable
# description: 初始化iptables端口信息,整理运行的端口列表 
# return success 0, fail 1
#------------------------------
function initporttable()
{
    cat /dev/null > ${PORTTMP};
    for i in ${ZOOKEEPER_NODE_ARR[*]} 
    do 
        echo $i | awk -F: '{ printf("%s\n%s\n", $2,$3) }' >> ${PORTTMP};
    done 

    for i in ${IPTABLES_ACCESS_PORT[*]} 
    do 
        echo $i >> ${PORTTMP};
    done 

    echo ${RIAK_HTTP_PORT} >> ${PORTTMP};
    echo ${RIAK_HTTP_PORT} >> ${PORTTMP};
    echo ${RIAK_EPMD_PORT} >> ${PORTTMP};
    echo ${RIAK_HANDOFF_PORT} >> ${PORTTMP};
    echo ${RIAK_DEFPORT} >> ${PORTTMP};
    echo ${RIAK_PROTOBUF_PORT} >> ${PORTTMP}
    echo ${RIAK_ERLANG_PORT_RANGE/-/:} >> ${PORTTMP};

    echo ${MONGODB_MASTER_PORT}  >> ${PORTTMP};
    echo ${MONGODB_SLAVE_PORT}  >> ${PORTTMP};
    echo ${MONGODB_ARBITER_PORT}  >> ${PORTTMP};
}


#------------------------------
# accessPortArr
# description: 设置允许访问的端口
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function accessPortArr()
{

    HOSTIP=$1
    initporttable    
    unset IPTABLES_ACCESS_PORT
    
        IPTABLES_ACCESS_PORT=`cat ${PORTTMP} | sort | uniq`;

    for i in ${IPTABLES_ACCESS_PORT[@]} 
    do 
        echo "set ${HOSTIP} allow port: $i"

        #判断端口号是否已经存在iptables中
        grep "$i\>" ${IPTABLES_FILE} > /dev/null 
        if [ $? -ne 0 ] 
        then 
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



#------------------------------
# doaccessPort
# description:  使用ssh命令登陆到指定服务器,调用accessPort设置允许端口
# return success 0, fail 1
#------------------------------
function doaccessPort()
{

    #构造数组
    inithostarray;
    if [ $# -ge 1 ] 
    then 
        HOSTARR=$*
    else
        HOSTARR=`sort ${HOSTARRAY_FILE} | uniq`;
    fi

    #需要修改.需要指定全部的ip
    for i in ${HOSTARR[@]} 
    do 
        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh iptables.sh accessPort $i \
            "

        res=$?;
        if [ ${res} -ne 0 ] 
        then 
            exit ${res};
        fi

    done
}


#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = accessPort ]
then
    echo "accessPort ..."; 
    HOSTIP=$2;
    accessPortArr ${HOSTIP};
fi
