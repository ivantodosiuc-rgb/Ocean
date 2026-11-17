param([ValidateSet('Client','Server')][string]$Context)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
$r=& "$PSScriptRoot/GetStudioRoot.ps1"
$a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$tab=$a | Where-Object {$_.Current.Name -eq $Context -and $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::TabItem} | Select-Object -First 1
if(-not $tab){throw "Context tab not found: $Context"}
($tab.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)).Invoke()
Start-Sleep -Milliseconds 300
Write-Output "Studio context: $Context"
