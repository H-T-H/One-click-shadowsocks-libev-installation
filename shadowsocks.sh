#!/bin/bash

# 检查是否以root用户运行
if [[ $EUID -ne 0 ]]; then
    echo "请以root用户运行此脚本"
    exit 1
fi

# 更新系统安装snap
apt update
apt upgrade -y
sudo apt install snapd -y
sudo snap install core

# 安装shadowsocks libev
sudo snap install shadowsocks-libev

#写入配置文件
cat > /snap/bin/config.json <<EOL
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

# 设置开机自启动
cat > /etc/systemd/system/ss.service <<EOL
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
Restart=on-abnormal
ExecStart=/snap/bin/shadowsocks-libev.ss-server -c /snap/bin/config.json

[Install]
WantedBy=multi-user.target
EOL




echo "Shadowsocks-libev安装完成，配置文件位于 /etc/shadowsocks-libev/config.json"
