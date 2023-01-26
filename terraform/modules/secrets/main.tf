locals {
  db_password_key = "/${var.app_name}/${var.env}/database/password"
  dw_password_key = "/${var.app_name}/${var.env}/dw/password"
  secret_encryption_key = "/${var.app_name}/${var.env}/secrets/key"
  jwt_secret = "/${var.app_name}/${var.env}/jwt/secret"
}

# DB Password
resource "random_password" "database_password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "database_password_secret" {
  name = local.db_password_key
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_password_secret.id
  secret_string = random_password.database_password.result
}


# Dw Password
resource "random_password" "dw_password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "dw_password_secret" {
  name = local.dw_password_key
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "dw_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.dw_password_secret.id
  secret_string = random_password.dw_password.result
}

# API key
resource "random_password" "encryption_key" {
  length  = 32
  special = false
}
resource "aws_secretsmanager_secret" "secrets_encryption_key" {
  name = local.secret_encryption_key
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secrets_encryption_key_version" {
  secret_id     = aws_secretsmanager_secret.secrets_encryption_key.id
  secret_string = base64encode(random_password.encryption_key.result)
}

# JWT Secret
resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}
resource "aws_secretsmanager_secret" "jwt_secret_key" {
  name = local.jwt_secret
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "jwt_secret_key_version" {
  secret_id     = aws_secretsmanager_secret.jwt_secret_key.id
  secret_string = base64encode(random_password.jwt_secret.result)
}