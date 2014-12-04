#!/bin/bash 
. ./config 
. ./env.sh


#------------------------------
# jdk_install
# description: 解压jdk 
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function jdk_install()
{
    HOSTIP=$1
    echo "$1 jdk_install...";

    if [ ! -d ${JDK_FILE} ] 
    then 
        if [ -f ${JDK_FILE}.tar.gz ] 
        then 
            tar zxvf ${JDK_FILE}.tar.gz -C ./bin 2>&1 >/dev/null; 
            if [ $? -ne 0 ] 
            then 
                cfont -red "jdk install fail!\n" -reset; 
            else 
                cfont -green "jdk install success!\n" -reset; 
            fi  
        else 
            cfont -red "${JDK_FILE} No such file!\n" -reset;  
            exit 1;
        fi 
    else  
        cfont -green "jdk already installed!\n" -reset; 
    fi
}

#------------------------------
# jdk_uninstall 
# description: 卸载jdk
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function jdk_uninstall()
{
    HOSTIP=$1
    echo "$1 jdk_uninstall...";

    #echo ${JDK_FILE};
    test -d ${JDK_FILE} && rm -fr ${JDK_FILE}
    if [ $? -eq 0 ]
    then 
        cfont -green "uninstall success!\n" -reset;
    else
        cfont -red "uninstall fail!\n" -reset;
    fi
}


#------------------------------
# jdk_status
# description: 查询jdk 状态
# params HOSTIP - ip address 
# return success 0, fail 1
#------------------------------
function jdk_status()
{

    HOSTIP=$1
    initenv ${HOSTIP}
    if [ $? -eq 0 ] 
    then 
        cfont -green;
        java -version;
        cfont -reset;
        echo "${HOSTIP} jdk check success!" > ${JDK_CHECK_LOG};
    else 
        echo "${HOSTIP} jdk check fail!" > ${JDK_CHECK_LOG};
    fi

    echo "";
}


#------------------------------
# dojdk_install
# description: 使用ssh命令登陆服务器,调用jdk_install 解压jdk
# return success 0, fail 1
#------------------------------
function dojdk_install()
{
    if [ $# -ge 1 ] 
    then 
        JDK_HOSTARR=$*
    else
        JDK_HOSTARR=${JDK_ARR[@]}
    fi

    for i in ${JDK_HOSTARR[@]};do 
        ssh -p "${SSH_PORT}" "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh jdk_install.sh jdk_install $i \
            "
    done
}

#------------------------------
# dojdk_uninstall
# description: 使用ssh命令登陆服务器,调用jdk_install 删除jdk
# return success 0, fail 1
#------------------------------
function dojdk_uninstall()
{
    if [ $# -ge 1 ]
    then 
        JDK_HOSTARR=$*
    else 
        JDK_HOSTARR=${JDK_ARR[@]}
    fi

    for i in ${JDK_HOSTARR[@]};do 
        ssh -p "${SSH_PORT}" "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh jdk_install.sh jdk_uninstall $i \
            "
    done
}


#------------------------------
# dojdk_status
# description:  使用ssh命令登陆服务器,调用jdk_status 查询jdk 安装状态
# return success 0, fail 1
#------------------------------
function dojdk_status()
{

    if [ $# -ge 1 ] 
    then 
        JDK_HOSTARR=$*
    else
        JDK_HOSTARR=${JDK_ARR[@]}
    fi

    for i in ${JDK_HOSTARR[@]}; do 
        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh jdk_install.sh jdk_status $i"
    done
}





#-------------------------------
#根据传递的参数执行命令
#-------------------------------
if [ "$1" = jdk_install ]
then 
    HOSTIP=$2
    jdk_install ${HOSTIP}
fi


if [ "$1" = jdk_status ]
then 
    HOSTIP=$2
    jdk_status ${HOSTIP}
fi

if [ "$1" = jdk_uninstall ]
then 
    HOSTIP=$2
    jdk_uninstall ${HOSTIP}
fi


