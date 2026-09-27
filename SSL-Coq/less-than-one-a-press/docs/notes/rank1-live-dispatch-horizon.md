# Rank 1: live callback repair and the one-second attempt

27 September 2026. **The requested one-second backward search is still
incomplete.** We implemented and checked a more precise callback resolver and
an actual repeated-update observer, then attempted 30 checkpoints in US and
JP. Neither attempt completed the predecessor classification. No Ink route is
excluded, no new Coq result is claimed, and Rank 1 stays at its subjective
1–2%.

## What was wrong with the callback handling?

A native behavior call is an ordinary game function, such as Mario's update
or the pyramid elevator's update. The pinned C reads its address from the
current behavior command, calls it, then advances the command pointer. An
emulator or Wafel already knows that address in a concrete state and can run
the call normally.

The old broad resolver looked at every function with the right type and
stopped if any declaration lacked a body. In the selected linkage that meant
1,463 internal US targets or 1,457 JP targets, plus 29 missing declarations.
The emitted stock behavior data contains only 546 distinct US native-command
operands or 545 JP operands. All have internal bodies; none of the 29 missing
declarations appears among them. This is a source census, not proof that all
live script words retain their initialized values.

The new resolver reverses the actual assignments and reads preceding the
call. It asks which function addresses remain possible under the explicit
entry conditions. A missing body blocks only if its address has not been
excluded. Earlier stores affect the answer. A timeout keeps the alternatives
open. No initializer is silently assumed to persist, and no unknown callback
is treated as doing nothing.

This is a **partial repair**, not the completed live-script connection.
It currently handles a straight prefix without earlier calls. Other control
flow retains the conservative type domain. A root entry condition is kept in
the returned predecessor and is not borrowed by a shared callee after
intervening effects. Carrying justified script facts through the caller,
command loop and intervening memory effects remains unfinished.

## What was checked?

The US/JP regression starts the real native-command wrapper with its actual
stock elevator-loop operand specified in memory. The resolver selects that
function and excludes the unrelated missing declarations; it includes the
actual callback body in the predecessor formula. This is a conditional
application check, not a reachable elevator scene or an Ink producer. An
unrestricted recursive query for the chosen callback's full effects returned
unknown during development; it is not a successful execution witness. The
existing concrete trace checks remain separate.

Negative controls leave the operand unknown, select a missing external
declaration, overwrite the word before the call, and force a solver-unknown
answer. None is silently converted into a supported call or an exclusion.
The artificial overwrite is test data only; it is not proposed gameplay.

All **42 application tests pass**, including the previous real US/JP
controller-to-retention fixture and floor-list tests. No generated source or
Coq theorem changed. The existing Coq audit does not verify this interpreter.

## The horizon option now has an actual meaning

The previous benchmark command only attempted a prerequisite portion of one
update. Giving it a requested depth of 30 did not compose 30 updates. It is
retained and clearly labeled as a prerequisite diagnostic.

The new horizon runner selects the actual generated main game loop after
startup. An observer counts completed calls to the real final platform
update. Earlier calls return normally and retain the intervening caller
tails, display/vsync, audio, controller handling and level scheduling. Only
the last checkpoint stops the execution prefix. The checked-top target
applies to that last query, not every earlier query. The actual pressed-A
edge is constrained at each reached controller boundary; already-held A is
not silently removed from the domain.

The counter and stop flag are analysis bookkeeping, never writes to Mario
or game memory. Independent synthetic scheduler tests check one, two, three
and thirty checkpoints, including a write after each earlier checkpoint
that must not happen after the last one. Passing these tests does **not**
mean thirty SM64 updates were classified.

Thirty object-update checkpoints correspond to one nominal second of normal
30-update gameplay. Pauses or thread iterations without an object update
are not counted as additional gameplay updates. No controller-reachable
starting state, useful gap, action, live floor list or script pointer is
supplied to the real-game attempt.

## What happened when we ran it?

The full US and JP horizon attempts stop at the original
osContStartReadData call in the main loop, before completing its formula.
That declaration starts controller-device input. The earlier single-path
fixture began after hardware input was supplied, so it never established
this boundary between updates.

There is C source for that library routine in the pinned tree. Merely
including it would not finish the connection: it calls the input transfer
and message-queue routines. Their device/input effects need an explicit
model or a validated execution bridge. We did not implement those calls as
identity memory updates or arbitrary successful returns.

We also ran the smaller object-update prerequisite with the new resolver.
It still reaches the native call with unrestricted script memory. The
actual pointer-load formula therefore does not exclude the 29 missing-body
alternatives. This is a limitation of the predecessor domain and propagation
implemented so far, not evidence that ordinary SSL gameplay can call them.

Both attempts report **zero fully classified updates**. The larger-horizon
price remains unavailable. Their runtimes measure incomplete formula
construction and diagnostic queries, not updates per second or surviving
gameplay sequences. Reverse Scattershot was not substituted for this task.

## The precise remaining work

The callback connection needs the current script pointer and the script word
read at the call to be derived from the chosen predecessor domain and carried
through the real caller effects. The source census can guide that work, but
cannot stand in for it. The repeated-update connection needs the controller
input and intervening runtime effects at the boundary the previous fixture
excluded. These are separate tasks; repairing pointer lookup alone does not
complete the full frame model.

Wafel can execute and validate a concrete candidate across both boundaries.
It does not enumerate all possible earlier states from an endpoint. A
Wafel-validated candidate would still need a legal starting connection; a
failed sample would still leave other predecessors open.

## Reproduce

The existing isolated Python/Z3 environment and generated supplemental units
are used. No installation or altered game state is required.

    python -m unittest discover -s instrumentation/rank1-backward-search -p 'test_*.py' -v
    python instrumentation/rank1-backward-search/search_updates.py --updates 30 --timeout 180 --output build/rank1-backward-search/one-second-live-dispatch
    python instrumentation/rank1-backward-search/benchmark_updates.py --updates 30 --program-dispatch --live-dispatch --supplemental build/rank1-backward-search/supplemental-generated --timeout 120 --output build/rank1-backward-search/native-context-gate

The last command is only the prerequisite diagnostic. Both drivers exit with
status 2 for the recorded incomplete attempts. See the
[saved receipt](../../instrumentation/rank1-backward-search/live-dispatch-horizon-report.json),
[callback resolver](../../instrumentation/rank1-backward-search/live_dispatch.py),
[horizon observer](../../instrumentation/rank1-backward-search/horizon_engine.py)
and [horizon runner](../../instrumentation/rank1-backward-search/search_updates.py).
