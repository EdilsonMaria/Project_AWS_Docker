#Gerar um par de chaves SSH para acessar a instância
resource "tls_private_key" "chave_RSA" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Salvar a chave pública no AWS EC2
resource "aws_key_pair" "ssh_key" {
  key_name   = "project2-compass"
  public_key = tls_private_key.chave_RSA.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.chave_RSA.private_key_pem
  filename = "${path.module}/../../project2-compass.pem" 
}

#CRIAÇÃO DO LAUNCH TEMPLATE PARA EC2 NO AUTO SCALING
resource "aws_launch_template" "ec2_template" {
  name          = "wordpress-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh_key.key_name
 
  user_data = filebase64("./user_data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name       = "PB - JUN 2024"
      CostCenter = "C092000024"
      Project    = "PB - JUN 2024"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name       = "PB - JUN 2024"
      CostCenter = "C092000024"
      Project    = "PB - JUN 2024"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [var.ec2_SG]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }
}

# Grupo de Auto Scaling (ASG)
resource "aws_autoscaling_group" "wordpress-auto-scaling" {
  name                      = "wordpress-auto-scaling"
  desired_capacity          = 1
  min_size                  = 1 
  max_size                  = 2 
  vpc_zone_identifier       = [var.subnet-project2-privada1.id, var.subnet-project2-privada2.id]
  target_group_arns         = [var.wordpress_target_group]
  health_check_grace_period = 300 
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WordPress"
    propagate_at_launch = true
  }
}

# Anexar políticas de Auto Scaling
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.wordpress-auto-scaling.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300 
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.wordpress-auto-scaling.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300 
  policy_type            = "SimpleScaling"
}