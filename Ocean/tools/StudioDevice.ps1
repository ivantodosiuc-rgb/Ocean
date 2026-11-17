param([ValidateSet('Off','On')][string]$Action='Off')
$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
$r=[System.Windows.Automation.AutomationElement]::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children,[System.Windows.Automation.Condition]::TrueCondition) | Where-Object {$_.Current.Name -like '*SuckTheSea*'} | Select-Object -First 1
$a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$menu=$a | Where-Object {$_.Current.Name -eq 'Test' -and $_.Current.AutomationId -eq ''} | Select-Object -First 1
($menu.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)).Expand()
$a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$entry=$a | Where-Object {$_.Current.Name -eq 'Device Simulator'} | Select-Object -First 1
if(-not $entry.Current.IsEnabled){throw 'Stop Play before switching simulator'}
$toggle=$entry.GetCurrentPattern([System.Windows.Automation.TogglePattern]::Pattern)
$isOn=$toggle.Current.ToggleState -eq [System.Windows.Automation.ToggleState]::On
if($isOn -ne ($Action -eq 'On')){$toggle.Toggle()}
Write-Output "Device Simulator: $Action"
