(** Regrabbing a HOLDABLE object changes its parent and held-state word.
    The complete generated helper does not transfer its area ownership or
    reactivate it.  This is not an assertion that a Bob-omb survived a warp. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib Ctypes
  Errors Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_helpers jp_object_helpers.
From LessThanOneAPress.Proofs Require Import GameTypes TeleporterHeldObjectState
  InkCopyCaller InkRawCopyExpressions InkRawCopySource InkBodyResetFrame
  EyerokRank15LiveMovement Area1PostCopyChildFrame SelectedClightTarget ObjectContactReadback
  ObjectContactNecessity ContactConsumerExecution TeleporterDestinationReset.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.
Module THO := us_object_helpers.

Definition tho_function := thos_set_held_function.
Definition tho_ge version := Clight.globalenv (selected_clight_target version).
Definition tho_address oo delta := Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr delta)).
Definition tho_object := Ederef (Etempvar THO._obj (tptr (Tstruct THO._Object noattr)))
  (Tstruct THO._Object noattr).
Definition tho_raw_array version := Efield (irc_raw_union version THO._obj)
  THO._asU32 (tarray tuint 80).
Definition tho_raw_word version index := Ederef
  (Ebinop Oadd (tho_raw_array version) (Econst_int (Int.repr index) tint) (tptr tuint)) tuint.
Definition tho_parent := Efield tho_object THO._parentObj (tptr (Tstruct THO._Object noattr)).
Definition tho_test script := Ebinop Oeq (Etempvar THO._heldBehavior (tptr tuint))
  (Evar script (tarray tuint 0)) tint.
