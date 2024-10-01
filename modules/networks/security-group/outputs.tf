output "alb_SG" {
  value = aws_security_group.alb_SG.id
}

output "ec2_SG" {
  value = aws_security_group.ec2_SG.id
}

output "rds_SG" {
  value = aws_security_group.rds_SG.id
}

output "end_SG" {
  value = aws_security_group.end_SG.id
}