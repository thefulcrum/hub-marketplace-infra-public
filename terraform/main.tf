terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.39"
    }
  }
  required_version = "= 1.3.7"

}

provider "aws" {
  region  = var.region
}

data "aws_caller_identity" "current" {}


module "vpc" {
  source = "./modules/vpc"

  app_name = var.app_name
  env      = var.env

  vpc_cidr_block = var.vpc_cidr_block

  /* General Purpose Subnet */
  general_public_subnets  = var.general_subnets.public
  general_private_subnets = var.general_subnets.private
  public_nat_gateway_zone = var.public_nat_gateway_zone

  /* EKS Subnet */
  eks_public_subnets  = var.eks_subnets.public
  eks_private_subnets = var.eks_subnets.private
  eks_public_nat_gateway_zone = var.eks_public_nat_gateway_zone

}

module "rds" {
  source = "./modules/rds"

  app_name = var.app_name
  vpc_id =  module.vpc.vpc_id
  
  private_subnet_ids = module.vpc.private_subnet_ids
  
  rds_db             = var.databases.db
  rds_dw             = var.databases.dw
  
  db_password        = module.secrets.db_password.secret_string
  dw_password        = module.secrets.dw_password.secret_string
  
  private_subnet_nodes_sg_id  = module.vpc.ec2_nodes_sg_id

  vpc_cidr_block = var.vpc_cidr_block
}

module "secrets" {
  source = "./modules/secrets"

  app_name = var.app_name
  env      = var.env
}


module "iam" {
  source = "./modules/iam"

  app_name = var.app_name
  bucket_name = module.s3.bucket_name
}
module "redis_cache" {
  source = "./modules/elasticache"

  app_name = var.app_name

  cluster_id           = var.elastic_caches.redis.cluster_id
  node_type            = var.elastic_caches.redis.node_type
  engine_version       = var.elastic_caches.redis.engine_version
  port                 = var.elastic_caches.redis.port
  parameter_group_name = var.elastic_caches.redis.parameter_group_name
  
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block

  private_subnet_ids = module.vpc.private_subnet_ids
  private_subnet_nodes_sg_id  = module.vpc.ec2_nodes_sg_id
}

module "storage" {
  source = "./modules/storage"

  app_name = var.app_name
  env      = var.env

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  private_subnet_services_sg = module.vpc.private_subnet_services_sg
}

module "s3" {
  source = "./modules/s3"

  app_name = var.app_name
  env      = var.env
  region   = var.region

}

resource "local_file" "descriptor" {
  content = templatefile("./../config/rawconfig.json.tftpl", {
    app_name = var.app_name
    env      = var.env

    base_url  = "*"
    api_url   = "*"
    redis_host= module.redis_cache.host
    cryptography_provider_symmetric_keys = module.secrets.secret_encryption_key.secret_string

    dw_database = module.rds.dw.db_name
    dw_host     = module.rds.dw.address
    dw_username = module.rds.dw.username
    dw_password = module.secrets.dw_password.secret_string

    dw_readonly_database = module.rds.dw.db_name
    dw_readonly_host     = module.rds.dw.address
    dw_readonly_username = module.rds.dw.username
    dw_readonly_password = module.secrets.dw_password.secret_string

    db_database = module.rds.db.db_name
    db_host     = module.rds.db.address
    db_username = module.rds.db.username
    db_password = module.secrets.db_password.secret_string

    db_readonly_database = module.rds.db.db_name
    db_readonly_host     = module.rds.db.address
    db_readonly_username = module.rds.db.username
    db_readonly_password = module.secrets.db_password.secret_string

    s3_bucket = module.s3.bucket_name

    jwt_secret = module.secrets.jwt_secret

  })
  filename = "./../eks/rawconfig.json"
}

resource "local_file" "alembic" {
  content = templatefile("./../config/alembic.ini.tftpl", {
    database = module.rds.db.db_name
    endpoint = module.rds.db.endpoint
    username = module.rds.db.username
    password = module.secrets.db_password.secret_string
  })
  filename = "./../eks/alembic.ini"
}

resource "local_file" "cluster" {
  content = templatefile("./../config/cluster.yaml.tftpl", {
    private_subnets = {for a in module.vpc.eks_private_subnets: a.id => a.availability_zone}
    public_subnets  = {for a in module.vpc.eks_public_subnets: a.id => a.availability_zone }
    name   = "${var.app_name}-${var.env}"
    region = var.region
    vpc_id = module.vpc.vpc_id
    ec2_nodes_sg = module.vpc.ec2_nodes_sg_id
    additional_policies = module.iam.s3_access_policy
    user_arn = data.aws_caller_identity.current.arn
    pod_execution_role = module.iam.pod_execution_role
    s3_access_policy = module.iam.s3_access_policy
  })
  filename = "./../eks/cluster.yaml"
}

resource "local_file" "efs_claim" {
  content = templatefile("./../config/efs.yaml.tftpl", {
    efs_id = module.storage.efs_id
  })
  filename = "./../eks/efs.yaml"
}