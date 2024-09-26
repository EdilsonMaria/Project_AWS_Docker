module "vpc" {
  source = "./networks/vpc"
}

module "security_group" {
  source = "./networks/security-group"
}
