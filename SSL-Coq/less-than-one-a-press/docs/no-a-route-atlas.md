# No-A two-star route atlas

> Status snapshot: 2026-08-13.  Rankings are intentionally revisable as linked
> execution evidence or new counterexamples arrive.

## Purpose and scope

This document is the readable inventory of ways the project currently knows
to pursue the two target stars without a new A-button press.  It complements
the [open checklist](checklist.md): the checklist says what proof obligation is
next, while this atlas says what the gameplay idea is, what has already been
learned about it, and why it is or is not worth more search time.

### Authoring rule

Keep this atlas non-technical and centered on what has actually been proved or
disproved.  Every approach must have exactly three labeled sections—**In plain
language**, **What is already known**, and **What closes it**—and each section
must be one paragraph only.  Prefer ordinary gameplay language over theorem,
source-code, or memory-model terminology; include technical names only when
they are needed to identify evidence, and move exhaustive detail to the linked
checklist, proof narrative, or technical notes.

The two targets are:

- **Act 3, “Inside the Ancient Pyramid”** — source star index `2`;
- **Act 6, “Pyramid Puzzle”** — source star index `5`.

The theorem treats the two targets separately: a clean no-A collection of
**either** target would be a counterexample to the corresponding impossibility
claim.  “Getting the two stars” in this atlas therefore means covering the
route search for both targets; it does not silently require both collections to
occur in one playthrough.  A claimed route to both would need complete evidence
for each collection, whether they share a run or use separate scoped starts.
Source-provenance checks also show that the other normal SSL star sources do
not alias either target bit; a 100-coin star may be a movement tool, but it is
not a substitute target.

The current core scope begins at the declared default start in **SSL Area 1,
the exterior**, at node `0x0A`.  It does not require a proof of the castle route
to SSL.  A castle-origin glitch remains a separate, low-priority possibility.

“No A press” means no new A-button press edge in the scoped input history.  It
does not automatically forbid every action normally associated with A: for
example, an A-dependent action can sometimes continue when A was already held
at the boundary.  Every such use still needs an authenticated predecessor and
input history.

This is intended to cover every approach presently named in the active project
and its audited archives.  It is not a claim that nobody can invent a new SM64
mechanism.  The generic memory, external-call, collision-cache, and scheduler
escape classes near the end are where a genuinely new mechanism would
currently land.

## How to read the rankings

The **overall rank** combines three things: counterexample promise, how much of
the mechanism has been observed or checked, and how decisively the next result
would affect the main theorem.  The **family priority** compares only related
ideas.  These are research priorities, not numerical probabilities.
Lettered ranks such as `5A` place a tightly related subroute immediately after
the numbered route without obscuring the stable top-level ordering.

Likelihood labels mean:

- **High:** the best current lead, with a substantial conditional execution
  already observed; it is still not a clean counterexample.
- **Medium / medium-high:** the engine mechanism is concrete, but a major clean
  setup or execution bridge is absent.
- **Low-medium:** worth a bounded search or proof because it closes a real
  branch, but there is no strong clean witness.
- **Low / very low:** mainly a completeness obligation, or contradicted by
  significant source, geometry, timing, or arithmetic evidence.
- **Retired:** the proposal as stated has been disproved.  It can return only
  if a named premise of that disproof is broken by new evidence.

No single item below currently supplies a complete clean route to either
target.  A successful counterexample for one target needs all three layers:

1. reach or bypass an Area-2 gate with zero new A edges;
2. complete the relevant target-star continuation; and
3. connect the entire execution to the selected Clight program and retail ROM.

The detailed sections are organized as:

1. JP stale-platform and spawning-displacement routes;
2. Ink's Graphics-retry installations;
3. local-Object/nonlocal-State installations;
4. direct Area-2 gate crossings;
5. downstream Act-3 and Act-6 collection;
6. Goomba raising and PU transport;
7. Eyerok and Area-3 manipulation;
8. generic memory, collision, scheduler, and upstream escapes; and
9. a cross-family table of retired or corrected ideas.

## Bottom line

- **No clean retail counterexample is currently established.**
- **The leading route is JP-only:** install the spinning-top pointer from a
  different collision/query sample, retain the inactive unreused top slot, and
  consume its payload on the first Area-2 apply.
- **A real cached-floor collision/query split is now checked:** it is the
  Y-only change `(0,-50,0)`, so it proves that the two samples need not be
  equal but cannot install the top.
- **The immediate rank-1 priority is linking or eliminating useful split and
  escape mechanisms, not routing the remaining pyramid pillars.**
- **Ink is the leading concrete installer design:** its timer-131 Graphics
  retry works when the required three-view gap and top lifecycle are injected,
  but no clean execution creates that gap.
- **Act 6 has the strongest downstream evidence:** trigger/spawn and
  pickup/save-bit replays both exist conditionally, but still need joining.
- **Act 3 is the main downstream gap:** the upper and lower itineraries are
  specified and source geometry is checked, but neither has a cut-starting
  linked replay.

## At-a-glance ranking

| Overall | Family | Approach | Current counterexample promise |
|---:|---|---|---|
| 1 | JP stale-platform lineage | Different collision/query samples, then read the inactive unreused top payload | High relative to this project |
| 2 | Ink installation | Timer-131 non-null Graphics retry | Medium-high |
| 3 | State-first installation | Finite signed-16 nonlocal-State alias | Medium |
| 4 | JP stale-platform lineage | Move the warp/top or create a collision-preserving clone | Low-medium |
| 5 | State-first installation | Post-copy State-only writer in a later callback or descendant | Low-medium |
| 5A | State-first installation | Pre-collision cached-platform displacement creates the split | Low-medium as an effect; low as a stock origin |
| 6 | JP stale-platform lineage | Moving skipped-query interval | Low |
| 7 | Downstream collection | Join all five Act-6 triggers, spawn, pickup, and save-bit update | High once a gate installer exists |
| 8 | Downstream collection | Upper Act-3 100-coin/star-dance itinerary | Low-medium |
| 9 | Downstream collection | Lower Act-3 Amp/Grindel/elevator itinerary | Low-medium |
| 10 | Direct Area-2 gates | Held-A jump-kick or B rollout from the upper elevator shaft | Low |
| 11 | Direct Area-2 gates | Lower-aperture impulse, clip, or support switch | Low-medium |
| 12 | Ink installation | Negative quicksand depth plus stalled automatic dialog | Low |
| 13 | State-first installation | Raw-Object-only return or impulse writer | Low-medium |
| 13A | State-first installation | Terrain-dispatch or collision-prefix writer outside the platform phase | Low-medium as a proof branch |
| 13B | State-first installation | Interaction-stage writer or cached-floor snap composite | Low |
| 14 | Eyerok | Carry a stale Eyerok-hand address from Area 3 to Area 2 in JP | Low |
| 15 | Eyerok | Board and ride a raised hand into a lower Area-2 route | Low-medium as a primitive |
| 16 | Goomba / PU transport | Goomba raising, PU transport, and Spindel handoff | Very low as a full route |
| 17 | JP stale-platform lineage | Fresh same-slot replacement payload | Low-medium abstractly; low in the authenticated trace |
| 18A | JP stale-platform lineage | Canonical owner observed outside the modeled geometry | Low-medium |
| 18B | JP stale-platform lineage | Recognized owner at a noncanonical slot or ghost epoch | Low-medium |
| 18C | JP stale-platform lineage | Unclassified dynamic owner | Low-medium |
| 18D | JP stale-platform lineage | Surface-node/temporary mutation before the floor query | Low-medium |
| 18E | JP stale-platform lineage | Live same-owner payload mutation before apply | Low-medium |
| 19 | State-first installation | Skipped, wrong-index, or redirected State-to-Object copy | Low |
| 20 | Direct Area-2 gates | Amp, Grindel, elevator, Tweester, shell, or other object impulse | Low-medium |
| 20A | Direct Area-2 gates | Reload, nonzero warp destination, or same-position support-selection change | Low-medium as a coverage branch |
| 21 | Ink installation | Mario behavior flag plus a large graphical Y offset | Low |
| 22 | Ink installation | Non-stock Graphics anchor or spawned anchor actor | Low |
| 23 | Eyerok | Second-hand ceiling to the Area-2 Y=1280 tier | Low |
| 24 | Eyerok | Update-11 wake-sandwich Pedro installer | Low |
| 25 | Direct Area-2 gates | Direct Float32 pole exit or pole avoidance | Very low on current evidence |
| 26 | Ink / wall interaction | Shell visual offset plus wall/floor schedule | Very low alone |
| 27 | Downstream collection | Negative-depth transport to a fresh or older tangible star | Low |
| 28 | JP stale-platform lineage | Classic Spindel replacement-object spawning displacement | Low |
| 29 | Eyerok | Attack and reboard a rising hand | Very low |
| 30 | Eyerok | Sleeping-hand Pedro speed bootstrap | Very low |
| 31 | Eyerok | Seams, moving boundaries, or partial updates | Very low |
| 32 | Memory and control escapes | Alias, external write, false cache, hitbox mutation, DMA, or forged state | Very low as a known gameplay route; proof-critical |
| 33 | Upstream scope extension | Castle-to-SSL glitch or retained inbound pointer | Very low and intentionally deferred |

