# Status & Next Steps — 2026-06-01

A checkpoint of the machine-checked "you must press A to fly" development. Written
before a context compaction; intended to let a fresh session resume without
re-deriving the strategy. Master is green at `1dfebe3`.

---

## 0. The goal, in one line

Machine-check (Rocq/Coq 8.19.2 + CompCert 3.15) that completing SM64's *Wing Mario
over the Rainbow* requires pressing **A**, because flight (`ACT_FLYING`) cannot be
entered without an A press. The honest top theorem is **conditional**:

> a run with **no A press** *and* **no `MARIO_SPAWN_FLYING` spawn** never reaches a
> flying action.

The spawn precondition is real and necessary: a `MARIO_SPAWN_FLYING` warp
(`level_update.c set_mario_initial_action`) enters `ACT_FLYING` with no input (Tower
of the Wing Cap). WMotR has no such warp, but we don't yet machine-extract WMotR's
object table (clightgen rejects `levels/wmotr/script.c`), so it's an explicit
hypothesis, not yet discharged.

---

## 1. The proof architecture (top → bottom)

```
 wmotr_noA_no_spawn_never_flying          WMotRStatement.v   run-level, spawn carve-out
   │  = FrameTrace.noA_run_not_flying      FrameTrace.v       PROVED induction harness
   │      needs: per-frame preservation  = Phi_preserved_noA
   ▼
 ┌───────────────── THE MIDDLE (spines) ──────────────────┐
 │ NoAFlyingSpine.v   the C-bucket spine                   │  per-frame preservation,
 │ BucketASpine.v     the store-frame spine                │  decomposed into named holes
 └─────────────────────────────────────────────────────────┘
   │  per-function obligations
   ▼
 ResetBodystate.v   real per-function body proofs (3 done) + reusable inverters
 MarioMemWF.v       memory-layout well-formedness (block distinctness)
 ActionValueFrame.v the value-frame engine (capstone exec_stmt_value_preserves)
 Flying.v / ActionGraph.v   syntactic enumeration of flying set-sites & writers
```

### The A/B/C bucket taxonomy (the key structural insight)

`Flying.v` machine-proved the set of functions that can make `m->action` flying is
small and exact. Every reachable function falls in one of three buckets:

- **Bucket A** — doesn't write the action field (the vast majority of `act_*`).
  Obligation: *its stores hit other cells/blocks, so the action cell is preserved.*
  This is the **store-frame** side. `mario_reset_bodystate` etc. live here.
- **Bucket B** — the raw action writers (Flying.v enumerated exactly these:
  `set_mario_action`, `init_mario`, `init_mario_from_save_file`, `act_air_throw`,
  `act_ledge_climb_slow`, `bounce_back_from_attack`, `check_kick_or_punch_wall`).
  Flying.v proved **none writes a flying constant**.
- **Bucket C** — the **5 flying-setter sites** (the only callers that pass a flying
  constant to `set_mario_action`): `act_shot_from_cannon`, `act_flying_triple_jump`
  (→ `ACT_FLYING`); `set_jump_from_landing`, `set_triple_jump_action` (→
  `ACT_FLYING_TRIPLE_JUMP`); `set_mario_initial_action` (the spawn hatch). Flying.v
  also proved **none checks the A button locally** (`*_no_input`): the A-dependence
  is **temporal** (the upstream jump → double → triple chain), which is the hard
  **R3** work, *not* a local guard.

---

## 2. What is machine-checked right now (green, axiom-honest)

All of the below build under `bash pipeline/build.sh` and the headline lemmas pass
`bash pipeline/assumptions.sh` with only CompCert's standard base axioms (`classic`,
`functional_extensionality`, `Events.{external_functions,inline_assembly}_sem`) — and
crucially **none of VST's** extra axioms.

### Spines (the theorem skeleton with named holes)
- **`FlyingStatement.v`** — top statement; leaves the whole hard part as one hole
  `Phi_preserved_noA`. PROVED from named hypotheses via FrameTrace.
- **`NoAFlyingSpine.v`** — decomposes per-frame preservation into the enumerated
  holes: `chokepoint` (buckets A+B folded), 4 R3 site holes
  (`no_{cannon,ftj,sjfl,stja}_without_A`), 1 spawn hole (`no_spawn_without_flag`).
  `keeps_nonflying` + `spine_noA_no_spawn_never_flying` PROVED by composition.
