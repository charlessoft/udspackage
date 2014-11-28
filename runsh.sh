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
. ./user_install.sh


SCRIPT=`basename $0`
export CURPWD=$(cd `dirname $0`; pwd)

function usage()
{
cfont  -red 
    echo "\
Usage: ${SCRIPT} <command>
where <command> is one of the following:
        { env | riak | mongodb | zookeeper | jdk | fscontent | fsname | fsmeta }
    "   
cfont -reset

}

function env_help()
{
cfont  -red 
    echo "\
Usage: ${SCRIPT} env <command>
where <command> is one of the following:
    { nopwd | checkenv | setenv | distribute } "
cfont -reset
}


function riak_help()
{
cfont  -red 
    echo "
Usage: ${SCRIPT} riak <command>
where <command> is one of the following:  
\
    { install | uninstall | start | stop | status | join | commit }"
cfont -reset
}

function mongodb_help()
{
cfont  -red 
    echo " 
Usage: ${SCRIPT} riak <command>
where <command> is one of the following:  
\
    { start | install | gencfg | status | cluster | destroy }
    "
cfont  -reset
}

function zookeeper_help()
{
cfont  -red 
    echo " 
Usage: ${SCRIPT} zookeeper <command>
where <command> is one of the following:  
\
    { install | start | stop | status | gencfg | destroy  }
    "
cfont  -reset

}

function  fsname_help()
{
    cfont -red
    echo "\
Usage: ${SCRIPT} fsname <command>
where <command> is one of the following:  
\
    { start | stop | status }"
cfont -reset
}

function fscontent_help()
{
cfont -red
    echo "\
Usage: ${SCRIPT} fscontent <command>
where <command> is one of the following:  
\
    { start | stop | status }"
cfont -reset

}

function fsmeta_help()
{
cfont -red
    echo "\
Usage: ${SCRIPT} fsmeta <command>
where <command> is one of the following:  
\
    { start | stop | status }"
cfont -reset

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
        log)
            echo "nameserver collect log...";
            fsname_log;
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
        log)
            echo "metaserver collect log...";
            fsmeta_log;
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
        log)
            echo "content collect log...";
            fscontent_log;
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
        rink_status)
            echo "riak rink status...";
            doriak_rink_status;
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
        checkinstalledstatus)
            echo "check installed status...";
            docheckinstalledstatus;
            ;;
        setenv)
            echo "设置环境变量"
            ;;
        distribute)
            echo "分发到各台机器"
            distributepackage
            ;;
        iptables)
            echo "allow port table"
            doaccessPort
            ;;
        adduser)
            echo "add user";
            douser_createuser ${USERNAME} ${USERPWD}
            ;;
        mytest)
            echo "mytest"
            douser_mytest;
            ;;

        #init)
            #echo "初始化环境,以及相关配置信息";
            #mongodb_admin gencfg 
            #zookeeper_admin gencfg
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
        status)
            echo "jdk status";
            dojdk_status;
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
            deal_mongodb_cluster_js_patch 
            ;;
        status)
            echo "mongodb status";
            domongodb_status;
            ;;
        cluster)
            echo "mongodb cluster";
            domongodb_cluster;
            ;;
        cluster_status)
            echo "mongodb cluster_status";
            domongodb_cluster_status;
            ;;
        destroy)
            echo "mongodb destroy";
            domongodb_destroy;
            ;;
        stop)
            echo "=====mongodb stop=====";
            domongodb_stop;
            ;;
        *)
            mongodb_help;
            ;;
    esac

}



function runall()
{
   
    zookeeper_admin gencfg 
    mongodb_admin gencfg 

    env_admin nopwd
    env_admin distribute

    sudo sh runsh.sh env nopwd
    sudo sh runsh.sh env iptables

    sudo sh runsh.sh riak install 
    sudo sh runsh.sh riak start 
    sudo sh runsh.sh riak join 
    sudo sh runsh.sh riak commit 
   
    jdk_admin install 
    zookeeper_admin install 
    zookeeper_admin start
    #zookeeper_admin stop

    mongodb_admin install
    mongodb_admin start
    mongodb_admin cluster 

    #mongodb_admin stop
    #mongodb_admin install 
    
    

    
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
    runall)
        shift
        echo "runall";
        runall "$@";
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


