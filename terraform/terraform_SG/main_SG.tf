#CRIAÇÃO DE SECURITY GROUP QUE SERÁ AMARRADO AO ELB.
module "vpc" {
  source = "../terraform_VPC"  
}

resource "aws_security_group" "wordpres_SG" { 
  name_prefix = "wordpres_SG"                 
  vpc_id = module.vpc.vpc_id                     
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_id]  # Allow traffic from Load Balancer only
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_id]  # Only Load Balancer allowed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_id]  # Only allow internal VPC traffic
  }

  tags = {
    Name = "wordpres_SG"
  }
}