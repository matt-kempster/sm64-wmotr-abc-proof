# Status

The active target is the US/JP TTC cog entry/control claim. It remains open.
The new cog work derives the eight-object inventory from generated source,
certifies a 154-unit pairwise gap between hexagonal cogs 0 and 3, and executes
the complete generated cog update from an explicit zero-speed memory image.
That real Clight execution includes the approach helper and both RNG calls:
seed `16 -> 59500 -> 54874`, unchanged yaw 57344, and zero speed, target, and
yaw velocity. The memory image and symbol/layout premises still need a
reachable, properly linked gameplay instantiation.

An exact four-draw recurrence example changes a pair's zero-target outcome.
The finite search in `pipeline/search-ttc-cog-rng.js` found no infinite
continuation in its simplified consecutive-pair model for any fixed number
of other calls from 0 through 8. This is a discovery result, not a formal
negative gameplay theorem; the real cog pair is separated by other objects.

Normal entry, actual floor/ceiling selection, both preserving controller
choices, all intervening consumers, and repeated stasis remain unproved.
New work excludes ACE, corruption, cheats, debug entry, and arbitrary
game-memory/code edits. The legacy cheat-enabled launcher has been retired.
See the [cog plan](ttc-cog-plan.md) for the remaining work.
The user subsequently authorized a separately labeled experiment that starts
Mario near the cogs. Its initialization-only test build and read-only observer
are in `instrumentation/ttc-cog-placement/`. It cannot establish normal entry.

Three declared placements have now run in both versions. The back-of-cog
setup selects a real 154-unit floor/ceiling gap; it and the edge setup fall
without a Pedro branch. Their complete observed logical traces agree between
US and JP after excluding raw addresses. A US controller approach from the
test ledge reaches the lower cog, and its exported replay reproduces all 2250
input/Mario/cog records. The JP replay independently reproduces the US logical
event sequence, including its RNG and air-step returns. A traced back-of-cog
jump replay also falls without a Pedro branch. Recorded RNG transitions pass
the recurrence checker.
A corrected route now goes around the mesh end with a jump and reaches the
back of the lower cog. Its recorded inputs reproduce all logical events in
US and JP, including the US video capture. Mario subsequently falls, and
none of its 456 air-quarter-step returns takes the Pedro branch. Floor
detection and candidate particle actions are analyzed in
[the floor/action note](ttc-cog-floor-actions.md).
See [the placement results](ttc-cog-placement-results.md) for trace hashes,
scope and unsuccessful continuations.

The pinned freefall landing action checks `common_landing_cancels` before
the dust code. The observed edge state has `INPUT_OFF_FLOOR` and a floor at
Y=-8191, so this cancellation path is a concrete obstacle to investigate at a
successful Pedro entry. The existing velocity witnesses do not discharge it.

The later `inner_rim` placement now produces actual close-gap air returns in
both US and JP. Its complete 65-frame comparison agrees, including a return
with retained floor -8191, queried floor -2088 and ceiling -1934. The observed
action sequence matches off-floor landing cancellation. The cogs still rotate
and carry Mario between calls, so this is a transient mechanism witness.
Paired dive and ground-pound continuations also agree across US/JP: the dive
bonks without landing dust, and ground-pound mist occurs only after falling
to a lower platform. Preserving in-spot RNG control remains open.

The complete Pedro proof build, no-hole check, all named capstone assumption
checks, and separate root proof-discipline audit pass. The new cog execution
depends only on standard Coq/CompCert axioms beyond its explicit premises.
After interruptions in the mounted workspace, the unchanged two-pass
regeneration pipeline passes in a temporary Linux copy: both passes agree and
all 56 outputs match the workspace byte for byte. Individual pipeline calls
completed the interrupted assumption audit. One launch reported a WSL service
error; the precise cause of the earlier exits remains unknown. Verification
and the open gameplay claim are tracked separately in [the checklist](checklist.md).

The earlier work establishes the source-level Pedro reduction, exact binary32
landing-speed witnesses, a TTC spinner collision interval, the spinner's
random-mode timer/direction model, and a conditional dust-runtime projection.

For both supported versions, the new projection decodes the stock Mist and
white-puff behavior words, checks the normal object-list order and dynamic-next
walk, and computes the same-frame sequence Mist, WhitePuff1, WhitePuff2. Under
an initially clear active-dust bit and an isolated reserve of at least three,
the pool model accepts all three D/D/U allocations and the active-bit model is
set then cleared. The derived dust-only event list has four `random_u16` calls
on that frame: Puff1 X/Z in DEFAULT, then Puff2 X/Z in UNIMPORTANT.

