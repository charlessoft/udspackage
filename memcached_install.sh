#!/bin/bash 
. ./config 
. ./env.sh

#export MEMCACHED_FILE=bin/${MEMCACHED_FILE}
#export LIBEVENT_FILE=bin/${LIBEVENT_FILE}
function memcached_install()
{
    
    HOSTIP=$1
    #libevent_install ${HOSTIP}
    #if [ $? -ne 0 ]
    #then 
        #exit 1;
    #fi

    echo "${HOSTIP} memcached install...";
    echo " ./bin/${MEMCACHED_FILE}.tar.gz "
    if [ -f ./bin/${MEMCACHED_FILE}.tar.gz  ] 
    then 
        tar zxvf ./bin/${MEMCACHED_FILE}.tar.gz -C /usr/local/ 
        cd /usr/local/${MEMCACHED_FILE}
        ./configure -with-libevent=/usr
        make
        make install
        #查看memcached是否安装成功
        ls -al /usr/local/bin/mem*
        if [ $? -eq 0 ]
        then 
            cfont -green "memcache install successful\n" -reset;
        else 
            cfont -red "memcache install fail\n" -reset;
        fi

    else 
        echo "failllll";
    fi 

}

function libevent_install()
{

    HOSTIP=$1
    echo "${HOSTIP} libevent install...";
    if [ -f ./bin/${LIBEVENT_FILE}.tar.gz  ] 
    then 
        tar zxvf ./bin/${LIBEVENT_FILE}.tar.gz  -C /usr/local/
        cd /usr/local/${LIBEVENT_FILE}
        ./configure --prefix=/usr 
        make 
        make install
        ls -al /usr/lib | grep libevent
        if [ $? -eq 0 ]
        then 
            cfont -green "libevent install successful\n" -reset;
        else 
            cfont -red "libevent install fail\n" -reset;
        fi
        ln -sf  /usr/lib/libevent-1.3.so.1  /usr/lib64/libevent-1.3.so.1
    else 
        echo "fail\n";
    fi

}


#------------------------------
# domemcached_install
# description: 使用ssh命令登陆服务器,调用jdk_install 解压jdk
# return success 0, fail 1
#------------------------------
function domemcached_install()
{
    if [ $# -ge 1 ] 
    then 
        MEMCACHED_HOSTARR=$*
    else
        MEMCACHED_HOSTARR=${MEMCACHED_ARR[@]}
    fi

    for i in ${MEMCACHED_HOSTARR[@]} 
    do 
        ssh -p "${SSH_PORT}" "$i" \
            "cd ${UDSPACKAGE_PATH}; \
            source /etc/profile; \
            sh memcached_install.sh memcached_install $i \
            "
    done
}




if [ "$1" = libevent_install ]
then 
    echo "libevent install====="
    HOSTIP=$2
    libevent_install ${HOSTIP}
fi



if [ "$1" = memcached_install ]
then 
    echo "libevent install====="
    HOSTIP=$2
    memcached_install ${HOSTIP}
fi
