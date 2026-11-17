$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
if(-not ('SeaStudioRoot' -as [type])) {
Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class SeaStudioRoot {
 public delegate bool EnumProc(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb,IntPtr p);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 public static IntPtr Find(int pid) {
  IntPtr found=IntPtr.Zero;
  EnumWindows((h,p)=>{uint id;GetWindowThreadProcessId(h,out id);var s=new StringBuilder(1024);GetWindowText(h,s,1024);if(id==pid && s.ToString().Contains("SuckTheSea")){found=h;return false;}return true;},IntPtr.Zero);
  return found;
 }
}
'@
}
foreach($studioProcess in Get-Process RobloxStudioBeta) {
 $studioHandle=[SeaStudioRoot]::Find($studioProcess.Id)
 if($studioHandle -ne [IntPtr]::Zero) {
  return [System.Windows.Automation.AutomationElement]::FromHandle($studioHandle)
 }
}
throw 'Target SuckTheSea Studio window not found'
