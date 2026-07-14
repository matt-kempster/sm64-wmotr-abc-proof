# Eyerok manipulation proof

This project studies the proposed Shifting Sand Land route in which an Eyerok
hand is manipulated into rising without bound above the instant-warp floor
triangles between the Pyramid interior and the boss arena. It follows the
Rocq/Coq + CompCert Clight structure used by the sibling SSL-Cog projects.

The intended target is deliberately adversarial: player position, attacks,
timing, and the boss's random choices may select any original-game action
transition. The current handwritten Rocq relations are intended to cover those
choices, but that coverage has not yet been proved.

See [Eyerok.md](Eyerok.md) for the source state machine,
`docs/claim.md` for the exact formal boundary, and `docs/checklist.md` for the
live proof status.

## Project route

```text
pinned US SM64 Eyerok, object-motion, SSL script, and collision source
  -> reproducible source audit + CompCert clightgen
  -> generated Clight AST shape certificates
  -> handwritten nondeterministic vertical transition system
  -> uniform height invariant
  -> no-unbounded-rise theorem for that relation
  -> original-game refinement (open)
```

Generated Clight files are never hand-edited.

## Current status

The pinned source-ingestion pipeline now generates Clight for the authentic
Eyerok translation unit, object motion, behavior dispatch, object-list order,
spawn/list insertion, floor queries, and the SSL script. A deterministic audit
checks the source pin, vertical writer census, paired instant warps, collision
bounds, and selected geometry used in the argument about a gravity-zero ground
launch. Those checks do not themselves prove the launch unreachable.

The audit exposes one critical tripwire: the local C state
`DOUBLE_POUND + grounded + gravity=0` would launch at velocity 100 without
ever installing negative gravity. The abstract machine-checked scheduler
excludes that state in its own relation. No theorem yet proves that every
original-game schedule is represented by that relation.

`inputs/eyerok_model.c` makes a vertical abstraction executable. It
tracks surface-list rank, controlled positioning, static or earlier-hand
support, finite ascent budget, partial-update stuttering, deletion, and the
runaway seed as a distinct mode. Its Clight AST is generated alongside the
pinned source surface. No semantic theorem connects executions of this C
abstraction to the handwritten Rocq `vertical_step` relation. Its public API
can violate the Rocq launch precondition; its safety predicate reports such a
violation but does not prevent it.

## Current result

`proofs/EyerokManipulation.v` packages these independent closed-world facts:

- the generated model contains the envelope constants, while the critical
  authentic-source Clight shapes pin float-constant counts, the movement call,
  and relevant dynamic-surface/list call sites; the source audit pins the exact
  impulse and gravity values but does not prove complete semantic update order;
- every state reachable in the abstract scheduler excludes the runaway seed;
- the handwritten vertical relation bounds `FirstHand` by absolute Y 1196 and
  `SecondHand` by absolute Y 2003; and
- no infinite execution of that handwritten relation is unbounded above.

The rank-to-update-order mapping, scheduler-to-vertical coupling, C-to-Rocq
semantics, and original-game refinement are all open. The project separately
proves that an idealized mathematical-integer recurrence `Y + 100*n` is
unbounded. This is not a C execution theorem: the C abstraction uses 32-bit
`int`, while original Eyerok position is binary32. Repeated original-game
binary32 `+100` eventually rounds to no position change, although it could
produce an enormous finite rise if the seed were reachable.

This is not yet a whole-program CompCert simulation of every original SM64
frame. `proofs/GlobalBoundary.v` is a generic lemma over an arbitrary run type
and arbitrary Z-valued height function; it does not itself mention Clight or
binary32. A faithful original-game instantiation, including a sound numeric
observation, remains open.

## Build

The intended toolchain is Coq 8.16.1 and CompCert 3.15 in the
`sm64-item-proof` opam switch. From PowerShell, use the Ubuntu distribution
explicitly because the default WSL distribution is not usable:

```powershell
wsl.exe -d Ubuntu
```

Run generation followed by the complete source/proof check:

```sh
opam exec --switch sm64-item-proof -- make generated
opam exec --switch sm64-item-proof -- bash pipeline/check.sh
```

The check diff-verifies the source audit, compiles every generated and
handwritten module, rejects proof-hole keywords, and prints the assumptions of
the local capstone, scheduler invariant, infinite-run theorem, and authentic
lifting theorem.
