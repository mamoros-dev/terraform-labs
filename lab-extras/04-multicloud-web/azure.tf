# -----------------------------------------------------------------------------
# Azure: el mismo HTML en un Storage Account con static website.
# El Resource Group es el "carpeta" de Azure: agrupa estos recursos.
# El endpoint *.web.core.windows.net sí sirve HTTPS.
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "web" {
  name     = "rg-${var.project_name}-${local.suffix}"
  location = var.azure_location
  tags     = merge(local.common_tags, { Cloud = "azure", DeploymentId = local.suffix })
}

resource "azurerm_storage_account" "web" {
  # Solo minúsculas y números, 3-24 caracteres, único en toda Azure.
  name                     = "st${var.project_name}${local.suffix}"
  resource_group_name      = azurerm_resource_group.web.name
  location                 = azurerm_resource_group.web.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(local.common_tags, { Cloud = "azure", DeploymentId = local.suffix })
}

# Activa el contenedor especial $web y la página de índice.
resource "azurerm_storage_account_static_website" "web" {
  storage_account_id = azurerm_storage_account.web.id
  index_document     = "index.html"
}

# $web lo crea Azure al activar static website; lo leemos para subir el HTML.
data "azurerm_storage_container" "web" {
  name               = "$web"
  storage_account_id = azurerm_storage_account.web.id

  depends_on = [azurerm_storage_account_static_website.web]
}

resource "azurerm_storage_blob" "index" {
  name                 = "index.html"
  storage_container_id = data.azurerm_storage_container.web.id
  type                 = "Block"
  content_type         = "text/html"
  source_content       = local.index_html
}
