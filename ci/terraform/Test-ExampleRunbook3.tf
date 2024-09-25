module "Runbook3" {
  source = "../.."

  resource_group_name     = data.azurerm_resource_group.existing.name
  automation_account_name = data.azurerm_automation_account.existing.name
  location                = var.location
  timezone                = var.automation_schedule_timezone

  runbook = {
    name         = "Test-ExampleRunbook3"
    description  = "First example runbook"
    content      = file("../azure-runbooks/Test-ExampleRunbook3.ps1")
    log_verbose  = true
    log_progress = true
    runbook_type = "PowerShell72"
  }

  schedules = [
    {
      name        = "Runbook3-OneTime"
      frequency   = "OneTime"
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-OneTime"
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook3-Daily"
      frequency   = "Day"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Daily"
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook3-Hourly"
      frequency   = "Hour"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Hourly"
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook3-Weekly"
      frequency   = "Week"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Weekly"
      week_days   = ["Monday", "Friday"]
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook3-Monthly"
      frequency   = "Month"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook1-Monthly"
      enabled     = false
      run_on      = ""
    }
  ]

  automation_variables = [
    {
      name      = "Runbook3-Environment"
      value     = "Dev"
      type      = "string"
      encrypted = false
    },
    {
      name      = "Runbook3-TestVar"
      value     = "runbook3testvar"
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
