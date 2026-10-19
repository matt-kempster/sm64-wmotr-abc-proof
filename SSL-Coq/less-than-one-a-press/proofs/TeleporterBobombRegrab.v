(** Regrabbing is a concrete pointer restoration, rather than an inference
    from the Bob-omb's private held-state word.  This module follows the real
    grab call through the selected held-state helper.  Collision eligibility,
    the pickup animation and survival to this call remain separate questions. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction
  us_object_helpers.
From LessThanOneAPress.Proofs Require Import GameTypes InkCopyCaller
  ObjectContactNecessity ObjectContactReadback ReadOnlyClightPaths
  TeleporterDestinationReset TeleporterNullRelease TeleporterHeldOwnership
  InkBackwardExecution ContactConsumerExecution SecretContactExecution
  SelectedClightTarget UpperElevatorQueryResolution CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair EyerokRank15LiveMovement.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.
Module TRB := us_interaction.

Definition trb_function version := match version with
| VersionUS => TRB.f_mario_grab_used_object
| VersionJP => jp_interaction.f_mario_grab_used_object end.
Definition trb_field field := Efield
  (Ederef (Etempvar TRB._m (tptr (Tstruct TRB._MarioState noattr)))
    (Tstruct TRB._MarioState noattr)) field
  (tptr (Tstruct TRB._Object noattr)).
Definition trb_guard := Ebinop Oeq
  (Etempvar TRB._t'1 (tptr (Tstruct TRB._Object noattr)))
  (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint.
Definition trb_restore := Ssequence
  (Sset TRB._t'3 (trb_field TRB._usedObj))
  (Sassign (trb_field TRB._heldObj)
    (Etempvar TRB._t'3 (tptr (Tstruct TRB._Object noattr)))).
Definition trb_helper_call := Scall None
  (Evar TRB._obj_set_held_state
    (Tfunction [tptr (Tstruct TRB._Object noattr); tptr tuint] tvoid cc_default))
  [Etempvar TRB._t'2 (tptr (Tstruct TRB._Object noattr));
   Evar TRB._bhvCarrySomething3 (tarray tuint 0)].
Definition trb_tail := Ssequence
  (Sset TRB._t'2 (trb_field TRB._heldObj)) trb_helper_call.
Definition trb_entry_temps version mb mo := PTree.set TRB._m (Vptr mb mo)
  (create_undef_temps (fn_temps (trb_function version))).

Lemma trb_generated_shape : forall version,
  fn_vars (trb_function version) = [] /\
  fn_params (trb_function version) =
    [(TRB._m, tptr (Tstruct TRB._MarioState noattr))] /\
  fn_return (trb_function version) = tvoid /\
  fn_body (trb_function version) = Ssequence
    (Sset TRB._t'1 (trb_field TRB._heldObj))
    (Sifthenelse trb_guard (Ssequence trb_restore trb_tail) Sskip).
Proof. intros []; repeat split; reflexivity. Qed.

Lemma trb_us_source :
  nth_error TRB.global_definitions
    (ueqr_definition_index TRB._mario_grab_used_object TRB.global_definitions) =
  Some (TRB._mario_grab_used_object, Gfun (Internal (trb_function VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma trb_us_member :
  In (TRB._mario_grab_used_object, Gfun (Internal (trb_function VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 10 us_units).
  - exact (us_nlist_at_nIn _ 10 us_units).
  - change (In (TRB._mario_grab_used_object, Gfun (Internal (trb_function VersionUS)))
      TRB.global_definitions). eapply nth_error_In. exact trb_us_source.
Qed.

Lemma trb_helper_inputs_after_restore : forall version memory restored mb mo ob oo
    cb pb po flags carry fourth fifth,
  mb <> ob -> mb <> cb ->
  tho_inputs version memory ob oo cb pb po flags carry fourth fifth ->
  Mem.store Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored ->
  tho_inputs version restored ob oo cb pb po flags carry fourth fifth.
Proof.
  intros version memory restored mb mo ob oo cb pb po flags carry fourth fifth
    Hobject Hglobal (Hsymbol & Hcurrent & Hflags & Hhold & Hscripts & Hapart & Hw1 & Hw2)
    Hstore.
  unfold tho_inputs. split; [exact Hsymbol|].
  split.
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (left; congruence).
    exact Hcurrent. }
  split.
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (left; congruence).
    exact Hflags. }
  split; [exact Hhold|]. split.
  { eapply tho_store_keeps_scripts; eauto. }
  split; [exact Hapart|]. split; eapply Mem.store_valid_access_1; eauto.
Qed.

Definition trb_storage version memory mb mo ob oo cb pb po flags carry fourth fifth : Prop :=
  mb <> ob /\ mb <> cb /\
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) /\
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) /\
  Mem.valid_access memory Mptr mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) Writable /\
  tho_inputs version memory ob oo cb pb po flags carry fourth fifth.

Definition trb_post memory after mb mo ob oo pb po : Prop :=
  exists restored middle,
    Mem.store Mptr memory mb
      (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored /\
    Mem.store Mint32 restored ob (tho_address oo 104) (Vptr pb po) = Some middle /\
    Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after /\
    Mem.load Mptr after mb
      (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vptr ob oo) /\
    Mem.load Mint32 after ob (tho_address oo 292) = Some (Vint Int.one).

Lemma trb_three_stores_restore : forall memory restored middle after mb mo ob oo pb po,
  mb <> ob ->
  Mem.store Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored ->
  Mem.store Mint32 restored ob (tho_address oo 104) (Vptr pb po) = Some middle ->
  Mem.store Mint32 middle ob (tho_address oo 292) (Vint Int.one) = Some after ->
  trb_post memory after mb mo ob oo pb po.
Proof.
  intros memory restored middle after mb mo ob oo pb po Hseparate Hrestore Hparent Hheld.
  exists restored, middle. repeat split; try assumption.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hheld) by (left; congruence).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hparent) by (left; congruence).
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hrestore). reflexivity.
  - rewrite (Mem.load_store_same _ _ _ _ _ _ Hheld). reflexivity.
Qed.

Lemma trb_null_guard : forall ge e le memory,
  le ! TRB._t'1 = Some (Vint Int.zero) ->
  eval_expr ge e le memory trb_guard (Vint Int.one).
Proof.
  intros ge e le memory Htemp. unfold trb_guard. eapply eval_Ebinop.
  - apply eval_Etempvar. exact Htemp.
  - eapply eval_Ecast; [constructor|reflexivity].
  - reflexivity.
Qed.

Lemma trb_reached_helper : forall version e le memory ob oo carry fb
    trace last after out,
  e ! TRB._obj_set_held_state = None ->
  e ! TRB._bhvCarrySomething3 = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._obj_set_held_state = Some fb ->
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) fb =
    Some (Internal (tho_function version)) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry ->
  le ! TRB._t'2 = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory
    trb_helper_call trace last after out ->
  exists result, ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero]
    trace after result /\ last = le /\ out = Out_normal.
Proof.
  intros version e le memory ob oo carry fb trace last after out
    Hlocal Hcarrylocal Hsymbol Hfunction Hcarry Htemp Hrun.
  unfold trb_helper_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  lazymatch goal with Hread : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr fb Ptrofs.zero) by
      (exact (sce_function_name_value _ e le memory TRB._obj_set_held_state
        [tptr (Tstruct TRB._Object noattr); tptr tuint] tvoid cc_default fb vf
        Hlocal Hsymbol Hread)); subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) fb = Some fd)
      in Hfind; rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hargs : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ =>
    inversion Hargs; subst; clear Hargs end.
  match goal with Hread : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hcast : sem_cast (Vptr ob oo) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr ob oo) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Hargs : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ =>
    inversion Hargs; subst; clear Hargs end.
  lazymatch goal with Hread : eval_expr _ _ _ _ (Evar TRB._bhvCarrySomething3 _) ?v |- _ =>
    assert (v = Vptr carry Ptrofs.zero) by
      (eapply ocr_expr_unique; [exact Hread|];
       eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full);
       [apply eval_Evar_global; [exact Hcarrylocal|exact Hcarry]
       |apply deref_loc_reference; reflexivity]);
    subst v end.
  match goal with Hcast : sem_cast (Vptr carry Ptrofs.zero) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr carry Ptrofs.zero) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Hargs : eval_exprlist _ _ _ _ [] _ _ |- _ => inversion Hargs; subst end.
  eauto 8.
