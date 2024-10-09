output "efs_id" {
  value = module.aws_efs_file_system.efs_id
}

output "db_endpoint" {
  value = module.aws_db_instance.db_endpoint
}