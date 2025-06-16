# La convención de nombres se aplica en los valores 'default' de las variables.
# Formato: ch (Chile) + i2 (Pre-producción) + zb1 (Brazil South) + XXX (Tipo) + openfc (Proyecto) + crit001 (Criticidad)

variable "resource_group_name" {
  description = "Nombre del grupo de recursos principal donde se desplegará el AKS."
  type        = string
  # rsg = resource group
  default     = "chi2zb1rsgopenfccrit001"
}

variable "network_resource_group_name" {
  description = "Nombre del grupo de recursos donde reside la VNet."
  type        = string
  # Asumiendo un RG separado para la red
  default     = "chi2zb1rsgopenfcnetcrit001"
}

variable "dns_resource_group_name" {
  description = "Nombre del grupo de recursos donde reside la Zona DNS Privada."
  type        = string
  # Asumiendo un RG separado para DNS
  default     = "chi2zb1rsgopenfcdnscrit001"
}

variable "cluster_name" {
  description = "Nombre del clúster de AKS."
  type        = string
  # aks = cluster aks
  default     = "chi2zb1aksopenfccrit001"
}

variable "vnet_name" {
  description = "Nombre de la VNet existente."
  type        = string
  # vnt = virtual network
  default     = "chi2zb1vntopenfccrit001"
}

variable "subnet_name" {
  description = "Nombre de la Subnet existente para el AKS."
  type        = string
  # No se proveyó un código para 'subnet', se usa un nombre descriptivo.
  default     = "snet-chi2zb1aksopenfccrit001"
}

variable "private_dns_zone_name" {
  description = "Nombre de la Zona DNS Privada existente."
  type        = string
  # Este nombre está definido por Azure y no sigue la convención interna.
  default     = "privatelink.brazilsouth.azmk8s.io"
}

variable "key_vault_name" {
  description = "Nombre del Key Vault existente. Debe ser globalmente único."
  type        = string
  # No se proveyó un código para 'key vault', se usa un nombre descriptivo.
  # NOTA: Este nombre debe ser único a nivel mundial.
  default     = "kv-chi2zb1openfccrit001"
}

variable "log_analytics_workspace_name" {
  description = "Nombre del Log Analytics Workspace existente."
  type        = string
  # lwk = log analytics workspace
  default     = "chi2zb1lwkopenfccrit001"
}

variable "aks_admin_group_id" {
  description = "Object ID del grupo de Azure AD para los administradores de AKS."
  type        = string
}

# === Variables de Gobierno para 'Open Finance' (sin cambios en su valor) ===
variable "product" {
  type        = string
  description = "Etiqueta 'product' para gobierno."
  default     = "Open Finance"
}

variable "cost_center" {
  type        = string
  description = "Etiqueta 'cost_center' para gobierno."
  default     = "OF-2025-PRE"
}

variable "apm_functional" {
  type        = string
  description = "Etiqueta 'apm_functional' para gobierno."
  default     = "open-finance-backend"
}

variable "cia" {
  type        = string
  description = "Etiqueta 'cia' para gobierno (Confidencialidad, Integridad, Disponibilidad)."
  default     = "C3-I3-A3"
}