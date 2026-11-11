# Creating a gap below the spinning cap

This follows the original supplied-gap demonstration backward. Its target is
movement/collision `(-2200,768,-1024)` with a raised display position that lets
the retry select the spinning top. The demonstration supplies that disagreement;
it does not explain how to create it through controller input.

**A smaller gap can be created by the game while the supplied crawling body
stays below the cap. It does not install the top.** The clearest new diagnostic
starts with all three Mario positions equal at `(-2132,1400,-1024)`. A supplied
nearby Crazy Box pushes Mario west; the stopped crawl then leaves movement and
collision at `(-2200,768,-1024)` and display at `(-2200,1400,-1024)`. The game
creates this 632-unit disagreement. On the next update the low query misses,
but the raised retry selects the static roof at1280, not the top. The accepted
warp therefore has no remembered top. No clean no-A producer of the supplied
high crawl or item placement has been found.

## What was supplied, and what was produced

The [producer script](../../instrumentation/wafel-jp-pilot/ink_low_fixture_producers.py)
uses the pinned native JP Wafel runtime and the authenticated no-A four-pillar
controller replay. It reaches stored top timer130 without changing top state,
RNG, allocation history or pillar counters. Each diagnostic restores that
reached context, makes one declared initial setup, and then advances only
controller input through the producer, next retry and warp continuation.

For the westward box case, the initial setup supplies:

- Equal movement, collision and display `(-2132,1400,-1024)`.
- `ACT_CRAWLING`, action state/timer zero, zero speed/velocity, face yaw208,
  and the already-established 100-unit crawl hitbox.
- Native box49 at `(-2093,1400,-1024)`, with its velocity fields zeroed.

It does **not** write floor height or pointer, ceiling, platform, collision
lists, held-object state, top timer, RNG or a display gap. The inherited floor
height is1024. The first controller input is Z with stick `(0,64)`; all later
inputs are neutral. A-input counters remain zero. Supplying a crawling action
and a hovering high position is not evidence that normal gameplay reaches them.

| Checkpoint | Movement/collision | Stored display | Remembered floor |
| --- | --- | --- | --- |
| Supplied starting state | `(-2132,1400,-1024)` | same | inherited1024 |
| First action entry, after object interaction | movement `(-2200,1400,-1024)` | earlier value; no claim of an action-entry display hook | fresh cache established by the earlier geometry pass |
| After the producer update | `(-2200,768,-1024)` | `(-2200,1400,-1024)` |768 |
| After the next update | `(-2200,1280,-1024)` | same |1280, ownerless |

The first update logs exactly one crawling quarter. The runtime's stock event
log does not hook individual floor/ceiling returns. The explanation of the
local roof1280/ceiling1523 stop uses the source and the separately checked Coq
tail; these are not mislabeled as direct query observations.

The native Bob-omb39 also works as a supplied pushing actor: place it at
`(-2103,1400,-1024)` with zero velocity. Its different radius gives the same
westward endpoint. This does not produce or release that Bob-omb through
hands-free teleport; its placement is a diagnostic assumption.

## Why a below-cap crawler can stop

The loaded cap underside before this update is1518; terrain preparation loads
1523 for the update. At Y1400 the supplied 100-unit crawling collision body
ends at1500, below both. Its horizontal radius does not change that vertical
separation. This describes the collision body, not every vertex of Mario's
rendered model or an earlier controller history.

The ordinary ground quarter nevertheless tests **intended Y+160**, even for
this 100-unit crawling hitbox. Here `1400 > 1280+100` and `1400+160 >= 1523`.
It returns the stopped result without committing the local roof answer to
Mario's cached floor. The ground caller refreshes display at1400, then crawl
alignment uses the retained768. The later collision copy follows movement.
The cap still provides the ceiling obstruction; this is not a mechanism that
dispenses with the cap's collision geometry altogether.

At the original X/Z, the recorded next-phase top floor is
1938.8648681640625. The integer floor query needs at least Y1861 to accept it
under the 78-unit allowance. Display1400 instead admits the roof1280. Thus
reaching the low coordinates with *some* disagreement is insufficient: this
producer lacks461 units even relative to the lower accepted display threshold.
That is a calculation for this recorded point/phase, not a general Ink bound.

| Supplied crawl Y, phase130 west box | First-update gap | Next selected floor | Boundary detail |
| --- | ---: | --- | --- |
|1280,1363,1380|0|roof1280|No retained high display after the quarter commits.|
|1381|613|roof1280|100-unit body strictly below both undersides.|
|1400|632|roof1280|100-unit body strictly below both undersides.|
|1418|650|roof1280|Body touches the previous1518 underside; excluded by the strict screen.|
|1423|655|roof1280|Body overlaps the previous underside by5; only touches the new1523 plane.|
|1741|973|roof1280|Inside-cap diagnostic; still too low at the original west X/Z.|

