#!/bin/bash 
. ./config 
. ./env.sh
export MONGODB_FILE=bin/${MONGODB_FILE}
export MONGODB_TMPLOG=${UDSPACKAGE_PATH}/tmp/mongodbtmp.log
export MONGODB_CLUSTER_TMPLOG=${UDSPACKAGE_PATH}/tmp/mongodbclustertmp.log


#------------------------------
# mongodb_mkdir_master
# description: 创建mongodb master文件夹
# return success 0, fail 1
#------------------------------
function mongodb_mkdir_master()
{
    mkdir ${MONGODB_DBPATH} -p
    mkdir `echo ${MONGODB_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
    mkdir `echo ${MONGODB_LOGPATH} | sed  's/\/[^\/]*$//'` -p
}

#------------------------------
# mongodb_mkdir_slave 
# description: 创建mongodb slave文件夹
# return success 0, fail 1
#------------------------------
function mongodb_mkdir_slave()
{
    mkdir ${MONGODB_DBPATH} -p
    mkdir `echo ${MONGODB_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
}

#------------------------------
# mongodb_mkdir_arbiter
# description: 创建mongodb arbiter文件夹
# return success 0, fail 1
#------------------------------
function mongodb_mkdir_arbiter()
{
    mkdir ${MONGODB_DBPATH} -p
    mkdir `echo ${MONGODB_LOGPATH} | sed 's/\/[^\/]*$//'` -p 
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
        if [ -f ${MONGODB_FILE}.zip ] 
        then 
            #tar zxvf ${MONGODB_FILE}.gz -C ./bin 2>&1 >/dev/null; 
            unzip -o ${MONGODB_FILE}.zip -d ./bin 2>&1 >/dev/null;
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

    cp conf/mongodb-keyfile ${MONGODB_FILE}
    if [ $? -eq 0 ]
    then 
        cfont -green "copy ${MONGODB_KEYFILE} ok\n" -reset ;
        chmod 600 ${MONGODB_FILE}/${MONGODB_KEYFILE}
    else 
        cfont -red "copy ${MONGODB_KEYFILE} fail!\n" -reset;
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
    PORT=$2
    AUTHFLAG=$3 
    if  [ x"${AUTHFLAG}" = x"" -o x"${AUTHFLAG}" = x"false" ] 
    then 
        AUTHFLAG=false
        sed -i 's/keyFile/#keyFile/g' mongodb_${HOSTIP}.conf
    else
        sed -i 's/#.*keyFile/keyFile/g' mongodb_${HOSTIP}.conf
    fi
    echo "auth=${AUTHFLAG}"

    sed -i 's/auth=.*/auth='${AUTHFLAG}'/g' mongodb_${HOSTIP}.conf
    mongodb_status ${HOSTIP} ${PORT}
    if [ $? -ne 0 ] 
    then 
        if [ -d ${MONGODB_FILE} ] 
        then 
            cd ${MONGODB_FILE}/bin; 
            ./mongod -f ../../../mongodb_${HOSTIP}.conf > ${MONGODB_TMPLOG}
            grep -rin "ERROR" ${MONGODB_TMPLOG} >/dev/null 2>&1;
            if [ $? -eq 0 ] 
            then 
                cfont -red ""
                echo `cat ${MONGODB_TMPLOG}`; 
                cfont -reset; 
            else 
                cfont -green ""
                echo `cat ${MONGODB_TMPLOG}`; 
                cfont -reset; 
            fi
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
    if [ $# -lt 2 ]
    then 
        cfont -red "check mongodb whether is running ,need two params, ipaddress and port!\n" -reset;
        exit 1;
    fi
    HOSTIP=$1
    PORT=$2
    echo "${HOSTIP}:${PORT} check mongodb whether is running";
    curl http://${HOSTIP}:${PORT} &> /dev/null 
    res=$?
    
    if [ ${res} -ne 0 ] 
    then 
        cfont -red "mongodb ${HOSTIP}:${PORT} curl network check fail! res=${res}\n" -reset;
        echo "${HOSTIP} mongodb check fail!" >> ${MONGODB_CHECK_LOG}
        return ${res}; 
    else 
        cfont -green "mongodb ${HOSTIP}:${PORT} curl network check success,mongodb is running! res=${res}\n" -reset;
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
        cd ${MONGODB_FILE}/bin && \
            ./mongo ${MONGODB_MASTER}:${MONGODB_PORT} ../../../mongodb_cluster.js > ${MONGODB_CLUSTER_TMPLOG}
        cd ../../../
        grep -rin "\"ok\"\ :\ 1" ${MONGODB_CLUSTER_TMPLOG} >/dev/null 2>&1;
        if [ $? -eq 0 ]
        then 
            cfont -green 
            cat ${MONGODB_CLUSTER_TMPLOG}
            cfont -reset
        else 
            cfont -red
            cat ${MONGODB_CLUSTER_TMPLOG}
            cfont -reset
        fi
        exit 1;
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
        ./mongo ${MONGODB_ARBITER}:${MONGODB_PORT} ../../../mongodb_cluster_status.js; 
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
}

function mongodb_db_auth()
{
    HOSTIP=$1
    echo "${HOSTIP} db auth"
    if [ -s ${MONGODB_FILE} ]
    then 
        cd ${MONGODB_FILE}/bin;
        ./mongo  ${MONGODB_MASTER}:${MONGODB_PORT} ../../../mongodb_db_auth.js;
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
    
    
}

function domongodb_db_auth()
{

    ssh -p ${SSH_PORT} "${MONGODB_MASTER}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_db_auth ${MONGODB_MASTER} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi
}

#------------------------------
# domongodb_master_install
# description: 调用ssh命令 登陆服务器安装mongodb
# return success 0, fail 1
#------------------------------
function domongodb_master_install()
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
}


#------------------------------
# domongodb_slave_install
# description: 调用ssh命令 登陆slave服务器安装mongodb
# return success 0, fail 1
#------------------------------
function domongodb_slave_install()
{

    #安装slave
    for i in ${MONGODB_SLAVE_ARR[@]}
    do
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
}


#------------------------------
# domongodb_arbiter_install
# description: 调用ssh命令 登陆arbiter服务器安装mongodb
# return success 0, fail 1
#------------------------------
function domongodb_arbiter_install()
{

    #echo "${MONGODB_ARBITER} 安装 arbiter mongodb"
    if [ x"${MONGODB_ARBITER}" != x"" ]
    then 
        ssh -p ${SSH_PORT} "${MONGODB_ARBITER}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_install ${MONGODB_ARBITER} \
            "
        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res}; 
        fi
    fi
}

