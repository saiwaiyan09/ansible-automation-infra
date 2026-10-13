resource "aws_security_group" "public_alb" {
  name        = "${var.project_name}-public-alb-sg"
  description = "Security group for the internet-facing public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-public-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "dashboard" {
  name        = "${var.project_name}-dashboard-sg"
  description = "Security group for the private Dashboard application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-dashboard-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_https" {
  security_group_id = aws_security_group.public_alb.id
  description       = "Allow HTTPS from the internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_http" {
  security_group_id = aws_security_group.public_alb.id
  description       = "Allow HTTP from the internet for testing"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "public_alb_to_dashboard" {
  security_group_id            = aws_security_group.public_alb.id
  description                  = "Allow ALB traffic to Dashboard targets"
  ip_protocol                  = "tcp"
  from_port                    = 9002
  to_port                      = 9002
  referenced_security_group_id = aws_security_group.dashboard.id
}

resource "aws_vpc_security_group_ingress_rule" "dashboard_from_public_alb" {
  security_group_id            = aws_security_group.dashboard.id
  description                  = "Allow Dashboard traffic from the public ALB"
  ip_protocol                  = "tcp"
  from_port                    = 9002
  to_port                      = 9002
  referenced_security_group_id = aws_security_group.public_alb.id
}

resource "aws_vpc_security_group_ingress_rule" "dashboard_ssh_from_ansible_controller" {
  security_group_id            = aws_security_group.dashboard.id
  description                  = "Allow SSH from the Ansible Controller"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.ansible_controller.id
}

resource "aws_vpc_security_group_egress_rule" "dashboard_all_outbound" {
  security_group_id = aws_security_group.dashboard.id
  description       = "Allow outbound traffic for Dashboard operations"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "internal_alb" {
  name        = "${var.project_name}-internal-alb-sg"
  description = "Security group for the private internal ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-internal-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "counting" {
  name        = "${var.project_name}-counting-sg"
  description = "Security group for the private Counting application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-counting-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "ansible_controller" {
  name        = "${var.project_name}-ansible-controller-sg"
  description = "Security group for the Ansible Controller"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-ansible-controller-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "ansible_controller_ssh" {
  security_group_id = aws_security_group.ansible_controller.id
  description       = "Allow SSH to the Ansible Controller"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ansible_controller_ssh_cidr
}

resource "aws_vpc_security_group_egress_rule" "ansible_controller_http" {
  security_group_id = aws_security_group.ansible_controller.id
  description       = "Allow HTTP access for software downloads"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ansible_controller_https" {
  security_group_id = aws_security_group.ansible_controller.id
  description       = "Allow HTTPS access for software downloads"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ansible_controller_ssh_dashboard" {
  security_group_id            = aws_security_group.ansible_controller.id
  description                  = "Allow SSH to Dashboard instances"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.dashboard.id
}

resource "aws_vpc_security_group_egress_rule" "ansible_controller_ssh_counting" {
  security_group_id            = aws_security_group.ansible_controller.id
  description                  = "Allow SSH to Counting instances"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.counting.id
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_dashboard" {
  security_group_id            = aws_security_group.internal_alb.id
  description                  = "Allow Dashboard traffic to the internal ALB"
  ip_protocol                  = "tcp"
  from_port                    = 9002
  to_port                      = 9002
  referenced_security_group_id = aws_security_group.dashboard.id
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_to_counting" {
  security_group_id            = aws_security_group.internal_alb.id
  description                  = "Allow internal ALB traffic to Counting targets"
  ip_protocol                  = "tcp"
  from_port                    = 9003
  to_port                      = 9003
  referenced_security_group_id = aws_security_group.counting.id
}

resource "aws_vpc_security_group_ingress_rule" "counting_from_internal_alb" {
  security_group_id            = aws_security_group.counting.id
  description                  = "Allow Counting traffic from the internal ALB"
  ip_protocol                  = "tcp"
  from_port                    = 9003
  to_port                      = 9003
  referenced_security_group_id = aws_security_group.internal_alb.id
}

resource "aws_vpc_security_group_ingress_rule" "counting_ssh_from_ansible_controller" {
  security_group_id            = aws_security_group.counting.id
  description                  = "Allow SSH from the Ansible Controller"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.ansible_controller.id
}

resource "aws_vpc_security_group_egress_rule" "counting_all_outbound" {
  security_group_id = aws_security_group.counting.id
  description       = "Allow all outbound traffic for the initial lab configuration"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
