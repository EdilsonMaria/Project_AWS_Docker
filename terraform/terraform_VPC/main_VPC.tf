# Definição da versão do provedor
terraform {
  required_version = "1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "AdministratorAccess"
}

#VPC PRINCIPAL
resource "aws_vpc" "project2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "project2-vpc"
  }
}

#SUB REDE PRIVADA
resource "aws_subnet" "subnet-project2-privada1" {
  vpc_id            = aws_vpc.project2_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-project2-privada1"
  }
}
resource "aws_subnet" "subnet-project2-privada2" {
  vpc_id            = aws_vpc.project2_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-project2-privada2"
  }
}
resource "aws_subnet" "subnet-project2-publica1" {
  vpc_id            = aws_vpc.project2_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-project2-publica1"
  }
}
resource "aws_subnet" "subnet-project2-publica2" {
  vpc_id            = aws_vpc.project2_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-project2-publica2"
  }
}

#INTERNET GATEWAY
resource "aws_internet_gateway" "project2-igw01" {
  vpc_id = aws_vpc.project2_vpc.id
  tags = {
    Name = "project2-igw01"
  }
}

#IPS ELASTICOS DA ZONA A E B
resource "aws_eip" "nat_gateway_eip_project2a" {
  tags = {
    Name = "ip_elastico_project2a"
  }
}
resource "aws_eip" "nat_gateway_eip_project2b" {
  tags = {
    Name = "ip_elastico_project2b"
  }
}

#NAT GATEWAY
resource "aws_nat_gateway" "nat_gateway_project2a" {
  allocation_id = aws_eip.nat_gateway_eip_project2a.id
  subnet_id     = aws_subnet.subnet-project2-publica1.id
  tags = {
    Name = "nat_gtw_project2a"
  }
}
resource "aws_nat_gateway" "nat_gateway_project2b" {
  allocation_id = aws_eip.nat_gateway_eip_project2b.id
  subnet_id     = aws_subnet.subnet-project2-publica2.id
  tags = {
    Name = "nat_gtw_project2b"
  }
}

#CRIAÇÃO TABELA DE ROTAS SUB-REDES PRIVADAS A E B
resource "aws_route_table" "rtb_private_project2a" {
  vpc_id = aws_vpc.project2_vpc.id
  tags = {
    Name = "rtb_private_project2a"
  }
}
resource "aws_route_table" "rtb_private_project2b" {
  vpc_id = aws_vpc.project2_vpc.id
  tags = {
    Name = "rtb_private_project2b"
  }
}

#ASSOCIAÇÃO TABELA DE ROTAS PRIVADA DA SUB-REDE A e B
resource "aws_route_table_association" "roteamento_privado_a" {
  subnet_id      = aws_subnet.subnet-project2-privada1.id
  route_table_id = aws_route_table.rtb_private_project2a.id
}
resource "aws_route_table_association" "roteamento_privado_b" {
  subnet_id      = aws_subnet.subnet-project2-privada2.id
  route_table_id = aws_route_table.rtb_private_project2b.id
}

#ROTEAMENTO INTERNO SAIDA PARA A INTERNET DA SUB-REDE A
resource "aws_route" "rota_padrao_privada_subnet_a" {
  route_table_id         = aws_route_table.rtb_private_project2a.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat_gateway_project2a.id
  depends_on     = [aws_nat_gateway.nat_gateway_project2a]
}

#ROTEAMENTO INTERNO SAIDA PARA A INTERNET DA SUB-REDE B
resource "aws_route" "rota_padrao_privada_subnet_b" {
  route_table_id         = aws_route_table.rtb_private_project2b.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat_gateway_project2b.id
  depends_on     = [aws_nat_gateway.nat_gateway_project2b]
}

#CRIAÇÃO TABELA DE ROTAS SUB-REDES PUBLICAS A E B
resource "aws_route_table" "rtb_publica_project2a" {
  vpc_id = aws_vpc.project2_vpc.id
  tags = {
    Name = "rtb_publica_project2a"
  }
}
resource "aws_route_table" "rtb_publica_project2b" {
  vpc_id = aws_vpc.project2_vpc.id
  tags = {
    Name = "rtb_publica_project2b"
  }
}

#ASSOCIAÇÃO TABELA DE ROTAS PUBLICAS DA SUB-REDE A e B
resource "aws_route_table_association" "roteamento_publico_a" {
  subnet_id      = aws_subnet.subnet-project2-publica1.id
  route_table_id = aws_route_table.rtb_publica_project2a.id
}
resource "aws_route_table_association" "roteamento_publico_b" {
  subnet_id      = aws_subnet.subnet-project2-publica2.id
  route_table_id = aws_route_table.rtb_publica_project2b.id
}

#ROTEAMENTO EXTERNO SAIDA PARA A INTERNET DA SUB-REDE A
resource "aws_route" "rota_padrao_publica_subnet_a" {
  route_table_id         = aws_route_table.rtb_publica_project2a.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.project2-igw01.id
}

#ROTEAMENTO EXTERNO SAIDA PARA A INTERNET DA SUB-REDE B
resource "aws_route" "rota_padrao_publica_subnet_b" {
  route_table_id         = aws_route_table.rtb_publica_project2b.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.project2-igw01.id
}