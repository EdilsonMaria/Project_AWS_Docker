# Criar o EFS
resource "aws_efs_file_system" "wordpress-efs" {
  creation_token = "wordpress-efs"
  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "wordpress-efs"
  }
}

# Criar os Mount Targets para EFS nas subnets do VPC
resource "aws_efs_mount_target" "efs_mount_target" {
  count          = 2 # Cria dois mount targets, um por subnet
  file_system_id = aws_efs_file_system.wordpress-efs.id
  subnet_id      = element(["var.subnet-project2-privada1.id", "var.subnet-project2-privada2.id"], count.index) # Substitua pelos IDs das subnets
  security_groups = [var.end_SG.id]
}

