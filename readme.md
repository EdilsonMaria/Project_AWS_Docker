
# Projeto IaC com Terraform - Infraestrutura AWS para WordPress com RDS, EFS, Auto Scaling e Load Balancer

Este projeto utiliza **Infrastructure as Code (IaC)** com **Terraform** para provisionar uma infraestrutura completa na AWS. A infraestrutura permite o deployment de um ambiente **WordPress** em instâncias EC2 sem IP público, distribuídas em diferentes **Availability Zones (AZs)**, conectadas a um banco de dados MySQL no **RDS**, com pastas compartilhadas usando **EFS**, suporte a **Auto Scaling** e balanceamento de carga com **ALB (Application Load Balancer)**.

## Estrutura do Projeto

```
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
```

## Funcionalidade

O projeto provisiona a seguinte infraestrutura na AWS:
1. **VPC** com 4 subnets:
   - 2 subnets públicas (uma em cada AZ)
   - 2 subnets privadas (uma em cada AZ)
2. **Internet Gateway** para as subnets públicas e **NAT Gateway** para as subnets privadas (uma para cada AZ)
3. **Tabelas de roteamento** para as subnets públicas e privadas:
   - As subnets públicas roteam tráfego para o Internet Gateway
   - As subnets privadas têm acesso à Internet através do NAT Gateway
4. **VPC Endpoint** para permitir o acesso às instâncias EC2 privadas sem IP público, dispensando o uso de Bastion Hosts
5. **4 Security Groups** para:
   - Instâncias EC2 (acesso SSH e tráfego de HTTP/HTTPS)
   - Banco de dados RDS (acesso ao MySQL)
   - EFS (para compartilhamento de arquivos)
   - Endpoint (para comunicação interna)
6. **EFS (Elastic File System)** para compartilhamento de arquivos entre as instâncias EC2
7. **Auto Scaling Group** para gerenciar instâncias EC2 com balanceamento de carga
8. **Banco de dados RDS (MySQL)** para armazenar dados do WordPress
9. **Application Load Balancer (ALB)** para distribuir o tráfego entre as instâncias EC2 privadas
10. As instâncias EC2 são provisionadas para rodar o WordPress em contêineres Docker, com pastas públicas compartilhadas através do **EFS**, conectadas ao banco de dados RDS.

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
   git clone https://github.com/seu-usuario/seu-repositorio.git
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

O arquivo `user_data.sh` é usado para montar automaticamente o EFS nas instâncias EC2 assim que elas forem inicializadas. Ele instala os pacotes necessários e realiza a montagem no diretório `/mnt/efs`.

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

## Licença

Este projeto está licenciado sob os termos da licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.

---

Este projeto foi desenvolvido para provisionar automaticamente uma infraestrutura robusta e escalável para hospedar um ambiente WordPress utilizando as melhores práticas de IaC com Terraform. Se você tiver dúvidas ou problemas, fique à vontade para abrir uma **issue**.