## Family 1 — JP stale-platform and spawning-displacement routes

This family exploits the original-JP behavior that can retain a raw
`gMarioPlatform` pointer across a spawn or area transition.  US clears that
pointer during spawn, so the same route is not presently a US mechanism.  The
important distinction is between **installing** a useful pointer in Area 1 and
the later Area-2 code **using** the bytes found at that address.

Technical background: [route exhaustiveness](notes/route-exhaustiveness.md),
[installer temporal closure](notes/installer-temporal-closure.md),
[JP lifecycle trace](notes/jp-lifecycle-trace.md), and the
[local-Object/nonlocal-State matrix](notes/local-object-nonlocal-state-gap-matrix.md).

### Different collision/query samples, then the inactive top payload

**Overall rank: 1. Family priority: 1. Likelihood: high relative to the other
leads, but not yet a clean counterexample.**

**In plain language.** Mario's raw collision Object touches the upper warp,
but a later floor query looks at a different position and remembers the
spinning pyramid top as Mario's platform.  The top explodes and its object slot
becomes inactive, yet JP keeps the old address.  On the first pyramid update,
the game reads the still-resident top bytes and applies their three-dimensional
platform displacement to MarioState while the raw Mario Object remains local.

**What is already known.** This remains the strongest lead because an injected
JP run demonstrates the entire useful effect once the setup is granted: it
captures the spinning top, frees it without reusing its slot, applies the old
three-dimensional movement data after the area change, reaches all five Act-6
triggers, and separately collects the Act-6 star with no A press; however, that
test also forces the pillar counter to four, so it does not supply the missing
clean setup or a complete Act-3 route.  Controller-only play after a level-
select entry has activated the two eastern pillars with zero A presses, while
two longer attempts failed at the central pyramid before reaching the western
pillars; these runs show that pillar activation is possible but say nothing
useful about the required position split.  The project has now proved that a
collision/query split can genuinely occur in the ordinary warp sequence:
Mario can touch the warp at `(-2048,818,-1024)` and later query at
`(-2048,768,-1024)`, exactly 50 units lower, with matching US and JP floor
evidence and no A-input assumption in the construction.  It has also disproved
that particular split as the top installer: the change is vertical and
downward, while the top requires more than 459 units of upward separation, so
the modeled final query finds no platform.  Nearby ordinary explanations have
been narrowed as well: the audited scheduler contains no concrete moving
query-skip, an accepted warp stops later interaction handlers, the recognized
surface owner comes from the object being updated, no direct one-step call
passes Mario into the audited raw-position writers, and the checked
particle/debug copies write into child objects rather than Mario.  These
results do not yet rule out a useful split produced through an indirect
callback, an alias, an external write, a mistaken current-object identity, an
unmodeled live surface owner, or object-slot lifetime/reuse behavior; nor does
the current proof wrapper connect all of its modeled events to one real game
execution, so rank 1 is neither proved nor disproved.

**What closes it.** First derive a *useful* collision/query split from the
declared clean linked run—or eliminate the remaining alias, callback,
scheduler, surface-owner, and lifecycle escapes—and execute the live floor
lookup.  The five-field ordinary no-go now names the required bridge groups:
selection/collision sampling; alias/external framing and final receiver;
callback dispatch; same-frame scheduling; and live surface owner/list/query
refinement.  The no-go remains contradictory with any separately supplied
lifecycle fate, but a linked proof must still establish the real chronology;
the inactive-unreused payload survives even when reuse is excluded.  Linking the
new Y=`818` to Y=`768` witness would validate a real
downward split, but cannot by itself capture the top; it is not a reason to
route the remaining pillars.  Only after a useful upward or horizontal split,
alternative owner, relocation, or clone survives should the project prioritize
the remaining detectors and stock spin/explosion lifecycle.  Preserve the
exact object-pool block, epoch, and payload bytes through
unload and transition; refine the first Area-2 apply; join the Act-6
trigger/spawn and pickup/save-bit receipts into one linked suffix; and
separately add an Act-3 continuation if claiming access to both targets.  The
two-pillar prefix and the conditional timer-131 lifecycle are independent
witnesses; they do not establish this coupling.

### Move the warp/top, or create a collision-preserving clone

**Overall rank: 4. Family priority: 2. Likelihood: low-medium.**

**In plain language.** Instead of separating Mario's samples, physically put a
standable moving-object floor inside the warp.  Mario could then touch the warp
and save a platform pointer at the same place.  A clone could serve the same
purpose if it preserved the original collision and movement behavior.

**What is already known.** The fixed stock top and warp are not co-located.
The other modeled stock surface owners are horizontally disjoint, top motion
stays in a bounded envelope in the finite source-shaped model, and ordinary
pose-copy helpers do not copy
behavior or collision identity, and the top callbacks do not directly clone
the top.  A deliberately permissive archived clone model shows that the engine
effect would be sufficient if a real clone existed.

**What closes it.** Complete the live spawn/behavior graph, all collision-data
writer receivers, allocator reset and epoch proofs, and the dynamic-surface
owner map.  The branch closes either with a concrete clean relocation/clone or
with an exhaustive proof that every reachable owner remains outside the joint
warp/platform geometry.

### Moving skipped-query interval

**Overall rank: 6. Family priority: 3. Likelihood: low.**

**In plain language.** Save a useful platform somewhere else, then move Mario
into the warp during a frame that does not recompute the platform pointer.

**What is already known.** The modeled frozen carries preserve both the
pointer and Mario's raw Object position, so they cannot do this.  Bilateral
generated-source receipts now find no concrete moving skip in the audited
normal, basic-update, and delayed-object-warp shapes: coordinate-moving area
and instant-warp paths precede a full same-frame update/query, while the two
query-free delayed-warp frames are reached from source that installs a null
callback, and their checked bodies contain no direct Mario-view or platform
syntax.  This is a source-shaped reduction, not
whole-scheduler linked exhaustiveness.

