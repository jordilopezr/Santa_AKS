# **Azure Key Vault - SA**

## Overview

**IMPORTANT** 
If you want to run this module it is an important requirement to specify the azure provider version, you must set the azure provider version and the terraform version in version.tf file.

his module has been certified with the versions:

| Terraform version | Azure version |
| :-----: | :-----: |
| 1.8.5 | 3.110.0 |

<br>

**<span style="color:red; font-weight:bold; animation: blinker 1s linear infinite;">ATTENTION!!!</span>**
<br>Starting in October 2025, access to the Key Vault will be through RBAC instead of access policies.
<br>The value of the enable_rbac_authorization variable should be changed to true instead of using the default value false.
<br>Make sure that the Service Principal that executes it has permission from Santander RBAC Contributor to be able to execute it.

### Acronym

Acronym for the product is **akv**.

### Description
 > Cloud applications and services use cryptographic keys and secrets to help keep information secure. Azure Key Vault safeguards these keys and secrets. When you use Key Vault, you can encrypt authentication keys, storage account keys, data encryption keys, .pfx files, and passwords by using keys that are protected by hardware security modules (HSMs).
Key Vault helps solve the following problems:
 > - Secret management: Securely store and tightly control access to tokens, passwords, certificates, API keys, and other secrets.
 > - Key management: Create and control encryption keys that encrypt your data.
 > - Certificate management: Provision, manage, and deploy public and private Secure Sockets Layer/Transport Layer Security (SSL/TLS) certificates for use with Azure and your internal connected resources.
Store secrets backed by HSMs: Use either software or FIPS 140-2 Level 2 validated HSMs to help protect secrets and keys.

### Dependencies

Resources given by the Cloud Competence Center that must exist before the deployment can take place:
- Azure Subscription.
- Workload resource Group.
- Azure Active Directory Tenant.
- Log Analytics Workspace for health logs and metrics.
- A deployment Service Principal with owner permissions on the resource group.

**IMPORTANT** Some resources, such as secret or key, can support a maximum of 15 tags

