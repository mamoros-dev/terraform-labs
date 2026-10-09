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

  # añade a cada recurso todas estas etiquetas por defecto
  default_tags {
    tags = {
      Project     = "Lab01-vpc"
      Environment = "dev"
      Owner       = "Miguel Amoros"
      ManagedBy   = "Terraform"
    }
  }
}