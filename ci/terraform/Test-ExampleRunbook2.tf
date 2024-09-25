# For testing a secret passed in as TF_VAR_var_name through GitHub secrets,
# which is then deployed as an encrypted string to the automation account.
variable "test_secret" {
  type        = string
  description = "Secret variable from GitHub Secrets"
  sensitive   = true
}

module "Runbook2" {
  source = "../.."

  resource_group_name     = data.azurerm_resource_group.existing.name
  automation_account_name = data.azurerm_automation_account.existing.name
  location                = var.location
  timezone                = var.automation_schedule_timezone

  runbook = {
    name         = "Test-ExampleRunbook2"
    description  = "First example runbook"
    content      = file("../azure-runbooks/Test-ExampleRunbook2.ps1")
    log_verbose  = true
    log_progress = true
    runbook_type = "PowerShell72"
  }

  schedules = [
    {
      name        = "Runbook2-OneTime"
      frequency   = "OneTime"
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-OneTime"
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook2-Daily"
      frequency   = "Day"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Daily"
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook2-Hourly"
      frequency   = "Hour"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Hourly"
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook2-Weekly"
      frequency   = "Week"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Weekly"
      week_days   = ["Monday", "Friday"]
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook2-Monthly"
      frequency   = "Month"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Monthly"
      enabled     = true
      run_on      = ""
    }
  ]

  automation_variables = [
    {
      name      = "Runbook2-Secret"
      value     = var.test_secret
      type      = "string"
      encrypted = true
    },
    {
      name      = "Runbook2-TestVar"
      value     = "runbook2testvar"
      type      = "string"
      encrypted = false
    }
  ]

  tags = {
    "Environment" = "Dev"
    "ManagedBy"   = "Terraform"
    "Project"     = "Automation"
  }
}
