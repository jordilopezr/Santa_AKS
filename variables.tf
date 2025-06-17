variable "rsg_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Key Vault is created. Changing this forces a new resource to be created."
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the Resource Group exists. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "sku_name" {
  type        = string
  description = "(Opcional) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default     = "premium"
}

variable "ip_rules" {
  type        = list(any)
  description = "(Optional) The ranges of IPs to can access Key Vault."
  default     = []
}

variable "virtual_network_subnet_ids" {
  type        = list(any)
  description = "(Optional) The Azure subnets that can access Key Vault."
  default     = []
}

variable "deploy" {
  type        = bool
  description = "(Opcional) Specify if you want the property Azure Virtual Machines for deployment."
  default     = false
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "(Optional) Boolean flag to specify the way you control access to resources using Azure RBAC is to assign Azure roles. If enable_rbac_authorization is true, the Key Vault Access Policy is not create."
  default     = false
}

variable "target_scenario" {
  type        = bool
  description = "(Optional) If true, they will apply to the following cases and if false, they will not apply"
  default     = true
}

// SEC variables from SPN
variable "object_id" {
  type        = string
  description = "(Required) The Object Id which should be used."
}
variable "arm_tenant_id" {
  description = "(Required) The tenant id used for deploy."
  type        = string
  default     = "35595a02-4d6d-44ac-99e1-f9ab4cd872db"
}

// MONITOR DIAGNOSTICS SETTINGS
variable "lwk_rsg_name" {
  type        = string
  description = "(Optional) The name of the resource group where the lwk is located. Only applies if analytics_diagnostic_monitor_enabled is true. If analytics_diagnostic_monitor_lwk_id is not null, it will be ignored, but if analytics_diagnostic_monitor_lwk_id is null and this variables is not set, it assumes the rsg_name value."
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

//NAMING
variable "entity" {
  description = "(Required) Santander entity code. Used for Naming (3 characters)."
  type        = string
}

variable "environment" {
  description = "(Required) Santander environment code. Used for Naming (2 characters)."
  type        = string
}


variable "app_acronym" {
  description = "(Required) App acronym of the resource. Used for Naming (6 characters)."
  type        = string
}

variable "function_acronym" {
  description = "(Required) App function of the resource. Used for Naming (4 characters)."
  type        = string
}

variable "sequence_number" {
  description = "(Required) Secuence number of the resource. Used for Naming (3 characters)."
  type        = string
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
