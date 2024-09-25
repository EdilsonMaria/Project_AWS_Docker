#!/bin/bash
# Atualizar a lista de pacotes
sudo apt-get update -y

# Instalar pacotes necessários para adicionar repositórios
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Adicionar chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório do Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Atualizar a lista de pacotes novamente
sudo apt-get update -y

# Instalar Docker
sudo apt-get install -y docker-ce

# Habilitar e iniciar o serviço do Docker
sudo systemctl enable docker
sudo systemctl start docker

# Adicionar o usuário 'ubuntu' ao grupo docker (para evitar precisar de sudo)
sudo usermod -aG docker ubuntu

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dar permissões de execução ao Docker Compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar versões instaladas
docker --version
docker-compose --version

# Reiniciar a instância para aplicar alterações (opcional)
# sudo reboot