Qed.
Lemma trb_us_selection :
  us_normalized_global_definition_map ! TRB._mario_grab_used_object =
    Some (Gfun (Internal (trb_function VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact trb_us_member.
Qed.
Lemma trb_us_selected_member :
  In (TRB._mario_grab_used_object, Gfun (Internal (trb_function VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (TRB._mario_grab_used_object, Gfun (Internal (trb_function VersionUS))) = false)
      as Hrepair by (vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact trb_us_selection.
Qed.
Theorem trb_selected_grab_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._mario_grab_used_object = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (trb_function version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact trb_us_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 10 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 10 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.

Lemma trb_used_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    TRB._MarioState TRB._usedObj 128 = true.
Proof.
  intro version. change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    TRB._MarioState TRB._usedObj 128 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

Lemma trb_helper_us_source :
  nth_error us_object_helpers.global_definitions
    (ueqr_definition_index TRB._obj_set_held_state us_object_helpers.global_definitions) =
  Some (TRB._obj_set_held_state, Gfun (Internal (tho_function VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma trb_helper_us_member :
  In (TRB._obj_set_held_state, Gfun (Internal (tho_function VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 19 us_units).
  - exact (us_nlist_at_nIn _ 19 us_units).
  - change (In (TRB._obj_set_held_state, Gfun (Internal (tho_function VersionUS)))
      us_object_helpers.global_definitions). eapply nth_error_In. exact trb_helper_us_source.
Qed.
Lemma trb_helper_us_selection :
  us_normalized_global_definition_map ! TRB._obj_set_held_state =
    Some (Gfun (Internal (tho_function VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact trb_helper_us_member.
Qed.
Lemma trb_helper_us_selected_member :
  In (TRB._obj_set_held_state, Gfun (Internal (tho_function VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (TRB._obj_set_held_state, Gfun (Internal (tho_function VersionUS))) = false)
      as Hrepair by (vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact trb_helper_us_selection.
Qed.
Theorem trb_selected_helper_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._obj_set_held_state = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tho_function version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact trb_helper_us_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 19 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 19 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.
Lemma trb_actual_pointer_read : forall version e le memory mb mo field delta value,
  le ! TRB._m = Some (Vptr mb mo) ->
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    TRB._MarioState field delta = true ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr delta))) = Some value ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le memory
    (trb_field field) value.
Proof.
  intros version e le memory mb mo field delta value Htemp Hfield Hload.
  destruct (ibcc_field_ok_sound _ _ _ _ Hfield) as (co & Hco & Hoff).
  unfold trb_field. eapply eval_Elvalue with
    (ofs := Ptrofs.add mo (Ptrofs.repr delta)) (bf := Full).
  - eapply eval_Efield_struct with (co := co).
    + eapply eval_Elvalue.
      * apply eval_Ederef. apply eval_Etempvar. exact Htemp.
      * apply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hco.
    + exact Hoff.
  - eapply deref_loc_value with (chunk := Mptr); eauto.
Qed.

Lemma trb_actual_restore : forall version e le memory mb mo ob oo
    trace last after out,
  le ! TRB._m = Some (Vptr mb mo) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory
    trb_restore trace last after out ->
  trace = E0 /\ last = PTree.set TRB._t'3 (Vptr ob oo) le /\ out = Out_normal /\
  Mem.store Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some after /\
  Mem.load Mptr after mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vptr ob oo).
Proof.
  intros version e le memory mb mo ob oo trace last after out Hm Hused Hrun.
  unfold trb_restore in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: match goal with Hread : eval_expr _ _ _ _ (trb_field TRB._usedObj) ?value |- _ =>
    assert (value = Vptr ob oo) by
      (eapply ocr_expr_unique; [exact Hread|eapply trb_actual_pointer_read;
        [exact Hm|exact (trb_used_layout version)|exact Hused]]); subst value end.
  all: match goal with Hassign : ClightBigstep.exec_stmt _ _ _ _ _
      (Sassign _ _) _ _ _ _ |- _ =>
    inversion Hassign; subst; clear Hassign end.
  all: lazymatch goal with Hl : eval_lvalue
      (Clight.globalenv (selected_clight_target ?actual_version))
      ?actual_env ?actual_temps ?actual_memory
      (trb_field TRB._heldObj) _ _ _ |- _ =>
    unfold trb_field in Hl;
    destruct (ibcc_field_location (Clight.globalenv (selected_clight_target actual_version))
      actual_env actual_temps actual_memory
      (Ederef (Etempvar TRB._m (tptr (Tstruct TRB._MarioState noattr)))
        (Tstruct TRB._MarioState noattr)) TRB._MarioState TRB._heldObj
      (tptr (Tstruct TRB._Object noattr)) mb mo 124 _ _ _ eq_refl
      ltac:(intros; eapply (ibcc_deref_struct
        (Clight.globalenv (selected_clight_target actual_version)) actual_env actual_temps
        actual_memory TRB._m TRB._MarioState mb mo);
        [rewrite PTree.gso by discriminate; exact Hm|eassumption])
      (tdr_selected_held_field_layout actual_version) Hl) as (-> & -> & ->) end.
  all: lazymatch goal with Hr : eval_expr _ _ _ _ (Etempvar TRB._t'3 _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocn_temp_value; [exact Hr|apply PTree.gss]); subst v end.
  all: match goal with Hcast : sem_cast _ _ _ _ = Some ?value |- _ =>
    change (Some (Vptr ob oo) = Some value) in Hcast; inversion Hcast; subst value end.
  all: match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  all: match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  all: match goal with Hstore : Mem.storev _ ?store_memory _ _ = Some ?store_after |- _ =>
    change (Mem.store Mptr store_memory mb
      (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some store_after) in Hstore;
    repeat split; try assumption; try reflexivity;
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore); reflexivity end.
Qed.

Lemma trb_actual_body_reaches_helper : forall version e le memory mb mo ob oo carry fb
    trace last after out,
  e ! TRB._obj_set_held_state = None ->
  e ! TRB._bhvCarrySomething3 = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._obj_set_held_state = Some fb ->
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) fb =
    Some (Internal (tho_function version)) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry ->
  le ! TRB._m = Some (Vptr mb mo) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory
    (fn_body (trb_function version)) trace last after out ->
  exists restored result,
    Mem.store Mptr memory mb
      (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) restored
      (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero]
      trace after result /\ out = Out_normal.
Proof.
  intros version e le memory mb mo ob oo carry fb trace last after out
    Hlocal Hcarrylocal Hsymbol Hfunction Hcarry Hm Hnull Hused Hrun.
  rewrite (proj2 (proj2 (proj2 (trb_generated_shape version)))) in Hrun.
  destruct (ibk_split_sequence _ _ _ _
    (Sset TRB._t'1 (trb_field TRB._heldObj)) _ _ _ _ _ eq_refl Hrun)
    as (read_le & read_m & pre & rest & Htrace & Hread & Hchoice).
  assert (readonly_path (Clight.globalenv (selected_clight_target version)) e memory le
    (Sset TRB._t'1 (trb_field TRB._heldObj))
    (PTree.set TRB._t'1 (Vint Int.zero) le)) as Hpath.
  { apply ro_set. eapply trb_actual_pointer_read;
      [exact Hm|exact (tdr_selected_held_field_layout version)|exact Hnull]. }
  destruct (readonly_path_forces_every_execution _ _ _ _ _ _ Hpath _ _ _ _ Hread)
    as (-> & -> & -> & _).
  inversion Hchoice; subst.
  match goal with Hguard : eval_expr _ _ _ _ trb_guard ?v |- _ =>
    assert (v = Vint Int.one) by
      (eapply ocr_expr_unique; [exact Hguard|apply trb_null_guard; apply PTree.gss]); subst v end.
  match goal with Hb : bool_val (Vint Int.one) _ _ = Some ?choice |- _ =>
    change (Some true = Some choice) in Hb; inversion Hb; subst choice end.
  match goal with Haccepted : ClightBigstep.exec_stmt _ _ _ _ _
      (Ssequence trb_restore trb_tail) _ _ _ _ |- _ =>
    destruct (ibk_split_sequence _ _ _ _ trb_restore _ _ _ _ _ eq_refl Haccepted)
      as (restored_le & restored & prefix & helper_t & Hacceptedtrace & Hrestore & Htail) end.
  assert ((PTree.set TRB._t'1 (Vint Int.zero) le) ! TRB._m = Some (Vptr mb mo)) as Hm1.
  { rewrite PTree.gso by discriminate. exact Hm. }
  destruct (trb_actual_restore version e _ memory mb mo ob oo _ _ _ _ Hm1 Hused Hrestore)
    as (-> & -> & _ & Hstore & Hheld).
  unfold trb_tail in Htail.
  destruct (ibk_split_sequence _ _ _ _
    (Sset TRB._t'2 (trb_field TRB._heldObj)) _ _ _ _ _ eq_refl Htail)
    as (call_le & call_m & read_t & call_t & Htailtrace & Hheldread & Hcall).
  assert (readonly_path (Clight.globalenv (selected_clight_target version)) e restored
    (PTree.set TRB._t'3 (Vptr ob oo) (PTree.set TRB._t'1 (Vint Int.zero) le))
    (Sset TRB._t'2 (trb_field TRB._heldObj))
    (PTree.set TRB._t'2 (Vptr ob oo)
      (PTree.set TRB._t'3 (Vptr ob oo) (PTree.set TRB._t'1 (Vint Int.zero) le)))) as Hheldpath.
  { apply ro_set. eapply trb_actual_pointer_read.
    - repeat rewrite PTree.gso by discriminate. exact Hm.
    - exact (tdr_selected_held_field_layout version).
    - exact Hheld. }
  destruct (readonly_path_forces_every_execution _ _ _ _ _ _ Hheldpath _ _ _ _ Hheldread)
    as (-> & -> & -> & _).
  destruct (trb_reached_helper version e _ restored ob oo carry fb _ _ _ _
    Hlocal Hcarrylocal Hsymbol Hfunction Hcarry (PTree.gss _ _ _) Hcall)
    as (result & Hhelper & _ & Hnormal).
  exists restored, result. repeat split; try assumption.
  all: unfold Eapp in *; cbn in Hacceptedtrace, Htailtrace;
    subst; exact Hhelper.
Qed.

Lemma trb_actual_entry : forall version ge memory mb mo e le allocated,
  function_entry2 ge (trb_function version) [Vptr mb mo]
    memory e le allocated ->
  e = empty_env /\ allocated = memory /\ le ! TRB._m = Some (Vptr mb mo).
Proof.
  intros version ge memory mb mo e le allocated Hentry.
  destruct (trb_generated_shape version) as (Hvars & Hparams & _).
  inversion Hentry; subst; clear Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  repeat split; try reflexivity.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb;
    inversion Hb; subst temps; apply PTree.gss end.
Qed.

Lemma trb_held_location : forall version e le memory mb mo,
  le ! TRB._m = Some (Vptr mb mo) ->
  eval_lvalue (Clight.globalenv (selected_clight_target version)) e le memory
    (trb_field TRB._heldObj) mb (Ptrofs.add mo (Ptrofs.repr 124)) Full.
Proof.
  intros version e le memory mb mo Htemp.
  destruct (ibcc_field_ok_sound _ _ _ _ (tdr_selected_held_field_layout version))
    as (co & Hco & Hoff).
  unfold trb_field. eapply eval_Efield_struct with (co := co).
  - eapply eval_Elvalue.
    + apply eval_Ederef. apply eval_Etempvar. exact Htemp.
    + apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hco.
  - exact Hoff.
Qed.

Lemma trb_construct_restore : forall version e le memory mb mo ob oo restored,
  le ! TRB._m = Some (Vptr mb mo) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) ->
  Mem.store Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory trb_restore
    E0 (PTree.set TRB._t'3 (Vptr ob oo) le) restored Out_normal.
Proof.
  intros version e le memory mb mo ob oo restored Hm Hused Hstore.
  unfold trb_restore. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply trb_actual_pointer_read;
      [exact Hm|exact (trb_used_layout version)|exact Hused].
  - eapply exec_Sassign with (v := Vptr ob oo) (v2 := Vptr ob oo).
    + apply trb_held_location. rewrite PTree.gso by discriminate. exact Hm.
    + apply eval_Etempvar. apply PTree.gss.
    + reflexivity.
    + eapply assign_loc_value with (chunk := Mptr); [reflexivity|exact Hstore].
Qed.

Lemma trb_construct_body : forall version e le memory mb mo ob oo carry fb
    restored trace after result,
  e ! TRB._obj_set_held_state = None ->
  e ! TRB._bhvCarrySomething3 = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._obj_set_held_state = Some fb ->
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) fb =
    Some (Internal (tho_function version)) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry ->
  le ! TRB._m = Some (Vptr mb mo) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) ->
  Mem.store Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) restored
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero]
    trace after result ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory
    (fn_body (trb_function version)) trace
    (PTree.set TRB._t'2 (Vptr ob oo)
      (PTree.set TRB._t'3 (Vptr ob oo) (PTree.set TRB._t'1 (Vint Int.zero) le)))
    after Out_normal.
Proof.
  intros version e le memory mb mo ob oo carry fb restored trace after result
    Hlocal Hcarrylocal Hsymbol Hfunction Hcarry Hm Hnull Hused Hstore Hhelper.
  rewrite (proj2 (proj2 (proj2 (trb_generated_shape version)))).
  rewrite <- (app_nil_l trace) at 1.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
  - apply exec_Sset. eapply trb_actual_pointer_read;
      [exact Hm|exact (tdr_selected_held_field_layout version)|exact Hnull].
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + apply trb_null_guard. apply PTree.gss.
    + reflexivity.
    + rewrite <- (app_nil_l trace) at 1.
      eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
      * eapply trb_construct_restore; [|exact Hused|exact Hstore].
        rewrite PTree.gso by discriminate. exact Hm.
      * unfold trb_tail. rewrite <- (app_nil_l trace) at 1.
        eapply exec_Sseq_1 with (t1 := E0) (t2 := trace).
        -- apply exec_Sset. eapply trb_actual_pointer_read.
           ++ repeat rewrite PTree.gso by discriminate. exact Hm.
           ++ exact (tdr_selected_held_field_layout version).
           ++ rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). reflexivity.
        -- unfold trb_helper_call. eapply exec_Scall with
             (vf := Vptr fb Ptrofs.zero) (f := Internal (tho_function version))
             (vargs := [Vptr ob oo; Vptr carry Ptrofs.zero]) (vres := result).
           ++ reflexivity.
           ++ eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
              ** apply eval_Evar_global; [exact Hlocal|exact Hsymbol].
              ** apply deref_loc_reference. reflexivity.
           ++ econstructor; [apply eval_Etempvar; apply PTree.gss|reflexivity|].
              econstructor.
              { eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
                - apply eval_Evar_global; [exact Hcarrylocal|exact Hcarry].
                - apply deref_loc_reference. reflexivity. }
              { reflexivity. }
              constructor.
           ++ exact Hfunction.
           ++ destruct version; reflexivity.
           ++ exact Hhelper.
Qed.

Lemma trb_construct_entry : forall version ge memory mb mo,
  function_entry2 ge (trb_function version) [Vptr mb mo] memory empty_env
    (trb_entry_temps version mb mo) memory.
Proof.
  intros [] ge memory mb mo; eapply function_entry2_intro.
  all: try apply list_norepet_nil.
  all: try (vm_compute; repeat constructor; simpl; intuition congruence).
  all: try (vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence).
  all: try apply alloc_variables_nil.
  all: reflexivity.
Qed.

Definition TRBActualGrabReachesHelper : Prop :=
  forall version memory mb mo ob oo carry trace after result,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (trb_function version)) [Vptr mb mo] trace after result ->
  exists restored helper_result,
    Mem.store Mptr memory mb
      (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) restored
      (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero]
      trace after helper_result /\ result = Vundef.

Theorem trb_actual_grab_reaches_helper : TRBActualGrabReachesHelper.
Proof.
  intros version memory mb mo ob oo carry trace after result Hcarry Hnull Hused Hcall.
  destruct (trb_selected_helper_resolves version) as (fb & Hsymbol & Hfunction).
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    destruct (trb_actual_entry version _ memory mb mo _ _ _ Hentry)
      as (-> & -> & Hm) end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (trb_actual_body_reaches_helper version empty_env _ memory mb mo ob oo carry fb
      _ _ _ _ (PTree.gempty _ _) (PTree.gempty _ _) Hsymbol Hfunction Hcarry Hm Hnull Hused Hbody)
      as (restored & helper_result & Hstore & Hhelper & Hnormal) end.
  subst.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?last |- _ =>
    change (Some before = Some last) in Hfree; inversion Hfree; subst end.
  match goal with Hresult : outcome_result_value _ _ _ _ |- _ =>
    rewrite (proj1 (proj2 (proj2 (trb_generated_shape version)))) in Hresult;
    cbn in Hresult; subst result end.
  eauto 8.
Qed.

(** This construction takes a real helper execution rather than a frame
    premise. The helper's separate construction supplies that execution from
    its concrete writable fields and actual symbol readings. *)
Theorem trb_construct_grab_from_helper :
  forall version memory mb mo ob oo carry restored trace after helper_result,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 128))) = Some (Vptr ob oo) ->
  Mem.store Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) (Vptr ob oo) = Some restored ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) restored
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero]
    trace after helper_result ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (trb_function version)) [Vptr mb mo] trace after Vundef.
Proof.
  intros version memory mb mo ob oo carry restored trace after helper_result
    Hcarry Hnull Hused Hstore Hhelper.
  destruct (trb_selected_helper_resolves version) as (fb & Hsymbol & Hfunction).
  eapply eval_funcall_internal with (e := empty_env)
    (le1 := trb_entry_temps version mb mo)
    (le2 := PTree.set TRB._t'2 (Vptr ob oo)
      (PTree.set TRB._t'3 (Vptr ob oo)
        (PTree.set TRB._t'1 (Vint Int.zero) (trb_entry_temps version mb mo))))
    (m1 := memory) (m2 := after) (out := Out_normal).
  - apply trb_construct_entry.
  - eapply trb_construct_body; eauto; try apply PTree.gempty.
    unfold trb_entry_temps. apply PTree.gss.
  - rewrite (proj1 (proj2 (proj2 (trb_generated_shape version)))). reflexivity.
  - reflexivity.
Qed.

Definition TRBCompleteGrabExecutes : Prop :=
  forall version memory mb mo ob oo cb pb po flags carry fourth fifth,
  trb_storage version memory mb mo ob oo cb pb po flags carry fourth fifth ->
  exists after,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) memory
      (Internal (trb_function version)) [Vptr mb mo] E0 after Vundef /\
    trb_post memory after mb mo ob oo pb po.

Theorem trb_complete_grab_executes : TRBCompleteGrabExecutes.
Proof.
  intros version memory mb mo ob oo cb pb po flags carry fourth fifth
    (Hobject & Hglobal & Hnull & Hused & Hwritable & Hinputs).
  destruct (Mem.valid_access_store _ _ _ _ (Vptr ob oo) Hwritable)
    as (restored & Hrestore).
  pose proof (trb_helper_inputs_after_restore _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hobject Hglobal Hinputs Hrestore) as Hready.
  destruct (tho_complete_helper_executes _ _ _ _ _ _ _ _ _ _ _ Hready)
    as (middle & after & Hparent & Hheld & Hhelper).
  assert (Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry) as Hcarry.
  { destruct Hinputs as (_ & _ & _ & _ & Hscripts & _).
    exact (proj1 Hscripts). }
  exists after. split.
  - eapply trb_construct_grab_from_helper; eauto.
  - eapply trb_three_stores_restore; eauto.
Qed.

Definition TRBCompleteGrabRestoresPointers : Prop :=
  forall version memory mb mo ob oo cb pb po flags carry fourth fifth trace after result,
  trb_storage version memory mb mo ob oo cb pb po flags carry fourth fifth ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (trb_function version)) [Vptr mb mo] trace after result ->
  trace = E0 /\ result = Vundef /\ trb_post memory after mb mo ob oo pb po.

Theorem trb_complete_grab_restores_pointers : TRBCompleteGrabRestoresPointers.
Proof.
  intros version memory mb mo ob oo cb pb po flags carry fourth fifth trace after result
    (Hobject & Hglobal & Hnull & Hused & Hwritable & Hinputs) Hcall.
  assert (Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TRB._bhvCarrySomething3 = Some carry) as Hcarry.
  { destruct Hinputs as (_ & _ & _ & _ & Hscripts & _).
    exact (proj1 Hscripts). }
  destruct (trb_actual_grab_reaches_helper _ _ _ _ _ _ _ _ _ _ Hcarry Hnull Hused Hcall)
    as (restored & helper_result & Hrestore & Hhelper & Hresult).
  pose proof (trb_helper_inputs_after_restore _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hobject Hglobal Hinputs Hrestore) as Hready.
  destruct (tho_complete_helper_exact_stores _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hready Hhelper)
    as (Htrace & _ & middle & Hparent & Hheld).
  split; [exact Htrace|]. split; [exact Hresult|].
  eapply trb_three_stores_restore; eauto.
Qed.

Definition TRBCompleteGrabKeepsOwnershipAndActivity : Prop :=
  forall version memory mb mo ob oo cb pb po flags carry fourth fifth trace after result
    chunk delta,
  trb_storage version memory mb mo ob oo cb pb po flags carry fourth fifth ->
  Ptrofs.unsigned oo + 296 <= Ptrofs.modulus ->
  In delta [24; 25; 116] -> 0 < size_chunk chunk <= 4 ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (trb_function version)) [Vptr mb mo] trace after result ->
  Mem.load chunk after ob (tho_address oo delta) =
    Mem.load chunk memory ob (tho_address oo delta).

Theorem trb_complete_grab_keeps_ownership_and_activity :
  TRBCompleteGrabKeepsOwnershipAndActivity.
Proof.
  intros version memory mb mo ob oo cb pb po flags carry fourth fifth trace after result
    chunk delta Hstorage Hbounds Hdelta Hchunk Hcall.
  destruct (trb_complete_grab_restores_pointers version memory mb mo ob oo cb pb po flags
    carry fourth fifth trace after result Hstorage Hcall)
    as (_ & _ & restored & middle & Hrestore & Hparent & Hheld & _).
  rewrite (tho_two_stores_preserve_ownership_and_activity restored ob oo (Vptr pb po)
    middle after chunk delta Hbounds Hdelta Hchunk Hparent Hheld).
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hrestore); [reflexivity|].
  left. intro Hequal. apply (proj1 Hstorage). symmetry. exact Hequal.
Qed.

Definition TRBCompleteGrabDoesNotRevive : Prop :=
  forall version memory mb mo ob oo cb pb po flags carry fourth fifth trace after result,
  trb_storage version memory mb mo ob oo cb pb po flags carry fourth fifth ->
  Ptrofs.unsigned oo + 296 <= Ptrofs.modulus ->
  Mem.load Mint16signed memory ob (tho_address oo 116) = Some (Vint Int.zero) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (trb_function version)) [Vptr mb mo] trace after result ->
  Mem.load Mint16signed after ob (tho_address oo 116) = Some (Vint Int.zero).

Theorem trb_complete_grab_does_not_revive : TRBCompleteGrabDoesNotRevive.
Proof.
  intros version memory mb mo ob oo cb pb po flags carry fourth fifth trace after result
    Hstorage Hbounds Hinactive Hcall.
  rewrite (trb_complete_grab_keeps_ownership_and_activity version memory mb mo ob oo
    cb pb po flags carry fourth fifth trace after result Mint16signed 116
    Hstorage Hbounds ltac:(cbn; auto) ltac:(cbn; intuition) Hcall).
  exact Hinactive.
Qed.

Definition TeleporterBobombRegrabBoundary : Prop :=
  TRBActualGrabReachesHelper /\ TRBCompleteGrabExecutes /\ TRBCompleteGrabRestoresPointers /\
  TRBCompleteGrabKeepsOwnershipAndActivity /\ TRBCompleteGrabDoesNotRevive /\
  (forall version, exists b,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      TRB._mario_grab_used_object = Some b /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
      Some (Internal (trb_function version))).
Theorem teleporter_bobomb_regrab_boundary_checked : TeleporterBobombRegrabBoundary.
Proof.
  split; [exact trb_actual_grab_reaches_helper|].
  split; [exact trb_complete_grab_executes|].
  split; [exact trb_complete_grab_restores_pointers|].
  split; [exact trb_complete_grab_keeps_ownership_and_activity|].
  split; [exact trb_complete_grab_does_not_revive|].
  exact trb_selected_grab_resolves.
Qed.
