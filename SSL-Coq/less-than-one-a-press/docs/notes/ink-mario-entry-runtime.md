# Late-push Mario predecessors: finite Wafel JP results

**Verdict (2026-11-14): the late-push branch can make the large position split,
but these tests do not complete the Ink handoff.** A box can move Mario away
from the spinning top after the update has cached its floor. A stopped ground
quarter then retains the slide and aligns to that cache. On the next update,
the real low warp pad becomes the fresh floor and alignment produces the large
gap. The closest case below accepts the warp but still finds the low pad, so
it does not retry at stored graphics XYZ or capture the top. It reaches the
ordinary Area 2 spawn, not a useful stale-platform displacement.

These experiments began with a supplied ground action and a pose on the
actual old top plane. They do **not** establish action entry or controller
reachability. A subsequent, separate experiment removed that action cut:
[native landing preparation](ink-supported-slide-preparation.md) starts from
supplied freefall, lands on the actual top, enters butt slide through the
native landing cancellation, and makes a similar gap. It also supplies the
box before landing in its later variant. That is now the closer verified
predecessor; its remaining failure is likewise the low floor query finding
the pad. Read that experiment's receipt and original-ROM validation for its
evidence level. Neither experiment delivers Mario or the actor by a complete
allowed controller history.

## Scope, versions, and preserved evidence

The proof checkout was `921e4d1954d79f3b4deb6958c88419a8f4bd5a28` on
`codex/ssl-pyramid-item-proof`. The sibling JP source checkout was
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with existing local changes;
the exact five relevant C-file hashes are recorded in the receipt. This is
Windows Wafel 0.8.5 with Python 3.9.13 and the existing JP native DLL, not an
original-ROM replay. Runtime SHA-256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The existing 2,548-input capture SHA-256 is
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The prefix uses supplied debug level select before level entry and is checked
A-off. Neutral input advances from the established four-pillar root to the
specified phase. No new random seeds are introduced.

Reproduction commands and exact menus are in
[`instrumentation/ink-mario-entry-search/README.md`](../../instrumentation/ink-mario-entry-search/README.md).
The durable [main receipt](ink-mario-entry-runtime-receipt.json) contains all
32 retained histories, setup-write ledgers, inputs, samples, event
projections, source/script hashes and raw output hashes. The separate
[contact refinement receipt](ink-mario-entry-contact-receipt.json) preserves
all 432 candidate summaries and five full histories. Ignored raw grids remain
under `build/ink-mario-entry-search/`. A write guard rejects non-controller
writes after each declared setup cut; native held-A and pressed-A flags are
checked after every tested update. The event field called `_placeholder` is
retained for exact replay comparison and is **not** interpreted as a native
quarter-step result. Source reasoning below supplies the quarter-step
interpretation; no hook result is invented.

Earlier entry, top-slide, walking-edge, crawl-predecessor, crawl-edge-entry,
slide-handoff and height-map studies were inspected. In particular, these
menus do not repeat the heavily searched fixed timer-113 landing seed. The
new question is a late actor push from actual upper-face geometry at the
timer-129 update, including the difference between the retained floor cache
and the platform re-query. An exploratory inverse-carry pilot was superseded
when execution showed that the push clears `gMarioPlatform`; its counts are
excluded below. Existing local work and build output were preserved.

## Why this branch differs from ordinary ledge departure

`mario_step.c:258` distinguishes an accepted quarter that leaves the floor
from a quarter rejected because no floor is found or ceiling clearance
fails. The latter can preserve the old position/floor cache. At
`mario_actions_moving.c:1359`, the common slide handler changes to the air
action on `GROUND_STEP_LEFT_GROUND`, but reaches `align_with_floor` for the
relevant wall/stop result. The final graphics copy performed by the ground
step precedes alignment's movement-Y snap. The retained `gfx.pos` is stored
graphics data, not a claim about where the rendered model appears.

