#!/bin/bash

# 检查是否以root用户运行
if [[ $EUID -ne 0 ]]; then
    echo "请以root用户运行此脚本"
    exit 1
fi

# 更新系统
apt update
apt upgrade -y

# 安装依赖
apt install -y wget git build-essential autoconf libtool libssl-dev

# 下载并安装Shadowsocks-libev
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh
./configure
make && make install

# 创建配置文件
cp ./debian/shadowsocks-libev.init /etc/init.d/shadowsocks-libev
chmod +x /etc/init.d/shadowsocks-libev
cp ./debian/shadowsocks-libev.default /etc/default/shadowsocks-libev

# 修改配置文件
CONFIG_FILE="/etc/shadowsocks-libev/config.json"
cat <<EOF >$CONFIG_FILE
{
    "server":"0.0.0.0",
    "server_port":1,
    "password":"teddysun.com",
    "method":"aes-256-gcm"
}
EOF

# 启动Shadowsocks-libev服务
/etc/init.d/shadowsocks-libev start

# 设置开机自启动
update-rc.d shadowsocks-libev defaults

echo "Shadowsocks-libev安装完成，配置文件位于 $CONFIG_FILE"
