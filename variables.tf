// COMMON VARIABLES
variable "rsg_name" {
  type        = string
  description = "(Required) The name of the Resource Group where the Kubernetes Nodes will be created. Changing this forces a new resource to be created."
}

// PRODUCT
# AKS Cluster
variable "aks_name" {
  type        = string
  description = " (Required) The name of the Managed Kubernetes Cluster to create. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "(Optional) The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created. If not defined assumes the location of resource group."
  default     = null
}

variable "subscription_id" {
  type        = string
  description = "(Optional) Specifies the supported Azure subscription where the resource will be deployed. If it's not set, it assumes the current subscription id."
  default     = null
}

variable "kubernetes_version" {
  type        = string
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster.\nIf not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  default     = null
}

variable "sku_tier" {
  type        = string
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Changing this forces a new resource to be created."
  default     = "Free"
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable."
  default     = null
  validation {
    condition = var.automatic_channel_upgrade == null || contains(["patch", "rapid", "node-image", "stable"], coalesce(var.automatic_channel_upgrade, "patch"))
    #condition     = length(regexall("^(null|patch|rapid|node-image|stable)$", var.automatic_channel_upgrade)) > 0
    error_message = "ERROR: Valid types are \"patch\", \"rapid\", \"node-image\" and \"stable\"!"
  }
}

variable "allowed_maintenance_window" {
  type = list(object({
    day   = string,
    hours = list(number)
  }))
  description = "(Optional) An array of maintenance windows. Each maintenance window object has the following attributes: day: A day in a week. Possible values are Sunday, Monday, Tuesday, Wednesday, Thursday, Friday and Saturday; hours: An array of hour slots in a day. For example, Specifying [ 1, 2 ] will allow maintenance from 1:00am to 3:00m."
  default     = []
}

variable "not_allowed_maintenance_window" {
  type = list(object({
    start = string,
    end   = string
  }))
  description = "(Optional) An array of not maintenance windows. Each not maintenance window object has the following attributes: start: The start of a time span, formatted as an RFC3339 string; end: The end of a time span, formatted as an RFC3339 string."
  default     = []
}

variable "attached_acr_id_map" {
  type        = map(string)
  description = "(Optional) Azure Container Registry ids that need an authentication mechanism with Azure Kubernetes Service (AKS). Map key must be static string as acr's name, the value is acr's resource id. Changing this forces some new resources to be created."
  default     = {}
  nullable    = false
}


//AGENT POOL PROFILE
variable "default_node_pool" {
  type = object({
    subnet_id     = string
    vm_size       = string
    max_surge     = optional(string, "10%")
    os_disk_size  = optional(number)
    min_count     = number
    max_count     = number
    max_pods      = optional(number)
    agents_labels = map(string)
  })
  description = "(Optional) Object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones. It consists of ==> subnet_id: (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created; vm_size: (Optional) The size of the Virtual Machine. If not set assumes the value Standard_DS2_v5; os_disk_size: (Optional) The size of the OS Disk which should be used for each agent in the Node Pool;  max_surge: (Optional) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade. By default, it's 10%; os_disk_size: (Optional) The size of the OS Disk which should be used for each agent in the Node Pool; min_count: (Optional) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000. If not set assumes the value 2; max_cont: (Optional) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000. If not set assumes the value 100; max_pods: (Optional) The maximum number of pods that can run on each agent. If not set assumes the value 110. Changing this forces a new resource to be created. temporary_name_for_rotation must be specified when changing this property; agents_labels: (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool."
  default = {
    subnet_id     = null
    vm_size       = null
    max_surge     = "10%"
    os_disk_size  = null
    min_count     = null
    max_count     = null
    max_pods      = null
    agents_labels = null
  }
}

