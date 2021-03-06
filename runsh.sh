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
. ./fsdeploy_install.sh
. ./config_patch.sh
. ./memcached_install.sh



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
        { env | riak | mongodb | zookeeper | jdk | fscontent | fsname | fsmeta | fsdeploy | runall | clean | memcached }
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
    { install | gencfg | start | stop | status | join | commit | reip }
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
    { start | install | gencfg | status | cluster | cluster_status | stop | dbauth }
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
# fsdeploy_admin
# description: zookeeper_使用帮助
#------------------------------
function fsdeploy_help()
{
    cfont  -red 
    echo " 
Usage: ${SCRIPT} fsdeploy <command>
where <command> is one of the following:  
\
    { install | refreshzookeeper | refreshzookeepercluster | refreshmongodb | refreshstorageresource | zookeeperlog | mongodblog | zookeeperclusterlog | storageresourcelog }
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
    { install | start | stop | status | log }
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
    { install | start | stop | status | log }
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
    { install | start | stop | status | log }
    "
    cfont -reset

}

function memcached_help()
{
    cfont -red
    echo "\
Usage: ${SCRIPT} memcached <command>
where <command> is one of the following:
\
    { install | status }
    "
    cfont -reset;

}



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
            dofsname_log;
            ;;
        install)
            echo "nameserver install...";
            shift 
            dofsname_install;
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
            dofsmeta_log;
            ;;
        install)
            echo "metaserver install...";
            dofsmeta_install;
            ;;
        *)
            fsmeta_help;
    esac
}

function fscontent_admin()
{
    case "$1" in
        install)
            echo "content install...";
            dofscontent_install;
            ;;
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
            dofscontent_log;
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
        gencfg)
            echo "riak gencfg...";
            shift 
            for i in ${RIAK_RINK[@]} 
            do
                deal_riakconf $i
            done 
            ;;
        reip)
            echo "riak reip...";
            shift 
            #doriak_reip "$@";
            riak_reip "$@";
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
            if [ ! -f install.lock ] 
            then 
                cfont -red "please perform [sh runsh.sh env initcfg] cmd first!\n" -reset;
                exit 1;
            fi
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
            cfont -green "create user\n" -reset;
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
            cfont -green "init mongodb zookeeper config\n" -reset;
            mongodb_admin gencfg;
            zookeeper_admin gencfg;
            #sh config_patch.sh
            
            deal_zookeeper_config "$@"
            deal_mongodb_config "$@"
            deal_configuration "$@"
            deal_zookeeper_cluster_config "$@"

            deal_zookeeper_storageresource_confg "$@"
            #deal_storageresource "$@"
            riak_admin gencfg
            touch install.lock
            ;;
        *)
            env_help;
            ;;
    esac
}