The existing east endpoint `(-1882,768,-939)` also admits the lower613/632
gaps, with the same failed top capture. Its successful1741 display belongs to
a different X/Z and the known inside-cap supplied setup. The west and east
top heights must not be interchanged.

## Other tested predecessors

The complete [producer receipt](ink-low-fixture-producers-receipt.json) contains
75 supplied-state cases and2051 continuation updates: two targets, two actors
and14 heights; six entry-action controls; three negative-depth controls; and
ten earlier-phase cases. Nineteen cases create positive gaps while passing the
strict below-cap collision-body screen. None of those nineteen captures the
top. These include duplicate geometric outcomes under different actors or
depth assumptions; they are not nineteen distinct mechanisms.

Starting idle, crouching or starting to crawl at1400 did not reproduce the
gap. The established crawl matters. Supplying negative depth `-0.5`,
`-538.8648681640625` or `-1000` also did not amplify the632 gap: all three
values became zero. The moving-action quicksand update clamps/checks the depth
and resets it on this ordinary floor before the final sinking helper. Simply
combining the negative-depth idea with this crawling update does not work.
No negative seed is claimed reachable.

Earlier cases set crawl Y to101 below the measured previous underside, so
the 100-unit body has one unit of clearance. Both targets were tested at
stored phases96,112,122,126,128. The first two produce gaps479 and559, then
select roof1280. Their roof/ceiling clearance is small enough for the other
ceiling-stop branch. Phase122 commits to the roof and makes no gap; phases126
and128 produce gaps629 and639 but again select the roof. These observations
do not establish useful earlier warp timing or an allocation-lifetime payoff.

Two forward tests address earlier state production:

- **396 controller-only suffixes**, from nine reached post-pillar phases,
  test44 policies for160 updates each:63360 updates, no supplied gameplay
  fields, no positive display gap and no top capture. These starts remain
  far away: the closest sampled distance to the original low target is about
  2554.87 units. This has weak coverage of the actual handoff neighborhood.
- **352 position-only roof continuations**, from eight nearby Y1280 seeds,
  test the same44 policies for at most60 updates:20891 updates. They inherit
  the reached idle action, cache, depth and native actor positions. Eighty
  trials reach crawling, with maximum crawl Y1280. None creates a positive
  display gap. Eighteen leave Area1;334 reach the horizon. Their initial
  positions are supplied, so none is a clean arrival from level entry.

The44 policies are nine fixed stick choices and two camera-relative target
steers, each combined with neutral buttons, held Z, B every eighth update,
or held Z plus those B pulses. All exclude A. The roof seeds are listed in
the [roof script](../../instrumentation/wafel-jp-pilot/ink_low_fixture_roof.py)
and its [receipt](ink-low-fixture-roof-receipt.json). Neither search enumerates
all input histories, speeds, actions, moving supports or actor deliveries.

The conservative cap screen compares Mario's radius37 and observed hitbox
height with the loaded cap's axis-aligned bounds at update boundaries and
logged action entries. Any overlap or equality rejects the candidate. It is
deliberately stricter than a mesh intersection test. It is **not** continuous
tracing of every internal position write. No controller or roof continuation
was rejected by this screen in the recorded batch.

## Checks and remaining obligations

Fourteen distinct main cases were replayed after a fresh boot and replay of
the controller prefix, matching780 complete suffix updates. Three roof cases
match180 more updates. The comparisons include the recorded snapshots, input
recipes and normalized native events, not whole native memory. The
[receipt checker](../../instrumentation/wafel-jp-pilot/ink_low_fixture_verify.py)
passes both compact receipts and rejects eight mutations, including supplied
floor writes, false gaps/cap clearance, false capture, duplicated replay
counts, an A input and an altered roof gap.

The corresponding Coq work is in [InkLowFixtureCrawl.v](../../proofs/InkLowFixtureCrawl.v)
and [InkLowFixturePush.v](../../proofs/InkLowFixturePush.v). The former constructs
the actual US/JP stopped tail at sampled heights1381,1400,1418,1423 under
explicit local-query/storage hypotheses, and checks the separate recorded
next-query surface snapshot. The latter connects the actual push query to
the null-result no-position-commit branch. Neither constructs the supplied
high crawl, actor delivery, negative seed, whole update or complete no-A route.
The exact proof boundaries and integrated checks follow below.

The useful open predecessor is now quite specific: reach an established
crawl at an adequate height with an available actor **and** a fresh low
primary floor, then create enough retained display height before eligible
warp contact. The lower supplied setup demonstrates that entering the cap's
interior is unnecessary for a smaller gap. It does not show that normal
gameplay can reach that setup, or that this smaller gap can be extended into
the original successful installation. A different source of extra display
height, a different transfer, or a different complete timing remains open.

