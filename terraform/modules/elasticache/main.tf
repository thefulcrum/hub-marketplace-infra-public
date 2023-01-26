resource "aws_elasticache_replication_group" "elasticache" {    
    engine               = "redis"
    replication_group_id = "${var.app_name}-redis-cache"
    description          = "Redhis cache"

    node_type            = var.node_type
    engine_version       = var.engine_version
    port                 = var.port
    parameter_group_name = var.parameter_group_name

    subnet_group_name    = aws_elasticache_subnet_group.elastic_cache_subnet_group.name

    at_rest_encryption_enabled  = false
    transit_encryption_enabled  = false
    security_group_ids = [aws_security_group.elasticache_private_subnet_services_sg.id]
}

resource "aws_elasticache_subnet_group" "elastic_cache_subnet_group" {
  name       = "${var.app_name}-elasticache-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "elasticache_private_subnet_services_sg" {
  name        = "${var.app_name}_elasticache_private_subnet_services_for_rds"
  description = "Allow communication from Private subnets nodes"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow incoming traffic from private resource"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    security_groups = [var.private_subnet_nodes_sg_id]
    cidr_blocks = [var.vpc_cidr_block]
  }
}