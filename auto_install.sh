#!/bin/bash

#密钥分发
ssh-keygen -N ""
for i in node1 noe2 node3 node4 node5 node6 node7; do sshpass -p WOJIAOmoyujian88 ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $i;done

#hosts文件
echo "172.26.10.92 node1 " >> /etc/hosts #master_1
echo "172.26.10.89 node2 " >> /etc/hosts #master_2
echo "172.26.10.91 node3 " >> /etc/hosts #node1
echo "172.26.10.93 node4 " >> /etc/hosts #node2
echo "172.26.10.90 node5 " >> /etc/hosts #node3
echo "172.26.10.95 node6 " >> /etc/hosts #node4
echo "172.26.10.96 node7 " >> /etc/hosts #node5

#安装必须的软件
[root@k8s_master1 ~]# rpm -ivh epel-release-latest-7.noarch.rpm 
[root@k8s_master1 ~]# yum clean all
[root@k8s_master1 ~]# yum makecache fast
[root@k8s_master1 ~]# yum install python-pip python34 python34-pip -y
[root@k8s_master1 ~]# git clone https://github.com/kubernetes-incubator/kargo.git
[root@k8s_master1 ~]# yum install net-tools python python-devel python-pip -y;done
[root@k8s_master1 ~]# pip install kargo  





