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


echo "admin123"|passwd --stdin root
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
