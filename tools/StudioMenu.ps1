param([Parameter(Mandatory=$true)][string]$Name)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
function TryInvoke {
 foreach($p in (Get-Process RobloxStudioBeta)){
  $condition=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty,$p.Id)
  $wins=[System.Windows.Automation.AutomationElement]::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children,$condition)
  foreach($win in $wins){
   $els=$win.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
   foreach($el in $els){if($el.Current.Name -eq $Name){($el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)).Invoke();return $true}}
  }
 }
 return $false
}
if(-not (TryInvoke)){
 & "$PSScriptRoot/StudioWindow.ps1" -Action PostClick -X 24 -Y 41
 Start-Sleep -Milliseconds 400
 if(-not (TryInvoke)){throw "Menu action unavailable: $Name"}
}
Start-Sleep -Milliseconds 500
foreach($p in (Get-Process RobloxStudioBeta)){
 $condition=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ProcessIdProperty,$p.Id)
 $wins=[System.Windows.Automation.AutomationElement]::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children,$condition)
 foreach($win in $wins){$els=$win.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition);foreach($el in $els){if($el.Current.ControlType -eq [System.Windows.Automation.ControlType]::Button){Write-Output ($el.Current.Name+' | '+$el.Current.AutomationId)}}}
}
