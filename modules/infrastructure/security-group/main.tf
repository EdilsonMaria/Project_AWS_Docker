#CRIAÇÃO DE SECURITY GROUP DO ELB.
resource "aws_security_group" "alb_SG" {
  name = "alb_SG"
  description = "Security Group para o Load Balancer"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "alb_SG"
  }
}

#CRIAÇÃO DE SECURITY GROUP DA EC2 (WordPress)
resource "aws_security_group" "ec2_SG" { 
  name = "ec2_SG"   
  description = "Security Group para instâncias EC2 do WordPress"              
  vpc_id = var.vpc_id                   
  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_SG]  
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]  
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "ec2_SG"
  }
}

#CRIAÇÃO DE SECURITY GROUP DO RDS (MySQL)
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security Group para o RDS MySQL"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]  # Permitir acesso MySQL apenas das instâncias EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir saída para qualquer origem
  }
}