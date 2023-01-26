variable "vpc_id" {
    type = string
}

variable "vpc_cidr_block" {
    type = string
}

variable "node_type" {
    type = string
}

variable "engine_version" {
    type = string
  
}

variable "cluster_id" {
    type = string
}

variable "port" {
    type = string
    default = 6379
}

variable "parameter_group_name" {
    type = string  
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "app_name" {
  type = string
}

variable "private_subnet_nodes_sg_id" {
  type = string
}