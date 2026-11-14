# Refocusing entry on high coordinates with the top unloaded

14 November 2026. **The latest tests do not find a usable handoff, but they
remove the loaded top as the explanation for the tested failures.** The
preceding low-height landing/two-shove branch really did use the top to
establish the ground slide. The user's objection correctly identifies a
constraint of that branch. This follow-up focuses on high coordinates,
including Y25000 and positive-VPU Y67277, with unloaded top collision and
the fresh low floor cache checked in the native runtime.

The default fixture's second working integer window starts at **21778**,
not 21777; its recorded fractional threshold is21777.658203125. This is
fixture-specific. A descending airborne Mario at 21778 can cross back into
the loading range on the next update, so tests must record actual loading
rather than infer it forever from the initial height.

## Answer to the action-entry question

There is already a native high-air action conversion: shell contact and Z
in the same update enter the common crouch-slide handler without needing
the top collision. At the high supplied coordinates this can save high
stored graphics D and snap movement/collision M/C to floor768. But mounting
ends interaction processing before the later Crazy Box handler, so the
tested conversion stays over the pad and takes the ordinary warp. The
earlier high-position/boundary searches are credited in
[the prior high-action report](ink-high-action-entry.md), not rerun here.

The missing condition is therefore **the right action when the later box
interaction can actually run**. Having a ground action ID is insufficient
if its handler does not align to the floor, or if no handler executes.
Stored graphics means `gfx.pos`, not the rendered model's position.

Unloading the top does not make ordinary horizontal ground movement free.
With the fresh pad cache and no ceiling, the query's default ceiling height
is 20000. The high ground quarter hits that check and does not commit its
proposed X/Z. This stop is what lets the slide retain high graphics before
alignment; a separate actor shove still has to supply the sideways crossing.

| High-only proposal | What the game really supplies | First failed condition |
| --- | --- | --- |
| Immediate shell mount + Z | Native common slide, fresh floor768, high D/low M and C | The successful mount skips the box's later handler; tested next query remains on the pad. Ordinary warp, no useful displacement. |
| Mount first, cancel later | High BACKWARD_GROUND_KB, fresh floor768 and genuine later actor pushes | Knockback runs a ground step but never the needed alignment. Raw collision remains high. |
| Let that knockback recover before130 | Native IDLE while the top is still live | Its OFF_FLOOR guard selects FREEFALL before later slide/walk/Z controls. A subsequent Z gives airborne ground pound. |
| Ordinary high enemy damage | Native FORWARD_AIR_KB | Normal recovery needs a real landed result; its timer/animation does not independently produce a ground slide. |
| Mount while no floor exists | A retained RIDING_SHELL_GROUND ID without action execution | Geometry has already queued death. Returning to valid terrain does not clear that request; a later ordinary object warp cannot overwrite it while it remains pending. |

The supplied ground-slide controls at Y25000 and67277 still produce the
useful displaced Area 2 arrival `(365.5927734375,5500,-1096.8026123046875)`.
That validates the high-window handoff mechanism, not how Mario reaches
its starting action. Ordinary Area 2 `(0,5500,256)` is not counted as a
successful Ink result.

## New native evidence

[Delayed shell cancellation](ink-high-delayed-shell.md) checks 129 recipes
and 9,030 native updates:128 late-start recipes plus one early control.
Seven complete histories independently match 490 boundaries. No ground
action, animation progress, top timer, floor/cache or platform is supplied;
the initial airborne pose, shell preparation/placement and declared box
XYZ cuts remain explicit grants. No Mario fields are edited after the air
cut, and every input keeps A released.

An exact high near miss after phase130 has
M=C=D=`(-1946.240234375,25000,-1037.084716796875)`, real fresh cache768 and
BACKWARD_GROUND_KB. The box really pushed Mario, but no floor alignment
occurs. The same position/cache behavior is observed at raw Y67277.
The early phase97 control ends update32 in IDLE at top timer129, then
FREEFALL at130, while the top remains active. This removes late recovery
after the top's destruction as the explanation for that branch's failure.

[Other high entry paths](ink-high-other-entry.md) include eight native
FREEFALL/stock-Goomba comparisons at 21778,25000,32767 and67277, with 242
independently matched boundaries. Every retained boundary has zero top
surfaces. The21778 pair is deliberately limited to the first unloaded
update; the other six histories run40 updates each. Damage produces air
knockback, not a ground action. At VPU Y66167 (query alias631), a later
floor miss preserves the old airborne action ID while action dispatch
stops entirely. That is not execution of a slide helper.

The [complete earlier-interaction source review](ink-high-unloaded-entry-source.md)
checks all 26 table entries before the Koopa shell. No normal stock SSL
entry supplies the needed continuing X/Z shove before a successful mount.
The igloo barrier has that source pattern but is absent from stock SSL;
bully pushes terminate processing; ordinary enemy bounces change Y/vertical
velocity without the needed X/Z shove. Held/used-object and status fields
do not reorder grabbable handling ahead of mounting. This is a scoped
source-control-flow result, not a global theorem about every object history.

The [floorless shell control](ink-floorless-shell-entry.md) verifies a real
action-retention mechanism at both world edges, `(±8192,25000,0)`. Mounting
sets RIDING_SHELL_GROUND but no action executes while the floor remains null.
The death request is already operation 18/source 241. A later box-only cut
moves positive-edge Mario inward to X8124, and terrain is subsequently found,
but the queued death remains. Three 49-update histories independently match
147 boundaries through Mario-object clearing; a final castle arrival is not
claimed. No warp field is edited. This is a useful negative control, not an
Ink entry.

The source-mesh check also finds eligible static pad/roof triangles at all
185,761 integer points in X=[−2260,−1830], Z=[−1240,−810], a rectangle
covering the pad's 107-unit neighborhood plus truncation margins. Query
Y25000 and the alias1741 of67277 are above their height gates. This finite
mesh test is not a native `find_floor` replay or a global geometry theorem;
its script, coverage and zero-miss receipt are linked from the source note.

## Proof boundary and remaining target

The newly compiled `InkIdleOffFloorGuard.v` from commit 77ed751 directly
addresses the reached idle guard, with live OFF_FLOOR and completed
execution as premises. Its targeted build and selected audit were reported
in [the previous batch](ink-high-entry-followup.md); no proof code changes
or new Coq build are claimed in this high-only follow-up.

The existing `InkFailedRetryGuard.v` theorem
`ifg_pending_death_or_game_over_blocks_object_warp` proves a second precise
fact about the actual JP/US Clight function: a completed ordinary object-
warp request preserves memory when its live pending request is DEATH or
GAME_OVER. It does not by itself prove installation of that pending request
or every intervening frame. The actual geometry source queues death before
interactions after both floor lookups fail, and the native floor-miss
control checks that consequence without editing the request.

Mario's useful entry, actor delivery and their joined timing remain open.
The remaining high-coordinate target is a different native transition that
lets the floor-aligning ground helper run while the required box handling
is still available. A real high support or a different earlier history
would need its own evidence; neither is supplied by terrain aliasing alone.
These failures do not establish a global impossibility result. All 45
subjective route estimates stay unchanged, including Rank 1 **1–2%** and
Ink Rank 2 **<1%**. No new original-ROM replay, clean controller route or
video is claimed.

This pass starts at proof revision
`77ed7515d9ddce96fe00a030a26aae8663b590b0`, decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with earlier changes preserved.
Each linked receipt pins the JP runtime, source files, helpers, initial
cuts and controller inputs. Supplied initial high air and actual actor
coordinates remain prerequisites, not controller-reachable conclusions.
