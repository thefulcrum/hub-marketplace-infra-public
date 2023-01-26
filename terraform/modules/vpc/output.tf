output "vpc_id" {
    value = aws_vpc.hub_cdp_vpc.id
}

output "private_subnet_ids" {
    value = [for subnet in aws_subnet.private_subnets: subnet.id]
}

output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public_subnets: subnet.id]
}

output "private_subnets" {
    value = aws_subnet.private_subnets
}

output "public_subnets" {
    value = aws_subnet.public_subnets
}

output "eks_private_subnets" {
    value = aws_subnet.eks_private_subnets
}

output "eks_public_subnets" {
    value = aws_subnet.eks_public_subnets
}

output "ec2_nodes_sg_id" {
    value = aws_security_group.ec2_nodes_sg.id
}

output "private_subnet_services_sg" {
    value = aws_security_group.private_subnet_services_sg.id
}