variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Lab03-variables-state"
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

variable "instance_type" {
  description = "Tipo de instancia EC2 permitida"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small"], var.instance_type)
    error_message = "Error: El tipo de instancia debe ser t2.micro, t3.micro o t3.small."
  }
}

variable "allowed_ingress_ports" {
  description = "Lista de puertos de entrada permitidos"
  type        = list(number)
  default     = [443, 80]
}

variable "environment_config" {
  description = "Mapeo de configuraciones por entorno"
  type        = map(string)
  default = {
    dev  = "10.0.0.0/16"
    prod = "10.1.0.0/16"
  }
}

variable "server_config" {
  description = "Objeto con la configuración detallada del servidor"
  type = object({
    name          = string
    ebs_size_gb   = number
    enable_backup = bool
  })
  default = {
    name          = "lab03-app-server"
    ebs_size_gb   = 30
    enable_backup = false
  }
}