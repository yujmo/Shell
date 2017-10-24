#!/bin/bash
yum update -y > /dev/null
directory=`ls -F |grep '/$'`
#echo $directory
for i in $directory
        do
        cd /root/$i && git add . && git commit -m "add some files" && git push origin master
        done
