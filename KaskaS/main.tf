# 1. CONFIGURACIÓN DEL PROVEEDOR Y TERRAFORM
# Basado en las versiones certificadas del README.md

terraform {
  required_version = ">= 1.7.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# 2. REFERENCIA A DEPENDENCIAS EXISTENTES
# El módulo curado requiere que estos recursos ya existan.
# Usamos "data sources" para obtener su información desde Azure.

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.network_resource_group_name
}

data "azurerm_private_dns_zone" "aks_dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = var.dns_resource_group_name
}

data "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.main.name // Asumimos que está en el mismo RG
}

data "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  resource_group_name = data.azurerm_resource_group.main.name // Asumimos que está en el mismo RG
}


# 3. LLAMADA AL MÓDULO CURADO DE AKS
# Este es el núcleo de nuestro código. Abstraemos toda la lógica.

module "aks" {
  # El 'source' apunta al repositorio del módulo.
  # En un entorno real, podría ser una URL a un registro privado de Terraform.
  # Esta ruta apunta al módulo AKS en GitHub
  source = "git::https://github.com/jordilopezr/Santa_AKS.git//AKS?ref=main"
  #version = "1.0.0" # IMPORTANTE: Debes usar la versión correcta del tag del módulo

  # ---- Variables Obligatorias del Módulo ----

  # Nombres y Ubicación
  rsg_name = data.azurerm_resource_group.main.name
  location = data.azurerm_resource_group.main.location
  aks_name = var.cluster_name

  # Dependencias de Redes y DNS
  private_dns_zone_rsg_name = data.azurerm_private_dns_zone.aks_dns_zone.resource_group_name
  private_dns_zone_name     = data.azurerm_private_dns_zone.aks_dns_zone.name
  
  default_node_pool = {
    subnet_id = data.azurerm_subnet.aks_subnet.id
    vm_size   = "Standard_A2_v2" # Puedes parametrizar esto con una variable
    min_count = 1
    max_count = 3
  }

  # Dependencias de Identidad y Servicios
  aks_admin_group_id       = var.aks_admin_group_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  key_vault_id             = data.azurerm_key_vault.main.id

  # Etiquetas de Gobierno y Metadatos (Obligatorias)
  product        = var.product
  cost_center    = var.cost_center
  apm_functional = var.apm_functional
  cia            = var.cia

  # ---- Variables Opcionales (Ejemplos) ----
  
  # Si quieres añadir más node pools, puedes hacerlo así:
  extra_node_pools = {
    app_pool = {
      subnet_id = data.azurerm_subnet.aks_subnet.id
      vm_size   = "Standard_D2s_v3"
      min_count = 1
      max_count = 5
      node_labels = {
        "pooltype" = "application"
      }
    }
  }

  tags = {
    environment = "development"
    owner       = "team-open-finance" # Actualizado
  }
}
https://github.com/jordilopezr/Santa_AKS/tree/4e7c045e6301c98b2e7031d0741538c1c27d5f38/tags

# 4. SALIDAS (OUTPUTS)
# Exponemos la información útil que nos devuelve el módulo.

output "aks_id" {
  value       = module.aks.aks_id
  description = "AKS resource ID"
}

output "aks_identity_id" {
  value       = module.aks.aks_identity_id
  description = "AKS identity ID"
}

output "aks_kube_config" {
  value       = module.aks.aks_kube_config
  description = "AKS kubeconfig"
  sensitive   = true
}