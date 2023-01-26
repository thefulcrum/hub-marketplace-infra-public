########################################################################################################################
# Application
#variable "account" {
#  type = number
#  description = "AWS account number"
#}

#variable "profile" {
#  type = string
#  description = "AWS S3 profile to use for the IAC"
#}

variable "region" {
  type        = string
  description = "region"
}

variable "app_name" {
  type        = string
  description = "Application name, which will use across different resource provisioing. Please make it unique with in account."
}

variable "env" {
  type        = string
  description = "Environment"
}
########################################################################################################################

# VPC
variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
}

variable "general_subnets" {
  type = object(
    {
      public=map(object({
        cidr = string
        availability_zone = string
      })), 
      private=map(object({
        cidr = string
        availability_zone = string
      }))
    }
  )
  description = "Subnets mapping"
}

variable "eks_subnets" {
  type = object(
    {
      public=map(object({
        cidr = string
        availability_zone = string
      })),
      private=map(object({
        cidr = string
        availability_zone = string
      }))
    }
  )
  description = "Subnets mapping"
}


variable "public_nat_gateway_zone" {
  type        = string
  description = "Public NAT Gateway for General subnet"
}

variable "eks_public_nat_gateway_zone" {
  type        = string
  description = "Public NAT Gateway for EKS subnet"
}

variable "databases" {
  type = map(object({
    username          = string
    allocated_storage = number
    db_name           = string
    engine            = string
    engine_version    = string
    instance_class    = string
  }))
}

variable "elastic_caches" {
  type = map(object({
    cluster_id           = string
    node_type            = string
    parameter_group_name = string
    engine_version       = string
    port                 = number
  }))
  description = "Elastic Cache instance"
}