**What closes it.** Link the indirect callback targets, external/non-alias
frames, play-mode reachability, and null-`gMarioObject` lifecycle to the actual
run.  A survivor must then exhibit a scheduler shape outside the audited cases
or a concrete alias, external, or lifecycle effect.

### Fresh same-slot replacement payload

**Overall rank: 17. Family priority: 4. Likelihood: low-medium abstractly, low
for the authenticated timer-131 trace.**

**In plain language.** Save an object's address, free the object, allocate a
different object in the same slot, then let the stale pointer interpret the new
object's movement fields as a platform displacement.

**What is already known.** The project has an executable abstract epoch
`4 -> 5` reuse countermodel and a source-shaped replacement payload capable of
a large three-dimensional displacement.  It also separates the query owner
from the apply-time payload owner.  However, the authenticated JP top slot is
not reused before the observed first apply, so this is not the fate seen in the
best trace.

**What closes it.** Produce one coupled linked chronology proving the exact
free-list pushes and pops, same-slot allocation, replacement type, payload
bytes, query selection, and apply timing.  An independent schedule witness and
an independent reuse witness are not enough.

### Canonical owner observed outside the modeled geometry

**Overall rank: 18A. Family priority: 5. Likelihood: low-medium.**

**In plain language.** The floor really belongs to a familiar stock object,
but that object's live transform places its collision somewhere the finite
geometry model did not allow.

**What is already known.** Canonical observations for the fifteen modeled
Area-1 owner families do not supply a platform at the fixed upper-warp sample.
That is a strong conditional exclusion, not a live transform/list theorem.

**What closes it.** Reconstruct each reachable owner's live position, angles,
scale, collision matrix, and surface insertion at the query frame; otherwise
return the first owner whose observed transform violates the canonical map.

### Recognized owner at a noncanonical slot or ghost epoch

**Overall rank: 18B. Family priority: 6. Likelihood: low-medium.**

**In plain language.** The behavior name looks familiar, but the pointer names
the wrong pool slot, an old lifetime of that slot, or a stale “ghost” copy.

**What is already known.** The lineage classifier keeps this separate from a
fresh replacement at apply time.  Official JP initial memory provides the
object-pool block and writable range, but no current theorem reconstructs live
slot allocation epochs or proves every owner pointer is the slot base.

**What closes it.** Connect every `Surface.object` address to an aligned live
pool slot, prove allocation-epoch monotonicity and behavior identity, and frame
unload/reuse from insertion through query.

### Unclassified dynamic owner

**Overall rank: 18C. Family priority: 7. Likelihood: low-medium.**

**In plain language.** A reachable actor omitted from the stock owner list
loads a floor at the warp and supplies the platform pointer.

**What is already known.** The finite source-bounded model covers the named
stock candidates and proves their geometry exclusion.  Generic spawn helpers,
transitive behavior scripts, clones, corruption, and externally produced
owners are not a live closed-world theorem.  No concrete missing actor is
known.

**What closes it.** Complete the Area-1 transitive spawn/behavior/collision-data
graph and dynamic-list membership proof, or exhibit the exact new owner and
its clean creation path.

### Surface-node or temporary mutation before the query

**Overall rank: 18D. Family priority: 8. Likelihood: low-medium.**

**In plain language.** The loader starts with the right object and surface,
but a reassignment, list corruption, stale node, or alias changes what the
floor query later sees.

**What is already known.** Bilateral AST receipts tie `gCurrentObject` to the
`Surface.object` store and then to a dynamic `add_surface(...,1)` call using the
same syntactic surface receiver; static loaders use flag `0`.  They do not
prove call reachability, live list integrity, node lifetime, or the eventual
query result.

**What closes it.** Execute allocation, initialization, insertion, list
traversal, clear/removal, and `find_floor` with receiver/alias/external frames.

### Live same-owner payload mutation before apply

**Overall rank: 18E. Family priority: 9. Likelihood: low-medium.**

**In plain language.** The pointer remains valid and names the same object, but
that object's position, angles, velocity, or transform changes between the
floor query and the later platform apply.

**What is already known.** The payload-fate classification deliberately keeps
this distinct from slot reuse.  No theorem yet freezes all fields read by the
apply, even when owner identity and epoch stay fixed.

**What closes it.** Prove a per-field last-writer and memory-frame theorem from
query to apply, or return the exact mutating step and resulting binary32
displacement.

### Classic Spindel replacement-object route

**Overall rank: 28. Family priority: 10. Likelihood: low.**

**In plain language.** Reuse the stale Area-1 slot specifically as Spindel,
then use Spindel's first update as the spawning-displacement payload.

**What is already known.** The JP retention bug is real, but the corrected
allocation depth is `63`, not the old “60” figure.  The modeled first Spindel
displacement moves the upper-entry sample away from Act 3, and the nearby
elevator is not yet in a helpful state.  The inactive old-top payload is both
better authenticated and currently more promising.

**What closes it.** Construct a clean seed at the exact free-list depth and a
binary32 continuation to a target, or finish the finite first-update platform
census and rule out every Spindel placement.

**Version verdict.** The US spawn clear blocks the retained-inbound-pointer
subbranches at that boundary.  It does not exclude a later US recapture,
relocated owner, clone, or independently corrupted pointer.  The final proof
still needs to execute and frame the clear in linked US memory; source syntax
alone is not the memory theorem.

## Family 2 — Ink's Graphics-retry installation attempts

Ink's core observation is that SM64 can consult three different views of
Mario's position in one update: raw Object, MarioState, and displayed Graphics.
If Object touches the warp, State's first floor query fails, and Graphics is on
the spinning top, the graphical retry can install the exact JP stale pointer
needed by Family 1.

Technical background: [Ink fallback](notes/ink-fallback.md),
[timer-131 surface](notes/timer131-surface.md), and the
[clean-JP Graphics-gap source audit](notes/clean-jp-graphics-gap-source-audit.md).

### Timer-131 non-null Graphics retry

**Overall rank: 2. Family priority: 1. Likelihood: medium-high.**

**In plain language.** Leave Mario's collision Object at the upper warp, make
MarioState's first floor lookup miss, but leave the rendered Mario position on
the raised spinning top.  The game retries the floor lookup at the rendered
position and remembers the top.

**What is already known.** Source order supports the three-view sequence.  The
correct timer-131 midpoint is an exact interior point on the live modeled top;
the older home-position point is rejected.  At the warp center the route needs
a Graphics/Object Y gap of `1010` (at least `960` in the route envelope).
Injecting those three views, together with an injected pillar counter `4` that
forces the top's spin/explosion lifecycle, reaches the conditional JP lifecycle
and Act-6 receipt.  A retry that is also null is fatal under the abstract
latch, and the new first-NULL capstone proves that any route projected into
that scheduler model must therefore succeed on the Graphics retry rather than
continue after two misses.  A stricter generated-code census also reduces the
possible direct Graphics-Y assignment bodies from `33` receiver-neutral
`pos[1]` sites to exactly `11` real `gfx.pos[1]` writers.  Those now split
exactly into seven Mario initialization/action paths and four helpers with a
generic Object receiver; the latter four are the focused receiver-identity and
call-path residuals.

**What closes it.** Produce the large three-view gap from clean execution;
prove the first null lookup, live top-owned retry, exact return/snap/copy order,
post-copy preservation, clean pillar-counter progression and explosion,
unload/final-query selection, and the remaining Act-3 suffix.  The double-NULL
case now needs only a live trace-to-latch projection, not new fatal-latch
arithmetic; writer work should focus on receiver identity and call paths for
the eleven direct Graphics-Y bodies.  Act 6 separately needs the existing
trigger/spawn and pickup/save-bit receipts joined in one linked suffix.

