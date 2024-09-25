output "alb_SG" {
    value = aws_security_group.alb_SG
}

output "ec2_SG" {
    value = aws_security_group.ec2_SG
}

output "rds_sg" {
    value = aws_security_group.rds_sg
}