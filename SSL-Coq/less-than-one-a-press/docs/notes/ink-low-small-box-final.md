# A small crate can make the final shove in the low Ink setup

18 November 2026. **Yes. On the original Japanese ROM, Mario dropped SSL Area 1’s ordinary small breakable box before mounting the shell. The bloated black Bob-omb gave the first shove, the small crate gave the second, and Mario entered Area 2 at (365.592773, 5500, −1096.802612).** The experiment supplied the two carrying states and their remote held-object positions. A was released throughout. How to join those carrying states in one controller history remains open. [Positive ROM receipt](../../instrumentation/jp-ink-low-small-box-final/positive-receipt.json)

## Why the crate placement matters

Both replays below use the same Mario, shell, Bob-omb, inputs and small crate. Only the X/Z of the intended crate drop changes. In both, the Bob-omb puts Mario where the game can find the low floor at Y 768. Then the crate shoves him sideways. Where that shove **ends** decides which floor the game finds on the following update. The original-ROM probe observed the actual object and Mario’s coordinates as each shove executed.

| What the Japanese game did | Retuned small crate | Small crate at the former Crazy Box drop |
|---|---|---|
|126, Mario drops the crate from a supplied carry at Y 1920|Supplied drop X/Z (−2110.089844, −1106.102466)|Supplied drop X/Z (−2102.720703, −1119.561890)|
|128, fresh Z as Mario meets the parked shell|Shell 71 releases held Bob-omb 39. Mario mounts, enters crouch slide, then butt slide.|Same|
|129, Bob-omb shoves Mario|Its radius is 91. Mario finishes at movement and collision (−2117.026855, 1839.447266, −1113.008545).|Same|
|130, first floor lookup|At those coordinates the game finds static floor **768**, before the crate pushes.|Same|
|130, crate shoves Mario|Crate 23 has radius 60. At contact its center is (−2116.026855, 1925.437866, −1113.458496). Mario ends at X/Z (−2199.961670, −1075.789673).|The same crate has moved to (−2108.657715, 1920.500366, −1126.917969). Mario ends at X/Z (−2156.197021, −1048.152466).|
|130, positions after the update|Movement and collision Y **768**, stored graphics Y **1839.447266**. The gap is **1071.447266**.|Same vertical gap|
|131, real upper warp and floor lookup|Warp 64 accepts Mario. His low lookup misses. Retrying from stored graphics finds the spinning top at Y **1915.737061**, installing platform 61.|Warp 64 accepts Mario. After wall correction the low lookup at (−2099, 768, −1048.152466) finds static floor 768. This succeeds immediately, so the game skips the stored-graphics retry.|
|First Area 2 movement position|**(365.592773, 5500, −1096.802612)**|**(0, 5500, 256)**|

Update numbers are the top timer **before** each update. Stored graphics is Mario’s `gfx.pos`. In the useful case the top remains installed through the observed Area 1 transition, letting it displace the spawn. Wafel records each update. The ROM observer matched 1,080 field comparisons per case at 27 camera observations, with two transition camera boundaries absent from its trace. [Untuned ROM receipt](../../instrumentation/jp-ink-low-small-box-final/control-receipt.json) · [ROM logs and verifier](../../instrumentation/jp-ink-low-small-box-final/README.md)

## What Mario and the game were given

The conditional four-pillar history includes a forced shell-box spawn, a low pickup preparation and a supplied pickup target. A real throw with supplied held-object last position (HOLP) parks shell 71 at (−1962.440430, 1800, −1243.341309). Before 126 the harness places Mario at (5900, 1920, 3440), in holding freefall with the stock small crate in his hands. Z executes the actual drop to remote X/Z and Mario’s own Y. For the useful release, native floor correction brings the crate to Y 1929.547363 by the end of 126. The crate then moves under its own behavior, with no later crate writes.

Before 128 the harness separately supplies Mario at (−1962.440430, 1810, −1243.341309) holding Bob-omb 39, with velocity (0, −16, 0), facing yaw 0. It supplies a held profile from a separate radius-91 Bob-omb donor and a release HOLP. The shell interaction drops the Bob-omb before Mario’s riding action processes Z. From the 126 setup the inputs are Z, neutral, Z, then neutral through arrival. Nothing edits Mario or any actor after the 128 setup. The Crazy Box stays at its stock position. [All positive setup writes and inputs](../../instrumentation/ink-low-small-box-final/positive.json) · [Inherited shell and Bob-omb setup](ink-shell-placement-join.md)

## How much retuning was tested

Wafel tested 43 selected drop positions at Y 1920 and one omitted-crate control through arrival or 45 updates. Two produced the displaced spawn, 33 reached the ordinary spawn, and nine were still in Area 1 at the cutoff. A separate rectangular search tested 110 integer X/Z pairs and 117 quarter-unit pairs for top capture on 131. None of the integer pairs captured there. Two quarter-unit pairs captured and were followed through the useful spawn. Their drop positions were **(−2109.75, 1920, −1106.25)** and **(−2108.5, 1920, −1106.75)**. The rectangles overlap, and these sampled positions do not establish a continuous interval or a required precision. Each search was run from two independent initializations. [Ranges, tests and reconstruction commands](../../instrumentation/ink-low-small-box-final/README.md)

## Reachability and reproduction

An earlier no-new-A original-ROM replay actually picked up, carried uphill and threw this stock crate. That puts a real movable SSL item behind the proposed replacement. The missing gameplay link is getting Mario from a usable crate release into the held, bloated Bob-omb approach above the shell while the crate moves into position. The next experiment is to move the crate drop earlier and measure how many intervening updates still give the required shove. That would establish how much time is available for pickup and travel. The project’s complete no-new-A route assessment remains open. This result adds runtime evidence and changes no Coq assumption or subjective route estimate. [Controller pickup-and-carry record](ink-buddy-replacement-delivery.md)

Starting proof revision `01c1109e31216f854fe30bfa70866e62bcc00614`. The applicable source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`, with local decompile checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Search used Wafel 0.8.5, Python 3.9.13 and the JP DLL identified in the experiment record. Original JP replays used Mupen64Plus 2.5.9 in interpreter mode and ROM SHA-256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`. The linked packets preserve the exact inputs, edits and logs, with commands to reproduce each test. [Wafel packet](../../instrumentation/ink-low-small-box-final/README.md) · [Original JP packet](../../instrumentation/jp-ink-low-small-box-final/README.md)
