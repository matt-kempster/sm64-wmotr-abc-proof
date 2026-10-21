(** Exact execution of generated US/JP slide-kick gravity, independent of
    SSL's whole-program link audit. The only environment premises are the
    MarioState action/velocity layouts, instantiated for SSL's selected
    linked programs in the companion file. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Errors Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario_step jp_mario_step.
From LessThanOneAPress.Proofs Require Import GameTypes.
Import ListNotations.
Local Open Scope Z_scope.
Module SKP := us_mario_step.
Definition skp_body version := match version with
| VersionUS => us_mario_step.f_apply_gravity
| VersionJP => jp_mario_step.f_apply_gravity end.
Definition skp_action := Int.repr 25168042.
Definition skp_field field ty := Efield
  (Ederef (Etempvar SKP._m (tptr (Tstruct SKP._MarioState noattr)))
    (Tstruct SKP._MarioState noattr)) field ty.
Definition skp_action_field := skp_field SKP._action tuint.
Definition skp_velocity := Ederef
  (Ebinop Oadd (skp_field SKP._vel (tarray tfloat 3))
    (Econst_int Int.one tint) (tptr tfloat)) tfloat.
Definition SKPField (ge : genv) field offset : Prop := exists co,
  (genv_cenv ge) ! SKP._MarioState = Some co /\
  field_offset ge field (co_members co) = OK (offset,Full).
Definition SKPLayout ge := SKPField ge SKP._action 12 /\ SKPField ge SKP._vel 72.
Lemma skp_field_lvalue : forall (ge : genv) e le m mario field ty offset,
  SKPField ge field offset ->
  le ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
  eval_lvalue ge e le m (skp_field field ty) mario (Ptrofs.repr offset) Full.
Proof.
  intros ge e le m mario field ty offset (co & Hco & Hoff) Hm.
  replace (Ptrofs.repr offset) with (Ptrofs.add Ptrofs.zero (Ptrofs.repr offset))
    by (rewrite Ptrofs.add_zero_l; reflexivity).
  unfold skp_field. eapply eval_Efield_struct with (co := co).
  - eapply eval_Elvalue; [apply eval_Ederef; apply eval_Etempvar; exact Hm|].
    apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hco.
  - exact Hoff.
Qed.
Lemma skp_velocity_lvalue : forall (ge : genv) e le m mario,
  SKPField ge SKP._vel 72 ->
  le ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
  eval_lvalue ge e le m skp_velocity mario (Ptrofs.repr 76) Full.
Proof.
  intros ge e le m mario Hlayout Hm. unfold skp_velocity.
  apply eval_Ederef. eapply eval_Ebinop.
  - eapply eval_Elvalue.
    + eapply skp_field_lvalue; eauto.
    + apply deref_loc_reference. reflexivity.
  - constructor.
  - reflexivity.
Qed.
Lemma skp_velocity_read : forall (ge : genv) e le m mario v,
  SKPField ge SKP._vel 72 ->
  le ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mfloat32 m mario 76 = Some (Vsingle v) ->
  eval_expr ge e le m skp_velocity (Vsingle v).
Proof.
  intros ge e le m mario v Hlayout Hm Hv.
  eapply eval_Elvalue with (loc := mario) (ofs := Ptrofs.repr 76) (bf := Full).
  - apply skp_velocity_lvalue; assumption.
  - eapply deref_loc_value with (chunk := Mfloat32); eauto.
Qed.
Lemma skp_action_read : forall (ge : genv) e le m mario,
  SKPField ge SKP._action 12 ->
  le ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 m mario 12 = Some (Vint skp_action) ->
  eval_expr ge e le m skp_action_field (Vint skp_action).
Proof.
  intros ge e le m mario Hlayout Hm Ha.
  eapply eval_Elvalue with (loc := mario) (ofs := Ptrofs.repr 12) (bf := Full).
  - apply skp_field_lvalue; assumption.
  - eapply deref_loc_value with (chunk := Mint32); eauto.
Qed.
Definition skp_two := Float32.of_bits (Int.repr 1073741824).
Definition skp_minus75 := Float32.neg (Float32.of_bits (Int.repr 1117126656)).
Definition skp_raw v := Float32.sub v skp_two.
Definition skp_clamp v := Float32.cmp Clt (skp_raw v) skp_minus75.
Definition skp_gravity v := if skp_clamp v then skp_minus75 else skp_raw v.
Definition skp_code := Ssequence
  (Ssequence (Sset SKP._t'32 skp_velocity)
    (Sassign skp_velocity (Ebinop Osub (Etempvar SKP._t'32 tfloat)
      (Econst_single skp_two tfloat) tfloat)))
  (Ssequence (Sset SKP._t'31 skp_velocity)
    (Sifthenelse (Ebinop Olt (Etempvar SKP._t'31 tfloat)
      (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat) tfloat) tint)
      (Sassign skp_velocity
        (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat) tfloat)) Sskip)).

Definition skp_locals le v := PTree.set SKP._t'31 (Vsingle (skp_raw v))
  (PTree.set SKP._t'32 (Vsingle v) le).
Definition SKPOutsideVelocity (mario : block) chunk (b : block) offset : Prop :=
  b <> mario \/ offset + size_chunk chunk <= 76 \/ 80 <= offset.

Theorem skp_exact_gravity_branch : forall (ge : genv) e le m mario v,
  SKPLayout ge ->
  le ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mfloat32 m mario 76 = Some (Vsingle v) ->
  Mem.valid_access m Mfloat32 mario 76 Writable ->
  exists after,
    ClightBigstep.Clight2.exec_stmt ge e le m
      skp_code E0 (skp_locals le v) after Out_normal /\
    Mem.load Mfloat32 after mario 76 = Some (Vsingle (skp_gravity v)) /\
    (forall chunk b offset, SKPOutsideVelocity mario chunk b offset ->
      Mem.load chunk after b offset = Mem.load chunk m b offset).
Proof.
  intros ge e le m mario v Hlayout Hm Hv Haccess.
  destruct (Mem.valid_access_store m Mfloat32 mario 76 (Vsingle (skp_raw v)) Haccess)
    as [raw Hraw].
  assert (Hrawload : Mem.load Mfloat32 raw mario 76 = Some (Vsingle (skp_raw v)))
    by (erewrite Mem.load_store_same by exact Hraw; reflexivity).
  assert (Hfirst : ClightBigstep.Clight2.exec_stmt ge e le m
    (Ssequence (Sset SKP._t'32 skp_velocity)
      (Sassign skp_velocity (Ebinop Osub (Etempvar SKP._t'32 tfloat)
        (Econst_single skp_two tfloat) tfloat))) E0
    (PTree.set SKP._t'32 (Vsingle v) le) raw Out_normal).
  { eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    - apply exec_Sset. eapply skp_velocity_read; [exact (proj2 Hlayout)|exact Hm|exact Hv].
    - eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 76)
        (bf := Full) (v2 := Vsingle (skp_raw v)) (v := Vsingle (skp_raw v)).
      + apply skp_velocity_lvalue; [exact (proj2 Hlayout)|]. rewrite PTree.gso by discriminate. exact Hm.
      + eapply eval_Ebinop; [apply eval_Etempvar; apply PTree.gss|constructor|reflexivity].
      + reflexivity.
      + eapply assign_loc_value with (chunk := Mfloat32); [reflexivity|exact Hraw]. }
  assert (Hread : ClightBigstep.Clight2.exec_stmt ge e
    (PTree.set SKP._t'32 (Vsingle v) le) raw (Sset SKP._t'31 skp_velocity)
    E0 (skp_locals le v) raw Out_normal).
  { apply exec_Sset. apply skp_velocity_read with (mario := mario); [exact (proj2 Hlayout)| |].
    - rewrite PTree.gso by discriminate. exact Hm.
    - exact Hrawload. }
  assert (Htest : eval_expr ge e
    (skp_locals le v) raw (Ebinop Olt (Etempvar SKP._t'31 tfloat)
      (Eunop Oneg (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat) tfloat) tint)
    (Val.of_bool (skp_clamp v))).
  { eapply eval_Ebinop.
    - apply eval_Etempvar. apply PTree.gss.
    - eapply eval_Eunop; [constructor|reflexivity].
    - reflexivity. }
  destruct (skp_clamp v) eqn:Hclamp.
  - assert (Haccess' : Mem.valid_access raw Mfloat32 mario 76 Writable)
      by (eapply Mem.store_valid_access_1; eauto).
    destruct (Mem.valid_access_store raw Mfloat32 mario 76 (Vsingle skp_minus75) Haccess')
      as [after Hstore].
    exists after. split.
    + unfold skp_code. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hfirst|].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hread|].
      eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true); [exact Htest|reflexivity|].
      eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 76)
        (bf := Full) (v2 := Vsingle skp_minus75) (v := Vsingle skp_minus75).
      * apply skp_velocity_lvalue; [exact (proj2 Hlayout)|]. unfold skp_locals.
        repeat rewrite PTree.gso by discriminate. exact Hm.
      * eapply eval_Eunop; [constructor|reflexivity].
      * reflexivity.
      * eapply assign_loc_value with (chunk := Mfloat32); [reflexivity|exact Hstore].
    + split.
      * unfold skp_gravity. rewrite Hclamp. erewrite Mem.load_store_same by exact Hstore. reflexivity.
      * intros chunk b offset Hout. unfold SKPOutsideVelocity in Hout.
        erewrite Mem.load_store_other; [|exact Hstore|exact Hout].
        eapply Mem.load_store_other; [exact Hraw|exact Hout].
  - exists raw. split.
    + unfold skp_code. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hfirst|].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hread|].
      eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false); [exact Htest|reflexivity|constructor].
    + split.
      * unfold skp_gravity. rewrite Hclamp. exact Hrawload.
      * intros chunk b offset Hout. eapply Mem.load_store_other; [exact Hraw|exact Hout].
Qed.

Definition skp_prefix_locals le :=
  PTree.set SKP._t'7 (Vint Int.one) (PTree.set SKP._t'6 (Vint Int.one)
    (PTree.set SKP._t'35 (Vint skp_action) (PTree.set SKP._t'34 (Vint skp_action)
      (PTree.set SKP._t'9 (Vint skp_action) (PTree.set SKP._t'8 (Vint Int.zero)
        (PTree.set SKP._t'38 (Vint skp_action) le)))))).

Ltac skp_temp := repeat (rewrite PTree.gss || rewrite PTree.gso by discriminate);
  first [reflexivity | assumption].

Lemma skp_gravity_body_from_branch : forall (ge : genv) version e le m mario v after,
  SKPLayout ge ->
  le ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 m mario 12 = Some (Vint skp_action) ->
  ClightBigstep.Clight2.exec_stmt ge e
    (skp_prefix_locals le) m skp_code E0
    (skp_locals (skp_prefix_locals le) v) after Out_normal ->
  ClightBigstep.Clight2.exec_stmt ge e le m
    (fn_body (skp_body version)) E0
    (skp_locals (skp_prefix_locals le) v) after Out_normal.
Proof.
  intros ge version e le m mario v after Hlayout Hm Ha Hbranch.
  assert (Haction : forall locals,
    locals ! SKP._m = Some (Vptr mario Ptrofs.zero) ->
    eval_expr ge e locals m
      skp_action_field (Vint skp_action)).
  { intros locals Hlocal. eapply skp_action_read; [exact (proj1 Hlayout)|exact Hlocal|exact Ha]. }
  Ltac skp_expr action := first
    [ solve [apply action; skp_temp]
    | apply eval_Etempvar; skp_temp
    | solve [constructor]
    | eapply eval_Ebinop; [skp_expr action|skp_expr action|reflexivity]
    | eapply eval_Ecast; [skp_expr action|reflexivity] ].
  Ltac skp_walk action branch :=
    first [exact branch |
    match goal with
    | |- ClightBigstep.exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
        eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [skp_walk action branch|skp_walk action branch]
    | |- ClightBigstep.exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => apply exec_Sset; skp_expr action
    | |- ClightBigstep.exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
        first [eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false);
          [solve [skp_expr action]|reflexivity|skp_walk action branch] |
          eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
          [solve [skp_expr action]|reflexivity|skp_walk action branch]]
    end].
  unfold ClightBigstep.Clight2.exec_stmt in *.
  destruct version; cbn [skp_body us_mario_step.f_apply_gravity jp_mario_step.f_apply_gravity fn_body]; skp_walk Haction Hbranch.
Qed.

Definition skp_entry version mario := PTree.set SKP._m (Vptr mario Ptrofs.zero)
  (create_undef_temps (fn_temps (skp_body version))).

(** Complete generated apply_gravity call, not an assumed call contract.
    This applies at every action state, including nonzero/post-bounce. *)
Theorem skp_exact_gravity_call_in : forall (ge : genv) version m mario v,
  SKPLayout ge ->
  Mem.load Mint32 m mario 12 = Some (Vint skp_action) ->
  Mem.load Mfloat32 m mario 76 = Some (Vsingle v) ->
  Mem.valid_access m Mfloat32 mario 76 Writable ->
  exists after,
    ClightBigstep.Clight2.eval_funcall
      ge m
      (Internal (skp_body version)) [Vptr mario Ptrofs.zero] E0 after Vundef /\
    Mem.load Mfloat32 after mario 76 = Some (Vsingle (skp_gravity v)) /\
    (forall chunk b offset, SKPOutsideVelocity mario chunk b offset ->
      Mem.load chunk after b offset = Mem.load chunk m b offset).
Proof.
  intros ge version m mario v Hlayout Ha Hv Haccess.
  assert (Hentry : function_entry2 ge
    (skp_body version) [Vptr mario Ptrofs.zero] m empty_env (skp_entry version mario) m).
  { constructor.
    - destruct version; constructor.
    - destruct version; repeat constructor; cbn; tauto.
    - destruct version; vm_compute; intuition congruence.
    - destruct version; constructor.
    - destruct version; reflexivity. }
  assert (Hm : (skp_prefix_locals (skp_entry version mario)) ! SKP._m = Some (Vptr mario Ptrofs.zero))
    by (unfold skp_prefix_locals, skp_entry; skp_temp).
  destruct (skp_exact_gravity_branch ge empty_env _ m mario v Hlayout Hm Hv Haccess)
    as (after & Hbranch & Hload & Hframe).
  exists after. split; [|auto].
  eapply eval_funcall_internal.
  - exact Hentry.
  - eapply skp_gravity_body_from_branch; [exact Hlayout|unfold skp_entry; apply PTree.gss|exact Ha|exact Hbranch].
  - destruct version; reflexivity.
  - destruct version; reflexivity.
Qed.
