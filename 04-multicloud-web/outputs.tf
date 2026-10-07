output "deployment_id" {
  description = "Sufijo compartido. Aparece en los nombres de AWS, Azure y en el HTML."
  value       = local.suffix
}

output "aws_url" {
  description = "Página en AWS (HTTPS sobre la API REST de S3)."
  value       = "https://${aws_s3_bucket.web.bucket_regional_domain_name}/index.html"
}

output "azure_url" {
  description = "Página en Azure (static website, HTTPS)."
  value       = azurerm_storage_account.web.primary_web_endpoint
}

output "aws_bucket" {
  description = "Nombre del bucket S3."
  value       = aws_s3_bucket.web.id
}

output "azure_storage_account" {
  description = "Nombre del Storage Account."
  value       = azurerm_storage_account.web.name
}
