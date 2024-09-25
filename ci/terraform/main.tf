# Data source to access information about an existing resource group
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Data source to access information about an existing automation account
data "azurerm_automation_account" "existing" {
  name                = var.automation_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subscription" "current" {}
