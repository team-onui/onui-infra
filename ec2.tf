resource "aws_instance" "ec2" {
  ami                             = "ami-0f52ba4acb7f8f76a"
  instance_type                   = "t2.small"
  key_name                        = var.app_name
  subnet_id                       = aws_subnet.public.*.id[0]
  vpc_security_group_ids          = [aws_security_group.ec2.id]

  ebs_block_device {
    device_name                   = "/dev/xvda"
    volume_size                   = 30
    delete_on_termination         = true
    volume_type                   = "gp3"
    tags = {
      Name                        = "onui-volume"
    }
  }
  tags = {
    Name                          = "onui-main-server"
  }
}