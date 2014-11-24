#!/bin/bash 
. ./config
. ./env.sh

function riak_install()
{
    echo "$1 安装Riak";
    `which riak` > /dev/null  
    if [ $? -ne 0  ]; then \
        cfont -red "未安装riak,开始安装riak \n" -reset; \
        if [ -f ${RIAK_FILE} ]; then \
            rpm -ivh ${RIAK_FILE}; \
        else
            cfont -red "${RIAK_FILE} 文件不存在退出 \n" -reset; exit 1;
        fi
    else 
        #echo "riak 已经安装";
        #rpm -ivh ${RIAK_FILE}
        cfont -red "已经安装 " `rpm -q riak` "\n" -reset;
    fi
    sh riak_patch.sh $1

}

function riak_start()
{
    res=0

    #用riak ping 得不到内容,改用getpid
    pid=`riak getpid | awk '{print $1}'`
    cfont -green "$1 端口号:${pid}\n" -reset;
    if [ "${pid}" == "Node" ]; then \
        echo "riak 未运行,启动riak...";
        riak start
        if [ $? -eq 0 ]; then \
            echo "启动成功!"; \
        else
            cfont -red "$1 riak 启动失败!" -reset;
            res=1
        fi
    else 
        echo "正在运行.....重新启动下";

        riak stop
        riak start
        if [ $? -eq 0 ]; then \
            pid=`riak getpid | awk '{print $1}'`;
            echo "Riak 进程号${pid}"; \
            cfont -green "重启成功!\n" -reset; \
        else
            cfont -red "$1 riak 重启失败!\n" -reset; 
            res=1;
        fi

        #riak-admin cluster join riak@

    fi

}

function riak_status()
{
    service riak status

}

function doriak_status()
{
    echo "获取各台Riak status"
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_status $i \
            "
        if [ $? -ne 0 ]; then \
            echo "查询失败 $1"
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
                echo "$1 加入 ${RIAK_FIRST_NODE} 成功!"; \
            else 
                echo "$1 加入 ${RIAK_FIRST_NODE} 失败!";
                exit 1;
            fi
        else 
            echo "$1 已经加入到环中";
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
            echo "Riak curl 网络检查失败!退出安装,请检查原因!";
            exit $?;
        fi

        echo "$1 Riak 检测启动成功,准备加入环中"; \
            ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_joinring $i"

        res=$?
        if [ ${res} -ne 0 ]; then \
            echo "cluster 加入失败 ${res}";
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
            echo "停止失败 $1"
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
    #ji群 ok

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
    echo "启动各台Riak"
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_start $i \
            "
        if [ $? -ne 0 ]; then \
            echo "启动失败 $1"
        fi
    done

    sleep 10s
}

function doriak_install()
{
    for i in ${RIAK_RINK[@]}; do
        echo "远程连接到$i安装Riak"

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



export RIAK_FILE=bin/${RIAK_FILE}


if [ "$1" = riak_install ] 
then 
    HOSTIP=$2
    echo "开始安装Riak"
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
