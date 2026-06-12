Add-Type -AssemblyName System.Drawing

function Test-BackgroundColor([System.Drawing.Color]$color) {
    $max = [Math]::Max($color.R, [Math]::Max($color.G, $color.B)) / 255.0
    $min = [Math]::Min($color.R, [Math]::Min($color.G, $color.B)) / 255.0
    $sat = $max - $min
    return ($max -ge 0.70 -and $sat -le 0.28)
}

function Convert-ToTransparentPng([string]$inputPath, [string]$outputPath) {
    $bitmap = [System.Drawing.Bitmap]::new($inputPath)
    $result = [System.Drawing.Bitmap]::new($bitmap.Width, $bitmap.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $width = $bitmap.Width
    $height = $bitmap.Height
    $lastX = $width - 1
    $lastY = $height - 1

    $visited = New-Object 'bool[,]' $width, $height
    $queue = New-Object 'System.Collections.Generic.Queue[System.Drawing.Point]'

    function Enqueue-IfBackground([int]$x, [int]$y) {
        if ($x -lt 0 -or $y -lt 0 -or $x -gt $script:lastX -or $y -gt $script:lastY) { return }
        if ($script:visited[$x, $y]) { return }
        $color = $script:bitmap.GetPixel($x, $y)
        if (-not (Test-BackgroundColor $color)) { return }
        $script:visited[$x, $y] = $true
        $script:queue.Enqueue([System.Drawing.Point]::new($x, $y))
    }

    for ($x = 0; $x -le $lastX; $x++) {
        Enqueue-IfBackground $x 0
        Enqueue-IfBackground $x $lastY
    }
    for ($y = 0; $y -le $lastY; $y++) {
        Enqueue-IfBackground 0 $y
        Enqueue-IfBackground $lastX $y
    }

    while ($queue.Count -gt 0) {
        $point = $queue.Dequeue()
        Enqueue-IfBackground ($point.X + 1) $point.Y
        Enqueue-IfBackground ($point.X - 1) $point.Y
        Enqueue-IfBackground $point.X ($point.Y + 1)
        Enqueue-IfBackground $point.X ($point.Y - 1)
    }

    for ($y = 0; $y -le $lastY; $y++) {
        for ($x = 0; $x -le $lastX; $x++) {
            $color = $bitmap.GetPixel($x, $y)
            if ($visited[$x, $y]) {
                $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, $color.R, $color.G, $color.B))
                continue
            }

            $alpha = 255
            $max = [Math]::Max($color.R, [Math]::Max($color.G, $color.B)) / 255.0
            $min = [Math]::Min($color.R, [Math]::Min($color.G, $color.B)) / 255.0
            $sat = $max - $min
            if ($max -ge 0.68 -and $sat -le 0.34) {
                $touchesBackground = $false
                for ($oy = -1; $oy -le 1; $oy++) {
                    for ($ox = -1; $ox -le 1; $ox++) {
                        if ($ox -eq 0 -and $oy -eq 0) { continue }
                        $nx = $x + $ox
                        $ny = $y + $oy
                        if ($nx -lt 0 -or $ny -lt 0 -or $nx -gt $lastX -or $ny -gt $lastY) { continue }
                        if ($visited[$nx, $ny]) { $touchesBackground = $true }
                    }
                }
                if ($touchesBackground) { $alpha = 110 }
            }

            $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $color.R, $color.G, $color.B))
        }
    }

    $result.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    $result.Dispose()
}

Convert-ToTransparentPng 'C:\Users\38389\Documents\battle-game\assets\mushroom.webp' 'C:\Users\38389\Documents\battle-game\assets\mushroom.png'
Convert-ToTransparentPng 'C:\Users\38389\Documents\battle-game\assets\gel.jpg' 'C:\Users\38389\Documents\battle-game\assets\gel.png'
Write-Output 'done'
