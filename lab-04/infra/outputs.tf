output "vpc_id" {
  description = "ID of the VPC creada en la raíz"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "IDs of the private subnets creada en la raíz"
  value       = aws_subnet.main.id
}

# ya teniamos la salida en el modulo pero si la quieres llamar en la raiz
# se pone module.nombre_modulo.nombre_output
output "private_ec2_ip" {
  description = "Ip privada de la instancia traída desde el módulo"
  value       = module.mi_instancia_ec2.private_ip
}

output "server_summary" {
  description = "Resumen estructurado de la infraestructura desplegada"
  value = {
    instance_id       = module.mi_instancia_ec2.instance_id       # llamando al output del modulo
    private_ip        = module.mi_instancia_ec2.private_ip        # llamando al output del modulo
    security_group_id = module.mi_instancia_ec2.security_group_id # llamando al output del modulo
    subnet_id         = aws_subnet.main.id
    ami_used          = module.mi_instancia_ec2.ami_id       # llamando al output del modulo
    architecture      = module.mi_instancia_ec2.architecture # llamando al output del modulo
  }
}
