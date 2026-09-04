(** Resolve Rank 10's complete air-quarter query chain in the selected US and
    JP Clight programs.

    The generated quarter-step body has an unconditional prefix consisting of
    vector copy, two wall wrappers, one floor query, one ceiling wrapper, and
    one water query.  Each wall wrapper unconditionally enters the real wall
    query before its first branch, and the ceiling wrapper unconditionally
    enters the real ceiling query before returning.  This file checks those
    shapes in both source versions and proves that all seven involved bodies
    are the bodies selected by the linked proof target.  It is a source/link
    theorem; the separate JP machine receipt records the calls that actually
    occurred in the tested held-A and rollout executions. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import
  us_mario jp_mario us_mario_step jp_mario_step
  us_surface_collision jp_surface_collision.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CleanedClightPrograms ClightLinkExecution GameTypes
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SelectedClightTarget
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Import ListNotations.

Module UEQR_UM := us_mario.
Module UEQR_JM := jp_mario.
Module UEQR_US := us_mario_step.
Module UEQR_JS := jp_mario_step.
Module UEQR_UC := us_surface_collision.
Module UEQR_JC := jp_surface_collision.

Inductive UpperElevatorQueryNative :=
| UEQRPerformAirStep
| UEQRPerformAirQuarterStep
| UEQRResolveWall
| UEQRVecCeil
| UEQRFindWall
| UEQRFindFloor
| UEQRFindCeil.

Definition ueqr_native_ident native : ident :=
  match native with
  | UEQRPerformAirStep => UEQR_US._perform_air_step
  | UEQRPerformAirQuarterStep => UEQR_US._perform_air_quarter_step
  | UEQRResolveWall => UEQR_UM._resolve_and_return_wall_collisions
  | UEQRVecCeil => UEQR_UM._vec3f_find_ceil
  | UEQRFindWall => UEQR_UC._find_wall_collisions
  | UEQRFindFloor => UEQR_UC._find_floor
  | UEQRFindCeil => UEQR_UC._find_ceil
  end.

Definition ueqr_native_body version native : function :=
  match version, native with
  | VersionUS, UEQRPerformAirStep => UEQR_US.f_perform_air_step
  | VersionJP, UEQRPerformAirStep => UEQR_JS.f_perform_air_step
  | VersionUS, UEQRPerformAirQuarterStep => UEQR_US.f_perform_air_quarter_step
  | VersionJP, UEQRPerformAirQuarterStep => UEQR_JS.f_perform_air_quarter_step
  | VersionUS, UEQRResolveWall => UEQR_UM.f_resolve_and_return_wall_collisions
  | VersionJP, UEQRResolveWall => UEQR_JM.f_resolve_and_return_wall_collisions
  | VersionUS, UEQRVecCeil => UEQR_UM.f_vec3f_find_ceil
  | VersionJP, UEQRVecCeil => UEQR_JM.f_vec3f_find_ceil
  | VersionUS, UEQRFindWall => UEQR_UC.f_find_wall_collisions
  | VersionJP, UEQRFindWall => UEQR_JC.f_find_wall_collisions
  | VersionUS, UEQRFindFloor => UEQR_UC.f_find_floor
  | VersionJP, UEQRFindFloor => UEQR_JC.f_find_floor
  | VersionUS, UEQRFindCeil => UEQR_UC.f_find_ceil
  | VersionJP, UEQRFindCeil => UEQR_JC.f_find_ceil
  end.

Definition ueqr_source_unit_index native : nat :=
  match native with
  | UEQRPerformAirStep | UEQRPerformAirQuarterStep => 9
  | UEQRResolveWall | UEQRVecCeil => 1
  | UEQRFindWall | UEQRFindFloor | UEQRFindCeil => 31
  end.

Definition ueqr_us_source_definitions native :=
  match native with
  | UEQRPerformAirStep | UEQRPerformAirQuarterStep => UEQR_US.global_definitions
  | UEQRResolveWall | UEQRVecCeil => UEQR_UM.global_definitions
  | UEQRFindWall | UEQRFindFloor | UEQRFindCeil => UEQR_UC.global_definitions
  end.

Fixpoint ueqr_definition_index (id : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : nat :=
  match definitions with
  | nil => O
  | (candidate, _) :: rest =>
      if Pos.eqb id candidate then O else S (ueqr_definition_index id rest)
  end.

Definition ueqr_us_source_definition_index native : nat :=
  ueqr_definition_index (ueqr_native_ident native)
    (ueqr_us_source_definitions native).

Lemma ueqr_us_source_definition_receipt : forall native,
  nth_error (ueqr_us_source_definitions native)
    (ueqr_us_source_definition_index native) =
    Some (ueqr_native_ident native,
      Gfun (Internal (ueqr_native_body VersionUS native))).
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma ueqr_us_source_unit_definitions : forall native,
  prog_defs (us_nlist_at (ueqr_source_unit_index native) us_units) =
  ueqr_us_source_definitions native.
Proof. intros []; reflexivity. Qed.

Lemma ueqr_us_source_union_member : forall native,
  In (ueqr_native_ident native,
      Gfun (Internal (ueqr_native_body VersionUS native)))
    (unit_global_definitions us_units).
Proof.
  intro native. eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (ueqr_source_unit_index native) us_units).
  - exact (us_nlist_at_nIn _ (ueqr_source_unit_index native) us_units).
  - rewrite ueqr_us_source_unit_definitions.
    eapply nth_error_In. exact (ueqr_us_source_definition_receipt native).
Qed.

Lemma ueqr_us_normalized_selection : forall native,
  us_normalized_global_definition_map ! (ueqr_native_ident native) =
    Some (Gfun (Internal (ueqr_native_body VersionUS native))).
Proof.
  intro native. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact (ueqr_us_source_union_member native).
Qed.

Lemma ueqr_us_native_needs_no_repair : forall native,
  us_selected_definition_needs_viewport_repair
    (ueqr_native_ident native,
      Gfun (Internal (ueqr_native_body VersionUS native))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma ueqr_us_selected_member : forall native,
  In (ueqr_native_ident native,
      Gfun (Internal (ueqr_native_body VersionUS native)))
    us_viewport_repaired_global_definitions.
Proof.
  intro native. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite ueqr_us_native_needs_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact (ueqr_us_normalized_selection native).
Qed.

Definition ueqr_jp_cleaned_unit native : Clight.program :=
  nlist_at (ueqr_source_unit_index native) jp_cleaned_units.

Lemma ueqr_jp_cleaned_defmap_receipt : forall native,
  (prog_defmap (ueqr_jp_cleaned_unit native)) ! (ueqr_native_ident native) =
    Some (Gfun (Internal (ueqr_native_body VersionJP native))).
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem upper_elevator_selected_query_body_resolves : forall version native,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (ueqr_native_ident native) = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (ueqr_native_body version native)).
Proof.
  intros [] native.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (ueqr_us_selected_member native).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (ueqr_jp_cleaned_unit native)).
    + exact (nlist_at_nIn _ (ueqr_source_unit_index native) jp_cleaned_units).
    + exact (ueqr_jp_cleaned_defmap_receipt native).
