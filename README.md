# **Azure Kubernetes Service Cluster**

|     :warning: WARNING      |
|:---------------------------|
|Our current Group strategy is based on Openshift as unique layer over OHE & Public Clouds to guarantee the portability of workloads between OHE and Public Cloud ([Public Cloud CaaS Strategy](https://confluence.alm.europe.cloudcenter.corp/display/ARCHCLOUD/Public+Cloud+CaaS+Strategy)):<br>1.	For critical applications, our CaaS strategy must guarantee the portability of workloads between Public Cloud and OHE. Openshift is the selected platform in Santander to implement this strategy and its usage is mandatory.<br>2.	There is an use case where an exception for the Openshift strategy is permitted:  for channel applications with high elasticity requirements running in Public Cloud, using native Kubernetes (AKS/EKS) could a valid alternative (specially with a high volume of small clusters) only if the entity has the specific skills required for operation and if portability to OCP OnPrem is guaranteed.<br><br>In order to guarantee portability and to avoid financial impact for other units there are three caveats for this alternative:<br>A.	Dual deployment required (OCP OnPrem + AKS/EKS in Public) in active/active. There is no need of having full 100% capacity on both platforms. Load can be split (e.g. 10-90) and scaled when needed.<br>B.	Units must maintain their contribution to the OCP contract to avoid impacting other units.<br>C.	For advanced capabilities (e.g., federated service mesh or serverless) OpenShift is the option recommended as AKS/EKS is not mature enough (to be analyzed again in the context of OneApp).|    

## Overview

**IMPORTANT** 
If you want to run this module it is an important requirement to specify the azure provider version, you must set the azure provider version and the terraform version in version.tf file.

This module has been certified with the versions:

| Terraform version | Azure version | Null version |
|:-----:|:-----:|:-----:|
| 1.7.1 | 3.90.0 | 3.2.2 |

### Acronym
Acronym for the product is **aks**.

## Description

Curated Module creates AKS Cluster as Private. Azure Kubernetes Service (AKS) simplifies deploying a managed Kubernetes cluster in Azure by offloading the operational overhead to Azure. As a hosted Kubernetes service, Azure handles critical tasks, like health monitoring and maintenance. Since Kubernetes masters are managed by Azure, you only manage and maintain the agent nodes. Thus, AKS is free; you only pay for the agent nodes within your clusters, not for the masters.
When you deploy an AKS cluster, the Kubernetes master and all nodes are deployed and configured for you. Advanced networking, Azure Active Directory (Azure AD) integration, monitoring, and other features can be configured during the deployment process.
For the creation of the Azure Kubernetes Service Cluster, the use of the kubernetes provider is required.

## Public Documentation
[Azure Azure Kubernetes Overview](https://docs.microsoft.com/es-es/azure/aks/intro-kubernetes)

## Dependencies
The following resources must exist before the deployment can take place:<br>
    • Azure Subscription.<br>
    • Resource Group.<br>
    • Azure Active Directory Tenant.<br>
    • Azure Key Vault.<br>
    • Log Analytics Workspace (formerly OMS) for health logs and metrics.<br>
    • A user or deployment Service Principal with owner permissions on the resource group where the aks will be created, with Santander Reader and Santander RBAC Contributor permissions in the Resource Group where exists the private DNS zone and the Virtual Network. It's needed Santander Join Network permission in the subnet used  to linked to the AKS Cluster (subnet_id variable).<br>
    • Review the user or deployment Service Principal has the following key permissions in the access policies of the Key Vault used: Recover, Get Rotation Policy and Delete.<br>
    • A existing Private zone DNS in a resolvable zone to associated it to resolve the AKS. In scenarios where the VNet containing your cluster  has custom DNS settings, cluster deployment fails unless the private DNS zone is linked to the VNet that contains the custom DNS resolvers. For custom DNS, please refer the [doc](https://docs.microsoft.com/en-us/azure/aks/private-clusters#hub-and-spoke-with-custom-dns).<br>
    • To install the flux extension for use GitOps (gitops_enabled to true), previously to launch the code the Microsoft.KubernetesConfiguration provider must be registred (run this Azure cli code with the properly permissions to do it: az provider register --namespace Microsoft.KubernetesConfiguration).<br>
    • It is necessary to have a subnet with enough free IP addresses to cover the number of pods required.<br>
    • It`s deprecated the managed property in azure_active_directory_role_based_access_control block of the azurerm_kubernetes_cluster resource in azurerm provider 3.* but it's not possible deleted because its a mandatory configuration. When the module will be adapted to use 4.* azurerm provider version will be deleted this property because it not supported. Atention if you use the 4.* azurerm provider version with this module it will be fail.<br>
    • If a key is created in the module, a rotation policy will be established. The key rotates every 90 days from its creation, which expires after 10 years (this is the maximum that Azure allows).<br><br> 

- Keep in mind that Azure Kubernetes Service has certain limits. <br>
    •	There is a maximum of 100 node pools per cluster.<br>
    •	A minimum of 10 pods and maximum of 250 pods per node.<br>
    •	Within a cluster there can be a maximum of 100 nodes, between all the groups of nodes.<br>

**IMPORTANT** Some resources, such as secret or key, can support a maximum of 15 tags.

## Architecture example:
![Diagram](documentation/architecture_diagram.png "Architecture diagram")

### Networking
![Diagram](documentation/network_diagram.png "Networking diagram")

## Additional information
### Access, security, and monitoring
For improved security and management, AKS lets you integrate with Azure AD to:
<ul>
<li> Use Kubernetes role-based access control (Kubernetes RBAC).
<li> Monitor the health of your cluster and resources.
<li> In case the user does not use sysdig, Azure Defender for Containers must be activated (The Azure Kubernetes Service add-on feature).
</ul>

### Authentication
![Diagram](documentation/authentication_diagram.png "Authentication diagram")
<br> 
**Kubernetes RBAC**
To limit access to cluster resources, AKS supports [Kubernetes RBAC](https://docs.microsoft.com/es-es/azure/aks/intro-kubernetes). Kubernetes RBAC controls access and permissions to Kubernetes resources and namespaces.

### Azure AD
You can configure an AKS cluster to integrate with Azure AD. With Azure AD integration, you can set up Kubernetes access based on existing identity and group membership. Your existing Azure AD users and groups can be provided with an integrated sign-on experience and access to AKS resources.

For more information on identity, see [Access and identity options for AKS](https://docs.microsoft.com/es-es/azure/aks/concepts-identity).

To secure your AKS clusters, see [Integrate Azure Active Directory with AKS](https://docs.microsoft.com/es-es/azure/aks/azure-ad-integration-cli).

### Network Security
Curated modules uses Azure CNI as default Network Configuration. For this implementation is recommended when AKS Cluster is deployed in a Level 2 Spoke (more performant than the kubenet virtualization). In case of Level 1 Spoke is used for Cluster deployment, Kubenet can to be used instead.

## Configuration
| Tf Name | Default Value | Type |Mandatory |Others |
|:--:|:--:|:--:|:--:|:--:|
| rsg_name | n/a | `string` | YES | The name of the Resource Group where the Kubernetes Nodes will be created. Changing this forces a new resource to be created. |
| location | `null` | `string` | NO | The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created. If not defined assumes the location of resource group. |
| subscription_id | `null` | `string` | NO | Specifies the supported Azure subscription where the resource will be deployed. If it's not set, it assumes the current subscription id. |
| aks_name | n/a | `string` | YES | The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created. |
| kubernetes_version | `null` | `string` | NO | Version of Kubernetes specified when creating the AKS managed cluster.\nIf not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). |
| sku_tier | `"Free"` | `string` | NO | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Changing this forces a new resource to be created. |
| automatic_channel_upgrade | `null` | `string` | NO | The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. |
| allowed_maintenance_window | `[]` | `list(object({day = string, hours = list(number)}))` | NO | An array of maintenance windows. Each maintenance window object has the following attributes: day: A day in a week. Possible values are Sunday, Monday, Tuesday, Wednesday, Thursday, Friday and Saturday; hours: An array of hour slots in a day. For example, Specifying [ 1, 2 ] will allow maintenance from 1:00am to 3:00m. |
| not_allowed_maintenance_window | `[]` | `list(object({start = string, end = string}))` | NO | An array of not maintenance windows. Each not maintenance window object has the following attributes: start: The start of a time span, formatted as an RFC3339 string; end: The end of a time span, formatted as an RFC3339 string. |
| attached_acr_id_map | `{}` | `mal(string)` | NO | Azure Container Registry ids that need an authentication mechanism with Azure Kubernetes Service (AKS). Map key must be static string as acr's name, the value is acr's resource id. Changing this forces some new resources to be created. |
| default_node_pool | `{subnet_id = null vm_size = null max_surge = "10%" os_disk_size = null min_count = null max_count = null max_pods = null agents_labels = null}` | `object({subnet_id = string vm_size = string max_surge = optional(string, "10%") os_disk_size = optional(number) min_count = number max_count = number max_pods = optional(number) agents_labels = map(string)})` | NO | Object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones. It consists of ==> subnet_id: (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created; vm_size: (Optional) The size of the Virtual Machine. If not set assumes the value Standard_DS2_v5; os_disk_size: (Optional) The size of the OS Disk which should be used for each agent in the Node Pool; max_surge: (Optional) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade. By default, it's 10%; os_disk_size: (Optional) The size of the OS Disk which should be used for each agent in the Node Pool; min_count: (Optional) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000. If not set assumes the value 2; max_count: (Optional) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000. If not set assumes the value 100; max_pods: (Optional) The maximum number of pods that can run on each agent. If not set assumes the value 110. Changing this forces a new resource to be created. temporary_name_for_rotation must be specified when changing this property; agents_labels: (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. |
| additional_node_pools | `{}` | `map(object({node_count = optional(number) tags = optional(map(string)) vm_size = string host_group_id = optional(string) capacity_reservation_group_id = optional(string) custom_ca_trust_enabled = optional(bool) eviction_policy = optional(string) fips_enabled = optional(bool) max_count = optional(number) max_pods = optional(number) min_count = optional(number) node_labels = optional(map(string)) node_taints = optional(list(string)) orchestrator_version = optional(string) os_disk_size_gb = optional(number) os_disk_type = optional(string, "Managed") priority = optional(string, "Regular") proximity_placement_group_id = optional(string) spot_max_price = optional(number) scale_down_mode = optional(string, "Delete") ultra_ssd_enabled = optional(bool) subnet_id = optional(string) upgrade_settings = optional(object({max_surge = string}))}))` | NO | A map of node pools that about to be created and attached on the Kubernetes cluster. The key of the map can be the name of the node pool, and the key must be static string. It consists of ==> node_count: (Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` (inclusive) for user pools and between `1` and `1000` (inclusive) for system pools and must be a value in the range `min_count`-`max_count`; tags: (Optional) A mapping of tags to assign to the resource; vm_size: (Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created; host_group_id: (Optional) The fully qualified resource ID of the Dedicated Host Group to provision virtual machines from. Changing this forces a new resource to be created; capacity_reservation_group_id: (Optional) Specifies the ID of the Capacity Reservation Group where this Node Pool should exist. Changing this forces a new resource to be created; custom_ca_trust_enabled: (Optional) Specifies whether to trust a Custom CA. This requires that the Preview Feature `Microsoft.ContainerService/CustomCATrustPreview` is enabled and the Resource Provider is re-registered, see [the documentation](https://learn.microsoft.com/en-us/azure/aks/custom-certificate-authority) for more information; eviction_policy: (Optional) The Eviction Policy which should be used for Virtual Machines within the Virtual Machine Scale Set powering this Node Pool. Possible values are `Deallocate` and `Delete`. Changing this forces a new resource to be created. An Eviction Policy can only be configured when `priority` is set to `Spot` and will default to `Delete` unless otherwise specified; fips_enabled: (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created. FIPS support is in Public Preview - more information and details on how to opt into the Preview can be found in [this article](https://docs.microsoft.com/azure/aks/use-multiple-node-pools#add-a-fips-enabled-node-pool-preview); max_count: (Optional) The maximum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be greater than or equal to `min_count`; max_pods: (Optional) The minimum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be less than or equal to `max_count`; min_count: (Optional) The minimum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be less than or equal to `max_count`; node_labels: (Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool; node_taints: (Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g `key=value:NoSchedule`). Changing this forces a new resource to be created; orchestrator_version: (Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact patch version to be specified, minor version aliases such as `1.22` are also supported. - The minor version's latest GA patch is automatically chosen in that case. More details can be found in [the documentation](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#alias-minor-version). This version must be supported by the Kubernetes Cluster - as such the version of Kubernetes used on the Cluster/Control Plane may need to be upgraded first; os_disk_size_gb: (Optional) The Agent Operating System disk size in GB. Changing this forces a new resource to be created; os_disk_type: (Optional) The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created; priority: (Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this forces a new resource to be created; proximity_placement_group_id: (Optional) The ID of the Proximity Placement Group where the Virtual Machine Scale Set that powers this Node Pool will be placed. Changing this forces a new resource to be created. When setting `priority` to Spot - you must configure an `eviction_policy`, `spot_max_price` and add the applicable `node_labels` and `node_taints` [as per the Azure Documentation](https://docs.microsoft.com/azure/aks/spot-node-pool); spot_max_price: (Optional) The maximum price you're willing to pay in USD per Virtual Machine. Valid values are `-1` (the current on-demand price for a Virtual Machine) or a positive value with up to five decimal places. Changing this forces a new resource to be created. This field can only be configured when `priority` is set to `Spot`; scale_down_mode: (Optional) Specifies how the node pool should deal with scaled-down nodes. Allowed values are `Delete` and `Deallocate`. Defaults to `Delete`; ultra_ssd_enabled: (Optional) Used to specify whether the UltraSSD is enabled in the Node Pool. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/use-ultra-disks) for more information. Changing this forces a new resource to be created; subnet_id: (Optional) The ID of the Subnet where this Node Pool should exist. Changing this forces a new resource to be created. A route table must be configured on this Subnet; upgrade_settings: Settings to upgrade node groups. (It consist of max_surge: (Required) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade.If a percentage is provided, the number of surge nodes is calculated from the node_count value on the current cluster. Node surge can allow a cluster to have more nodes than max_count during an upgrade. Ensure that your cluster has enough [IP space](https://learn.microsoft.com/azure/aks/upgrade-cluster?tabs=azure-cli#customize-node-surge-upgrade) during an upgrade). |
| auto_scaler_profile | `{balance_similar_node_groups = false expander = "random" max_graceful_termination_sec = 600 max_node_provisioning_time = "15m" max_unready_nodes = 3 max_unready_percentage = 45 new_pod_scale_up_delay = "0s" scale_down_delay_after_add = "10m" scale_down_delay_after_delete = "10s" scale_down_delay_after_failure = "3m" scan_interval = "10s" scale_down_unneeded = "10m" scale_down_unready = "20m" scale_down_utilization_threshold = "0.5" empty_bulk_delete_max = 10 skip_nodes_with_local_storage = false skip_nodes_with_system_pods = true}` | `object({ balance_similar_node_groups = bool expander = string max_graceful_termination_sec = number max_node_provisioning_time       = string max_unready_nodes = number max_unready_percentage = number new_pod_scale_up_delay = string scale_down_delay_after_add = string scale_down_delay_after_delete = string scale_down_delay_after_failure = string scan_interval = string scale_down_unneeded = string scale_down_unready = string scale_down_utilization_threshold = string empty_bulk_delete_max = number skip_nodes_with_local_storage = bool skip_nodes_with_system_pods = bool})` | NO | Object to configuate the autoscaler profile. It consists of ==> balance_similar_node_groups: (Optional) Detect similar node groups and balance the number of nodes between them. Defaults to false; expander: (Optional) Expander to use. Possible values are least-waste, priority, most-pods and random. Defaults to random; max_graceful_termination_sec: (Optional) Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to 600; max_node_provisioning_time: (Optional) Maximum time the autoscaler waits for a node to be provisioned. Defaults to 15m; max_unready_nodes: (Optional) Maximum Number of allowed unready nodes. Defaults to 3; max_unready_percentage: (Optional) Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to 45; new_pod_scale_up_delay: (Optional) For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to 0s; scale_down_delay_after_add: (Optional) How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to 10m; scale_down_delay_after_delete: (Optional) How long after node deletion that scale down evaluation resumes. Defaults to 10s; scale_down_delay_after_failure: (Optional) How long after scale down failure that scale down evaluation resumes. Defaults to 3m; scan_interval: (Optional) How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to 10s; scale_down_unneeded: (Optional) How long a node should be unneeded before it is eligible for scale down. Defaults to 10m; scale_down_unready: (Optional) How long an unready node should be unneeded before it is eligible for scale down. Defaults to 20m; scale_down_utilization_threshold: (Optional) Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to 0.5; empty_bulk_delete_max: (Optional) Maximum number of empty nodes that can be deleted at the same time. Defaults to 10; skip_nodes_with_local_storage: (Optional) If true cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to false; skip_nodes_with_system_pods: (Optional) If true cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to true. |
| rbac_aad_admin_group_object_ids | `null` | `list(string)` | NO | A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster. |
| exist_uai | `false` | `bool` | NO | Specifies whether the user-assigned identity name exists and will be used (true) or does not exist and will be created (false). Defaults to false. |
| gitops_enabled | `false` |`bool` | NO | Is required install the Flux extension to use GitOps? Defaults is false. |
| gitops_config | `{url = "https://github.com" tag = "" token_base64 = null kustomizations = {bootstrap = "null"}}` | `object({url = string reference_type = string reference_value = string token_base64 = string kustomizations = map(string)})` | NO | Set the value to config the Gitop connection to use the Flux extension. Required to configure with appropriate values ​​if gitops_enabled is true. It consists of ==> url: (Optional) Specifies the URL to sync for the flux configuration git repository. It must start with http://, https://, git@ or ssh://. Defaults to https://github.com; tag: (Optional) Specifies the source reference value for the tag. Defaults to aks_tag; token_base64: (Optional) Specifies the Base64-encoded HTTPS certificate authority contents used to access git private git repositories over HTTPS. Defaults to null; kustomizations: (Optional) Is a Map of key/value to set the group of desired kustomizations, the key specifies the name of the kustomization and the value specifies the path in the source reference to reconcile on the cluster. Defaults to {bootstrap = null}. |
| uai_name | `null` |`string`| NO | Specifies the name of User Assigned Identity that will be create or used if exist_uai is true or false. Changing this forces a new User Assigned Identity to be created if exist_uai is false. If exist_uai is false and this value is set the real name of the User Assigned Identity name will be \"<aks_name>-<uai_name>\", but if this value won't be set will be \"<aks_name>\". If exist_uai is true this value will be the real name and it must exist. The Resource Group to which the User Assigned Identity used belongs, whether existing or not (if exist_uai is true or false) will be the one indicated in rsg_name. |
| load_balancer_sku | `"standard"` | `string` | NO | Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are basic and standard. Defaults to standard. Changing this forces a new resource to be created. |
| http_proxy_config | `{http_proxy = null https_proxy = null no_proxy = null trusted_ca = null}` | `object({http_proxy = optional(string, null) https_proxy = optional(string,null) no_proxy = optional(set(string), null trusted_ca = string})` | NO | The proxy address to be used. It consists of ==>http_proxy: (Optional) The proxy address to be used when communicating over HTTP. Changing this forces a new resource to be created. If not set assumes the value http://proxy.sig.umbrella.com:80/; https_proxy: (Optional) The proxy address to be used when communicating over HTTPS. Changing this forces a new resource to be created. If not set assumes the value http://proxy.sig.umbrella.com:443/; no_proxy: (Optional) The list of domains that will not use the proxy for communication. If you specify subnet_id in default_node_pool, be sure to include the Subnet CIDR in the no_proxy list. If not set assumes the value [\".corp\", \"sts.gsnetcloud.com\", \".cluster.local.\", \".cluster.local\", \".svc\", \"10.112.0.0/16\"]; trusted_ca: (Optional) The base64 encoded alternative CA certificate content in PEM format. If not set assumes the PEM Cisco Umbrella CA in base64. |
| virtual_network_ids | `[]` | `list(string)` | NO | The ID map of the Virtual Network that should be linked to the DNS Zone. Changing this forces a new resource to be created. |
| dns_subscription_id | `null` | `string` | NO | The ID Subscription for Private DNS Zone. Required if the private DNS zone belongs to a different subscription than the AKS Cluster. |
| private_dns_zone_rsg_name | n/a | `string` | YES | The Name of the Resource Group where the Private DNS Zone exists. |
| private_dns_zone_name | n/a | `string` | YES | The name of the existing Private DNS Zone to use with the AKS Cluster. |
| dns_prefix | `null` | `string` | NO | DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created. If not set assumes the value of aks_name. |
| key_custom_enabled | `false` | `bool` | NO | Flag to determine if the encryption is customized or will be performed by Azure. |
| use_existing_des | `false` | `bool` | NO | Apply only if key_custom_enabled is true. Determines whether to use an existing Disk Encryption Set for encryption the VM or create one. Defaults to false, which will create a new one. |
| akv_id | `null` | `string` | NO | Specifies of the id of the key vault. Required only if key_custom_enabled is true, use_existing_des is false and akv_name is null. |
| akv_rsg_name | `null` | `string` | NO | Specifies of the common key vault resource group name. If not set, it assumes the rsg_name value. |
| akv_name | `null` | `string` | NO | Specifies the name of the key vault. Required if key_custom_enabled is true, use_existing_des is false and akv_id is null. |
| key_name | `null` | `string` | NO | Specifies the name of the key in a key vault. Required if key_custom_enabled is true and use_existing_des is false. |
| key_exist | `false` | `bool` | NO | Flag to determined if the encryption key exists or it must be created (by default). Only applies if key_custom_enabled is true and use_existing_des is false. |
| des_rsg_name | `null` | `string` | NO | The resource group name used for disks encryption. If not set, it assumes the rsg_name value. |
| des_name | `null` | `string` | NO | The disk encryption set base name used for disks encryption if use_existing_des is false des name will be <aks_name>-<des_name>, if use_existing_des is true the des name will be <des_name>. Required if key_custom_enabled is true. If use_existing_des is true it must exist, otherwise it will be created. |
| lwk_rsg_name| `null` | `string` | NO | The name of the resource group where the lwk is located. If is not set, it assumes the rsg_name value.|
| analytics_diagnostic_monitor_lwk_id | `null` | `string` | NO | Specifies the Id of a Log Analytics Workspace where Diagnostics Data should be sent. |
| lwk_name| `null` | `string` | NO | Specifies the name of a Log Analytics Workspace where Diagnostics Data should be sent. |
| analytics_diagnostic_monitor_name | `null` | `string` | NO | The name of the diagnostic monitor. Required if analytics_diagnostic_monitor_enabled is true. |
| analytics_diagnostic_monitor_enabled | `true` | `bool` | NO | Enable diagnostic monitor with true or false. |
| eventhub_authorization_rule_id | `null` | `string` | NO | Specifies the id of the Authorization Rule of Event Hub used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name. |
| analytics_diagnostic_monitor_aeh_namespace | `null` | `string` | NO | Specifies the name of an Event Hub Namespace used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_rsg. It will be ignored if eventhub_authorization_rule_id is defined. |
| analytics_diagnostic_monitor_aeh_name | `null` | `string` | NO | Specifies the name of the Event Hub where Diagnostics Data should be sent. Only applies if defined together with analytics_diagnostic_monitor_aeh_rsg and analytics_diagnostic_monitor_aeh_namespace or if defined together eventhub_authorization_rule_id. |
| analytics_diagnostic_monitor_aeh_rsg | `null` | `string` | NO | Specifies the name of the resource group where the Event Hub used to send Diagnostics Data is stored. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_namespace. It will be ignored if eventhub_authorization_rule_id is defined. |
| analytics_diagnostic_monitor_aeh_policy | `"RootManageSharedAccessKey"` | `string` | NO | Specifies the name of the event hub policy used to send diagnostic data. Defaults is RootManageSharedAccessKey. |
| analytics_diagnostic_monitor_sta_id | `null` | `string` | NO | Specifies the id of the Storage Account where logs should be sent. |
| analytics_diagnostic_monitor_sta_name | `null` | `string` | NO | Specifies the name of the Storage Account where logs should be sent. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_rsg is not null and analytics_diagnostic_monitor_sta_id is null. |
| analytics_diagnostic_monitor_sta_rsg | `null` | `string` | NO | Specifies the name of the resource group where Storage Account is stored. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_name is not null and analytics_diagnostic_monitor_sta_id is null. | 
| microsoft_defender_enabled | `true` | `bool` | NO | Is Microsoft Defender on the cluster enabled? If true, only applied if defender_lwk_id is set. |
| defender_lwk_id | `null` | `string` | NO | Specifies the ID of the Log Analytics Workspace where the audit logs collected by Microsoft Defender should be sent to. Required if microsoft_defender_enabled is true. |
| inherit | `true` | `bool` | NO | Inherits resource group tags. Values can be false or true (by default). |
| product | n/a | `string` | YES | The product tag will indicate the product to which the associated resource belongs to. In case shared_costs is Yes, product variable can be empty. |
| cost_center | n/a | `string` | YES | This tag will report the cost center of the resource. In case shared_costs is Yes, cost_center variable can be empty. |
| shared_costs | `"No"` | `string` | NO | Helps to identify costs which cannot be allocated to a unique cost center, therefore facilitates to detect resources which require subsequent cost allocation and cost sharing between different payers. |
| apm_functional | n/a | `string` | YES | Allows to identify to which functional application the resource belong, and its value must match with existing functional application code in Entity application portfolio management (APM) systems. In case shared_costs is Yes, apm_functional variable can be empty. |
| cia | n/a | `string` | YES | Confidentiality-Integrity-Availability. Allows a  proper data classification to be attached to the resource. |
| optional_tags | `{entity = null environment = null APM_technical = null business_service = null service_component = null description = null management_level = null AutoStartStopSchedule = null tracking_code = null Appliance = null Patch = null backup = null bckpolicy = null}` | `object({entity = optional(string) environment = optional(string) APM_technical = optional(string) business_service = optional(string)  service_component = optional(string) description = optional(string) management_level = optional(string) AutoStartStopSchedule = optional(string) tracking_code = optional(string) Appliance = optional(string) Patch = optional(string) backup = optional(string) bckpolicy = optional(string)})` | NO | A object with the [optional tags](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx?OR=Teams-HL&CT=1716801658655&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yNDA1MDMwNTAwMCIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D#optional-tags). These are: entity: (Optional) this tag allows to identify entity resources in a simpler and more flexible way than naming convention, facilitating cost reporting among others; environment: (Optional) this tag allows to identify to which environment belongs a resource in a simpler and more flexible way than naming convention, which is key, for example, to proper apply cost optimization measures; APM_technical: (Optional) this tag allows to identify to which technical application the resource belong, and its value must match with existing technical application code in entity application portfolio management (APM) systems; business_service: (Optional) this tag allows to identify to which Business Service the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); service_component: (Optional) this tag allows to identify to which Service Component the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); description: (Optional) this tag provides additional information about the resource function, the workload to which it belongs, etc; management_level: (Optional) this tag depicts the deployment model of the cloud service (IaaS, CaaS, PaaS and SaaS) and helps generate meaningful cloud adoption KPIs to track cloud strategy implementation, for example: IaaS vs. PaaS; AutoStartStopSchedule: (Optional) this tag facilitates to implement a process to automatically start/stop virtual machines according to a schedule. As part of global FinOps practice, there are scripts available to implement auto start/stop mechanisms; tracking_code: (Optional) this tag will allow matching of resources against other internal inventory systems; Appliance: (Optional) this tag identifies if the IaaS asset is an appliance resource. Hardening and agents installation cannot be installed on this resources; Patch: (Optional) this tag is used to identify all the assets operated by Global Public Cloud team that would be updated in the next maintenance window; backup: (Optional) used to define if backup is needed (yes/no value); bckpolicy: (Optional) (platinium_001, gold_001, silver_001, bronze_001) used to indicate the backup plan required for that resource. |
| custom_tags | `{}` | `map(string)` | NO | Custom (additional) tags for compliant. |

<br>

## Outputs
|Output Name| Output Value | Description |
|:--:|:--:|:--:|
| aks_name| azurerm_kubernetes_cluster.cluster_k8s.name| The name of the Azure Kubernetes Managed Cluster.|
| aks_id| azurerm_kubernetes_cluster.cluster_k8s.id| The Kubernetes Managed Cluster ID.|
| aks_location| azurerm_kubernetes_cluster.cluster_k8s.location| The location where the Azure Kubernetes Managed Cluster was created.|
| aks_fqdn| azurerm_kubernetes_cluster.cluster_k8s.fqdn| The FQDN of the Azure Kubernetes Managed Cluster.|
| aks_portal_fqdn|azurerm_kubernetes_cluster.cluster_k8s.portal_fqdn| The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Azure Kubernetes Managed Cluster.|
| aks_private_fqdn|azurerm_kubernetes_cluster.cluster_k8s.private_fqdn| The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Azure Kubernetes Managed Cluster.|
| aks_node_rsg| azurerm_kubernetes_cluster.cluster_k8s.node_resource_group| The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster.|
| aks_oidc_issuer_url| azurerm_kubernetes_cluster.cluster_k8s.oidc_issuer_url| The OIDC issuer URL that is associated with the Azure Kubernetes Managed Cluster.|
| aks_cluster_identity| try(azurerm_kubernetes_cluster.cluster_k8s.identity[0], null)| The identity block of the Azure Kubernetes Managed Cluster.|
| aks_kubelet_identity| azurerm_kubernetes_cluster.cluster_k8s.kubelet_identity| The kubelet identity block of the Azure Kubernetes Managed Cluster.|
| aks_network_profile| azurerm_kubernetes_cluster.cluster_k8s.network_profile| The Network Profile block of the Azure Kubernetes Managed Cluster.|
| aks_kube_config| azurerm_kubernetes_cluster.cluster_k8s.kube_config[0]| The kube config block of the Azure Kubernetes Managed Cluster. This value is sensitive, it's usable but not visible.|
| aks_kube_config_raw| azurerm_kubernetes_cluster.cluster_k8s.kube_config_raw| The raw kubernetes config to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools corresponding with the Azure Kubernetes Managed Cluster. This value is sensitive, it's usable but not visible.|
| aks_kube_admin_config| try(azurerm_kubernetes_cluster.cluster_k8s.kube_admin_config[0], "")| The kube admin config block of the Azure Kubernetes Managed Cluster. This value is sensitive, it's usable but not visible.|
| aks_kube_admin_config_raw| azurerm_kubernetes_cluster.cluster_k8s.kube_admin_config_raw| The raw Kubernetes config for the admin account to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools corresponding with the Azure Kubernetes Managed Cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled. This value is sensitive, it's usable but not visible.|
| aks_azure_policy_enabled| azurerm_kubernetes_cluster.cluster_k8s.azure_policy_enabled| Specifies if the Azure Policy Add-On is enabled or not for the Azure Kubernetes Managed Cluster.|
| aks_http_application_routing_enabled| azurerm_kubernetes_cluster.cluster_k8s.http_application_routing_enabled| Specifies if the HTTP Application Routing is enabled or not for the Azure Kubernetes Managed Cluster.|
| aks_http_application_routing_zone_name| azurerm_kubernetes_cluster.cluster_k8s.http_application_routing_zone_name != null ? azurerm_kubernetes_cluster.cluster_k8s.http_application_routing_zone_name : ""| The Zone Name of the HTTP Application Routing for the Azure Kubernetes Managed Cluster if the HTTP Application Routing is enabled.|
| aks_ingress_application_gateway_enabled| can(azurerm_kubernetes_cluster.cluster_k8s.ingress_application_gateway[0])| Specifies if the ingress application gateway is enabled or not for the Azure Kubernetes Managed Cluster.|
| aks_ingress_application_gateway| try(azurerm_kubernetes_cluster.cluster_k8s.ingress_application_gateway[0], null)| The ingress application gateway configuration for the Azure Kubernetes Managed Cluster if it's enabled.|
| aks_key_vault_secrets_provider_enabled| can(azurerm_kubernetes_cluster.cluster_k8s.key_vault_secrets_provider[0])| Specifies if the Key Vault secrets provider is enabled or not for the Azure Kubernetes Managed Cluster.|
| aks_key_vault_secrets_provider| try(azurerm_kubernetes_cluster.cluster_k8s.key_vault_secrets_provider[0], null)| The Key Vault secrets provider configuration for the Azure Kubernetes Managed Cluster if it's enabled.|
| aks_oms_agent_enabled| can(azurerm_kubernetes_cluster.cluster_k8s.oms_agent[0])| Specifies if the OMS Agent is enabled or not for the Azure Kubernetes Managed Cluster.|
| aks_oms_agent| try(azurerm_kubernetes_cluster.cluster_k8s.oms_agent[0], null)| The OMS Agent configuration for the Azure Kubernetes Managed Cluster if it's enabled.|
| aks_open_service_mesh_enabled| azurerm_kubernetes_cluster.cluster_k8s.open_service_mesh_enabled| Specifies if the Open Service Mesh is enabled or not for the Azure Kubernetes Managed Cluster.|
<br>

## Usage
Include the next code into your main.tf file:
```hcl
module "aks" {

  source  = "<aks module source>"
  version = "<aks module version>"

  providers = {
    azurerm                 = azurerm
    azurerm.dnssubscription = azurerm.dnssubscription
  }

  // COMMON VARIABLES
  rsg_name                                    = var.rsg_name                                      # Required

  // PRODUCT 
  aks_name                                    = var.aks_name                                      # Required
  location                                    = var.location                                      # Optional
  subscription_id                             = var.subscription_id                               # Optional
  kubernetes_version                          = var.kubernetes_version                            # Optional
  sku_tier                                    = var.sku_tier                                      # Optional
  automatic_channel_upgrade                   = var.automatic_channel_upgrade                     # Optional
  allowed_maintenance_window                  = var.allowed_maintenance_window                    # Optional
  not_allowed_maintenance_window              = var.not_allowed_maintenance_window                # Optional
  attached_acr_id_map                         = var.attached_acr_id_map                           # Optional
  default_node_pool                           = var.default_node_pool                             # Optional
  additional_node_pools                       = var.additional_node_pools                         # Optional
  auto_scaler_profile                         = var.auto_scaler_profile                           # Optional
  rbac_aad_admin_group_object_ids             = var.rbac_aad_admin_group_object_ids               # Optional

  //GITOPS
  gitops_enabled                              = var.gitops_enabled                                # Optional 
  gitops_config                               = var.gitops_config                                 # Required if gitops_enabled is true

  // ASSIGNED IDENTITY
  exist_uai                                   = var.exist_uai                                     # Optional
  uai_name                                    = var.uai_name                                      # Optional

  // VIRTUAL NETWORK
  load_balancer_sku                           = var.load_balancer_sku                             # Optional
  http_proxy_config                           = var.http_proxy_config                             # Optional
  virtual_network_ids                         = var.virtual_network_ids                           # Optional

  //Private DNS Zone
  dns_subscription_id                         = var.dns_subscription_id                           # Optional
  private_dns_zone_rsg_name                   = var.private_dns_zone_rsg_name                     # Required
  private_dns_zone_name                       = var.private_dns_zone_name                         # Required
  dns_prefix                                  = var.dns_prefix                                    # Optional

  // Key Custom & Disk Encryption Set
  key_custom_enabled                          = var.key_custom_enabled                            # Optional
  use_existing_des                            = var.use_existing_des                              # Optional
  akv_id                                      = var.akv_id                                        # Required if key_custom_enabled is true, use_existing_des is false and akv_name is null
  akv_rsg_name                                = var.akv_rsg_name                                  # Optional
  akv_name                                    = var.akv_name                                      # Required if key_custom_enabled is true, use_existing_des is false and akv_id is null
  key_name                                    = var.key_name                                      # Required if key_custom_enabled is true and use_existing_des is false
  key_exist                                   = var.key_exist                                     # Optional
  des_rsg_name                                = var.des_rsg_name                                  # Optional
  des_name                                    = var.des_name                                      # Required if key_custom_enabled is true

  // MONITOR DIAGNOSTICS SETTINGS
  lwk_rsg_name                                = var.lwk_rsg_name                                  # Optional
  analytics_diagnostic_monitor_lwk_id         = var.analytics_diagnostic_monitor_lwk_id           # Optional
  lwk_name                                    = var.lwk_name                                      # Optional
  analytics_diagnostic_monitor_name           = var.analytics_diagnostic_monitor_name             # Required if analytics_diagnostic_monitor_enabled is true
  analytics_diagnostic_monitor_enabled        = var.analytics_diagnostic_monitor_enabled          # Optional
  eventhub_authorization_rule_id              = var.eventhub_authorization_rule_id                # Optional
  analytics_diagnostic_monitor_aeh_namespace  = var.analytics_diagnostic_monitor_aeh_namespace    # Optional
  analytics_diagnostic_monitor_aeh_name       = var.analytics_diagnostic_monitor_aeh_name         # Optional
  analytics_diagnostic_monitor_aeh_rsg        = var.analytics_diagnostic_monitor_aeh_rsg          # Optional
  analytics_diagnostic_monitor_aeh_policy     = var.analytics_diagnostic_monitor_aeh_policy       # Optional
  analytics_diagnostic_monitor_sta_id         = var.analytics_diagnostic_monitor_sta_id           # Optional
  analytics_diagnostic_monitor_sta_name       = var.analytics_diagnostic_monitor_sta_name         # Optional
  analytics_diagnostic_monitor_sta_rsg        = var.analytics_diagnostic_monitor_sta_rsg          # Optional
  microsoft_defender_enabled                  = var.microsoft_defender_enabled                    # Optional
  defender_lwk_id                             = var.defender_lwk_id                               # Required if microsoft_defender_enabled is true

  // TAGGING
  inherit                                     = var.inherit                                       # Optional
  product                                     = var.product                                       # Required if shared_costs is No.
  cost_center                                 = var.cost_center                                   # Required if shared_costs is No.
  shared_costs                                = var.shared_costs                                  # Optional
  apm_functional                              = var.apm_functional                                # Optional
  cia                                         = var.cia                                             # Required
  optional_tags                               = var.optional_tags                                 # Optional
  custom_tags                                 = var.custom_tags                                     # Optional
}
```

If you need user another subscription for Private DNS Zones, include the next code into your versions.tf file: Example file: documentation/examples/versions.tf

Include the next code into your outputs.tf file:

```hcl

output "aks_name" {
  description = "The name of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_name
}

output "aks_id" {
  description = "The ID of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_id
}

output "aks_location" {
  description = "The location where the Azure Kubernetes Managed Cluster was created."
  value       = module.aks.aks_location
}

output "aks_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_fqdn
}

output "aks_portal_fqdn" {
  description = "The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_portal_fqdn
}

output "aks_private_fqdn" {
  description = "The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_private_fqdn
}

output "aks_node_rsg" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  value       = module.aks.aks_node_rsg
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_oidc_issuer_url
}

output "aks_cluster_identity" {
  description = "The identity block of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_cluster_identity
}

output "aks_kubelet_identity" {
  description = "The kubelet identity block of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_kubelet_identity
}

output "aks_network_profile" {
  description = "The Network Profile block of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_network_profile
}

output "aks_kube_config" {
  description = "The kube config block of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_kube_config
  sensitive   = true
}

output "aks_kube_config_raw" {
  description = "The raw kubernetes config to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools corresponding with the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_kube_config_raw
  sensitive   = true
}

output "aks_kube_admin_config" {
  description = "The kube admin config block of the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_kube_admin_config
  sensitive   = true
}

output "aks_kube_admin_config_raw" {
  description = "The raw Kubernetes config for the admin account to be used by [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and other compatible tools corresponding with the Azure Kubernetes Managed Cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled."
  value       = module.aks.aks_kube_admin_config_raw
  sensitive   = true
}

output "aks_azure_policy_enabled" {
  description = "Specifies if the Azure Policy Add-On is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_azure_policy_enabled
}

output "aks_http_application_routing_enabled" {
  description = "Specifies if the HTTP Application Routing is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_http_application_routing_enabled
}

output "aks_http_application_routing_zone_name" {
  description = "The Zone Name of the HTTP Application Routing for the Azure Kubernetes Managed Cluster if the HTTP Application Routing is enabled."
  value       = module.aks.aks_http_application_routing_zone_name
}

output "aks_http_application_routing_zone_name" {
  description = "The Zone Name of the HTTP Application Routing for the Azure Kubernetes Managed Cluster if the HTTP Application Routing is enabled."
  value       = module.aks.aks_http_application_routing_zone_name
}

output "aks_ingress_application_gateway_enabled" {
  description = "Specifies if the ingress application gateway is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_ingress_application_gateway_enabled
}

output "aks_ingress_application_gateway" {
  description = "The ingress application gateway configuration for the Azure Kubernetes Managed Cluster if it's enabled."
  value       = module.aks.aks_ingress_application_gateway
}

output "aks_key_vault_secrets_provider_enabled" {
  description = "Specifies if the Key Vault secrets provider is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_key_vault_secrets_provider_enabled
}

output "aks_key_vault_secrets_provider" {
  description = "The Key Vault secrets provider configuration for the Azure Kubernetes Managed Cluster if it's enabled."
  value       = module.aks.aks_key_vault_secrets_provider
}

output "aks_oms_agent_enabled" {
  description = "Specifies if the OMS Agent is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_oms_agent_enabled
}

output "aks_oms_agent" {
  description = "The OMS Agent configuration for the Azure Kubernetes Managed Cluster if it's enabled."
  value       = module.aks.aks_oms_agent
}

output "aks_open_service_mesh_enabled" {
  description = "Specifies if the Open Service Mesh is enabled or not for the Azure Kubernetes Managed Cluster."
  value       = module.aks.aks_open_service_mesh_enabled
}
```

* You can watch more details about [ aks configuration parameters](/variables.tf).

# **Security Framework**
This section explains how the different aspects to have into account in order to meet the Security Control Framework for this Certified Service.

## Security Controls based on Security Control Framework

### Foundation (**F**) Controls for Rated Workloads
|SF#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SF1|IAM on all accounts|Azure Kubernetes Service is integrated with AzureAD|CCoE Entity|
|SF2|MFA on account|Azure Kubernetes Service is integrated with AzureAD|CISO CCoE Entity|
|SF3|Platform Activity Logs & Security Monitoring|The diagnostic settings are configured to send logs to Azure Monitor|CISO CCoE Entity|
|SF4|Malware Protection on IaaS|N/A|CISO CCoE Entity|
|SF5|Authenticate all connections|Kubernetes API server uses AzureAD as the identity provider. Azure AD authentication is provided to AKS clusters with OpenID Connect. OpenID Connect is an identity layer built based on the OAuth 2.0 protocol. |CCoE Entity|
|SF6|Isolated environments at network level|IP firewall: Normally it is the inbound controller that is responsible for distributing traffic to services and applications.Private Link for AKS: Always use a Private Azure Kubernetes cluster. Use it to isolate the Kubernetes API server within your Azure virtual network.All inbound/outbound traffic will be restricted by the cluster/node security group.All internal traffic will be restricted by the Kubernetes network policies|CISO CCoE Entity|
|SF7|Security Configuration & Patch Management|Since this is a PaaS service, product upgrade and patching is done by CSP|CCoE Entity|
|SF8.1|Privileged User Accounts|This is governed by Azure AD|CISO / Delivery Team|
|SF8.2| Service Accounts | If you want to use a service account, you must go through the corresponding flow	|Ciso / Delivery Team|
|SF9| Cyber incidents management | Entity must support Cyber Security operations responding to incidents. |Ciso / Entity|
### Application (**P**) Controls for Rated Workloads
|SP#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SP1|IAM - Assets identification and tagging|Azure Kubernetes Service is integrated with AzureAD|CISO CCoE|
|SP2|Segregation of Duties|Segregation of duties must be done by using RBAC|CISO CCoE Entity|
|SP3.1|Vulnerability Management|Because this is a PaaS service, Vulnerability Management is done by CSD|CISO CCoE Entity|
|SP3.2|Vulnerability Scanning for Virtual Machines|N/A|CISO CCoE Entity|
|SP3.3|Vulnerability Scanning for managed Services|Detect is responsible for vulnerability scanning of public endpoints|CISO CCoE Entity|
|SP4|Service Logs and Security Monitoring|The diagnostic settings are configured to send logs to Azure Monitor|CISO CCoE Entity|
|SP5|Network Security|IP firewall: Normally it is the inbound controller that is responsible for distributing traffic to services and applications.Private Link for AKS: Always use a Private Azure Kubernetes cluster. Use it to isolate the Kubernetes API server within your Azure virtual network.All inbound/outbound traffic will be restricted by the cluster/node security group.All internal traffic will be restricted by the Kubernetes network policies|CISO CCoE Entity|
|SP6|Advanced Malware Protection on IaaS|Since this is a PaaS service, Malware Protection on IaaS doesn't apply|CISO CCoE Entity|
|SP7|Encrypt data in transit over public interconnections|HTTPS is used for management and outbound traffic. TLS is used for pod to pod traffic and for inbound traffic.|Delivery Team / Entity|
|SP8|Static Application Security Testing|N/A|Entity|
|SP9|Data life-Cycle Protection|The life cycle of the data is under the protection of the element used|CISO / Delivery Team / Workload Team - Service Manager|
|SP10|Secure Software Deveopment lifecycle |N/A|CISO / Business Owner / Administrator / T&O Project Manager|
|SP11|Threat Model ( para IaaS )|N/A|Entity|
|SP12|Security Configuration & Patch Management| Since this is a PaaS service, product upgrade and patching is done by CSP| Delivery Team / IT Administrators Entity |
|SP13| Data Loss Prevention|N/A|eCISO (DLP Analyst)/Protect(DLP Administrator)/Global SOC(DLP Analyst)|
|SP13.1|Data loss prevention - email|N/A|eCISO (DLP Analyst)/Protect(DLP Administrator)/Global SOC(DLP Analyst)|
|SP13.2|Data loss prevention -navigation|N/A|eCISO (DLP Analyst)/Protect(DLP Administrator)/Global SOC(DLP Analyst)|
|SP13.3|Data loss prevention - User corporate device |N/A|eCISO (DLP Analyst)/Protect(DLP Administrator)/Global SOC(DLP Analyst)|
|SP14|Email sending service|N/A|eCISO / Protect / Detect / Respond| 
### Medium (**M**) Controls for Rated Workloads
|SM#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SM1|IAM|Azure Kubernetes Service is integrated with AzureAD|CCoE / Entity|
|SM2|Encrypt data at rest|With host-based encryption, the data stored on the VM host of your AKS agent nodes' VMs is encrypted at rest and flows encrypted to the Storage service|CCoE|
|SM3| Encrypt data in transit over private interconections|HTTPS is used for management and outbound traffic. TLS is used for pod to pod traffic and for inbound traffic.|CCoE / Entity|
|SM4|Control resource geographical location|The service can be deployed in any of the regions where it is available|CISO CCoE|
|SM5|Production real data in non-production environments|The use of Azure AI Content Safety with real data should not be used in non-production environments. If necessary, obfuscation or anonymization techniques should be applied to the data.|T&O Project Manager|
### Advanced (**A**) Controls for Rated Workloads
|SA#|What|How it is implemented in the Product|Who|
|:--:|:---:|:---:|:--:|
|SA1|IAM|Azure Kubernetes Service is integrated with AzureAD|CCoE Entity|
|SA2|Encrypt data at rest|With host-based encryption, the data stored on the VM host of your AKS agent nodes' VMs is encrypted at rest and flows encrypted to the Storage service|CCoE|
|SA3|Encrypt data in transit over private interconnections|	HTTPS is used for management and outbound traffic. TLS is used for pod to pod traffic and for inbound traffic.|CCoE / Entity|
|SA4|Santander managed keys with HSM and BYOK|Any environment that has data classified as Secret or restricted confidentiality use BYOK in KMS.For encryption on EBS and local disk also use the same encryption with keys in KMS|CISO / CCoE / Entity|
|SA5|Control resource geographical location|The service can be deployed in any of the regions where it is available|CISO CCoE|
|SA6|Cardholder and auth sensitive data|Entity is responsable to identify workloads and components processing cardholder and auth sensitive data and apply the security measures to comply with the Payment Card Industry Data Security Standard (PCI-DSS).|Entity|
|SA7|MFA on user access to data|Azure Kubernetes Service is integrated with AzureAD|CISO / CCoE / Entity|
|SA8|Production real data in non-production environments|The use of Azure AI Content Safety with real data should not be used in non-production environments. If necessary, obfuscation or anonymization techniques should be applied to the data.|T&O Project Manager|
# **Basic tf files description**
This section explain the structure and elements that represent the artifacts of product.
|Folder|Name|Description
|:--:|:--:|:--:|
|Documentation|architecture_diagram.png|Architecture diagram|
|Documentation|networking_diagram.png|Network topology diagram|
|Documentation|authentication_diagram.png|Authentication Diagram|
|Documentation|examples|terraform.tfvars|
|Root|README.md|Product documentation file|
|Root|CHANGELOG.md|Contains the changes added to the new versions of the modules|
|Root|main.tf|Terraform file to use in pipeline to build and release a product|
|Root|outputs.tf|Terraform file to use in pipeline to check output|
|Root|variables.tf|Terraform file to use in pipeline to configure product|

### Target Audience
|Audience |Purpose  |
|:--:|:--:|
| Cloud Center of Excellence | Understand the Design of this Service. |
| Cybersecurity Hub | Understand how the Security Framework is implemented in this Service and who is responsible of each control. |
| Service Management Hub | Understand how the Service can be managed according to the Service Management Framework. |


# **Links to internal documentation**
**Reference documents** :
- [List of Acronyms](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx)
- [Product Portfolio](https://github.alm.europe.cloudcenter.corp/pages/sgt-cloudplatform/documentationGlobalHub/eac-az-portfolio.html)


| Template version | 
|:-----:|
| 1.0.13 |
