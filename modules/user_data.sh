#!/bin/bash

sudo yum update -y # Atualiza os pacotes da instância

sudo amazon-linux-extras install docker -y # Instala o Docker

sudo systemctl enable docker # Habilita o Docker para iniciar automaticamente com o sistema

sudo systemctl start docker # Inicia o serviço do Docker imediatamente

sudo usermod -aG docker ec2-user # Adiciona o usuário 'ec2-user' ao grupo 'docker'

# Instala o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose # Dá permissão de execução para o Docker Compose

sudo systemctl restart docker # Garante que o serviço Docker está sempre rodando

sudo yum install -y nfs-utils # Instalar as ferramentas NFS (necessário para montar o EFS)

sudo yum install -y amazon-efs-utils

sudo mkdir -p /mnt/efs # Cria um diretorio para o ponto de montagem

EFS_DNS=$(terraform output -raw efs_dns) # Variáveis do EFS

sudo mount -t efs -o tls ${EFS_DNS}:/ /mnt/efs

echo "${EFS_DNS}:/ /mnt/efs efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab # Adicionar a montagem ao fstab para persistência

sudo yum install git -y # Instalando o git na maquina

cd home # Acessando o diretorio home

sudo git clone https://github.com/EdilsonMaria/Docker-Compose_WordPress # Baixar o docker-compose.yml do repositório do GitHub
 
cd Docker-Compose_WordPress #Acessando o diretorio com o docker-compose.yml

docker-compose up -d # Subir o container WordPress com docker-compose




