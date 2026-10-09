# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Esto garantiza que las instancias EC2 reciban nombres de dominio DNS públicos/privados
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --- Private Subnet ---
# --- Subred privada ---
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[0] # el modulo definimos un string no lista por eso sin corchetes

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}


module "mi_instancia_ec2" {
  source = "./modules/aws_private_ec2" # Ruta local del módulo

  # Aquí le pasamos los valores a las variables del módulo:
  instance_name = "mi-instancia-dev"
  vpc_id        = aws_vpc.main.id
  subnet_id     = aws_subnet.main.id
  instance_type = "t3.micro"
  environment   = var.environment # o "dev", "prod", "staging"...
}