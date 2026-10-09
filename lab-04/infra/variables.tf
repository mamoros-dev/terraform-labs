variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Lab04-modules"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "environment" {
  description = "Entorno de despliegue (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}
