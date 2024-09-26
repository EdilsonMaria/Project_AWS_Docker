variable "instance_type" {
  default = "t2.micro"  
}  

variable "ami" {
  default = "ami-0e54eba7c51c234f6"  
}

variable "alb_SG" {
}

variable "ec2_SG" {
}

variable "rds_sg" {
}

variable "vpc_id" {
}