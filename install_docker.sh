#!/bin/bash


sudo yum remove docker docker-common docker-selinux docker-engine -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum makecache fast
#sudo yum install docker-ce -y
sudo  yum  install docker-ce-17.12.0.ce-1.el7.centos.x86_64
sudo systemctl start docker
sudo systemctl enable docker
