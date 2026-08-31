# Status

The project currently establishes the source-level reduction, exact binary32
landing-speed witnesses, a concrete TTC spinner collision interval, the
random-mode timer/direction model, and a conditional dust-runtime projection.
It does not yet establish either ultimate gameplay claim.

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
arbitrary-`genv` symbol/layout/memory premises: it masks Mario's bit 1 at
raw-data byte 224, proves the result clear, and advances the Mist cursor
`4 -> 12`. Its typed-link instantiation remains open.

The remaining downward chain is not executable under unrefined standard
Clight merely by adding memory premises. Generated `segmented_to_virtual`
casts a symbolic `Vptr` to unsigned and shifts it; CompCert preserves the
pointer value at the cast, while the shift accepts only integers. A full proof
therefore needs an explicit N64-flat-address refinement, followed by a
CompCert realization of allocation and object-list memory.

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
every pitch from 15,856 through 15,951, CompCert binary32 transformation and the
signed-16-bit terrain cast produce strict horizontal containment and a plane gap
in `(0, 160]`.

That interval is not a bounded-oscillation target. The schedule proof shows
that, after the five stopped timer values, the next frame moves by 200 in either
direction and exits the interval independently of all RNG observations. The
next TTC milestones are therefore a wider or multi-interval geometry witness,
a reproducible reachable US/JP entry trace with pool/flag and RNG-window
evidence, and a complete linked-Clight execution/refinement for the dust chain.