### Negative quicksand depth plus stalled automatic dialog

**Overall rank: 12. Family priority: 2. Likelihood: low.**

**In plain language.** Make `quicksandDepth` negative, then stall in a dialog
state that repeatedly subtracts that negative value from Graphics Y without
reanchoring it.  Hundreds of iterations can build the large Ink gap.

**What is already known.** Exact binary32 models reach more than the required
gap after a finite number of calls.  The only normal negative-depth source
found so far comes from long-jump landing timers and therefore inherits an A
edge.  Ordinary sign/NPC dialogs reanchor, no direct Area-1 macro/script door
root supplies the desired automatic dialog, and the known fresh-star timing
does not align with the needed vertical overlap.

**What closes it.** Find a no-A negative-depth producer or prove none exists;
find a reachable non-reanchoring dialog; execute the repeated sink and its
X/Z transport; then prove no intermediate reset or reanchor destroys the gap.
See the [negative-quicksand/dialog audit](notes/negative-quicksand-unreanchored-dialog.md)
for the producer and reanchoring split.

### Mario behavior flag plus a large graphical Y offset

**Overall rank: 21. Family priority: 3. Likelihood: low.**

**In plain language.** Give Mario the generic object flag that copies raw
position to graphics with an added `oGraphYOffset`, and make that offset huge.
This could create the entire Ink gap at once.

**What is already known.** Object allocation clears the relevant fields.
Mario's normal behavior sets a different flag bit, and no clean direct writer
of the dangerous flag/offset pair has been found.  An over-permissive memory
model can realize it, so it remains an alias or lifecycle hole rather than a
normal gameplay lead.

**What closes it.** Prove the live Mario slot, initialization, behavior-tail
execution, and every direct/indirect/alias/external mutation of both fields.

### Non-stock Graphics anchor or spawned anchor actor

**Overall rank: 22. Family priority: 4. Likelihood: low.**

**In plain language.** Some actors, such as Chuckya- or King-Bob-omb-style
anchors, can force Mario's rendered position to the actor's position.  A far
away actor could manufacture a huge graphical gap.

**What is already known.** The writer family is real, but those actors are not
stock SSL Area-1 roots.  Loading an actor model is not the same as spawning
that actor.  Post-copy particle/debug spawn paths and transitive descendants
are now explicit residuals, but no such anchor has been reached.

**What closes it.** Complete the transitive behavior/spawn graph, same-frame
list traversal, interpreter calls, allocation success, and receiver identity;
then either produce a clean anchor actor or prove every descendant harmless.

### Shell visual offset plus wall/floor scheduling

**Overall rank: 26. Family priority: 5. Likelihood: very low alone.**

**In plain language.** Use the shell's small visual lift and a wall-selected or
cached floor to try to preserve and enlarge a Graphics gap.

**What is already known.** The stock shell offsets are around `+42/+45`, far
below `960`, and the normal behavior reanchors instead of accumulating them
forever.  Under well-formed non-aliasing state, a successful shell interaction
has no immediate Mario-coordinate write.  A failed contact pushes State X/Z
toward the stock radius-`89` boundary, but no total live-wall bound is proved.
Ground and air shell paths reset quicksand depth.  These effects have not
supplied the missing large gap.

**What closes it.** Linked live-range writer coverage can turn this into a
clean impossibility result.  A counterexample would need an unusual schedule,
alias, or another mechanism that first creates most of the gap.

**Related retired ideas.** Ordinary platform or PU motion by itself preserves
an already existing Object/Graphics gap; it does not create Ink's gap from a
synchronized start.  Turning-animation metadata also preserves the position
views.  Only a real animation-buffer/DMA alias would reopen that branch.

## Family 3 — Local-Object/nonlocal-State (“State-first”) installers

These approaches leave raw Mario Object at the Area-1 warp while moving or
interpreting MarioState somewhere else.  The local Object caches the warp
interaction; the nonlocal State selects the top or another platform; later
copy/query code installs the pointer.

Technical background: [nonlocal endpoints](notes/area1-nonlocal-endpoints.md),
[post-copy mechanism matrix](notes/local-object-nonlocal-state-gap-matrix.md),
and [platform alias/external closure](notes/platform-alias-external-closure.md).

### Finite signed-16 nonlocal-State alias

**Overall rank: 3. Family priority: 1. Likelihood: medium.**

**In plain language.** Put MarioState one 65,536-unit period away while raw
Object stays at the warp.  The terrain code narrows the large coordinate to a
signed 16-bit value, wrapping it back to the timer-131 top.

**What is already known.** The exact vector
`(-1862,67314,-902) -> (-1862,1778,-902)` is checked, and an injected JP run
selects the top, captures it, applies the stale payload, and reaches the upper
trigger.  NaN, infinity, and out-of-signed-32 conversions do not provide a
usable continuation under the modeled retail exception behavior.  The price
is a still-unexplained `66546`-unit State/Object split.  This probe shares the
timer-131 harness's separate write of the top pillar counter to `4`, so it also
does not derive the required spin/explosion lifecycle from clean play.

**What closes it.** Find and execute a clean three-dimensional State-only
writer, prove the live casts/wall/floor/list owner, preserve the split through
the cached warp collision and first geometry query, then faithfully execute
the floor snap, synchronizing State-to-Object copy, and top-capturing final
query before connecting the destination trace.  Otherwise prove all reachable
State writers stay in the local cast domain.  A successful route must also
derive the pillar-counter, spin, explosion, and deactivation chronology rather
than inherit it from the injected harness.

### Post-copy State-only writer in a callback or spawned descendant

**Overall rank: 5. Family priority: 2. Likelihood: low-medium.**

**In plain language.** Mario's own update first copies State to Object.  A
later object then changes only State, leaving Object behind for the next
frame's warp collision.

**What is already known.** Any supplied faithful-copy tail that ends split
must contain an actual State-only, Object-only, or joint value-changing edge.
The exact post-PLAYER list suffix is `[5;4;2;6;8;12;-1]`.  Source receipts expose
Mario's post-copy `spawn_particle` source path and candidate family, the later
debug-spawn callback, possible later
PLAYER nodes, 18 list-8 particle behaviors, and an Area-1 breakable-box path to
a list-12 triangle.  Fixed traversal, unload, top-level update, and final-query
bodies have no recognized direct State-position or raw-Object XYZ store.  No
reachable descendant that writes Mario's coordinates has been found.  The
exterior palm/tree push runs before PLAYER and a correct Mario copy erases it.

**What closes it.** Execute the behavior lists and interpreter; close the
transitive spawn/callback graph, same-frame visitation, copy receiver/index,
alias/external frames, unload/reuse, post-query debug call, and next-frame
warp/instant-warp interval.  The first real late writer would be a serious
counterexample lead; complete framing would rule out the family.

### Pre-collision cached-platform displacement creates the split

**Overall rank: 5A. Family priority: 3. Likelihood: low-medium as an effect,
low as an ordinary stock origin.**

**In plain language.** Begin a frame with a useful moving-platform pointer.
The platform update changes MarioState before collision while leaving raw
Object at the local warp sample.

**What is already known.** This is the only identified stock three-dimensional
State-only writer in the exact pre-collision window, and the selected US/JP
bodies contain the expected query/apply source shape.  The finite stock
pre-apply provenance model says the pointer is null at the upper-warp sample,
including its modeled active and frozen carries.  That result still consumes a
supplied projection rather than deriving the live pointer history.  Platform
apply also cannot create Ink's Object/Graphics gap from synchronized views.