- **`BucketASpine.v`** — the store-frame spine. Bucket A = ONE engine
  (`store_frame_bridge`) × N bodies; each body's contribution is a **decidable**
  local-safety check, so the leaves are real `reflexivity` facts
  (`reset_bodystate_locally_safe`, etc.; negative control:
  `set_jump_from_landing_NOT_locally_safe`).
- **`WMotRStatement.v`** — run-level theorem with the spawn carve-out.

### Memory layout
- **`MarioMemWF.v`** — `mario_mem_wf m bm bbs`: Mario's block `bm` is distinct from the
  body-state block `bbs` (PROVED via `Genv.global_addresses_distinct`), and
  `m->marioBodyState` loads into `bbs`. The anti-aliasing brick.

### Reusable inverters (in `ResetBodystate.v`)
- `exec_bodystate_load` — pointer-field **load** inverter (`bodyState = m->marioBodyState`
  → off-`bm` temp, memory unchanged).
- `exec_field_store_block` — pointer-chase **store** → target block.
- `exec_marioState_field_store` — **direct** store → block `bm` + pinned offset.
- forward helpers: `chase_store_preserves`, `direct_store_preserves`,
  `flags_store_preserves`; tactic `seq2_absurd`, `chase_one`.

### Real per-function body proofs (3 done — all capabilities)
| lemma | function | capability exercised |
|---|---|---|
| `mario_reset_bodystate_preserves` | `mario_reset_bodystate` | **pointer-chase** stores (block-distinctness) + direct flags store |
| `hurt_and_set_mario_action_preserves` | `hurt_and_set_mario_action` | **function calls** (`reach_value_preserves`) + direct store + return |
| `play_mario_action_sound_preserves` | `play_mario_action_sound` | **control flow** (`if`/`else` case-split) + call + direct store |

Each: real clightgen'd body, `action_sat nonflying` preserved, **no `Admitted`**,
CompCert-axiom-clean.

### Syntactic backbone
- **`Flying.v`** — the 5 flying set-sites and the no-raw-flying-writer corpus, by
  `reflexivity` over real ASTs. The stale-header note: `ACT_FLYING = 0x10808899 =
  277350553` (the `sm64.h` comment `0x10880899` is wrong).
- **`ActionGraph.v`** — the action-transition edge graph; flying edges pinned by value.
- **`ChaseCount.v`** — measured the per-function burden (see §4).

### The value-frame engine
- **`ActionValueFrame.v`** — `action_sat`, `action_cell`, and the capstone
  `exec_stmt_value_preserves` (threads `action_sat` through any statement given
  `reach_value_preserves` + `reach_ext_preserves` + `stmt_value_ok`). Its limitation
  is the generalization target (§5).

### Infrastructure
- CI (`.github/workflows/build.yml`) mirrors `pipeline/*.sh`, type-checks the tree and
  axiom-gates the headline theorems.
- `LinkSpike.v` — symbolic cross-TU linking template (resolve via CompCert metatheory,
  never `vm_compute` a whole-program link → OOM).

---

## 3. VST investigated and REJECTED (don't re-litigate)

We installed `coq-vst.2.15` (additive, reversible) and spiked it. **It works locally
and decisively** — `forward` proves a pointer-chase store preserves a sibling field in
3 lines, adversarially verified genuine. **But it is architecturally unreachable** from
our tower:

- VST's only soundness (`semax_prog_sound`/`semax_prog_rule`) is **whole-program** and
  **small-step juicy** (`cl_core_sem`, `jsafeN`, `m_phi`/`m_dry`); `eval_funcall`
  appears **nowhere** in VST, and **no `semax_body_*` lemma** ties one function's spec
  to operational behavior.
- Bridging to our big-step `body_preserves_nonflying` would need: spec the *whole*
  reachable program + `main` → `semax_prog` → `jsafeN` → extract one fn → juicy-small →
  plain-small → big-step. That's strictly more work than the thing it avoids, plus a
  broader axiom base.

**Decision: stay in our big-step framework; generalize our own proof.** VST is left
installed (harmless; `opam remove coq-vst` to reclaim disk). Spike artifacts in
`/tmp/vstspike`. Full reasoning in memory `vst-option.md`.

