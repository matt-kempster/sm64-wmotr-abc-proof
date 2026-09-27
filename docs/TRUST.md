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
| 0.3 | "Collect the star" = the red-coin star spawns and is touched. The GOAL-2 height bound must imply you can't | **Height form stated** (`WMotRRequiresA/HeightFrame.v`, `wmotr_noA_height_bound_linked12`): a no-A run keeps `pos[1] ≤ 2744` (`PHI_YMAX` = K + A, `HeightPhi.v`; K = H* = 2372 from level data via `tools/goal2_ladder.py`, A = 372 from `tools/goal2_budget.py` plus the binary32 rounding allowance). A wrong K or A would make the crux row false, not the capstone unsound. Still missing: the step "y below coin #2's grab window ⇒ coin #2 not collected ⇒ no star". |
| 0.6 | GOAL 2's height invariant `Phi` and the Mario-frame rows | **Defined** (`HeightPhi.Phi_wmotr`, design `docs/goal2-phi.md`): `R_noA` action whitelist ∧ `PhiC` over the cells action, actionState, actionTimer, pos[1], vel[1], floorHeight and `marioObj->gfx.pos[1]` (what OOB recovery restores). The cells are ranges (−75 ≤ vel ≤ 128, y ≥ −8192), the budget y + credit ≤ 2372 + 372 at pos and at gfx.pos, and the slide-kick, ground-pound and ledge clauses. Offsets and action constants are pinned against the generated AST, and `Hphi_y` is proved. **The old crux row `Hseg_action_phi` is now a lemma** (`HeightFrame.seg_action_phi`). The budget arithmetic of every move a frame can make (binary32 air step, cut step, slide-kick signed-energy step, ground-pound windup, E3 switches, attach, floor refresh, OOB) is proved (`HeightMove.Phi_of_moves`). **Open rows:** `Hact_whitelist` (the frame keeps the action in `R_noA`, GOAL 1's engine at a new predicate); `Hframe_move` (the real frame's effect on the cells is a chain of those moves, each in range; the T3 value walk; false if an unmodelled mechanism fires, listed in the row's comment); and two **level-data rows**, `wmotr_gap` (no floor height in (2372, 2994)) and `wmotr_poles` (every pole low or out of reach). `R_noA` is still a parameter (census: `docs/goal2-rnoa-census.md`). Tethered: `PhiC` holds on all 620 recorded real states (`experiments/oracle/phi_check.py`). |
| 0.7 | GOAL 2's flank segments (`HeightFrame.v`: controller poll, platform displacement, level/warp phase, non-Mario objects) do what their specs say: y / action loads as the censuses found them, and each carries GOAL 1's `MWF_real` and Φ (the poll only when A is not pressed) | **ASSUMED, labeled.** Specs, not proofs: none of that code is linked. The censuses behind the load clauses: `docs/goal2-frame-boundary-scout.md`, `goal2-wmotr-behavior-census.md`, `playground/PlatformInert.v`. The carries are stated *inside* the specs because as separate ∀-rows over every memory matching the load clauses they would be false. |
| 0.4 | The starting states the theorem quantifies over (currently `mem_ok_lp`: about 10 invented rows) | **ASSUMED**. Must become "every state the real game can be in when WMotR starts", or be checked on real recorded states (§5). |
| 0.5 | The step relation = what one real frame does | GOAL 1: **only `execute_mario_action`**. GOAL 2's `frame_step` composes that real call with four *specified* flanks (0.7): controller poll, platform, level phase, objects. The flanks are specs, not linked code. This is the largest scope gap. |

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
| 2.2 | **We verify a different preprocessing of that C.** The ROM is IDO-compiled vendor C. The proof's C adds `-DNON_MATCHING=1 -DAVOID_UB=1` and force-includes `pipeline/proof_n64.h` (every TU except `shadow.c`) | **Itemized: every site is in the register below.** `tools/ub_sites.py` preprocesses every generated TU both ways (ROM: `-D__sgi`, as IDO predefines it; proof: our flags) with clightgen's own preprocessor, and diffs them. Its output is committed as `docs/ub-sites.txt`. A new site cannot enter silently: regenerate that file and the diff shows it. |
| 2.3 | `clightgen` (CompCert's *unverified* front end: parser, elaborator, `-normalize`) translates that C faithfully | ASSUMED, **TETHERED on sampled paths**. 267 real frames over 15 actions run through the generated Clight and reproduce the game's memory byte for byte (§5.1). This is evidence for the translation of the code those frames exercise, not proof. |
| 2.4 | Our post-processing of the generated `.v` is semantics-preserving: stringlit renaming, anonymous-composite renaming (`canonicalize_anon.py`), completing extern incomplete arrays | ASSUMED. Each is a documented rename or type completion. Could be proved (rename = alpha-equivalence) or regenerated and diffed. |
| 2.5 | The target configuration (ppc32 eabi: 32-bit, big-endian) gives the same struct layout, sizes and alignment as IDO/MIPS | Partly TETHERED: offsets cited in proofs (action@12, controller@156, buttonPressed@18) match the decomp's `/*0x..*/` layout comments. Should be checked for every struct in scope, mechanically, against the built ROM's symbol/debug info. |

### 2.2 register: every place the proof's C differs from the ROM's C

The policy (2026-09-26): each difference is either an **equivalence** (same bits as
the ROM, with the argument or check named) or a **nondeterministic
over-approximation** (the model allows every value the machine could produce). A
"we picked a value" row is not allowed. Sites outside the twelve-TU link do not
affect the GOAL-1 step, but they are listed so they can't enter unnoticed when the
link grows.

| Site (hunks) | ROM C | Proof C | Class | Why it is the same machine behavior |
|---|---|---|---|---|
| `gCosineTable` (122 hunks, all TUs; `math_util.h:24`, `trig_tables.inc.c:259`) | `gCosineTable[i]`, a separate symbol | `(gSineTable + 0x400)[i]` | equivalence (layout) | ROM map: `gCosineTable` = 0x80387000 = `gSineTable` + 0x1000 bytes = +0x400 floats, the same address. In the ROM, indexing across the symbol boundary is out-of-bounds C; the proof's C makes it one object. |
| `VIRTUAL_TO_PHYSICAL`, 4 expressions in `set_mario_animation` / `set_mario_anim_with_accel` (`mario.c`) | `(uintptr_t)p & 0x1FFFFFFF`: UB on a pointer in CompCert, so the model had **no execution** (3.2) | `(uintptr_t)((unsigned char *)p - 0x80000000U)` (`pipeline/proof_n64.h`) | equivalence (arithmetic) | Every RDRAM address is KSEG0: x = 0x80000000 + y with 0 ≤ y < 2^29. Since 0x80000000 is a multiple of 2^29, x & 0x1FFFFFFF = y = x − 0x80000000. Checked on real frames by §5.1. |
| `act_air_hit_wall` missing return (`mario_actions_airborne.c:1341`) | falls off the end; the caller gets whatever is in `v0` | `return set_mario_animation(...)` | equivalence (checked against the ROM's assembly) | ROM disassembly: after `jal set_mario_animation` at 0x8026db34 the only instructions before `jr ra` are `b`, `nop`, `lw ra`, `addiu sp`; nothing writes `v0`. `set_mario_animation` sets `v0` with `lh` (0x80250ae8), which is sign-extended, so it equals the C `s16`→`s32` conversion. |
| `GET_HIGH_U16_OF_32` / `GET_LOW_U16_OF_32` (`mario_actions_cutscene.c:459,462`) | `((u16 *)&x)[0]`, `[1]` | `(u16)(x >> 16)`, `(u16)(x & 0xFFFF)` | equivalence (endianness) | The N64 is big-endian, so halfword 0 of a stored u32 is its high 16 bits. |
| `BAD_RETURN` declarations: `CameraEvent` (`camera.h:346`), `mem_pool_free` (`memory.h:78`), `save_file_copy` (`save_file.h:130`), `cur_obj_reverse_animation` / `cur_obj_extend_animation_if_at_end` (`object_helpers.h:143`), `init_bully_collision_data` (`mario_step.h:25`, `.c:74`), `update_water_pitch` (`mario_actions_submerged.c:197`) | declared to return `s32`/`s16`/`u32` but returns nothing (garbage `v0`) | declared `void` | equivalence (typing) | The proof's C type-checks with `void`, so no caller in it reads the value. The ROM callers are the same C, so they don't read the garbage either. |
| `geo_switch_anim_state`, `geo_switch_area` declarations (`object_helpers.h:69`) | 2 parameters | 3 parameters (`void *context`) | equivalence (unused) | Declarations only. These are graph-node callbacks, not called from the linked code. |
| `chuckya_act_0` `sp3C` (`behaviors/chuckya.inc.c:108`) | possibly-uninitialized local | `sp3C = 0` | **picked value: must become any-value** | Stack garbage in the ROM. Outside the GOAL-1 step (an object behavior, not reached from `execute_mario_action`). If it is ever needed: replace with an "any u32" external. |
| `shadow.c:191` missing return | falls off the end | `return waterLevel` | not yet checked | `shadow.c` is not linked. Assembly check needed before it is used. |
| `mtxf_to_mtx` (`math_util.c:577`) | register/fixed-point implementation | portable C | not yet checked | `math_util` is not in the twelve-TU link (its callers go through the external-call rows, 4.1). Needs an equivalence check before linking. |

## 3. C semantics versus what the N64 actually does

| # | Item | Status / notes |
|---|---|---|
| 3.1 | CompCert's C semantics agrees with IDO-compiled MIPS on the code in scope: evaluation order, integer promotions, float rounding (single vs double), float→int casts | ASSUMED, **TETHERED on sampled paths**. Across 267 completed real frames, 0 differ in memory and 0 diverge in external calls or arguments, including float arguments passed bit-exact to `find_floor`, `atan2s` and others (§5.1). |
| 3.2 | **Undefined behavior means "no execution" in CompCert.** If a real frame hits UB (uninitialized read, out-of-range float→s16), the model has *no* derivation for it, and a "for all executions" theorem says **nothing** about that frame | **Closed for the one measured site; open in general.** §5.1 measured 33 of 300 real WMotR frames (11%) with no CompCert execution, all from `VIRTUAL_TO_PHYSICAL(ptr)` (`macros.h:64`, `(uintptr_t)ptr & 0x1FFFFFFF`) in `set_mario_animation` / `set_mario_anim_with_accel`. Worse, the spine did not merely miss those frames: its walker had a *dead-mask* arm (`dead_mask_chk`/`dead_mask_dead`) that discharged those stores **by contradiction**, using the UB itself as a proof step. Fixed by the 2.2 rewrite (`pipeline/proof_n64.h`, pointer subtraction). The stores now execute, and the walker proves them with a real arm (`chase_arith_store_chk`/`chase_arith_assign_pres`: pointer arithmetic on a chase temp stays in a SafeB block). The dead-mask arm is deleted. After the fix: **300/300 MATCH, 0 STUCK**. The general hole (a UB site that no recorded frame hits) remains; §5.1's STUCK count is the regression gate, and 2.2's register lists every site that differs from the ROM's C. |
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
| 5.1 | **Recorded-RAM differential testing.** Headless emulator (Mupen64Plus in WSL) running the matching ROM, RDRAM dumped each frame, translated into CompCert memory, one frame run by the proved-sound interpreter (`proofs/Interp/`), compared to the emulator's next frame | 2.2–2.5, 3.1, **3.2** (a stuck run on a real frame = the UB hole is live), 4.1 (do the real externals satisfy our rows on real states?), 0.4 (do real WMotR states satisfy the starting conditions?) | **Working** (`experiments/oracle/`, README has the method). 300 random-input WMotR frames give 267 MATCH (byte-identical over about 80 KB of globals and typed heap objects), 0 DIFF, 0 DIVERGE and 33 STUCK (all from the 3.2 UB) before the `VIRTUAL_TO_PHYSICAL` rewrite, and **300 MATCH** after it. External calls are *replayed* from the game, so this checks the linked C, not the ~35 rows of 4.1. Checking those rows on the recorded real calls is the next use. Trusts: the emulator (cached interpreter) on sampled frames; the harness's RAM→memory translation (map, `.mdebug` statics, type-directed pointer rebuilding); and OCaml extraction of the interpreter. A mistake there shows up as a false STUCK/DIFF, or as a false MATCH only if it errs identically in the model and the comparison. |
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
