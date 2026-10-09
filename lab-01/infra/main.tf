# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Esto garantiza que las instancias EC2 reciban nombres de dominio DNS públicos/privados
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab01-vpc"
  }
}

# --- Public Subnets (one per AZ) ---
# --- Subredes públicas (una por AZ) ---
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # recibe automaticamente una ip publica

  tags = {
    Name = "lab01-public-${var.availability_zones[count.index]}"
  }
}

# --- Private Subnets (one per AZ) ---
# --- Subredes privadas (una por AZ) ---
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "lab01-private-${var.availability_zones[count.index]}"
  }
}

# --- Internet Gateway --- para la salida a internet de la VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "lab01-igw"
  }
}

# --- Elastic IP for the NAT Gateway ---
# --- Elastic IP para la NAT Gateway ---
# Para que un NAT Gateway traduzca el tráfico privado hacia Internet, AWS exige que tenga asignada una IP pública estática (Elastic IP).
# resource "aws_eip" "nat1" {
#   domain = "vpc"

#   tags = {
#     Name = "lab01-nat-eip-a"
#   }
# }
# resource "aws_eip" "nat2" {
#   domain = "vpc"

#   tags = {
#     Name = "lab01-nat-eip-b"
#   }
# }
# "Crea este recurso tantas veces como subredes públicas tengamos en la lista"
# se llama nat a esta eip porque su uso será para una nat
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs) # se ejecuta 2 veces, una por cada subred pública
  domain = "vpc"

  tags = {
    # var.availibility_zones[count.index]
    # var.availibility_zones[0] eu-west-1a
    # var.availibility_zones[1] eu-west-1b
    Name = "lab01-nat-eip-${var.availability_zones[count.index]}"
  }
}

# --- NAT Gateway (single por each public subnet) ---
# --- NAT Gateway (única por cada subred pública) ---
# resource "aws_nat_gateway" "nat1" {
#   allocation_id = aws_eip.nat1.id
#   subnet_id     = aws_subnet.public[0].id

#   tags = {
#     Name = "lab01-nat-a"
#   }

#   depends_on = [aws_internet_gateway.main]
# }

# resource "aws_nat_gateway" "nat2" {
#   allocation_id = aws_eip.nat2.id
#   subnet_id     = aws_subnet.public[1].id

#   tags = {
#     Name = "lab01-nat-b"
#   }

#   depends_on = [aws_internet_gateway.main]
# }

# Cada NAT Gateway necesita dos datos obligatorios para crearse:
# - allocation_id: La ID de la IP Elástica que acabamos de reservar.
# - subnet_id: La ID de la Subred Pública donde va a residir físicamente el NAT.
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)   # se ejecuta 2 veces, una por cada subred pública
  allocation_id = aws_eip.nat[count.index].id       # En la vuelta 0 coge aws_eip.nat[0], en la 1 coge aws_eip.nat[1]
  subnet_id     = aws_subnet.public[count.index].id # En la vuelta 0 coge public[0], en la 1 coge public[1]

  tags = {
    Name = "lab01-nat-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}


# --- Public Route Table ---
# --- Tabla de rutas pública ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "lab01-public-rt"
  }
}

# --- Public Route Table Associations (one per public subnet) ---
# --- Asociaciones de la tabla de rutas pública (una por subred pública) ---
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Private Route Table (one per public subnet) ---
# --- Tabla de rutas privada (una por subred pública) ---
# resource "aws_route_table" "private1" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat1.id
#   }

#   tags = {
#     Name = "lab01-private1-rt"
#   }
# }

# resource "aws_route_table" "private2" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat2.id
#   }

#   tags = {
#     Name = "lab01-private2-rt"
#   }
# }

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs) # se ejecuta 2 veces, una por cada subred privado
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "lab01-private-rt-${var.availability_zones[count.index]}"
  }
}

# --- Private Route Table Associations (one per app and db subnet) ---
# --- Asociaciones de la tabla de rutas privada (una por subred app y db)
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# --- Instancias EC2 ---

## Obtener la Amazon Linux 2023 AMI más reciente automáticamente:
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

## --- Security Groups ---
resource "aws_security_group" "lab_sg" {
  name        = "lab01-test-sg"
  description = "Allow SSH and ICMP/Ingress/Egress for lab tests"
  vpc_id      = aws_vpc.main.id

  # Regla 1: Entrada SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # O pones tu IP pública actual: "X.X.X.X/32"
  }

  # Regla 2: ICMP (Ping) interno desde la VPC
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Permitir todo el tráfico saliente a Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  Name = "lab01-test-sg"
  }
}

## EC2 PUBLICA
resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro" # O t2.micro según tu Free Tier
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "lab01-public-ec2"
  }
}

## EC2 PRIVADA
resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  # Adjuntamos el perfil SSM
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "lab01-private-ec2"
  }
}

# AÑADIMOS SSM A LA EC2 PRIVADA PARA PODER CONECTARNOS A ELLA DESDE LA EC2 PUBLICA
## Crea el IAM Role para SSM y adjúntalo a la EC2 Privada
resource "aws_iam_role" "ssm_role" {
  name = "lab01-ssm-role"

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

# Adjuntar la política oficial de SSM
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Perfil de instancia para asociar a la EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "lab01-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}