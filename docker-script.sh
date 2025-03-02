#!/bin/bash

growpart /dev/nvme0n1 4

lvextend -l +50%FREE /dev/RootVG/rootVol

lvextend -l +50%FREE /dev/RootVG/varVol

xfs_growfs /

xfs_growfs /var

sudo dnf -y install dnf-plugins-core

sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 

sudo systemctl start docker 

sudo systemctl enable docker

usermod -aG docker ec2-user

docker run hello-world

# sudo systemctl reboot
