# Replacing Buddy: Fly Guy contact, small-box delivery and the missing join

14 November 2026. **No real delivered replacement has yet completed the useful
Ink handoff. A manipulated Fly Guy does not directly perform the pink Buddy's
harmless sideways shove. It could still help Mario gain height earlier.**

This study starts at proof revision `1222ab0ee82b870ba5efe1a8afd7f3ea7e78b1bf`
on `codex/ssl-pyramid-item-proof`. The source review uses original JP code,
stock pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`, in decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Runtime records specify Wafel 0.8.5
JP and the authenticated original Japanese ROM. No new Coq file, proof build,
movie or global impossibility result is claimed.

## Why Buddy and whether Fly Guy can do his job

In the earlier three-actor witness, the shell and Z create Mario's ground slide.
The Crazy Box and Buddy then supply two separate sideways pushes. A later Box
position supplies another push before the low-cache snap. Buddy supplies the
second preserving push; he is not required by the Ink engine mechanism itself.
His placement and the other approach/delivery cuts were supplied.

Fly Guy manipulation is a different delivery mechanism from cloning and is
worth considering on its own. SSL Area 1 has one generic Fly Guy and two fire
variants. The western fire variant starts at `(-3400,1160,-1120)`, near enough
that the local target `(-1950,1741,-939)` lies within its normal home-steering
region. The home rule changes steering; it does not clamp the actor inside a
sphere or prove that manipulation beyond it is impossible. No claim that an
arbitrary high Y or VPU position is reachable follows from that fact.

The obstacle to direct Buddy substitution is contact behavior. A top hit causes
an airborne twirl; vulnerable side contact causes knockback; a fast ground slide
can attack the enemy without adding a neutral separation push. Invulnerability
can reject damage, but that also does not create a sideways shove. A frozen
clone keeps these collision rules. Fire projectiles are a separate burning-action
mechanism. See the [source review](ink-buddy-replacement-source.md#fly-guy-manipulation-and-the-ink-roles)
for actual branches, native positions, creator links and manipulation limits.

| Experiment | What is supplied or reached | Result and evidence |
| --- | --- | --- |
| Fly Guy replacing Buddy | Supplied initial FREEFALL/shell placement; game enters slide via shell/Z. No later Mario writes. Live ordinary/fire actors are placed at tested contacts. | 4,200 producer/acceptance screens; 3,000 registered contacts; zero intended top captures. Sixty-six full histories independently match 2,376 boundaries and give no useful arrival. Wafel JP only. |
| Small box replacing Buddy | Same native slide-entry sequence, then an exact or closer supplied small-box placement | Exact placement misses its smaller hitbox. Closer placement registers, but the Crazy Box and small box share GRABBABLE, so they do not supply two separate same-pass pushes. |
| Retuned shell plus one box | Supplied air entry and actor cuts, with finite geometry/timing menus | No useful handoff found. The full reports distinguish producer screens from selected long continuations; this is not exhaustive route coverage. |
| Real small-box acquisition, carry and throw | Controller-only after inherited debug level selection; no gameplay-state writes; A off throughout | Original JP: 1,149 inputs, 801 matched observations, zero mismatches. Mario reaches Y493.2757; actual release Y605.2346 and flight peak Y675.2346. This is not Ink delivery. |
| Higher small-box carry | Real pickup and alternating uphill stick/neutral input | Wafel Mario Y979.4579 on the southern perimeter, far from Ink. A steeper triangle breaks the positive-speed cycle. No proof excludes a different path around it. |
| Native shell-box approach | Controller-only 72-case waypoint/prefix menu | 32,695 updates, zero releases; three fresh histories match 1,500 boundaries. A failed finite search, not a shell-access impossibility theorem. |
| High downstream compatibility controls | Supplied crawl/butt-slide plus native small box or other compatible actor at H1741,25000,67277,90536 | Selected controls capture/retain the top and reach displaced Area 2. They explicitly grant the ground action under investigation and therefore do not solve entry or delivery. |

The Fly Guy menu varies initial airborne speed/yaw and actual contact offsets
for native slots 38, 44 and 45. The resulting contact speed, rather than the
supplied airborne speed, determines the attack branch. At measured slide speeds
26.82–28.45, Fly Guy is attacked and Mario follows the Box-only trajectory. Other
registered close contacts cause ground knockback. None adds Buddy's preserving
second push. Every screen runs through phase 131; the 66 selected outcome-family
histories continue for 35 updates. The initial useful Buddy control still works.

An ordinary Area 2 warp is insufficient. The success condition remains accepted
low warp, useful high stored-graphics floor retry, top capture and retention,
then the demonstrated displaced arrival near `(365.59277,5500,-1096.80261)`.
Stored graphics means `gfx.pos`, not the visibly drawn model or render matrix.

## What was actually reached, and what still fails

**Mario side:** native shell contact plus Z still supplies a conditional action
constructor from the supplied air setup. No complete allowed approach to a
productive high state is newly demonstrated. A real held-small-box pickup plus
supplied Mario travel cuts reaches the top, but immediately enters HOLD_BUTT_SLIDE;
the next Z input does not perform the intended walking/drop transition.

**Actor side:** the ordinary small box is genuinely acquired and transported
without A, with a selected original-ROM replay. It is not delivered to the Ink
region or required high coordinates. The larger uphill result is separate Wafel
evidence. The native box's raw XYZ stays at spawn while held, so Mario's carried
height is not the released actor's position. All reports distinguish those
quantities and actual HOLP.

**Joined timing:** no tested replacement combines actual delivery, native action
entry, the required successive displacements and the useful spawn. Supplied
ground-action successes are diagnostic controls only. Replacing the name of an
actor cannot replace its collision type, hitbox or callback schedule.

The closest verified delivery predecessor in this study is the real small-box
carry; its higher Wafel branch fails when neutral deceleration reaches zero on
a steep triangle and triggers held sliding. Its location is also wrong. The
closest useful handoff remains the earlier conditional shell/Box/Buddy recipe,
with its original delivery and approach grants intact.

The next focused Fly Guy experiment is an A-off lure of the western fire variant
from its native spawn toward a genuinely reached pillar/pyramid position, followed
by an actual bounce or burning ascent and landing. Record raw actor and Mario
coordinates, home, active flags, action, RNG, floor and all controller inputs.
Only after that would a later slide and grabbable push establish an Ink connection.
The upstream Fly Guy branch and a retimed two-GRABBABLE sequence on different
updates were not run here; the same-type restriction does not exclude the latter.

The full no-new-A route remains open. All 45 subjective atlas estimates remain
unchanged, including Rank 1 **1–2%** and Ink Rank 2 **<1%**; they are judgments,
not measured probabilities. Existing local proofs retain their previous scope.

## Reproduction records

- [Source audit and creator references](ink-buddy-replacement-source.md).
- [Native-entry replacement experiments](ink-buddy-replacement-handoff.md), with
  [scripts and archived histories](../../instrumentation/ink-buddy-replacement-handoff/README.md).
- [Actual small-box delivery](ink-buddy-replacement-delivery.md), with
  [controller inputs and original-JP record](../../instrumentation/ink-buddy-replacement-delivery/README.md).
- [Finite native shell approach](../../instrumentation/ink-buddy-replacement-shell/README.md).

These records preserve positive controls, failed cases, exact setup writes,
inputs, field observations and checker hashes. No ROM or runtime binary is
redistributed. Earlier Buddy acquisition, three-actor, clone and height studies
are credited in the linked reports rather than treated as new findings.
