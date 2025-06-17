output "akv_name" {
  description = "The name of Key Vault"
  value       = azurerm_key_vault.akv_sa.name
}

output "akv_id" {
  description = "The ID of Key Vault"
  value       = azurerm_key_vault.akv_sa.id
}