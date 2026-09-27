# Rank 1: a runtime inside the backward search

Reviewed 27 September 2026. **Feasible design; the hybrid bridge is not yet
implemented.** A new concrete timing check passes. No predecessor search,
Coq theorem, Ink witness or impossibility result is added by this review.

## What is being proposed

Keep working backward from useful top retention. At a difficult call, let
Wafel or an emulator evaluate a concrete case, then feed that information back
to the backward solver. This is possible. It is different from replacing the
requested search with forward random trials. The solver can enumerate candidate
predecessors, but a model is only a proposal until its pending call effects and
execution have been checked. One observed effect is not a rule for every state.

## The full loop and the actual blocker

The pinned source is revision 9921382a68bb0c865e5e45eb594d9c64db59b1af. The
actual generated US/JP modules retain the following relevant order:

1. The game thread starts controller acquisition, ticks audio, selects its
   graphics pool, reads controllers and executes the level script. Pressed edges
   are derived from new and previous held buttons, not independently supplied.
2. SSL's live CALL_LOOP invokes lvl_init_or_update and the current play mode.
   Normal play performs area/instant-warp work before updating objects, then
   HUD, camera and delayed-warp work afterward.
3. The object update clears dynamic surfaces, runs spawner/surface objects,
   applies the previous platform displacement, detects object contact, runs
   remaining lists, unloads deactivated objects and checks the new platform.
   Native behaviors run within these lists. Mario's behavior executes his
   action and then copies State into the Object.
4. Rendering and presentation finish the outer iteration. Pause, transition
   and time-stop paths mean an outer iteration is not universally one Mario
   update. The search must keep its actual retention checkpoint and earlier
   iteration tails; a convenient frame boundary cannot erase ordering.

In the pinned library, osContStartReadData manages request buffers, DMA and
queues. osContGetReadData later copies the response into controller pads.
Delegating just the first return value does not supply the later input or
memory effects. Wafel supplies host inputs at its update boundary; it is not
an exact implementation of that individual retail OS call. An emulator can
observe the retail boundary. We do not need to rebuild an N64 OS to test
gameplay. Formal claims still need a narrow explicit runtime contract or a
verified implementation connection. The existing [execution scope](../compcert-execution-scope.md)
already leaves asynchronous hardware effects outside Clight unless modeled.

The [relational engine](../../instrumentation/rank1-backward-search/relational_engine.py)
currently builds call relations before solving. The
[horizon engine](../../instrumentation/rank1-backward-search/horizon_engine.py)
shares them across iterations. A missing body stops construction before a
predecessor is proposed. There is no deferred-call queue, runtime-state adapter
or candidate/refinement loop yet. Adding an ordinary Python callback does not
by itself provide those pieces.

## How the hybrid would preserve backward reasoning

1. **Reverse from the same Ink target.** Keep actual generated assignments,
   branch guards and checkpoint order. Do not supply the gap or require the
   three positions to agree to make the query easier.
2. **Leave a named pending call relation.** It relates entry memory/arguments
   to returned memory/result, followed by the existing backward continuation.
   A temporary permissive relation can generate proposals, but cannot validate
   them. In particular, do not assume that an unknown call preserves memory.
3. **Propose a concrete predecessor and test its pending calls.** If the state
   maps to a runtime snapshot, replay/restore it and execute the correctly
   delimited call or interval. Return its effects to the solver. A candidate
   that cannot be represented or joined to a runtime state stays unresolved;
   inability to instantiate it is not a gameplay disproof.
4. **Refine under a guard and ask for another candidate.** Cache an observed
   edge only for the matching state, inputs, version and call boundary. A
   mismatch rejects that proposed edge in that scope. To cover a larger class,
   use a checked symbolic path or proved summary; agreeing samples do not
   establish a whole class. The script continues backward after the handoff.
5. **Retain the unexplored complement.** Unknown calls, unmatched snapshots,
   other live operands and timeouts stay pending. Validate a joined controller
   replay for a witness. An exclusion needs complete coverage of the declared
   domain and justified relations, not an empty cache or failed trials.

For deterministic caching, include everything the pinned backend needs,
including controller history and relevant device/event state. Mario's XYZ is
not an adequate key: objects, scripts, floors, camera, RNG, timers and ownership
can change the answer. A smaller key needs a checked dependency footprint.
The solver's shared/existential formulas also need to expose the particular
intermediate call occurrence; they do not automatically yield an executable
snapshot. A finite forward archive can provide actual edges to reverse, but
covers only that archive and is not substituted for the requested inverse search.

