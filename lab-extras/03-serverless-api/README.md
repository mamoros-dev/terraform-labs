# 03 - API HTTP serverless

Despliega `GET /hello` en `eu-west-1` con esta cadena:

```text
API Gateway HTTP API → Lambda (Python) → CloudWatch Logs
```

Lambda asume un IAM Role; el role solo puede escribir en su Log Group.

```text
Lambda → IAM Role → IAM Policy
```

```bash
cd 03-serverless-api
terraform init       # descarga el provider de AWS
terraform fmt        # formatea el código
terraform validate   # comprueba que la sintaxis es correcta
terraform plan       # muestra qué se va a crear, sin crear nada
terraform apply      # crea la infraestructura en AWS
```

Prueba la API:

```bash
curl "$(terraform output -raw hello_url)"
```

Debe devolver `{"message": "Hello from Terraform and AWS Lambda!"}`.

Al terminar:

```bash
terraform destroy
```

Unas pocas invocaciones entran en Free Tier. No dejes la API sin destruir.

## Conceptos aprendidos

- Cómo Terraform conecta varios servicios de AWS
- Referencias a ARNs (`aws_lambda_function.hello.invoke_arn`)
- IAM de mínimo privilegio
- HTTP API + Lambda + logs