---

## 4. The scaling measurement (`ChaseCount.v`)

Per TU, (pointer-chase functions / total internal): mario 14/62, airborne 16/64,
moving 11/73, stationary 7/44, submerged 15/57, cutscene 36/93, object 4/14, automatic
8/28 → **111 chase / 435 internal** across 8 TUs (excludes `interaction`,
`level_update`, and the ~111 behaviors in `behavior_actions`).

**Conclusion (machine-anchored):** per-function proofs do NOT scale to 111+. Confirmed
empirically — `mario_reset_bodystate` is the *only* call-free single-chain function;
every other chase function needs calls, array-stores, deep chains, or control flow. So
the 3 per-function proofs are **prototypes that validate the pieces**, not the
production method. The generic engine (§5) is the end state.

---

## 5. The remaining gaps (honest, prioritized)

### (a) Array-element stores — the one un-cracked lvalue shape *(blocking)*
Stores like `m->vel[i]` (lvalue `Ederef (Ebinop Oadd (m->fld) i)`). I built an
array-store inverter but `inv` on the array `By_reference` `deref_loc` **hangs**
(timeout, not error) — almost certainly `vm_compute` forcing the genv `cenv` inside
`sem_add_ptr_int`. **Fix to try:** reduce `sem_add_ptr_int`/`sizeof` with scoped `cbn`
(keeping `cenv` abstract, since `sizeof tfloat = 4` ignores it) instead of
`vm_compute`. This is the only control shape not yet handled. (The simplest if-else
function, `set_mario_action_submerged`, is blocked on exactly this.)

### (b) The generic temp-provenance capstone — the scalable end state *(the big one)*
Upgrade `ActionValueFrame.assign_value_ok`/`exec_stmt_value_preserves` to **thread a
temp-environment invariant `INV`** (kills the `forall le` wall that blocks chase
stores). The prototype proofs revealed `INV`:

> `INV le m := mem_wf m bm ∧ valid_block m bm ∧ (every temp holding Vptr b _ has b=bm ∨ b≠bm)`

Per-store obligation splits on the base temp's value: `Vptr bm` → offset check; off-`bm`
→ block-distinct. `INV` is established at each chase-field-load `Sset` (off-`bm` by
`mem_wf` = `exec_bodystate_load` generalized) and preserved by other statements. Proven
once, this discharges all 111 chase functions and folds the per-function proofs away.

### (c) Discharge the `reach_value_preserves` hypotheses *(recursion)*
The call-bearing proofs assume callees preserve `action_sat`. This bottoms out at
`set_mario_action` (use `ActionValueFrame.set_mario_action_body_action_sat`, gated on a
non-flying argument) and at leaf functions. Needs the recursion/closure tied together.

### (d) `mem_wf` for the other chase fields
`MarioMemWF` covers `marioBodyState`. Extend to `marioObj`, `floor`, `wall`, `ceil`,
`area`, `heldObj`, … — mechanical (same `Genv.global_addresses_distinct` shape), needed
for chase functions through those fields.

### (e) Bucket C — the R3 temporal closure *(the genuinely hard frontier)*
The 4 A-gated site holes in `NoAFlyingSpine`. All reduce to one fact: the jump chain
(`ACT_JUMP → DOUBLE → TRIPLE`, and cannon-launch) can't be entered without an A press.
`ActionGraph.v` is the syntactic groundwork. This is temporal (across frames), not a
per-frame store argument — the hardest remaining piece. The spawn site (5th) is
design-complete (the precondition).

### (f) Model faithfulness / `step` instantiation
`step` in the spines is still an abstract relation. Instantiate it with the real
per-frame `execute_mario_action` big-step (`FlyingStatement.mario_update` is the
grounded version). Plus: whole-tick faithfulness (behaviors can't flip the action —
`Flying.no_behavior_is_a_flying_setter` covers the syntactic side).

### (g) Cross-TU linking
The action handlers live in `mario_actions_*` TUs; their callees (`set_mario_action`)
are in `mario.c`. `LinkSpike.v` is the symbolic-linking template. Needed once we leave
`mario.c`-only functions.

