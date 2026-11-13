# Objects rows: strategy (2026-11-13, resume after the 11-09 pause)

## What the problem really is

The objects rows (`Hobj_cou_t` / `Hobj_cou_nt`) are `forall m st, INV st m -> real step -> INV st' m'`.
A row is false exactly where INV is not inductive under the real code. So "the capstone is
vacuous" and "INV is not yet an inductive invariant of the real object code" are the same
statement. Restating over reachable states is not available cheaply: the rows speak about
mid-update memories and Clight big-step gives no intermediate-state relation to quantify
over (threading one through every proved keep would touch the whole spine). So the
invariant has to become inductive; the only question is how to find the missing pieces
fast instead of one multi-hour round per phantom.

## Chosen

1. **Finish the cannon trajectory WIP (e437b2a5 / e1784959), do not discard it.**
   It is the real inductive invariant for bhv_cannon_base_loop, read off the code
   (`ObjWorld.traj_b`: the (oAction, oPrevAction, oTimer, jitter, rise) tuples of
   sOpenedCannonActions, closed under the native, the timer step and Mario's act-2 store),
   GOAL 2 needs it anyway (Mario's y in the cannon is the base's y), and it already
   compiles through ObjAnchor. Remaining: ObjStep, the boot check (ow_chk carries
   can_traj_b; a failure there is a FOUND), docs.
2. **Census before any further repair.** No more "find one phantom, rebuild". One vm
   census on the spine enumerates native_res's exact finite case set (every CALL_NATIVE
   word at a special-script state + every non-bulk native at a generic state), so the
   remaining phantom candidates are named and counted once, and native_res can be asked
   per case instead of as one forall.
3. **Next rounds (not this milestone): table-driven slot classes.** The cannon work
   cost ~1900 lines over 17 files because a new obj_w clause touches every keeper. The
   shape that came out of it is reusable: a per-script clause keyed by the command offset
   class (`ccls` / `can_cl`), reading a fixed offset list (`traj_offs`), with one
   `_eq` lemma that keepers call. The remaining special scripts (red-coin counter /
   hidden star, cannon lid, exclamation box, jumping box) should go in as rows of ONE
   generic table (script, offset class -> boolean check over a listed cell set), so the
   keepers are proved once for the table and a new trajectory is a table row + a boot
   check + its native's transfer proof. The transfer proofs are the place for the
   symbolic executor (SymExec2 `sx_call_sound`) + a vm closure check.

## Rejected

- Rows over reachable states only: see above (needs a sub-execution relation).
- Discarding the WIP: it is the same loop shape, but it is ~95% done and it is true.
- A narrower objects -> Mario interface: the pins that cause phantoms (cannon pos, pole
  hitbox, box pos, red-coin count) are exactly the ones Mario's rows read.

## Build latency

Single-file `pipeline/check.sh` until the frontier is clean; ONE full build per
milestone (vo cache, flock /tmp/sm64-build.lock).