This is not yet a retail-frame execution, but the typed CompCert frontier now
goes beyond a symbol-only slice. In both versions it executes one actual
WhitePuff2 `cur_obj_update` dispatch cycle through `BehaviorCmdTable[12]`, the
generated `CALL_NATIVE` handler, the native loop, random X/Z translation, and
two nested `random_float`/`random_u16` calls. From seed zero the exact stores
are `0 -> 57460 -> 55882`, and the behavior cursor advances `20 -> 28`.
Separately, the generated parent-bit-clear handler is executed under explicit
arbitrary-`genv` symbol/layout/memory premises: it clears Mario's mask-1 bit
(bit zero) at raw-data byte 224, proves the result clear, and advances the Mist cursor
`4 -> 12`. The exact US/JP `spawn_particle` callers are also executed on their
accepted branch: they read a clear bit, set raw-data word 22's mask-1 bit
(bit zero), call `spawn_object_at_origin` with model 142 and their supplied
behavior argument, and copy Mario's position and angle to the returned
particle. A paired exact table receipt identifies the dust argument as the
Mist behavior. The two callee executions and their active-word preservation
remain premises, so typed-link instantiation
of this downward edge remains open.

The remaining downward chain is not executable under unrefined standard
Clight merely by adding memory premises. `SegmentedPointerBoundary.v` now
proves against both exact generated bodies that `segmented_to_virtual` casts a
symbolic `Vptr` to unsigned without changing the semantic value, after which
the first right shift has no integer operand case. A full proof therefore needs
an explicit N64-flat-address refinement, followed by a CompCert realization of
allocation and object-list memory.

The TTC loader audit now counts a generated source inventory of 110 macro
descriptors, 9 area object descriptors, and Mario. The resulting 120-slot
headroom is nominal: act/respawn filtering can omit descriptors, but a loader
execution and later live-object census are still needed before treating it as
the pool at a tap. The normal-frame reduction keeps a freshly clear dust bit
clear across any finite request sequence, while retail refinement and
time-stop exclusion remain open.

Intervening consumers no longer need to be modeled as absent: for certified
finite counts before, between, and after the two puff pairs, the exact global
equation is `R^(4+k)(seed)`. Generated macro and Clight receipts enumerate the
prefixes before spinner 0 and spinner 7 and give conservative conditional
bounds of 80 and 94 non-dust calls. A reachable live-state snapshot and a proof
that no outside consumer was omitted are still required to instantiate those
bounds. The spinner's first opportunity to observe the post-tap seed remains
the next frame because SURFACE precedes PLAYER, DEFAULT, and UNIMPORTANT.

A fail-closed static closure now terminates only at declared-external `sqrtf`.
The authenticated US and JP retail leaves are checked byte-for-byte as the
four instructions `jr ra; sqrt.s f0,f12; nop; nop`, with no conservatively
recognized nested call or store. That finite opcode receipt does not supply a
MIPS semantic contract for the CompCert external. The complete 240-slot and
ten-call runtime receipt remains a debug-origin SLOW-mode boundary, not a
controller-only stock/Pedro/RANDOM witness.

The most important factual correction to the motivating chatbot summary is
the timing: `AIR_STEP_LANDED` does not directly create dust. It selects a
landing action. On the landing action's frame, `common_landing_action` first
changes forward velocity, performs a ground step, and only then sets the dust
particle bit if the resulting forward velocity is strictly greater than 16.

The TTC geometry certificate uses spinner 7 triangle 12 as the floor, spinner 0
triangle 4 as the ceiling, and the common horizontal point `(1045, 1603)`. For
every pitch from 15,664 through 16,031, CompCert binary32 transformation and the
signed-16-bit terrain cast produce strict horizontal containment and a plane gap
in `(0, 160]`.

That interval admits one controlled movement: pitch 15,864 with direction `-1`
reaches pitch 15,664 and remains certified. It is still not a bounded-oscillation
target. After the five stopped timer values, the second movement frame reaches
`pitch +/- 400` and necessarily exits the interval. Those spinner milestones
are prior work. The active cog milestones are a reproducible reachable US/JP
entry trace with pool/flag and RNG-window evidence and a complete linked-Clight
execution/refinement for the dust and cog chain.
