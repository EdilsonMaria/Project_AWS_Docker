# --------------------------------------
# ELASTC LOAD BALANCE ELB
# --------------------------------------
resource "aws_lb" "wordpress-lb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_SG]
  subnets            = [var.subnet-project2-publica1.id, var.subnet-project2-publica2.id]

  enable_deletion_protection = false

  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "wordpress-lb"
  }
}

# --------------------------------------
# Target Group 
# --------------------------------------
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
    path                = "/wp-admin/setup-config.php"
    protocol            = "HTTP"
    port                = "80"
    matcher             = "200"
  }
}

# --------------------------------------
# LISTENER HTTP
# --------------------------------------
resource "aws_lb_listener" "wordpress_http_listener" {
  load_balancer_arn = aws_lb.wordpress-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-target-group.arn
  }
}