Definition tho_holdable_test := Ebinop Oand (Etempvar THO._t'2 tuint)
  (Ebinop Oshl (Econst_int Int.one tint) (Econst_int (Int.repr 10) tint) tint) tuint.
Definition tho_parent_assignment := Sassign tho_parent
  (Etempvar THO._t'3 (tptr (Tstruct THO._Object noattr))).
Definition tho_effects version :=
  Ssequence (Sifthenelse (tho_test THO._bhvCarrySomething3)
    (Sassign (tho_raw_word version 39) (Econst_int Int.one tint)) Sskip)
    (Ssequence (Sifthenelse (tho_test THO._bhvCarrySomething5)
      (Sassign (tho_raw_word version 39) (Econst_int (Int.repr 2) tint)) Sskip)
      (Sifthenelse (tho_test THO._bhvCarrySomething4)
        (Sassign (tho_raw_word version 39) (Econst_int (Int.repr 3) tint)) Sskip)).
Definition tho_nonholdable version := match fn_body (tho_function version) with
  | Ssequence _ (Ssequence _ (Sifthenelse _ _ no)) => no | _ => Sskip end.

Lemma tho_generated_shape : forall version,
  fn_vars (tho_function version) = [] /\
  fn_params (tho_function version) =
    [(THO._obj, tptr (Tstruct THO._Object noattr)); (THO._heldBehavior, tptr tuint)] /\
  fn_return (tho_function version) = tvoid /\
  fn_body (tho_function version) =
    Ssequence (Ssequence
      (Sset THO._t'3 (Evar THO._gCurrentObject (tptr (Tstruct THO._Object noattr))))
      tho_parent_assignment)
      (Ssequence (Sset THO._t'2 (tho_raw_word version 1))
        (Sifthenelse tho_holdable_test (tho_effects version) (tho_nonholdable version))).
Proof. intros []; repeat split; reflexivity. Qed.

Lemma tho_parent_layout : forall version,
  ibcc_field_ok (tho_ge version) THO._Object THO._parentObj 104 = true.
Proof.
  intro version. change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    THO._Object THO._parentObj 104 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

Lemma tho_array_global_read : forall (ge : Clight.genv) e le m id b,
  e ! id = None -> Genv.find_symbol ge id = Some b ->
  eval_expr ge e le m (Evar id (tarray tuint 0)) (Vptr b Ptrofs.zero).
Proof.
  intros ge e le m id b Hlocal Hsymbol. eapply eval_Elvalue.
  - eapply eval_Evar_global; eauto.
  - apply deref_loc_reference. reflexivity.
Qed.

Lemma tho_pointer_comparison : forall (ge : Clight.genv) e le m script carry other,
  le ! THO._heldBehavior = Some (Vptr carry Ptrofs.zero) ->
  e ! script = None -> Genv.find_symbol ge script = Some other ->
  Mem.valid_pointer m carry 0 = true -> Mem.valid_pointer m other 0 = true ->
  eval_expr ge e le m (tho_test script)
    (Val.of_bool (if eq_block carry other then true else false)).
Proof.
  intros ge e le m script carry other Htemp Hlocal Hsymbol Hcarry Hother.
  unfold tho_test. eapply eval_Ebinop.
  - apply eval_Etempvar. exact Htemp.
  - eapply tho_array_global_read; eauto.
  - change (option_map Val.of_bool
      (Val.cmpu_bool (Mem.valid_pointer m) Ceq (Vptr carry Ptrofs.zero)
        (Vptr other Ptrofs.zero)) =
      Some (Val.of_bool (if eq_block carry other then true else false))).
    change (option_map Val.of_bool
      (if eq_block carry other then
        if (Mem.valid_pointer m carry 0 || Mem.valid_pointer m carry (-1)) &&
           (Mem.valid_pointer m other 0 || Mem.valid_pointer m other (-1))
        then Some true else None
      else if Mem.valid_pointer m carry 0 && Mem.valid_pointer m other 0
        then Some false else None) =
      Some (Val.of_bool (if eq_block carry other then true else false))).
    rewrite Hcarry, Hother. cbn.
    destruct (eq_block carry other); reflexivity.
Qed.

Lemma tho_holdable_condition : forall ge e le m flags,
  le ! THO._t'2 = Some (Vint flags) ->
  eval_expr ge e le m tho_holdable_test (Vint (Int.and flags (Int.repr 1024))).
Proof.
  intros ge e le m flags Htemp. unfold tho_holdable_test.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Htemp.
  - eapply eval_Ebinop; [constructor|constructor|reflexivity].
  - reflexivity.
Qed.

Lemma tho_parent_location_construct : forall version e le m ob oo,
  le ! THO._obj = Some (Vptr ob oo) ->
  eval_lvalue (tho_ge version) e le m tho_parent ob
    (Ptrofs.add oo (Ptrofs.repr 104)) Full.
Proof.
  intros version e le m ob oo Htemp.
  destruct (ibcc_field_ok_sound _ _ _ _ (tho_parent_layout version)) as (co & Hco & Hoff).
  unfold tho_parent, tho_object. eapply eval_Efield_struct with (co := co).
  - eapply eval_Elvalue.
    + apply eval_Ederef. apply eval_Etempvar. exact Htemp.
    + apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hco.
  - exact Hoff.
Qed.

Lemma tho_raw_array_construct : forall version e le m ob oo,
  le ! THO._obj = Some (Vptr ob oo) ->
  eval_expr (tho_ge version) e le m (tho_raw_array version)
    (Vptr ob (Ptrofs.add oo (Ptrofs.repr 136))).
Proof.
  intros version e le m ob oo Htemp.
  destruct (thos_selected_held_storage_layout version) as [Hfield [Hunion _]].
  destruct (ibcc_field_ok_sound _ _ _ _ Hfield) as (object_type & Hco & Hoff).
  destruct (pcc_union_check_sound _ _ _ Hunion) as (raw_type & Hraw & HunionOffset).
  unfold tho_raw_array, irc_raw_union, irc_raw_object.
  rewrite <- (Ptrofs.add_zero (Ptrofs.add oo (Ptrofs.repr 136))).
  eapply eval_Elvalue.
  - eapply eval_Efield_union with (co := raw_type).
    + eapply eval_Elvalue.
      * eapply eval_Efield_struct with (co := object_type).
        -- eapply eval_Elvalue.
           ++ apply eval_Ederef. apply eval_Etempvar. exact Htemp.
           ++ apply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- exact Hco.
        -- exact Hoff.
      * apply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hraw.
    + exact HunionOffset.
  - apply deref_loc_reference. reflexivity.
Qed.

Lemma tho_raw_location_construct : forall version e le m ob oo index,
  le ! THO._obj = Some (Vptr ob oo) -> In index [1;39] ->
  eval_lvalue (tho_ge version) e le m (tho_raw_word version index) ob
    (Ptrofs.add oo (Ptrofs.repr (136 + 4 * index))) Full.
Proof.
  intros version e le m ob oo index Htemp Hindex.
  unfold tho_raw_word. apply eval_Ederef.
  eapply eval_Ebinop.
  - eapply tho_raw_array_construct; eauto.
  - constructor.
  - destruct Hindex as [<-|[<-|[]]].
    + change (Some (Vptr ob (Ptrofs.add (Ptrofs.add oo (Ptrofs.repr 136))
        (Ptrofs.repr 4))) = Some (Vptr ob (Ptrofs.add oo (Ptrofs.repr 140)))).
      rewrite Ptrofs.add_assoc. reflexivity.
    + change (Some (Vptr ob (Ptrofs.add (Ptrofs.add oo (Ptrofs.repr 136))
        (Ptrofs.repr 156))) = Some (Vptr ob (Ptrofs.add oo (Ptrofs.repr 292)))).
      rewrite Ptrofs.add_assoc. reflexivity.
Qed.

Lemma tho_raw_read_construct : forall version e le m ob oo index value,
  le ! THO._obj = Some (Vptr ob oo) -> In index [1;39] ->
  Mem.load Mint32 m ob (tho_address oo (136 + 4 * index)) = Some value ->
  eval_expr (tho_ge version) e le m (tho_raw_word version index) value.
Proof.
  intros version e le m ob oo index value Htemp Hindex Hload.
  eapply eval_Elvalue.
  - eapply tho_raw_location_construct; eauto.
  - eapply deref_loc_value with (chunk := Mint32); [reflexivity|exact Hload].
Qed.

(** A path certificate is a restricted derivation of the real Clight rules,
    with no calls.  Its stores retain their actual addresses and cast values. *)
Inductive tho_path (ge : genv) (e : env) :
  temp_env -> mem -> statement -> temp_env -> mem -> Prop :=
| tho_skip : forall le m, tho_path ge e le m Sskip le m
| tho_set : forall le m id a v,
    eval_expr ge e le m a v ->
    tho_path ge e le m (Sset id a) (PTree.set id v le) m
| tho_assign : forall le m lhs rhs b ofs value cast after,
    access_mode (typeof lhs) = By_value Mint32 ->
    eval_lvalue ge e le m lhs b ofs Full ->
    eval_expr ge e le m rhs value ->
    sem_cast value (typeof rhs) (typeof lhs) m = Some cast ->
    Mem.store Mint32 m b (Ptrofs.unsigned ofs) cast = Some after ->
    tho_path ge e le m (Sassign lhs rhs) le after
| tho_seq : forall le m first middle next second last after,
    tho_path ge e le m first middle next ->
    tho_path ge e middle next second last after ->
    tho_path ge e le m (Ssequence first second) last after
| tho_if : forall le m a yes no v choice last after,
    eval_expr ge e le m a v ->
    bool_val v (typeof a) m = Some choice ->
    tho_path ge e le m (if choice then yes else no) last after ->
    tho_path ge e le m (Sifthenelse a yes no) last after.

Lemma tho_path_executes : forall ge e le m s last after,
  tho_path ge e le m s last after -> ocn_exec ge e le m s E0 last after Out_normal.
Proof.
  intros ge e le m s last after Hpath. induction Hpath.
  - constructor.
  - constructor; assumption.
  - eapply exec_Sassign; eauto. eapply assign_loc_value with (chunk := Mint32); eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); eauto.
  - eapply exec_Sifthenelse; eauto.
Qed.

Lemma tho_path_forces_execution : forall ge e le m s last after,
  tho_path ge e le m s last after ->
  forall t actual final out, ocn_exec ge e le m s t actual final out ->
  t = E0 /\ actual = last /\ final = after /\ out = Out_normal.
Proof.
  intros ge e le m s last after Hpath.
  induction Hpath as [le m|le m id a v Hvalue|
    le m lhs rhs b ofs value cast after Hmode Hl Hr Hcast Hstore|
    le m first middle next second last after Hp1 IH1 Hp2 IH2|
    le m a yes no v choice last after Hexpr Hbool Hp IH];
    intros t actual final out Hrun; inversion Hrun; subst.
  - repeat split; reflexivity.
  - match goal with Hv : eval_expr _ _ _ _ _ ?v,
      Hw : eval_expr _ _ _ _ _ ?w |- _ =>
      assert (v = w) by (eapply ocr_expr_unique; eauto); subst end.
    repeat split; reflexivity.
  - match goal with Ha : assign_loc _ _ _ ?c ?off ?bf _ _ |- _ =>
      assert (b = c /\ ofs = off /\ Full = bf) as Hplaces
        by (eapply (proj2 (ocr_expression_lvalue_unique ge e actual m)); eauto);
      destruct Hplaces as [? [? ?]]; subst end.
    match goal with Ha : assign_loc _ _ _ _ _ _ ?actual_cast _ |- _ =>
      assert (actual_cast = cast) as Hsamecast by
        (match goal with HC : sem_cast ?actual_value _ _ _ = Some actual_cast |- _ =>
          assert (actual_value = value) by (eapply ocr_expr_unique; eauto);
          subst actual_value; congruence end);
      subst actual_cast end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inversion Ha; subst; try congruence end.
    all: match goal with Haccess : access_mode _ = By_value ?chunk |- _ =>
      assert (chunk = Mint32) by congruence; subst chunk end.
    all: match goal with Hstore : Mem.storev _ _ _ _ = Some _ |- _ =>
      cbn [Mem.storev] in Hstore end.
    all: repeat split; congruence.
  - lazymatch goal with
    | Hfirst : ClightBigstep.exec_stmt _ _ _ _ _ first ?ft ?fl ?fm Out_normal |- _ =>
        pose proof (IH1 ft fl fm Out_normal Hfirst) as Hfirst_exact
    end.
    destruct Hfirst_exact as (Ht1 & Hle1 & Hm1 & Hout1).
    subst.
    lazymatch goal with
    | Hsecond : ClightBigstep.exec_stmt _ _ _ _ _ second ?st ?sl ?sm ?so |- _ =>
        pose proof (IH2 st sl sm so Hsecond) as Hsecond_exact
    end.
    destruct Hsecond_exact as (Ht2 & Hle2 & Hm2 & Hout2).
    subst.
    repeat split; reflexivity.
  - lazymatch goal with
    | Hfirst : ClightBigstep.exec_stmt _ _ _ _ _ first ?ft ?fl ?fm ?fo |- _ =>
        pose proof (IH1 ft fl fm fo Hfirst) as Hfirst_exact
    end.
    destruct Hfirst_exact as (Ht1 & Hle1 & Hm1 & Hout1).
    subst.
    contradiction.
  - match goal with Hv : eval_expr _ _ _ _ _ ?v,
      Hw : eval_expr _ _ _ _ _ ?w |- _ =>
      assert (v = w) by (eapply ocr_expr_unique; eauto); subst end.
    match goal with H1 : bool_val ?v ?ty ?m = Some ?b,
      H2 : bool_val ?v ?ty ?m = Some ?c |- _ =>
      assert (b = c) by congruence; subst end.
    eapply IH; eauto.
Qed.

Lemma tho_store_keeps_valid_pointer : forall chunk before b offset value after p position,
  Mem.store chunk before b offset value = Some after ->
  Mem.valid_pointer before p position = true -> Mem.valid_pointer after p position = true.
Proof.
  intros chunk before b offset value after p position Hstore Hvalid.
  apply Mem.valid_pointer_nonempty_perm. apply Mem.valid_pointer_nonempty_perm in Hvalid.
  eapply Mem.perm_store_1; eauto.
Qed.

Definition tho_script_receipt version memory carry fourth fifth : Prop :=
  Genv.find_symbol (tho_ge version) THO._bhvCarrySomething3 = Some carry /\
  Genv.find_symbol (tho_ge version) THO._bhvCarrySomething4 = Some fourth /\
  Genv.find_symbol (tho_ge version) THO._bhvCarrySomething5 = Some fifth /\
  carry <> fourth /\ carry <> fifth /\
  Mem.valid_pointer memory carry 0 = true /\
  Mem.valid_pointer memory fourth 0 = true /\
  Mem.valid_pointer memory fifth 0 = true.

Lemma tho_store_keeps_scripts : forall version before carry fourth fifth chunk b offset value after,
  tho_script_receipt version before carry fourth fifth ->
  Mem.store chunk before b offset value = Some after ->
  tho_script_receipt version after carry fourth fifth.
Proof.
  intros version before carry fourth fifth chunk b offset value after
    (H3 & H4 & H5 & H34 & H35 & Hv3 & Hv4 & Hv5) Hstore.
  repeat split; try assumption; eapply tho_store_keeps_valid_pointer; eauto.
Qed.

Definition tho_body_temps le parent flags :=
  PTree.set THO._t'2 (Vint flags) (PTree.set THO._t'3 parent le).

Lemma tho_complete_body_path : forall version le before ob oo cb pb po flags
    carry fourth fifth middle after,
  le ! THO._obj = Some (Vptr ob oo) ->
  le ! THO._heldBehavior = Some (Vptr carry Ptrofs.zero) ->
  Genv.find_symbol (tho_ge version) THO._gCurrentObject = Some cb ->
  Mem.load Mint32 before cb 0 = Some (Vptr pb po) ->
  Mem.load Mint32 before ob (tho_address oo 140) = Some (Vint flags) ->
  Int.and flags (Int.repr 1024) <> Int.zero ->
  tho_script_receipt version before carry fourth fifth ->
  tho_address oo 104 + 4 <= tho_address oo 140 ->
  Mem.store Mint32 before ob (tho_address oo 104) (Vptr pb po) = Some middle ->
  Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after ->
  tho_path (tho_ge version) empty_env le before (fn_body (tho_function version))
    (tho_body_temps le (Vptr pb po) flags) after.
Proof.
  intros version le before ob oo cb pb po flags carry fourth fifth middle after
    Hobj Harg Hcurrent Hparent Hflags Hhold Hscripts Hapart Hstore1 Hstore2.
  destruct (tho_store_keeps_scripts _ _ _ _ _ _ _ _ _ _ Hscripts Hstore1)
    as (Hs3 & Hs4 & Hs5 & H34 & H35 & Hv3 & Hv4 & Hv5).
  pose proof (tho_store_keeps_scripts _ _ _ _ _ _ _ _ _ _ Hscripts Hstore1)
    as HmiddleScripts.
  pose proof (tho_store_keeps_scripts _ _ _ _ _ _ _ _ _ _ HmiddleScripts Hstore2)
    as (_ & _ & _ & _ & _ & Ha3 & Ha4 & Ha5).
  assert (Mem.load Mint32 middle ob (tho_address oo 140) = Some (Vint flags)) as HmiddleFlags.
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore1 Mint32 ob (tho_address oo 140));
      [exact Hflags|right; right; exact Hapart]. }
  assert ((tho_body_temps le (Vptr pb po) flags) ! THO._obj = Some (Vptr ob oo)) as HbodyObj.
  { unfold tho_body_temps. rewrite !PTree.gso by discriminate. exact Hobj. }
  assert ((tho_body_temps le (Vptr pb po) flags) ! THO._heldBehavior =
    Some (Vptr carry Ptrofs.zero)) as HbodyArg.
  { unfold tho_body_temps. rewrite !PTree.gso by discriminate. exact Harg. }
  assert (eval_expr (tho_ge version) empty_env (tho_body_temps le (Vptr pb po) flags)
      middle (tho_test THO._bhvCarrySomething3) (Vint Int.one)) as Htest3.
  { pose proof (tho_pointer_comparison (tho_ge version) empty_env
      (tho_body_temps le (Vptr pb po) flags) middle THO._bhvCarrySomething3 carry carry
      HbodyArg (PTree.gempty _ _) Hs3 Hv3 Hv3) as H.
    destruct (eq_block carry carry); [exact H|contradiction]. }
  assert (eval_expr (tho_ge version) empty_env (tho_body_temps le (Vptr pb po) flags)
      after (tho_test THO._bhvCarrySomething5) (Vint Int.zero)) as Htest5.
  { pose proof (tho_pointer_comparison (tho_ge version) empty_env
      (tho_body_temps le (Vptr pb po) flags) after THO._bhvCarrySomething5 carry fifth
      HbodyArg (PTree.gempty _ _) Hs5 Ha3 Ha5) as H.
    destruct (eq_block carry fifth); [contradiction|exact H]. }
  assert (eval_expr (tho_ge version) empty_env (tho_body_temps le (Vptr pb po) flags)
      after (tho_test THO._bhvCarrySomething4) (Vint Int.zero)) as Htest4.
  { pose proof (tho_pointer_comparison (tho_ge version) empty_env
      (tho_body_temps le (Vptr pb po) flags) after THO._bhvCarrySomething4 carry fourth
      HbodyArg (PTree.gempty _ _) Hs4 Ha3 Ha4) as H.
    destruct (eq_block carry fourth); [contradiction|exact H]. }
  rewrite (proj2 (proj2 (proj2 (tho_generated_shape version)))).
  eapply tho_seq with (middle := PTree.set THO._t'3 (Vptr pb po) le) (next := middle).
  - eapply tho_seq.
    + apply tho_set. eapply eval_Elvalue.
      * eapply eval_Evar_global; [apply PTree.gempty|exact Hcurrent].
      * eapply deref_loc_value with (chunk := Mint32); [reflexivity|exact Hparent].
    + eapply tho_assign with (value := Vptr pb po) (cast := Vptr pb po).
      * reflexivity.
      * apply tho_parent_location_construct. rewrite PTree.gso by discriminate. exact Hobj.
      * apply eval_Etempvar. apply PTree.gss.
      * reflexivity.
      * exact Hstore1.
  - eapply tho_seq with (middle := tho_body_temps le (Vptr pb po) flags) (next := middle).
    + apply tho_set. eapply tho_raw_read_construct with (index := 1).
      * rewrite PTree.gso by discriminate. exact Hobj.
      * cbn; auto.
      * exact HmiddleFlags.
    + eapply tho_if with (v := Vint (Int.and flags (Int.repr 1024))) (choice := true).
      * apply tho_holdable_condition. unfold tho_body_temps. apply PTree.gss.
      * change (Some (negb (Int.eq (Int.and flags (Int.repr 1024)) Int.zero)) = Some true).
        apply Int.eq_false in Hhold. rewrite Hhold. reflexivity.
      * unfold tho_effects. eapply tho_seq.
        -- eapply tho_if with (v := Vint Int.one) (choice := true); [exact Htest3|reflexivity|].
           eapply tho_assign with (value := Vint Int.one) (cast := Vint Int.one).
           ++ reflexivity.
           ++ apply tho_raw_location_construct; [exact HbodyObj|cbn; auto].
           ++ constructor.
           ++ reflexivity.
           ++ exact Hstore2.
        -- eapply tho_seq.
           ++ eapply tho_if with (v := Vint Int.zero) (choice := false);
                [exact Htest5|reflexivity|constructor].
           ++ eapply tho_if with (v := Vint Int.zero) (choice := false);
                [exact Htest4|reflexivity|constructor].
Qed.

Definition tho_entry_temps version ob oo carry :=
  PTree.set THO._heldBehavior (Vptr carry Ptrofs.zero)
    (PTree.set THO._obj (Vptr ob oo) (create_undef_temps (fn_temps (tho_function version)))).

Lemma tho_construct_entry : forall version ge before ob oo carry,
  function_entry2 ge (tho_function version)
    [Vptr ob oo; Vptr carry Ptrofs.zero] before empty_env
    (tho_entry_temps version ob oo carry) before.
Proof.
  intros [] ge before ob oo carry; eapply function_entry2_intro.
  all: try (apply list_norepet_nil).
  all: try (vm_compute; repeat constructor; simpl; intuition congruence).
  all: try (vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence).
  all: try (apply alloc_variables_nil).
  all: reflexivity.
Qed.

Lemma tho_actual_entry : forall version ge before ob oo carry e le allocated,
  function_entry2 ge (tho_function version) [Vptr ob oo; Vptr carry Ptrofs.zero]
    before e le allocated ->
  e = empty_env /\ allocated = before /\ le = tho_entry_temps version ob oo carry.
Proof.
  intros version ge before ob oo carry e le allocated Hentry.
  destruct (tho_generated_shape version) as (Hvars & Hparams & _).
  inversion Hentry; subst; clear Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  repeat split; try reflexivity.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb;
    inversion Hb; reflexivity end.
Qed.

(** These are concrete readable/writable object cells and actual selected
    script addresses, not a hypothesis that the callee preserves ownership. *)
Definition tho_inputs version before ob oo cb pb po flags carry fourth fifth : Prop :=
  Genv.find_symbol (tho_ge version) THO._gCurrentObject = Some cb /\
  Mem.load Mint32 before cb 0 = Some (Vptr pb po) /\
  Mem.load Mint32 before ob (tho_address oo 140) = Some (Vint flags) /\
  Int.and flags (Int.repr 1024) <> Int.zero /\
  tho_script_receipt version before carry fourth fifth /\
  tho_address oo 104 + 4 <= tho_address oo 140 /\
  Mem.valid_access before Mint32 ob (tho_address oo 104) Writable /\
  Mem.valid_access before Mint32 ob (tho_address oo 292) Writable.

Lemma tho_inputs_supply_path : forall version before ob oo cb pb po flags carry fourth fifth,
  tho_inputs version before ob oo cb pb po flags carry fourth fifth ->
  exists middle after,
    Mem.store Mint32 before ob (tho_address oo 104) (Vptr pb po) = Some middle /\
    Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after /\
    tho_path (tho_ge version) empty_env (tho_entry_temps version ob oo carry) before
      (fn_body (tho_function version))
      (tho_body_temps (tho_entry_temps version ob oo carry) (Vptr pb po) flags) after.
Proof.
  intros version before ob oo cb pb po flags carry fourth fifth
    (Hcurrent & Hparent & Hflags & Hhold & Hscripts & Hapart & HparentWrite & HheldWrite).
  destruct (Mem.valid_access_store _ _ _ _ (Vptr pb po) HparentWrite) as (middle & Hstore1).
  assert (Mem.valid_access middle Mint32 ob (tho_address oo 292) Writable) as HheldWriteMiddle.
  { eapply Mem.store_valid_access_1; eauto. }
  destruct (Mem.valid_access_store _ _ _ _ (Vint Int.one) HheldWriteMiddle) as (after & Hstore2).
  exists middle, after. split; [exact Hstore1|]. split; [exact Hstore2|].
  eapply tho_complete_body_path; eauto.
  - unfold tho_entry_temps. rewrite PTree.gso by discriminate. apply PTree.gss.
  - unfold tho_entry_temps. apply PTree.gss.
Qed.

Definition THOCompleteHelperExecutes : Prop :=
  forall version before ob oo cb pb po flags carry fourth fifth,
  tho_inputs version before ob oo cb pb po flags carry fourth fifth ->
  exists middle after,
    Mem.store Mint32 before ob (tho_address oo 104) (Vptr pb po) = Some middle /\
    Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after /\
    ClightBigstep.Clight2.eval_funcall (tho_ge version) before
      (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero] E0 after Vundef.

Theorem tho_complete_helper_executes : THOCompleteHelperExecutes.
Proof.
  intros version before ob oo cb pb po flags carry fourth fifth Hinputs.
  destruct (tho_inputs_supply_path _ _ _ _ _ _ _ _ _ _ _ Hinputs)
    as (middle & after & Hstore1 & Hstore2 & Hpath).
  exists middle, after. split; [exact Hstore1|]. split; [exact Hstore2|].
  eapply eval_funcall_internal with (e := empty_env)
    (le1 := tho_entry_temps version ob oo carry)
    (le2 := tho_body_temps (tho_entry_temps version ob oo carry) (Vptr pb po) flags)
    (m1 := before) (m2 := after) (out := Out_normal).
  - apply tho_construct_entry.
  - apply tho_path_executes. exact Hpath.
  - rewrite (proj1 (proj2 (proj2 (tho_generated_shape version)))). reflexivity.
  - reflexivity.
Qed.

Definition THOCompleteHelperExactStores : Prop :=
  forall version before ob oo cb pb po flags carry fourth fifth trace after result,
  tho_inputs version before ob oo cb pb po flags carry fourth fifth ->
  ClightBigstep.Clight2.eval_funcall (tho_ge version) before
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero] trace after result ->
  trace = E0 /\ result = Vundef /\ exists middle,
    Mem.store Mint32 before ob (tho_address oo 104) (Vptr pb po) = Some middle /\
    Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after.

