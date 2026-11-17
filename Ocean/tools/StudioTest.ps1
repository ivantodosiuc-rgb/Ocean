param([ValidateSet('Start','Stop')][string]$Action)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
$r=& "$PSScriptRoot/GetStudioRoot.ps1"
if(-not $r){throw 'Map Studio window not found'}
$a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$menu=$a | Where-Object {$_.Current.Name -eq 'Test' -and $_.Current.AutomationId -eq ''} | Select-Object -First 1
($menu.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)).Expand()
Start-Sleep -Milliseconds 400
$a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
if($Action -eq 'Start') {
 $entry=$a | Where-Object {$_.Current.Name -eq 'Start Test Session'} | Select-Object -First 1
 ($entry.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)).Expand()
 Start-Sleep -Milliseconds 250
 $a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
 $id='RBXMainWindow.simulationPlayAction'
} else {$id='RBXMainWindow.simulationResetAction'}
$target=$a | Where-Object {$_.Current.AutomationId -eq $id} | Select-Object -First 1
if(-not $target -or -not $target.Current.IsEnabled){throw "Test action unavailable: $id"}
($target.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)).Invoke()
Write-Output "Studio test action: $Action"
