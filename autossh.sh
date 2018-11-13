#!/bin/bash

#反向代理，将内网主机暴露到具有公网IP的服务器中
autossh -M 7281 -fCNR 7280:127.0.0.1:22 root@xxx.xxx.xxx -p 22
# 如果不成功，端口被占用，可以去掉-f。还有公钥问题
