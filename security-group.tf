resource "aws_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  name = "alb-sg"

  ingress {
    from_port         = var.host_port
    protocol          = "tcp"
    to_port           = var.host_port
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  ingress {
    from_port         = 443
    protocol          = "tcp"
    to_port           = 443
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name = "2-2Admin"
  }
}

resource "aws_security_group" "ecs_tasks" {
  vpc_id = aws_vpc.vpc.id
  name = "ecs-tasks-sg"

  ingress {
    from_port       = var.host_port
    protocol        = "tcp"
    to_port         = var.container_port
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port     = 0
    protocol      = "-1"
    to_port       = 0
    cidr_blocks   = ["0.0.0.0/0"]
  }

  tags = {
    name = "2-2Admin"
  }
}