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

output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints"
  value       = aws_vpc_endpoint.ssm_endpoints[*].id
}