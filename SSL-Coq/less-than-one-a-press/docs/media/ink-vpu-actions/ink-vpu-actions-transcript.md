# VPU crawl, slide and walking: video commentary

Silent visual commentary matching the earlier crawl demo. Six independent original JP ROM supplied-state replays: three vertical handoffs and three horizontal comparisons. Source/Wafel diagrams expand within-update ordering; native logs observe end-update states. No continuous controller-reachable high entry or box delivery is claimed. The stock camera is unmodified.

## 00:00.000–00:08.000: VPU crawl, slides and walking

INK HANDOFF / SIX INDEPENDENT JP ROM TESTS

Three supplied vertical tests reach a useful Area 2 entry.
Horizontal tests show why repeating terrain queries are not enough.

Original JP ROM footage with explicit setup edits; explanatory diagrams are not game footage. No complete route is claimed.

## 00:08.000–00:16.000: A VPU repeats queries, not the whole world

READING THE DIAGRAM / M, C AND D ARE DIFFERENT STORES

Here, VPU means +65536 in Y: actual height 67277 queries as 1741.
The floor still returns a local height. The real warp and top stay below.

D means stored graphics position; the floor-alignment matrix can draw Mario elsewhere. Broken axis, not to scale.

## 00:16.000–00:23.000: Start with a high crawler and a high box

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

Supply Mario at (-1950, 67277, -939), already crawling, speed 5.
Supply the Crazy Box at (-1989, 67277, -939), beside him; top phase 130.

Supplied-state original-ROM replay. High entry and Crazy Box delivery are not controller-reachable demonstrations.

## 00:23.000–00:30.000: The first lookup remembers the low pad

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

At Mario's initial X/Z, the high floor query aliases to Y 1741.
It refreshes the cached floor to the actual low pad at Y 768.

Right: JP source + Wafel within-update explanation. Left: recorded ROM end state.

## 00:30.000–00:37.000: The box moves M sideways while M stays high

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

The box interaction pushes movement X from -1950 to -1882.
Movement Y remains 67277. The cached floor still remembers 768.

Right: JP source + Wafel within-update explanation. Left: recorded ROM end state.

## 00:37.000–00:45.000: The high quarter-step stops before installing a floor

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

The proposed step finds roof 1280, but the no-ceiling value is 20000.
Raw Y 67277 + 160 reaches that value, so the old floor cache survives.

Right: JP source + Wafel within-update explanation. Left: recorded ROM end state.

## 00:45.000–00:52.000: Save high graphics, then snap movement low

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

The ground step copies high movement into stored graphics D.
Floor alignment sets M to cached Y 768; collision C then copies low M.

Right: JP source + Wafel within-update explanation. Left: recorded ROM end state.

## 00:52.000–00:59.000: The end of input 6 contains the 66509-unit split

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

M and C are (-1882, 768, -939). Stored graphics D is still at Y 67277.
Low C is near the real warp; high D is available for the next floor retry.

Native end-update coordinates are measured. Stock camera may not show the high stored pose; use the M/C/D diagram.

## 00:59.000–01:07.000: Next update: low contact, high retry

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

Low C reaches the warp and permits the real top collision to load again.
The low floor lookup fails; retrying from D aliases 67277 to 1741.

Right: JP source + Wafel within-update explanation. Left: recorded ROM end state.

## 01:07.000–01:15.000: Warp accepted; the spinning top is captured

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

Mario disappears for the warp. Floor owner and platform both name the top.
The new floor is local Y 1818.9613, with no +65536 added.

Native input 7 records disappearance + top floor/platform. Local top height is not shifted by 65536.

## 01:15.000–01:17.666: The top stays captured during the warp

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

The native recording advances while the disappearance action runs.
The right panel keeps the input 7 capture snapshot for reference.

Left: consecutive native inputs 7-26 at quarter speed. Right: input 7 snapshot, not current moving coordinates.

## 01:17.666–01:24.666: An inactive top is still remembered

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

At input 27, the top is inactive but Mario still retains it as platform.
This stored reference survives the disappearance before Area 2 loads.

Native input 27 telemetry records topActive=0 and retained platform. No exactly joined screenshot exists for that input.

## 01:24.666–01:32.533: Follow the warp into Area 2

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

The transition fades, then the stock camera reaches the pyramid interior.
First Area 2 position: (365.593, 5500, -1096.803), away from normal entry.

Left: consecutive native inputs 30-147 at half speed. Unmapped transition frame 27 is omitted. Right: first arrival.

## 01:32.533–01:39.533: Crawling reaches the useful interior side

1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST

The first Area 2 state is outside the usual elevator entry footprint.
Later native frames show Mario beside the upper interior walkway.

Coordinates describe first Area 2 input 30. Visible footage is later in the same independent supplied-state replay.

## 01:39.533–01:46.533: Replace the crawler with a ground butt slide

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

Supply the same high position and box, but ACT_BUTT_SLIDE at speed 20.
This is an established ground slide, not an airborne slide animation.

Supplied-state original-ROM replay. High entry and Crazy Box delivery are not controller-reachable demonstrations.

## 01:46.533–01:54.533: A ground bonk does not prevent this alignment

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

The stopped ground step changes the action to GROUND_BONK.
The common slide helper still aligns with the old floor after that change.

Right: JP source + Wafel within-update explanation. Left: recorded ROM end state.

## 01:54.533–02:01.533: The slide makes the same recorded split

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

Input 6 ends with M/C at 768 and D at 67277: a gap of 66509.
The end action is GROUND_BONK; that alone does not defeat the handoff.

Supplied-state original-ROM replay. High entry and Crazy Box delivery are not controller-reachable demonstrations.

## 02:01.533–02:08.533: The separate slide run captures the top too

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

