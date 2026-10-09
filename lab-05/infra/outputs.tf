output "active_workspace" {
  description = "Workspace de Terraform actualmente desplegado"
  value       = terraform.workspace
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets_created" {
  description = "Mapa de IDs de las subredes creadas dinámicamente con for_each"
  value       = { for k, v in aws_subnet.private_subnets : k => v.id }
}

output "server_summary" {
  description = "Resumen del servidor desplegado en el workspace activo"
  value = {
    environment       = terraform.workspace
    instance_id       = module.mi_instancia_ec2.instance_id
    private_ip        = module.mi_instancia_ec2.private_ip
    instance_type     = var.instance_type_map[terraform.workspace]
    vpc_cidr          = var.vpc_cidr_map[terraform.workspace]
    security_group_id = module.mi_instancia_ec2.security_group_id
  }
}