# Why the retiming misses the fresh 768 cache

The stopped ground step is **not choosing the high floor in the representative
failure**. Its local lookup already returns 768. The initial Mario geometry
lookup has selected the raised top, and the stopped quarter does not replace
that cache. This corrects the earlier inference from the completed frame's
high floor. A useful fix must change the earlier query, not just the final shove.

Two new original-Japanese-ROM runs observed the actual queries and native
quarter returns: the successful supplied Buddy control and selected history 0
of the bounded retiming menu. This failure is the menu's **no-first-Bob-placement
comparison**, not a Bob-delivery witness. It starts shell/Z one update earlier,
then receives the recorded Crazy Box placements on updates 129 and 130. Both
retain ordinary actor callbacks and all older actors; neither changes Mario
after the initial airborne cut.

## The actual producer update

M means movement, C collision/object position, and G stored graphics `gfx.pos`,
not the visibly drawn pose. Both runs load the current top collision before
the initial query. Update-130 top position is
`(-2047, 1778.071044921875, -1023)`; their loaded top meshes are identical.

| Observation on update 130 | Successful Buddy control | Failed earlier shell/Z comparison |
| --- | --- | --- |
| Incoming M = C | (-2140.031982, 1830.177979, -1115.029175) | (-2140.712646, 1889.036987, -1102.085083) |
| Incoming platform | none | top, slot 61 |
| Initial geometry query after platform displacement | (-2140.031982, 1830.177979, -1115.029175) | (-2168.856445, 1889.036987, -1036.692871) |
| Initial query result committed to cache | static 768 | top 1933.492310 |
| Crazy Box push destination | (-2210.062256, 1830.177979, -1075.108887) | (-2104.462891, 1889.036987, -988.584473) |
| Push helper's local floor query | 1280; cache stays 768 | 768; cache stays 1933.492310 |
| First ground-quarter query | (-2209.176514, 1830.177979, -1072.188843), floor 1280 | (-2103.844238, 1889.036987, -986.374023), floor 768 |
| Ground-quarter ceiling / upper wall | 1523 / none | 1523 / none |
| Native quarter result / cache commit | 2, stop remaining quarters / none | 2, stop remaining quarters / none |
| Completed M = C | (-2210.062256, 768, -1075.108887) | (-2104.462891, 1933.492310, -988.584473) |
| Completed G | same X/Z as M, Y=1830.177979 | same X/Z as M, Y=1889.036987 |
| Following outcome | warp accepted, top captured, useful spawn | remains in Area 1 |

The recorded native query callers are `0x802538a0` (initial geometry),
`0x8024d550` (push validation) and `0x80255930` (ground quarter). The native
quarter epilogue at `0x80255b4c` returns 2 in both producer updates; no quarter
commits its local floor first. Ground-step entry/return hooks independently
show cache 768 throughout the positive and 1933.492310 throughout the negative.
The ceiling is the **dynamic underside of the spinning top** at 1523, not
the 20000 sentinel. Its returned surface belongs to top slot 61 and has
downward normal; it is not static pyramid geometry.

The positive captures and retains the top and reaches exact Area-2 movement
`(365.5927734375, 5500, -1096.8026123046875)`. The comparison remains in Area 1
through all 35 recorded post-entry boundaries. Initial airborne Y=19900 is
**not** producer Y: the first shell/Z update has already snapped movement
onto the top. Starting high does not ensure a low cache several updates later.

## Why the lookup order matters

Dynamic collision is rebuilt, platform displacement runs, then object
collisions and Mario's update run (`object_list_processor.c:644–662`).
`update_mario_geometry_inputs` commits `m->floor`/`floorHeight` before
interactions (`mario.c:1321–1329,1705–1707`). Plain-contact shove's `find_floor`
validates its proposed X/Z; it commits M.X/Z but **not** that local floor/cache
(`interaction.c:640–645`).

Early-stop paths in `perform_ground_quarter_step` preserve the incoming cache
(`mario_step.c:277–299`). In both recorded producer quarters, proposed Y is
more than 100 above the local floor and Y+160 exceeds ceiling 1523. Both stop.
Later floor alignment uses the surviving cache. Thus the positive can keep
768 while its later queries see 1280; the negative can keep the top while
its later queries see 768. The final cache alone cannot identify which lookup
first selected a floor.

