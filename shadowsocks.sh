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

#开启debian的bbr拥堵算法
# 检查当前TCP拥塞控制算法
current_algo=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')

# 如果当前算法不是BBR，则启用BBR
if [ "$current_algo" != "bbr" ]; then
    echo "BBR未启用，正在启用BBR..."
    
    # 将BBR配置添加到sysctl.conf
    echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf

    # 应用更改
    sudo sysctl -p

    echo "以为你启用BBR。"
else
    echo "BBR已经启用。"
fi
