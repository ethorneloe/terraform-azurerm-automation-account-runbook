param (
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [string]$AutomationAccountName
)

Describe "Test Azure Automation Runbook and Related Resource Creation" {
    # Define the expected resources for each runbook
    $runbooks = @(
        @{
            Name = "Test-ExampleRunbook1"
            Schedules = @("Runbook1-OneTime", "Runbook1-Daily", "Runbook1-Hourly", "Runbook1-Weekly", "Runbook1-Monthly")
            Variables = @("Runbook1-Environment")
        },
        @{
            Name = "Test-ExampleRunbook2"
            Schedules = @("Runbook2-OneTime", "Runbook2-Daily", "Runbook2-Hourly", "Runbook2-Weekly", "Runbook2-Monthly")
            Variables = @("Runbook2-Secret", "Runbook2-TestVar")
        },
        @{
            Name = "Test-ExampleRunbook3"
            Schedules = @("Runbook3-OneTime", "Runbook3-Daily", "Runbook3-Hourly", "Runbook3-Weekly", "Runbook3-Monthly")
            Variables = @("Runbook3-Environment", "Runbook3-TestVar")
        }
    )

    foreach ($runbook in $runbooks) {
        Context "Runbook $($runbook.Name)" {
            It "Should contain the expected automation account resources" {
                # Check Automation Runbook
                $runbookResource = Get-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $runbook.Name
                $runbookResource | Should -Not -BeNullOrEmpty
                $runbookResource.Name | Should -Be $runbook.Name

                # Check Automation Schedules
                foreach ($scheduleName in $runbook.Schedules) {
                    $schedule = Get-AzAutomationSchedule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $scheduleName
                    $schedule | Should -Not -BeNullOrEmpty
                    $schedule.Name | Should -Be $scheduleName
                }

                # Check Automation Variables
                foreach ($variableName in $runbook.Variables) {
                    $variable = Get-AzAutomationVariable -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $variableName
                    $variable | Should -Not -BeNullOrEmpty
                    $variable.Name | Should -Be $variableName
                }
            }

            It "Should execute the runbook and collect the output" {
                # Start the Runbook
                $job = Start-AzAutomationRunbook -AutomationAccountName $AutomationAccountName `
                                                 -ResourceGroupName $ResourceGroupName `
                                                 -Name $runbook.Name `
                                                 -Parameters @{} -Wait

                # Wait for the job to complete
                $job | Wait-AzAutomationJob -Timeout 600

                # Get the job output
                $output = Get-AzAutomationJobOutput -ResourceGroupName $ResourceGroupName `
                                                    -AutomationAccountName $AutomationAccountName `
                                                    -Id $job.JobId -Stream Output

                # Check the output
                $output | Should -Not -BeNullOrEmpty
            }
        }
    }
}