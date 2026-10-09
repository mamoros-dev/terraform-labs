variable "instance_name" {
  description = "Nombre que se asignará a la instancia EC2"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará el Security Group"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se ubicará la EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Entorno de despliegue (dev, stage, prod)"
  type        = string
  default     = "dev"
}