Theorem tho_complete_helper_exact_stores : THOCompleteHelperExactStores.
Proof.
  intros version before ob oo cb pb po flags carry fourth fifth trace after result Hinputs Hcall.
  destruct (tho_inputs_supply_path _ _ _ _ _ _ _ _ _ _ _ Hinputs)
    as (middle & expected & Hstore1 & Hstore2 & Hpath).
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    destruct (tho_actual_entry _ _ _ _ _ _ _ _ _ Hentry) as (-> & -> & ->) end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (tho_path_forces_execution _ _ _ _ _ _ _ Hpath _ _ _ _ Hbody)
      as (-> & -> & -> & ->) end.
  match goal with Hfree : Mem.free_list ?body (blocks_of_env _ empty_env) = Some ?final |- _ =>
    change (Some body = Some final) in Hfree; inversion Hfree; subst end.
  match goal with Hresult : outcome_result_value _ _ _ _ |- _ =>
    rewrite (proj1 (proj2 (proj2 (tho_generated_shape version)))) in Hresult;
    cbn in Hresult; subst result end.
  repeat split; try reflexivity. exists middle. auto.
Qed.

Lemma tho_address_no_wrap : forall oo delta,
  Ptrofs.unsigned oo + 296 <= Ptrofs.modulus -> 0 <= delta <= 292 ->
  tho_address oo delta = Ptrofs.unsigned oo + delta.
