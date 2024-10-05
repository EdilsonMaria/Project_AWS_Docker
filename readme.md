
# Projeto IaC com Terraform - Infraestrutura AWS para WordPress com RDS, EFS, Auto Scaling e Load Balancer

Este projeto utiliza **Infrastructure as Code (IaC)** com **Terraform** para provisionar uma infraestrutura completa na AWS. A infraestrutura permite o deployment de um ambiente **WordPress** em instâncias EC2 sem IP público, distribuídas em diferentes **Availability Zones (AZs)**, conectadas a um banco de dados MySQL no **RDS**, com pastas compartilhadas usando **EFS**, suporte a **Auto Scaling** e balanceamento de carga com **ALB (Application Load Balancer)**.

## Estrutura do Projeto

```
.
├── main.tf                # Arquivo principal que chama os módulos
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
```

## Funcionalidade

O projeto provisiona a seguinte infraestrutura na AWS:
### 1. VPC
- Criação de uma **VPC** com o bloco CIDR `10.0.0.0/16`.
- **Subnets**:
  - **2 subnets públicas**:
    - Subnet pública 1: `10.0.10.0/24` (AZ: us-east-1a)
    - Subnet pública 2: `10.0.11.0/24` (AZ: us-east-1b)
  - **2 subnets privadas**:
    - Subnet privada 1: `10.0.1.0/24` (AZ: us-east-1a)
    - Subnet privada 2: `10.0.2.0/24` (AZ: us-east-1b)

### 2. Internet Gateway e NAT Gateway
- Um **Internet Gateway** é associado à VPC, permitindo acesso à internet para as subnets públicas.
- Dois **NAT Gateways** são configurados para fornecer acesso à internet para as subnets privadas:
  - NAT Gateway 1 (us-east-1a) usando Elastic IP.
  - NAT Gateway 2 (us-east-1b) usando Elastic IP.

### 3. Tabelas de Roteamento
- **Tabelas de Roteamento para as subnets públicas**:
  - O tráfego externo é roteado pelo **Internet Gateway**.
- **Tabelas de Roteamento para as subnets privadas**:
  - O tráfego de saída é roteado através dos **NAT Gateways**.

### 4. VPC Endpoint
- Um **VPC Endpoint** é configurado para as instâncias EC2 nas subnets privadas, permitindo acesso a serviços da AWS sem a necessidade de IP público, dispensando o uso de Bastion Hosts.

#### Recursos Terraform Utilizados

- **VPC**: `aws_vpc`
- **Subnets**: `aws_subnet` (públicas e privadas)
- **Internet Gateway**: `aws_internet_gateway`
- **Elastic IP**: `aws_eip` (para os NAT Gateways)
- **NAT Gateway**: `aws_nat_gateway`
- **Tabelas de Roteamento**: `aws_route_table`
- **Rotas**: `aws_route`
- **Associações de Tabelas de Roteamento**: `aws_route_table_association`
- **VPC Endpoint**: `aws_ec2_instance_connect_endpoint`

### 5. Security Group para Instâncias EC2
- **Função**: Controla o acesso às instâncias EC2.
- **Permissões**:
  - **SSH** (porta 22) aberto para a internet.
  - **HTTP/HTTPS** (portas 80 e 443) a partir do Load Balancer.
  - **MySQL** (porta 3306) a partir do RDS dentro da VPC.
  - **EFS** (porta 2049) para compartilhamento de arquivos entre as instâncias EC2.

### 6. Security Group para o RDS (Banco de Dados)
- **Função**: Controla o acesso ao banco de dados RDS (MySQL).
- **Permissões**:
  - **MySQL** (porta 3306) acessível apenas pelas instâncias EC2 dentro da VPC.

### 7. Security Group para o EFS
- **Função**: Permite o compartilhamento de arquivos entre as instâncias EC2.
- **Permissões**:
  - **NFS** (porta 2049) acessível dentro da VPC.

### 8. Security Group para o Load Balancer
- **Função**: Controla o tráfego de entrada para o Load Balancer.
- **Permissões**:
  - **HTTP/HTTPS** (portas 80 e 443) aberto para a internet.

#### Recursos Terraform Utilizados
- **Security Group do Load Balancer**: `aws_security_group.alb-SG`
- **Security Group das Instâncias EC2**: `aws_security_group.ec2-SG`
- **Security Group do RDS**: `aws_security_group.rds-SG`
- **Security Group do EFS**: `aws_security_group.end-SG`

### 9. Load Balancer (Application Load Balancer)
- **Função**: Distribuir o tráfego HTTP entre as instâncias EC2.
- **Configurações**:
  - **Subnets**: Associado a subnets públicas.
  - **Segurança**: Usa o Security Group do Load Balancer para permitir tráfego HTTP e HTTPS.
  - **Cross-Zone Load Balancing**: Habilitado para distribuir o tráfego entre todas as zonas de disponibilidade.

