#CRIAÇÃO DE SECURITY GROUP QUE SERÁ AMARRADO AO ELB.
resource "aws_security_group" "internet_facing_sg" { #AQUI VOCÊ DEFINE O RECURSO E EM SEGUIDA, O NOME DO SECURITY GROUP
  name_prefix = "internet_facing_sg"                 #AQUI VOCÊ DEFINE O NOME TAG DO SECURITY GROUP
  vpc_id = aws_vpc.vpc_prod.id                       #AQUI VOCÊ ASSOCIA SEU SG A VPC DO AMBIENTE
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # COMO É UM BALANCE DE CARA PARA A INTERNET, PRECISAMOS MANTER ESSA REGRA ABERTA PARA O MUNDO
  }
}