Proof.
  intros oo delta Hspan Hdelta.
  assert (Ptrofs.unsigned (Ptrofs.repr delta) = delta) as Hrepr.
  { apply Ptrofs.unsigned_repr. change (0 <= delta <= Ptrofs.modulus - 1).
    pose proof (Ptrofs.unsigned_range oo). lia. }
  unfold tho_address, Ptrofs.add. rewrite Hrepr. apply Ptrofs.unsigned_repr.
  change (0 <= Ptrofs.unsigned oo + delta <= Ptrofs.modulus - 1).
  pose proof (Ptrofs.unsigned_range oo). lia.
Qed.

Lemma tho_two_stores_preserve_ownership_and_activity :
  forall before ob oo parent middle after chunk delta,
  Ptrofs.unsigned oo + 296 <= Ptrofs.modulus ->
  In delta [24;25;116] -> 0 < size_chunk chunk <= 4 ->
  Mem.store Mint32 before ob (tho_address oo 104) parent = Some middle ->
  Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after ->
  Mem.load chunk after ob (tho_address oo delta) =
    Mem.load chunk before ob (tho_address oo delta).
Proof.
  intros before ob oo parent middle after chunk delta Hspan Hdelta Hchunk Hstore1 Hstore2.
  assert (tho_address oo 104 = Ptrofs.unsigned oo + 104) as H104
    by (apply tho_address_no_wrap; lia).
  assert (tho_address oo 292 = Ptrofs.unsigned oo + 292) as H292
    by (apply tho_address_no_wrap; lia).
  assert (0 <= delta <= 116) as Hrange by
    (destruct Hdelta as [<-|[<-|[<-|[]]]]; lia).
  assert (tho_address oo delta = Ptrofs.unsigned oo + delta) as Hd
    by (apply tho_address_no_wrap; lia).
  rewrite H104 in Hstore1. rewrite H292 in Hstore2. rewrite Hd.
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore2 chunk ob (Ptrofs.unsigned oo + delta))
    by (right; left; cbn; lia).
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore1 chunk ob (Ptrofs.unsigned oo + delta)).
  - reflexivity.
  - destruct Hdelta as [<-|[<-|[<-|[]]]];
      (right; left; cbn; lia) || (right; right; cbn; lia).
