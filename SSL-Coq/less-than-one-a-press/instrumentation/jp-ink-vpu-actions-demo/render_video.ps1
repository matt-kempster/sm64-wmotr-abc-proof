param(
    [Parameter(Mandatory=$true)][string]$Manifest,
    [Parameter(Mandatory=$true)][string]$Output,
    [string]$Ffmpeg,
    [switch]$PanelsOnly
)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$manifestPath=(Resolve-Path -LiteralPath $Manifest).Path
$story=Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$out=[IO.Path]::GetFullPath($Output)
if(Test-Path -LiteralPath $out){throw "Output already exists: $out"}
New-Item -ItemType Directory -Path $out | Out-Null
if(!$Ffmpeg){$Ffmpeg=(Get-ChildItem 'C:/Users/tariq/AppData/Local/Overwolf/Extensions' -Filter ffmpeg.exe -Recurse | Select-Object -First 1).FullName}
if(!$Ffmpeg){throw 'Pass -Ffmpeg with an installed ffmpeg executable.'}
$W=1600;$H=900;$fps=30
$ink='#EAF1FD';$muted='#A8B9D1';$teal='#5CE3CB';$blue='#79B8FF';$pink='#FF90BC';$gold='#FFD17C';$purple='#BEABFF';$wood='#E1A572';$edge='#567092'
$panels=[Collections.Generic.List[object]]::new()
$sources=@{};$nativeMaps=@{};$script:textChecks=0
foreach($property in $story.runs.PSObject.Properties){
    $run=$property.Value
    if(!$run.receipt){continue} # Layout-only manifests can use explicitly labelled old frames.
    $receiptPath=Join-Path $projectRoot $run.receipt
    $hash=(Get-FileHash -LiteralPath $receiptPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if($hash -ne $run.receiptSha256){throw "Native receipt hash mismatch: $receiptPath"}
    $native=Get-Content -Raw -LiteralPath $receiptPath|ConvertFrom-Json
    $map=@{};foreach($entry in $native.frameMap){$map[$entry.file]=$entry}
    $nativeMaps[$property.Name]=$map
}
function Brush([string]$c){[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($c))}
function Rect($x,$y,$w,$h,$c){$b=Brush $c;$script:g.FillRectangle($b,$x,$y,$w,$h);$b.Dispose()}
function Text([string]$s,$x,$y,$size=24,$c=$ink,$bold=$false,$maxWidth=1450){
    $style=if($bold){[Drawing.FontStyle]::Bold}else{[Drawing.FontStyle]::Regular}
    $f=[Drawing.Font]::new('Segoe UI',[single]$size,$style,[Drawing.GraphicsUnit]::Pixel)
    $measure=$script:g.MeasureString($s,$f)
    if($measure.Width -gt $maxWidth+3){$f.Dispose();throw "Text overflows ($([math]::Round($measure.Width)) > $maxWidth): $s"}
    if($x+$measure.Width -gt 1580 -or $y+$measure.Height -gt 896){$f.Dispose();throw "Text outside canvas: $s"}
    $b=Brush $c;$script:g.DrawString($s,$f,$b,[single]$x,[single]$y);$b.Dispose();$f.Dispose();$script:textChecks++
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
    if($kind.Contains('D')){Dot $x $y 10 $pink $true}
    if($kind.Contains('M')){Dot $x $y 5 $teal}
}
function Poly($coordinates,$stroke,$fill,$dash=$false){
    $points=for($i=0;$i -lt $coordinates.Length;$i+=2){[Drawing.Point]::new($coordinates[$i],$coordinates[$i+1])}
    if($fill){$b=Brush $fill;$script:g.FillPolygon($b,[Drawing.Point[]]$points);$b.Dispose()}
    $p=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($stroke),2)
    if($dash){$p.DashStyle='Dash'}
    $script:g.DrawPolygon($p,[Drawing.Point[]]$points);$p.Dispose()
}
function AxisBreak {
    Line 786 336 815 336 $edge 2
    Line 815 336 829 324 $edge 2
    Line 829 324 843 348 $edge 2
    Line 843 348 857 336 $edge 2
    Line 857 336 1518 336 $edge 2
    Rect 1010 317 395 39 '#132137'
    Text 'Broken Y axis / not to scale' 1024 322 21 $muted $false 470
}
function LowWorld($loaded=$false){
    Poly @(800,460,1080,367,1505,460) $(if($loaded){'#88A9D4'}else{'#496080'}) $(if($loaded){'#233953'}else{''}) (!$loaded)
    Text $(if($loaded){'Top collision: loaded'}else{'Top collision: unloaded'}) 1170 384 22 $(if($loaded){$ink}else{$muted}) $true 360
    Rect 1006 510 512 15 '#574F3B';Text 'Roof 1280' 1370 530 19 $gold $false 170
    Rect 792 570 218 17 '#54482E';Line 792 570 1010 570 $gold 4
    Line 1010 480 1010 598 $gold 2 $true
    Text 'Low pad 768' 788 594 23 $gold $true 215
    Text 'Pad edge' 1019 594 20 $gold $false 150
    Dot 865 570 12 $purple $true
    Text 'Real warp' 790 533 19 $purple $false 170
}
function VerticalDiagram([string]$stage){
    Text 'Position explanation / broken vertical scale' 778 158 23 $muted $false 740
    AxisBreak
    LowWorld ($stage -in @('retry','capture'))
    switch($stage){
        'start' {
            Rect 927 231 23 23 $wood;Text 'Box' 887 265 20 $wood $true 80
            Marker 1010 242 'MCD';Text 'M = C = D  /  Y 67277' 1050 218 28 $ink $true 470
            Text 'The whole pose is supplied here.' 1050 262 22 $muted $false 470
        }
        'query' {
            Marker 1010 242 'MCD';Text 'Actual Y 67277' 1050 213 27 $ink $true 440
            Text 'Floor-query Y = 1741' 1050 254 27 $gold $true 460
            Line 1010 270 1010 305 $gold 2 $true $true
            Text 'Query wraps; the floor stays at 768.' 800 477 21 $gold $false 690
        }
        'push' {
            Rect 898 231 23 23 $wood;Marker 981 242 'CD';Marker 1148 242 'M'
            Line 1006 242 1125 242 $teal 3 $false $true
            Text '+68 X' 1015 202 25 $teal $true 140
            Text 'M stays high at Y 67277' 1174 233 23 $teal $true 360
            Text 'Cache still names low floor 768' 1033 558 23 $gold $true 480
        }
        'stop' {
            Marker 1148 242 'M';Text 'Y 67277 + 160' 797 207 26 $ink $true 330
            Text '>= no-ceiling value 20000' 797 247 25 $gold $true 540
            Text 'Stopped quarter / cache stays 768' 811 477 23 $gold $true 680
            Text 'No physical ceiling is required.' 1020 287 21 $muted $false 500
        }
        'copy' {
            Marker 1148 242 'MD';Text 'Save high M into D' 1190 225 25 $pink $true 340
            Line 1148 266 1148 552 $teal 3 $true $true
            Marker 1148 570 'MC';Text 'Then snap M to 768' 1180 552 25 $teal $true 350
            Text 'Immediate store, not a fall' 1173 471 20 $muted $false 340
        }
        'gap' {
            Marker 1148 242 'D';Text 'D  Y 67277' 1190 222 28 $pink $true 345
            Marker 1148 570 'MC';Text 'M + C  Y 768' 1188 551 28 $teal $true 340
            Line 1167 256 1167 554 $ink 2 $true
            Rect 1178 472 350 45 '#132137';Text '66509-unit gap' 1191 477 27 $ink $true 330
        }
        'retry' {
            Marker 1148 242 'D';Text 'D query aliases to 1741' 1180 228 23 $pink $true 360
            Marker 1148 570 'MC';Line 1148 548 1148 264 $pink 3 $true $true
            Line 883 570 1121 570 $purple 3 $true
            Text 'Low contact + failed low lookup' 804 477 22 $purple $true 700
        }
        'capture' {
            Marker 1130 420 'MCD';Text 'M = C = D  /  Y 1818.9613' 800 209 28 $teal $true 710
            Text 'Input 7: floor owner = platform = top' 800 256 25 $gold $true 700
            Text 'Local surface height; no VPU offset added.' 804 477 21 $muted $false 700
        }
        default {throw "Unknown vertical stage: $stage"}
    }
}
function ActionDiagram([string]$stage){
    Text 'Action sequence / explanatory diagram' 778 158 23 $muted $false 740
    if($stage -eq 'walkprep'){
        Rect 808 232 675 84 '#1D3545';Text 'CUT 1: supplied walking on roof 1280' 831 246 27 $ink $true 635
        Line 1145 323 1145 367 $teal 3 $false $true
        Rect 808 380 675 84 '#223F40';Text 'One native walking update sets slide speed' 831 396 26 $teal $true 635
        Text 'This is a low preparation state.' 832 493 27 $muted $false 635
        Text 'It does not travel up into a VPU.' 832 535 27 $muted $false 635
    } elseif($stage -eq 'walkcut'){
        Rect 809 219 679 92 '#46363B';Text 'CUT 2: supply high M / C / D and box' 832 238 27 $pink $true 640
        Text 'Y 67277; keep native action and speeds' 834 277 23 $muted $false 640
        Line 1145 321 1145 364 $teal 3 $false $true
        Rect 809 377 679 155 '#263B43';Text 'Z + stick  →  WALKING' 834 389 26 $ink $true 640
        Text '→  CROUCH SLIDE  →  GROUND BONK' 834 434 26 $teal $true 640
        Text 'All in the gap-producing update.' 834 483 23 $muted $false 640
        Text 'No additional input between these actions.' 814 574 24 $gold $true 700
    } else {
        Rect 808 222 675 82 '#1D3545';Text 'Supplied ground slide / speed 20' 833 242 29 $ink $true 630
        Line 1145 313 1145 351 $teal 3 $false $true
        Rect 808 366 675 82 '#3A3446';Text 'Stopped step  →  GROUND BONK' 833 387 29 $pink $true 630
        Line 1145 455 1145 493 $teal 3 $false $true
        Rect 808 509 675 82 '#223F40';Text 'Floor alignment still runs' 833 530 29 $teal $true 630
    }
}
function ArrivalDiagram {
    Text 'First Area 2 position / plan view, X and Z' 778 158 23 $muted $false 740
    Text '−Z ↑' 798 211 22 $muted $false 100
    Rect 912 410 366 154 '#373043'
    Line 912 410 1278 410 $purple;Line 912 564 1278 564 $purple
    Line 912 410 912 564 $purple;Line 1278 410 1278 564 $purple
    Text 'Elevator footprint' 930 527 24 $purple $true 330
    Dot 1094 483 8 $purple;Text 'Usual entry (0, 256)' 1112 468 22 $muted $false 390
    Line 1105 465 1225 285 $teal 3 $true $true;Marker 1236 268 'MCD'
    Text 'Useful entry' 1275 230 27 $teal $true 260
    Text 'Y 5500' 1275 272 25 $ink $true 250
    Text 'X 365.593 / Z −1096.803' 815 591 25 $ink $false 700
    Text 'Dashed arrow compares positions; it is not a travelled path.' 806 361 20 $muted $false 710
}
function RetentionDiagram {
    Text 'Input 27 telemetry / no exactly joined image' 778 158 23 $muted $false 740
    Rect 809 219 679 92 '#46363B';Text 'Top active flags = 0' 832 238 29 $pink $true 640
    Text 'The spinning-top object is now inactive.' 834 278 23 $muted $false 640
    Line 1145 321 1145 364 $teal 3 $false $true
    Rect 809 377 679 112 '#263B43';Text 'Floor owner = platform = old top' 834 393 27 $teal $true 640
    Text 'The stored reference remains during disappearance.' 834 442 23 $ink $false 640
    Text 'Next recorded area: Area 2, input 30.' 814 560 27 $gold $true 700
    Text 'Left image is paused at input 26.' 814 605 22 $muted $false 700
}
function HorizontalDiagram([string]$stage){
    Text 'Actual X versus aliased terrain / not to scale' 778 158 23 $muted $false 750
    Rect 799 211 303 310 '#1B2D42';Rect 1206 211 319 310 '#213142'
    Text 'REAL SSL' 817 229 27 $ink $true 260
    Text 'X + 65536' 1224 229 27 $ink $true 280
    Poly @(821,370,950,293,1079,370) '#88A9D4' '#233953'
    Line 821 460 1081 460 $gold 4;Dot 886 460 12 $purple $true
    Text 'Warp + top live here' 811 482 21 $purple $true 285
    Line 1224 460 1505 460 $gold 3 $true
    Text 'Terrain query aliases' 1222 481 21 $gold $true 290
    Marker 1381 $(if($stage -eq 'horizontal_gap'){460}else{334}) $(if($stage -eq 'horizontal_gap'){'MC'}else{'MCD'})
    if($stage -eq 'horizontal_gap'){
        Marker 1381 304 'D';Line 1381 328 1381 439 $teal 3 $true $true
        Text 'Y snaps; X stays far away' 1219 530 20 $teal $true 300
    } else {Text 'Mario + supplied box' 1221 386 21 $teal $true 295}
    Line 1109 363 1193 363 $edge 2 $true
    Text '…' 1127 321 40 $muted $false 80
    Text 'No second warp or second top is created.' 814 575 26 $purple $true 700
    Text 'Horizontal floor aliasing does not return Mario''s raw X.' 804 614 20 $muted $false 720
}
function SummaryDiagram {
    Text 'What the separate runs establish' 778 158 23 $muted $false 740
    $rows=@(@('VPU crawl','Supplied high crawl → useful handoff',$teal),@('VPU slide','Supplied high slide → useful handoff',$teal),@('VPU walking','Two supplied cuts; Z makes the slide',$teal),@('Horizontal PU','Aliases terrain; misses the real warp',$gold))
    $y=216
    foreach($r in $rows){Rect 803 $y 698 80 '#1E3148';Text $r[0] 820 ($y+7) 25 $r[2] $true 660;Text $r[1] 820 ($y+42) 23 $ink $false 660;$y+=96}
    Text 'A continuous allowed route remains open.' 811 614 22 $muted $true 710
}
function MakePanel($segment,$shot,$number,$nativeEntry){
    $bitmap=[Drawing.Bitmap]::new($W,$H);$script:g=[Drawing.Graphics]::FromImage($bitmap)
    $script:g.SmoothingMode='AntiAlias';$script:g.InterpolationMode='NearestNeighbor';$script:g.PixelOffsetMode='Half';$script:g.TextRenderingHint='AntiAliasGridFit'
    $script:g.Clear([Drawing.ColorTranslator]::FromHtml('#0B1321'))
    Rect 38 32 6 89 $teal;Text $segment.tag 62 29 22 $teal $true 1450
    Text $segment.title 60 65 46 $ink $true 1460
    Rect 44 145 690 496 '#101D2D';Rect 752 145 804 496 '#132137'
    $sourceLabel=$segment.sourceLabel
    if($nativeEntry){$sourceLabel += " / input $($nativeEntry.completedInput)"}
    Text $sourceLabel 62 158 22 $muted $false 650
    $img=[Drawing.Image]::FromFile($shot);$scaledHeight=[int](560*$img.Height/$img.Width)
    $script:g.DrawImage($img,109,199,560,$scaledHeight);$img.Dispose()
    if($segment.badge){Rect 67 597 641 31 '#101D2D';Text $segment.badge 77 600 19 $gold $true 618}
    switch($segment.diagram){
        {$_ -in @('start','query','push','stop','copy','gap','retry','capture')}{VerticalDiagram $_;break}
        {$_ -in @('walkprep','walkcut','slide')}{ActionDiagram $_;break}
        'arrival'{ArrivalDiagram;break}
        'retention'{RetentionDiagram;break}
        {$_ -in @('horizontal','horizontal_gap')}{HorizontalDiagram $_;break}
        'summary'{SummaryDiagram;break}
        default{throw "Unknown diagram $($segment.diagram)"}
    }
    Rect 44 652 1512 48 '#19273C'
    Marker 74 676 'M';Text 'M  Movement' 89 662 22 $teal $false 207
    Dot 303 676 10 $blue $true;Text 'C  Collision' 322 662 22 $blue $false 245
    Dot 554 676 10 $pink $true;Text 'D  Stored graphics' 573 662 22 $pink $false 320
    Line 928 676 956 676 $gold 4;Text 'Cached floor' 968 662 22 $gold $false 235
    Dot 1245 676 10 $purple $true;Text 'Warp' 1263 662 22 $purple $false 115
    Rect 1393 668 16 16 $wood;Text 'Box' 1421 662 22 $wood $false 100
    if($segment.lines.Count -ne 2){throw 'Every card needs exactly two commentary lines.'}
    Text $segment.lines[0] 61 721 31 $ink $false 1475
    Text $segment.lines[1] 61 765 31 $ink $false 1475
    Line 62 829 1537 829 $edge 1;Text $segment.footer 61 847 19 $muted $false 1475
    $fn='panel-{0:0000}.png' -f $number;$path=Join-Path $out $fn
    $bitmap.Save($path,[Drawing.Imaging.ImageFormat]::Png)
    $script:g.Dispose();$bitmap.Dispose()
    return $fn
}
$queue=[Collections.Generic.List[string]]::new();$segments=[Collections.Generic.List[object]]::new();$frame=0;$panelNumber=0
foreach($s in $story.segments){
    $run=$story.runs.($s.run)
    if(!$run){throw "Missing run $($s.run)"}
    $shotDir=[IO.Path]::GetFullPath((Join-Path $projectRoot $run.shots))
    $indices=if($s.range){$s.range[0]..$s.range[1]}else{@([int]$s.shot)}
    $first=$frame
    foreach($index in $indices){
        $shot=Join-Path $shotDir ('super_mario_64-{0:000}.png' -f $index)
        if(!(Test-Path -LiteralPath $shot)){throw "Missing original capture $shot"}
        $nativeEntry=$null
        if($nativeMaps.ContainsKey($s.run)){
            $nativeEntry=$nativeMaps[$s.run][[IO.Path]::GetFileName($shot)]
            if(!$nativeEntry -or $null -eq $nativeEntry.completedInput){throw "Unmapped native framebuffer: $shot"}
        }
        if(!$sources.ContainsKey($shot)){
            $hash=(Get-FileHash -LiteralPath $shot -Algorithm SHA256).Hash.ToLowerInvariant()
            if($nativeEntry -and $hash -ne $nativeEntry.sha256){throw "Native image hash mismatch: $shot"}
            $sources[$shot]=@{path=[IO.Path]::GetRelativePath($projectRoot,$shot);sha256=$hash;completedInput=$nativeEntry.completedInput;framebufferTimer=$nativeEntry.framebufferTimer;state=$nativeEntry.state}
        }
        $fn=MakePanel $s $shot $panelNumber $nativeEntry
        $count=if($s.range){[int]$s.repeat}else{[int][math]::Round([double]$s.seconds*$fps)}
        if($count -le 0){throw 'Nonpositive frame duration'}
        $duration=([double]$count/$fps).ToString('0.#########',[Globalization.CultureInfo]::InvariantCulture)
        $queue.Add("file '$fn'");$queue.Add("duration $duration")
        $panels.Add(@{file=$fn;source=$sources[$shot].path;sourceIndex=$index;completedInput=$nativeEntry.completedInput;firstFrame=$frame;frames=$count;segment=$segments.Count})
        $frame+=$count;$panelNumber++
    }
    $segments.Add(@{tag=$s.tag;title=$s.title;run=$s.run;diagram=$s.diagram;lines=$s.lines;footer=$s.footer;firstFrame=$first;lastFrame=$frame-1;startSeconds=$first/$fps;endSeconds=$frame/$fps})
}
$queue.Add($queue[$queue.Count-2]);$concat=Join-Path $out 'frames.txt';[IO.File]::WriteAllLines($concat,$queue,[Text.Encoding]::ASCII)
$posterSegment=[int]$story.posterSegment;$posterPanel=$panels | Where-Object {$_.segment -eq $posterSegment}|Select-Object -First 1
Copy-Item -LiteralPath (Join-Path $out $posterPanel.file) -Destination (Join-Path $out 'ink-vpu-actions-poster.png')
# Contact sheet: one representative per story segment, with readable chapter order.
$columns=3;$thumbW=480;$thumbH=270;$rows=[int][math]::Ceiling($segments.Count/$columns)
$sheet=[Drawing.Bitmap]::new(($thumbW*$columns),($thumbH*$rows));$sheetG=[Drawing.Graphics]::FromImage($sheet);$sheetG.Clear([Drawing.Color]::Black)
for($i=0;$i -lt $segments.Count;$i++){$p=$panels|Where-Object {$_.segment -eq $i}|Select-Object -First 1;$im=[Drawing.Image]::FromFile((Join-Path $out $p.file));$sheetG.DrawImage($im,($i%$columns)*$thumbW,[int][math]::Floor($i/$columns)*$thumbH,$thumbW,$thumbH);$im.Dispose()}
$sheet.Save((Join-Path $out 'contact-sheet.png'),[Drawing.Imaging.ImageFormat]::Png);$sheetG.Dispose();$sheet.Dispose()
$transcript=[Collections.Generic.List[string]]::new();$transcript.Add('# VPU crawl, slide and walking: video commentary');$transcript.Add('');$transcript.Add($story.scope);$transcript.Add('')
foreach($s in $segments){$a=[TimeSpan]::FromSeconds($s.startSeconds);$b=[TimeSpan]::FromSeconds($s.endSeconds);$transcript.Add("## $($a.ToString('mm\:ss\.fff'))–$($b.ToString('mm\:ss\.fff')): $($s.title)");$transcript.Add('');$transcript.Add($s.tag);$transcript.Add('');foreach($l in $s.lines){$transcript.Add($l)};$transcript.Add('');$transcript.Add($s.footer);$transcript.Add('')}
[IO.File]::WriteAllLines((Join-Path $out 'ink-vpu-actions-transcript.md'),$transcript,[Text.UTF8Encoding]::new($false))
$vtt=[Collections.Generic.List[string]]::new();$vtt.Add('WEBVTT');$vtt.Add('')
foreach($s in $segments){$a=[TimeSpan]::FromSeconds($s.startSeconds);$b=[TimeSpan]::FromSeconds($s.endSeconds);$vtt.Add("$($a.ToString('hh\:mm\:ss\.fff')) --> $($b.ToString('hh\:mm\:ss\.fff'))");$vtt.Add(($s.lines -join "`n"));$vtt.Add('')}
[IO.File]::WriteAllLines((Join-Path $out 'ink-vpu-actions-commentary.vtt'),$vtt,[Text.UTF8Encoding]::new($false))
$video=Join-Path $out 'ink-vpu-actions.mp4'
if(!$PanelsOnly){
    & $Ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i $concat -vf 'fps=30' -frames:v $frame -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -movflags +faststart $video
    if($LASTEXITCODE -ne 0){throw 'Video encoding failed'}
    & $Ffmpeg -hide_banner -loglevel error -i $video -f null -
    if($LASTEXITCODE -ne 0){throw 'Full video decode failed'}
}
$receipt=[ordered]@{schema=1;scope=$story.scope;format='1600x900;30fps;H264;yuv420p;silent;faststart';frames=$frame;durationSeconds=$frame/$fps;segments=$segments;panels=$panels;uniqueOriginalFrames=@($sources.Values);textFitChecks=$script:textChecks;manifestSha256=(Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant();rendererSha256=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant();posterSha256=(Get-FileHash -LiteralPath (Join-Path $out 'ink-vpu-actions-poster.png') -Algorithm SHA256).Hash.ToLowerInvariant();runs=$story.runs}
if(!$PanelsOnly){$receipt.videoSha256=(Get-FileHash -LiteralPath $video -Algorithm SHA256).Hash.ToLowerInvariant()}
[IO.File]::WriteAllText((Join-Path $out 'ink-vpu-actions-video-receipt.json'),($receipt|ConvertTo-Json -Depth 14),[Text.UTF8Encoding]::new($false))
Write-Output (@{frames=$frame;durationSeconds=$frame/$fps;textFitChecks=$script:textChecks;videoSha256=$receipt.videoSha256}|ConvertTo-Json)
