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

# 如果当前算法不是BBR，则启用BBR
if [ "$current_algo" != "bbr" ]; then
    echo "BBR未启用，正在启用BBR..."

    # 检查并更新net.core.default_qdisc
    if grep -q "net.core.default_qdisc" /etc/sysctl.conf; then
        sudo sed -i 's/^net.core.default_qdisc=.*/net.core.default_qdisc=fq/' /etc/sysctl.conf
    else
        echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
    fi

    # 检查并更新net.ipv4.tcp_congestion_control
    if grep -q "net.ipv4.tcp_congestion_control" /etc/sysctl.conf; then
        sudo sed -i 's/^net.ipv4.tcp_congestion_control=.*/net.ipv4.tcp_congestion_control=bbr/' /etc/sysctl.conf
    else
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
    fi

    # 应用更改
    sudo sysctl -p

    echo "BBR已启用。"
else
    echo "BBR已经启用。"
fi
