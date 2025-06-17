# **Changelog**

## **[v3.7.0 (2025-02-12)]**
### Changes
- `Upgraded` Include RBAC permissions.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v3.6.3 (2024-12-11)]**
### Changes
- `Upgraded` Terraform version to 1.8.5 and azure version to 3.110.0.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v3.6.2 (2024-07-03)]**
### Changes
- `Updated` Logic of Diagnostic Monitor.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v3.6.1 (2024-05-29)]**
### Changes
- `Changed` the method of obtaining tags from calculation in locals to calling a dedicated tags module.
- `Added` tags module call.
- `Added` optional_tags variable.
- `Added` terraform_optionaltags.tfvars file.
- `Updated` CHANGELOG.md.
- `Updated` README.md.

## **[v3.6.0 (2024-05-09)]**
### Changes
- `Tested` with terraform v1.7.1, azure v3.90.0, .
- `Updated` CHANGELOG.md.
- `Updated` README.md.
## **[3.5.19 (2024-04-19)]**
- `Updated` Remove lifecycle from azurerm_monitor_diagnostic_setting
  
## **[3.5.18 (2024-04-18)]**
- `Updated` total_tags variable logic in main file to prioritize custom tags over resource group tags

## **[3.5.17 (2024-04-16)]**
- `Added` analytics_diagnostic_monitor_sta_id variable
- `Updated` local variable mds_sta_enabled
- `Updated` azurerm_monitor_diagnostic_setting resource called law.
- `Updated` azurerm_storage_account data called mds_sta
- `Updated` README & CHANGELOG

## **[3.5.16 (2024-04-12)]**
- `Deleted` unnecesary depends_on.
- `Improved` code.

## **[v3.5.15 (2024-03-25)]**
### Changes
- `Added` analytics_diagnostic_monitor_lwk_id variable.
- `Added` local variables lwk_id, location & rsg_lwk.
- `Updated` azurerm_log_analytics_workspace datasource called lwk_principal.
- `Updated` azurerm_key_vault resource called akv_sa.
- `Updated` azurerm_monitor_diagnostic_setting resource called law.
- `Fixed` default value of some variables
- `Updated` README.md & CHANGELOG.md

## **[v3.5.14 (2024-03-07)]**
### Changes
- `Updated` tags
- `Updated` URL section in README
- `Updated` template version in README

## **[v3.5.13 (2023-12-14)]**
### Changes
- `Update` Include functionality of regions.
- `Update` Allow inform the id of event hub authorization rule.
- `Update` CHANGELOG.md
- `Update` README.md

## **[v3.5.11 (2023-11-08)]**
### Changes
- `Added` availability of multiple regions.

## **[v3.5.10 (2023-10-19)]**
### Changes
- `Added` availability of the Sweden Central region.

## [v3.5.9] - 2023-10-04
- `Added` support for diagnostic settings

## [v3.5.8] - 2023-09-18
- `Update` Upgrade versions of terraform and azurerm provider
- `Update` CHANGELOG.md
- `Update` README.md

## [v3.5.7] - 2023-09-14
- `Update` Allow enabled rbac
- `Update` Allow not enabled enabled_for_template_deployment and enabled_for_disk_encryption-
- `Update` CHANGELOG.md
- `Update` README.md

## [v3.5.6] - 2023-06-02
### Added
- Update diagnostic settings with enabled_log
- Update naming with LZ.

## [v3.5.5] - 2023-05-29
 
### Added
- Update diagnostic settings with enabled_log

## [v3.5.4] - 2023-05-22
 
### Added
- Update documentation

## [v3.5.3] - 2023-05-18
 
### Added
- Update conditions of tags


## [v3.5.2] - 2023-04-20
 
### Added
- Variable deploy

## [v3.5.1] - 2023-04-13
 
### Changed
- Adapt to template 1.0.6

## [v3.5.0] - 2022-11-11

### Added
- Variable custom_tags


## [v3.4.0] - 2022-08-08

### Changed
- Fix ignore changes azurerm_monitor_diagnostic_setting


## [v3.3.0] - 2022-07-04

### Added
- Region india


## [v1.0.0] - 2022-01-04
First stable version

### Added
- n/a

### Changed
- Update modules versions to v1.0.0

### Removed
- n/a


## [v0.9.0] version - 2021-12-28

### Added
- n/a

### Changed
- Source to localterraform and catalog.

### Removed
- n/a

## [v1.0.0] - 2021-06-01 - DELETED

### First version

Based on https://github.alm.europe.cloudcenter.corp/ccc-ccoe/iac.az.modules.key-vault-sm

- Add naming join to KVE resource
- Update Readme.md with news variables and format
- Clean main.tf
- Update Terraform and Azurerm provider versions
- Replace the repository structure
- News QA Evidences
