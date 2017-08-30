#!/bin/bash
touch cache.sh
tee cache.sh <<- 'EOF'                                                                                 
#!/bin/bash                                                                                                               
echo "NODE_NAME=etcd-$HOSTNAME                                                                                            
NODE_IP=`ifconfig | grep 'inet'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}' |grep 10.0.2`                      
#NODE_IPS="10.0.2.11 10.0.2.12 10.0.2.31"                                                                                 
ETCD_NODES="etcd-master=https://master:2380,etcd-node1=https://node1:2380,etcd-node2=https://node2:2380" " >> /etc/bashrc 
'EOF'   

