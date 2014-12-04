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


#------------------------------
# usage
# description: 使用帮助
#------------------------------
function usage()
{
    cfont  -red 
    echo "\
Usage: ${SCRIPT} <command>
where <command> is one of the following:
        { env | riak | mongodb | zookeeper | jdk | fscontent | fsname | fsmeta | runall }
    "   
    cfont -reset

}

#------------------------------
# env_help 
# description: env_使用帮助
#------------------------------
function env_help()
{
    cfont  -red 
    echo "\
Usage: ${SCRIPT} env <command>
where <command> is one of the following:
    { nopwd | checkenv | distribute | initcfg | checkinstalledstatus | createuser | chownuser } 
    "
    cfont -reset
}



#------------------------------
# jdk_help 
# description: jdk_使用帮助
#------------------------------
function jdk_help()
{
    cfont  -red 
    echo "\
Usage: ${SCRIPT} jdk <command>
where <command> is one of the following:
    { install | status } 
    "
    cfont -reset
}

#------------------------------
# riak_help 
# description: riak_使用帮助
#------------------------------
function riak_help()
{
    cfont  -red 
    echo "
Usage: ${SCRIPT} riak <command>
where <command> is one of the following:  
\
    { install | start | stop | status | join | commit }
    "
    cfont -reset
}


#------------------------------
# mongodb_help 
# description: mongodb_使用帮助
#------------------------------
function mongodb_help()
{
    cfont  -red 
    echo " 
Usage: ${SCRIPT} riak <command>
where <command> is one of the following:  
\
    { start | install | gencfg | status | cluster | cluster_status | stop }
    "
    cfont  -reset
}

#------------------------------
# zookeeper_help
# description: zookeeper_使用帮助
#------------------------------
function zookeeper_help()
{
    cfont  -red 
    echo " 
Usage: ${SCRIPT} zookeeper <command>
where <command> is one of the following:  
\
    { install | start | stop | status | gencfg }
    "
    cfont  -reset

}


#------------------------------
# fsname_help 
# description: fsname_使用帮助
#------------------------------
function fsname_help()
{
    cfont -red
    echo "\
Usage: ${SCRIPT} fsname <command>
where <command> is one of the following:  
\
    { start | stop | status }
    "
    cfont -reset
}


#------------------------------
# fscontent_help 
# description: fscontent_使用帮助
#------------------------------
function fscontent_help()
{
    cfont -red
    echo "\
Usage: ${SCRIPT} fscontent <command>
where <command> is one of the following:  
\
    { start | stop | status }
    "
    cfont -reset

}

#------------------------------
# fsmeta_help 
# description: fsmeta_使用帮助
#------------------------------
function fsmeta_help()
{
    cfont -red
    echo "\
Usage: ${SCRIPT} fsmeta <command>
where <command> is one of the following:  
\
    { start | stop | status }
    "
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
    configsshlogin

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
            shift
            doriak_start "$@";
            ;;
        stop)
            echo "riak stop...";
            shift
            doriak_stop "$@";
            ;;
        status)
            echo "riak status...";
            shift 
            doriak_status "$@";
            ;;
        rink_status)
            echo "riak rink status...";
            shift 
            doriak_rink_status "$@";
            ;;
        join)
            echo "join...";
            shift
            doriak_joinring "$@";
            ;;
        commit)
            echo "commit...";
            doriak_commit;
            ;;
        install)
            echo "riak install..";
            shift
            doriak_install "$@";
            ;;
        *)
            riak_help
            ;;
    esac 
}

