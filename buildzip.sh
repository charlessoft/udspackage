#!/bin/bash 
sh runsh.sh clean
current_date=`date "+%Y%m%d"`
filename='udspackage'
build_file_time_format=`date "+%Y-%m-%d-%H-%M-%S"` #小时 时间秒 2014-11-12 20:22:49
cd ../
tar zcvf ${filename}_${build_file_time_format}.tar.gz ./udspackage
