# -----------------------------------------------------------------------------
# Nombre único del bucket
# En S3 el nombre es global a toda AWS, no solo a tu cuenta. Si 20 alumnos
# intentan crear "mi-web", 19 fallarán. Un sufijo aleatorio evita ese problema
# en clase, y enseña que algunos identificadores de AWS tienen reglas especiales.
# -----------------------------------------------------------------------------

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# -----------------------------------------------------------------------------
# Bucket S3
# El bucket es el contenedor de objetos (archivos). Este resource crea el
# "recipiente"; el contenido y las reglas de acceso van en resources aparte.
# AWS descompuso la configuración de S3 en varios recursos a propósito:
# cada uno gestiona una preocupación distinta (hosting, política, objetos...).
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "website" {
  # Concatenamos prefijo (variable) + sufijo (resource). Esta expresión es
  # otra referencia entre elementos de Terraform.
  bucket = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"

  # En un laboratorio queremos poder destruir el bucket aunque tenga archivos.
  # Sin force_destroy, terraform destroy fallaría porque el bucket no está vacío.
  # En producción se suele dejar en false para no borrar datos por accidente.
  force_destroy = true

  tags = {
    Name = "${var.bucket_prefix}-website"
  }
}

# Desactivamos ACLs. BucketOwnerEnforced es el modelo actual recomendado:
# el dueño del bucket es dueño de todos los objetos y el acceso se controla
# solo con bucket policies (no con ACLs heredadas).
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# -----------------------------------------------------------------------------
# Hosting web estático
# Este resource le indica a S3 qué archivo servir cuando alguien visita la
# raíz del website endpoint (por ejemplo / → index.html).
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = var.index_document
  }
}

# -----------------------------------------------------------------------------
# Acceso público
#
# IMPORTANTE (seguridad):
# El hosting web clásico de S3 exige que el bucket sea legible desde Internet.
# Eso implica relajar Block Public Access y publicar una bucket policy de
# s3:GetObject. AWS ya NO recomienda este patrón en producción.
#
# Por qué lo usamos en el laboratorio:
# - Es el ejemplo más simple para entender S3, policies y aws_s3_object.
# - terraform apply termina en segundos (CloudFront tarda 10-20 minutos).
# - El coste es prácticamente cero.
#
# Qué harías en un proyecto real:
# - Bucket privado (Block Public Access activado).
# - CloudFront delante, con Origin Access Control (OAC).
# - HTTPS en el borde y el bucket inaccesible de forma directa.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  # Mantenemos las ACLs bloqueadas (no las necesitamos).
  block_public_acls  = true
  ignore_public_acls = true
  # Permitimos una bucket policy pública de solo lectura, imprescindible
  # para el website endpoint clásico de S3.
  block_public_policy     = false
  restrict_public_buckets = false
}

# La bucket policy es un documento IAM en JSON asociado al bucket.
# Aquí concedemos s3:GetObject a cualquiera (Principal "*"), pero solo
# lectura: nadie de fuera puede escribir ni borrar objetos.
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  # depends_on hace explícita una dependencia que, si no, podría quedar
  # oculta: AWS rechaza una policy pública hasta que el Public Access Block
  # permita políticas públicas. Terraform necesita aplicar ese cambio primero.
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicReadForWebsite"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Subida del HTML
# aws_s3_object copia un archivo local al bucket. Terraform no "ejecuta el
# sitio web": solo sube el objeto y deja que S3 lo sirva.
# -----------------------------------------------------------------------------

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = var.index_document
  source       = "${path.module}/www/${var.index_document}"
  content_type = "text/html"

  # etag con el MD5 del archivo: si cambias index.html, Terraform detecta
  # el cambio y vuelve a subir el objeto en el siguiente apply.
  etag = filemd5("${path.module}/www/${var.index_document}")
}
