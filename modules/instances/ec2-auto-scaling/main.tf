#CRIAÇÃO DO LAUNCH TEMPLATE PARA EC2 NO AUTO SCALING
resource "aws_launch_template" "ec2_template" {
  name_prefix   = "ec2-template"
  image_id      = var.ami
  instance_type = var.instance_type
  user_data = (filebase64("user_data.sh"))

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups             = [var.ec2_SG]
  }
}

# Grupo de Auto Scaling (ASG)
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2  # Número inicial de instâncias EC2
  max_size             = 4  # Número máximo de instâncias EC2
  min_size             = 2  # Número mínimo de instâncias EC2
  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.public_subnet[*].id  # Subnets públicas para o Auto Scaling

  tag {
    key                 = "Name"
    value               = "EC2-AutoScaling"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300  # Período de checagem de integridade (em segundos)

  # Espera por 300 segundos antes de iniciar a próxima verificação de saúde
  wait_for_capacity_timeout = "0"
}

# Anexar políticas de Auto Scaling
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  autoscaling_group_name  = aws_autoscaling_group.asg.name
  cooldown                = 300  # Tempo de espera antes de permitir outro ajuste
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  autoscaling_group_name  = aws_autoscaling_group.asg.name
  cooldown                = 300  # Tempo de espera antes de permitir outro ajuste
}