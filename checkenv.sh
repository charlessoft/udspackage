#!/bin/bash 
. ./config
. ./env.sh
. ./mongodb_install.sh
. ./report.sh

function checkenv()
{
    res=0
    echo 'check env :'$1 > ${LOG};
    echo ${checkfile[@]}
    date "+%Y-%m-%d %X" >> ${LOG};
    for i in ${checkfile[@]} 
    do
        queryInfo="`which $i`"
        #res=`echo $?`
        #if [ "${res}" == "0" ]; then \
        if [ $? -eq 0 ]; then \
            echo "$i installed " >> ${LOG}; \
        else
            echo "$i No such file!" >> ${LOG};
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
    for i in ${RIAK_RINK[@]} 
    do
        ssh -p "${SSH_PORT}" "$i" "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh checkenv.sh checkenv $i; \
            exit;"
    done
}

function docollectres()
{
    echo "collect check env result"
    for i in ${RIAK_RINK[@]} 
    do
        echo "scp -r $i:${LOG} ${LOG_COLLECT}$i"
        scp -r $i:${LOG} ${LOG_COLLECT}$i
        if [ $? -eq 1 ]; then \
            echo "collect $1 env result fail!"; exit 1; \
        fi
    done 
}


function collectenvres()
{
    for i in ${checkfile[@]} 
    do
        queryInfo="`which $i`"
        #res=`echo $?`
        #if [ "${res}" == "0" ]; then \
        if [ $? -eq 0 ]; then \
            echo "$i installed " >> ${LOG}; \
        else
            echo "$i No such file!" >> ${LOG};
            echo "=====FAIL=====" >> ${LOG};
        fi
    done

}

function docheckinstalledstatus()
{

    #rm -fr log/checktmp.log;
    cat /dev/null > log/checktmp.log

    for i in ${RIAK_RINK[@]} 
    do 
        echo $i
        curl http://${i}:${RIAK_HTTP_PORT} >/dev/null 2>&1;
        if [ $? -eq 0 ]; then \
            echo "${i} riak check http port ${RIAK_HTTP_PORT} success!" >> log/checktmp.log; \
        else 
            echo "${i} criak heck http port ${RIAK_HTTP_PORT} fail!" >> log/checktmp.log
        fi
    done 

    #检测是否加入到环中了
    

    #检测jdk 是否安装
    sh runsh.sh jdk status 

    #检测mongodb 端口 
    sh runsh.sh mongodb status  

    ###检测zookeeper 端口
    sh runsh.sh zookeeper status 


    ###检测riak
    cfont -yellow "check riak status ,please input the ${USER} password\n" -reset;
    sudo sh runsh.sh riak status

    sudo sh runsh.sh riak rink_status
    
    sh runsh.sh fscontent status 

    sh runsh.sh fsname status 

    sh runsh.sh fsmeta status 


    #mongodb 是检测端口,不需要重新检测
    #riak 需要检测端口
    #有CONTENT_SERVER 就需要有找回content log 
    scp ${CONTENT_SERVER}:${UDSPACKAGE_PATH}/${CONTENT_CHECK_LOG} \
        ./log/${CONTENT_SERVER}_contentservercheck.log


    scp ${NAME_SERVER}:${UDSPACKAGE_PATH}/${NAME_CHECK_LOG} \
        ./log/${NAME_SERVER}_nameservercheck.log


    scp ${META_SERVER}:${UDSPACKAGE_PATH}/${META_CHECK_LOG} \
        ./log/${META_SERVER}_metaservercheck.log


    cfont -green "collect riak log...\n" -reset;
    for i in ${RIAK_RINK[@]} 
    do 
        scp $i:${UDSPACKAGE_PATH}/log/riakcheck.log \
            ./log/${i}_riakcheck.log
    done 

    cfont -green "collect jdk log...\n" -reset;
    for i in ${JDK_ARR[@]} 
    do 
        scp $i:${UDSPACKAGE_PATH}/log/jdkcheck.log \
            ./log/${i}_jdkcheck.log
    done 


    cfont -green "collect zookeeper log...\n" -reset;
    for i in ${ZOOKEEPER_NODE_ARR[@]} 
    do 
        ZOOKEEPER_HOSTIP=`echo $i | awk -F= '{print $2}' | awk -F: '{print $1}'`
        scp ${ZOOKEEPER_HOSTIP}:${UDSPACKAGE_PATH}/log/zookcheck.log ./log/${ZOOKEEPER_HOSTIP}_zookcheck.log
    done 

    cd log && \
        cat /dev/null > contentservercheck.log
        find ./ -name "*.log" \
            -not -name "contentservercheck.log" \
            -not -name "fsname_log.log" \
            -not -name "fscontent_log.log" \
            -not -name "fsmeta_log.log" \
            -not -name "zookcheck.log" \
            -not -name "fsdeploy_mongodb_log.log" \
            -not -name "fsdeploy_zk_log.log" \
            -not -name "fsdeploy_zk_cluster_log.log" \
            -not -name "riakcheck.log" \
            -not -name "jdkcheck.log" \
            -not -name "mongodbclustertmp.log" \
            -not -name "contentserver.log" \
            -not -name "nameserver.log" \
            -not -name "metaserver.log" \
            -exec 'cat' {} \; > test.tmp;
    cd ../

    generateinstalledRpt



exit 1;
}




if [ "$1" = checkenv ] 
then 
    checkenv $2
fi 

if [ "$1" = checkjdk ]
then 
    HOSTIP=$2
    checkjdk ${HOSTIP}
fi
