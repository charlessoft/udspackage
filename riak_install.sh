#!/bin/bash 
. ./config
. ./env.sh

export RIAK_FILE=bin/${RIAK_FILE}
function riak_install()
{
    echo "$1 install Riak";
    `which riak` > /dev/null;
    if [ $? -ne 0  ]; then \
        cfont -green "begin install riak ...\n" -reset; \
        if [ -f ${RIAK_FILE} ]; then \
            rpm -ivh ${RIAK_FILE}; \
        else
            cfont -red "${RIAK_FILE} No such file!\n" -reset; exit 1;
        fi
    else 
        #echo "riak 已经安装";
        #rpm -ivh ${RIAK_FILE}
        cfont -red "already installed " `rpm -q riak` "\n" -reset;
    fi
    sh riak_patch.sh $1

}

function riak_start()
{
    res=0

    `which riak` > /dev/null;
    if [ $? -ne 0  ]; then \
        exit 1; \
    fi

    #用riak ping 得不到内容,改用getpid
    pid=`riak getpid | awk '{print $1}'`
    cfont -green "$1 port:${pid}\n" -reset;
    if [ "${pid}" == "Node" ]; then \
        cfont -green "start riak...\n" -reset;
        riak start
        if [ $? -eq 0 ]; then \
            cfont -green "start success!\n" -reset; \
        else
            cfont -red "$1 riak fail!" -reset;
            res=1
        fi
    else 
        echo "already running.....restart riak";

        riak stop
        riak start
        if [ $? -eq 0 ]; then \
            pid=`riak getpid | awk '{print $1}'`;
            echo "Riak pid: ${pid}"; \
            cfont -green "restart success!\n" -reset; \
        else
            cfont -red "$1 riak restart fail!\n" -reset; 
            res=1;
        fi

        #riak-admin cluster join riak@

    fi

}

function riak_status()
{
    HOSTIP=$1
    service riak status
    res=$?
    if [ ${res} -eq 0 ]; then \
        echo "${HOSTIP} riak check success!" > ${RIAK_CHECK_LOG}; \
    else  \
        echo "${HOSTIP} riak check fail!" > ${RIAK_CHECK_LOG};
    fi
    return ${res}

}

function doriak_status()
{
    echo "Riak status"
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_status $i \
            "

        if [ $? -ne 0 ]; then \
            echo "query status fail $1"
        fi
    done

}


function riak_joinring()
{
    echo "joinring == $1"
    if [ "$1" != "${RIAK_FIRST_NODE}" ]; then \
        echo "$1 joing ${RIAK_FIRST_NODE}"
        echo "riak-admin status | grep member | grep -rin "${RIAK_FIRST_NODE}""
        riak-admin status | grep member | grep -rin "${RIAK_FIRST_NODE}"
        if [ $? -ne 0 ]; then \
            echo "riak-admin cluster join riak@${RIAK_FIRST_NODE};"
            riak-admin cluster join riak@${RIAK_FIRST_NODE};
            if [ $? -eq 0 ]; then \
                cfont -green "$1 join ${RIAK_FIRST_NODE} success!\n" -reset; \
            else 
                cfont -red "$1 join ${RIAK_FIRST_NODE} fail!\n" -reset;
                exit 1;
            fi
        else 
            cfont -green "$1 already join the ring\n" -reset;
        fi
    fi
}

function doriak_joinring()
{
    for i in ${RIAK_RINK[@]}; do 
        echo $i
        echo "curl http://$i:${RIAK_HTTP_PORT}"
        curl http://$i:${RIAK_HTTP_PORT} &> /dev/null
        res=$?
        echo "====curl ${res}"
        if [ ${res} -ne 0 ]; then \
            cfont -red "Riak curl network check fail!\n" -reset;
            exit $?;
        fi

        cfont -green "$1 Riak network check success,join the ring\n" -reset; \
            ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_joinring $i"

        res=$?
        if [ ${res} -ne 0 ]; then \
            cfont -red "cluster join fail ${res}\n" -reset;
            exit ${res};
        fi
        
    done

}

