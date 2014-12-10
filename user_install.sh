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
        cfont -red "${HOSTIP} ${USERNAME}  user exist!!\n" -reset;  
    else 
        cfont -green "${HOSTIP} ${USERNAME} add user ${USERNAME}\n" -reset;

        useradd  -m -G root ${USERNAME};
        echo "${USERPWD}" | passwd --stdin ${USERNAME};
    fi

    grep -n "${USERNAME}.*ALL" /etc/sudoers >/dev/null 2>&1;
    if [ $? -ne 0 ] 
    then 
        #没写入到sudo表中
        sed -i '/root.*ALL/a'${USERNAME}'    ALL=(ALL)   ALL' /etc/sudoers

    fi 

}



#------------------------------
# douser_createuser
# description: 使用ssh 命令登陆到指定服务器 调用user_createuser创建用户
# return success 0, fail 1
#------------------------------
function douser_createuser()
{
    #构造数组
    inithostarray;
    if [ $# -ge 1 ] 
    then 
        HOSTARR=$*
    else
        HOSTARR=`sort ${HOSTARRAY_FILE} | uniq`;
    fi

    for i in ${HOSTARR[@]}; do \
        ssh -p ${SSH_PORT} "$i" \
        "cd ${UDSPACKAGE_PATH}; \
        source /etc/profile; \
        sh user_install.sh user_createuser $i 
        "
    done 

}


#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = user_createuser ]
then 
    HOSTIP=$2
    echo "user_createuser";
    user_createuser ${HOSTIP}
fi





