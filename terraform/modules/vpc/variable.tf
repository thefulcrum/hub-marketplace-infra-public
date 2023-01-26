variable "vpc_cidr_block" {
  type = string
}

variable "general_public_subnets" {
  type = map(object({
    cidr              = string,
    availability_zone = string,
  }))
}

variable "general_private_subnets" {
  type = map(object({
    cidr              = string,
    availability_zone = string,
  }))
}

variable "eks_public_subnets" {
  type = map(object({
    cidr              = string,
    availability_zone = string,
  }))
}

variable "eks_private_subnets" {
  type = map(object({
    cidr              = string,
    availability_zone = string,
  }))
}


variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "public_nat_gateway_zone" {
  type        = string
  description = "Public NAT Gateway key name."
}


variable "eks_public_nat_gateway_zone" {
  type        = string
  description = "Public NAT Gateway key name."
}
