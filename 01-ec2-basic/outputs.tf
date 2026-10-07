# Los outputs muestran información útil cuando termina terraform apply.
# También se consultan después con `terraform output`.

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.lab.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.lab.public_ip
}

output "website_url" {
  description = "URL HTTP servida por nginx (user_data). Espera 1-2 minutos tras el apply."
  value       = "http://${aws_instance.lab.public_ip}"
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.lab.public_dns
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.lab.private_ip
}

output "instance_ami" {
  description = "The AMI ID used for the EC2 instance"
  value       = aws_instance.lab.ami
}

output "ami_id" {
  description = "AMI que eligió el data source. Útil para ver que no está hardcodeada."
  value       = data.aws_ami.amazon_linux.id
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = aws_security_group.instance.id
}