(* ======================================================================= *)
(*  GOAL-2 T0 — the SEGMENT-COMPOSITION frame skeleton.                     *)
(*  (docs/goal2-real-frame-plan.md §0/§3-T0; scout cites =                  *)
(*   docs/goal2-frame-boundary-scout.md)                                    *)
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
     clightgen pipeline (at which point bplat becomes a find_symbol fact). *)
  Variable bplat : block.

  Definition gplat_null (m : mem) : Prop :=
    Mem.load Mptr m bplat 0 = Some Vnullptr.

  (* Mario's whole block, as a watched region. *)
  Definition mario_block : block -> Z -> Prop := fun b _ => b = bm.

  (* The y-cell: 4 bytes at (bm, POSY). *)
  Definition pos_y_cell : block -> Z -> Prop :=
    fun b z => b = bm /\ POSY <= z < POSY + size_chunk Mfloat32.

  (* ===================================================================== *)
  (* 1. THE SEGMENT SPECS (predicates over (m, m')).                        *)
  (*    Per plan §0 every flanking spec carries "does not write the action  *)
  (*    cell" UNCONDITIONALLY — that is what makes GOAL-1 transfer          *)
  (*    compositional.                                                      *)
  (* ===================================================================== *)

  (* seg_platform: apply_mario_platform_displacement
     (platform_displacement.c:171).  Its only m->pos writer is
     apply_platform_displacement (line 91), which never touches m->action
     (scout §4) — hence the unconditional action-cell clause.  Its guard
     requires gMarioPlatform != NULL (line 174); WMotR has NO dynamic
     surfaces, so under the NULL invariant the segment is memory-inert on
     Mario's block (in fact a full no-op — T1 may strengthen the conclusion
     to m' = m) and the NULL cell survives (the body writes gMarioPlatform
     only to NULL, line 184). *)
  Definition seg_platform_spec (m m' : mem) : Prop :=
    Mem.unchanged_on (action_cell bm) m m'
    /\ (gplat_null m ->
        Mem.unchanged_on mario_block m m' /\ gplat_null m').

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
     (other objects' behaviors, unload, update_mario_platform) + gfx.  Spec:
     unchanged on bm ENTIRELY (no non-Mario code writes Mario's state;
     copy_mario_state_to_object copies state->object, not the reverse —
     scout §1), and the gMarioPlatform-NULL cell is preserved
     (update_mario_platform writes gMarioPlatform, but in WMotR every floor
     has object == NULL so it only ever writes NULL — scout §4). *)
  Definition seg_rest_spec (m m' : mem) : Prop :=
    Mem.unchanged_on mario_block m m'
    /\ (gplat_null m -> gplat_null m').

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

  (* OPEN (T1): MWF survives the platform segment.  Under gplat_null the
     segment is semantically a full no-op (early return at
     platform_displacement.c:174), so the honest discharge is to strengthen
     seg_platform_spec's NULL conclusion to m' = m (then this row is
     trivial).  Kept as a row so T0 needs no spec-strength decision. *)
  Hypothesis Hmwf_platform :
    forall m m', gplat_null m -> seg_platform_spec m m' -> MWF m -> MWF m'.

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

  Lemma unchanged_mario_action_cell :
    forall m m',
      Mem.unchanged_on mario_block m m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Proof.
    intros m m' H.
    eapply Mem.unchanged_on_implies; [ exact H | ].
    intros b ofs Hc _. destruct Hc as [Hb _]. exact Hb.
  Qed.

  Lemma unchanged_mario_pos_y_cell :
    forall m m',
      Mem.unchanged_on mario_block m m' ->
      Mem.unchanged_on pos_y_cell m m'.
  Proof.
    intros m m' H.
    eapply Mem.unchanged_on_implies; [ exact H | ].
    intros b ofs Hc _. destruct Hc as [Hb _]. exact Hb.
  Qed.

  (* a mario_block-unchanged flank transports valid_block + action_sat
     (the action_sat leg is ActionValueFrame.action_sat_unchanged_on). *)
  Lemma flank_transfers_bundle :
    forall m m',
      Mem.unchanged_on mario_block m m' ->
      Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm.
  Proof.
    intros m m' Hu Hv Hsat. split.
    - eapply Mem.valid_block_unchanged_on; eauto.
    - eapply action_sat_unchanged_on;
        [ apply unchanged_mario_action_cell; exact Hu | exact Hv | exact Hsat ].
  Qed.

  (* ===================================================================== *)
  (* 4. THE GOAL-1 TRANSFER THEOREM: frame_step preserves the GOAL-1        *)
  (*    invariant bundle.  PROVED — the flanking segments' action-cell      *)
  (*    clauses transport action_sat (action_sat_unchanged_on), their       *)
  (*    nextblock monotonicity transports valid_block, the middle is        *)
  (*    GOAL-1's proved frame lemma (the Hmiddle row), and MWF crosses the  *)
  (*    flanks via the three OPEN rows above.                               *)
  (* ===================================================================== *)
  Theorem frame_step_preserves_mem_ok :
    forall m m',
      gplat_null m ->
      mem_ok m ->
      frame_step m m' ->
      mem_ok m'.
  Proof.
    intros m m' Hnull (Hv & Hsat & Hmwf)
           (m1 & m2 & m3 & Hplat & Hact & Hlvl & Hrest).
    (* --- seg_platform flank --- *)
    pose proof Hplat as Hplat0.
    destruct Hplat as [_ Hcond1].
    destruct (Hcond1 Hnull) as [Hunch1 Hnull1].
    destruct (flank_transfers_bundle m m1 Hunch1 Hv Hsat) as [Hv1 Hsat1].
    assert (Hmwf1 : MWF m1) by exact (Hmwf_platform m m1 Hnull Hplat0 Hmwf).
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
    (* --- seg_rest flank --- *)
    pose proof Hrest as Hrest0.
    destruct Hrest as [Hunch4 _].
    destruct (flank_transfers_bundle m3 m' Hunch4 Hv3 Hsat3) as [Hv4 Hsat4].
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
      gplat_null m ->
      mem_ok m ->
      y_le YMAX m ->
      frame_step m m' ->
      y_le YMAX m'.
  Proof.
    intros m m' HnoA Hnull (Hv & Hsat & Hmwf) Hy
           (m1 & m2 & m3 & Hplat & Hact & Hlvl & Hrest).
    (* --- seg_platform flank --- *)
    pose proof Hplat as Hplat0.
    destruct Hplat as [_ Hcond1].
    destruct (Hcond1 Hnull) as [Hunch1 Hnull1].
    destruct (flank_transfers_bundle m m1 Hunch1 Hv Hsat) as [Hv1 Hsat1].
    assert (Hmwf1 : MWF m1) by exact (Hmwf_platform m m1 Hnull Hplat0 Hmwf).
    assert (Hy1 : y_le YMAX m1).
    { eapply y_le_unchanged_on;
        [ apply unchanged_mario_pos_y_cell; exact Hunch1
        | exact Hv | exact Hy ]. }
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
    (* --- seg_rest flank --- *)
    destruct Hrest as [Hunch4 _].
    eapply y_le_unchanged_on;
      [ apply unchanged_mario_pos_y_cell; exact Hunch4
      | exact Hv3 | exact Hy3 ].
  Qed.

End CompositionFrame.

(* ======================================================================= *)
(* (* STATUS *)                                                             *)
(*                                                                          *)
(* COMPILES (all Qed, NO Admitted):                                         *)
(*   - mario_pos_offset_concrete : pos @ 60 in MarioState, vm-pinned from   *)
(*     mario.prog's composite env (so POSY = 64 is AST-grounded, not        *)
(*     bespoke).                                                            *)
(*   - the three segment specs (seg_platform_spec / seg_level_spec /        *)
(*     seg_rest_spec), gplat_null, frame_step (the plan-§0 existential      *)
(*     composition with seg_action := execute_mario_action_step_lp lp,      *)
(*     GOAL-1's frame verbatim), mem_ok (= mem_ok_lp's bundle shape),       *)
(*     y_le (concrete: Flocq B2R of the Mfloat32 at (bm, 64)).              *)
(*   - frame_step_preserves_mem_ok  — THE GOAL-1 TRANSFER THEOREM, proved   *)
(*     as composition glue (flanks: action_sat_unchanged_on +               *)
(*     valid_block_unchanged_on; middle: the Hmiddle row).                  *)
(*   - frame_step_keeps_y_le       — THE ONE-FRAME Y-THEOREM, proved as     *)
(*     glue over the two OPEN y-rows (flanks transport y_le; teleport       *)
(*     disjunct bounded by the census row).                                 *)
(*                                                                          *)
(* NO Admitted; the open surface is the named Hypothesis rows:              *)
(*   - Hmiddle        : NOT open — GOAL-1's frame_preserves_mem_ok_lp,      *)
(*                      proved in NoAImpliesNoFlyLinked; re-stated to       *)
(*                      avoid duplicating the capstone's residual plumbing  *)
(*                      in a sandbox.  Promotion wires the real lemma.      *)
(*   - Hnoa_of_mwf    : NOT open — the capstone's own row, PROVED at        *)
(*                      MWF_real (mwf_real_ctl).                            *)
(*   - Hmwf_platform  : OPEN — T1.  Discharge: strengthen the NULL branch   *)
(*                      of seg_platform_spec to m' = m (the early return    *)
(*                      at platform_displacement.c:174 is a full no-op),    *)
(*                      grounded by the T1 gMarioPlatform-NULL invariant.   *)
(*   - Hmwf_level     : OPEN — T4/boundary.  check_instant_warp is in the   *)
(*                      LINKED level_update TU: walkable with the GOAL-1    *)
(*                      walker kit, or killed by the WMotR census (no       *)
(*                      instant-warp regions).                              *)
(*   - Hmwf_rest      : OPEN — boundary.  Needs seg_rest_spec widened to    *)
(*                      "unchanged on the MWF-watched cells" (bc, oc0,      *)
(*                      stored globals) or stays the labeled non-Mario      *)
(*                      model boundary.                                     *)
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
(* lookup.  See the FLAG comment at the Variable.                           *)
(*                                                                          *)
(* WHAT T1/T2/T3/T4 MUST DELIVER (to discharge each admit-analogue):        *)
(*   T1 -> Hmwf_platform (+ the frame-to-frame gplat_null re-establishment: *)
(*         T0's theorems CONSUME gplat_null m but do not re-derive          *)
(*         gplat_null m'; seg_rest_spec carries the preservation clause,    *)
(*         and threading it through seg_action/seg_level — mario.prog       *)
(*         cannot even NAME gMarioPlatform, so a bplat-distinctness row     *)
(*         like the stored_globals pattern — is T1's remaining glue).       *)
(*   T2 -> the Flocq interval brick consumed inside Hseg_action_y.          *)
(*   T3 -> Hseg_action_y itself (the ballistic value walk).                 *)
(*   T4 -> Hteleport_y + Hmwf_level (census: WMotR instant-warp set).       *)
(* ======================================================================= *)
