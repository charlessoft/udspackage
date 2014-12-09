UDS自动安装部署工具
==

概述
=
本shell脚本用于自动化安装UDS_FS  
根据配置文件配置,理论上允许3个以上riak,Mongodb,zookeeper集群部署

配置文件说明
=

######udspackage安装路径
>INSTALL_PATH=/apps

######mongodb文件名
>MONGODB_FILE=mongodb-linux-x86_64-2.6.3

######jdk文件名
>JDK_FILE=jdk1.6.0_45

######riak文件名
>RIAK_FILE=riak-2.0.2-1.el5.x86_64.rpm  

######zookeeper文件名
>ZOOKEEPER_FILE=zookeeper-3.4.6  

######fscontent server文件名
>CONTENT_SERVER=10.211.55.18

######fsmeta server文件名
>META_SERVER=10.211.55.21

######fsname server文件名
>NAME_SERVER=10.211.55.22

######用户账号密码
>USERNAME=weblogic

>USERPWD=abcdefg


fscontent-nameserver-metaserver参数优化配置,默认不需要修改

>META_SERVER_PARAMS="-Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M"

>NAME_SERVER_PARAMS="-Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M"

>CONTENT_SERVER_PARAMS="-Xms2048M -Xmx2048M -Xss512k -XX:PermSize=256M -XX:MaxPermSize=512M"


######riak 相关服务器地址,多个riak增加到数组中

>RIAK_RINK=( \  
    10.211.55.18 \  
    10.211.55.21 \  
    10.211.55.22 \  
    )

>RIAK_FIRST_NODE=${RIAK_RINK[0]}

>RIAK_HTTP_PORT=8098
>
>RIAK_EPMD_PORT=4369
>
>RIAK_HANDOFF_PORT=8099
>
>RIAK_DEFPORT=44571
>
>RIAK_ERLANG_PORT_RANGE=6000-7999
>
>RIAK_PROTOBUF_PORT=8087


###### mongodb Repliset相关配置
>#####MONGODB MASTER
>MONGODB_MASTER=10.211.55.18
>MONGODB_MASTER_DBPATH=/home/${USERNAME}/mongodb/data/master
>MONGODB_MASTER_LOGPATH=/home/${USERNAME}/mongodb/log/master.log
>MONGODB_MASTER_PIDFILEPATH=/home/${USERNAME}/mongodb/master.pid
>MONGODB_MASTER_PORT=27017
>
>####MONGODB SLAVE
>MONGODB_SLAVE=10.211.55.21
>MONGODB_SLAVE_DBPATH=/home/${USERNAME}/mongodb/data/slave
>MONGODB_SLAVE_LOGPATH=/home/${USERNAME}/mongodb/log/slave.log
>MONGODB_SLAVE_PIDFILEPATH=/home/${USERNAME}/mongodb/slave.pid
>MONGODB_SLAVE_PORT=27017
>
>#####如果多个mongodb 集群.ip写入到一下数组中
>MONGODB_SLAVE_ARR=( \  
>    ${MONGODB_SLAVE} \  
>    )
>
>#####MONGODB ARIBTER
>MONGODB_ARBITER=10.211.55.22
>MONGODB_ARBITER_DBPATH=/home/${USERNAME}/mongodb/data/slave
>MONGODB_ARBITER_LOGPATH=/home/${USERNAME}/mongodb/log/slave.log
>MONGODB_ARBITER_PIDFILEPATH=/home/${USERNAME}/mongodb/slave.pid
>MONGODB_ARBITER_PORT=27017


######JAVA 多个jdk增加到ip数组中
>JDK_ARR=( \
>    10.211.55.18 \  
>    10.211.55.21 \  
>    10.211.55.22 \  
>    )


###### zookeeper 配置相关


>ZOOKEEPER_DATADIR=/home/${USERNAME}/zookeeper/data
>ZOOKEEPER_LOGDIR=/home/${USERNAME}/zookeeper/data/log
>ZOOKEEPER_NODE_ARR=( \
>    server.1=10.211.55.18:2888:3888 \
>    server.2=10.211.55.21:2888:3888 \
>    server.3=10.211.55.22:2888:3888 \
>    )
>ZOOKEEPER_PORT=2181


######需要开放的防火墙端口列表
>IPTABLES_ACCESS_PORT=( \  
>    123 \  
>    456 \  
>    )



######刷新zookeeper配置 
>ZOOKEEPER_USER=admin
>ZOOKEEPER_PASSWORD=pa44w0rd
>ZOOKEEPER_CONFIG_NAME=/udsfs/configuration
>ZOOKEEPER_CONFIG_PATH=configuration.json
>ZOOKEEPER_CLUSTER_NAME=/udsfs/cluster
>ZOOKEEPER_CLUSTER_PATH=cluster

