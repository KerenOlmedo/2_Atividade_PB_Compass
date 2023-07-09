sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker $(ec2-user)
sudo chkconfig docker on
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo yum install git
sudo mkdir /mnt/efs
sudo mkdir /mnt/efs/wordpress
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-0924babb32c0feaa2.efs.us-east-1.amazonaws.com:/ /mnt/efs

export WORDPRESS_DB_HOST="dbwordpress.czuctyrea21y.us-east-1.rds.amazonaws.com"
export WORDPRESS_DB_USER="adminPB"
export WORDPRESS_DB_PASSWORD="estagioCompass" 
export WORDPRESS_DB_NAME="dbwordpress"

sudo cd /home/ec2-user
sudo git clone https://github.com/KerenOlmedo/2_Atividade_PB_Compass.git
sudo cd 2_Atividade_PB_Compass
sudo docker compose up -d