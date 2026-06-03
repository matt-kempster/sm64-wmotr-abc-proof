(* The SEMANTIC A-gates -- branch-selection lemmas for the canonical
   clightgen'd gate shapes whose locations Taint.v's census pins down. Under
   the A-clear memory invariant, each gate PROVABLY takes its else branch, so
   no entry into the taint set T executes. SPINE-CONSUMED: the grounded
   capstone (NoAImpliesNoFlyLinked.noA_no_spawn_never_flying_real) uses
   ctl_a_clear / a_pressed_real / a_pressed_real_grounds_ctl as its concrete
   no-A input model. The gate THEOREMS below are consumed by the Phase-B
   discharge of the capstone residual Hreach_val (reach_value_preserves_
   reached not_tainted over lp_ge): when the per-body walk reaches a gate,
   they kill the THEN branch. *)
(* ====================================================================== *)
(* THE SEMANTIC A-GATES, over the linked program.                          *)
(*                                                                        *)
(* Taint.v shows (by reflexivity) that every entry into T sits under one   *)
(* of two canonical clightgen'd gate shapes:                               *)
(*                                                                        *)
(*  (input gate)  Sset t (m->input);                                       *)
(*                if (t & 2 /\* INPUT_A_PRESSED *\/) THEN else ELSE         *)
(*                -- act_in_cannon's cannon fire, the three                 *)
(*                   set_jump_from_landing call sites, and                  *)
(*                   common_landing_cancels' indirect setter call;          *)
(*                                                                        *)
(*  (ctl gate)    Sset t1 (m->controller);                                  *)
(*                Sset t2 (t1->buttonPressed);                              *)
(*                if (t2 & 0x8000 /\* A_BUTTON *\/) THEN else ELSE           *)
(*                -- the single INPUT_A_PRESSED-setting write in            *)
(*                   update_mario_button_inputs.                            *)
(*                                                                        *)
(* This file proves, over the abstract linked genv lp_ge (linkorder only;   *)
(* lp never computed), that under the corresponding A-clear MEMORY           *)
(* invariant each gate's execution provably goes through ELSE. The field    *)
(* geometry (input@2, controller@156, buttonPressed@18) is computed in      *)
(* mario.prog's OWN cenv and transferred to lp by linking metatheory --      *)
(* the same trust path as action@12.                                        *)
(* ====================================================================== *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  RealFrameValue RealFrameLinked.

(* ====================================================================== *)
(* Field geometry: concrete offsets in mario.prog's cenv (vm_compute).     *)
(* ====================================================================== *)

Lemma mario_input_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._input mario_state_members
    = OK (2, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_controller_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._controller mario_state_members
    = OK (156, Full).
Proof. vm_compute. reflexivity. Qed.

(* the Controller composite, from mario.prog's own cenv (same boolean-probe
   pattern as mario_defines_MarioState -- never read the composite back). *)
Definition mario_controller_members : members :=
  match (prog_comp_env mario.prog) ! mario._Controller with
  | Some co => co_members co
  | None => nil
  end.

Lemma mario_controller_members_complete :
  complete_members (prog_comp_env mario.prog) mario_controller_members = true.
Proof. vm_compute. reflexivity. Qed.

Lemma mario_buttonPressed_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._buttonPressed mario_controller_members
    = OK (18, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_Controller_isSome :
  match (prog_comp_env mario.prog) ! mario._Controller with
  | Some _ => true | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma mario_defines_Controller :
  exists co, (prog_comp_env mario.prog) ! mario._Controller = Some co.
Proof.
  pose proof mario_Controller_isSome as H.
  destruct ((prog_comp_env mario.prog) ! mario._Controller) as [co|].
  - exists co; reflexivity.
  - cbn in H; discriminate H.
Qed.

(* ====================================================================== *)
(* The A-clear MEMORY invariants (the concrete no-A facts).                *)
(* ====================================================================== *)

(* "Mario's input halfword has INPUT_A_PRESSED clear" -- the mid-frame
   invariant the handler gates consume (established by update_mario_inputs'
   zeroing + the gated/A-clear writes; Taint.v's input census). *)
Definition input_a_clear (m : mem) (bm : block) : Prop :=
  forall v, Mem.load Mint16unsigned m bm 2 = Some (Vint v) ->
            Int.and v (Int.repr 2) = Int.zero.

(* "the controller's buttonPressed halfword has A_BUTTON clear" -- the
   frame-boundary invariant (the player did not press A this frame). *)
Definition ctl_a_clear (m : mem) (bm : block) : Prop :=
  forall bc oc v,
    Mem.load Mptr m bm 156 = Some (Vptr bc oc) ->
    Mem.load Mint16unsigned m bc
      (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) = Some (Vint v) ->
    Int.and v (Int.repr 32768) = Int.zero.

(* THE CONCRETE "did the player press A this frame" reading of a memory:
   chase Mario's controller pointer and test buttonPressed & A_BUTTON --
   the boolean the grounded capstone uses as its per-frame input.
   PESSIMISTIC: an unreadable controller counts as PRESSED, so the no-A
   run hypothesis can only get stronger, never silently vacuous. *)
Definition a_pressed_real (bm : block) (m : mem) : bool :=
  match Mem.load Mptr m bm 156 with
  | Some (Vptr bc oc) =>
      match Mem.load Mint16unsigned m bc
              (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) with
      | Some (Vint v) => negb (Int.eq (Int.and v (Int.repr 32768)) Int.zero)
      | _ => true
      end
  | _ => true
  end.

(* the input grounding: an A-silent frame start satisfies the concrete
   controller invariant. This is what discharges the capstone's
   input_grounds_noA residual at the grounded instantiation. *)
Lemma a_pressed_real_grounds_ctl :
  forall bm m, a_pressed_real bm m = false -> ctl_a_clear m bm.
Proof.
  intros bm m Ha bc oc v Hl1 Hl2.
  unfold a_pressed_real in Ha. rewrite Hl1, Hl2 in Ha.
  destruct (Int.eq (Int.and v (Int.repr 32768)) Int.zero) eqn:E; cbn in Ha.
  - apply Int.same_if_eq in E. exact E.
  - discriminate Ha.
Qed.

Section AGatesLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* ---- the load-eval inversion bricks (mirrors of eval_marioObj_off_bm_lp,
     at the input / controller / buttonPressed fields). ---- *)

  Lemma eval_input_load_bm_lp :
    forall stid e le m bm v,
      le ! stid = Some (Vptr bm Ptrofs.zero) ->
      eval_expr (lp_ge lp) e le m
        (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                        (Tstruct mario._MarioState noattr))
                mario._input tushort) v ->
      Mem.load Mint16unsigned m bm 2 = Some v.
  Proof.
    intros stid e le m bm v Hle Hev.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
    apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    rewrite Hle in Hlvb. inv Hlvb.
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate ].
    cbn in Hty; inv Hty.
    change (genv_cenv (lp_ge lp)) with (prog_comp_env lp) in Hco, Hfo2.
    destruct (RealFrameLinked.mario_defines_MarioState) as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState co0 LO_mario Hmar)
      as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog mario._input (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite <- Hmm in Hfo2. rewrite mario_input_offset_concrete in Hfo2. inv Hfo2.
    rewrite Ptrofs.add_zero_l in Hderef.
    inv Hderef;
      try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
      try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
      match goal with
      | Hac : access_mode _ = By_value ?chunk, Hlv3 : Mem.loadv ?chunk _ _ = Some v |- _ =>
          cbn in Hac; inv Hac;
          change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in Hlv3; exact Hlv3
      end.
  Qed.

  Lemma eval_controller_load_bm_lp :
    forall stid e le m bm v,
      le ! stid = Some (Vptr bm Ptrofs.zero) ->
      eval_expr (lp_ge lp) e le m
        (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                        (Tstruct mario._MarioState noattr))
                mario._controller (tptr (Tstruct mario._Controller noattr))) v ->
      Mem.load Mptr m bm 156 = Some v.
  Proof.
    intros stid e le m bm v Hle Hev.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
    apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    rewrite Hle in Hlvb. inv Hlvb.
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate ].
    cbn in Hty; inv Hty.
    change (genv_cenv (lp_ge lp)) with (prog_comp_env lp) in Hco, Hfo2.
    destruct (RealFrameLinked.mario_defines_MarioState) as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState co0 LO_mario Hmar)
      as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog mario._controller (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite <- Hmm in Hfo2. rewrite mario_controller_offset_concrete in Hfo2. inv Hfo2.
    rewrite Ptrofs.add_zero_l in Hderef.
    inv Hderef;
      try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
      try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
      match goal with
      | Hac : access_mode _ = By_value ?chunk, Hlv3 : Mem.loadv ?chunk _ _ = Some v |- _ =>
          cbn in Hac; inv Hac;
          change (Ptrofs.unsigned (Ptrofs.repr 156)) with 156 in Hlv3; exact Hlv3
      end.
  Qed.

  Lemma eval_buttonPressed_load_lp :
    forall t1id e le m bc oc v,
      le ! t1id = Some (Vptr bc oc) ->
      eval_expr (lp_ge lp) e le m
        (Efield (Ederef (Etempvar t1id (tptr (Tstruct mario._Controller noattr)))
                        (Tstruct mario._Controller noattr))
                mario._buttonPressed tushort) v ->
      Mem.load Mint16unsigned m bc
        (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) = Some v.
  Proof.
    intros t1id e le m bc oc v Hle Hev.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
    apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    rewrite Hle in Hlvb. inv Hlvb.
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate ].
    cbn in Hty; inv Hty.
    change (genv_cenv (lp_ge lp)) with (prog_comp_env lp) in Hco, Hfo2.
    destruct mario_defines_Controller as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._Controller co0 LO_mario Hmar)
      as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_controller_members = co_members co)
      by (unfold mario_controller_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog mario._buttonPressed (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_controller_members_complete ].
    rewrite <- Hmm in Hfo2. rewrite mario_buttonPressed_offset_concrete in Hfo2. inv Hfo2.

    inv Hderef;
      try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
      try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
      match goal with
      | Hac : access_mode _ = By_value ?chunk, Hlv3 : Mem.loadv ?chunk _ _ = Some v |- _ =>
          cbn in Hac; inv Hac; exact Hlv3
      end.
  Qed.

  (* ---- guard bricks: the `t & mask` guard forces the temp to hold a Vint
     and pins its evaluated value; an AND-zero value makes bool_val false. ---- *)
  Lemma guard_temp_vint :
    forall t6 (mask : Z) e le m v1,
      eval_expr (lp_ge lp) e le m
        (Ebinop Oand (Etempvar t6 tushort) (Econst_int (Int.repr mask) tint) tint) v1 ->
      exists vi, le ! t6 = Some (Vint vi) /\ v1 = Vint (Int.and vi (Int.repr mask)).
  Proof.
    intros t6 mask e le m v1 Hev.
    inv Hev.
    - (* eval_Ebinop *)
      match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?vv |- _ =>
        apply eval_expr_Etempvar_val in H; rename H into Hle6 end.
      match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H end.
      + match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some v1 |- _ =>
          unfold sem_binary_operation, sem_and, sem_binarith, sem_cast in H;
          match goal with HH : le ! t6 = Some ?va |- _ =>
            destruct va;
            cbn [classify_binarith binarith_type classify_cast cast_int_int] in H;
            try discriminate H end;
          inv H end.
        eexists; split; [ exact Hle6 | reflexivity ].
      + match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end.
    - (* eval_Elvalue on a binop: impossible *)
      match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end.
  Qed.

  Lemma bool_val_and_zero :
    forall vi (mask : Z) m b,
      Int.and vi (Int.repr mask) = Int.zero ->
      bool_val (Vint (Int.and vi (Int.repr mask))) tint m = Some b ->
      b = false.
  Proof.
    intros vi mask m b Hand Hbv.
    unfold bool_val in Hbv; cbn [classify_bool] in Hbv.
    rewrite Hand in Hbv. rewrite Int.eq_true in Hbv.
    inv Hbv. reflexivity.
  Qed.

  (* an Efield-through-Ederef load forces the base temp to hold a pointer. *)
  Lemma efield_base_vptr :
    forall t1id cid fldid fldty e le m v,
      eval_expr (lp_ge lp) e le m
        (Efield (Ederef (Etempvar t1id (tptr (Tstruct cid noattr)))
                        (Tstruct cid noattr)) fldid fldty) v ->
      exists bc oc, le ! t1id = Some (Vptr bc oc).
  Proof.
    intros t1id cid fldid fldty e le m v Hev.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & _).
    apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & _).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    eauto.
  Qed.

  (* ================================================================== *)
  (* GATE LEMMA 1 (the input A-gate): under input_a_clear, the canonical *)
  (* `Sset t (m->input); if (t & 2) THEN else ELSE` provably executes     *)
  (* ELSE. This is the semantic A-gate at act_in_cannon's cannon fire,    *)
  (* the three set_jump_from_landing call sites, and                      *)
  (* common_landing_cancels' indirect setter call (Taint.v pins those     *)
  (* shapes).                                                             *)
  (* ================================================================== *)
  Theorem input_a_gate_takes_else_lp :
    forall mptr t6 THEN ELSE e le m bm tr le' m' out,
      le ! mptr = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Ssequence
           (Sset t6 (Efield (Ederef (Etempvar mptr (tptr (Tstruct mario._MarioState noattr)))
                                    (Tstruct mario._MarioState noattr))
                            mario._input tushort))
           (Sifthenelse (Ebinop Oand (Etempvar t6 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              THEN ELSE))
        tr le' m' out ->
      exists vi,
        Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
        Int.and vi (Int.repr 2) = Int.zero /\
        exec_stmt function_entry2 (lp_ge lp) e (PTree.set t6 (Vint vi) le) m
          ELSE tr le' m' out.
  Proof.
    intros mptr t6 THEN ELSE e le m bm tr le' m' out Hle Hclear Hexec.
    inv Hexec.
    2: { match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
         match goal with H : Out_normal <> Out_normal |- _ =>
           contradiction H; reflexivity end. }
    match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Efield _ _ _) ?vv |- _ =>
      pose proof (eval_input_load_bm_lp _ _ _ _ _ vv Hle H) as Hload end.
    match goal with H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : exec_stmt _ _ _ _ _ (if _ then THEN else ELSE) _ _ _ _ |- _ =>
      rename H into Hbr end.
    match goal with H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply guard_temp_vint in H as (vi & Hle6 & ->) end.
    rewrite PTree.gss in Hle6. inv Hle6.
    pose proof (Hclear vi Hload) as Hand.
    match goal with H : bool_val _ _ _ = Some ?bb |- _ =>
      cbn [typeof] in H;
      pose proof (bool_val_and_zero vi 2 _ bb Hand H) as Hb end.
    subst.
    exists vi. split; [ exact Hload | ]. split; [ exact Hand | ].
    exact Hbr.
  Qed.

  (* ================================================================== *)
  (* GATE LEMMA 2 (the controller A-gate): under ctl_a_clear, the         *)
  (* canonical `Sset t1 (m->controller); Sset t2 (t1->buttonPressed);     *)
  (* if (t2 & 0x8000) THEN else ELSE` provably executes ELSE. This is the *)
  (* gate guarding the single INPUT_A_PRESSED-setting write in            *)
  (* update_mario_button_inputs.                                          *)
  (* ================================================================== *)
  Theorem ctl_a_gate_takes_else_lp :
    forall mptr t1 t2 THEN ELSE e le m bm tr le' m' out,
      le ! mptr = Some (Vptr bm Ptrofs.zero) ->
      ctl_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Ssequence
           (Sset t1 (Efield (Ederef (Etempvar mptr (tptr (Tstruct mario._MarioState noattr)))
                                    (Tstruct mario._MarioState noattr))
                            mario._controller (tptr (Tstruct mario._Controller noattr))))
           (Ssequence
              (Sset t2 (Efield (Ederef (Etempvar t1 (tptr (Tstruct mario._Controller noattr)))
                                       (Tstruct mario._Controller noattr))
                               mario._buttonPressed tushort))
              (Sifthenelse (Ebinop Oand (Etempvar t2 tushort)
                              (Econst_int (Int.repr 32768) tint) tint)
                 THEN ELSE)))
        tr le' m' out ->
      exists bc oc vi,
        Mem.load Mptr m bm 156 = Some (Vptr bc oc) /\
        Mem.load Mint16unsigned m bc
          (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) = Some (Vint vi) /\
        Int.and vi (Int.repr 32768) = Int.zero /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set t2 (Vint vi) (PTree.set t1 (Vptr bc oc) le)) m
          ELSE tr le' m' out.
  Proof.
    intros mptr t1 t2 THEN ELSE e le m bm tr le' m' out Hle Hclear Hexec.
    inv Hexec.
    2: { match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
         match goal with H : Out_normal <> Out_normal |- _ =>
           contradiction H; reflexivity end. }
    (* first Sset: t1 := m->controller *)
    match goal with H : exec_stmt _ _ _ _ _ (Sset t1 _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Efield _ mario._controller _) ?vv |- _ =>
      pose proof (eval_controller_load_bm_lp _ _ _ _ _ vv Hle H) as Hldctl end.
    (* second layer: Ssequence (Sset t2 ...) (Sifthenelse ...) *)
    match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset t2 _) _) _ _ _ _ |- _ =>
      inv H end.
    2: { match goal with H : exec_stmt _ _ _ _ _ (Sset t2 _) _ _ _ _ |- _ => inv H end.
         match goal with H : Out_normal <> Out_normal |- _ =>
           contradiction H; reflexivity end. }
    (* second Sset: t2 := t1->buttonPressed; its eval forces t1's value Vptr *)
    match goal with H : exec_stmt _ _ _ _ _ (Sset t2 _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Efield _ mario._buttonPressed _) _ |- _ =>
      pose proof H as Hevbp;
      apply efield_base_vptr in H as (bc & oc & Hle1) end.
    rewrite PTree.gss in Hle1. inv Hle1.
    pose proof (eval_buttonPressed_load_lp t1 _ _ _ bc oc _ (PTree.gss _ _ _) Hevbp) as Hldbp.
    (* the if *)
    match goal with H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : exec_stmt _ _ _ _ _ (if _ then THEN else ELSE) _ _ _ _ |- _ =>
      rename H into Hbr end.
    match goal with H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply guard_temp_vint in H as (vi & Hle2 & ->) end.
    rewrite PTree.gss in Hle2. inv Hle2.
    pose proof (Hclear bc oc vi Hldctl Hldbp) as Hand.
    match goal with H : bool_val _ _ _ = Some ?bb |- _ =>
      cbn [typeof] in H;
      pose proof (bool_val_and_zero vi 32768 _ bb Hand H) as Hb end.
    subst.
    exists bc, oc, vi.
    split; [ exact Hldctl | ]. split; [ exact Hldbp | ]. split; [ exact Hand | ].
    exact Hbr.
  Qed.

End AGatesLp.
