#!/bin/bash
NODE_IP=`ifconfig | grep 'inet'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}' |grep 10.0.2` 
echo "******"|passwd --stdin root
echo "nameserver 114.114.114.114" > /etc/resolv.conf 
rm -rf /etc/yum.repos.d/CentOS-[CDfMSV]*
yum install yum-utils -y
yum makecache fast

tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://ld7jqf2j.mirror.aliyuncs.com"]
}
EOF

head -c 16 /dev/urandom | od -An -t x | tr -d ' '

IP=`arp-scan 192.168.0.0/24 |grep 08:00:27:42:93:94|awk '{ print $1 }'`

sshpass -p ****** ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $i
