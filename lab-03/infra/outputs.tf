output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "IDs of the private subnets"
  value       = aws_subnet.main.id
}

output "private_ec2_ip" {
  value = aws_instance.private_ec2.private_ip
}

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "server_summary" {
  description = "Resumen estructurado de la infraestructura desplegada"
  value = {
    instance_id  = aws_instance.private_ec2.id
    private_ip   = aws_instance.private_ec2.private_ip
    subnet_id    = aws_subnet.main.id
    ami_used     = data.aws_ami.amazon_linux.id
    architecture = data.aws_ami.amazon_linux.architecture
  }
}