### (h) WMotR object-table extraction
Discharge "WMotR loaded ⇒ `no_spawn_flying_run`" from the level's object set. Blocked on
clightgen rejecting `levels/wmotr/script.c`. The only gap between the conditional
theorem and an unconditional WMotR statement.

---

## 6. Recommended next steps (in order)

1. **Crack the array-store hang** (§5a) — scoped `cbn` over `sem_add_ptr_int`, keep
   `cenv` abstract. Unblocks `m->vel[i]` and the simplest if-else function. Small,
   well-scoped.
2. **Build the temp-provenance capstone** (§5b) — the scalable kill. Start by
   generalizing `exec_bodystate_load` to "any chase-field load yields an off-`bm` temp
   under `mem_wf`," then thread `INV` through `exec_stmt_value_preserves`. This is the
   highest-leverage work; it retires the per-function treadmill.
3. **Discharge `set_mario_action`'s preservation** (§5c) so the call-bearing proofs
   become unconditional.
4. Then attack **Bucket C / R3** (§5e) — the real intellectual frontier.

The per-function proofs (1–3 done) have served their purpose: they prove every control
shape is handlable in our semantics and they *are the spec* the capstone must satisfy.
Continuing one-by-one past here is the wrong use of effort (§4) — fold them into (b).

---

## 7. Battle scars / gotchas (save future hours)

- **Never `vm_compute` over `mario_ge`** (= `globalenv mario.prog`) — forces the whole
  genv → OOM (crashed the machine once). Use `genv_cenv_mario` to rewrite to `mario_ce`
  (the light `prog_comp_env`), or pin offsets by `field_offset` **determinism**
  (`congruence` vs a `vm_compute`'d fact) — never compute the genv.
- **`inv`'s `subst`** eliminates a `x = literal` equation (e.g. `off_bs = 200`), so
  reference the literal afterward, not the bound var.
- **Folded Clightdefs Definitions** don't match constructor patterns: match
  `deref_loc (tptr _)` / `(tarray _ _)`, *not* `(Tpointer _ _)` / `(Tarray _ _ _)`;
  `cbn [typeof]` does not unfold `tptr`/`tarray`/`tuint`.
- **`!` (PTree get) is shadowed by `ClightNotations`** — match composites with explicit
  `PTree.get k m`, not `m ! k`.
- **`exec_stmt` has 10 args** — `Ssequence`-peel match patterns need `5 + stmt + 4`
  underscores. `Local Ltac` can't see proof-local vars (`bm`, `Hbbs`) — parametrize.
- **`set_opttemp None vres le`** (clightgen void call) isn't reduced; `cbn
  [set_opttemp]` before threading `le!_m` through `PTree.gso`.
- **`sizeof ce tfloat`/`tuint`** = scalar size, ignores `ce` → prove `= 4` by
  `reflexivity` (don't `cbn [sizeof]`, which gets stuck on the folded type).
- **Side-condition evar order**: discharge the `exec_stmt` premise (which fixes the
  field) *before* `vm_compute`-ing a `field_offset` goal — prove side conditions as
  explicit `assert`s, then `destruct`, rather than `edestruct … ; [ … ]`.
- **Always use `pipeline/*.sh`** (never raw `coqc`; switch-less `coqc` lies). `check.sh
  -time` localizes hangs by last-completed sentence.
- **Build → READ result → commit as SEPARATE steps**; never batch build+commit (a
  killed build can slip a red commit through; CI is the backstop).

---

## 8. Field offsets in MarioState (verified by `field_offset` over `mario_ce`)
`action @ 12` (Mint32, the watched cell [12,16)); `input @ 2`; `flags @ 4`; `vel @ 72`
(tarray tfloat 3 → vel[i] @ 72+4i); `forwardVel @ 84`; `slideVelX @ 88`; `slideVelZ @
92`; `marioBodyState @ 200`; `hurtCounter @ 238`.

## 9. Key commits this session
`9731f22` CI · `f31cb9b` MarioMemWF · `760afc9`/`2193dbb` spines · `a44a814` load
inverter · `ed1e307` ChaseCount · `683b944` direct-store inverter · `f824fcd` forward
helpers · `9c7b0d5` reset_bodystate body · `4a49a34` hurt (call) · `1dfebe3`
play_mario_action_sound (control flow).
