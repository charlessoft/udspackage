UDS自动安装部署工具
==

概述
=
本shell脚本用于自动化安装基础软件以支持UDS_FS正常运行
根据配置文件配置,理论上允许3个以上riak,Mongodb,zookeeper,配置执行

工程结构
=

使用步骤
=
1.以root权限拷贝脚本到目标机器目录下,例如:/apps  
sh runsh.sh env initcfg 
sh runsh.sh env nopwd 
sh runsh.sh env distribute 
2.以root权限登陆目标机器
    1) ssh root@10.211.55.18
    2) cd /apps/udspackage
    3) sh runsh.sh runall 
    首次执行过程中,系统会自动判断用户目录中是否存在公钥,如果不存在公钥,程序会提示用户执行ssh-keygen命令生成密钥对, 
    执行ssh-keygen 命令,需要敲入3次回车,生成密钥对
    5) 执行完毕会提示使用特定用户执行命令 
    6) su - weblogic2
    7) cd /apps/udspackage 
    8) sh runsh.sh runall
    9) 最终会检测安装情况

    使用免密码登陆,首次执行也会询问是否增加新主机公钥指纹,输入yes,根据提示输入新添加主机密码



3.命令说明

env   --对要分发的计算机提供创建用户,检测是否安装成功,初始化参数配置
    nopwd  --免密码登陆,可以指定到各台机器
    distribute --分发到各台机器,可以指定分发到各台机器
    initcfg --初始化参数配置 
    checkinstalledstatus --检测安装状态
    createuser --创建用户
    chownuser --修改udspackage安装包所属用户

riak   --对riak 操作,所有对riak的操作都需要root权限 
    install --安装 
    start --启动riak 
    stop --停止riak 
    status --获取riak运行状态
    join --各个节点的riak加入到环中
    commit --提交对riak加入环中的操作做的修改

mongodb   --对mongodb 操作 
    install --解压mongodb 
    start  --启动mongodb 
    status --获取mongodb 运行状态 
    gencfg --单独生成mongodb 配置文件
    cluster --设置多台mongodb集群
    cluster_status --获取mongodb集群状态
    stop  --停止mongodb 
    
zookeeper  --对zookeeper 操作 
    install --解压zookeeper
    start --启动zookeeper 
    status --获取zookeeper 状态
    gencfg --单独生成zookeeper配置文件 

jdk    --对jdk 操作 
    install --解压jdk 
    status --获取jdk安装是否成功 

fscontent   --对fscontent 操作 
    start  --启动fscontent 
    stop  --停止fscontent 
    status --获取fscontent状态 
    log  --收集fscontent 日志

fsname   
    start --启动fsname 
    stop  --停止fsname
    status --获取fsname状态
    log  --收集fsname日志 
    
fsmeta   
    start --启动fsmeta
    stop  --停止fsmeta
    status --获取fsmeta状态
    log  --收集fsmeta日志 

fsdeploy --刷新配置功能
    refreshzookeeper --刷新zookeeper配置
    zookeeperlog --收集刷新zookeeper log 
    refreshzookeepercluster --刷新集群操作(待张垚手工文档确认)
    zookeeperclusterlog--收集zookeeperclusterlog日志
    refreshmongodb --刷新mongodb配置 
    mongodblog --收集刷新mongodb日志

runall  
    一次执行脚本,在执行的过程中会提示切换用户

clean   
    清空日志以及配置文档




已知问题
=
1. riak node节点通信随机端口,未加入防火墙允许规则,无法通信, riak node是否有允许范围的端口?



1.riak
2.jdk
3.zookeeper
4.mongodb 
use uds_fs

db.user.find()
