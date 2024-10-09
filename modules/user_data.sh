#!/bin/bash

# Atualiza os pacotes da instância
sudo yum update -y 

# Instala o Docker
sudo amazon-linux-extras install docker -y 

# Habilita o Docker para iniciar automaticamente com o sistema
sudo systemctl enable docker 

# Inicia o serviço do Docker imediatamente
sudo systemctl start docker 

# Adiciona o usuário 'ec2-user' ao grupo 'docker'
sudo usermod -aG docker ec2-user 

# Instala o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dá permissão de execução para o Docker Compose
sudo chmod +x /usr/local/bin/docker-compose 

# Garante que o serviço Docker está sempre rodando
sudo systemctl restart docker 

# Ajusta o horário para facilitar a visualização dos logs do container
sudo timedatectl set-timezone America/Sao_Paulo 

# Instala as ferramentas NFS (necessário para montar o EFS)
sudo yum install -y nfs-utils 
sudo yum install -y amazon-efs-utils 

# Cria um diretório para o ponto de montagem do EFS
sudo mkdir -p /mnt/efs 

# Obtém os IDs do EFS e do DB do Terraform
EFS_ID=$(terraform output -raw efs_id)  # Substitua 'efs_id' pelo nome exato do output
DB_ENDPOINT=$(terraform output -raw db_endpoint)  # Substitua 'db_endpoint' pelo nome exato do output

# Monta o EFS
sudo mount -t efs -o tls ${EFS_ID}:/ /mnt/efs 

# Adiciona a montagem ao fstab para persistência
echo "${EFS_ID}:/ /mnt/efs efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab 

# Cria o arquivo .env no diretório home do usuário
cat <<EOF > /home/ec2-user/.env
DB_NAME="wordpress"
DB_USER="admin"
DB_PASSWORD="admin_password"
DB_ENDPOINT="${DB_ENDPOINT}"
EOF

# Cria o arquivo docker-compose.yml no diretório home do usuário
cat <<EOF > /home/ec2-user/docker-compose.yml
version: '3.8'

services:
  wordpress:
    image: wordpress:6.3
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    env_file:
      - .env  # Referenciando o arquivo .env
    volumes:
      - /mnt/efs:/var/www/html
    networks:
      - wp-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

networks:
  wp-network:
    driver: bridge

volumes:
  db_data:
EOF

# Altera a propriedade dos arquivos para o usuário ec2-user
sudo chown ec2-user:ec2-user /home/ec2-user/.env /home/ec2-user/docker-compose.yml

# Inicia os serviços do Docker Compose
cd /home/ec2-user
docker-compose up -d

# Instalar o repositório EPEL
sudo amazon-linux-extras install epel -y

# Instalar o stress-ng
sudo yum install stress-ng -y




