#!/bin/bash 
source ./config

function checkenv()
{
    res=0
    echo "检测安装环境"
    echo '检测安装环境:'$1 > ${LOG};
    echo ${checkfile[@]}
    date "+%Y-%m-%d %X" >> ${LOG};
    for i in ${checkfile[@]}; do
        queryInfo="`which $i`"
        #res=`echo $?`
        #if [ "${res}" == "0" ]; then \
        if [ $? -eq 0 ]; then \
            echo "$i 安装" >> ${LOG}; \
        else
            echo "$i 未安装" >> ${LOG};
            echo "=====FAIL=====" >> ${LOG};
            let res=$res+1;
        fi
    done
    if [ $res -eq 0 ]; then \
        echo "=====SUCCESS=====" >> ${LOG};
    fi
}

function docheck()
{
    for i in ${RIAK_RINK[@]}; do
        ssh -p 22 "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh checkenv.sh checkenv $i; \
            exit;"
    done
}

function docollectres()
{
    echo "收集检测环境结果"
    for i in ${RIAK_RINK[@]}; do
        echo "scp -r $i:${LOG} ${LOG_COLLECT}$i"
        scp -r $i:${LOG} ${LOG_COLLECT}$i
        if [ $? -eq 1 ]; then \
            echo "收集$1 环境失败"; exit 1; \
        fi
    done 
}


function collectenvres()
{
    echo "收集检测环境结果:"$1
    for i in ${checkfile[@]}; do
        queryInfo="`which $i`"
        #res=`echo $?`
        #if [ "${res}" == "0" ]; then \
        if [ $? -eq 0 ]; then \
            echo "$i 安装" >> ${LOG}; \
        else
            echo "$i 未安装" >> ${LOG};
            echo "=====FAIL=====" >> ${LOG};
        fi
    done
    #echo ${RIAK_RINK[@]}
    #for i in ${RIAK_RINK[@]}; do
        #echo "scp -r $i:${LOG} ${LOG_COLLECT}$1"
        #scp -r $i:${LOG} ${LOG_COLLECT}$1
        ##if [ $? -eq 1 ]; then#echo "收集$i 环境失败"; exit 1;
        #fi
    #done

}

if [ "$1" = checkenv ] 
then 
    checkenv $2
fi 

if [ "$1" = echo_hello  ] 
then 
    echo_hello 
fi 
#checkenv
