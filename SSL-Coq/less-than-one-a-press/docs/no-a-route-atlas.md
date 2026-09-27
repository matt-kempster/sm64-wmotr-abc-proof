# No-A two-star route atlas

> Status snapshot: 2026-09-27.  Rankings are intentionally revisable as linked
> execution evidence or new counterexamples arrive.

The [23 September family workboard](notes/glitch-family-workboard.md) groups all 45 ranks into 11 shared gameplay investigations, with separate workstreams for downstream collection, proof contracts and a different start. Each gives the affected ranks, a first compute batch, and the limited conclusion that would justify stopping. The grouping adds no new proof or search result and leaves the route verdicts and subjective estimates unchanged.

The [25 September Wafel pilot](notes/wafel-testing-review.md) now reproduces the known JP replay: 2,483 Area-1 snapshots match the checked position/action/support/top-slot fields with a separately checked +1 global-timer mapping. Five controller-only three-second choices produce no sampled split; one changed branch also matches 2,442 emulator snapshots, including the 90 restored-state outputs. No A was used. This validates one bounded test adapter, not every timer-dependent history; the existing exact warp observer remains necessary. No proof verdict or route estimate changes.

The [27 September controller search](notes/rank1-reachable-search.md) starts around the fourth-pillar trigger, before the earlier pilot. Across 132 controller choices it finds no sampled upward gap. Four exact JP replays check 983 first geometry queries, with no failures or retries, and 983 ownerless final floor results. A new Crazy Box arrival accepts with all three positions at Y=816, finishes at Y=768, and enters Area 2 with no retained platform or Ink displacement. This is finite evidence, not an all-history exclusion; Rank 1 stays at 1–2%.

The approved [first backward predecessor search](notes/rank1-backward-search.md) now runs on actual generated US/JP statements. For the checked top height, it derives a final raw-Y band of 1934.864990234375 through 1942.86474609375; reversing the ordinary copy requires State Y in that band, and reversing the floor-snap helper requires the cached floor height in that band. A high old display alone cannot satisfy that snap condition. The selected retry still needs a null first floor result and a high display at its copy. Calls and the connections between these checkpoints remain open; the tool does not assume their memory effects, reconstruct complete previous frames, or establish controller reachability. Seven tests and the local solver checks pass, alongside a fresh selected audit of the unchanged Coq boundary. The proposed longer search considers all allowed inputs before top retention. The [five-versus-thirty-second comparison](notes/rank1-input-search-size.md) gives 150 or 900 nominal updates: unpruned enumeration grows as K^150 or K^900 for K choices per update. Even two choices over five seconds give about 1.43 × 10^45 sequences. Five seconds is a smaller target for symbolic grouping and justified pruning, but its actual cost remains unknown; neither horizon has been searched exhaustively. This is exploratory tooling, not a new Coq or whole-route exclusion; all route estimates and verdicts are unchanged.

The first [input-grouping implementation](notes/rank1-input-grouping.md) retains exact controller values and held-button history. **The requested one-update backward search remains unfinished.** A narrower [supplied-scene update and reverse check](notes/rank1-complete-update-path.md) does complete in both US and JP, from sampled controller pads through the real level scheduler, live Mario callback and actual final floor selection. The first lookup misses at Y=768, the display retry finds the checked top, and both platform pointers retain it. The raised display, disappeared action, stopped top and finite floor list were supplied; this test does not find how gameplay could create them or establish a newly accepted warp. After the broader solver attempts failed to finish, the checker followed this chosen scene and reversed its path. It checks exactly 225 neutral-stick encodings with the other entry bytes fixed; all 36 application tests pass. These results are useful application checks, not a finished predecessor search. Other paths and longer windows remain open; no new Coq theorem or route exclusion is claimed. Rank 1 stays at 1–2%, with all other verdicts and estimates unchanged.

The [gap review](notes/ink-gap-backward.md) now separates the 20 reviewed entries into six scoped insufficient cases, five helpers, four concrete unresolved producers, four other-context/lookalike cases and one ownership question. They are not 20 independent open gap producers. The site's five helper cases carry purple “Helper only / not a gap source” banners: set them aside while seeking the original height gap, then revisit them if a producer needs their consuming, sideways, preserving, transferring or query-only role. This is a role label, separate from green Already proved. There is no stock pole beside the Area-1 top warp: the palm tree is distant, while the two regular poles belong to Area 2. The checked Area-1 static mesh and pyramid top have no hangable triangles. These stock-data/source distinctions do not become new Coq or all-history impossibility results; the existing ground-copy and Tweester-copy insufficiency proofs retain their precise checkpoints.

The [Reverse Scattershot review](notes/rank1-reverse-scattershot.md) distinguishes a proposed randomized search from the unfinished one-update implementation. Sampling valid predecessors could prioritize promising paths, but cannot supply missing callback semantics or turn failed trials into impossibility. The practical witness-search recommendation is to reuse controller-reached Wafel states, guide branches with backward requirements, preserve several timing/support alternatives and validate any complete replay. No new search was implemented or run, nothing moves to Already proved, and all 45 estimates remain unchanged.

The [search-interpretation review](notes/rank1-search-interpretation.md) keeps the working supplied JP installation separate from its missing gameplay producer. A timeout or empty sample does not exclude a route; a complete bounded search excludes only its covered domain, while a proved contradiction at a required checkpoint can close a whole named approach. The 1,170.864868-unit example is not a universal minimum. The user has deferred the requested one-update search for this review, and no new run or proof is claimed. Three and five seconds mean 90 and 150 nominal updates; one-depth timing alone cannot price their exhaustive searches. All route verdicts and estimates remain unchanged.

## Purpose and scope

This document is the readable inventory of ways the project currently knows
to pursue the two target stars without a new A-button press.  It complements
the [open checklist](checklist.md): the checklist says what proof obligation is
next, while this atlas says what the gameplay idea is, what has already been
learned about it, and why it is or is not worth more search time.

The [Fine Print review](notes/fine-print-proof-promotions.md) includes the
conditional stock negative-seed argument with the proved results. Its listed
conditions are the accepted stopping point for that seed claim; proving they
cover every allowed gameplay history remains a separate extension.

Every ranked entry now separates **Conditional Impossibility Result** from
**Full Impossibility Result**. The first names the case actually excluded and
its conditions, and says whether that is enough for the proposed mechanism.
Where there is only a source check, finite trial, supplied success or scope
restriction, it says so instead of inventing an impossibility theorem. The
second states the additional work needed to exclude the whole entry across
allowed histories. “Full” retains the agreed start and defined, in-bounds
execution model; it does not require a castle-entry or outside-model hardware
proof. Closing one entry would not close every other route. This reporting
review adds no Coq proof, accepts no further assumption packages and changes
none of the subjective counterexample estimates.

For the shared proof gaps that affect many routes at once, see the
[plain-English guide to the hardest obligations](hardest-obligations.md).
For what the final impossibility argument actually uses, which local results
are available to reuse, and which connections remain unproved, see the
[impossibility-proof progress ledger](impossibility-proof-progress.md).

### Authoring rule

Keep this atlas non-technical and centered on what has actually been proved or
disproved. Every ranked approach must have exactly six labeled sections:
**In plain language**, **What is already known**, **Conditional Impossibility Result**,
**What closes it**, **Full Impossibility Result**, and **Are counterexamples likely?**
Each section must be one paragraph only. Keep
the likelihood paragraph consistent with the table's rough estimate and name
the missing clean setup; an unfinished proof is not evidence of a route.
Prefer ordinary gameplay language over theorem, source-code or memory-model
terminology, and put exhaustive detail in the linked notes or checklist.
The conditional section must name what is excluded, its conditions and whether
it suffices for this entry. The full section must identify the missing live
connection or wider coverage; do not replace it with “prove everything.” Keep
accepted conditional stopping points separate from those optional extensions.

For downstream continuations, name the unresolved gate before describing the
payoff. Never treat a start beyond that gate as evidence of a no-A bypass.
When work is paused for that missing prerequisite, mark the continuation as
parked. Keep conditional results separate from progress on removing the
required A press.

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

This covers the approaches named in the active project and its audited
archives, including the new [ordinary-gameplay coverage review](notes/ordinary-gameplay-route-coverage.md).
It is not an exhaustive proof of every controller-reachable route: a broad
collision or scheduler category does not mean all of its gameplay uses have
been tested.  This review investigates ordinary behavior and defined,
in-bounds execution only; historical ACE, out-of-bounds, and arbitrary
memory/code modification ideas remain deferred, outside-model entries, not
methods being developed or retail possibilities that have been disproved.

## How to read the rankings

The **overall rank** combines three things: counterexample promise, how much of
the mechanism has been observed or checked, and how decisively the next result
would affect the main theorem.  The **family priority** compares only related
ideas.  These are research priorities, not numerical probabilities.
Lettered ranks such as `5A` place a tightly related subroute immediately after
the numbered route without obscuring the stable top-level ordering.

**🎮 means that the route still needs same-history execution coverage or an
exhaustive classification of its reachable cases before a general exclusion
can be claimed.** This is the shared-coverage work discussed with the proposed
producer classifier. It does **not** mean a literal brute-force controller
search is required, already exists, or would necessarily finish the proof:
an inductive invariant or a justified finite case split may discharge it.
A narrower conditional exclusion can instead state explicit gameplay
contracts and leave their applicability open; it must not assume the very
behavior it is meant to exclude.
Checking a finite sample of controller histories is not enough without a
proved bound or coverage argument. Different marked routes need different
classifiers; completing the negative-depth classifier alone would not close
all of them.

The marker appears beside the approach in the ranking table and its detailed
heading. It marks 41 of the 45 ranked entries because most surviving routes
share this missing live-execution connection; it is not a likelihood rating
or a statement that all other setup work is finished. **7, 8 and 9** instead
need a particular downstream continuation after a separately supplied bypass,
so they are unmarked; **32** changes the starting boundary and is deferred.
For **14**, the marker refers only to extending the existing stock disproof
to live execution; for **31**, only the remaining defined cases are marked,
not the closed action-table case or deferred outside-model possibilities.
The unranked retired/corrected tables retain their settled local verdicts:
broader execution gaps or proposed reopenings belong to their marked parent
routes, rather than turning those settled mini-cases into new searches.
Keep table and heading markers synchronized when a route's status changes.

Likelihood and status labels mean:

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
- **Parked:** supporting work awaits an unresolved prerequisite; this is not
  a disproof. Its existing rank and links remain for reference, not as a
  recommendation to pursue it before the prerequisite.

No single item below currently supplies a complete clean route to either
target.  A successful counterexample for one target needs all three layers:

1. reach the needed target/secret contacts with zero new A edges, either by
   crossing an Area-2 gate or by a route that avoids the usual gate entirely;
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
- **The high-payoff retained-top design is JP-only, and its known clean schedule fails:** a
  complete zero-A four-pillar and upper-warp run never remembers the spinning
  top and produces no useful positive split; another schedule would have to
  break a precisely checked query, owner, alias, outside-call, or lifecycle
  boundary before the old JP pointer can help.
- **Four ordinary-gameplay questions now have explicit entries:** spending the
  100-coin star at a gate (9A), ground-pound startup with moving geometry
  (10A), touching a secret or star across a barrier (12B), and Puzzle progress
  across area revisits (7A).  Their source mechanisms exist, but no new clean
  bypass has been demonstrated; their promise is low or very low.
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
  retry now has recorded conditional JP elevator bypasses from both the
  supplied midpoint and vertical-only setups. The latter starts idle, selects
  the live top, and retains it through the explosion and warp without A.
  The current question is how gameplay creates the display gap and a failed
  first floor lookup before the display is refreshed. Clean creation remains
  open. The current F02 target is now fixed at the accepted upper-warp
  interaction return, still in Area 1, with position disagreement and
  subsequent platform capture reported separately; see the
  [chosen checkpoint](notes/f02-warp-acceptance-target.md). The first batch proves
  the final action call preserves the positions it receives; the clean JP
  replay has no gap at that return and no final capture. Earlier creation
  and the all-gameplay question remain open. The new
  [whole-game position-split catalog](notes/position-split-catalog.md) separates
  27 mechanisms and supporting cases. Checked stock-selector exclusions prune
  foreign actors, while SSL's own platform, push, water, cannon, shell and
  dialog mechanisms still need their timing and copy arguments. This is not
  yet a complete live-write classification; route estimates stay unchanged.
  The catalog and Fine Print Section 01 now mark seven groups as **ruled out
  from the checked stock spawn lists**: Chuckya/King Bob-omb, Dorrie, the two
  tilting pyramids, Hoot, the named launch enemies, whirlpools and butterflies.
  The other 20 cases remain separate. This makes existing exclusions easier
  to find; it does not claim those actors are impossible under every later
  object-creation history or close a whole route. The new
  [backward sizing pass](notes/ink-gap-backward.md) reviews all 20 catalog
  cases against the supplied 1170.864868-unit gap. A proved shortfall now
  counts as **Insufficient — already proved** for its stated conditions and
  checkpoint: the normal Tweester copy and completed ordinary ground copy
  qualify with zero gap. This target is specific to the supplied setup, not
  a proved minimum for every Ink route; finite/source shortfalls retain
  their separate evidence labels. A new US/JP proof shows
  that the normal Tweester continuation reaches a copy with equal movement
  and display Y, even after its internal floor query misses. Its ejection
  branch and later changes remain separate. Shell and the checked single-refresh
  water offsets are too small alone; large retained downward moves and
  the negative-depth/dialog producer remain open. Warp transport waits for
  a viable producer, and the route estimates stay unchanged. The new
  [Tweester transport check](../instrumentation/tweester-transport/README.md)
  leaves rapid home oscillation to the warp open: the tested schedules fail
  before useful contact, while a relaxed western-ledge pose passes only a
  conditional hitbox test. Ordinary ejection refreshes display through its
  air step, and an accepted warp prevents a later Tweester interaction in
  that same handler loop. No clean producer or whole exclusion is claimed.
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
- **Ordinary enemy damage has a confirmed lower-gate payoff:** an explicitly
  relocated Goomba knocks Mario from the second pole onto the upper ring with
  zero A, retaining the full handstand height; ordinary holding also works.
  The nine-Goomba finite graph finds no installation under its short-transfer
  rules. Coverage of longer airborne movement, hard-fall rebounds and repeated
  pushes remains unproved, alongside H/F/R and other support changes.
- **Act 3 is the main downstream gap:** the upper and lower itineraries are
  specified and source geometry is checked, but neither has a cut-starting
  linked replay.
- **Rank 9 is parked behind the upper-elevator barrier:** its star-dance
  continuation assumes Mario is already outside. Even a complete continuation
  leaves one A press if the ordinary elevator jump is used; prioritize a
  clean no-A escape before extending this downstream work.
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
  search is now a memory-backed execution classification: one actual
  position-update case is constructed, while the remaining poses, floors,
  lifetimes, scheduler steps, and outside-call effects still need proof.

<a id="at-a-glance-ranking"></a>

## At-a-glance ranking

The percentages are **rough subjective judgments**, not measured odds,
statistical confidence intervals or formal bounds. They estimate whether the
named approach could supply a complete clean no-new-A counterexample for at
least one target under the agreed start and model, not whether an isolated
effect works or the next test succeeds. A range such as 2–5% means a weak but
concrete lead; <1% means a particularly weak lead, not a proved probability
bound. Routes overlap, so do not add or multiply these estimates. N/A is
deliberate for continuations needing a separate bypass and the different-start
entry. Deferred outside-model modification is not included. Supplied positions,
negative depth and dialog checkpoints can establish conditional effects, but
do not count as clean route setup in these estimates. Finite searches are not
random samples of all possible routes, so their success or failure counts do
not provide these percentages. This review adds judgment, not new execution
evidence.

