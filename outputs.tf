output "aks_name" {
  description = "The name of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.name
}

output "aks_id" {
  description = "The ID of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.id
}

output "aks_location" {
  description = "The location where the Azure Kubernetes Managed Cluster was created."
  value       = azurerm_kubernetes_cluster.cluster_k8s.location
}

output "aks_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.fqdn
}

output "aks_portal_fqdn" {
  description = "The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.portal_fqdn
}

output "aks_private_fqdn" {
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.private_fqdn
}

output "aks_node_rsg" {
  description = "The auto-generated Resource Group which contains the resources for this Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.node_resource_group
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.oidc_issuer_url
}

output "aks_cluster_identity" {
  description = "The identity block of the Azure Kubernetes Managed Cluster."
  value       = try(azurerm_kubernetes_cluster.cluster_k8s.identity[0], null)
}

output "aks_kubelet_identity" {
  description = "The kubelet identity block of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.kubelet_identity
}

output "aks_network_profile" {
  description = "The Network Profile block of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.network_profile
}

output "aks_kube_config" {
  description = "The kube config block of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.kube_config[0]
  sensitive   = true
}

output "aks_kube_config_raw" {
  description = "The raw kubernetes config to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools corresponding with the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.kube_config_raw
  sensitive   = true
}

output "aks_kube_admin_config" {
  description = "The kube admin config block of the Azure Kubernetes Managed Cluster."
  value       = try(azurerm_kubernetes_cluster.cluster_k8s.kube_admin_config[0], "")
  sensitive   = true
}

output "aks_kube_admin_config_raw" {
  description = "The raw Kubernetes config for the admin account to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools corresponding with the Azure Kubernetes Managed Cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
  value       = azurerm_kubernetes_cluster.cluster_k8s.kube_admin_config_raw
  sensitive   = true
}

output "aks_azure_policy_enabled" {
  description = "Specifies if the Azure Policy Add-On is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.azure_policy_enabled
}

output "aks_http_application_routing_enabled" {
  description = "Specifies if the HTTP Application Routing is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.http_application_routing_enabled
}

output "aks_http_application_routing_zone_name" {
  description = "The Zone Name of the HTTP Application Routing for the Azure Kubernetes Managed Cluster if the HTTP Application Routing is enabled."
  value       = azurerm_kubernetes_cluster.cluster_k8s.http_application_routing_zone_name != null ? azurerm_kubernetes_cluster.cluster_k8s.http_application_routing_zone_name : ""
}

output "aks_ingress_application_gateway_enabled" {
  description = "Specifies if the ingress application gateway is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = can(azurerm_kubernetes_cluster.cluster_k8s.ingress_application_gateway[0])
}

output "aks_ingress_application_gateway" {
  description = "The ingress application gateway configuration for the Azure Kubernetes Managed Cluster if it's enabled."
  value       = try(azurerm_kubernetes_cluster.cluster_k8s.ingress_application_gateway[0], null)
}

output "aks_key_vault_secrets_provider_enabled" {
  description = "Specifies if the Key Vault secrets provider is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = can(azurerm_kubernetes_cluster.cluster_k8s.key_vault_secrets_provider[0])
}

output "aks_key_vault_secrets_provider" {
  description = "The Key Vault secrets provider configuration for the Azure Kubernetes Managed Cluster if it's enabled."
  value       = try(azurerm_kubernetes_cluster.cluster_k8s.key_vault_secrets_provider[0], null)
}

output "aks_oms_agent_enabled" {
  description = "Specifies if the OMS Agent is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = can(azurerm_kubernetes_cluster.cluster_k8s.oms_agent[0])
}

output "aks_oms_agent" {
  description = "The OMS Agent configuration for the Azure Kubernetes Managed Cluster if it's enabled."
  value       = try(azurerm_kubernetes_cluster.cluster_k8s.oms_agent[0], null)
}

output "aks_open_service_mesh_enabled" {
  description = "Specifies if the Open Service Mesh is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.cluster_k8s.open_service_mesh_enabled
}

