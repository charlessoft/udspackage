#!/bin/bash 
#sh copy.sh 10.211.55.19
#sh copy.sh 10.211.55.20
#sh copy.sh centos
source ./config
#1:generate slave install shell 

function generateShell()
{
    echo "生成各台安装脚本"
    echo ${RIAK_RINK[@]}
    for i in ${RIAK_RINK[@]}; do
        #echo $i
        cp modify.sh modify_$i.sh
        res=`echo $?`
        if [ ${res} == "0" ]; then \
            sed -i "s/TEMP_IPHOST/$i/g" modify_$i.sh
        else 
            echo "no";
        fi
    done

}
generateShell




