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
    instance_id = aws_db_instance.mysql_instance.id
    endpoint    = aws_db_instance.mysql_instance.endpoint
    subnet_id   = aws_subnet.private[*].id
  }
}

# variables sensibles de la db
variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
  sensitive   = true # Indica a Terraform que es un dato sensible y lo oculta en los logs
}

variable "db_password" {
  description = "Contraseña del administrador de la base de datos"
  type        = string
  sensitive   = true
}

# Output para obtener el Endpoint privado
output "rds_postgres_endpoint" {
  description = "Endpoint privado de la base de datos PostgreSQL"
  value       = aws_db_instance.mysql_instance.endpoint
}

output "rds_postgres_port" {
  description = "Puerto de conexión de PostgreSQL"
  value       = aws_db_instance.mysql_instance.port
}

output "mysql_read_replica_endpoint" {
  description = "Endpoint de la replica de lectura de MySQL"
  value       = aws_db_instance.mysql_read_replica.endpoint
}