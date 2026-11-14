param([Parameter(Mandatory=$true)][string]$Output,[switch]$PanelsOnly)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$out=[IO.Path]::GetFullPath($Output)
if(Test-Path -LiteralPath $out){throw 'Use a fresh render directory'}
New-Item -ItemType Directory -Path $out | Out-Null
$story=Get-Content "$PSScriptRoot/storyboard.json" -Raw|ConvertFrom-Json
$capture=[IO.Path]::GetFullPath("$PSScriptRoot/../jp-ink-enlarged-bob-video")
$maps=@{}
foreach($case in @('positive','no-final-box')){$sourceCase=if($case -eq 'positive'){'positive-closeup'}else{$case};$maps[$case]=Get-Content "$capture/$sourceCase-frame-map.json" -Raw|ConvertFrom-Json}
$ink='#EAF1FD';$muted='#A8B9D1';$teal='#5CE3CB';$blue='#79B8FF';$pink='#FF90BC';$gold='#FFD17C';$purple='#BEABFF';$edge='#567092'
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
 if($kind.Contains('C')){Dot $x $y 15 $blue $true};if($kind.Contains('G')){Dot $x $y 10 $pink $true};if($kind.Contains('M')){Dot $x $y 5 $teal}
}
function Card($y,$label,$detail,$c=$teal){Rect 788 $y 742 94 '#203348';Text $label 808 ($y+9) 29 $c $true 702;Text $detail 808 ($y+52) 23 $ink $false 702}
function Floor {Line 805 554 1509 554 $gold 4;Text 'Cached floor 768' 807 577 25 $gold $true 400}
function Diagram([string]$id){
 Text 'EXPLANATORY DIAGRAM / NOT TO SCALE' 780 160 21 $muted $false 740
 switch($id){
 'roles' {Card 211 '1  Shell' 'Mount + Z creates the ground slide.' $teal;Card 333 '2  Bloated black Bob-omb' 'An earlier shove sets up the low-floor lookup.' $blue;Card 455 '3  Crazy Box' 'The final shove sets up top capture.' $gold}
 'setup' {
  Marker 1080 273 'MCG';Text 'M = C = G / Y 19,900' 1120 250 28 $pink $true 410
  Dot 1080 369 24 $teal;Text 'Frozen initialized shell' 1120 343 26 $teal $true 410;Text 'Y 19,890' 1120 385 25 $ink $false 380
  Line 1080 292 1080 335 $teal 3 $false $true;Text 'FREEFALL' 805 227 29 $ink $true 265;Text '10 units above shell' 805 460 28 $gold $true 700
  Text 'X -1960 / Z -1230 / A released' 805 514 26 $muted $false 700;Text 'Initial state is supplied.' 805 569 27 $gold $true 700
 }
 'shell' {Card 209 'FREEFALL → mount → Z → BUTT SLIDE' 'Native action changes on update 128.' $teal;Card 331 'M = C / Y 1809.207' 'Floor alignment puts movement on the top.' $blue;Card 453 'G / Y 19,900' 'Saved coordinates remain high at this boundary.' $pink}
 'positions' {Card 211 'M  Movement' 'Used by movement and floor alignment.' $teal;Card 333 'C  Collision' 'Mario object position used for actor overlap.' $blue;Card 455 'G  Stored Graphics' 'gfx.pos — not the drawn model or matrix.' $pink}
 'carry' {
  Text 'Plan view / X and Z' 807 211 27 $muted $true 660
  Dot 1130 371 136.5 $gold $true;Dot 1310 371 55.5 $blue $true
  Marker 1310 371 'C';Text 'Old C' 1382 351 26 $blue $true 140
  Dot 1130 371 10 $gold;Marker 1126 385 'M'
  Line 1285 378 1152 386 $teal 3 $true $true
  Text 'Bob' 1087 293 26 $gold $true 120;Text 'Moved M' 1000 437 25 $teal $true 245
  Text 'The two contact circles overlap.' 805 530 26 $ink $false 710
  Text '91 + 37 = 128 > contact distance 120.06' 805 568 25 $gold $true 710
  Text 'Stock radius 65 misses this exact placement.' 805 605 22 $muted $false 710
 }
 'bob' {Card 210 'UPDATE 129 / actor placement supplied' 'The live bloated Bob gives the earlier shove.' $gold;Card 332 'M = C / Y 1839.447' 'X -2117.027 / Z -1113.009' $teal;Card 454 'BUTT SLIDE / no platform reference' 'The next update will query this new position.' $blue}
 'cache' {Card 210 '1  Initial lookup → save 768' 'This happens before the final actor shove.' $gold;Card 332 '2  Actor shove → local validation query' 'That separate query does not replace the cache.' $muted;Card 454 '3  Ground quarter → STOP' 'The early stop preserves the saved floor.' $pink}
 'box' {
  Dot 1025 318 20 $gold;Rect 1008 301 34 34 '#8B673D';Marker 1115 332 'MC';Line 1145 332 1433 255 $teal 4 $false $true;Marker 1460 248 'MC'
  Text 'Crazy Box' 826 263 28 $gold $true 230;Text 'final shove' 826 302 27 $gold $false 230
  Text 'X -2117.027 → -2200.002' 806 430 30 $teal $true 700
  Text 'Z -1113.009 → -1075.004' 806 478 30 $blue $true 700
  Text 'Y remains 1839.447 during this shove.' 806 543 25 $pink $true 700
  Text 'Bob pushes on 129; Crazy Box pushes on 130.' 806 594 23 $muted $false 710
 }
 'gap' {
  Marker 1118 259 'G';Text 'G.Y 1839.447' 1157 239 33 $pink $true 375
  Line 1118 288 1118 513 $teal 3 $true $true;Text 'Store, then align' 805 351 27 $muted $true 290
  Text 'Gap 1071.447' 1160 391 28 $pink $true 355
  Floor;Marker 1118 554 'MC';Text 'M = C / Y 768' 1160 509 29 $teal $true 360
  Text 'Immediate change, not a visible fall' 805 610 23 $muted $false 710
 }
 'retry' {
  Marker 1090 251 'G';Text 'High retry from G' 1132 232 29 $pink $true 380
  Line 1090 502 1090 286 $pink 3 $true $true;Text 'Select spinning top' 1132 294 25 $gold $true 390
  Floor;Marker 1090 554 'MC';Dot 1090 554 30 $purple $true
  Text 'Low C overlaps real warp' 805 449 28 $purple $true 690
  Text 'Warp 64 accepted / platform = top 61' 805 392 27 $teal $true 710
 }
 'retention' {Card 210 'Warp accepted / Mario disappears' 'The spinning top is now the platform reference.' $purple;Card 332 'Observed Area 1 countdown' 'Every observed boundary retains top 61.' $teal;Card 454 'Area transition' 'Missing camera observations are not invented.' $muted}
 'arrival' {
  Text 'Area 2 / X-Z plan view / Y 5500' 805 211 27 $muted $true 710
  Dot 991 495 12 $purple;Text 'Ordinary' 806 472 26 $purple $true 180;Text '(0, 256)' 806 515 25 $muted $false 180
  Marker 1284 318 'MCG';Line 1009 482 1257 338 $teal 3 $true $true
  Text 'Useful spawn' 1307 271 27 $teal $true 225;Text 'X 365.593' 1307 321 25 $ink $false 225;Text 'Z -1096.803' 1307 361 25 $ink $false 230
  Text 'Different arrival, not just an ordinary warp.' 805 573 25 $gold $true 715
  Text 'Arrow compares coordinates; it is not a path.' 805 610 22 $muted $false 710
 }
 'comparison' {Card 211 'Omit only the final Crazy Box placement' 'Bob remains live and can still nudge Mario.' $gold;Card 333 'Fresh cache 768 + gap + accepted warp' 'These conditions alone are not enough.' $pink;Card 455 'No top capture → ordinary spawn' '(0, 5500, 256) instead of useful displacement.' $purple}
 'scope' {Card 210 'Verified: slide → cache → top → useful spawn' 'Three actors fill the local roles. No Buddy.' $teal;Card 332 'Supplied: entry, actor states and placements' 'The bloated Bob donor is a separate history.' $gold;Card 454 'Open: one continuous gameplay route' 'No Mario edits follow the initial airborne cut.' $pink}
 default{throw "Unknown diagram $id"}
 }
}
$queue=[Collections.Generic.List[string]]::new();$panels=[Collections.Generic.List[object]]::new();$chapters=[Collections.Generic.List[object]]::new();$frame=0;$number=0;$chapter=0
foreach($s in $story.segments){
 $totalFrames=[int][math]::Round([double]$s.seconds*30)
 $start=$frame;$case=if($s.id -eq 'comparison'){'no-final-box'}else{'positive'}
 $steps=if($s.range){[int]$s.range[0]..[int]$s.range[1]}else{@([int]$s.sourceStep)}
 $selected=@();foreach($step in $steps){$m=$maps[$case].frameMap|Where-Object {$null -ne $_.completedBridge -and $_.completedBridge -eq $step}|Select-Object -First 1;if(!$m){throw "Unjoined bridge $step ($case)"};$selected+=,$m}
 $j=0
 foreach($m in $selected){
  $path=Join-Path $capture $m.file;if((Get-FileHash $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $m.sha256){throw 'Native image hash mismatch'}
  $bitmap=[Drawing.Bitmap]::new(1600,900);$script:g=[Drawing.Graphics]::FromImage($bitmap);$script:g.SmoothingMode='AntiAlias';$script:g.InterpolationMode='NearestNeighbor';$script:g.PixelOffsetMode='Half';$script:g.TextRenderingHint='AntiAliasGridFit';$script:g.Clear([Drawing.ColorTranslator]::FromHtml('#0B1321'))
  Rect 38 32 6 89 $teal;Text $s.tag 62 29 22 $teal $true 1450;Text $s.title 60 65 42 $ink $true 1460
  Rect 44 145 690 496 '#101D2D';Rect 752 145 804 496 '#132137'
  $label=if($case -eq 'no-final-box'){'Original JP / omission control'}else{'Original JP / render-camera closeup'}
  Text $label 62 158 23 $muted $false 650
  $img=[Drawing.Image]::FromFile($path);$script:g.DrawImage($img,109,198,560,420);$img.Dispose()
  $cameraLabel=if($case -eq 'no-final-box'){'unchanged camera'}else{'render camera edited'}
  $timeLabel=if($m.completedBridge -le 4){"Replay after update $([int]$m.completedBridge+127)"}elseif($m.completedBridge -ge 27){"Later replay / boundary $($m.completedBridge)"}else{"Native boundary $($m.completedBridge)"}
  Rect 62 598 651 32 '#101D2D';Text "$timeLabel / $cameraLabel" 77 600 19 $muted $false 620
  Diagram $s.diagram
  Rect 44 652 1512 48 '#19273C';Marker 74 676 'M';Text 'M  Movement' 89 662 22 $teal $false 210
  Dot 322 676 10 $blue $true;Text 'C  Collision' 342 662 22 $blue $false 225
  Dot 581 676 10 $pink $true;Text 'G  Stored Graphics' 603 662 22 $pink $false 345
  Text 'Supplied setup / A released' 1110 663 21 $gold $true 422
  Text $s.lines[0] 61 720 28 $ink $false 1475;Text $s.lines[1] 61 764 28 $ink $false 1475
  Line 62 829 1537 829 $edge 1;Text $s.footer 61 846 18 $muted $false 1475
  $name='panel-{0:0000}.png' -f $number;$bitmap.Save((Join-Path $out $name),[Drawing.Imaging.ImageFormat]::Png);$script:g.Dispose();$bitmap.Dispose()
  $count=[int][math]::Floor($totalFrames/$selected.Count);if($j -eq $selected.Count-1){$count=$totalFrames-($count*$j)}
  $queue.Add("file '$name'");$queue.Add('duration '+([double]$count/30).ToString('0.#########',[Globalization.CultureInfo]::InvariantCulture))
  $panels.Add(@{file=$name;source=$m.file;sourceSha256=$m.sha256;case=$case;nativeBridge=$m.completedBridge;framebufferTimer=$m.framebufferTimer;chapter=$chapter;firstFrame=$frame;frames=$count})
  $frame+=$count;$number++;$j++
 }
 $chapters.Add(@{id=$s.id;title=$s.title;tag=$s.tag;lines=$s.lines;footer=$s.footer;firstFrame=$start;lastFrame=$frame-1;startSeconds=$start/30;endSeconds=$frame/30});$chapter++
}
$queue.Add($queue[$queue.Count-2]);[IO.File]::WriteAllLines((Join-Path $out 'frames.txt'),$queue,[Text.Encoding]::ASCII)
$poster=$panels|Where-Object {$_.chapter -eq 8}|Select-Object -First 1;Copy-Item (Join-Path $out $poster.file) (Join-Path $out 'enlarged-bob-handoff-poster.png')
$sheet=[Drawing.Bitmap]::new(1440,1350);$sg=[Drawing.Graphics]::FromImage($sheet);$sg.Clear([Drawing.Color]::Black)
for($i=0;$i -lt $chapters.Count;$i++){$p=$panels|Where-Object {$_.chapter -eq $i}|Select-Object -First 1;$im=[Drawing.Image]::FromFile((Join-Path $out $p.file));$sg.DrawImage($im,($i%3)*480,[int][math]::Floor($i/3)*270,480,270);$im.Dispose()}
$sheet.Save((Join-Path $out 'contact-sheet.png'),[Drawing.Imaging.ImageFormat]::Png);$sg.Dispose();$sheet.Dispose()
$video=Join-Path $out 'enlarged-bob-handoff-silent.mp4'
if(!$PanelsOnly){$ff=(Get-ChildItem 'C:/Users/tariq/AppData/Local/Overwolf/Extensions' -Filter ffmpeg.exe -Recurse|Select-Object -First 1).FullName;& $ff -hide_banner -loglevel error -f concat -safe 0 -i (Join-Path $out 'frames.txt') -vf fps=30 -frames:v $frame -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p -movflags +faststart $video;if($LASTEXITCODE -ne 0){throw 'Video encode failed'}}
$receipt=@{schema=1;scope=$story.scope;frames=$frame;durationSeconds=$frame/30;chapters=$chapters;panels=$panels;textFitChecks=$script:checks.Count;rendererSha256=(Get-FileHash $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant();storyboardSha256=(Get-FileHash "$PSScriptRoot/storyboard.json" -Algorithm SHA256).Hash.ToLowerInvariant();coordinateLabels=@{M='Movement';C='Collision';G='Stored Graphics (gfx.pos), not rendered pose'}}
[IO.File]::WriteAllText((Join-Path $out 'render-receipt.json'),($receipt|ConvertTo-Json -Depth 14),[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $out 'text-fit-checks.json'),($script:checks|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
Write-Output "Rendered $number panels, $frame frames, $($frame/30) seconds, $($script:checks.Count) text-fit checks"
