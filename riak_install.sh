#!/bin/bash 
. ./config
. ./env.sh

export RIAK_FILE=bin/${RIAK_FILE}

#------------------------------
# riak install
# params HOSTIP- ip address 
# return success 0, fail 1
#------------------------------
function riak_install()
{
    HOSTIP=$1;
    echo "${HOSTIP} install Riak";
    `which riak` > /dev/null;
    if [ $? -ne 0  ] 
    then 
        cfont -green "begin install riak ...\n" -reset; 
        if [ -f ${RIAK_FILE} ] 
        then 
            rpm -ivh ${RIAK_FILE}; 
        else
            cfont -red "${RIAK_FILE} No such file!\n" -reset; exit 1;
        fi
    else 
        cfont -red "already installed " `rpm -q riak` "\n" -reset;
    fi
    sh riak_patch.sh $1

}

#------------------------------
# riak unstall
# description: 卸载riak
# return default
#------------------------------
function riak_unstall()
{
    echo "$1 卸载riak";
    riak stop;
    rpm -e `rpm -q riak | awk 'NR==1'`;
}

#------------------------------
# riak start
# params HOSTIP- ip address 
# return success 0, fail 1
#------------------------------
function riak_start()
{
    HOSTIP=$1;
    res=0;
    `which riak` > /dev/null;
    if [ $? -ne 0  ] 
    then 
        exit 1; 
    fi

    #用riak ping 得不到内容,改用getpid
    pid=`riak getpid | awk '{print $1}'`
    cfont -green "${HOSTIP} pid:${pid}\n" -reset;

    if [ "${pid}" == "Node" ] 
    then 
        cfont -green "start riak...\n" -reset;
        riak start
        if [ $? -eq 0 ] 
        then 
            cfont -green "start success!\n" -reset; 
        else
            cfont -red "${HOSTIP} riak fail!\n" -reset;
            res=1;
        fi
    else 
        echo "already running.....restart riak...";

        riak stop
        riak start
        if [ $? -eq 0 ]
        then 
            pid=`riak getpid | awk '{print $1}'`;
            echo "Riak pid: ${pid}"; 
            cfont -green "restart success!\n" -reset; 
        else
            cfont -red "${HOSTIP} riak restart fail!\n" -reset; 
            res=1;
        fi

        #riak-admin cluster join riak@

    fi

}

#------------------------------
# riak stop
# params HOSTIP- ip address 
# return success 0, fail 1
#------------------------------
function riak_stop()
{
    HOSTIP=$1;
    service riak stop;
    res=$?;
    if [ ${res} -ne 0 ] 
    then 
        cfont -red "${HOSTIP} riak stop fail!\n" -reset;  
    fi
    return ${res};
}


#------------------------------
# riak status 
# @params HOSTIP- ip address 
# @return success 0, fail 1
#------------------------------
function riak_status()
{
    HOSTIP=$1;
    service riak status;
    res=$?;
    if [ ${res} -eq 0 ] 
    then 
        cfont -green "${HOSTIP} riak check success!\n" -reset; > ${RIAK_CHECK_LOG}; 
    else  
        cfont -red "${HOSTIP} riak check fail!\n" -reset; > ${RIAK_CHECK_LOG};
    fi
    return ${res};
 


}

#------------------------------
# riak joinring 集群 加入到riak 集群环中 
# @params HOSTIP- ip address 
# @return success 0, fail 1
#------------------------------
function riak_joinring()
{
    HOSTIP=$1;
    echo "${HOSTIP} joinring ${RIAK_FIRST_NODE}"
    if [ "${HOSTIP}" != "${RIAK_FIRST_NODE}" ] 
    then 
        echo "$1 joing ${RIAK_FIRST_NODE}"
        echo "riak-admin status | grep member | grep -rin "${RIAK_FIRST_NODE}""
        riak-admin status | grep member | grep -rin "${RIAK_FIRST_NODE}"

        if [ $? -ne 0 ] 
        then 
            echo "riak-admin cluster join riak@${RIAK_FIRST_NODE};"
            riak-admin cluster join riak@${RIAK_FIRST_NODE};

            if [ $? -eq 0 ] 
            then 
                cfont -green "$1 join ${RIAK_FIRST_NODE} success!\n" -reset;
            else 
                cfont -red "$1 join ${RIAK_FIRST_NODE} fail!\n" -reset;
                exit 1;
            fi
        else 
            cfont -green "$1 already join the ring\n" -reset;
        fi
    fi
}

#------------------------------
# riak commit
# description: 提交对riak集群做的修改操作 (riak-admin cluster commit)
# return success 0 ,fail 1
#------------------------------
function riak_commit()
{

    riak-admin cluster plan 
    riak-admin cluster commit 
    riak-admin bucket-type create uds_fs_no_mult '{"props":{"allow_mult":false, "last_write_wins":true}}'
    riak-admin bucket-type activate uds_fs_no_mult
    riak-admin bucket-type list 

}

