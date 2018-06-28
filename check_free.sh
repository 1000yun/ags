#!/bin/bash

mt=`free | tr [:blank:] \\\n | grep [0-9] | sed -n '1p'`
st=`free | tr [:blank:] \\\n | grep [0-9] | sed -n '9p'`
t=`expr $mt + $st`


echo "Total Mem: $t"
 
if [ $t -lt 1800000 ]
then 
	echo "the momery need at least 2G"
fi
