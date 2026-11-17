$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
$root=& "$PSScriptRoot/GetStudioRoot.ps1"
if(-not $root){throw 'Target SuckTheSea document not found'}
$all=$root.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$file=$all | Where-Object {$_.Current.Name -eq 'File' -and $_.Current.ControlType -eq [System.Windows.Automation.ControlType]::MenuItem} | Select-Object -First 1
($file.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)).Expand()
Start-Sleep -Milliseconds 300
$all=$root.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$save=$all | Where-Object {$_.Current.Name -eq 'Save to File'} | Select-Object -First 1
if(-not $save -or -not $save.Current.IsEnabled){throw 'Save to File action is unavailable'}
($save.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)).Invoke()
Write-Output 'Local save requested'