## Public Documentation
[Azure Key Vault Overview](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
[Azure Key Vault Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)

## Architecture example:

![Architecture diagram](documentation/images/architecture_diagram.png "Architecture diagram")

## Networking

![Network diagram](documentation/images/network_diagram.png "Network diagram")


### Encryption

Key Vault has enabled soft deleted property.
This action will permit enable for Azure SQL Database: Transparent Data Encryption with Bring Your Own Key support for Azure SQL Database and Data Warehouse.
[Azure Key Vault - Soft Deleted enable for Server database and SQL database ](https://docs.microsoft.com/es-es/azure/sql-database/transparent-data-encryption-byok-azure-sql?view=sql-server-2017&viewFallbackFrom=azuresqldb-current)


### Exposed product endpoints

Virtual Network (VNet) service endpoints extend your virtual network private address space and the identity of your VNet to the Azure services, over a direct connection. Endpoints allow you to secure your critical Azure service resources to only your virtual networks. Traffic from your VNet to the Azure service always remains on the Microsoft Azure backbone network.

Key Vault firewalls and virtual network rules only apply to the data plane of Key Vault. Key Vault control plane operations (such as create, delete, and modify operations, setting access policies, setting firewalls, and virtual network rules) are not affected by firewalls and virtual network rules.

**Important:**
After firewall rules are in effect, users can only perform Key Vault data plane operations when their requests originate from allowed virtual networks or IPv4 address ranges. This also applies to accessing Key Vault from the Azure portal. Although users can browse to a key vault from the Azure portal, they might not be able to list keys, secrets, or certificates if their client machine is not in the allowed list. This also affects the Key Vault Picker by other Azure services. Users might be able to see list of key vaults, but not list keys, if firewall rules prevent their client machine.

**Note:**

Be aware of the following configuration limitations:
* A maximum of 127 virtual network rules and 127 IPv4 rules are allowed.
* Small address ranges that use the "/31" or "/32" prefix sizes are not supported. Instead, configure these ranges by using individual IP address rules.
* IP network rules are only allowed for public IP addresses. IP address ranges reserved for private networks (as defined in RFC 1918) are not allowed in IP rules. Private networks include addresses that start with 10., 172.16-31, and 192.168..
* Only IPv4 addresses are supported at this time.

The following endpoints can be used to consume or manage the Certified Product:

#### Management endpoints (Management Plane)
Key Vault control plane operations (such as create, delete, and modify operations, setting access policies, setting firewalls, and virtual network rules) are not affected by firewalls and virtual network rules.

|EndPoint|IP/URL  |Protocol|Port|Authorization|
|:-|:-|--|--|:-|
|Azure Resource Management REST API|https://management.azure.com/|HTTPS|443|Azure Active Directory|

#### Consumption endpoints (Data Plane)
Key Vault firewalls and virtual network rules only apply to the data plane of Key Vault.

|EndPoint|IP/URL  |Protocol|Port|Authorization|
|:-|:-|--|--|:-|
|Secured public endpoint, configured with a custom name|https://[Key Vault].[service].core.windows.net|HTTPS|443|Authentication and Authorization via Azure AD RBAC model also Authorization use access policy for permit the access to the Key Vault.|

# **Exit Plan**

Create an Encryption Key Management software on the new CSP destination.

Export keys managed at Azure Key Vault and import into the new destination.
Review all the workloads or applications connected to Azure Key Vault, change its connection strings to the new CSP destination and test if it is needed to rotate or re-create the keys already employed to have the applications 100% working.)

## Configuration
| Tf Name | Default Value | Type | Mandatory | Description |
|:--:|:--:|:--:|:--:|:--|
| rsg_name | n/a | `string` | YES | The name of the resource group in which the Key Vault is created. Changing this forces a new resource to be created. |
| location | `null` | `string` | NO | Specifies the supported Azure location where the Resource Group exists. Changing this forces a new resource to be created. |
| sku_name | `"premium"` | `string` | NO | The Name of the SKU used for this Key Vault. Possible values are standard and premium. |
| ip_rules | `[]` | `list(any)` | NO | The ranges of IPs to can access Key Vault. |
| virtual_network_subnet_ids | `[]` | `list(any)` | NO | The Azure subnets that can access Key Vault. |
| deploy | `false` | `bool` | NO | Specify if you want the property Azure Virtual Machines for deployment. |
| enable_rbac_authorization | `false` | `bool` | NO | Boolean flag to specify the way you control access to resources using Azure RBAC is to assign Azure roles. If enable_rbac_authorization is true, the Key Vault Access Policy is not create. |
| target_scenario | `true` | `bool` | NO | If true, they will apply to the following cases and if false, they will not apply. |
| object_id | n/a | `string` | NO | This variable contains the Object Id which should be used for provider configuration. |
|arm_tenant_id | `"35595a02-4d6d-44ac-99e1-f9ab4cd872db"` | `string` | NO | This variable contains the tenant id used for deploy. |
| analytics_diagnostic_monitor_lwk_id | `null` | `string` | NO | Specifies the Id of a Log Analytics Workspace where Diagnostics Data should be sent. |
| lwk_name| `null` | `string` | NO | Specifies the name of a Log Analytics Workspace where Diagnostics Data should be sent. |
| lwk_rsg_name| `null` | `string` | NO | The name of the resource group where the lwk is located. If this variable is not set, it assumes the rsg_name value. |
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
| entity | n/a | `string` | YES | Santander entity code. Used for Naming. (3 characters). |
| environment | n/a | `string` | YES | Santander environment code. Used for Naming. (2 characters). |
| app_acronym | n/a | `string` | YES | App acronym of the resource. Used for Naming. (6 characters). |
| function_acronym | n/a | `string` | YES | App function of the resource. Used for Naming. (4 characters). |
| sequence_number | n/a | `string` | YES | Secuence number of the resource. Used for Naming. (3 characters). |
| inherit | `true` | `bool` | NO | Inherits resource group tags. Values can be false or true (by default). |
| product | n/a | `string` | YES | The product tag will indicate the product to which the associated resource belongs to. In case shared_costs is Yes, product variable can be empty. |
| cost_center | n/a | `string` | YES | This tag will report the cost center of the resource. In case shared_costs is Yes, cost_center variable can be empty. |
| shared_costs | "No" | `string` | NO | Helps to identify costs which cannot be allocated to a unique cost center, therefore facilitates to detect resources which require subsequent cost allocation and cost sharing between different payers. |
| apm_functional | n/a | `string` | YES | Allows to identify to which functional application the resource belong, and its value must match with existing functional application code in Entity application portfolio management (APM) systems. In case shared_costs is Yes, apm_functional variable can be empty. |
| cia | n/a | `string` | YES | Confidentiality-Integrity-Availability. Allows a  proper data classification to be attached to the resource. |
| optional_tags | `{entity = null environment = null APM_technical = null business_service = null service_component = null description = null management_level = null AutoStartStopSchedule = null tracking_code = null Appliance = null Patch = null backup = null bckpolicy = null}` | `object({entity = optional(string) environment = optional(string) APM_technical = optional(string) business_service = optional(string)  service_component = optional(string) description = optional(string) management_level = optional(string) AutoStartStopSchedule = optional(string) tracking_code = optional(string) Appliance = optional(string) Patch = optional(string) backup = optional(string) bckpolicy = optional(string)})` | NO | A object with the [optional tags](https://santandernet.sharepoint.com/sites/SantanderPlatforms/SitePages/Naming_and_Tagging_Building_Block_178930012.aspx?OR=Teams-HL&CT=1680161225717&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yMzAzMDUwMTExMCIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D). These are: entity: (Optional) this tag allows to identify entity resources in a simpler and more flexible way than naming convention, facilitating cost reporting among others; environment: (Optional) this tag allows to identify to which environment belongs a resource in a simpler and more flexible way than naming convention, which is key, for example, to proper apply cost optimization measures; APM_technical: (Optional) this tag allows to identify to which technical application the resource belong, and its value must match with existing technical application code in entity application portfolio management (APM) systems; business_service: (Optional) this tag allows to identify to which Business Service the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); service_component: (Optional) this tag allows to identify to which Service Component the resource belongs, and its value must match with Business Service code in entity assets management systems (CMDB); description: (Optional) this tag provides additional information about the resource function, the workload to which it belongs, etc; management_level: (Optional) this tag depicts the deployment model of the cloud service (IaaS, CaaS, PaaS and SaaS) and helps generate meaningful cloud adoption KPIs to track cloud strategy implementation, for example: IaaS vs. PaaS; AutoStartStopSchedule: (Optional) this tag facilitates to implement a process to automatically start/stop virtual machines according to a schedule. As part of global FinOps practice, there are scripts available to implement auto start/stop mechanisms; tracking_code: (Optional) this tag will allow matching of resources against other internal inventory systems; Appliance: (Optional) this tag identifies if the IaaS asset is an appliance resource. Hardening and agents installation cannot be installed on this resources; Patch: (Optional) this tag is used to identify all the assets operated by Global Public Cloud team that would be updated in the next maintenance window; backup: (Optional) used to define if backup is needed (yes/no value); bckpolicy: (Optional) (platinium_001, gold_001, silver_001, bronze_001) used to indicate the backup plan required for that resource. |
| custom_tags | `{}` | `map(string)` | NO | Custom (additional) tags for compliant. |

<br>

## Outputs

|Output Name| Output Value | Description |
|:--|:--:|:--:|
| akv_name | akv_keyvault_resource.akv.name | The name of Key Vault. |
| akv_id | akv_keyvault_resource.akv.id | The ID of Key Vault. |

<br>

### Usage

Include the next code into your main.tf file:

```hcl
module "akv" {
  source                                      = "<akv module source>"
  
  // COMMON VARIABLES
  rsg_name                                    = var.rsg_name                                             # Required
  location                                    = var.location                                             # Optional

  //PRODUCT
  sku_name                                    = var.sku_name                                             # Optional
  ip_rules                                    = var.ip_rules                                             # Optional
  virtual_network_subnet_ids                  = var.virtual_network_subnet_ids                           # Optional
  deploy                                      = var.deploy                                               # Optional
  enable_rbac_authorization                   = var.enable_rbac_authorization                            # Optional
  target_scenario                             = var.target_scenario                                      # Optional

  // SEC VARIABLES
  object_id                                   = var.object_id                                            # Required
  arm_tenant_id                               = var.arm_tenant_id                                        # Optional

  // MONITOR DIAGNOSTICS SETTINGS  
  lwk_rsg_name                                = var.lwk_rsg_name                                                            # Optional
  analytics_diagnostic_monitor_lwk_id         = var.analytics_diagnostic_monitor_lwk_id                                     # Optional
  lwk_name                                    = var.lwk_name                                                                # Optional
  analytics_diagnostic_monitor_name           = var.analytics_diagnostic_monitor_name                                       # Required if analytics_diagnostic_monitor_enabled is true
  analytics_diagnostic_monitor_enabled        = var.analytics_diagnostic_monitor_enabled                                    # Optional
  eventhub_authorization_rule_id              = var.eventhub_authorization_rule_id                                          # Optional
  analytics_diagnostic_monitor_aeh_namespace  = var.analytics_diagnostic_monitor_aeh_namespace                              # Optional 
  analytics_diagnostic_monitor_aeh_name       = var.analytics_diagnostic_monitor_aeh_name                                   # Optional
  analytics_diagnostic_monitor_aeh_rsg        = var.analytics_diagnostic_monitor_aeh_rsg                                    # Optional
  analytics_diagnostic_monitor_aeh_policy     = var.analytics_diagnostic_monitor_aeh_policy                                 # Optional
  analytics_diagnostic_monitor_sta_id         = var.analytics_diagnostic_monitor_sta_id                                     # Optional
  analytics_diagnostic_monitor_sta_name       = var.analytics_diagnostic_monitor_sta_name                                   # Optional
  analytics_diagnostic_monitor_sta_rsg        = var.analytics_diagnostic_monitor_sta_rsg                                    # Optional
  
  //NAMING
  entity                                      = var.entity                                               # Required
  environment                                 = var.environment                                          # Required
  app_acronym                                 = var.app_acronym                                          # Required
  function_acronym                            = var.function_acronym                                     # Required
  sequence_number                             = var.sequence_number                                      # Required

  // TAGGING
  inherit                                     = var.inherit                                              # Optional
  product                                     = var.product                                              # Required if shared_costs is No.
  cost_center                                 = var.cost_center                                          # Required if shared_costs is No.
  shared_costs                                = var.shared_costs                                         # Optional
  apm_functional                              = var.apm_functional                                       # Optional
  cia                                         = var.cia                                                  # Required
  optional_tags                               = var.optional_tags                                        # Optional
  custom_tags                                 = var.custom_tags                                          # Optional
}
```

<br>

Include the next code into your outputs.tf file:

```hcl

output "akv_name" {
  value = module.akv.akv_name
  description = "The name of Key Vault."
}

output "akv_id" {
  value = module.akv.akv_id
  description = "The ID of Key Vault."
}
```

* You can watch more details about [Azure Key Vault configuration parameters](/variables.tf).

# **Security Framework**
This section explains how the different aspects to have into account in order to meet the Security Control Framework for this Certified Service. 

This product has been certified for the [Security Control Framework v1.2](https://teams.microsoft.com/l/file/E7EFF375-EEFB-4526-A878-3C17A220F63C?tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47&fileType=docx&objectUrl=https%3A%2F%2Fmicrosofteur.sharepoint.com%2Fteams%2FOptimum-SanatanderAzureFoundationsProject%2FShared%20Documents%2FCCoE-Channel%2FSecurity%20Control%20Framework%2FSantander%20-%20CCoE%20-%20Security%20Control%20Framework%20-%20v1.2.docx&baseUrl=https%3A%2F%2Fmicrosofteur.sharepoint.com%2Fteams%2FOptimum-SanatanderAzureFoundationsProject&serviceName=teams&threadId=19:e20a3726dc824141b32579df437f7a66@thread.skype&groupId=26385c5b-85e4-4376-988a-27ed549d9419) revision.

A Whitelist of common IPs has been included in the script. Additional IPs can be included using var.ip_rules. The Latest list of IPs can be found in this [link](https://santandernet.sharepoint.com/:x:/r/sites/globalcloudsecurity/_layouts/15/Doc.aspx?sourcedoc=%7BF8D31875-5A71-4569-A5D6-580EA272FDFD%7D&file=Deny%20policies%20transition%20analysis.xlsx&action=default&mobileredirect=true&DefaultItemOpen=1). If the Ip is not included, the resource will be unavailable.

## Security Controls based on Security Control Framework

### Foundation (**F**) Controls for Rated Workloads
|SF#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SF1|Resource Tagging on all resources|Product includes all required tags in the deployment template|CCoE|
|SF2|IAM on all accounts|CCoE RBAC model for products certifies right level of access to the Key Vault. Access to a key vault requires proper authentication and authorization before a caller (user or application) can get access. Authentication establishes the identity of the caller, while authorization determines the operations that they are allowed to perform. Authentication is done via Azure Active Directory. Authorization may be done via role-based access control (RBAC) or Key Vault access policy. RBAC is used when dealing with the management of the vaults and key vault access policy is used when attempting to access data stored in a vault. <span style="background-color: #FFFF00">although this is not enforced</span>)|CCoE|
|SF3|MFA on accounts|This is governed by Azure AD|Protect|
|SF4|Platform Activity Logs & Security Monitoring|Platform logs and security monitoring provided by Platform|CCoE|
|<span style="color:red">SF5</span>|Virus/Malware Protection|<span style="background-color: #FFFF00">No antivirus protection for Key Vault</span>||

### Medium (**M**) Controls for Rated Workloads
|SM#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SM1|Encrypt data at rest using application or server level encryption|Default Azure Key Vault encrypt the Key Management, Secrets Management, Certificate Management and Store secrets backed by Hardware Security Modules. Secrets and keys are safeguarded by Azure, using industry-standard algorithms, key lengths, and hardware security modules (HSMs). The HSMs used are Federal Information Processing Standards (FIPS) 140-2 Level 2 validated. |CCoE|
|SM2|Customer managed keys|Current version Azure Key Vault "Use your own key" feature |CCoE|
|SM3|Encrypt data in transit over public interconnections|Certified Product enables only https traffic|CCoE|
|SM4|Control resource geography|Certified Product location can be configured using product deployment parameters|DevOps|

### Advanced (**A**) Controls for Rated Workloads
|SM#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|SA1|Encrypt data at rest using application or server level encryption|Default Azure Key Vault encrypt the Key Management, Secrets Management, Certificate Management and Store secrets backed by Hardware Security Modules. Secrets and keys are safeguarded by Azure, using industry-standard algorithms, key lengths, and hardware security modules (HSMs). The HSMs used are Federal Information Processing Standards (FIPS) 140-2 Level 2 validated.  |CCoE|
|SA2|Customer managed keys with HSM and BYOK|Current version Azure Key Vault "Use your own key" feature |CCoE|
|SA3|Encrypt data in transit using private & public interconnections​|Certified Product enables only https traffic |CCoE|
|SA4|Control resource geography|Certified Product location can be configured using product deployment parameters |CCoE|
|SA5|Cardholder and auth sensitive data|No card or sensitive auth data will be store in a key vault. |CCoE|
|SA6|RedTeam​|eCISO exercises must be performed periodically. |CCoE|

### Application (**P**) Controls for Rated Workloads
|SP#|What|How it is implemented in the Product|Who|
|--|:---|:---|:--|
|<span style="color:red">SP1</span>|Segregation of Duties|<span style="background-color: #FFFF00">N/A</span>||
|SP2|Vulnerability Management|Detect is responsible for vulnerability scanning of public endpoints|Detect|
|SP3|Security Configuration & Patch Management|Since this is a **SaaS** service, product upgrade and patching is done by CSP|MS|
|<span style="color:red">SP4</span>|Service Logs & Security Monitoring|Product is connected to Log Analytics for activity and security monitoring. <span style="background-color: #FFFF00">Product metrics and Audit Event are being exported to Log Analytics Workspace</span>.|CCoE|
|SP5|Privileged Access Management|**Data Plane**: Access to data plane is not considered Privileged Access<br>**Control Plane**:Access to the control plane is considered Privileged Access and is governed as per the [Azure Management Endpoint Privileged Access Management]() policy|N/A|
|SP6|Network Security Perimeter|**SP6.1**: DevOps can configure the isolated network by leveraging the product built in Virtual Firewall<br>**SP6.2**: Virtual Firewall can be used to deny incoming traffic, built in Azure DDoS protection for PaaS/SaaS services<br>**SP6.3**: Doesn't apply as no outbound traffic is generated from the service<br>**SP6.4,SP6.5**: Virtual Network Service Endpoint can be configured to enable incoming traffic from on-prem or private Virtual Networks. Public IP filtering is set to prevent access from Internet<br>**SP6.6**: Doesn't apply<br>**SP6.7**: : Doesn't apply<br>|DevOps, CCoE|
|<span style="color:red">SP7</span>|Advanced Malware Protection | Doesn't apply |<span style="background-color: #FFFF00"> DevOps</span>|
|SP8|Cyber incidents management & Digital evidences gathering|Isolate infrastructure product is possible with Virtual Firewall|DevOps|
|SP9|RedTeam|Read Teaming exercises must be performed periodically|Cybersecurity, DevOps|
|SP10|Pentesting|All penetration testing must be authorized by business owners and pertinent stakeholders|Cybersecurity, DevOps|


# **Basic tf files description**
This section explain the structure and elements that represent the artifacts of product.
|Folder|Name|Description
|--|:-|--|
|Documentation|network_diagram.png|Network topology diagram.|
|Documentation|architecture_diagram.png|Architecture diagram.|
|Documentation|examples|terraform.tfvars|
|Root|README.md|Product documentation file.|
|Root|CHANGELOG.md|Contains the changes added to the new versions of the modules.|
|Root|main.tf|Terraform file to use in pipeline to build and release a product.|
|Root|outputs.tf|Terraform file to use in pipeline to check output.|
|Root|variables.tf|Terraform file to use in pipeline to configure product.|

### Target Audience
|Audience |Purpose  |
|--|--|
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
