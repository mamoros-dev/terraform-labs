terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # archive empaqueta el .py en un ZIP. Lambda no acepta un .py suelto:
    # hay que subir un archivo comprimido (o un contenedor, que no usamos aquí).
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.6"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}