variable "additional_node_pools" {
  type = map(object({
    node_count = optional(number)
    tags       = optional(map(string))
    # At this time there's a bug in the AKS API where Tags for a Node Pool are not stored in the correct case and a ignore_changes Terraform's will be to use to ignore changes to the casing (https://www.terraform.io/language/meta-arguments/lifecycle#ignore_changess) until this is fixed in the AKS API.
    vm_size                       = string
    host_group_id                 = optional(string)
    capacity_reservation_group_id = optional(string)
    custom_ca_trust_enabled       = optional(bool)
    eviction_policy               = optional(string)
    fips_enabled                  = optional(bool)
    max_count                     = optional(number)
    max_pods                      = optional(number)
    min_count                     = optional(number)
    node_labels                   = optional(map(string))
    node_taints                   = optional(list(string))
    orchestrator_version          = optional(string)
    os_disk_size_gb               = optional(number)
    os_disk_type                  = optional(string, "Managed")
    priority                      = optional(string, "Regular")
    proximity_placement_group_id  = optional(string)
    spot_max_price                = optional(number)
    scale_down_mode               = optional(string, "Delete")
    ultra_ssd_enabled             = optional(bool)
    subnet_id                     = optional(string)
    upgrade_settings = optional(object({
      max_surge = string
    }))
  }))
  description = "(Optional) A map of node pools that about to be created and attached on the Kubernetes cluster. The key of the map can be the name of the node pool, and the key must be static string. It consists of ==> node_count: (Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` (inclusive) for user pools and between `1` and `1000` (inclusive) for system pools and must be a value in the range `min_count` - `max_count`; tags: (Optional) A mapping of tags to assign to the resource; vm_size: (Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created; host_group_id: (Optional) The fully qualified resource ID of the Dedicated Host Group to provision virtual machines from. Changing this forces a new resource to be created; capacity_reservation_group_id: (Optional) Specifies the ID of the Capacity Reservation Group where this Node Pool should exist. Changing this forces a new resource to be created; custom_ca_trust_enabled: (Optional) Specifies whether to trust a Custom CA. This requires that the Preview Feature `Microsoft.ContainerService/CustomCATrustPreview` is enabled and the Resource Provider is re-registered, see [the documentation](https://learn.microsoft.com/en-us/azure/aks/custom-certificate-authority) for more information; eviction_policy: (Optional) The Eviction Policy which should be used for Virtual Machines within the Virtual Machine Scale Set powering this Node Pool. Possible values are `Deallocate` and `Delete`. Changing this forces a new resource to be created. An Eviction Policy can only be configured when `priority` is set to `Spot` and will default to `Delete` unless otherwise specified; fips_enabled: (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created. FIPS support is in Public Preview - more information and details on how to opt into the Preview can be found in [this article](https://docs.microsoft.com/azure/aks/use-multiple-node-pools#add-a-fips-enabled-node-pool-preview); max_count: (Optional) The maximum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be greater than or equal to `min_count`; max_pods: (Optional) The minimum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be less than or equal to `max_count`; min_count: (Optional) The minimum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be less than or equal to `max_count`; node_labels: (Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool; node_taints: (Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g `key=value:NoSchedule`). Changing this forces a new resource to be created; orchestrator_version: (Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact patch version to be specified, minor version aliases such as `1.22` are also supported. - The minor version's latest GA patch is automatically chosen in that case. More details can be found in [the documentation](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#alias-minor-version). This version must be supported by the Kubernetes Cluster - as such the version of Kubernetes used on the Cluster/Control Plane may need to be upgraded first; os_disk_size_gb: (Optional) The Agent Operating System disk size in GB. Changing this forces a new resource to be created; os_disk_type: (Optional) The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created; priority: (Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this forces a new resource to be created; proximity_placement_group_id: (Optional) The ID of the Proximity Placement Group where the Virtual Machine Scale Set that powers this Node Pool will be placed. Changing this forces a new resource to be created. When setting `priority` to Spot - you must configure an `eviction_policy`, `spot_max_price` and add the applicable `node_labels` and `node_taints` [as per the Azure Documentation](https://docs.microsoft.com/azure/aks/spot-node-pool); spot_max_price: (Optional) The maximum price you're willing to pay in USD per Virtual Machine. Valid values are `-1` (the current on-demand price for a Virtual Machine) or a positive value with up to five decimal places. Changing this forces a new resource to be created. This field can only be configured when `priority` is set to `Spot`; scale_down_mode: (Optional) Specifies how the node pool should deal with scaled-down nodes. Allowed values are `Delete` and `Deallocate`. Defaults to `Delete`; ultra_ssd_enabled: (Optional) Used to specify whether the UltraSSD is enabled in the Node Pool. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/use-ultra-disks) for more information. Changing this forces a new resource to be created; subnet_id: (Optional) The ID of the Subnet where this Node Pool should exist. Changing this forces a new resource to be created. A route table must be configured on this Subnet; upgrade_settings: Settings to upgrade node groups. (It consist of max_surge: (Required) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade.If a percentage is provided, the number of surge nodes is calculated from the node_count value on the current cluster. Node surge can allow a cluster to have more nodes than max_count during an upgrade. Ensure that your cluster has enough [IP space](https://learn.microsoft.com/azure/aks/upgrade-cluster?tabs=azure-cli#customize-node-surge-upgrade) during an upgrade)."
  default     = {}
  nullable    = false
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = bool
    expander                         = string
    max_graceful_termination_sec     = number
    max_node_provisioning_time       = string
    max_unready_nodes                = number
    max_unready_percentage           = number
    new_pod_scale_up_delay           = string
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scan_interval                    = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
    empty_bulk_delete_max            = number
    skip_nodes_with_local_storage    = bool
    skip_nodes_with_system_pods      = bool
  })
  description = "(Optional) Object to configuate the autoscaler profile. It consists of ==> balance_similar_node_groups: (Optional) Detect similar node groups and balance the number of nodes between them. Defaults to false; expander: (Optional) Expander to use. Possible values are least-waste, priority, most-pods and random. Defaults to random; max_graceful_termination_sec: (Optional) Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to 600; max_node_provisioning_time: (Optional) Maximum time the autoscaler waits for a node to be provisioned. Defaults to 15m; max_unready_nodes: (Optional) Maximum Number of allowed unready nodes. Defaults to 3; max_unready_percentage: (Optional) Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to 45; new_pod_scale_up_delay: (Optional) For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to 0s; scale_down_delay_after_add: (Optional) How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to 10m; scale_down_delay_after_delete: (Optional) How long after node deletion that scale down evaluation resumes. Defaults to 10s; scale_down_delay_after_failure: (Optional) How long after scale down failure that scale down evaluation resumes. Defaults to 3m; scan_interval: (Optional) How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to 10s; scale_down_unneeded: (Optional) How long a node should be unneeded before it is eligible for scale down. Defaults to 10m; scale_down_unready: (Optional) How long an unready node should be unneeded before it is eligible for scale down. Defaults to 20m; scale_down_utilization_threshold: (Optional) Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to 0.5; empty_bulk_delete_max: (Optional) Maximum number of empty nodes that can be deleted at the same time. Defaults to 10; skip_nodes_with_local_storage: (Optional) If true cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to false; skip_nodes_with_system_pods: (Optional) If true cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to true."
  default = {
    balance_similar_node_groups      = false
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "0s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = "0.5"
    empty_bulk_delete_max            = 10
    skip_nodes_with_local_storage    = false
    skip_nodes_with_system_pods      = true
  }
}


