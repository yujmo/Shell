#!/bin/bash
export NODE_NAME="etcd-""${HOSTNAME}"
export NODE_IP=`ifconfig | grep 'inet'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}' |grep 10.0.2`
export NODE_IPS="10.0.2.11 10.0.2.12 10.0.2.31"
echo $NODE_NAME
