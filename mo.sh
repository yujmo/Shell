#!/bin/bash
echo "WOJIAOmoyujian88"|passwd --stdin root
echo "nameserver 114.114.114.114" > /etc/resolv.conf 
rm -rf /etc/yum.repos.d/CentOS-[CDfMSV]*
yum install yum-utils -y
yum makecache fast
mkdir /etc/docker
touch  /etc/docker/daemon.json
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://ld7jqf2j.mirror.aliyuncs.com"]
}
EOF

echo "hello"


