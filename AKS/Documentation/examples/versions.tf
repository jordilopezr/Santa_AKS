# Terraform and Azure Provider version being used
terraform {
  required_version = "=1.7.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.90.0"
      configuration_aliases = [azurerm, azurerm.dnssubscription]
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.2.2"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  storage_use_azuread        = true # Mandatory for use a sta 
  features {
    key_vault {
      purge_soft_delete_on_destroy               = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      purge_soft_deleted_secrets_on_destroy      = false
      recover_soft_deleted_key_vaults            = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
      recover_soft_deleted_secrets               = true
      # Necessary to avoid errors in the destruction process with soft delete & recover 
    }
    template_deployment {
      delete_nested_items_during_deletion = true
      # use this feature only with a azurerm_template_deployment resource 
      # not necesarry with a azurerm_resource_group_template_deployment resource  
    }
  }
}

provider "azurerm" {
  alias           = "dnssubscription"
  subscription_id = var.dns_subscription_id

  skip_provider_registration = true
  storage_use_azuread        = true # Mandatory for use a sta 
  features {
    key_vault {
      purge_soft_delete_on_destroy               = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      purge_soft_deleted_secrets_on_destroy      = false
      recover_soft_deleted_key_vaults            = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
      recover_soft_deleted_secrets               = true
      # Necessary to avoid errors in the destruction process with soft delete & recover 
    }
    template_deployment {
      delete_nested_items_during_deletion = true
      # use this feature only with a azurerm_template_deployment resource 
      # not necesarry with a azurerm_resource_group_template_deployment resource  
    }
  }
}

# Use with MS Devops, Don't use with TFE
# Configuring the Remote Backend to use Azure Storage with Terraform 
#terraform {
#  backend "azurerm" {}
#}
