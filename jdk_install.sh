#!/bin/bash 
. ./config 

function jdk_install()
{
    HOSTIP=$1
    echo "$1 jdk_install";

    
    #echo ${CURPWD}
    #echo "ssss"
    #if [ ! -n "${JAVA_HOME}" ]; then
        #echo "jdk 路径为空,使用udspackage 当前路径";
        #export CURPWD=$(cd `dirname $0`; pwd)
        #export JAVA_HOME=${CURPWD}/${JDK_FILE}
        #export JAVA_BIN=${JAVA_HOME}/bin
    #else
        #export CURPWD=${JAVA_HOME}
    #fi

    if [ ! -d ${JDK_FILE} ] && [ -f ${JDK_FILE}.tar.gz ]; then \
        tar zxvf ${JDK_FILE}.tar.gz  2>&1 >/dev/null 
        if [ $? -ne 0 ]; then \
            echo "jdk 解压失败"; \
        else 
            echo "安装成功";
        fi 
    else 
        echo "jdk已经安装";
    fi
}

function dojdk_install()
{
    echo "dojdk_install";
    for i in ${JDK_ARR[@]};do 
        ssh -p "${SSH_PORT}" "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh jdk_install.sh jdk_install $i \
            "
        res=$?
        if [ ${res} -ne 0 ]; then \
            echo "$i jdk 安装失败";
            exit ${res};
        fi
    done
}




if [ "$1" = jdk_install ]
then 
    HOSTIP=$2
    echo "jdk_install====="
    jdk_install ${HOSTIP}
fi
