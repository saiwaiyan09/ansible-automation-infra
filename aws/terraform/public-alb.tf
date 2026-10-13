resource "aws_lb" "public" {
  name                       = "${substr(var.project_name, 0, 20)}-public-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.public_alb.id]
  subnets                    = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  enable_deletion_protection = false

  tags = {
    Name        = "${substr(var.project_name, 0, 20)}-public-alb"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "dashboard" {
  name        = "${trimsuffix(substr(var.project_name, 0, 19), "-")}-dashboard-tg"
  port        = 9002
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
    Name        = "${trimsuffix(substr(var.project_name, 0, 19), "-")}-dashboard-tg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dashboard.arn
  }
}
