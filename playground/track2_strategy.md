# Track 2 strategy (everything except the objects invariant) — 2026-11-14

Branch `worktree-agent-a04ffd875c6d5e21f`, from master 2d4f1528.

## What I chose, in order

**M1 — entry coverage: widen `StartCarry`.**  Cheapest real gain.
`goal2_start_carried` today covers Mario bytes [4,8), [168,178), [184,186)
and three globals.  The census (docs/wmotr-entry-census.md §4d) lists
carried Mario fields and globals not yet covered.  Plan: extend
`carried_cell` / `carried_gids` to every cell the start invariant provably
does not read, each by the existing reflective check (`carried_gids_ok`,
vm_compute), and treat `m->input` separately (the invariant needs only
`input & 0x882 = 0`).  No new premise; the start theorem quantifies over
more real entry states.

**M2 — Mario row: `mario_handle_special_floors` out of `na_open`.**
The body is small.  In WMotR only floor type 10 does anything:
`check_death_barrier` -> `level_trigger_warp(m, 19)` (+ optional
`play_sound`).  `LtwFrame.v` already has the callee contract (`ltw_frame`,
`ltw_cells`, `ltw_warp_w`).  Three obstacles, all local lemmas, none a
premise:

1. `level_trigger_warp` stores `invincTimer` (Mario bytes [38,40)), outside
   the `hz` hole [4,8) ∪ [174,184) that `HoleX.hx_fworld` allows.  Needs a
   hole lemma that also allows [38,40), or a two-step argument.
2. `sDelayedWarpOp` / `sSourceWarpNodeId` are in `lvl_ids` ⊂
   `HoleX.safe_ids`.  `lvl_w` must be rebuilt by hand: `warp_w` from
   `ltw_warp_w`, the rest by accessors + `lvl_w_mk`.
3. `gSequencePlayers` (fadeout path) is in `aud_ls_ids`; need `aud_w`
   after the call.

Removes one of the seven open Mario rows.  Medium-large; done after M1.

**M3+ — by value per effort, decided after M2:**
- phantom-∀ sweep of the non-object premises (log FOUND; REPAIR/RESTATE
  only without a new premise);
- `update_mario_inputs` row (straight-line, reads controller + camera);
- S7 anim-buffer apartness at byte-range instead of block granularity.

## Parked, and why

- Dispatcher rows (`mario_execute_*_action`): need ground-step / per-action
  infrastructure; not a small milestone.
- Castle residue vs R7: probably changes what the start premise says ->
  user decision; I will write down exactly what is needed, not do it.
- `la` keep / `SafeB_syms_ok`: user is deciding; untouched.
- Camera rows (`Hcam_phi`, `Hcam_ow_res`): stay labeled premises unless a
  cheap discharge shows up.
- Objects rows: other worker's track.

## Method

Prefer computed checks (vm_compute over id lists, the walker, symbolic
execution) over hand proofs; prefer one lemma that removes a class of
side conditions.  Every fact from `generated/`.  Each milestone: full
build, audit, unwired check, SKILL + TRUST + finish-line entry, commit.

## Round 2026-11-24

- M2 done: `NaSplit.sf_row` (special floors out of `na_open`, 6 left).
  The three obstacles were solved in `HoleX` (hole may name the two warp
  cells, excludes bytes 38..39) and `LtwAudio`.
- Next: the NULL-floor FOUND.  Plan: weaken the floor clause of
  `wmotr_world` from `surface_nonnull_ok` to surface-or-NULL; readers that
  need a real floor take it from `fresh` (`floor_nn`); `SfRow.sf_shape`
  gets a NULL branch (the body returns at once on a NULL floor).  Probe
  first: change the definition, check the consumers one file at a time,
  count failures.  If an object-owner file (ObjWorld) breaks, stop and
  report instead.  If three rounds fail the same way, restate the open
  umi row instead (its post becomes `floor_null \/ fresh`, as for `is_fk`).
- After that: `m->input` entry premise, then `update_mario_inputs`.
