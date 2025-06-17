locals {

tags_optional = merge({
    entity                = var.optional_tags.entity != null ? var.optional_tags.entity : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["entity"]) ? data.azurerm_resource_group.rsg_principal[0].tags["entity"] : var.optional_tags.entity) : var.optional_tags.entity)
    environment           = var.optional_tags.environment != null ? var.optional_tags.environment : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["environment"]) ? data.azurerm_resource_group.rsg_principal[0].tags["environment"] :  var.optional_tags.environment) : var.optional_tags.environment)
    APM_technical         = var.optional_tags.APM_technical != null ? var.optional_tags.APM_technical : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["APM_technical"]) ? data.azurerm_resource_group.rsg_principal[0].tags["APM_technical"] : var.optional_tags.APM_technical) : var.optional_tags.APM_technical)
    business_service      = var.optional_tags.business_service != null ? var.optional_tags.business_service : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["business_service"]) ? data.azurerm_resource_group.rsg_principal[0].tags["business_service"] : var.optional_tags.business_service) : var.optional_tags.business_service)
    service_component     = var.optional_tags.service_component != null ? var.optional_tags.service_component : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["service_component"]) ? data.azurerm_resource_group.rsg_principal[0].tags["service_component"] : var.optional_tags.service_component) : var.optional_tags.service_component)
    description           = var.optional_tags.description != null ? var.optional_tags.description : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["description"]) ? data.azurerm_resource_group.rsg_principal[0].tags["description"] : var.optional_tags.description) : var.optional_tags.description)
    management_level      = var.optional_tags.management_level != null ? var.optional_tags.management_level : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["management_level"]) ? data.azurerm_resource_group.rsg_principal[0].tags["management_level"] : var.optional_tags.management_level) : var.optional_tags.management_level)
    AutoStartStopSchedule = var.optional_tags.AutoStartStopSchedule != null ? var.optional_tags.AutoStartStopSchedule : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["AutoStartStopSchedule"]) ? data.azurerm_resource_group.rsg_principal[0].tags["AutoStartStopSchedule"] : var.optional_tags.AutoStartStopSchedule) : var.optional_tags.AutoStartStopSchedule)
    tracking_code         = var.optional_tags.tracking_code != null ? var.optional_tags.tracking_code : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["tracking_code"]) ? data.azurerm_resource_group.rsg_principal[0].tags["tracking_code"] : var.optional_tags.tracking_code) : var.optional_tags.tracking_code)
    Appliance             = var.optional_tags.Appliance != null ? var.optional_tags.Appliance : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["Appliance"]) ? data.azurerm_resource_group.rsg_principal[0].tags["Appliance"] : var.optional_tags.Appliance) : var.optional_tags.Appliance)
    Patch                 = var.optional_tags.Patch != null ? var.optional_tags.Patch : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["Patch"]) ? data.azurerm_resource_group.rsg_principal[0].tags["Patch"] : var.optional_tags.Patch) : var.optional_tags.Patch)
    backup                = var.optional_tags.backup != null ? var.optional_tags.backup : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["backup"]) ? data.azurerm_resource_group.rsg_principal[0].tags["backup"] : var.optional_tags.backup) : var.optional_tags.backup)
    bckpolicy             = var.optional_tags.bckpolicy != null ? var.optional_tags.bckpolicy : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["bckpolicy"]) ? data.azurerm_resource_group.rsg_principal[0].tags["bckpolicy"] : var.optional_tags.bckpolicy) : var.optional_tags.bckpolicy)
  }, var.custom_tags)
  
    tags_resource = {
    "Product" = var.product != null ? var.product : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["product"]) ? data.azurerm_resource_group.rsg_principal[0].tags["product"] : (can(data.azurerm_resource_group.rsg_principal[0].tags["Product"]) ? data.azurerm_resource_group.rsg_principal[0].tags["Product"] : var.product)) : var.product)
    "Cost Center" = var.cost_center != null ? var.cost_center : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["cost_center"]) ? data.azurerm_resource_group.rsg_principal[0].tags["cost_center"] : (can(data.azurerm_resource_group.rsg_principal[0].tags["Cost Center"]) ? data.azurerm_resource_group.rsg_principal[0].tags["Cost Center"] : var.cost_center)) : var.cost_center)
    "shared_costs"   = var.shared_costs != null ? var.shared_costs : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["shared_costs"]) ? data.azurerm_resource_group.rsg_principal[0].tags["shared_costs"] : var.shared_costs) : var.shared_costs)
    "APM_functional" = var.apm_functional != null ? var.apm_functional : (var.inherit ? (can(data.azurerm_resource_group.rsg_principal[0].tags["APM_functional"]) ? data.azurerm_resource_group.rsg_principal[0].tags["APM_functional"] : var.apm_functional) : var.apm_functional)
    "CIA"            = !strcontains(var.cia,"X") ? var.cia : ((var.inherit || strcontains(var.cia,"X")) ? (can(data.azurerm_resource_group.rsg_principal[0].tags["cia"]) ? data.azurerm_resource_group.rsg_principal[0].tags["cia"] : (can(data.azurerm_resource_group.rsg_principal[0].tags["CIA"]) ? data.azurerm_resource_group.rsg_principal[0].tags["CIA"] : var.cia)) : var.cia)
    "hidden-deploy"  = "curated"
  }

  tags_complete = merge(local.tags_resource, local.tags_optional)

  total_tags = var.inherit ? merge(data.azurerm_resource_group.rsg_principal[0].tags, local.tags_complete) : null
  keys       = var.inherit ? distinct(split(",", replace(replace(replace(join(",", keys(local.total_tags)), "cia", "CIA"), "product", "Product"), "cost_center", "Cost Center"))) : null

  tags = var.inherit ? {
    for key in sort(local.keys) : key => lookup(local.total_tags, key) != "" && lookup(local.total_tags, key) != null ? lookup(local.total_tags, key) : null
  } : null
}

# Get and set a resource group for deploy. 
data "azurerm_resource_group" "rsg_principal" {
  count = var.rsg_name != null ? 1 : 0
  name = var.rsg_name
}
