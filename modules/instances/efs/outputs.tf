output "efs_id" {
  value = aws_efs_file_system.wordpress-efs.id
}

output "efs_dns" {
  value = aws_efs_file_system.wordpress-efs.dns_name
}

