# main.tf - Creación de Prerrequisitos para AKS

terraform {
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

# --- VARIABLES PARA PERSONALIZAR NOMBRES Y UBICACIÓN ---

variable "location" {
  description = "Región de Azure donde se desplegarán los recursos."
  type        = string
  default     = "brazilsouth"
}

variable "project_prefix" {
  description = "Prefijo basado en país, ambiente y zona (ej: chi2zb1)."
  type        = string
  default     = "chi2zb1"
}

variable "project_name" {
  description = "Nombre corto del proyecto (ej: openfc)."
  type        = string
  default     = "openfc"
}

variable "criticality" {
  description = "Nivel de criticidad del recurso (ej: crit001)."
  type        = string
  default     = "crit001"
}

# --- OBTENER DATOS DEL USUARIO ACTUAL PARA PERMISOS DE KEY VAULT ---

data "azurerm_client_config" "current" {}


# --- CREACIÓN DE GRUPOS DE RECURSOS ---

resource "azurerm_resource_group" "main" {
  name     = "${var.project_prefix}rsg${var.project_name}${var.criticality}"
  location = var.location
}

resource "azurerm_resource_group" "network" {
  name     = "${var.project_prefix}rsg${var.project_name}net${var.criticality}"
  location = var.location
}

resource "azurerm_resource_group" "dns" {
  name     = "${var.project_prefix}rsg${var.project_name}dns${var.criticality}"
  location = var.location
}


# --- CREACIÓN DE RECURSOS DE RED ---

resource "azurerm_virtual_network" "main" {
  name                = "${var.project_prefix}vnt${var.project_name}${var.criticality}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-${var.project_prefix}aks${var.project_name}"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}


# --- CREACIÓN DE ZONA DNS PRIVADA ---

resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.dns.name
}


# --- CREACIÓN DE LOG ANALYTICS Y KEY VAULT ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_prefix}lwk${var.project_name}${var.criticality}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project_prefix}${var.project_name}${var.criticality}" # kv- necesita ser único globalmente
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions    = ["Get", "List", "Create", "Delete", "Update", "Recover"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover"]
  }
}


# --- SALIDAS (OUTPUTS) ---
output "main_resource_group_name" {
  value = azurerm_resource_group.main.name
}
output "network_resource_group_name" {
  value = azurerm_resource_group.network.name
}
output "dns_resource_group_name" {
  value = azurerm_resource_group.dns.name
}
output "vnet_name" {
  value = azurerm_virtual_network.main.name
}
output "subnet_name" {
  value = azurerm_subnet.aks.name
}
output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.main.name
}
output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}
output "key_vault_name" {
  value = azurerm_key_vault.main.name
}