#------------------------------
# riak riak_rink_status
# description: 通过riak-admin status | grep member 查询环中成员
# return success 0 ,fail 1
#------------------------------
function riak_rink_status()
{
    HOSTIP=$1;
    RINKMEMBER=`riak-admin status | grep member`;
    res=0;
    #判断riak 节点是否再 查询状态中
    for i in ${RIAK_RINK[@]}; do 
        echo $RINKMEMBER | grep -rin "$i" >/dev/null 2>&1;
        if [ $? -ne 0 ]; then \
            res=1
        fi
    done 


    if [ ${res} -eq 0 ]
    then 
        cfont -green "${RINKMEMBER}\n" -reset;
        echo "${RIAK_FIRST_NODE} riak rink check success! ${RINKMEMBER}" >> ${RIAK_CHECK_LOG};
    else 
        cfont -red "not full riak node in the ${RINKMEMBER}\n" -reset;
        echo "${RIAK_FIRST_NODE} riak rink check fail! ${RINKMEMBER}" >> ${RIAK_CHECK_LOG};
    fi

} 







#------------------------------
# riak doriak_install
# description: 通过ssh命令进入指定riak服务器, 安装riak服务
# return success 0 ,fail 1
#------------------------------
function doriak_install()
{
    for i in ${RIAK_RINK[@]}; do
        echo "$i install Riak";

        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
           source /etc/profile; \
           sh riak_install.sh riak_install $i; \
           "

        res=$?
        if [ ${res} -ne 0 ] 
        then 
            exit ${res};
        fi
    done
}

#------------------------------
# riak doriak_unstall
# description: 通过ssh命令进入指定riak服务器,卸载riak
# return success 0 ,fail 1
#------------------------------
function doriak_unstall()
{
    for i in ${RIAK_RINK[@]}; do
        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_unstall $i"
    done
}

#------------------------------
# riak doriak_start
# description: 通过ssh命令进入指定riak服务器,启动riak
# return success 0 ,fail 1
#------------------------------
function doriak_start()
{
    echo "start Riak"
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_start $i \
            "
        if [ $? -ne 0 ] 
        then 
            cfont -red "$i riak start fail $1\n" -reset;
            exit 1;
                
        fi
    done

    sleep 10s
}


#------------------------------
# riak doriak_stop
# description: 通过ssh命令进入指定riak服务器,停止riak服务
# return success 0 ,fail 1
#------------------------------
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


#------------------------------
# riak doriak_status  
# description: 通过ssh命令进入指定riak服务器查询riak当前状态
# return success 0 ,fail 1
#------------------------------
function doriak_status()
{
    echo "Riak status";
    for i in ${RIAK_RINK[@]}; do 
        ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_status $i \
            "

        if [ $? -ne 0 ] 
        then 
            cfont -red "query status fail $1\n" -reset;
        fi
    done

}

#------------------------------
# riak doriak_joinring
# description: 通过ssh命令进入指定riak服务器,加入节点到集群中
# return success 0 ,fail 1
#------------------------------
function doriak_joinring()
{
    for i in ${RIAK_RINK[@]}; do 
        echo $i
        echo "curl http://$i:${RIAK_HTTP_PORT}";
        curl http://$i:${RIAK_HTTP_PORT} &> /dev/null;
        res=$?;
        if [ ${res} -ne 0 ] 
        then 
            cfont -red "Riak curl network check fail!\n" -reset;
            exit $?;
        fi

        cfont -green "$i Riak network check success,join the ring\n" -reset; \
            ssh -p ${SSH_PORT} "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh riak_install.sh riak_joinring $i"

        res=$?;
        if [ ${res} -ne 0 ] 
        then 
            cfont -red "cluster join fail ${res}\n" -reset;
            exit ${res};
        fi
        
    done

}



#------------------------------
# riak doriak_rink_status
# description: 通过ssh命令进入指定riak服务器, 查询环中成员
# return success 0 ,fail 1
#------------------------------
function doriak_rink_status()
{
    ssh -p ${SSH_PORT} "${RIAK_FIRST_NODE}" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh riak_install.sh riak_rink_status ${RIAK_FIRST_NODE}"

}

#------------------------------
# riak doriak_commit
# description: 通过ssh命令进入指定riak服务器,提交对riak集群修改
# return success 0 ,fail 1
#------------------------------
function doriak_commit()
{
    echo "commit Riak"

    ssh -p ${SSH_PORT} "${RIAK_FIRST_NODE}" "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh riak_install.sh riak_commit ${RIAK_FIRST_NODE}; \
        "
}






#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = riak_install ] 
then 
    HOSTIP=$2;
    echo "install Riak";
    riak_install ${HOSTIP};
fi 

if [ "$1" = riak_joinring ]
then
    HOSTIP=$2;
    echo "riak_joinring";
    riak_joinring ${HOSTIP};
fi

if [ "$1" = riak_start ]
then 
    HOSTIP=$2;
    echo "riak start..." 
    riak_start ${HOSTIP};
fi

if [ "$1" = riak_commit ]
then 
    HOSTIP=$2;
    echo "riak_commit ...";
    riak_commit ${HOSTIP};
fi

if [ "$1" = riak_unstall ]
then 
    HOSTIP=$2;
    echo "riak_unstall..."; 
    riak_unstall ${HOSTIP};
fi


if [ "$1" = riak_status ]
then 
    HOSTIP=$2;
    echo "riak_status...";
    riak_status ${HOSTIP};
fi


if [ "$1" = riak_stop ]
then 
    HOSTIP=$2;
    echo "riak_stop..."; 
    riak_stop ${HOSTIP};
fi


if [ "$1" = riak_rink_status ]
then 
    HOSTIP=$2;
    echo "riak_rink_status..."; 
    riak_rink_status ${HOSTIP};
fi


