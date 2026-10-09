# 1. IAM Role y Perfil para SSM
resource "aws_iam_role" "ssm_role" {
  name = "${var.instance_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.instance_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# 2. Data Source para la AMI de Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# 3. Security Group con BLOQUE DYNAMIC
resource "aws_security_group" "module_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security Group dinamico para ${var.instance_name}"
  vpc_id      = var.vpc_id

  # --- DYNAMIC INGRESS BLOCK ---
  dynamic "ingress" {
    for_each = var.ingress_rules # Itara sobre la lista de objetos en var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# 4. Instancia EC2 Privada
resource "aws_instance" "ec2" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type # <--- Recibido desde el Root Module
  subnet_id            = var.subnet_id     # <--- Recibido desde el Root Module
  vpc_security_group_ids = [aws_security_group.module_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}