# Un mismo proyecto Terraform puede hablar con varias nubes.
# Cada provider tiene su autenticación:
#   AWS   → aws configure / variables AWS_*
#   Azure → az login     / variables ARM_*
# No pongas credenciales en estos archivos.

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id

  # Por defecto Azure registra muchos Resource Providers y el plan parece
  # colgado (minutos sin output). "none" evita esa espera; Microsoft.Storage
  # suele estar ya registrado en la subscription.
  resource_provider_registrations = "none"
}
