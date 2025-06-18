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
  default     = "CLL"
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue (i2, p1, etc.)."
  default     = "i2"
}

variable "inherit" {
  type        = bool
  description = "Heredar configuraciones de un recurso existente."
  default     = true
}

variable "sequence_number" {
  type        = string
  description = "Número de secuencia para el nombre del recurso."
  default     = "001"
}
variable "app_acronym" {
  type        = string
  description = "Acrónimo de la aplicación."
  default     = "openfc"
}
variable "function_acronym" {
  type        = string
  description = "Acrónimo de la función del recurso."
  default     = "crit"
}
variable "entity" {
  type        = string
  description = "Entidad del recurso (por ejemplo, 'chl' para Chile)."
  default     = "chl"
}
variable "object_id" {
  type        = string
  description = "Object ID del recurso en Azure AD."
  default     = "f0422a6e-7801-4c39-87d3-bdb9ea0e80f9"
}
variable "location" {
  type        = string
  description = "Ubicación del recurso (por ejemplo, 'brazilsouth')."
  default     = "brazilsouth"
}

variable "analytics_diagnostic_monitor_lwk_id" {
  type        = string
  description = "ID del Log Analytics Workspace existente."
  default     = "/subscriptions/ef0a94be-5750-4ef8-944b-1bbc0cdda800/resourcegroups/chi2zb1rsgopenfccrit001/providers/microsoft.operationalinsights/workspaces/chi2zb1lwkopenfccrit001"
}
variable "analytics_diagnostic_monitor_name" {
  type        = string
  description = "Nombre del monitor de diagnóstico para AKS."
  default     = "chi2zb1aksopenfccrit001-dgm"
}
variable "analytics_diagnostic_monitor_description" {
  type        = string
  description = "Descripción del monitor de diagnóstico para AKS."
  default     = "Monitor de diagnóstico para AKS en el entorno Open Finance."
}
variable "analytics_diagnostic_monitor_location" {
  type        = string
  description = "Ubicación del monitor de diagnóstico para AKS."
  default     = "brazilsouth"
}
variable "analytics_diagnostic_monitor_tags" {
  type        = map(string)
  description = "Etiquetas para el monitor de diagnóstico de AKS."
  default     = {
    product         = "Open Finance"
    cost_center     = "OF-2025-PRE"
    apm_functional  = "open-finance-backend"
    cia             = "CLL"
    environment     = "i2"
    inherit         = "true"
    sequence_number = "001"
    app_acronym     = "openfc"
    function_acronym= "crit"
    entity          = "chl"
  }
}
variable "aks_name" {
  type        = string
  description = "Nombre del clúster AKS."
  default     = "chi2zb1aksopenfccrit001"
}
variable "private_dns_zone_rsg_name" {
  type        = string
  description = "Nombre del grupo de recursos donde se encuentra la zona DNS privada."
  default     = "chi2zb1rsgopenfcdnscrit001"
}

