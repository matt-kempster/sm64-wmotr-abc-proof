# P5 slices 3–5 — SafeB concretization: design scout

Read-only design memo for task #92 (slices 3–5). **No `.v` was edited.** Answers
the fulcrum question the slice-3-5 brief opens with (`docs/p5-init-grounding-design.md`
Director's addendum, 2026-07-09): *where do the object-system blocks `SafeB` denotes
actually live, relative to the twelve linked TUs?* — then ranks the two candidate
`SafeB` shapes, gives the recommended Coq shape, the row-by-row proved-vs-assumed
table, non-vacuity, the `MWF_real`-type-impact answer, and the ordered slice plan.

Discipline note (`.claude/skills/proof-discipline/SKILL.md`): the recommendation
**decomposes, never launders** — it does *not* discharge the `~SafeB` rows from
`Genv` metatheory (they *cannot* be, see §1, the pool is unlinked), it **consolidates**
eight scattered capstone assumptions into one sharper honest-boundary row from which
seven are then *derived*. The one genuinely-not-dischargeable tension (§5) is flagged
loudly, not papered over.

---

## THE FULCRUM ANSWER (decisive, with evidence)

**The object-system blocks `SafeB` is meant to denote do NOT live in the twelve
linked TUs.** They are produced by an **external return / runtime allocation
OUTSIDE the link**. The *only* object-system-relevant block that is a static
symbol in the twelve TUs is `sFloorAlignMatrix`.

Evidence (grepped over the twelve TUs = `mario.prog` + `tu_rest`,
`proofs/MarioModel/LinkedTwelve.v:77–89`):

| object-pool symbol | status in the twelve TUs | evidence |
|---|---|---|
| `gObjectPool` | **ABSENT** (not in any `generated/*.v` at all) | `grep -rln gObjectPool generated/*.v` → empty |
| `gObjectLists` | **ABSENT** | same |
| `gMarioObject` | present as `Gvar`, but `tptr (Tstruct _Object)` with **`gvar_init := nil`** — a NULL `Object*` cell, *not* the Object data | `generated/mario.v:847–852`; `generated/behavior_actions.v:3104–3109` |
| `gCurrentObject` | present as `Gvar`, `tptr (Tstruct _Object)`, **`gvar_init := nil`** | `generated/mario_actions_cutscene.v:1007–1012`; `generated/behavior_actions.v:3111–3116` |
| `spawn_object` | **`Gfun(External (EF_external "spawn_object" …))`** — genuinely external, a model boundary | `generated/behavior_actions.v:111745–111746` |
| `sFloorAlignMatrix` | **DEFINED static `Gvar`** in `mario_actions_moving.prog` (member #2), `tarray (tarray (tarray tfloat 4) 4) 2`, `gvar_init = Init_space 128` | `generated/mario_actions_moving.v:754–759`, `:13749` |

So the pointees of Mario's chase-root cells (the *actual* `Object` structs) are
**not** `mario.prog`/`tu_rest` symbols: the pool is absent, and the two `Object*`
globals that *are* linked are null pointer cells whose pointees come from the
external `spawn_object` / runtime setup. `sFloorAlignMatrix` is the lone
static-symbol exception, and it is *required to be `SafeB`* (positive `Hsfam_safe`)
because `align_with_floor` plants `&sFloorAlignMatrix` into an object's
`gfx.throwMatrix` cell — a `SafeB` cell — so R7 load-closure forces it in.

**Immediate consequence.** Candidate **(A)** — "`SafeB` := the static symbol-block
set of the object-system globals" — is **impossible and unfaithful**: those globals
are not in the link. Choosing (A) would be inventing memory the program never
produces (the phantom trap the discipline warns against). The faithful shape is a
**boundary-rooted** `SafeB` (Candidate **B**).

---

## 1. What `SafeB` is REQUIRED to contain (from its consumers)

`SafeB : block -> Prop` is a **section `Variable`** in both
`proofs/MarioModel/MWFReal.v:148` and `proofs/NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v:59`,
with `MWF := MWF_real lp bm bc oc0 SafeB` (`NoAImpliesNoFlyTwelve.v:62`).

**Chase roots.** `chase_root_fields` (`CensusV2.v:275–278`) =
`_marioObj :: _marioBodyState :: _statusForCamera :: _heldObj :: _usedObj ::
_riddenObj :: _animList :: _interactObj :: nil` — **fields of the `MarioState`
struct at `bm`**. R6 (`MWFReal.v:229–237`) requires: a pointer loaded from
`bm + field_offset(fld)` is `SafeB`. The pointer is *produced* by the game storing
`spawn_object`/`gMarioObject`-graph pointers into those cells at runtime — none is a
`mario.prog` symbol (§ fulcrum).

**Load-closure.** R7 (`MWFReal.v:238–242`) = `SafeB b -> loadv b = Vptr b' _ -> SafeB b'`.
Consumed as `HchaseStep` (`EngineV2Consumer.v:152–154`, `CensusV2.v:1420–1423`).

**`sFloorAlignMatrix`.** `Hsfam_safe` (`NoAImpliesNoFlyTwelve.v:90–91`): positive —
`find_symbol _sFloorAlignMatrix = Some gb -> SafeB gb`. Producer = the
`align_with_floor` `throwMatrix = &sFloorAlignMatrix` store edge
(`MovingLeafSurface.v` consumer). This is the ONE static symbol `SafeB` must contain.

**Boundary producers already assumed at the capstone** (the honest-boundary
`SafeB`-return rows — Candidate B's grounding, *already trusted today*):
- `Hcp_spawn_real` (`NoAImpliesNoFlyTwelve.v:173–174`) =
  `call_pres_ext_sr … behavior_actions._spawn_object`
  (`WindSurface.v:45–54`): the **return** of external `spawn_object`, if a pointer,
  is `SafeB`. This is the root of the whole `SafeB` set.
- `Hglob_obj_root` (`NoAImpliesNoFlyTwelve.v:132–137`): each cutscene global object
  root in `gobj_ids` (`CutsceneLeafSurface.v:602` = `_sIntroWarpPipeObj ::
  _sEndPeachObj :: _sEndRightToadObj :: _sEndLeftToadObj :: …`, all null `Object*`
  statics like `gCurrentObject`), if a pointer, points into `SafeB`.

**Negative rows** `SafeB` must satisfy (`NoAImpliesNoFlyTwelve.v:70–88`):
`HSafeB_not_bm`, `HSafeB_not_bc`, and the `~SafeB` conjunct of each of
`Hgms_blk`, `Hglob_blk`, `Hgtimer_blk`, `Htable_blk`, `Hktab_blk`.

---

## 2. Where each root pointer's pointee lives (a/b/c classification)

For each `SafeB` root, is its pointee (a) a defined static `Gvar` in the twelve
TUs, (b) an external return, or (c) a walked-body writer?

| root | pointee origin | class |
|---|---|---|
| `bm->marioObj` / `heldObj` / `usedObj` / `riddenObj` / `interactObj` | `spawn_object` (EF_external) return; pool `gObjectPool` **absent** from link | **(b) external** |
| `bm->marioBodyState` | `&gMarioState->marioBodyState`-style embedded / runtime — not a linked pool symbol | **(b)/(c)** |
| `bm->statusForCamera`, `bm->animList` | runtime graphics/anim structs, pool absent | **(b)** |
| cutscene `gobj_ids` roots (`sEndPeachObj`, …) | linked as **null `Object*`** statics; pointee = spawned object | **(b) external** |
| `sFloorAlignMatrix` | **defined static `Gvar`** in `mario_actions_moving.prog` | **(a) static — the lone exception** |

So: **every genuine object block is class (b)** (external / runtime, `≥ genv_next`,
never a `mario.prog` symbol), and **exactly one** `SafeB` member is class (a) — the
`sFloorAlignMatrix` symbol. This is the shape the definition must encode.

---

## 3. THE DECISION — rank & recommend

**Ranking: B ≫ A (A is impossible).** Candidate A cannot be built (§fulcrum).
Within B there are two realizations; the recommendation is **B-consolidated**
(abstract `SafeB` pinned by one boundary characterization), *not* a self-contained
`Inductive` closure — because a concrete closure buys `HchaseStep`-as-definitional
but leaves the genuinely-hard content (that **no symbol other than `sFloorAlignMatrix`
enters an object cell**) needing a whole-program store census we cannot do in these
slices; making it "provable-looking" without that census would be a phantom.

### Recommended shape — `SafeB` abstract + ONE consolidated boundary row

Replace the **eight** scattered negative/positive `SafeB` rows
(`HSafeB_not_bm`, `HSafeB_not_bc`, the five `~SafeB` conjuncts, `Hsfam_safe`) with a
single **symbol-intersection characterization**:

```coq
(* Honest model-boundary fact: among LINKED symbol blocks, the object-system
   pointer graph credits exactly ONE — sFloorAlignMatrix.  Every other SafeB
   member is a runtime/external (spawn_object) block, never a mario.prog symbol. *)
Hypothesis HSafeB_sym_iff :
  forall id b,
    Genv.find_symbol (lp_ge lp) id = Some b ->
    (SafeB b <-> id = mario_actions_moving._sFloorAlignMatrix).
```

Non-vacuity witness (exhibited, not assumed) — the concrete `SafeB` the game realizes:

```coq
(* objblks = the boundary-returned object graph; all runtime blocks, hence
   >= genv_next (Genv.genv_symb_range gives every symbol < genv_next). *)
Definition SafeB_wit (lp : Clight.program) (objblks : block -> Prop) : block -> Prop :=
  fun b => objblks b
        \/ Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix = Some b.
(* side condition: forall b, objblks b -> Plt (Genv.genv_next (lp_ge lp)) b. *)
```

`SafeB_wit` satisfies `HSafeB_sym_iff`: an `objblks` block is `≥ genv_next` so is
never `find_symbol id` (which is `< genv_next` by `genv_symb_range`,
`Globalenvs.v:153`); the only symbol in the set is `sFloorAlignMatrix`.

### Rows PROVED vs stay-assumed under the recommendation

| Row | disposition | how |
|---|---|---|
| `HSafeB_not_bm` | **PROVED** | `bm = gMarioStates` symbol (p5 §0) ≠ `sFloorAlignMatrix` ident ⇒ `~SafeB bm` by `HSafeB_sym_iff` (`Pos.eqb` decid.) |
| `HSafeB_not_bc` | **PROVED** | `bc = gControllers` symbol (`mario.v:791`) ≠ `sFloorAlignMatrix` ⇒ `~SafeB bc` |
| `~SafeB` of `Hgms_blk`,`Hglob_blk`,`Hgtimer_blk`,`Htable_blk`,`Hktab_blk` | **PROVED** | each named static ident ≠ `_sFloorAlignMatrix` ⇒ `~SafeB` (finite `mem_id` enumeration for the two list-quantified rows) |
| `Hsfam_safe` | **PROVED** | forward direction of `HSafeB_sym_iff` at `id = _sFloorAlignMatrix` |
| `HSafeB_sym_iff` | **honest-boundary ASSUMPTION (the 1 replacing 8)** | model boundary: object pool is UNLINKED (`gObjectPool`/`gObjectLists` absent; `spawn_object` EF_external). Same trust class as `Hcp_spawn_real` |
| `Hcp_spawn_real`, `Hglob_obj_root` | **stay honest-boundary** (unchanged trust) | positive `SafeB`-production at the external/global-root boundary; already assumed today |
| R6 `HchaseRoot`, R7 `HchaseStep` | **stay `MWF_real` invariant clauses** (NOT separate capstone assumptions) | carried & *preserved* by the frame; with concrete `SafeB_wit` they assert a sharp true property ("object pointers/graph are runtime blocks or `sFloorAlignMatrix`"), but their preservation is the ongoing frame work, not this slice |

Net capstone `SafeB`-negative/positive surface: **8 → 1**, and the surviving 1 is
strictly sharper (a single characterization) and manifestly a boundary fact.

**Why this is refinement, not laundering (discipline Step-3 a–d):** (a) about real
program objects — named `generated/` symbols and the real `genv`; (b) strictly more
precise than eight opaque rows; (c) discharges seven of them via `genv_vars_inj`
(`Globalenvs.v:155`) + `genv_symb_range`; (d) net tethering increase *on the spine*
(the capstone consumes all eight). It is **not** the conclusion restated — it says
nothing about flying; it is a memory-layout boundary fact.

---

## 4. Does concretizing `SafeB` change `MWF_real`'s TYPE?  (design constraint)

**No.** `SafeB` is a section `Variable` (`MWFReal.v:148`), so `MWF_real` already
takes it as an explicit trailing argument (`MWF_real lp bm bc oc0 SafeB`,
`NoAImpliesNoFlyTwelve.v:62`); its *type* already abstracts over `SafeB : block -> Prop`.
All ~15 `MWFReal` lemmas (`mwf_real_valid`, `mwf_real_chase_root`,
`mwf_real_act_store`, …, `MWFReal.v:287–1562`) are generalized over the section
`Variable`, so they hold for **any** instantiation, including a concrete one.
**The swap breaks no `MWFReal` lemma and re-proves none.** Staging: instantiate the
capstone's section `Variable SafeB` with `SafeB_wit` (or keep it abstract and add
`HSafeB_sym_iff`), then derive the seven rows. The *only* file that changes is the
capstone — a localized edit swapping eight `Hypothesis`es for one plus seven
`Lemma` derivations. (`SafeB` also flows unchanged through the surface files
`BullySurface.v`, `PerformWaterStepSurface.v`, etc., all section-generalized.)

---

## 5. LOUD FLAG — the one row-family NOT dischargeable (genuine strengthening)

**A single memory-free `SafeB` cannot satisfy R0-validity AND R6 across a run that
allocates new reachable object blocks.** R0 (`MWFReal.v:198`) carries
`forall b, SafeB b -> Mem.valid_block m b` as a clause of `MWF_real m` — for *every*
`m` in the run, including the starting `init`. So `SafeB ⊆ valid_block init`. But
R6 requires `SafeB` to contain *every* object block Mario's chase cells will *ever*
hold. If the analyzed frame loop ever `spawn_object`s a NEW block that reaches a
Mario chase cell (and `Hcp_spawn_real`'s `SafeB`-return row exists precisely because
the design anticipates spawns), that block is not `valid_block init` — so **no fixed
`SafeB` satisfies both**. `Hcp_spawn_real` returning `SafeB` is only consistent if
`SafeB` *pre-contains* every spawnable block, which then breaks R0 at `init`.

This is a **real strengthening**, not a phantom to prove away. Resolutions:

- **(a) RECOMMENDED — ground `SafeB`'s `init` in the post-setup memory, and argue
  the mario-action frame loop makes no new Mario-reachable allocation.** Then
  `SafeB` = the *already-allocated* object graph, `valid_block init`, closed under
  the loop's stores (no new blocks). This is plausibly what the theorem's `no_spawn`
  name already intends and needs its own small lemma (Mario actions don't spawn
  Mario's own reachable objects). **Do NOT conflate this with p5 Candidate A's
  `spawn_ok`/`init = init_mem lp` anchor:** at `init_mem lp` all chase cells are
  `Init_space` zero (§fulcrum), so `SafeB`'s object content is *provably empty*
  there — that anchor grounds the **layout** rows (`bm`/`bc` symbol blocks) only,
  **not** `SafeB` inhabitation, which is grounded by `Hcp_spawn_real` + R6/R7
  preservation over the abstract post-setup `init`.
- **(b) REJECT — memory-index `SafeB` (`SafeB : mem -> block -> Prop`).** Changes
  `MWF_real`'s type, breaks all ~15 `MWFReal` lemmas, and is the exact caution the
  addendum raises. Also reintroduces the `Hsfam_safe` circularity (`sFloorAlignMatrix`
  only enters *after* the `throwMatrix` store, but the store needs it already `SafeB`
  to preserve R7).

Recommend (a). Flag: **R6/R7 preservation and the no-in-loop-Mario-spawn obligation
are NOT discharged by slices 3–5** — they are the honest residual the SafeB
concretization exposes, not eliminates. Do not round up.

---

## 6. Recommended shape + ordered slice plan (folding #94 + R0 strengthening)

**Recommended `SafeB` shape:** abstract `Variable SafeB`, pinned by the single
honest-boundary `HSafeB_sym_iff` (symbol-intersection = `{sFloorAlignMatrix}`), with
`SafeB_wit lp objblks` as the exhibited non-vacuity witness (`objblks ⊆ {b | Plt
genv_next b}`). Boundary-rooted (Candidate B), consolidated — **not** a self-contained
`Inductive` closure (that needs a whole-program store census we can't do here).

**Ordered slices 3–5:**

3. **SafeB boundary spec + consolidation.** Add `HSafeB_sym_iff`; exhibit
   `SafeB_wit` non-vacuity certificate (`objblks` fresh ⇒ satisfies the iff); derive
   the seven rows (`HSafeB_not_bm/bc`, five `~SafeB` conjuncts, `Hsfam_safe`) from it
   via the slice-0 symbol kit + `genv_vars_inj`/`genv_symb_range`. Net capstone
   SafeB surface **8 → 1**. Reuses the slice-0/1 `≠bm/≠bc` genv work.

4. **R0 strengthening ride-along (pay the `MWFReal` ripple once).** Add the
   `Ple (Genv.genv_next (lp_ge lp)) (Mem.nextblock m)` clause to `MWF_real` R0
   (p5 §5), prove run-monotone, discharge `Hglob_valid`. **Fold in #94 option-B
   (R11-at-spawn):** ground `Hcp_spawn_real`'s consumption against `spawn_ok` +
   the `spawn_object_abs_with_rot` `SafeB`-return in the SAME MWFReal-touching commit
   (single ripple for both the R0 clause and the spawn grounding, per addendum).

5. **The honest boundary (flag, don't claim discharge).** Document R6/R7 as carried,
   concretized-by-`SafeB_wit` invariants; state the fixed-`SafeB`-vs-new-allocation
   strengthening (§5) and the no-in-loop-Mario-spawn obligation as the remaining
   honest residual. **Do not** report R6/R7 as discharged.

**Bottom line.** Fulcrum: object blocks are external/runtime, **outside** the twelve
TUs (pool absent, `gMarioObject`/`gCurrentObject` null, `spawn_object` EF_external);
only `sFloorAlignMatrix` is a linked static `SafeB` member. So `SafeB` must be
boundary-rooted (B), best realized as **abstract + one `HSafeB_sym_iff` boundary
row** that *proves* seven of today's eight capstone `SafeB` rows and leaves one
sharp honest-boundary assumption — a real 8→1 tethering refinement — with the
fixed-`SafeB`/new-allocation joint-satisfiability flagged as the genuine
strengthening slices 3–5 expose but do not close.
