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

## 2026-11-13 (second round): the sweep -- choice, written before executing

**Chosen: decide every case first, by computation where a computation can decide,
and only then spend proof lines.** The table-driven slot-class design is kept as the
repair shape, but it is NOT started this round: the sweep shows the open cases need
three different kinds of new invariant content (a per-slot field pin, a cross-slot
count, a coupling to Mario's phase), so one table of per-slot cell checks would not
close the window by itself.

1. One spine census (`proofs/WMotRRequiresA/NativeSweep.v`, vm) lists native_res's
   exact case set as (script, word, native) sites and splits it:
   - DEAD sites: the script is not in `ObjWorld.live_bhvs`. The row asks native_res
     at `Qs := ObjFamily.Qfam`, which contains `In (v_s st) live_bhvs`, so the row is
     true there with a false premise that no INV-state at such a site exists to
     contradict. Closed, no proof work (this is the jumping box).
   - LIVE sites: the real surface.
2. A computed detector for the SCRIPT clause: for each live residual native, the
   non-live behaviors in its reference closure (`BehaviorScripts.closure_of`, over
   the generated ASTs). Empty = no spawn out of that native can break script_ok.
   Non-empty = phantom candidate unless a guard is pinned.
3. For the pinned-field clauses (red_ok, box_pos_ok, the cannon pins) the verdict is
   by reading the native against the clause; each FOUND is logged with the falsifying
   INV-state. No repair is attempted unless it needs no new premise and stays local.
4. Improvement proposed for the table design: the table must have three row kinds --
   (a) per-slot field pin keyed by offset class (as can_traj), (b) a cross-slot count
   (red coins alive + counter = 8; a red coin exists while the star is at its init
   word), (c) a guard on a global (cannon-unlocked save bit, Mario's phase). (a) alone
   is what the note above described.

Rejected this round: starting the generic table before the sweep (would have built
kind (a) only); weakening box_pos_ok (its one consumer, CannonKeep.lid_not_box, has no
other way to tell a lid from a box: oBehavior is not tied to the script).

## 2026-11-13 (third round): the slot table -- choice, written before executing

**Chosen: ONE boolean table inside `pin_at`, flat rows first.**

- `ObjWorld.slot_tab : list trow`, a row = (script, cell list, boolean check over the
  command offset and the loaded cells). `tab_at k := forallb (row_b k) slot_tab = true`
  is a new conjunct of `pin_at`. The clause IS its checker, so the boot check
  (`ow_chk`) costs one `&&` and no soundness proof per row.
- Keyed by the SCRIPT a slot runs (command-pointer block), not by oBehavior: the
  native_res sites are (script, word, native), and nothing ties script -> behavior.
- One generic keeper, `tab_at_scr`: cells of `tab_cells` equal + `runs` equal for
  `tab_scripts` => kept. Every proved obj_w keeper (PollKeep.obj_w_slots_h,
  ObjVmSwap.obj_w_vm_swap, UnloadOw) already has both facts for any cell off the VM
  cells / oPosY / home, so a FLAT row (check independent of the command offset, cells
  off those three) costs: the row, `tab_scripts` / `tab_cells` entries, one bit in
  ObjFamily's class (so a VM step keeps "runs this script"), and nothing per keeper.
- First row: bhvHiddenRedCoinStar -> oAction = 0 and oHiddenStarTriggerCounter < 8
  (the hidden-star loop FOUND: oAction = 1 was not excluded; the counter is restated
  by script because red_ok's is keyed by oBehavior).

Measured against the cannon trajectory (~2,000 lines, 28 files): the flat-row route
touches the 4 keeper sites once, for the table.

Not covered by flat rows, so NOT attempted this round (each needs the carrier shape
can_traj has, i.e. a re-anchored ghost at the script word that moves the pin):
lid oHome (pos pinned before SET_HOME, home after), box position by action, box
byte (field 47 is a FieldWin script window). Next step for those: migrate can_traj
into the table as an offset-class row and generalize ObjAnchor's re-anchor once.
Cross-slot (red coins 7 -> 8, star init with no coin) and global guards stay open.

Rejected: a new ow_core field (breaks every constructor); narrowing `live_bhvs` first
(removes no FOUND case: the box's cut contents are already dead sites, the rest are
field pins); keying by oBehavior (the loop site would stay false at a slot that runs
the script under another behavior).

## 2026-11-14 (fourth round): choices, written before executing

Kept from the interrupted third round (7839647b WIP): the boolean slot table inside
`pin_at` and its first flat row (hidden star: oAction = 0, counter < 8). It is small,
its boot check is the clause itself, and it is the right carrier for per-slot pins.

**Changed / added, and why:**

1. **box_pos_ok is DROPPED from coll_ok, not strengthened by action.** The clause is
   false in the real game: a hit box (act 3) moves by oVelY and oForwardVel, and act 2
   resets only oPosY. A by-action pin is not inductive either (oForwardVel is an
   unpinned window field, so x/z in act 3 is unbounded). Its only reader is
   CannonKeep's "the lid ghost is not a box", which exists only to feed ObjVmSwap's
   Hy0, which needs it only to re-prove box_pos_ok. So the clause supports nothing
   but itself. Removing it RESTATES the row (INV says less, the two FOUND cases go
   away) at ~5 edit sites. The third round rejected this on the grounds that the lid
   keep needs it; that need is circular.
2. **Window-cell rows (box byte, field 47).** A table row may read a FieldWin window
   cell only if the window is taken out of the script-writable set for obj_w. Plan:
   remove (324,328) from `ucl_h`, carry a table-keep hypothesis next to `KT`, and
   one generic "store into slot k off every row's cells or at a slot not running the
   row's script" lemma (the shape of kt_off). Census: no script word writes field 47.
   Row: BOXS -> byte in BoxCensus.box_ids. Second milestone; stop if the keepers'
   churn exceeds ~400 lines.
3. **Lid oHome**: needs an offset-class row + a SET_HOME re-anchor (ObjAnchor shape).
   Third, only if 2 lands cheaply; otherwise logged open with its exact cost.
4. **Red coins (7 -> 8; star init with no coin)**: NOT attempted per-slot. Both are
   true only through Mario (a coin is collected only by contact). They need row kind
   (c), a guard on Mario's phase/height, which is GOAL 2's own conclusion: closing
   them is a joint induction with the height capstone, not an objects-local repair.
   Reported as needing a decision.
5. **Undecided sites** are decided by census where a computation can (reference
   closure, written cells), after milestone 1.

Order: green first (1 + the WIP row) -> 2 -> undecided sites -> 3.

## 2026-11-24 (fifth round): choices, written before executing

State: master af5b951a merged. WIP row 2 (box byte) compiles through ObjFld; frontier ObjStep.

Read before choosing:
- `red_ok` and table row 1 have NO reader outside their own keepers. What is load-bearing
  is `kind_ok` (no INTERACT_STAR slot), which feeds `wmotr_objects`. So the red-coin pair
  cannot be dropped the way box_pos_ok was: "no star slot" must stay, and it is true only
  through "coin #2 not touched", i.e. Mario's height (Pobj already holds Phi, so the
  induction is statable inside the rows).
- What the red-coin repair really needs (not objects-local): (i) obj_w pins a coin-#2
  slot (script, position, hitbox, active, INTERACTED clear) and a count
  (star counter + live red coins <= 8); (ii) the PROVED collision stage must show Mario's
  collided list never holds that slot (the f32 overlap test against PhiW's height: new
  geometry in CollWalk); (iii) Mario's frame must keep INTERACTED clear on non-collided
  slots. (ii)/(iii) are Mario-side / proved-stage files. No cheaper true restatement
  found: any clause that makes the two sites true must exclude "coin interacted at
  counter 7", and only Mario's height does that. => reported as a cross-track item.

**Order chosen:**
1. Land row 2 (box byte) green: milestone 1.
2. Census the undecided sites (Sweep4-style reach classes on the spine), so every
   NOT DECIDED site gets a computed class instead of a reading.
3. Lid oHome. NOT a third hand-built re-anchor: add a state-keyed clause to GPs
   (`v_s st0 = LIDS -> past SET_HOME -> home pinned in the ghost`) fed by a row that
   pins pos before word 4 and home after; only the home_keep step establishes it.
   Stop if it reaches the cannon's cost shape (3 failed rounds => redesign).
4. Split native_res by site class so that discharged classes leave the row
   (dead sites first: provable now from dead_site_no_Q).

## 2026-11-25 (sixth round): the joint induction ("no star collected yet"), design

Coordinator: this is an invariant strengthening proved from real code, owned here.
Survey of what already exists (read-only pass, file:line in the session log):
- Phi = PhiW contains `action_sat R_noA` (73 actions): star-dance, key-door, ending
  actions ARE excluded at every Pobj state. (The fifth-round remark "mem_ok does not
  exclude them" was about mem_ok only; Phi does.) wmotr_objects: Mario's collided
  objects have WMotR kinds (no STAR_OR_KEY).
- Height: pos[1] and gfx.pos[1] <= 2796 < 2980. NOT bounded: Mario's OBJECT oPosY
  (offset 164), the cell detect_object_hitbox_overlap reads. TRUST.md:96 lists
  "Mario object's y = pos[1] at collision time" as assumed.
- Collision stage: proved, but with no geometry (any two listed slots may register).
  The geometric lemma exists off the spine: CoinLink.overlap_no_contact /
  mario_coin2_no_contact. Plug-in point: CollWalk.hit_ok's Mario-vs-slot call.
- No red coin slot is pinned (position, hitbox, parent, status). Counter increment in
  bhv_red_coin_loop: INTERACTED bit set and parent != NULL, parent's field 27 += 1.
- Mario frame: no proved "INTERACTED is written only on collided objects";
  mario_process_interactions sits in NaSplit.na_open (track 2's file).

**Chosen steps, cheapest first (each a separate green milestone):**
C1. Cut the star family (9 scripts) from `live_bhvs`. Objects-local. 13 sites become
    dead. True in the real game given C2-C4; spawner guards: row 1, C3, R_noA.
C2. obj_w: Mario's object oPosY <= 2796 at Pobj states (the copy at the end of
    bhv_mario_update keeps it; boot-checked). Turns TRUST.md:96's assumed fact into
    an invariant clause; the transfer obligation lands in bhvMario@9's native_res.
C3. obj_w: coin-#2 clause. "A live slot running bhvRedCoin with the INTERACTED bit
    set does not exist while ..." is too strong (other 7 coins are collectable).
    Instead a COUNT: let R = live slots running bhvRedCoin, I = those with INTERACTED;
    clause: HSTARS counter + |R| <= 8 ... and coin #2 (pinned: script bhvRedCoin, pos
    (2735,3140,-3085), down offset 0, INTERACTED clear, active) is in R. Then
    counter <= 8 - 1 < 8 (row 1's bound, now derived), init's count >= 1 (no bhvStar
    spawn), and the 7 -> 8 site needs coin #2 INTERACTED, excluded by the pin.
    Needs: red coin parent = the HSTARS slot (else the increment hits another slot).
C4. Keeping C3's "coin #2 INTERACTED clear": (i) collision stage: put
    overlap_no_contact on the spine at hit_ok, so coin #2 is never in Mario's list
    (uses C2); (ii) Mario frame: INTERACTED stored only on collided objects / usedObj.
    (ii) is Mario-side (NaSplit.na_open, track 2): PROPOSAL to the coordinator before
    any edit there. Until (ii) is proved it stays an obligation inside native_res at
    bhvMario@9, which is where Mario's object effects already sit, so NO HeightFrame
    premise changes.
Order with the rest: milestone 1 (box byte) -> lid oHome -> C1 -> C2 -> C3 -> C4(i).
