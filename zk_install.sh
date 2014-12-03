#!/bin/bash 
. ./config 
. ./env.sh
export ZOOKEEPER_FILE=bin/${ZOOKEEPER_FILE}
export ZOOKEEPER_TMPLOG=${UDSPACKAGE_PATH}/tmp/zktmp.log

#------------------------------
# zk_init
# description: 构造zookeeper数组
# return success 0, fail 1
#------------------------------
function zk_init()
{
    #构造需要执行zookeper命令的HOST 数组
    if [ $# -ge 1 ] 
    then 
        ZKHOST=$*
        nindex=0;
        #端口号 需要zookeeper 数组中查找到对应的ip
        for i in ${ZKHOST[@]} 
        do 
            for j in ${ZOOKEEPER_NODE_ARR[@]}
            do
                echo $j | grep -rin "$i"  >/dev/null 2>&1;
                if [ $? -eq 0 ] 
                then 
                    ZOOKEEPER_HOSTARR[$nindex]=$j;
                    let nindex=$nindex+1;
                fi
            done 
        done 

    else
        ZOOKEEPER_HOSTARR=${ZOOKEEPER_NODE_ARR[@]};
    fi
    export ZOOKEEPER_HOSTARR
}
#------------------------------
# zk_install
# description: 解压zookeeper
# params HOSTIP - ip address 
# params MYID - zookeeper pid
# return success 0, fail 1
#------------------------------
function zk_install()
{

    HOSTIP=$1
    MYID=$2
    echo "${HOSTIP}:${MYID} zk_install...";

    if [  ! -d ${ZOOKEEPER_FILE} ] 
       
    then 
        if [ -f ${ZOOKEEPER_FILE}.tar.gz  ] 
        then
            tar zxvf ${ZOOKEEPER_FILE}.tar.gz -C ./bin 2>&1 >/dev/null;
            if [ $? -ne 0 ] 
            then 
                cfont -red "zookeeper install fail!\n" -reset; 
            else 
                cfont -green "zookeeper install success!\n" -reset;
            fi 
        else
            cfont -red "${ZOOKEEPER_FILE} No such file!\n" -reset;  
            exit 1;
        fi
    else 
        cfont -green "zookeeper already installed!\n" -reset;
    fi

    #echo "cp ./zoo_${HOSTIP}.cfg  ./${ZOOKEEPER_FILE}/conf/zoo.cfg";
    if [ ! -f ./zoo_${HOSTIP}.cfg ] 
    then 
        cfont -red "zoo_${HOSTIP}.cfg No such file!\n" --reset; exit 1;
    fi

    cp ./zoo_${HOSTIP}.cfg  ./${ZOOKEEPER_FILE}/conf/zoo.cfg;
    mkdir ${ZOOKEEPER_DATADIR} -p;
    mkdir ${ZOOKEEPER_LOGDIR} -p;
    echo "${MYID}" > ${ZOOKEEPER_DATADIR}/myid;

}



#------------------------------
# zk_start
# description: 启动zookeeper
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function zk_start()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_start...";
    
    initenv ${HOSTIP}
    if [ $? -ne 0 ]
    then 
        return 1;
    fi

    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh start > tmp.log
        sleep 3s;
        cfont -green 
        echo `cat tmp.log`;
        cfont -reset
    cd ../../

}

#------------------------------
# zk_stop
# description: 停止zookeeper
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function zk_stop()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_stop...";
    initenv ${HOSTIP}
    cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh stop > tmp.log
        sleep 2s;
        cfont -green 
        echo `cat tmp.log`; 
        cfont -reset;

    cd ../../;
}


#------------------------------
# zk_destroy
# description: 删除zookeeper
# params HOSTIP - ip address 
# return success 0, fail 1
# node: 可能不用
#------------------------------
function zk_destroy()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_destroy";

    zk_stop 
    echo ${PWD}
    echo "rm -fr ${ZOOKEEPER_DATADIR}"
    echo "rm -fr ${ZOOKEEPER_LOGDIR}"
    echo "rm -fr ${ZOOKEEPER_FILE}"
    rm -fr ${ZOOKEEPER_DATADIR};
    echo "RESSS=$?"

    rm -fr ${ZOOKEEPER_LOGDIR}
    echo "RESSS=$?"

    rm -fr ${ZOOKEEPER_FILE}
    echo "RESSS=$?"
}


