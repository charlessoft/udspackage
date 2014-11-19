#!/bin/bash 
. ./config 

function zk_install()
{
    echo "zk_install..."
    tar zxvf ${ZOOKEEPER_FILE}.tar.gz;

}

function dozk_install()
{
    echo "dozk_install..."
    for i in ${ZOOKEEPER_ARR[@]};do 
        ssh -p ${SSH_PORT} "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh zk_install.sh zk_install $i \
            "
    done
}


function zk_start()
{
    echo "zk_start..."
}

function zk_stop()
{
    echo "zk_stop...";
}




if [ "$1" = zk_install ]
then 
    echo "zk_install ====="
    zk_install $2
fi
