# **Changelog**

## **[v2.4.1 (2024-09-11)]**
### Changes
- `Added` rotation policy in azurerm_key_vault_key called by key_generate.
- `Added` ignore change lifecycle in azurerm_key_vault_key resource key_generate by issue in re-apply.
- `Updated` dependencies between azurerm_key_vault_key resource key_generate and azurerm_disk_encryption_set resource called des and between azurerm_disk_encryption_set resource called des and azurerm_key_vault_access_policy resource called kvt_access_policy by issue.
- `Tested` re-apply. 
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.4.0 (2024-07-01)]**
### Changes
- `Changed` use cmk from mandatory in pro env to optional.
- `Changed` the use of Log Analytics in a diagnostic monitor from mandatory to optional.
- `Changed` to improve the code.
- `Added` akv_id & analytics_diagnostic_monitor_lwk_id, defender_lwk_id variables.
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.3.9 (2024-06-19)]**
### Changes
- `Changed` the tags used in the azurerm_key_vault_key resource called key_generate are changed to always assign a number of tags <15 to the keys due for a issue by the Azure limitation to have a maximum of 15 tags in a key.

## **[v2.3.8 (2024-05-31)]**
### Changes
- `Changed` the http_proxy_config variable to allow setting the subvariables it includes (http_proxy, https_proxy, no_proxy or trusted_ca) with an optional null value. This allows setting only the necessary subvariables in a parameter pass in a call to the module or in a tfvars file use and not establish all of them as was done until now by calling the variable.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.3.7 (2024-05-29)]**
### Changes
- `Changed` the method of obtaining tags from calculation in locals to calling a dedicated tags module.
- `Changed` cia variable from optional to required. 
- `Added` tags module call.
- `Added` optional_tags variable.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.3.6 (2024-05-14)]**
### Changes
- `Tested` with terraform v1.7.1, null provider v3.2.2 and azure provider v3.90.0.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v2.3.5 (2024-03-25)]**
### Changes
- `Changed` the method to obtain akv_id was modified from using a data to composing it, due to an issue with its use with modules.
- `Added` subscription_id variable.
- `Added` azurerm_client_config datasource called current.
- `Restored` provider call in main with use in a module call by issue.
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.3.4 (2024-03-13)]** 
### Changes
- `Changed` to reduce the number of monitored logs in a diagnostic settings to only kube-audit in the azurerm_monitor_diagnostic_setting resource called mds_principal.
- `Updated` CHANGELOG.md.

## **[v2.3.3 (2024-03-07)]**
### Changes
- `Updated` README.md with CISO certification of the module (RITM010902600).
  
## **[v2.3.2 (2024-02-20)]**
### Changes
- `Updated` Main to set always tags with the correct naming.
- `Updated` issue creating ContainerInsights solution in azurerm_log_analytics_solution resource called lwk_container. 
- `Updated` README.md.
- `Updated` CHANGELOG.md.

## **[v2.3.1 (2024-01-30)]**
### Changes
- `Added` use sta & aeh in the diagnostic settings component.
- `Added` azurerm_storage_account datasource called mds_sta.
- `Added` azurerm_azurerm_eventhub_namespace_authorization_rule datasource called  mds_aeh.
- `Updated` azurerm_monitor_diagnostic_setting resource called mds_principal. 
- `Added` eventhub_authorization_rule_id variable.
- `Added` analytics_diagnostic_monitor_aeh_namespace  variable.
- `Added` analytics_diagnostic_monitor_aeh_name variable.
- `Added` analytics_diagnostic_monitor_aeh_rsg variable. 
- `Added` analytics_diagnostic_monitor_aeh_policy variable.
- `Added` analytics_diagnostic_monitor_sta_id variable.
- `Added` analytics_diagnostic_monitor_sta_name variable.
- `Added` analytics_diagnostic_monitor_sta_rsg variable.
- `Updated` README.md.
- `Updated` CHANGELOG.md.
- `Tested` re-apply.

