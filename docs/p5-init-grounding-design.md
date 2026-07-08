# P5 — Bucket-B init grounding: design scout

Read-only design memo for task #92. **No `.v` was edited.** Goal: discharge the
~11 "bucket-B" runtime-layout hypotheses of the twelve-TU GOAL-1 capstone
(`proofs/NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v`) from `Genv.init_mem` facts +
an explicit spawn condition, and prove that condition satisfiable (non-vacuity).

Discipline note (`.claude/skills/proof-discipline/SKILL.md`): every row below is
either an assumption the capstone currently *assumes* (so discharging it is a
Step-2.1 residual ELIMINATION — real tethering) or is flagged as **not
dischargeable without strengthening**. The proposed spawn condition is
**decomposed, never laundered**: it asserts three `find_symbol` equations + an
`init_mem` anchor, and every bucket-B row is *derived* from those — no row is
restated verbatim as an assumption.

---

## 0. The load-bearing discovery (changes the whole design)

The memory note `bm-is-runtime-block` (bm is a fresh runtime block because
`gMarioState` has `gvar_init = nil`) is **true only for `mario.c` in isolation**.
In the *twelve-TU link* `lp` it is **false**, and this is the pivot of the memo:

- `generated/mario.v:812` — `v_gMarioState.gvar_init = nil` (extern declaration).
- `generated/level_update.v:2141` — `v_gMarioState.gvar_init =
  (Init_addrof _gMarioStates (Ptrofs.repr 0) :: nil)` — **statically
  initialized to `&gMarioStates[0]`**.
- `generated/level_update.v:2034-2039` — `v_gMarioStates.gvar_init =
  (Init_space 200 :: nil)`, `gvar_info = tarray (Tstruct _MarioState) 1` — a
  **defined** 200-byte static array (`generated/level_update.v:8983` puts it in
  `prog_defs`).
