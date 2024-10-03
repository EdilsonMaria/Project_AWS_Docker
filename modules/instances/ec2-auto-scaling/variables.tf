variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0e54eba7c51c234f6"
}

variable "ec2_SG" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet-project2-privada1" {
  type = object({
    id = string
  })
}

variable "subnet-project2-privada2" {
  type = object({
    id = string
  })
}

variable "subnet-project2-publica1" {
  type = object({
    id = string
  })
}

variable "subnet-project2-publica2" {
  type = object({
    id = string
  })
}

variable "wordpress_target_group" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "efs_id" {
  type = string
}