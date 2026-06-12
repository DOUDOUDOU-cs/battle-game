Add-Type -AssemblyName System.Drawing
$src = 'C:\Users\38389\Documents\battle-game\assets\tileset\tileset_GrassTile.png'
$dst = 'C:\Users\38389\Documents\battle-game\assets\tileset\tileset_annotated.png'
$img = [System.Drawing.Bitmap]::new($src)
$tile = 16
$scale = 8
$font = New-Object System.Drawing.Font('Consolas', 10, [System.Drawing.FontStyle]::Bold)
$brushText = [System.Drawing.Brushes]::White
$brushShadow = [System.Drawing.Brushes]::Black
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180,255,0,0),1)
$out = New-Object System.Drawing.Bitmap ($img.Width * $scale), ($img.Height * $scale)
$g = [System.Drawing.Graphics]::FromImage($out)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($img, 0, 0, $out.Width, $out.Height)
for($x=0; $x -le $img.Width; $x += $tile){ $g.DrawLine($pen, $x*$scale, 0, $x*$scale, $out.Height) }
for($y=0; $y -le $img.Height; $y += $tile){ $g.DrawLine($pen, 0, $y*$scale, $out.Width, $y*$scale) }
for($ty=0; $ty -lt [int]($img.Height / $tile); $ty++){
  for($tx=0; $tx -lt [int]($img.Width / $tile); $tx++){
    $label = "$tx,$ty"
    $px = $tx*$tile*$scale + 6
    $py = $ty*$tile*$scale + 6
    $g.DrawString($label, $font, $brushShadow, $px+1, $py+1)
    $g.DrawString($label, $font, $brushText, $px, $py)
  }
}
$out.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $out.Dispose(); $img.Dispose(); $font.Dispose(); $pen.Dispose();
Write-Output $dst