The ceiling can be below Mario because `vec3f_find_ceil` searches from the
**local floor height plus 80**, not Mario's actual Y (`mario.c:547–550`).
The source therefore gives ceiling-query heights 1360 and 848 for these
local floors 1280 and 768; both can see the top underside at 1523 while
Mario is still at Y=1830.178 or 1889.037. The native trace directly records
the returned ceiling, owner and early stop; those two query-height numbers
are derived from the source helper, not a separate ceiling-call hook.

## What the top geometry says

The [companion geometry report](../../instrumentation/ink-floor768-diagnosis/geometry.md)
and read-only source evaluator use the actual freshly rebuilt
surface lists, binary32 arithmetic and signed-16 query casts. Its actual
query results match the native producer observations. The two histories
were reconstructed independently twice; the extra query probes were also
repeated. These are geometric diagnostics, not additional gameplay replays.

| Initial-query geometry | Successful control | Failed comparison |
| --- | --- | --- |
| Signed-16 query XYZ | (-2140,1830,-1115) | (-2168,1889,-1036) |
| Top plane height at that X/Z | 1909.11376953125 | 1933.4923095703125 |
| Eligibility threshold, top height minus 78 | 1831.11376953125 | 1855.4923095703125 |
| Top eligibility | rejected by 1.11376953125 | accepted, margin 33.5076904296875 |
| Static floor underneath | 768 | 1280 |
| Source-only height sensitivity | +1 Y still selects 768; +2 selects top | −33 Y still selects top; −34/−35 selects 1280 |

The lookup casts X/Y/Z to signed 16-bit values and accepts a candidate only
when cast Y is at least its plane height minus 78
(`surface_collision.c:459,524–526`). The positive misses the top's eligibility
threshold narrowly. The failed initial query instead sits above a different
static floor: **lowering its Y enough to reject the top gives 1280, not 768**.
Evaluating the failure's saved X/Z without its later platform displacement
still selects the top at 1920.5714111328125. Removing platform carry alone is
therefore not a demonstrated repair. These are point probes, not a continuous
working-height interval or a legal route.

## What needs to change next

Target the **initial geometry query of the producer update**, after any
platform displacement: it must lie over the desired static 768 floor while
the raised top is absent or ineligible, with a slide action that reaches the
stopped quarter and alignment. The subsequent shove must still place low
collision at the real warp and high G where the retry selects the top.

A shove later in that same update cannot directly refresh a wrong cache.
The next useful experiment changes the previous pusher placement/timing so
a deliverable actor leaves Mario at the right pre-query X/Z, Y, action and
platform state. A different top phase can also change the surface planes.
Neither lowering Y alone at the failed X/Z nor repeating only the final
shove solves the recorded failure. Any altered history still needs complete
capture, retention and displaced-spawn validation.

## Scope and reproducibility

Start revision: `510ab2d31a625676c1ef7b3769892efd5ac8ffc6`.
Applicable JP source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`;
local decompile: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
Original-JP ROM SHA-256:
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Ubuntu-24.04 ran the existing Mupen64Plus 2.5.9 interpreter/debugger pipeline.
The breakpoint addresses were checked against that ROM. There are no code
patches or floor/cache writes. Stored top-distance 19000 in the trace is
the engine's sentinel; actual loading is observed separately.

Both histories grant shell-box activation, low pickup preparation, one
fake-pickup `usedObj` retarget, high HOLP, initial high FREEFALL pose/velocity,
shell XYZ and the later actor XYZ cuts. The positive also supplies Buddy XYZ.
The original prior recipe and all exact edits are preserved in the receipts.
No A is down or newly pressed in the audited prefix/subsequent inputs, and
no Mario edit follows the initial airborne cut. This remains a conditional
handoff, not proof of legal actor delivery or a complete no-new-A route.

`instrumentation/ink-floor768-diagnosis/` preserves inputs, every state write,
459/483 native floor-return observations, raw logs and exact compiled sources
with hashes. `check.py` compares 25 positive and 35 negative saved Wafel
boundaries, retaining all 60 expected global-clock mismatches
(`native+2 = Wafel`) and finding no selected physical-field mismatch. Two
camera observations are unavailable during the positive's area transition;
the negative has 35 native post-entry boundaries versus 40 in its saved Wafel history;
this is not a full-memory comparison. It asserts producer-query roles,
local floors, actual ceiling, stop result 2, absent producer-quarter commit,
final cache, no-A audit and exact useful spawn. Archive checks and independent
geometry reruns pass. No new Coq theorem or global route exclusion is claimed.
