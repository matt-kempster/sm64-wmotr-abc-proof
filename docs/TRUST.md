# The trust ledger — what a reader must believe when the proof is done

Every item a reader has to *accept* in order to believe the final theorem is
about the real Super Mario 64. A proof shrinks this list; it can never empty it.
The target ("~no assumptions") is: **only the Foundations layer remains**, plus a
theorem statement short enough to read, with everything else proved or pinned to
recorded evidence.

Each row: what you have to believe, why it's there, how it's tethered to reality today,
and how it shrinks. Keep this file current: add a row the moment a new kind of trust
enters the proof, and never let one enter silently.

Status key: **PROVED** (a theorem, Foundations only) · **TETHERED** (checked
against the real game, not proved) · **ASSUMED** (neither).

---

## 0. The statement itself

*You must read the final theorem and agree it says "WMotR's star can't be collected
without pressing A".*

| # | Item | Status / notes |
|---|---|---|
| 0.1 | The definition of "no A": the controller's `buttonPressed & A_BUTTON` is clear every frame (`AGates.v`) | Needs a reader check. `buttonPressed` is the rising edge, so holding A from boot is not "pressing". This matches ABC convention, but the ledger should say it. |
| 0.2 | The definition of "flying" (`Flying.v`: `ACT_FLYING`, `ACT_FLYING_TRIPLE_JUMP`; the invariant set also has `ACT_SHOT_FROM_CANNON`) | Constants read from the generated AST. |
| 0.3 | "Collect the star" = the red-coin star spawns and is touched. The GOAL-2 height bound must imply you can't | GOAL 2 is not stated yet. |
| 0.4 | The starting states the theorem quantifies over (currently `mem_ok_lp`: about 10 invented rows) | **ASSUMED**. Must become "every state the real game can be in when WMotR starts", or be checked on real recorded states (§5). |
| 0.5 | The step relation = what one real frame does | Today it's **only `execute_mario_action`**. Objects, level scripts, warps, platforms and the other threads are outside it. This is the largest scope gap. |

## 1. Foundations (irreducible; every formal proof has these)

| # | Item | Notes |
|---|---|---|
| 1.1 | The Rocq/Coq 8.19.2 kernel is sound | Standard. |
| 1.2 | Axioms: classical logic, functional extensionality, proof irrelevance, Flocq's classical reals | Standard. `discipline_check.sh` enforces that nothing else appears. |
| 1.3 | CompCert 3.15's definitions of C (Clight syntax, big-step semantics, memory model, `Cop` arithmetic, IEEE floats via Flocq) mean what C means | This is a *definition* to trust, not CompCert's compiler-correctness theorem. We never use the compiler. |

## 2. From the ROM to the C we verify

