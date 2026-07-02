# State of the proof & the director's roadmap — 2026-07-01

*Written by Fable 5 in a director capacity: (1) where the proof actually stands,
(2) my professional opinion on what to do next and in what order, (3) how to
delegate the work across model tiers so expensive tokens go only to the hard
parts. Companion docs: `state-of-the-union-2026-06-21.html` (the last full
ledger), `goal2-general-height-invariant.md` (the GOAL-2 strategy),
`ROADMAP.md` (historical).*

---

## 1. Where the proof stands (audited today, tree at `6171877`)

**The theorem (GOAL 1, live):** `noA_no_spawn_never_flying_real_mwf`
(`proofs/NoAImpliesNoFly/NoAImpliesNoFlyLinked.v:2451`) — for a linked Clight
program `lp` containing the 12 clightgen'd SM64 TUs, any run from a
well-formed initial memory in which the A button is never pressed and no
frame spawns Mario airborne-flying never reaches a memory where Mario's
`action` field holds a flying action. The carried invariant `MWF_real` is
**concrete** (its 14 projection/stability obligations are proved, not
assumed), the reached-set is concrete (`reached_v2`), the input grounding
(`input_grounds_noA`) is proved, and the frame is the **real**
`eval_funcall` of `f_execute_mario_action` over the real generated AST.

**Audit (2026-07-01):** green on all four gates — builds, zero
admit/axiom/sorry, all four capstones rest only on standard CompCert axioms,
78 files with a clean Unwired firewall and no orphans.

**The honest scoreboard** is the capstone's section-hypothesis surface:
**56 hypotheses**, which classify into four buckets:

### A. Link-time structural pins (13) — *discharged by constructing `lp`*
`LO_mario` + 11 per-TU `linkorder` pins (`LO_sta/mov/air/sub/cut/aut/obj/int/
beh/lvl/stp`) + `Hrest_ext_only`. Facts about how the TUs compose; all vanish
the day we instantiate the section at a **concrete symbolically-linked
program** (`Generic/SymbolicLinking.v` proved the template).

### B. Runtime memory-layout facts (12) — *discharged from init + SafeB concretization*
`Hbc_bm, HSafeB_not_bm, HSafeB_not_bc, Hgms_blk, Hglob_blk, Hgtimer_blk,
Htable_blk, Hktab_blk, Hsfam_safe, Hbc_sym, Hglob_valid, WL_exempt*`.
Block-distinctness of Mario's runtime block / the controller block / static
globals, and validity of genv blocks. `bm` is a *runtime* block
(`gMarioState` has `gvar_init nil`), so these are genuinely facts about the
run's initialization, not about the AST. Discharge path: concretize `SafeB`
as the actual chase/reach closure and derive distinctness from
`Genv.init_mem` symbol-block injectivity + an explicit spawn condition.
(*`WL_exempt` is really a census fact — see D.*)

### C. Terminal-external model boundary (~28) — *split: ~2/3 killable by clightgen'ing 2 more TUs, ~1/3 the honest permanent trust boundary*
Two sub-classes, and the distinction is the biggest lever we have left:

- **C1 — external only because their TU was never clightgen'd (~16 rows):**
  the `vec3f_copy/vec3s_set/vec3f_set/approach_f32/approach_s32/atan2s/sqrtf`
  math rows (bodies live in `src/engine/math_util.c`) and the
  `find_floor/find_ceil/find_wall_collisions/f32_find_wall_collision/
  find_water_level` terrain-query rows (bodies live in
  `src/engine/surface_collision.c`). Every one of these is currently an
  *assumed gated spec* (`call_pres_ext_oc/wol/sc/w1/wl/...`); if we
  `clightgen` those two TUs and walk the real bodies with the existing
  walker kit, the gated specs become **proved lemmas** and the rows leave
  the trust surface entirely.
- **C2 — genuinely external (~12 rows):** audio (`play_sound`,
  `raise/lower_background_noise`, …), rendering/dialog
  (`create_dialog_inverted_box`, `trigger_cutscene_dialog`, time-stop),
  `spawn_object`/object-system, `save_file_*`, plus the two reached-external
  blanket rows `Hext_action`/`Hmwf_ext`. These drive hardware/OS/renderer
  state and are the **honest, documentable model boundary** — the right end
  state is a short trust-model section, not more proof.

