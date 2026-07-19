# RDS Module - Creates a PostgreSQL RDS instance with secure defaults
# Random password for RDS
resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}|;:,.<>?"
}

# Generate unique secret name to avoid conflicts
locals {
  secret_name = "${var.project_name}-${var.environment}-rds-credentials"
}

# Store RDS password in Secrets Manager with unique name
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = local.secret_name
  description             = "RDS password for ${var.environment} environment"
  recovery_window_in_days = 7


}

# Store the password value
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = var.database_username
    password = random_password.master_password.result
  })
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for ${var.environment} RDS PostgreSQL database - allows access from bastion, EKS, and application security groups"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.additional_security_group_ids
    cidr_blocks     = var.allowed_cidr_blocks
    description     = "PostgreSQL database access from bastion, EKS, and application security groups"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "${var.environment}-rds-parameter-group"
  family      = "postgres${replace(var.engine_version, "/^([0-9]+).*$/", "$1")}"
  description = "Parameter group for ${var.environment} RDS instance"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

}

resource "aws_db_instance" "rds_instance" {
  identifier            = "${var.environment}-rds"
  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.database_name
  username = var.database_username
  password = random_password.master_password.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name

  multi_az          = var.multi_az
  availability_zone = var.multi_az ? null : var.availability_zone

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-rds-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection       = var.deletion_protection

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]


}

# Read Replica (if enabled)
resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? 1 : 0

  replicate_source_db = aws_db_instance.rds_instance.identifier
  identifier          = "${var.environment}-rds-replica"
  instance_class      = var.replica_instance_class != "" ? var.replica_instance_class : var.instance_class

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  multi_az            = false
  publicly_accessible = false

  skip_final_snapshot   = true
  deletion_protection   = var.deletion_protection

  vpc_security_group_ids = [aws_security_group.rds.id]

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null


}
