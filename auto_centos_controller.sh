#!/bin/bash
IP=`arp-scan 192.168.0.0/24 |grep 08:00:27:42:93:94|awk '{ print $1 }'`
cat /etc/hosts.bak > /etc/hosts
echo "$IP cc" >> /etc/hosts
ssh -o "StrictHostKeyChecking=no" root@cc bash auto_install_centos_controller.sh

#control 172.26.10.89

#node1 172.26.10.90
#node2 172.26.10.91
#node3 172.26.10.92
#node4 172.26.10.93
#node5 172.26.10.95
#node6 172.26.10.96