### 10. Target Group
- **Função**: Gerenciar as instâncias EC2 que recebem o tráfego do Load Balancer.
- **Configurações**:
  - Porta **80** para tráfego HTTP.
  - **Health Check** configurado no caminho `/wp-admin/install.php`.

### 11. Listener HTTP
- **Função**: Escuta o tráfego HTTP na porta 80 e o direciona para o Target Group.
- **Configuração**: Listener na porta **80** com protocolo **HTTP**, ação de **forward** para o Target Group.

### 12. Launch Template
- **Função**: Define a configuração das instâncias EC2 lançadas pelo Auto Scaling.
- **Configurações**:
  - **AMI** e **Tipo de Instância**.
  - **User Data** para configurar as instâncias no início (instalação de Docker, etc.).
  - **Disco EBS** de 8 GB e tipo **gp2**.
  - Usa o **Security Group das EC2**.

### 13. Auto Scaling Group
- **Função**: Gerencia o número de instâncias EC2 conforme a demanda.
- **Configurações**:
  - Capacidade mínima de **1** e máxima de **2** instâncias.
  - Usa subnets privadas.
  - Associado ao Target Group para receber tráfego do Load Balancer.

### 14. Políticas de Auto Scaling
- **Scale Up**: Aumenta em 1 instância quando a demanda cresce.
- **Scale Down**: Reduz em 1 instância quando a demanda diminui.

### 15. Elastic File System (EFS)
- **Função**: O EFS permite o compartilhamento de arquivos entre as instâncias EC2, garantindo que as instâncias no Auto Scaling possam acessar os mesmos dados persistentes.
- **Configurações**:
  - Um sistema de arquivos EFS é provisionado com uma política de ciclo de vida que move os dados para a classe de armazenamento "infrequent access" após 30 dias de inatividade.
  - **Mount Targets** são configurados nas subnets privadas para que as instâncias EC2 possam acessar o EFS via NFS (porta 2049).
  - O acesso ao EFS é controlado pelo **Security Group** que permite tráfego na porta 2049 para NFS.

#### Recursos Terraform Utilizados:
- **EFS**: `aws_efs_file_system.wordpress-efs`
- **Mount Targets**: 
  - `aws_efs_mount_target.subnet-privada1-efs-mount-target`
  - `aws_efs_mount_target.subnet-privada2-efs-mount-target`

### 16. RDS (MySQL)
- **Função**: O banco de dados MySQL gerenciado pelo RDS é utilizado para armazenar os dados persistentes da aplicação WordPress.
- **Configurações**:
  - Um banco de dados MySQL é provisionado com 20 GB de armazenamento em disco do tipo **gp2**.
  - Está associado a um **Security Group** que controla o acesso ao banco de dados via a porta 3306 (MySQL).
  - O banco de dados utiliza um **DB Subnet Group** com subnets privadas, garantindo que o RDS seja acessível apenas por instâncias dentro da VPC.

#### Recursos Terraform Utilizados:
- **RDS (MySQL)**: `aws_db_instance.wordpress-db`
- **DB Subnet Group**: `aws_db_subnet_group.wordpress-db-subnet-group`

## Pré-requisitos

### 1. Instalar o Terraform

No Linux (CentOS ou Ubuntu), siga os passos abaixo:

#### CentOS:
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

#### Ubuntu:
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

Verifique se o Terraform foi instalado corretamente:
```bash
terraform -v
```

### 2. Configurar a AWS CLI

1. Instale a AWS CLI:
   
   #### CentOS:
   ```bash
   sudo yum install awscli -y
   ```

   #### Ubuntu:
   ```bash
   sudo apt-get install awscli -y
   ```

2. Configure a AWS CLI com suas credenciais:

```bash
aws configure
```
Você precisará inserir:
- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (ex: `us-east-1`)
- **Default output format** (ex: `json`)

3. Verifique se a AWS CLI está configurada corretamente:
```bash
aws sts get-caller-identity
```

## Como Utilizar o Projeto

### Passos para provisionar a infraestrutura:

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/EdilsonMaria/Project_AWS_Docker
   cd seu-repositorio
   ```

2. **Inicialize o Terraform**:
   ```bash
   terraform init
   ```

3. **Verifique o plano de execução**:
   ```bash
   terraform plan
   ```

4. **Aplique o plano para provisionar a infraestrutura**:
   ```bash
   terraform apply
   ```
   Confirme a execução digitando `yes` quando solicitado.

### Arquivo `user_data.sh`

O arquivo `user_data.sh` é responavel por fazer o update da maquina linux EC2, instalar o docker e docker-compose, garatir que esses serviços sempre estejam ativos no sistema linux, atualizar a hora da maquina linux EC2, instalar o nfs-utils e o amazon-efs-utils, montar o diretório /mnt/efs para o AWS EFS, instalar o git, clonar do repositório público do github o `https://github.com/EdilsonMaria/Docker-Compose_WordPress.git` o docker-compose.yml e as variaveis de ambiente .env, e por fim executar o container docker com o comando `docker-compose up -d`

