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
      name        = "Runbook3-Daily1"
      frequency   = "Day"
      interval    = 1
      start_time  = "2024-09-19T01:00:00+10:00"
      description = "Runbook3-Daily1"
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook3-Daily2"
      frequency   = "Day"
      interval    = 1
      start_time  = "2024-09-19T01:00:00+10:00"
      description = "Runbook3-Daily2"
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook3-Weekly1"
      frequency   = "Week"
      interval    = 1
      start_time  = "2024-09-19T01:00:00+10:00"
      description = "Runbook3-Weekly1"
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook3-Weekly2"
      frequency   = "Week"
      interval    = 1
      start_time  = "2024-09-19T01:00:00+10:00"
      description = "Runbook3-Weekly2"
      week_days   = ["Monday", "Friday"]
      run_on      = ""
    },
    {
      name        = "Runbook3-Weekly3"
      frequency   = "Week"
      interval    = 1
      start_time  = "2024-09-19T01:00:00+10:00"
      description = "Runbook3-Weekly3"
      week_days   = ["Tuesday", "Friday"]
      run_on      = ""
    }
  ]

  automation_variables = [
    {
      name      = "Runbook3-Environment"
      value     = "Dev"
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
