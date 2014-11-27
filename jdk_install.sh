#!/bin/bash 
. ./config 
. ./env.sh

function jdk_install()
{
    HOSTIP=$1
    echo "$1 jdk_install...";

    if [ ! -d ${JDK_FILE} ] && [ -f ${JDK_FILE}.tar.gz ]; then \
        tar zxvf ${JDK_FILE}.tar.gz -C ./bin 2>&1 >/dev/null 
        if [ $? -ne 0 ]; then \
            cfont -red "jdk install fail!\n" -reset; \
        else 
            cfont -green "jdk install success!\n" -reset;
        fi 
    else 
        cfont -green "jdk already installed!\n" -reset;
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
    done
}

function dojdk_status()
{
    for i in ${JDK_ARR[@]}; do 
        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh jdk_install.sh jdk_status $i"
    done
}


function jdk_status()
{

    HOSTIP=$1
    initenv ${HOSTIP}
    if [ $? -eq 0 ]; then \
        cfont -green 
        java -version 
        cfont -reset
        echo "${HOSTIP} jdk check success!" > ${JDK_CHECK_LOG}
    else 
        echo "${HOSTIP} jdk check fail!" > ${JDK_CHECK_LOG}
    fi

    echo ""
}



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


