#!/bin/bash
yum update -y
yum install -y docker
service docker start
chkconfig docker on
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
usermod -aG docker ec2-user
yum install -y git
mkdir /mnt/efs
mkdir /mnt/efs/wordpress
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-XXXXXXXXXXXX.amazonaws.com:/ /mnt/efs

export WORDPRESS_DB_HOST="XXXXX"
export WORDPRESS_DB_USER="XXXXX"
export WORDPRESS_DB_PASSWORD="XXXXX" 
export WORDPRESS_DB_NAME="XXXXX"

cd /home/ec2-user
git clone https://github.com/KerenOlmedo/2_Atividade_PB_Compass.git
cd 2_Atividade_PB_Compass
docker-compose up -d
