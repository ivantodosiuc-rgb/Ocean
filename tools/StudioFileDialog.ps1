param([string]$File)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type @'
using System;using System.Runtime.InteropServices;
public class DialogSend {
 [DllImport("user32.dll",CharSet=CharSet.Unicode)]public static extern IntPtr SendMessage(IntPtr h,uint m,IntPtr w,string text);
 [DllImport("user32.dll")]public static extern bool PostMessage(IntPtr h,uint m,IntPtr w,IntPtr l);
}
'@
$r=& "$PSScriptRoot/GetStudioRoot.ps1"
$a=$r.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
$filename=$a | Where-Object {$_.Current.AutomationId -eq '1148' -and $_.Current.NativeWindowHandle -ne 0} | Select-Object -Last 1
if(-not $filename){throw 'Native file name field not found'}
[DialogSend]::SendMessage([IntPtr]$filename.Current.NativeWindowHandle,12,[IntPtr]::Zero,[System.IO.Path]::GetFullPath($File)) | Out-Null
$open=$a | Where-Object {$_.Current.Name -eq 'Open' -and $_.Current.AutomationId -eq '1'} | Select-Object -First 1
if(-not $open){throw 'Open button not found'}
[DialogSend]::PostMessage([IntPtr]$open.Current.NativeWindowHandle,0xF5,[IntPtr]::Zero,[IntPtr]::Zero) | Out-Null
