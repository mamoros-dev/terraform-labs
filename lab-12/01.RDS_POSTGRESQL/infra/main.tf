# --- 1. RED Y VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# -- 2. INTERNET GATEWAY PARA LA SALIDA A INTERNET DE LA VPC ---
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# -------------------------------------------------------------------
# -- 3. CREACION DE SUBNETS PUBLICAS (2 AZs para alta disponibilidad)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${var.availability_zones[count.index]}"
  }
}

# --- Public Route Table (IGW with VPC) ---
# --- Tabla de rutas pública para que salgan las subnets publicas a internet por el IGW---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# --- Public Route Table Associations (one per public subnet) ---
# --- Asociaciones de la tabla de rutas pública (una por subred pública) ---
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -------------------------------------------------------------------

# -- 4. CREACION DE SUBNETS PRIVADAS PARA APPS/DATABASES
# Subnets Privadas (Aisladas, donde vivirá la Base de Datos)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-db-${var.availability_zones[count.index]}"
  }
}

# -------------------------------------------------------

# --- 5. BASE DE DATOS: RDS POSTGRESQL ---

# Security Group para la BD (Solo acepta tráfico interno de la red en puerto 5432)
resource "aws_security_group" "rds_postgres_sg" {
  name        = "${var.project_name}-rds-postgres-sg"
  description = "Permite trafico exclusivo en puerto 5432 dentro de la VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL desde la red interna"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    #cidr_blocks = [var.vpc_cidr]
    security_groups = [aws_security_group.bastion_sg.id] # <-- Permitimos explícitamente al Bastion
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-rds-postgresql"
  }
}

# DB Subnet Group (Agrupa todas las subnets privadas en una lista para Multi-AZ)
resource "aws_db_subnet_group" "rds_postgres_subnet_group" {
  name       = "${var.project_name}-postgres-subnet-group"
  subnet_ids = aws_subnet.private[*].id # Pasamos la lista completa de IDs de subnets privadas

  tags = {
    Name = "${var.project_name}-dbsubnet-postgres-group"
  }
}


# Instancia RDS PostgreSQL Multi-AZ
resource "aws_db_instance" "postgres_instance" {
  identifier        = "${var.project_name}-postgres-prod"
  engine            = "postgres"
  engine_version    = "15.19"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "empresa_db"
  username = var.db_username                    # <--- Usando variable sensible
  password = random_password.db_password.result # var.db_password # <--- Usando variable sensible (terraform.tfvars)

  db_subnet_group_name   = aws_db_subnet_group.rds_postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]

  multi_az            = true  # Alta disponibilidad real en 2 zonas
  publicly_accessible = false # ¡Aislada en subnets privadas!
  skip_final_snapshot = true  # Facilita destruir el laboratorio

  backup_retention_period = 1

  tags = {
    Environment = var.environment
    Engine      = "PostgreSQL"
  }
}

# Generador automático de contraseña segura para la bd
resource "random_password" "db_password" {
  length  = 16
  special = false # A veces los caracteres especiales dan problemas en algunas cadenas de conexión
}

# Crear el secreto en AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${var.project_name}-db-credentials"
  description = "Credenciales de acceso para la base de datos PostgreSQL"
}

# Guardar los valores (usuario y contraseña) dentro del secreto
resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result # si no quieres una randome hay que usar terraform.tfvars
    engine   = "postgres"
    host     = aws_db_instance.postgres_instance.address
    port     = aws_db_instance.postgres_instance.port
    dbname   = "empresa_db"
  })
}


# --- 6. BASTION HOST (Servidor de salto en subnet pública) ---

# Par de claves SSH para acceder al Bastion Host
resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = file("~/.ssh/id_ed25519_bastionhost.pub") # Lee el nuevo archivo público que acabamos de crear
}

# Security Group para el Bastion Host (Permite SSH desde internet)
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "Permite acceso SSH publico al servidor de salto"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH desde cualquier lugar (en prod acotar a IP corporativa)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-bastion-sg" }
}

# Instancia EC2 del Bastion Host en la Subnet Pública
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id # Amazon Linux 2023 (o Ubuntu recente en eu-west-1)
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id # En la primera subnet pública
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "${var.project_name}-bastion-host"
  }
}