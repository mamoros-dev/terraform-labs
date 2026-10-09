variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "lab06-workspaces"
}

# --- MAPA DE INSTANCIAS POR ENTORNO ---
variable "instance_type_map" {
  description = "Tipo de instancia EC2 según el workspace"
  type        = map(string)
  default = {
    default = "t3.micro"
    dev     = "t3.micro"
    prod    = "t3.small"
  }
}

# --- MAPA DE CIDRS DE VPC POR ENTORNO ---
variable "vpc_cidr_map" {
  description = "Bloque CIDR de la VPC según el workspace"
  type        = map(string)
  default = {
    default = "10.0.0.0/16"
    dev     = "10.10.0.0/16"
    prod    = "10.20.0.0/16"
  }
}

# --- MAPA DE SUBREDES MULTI-AZ (Para for_each) ---
variable "subnet_cidrs" {
  description = "Subredes a crear por Zona de Disponibilidad"
  type        = map(string)
  default = {
    "subnet-a" = "10.0.1.0/24"
    "subnet-b" = "10.0.2.0/24"
  }
}
