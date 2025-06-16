#Required for more providers
# terraform {
#   required_providers {
#     azurerm = {
#       source                = "hashicorp/azurerm"
#       configuration_aliases = [azurerm, azurerm.dnssubscription]
#     }
#   }
# }
# If you launchs the code in local and not from remote,you must comment the above code

## Modules
# Call Tags Module
module "tags" {
  source  = "tfe1.sgtech.corp/curated-catalog/module-tag/azurerm"
  version = ">=1.0.0"

  rsg_name       = var.rsg_name
  inherit        = var.inherit
  product        = var.product
  cost_center    = var.cost_center
  shared_costs   = var.shared_costs
  apm_functional = var.apm_functional
  cia            = var.cia
  custom_tags    = var.custom_tags
  optional_tags  = var.optional_tags
}

## LOCALS Define variables for local scope
locals {

  diagnostic_monitor_enabled = substr(var.rsg_name, 3, 1) == "p" || var.analytics_diagnostic_monitor_enabled ? true : false
  mds_lwk_enabled            = var.analytics_diagnostic_monitor_lwk_id != null || (var.lwk_name != null && local.rsg_lwk != null)
  mds_sta_enabled            = var.analytics_diagnostic_monitor_sta_id != null || (var.analytics_diagnostic_monitor_sta_name != null && var.analytics_diagnostic_monitor_sta_rsg != null)
  mds_aeh_enabled            = var.analytics_diagnostic_monitor_aeh_name != null && (var.eventhub_authorization_rule_id != null || (var.analytics_diagnostic_monitor_aeh_namespace != null && var.analytics_diagnostic_monitor_aeh_rsg != null))
  subscription               = var.subscription_id != null ? var.subscription_id : data.azurerm_client_config.current.subscription_id
  location                   = var.location != null ? var.location : data.azurerm_resource_group.rsg_principal.location
  akv_id                     = var.key_custom_enabled ? (!var.use_existing_des ? (var.akv_id != null ? var.akv_id : "/subscriptions/${local.subscription}/resourceGroups/${local.rsg_akv}/providers/Microsoft.KeyVault/vaults/${var.akv_name}") : null) : null
  rsg_akv                    = var.key_custom_enabled ? (var.akv_rsg_name != null ? var.akv_rsg_name : data.azurerm_resource_group.rsg_principal.name) : null
  rsg_lwk                    = var.lwk_rsg_name != null ? var.lwk_rsg_name : data.azurerm_resource_group.rsg_principal.name
  rsg_des                    = var.key_custom_enabled ? (var.des_rsg_name != null ? var.des_rsg_name : data.azurerm_resource_group.rsg_principal.name) : null
  des_name                   = !var.key_custom_enabled ? null : (var.use_existing_des ? var.des_name : "${var.aks_name}-${var.des_name}")

  virtual_network_ids = distinct(concat(
    var.virtual_network_ids,                                                                         # Custom virtual networks
    [for s in var.additional_node_pools : try(join("/", slice(split("/", s.subnet_id), 0, 9)), "")], # Additional node pool virtual networks
    [try(join("/", slice(split("/", var.default_node_pool.subnet_id), 0, 9)), "")]                   # Default node pool virtual network
  ))

  # create_private_dns_zone = var.private_dns_zone_id == null
  # private_dns_zone_id     = data.azurerm_private_dns_zone.private_dns_zone.id
  default_node_pool = {
    vm_size   = var.default_node_pool.vm_size == null ? "Standard_D2_v5" : var.default_node_pool.vm_size
    min_count = coalesce(lookup(var.default_node_pool, "min_count", 2), 2)
    max_count = coalesce(lookup(var.default_node_pool, "max_count", 100), 100)
    max_pods  = lookup(var.default_node_pool, "max_pods", 110)
  }

  http_proxy_config = {
    http_proxy  = var.http_proxy_config.http_proxy == null ? "http://proxy.sig.umbrella.com:80/" : var.http_proxy_config.http_proxy
    https_proxy = var.http_proxy_config.https_proxy == null ? "http://proxy.sig.umbrella.com:443/" : var.http_proxy_config.https_proxy
    no_proxy    = var.http_proxy_config.no_proxy == null ? [".corp", "sts.gsnetcloud.com", ".cluster.local.", ".cluster.local", ".svc", "10.112.0.0/16"] : var.http_proxy_config.no_proxy
    trusted_ca  = var.http_proxy_config.trusted_ca == null ? filebase64("${path.module}/certs/Cisco_Umbrella_CA.cer") : var.http_proxy_config.trusted_ca
  }
  
}

