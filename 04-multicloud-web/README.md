# 04 - Web multi-cloud (AWS + Azure) 

Un `terraform apply` publica **la misma página** en las dos nubes. Lo que las une es un ID generado por Terraform: sale en los nombres de los recursos y en el HTML. Si abres las dos URLs, el ID tiene que coincidir.

```text
                 terraform apply
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
     AWS S3                    Azure Blob
   (aws.tf)                    (azure.tf)
          │                         │
          └────────────┬────────────┘
                       ▼
              mismo HTML + mismo ID
```

Hace falta `aws configure` y `az login`. El `azure_subscription_id` no tiene valor por defecto: si no hay `terraform.tfvars`, Terraform te lo pedirá (`az account show --query id -o tsv`). `terraform.tfvars.example` es solo una plantilla; Terraform no la lee.

```bash
cd 04-multicloud-web
terraform init       # descarga providers de AWS y Azure
terraform fmt
terraform validate
terraform plan       # el primero puede tardar ~1 min SIN texto: el provider de Azure es grande
terraform apply
```

Comprueba las dos nubes:

```bash
terraform output deployment_id
terraform output aws_url
terraform output azure_url

curl "$(terraform output -raw aws_url)"
curl "$(terraform output -raw azure_url)"
```

Al terminar:

```bash
terraform destroy
```

S3 + Storage LRS con un HTML: coste despreciable. Destruye al acabar.

## Conceptos aprendidos

- Dos providers en un mismo proyecto (`aws` y `azurerm`)
- Un `random_id` compartido como nexo entre nubes
- `templatefile` para generar un HTML y subirlo dos veces
- AWS S3 vs Azure Storage Account + Resource Group