Reproduce from the SSL project in Windows PowerShell, using fresh output names:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_low_fixture_producers.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-low-fixture-producers-REPLAY.json --receipt build/wafel-pilot/ink-low-fixture-producers-REPLAY-receipt.json
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_low_fixture_roof.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-low-fixture-roof-REPLAY.json --receipt build/wafel-pilot/ink-low-fixture-roof-REPLAY-receipt.json
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_low_fixture_verify.py docs/notes/ink-low-fixture-producers-receipt.json docs/notes/ink-low-fixture-roof-receipt.json
```

Final local raw files are `build/wafel-pilot/ink-low-fixture-producers-v2-20261111.json`
and `build/wafel-pilot/ink-low-fixture-roof-20261111.json`; compact receipts pin
their hashes. The initial matrix run was repeated after removing duplicated
fresh-replay bookkeeping; its75 matrix outcomes and396 policy outcomes did
not change. No new video was created in this tranche.

## Checked Coq claims and their limits

`ilfp_real_null_query_preserves_all_mario_cells` connects the actual generated
US/JP object-push destination query to its null-result branch. It derives a
frame for every MarioState memory load, rather than assuming that the query
does not change Mario. `ilfp_completed_push_exposes_floorless_obstruction`
exposes this query inside one completed actual helper call and extends that
frame through freeing the helper's local variables. The query reads movement
Y; an old high display or remembered floor does not replace its result.

The hypotheses include an actual selected-program execution, the real Mario
global block, a correctly bound separate local floor-output cell, and readable
movement Y. The earlier distance/math/wall prefix is exposed by the theorem,
not proved to preserve Mario. The live query must actually return null; the
proof does not assume every low coordinate has that result. This strengthens
one specific failed-push explanation, not an exclusion of all earlier writers.

`ilfc_lower_crawl_ceiling_stop_executes` constructs the actual post-water
quarter tail for intended Y in `{1381,1400,1418,1423}`, local floor 1280 and
ceiling 1523. `ilfc_lower_crawl_stop_preserves_memory` proves that such a tail
returns stop-result 2 with unchanged memory. A cache of 768 is preserved if
it already exists at this cut; its origin is not proved here. Correct local
bindings and the readable intended-Y cell are material hypotheses. The
preceding query prefix, action, subsequent display refresh/alignment and item
history are not supplied by this local theorem.

`ilfc_lower_display_retries_only_static_roof` separately evaluates the existing
recorded, ordered timer-131 surface snapshot at original X/Z `(-2200,-1024)`.
Both low lists miss at 768; each of the four sampled raised queries misses
the dynamic top and selects static roof 1280 with null owner. It reuses scalar
expressions extracted from generated US/JP code. It is a finite snapshot
certificate, not a proof that all live histories install those lists.

Both new modules are registered in `_CoqProject`, and their checked boundaries
are explicit conjuncts consumed by `InkConcreteProducerBoundary` and
`MainTheorem.current_ink_concrete_producer_boundary`. No axiom or `Admitted`
was added. The progress is a stronger actual query-to-return connection and
a constructed alternative local stop, not discharge of clean reachability.

## Proof commands and audit outcome

Ubuntu WSL still uses `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15. The
pipeline's 6,815,744-KiB virtual-memory cap was unchanged. From the WSL SSL
project directory, both targeted commands passed with exit 0:

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkLowFixturePush.vo
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/InkLowFixtureCrawl.vo
```

The final selected audit command was:

```sh
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_concrete_producer_boundary \
  LessThanOneAPress.Proofs.InkLowFixturePush ilfp_low_fixture_push_checked \
  LessThanOneAPress.Proofs.InkLowFixtureCrawl ilfc_low_fixture_crawl_checked
```

**PASS, exit 0**, at `build/audit/20261111-162510-oqgzg_nu`: 713 registered
sources, zero inventory problems; dependency build, proof-hole and link checks
pass; all three assumption queries use seven existing allowed foundations;
547 of 633 modules are in MainTheorem's import closure, 86 are retained
standalone modules, and integration has zero problems. This is a selected
dependency audit, not a rebuild or assumption audit of every standalone module.
The initial backward-boundary audit also passed at
`build/audit/20261111-161622-coa2u1db` before the edits.

The seven foundations are `Axioms.proof_irr`,
`ClassicalDedekindReals.sig_forall_dec`, `ClassicalDedekindReals.sig_not_dec`,
`Classical_Prop.classic`, `Events.external_functions_sem`,
`Events.inline_assembly_sem`, and
`FunctionalExtensionality.functional_extensionality_dep`. They do not remove
the explicit hypotheses above or establish native-runtime/Clight equivalence.
The clean gameplay verdict remains open. All 45 subjective estimates are
unchanged, including Rank 1 **1–2%** and Ink Rank 2 **<1%**.