variable "rbac_aad_admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  type        = list(string)
  default     = null
}

//GITOPS
variable "gitops_enabled" {
  type        = bool
  description = "(optional) Is required install the Flux extension to use GitOps? Defaults is false."
  default     = false
}

variable "gitops_config" {
  type = object({
    url            = string
    tag            = string
    token_base64   = string
    kustomizations = map(string)
  })
  description = "(optional) Set the value to config the Gitop connection to use the Flux extension. Required to configure with appropriate values ​​if gitops_enabled is true. It consists of ==> url: (Optional) Specifies the URL to sync for the flux configuration git repository. It must start with http://, https://, git@ or ssh://. Defaults to https://github.com; tag: (Optional) Specifies the source reference value for the tag. Defaults to aks_tag; token_base64: (Optional) Specifies the Base64-encoded HTTPS certificate authority contents used to access git private git repositories over HTTPS. Defaults to null; kustomizations: (Optional) Is a Map of key/value to set the group of desired kustomizations, the key specifies the name of the kustomization and the value specifies the path in the source reference to reconcile on the cluster. Defaults to {bootstrap = null}."
  default = {
    url          = "https://github.com"
    tag          = "aks_tag"
    token_base64 = null
    kustomizations = {
      bootstrap = null
    }
  }
}