**What closes it.** Derive the terrain, platform, and collision phases from the
same nonempty linked run; prove the non-null load, owner, payload, true apply
branch, endpoint receivers, and later collision sample; or construct one of the
explicit pointer-provenance escapes.

### Raw-Object-only return or impulse writer

**Overall rank: 13. Family priority: 4. Likelihood: low-medium.**

**In plain language.** Instead of moving State, change only Mario's raw
collision Object after synchronization.  State remains at the remote sample
while Object is returned to the warp.

**What is already known.** Abstract countermodels show that call ordering alone
cannot exclude this.  The Goomba work names pre-collision raw-return, lifecycle,
and entry writer classes, but no stock SSL Area-1 writer has been shown to hit
the right endpoint at the right time.

**What closes it.** Prove an exact first-divergence/last-writer chronology with
receiver, component, and timing data, or frame every reachable Object writer
through the collision sample.

### Terrain-dispatch or collision-prefix writer outside the platform phase

**Overall rank: 13A. Family priority: 5. Likelihood: low-medium as a proof
branch; no concrete gameplay writer is known.**

**In plain language.** A store in terrain handling or the collision prefix
moves State or Object before the warp test, but falls outside the modeled
ordinary/platform stages.

**What is already known.** Abstract framed-stage theorems make terrain,
platform, and collision refinement failures explicit instead of silently
assuming them away.  Source-level direct-writer censuses are narrow and do not
prove live receivers, indirect callbacks, or external frames.  No specific
extra stock writer has been identified.

**What closes it.** Instantiate each stage with actual linked steps and
protected loads, prove every direct and indirect receiver, and either frame all
stores or return the first concrete State/Object-changing step.

### Interaction-stage writer or cached-floor snap composite

**Overall rank: 13B. Family priority: 6. Likelihood: low.**

**In plain language.** Let geometry cache the warp, then have a later object
interaction push/bounce State or let `ACT_DISAPPEARED` snap Mario to an older
floor before the copy and final query.

**What is already known.** These source mechanisms are real.  The bilateral
source receipt now pins `interact_warp` at table index `4`; the accepted
nonfading branch returns the result of
`set_mario_action(ACT_DISAPPEARED)`, that call returns `1`, and the loop breaks
on a nonzero handler result.  Under explicitly supplied live table/dispatch/
return, receiver, alias/external-frame, and final-copy facts, later handlers
cannot run and direct post-selection coordinate changes reduce to the
cached-floor Y snap.  Every same-sample floor admitted by the finite
`find_floor` model is at most Y=`896`, and the completed query at preserved
warp X/Z is null against every modeled stock owner.  Live binary32 floor
selection and owner/list projection remain open premises.

**What closes it.** Derive the supplied dispatch/receiver/frame facts and the
live floor/owner projection from one linked frame.  A survivor must violate one
of those premises rather than merely invoke a later normal handler or an
ordinary same-sample cached-floor snap.

### Skipped, wrong-index, or redirected State-to-Object copy

**Overall rank: 19. Family priority: 7. Likelihood: low.**

**In plain language.** Let ordinary or PU movement create a State difference,
then skip the expected copy, copy from the wrong MarioState entry, or write a
different Object.

**What is already known.** The source call shape and order are checked, but
live equality of `gCurrentObject`, `gMarioObject`, `MarioState.marioObj`, and
`gMarioStates[0]` is not yet an invariant.  The proof layer explicitly retains
skipped/nonreturning, wrong-target, wrong-transfer, retarget, and lifecycle
copy escapes.
No normal wrong receiver, index, or nonreturning path has been observed; the
branch ranks lower here than in the proof-obligation matrix because it has no
current gameplay seed despite its high value for exhaustiveness.

**What closes it.** Prove every relevant path reaches and returns from the copy
with index `0`, stable live endpoints, exact three-coordinate stores, and no
intervening retarget; classify deaths, warps, abnormal returns, and externals.

## Family 4 — Direct Area-2 gate crossings

These ideas try to cross the upper or lower pyramid barrier without first
installing a stale platform pointer.  The formal first-crossing classifier
keeps ordinary physics, platform displacement, object impulse, collision clip,
area reload, nonlocal cast, and same-position support change separate.

Technical background: [upper elevator cut](notes/area2-elevator-cut.md),
[lower target cut](notes/area2-lower-target-cut.md), and
[route exhaustiveness](notes/route-exhaustiveness.md).

### Held-A jump-kick or B rollout from the upper elevator shaft

**Overall rank: 10. Family priority: 1. Likelihood: low.**

**In plain language.** First complete the no-spin descent on the shaft line and
land on the live elevator.  From that landed state, use a no-new-A action to
get over or through the elevator-shaft wall.

**What is already known.** A held-A plus B jump kick is a genuine no-new-edge
action, and B-only dive/rollout movement is real.  In the current arithmetic,
the jump-kick envelope reaches `128`, rollout `220`, and even a generous Wing
flutter `228`, below the checked `231` wall threshold.  Those are not yet live
collision executions, and cap reset at entry remains a premise.

**What closes it.** Execute the initial descent, every intermediate floor
query, intended live-elevator selection and landing, then every Float32
quarter-step, wall response, action transition, collision phase, and cap
state.  Either one trajectory crosses the cut or the finite action/collision
split becomes exhaustive.

### Lower-aperture impulse, clip, or support switch

**Overall rank: 11. Family priority: 2. Likelihood: low-medium.**

**In plain language.** Leave the second pole without A and cross the floor-ring
aperture using a collision clip, object shove, moving support, or a change in
which floor the game selects even when Mario's coordinates barely change.

**What is already known.** The exact pole top, ring, aperture, and target-side
supports are imported.  The old normalized soft-bonk trajectory does not
clear the route, but that proves only one subcase.  Z soft-bonk, falling below
the pole bottom into freefall, wall outcomes, moving owners, nonlocal casts,
and same-position support changes remain legitimate branches.

**What closes it.** Instantiate and complete the current conditional Float32
collision-phase theorem with linked execution and an exhaustive pole-action
exit split, then classify every impulse, clip, support, and external writer at
the first target-side crossing.

### Moving geometry or object impulse

**Overall rank: 20. Family priority: 3. Likelihood: low-medium.**

**In plain language.** Use a homing Amp, Grindel, elevator, Tweester, jumping
box, shell, or another object to push, carry, shock, or reanchor Mario across a
gate.

**What is already known.** These effects are genuine game mechanics, and the
lower transcript route deliberately uses Amp/Grindel/elevator interactions.
Bounded Tweester and jumping-box experiments raised Mario but did not create a
useful gap or target crossing.  No complete transitive moving-owner route is
proved.

**What closes it.** Build the live spawn and callback closure, exact collision
owner, action result, binary32 movement, and controller chronology for each
reachable object family.  A counterexample needs a concrete object sequence,
not just an abstract `object impulse` label.

### Reload, nonzero warp destination, or same-position support change

**Overall rank: 20A. Family priority: 4. Likelihood: low-medium as a coverage
branch; no concrete clean witness is known.**

**In plain language.** Cross a route cut because an area transition reloads a
different entry, a corrupted/nonstandard warp destination adds movement, or
the game changes which floor/platform supports Mario even though his position
does not change.

**What is already known.** The ordinary Area-2/Area-3 instant warp has zero
displacement, and a coherent reload to the same recorded entry cannot cross a
validated cut in the certified semantics.  Same-position support selection is
an explicit first-crossing case for both upper and lower gates.  Linked
execution outside those coherent premises remains open.

**What closes it.** Prove every reachable destination, entry snapshot,
area-load memory effect, and selected support from the linked program; or
produce the exact nonzero/corrupted destination or changed-support witness.

