# Partial S3 backend configuration.
# Supply values using: terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {}

  required_version = ">= 1.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15"
    }
  }
}
