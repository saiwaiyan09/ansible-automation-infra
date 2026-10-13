variable "aws_profile" {
  description = "Local AWS CLI profile used by the AWS provider."
  type        = string
  default     = "main-console-admin"
}

variable "aws_region" {
  description = "AWS region in which the infrastructure will be created."
  type        = string
  default     = "ap-southeast-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "The AWS region must not be empty."
  }
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "ansible-automation-infra"

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "The project name must not be empty."
  }
}

variable "environment" {
  description = "Environment name used in resource tags."
  type        = string
  default     = "dev"

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "The environment must not be empty."
  }
}

variable "ansible_controller_instance_type" {
  description = "EC2 instance type for the Ansible Controller."
  type        = string
  default     = "t3.micro"
}

variable "ansible_controller_key_name" {
  description = "Optional existing EC2 key pair name for SSH access to the Ansible Controller."
  type        = string
  default     = "ansible-controller-key"
  nullable    = true
}

variable "ansible_controller_ssh_cidr" {
  description = "Administrator IPv4 CIDR allowed to SSH to the Ansible Controller; use the administrator's public IPv4 address with /32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ansible_controller_ssh_cidr))
    error_message = "The Ansible Controller SSH CIDR must be a valid IPv4 CIDR block."
  }
}

variable "dashboard_instance_type" {
  description = "EC2 instance type for the Dashboard application."
  type        = string
  default     = "t3.micro"
}

variable "counting_instance_type" {
  description = "EC2 instance type for the Counting application."
  type        = string
  default     = "t3.micro"
}

variable "application_key_name" {
  description = "Optional existing EC2 key pair name for SSH access to application instances."
  type        = string
  default     = "ansible-managed-nodes-key"
  nullable    = true
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone_a" {
  description = "Availability Zone for network resources in AZ A."
  type        = string
  default     = "ap-southeast-1a"

  validation {
    condition     = length(trimspace(var.availability_zone_a)) > 0
    error_message = "Availability Zone A must not be empty."
  }

  validation {
    condition     = lower(trimspace(var.availability_zone_a)) != lower(trimspace(var.availability_zone_b))
    error_message = "Availability Zone A and Availability Zone B must be different."
  }
}

variable "availability_zone_b" {
  description = "Availability Zone for network resources in AZ B."
  type        = string
  default     = "ap-southeast-1b"

  validation {
    condition     = length(trimspace(var.availability_zone_b)) > 0
    error_message = "Availability Zone B must not be empty."
  }
}

variable "public_subnet_a_cidr" {
  description = "IPv4 CIDR block reserved for public subnet A."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_a_cidr))
    error_message = "The public subnet A CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition = can(cidrnetmask(var.public_subnet_a_cidr)) && try(
      sum([
        for octet_index, octet in split(".", cidrhost(var.public_subnet_a_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
        ]) >= sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) &&
      sum([
        for octet_index, octet in split(".", cidrhost(var.public_subnet_a_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.public_subnet_a_cidr)[1])) <=
      sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.vpc_cidr)[1])),
      false
    )
    error_message = "The public subnet A CIDR must be entirely contained within the VPC CIDR."
  }

  validation {
    condition = can(cidrnetmask(var.public_subnet_a_cidr)) && try(alltrue([
      for pair in [
        [var.public_subnet_a_cidr, var.public_subnet_b_cidr],
        [var.public_subnet_a_cidr, var.private_subnet_a_cidr],
        [var.public_subnet_a_cidr, var.private_subnet_b_cidr],
        [var.public_subnet_b_cidr, var.private_subnet_a_cidr],
        [var.public_subnet_b_cidr, var.private_subnet_b_cidr],
        [var.private_subnet_a_cidr, var.private_subnet_b_cidr],
      ] :
      sum([
        for octet_index, octet in split(".", cidrhost(pair[0], 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
        ]) + pow(2, 32 - tonumber(split("/", pair[0])[1])) <= sum([
        for octet_index, octet in split(".", cidrhost(pair[1], 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) ||
      sum([
        for octet_index, octet in split(".", cidrhost(pair[1], 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
        ]) + pow(2, 32 - tonumber(split("/", pair[1])[1])) <= sum([
        for octet_index, octet in split(".", cidrhost(pair[0], 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ])
    ]), false)
    error_message = "The public and private subnet CIDRs must not overlap."
  }
}

variable "public_subnet_b_cidr" {
  description = "IPv4 CIDR block reserved for public subnet B."
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_b_cidr))
    error_message = "The public subnet B CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition = can(cidrnetmask(var.public_subnet_b_cidr)) && try(
      sum([
        for octet_index, octet in split(".", cidrhost(var.public_subnet_b_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
        ]) >= sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) &&
      sum([
        for octet_index, octet in split(".", cidrhost(var.public_subnet_b_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.public_subnet_b_cidr)[1])) <=
      sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.vpc_cidr)[1])),
      false
    )
    error_message = "The public subnet B CIDR must be entirely contained within the VPC CIDR."
  }
}

variable "private_subnet_a_cidr" {
  description = "IPv4 CIDR block reserved for private application subnet A."
  type        = string
  default     = "10.0.11.0/24"

  validation {
    condition     = can(cidrnetmask(var.private_subnet_a_cidr))
    error_message = "The private subnet A CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition = can(cidrnetmask(var.private_subnet_a_cidr)) && try(
      sum([
        for octet_index, octet in split(".", cidrhost(var.private_subnet_a_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
        ]) >= sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) &&
      sum([
        for octet_index, octet in split(".", cidrhost(var.private_subnet_a_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.private_subnet_a_cidr)[1])) <=
      sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.vpc_cidr)[1])),
      false
    )
    error_message = "The private subnet A CIDR must be entirely contained within the VPC CIDR."
  }
}

variable "private_subnet_b_cidr" {
  description = "IPv4 CIDR block reserved for private application subnet B."
  type        = string
  default     = "10.0.12.0/24"

  validation {
    condition     = can(cidrnetmask(var.private_subnet_b_cidr))
    error_message = "The private subnet B CIDR must be a valid IPv4 CIDR block."
  }

  validation {
    condition = can(cidrnetmask(var.private_subnet_b_cidr)) && try(
      sum([
        for octet_index, octet in split(".", cidrhost(var.private_subnet_b_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
        ]) >= sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) &&
      sum([
        for octet_index, octet in split(".", cidrhost(var.private_subnet_b_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.private_subnet_b_cidr)[1])) <=
      sum([
        for octet_index, octet in split(".", cidrhost(var.vpc_cidr, 0)) :
        tonumber(octet) * pow(256, 3 - octet_index)
      ]) + pow(2, 32 - tonumber(split("/", var.vpc_cidr)[1])),
      false
    )
    error_message = "The private subnet B CIDR must be entirely contained within the VPC CIDR."
  }
}