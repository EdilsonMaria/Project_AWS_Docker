#CRIAÇÃO ELASTC LOAD BALANCE ELB
resource "aws_lb" "wordpress_lb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_SG]
  subnets            = [var.subnet-project2-publica1, var.subnet-project2-publica2]

  enable_deletion_protection = false

  enable_http2       = true   
  enable_cross_zone_load_balancing = true 

  tags = {
    Name = "wordpress-lb"
  }
}

# Criar o Target Group (Grupo de Alvos) para as instâncias EC2
resource "aws_lb_target_group" "wordpress_target_group" {
  name        = "my-target-group"
  port        = 80  
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  
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
  load_balancer_arn = aws_lb.wordpress_lb
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_target_group
  }
}

# Registrar as instâncias EC2 no Target Group
#resource "aws_lb_target_group_attachment" "tg_attachment" {
#  count            = 2
#  target_group_arn = aws_lb_target_group.my_target_group.arn
#  target_id        = aws_instance.ec2_instances[count.index].id  # Vincular as instâncias EC2
#  port             = 80
#}

