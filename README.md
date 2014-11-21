UDS自动安装部署工具
==

概述
=
本shell脚本用于自动化安装基础软件以支持UDS_FS正常运行
根据配置文件配置,理论上允许N个riak,N个Mongodb,N个zookeeper,配置执行

工程结构
=

已知问题
=
1. riak node节点通信随机端口,未加入防火墙允许规则,无法通信, riak node是否有允许范围的端口?



