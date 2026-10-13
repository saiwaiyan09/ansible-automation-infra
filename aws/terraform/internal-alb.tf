resource "aws_lb" "internal" {
  name               = "${substr(var.project_name, 0, 19)}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb.id]
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name        = "${substr(var.project_name, 0, 19)}-internal-alb"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "counting" {
  name        = "${trimsuffix(substr(var.project_name, 0, 20), "-")}-counting-tg"
  port        = 9003
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${trimsuffix(substr(var.project_name, 0, 20), "-")}-counting-tg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 9002
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.counting.arn
  }
}

resource "aws_lb_target_group_attachment" "counting" {
  target_group_arn = aws_lb_target_group.counting.arn
  target_id        = aws_instance.counting.id
  port             = 9003
}
