#! /bin/bash

echo "Changing Directory..."
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
echo "Done!"

read -p "What is your server entry: " cdsctf_entry

echo "Installing Docker..."
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installing K3s..."
curl -sfL \
    https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn sh -s - \
    --system-default-registry "registry.cn-hangzhou.aliyuncs.com" --disable=traefik
    
echo "Configuring K3s..."
sudo cat /etc/rancher/k3s/k3s.yaml > ./configs/k8s.yml
sed -i 's/127.0.0.1/172.20.0.1/g' ./configs/k8s.yml
sudo systemctl stop k3s
sudo bash -c 'echo "tls-san:" > /etc/rancher/k3s/config.yaml'
sudo bash -c 'echo "  - 172.20.0.1" >> /etc/rancher/k3s/config.yaml'
sudo rm /var/lib/rancher/k3s/server/tls/server-ca.crt
sudo rm /var/lib/rancher/k3s/server/tls/server-ca.key
sudo systemctl start k3s

echo "Configuring CdsCTF..."
sudo apt-get install -y openssl
cdsctf_jwt=$(openssl rand -hex 32)
sed -i "s/REPLACE_WITH_YOUR_SERVER_ENTRY/$cdsctf_entry/g" ./configs/config.toml
sed -i "s/REPLACE_WITH_A_RANDOM_STRING/$cdsctf_jwt/g" ./configs/config.toml

echo "Starting..."
sudo docker compose up -d

echo "Successed!"
echo "Looking at http://$cdsctf_entry for your CdsCTF instance!"
