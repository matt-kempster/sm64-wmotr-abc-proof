(** Rank 18: the alternate copy index cannot read a second MarioState.
    The allocation bound is checked against every declaration in the real
    US/JP source unions and transported to the selected linked programs.
    It persists through actual Clight steps, including abstract externals.
    No private-pointer invariant or per-external frame is assumed here. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Coqlib Ctypes Events
  Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import
  us_level_update jp_level_update us_object_list_processor jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightAllocationBounds ClightRefinement GameTypes
  LinkedClightPrograms LinkedGlobalInitialMemory NormalizedClightPrograms
  SelectedClightTarget USViewportRepairedProgramSelection USWholeASTTagRepair.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Module R18U := us_object_list_processor.
Module R18J := jp_object_list_processor.

Definition rank18_state_array_shape (definition : globdef Clight.fundef type) :=
  match definition with
  | Gvar variable => Z.leb (init_data_list_size (gvar_init variable)) 200
  | _ => false
  end.

Definition rank18_state_array_entry_ok
    (entry : ident * globdef Clight.fundef type) : bool :=
  if Pos.eqb (fst entry) R18U._gMarioStates
  then rank18_state_array_shape (snd entry) else true.

Lemma rank18_us_state_array_declarations_checked :
  forallb rank18_state_array_entry_ok (unit_global_definitions us_units) = true.
Proof. vm_compute; reflexivity. Qed.

Lemma rank18_jp_state_array_declarations_checked :
  forallb rank18_state_array_entry_ok (unit_global_definitions jp_units) = true.
Proof. vm_compute; reflexivity. Qed.

Lemma rank18_state_array_actual_storage_checked :
  us_level_update.v_gMarioStates.(gvar_init) = [Init_space 200] /\
  jp_level_update.v_gMarioStates.(gvar_init) = [Init_space 200] /\
  us_level_update.v_gMarioStates.(gvar_info) =
    tarray (Tstruct R18U._MarioState noattr) 1 /\
  jp_level_update.v_gMarioStates.(gvar_info) =
    tarray (Tstruct R18U._MarioState noattr) 1.
Proof. repeat split; reflexivity. Qed.

Lemma rank18_repair_preserves_state_array_check : forall entry,
  rank18_state_array_entry_ok (repair_us_selected_global_definition entry) =
  rank18_state_array_entry_ok entry.
Proof.
  intros [id definition]. unfold repair_us_selected_global_definition.
  destruct (us_selected_definition_needs_viewport_repair (id, definition));
    [destruct definition; reflexivity | reflexivity].
Qed.

(** Keep forallb elimination abstract: rewriting it over the concrete union
    duplicates the entire generated program in the kernel proof term. *)
Lemma rank18_checked_source_entry : forall definitions entry,
  forallb rank18_state_array_entry_ok definitions = true ->
  In entry definitions -> rank18_state_array_entry_ok entry = true.
Proof.
  intros definitions entry Hchecked Hin.
  rewrite forallb_forall in Hchecked. exact (Hchecked entry Hin).
Qed.

Lemma rank18_repaired_list_checked : forall definitions source,
  (forall entry, In entry definitions -> In entry source) ->
  forallb rank18_state_array_entry_ok source = true ->
  forall entry,
    In entry (map repair_us_selected_global_definition definitions) ->
    rank18_state_array_entry_ok entry = true.
Proof.
  intros definitions source Hsource Hchecked entry Hin.
  apply in_map_iff in Hin. destruct Hin as [original [<- Hin]].
  rewrite rank18_repair_preserves_state_array_check.
  eapply rank18_checked_source_entry; eauto.
Qed.

Lemma rank18_program_shape_from_checked_list : forall program definitions,
  prog_defs program = definitions ->
  (forall entry, In entry definitions -> rank18_state_array_entry_ok entry = true) ->
  forall definition,
    In (R18U._gMarioStates, definition) (prog_defs program) ->
    rank18_state_array_shape definition = true.
Proof.
  intros program definitions Hdefinitions Hchecked definition Hin.
  rewrite Hdefinitions in Hin.
  specialize (Hchecked (R18U._gMarioStates, definition) Hin).
  unfold rank18_state_array_entry_ok in Hchecked. cbn [fst snd] in Hchecked.
  now rewrite Pos.eqb_refl in Hchecked.
Qed.

(** All large-program transport now uses opaque certificates.  In particular,
    kernel conversion must not normalize the complete global-definition map. *)
Local Opaque us_viewport_repaired_program us_normalized_global_definitions
  jp_official_cleaned_slice unit_global_definitions us_units jp_units.

Lemma rank18_us_repaired_list_checked : forall entry,
  In entry us_viewport_repaired_global_definitions ->
  rank18_state_array_entry_ok entry = true.
Proof.
  exact (rank18_repaired_list_checked us_normalized_global_definitions
    (unit_global_definitions us_units)
    us_selected_definitions_have_source_provenance
    rank18_us_state_array_declarations_checked).
Qed.

Lemma rank18_us_selected_state_array_shape : forall definition,
  In (R18U._gMarioStates, definition)
    (prog_defs us_viewport_repaired_program) ->
  rank18_state_array_shape definition = true.
Proof.
  exact (rank18_program_shape_from_checked_list us_viewport_repaired_program
    us_viewport_repaired_global_definitions
    us_viewport_repaired_program_definitions_checked
    rank18_us_repaired_list_checked).
Qed.

Lemma rank18_jp_selected_list_checked : forall entry,
  In entry (prog_defs jp_official_cleaned_slice) ->
  rank18_state_array_entry_ok entry = true.
Proof.
  intros [id definition] Hin.
  exact (rank18_checked_source_entry _ (id, definition)
    rank18_jp_state_array_declarations_checked
    (jp_official_cleaned_definition_source_provenance id definition Hin)).
Qed.

Lemma rank18_jp_selected_state_array_shape : forall definition,
  In (R18U._gMarioStates, definition)
    (prog_defs jp_official_cleaned_slice) ->
  rank18_state_array_shape definition = true.
Proof.
  exact (rank18_program_shape_from_checked_list jp_official_cleaned_slice
    (prog_defs jp_official_cleaned_slice) eq_refl rank18_jp_selected_list_checked).
Qed.

Definition rank18_selected_state_array_shape (version : GameVersion) :
  forall definition,
    In (R18U._gMarioStates, definition)
      (prog_defs (selected_clight_target version)) ->
    rank18_state_array_shape definition = true :=
  match version as v return
    (forall definition,
      In (R18U._gMarioStates, definition)
        (prog_defs (selected_clight_target v)) ->
      rank18_state_array_shape definition = true) with
  | VersionUS => rank18_us_selected_state_array_shape
  | VersionJP => rank18_jp_selected_state_array_shape
  end.

Lemma rank18_selected_state_symbol_has_bounded_variable : forall version b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    R18U._gMarioStates = Some b ->
  exists variable,
    Genv.find_var_info (Clight.globalenv (selected_clight_target version)) b =
      Some variable /\
    init_data_list_size (gvar_init variable) <= 200.
Proof.
  intros version b Hsymbol.
  destruct (linked_symbol_with_definition_shape_has_variable
    (selected_clight_target version) R18U._gMarioStates
    rank18_state_array_shape
    (fun v => init_data_list_size (gvar_init v) <= 200))
    as (found & variable & Hfound & Hvariable & Hbound).
  - exact (rank18_selected_state_array_shape version).
  - intros [function | variable] Hshape; try discriminate.
    exists variable. split; [reflexivity |]. now apply Z.leb_le.
  - exists b. exact Hsymbol.
  - rewrite Hsymbol in Hfound. inversion Hfound; subst found.
    exists variable. auto.
Qed.

Theorem rank18_reached_state_array_has_no_second_element :
  forall version initial start trace last b offset permission,
    Genv.init_mem (selected_clight_target version) = Some initial ->
    clight_bound_memory start = initial ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_target version)) start trace last ->
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R18U._gMarioStates = Some b ->
    200 <= offset ->
    ~ Mem.perm (clight_bound_memory last) b offset Max permission.
