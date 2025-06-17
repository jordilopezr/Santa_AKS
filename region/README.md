# **Module name: terraform-azurerm-module-reg-lz**

## **Overview**

### Acronym: **reg**

### **Description**

Each Azure geography contains one or more regions and meets specific data residency and compliance requirements. This lets you keep your business-critical data and apps nearby on fault-tolerant, high-capacity networking infrastructure. An Azure subscription is supported by a list of Regions.

This module returns the list of Azure Regions allowed, consisting of the region name and its geographic code.

### Usage

Include the next code into your main.tf file:
```hcl
module "az_regions" {
    source  = "tfe1.sgtech.corp/global-catalog/module-reg-lz/azurerm"
}
```

To apply aws_regions, the module where the region list is found must be invoked.
```hcl
   regions = module.az_regions.regions
```

## Public documentation

- [Azure Geography](https://azure.microsoft.com/explore/global-infrastructure/geographies/)

- [AWS Regions: names & codes](https://www.aws-services.info/regions.html)

- [Available Azure services by region types and categories](https://learn.microsoft.com/en-us/azure/reliability/availability-service-by-category)

- [Azure CLI: List supported regions for the current subscription](https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list-locations)

- [Geocodes for Azure regions](https://learn.microsoft.com/azure/backup/scripts/geo-code-list)

### **Version**
| Version |
| :------ |
| 1.0.0   |

### **Target Audience**
| Audience                   | Purpose                               |
| -------------------------- | ------------------------------------- |
| Cloud Center of Excellence | Understand the Design of this Service |

- **GitHub Repository:** [terraform-azurerm-module-reg-lz](https://github.com/santander-group-slz/terraform-azurerm-module-reg-lz)