variable "resource_group_name" {
  type        = string
  description = "Resource group name containing the existing Automation Account"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "automation_account_name" {
  type        = string
  description = "Automation Account name"
}

variable "timezone" {
  type        = string
  description = "Timezone for schedules"
}

variable "tags" {
  type        = map(any)
  description = "Resource tags"
  default     = {}
}

variable "runbook" {
  type = object({
    name         = string
    description  = optional(string)
    script_path  = optional(string)
    content      = optional(string)
    log_verbose  = optional(bool, true)
    log_progress = optional(bool, true)
    runbook_type = optional(string, "PowerShell72")
  })
  description = "The Automation Runbook properties"

  validation {
    condition     = contains(["Graph", "GraphPowerShell", "GraphPowerShellWorkflow", "PowerShellWorkflow", "PowerShell", "PowerShell72", "Python3", "Python2", "Script"], var.runbook.runbook_type)
    error_message = "runbook_type must be one of: Graph, GraphPowerShell, GraphPowerShellWorkflow, PowerShellWorkflow, PowerShell, PowerShell72, Python3, Python2, Script."
  }
}

variable "schedules" {
  type = set(object({
    name        = string
    description = optional(string)
    frequency   = optional(string)
    interval    = optional(string, "1")
    start_time  = optional(string, null)
    week_days   = optional(list(string), ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    parameters  = optional(any, {})
    enabled     = optional(bool, true)
    run_on      = optional(string)
  }))
  description = "Schedules needed for this runbook"

  default = []

  validation {
    condition = alltrue([
      for i in var.schedules : contains(["OneTime", "Day", "Hour", "Week", "Month"], i.frequency)
    ])
    error_message = "frequency must be set to 'OneTime', 'Day', 'Hour', 'Week', or 'Month'."
  }
}

variable "automation_variables" {
  type = set(object({
    name        = string
    description = optional(string, "Managed by Terraform")
    encrypted   = optional(bool, false)
    type        = optional(string, "string") # Should be one of: "int", "string", "object"
    value       = optional(any)              # This can be an int, string, or map, depending on `type`
  }))
  description = "Automation variables needed for this runbook"

  default = []

  validation {
    condition = alltrue([
      for i in var.automation_variables : contains(["int", "string", "object", "datetime"], i.type)
    ])
    error_message = "Automation variable type must be 'int', 'string', 'object', or 'datetime'."
  }
}
