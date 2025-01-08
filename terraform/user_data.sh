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
apt-get install -y apt-transport-https ca-certificates wget curl software-properties-common unzip postgresql-client
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

# Install AWS CLI v2 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
unzip awscliv2.zip 
sudo ./aws/install

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

# Get environment variables only for current session 
export AWS_REGION="${aws_region}"
# export AWS_ACCESS_KEY_ID="${aws_access_key_id}"
# export AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}"
export ROLE_ARN="${role_arn}"
export KAGGLE_USERNAME="${kaggle_username}"
export KAGGLE_KEY="${kaggle_key}"
export PROJECT_NAME="${project_name}"
export POSTGRES_DBNAME="${postgres_dbname}"
export POSTGRES_SCHEMA="${postgres_schema}"
export POSTGRES_USER="${postgres_user}"
export POSTGRES_PASSWORD="${postgres_password}"
export POSTGRES_HOST="${postgres_host}"
export POSTGRES_PORT="${postgres_port}"
export S3_BUCKET_NAME="${s3_bucket_name}"
export POSTGRES_CONNECT_TIMEOUT="${postgres_timeout}"

# Start Docker containers
docker-compose up -d