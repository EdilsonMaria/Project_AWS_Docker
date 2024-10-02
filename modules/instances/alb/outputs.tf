output "wordpress_lb" {
  value = aws_lb.wordpress_lb
}

output "wordpress_target_group" {
  value = aws_lb_target_group.wordpress-target-group
}

output "wordpress_http_listener" {
  value = aws_lb_listener.wordpress_http_listener
}