### D. Engine-sharpening residuals (3) — *the remaining real proof work in GOAL 1's engine*
- `Hret_unsafe` (task **#50**, in progress): I32-returning reached functions
  that aren't vint-tracked — the 7 dispatchers whose status int flows
  through a `switch`. Needs a modest extension of the `fd_is_vint` tracker.
- `Hglob_obj_root`: pointer loads from the cutscene `gobj_ids` globals land
  in `SafeB` — the designed glob-obj mini-walker campaign
  (memory: *cutscene globobj campaign*) discharges it.
- `WL_exempt`: the exempt-callee whitelist resolves to `marg_exempt`
  fundefs — becomes computable once `lp` is concrete (fold into A/B).

**GOAL 2 (`WMotRRequiresA/`, not started in Coq):** strategy is now settled —
`goal2-general-height-invariant.md`: a one-frame inductive invariant `Φ`
(coupled conjunction: taint ∪ height ∪ velocity ∪ squishTimer ∪ level-data)
plus a launch-site dominator classification whose "danger class" (mid-air
relaunch without A/object) must be proved empty. The y-changer census and the
squish-cancel kill are done as prose; nothing is mechanized.

---

## 2. My professional opinion: the priority list

Two strategic observations drive the ordering.

**Observation 1 — GOAL 1 has a concrete, reachable "newsworthy finish."**
The remaining surface is no longer "walk 300 functions" (that grind is
*done* — every dispatcher, every leaf family, every internal helper is
walked). What's left is *structural*: instantiate the program, concretize the
memory layout, shrink the boundary. After P1–P3 below, the headline becomes:

> *For **the** linked SM64 Clight program (14 mechanically-translated TUs),
> every no-A run from a well-formed spawn never enters a flying action —
> modulo a documented, ~dozen-row trust boundary (audio/renderer/save/OS
> externals) and standard CompCert axioms.*

That is an announceable theorem. Nothing in P1–P3 is research-risky; it is
engineering with known templates.

**Observation 2 — GOAL 2's bottleneck is design, not grind.** The expensive
mistake would be to start mechanizing GOAL 2 before the invariant `Φ` and the
danger-class enumeration are *right on paper* — every phantom-`forall` and
false-lemma lesson from GOAL 1 says the statement design is where soundness
lives. That design work is exactly what should NOT be delegated.

### The ranked list

| # | Task | Bucket | Difficulty | Leverage | Who |
|---|------|--------|-----------|----------|-----|
| **P1** | **C1 boundary shrink:** clightgen `math_util.c` + `surface_collision.c`, add `LO_mat`/`LO_scol` pins, walk the ~12 small bodies, convert ~16 assumed gated rows into lemmas | C1 | Low–Med (templates exist; `find_floor`'s surface-list loop is the only nontrivial walk) | **Highest** — biggest single cut to the trust surface; also *feeds GOAL 2* (find_floor/find_ceil semantics are exactly what the height bound reads) | Delegate slices; Fable reviews gates |
| **P2** | **Finish #50 `Hret_unsafe`:** extend `fd_is_vint` to track the switch-shaped status temp in the 7 dispatchers | D | Med (syntactic-tracker extension; false-positive risk caught by Qed) | Med — deletes a standing engine row | Fable designs the tracker extension; delegate the 7 instantiations |
| **P3** | **Concretize `lp`:** symbolic link of all TUs via `SymbolicLinking.v`, instantiate the capstone section, discharge the 13 A-rows + `WL_exempt` + `Hbc_sym` by `vm_compute` | A | Med (perf is the known risk — never link concretely; the spike proved the symbolic route) | High — changes the theorem's *kind*: from "any lp such that…" to "THE program" | Fable owns (perf traps, section surgery); delegation unsafe |
| **P4** | **`Hglob_obj_root` glob-obj campaign** per the existing design memo | D | Med | Low–Med (one row) — do it opportunistically, it also cleans the cutscene story | Delegate (design exists) |
| **P5** | **SafeB concretization + init grounding:** define `SafeB` as the concrete reach closure, derive the B-rows from `Genv.init_mem` + spawn conditions | B | **High** (the one genuinely-novel remaining GOAL-1 design problem) | High — closes bucket B, makes `mem_ok` demonstrably satisfiable (kills any vacuity critique for good) | Fable only |
| **P6** | **GOAL 2 design track (parallel, Fable-time):** (a) danger-class enumeration over the real air-transition graph; (b) `Φ` constant-pinning; (c) level-data ingestion pipeline design (clightgen WMotR collision/macro → Coq constants); (d) the §2a integration-lemma statement over the already-walked `paqs`/`pgqs` | G2 | High (design) / Low (census sweeps) | The second theorem | Fable designs; Sonnet does C-source census sweeps; Opus mechanizes once statements are frozen |
| **P7** | **Trust-model doc for C2:** one page naming each surviving external row and why it can't touch `action`/the watched cells | C2 | Low | Presentation-critical for the announcement | Delegate, Fable edits |

**Sequencing:** P1 and P2 in parallel now (disjoint files). P3 after P1 (link
once, including the two new TUs — don't do section surgery twice). P4
opportunistic. P5 after P3 (concrete `lp` makes the B-rows computable). P6
runs continuously on director time. P7 last, as the announcement draft.

### What I would *not* do
- Don't start writing GOAL-2 Coq before the danger-class enumeration is
  complete on paper. A wrong `Φ` costs a re-walk of everything.
- Don't try to make C2 rows provable by modeling audio/renderer internals.
  That's scope creep with zero theorem value; the boundary is *honest*.
- Don't touch the v1/v2 legacy capstones; they're historical scaffolding.

---

## 3. The delegation playbook

**Principle:** Fable tokens are for *decisions, statements, and stuck-states*;
Opus tokens are for *deterministic recipes*; Sonnet tokens are for *reading
and tabulating*. The GOAL-1 walk machinery is mature enough that most
remaining work is recipe-shaped.

### Tier map

| Tier | Model | Use for | Never use for |
|------|-------|---------|---------------|
| Director | **Fable 5** | statement design, new engine arms/gates, phantom-false adjudication, section surgery (P3/P5), GOAL-2 `Φ`, un-sticking any proof stuck >2 attempts | grep sweeps, doc formatting, template walks |
| Workhorse | **Opus 4.8** | leaf/body walks from an existing template (probe first!), census construction, per-symbol instantiation grinds, discipline-check runs, commit hygiene | inventing new lemma *statements*, changing gates/specs, anything where the spec might be phantom-false |
| Scout | **Sonnet 5** | C-source census sweeps (e.g. "list every `vel[1]` write in these files with line numbers"), verifying prose claims against `vendor/sm64`, drafting doc sections, extracting id lists from generated `.v` | any `.v` edit on the spine |

### Standing subagent contract (paste into every delegated task)

1. Read `.claude/skills/proof-discipline/SKILL.md` first; the deliverable is
   a *tethering* delta, not a green build.
2. Build only via `pipeline/build.sh proofs`; never bare `coqc`
   (switch false-positive). Run
   `bash .claude/skills/proof-discipline/discipline_check.sh` before claiming done.
3. **Probe-walks-first:** before proving, state the walk/gate you expect and
   probe the body (`About`/`Print`/vm_compute the census) — if the gate
   doesn't fit, STOP and report; do not weaken the spec (that's how
   phantom-false rows happen).
4. Never edit `generated/`; never import `Unwired/` from spine files; new
   helper lemmas go next to their consumer, not in new orphan files.
5. If stuck twice on the same goal, stop and return the exact goal state +
   what was tried. Do not `admit`, do not restate the hypothesis to make it
   pass, do not add axioms (CI catches all three, so they only waste a cycle).
6. Report: what shrank on the capstone surface (hypothesis deleted/replaced),
   commit hash, and any NEW residual introduced (must be justified per the
   skill's refinement rules a–d).
7. Commit format per repo convention; push to master after committing.

### Known gotchas to hand every walker task
The memory files carry ~30 hard-won Ltac/CompCert gotchas. The ones that cost
the most when unknown: per-file `make X.vo` is a no-op (build `proofs`);
`destruct (prog_defmap TU) ! fid` in a heavy context hangs; `LO_*`
declare-LATE (early `eassumption` can hang hours); `inv` global-subst eats eq
hypotheses; plain `cbn` eats `Pos.eqb`; `Archi.ptr64` is opaque —
`cast_case_pointer` passes `Vptr` through `Tint I32`; exact-with-evar before
`eq_refl` fails (use `apply`). Point subagents at
`~/.claude/.../memory/MEMORY.md` topics when relevant.

---

## 4. GOAL 2 — the design agenda (director track)

The strategy is frozen (`goal2-general-height-invariant.md`). The open design
questions, in the order they must be answered:

1. **The action-cycle/danger-class enumeration (the crux).** Enumerate every
   transition in the airborne/hanging/submerged action graph that (re)sets
   `vel[1] > 0` or performs an unconditional `pos[1] +=`, and tag each with
   its dominator: *grounded / A-gated / absent-object / DANGER*. The census
   already covers the write **sites**; what's missing is the **entry-edge**
   analysis (which action can transition to which launch, from mid-air, under
   no-A). Deliverable: a table over the real `ACT_*` graph with a per-edge
   verdict, each verified against `vendor/sm64` line numbers. *Sonnet sweeps,
   Fable adjudicates every DANGER/unclear row.*
2. **`Φ`'s constants** (`C_pos/C_vel/C_fwd`): fixpoint-tune on paper against
   the census table (dive 20 / rollout 30 / GP windup +110 / wind, etc.).
3. **Level-data ingestion:** decide the mechanism (clightgen the WMotR
   `collision.inc.c`/`macro.inc.c` arrays as a data TU and `vm_compute` the
   needed constants out of the initializers — keeps PIPELINE-not-bespoke) and
   prototype it on one array.
4. **The §2a integration lemma statement** over the already-walked
   `perform_air_quarter_step`: "one air quarter-step increases `pos[1]` by at
   most `max(0, vel[1])/4`" — stated against the real body, consuming the
   existing paqs walk. This is the first GOAL-2 Coq artifact worth writing,
   and it doubles as the template for all numeric-bound walks.

---

## 5. Tonight's execution plan (2026-07-01, overnight)

1. ~~Audit + this document.~~ (done)
2. **P1 kickoff (Fable):** clightgen `math_util.c` + `surface_collision.c`,
   get them building in `generated/`, add the `LO_*` pins, and walk the
   first math body end-to-end myself to validate the recipe.
3. **P1 fan-out (Opus):** delegate remaining math_util bodies + the
   surface_collision walks as slices, one commit each.
4. **P2 (Fable design, then delegate):** scope the `fd_is_vint`
   switch-tracking extension for #50.
5. **P6a (Sonnet, parallel):** the air-transition-graph census sweep for the
   GOAL-2 danger class.
6. Iterate until the token limit: review, land, commit, push, update tasks
   and memory as each slice closes.
