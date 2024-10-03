#VPC PRINCIPAL
resource "aws_vpc" "project2-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "project2-vpc"
  }
}

#SUB REDE PRIVADA
resource "aws_subnet" "subnet-project2-privada1" {
  vpc_id            = aws_vpc.project2-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-project2-privada1"
  }
}
resource "aws_subnet" "subnet-project2-privada2" {
  vpc_id            = aws_vpc.project2-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-project2-privada2"
  }
}
resource "aws_subnet" "subnet-project2-publica1" {
  vpc_id            = aws_vpc.project2-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-project2-publica1"
  }
}
resource "aws_subnet" "subnet-project2-publica2" {
  vpc_id            = aws_vpc.project2-vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-project2-publica2"
  }
}

#INTERNET GATEWAY
resource "aws_internet_gateway" "project2-igw01" {
  vpc_id = aws_vpc.project2-vpc.id
  tags = {
    Name = "project2-igw01"
  }
}

#IPS ELASTICOS DA ZONA A E B
resource "aws_eip" "nat-gateway-eip-project2a" {
  tags = {
    Name = "ip-elastico-project2a"
  }
}
resource "aws_eip" "nat-gateway-eip-project2b" {
  tags = {
    Name = "ip-elastico-project2b"
  }
}

#NAT GATEWAY
resource "aws_nat_gateway" "nat-gateway-project2a" {
  allocation_id = aws_eip.nat-gateway-eip-project2a.id
  subnet_id     = aws_subnet.subnet-project2-publica1.id
  tags = {
    Name = "nat-gtw-project2a"
  }
}
resource "aws_nat_gateway" "nat-gateway-project2b" {
  allocation_id = aws_eip.nat-gateway-eip-project2b.id
  subnet_id     = aws_subnet.subnet-project2-publica2.id
  tags = {
    Name = "nat-gtw-project2b"
  }
}

#CRIAÇÃO TABELA DE ROTAS SUB-REDES PRIVADAS A E B
resource "aws_route_table" "rtb-private-project2a" {
  vpc_id = aws_vpc.project2-vpc.id
  tags = {
    Name = "rtb_private_project2a"
  }
}
resource "aws_route_table" "rtb-private-project2b" {
  vpc_id = aws_vpc.project2-vpc.id
  tags = {
    Name = "rtb_private_project2b"
  }
}

#ASSOCIAÇÃO TABELA DE ROTAS PRIVADA DA SUB-REDE A e B
resource "aws_route_table_association" "roteamento-privado-a" {
  subnet_id      = aws_subnet.subnet-project2-privada1.id
  route_table_id = aws_route_table.rtb-private-project2a.id
}
resource "aws_route_table_association" "roteamento-privado-b" {
  subnet_id      = aws_subnet.subnet-project2-privada2.id
  route_table_id = aws_route_table.rtb-private-project2b.id
}

#ROTEAMENTO INTERNO SAIDA PARA A INTERNET DA SUB-REDE A
resource "aws_route" "rota-padrao-privada-subnet-a" {
  route_table_id         = aws_route_table.rtb-private-project2a.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat-gateway-project2a.id
  depends_on     = [aws_nat_gateway.nat-gateway-project2a]
}

#ROTEAMENTO INTERNO SAIDA PARA A INTERNET DA SUB-REDE B
resource "aws_route" "rota-padrao-privada-subnet-b" {
  route_table_id         = aws_route_table.rtb-private-project2b.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat-gateway-project2b.id
  depends_on     = [aws_nat_gateway.nat-gateway-project2b]
}

#CRIAÇÃO TABELA DE ROTAS SUB-REDES PUBLICAS A E B
resource "aws_route_table" "rtb-publica-project2a" {
  vpc_id = aws_vpc.project2-vpc.id
  tags = {
    Name = "rtb-publica-project2a"
  }
}
resource "aws_route_table" "rtb-publica-project2b" {
  vpc_id = aws_vpc.project2-vpc.id
  tags = {
    Name = "rtb-publica-project2b"
  }
}

#ASSOCIAÇÃO TABELA DE ROTAS PUBLICAS DA SUB-REDE A e B
resource "aws_route_table_association" "roteamento-publico-a" {
  subnet_id      = aws_subnet.subnet-project2-publica1.id
  route_table_id = aws_route_table.rtb-publica-project2a.id
}
resource "aws_route_table_association" "roteamento-publico-b" {
  subnet_id      = aws_subnet.subnet-project2-publica2.id
  route_table_id = aws_route_table.rtb-publica-project2b.id
}

#ROTEAMENTO EXTERNO SAIDA PARA A INTERNET DA SUB-REDE A
resource "aws_route" "rota-padrao-publica-subnet-a" {
  route_table_id         = aws_route_table.rtb-publica-project2a.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.project2-igw01.id
}

#ROTEAMENTO EXTERNO SAIDA PARA A INTERNET DA SUB-REDE B
resource "aws_route" "rota-padrao-publica-subnet-b" {
  route_table_id         = aws_route_table.rtb-publica-project2b.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.project2-igw01.id
}

#CRIANDO UM VPC ENDPOINT P/ ACESSAR EC2 EM SUBNET PRIVADA
resource "aws_ec2_instance_connect_endpoint" "wordpress-endpoint" {
  subnet_id          = aws_subnet.subnet-project2-publica1.id
  security_group_ids = [var.end_SG]
  tags = {
    Name = "wordpress-endpoint"
  }
}