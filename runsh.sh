#!/bin/bash 
. ./config
. ./checkenv.sh
. ./report.sh
. ./riak_install.sh
. ./iptables.sh
. ./mongodb_patch.sh
. ./mongodb_install.sh
. ./zk_install.sh
. ./jdk_install.sh
. ./env.sh
. ./zk_patch.sh
. ./fscontent_install.sh
. ./fsmeta_install.sh 
. ./fsname_install.sh


SCRIPT=`basename $0`
export CURPWD=$(cd `dirname $0`; pwd)

function usage()
{
    echo "\
Usage: ${SCRIPT} <command>
where <command> is one of the following:
        { env | riak | mongodb | zookeeper | jdk | fscontent | fsname | fsmeta }
    " 
}

function env_help()
{
    echo "\
Usage: ${SCRIPT} env <command>
where <command> is one of the following:
    { nopwd | checkenv | setenv | distribute } "
}


function riak_help()
{
    echo "\
Usage: ${SCRIPT} riak <command>
where <command> is one of the following:  
\
    { install | uninstall | start | stop | status | join | commit }"
}


function  fsname_help()
{
    echo "\
Usage: ${SCRIPT} fsname <command>
where <command> is one of the following:  
\
    { start | stop | status }"
}

function fscontent_help()
{
    echo "\
Usage: ${SCRIPT} fscontent <command>
where <command> is one of the following:  
\
    { start | stop | status }"

}

function fsmeta_help()
{
    echo "\
Usage: ${SCRIPT} fsmeta <command>
where <command> is one of the following:  
\
    { start | stop | status }"

}


function run()
{
    #1.生成脚本
    #2.ssh 免密码
    #3.环境检测并且收集
    #echo ${RIAK_FIRST_NODE}
    #exit 1;
    #generateShell
    confiesshlogin

    distributepackage
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
    #checkenv
    #collectenvres
    echo "exitttt";
    exit 1;
}

#run



function fsname_admin()
{
    case "$1" in
        start)
            echo "nameserver start...";
            dofsname_start;
            ;;
        stop)
            echo "nameserver stop...";
            dofsname_stop;
            ;;
        status)
            echo "nameserver status...";
            dofsname_status;
            ;;
        *)
            fsname_help;
            ;;
    esac
}

function fsmeta_admin()
{
    case "$1" in
        start)
            echo "metaserver start...";
            dofsmeta_start;
            ;;
        stop)
            echo "metaserver stop...";
            dofsmeta_stop;
            ;;
        status)
            echo "metaserver status...";
            dofsmeta_status;
            ;;
        *)
            fsmeta_help;
    esac
}

function fscontent_admin()
{
    case "$1" in
        start)
            echo "content start...";
            dofscontent_start;
            ;;
        stop)
            echo "content stop...";
            dofscontent_stop;
            ;;
        status)
            echo "content status...";
            dofscontent_status;
            ;;
        *)
            fscontent_help;
            ;;
    esac 


}

function riak_admin()
{
    case "$1" in
        start)
            echo "riak start...";
            doriak_start;
            ;;
        stop)
            echo "riak stop...";
            doriak_stop;
            ;;
        status)
            echo "riak status...";
            doriak_status;
            ;;
        join)
            echo "join...";
            doriak_joinring;
            ;;
        commit)
            echo "commit...";
            doriak_commit;
            ;;
        install)
            echo "riak install..";
            doriak_install;
            ;;
        unstall)
            echo "riak unstall...";
            doriak_unstall;
            ;;
        all)
            echo "riak all...";
            ;;
        *)
            riak_help
            ;;
    esac 
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
        setenv)
            echo "设置环境变量"
            ;;
        distribute)
            echo "分发到各台机器"
            distributepackage
            ;;
        iptables)
            echo "允许ip列表"
            doaccessPort
            ;;
        *)
            env_help;
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
        start)
            echo "zk start..."
            dozk_start
            ;;
        stop)
            echo "zk stop..."
            dozk_stop
            ;;
        status)
            echo "zk status..."
            dozk_status
            ;;
        gencfg)
            echo "zk gencfg..."
            for i in ${ZOOKEEPER_NODE_ARR[@]}; do
                HOSTIP=`echo $i | \
                    awk -F= '{print $2}' | \
                    awk -F: '{print $1}'`
                deal_zkconfig ${HOSTIP}
            done 
            ;;
        destroy)
            echo "删除zookeeper"
            dozk_destroy
            ;;

        *)
            echo "zookeeper"
            ;;
    esac
}

function jdk_admin()
{
    case "$1" in
        install)
            echo "jdk install";
            dojdk_install 
            ;;
        *)
            echo "jdk install ";
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
    jdk)
        shift
        jdk_admin "$@"
        ;;
    fscontent)
        shift
        echo "fs-content";
        fscontent_admin "$@";
        ;;
    fsname)
        shift
        echo "fs-name";
        fsname_admin "$@";
        ;;
    fsmeta)
        shift
        echo "fs-meta";
        fsmeta_admin "$@";
        ;;
    #fsjetty)
        #shfit
        #echo "fs-jetty";
        #fsjetty_admin "$@";
        #;;
    *)
        usage;
        ;;
esac


