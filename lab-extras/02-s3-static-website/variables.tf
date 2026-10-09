variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my-terraform-s3-static-website"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "lab"
}

variable "bucket_prefix" {
  description = "Prefijo del bucket. Terraform le añadirá un sufijo aleatorio porque el nombre de un bucket S3 debe ser único en toda AWS."
  type        = string
  default     = "tf-lab-website"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,20}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix debe usar solo minúsculas, números y guiones, y tener una longitud razonable."
  }
}

variable "index_document" {
  description = "Nombre del documento de índice que S3 servirá como página principal."
  type        = string
  default     = "index.html"
}
