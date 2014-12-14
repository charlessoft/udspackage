#!/bin/bash 
. ./config
JDK_FILE=bin/${JDK_FILE}

UDSPACKAGE_FILE=udspackage
UDSPACKAGE_PATH=${INSTALL_PATH}/${UDSPACKAGE_FILE}
SUDOERS_PATH=/etc/sudoers

ENVBASHRC=envbashrc
LOG_COLLECT=${INSTALL_PATH}/udslog.log
LOG=${INSTALL_PATH}/udsinstall.log
LOG_MERGE=${INSTALL_PATH}/udsmerge.log

#内部使用,不需要放在config中
MONGODB_CHECK_LOG=log/mongodbcheck.log 
JDK_CHECK_LOG=log/jdkcheck.log
RIAK_CHECK_LOG=log/riakcheck.log
ZOOKEEPER_CHECK_LOG=log/zookcheck.log 
CONTENT_CHECK_LOG=log/contentservercheck.log
NAME_CHECK_LOG=log/nameservercheck.log
META_CHECK_LOG=log/metaservercheck.log
HOSTARRAY_FILE=tmp/hostarray;

RIAK_CONF_BAK=/etc/riak/riak.conf_bak
RIAK_CONF=/etc/riak/riak.conf

UDS_ZOOKEEPER_CONFIG=udszookeeper.cfg
UDS_ZOOKEEPER_CLUSTER_CONFIG=udscluster.cfg
UDS_ZOOKEEPER_STORAGE_CONFIG=udsstorageresource.cfg
UDS_MONGODB_CONFIG=udsmongodb.cfg
CONFIGURATION=configuration.json
DEPLOY_FILE=fs-deploy


CONTENT_FILE=fs-contentserver
NAME_FILE=fs-nameserver
META_FILE=fs-metaserver


CONTENT_LOG_FILE=contentserver.log
NAME_LOG_FILE=nameserver.log
META_LOG_FILE=metaserver.log
DEPLOY_LOG_ZOOKEEPER_FILE=fsdeploy_zk_log.log
DEPLOY_LOG_MONGODB_FILE=fsdeploy_mongodb_log.log
DEPLOY_LOG_ZOOKEEPER_CLUSTER_FILE=fsdeploy_zk_cluster_log.log
DEPLOY_LOG_ZOOKEEPER_STORAGE_FILE=fsdeploy_zk_storageresource_log.log

ID_RSA_PUB=$HOME/.ssh/id_rsa.pub
IPTABLES_FILE=/etc/sysconfig/iptables

MONGODB_DBNAME=uds_fs
MONGODB_COL=user 


#riak 端口
RIAK_HTTP_PORT=8098
RIAK_EPMD_PORT=4369
RIAK_HANDOFF_PORT=8099
RIAK_DEFPORT=44571
RIAK_ERLANG_PORT_RANGE=6000-7999
RIAK_PROTOBUF_PORT=8087 
RIAK_FIRST_NODE=${RIAK_RINK[0]}

META_SERVER_PARAMS="-Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M"
NAME_SERVER_PARAMS="-Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M"
CONTENT_SERVER_PARAMS="-Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M"

#zookeeper 第一个节点
    ZOOKEEPER_FIRST_NODE_HOSTIP=`echo ${ZOOKEEPER_NODE_ARR[0]} | awk -F= '{print $2}' | \
        awk -F: '{print $1}'`

function initenv()
{
    HOSTIP=$1
    echo "${HOSTIP} initenv...";
    rm -fr envbashrc
    setjdkenv
    return $?;
}

function setjdkenv()
{
    export CURPWD=$(cd `dirname $0`; pwd)
    export JAVA_HOME=${CURPWD}/${JDK_FILE}
    export JAVA_BIN=${JAVA_HOME}/bin
    export PATH=${JAVA_BIN}:${PATH}

    if [ ! -d ${JAVA_HOME} ]; then \
        cfont -red "JDK ${JAVA_HOME} No such file!\n" -reset ; return 1;
    fi
    echo export JAVA_HOME=$JAVA_HOME >> ${ENVBASHRC}
    echo export JAVA_BIN='$JAVA_HOME'/bin >> ${ENVBASHRC}
    echo export PATH='$JAVA_HOME':'$JAVA_BIN':'$PATH' >> ${ENVBASHRC}

      #if [ `whoami` = "${USERNAME}" ] 
      #then
          ##echo "aa";
          ##echo "${HOME}/.bash_profile"
          ##exit 1
          #if [ -f ${HOME}/.bash_profile ]
          #then 
              ##判断是否存在
              ##grep -rin "JAVA_HOME"
              #echo "ok"
          #else 
              #echo export JAVA_HOME=$JAVA_HOME >> ${HOME}/.bash_profile
              #echo export JAVA_BIN='$JAVA_HOME'/bin >> ${HOME}/.bash_profile
              #echo export PATH='$JAVA_HOME':'$JAVA_BIN':'$PATH' >> ${HOME}/.bash_profile
          #fi

      #else 
          #echo "aaddddd";
      #fi

    echo "jdk path=${JAVA_HOME}"
    #java -version
}

