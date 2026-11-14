# Cloned shells: a usable conditional handoff, with entry and delivery still open

14 November 2026. **An initialized cloned shell remains mountable, and it
can participate in useful Ink displacement. The proposed high mount-now,
Bob-omb-next-update bridge still fails in the tested setups.** The stronger
alternative is the older immediate-Z / Crazy Box+Buddy / Crazy Box sequence
at initial airborne Y19900: substituting a native frozen shell preserves
that useful result. It still supplies Mario's initial airborne position,
the high shell preparation and later actor positions. No complete no-new-A
route has been demonstrated.

This investigation fetched `codex/ssl-pyramid-item-proof` from the proof
fork and began at its then-latest pushed revision
`162617b708b2244beca85af58b76ad5794e598cd`, newer than the requested
`08df00c605127a172d3a28049e31d6f50f7bff98` high-item notes. The requested
notes were unchanged between those revisions and were read first. Existing
local work was preserved. The decompile checkout is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; applicable stock JP code is
pinned at `9921382a68bb0c865e5e45eb594d9c64db59b1af`. Versions, source hashes,
ROM authentication, inputs and every setup edit accompany the linked packages.

## Three separate questions

| Question | Current answer | Evidence and first missing condition |
| --- | --- | --- |
| Does an actual initialized frozen shell still mount? | Yes in the checked low/high contacts. | Native spawn, fake pickup and drop/throw preserve its tangible 50×50 shell interaction. The isolation target-pointer retarget is disclosed. |
| Does high freefall mount leave grounded riding for next-update shove+Z? | No in the finite checked menu. | At high Y the stop sends Mario into ground knockback. Just below the default-ceiling boundary he instead enters shell fall. Neither executes the required grounded cancellation next update. |
| Can a clone participate in useful displacement by another sequence? | Yes, conditionally. | The Y19900 immediate-Z moving-top sequence works with the frozen shell and supplied Box/Buddy cuts. Native low mount plus supplied high rider relocation is also a positive control. |
| Can native pending pickup acquire such a shell without assigning the pickup pointer? | Yes, with one remaining shell-box activation grant. | A real expiring small box's slot is reused and initialized before pickup commits. Native carry, release and mount work on original JP. Actual roof-box attack/timing, high transport and joining the Ink phase remain open. |

All new controller sequences keep A released; none depends on held A.
The shared accepted prefixes use the documented debug level-selection
startup. The conditional tests are not uninterrupted permitted histories
from reset. The original-ROM checks run the hash-authenticated JP ROM in
Mupen64Plus, not on a physical console.

## What the shell does, in ordinary terms

A shell's rideable hitbox is separate from a solid floor. Its first normal
behavior update initializes that hitbox. Fake pickup then replaces its
running script with a stopped carry script, but does not erase the initialized
hitbox or interaction type. Global collision processing can still find it,
and Mario's interaction code can still mount it. No shell interaction type
was artificially assigned in these new tests.

The difficulty comes immediately afterward. Mario executes the riding-ground
handler during that same update. With a low queried floor and the default
no-ceiling height20000, proposed Y+160 reaching20000 stops the quarter-step.
The shell handler responds by stopping riding and requesting ground knockback.
Under those conditions the nominal boundary is19840, not20000 or25000.
Below it, if the queried floor is still over100 units down, the alternative
is leaving the ground and selecting shell fall. Merely keeping a ridden
pointer or looking like a rider is not retaining the needed ground action.

Pressing Z on the mount update can cancel directly into a slide, but mounting
has already stopped that update's interaction pass before GRABBABLE actors.
At the high fixed X/Z, the selected control reaches an ordinary warp instead
of useful displacement. The older Y19900 route solves a different local
problem: immediate cancellation puts Mario onto the actual moving top,
then supplied Box and Buddy pushes arrange the later productive crossing.

M means Movement, C means Collision, and G means **Stored Graphics**
(`gfx.pos`), not the render matrix or where the model is drawn. The
Y19900 alternative produces its final gap from actual movement Y about1830,
ending M/C.Y768 while G.Y remains1830.177978515625. Initial airborne height,
producer height and gap are different quantities.

## Compact evidence map