Qed.

Definition THOCompleteOwnershipAndActivityFrame : Prop :=
  forall version before ob oo cb pb po flags carry fourth fifth trace after result chunk delta,
  tho_inputs version before ob oo cb pb po flags carry fourth fifth ->
  Ptrofs.unsigned oo + 296 <= Ptrofs.modulus ->
  In delta [24;25;116] -> 0 < size_chunk chunk <= 4 ->
  ClightBigstep.Clight2.eval_funcall (tho_ge version) before
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero] trace after result ->
  Mem.load chunk after ob (tho_address oo delta) =
    Mem.load chunk before ob (tho_address oo delta).

Theorem tho_complete_ownership_and_activity_frame : THOCompleteOwnershipAndActivityFrame.
Proof.
  intros version before ob oo cb pb po flags carry fourth fifth trace after result chunk delta
    Hinputs Hspan Hdelta Hchunk Hcall.
  destruct (tho_complete_helper_exact_stores _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hinputs Hcall)
    as (_ & _ & middle & Hstore1 & Hstore2).
  eapply tho_two_stores_preserve_ownership_and_activity; eauto.
Qed.

Definition THOSelectedProtectedLayout : Prop := forall version,
  ibcc_field_ok (tho_ge version) THO._Object THO._header 0 = true /\
  ibcc_field_ok (tho_ge version) THO._ObjectNode THO._gfx 0 = true /\
  ibcc_field_ok (tho_ge version) THO._GraphNodeObject THO._areaIndex 24 = true /\
  ibcc_field_ok (tho_ge version) THO._GraphNodeObject THO._activeAreaIndex 25 = true /\
  ibcc_field_ok (tho_ge version) THO._Object THO._activeFlags 116 = true.