function riak_unstall()
{
    echo "$1 卸载riak"
    riak stop
    rpm -e `rpm -q riak | awk 'NR==1'`
}

function riak_rink_status()
{
    HOSTIP=$1
    RINKMEMBER=`riak-admin status | grep member`
    res=0;
    #判断riak 节点是否再 查询状态中
    for i in ${RIAK_RINK[@]}; do 
        echo $RINKMEMBER | grep -rin "$i" >/dev/null 2>&1
        if [ $? -ne 0 ]; then \
            res=1
        fi
    done 


    if [ ${res} -eq 0 ]; then \
        cfont -green "${RINKMEMBER}\n" -reset;
        echo "${RIAK_FIRST_NODE} riak rink check success! ${RINKMEMBER}" >> ${RIAK_CHECK_LOG};
    else 
        cfont -red "not full riak node in the ${RINKMEMBER}\n" -reset;
        echo "${RIAK_FIRST_NODE} riak rink check fail! ${RINKMEMBER}" >> ${RIAK_CHECK_LOG};
    fi

}

function doriak_rink_status()
{
    ssh -p ${SSH_PORT} "${RIAK_FIRST_NODE}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh riak_install.sh riak_rink_status ${RIAK_FIRST_NODE}"

}

function riak_stop()
{

    echo "riak stop";
    riak stop;
}

function doriak_stop()
{
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_stop $i \
            "
        if [ $? -ne 0 ]; then \
            cfont -red "stop fail $1\n" -reset;
        fi
    done
}

function doriak_unstall()
{
    for i in ${RIAK_RINK[@]}; do
        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_unstall $i"
    done
}

function riak_commit()
{

    riak-admin cluster plan 
    riak-admin cluster commit 
    riak-admin bucket-type create uds_fs_no_mult '{"props":{"allow_mult":false, "last_write_wins":true}}'
    riak-admin bucket-type activate uds_fs_no_mult
    riak-admin bucket-type list 
    #集群 ok

}

function doriak_commit()
{
    echo "commit Riak"

    ssh -p ${SSH_PORT} "${RIAK_FIRST_NODE}" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh riak_install.sh riak_commit ${RIAK_FIRST_NODE}; \
        "
}


function doriak_start()
{
    echo "start Riak"
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_start $i \
            "
        if [ $? -ne 0 ]; then \
            cfont -red "$i riak start fail $1\n" -reset;
            exit 1;
                
        fi
    done

    sleep 10s
}

function doriak_install()
{
    for i in ${RIAK_RINK[@]}; do
        echo "$i install Riak";

        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
           source /etc/profile; \
           sh riak_install.sh riak_install $i; \
           "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done
}





if [ "$1" = riak_install ] 
then 
    HOSTIP=$2
    echo "install Riak"
    riak_install ${HOSTIP}
fi 

if [ "$1" = riak_joinring ]
then
    HOSTIP=$2
    echo "riak_joinring"
    riak_joinring ${HOSTIP}
fi

if [ "$1" = riak_start ]
then 
    HOSTIP=$2
    echo "riak start startRiak===="
    riak_start ${HOSTIP}
fi

if [ "$1" = riak_commit ]
then 
    HOSTIP=$2
    echo "riak_commit ====="
    riak_commit ${HOSTIP}
fi

if [ "$1" = riak_unstall ]
then 
    HOSTIP=$2
    echo "riak_unstall ====="
    riak_unstall ${HOSTIP}
fi


if [ "$1" = riak_status ]
then 
    HOSTIP=$2
    echo "riak_status ====="
    riak_status ${HOSTIP}
fi


if [ "$1" = riak_stop ]
then 
    HOSTIP=$2
    echo "riak_stop ====="
    riak_stop ${HOSTIP}
fi


if [ "$1" = riak_rink_status ]
then 
    HOSTIP=$2
    echo "riak_rink_status ====="
    riak_rink_status ${HOSTIP}
fi


