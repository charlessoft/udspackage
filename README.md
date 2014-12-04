UDS自动安装部署工具
==

概述
=
本shell脚本用于自动化安装基础软件以支持UDS_FS正常运行
根据配置文件配置,理论上允许N个riak,N个Mongodb,N个zookeeper,配置执行

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
    首次运行过程中中会遇到ssh登陆询问是否添加新主机公钥指纹输入yes 回车就好,然后根据提示输入新添加主机的密码 
    5) 执行完毕会提示使用特定用户执行命令 
    6) su - weblogic2
    7) cd /apps/udspackage 
    8) sh runsh.sh runall

    使用免密码登陆,首次执行也会询问是否增加新主机公钥指纹,输入yes,根据提示输入新添加主机密码



3.执行命令





已知问题
=
1. riak node节点通信随机端口,未加入防火墙允许规则,无法通信, riak node是否有允许范围的端口?



1.riak
2.jdk
3.zookeeper
4.mongodb 
use uds_fs

db.user.find()
