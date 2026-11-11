# Backward from the timer-130 handoff: fresh cache, push and crawl

The useful handoff remains possible from a supplied state, but this follow-up
does not find a normal no-A way to produce that state. It connects more of
the actual generated code and implements a backward proposal search. The
important distinction is between **being high and crawling** and **being high
and crawling with the right fresh low floor**. Forty-one sampled continuations
reach high crawl before timer 130; all forty-one remember the spinning top's
high floor. None produces the complete low-cache handoff.

The new Coq composition proves that the remembered height at the stopped
quarter equals the primary geometry query's actual return, under explicit
conditions on the intervening executions. Consequently that final cache is
768 if and only if the primary query returned 768. An earlier update's 768
cache, or the push's separate floor query, cannot supply the value through
this conditional path. This is not yet a theorem that the cuts occur in one
reachable Mario update: the actual paths between the cuts are premises, their
four-cell preservation conditions are premises, and membership in one
`execute_mario_action` activation has not been established.

## What is connected, and what remains open

The source order is geometry preparation, special floors, object interactions,
crawl guards and speed calculation, ground-quarter queries, display refresh,
floor alignment, Mario-object position copy, then the following update's warp
contact. The existing source links are in `InkActionPassHistory.v`,
`InkFloorHistorySource.v`, `InkObjectPushHandoff.v` and
`InkStoppedCrawlAlignment.v`. The newly checked segment ends at the ground
caller's `break`; it does not reprove the later alignment/copy/warp lifecycle.

At the working pad, the primary query can select the low 768 floor while
Mario's movement Y is 1741. An object push moves X/Z east. The push tests a
floor at its candidate destination using a **local** output pointer. It does
not replace Mario's remembered floor. The crawl quarter then has its own
local floor and ceiling queries. With intended Y=1741, local floor=1280 and
ceiling=1523, the quarter takes the ceiling-stop return before committing a
new position or floor. Existing alignment can subsequently move Mario down
to the remembered 768 while display Y remains 1741.

These numbers have different evidential roles. `InkTimer130Geometry.v`
checks bounded source-mesh calculations, including the underside and sample
floor tests. The native receipt observes the complete supplied-state suffix.
The new execution theorems require the actual calls to return the stated
values; the mesh calculation and native observation have not been turned
into a proof of those calls' loaded surface lists and results.

### Actual primary query and push

New module: [`InkObjectPushQuery.v`](../../proofs/InkObjectPushQuery.v).

* `ipq_primary_query_supplies_fresh_cache` extracts the primary `find_floor`
  invocation and its actual output memory, followed by the real `floorHeight`
  assignment. It proves action and movement Y survive that query/store from
  the same input memory. The numeric returned height is not assumed to be 768.
* `ipq_destination_query_and_commit_preserve_cache` composes the actual
  destination query with the generated conditional X/Z commit. It preserves
  movement Y, action, remembered floor pointer and remembered floor height.
  The complete floor-call frame is derived, not a new caller hypothesis.
* `ipq_completed_push_exposes_actual_query_cut` extracts the post-wall cut
  from a completed actual push invocation, retaining the false-distance
  alternative and preceding math/wall execution. Fresh local allocation
  supplies the local/Mario separation, and cleanup preserves the four cells.

The standalone segment requires the actual MarioState global, readable Y,
the matching `_m`, unshadowed selected `find_floor`, its real local-floor
binding and separate blocks. The full push theorem derives that separation
from validity before function entry. It does not prove a live actor reaches
this push through `interact_grabbable`; it does not construct the push's
earlier math/wall prefix or establish a particular displacement.

### The five crawl queries and real caller break

New module: [`InkCrawlLiveQueries.v`](../../proofs/InkCrawlLiveQueries.v).

`icl_live_queries_to_caller_break` uses one memory chain of actual calls:
lower wall resolution, upper wall resolution, `find_floor`, `vec3f_find_ceil`
and `find_water_level`. It constructs their actual expression/assignment
wrappers, the quarter's stopped tail, the real return and the caller's result
assignment and loop break. The old terminal `InkCrawl973QueryCut` is derived.
It is no longer an independently supplied endpoint for this theorem.

