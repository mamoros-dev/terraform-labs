output "instance_id" {
  description = "ID de la instancia EC2 creada"
  value       = aws_instance.ec2.id
}

output "private_ip" {
  description = "IP privada de la instancia"
  value       = aws_instance.ec2.private_ip
}

output "security_group_id" {
  description = "ID del Security Group creado dentro del modulo"
  value       = aws_security_group.module_sg.id
}

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "architecture" {
  description = "Arquitectura de la AMI"
  value       = data.aws_ami.amazon_linux.architecture
}
