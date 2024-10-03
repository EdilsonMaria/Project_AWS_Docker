output "db_endpoint" {
  value = aws_db_instance.wordpress-db.endpoint
}

output "rds_instance_id" {
  value = aws_db_instance.wordpress-db.id
}
