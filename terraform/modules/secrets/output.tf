output "db_password" {
  value = aws_secretsmanager_secret_version.database_password_secret_version
}

output "dw_password" {
  value = aws_secretsmanager_secret_version.dw_password_secret_version
}

output "secret_encryption_key" {
  value = aws_secretsmanager_secret_version.secrets_encryption_key_version
}

output "jwt_secret" {
  value = aws_secretsmanager_secret_version.jwt_secret_key_version.secret_string
}