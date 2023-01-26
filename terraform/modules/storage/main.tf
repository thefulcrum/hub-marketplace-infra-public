resource "aws_efs_file_system" "data_storage" {
  encrypted = true

  tags = {
    Name = "${var.app_name}_${var.env}_storage"
  }
}

# Creating the EFS access point for AWS EFS File system

resource "aws_efs_access_point" "hub" {
  file_system_id = aws_efs_file_system.data_storage.id
  posix_user {
    gid = 1000
    uid = 1000
  }
 root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
    path = "/hub"
  }
}

resource "aws_efs_mount_target" "mount_points" {
  file_system_id = aws_efs_file_system.data_storage.id

  for_each = var.private_subnets
  security_groups = [var.private_subnet_services_sg]
  subnet_id      = each.value.id
}

output "aabb"{
  value = var.private_subnets
}