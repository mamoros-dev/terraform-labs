# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block = var.environment_config[var.environment] # Usamos el MAP según el entorno
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
  cidr_block = var.private_subnet_cidrs[0] # Extraemos el elemento 0 de la lista

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# -- Role SSM ---
## Crea el IAM Role para SSM y adjúntalo a la EC2 Privada
resource "aws_iam_role" "ssm_role" {
  name = "${var.environment}-ssm-role"

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
  name = "${var.environment}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
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

# --- Security Group usando la variable list(number) ---
resource "aws_security_group" "instance" {
  name        = "${var.project_name}-sg"
  description = "Security Group del laboratorio 01-ec2-basic"
  vpc_id      = aws_vpc.main.id

  # Regla 1: HTTPS (Puerto 443 -> var.allowed_ingress_ports[0])
  ingress {
    description = "HTTPS Inbound"
    from_port   = var.allowed_ingress_ports[0]
    to_port     = var.allowed_ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Regla 2: HTTP (Puerto 80 -> var.allowed_ingress_ports[1])
  ingress {
    description = "HTTP Inbound"
    from_port   = var.allowed_ingress_ports[1]
    to_port     = var.allowed_ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Salida libre hacia Internet (actualizar paquetes, consultar APIs, etc.).
  egress {
    description = "Salida a Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# -- Instancia EC2 en subred privada --
resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type # Validada en variables.tf (t2/t3)
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance.id]

  # Adjuntamos el perfil SSM
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  # Usamos la variable de tipo OBJECT para el volumen
  root_block_device {
    volume_size           = var.server_config.ebs_size_gb
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = var.server_config.name
  }
}
