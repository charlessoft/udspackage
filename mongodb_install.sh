#!/bin/bash 
source ./config 

function mongodb_isonline()
{
    HOSTIP=$1
    echo "${HOSTIP} 检测 mongodb 是否运行"
    curl http://${HOSTIP} &> /dev/null 
    res=$?
    echo "=====mongodb curl ${res}"
    if [ ${res} -ne 0 ]; then \
        echo "mongodb curl 网络检查失败,请检查原因!"
        return ${res}; \
    else 
        echo "mongodb curl 检测返回成功,mongodb正在运行";
    fi

}

function mongodb_init()
{
    HOSTIP=$1
    echo "初始化 ${HOSTIP} mongodb 相关信息";

    if [ "${HOSTIP}" = "${MONGODB_MASTER}" ]; then \
        echo "创建mongodb master 文件夹"
        mongodb_mkdir_master
    fi

    #if [ "$1" = "${MONGODB_}"]
    echo ${MONGODB_SLAVE_ARR[*]} | grep -E "\<${HOSTIP}\>" 2>&1 > /dev/null 
    if [ $? -eq 0 ]; then \
        echo "创建mongodb slave文件夹"; \
        mongodb_mkdir_slave
    fi

    if [ "${HOSTIP}" = "${MONGODB_ARBITER}" ]; then \
        echo "mongodb_mkdir_arbiter";
        echo "创建mongodb arbiter 文件夹"
        mongodb_mkdir_arbiter
    fi 
}

function mongodb_install()
{
    HOSTIP=$1
    echo "${HOSTIP} 安装 mongodb"
    
    if [ -f ${MONGODB_FILE}.gz ]; then \
        tar zxvf ${MONGODB_FILE}.gz; \
    fi

    #cd ${MONGODB_FILE}/bin; \
        #./mongod -f ../../mongodb_${HOSTIP}.conf

}


function mongodb_cluster()
{
    if [ -d ${MONGODB_FILE} ]; then \
        cd ${MONGODB_FILE}/bin; \
        ./mongo ../../mongodb_cluster.js; \
    else 
        echo "mongodb ${MONGODB_FILE} 目录文件不存在";
        exit 1;
    fi
}

function domongodb_cluster()
{
}


function mongodb_mkdir_master()
{
    mkdir ${MONGODB_MASTER_DBPATH} -p
    mkdir `echo ${MONGODB_MASTER_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
    mkdir `echo ${MONGODB_MASTER_LOGPATH} | sed  's/\/[^\/]*$//'` -p
}

function mongodb_mkdir_slave()
{
    mkdir ${MONGODB_SLAVE_DBPATH} -p
    mkdir `echo ${MONGODB_SLAVE_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
}

function mongodb_mkdir_arbiter()
{
    mkdir ${MONGODB_ARBITER_DBPATH} -p
    mkdir `echo ${MONGODB_ARBITER_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
}

function mongodb_start()
{
    HOSTIP=$1
    echo "${HOSTIP} 启动 mongodb "

    mongodb_isonline ${HOSTIP}
    if [ $? -ne 0 ]; then \
        echo  "${HOSTIP} mongodb 没启动"; \
        if [ -d ${MONGODB_FILE} ]; then \
            cd ${MONGODB_FILE}/bin; \
            ./mongod -f ../../mongodb_${HOSTIP}.conf; \
        else 
            echo "mongodb ${MONGODB_FILE} 目录文件不存在";
            exit 1;
        fi
    else 
        echo "${HOSTIP} mongodb 已经启动";
    fi
    
}

function mongodb_stop()
{
    HOSTIP=$1
    if [ -f ${MONGODB_FILE} ]; then \
       #先用killall mongod 
        killall mongod 
    fi
}


function domongodb_isonline()
{
    mongodb_isonline ${MONGODB_MASTER}
    echo ""
    for i in ${MONGODB_SLAVE_ARR[@]}; do
        mongodb_isonline $i
        echo ""
    done
    echo "" 

    mongodb_isonline ${MONGODB_ARBITER}
    echo ""
}

function domongodb_start()
{
    echo "远程启动 master mongodb "
    #echo "hello world" | cut -d " "
    ssh -p ${SSH_PORT} "`echo ${MONGODB_MASTER}|cut -d: -f 1`" \
        " \
        cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_start ${MONGODB_MASTER} \
        "
    res=$?
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi


    for i in ${MONGODB_SLAVE_ARR[@]}; do
        echo "远程启动 $i slave mongodb"

        ssh -p ${SSH_PORT} "`echo $i|cut -d: -f 1`" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_start $i; \
            "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done


    echo "远程启动 ${MONGODB_ARBITER} arbiter mongodb"

    ssh -p 22 "`echo ${MONGODB_ARBITER}|cut -d: -f 1`" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_start ${MONGODB_ARBITER} \
        "
    res=$?
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi

}

function mongodb_destory()
{
    echo "ss"

}

function domongodb_destroy()
{
    echo "mongodb destroy"
}

function domongodb_join()
{
   echo "join" 
}

function domongodb_install()
{
    #安装 master
    echo "远程连接到${MONGODB_MASTER} 安装mongodb "
    ssh -p 22 "`echo ${MONGODB_MASTER}|cut -d: -f 1`" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_install ${MONGODB_MASTER} \
        "
    res=$?
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi

    #安装slave
    for i in ${MONGODB_SLAVE_ARR[@]}; do
        echo "远程连接到$i安装 slave mongodb"

        ssh -p 22 "`echo $i|cut -d: -f 1`" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_install $i; \
            "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done

    echo "安装 ${MONGODB_ARBITER} 安装 arbiter mongodb"

    ssh -p 22 "`echo ${MONGODB_ARBITER}|cut -d: -f 1`" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_install ${MONGODB_ARBITER} \
        "
    res=$?
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi
}


if [ "$1" = mongodb_install ]
then 
    echo "mongodb_install ====="
    HOSTIP=$2
    mongodb_init ${HOSTIP}
    mongodb_install ${HOSTIP}
fi

if [ "$1" = mongodb_start ]
then
    echo "mongodb_start ===="
    HOSTIP=$2
    #临时增加测试
    mongodb_init ${HOSTIP}
    #临时增加测试
    mongodb_start ${HOSTIP}
fi

if [ "$1" = mongodb_isonline ]
then
    echo "mongodb_isonline ===="
    echo "参数共计 $#个"
    shift 
    #if [ $# -ne 2 ]; then \
        #echo "参数不正确,需要传递IP和端口号"; \
        #exit 1; \
    #fi 
    HOSTIP=$1
    #PORT=$2
    mongodb_isonline ${HOSTIP}
fi
