# --- Este archivo define la configuración del backend para Terraform. 
# Especifica que el estado de la infraestructura administrada por Terraform se almacenará en un bucket de S3 llamado "miguel-terraform-state-proyecto2" en la región "eu-west-1". 
# El archivo de estado se almacenará en la clave "proyecto5/terraform.tfstate". La configuración también habilita el bloqueo del estado para evitar modificaciones concurrentes 
# y cifra el archivo de estado para mayor seguridad.

terraform {
  backend "s3" {
    bucket       = "miguel-labs-terraform-state" # Asegúrate de que este bucket exista en tu cuenta de AWS
    key          = "lab-05/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true # locking en el mismo bucket S3
    # dynamodb_table = "miguel-labs-terraform-locks" # locking en DynamoDB
    encrypt = true
  }
}