function env_admin()
{
    case "$1" in 
        nopwd)#--ok
            shift 
            doconfigsshlogin "$@";
            ;;
        checkenv)
            echo "check env..."
            docheck
            docollectres
            generateEnvrpt
            ;;
        checkinstalledstatus)
            echo "check installed status...";
            shift
            docheckinstalledstatus "$@";
            ;;
        distribute) #--ok
            cfont -green "distribute udspackage...\n" -reset;
            shift
            distributepackage "$@";
            ;;
        iptables) #--ok
            echo "allow port table"
            shift
            doaccessPort "$@";
            ;;
        createuser) #--ok
            cfont -greed "create user\n" -reset;
            shift
            douser_createuser "$@";
            #douser_createuser ${USERNAME} ${USERPWD}
            ;;
        chownuser) #--ok
            echo "chownuser";
            shift
            dochownuser "$@";
            ;;
        initcfg) 
            cfont -greed "init mongodb zookeeper config\n" -reset;
            mongodb_admin gencfg;
            zookeeper_admin gencfg;
            ;;
        *)
            env_help;
            ;;
    esac
}

function zookeeper_admin()
{
    case "$1" in
        install) #--ok
            echo "zk install..."
            shift
            dozk_install "$@";
            ;;
        start)  #--ok
            echo "zk start..."
            shift
            dozk_start "$@";
            ;;
        stop) #--ok
            echo "zk stop..."
            shift
            dozk_stop "$@";
            ;;
        status) #--ok
            echo "zk status..."
            shift
            dozk_status "$@";
            ;;
        gencfg)
            echo "zk generate gencfg..."
            for i in ${ZOOKEEPER_NODE_ARR[@]}; do
                HOSTIP=`echo $i | \
                    awk -F= '{print $2}' | \
                    awk -F: '{print $1}'`
                deal_zkconfig ${HOSTIP}
            done 
            ;;
        log)
            echo "collect zookeeper log";
            shift
            dozk_log "$@";
            ;;

        *)
            echo "zookeeper"
            ;;
    esac
}

function jdk_admin()
{
    case "$1" in
        install) #--ok
            echo "jdk install";
            shift
            dojdk_install "$@";
            ;;
        status) #--ok
            echo "jdk status";
            shift
            dojdk_status "$@";
            ;;
        *)
            jdk_help;
            ;;
    esac

}
function mongodb_admin()
{
    case "$1" in 
        start) #--ok
            echo "mongodb start"
            shift
            domongodb_start "$@"
            ;;
        install)
            echo "mongodb install"
            shift
            domongodb_install "$@"
            ;;
        gencfg)
            echo "mongodb generate cfg..."
            deal_mongodb_patch  ${MONGODB_MASTER}
            deal_mongodb_patch  ${MONGODB_ARBITER}
            for i in ${MONGODB_SLAVE_ARR[@]}; do
                deal_mongodb_patch  $i
            done 
            deal_mongodb_cluster_js_patch 
            deal_mongodb_cluster_status_js_patch
            ;;
        status) 
            echo "mongodb status";
            shift
            domongodb_status "$@"
            ;;
        cluster)
            echo "mongodb cluster";
            domongodb_cluster;
            ;;
        cluster_status)
            echo "mongodb cluster_status";
            domongodb_cluster_status;
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
    
      if [ `whoami` = "root" ];then
          #zookeeper_admin gencfg 
          #mongodb_admin gencfg 

          env_admin nopwd
          env_admin iptables

          riak_admin install 
          riak_admin start 
          riak_admin join 
          riak_admin commit 
          env_admin createuser 
          env_admin chownuser
          chown ${USERNAME}.${USERNAME} ../udspackage -R
          cfont -yellow "\
please perform cmd switch ${USERNAME} login to perform same cmd to continue\n" -reset;

          cfont -green "su - ${USERNAME};\n" -reset;
          cfont -green "cd ${UDSPACKAGE_PATH};\n" -reset;
          cfont -green "sh runsh.sh runall;\n" -reset;
          exit 1;
else \

    
    env_admin nopwd
    jdk_admin install 
    zookeeper_admin install 
    zookeeper_admin start
    #zookeeper_admin stop

    mongodb_admin install
    mongodb_admin start
    mongodb_admin cluster 

    fscontent_admin start
    fsname_admin start 
    fsmeta_admin start

    echo "==========check installed status ==========";
    env_admin checkinstalledstatus
    
fi
   

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
    runall1)
        shift
        echo "runall1";
        runall1 "$@";
        ;;
    *)
        usage;
        ;;
esac


