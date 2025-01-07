#!/bin/bash
set -e

# Source: https://gist.github.com/burgossrodrigo/790406f04f6bd38d4baee0364fce2f04
# Adapted by: joweyel

# Update the system
apt-get update -y
apt-get upgrade -y

# Install Git
apt-get install -y git

# Install Docker
apt-get install -y apt-transport-https ca-certificates wget curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the 'ubuntu' to the Docker group
usermod -aG docker ubuntu
id ubuntu
newgrp docker

# Enable and start Docker
systemctl enable docker.service
systemctl start docker.service

# Install Docker Compose v2
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Add swap space
dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab

# Get Source Code
mkdir /home/ubuntu/app
git clone https://github.com/joweyel/DataEngineering-books-project.git /home/ubuntu/app
chown ubuntu:ubuntu -R /home/ubuntu/app
cd /home/ubuntu/app

# Fill docker-compose template
cat << EOF > docker-compose.yml
${docker_compose_yaml}
EOF

# Start Docker containers
docker-compose up -d