- Link resolution: `classify_init nil = Init_extern`
  (`compcert/common/Linking.v:96`) and `link_varinit Init_extern _ = Some i2`
  (`Linking.v:103`), so the linked `gMarioState` def is the **`Init_addrof`**
  one (level_update wins over mario.v's empty decl) and the linked
  `gMarioStates` is the **`Init_space 200`** def (behavior_actions'
  `gMarioStates` is `nil`/extern — `generated/behavior_actions.v:2957-2962` — so
  it loses to level_update's). `level_update.prog` is member #9 of `tu_rest`
  (`proofs/MarioModel/LinkedTwelve.v:77-89`), so this holds in every `linked12
  lp`.

**Consequence.** In `lp`, `gMarioStates` is a genuine symbol with an
`init_mem` block, and `gMarioState`'s cell is statically `(gMarioStates_block,
0)`. `MWF_real` row **R5** (`MWFReal.v:224-228`: "the gMarioState cell, IF a
pointer, is `(bm,0)`") therefore **forces `bm = the gMarioStates symbol block`**
at `init_mem`. So `bm` is a **symbol block**, not a fresh runtime block, and the
same for `bc` (`gControllers`, `generated/mario.v:299,791`). This makes the
distinctness rows pure `genv_vars_inj` corollaries rather than a
block-freshness argument — the single biggest simplification available, and it
was hidden until the AST was read at link scope.

(A MarioState is modeled as 200 bytes here — `action@12`, `controller ptr@156`,
`marioBodyState@152`, `hurtCounter@178` all fit; the pipeline's
"gMarioStates extern-array completion" synthesized this defined static.)

---

## 1. The bucket-B rows: exact statements + consumers

Source: `proofs/NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v:69-96` (identical shapes
re-declared in the `NoARealInputMWF` section of
`NoAImpliesNoFlyLinked.v:670-724` and the `MWFReal` section
`MWFReal.v:153-186`). All are over `lp_ge lp := globalenv lp`
(`RealFrameLinked.v:53`). `MWF := MWF_real lp bm bc oc0 SafeB`.

| Row | Statement (abbrev.) | Consumed by |
|---|---|---|
| `Hbc_bm` | `bc <> bm` | `MWFReal.v` R2/store lemmas (`mwf_real_act_store`, `_root_store` block-distinctness legs) |
| `HSafeB_not_bm` | `∀ b, SafeB b → b <> bm` | `MWFReal.v:646-652,800-805,1023-1028` (R7 legs of every store lemma) |
| `HSafeB_not_bc` | `~ SafeB bc` | `MWFReal.v` store lemmas + `MovingLeafSurface`/`SubmergedSurface` (grep hit) |
| `Hgms_blk` | `find_symbol _gMarioState = Some gb → gb≠bm ∧ gb≠bc ∧ ~SafeB gb` | `MWFReal.v:156-158` (R5/R8 grounding) |
| `Hglob_blk` | `mem_id gid stored_globals → find_symbol gid = Some bg → bg≠bm ∧ bg≠bc ∧ ~SafeB bg` | `MWFReal.v:159-162` (`mwf_real_sglob`) |
| `Hgtimer_blk` | same shape, `_gGlobalTimer` | `MWFReal.v:166-168` (R8 non-pointer row) |
| `Htable_blk` | same shape, `_sInteractionHandlers` | `MWFReal.v:174-177` (R9 dispatch-table row) |
| `Hktab_blk` | `mem_id gid knockback_table_ids → … → kb≠bm ∧ kb≠bc ∧ ~SafeB kb` | `MWFReal.v:183-186` (R10) |
| `Hsfam_safe` | `find_symbol _sFloorAlignMatrix = Some gb → SafeB gb` (POSITIVE) | `MovingLeafSurface.v` (align_with_floor `throwMatrix` store) |
| `Hbc_sym` | `∃ gid, find_symbol gid = Some bc` | `NoAImpliesNoFlyLinked.v:720` OutParam arc (bc-disjoint local via `local_blk`) |
| `Hglob_valid` | `∀ m, MWF m → ∀ gid bg, find_symbol gid = Some bg → valid_block m bg` | `NoAImpliesNoFlyLinked.v:722-724` OutParam arc (fresh local disjoint from all globals) |

**`WL_exempt` is NOT bucket-B-shaped.** `NoAImpliesNoFlyTwelve.v:114-118` is a
`marg_exempt fd = true` fact about the *callee surface* (env hygiene), not a
block-layout fact. It belongs to the callee/engine bucket; leave it out of P5.

---

## 2. How `bm`/`bc` get their values in the real run

The run starts at `init := the linked init memory`. `mem_ok_lp`
(`NoAImpliesNoFlyLinked.v:91-92`) is `valid_block init bm ∧ mem_nontainted_lp
init ∧ MWF init`; `MWF = MWF_real …` (`MWFReal.v:190-266`). What pins `bm`/`bc`:

- **`bm` is pinned by R5 + the static `Init_addrof`.** At `init_mem lp`, the
  `gMarioState` cell loads `(gMarioStates_block, 0)` (below); R5 (`MWFReal.v:224`)
  then forces `bm = gMarioStates_block`.
- **`bc` cell is NULL at init** (R2, `MWFReal.v:210-212`, is *conditional* — "IF
  a pointer"). `gMarioStates` content is `Init_space 200` = all zero, so
  `bm+156` is `Vint 0`, not a pointer, and R2 holds **vacuously at init**. `bc`
  is the block the game later stores (`m->controller = &gControllers[0]`); the
  faithful choice is `bc = gControllers_block`, `oc0 = 0`. Nothing at init
  constrains `bc`, so any run-consistent choice works — pick the symbol block.
- **SafeB at init is nearly empty.** Chase roots (`marioObj@136`, etc.) are zero
  in `Init_space 200`, so R6 (`MWFReal.v:230-237`) is vacuous at init; `SafeB`
  grows only as the game spawns objects and stores their pointers into
  Mario's chase cells (R7 load-closure, `MWFReal.v:239-242`).

---

## 3. CompCert `Genv` toolkit for the discharge

All in `~/.opam/sm64-proof/lib/coq/user-contrib/compcert/common/Globalenvs.v`:

- **Symbol injectivity** — `genv_vars_inj` (`:155`): `find_symbol id1 = Some b →
  find_symbol id2 = Some b → id1 = id2`. Contrapositive gives every
  `distinct-ident → distinct-block` fact (the ≠bm/≠bc conjuncts).
- **Symbol existence** — `find_symbol_exists` (`:440`): `In (id,g) (prog_defs p)
  → ∃ b, find_symbol (globalenv p) id = Some b`. Gives `Hbc_sym` and the block
  for every censused id.
- **Symbol blocks are valid at init** — `find_symbol_not_fresh` (`:1268`):
  `init_mem p = Some m → find_symbol id = Some b → valid_block m b`. Core of
  `Hglob_valid` and bm/bc validity.
- **Block-range** — `genv_symb_range` (`:153`): `find_symbol id = Some b → Plt b
  genv_next`; `init_mem_genv_next` (`:1258`): `genv_next (globalenv p) =
  nextblock (init_mem p)`. Together: every symbol block `< nextblock init`.
- **Reading the `Init_addrof` content** — `init_mem_characterization_gen`
  (`:1302`) gives `globals_initialized`, whose `load_store_init_data` clause at
  the `Init_addrof` case (`:1042-1044`) yields exactly `∃ b', find_symbol ge
  _gMarioStates = Some b' ∧ Mem.load Mptr init gMarioState_block 0 = Some (Vptr
  b' Ptrofs.zero)`. This is the machine proof that `bm = gMarioStates_block`.
- **Freshness algebra** (only needed for the rejected Candidate B): `Plt_ne`
  (`Coqlib.v:113`), `Plt_strict` (`Coqlib.v:174`), `Mem.alloc_result`/
  `nextblock_alloc` (`Memory.v:1720`).

**Note on runtime-block freshness:** if `bm` *were* a fresh alloc, `alloc`
returns `block = nextblock (pre-alloc mem) ≥ genv_next`, and `genv_symb_range`
gives every symbol `< genv_next`, so `bm ≠` every symbol automatically. We do
**not** need this — §0 shows `bm` is a symbol block — but it is the fallback and
it is why Candidate B is *sound-if-faithful*, just unfaithful here.

---

## 4. Candidate spawn conditions

### Candidate A — init-anchored static-symbol spawn (RECOMMENDED)

```coq
Definition spawn_ok (lp : Clight.program) (init : mem)
                    (bm bc : block) (oc0 : ptrofs) : Prop :=
  Genv.init_mem lp = Some init
  /\ Genv.find_symbol (lp_ge lp) mario._gMarioStates  = Some bm
  /\ Genv.find_symbol (lp_ge lp) mario._gControllers   = Some bc
  /\ oc0 = Ptrofs.zero.
```

- **(a) every bucket-B row follows.** Distinctness (≠bm/≠bc) from
  `genv_vars_inj` + distinct idents; `Hbc_sym` trivial (`gid := _gControllers`);
  bm/bc validity + `Hglob_valid` from `find_symbol_not_fresh` (after the R0
  strengthening in §5); R5-at-init from `Init_addrof` (§3). The **`~SafeB` /
  `SafeB`-positive** conjuncts are discharged from the *separate* SafeB
  concretization (§5, Slices 4-5) — `spawn_ok` deliberately does **not** mention
  SafeB, so it cannot launder those.
- **(b) satisfiable.** Witness is the concrete `init_mem lp`. `linked12_inhabited`
  (`Linked12Sat.v:475`) already gives `lp`; `init_mem lp = Some init` succeeds
  for a well-formed Clight program (consistent defs, which the twelve-TU link
  certificate `Linked12Sat.v` established). Then `find_symbol _gMarioStates` and
  `_gControllers` are `Some _` by `find_symbol_exists` on `prog_defs lp`. So
  `∃ init bm bc oc0, spawn_ok …` is a Qed-able non-vacuity certificate — this is
  the demonstration that kills the vacuity critique.
- **(c) no smuggling.** `spawn_ok` = three `find_symbol` facts + one `init_mem`
  fact. None of the 11 rows appears in it; each is derived. Faithful to the AST
  (`Init_addrof`), so no invented memory.

### Candidate B — fresh-runtime spawn (REJECT)

Posit `bm`, `bc` fresh (`Plt genv_next bm`), with a spawn *store* establishing
`gMarioState` cell `= (bm,0)`. Distinctness via freshness (§3). **Reject:** it
**contradicts the generated AST** — `lp` statically sets `gMarioState :=
&gMarioStates[0]` (`Init_addrof`, §0), so the real cell is
`(gMarioStates_block, 0)`, a *symbol* block. R5 then forces `bm =
gMarioStates_block`, making the "fresh" posit **false**. Choosing a fresh `bm`
is exactly the phantom-`forall`/invented-memory trap the discipline warns
against — a memory the program never produces. Only admissible if the game
demonstrably re-points `gMarioState` to a heap block, which the clightgen'd code
does not show.

### Candidate C — hybrid: static bm/bc, finite explicit SafeB (FALLBACK)

Same anchor as A, but define `SafeB` as a *finite hand-list* of the static
globals the chase touches (`sFloorAlignMatrix`, the object-pool global, …) plus
a load-closure clause. Weaker: R7 (`MWFReal.v:239-242`) demands genuine
load-closure, and a hand-list re-introduces per-store membership bookkeeping and
risks incompleteness. Keep only as a fallback if the least-fixpoint SafeB (A's
Slice 3) proves intractable.

**Ranking: A > C > B.** Recommend **A**, with `SafeB` concretized as an
inductive least-fixpoint reach closure (a separate brick), and the two hard
SafeB sub-families discharged from that definition.

---

## 5. Mechanical-work estimate (per row) + the loud flag

Three tiers.

**CHEAP — pure `genv_vars_inj` / `find_symbol_exists` corollaries** (given a
Slice-0 symbol-block kit): `Hbc_bm`; `Hbc_sym`; and the **≠bm / ≠bc conjuncts**
of `Hgms_blk`, `Hgtimer_blk`, `Htable_blk`, `Hglob_blk`, `Hktab_blk` (the latter
two are `forall`-over-a-censused-list — finite, one `genv_vars_inj` per id via
`mem_id … = true` enumeration). Est: small, deterministic.

**MEDIUM — init anchor + monotonicity**: bm/bc **validity** and **`Hglob_valid`**
from `find_symbol_not_fresh`. **Flag:** `Hglob_valid` as literally stated
(`∀ m, MWF m → …`) is **stronger than `MWF_real` R0** (`MWFReal.v:195-206`, which
carries validity only for the *specific* symbols it reads, not *all* symbols).
It is therefore **not dischargeable from `MWF_real` alone** — it needs an init
anchor + a run-monotone `nextblock`. Recommended fix: add one clause to R0,
`Ple (Genv.genv_next (lp_ge lp)) (Mem.nextblock m)` (true at init by
`init_mem_genv_next`; preserved because every step only grows `nextblock`), then
`Hglob_valid` = `genv_symb_range` + that clause. This is a **small MWF_real
strengthening**, not a phantom — say so explicitly rather than pretending R0
already gives it.

**HARD — SafeB concretization (the genuinely-novel part, roadmap P5)**: the
`~SafeB` conjuncts of the five distinctness rows, `HSafeB_not_bm`,
`HSafeB_not_bc`, and the positive `Hsfam_safe`. These are **not corollaries of
Genv metatheory**. They require:
1. A concrete `SafeB := SafeB_reach lp bm` as a least-fixpoint reach closure
   (base = pointer targets in Mario's chase-root cells; step = R7 load-closure),
   provably satisfying R7 by construction and `HSafeB_not_bm` (closure excludes
   the root `bm`).
2. An **over-approximation invariant** — e.g. `SafeB ⊆ the object/graphics
   region`, disjoint from the control/timer/handler/knockback statics. Every
   `~SafeB gGlobalTimer` / `~SafeB sInteractionHandlers` / `~SafeB (stored_globals)`
   / `~SafeB (ktab)` / `~SafeB bc` reduces to "that static is outside the
   region"; `Hsfam_safe` reduces to "`sFloorAlignMatrix` IS credited to the
   region" via the `align_with_floor` `throwMatrix = &sFloorAlignMatrix[i]`
   store edge (`MovingLeafSurface.v` consumer).

**Loud flag:** if that region-invariant cannot be established, `HSafeB_not_bc`
and the `~SafeB(timer/table/ktab/glob)` conjuncts are **not provable** and P5
must strengthen (carry a region tag on SafeB). This is the one genuinely-novel
remaining GOAL-1 design problem (`docs/director-roadmap-2026-07-01.md:170`).
Do **not** attempt to discharge them from `spawn_ok` alone — that would be
laundering. P5's *tractable* ~70% is Slices 0-3 (init grounding proper); the
SafeB content is Slices 4-5 and is the hard research brick.

---

## 6. Recommended spawn-condition shape + ordered slice plan

**Recommended shape:** Candidate A —
`spawn_ok lp init bm bc oc0 := init_mem lp = Some init ∧ find_symbol _gMarioStates
= Some bm ∧ find_symbol _gControllers = Some bc ∧ oc0 = Ptrofs.zero`. It is
faithful to the linked AST (bm/bc are the `gMarioStates`/`gControllers` symbol
blocks, forced by R5 + `Init_addrof`), makes every distinctness row a
`genv_vars_inj` corollary, grounds R5 at init from `Init_addrof`, and is
non-vacuous via the concrete `init_mem lp` witness.

**Ordered slices** (each ELIMINATES capstone assumptions = real tethering):

0. **Symbol-block kit** — prove `find_symbol (lp_ge lp) id = Some _` and pairwise
   ident-distinctness for `_gMarioStates`, `_gControllers`, `_gGlobalTimer`,
   `_sInteractionHandlers`, `_sFloorAlignMatrix`, and each `stored_globals` /
   `knockback_table_ids` member. Reusable everywhere. (`find_symbol_exists`,
   `Pos.eqb` decidability.)
1. **Cheap injectivity rows** — `Hbc_bm`, `Hbc_sym`, and all ≠bm/≠bc conjuncts,
   from Slice 0 + `genv_vars_inj`.
2. **Init anchor** — define `spawn_ok`; prove `∃ init bm bc oc0, spawn_ok …`
   (non-vacuity, via `linked12_inhabited` + `init_mem lp`); derive R5-at-init
   (`Init_addrof` + `init_mem_characterization_gen`), bm/bc validity, and
   `Hglob_valid` **after** adding the `Ple genv_next (nextblock m)` clause to
   `MWF_real` R0 and proving it run-monotone.
3. **SafeB definition** — `SafeB_reach lp bm` least fixpoint; prove R7-closure
   and `HSafeB_not_bm`.
4. **SafeB vs static globals (HARD)** — the region-disjointness invariant;
   discharge the `~SafeB` conjuncts + `HSafeB_not_bc`.
5. **SafeB positive (HARD)** — `Hsfam_safe` from the `throwMatrix` store edge.

Slices 0-2 are the tractable, high-confidence init-grounding win (bulk of the 11
rows' *layout* content). Slices 3-5 are the SafeB reach-closure research brick —
flag them as such, do not round up.
