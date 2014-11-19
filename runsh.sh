#!/bin/bash 
#sh copy.sh 10.211.55.19
#sh copy.sh 10.211.55.20
#sh copy.sh centos
source ./config
source ./checkenv.sh
source ./report.sh
source ./riak_install.sh
source ./iptables.sh
source ./mongodb_patch.sh
source ./mongodb_install.sh
source ./zk_install.sh

function dealres()
{
    echo "res=$1";
    case $1 in 
        ${FILE_NO_EXIST}) 
            echo "文件不存在";;
        *)
            echo "未知错误";;
        0)
            echo "成功";;
        7)
            echo "Riak curl 网络检查失败!退出安装,请检查原因!";;
    esac
    if [ ${res} -ne 0 ]; then \
        exit ${res}; \
    fi

}
SCRIPT=`basename $0`
function usage()
{
    echo "Usage ${SCRIPT} aaa"
}

#1:generate slave install shell 
#function generatePatchShell()
#{
    #echo '正在生成 '$1' patch 脚本'
    #cp modify.sh modify_$1.sh
    #res=`echo $?`
    #if [ ${res} == "0" ]; then \
        #sed -i "s/TEMP_IPHOST/$1/g" modify_$1.sh; \
    #else 
        #echo "no"
    #fi
#}

function copyudspackage()
{
    for i in ${RIAK_RINK[@]}; do
        echo "复制uds安装包到" $i "${TMP_PATH}目录"
        scp -r ../${UDSPACKAGE_FILE} $i:${TMP_PATH}
        if [ $? -eq 1 ]; then \
            echo "复制文件失败 $i"; exit 1;
        fi
    done 
}

function generateInstallShell()
{
    echo $1

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

#function generateShell()
#{
    #echo "生成各台安装脚本"
    ##echo ${RIAK_RINK[@]}
    #nIndex=0
    #for i in ${RIAK_RINK[@]}; do
        ##if [ ${nIndex} == 0 ]; then \
            ##echo "生成Riak_FirstNode_安装脚本"; \
        ##else 
            ##echo "生成Riak安装脚本";
        ##fi
        ##let nIndex=$nIndex+1
        ##echo $nIndex
        #generatePatchShell $i 
    #done

#}

function run()
{
    #1.生成脚本
    #2.ssh 免密码
    #3.环境检测并且收集
    #echo ${RIAK_FIRST_NODE}
    #exit 1;
    #generateShell
    confiesshlogin

    copyudspackage
    docheck
    docollectres
    ##parseres
    generateEnvrpt

    #---parseok----
    doaccessPort   
    echo "sss";
    doinstall
    #dealres $?
    #if [ $? -ne 0 ]; then \
        #echo "安装失败"; \
    #fi
        
    dostart
    
    dojoinring
    #generateInstallShell
    #checkenv
    #collectenvres
    echo "exitttt";
    exit 1;
}

#run

function riak_help()
{
    echo "\
        Usage: ${SCRIPT} riak <command>

    The following commands stage changes to riak membership.
    "
}
function riak_admin()
{
    case "$1" in
        start)
            echo "riak start..."
            doriak_start
            ;;
        stop)
            echo "riak stop..."
        
            ;;
        join)
            echo "join..."
            doriak_joinring
            ;;
        install)
            echo "riak install.."
            doriak_install
            ;;
        unstall)
            echo "riak unstall..."
            doriak_unstall
            ;;
        all)
            echo "riak all..."
            echo "aaadddd"
            ;;
        *)
            riak_help
            ;;
    esac 
    #echo "riak_admin"
    #echo $*
}

function env_admin()
{
    case "$1" in 
        nopwd)
            echo "免密码登陆配置"
            confiesshlogin
            ;;
        checkenv)
            echo "环境检测并且收集"
            docheck
            docollectres
            generateEnvrpt
            ;;
        #gencfg)
            #echo "生成脚本"
            #generateShell
            #;;
        distribute)
            echo "分发到各台机器"
            copyudspackage
            ;;
        iptables)
            echo "允许ip列表"
            doaccessPort
            
            ;;
        *)
            echo "nopwd checkenv gencfg distribute"
            ;;
    esac
}

function zookeeper_admin()
{

    case "$1" in
        install)
            echo "zk install..."
            dozk_install
            ;;
        *)
            echo "zookeeper"
            ;;
    esac
}

function mongodb_admin()
{
    case "$1" in 
        start)
            echo "mongodb start"
            domongodb_start
            ;;
        install)
            echo "mongodb install"

            deal_mongody_patch  ${MONGODB_MASTER}
            deal_mongody_patch  ${MONGODB_ARBITER}
            for i in ${MONGODB_SLAVE_ARR[@]}; do
                deal_mongody_patch  $i
            done 
            copyudspackage
            domongodb_install
            ;;
        gencfg)
            echo "mongodb generate cfg"
            deal_mongody_patch  ${MONGODB_MASTER}
            deal_mongody_patch  ${MONGODB_ARBITER}
            for i in ${MONGODB_SLAVE_ARR[@]}; do
                deal_mongody_patch  $i
            done 
            ;;
        isonline)
            echo "mongodb isonlne";
            domongodb_isonline
            ;;
        cluster)
            echo "mongodb cluster";
            domongodb_cluster
            ;;
        destroy)
            echo "mongodb destroy";
            domongodb_destroy
            ;;
        *)
            echo "install gencfg"
            ;;
    esac

}


case "$1" in 
    env)
        shift
        env_admin "$@"
        ;;
    riak)
        shift
        riak_admin "$@"
        ;;
    mongodb)
        shift 
        mongodb_admin "$@"
        ;;
    zookeeper)
        shift
        zookeeper_admin "$@"
        ;;
    *)
        #run
        echo "请选择 env riak"
        ;;
esac




#2:install riak "





