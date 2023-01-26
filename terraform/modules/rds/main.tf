resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "${var.app_name}private_subnet_group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "Private Subnet Group"
  }
}
resource "aws_db_instance" "db" {
    allocated_storage    = var.rds_db.allocated_storage
    db_name              = var.rds_db.db_name
    engine               = var.rds_db.engine
    engine_version       = var.rds_db.engine_version
    instance_class       = var.rds_db.instance_class
    username             = var.rds_db.username
    password             = var.db_password
    db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
    
    skip_final_snapshot  = true
    backup_retention_period = 0

    vpc_security_group_ids = [aws_security_group.rds_private_subnet_services_sg.id]
}

resource "aws_db_instance" "dw" {
    allocated_storage    = var.rds_dw.allocated_storage
    db_name              = var.rds_dw.db_name
    engine               = var.rds_dw.engine
    engine_version       = var.rds_dw.engine_version
    instance_class       = var.rds_dw.instance_class
    username             = var.rds_dw.username
    password             = var.dw_password
    db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
    
    skip_final_snapshot  = true
    backup_retention_period = 0

    vpc_security_group_ids = [aws_security_group.rds_private_subnet_services_sg.id]
}

resource "aws_security_group" "rds_private_subnet_services_sg" {
  name        = "${var.app_name}_private_subnet_services_for_rds"
  description = "Allow communication from Privaete subnets nodes"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow incoming traffic from private resource"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [var.private_subnet_nodes_sg_id]
    cidr_blocks = [var.vpc_cidr_block]
  }
}