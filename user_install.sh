#!/bin/bash 
. ./config 
. ./env.sh


#------------------------------
# user_createuser
# description: 创建用户
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function user_createuser()
{
    HOSTIP=$1;
    `id ${USERNAME} &>/dev/null`;
    if [ $? -eq 0 ] 
    then 
        cfont -red "user exist!!\n" -reset;  
    else 
        cfont -green "add user ${USERNAME}\n" -reset;

        useradd ${USERNAME} -G root;
        echo "${USERPWD}" | passwd --stdin ${USERNAME};
    fi

    grep -n "${USERNAME}.*ALL" /etc/sudoers >/dev/null 2>&1;
    if [ $? -ne 0 ] 
    then 
        #没写入到sudo表中

        LINE=`grep -n "root.*ALL" /etc/sudoers | awk -F: '{print $1}'`;
        if [ x${LINE} = x"" ] 
        then 
            echo "not found root from /etc/sudoers"; 
        else 
            sed -i ''${LINE}'a'${USERNAME}'    ALL=(ALL)   ALL' /etc/sudoers 

        fi
    fi 

}



#------------------------------
# douser_createuser
# description: 使用ssh 命令登陆到指定服务器 调用user_createuser创建用户
# return success 0, fail 1
#------------------------------
function douser_createuser()
{
    echo "create user";
    mergehostarray

    HOSTARR=`sort ${HOSTARRAY} | uniq`;
    for i in ${HOSTARR[@]}; do \
        ssh -p ${SSH_PORT} "$i" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh user_install.sh user_createuser $i 
        "
    done 

}

function douser_mytest()
{
    
    HOSTARR=`sort ${HOSTARRAY} | uniq`;
    for i in ${HOSTARR[@]}; do \
        ssh -p ${SSH_PORT} -l ${USERNAME} "$i" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh user_install.sh mytest $i"
    done 
}

if [ "$1" = user_createuser ]
then 
    HOSTIP=$2
    echo "user_createuser";
    user_createuser ${HOSTIP}
fi

if [ "$1" = mytest ]
then 
    HOSTIP=$2
    #echo "user_createuser ====="
    #user_createuser ${HOSTIP}
    touch /tmp/mytest
fi
#user_createuser 10.211.55.18




