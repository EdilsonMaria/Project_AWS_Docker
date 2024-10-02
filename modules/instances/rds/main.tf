resource "aws_db_instance" "wordpress-db" {
  allocated_storage    = 20
  engine               = "mysql" 
  engine_version       = "8.0.35" 
  db_name                 = "wordpress" 
  username             = "admin" 
  password             = "admin_password" 
  instance_class       = "db.t3.micro" 
  storage_type = "gp2" 
  final_snapshot_identifier = true

  vpc_security_group_ids = [var.rds_SG]

  db_subnet_group_name = aws_db_subnet_group.wordpress-db-subnet-group.name
}

resource "aws_db_subnet_group" "wordpress-db-subnet-group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [var.subnet-project2-privada1, var.subnet-project2-privada2]
}