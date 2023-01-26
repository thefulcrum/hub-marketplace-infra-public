variable "vpc_id" {
    type = string
}

variable "vpc_cidr_block" {
    type = string
}

variable "app_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_db" {
    type = object({
        allocated_storage = number
        db_name           = string
        engine            = string
        instance_class    = string
        username          = string
        engine_version    = string
    })
  
}

variable "rds_dw" {
    type = object({
        allocated_storage = number
        db_name           = string
        engine            = string
        instance_class    = string
        username          = string
        engine_version    = string
    })
  
}

variable "db_password" {
  type = string
}

variable "dw_password" {
  type = string
}

variable "private_subnet_nodes_sg_id" {
  type = string
}