variable "rsg_name" {
  type        = string
  description = "(Required) The name of the resource group in which the resource is created. Changing this forces a new resource to be created."
}
// TAGGING 
variable "inherit" {
  type        = bool
  description = "(Required) Inherits resource group tags. Values can be false (by default) or true."
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
    entity            = optional(string)
    environment    = optional(string)
    APM_technical      = optional(string)
    business_service   = optional(string)
    service_component      = optional(string)
    description      = optional(string)
    management_level      = optional(string)
    AutoStartStopSchedule    = optional(string)
    tracking_code  = optional(string)
    Appliance = optional(string)
    Patch = optional(string)
    backup = optional(string)
    bckpolicy = optional(string)
  })
  default = ({
    entity            = null
    environment    = null
    APM_technical      = null
    business_service   = null
    service_component      = null
    description      = null
    management_level      = null
    AutoStartStopSchedule    = null
    tracking_code  = null
    Appliance = null
    Patch = null
    backup = null
    bckpolicy = null
  })
}
variable "custom_tags" {
  type        = map(string)
  description = "(Optional) Custom tags for product."
  default     = {}
}
