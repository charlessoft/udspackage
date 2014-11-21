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
        echo "JDK 路径不存在,无法设置环境变量"; return 1;
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
    return $?;
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


function distributepackage()
{
    for i in ${RIAK_RINK[@]}; do
        echo "复制uds安装包到" $i "${TMP_PATH}目录"
        scp -r ../${UDSPACKAGE_FILE} $i:${TMP_PATH}
        #临时测试去掉,后期需要还远
        #if [ $? -eq 1 ]; then \
            #echo "复制文件失败 $i"; exit 1;
        #fi
        #临时测试去掉,后期需要还远
    done 
}



#配置ssh 免密码登陆
function confiesshlogin()
{
    if [ -f ${ID_RSA_PUB} ]; then \
        echo "本机id_rsa.pub 存在! ===ok"; \
    else
        echo "id_rsa.pub 不存在,请调用ssh-kengen 命令生成id_rsa.pub";
        exit 1; 
    fi
    for i in ${RIAK_RINK[@]}; do \
        ssh-copy-id -i $ID_RSA_PUB $USER@$i; \
        if [ $? -eq 1 ]; then \
            echo "免密码登陆失败,请检查原因"; exit 1; \
        fi
    done
}


if [ "$1" = setjdkenv ]
then 
    HOSTIP=$2
    echo "setjdkenv ====="
    setjdkenv ${HOSTIP}
fi
