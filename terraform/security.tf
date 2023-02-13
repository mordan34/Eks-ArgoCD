# Random string to use as master password
resource "random_password" "master_password" {
  length  = 12
  special = false
}

resource "aws_secretsmanager_secret" "sm" {
  name                    = format("secret-%s-%s-%s", var.appname, var.env_name, random_string.suffix.result)
  description             = format("Secret for %s in %s environment", var.appname, var.env_name)
  recovery_window_in_days = 7

  # Tags
  tags = {
    environment = var.env_name
    build       = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "sm" {
  secret_id     = aws_secretsmanager_secret.sm.id
  secret_string = jsonencode(random_password.master_password.result)

  depends_on = [
        random_password.master_password
  ]
}