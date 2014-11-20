#!/bin/bash 
. ./config
function setjdkenv()
{
    #export CURPWD=$(cd `dirname $0`; pwd)
    #JAVA_HOME=${}
    #export ${JAVA_HOME}

    export CURPWD=$(cd `dirname $0`; pwd)
    export JAVA_HOME=${CURPWD}/${JDK_FILE}
    export JAVA_BIN=${JAVA_HOME}/bin
    export PATH=${JAVA_BIN}:${PATH}

    if [ ! -d ${JAVA_HOME} ]; then \
        echo "JDK 路径不存在,无法设置"; exit 1;
    fi
    echo export JAVA_HOME=${JAVA_HOME} >> ${ENVBASHRC}
    echo export JAVA_BIN=${JAVA_HOME}/bin >> ${ENVBASHRC}
    echo export PATH=${JAVA_HOME}:${PATH} >> ${ENVBASHRC}

    echo "jdk path=${JAVA_HOME}"
    #java -version
}

function initenv()
{
    rm -fr envbashrc
    setjdkenv
}


function doenv()
{
    echo "doenv"
    #for i in ${RIAK_RINK[@]}; do 
        #ssh -p ${SSH_PORT} "$i" \
            #"cd ${UDSPACKAGE_PATH}; \
            #source /etc/profile; \
            #sh env.sh"
    #done 
}


if [ "$1" = setjdkenv ]
then 
    HOSTIP=$2
    echo "setjdkenv ====="
    setjdkenv ${HOSTIP}
fi
