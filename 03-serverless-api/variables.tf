variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my-terraform-lambda-api"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "lab"
}

variable "lambda_timeout" {
  description = "Tiempo máximo de ejecución de la función, en segundos."
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Memoria de la función en MB. 128 es el mínimo y el más barato."
  type        = number
  default     = 128
}

variable "log_retention_days" {
  description = "Días que se conservan los logs. Un valor bajo evita acumular almacenamiento."
  type        = number
  default     = 7
}
