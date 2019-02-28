#!/bin/bash


docker stack deploy ags  --compose-file=docker-compose-dev.yml
# docker service create    --name ags_proxy --publish "mode=host,target=80,published=80" --publish "mode=host,target=443,published=443"    --network  ags_network  registry.cn-hangzhou.aliyuncs.com/ags/image_openresty_proxy:latest

