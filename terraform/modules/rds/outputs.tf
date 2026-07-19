output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.rds_instance.id
}

output "rds_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.rds_instance.arn
}

output "rds_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds_instance.address
}

output "rds_instance_port" {
  description = "The port the RDS instance listens on"
  value       = aws_db_instance.rds_instance.port
}

output "rds_instance_username" {
  description = "The master username for the RDS instance"
  value       = aws_db_instance.rds_instance.username
  sensitive   = true
}


output "rds_instance_db_name" {
  description = "The name of the database"
  value       = aws_db_instance.rds_instance.db_name
}

output "rds_instance_status" {
  description = "The status of the RDS instance"
  value       = aws_db_instance.rds_instance.status
}

output "rds_security_group_id" {
  description = "The ID of the security group attached to the RDS instance"
  value       = aws_security_group.rds.id
}

output "rds_subnet_group_id" {
  description = "The ID of the RDS subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.id
}

output "rds_parameter_group_id" {
  description = "The ID of the RDS parameter group"
  value       = aws_db_parameter_group.rds_parameter_group.id
}

# Read Replica Outputs
output "rds_replica_endpoint" {
  description = "The connection endpoint for the RDS read replica (if created)"
  value       = var.create_read_replica ? aws_db_instance.replica[0].endpoint : null
}

output "rds_replica_address" {
  description = "The address of the RDS read replica (if created)"
  value       = var.create_read_replica ? aws_db_instance.replica[0].address : null
}

output "rds_replica_arn" {
  description = "The ARN of the RDS read replica (if created)"
  value       = var.create_read_replica ? aws_db_instance.replica[0].arn : null
}

# Secrets Manager outputs
output "rds_password_secret_arn" {
  description = "ARN of the RDS password secret in Secrets Manager"
  value       = aws_secretsmanager_secret.rds_password.arn
}

output "rds_password_secret_name" {
  description = "Name of the RDS password secret in Secrets Manager"
  value       = aws_secretsmanager_secret.rds_password.name
}

# Secret outputs for sensitive data