| Boundary | Runtime's useful contribution | Backward obligation retained |
| --- | --- | --- |
| Controller acquisition | Wafel supplies a host sample; the emulator executes and observes retail input calls. | Connect the complete sample boundary, pad writes, held/pressed history and other effects. Keep any input contract explicit. |
| Native behavior | Observe the actual script operand and receiver at the call. | Guard the observed choice, then prefer expanding the already available generated callee body. Keep other operands pending. |
| Stateful helper | Return an observed result and memory effects for a matched state, or guide a symbolic path through its real body. | Retain dependencies, writes, aliases and continuation. A floor result from one list does not describe another list. |
| Ink checks | The existing JP emulator observer samples contact, geometry, warp acceptance, copy, retention and first Area-2 apply. | Use those exact boundaries. End-of-frame equality cannot reject a split that existed earlier. |

There is a concrete representation problem to solve: ProgramImage assigns
canonical 32-bit explorer addresses; retail addresses differ and Wafel uses
native DLL layouts. Raw byte/pointer copying is not a valid bridge. Map symbols,
object slots, surface identities, typed fields and local storage explicitly.
The receiver and script offset matter as much as the function name.

For the **first call-level hybrid, prefer the emulator**. Our existing JP
observer already has authenticated instruction checkpoints, register reads and
live-memory reads. Released Wafel's Python API advances the game and provides
a limited frame log, not a general pause-at-any-C-call interface. Wafel is
useful for fast complete replay and candidate validation; finer call delegation
would require additional instrumentation. Neither backend automatically proves
US behavior, Clight/retail equivalence or all-history coverage.

The bounded implementation milestone is one generated-code predecessor query
that suspends at a named boundary, resumes using a guarded observed edge or
checked symbolic path, and reports validated candidates separately from the
uncovered frontier. Only complete classification of its declared one-update
domain meets the exhaustive milestone. No feasibility or cost claim for the
30-update inverse search follows from the oracle's speed. Reverse Scattershot
remains a separate decision.

## Concrete runtime check performed

The new [benchmark](../../instrumentation/wafel-jp-pilot/benchmark_loop.py)
uses the pinned Wafel 0.8.5 JP DLL and existing retail-capture inputs. It replays
2,539 controller samples from accepted startup, comparing 2,191 available
Area-1 snapshots before saving at poll 2540. It restores that reached state and
replays nested 30-, 90- and 150-advance windows five times in each timing mode.
No pose, gap, action, RNG or support is injected; A stays released. The only
non-controller setup is the accepted pre-entry level-select flag.

| Nominal gameplay time | Advances | Median restore + advance | Median restore + checked trace |
| --- | ---: | ---: | ---: |
| 1 second | 30 | 1.22 ms | 3.45 ms |
| 3 seconds | 90 | 2.90 ms | 10.43 ms |
| 5 seconds | 150 | 4.80 ms | 15.67 ms |

The checked mode reads position/action/support/top fields, compares every
snapshot with the retail capture at the established +1 timer offset, and
reads the frame log. All comparisons and repeated observation traces match.
Each checked advance has a Mario-action event and a global-timer increment.
The 2,700 timed advances cover only **150 distinct suffix snapshots**. They
are repeated measurements, not new search cases. Times exclude DLL loading,
initial prefix construction, storage/solver work and endpoint checks; restore
time is included. These are small local scene measurements, not a general
throughput guarantee. See [ranges and hashes](../../instrumentation/wafel-jp-pilot/loop-benchmark-report.json).

The concrete backend executes these windows. This does not implement the
hybrid, enumerate predecessors, observe every within-update Ink checkpoint or
price exhaustive coverage. Nothing moves to Already proved; Rank 1 remains
open at its unchanged subjective 1–2%.

## Evidence and source-version limits

Inspection covered pinned game_init.c, osContStartReadData.c, level_script.c,
level_update.c, object_list_processor.c and behavior_script.c, with actual
generated US/JP game bodies. The [previous attempt](rank1-live-dispatch-horizon.md)
records the symbolic failures; the [controller-search report](rank1-reachable-search.md)
records the exact observer and replay comparisons.

The upstream [Wafel README](https://github.com/branpk/wafel) distinguishes its
library from an emulator. Its [Game implementation](https://github.com/branpk/wafel/blob/5b808b60af15d316a5e2b0f87db34421d6225b57/wafel_api/src/game.rs)
loads sm64_init/sm64_update and supports advancing and restoring states. The
reviewed DLL-memory implementation invokes that update function and copies
data segments for snapshots. This explains the API design; it does not prove
that the reviewed main source equals the tested 0.8.5 binary. The pinned DLL
hash and finite retail comparisons remain the binary's concrete evidence.
