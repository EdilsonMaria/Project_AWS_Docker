module "vpc" {
  source = "./networks/vpc"
}

module "security_group" {
  source = "./networks/security-group"
  vpc_id = module.vpc.vpc_id
}

module "aws_lb" {
  source                   = "./instances/alb"
  vpc_id                   = module.vpc.vpc_id
  alb_SG                   = module.security_group.alb_SG
  subnet-project2-publica1 = module.vpc.subnet-project2-publica1
  subnet-project2-publica2 = module.vpc.subnet-project2-publica2
}

module "aws_autoscaling_group" {
  source                   = "./instances/ec2-auto-scaling"
  vpc_id                   = module.vpc.vpc_id
  ec2_SG                   = module.security_group.ec2_SG
  subnet-project2-publica1 = module.vpc.subnet-project2-publica1
  subnet-project2-publica2 = module.vpc.subnet-project2-publica2
  wordpress_target_group   = module.aws_lb.wordpress_target_group.arn
}