### Arquivo `docker-compose.yml`

O arquivo `docker-compose.yml` é responsável por subir o contêiner do WordPress em cada instância EC2. Ele é configurado para conectar ao banco de dados RDS e usar o EFS para armazenar os arquivos compartilhados entre as instâncias.

### Variáveis de Ambiente

As variáveis de ambiente usadas pelo Docker Compose (como as credenciais do banco de dados RDS) estão armazenadas no arquivo `.env`.

## Estrutura Modularizada

O projeto está modularizado da seguinte forma:

- **Módulos de Instâncias**:
  - `alb`: Configura o Load Balancer.
  - `ec2-auto-scaling`: Cria o Auto Scaling Group e as instâncias EC2.
  - `efs`: Provisiona o Elastic File System.
  - `rds`: Cria o banco de dados MySQL no RDS.
  
- **Módulos de Redes**:
  - `security-group`: Cria os Security Groups necessários.
  - `vpc`: Provisiona a VPC, subnets, NAT Gateways e tabelas de roteamento.

## Como Destruir a Infraestrutura

Para remover toda a infraestrutura provisionada, execute o seguinte comando:

```bash
terraform destroy
```

## Passos de como ficará o seu ambiente na cloud AWS

•	*1 - Criação da VPC com o mapa de recursos para as Subnets, Tabela de Roteamento e Conexões e Rede*
<img src="/imgs/image.png">

•	*2 - criação das subnets privadas e publicas em AZ's us-east-1a e us-east-1b*
<img src="/imgs/image1.png">

•	*3 - Tabela de roteamento, uma para cada tipo de subnets, privada e publica em suas diferentes AZ's*
<img src="/imgs/image2.png">

•	*4 - Internet gateways atrelados a VPC e as duas subnetes publicas permitindo acesso a internet*
<img src="/imgs/image3.png">

•	*5 - Elastic IP atrelados um a cada Nat Gateways das AZ's diferentes*
<img src="/imgs/image4.png">

•	*6 - Nat Gateways atrelados um a cada subnet privada permitindo a saida para internet de forma segura e assegurando a não permissão de entrada*
<img src="/imgs/image5.png">

•	*7 - Criação do Endpoint para permitir acesso as EC2 que estiverem em subnetes privadas e sem ip publico*
<img src="/imgs/image6.png">

•	*8 - Criação das Security Group para EC2, Endpoint, RDS e Load Balance*
<img src="/imgs/image7.png">

•	*9 - Criação do Lounch Templete para o Auto Scaling das instnaicas EC2*
<img src="/imgs/image8.png">

•	*10 - Criação do Auto Scaling permitindo o scaling up e scaling down* 
<img src="/imgs/image9.png">

•	*11 - Criação pelo Auto Scaling das instancias EC2 uma em cada subnet privada e em diferentes AZ's* 
<img src="/imgs/image10.png">

•	*12 - Instancia 1-WordPress com os logs do container, mostrando a Response 200 para o Healthkecker configurado* 
<img src="/imgs/image11.png">

•	*13 - Instancia 1-WorpPress na subnet privada 1 na zona de disponibilidade 1a com o EFS montado*
<img src="/imgs/image12.png">

•	*14 - Instancia 2-WordPress com os logs do container, mostrando a configuração ok do HeathChecker e as requisições do load balancer ao acessar pelo cliente navegador*
<img src="/imgs/image13.png">

•	*15 - Criação do Load Balancer, para distribuir as requisões entre as duas instncicas EC2 nas AZ's diferentes*
<img src="/imgs/image14.png">

•	*16 - Target Group atrelado ao Load Balance, mostrando que as requisições da HTTP para EC2 estão sudaveis* 
<img src="/imgs/image15.png">

•	*17 - Configuração do Health Checks* 
<img src="/imgs/image16.png">

•	*18 - Servirço do Load Balance acessadno as intancias e expondo de forma publica do serviço do WordPress rodando dentro do contanier docker* 
<img src="/imgs/image17.png">

•	*19 - Comando terraform init para iniciar o servidor da hashicorp e as dependencias de provedor(AWS)* 
<img src="/imgs/image18.png">

•	*20 - Comando plan que mostra a saida de todos os servirços a serem startados* 
<img src="/imgs/image19.png">

•	*21 - Comando terraform destroy para apagar todos os recurso de forma automatico que foi iniciado anterioemente* 
<img src="/imgs/image20.png">

## Licença

Este projeto está licenciado sob os termos da licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.

---

Este projeto foi desenvolvido para provisionar automaticamente uma infraestrutura robusta e escalável para hospedar um ambiente WordPress utilizando as melhores práticas de IaC com Terraform. Se você tiver dúvidas ou problemas, fique à vontade para abrir uma **issue**.
