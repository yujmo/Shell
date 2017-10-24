#!/bin/bash
os_name=`lsb_release -a |grep Distributor |awk '{print $3}'`
echo $os_name
case $os_name in
        CentOS)
        yum update -y > /dev/null
        echo `date`
        ;;
        *)
        echo "Can't get the os name"
        ;;
esac

directory=`ls -F |grep '/$'`
#echo $directory
#for i in $directory
#       do
#       cd /root/$i && git add . && git commit -m "add some files" && git push origin master
#       done
~