function inithostarray()
{
    cat /dev/null > ${HOSTARRAY_FILE};
    echo "${CONTENT_SERVER}" >> ${HOSTARRAY_FILE};
    echo "${NAME_SERVER}" >> ${HOSTARRAY_FILE};
    echo "${RIAK_RINK[*]}"  | sed 's/\ /\n/g' >> ${HOSTARRAY_FILE}
    
    echo "${MONGODB_MASTER}" >> ${HOSTARRAY_FILE}
    echo "${MONGODB_SLAVE_ARR[*]}" | sed 's/\ /\n/g' >> ${HOSTARRAY_FILE};

    echo "${MONGODB_MASTER}" >> ${HOSTARRAY_FILE};
    echo "${MONGODB_ARBITER}" >> ${HOSTARRAY_FILE};
    echo "${JDK_ARR[*]}" | sed 's/\ /\n/g' >> ${HOSTARRAY_FILE};
    echo "${ZOOKEEPER_NODE_ARR[*]}" | sed 's/\ /\n/g' | awk -F: '{print $1}' | awk -F= '{print $2}' >> ${HOSTARRAY_FILE}

}



function distributepackage()
{
    #if [ $# -eq 1  ] 
    #then 
        #echo "distribute udspackage to "$1 "${INSTALL_PATH} folder..";
#"mkdir ${INSTALL_PATH} -p";
        #scp -r ../${UDSPACKAGE_FILE} $1:${INSTALL_PATH}; \
        ##临时测试去掉,后期需要还远
    ##if [ $? -eq 1 ]; then \
        ##echo "复制文件失败 $i"; exit 1;
    ##fi
    ##临时测试去掉,后期需要还远
#else 


    #构造数组
    inithostarray;
    if [ $# -ge 1 ] 
    then 
        HOSTARR=$*
    else
        HOSTARR=`sort ${HOSTARRAY_FILE} | uniq`;
    fi

    for i in ${HOSTARR[@]}; do
        echo "distribute udspackage to "$i "${INSTALL_PATH} folder..";
        ssh -p ${SSH_PORT} "$i" \
            "mkdir ${INSTALL_PATH} -p";
        scp -r ../${UDSPACKAGE_FILE} $i:${INSTALL_PATH}  >/dev/null 2>&1;
        #scp -r ../${UDSPACKAGE_FILE} $i:${INSTALL_PATH} 


        #临时测试去掉,后期需要还远
        #if [ $? -eq 1 ]; then \
            #echo "复制文件失败 $i"; exit 1;
        #fi
        #临时测试去掉,后期需要还远
    done 
#fi 
}

function dochownuser()
{

    #构造数组
    inithostarray;
    if [ $# -ge 1 ] 
    then 
        HOSTARR=$*
    else
        HOSTARR=`sort ${HOSTARRAY_FILE} | uniq`;
    fi

    #HOSTARR=`sort ${HOSTARRAY_FILE} | uniq`;
    for i in ${HOSTARR[@]}; do \
        ssh -p ${SSH_PORT} "$i" \
        "cd ${UDSPACKAGE_PATH}; \
        cd ../;\
        chown ${USERNAME}.${USERNAME} ./${UDSPACKAGE_FILE} -R;"
    done 

}


function configsshlogin()
{
   HOSTIP=$1;
   ssh-copy-id -i $ID_RSA_PUB $USER@$HOSTIP; 
}

#配置ssh 免密码登陆
function doconfigsshlogin()
{
    cfont -green "$USER perform SSH Login Without Password config\n" -reset;

    if [ -f ${ID_RSA_PUB} ] 
    then 
        cfont -green "$USER id_rsa.pub exist!\n" -reset; \
    else
        cfont -red "id_rsa.pub No such file! please perform [ssh-kengen] command generate id_rsa.pub\n" -reset;
        exit 1; 
    fi
    
    #构造数组
    inithostarray;
    if [ $# -ge 1 ] 
    then 
        HOSTARR=$*
    else
        HOSTARR=`sort ${HOSTARRAY_FILE} | uniq`;
    fi

    for i in ${HOSTARR[@]} 
    do 

        configsshlogin $i

        if [ $? -eq 1 ] 
        then 
            echo "login fail!"; exit 1; 
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
    HOSTIP=$2;
    echo "setjdkenv ..."; 
    setjdkenv ${HOSTIP};
fi


if [ "$1" = initenv ]
then 
    HOSTIP=$2;
    initenv ${HOSTIP};
fi
