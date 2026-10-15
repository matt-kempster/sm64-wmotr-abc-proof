From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update
  us_ingame_menu jp_ingame_menu.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_level_update.
Module I := us_ingame_menu.

(** The selected decision is the actual suffix after get_dialog_id and Mario's
    action/intangible calculation, not a replacement predicate for pausing. *)
Definition pressed_pause_decision (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ decision) => decision
  | _ => Sskip
  end.

Lemma generated_pause_decision_identical_us_jp :
  pressed_pause_decision (fn_body P.f_pressed_pause) =
  pressed_pause_decision (fn_body jp_level_update.f_pressed_pause).
Proof. reflexivity. Qed.

Ltac pause_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [pause_expr | pause_expr |
        first
        [match goal with
         | H : Int.eq ?x Int.zero = false |- _ = ?out =>
           change (Some (Val.of_bool (Int.eq x Int.zero)) = out);
           rewrite H; reflexivity
         end
        |demo_reduce; reflexivity]]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [pause_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [pause_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec; cbn;
        first [reflexivity | eassumption]
  | _ => demo_expr
  end.

Ltac pause_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first
      [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
        [pause_stmt | pause_stmt]
      |eapply exec_Sseq_2; [pause_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
        [pause_expr | reflexivity | pause_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
        [pause_expr | reflexivity | pause_stmt]]
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; pause_expr
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; pause_expr
  end.

(** Actual Mario/dialog checks yield boolean-valued temporaries.  The following
    theorem handles both values of each; it does not assume Mario intangible or
    a dialog open.  The actual active-byte read is fixed to the runtime boolean
    values 0/1; establishing that byte invariant from initialization is separate. *)
Definition pause_decision_exclusion_claim : Prop :=
  forall (ge : Clight.genv) le m dialog intangible active
      transition operation op transition_co,
    le ! P._dialogActive = Some (Val.of_bool dialog) ->
    le ! P._intangible = Some (Val.of_bool intangible) ->
    Genv.find_symbol ge P._gWarpTransition = Some transition ->
    Genv.find_symbol ge P._sDelayedWarpOp = Some operation ->
    (genv_cenv ge) ! P._WarpTransition = Some transition_co ->
    field_offset (genv_cenv ge) P._isActive (co_members transition_co) =
      OK (0, Full) ->
    Mem.load Mint8unsigned m transition 0 = Some (Val.of_bool active) ->
    Mem.load Mint16signed m operation 0 = Some (Vint op) ->
    (active = true \/ Int.eq op Int.zero = false) ->
    exists le',
      exec_stmt function_entry2 ge empty_env le m
        (pressed_pause_decision (fn_body P.f_pressed_pause)) E0 le' m
        (Out_return (Some (Vzero, tint))) /\
      exec_stmt function_entry2 ge empty_env le m
        (pressed_pause_decision (fn_body jp_level_update.f_pressed_pause)) E0
        le' m (Out_return (Some (Vzero, tint))).

Theorem generated_pause_decision_rejects_active_transition_or_delayed_warp :
  pause_decision_exclusion_claim.
Proof.
  intros ge le m dialog intangible active transition operation op transition_co
    Hdialog Hintangible Htransition Hoperation Hco Hfield Hactive Hop Hexclude.
  assert (Hexec : exists le',
    exec_stmt function_entry2 ge empty_env le m
      (pressed_pause_decision (fn_body P.f_pressed_pause)) E0 le' m
      (Out_return (Some (Vzero, tint)))).
  { destruct dialog, intangible, active; cbn in Hdialog, Hintangible, Hactive;
      try (destruct Hexclude as [Hfalse | Hneq]; [discriminate |]);
      eexists; unfold pressed_pause_decision;
      cbn [P.f_pressed_pause fn_body]; pause_stmt. }
  destruct Hexec as [le' Hexec]. exists le'. split; [exact Hexec |].
  rewrite <- generated_pause_decision_identical_us_jp. exact Hexec.
Qed.

Lemma generated_dialog_query_identical_us_jp :
  I.f_get_dialog_id = jp_ingame_menu.f_get_dialog_id.
Proof. reflexivity. Qed.

Theorem generated_dialog_query_call_executes :
  forall (ge : Clight.genv) m dialog_global dialog,
    Genv.find_symbol ge I._gDialogID = Some dialog_global ->
    Mem.load Mint16signed m dialog_global 0 = Some (Vint dialog) ->
    eval_funcall function_entry2 ge m (Internal I.f_get_dialog_id) [] E0 m
      (Vint dialog).
Proof.
  intros ge m dialog_global dialog Hdialog Hread.
  assert (Hnormalized : Int.sign_ext 16 dialog = dialog).
  { pose proof (Mem.load_cast _ _ _ _ _ Hread) as Hcast.
    cbn in Hcast. congruence. }
  eapply eval_funcall_internal with (e := empty_env)
    (le1 := create_undef_temps (fn_temps I.f_get_dialog_id))
    (le2 := PTree.set I._t'1 (Vint dialog)
      (create_undef_temps (fn_temps I.f_get_dialog_id))) (m1 := m) (m2 := m)
    (out := Out_return (Some (Vint dialog, tshort))).
  - constructor.
    + constructor.
    + constructor.
    + unfold list_disjoint. cbn. tauto.
    + constructor.
    + reflexivity.
  - cbn [I.f_get_dialog_id fn_body]. demo_stmt.
  - split; [discriminate | cbn; rewrite Hnormalized; reflexivity].
  - reflexivity.
Qed.

Definition pause_dialog_flag (dialog : int) : bool :=
  Int.cmp Cge dialog Int.zero.
Definition pause_intangible_flag (action : int) : bool :=
  Int.cmp Cne (Int.and action (Int.shl Int.one (Int.repr 12))) Int.zero.

Definition pause_after_reads (le : temp_env) (mario : block)
    (dialog action : int) : temp_env :=
  PTree.set P._intangible (Val.of_bool (pause_intangible_flag action))
    (PTree.set P._t'11 (Vint action)
      (PTree.set P._t'10 (Vptr mario Ptrofs.zero)
        (PTree.set P._dialogActive (Val.of_bool (pause_dialog_flag dialog))
          (PTree.set P._t'1 (Vint dialog) le)))).

Lemma generated_pressed_pause_identical_us_jp :
  P.f_pressed_pause = jp_level_update.f_pressed_pause.
Proof. reflexivity. Qed.

Section COMPLETE_PAUSE.
  Variable ge : Clight.genv.
  Variable m : mem.
  Variables dialog_global query_global mario_global mario transition operation : block.
  Variables dialog action op : int.
  Variable active : bool.
  Variables mario_co transition_co : composite.
  Hypothesis Hdialog_global : Genv.find_symbol ge I._gDialogID = Some dialog_global.
  Hypothesis Hdialog_read : Mem.load Mint16signed m dialog_global 0 = Some (Vint dialog).
  Hypothesis Hquery_global : Genv.find_symbol ge P._get_dialog_id = Some query_global.
  Hypothesis Hquery_body : Genv.find_funct_ptr ge query_global = Some (Internal I.f_get_dialog_id).
  Hypothesis Hmario_global : Genv.find_symbol ge P._gMarioState = Some mario_global.
  Hypothesis Hmario_read : Mem.load Mptr m mario_global 0 = Some (Vptr mario Ptrofs.zero).
  Hypothesis Hmario_co : (genv_cenv ge) ! P._MarioState = Some mario_co.
  Hypothesis Haction_offset : field_offset (genv_cenv ge) P._action
    (co_members mario_co) = OK (12, Full).
  Hypothesis Haction : Mem.load Mint32 m mario 12 = Some (Vint action).
  Hypothesis Htransition : Genv.find_symbol ge P._gWarpTransition = Some transition.
  Hypothesis Hoperation : Genv.find_symbol ge P._sDelayedWarpOp = Some operation.
  Hypothesis Htransition_co : (genv_cenv ge) ! P._WarpTransition = Some transition_co.
  Hypothesis Hactive_offset : field_offset (genv_cenv ge) P._isActive
    (co_members transition_co) = OK (0, Full).
  Hypothesis Hactive : Mem.load Mint8unsigned m transition 0 = Some (Val.of_bool active).
  Hypothesis Hop : Mem.load Mint16signed m operation 0 = Some (Vint op).
  Hypothesis Hexclude : active = true \/ Int.eq op Int.zero = false.

  Theorem generated_pressed_pause_complete_body_excludes_pause :
    forall le, exists le',
      exec_stmt function_entry2 ge empty_env le m
        (fn_body P.f_pressed_pause) E0 le' m
        (Out_return (Some (Vzero, tint))).
  Proof.
    intros le.
    destruct (generated_pause_decision_rejects_active_transition_or_delayed_warp
      ge (pause_after_reads le mario dialog action) m
      (pause_dialog_flag dialog) (pause_intangible_flag action) active
      transition operation op transition_co)
      as [le' Hdecision]; try assumption.
    - unfold pause_after_reads. repeat rewrite PTree.gsspec. cbn. reflexivity.
    - unfold pause_after_reads. apply PTree.gss.
    - destruct Hdecision as [Hdecision Hjp]. exists le'.
      cbn [P.f_pressed_pause fn_body].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        * eapply exec_Scall with (vf := Vptr query_global Ptrofs.zero)
            (f := Internal I.f_get_dialog_id) (vargs := []) (vres := Vint dialog).
          -- reflexivity.
          -- demo_expr.
          -- constructor.
          -- cbn. exact Hquery_body.
          -- reflexivity.
          -- apply generated_dialog_query_call_executes with (dialog_global := dialog_global);
               assumption.
        * eapply exec_Sset. unfold pause_dialog_flag. pause_expr.
      + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0)
          (le1 := pause_after_reads le mario dialog action).
        * unfold pause_after_reads, pause_intangible_flag. pause_stmt.
        * exact Hdecision.
  Qed.

  Theorem generated_pressed_pause_complete_call_excludes_pause :
    eval_funcall function_entry2 ge m (Internal P.f_pressed_pause) [] E0 m Vzero /\
    eval_funcall function_entry2 ge m (Internal jp_level_update.f_pressed_pause)
      [] E0 m Vzero.
  Proof.
    assert (Hcall : eval_funcall function_entry2 ge m
      (Internal P.f_pressed_pause) [] E0 m Vzero).
    { destruct (generated_pressed_pause_complete_body_excludes_pause
        (create_undef_temps (fn_temps P.f_pressed_pause))) as [le' Hbody].
      eapply eval_funcall_internal with (e := empty_env)
        (le1 := create_undef_temps (fn_temps P.f_pressed_pause))
        (le2 := le') (m1 := m) (m2 := m)
        (out := Out_return (Some (Vzero, tint))).
      - constructor.
        + constructor.
        + constructor.
        + unfold list_disjoint. cbn. tauto.
        + constructor.
        + reflexivity.
      - exact Hbody.
      - split; [discriminate | reflexivity].
      - reflexivity. }
    split; exact Hcall.
  Qed.
End COMPLETE_PAUSE.

Definition demo_complete_pause_exclusion_claim : Prop :=
  forall (ge : Clight.genv) m dialog_global query_global mario_global mario
      transition operation dialog action op active mario_co transition_co,
    Genv.find_symbol ge I._gDialogID = Some dialog_global ->
    Mem.load Mint16signed m dialog_global 0 = Some (Vint dialog) ->
    Genv.find_symbol ge P._get_dialog_id = Some query_global ->
    Genv.find_funct_ptr ge query_global = Some (Internal I.f_get_dialog_id) ->
    Genv.find_symbol ge P._gMarioState = Some mario_global ->
    Mem.load Mptr m mario_global 0 = Some (Vptr mario Ptrofs.zero) ->
    (genv_cenv ge) ! P._MarioState = Some mario_co ->
    field_offset (genv_cenv ge) P._action (co_members mario_co) = OK (12, Full) ->
    Mem.load Mint32 m mario 12 = Some (Vint action) ->
    Genv.find_symbol ge P._gWarpTransition = Some transition ->
    Genv.find_symbol ge P._sDelayedWarpOp = Some operation ->
    (genv_cenv ge) ! P._WarpTransition = Some transition_co ->
    field_offset (genv_cenv ge) P._isActive (co_members transition_co) = OK (0, Full) ->
    Mem.load Mint8unsigned m transition 0 = Some (Val.of_bool active) ->
    Mem.load Mint16signed m operation 0 = Some (Vint op) ->
    (active = true \/ Int.eq op Int.zero = false) ->
    eval_funcall function_entry2 ge m (Internal P.f_pressed_pause) [] E0 m Vzero /\
    eval_funcall function_entry2 ge m (Internal jp_level_update.f_pressed_pause)
      [] E0 m Vzero.

Theorem generated_demo_complete_pause_exclusion_us_jp :
  demo_complete_pause_exclusion_claim.
Proof.
  unfold demo_complete_pause_exclusion_claim.
  intros. eapply generated_pressed_pause_complete_call_excludes_pause;
    eassumption.
Qed.