| Setup | Heights / coordinates | Handoff outcome | Evidence boundary |
| --- | --- | --- | --- |
| Real initialized shell, native fake pickup/release, above-contact | 25000,67277,90536; fixed high X/Z(-1950,-939) | Mounts; no useful next-update ground-rider bridge | [Isolation](ink-shell-clone-isolation.md):228 independent matched boundaries |
| Frozen/live shell, next-update or immediate Z, geometry/phase/speed variants | Three high points; 69 continuations and324 one-update checks | No high-FREEFALL useful captures; six separately relocated-rider controls succeed | [Bridge study](ink-cloned-shell-bridge.md):2610 matched boundaries; [JP selected controls](ink-cloned-shell-bridge-rom.md) |
| Lower delayed-Z frozen shell | Eight points from1741 to21777, including preceding float below19840 | Lower neighboring points select shell fall;19840/19900 select knockback | [Lower tests](ink-shell-lower-boundary.md); no continuous interval claim |
| Frozen shell + immediate Z, then Crazy Box/Buddy, then Box again | Initial FREEFALL(-1920,19900,-1210); final producer aboutY1830 | Top captured/retained; Area2(365.5927734375,5500,-1096.8026123046875) | Supplied air/actor history; [lower report](ink-shell-lower-boundary.md) and [JP pair](ink-shell-lower-boundary-rom.md) |
| Native expiring-box slot replacement, shell initialized one update before pickup | Actual low gameplay positions; one shell-box action4 grant | Native carry/drop/throw and remount; no high handoff tested | [Delivery source/search](ink-shell-delivery-source.md), [original-JP timing pair](ink-shell-delivery-rom.md) |

The lower package adds eleven continuations /378 independently matched
boundaries, including the old-sequence clone substitution and no-Buddy
control. Counts from different packages are not independent route probabilities.
The shell, Crazy Box, small box, ordinary black Bob-omb and Buddy all exist
in SSL Area1; their existence does not establish delivery to these coordinates.
Only the recorded heights and recipes are claimed. No new positive or negative
VPU interval, negative-VPU result, or global height limit follows.

## Legal delivery is narrower, but not completed

The new pending-pickup predecessor uses controller inputs to carry/drop a
small box, wait for its real expiry, and select it just before it disappears.
Its freed object slot becomes the next allocation. Granting the existing
roof shell box's spawning action one update before the pickup commit makes
the shell initialize first, then become held and frozen. No Mario position,
action or pickup pointer is edited in that delivery test. The matched late
control freezes the shell before initialization; it stays intangible with
interaction type0 and cannot mount after release.

This is a concrete reduction in supplied prerequisites, not a clean acquisition
route: the roof-box activation is still assigned. Its native attack-to-spawn
delay gives a timing target, but the current donor position is roughly1590
horizontal units from that box and940 units below. A useful next experiment
is carrying the expiring donor near a reachable real box attack and timing
that attack before pickup. High HOLP, Mario above the released shell,
delivered pushers and top-phase synchronization remain subsequent obligations.
A drop uses Mario's movement Y; a throw uses stored HOLP Y. Neither fact
creates a high HOLP or moves the real warp into another vertical universe.

For the successful Y19900 alternative, the first missing gameplay links
are the supplied initial air/shell pose and later actor deliveries. Buddy's
placement and the approximately198-unit second Box relocation are still
substantial conditions. Removing Buddy fails the selected recipe. Replacing
those grants, rather than treating an ordinary warp as success, is the next
task if that alternative is pursued.

## Formal and reporting boundary

[InkShellBridge](ink-shell-bridge-proof.md) records the generated-Clight
quarter-stop and shell-dispatch checkpoints, connected to a named Main
boundary. Its exact execution, storage and helper premises remain explicit.
It does not prove a complete reachable mount history, all-query geometry,
every lower-height branch or a global no-shell theorem. Runtime/source
explanations and those formal statements remain separate evidence levels.

These results refine the conditional route assessment: initialized shell
cloning is compatible with mounting and useful handoff, while the proposed
delayed high-rider bridge fails at a named step in the tested menus. A
continuous no-new-A route is still open. All45 subjective estimates remain
unchanged, including Rank1 **1–2%** and Ink Rank2 **<1%**; they are not measured
probabilities. The SSL atlas and private Pyramid Fine Print report carry the
same verdict. No unrelated project verdict is changed.

Validation completed: seven original-JP runs (three high controls, two Y19900 controls and two pickup-timing controls), the independently repeated Wafel packages, and the selected Coq audit. The new module/Main boundaries each report seven standard foundations; the unchanged backward boundary reports nine. All source/hole/link/integration checks pass. Native timer offsets, the delivery prefix subtype discrepancy and missing camera observations are preserved in the linked receipts; full-state equality is not claimed.
