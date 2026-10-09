# -----------------------------------------------------------------------------
# AWS: el mismo HTML en un bucket S3 público de lectura.
# Usamos la URL REST (https://bucket.s3.region.amazonaws.com/index.html)
# porque el website endpoint de S3 no tiene HTTPS.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "web" {
  bucket        = "${var.project_name}-${local.suffix}"
  force_destroy = true

  tags = {
    Name         = "${var.project_name}-aws"
    Cloud        = "aws"
    DeploymentId = local.suffix
  }
}

resource "aws_s3_bucket_ownership_controls" "web" {
  bucket = aws_s3_bucket.web.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "web" {
  bucket     = aws_s3_bucket.web.id
  depends_on = [aws_s3_bucket_public_access_block.web]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadIndex"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.web.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.web.id
  key          = "index.html"
  content      = local.index_html
  content_type = "text/html"
  etag         = md5(local.index_html)
}
