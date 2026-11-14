param([Parameter(Mandatory=$true)][string]$Output, [switch]$PanelsOnly)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$out=[IO.Path]::GetFullPath($Output)
if(Test-Path -LiteralPath $out){throw 'Use a fresh output directory'}
New-Item -ItemType Directory -Path $out | Out-Null
$story=Get-Content "$PSScriptRoot/storyboard.json" -Raw|ConvertFrom-Json
$mapping=Get-Content "$PSScriptRoot/frame-map.json" -Raw|ConvertFrom-Json
$ink='#EAF1FD';$muted='#A8B9D1';$teal='#5CE3CB';$blue='#79B8FF';$pink='#FF90BC';$gold='#FFD17C';$purple='#BEABFF';$wood='#E1A572';$edge='#567092'
$script:checks=[Collections.Generic.List[object]]::new()
function Brush($c){[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($c))}
function Rect($x,$y,$w,$h,$c){$b=Brush $c;$script:g.FillRectangle($b,$x,$y,$w,$h);$b.Dispose()}
function Text([string]$s,$x,$y,$size=24,$c=$ink,$bold=$false,$maxWidth=1450){
 $style=if($bold){[Drawing.FontStyle]::Bold}else{[Drawing.FontStyle]::Regular}
 $f=[Drawing.Font]::new('Segoe UI',[single]$size,$style,[Drawing.GraphicsUnit]::Pixel)
 $m=$script:g.MeasureString($s,$f)
 if($m.Width -gt $maxWidth+3 -or $x+$m.Width -gt 1580 -or $y+$m.Height -gt 897){throw "Text overflow: $s ($($m.Width) vs $maxWidth)"}
 $b=Brush $c;$script:g.DrawString($s,$f,$b,[single]$x,[single]$y);$b.Dispose();$f.Dispose()
 $script:checks.Add(@{text=$s;x=$x;y=$y;width=$m.Width;height=$m.Height;size=$size})
}
function Line($x,$y,$x2,$y2,$c,$width=2,$dash=$false,$arrow=$false){
 $p=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($c),[single]$width)
 if($dash){$p.DashStyle='Dash'}
 if($arrow){$p.CustomEndCap=[Drawing.Drawing2D.AdjustableArrowCap]::new(4,5)}
 $script:g.DrawLine($p,$x,$y,$x2,$y2);$p.Dispose()
}
function Dot($x,$y,$r,$c,$ring=$false){
 if($ring){$p=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($c),3);$script:g.DrawEllipse($p,($x-$r),($y-$r),(2*$r),(2*$r));$p.Dispose()}
 else{$b=Brush $c;$script:g.FillEllipse($b,($x-$r),($y-$r),(2*$r),(2*$r));$b.Dispose()}
}
function Marker($x,$y,[string]$kind){
 if($kind.Contains('C')){Dot $x $y 15 $blue $true}
 if($kind.Contains('G')){Dot $x $y 10 $pink $true}
 if($kind.Contains('M')){Dot $x $y 5 $teal}
}
function PanelBox($y,$label,$detail,$c=$teal){
 Rect 801 $y 706 95 '#203348';Text $label 822 ($y+9) 29 $c $true 660
 Text $detail 822 ($y+51) 23 $ink $false 660
}
function BreakAxis {
 Line 803 414 1085 414 $edge 2
 Line 1085 414 1101 403 $edge 2;Line 1101 403 1117 425 $edge 2;Line 1117 425 1133 414 $edge 2
 Line 1133 414 1506 414 $edge 2
 Text 'Broken vertical scale / not to scale' 838 430 20 $muted $false 650
}
function LowFloor($caption='Cached floor 768') {
 Line 808 574 1505 574 $gold 4
 Text $caption 811 585 22 $gold $true 330
 Dot 908 574 13 $purple $true
 if($caption -eq 'Cached floor 768'){Text 'Real warp' 965 537 20 $purple $false 240}
}
function HighBox {
 Rect 1121 270 326 108 '#6B4935'
 Line 1121 270 1447 270 $wood 4
 Line 1121 270 1121 378 $wood 3
 Text 'Live large box' 1150 287 27 $wood $true 295
 Text 'Top Y 25000' 1150 332 25 $ink $true 295
 Text 'West edge X -1949' 1130 385 21 $wood $false 350
}
function Diagram([string]$d){
 Text 'EXPLANATORY DIAGRAM / STORED COORDINATES' 779 158 21 $muted $false 740
 switch($d){
 'roles'{
  PanelBox 207 '1  Live large breakable box' 'Its loaded floor supplies the landing result.' $wood
  PanelBox 329 '2  Mario enters DIVE_SLIDE' 'The game creates the ground action from air.' $teal
  PanelBox 451 '3  A nonmounting shell shoves' 'The slide then makes the useful Ink split.' $pink
  Text 'High placements remain supplied.' 821 583 25 $gold $true 670
 }
 'setup'{
  HighBox;Marker 1049 257 'MCG';Text 'M = C = G' 805 209 27 $ink $true 290
  Text 'Y 25001' 805 251 28 $pink $true 250
  Line 1070 257 1110 257 $teal 3 $false $true
  Text 'Box origin Y 24800' 1095 485 25 $wood $true 425
  BreakAxis;Text 'Inherited cache 1024; next lookup finds 768' 811 524 23 $gold $false 690;LowFloor 'Static floor 768'
 }
 'edge'{
  Rect 1156 310 336 235 '#6B4935';Line 1156 310 1492 310 $wood 4
  Marker 1062 296 'MCG';Dot 1214 308 7 $gold $true
  Line 1080 296 1200 308 $gold 3 $true $true
  Text 'X -1950' 833 247 31 $teal $true 270
  Text 'X -1949' 1177 556 28 $wood $true 300
  Text '1 unit to edge' 805 356 28 $ink $true 310
  Text 'Candidate crosses' 1178 218 26 $gold $true 350
  Text 'into the high floor' 1178 256 24 $gold $false 350
  Text 'The horizontal distance is greatly enlarged.' 813 603 21 $muted $false 700
 }
 'action'{
  PanelBox 209 'FREEFALL' 'Supplied airborne state; A is off.' $muted
  Line 1143 311 1143 337 $teal 3 $false $true
  PanelBox 345 'B  →  DIVE' 'The next air step reports LANDED.' $teal
  Line 1143 448 1143 475 $teal 3 $false $true
  PanelBox 483 'DIVE_SLIDE' 'A native ground action, not a setup write.' $pink
 }
 'cache'{
  PanelBox 210 'Initial floor query: 768' 'The current X/Z is outside the large box.' $gold
  PanelBox 330 'Air candidate reaches floor 25000' 'LANDED assigns the high movement Y.' $teal
  PanelBox 450 'Clearance: 20000 - 25000 ≤ 160' 'X/Z and the cached floor are not replaced.' $pink
  Text '20000 is the default no-ceiling value.' 822 581 25 $muted $false 680
 }
 'landed'{
  HighBox;Marker 1082 270 'MCG';Text 'M = C = G' 800 208 28 $ink $true 300
  Text 'Y 25000' 800 252 30 $pink $true 290
  Text 'X stays -1950' 795 340 27 $teal $true 310
  BreakAxis;LowFloor
 }
 'shell'{
  HighBox;Marker 1082 270 'MCG';Dot 956 270 24 $teal
  Line 984 270 1055 270 $teal 3 $false $true
  Text 'Shell cut' 804 210 28 $teal $true 270
  Text 'X -1971' 804 314 28 $teal $true 280
  Text 'Y 25000' 804 354 25 $ink $false 280
  BreakAxis;LowFloor
 }
 'push'{
  Marker 999 269 'CG';Marker 1267 269 'M';Line 1024 269 1235 269 $teal 4 $false $true
  Text '+68 X' 1088 210 37 $teal $true 250
  Text 'M: X -1882 / Y 25000' 1047 328 30 $teal $true 470
  Text 'Before alignment, movement is still high.' 808 486 25 $ink $false 680
  LowFloor
 }
 'copy'{
  Marker 1110 249 'MG';Text '1  Save high M into G' 1150 230 28 $pink $true 390
  Line 1110 279 1110 543 $teal 3 $true $true
  Marker 1110 575 'MC';Text '2  Snap M to 768' 1150 549 28 $teal $true 390
  Text 'G keeps Y 25000' 807 319 29 $pink $true 620
  Text 'Instant assignments, not a long fall' 805 414 25 $muted $false 700
  Line 804 575 1084 575 $gold 4
 }
 'gap'{
  Marker 1069 248 'G';Text 'G  Stored Graphics' 1110 220 29 $pink $true 425
  Text 'Y 25000' 1110 266 31 $pink $true 390
  Marker 1069 575 'MC';Text 'M + C  Y 768' 1110 554 31 $teal $true 410
  Line 1087 282 1087 548 $ink 2 $true
  Text '24232-unit gap' 1115 411 33 $ink $true 400
  Text 'X -1882 / Z -939' 807 337 24 $muted $false 650
  Line 805 575 1040 575 $gold 4
 }
 'retry'{
  Marker 1110 239 'G';Text 'Retry from G.Y 25000' 1150 220 26 $pink $true 380
  Marker 1110 577 'MC';Line 1110 546 1110 269 $pink 3 $true $true
  Line 806 577 1080 577 $gold 4;Dot 894 577 13 $purple $true
  Line 915 577 1080 577 $purple 3 $true $true
  Text 'Low collision contacts warp' 800 491 25 $purple $true 700
  Text 'Top collision is now loaded' 811 361 28 $gold $true 680
  Text 'The live high box mesh has unloaded.' 811 407 23 $muted $false 680
 }
 'capture'{
  PanelBox 211 'Warp 64 accepted' 'Mario enters DISAPPEARED.' $purple
  PanelBox 333 'Floor owner = platform = top 61' 'The useful reference is installed.' $teal
  PanelBox 455 'M = C = G / Y 1818.9613' 'The high graphics / low collision gap closes.' $pink
 }
 'retention'{
  PanelBox 211 'Area 1 countdown' 'Observed samples retain the top reference.' $teal
  PanelBox 333 'Last observed boundary: step 27' 'Top inactive; stored platform still top 61.' $pink
  PanelBox 455 'Next observed area: Area 2' 'The useful spawning displacement follows.' $gold
 }
 'gaps'{
  PanelBox 210 'Step 27: native telemetry exists' 'Inactive top; retained platform reference.' $teal
  PanelBox 332 'Steps 28–29: no camera states' 'No invented intermediate observations.' $gold
  PanelBox 454 'Step 30: first Area 2 state' 'The separate Wafel trace fills its own record.' $pink
 }
 'arrival'{
  Text 'X/Z plan view / Y 5500' 801 209 27 $muted $true 700
  Rect 904 433 360 133 '#373043';Text 'Ordinary entry' 925 519 25 $purple $true 320
  Dot 1088 484 10 $purple;Text '(0, 256)' 1110 463 24 $muted $false 300
  Marker 1245 286 'MCG';Line 1098 466 1228 310 $teal 3 $true $true
  Text 'Useful entry' 1280 252 26 $teal $true 250
  Text 'X 365.593' 1280 290 23 $ink $false 250
  Text 'Z -1096.803' 1280 326 23 $ink $false 250
  Text 'Comparison arrow; not a travelled path' 810 601 24 $muted $false 710
 }
 'clone'{
  PanelBox 209 'LIVE BOX' 'Behavior reloads its solid collision mesh.' $wood
  PanelBox 331 'FROZEN CONTROL' 'No high mesh was loaded; landing failed.' $gold
  PanelBox 453 'DELIVERY QUESTION REMAINS' 'Can gameplay arrange a live high solid?' $pink
 }
 'summary'{
  PanelBox 209 'Established in this conditional replay' 'Native slide → top capture → useful spawn.' $teal
  PanelBox 331 'Still supplied' 'High Mario, live box and timed shell placement.' $gold
  PanelBox 453 'Limits preserved' 'Subtype differences and two camera gaps.' $pink
  Text 'No continuous no-new-A route established.' 810 584 25 $muted $true 710
 }
 default{throw "Unknown diagram: $d"}
 }
}
$queue=[Collections.Generic.List[string]]::new();$panels=[Collections.Generic.List[object]]::new();$chapters=[Collections.Generic.List[object]]::new();$frame=0;$number=0
foreach($s in $story.segments){
 $start=$frame;$indices=if($s.range){$s.range[0]..$s.range[1]}else{@([int]$s.shot)}
 foreach($index in $indices){
  $m=$mapping.frameMap[$index];if($null -eq $m.completedInput){throw 'Cannot use an unjoined native image'}
  $path=Join-Path "$PSScriptRoot/frames" $m.file
  if((Get-FileHash $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $m.sha256){throw 'Native image hash mismatch'}
  $bitmap=[Drawing.Bitmap]::new(1600,900);$script:g=[Drawing.Graphics]::FromImage($bitmap)
  $script:g.SmoothingMode='AntiAlias';$script:g.InterpolationMode='NearestNeighbor';$script:g.PixelOffsetMode='Half';$script:g.TextRenderingHint='AntiAliasGridFit'
  $script:g.Clear([Drawing.ColorTranslator]::FromHtml('#0B1321'))
  Rect 38 32 6 89 $teal;Text $s.tag 62 29 22 $teal $true 1450;Text $s.title 60 65 44 $ink $true 1460
  Rect 44 145 690 496 '#101D2D';Rect 752 145 804 496 '#132137'
  $sourceLabel=if($s.sourceLabel){$s.sourceLabel}else{"Original JP / native step $($m.completedInput)"}
  Text $sourceLabel 62 158 22 $muted $false 650
  $img=[Drawing.Image]::FromFile($path);$h=[int](560*$img.Height/$img.Width);$script:g.DrawImage($img,109,199,560,$h);$img.Dispose()
  Rect 67 597 641 31 '#101D2D';Text $s.badge 77 600 18 $gold $true 618
  Diagram $s.diagram
  Rect 44 652 1512 48 '#19273C'
  Marker 74 676 'M';Text 'M  Movement' 89 662 22 $teal $false 210
  Dot 322 676 10 $blue $true;Text 'C  Collision' 342 662 22 $blue $false 225
  Dot 581 676 10 $pink $true;Text 'G  Stored Graphics' 603 662 22 $pink $false 345
  Line 1003 676 1030 676 $gold 4;Text 'Cached floor' 1044 662 22 $gold $false 235
  Dot 1338 676 10 $purple $true;Text 'Warp' 1360 662 22 $purple $false 160
  Text $s.lines[0] 61 720 29 $ink $false 1475;Text $s.lines[1] 61 764 29 $ink $false 1475
  Line 62 829 1537 829 $edge 1;Text $s.footer 61 846 18 $muted $false 1475
  $name='panel-{0:0000}.png' -f $number;$bitmap.Save((Join-Path $out $name),[Drawing.Imaging.ImageFormat]::Png);$script:g.Dispose();$bitmap.Dispose()
  $count=if($s.range){[int]$s.repeat}else{[int]($s.seconds*30)}
  $queue.Add("file '$name'");$queue.Add('duration '+([double]$count/30).ToString('0.#########',[Globalization.CultureInfo]::InvariantCulture))
  $panels.Add(@{file=$name;source=$m.file;sourceSha256=$m.sha256;nativeStep=$m.completedInput;framebufferTimer=$m.framebufferTimer;segment=$chapters.Count;firstFrame=$frame;frames=$count})
  $frame+=$count;$number++
 }
 $chapters.Add(@{title=$s.title;tag=$s.tag;diagram=$s.diagram;lines=$s.lines;footer=$s.footer;firstFrame=$start;lastFrame=$frame-1;startSeconds=$start/30;endSeconds=$frame/30})
}
$queue.Add($queue[$queue.Count-2]);[IO.File]::WriteAllLines((Join-Path $out 'frames.txt'),$queue,[Text.Encoding]::ASCII)
$poster=$panels|Where-Object {$_.segment -eq $story.posterSegment}|Select-Object -First 1
Copy-Item (Join-Path $out $poster.file) (Join-Path $out 'live-box-handoff-poster.png')
$sheet=[Drawing.Bitmap]::new(1440,1620);$sg=[Drawing.Graphics]::FromImage($sheet)
for($i=0;$i -lt $chapters.Count;$i++){$p=$panels|Where-Object {$_.segment -eq $i}|Select-Object -First 1;$im=[Drawing.Image]::FromFile((Join-Path $out $p.file));$sg.DrawImage($im,($i%3)*480,[int][math]::Floor($i/3)*270,480,270);$im.Dispose()}
$sheet.Save((Join-Path $out 'contact-sheet.png'),[Drawing.Imaging.ImageFormat]::Png);$sg.Dispose();$sheet.Dispose()
$transcript=[Collections.Generic.List[string]]::new();$transcript.Add('# Live large box: native slide into useful Ink');$transcript.Add('');$transcript.Add($story.scope);$transcript.Add('')
$vtt=[Collections.Generic.List[string]]::new();$vtt.Add('WEBVTT');$vtt.Add('')
foreach($c in $chapters){$a=[TimeSpan]::FromSeconds($c.startSeconds);$b=[TimeSpan]::FromSeconds($c.endSeconds);$transcript.Add("## $($a.ToString('mm\:ss\.fff'))–$($b.ToString('mm\:ss\.fff')): $($c.title)");$transcript.Add('');$transcript.Add($c.tag);$transcript.Add('');foreach($l in $c.lines){$transcript.Add($l)};$transcript.Add('');$transcript.Add($c.footer);$transcript.Add('');$vtt.Add("$($a.ToString('hh\:mm\:ss\.fff')) --> $($b.ToString('hh\:mm\:ss\.fff'))");$vtt.Add(($c.lines -join "`n"));$vtt.Add('')}
[IO.File]::WriteAllLines((Join-Path $out 'live-box-handoff-transcript.md'),$transcript,[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllLines((Join-Path $out 'live-box-handoff-commentary.vtt'),$vtt,[Text.UTF8Encoding]::new($false))
$video=Join-Path $out 'live-box-handoff-silent.mp4'
if(!$PanelsOnly){
 $ff=(Get-ChildItem 'C:/Users/tariq/AppData/Local/Overwolf/Extensions' -Filter ffmpeg.exe -Recurse|Select-Object -First 1).FullName
 & $ff -hide_banner -loglevel error -f concat -safe 0 -i (Join-Path $out 'frames.txt') -vf fps=30 -frames:v $frame -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -movflags +faststart $video
 if($LASTEXITCODE -ne 0){throw 'Video encode failed'}
 & $ff -hide_banner -loglevel error -i $video -f null -
 if($LASTEXITCODE -ne 0){throw 'Full decode failed'}
}
$receipt=@{scope=$story.scope;frames=$frame;durationSeconds=$frame/30;chapters=$chapters;panels=$panels;textFitChecks=$script:checks.Count;rendererSha256=(Get-FileHash $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant();storyboardSha256=(Get-FileHash "$PSScriptRoot/storyboard.json" -Algorithm SHA256).Hash.ToLowerInvariant();frameMapSha256=(Get-FileHash "$PSScriptRoot/frame-map.json" -Algorithm SHA256).Hash.ToLowerInvariant();coordinateLabels=@{M='Movement';C='Collision';G='Stored Graphics (gfx.pos), not rendered pose'}}
if(!$PanelsOnly){$receipt.silentVideoSha256=(Get-FileHash $video -Algorithm SHA256).Hash.ToLowerInvariant()}
[IO.File]::WriteAllText((Join-Path $out 'render-receipt.json'),($receipt|ConvertTo-Json -Depth 14),[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $out 'text-fit-checks.json'),($script:checks|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
Write-Output "Rendered $number panels, $frame frames, $($frame/30) seconds, $($script:checks.Count) text-fit checks"