##DATA
# Get info about curent session
data "azurerm_client_config" "current" {}

# Get and set a resource group for deploy. 
data "azurerm_resource_group" "rsg_principal" {
  name = var.rsg_name
}

# Get and set a monitor diagnostic settings
data "azurerm_log_analytics_workspace" "lwk_principal" {
   count = local.mds_lwk_enabled && var.analytics_diagnostic_monitor_lwk_id == null ? 1 : 0

  name                = var.lwk_name
  resource_group_name = local.rsg_lwk
}

# Get and set a Storage Account to send logs in monitor diagnostic settings
data "azurerm_storage_account" "mds_sta" {
  count = local.mds_sta_enabled && var.analytics_diagnostic_monitor_sta_id == null ? 1 : 0

  name                = var.analytics_diagnostic_monitor_sta_name
  resource_group_name = var.analytics_diagnostic_monitor_sta_rsg
}

# Get and set a Event Hub Authorization Rule to send logs in monitor diagnostic settings
data "azurerm_eventhub_namespace_authorization_rule" "mds_aeh" {
  count = local.mds_aeh_enabled && var.eventhub_authorization_rule_id == null ? 1 : 0

  name                = var.analytics_diagnostic_monitor_aeh_policy
  resource_group_name = var.analytics_diagnostic_monitor_aeh_rsg
  namespace_name      = var.analytics_diagnostic_monitor_aeh_namespace
}


#Get and Set the private DNS Zone
data "azurerm_private_dns_zone" "private_dns_zone" {
  provider = azurerm.dnssubscription

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_rsg_name

}


// RESOURCES
resource "azurerm_key_vault_key" "key_generate" {
  count = (var.key_custom_enabled && var.use_existing_des == false) && var.key_exist == false ? 1 : 0

  name         = var.key_name
  key_vault_id = local.akv_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey",
    "encrypt",
    "decrypt"
  ] 

  rotation_policy {
    automatic {
      time_after_creation = "P90D"
    }
    expire_after         = "P10Y"
    notify_before_expiry = "P60D"
  }

  lifecycle {
    ignore_changes = [ expiration_date ]
  } 

  tags = var.inherit ? (length(module.tags.tags) < 16 ? module.tags.tags : module.tags.mandatory_tags) : (length(module.tags.tags_complete) < 16 ? module.tags.tags_complete : module.tags.mandatory_tags)
}

# Get and set a existing key from a key vault. 
data "azurerm_key_vault_key" "key_principal" {
  count      = var.key_custom_enabled && var.use_existing_des == false ? 1 : 0
  depends_on = [azurerm_key_vault_key.key_generate]

  name         = var.key_name
  key_vault_id = local.akv_id
}

#Set a Disk Encrytion Set
resource "azurerm_disk_encryption_set" "des" {
  count      = var.key_custom_enabled && var.use_existing_des == false ? 1 : 0
  depends_on = [azurerm_key_vault_key.key_generate]

  name                = local.des_name
  resource_group_name = local.rsg_des
  location            = local.location
  key_vault_key_id    = data.azurerm_key_vault_key.key_principal[0].id
 
  identity {
    type = "SystemAssigned"
  }

  tags = var.inherit ? module.tags.tags : module.tags.tags_complete
}

# Get a Disk Encryption Set
data "azurerm_disk_encryption_set" "des" {
  count      = var.key_custom_enabled ? 1 : 0
  depends_on = [azurerm_disk_encryption_set.des]

  name                = local.des_name
  resource_group_name = local.rsg_des
}

