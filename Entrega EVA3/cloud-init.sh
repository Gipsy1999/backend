#!/bin/bash
apt-get update
apt-get upgrade -y
timedatectl set-timezone America/Santiago
apt-get install -y curl wget git htop net-tools ufw unzip vim
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
apt-get install -y docker-compose-plugin
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw allow 8081/tcp
ufw allow 8082/tcp
ufw allow 8083/tcp
ufw allow 8084/tcp
ufw --force enable
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
echo 'vm.swappiness=10' >> /etc/sysctl.conf
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.core.somaxconn=1024' >> /etc/sysctl.conf
sysctl -p
mkdir -p /home/ubuntu/levelup
chown ubuntu:ubuntu /home/ubuntu/levelup
systemctl enable docker
apt-get autoremove -y
apt-get clean
echo "Inicializacion completada" > /home/ubuntu/init-complete.log