`InkCrawlLiveQueryChain` explicitly requires the live floor/ceiling return
values 1280/1523, intended Y=1741 at the relevant reads, an actual non-null
floor output with a weakly valid surface pointer, a properly typed wall
result, and writable wall storage. Three remaining finite frames protect
six MarioState cells across the two wall calls and ceiling wrapper: action
at offset 12, position at 60/64/68, floor pointer at 104, floor height at 112.
The ceiling wrapper must also preserve the local floor output. The floor
call's frame is proved from its actual implementation; the water call is
proved to preserve all memory. Entry allocation, the wall write and local
cleanup are accounted for. These frames do not preserve Surface contents,
MarioObject or a live item by implication.

Material caller assumptions remain: pre-entry ACT_CRAWLING, the actual
quarter entry, separate intended-position storage, caller argument/global
bindings, actual local floor/ceiling bindings, successful wall store and
successful local cleanup. The theorem preserves the six cells from the
pre-quarter memory. It does not produce the intended-position stores or
establish crawl from a lower or different-action state.

### Conditional composition and reverse constraint

New module: [`InkFreshPushCrawl.v`](../../proofs/InkFreshPushCrawl.v).

`ifpc_named_cuts_compose_with_fresh_cache` consumes the primary-query result,
push-query/commit frame and live-query/caller-break result. Its
`InkFreshPushCrawlCuts` record shares exact memories and contains two actual
Clight2 small-step paths between named generated program locations:

1. After primary geometry query to the push's post-wall destination query.
2. After that push segment to the ground caller's quarter-call tail.

Each interval explicitly preserves only action, movement Y, floor pointer
and floor height. X/Z are allowed to change. The theorem concatenates a
single actual small-step path through the primary query, both intervals,
push query/commit and constructed quarter/caller break. If the actual primary
query returns `h`, the final cache is `h`, its pointer is that query's output,
movement Y is 1741 and action is still crawling. Final cache 768 is equivalent
to `h = Float32(768)`.

The initial high crawl is a hypothesis. The continuations are explicit but
not proved to stay within one Mario-action activation. In particular this
is not a global same-update theorem disguised as a conjunction of separate
fixture results. The remaining same-update task is to construct the first
interval through geometry completion, input return, special-floor handling,
interaction dispatch and the actual push's math/wall prefix; then construct
the second through interaction return, crawl guards/speed and intended-position
stores. Both finite frames must hold on those actual paths. No live-item,
no-A, timer or allocator theorem follows merely from this composition.

All three boundaries are registered in `_CoqProject` and consumed by
`InkConcreteProducerBoundary.icpb_stopped_floor_producer_checked`, hence
`MainTheorem.current_ink_stopped_floor_producer_boundary`. The concrete
advance is replacement of separate query-endpoint assumptions by selected
actual calls and shared memory effects, plus a precise reverse constraint
on the fresh primary return. The top-level gameplay verdict remains open.

## Reverse scattershot implementation and finite result

[`ink_handoff_reverse_scattershot.py`](../../instrumentation/wafel-jp-pilot/ink_handoff_reverse_scattershot.py)
starts at successful timer-130 controls and proposes earlier states. It is
a native heuristic, **not Coq inverse semantics**. Each trial restores one
phase of the accepted controller prefix, makes one declared initial setup,
then uses only controller inputs. There are no later pose, action, floor,
timer, RNG or allocator corrections. An earlier proposal becomes a parent
only if its entire continuation still creates the useful split, captures
top slot 61 and reaches Area 2 outside the ordinary elevator footprint.
The exact parent's remaining controls are retained. Different intermediate
observations are permitted; states are not merged on an approximate match.

