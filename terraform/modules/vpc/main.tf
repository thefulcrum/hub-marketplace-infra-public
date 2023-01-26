resource "aws_vpc" "hub_cdp_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app_name}-${var.env}-vpc"
  }
}


/***************************************
* GENERAL PURPOSE SUBNETS
****************************************/

resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.hub_cdp_vpc.id

  for_each = var.general_private_subnets

  cidr_block        = each.value.cidr
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${var.app_name}-${var.env}-${each.key}"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.hub_cdp_vpc.id

  for_each = var.general_public_subnets

  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${var.env}-${each.key}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hub_cdp_vpc.id

  tags = {
    Name = "${var.app_name}-${var.env}-igw"
  }
}

/* Start Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.hub_cdp_vpc.id
  tags   = {
    Name = "${var.app_name}-${var.env}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "to_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.hub_nat.id
}

/* Start Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hub_cdp_vpc.id
  tags   = {
    Name = "${var.app_name}-${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_nat_gateway" "hub_nat" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnets[var.public_nat_gateway_zone].id

  tags = {
    Name = "${var.app_name}-${var.env}-public-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}


/***************************************
* EKS SUBNETS
****************************************/

locals {
  cluster_name = "${var.app_name}-${var.env}"
}

resource "aws_subnet" "eks_private_subnets" {
  vpc_id = aws_vpc.hub_cdp_vpc.id

  for_each = var.eks_private_subnets

  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false
  tags                    = {
    Name                                          = "eks-${var.app_name}-${var.env}-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

resource "aws_subnet" "eks_public_subnets" {
  vpc_id = aws_vpc.hub_cdp_vpc.id

  for_each = var.eks_public_subnets

  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "eks-${var.app_name}-${var.env}-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
}

resource "aws_route_table_association" "eks_public" {
  for_each = aws_subnet.eks_public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "eks_private" {
  for_each = aws_subnet.eks_private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Security Groups

resource "aws_security_group" "private_subnet_services_sg" {
  name        = "${var.app_name}_private_subnet_services"
  description = "Allow communication from Privaete subnets"
  vpc_id      = aws_vpc.hub_cdp_vpc.id

  ingress {
    description      = "Allow incoming traffic from private resource"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [aws_security_group.ec2_nodes_sg.id]
  }

  ingress {
    description      = "Allow NFS traffic - TCP 2049"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
 }
}

resource "aws_security_group" "ec2_nodes_sg" {
  name        = "${var.app_name}_ec2_nodes_sg"
  description = "Security group for the EC2 nodes."
  vpc_id      = aws_vpc.hub_cdp_vpc.id
}
