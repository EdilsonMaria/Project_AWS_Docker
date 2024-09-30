variable "vpc_id" {
  type = string
}

variable "alb_SG" {
  type = string
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

variable "subnet-project2-privada1" {
    type        = object({
    id = string
  })
}

variable "subnet-project2-privada2" {
    type        = object({
    id = string
  })
}