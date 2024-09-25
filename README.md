# Azure Automation Runbook Terraform module
Terraform module for creating runbooks in an existing Azure automation account.

Support schedules, automation variables, and `run_on` for specifying a hybrid worker pool.
## Usage

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.40.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_job_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_variable_bool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_bool) | resource |
| [azurerm_automation_variable_datetime.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_datetime) | resource |
| [azurerm_automation_variable_int.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_int) | resource |
| [azurerm_automation_variable_object.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_object) | resource |
| [azurerm_automation_variable_string.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | Automation Account name | `string` | n/a | yes |
| <a name="input_automation_variables"></a> [automation\_variables](#input\_automation\_variables) | Automation variables needed for this runbook | <pre>list(object({<br>    name        = string<br>    description = optional(string, "Managed by Terraform")<br>    encrypted   = optional(bool, false)<br>    type        = optional(string, "string")  # Should be one of: "int", "string", "object"<br>    value       = optional(any)     # This can be an int, string, or map, depending on `type`<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name containing the existing Automation Account | `string` | n/a | yes |
| <a name="input_runbook"></a> [runbook](#input\_runbook) | The Automation Runbook properties | <pre>object({<br>    name         = string<br>    description  = optional(string)<br>    script_path  = optional(string)<br>    content      = optional(string)<br>    log_verbose  = optional(bool, true)<br>    log_progress = optional(bool, true)<br>    runbook_type = optional(string, "PowerShell72")<br>  })</pre> | n/a | yes |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Schedules needed for this runbook | <pre>set(object({<br>    name        = string<br>    description = optional(string)<br>    frequency   = string<br>    interval    = optional(string, "1")<br>    start_time  = optional(string, null)<br>    week_days   = optional(list(string), ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])<br>    parameters  = optional(any, {})<br>    enabled     = optional(bool, true)<br>    run_on      = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(any)` | `{}` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for schedules | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runbook_id"></a> [runbook\_id](#output\_runbook\_id) | Automation Runbook Id |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](./LICENSE)
