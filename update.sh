
#!/bin/bash
 
#设置脚本中所需命令的执行路径
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LOGFILE=/usr/local/ags/update.tmp.log
#echo $logfile
date > $LOGFILE


show_log()    ## 函数定义
{

	echo  -e "\n\n ==================== update detail log start ====================================\n"
        cat update.tmp.log #$LOGFILE
	echo -e  "\n\n ==================== update detail log end =======================================\n"
        # return  2      ###返回值其实是状态码，只能在[0-255]范围内
}   


echo "[1/12]check docker install..." | tee $LOGFILE  
rpm -qa | grep docker >>  $LOGFILE  2>&1

#exit 0

#检查docker 是否安装 
# $? 是取得上面执行命令的返回值，一般正确为0，错误为1
if [ "$?" != 0 ] ;
then
 #echo 为输出到屏幕
 echo "err! not find docker,please install docker first!" | tee -a $LOGFILE
 show_log
 exit 0
else
 echo "success!"  | tee -a $LOGFILE
fi

echo -e  | tee -a $LOGFILE
echo  "[2/12] check ags_proxy service..." | tee -a $LOGFILE
docker service ps ags_proxy >> $LOGFILE  2>&1

if [ "$?" != 0 ] ;
      then
       echo "err! can't find ags_proxy serivce!please install first!" | tee -a $LOGFILE
       show_log
       exit 0
    else	
       echo "success!" | tee -a $LOGFILE
fi 


echo -e  | tee -a $LOGFILE
echo  "[3/12]check ags_openresty service"
docker service ps ags_openresty  >> $LOGFILE  2>&1

if [ "$?" != 0 ] ;
      then
       	   echo "error! can't find ags_openresty serivce !please install first!"  | tee -a $LOGFILE
           show_log
           exit 0
       else
 	   echo "success!"  | tee -a $LOGFILE
fi

echo -e  | tee -a $LOGFILE
echo  "[4/12]check ags_webadmin service"  | tee -a $LOGFILE
docker service ps ags_webadmin   >> $LOGFILE  2>&1

if [ "$?" != 0 ] ;
      then 
         echo "error! can't find ags_webadmin serivce !please install first!" | tee -a $LOGFILE
         show_log
         exit 0
      else
         echo "success!"  | tee -a $LOGFILE
fi

echo -e  | tee -a $LOGFILE
echo  "[4/12]check ags_webjs service"  | tee -a $LOGFILE
docker service ps ags_webjs   >> $LOGFILE  2>&1

if [ "$?" != 0 ] ;
      then
         echo "error! can't find ags_webjs serivce !please install first!" | tee -a $LOGFILE
         show_log
         exit 0
      else
         echo "success!"  | tee -a $LOGFILE
fi



echo -e  | tee -a $LOGFILE
echo  "[5/12]check ags_redis service"  | tee -a $LOGFILE
docker service ps ags_redis  >> $LOGFILE  2>&1

if [ "$?" != 0 ] ;
      then
         echo "error! can't find ags_redis serivce !please install first!" | tee -a $LOGFILE
         show_log
         exit 0
      else
         echo "success!"  | tee -a $LOGFILE
fi

# check ags service
echo -e  | tee -a $LOGFILE
echo  "[6/12]check ags_es"  | tee -a $LOGFILE
docker service ps ags_es  >> $LOGFILE  2>&1

if [ "$?" != 0 ] ;
      then
       echo "error! can't find  ags_es serivce ! please install first!"  | tee -a $LOGFILE
       show_log
       exit 0
     else
         echo "success!"  | tee -a $LOGFILE

fi

#exit 0

echo -e  | tee -a $LOGFILE
echo "[7/12]update ags_proxy service,need about 3 minutes,please wait..."  | tee -a $LOGFILE
docker service update --image registry.cn-hangzhou.aliyuncs.com/ags/image_nginx_proxy  ags_proxy >> $LOGFILE  2>&1
if [ "$?" != 0 ] ;
      then    
       echo "error! can't find  ags_proxy serivce ! please install first!"  | tee -a $LOGFILE
       show_log
       exit 0  
     else    
         echo "success!"  | tee -a $LOGFILE

fi

echo -e  | tee -a $LOGFILE
echo "[8/12]update ags_redis service,need about 3 minutes,please wait..."  | tee -a $LOGFILE


docker service update --image registry.cn-hangzhou.aliyuncs.com/ags/image_redis  ags_redis >> $LOGFILE  2>&1
if [ "$?" != 0 ] ;
      then    
       echo "err!  update service ags_reidis serivce err"  | tee -a $LOGFILE
       show_log
       exit 0  
     else    
         echo "success!"  | tee -a $LOGFILE

fi

echo -e  | tee -a $LOGFILE
echo "[9/12]update ags_es service,need about 3 minutes,please wait..."  | tee -a $LOGFILE

docker service update --image registry.cn-hangzhou.aliyuncs.com/ags/image_elasticsearch  ags_es >> $LOGFILE  2>&1
if [ "$?" != 0 ] ;
      then    
       echo "err! update  ags_es serivce err!"  | tee -a $LOGFILE
       show_log
       exit 0  
     else    
         echo "success!"  | tee -a $LOGFILE

fi


echo -e  | tee -a $LOGFILE
echo "[10/12]update ags_openresty service,need about 3 minutes,please wait..."  | tee -a $LOGFILE

docker service update --image registry.cn-hangzhou.aliyuncs.com/ags/image_openresty  ags_openresty >> $LOGFILE  2>&1
if [ "$?" != 0 ] ;
      then    
       echo "err! update  ags_openresty serivce err!"  | tee -a $LOGFILE
       show_log
       exit 0  
     else    
         echo "success!"  | tee -a $LOGFILE

fi


echo -e  | tee -a $LOGFILE
echo "[11/12]update ags_webadmin service,need about 10 minutes,please wait..."  | tee -a $LOGFILE

docker service update --image registry.cn-hangzhou.aliyuncs.com/ags/image_nginx_webadmin  ags_webadmin >> $LOGFILE  2>&1
if [ "$?" != 0 ] ;
      then    
       echo "err! update  ags_webadmin serivce err !"  | tee -a $LOGFILE
       show_log
       exit 0  
     else    
         echo "success!"  | tee -a $LOGFILE

fi

echo -e  | tee -a $LOGFILE
echo "[11/12]update ags_webjs service,need about 10 minutes,please wait..."  | tee -a $LOGFILE

docker service update --image registry.cn-hangzhou.aliyuncs.com/ags/image_nginx_client_js  ags_webjs >> $LOGFILE  2>&1
if [ "$?" != 0 ] ;
      then
       echo "err! update  ags_webjs serivce err !"  | tee -a $LOGFILE
       show_log
       exit 0
     else
         echo "success!"  | tee -a $LOGFILE

fi


#检查程序是否安装成功

echo -e  | tee -a $LOGFILE
echo "[12/12]done" | tee -a $LOGFILE