The grabbable interaction at `interaction.c:1636` can push Mario after the
initial floor refresh and before his ground action executes. It uses the
real object hitbox and native wall resolution. After Mario's update,
`platform_displacement.c:22` queries the floor again and only installs a
platform when the floor is within its near-floor condition. Thus
`m.floor->object == top` does not imply `gMarioPlatform == top`: the former
can be the retained cache while the latter is already null. This exact
distinction appears in the trace below. The two successive updates must be
checked; merely observing a ground action ID or an old top floor pointer is
insufficient.

## Closest supplied-action predecessor

Before the top behavior runs with timer 129, the setup cut supplies
M = collision position = `gfx.pos` =
`(-1840, 1830.5751953125, -970)`, `ACT_BUTT_SLIDE`, action state/timer zero,
forward speed 20, facing yaw 49152 (signed -16384), horizontal/slide velocity
approximately `(-20, 0)` and vertical velocity zero. The tiny trigonometric
Z residue is retained exactly in the receipt. Y is computed from the actual
old upper-face query plane, rather than chosen from the old height-window
fixture. The Crazy Box in slot 49 is supplied at
`(-1839, 1830.5751953125, -970)` by XYZ writes only. Its existing native action,
velocity and other fields remain active; it is not a fixed or frozen box.

The setup does not write the floor pointer/height, ceiling, platform, top
phase, collision geometry or RNG. In fact, the initial stored floor cache is
still the prefix's unrelated static floor at Y=1024; the first native Mario
geometry update refreshes it. No Mario or actor writes follow the setup;
all subsequent controller inputs are neutral, with no held-A dependency.

In this table “after 129” means after the top behavior ran with timer 129;
its stored timer has advanced to 130. All positions are raw same-universe
coordinates. M and C agree at these sampled update boundaries.

| Boundary | M = C | Stored graphics D | Action / floor / platform |
| --- | --- | --- | --- |
| Before 129, global timer 2679 | (-1840, 1830.5751953125, -970) | Same | Supplied butt slide; old unrelated cache1024; platform null |
| After 129, global2680 | (-1946, 1857.76904296875, -970) | (-1946, 1830.5751953125, -970) | Butt slide; cache1857.76904296875, owner top61; platform null |
| After 130, global2681 | (-1946, 768, -970) | (-1946, 1857.76904296875, -970) | Butt-slide stop after ground bonk; static pad cache768; platform null |
| After 131, global2682 | (-1995, 768, -971) | Same | Disappeared, used warp64; static pad cache768; platform null |
| Area2 entry, global2705 | (0, 5500, 256) | Same | Ordinary spawn; platform null |

The producer gap is **1089.76904296875**. At that boundary the ceiling query
finds the top's underside at Y=1523; the top has six loaded surfaces. Box
collision list `[49]` appears on both 129 and 130; the warp collision list
`[64]` appears on 131. The native box Y values after 129, 130 and 131 are
1856.7747802734375, 1875.6376953125 and 1872.091796875, respectively. Top
centers at those boundaries are (-2007,1773.071044921875,-1023),
(-2047,1778.071044921875,-1023) and
(-2087,1783.071044921875,-1023). Full floor vertices, ceiling ownership,
object state, velocities, action fields and transition samples are in the
receipt.

**The first missing handoff condition is exact:** the next low-position
geometry update resolves walls before querying the floor (`mario.c:1314`),
and that floor query still succeeds on the real pad. The query therefore has no
reason to retry at high stored graphics XYZ. Warp acceptance alone is not
Ink installation. This is a meaningful predecessor to the split, but not a
successful installation or a controller-reachable route.

## Finite coverage and important contrasts

The actual upper-face queries filter seed geometry. Menus vary X/Z, facing,
nominal push proposal, action and speed; they do not prove global height or
reachability bounds. The source in `search.py` is the authoritative complete
menu, including float32 rounding. The direct one-box menu has nine target-X
values around the pad edge, 17 target-Z values from -1010 through -850, 64
angles, five nominal push values, crawl/butt-slide actions and speeds5/20.
The two-actor variants use six target-X values, the same Z/angle coverage,
their listed proposal menus, and butt slide at speed20. Accepted old/new
surface candidates must both have an upper-face query and satisfy the
recorded 78-unit comparison. This filter is a finite seed-construction
condition, not a reachability invariant.

