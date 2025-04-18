resource "azurerm_resource_group" "main" {
  name     = "rg-storage"
  location = "uksouth"
}

resource "azurerm_storage_account" "site_storage_account" {
  name                     = "stdfwlandingstorage"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "site_settings" {
  storage_account_id = azurerm_storage_account.site_storage_account.id
  index_document     = "index.html"
}

resource "azurerm_role_assignment" "spn_blob_storage_contributor" {
  scope                = azurerm_storage_account.site_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.spn.object_id
}
