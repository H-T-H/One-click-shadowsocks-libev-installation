#!/bin/bash

# 检查是否以root用户运行
if [[ $EUID -ne 0 ]]; then
    echo "请以root用户运行此脚本"
    exit 1
fi

# 更新系统
apt update
apt upgrade -y

# 安装shadowsocks libev
sudo apt-get install shadowsocks-libev -y

#写入配置文件
cat > /etc/shadowsocks-libev/config.json <<EOL
{
  "server": "0.0.0.0",
  "server_port": 1,
  "password": "teddysun.com",
  "method": "aes-256-gcm",
  "timeout": 600,
  "no_delay": true,
  "mode": "tcp_only"
}
EOL

#重新启动
sudo systemctl restart shadowsocks-libev
