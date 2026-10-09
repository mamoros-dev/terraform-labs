output "bucket_name" {
  description = "Nombre real del bucket, incluido el sufijo aleatorio."
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "ARN del bucket. El ARN es el identificador universal de un recurso en AWS."
  value       = aws_s3_bucket.website.arn
}

output "website_endpoint" {
  description = "Hostname del website endpoint de S3 (sin https://)."
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_url" {
  description = "Website endpoint de S3. Solo HTTP: el navegador fallará si fuerza HTTPS."
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "website_https_url" {
  description = "URL HTTPS del index.html (API REST de S3). Úsala en el navegador."
  value       = "https://${aws_s3_bucket.website.bucket_regional_domain_name}/${aws_s3_object.index.key}"
}

output "index_object_key" {
  description = "Clave (ruta) del objeto subido al bucket."
  value       = aws_s3_object.index.key
}
