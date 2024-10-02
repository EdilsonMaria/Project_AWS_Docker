#CRIAÇÃO ELASTC LOAD BALANCE ELB
resource "aws_lb" "wordpress-lb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_SG]
  subnets = [var.subnet-project2-privada1.id, var.subnet-project2-privada2.id]

  enable_deletion_protection = false

  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "wordpress-lb"
  }
}

# Criar o Target Group (Grupo de Alvos) para as instâncias EC2
resource "aws_lb_target_group" "wordpress-target-group" {
  name     = "wordpress-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
  }
}

# Vincular o Target Group ao Load Balancer por meio de um Listener HTTP
resource "aws_lb_listener" "wordpress_http_listener" {
  load_balancer_arn = aws_lb.wordpress-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-target-group.arn
  }
}


