output "data_storage_mount_points" {
  value = "aws_efs_mount_target.mount_points"
}

output "efs_id" {
  value = aws_efs_file_system.data_storage.id
}