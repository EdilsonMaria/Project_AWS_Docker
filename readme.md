Projeto IaC com Terraform - Infraestrutura AWS para WordPress com RDS, EFS, Auto Scaling e Load Balancer
Este projeto utiliza Infrastructure as Code (IaC) com Terraform para provisionar uma infraestrutura completa na AWS. A infraestrutura permite o deployment de um ambiente WordPress em instâncias EC2 sem IP público, distribuídas em diferentes Availability Zones (AZs), conectadas a um banco de dados MySQL no RDS, com pastas compartilhadas usando EFS, suporte a Auto Scaling e balanceamento de carga com ALB (Application Load Balancer).

Estrutura do Projeto
bash
Copiar código
.
├── main.tf               # Arquivo principal que chama os módulos
├── docker-compose.yml     # Arquivo Docker Compose para rodar o WordPress nas instâncias EC2
├── .env                   # Arquivo de variáveis de ambiente para o Docker Compose
├── user_data.sh           # Script para montagem do EFS nas instâncias EC2
├── modules
│   ├── instances
│   │   ├── alb
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   │   ├── version.tf
│   │   ├── ec2-auto-scaling
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   │   ├── version.tf
│   │   ├── efs
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   │   ├── version.tf
│   │   ├── rds
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── providers.tf
│   │       ├── variables.tf
│   │       ├── version.tf
│   ├── networks
│   │   ├── security-group
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   │   ├── version.tf
│   │   ├── vpc
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── providers.tf
│   │       ├── variables.tf
│   │       ├── version.tf
Funcionalidade
O projeto provisiona a seguinte infraestrutura na AWS:

VPC com 4 subnets:
2 subnets públicas (uma em cada AZ)
2 subnets privadas (uma em cada AZ)
Internet Gateway para as subnets públicas e NAT Gateway para as subnets privadas (uma para cada AZ)
Tabelas de roteamento para as subnets públicas e privadas:
As subnets públicas roteam tráfego para o Internet Gateway
As subnets privadas têm acesso à Internet através do NAT Gateway
VPC Endpoint para permitir o acesso às instâncias EC2 privadas sem IP público, dispensando o uso de Bastion Hosts
4 Security Groups para:
Instâncias EC2 (acesso SSH e tráfego de HTTP/HTTPS)
Banco de dados RDS (acesso ao MySQL)
EFS (para compartilhamento de arquivos)
Endpoint (para comunicação interna)
EFS (Elastic File System) para compartilhamento de arquivos entre as instâncias EC2
Auto Scaling Group para gerenciar instâncias EC2 com balanceamento de carga
Banco de dados RDS (MySQL) para armazenar dados do WordPress
Application Load Balancer (ALB) para distribuir o tráfego entre as instâncias EC2 privadas
As instâncias EC2 são provisionadas para rodar o WordPress em contêineres Docker, com pastas públicas compartilhadas através do EFS, conectadas ao banco de dados RDS.
Pré-requisitos
1. Instalar o Terraform
No Linux (CentOS ou Ubuntu), siga os passos abaixo:

CentOS:
bash
Copiar código
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
Ubuntu:
bash
Copiar código
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
Verifique se o Terraform foi instalado corretamente:

bash
Copiar código
terraform -v
2. Configurar a AWS CLI
Instale a AWS CLI:

CentOS:
bash
Copiar código
sudo yum install awscli -y
Ubuntu:
bash
Copiar código
sudo apt-get install awscli -y
Configure a AWS CLI com suas credenciais:

bash
Copiar código
aws configure
Você precisará inserir:

AWS Access Key ID
AWS Secret Access Key
Default region name (ex: us-east-1)
Default output format (ex: json)
Verifique se a AWS CLI está configurada corretamente:
bash
Copiar código
aws sts get-caller-identity
Como Utilizar o Projeto
Passos para provisionar a infraestrutura:
Clone o repositório:

bash
Copiar código
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
Inicialize o Terraform:

bash
Copiar código
terraform init
Verifique o plano de execução:

bash
Copiar código
terraform plan
Aplique o plano para provisionar a infraestrutura:

bash
Copiar código
terraform apply
Confirme a execução digitando yes quando solicitado.

Arquivo user_data.sh
O arquivo user_data.sh é usado para montar automaticamente o EFS nas instâncias EC2 assim que elas forem inicializadas. Ele instala os pacotes necessários e realiza a montagem no diretório /mnt/efs.

Arquivo docker-compose.yml
O arquivo docker-compose.yml é responsável por subir o contêiner do WordPress em cada instância EC2. Ele é configurado para conectar ao banco de dados RDS e usar o EFS para armazenar os arquivos compartilhados entre as instâncias.

Variáveis de Ambiente
As variáveis de ambiente usadas pelo Docker Compose (como as credenciais do banco de dados RDS) estão armazenadas no arquivo .env.

Estrutura Modularizada
O projeto está modularizado da seguinte forma:

Módulos de Instâncias:
alb: Configura o Load Balancer.
ec2-auto-scaling: Cria o Auto Scaling Group e as instâncias EC2.
efs: Provisiona o Elastic File System.
rds: Cria o banco de dados MySQL no RDS.
Módulos de Redes:
security-group: Cria os Security Groups necessários.
vpc: Provisiona a VPC, subnets, NAT Gateways e tabelas de roteamento.
Como Destruir a Infraestrutura
Para remover toda a infraestrutura provisionada, execute o seguinte comando:

bash
Copiar código
terraform destroy
Licença
Este projeto está licenciado sob os termos da licença MIT. Consulte o arquivo LICENSE para mais detalhes.