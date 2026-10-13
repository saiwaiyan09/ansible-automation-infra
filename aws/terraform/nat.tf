resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-a-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-b-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.allocation_id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name        = "${var.project_name}-nat-a"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.allocation_id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name        = "${var.project_name}-nat-b"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}
