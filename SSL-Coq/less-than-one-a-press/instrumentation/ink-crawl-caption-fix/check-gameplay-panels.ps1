param([Parameter(Mandatory=$true)][string]$OriginalPanels, [Parameter(Mandatory=$true)][string]$CorrectedPanels)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
function PixelHash([string]$Path) {
    $image=[Drawing.Bitmap]::FromFile($Path)
    $crop=$image.Clone([Drawing.Rectangle]::new(109,199,560,420),[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $data=$crop.LockBits([Drawing.Rectangle]::new(0,0,560,420),[Drawing.Imaging.ImageLockMode]::ReadOnly,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes=[byte[]]::new([Math]::Abs($data.Stride)*$data.Height)
    [Runtime.InteropServices.Marshal]::Copy($data.Scan0,$bytes,0,$bytes.Length)
    $crop.UnlockBits($data)
    $hash=[Security.Cryptography.SHA256]::Create()
    $result=[BitConverter]::ToString($hash.ComputeHash($bytes)).Replace('-','').ToLowerInvariant()
    $hash.Dispose(); $crop.Dispose(); $image.Dispose()
    return $result
}
$results=foreach($panel in (Get-ChildItem -LiteralPath $CorrectedPanels -Filter 'panel-*.png' | Sort-Object Name)) {
    $before=PixelHash (Join-Path $OriginalPanels $panel.Name)
    $after=PixelHash $panel.FullName
    if ($before -ne $after) { throw "Gameplay crop changed: $($panel.Name)" }
    [ordered]@{panel=$panel.Name;crop=@(109,199,560,420);pixelFormat='Format32bppArgb';sha256=$after;identical=$true}
}
$results | ConvertTo-Json -Depth 4