#Create a policy to access to the Key Vault from the Disk Encryption Set
resource "azurerm_key_vault_access_policy" "des2akv_access" {
  count      = var.key_custom_enabled && !var.use_existing_des ? 1 : 0
  depends_on = [azurerm_disk_encryption_set.des]

  key_vault_id = local.akv_id
  tenant_id    = data.azurerm_disk_encryption_set.des[0].identity.0.tenant_id
  object_id    = data.azurerm_disk_encryption_set.des[0].identity.0.principal_id

  key_permissions = [
    "Decrypt",
    "Encrypt",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}

#Set the user assigned identity
resource "azurerm_user_assigned_identity" "uai_principal" {
  count      = var.exist_uai == false ? 1 : 0

  resource_group_name = var.rsg_name
  location            = local.location
  name                = var.uai_name == null ? var.aks_name : "${var.aks_name}-${var.uai_name}"
  tags                = var.inherit ? module.tags.tags : module.tags.tags_complete
}

#Get a user assigned identity 
data "azurerm_user_assigned_identity" "uai_principal" {
  depends_on = [azurerm_user_assigned_identity.uai_principal]

  name                = var.exist_uai == true ? var.uai_name : azurerm_user_assigned_identity.uai_principal[0].name
  resource_group_name = data.azurerm_resource_group.rsg_principal.name
}

# Assign private DNS zone contributor role to the user assigned identity for the private DNS zones
resource "azurerm_role_assignment" "uai_role_private_dns_zone" {
  depends_on = [data.azurerm_user_assigned_identity.uai_principal]

  scope                = data.azurerm_private_dns_zone.private_dns_zone.id #local.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = data.azurerm_user_assigned_identity.uai_principal.principal_id
}

# Assign Network contributor role to the user assigned identity for the Vnets
# the user assigned identity with the Virtual Networks like contributor
# The AKS cluster identity has the Contributor role on the AKS second resource group (MC_myResourceGroup_myAKSCluster_eastus)
# However when using a custom VNET, the AKS cluster identity needs the Network Contributor role on the VNET subnets
# used by the system node pool and by any additional node pools.
# https://learn.microsoft.com/en-us/azure/aks/configure-kubenet#prerequisites
# https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni#prerequisites
# https://github.com/Azure/terraform-azurerm-aks/issues/178
resource "azurerm_role_assignment" "uai_role_vnts" {
  #####revisar
  for_each   = toset(local.virtual_network_ids)
  depends_on = [azurerm_role_assignment.uai_role_private_dns_zone]

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.uai_principal.principal_id
}

# Assign ACR Pull role to the AKS Cluster objectId for the ACR's
resource "azurerm_role_assignment" "aks_cluster_role_acr" {
  for_each   = var.attached_acr_id_map

  principal_id                     = azurerm_kubernetes_cluster.cluster_k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = each.value
  skip_service_principal_aad_check = true
}

# Link Private DNS Zones with VNET
resource "azurerm_private_dns_zone_virtual_network_link" "lnk_vnt_private_dns_zone" {
  provider   = azurerm.dnssubscription
  for_each   = toset(var.virtual_network_ids)
  depends_on = [data.azurerm_private_dns_zone.private_dns_zone]

  name                  = each.key
  resource_group_name   = data.azurerm_private_dns_zone.private_dns_zone.resource_group_name #split("/", local.private_dns_zone_id)[4]
  private_dns_zone_name = data.azurerm_private_dns_zone.private_dns_zone.name                #split("/", local.private_dns_zone_id)[8]
  virtual_network_id    = each.value

  tags = var.inherit ? module.tags.tags : module.tags.tags_complete
}

resource "azurerm_kubernetes_cluster" "cluster_k8s" {
  depends_on = [azurerm_role_assignment.uai_role_vnts, data.azurerm_log_analytics_workspace.lwk_principal]

  name                = var.aks_name
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rsg_principal.name
  dns_prefix          = var.dns_prefix == null ? var.aks_name : var.dns_prefix

  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = true
  private_dns_zone_id     = data.azurerm_private_dns_zone.private_dns_zone.id #local.private_dns_zone_id
  azure_policy_enabled    = true
  #`public_network_access_enabled` is currently not functional and is not be passed to the API
  #public_network_access_enabled = false 
  sku_tier                            = var.sku_tier
  disk_encryption_set_id              = var.key_custom_enabled ? data.azurerm_disk_encryption_set.des[0].id : null
  custom_ca_trust_certificates_base64 = null #TODO Add our custom CA certs

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.uai_principal.id]
  }

  # If local_account_disabled is set to true, it is required to enable Kubernetes RBAC and AKS-managed Azure AD integration.
  local_account_disabled            = true
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.rbac_aad_admin_group_object_ids
    azure_rbac_enabled     = false
  }

  default_node_pool {
    name                        = "default"
    temporary_name_for_rotation = "tempdefault"

    enable_node_public_ip  = false
    enable_auto_scaling    = true
    enable_host_encryption = false
    os_sku                 = "AzureLinux"
    # BYOK and Ephemeral OS disk can not be combined in Azure. Disable ephemeral OS disk or disable BYOK."
    os_disk_type = var.key_custom_enabled ? "Managed" : try(var.default_node_pool.os_disk_type, "Managed")
    type         = "VirtualMachineScaleSets"

    zones                        = ["1", "2", "3"]
    max_count                    = local.default_node_pool.max_count
    max_pods                     = local.default_node_pool.max_pods
    min_count                    = local.default_node_pool.min_count
    vm_size                      = local.default_node_pool.vm_size
    node_labels                  = try(var.default_node_pool.node_labels, {})
    only_critical_addons_enabled = try(var.default_node_pool.only_critical_addons_enabled, false)
    orchestrator_version         = try(var.default_node_pool.var.kubernetes_version, var.kubernetes_version)
    os_disk_size_gb              = try(var.default_node_pool.os_disk_size_gb, null)
    proximity_placement_group_id = try(var.default_node_pool.proximity_placement_group_id, null)
    scale_down_mode              = try(var.default_node_pool.scale_down_mode, null)
    ultra_ssd_enabled            = try(var.default_node_pool.ultra_ssd_enabled, false)
    vnet_subnet_id               = var.default_node_pool.subnet_id
    tags                         = var.inherit ? module.tags.tags : module.tags.tags_complete

    upgrade_settings {
        max_surge = var.default_node_pool.max_surge  
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = var.auto_scaler_profile.balance_similar_node_groups
    expander                         = var.auto_scaler_profile.expander
    max_graceful_termination_sec     = var.auto_scaler_profile.max_graceful_termination_sec
    max_node_provisioning_time       = var.auto_scaler_profile.max_node_provisioning_time
    max_unready_nodes                = var.auto_scaler_profile.max_unready_nodes
    max_unready_percentage           = var.auto_scaler_profile.max_unready_percentage
    new_pod_scale_up_delay           = var.auto_scaler_profile.new_pod_scale_up_delay
    scale_down_delay_after_add       = var.auto_scaler_profile.scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_profile.scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_profile.scale_down_delay_after_failure
    scan_interval                    = var.auto_scaler_profile.scan_interval
    scale_down_unneeded              = var.auto_scaler_profile.scale_down_unneeded
    scale_down_unready               = var.auto_scaler_profile.scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
    empty_bulk_delete_max            = var.auto_scaler_profile.empty_bulk_delete_max
    skip_nodes_with_local_storage    = var.auto_scaler_profile.skip_nodes_with_local_storage
    skip_nodes_with_system_pods      = var.auto_scaler_profile.skip_nodes_with_system_pods
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    outbound_type       = "userDefinedRouting"
    #ebpf_data_plane     = "cilium"
    dns_service_ip    = "10.112.0.10"
    load_balancer_sku = var.load_balancer_sku
    service_cidr      = "10.112.0.0/18"
    pod_cidr          = "10.112.128.0/17"
  }

  http_proxy_config {
    http_proxy  = local.http_proxy_config.http_proxy
    https_proxy = local.http_proxy_config.https_proxy
    no_proxy    = local.http_proxy_config.no_proxy
    trusted_ca  = local.http_proxy_config.trusted_ca
  }

  dynamic "oms_agent" {
    for_each = local.diagnostic_monitor_enabled && local.mds_lwk_enabled ? ["oms_agent"] : []
    content {
      log_analytics_workspace_id = var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled && var.defender_lwk_id != null ? ["microsoft_defender"] : []

    content {
      log_analytics_workspace_id = var.defender_lwk_id
    }
  }

  automatic_channel_upgrade = var.automatic_channel_upgrade
  dynamic "maintenance_window" {
    for_each = length(concat(var.allowed_maintenance_window, var.not_allowed_maintenance_window)) > 0 ? [1] : []
    content {
      dynamic "allowed" {
        for_each = var.allowed_maintenance_window
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = var.not_allowed_maintenance_window
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [http_proxy_config["no_proxy"]]
  }

  tags = var.inherit ? module.tags.tags : module.tags.tags_complete
}

resource "null_resource" "pool_name_keeper" {
  for_each   = var.additional_node_pools
  depends_on = [azurerm_kubernetes_cluster.cluster_k8s]

  triggers = {
    pool_name = each.key
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each   = var.additional_node_pools
  depends_on = [null_resource.pool_name_keeper]

  kubernetes_cluster_id  = azurerm_kubernetes_cluster.cluster_k8s.id
  name                   = "${substr(each.key, 0, 8)}${substr(md5(jsonencode(each.value)), 0, 4)}"
  enable_auto_scaling    = true
  enable_host_encryption = false
  enable_node_public_ip  = false
  mode                   = "User"
  # BYOK and Ephemeral OS disk can not be combined in Azure. Disable ephemeral OS disk or disable BYOK."
  os_disk_type     = var.key_custom_enabled ? "Managed" : try(each.value.os_disk_type, "Managed")
  os_sku           = "AzureLinux"
  os_type          = "Linux"
  workload_runtime = "OCIContainer"
  zones            = ["1", "2", "3"]

  vm_size                       = each.value.vm_size
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  custom_ca_trust_enabled       = each.value.custom_ca_trust_enabled
  eviction_policy               = each.value.eviction_policy
  fips_enabled                  = each.value.fips_enabled
  host_group_id                 = each.value.host_group_id
  max_count                     = each.value.max_count
  max_pods                      = each.value.max_pods
  min_count                     = each.value.min_count
  node_count                    = each.value.node_count
  node_labels                   = each.value.node_labels
  node_taints                   = each.value.node_taints
  orchestrator_version          = each.value.orchestrator_version
  os_disk_size_gb               = each.value.os_disk_size_gb
  priority                      = each.value.priority
  proximity_placement_group_id  = each.value.proximity_placement_group_id
  scale_down_mode               = each.value.scale_down_mode
  spot_max_price                = each.value.spot_max_price
  ultra_ssd_enabled             = each.value.ultra_ssd_enabled
  vnet_subnet_id                = each.value.subnet_id

  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings == null ? [] : ["upgrade_settings"]

    content {
      max_surge = each.value.upgrade_settings.max_surge
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name, node_count]
    replace_triggered_by  = [null_resource.pool_name_keeper[each.key]]

    precondition {
      condition     = can(regex("[a-z0-9]{1,8}", each.key))
      error_message = "A Node Pools name must consist of alphanumeric characters and have a maximum lenght of 12 characters"
    }

    precondition {
      condition     = !can(regex("^Standard_DC[0-9]+s?_v2$", each.value.vm_size))
      error_message = "With with Azure CNI Overlay you can't use DCsv2-series virtual machines in node pools. "
    }
  }

  tags = var.inherit ? module.tags.tags : module.tags.tags_complete
}

# resource "azurerm_kubernetes_cluster_extension" "aks_extension" {
#   for_each   = local.extensions
#   depends_on = [azurerm_kubernetes_cluster_node_pool.node_pool]

#   name           = each.key
#   cluster_id     = azurerm_kubernetes_cluster.cluster_k8s.id
#   extension_type = each.value
# }

resource "azurerm_kubernetes_cluster_extension" "flux" {
  count      = var.gitops_enabled ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster_node_pool.node_pool]

  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.cluster_k8s.id
  extension_type = "microsoft.flux"

  configuration_settings = {
    "multiTenancy.enforce" = "false"
  }
}

resource "azurerm_kubernetes_flux_configuration" "flux_cfg" {
  count      = var.gitops_enabled ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster_extension.flux]

  name       = "bootstrap"
  cluster_id = azurerm_kubernetes_cluster.cluster_k8s.id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url             = var.gitops_config.url
    reference_type  = "tag"
    reference_value = var.gitops_config.tag

    https_user       = var.gitops_config.token_base64 != null ? "github" : null
    https_key_base64 = var.gitops_config.token_base64
  }

  dynamic "kustomizations" {
    for_each = var.gitops_config.kustomizations
    content {
      name                       = kustomizations.key
      path                       = kustomizations.value
      sync_interval_in_seconds   = 60
      retry_interval_in_seconds  = 60
      garbage_collection_enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "mds_principal" {
  count      = local.diagnostic_monitor_enabled == true ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster.cluster_k8s]

  name                           = var.analytics_diagnostic_monitor_name
  target_resource_id             = azurerm_kubernetes_cluster.cluster_k8s.id
  log_analytics_workspace_id     = local.mds_lwk_enabled ? (var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id) : null
  eventhub_name                  = local.mds_aeh_enabled ? var.analytics_diagnostic_monitor_aeh_name : null
  eventhub_authorization_rule_id = local.mds_aeh_enabled ? (var.eventhub_authorization_rule_id != null ? var.eventhub_authorization_rule_id : data.azurerm_eventhub_namespace_authorization_rule.mds_aeh[0].id) : null
  storage_account_id             = local.mds_sta_enabled ? (var.analytics_diagnostic_monitor_sta_id != null ? var.analytics_diagnostic_monitor_sta_id : data.azurerm_storage_account.mds_sta[0].id) : null

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

#Set a Container Solution for the LWK
resource "azurerm_log_analytics_solution" "lwk_container" {
  count = local.diagnostic_monitor_enabled && local.mds_lwk_enabled ? 1 : 0

  resource_group_name   = data.azurerm_resource_group.rsg_principal.name
  location              = local.location
  solution_name         = "ContainerInsights"
  workspace_name        = split("/", (var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id))[8]
  workspace_resource_id = var.analytics_diagnostic_monitor_lwk_id != null ? var.analytics_diagnostic_monitor_lwk_id : data.azurerm_log_analytics_workspace.lwk_principal[0].id

  tags = var.inherit ? module.tags.tags : module.tags.tags_complete

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}
