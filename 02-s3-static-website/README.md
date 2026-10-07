# 02 - Sitio estático en S3

Crea un bucket, sube `www/index.html` y lo publica como web. Varios resources colaboran sobre el mismo bucket. Región: `eu-west-1`.

El website endpoint de S3 es público y **solo HTTP**. Chrome a menudo fuerza HTTPS y muestra que el sitio no admite una conexión segura. En el navegador usa la URL REST con HTTPS (`website_https_url`). En producción se pondría CloudFront delante.

```bash
cd 02-s3-static-website
terraform init       # descarga el provider de AWS
terraform fmt        # formatea el código
terraform validate   # comprueba que la sintaxis es correcta
terraform plan       # muestra qué se va a crear, sin crear nada
terraform apply      # crea la infraestructura en AWS
```

Abre la web:

```bash
terraform output website_https_url
# pega esa URL en el navegador (https://...s3.us-east-1.amazonaws.com/index.html)

curl "$(terraform output -raw website_https_url)"
```

Al terminar:

```bash
terraform destroy
```

Un HTML de pocos KB no genera coste apreciable.

## Conceptos aprendidos

- Varios resources relacionados (bucket, policy, objeto)
- Subida de archivos con `aws_s3_object`
- Variables y outputs
- Acceso público de S3 y por qué no usarlo en producción