// ASSIGNED IDENTITY
variable "exist_uai" {
  type        = bool
  description = "(Optional) Specifies whether the user-assigned identity name exists and will be used (true) or does not exist and will be created (false). Defaults to false."
  default     = false
}
variable "uai_name" {
  type        = string
  description = "(Optional) Specifies the name of User Assigned Identity that will be create or used if exist_uai is true or false. Changing this forces a new User Assigned Identity to be created if exist_uai is false. If exist_uai is false and this value is set the real name of the User Assigned Identity name will be \"<aks_name>-<uai_name>\", but if this value won't be set will be \"<aks_name>\". If exist_uai is true this value will be the real name and it must exist. The Resource Group to which the User Assigned Identity used belongs, whether existing or not (if exist_uai is true or false) will be the one indicated in rsg_name."
  default     = null
}

variable "load_balancer_sku" {
  type    = string
  description = "(Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are basic and standard. Defaults to standard. Changing this forces a new resource to be created."
  default = "standard"
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string, null)
    https_proxy = optional(string, null)
    no_proxy    = optional(set(string), null)
    trusted_ca  = optional(string, null)
  })
  description = "(Optional) The proxy address to be used. It consists of ==>http_proxy: (Optional) The proxy address to be used when communicating over HTTP. Changing this forces a new resource to be created. If not set assumes the value http://proxy.sig.umbrella.com:80/; https_proxy: (Optional) The proxy address to be used when communicating over HTTPS. Changing this forces a new resource to be created. If not set assumes the value http://proxy.sig.umbrella.com:443/; no_proxy: (Optional) The list of domains that will not use the proxy for communication. If you specify subnet_id in default_node_pool, be sure to include the Subnet CIDR in the no_proxy list. If not set assumes the value [\".corp\", \"sts.gsnetcloud.com\", \".cluster.local.\", \".cluster.local\", \".svc\", \"10.112.0.0/16\"]; trusted_ca: (Optional) The base64 encoded alternative CA certificate content in PEM format. If not set assumes the PEM Cisco Umbrella CA in base64."
  default = {
    http_proxy  = null
    https_proxy = null
    no_proxy    = null
    trusted_ca  = null
  }
}

variable "virtual_network_ids" {
  type        = list(string)
  description = "(Optional) The ID map of the Virtual Network that should be linked to the DNS Zone. Changing this forces a new resource to be created."
  default     = []
}

//Private DNS Zone

variable "dns_subscription_id" {
  type        = string
  description = "(Optional) The ID Subscription for Private DNS Zone. Required if the private DNS zone belongs to a different subscription than the AKS Cluster."
  default     = null
}

variable "private_dns_zone_rsg_name" {
  type        = string
  description = "(Required) The Name of the Resource Group where the Private DNS Zone exists."
}

variable "private_dns_zone_name" {
  type        = string
  description = "(Required) The name of the existing Private DNS Zone to use with the AKS Cluster."
}

variable "dns_prefix" {
  type        = string
  description = "(Optional) DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created. If not set assumes the value of aks_name."
  default     = null
}


// Key Custom & Disk Encryption Set
variable "key_custom_enabled" {
  type        = bool
  description = "(Optional) Flag to determine if the encryption is customized or will be performed by Azure."
  default     = false
}

variable "use_existing_des" {
  type        = bool
  description = "(Optional) Apply only if key_custom_enabled is true. Determines whether to use an existing Disk Encryption Set for encryption the VM or create one. Defaults to false, which will create a new one."
  default     = false
}

// KEY VAULT
variable "akv_id" {
  type        = string
  description = "(Optional) Specifies of the id of the key vault. Required only if key_custom_enabled is true, use_existing_des is false and akv_name is null."
  default     = null
}

variable "akv_rsg_name" {
  type        = string
  description = "(Optional) Specifies of the common key vault resource group name. If not set, it assumes the rsg_name value."
  default     = null
}

variable "akv_name" {
  type        = string
  description = "(Optional) Specifies the name of the key vault. Required if key_custom_enabled is true, use_existing_des is false and akv_id is null."
  default     = null
}

variable "key_name" {
  type        = string
  description = "(Optional) Specifies the name of the key in a key vault. Required if key_custom_enabled is true and use_existing_des is false."
  default     = null
}

variable "key_exist" {
  type        = bool
  description = "(Optional) Flag to determined if the encryption key exists or it must be created (by default). Only applies if key_custom_enabled is true and use_existing_des is false."
  default     = false
}