Qed.

(** Calls encountered before the first control split, return, loop, or jump.
    The boolean says that the scanned fragment can continue straight through.
    This is deliberately stricter than merely finding callees somewhere in a
    body: an early branch or return stops the projection. *)
Fixpoint ueqr_calls_before_control (statement : statement) : list ident * bool :=
  match statement with
  | Sskip | Sassign _ _ | Sset _ _ | Sbuiltin _ _ _ _ => ([], true)
  | Scall _ (Evar id _) _ => ([id], true)
  | Scall _ _ _ => ([], true)
  | Ssequence first second =>
      let '(first_calls, continues) := ueqr_calls_before_control first in
      if continues then
        let '(second_calls, second_continues) :=
          ueqr_calls_before_control second in
        (first_calls ++ second_calls, second_continues)
      else (first_calls, false)
  | Slabel _ body => ueqr_calls_before_control body
  | _ => ([], false)
  end.

Definition ueqr_query_prefix version : list ident :=
  fst (ueqr_calls_before_control
    (fn_body (ueqr_native_body version UEQRPerformAirQuarterStep))).

Definition ueqr_wall_prefix version : list ident :=
  fst (ueqr_calls_before_control
    (fn_body (ueqr_native_body version UEQRResolveWall))).

Definition ueqr_ceil_prefix version : list ident :=
  fst (ueqr_calls_before_control
    (fn_body (ueqr_native_body version UEQRVecCeil))).

Record UpperElevatorQueryChainChecked (version : GameVersion) : Prop := {
  ueqr_quarter_unconditional_prefix :
    ueqr_query_prefix version =
      [UEQR_US._vec3f_copy;
       UEQR_US._resolve_and_return_wall_collisions;
       UEQR_US._resolve_and_return_wall_collisions;
       UEQR_US._find_floor;
       UEQR_US._vec3f_find_ceil;
       UEQR_US._find_water_level];
  ueqr_quarter_has_exact_query_multiplicity :
    count_occ Pos.eq_dec
      (direct_callees_s
        (fn_body (ueqr_native_body version UEQRPerformAirQuarterStep)))
      UEQR_US._resolve_and_return_wall_collisions = 2%nat /\
    count_occ Pos.eq_dec
      (direct_callees_s
        (fn_body (ueqr_native_body version UEQRPerformAirQuarterStep)))
      UEQR_US._find_floor = 1%nat /\
    count_occ Pos.eq_dec
      (direct_callees_s
        (fn_body (ueqr_native_body version UEQRPerformAirQuarterStep)))
      UEQR_US._vec3f_find_ceil = 1%nat;
  ueqr_wall_wrapper_reaches_real_query_before_control :
    ueqr_wall_prefix version = [UEQR_UM._find_wall_collisions];
  ueqr_ceil_wrapper_reaches_real_query_before_control :
    ueqr_ceil_prefix version = [UEQR_UM._find_ceil];
  ueqr_cross_unit_identifiers_match :
    UEQR_US._resolve_and_return_wall_collisions =
      UEQR_UM._resolve_and_return_wall_collisions /\
    UEQR_US._vec3f_find_ceil = UEQR_UM._vec3f_find_ceil /\
    UEQR_US._find_floor = UEQR_UC._find_floor /\
    UEQR_UM._find_wall_collisions = UEQR_UC._find_wall_collisions /\
    UEQR_UM._find_ceil = UEQR_UC._find_ceil
}.

Theorem upper_elevator_query_chain_checked : forall version,
  UpperElevatorQueryChainChecked version.
Proof. intros []; constructor; vm_compute; repeat split; reflexivity. Qed.

Record UpperElevatorSelectedQueryBoundary : Prop := {
  ueqr_boundary_all_bodies_resolve : forall version native,
    exists function_block,
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        (ueqr_native_ident native) = Some function_block /\
      Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
        function_block = Some (Internal (ueqr_native_body version native));
  ueqr_boundary_both_query_chains_checked : forall version,
    UpperElevatorQueryChainChecked version
}.

Theorem upper_elevator_selected_query_boundary_checked :
  UpperElevatorSelectedQueryBoundary.
Proof.
  constructor.
  - exact upper_elevator_selected_query_body_resolves.
  - exact upper_elevator_query_chain_checked.
Qed.
