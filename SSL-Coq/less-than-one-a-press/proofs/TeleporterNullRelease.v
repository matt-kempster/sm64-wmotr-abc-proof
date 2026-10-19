(** A null Mario held-object pointer disables the actual drop and throw
    functions.  Object-side HELD_HELD is not an alternative input to these
    operations.  This does not rule out regrabbing a surviving object. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction
  us_behavior_data jp_behavior_data us_behavior_script jp_behavior_script
  us_object_helpers jp_object_helpers.
From LessThanOneAPress.Proofs Require Import GameTypes InkCopyCaller
  ObjectContactNecessity ReadOnlyClightPaths TeleporterDestinationReset
  SelectedClightTarget UpperElevatorQueryResolution CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.
Module TNR := us_interaction.

Inductive TNRRelease := TNRDrop | TNRThrow.
Definition tnr_ident kind := match kind with
  | TNRDrop => TNR._mario_drop_held_object
  | TNRThrow => TNR._mario_throw_held_object end.
Definition tnr_function version kind := match version, kind with
  | VersionUS, TNRDrop => TNR.f_mario_drop_held_object
  | VersionUS, TNRThrow => TNR.f_mario_throw_held_object
  | VersionJP, TNRDrop => jp_interaction.f_mario_drop_held_object
  | VersionJP, TNRThrow => jp_interaction.f_mario_throw_held_object end.
Definition tnr_held_read := Efield
  (Ederef (Etempvar TNR._m (tptr (Tstruct TNR._MarioState noattr)))
    (Tstruct TNR._MarioState noattr)) TNR._heldObj
  (tptr (Tstruct TNR._Object noattr)).
Definition tnr_guard := Ebinop One
  (Etempvar TNR._t'2 (tptr (Tstruct TNR._Object noattr)))
  (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint.
Definition tnr_effects version kind :=
  match fn_body (tnr_function version kind) with
  | Ssequence _ (Sifthenelse _ yes _) => yes | _ => Sskip end.
Definition tnr_entry_temps version kind mb mo :=
  PTree.set TNR._m (Vptr mb mo)
    (create_undef_temps (fn_temps (tnr_function version kind))).

Lemma tnr_generated_shape : forall version kind,
  fn_vars (tnr_function version kind) = [] /\
  fn_params (tnr_function version kind) =
    [(TNR._m, tptr (Tstruct TNR._MarioState noattr))] /\
  fn_return (tnr_function version kind) = tvoid /\
  fn_body (tnr_function version kind) =
    Ssequence (Sset TNR._t'2 tnr_held_read)
      (Sifthenelse tnr_guard (tnr_effects version kind) Sskip).
Proof. intros [] []; repeat split; reflexivity. Qed.

Lemma tnr_us_source : forall kind,
  nth_error TNR.global_definitions
    (ueqr_definition_index (tnr_ident kind) TNR.global_definitions) =
  Some (tnr_ident kind, Gfun (Internal (tnr_function VersionUS kind))).
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tnr_us_member : forall kind,
  In (tnr_ident kind, Gfun (Internal (tnr_function VersionUS kind)))
    (unit_global_definitions us_units).
Proof.
  intro kind. eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 10 us_units).
  - exact (us_nlist_at_nIn _ 10 us_units).
  - change (In (tnr_ident kind, Gfun (Internal (tnr_function VersionUS kind)))
      TNR.global_definitions).
    eapply nth_error_In. exact (tnr_us_source kind).
Qed.
Lemma tnr_us_selection : forall kind,
  us_normalized_global_definition_map ! (tnr_ident kind) =
    Some (Gfun (Internal (tnr_function VersionUS kind))).
Proof.
  intro kind. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact (tnr_us_member kind).
Qed.
Lemma tnr_us_no_repair : forall kind,
  us_selected_definition_needs_viewport_repair
    (tnr_ident kind, Gfun (Internal (tnr_function VersionUS kind))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tnr_us_selected_member : forall kind,
  In (tnr_ident kind, Gfun (Internal (tnr_function VersionUS kind)))
    us_viewport_repaired_global_definitions.
Proof.
  intro kind. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite tnr_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact (tnr_us_selection kind).
Qed.
Lemma tnr_jp_source : forall kind,
  (prog_defmap (nlist_at 10 jp_cleaned_units)) ! (tnr_ident kind) =
    Some (Gfun (Internal (tnr_function VersionJP kind))).
Proof. intros []; vm_compute; reflexivity. Qed.
Theorem tnr_selected_callees_resolve : forall version kind, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    (tnr_ident kind) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tnr_function version kind)).
Proof.
  intros [] kind.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (tnr_us_selected_member kind).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at 10 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 10 jp_cleaned_units).
    + exact (tnr_jp_source kind).
Qed.

(** These are the scripts installed for non-HOLDABLE clones: BEGIN and
    BREAK, rather than a normal Goomba update. This finite source certificate
    does not assert that a clone cannot hurt Mario: Mario's interaction code
    may still process the clone's existing damage hitbox. *)
Definition TNRCloneCarryScripts : Prop := forall version,
  map (fun variable => gvar_init variable)
    (match version with
    | VersionUS => [us_behavior_data.v_bhvCarrySomething3;
        us_behavior_data.v_bhvCarrySomething4; us_behavior_data.v_bhvCarrySomething5]
    | VersionJP => [jp_behavior_data.v_bhvCarrySomething3;
        jp_behavior_data.v_bhvCarrySomething4; jp_behavior_data.v_bhvCarrySomething5]
    end) = repeat [Init_int32 (Int.repr 524288);
      Init_int32 (Int.repr 167772160)] 3 /\
  fn_body (match version with
    | VersionUS => us_behavior_script.f_bhv_cmd_break
    | VersionJP => jp_behavior_script.f_bhv_cmd_break end) =
      Sreturn (Some (Econst_int Int.one tint)).
Lemma tnr_clone_carry_scripts_checked : TNRCloneCarryScripts.
Proof. intros []; split; reflexivity. Qed.

Definition tnr_nonholdable_effects version :=
  match fn_body (match version with
    | VersionUS => us_object_helpers.f_obj_set_held_state
    | VersionJP => jp_object_helpers.f_obj_set_held_state end) with
  | Ssequence _ (Ssequence _ (Sifthenelse _ _ no)) => no
  | _ => Sskip end.
Definition TNRNonholdableScriptInstallation : Prop := forall version,
  tnr_nonholdable_effects version =
  Ssequence
    (Ssequence
      (Scall (Some us_object_helpers._t'1)
        (Evar us_object_helpers._segmented_to_virtual
          (Tfunction [tptr tvoid] (tptr tvoid) cc_default))
        [Etempvar us_object_helpers._heldBehavior (tptr tuint)])
      (Sassign
        (Efield
          (Ederef (Etempvar us_object_helpers._obj
            (tptr (Tstruct us_object_helpers._Object noattr)))
            (Tstruct us_object_helpers._Object noattr))
          us_object_helpers._curBhvCommand (tptr tuint))
        (Etempvar us_object_helpers._t'1 (tptr tvoid))))
    (Sassign
      (Efield
        (Ederef (Etempvar us_object_helpers._obj
          (tptr (Tstruct us_object_helpers._Object noattr)))
          (Tstruct us_object_helpers._Object noattr))
        us_object_helpers._bhvStackIndex tuint)
      (Econst_int Int.zero tint)).
Lemma tnr_nonholdable_script_installation_checked : TNRNonholdableScriptInstallation.
Proof. intros []; reflexivity. Qed.

Lemma tnr_actual_held_read : forall version e le memory mb mo value,
  le ! TNR._m = Some (Vptr mb mo) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some value ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le memory
    tnr_held_read value.
Proof.
  intros version e le memory mb mo value Htemp Hload.
  destruct (ibcc_field_ok_sound _ _ _ _
    (tdr_selected_held_field_layout version)) as (co & Hco & Hoff).
  unfold tnr_held_read.
  eapply eval_Elvalue with
    (ofs := Ptrofs.add mo (Ptrofs.repr 124)) (bf := Full).
  - eapply eval_Efield_struct with (co := co).
    + eapply eval_Elvalue.
      * apply eval_Ederef. apply eval_Etempvar. exact Htemp.
      * apply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hco.
    + exact Hoff.
  - eapply deref_loc_value with (chunk := Mptr); eauto.
Qed.

(** The body path is constructed from the actual cell load, so the result
    does not assume that a completed call exists or that another callee frames
    memory. The false branch bypasses every call and every object write. *)
Theorem tnr_null_body_readonly : forall version kind e le memory mb mo,
  le ! TNR._m = Some (Vptr mb mo) ->
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  readonly_path (Clight.globalenv (selected_clight_target version)) e memory le
    (fn_body (tnr_function version kind))
    (PTree.set TNR._t'2 (Vint Int.zero) le).
Proof.
  intros version kind e le memory mb mo Htemp Hload.
  rewrite (proj2 (proj2 (proj2 (tnr_generated_shape version kind)))).
  eapply ro_seq.
  - apply ro_set. eapply tnr_actual_held_read; eauto.
  - eapply ro_if with (v := Vint Int.zero) (choice := false).
    + unfold tnr_guard. eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * eapply eval_Ecast; [constructor|reflexivity].
      * reflexivity.
    + reflexivity.
    + apply ro_skip.
Qed.

Lemma tnr_actual_entry : forall version kind ge memory mb mo e le allocated,
  function_entry2 ge (tnr_function version kind) [Vptr mb mo]
    memory e le allocated ->
  e = empty_env /\ allocated = memory /\ le ! TNR._m = Some (Vptr mb mo).
Proof.
  intros version kind ge memory mb mo e le allocated Hentry.
  destruct (tnr_generated_shape version kind) as (Hvars & Hparams & _).
  inversion Hentry; subst; clear Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  repeat split; try reflexivity.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb;
    inversion Hb; subst temps; apply PTree.gss end.
Qed.

Lemma tnr_construct_entry : forall version kind ge memory mb mo,
  function_entry2 ge (tnr_function version kind) [Vptr mb mo]
    memory empty_env (tnr_entry_temps version kind mb mo) memory.
Proof.
  intros [] [] ge memory mb mo;
    eapply function_entry2_intro.
  all: try (apply list_norepet_nil).
  all: try (vm_compute; repeat constructor; simpl; intuition congruence).
  all: try (vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence).
  all: try (apply alloc_variables_nil).
  all: reflexivity.
Qed.

Definition TNRNullReleaseExecutes : Prop :=
  forall version kind memory mb mo,
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (tnr_function version kind)) [Vptr mb mo] E0 memory Vundef.

Theorem tnr_null_release_executes : TNRNullReleaseExecutes.
Proof.
  intros version kind memory mb mo Hload.
  eapply eval_funcall_internal with (e := empty_env)
    (le1 := tnr_entry_temps version kind mb mo)
    (le2 := PTree.set TNR._t'2 (Vint Int.zero)
      (tnr_entry_temps version kind mb mo))
    (m1 := memory) (m2 := memory) (out := Out_normal).
  - apply tnr_construct_entry.
  - apply readonly_path_executes.
    eapply tnr_null_body_readonly; [unfold tnr_entry_temps; apply PTree.gss|exact Hload].
  - rewrite (proj1 (proj2 (proj2 (tnr_generated_shape version kind)))). reflexivity.
  - reflexivity.
Qed.

Definition TNRNullReleasePreservesMemory : Prop :=
  forall version kind memory mb mo trace after result,
  Mem.load Mptr memory mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (tnr_function version kind)) [Vptr mb mo] trace after result ->
  trace = E0 /\ after = memory /\ result = Vundef.

Theorem tnr_null_release_preserves_memory : TNRNullReleasePreservesMemory.
Proof.
  intros version kind memory mb mo trace after result Hload Hcall.
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    destruct (tnr_actual_entry version kind _ memory mb mo _ _ _ Hentry)
      as (-> & -> & Htemp) end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (readonly_path_forces_every_execution _ _ _ _ _ _
      (tnr_null_body_readonly version kind _ _ memory mb mo Htemp Hload)
      _ _ _ _ Hbody) as (-> & -> & -> & ->) end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?last |- _ =>
    change (Some before = Some last) in Hfree; inversion Hfree; subst end.
  match goal with Hresult : outcome_result_value _ _ _ _ |- _ =>
    rewrite (proj1 (proj2 (proj2 (tnr_generated_shape version kind)))) in Hresult;
    cbn in Hresult; subst result end.
  repeat split; reflexivity.
Qed.

Definition TeleporterNullReleaseBoundary : Prop :=
  TNRNullReleaseExecutes /\ TNRNullReleasePreservesMemory /\ TNRCloneCarryScripts /\
  TNRNonholdableScriptInstallation /\
  (forall version kind, exists b,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (tnr_ident kind) = Some b /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
      Some (Internal (tnr_function version kind))).
Theorem teleporter_null_release_boundary_checked : TeleporterNullReleaseBoundary.
Proof.
  split; [exact tnr_null_release_executes|].
  split; [exact tnr_null_release_preserves_memory|].
  split; [exact tnr_clone_carry_scripts_checked|].
  split; [exact tnr_nonholdable_script_installation_checked|
    exact tnr_selected_callees_resolve].
Qed.
