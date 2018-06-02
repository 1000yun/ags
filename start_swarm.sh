#!/bin/sh

# docker network create   -d overlay ags_network
docker service create --name ags_proxy --publish "mode=host,target=80,published=80" --publish "mode=host,target=443,published=443" --publish "mode=host,target=7070,published=7070" --publish "mode=host,target=7070,published=7071" --publish "mode=host,target=7072,published=7072"   --mode global --network ags_network registry.cn-hangzhou.aliyuncs.com/ags/image_nginx_proxy:latest
docker stack deploy ags --compose-file=./docker-compose-work.yml

