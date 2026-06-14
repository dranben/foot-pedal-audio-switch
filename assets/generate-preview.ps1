# Generates assets/social-preview.png (1280x640) — GitHub social card + README banner.
Add-Type -AssemblyName System.Drawing
$W, $H = 1280, 640
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'ClearTypeGridFit'

function RoundRect($x, $y, $w, $h, $r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}
function C($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Brush($hex) { New-Object System.Drawing.SolidBrush (C $hex) }
function Font($name, $size, $style) { New-Object System.Drawing.Font $name, $size, ([System.Drawing.FontStyle]$style) }

# --- Background: diagonal gradient ---
$bgRect = New-Object System.Drawing.Rectangle 0, 0, $W, $H
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush $bgRect, (C '#0B1220'), (C '#141E33'), 45
$g.FillRectangle($bg, $bgRect)

# subtle accent glow stripe on the left
$stripe = New-Object System.Drawing.Drawing2D.LinearGradientBrush $bgRect, (C '#1F6FEB'), (C '#0B1220'), 0
$g.FillRectangle($stripe, (New-Object System.Drawing.Rectangle 0, 0, 12, $H))

$white = Brush '#E6EDF3'
$muted = Brush '#8B949E'
$blue  = Brush '#58A6FF'
$green = Brush '#3FB950'

# --- Title + subtitle ---
$g.DrawString("Foot Pedal Audio Switch", (Font 'Segoe UI Semibold' 60 'Bold'), $white, 70, 64)
$g.DrawString("Tap a USB foot pedal to switch your Windows sound -", (Font 'Segoe UI' 27 'Regular'), $muted, 74, 168)
$g.DrawString("hands never leave the keyboard.", (Font 'Segoe UI' 27 'Regular'), $muted, 74, 208)

# --- Diagram row (y ~ 300..470) ---
$cy = 330
# Pedal box
$pedal = RoundRect 80 $cy 230 150 22
$g.FillPath((Brush '#172033'), $pedal)
$g.DrawPath((New-Object System.Drawing.Pen((C '#2A3754'), 2)), $pedal)
$cf = New-Object System.Drawing.StringFormat; $cf.Alignment = 'Center'; $cf.LineAlignment = 'Center'
$g.DrawString("FOOT PEDAL", (Font 'Segoe UI Semibold' 22 'Bold'), $white, (New-Object System.Drawing.RectangleF 80, ($cy+34), 230, 40), $cf)
$g.DrawString("tap", (Font 'Segoe UI' 20 'Italic'), $muted, (New-Object System.Drawing.RectangleF 80, ($cy+78), 230, 36), $cf)

# Arrow with F24 label
$pen = New-Object System.Drawing.Pen((C '#58A6FF'), 5); $pen.EndCap = 'ArrowAnchor'
$ax1, $ax2, $ay = 330, 470, ($cy + 75)
$g.DrawLine($pen, $ax1, $ay, $ax2, $ay)
$g.DrawString("sends F24", (Font 'Consolas' 18 'Bold'), $blue, 318, ($ay - 44))

# Two device chips with a toggle
$chipX = 500; $chipW = 300
$hp = RoundRect $chipX $cy $chipW 64 16
$g.FillPath((Brush '#102A1A'), $hp)
$g.DrawPath((New-Object System.Drawing.Pen((C '#3FB950'), 2)), $hp)
$g.FillEllipse($green, ($chipX + 24), ($cy + 22), 20, 20)
$g.DrawString("Headphones", (Font 'Segoe UI Semibold' 24 'Bold'), $white, ($chipX + 64), ($cy + 15))

$sy = $cy + 86
$sp = RoundRect $chipX $sy $chipW 64 16
$g.FillPath((Brush '#172033'), $sp)
$g.DrawPath((New-Object System.Drawing.Pen((C '#2A3754'), 2)), $sp)
$ring = New-Object System.Drawing.Pen((C '#8B949E'), 3)
$g.DrawEllipse($ring, ($chipX + 24), ($sy + 22), 20, 20)
$g.DrawString("Speakers", (Font 'Segoe UI Semibold' 24 'Bold'), $muted, ($chipX + 64), ($sy + 15))

# ⇄ to the right of the chips, vertically centered between them
$g.DrawString([char]0x21C4, (Font 'Segoe UI' 34 'Bold'), $blue, ($chipX + $chipW + 22), ($cy + 52))

# --- Bottom strip: badges + URL, both centered on their own line ---
$ctr = New-Object System.Drawing.StringFormat; $ctr.Alignment = 'Center'
$sep = "      " + [char]0x00B7 + "      "
$badges = "Windows 10 / 11" + $sep + "AutoHotkey v2" + $sep + "PowerShell" + $sep + "MIT"
$g.DrawString($badges, (Font 'Segoe UI' 21 'Regular'), $muted, (New-Object System.Drawing.RectangleF 0, 520, $W, 32), $ctr)
$g.DrawString("github.com/dranben/foot-pedal-audio-switch", (Font 'Segoe UI Semibold' 20 'Bold'), $blue, (New-Object System.Drawing.RectangleF 0, 566, $W, 32), $ctr)

$out = Join-Path $PSScriptRoot 'social-preview.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output ("Saved: $out  ({0:N0} bytes)" -f (Get-Item $out).Length)