Proof.
  intros version initial start trace last b offset permission
    Hinitial Hstart Hsteps Hsymbol Hoffset Hperm.
  destruct (rank18_selected_state_symbol_has_bounded_variable version b Hsymbol)
    as [variable [Hvariable Hbound]].
  pose proof (initialized_global_bound_persists_through_clight
    _ _ _ _ _ _ _ Hinitial Hvariable Hstart Hsteps _ _ Hperm) as Hrange.
  lia.
Qed.

Corollary rank18_reached_index_one_first_velocity_load_fails :
  forall version initial start trace last b,
    Genv.init_mem (selected_clight_target version) = Some initial ->
    clight_bound_memory start = initial ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_target version)) start trace last ->
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R18U._gMarioStates = Some b ->
    Mem.load Mfloat32 (clight_bound_memory last) b 272 = None.
Proof.
  intros version initial start trace last b Hinitial Hstart Hsteps Hsymbol.
  destruct (Mem.load Mfloat32 (clight_bound_memory last) b 272)
    as [value |] eqn:Hload; [| reflexivity].
  exfalso. pose proof (Mem.load_valid_access _ _ _ _ _ Hload) as [Hrange _].
  eapply (rank18_reached_state_array_has_no_second_element
    version initial start trace last b 272 Readable Hinitial Hstart Hsteps Hsymbol);
    [lia |].
  apply Mem.perm_cur_max. apply Hrange. cbn; lia.
Qed.
