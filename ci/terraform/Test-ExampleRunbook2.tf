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
      name        = "Runbook2-Daily"
      frequency   = "Day"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook2-Daily1"
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook2-Daily2"
      frequency   = "Day"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook2-Daily2"
      enabled     = true
      run_on      = ""
    },
    {
      name        = "Runbook2-Weekly1"
      frequency   = "Week"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook2-Weekly1"
      enabled     = false
      run_on      = ""
    },
    {
      name        = "Runbook2-Weekly2"
      frequency   = "Week"
      interval    = 1
      start_time  = "2050-09-19T01:00:00+10:00"
      description = "Runbook2-Weekly2"
      week_days   = ["Monday", "Friday"]
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
      name      = "Runbook2-TestVal1"
      value     = "testval1"
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
