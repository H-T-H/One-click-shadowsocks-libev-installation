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
apt-get install -y git gettext build-essential unzip gzip python python-dev python-setuptools curl openssl libssl-dev autoconf automake libtool gcc make perl cpio libpcre3 libpcre3-dev zlib1g-dev libev-dev libc-ares-dev git qrencode

# 运行autoreconf
autoreconf -i

# 下载并安装Shadowsocks-libev
# 从GitHub上获取发布版本
RELEASE_URL="https://github.com/shadowsocks/shadowsocks-libev/releases/latest"
TAG=$(wget -qO- "$RELEASE_URL" | grep -oP '(?<=tag/)[^"]+')
wget "https://github.com/shadowsocks/shadowsocks-libev/archive/$TAG.tar.gz"
tar -zxvf "$TAG.tar.gz"
cd "shadowsocks-libev-$TAG"

# 运行autoreconf
autoreconf --force --install

# 继续安装
./configure
make && make install

# 创建配置文件
cp ./debian/shadowsocks-libev.init /etc/init.d/shadowsocks-libev
chmod +x /etc/init.d/shadowsocks-libev
cp ./debian/shadowsocks-libev.default /etc/default/shadowsocks-libev

# 启动Shadowsocks-libev服务
/etc/init.d/shadowsocks-libev start

# 设置开机自启动
update-rc.d shadowsocks-libev defaults

# 创建Shadowsocks-libev配置文件
mkdir -p /etc/shadowsocks-libev
cp ./debian/config.json /etc/shadowsocks-libev/config.json

echo "Shadowsocks-libev安装完成，配置文件位于 /etc/shadowsocks-libev/config.json"
