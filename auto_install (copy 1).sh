#!/bin/bash
#一个控制节点
#一个master
#两个node
#在hosts文件中修改

#密钥分发
ssh-keygen -N ""
for i in localhost master node1 node2; do sshpass -p admin ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $i;done

#安装必须的软件
for i in master node1 node2; do ssh $i yum install net-tools -y;done
#分发hosts文件
for i in master node1 node2; do scp /etc/hosts $i:/etc/hosts;done

#备份bashrc文件
for i in master node1 node2; do ssh $i cp /etc/bashrc /etc/bashrc.bak;done

#写入环境变量（由于不会将脚本结合在一起，就分开写了）
touch temp_environment.sh
tee temp_environment.sh <<- EOF
#!/bin/bash
echo  "BOOTSTRAP_TOKEN='41f7e4ba8b7be874fcff18bf5cf41a7c'                                                                
SERVICE_CIDR='10.254.0.0/16'                                                                                            
CLUSTER_CIDR='172.30.0.0/16'                                                                                             
NODE_PORT_RANGE='8400-9000'                                                                                              
ETCD_ENDPOINTS='https://master:2379,https://node1:2379,https://node2:2379'                                               
FLANNEL_ETCD_PREFIX='/kubernetes/network'                                                                                
CLUSTER_KUBERNETES_SVC_IP='10.254.0.1'                                                                            
CLUSTER_DNS_SVC_IP='10.254.0.2'                                                                                         
CLUSTER_DNS_DOMAIN='cluster.local.'" >> /etc/bashrc
EOF
for i in master node1 node2;do ssh $i mkdir -p /root/local/bin/;done
for i in master node1 node2;do scp /root/temp_environment.sh $i:/root/local/bin/environment.sh;done
for i in master node1 node2;do ssh $i bash /root/local/bin/environment.sh;done
for i in master node1 node2;do ssh $i rm -rf /root/local/bin/environment.sh;done

#控制节点安装cfssl
#环境变量
echo "PATH=/root/local/bin:$PATH" >> /etc/bashrc
for i in master node1 node2;do ssh $i echo "PATH=/root/local/bin:$PATH" >> /etc/bashrc;done
for i in master node1 node2;do ssh $i source /etc/bashrc;done

wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /root/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /root/local/bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /root/local/bin/cfssl-certinfo

for i in master node1 node2;do scp /root/local/bin/cfssl* $i:/root/local/bin/;done
for i in master node1 node2;do ssh $i chmod +x /root/local/bin/cfssl*;done
 
#制作ca证书
mkdir -p /root/ssl
touch /root/ssl/ca-config.json
tee /root/ssl/ca-config/json <<- 'EOF'
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF
touch /root/ssl/ca-csr.json
tee /root/ssl/ca-csr.json <<- 'EOF'
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
cfssl gencert -initca /root/ssl/ca-csr.json|cfssljson -bare ca
mv ca* /root/ssl/ 
for i in localhost master node1 node2;do ssh $i mkdir -p /etc/kubernetes/ssl ;done
for i in localhost master node1 node2;do scp /root/ssl/ca* $i:/etc/kubernetes/ssl/ ;done

#部署etcd集群
touch cache.sh
tee cache.sh <<- 'EOF'
#!/bin/bash
echo "NODE_NAME=etcd-$HOSTNAME
NODE_IP=`ifconfig | grep 'inet'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}' |grep 10.0.2`
#NODE_IPS="10.0.2.11 10.0.2.12 10.0.2.31"
ETCD_NODES="etcd-master=https://master:2380,etcd-node1=https://node1:2380,etcd-node2=https://node2:2380"" >> /etc/bashrc
EOF

for i in master node1 node2;do scp cache.sh $i:/root/local/bin/cache.sh ;done
for i in master node1 node2;do ssh $i bash /root/local/bin/cache.sh ;done
for i in master node1 node2;do ssh $i source /etc/bashrc;done
wget http://58.193.0.178/etcd-v3.1.6-linux-amd64.tar.gz
tar -xzvf etcd-v3.1.6-linux-amd64.tar.gz
for i in master node1 node2;do scp etcd-v3.1.6-linux-amd64/etcd* $i:/root/local/bin ;done

touch etcd-csr.json
tee etcd-csr.json <<- 'EOF'
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "${NODE_IP}"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
for i in master node1 node2;do ssh $i mkdir -p /etc/etcd/ssl;done
for i in master node1 node2;do scp etcd-csr.json $i:/etc/etcd/ssl;done
touch etcd_ca.sh
tee etcd_ca.sh <<- 'EOF'
#!/bin/bash
/root/local/bin/cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem -ca-key=/etc/kubernetes/ssl/ca-key.pem -config=/etc/kubernetes/ssl/ca-config.json -profile=kubernetes /etc/etcd/ssl/etcd-csr.json | /root/local/bin/cfssljson -bare etcd
EOF

for i in master node1 node2;do scp etcd_ca.sh $i:/etc/etcd/etcd_ca.sh;done
for i in master node1 node2;do ssh $i bash /etc/etcd/etcd_ca.sh;done
for i in master node1 node2;do ssh $i mv /root/etcd*.pem /etc/etcd/ssl/ ;done

for i in master node1 node2;do ssh $i mkdir -p /var/lib/etcd ;done
touch etcd.service
tee etcd.service <<- 'EOF'
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/root/local/bin/etcd \
  --name=${NODE_NAME} \
  --cert-file=/etc/etcd/ssl/etcd.pem \
  --key-file=/etc/etcd/ssl/etcd-key.pem \
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls=https://${NODE_IP}:2380 \
  --listen-peer-urls=https://${NODE_IP}:2380 \
  --listen-client-urls=https://${NODE_IP}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls=https://${NODE_IP}:2379 \
  --initial-cluster-token=etcd-cluster-0 \
  --initial-cluster=${ETCD_NODES} \
  --initial-cluster-state=new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
rm -rf etcd.service


for i in master node1 node2;do scp etcd.service $i:/etc/systemd/system/;done
for i in master node1 node2;do ssh $i systemctl daemon-reload;done
for i in master node1 node2;do ssh $i systemctl enable etcd;done
for i in master node1 node2;do ssh $i systemctl start etcd;done

#ssh node1  for ip in ${NODE_IPS}; do ETCDCTL_API=3 /root/local/bin/etcdctl --endpoints=https://${ip}:2379 --cacert=/etc/kubernetes/ssl/ca.pem   --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem  endpoint health;done