The supplied roots put M/C/D at (-1950,1741,-939), already crawling, with
zero movement speed/velocity, yaw 208 and a supplied 100-unit Mario hitbox.
Box 49 is placed at (-1989,1741,-939), or Bob-omb 39 at
(-1979,1741,-939). Other actor fields retain their native phase context.
There is no floor-cache write. This is a new **one-initial-cut control**;
the old video used separate action and position cuts. Neither is a clean
producer. The accepted prefix uses the documented debug level-select entry,
so even a no-extra-edit success would be scoped to that entry convention.

Both controls produce M/C=(-1882,768,-939), D=(-1882,1741,-939), top capture
on the next update, and first Area-2 M=(365.5927734375,5500,-1096.8026123046875).
The selected actor appears in the native collision list. Eligibility is checked
there, allowing a positive intangibility timer to expire during the update;
the earlier pre-update-tangibility restriction was corrected and the batch
rerun. The missing-nearby-actor
control fails the useful target: it leaves X=-1950. Collision membership and
this negative control support the pushing interpretation; the sampler is
not an instruction-level proof that this actor performed the displacement.

The final seeded batch has **2,200 proposals**, 200 for each of eleven
families: existing crawl, inverse-rotation/top-supported crawl, starting
crawl, crouch, idle with held item, hands-free-style slide, airborne held
item, lower supplied release, native actor position, native Mario state and
fully native context. Held/released flags, positions, action and platform
reference in these proposals are recorded supplied conditions, not native
acquisitions. The family names do not certify a reachable state.

Actual starting phases are **114, 122, 126, 128, 129**, 440 proposals each.
Although the configured maximum backward depth is 33, no earlier parent was
accepted, so the run never explores all phases back to 98. Step distances
are 1/2/4/8/16, with sampled yaw, speed, X/Z offsets and a finite controller
menu. Earlier inputs vary; the final root input is Z plus upward stick.
Every suffix input releases A; the runtime checks controller held/pressed A
and Mario's A flags after every update. This is not exhaustive input coverage.

**Result: zero new parents, zero clean gameplay successes.** All 2,200 fail
the useful split target; none advances to the target's capture/payoff checks.
Forty-one are still crawling above Y1280 immediately before behavior130;
36 also have the selected actor live and tangible, without asserting it is
nearby. All 41 remember top owner61, with floor heights approximately
1796.609–2005.073, rather than 768. Thus high crawl alone is an inadequate
parent criterion. Four selected such failed suffixes are replayed from a
new native instance and match all recorded snapshots/events (19 updates).
The two successful supplied roots also match fresh replays (50 updates).

The final batch accounts for 21,318 native updates, including reconstruction,
phase preparation, controls and fresh checks. A separate earlier run of the
same 2,200 proposals matches every recipe and recorded history digest; these
are **repeated observations, not 4,400 distinct proposals**. Equality covers
recorded fields and frame events, not complete native memory. The frame
event's `stepType=2` identifies ground movement; it is not the quarter's
return value. No live floor/ceiling-return hook is used in this search.

The [compact receipt](ink-handoff-reverse-scattershot-receipt.json) includes
the pinned runtime/input/script hashes, controls, fresh replays, diagnostic
histories and all 2,200 ledger entries. Each entry retains recipe/history
digests, status, phase, family, parent and edit count. The full local raw
record retains the exact recipes and edit values at
`build/wafel-pilot/ink-handoff-reverse-v2-20261111.json` (its size/hash are
in the receipt). The verifier checks the parent suffixes, target bookkeeping,
counts, histories and repeat-run agreement. This is not a proof certificate
of all untested histories, nor an original-ROM replication of these new runs.

## Reproduction and checks

From `SSL-Coq/less-than-one-a-press`, Windows PowerShell:

```powershell
& ./build/wafel-pilot/python/python.exe -m unittest discover -s instrumentation/wafel-jp-pilot -p test_ink_handoff_reverse_scattershot.py -v
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_handoff_reverse_scattershot.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-handoff-reverse-v2-20261111.json --trials 2200 --seconds 120 --max-depth 33
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_handoff_reverse_scattershot.py build/wafel-pilot/ink-handoff-reverse-v2-20261111.json build/wafel-pilot/ink-handoff-reverse-receipt-v2.json --compare build/wafel-pilot/ink-handoff-reverse-v2-repeat-20261111.json
Copy-Item -LiteralPath build/wafel-pilot/ink-handoff-reverse-receipt-v2.json -Destination docs/notes/ink-handoff-reverse-scattershot-receipt.json
```

