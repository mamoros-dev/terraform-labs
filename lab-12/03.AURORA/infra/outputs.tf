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
    instance_id = aws_rds_cluster_instance.aurora_instances[*].id
    endpoint    = aws_rds_cluster_instance.aurora_instances[*].endpoint
    subnet_id   = aws_subnet.private[*].id
  }
}

# --- OUTPUTS PARA LOS ENDPOINTS ---
output "aurora_writer_endpoint" {
  description = "Endpoint de Escritura (Primary) de Aurora"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_reader_endpoint" {
  description = "Endpoint de Lectura (Reader) de Aurora (balancea automáticamente entre réplicas)"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}