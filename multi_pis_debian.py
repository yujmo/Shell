#!/bin/bash

#更新系统，安装常用的软件
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install arp-scan -y && sudo apt-get install python python-pip -y \
     && sudo apt-get install ansible -y

#获取当前网段
nets=`ifconfig wlan0|grep mask|awk '{print $6}'|awk -F '.' 'BEGIN{OFS="."} END{print and($1,$1),and($2,$2),and($3,$3),and($10,$10)}'`

#利用ARP协议对网段内主机进行扫描，找出符合条件的主机
sudo arp-scan $nets/24 |grep Raspberry | awk '{print $2,$1}' > /home/pi/cache_hosts

#更改文件权限
sudo chmod 777 /etc/ansible/hosts

#使用python改写/etc/ansible/hosts文件
python /home/pi/rewrite_ansible_hosts.py

#ansible执行命令
ansible /home/pi/pi.yaml
