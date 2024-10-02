output "alb_SG" {
  value = aws_security_group.alb-SG.id
}

output "ec2_SG" {
  value = aws_security_group.ec2-SG.id
}

output "rds_SG" {
  value = aws_security_group.rds-SG.id
}

output "end_SG" {
  value = aws_security_group.end-SG.id
}