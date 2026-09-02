# No-A two-star route atlas

> Status snapshot: 2026-08-29.  Rankings are intentionally revisable as linked
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

Keep the navigation bidirectional whenever an approach is added, removed, or
reranked: its **Approach** cell in the at-a-glance table must link to a stable
explicit `route-rank-*` anchor immediately above the approach heading, and the
description must end with a **Back to the at-a-glance ranking** link.  Update
the table link, section anchor, and return link together when a rank changes.

Every verdict must also respect the [CompCert execution-scope boundary](compcert-execution-scope.md): defined in-bounds aliases, known-function retargets, ordinary scheduler/collision/lifecycle behavior, and explicitly modeled calls remain legitimate proof targets; unresolved external effects first need a concrete specification; successful out-of-bounds accesses, invalid-pointer calls, arbitrary code execution, post-undefined-behavior MIPS continuations, DMA, and interrupts are outside the current Clight runs and must be labeled **outside the current execution model**, never “disproved in the retail game.”

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
- **The leading route is JP-only, but its known clean schedule now fails:** a
  complete zero-A four-pillar and upper-warp run never remembers the spinning
  top and produces no useful positive split; another schedule would have to
  break a precisely checked query, owner, alias, outside-call, or lifecycle
  boundary before the old JP pointer can help.
- **A real cached-floor collision/query split is now checked:** it is the
  Y-only change `(0,-50,0)`, so it proves that the two samples need not be
  equal but cannot install the top.
- **The clean pillar/upper-warp routing obligation is complete:** the remaining
  rank-1 task is universal coverage of materially different in-bounds
  executions, not finding a way to touch the four pillars.
- **Moving or cloning the warp/top is absent from that clean route:** every
  loaded top floor keeps the original owner and normal position, the upper
  warp stays fixed and floorless, and later reuse of the dead top's slot first
  clears its collision; only a different-history or machine-level producer
  remains.
- **The two leading State-first timing windows are absent from that same clean
  route:** through all 2,462 updates, every Mario copy returns to matching
  State and Object coordinates with no later coordinate or identity write,
  while every cached-platform apply loads an empty pointer and makes no
  displacement, including the three upper-warp frames; only a materially
  different clean history or an all-history proof remains for ranks 5 and 5A.
- **Ink is the leading concrete installer design:** its timer-131 Graphics
  retry works when the required three-view gap and top lifecycle are injected,
  but no known clean execution creates that gap, and the authenticated
  normal-tail timeline through timer 131 found no corruption producer.
- **The signed-16 State alias remains rank 3 for proof value, not because a
  stock installation looks likely:** its exact payload works, but every
  installation in the audited stock scheduler and surface-owner model fails.
- **Writable action-table mutation is no longer a free-form alias/external
  lead:** the whole modeled game has no stored initializer or export alias,
  each version has only four terminal reads, and the proof now constructs the
  private table relation at successful initialization and preserves it through
  every actual reached Clight step; successful in-bounds selected executions
  cannot mutate any of the three tables.  A separate hypothetical theorem now
  preserves the payoff for a future machine-level discovery: a correctly timed
  two-word pole/knockback mutation supplies a real long jump that crosses the
  lower cut in five clear zero-A frames.
- **Out-of-bounds corruption and ACE are deferred, not disproved:** they have
  no witness in the present Clight execution model and need a retail MIPS or
  hardware semantics before this project can decide them.
- **Act 6 has the strongest downstream evidence:** trigger/spawn and
  pickup/save-bit replays both exist conditionally, but still need joining.
- **Act 3 is the main downstream gap:** the upper and lower itineraries are
  specified and source geometry is checked, but neither has a cut-starting
  linked replay.
- **The stale Eyerok-hand route is retired in the audited stock model:** the
  only hand motion that reaches the warp is vertically below both Pedro bands,
  every rising family remains horizontally behind it, the later-writer and
  unreused-slot alternatives are harmless, and the only reused nonzero payload
  moves Mario slightly down and back.
- **Rank 15's local hand ride is real, but ordinary VSC does not finish it:**
  even perfect conservation of every checked seed through `31`, plus the full
  ledge/floor lookup allowance, remains below the tunnel; `32` is only the
  first purely vertical arithmetic threshold, the static mesh has no
  intermediate upward floor, and an arbitrary number of cycles in the checked
  Eyerok quotient cannot manufacture the missing seed.  The remaining schedule
  search is now an exact memory-backed Clight chunk classification: poses,
  list order, floor ownership, writes, lifetimes, and reached outside calls.

<a id="at-a-glance-ranking"></a>

## At-a-glance ranking

