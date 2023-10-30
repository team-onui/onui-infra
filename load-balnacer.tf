resource "aws_alb" "default" {
  name                  = "${var.app_name}-ALB"
  subnets               = aws_subnet.public.*.id
  load_balancer_type    = "application"
  security_groups       = [aws_security_group.alb.id]
  internal              = false

  tags = {
    Name                = "${var.app_name}-ALB"
    name                = "onui"
  }
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn     = aws_alb.default.id
  port                  = 443
  protocol              = "HTTPS"
  certificate_arn       = aws_acm_certificate.cert.arn

  default_action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  vpc_id                = aws_vpc.vpc.id
  name                  = "service-alb-tg"
  port                  = 80
  protocol              = "HTTP"
  target_type           = "ip"
  deregistration_delay  = 30

  health_check {
    interval            = 120
    path                = "/auth/google/link"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = {
    Name                = "service-alb-tg"
    name                = "onui"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn     = aws_lb_target_group.http.arn
  target_id            = aws_instance.ec2.private_ip
  port                 = 80

  depends_on = [
    aws_lb_target_group.http,
    aws_instance.ec2
  ]
}
