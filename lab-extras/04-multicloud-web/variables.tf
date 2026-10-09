variable "azure_subscription_id" {
  description = "ID de la subscription de Azure. Consulta: az account show --query id -o tsv"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "azure_location" {
  description = "Región de Azure. eastus queda cerca de us-east-1 para el ejemplo."
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Nombre corto del proyecto. Azure Storage Account no admite guiones: solo minúsculas y números."
  type        = string
  default     = "tfmulti"

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.project_name))
    error_message = "project_name debe tener 3-10 caracteres, solo minúsculas y números (límite de Azure Storage)."
  }
}

variable "environment" {
  description = "Entorno (lab, dev, prod...)."
  type        = string
  default     = "lab"
}

variable "owner_name" {
  description = "Nombre que aparece en la página de ejemplo."
  type        = string
  default     = "Miguel Amoros"
}


