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

# --- 5. BASE DE DATOS: RDS MYSQL ---

# Security Group para la BD (Solo acepta tráfico interno de la red en puerto 5432)
resource "aws_security_group" "rds_mysql_sg" {
  name        = "${var.project_name}-mysql-sg"
  description = "Permite trafico MySQL solo desde el Bastion Host"
  vpc_id      = aws_vpc.main.id

  # Permitir puerto 3306 (MySQL) exclusivamente desde el Security Group del Bastion
  ingress {
    description     = "MySQL desde el Bastion Host"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-mysql-sg" }
}

# DB Subnet Group (Agrupa todas las subnets privadas en una lista para Multi-AZ)
resource "aws_db_subnet_group" "rds_mysql_subnet_group" {
  name        = "${var.project_name}-mysql-subnet-group"
  subnet_ids  = aws_subnet.private[*].id # Utiliza tus subnets privadas existentes
  description = "Grupo de subnets privadas para la base de datos MySQL"

  tags = { Name = "${var.project_name}-mysql-subnet-group" }
}


# Instancia RDS MySQL Multi-AZ
resource "aws_db_instance" "mysql_instance" {
  identifier        = "${var.project_name}-mysql-prod"
  engine            = "mysql"
  engine_version    = "8.0" # Versión estándar y robusta de MySQL
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "empresa_mysql_db"
  username = var.db_username
  password = random_password.db_password.result # var.db_password # O enlazado a una variable sensible

  db_subnet_group_name   = aws_db_subnet_group.rds_mysql_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]

  multi_az            = false  # Alta disponibilidad en 2 zonas
  publicly_accessible = false # ¡Aislada en subnet privada!
  skip_final_snapshot = true  # Facilita destruir el lab

  backup_retention_period = 1 # Obligatorio para permitir réplicas de lectura

  tags = {
    Environment = var.environment
    Engine      = "MySQL"
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
    host     = aws_db_instance.mysql_instance.address
    port     = aws_db_instance.mysql_instance.port
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

## --- 7. CREAR READ REPLICA ---
# --- RÉPLICA DE LECTURA DE MYSQL ---
resource "aws_db_instance" "mysql_read_replica" {
  identifier             = "${var.project_name}-mysql-read-replica"
  replicate_source_db    = aws_db_instance.mysql_instance.identifier
  
  # Una réplica hereda por defecto la clase de instancia y motor del origen, 
  # pero podemos especificar opciones de almacenamiento o clase si lo deseamos.
  instance_class         = "db.t3.micro"
  storage_type           = "gp3"
  
  # Las réplicas de lectura van por defecto fuera de la VPC principal o en subnets, 
  # pero heredan la red y el security group de manera lógica.
  publicly_accessible    = false
  skip_final_snapshot    = true

  # --- AÑADE ESTA LÍNEA AQUÍ ---
  # Fuerza a Terraform a esperar a que la instancia principal esté modificada por completo
  depends_on = [aws_db_instance.mysql_instance]

  tags = {
    Environment = var.environment
    Role        = "Read-Replica"
  }
}