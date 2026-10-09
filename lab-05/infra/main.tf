# --- 1. VPC Dinámica según el Workspace ---
resource "aws_vpc" "main" {
  # Selecciona el CIDR de VPC dependiendo de si el workspace es 'dev', 'prod' o 'default'
  cidr_block           = var.vpc_cidr_map[terraform.workspace]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-vpc"
  }
}

# --- 2. Subredes Privadas Calculadas Dinámicamente ---
# Definimos el mapa de subredes asignando un índice numérico netnum (1 y 2)
locals {
  subnet_offsets = {
    "subnet-a" = 1
    "subnet-b" = 2
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.subnet_offsets

  vpc_id            = aws_vpc.main.id
  # cidrsubnet("10.10.0.0/16", 8, 1) = cidrsubnet(prefix, newbits, netnum) -> Genera "10.10.1.0/24" en dev y "10.20.1.0/24" en prod
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value)
  availability_zone = "${var.region}${substr(each.key, -1, 1)}"

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-${each.key}"
  }
}

# --- 3. Instanciación del Módulo EC2 ---
module "mi_instancia_ec2" {
  source = "./modules/aws_private_ec2"

  instance_name = "mi-instancia-${terraform.workspace}"
  vpc_id        = aws_vpc.main.id
  # Como tenemos varias subredes por for_each, le pasamos la primera ("subnet-a"):
  subnet_id     = aws_subnet.private_subnets["subnet-a"].id
  instance_type = var.instance_type_map[terraform.workspace]
  environment   = terraform.workspace
}