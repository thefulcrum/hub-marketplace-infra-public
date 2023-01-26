## Application configurations
region   = "ap-southeast-2"
app_name = "n3-hub-cdp"
env      = "marketplace"

vpc_cidr_block = "10.0.0.0/16"


general_subnets = {
  public = {
    subnet-public-a = { cidr = "10.0.1.0/24", availability_zone = "ap-southeast-2a" }
    subnet-public-b = { cidr = "10.0.2.0/24", availability_zone = "ap-southeast-2b" }
    subnet-public-c = { cidr = "10.0.3.0/24", availability_zone = "ap-southeast-2c" }
  }
  private = {
    subnet-private-a = { cidr = "10.0.101.0/24", availability_zone = "ap-southeast-2a" }
    subnet-private-b = { cidr = "10.0.102.0/24", availability_zone = "ap-southeast-2b" }
    subnet-private-c = { cidr = "10.0.103.0/24", availability_zone = "ap-southeast-2c" }
  }
}

eks_subnets = {
  public = {
    subnet-eks-public-a = { cidr = "10.0.4.0/24", availability_zone = "ap-southeast-2a" }
    subnet-eks-public-b = { cidr = "10.0.5.0/24", availability_zone = "ap-southeast-2b" }
    subnet-eks-public-c = { cidr = "10.0.6.0/24", availability_zone = "ap-southeast-2c" }
  }
  private = {
    subnet-eks-private-a = { cidr = "10.0.104.0/24", availability_zone = "ap-southeast-2a" }
    subnet-eks-private-b = { cidr = "10.0.105.0/24", availability_zone = "ap-southeast-2b" }
    subnet-eks-private-c = { cidr = "10.0.106.0/24", availability_zone = "ap-southeast-2c" }
  }
}

public_nat_gateway_zone     = "subnet-public-a"
eks_public_nat_gateway_zone = "subnet-public-a"

databases = {
  db = {
    username          = "master"
    allocated_storage = 10
    db_name           = "hub_db"
    engine            = "postgres"
    engine_version    = "11.16"
    instance_class    = "db.t3.small"
  }
  dw = {
    username          = "master"
    allocated_storage = 10
    db_name           = "hub_db"
    engine            = "postgres"
    engine_version    = "11.16"
    instance_class    = "db.t3.small"
  }
}

elastic_caches = {
  redis = {
    cluster_id           = "redis-memory"
    node_type            = "cache.t2.micro"
    parameter_group_name = "default.redis7"
    engine_version       = "7.0"
    port                 = 6379
  }
}
