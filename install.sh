#!/bin/bash 
source ./config

function startRiak()
{
    res=0
    #用riak ping 得不到内容,改用getpid
    pid=`riak getpid | awk '{print $1}'`
    echo ${pid}
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

        riak restart 
        if [ $? -eq 0 ]; then \
            pid=`riak getpid | awk '{print $1}'`
            echo "Riak 进程号${pid}" \
            echo "重启成功!"; \
            sleep 2s;
        else
            echo "$1 riak 重启失败!"; 
            res=1
        fi

        #riak-admin cluster join riak@

    fi

        #min=1
        #max=3
        #while [ $min -le $max ]
        #do
            #echo "riak-admin cluster join riak@${RIAK_FIRST_NODE}"
            #riak-admin cluster join riak@${RIAK_FIRST_NODE}
            #let "min++"
        #done  
    
}

function install()
{
    echo "$1 安装Riak";
    `which riak` > /dev/null  
    if [ $? -ne 0 ]; then \
        echo "未安装riak,开始安装riak"; \
        rpm -ivh ${RIAK_FILE}; \
    else 
        echo "riak 已经安装";
    fi

    #if [ -f ${RIAK_FILE} ]; then \
        #rpm -ivh ${RIAK_FILE};
        #if [ $? -eq 0 ]; then \
            #echo "sh modify_$1.sh"; \
            #sh modify_$1.sh; \
        #else
            #exit 1;
        #fi
        ##sudo riak start;
    #else 
        #exit ${FILE_NO_EXIST};
    #fi

}

function joinring()
{
    echo "joinring ==$1"
    if [ "$1" != "${RIAK_FIRST_NODE}" ]; then \
        riak-admin cluster join riak@${RIAK_FIRST_NODE};
        if [ $? -eq 0 ]; then \
            echo "$1 加入 ${RIAK_FIRST_NODE} 成功!"; \
        else 
            echo "$1 加入 ${RIAK_FIRST_NODE} 失败!";
            exit 1;
        fi
    fi
}

function dojoinring()
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
            sh install.sh joinring $i"

        res=$?
        if [ ${res} -ne 0 ]; then \
            exit ${res};
        fi
        
        #if [ ${res} -eq 0 ]; then \
        #else
            #echo "$1 Riak 检测启动失败!,退出安装,请检查原因!";
            #return 1;
        #fi


    done

    ssh -p "22" "${RIAK_FIRST_NODE}" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh install.sh commit ${RIAK_FIRST_NODE}; \
        "

    #sudo riak-admin cluster plan
    #sudo riak-admin cluster commit


    
}

function commit()
{

    riak-admin cluster plan 
    riak-admin cluster commit 
}


function dostart()
{
    for i in ${RIAK_RINK[@]}; do 
        echo "启动各台Riak"
        ssh -p 22 "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh install.sh startRiak $i \
            "
        if [ $? -ne 0 ]; then \
            echo "启动失败 $1"
        fi
    done
}

function doinstall()
{
    for i in ${RIAK_RINK[@]}; do
        echo "远程连接到$i安装Riak"

        ssh -p 22 "$i" "cd ${UDSPACKAGE_PATH}; \
           source /etc/profile; \
           sh install.sh install $i; \
           "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done
}


if [ "$1" = install ] 
then 
    echo "开始安装Riak"
    install $2
fi 

if [ "$1" = joinring ]
then
    echo "joinring"
    joinring $2
fi

if [ "$1" = startRiak ]
then 
    echo "startRiak===="
    startRiak $2
fi

if [ "$1" = commit ]
then 
    echo "commit ====="
    commit $2
fi