Use new output names when rerunning: the tools refuse to overwrite records.
The search seed defaults to 20261111. All three commands exit 0; the 16
bookkeeping tests pass. The repeat run uses the same options and includes
the same diagnostic-replay output. The first startup attempt exposed the
embedded Python's missing script-directory import path; that path was fixed
before any accepted batch. No failed startup is counted as gameplay evidence.

Coq validation uses Ubuntu WSL, `sm64-item-proof`, Coq 8.16.1 and CompCert
3.15. The existing 6,815,744 KiB virtual-memory cap is unchanged. The baseline
selected audit passed at `build/audit/20261111-143319-ob6m1dt1` before the
new modules were integrated. Targeted commands, within that WSL directory:

```bash
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkObjectPushQuery.vo
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkCrawlLiveQueries.vo
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkFreshPushCrawl.vo
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_ink_stopped_floor_producer_boundary LessThanOneAPress.Proofs.InkObjectPushQuery ipq_object_push_query_checked LessThanOneAPress.Proofs.InkCrawlLiveQueries icl_crawl_live_queries_checked LessThanOneAPress.Proofs.InkFreshPushCrawl ifpc_fresh_push_crawl_checked
```

All three targeted builds pass, exit 0. The final integrated selected audit
also passes, exit 0, at `build/audit/20261111-145917-kzr3x0zl`: 711 source
files, zero inventory problems, successful MainTheorem/dependency build,
proof-hole scan and generated-link checks; all four assumption queries
report seven allowed existing foundations. Integration finds 545 of 631
proof modules in MainTheorem's closure, 86 standalone-only modules and
zero problems. This is a selected dependency audit, not a full rebuild or
assumption audit of every standalone theorem.

The seven foundations are `Axioms.proof_irr`,
`ClassicalDedekindReals.sig_forall_dec`,
`ClassicalDedekindReals.sig_not_dec`, `Classical_Prop.classic`,
`Events.external_functions_sem`, `Events.inline_assembly_sem` and
`FunctionalExtensionality.functional_extensionality_dep`. No new axiom or
admission is introduced. These checks do not discharge the explicit execution
paths, finite frames, loaded geometry and reachability obligations above.

The full Windows wrapper for the final audit was:

```powershell
wsl.exe -d Ubuntu -- bash -lc "cd '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press' && bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_ink_stopped_floor_producer_boundary LessThanOneAPress.Proofs.InkObjectPushQuery ipq_object_push_query_checked LessThanOneAPress.Proofs.InkCrawlLiveQueries icl_crawl_live_queries_checked LessThanOneAPress.Proofs.InkFreshPushCrawl ifpc_fresh_push_crawl_checked"
```

## Next backward obligations

Constructing a controller history still requires a live actor delivered to
the relevant location; Mario already high and in established crawl; a
primary query that really returns768 with a usable floor pointer; eligible
object contact after that query; the stopped quarter and later alignment;
and useful warp timing through explosion, freeing, allocation and first
Area-2 apply. The finite search has not joined those requirements.

The next precise proof work is the two named intervening paths and their
cell effects, followed by live surface-list/query-result execution. The next
search target should keep the low-cache and full payoff requirements when
trying predecessors of high crawl; accepting high crawl alone admits the
41 unsuccessful top-supported states found here. Other controller inputs,
earlier routes, actor placements and histories remain open. No universal
allocator count or actor-lifetime bound is inferred from timer130 controls.

All 45 atlas estimates and four single-paragraph summaries remain unchanged:
Rank 1 **1–2%**, Ink Rank 2 **<1%**. These subjective estimates are not proof
probabilities or measured probabilities from the sampler.
