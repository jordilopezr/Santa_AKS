//COMMON
rsg_name = "sgtd2weursgitdmodcomm001"

# AKS product variables
aks_name = "sgtd2weuaksitdmodcomm001"
sku_tier = "Free"

exist_uai = false
uai_name  = "sgtd2weuuaiitdmodcomm012"
#exist_uai = true
#uai_name  = "myexistingidentityaks"

default_node_pool = {
  subnet_id     = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgplatfoglob001/providers/Microsoft.Network/virtualNetworks/sgtd2weuvntplatfoglob001/subnets/sgtd2weuvntplatfoglob001-snt69"
  vm_size       = "Standard_B4ms"
  min_count     = 2
  max_count     = 6
  agents_labels = null
}

additional_node_pools = {
  nodepool1 = {
    node_count = 2
    tags       = { "pool" : "nodepool1" }
    vm_size    = "Standard_D2s_v3"
    max_count  = 6
    max_pods   = 110
    min_count  = 1
    node_labels = {
      "kubernetes.sds.com/mode" = "user"
    }
    node_taints = [
      "CriticalAddonsOnly=true:NoSchedule"
    ]
    subnet_id = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgplatfoglob001/providers/Microsoft.Network/virtualNetworks/sgtd2weuvntplatfoglob001/subnets/sgtd2weuvntplatfoglob001-snt69"
  }
  nodepool2 = {
    node_count = 2
    tags       = { "pool" : "nodepool2" }
    vm_size    = "Standard_D2s_v3"
    max_count  = 6
    max_pods   = 110
    min_count  = 1
    node_labels = {
      "kubernetes.sds.com/mode" = "user"
    }
    node_taints = [
      "CriticalAddonsOnly=true:NoSchedule"
    ]
    subnet_id = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgplatfoglob001/providers/Microsoft.Network/virtualNetworks/sgtd2weuvntplatfoglob001/subnets/sgtd2weuvntplatfoglob001-snt69"
  }

}

dns_prefix                = "aks-test"
dns_subscription_id       = "ebac6c00-3c2f-4d56-82c0-8057225d44fa"
private_dns_zone_rsg_name = "sgtd2weursgplatfoglob001"
private_dns_zone_name     = "test.privatelink.westeurope.azmk8s.io"



#key_custom_enabled = false
#akv_id             = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgitdmodcomm001/providers/Microsoft.KeyVault/vaults/sgtd2weuakvitdmodcomm002"
#akv_name           = "sgtd2weuakvitdmodcomm002"
#akv_rsg_name       = "sgtd2weursgitdmodcomm001"
# key_exist          = false
#key_name           = "AAtestAKSKeycreate"
#key_exist        = true
#key_name         = "sgtd2weukeyitdmodcomm011-aks"
#use_existing_des = false
#des_rsg_name     = "sgtd2weursgitdmodcomm001"
#des_name         = "sgtd2weudesitdmodcomm001-aks"
#use_existing_des = true
#des_name         = "sgtd2weudesitdmodcomm011-aks"


rbac_aad_admin_group_object_ids = [
  "91df1d64-05b2-45d4-a24c-8e453f486969",
  "bd01d9d9-0108-41ad-9f9f-b92e81138234"
]

analytics_diagnostic_monitor_enabled        = false
#analytics_diagnostic_monitor_lwk_id        = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgitdmodcomm001/providers/Microsoft.OperationalInsights/workspaces/sgtd2weulwkitdmodcomm001"
#lwk_name                                   = "sgtd2weulwkitdmodcomm001"
#lwk_rsg_name                               = "sgtd2weursgitdmodcomm001"
#analytics_diagnostic_monitor_name          = "sgtd2wuedbraks"
#analytics_diagnostic_monitor_sta_id        = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgitdmodcomm001/providers/Microsoft.Storage/storageAccounts/sgtd2weustaitdmodcomm001"
#analytics_diagnostic_monitor_sta_name      = "sgtd2weustaitdmodcomm001"
#analytics_diagnostic_monitor_sta_rsg       = "sgtd2weursgitdmodcomm001"
#analytics_diagnostic_monitor_aeh_rsg       = "sgtd2weursgitdmodcomm001"
#analytics_diagnostic_monitor_aeh_namespace = "sgtd2weuaehitdmodcomm001"
#analytics_diagnostic_monitor_aeh_name      = "sgtd2weuaehitdmodcomm001-testaeh"
#eventhub_authorization_rule_id             = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgitdmodcomm001/providers/Microsoft.EventHub/namespaces/sgtd2weuaehitdmodcomm001/authorizationRules/RootManageSharedAccessKey"


#defender_lwk_id = "/subscriptions/ebac6c00-3c2f-4d56-82c0-8057225d44fa/resourceGroups/sgtd2weursgitdmodcomm001/providers/Microsoft.OperationalInsights/workspaces/sgtd2weulwkitdmodcomm002"

# agent_pool_name        = "akspooldfalt"
# agent_pool_vnet_rsg    = "sgtd2weursgplatfoglob001"
# agent_pool_vnet_name   = "sgtd2weuvntplatfoglob001"
# agent_pool_subnet_name = "sgtd2weuvntplatfoglob001-snt04"


# Custom tags
product        = "Cluster AKS Test"
cost_center    = "CC-ITDMOD"
shared_costs   = "Yes"
apm_functional = "APM Test"
cia            = "CLL"



optional_tags = {
  entity                = "sgt"
  environment           = "dev"
  APM_technical         = "APM tech Test"
  business_service      = "Business Service Test"
  service_component     = "Service Component Test"
  description           = "Description Test"
}
custom_tags    = { "Test" : "CustomTag", "1": "1", "2": "2", "3": "3", "4": "4" }