#------------------------------
# dozk_destroy
# description: 使用ssh 命令登陆到指定服务器删除zookeeper
# return success 0, fail 1
# node: 可能不用
#------------------------------
function dozk_destroy()
{

    echo "dozk_destroy..."
    for i in ${ZOOKEEPER_NODE_ARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`
        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_destroy ${HOSTIP} ${MYID} \
            "
    done
}


#------------------------------
# zk_log
# description: 收集zookeeper.out 日志
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function zk_log()
{
    HOSTIP=$1
    echo "${HOSTIP} collect zookeeper log";
    echo "scp ${HOSTIP}:${UDSPACKAGE_PATH}/${ZOOKEEPER_FILE}/zookeeper.out ./log/";
    scp ${HOSTIP}:${UDSPACKAGE_PATH}/${ZOOKEEPER_FILE}/zookeeper.out ./log/${HOSTIP}_zookeeper.out 

    if [ $? -eq 0 ] 
    then 
        cfont -green "collect zookeeper log success!\n" -reset ;
else 
    cfont -red "collecg zookeeper log fail!\n" -reset;
   fi
}


#------------------------------
# dozk_log
# description:  使用ssh 命令登陆到指定服务器收集log
# return success 0, fail 1
#------------------------------
function dozk_log()
{
    echo "dozk_collect log";
    
    zk_init $@
    for i in ${ZOOKEEPER_HOSTARR[@]}; do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`
        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_log ${HOSTIP} \
            "
    done

}


#------------------------------
# zk_status
# description: 获取zookeeper运行状态
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function zk_status()
{
    HOSTIP=$1
    echo "${HOSTIP} zk_status...";
    initenv ${HOSTIP};

    if [ -d ${ZOOKEEPER_FILE}/bin ] 
    then 
        cd ${ZOOKEEPER_FILE}/bin && \
        sh ./zkServer.sh status > ${ZOOKEEPER_TMPLOG}
        sleep 2s;
        grep -rin "error" ${ZOOKEEPER_TMPLOG} 2>&1 >/dev/null;

        if [ $? -eq 0 ] 
        then 
            cfont -red
            echo `cat ${ZOOKEEPER_TMPLOG}`
            cfont -reset
        else 
            cfont -green 
            echo `cat ${ZOOKEEPER_TMPLOG}`
            cfont -reset
        fi
        cd ../../../;
        sed -e 's/\(.*\)/'${HOSTIP}' zookeeper \1/g' ${ZOOKEEPER_TMPLOG} > ${ZOOKEEPER_CHECK_LOG};
    else 
        echo "${HOSTIP} zookeeper check fail!" > ${ZOOKEEPER_CHECK_LOG};
    fi
}



#------------------------------
# dozk_install
# description: 使用ssh 命令登陆到指定服务器调用zk_install 解压zookeeper
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dozk_install()
{
    echo "dozk_install..."
    
    zk_init $@
    #解压zookeeper 
    for i in ${ZOOKEEPER_HOSTARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`;
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`;

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_install ${HOSTIP} ${MYID} \
            "
    done
}


#------------------------------
# dozk_start
# description: 使用ssh 命令登陆到指定服务器调用 zk_start 启动zookeeper
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dozk_start()
{
    
    zk_init $@
    for i in ${ZOOKEEPER_HOSTARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`;
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`;

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_start ${HOSTIP} \
            "
        if [ $? -ne 0 ]
        then 
            exit 1;
        fi
    done
}


#------------------------------
# dozk_stop 
# description: 使用ssh 命令登陆到指定服务器 嗲用zk_stop停止zookeeper
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dozk_stop()
{

    zk_init $@
    for i in ${ZOOKEEPER_HOSTARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`;
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`;

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_stop ${HOSTIP} \
            "
    done
}



#------------------------------
# dozk_status
# description: 使用ssh 命令登陆到指定服务器 调用zk_status 查询zookeeper 运行状态
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function dozk_status()
{

    zk_init $@
    for i in ${ZOOKEEPER_HOSTARR[@]};do 
        MYID=`echo $i | awk -F= '{print $1}'| \
            awk -F\. '{print $2}'`;
        HOSTIP=`echo $i | awk -F= '{print $2}' | \
            awk -F: '{print $1}'`;

        ssh -p ${SSH_PORT} "${HOSTIP}" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_status ${HOSTIP} \
            "
    done
}



#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = zk_install ]
then 
    HOSTIP=$2
    MYID=$3
    zk_install ${HOSTIP} ${MYID}
fi

if [ "$1" = zk_start ]
then 
    HOSTIP=$2
    zk_start ${HOSTIP} 
fi


if [ "$1" = zk_status ]
then 
    HOSTIP=$2
    zk_status ${HOSTIP} 
fi



if [ "$1" = zk_stop ]
then 
    HOSTIP=$2
    zk_stop ${HOSTIP} 
fi


if [ "$1" = zk_destroy ]
then 
    echo "zk_destroy ====="
    HOSTIP=$2
    zk_destroy ${HOSTIP} 
fi

if [ "$1" = zk_log ]
then 
    echo "zk_log====="
    HOSTIP=$2
    zk_log ${HOSTIP} 
fi
