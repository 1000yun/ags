#!/bin/bash
 
#设置脚本中所需命令的执行路径
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


mkdir /usr/local/ags
touch /usr/local/ags/install.tmp.log
touch /usr/local/ags/update.tmp.log
LOGFILE=/usr/local/ags/install.tmp.log
date >>$LOGFILE


show_log()    ## 函数定义
{

	echo  -e "\n\n ==================== update detail log start ====================================\n"
        cat install.tmp.log #$LOGFILE
	echo -e  "\n\n ==================== update detail log end =======================================\n"
        # return  2      ###返回值其实是状态码，只能在[0-255]范围内
}   




echo "[1/9]download install file"
PACKAGE="ags.tar.gz"
fileurl="https://github.com/1000yun/ags/raw/master/${PACKAGE}"
COMPOSE_FILENAME="docker-compose.yml"
BOOT_SH_FILENAME="start_swarm.sh"
UPDATE_SH_FILENAME="update.sh"
wget -nv $fileurl
if [ "$?" != 0 ] ;
then
         echo "download file err!!!"
         exit 0
else
        echo "success,download"
fi
tar zxvf ${PACKAGE} -C /usr/loca/ags

#LOGFILE=/usr/local/ags/install.tmp.log
#date >>$LOGFILE



cd /usr/local/ags
chmod +x /usr/local/ags/${UPDATE_SH_FILENAME}
chmod +x /usr/local/ags/${BOOT_SH_FILENAME}
echo " success,change install file"

echo "[2/9]check docker install..."  
rpm -qa | grep docker  
if [ "$?" != 0 ] ;
then
         echo "error! not find docker!!!"
         exit 0
else
	echo " success"
fi


echo "[3/9]init swarm"
docker swarm join-token manager
if [ "$?" != 0 ] ;
then
         echo "docker swarm not existing,create..."
         docker swarm init
	if [ "$?" != 0 ] ;
	then
        	 echo "err! swarm init err!"
	         exit 0
	else
		echo " success,swarm init"
	fi
else
	echo " success,the swarm has been created!"
fi

echo "[4/9]check netwrok.."
docker network inspect   ags_network
if [ "$?" != 0 ] ;
then
        echo "ags_network not existing,create..."
	docker network create   -d overlay ags_network
	if [ "$?" != 0 ] ;
	then
        	 echo "err! create new network err!"
	         exit 0
	else
        	echo " success,create new ags_network"
	fi
else
        echo " success,ags_nework existing"
fi

echo "[5/9]create ags_proxy service.."
docker service ps ags_proxy
if [ "$?" != 0 ] ;
then
        echo "service_proxy service isn't existing,create..."        
else
	echo "rm old ags_proxy service..."
        docker service rm ags_proxy
fi
docker service create --name ags_proxy --publish "mode=host,target=80,published=80" --publish "mode=host,target=443,published=443"   --mode global --network ags_network registry.cn-hangzhou.aliyuncs.com/ags/image_nginx_proxy:latest
if [ "$?" != 0 ] ;
then
         echo "err! create ags_proxy service err!"         exit 0
else
	echo "success"
fi 

echo "[6/9]deploy stack ags.."
docker stack ps ags
if [ "$?" != 0 ] ;
then
         echo "stack ags isn't existing!,created..."         exit 0
else
	echo "rm old stack..."
        docker stack rm ags
fi
docker stack deploy ags --compose-file=./${COMPOSE_FILENAME}
if [ "$?" != 0 ] ;
then
         echo "err!  stack deploy ags  err!"         exit 0
else
	echo " success"
fi



echo "[7/9]install update cron."
# cron 每天3点10分，执行 update.sh 
echo  "10 3 * * * /usr/local/ags/${UPDATE_SH_FILENAME} > /dev/null 2>&1"  >> /var/spool/cron/root
if [ "$?" != 0 ] ;
then
         echo "err!  set update cron err!"
         exit 0
else
	echo " success"
fi

echo "[8/9]install boot service script."
chmod +x /etc/rc.d/rc.local
echo "/usr/local/${BOOT_SH_FILENAME}"  >> /etc/rc.d/rc.local
if [ "$?" != 0 ] ;
then
         echo "err!  install boot service script  err!"
         exit 0
else
	echo " success"
fi

#echo "[9/]open iptables port...???"
#iptables -I INPUT -p tcp --dport 80 -j ACCEPT&&iptables -I INPUT -p tcp --dport 443 -j ACCEPT
#if [ "$?" != 0 ] ;
#then
#         echo "open iptables port err!"
#         exit 0
#else
#echo " success"
#fi

echo "[9/9]done"
