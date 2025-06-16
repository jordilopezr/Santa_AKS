# terraform.tfvars
# Contiene los valores de los recursos que acabamos de crear.

# Nombres de los recursos de prerrequisito
resource_group_name           = "chi2zb1rsgopenfccrit001"
network_resource_group_name   = "chi2zb1rsgopenfcnetcrit001"
dns_resource_group_name       = "chi2zb1rsgopenfcdnscrit001"
vnet_name                     = "chi2zb1vntopenfccrit001"
subnet_name                   = "snet-chi2zb1aksopenfc"
private_dns_zone_name         = "privatelink.brazilsouth.azmk8s.io"
log_analytics_workspace_name  = "chi2zb1lwkopenfccrit001"
key_vault_name                = "kv-chi2zb1openfccrit001"

# --- ¡ACCIÓN MANUAL REQUERIDA! ---
# Debes obtener este valor de Azure AD y pegarlo aquí.
aks_admin_group_id = "24d56489-7549-4628-be7c-950fda1f6797"

# --- Variables de Gobierno (puedes dejarlas como están si los valores por defecto en variables.tf son correctos) ---
# product        = "Open Finance"
# cost_center    = "OF-2025-DEV"
# apm_functional = "open-finance-backend"
# cia            = "C3-I3-A3"