| Overall | Family | Approach | Current counterexample promise |
|---:|---|---|---|
| 1 | JP stale-platform lineage | [Different collision/query samples, then read the inactive unreused top payload](#route-rank-1) | Very low currently; exact high-payoff JP mechanism if another clean history breaks a checked boundary |
| 2 | Ink installation | [Timer-131 non-null Graphics retry](#route-rank-2) | Very low for a clean producer; exact injected retry |
| 3 | State-first installation | [Finite signed-16 nonlocal-State alias](#route-rank-3) | Very low in the audited stock model; exact injected payload |
| 4 | JP stale-platform lineage | [Move the warp/top or create a collision-preserving clone](#route-rank-4) | Very low on the checked clean route; the warp never moves or gains collision, and every top-slot reuse first loses the top collision |
| 5 | State-first installation | [Post-copy State-only writer in a later callback or descendant](#route-rank-5) | Very low on the checked clean run; another history must expose the first late write, wrong receiver, or lifetime failure |
| 5A | State-first installation | [Pre-collision cached-platform displacement creates the split](#route-rank-5a) | Very low as a clean origin on the checked run; the effect remains exact if another history installs a valid pointer |
| 6 | JP stale-platform lineage | [Moving skipped-query interval](#route-rank-6) | Very low; no moving skip appears in the audited scheduler shapes |
| 7 | Downstream collection | [Join all five Act-6 triggers, spawn, pickup, and save-bit update](#route-rank-7) | High conditional value; the recovered transcript and published run put the sole press at the second pole, and an exact one-edge controller segment now reaches the downstream Grindel base |
| 8 | Downstream collection | [Lower Act-3 100-coin-star/Grindel itinerary](#route-rank-8) | High conditional value; the recovered five-trial account and published run reach Act 3 after the sole second-pole press, while exact inputs currently stop at the Grindel base |
| 9 | Downstream collection | [Upper Act-3 100-coin/star-dance itinerary](#route-rank-9) | Low-medium conditional continuation; no cut-starting replay |
| 10 | Direct Area-2 gates | [Held-A jump-kick or B rollout from the upper elevator shaft](#route-rank-10) | Very low for the checked vertical routes; live collision closure remains |
| 11 | Direct Area-2 gates | [Lower-aperture impulse, clip, or support switch](#route-rank-11) | Low in-model; exact payoff only if an ordinary escape or deferred timed mutation exists |
| 12 | Direct Area-2 gates | [Homing Amp or a moving collision owner](#route-rank-12) | Very low after the stock shock-composite closure; only a transported Goomba or a failed runtime-owner premise remains |
| 12A | Direct Area-2 gates | [Reload, nonzero warp destination, or same-position support-selection change](#route-rank-12a) | Low; useful coverage branch, but no concrete clean witness |
| 13 | State-first installation | [Raw-Object-only return or impulse writer](#route-rank-13) | Low; broad proof branch, but no concrete gameplay writer |
| 13A | State-first installation | [Terrain-dispatch or collision-prefix writer outside the platform phase](#route-rank-13a) | Low; proof branch with no reached extra writer |
| 13B | State-first installation | [Interaction-stage writer or cached-floor snap composite](#route-rank-13b) | Low; the ordinary branch is conditionally blocked |
| 14 | Eyerok | [Carry a stale Eyerok-hand address from Area 3 to Area 2 in JP](#route-rank-14) | Retired in the audited stock model; no hand can install the pointer at the warp, and the sole reused nonzero payload moves about 8 down and 38 backward |
| 15 | Eyerok | [Board and ride a raised hand into a lower Area-2 route](#route-rank-15) | Medium as a proved local ride, but very low as a full route; the memory-backed bridge now exposes any surviving pose, owner, list, write, outside-call, or lifetime escape exactly |
| 16 | Goomba / PU transport | [Goomba raising, PU transport, and Spindel handoff](#route-rank-16) | Very low; both finite top-window timing classes are refuted, and the generous revised case reaches only Y=1017 |
| 17 | JP stale-platform lineage | [Fresh same-slot replacement payload](#route-rank-17) | Low abstractly; absent in the authenticated best trace |
| 18 | State-first installation | [Skipped, wrong-index, or redirected State-to-Object copy](#route-rank-18) | Low; no normal receiver or return failure has been observed |
| 19 | Ink installation | [Negative quicksand depth plus stalled automatic dialog](#route-rank-19) | Very low; no clean seed, failed lookup, or Graphics-to-collision bridge |
| 20 | Ink installation | [Mario behavior flag plus a large graphical Y offset](#route-rank-20) | Very low; ordinary stock writers are excluded |
| 21 | Ink installation | [Non-stock Graphics anchor or spawned anchor actor](#route-rank-21) | Very low; the required parent actors are absent from stock Area 1 |
| 22 | Eyerok | [Second-hand ceiling to the Area-2 Y=1280 tier](#route-rank-22) | Very low under the checked height and speed bounds |
| 23 | Eyerok | [Update-11 wake-sandwich Pedro installer](#route-rank-23) | Very low; only a one-frame desynchronizer remains plausible |
| 24 | Direct Area-2 gates | [Direct Float32 pole exit or pole avoidance](#route-rank-24) | Very low on current geometry and trajectory evidence |
| 25 | Ink / wall interaction | [Shell visual offset plus wall/floor schedule](#route-rank-25) | Very low; the offset is small and normally reanchored |
| 26 | Downstream collection | [Negative-depth transport to a fresh or older tangible star](#route-rank-26) | Very low; checked placements miss and no suitable older star is known |
| 26A | JP stale-platform lineage | [Canonical owner observed outside the modeled geometry](#route-rank-26a) | Very low after the continuous clean trace; universal-history residual only |
| 26B | JP stale-platform lineage | [Recognized owner at a noncanonical slot or ghost epoch](#route-rank-26b) | Very low after the continuous clean trace; universal-history residual only |
| 26C | JP stale-platform lineage | [Unclassified dynamic owner](#route-rank-26c) | Very low after the continuous clean trace; no missing actor is known |
| 26D | JP stale-platform lineage | [Surface-node/temporary mutation before the floor query](#route-rank-26d) | Very low after the continuous clean trace; no returned stale or changed node |
| 26E | JP stale-platform lineage | [Live same-owner payload mutation before apply](#route-rank-26e) | Very low after the continuous clean trace; no harmful payload change |
| 27 | JP stale-platform lineage | [Classic Spindel replacement-object spawning displacement](#route-rank-27) | Very low; corrected allocation depth and first payload are unhelpful |
| 28 | Eyerok | [Attack and reboard a rising hand](#route-rank-28) | Very low |
| 29 | Eyerok | [Sleeping-hand Pedro speed bootstrap](#route-rank-29) | Very low; no intact stock moving-floor, landing, or `OFF_FLOOR` cycle can evade the cap, so only a named owner/action/source failure or model extension remains |
| 30 | Eyerok | [Seams, moving boundaries, or partial updates](#route-rank-30) | Very low |
| 31 | Memory and control escapes | [Defined alias/external/cache/hitbox escapes; machine-only corruption deferred](#route-rank-31) | Very low as a known gameplay route; proof-critical |
| 32 | Upstream scope extension | [Castle-to-SSL glitch or retained inbound pointer](#route-rank-32) | Very low and intentionally deferred |

This review makes three substantive priority changes.  Genuine moving-object
mechanics and support changes moved from ranks `20/20A` to `12/12A` because
they could bypass the installer families entirely; the later Rank-12 roster
and Amp-payoff audit has now reduced that branch to named collision/support
composites without yet changing its search order.  Negative quicksand falls
from rank `12` to `19`, and the five
abstract floor-owner residuals fall from `18A–18E` to `26A–26E`, because the
producer audits and continuous clean upper-warp trace found none of their
needed effects.  Ranks 1–3 remain high for decision value and exact conditional
mechanisms, not because any now has a likely clean stock producer.

## Family 1 — JP stale-platform and spawning-displacement routes

This family exploits the original-JP behavior that can retain a raw
`gMarioPlatform` pointer across a spawn or area transition.  US clears that
pointer during spawn, so the same route is not presently a US mechanism.  The
important distinction is between **installing** a useful pointer in Area 1 and
the later Area-2 code **using** the bytes found at that address.

Technical background: [route exhaustiveness](notes/route-exhaustiveness.md),
[installer temporal closure](notes/installer-temporal-closure.md),
[JP lifecycle trace](notes/jp-lifecycle-trace.md), and the
[local-Object/nonlocal-State matrix](notes/local-object-nonlocal-state-gap-matrix.md),
plus the [Rank-1 player/floor-owner residual audit](notes/rank1-player-floor-owner-residual.md).

<a id="route-rank-1"></a>

### Different collision/query samples, then the inactive top payload

**Overall rank: 1. Family priority: 1. Likelihood: very low for a clean producer,
but high conditional payoff.**

**In plain language.** Mario's raw collision Object touches the upper warp,
but a later floor query looks at a different position and remembers the
spinning pyramid top as Mario's platform.  The top explodes and its object slot
becomes inactive, yet JP keeps the old address.  On the first pyramid update,
the game reads the still-resident top bytes and applies their three-dimensional
platform displacement to MarioState while the raw Mario Object remains local.

**What is already known.** The conditional stale-top effect still works when its setup is injected, but the supplied 2013 video has now been converted into an independent original-JP route that really touches all four pillars and takes the upper warp with zero A input, and the continuous audit follows that run from Area-1 entry through the warp.  All 2,462 frames pass: every memory-pool change and floor-storage write is harmless, every object and floor list remains intact, all 149,578 floor checks return normally, all 426 moving-floor results have the right live owner, and Mario's final platform is an ordinary ownerless floor in every frame.  The exploding top does briefly leave six triangles behind after its owner is removed, but no floor check returns them and the next frame clears them before checking any floor.  Mario reaches the warp without ever remembering the top or creating a useful upward or horizontal split.  This disproves the named corruption, alias, callback, wrong-owner, and stale-surface explanations for this successful clean route, but not for every possible controller history.

**What closes it.** The real upper-warp attempt is finished, so a complete in-model disproof now needs the same checks for every materially different reachable controller and scheduler history, or one general proof that makes those repetitions unnecessary: no route may overlap the protected floor storage, redirect an outside destination, return a wrong or dead moving-floor owner, keep a usable stale floor past clearing, select an unexpected final platform, or create a useful positive split.  A counterexample instead has to identify the first exact check that a different clean run breaks and then carry the saved top pointer into Area 2.  The confirmed inactive object can still carry such a pointer if another schedule installs it.  Out-of-bounds installation, ACE, raw DMA, and continuation after undefined behavior remain outside the current execution model rather than disproved.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-4"></a>

### Move the warp/top, or create a collision-preserving clone

**Overall rank: 4. Family priority: 2. Likelihood: very low on the checked
clean route; no clean relocation or clone producer is known.**

**In plain language.** Instead of making Mario's different position checks disagree, physically put a standable moving floor inside the upper warp; Mario could then touch the warp and remember that floor at the same place.  A second pyramid top would serve the same purpose only if it kept both the original movement and the original standable collision.

**What is already known.** The stock top and warp are not together, ordinary copying helpers do not copy an object's identity or collision, and the top's own routines create only detectors and harmless fragments.  The new authenticated zero-A four-pillar run checked every live object from Area-1 entry through the upper warp: there was always only one real top and one upper warp, every one of the top's 2,353 collision loads belonged to that top inside its normal small motion range, and the warp never moved, gained collision, changed identity, or loaded a floor.  The dead top's slot was reused three times, but each reuse cleared the old collision before installing a different object, so no replacement kept a standable copy.  This disproves relocation or cloning on that successful route, while the older permissive model still confirms that either effect would be useful if another clean route actually produced it.  See the [Rank-4 warp/top trace](notes/rank4-warp-top-clone.md).

**What closes it.** A full in-model disproof still has to connect the complete stock spawn and collision-writer census to every reachable clean controller history, showing that no ordinary callback, outside effect, alias, or later slot reuse can move the warp or install the top's floor on another object; alternatively, one different clean run can settle the route positively by producing the first extra top, top-collision owner, warp write, or warp collision load and carrying it into the warp.  The checked run supplies the exact test and eliminates the most realistic stock execution, while out-of-bounds writes, ACE, DMA, and execution after undefined behavior remain separate machine-level extensions rather than unfinished clean producers.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-6"></a>

### Moving skipped-query interval

**Overall rank: 6. Family priority: 3. Likelihood: very low.**

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-17"></a>

### Fresh same-slot replacement payload

**Overall rank: 17. Family priority: 4. Likelihood: low abstractly and very low
for the authenticated best trace.**

**In plain language.** Save an object's address, free the object, allocate a
different object in the same slot, then let the stale pointer interpret the new
object's movement fields as a platform displacement.

**What is already known.** The project has an executable abstract slot-reuse countermodel and a replacement payload capable of a large three-dimensional displacement, so the engine effect is possible when supplied.  The authenticated timer-131 trace does not reuse the top slot before the first apply, and the continuous clean four-pillar/upper-warp run finds no useful replacement fate either, so this is absent from both of the strongest observations.

**What closes it.** Produce one coupled linked chronology proving the exact
free-list pushes and pops, same-slot allocation, replacement type, payload
bytes, query selection, and apply timing.  An independent schedule witness and
an independent reuse witness are not enough.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26a"></a>

### Canonical owner observed outside the modeled geometry

**Overall rank: 26A. Family priority: 5. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The floor really belongs to a familiar stock object,
but that object's live transform places its collision somewhere the finite
geometry model did not allow.

**What is already known.** Canonical observations for the fifteen modeled Area-1 owner families do not supply a platform at the fixed upper-warp sample, and the continuous clean upper-warp run strengthens that result: all 426 moving-floor returns have the expected live owner, while Mario's final platform is ownerless and static in all 2,462 checked frames.  No familiar owner appears at an unexpected transform in that run, although this is not yet a theorem over every possible controller history.

**What closes it.** Reconstruct each reachable owner's live position, angles,
scale, collision matrix, and surface insertion at the query frame; otherwise
return the first owner whose observed transform violates the canonical map.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26b"></a>

### Recognized owner at a noncanonical slot or ghost epoch

**Overall rank: 26B. Family priority: 6. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The behavior name looks familiar, but the pointer names
the wrong pool slot, an old lifetime of that slot, or a stale “ghost” copy.

**What is already known.** The lineage classifier keeps this separate from a fresh replacement at apply time.  The continuous clean upper-warp run checks every returned moving-floor owner against its aligned live slot, object list, and unchanged behavior and finds no ghost epoch or interior owner, while the accepted entry fixes the object-pool range.  A universal allocation-epoch theorem for every other input history remains open.

**What closes it.** Connect every `Surface.object` address to an aligned live
pool slot, prove allocation-epoch monotonicity and behavior identity, and frame
unload/reuse from insertion through query.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26c"></a>

### Unclassified dynamic owner

**Overall rank: 26C. Family priority: 7. Likelihood: very low; no missing actor
is known.**

**In plain language.** A reachable actor omitted from the stock owner list
loads a floor at the warp and supplies the platform pointer.

**What is already known.** The finite source-bounded model covers the named stock candidates and proves their geometry exclusion, and every moving floor actually returned during the continuous clean upper-warp run belongs to a checked live owner; no unclassified actor appears.  Generic spawn helpers, transitive behavior scripts, clones, and outside-produced owners are still not ruled out for every possible execution, but no concrete missing actor is known.

**What closes it.** Complete the Area-1 transitive spawn/behavior/collision-data
graph and dynamic-list membership proof, or exhibit the exact new owner and
its clean creation path.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26d"></a>

### Surface-node or temporary mutation before the query

**Overall rank: 26D. Family priority: 8. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The loader starts with the right object and surface,
but a reassignment, list corruption, stale node, or alias changes what the
floor query later sees.

**What is already known.** Source checks tie the currently updating object to each moving-floor owner, and the continuous clean run additionally checks every reached insertion, list, and floor-query return.  The exploding top briefly leaves six triangles after its owner is removed, but no query returns them and the next frame clears them before any new query.  No node is corrupted, substituted, or returned stale in this execution; other controller histories still need the same guarantee.

**What closes it.** Execute allocation, initialization, insertion, list
traversal, clear/removal, and `find_floor` with receiver/alias/external frames.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26e"></a>

### Live same-owner payload mutation before apply

**Overall rank: 26E. Family priority: 9. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The pointer remains valid and names the same object, but
that object's position, angles, velocity, or transform changes between the
floor query and the later platform apply.

**What is already known.** The payload-fate classification deliberately keeps this distinct from slot reuse.  The continuous clean run checks the reached owner identities, protected writes, and query returns and finds no harmful same-owner change or owner-backed final Mario platform.  It remains possible only as a universal-history residual because no theorem yet freezes every displacement field from every possible query through its later apply.

**What closes it.** Prove a per-field last-writer and memory-frame theorem from
query to apply, or return the exact mutating step and resulting binary32
displacement.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-27"></a>

### Classic Spindel replacement-object route

**Overall rank: 27. Family priority: 10. Likelihood: very low.**

**In plain language.** Reuse the stale Area-1 slot specifically as Spindel,
then use Spindel's first update as the spawning-displacement payload.

**What is already known.** The JP retention bug is real, but the corrected
allocation depth is `63`, not the old “60” figure.  The modeled first Spindel
displacement moves the upper-entry sample away from Act 3, and the nearby
elevator is not yet in a helpful state.  The inactive old-top payload is both
better authenticated and currently more promising.

**What closes it.** Construct a clean seed at the exact free-list depth and a binary32 continuation to a target, or finish the finite first-update platform census and rule out every Spindel placement.  In US, the spawn clear blocks retained-inbound-pointer versions at that boundary but does not exclude a later recapture, relocated owner, clone, or independently changed pointer; the final proof must still execute and frame that clear in linked US memory.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 2 — Ink's Graphics-retry installation attempts

Ink's core observation is that SM64 can consult three different views of
Mario's position in one update: raw Object, MarioState, and displayed Graphics.
If Object touches the warp, State's first floor query fails, and Graphics is on
the spinning top, the graphical retry can install the exact JP stale pointer
needed by Family 1.

Technical background: [Ink fallback](notes/ink-fallback.md),
[timer-131 surface](notes/timer131-surface.md), and the
[clean-JP Graphics-gap source audit](notes/clean-jp-graphics-gap-source-audit.md).

<a id="route-rank-2"></a>

### Timer-131 non-null Graphics retry

**Overall rank: 2. Family priority: 1. Likelihood: very low for a clean
producer; exact as an injected mechanism.**

**In plain language.** Leave Mario's collision Object at the upper warp, make
MarioState's first floor lookup miss, but leave the rendered Mario position on
the raised spinning top.  The game retries the floor lookup at the rendered
position and remembers the top.

**What is already known.** The supplied setup works, but it needs at least a `960`-unit gap between Mario's displayed and collision heights (`1010` at the warp center), and a second missed floor check is fatal; ordinary creation, Mario's normal behavior and callbacks, stock display offsets, and another object's slot do not make that gap, while a deliberately non-stock `+1160` offset confirms the geometry.  The accepted hash-checked JP entry ends with Mario in slot 67, both game pointers selecting him, normal `bhvMario`, one-node player-list membership, flag value `0x100`, and zero graphical offset.  From that exact endpoint, one receipt checks 131 ordinary updates, and a stronger route-specific receipt uses one separately logged write only to the spinning top's slot-61 pillar counter, then follows 144 consecutive authentic updates to the top's real action 1 timer 131.  In the stronger receipt Mario never changes slot, list, behavior, or either protected value; all 144 writes which trigger any of the twelve protected ranges are the same harmless collision-reset halfword immediately after `activeFlags`; all three Mario callbacks and the command and dispatch bytes remain stable; 93 allocations succeed with no allocator fallback; and 71 unloads and 71 source-sound calls cause no watched change.  The real sound-call tree is independently proved to write only sound data or safe stack, `sqrtf` is store-free, the two conservative debug-print callsites are not reached, and the heavily used HUD print callees likewise produce no protected write in this receipt.  Thus the selected spinning-timer timeline contains no corruption producer, but this conditional machine receipt is not yet a universal proof over every controller history or a proof that debugger watchpoints are complete N64 semantics.

**What closes it.** The clean four-pillar run now reaches the top's real timer 131 without changing Mario's protected values, but Mario reaches the upper warp only after the top explodes, so it does not supply the retry geometry; a counterexample must couple the clean pillar activation, the still-spinning top, the upper-warp collision, and the required three-view gap in one run.  A complete in-model disproof instead must show that every controller and lifecycle history preserves Mario's identity, behavior, flag, and graphical offset or identify the first exact store or outside call that does not.  Ordinary castle entry and an IDO-to-Clight entry bridge remain unnecessary under the chosen boundary.  Negative quicksand still needs an unusual seed and a way to turn displayed height into collision height, while out-of-bounds writes, arbitrary code execution, and DMA require a separate retail-machine model; only a surviving producer warrants continuing to the failed lookup, top-owned retry, JP displacement, and the separate Act-3 and Act-6 continuations.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-19"></a>

### Negative quicksand depth plus stalled automatic dialog

**Overall rank: 19. Family priority: 2. Likelihood: very low; Area 2 makes the
hypothetical payoff exact but supplies neither a clean seed nor the needed
Graphics-to-collision bridge.**

**In plain language.** Make quicksand depth negative, then remain in a dialog state that repeatedly raises Mario's displayed position without snapping it back; this can build either the large Ink gap needed in Area 1 or, hypothetically, the much smaller height needed below an Area-2 star, but the displayed height must still be copied into Mario's real collision position before it can collect anything.

**What is already known.** A negative depth could create enough displayed-height gap, but the clean zero-A source has no known way to create the starting value: every direct depth change has been audited, and the only dangerous one is a late long-jump landing that normally requires A; stock interactions, writable tables, and the checked whole-game aliases do not bypass that requirement.  Ordinary Area-2 entry also resets depth to zero.  Area 2 nevertheless contains 260 quicksand triangles, with an exact moving-quicksand floor leaving the Act-6 star just 11 raw collision units above standing Mario; the Act-3 standing gap is 75 units and its floor is not quicksand.  The new conditional proof shows that retaining the known hypothetical `-2.65` value for five sinks supplies enough displayed height for Act 6, and 29 supplies enough for Act 3, but only if a later retry copies that height into Mario's real collision position; without that copy, every finite number of sinks leaves both star checks unchanged.  Both ordinary target samples already have static floors, so the required failed lookup is unexplained, and the original Area-1 dialog candidate remains far from the upper warp.

**What closes it.** In the current in-bounds CompCert model, follow one accepted live execution from its clean zero-depth start, match every reached depth and action change to the harmless audited cases, and give every reached outside call an exact promise that it preserves the relevant values; this either disproves the remaining clean seed or identifies the first real producer.  If a future retail-machine mutation supplies the seed, it must occur after or replace Area 2's zero reset, retain the value for five Act-6 or 29 Act-3 sinks, explain why the first floor lookup misses despite the checked floor, make the displayed-position retry succeed, copy the result into Mario's collision position, and preserve it until the next star check.  Out-of-bounds writes, ACE, DMA, and execution after undefined behavior require that separate retail-machine model.  See the [Area-2 hypothetical](notes/area2-negative-quicksand-star-hypothesis.md), [conditional Coq proof](../proofs/Area2NegativeQuicksandStarHypothesis.v), [writable-table audit](notes/writable-action-table-mutation.md), [defined-producer proof](../proofs/NegativeDepthDefinedProducerClosure.v), and [negative-quicksand/dialog audit](notes/negative-quicksand-unreanchored-dialog.md).

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-20"></a>

### Mario behavior flag plus a large graphical Y offset

**Overall rank: 20. Family priority: 3. Likelihood: very low in the selected
in-bounds model.**

**In plain language.** Give Mario the generic object flag that copies raw
position to graphics with an added `oGraphYOffset`, and make that offset huge.
This could create the entire Ink gap at once.

**What is already known.** Object allocation clears the relevant words, Mario has no graphical-offset command, and its normal flag command enables bit 8 without changing dangerous bit 0.  The audit now follows the complete ordinary direct-call graph from all three Mario callbacks in both versions and finds no direct write to either word through any literal union view; it also narrows the current-object identity to the normal Mario spawn and list-traversal chain.  All forty stock graphical-offset commands elsewhere are fixed values at most `+240`, far below the generic `+632` timer-131 minimum.  A deliberately non-stock `+1160` value does make a warp-center retry succeed, so the normal stock-script/direct-helper route is disproved at this source boundary but aliasing, indirect or external code, forged behavior, and slot-lifetime failure remain possible escape classes.

**What closes it.** Prove through live execution that the traversed Mario node is still `gMarioObject`, its allocation epoch and cleared raw fields persist, behavior dispatch uses the checked table and script, and no indirect or defined aliased store changes bit 0 or the offset; give every reachable external an exact effect or frame, or exhibit the first valid counterexample store.  An out-of-bounds overwrite is outside this Clight close-out and would need a separate retail machine model.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-21"></a>

### Non-stock Graphics anchor or spawned anchor actor

**Overall rank: 21. Family priority: 4. Likelihood: very low for stock Area 1.**

**In plain language.** Some actors, such as Chuckya- or King-Bob-omb-style
anchors, can force Mario's rendered position to the actor's position.  A far
away actor could manufacture a huge graphical gap.

**What is already known.** The writer family is real and copies a child anchor's full rendered position into Mario, but the complete direct call chain belongs only to Chuckya and King Bob-omb anchor behaviors.  The audited SSL Area-1 regular list, macro list, and selected special presets contain neither parent; the generated C corpus has no direct parent reference, and the only static Chuckya reference is its global macro-preset table.  Loading the model is not spawning the actor.  This rules out the normal stock-root story, while forged behavior pointers, corrupted preset selection, and unclosed transitive or debug-spawn paths remain.

**What closes it.** Link the static selector result to the live behavior/spawn graph, preset indices, same-frame traversal, allocation, and receiver identity, including debug and indirect spawns; then either produce a clean Chuckya/King Bob-omb anchor descendant or prove that no live Area-1 object can acquire either parent or child behavior.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-25"></a>

### Shell visual offset plus wall/floor scheduling

**Overall rank: 25. Family priority: 5. Likelihood: very low alone.**

**In plain language.** Use the shell's small visual lift and a wall-selected or
cached floor to try to preserve and enlarge a Graphics gap.

**What is already known.** The stock shell offsets are around `+42/+45`, far
below `960`, and the normal behavior reanchors instead of accumulating them
forever.  Under well-formed non-aliasing state, a successful shell interaction
has no immediate Mario-coordinate write.  A failed contact pushes State X/Z
toward the stock radius-`89` boundary, but no total live-wall bound is proved.
Ground and air shell paths reset quicksand depth.  These effects have not
supplied the missing large gap.

**What closes it.** Linked live-range writer coverage can turn this into a clean impossibility result; a counterexample would need an unusual schedule, valid alias, or another mechanism that first creates most of the gap.  Ordinary platform or PU motion alone preserves an existing gap rather than creating one from a synchronized start, and turning-animation metadata also preserves the three positions.  A valid overlapping buffer remains an in-scope alias question, while actual asynchronous DMA is outside the current Clight execution and needs explicit machine or external semantics.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 3 — Local-Object/nonlocal-State (“State-first”) installers

These approaches leave raw Mario Object at the Area-1 warp while moving or
interpreting MarioState somewhere else.  The local Object caches the warp
interaction; the nonlocal State selects the top or another platform; later
copy/query code installs the pointer.

Technical background: [nonlocal endpoints](notes/area1-nonlocal-endpoints.md),
[post-copy mechanism matrix](notes/local-object-nonlocal-state-gap-matrix.md),
and [platform alias/external closure](notes/platform-alias-external-closure.md).

<a id="route-rank-3"></a>

### Finite signed-16 nonlocal-State alias

**Overall rank: 3. Family priority: 1. Likelihood: very low in the audited
stock model; only a narrow defined alias, dispatch, lifetime, owner, scheduler,
or outside-call escape remains.**

**In plain language.** Put MarioState one 65,536-unit period away while raw
Object stays at the warp.  The terrain code narrows the large coordinate to a
signed 16-bit value, wrapping it back to the timer-131 top.

**What is already known.** The coordinate wrapping works, and an injected JP run uses it to select and capture the top before reaching the upper trigger; a single platform update can also create the entire split from the synchronized warp centre by adding the right sideways motion and making a half-turn around a remote pivot.  The stock scheduler and surface-owner model cannot install that payload because the remembered platform is empty at the upper warp, and the new whole-game source check strengthens this result: each version has 28 named writers of the needed turn value, but following every direct helper call from all stock Area-1 surface owners reaches 93 functions and only one of those writers, the debris spawner, whose normal values are `3840` or `6400` rather than the required half-turn `-32768`.  CompCert also proves that casting an integer cannot fabricate a usable pointer for a successful write.  The six calls in this closed direct graph whose bodies are not supplied by the selected source program are now exactly `play_puzzle_jingle`, `create_sound_spawner`, `cur_obj_play_sound_2`, `set_camera_shake_from_point`, `sqrtf`, and `stop_sounds_from_source`; indirect or forged dispatch, object-slot replacement, a valid alias already present or returned by outside code, mistaken ownership, and unaudited scheduling remain open.  The injected run still supplies the split and starts the top artificially, so it is capability evidence rather than a clean route.

**What closes it.** A counterexample must now show one concrete defined escape that the new direct-call and integer-cast checks do not cover: a valid existing or outside-produced alias that writes the remembered-platform cell, an indirect or forged callback, object-slot replacement, a wrongly identified floor owner, movement after the final floor check or during a skipped check, an unchecked retained entry, or a scheduler path outside the audit, and it must carry the exact payload through one live execution; if any of the six named unresolved calls is actually reached, its exact memory effect must be supplied first.  An impossibility proof must connect each real Clight frame to the audited cases and eliminate those remaining choices, after which the route closes before its already-proved platform math runs.  Out-of-bounds pointer fabrication and MIPS continuation after undefined behavior remain outside that verdict and need a machine-level extension, and either defined outcome must still derive the top's activation and later lifecycle without the injected setup.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-5"></a>

### Post-copy State-only writer in a callback or spawned descendant

**Overall rank: 5. Family priority: 2. Likelihood: very low on the checked
clean run; no reached writer is known.**

**In plain language.** Near the end of Mario's turn in each frame, the game makes his movement position match the position used for object collisions.  This idea asks whether something later moves only one of those positions, leaving them apart when the next frame checks the warp.

**What is already known.** On the successful zero-A four-pillar run, a read-only audit followed all 2,462 frames from that copy through the remaining objects and into the next frame.  Mario stayed the same player object, the two positions matched after every copy, and neither position was written before the next platform update.  They also matched at every checked collision entry and return.  Thus no late object or callback creates this route on that run.  See the [Rank-5/5A intra-frame trace](notes/rank5-state-split-trace.md) for the technical receipt.

**What closes it.** A general disproof must show that every other reachable clean input history behaves the same way.  A counterexample must instead identify the first frame where Mario's copy targets the wrong object or one of the two positions changes afterward, then carry that disagreement into collision.  Out-of-bounds corruption and arbitrary code execution remain outside the current execution model.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-5a"></a>

### Pre-collision cached-platform displacement creates the split

**Overall rank: 5A. Family priority: 3. Likelihood: very low as a clean origin
on the checked run; the conditional effect itself is exact.**

**In plain language.** The game can remember which platform Mario stood on and move him with it at the start of the next frame.  If it remembered a useful moving platform here, Mario's movement position could shift before the warp checks his collision position.

**What is already known.** An artificially supplied platform can create the useful movement, so the effect itself is real.  On the successful zero-A four-pillar run, however, the remembered platform is empty at the platform step in all 2,462 frames and the moving-platform helper never runs.  None of Mario's three recorded positions changes during that step, and his movement and collision positions match at every checked collision entry and return.  At the three upper-warp platform checks, all three positions match.  See the [Rank-5/5A intra-frame trace](notes/rank5-state-split-trace.md) for the technical receipt.

**What closes it.** A general disproof must show that every other reachable clean input history also reaches each platform step without a useful remembered platform.  A counterexample must instead produce one clean frame where a real moving platform is remembered and moves Mario far enough before collision.  Fabricated pointers and continuation after out-of-bounds corruption remain outside the current execution model.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-13"></a>

### Raw-Object-only return or impulse writer

**Overall rank: 13. Family priority: 4. Likelihood: low as a proof
branch; no concrete gameplay writer is known.**

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-13a"></a>

### Terrain-dispatch or collision-prefix writer outside the platform phase

**Overall rank: 13A. Family priority: 5. Likelihood: low as a proof
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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-13b"></a>

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-18"></a>

### Skipped, wrong-index, or redirected State-to-Object copy

**Overall rank: 18. Family priority: 7. Likelihood: low.**

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 4 — Direct Area-2 gate crossings

These ideas try to cross the upper or lower pyramid barrier without first
installing a stale platform pointer.  The formal first-crossing classifier
keeps ordinary physics, platform displacement, object impulse, collision clip,
area reload, nonlocal cast, and same-position support change separate.

Technical background: [upper elevator cut](notes/area2-elevator-cut.md),
[lower target cut](notes/area2-lower-target-cut.md), and
[route exhaustiveness](notes/route-exhaustiveness.md).

<a id="route-rank-10"></a>

### Held-A jump-kick or B rollout from the upper elevator shaft

**Overall rank: 10. Family priority: 1. Likelihood: very low for the checked
vertical routes.**

**In plain language.** First complete the no-spin descent on the shaft line and
land on the live elevator.  From that landed state, use a no-new-A action to
get over or through the elevator-shaft wall.

**What is already known.** A held-A plus B jump kick is a genuine no-new-edge action, and B-only dive/rollout movement is real.  Exact replay checks all 32 jump-kick and 40 rollout collision samples; every normal sample remains below the elevator wall, with maxima of `134` and `224.5` against the strict `231` cutoff.  Wing-Cap preservation through the stock upper entrance is now disproved for a normal source-level execution: the Area-1-to-Area-2 warp reloads and reinitializes Mario, erases the Wing flag and timer, and SSL is not one of the three courses that immediately grants a special cap.  For comparison only, an impossible-at-stock-entry retained-Wing state would rise above the cutoff at exactly two samples, `234` and `232`, before returning to `230` and `228`; that narrow opening still does not prove that the correct wall is selected or crossed.  A hypothetical handler-table edit could make an upper coin or other matching interaction request an automatic action, but the new audit gives it no defined first producer once the private-table invariant is installed, and no useful in-elevator consumer, collision, or trajectory is proved.  The live descent, elevator landing and ownership, wall/floor choices, and ordinary action transitions remain unexecuted in the proof.

**What closes it.** Connect the checked stock warp, reinitialization, and non-Wing values to the same live Mario receiver, then execute the initial descent and every floor query through the intended live-elevator landing and connect every checked quarter-step to its live wall, floor, ceiling, action transition, and collision result.  That would eliminate the ordinary held-A and B-rollout vertical versions and leave horizontal clips or another named writer class to test.  A Wing version can reopen only by identifying a nonstock course or warp, a different live receiver, or another in-scope writer that grants Wing after reinitialization; merely arriving at the Area-1 entrance with Wing no longer suffices.  The table-triggered version is closed for successful in-bounds selected CompCert runs and can reopen only by refuting the accepted start/step relation or adding a separate retail-machine corruption model.  Either a live ordinary trajectory crosses the cut or this finite action/collision split becomes exhaustive.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-11"></a>

### Lower-aperture impulse, clip, or support switch

**Overall rank: 11. Family priority: 2. Likelihood: low in the current model,
but high conditional payoff under a correctly timed retail mutation.**

**In plain language.** Leave the second pole without A and cross the floor-ring aperture using a collision clip, object shove, moving support, a change in which floor the game selects, or—if a future machine-level exploit can edit the game's tables—a properly initialized long jump triggered after the ordinary climb.

**What is already known.** The exact pole top, ring, aperture, and target-side supports are imported, and the old normalized soft-bonk trajectory does not clear them.  The new hypothetical Coq proof checks the stronger two-word US/JP payload: redirect pole-handler word `45` to the compatible Snufit/damage handler and change the selected air/weak forward knockback word `3` to `ACT_LONG_JUMP`; the stock helper raises speed to `16`, the real setter produces horizontal speed `24` and vertical speed `30`, and five no-analog clear frames move the pole-top sample from `(0,4020,1331)` to `(0,4150,1216.25)`, inside the authenticated south target-air cell with zero A edges.  If the mutation is active before the climb, changing only the knockback word leaves the first grab alone but does nothing at the handstand, because the checked pole and top-of-pole bodies never read that table and the automatic actions use a direct switch rather than a top-specific writable table; changing pole-handler word `45` does have a consumer, but it catches the first eligible pole collision and replaces the stock grab.  A ground contact also selects word `0`, not word `3`; even granting a fully initialized long jump from the normalized Y-`3200` base, all 31 clear-flight states miss and the peak is only `3440`, while Y `3702` is the checked threshold whose frame-15 apex `(0,3942,1013)` reaches the target.  Thus an early edit needs a separate high contact, support, or recontact mechanism, whereas preserving the climb needs a timed post-grab handler write, another interaction found only at the top, or a broader ACE code patch that also supplies the required speed.  No such write exists in a successful in-bounds selected CompCert execution, and the live twenty-quarter collision replay and downstream star continuation remain unproved; see the [hypothetical pole-long-jump note](notes/hypothetical-pole-long-jump-mutation.md).

**What closes it.** For ordinary in-model motion, instantiate the current conditional Float32 collision-phase theorem with linked execution and an exhaustive pole-action exit split, then classify every impulse, clip, support, and external writer at the first target-side crossing.  For the hypothetical mutation, add a retail MIPS/hardware semantics and one continuous trace that identifies the two write addresses and values, proves whether the edit occurs after the stock grab or supplies an independently reachable contact at least as high as the checked threshold, resolves the exact direction/terrain/strength table cell, enters the normal long-jump setter, and shows all twenty quarter steps realize the clear kernel before connecting the target endpoint to the star suffix.  A mere static pre-climb pole-row edit, bare dispatch to `act_long_jump`, or CompCert-excluded ACE assertion does not inhabit that bridge.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-12"></a>

### Moving geometry or object impulse

**Overall rank: 12. Family priority: 3. Likelihood: very low after the stock
Amp wall/support composite was closed.**

**In plain language.** Use an actor that really exists in Area 2 to push, carry, shock, or reanchor Mario across a gate; the most plausible direct attempt is to lure a homing Amp to the second pole and have it knock Mario off without pressing A, while the remaining versions use a Grindel, moving wall, Spindel, or elevator as a changing support.

**What is already known.** The exact US/JP roster contains two homing Amps and one circling Amp, but no cannon, shell source, Tweester, Heave-Ho, Chuckya, Fly Guy, or jumping box; the scripted moving owners are the known Grindels, Spindel, four walls, and elevator.  The proof grants perfect Amp installation at the pole, then checks the payoff: shock contains no push, zeroes all horizontal motion, and calls the ordinary air step, which applies gravity after four collision quarters.  Mario is stationary for only the first shocked frame, then falls at the fixed pole centre and lands on the static Y-`3200` base on update 21.  The aperture walls are 101–103 units from the centre against radius-`50` queries, all six stock moving-owner corridors miss the pole disc (the closest is the elevator, still 513 units away), and the 820-unit pole-to-floor gap makes the final platform update clear any cached support before the fall.  Thus the formerly open stationary-shock plus wall/platform composite is disproved in the finite stock source model; see the [Rank-12 object-impulse audit](notes/rank12-area2-object-impulse.md).

**What closes it.** Retire the remaining ordinary branch by constructing and checking every step of a low-tier Goomba transport to a useful pole collision, or by linking the finite source model to a real Amp-lure execution and showing that every runtime object keeps its decoded home, axis, owner, and collision-list entry; the present geometry already closes that execution if those premises hold, while the first wrong position, surface, or owner would identify a concrete counterexample producer.  Stale, relocated, forged, out-of-bounds, or ACE-created supports are separate machine-level routes rather than unfinished stock wall/platform composites.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-12a"></a>

### Reload, nonzero warp destination, or same-position support change

**Overall rank: 12A. Family priority: 4. Likelihood: low as a coverage
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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-24"></a>

### Direct Float32 pole exit or pole avoidance

**Overall rank: 24. Family priority: 5. Likelihood: very low on current
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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 5 — Downstream collection of the two target stars

An installer or gate crossing is not enough.  These are the remaining routes
from a supplied Area-2 boundary to the actual target objects and save bits.  A
published lower-entrance video now shows both targets being collected in
separate one-A runs: the recovered full transcript places their sole displayed
press at the upper second-pole jump, so the post-pole downstream play is
visibly complete while input authentication and a no-A replacement for that
pole exit remain open.

Technical background: [Area-2 downstream continuations](notes/area2-downstream-continuations.md)
and [published lower-entrance video](notes/lower-entrance-downstream-video.md).

<a id="route-rank-7"></a>

### Join the Act-6 trigger, spawn, pickup, and save-bit traces

**Overall rank: 7. Family priority: 1. Likelihood: high once a valid gate
installer exists; this is not an installer by itself.**

**In plain language.** Touch all five Pyramid Puzzle trigger regions, make the
hidden star spawn, then overlap and collect it without a new A press.

**What is already known.** The five trigger locations are checked, one controlled JP run touches all five and spawns the star, and a separate controlled run collects it and records the correct completion flag; the published lower-entrance video supplies the missing continuous gameplay witness by visibly doing all of those things in one run.  The recovered full transcript identifies the sole displayed A press as the upper/second-pole jump—the third of five trials—and says the later Amp, Grindel, and elevator work uses no additional press; a new JP controller test creates exactly that one press, keeps the same press held without counting it again, and lands beside the real Grindel, but no `.m64` is available, the video's game version is unknown, the earlier route and Grindel mount have not been recreated, and the edited counter is not a raw input record.

**What closes it.** Obtain the `.m64` or recreate everything after the pole on a known game version with every input recorded, then show in that one run the Amp, Grindel, elevator, all five trigger regions, star spawn, pickup, and completion flag with no new A press; a complete zero-A route must separately replace the second-pole jump or reach the far side another way.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-8"></a>

### Lower Act-3 100-coin-star/Grindel itinerary

**Overall rank: 8. Family priority: 2. Likelihood: high as a conditional continuation; the one displayed pole-jump press remains.**

**In plain language.** Start at the lower pyramid entrance, clip onto the mesh and reverse the teleporter, use the 100-coin star dance at the big steps, make the route's one ordinary jump from the upper second pole, use the homing Amp at the later ledge, then use the Grindel and undescended elevator to cross to the Act-3 platform and collect the star without another A press.

**What is already known.** The published video visibly performs the complete lower-entrance route in a single run, beginning with 95 coins, collecting the 100-coin star, jumping from the upper second pole with its sole displayed A press, continuing through moving-platform play, and collecting Act 3 with no further displayed press; the recovered full transcript fixes the exact five-trial order and confirms that the Amp clip and Grindel/elevator tricks come after the pole and cost no extra press.  A new JP controller test reproduces the pole jump with exactly one press, keeps that same press held without counting another, and lands beside the real Grindel; its tested approach has not yet mounted the Grindel, the `.m64` remains unavailable, and the footage does not reveal exact inputs or collision details.  The checked star geometry also shows that simply standing below the star leaves Mario `75` units too low.

**What closes it.** Obtain the `.m64` or continue the known-version input reconstruction through the homing-Amp ledge grab, the Grindel's one-unit corner, the undescended elevator's matching corner and descent, and the final star pickup with no new A press; then either leave the second pole without A or connect another clean crossing directly to the recreated state beyond it.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-9"></a>

### Upper Act-3 100-coin/star-dance itinerary

**Overall rank: 9. Family priority: 3. Likelihood: low-medium.**

**In plain language.** Spawn the 100-coin star near the Act-3 platform, store the upward part of a rollout, reactivate that vertical speed, collect the 100-coin star with a ground pound, use the star dance for a ledge grab, and roll into the Act-3 star.

**What is already known.** This is the transcript's specified upper route, and the target/support geometry is checked; simply standing on the checked floor under the Act-3 star misses its hitbox by `75` vertical units.  The new video demonstrates a different lower-entrance continuation and therefore does not authenticate this upper itinerary, which still has no cut-starting replay.

**What closes it.** Prove the 100th-coin timing and placement, rollout-speed storage and reactivation, ground-pound and star-dance transitions, ledge collision, final star overlap, and Act-3 bit update in one linked zero-edge suffix.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26"></a>

### Negative-depth transport to a fresh or older star

**Overall rank: 26. Family priority: 4. Likelihood: very low.**

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 6 — Goomba raising and PU transport

Technical background: [Goomba raising](notes/goomba-raising.md) and
[nonlocal endpoints](notes/area1-nonlocal-endpoints.md).

<a id="route-rank-16"></a>

### Goomba H/F/R raising, PU capture, and Spindel handoff

**Overall rank: 16. Family priority: 1. Likelihood: very low as a full route.**

**In plain language.** Repeatedly raise a Goomba with a hit-and-depart, far
reset, and near rearm cycle; then try to use a parallel-universe coordinate
alias, capture the object in the useful segment, and hand the setup to Spindel
or another moving object.

**What is already known.** The H/F/R primitive and binary32 velocity arithmetic are real, but full-float object distance means that a PU alias neither transports the Goomba nor keeps a distant Spindel loaded.  The original post-collision schedule permits only `31` useful rises in the accepted `91`-frame top window, and the formerly open raw-Object timing still has to alternate a non-rising return/reset frame with a rising departure frame: its exact return-first form permits `45` rises, while a deliberately more favorable phase shift permits `46`, reaching exact binary32 Y=`1017` from Y=`51`, still `774` below Y=`1791`.  Thus both finite top-window timing classes are refuted even if their coordinate writers are granted for free; physical singleton transport, same-segment capture, repeatability, longer independent timing, and every handoff remain unconstructed, while failed nonfinite casts trap rather than produce a continuing coordinate.

**What closes it.** A counterexample must now leave the checked finite timing family by supplying a clean longer raising interval or a defined action, FAR-state, velocity, or scheduling effect that can produce rises more often than every other frame, then keep the same live Goomba through physical PU transport, moving-collision capture, every handoff, and a target-star continuation; an impossibility result must rule out those departures and the remaining transport and handoff obligations, since finding either raw-Object writer alone no longer rescues the `91`-frame top proposal.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 7 — Eyerok and Area-3 manipulation

Eyerok is mainly a proposed gateway to Act 3 through Area 3 and back into Area
2.  Eyerok's own boss star is source index `3`, not either target, and there is
currently no modeled Eyerok-to-Act-6 continuation.

The active project imports only narrow facts from the archived Eyerok work.
Most results below are substantial conditional or source-shaped evidence, not
linked retail executions.  See [archived proof evidence](notes/archived-proof-evidence.md).
The detailed historical experiments are in the clearly archived
[Eyerok notebook](../../old-proofs/eyerok-manipulation/Eyerok.md).  A new
[controller-manipulation map](notes/eyerok-controller-manipulation.md) checks
the exact movement-sensitive state-machine choices in both generated versions:
Mario can deterministically request a tracking hand in a narrow Z strip, steer
its chase, hold and release the alternating double-pound loop, choose sweep
direction, and place a two-hand formation in Z, but movement cannot directly
choose the active side or force fist-push independently of RNG.  A paired
hash-authenticated US suffix now reaches the deterministic strip, chase, and
both sweep signs with no A poll or post-boundary write; the forward sample
falls from the arena edge, while the grounded mirror pushes backward in Z and
never makes the hand Mario's floor owner or platform.

<a id="route-rank-14"></a>

### Carry a stale Eyerok-hand address into Area 2 in JP

**Overall rank: 14. Family priority: 1. Likelihood: retired in the audited stock model; reopening it requires a failed source-to-execution premise or machine-level behavior outside that model.**

**In plain language.** On original JP, this idea tried to make Mario remember the static tunnel warp as his floor while separately remembering an Eyerok hand as the moving platform, so that after the warp unloaded the arena the game would apply one Area-2 object's movement through the old hand address.  Both the far-away magnified version and the ordinary version under the warp are now blocked in normal stock play.

**What is already known.** A natural JP warp remembers no hand, while forced sleeping-hand comparisons move Mario by `(0,0,0)`; destroying a hand can align its old address with Area-2 allocation 53 or 54, but every checked replacement is motionless except Spindel, whose exact effect is only about 8 down and 38 backward.  Installation at the warp requires a hand floor in `[-569,-411]` or `[608,766]`, yet fist-push remains far too low (and both tested central cases also stop before the warp), while one-hand eye-show crosses the warp with its top only at `-1027`; even granting the hand's largest hit-induced rise reaches only `-739`, still 170 below the lower band, and target and double-pound rises remain horizontally short.  The other hand cannot arrive later in the required state, SSL Area 3 has no later object that moves Mario between the two samples, an unreused dead-hand slot has zero useful motion, and the separate far-away version is already disproved by its support, transport, dialog, and raw-distance checks.  See the [original-JP stale-hand audit](notes/jp-eyerok-stale-hand.md).

**What closes it.** The route is closed within the audited stock source-shaped model; a full formal verdict now needs the real linked execution to be shown to follow the checked hand-pose, sibling, writer, and lifetime classification.  A concrete failure of that connection—such as a hand pose outside the stock split, an unexpected later Mario-position writer, or nonzero bytes surviving in the freed slot—would reopen one exact case and make the small Spindel displacement worth testing, while out-of-bounds writes, ACE, DMA, and continuation after undefined behavior remain outside the current execution model and require a retail-machine extension; Eyerok still supplies no Act-6 continuation.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-15"></a>

### Board and ride a raised hand into the lower route

**Overall rank: 15. Family priority: 2. Likelihood: medium as a proved local primitive, very low as a full route.**

**In plain language.** Hold A before boarding, stand idle on the real Eyerok hand, and press B once just before its double-pound rise; the game turns that ordinary B press into a jump-kick without a new A press, allowing Mario to catch and ride the hand upward, although the hand still stops far below the tunnel.

**What is already known.** A hash-checked North-American retail run starts from game-confirmed ownership on the real hand and uses one B edge with A already held to perform idle to punching to jump-kick without a new A edge, catch the hand, and ride its six upward steps to Y `-943`; jump-kick replaces vertical speed with `20`, every favorable conserved seed through `31` still fails, and none of the `181,944` generous finite boss/two-hand/effect cases manufactures seed `32`.  Both generated versions contain only the checked vertical writers, all positive episodes fit a `288`-unit rise budget, every upward static floor is at or below `384`, and the complete scaled hand top is `507`, so even one hand standing on the other plus an excessive `630`-unit Mario rise reaches only Y `1809` below the required query height `1889`.  The active bridge now authenticates left-before-right spawn requests and the separate velocity/clamp/position stores, reads both concrete slots' poses, actions, floors, owners, behavior, active flags and list links from CompCert memory, proves their observed bytes disjoint, follows the live SURFACE-list path, makes deletion absorbing, and requires a real selected-program task-entry prefix; therefore a constant projector, detached fake objects, silent same-slot resurrection, or one-envelope-step-per-store argument is no longer accepted.  See the [controller-authentic ride, VSC, schedule, dynamic-support, and live-projection audit](notes/rank15-eyerok-controller-ride.md) and [controller-manipulation receipt](notes/eyerok-controller-manipulation.md).

**What closes it.** Construct the now-defined connected Clight chunks from ordinary controller play and classify every endpoint transition as a checked direct pose, landing, bounded rise, nonrise, wait, or deletion, while computing the complete transitive outside-call inventory and proving reachability plus exact protected-slot effects for every call that really executes; the first generated roots authenticated here include `cur_obj_play_sound_2`, `create_sound_spawner`, and movement's `sqrtf`, with the spawner requiring a checked distinct allocation rather than a blanket frame, but the earlier task-entry/spawn prefix may contribute more.  If every chunk passes, the promoted barrier closes all seven upward classes in one live execution; if one fails, report its recorded X/Y/Z pose, floor pointer and owner, left/right list links, changed cell or callback, active/behavior identity, or before/after state as the concrete counterexample candidate.  A positive route must exploit that exact failure or authenticate a separate incoming seed of at least about `32`, then pass the wall, horizontal, hand-to-warp, and Act-3 continuation checks; Act 6 remains separate.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-22"></a>

### Second-hand ceiling to the Area-2 Y=1280 tier

**Overall rank: 22. Family priority: 3. Likelihood: very low under the checked
height and speed bounds.**

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-23"></a>

### Update-11 wake-sandwich Pedro installer

**Overall rank: 23. Family priority: 4. Likelihood: very low.**

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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-28"></a>

### Attack and reboard a rising hand

**Overall rank: 28. Family priority: 5. Likelihood: very low.**

**In plain language.** Hit an Eyerok eye, make its hand rise, then fall back
onto or reacquire its moving collision before it returns or disappears.

**What is already known.** Standing on either hand top is above the eye
hitbox, so the simple “stand, attack, ride” plan fails.  Tested nonlethal
reboarding needs an injected prior long-jump and happens only after return
home; tested lethal rises never select the platform before deletion.

**What closes it.** Authenticate or refute the nonlethal predecessor and its
earlier A edge; generalize the lethal pose/steering search; and, if reboarding
succeeds, prove the hand-to-warp and Act-3 continuation.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-29"></a>

### Sleeping-hand Pedro speed bootstrap

**Overall rank: 29. Family priority: 6. Likelihood: very low.**

**In plain language.** Build enough speed without pressing A to cross the sleeping hand's narrow outer wall in one movement step and land in the small space between its floor and ceiling.

**What is already known.** The crossing needs a quarter-step over `100`, which means directional speed over `400`; an injected speed of `424` proves the landing works but does not supply that speed cleanly.  The [Rank-29 preload and cycle audit](notes/rank29-sleeping-hand-preload.md) checks both game versions and shows that normal entry clears old speed, the Area 2/Area 3 warp only preserves existing speed, the complete stock roster has none of the usual large-speed actors, and a sleeping hand skips the attack check that could bounce Mario; ordinary air growth would need `1,934` uninterrupted frames, while the generous episode bound allows fewer than 400 and reaches only speed `170`.  The former reset-evading-cycle residual is also finite now: all five moving-collision owners reload their mesh, carry never changes forward speed, their largest possible one-frame Y change is `78` rather than the strict greater-than-`100` needed for `OFF_FLOOR`, ordinary landing damps before any ground-step departure, steep-floor push replaces speed with `16`, Area 2 has no burning collision, and the only preserving flat butt-slide-air bounce consumes state zero and cannot repeat without returning through the speed-`100` ground-slide normalization.

**What closes it.** The ordinary stock cycle is closed in the source-shaped owner model; a counterexample must now show the first live frame where that model fails—such as a stale or wrong floor owner, skipped collision reload, non-stock inserted surface, forged action/state, valid alias, or specified outside effect—then repeat the resulting preserving transition to speed over `400` and carry it through the instant warp to the proven hand landing.  A continuous live-trace proof that ownership, collision reload, action state, and collision data remain stock would instead import the finite closure and finish the successful in-bounds case, while an out-of-bounds write or post-undefined-behavior continuation is a separate machine-level extension.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-30"></a>

### Seams, moving boundaries, or partial updates

**Overall rank: 30. Family priority: 7. Likelihood: very low.**

**In plain language.** Slip between moving collision pieces, or find a frame
in which action state changes but hand movement or collision only partly runs.

**What is already known.** The exact positive-double sibling approach has no
sample that is both horizontally and vertically eligible.  In the modeled
no-external-writer lifecycle, a live hand cannot enter the movement-only
partial-update guard.  Other seams and transformed phases are not exhaustive.

**What closes it.** Enumerate every transformed hand mesh and phase, moving
boundary, wall response, partial-update flag writer, and external effect in
linked execution.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

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

The defined cases are necessary for proof exhaustiveness but currently poor
gameplay leads; a concrete valid witness would immediately move one much
higher.  Machine-only cases are recorded separately so their absence from
Clight is not mistaken for a retail result.

<a id="route-rank-31"></a>

### Defined memory/control escapes and deferred machine-only corruption

**Overall rank: 31. Family priority: 1. Likelihood: very low as a known clean
route; high proof importance.**

**In plain language.** Make a valid pointer name the wrong live field or object, have a reachable outside routine change protected state, retain a stale warp collision, alter a hitbox, or forge an action, timer, or owner through an otherwise valid game write.  Out-of-bounds overwrites, arbitrary code execution, and raw DMA are tracked here only as deferred retail possibilities because the current source execution cannot perform them.

**What is already known.** A defined one-store State/Object divergence must target one endpoint block, so a different CompCert allocation cannot wrap into it; direct platform writers are censused, collision-cache and hitbox observations have explicit escape classifiers, capacity guards can drop collisions but do not invent one, and animation metadata preserves Mario's coordinates.  For the writable action tables, all 38 modeled units per version contain no initializer or export alias, every body occurrence is a final read, the three expected linked blocks are valid at initialization, and ordinary level transitions do not name them; the completed reached-execution theorem constructs a relation that leaves those blocks private and carries it through every actual Clight step and outside call in every finite successful selected run without changing a table byte or returning a table pointer.  Valid same-block aliases to other state, wrong logical object slots, stale pool bytes, known-function retargets, and outside-call effects on public or passed state remain possible in Clight.  By contrast, a successful invalid load/store, invalid function target, ACE continuation, post-undefined-behavior MIPS behavior, DMA, interrupt, or self-modifying-code effect has no witness in the current Clight run; that absence is a model limitation, not a retail disproof.  No clean in-scope corruptor is known.

**What closes it.** The writable-table part is closed in the selected successful in-bounds Clight model; the remaining in-scope work is to prove live pointer/block/offset provenance for the other protected stores and link same-frame collision clearing, traversal, owner return, hitbox writers, and object-pool epochs, with any failure identifying the exact valid store, call, cache entry, or field.  For the deferred part, first add a retail MIPS/hardware execution model with the RAM layout, devices, interrupts, selected-binary connection, and explicit post-undefined-behavior rule.  Until then, report out-of-bounds, ACE, and DMA variants as outside the current model rather than open Clight obligations or disproved routes.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-32"></a>

### Castle-to-SSL glitch or retained inbound pointer

**Overall rank: 32. Family priority: 2. Likelihood: very low and intentionally
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

[Back to the at-a-glance ranking](#at-a-glance-ranking)

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
| Goomba R1 | Original post-collision Goomba H/F/R schedule reaches the target height | It permits `31` useful hits where `83` are required. | A longer independent interval or a state-machine escape. | Closed for that schedule. |
| Goomba R2 | Revised raw-Object timing reaches the target within the same top window | Return/reset cannot rise, so the exact schedule permits `45` rises; even granting a productive first frame permits `46`, ending at Y=`1017`, `774` short. | A longer independent interval or a defined action/FAR/velocity/scheduler effect outside the two-phase quotient. | Closed for the accepted `91`-frame timing class. |
| Animation/HOLP R1 | [Turning action `0xBD`](notes/turning-animation-upwarp.md) creates a 189-unit rise | The relevant normalization is `189/189 = 1`; metadata preserves position. | A defined overlapping-buffer writer; raw DMA is outside the current execution model. | Closed as arithmetic. |
| Animation/HOLP R2 | Turning/HOLP moves Mario through the rendered hand matrix | The matrix can update `heldObjLastPosition`, but turning drops held objects first; HOLP affects a later drop/throw, not Mario's gameplay position. | A proved held-object survival path, defined buffer overlap, or later machine-level DMA model. | Very low. |
| Ink R1 | Shell `+42/+45` graphics offsets accumulate forever | Normal frames reanchor them. | A proved skipped reanchor or alias schedule. | Very low alone. |
| Ink R2 | Fire-particle `prevObj` moves Mario | It moves the flame object, not Mario. | Only a receiver-alias proof failure. | Closed under normal receivers. |
| Ink R3 | A direct stock Area-1 door supplies the automatic-dialog route | No direct Area-1 macro/script door root exists. | A transitive spawn/interpreter/debug route to a suitable dialog actor. | Very low as a direct root. |
| Held-object R1 | A carried box remains a useful moving collision platform | Carry scripts disable or lose the needed collision. | A different object with proved collision retention. | Very low for the box. |
| Held-object R2 | Pickup can beat the warp interaction at node `0x1E` | Handler order gives the warp interaction priority. | Retargeted handler table, stale collision cache, or corruption. | Very low under normal dispatch. |
| Held-object R3 | Obtain `heldObj == node 0x1E` through enumerated stock pickup or stale-held-slot paths | The counterfactual drop would relocate the live entrance, but audited stock paths do not produce that held pointer. | A concrete new held-pointer or behavior-provenance exploit; Rank 4 now retains only its different-history universal residual. | Very low for enumerated paths. |
| Lifecycle R1 | Direct Area-2/Area-3 instant warp adds height | Its displacement is zero and coherent kinematics are preserved. | A stale-platform, receiver, or lifecycle effect classified separately. | Closed as ordinary warp displacement. |
| Lifecycle R2 | Reload or the wrong star directly sets a target bit | Coherent reload preserves save facts; Eyerok/100-coin/other stars have different indices. | Explicit save corruption or target-provenance failure. | Closed under certified provenance. |
| State-first R1 | Area-1 palm/tree pole push is a late State-only writer | It executes before PLAYER; the later correct copy resynchronizes State/Object. | A later transitive caller or a failed/redirected copy. | Closed for that caller/order. |
| Object impulse R1 | Tweester or jumping-box search already found an installer | Bounded searches found synchronized elevation but no positive view gap, warp/top capture, or target crossing. | A different live object-impulse chronology; keep it under rank 12. | Very low for tested schedules. |
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