######刷新mongodb配置
>MONGODB_DBUSER=uds_fs
>MONGODB_DBPASSWORD=pa44w0rd
>MONGODB_DBNAME=uds_fs
>MONGODB_COL=user
>MONGODB_ADDUSERNAME=zhangyao
>MONGODB_ADDPASSWORD=pa44w0rd
>MONGODB_BUCKETS=uds
>FILE_TMP_PATH=/tmp4






使用步骤
=
1.以root权限拷贝脚本到目标机器目录下,例如:/apps  
sh runsh.sh env initcfg   
sh runsh.sh env nopwd   
sh runsh.sh env distribute   

2.以root权限登陆目标机器  

ssh root@10.211.55.18  
cd /apps/udspackage  
sh runsh.sh runall  
       首次执行过程中,系统会自动判断用户目录中是否存在公钥,如果不存在公钥,程序会提示用户执行ssh-keygen命令生成密钥对, 
    执行ssh-keygen 命令,需要敲入3次回车,生成密钥对
执行完毕会提示使用特定用户执行命令  
su - weblogic  
cd /apps/udspackage  
sh runsh.sh runall  
最终会检测安装情况    

使用免密码登陆,首次执行也会询问是否增加新主机公钥指纹,输入yes,根据提示输入新添加主机密码



命令说明
=

##env
对要分发的计算机提供创建用户,检测是否安装成功,初始化参数配置
    
- **nopwd**  
	-   免密码登陆,可以指定到各台机器  
- **distribute** 
	- 分发到各台机器,可以指定分发到各台机器  
- **initcfg** 
	- 初始化参数配置   
- **checkinstalledstatus** 
	- 检测安装状态  
- **createuser** 
	- 创建用户  
- **chownuser** 
	- 修改udspackage安装包所属用户  

##riak  
对riak 操作,所有对riak的操作都需要root权限   

- **install** 
	- 安装riak   
- **start** 
	- 启动riak   
- **stop** 
	- 停止riak   
- **status** 
	- 获取riak运行状态  
- **join** 
	- 各个节点的riak加入到环中  
- **commit** 
	- 提交对riak加入环中的操作做的修改  

##mongodb
对mongodb 操作 

- **install** 
	- 解压mongodb   
- **start**    
	- 启动mongodb   
- **status**   
	- 获取mongodb 运行状态   
- **gencfg**   
	- 单独生成mongodb 配置文件  
- **cluster**   
	- 设置多台mongodb集群  
- **cluster_status**   
	- 获取mongodb集群状态  
- **stop**    
	- 停止mongodb   
    
##zookeeper  
对zookeeper 操作   

- **install** 
	- 解压zookeeper  
- **start** 
	- 启动zookeeper   
- **status** 
	- 获取zookeeper 状态  
- **gencfg** 
	- 单独生成zookeeper配置文件   

##jdk    

- **install** 
	- 解压jdk   
- **status** 
	- 获取jdk安装是否成功   

##fscontent   
   
- **start**  
	- 启动fscontent   
- **stop**  
	- 停止fscontent   
- **status** 
	- 获取fscontent状态   
- **log**  
	- 收集fscontent 日志  

##fsname   
 
- **start** 
	- 启动fsname   
- **stop**  
	- 停止fsname  
- **status** 
	- 获取fsname状态  
- **log**  
	- 收集fsname日志   
    
##fsmeta   

- **start** 
	- 启动fsmeta  
- **stop**  
	- 停止fsmeta  
- **status** 
	- 获取fsmeta状态  
- **log**  
	- 收集fsmeta日志   

##fsdeploy 
刷新配置功能  

- **refreshzookeeper** 
	- 刷新zookeeper配置  
- **zookeeperlog** 
	- 收集刷新zookeeper log   
- **refreshzookeepercluster** 
	- 刷新集群操作
- **zookeeperclusterlog** 
	- 收集zookeeperclusterlog日志  
- **refreshmongodb** 
	- 刷新mongodb配置   
- **mongodblog** 
	- 收集刷新mongodb日志  

##runall    
一次执行脚本,在执行的过程中会提示切换用户  
  
## clean     
清空日志以及配置文档  




待讨论-以及修改
==
1. cd /app/soft/fs-contentserver-1.0/lib, fs-common-1.0.jar用winrar打开。提取出config/zookeeper.properties文件，替换ip地址 未做.(fs-nameserver.fsmetaserver也是)