function fsdeploy_admin()
{
    case "$1" in 
        refreshzookeeper)
            echo "refresh zookeeper config...";
            shift 
            dofsdeploy_refresh_zookeeper_cfg;
            ;;
        refreshzookeepercluster)
            echo "refresh zookeeper cluster...";
            shift 
            dofsdeploy_refresh_zookeeper_cluster_cfg;
            ;;
        refreshmongodb)
            echo "refresh mongodb config...";
            shift
            dofsdeploy_refresh_mongodb_cfg;
            ;;
        refreshstorageresource)
            echo "refresh storageresource...";
            shift 
            dofsdeploy_refresh_storageresource_cfg "$@"
            ;;
        storageresourcelog)
            echo "collect deploy zookeeper storageresource...";
            shift 
            dofsdeploy_storageresource_log;
            ;;
        zookeeperlog)
            echo "collect deploy zookeeper config log...";
            shift 
            dofsdeploy_zookeeper_log;
            ;;
        zookeeperclusterlog)
            echo "collect deploy zookeeper config log...";
            shift 
            dofsdeploy_zookeeper_cluster_log;
            ;;
        mongodblog)
            echo "collect deploy mongodb config log...";
            shift
            dofsdeploy_mongodb_log;
            ;;
        install)
            echo "fsdeplpy install...";
            shift 
            dofsdeploy_install;
            ;;
        *)
            echo "deploy_admin"
            fsdeploy_help
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
            for i in ${ZOOKEEPER_NODE_ARR[@]} 
            do
                HOSTIP=`echo $i | \
                    awk -F= '{print $2}' | \
                    awk -F: '{print $1}'`
                deal_zkconfig ${HOSTIP}
            done 
            deal_zkperproperty
            ;;
        log)
            echo "collect zookeeper log";
            shift
            dozk_log "$@";
            ;;

        *)
            echo "zookeeper"
            zookeeper_help         
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
            for i in ${MONGODB_SLAVE_ARR[@]} 
            do
                deal_mongodb_patch  $i
            done 
            deal_mongodb_cluster_js_patch 
            deal_mongodb_cluster_status_js_patch
            deal_mongodb_db_auth_js_patch
            ;;
        dbauth)
            echo "mongodb auth"
            domongodb_db_auth;
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
            shift
            domongodb_stop "$@"
            ;;
        *)
            mongodb_help;
            ;;
    esac

}

function memcached_admin()
{
    case "$1" in 
        install)
            echo "memcached install"
            shift
            domemcached_install "$@"
            ;;
        status)
            echo "memcached status"
            shift 
            domemcached_status "$@"
            ;;
        *)
            memcached_help;
            ;;
    esac
}


function clean()
{
    rm -fr *.cfg 
    rm -fr *.conf 
    rm -fr log/*
    rm -fr tmp/*
    rm -fr cluster 
    rm -fr *.js
    rm -fr configuration.json
    rm -fr install.lock
    rm -fr zookeeper.properties
    rm -fr storageresource.json
}

#打包生成zip文件
function buildzip()
{
    clean
    sed -i 's/oplogSize.*=.*/oplogSize=10000/g' conf/mongodb_bak.conf
    cd ../ 
    tar cvzf udspackage.tar.gz --exclude=./udspackage/.git ./udspackage
}

function runall()
{
    
      if [ `whoami` = "root" ];then
          #zookeeper_admin gencfg 
          #mongodb_admin gencfg 

          
          clean
          env_admin initcfg
          env_admin distribute 
          env_admin nopwd
          env_admin iptables

          riak_admin install 
          riak_admin start 
          riak_admin join 
          riak_admin commit 
          env_admin createuser 
          env_admin chownuser
          chown ${USERNAME}.${USERNAME} ../udspackage -R
          #cfont -yellow "\
#please perform cmd switch ${USERNAME} login to perform same cmd to continue\n" -reset;
          cfont -yellow "please switch ${USERNAME} user to perfrom same cmd\n" -reset;

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
    mongodb_admin stop
    mongodb_admin start auth=false
    mongodb_admin cluster 
    sleep 20s;
    mongodb_admin dbauth
    
    mongodb_admin stop 
    mongodb_admin start auth=true
    fsdeploy_admin install
    fsdeploy_admin refreshzookeeper 
    fsdeploy_admin refreshmongodb
    fsdeploy_admin refreshzookeepercluster
    fsdeploy_admin refreshstorageresource 
    fsdeploy_admin refreshmongodb

    fscontent_admin install
    fsname_admin install 
    fsmeta_admin install 
    fscontent_admin start
    fsname_admin start 
    fsmeta_admin start

    sleep 5s;
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
    fsdeploy)
        shift 
        echo "fs-deploy";
        fsdeploy_admin "$@";
        ;;
    runall)
        shift
        echo "runall";
        runall "$@";
        ;;
    clean)
        shift 
        echo "clean all config, tmp file";
        clean 
        ;;
    buildzip)
        shift
        buildzip 
        ;;
    memcached)
        shift 
        memcached_admin "$@";
        ;;
    *)
        usage;
        ;;
esac


