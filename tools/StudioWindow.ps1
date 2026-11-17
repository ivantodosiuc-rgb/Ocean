param([ValidateSet('Capture','Command','Key','Click','LeftDown','LeftUp','RightDown','RightUp','PostClick','Inspect','Invoke','Move','Set')][string]$Action='Capture',[string]$ScriptPath,[string]$Keys,[int]$X,[int]$Y,[string]$Name,[string]$Value,[string]$Out='build/screenshots/studio-window.png')
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class StudioWin {
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb,IntPtr p);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 public static IntPtr FindStudio(int pid){IntPtr found=IntPtr.Zero;EnumWindows((h,p)=>{uint id;GetWindowThreadProcessId(h,out id);var s=new StringBuilder(1024);GetWindowText(h,s,1024);if(id==pid && s.ToString().Contains("SuckTheSea")){found=h;return false;}return true;},IntPtr.Zero);return found;}
 public static IntPtr FindCaption(int pid,string caption){IntPtr found=IntPtr.Zero;EnumWindows((h,p)=>{uint id;GetWindowThreadProcessId(h,out id);var s=new StringBuilder(1024);GetWindowText(h,s,1024);if(id==pid && s.ToString()==caption){found=h;return false;}return true;},IntPtr.Zero);return found;}
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
 [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int n);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out RECT r);
 [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h,IntPtr after,int x,int y,int w,int hgt,uint flags);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint flags);
 [DllImport("user32.dll")] public static extern IntPtr ChildWindowFromPointEx(IntPtr h,POINT p,uint flags);
 [DllImport("user32.dll")] public static extern bool ScreenToClient(IntPtr h,ref POINT p);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h,uint msg,IntPtr wp,IntPtr lp);
 public struct POINT {public int X;public int Y;}
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint flags,uint x,uint y,uint data,UIntPtr extra);
 public struct RECT {public int L;public int T;public int R;public int B;}
}
'@
[StudioWin]::SetProcessDPIAware() | Out-Null
[StudioWin]::SetThreadDpiAwarenessContext([IntPtr](-4)) | Out-Null
$studioProcess=$null
foreach($proc in (Get-Process RobloxStudioBeta)) {
 $handle=[StudioWin]::FindStudio($proc.Id)
 if($handle -ne [IntPtr]::Zero){$studioProcess=[PSCustomObject]@{Id=$proc.Id;MainWindowHandle=$handle};break}
}
if(-not $studioProcess){throw 'Target SuckTheSea Studio window not found'}
$targetHandle=$studioProcess.MainWindowHandle
if($Name -and $Action -in @('Capture','PostClick')) {
 $targetHandle=[StudioWin]::FindCaption($studioProcess.Id,$Name)
 if($targetHandle -eq [IntPtr]::Zero){throw "Popup window not found: $Name"}
}
if($Action -in @('Command','Key','Click','Move','PostClick')){[StudioWin]::ShowWindow($studioProcess.MainWindowHandle,9) | Out-Null}
if($Action -in @('Command','Key','Click','Move','PostClick')){[StudioWin]::SetForegroundWindow($studioProcess.MainWindowHandle) | Out-Null}
Start-Sleep -Milliseconds 400
if($Action -eq 'Move') {
 [StudioWin]::SetWindowPos($studioProcess.MainWindowHandle,[IntPtr]::Zero,80,60,1300,1000,0x40) | Out-Null
} elseif($Action -in @('Inspect','Invoke','Set')) {
 $root=[System.Windows.Automation.AutomationElement]::FromHandle($studioProcess.MainWindowHandle)
 $all=$root.FindAll([System.Windows.Automation.TreeScope]::Descendants,[System.Windows.Automation.Condition]::TrueCondition)
 if($Action -eq 'Inspect') {
  foreach($el in $all){if($el.Current.Name -and (!$Name -or $el.Current.Name -match $Name)) { $c=$el.Current;Write-Output ($c.ControlType.ProgrammaticName+' | '+$c.Name+' | '+$c.AutomationId+' | '+$c.BoundingRectangle.ToString()) }}
 } else {
  $el=$all | Where-Object {$_.Current.Name -eq $Name} | Select-Object -First 1
  if(-not $el){throw "Control not found: $Name"}
  if($Action -eq 'Invoke'){($el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)).Invoke()}
  else {($el.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)).SetValue($Value)}
 }
} elseif($Action -eq 'Command') {
 $code=Get-Content -Raw -Encoding UTF8 -LiteralPath $ScriptPath
 $root=[System.Windows.Automation.AutomationElement]::FromHandle($studioProcess.MainWindowHandle)
 $toolbar=$root.FindFirst([System.Windows.Automation.TreeScope]::Descendants,(New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty,'Command')))
 if(-not $toolbar){throw 'Command toolbar not visible'}
 $edit=$toolbar.FindFirst([System.Windows.Automation.TreeScope]::Descendants,(New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty,[System.Windows.Automation.ControlType]::Edit)))
 ($edit.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)).SetValue($code)
 $runButton=$toolbar.FindFirst([System.Windows.Automation.TreeScope]::Descendants,(New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty,'Run')))
 ($runButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)).Invoke()
} elseif($Action -eq 'PostClick') {
 $rect=New-Object StudioWin+RECT
 [StudioWin]::GetWindowRect($targetHandle,[ref]$rect) | Out-Null
 $screenPoint=New-Object StudioWin+POINT
 $screenPoint.X=$rect.L+$X;$screenPoint.Y=$rect.T+$Y
 $target=$targetHandle
 for($i=0;$i -lt 10;$i++) {
  $point=$screenPoint
  [StudioWin]::ScreenToClient($target,[ref]$point) | Out-Null
  $child=[StudioWin]::ChildWindowFromPointEx($target,$point,5)
  if($child -eq [IntPtr]::Zero -or $child -eq $target){break}
  $target=$child
 }
 $point=$screenPoint
 [StudioWin]::ScreenToClient($target,[ref]$point) | Out-Null
 $lp=[IntPtr](($point.Y -shl 16) -bor ($point.X -band 65535))
 [StudioWin]::PostMessage($target,0x201,[IntPtr]1,$lp) | Out-Null
 [StudioWin]::PostMessage($target,0x202,[IntPtr]0,$lp) | Out-Null
 if($Value) {
  Start-Sleep -Milliseconds 150
  [StudioWin]::PostMessage($target,0x100,[IntPtr]0x24,[IntPtr]0) | Out-Null
  [StudioWin]::PostMessage($target,0x101,[IntPtr]0x24,[IntPtr]0) | Out-Null
  for($i=0;$i -lt 16;$i++) {
   [StudioWin]::PostMessage($target,0x100,[IntPtr]0x2E,[IntPtr]0) | Out-Null
   [StudioWin]::PostMessage($target,0x101,[IntPtr]0x2E,[IntPtr]0) | Out-Null
  }
  foreach($ch in $Value.ToCharArray()){[StudioWin]::PostMessage($target,0x102,[IntPtr]([int]$ch),[IntPtr]0) | Out-Null}
  [StudioWin]::PostMessage($target,0x100,[IntPtr]0x0D,[IntPtr]0) | Out-Null
  [StudioWin]::PostMessage($target,0x101,[IntPtr]0x0D,[IntPtr]0) | Out-Null
 }
 Write-Output "Target $target point $($point.X),$($point.Y)"
} elseif($Action -in @('Click','LeftDown','LeftUp','RightDown','RightUp')) {
 $rect=New-Object StudioWin+RECT
 [StudioWin]::GetWindowRect($studioProcess.MainWindowHandle,[ref]$rect) | Out-Null
 [StudioWin]::SetCursorPos($rect.L+$X,$rect.T+$Y) | Out-Null
 Start-Sleep -Milliseconds 150
 if($Action -eq 'Click') {
  [StudioWin]::mouse_event(2,0,0,0,[UIntPtr]::Zero)
  Start-Sleep -Milliseconds 80
  [StudioWin]::mouse_event(4,0,0,0,[UIntPtr]::Zero)
 } else { [StudioWin]::mouse_event($(switch($Action){'LeftDown'{2};'LeftUp'{4};'RightDown'{8};'RightUp'{16}}),0,0,0,[UIntPtr]::Zero) }
} elseif($Action -eq 'Key') {
 [System.Windows.Forms.SendKeys]::SendWait($Keys)
} else {
 $rect=New-Object StudioWin+RECT
 [StudioWin]::GetWindowRect($targetHandle,[ref]$rect) | Out-Null
 $bmp=New-Object System.Drawing.Bitmap(($rect.R-$rect.L),($rect.B-$rect.T))
 $graphics=[System.Drawing.Graphics]::FromImage($bmp)
 $dc=$graphics.GetHdc()
 $printed=[StudioWin]::PrintWindow($targetHandle,$dc,2)
 $graphics.ReleaseHdc($dc)
 if(-not $printed){throw 'Studio window capture failed'}
 $fullOut=[System.IO.Path]::GetFullPath($Out)
 [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($fullOut)) | Out-Null
 $bmp.Save($fullOut,[System.Drawing.Imaging.ImageFormat]::Png)
 $graphics.Dispose();$bmp.Dispose()
 Write-Output $fullOut
}
