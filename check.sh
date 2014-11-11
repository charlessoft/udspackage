#!/bin/bash 
source ./config

FILESSS="aa"
function checkfile()
{
    echo ${checkfile[@]}
    for i in ${checkfile[@]}; do
        #queryInfo=`rpm -q $i`
        #echo $queryInfo
        #if [ x"$queryInfo" == x"package $i is not installed" ]; then \
            #echo "no"; \
        #else 
            #echo "ok"; \
            #fi
        queryInfo="`which $i | xargs grep -rin ":"`"
        echo ${queryInfo}
        #if [ "${queryInfo}" == x'' ]; then \
            #echo "ok"; \
        #else
            #echo "nu";
        #fi
    done
}

checkfile
