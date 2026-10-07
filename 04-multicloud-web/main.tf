# -----------------------------------------------------------------------------
# Lo que une a las dos nubes
#
# 1. Un random_id: el mismo sufijo entra en el bucket de AWS y en el storage
#    de Azure. En la consola se ve que son el mismo despliegue.
# 2. Un HTML generado con templatefile: la página muestra ese ID.
#    Si abres la URL de AWS y la de Azure, el ID coincide.
# 3. Tags comunes (Project, Environment). El ID del despliegue va en los nombres y en el HTML.
# -----------------------------------------------------------------------------

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  suffix = random_id.suffix.hex

  # Solo valores conocidos en el plan. Meter aquí el random_id hace fallar
  # a AWS: default_tags aparece vacío en el plan y completo en el apply
  # ("inconsistent final plan").
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Lab         = "04-multicloud-web"
  }

  # Un solo HTML para las dos nubes. Terraform lo rellena antes de subirlo.
  index_html = templatefile("${path.module}/www/index.html.tftpl", {
    owner  = var.owner_name
    suffix = local.suffix
  })
}