#------------------------------
# domongodb_install
# description: 根据ip地址 调用domongodb_master_install, domongodb_slave_install,domongodb_arbiter_install
# return success 0, fail 1
#------------------------------
function domongodb_install()
{
    if [ $# -ge 1 ]
    then
        #允许传入多个ip 地址
        until [ $# -eq 0 ]
        do 
            if [ x"$1" = x"${MONGODB_MASTER}" ]
            then
                domongodb_master_install
                shift
                continue
            elif [ x"$1" = x"${MONGODB_ARBITER}" ]
            then
                domongodb_arbiter_install
                shift
                continue
            else 
                #判断是否需要启动slave 
                for i in ${MONGODB_SLAVE_ARR[@]} 
                do 
                    if [ x"$1" = x"$i" ]
                    then 
                        domongodb_slave_install
                        shift
                        continue
                    fi
                done
                
            fi
            shift 
        done

    else 
        domongodb_master_install
        domongodb_slave_install
        domongodb_arbiter_install
    fi



}


#------------------------------
# domongodb_master_start
# description: 调用ssh命令 登陆master服务器启动mongodb
# return success 0, fail 1
#------------------------------
function domongodb_master_start()
{

    echo "start master mongodb ";

    ssh -p ${SSH_PORT} "${MONGODB_MASTER}" \
        " \
        cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_start ${MONGODB_MASTER} ${MONGODB_PORT} ${authflag} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi

}

#------------------------------
# domongodb_slave_start
# description: 调用ssh命令 登陆slave服务器启动mongodb
# return success 0, fail 1
#------------------------------
function domongodb_slave_start()
{

    if [ $# -ge 1 ]
    then 
        SLAVE_HOSTARR=$*
    else 
        SLAVE_HOSTARR=${MONGODB_SLAVE_ARR[@]}
    fi

    for i in ${SLAVE_HOSTARR[@]}
    do
        echo "$i start slave mongodb";

        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_start $i ${MONGODB_PORT} ${authflag}; \
            "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done
} 


#------------------------------
# domongodb_arbiter_start
# description: 调用ssh命令 登陆arbiter服务器启动mongodb
# return success 0, fail 1
#------------------------------
function domongodb_arbiter_start()
{

    if [ x"${MONGODB_ARBITER}" != x"" ]
    then 
        echo "start ${MONGODB_ARBITER} arbiter mongodb"

        ssh -p ${SSH_PORT} "${MONGODB_ARBITER}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_start ${MONGODB_ARBITER} ${MONGODB_PORT}  ${authflag} \
            "
        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res}; 
        fi
    fi
}

#------------------------------
# domongodb_start
# description: 根据传入的ip地址,调用domongodb_master_start,domongodb_slave_start,domongodb_arbiter_start
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function domongodb_start()
{
    args=$#
    #lastargs=${!args}
    firstargs=$1

    newstr=`tr '[A-Z]' '[a-z]' <<<"${firstargs}"`
    if [  x"${newstr}" == x"auth=true" ] #[ x"${newstr}" == x"false"  ]
    then 
        echo "auth=true";
        export authflag=true
        shift
    elif [ x"${newstr}" == x"auth=false"  ]
    then
        echo "auth=false"
        export authflag=false
        shift 
    fi

    if [ $# -ge 1 ]
    then

        #允许传入多个ip 地址
        until [ $# -eq 0 ]
        do 
            if [ x"$1" = x"${MONGODB_MASTER}" ]
            then
                domongodb_master_start 
                shift
                continue
            elif [ x"$1" = x"${MONGODB_ARBITER}" ]
            then
                domongodb_arbiter_start
                shift
                continue
            else 
                #判断是否需要启动slave 
                for i in ${MONGODB_SLAVE_ARR[@]} 
                do 
                    if [ x"$1" = x"$i" ]
                    then 
                        domongodb_slave_start
                        shift
                        continue
                    fi
                done
                
            fi

            shift 
        done


    else 
        domongodb_master_start 
        domongodb_slave_start 
        domongodb_arbiter_start
    fi

}


function domongodb_master_stop()
{

    echo "stop ${MONGODB_MASTER} master mongodb ";
    echo ""
    ssh -p ${SSH_PORT} "`echo ${MONGODB_MASTER}|cut -d: -f 1`" \
        " \
        cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_stop ${MONGODB_MASTER} ${MONGODB_DBPATH} \
        "
    res=$?
    if [ ${res} -ne 0 ] 
    then 
        exit ${res}; 
    fi
}

function domongodb_slave_stop()
{


    for i in ${MONGODB_SLAVE_ARR[@]}
    do
        echo "stop $i slave mongodb";
        echo ""
        ssh -p ${SSH_PORT} "`echo $i|cut -d: -f 1`" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_stop $i ${MONGODB_DBPATH}; \
            "
        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res};
        fi
    done
}

function domongodb_arbiter_stop()
{

    if [ x"${MONGODB_ARBITER}" != x"" ]
    then 
        echo "stop ${MONGODB_ARBITER} arbiter mongodb";

        ssh -p ${SSH_PORT} "`echo ${MONGODB_ARBITER}|cut -d: -f 1`" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_stop ${MONGODB_ARBITER} ${MONGODB_DBPATH} \
            "
        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res}; 
        fi
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

    if [ $# -ge 1 ]
    then
        #允许传入多个ip 地址
        until [ $# -eq 0 ]
        do 
            if [ x"$1" = x"${MONGODB_MASTER}" ]
            then
                domongodb_master_stop
                shift
                continue
            elif [ x"$1" = x"${MONGODB_ARBITER}" ]
            then
                domongodb_arbiter_stop
                shift
                continue
            else 
                #判断是否需要启动slave 
                for i in ${MONGODB_SLAVE_ARR[@]} 
                do 
                    if [ x"$1" = x"$i" ]
                    then 
                        domongodb_slave_stop
                        shift
                        continue
                    fi
                done
                
            fi
            shift 
        done


    else 
        domongodb_master_stop
        domongodb_slave_stop 
        domongodb_arbiter_stop
    fi

}


#------------------------------
# domongodb_cluster
# description: 调用ssh命令 登陆指定服务器集群部署
# return success 0, fail 1
#------------------------------
function domongodb_cluster()
{
    if [ x"${MONGODB_ARBITER}" != x"" ] 
    then 
        echo "domongodb_cluster";
        HOSTIP=`echo ${MONGODB_ARBITER}|cut -d: -f 1`
        echo ${HOSTIP}
        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_cluster ${HOSTIP}"
    fi
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


function domongodb_master_status()
{
    mongodb_status ${MONGODB_MASTER} ${MONGODB_PORT}
}

function domongodb_slave_status()
{

    for i in ${MONGODB_SLAVE_ARR[@]} 
    do
        mongodb_status $i ${MONGODB_PORT}
        echo ""
    done
}

function domongodb_arbiter_status()
{

    if [ x"${MONGODB_ARBITER}" != x"" ]
    then 
        mongodb_status ${MONGODB_ARBITER} ${MONGODB_PORT}
    fi
}

#------------------------------
# domongodb_status
# description: 查询mongodb运行状态
# return success 0, fail 1
#------------------------------
function domongodb_status()
{
    #rm -fr ${MONGODB_CHECK_LOG}
    cat /dev/null > ${MONGODB_CHECK_LOG}

    if [ $# -ge 1 ]
    then
        #允许传入多个ip 地址
        until [ $# -eq 0 ]
        do 
            if [ x"$1" = x"${MONGODB_MASTER}" ]
            then
                domongodb_master_status
                shift
                continue
            elif [ x"$1" = x"${MONGODB_ARBITER}" ]
            then
                domongodb_arbiter_status
                shift
                continue
            else 
                #判断是否需要启动slave 
                for i in ${MONGODB_SLAVE_ARR[@]} 
                do 
                    if [ x"$1" = x"$i" ]
                    then 
                        domongodb_slave_status
                        shift
                        continue
                    fi
                done
                
            fi
            shift 
        done

    else 
        domongodb_master_status
        domongodb_slave_status
        domongodb_arbiter_status
    fi
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
    PORT=$3
    AUTHFLAG=$4
    mongodb_start ${HOSTIP} ${PORT} ${AUTHFLAG}
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



if [ "$1" = mongodb_db_auth ]
then
    shift 
    HOSTIP=$1
    mongodb_db_auth ${HOSTIP}
fi
