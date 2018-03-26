#!/bin/bash

#反向代理，将内网主机暴露到具有公网IP的服务器中
autossh -M 7281 -fCNR 7280:127.0.0.1:80 root@xxx.xxx.xxx.xxx -p 22
