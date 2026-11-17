Add-Type -AssemblyName System.Drawing
$files=Get-ChildItem "$PSScriptRoot/../build/screenshots/comfort-qa" -Filter *.png | Sort-Object Name
$sheet=New-Object System.Drawing.Bitmap(1200,([int][Math]::Ceiling($files.Count/8)*180))
$g=[System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::WhiteSmoke)
$font=New-Object System.Drawing.Font('Arial',8)
$i=0
foreach($file in $files){
 $im=[System.Drawing.Image]::FromFile($file.FullName);$x=($i%8)*150;$y=[Math]::Floor($i/8)*180
 $g.DrawImage($im,[int]$x,[int]$y,145,145)
 $label=$file.BaseName.Replace('Tool__','').Replace('Restroom__','WC_')
 if($label.Length -gt 23){$label=$label.Substring(0,23)}
 $g.DrawString($label,$font,[System.Drawing.Brushes]::Black,[single]($x+2),[single]($y+145))
 $im.Dispose();$i++
}
$sheet.Save([System.IO.Path]::GetFullPath("$PSScriptRoot/../build/screenshots/comfort-wire-review.png"),[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$sheet.Dispose();$font.Dispose()
