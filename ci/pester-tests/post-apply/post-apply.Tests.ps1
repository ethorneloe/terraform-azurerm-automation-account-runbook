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
            Schedules = @("Runbook1-OneTime", "Runbook1-Daily", "Runbook1-Hourly", "Runbook1-Weekly", "Runbook1-Monthly")
            Variables = @("Runbook1-Environment")
        },
        @{
            Name      = "Test-ExampleRunbook2"
            Schedules = @("Runbook2-OneTime", "Runbook2-Daily", "Runbook2-Hourly", "Runbook2-Weekly", "Runbook2-Monthly")
            Variables = @("Runbook2-Secret", "Runbook2-TestVar")
        },
        @{
            Name      = "Test-ExampleRunbook3"
            Schedules = @("Runbook3-OneTime", "Runbook3-Daily", "Runbook3-Hourly", "Runbook3-Weekly", "Runbook3-Monthly")
            Variables = @("Runbook3-Environment", "Runbook3-TestVar")
        }
    )

    It "Should contain the expected automation account resources" -ForEach $runbooks {
        $runbookName = $_.Name
        # Check Automation Runbook
        Write-Host "Testing - $runbookName"
        $runbookResource = Get-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $runbookName
        $runbookResource | Should -Not -BeNullOrEmpty
        $runbookResource.Name | Should -Be $runbookName

        # Check Automation Schedules
        foreach ($scheduleName in $_.Schedules) {
            $schedule = Get-AzAutomationSchedule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $scheduleName
            $schedule | Should -Not -BeNullOrEmpty
            $schedule.Name | Should -Be $scheduleName
        }

        # Check Automation Variables
        foreach ($variableName in $_.Variables) {
            $variable = Get-AzAutomationVariable -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $variableName
            $variable | Should -Not -BeNullOrEmpty
            $variable.Name | Should -Be $variableName
        }
    }
}