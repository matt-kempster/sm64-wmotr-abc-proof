---
name: proof-discipline
description: Checklist for proof work in this repo. Use before committing Rocq/Coq changes, and before adding a Definition/Lemma/Hypothesis to the spine. Progress means the capstone says more about the REAL SM64 program; a green build, axiom-cleanliness or a new disconnected lemma is not progress. Covers the audit script, the tethering test, phantom-forall rows, and statement fidelity.
---

# Proof discipline

## The one question

> Is the capstone now closer to a **true** statement about the **real** SM64
> program than it was before?

Green builds, axiom-cleanliness and new true lemmas are the floor. They are not the
goal. The failure this skill exists for is a session of clean, `Qed`'d work that is
disconnected from the real theorem: lemmas about placeholders, or a definition that
doesn't mean what its name says. This happened here once: four green, axiom-clean commits,
all in `Unwired/`, and the theorem moved nowhere. See
[*Did you prove what you think you proved?*](https://leanprover-community.github.io/did_you_prove_it.html).

## Where the bottom line is (keep this current)

- **GOAL 1** (no-A ⇒ no-fly): `NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v`,
  `noA_no_spawn_never_flying_linked12`. The step is one real `execute_mario_action` over
  any link of the 14 TUs (the 12 Mario TUs + `surface_collision` + `math_util`, since
  2026-10-17). The open surface is its `Hypothesis` rows (23 as of 2026-10-17,
  external-call and boundary rows; see `docs/TRUST.md` §4). The collision rows
  (`SurfaceBodies.v`) and the math_util rows (`MathBodies.v`) are lemmas, and so is
  `Hscp_mtxf_real` since 2026-10-21 (`MtxfBody.v`). Because `vec3f_normalize` reloads its
  `dest` after `sqrtf`, the capstone takes the FPU floor `Hsq : sqrtf_spec` (TRUST 3.5) in its place.
  The two animation rows `Hgeo_real` / `Hocp_rai_real` are lemmas since 2026-10-20
  (`GraphNodeBodies.v`; `graph_node.c` is the 19th TU): their real bodies store only through a
  pointer parameter that the gate pins NULL / puts in a caller stack local.
  `Hcp_savefile_real` is a lemma since 2026-10-21 (`SaveFileBody.v`; `save_file.c` and
  `buffers.c` are TUs 20 and 21): every store lands in `gSaveBuffer` / `gSaveFileModified`,
  both stored globals (TRUST 4.1).
  The three arg0-gated object-helper rows `Hcsp_omfd_real` / `Hcsp_scale_real` /
  `Hcsp_osh_real` are lemmas since 2026-10-21 (`ObjHelpersBodies.v`; `object_helpers.c` is
  the 22nd TU): every store goes through the SafeB `obj`, and the two pointer stores hold
  `gCurrentObject`'s (SafeB) value or `segmented_to_virtual`'s (integer) result.
- **GOAL 2** (WMotR needs A): `WMotRRequiresA/HeightFrame.v`,
  `wmotr_noA_height_bound_linked12`. This is a conditional theorem over ONE WMotR
  visit (frames end with `in_wmotr`), under input with A neither pressed nor held
  (`a_used_real`). Φ is concrete
  (`HeightInvariant.v`), `Hphi_y` is proved (YMAX = 2796), the level-data rows are proved (`WMotRLevel.v`), and the crux is the lemma
  `seg_action_phi`, whose move arithmetic is proved (`HeightMoveCatalog.chain_keeps_budget`).
  Its start premise is proved satisfiable (`StartSat.goal2_start_sat`, 2026-10-20, in the audit):
  a memory built from the real boot image of any 19-TU link meets `mem_ok_lp` and `PhiW`. That
  rules out empty-premise vacuity only; Φ at real WMotR entry stays ASSUMED (TRUST 0.4).
  Since 2026-10-20 the three frame rows below are LEMMAS of the frame split (since 2026-10-21
  the STAGED `FrameSplit.frame_stage`, which threads the dispatch's floor refresh
  `FfWorld.fresh` / `fresh_at` through the body in order and over the real dispatch loop); the
  assumed rows are the per-call `Hseg_call_na` (`seg_call_rows_naF`, with `pre_of` / `post_of`:
  update_mario_inputs leaves the floor fresh, handle_special_floors / process_interactions keep
  it, each dispatcher returns 0 or leaves fresh_at) / `Hseg_any` (one per call in the real
  `execute_mario_action` body; the two store blocks are proved). What each per-call row
  carries:
  - `Hframe_stays_noA` (ACT_SQUISHED still needs the dynamic-surface geometry fact in the
    find_floor / find_ceil contracts, docs/goal2-value-walk-plan.md §6)
  - `Hframe_keeps_world`: the run carries `PhiW` = Φ ∧ `WMotRWorld.wmotr_world` (surfaces of
    WMotR's types, nothing held or ridden, no quicksand; collided objects of WMotR's kinds,
    with pole and cannon fields from the level lists, no star, and no stomp bit). Without W the other rows are false
    over phantom worlds; grow W, don't drop it
  - `Hframe_is_move_chain`, the value walk. It is false if an unmodelled move fires, so check the
    `Step` constructors against any new y/vel writer. The airborne dispatcher is split per case
    (`AirSplit`), and the **freefall case is proved** (`FfRow.ff_row`: the real `act_freefall`
    walked by `FfRun` keeps fworld and moves the cells by a MoveChain), started from the carried
    `FfWorld.ffw` (in PhiW / fworld). The **air-hit-wall case is proved** too (`AhwRow.ahw_row`,
    walked by `AhwRun`; the A-gated wall kick is pruned), and so are soft bonk and both air
    knockbacks (`KbRow.kb_row`, generic in the walk theorem `KbRun.kfinal`; walks in `KbRun`),
    and ground pound (`GpRun.gp_kfinal`: windup via `FfClass.gpw_ok`, fall via `ff_ok`), and
    dive (`KbDv`, an air_entry), and both rollouts (`RlF` / `RlB` through `RlRun.rl_kfinal`;
    the air-step summary's entry is the caller's cell terms at the call, `AirSum.icE`).
    and butt-slide air at state 0 (`BsW` through `BsRun.bs_kfinal`: S_tick, then the step from
    the ticked cells `FfClass.ent_bs`; the bounce is an S_attach), and slide kick at state 0
    (`SkW` through `SkRun.sk_kfinal`: the step from the ticked cells is one move from the
    pre-tick cells, `AirMove.sk_pre`; gravity 2 via `AirMatch.gk_of`). Every no-A case is
    covered (`KbRow.air_case_rows_ff8`, `air_case_fns_in`). Butt-slide air is proved at ANY
    state (2026-10-21: the entry floor is the dispatch's fresh floor, `kb_row` takes
    `FfWorld.fresh`; every walk also checks `RetOk.ret_ok`: FALSE or y/floorHeight untouched).
    Open: slide kick at state <> 0 (`Hsk1` / `KbRow.sk1_row`, now fresh-in / fresh-or-FALSE-out;
    needs a state-1 classifier, `S_sk_bounced` relaxed). ffw's floor refresh still holds for
    `fro_st` (air_entry + ground pound + rollouts, and butt-slide air and slide kick at state 0;
    TRUST 0.6); the ff / ahw rows still read it. Phantom-∀ caveat (pre-existing): the
    open rows claim FRO after let_go_of_ledge -> SOFT_BONK, true in the game (find_floor's +78
    bound, y drops <= 100) but not derivable from fworld. Walk files: one walk each (KbSb/KbBkb/KbFkb/KbDv),
    `WithGe.with_ge` not `match ge12`, `vm_cast_no_check`, never `eassumption` near a walk. Dive and rollouts read `gAudioRandom`; audio/data.c (its only
    definer) is linked as the 18th TU so those paths have executions. Squish: WMotR's dynamic
    surfaces never come within 150 of a floor/ceiling (`tools/goal2_squish_scan.py`, min gap 276),
    so INPUT_SQUISHED can join the carried input mask when the dispatcher is walked.
  - (`wmotr_gap` and `wmotr_poles` are now proved from generated level data, `WMotRLevel.v`)
  - the flank specs (TRUST 0.7)

  The coin link is also open.
- `docs/TRUST.md` is the ledger of everything a reader must believe. Read
  `Print Assumptions` (`pipeline/assumptions.sh`) together with the Hypothesis rows:
  holes appear as axioms, but assumptions appear as rows.

## What counts as progress

1. **Eliminate a row.** Prove it for the real program.
2. **Refine a row** into sharper real pieces that can each be discharged, even if the
   count goes up. This counts only if the new rows:
   - are about real program objects (named functions, fields and offsets from
     `generated/`);
   - are strictly more precise than what they replaced;
   - have a credible discharge path;
   - are consumed on the spine.

   Decompose the gap; never collapse it. A row that restates the conclusion is laundering.
3. **Partial work aimed at 1 or 2, on the spine.** Half a closure on the spine beats a
   finished lemma in `Unwired/`.
4. **Finding that a row, number or design claim is false.** This is progress too, and
   often the most valuable kind. Examples: E3's Δ_pot, the VIRTUAL_TO_PHYSICAL UB frames,
   the flank ∀-rows.

`Unwired/` work isn't done until it is promoted: `git mv` it onto the spine and have a
spine file use it. Otherwise say plainly that nothing consumes it yet. CI's firewall
forbids the spine from importing `Unwired/`.

## We don't need `forall`: SM64 is one specific codebase

One program, one call graph, one set of externals. A row that quantifies over every
`le` / `fd` / `ef` / memory can admit states the game never produces. Then a true fact
becomes a false row. It happened repeatedly:

- `forall le m` in a per-`Sassign` check, where a temp was allowed to alias Mario's block
  although the program had just loaded it from `marioObj`;
- the GOAL-2 flank rows, "spec ⇒ MWF m ⇒ MWF m'" over every m' matching loose y/action
  clauses;
- "y ≤ YMAX is preserved by a frame": false, since upward velocity is unconstrained;
- the crux row with a Φ that lacks an action whitelist, which would range over mem_ok
  memories in A-gated actions.

The fix is always the same: reason about the actual execution, or enumerate the actual
finite set. If a row looks true but won't go through, first ask whether it ranges over
states the program never reaches. Also ask whether each premise is satisfiable: an
unsatisfiable oracle premise makes everything above it vacuous (the P1′ lesson).

## PIPELINE, not bespoke

Every fact about SM64 comes from the clightgen'd AST in `generated/`. Pin constants and
offsets there with `vm_compute` (e.g. `mario_pos_offset_concrete`), and never transcribe
them by hand. Numbers the proof depends on (budgets, level data) come from tools that read
the vendor source, such as `tools/goal2_ladder.py` and `tools/goal2_budget.py`, not from
prose. Check prose against code before building on it.

## The audit (the floor)

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

It runs the build, checks for holes, checks each capstone's axiom footprint, and runs the
firewall/orphan check. It also prints the residual surface. Run it before committing proof
changes. To audit a specific capstone:
`discipline_check.sh SM64.Proofs.<Path>.<Module> <theorem> ...`.
Always build via `pipeline/*.sh`, never bare `coqc`: a bare `coqc` can report a false green.

## Before claiming progress, answer

- **What got more real?** Name the placeholder that became a generated-AST object, or the
  row that was discharged or sharpened.
- **New assumption?** Is it a refinement or a laundering? Update `docs/TRUST.md` in the
  same commit.
- **Spine or island?**
- **Statement fidelity:** do `step`, `mem_ok`, `Phi` and `y_le` still mean what their
  names claim?
- **Non-vacuity:** are the rows jointly satisfiable? Does a positive control or real-game
  tether (`experiments/oracle`) exercise them?
