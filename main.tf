locals {
  enabled_schedules = {
    for i in var.schedules : i.name => i
    if i.enabled
  }
}

resource "azurerm_automation_runbook" "this" {
  name                    = var.runbook.name
  location                = var.location
  tags                    = var.tags
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  log_verbose             = var.runbook.log_verbose
  log_progress            = var.runbook.log_progress
  description             = var.runbook.description
  runbook_type            = var.runbook.runbook_type
  content                 = var.runbook.content
}

resource "azurerm_automation_schedule" "this" {
  for_each = local.enabled_schedules

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = each.value.frequency
  interval                = each.value.frequency == "OneTime" ? [] : each.value.interval
  start_time              = each.value.start_time
  description             = each.value.description
  timezone                = var.timezone
  week_days               = each.value.frequency == "Week" ? each.value.week_days : []

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_job_schedule" "this" {
  for_each = local.enabled_schedules

  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = each.value.name
  runbook_name            = azurerm_automation_runbook.this.name
  parameters              = each.value.parameters
  run_on                  = each.value.run_on

  depends_on = [azurerm_automation_schedule.this]
}

resource "azurerm_automation_variable_int" "this" {
  for_each = { for i in var.automation_variables : i.name => i if i.type == "int" }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = tonumber(each.value.value)
  description             = each.value.description
  encrypted               = each.value.encrypted
}

resource "azurerm_automation_variable_bool" "this" {
  for_each = { for i in var.automation_variables : i.name => i if i.type == "bool" }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted
}

resource "azurerm_automation_variable_datetime" "this" {
  for_each = { for i in var.automation_variables : i.name => i if i.type == "datetime" }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted
}

resource "azurerm_automation_variable_object" "this" {
  for_each = { for i in var.automation_variables : i.name => i if i.type == "object" }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = jsonencode(each.value.value)
  description             = each.value.description
  encrypted               = each.value.encrypted
}

resource "azurerm_automation_variable_string" "this" {
  for_each = { for i in var.automation_variables : i.name => i if i.type == "string" }

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = each.value.value
  description             = each.value.description
  encrypted               = each.value.encrypted
}
