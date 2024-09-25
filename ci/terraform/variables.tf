variable "location" {
  description = "The Azure region for the automation account"
  default     = "australiaeast"
}

variable "automation_schedule_timezone" {
  description = "The timezone for schedules"
  default     = "Australia/Brisbane"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "automation_account_name" {
  type        = string
  description = "The name of the automation account."
}