### Direct Float32 pole exit or pole avoidance

**Overall rank: 25. Family priority: 5. Likelihood: very low on current
evidence.**

**In plain language.** Find an untested quarter-step, seam, wall response, or
action that gets Mario around the second-pole ring without using the larger
installer mechanisms above.

**What is already known.** The normalized route is negative, and exact local
geometry makes the opening narrow.  It is also proved false that A is the only
way off a pole: Z soft-bonk and freefall exits exist.  No live zero-A exit has
yet reached the target side.

**What closes it.** Enumerate every pole action/health/version branch, all four
air quarter-steps, floor/wall/lava-wall outcomes, and the live support mesh.

## Family 5 — Downstream collection of the two target stars

An installer or gate crossing is not enough.  These are the remaining routes
from a supplied Area-2 boundary to the actual target objects and save bits.

Technical background: [Area-2 downstream continuations](notes/area2-downstream-continuations.md).

### Join the Act-6 trigger, spawn, pickup, and save-bit traces

**Overall rank: 7. Family priority: 1. Likelihood: high once a valid gate
installer exists; this is not an installer by itself.**

**In plain language.** Touch all five Pyramid Puzzle trigger regions, make the
hidden star spawn, then overlap and collect it without a new A press.

**What is already known.** Static support triangles for all five triggers are
checked.  One conditional JP replay consumes all five and spawns the star; a
separately tuned replay overlaps the spawned star and changes the SSL save byte
from `0x00` to `0x20`.  They are intentionally separate receipts, and both
start from an injected boundary rather than clean retail execution.

**What closes it.** Construct one cut-starting linked suffix containing the
five ordered triggers, spawn, active-parent lifecycle, star overlap, collection,
and exact save-bit change, with zero-edge input evidence throughout.

### Upper Act-3 100-coin/star-dance itinerary

**Overall rank: 8. Family priority: 2. Likelihood: low-medium.**

**In plain language.** Spawn the 100-coin star near the Act-3 platform, store
the upward part of a rollout, reactivate that vertical speed, collect the
100-coin star with a ground pound, use the star dance for a ledge grab, and
roll into the Act-3 star.

**What is already known.** This is the transcript's specified upper route, and
the target/support geometry is checked.  Simply standing on the checked floor
under the Act-3 star misses its hitbox by `75` vertical units.  There is no
authenticated cut-starting replay of the itinerary.

**What closes it.** Prove the 100th-coin timing and placement, rollout-speed
storage/reactivation, ground-pound and star-dance transitions, ledge collision,
final star overlap, and Act-3 bit update in one linked zero-edge suffix.

### Lower Act-3 Amp/Grindel/elevator itinerary

**Overall rank: 9. Family priority: 3. Likelihood: low-medium.**

**In plain language.** Use a homing Amp shock for a ledge grab, cross the ramp,
exploit a one-unit upper-Grindel misalignment, exploit a matching undescended
elevator misalignment, ride the elevator, and roll into Act 3.

**What is already known.** The itinerary is recorded and the static target
geometry is checked.  A failed direct-steering experiment fell to Y `-101`,
but it did not test the transcript's two misalignment steps and therefore does
not refute this route.

**What closes it.** Replay the exact Amp homing, knockback, ledge, Grindel, and
elevator phases from the lower cut with binary32 collision ownership and zero-A
controller history, then prove target overlap and save-bit change.

### Negative-depth transport to a fresh or older star

**Overall rank: 27. Family priority: 4. Likelihood: low.**

**In plain language.** Use the negative-depth/dialog machinery not to install
Ink, but to arrange a fresh 100-coin star or another already tangible star at a
height and time that provides a useful collection/dance transition.

**What is already known.** Fresh-star timing is modeled, but the checked
successor placements miss vertically by more than `96` units.  No alternate
relative placement or suitable older-star setup is known, and normal target
provenance prevents substituting the wrong star for Act 3 or Act 6.

**What closes it.** Supply an exact reachable star position/lifecycle and
overlap schedule, or prove every eligible fresh/older star remains outside the
necessary contact envelope.

## Family 6 — Goomba raising and PU transport

### Goomba H/F/R raising, PU capture, and Spindel handoff

**Overall rank: 16. Family priority: 1. Likelihood: very low as a full route.**

**In plain language.** Repeatedly raise a Goomba with a hit-and-depart, far
reset, and near rearm cycle; then try to use a parallel-universe coordinate
alias, capture the object in the useful segment, and hand the setup to Spindel
or another moving object.

**What is already known.** The H/F/R primitive and binary32 velocity arithmetic
are real.  Full-float object-distance semantics instead explain why a PU alias
does not by itself transport the Goomba or keep a distant Spindel loaded.  The
original post-collision schedule can perform only `31` useful hits in the
`91`-frame window where `83` are required, so that version is refuted.  A
pre-collision raw-Object-return schedule remains open, while physical singleton
transport, same-segment capture, repeatability, and every handoff are still
uninhabited.  Failed nonfinite casts trap instead of yielding a continuing
coordinate.

**What closes it.** Execute a revised pre-collision schedule, prove the exact
Goomba receiver and lifecycle, preserve it through PU transport, instantiate
every handoff, and then give a target continuation.  Otherwise prove the
remaining writer/timing classes cannot beat the hit budget.

Technical background: [Goomba raising](notes/goomba-raising.md) and
[nonlocal endpoints](notes/area1-nonlocal-endpoints.md).

## Family 7 — Eyerok and Area-3 manipulation

Eyerok is mainly a proposed gateway to Act 3 through Area 3 and back into Area
2.  Eyerok's own boss star is source index `3`, not either target, and there is
currently no modeled Eyerok-to-Act-6 continuation.

The active project imports only narrow facts from the archived Eyerok work.
Most results below are substantial conditional or source-shaped evidence, not
linked retail executions.  See [archived proof evidence](notes/archived-proof-evidence.md).
The detailed historical experiments are in the clearly archived
[Eyerok notebook](../../old-proofs/eyerok-manipulation/Eyerok.md).

### Carry a stale Eyerok-hand address into Area 2 in JP

**Overall rank: 14. Family priority: 1. Likelihood: low, but the best Eyerok
lead.**

**In plain language.** Cache the static tunnel warp as Mario's floor while
separately remembering an Eyerok hand as the moving platform.  JP keeps the
hand address across the Area-3-to-Area-2 warp and can read whatever payload is
left in or later placed into that slot.

**What is already known.** Archived source/model evidence says US clears the
pointer while JP retains and consumes a saved address once.  An injected
matching-ROM comparison reused the watched
slot as a zero-motion water droplet and therefore moved Mario by `(0,0,0)`.
Ordinary coherent JP entry has a null platform.  The essential incoherent
floor/hand prestate has never been reached cleanly.  Platform displacement
changes Mario's position and facing but preserves his stored vertical and
forward speeds.  A useful large effect therefore needs positional
displacement—most plausibly rotation around a large ordinary- or PU-scale
lever arm—not a speed-building effect from the transition itself.

**What closes it.** Construct the exact floor/platform mismatch, prove hand
unload and free-list timing, payload identity and motion, first Area-2 apply,
and an Act-3 continuation.  The actual apply also needs time stop to permit the
update, a present Mario object, and a non-null cached pointer.  Ordinary and
PU-scale lever-arm variants should remain separate.  Eyerok currently supplies
no Act-6 route; covering both targets also needs Family 5's Act-6 work.

### Board and ride a raised hand into the lower route

**Overall rank: 15. Family priority: 2. Likelihood: low-medium as a primitive,
low as a full route.**

