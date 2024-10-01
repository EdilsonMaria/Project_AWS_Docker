resource "aws_db_instance" "wordpress-db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  db_name                 = "wordpress"
  username             = "admin"
  password             = "admin_password"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = false
  publicly_accessible  = true

  vpc_security_group_ids = var.vpc_id.id

  db_subnet_group_name = var.rds_SG.id
}

resource "aws_db_subnet_group" "default" {
  name       = "wordpress_db_subnet_group"
  subnet_ids = [var.subnet-project2-privada1.id, var.subnet-project2-privada2.id]
}