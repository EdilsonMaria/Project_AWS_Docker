output "efs_id" {
  description = "ID do EFS criado"
  value       = aws_efs_file_system.wordpress-efs.id
}

output "efs_dns_name" {
  description = "DNS Name para acesso ao EFS"
  value       = aws_efs_file_system.wordpress-efs.dns_name
}