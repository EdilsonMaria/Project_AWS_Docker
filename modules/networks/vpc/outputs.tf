output "vpc_id" {
  value = aws_vpc.project2_vpc.id
}

output "subnet-project2-privada1" {
  value = aws_subnet.subnet-project2-privada1
}

output "subnet-project2-privada2" {
  value = aws_subnet.subnet-project2-privada2
}

output "subnet-project2-publica1" {
  value = aws_subnet.subnet-project2-publica1
}

output "subnet-project2-publica2" {
  value = aws_subnet.subnet-project2-publica2
}