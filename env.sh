#!/bin/bash 
. ./config
export JDK_FILE=bin/${JDK_FILE}

#内部使用,不需要放在config中
export MONGODB_CHECK_LOG=log/mongodbcheck.log 
export JDK_CHECK_LOG=log/jdkcheck.log
export RIAK_CHECK_LOG=log/riakcheck.log
export ZOOKEEPER_CHECK_LOG=log/zookcheck.log 
export CONTENT_CHECK_LOG=log/contentservercheck.log
export NAME_CHECK_LOG=log/nameservercheck.log
export META_CHECK_LOG=log/metaservercheck.log


function setjdkenv()
{
    export CURPWD=$(cd `dirname $0`; pwd)
    export JAVA_HOME=${CURPWD}/${JDK_FILE}
    export JAVA_BIN=${JAVA_HOME}/bin
    export PATH=${JAVA_BIN}:${PATH}

    if [ ! -d ${JAVA_HOME} ]; then \
        cfont -red "JDK ${JAVA_HOME} No such file!\n" -reset ; return 1;
    fi
    echo export JAVA_HOME=${JAVA_HOME} >> ${ENVBASHRC}
    echo export JAVA_BIN=${JAVA_HOME}/bin >> ${ENVBASHRC}
    echo export PATH=${JAVA_HOME}:${PATH} >> ${ENVBASHRC}

    echo "jdk path=${JAVA_HOME}"
    #java -version
}

function initenv()
{
    HOSTIP=$1
    echo "${HOSTIP} initenv...";
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
    echo "使用 $USER 进行免密码登陆配置";

    if [ -f ${ID_RSA_PUB} ]; then \
        echo "本机 $USER id_rsa.pub 存在! ===ok"; \
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

cfont()
{
while (($#!=0))
do
        case $1 in
                -b)
                        echo -ne " ";
                ;;
                -t)
                        echo -ne "\t";
                ;;
                -n)     echo -ne "\n";
                ;;
                -black)
                        echo -ne "\033[30m";
                ;;
                -red)
                        echo -ne "\033[31m";
                ;;
                -green)
                        echo -ne "\033[32m";
                ;;
                -yellow)
                        echo -ne "\033[33m";
                ;;
                -blue)
                        echo -ne "\033[34m";
                ;;
                -purple)
                        echo -ne "\033[35m";
                ;;
                -cyan)
                        echo -ne "\033[36m";
                ;;
                -white|-gray) echo -ne "\033[37m";
                ;;
                -reset)
                        echo -ne "\033[0m";
                ;;
                -h|-help|--help)
                        echo "Usage: cfont -color1 message1 -color2 message2 ...";
                        echo "eg:       cfont -red [ -blue message1 message2 -red ]";
                ;;
                *)
                echo -ne "$1"
                ;;
        esac
        shift
done
}

if [ "$1" = setjdkenv ]
then 
    HOSTIP=$2
    echo "setjdkenv ====="
    setjdkenv ${HOSTIP}
fi


if [ "$1" = initenv ]
then 
    HOSTIP=$2
    initenv ${HOSTIP}
fi
