# 01 - Instancia EC2 básica

Crea una EC2 `t3.micro` con Amazon Linux 2023 (AMI vía data source), un Security Group (SSH + HTTP) y un `user_data` que instala nginx.

Región: `eu-west-1`. Necesitas una VPC por defecto. Si no existe: `aws ec2 create-default-vpc --region eu-west-1`.

```bash
cd 01-ec2-basic
terraform init       # descarga el provider de AWS
terraform fmt        # formatea el código
terraform validate   # comprueba que la sintaxis es correcta
terraform plan       # muestra qué se va a crear, sin crear nada
terraform apply      # crea la infraestructura en AWS
```

Comprueba la web (espera 1-2 minutos a que nginx termine de instalarse):

```bash
terraform output website_url
curl "$(terraform output -raw website_url)"
```

Para actualizar algo ya desplegado, cambia el código y vuelve a aplicar:

```bash
terraform plan    # verá el diff respecto a lo que ya existe
terraform apply   # aplica solo los cambios
```

Al terminar:

```bash
terraform destroy
```

`t3.micro` suele entrar en Free Tier. Si se deja encendida, cobra por hora.

## Conceptos aprendidos

- Provider de AWS
- Resources y data sources
- Variables, outputs y tags
- Referencias (`data.aws_ami.amazon_linux.id`)