## **[v2.3.0 (2024-01-19)]**
### Changes
- `Added` support for the GitOps extension (flux) to the AKS module code (RITM010734978).
- `Added` modified the module to set the IPs of Kubernetes pods and services in Azure CNI Overlay mode to the reference range (RITM010735049).
- `Added` http_proxy_config block in resource azurerm_kubernetes_cluster resource called cluster_k8s (RITM010360718).
- `Added` autoscaler profile in resource azurerm_kubernetes_cluster resource called cluster_k8s for required node autoscaling (RITM010360754).
- `Added` use Azure CNI Overlay networking in resource azurerm_kubernetes_cluster resource called cluster_k8s (RITM010360267).
- `Added` support for user assigned managed identities like identity in the cluster (RITM010360215).
- `Deleted` use Kubernetes provider from the code (RITM010360322).
- `Added ` use of custom_ca_trust_enabled property in resource azurerm_kubernetes_cluster resource called cluster_k8s (issue in code).
- `Added ` outputs.
- `Updated` README.md.
- `Updated` CHANGELOG.md.
- `Updated` Arquitecture & Networking diagrams.
- `Tested` with Azure provider v3.73.0 and Null provider v3.2.1.
- `Tested` re-apply.

## **[v2.2.0 (2023-09-07)]**
### Changes
- `Update` README.md
- `Update` CHANGELOG.md
- `Update` versions terraform to 1.4.6 and Azure 3.60.0.

## **[v2.1.2 (2023-08-31)]**
### Changes
- `Update` Delete retention policy block.
- `Update` README.md.

## **[v2.1.0 (2023-03-24)]** 
### Changes
- `Changed` resource_group variable name in favour of rsg_name.
- `Changed` name variable name in favour of aks_name.
- `Changed` akv_key variable name in favour of key_name.
- `Changed` user_assigned_identity_id variable name in favour of uai_name.
- `Changed` dns_resource_group variable name in favour of dns_rsg.
- `Added` akv_rsg_name variable.
- `Added` key_exist variable.
- `Added` key_custom_enabled variable.
- `Added` lwk_rsg_name variable.
- `Added` analytics_diagnostic_monitor_name variable.
- `Added` analytics_diagnostic_monitor_enabled variable.
- `Removed` log_analytics_workspace_sku variable.
- `Removed` log_retention_in_days variable.
- `Removed` local disk_encryption_set_count variable.
- `Removed` local disk_encryption_set_key_count variable.
- `Changed` kubernetes_version variable name in favour of aks_version.
- `Changed` data identifier from rsg to rsg_principal.
- `Changed` data identifier from akv to akv_principal.
- `Changed` data identifier from data_lwk to lwk_principal.
- `Changed` data identifier from data_subnet to snt_principal.
- `Changed` azurerm_key_vault_key identifier from generated to key_generate.
- `Changed` azurerm_key_vault_key identifier from generated to key_principal.
- `Changed` azurerm_monitor_diagnostic_setting identifier from dgm to mds_principal.
- `Changed` tags assign in resources from a merged group to local.tags
- `Added` key_cmk local to set use or not cmk
- `Changed` old local tags in favour of new tags.
- `Changed` Kubernetes_Managed_Cluster_ID output name in favour of aks_id.
- `Changed` Kubernetes_Managed_Cluster_FQDN output name in favour of aks_FQDN.
- `Changed` Kubernetes_Managed_Cluster_node_resource_group output name in favour of aks_node_rsg.
- `Update` Readme.md.
- `Update` module with template version v1.0.6.

## [v2.0.0] - 2022-13-12
## Changed
 * Update README.md
 * Update code
 * Terraform v1.3.2
 * Azure Provider v3.35.0

## [v1.1.1] - 2022-08-11
## Changed
 * Update resources names
 * Update README.md
 * Add file output.tf
 * Add common_tags to local variables
 * Terraform v1.0.9
 * Azure Provider v2.98.0
 * Kubernetes Provider v2.7.1

## [v1.1.0] - 2022-03-15
## Changed
 * Oficial Module terraform-azurerm-module-aks
 * Terraform v1.0.9
 * Azure Provider v2.98.0
 * Kubernetes Provider v2.7.1
 
Updated change log
## [v1.0.1] - 2022-02-15
## Changed
 * last release iac.az.modules.aks_cluster
 * add variable dns_resource_group

## [v1.0.0] - 2022-02-07
## Changed
 * First certified version

## [v0.0.1]
 * First version. No validated