| # | Item | Status / notes |
|---|---|---|
| 2.1 | The decomp C is the game: compiled with IDO 5.3 it reproduces the US ROM byte-for-byte | **Checked** (2026-09-26): `vendor/sm64` @ 9921382 built with `make VERSION=us COMPARE=1` has sha1 `9bef1128…6ce`, which equals the US baserom (`experiments/oracle/README.md`). Covers the *default* preprocessing only; see 2.2. |
| 2.2 | **We verify a different preprocessing of that C.** `pipeline/clightgen.sh` passes `-DNON_MATCHING=1 -DAVOID_UB=1`, so every `#ifdef AVOID_UB` / `NON_MATCHING` site is C that the ROM was *not* built from | **ASSUMED, must be itemized.** Known in-scope site: `act_air_hit_wall` (`mario_actions_airborne.c:1340`). The ROM's missing `return` returns leftover register contents (the result of `set_mario_animation`, behind the "firsties" behavior), and AVOID_UB makes that return explicit. Also `BAD_RETURN`, `GET_HIGH_U16_OF_32` (`sm64.h`, `types.h`), `math_util.c:574`, and C replacements for `GLOBAL_ASM` functions. And `math_util.h:22`: under AVOID_UB, `gCosineTable` is `(gSineTable + 0x400)`, where the ROM has a separate symbol over the same bytes. The model therefore indexes `gSineTable` past 0x1000 bytes (same memory, and §5.1 frames agree). Each needs a row: *identical behavior to the ROM, or a documented difference*. |
| 2.3 | `clightgen` (CompCert's *unverified* front end: parser, elaborator, `-normalize`) translates that C faithfully | ASSUMED, **TETHERED on sampled paths**. 267 real frames over 15 actions run through the generated Clight and reproduce the game's memory byte for byte (§5.1). This is evidence for the translation of the code those frames exercise, not proof. |
| 2.4 | Our post-processing of the generated `.v` is semantics-preserving: stringlit renaming, anonymous-composite renaming (`canonicalize_anon.py`), completing extern incomplete arrays | ASSUMED. Each is a documented rename or type completion. Could be proved (rename = alpha-equivalence) or regenerated and diffed. |
| 2.5 | The target configuration (ppc32 eabi: 32-bit, big-endian) gives the same struct layout, sizes and alignment as IDO/MIPS | Partly TETHERED: offsets cited in proofs (action@12, controller@156, buttonPressed@18) match the decomp's `/*0x..*/` layout comments. Should be checked for every struct in scope, mechanically, against the built ROM's symbol/debug info. |

## 3. C semantics versus what the N64 actually does

| # | Item | Status / notes |
|---|---|---|
| 3.1 | CompCert's C semantics agrees with IDO-compiled MIPS on the code in scope: evaluation order, integer promotions, float rounding (single vs double), float→int casts | ASSUMED, **TETHERED on sampled paths**. Across 267 completed real frames, 0 differ in memory and 0 diverge in external calls or arguments, including float arguments passed bit-exact to `find_floor`, `atan2s` and others (§5.1). |
| 3.2 | **Undefined behavior means "no execution" in CompCert.** If a real frame hits UB (uninitialized read, out-of-range float→s16), the model has *no* derivation for it, and a "for all executions" theorem says **nothing** about that frame | **LIVE, measured** (§5.1). 33 of 300 real WMotR frames (11%) have no CompCert execution. `set_mario_animation` and `set_mario_anim_with_accel` run `VIRTUAL_TO_PHYSICAL(ptr)` (`macros.h:64`, `(uintptr_t)ptr & 0x1FFFFFFF`) after every fresh animation DMA, and bitwise AND on a pointer is undefined in CompCert. The spine *walks* `set_mario_animation`'s body (`sub_sma_row`), so GOAL 1's ∀-executions claim is silent on every animation-loading frame. **Fix candidate:** a proof-only `VIRTUAL_TO_PHYSICAL` defined as pointer subtraction, `(u8*)(addr) - 0x80000000` (`macros.h:70` already has this form as `VIRTUAL_TO_PHYSICAL2`). It is bit-identical to the mask on KSEG0 addresses, and CompCert defines it. It would be a 2.2 row, checked by §5.1. |
| 3.3 | Concurrency: the game thread is the only writer of the state we reason about, and frames don't interleave with other threads' writes (audio, VI/PI interrupts, controller reads via `osContGetReadData`) | ASSUMED. The input buffer is written by the controller path. **Observed** (§5.1 recordings): during a single `execute_mario_action` call, the PI manager thread, DMA into `gMarioAnimsBuf` (Mario's animation data), thread save areas and `gZBuffer` all change. So Mario's *animation buffer* is filled by DMA mid-call. Needs an argument (likely: those threads write only buffers the game thread copies at a fixed point). |
| 3.4 | Lag frames and frame pacing don't matter (the theorem is per *game-logic* frame) | ASSUMED, probably easy. |

## 4. Scope: code and data outside what is linked

| # | Item | Status / notes |
|---|---|---|
| 4.1 | Functions outside the 12 linked files (collision, `math_util`, audio, camera, save file, object spawning) behave as the capstone's rows say (`Hocp_*`, `Hpres_*`, `Hext_*`, …) | **ASSUMED, the ~35 project rows.** Shrinks by linking more files (collision and `math_util` next, then the object system) until only truly external things remain. |
| 4.2 | CompCert's `external_functions_sem` is an abstract Parameter. Anything left external is constrained *only* by our rows | Permanent for whatever stays external. The goal is that nothing game-logic stays external. |
| 4.3 | Level data (WMotR collision triangles, object placements, the red-coin positions) is what the ROM contains | Not yet in scope at all. Can be clightgen'd like code (`levels/wmotr/*.inc.c`). |
| 4.4 | The proof's internal vocabulary (`MWF_real`, `SafeB`, `call_pres_ext_*`) appears in the *statement's* hypotheses | Anti-goal: a reader shouldn't have to understand proof internals to know what's assumed. Rows must eventually be about the game, or be gone. |

## 5. Tethers: evidence the model is the game (NOT proof)

These don't make the theorem stronger. They check that its assumptions describe the
real game, and they find false rows (four were found historically, all "provable but
false about the game").

| # | Tether | What it checks | Status |
|---|---|---|---|
| 5.1 | **Recorded-RAM differential testing.** Headless emulator (Mupen64Plus in WSL) running the matching ROM, RDRAM dumped each frame, translated into CompCert memory, one frame run by the proved-sound interpreter (`proofs/Interp/`), compared to the emulator's next frame | 2.2–2.5, 3.1, **3.2** (a stuck run on a real frame = the UB hole is live), 4.1 (do the real externals satisfy our rows on real states?), 0.4 (do real WMotR states satisfy the starting conditions?) | **Working** (`experiments/oracle/`, README has the method). 300 random-input WMotR frames give 267 MATCH (byte-identical over about 80 KB of globals and typed heap objects), 0 DIFF, 0 DIVERGE, and 33 STUCK, all from the 3.2 UB. External calls are *replayed* from the game, so this checks the linked C, not the ~35 rows of 4.1. Checking those rows on the recorded real calls is the next use. Trusts: the emulator (cached interpreter) on sampled frames; the harness's RAM→memory translation (map, `.mdebug` statics, type-directed pointer rebuilding); and OCaml extraction of the interpreter. A mistake there shows up as a false STUCK/DIFF, or as a false MATCH only if it errs identically in the model and the comparison. |
| 5.2 | Positive control: with A pressed, the model can fly (`PositiveControl.A_pressed_frame_reaches_flying`) | The theorem isn't true for a trivial reason: the step relation is non-empty and flying is reachable | **PROVED**, under an invented flat-world oracle and a hand-built (non-real) memory. Should be redone from a *recorded* WMotR state (5.1). |
| 5.3 | ESBMC model checking on the vendor C (`experiments/esbmc/`) | Candidate GOAL-2 invariants against the real C before Coq effort | A scout. Trusts ESBMC plus stub contracts; nothing in `proofs/` rests on it. |

## 6. Tools we use but do not trust

Their outputs are re-checked by the Coq kernel, so they add nothing to the ledger.
Listing them makes that explicit.

- `proofs/Interp/`: the interpreter (`ClightInterp`, soundness proved against
  ClightBigstep), `CMem` (proved equal to `Mem.*`), `LinkGenv` (proved equal to
  `globalenv lp`). Runs happen inside `vm_compute`, so the kernel re-checks them.
- The `vm_compute` checker itself **is** trusted (part of 1.1; the kernel's VM).
- `discipline_check.sh`, `check_unwired.py`, `tools/clight_pretty.py`: hygiene and display only.
