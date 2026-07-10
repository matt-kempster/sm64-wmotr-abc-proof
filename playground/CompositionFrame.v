(* ======================================================================= *)
(*  GOAL-2 T0 — the SEGMENT-COMPOSITION frame skeleton.                     *)
(*  (docs/goal2-real-frame-plan.md §0/§3-T0; scout cites =                  *)
(*   docs/goal2-frame-boundary-scout.md)                                    *)
(*                                                                          *)
(*  T0-RETOOL (2026-07-09, plan §1 correction): the platform segment now    *)
(*  consumes T1's WIDENED spec (playground/PlatformInert.v,                 *)
(*  seg_platform_yact_inert) — the y-cell and action-cell LOADS are         *)
(*  unchanged, UNCONDITIONALLY — instead of the first draft's               *)
(*  gplat_null-conditioned no-op.  Reason: "gMarioPlatform ≡ NULL" is       *)
(*  FALSE in WMotR (the 6 wing-cap exclamation boxes are dynamic object     *)
(*  floors, 3 reachable no-A); the honest invariant is NULL-OR-BOX and      *)
(*  BOTH arms are y/action-inert.  That case analysis lives behind T1's     *)
(*  boundary premises (BP-INIT/BP-SEG-NULL/BP-SEG-BOX/BP-SURF-OBJ), NOT     *)
(*  in T0's interface: the theorems below take NO gplat_null premise.       *)
(*                                                                          *)
(*  THIS FILE IS A SANDBOX (same regime as FramePlayground.v): outside      *)
(*  proofs/, NOT in _CoqProject, invisible to `make proofs` and to the      *)
(*  discipline audit's admit-grep.  Admitted would be allowed here, but     *)
(*  this file has NONE: every genuinely-open obligation is a named          *)
(*  Hypothesis row marked (* OPEN: ... *), and the two T0 theorems are      *)
(*  PROVED as composition glue over those rows.                             *)
(*                                                                          *)
(*  Compile by hand:                                                        *)
(*    source pipeline/env.sh                                                *)
(*    coqc -R generated SM64.Generated -R proofs SM64.Proofs \              *)
(*         playground/CompositionFrame.v                                    *)
(*                                                                          *)
(*  THE ARCHITECTURE (plan §0).  The real per-frame chain is                *)
(*      apply_mario_platform_displacement                                   *)
(*      → bhv_mario_update → execute_mario_action    (GOAL-1's frame)       *)
(*      → level phase (check_instant_warp etc.)                            *)
(*      → the rest of update_objects / gfx (non-Mario)                     *)
(*  Widening GOAL-1's eval_funcall to update_objects would require          *)
(*  clightgen'ing + linking >= 4 new TUs (the object-behavior VM) —         *)
(*  REJECTED.  Instead the frame is a composition of four segments:         *)
(*  the middle one is GOAL-1's execute_mario_action_step_lp AS-IS, and      *)
(*  the flanking three get named SPECS (the labeled-trust pattern),         *)
(*  each backed by a WMotR-grounded discharge track (T1/T4) or an           *)
(*  explicit boundary row.                                                  *)
(* ======================================================================= *)

From Coq Require Import ZArith List Reals.
From Flocq Require Import Binary.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Clight Linking.
From SM64.Generated Require mario level_update.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked
  ActionValueFrame Taint.

(* ----------------------------------------------------------------------- *)
(* The tracked y-cell, pinned against the generated AST (PIPELINE, not      *)
(* bespoke): pos is at byte offset 60 in MarioState (vm-computed below      *)
(* from mario.prog's OWN composite env, exactly like GOAL-1's action@12),   *)
(* pos[1] = 60 + 4 = 64.                                                    *)
(* ----------------------------------------------------------------------- *)
Lemma mario_pos_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._pos mario_state_members
    = Errors.OK (60, Full).
Proof. vm_compute. reflexivity. Qed.

Definition POSY : Z := 64.   (* pos base 60 (pinned above) + 4 for index 1 *)

(* The censused TELEPORT writers (scout §1/§5; plan §2 TELEPORT class):
   check_instant_warp (level_update.c:547, LINKED TU) and init_mario
   (mario.c:1788, spawn — the run's antecedent, not a per-frame writer).
   Documentation census only in T0; T4 grounds the semantic disjunct below
   against WMotR's level data (expected: NO instant-warp regions). *)
Definition teleport_writer_ids : list ident :=
  level_update._check_instant_warp :: mario._init_mario :: nil.

Section CompositionFrame.

  (* --- mirror GOAL-1's real-frame section surface (RealFrameLinked / *)
  (*     NoAImpliesNoFlyLinked) --- *)
  Variable lp : Clight.program.                (* the linked program, ABSTRACT *)
  Hypothesis LO_mario : linkorder mario.prog lp.
  Variable bm : block.                         (* Mario's MarioState block *)
  Variable MWF NoA : mem -> Prop.              (* the GOAL-1 invariants, abstract
                                                  here exactly as in the capstone
                                                  section (grounded at MWF_real /
                                                  NoA_real on promotion) *)

  (* --- gMarioPlatform ---------------------------------------------------
     FLAG (linkage finding, 2026-07-09): gMarioPlatform is NOT a linked or
     even generated global.  It lives in platform_displacement.c, which is
     un-generated (scout §2); `grep -rn gMarioPlatform generated/` finds
     NOTHING — not even an External declaration in another TU.  So its
     NULL-ness CANNOT be phrased via Genv.find_symbol over lp (there is no
     ident to look up, and a lookup would fail).  We therefore parameterize
     honestly by the BLOCK holding the cell; a C global's storage starts at
     offset 0 of its own block, so the cell is (bplat, 0).  T1 keeps this a
     labeled boundary row unless/until platform_displacement.c joins the
     clightgen pipeline (at which point bplat becomes a find_symbol fact).

     T0-RETOOL: bplat/gplat_null are retained for DOCUMENTATION only — no
     definition or theorem below consumes them.  T1's correction
     (PlatformInert.v §4) shows the cell is NULL-OR-BOX in WMotR, not NULL;
     the case analysis, the cell-carry lemmas (platform_null_carry) and the
     writer census all live in PlatformInert.v behind its named boundary
     premises.  T0's interface sees only the unconditional widened
     conclusion (seg_platform_spec below). *)
  Variable bplat : block.

  Definition gplat_null (m : mem) : Prop :=
    Mem.load Mptr m bplat 0 = Some Vnullptr.

  (* The y-cell: 4 bytes at (bm, POSY). *)
  Definition pos_y_cell : block -> Z -> Prop :=
    fun b z => b = bm /\ POSY <= z < POSY + size_chunk Mfloat32.

  (* ===================================================================== *)
  (* 1. THE SEGMENT SPECS (predicates over (m, m')).                        *)
  (*    Per plan §0 every flanking spec carries does-not-change-the-action- *)
  (*    cell UNCONDITIONALLY — that is what makes GOAL-1 transfer           *)
  (*    compositional (for seg_platform, as a load-equality).               *)
  (* ===================================================================== *)

  (* seg_platform: apply_mario_platform_displacement
     (platform_displacement.c:171).  THE WIDENED SPEC — clauses 1-2 are
     T1's seg_platform_yact_inert COPIED VERBATIM from
     playground/PlatformInert.v (playground has no -R mapping, so
     playground files cannot Require each other; the duplication is
     deliberate and credited).  Unconditionally: whatever the platform
     phase did, the y-cell (bm,POSY,Mfloat32) and action-cell
     (bm,12,Mint32 — GOAL-1's action_cell offset) LOADS are unchanged.
     Grounding (PlatformInert.v §4): the NULL arm is the :174 early
     return (no store at all, BP-SEG-NULL); the box arm's y-write is
     IDENTITY (a ridden exclamation box has oVel* = oAngleVel* = 0, so
     the displacement stores back the loaded y) and never touches action
     (BP-SEG-BOX).  Note the box arm DOES store to pos — which is why
     the spec is "the LOAD is unchanged", not unchanged_on/no-store.
     Clause 3 is block-validity transport: loads alone cannot carry
     Mem.valid_block across the segment (mem_ok needs it); it is
     dischargeable on both T1 arms — NULL from BP-SEG-NULL's
     unchanged_on (Mem.valid_block_unchanged_on), box because the phase
     is a real execution (nextblock-monotone). *)
  Definition seg_platform_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm).

  (* seg_level: the warp/level phase (check_instant_warp level_update.c:530
     + the delayed/painting warp initiators).  None of them writes
     m->action (scout §5), hence the unconditional action clause.  The pos
     clause is the TELEPORT disjunction (plan §1): either nothing wrote the
     y cell, or a censused teleport writer ran and the resulting y value is
     in the censused target set.  teleport_target_y is the T4 parameter:
     "v is the y of a WMotR-censused teleport destination" (for WMotR the
     instant-warp set is expected EMPTY, collapsing the spec to the left
     disjunct; spawn/init_mario is the run antecedent, not per-frame). *)
  Variable teleport_target_y : float32 -> Prop.

  Definition teleport_write (m m' : mem) : Prop :=
    exists v, Mem.load Mfloat32 m' bm POSY = Some (Vsingle v)
              /\ teleport_target_y v.

  Definition seg_level_spec (m m' : mem) : Prop :=
    Mem.unchanged_on (action_cell bm) m m'
    /\ (Mem.unchanged_on pos_y_cell m m' \/ teleport_write m m').

  (* seg_rest: the non-Mario phase boundary — the rest of update_objects
     (other objects' behaviors, unload, update_mario_platform) + gfx.  NOTE
     (T0-retool, prior draft): the first draft also carried "gplat_null m ->
     gplat_null m'", justified by "every WMotR floor has object == NULL" —
     that claim is FALSE (T1's correction: the 6 exclamation boxes are
     dynamic object floors, so update_mario_platform CAN write a box
     pointer, writer platform_displacement.c:59).  The honest gMarioPlatform
     evolution (NULL-or-box) is T1's business (PlatformInert.v BP-SURF-OBJ +
     the §4(b) writer census); T0 no longer threads the cell.

     RETOOL §7 (2026-07-09, plan §7 + docs/goal2-wmotr-behavior-census.md):
     the bare "unchanged_on mario_block ENTIRELY" claim is ALSO FALSE of the
     real game — the level-wide WMotR object census (rung 4) found exactly
     THREE object-side Mario-block writers reachable in this level:
       1. cur_obj_push_mario_away (the 6 pole volumes): writes pos[0]/pos[2]
          only — never y, never action.
       2. bhv_1up_interact (the 1-ups): writes numLives only.
       3. set_mario_npc_dialog, via the cannon's bob-omb buddy
          (mario_actions_cutscene.c:361-362, generated as
          f_set_mario_npc_dialog in generated/mario_actions_cutscene.v):
          writes action := ACT_READING_NPC_DIALOG and usedObj — the ONLY
          object-side write to the action cell anywhere in the level.
     None of the three ever writes pos[1] (y).  The refined spec: the
     y-load is unchanged (as before, unconditionally); the action-load is
     EITHER unchanged OR set to the single grounded value
     ACT_READING_NPC_DIALOG (a non-flying, not_tainted cutscene action —
     proved below by vm_compute against the real Taint.is_tainted, not
     assumed); validity transport, as the other two flanks carry. *)

  (* ACT_READING_NPC_DIALOG, grounded at the generated AST (PIPELINE, not
     the C header): generated/mario_actions_cutscene.v:2276, inside
     f_set_mario_npc_dialog's own early-return guard
     "if (gMarioState->action == ACT_READING_NPC_DIALOG) return -1;"
     (mario_actions_cutscene.c:349) —
       (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                      (Econst_int (Int.repr 536875782) tint) tint) ...).
     The SAME literal 536875782 also appears at
     mario_actions_cutscene.v:2361 (the set_mario_action call argument —
     the real write site, source mario_actions_cutscene.c:362) and in the
     dispatch switch tables of mario.v:8828 and
     mario_actions_cutscene.v:16950 (LScons (Some 536875782) ...) — so it
     is the ONE value clightgen assigned this action constant everywhere it
     is mentioned, not an isolated occurrence.  (vendor/sm64/include/sm64.h:343
     independently says 0x20001306 = 536875782, so the header and the
     compiled AST agree for this constant — unlike ACT_FLYING's
     stale-nibble case documented in Flying.v.) *)
  Definition ACT_READING_NPC_DIALOG : int := Int.repr 536875782.

  (* not_tainted is ALREADY concrete in this file (Taint is Require Import'd
     above, not abstracted behind a section Variable), so this is a real
     proof, not a Hypothesis: unfolding is_tainted, ACT_READING_NPC_DIALOG is
     neither ACT_FLYING nor ACT_FLYING_TRIPLE_JUMP (Flying.v) nor
     ACT_SHOT_FROM_CANNON (Taint.v) — three closed Int.eq comparisons on
     Int.repr literals, safe to vm_compute (never a genv/program constant;
     this is bare Int arithmetic, per the build-rules guardrail). *)
  Lemma dialog_action_not_tainted : not_tainted ACT_READING_NPC_DIALOG.
  Proof. vm_compute. reflexivity. Qed.

  Definition seg_rest_spec (m m' : mem) : Prop :=
    Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
    /\ (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
        \/ Mem.load Mint32 m' bm 12 = Some (Vint ACT_READING_NPC_DIALOG))
    /\ (Mem.valid_block m bm -> Mem.valid_block m' bm).

  (* ===================================================================== *)
  (* 2. THE FRAME: existential composition (plan §0).  seg_action is        *)
  (*    GOAL-1's execute_mario_action_step_lp (RealFrameLinked.v:415) —     *)
  (*    one big-step eval_funcall of f_execute_mario_action at globalenv    *)
  (*    lp — reused AS-IS, verbatim.                                        *)
  (* ===================================================================== *)

  Definition seg_action : mem -> mem -> Prop :=
    execute_mario_action_step_lp lp.

  Definition frame_step (m m' : mem) : Prop :=
    exists m1 m2 m3,
      seg_platform_spec m  m1
      /\ seg_action        m1 m2
      /\ seg_level_spec    m2 m3
      /\ seg_rest_spec     m3 m'.

  (* ===================================================================== *)
  (* 3. THE GOAL-1 INVARIANT BUNDLE (NoAImpliesNoFlyLinked.v:92,            *)
  (*    mem_ok_lp): valid_block + action_sat not_tainted + MWF.             *)
  (* ===================================================================== *)

  Definition mem_ok (m : mem) : Prop :=
    Mem.valid_block m bm /\ action_sat not_tainted m bm /\ MWF m.

  (* ---- the labeled-trust rows the glue composes over ------------------ *)

  (* THE MIDDLE — PROVED ELSEWHERE: this row is exactly what GOAL-1's
     NoAImpliesNoFlyLinked.frame_preserves_mem_ok_lp discharges (via
     execute_mario_action_preserves_real_reached_lp).  It is re-stated as a
     hypothesis here only because instantiating its full residual surface
     (Hreach_val/Hstore_safe/Hbcr/... ) in a sandbox would duplicate the
     capstone's plumbing; the promotion step wires the real lemma in.  NOT
     new trust. *)
  Hypothesis Hmiddle :
    forall m m', NoA m -> mem_ok m -> seg_action m m' -> mem_ok m'.

  (* Mirrors the capstone row Hnoa_of_mwf (NoAImpliesNoFlyLinked.v:147),
     PROVED at the MWF_real grounding (mwf_real_ctl).  NOT new trust. *)
  Hypothesis Hnoa_of_mwf : forall m, MWF m -> NoA m.

  (* OPEN (T1 boundary): MWF survives the platform segment.  T1's
     deliverable (PlatformInert.v seg_platform_transfer + the boundary
     premises BP-INIT/BP-SEG-NULL/BP-SEG-BOX/BP-SURF-OBJ) discharges the
     y_le/action_sat transfer — that part T0 now consumes directly through
     the widened seg_platform_spec, no case analysis here.  MWF is the
     residue: MWF_real watches cells BEYOND the two yact-inert loads (bc,
     oc0, the stored globals), so this row is the platform analogue of
     Hmwf_rest.  Discharge: widen T1's segment conclusion to "unchanged on
     the MWF-watched cells" — immediate on the NULL arm (BP-SEG-NULL's
     unchanged_on is block-wise), and on the box arm the phase writes only
     m->pos[0..2] (set_mario_pos, platform_displacement.c:81-85; PlatformInert.v
     §4(d)) so the same census closes it — or keep it as the labeled
     un-generated-TU boundary. *)
  Hypothesis Hmwf_platform :
    forall m m', seg_platform_spec m m' -> MWF m -> MWF m'.

  (* OPEN (T4 + boundary): MWF survives the level phase.  check_instant_warp
     is in the LINKED level_update TU, so this is walkable with GOAL-1's
     existing machinery (a WarpSurface-style walk) — or dischargeable via
     the WMotR census (no instant-warp regions => the phase is inert on the
     cells MWF watches). *)
  Hypothesis Hmwf_level :
    forall m m', seg_level_spec m m' -> MWF m -> MWF m'.

  (* OPEN (boundary row): MWF survives the non-Mario rest phase.  MWF_real
     watches cells beyond bm (bc, oc0, the stored globals), so
     unchanged_on bm alone cannot prove it; the honest discharge is either
     to widen seg_rest_spec with "unchanged on the MWF-watched cells" (the
     same shape as the stored_globals rows) or keep this as the labeled
     non-Mario model boundary. *)
  Hypothesis Hmwf_rest :
    forall m m', seg_rest_spec m m' -> MWF m -> MWF m'.

  (* ---- proved composition glue ---------------------------------------- *)

  (* a LOAD-EQUAL action cell transports action_sat outright — no
     valid_block needed (the mirror of PlatformInert.v's
     transfer_of_yact_inert, action leg). *)
  Lemma action_sat_load_eq :
    forall Q m m',
      Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12 ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q m m' Heq Hsat v Hl. apply Hsat. congruence.
  Qed.

  (* the §7 seg_rest action clause is a DISJUNCTION (load-equal OR set to
     one grounded value v0) rather than a bare equality — this is the
     generalization action_sat_load_eq specializes to the empty-disjunct
     case.  Consumed with v0 := ACT_READING_NPC_DIALOG and the Q-side
     premise supplied by dialog_action_not_tainted. *)
  Lemma action_sat_load_eq_or_val :
    forall Q v0 m m',
      (Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12
       \/ Mem.load Mint32 m' bm 12 = Some (Vint v0)) ->
      Q v0 ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q v0 m m' [Heq | Heq] Hv0 Hsat v Hl.
    - apply Hsat. congruence.
    - rewrite Heq in Hl. injection Hl as Hveq. subst v. exact Hv0.
  Qed.

  (* ===================================================================== *)
  (* 4. THE GOAL-1 TRANSFER THEOREM: frame_step preserves the GOAL-1        *)
  (*    invariant bundle.  PROVED — the platform flank's widened spec       *)
  (*    transports action_sat by load-equality (action_sat_load_eq) and     *)
  (*    valid_block by its transport clause; the level/rest flanks'         *)
  (*    action-cell clauses transport action_sat (action_sat_unchanged_on); *)
  (*    the middle is GOAL-1's proved frame lemma (the Hmiddle row); MWF    *)
  (*    crosses the flanks via the three OPEN rows above.  NO gplat_null    *)
  (*    premise (T0-retool): the NULL-or-box analysis is T1-internal.       *)
  (* ===================================================================== *)
  Theorem frame_step_preserves_mem_ok :
    forall m m',
      mem_ok m ->
      frame_step m m' ->
      mem_ok m'.
  Proof.
    intros m m' (Hv & Hsat & Hmwf)
           (m1 & m2 & m3 & Hplat & Hact & Hlvl & Hrest).
    (* --- seg_platform flank: the widened yact-inert spec --- *)
    pose proof Hplat as Hplat0.
    destruct Hplat as (Hyeq1 & Haeq1 & Hvb1).
    assert (Hv1 : Mem.valid_block m1 bm) by exact (Hvb1 Hv).
    assert (Hsat1 : action_sat not_tainted m1 bm)
      by (eapply action_sat_load_eq; [ exact Haeq1 | exact Hsat ]).
    assert (Hmwf1 : MWF m1) by exact (Hmwf_platform m m1 Hplat0 Hmwf).
    (* --- seg_action = GOAL-1's frame --- *)
    assert (Hok2 : mem_ok m2).
    { eapply Hmiddle;
        [ exact (Hnoa_of_mwf m1 Hmwf1)
        | exact (conj Hv1 (conj Hsat1 Hmwf1))
        | exact Hact ]. }
    destruct Hok2 as (Hv2 & Hsat2 & Hmwf2).
    (* --- seg_level flank --- *)
    pose proof Hlvl as Hlvl0.
    destruct Hlvl as [Hact_unch3 _].
    assert (Hv3 : Mem.valid_block m3 bm)
      by (eapply Mem.valid_block_unchanged_on; eauto).
    assert (Hsat3 : action_sat not_tainted m3 bm)
      by (eapply action_sat_unchanged_on;
          [ exact Hact_unch3 | exact Hv2 | exact Hsat2 ]).
    assert (Hmwf3 : MWF m3) by exact (Hmwf_level m2 m3 Hlvl0 Hmwf2).
    (* --- seg_rest flank: the §7 census-refined spec --- *)
    pose proof Hrest as Hrest0.
    destruct Hrest as (_ & Hact4 & Hvb4).
    assert (Hv4 : Mem.valid_block m' bm) by exact (Hvb4 Hv3).
    assert (Hsat4 : action_sat not_tainted m' bm)
      by (eapply action_sat_load_eq_or_val;
          [ exact Hact4 | exact dialog_action_not_tainted | exact Hsat3 ]).
    exact (conj Hv4 (conj Hsat4 (Hmwf_rest m3 m' Hrest0 Hmwf3))).
  Qed.

  (* ===================================================================== *)
  (* 5. THE ONE-FRAME Y-LEMMA.                                              *)
  (*    y_le: the float at (bm, POSY) has real value <= YMAX (the           *)
  (*    FramePlayground sketch, made concrete; B2R is Flocq's, float32 =    *)
  (*    binary_float 24 128).                                               *)
  (* ===================================================================== *)

  Variable YMAX : R.   (* the WMotR bound H* + Delta_pot (strategy v2) *)

  Definition y_le (Y : R) (m : mem) : Prop :=
    forall v, Mem.load Mfloat32 m bm POSY = Some (Vsingle v) ->
              (B2R _ _ v <= Y)%R.

  (* a LOAD-EQUAL y cell transports y_le outright — the mirror of
     PlatformInert.v's transfer_of_yact_inert, y leg. *)
  Lemma y_le_load_eq :
    forall Y m m',
      Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY ->
      y_le Y m -> y_le Y m'.
  Proof.
    intros Y m m' Heq Hy v Hl. apply Hy. congruence.
  Qed.

  Lemma y_le_unchanged_on :
    forall Y m m',
      Mem.unchanged_on pos_y_cell m m' ->
      Mem.valid_block m bm ->
      y_le Y m -> y_le Y m'.
  Proof.
    intros Y m m' Hu Hv Hy v Hld.
    assert (Heq : Mem.load Mfloat32 m' bm POSY
                  = Mem.load Mfloat32 m bm POSY).
    { eapply Mem.load_unchanged_on_1; [ exact Hu | exact Hv | ].
      intros i Hi. split; [ reflexivity | exact Hi ]. }
    apply Hy. rewrite <- Heq. exact Hld.
  Qed.

  (* OPEN (T2 + T3, THE CRUX): the seg_action y-preservation — one real
     eval_funcall of f_execute_mario_action keeps y <= YMAX under no-A.
     This is the BALLISTIC value walk (plan §2): GOAL-1's walks prove
     stores AVOID a cell; this must prove the stored VALUE satisfies the
     interval (paqs `pos[1] += vel[1]/4` bounded by the Flocq brick T2 +
     the vel census; ATTACH class via the find_floor value contract;
     MONOTONE-SAFE class trivial).  The side conditions the §2 classes
     need (vel bound, floor-ladder H*, the OOB-gfx invariant) will refine
     this row's premises — T0 deliberately keeps the frame-level premise
     set minimal (NoA + mem_ok). *)
  Hypothesis Hseg_action_y :
    forall m m', NoA m -> mem_ok m -> y_le YMAX m -> seg_action m m' ->
                 y_le YMAX m'.

  (* OPEN (T4): the teleport census bound — every censused WMotR teleport
     target y is <= YMAX.  Expected discharge: the WMotR instant-warp set
     is EMPTY (scout §5: WMotR's warps are the airborne self-loop +
     death/success node warps), making teleport_target_y := fun _ => False
     and this row vacuous. *)
  Hypothesis Hteleport_y :
    forall v, teleport_target_y v -> (B2R _ _ v <= YMAX)%R.

  (* THE ONE-FRAME Y-THEOREM.  PROVED as glue over the two OPEN rows: the
     flanks transport y_le because they are unchanged on the y cell (or,
     in seg_level's teleport disjunct, because the written value is
     censused-bounded); the middle is the T2/T3 row.  The NoA premise is
     the "noA side condition"; at the MWF_real grounding it also follows
     from mem_ok via Hnoa_of_mwf, but it is kept explicit for statement
     fidelity with the plan's y-invariant shape. *)
  Theorem frame_step_keeps_y_le :
    forall m m',
      NoA m ->
      mem_ok m ->
      y_le YMAX m ->
      frame_step m m' ->
      y_le YMAX m'.
  Proof.
    intros m m' HnoA (Hv & Hsat & Hmwf) Hy
           (m1 & m2 & m3 & Hplat & Hact & Hlvl & Hrest).
    (* --- seg_platform flank: the widened yact-inert spec --- *)
    pose proof Hplat as Hplat0.
    destruct Hplat as (Hyeq1 & Haeq1 & Hvb1).
    assert (Hv1 : Mem.valid_block m1 bm) by exact (Hvb1 Hv).
    assert (Hsat1 : action_sat not_tainted m1 bm)
      by (eapply action_sat_load_eq; [ exact Haeq1 | exact Hsat ]).
    assert (Hmwf1 : MWF m1) by exact (Hmwf_platform m m1 Hplat0 Hmwf).
    assert (Hy1 : y_le YMAX m1)
      by (eapply y_le_load_eq; [ exact Hyeq1 | exact Hy ]).
    assert (Hok1 : mem_ok m1) by exact (conj Hv1 (conj Hsat1 Hmwf1)).
    (* --- seg_action: the T2/T3 crux row --- *)
    assert (Hy2 : y_le YMAX m2)
      by exact (Hseg_action_y m1 m2 (Hnoa_of_mwf m1 Hmwf1) Hok1 Hy1 Hact).
    assert (Hok2 : mem_ok m2).
    { eapply Hmiddle;
        [ exact (Hnoa_of_mwf m1 Hmwf1) | exact Hok1 | exact Hact ]. }
    destruct Hok2 as (Hv2 & _ & _).
    (* --- seg_level flank: the TELEPORT disjunction --- *)
    destruct Hlvl as [Hact_unch3 Hdisj].
    assert (Hv3 : Mem.valid_block m3 bm)
      by (eapply Mem.valid_block_unchanged_on; eauto).
    assert (Hy3 : y_le YMAX m3).
    { destruct Hdisj as [Hunch3 | (v & Hld & Htgt)].
      - eapply y_le_unchanged_on; [ exact Hunch3 | exact Hv2 | exact Hy2 ].
      - intros v' Hld'. rewrite Hld' in Hld.
        injection Hld as Hveq. subst v'.
        exact (Hteleport_y v Htgt). }
    (* --- seg_rest flank: the §7 census-refined spec's y-load-equal
       clause transports y_le directly (load-equality, not unchanged_on —
       the pole/1-up writers touch other cells, never pos[1]). --- *)
    destruct Hrest as (Hyeq4 & _ & _).
    eapply y_le_load_eq; [ exact Hyeq4 | exact Hy3 ].
  Qed.

End CompositionFrame.

(* ======================================================================= *)
(* (* STATUS *)                                                             *)
(*                                                                          *)
(* COMPILES (all Qed, NO Admitted):                                         *)
(*   - mario_pos_offset_concrete : pos @ 60 in MarioState, vm-pinned from   *)
(*     mario.prog's composite env (so POSY = 64 is AST-grounded, not        *)
(*     bespoke).                                                            *)
(*   - the three segment specs: seg_platform_spec is the WIDENED T1 shape   *)
(*     (T0-retool: clauses 1-2 = PlatformInert.v's seg_platform_yact_inert  *)
(*     copied verbatim — y-cell + action-cell LOADS unchanged,              *)
(*     UNCONDITIONALLY, both NULL-or-box arms concluding it behind T1's     *)
(*     boundary premises — plus a block-validity-transport clause 3);       *)
(*     seg_level_spec (unchanged); seg_rest_spec — RETOOLED §7 (2026-07-09,  *)
(*     plan §7 + docs/goal2-wmotr-behavior-census.md): shed both the false   *)
(*     gplat_null-carry clause AND the false bare "unchanged_on mario_block" *)
(*     shape.  Now: y-load unchanged (unconditional); action-load unchanged  *)
(*     OR := ACT_READING_NPC_DIALOG (the ONE grounded object-side action     *)
(*     write in WMotR, generated/mario_actions_cutscene.v:2276); validity    *)
(*     transport.  frame_step (the plan-§0 existential composition with      *)
(*     seg_action := execute_mario_action_step_lp lp, GOAL-1's frame         *)
(*     verbatim), mem_ok (= mem_ok_lp's bundle shape), y_le (concrete:       *)
(*     Flocq B2R of the Mfloat32 at (bm, 64)).                               *)
(*   - ACT_READING_NPC_DIALOG := Int.repr 536875782, grounded at             *)
(*     generated/mario_actions_cutscene.v:2276 (see the Definition's         *)
(*     comment for the full multi-site citation) — NOT the C header alone.  *)
(*   - dialog_action_not_tainted : not_tainted ACT_READING_NPC_DIALOG — a    *)
(*     REAL proof (vm_compute over Taint.is_tainted, which this file already *)
(*     imports concretely), not a Hypothesis: no new trust was added for     *)
(*     the §7 retool.                                                       *)
(*   - action_sat_load_eq / y_le_load_eq — the load-equality transport      *)
(*     glue (mirrors of PlatformInert.v's transfer_of_yact_inert legs).     *)
(*   - action_sat_load_eq_or_val — the §7 generalization (load-equal OR     *)
(*     set-to-v0) consumed by the seg_rest flank with v0 :=                 *)
(*     ACT_READING_NPC_DIALOG.                                              *)
(*   - frame_step_preserves_mem_ok  — THE GOAL-1 TRANSFER THEOREM, proved   *)
(*     as composition glue (platform flank: action_sat_load_eq + the        *)
(*     validity clause; level flank: action_sat_unchanged_on +              *)
(*     valid_block_unchanged_on; rest flank: action_sat_load_eq_or_val +    *)
(*     the validity-transport clause; middle: the Hmiddle row).  NO         *)
(*     gplat_null premise (T0-retool).                                      *)
(*   - frame_step_keeps_y_le       — THE ONE-FRAME Y-THEOREM, proved as     *)
(*     glue over the two OPEN y-rows (platform flank transports y_le by     *)
(*     y_le_load_eq, level flank by unchanged_on / the teleport census row, *)
(*     rest flank by y_le_load_eq off seg_rest_spec's first clause).  NO    *)
(*     gplat_null premise (T0-retool).                                      *)
(*                                                                          *)
(* NO Admitted; the open surface is the named Hypothesis rows:              *)
(*   - Hmiddle        : NOT open — GOAL-1's frame_preserves_mem_ok_lp,      *)
(*                      proved in NoAImpliesNoFlyLinked; re-stated to       *)
(*                      avoid duplicating the capstone's residual plumbing  *)
(*                      in a sandbox.  Promotion wires the real lemma.      *)
(*   - Hnoa_of_mwf    : NOT open — the capstone's own row, PROVED at        *)
(*                      MWF_real (mwf_real_ctl).                            *)
(*   - Hmwf_platform  : OPEN — T1 boundary.  The y_le/action_sat legs are   *)
(*                      ALREADY covered: T1's seg_platform_transfer +       *)
(*                      boundary premises (BP-INIT / BP-SEG-NULL /          *)
(*                      BP-SEG-BOX / BP-SURF-OBJ, PlatformInert.v) conclude *)
(*                      the widened spec T0 now consumes directly.  What    *)
(*                      remains is MWF alone (MWF_real watches bc/oc0/      *)
(*                      stored globals beyond the two loads): discharge =   *)
(*                      widen T1's segment conclusion to unchanged-on-the-  *)
(*                      MWF-watched-cells (NULL arm immediate from          *)
(*                      BP-SEG-NULL's unchanged_on; box arm writes only     *)
(*                      m->pos[0..2] per PlatformInert.v §4(d)), or keep    *)
(*                      it as the labeled un-generated-TU boundary — the    *)
(*                      platform analogue of Hmwf_rest.                     *)
(*   - Hmwf_level     : OPEN — T4/boundary.  check_instant_warp is in the   *)
(*                      LINKED level_update TU: walkable with the GOAL-1    *)
(*                      walker kit, or killed by the WMotR census (no       *)
(*                      instant-warp regions).                              *)
(*   - Hmwf_rest      : OPEN — boundary.  Needs seg_rest_spec's rest-of-MWF *)
(*                      residue (bc, oc0, stored globals — beyond the two   *)
(*                      §7-covered loads) widened to unchanged-on-the-      *)
(*                      MWF-watched-cells (the numLives/pos[0,2]/usedObj    *)
(*                      writes from §7 are outside MWF's watch set per the  *)
(*                      census) or stays the labeled non-Mario model        *)
(*                      boundary.                                           *)
(*   - Hseg_action_y  : OPEN — T2 + T3, THE CRUX.  The BALLISTIC value      *)
(*                      walk: a value-tracking variant of the paqs walk     *)
(*                      bounding the stored y (Flocq add/round brick T2 +   *)
(*                      vel census + ATTACH find_floor contract + the       *)
(*                      MONOTONE-SAFE class).  Its premise set will grow    *)
(*                      the §2 side conditions (vel bound, floor ladder,    *)
(*                      OOB-gfx invariant) as T3 lands.                     *)
(*   - Hteleport_y    : OPEN — T4.  The WMotR instant-warp census;          *)
(*                      expected EMPTY (teleport_target_y := False),        *)
(*                      making the row vacuously true.                      *)
(*                                                                          *)
(* GMARIOPLATFORM LINKAGE FINDING: not a linked global — zero occurrences   *)
(* in generated/ (platform_displacement.c is un-generated); parameterized   *)
(* here as an abstract block (bplat, cell at offset 0), NOT a find_symbol   *)
(* lookup.  See the FLAG comment at the Variable.  T0-RETOOL: bplat /       *)
(* gplat_null are now DOCUMENTATION ONLY — nothing below the Variable       *)
(* consumes them; the cell's per-frame evolution (NULL-or-box) lives        *)
(* entirely in T1 (PlatformInert.v: platform_null_carry, BP-SURF-OBJ, the   *)
(* §4(b) writer census).                                                    *)
(*                                                                          *)
(* WHAT T1/T2/T3/T4 MUST DELIVER (to discharge each admit-analogue):        *)
(*   T1 -> DELIVERED the widened spec + transfer glue this retool consumes  *)
(*         (seg_platform_yact_inert / seg_platform_transfer /               *)
(*         transfer_of_yact_inert behind BP-INIT / BP-SEG-NULL /            *)
(*         BP-SEG-BOX / BP-SURF-OBJ).  Remaining T1-side: the MWF residue   *)
(*         of Hmwf_platform (widen the segment conclusion to the            *)
(*         MWF-watched cells) and clause 3's validity transport on the box  *)
(*         arm (nextblock-monotonicity of the real phase).                  *)
(*   T2 -> the Flocq interval brick consumed inside Hseg_action_y.          *)
(*   T3 -> Hseg_action_y itself (the ballistic value walk).                 *)
(*   T4 -> Hteleport_y + Hmwf_level (census: WMotR instant-warp set).       *)
(* ======================================================================= *)
