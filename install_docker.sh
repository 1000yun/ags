#!/bin/bash


yum remove docker docker-common docker-selinux docker-engine -y
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install docker-ce -y
systemctl start docker