Input 7 accepts the warp and records the spinning top as platform.
We keep following this slide replay through the actual Area 2 transition.

Native input 7 records disappearance + top floor/platform. Local top height is not shifted by 65536.

## 02:08.533–02:11.200: The top stays captured during the warp

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

The native recording advances while the disappearance action runs.
The right panel keeps the input 7 capture snapshot for reference.

Left: consecutive native inputs 7-26 at quarter speed. Right: input 7 snapshot, not current moving coordinates.

## 02:11.200–02:19.066: Follow the warp into Area 2

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

The transition fades, then the stock camera reaches the pyramid interior.
First Area 2 position: (365.593, 5500, -1096.803), away from normal entry.

Left: consecutive native inputs 30-147 at half speed. Unmapped transition frame 27 is omitted. Right: first arrival.

## 02:19.066–02:25.066: Butt sliding also reaches the useful arrival

2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY

The independently recorded slide reaches the same first Area 2 position.
High slide entry and box delivery were supplied, so route reachability stays open.

Coordinates describe first Area 2 input 30. Visible footage is later in the same independent supplied-state replay.

## 02:25.066–02:33.066: Walking supplies the slide speed locally

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

First supply walking on the low roof at Y 1280 and speed 20.
One native walking update initializes slide velocity, still on that low roof.

Preparation starts from a supplied low walking state. No climb or transport to the VPU is demonstrated.

## 02:33.066–02:42.066: A second cut moves the prepared walker high

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

Supply high synchronized M/C/D and the high box; retain native walking speeds.
Z selects CROUCH_SLIDE; its stopped step bonks and still aligns with the floor.

This is walking-to-crouch-slide after a supplied high cut. Ordinary walking does not itself make the split.

## 02:42.066–02:49.066: The walking-to-slide update produces the gap

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

M/C again end at 768 while D remains at 67277; the gap is 66509.
The native end action is GROUND_BONK, just as in the butt-slide replay.

Supplied-state original-ROM replay. High entry and Crazy Box delivery are not controller-reachable demonstrations.

## 02:49.066–02:56.066: The next update completes the same local handoff

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

The warp is accepted and the actual spinning top becomes Mario's platform.
The run continues without another setup write after the high cut.

Native input 7 records disappearance + top floor/platform. Local top height is not shifted by 65536.

## 02:56.066–02:58.733: The top stays captured during the warp

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

The native recording advances while the disappearance action runs.
The right panel keeps the input 7 capture snapshot for reference.

Left: consecutive native inputs 7-26 at quarter speed. Right: input 7 snapshot, not current moving coordinates.

## 02:58.733–03:06.600: Follow the warp into Area 2

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

The transition fades, then the stock camera reaches the pyramid interior.
First Area 2 position: (365.593, 5500, -1096.803), away from normal entry.

Left: consecutive native inputs 30-147 at half speed. Unmapped transition frame 27 is omitted. Right: first arrival.

## 03:06.600–03:13.600: Walking-to-slide reaches Area 2, conditionally

3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS

This third replay also reaches (365.593, 5500, -1096.803) at first arrival.
The missing route is how to obtain the supplied high pose and high box legally.

Coordinates describe first Area 2 input 30. Visible footage is later in the same independent supplied-state replay.

## 03:13.600–03:20.600: Now move X by 65536 instead of Y

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

The X-only tests start at (63586, 1741, -939), with the box beside Mario.
Terrain queries alias back, but Mario is far from the actual warp and top.

Horizontal PU means an X offset here. This finite comparison does not establish impossibility for every horizontal route.

## 03:20.600–03:27.600: Horizontal slide: no gap and no handoff

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

The ground slide leaves the floor: M = C = D at Y 1741 after input 6.
Its floor cache is 1280; raw X remains about 63659, far from the real warp.

Native X-only butt-slide replay: no accepted warp, no top capture, no Area 2 handoff in the observed run.

## 03:27.600–03:31.600: Watch the X-only slide continue

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

The remote state keeps evolving without entering the real warp.
An aliased terrain query has not returned Mario's actual X coordinate.

Consecutive native inputs 7-66 at half speed. Right panel explains the spatial separation, not exact changing Y.

## 03:31.600–03:38.600: Horizontal walking-to-slide fails here too

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

The prepared walker receives Z at the X-offset cut and becomes airborne.
Input 6 has no split: all three stores remain at Y 1741, with no top platform.

Native X-only walking-to-slide replay: no accepted warp, no top capture, no Area 2 handoff in the observed run.

## 03:38.600–03:42.600: Watch the X-only walking case continue

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

This separate remote run also stays away from the real warp and top.
The repeated floor coordinates are not a repeated set of interactive objects.

Consecutive native inputs 7-66 at half speed. Right panel is a location diagram, not an additional game camera.

## 03:42.600–03:50.600: Both offsets: a huge gap can still fail

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

At X +65536 and Y +65536, the slide makes the same 66509-unit Y split.
But low C is still at X 63654. Snapping Y does not move X back to the warp.

Supplied XY butt-slide test: M/C=(63654,768,-939), D=(63654,67277,-939) after input 6.

## 03:50.600–03:57.600: On the next update, the failed split disappears

4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS

The retry restores M/C/D to Y 67277; the new floor cache is 1280.
The real top is not captured, and no useful Area 2 arrival follows.

This XY failure separates a position gap from a completed handoff. Terrain aliasing alone is insufficient.

## 03:57.600–04:06.600: Local handoffs demonstrated; route still open

RESULT / CONDITIONAL SUCCESSES, NOT A COMPLETE NO-A ROUTE

All three vertical supplied tests complete the handoff in original JP ROM runs.
The horizontal comparisons fail; reaching the high setup without a new A remains open.

Footage and end states: original JP ROM. Within-update ordering and collision-face counts: source + Wafel evidence.