// DES
variable "des_rsg_name" {
  type        = string
  description = "(Optional) The resource group name used for disks encryption. If not set, it assumes the rsg_name value."
  default     = null
}

variable "des_name" {
  type        = string
  description = "(Optional) The disk encryption set base name used for disks encryption if use_existing_des is false des name will be <aks_name>-<des_name>, if use_existing_des is true the des name will be <des_name>. Required if key_custom_enabled is true. If use_existing_des is true it must exist, otherwise it will be created."
  default     = null
}

// MONITOR DIAGNOSTICS SETTINGS
variable "lwk_rsg_name" {
  type        = string
  description = "(Optional) The name of the resource group where the lwk is located. If is not set, it assumes the rsg_name value."
  default     = null
}

variable "analytics_diagnostic_monitor_lwk_id" {
  type        = string
  description = "(Optional) Specifies the Id of a Log Analytics Workspace where Diagnostics Data should be sent."
  default     = null
}

variable "lwk_name" {
  type        = string
  description = "(Optional) Specifies the name of a Log Analytics Workspace where Diagnostics Data should be sent."
  default     = null
}

variable "analytics_diagnostic_monitor_name" {
  type        = string
  description = "(Optional) The name of the diagnostic monitor. Required if analytics_diagnostic_monitor_enabled is true."
  default     = null
}