| Menu | Candidate histories | Candidate updates | Immediate warp + top capture |
| --- | ---: | ---: | ---: |
| Crazy Box; crawl/butt-slide poses | 182,824 | 548,472 | 0 |
| Crazy Box, then proposed Bob-omb contact | 31,806 | 95,418 | 0 |
| Bob-omb, then proposed Crazy Box contact | 25,744 | 77,232 | 0 |
| Real spawned shell, then proposed Crazy Box contact | 25,584 | 76,752 | 0 |
| **Total broad menus** | **265,958** | **797,874** | **0** |
| Separate contact-timing refinement | 432 | 1,296 | 0 |

The shell menu supplies shell-box action4 at phase127, then allows two native
updates to spawn a real shell before the phase129 Mario/actor cut. Its setup
ledger records that extra write. The actor-order variants supply the two
actors' initial XYZ separately. “Push” in a recipe is a proposal parameter;
the game computes the actual displacement. In particular, the swapped
Bob-omb grid's geometric constant72 is not the native push radius. The native
Bob-omb has hitbox radius65; with Mario37 and padding-5 the combined radius
is97. This limits how one should interpret the proposal labels, but the
native finite executions and their explicit positions remain reproducible.

Eight histories per broad menu were followed to Area2 or a 32-update cap and
then replayed from independently rebuilt roots: **32 histories / 928 update
boundaries**, all exact retained-projection comparisons passed. Candidate
failure means no observed immediate top capture through the relevant third
update; only the selected histories were followed longer. Broad-grid full
samples record Crazy Box slot49 state, collision lists and initial writes;
they do not record every secondary actor field. The refinement adds the
Bob-omb's full relevant native state.

The refinement fixes the closest seed and varies first-box Y offsets
`[-124,-120,-115,-110,-105,-100,-80,0]`, second-actor X separations
`[1,10,39,60,68,70,71,71.5,90,92,94,95,96,96.5,97,98,100,104]`, and
second-actor Y offsets `[-120,-100,0]`. The second actor is Bob-omb slot39,
supplied at `(-1946-separation, 1857.76904296875+offset, -970)`.
Five retained histories replayed exactly on a new boot, totaling136 update
boundaries. This 432-case result supersedes the preliminary 192-case subset;
the subset is not counted a second time.

Lowering the first box by110 makes its first shove work while its next
vertical overlap fails, allowing the second grabbable interaction. With
second separation70 and Y offset0, the second push instead refreshes/accepts
the upper floor: after130 M is approximately
`(-1924.5177001953125,1929.3760986328125,-970.6025390625)`, so the desired low
gap fails. At separation90 and Y offset0, after130 M is
`(-1934.584228515625,768,-970.2470092773438)` while D.Y is1857.76904296875;
the gap survives, but after131 the floor is still static768 and the warp
still captures no top. Crossing the pad's raw X edge is insufficient: the
next geometry update's wall resolution moves this low position back to
X=-1995 before floor lookup. With the box only80 lower or unlowered, the original
box can continue to take the grabbable interaction instead. At offsets
-124/-120 the intended first shove fails. These are finite examples of
timing and query constraints, not a proof excluding all two-actor routes.

## Consequence and next experiment

This work narrows the next test to a specific obstacle: carry a natively
entered slide through the producer while placing the next collision query
outside the pad, without letting the proposed ground quarter accept a top
floor and erase the low-cache split, and after accounting for the next
update's wall resolution before its floor lookup. The native landing preparation is the
best starting point. The small second-push test shows why merely adding a
second object is insufficient; timing, vertical hitbox separation, pad
coverage and the top's 78-unit floor acceptance all matter together.

No new Coq proof is claimed by this runtime report. It supports a narrow
source distinction between an accepted ledge departure and a rejected
quarter after a late push, and demonstrates native execution of the latter
from the stated cuts. It does not close the global Mario-entry question,
actor delivery, the phase join, or an entire same-universe/VPU route. It
does not change the proof's clean-counterexample verdict to success.
