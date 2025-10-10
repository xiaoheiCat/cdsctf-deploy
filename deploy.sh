#! /bin/bash

echo "Installing K3s..."
curl –sfL \
    https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn sh -s - \
    --system-default-registry "registry.cn-hangzhou.aliyuncs.com" --disable=traefik
