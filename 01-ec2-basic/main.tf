# -----------------------------------------------------------------------------
# Data sources
# Un data source NO crea infraestructura: consulta información que ya existe
# en AWS. Terraform puede usarla después al crear resources.
# -----------------------------------------------------------------------------

# Buscamos automáticamente la AMI más reciente de Amazon Linux 2023.
# Utilizar un data source evita escribir a mano un ami-xxxxxxxx, porque esos
# identificadores cambian según la región y se publican AMIs nuevas con el tiempo.
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

# Recuperamos la VPC por defecto de la cuenta en esta región.
# Así no hace falta crear una red nueva: el laboratorio se centra en EC2.
# Si este data source falla, la cuenta no tiene VPC por defecto.
# En ese caso puede crearse con: aws ec2 create-default-vpc
data "aws_vpc" "default" {
  default = true
}

# -----------------------------------------------------------------------------
# Security Group
# En AWS, un Security Group es el firewall de la instancia: decide qué tráfico
# entra (ingress) y sale (egress).
# -----------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name_prefix = "${var.instance_name}-sg-"
  description = "Security Group del laboratorio 01-ec2-basic"
  vpc_id      = data.aws_vpc.default.id

  # Permitimos SSH para que el alumno pueda conectarse si tiene un Key Pair.
  # El origen se configura con una variable para poder restringirlo.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  # Puerto 80: el user_data arranca nginx y sirve una página en la IP pública.
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "${var.instance_name}-sg"
  }
}

# -----------------------------------------------------------------------------
# Instancia EC2
# Este resource SÍ crea infraestructura: una máquina virtual en AWS.
# Observa las referencias: Terraform sustituye automáticamente los valores
# de otros bloques (data sources, variables y resources) cuando aplica.
# -----------------------------------------------------------------------------

resource "aws_instance" "lab" {
  # Referencia al data source: usamos el ID de la AMI que Terraform acaba de
  # descubrir en AWS. No hace falta copiarlo a mano.
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Referencia a otro resource: el Security Group creado más arriba.
  # Terraform entiende que la instancia depende del SG y lo crea primero.
  vpc_security_group_ids = [aws_security_group.instance.id]

  # Key Pair opcional. Si la variable es null, no se asocia ninguna clave.
  key_name = var.key_pair_name

  # En la VPC por defecto las subnets públicas asignan IP pública al arrancar.
  # La pedimos de forma explícita para poder mostrar la IP en los outputs.
  associate_public_ip_address = true

  # IMDSv2 es la forma recomendada de consultar metadatos de la instancia.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # user_data es un script que AWS ejecuta en el PRIMER arranque.
  # Aquí instalamos nginx y dejamos una página HTML para poder abrir
  # http://<IP_PUBLICA> en el navegador y ver que la instancia responde.
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html lang="es">
      <head>
        <meta charset="utf-8" />
        <title>Laboratorio Terraform EC2</title>
      </head>
      <body>
        <h1>Hola Miguel Amorós Moret</h1>
        <p>Si ves esta página, la instancia, el Security Group y el user_data funcionan.</p>
      </body>
    </html>
    HTML
    systemctl enable --now nginx
  EOF

  # Si cambias el user_data, Terraform recreará la instancia. Sin esto,
  # AWS no vuelve a ejecutar el script en una máquina que ya existe.
  user_data_replace_on_change = true

  tags = {
    Name = var.instance_name
  }
}

