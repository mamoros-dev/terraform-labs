output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "IDs of the private subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_id" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "server_summary" {
  description = "Resumen estructurado de la infraestructura desplegada"
  value = {
    subnet_id = aws_subnet.private[*].id
  }
}

# --- OUTPUTS DE DYNAMODB ---
output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB creada"
  value       = aws_dynamodb_table.empresa_table.name
}

output "dynamodb_table_arn" {
  description = "ARN (Amazon Resource Name) de la tabla DynamoDB"
  value       = aws_dynamodb_table.empresa_table.arn
}