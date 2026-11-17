Add-Type -AssemblyName System.Drawing
$files=Get-ChildItem "$PSScriptRoot/../build/screenshots/sparkle-qa" -Filter *.png | Where-Object { $_.BaseName -notmatch '_(front|back|three_quarter)$' } | Sort-Object Name
$sheet=New-Object System.Drawing.Bitmap(1000,([int][Math]::Ceiling($files.Count/2)*170))
$g=[System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::WhiteSmoke)
$font=New-Object System.Drawing.Font('Arial',10)
$i=0
foreach($file in $files){
 $im=[System.Drawing.Image]::FromFile($file.FullName);$x=($i%2)*500;$y=[Math]::Floor($i/2)*170
 $g.DrawImage($im,[int]$x,[int]$y,480,140)
 $g.DrawString($file.BaseName,$font,[System.Drawing.Brushes]::Black,[single]($x+2),[single]($y+143))
 $im.Dispose();$i++
}
$sheet.Save([System.IO.Path]::GetFullPath("$PSScriptRoot/../build/screenshots/sparkle-wire-review.png"),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$sheet.Dispose();$font.Dispose()
