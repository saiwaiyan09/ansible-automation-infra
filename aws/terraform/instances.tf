data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "ansible_controller" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type               = var.ansible_controller_instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ansible_controller.id]
  associate_public_ip_address = true
  key_name                    = var.ansible_controller_key_name

  tags = {
    Name        = "${var.project_name}-ansible-controller"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "dashboard" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type               = var.dashboard_instance_type
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.dashboard.id]
  associate_public_ip_address = false
  key_name                    = var.application_key_name

  tags = {
    Name        = "${var.project_name}-dashboard"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "counting" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type               = var.counting_instance_type
  subnet_id                   = aws_subnet.private_b.id
  vpc_security_group_ids      = [aws_security_group.counting.id]
  associate_public_ip_address = false
  key_name                    = var.application_key_name

  tags = {
    Name        = "${var.project_name}-counting"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "dashboard" {
  target_group_arn = aws_lb_target_group.dashboard.arn
  target_id        = aws_instance.dashboard.id
  port             = 9002
}