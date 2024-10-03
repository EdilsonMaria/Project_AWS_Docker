# Criar o EFS
resource "aws_efs_file_system" "wordpress-efs" {
  creation_token = "wordpress-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "wordpress-efs"
  }
}

# Criar os Mount Targets para EFS nas subnet privada 1 da VPC
resource "aws_efs_mount_target" "subnet-privada1-efs-mount-target" {
  file_system_id  = aws_efs_file_system.wordpress-efs.id
  subnet_id       = var.subnet-project2-privada1
  security_groups = [var.ec2_SG]
}

resource "aws_efs_mount_target" "subnet-privada2-efs-mount-target" {
  file_system_id  = aws_efs_file_system.wordpress-efs.id
  subnet_id       = var.subnet-project2-privada2
  security_groups = [var.ec2_SG]
}




