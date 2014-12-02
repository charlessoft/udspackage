#!/bin/bash 
. ./config 
. ./env.sh
export MONGODB_FILE=bin/${MONGODB_FILE}


#------------------------------
# mongodb_mkdir_master
# description: 创建mongodb master文件夹
# return success 0, fail 1
#------------------------------
function mongodb_mkdir_master()
{
    mkdir ${MONGODB_MASTER_DBPATH} -p
    mkdir `echo ${MONGODB_MASTER_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
    mkdir `echo ${MONGODB_MASTER_LOGPATH} | sed  's/\/[^\/]*$//'` -p
}

#------------------------------
# mongodb_mkdir_slave 
# description: 创建mongodb slave文件夹
# return success 0, fail 1
#------------------------------
function mongodb_mkdir_slave()
{
    mkdir ${MONGODB_SLAVE_DBPATH} -p
    mkdir `echo ${MONGODB_SLAVE_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
}

#------------------------------
# mongodb_mkdir_arbiter
# description: 创建mongodb arbiter文件夹
# return success 0, fail 1
#------------------------------
function mongodb_mkdir_arbiter()
{
    mkdir ${MONGODB_ARBITER_DBPATH} -p
    mkdir `echo ${MONGODB_ARBITER_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
}

#------------------------------
# mongodb_init 
# description:  初始化mongodb, 创建对应文件夹
# params HOSTIP - ip address
# return success 0, fail 1
#------------------------------
function mongodb_init()
{
    HOSTIP=$1
    echo "${HOSTIP} init mongodb ";

    if [ "${HOSTIP}" = "${MONGODB_MASTER}" ] 
    then 
        echo "${HOSTIP} create mongodb master data folder";
        mongodb_mkdir_master;
    fi

    #if [ "$1" = "${MONGODB_}"]
    echo ${MONGODB_SLAVE_ARR[*]} | grep -E "\<${HOSTIP}\>" 2>&1 > /dev/null 
    if [ $? -eq 0 ] 
    then 
        echo "${HOSTIP} create mongodb slave data folder"; \
        mongodb_mkdir_slave
    fi

    if [ "${HOSTIP}" = "${MONGODB_ARBITER}" ] 
    then 
        #echo "mongodb_mkdir_arbiter";
        echo "${HOSTIP} create mongodb arbiter folder"
        mongodb_mkdir_arbiter
    fi 
}

#------------------------------
# mongodb_install
# description: 解压mongodb tar到指定目录
# params HOSTIP - ip address
# return success 0, fail 1
#------------------------------
function mongodb_install()
{
    HOSTIP=$1;
    echo "${HOSTIP} install mongodb";
    
    if [ ! -d ${MONGODB_FILE} ] 
    then 
        if [ -f ${MONGODB_FILE}.gz ] 
        then 
            tar zxvf ${MONGODB_FILE}.gz -C ./bin 2>&1 >/dev/null; 
            if [ $? -ne 0 ] 
            then 
                cfont -red "mongodb unzip fail\n" -reset; 
            else 
                cfont -green "mongodb unzip success!\n" -reset;
            fi 
        else 
            cfont -red "${MONGODB_FILE}.gz No such file!\n" -reset;
        fi
    else 
        cfont -green "mongodb already installed\n" -reset;
    fi

}


#------------------------------
# mongodb_start
# description: 启动mongodb
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function mongodb_start()
{
    HOSTIP=$1
    echo "${HOSTIP} start mongodb ";

    mongodb_status ${HOSTIP}
    if [ $? -ne 0 ] 
    then 
        if [ -d ${MONGODB_FILE} ] 
        then 
            cd ${MONGODB_FILE}/bin; 
            ./mongod -f ../../../mongodb_${HOSTIP}.conf > tmp.log;  
            cfont -green ""
            echo `cat tmp.log`; 
            cfont -reset; 
            cd ../../../;
        else 
            cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset ;
            exit 1;
        fi
    else 
        cfont -green "${HOSTIP} mongodb is running!\n" -reset;
    fi
    
    
}


#------------------------------
# mongodb_stop
# description: 停止mongodb 
# params HOSTIP - ip address
# params DBPATH - mongodb db path
# return success 0, fail 1
#------------------------------
function mongodb_stop()
{
    HOSTIP=$1
    DBPATH=$2
    echo "${HOSTIP}:${DBPATH}"
    if [ -d ${MONGODB_FILE} ] 
    then 
        cd ${MONGODB_FILE}/bin; 
        ./mongod --shutdown --dbpath ${DBPATH} ;
        sleep 3s;
        if [ $? -eq 0 ] 
        then 
            cfont -green "stop mongod success!\n" -reset;
        fi
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
}

#------------------------------
# mongodb_status
# description: 获取mongodb 状态
# params HOSTIP - ip address 
# params PORT - mongodb port
# return success 0, fail 1
#------------------------------
function mongodb_status()
{
    HOSTIP=$1
    PORT=$2
    echo "${HOSTIP}:${PORT} check mongodb whether is running";
    curl http://${HOSTIP}:${PORT} &> /dev/null 
    res=$?
    
    if [ ${res} -ne 0 ] 
    then 
        cfont -red "mongodb curl network check fail! res=${res}\n" -reset;
        echo "${HOSTIP} mongodb check fail!" >> ${MONGODB_CHECK_LOG}
        return ${res}; 
    else 
        cfont -green "mongodb curl network check success,mongodb is running! res=${res}\n" -reset;
        echo "${HOSTIP} mongodb check success!" >> ${MONGODB_CHECK_LOG}
    fi

}


#------------------------------
# mongodb_cluster
# description: 设置mongodb 集群
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function mongodb_cluster()
{
    HOSTIP=$1
    echo "${HOSTIP} cluster"
    if [ -d ${MONGODB_FILE} ] 
    then 
        cd ${MONGODB_FILE}/bin; 
        ./mongo ../../../mongodb_cluster.js; 
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
}

#------------------------------
# mongodb_cluster_status
# description: 获取mongodb 集群状态
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function mongodb_cluster_status()
{
    HOSTIP=$1
    echo "${HOSTIP} cluster"
    if [ -d ${MONGODB_FILE} ] 
    then 
        cd ${MONGODB_FILE}/bin; 
        ./mongo ../../../mongodb_cluster_status.js; 
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
}


#------------------------------
# domongodb_install
# description: 调用ssh命令 登陆指定服务器安装mongodb
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function domongodb_install()
{
    #安装 master
    ssh -p ${SSH_PORT} "${MONGODB_MASTER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_install ${MONGODB_MASTER} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi

    #安装slave
    for i in ${MONGODB_SLAVE_ARR[@]}; do
        #echo "$i安装 slave mongodb"

        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_install $i; \
            "
        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res};
        fi
    done

    #echo "${MONGODB_ARBITER} 安装 arbiter mongodb"
    ssh -p ${SSH_PORT} "${MONGODB_ARBITER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_install ${MONGODB_ARBITER} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; \
    fi
}

#------------------------------
# domongodb_start
# description: 调用ssh命令 登陆指定服务器启动mongodb
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function domongodb_start()
{
    echo "start master mongodb ";
    #echo "hello world" | cut -d " "
    ssh -p ${SSH_PORT} "${MONGODB_MASTER}" \
        " \
        cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_start ${MONGODB_MASTER} ${MONGODB_MASTER_PORT} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi


    for i in ${MONGODB_SLAVE_ARR[@]}; do
        echo "$i start slave mongodb";

        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_start $i ${MONGODB_SLAVE_PORT}; \
            "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done


    echo "start ${MONGODB_ARBITER} arbiter mongodb"

    ssh -p ${SSH_PORT} "${MONGODB_ARBITER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_start ${MONGODB_ARBITER} ${MONGODB_ARBITER_PORT} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi

}


#------------------------------
# domongodb_stop
# description: 调用ssh命令 登陆指定服务停止mongodb
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function domongodb_stop()
{

    echo "stop ${MONGODB_MASTER} master mongodb ";
    echo ""
    ssh -p ${SSH_PORT} "`echo ${MONGODB_MASTER}|cut -d: -f 1`" \
        " \
        cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_stop ${MONGODB_MASTER} ${MONGODB_MASTER_DBPATH} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi


    for i in ${MONGODB_SLAVE_ARR[@]}; do
        echo "stop $i slave mongodb";
        echo ""
        ssh -p ${SSH_PORT} "`echo $i|cut -d: -f 1`" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_stop $i ${MONGODB_SLAVE_DBPATH}; \
            "
        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res};
        fi
    done


    echo "stop ${MONGODB_ARBITER} arbiter mongodb";

    ssh -p ${SSH_PORT} "`echo ${MONGODB_ARBITER}|cut -d: -f 1`" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_stop ${MONGODB_ARBITER} ${MONGODB_ARBITER_DBPATH} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; \
    fi
}


#------------------------------
# domongodb_cluster
# description: 调用ssh命令 登陆指定服务器集群部署
# return success 0, fail 1
#------------------------------
function domongodb_cluster()
{
    echo "domongodb_cluster";
    HOSTIP=`echo ${MONGODB_ARBITER}|cut -d: -f 1`
    echo ${HOSTIP}
    ssh -p ${SSH_PORT} "${HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_cluster ${HOSTIP}"

}


#------------------------------
# domongodb_cluster_status
# description: 调用ssh命令 登陆指定服务器查询集群状态
# return success 0, fail 1
#------------------------------
function domongodb_cluster_status()
{
    echo "domongodb_cluster_status"
    HOSTIP=`echo ${MONGODB_ARBITER}|cut -d: -f 1`
    echo ${HOSTIP}
    ssh -p ${SSH_PORT} "${HOSTIP}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_cluster_status ${HOSTIP}"
}


#------------------------------
# domongodb_status
# description: 查询mongodb运行状态
# return success 0, fail 1
#------------------------------
function domongodb_status()
{
    rm -fr ${MONGODB_CHECK_LOG}
    mongodb_status ${MONGODB_MASTER} ${MONGODB_MASTER_PORT}
    echo ""
    for i in ${MONGODB_SLAVE_ARR[@]}; do
        mongodb_status $i ${MONGODB_SLAVE_PORT}
        echo ""
    done
    echo "" 

    mongodb_status ${MONGODB_ARBITER} ${MONGODB_ARBITER_PORT}
    echo ""
}




#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = mongodb_install ]
then 
    HOSTIP=$2
    mongodb_init ${HOSTIP}
    mongodb_install ${HOSTIP}
fi


if [ "$1" = mongodb_cluster ]
then 
    echo "mongodb_cluster..."
    HOSTIP=$2
    mongodb_cluster ${HOSTIP}
fi

if [ "$1" = mongodb_start ]
then
    HOSTIP=$2
    #临时增加测试
    #mongodb_init ${HOSTIP}
    #临时增加测试
    mongodb_start ${HOSTIP}
fi

if [ "$1" = mongodb_status ]
then
    shift 
    HOSTIP=$1
    PORT=$2
    mongodb_status ${HOSTIP} ${PORT}
fi


if [ "$1" = mongodb_stop ]
then
    shift 
    HOSTIP=$1
    DBPATH=$2
    mongodb_stop ${HOSTIP} ${DBPATH}
fi


if [ "$1" = mongodb_cluster_status ]
then
    shift 
    HOSTIP=$1
    mongodb_cluster_status ${HOSTIP}
fi
