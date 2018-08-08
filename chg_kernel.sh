#!/bin/bash

#设置脚本中所需命令的执行路径
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


#  在主机 /etc/sysctl.conf  文件后面加入
echo -e  "net.core.somaxconn = 20480 \n\
net.core.rmem_default = 262144 \n\
net.core.wmem_default = 262144 \n\
net.core.rmem_max = 16777216 \n\
net.core.wmem_max = 16777216 \n\
net.ipv4.tcp_rmem = 4096 4096 16777216 \n\
net.ipv4.tcp_wmem = 4096 4096 16777216 \n\
net.ipv4.tcp_mem = 786432 2097152 3145728 \n\
net.ipv4.tcp_max_syn_backlog = 16384 \n\
net.core.netdev_max_backlog = 20000 \n\
net.ipv4.tcp_fin_timeout = 15 \n\
net.ipv4.tcp_max_syn_backlog = 16384 \n\
net.ipv4.tcp_tw_reuse = 1 \n\
net.ipv4.tcp_tw_recycle = 1 \n\
net.ipv4.tcp_max_orphans = 131072 \n\
net.ipv4.tcp_syncookies = 0 \n"\
>> /etc/sysctl.conf

# 修改宿主主机 /etc/security/limits.conf   最后加
echo -e  "*    soft    nofile    102400 \n\
*    hard    nofile    102400 \n\
*    soft    nproc    10240 \n\
*    hard    nproc    10240 \n"\
>> /etc/security/limits.conf