**In plain language.** Start Mario's air motion before a double-pound launch so
the first hand step remains within floor-snap tolerance, then ride the hand's
finite rise and depart toward the tunnel.

**What is already known.** Injected US local continuations snap at the first
eligible gap and ride the modeled `+85,+70,+55,+40,+25,+10` sequence.  One uses
preheld A with no new edge and one uses B only.  The resulting hand top remains
`303` below the lowest tunnel query; even granting the same `+60` action
envelope would leave it `243` short.  The predecessor and boss timing are
injected, not reached.  The separate nonlethal long-jump reboard trace has the
`288`/`228` deficits, but it inherits an earlier fresh-A predecessor.

**What closes it.** Authenticate the controller-only predecessor and boss
phase, live hand collision ownership, an additional lift/support mechanism,
the hand-to-warp departure, and the Act-3 continuation.  Act 6 remains a
separate downstream task.

### Second-hand ceiling to the Area-2 Y=1280 tier

**Overall rank: 23. Family priority: 3. Likelihood: low.**

**In plain language.** Grant Mario the highest modeled second-hand surface,
cross the Area-3 warp with an upward action, and land on the pyramid's
Y=`1280` floor tier.

**What is already known.** The generous modeled hand ceiling is Y=`1179`.  A
fresh-A triple-jump envelope conditionally reaches Y=`1280`, but that is not a
no-A route.  Seam-free B-only speed-kick and already-held-A jump-kick routes
are excluded when inherited speed is at most `48`, there are at most `35`
eligible steps, and the respective conservative quarter-step budgets are at
most `12` and `13` inside the ordinary wall-avoiding classification.  The hand
ceiling is a proved bound, not an attained clean retail state.

**What closes it.** Construct a faster no-A predecessor, post-bonk recovery,
seam/quantum-tunneling path, or PU-cast entry; or prove all reachable departures
remain inside the existing speed and wall bounds.  Then connect the landing to
Act 3.  Act 6 remains separate.

### Update-11 wake-sandwich Pedro installer

**Overall rank: 24. Family priority: 4. Likelihood: low.**

**In plain language.** Enter a floor/ceiling squeeze during the staggered hand
wake, hoping the cancelled movement keeps an old floor while updating the hand
platform cache.

**What is already known.** Real Eyerok Pedro geometries exist.  The staggered
wake has a one-unit ordinary entry on update `11`, and update `12` closes the
geometry, so the ordinary entry permits only one air-speed update and cannot be
repeat-ground.  For the checked common `update_air_with_turn` /
`update_air_without_turn` family, the ideal gain is at most `3.85` and the
conservative ROM-facing bound is `4`; other air-action writers and a universal
Float32 ceiling remain open.  The mechanism is more interesting as a one-frame
cache-desynchronizer than as a speed engine, and it has not produced the
required mismatch.

**What closes it.** Authenticate the exact predecessor and input history, then
prove or refute the floor/hand cache mismatch in the required update order.

### Attack and reboard a rising hand

**Overall rank: 29. Family priority: 5. Likelihood: very low.**

**In plain language.** Hit an Eyerok eye, make its hand rise, then fall back
onto or reacquire its moving collision before it returns or disappears.

**What is already known.** Standing on either hand top is above the eye
hitbox, so the simple “stand, attack, ride” plan fails.  Tested nonlethal
reboarding needs an injected prior long-jump and happens only after return
home; tested lethal rises never select the platform before deletion.

**What closes it.** Authenticate or refute the nonlethal predecessor and its
earlier A edge; generalize the lethal pose/steering search; and, if reboarding
succeeds, prove the hand-to-warp and Act-3 continuation.

### Sleeping-hand Pedro speed bootstrap

**Overall rank: 30. Family priority: 6. Likelihood: very low.**

**In plain language.** Cross the sleeping hand's narrow wall band in one
quarter-step and enter its floor/ceiling squeeze.

**What is already known.** Ordinary exterior entry needs a quarter-step over
`100`, or directional speed over `400`.  An injected speed of `424` works and
preserves the old floor/X/Z state, but no no-A source of that speed is known.
As a standalone speed bootstrap, the proposal is circular.

**What closes it.** Find an independent no-A speed source and authenticate its
pose/action, or prove every reachable preload remains below the threshold.

### Seams, moving boundaries, or partial updates

**Overall rank: 31. Family priority: 7. Likelihood: very low.**

**In plain language.** Slip between moving collision pieces, or find a frame
in which action state changes but hand movement or collision only partly runs.

**What is already known.** The exact positive-double sibling approach has no
sample that is both horizontally and vertically eligible.  In the modeled
no-external-writer lifecycle, a live hand cannot enter the movement-only
partial-update guard.  Other seams and transformed phases are not exhaustive.

**What closes it.** Enumerate every transformed hand mesh and phase, moving
boundary, wall response, partial-update flag writer, and external effect in
linked execution.

### Eyerok approaches retired at the current formal boundary

These are below all active ranks.  “Retired” means disproved inside the named
audited or source-shaped boundary; linked Clight/ROM refinement is still needed
for a final retail exclusion.

| Overall rank | Family priority | Approach in plain language | Current result | Legitimate close-out or reopening condition | Likelihood |
|---|---|---|---|---|---|
| Retired | R1 | Let a destroyed hand's own fragments take its stale slot immediately. | Fragments allocate before the hand frees; the sibling's fragments miss the one-active-update window. | Finish linked allocator/callback timing, or exhibit an omitted allocation before apply. | Near zero for this construction. |
| Retired | R2 | Stack nonlethal hits or use two hands for unbounded height. | Accepted hits reset at home and have bounded impulses; audited first- and two-hand barriers refute the old height premises. | Break a named reset, support, or writer premise with a linked event. | Near zero. |
| Retired | R3 | Preserve positive velocity in zero gravity and rise forever. | The required grounded or airborne-positive seed is unreachable in the archived model. | Supply a concrete omitted velocity/gravity writer and reachable predecessor. | Near zero. |
| Retired | R4 | Gain height merely by toggling between Areas 2 and 3. | Ordinary instant-warp displacement is `(0,0,0)` and preserves coherent kinematics. | A retained platform, receiver mismatch, or lifecycle effect belongs in another active approach. | Near zero as ordinary warp displacement. |
| Retired | R5 | Collect Eyerok's boss star as a requested star. | Its index is `3`, not target index `2` or `5`. | Only explicit save/target-provenance corruption, classified under Family 8. | Closed under normal provenance. |

## Family 8 — Generic memory, collision, scheduler, and upstream escapes

These are necessary for proof exhaustiveness but currently poor gameplay
leads.  A concrete witness in any one of them would immediately move it much
higher in the ranking.

### Alias, external write, false collision cache, hitbox mutation, DMA, or forged state

**Overall rank: 32. Family priority: 1. Likelihood: very low as a known clean
route; high proof importance.**

**In plain language.** Make one of the supposedly distinct pointers name the
wrong memory, have an external routine change protected state, retain a stale
warp collision, alter a hitbox, overlap an animation/DMA buffer with gameplay
state, or forge an action/timer/owner.

**What is already known.** A defined one-store State/Object divergence must
target one endpoint block; ordinary address and initializer origins reduce to
explicit semantic escapes.  Selected audited builtin/runtime cases have
framed effects, while unresolved `EF_external` callsites still need argument
provenance and either a protected-cell frame or a concrete writer/lifecycle
refinement.  Direct platform writers are censused; collision-cache and hitbox
observations have data-bearing abstract escape classifiers.  No clean
corruptor is known.  Capacity guards can drop collisions but do not create a
false one.  Animation metadata itself preserves Mario's coordinates.

