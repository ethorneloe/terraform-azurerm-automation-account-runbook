<#

This Pester test suite is designed to validate the changes in an Azure Automation Account as defined in a Terraform plan.

It performs the following checks:

1. Loads the Terraform plan from a JSON file.
2. Extracts specific resource changes related to Azure Automation, such as schedules, job schedules, runbooks, and variables.
3. Defines the expected state of the runbooks, schedules, and variables based on the test Terraform files.
4. Iterates over each runbook to verify that the Terraform plan contains the expected resources.
5. Checks that enabled schedules and their associated job schedules exist in the plan, while disabled schedules and their job schedules do not.
6. Verifies that all defined variables for each runbook are present in the plan.
7. Confirms that the correct tags will be configured.
8. Ensures the total counts of each resource type in the plan match the expected counts.

#>

param (
    [Parameter(Mandatory)]
    [string]$PlanFilePath
)

Describe "Automation Account Resource Changes in Terraform Plan" {

    # Load the plan from the JSON file
    BeforeAll {

        $script:plan = Get-Content $PlanFilePath | ConvertFrom-Json

        # Extract the resource changes
        $script:planSchedules = $plan.resource_changes | Where-Object { $_.type -like 'azurerm_automation_schedule' } | Select-Object type, change
        $script:planJobSchedules = $plan.resource_changes | Where-Object { $_.type -like 'azurerm_automation_job_schedule' } | Select-Object type, change
        $script:planRunbooks = $plan.resource_changes | Where-Object { $_.type -like 'azurerm_automation_runbook' } | Select-Object type, change
        $script:planVariables = $plan.resource_changes | Where-Object { $_.type -like 'azurerm_automation_variable_string' } | Select-Object type, change

        $script:planRunbooks.change.after.tags

    }

    $runbooks = @(
        @{
            Name      = "Test-ExampleRunbook1"
            Schedules = @(
                @{ Name = "Runbook1-OneTime"; Enabled = $true },
                @{ Name = "Runbook1-Daily"; Enabled = $true },
                @{ Name = "Runbook1-Hourly"; Enabled = $true },
                @{ Name = "Runbook1-Weekly"; Enabled = $true },
                @{ Name = "Runbook1-Monthly"; Enabled = $true }
            )
            Variables = @(
                @{ Name = "Runbook1-Environment"; Encrypted = $false }
            )
            Tags      = @{
                "Environment" = "Dev"
                "ManagedBy"   = "Terraform"
                "Project"     = "Automation"
            }
        },
        @{
            Name      = "Test-ExampleRunbook2"
            Schedules = @(
                @{ Name = "Runbook2-OneTime"; Enabled = $true },
                @{ Name = "Runbook2-Daily"; Enabled = $false },
                @{ Name = "Runbook2-Hourly"; Enabled = $true },
                @{ Name = "Runbook2-Weekly"; Enabled = $false },
                @{ Name = "Runbook2-Monthly"; Enabled = $true }
            )
            Variables = @(
                @{ Name = "Runbook2-Secret"; Encrypted = $true },
                @{ Name = "Runbook2-TestVar"; Encrypted = $false }
            )
            Tags      = @{
                "Environment" = "Dev"
                "ManagedBy"   = "Terraform"
                "Project"     = "Automation"
            }
        },
        @{
            Name      = "Test-ExampleRunbook3"
            Schedules = @(
                @{ Name = "Runbook3-OneTime"; Enabled = $false },
                @{ Name = "Runbook3-Daily"; Enabled = $true },
                @{ Name = "Runbook3-Hourly"; Enabled = $false },
                @{ Name = "Runbook3-Weekly"; Enabled = $true },
                @{ Name = "Runbook3-Monthly"; Enabled = $false }
            )
            Variables = @(
                @{ Name = "Runbook3-Environment"; Encrypted = $false },
                @{ Name = "Runbook3-TestVar"; Encrypted = $false }
            )
            Tags      = @{
                "Environment" = "Dev"
                "ManagedBy"   = "Terraform"
                "Project"     = "Automation"
            }
        }
    )

    It "Should contain the expected automation account resources" -ForEach $runbooks {
        # Check Automation Runbook
        $runbookName = $_.Name

        $runbookResource = $planRunbooks | Where-Object { $_.change.after.name -eq $runbookName }
        $runbookResource | Should -Not -BeNullOrEmpty

        # Check Automation Schedules
        foreach ($schedule in $_.Schedules) {

            if ($schedule.Enabled) {

                $scheduleResource = $planSchedules | Where-Object { $_.change.after.name -eq $schedule.Name }
                $scheduleResource | Should -Not -BeNullOrEmpty

                $jobScheduleResource = $planJobSchedules | Where-Object { $_.change.after.schedule_name -eq $schedule.Name }
                $jobScheduleResource | Should -Not -BeNullOrEmpty
            }
            else {

                $scheduleResource = $planSchedules | Where-Object { $_.change.after.name -eq $schedule.Name }
                $scheduleResource | Should -BeNullOrEmpty

                $jobScheduleResource = $planJobSchedules | Where-Object { $_.change.after.name -eq $schedule.Name }
                $jobScheduleResource | Should -BeNullOrEmpty
            }

            # Check Automation Variables
            foreach ($variable in $_.Variables) {
                $variableResource = $planVariables | Where-Object { $_.change.after.name -eq $variable.Name }
                $variableResource | Should -Not -BeNullOrEmpty
            }

            # Check Runbook Tags
            $expectedTags = $_.Tags
            $actualTags = $runbookResource.change.after.tags
            foreach ($key in $expectedTags.Keys) {
                $actualTags.$key | Should -Be $expectedTags[$key]
            }
        }
    }

    It "Should have the correct total counts across automation account resource types" {
        $planRunbooks.Count | Should -Be 3
        $planSchedules.Count | Should -Be 10
        $planJobSchedules.Count | Should -Be 10
        $planVariables.Count | Should -Be 5
    }
}