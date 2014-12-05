#!/bin/bash 
. ./config

function generateEnvrpt()
{
    failcount=0;
    echo -e "        分析检测环境结果"
    echo "================================="
    cat /dev/null > ${LOG_MERGE};
    for i in ${RIAK_RINK[@]} 
    do
        #echo "cat ${LOG_COLLECT}$i >> ${LOG_MERGE}"
        cat ${LOG_COLLECT}$i >> ${LOG_MERGE};
        echo "-----------------------------------------" >> ${LOG_MERGE};
        success=`grep -rin "SUCCESS" ${LOG_COLLECT}$i`
        if [ x${success} != x'' ]; then \
            echo "目标环境 " $i " 可以安装riak"; \
        else 
            echo "目标环境 " $i " 缺少相关组件,无法安装riak !!!!!"; 
            let failcount=$failcount+1;
        fi
    done
    cat ${LOG_MERGE} 

    if [ ${failcount} -gt 0 ]; then \
        exit 1;
    fi

}


function generateinstalledRpt()
{
    echo -e "        installed status"
    sort log/test.tmp | while read line
do
    CURSERIP=`echo $line | awk '{print $1}' | awk -F: '{print $1}'`
    if [ x"$CURSERIP" != x"$PRESERIP" ] 
    then 
        PRESERIP=$CURSERIP 
        echo "-----${PRESERIP}-----";

    fi

    echo "$line" | grep -rinE "success|leader|follower" 2>&1 >/dev/null;
    if [ $? -eq 0 ] 
    then 
        cfont -green "$line\n" -reset; 
    else  
        cfont -red "$line\n" -reset;
    fi



done

}
