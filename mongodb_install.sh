#!/bin/bash 
. ./config 
. ./env.sh
function mongodb_status()
{
    HOSTIP=$1
    echo "check ${HOSTIP} mongodb whether is running";
    curl http://${HOSTIP} &> /dev/null 
    res=$?
    #echo "curl return ${res}";
    if [ ${res} -ne 0 ]; then \
        cfont -red "mongodb curl network check fail! res=${res}\n" -reset;
        return ${res}; \
    else 
        cfont -green "mongodb curl network check successfully ,mongodb is running! res=${res}\n" -reset;
    fi

}

function mongodb_init()
{
    HOSTIP=$1
    echo "init ${HOSTIP} mongodb ";

    if [ "${HOSTIP}" = "${MONGODB_MASTER}" ]; then \
        echo "create mongodb master data folder";
        mongodb_mkdir_master
    fi

    #if [ "$1" = "${MONGODB_}"]
    echo ${MONGODB_SLAVE_ARR[*]} | grep -E "\<${HOSTIP}\>" 2>&1 > /dev/null 
    if [ $? -eq 0 ]; then \
        echo "create mongodb slave data folder"; \
        mongodb_mkdir_slave
    fi

    if [ "${HOSTIP}" = "${MONGODB_ARBITER}" ]; then \
        #echo "mongodb_mkdir_arbiter";
        echo "create mongodb arbiter folder"
        mongodb_mkdir_arbiter
    fi 
}

function mongodb_install()
{
    HOSTIP=$1;
    echo "HOSTIP} install mongodb";
    
    if [ ! -d ${MONGODB_FILE} ] && [ -f ${MONGODB_FILE}.gz ]; then \
        tar zxvf ${MONGODB_FILE}.gz -C ./bin 2>&1 >/dev/null; \
        if [ $? -ne 0 ]; then \
            cfont -red "mongodb unzip fail\n" -reset; \
        else 
            cfont -green "mongodb unzip successfully!\n" -reset;
        fi 
    else \
        cfont -green "mongodb is already installed!\n" -reset;
    fi

}


function mongodb_cluster()
{
    HOSTIP=$1
    echo "${HOSTIP} cluster"
    if [ -d ${MONGODB_FILE} ]; then \
        cd ${MONGODB_FILE}/bin; \
        ./mongo ../../../mongodb_cluster.js; \
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
}

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
    echo "${HOSTIP} start mongodb ";

    mongodb_status ${HOSTIP}
    if [ $? -ne 0 ]; then \
        if [ -d ${MONGODB_FILE} ]; then \
            cd ${MONGODB_FILE}/bin; \
            ./mongod -f ../../../mongodb_${HOSTIP}.conf > tmp.log;  \
            cfont -green ""
            echo `cat tmp.log`; \
            cfont -reset; \
            cd ../../../;
        else 
            cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset ;
            exit 1;
        fi
    else 
        cfont -green "${HOSTIP} mongodb is running!\n" -reset;
    fi
    
    
}

function mongodb_stop()
{
    HOSTIP=$1
    DBPATH=$2
    echo "${HOSTIP}:${DBPATH}"
    if [ -d ${MONGODB_FILE} ]; then \
        cd ${MONGODB_FILE}/bin; \
        ./mongod --shutdown --dbpath ${DBPATH} ;\
        sleep 3s;
        if [ $? -eq 0 ]; then \
            cfont -green "stop mongod successfully!\n" -reset;
        fi
    else 
        cfont -red "mongodb ${MONGODB_FILE} No such file!\n" -reset;
        exit 1;
    fi
}

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
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
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
        if [ ${res} -ne 0 ]; then 
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
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi
}


function domongodb_status()
{
    mongodb_status ${MONGODB_MASTER}
    echo ""
    for i in ${MONGODB_SLAVE_ARR[@]}; do
        mongodb_status $i
        echo ""
    done
    echo "" 

    mongodb_status ${MONGODB_ARBITER}
    echo ""
}

function domongodb_start()
{
    echo "start master mongodb ";
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
        echo "start $i slave mongodb";

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


    echo "start ${MONGODB_ARBITER} arbiter mongodb"

    ssh -p ${SSH_PORT} "`echo ${MONGODB_ARBITER}|cut -d: -f 1`" \
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

function domongodb_install()
{
    #安装 master
    ssh -p ${SSH_PORT} "`echo ${MONGODB_MASTER}|cut -d: -f 1`" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_install ${MONGODB_MASTER} \
        "
    res=$?
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi

    #安装slave
    for i in ${MONGODB_SLAVE_ARR[@]}; do
        #echo "$i安装 slave mongodb"

        ssh -p ${SSH_PORT} "`echo $i|cut -d: -f 1`" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh mongodb_install.sh mongodb_install $i; \
            "
        res=$?
        if [ ${res} -ne 0 ]; then 
            exit ${res};
        fi
    done

    #echo "${MONGODB_ARBITER} 安装 arbiter mongodb"
    ssh -p ${SSH_PORT} "`echo ${MONGODB_ARBITER}|cut -d: -f 1`" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh mongodb_install.sh mongodb_install ${MONGODB_ARBITER} \
        "
    res=$?
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi
}

export MONGODB_FILE=bin/${MONGODB_FILE}

if [ "$1" = mongodb_install ]
then 
    HOSTIP=$2
    mongodb_init ${HOSTIP}
    mongodb_install ${HOSTIP}
fi


if [ "$1" = mongodb_cluster ]
then 
    echo "mongodb_cluster ====="
    HOSTIP=$2
    mongodb_cluster ${HOSTIP}
fi

if [ "$1" = mongodb_start ]
then
    HOSTIP=$2
    #临时增加测试
    mongodb_init ${HOSTIP}
    #临时增加测试
    mongodb_start ${HOSTIP}
fi

if [ "$1" = mongodb_status ]
then
    shift 
    HOSTIP=$1
    mongodb_status ${HOSTIP}
fi


if [ "$1" = mongodb_stop ]
then
    shift 
    HOSTIP=$1
    DBPATH=$2
    mongodb_stop ${HOSTIP} ${DBPATH}
fi
