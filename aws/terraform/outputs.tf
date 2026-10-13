output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC IPv4 CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_a_id" {
  description = "Public subnet A ID"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "Public subnet B ID"
  value       = aws_subnet.public_b.id
}

output "private_subnet_a_id" {
  description = "Private subnet A ID"
  value       = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  description = "Private subnet B ID"
  value       = aws_subnet.private_b.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_a_id" {
  description = "Private route table A ID"
  value       = aws_route_table.private_a.id
}

output "private_route_table_b_id" {
  description = "Private route table B ID"
  value       = aws_route_table.private_b.id
}

output "nat_gateway_a_id" {
  description = "NAT Gateway A ID"
  value       = aws_nat_gateway.nat_a.id
}

output "nat_gateway_b_id" {
  description = "NAT Gateway B ID"
  value       = aws_nat_gateway.nat_b.id
}

output "ansible_controller_instance_id" {
  description = "Ansible Controller EC2 instance ID"
  value       = aws_instance.ansible_controller.id
}

output "ansible_controller_public_ip" {
  description = "Public IPv4 address of the Ansible Controller"
  value       = aws_instance.ansible_controller.public_ip
}

output "dashboard_instance_id" {
  description = "Dashboard EC2 instance ID"
  value       = aws_instance.dashboard.id
}

output "dashboard_private_ip" {
  description = "Dashboard EC2 private IPv4 address"
  value       = aws_instance.dashboard.private_ip
}

output "counting_instance_id" {
  description = "Counting EC2 instance ID"
  value       = aws_instance.counting.id
}

output "counting_private_ip" {
  description = "Counting EC2 private IPv4 address"
  value       = aws_instance.counting.private_ip
}

output "internal_alb_dns_name" {
  description = "Internal Application Load Balancer DNS name"
  value       = aws_lb.internal.dns_name
}

output "public_alb_dns_name" {
  description = "DNS name of the public Application Load Balancer"
  value       = aws_lb.public.dns_name
}

output "dashboard_url" {
  description = "Dashboard application URL through the public ALB"
  value       = "http://${aws_lb.public.dns_name}"
}