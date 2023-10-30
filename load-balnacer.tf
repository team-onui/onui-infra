resource "aws_alb" "default" {
  name               = "hihghton-ALB"
  subnets            = aws_subnet.public.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  internal           = false

  tags = {
    Name = "hihghton-ALB"
    name = "2-2Admin"
  }
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_alb.default.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_alb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "http" {
  vpc_id                = aws_vpc.vpc.id
  name                  = "service-alb-tg"
  port                  = var.host_port
  protocol              = "HTTP"
  target_type           = "ip"
  deregistration_delay  = 30

  health_check {
    interval            = 120
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}