#!/bin/bash 
. ./config
export JDK_FILE=bin/${JDK_FILE}

export UDSPACKAGE_FILE=udspackage
export UDSPACKAGE_PATH=${INSTALL_PATH}/${UDSPACKAGE_FILE}
export SUDOERS_PATH=/etc/sudoers

export ENVBASHRC=envbashrc
export LOG_COLLECT=${INSTALL_PATH}/udslog.log
export LOG=${INSTALL_PATH}/udsinstall.log
export LOG_MERGE=${INSTALL_PATH}/udsmerge.log
#内部使用,不需要放在config中
export MONGODB_CHECK_LOG=log/mongodbcheck.log 
export JDK_CHECK_LOG=log/jdkcheck.log
export RIAK_CHECK_LOG=log/riakcheck.log
export ZOOKEEPER_CHECK_LOG=log/zookcheck.log 
export CONTENT_CHECK_LOG=log/contentservercheck.log
export NAME_CHECK_LOG=log/nameservercheck.log
export META_CHECK_LOG=log/metaservercheck.log
export HOSTARRAY_FILE=tmp/hostarray;

export RIAK_CONF_BAK=/etc/riak/riak.conf_bak
export RIAK_CONF=/etc/riak/riak.conf

export UDS_ZOOKEEPER_CONFIG=udszookeeper.cfg
export UDS_ZOOKEEPER_CLUSTER_CONFIG=udscluster.cfg
export UDS_MONGODB_CONFIG=udsmongodb.cfg
export CONFIGURATION=configuration.json
export DEPLOY_FILE=uds-deploy



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
    echo export JAVA_HOME=${JAVA_HOME} >> ${ENVBASHRC}
    echo export JAVA_BIN=${JAVA_HOME}/bin >> ${ENVBASHRC}
    echo export PATH=${JAVA_HOME}:${PATH} >> ${ENVBASHRC}

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
