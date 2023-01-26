variable "vpc_id" {
  type = string
}

variable "app_name" {
  type = string
  description = "Application name"
}

variable "env" {
  type = string
  description = "Environment"
}

variable "private_subnets" {

}

variable "private_subnet_services_sg" {
  type = string
}