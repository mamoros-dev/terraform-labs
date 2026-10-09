terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = terraform.workspace # <--- Asigna "dev" o "prod" automáticamente
      Owner       = "Miguel Amoros"
      ManagedBy   = "Terraform"
    }
  }
}
