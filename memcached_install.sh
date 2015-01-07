#!/bin/bash 
. ./config 
. ./env.sh

function memcached_install()
{
    
    HOSTIP=$1
    libevent_install ${HOSTIP}
    if [ $? -ne 0 ]
    then 
        exit 1;
    fi

    echo "${HOSTIP} memcached install...";
    cd ${UDSPACKAGE_PATH}
    if [ -f ./bin/${MEMCACHED_FILE}.tar.gz ]
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
        cfont -red "${MEMCACHED_FILE}.tar.gz No such file\n" -reset;
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
            cfont -green "${HOSTIP} libevent install successful\n" -reset;
        else 
            cfont -red "${HOSTIP} libevent install fail\n" -reset;
        fi
        ln -sf  /usr/lib/libevent-1.3.so.1  /usr/lib64/libevent-1.3.so.1
    else 
        cfont -red "${LIBEVENT_FILE}.tar.gz No such file\n" -reset;
    fi

}


#------------------------------
# domemcached_install
# description: 使用ssh命令登陆服务器,调用memcached_install 解压memcached
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

function memcached_status()
{
    HOSTIP=$1
    ls -al /usr/local/bin/mem*
    if [ $? -eq 0 ]
    then 
        cfont -green "${HOSTIP} memcache install successful\n" -reset;
    else 
        cfont -red "${HOSTIP} memcache install fail\n" -reset;
    fi
}

function domemcached_status()
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
            sh memcached_install.sh memcached_status $i \
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

if [ "$1" = memcached_status ]
then 
    echo "memcached status====="
    HOSTIP=$2
    memcached_status ${HOSTIP}
fi
