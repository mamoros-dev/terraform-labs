# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Esto garantiza que las instancias EC2 reciban nombres de dominio DNS públicos/privados
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab02-ec2-ssm"
  }
}

# --- Private Subnet ---
# --- Subred privada ---
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.50.0/24"

  tags = {
    Name = "lab02-private-ec2-ssm"
  }
}

# -- Role SSM ---
## Crea el IAM Role para SSM y adjúntalo a la EC2 Privada
resource "aws_iam_role" "ssm_role" {
  name = "lab02-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

## Adjuntar la política oficial de SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## Perfil de instancia para asociar a la EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "lab02-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# Security Group para los VPC Endpoints (443 HTTPS)
# --- Security Group para los VPC Endpoints ---
resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "lab02-vpc-endpoints-sg"
  description = "Allow inbound HTTPS traffic from VPC for SSM endpoints"
  vpc_id      = aws_vpc.main.id

  # Permite que la EC2 (10.0.0.0/16) conecte al endpoint por el puerto 443
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab02-vpc-endpoints-sg"
  }
}

## Los 3 VPC Endpoints de SSM
# --- Lista de servicios SSM necesarios ---
locals {
  ssm_services = [
    "com.amazonaws.${var.region}.ssm",
    "com.amazonaws.${var.region}.ssmmessages",
    "com.amazonaws.${var.region}.ec2messages"
  ]
}

# --- VPC Endpoints con count ---
resource "aws_vpc_endpoint" "ssm_endpoints" {
  count               = length(local.ssm_services)
  vpc_id              = aws_vpc.main.id
  service_name        = local.ssm_services[count.index]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.main.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "lab02-vpce-${count.index}"
  }
}


# -- AMI Amazon linuz 2023 --
# --- AMI para las instancias EC2 ---
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -- Instancia EC2 en subred privada --
resource "aws_instance" "private_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.main.id

  # Adjuntamos el perfil SSM
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "lab02-private-ec2-ssm"
  }
}

