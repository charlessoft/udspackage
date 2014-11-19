#!/bin/bash 
source ./config

function riak_start()
{
    res=0

    #用riak ping 得不到内容,改用getpid
    pid=`riak getpid | awk '{print $1}'`
    echo "$1 端口号:${pid}"
    if [ "${pid}" == "Node" ]; then \
        echo "riak 未运行,启动riak...";
        riak start
        if [ $? -eq 0 ]; then \
            echo "启动成功!"; \
        else
            echo "$1 riak 启动失败!"; 
            res=1
        fi
    else 
        echo "正在运行.....重新启动下";

        riak stop
        riak start
        if [ $? -eq 0 ]; then \
            pid=`riak getpid | awk '{print $1}'`
            echo "Riak 进程号${pid}" \
            echo "重启成功!"; \
        else
            echo "$1 riak 重启失败!"; 
            res=1
        fi

        #riak-admin cluster join riak@

    fi

}

function riak_install()
{
    echo "$1 安装Riak";
    `which riak` > /dev/null  
    if [ $? -ne 0  ]; then \
        echo "未安装riak,开始安装riak"; \
        if [ -f ${RIAK_FILE} ]; then \
            rpm -ivh ${RIAK_FILE}; \
        else
            echo "${RIAK_FILE}文件不存在退"; exit 1;
        fi
    else 
        #echo "riak 已经安装";
        rpm -ivh ${RIAK_FILE}
    fi
    sh riak_patch.sh $1

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
            ssh -p 22 "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_joinring $i"

        res=$?
        if [ ${res} -ne 0 ]; then \
            echo "cluster 加入失败 ${res}";
            exit ${res};
        fi
        
    done

    ssh -p "22" "${RIAK_FIRST_NODE}" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh riak_install.sh commit ${RIAK_FIRST_NODE}; \
        "
}

function riak_unstall()
{
    echo "$1 卸载riak"
    riak stop
    rpm -e `rpm -q riak | awk 'NR==1'`
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
}


function doriak_start()
{
    echo "启动各台Riak"
    for i in ${RIAK_RINK[@]}; do 
        ssh -p 22 "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_start $i \
            "
        if [ $? -ne 0 ]; then \
            echo "启动失败 $1"
        fi
    done

    echo "睡觉=="
    sleep 10s
}

function doriak_install()
{
    for i in ${RIAK_RINK[@]}; do
        echo "远程连接到$i安装Riak"

        ssh -p 22 "$i" "cd ${UDSPACKAGE_PATH}; \
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
