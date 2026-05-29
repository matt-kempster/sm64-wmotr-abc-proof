# Whole-program ingestion, stubbing, and the script-interpreter "dragon"

> A faithful capture of two strategy threads: (0) can we just throw the whole SM64 codebase
> through clightgen?, and (B) the script interpreters -- can we reason about behavior/level
> scripts *as a whole* rather than per-instance? See also
> [object-set-and-glitches.md](object-set-and-glitches.md),
> [pointer-writes-and-block-disjointness.md](pointer-writes-and-block-disjointness.md),
> [trust-model.md](trust-model.md).

## Thread 0: clightgen the whole codebase

`main()` exists -- there is a real program entry -- so "the whole program" is meaningful. Two
honest facts temper "just toss it in":

1. **Per-TU output + linking.** clightgen emits one `prog` per `.c`. Whole-program reasoning
   needs them linked into a single `program`/genv via CompCert's `Linking` framework. CompCert's
   own correctness is stated over separately-compiled-then-linked modules, so this is a
   **supported, solved path -- labor, not research** -- and the labor scales with how many TUs you
   include. Often you only need the **reachable** TUs for a given property, not all ~50+.
2. **Un-clightgennable code.** A real chunk has no C for clightgen to read, or uses features it
   rejects: hand-written `.s` (most of libultra / the N64 SDK), inline `__asm__`, and C that
   pokes hardware via volatile/DMA. clightgen cannot ingest `.s` and chokes on inline asm.

## Stubbing is the answer, and it defines the project rather than killing it

Replace boundary subsystems with **`External` functions carrying a frame spec** (or a havoc
spec). CompCert Clight already treats undefined functions as `External` with arbitrary
semantics. The proof then reasons only about the C we *did* clightgen, plus these boundary specs.
This is standard verification practice (it's how every verified system handles its boundary).

The one rule: **a stub is sound only if its assumed frame over-approximates the real
subsystem's effect.** Per stub, two options:

- **Discharge it** -- prove the subsystem's frame (work; exactly what the escape/frame machinery
  is for); or
- **Trust it** -- assume e.g. "audio cannot write Mario's y" (cheap, but it enters the trusted
  base as a **named assumption**, per [trust-model.md](trust-model.md)).

For ABC properties most of SM64 (audio, rendering, most of libultra/OS) is genuinely irrelevant
to game-logic state, so stubbing it is both safe and necessary. The subsystems you **cannot**
stub are precisely the ones the gate depends on (Mario physics, the object/behavior system).

> Net: stubbing converts "we can't compile libultra" into "we have an explicit, auditable list of
> trusted boundary assumptions." It does not kill the project; it **defines its trusted
> boundary.** The right recon output is a **partition**: code-we-reason-about vs.
> boundary-we-stub-and-assume.

## Thread B: the dragon -- the script interpreters

SM64's *interesting* control flow is not C calls; it is **two bytecode interpreters** -- the
level-script engine and the behavior-script engine. Levels, the title screen, the demo system,
and **every object** (red coins, stars, enemies) are driven by data tables walked by a dispatch
loop. This is leak #2 (data-driven / indirect dispatch) at its most concentrated. The
"not many function pointers in SM64" intuition is true for ordinary code and **false** exactly
where the gameplay rules live.

### Tame them *as a whole* (the right move)

1. **Interpreter frame meta-theorems, proved once, quantified over all script data.** The prize:
   a frame theorem about the *engine itself*, e.g. "executing any behavior command mutates only
   the current object's fields plus a fixed global set." Prove that once over arbitrary scripts
   and a whole class of frame questions is settled without inspecting individual behaviors. This
   is our frame analysis lifted from "a function" to "the interpreter's step function."
2. **Per-script reasoning only as *data evaluation*.** When a property depends on one behavior
   (e.g. red coin -> star), feed that script's concrete table to the already-proven-sound
   interpreter and compute -- finite and concrete, like `Reach.v` discharging facts over a
   concrete AST by `reflexivity`. You evaluate the interpreter on data; you do not re-verify it.

Prior art is large: this is how any verified bytecode VM / definitional interpreter is done.
Treating every behavior hyperspecifically by hand is the trap to avoid.

### Why the dragon is smaller than it looks

- **Dispatch is mostly a `switch`, not a forest of function pointers.** The behavior engine
  dispatches on a command opcode through a **static** table (`BehaviorCmdProc[]`); a static const
  table behaves like a switch -- ordinary structural control flow, exactly what
  `Reach.callees_s` / `Frame.writes_global_s` already walk.
- **The genuine indirection is narrow and enumerable.** `CALL_NATIVE(func)` commands stash a C
  function pointer in the script. Their targets live in the **static** behavior/level data
  tables, so the "arbitrary function pointers" collapse to a **finite, enumerable set extractable
  by scanning the same Clight AST we already parse.** Leak #2, for the engines, becomes "list the
  native callbacks (data) and reason about each as a normal C function."

### The caveat Spiny Adoption forces

The engine's dispatch *state* (`curBhvCommand`, the interpreter's instruction pointer) lives in
the object struct -- i.e. in **corruptible memory** (see
[object-set-and-glitches.md](object-set-and-glitches.md)). So the "finite static callback set"
describes the **intended** control-flow graph; soundly, the instruction pointer can be havoc'd by
a pool-aliasing write, and the interpreter meta-theorem must permit that. The mitigation is the
same offset-level frame obligation: show reachable pool-aliasing writes do not land on the
control-pointer offsets.

## Net sequencing (where these threads leave us)

1. **Recon (cheap):** clightgen every TU; produce the **partition** (reason-about vs.
   stub-boundary), and separately measure the dragon -- count `CALL_NATIVE` sites and the
   dispatch tables -- so its true size is data, not a guess.
2. **An interpreter frame meta-theorem** is a legitimate milestone candidate (it unlocks the
   interpreter-gated threads -- "must press Start," "red coins -> star"), not a side quest.
3. **Mario-physics functional specs** (e.g. no fall damage in wing cap) are the **interpreter-free
   beachhead**: same shape as `ShadowSpec.dim_shadow`, and the deliberate down-payment on the
   Mario-physics + float reasoning the y-bound ultimately needs. Good for a concrete win while the
   engine work looms.
