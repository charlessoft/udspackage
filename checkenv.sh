#!/bin/bash 
source ./config

FILESSS="aa"
function checkfile()
{
    echo '检测安装环境:'
    echo ${checkfile[@]}
    for i in ${checkfile[@]}; do
        queryInfo="`which $i`"
        res=`echo $?`
        if [ "${res}" == "0" ]; then \
            echo "$i 安装"; \
        else
            echo "$i 未安装";
        fi
    done
}

checkfile
