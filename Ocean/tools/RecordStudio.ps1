param([string]$Out='build/animation-frames-final',[int]$Frames=80,[int]$Fps=12)
$ErrorActionPreference='Stop'
$recordDirectory=[System.IO.Path]::GetFullPath($Out)
[System.IO.Directory]::CreateDirectory($recordDirectory) | Out-Null
. (Join-Path $PSScriptRoot 'StudioWindow.ps1') -Action Capture -Out (Join-Path $recordDirectory 'preview.png')
$rect=New-Object StudioWin+RECT
[StudioWin]::GetWindowRect($targetHandle,[ref]$rect) | Out-Null
$watch=[System.Diagnostics.Stopwatch]::StartNew()
for($frameIndex=0;$frameIndex -lt $Frames;$frameIndex++) {
 $targetMillis=$frameIndex*1000/$Fps
 $delay=[int]($targetMillis-$watch.ElapsedMilliseconds)
 if($delay -gt 0){Start-Sleep -Milliseconds $delay}
 $bmp=New-Object System.Drawing.Bitmap(($rect.R-$rect.L),($rect.B-$rect.T))
 $graphics=[System.Drawing.Graphics]::FromImage($bmp);$dc=$graphics.GetHdc()
 [StudioWin]::PrintWindow($targetHandle,$dc,2) | Out-Null
 $graphics.ReleaseHdc($dc)
 $bmp.Save((Join-Path $recordDirectory ($frameIndex.ToString('D5')+'.jpg')),[System.Drawing.Imaging.ImageFormat]::Jpeg)
 $graphics.Dispose();$bmp.Dispose()
}
Write-Output "Recorded $Frames frames in $($watch.ElapsedMilliseconds) ms"
[PSCustomObject]@{frames=$Frames;fps=[Math]::Round(($Frames-1)*1000/$watch.ElapsedMilliseconds);elapsedMs=$watch.ElapsedMilliseconds} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $recordDirectory 'timing.json')
