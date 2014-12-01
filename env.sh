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
export HOSTARRAY=/tmp/hostarray;


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

function mergehostarray()
{
    cat /dev/null > ${HOSTARRAY};
    echo "${CONTENT_SERVER}" >> ${HOSTARRAY};
    echo "${NAME_SERVER}" >> ${HOSTARRAY};
    echo "${RIAK_RINK[*]}"  | sed 's/\ /\n/g' >> ${HOSTARRAY}
    
    echo "${MONGODB_MASTER}" >> ${HOSTARRAY}
    echo "${MONGODB_SLAVE_ARR[*]}" | sed 's/\ /\n/g' >> ${HOSTARRAY};

    echo "${MONGODB_MASTER}" >> ${HOSTARRAY};
    echo "${MONGODB_ARBITER}" >> ${HOSTARRAY};
    echo "${JDK_ARR[*]}" | sed 's/\ /\n/g' >> ${HOSTARRAY};
    echo "${ZOOKEEPER_NODE_ARR[*]}" | sed 's/\ /\n/g' | awk -F: '{print $1}' | awk -F= '{print $2}' >> ${HOSTARRAY}

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
    if [ $# -eq 1  ]; then \
        echo "distribute udspackage to "$1 "${INSTALL_PATH} folder.."
        ssh -p ${SSH_PORT} "$1" \
            "mkdir ${INSTALL_PATH} -p";
        scp -r ../${UDSPACKAGE_FILE} $1:${INSTALL_PATH}; \
        #临时测试去掉,后期需要还远
    #if [ $? -eq 1 ]; then \
        #echo "复制文件失败 $i"; exit 1;
    #fi
    #临时测试去掉,后期需要还远
else 

    for i in ${RIAK_RINK[@]}; do

        echo "distribute udspackage to "$i "${INSTALL_PATH} folder.."
        ssh -p ${SSH_PORT} "$i" \
            "mkdir ${INSTALL_PATH} -p";
        scp -r ../${UDSPACKAGE_FILE} $i:${INSTALL_PATH} 


        #临时测试去掉,后期需要还远
        #if [ $? -eq 1 ]; then \
            #echo "复制文件失败 $i"; exit 1;
        #fi
        #临时测试去掉,后期需要还远
    done 
fi 
}

function dochownuser()
{
    mergehostarray
    HOSTARR=`sort ${HOSTARRAY} | uniq`;
    for i in ${HOSTARR[@]}; do \
        ssh -p ${SSH_PORT} "$i" \
        "cd ${UDSPACKAGE_PATH}; \
        cd ../;\
        chown ${USERNAME}.${USERNAME} ./udspackage -R;"
        #"cd ${UDSPACKAGE_PATH}; \
        #source /etc/profile; \
        #sh env.sh chownuser $i 
        #"
        #useradd ${USERNAME}; \
        #echo "${USERPWD}" | passwd --stdin ${USERNAME} \
        #"
        #sh user_install.sh user_createuser $i"
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

    if [ -f ${ID_RSA_PUB} ]; then \
        cfont -green "$USER id_rsa.pub exist!\n" -reset; \
    else
        cfont -red "id_rsa.pub No such file! please perform [ssh-kengen] command generate id_rsa.pub\n" -reset;
        exit 1; 
    fi
    
    for i in ${RIAK_RINK[@]}; do \
        configsshlogin $i
        if [ $? -eq 1 ]; then \
            echo "login fail!"; exit 1; \
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