Theorem tho_selected_protected_layout : THOSelectedProtectedLayout.
Proof.
  intro version. unfold tho_ge.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version)) THO._Object THO._header 0 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version)) THO._ObjectNode THO._gfx 0 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version)) THO._GraphNodeObject THO._areaIndex 24 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version)) THO._GraphNodeObject THO._activeAreaIndex 25 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version)) THO._Object THO._activeFlags 116 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; repeat split; reflexivity.
Qed.

Definition THOCompleteHelperDoesNotRevive : Prop :=
  forall version before ob oo cb pb po flags carry fourth fifth trace after result,
  tho_inputs version before ob oo cb pb po flags carry fourth fifth ->
  Ptrofs.unsigned oo + 296 <= Ptrofs.modulus ->
  Mem.load Mint16signed before ob (tho_address oo 116) = Some (Vint Int.zero) ->
  ClightBigstep.Clight2.eval_funcall (tho_ge version) before
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero] trace after result ->
  Mem.load Mint16signed after ob (tho_address oo 116) = Some (Vint Int.zero).
Theorem tho_complete_helper_does_not_revive : THOCompleteHelperDoesNotRevive.
Proof.
  intros version before ob oo cb pb po flags carry fourth fifth trace after result
    Hinputs Hspan Hdead Hcall.
  rewrite (tho_complete_ownership_and_activity_frame version before ob oo cb pb po flags
    carry fourth fifth trace after result Mint16signed 116 Hinputs Hspan
    ltac:(cbn; auto) ltac:(cbn; lia) Hcall). exact Hdead.
Qed.

Definition TeleporterHeldOwnershipBoundary : Prop :=
  THOSelectedProtectedLayout /\ THOCompleteHelperExecutes /\ THOCompleteHelperExactStores /\
  THOCompleteOwnershipAndActivityFrame /\ THOCompleteHelperDoesNotRevive.
Theorem teleporter_held_ownership_boundary_checked : TeleporterHeldOwnershipBoundary.
Proof.
  split; [exact tho_selected_protected_layout|].
  split; [exact tho_complete_helper_executes|].
  split; [exact tho_complete_helper_exact_stores|].
  split; [exact tho_complete_ownership_and_activity_frame|exact tho_complete_helper_does_not_revive].
Qed.