**What closes it.** Prove live pointer/block/offset provenance for every
reachable store, per-callsite frames or exact effects for every external,
same-frame collision clear/traversal/owner return, hitbox/down-offset writers,
FPCSR/trap behavior, and object-pool epochs.  A failure must identify the exact
store, call, cache entry, or corrupted field.

### Castle-to-SSL glitch or retained inbound pointer

**Overall rank: 33. Family priority: 2. Likelihood: very low and intentionally
deferred.**

**In plain language.** Create a useful glitch in the castle and carry it into
SSL before the scoped proof begins.

**What is already known.** Public gameplay evidence already establishes that
ordinary castle-to-SSL entry exists, so the project does not spend scarce
compute reconstructing that route.  The formal core starts at an explicit
Area-1 boundary with a null platform pointer, synchronized Mario views, and no
new A edge.  The boundary is an assumption and does not disprove an upstream
glitch.

**What closes it.** Treat it as a separate project: define the earlier start,
authenticate the castle route and input history, carry every relevant memory
cell through the transition, and show the resulting state satisfies—or breaks—the
Area-1 boundary.  It should not block the scoped theorem unless a concrete lead
appears.

## Retired and corrected ideas

These proposals have no active overall rank because their stated mechanism is
already refuted or based on a mistaken premise.  They are grouped by family,
with the more important correction first inside each family, so completed work
is not repeatedly rediscovered.

| Family / retired priority | Proposal | What the project found | What could legitimately reopen it | Likelihood as stated |
|---|---|---|---|---|
| Input semantics R1 | “No A edge means Mario cannot move upward” | False: B rollout and already-held-A actions can create upward movement without a new edge. | Nothing; use the correct input-edge model. | Closed misconception. |
| Input semantics R2 | “A is the only way to leave the second pole” | False: Z soft-bonk, below-bottom freefall, walls, and health/version branches exist. | Nothing; enumerate those branches instead. | Closed misconception. |
| Direct gates R1 | The normalized pole soft-bonk clears the lower route | Refuted for the modeled trajectory; it loses the needed height/clearance. | A different live Float32 phase, writer, support, or action. | Very low for that trajectory. |
| Direct gates R2 | Pure upper jump-kick/rollout/Wing flutter clears the wall | Checked envelopes remain below the `231` threshold. | A collision glitch, moving-relative wall, extra writer, or broken cap premise. | Very low under the checked bounds. |
| JP platform R1 | Intact stock top simultaneously touches the warp and is selected from the same sample | Refuted by the imported stock geometry. | Different samples, relocation, clone, or corrupted geometry. | Closed for the fixed same-sample model. |
| JP platform R2 | Stock yaw-only top motion supplies the needed vertical PU change | Refuted in the checked arithmetic model. | A different payload field or replacement object. | Very low as stated. |
| PU/casts R1 | NaN, infinity, or failed large cast becomes a usable terrain coordinate | Modeled retail invalid conversion traps before a continuing query. | A proved different FPCSR mode or resumable handler. | Very low. |
| Goomba R1 | Original post-collision Goomba H/F/R schedule reaches the target height | It permits `31` useful hits where `83` are required. | A genuinely different pre-collision schedule or writer. | Closed for that schedule. |
| Animation/HOLP R1 | [Turning action `0xBD`](notes/turning-animation-upwarp.md) creates a 189-unit rise | The relevant normalization is `189/189 = 1`; metadata preserves position. | A real memory alias/DMA writer, not the animation arithmetic. | Closed as arithmetic. |
| Animation/HOLP R2 | Turning/HOLP moves Mario through the rendered hand matrix | The matrix can update `heldObjLastPosition`, but turning drops held objects first; HOLP affects a later drop/throw, not Mario's gameplay position. | A proved held-object survival path or actual animation-buffer/DMA alias. | Very low. |
| Ink R1 | Shell `+42/+45` graphics offsets accumulate forever | Normal frames reanchor them. | A proved skipped reanchor or alias schedule. | Very low alone. |
| Ink R2 | Fire-particle `prevObj` moves Mario | It moves the flame object, not Mario. | Only a receiver-alias proof failure. | Closed under normal receivers. |
| Ink R3 | A direct stock Area-1 door supplies the automatic-dialog route | No direct Area-1 macro/script door root exists. | A transitive spawn/interpreter/debug route to a suitable dialog actor. | Very low as a direct root. |
| Held-object R1 | A carried box remains a useful moving collision platform | Carry scripts disable or lose the needed collision. | A different object with proved collision retention. | Very low for the box. |
| Held-object R2 | Pickup can beat the warp interaction at node `0x1E` | Handler order gives the warp interaction priority. | Retargeted handler table, stale collision cache, or corruption. | Very low under normal dispatch. |
| Held-object R3 | Obtain `heldObj == node 0x1E` through enumerated stock pickup or stale-held-slot paths | The counterfactual drop would relocate the live entrance, but audited stock paths do not produce that held pointer. | A concrete new held-pointer or behavior-provenance exploit; ordinary relocation/clone remains active at rank 4. | Very low for enumerated paths. |
| Lifecycle R1 | Direct Area-2/Area-3 instant warp adds height | Its displacement is zero and coherent kinematics are preserved. | A stale-platform, receiver, or lifecycle effect classified separately. | Closed as ordinary warp displacement. |
| Lifecycle R2 | Reload or the wrong star directly sets a target bit | Coherent reload preserves save facts; Eyerok/100-coin/other stars have different indices. | Explicit save corruption or target-provenance failure. | Closed under certified provenance. |
| State-first R1 | Area-1 palm/tree pole push is a late State-only writer | It executes before PLAYER; the later correct copy resynchronizes State/Object. | A later transitive caller or a failed/redirected copy. | Closed for that caller/order. |
| Object impulse R1 | Tweester or jumping-box search already found an installer | Bounded searches found synchronized elevation but no positive view gap, warp/top capture, or target crossing. | A different live object-impulse chronology; keep it under rank 20. | Very low for tested schedules. |
| Act-3 downstream R1 | The failed direct Grindel steering test refutes the lower itinerary | It did not attempt the transcript's Grindel/elevator misalignments. | A faithful test of the actual itinerary, positive or negative. | The negative inference is invalid. |

## What would count as a complete counterexample

A complete counterexample for either target is not merely a large displacement,
a target-region coordinate, or a star-spawn event.  It must provide one
connected execution that:

1. starts at the declared SSL Area-1 boundary, or explicitly extends and
   replaces that boundary;
2. has an authenticated input history with no new A edge;
3. crosses the relevant Area-2 gates through actual collision and object-list
   execution;
4. reaches and collects the chosen Act-3 or Act-6 target object with correct
   provenance;
5. newly sets that target's corresponding save bit; and
6. is connected through selected Clight execution to the pinned retail version.

Establishing that **both** targets are obtainable requires this evidence for
each one, as a version-consistent pair of clean executions or as one larger run
whose exit/re-entry interval is also modeled.  It is stronger than finding a
single counterexample to one target's impossibility claim.

Until then, “works when injected” means the engine accepts a supplied state; it
does not mean ordinary gameplay can create that state.  Conversely, an
abstract escape case should not be dismissed merely because no setup is known:
it closes only when linked execution proves the escape unreachable or a real
trace inhabits it.

For the exact open proof obligations, use the [checklist](checklist.md).  For
the formal cut and coverage boundaries behind these rankings, use
[route exhaustiveness](notes/route-exhaustiveness.md).  For the most detailed
installer-mechanism matrix, use the
[local-Object/nonlocal-State gap matrix](notes/local-object-nonlocal-state-gap-matrix.md).
