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
(*                                                                        *)
(* It also proves the third, VALUE-driven gate -- THE DISPATCH KILL (end    *)
(* of file): the airborne action dispatcher's `Sset t (m->action);          *)
(* Sswitch t` under the carried invariant action_sat not_tainted provably   *)
(* never selects the T-labeled case arms, so the bodies of act_flying,      *)
(* act_flying_triple_jump and act_shot_from_cannon are DEAD CODE under      *)
(* no-A. This is the invariant-aware switch rule (the restatement of the    *)
(* H1 engine leaf HCsw) at the one switch where all three T labels live.    *)
(* ====================================================================== *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario.
From SM64.Generated Require mario_actions_airborne.
From SM64.Generated Require mario_actions_automatic.
From SM64.Generated Require mario_actions_stationary.
From SM64.Generated Require mario_actions_moving.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked.

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

(* ====================================================================== *)
(* THE DISPATCH KILL (the airborne action switch).                        *)
(*                                                                        *)
(* mario_execute_airborne_action dispatches `switch (m->action)`; the     *)
(* clightgen'd shape is the value-gate sibling of the A-gates above:      *)
(*                                                                        *)
(*   Sset _t'46 (m->action); Sswitch (Etempvar _t'46) CASES               *)
(*                                                                        *)
(* All three T labels live in this one switch:                            *)
(*   277350553 (ACT_FLYING)             -> act_flying                      *)
(*   50333844  (ACT_FLYING_TRIPLE_JUMP) -> act_flying_triple_jump          *)
(*   8915096   (ACT_SHOT_FROM_CANNON)   -> act_shot_from_cannon            *)
(*                                                                        *)
(* Under the carried run invariant action_sat not_tainted, the loaded     *)
(* selector provably avoids all three labels, CompCert's select_switch    *)
(* lands on a non-T arm (or no arm at all -- the switch has no default),  *)
(* and -- because every arm ends in Sbreak -- the fall-through tail is     *)
(* dead too: the WHOLE switch execution is the execution of ONE arm that  *)
(* calls none of the three handlers. act_flying's body is dead code.      *)
(*                                                                        *)
(* This is the invariant-aware switch rule (the engine-v2 restatement of  *)
(* H1's leaf HCsw, docs/open-hypothesis-surface.html SS5 #20), proved at   *)
(* the dispatcher it matters for. PIPELINE: the dispatch statement and    *)
(* the case list are PROJECTED from the generated AST, never hand-written; *)
(* the censuses over them are reflexivity facts with positive controls.   *)
(* ====================================================================== *)

(* ---- the dispatcher fragment, BY PROJECTION from the generated AST.
   The body is Sseq(cancel-check, Sseq(far-fall-sound, Sseq(DISPATCH, return))):
   we project the third element and pin its shape by reflexivity below. ---- *)
Definition third_seq (s : statement) : statement :=
  match s with
  | Ssequence _ (Ssequence _ (Ssequence d _)) => d
  | _ => Sskip
  end.

Definition airborne_dispatch_stmt : statement :=
  third_seq (fn_body mario_actions_airborne.f_mario_execute_airborne_action).

Definition airborne_cases : labeled_statements :=
  match airborne_dispatch_stmt with
  | Ssequence _ (Sswitch _ ls) => ls
  | _ => LSnil
  end.

(* shape pin: the projected fragment IS the canonical value-gate shape.
   (mario.* and mario_actions_airborne.* idents agree -- clightgen derives
   them from the source strings -- so the brick vocabulary applies as-is.) *)
Example airborne_dispatch_shape :
  airborne_dispatch_stmt =
  Ssequence
    (Sset mario_actions_airborne._t'46
       (Efield (Ederef (Etempvar mario_actions_airborne._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._action tuint))
    (Sswitch (Etempvar mario_actions_airborne._t'46 tuint) airborne_cases).
Proof. vm_compute. reflexivity. Qed.

(* ---- the T labels and the per-arm checks (booleans over the literal AST). ---- *)

Definition is_T_label (c : Z) : bool :=
  Z.eqb c 277350553 || Z.eqb c 50333844 || Z.eqb c 8915096.

Definition is_T_handler (i : ident) : bool :=
  Pos.eqb i mario_actions_airborne._act_flying
  || Pos.eqb i mario_actions_airborne._act_flying_triple_jump
  || Pos.eqb i mario_actions_airborne._act_shot_from_cannon.

(* does a statement contain ANY call to a T handler? (indirect calls count
   as dangerous -- conservative; the dispatcher has none). *)
Fixpoint calls_T_handler (s : statement) : bool :=
  match s with
  | Scall _ (Evar f _) _ => is_T_handler f
  | Scall _ _ _ => true
  | Ssequence s1 s2 => calls_T_handler s1 || calls_T_handler s2
  | Sifthenelse _ s1 s2 => calls_T_handler s1 || calls_T_handler s2
  | Sloop s1 s2 => calls_T_handler s1 || calls_T_handler s2
  | Slabel _ s1 => calls_T_handler s1
  | Sswitch _ ls => calls_T_handler_ls ls
  | _ => false
  end
with calls_T_handler_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => false
  | LScons _ s rest => calls_T_handler s || calls_T_handler_ls rest
  end.

(* an arm that ends in Sbreak: its big-step outcome is never Out_normal,
   so the switch's textual fall-through tail is provably dead. *)
Definition ends_in_break (s : statement) : bool :=
  match s with
  | Ssequence _ Sbreak => true
  | Sbreak => true
  | _ => false
  end.

Definition arm_ok (s : statement) : bool :=
  negb (calls_T_handler s) && ends_in_break s.

(* C fall-through: a `case X:` with an EMPTY arm (Sskip) falls into the next
   case (the dispatcher really has one: case 42010778 falls into the
   act_riding_shell_air arm at 8456347). Semantically a leading Sskip arm is
   a no-op -- exec_seq_drop_skips below -- so the right per-selection check is
   on the suffix AFTER dropping leading skips: the first REAL arm must pass
   arm_ok (and a skipped Sskip trivially calls no T handler). *)
Fixpoint drop_skips (sl : labeled_statements) : labeled_statements :=
  match sl with
  | LScons o s rest => match s with Sskip => drop_skips rest | _ => sl end
  | LSnil => LSnil
  end.

Definition head_arm_ok (ok : statement -> bool) (sl : labeled_statements) : bool :=
  match sl with LSnil => true | LScons _ s _ => ok s end.

(* the per-selection check: after the skips, the first real arm is ok
   (no arm at all -- all skips / ran off the end -- is fine: nothing runs). *)
Definition suffix_ok (sl : labeled_statements) : bool :=
  head_arm_ok arm_ok (drop_skips sl).

Lemma suffix_ok_LSnil : suffix_ok LSnil = true.
Proof. reflexivity. Qed.

(* the case census: every suffix a non-T selector can land on passes ok.
   (T-labeled positions are exempt -- a not_tainted selector cannot match
   them; None-labeled (default) positions are always selectable, so always
   checked.) *)
Fixpoint nonT_suffixes_ok (ok : labeled_statements -> bool) (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons None s rest => ok (LScons None s rest) && nonT_suffixes_ok ok rest
  | LScons (Some c) s rest =>
      (if is_T_label c then true else ok (LScons (Some c) s rest))
      && nonT_suffixes_ok ok rest
  end.

(* ---- the reflexivity censuses over the REAL case list. ---- *)

(* every suffix of the airborne dispatch selectable by a non-T selector
   resolves (through the skips) to an arm that calls no T handler and ends
   in Sbreak. *)
Example airborne_nonT_suffixes_ok : nonT_suffixes_ok suffix_ok airborne_cases = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL 1: the walker is not blind -- selecting a T label lands
   on an arm that DOES call its T handler. *)
Example airborne_T_arms_do_call :
  ( head_arm_ok calls_T_handler (select_switch 277350553 airborne_cases)
  , head_arm_ok calls_T_handler (select_switch 50333844 airborne_cases)
  , head_arm_ok calls_T_handler (select_switch 8915096 airborne_cases) )
  = (true, true, true).
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL 2: the census is not vacuous -- it really checks the
   non-T suffixes (an always-false ok fails it). *)
Example airborne_census_not_vacuous :
  nonT_suffixes_ok (fun _ => false) airborne_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL 3: the fall-through machinery is load-bearing -- the
   head-only check FAILS at the real Sskip case (42010778) and the
   skip-dropping suffix check passes it. *)
Example airborne_fallthrough_case :
  ( head_arm_ok arm_ok (select_switch 42010778 airborne_cases)
  , suffix_ok (select_switch 42010778 airborne_cases) )
  = (false, true).
Proof. vm_compute. reflexivity. Qed.

(* ---- the generic selection lemmas (CompCert select_switch vs the census).
   Reusable for every dispatcher; nothing airborne-specific below. ---- *)

Lemma select_switch_case_nonT_ok :
  forall (ok : labeled_statements -> bool) n sl sl',
    nonT_suffixes_ok ok sl = true -> is_T_label n = false ->
    select_switch_case n sl = Some sl' ->
    ok sl' = true.
Proof.
  intros ok n sl; induction sl as [| o s rest IH]; cbn; intros sl' Hc Hn Hsel.
  - discriminate.
  - destruct o as [c|].
    + apply andb_prop in Hc as [Hc1 Hc2].
      destruct (zeq c n) as [e|ne].
      * inv Hsel. rewrite Hn in Hc1. exact Hc1.
      * apply IH; assumption.
    + apply andb_prop in Hc as [Hc1 Hc2]. apply IH; assumption.
Qed.

Lemma select_switch_default_nonT_ok :
  forall (ok : labeled_statements -> bool) sl,
    nonT_suffixes_ok ok sl = true -> ok LSnil = true ->
    ok (select_switch_default sl) = true.
Proof.
  intros ok sl; induction sl as [| o s rest IH]; cbn; intros Hc Hnil.
  - exact Hnil.
  - destruct o as [c|]; apply andb_prop in Hc as [Hc1 Hc2].
    + apply IH; assumption.
    + exact Hc1.
Qed.

Lemma select_switch_nonT_ok :
  forall (ok : labeled_statements -> bool) n sl,
    nonT_suffixes_ok ok sl = true -> is_T_label n = false -> ok LSnil = true ->
    ok (select_switch n sl) = true.
Proof.
  intros ok n sl Hc Hn Hnil. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply select_switch_case_nonT_ok; eauto.
  - apply select_switch_default_nonT_ok; assumption.
Qed.

(* ---- not_tainted excludes the three labels (int -> Z bridge). ---- *)

Lemma int_eq_false_unsigned_neq :
  forall v (k : Z),
    Int.eq v (Int.repr k) = false -> Z.eqb (Int.unsigned v) k = false.
Proof.
  intros v k He. apply Z.eqb_neq. intros Hk.
  rewrite <- Hk in He. rewrite Int.repr_unsigned in He.
  rewrite Int.eq_true in He. discriminate.
Qed.

Lemma not_tainted_not_T_label :
  forall v, not_tainted v -> is_T_label (Int.unsigned v) = false.
Proof.
  intros v Hnt.
  unfold not_tainted, is_tainted, is_flying_int in Hnt.
  apply orb_false_iff in Hnt as [Hfl Hcan].
  apply orb_false_iff in Hfl as [Hf Hftj].
  unfold is_T_label.
  rewrite (int_eq_false_unsigned_neq v 277350553 Hf).
  rewrite (int_eq_false_unsigned_neq v 50333844 Hftj).
  rewrite (int_eq_false_unsigned_neq v 8915096 Hcan).
  reflexivity.
Qed.

Section DispatchKillLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* the action-load inversion brick: the value-gate's Sset RHS loads the
     real action cell (offset 12, pinned in mario.prog's cenv, transferred
     to lp by linking metatheory -- the same trust path as the A-gates'). *)
  Lemma eval_action_load_bm_lp :
    forall stid e le m bm v,
      le ! stid = Some (Vptr bm Ptrofs.zero) ->
      eval_expr (lp_ge lp) e le m
        (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                        (Tstruct mario._MarioState noattr))
                mario._action tuint) v ->
      Mem.load Mint32 m bm 12 = Some v.
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
    rewrite (linkorder_field_offset_agree lp mario.prog mario._action (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite <- Hmm in Hfo2. rewrite mario_action_offset_concrete in Hfo2. inv Hfo2.
    rewrite Ptrofs.add_zero_l in Hderef.
    inv Hderef;
      try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
      try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
      match goal with
      | Hac : access_mode _ = By_value ?chunk, Hlv3 : Mem.loadv ?chunk _ _ = Some v |- _ =>
          cbn in Hac; inv Hac;
          change (Ptrofs.unsigned (Ptrofs.repr 12)) with 12 in Hlv3; exact Hlv3
      end.
  Qed.

  (* a break-terminated arm never finishes Out_normal, so the textual
     fall-through tail after the selected arm is dead. *)
  Lemma ends_in_break_not_normal :
    forall e le m s t le' m' out,
      ends_in_break s = true ->
      exec_stmt function_entry2 (lp_ge lp) e le m s t le' m' out ->
      out <> Out_normal.
  Proof.
    intros e le m s t le' m' out Hb Hexec.
    destruct s; try discriminate Hb.
    - (* Ssequence _ Sbreak *)
      destruct s2; try discriminate Hb.
      inv Hexec.
      + match goal with H : exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ => inv H end.
        discriminate.
      + assumption.
    - (* Sbreak *)
      inv Hexec. discriminate.
  Qed.

  (* leading Sskip arms (C fall-through labels) are semantic no-ops: the
     execution of a case suffix IS the execution of the suffix with the
     skips dropped. *)
  Lemma exec_seq_drop_skips :
    forall sl e le m t le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m
        (seq_of_labeled_statement sl) t le' m' out ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (seq_of_labeled_statement (drop_skips sl)) t le' m' out.
  Proof.
    induction sl as [| o s rest IH]; intros e le m t le' m' out Hexec.
    - exact Hexec.
    - destruct s; try exact Hexec.
      (* s = Sskip *)
      cbn in Hexec |- *.
      inv Hexec.
      + match goal with H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H end.
        apply IH. assumption.
      + match goal with H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H end.
        match goal with H : Out_normal <> Out_normal |- _ =>
          contradiction H; reflexivity end.
  Qed.

  (* ================================================================== *)
  (* THE DISPATCH KILL, selection form: under action_sat not_tainted the *)
  (* airborne dispatch executes the switch at a selector OUTSIDE T, and   *)
  (* the selected case suffix passes suffix_ok (through the skips, its    *)
  (* first real arm calls no T handler and ends in Sbreak). The           *)
  (* engine-facing dead-case rule.                                        *)
  (* ================================================================== *)
  Theorem airborne_dispatch_kill_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_airborne._m = Some (Vptr bm Ptrofs.zero) ->
      action_sat not_tainted m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m airborne_dispatch_stmt tr le' m' out ->
      exists v out1,
        Mem.load Mint32 m bm 12 = Some (Vint v) /\
        not_tainted v /\
        is_T_label (Int.unsigned v) = false /\
        suffix_ok (select_switch (Int.unsigned v) airborne_cases) = true /\
        out = outcome_switch out1 /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set mario_actions_airborne._t'46 (Vint v) le) m
          (seq_of_labeled_statement (select_switch (Int.unsigned v) airborne_cases))
          tr le' m' out1.
  Proof.
    intros e le m bm tr le' m' out Hle Hsat Hexec.
    rewrite airborne_dispatch_shape in Hexec.
    inv Hexec.
    2: { match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
         match goal with H : Out_normal <> Out_normal |- _ =>
           contradiction H; reflexivity end. }
    match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Efield _ _ _) ?vv |- _ =>
      pose proof (eval_action_load_bm_lp _ _ _ _ _ vv Hle H) as Hload end.
    match goal with H : exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in H; rename H into Hlet end.
    rewrite PTree.gss in Hlet.
    match goal with H : sem_switch_arg ?vv _ = Some _ |- _ =>
      unfold sem_switch_arg in H; cbn [classify_switch typeof] in H;
      destruct vv; try discriminate H; inv H end.
    inv Hlet.
    pose proof (Hsat _ Hload) as Hnt.
    pose proof (not_tainted_not_T_label _ Hnt) as Hlab.
    pose proof (select_switch_nonT_ok suffix_ok (Int.unsigned i) airborne_cases
                  airborne_nonT_suffixes_ok Hlab suffix_ok_LSnil) as Hok.
    eexists i, _.
    split; [ exact Hload | ].
    split; [ exact Hnt | ].
    split; [ exact Hlab | ].
    split; [ exact Hok | ].
    split; [ reflexivity | ].
    match goal with H : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ =>
      exact H end.
  Qed.

  (* ================================================================== *)
  (* THE DISPATCH KILL, headline form: every execution of the airborne   *)
  (* dispatch under no-A either runs NO real arm (no label matched -- the *)
  (* switch has no default -- or only empty fall-through labels), or      *)
  (* executes EXACTLY ONE real arm -- and that arm contains no call to    *)
  (* act_flying / act_flying_triple_jump / act_shot_from_cannon. Their    *)
  (* case arms -- the only sites invoking them in the dispatcher -- are    *)
  (* never entered: dead code under no-A.                                 *)
  (* ================================================================== *)
  Corollary airborne_dispatch_no_T_entry_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_airborne._m = Some (Vptr bm Ptrofs.zero) ->
      action_sat not_tainted m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m airborne_dispatch_stmt tr le' m' out ->
      exists v,
        Mem.load Mint32 m bm 12 = Some (Vint v) /\
        not_tainted v /\
        ( (* nothing real runs: the switch is a no-op *)
          ( drop_skips (select_switch (Int.unsigned v) airborne_cases) = LSnil /\
            le' = PTree.set mario_actions_airborne._t'46 (Vint v) le /\ m' = m )
          \/
          (* exactly one real arm runs, and it calls NO T handler *)
          exists o s_arm ls_tail out1,
            drop_skips (select_switch (Int.unsigned v) airborne_cases)
              = LScons o s_arm ls_tail /\
            calls_T_handler s_arm = false /\
            out1 <> Out_normal /\
            out = outcome_switch out1 /\
            exec_stmt function_entry2 (lp_ge lp) e
              (PTree.set mario_actions_airborne._t'46 (Vint v) le) m
              s_arm tr le' m' out1 ).
  Proof.
    intros e le m bm tr le' m' out Hle Hsat Hexec.
    destruct (airborne_dispatch_kill_lp e le m bm tr le' m' out Hle Hsat Hexec)
      as (v & out1 & Hload & Hnt & Hlab & Hok & Hout & Hrun).
    exists v. split; [ exact Hload | ]. split; [ exact Hnt | ].
    apply exec_seq_drop_skips in Hrun.
    unfold suffix_ok in Hok.
    destruct (drop_skips (select_switch (Int.unsigned v) airborne_cases))
      as [| o s_arm ls_tail] eqn:Esel.
    - (* LSnil: seq_of = Sskip *)
      left. cbn in Hrun. inv Hrun. auto.
    - (* LScons: Ssequence s_arm (fall-through tail) *)
      right.
      cbn in Hok. unfold arm_ok in Hok.
      apply andb_prop in Hok as [HnoT Hbrk].
      apply negb_true_iff in HnoT.
      cbn in Hrun.
      inv Hrun.
      + (* Sseq_1: the arm finished Out_normal -- impossible, it ends in Sbreak *)
        match goal with H : exec_stmt _ _ _ _ _ s_arm _ _ _ Out_normal |- _ =>
          pose proof (ends_in_break_not_normal _ _ _ _ _ _ _ _ Hbrk H) as Hcontra end.
        contradiction Hcontra; reflexivity.
      + (* Sseq_2: only the arm ran; the tail is dead *)
        exists o, s_arm, ls_tail, out1.
        split; [ reflexivity | ].
        split; [ exact HnoT | ].
        split; [ assumption | ].
        (* inv's global subst consumed Hout (out := outcome_switch out1),
           so the outcome conjunct is now reflexive. *)
        split; [ reflexivity | ].
        assumption.
  Qed.

End DispatchKillLp.

(* ====================================================================== *)
(* THE CANNON-FIRE KILL (act_in_cannon's gated fire).                      *)
(*                                                                        *)
(* act_in_cannon fires the cannon -- set_mario_action(m, 0x880898, 0),     *)
(* THE edge that forces the taint set to strictly contain the flying set   *)
(* -- only inside the canonical input A-gate `if (m->input & 2)`. Under    *)
(* input_a_clear the gate provably takes ELSE (input_a_gate_takes_else_lp) *)
(* and the censuses pin: the function body contains exactly ONE tainted    *)
(* feed, it lives in this gate's THEN, and the executed ELSE has none.     *)
(* The cannon never fires on an A-silent frame.                            *)
(*                                                                        *)
(* The gate is located by a generic FINDER over the generated AST (the     *)
(* first canonical input gate whose THEN contains the danger), reusable    *)
(* for the remaining gated feeders (set_jump_from_landing's callers,       *)
(* common_landing_cancels' indirect site).                                 *)
(* ====================================================================== *)

(* ---- generic danger walkers (any statement-level boolean detector). ---- *)

Fixpoint has_danger (danger : statement -> bool) (s : statement) : bool :=
  danger s ||
  match s with
  | Ssequence s1 s2 => has_danger danger s1 || has_danger danger s2
  | Sifthenelse _ s1 s2 => has_danger danger s1 || has_danger danger s2
  | Sloop s1 s2 => has_danger danger s1 || has_danger danger s2
  | Slabel _ s1 => has_danger danger s1
  | Sswitch _ ls => has_danger_ls danger ls
  | _ => false
  end
with has_danger_ls (danger : statement -> bool) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => false
  | LScons _ s rest => has_danger danger s || has_danger_ls danger rest
  end.

Fixpoint count_danger (danger : statement -> bool) (s : statement) : nat :=
  ((if danger s then 1 else 0) +
   match s with
   | Ssequence s1 s2 => count_danger danger s1 + count_danger danger s2
   | Sifthenelse _ s1 s2 => count_danger danger s1 + count_danger danger s2
   | Sloop s1 s2 => count_danger danger s1 + count_danger danger s2
   | Slabel _ s1 => count_danger danger s1
   | Sswitch _ ls => count_danger_ls danger ls
   | _ => 0
   end)%nat
with count_danger_ls (danger : statement -> bool) (ls : labeled_statements) : nat :=
  match ls with
  | LSnil => 0%nat
  | LScons _ s rest => (count_danger danger s + count_danger_ls danger rest)%nat
  end.

(* ---- the gate finder: first canonical input A-gate (Taint.v's detectors:
   `Sset t (m->input); if (t & 2)`) whose THEN satisfies sel. ---- *)

Fixpoint find_input_gate (mptr : ident) (sel : statement -> bool) (s : statement)
  : option statement :=
  match s with
  | Ssequence (Sset t e) (Sifthenelse g s1 s2) =>
      if is_input_load mptr e && is_a_guard t g && sel s1 then Some s
      else match find_input_gate mptr sel s1 with
           | Some g' => Some g'
           | None => find_input_gate mptr sel s2
           end
  | Ssequence s1 s2 =>
      match find_input_gate mptr sel s1 with
      | Some g' => Some g'
      | None => find_input_gate mptr sel s2
      end
  | Sifthenelse _ s1 s2 =>
      match find_input_gate mptr sel s1 with
      | Some g' => Some g'
      | None => find_input_gate mptr sel s2
      end
  | Sloop s1 s2 =>
      match find_input_gate mptr sel s1 with
      | Some g' => Some g'
      | None => find_input_gate mptr sel s2
      end
  | Slabel _ s1 => find_input_gate mptr sel s1
  | Sswitch _ ls => find_input_gate_ls mptr sel ls
  | _ => None
  end
with find_input_gate_ls (mptr : ident) (sel : statement -> bool) (ls : labeled_statements)
  : option statement :=
  match ls with
  | LSnil => None
  | LScons _ s rest =>
      match find_input_gate mptr sel s with
      | Some g' => Some g'
      | None => find_input_gate_ls mptr sel rest
      end
  end.

(* ---- the cannon-fire gate, BY PROJECTION from the generated AST. ---- *)

Definition cannon_fire_gate : statement :=
  match find_input_gate mario_actions_automatic._m (has_danger tainted_feed)
          (fn_body mario_actions_automatic.f_act_in_cannon) with
  | Some g => g
  | None => Sskip
  end.

Definition cannon_fire_gate_temp : ident :=
  match cannon_fire_gate with Ssequence (Sset t _) _ => t | _ => 1%positive end.
Definition cannon_fire_gate_then : statement :=
  match cannon_fire_gate with Ssequence _ (Sifthenelse _ s1 _) => s1 | _ => Sbreak end.
Definition cannon_fire_gate_else : statement :=
  match cannon_fire_gate with Ssequence _ (Sifthenelse _ _ s2) => s2 | _ => Sbreak end.

(* shape pin: the found gate IS the canonical input A-gate shape the gate
   lemma quantifies over. *)
Example cannon_fire_gate_canonical :
  cannon_fire_gate =
  Ssequence
    (Sset cannon_fire_gate_temp
       (Efield (Ederef (Etempvar mario_actions_automatic._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar cannon_fire_gate_temp tushort)
                    (Econst_int (Int.repr 2) tint) tint)
       cannon_fire_gate_then cannon_fire_gate_else).
Proof. vm_compute. reflexivity. Qed.

(* THE PINNING CENSUS: act_in_cannon's body contains exactly ONE tainted
   feed (the fire), it lives in this gate's THEN, and the ELSE has none.
   (Taint.v's automatic-TU census already shows there is no other tainted
   feed anywhere in the TU, and no ungated one.) *)
Example cannon_fire_unique_and_gated :
  ( count_danger tainted_feed (fn_body mario_actions_automatic.f_act_in_cannon)
  , count_danger tainted_feed cannon_fire_gate_then
  , count_danger tainted_feed cannon_fire_gate_else )
  = (1%nat, 1%nat, 0%nat).
Proof. vm_compute. reflexivity. Qed.

Example cannon_fire_gate_else_clean :
  count_danger tainted_feed cannon_fire_gate_else = 0%nat.
Proof. vm_compute. reflexivity. Qed.

Section CannonKillLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* ================================================================== *)
  (* THE CANNON-FIRE KILL: on an A-silent frame (input_a_clear), any      *)
  (* execution of the fire gate takes ELSE -- which contains NO tainted   *)
  (* feed. The unique set_mario_action(m, ACT_SHOT_FROM_CANNON, 0) in     *)
  (* act_in_cannon (the THEN) never executes: the cannon never fires      *)
  (* without A.                                                           *)
  (* ================================================================== *)
  Theorem act_in_cannon_fire_dead_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_automatic._m = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m cannon_fire_gate tr le' m' out ->
      exists vi,
        Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
        Int.and vi (Int.repr 2) = Int.zero /\
        count_danger tainted_feed cannon_fire_gate_else = 0%nat /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set cannon_fire_gate_temp (Vint vi) le) m
          cannon_fire_gate_else tr le' m' out.
  Proof.
    intros e le m bm tr le' m' out Hle Hclear Hexec.
    rewrite cannon_fire_gate_canonical in Hexec.
    destruct (input_a_gate_takes_else_lp lp LO_mario
                mario_actions_automatic._m cannon_fire_gate_temp
                cannon_fire_gate_then cannon_fire_gate_else
                e le m bm tr le' m' out Hle Hclear Hexec)
      as (vi & Hload & Hand & Helse).
    exists vi.
    split; [ exact Hload | ].
    split; [ exact Hand | ].
    split; [ exact cannon_fire_gate_else_clean | ].
    exact Helse.
  Qed.

End CannonKillLp.

(* ====================================================================== *)
(* THE REMAINING GATED-FEEDER KILLS.                                       *)
(*                                                                        *)
(* Taint.v's census pins the complete in-frame T-feed surface beyond the   *)
(* cannon fire and the dispatcher-killed T-internal handlers:              *)
(*   - set_jump_from_landing (the FTJ feeder) is called from exactly 3     *)
(*     sites: check_common_landing_cancels (stationary), act_walking and   *)
(*     act_decelerating (moving) -- each under an input A-gate;             *)
(*   - set_triple_jump_action escapes as a funptr only into                *)
(*     common_landing_cancels' setAPressAction parameter, whose single     *)
(*     indirect call sits under an input A-gate.                           *)
(* Each site below: gate PROJECTED from the generated AST, shape pinned    *)
(* by reflexivity, census (the body's unique danger lives in THEN; ELSE    *)
(* clean), and the kill -- under input_a_clear the gate takes ELSE.        *)
(* ====================================================================== *)

(* ---- shared projections. ---- *)
Definition gate_of (mptr : ident) (danger : statement -> bool) (body : statement)
  : statement :=
  match find_input_gate mptr (has_danger danger) body with
  | Some g => g
  | None => Sskip
  end.
Definition gate_temp (g : statement) : ident :=
  match g with Ssequence (Sset t _) _ => t | _ => 1%positive end.
Definition gate_then (g : statement) : statement :=
  match g with Ssequence _ (Sifthenelse _ s1 _) => s1 | _ => Sbreak end.
Definition gate_else (g : statement) : statement :=
  match g with Ssequence _ (Sifthenelse _ _ s2) => s2 | _ => Sbreak end.

Definition sjfl_danger : statement -> bool :=
  calls_target mario._set_jump_from_landing.

(* ---- site 1: check_common_landing_cancels (stationary) -> sjfl. ---- *)
Definition cclc_gate : statement :=
  gate_of mario_actions_stationary._m sjfl_danger
    (fn_body mario_actions_stationary.f_check_common_landing_cancels).

Example cclc_gate_canonical :
  cclc_gate =
  Ssequence
    (Sset (gate_temp cclc_gate)
       (Efield (Ederef (Etempvar mario_actions_stationary._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar (gate_temp cclc_gate) tushort)
                    (Econst_int (Int.repr 2) tint) tint)
       (gate_then cclc_gate) (gate_else cclc_gate)).
Proof. vm_compute. reflexivity. Qed.

Example cclc_census :
  ( count_danger sjfl_danger
      (fn_body mario_actions_stationary.f_check_common_landing_cancels)
  , count_danger sjfl_danger (gate_then cclc_gate)
  , count_danger sjfl_danger (gate_else cclc_gate) )
  = (1%nat, 1%nat, 0%nat).
Proof. vm_compute. reflexivity. Qed.

(* ---- site 2: act_walking (moving) -> sjfl. ---- *)
Definition walking_gate : statement :=
  gate_of mario_actions_moving._m sjfl_danger
    (fn_body mario_actions_moving.f_act_walking).

Example walking_gate_canonical :
  walking_gate =
  Ssequence
    (Sset (gate_temp walking_gate)
       (Efield (Ederef (Etempvar mario_actions_moving._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar (gate_temp walking_gate) tushort)
                    (Econst_int (Int.repr 2) tint) tint)
       (gate_then walking_gate) (gate_else walking_gate)).
Proof. vm_compute. reflexivity. Qed.

Example walking_census :
  ( count_danger sjfl_danger (fn_body mario_actions_moving.f_act_walking)
  , count_danger sjfl_danger (gate_then walking_gate)
  , count_danger sjfl_danger (gate_else walking_gate) )
  = (1%nat, 1%nat, 0%nat).
Proof. vm_compute. reflexivity. Qed.

(* ---- site 3: act_decelerating (moving) -> sjfl. ---- *)
Definition decel_gate : statement :=
  gate_of mario_actions_moving._m sjfl_danger
    (fn_body mario_actions_moving.f_act_decelerating).

Example decel_gate_canonical :
  decel_gate =
  Ssequence
    (Sset (gate_temp decel_gate)
       (Efield (Ederef (Etempvar mario_actions_moving._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar (gate_temp decel_gate) tushort)
                    (Econst_int (Int.repr 2) tint) tint)
       (gate_then decel_gate) (gate_else decel_gate)).
Proof. vm_compute. reflexivity. Qed.

Example decel_census :
  ( count_danger sjfl_danger (fn_body mario_actions_moving.f_act_decelerating)
  , count_danger sjfl_danger (gate_then decel_gate)
  , count_danger sjfl_danger (gate_else decel_gate) )
  = (1%nat, 1%nat, 0%nat).
Proof. vm_compute. reflexivity. Qed.

(* ---- site 4: common_landing_cancels (moving) -- the ONE indirect call
   (the escaped set_triple_jump_action's unique sink). ---- *)
Definition clc_gate : statement :=
  gate_of mario_actions_moving._m indirect_call
    (fn_body mario_actions_moving.f_common_landing_cancels).

Example clc_gate_canonical :
  clc_gate =
  Ssequence
    (Sset (gate_temp clc_gate)
       (Efield (Ederef (Etempvar mario_actions_moving._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar (gate_temp clc_gate) tushort)
                    (Econst_int (Int.repr 2) tint) tint)
       (gate_then clc_gate) (gate_else clc_gate)).
Proof. vm_compute. reflexivity. Qed.

Example clc_census :
  ( count_danger indirect_call (fn_body mario_actions_moving.f_common_landing_cancels)
  , count_danger indirect_call (gate_then clc_gate)
  , count_danger indirect_call (gate_else clc_gate) )
  = (1%nat, 1%nat, 0%nat).
Proof. vm_compute. reflexivity. Qed.

Section GatedFeederKillsLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* generic: any projected gate that pins to the canonical shape (each
     site's *_gate_canonical Example) takes ELSE under input_a_clear. *)
  Lemma projected_gate_takes_else_lp :
    forall mptr g,
      g = Ssequence
            (Sset (gate_temp g)
               (Efield (Ederef (Etempvar mptr (tptr (Tstruct mario._MarioState noattr)))
                          (Tstruct mario._MarioState noattr))
                  mario._input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar (gate_temp g) tushort)
                            (Econst_int (Int.repr 2) tint) tint)
               (gate_then g) (gate_else g)) ->
      forall e le m bm tr le' m' out,
        le ! mptr = Some (Vptr bm Ptrofs.zero) ->
        input_a_clear m bm ->
        exec_stmt function_entry2 (lp_ge lp) e le m g tr le' m' out ->
        exists vi,
          Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
          Int.and vi (Int.repr 2) = Int.zero /\
          exec_stmt function_entry2 (lp_ge lp) e
            (PTree.set (gate_temp g) (Vint vi) le) m
            (gate_else g) tr le' m' out.
  Proof.
    intros mptr g Hshape e le m bm tr le' m' out Hle Hclear Hexec.
    rewrite Hshape in Hexec.
    exact (input_a_gate_takes_else_lp lp LO_mario mptr (gate_temp g)
             (gate_then g) (gate_else g) e le m bm tr le' m' out Hle Hclear Hexec).
  Qed.

  (* the four kills: on an A-silent frame each feeder gate takes its ELSE,
     which contains NO danger (the per-site census) -- the feeder call /
     indirect setter call never executes. *)

  Theorem cclc_sjfl_call_dead_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_stationary._m = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m cclc_gate tr le' m' out ->
      exists vi,
        Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
        Int.and vi (Int.repr 2) = Int.zero /\
        count_danger sjfl_danger (gate_else cclc_gate) = 0%nat /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set (gate_temp cclc_gate) (Vint vi) le) m
          (gate_else cclc_gate) tr le' m' out.
  Proof.
    intros e le m bm tr le' m' out Hle Hclear Hexec.
    destruct (projected_gate_takes_else_lp mario_actions_stationary._m cclc_gate
                cclc_gate_canonical e le m bm tr le' m' out Hle Hclear Hexec)
      as (vi & Hload & Hand & Helse).
    exists vi. split; [ exact Hload | ]. split; [ exact Hand | ].
    split; [ vm_compute; reflexivity | ]. exact Helse.
  Qed.

  Theorem act_walking_sjfl_call_dead_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_moving._m = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m walking_gate tr le' m' out ->
      exists vi,
        Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
        Int.and vi (Int.repr 2) = Int.zero /\
        count_danger sjfl_danger (gate_else walking_gate) = 0%nat /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set (gate_temp walking_gate) (Vint vi) le) m
          (gate_else walking_gate) tr le' m' out.
  Proof.
    intros e le m bm tr le' m' out Hle Hclear Hexec.
    destruct (projected_gate_takes_else_lp mario_actions_moving._m walking_gate
                walking_gate_canonical e le m bm tr le' m' out Hle Hclear Hexec)
      as (vi & Hload & Hand & Helse).
    exists vi. split; [ exact Hload | ]. split; [ exact Hand | ].
    split; [ vm_compute; reflexivity | ]. exact Helse.
  Qed.

  Theorem act_decelerating_sjfl_call_dead_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_moving._m = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m decel_gate tr le' m' out ->
      exists vi,
        Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
        Int.and vi (Int.repr 2) = Int.zero /\
        count_danger sjfl_danger (gate_else decel_gate) = 0%nat /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set (gate_temp decel_gate) (Vint vi) le) m
          (gate_else decel_gate) tr le' m' out.
  Proof.
    intros e le m bm tr le' m' out Hle Hclear Hexec.
    destruct (projected_gate_takes_else_lp mario_actions_moving._m decel_gate
                decel_gate_canonical e le m bm tr le' m' out Hle Hclear Hexec)
      as (vi & Hload & Hand & Helse).
    exists vi. split; [ exact Hload | ]. split; [ exact Hand | ].
    split; [ vm_compute; reflexivity | ]. exact Helse.
  Qed.

  Theorem clc_indirect_call_dead_lp :
    forall e le m bm tr le' m' out,
      le ! mario_actions_moving._m = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m clc_gate tr le' m' out ->
      exists vi,
        Mem.load Mint16unsigned m bm 2 = Some (Vint vi) /\
        Int.and vi (Int.repr 2) = Int.zero /\
        count_danger indirect_call (gate_else clc_gate) = 0%nat /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set (gate_temp clc_gate) (Vint vi) le) m
          (gate_else clc_gate) tr le' m' out.
  Proof.
    intros e le m bm tr le' m' out Hle Hclear Hexec.
    destruct (projected_gate_takes_else_lp mario_actions_moving._m clc_gate
                clc_gate_canonical e le m bm tr le' m' out Hle Hclear Hexec)
      as (vi & Hload & Hand & Helse).
    exists vi. split; [ exact Hload | ]. split; [ exact Hand | ].
    split; [ vm_compute; reflexivity | ]. exact Helse.
  Qed.

End GatedFeederKillsLp.

(* ====================================================================== *)
(* THE INPUT-WRITE KILL (update_mario_button_inputs' controller gate).     *)
(*                                                                        *)
(* Taint.v's input census: across ALL 12 TUs there is exactly ONE          *)
(* INPUT_A_PRESSED-setting write to m->input (a_unsafe_input_write) -- the *)
(* `m->input |= INPUT_A_PRESSED` in update_mario_button_inputs -- and it   *)
(* sits under the canonical controller A-gate                              *)
(* `if (m->controller->buttonPressed & A_BUTTON)`. Under ctl_a_clear (the  *)
(* capstone's frame-boundary no-A invariant) the gate provably takes ELSE: *)
(* the A-pressed bit is NEVER set in m->input on an A-silent frame. This   *)
(* is the source half of the mid-frame input_a_clear threading that the    *)
(* five feeder kills above consume.                                        *)
(* ====================================================================== *)

(* ---- the ctl-gate finder (the 3-deep canonical shape, Taint.v's
   detectors), mirroring find_input_gate. ---- *)
Fixpoint find_ctl_gate (mptr : ident) (sel : statement -> bool) (s : statement)
  : option statement :=
  match s with
  | Ssequence (Sset t1 e1) (Ssequence (Sset t2 e2) (Sifthenelse g s1 s2)) =>
      if is_controller_load mptr e1 && is_buttonPressed_load t1 e2
         && is_a_button_guard t2 g && sel s1
      then Some s
      else match find_ctl_gate mptr sel s1 with
           | Some g' => Some g'
           | None => find_ctl_gate mptr sel s2
           end
  | Ssequence s1 s2 =>
      match find_ctl_gate mptr sel s1 with
      | Some g' => Some g'
      | None => find_ctl_gate mptr sel s2
      end
  | Sifthenelse _ s1 s2 =>
      match find_ctl_gate mptr sel s1 with
      | Some g' => Some g'
      | None => find_ctl_gate mptr sel s2
      end
  | Sloop s1 s2 =>
      match find_ctl_gate mptr sel s1 with
      | Some g' => Some g'
      | None => find_ctl_gate mptr sel s2
      end
  | Slabel _ s1 => find_ctl_gate mptr sel s1
  | Sswitch _ ls => find_ctl_gate_ls mptr sel ls
  | _ => None
  end
with find_ctl_gate_ls (mptr : ident) (sel : statement -> bool) (ls : labeled_statements)
  : option statement :=
  match ls with
  | LSnil => None
  | LScons _ s rest =>
      match find_ctl_gate mptr sel s with
      | Some g' => Some g'
      | None => find_ctl_gate_ls mptr sel rest
      end
  end.

(* ---- projections for the 3-deep ctl-gate shape. ---- *)
Definition ctl_gate_t1 (g : statement) : ident :=
  match g with Ssequence (Sset t1 _) _ => t1 | _ => 1%positive end.
Definition ctl_gate_t2 (g : statement) : ident :=
  match g with Ssequence _ (Ssequence (Sset t2 _) _) => t2 | _ => 1%positive end.
Definition ctl_gate_then (g : statement) : statement :=
  match g with Ssequence _ (Ssequence _ (Sifthenelse _ s1 _)) => s1 | _ => Sbreak end.
Definition ctl_gate_else (g : statement) : statement :=
  match g with Ssequence _ (Ssequence _ (Sifthenelse _ _ s2)) => s2 | _ => Sbreak end.

(* ---- the umbi gate, BY PROJECTION from the generated AST. ---- *)
Definition umbi_a_gate : statement :=
  match find_ctl_gate mario._m (has_danger a_unsafe_input_write)
          (fn_body mario.f_update_mario_button_inputs) with
  | Some g => g
  | None => Sskip
  end.

Example umbi_a_gate_canonical :
  umbi_a_gate =
  Ssequence
    (Sset (ctl_gate_t1 umbi_a_gate)
       (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._controller (tptr (Tstruct mario._Controller noattr))))
    (Ssequence
       (Sset (ctl_gate_t2 umbi_a_gate)
          (Efield (Ederef (Etempvar (ctl_gate_t1 umbi_a_gate)
                             (tptr (Tstruct mario._Controller noattr)))
                     (Tstruct mario._Controller noattr))
             mario._buttonPressed tushort))
       (Sifthenelse (Ebinop Oand (Etempvar (ctl_gate_t2 umbi_a_gate) tushort)
                       (Econst_int (Int.repr 32768) tint) tint)
          (ctl_gate_then umbi_a_gate) (ctl_gate_else umbi_a_gate))).
Proof. vm_compute. reflexivity. Qed.

(* THE PINNING CENSUS: umbi's body holds exactly ONE A-unsafe input write,
   it lives in this gate's THEN, the ELSE has none. (Taint.v's
   input_writer_map shows there is NO other a_unsafe_input_write in ANY of
   the 12 TUs.) *)
Example umbi_a_write_unique_and_gated :
  ( count_danger a_unsafe_input_write (fn_body mario.f_update_mario_button_inputs)
  , count_danger a_unsafe_input_write (ctl_gate_then umbi_a_gate)
  , count_danger a_unsafe_input_write (ctl_gate_else umbi_a_gate) )
  = (1%nat, 1%nat, 0%nat).
Proof. vm_compute. reflexivity. Qed.

Section InputWriteKillLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* ================================================================== *)
  (* THE INPUT-WRITE KILL: on an A-silent frame (ctl_a_clear -- the        *)
  (* capstone's grounded NoA), the unique INPUT_A_PRESSED-setting write    *)
  (* in the whole linked program never executes.                           *)
  (* ================================================================== *)
  Theorem umbi_a_write_dead_lp :
    forall e le m bm tr le' m' out,
      le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
      ctl_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m umbi_a_gate tr le' m' out ->
      exists bc oc vi,
        Mem.load Mptr m bm 156 = Some (Vptr bc oc) /\
        Mem.load Mint16unsigned m bc
          (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) = Some (Vint vi) /\
        Int.and vi (Int.repr 32768) = Int.zero /\
        count_danger a_unsafe_input_write (ctl_gate_else umbi_a_gate) = 0%nat /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set (ctl_gate_t2 umbi_a_gate) (Vint vi)
             (PTree.set (ctl_gate_t1 umbi_a_gate) (Vptr bc oc) le)) m
          (ctl_gate_else umbi_a_gate) tr le' m' out.
  Proof.
    intros e le m bm tr le' m' out Hle Hclear Hexec.
    rewrite umbi_a_gate_canonical in Hexec.
    destruct (ctl_a_gate_takes_else_lp lp LO_mario mario._m
                (ctl_gate_t1 umbi_a_gate) (ctl_gate_t2 umbi_a_gate)
                (ctl_gate_then umbi_a_gate) (ctl_gate_else umbi_a_gate)
                e le m bm tr le' m' out Hle Hclear Hexec)
      as (bc & oc & vi & Hldctl & Hldbp & Hand & Helse).
    exists bc, oc, vi.
    split; [ exact Hldctl | ].
    split; [ exact Hldbp | ].
    split; [ exact Hand | ].
    split; [ vm_compute; reflexivity | ].
    exact Helse.
  Qed.

End InputWriteKillLp.

(* ====================================================================== *)
(* THE UMBI PRESERVATION WALK: the WHOLE body of                           *)
(* f_update_mario_button_inputs preserves input_a_clear under ctl_a_clear. *)
(*                                                                         *)
(* Gate 1 (the unique INPUT_A_PRESSED-setting write) provably takes ELSE   *)
(* (ctl_a_gate_takes_else_lp).  Gates 2-5 OR in 128/8192/16384/32768 --    *)
(* all INPUT_A-clear constants -- through the canonical                    *)
(* `t = m->input; m->input = t | K` idiom, so bit 1 stays clear whichever  *)
(* branch runs (no branch analysis needed past gate 1).  The               *)
(* framesSinceA/framesSinceB stores land at offsets 40/41, disjoint from   *)
(* input's [2,4).  This is the SOURCE half of mid-frame input_a_clear      *)
(* threading: with update_mario_inputs' zeroing it establishes the         *)
(* precondition of the five input-gate kills.                              *)
(* ====================================================================== *)

Lemma mario_framesSinceA_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._framesSinceA mario_state_members
    = OK (40, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_framesSinceB_offset_concrete :
  field_offset (prog_comp_env mario.prog) mario._framesSinceB mario_state_members
    = OK (41, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma ptrofs_max_unsigned_ge : 4294967295 <= Ptrofs.max_unsigned.
Proof. vm_compute. intro HX; discriminate HX. Qed.

(* bit-1 arithmetic: zero_ext-16 and OR-with-a-clear-constant keep the
   INPUT_A_PRESSED bit clear. *)
Lemma and2_zero_ext16 :
  forall y, Int.and (Int.zero_ext 16 y) (Int.repr 2) = Int.and y (Int.repr 2).
Proof.
  intro y. rewrite Int.zero_ext_and by lia. rewrite Int.and_assoc.
  assert (E : Int.eq (Int.and (Int.repr (two_p 16 - 1)) (Int.repr 2)) (Int.repr 2)
              = true) by (vm_compute; reflexivity).
  apply Int.same_if_eq in E. rewrite E. reflexivity.
Qed.

Lemma and2_or_clear :
  forall a b,
    Int.and a (Int.repr 2) = Int.zero ->
    Int.and b (Int.repr 2) = Int.zero ->
    Int.and (Int.or a b) (Int.repr 2) = Int.zero.
Proof.
  intros a b Ha Hb.
  rewrite Int.and_commut, Int.and_or_distrib.
  rewrite (Int.and_commut (Int.repr 2) a), (Int.and_commut (Int.repr 2) b).
  rewrite Ha, Hb. apply Int.or_zero.
Qed.

(* concrete-ident disequality (the temps vs _m). *)
Ltac ident_neq := let HX := fresh "HX" in intro HX; vm_compute in HX; discriminate HX.

Section UmbiPreservesLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* ---- generic big-step inversion bricks ---- *)

  Lemma exec_seq_cases :
    forall e le m s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Ssequence s1 s2) tr le' m' out ->
      (exists tr1 le1 m1 tr2,
          exec_stmt function_entry2 (lp_ge lp) e le m s1 tr1 le1 m1 Out_normal /\
          exec_stmt function_entry2 (lp_ge lp) e le1 m1 s2 tr2 le' m' out)
      \/ (exec_stmt function_entry2 (lp_ge lp) e le m s1 tr le' m' out /\
          out <> Out_normal).
  Proof.
    intros e le m s1 s2 tr le' m' out H; inv H.
    - left; do 4 eexists; split; eassumption.
    - right; split; assumption.
  Qed.

  Lemma exec_set_inv :
    forall e le m t a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sset t a) tr le' m' out ->
      exists v, eval_expr (lp_ge lp) e le m a v /\
                le' = PTree.set t v le /\ m' = m /\ out = Out_normal.
  Proof. intros e le m t a tr le' m' out H; inv H. eexists; repeat split; eauto. Qed.

  Lemma exec_if_inv :
    forall e le m c s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sifthenelse c s1 s2) tr le' m' out ->
      exists b,
        exec_stmt function_entry2 (lp_ge lp) e le m (if b : bool then s1 else s2)
          tr le' m' out.
  Proof. intros e le m c s1 s2 tr le' m' out H; inv H; eexists; eassumption. Qed.

  Lemma exec_skip_inv :
    forall e le m tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m Sskip tr le' m' out ->
      le' = le /\ m' = m /\ out = Out_normal.
  Proof. intros e le m tr le' m' out H; inv H; auto. Qed.

  (* ---- the m->FIELD lvalue pin (generic over the MarioState field) ---- *)
  Lemma eval_mario_field_lvalue_lp :
    forall stid fld fldty delta e le m bm loc ofs bf,
      eval_lvalue (lp_ge lp) e le m
        (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                        (Tstruct mario._MarioState noattr)) fld fldty) loc ofs bf ->
      le ! stid = Some (Vptr bm Ptrofs.zero) ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      loc = bm /\ ofs = Ptrofs.repr delta /\ bf = Full.
  Proof.
    intros stid fld fldty delta e le m bm loc ofs bf Hlv Hle Hfo.
    apply eval_lvalue_Efield_inv in Hlv
      as (o0 & id & att & co & delta' & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ].
    subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    rewrite Hle in Hlvb. inv Hlvb.
    (* NB: targeted `discriminate Hty`, NEVER bare `discriminate` here -- the
       argless form scans ALL hypotheses and lazily forces Hfo's
       field_offset-over-the-concrete-cenv (minutes-slow, the genv perf wall). *)
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn [typeof] in Hty; discriminate Hty ].
    cbn [typeof] in Hty; inv Hty.
    change (genv_cenv (lp_ge lp)) with (prog_comp_env lp) in Hco, Hfo2.
    destruct (RealFrameLinked.mario_defines_MarioState) as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState co0
                  LO_mario Hmar) as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog fld (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite <- Hmm in Hfo2. rewrite Hfo in Hfo2. inv Hfo2.
    try rewrite Ptrofs.add_zero_l in *.
    repeat split; congruence.
  Qed.

  (* the `t | K` rhs forces the temp to hold a Vint and pins the result
     (mirror of guard_temp_vint at Oor). *)
  Lemma or_temp_vint :
    forall t (k : Z) e le m v1,
      eval_expr (lp_ge lp) e le m
        (Ebinop Oor (Etempvar t tushort) (Econst_int (Int.repr k) tint) tint) v1 ->
      exists vi, le ! t = Some (Vint vi) /\ v1 = Vint (Int.or vi (Int.repr k)).
  Proof.
    intros t k e le m v1 Hev.
    inv Hev.
    - match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?vv |- _ =>
        apply eval_expr_Etempvar_val in H; rename H into Hlet end.
      match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H end.
      + match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some v1 |- _ =>
          unfold sem_binary_operation, sem_or, sem_binarith, sem_cast in H;
          match goal with HH : le ! t = Some ?va |- _ =>
            destruct va;
            cbn [classify_binarith binarith_type classify_cast cast_int_int] in H;
            try discriminate H end;
          inv H end.
        eexists; split; [ exact Hlet | reflexivity ].
      + match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end.
    - match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end.
  Qed.

  (* ---- the statement-level preservation contract and its combinators ---- *)

  Definition input_clear_contract (s : statement) : Prop :=
    forall e le m bm tr le' m' out,
      le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m s tr le' m' out ->
      input_a_clear m' bm /\
      le' ! mario._m = Some (Vptr bm Ptrofs.zero) /\
      out = Out_normal.

  Lemma contract_skip : input_clear_contract Sskip.
  Proof.
    intros e le m bm tr le' m' out Hle Hinp Hex.
    apply exec_skip_inv in Hex as (-> & -> & ->).
    split; [ exact Hinp | split; [ exact Hle | reflexivity ] ].
  Qed.

  Lemma contract_set :
    forall t a, t <> mario._m -> input_clear_contract (Sset t a).
  Proof.
    intros t a Hne e le m bm tr le' m' out Hle Hinp Hex.
    apply exec_set_inv in Hex as (v & _ & -> & -> & ->).
    split; [ exact Hinp | split; [ | reflexivity ] ].
    rewrite PTree.gso by congruence. exact Hle.
  Qed.

  Lemma contract_seq :
    forall s1 s2,
      input_clear_contract s1 -> input_clear_contract s2 ->
      input_clear_contract (Ssequence s1 s2).
  Proof.
    intros s1 s2 H1 H2 e le m bm tr le' m' out Hle Hinp Hex.
    apply exec_seq_cases in Hex
      as [ (tr1 & le1 & m1 & tr2 & Ha & Hb) | (Ha & Hnn) ].
    - destruct (H1 _ _ _ _ _ _ _ _ Hle Hinp Ha) as (Hinp1 & Hle1 & _).
      exact (H2 _ _ _ _ _ _ _ _ Hle1 Hinp1 Hb).
    - destruct (H1 _ _ _ _ _ _ _ _ Hle Hinp Ha) as (_ & _ & Ho). congruence.
  Qed.

  Lemma contract_if :
    forall c s1 s2,
      input_clear_contract s1 -> input_clear_contract s2 ->
      input_clear_contract (Sifthenelse c s1 s2).
  Proof.
    intros c s1 s2 H1 H2 e le m bm tr le' m' out Hle Hinp Hex.
    apply exec_if_inv in Hex as (b & Hb).
    destruct b; [ exact (H1 _ _ _ _ _ _ _ _ Hle Hinp Hb)
                | exact (H2 _ _ _ _ _ _ _ _ Hle Hinp Hb) ].
  Qed.

  (* THE OR-UPDATE BRICK: `t = m->input; m->input = t | K` with K&2 = 0
     keeps INPUT_A_PRESSED clear (gates 2-5's THEN arms). *)
  Lemma contract_or_update :
    forall t k,
      t <> mario._m ->
      Int.and (Int.repr k) (Int.repr 2) = Int.zero ->
      input_clear_contract
        (Ssequence
           (Sset t (Efield (Ederef (Etempvar mario._m
                              (tptr (Tstruct mario._MarioState noattr)))
                             (Tstruct mario._MarioState noattr))
                      mario._input tushort))
           (Sassign (Efield (Ederef (Etempvar mario._m
                               (tptr (Tstruct mario._MarioState noattr)))
                              (Tstruct mario._MarioState noattr))
                       mario._input tushort)
              (Ebinop Oor (Etempvar t tushort)
                 (Econst_int (Int.repr k) tint) tint))).
  Proof.
    intros t k Hne Hk e le m bm tr le' m' out Hle Hinp Hex.
    apply exec_seq_cases in Hex
      as [ (tr1 & le1 & m1 & tr2 & Ha & Hb) | (Ha & Hnn) ].
    2: { apply exec_set_inv in Ha as (v & _ & _ & _ & Ho). congruence. }
    apply exec_set_inv in Ha as (v & Hevset & -> & -> & _).
    inv Hb.
    (* rhs: t | K, forcing t = Vint vi *)
    match goal with H : eval_expr _ _ _ _ (Ebinop Oor _ _ _) _ |- _ =>
      apply or_temp_vint in H as (vi & Hlet & ->) end.
    rewrite PTree.gss in Hlet. inv Hlet.
    (* the Sset's load was the input cell: bit 1 clear by the invariant *)
    pose proof (eval_input_load_bm_lp lp LO_mario _ _ _ _ _ _ Hle Hevset) as Hld.
    pose proof (Hinp _ Hld) as Hvi2.
    (* lhs lvalue: (bm, 2, Full) *)
    match goal with H : eval_lvalue _ _ _ _ (Efield _ mario._input _) _ _ _ |- _ =>
      eapply eval_mario_field_lvalue_lp with (delta := 2) (bm := bm) in H;
      [ destruct H as (-> & -> & ->)
      | rewrite PTree.gso by congruence; exact Hle
      | exact mario_input_offset_concrete ] end.
    (* the cast to tushort: zero_ext 16 *)
    match goal with H : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in H;
      unfold sem_cast in H; cbn [classify_cast cast_int_int] in H; inv H end.
    (* the store *)
    match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => inv H end;
      try (match goal with Hac : access_mode _ = By_copy |- _ =>
             cbn in Hac; discriminate Hac end).
    match goal with Hac : access_mode _ = By_value _ |- _ => cbn in Hac; inv Hac end.
    match goal with H : Mem.storev _ _ _ _ = Some _ |- _ =>
      unfold Mem.storev in H;
      change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in H;
      rename H into Hst end.
    split; [ | split ].
    - (* input_a_clear m' bm *)
      intros w Hw.
      pose proof (Mem.load_store_same _ _ _ _ _ _ Hst) as Hsame.
      cbn [Val.load_result] in Hsame.
      rewrite Hw in Hsame. inv Hsame.
      rewrite !and2_zero_ext16. apply and2_or_clear; assumption.
    - rewrite PTree.gso by congruence. exact Hle.
    - reflexivity.
  Qed.

  (* THE OFF-INPUT STORE BRICK: a store to a tuchar MarioState field at
     offset >= 4 cannot touch input's [2,4) (framesSinceA/framesSinceB). *)
  Lemma contract_assign_high :
    forall fld delta rhs,
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      4 <= delta <= Ptrofs.max_unsigned ->
      input_clear_contract
        (Sassign (Efield (Ederef (Etempvar mario._m
                            (tptr (Tstruct mario._MarioState noattr)))
                           (Tstruct mario._MarioState noattr)) fld tuchar) rhs).
  Proof.
    intros fld delta rhs Hfo Hrange e le m bm tr le' m' out Hle Hinp Hex.
    inv Hex.
    match goal with H : eval_lvalue _ _ _ _ (Efield _ fld _) _ _ _ |- _ =>
      eapply eval_mario_field_lvalue_lp with (delta := delta) (bm := bm) in H;
      [ destruct H as (-> & -> & ->) | exact Hle | exact Hfo ] end.
    match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => inv H end;
      try (match goal with Hac : access_mode _ = By_copy |- _ =>
             cbn in Hac; discriminate Hac end).
    match goal with Hac : access_mode _ = By_value _ |- _ => cbn in Hac; inv Hac end.
    match goal with H : Mem.storev _ _ _ _ = Some _ |- _ =>
      unfold Mem.storev in H;
      rewrite Ptrofs.unsigned_repr in H by lia;
      rename H into Hst end.
    split; [ | split; [ exact Hle | reflexivity ] ].
    intros w Hw.
    assert (Heq : Mem.load Mint16unsigned m' bm 2 = Mem.load Mint16unsigned m bm 2).
    { eapply Mem.load_store_other;
      [ exact Hst | right; left; cbn [size_chunk]; lia ]. }
    rewrite Heq in Hw. exact (Hinp _ Hw).
  Qed.

  (* syntax-directed assembly: or-updates first (they are Ssequences too),
     then the generic combinators, then the two frames-field stores. *)
  Ltac solve_contract :=
    lazymatch goal with
    | |- input_clear_contract (Ssequence (Sset _ _) (Sassign _ (Ebinop Oor _ _ _))) =>
        apply contract_or_update;
        [ ident_neq | apply Int.same_if_eq; vm_compute; reflexivity ]
    | |- input_clear_contract (Ssequence _ _) =>
        apply contract_seq; [ solve_contract | solve_contract ]
    | |- input_clear_contract (Sifthenelse _ _ _) =>
        apply contract_if; [ solve_contract | solve_contract ]
    | |- input_clear_contract (Sset _ _) => apply contract_set; ident_neq
    | |- input_clear_contract Sskip => apply contract_skip
    | |- input_clear_contract (Sassign _ _) =>
        first
          [ apply (contract_assign_high mario._framesSinceA 40);
            [ exact mario_framesSinceA_offset_concrete
            | pose proof ptrofs_max_unsigned_ge; lia ]
          | apply (contract_assign_high mario._framesSinceB 41);
            [ exact mario_framesSinceB_offset_concrete
            | pose proof ptrofs_max_unsigned_ge; lia ] ]
    end.

  (* ================================================================== *)
  (* THE BRIDGE: the whole update_mario_button_inputs body preserves     *)
  (* input_a_clear on an A-silent frame.                                  *)
  (* ================================================================== *)
  Theorem umbi_body_preserves_input_a_clear_lp :
    forall e le m bm tr le' m' out,
      le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
      ctl_a_clear m bm ->
      input_a_clear m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (fn_body mario.f_update_mario_button_inputs) tr le' m' out ->
      input_a_clear m' bm.
  Proof.
    intros e le m bm tr le' m' out Hle Hctl Hinp Hexec.
    cbn [fn_body mario.f_update_mario_button_inputs] in Hexec.
    apply exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hg1 & Hrest) | (Hg1 & Hnn) ].
    2: { (* gate 1 alone with a non-normal outcome: impossible (ELSE = Sskip) *)
      destruct (ctl_a_gate_takes_else_lp lp LO_mario _ _ _ _ _ _ _ _ _ _ _ _ _
                  Hle Hctl Hg1) as (bc & oc & vi & _ & _ & _ & Hskip).
      apply exec_skip_inv in Hskip as (_ & _ & Ho). congruence. }
    (* gate 1 takes ELSE = Sskip: memory unchanged, two temps set *)
    destruct (ctl_a_gate_takes_else_lp lp LO_mario _ _ _ _ _ _ _ _ _ _ _ _ _
                Hle Hctl Hg1) as (bc & oc & vi & _ & _ & _ & Hskip).
    apply exec_skip_inv in Hskip as (Hle1eq & Hm1 & _). subst le1 m1.
    assert (Hle1 : (PTree.set mario._t'21 (Vint vi)
                      (PTree.set mario._t'20 (Vptr bc oc) le)) ! mario._m
                   = Some (Vptr bm Ptrofs.zero)).
    { rewrite PTree.gso by ident_neq. rewrite PTree.gso by ident_neq. exact Hle. }
    (* the rest of the body is contract-shaped: assemble and apply *)
    match type of Hrest with
    | exec_stmt _ _ _ _ _ ?S _ _ _ _ =>
        assert (HC : input_clear_contract S) by solve_contract;
        exact (proj1 (HC _ _ _ _ _ _ _ _ Hle1 Hinp Hrest))
    end.
  Qed.

End UmbiPreservesLp.
