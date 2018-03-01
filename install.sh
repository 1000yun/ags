#!/bin/bash

#设置脚本中所需命令的执行路径
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


mkdir /usr/local/ags
touch /usr/local/ags/install.tmp.log
touch /usr/local/ags/update.tmp.log

LOGFILE=/usr/local/ags/install.tmp.log
TOTLE=9
#NOW=1

date > $LOGFILE


show_log()    ## 函数定义
{

        echo  -e "\n\n ==================== update detail log start ====================================\n"
        cat install.tmp.log #$LOGFILE
        echo -e  "\n\n ==================== update detail log end =======================================\n"
        # return  2      ###返回值其实是状态码，只能在[0-255]范围内
}


echo "[1/${TOTLE}]download install file"
#PACKAGE="ags.tar.gz"
#fileurl="https://github.com/1000yun/ags/raw/master/${PACKAGE}"

COMPOSE_FILENAME="docker-compose.yml"
BOOT_SH_FILENAME="start_swarm.sh"
UPDATE_SH_FILENAME="update.sh"

# wget -nv $fileurl
# if [ "$?" != 0 ] ;
# then
#         echo "download file err!!!"
#         exit 0
#else
#        echo "success,download"
# fi

# tar zxvf ${PACKAGE} -C /usr/local/ags
#unzip ${PACKAGE} -d /usr/local/ags

cd /usr/local/ags

filepre="https://github.com/1000yun/ags/raw/master/"
wget -Nv ${filepre}${COMPOSE_FILENAME}
wget -Nv ${filepre}${BOOT_SH_FILENAME}
wget -Nv ${filepre}${UPDATE_SH_FILENAME}

chmod +x /usr/local/ags/${UPDATE_SH_FILENAME}
chmod +x /usr/local/ags/${BOOT_SH_FILENAME}
echo " success,change install file"

echo "[2/${TOTAL}]check docker install..."   | tee -a $LOGFILE
rpm -qa | grep docker >> $LOGFILE
if [ "$?" != 0 ] ;
then
         echo "error! not find docker!!!" | tee -a $LOGFILE
         exit 0
else
        echo " success" | tee -a $LOGFILE	

fi

echo "[3/${TOTAL}]check docker version..."   | tee -a $LOGFILE
DOCKER_INFO=`rpm -qa | grep docker`
VERSION_NOW=`echo $DOCKER_INFO | grep  -o "\([0-9]*\.[0-9]*\)" |  head -n1`
VERSION_NEED=17.04
VERSION_OK=`echo $VERSION_NOW $VERSION_NEED |awk '{if($1>$2){print 1;}else{print 0;}}'`
if [ $VERSION_OK -eq 1 ];
then
        echo "now docker version:$VERSION_NOW" | tee -a $LOGFILE
        echo " success"
else
        echo "the docker version at least  more then 17.04" | tee -a $LOGFILE
	exit 0 
fi



echo "[4/${TOTAL}]init swarm" | tee -a $LOGFILE
docker swarm join-token manager >> $LOGFILE
if [ "$?" != 0 ] ;
then
         echo "docker swarm not existing,create..." | tee -a $LOGFILE
         docker swarm init   >> $LOGFILE
        if [ "$?" != 0 ] ;
	then
                 echo "err! swarm init err!"  | tee -a $LOGFILE
                 exit 0
        else
                echo " success,swarm init" | tee -a $LOGFILE
        fi
else
        echo " success,the swarm has been created!" | tee -a $LOGFILE
fi

echo "[5/${TOTAL}]check netwrok.." | tee -a $LOGFILE
docker network inspect   ags_network >>  $LOGFILE
if [ "$?" != 0 ] ;
then
        echo "ags_network not existing,create..." | tee -a $LOGFILE
        docker network create   -d overlay ags_network >> $LOGFILE
        if [ "$?" != 0 ] ;
        then
                 echo "err! create new network err!" | tee -a $LOGFILE
                 exit 0
        else
                echo " success,create new ags_network" | tee -a $LOGFILE
        fi
else
        echo " success,ags_nework existing" | tee -a $LOGFILE
fi



echo "[6/${TOTAL}]deploy stack ags.." | tee -a $LOGFILE
docker stack ps ags >> $LOGFILE
if [ "$?" != 0 ] ;
then
         echo "stack ags is existing!,will create..."  | tee -a $LOGFILE 
else
        echo "stack ags is not existing,will udpate"  | tee -a $LOGFILE
#        docker stack rm ags
fi

docker stack deploy ags --compose-file=./${COMPOSE_FILENAME}  >> $LOGFILE
if [ "$?" != 0 ] ;
then
        echo "err!  stack deploy ags  err!"  | tee -a $LOGFILE 
	exit 0
else
        echo " success"   | tee -a $LOGFILE
fi


echo "[7/${TOTAL}]create ags_proxy service.."  | tee -a $LOGFILE
docker service ps ags_proxy  >> $LOGFILE
if [ "$?" != 0 ] ;
then
        echo "service_proxy service isn't existing,create..."  | tee -a $LOGFILE
        if [ "$?" != 0 ] ;
        then
                echo "err! create ags_proxy service err!"          | tee -a $LOGFILE
		exit 0
        else
                echo "success"  | tee -a $LOGFILE
        fi
else
        echo "success,the  ags_proxy service is existing"  | tee -a $LOGFILE
#        docker service rm ags_proxy
fi


echo "[8/${TOTAL}]install update cron."  | tee -a $LOGFILE

if grep -q "/usr/local/ags/${UPDATE_SH_FILENAME}"  /var/spool/cron/root
then
	echo "success,update cron task is existing."  | tee -a $LOGFILE
else
	# cron 每天3点10分，执行 update.sh
	echo  "10 3 * * * /usr/local/ags/${UPDATE_SH_FILENAME} > /dev/null 2>&1"  >> /var/spool/cron/root
	if [ "$?" != 0 ] ;
	then
        	 echo "err!  set update cron err!"   | tee -a $LOGFILE
	         exit 0
	else
        	echo " success"  | tee -a $LOGFILE
	fi

fi

#echo "[8/9]install boot service script."  | tee -a $LOGFILE
#if grep -q "/usr/local/ags/${BOOT_SH_FILENAME}"  /etc/rc.d/rc.local
#then
#        echo "success,the boot script is existing."  | tee -a $LOGFILE
#else
#	chmod +x /etc/rc.d/rc.local
#	echo "/usr/local/ags/${BOOT_SH_FILENAME}"  >> /etc/rc.d/rc.local
#	if [ "$?" != 0 ] ;
#	then
#        	 echo "err!  install boot service script  err!"  | tee -a $LOGFILE
#	         exit 0
#	else
#        	echo " success"  | tee -a $LOGFILE
#	fi
#fi



echo "[9/${TOTAL}]done"  | tee -a $LOGFILE