| Overall | Family | Approach | Current counterexample promise | % Chance of Counterexample |
|---:|---|---|---|---|
| 1 | JP stale-platform lineage | 🎮 [Different collision/query samples, then read the inactive unreused top payload](#route-rank-1) | Very low currently; exact high-payoff JP mechanism if another clean history breaks a checked boundary | 1–2% |
| 2 | Ink installation | 🎮 [Timer-131 non-null Graphics retry](#route-rank-2) | Very low for a clean route; supplied setups work, but all 68 dialog-support trials find a floor and refresh the display without a useful retry | <1% |
| 3 | State-first installation | 🎮 [Finite signed-16 nonlocal-State alias](#route-rank-3) | Very low in the audited stock model; exact injected payload | <1% |
| 4 | JP stale-platform lineage | 🎮 [Move the warp/top or create a collision-preserving clone](#route-rank-4) | Very low on the checked clean route; the warp never moves or gains collision, and every top-slot reuse first loses the top collision | <1% |
| 5 | State-first installation | 🎮 [Post-copy State-only writer in a later callback or descendant](#route-rank-5) | Very low on the checked clean run; another history must expose the first late write, wrong receiver, or lifetime failure | <1% |
| 5A | State-first installation | 🎮 [Pre-collision cached-platform displacement creates the split](#route-rank-5a) | Very low as a clean origin on the checked run; the effect remains exact if another history installs a valid pointer | <1% |
| 6 | JP stale-platform lineage | 🎮 [Moving skipped-query interval](#route-rank-6) | Very low; no moving skip appears in the audited scheduler shapes | <1% |
| 7 | Downstream collection | [Join all five Act-6 triggers, spawn, pickup, and save-bit update](#route-rank-7) | High conditional value; the recovered transcript and published run put the sole press at the second pole, and an exact one-edge controller segment now reaches the downstream Grindel base | N/A — continuation only |
| 7A | Downstream collection | 🎮 [Assemble Puzzle secret progress across ordinary area revisits](#route-rank-7a) | Very low as a bypass; normal credit survives revisits, but no unearned secret or avoided hard contact is known | <1% |
| 8 | Downstream collection | [Lower Act-3 100-coin-star/Grindel itinerary](#route-rank-8) | High conditional value; the recovered five-trial account and published run reach Act 3 after the sole second-pole press, while exact inputs currently stop at the Grindel base | N/A — continuation only |
| 9 | Downstream collection | [Upper Act-3 100-coin/star-dance itinerary](#route-rank-9) | Parked pending an independent no-A elevator escape; low-medium only as a downstream continuation, with no elevator bypass supplied | N/A — continuation only |
| 9A | Direct Area-2 gates | 🎮 [Use the 100-coin star to interrupt an action at the gate](#route-rank-9a) | Low; even an extra Goomba hop plus the pickup-frame ground-pound lift stays too low in the checked branch; higher supports, renewed airborne jumps or other real movement before the star chooses its position remain open | 1–3% |
| 10 | Direct Area-2 gates | 🎮 [Held-A jump-kick or B rollout from the upper elevator shaft](#route-rank-10) | Very low; live held-A launches hit all four elevator faces below the cutoff, and every JP held-A/rollout query is now linked and accounted for | <1% |
| 10A | Direct Area-2 gates | 🎮 [Ground-pound startup while the elevator or another support moves](#route-rank-10a) | Low; the height window remains, but checked entries and ordinary live-support samples supply no startup; a harder fall or special interaction and a useful sideways departure remain open | 2–5% |
| 11 | Direct Area-2 gates | 🎮 [Lower-aperture impulse, clip, or support switch](#route-rank-11) | Very low for a clean route; Goomba damage works, but no stock approach is constructed and the finite graph lacks full airborne coverage | 1–2% |
| 12 | Direct Area-2 gates | 🎮 [Homing Amp or a moving collision owner](#route-rank-12) | Very low; the checked stock shock composite fails; other position/support changes remain open, with Goomba approaches tracked under Rank 11 | <1% |
| 12A | Direct Area-2 gates | 🎮 [Reload, nonzero warp destination, or same-position support-selection change](#route-rank-12a) | Very low; an exact staged support refresh exists, but it is ownerless, stationary, and gives no gate crossing | <1% |
| 12B | Direct Area-2 gates | 🎮 [Touch a secret or star across a barrier without crossing the usual gate](#route-rank-12b) | Low; contact from inside either unchanged gate footprint is excluded, while the Act-3 rim and airborne secret approaches still need a clean route | 2–5% |
| 13 | State-first installation | 🎮 [Raw-Object-only return or impulse writer](#route-rank-13) | Very low on the checked clean run; all 7,386 collision-position writes are faithful ordinary copies | <1% |
| 13A | State-first installation | 🎮 [Terrain-dispatch or collision-prefix writer outside the platform phase](#route-rank-13a) | Very low on the checked clean run; no extra pre-collision position writer occurs | <1% |
| 13B | State-first installation | 🎮 [Interaction-stage writer or cached-floor snap composite](#route-rank-13b) | Very low on the checked clean run; the warp stops later interactions and all three floor snaps leave Mario at Y=768 | <1% |
| 14 | Eyerok | 🎮 [Carry a stale Eyerok-hand address from Area 3 to Area 2 in JP](#route-rank-14) | Retired in the audited stock model; no hand can install the pointer at the warp, and the sole reused nonzero payload moves about 8 down and 38 backward | <1% beyond checked stock cases |
| 15 | Eyerok | 🎮 [Board and ride a raised hand into a lower Area-2 route](#route-rank-15) | Medium as a proved local ride, very low as a full route; one live-memory movement case is constructed, but the complete timeline and outside-call effects remain open | 1–2% |
| 16 | Goomba / PU transport | 🎮 [Goomba raising, PU transport, and Spindel handoff](#route-rank-16) | Very low; both finite top-window timing classes are refuted, and the generous revised case reaches only Y=1017 | <1% |
| 17 | JP stale-platform lineage | 🎮 [Fresh same-slot replacement payload](#route-rank-17) | Low abstractly; absent in the authenticated best trace | <1% |
| 18 | State-first installation | 🎮 [Skipped, wrong-index, or redirected State-to-Object copy](#route-rank-18) | Very low; tested copies are exact, and the second-state read cannot succeed in the initialized proof model | <1% |
| 19 | Ink installation | 🎮 [Negative quicksand depth plus stalled automatic dialog](#route-rank-19) | Very low for a clean route; conditional gap creation and brief retention during movement work, but neither a useful first floor miss nor a clean negative seed is known | <1% |
| 20 | Ink installation | 🎮 [Mario behavior flag plus a large graphical Y offset](#route-rank-20) | Very low; ordinary stock writers are excluded | <1% |
| 21 | Ink installation | 🎮 [Non-stock Graphics anchor or spawned anchor actor](#route-rank-21) | Very low; the required parent actors are absent from stock Area 1 | <1% |
| 22 | Eyerok | 🎮 [Second-hand ceiling to the Area-2 Y=1280 tier](#route-rank-22) | Very low under the checked height and speed bounds | <1% |
| 23 | Eyerok | 🎮 [Update-11 wake-sandwich Pedro installer](#route-rank-23) | Very low; only a one-frame desynchronizer remains plausible | <1% |
| 24 | Direct Area-2 gates | 🎮 [Direct Float32 pole exit or pole avoidance](#route-rank-24) | Very low on current geometry and trajectory evidence | <1% |
| 25 | Ink / wall interaction | 🎮 [Shell visual offset plus wall/floor schedule](#route-rank-25) | Very low; the offset is small and normally reanchored | <1% |
| 26 | Downstream collection | 🎮 [Negative-depth transport to a fresh or older tangible star](#route-rank-26) | Very low; checked placements miss and no suitable older star is known | <1% |
| 26A | JP stale-platform lineage | 🎮 [Canonical owner observed outside the modeled geometry](#route-rank-26a) | Very low after the continuous clean trace; universal-history residual only | <1% |
| 26B | JP stale-platform lineage | 🎮 [Recognized owner at a noncanonical slot or ghost epoch](#route-rank-26b) | Very low after the continuous clean trace; universal-history residual only | <1% |
| 26C | JP stale-platform lineage | 🎮 [Unclassified dynamic owner](#route-rank-26c) | Very low after the continuous clean trace; no missing actor is known | <1% |
| 26D | JP stale-platform lineage | 🎮 [Surface-node/temporary mutation before the floor query](#route-rank-26d) | Very low after the continuous clean trace; no returned stale or changed node | <1% |
| 26E | JP stale-platform lineage | 🎮 [Live same-owner payload mutation before apply](#route-rank-26e) | Very low after the continuous clean trace; no harmful payload change | <1% |
| 27 | JP stale-platform lineage | 🎮 [Classic Spindel replacement-object spawning displacement](#route-rank-27) | Very low; corrected allocation depth and first payload are unhelpful | <1% |
| 28 | Eyerok | 🎮 [Attack and reboard a rising hand](#route-rank-28) | Very low | <1% |
| 29 | Eyerok | 🎮 [Sleeping-hand Pedro speed bootstrap](#route-rank-29) | Very low; no intact stock moving-floor, landing, or `OFF_FLOOR` cycle can evade the cap, so only a named owner/action/source failure or model extension remains | <1% |
| 30 | Eyerok | 🎮 [Seams, moving boundaries, or partial updates](#route-rank-30) | Very low | <1% |
| 31 | Memory and control escapes | 🎮 [Defined alias/external/cache/hitbox escapes; machine-only corruption deferred](#route-rank-31) | Very low as a known gameplay route; proof-critical | <1% for named defined cases |
| 32 | Upstream scope extension | [Castle-to-SSL glitch or retained inbound pointer](#route-rank-32) | Very low and intentionally deferred | N/A — different start |

Earlier reviews moved moving-object/support ideas to `12/12A`, negative
quicksand to `19`, and the abstract floor-owner residuals to `26A–26E` as the
evidence changed.  This review adds `7A`, `9A`, `10A`, and `12B` without
renumbering established links.  Ranks 1–3 remain high for decision value and
exact conditional mechanisms, not because any has a likely clean producer.

### Which ranks are most promising now?

The [Fine Print proof review](notes/fine-print-proof-promotions.md) promotes eight existing results into the site's proof section: the Ink retry, dialog gate, stopping copy and ownerless-platform clearing; pole-pickup selection and rising ledge rejection; and the bounded coin-flight and stock Amp-shock models. Each keeps its own conditions and open continuation. This recognizes completed parts of Ranks 2, 19, 9A and 12; it does not retire those routes or change any of the estimates below.

**10A and 12B are the strongest remaining searches**, at roughly **2–5% each**:
ground-pound startup has a real height window but lacks a clean entry and
sideways departure; unusual contact geometry might avoid the usual gate.
**9A follows at 1–3%**, after the extra Goomba-hop and pickup-frame lift checks
still left the star too low. All three remain unlikely, and their overlapping
ranges are not a precise ordering of success probabilities.

**1, 11 and 15 are roughly 1–2% leads**, each with a concrete conditional
payoff and a difficult missing setup. Most other gameplay leads are below 1%.
Rank 14's stated stock construction is already closed under its audited
conditions; its residual estimate concerns different defined histories outside
that classification. The numerical ranks remain stable research priorities,
not a sorting of the subjective odds.

**Rank 2 drops from 1–2% to below 1% in this review; Rank 19 stays below 1%.**
The [three-second support search](notes/ink-vertical-installation.md#three-seconds-after-dialog-release)
finds actual movement while the raised display survives in 56 of 68 trials
from supplied dialog checkpoints. That is a real conditional effect, but every trial finds a floor
and refreshes the display on the first update after release; none produces a
pre-action floor miss during the 90-update continuation. I now give this route
less weight because even the granted setup has not produced the required
combination of movement, floor loss and contact. This does not rule out other
poses, timings, actions or floor-alignment histories, and the trials do not
establish a numerical probability bound.

**For finishing the impossibility argument, prioritize the shared
connections** in the [proof-progress ledger](impossibility-proof-progress.md):
the accepted Area-1 start, actual execution and necessary collection contacts.
Rank 19's negative-depth history is valuable as possible branch closure, not
because a clean negative seed looks likely. An open proof condition is not
positive evidence of a counterexample.

**The vertical-only Ink setup works conditionally in JP.** The backward search
now needs movement or support loss that also makes the first floor lookup fail
while preserving the useful display, warp contact and top timing. Finding
movement before the display refresh is no longer the missing step by itself.
A negative seed may still be granted while testing that transfer; a complete
clean route must account for its creation and the real reward collection.
See the [vertical-installation note](notes/ink-vertical-installation.md).

**7 and 8 remain valuable downstream continuations; 9 stays parked until an
independent no-A elevator escape exists.** They have no independent bypass
odds. Rank 32 changes the starting boundary and is also unscored. No complete
clean counterexample is known, and the missing whole-history connections mean
we also lack an unconditional impossibility proof.

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

### 🎮 Different collision/query samples, then the inactive top payload

**Overall rank: 1. Family priority: 1. Likelihood: very low for a clean producer,
but high conditional payoff.**

**In plain language.** Mario's raw collision Object touches the upper warp,
but a later floor query looks at a different position and remembers the
spinning pyramid top as Mario's platform.  The top explodes and its object slot
becomes inactive, yet JP keeps the old address.  On the first pyramid update,
the game reads the still-resident top bytes and applies their three-dimensional
platform displacement to MarioState while the raw Mario Object remains local.

**What is already known.** The supplied JP stale-top setup has a useful payoff. The independent clean four-pillar run still gives only a finite exclusion: all 2,462 frames pass, all 149,578 floor checks return normally, all 426 moving-floor returns have the right live owner, and the final query always selects an ownerless floor. Six briefly surviving top triangles are never returned after their owner disappears. Separately, the actual US/JP final platform-update body now has a [checked query-to-owner connection](notes/rank1-final-platform-query.md): it reads raw Object coordinates, calls the real floor routine, tests the saved raw Y against the returned height, and writes that floor's owner to both platform references only when the rounded distance is less than four. The stores' effects are proved; position agreement and an active-owner check are not assumed. The [earlier controller search](notes/rank1-reachable-search.md) adds 132 finite choices and four exact JP replays: no sampled upward gap, no first-query retry in the replayed intervals, and no Ink displacement at either recorded Area-2 entry. The live floor selected in every other history and the pointer's later survival remain open.

**Conditional Impossibility Result.** Local stock-model exclusion only. With the checked stock owners and schedule and the same position used for warp contact and platform selection, the upper-warp platform must be empty. Separately, the real final-query connection confirms that raw Y still at 768 cannot retain the checked top at 1938.8648681640625: the four-unit test clears the pointers, regardless of a raised display. These conclusions do not establish that the final raw position must stay low or match the earlier contact sample. The 2,462-frame clean recording excludes only that recording, while the supplied inactive-top setup succeeds.

**What closes it.** Derive the actual positions and selected live floor at the final check for every allowed upper-warp history, then follow any installed owner through unloading, reuse and the first Area-2 apply. The new query-to-owner result consumes the real query's returned memory; it does not supply those list contents or prove the surrounding caller and lifetime. An exclusion must prevent the useful combination, while a clean exception must produce it from the accepted start. The confirmed inactive object can still help if another history installs and retains its address. Defined, in-bounds gameplay remains the scope.

**Full Impossibility Result.** Open. The final update body's raw reads, real floor call and returned-owner stores are connected under explicit ordinary storage conditions. Still derive the positions and live final floor choice for every allowed upper-warp history, discharge the surrounding call and memory conditions, and establish pointer lifetime and first Area-2 apply. Either show that the useful disagreement and retained pointer cannot coexist, or find a clean exception. Requiring the positions to agree would exclude the mechanism being investigated rather than prove it impossible.

**Are counterexamples likely?** Unlikely. The old top would have a useful payoff, but the complete clean four-pillar run never installs it. Another input history must create a useful disagreement between position checks.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-4"></a>

### 🎮 Move the warp/top, or create a collision-preserving clone

**Overall rank: 4. Family priority: 2. Likelihood: very low on the checked
clean route; no clean relocation or clone producer is known.**

**In plain language.** Instead of making Mario's different position checks disagree, physically put a standable moving floor inside the upper warp; Mario could then touch the warp and remember that floor at the same place.  A second pyramid top would serve the same purpose only if it kept both the original movement and the original standable collision.

**What is already known.** The stock top and warp are not together, ordinary copying helpers do not copy an object's identity or collision, and the top's own routines create only detectors and harmless fragments.  The new authenticated zero-A four-pillar run checked every live object from Area-1 entry through the upper warp: there was always only one real top and one upper warp, every one of the top's 2,353 collision loads belonged to that top inside its normal small motion range, and the warp never moved, gained collision, changed identity, or loaded a floor.  The dead top's slot was reused three times, but each reuse cleared the old collision before installing a different object, so no replacement kept a standable copy.  This disproves relocation or cloning on that successful route, while the older permissive model still confirms that either effect would be useful if another clean route actually produced it.  See the [Rank-4 warp/top trace](notes/rank4-warp-top-clone.md).

**Conditional Impossibility Result.** No conditional exclusion of the whole relocation or clone route yet. The checked ordinary copying and top-fragment code does not provide a standable duplicate, and the authenticated clean recording contains no moved warp or useful clone. Those are source and recorded-history exclusions; they do not cover every later spawning or collision-loading path.

**What closes it.** A full in-model disproof still has to connect the complete stock spawn and collision-writer census to every reachable clean controller history, showing that no ordinary callback, outside effect, alias, or later slot reuse can move the warp or install the top's floor on another object; alternatively, one different clean run can settle the route positively by producing the first extra top, top-collision owner, warp write, or warp collision load and carrying it into the warp.  The checked run supplies the exact test and eliminates the most realistic stock execution, while out-of-bounds writes, ACE, DMA, and execution after undefined behavior remain separate machine-level extensions rather than unfinished clean producers.

**Full Impossibility Result.** Open. Connect the actual spawn, copy, collision-load and slot-reuse paths to live object identities throughout all allowed histories. Show that none can move the warp or give another object the useful top collision before contact. A permissive model showing that a relocated floor would work is not a creation proof or an impossibility proof.

**Are counterexamples likely?** Very unlikely. The clean run neither moves the warp nor creates another standable top, and slot reuse removes the old collision. A different ordinary history must explain how a useful floor gets there.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-6"></a>

### 🎮 Moving skipped-query interval

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

**Conditional Impossibility Result.** Not yet sufficient for the moving-skip proposal. The checked frozen-carry model cannot move Mario, but preservation is built into that model. Source checks also narrow which normal and delayed-warp paths omit a query. Applying the preserving model to every omitted-query frame still needs proof; assuming that application would assume away the proposed movement.

**What closes it.** Link the indirect callback targets, external/non-alias
frames, play-mode reachability, and null-`gMarioObject` lifecycle to the actual
run.  A survivor must then exhibit a scheduler shape outside the audited cases
or a concrete alias, external, or lifecycle effect.

**Full Impossibility Result.** Open. Establish the reached play modes, callback targets, Mario lifetime and relevant call effects in the actual scheduler. Then prove that every interval without a fresh platform query either cannot move Mario into the warp or cannot retain a useful pointer. No blanket claim that all skipped frames preserve positions has been discharged.

**Are counterexamples likely?** Very unlikely. Checked pauses preserve Mario's position as well as his platform, while ordinary movement brings another floor check. An exception must both move Mario and preserve the useful old platform.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-17"></a>

### 🎮 Fresh same-slot replacement payload

**Overall rank: 17. Family priority: 4. Likelihood: low abstractly and very low
for the authenticated best trace.**

**In plain language.** Save an object's address, free the object, allocate a
different object in the same slot, then let the stale pointer interpret the new
object's movement fields as a platform displacement.

**What is already known.** The project has an executable abstract slot-reuse countermodel and a replacement payload capable of a large three-dimensional displacement, so the engine effect is possible when supplied.  The authenticated timer-131 trace does not reuse the top slot before the first apply, and the continuous clean four-pillar/upper-warp run finds no useful replacement fate either, so this is absent from both of the strongest observations.

**Conditional Impossibility Result.** No general conditional impossibility result for useful same-slot replacement. The abstract replacement payload can work, so slot reuse itself is not disproved. The timer-131 and clean four-pillar observations exclude the useful replacement only in their recorded chronologies. The allocator's separate-slot protection results do not forbid a stale pointer from later reading a reused slot.

**What closes it.** Produce one coupled linked chronology proving the exact
free-list pushes and pops, same-slot allocation, replacement type, payload
bytes, query selection, and apply timing.  An independent schedule witness and
an independent reuse witness are not enough.

**Full Impossibility Result.** Open. Cover the actual free-list order, allocation epoch, replacement type and movement fields from capture through first apply. Prove that every allowed replacement is too late or has an unusable payload, or exhibit the coupled allocation-and-movement history. Separate examples of reuse and useful motion cannot be combined without that connection.

**Are counterexamples likely?** Very unlikely in ordinary play. Replacement movement works in a supplied setup, but neither strong recorded history supplies the right replacement at the right time. Allocation and movement must work together.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26a"></a>

### 🎮 Canonical owner observed outside the modeled geometry

**Overall rank: 26A. Family priority: 5. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The floor really belongs to a familiar stock object,
but that object's live transform places its collision somewhere the finite
geometry model did not allow.

**What is already known.** Canonical observations for the fifteen modeled Area-1 owner families do not supply a platform at the fixed upper-warp sample, and the continuous clean upper-warp run strengthens that result: all 426 moving-floor returns have the expected live owner, while Mario's final platform is ownerless and static in all 2,462 checked frames.  No familiar owner appears at an unexpected transform in that run, although this is not yet a theorem over every possible controller history.

**Conditional Impossibility Result.** Finite geometry exclusion for canonical poses only. The fifteen modeled owner families cannot supply the required platform at the fixed warp sample under their checked transforms. This is sufficient for those transforms, but this entry proposes a transform outside them. The clean recording's expected owner positions do not prove that every other history has the same bounds.

**What closes it.** Reconstruct each reachable owner's live position, angles,
scale, collision matrix, and surface insertion at the query frame; otherwise
return the first owner whose observed transform violates the canonical map.

**Full Impossibility Result.** Open. Derive each reachable owner's position, rotation, scale and collision transform at the actual query, then connect surface insertion and selection to those bounds. The route closes only if every relevant live pose is covered; an outlying but defined pose needs its own geometry check.

**Are counterexamples likely?** Very unlikely. Familiar moving floors stayed in their expected places in the clean upper-warp run. Another history must actually place one where the warp lookup can use it.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26b"></a>

### 🎮 Recognized owner at a noncanonical slot or ghost epoch

**Overall rank: 26B. Family priority: 6. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The behavior name looks familiar, but the pointer names
the wrong pool slot, an old lifetime of that slot, or a stale “ghost” copy.

**What is already known.** The lineage classifier keeps this separate from a fresh replacement at apply time.  The continuous clean upper-warp run checks every returned moving-floor owner against its aligned live slot, object list, and unchanged behavior and finds no ghost epoch or interior owner, while the accepted entry fixes the object-pool range.  A universal allocation-epoch theorem for every other input history remains open.

**Conditional Impossibility Result.** No conditional exclusion of all wrong-slot or old-lifetime owners yet. The clean recording has correct aligned owners, and the accepted start bounds the pool. Neither fact proves that a pointer always names the same live allocation later. Local slot-separation proofs are useful, but are not a complete owner-lifetime theorem.

**What closes it.** Connect every `Surface.object` address to an aligned live
pool slot, prove allocation-epoch monotonicity and behavior identity, and frame
unload/reuse from insertion through query.

**Full Impossibility Result.** Open. Follow each selected surface owner from allocation and insertion through unload, reuse, query and apply. Prove the slot, behavior and allocation lifetime match the owner used by the geometry argument, or identify a legitimate mismatch with useful motion. Pool membership alone is insufficient.

**Are counterexamples likely?** Very unlikely. No useful disagreement between a recognized floor owner and its live object slot is known. Ordinary object reuse must preserve useful collision and change the later movement in the same history.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26c"></a>

### 🎮 Unclassified dynamic owner

**Overall rank: 26C. Family priority: 7. Likelihood: very low; no missing actor
is known.**

**In plain language.** A reachable actor omitted from the stock owner list
loads a floor at the warp and supplies the platform pointer.

**What is already known.** The finite source-bounded model covers the named stock candidates and proves their geometry exclusion, and every moving floor actually returned during the continuous clean upper-warp run belongs to a checked live owner; no unclassified actor appears.  Generic spawn helpers, transitive behavior scripts, clones, and outside-produced owners are still not ruled out for every possible execution, but no concrete missing actor is known.

**Conditional Impossibility Result.** Finite stock-list exclusion only. The named, source-bounded owner set has the checked geometry exclusion, and no extra owner appears in the clean recording. That is sufficient for the enumerated set, not for the proposal that another reachable actor was omitted. No complete conditional route exclusion is established merely by naming a coverage requirement.

**What closes it.** Complete the Area-1 transitive spawn/behavior/collision-data
graph and dynamic-list membership proof, or exhibit the exact new owner and
its clean creation path.

**Full Impossibility Result.** Open. Complete the reachable Area-1 spawn and behavior graph, collision-loading paths and dynamic-list membership. Connect every returned moving floor to a covered owner and pose. If an additional actor can occur, evaluate its actual floor geometry and timing before calling the route closed.

**Are counterexamples likely?** Very unlikely as a known route. No missing actor has been found to provide the required moving floor. An unclassified category is not evidence that a suitable actor exists.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26d"></a>

### 🎮 Surface-node or temporary mutation before the query

**Overall rank: 26D. Family priority: 8. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The loader starts with the right object and surface,
but a reassignment, list corruption, stale node, or alias changes what the
floor query later sees.

**What is already known.** Source checks tie the currently updating object to each moving-floor owner, and the continuous clean run additionally checks every reached insertion, list, and floor-query return.  The exploding top briefly leaves six triangles after its owner is removed, but no query returns them and the next frame clears them before any new query.  No node is corrupted, substituted, or returned stale in this execution; other controller histories still need the same guarantee.

**Conditional Impossibility Result.** Recorded-history exclusion only for the proposed list mutation. The clean run selects no altered or stale floor node, including the six top triangles briefly left after owner removal. The source owner checks do not themselves protect every node through later allocation, insertion and clearing. This is not enough to park all list-timing histories as impossible.

**What closes it.** Execute allocation, initialization, insertion, list
traversal, clear/removal, and `find_floor` with receiver/alias/external frames.

**Full Impossibility Result.** Open. Connect actual node allocation, initialization, insertion, traversal and clearing to the floor call that matters, including valid aliases and reached external effects. Prove that no useful changed or stale entry can be selected. The mere existence of a stale triangle is not a counterexample unless the query consumes it.

**Are counterexamples likely?** Very unlikely. The clean run never selects a usefully changed or stale floor-list entry. Another history must change that information at the right moment and have the query actually choose it.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26e"></a>

### 🎮 Live same-owner payload mutation before apply

**Overall rank: 26E. Family priority: 9. Likelihood: very low after the
continuous clean trace.**

**In plain language.** The pointer remains valid and names the same object, but
that object's position, angles, velocity, or transform changes between the
floor query and the later platform apply.

**What is already known.** The payload-fate classification deliberately keeps this distinct from slot reuse.  The continuous clean run checks the reached owner identities, protected writes, and query returns and finds no harmful same-owner change or owner-backed final Mario platform.  It remains possible only as a universal-history residual because no theorem yet freezes every displacement field from every possible query through its later apply.

**Conditional Impossibility Result.** No general conditional exclusion of useful same-owner changes yet. The checked run has neither a harmful payload change nor an owner-backed final platform. A fixed payload calculation only tells us what that payload would do; it does not prove the fields stay fixed between query and apply. Assuming they never change would remove this entry by assumption.

**What closes it.** Prove a per-field last-writer and memory-frame theorem from
query to apply, or return the exact mutating step and resulting binary32
displacement.

**Full Impossibility Result.** Open. Identify the last actual writer of each displacement field between selection and apply and follow the same object lifetime. Bound every allowed intervening change, or exhibit one that gives useful displacement. Ordinary object motion must be accounted for, rather than replaced by a blanket memory-preservation premise.

**Are counterexamples likely?** Very unlikely. The same floor owner helps only if its remembered movement changes usefully before Mario applies it. No such change appears in the checked clean history.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-27"></a>

### 🎮 Classic Spindel replacement-object route

**Overall rank: 27. Family priority: 10. Likelihood: very low.**

**In plain language.** Reuse the stale Area-1 slot specifically as Spindel,
then use Spindel's first update as the spawning-displacement payload.

**What is already known.** The JP retention bug is real, but the corrected
allocation depth is `63`, not the old “60” figure.  The modeled first Spindel
displacement moves the upper-entry sample away from Act 3, and the nearby
elevator is not yet in a helpful state.  The inactive old-top payload is both
better authenticated and currently more promising.

**Conditional Impossibility Result.** First-update shortfall only. The corrected allocation depth and checked Spindel displacement do not supply the intended direct target approach; the US spawn-clear model also blocks unchanged inbound-pointer retention at its own boundary. Neither result excludes every later Spindel continuation, replacement placement or fresh capture. There is no complete conditional exclusion of the whole named route.

**What closes it.** Construct a clean seed at the exact free-list depth and a binary32 continuation to a target, or finish the finite first-update platform census and rule out every Spindel placement.  In US, the spawn clear blocks retained-inbound-pointer versions at that boundary but does not exclude a later recapture, relocated owner, clone, or independently changed pointer; the final proof must still execute and frame that clear in linked US memory.

**Full Impossibility Result.** Open. Establish which Spindel slot and first-update payload can actually follow each allowed stale-pointer setup, then cover their later movement and contact opportunities. For the US retention subcase, connect and preserve the actual spawn clear. A later recapture is a separate case, not a contradiction of that clear.

**Are counterexamples likely?** Very unlikely. Corrected allocation timing and the first replacement movement are unhelpful. A different clean replacement schedule must be demonstrated rather than relying on the old estimate.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 2 — Ink's Graphics-retry installation attempts

Ink's core observation is that SM64 can consult three different views of
Mario's position in one update: raw Object, MarioState, and displayed Graphics.
An earlier warp contact can remain available when a failed floor lookup moves
Mario to his raised display position. With an eligible action and top support,
the game can then remember the top. Retaining it through the warp is a further
requirement for the JP displacement in Family 1.

Technical background: [Ink fallback](notes/ink-fallback.md),
[timer-131 surface](notes/timer131-surface.md), and the
[clean-JP Graphics-gap source audit](notes/clean-jp-graphics-gap-source-audit.md).

<a id="route-rank-2"></a>

### 🎮 Timer-131 non-null Graphics retry

**Overall rank: 2. Family priority: 1. Likelihood: very low for a clean
producer; midpoint and vertical-only conditional payoffs recorded.**

**In plain language.** Let Mario touch the upper warp at a low position where his first floor lookup fails, while his stored display position is high on the spinning top. The retry moves him to the display position. If he can process the warp interaction and keep the top as his platform, JP can carry its leftover movement into the pyramid.

**What is already known.** Both the supplied midpoint and the [vertical-only setup](notes/ink-vertical-installation.md) bypass the elevator in JP. The latter uses actual and collision position `(-2200,768,-1024)` and display `(-2200,1938.8648681640625,-1024)`. The real retry selects the top and retains it through explosion, warp and the first useful Area-2 movement; Coq separately checks the recorded floor selection. That successful setup was supplied with zero depth. The [three-second continuation search](../instrumentation/jp-dialog-support-search/README.md) instead lets the game raise the display from an extra supplied dialog checkpoint. Its 56 moving continuations preserve the display briefly, then find a floor and refresh it. The complete generated US/JP platform phase preserves display and collision coordinates, so moving actual Mario does not itself create low warp contact. The preceding support check now provably clears both platform references after a missing floor, whatever height was returned, or after a failed distance test. With those references cleared, a later platform movement needs a replacement pointer. A raised display does not rescue that support check. The useful gameplay producer remains missing. The new [accepted-warp batch](notes/f02-warp-acceptance-target.md) proves that the actual final US/JP action-setting call preserves all three position records. A clean JP replay now reads them at the exact successful handler return: all equal, with no active top and no final platform capture. This excludes that run, not other gameplay histories. The [whole-game split catalog](notes/position-split-catalog.md) separates 27 source mechanisms and supporting cases; checked absent actor selectors remove named stock paths. The [backward sizing pass](notes/ink-gap-backward.md) now compares the other 20 cases with this supplied gap. The normal Tweester continuation is proved to reach a copy with equal movement and display Y, even after a missing floor; ejection and later writes are separate. Shell offsets and the checked single-refresh water calculation fall far short. A large retained downward move or the negative-depth/dialog setup still needs a concrete producer. The [rapid-home-oscillation diagnostic](../instrumentation/tweester-transport/README.md) finds no useful warp approach in its tested schedules after rejecting early Mario contact; a relaxed western-ledge pose passes a conditional contact check but has no controller route. Source review also follows ordinary ejection into another display copy, while an accepted warp stops the interaction loop before a Tweester lift from that same contact.

**Conditional Impossibility Result.** Proved exclusions of particular gap sources, not of Ink itself. Under the stated storage and call conditions, a completed ordinary ground refresh and the normal Tweester copy erase the upward display gap; a missing floor at the earlier support check clears the remembered platforms. These are sufficient to exclude those specific mechanisms. The supplied useful retry works, so a blanket claim that movement cannot preserve display or that Ink cannot install would be false.

**What closes it.** The current F02 target is [immediately after the upper warp is accepted](notes/f02-warp-acceptance-target.md), still in Area 1: find a gameplay predecessor supplying useful position disagreement there, then report the final Area-1 platform capture separately. The retry can make movement equal display while collision stays low; all three need not differ, and later synchronization need not undo capture. First size the candidate gap and check its next copies, before spending effort on travel to the warp. The producer still needs the first floor miss, usable display, contact and top timing. A platform-based producer needs low collision coordinates with usable support before movement, or another concrete writer supplying contact. Losing the floor at the previous platform check cannot retain an old support pointer unchanged. Other support poses, action changes and retained floor-alignment mismatches remain open, as does deriving a dialog checkpoint from real reward collection. Grant negative depth and a valid coin opportunity for the conditional transfer investigation, without granting the useful combination. The chosen checkpoint fixes the present task; it does not establish clean reachability, Area-2 payoff or a complete route.

**Full Impossibility Result.** Open. Cover every remaining legal producer of the useful gap, first floor miss, low collision contact and top timing before the accepted-warp checkpoint, then connect final platform capture and retention. Rank 19 supplies an accepted conditional exclusion of one seed source; it does not exclude other position writers or turn the working supplied setup into a clean route.

**Are counterexamples likely?** Very unlikely; my current complete-route estimate is below 1%. The supplied installation works, and the dialog-support search shows that actual movement can briefly preserve the raised display. But all 68 trials still find a floor and refresh the display on the first update after release, so they do not produce the useful retry. A clean setup that combines the gap, first floor miss, warp contact and timing remains missing. Other support or floor-alignment histories remain open; this estimate is not a disproof or a statistical bound from the trials.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-19"></a>

### 🎮 Negative quicksand depth plus stalled automatic dialog

**Overall rank: 19. Family priority: 2. Likelihood: very low for a clean seed;
the supplied display works, but its post-dialog producer remains open.**

**In plain language.** Make quicksand depth negative, then remain in a dialog state that repeatedly raises Mario's displayed position without snapping it back; this can build either the large Ink gap needed in Area 1 or, hypothetically, the much smaller height needed below an Area-2 star, but the displayed height must still be copied into Mario's real collision position before it can collect anything.

**What is already known.** No clean no-A seed is known. The [conditional stock argument](notes/conditional-stock-negative-seed.md#a-fixed-stopping-point-for-this-producer) is already proved: with the stock timer bound at the actual write and a covered first-long-jump/controller history, common landing cannot create the first negative seed without A. Excluding every negative-depth producer additionally needs the complete checked writer classification and its finite-arithmetic conditions. Early quicksand-jump landing erases its negative intermediate before the next helper; common landing has no matching clamp. The [late-landing investigation](notes/late-common-landing-investigation.md) supplies local cancellation, caller, animation, sound and initialization results, but full gameplay applicability remains open. Six of twelve one-A controls reach late landing; none of twelve no-A controls does. Those are finite observations. Imported depth faces the proved course-entry reset. The [supplied display setup](notes/ink-vertical-installation.md) works conditionally, but no clean useful floorless arrival is established.

**Conditional Impossibility Result.** 01 — Already proved, under the listed conditions; this stopping point was accepted on 26 September. Starting with finite nonnegative depth and outside the long-jump cycle, the checked writer outcomes, stock timer bounds at the write, covered first-entry transitions and physical controller-edge connection force a useful negative seed to require A. This is sufficient for the accepted seed exclusion. The early subtraction-and-clamp pair also cannot expose its temporary negative as a useful seed.

**What closes it.** The user accepted the listed scope on 26 September: **01 — Already proved, under the listed conditions** is the stopping point for this conditional exclusion. Keep the timer-at-write, first-entry/controller and, for the whole seed family, writer-coverage conditions visible. Removing those conditions is a separate extension requiring earlier duration-record protection, timer preservation through the remaining calls, and complete first-long-jump/input history. The sound binding belongs to that extension. Immediate erasure before a useful read excludes its own producer, as proved for early quicksand-jump landing. A cross-course candidate must account for the reset or a real producer afterward. No A-using seed-size calculation or later Ink continuation is needed for the accepted conditional result. The unrestricted no-A seed family and the whole route remain open.


**Full Impossibility Result.** Open beyond the accepted scope. Derive the completed-writer coverage, live record and duration preservation, timer bounds and first-long-jump/controller history from every allowed gameplay history. Connect the needed sound and other call effects only where those invariants require them. Cross-course imports must account for the actual reset or a later producer. No later Ink payoff proof is needed to exclude the seed.

**Are counterexamples likely?** Very unlikely; the complete-route estimate stays below 1%. The game can build and briefly retain the gap from a supplied negative-depth dialog checkpoint, but the tested support departures still find a floor and reset the display. Both a useful floorless arrival and a clean no-A seed remain missing. Neither the finite search nor the local seed checks exclude every controller history.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-20"></a>

### 🎮 Mario behavior flag plus a large graphical Y offset

**Overall rank: 20. Family priority: 3. Likelihood: very low in the selected
in-bounds model.**

**In plain language.** Give Mario the generic object flag that copies raw
position to graphics with an added `oGraphYOffset`, and make that offset huge.
This could create the entire Ink gap at once.

**What is already known.** Object allocation clears the relevant words, Mario has no graphical-offset command, and its normal flag command enables bit 8 without changing dangerous bit 0.  The audit now follows the complete ordinary direct-call graph from all three Mario callbacks in both versions and finds no direct write to either word through any literal union view; it also narrows the current-object identity to the normal Mario spawn and list-traversal chain.  All forty stock graphical-offset commands elsewhere are fixed values at most `+240`, far below the generic `+632` timer-131 minimum.  A deliberately non-stock `+1160` value does make a warp-center retry succeed, so the normal stock-script/direct-helper route is disproved at this source boundary but aliasing, indirect or external code, forged behavior, and slot-lifetime failure remain possible escape classes.

**Conditional Impossibility Result.** Source-level exclusion of the normal script and direct-helper explanation. The checked Mario script does not request the dangerous graphical-offset behavior, the audited direct graph supplies no relevant direct writer, and the fixed stock offset commands are too small for the checked retry requirement. This is useful for those source paths, but does not yet establish a whole-run bound under all aliases, receivers and indirect calls.

**What closes it.** Prove through live execution that the traversed Mario node is still `gMarioObject`, its allocation epoch and cleared raw fields persist, behavior dispatch uses the checked table and script, and no indirect or defined aliased store changes bit 0 or the offset; give every reachable external an exact effect or frame, or exhibit the first valid counterexample store.  An out-of-bounds overwrite is outside this Clight close-out and would need a separate retail machine model.

**Full Impossibility Result.** Open. Prove that the actual Mario object keeps the checked identity, initialization, behavior dispatch and offset fields across all relevant updates. Cover the remaining defined alias, indirect-call and external writes. The initialized flag alone cannot justify that lifetime invariant.

**Are counterexamples likely?** Very unlikely. Ordinary initialization and checked later changes keep the relevant setting and display offset harmless. Another defined history must actually change them; an unfinished preservation proof does not supply that change.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-21"></a>

### 🎮 Non-stock Graphics anchor or spawned anchor actor

**Overall rank: 21. Family priority: 4. Likelihood: very low for stock Area 1.**

**In plain language.** Some actors, such as Chuckya or King Bob-omb, can make a child anchor set Mario's stored display position from the anchor's position and graphical offset. A distant anchor could supply a large gap; a visual animation alone does not establish that stored change.

**What is already known.** The stored-display writer is real, but its complete direct call chain belongs only to Chuckya and King Bob-omb anchor behaviors. The audited SSL Area-1 regular list, macro list and selected special presets contain neither parent; the generated C bodies have no direct parent reference, and the only static Chuckya reference in that corpus is its global macro-preset table. Loading a model is not spawning the actor. The [whole-game split catalog](notes/position-split-catalog.md) now separates these anchors from other special movers and checks twelve additional absent actor selectors. SSL's own tree, water, cannon, tornado, shell and dialog mechanisms remain separate cases. These source exclusions do not establish every live object's creation and lifetime; arbitrary injected actors and memory corruption remain outside the selected rules.

**Conditional Impossibility Result.** Proved stock-selector exclusion. The checked Area-1 regular, macro and selected special lists cannot select the named Chuckya or King Bob-omb anchor parents. That is sufficient to reject their ordinary listed placements as local gap sources. It is not yet a proof that every possible live descendant or indirect spawning history lacks those behaviors.

**What closes it.** Connect the checked selectors to actual legal object creation, lifetime and receiver identity, including any reached indirect spawning path. Then either construct a controller-reachable Chuckya/King Bob-omb anchor descendant or prove the named behaviors cannot arise in this stock Area-1 continuation. Do not assume a complete spawning classification or add injected debug states to the gameplay model.

**Full Impossibility Result.** Open. Connect the checked selectors to the complete legal spawning, behavior and lifetime paths that can reach the display writer. Exclude a reachable parent and anchor with a useful receiver, or show one ordinary creation path. Loading an actor model or supplying an injected actor does not satisfy that obligation.

**Are counterexamples likely?** Very unlikely. The actors supplying the useful alternative display anchor are absent from ordinary Area 1. A clean route must explain how a suitable actor appears and affects Mario at the required time.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-25"></a>

### 🎮 Shell visual offset plus wall/floor scheduling

**Overall rank: 25. Family priority: 5. Likelihood: very low alone.**

**In plain language.** Use the shell's small visual lift and a wall-selected or
cached floor to try to preserve and enlarge a Graphics gap.

**What is already known.** The normal shell offsets are `+42` in air and `+45` on the ground, far below the supplied `1170.8648681640625`-unit gap. The [shell investigation](notes/shell-gap-investigation.md) follows wall stops, in-step missing floors, action exits, water, quicksand, speed and the shell actor's copy direction. Normal movement refreshes before the addition; early shell exits add nothing. A native US/JP diagnostic checks 7760 supplied outcome/height cases and repeated calls per build, using explicit helper test doubles rather than live terrain or controller histories. It finds no stacking. Existing Coq copy and normal-frame results retain their scope; this adds no universal shell exclusion. At actual Y=768 the normal display is 810 or 813, so a later writer would still need at least another 1125.864868 units of downward separation. A successful mount has no immediate coordinate write under the existing storage conditions; failed contact can push X/Z, and normal riding clears quicksand depth.

**Conditional Impossibility Result.** Normal-frame model exclusion only. Reanchoring the display before the shell's 42- or 45-unit addition prevents those ordinary additions from stacking into the supplied 1170.864868-unit gap. The real ground-copy checkpoint is proved separately; the 7,760-case diagnostic uses test doubles. These results justify setting aside simple shell-offset accumulation, not claiming a universal live shell-gap bound.

**What closes it.** Linked live-range writer coverage can turn this into a clean impossibility result; a counterexample would need an unusual schedule, valid alias, or another mechanism that first creates most of the gap.  Ordinary platform or PU motion alone preserves an existing gap rather than creating one from a synchronized start, and turning-animation metadata also preserves the three positions.  A valid overlapping buffer remains an in-scope alias question, while actual asynchronous DMA is outside the current Clight execution and needs explicit machine or external semantics.

**Full Impossibility Result.** Open. Cover live shell entry, movement, exits, wall and floor responses, support changes and later writers through the consuming query. Prove no reachable interval skips the relevant refresh or adds enough retained downward separation. Any useful large gap created by another mechanism must be attributed to that producer, not to the small shell offset alone.

**Are counterexamples likely?** Very unlikely alone. The shell's display lift is small and normally reset, so it does not simply accumulate into the missing height. Most of the gap and a way to preserve it must come from elsewhere.

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

### 🎮 Finite signed-16 nonlocal-State alias

**Overall rank: 3. Family priority: 1. Likelihood: very low in the audited
stock model; only a narrow defined alias, dispatch, lifetime, owner, scheduler,
or outside-call escape remains.**

**In plain language.** Put MarioState one 65,536-unit period away while raw
Object stays at the warp.  The terrain code narrows the large coordinate to a
signed 16-bit value, wrapping it back to the timer-131 top.

**What is already known.** The coordinate wrapping works, and an injected JP run uses it to select and capture the top before reaching the upper trigger; a single platform update can also create the entire split from the synchronized warp centre by adding the right sideways motion and making a half-turn around a remote pivot.  The stock scheduler and surface-owner model cannot install that payload because the remembered platform is empty at the upper warp, and the new whole-game source check strengthens this result: each version has 28 named writers of the needed turn value, but following every direct helper call from all stock Area-1 surface owners reaches 93 functions and only one of those writers, the debris spawner, whose normal values are `3840` or `6400` rather than the required half-turn `-32768`.  CompCert also proves that casting an integer cannot fabricate a usable pointer for a successful write.  The six calls in this closed direct graph whose bodies are not supplied by the selected source program are now exactly `play_puzzle_jingle`, `create_sound_spawner`, `cur_obj_play_sound_2`, `set_camera_shake_from_point`, `sqrtf`, and `stop_sounds_from_source`; indirect or forged dispatch, object-slot replacement, a valid alias already present or returned by outside code, mistaken ownership, and unaudited scheduling remain open.  The injected run still supplies the split and starts the top artificially, so it is capability evidence rather than a clean route.

**Conditional Impossibility Result.** Conditional stock-bootstrap exclusion. The checked same-sample floor and scheduler model leaves no useful platform at the warp, so it cannot install the nonlocal displacement payload. The direct owner-call census also lacks the required half-turn writer in its normal paths, and a cast cannot fabricate a valid CompCert pointer. These narrow the installer; they do not refute the working supplied coordinate alias or all defined alternative writers.

**What closes it.** A counterexample must now show one concrete defined escape that the new direct-call and integer-cast checks do not cover: a valid existing or outside-produced alias that writes the remembered-platform cell, an indirect or forged callback, object-slot replacement, a wrongly identified floor owner, movement after the final floor check or during a skipped check, an unchecked retained entry, or a scheduler path outside the audit, and it must carry the exact payload through one live execution; if any of the six named unresolved calls is actually reached, its exact memory effect must be supplied first.  An impossibility proof must connect each real Clight frame to the audited cases and eliminate those remaining choices, after which the route closes before its already-proved platform math runs.  Out-of-bounds pointer fabrication and MIPS continuation after undefined behavior remain outside that verdict and need a machine-level extension, and either defined outcome must still derive the top's activation and later lifecycle without the injected setup.

**Full Impossibility Result.** Open. Derive the actual preapply schedule, selected owner, pointer and payload from the allowed start, covering remaining valid aliases, indirect dispatch, slot lifetimes and reached external calls. Show that every possible source of the large displacement is excluded before its already-working arithmetic is used, or produce a clean exceptional source.

**Are counterexamples likely?** Very unlikely under the checked stock rules. The displacement works with a supplied platform setup, but ordinary selection cannot install it. Missing live coverage is not evidence of a usable alternative platform.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-5"></a>

### 🎮 Post-copy State-only writer in a callback or spawned descendant

**Overall rank: 5. Family priority: 2. Likelihood: very low on the checked
clean run; no reached writer is known.**

**In plain language.** Near the end of Mario's turn in each frame, the game copies his movement position into the position used for object collisions. This idea asks whether something later moves only one of those positions, leaving them apart when the next frame checks the warp.

**What is already known.** On the successful zero-A four-pillar run, a read-only audit followed all 2,462 frames from that copy through the remaining objects and into the next frame. Mario stayed the same player object, the two positions matched after every copy, and neither position was written before the next platform update. They also matched at every checked collision entry and return. Separately, the actual US/JP particle-copy tail preserves Mario's records after spawning returns a different valid slot. A “child” here is a spawned particle or effect, not another Mario. The new allocator connection follows the entry free-list slot through the complete nonempty call to its return. The full initializer now protects every other slot in the shared Object pool and separate MarioState storage, including its clearing and matrix loops. Different entry active flags give an explicit separation test; live ownership and earlier graph/list effects remain open. See the [allocation boundary](notes/f02-allocation-boundary.md), [trace](notes/rank5-state-split-trace.md) and [particle-copy proof](notes/f02-postcopy-child-frame.md).

**Conditional Impossibility Result.** Proved local position protection. The completed particle-copy tail and full object initializer preserve Mario's protected positions when the particle is a different valid slot and the stated storage conditions hold. The nonempty allocator's returned-slot connection is also proved. These are sufficient to exclude those particular copy and initialization steps, not the entire interval of callbacks before collision.

**What closes it.** The initializer's slot bounds and the complete nonempty allocator's returned-slot connection are finished conditional claims. Closing the broader route additionally requires the earlier list and graph effects, full-pool eviction, live ownership, the remaining spawning wrappers and other reached callbacks through collision, with applicability to the relevant clean histories. These are separate extensions, not one bounded next step; each needs a fixed claim and explicit conditions before more work. An unfinished applicability proof does not reopen the completed conditional theorem. A counterexample must identify the first wrong copy recipient or later position change and carry that disagreement into collision. Out-of-bounds corruption and arbitrary code execution remain outside the current execution model.

**Full Impossibility Result.** Open. Establish live ownership and separation through the preceding list, graph and eviction operations, then cover the remaining spawn wrappers and callbacks up to the next collision check. Either prove that no reached late writer creates a useful disagreement, or identify the first actual write and show the next check consumes it.

**Are counterexamples likely?** Very unlikely. The checked frames end with Mario's position records agreeing. A new lead needs an actual later movement or changed recipient, not merely an unfinished universal proof.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-5a"></a>

### 🎮 Pre-collision cached-platform displacement creates the split

**Overall rank: 5A. Family priority: 3. Likelihood: very low as a clean origin
on the checked run; the conditional effect itself is exact.**

**In plain language.** The game can remember which platform Mario stood on and move him with it at the start of the next frame.  If it remembered a useful moving platform here, Mario's movement position could shift before the warp checks his collision position.

**What is already known.** An artificially supplied platform can create the useful movement, so the effect itself is real.  On the successful zero-A four-pillar run, however, the remembered platform is empty at the platform step in all 2,462 frames and the moving-platform helper never runs.  None of Mario's three recorded positions changes during that step, and his movement and collision positions match at every checked collision entry and return.  At the three upper-warp platform checks, all three positions match.  See the [Rank-5/5A intra-frame trace](notes/rank5-state-split-trace.md) for the technical receipt.

**Conditional Impossibility Result.** The null-platform subcase is excluded: an update with no remembered platform cannot obtain displacement from that platform. The full platform phase also preserves display and collision coordinates under its normal-pool conditions, even when actual Mario moves. That does not disprove this route with a useful supplied platform; it makes installing that platform the missing prerequisite.

**What closes it.** A general disproof must show that every other reachable clean input history also reaches each platform step without a useful remembered platform.  A counterexample must instead produce one clean frame where a real moving platform is remembered and moves Mario far enough before collision.  Fabricated pointers and continuation after out-of-bounds corruption remain outside the current execution model.

**Full Impossibility Result.** Open. Classify the reachable remembered platforms before collision and prove their motions cannot create the useful split at the warp, or construct one that does. An empty cache in the clean recording is not a universal cache invariant. Earlier low collision coordinates and support selection need their own gameplay explanation.

**Are counterexamples likely?** Very unlikely as an origin. A remembered moving platform could create the disagreement, but the checked run never remembers a useful one. This inherits the difficult installation problem.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-13"></a>

### 🎮 Raw-Object-only return or impulse writer

**Overall rank: 13. Family priority: 4. Likelihood: very low on the checked
clean run; another input history remains open.**

**In plain language.** Mario has separate movement and collision positions.  A change to only the collision position could put him back at the warp while leaving his movement position somewhere else, allowing the two game checks to disagree.

**What is already known.** The completed zero-A four-pillar run has write-by-write coverage across all 2,462 frames. Its only 7,386 writes to Mario's collision coordinates are the ordinary three-coordinate copies, with correct readbacks and no intervening retarget. Separately, the actual US/JP particle-copy tail preserves Mario's collision and display records when the spawned particle occupies a different valid slot. The newer [allocator results](notes/f02-allocation-boundary.md) also protect every other shared-pool slot during the full initializer and follow the entry free-list slot through the complete nonempty allocator's return. Earlier list/graph effects, live ownership, full-pool eviction, the remaining spawning wrappers and other callbacks are still open. Abstract examples show why ordering alone cannot exclude other histories, but none is a clean gameplay witness. See the [copy/interaction audit](notes/area1-ranks13-18-copy-interaction-audit.md) and [particle-copy execution proof](notes/f02-postcopy-child-frame.md).

**Conditional Impossibility Result.** Proved local subcases only. The separate-particle copy tail and initializer cannot overwrite Mario's collision coordinates under their explicit slot and storage conditions. Every collision-coordinate write in the clean recording is an ordinary faithful copy. This is enough to reject those local writes and that replay, but does not exclude every possible Object-only writer.

**What closes it.** Extend the checked write coverage to every reachable clean history, or find one different history with an actual collision-position write that creates the useful disagreement.  A candidate must identify which Mario it changes, the coordinate and timing of the change, and why the ordinary copy does not erase it before the relevant check.

**Full Impossibility Result.** Open. Cover all reached collision-position writers and their actual receivers through the interval that matters, including object lifetime and surrounding call effects. Prove that each either preserves the required agreement or is overwritten before contact. A different successful history must expose the first useful surviving write.

**Are counterexamples likely?** Very unlikely. All checked collision-position changes are ordinary copies of Mario's movement position. A different history needs a real change that survives long enough to matter.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-13a"></a>

### 🎮 Terrain-dispatch or collision-prefix writer outside the platform phase

**Overall rank: 13A. Family priority: 5. Likelihood: very low on the checked
clean run; no extra writer is known.**

**In plain language.** Terrain handling or the beginning of collision detection might change one of Mario's positions before the warp test, outside the usual moving-platform step.  Such an extra change could create the disagreement needed by an installer.

**What is already known.** On the same 2,462-frame clean run, no movement- or collision-position write occurs before the platform step, or after it through the end of collision detection; the platform helper itself never runs.  The positions agree at every checked collision boundary.  These are live write-watch results, including any reached indirect or outside call, rather than an assumption that the listed source writers are exhaustive.  The new replay reproduces the complete earlier receipt exactly, so no extra terrain or collision-prefix writer supplies a split here.  See the [four-route audit](notes/area1-ranks13-18-copy-interaction-audit.md).

**Conditional Impossibility Result.** No conditional exclusion of the whole terrain/collision-prefix interval yet. The live write watch excludes an extra position writer in all checked frames of the clean recording, including the calls actually reached there. It remains finite evidence; the separate platform-phase proof does not cover the surrounding code named by this entry.

**What closes it.** Show that every other reachable clean frame follows the checked stages without an extra position change, including unusual callbacks and object lifetimes.  Alternatively, exhibit the first real write outside those safe cases and show that it changes the relevant Mario position before the warp collision test.

**Full Impossibility Result.** Open. Follow every reachable terrain-dispatch and collision-prefix path with its actual callback receivers and object lifetimes. Show no additional position change can create the needed disagreement before the warp test, or identify a concrete reached writer outside the checked replay.

**Are counterexamples likely?** Very unlikely. The checked terrain and pre-collision stages contain no extra useful movement. The unfinished universal proof is a coverage question, not an identified gameplay mechanism.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-13b"></a>

### 🎮 Interaction-stage writer or cached-floor snap composite

**Overall rank: 13B. Family priority: 6. Likelihood: very low on the checked
clean run; a different useful cached floor remains unproved.**

**In plain language.** After the game chooses the warp, another interaction might push or bounce Mario, or the disappearing action might snap him to a previously remembered floor.  A useful change at that moment could make the final floor check disagree with the earlier warp check.

**What is already known.** The live upper-warp interaction now confirms the source prediction: it reports success and stops the interaction loop, so no later handler runs.  Mario then spends three frames disappearing; each performs a real remembered-floor height write, but merely rewrites his existing Y=768.  No sideways write occurs after selection, the remembered floor stays intact through the final query, and that query returns the same floor without a moving-object owner.  The floor itself exists; it is the remembered platform that is empty.  The copy remains faithful throughout, so this composite creates no useful movement on the checked run.  See the [four-route audit](notes/area1-ranks13-18-copy-interaction-audit.md). The new [acceptance check](notes/f02-warp-acceptance-target.md) records all three full position vectors equal at the successful return, before the disappearing action runs. Coq now proves that the final action-setting call cannot create or erase a split; its frame starts after stop-riding, leaving the earlier handler calls outside that theorem.

**Conditional Impossibility Result.** Proved last-call exclusion. After stop-riding, the actual final warp action-setting call preserves movement, collision and display under its stated storage conditions, so that call cannot create or erase a split. The clean run's short-circuit and harmless Y=768 snaps add recorded evidence. Earlier handler calls and a different cached floor are outside the proved last-call segment.

**What closes it.** Find a clean warp acceptance with a usefully different remembered floor, or an actual operation that breaks the checked interaction, position, or floor conditions.  Otherwise prove that every reachable clean warp frame has the same harmless short-circuit, floor snap, and completed copy.  Merely invoking another ordinary handler after the accepted warp is not a surviving mechanism.

**Full Impossibility Result.** Open. Connect every accepted warp's earlier interaction effects, cached floor, disappearing action and final copy/query. Prove they cannot create useful capture from a clean predecessor, or exhibit a reachable different floor or earlier writer. A later ordinary handler cannot help when the accepted warp has already ended that interaction loop.

**Are counterexamples likely?** Very unlikely. Checked warp frames stop later interactions, and their floor adjustment leaves Mario at the same height. A usefully different remembered floor or interaction order must first occur in ordinary play.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-18"></a>

### 🎮 Skipped, wrong-index, or redirected State-to-Object copy

**Overall rank: 18. Family priority: 7. Likelihood: very low; the second-state
read is excluded in the initialized proof model.**

**In plain language.** Let Mario's movement position change, then prevent the normal update of his collision position: skip the copy, choose a second Mario-state entry, or send the copied coordinates to the wrong object.

**What is already known.** All 2,462 copies in the clean run execute and return with the first state entry, the same Mario object, stable source coordinates, and three exact coordinate writes.  Separately, the US/JP Coq proof now shows why selecting a second entry cannot provide a successful copy: there is only one allocated Mario-state entry, and the stock function tries to read beyond it before copying any position.  No operation in the initialized proof model can enlarge that allocation, including an abstract outside call.  This excludes the second-entry read in that model, but not skipped or redirected copies on other histories.  See the [copy/read proof and audit](notes/area1-ranks13-18-copy-interaction-audit.md).

**Conditional Impossibility Result.** The second-Mario-state variant is closed in the initialized selected model: the sole state allocation cannot supply the second entry's required read, and successful execution cannot enlarge that allocation. This is a sufficient exclusion of that exact proposal. The clean copies add finite evidence, but skipped copies or valid redirected receivers are different cases.

**What closes it.** Prove that every remaining clean path reaches and returns from the copy with the same live Mario and unchanged source coordinates, including deaths, warps, object replacement, and outside calls; or exhibit the first real skipped copy, redirected receiver, or altered transfer.  Reading past the state array and continuing on the retail machine is a separate out-of-bounds extension, not an unfinished successful-Clight route.

**Full Impossibility Result.** Open for the remaining variants. Prove that every relevant live path reaches the correct copy, reads the intended Mario state and writes the intended live object before collision, including warp, death and reuse paths. An invalid out-of-bounds read followed by retail continuation is outside the selected model, not a remaining successful source execution.

**Are counterexamples likely?** Very unlikely. Observed copies reach the correct Mario record, and the second-state read cannot succeed in the initialized model. A clean skipped or differently directed copy needs concrete gameplay evidence.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 4 — Direct Area-2 gate crossings

These ideas try to cross the upper or lower pyramid barrier without first
installing a stale platform pointer.  The formal first-crossing classifier
keeps ordinary physics, platform displacement, object impulse, collision clip,
area reload, nonlocal cast, and same-position support change separate.

Technical background: [upper elevator cut](notes/area2-elevator-cut.md),
[lower target cut](notes/area2-lower-target-cut.md), and
[route exhaustiveness](notes/route-exhaustiveness.md).

<a id="route-rank-9a"></a>

### 🎮 Use the 100-coin star to interrupt an action at the gate

**Overall rank: 9A. Family priority: 1. Likelihood: low; attached-pole version
excluded locally, descending wall/ledge candidate still needs installation.**

**In plain language.** Save the 100-coin star for the difficult pole or elevator, then collect it at a moment when changing Mario's action might let him catch a ledge or keep a useful position. This uses ordinary coin collection, not a changed action table, and is separate from using the star after the gate.

**What is already known.** A pickup while attached to the pole loses the handstand elevation; an airborne pickup has a useful local calculation but no clean setup. All 41 fixed coin actors start away from the shaft, and the other checked actors add no convenient coin source. Goomba drops remain candidates, but the [stronger height and timing audit](notes/rank9a-pre-home-movement.md) now grants an extra Goomba hop after the conditional Spindel setup, the finishing attack, coin toss and pickup-frame ground-pound lift: even generous bounds still miss the required star-placement height by ten units. In the ordinary schedule the star chooses its position after the current Mario update, so the ground pound's later lifts cannot be counted toward that placement. Higher supports, renewed airborne jumps and other actual movement before the home sample remain open. No gate crossing is supplied, and the same reward cannot also be spent on the earlier climb.

**Conditional Impossibility Result.** Proved exclusions of specific interruption setups. The attached-pole selector chooses the standing dance, and the checked low Goomba/coin construction, even with the extra hop, finishing attack and one pickup-frame ground-pound lift, leaves the home sample at most 3495 rather than the needed 3505. These are sufficient for those selector and height-bound cases. They do not exclude a higher support, another earned jump or movement outside the checked pre-home interval.

**What closes it.** Find a clean higher support, another earned airborne jump, or a concrete Mario position change beyond the checked one-lift case before the star chooses its home; a delayed first star update must explain both why the star waits and why Mario can still move. Then follow the same coin and star through the right location, timing, airborne pickup, ledge catch and target collection without already crossing the gate or spending that reward earlier. Alternatively, prove that every reachable update, support, position copy and first-star timing fits the checked bounds. A different wall or upper-elevator placement needs its own height target; neither a supplied enemy nor a future jump apex establishes installation.

**Full Impossibility Result.** Open. Cover every reachable coin source, support, launch and Mario movement before the star chooses its home, then follow the actual reward through contact and the useful action change. Prove each placement or pickup fails to bypass the gate, or find one clean survivor. A star supplied beyond the gate is not an installation proof.

**Are counterexamples likely?** Unlikely, and weaker after the latest height checks. The coin-and-star mechanism is real, but the checked Goomba hop and ground-pound lift still place it too low. A higher reachable setup or useful movement before the star chooses its position is missing.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-10"></a>

### 🎮 Held-A jump-kick or B rollout from the upper elevator shaft

**Overall rank: 10. Family priority: 2. Likelihood: very low for the checked
vertical routes.**

**In plain language.** First complete the no-spin descent on the shaft line and
land on the live elevator.  From that landed state, use a no-new-A action to
get over or through the elevator-shaft wall.

**What is already known.** Held A plus B really produces a jump kick without a new A edge at the action, and B alone really produces the dive/rollout setup.  The held-A probe creates its held state on the final Area-1 disappearance frame, so it tests the Area-2 dynamics but is not itself an end-to-end zero-edge witness.  Exact Float32 envelopes contain 64 jump-kick and 84 rollout quarter steps and peak at only `135` and `227.5`, below the strict `231` wall cutoff.  The uninterrupted read-only JP run reaches Area 2 with Mario in slot 10, lands on the unique elevator after all 17 expected descent samples, and gives every observed floor the same elevator owner.  The B rollout hits the live east wall, stops at X `411`, stays inside, and returns to the elevator.  A separate held-A run records all 64 quarter steps: every one performs exactly two wall queries, one floor query, and one ceiling query in that order; 61 return clear, two hit the elevator wall, and the last lands.  The B rollout likewise accounts for all 84 quarter steps, with 168 wall, 84 floor, and 84 ceiling calls and no missing or unknown result.  Across both traces, every queried floor and every non-null queried wall belongs to the elevator, every queried ceiling is static, and every intended Y sample matches the proved Float32 envelope exactly, including the live maxima `135` and `227.5`.  Representative held-A launches toward east, west, north, and south each hit a distinct correctly oriented elevator wall, remain over its floor, stay inside the cage, and peak at the same live frame-end relative height `128`.  The selected US and JP Clight programs now resolve the exact air-step, wrapper, and surface-query bodies, and both versions have the same unavoidable wall–wall–floor–ceiling call prefix.  The stock transition also resets Wing; a hypothetical post-reset Wing has only the two above-cutoff samples `234` and `232` and is not a stock entry.

**Conditional Impossibility Result.** Proved vertical-envelope exclusion under the checked launch, gravity and support conditions. The ordinary jump-kick and rollout peak at 135 and 227.5 relative units, below the 231 cutoff, so they cannot clear the wall by height alone. The named JP executions also hit the actual walls and return inside. This is sufficient for those departures, not all horizontal poses, clips or changed supports.

**What closes it.** The named held-A and B trajectories are now closed for their exact JP executions, and the internal query chain is linked to the selected source in both versions; what remains is either to prove that the four cardinal wall classes and the pose-independent vertical bound cover every reachable ordinary launch, or to exhibit a genuinely different continuous X/Z/yaw setup whose first crossing uses a skipped query, different surface, horizontal clip, support switch, action writer, or identity/lifetime change.  US still needs a live machine receipt if machine-level parity rather than the selected-source theorem is required.  A Wing version can reopen only through a real post-reset Wing grant or different live receiver, and a table or memory-corruption version remains outside successful in-bounds selected CompCert runs unless its accepted memory invariant is refuted or a retail-machine semantics is added.

**Full Impossibility Result.** Open. Show the vertical bounds and wall-query coverage apply to every reachable launch direction and position, including action transitions, live surfaces and support changes. Authenticate any already-held A predecessor. A complete result must exclude a different crossing mechanism rather than extrapolate the four tested directions to every controller history.

**Are counterexamples likely?** Very unlikely for ordinary launches. Checked held-A and B departures hit the elevator below the required height, and normal entry removes Wing. A survivor must change the actual movement or collision situation.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-10a"></a>

### 🎮 Ground-pound startup while the elevator or another support moves

**Overall rank: 10A. Family priority: 3. Likelihood: low; a conditional height
window is proved, but useful entry and departure remain unconstructed.**

**In plain language.** Normally Mario ground-pounds by jumping with A and pressing Z in the air. Walking off a ledge into ordinary freefall also permits Z, so the challenge is earning that action while still in the elevator. Its startup lifts Mario while the elevator can descend, but it stops sideways motion. Walking off is only one possible entry, and the intact bucket has no interior ledge. The idea needs both a way to start without a new A press and a way to use the height to leave the cage.

**What is already known.** A granted ground pound can leave Mario 260 units above the descending elevator floor, clearing the checked wall-height cutoff of 231, but it stops sideways speed and supplies no B/Z escape. The ordinary falling-wall response points inward in the existing diagnostic. The [entry check](notes/rank10a-elevator-entry-checks.md) excludes normal elevator jolts and a nearby hanging ceiling as entries; rollout, jump kick, dive and the initial drop cannot request ground pound directly. The [rollout-ending proof](notes/rank10a-ground-pound-moving-geometry.md#rollout-animation-ending-cannot-supply-entry-2026-09-12) now also shows that finishing either rollout animation leaves its action unchanged, so that ending cannot unlock freefall or ground pound. The [slide-kick check](notes/rank10a-slide-kick-entry.md) includes its first bounce: the ordinary checked flight lands before its freefall timeout. Its [launch proof](notes/rank10a-slide-kick-entry.md#work-backward-through-the-launch) now follows the real airborne initializer, which replaces vertical speed with 12 without changing position or selected support; the remaining writes in the outer setter preserve that result. A much harder fall must therefore develop afterward or come from another concrete action or support change. The [backward support check](notes/rank10a-backward-support.md) shows that the base covers the bucket interior and every overlapping static-floor candidate is far below it; live base availability and rounded height calculations still need proof. The [conditional hold proof](notes/rank10a-live-support.md#conditional-eleven-descent-exclusion) now completes the actual US/JP ground quarter, including its position write, wall handling and return. Starting aligned, each ten-unit descent is followed by another alignment under explicit query and vertical-input conditions, so the proposed eleven-descent hold is excluded within that contract. The proof derives alignment; it does not assume it or claim those conditions for every gameplay situation. All static ceilings over the interior are too high to block a low-gap quarter, and the ordinary ceiling query rejects the elevator underside. The [live-support check](notes/rank10a-live-support.md) now finds no missing base, outward correction or low-gap alignment failure in more than 23 million queried quarters per version. Coq excludes static geometry from the wall-query corridor and proves that time stop does not erase existing collision. Other moving meshes miss the corridor at their stock tracks; preserving those tracks and the full update history still needs proof. A real ceiling stop near the top requires an already-supplied 110-unit gap, so it does not create the needed mismatch. A blanket 100-unit bound is formally refuted by the checked slide kick, so grounded and airborne bounds must stay separate. The [coin check](notes/rank10a-elevator-coins.md) leaves a conditional catch of a moving Goomba drop, but fixed coins miss and the reviewed hazards supply no ordinary passive drop. A Goomba's normal jump from nearby low ground is too low, while a checked hard-fall rebound beside the west wall has enough height for contact from inside. The [all-Goomba comparison](notes/goomba-elevator-timing.md) checks all nine stock placements and tests the six singletons with favorable RNG choices: the three raised eastern actors have isolated paths into the low pit, but none reaches the elevator. All starts lie far below the second pole. The [fresh-triplet proof](notes/fresh-triplet-spawning.md) now follows the live distance helper, its caller's store and the native-command dispatch, alongside the earlier callback, graphics and collision checks; the [square-root routine](notes/sqrtf-implementation.md) now has a local proof of its rounded result and unchanged RAM, and the real triplet input is in its supported range. An explicit local library binding now connects the generated helper to that routine, with checked argument and return registers, memory and normal control bits; the constructed helper execution rejects the distance test without a numerical-effect or matching-call premise. A [conditional sequence proof](notes/fresh-triplet-spawning.md#the-conditional-result) now shows that the fresh triplet never spawns across any finite number of supplied checks: initial distance 19,000 and every later calculated distance reject, and unloaded action is carried from one actual native-command return to the next. Its contract preserves five named parent fields across intervening activity, retains the calculated distance until its check, and bounds Mario's raw Object at each read. The reached square-root result and its narrow memory frame remain explicit premises in the older Clight model. Deriving these conditions for every ordinary gameplay check and transporting the linked runtime to the wider game/OS history remain open. The direct western approach still fails at the entry wall in the isolated source check. Longer approaches, other actors and changed support remain open; a useful high escape needs a raised supplier. The neighboring roofs also remain possible departure points. The [contact proof](notes/rank10a-ground-pound-moving-geometry.md#height-alone-cannot-replace-departure-2026-09-10) excludes collecting a target by height alone inside the cage. A clean entry and useful sideways departure remain missing.

**Conditional Impossibility Result.** Proved subcases, not a full 10A exclusion. Starting aligned in the checked height range, with the stated ground-query and vertical-input conditions, eleven ten-unit descents cannot hold Mario at his old height: the actual ground calls realign him. The fresh-triplet sequence also cannot spawn its children under its parent-field, distance and confinement conditions. These are useful conditional stopping points for those mechanisms. They do not exclude all ways to enter ground pound; the granted startup really has a useful height window.

**What closes it.** The eleven-descent ground-quarter hold and the named fresh-triplet sequence are now conditionally closed. Extending the triplet result requires its stated field-preservation and distance-read conditions at every check of the confinement episode; earlier children and singleton approaches remain separate. To extend that conclusion, prove the stated query and vertical-input conditions for the remaining grounded updates or exhibit a concrete way they fail. For a general exclusion, prove the [separate grounded and airborne invariants](notes/rank10a-backward-support.md#invariants-for-entry-and-what-walking-off-would-mean), including live base selection, missing-floor returns and entry into each grounded update, or find the first controller-reachable event that breaks them and supplies an eligible action. The ordinary low-gap ceiling stall has a conditional exclusion, and the finite live-support checks now reject the obvious missing-base and outward-wall explanations. A surviving repeated stall must identify a concrete failure of rendering or loading, departure from the checked interior or stock moving tracks, or an eligible action or interaction. A ceiling stop that already needs the large gap cannot serve as its producer. Walking past the base edge already requires an explanation for crossing its enclosing walls. Any useful entry still needs a sideways departure. For the slide-kick candidate, first create the harder fall after its launch while Mario is still confined, then follow its bounce, freefall and ground-pound entry; carrying downward speed from an earlier action through the ordinary initializer does not work. For lost support inside the bucket, explain why the live base is absent or rejected, why Mario leaves the checked interior, or what changes his position; a lower static floor cannot replace a successfully returned higher base under the checked selection conditions. Follow collision loading, query order, rounded heights and action changes; a time-stop proposal must also account for suspended collision clearing. For a coin/star interruption, first supply and collect the moving coin while Mario is still confined, then derive the star and useful action change. Any survivor still needs the height window, landing and target collection without a new A press; an impossibility proof must cover the remaining reachable alternatives.

**Full Impossibility Result.** Open. Cover the remaining grounded and airborne histories that could supply a ground-pound-eligible action, including a genuinely missing base, changed support, harder fall, interaction or reachable coin source. If an entry survives, determine whether it can produce sideways departure or target contact. Height alone inside the cage is already insufficient; proving the ordinary hold case does not settle every other entry.

**Are counterexamples likely?** Unlikely, but one of the better remaining searches. Ground-pound startup offers a real height window while a support moves. The ordinary checked slide kick and bounce now fail alongside the earlier entry checks. A separately granted hard fall can pass the freefall gate, but creating that fall inside the elevator remains unproved. This does not justify changing the subjective 2–5% estimate: a clean airborne start and useful sideways departure are still missing.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-11"></a>

### 🎮 Lower-aperture impulse, clip, or support switch

**Overall rank: 11. Family priority: 4. Likelihood: very low for a clean route,
although ordinary enemy damage has an observed conditional payoff.**

**In plain language.** Leave the second pole without A and cross the opening using an enemy hit that preserves the handstand height, another object shove, a collision clip, or moving support. A separate hypothetical version would use a future table-editing exploit to trigger a proper long jump after the ordinary climb.

**What is already known.** Ordinary enemy damage can preserve all 174 extra handstand units: a [staged Goomba test](notes/rank11-handstand-damage.md) leaves at Y 4194, crosses the opening, and lands on the upper ring without A, while ordinary holding at Y 4020 also works. The [Goomba installer audit](notes/rank11-goomba-installer.md) checks all nine stock actors and shows that a ring-level regular Goomba overlaps holding Mario after its first jump update. Its finite graph finds no approach to the ring through the listed short transfers or a nearby discharge from the low vertical Grindel. That graph has not been proved to cover all ordinary movement: the later elevator check confirms stronger rebounds after hard falls, and long airborne transfers need separate accounting. The proof checks the US/JP roster, hitbox, jump and floor-query source facts and the reviewed mesh receipt; the [timed Z release](notes/rank11-pole-exit-live-audit.md) still falls back without an enemy. No clean Goomba installation or complete target-star continuation is established.

**Conditional Impossibility Result.** No conditional exclusion of the enemy-damage route as a whole. The ordinary normalized pole release fails within its checked trajectory, but a staged Goomba hit really preserves useful height and reaches the ring. The finite stock-Goomba transfer graph excludes its listed transfers only; it does not cover all hard falls, rebounds or long flights. The payoff therefore cannot be marked impossible.

**What closes it.** Either derive a clean Goomba approach or prove that the movement analysis covers the remaining falls, rebounds, repeated pushes and support changes. The H/F/R departure and other defined gameplay mechanisms also remain open. Any success must connect ordinary lower entry, contact, every movement and collision check, ring landing and star collection without staging writes. Full handstand height is unnecessary for the checked damage payoff; a useful enemy position alone is not its installer.

**Full Impossibility Result.** Open. Prove every stock actor and other allowed impulse source cannot reach a useful contact before the gate, or derive one clean installation and continuation. Include the falls, rebounds, repeated interactions and support changes omitted by the older graph. Enemy position and attack timing must come from the same allowed history.

**Are counterexamples likely?** Unlikely, despite a strong conditional payoff. Enemy damage can knock Mario from the pole to the ring, but none of the nine stock Goombas has a checked ordinary installation there. Another reachable enemy placement, shove or support change is needed.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-12"></a>

### 🎮 Moving geometry or object impulse

**Overall rank: 12. Family priority: 5. Likelihood: very low after the stock
Amp wall/support composite was closed.**

**In plain language.** Test whether an Area-2 Amp's shock, a Grindel, a moving wall, Spindel, or the elevator can push, carry, or reposition Mario across a gate without A. The distinct ordinary-Goomba damage departure is tracked under [Rank 11](#route-rank-11), where its payoff works but a clean enemy approach remains unproved.

**What is already known.** The exact US/JP roster contains two homing Amps and one circling Amp, but no cannon, shell source, Tweester, Heave-Ho, Chuckya, Fly Guy, or jumping box; the scripted moving owners are the known Grindels, Spindel, four walls, and elevator.  The proof grants perfect Amp installation at the pole, then checks the payoff: shock contains no push, zeroes all horizontal motion, and calls the ordinary air step, which applies gravity after four collision quarters.  Mario is stationary for only the first shocked frame, then falls at the fixed pole centre and lands on the static Y-`3200` base on update 21.  The aperture walls are 101–103 units from the centre against radius-`50` queries, all six stock moving-owner corridors miss the pole disc (the closest is the elevator, still 513 units away), and the 820-unit pole-to-floor gap makes the final platform update clear any cached support before the fall.  Thus the formerly open stationary-shock plus wall/platform composite is disproved in the finite stock source model; see the [Rank-12 object-impulse audit](notes/rank12-area2-object-impulse.md).

**Conditional Impossibility Result.** Conditional stock-model exclusion of the Amp-shock composite. With the checked pole-centre start, stock walls and owner tracks, ordinary shock removes horizontal motion, falls to the Y=3200 base on update 21 and cannot keep the old platform across the large gap. This is sufficient to reject that shock-plus-support construction even with Amp contact granted. It does not exclude every different moving-geometry impulse.

**What closes it.** Link a real Amp/moving-owner execution to the finite closure and show that the relevant runtime objects keep their decoded homes, axes, owners and collision-list entries; a changed position, surface or owner needs its own gameplay predecessor. Supports changed by ordinary movement, deletion or reuse remain legitimate cases and need execution evidence. Goomba approaches, including falls and rebounds missing from the older graph, remain under Rank 11. The current work stays within defined gameplay and excludes arbitrary memory modification.

**Full Impossibility Result.** Open. Connect the stock geometry and motion assumptions to each reached object, floor list and contact in live execution, and classify the other allowed shove, carry and support-change cases. Prove none crosses a gate or supplies target contact. Ordinary Goomba damage has its separate positive payoff and installation question under Rank 11.

**Are counterexamples likely?** Very unlikely on present evidence. The checked ordinary-shock composite does not cross the gate. A different moving support or contact could reopen the search, but no useful clean setup is known.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-12a"></a>

### 🎮 Reload, nonzero warp destination, or same-position support change

**Overall rank: 12A. Family priority: 6. Likelihood: very low; the support-refresh mechanism is now witnessed exactly, but the observed refresh is stationary and ownerless.**

**In plain language.** Use an ordinary alternate warp or an area reload to reach a different entry or change Mario's support. The normal interior teleporter must be checked separately from the Area-2/Area-3 connection, which keeps his position; altered-destination proposals remain separate from these stock routes.

**What is already known.** The [Rank-12A audit](notes/rank12a-reload-support.md) checks the normal upper entry at `(0,5500,256)`, both zero-offset Area-2/Area-3 instant warps, and the direct destination writers. The stock interior fading warps instead connect `(3070,1280,2900)` and `(2546,1150,-2647)`; they are part of the known lower itinerary, not a newly found high exit. A staged original-JP Area-3-to-Area-2 receipt also replaces the selected floor while logging zero movement, but both floors have no object owner and Mario's platform remains empty. That receipt demonstrates support refresh, not a clean controller route or a useful crossing. The [coverage review](notes/ordinary-gameplay-route-coverage.md#existing-routes-clarified-rather-than-duplicated) keeps normal alternate entries distinct from changed-destination proposals.

**Conditional Impossibility Result.** Local ordinary-warp exclusion. The checked zero-offset Area-2/Area-3 warp model adds no displacement and preserves coherent kinematics, so repeatedly taking that warp alone cannot manufacture height. Certified coherent reload also cannot invent a missing target save bit. Neither result excludes a useful changed support, alternate stock entry or subsequent movement; the stationary ownerless refresh is only one supplied example.

**What closes it.** A useful ordinary route must connect a real warp, alternate entry, or replacement support to a gate bypass or target contact. An impossibility result must cover both fading-warp destinations as well as the upper, lower, and Area-3 entries, follow the actual reload and destination values, and show that every resulting floor check chooses only harmless rebuilt stock supports. The staged stationary refresh does not discharge those live obligations, and an arbitrarily supplied destination is not a controller-reachable witness.

**Full Impossibility Result.** Open. Follow the actual upper, lower, fading-warp and Area-3 entries, destination values, floor rebuilding and later support effects. Show that none of their reachable combinations supplies a gate bypass or target contact without A. Zero displacement at the warp itself is not enough if the selected support can change afterward.

**Are counterexamples likely?** Very unlikely. The supplied support-refresh example is stationary and crosses nothing. A real area transition must select a support that actually changes access.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-12b"></a>

### 🎮 Touch a secret or star across a barrier without crossing the usual gate

**Overall rank: 12B. Family priority: 7. Likelihood: low; direct gate-interior
contact is excluded, but rim and airborne approaches remain open.**

**In plain language.** Instead of landing beyond the pole or elevator barrier, get close enough to touch a required secret or star from a neighboring floor or an airborne position on the other side of a wall. The game's touch tests may recognize that contact without Mario taking the usual path.

**What is already known.** Contact does not check whether a wall separates Mario from a target, but the [contact proof and whole-floor scan](notes/rank12b-cross-barrier-contact.md) sharply limit that idea: with normal target readings and distance calculation, Mario cannot touch any required secret or settled target star from inside the stock elevator footprint or second-pole opening, at any height. This now follows a complete touch-test call from its actual object readings, rather than starting with an already-calculated distance. The highest secret's own platform is its only static standing-floor candidate, and approaching directly below it fails if Mario stays clear of its 128-unit-thick underside. A nearby sloped-rim sample does reach the Act-3 star's touch range; the old 75-unit miss applied only to the flat floor. Reaching that rim or a useful airborne secret contact remains unproved, and Act 6 still needs genuine credit for all five secrets.

**Conditional Impossibility Result.** Proved contact exclusion for the named interior regions. Under the normal target readings and distance/height contracts, the complete touch test cannot succeed from inside the stock elevator footprint or second-pole opening at any height. This is sufficient to rule out height-only collection from those interiors. It does not cover the Act-3 sloped rim or every airborne approach, and walls alone do not block the object touch test.

**What closes it.** Reach the Act-3 rim or a useful airborne or edge approach to the highest secret from ordinary no-A play, checking the surrounding walls, platform underside, moving supports and moment of contact. Connect the floor scan and object readings to one actual history, justify the distance helper's ordinary answer and the two height readings it must preserve for a successful touch, then complete genuine secret credit, star contact and the saved result. An impossibility proof must instead cover every remaining reachable contact and show that it requires an already-classified gate crossing; it must not assume that requirement merely because the usual route crosses a gate.

**Full Impossibility Result.** Open. Cover all reachable rim, edge, airborne and moving-support contact positions, and derive the live object readings, identity and helper effects. Connect any claimed secret credit or star award to its actual contact. To use the usual gate as a separator, prove every remaining successful contact requires a covered crossing rather than assuming it does.

**Are counterexamples likely?** Unlikely, but worth checking before assuming Mario must visibly cross a gate. Ordinary inside-gate positions cannot touch the targets, while rim and airborne approaches remain unsettled. A reachable contact through or around a barrier would be useful; a close-looking position alone would not.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-24"></a>

### 🎮 Direct Float32 pole exit or pole avoidance

**Overall rank: 24. Family priority: 8. Likelihood: very low on current
evidence.**

**In plain language.** Find an untested movement step, seam, wall response, ledge climb, or ceiling-hanging path that gets Mario around the second-pole ring without using the larger installer mechanisms above.

**What is already known.** The normalized pole exit fails, and the checked opening is narrow; Z soft-bonk and freefall nevertheless prove that A is not the only way off a pole. Ordinary ledge climbs can also use the stick or nearby-floor geometry, and ceiling hanging can continue with A already held. Area 2 has six hangable triangles, but they are only at heights 957 and 1853, well below the second-pole ring at 3942; they belong to lower routing rather than an already available high bridge. No new live zero-A crossing was found. See the [mesh and action review](notes/ordinary-gameplay-route-coverage.md#existing-routes-clarified-rather-than-duplicated).

**Conditional Impossibility Result.** Trajectory-level exclusion only. The normalized pole departure fails under its checked movement and collision conditions. The low hangable-mesh census removes a ready-made high hanging bridge, but does not prove every alternate approach impossible. Since Z releases and other no-new-A exits exist, a blanket assertion that leaving the pole requires A would be false.

**What closes it.** Enumerate every pole exit and ordinary alternate path, including health/version branches, ledge or ceiling acquisition and release, speed-dependent wall responses, every movement and collision step, and the actual supporting mesh. A hanging version must authenticate its already-held A history; a low mesh or normal teleporter must still connect to the far side of the second-pole gate or a genuine target contact.

**Full Impossibility Result.** Open. Cover all legitimate release actions and their predecessors, health/version branches, ledge and ceiling acquisition, continuous wall responses and changing supports. Show that every allowed departure misses the far side and target contact, or construct a different reachable one. Already-held A requires an authenticated input history.

**Are counterexamples likely?** Very unlikely on current evidence. Leaving a pole without a new A press is possible, but that is not the same as reaching beyond the barrier. An alternative must retain enough height and clearance through every movement check.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 5 — Downstream collection of the two target stars

An installer or gate crossing is not enough.  These are the remaining routes
from a supplied Area-2 boundary to the actual target objects and save bits,
including the separate accounting needed when progress spans area visits.  A
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

**Conditional Impossibility Result.** Bookkeeping exclusion, not downstream impossibility. Within the certified collection account, Pyramid Puzzle cannot count as collected without the required trigger, spawn, pickup and target-provenance events. That excludes invented credit in that account. The downstream gameplay has positive evidence once access is supplied, so its continuation is not something the current results prove impossible.

**What closes it.** Obtain the `.m64` or recreate everything after the pole on a known game version with every input recorded, then show in that one run the Amp, Grindel, elevator, all five trigger regions, star spawn, pickup, and completion flag with no new A press; a complete zero-A route must separately replace the second-pole jump or reach the necessary contacts another way. A route spread across area visits must instead connect its legitimate earlier secret credit through the reloads, as described in Rank 7A.

**Full Impossibility Result.** Open for the full no-A target claim. Connect actual secret credits and the final award to the certified account, including revisits, and show every way to reach the necessary contacts requires A or an excluded bypass. Authenticating the positive downstream replay would establish its payoff; it would not remove the earlier pole press.

**Are counterexamples likely?** Not as an independent bypass. The downstream Puzzle route has strong evidence after the difficult contact becomes accessible, but the demonstrated lower entry spends an A press at the second pole. Another approach must remove that press.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-7a"></a>

### 🎮 Assemble Puzzle secret progress across ordinary area revisits

**Overall rank: 7A. Family priority: 2. Likelihood: very low as a bypass;
important for complete collection accounting.**

**In plain language.** Touch some Puzzle secrets, leave and revisit the area, and finish the remaining secrets under a different ordinary entry or platform schedule. The game can remember earlier work, so the five contacts need not all occur during the final visit.

**What is already known.** When the hidden-star controller starts, it counts the remaining secret objects and treats the missing ones as completed; if none remain, it creates the target star immediately. Ordinary secret contact removes that secret and records that it should not return, while the controller itself can return. This is a real bookkeeping path omitted from the old touch-five-then-spawn description, but it does not establish free credit: walking far away does not affect the count, and normal object allocation does not simply skip secrets when space runs out. No ordinary history that credits an untouched secret or avoids the difficult contact is known. See the [revisit audit](notes/ordinary-gameplay-route-coverage.md#rank-7a--secret-progress-across-ordinary-area-revisits).

**Conditional Impossibility Result.** No general conditional exclusion of revisits as a route yet. Retaining earned secret progress is legitimate. The certified bookkeeping rules exclude unearned credit within their account, but the real mapping from a missing secret through removal, respawn records and reloads is not complete. Assuming every missing secret was already touched would hide the specific obligation this entry tracks.

**What closes it.** Track each of the five original secrets through its real contact, removal, saved respawn record, every area reload, and the final star creation and pickup in one zero-A history. Either exhibit a useful route that assembles those contacts across visits, or prove that every credited missing secret corresponds to a distinct earlier genuine touch and still requires the hard route. An unexplained missing object or prefilled progress is not a counterexample.

**Full Impossibility Result.** Open. Follow each original secret through contact, removal and every reload, and prove that every credited missing object represents a distinct genuine earlier touch. Then show that splitting those touches across visits cannot avoid the difficult contact. A completed result must cover the live bookkeeping and access histories together.

**Are counterexamples likely?** Very unlikely as a bypass. Retaining earned secret progress is real, but does not yet avoid any difficult contact. Separate visits must make the required contacts easier, not merely preserve credit already earned.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-8"></a>

### Lower Act-3 100-coin-star/Grindel itinerary

**Overall rank: 8. Family priority: 3. Likelihood: high as a conditional continuation; the one displayed pole-jump press remains.**

**In plain language.** Start at the lower pyramid entrance, clip onto the mesh and reverse the teleporter, use the 100-coin star dance at the big steps, make the route's one ordinary jump from the upper second pole, use the homing Amp at the later ledge, then use the Grindel and undescended elevator to cross to the Act-3 platform and collect the star without another A press.

**What is already known.** The published video visibly performs the complete lower-entrance route in a single run, beginning with 95 coins, collecting the 100-coin star, jumping from the upper second pole with its sole displayed A press, continuing through moving-platform play, and collecting Act 3 with no further displayed press; the recovered full transcript fixes the exact five-trial order and confirms that the Amp clip and Grindel/elevator tricks come after the pole and cost no extra press.  A new JP controller test reproduces the pole jump with exactly one press, keeps that same press held without counting another, and lands beside the real Grindel; its tested approach has not yet mounted the Grindel, the `.m64` remains unavailable, and the footage does not reveal exact inputs or collision details.  The checked star geometry also shows that simply standing below the star leaves Mario `75` units too low.

**Conditional Impossibility Result.** No conditional impossibility result for the whole downstream itinerary. The checked flat-floor position is 75 units short of direct Act-3 contact, which excludes that stationary subcase only; the sloped rim is different. The published one-A itinerary instead gives positive evidence that the later route works. Its success cannot be used to claim that every no-A predecessor is impossible.

**What closes it.** Obtain the `.m64` or continue the known-version input reconstruction through the homing-Amp ledge grab, the Grindel's one-unit corner, the undescended elevator's matching corner and descent, and the final star pickup with no new A press; then either leave the second pole without A or connect another clean crossing directly to the recreated state beyond it.

**Full Impossibility Result.** Open for a complete no-A route exclusion. Cover every allowed way of reaching this itinerary's useful post-pole or target-contact positions and prove each needs A or a separately excluded bypass. Input-authenticating the known downstream continuation is useful for testing payoff, but its earlier press is not a proof that all possible entries require one.

**Are counterexamples likely?** Not as an independent bypass. The demonstrated lower itinerary still jumps from the second pole. It becomes a complete no-A candidate only if another approach supplies access without that jump.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-9"></a>

### Upper Act-3 100-coin/star-dance itinerary

**Overall rank: 9. Family priority: 4. Status: parked pending a no-A elevator escape. Likelihood: low-medium only as a conditional continuation.**

**In plain language.** This idea starts with Mario already outside the upper elevator; it does not get him out. After an independent no-A escape, arrange an airborne 100-coin-star pickup that interrupts a ground pound, letting the star-collection animation catch the high platform, then reach the Act-3 star. Stored rollout speed or a controlled fall are possible approaches to that pickup, not established elevator escapes.

**What is already known.** Even a completed continuation would leave one A press if Mario uses the ordinary elevator jump, so Rank 9 is parked as supporting work rather than an active bypass search. The [upper-platform investigation](notes/rank9-upper-star-dance.md) connects a nearby coin, star spawning, the rear-wall catch and landing in one conditional local test; all nine tested later pickup timings fail. Coq checks the star-height writes, timing, contacts and caught-floor operations, but the test grants an airborne start outside the elevator and 99 coins. The nearby shelf's small drop does not establish the needed approach. The independent elevator escape, clean arrival, complete live execution and final pickup remain unproved; the flat platform still leaves a 75-unit gap to the target star.

**Conditional Impossibility Result.** No conditional impossibility result for the supplied outside-elevator continuation. A conditional local test reaches the catch from a granted airborne start and coin setup; the nine later timing failures exclude only those trials. This is a helper after an escape, not a proof that an escape is impossible. Its parked status is sufficient to avoid treating it as an independent bypass.

**What closes it.** First demonstrate an independent no-A elevator escape and show that its actual endpoint can reach the proposed pickup with the required coin history and unused 100-coin reward; do not assume Mario is already outside. Only then resume this continuation: reach the checked coin-contact position with 99 coins at the first ground-pound update, or another useful placement, and follow one real run through spawning, the freeze, resumption, movement and collision checks, catch, landing, dance and final Act-3 pickup without a new A press. Finishing the downstream portion alone would not close the full route.

**Full Impossibility Result.** Open through its prerequisite. First resolve whether a no-A elevator escape or another clean access path can reach a useful pickup state. If none can, this downstream proposal is blocked without disproving the working supplied continuation. If access survives, cover coin history, star timing, catch and final target contact in that same history.

**Are counterexamples likely?** Not as an independent bypass, so this should remain parked. Its useful star timing starts after Mario has escaped the elevator. Finishing that continuation cannot recover the A press spent on an ordinary escape.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-26"></a>

### 🎮 Negative-depth transport to a fresh or older star

**Overall rank: 26. Family priority: 5. Likelihood: very low.**

**In plain language.** Use the negative-depth/dialog machinery not to install
Ink, but to arrange a fresh 100-coin star or another already tangible star at a
height and time that provides a useful collection/dance transition.

**What is already known.** Fresh-star timing is modeled, but the checked
successor placements miss vertically by more than `96` units.  No alternate
relative placement or suitable older-star setup is known, and normal target
provenance prevents substituting the wrong star for Act 3 or Act 6.

**Conditional Impossibility Result.** Conditionally excluded at seed creation under Rank 19's accepted writer, timer and action/input conditions: no useful negative seed is then available without A. That is sufficient to set aside this seed-dependent route within the accepted scope. With a seed granted for transfer testing, the checked fresh-star placements miss, but they do not exclude every older star or relative placement.

**What closes it.** Supply an exact reachable star position/lifecycle and
overlap schedule, or prove every eligible fresh/older star remains outside the
necessary contact envelope.

**Full Impossibility Result.** Open beyond that scope. Either establish the seed-to-A conditions for every allowed history, including imports and entry resets, or prove all remaining reachable star placements and pickup schedules cannot provide the required transfer. Keep a fresh reward, an older tangible star and the actual target's provenance distinct.

**Are counterexamples likely?** Very unlikely. This combines an unproved useful negative-depth setup with an unproved suitable star position, and checked placements miss. Supplying the desired star position would show a payoff, not solve either setup problem.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Family 6 — Goomba raising and PU transport

Technical background: [Goomba raising](notes/goomba-raising.md) and
[nonlocal endpoints](notes/area1-nonlocal-endpoints.md).

<a id="route-rank-16"></a>

### 🎮 Goomba H/F/R raising, PU capture, and Spindel handoff

**Overall rank: 16. Family priority: 1. Likelihood: very low as a full route.**

**In plain language.** Repeatedly raise a Goomba with a hit-and-depart, far
reset, and near rearm cycle; then try to use a parallel-universe coordinate
alias, capture the object in the useful segment, and hand the setup to Spindel
or another moving object.

**What is already known.** The H/F/R primitive and binary32 velocity arithmetic are real, but full-float object distance means that a PU alias neither transports the Goomba nor keeps a distant Spindel loaded.  The original post-collision schedule permits only `31` useful rises in the accepted `91`-frame top window, and the formerly open raw-Object timing still has to alternate a non-rising return/reset frame with a rising departure frame: its exact return-first form permits `45` rises, while a deliberately more favorable phase shift permits `46`, reaching exact binary32 Y=`1017` from Y=`51`, still `774` below Y=`1791`.  Thus both finite top-window timing classes are refuted even if their coordinate writers are granted for free; physical singleton transport, same-segment capture, repeatability, longer independent timing, and every handoff remain unconstructed, while failed nonfinite casts trap rather than produce a continuing coordinate.

**Conditional Impossibility Result.** Proved finite timing-class exclusion. In the accepted 91-frame top window, the original raising schedule permits 31 rises and the more favorable return/departure schedules at most 45 or 46. Even the favorable endpoint Y=1017 misses Y=1791 by 774 units. This is sufficient to reject those complete timing classes, even with their coordinate writers granted; it does not exclude earlier raising or a different rise-producing transition.

**What closes it.** A counterexample must now leave the checked finite timing family by supplying a clean longer raising interval or a defined action, FAR-state, velocity, or scheduling effect that can produce rises more often than every other frame, then keep the same live Goomba through physical PU transport, moving-collision capture, every handoff, and a target-star continuation; an impossibility result must rule out those departures and the remaining transport and handoff obligations, since finding either raw-Object writer alone no longer rescues the `91`-frame top proposal.

**Full Impossibility Result.** Open. Cover longer reachable preparation intervals and any action, reset or scheduling change that could beat the alternating-rise bound. Then cover physical transport, live object retention, capture and handoff. A PU coordinate alias or a working supplied displacement does not itself move the Goomba or keep a distant actor active.

**Are counterexamples likely?** Very unlikely. Both checked raising schedules miss the required height substantially. A survivor needs a longer clean opportunity or different raising mechanism, followed by the still-missing transport and handoff.

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

### 🎮 Carry a stale Eyerok-hand address into Area 2 in JP

**Overall rank: 14. Family priority: 1. Likelihood: retired in the audited stock model; reopening it requires a failed source-to-execution premise or machine-level behavior outside that model.**

**In plain language.** On original JP, this idea tried to make Mario remember the static tunnel warp as his floor while separately remembering an Eyerok hand as the moving platform, so that after the warp unloaded the arena the game would apply one Area-2 object's movement through the old hand address.  Both the far-away magnified version and the ordinary version under the warp are now blocked in normal stock play.

**What is already known.** A natural JP warp remembers no hand, while forced sleeping-hand comparisons move Mario by `(0,0,0)`; destroying a hand can align its old address with Area-2 allocation 53 or 54, but every checked replacement is motionless except Spindel, whose exact effect is only about 8 down and 38 backward.  Installation at the warp requires a hand floor in `[-569,-411]` or `[608,766]`, yet fist-push remains far too low (and both tested central cases also stop before the warp), while one-hand eye-show crosses the warp with its top only at `-1027`; even granting the hand's largest hit-induced rise reaches only `-739`, still 170 below the lower band, and target and double-pound rises remain horizontally short.  The other hand cannot arrive later in the required state, SSL Area 3 has no later object that moves Mario between the two samples, an unreused dead-hand slot has zero useful motion, and the separate far-away version is already disproved by its support, transport, dialog, and raw-distance checks.  See the [original-JP stale-hand audit](notes/jp-eyerok-stale-hand.md).

**Conditional Impossibility Result.** Audited stock-model exclusion, with its scope retained. The checked hand-pose, sibling timing, later-writer and lifetime cases do not install a useful hand at the tunnel warp or supply the required replacement motion. That is sufficient to retire the stated stock construction within that classification. It is not a completed proof that every allowed linked execution follows the classification.

**What closes it.** The route is closed within the audited stock source-shaped model; a full formal verdict now needs the real linked execution to be shown to follow the checked hand-pose, sibling, writer, and lifetime classification.  A concrete failure of that connection—such as a hand pose outside the stock split, an unexpected later Mario-position writer, or nonzero bytes surviving in the freed slot—would reopen one exact case and make the small Spindel displacement worth testing, while out-of-bounds writes, ACE, DMA, and continuation after undefined behavior remain outside the current execution model and require a retail-machine extension; Eyerok still supplies no Act-6 continuation.

**Full Impossibility Result.** Open at the source-to-execution connection. Establish the actual hand poses, support selection, update order, position writers and freed-slot contents across every relevant warp history. A defined exception must be checked as a new case. The result concerns this Eyerok-to-Act-3 proposal; no Act-6 continuation is supplied.

**Are counterexamples likely?** The stated stock route is ruled out under the audited conditions. This small residual estimate concerns a different defined history outside that classification, not a chance that the proved stock case works. No useful hand installation or replacement movement is known.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-15"></a>

### 🎮 Board and ride a raised hand into the lower route

**Overall rank: 15. Family priority: 2. Likelihood: medium as a proved local primitive, very low as a full route.**

**In plain language.** Hold A before boarding, stand idle on the real Eyerok hand, and press B once just before its double-pound rise; the game turns that ordinary B press into a jump-kick without a new A press, allowing Mario to catch and ride the hand upward, although the hand still stops far below the tunnel.

**What is already known.** A verified retail test uses held A and one new B press to ride the real hand to Y `-943`, but its earlier setup is staged. The new US/JP proof executes the real velocity addition, terminal-speed check and height store for the selected flight, deriving the rounded output instead of assuming its height bound. A finite certificate checks its six upward and first four downward steps: the rise is `285`, within the existing `288` allowance. The airborne action adds no new launch while rising and switches gravity to `-20` once falling. These hand stores preserve separate Mario cells. Under the same closed-hand and seed-through-31 conditions, even the generous departure remains seven units short of the tunnel. The full cycle, floor selection, reset and intervening effects are still open. See the [selected-flight proof and limits](notes/rank15-eyerok-controller-ride.md#selected-double-pound-flight-actual-velocity-and-height-updates).

**Conditional Impossibility Result.** Proved height and speed barriers within the specified hand model, now with a constructed US/JP velocity-and-height segment for the selected double-pound flight. Its checked rise is 285, its upright closed-hand top is at most -943, and the existing ideal departure bound for every integral seed through 31 still misses the tunnel by at least seven units. Reboarding within that same height/seed envelope cannot cure the shortfall; proving that all reboards stay there remains separate. The broader two-hand model still bounds the top at 1179 and grants Mario 630 more, reaching 1809 below 1889. These are conditional payoff exclusions, not a complete live-cycle classification.

**What closes it.** For the selected flight, connect the water/floor tail, surrounding wall and attack work, impact and reset to the next launch on the actual support. That would justify repeating this named cycle without reopening the whole fight. Broader closure must additionally derive other hand phases, owners, lifetimes and reached call effects from ordinary play. A different launch height, collision mesh, larger legitimate seed or intermediate support is a separate candidate. A successful route still needs its wall, hand-to-warp and Act-3 continuation; Act 6 remains separate.

**Full Impossibility Result.** Open. The new proof constructs the actual movement prefix for the ten specified flight steps and the airborne action cases; it does not establish the complete sequence between those checkpoints. Derive floor and contact selection, the terminal clamp and impact/reset, and each later launch before claiming a repeated-cycle exclusion. Full route exclusion additionally needs all stronger speed predecessors, alternate hand/support cases and departures outside the height model.

**Are counterexamples likely?** Unlikely as a complete route, although the local hand ride is real. Checked height, speed and repeated-cycle bounds leave Mario short. A stronger clean speed source, intermediate support or different departure is needed.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-22"></a>

### 🎮 Second-hand ceiling to the Area-2 Y=1280 tier

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

**Conditional Impossibility Result.** Conditional departure exclusion. Starting no higher than the checked hand ceiling of 1179, the seam-free B speed-kick and already-held-A jump-kick miss the Y=1280 tier under inherited speed at most 48, at most 35 eligible steps and their respective 12- and 13-quarter-step travel budgets. This is sufficient for those departure classes. The fresh-A triple-jump success is outside the no-new-A claim.

**What closes it.** Construct a faster no-A predecessor, post-bonk recovery,
seam/quantum-tunneling path, or PU-cast entry; or prove all reachable departures
remain inside the existing speed and wall bounds.  Then connect the landing to
Act 3.  Act 6 remains separate.

**Full Impossibility Result.** Open. Prove every reachable no-A departure satisfies those speed, duration and wall-avoidance bounds, or classify the remaining bonk recovery, seam, support and coordinate-alias alternatives. The generous hand ceiling is a bound, not a demonstrated attainable start; any surviving route needs its actual warp and landing history.

**Are counterexamples likely?** Very unlikely under the checked height and speed conditions. Even generous hand height does not make ordinary no-new-A departures reach the tier. A faster reachable predecessor or different collision path is missing.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-23"></a>

### 🎮 Update-11 wake-sandwich Pedro installer

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

**Conditional Impossibility Result.** Local squeeze-duration exclusion only. The checked staggered wake allows ordinary entry on update 11 and closes on update 12, so it cannot provide repeat-ground acceleration. The named common air-update calculation has only one useful gain, conservatively bounded by 4. That is enough to reject the repeated speed-engine version, not the one-frame floor/platform mismatch proposed as an installer.

**What closes it.** Authenticate the exact predecessor and input history, then
prove or refute the floor/hand cache mismatch in the required update order.

**Full Impossibility Result.** Open. Connect a legal predecessor and exact action/update order to the floor and platform reads, then prove the useful mismatch cannot survive or produce one that does. Cover other reached air-action writers before extending the common-update speed bound. A one-frame opportunity needs a capture proof, not a long-term acceleration argument.

**Are counterexamples likely?** Very unlikely as a full route. The squeeze lasts briefly, gives little ordinary speed gain, and has not produced the useful floor mismatch. Its remaining interest is a precisely timed change in which floor Mario remembers.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-28"></a>

### 🎮 Attack and reboard a rising hand

**Overall rank: 28. Family priority: 5. Likelihood: very low.**

**In plain language.** Hit an Eyerok eye, make its hand rise, then fall back
onto or reacquire its moving collision before it returns or disappears.

**What is already known.** Standing on either hand top is above the eye
hitbox, so the simple “stand, attack, ride” plan fails.  Tested nonlethal
reboarding needs an injected prior long-jump and happens only after return
home; tested lethal rises never select the platform before deletion.

**Conditional Impossibility Result.** Simple standing-attack exclusion only. With the checked hand-top pose and eye hitbox, Mario stands above the eye and cannot perform the proposed stand-attack-ride contact. The tested lethal failures and staged nonlethal reboard exclude their supplied cases, not every attack pose or later reacquisition. No general conditional impossibility of attacking and reboarding is established.

**What closes it.** Authenticate or refute the nonlethal predecessor and its
earlier A edge; generalize the lethal pose/steering search; and, if reboarding
succeeds, prove the hand-to-warp and Act-3 continuation.

**Full Impossibility Result.** Open. Cover the controller-reachable attack positions, action and A history, steering, hand collision loading and deletion timing. Prove every useful reacquisition fails or occurs too late, or connect one clean success to a usable departure. A supplied earlier long jump cannot serve as the missing no-A predecessor.

**Are counterexamples likely?** Very unlikely. Standing attacks miss the eye, while the supplied successful reboarding relies on an earlier long jump and returns too late for the proposed rise. Both a clean predecessor and useful timing are missing.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-29"></a>

### 🎮 Sleeping-hand Pedro speed bootstrap

**Overall rank: 29. Family priority: 6. Likelihood: very low.**

**In plain language.** Build enough speed without pressing A to cross the sleeping hand's narrow outer wall in one movement step and land in the small space between its floor and ceiling.

**What is already known.** The crossing needs a quarter-step over `100`, which means directional speed over `400`; an injected speed of `424` proves the landing works but does not supply that speed cleanly.  The [Rank-29 preload and cycle audit](notes/rank29-sleeping-hand-preload.md) checks both game versions and shows that normal entry clears old speed, the Area 2/Area 3 warp only preserves existing speed, the complete stock roster has none of the usual large-speed actors, and a sleeping hand skips the attack check that could bounce Mario; ordinary air growth would need `1,934` uninterrupted frames, while the generous episode bound allows fewer than 400 and reaches only speed `170`.  The former reset-evading-cycle residual is also finite now: all five moving-collision owners reload their mesh, carry never changes forward speed, their largest possible one-frame Y change is `78` rather than the strict greater-than-`100` needed for `OFF_FLOOR`, ordinary landing damps before any ground-step departure, steep-floor push replaces speed with `16`, Area 2 has no burning collision, and the only preserving flat butt-slide-air bounce consumes state zero and cannot repeat without returning through the speed-`100` ground-slide normalization.

**Conditional Impossibility Result.** Conditional stock-cycle exclusion. In the checked owner, collision-refresh, action and episode model, ordinary growth stays far below the speed over 400 needed for the sleeping-hand entry. Stock platform drops cannot create the required off-floor gap, and the one preserving butt-slide bounce cannot repeat without speed normalization. This is a useful exclusion of that cycle model, not proof that every defined gameplay history belongs to it.

**What closes it.** The ordinary stock cycle is closed in the source-shaped owner model. The remaining conditions can be investigated through source proofs and a bounded controller-driven search for the first unexpected support owner, missed collision refresh, or speed-preserving action transition. A candidate must be replayable from an allowed start, build speed over `400`, and carry it through the instant warp to the proven hand landing; finding nothing in a finite search is not a universal disproof. A proof that every allowed history obeys the checked ownership, collision, action, episode and speed-reset rules would instead extend the existing closure. The search remains within defined, in-bounds gameplay; memory corruption and arbitrary state or code modification are outside its scope.

**Full Impossibility Result.** Open. Establish the live owner tracks, floor refreshes, action transitions, entry resets and episode bounds throughout the relevant no-A history. Exclude or account for any first departure from those rules before it creates and transports the required speed. The injected speed-424 landing proves only the payoff of an independently supplied speed source.

**Are counterexamples likely?** Very unlikely in the checked stock setting. Normal speed growth and examined landing or moving-floor cycles cannot reach the requirement. The supplied fast landing shows only what could happen with an independent clean speed source.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

<a id="route-rank-30"></a>

### 🎮 Seams, moving boundaries, or partial updates

**Overall rank: 30. Family priority: 7. Likelihood: very low.**

**In plain language.** Slip between moving collision pieces, or find a frame
in which action state changes but hand movement or collision only partly runs.

**What is already known.** The exact positive-double sibling approach has no
sample that is both horizontally and vertically eligible.  In the modeled
no-external-writer lifecycle, a live hand cannot enter the movement-only
partial-update guard.  Other seams and transformed phases are not exhaustive.

**Conditional Impossibility Result.** Two narrow model exclusions. The checked positive-double sibling approach has no simultaneously eligible horizontal and vertical sample. In the specified lifecycle without an extra flag writer, a live hand also cannot take the movement-only partial-update branch. These are sufficient for those cases, but neither is an exhaustive result about all moving seams or flag histories.

**What closes it.** Enumerate every transformed hand mesh and phase, moving
boundary, wall response, partial-update flag writer, and external effect in
linked execution.

**Full Impossibility Result.** Open. Cover every relevant transformed mesh, phase, wall response and writer of the partial-update flags in actual execution. Derive the flag and lifetime conditions instead of assuming that no extra writer runs. A surviving seam must be reachable and useful for departure or contact, not merely a geometric gap.

**Are counterexamples likely?** Very unlikely on present evidence, though coverage is incomplete. The checked seam and partial-update cases fail. A promising lead needs an exact reachable gap or timing window with a useful departure.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

### Eyerok approaches retired at the current formal boundary

These are below all active ranks.  “Retired” means disproved inside the named
audited or source-shaped boundary; applying that boundary to every allowed
selected-program execution still needs its stated connection. This does not
claim a separate retail-hardware impossibility theorem.

| Overall rank | Family priority | Approach in plain language | Conditional Impossibility Result | Full Impossibility Result | Likelihood |
|---|---|---|---|---|---|
| Retired | R1 | Let a destroyed hand's own fragments take its stale slot immediately. | Under the audited order, fragments allocate before the hand frees; the sibling's fragments miss the one-active-update window. | Connect every relevant allocator and callback step to that timing and exclude an omitted allocation before apply. | Near zero for this construction. |
| Retired | R2 | Stack nonlethal hits or use two hands for unbounded height. | Accepted hits reset at home and have bounded impulses; the checked support models refute unbounded height. | Derive the reset, support and writer conditions for all reached hand updates and cover any intermediate support outside the models. | Near zero. |
| Retired | R3 | Preserve positive velocity in zero gravity and rise forever. | The required grounded or airborne-positive seed is unreachable in the archived model. | Re-establish the relevant bound in the active program and classify every reachable velocity/gravity writer; the archive alone is insufficient. | Near zero. |
| Retired | R4 | Gain height merely by toggling between Areas 2 and 3. | Ordinary instant-warp displacement is `(0,0,0)` and preserves coherent kinematics. | The displacement component is closed under that contract. Connect live transitions and handle retained platforms or changed receivers separately under Rank 12A. | Near zero as ordinary warp displacement. |
| Retired | R5 | Collect Eyerok's boss star as a requested star. | Its index is `3`, not target index `2` or `5`, so normal provenance excludes substitution. | Connect the actual collection and save write to that provenance; remaining defined receiver/save effects belong to Rank 31. | Closed under normal provenance. |

## Family 8 — Generic memory, collision, scheduler, and upstream escapes

The defined cases are necessary for proof exhaustiveness but currently poor
gameplay leads; a concrete valid witness would immediately move one much
higher.  Machine-only cases are recorded separately so their absence from
Clight is not mistaken for a retail result.

<a id="route-rank-31"></a>

### 🎮 Defined memory/control escapes and deferred machine-only corruption

**Overall rank: 31. Family priority: 1. Likelihood: very low as a known clean
route; high proof importance.**

**In plain language.** Make a valid pointer name the wrong live field or object, have a reachable outside routine change protected state, retain a stale warp collision, alter a hitbox, or forge an action, timer, or owner through an otherwise valid game write.  Out-of-bounds overwrites, arbitrary code execution, and raw DMA are tracked here only as deferred retail possibilities because the current source execution cannot perform them.

**What is already known.** A defined one-store State/Object divergence must target one endpoint block, so a different CompCert allocation cannot wrap into it; direct platform writers are censused, and collision-cache and hitbox observations have explicit escape classifiers. The four-contact object-list limit can drop an additional object contact, but does not invent one or remove a terrain wall. Animation metadata alone does not move Mario, although specific action bodies such as the ground-pound startup in Rank 10A do. For the writable action tables, all 38 modeled units per version contain no initializer or export alias, every body occurrence is a final read, the three expected linked blocks are valid at initialization, and ordinary level transitions do not name them; the completed reached-execution theorem constructs a relation that leaves those blocks private and carries it through every actual Clight step and outside call in every finite successful selected run without changing a table byte or returning a table pointer. Valid same-block aliases to other state, wrong logical object slots, stale pool bytes, known-function retargets, and outside-call effects on public or passed state remain possible in Clight. By contrast, a successful invalid load/store, invalid function target, ACE continuation, post-undefined-behavior MIPS behavior, DMA, interrupt, or self-modifying-code effect has no witness in the current Clight run; that absence is a model limitation, not a retail disproof. No clean in-scope corruptor is known.

**Conditional Impossibility Result.** The private writable-action-table branch is proved closed for every finite successful run of the selected initialized Clight program. The checked protection covers those three private tables, not the nine exported landing-duration records or all Mario state. Memory-separation and invalid-pointer results exclude other exact subcases. This is sufficient for the named source-model branches; it is not a blanket exclusion of every defined alias, callback or lifetime effect.

**What closes it.** The writable-table part is closed in the selected successful in-bounds Clight model; the remaining in-scope work is to prove live pointer/block/offset provenance for the other protected stores and link same-frame collision clearing, traversal, owner return, hitbox writers, and object-pool epochs, with any failure identifying the exact valid store, call, cache entry, or field.  For the deferred part, first add a retail MIPS/hardware execution model with the RAM layout, devices, interrupts, selected-binary connection, and explicit post-undefined-behavior rule.  Until then, report out-of-bounds, ACE, and DMA variants as outside the current model rather than open Clight obligations or disproved routes.

**Full Impossibility Result.** Open for the remaining in-scope cases. Prove live pointer and receiver identity, collision-cache clearing, owner returns, hitbox writes and allocation lifetimes for the public or passed state that matters. Match the selected-program boundary to the route. Outside-model machine effects remain outside this project scope; their absence from Clight is not a retail impossibility result.

**Are counterexamples likely?** Very unlikely as an identified gameplay route. These are mainly shared proof obligations, and the selected initialized-program action-table case is closed. A remaining defined effect must become a reachable movement or contact advantage; deferred outside-model modification is not rated here.

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

**Conditional Impossibility Result.** Excluded by the agreed starting scope, not disproved as a gameplay mechanism. The accepted normally initialized SSL Area-1 boundary supplies the specified clean state, so an earlier castle-created mismatch is not an allowed input to that scoped theorem. This is sufficient to set the upstream investigation aside for the present claim, without calling the upstream route impossible.

**What closes it.** Treat it as a separate project: define the earlier start,
authenticate the castle route and input history, carry every relevant memory
cell through the transition, and show the resulting state satisfies—or breaks—the
Area-1 boundary.  It should not block the scoped theorem unless a concrete lead
appears.

**Full Impossibility Result.** No upstream impossibility result is claimed or required for the agreed SSL-start theorem. A broader claim would need a separately defined earlier start, authenticated controller history and a proof of what every castle-to-SSL transition preserves or resets. It must not inherit the clean Area-1 state as an unexplained conclusion.

**Are counterexamples likely?** Not rated for the current claim. This changes what can happen before the agreed Area-1 start, which the scoped proof takes as given. It has not been disproved, but meaningful odds would require a separately defined earlier-start investigation.

[Back to the at-a-glance ranking](#at-a-glance-ranking)

## Retired and corrected ideas

These unranked entries preserve scoped exclusions and corrections. Some reject
a specific construction; others correct an inference that the tests never
justified. They do not retire the broader active routes. They are grouped by
family so completed work and earlier mistakes are not repeatedly rediscovered.

The same two result columns are used here. A correction to a false statement
is labeled as a correction, not as a gameplay impossibility theorem. The full
column names the wider proof obligation where one remains; an outside-model
variant is not a requirement to extend this project's scope.

| Family / retired priority | Proposal | Conditional Impossibility Result | Full Impossibility Result | Likelihood as stated |
|---|---|---|---|---|
| Input semantics R1 | “No A edge means Mario cannot move upward” | Correction: false. B rollout and already-held-A actions can create upward movement without a new edge. | This claimed impossibility is false; use the correct input-edge model instead. | Closed misconception. |
| Input semantics R2 | “A is the only way to leave the second pole” | Correction: false. Z soft-bonk, below-bottom freefall, walls, and health/version branches exist. | This claimed impossibility is false; assess whether each legitimate exit crosses the gate instead. | Closed misconception. |
| Direct gates R1 | The normalized pole soft-bonk clears the lower route | Refuted for the modeled trajectory; it loses the needed height/clearance. | Extend the movement and collision bound to every relevant live release, or keep the exclusion limited to this trajectory; alternate exits remain under Rank 24. | Very low for that trajectory. |
| Direct gates R2 | Ordinary upper jump-kick/rollout clears the wall by height alone | The stock envelopes peak at `135` and `227.5`, below `231`; ordinary entry also removes Wing. Hypothetical Wing samples above the cutoff are a separate conditional case, not below-threshold evidence. | Derive the launch and query bounds for every reachable departure, including changed support and any legitimate post-entry cap; broader crossings remain under Rank 10. | Very low under the checked bounds. |
| JP platform R1 | Intact stock top simultaneously touches the warp and is selected from the same sample | Refuted by the imported stock geometry. | Connect the fixed same-sample geometry to live queries where applicable. Different samples, relocation and clones are separate active routes, not failures of this local exclusion. | Closed for the fixed same-sample model. |
| JP platform R2 | Stock yaw-only top motion supplies the needed vertical PU change | Refuted in the checked arithmetic model. | Connect the actual top fields and apply step to the yaw-only arithmetic. Other payload fields or replacement objects need separate coverage. | Very low as stated. |
| PU/casts R1 | NaN, infinity, or failed large cast becomes a usable terrain coordinate | Modeled retail invalid conversion traps before a continuing query. | Bind the actual conversion and processor mode to the checked trap behavior. A different modeled mode needs its own result; no unmodeled continuation is granted. | Very low. |
| Goomba R1 | Original post-collision Goomba H/F/R schedule reaches the target height | It permits `31` useful hits where `83` are required. | Show the relevant gameplay schedule stays inside this timing class. A longer independent preparation interval remains outside the local exclusion. | Closed for that schedule. |
| Goomba R2 | Revised raw-Object timing reaches the target within the same top window | Return/reset cannot rise, so the exact schedule permits `45` rises; even granting a productive first frame permits `46`, ending at Y=`1017`, `774` short. | Establish the 91-frame window and two-phase transition rules for each reached candidate; account for any earlier preparation or additional rise writer under Rank 16. | Closed for the accepted `91`-frame timing class. |
| Animation/HOLP R1 | [Turning action `0xBD`](notes/turning-animation-upwarp.md) creates a 189-unit rise | The relevant normalization is `189/189 = 1`; metadata preserves position. | The arithmetic is closed. Connect actual receiver and buffer ranges if claiming all reached animation work preserves position; outside-model DMA is not a current obligation. | Closed as arithmetic. |
| Animation/HOLP R2 | Turning/HOLP moves Mario through the rendered hand matrix | The matrix can update `heldObjLastPosition`, but turning drops held objects first; HOLP affects a later drop/throw, not Mario's gameplay position. | Cover held-object survival, the actual receiver and any later drop or throw effect. A HOLP change alone is not a Mario-position change. | Very low. |
| Ink R1 | Shell `+42/+45` graphics offsets accumulate forever | The checked normal-frame model reanchors the small addition; the newer helper-based diagnostics are finite evidence, not a live all-history proof. | Cover all relevant live shell calls, refreshes and later writers; ordinary-frame reanchoring does not prove a universal gap bound. See Rank 25. | Very low alone. |
| Ink R2 | Fire-particle `prevObj` moves Mario | The separate-particle copy tail preserves Mario under its stated receiver and storage conditions; the flame is the intended receiver. | Derive the distinct live particle receiver throughout spawning and reuse; the proved copy tail already excludes a Mario write once those conditions hold. | Closed under normal receivers. |
| Ink R3 | A direct stock Area-1 door supplies the automatic-dialog route | No direct Area-1 macro/script door root exists. | Connect the direct-root census to the complete legal spawn and interpreter paths for a suitable dialog actor. An injected debug actor is not an allowed witness. | Very low as a direct root. |
| Held-object R1 | A carried box remains a useful moving collision platform | Carry scripts disable or lose the needed collision. | Follow actual collision retention and owner identity through carrying and release; a different object remains a separate proposal. | Very low for the box. |
| Held-object R2 | Pickup can beat the warp interaction at node `0x1E` | Handler order gives the warp interaction priority. | Connect live interaction dispatch, contact order and cache contents to the checked priority. Cover remaining defined retargets rather than assuming normal receivers. | Very low under normal dispatch. |
| Held-object R3 | Obtain `heldObj == node 0x1E` through enumerated stock pickup or stale-held-slot paths | The counterfactual drop would relocate the live entrance, but audited stock paths do not produce that held pointer. | Prove every reachable held-pointer and slot-lifetime path is covered by the audited cases. A moved-warp payoff alone does not construct that pointer. | Very low for enumerated paths. |
| Lifecycle R1 | Direct Area-2/Area-3 instant warp adds height | Its displacement is zero and coherent kinematics are preserved. | The ordinary displacement component is closed under its contract. Connect live transitions and handle support, receiver and lifetime changes separately under Rank 12A. | Closed as ordinary warp displacement. |
| Lifecycle R2 | Reload or the wrong star directly sets a target bit | Coherent reload preserves save facts; Eyerok/100-coin/other stars have different indices. | Connect the actual reload, collection and save write to the certified provenance rules. Defined receiver or save-history failures remain under Rank 31. | Closed under certified provenance. |
| State-first R1 | Area-1 palm/tree pole push is a late State-only writer | It executes before PLAYER; the later correct copy resynchronizes State/Object. | Establish the real caller order and completed correct copy for every relevant use; later callers or redirected copies remain separate active cases. | Closed for that caller/order. |
| Object impulse R1 | Tweester or jumping-box search already found an installer | Bounded searches found synchronized elevation but no positive view gap, warp/top capture, or target crossing. | No full exclusion follows from these failed trials. Cover all relevant impulse histories or find a clean useful split; retain the existing finite-test label. | Very low for tested schedules. |
| Act-3 downstream R1 | The failed direct Grindel steering test refutes the lower itinerary | Correction: the test did not attempt the transcript's Grindel/elevator misalignments, so it supplies no such exclusion. | A faithful account of the actual itinerary is needed; full no-A exclusion must address its accessible predecessors rather than extrapolate this failed trial. | The negative inference is invalid. |

## What would count as a complete counterexample

A complete counterexample for either target is not merely a large displacement,
a target-region coordinate, or a star-spawn event.  It must provide one
connected execution that:

1. starts at the declared SSL Area-1 boundary, or explicitly extends and
   replaces that boundary;
2. has an authenticated input history with no new A edge;
3. reaches the required contacts through actual collision and object-list
   execution, crossing the Area-2 gates or demonstrating a route around the
   proposed separator rather than assuming that separator is exhaustive;
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


### Reading the 20-case gap comparison

The [gap catalog](notes/position-split-catalog.md) now labels every “What that tells us” cell by its scoped verdict and evidence: proved insufficient, geometrically unavailable, unavailable under route constraints, finite-tested, still-live producer, or helper only. Source-only and unresolved-coverage labels prevent an unproved route from being called impossible. Some rows have two labels because a missing local pole does not exclude a remote tree or ordinary ledge. These are bookkeeping categories, not new proofs; all route estimates are unchanged.
