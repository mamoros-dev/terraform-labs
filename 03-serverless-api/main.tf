# =============================================================================
# Laboratorio 03: API Gateway HTTP API → Lambda → CloudWatch Logs
#
# Lee este archivo de arriba a abajo. El orden de los resources coincide con
# las dependencias reales:
#
#   IAM Role → IAM Policy → Lambda → API Gateway → permiso de invocación
#                   │
#                   └── CloudWatch Logs (la policy solo deja escribir aquí)
#
# Terraform no necesita que estén en este orden: resuelve las referencias solo.
# Las ponemos así para que el alumno vea el grafo mientras lee el código.
# =============================================================================

# -----------------------------------------------------------------------------
# 1) CloudWatch Log Group
# Lambda escribe stdout/stderr (y lo que mandes con logging) a CloudWatch.
# Si no creamos el grupo, Lambda intentaría crearlo al ejecutarse, y para eso
# harían falta más permisos IAM. Al crearlo en Terraform:
#   - controlamos la retención (7 días) y por tanto el coste.
#   - la policy IAM puede limitarse a ESTE log group (mínimo privilegio).
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "hello" {
  # Convención de Lambda: /aws/lambda/<nombre-de-la-función>
  name              = "/aws/lambda/${var.project_name}-hello"
  retention_in_days = var.log_retention_days
}

# -----------------------------------------------------------------------------
# 2) IAM Role que Lambda va a "ponerse"
#
# En AWS, una función Lambda no usa tu usuario. Asume un ROL.
# El trust policy (quién puede asumir el rol) va en assume_role_policy.
# Los permisos (qué puede hacer una vez asumido) van en la IAM Policy.
#
# Relación que estamos enseñando:
#
#   Lambda
#     │  role = aws_iam_role.hello.arn
#     ▼
#   IAM Role
#     │  aws_iam_role_policy_attachment
#     ▼
#   IAM Policy  (solo logs de este Log Group)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  # Data source: no crea nada. Construye el JSON del trust policy.
  # lambda.amazonaws.com es el único principal que puede asumir este rol.
  statement {
    sid     = "AllowLambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hello" {
  name               = "${var.project_name}-hello-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Permisos de la función: escribir streams y eventos de log, y nada más.
# No incluimos logs:CreateLogGroup porque el grupo ya existe (lo crea Terraform).
# Resource está restringido al ARN de NUESTRO log group, no a todos los logs
# de la cuenta. Eso es el principio de mínimo privilegio.
data "aws_iam_policy_document" "lambda_logs" {
  statement {
    sid    = "AllowWriteToOwnLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    # El ARN del log group termina en el nombre del grupo. Los streams cuelgan
    # de él, por eso el resource es "<arn-del-grupo>:*".
    # Terraform ya conoce ese ARN porque el log group se declara en este mismo
    # proyecto: no hay que copiarlo a mano.
    resources = ["${aws_cloudwatch_log_group.hello.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_logs" {
  name        = "${var.project_name}-hello-logs"
  description = "Permite a la función hello escribir únicamente en su Log Group."
  policy      = data.aws_iam_policy_document.lambda_logs.json
}

# El attachment es el "pegamento": une la policy al role.
# Sin este resource, el role existiría pero no tendría permisos.
resource "aws_iam_role_policy_attachment" "hello_logs" {
  role       = aws_iam_role.hello.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

# -----------------------------------------------------------------------------
# 3) Código de Lambda
# data.archive_file empaqueta src/hello.py en un ZIP. Es otro data source:
# trabaja en local, no llama a AWS.
# -----------------------------------------------------------------------------

data "archive_file" "hello" {
  type        = "zip"
  source_file = "${path.module}/src/hello.py"
  output_path = "${path.module}/src/hello.zip"
}

resource "aws_lambda_function" "hello" {
  function_name = "${var.project_name}-hello"
  description   = "Devuelve un JSON de saludo. Invocada por API Gateway."

  filename         = data.archive_file.hello.output_path
  source_code_hash = data.archive_file.hello.output_base64sha256

  # handler = "archivo.funcion". El archivo es hello.py, la función es handler.
  handler = "hello.handler"
  runtime = "python3.12"

  # Referencia clave: Lambda necesita el ARN del role, no su nombre.
  # aws_iam_role.hello.arn significa:
  #   "del resource aws_iam_role llamado hello, toma el atributo arn".
  # Terraform conoce ese ARN porque él mismo va a crear el role. No hay que
  # esperar a que AWS lo muestre en la consola ni pegarlo como texto.
  role = aws_iam_role.hello.arn

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  # Enlazamos la función con el Log Group que hemos creado. Así CloudWatch
  # no usa un grupo distinto al que autoriza la IAM Policy.
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.hello.name
  }

  # Lambda no puede arrancar hasta que el role tenga la policy pegada.
  # El role = ... ya crea una dependencia con el role, pero no con el
  # attachment. depends_on evita una condición de carrera en el primer apply.
  depends_on = [aws_iam_role_policy_attachment.hello_logs]
}

# -----------------------------------------------------------------------------
# 4) API Gateway HTTP API
#
# Usamos HTTP API (apigatewayv2), no REST API. HTTP API es más simple y más
# barata, y basta para un GET /hello.
#
# Relación:
#
#   Cliente HTTP
#        │
#        ▼
#   API Gateway  (ruta GET /hello)
#        │  integration (AWS_PROXY)
#        ▼
#   Lambda
#        │  logging_config
#        ▼
#   CloudWatch Logs
# -----------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "hello" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
  description   = "HTTP API del laboratorio 03: un único GET /hello."
}

# El stage $default publica la API en la raíz de la URL, sin prefijo /prod.
# auto_deploy = true aplica cada cambio de ruta/integración sin un "deploy" extra.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.hello.id
  name        = "$default"
  auto_deploy = true
}

# La integración dice: "cuando entre una petición, invoca esta Lambda".
# integration_uri usa invoke_arn (no el ARN normal de la función).
# invoke_arn es el ARN específico para que otro servicio dispare la función.
resource "aws_apigatewayv2_integration" "hello" {
  api_id                 = aws_apigatewayv2_api.hello.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello.invoke_arn
  payload_format_version = "2.0"
}

# La ruta enlaza el método HTTP y el path con la integración anterior.
# target tiene el formato fijo integrations/<id>.
resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.hello.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello.id}"
}

# -----------------------------------------------------------------------------
# 5) Permiso para que API Gateway invoque Lambda
#
# IAM del role autoriza a Lambda a escribir logs.
# ESTE resource autoriza a API Gateway a llamar a Lambda.
# Son dos permisos distintos, sobre dos relaciones distintas.
#
# source_arn limita el permiso a GET /hello de ESTA API, no a cualquier API
# de la cuenta. Mínimo privilegio otra vez.
# -----------------------------------------------------------------------------

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id = "AllowAPIGatewayInvokeHello"
  action       = "lambda:InvokeFunction"
  principal    = "apigateway.amazonaws.com"

  # function_name acepta nombre, ARN o alias. Usamos el atributo de la función
  # creada arriba para no hardcodear el nombre.
  function_name = aws_lambda_function.hello.function_name

  # execution_arn identifica la API a efectos de invocación.
  # El sufijo /*/GET/hello = cualquier stage, método GET, path hello.
  source_arn = "${aws_apigatewayv2_api.hello.execution_arn}/*/GET/hello"
}
