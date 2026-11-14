param([string]$OutputDir = '', [switch]$PanelsOnly)
# Caption-corrected presentation; original gameplay captures and card timing retained.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$proof=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$workspace=(Resolve-Path (Join-Path $proof '../../..')).Path
if (-not $OutputDir) { $OutputDir=Join-Path $workspace 'build/ink-crawl-caption-fix' }
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$out=(Resolve-Path $OutputDir).Path
$labelChecks=[Collections.Generic.Dictionary[string,object]]::new()
$selection=[Collections.Generic.List[object]]::new()
$shots=(Resolve-Path "$proof/build/jp-ink-handoff-demo-20261112-a/shots").Path
$ff=(Get-ChildItem 'C:/Users/tariq/AppData/Local/Overwolf/Extensions' -Filter ffmpeg.exe -Recurse | Select-Object -First 1).FullName
$ink='#EAF1FD'; $muted='#A8B9D1'; $teal='#5CE3CB'; $blue='#79B8FF'; $pink='#FF90BC'; $gold='#FFD17C'; $warp='#BEABFF'; $wood='#E1A572'; $edge='#567092'
function Brush($c) { [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($c)) }
function Write-Label($s,$x,$y,$size=26,$c=$ink,$bold=$false) {
    $f=[Drawing.Font]::new('Segoe UI',[single]$size, $(if($bold){[Drawing.FontStyle]::Bold}else{[Drawing.FontStyle]::Regular}),[Drawing.GraphicsUnit]::Pixel)
    $measure=$g.MeasureString($s,$f)
    $key="$s|$x|$y|$size|$bold"
    $labelChecks[$key]=[ordered]@{text=$s;x=$x;y=$y;size=$size;bold=$bold;measuredWidth=$measure.Width;measuredHeight=$measure.Height;right=$x+$measure.Width;bottom=$y+$measure.Height;canvasFits=($x+$measure.Width -le 1600 -and $y+$measure.Height -le 900)}
    $b=Brush $c; $g.DrawString($s,$f,$b,[single]$x,[single]$y); $b.Dispose(); $f.Dispose()
}
function Rect($x,$y,$w,$h,$c) { $b=Brush $c; $g.FillRectangle($b,$x,$y,$w,$h); $b.Dispose() }
function Line($x,$y,$x2,$y2,$c,$w=2,$dash=$false,$arrow=$false) {
    $p=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($c),[single]$w)
    if($dash){$p.DashStyle='Dash'}
    if($arrow){$p.CustomEndCap=[Drawing.Drawing2D.AdjustableArrowCap]::new(4,5)}
    $g.DrawLine($p,$x,$y,$x2,$y2); $p.Dispose()
}
function Dot($x,$y,$r,$c,$ring=$false){
    if($ring){$p=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($c),3);$g.DrawEllipse($p,($x-$r),($y-$r),(2*$r),(2*$r));$p.Dispose()}
    else{$b=Brush $c;$g.FillEllipse($b,($x-$r),($y-$r),(2*$r),(2*$r));$b.Dispose()}
}
function Marker($x,$y,$mode){
    if($mode.Contains('C')){Dot $x $y 15 $blue $true}
    if($mode.Contains('D')){Dot $x $y 10 $pink $true}
    if($mode.Contains('M')){Dot $x $y 5 $teal}
}
function Poly($coords,$c,$fill){
    $points=foreach($i in 0..(($coords.Length/2)-1)){[Drawing.Point]::new($coords[2*$i],$coords[2*$i+1])}
    $b=Brush $fill; $g.FillPolygon($b,[Drawing.Point[]]$points); $b.Dispose()
    $p=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($c),2); $g.DrawPolygon($p,[Drawing.Point[]]$points);$p.Dispose()
}
function Draw-Cutaway($stage){
    Write-Label 'Stored-position cutaway  /  X increases →' 778 158 23 $muted
    if($stage -ge 6){
        Poly @(811,379,942,209,1380,379) '#6C85A7' '#1B2E46'
    }else{
        Poly @(829,379,1069,209,1504,379) '#6C85A7' '#1B2E46'
    }
    Line 829 379 1504 379 $edge 2
    Write-Label 'Spinning top' 1240 222 23 $ink $true
    Write-Label 'outlined so you can see inside' 1240 251 19 $muted
    Rect 1030 433 500 23 '#574F3B'
    Write-Label 'Higher roof  Y 1280' 1313 437 19 $gold
    Rect 804 568 226 19 '#54482E'
    Line 804 568 1030 568 $gold 4
    Line 1030 479 1030 588 $gold 2 $true
    Write-Label 'Low pad  Y 768' 784 594 21 $gold $true
    Write-Label 'Pad edge' 977 594 21 $gold
    Dot 871 568 12 $warp $true
    Line 871 548 871 519 $warp
    Write-Label 'Warp (invisible in game)' 783 487 19 $warp
    Write-Label 'projected from farther back' 783 513 16 $muted
    if($stage -le 4){
        Rect 926 316 22 22 $wood
        Write-Label 'Crazy Box' 791 305 21 $wood $true
        Line 890 323 919 327 $wood
    }
    switch($stage){
        0 { Marker 1018 327 'MCD'; Write-Label 'Mario  M/C/D overlap' 1050 308 21 $ink; Write-Label 'Y 1741' 1050 338 22 $pink }
        1 { Marker 1018 327 'MCD'; Line 1018 348 1018 562 $gold 2 $true $true; Write-Label 'Floor lookup → remember 768' 1060 486 22 $gold }
        2 { Marker 1018 327 'CD'; Marker 1174 327 'M'; Line 1040 327 1157 327 $teal 3 $false $true; Write-Label '+68 X' 1066 293 22 $teal; Write-Label 'M stays at Y 1741' 1196 314 22 $teal; Write-Label 'Remembered floor still 768' 1070 541 21 $gold }
        3 { Marker 1018 327 'CD'; Marker 1174 327 'M'; Line 1174 347 1174 376 $gold 3 $true $true; Write-Label 'Underside  Y 1523' 1193 385 21 $gold; Write-Label 'Remembered floor still 768' 1070 541 21 $gold }
        4 { Marker 1018 327 'C'; Marker 1174 327 'M'; Marker 1174 327 'D'; Line 1174 348 1174 556 $teal 3 $true $true; Write-Label 'M + stored D match first' 1197 310 21 $pink; Write-Label 'Then M snaps to 768' 1197 492 21 $teal }
        5 { Marker 1174 327 'D'; Marker 1174 568 'MC'; Line 1199 328 1199 566 $ink 2 $true; Write-Label 'Stored D  Y 1741' 1220 307 23 $pink $true; Write-Label '973 units' 1220 476 26 $ink $true; Write-Label 'M + C  Y 768' 1220 551 23 $teal $true }
        6 { Marker 1174 327 'D'; Marker 1174 568 'MC'; Line 892 568 1150 568 $warp 3 $true; Write-Label 'Low overlap logged by collision pass' 1040 613 20 $warp; Line 1174 550 1174 350 $pink 3 $true $true; Write-Label 'Low floor lookup misses' 1202 510 20 $teal; Write-Label 'Retry at stored D  Y 1741' 1202 311 22 $pink $true }
        7 { Dot 1174 327 10 $pink $true; Marker 1174 299 'MCD'; Line 1132 300 1157 300 $teal 3 $false $true; Write-Label 'Top surface selected' 1200 301 22 $teal $true; Write-Label 'Y 1818.96  /  M, C and D' 1200 332 20 $ink; Write-Label 'Top saved as Mario''s platform' 1056 515 23 $gold }
    }
}
function Draw-Arrival {
    Write-Label 'Area 2  /  plan view of X and Z' 778 158 23 $muted
    Write-Label '−Z ↑' 794 226 22 $muted
    Rect 928 416 368 153 '#373043'
    Line 928 416 1296 416 $warp 2
    Line 928 569 1296 569 $warp 2
    Line 928 416 928 569 $warp 2
    Line 1296 416 1296 569 $warp 2
    Write-Label 'Elevator footprint' 947 526 23 $warp
    Dot 1112 492 7 $warp; Write-Label 'Usual entry' 1127 477 21 $muted
    Line 1124 480 1250 281 $teal 3 $true $true
    Marker 1258 268 'MCD'
    Write-Label 'Recorded entry' 1282 239 23 $teal $true
    Write-Label 'Y 5500' 1282 271 22 $ink
    Write-Label 'The arrow compares entry points.' 809 614 21 $muted
}
$queue=[Collections.Generic.List[string]]::new()
$stillNames=@{0='overview';5='ink-gap';7='top-capture';8='area2-arrival'}
function Card($index,$duration,$stage,$tag,$title,$lines,$credit){
    $bitmap=[Drawing.Bitmap]::new(1600,900)
    $g=[Drawing.Graphics]::FromImage($bitmap)
    $g.SmoothingMode='AntiAlias';$g.InterpolationMode='HighQualityBicubic';$g.TextRenderingHint='AntiAliasGridFit'
    $g.Clear([Drawing.ColorTranslator]::FromHtml('#0B1321'))
    Rect 38 32 6 89 $teal
    Write-Label $tag 62 29 22 $teal $true
    Write-Label $title 60 60 52 $ink $true
    Rect 44 145 690 496 '#101D2D'; Rect 752 145 804 496 '#132137'
    $inputNumber=if($index -ge 28){$index+2}else{$index}
    $gameLabel=if($index -eq 27){'Original JP gameplay  /  area-change wipe'}else{"Original JP gameplay  /  input $inputNumber complete"}
    Write-Label $gameLabel 62 158 23 $muted
    $img=[Drawing.Image]::FromFile((Join-Path $shots ('super_mario_64-{0:000}.png' -f $index)))
    $scaledHeight=[int](560*$img.Height/$img.Width)
    $g.DrawImage($img,109,199,560,$scaledHeight); $img.Dispose()
    if($stage -eq 0){
        Line 242 284 242 333 $gold 2
        Rect 155 333 169 32 '#101D2D'
        Write-Label 'Spinning top' 161 336 22 $gold $true
    }
    if($stage -le 7){Draw-Cutaway $stage}else{Draw-Arrival}
    Rect 44 652 1512 48 '#19273C'
    Marker 74 676 'M'; Write-Label 'M  Movement' 87 662 22 $teal
    Dot 301 676 9 $blue $true; Write-Label 'C  Collision / object contact' 319 662 22 $blue
    Dot 628 676 9 $pink $true; Write-Label 'D  Stored graphics' 648 662 22 $pink
    Line 954 676 977 676 $gold 4; Write-Label 'Remembered floor' 985 662 22 $gold
    Dot 1268 676 9 $warp $true; Write-Label 'Warp' 1285 662 22 $warp
    Rect 1396 668 16 16 $wood; Write-Label 'Box' 1421 662 22 $wood
    Write-Label $lines[0] 61 721 33 $ink
    Write-Label $lines[1] 61 766 33 $ink
    Line 62 829 1537 829 $edge 1
    Write-Label $credit 61 846 20 $muted
    $fn='panel-{0:000}.png' -f ($queue.Count/2)
    $bitmap.Save((Join-Path $out $fn),[Drawing.Imaging.ImageFormat]::Png)
    if($stillNames.ContainsKey($stage) -and ($stage -ne 8 -or $index -eq 28) -and ($stage -ne 7 -or $index -eq 7)){
        $bitmap.Save((Join-Path $out ($stillNames[$stage]+'.png')),[Drawing.Imaging.ImageFormat]::Png)
    }
    $selection.Add([ordered]@{panel=$fn;source=('super_mario_64-{0:000}.png' -f $index);duration=$duration;stage=$stage;input=$inputNumber})
    $queue.Add("file '$fn'");$queue.Add("duration $duration")
    $g.Dispose();$bitmap.Dispose()
}
Card 5 11 0 'CRAZY BOX HANDOFF  /  AREA 1' 'Above the warp at the pyramid summit' @(
    'At left, Mario is still at his earlier location. The cutaway shows the supplied setup',
    'just before input 6, inside the top''s outline and directly above the low pad.'
) 'Separate original-JP replay chapter. Debug level select was used before entry. Cutaway at right is explanatory.'
Card 5 11 0 'SETUP  /  AFTER INPUT 5, BEFORE INPUT 6' 'What the replay supplies' @(
    'Before input 5, the script sets crawl. The game gives Mario his short hitbox.',
    'Before input 6, the script places all three Mario positions and box 49 up high.'
) 'Setup trace: 1 action word and 12 position words. The floor starts with its inherited value, Y 1024.'
Card 6 10 1 'INPUT 6  /  SAME UPDATE · 1 OF 4' 'The game remembers the low pad' @(
    'Mario''s movement starts at Y 1741. The game looks for a floor at his location.',
    'The low pad wins the lookup. The game stores the pad and its height, Y 768.'
) 'Left shows the completed update. Right shows the order within it, reconstructed from trace and source.'
Card 6 10 2 'INPUT 6  /  SAME UPDATE · 2 OF 4' 'The Crazy Box bumps Mario past the edge' @(
    'The box is west of Mario. Its shove moves him east from X −1950 to −1882.',
    'His height stays at 1741. The pad ends at X −1945, just east of his start.'
) 'Side view magnifies X relative to Y. The warp is projected from a different Z. Source: object push and pad mesh.'
Card 6 11 3 'INPUT 6  /  SAME UPDATE · 3 OF 4' 'The crawl step stops' @(
    'At the new spot, the crawl checks the higher roof and the top''s underside.',
    'The ceiling check stops the step before it can replace the remembered low floor.'
) 'Within-update reconstruction from the source-derived geometry and crawl-step code. These temporary queries are off-camera.'
Card 6 10 4 'INPUT 6  /  SAME UPDATE · 4 OF 4' 'Store high graphics, then snap movement down' @(
    'First, the game stores the high movement position as graphics coordinates.',
    'Then it snaps movement to the remembered pad height. Collision copies movement.'
) 'D marks stored graphics coordinates, not necessarily the drawn model. Left: the same completed frame.'
Card 6 10 5 'INPUT 6 COMPLETE  /  TRACE MARKERS' 'The Ink gap is 973 units' @(
    'Movement and collision now share the same point at Y 768, beyond the pad edge.',
    'Stored graphics stay at Y 1741. This need not be where the model is drawn.'
) 'Native trace: all three share X −1882 and Z −939. Remembered floor Y 768.'
Card 7 11 6 'INPUT 7  /  NEXT UPDATE · 1 OF 2' 'Low contact, high floor retry' @(
    'The object collision pass sees Mario overlap the warp at his low position.',
    'The low floor search misses past the pad edge. It retries at stored graphics Y.'
) 'Same update as the next card. Low contact is collected before floor search and handled afterward.'
Card 7 11 7 'INPUT 7 COMPLETE  /  NEXT UPDATE · 2 OF 2' 'Mario takes the warp and keeps the top as a platform' @(
    'The spinning top''s surface now qualifies at the retry point. Mario takes the',
    'warp and disappears. The game saves the selected floor''s owner as his platform.'
) 'Trace: floor owner equals platform, Y 1818.9613. The diagram shows the selected surface schematically.'
foreach($i in 8..27){
    Card $i 0.2 7 'ORIGINAL REPLAY  /  WARP TRANSITION' 'The warp counts down' @(
        'The replay advances through consecutive captured frames. The platform reference',
        'persists into the transition. The game image fades out as the area changes.'
    ) 'Left: consecutive original captures. Right: recap of the input 7 platform capture.'
}
Card 28 10 8 'INPUT 30 COMPLETE  /  FIRST AREA 2 STATE' 'The old platform reference displaces the arrival' @(
    'The JP warp carries the old platform reference across the area change.',
    'The resulting arrival is outside the elevator footprint, during the star wipe.'
) 'Recorded X/Z: (365.593, −1096.803). Dashed arrow compares with the ordinary entry (0, 256).'
foreach($i in 29..63){
    Card $i 0.133333 8 'ORIGINAL REPLAY  /  AREA 2' 'Watch the arrival resolve' @(
        'The camera catches up after the wipe. Mario appears on the upper walkway.',
        'The diagram keeps the first Area 2 position marked for reference.'
    ) 'Left: consecutive original captures. Right: plan view of the recorded first Area 2 state.'
}
Card 63 11 8 'AREA 2  /  WHAT ACTUAL PLAY STILL NEEDS' 'The handoff works from the supplied setup' @(
    'Actual play still needs to bring a high crawler and a live box together above',
    'the pad at the right moment in the spin. This replay demonstrates the handoff.'
) 'The three chapters of the source video are independent. Ordinary-play access to this setup remains open.'
$queue.Add($queue[$queue.Count-2])
$queue | Set-Content (Join-Path $out 'frames.txt') -Encoding ascii
$labelChecks.Values | Sort-Object text,x,y | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $out 'label-measurements.json') -Encoding utf8
$selection | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $out 'selection.json') -Encoding utf8
if (@($labelChecks.Values | Where-Object {-not $_.canvasFits}).Count -gt 0) { throw 'A label exceeds the 1600x900 canvas.' }
if ($PanelsOnly) { return }
& $ff -hide_banner -loglevel error -y -f concat -safe 0 -i (Join-Path $out 'frames.txt') -vf 'fps=30' -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -movflags +faststart (Join-Path $out 'crawl-caption-corrected.mp4')
if($LASTEXITCODE -ne 0){throw 'Video encoding failed.'}