variable "analytics_diagnostic_monitor_enabled" {
  type        = bool
  description = "(Optional) Flag to set if the diagnostic monitor is used or not. If the resource deploys in production env, the value will be ignored and asume for it a true value."
  default     = true
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "(Optional) Specifies the id of the Authorization Rule of Event Hub used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_namespace" {
  type        = string
  description = "(Optional) Specifies the name of an Event Hub Namespace used to send Diagnostics Data. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_rsg. It will be ignored if eventhub_authorization_rule_id is defined."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_name" {
  type        = string
  description = "(Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent. Only applies if defined together with analytics_diagnostic_monitor_aeh_rsg and analytics_diagnostic_monitor_aeh_namespace or if defined together eventhub_authorization_rule_id."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_rsg" {
  type        = string
  description = "(Optional) Specifies the name of the resource group where the Event Hub used to send Diagnostics Data is stored. Only applies if defined together with analytics_diagnostic_monitor_aeh_name and analytics_diagnostic_monitor_aeh_namespace. It will be ignored if eventhub_authorization_rule_id is defined."
  default     = null
}

variable "analytics_diagnostic_monitor_aeh_policy" {
  type        = string
  description = "(Optional) Specifies the name of the event hub policy used to send diagnostic data. Defaults is RootManageSharedAccessKey."
  default     = "RootManageSharedAccessKey"
}

variable "analytics_diagnostic_monitor_sta_id" {
  type        = string
  description = "(Optional) Specifies the id of the Storage Account where logs should be sent."
  default     = null
}

variable "analytics_diagnostic_monitor_sta_name" {
  type        = string
  description = "(Optional) Specifies the name of the Storage Account where logs should be sent. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_rsg is not null and analytics_diagnostic_monitor_sta_id is null."
  default     = null
}

variable "analytics_diagnostic_monitor_sta_rsg" {
  type        = string
  description = "(Optional) Specifies the name of the resource group where Storage Account is stored. If analytics_diagnostic_monitor_sta_id is not null, it won't be evaluated. Only applies if analytics_diagnostic_monitor_sta_name is not null and analytics_diagnostic_monitor_sta_id is null."
  default     = null
}

variable "microsoft_defender_enabled" {
  type        = bool
  description = "(Optional) Is Microsoft Defender on the cluster enabled? If true, only applied if defender_lwk_id is set."
  default     = true
  nullable    = true
}

variable "defender_lwk_id" {
  type = string
  description = "(Optional) Specifies the ID of the Log Analytics Workspace where the audit logs collected by Microsoft Defender should be sent to. Required if microsoft_defender_enabled is true."
  default = null
}

// TAGGING
variable "inherit" {
  type        = bool
  description = "(Optional) Inherits resource group tags. Values can be false or true (by default)."
  default     = true
}

variable "product" {
  type        = string
  description = "(Required) The product tag will indicate the product to which the associated resource belongs to. In case shared_costs is Yes, product variable can be empty."
  default     = null
}

variable "cost_center" {
  type        = string
  description = "(Required) This tag will report the cost center of the resource. In case shared_costs is Yes, cost_center variable can be empty."
  default     = null
}

variable "shared_costs" {
  type        = string
  description = "(Optional) Helps to identify costs which cannot be allocated to a unique cost center, therefore facilitates to detect resources which require subsequent cost allocation and cost sharing between different payers."
  default     = "No"
  validation {
    condition     = var.shared_costs == "Yes" || var.shared_costs == "No"
    error_message = "Only `Yes`, `No` or empty values are allowed."
  }
}

variable "apm_functional" {
  type        = string
  description = "(Optional) Allows to identify to which functional application the resource belong, and its value must match with existing functional application code in Entity application portfolio management (APM) systems. In case shared_costs is Yes, apm_functional variable can be empty."
  default     = null
}

variable "cia" {
  type        = string
  description = "(Required) Allows a proper data classification to be attached to the resource."
  validation {
    condition     = length(var.cia) == 3 && contains(["C", "B", "A", "X"], substr(var.cia, 0, 1)) && contains(["L", "M", "H", "X"], substr(var.cia, 1, 1)) && contains(["L", "M", "C", "X"], substr(var.cia, 2, 1))
    error_message = "CIA must be a 3 character long and has to comply with the CIA nomenclature (CLL, BLM, AHM...). In sandbox this variable does not apply."
  }
  default = "XXX"
}

variable "optional_tags" {
  type = object({
    entity                = optional(string)
    environment           = optional(string)
    APM_technical         = optional(string)
    business_service      = optional(string)
    service_component     = optional(string)
    description           = optional(string)
    management_level      = optional(string)
    AutoStartStopSchedule = optional(string)
    tracking_code         = optional(string)
    Appliance             = optional(string)
    Patch                 = optional(string)
    backup                = optional(string)
    bckpolicy             = optional(string)
  })
  description = "(Optional) A object with the [optional tags](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx?OR=Teams-HL&CT=1716801658655&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yNDA1MDMwNTAwMCIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D#optional-tags). These are: entity: (Optional) this tag allows to identify entity resources in a simpler and more flexible way than naming convention, facilitating cost reporting among others; environment: (Optional) this tag allows to identify to which environment belongs a resource in a simpler and more flexible way than naming convention, which is key, for example, to proper apply cost optimization measures; APM_technical: (Optional) this tag allows to identify to which technical application the resource belong, and its value must match with existing technical application code in entity application portfolio management (APM) systems; business_service: (Optional) this tag allows to identify to which Business Service the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); service_component: (Optional) this tag allows to identify to which Service Component the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); description: (Optional) this tag provides additional information about the resource function, the workload to which it belongs, etc; management_level: (Optional) this tag depicts the deployment model of the cloud service (IaaS, CaaS, PaaS and SaaS) and helps generate meaningful cloud adoption KPIs to track cloud strategy implementation, for example: IaaS vs. PaaS; AutoStartStopSchedule: (Optional) this tag facilitates to implement a process to automatically start/stop virtual machines according to a schedule. As part of global FinOps practice, there are scripts available to implement auto start/stop mechanisms; tracking_code: (Optional) this tag will allow matching of resources against other internal inventory systems; Appliance: (Optional) this tag identifies if the IaaS asset is an appliance resource. Hardening and agents installation cannot be installed on this resources; Patch: (Optional) this tag is used to identify all the assets operated by Global Public Cloud team that would be updated in the next maintenance window; backup: (Optional) used to define if backup is needed (yes/no value); bckpolicy: (Optional) (platinium_001 | gold_001 | silver_001 | bronze_001) used to indicate the backup plan required for that resource."
  default = {
    entity                = null
    environment           = null
    APM_technical         = null
    business_service      = null
    service_component     = null
    description           = null
    management_level      = null
    AutoStartStopSchedule = null
    tracking_code         = null
    Appliance             = null
    Patch                 = null
    backup                = null
    bckpolicy             = null
  }
}

variable "custom_tags" {
  type        = map(string)
  description = "(Optional) Custom tags for product."
  default     = {}
}
