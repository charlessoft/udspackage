#!/bin/sh 
#有参数输入.怎调用,否则就不调用
DESTFOLDER=uds
if [ ! -n "$1" ]; then
    echo "nil"
else
    echo "ok"
    scp -r ../${DESTFOLDER}/ $1:/tmp
fi
#scp -r ../ci/ $1:/home/charles/
#scp -r ../ci/ charles@10.211.55.3:/home/charles/
#scp -r ../ci/ charles@10.211.55.6:/home/charles/
#scp -r ../ci/ centos:/home/charles/
#scp charles@10.211.55.6:/home/charles/ci/linux/Makefile ./Makefile_bak
#scp -r ../ci/ root@10.142.55.227:/home/root/
