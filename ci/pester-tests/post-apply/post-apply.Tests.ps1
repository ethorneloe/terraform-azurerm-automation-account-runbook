<#

This Pester test suite is designed to validate the creation and execution of Azure Automation Runbooks and related resources after a Terraform apply.

It performs the following checks:

1. Defines the expected state of the runbooks, schedules, and variables based on the test Terraform files.
2. Iterates over each runbook to verify that the Azure Automation Account contains the expected resources.
3. Checks that enabled schedules exist in the Azure Automation Account.
4. Verifies that all defined variables for each runbook are present in the Azure Automation Account.
5. Executes each runbook and verifies that the job completes successfully.
6. Ensures that the output of each runbook execution matches the expected output.

#>

param (
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [string]$AutomationAccountName
)

Describe "Test Azure Automation Runbook and Related Resource Creation" {

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

        Write-Host "Checking Runbook: $runbookName"

        $runbookResource = Get-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $runbookName
        $runbookResource | Should -Not -BeNullOrEmpty
        $runbookResource.Name | Should -Be $runbookName

        # Check Automation Schedules
        foreach ($schedule in $_.Schedules) {
            if ($schedule.Enabled) {
                $scheduleResource = Get-AzAutomationSchedule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $schedule.Name
                $scheduleResource | Should -Not -BeNullOrEmpty
                $scheduleResource.Name | Should -Be $schedule.Name
            }
        }

        # Check Automation Variables
        foreach ($variable in $_.Variables) {
            $variableResource = Get-AzAutomationVariable -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $variable.Name
            $variableResource | Should -Not -BeNullOrEmpty
            $variableResource.Name | Should -Be $variable.Name
            $variableResource.Encrypted | Should -Be $variable.Encrypted
        }

        # Check Runbook Tags
        foreach ($key in $_.Tags.Keys) {
            $runbookResource.Tags[$key] | Should -Be $_.Tags[$key]
        }
    }

    It "Should execute job successfully and return output in standard output stream" -ForEach $runbooks {

        $runbookName = $_.Name

        Write-Host "Executing Runbook: $runbookName"

        # Execute Runbook and Grab Output
        $job = Start-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $runbookName
        $job | Should -Not -BeNullOrEmpty

        # Wait for the job to complete with a maximum of 12 iterations (1 minute)
        $jobStatus = $null
        for ($i = 0; $i -lt 12; $i++) {
            Write-Host "...Waiting for job to complete..."
            Start-Sleep -Seconds 10
            $job = Get-AzAutomationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Id $job.JobId
            $jobStatus = $job.Status
            if ($jobStatus -eq "Completed" -or $jobStatus -eq "Failed" -or $jobStatus -eq "Suspended") {
                break
            }
        }

        # Check job status
        $jobStatus | Should -Be "Completed"

        # Get job output
        $jobOutput = Get-AzAutomationJobOutput -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Id $job.JobId -Stream Output | Select-Object -ExpandProperty Summary
        $jobOutput | Should -eq $runbookName

    }
}