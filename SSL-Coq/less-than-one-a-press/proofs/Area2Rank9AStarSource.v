(** Rank 9A: exact generated bodies and the coin-star action-selection window.
    No placement, object contact, call frame or whole-route reachability is
    inferred from these syntax receipts. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Coqlib Ctypes
  Globalenvs Linking Maps Integers.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction
  us_mario jp_mario us_mario_step jp_mario_step
  us_mario_actions_cutscene jp_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes
  Area2Rank11PoleExitSplit Area2Rank11LivePoleExit
  Area2Rank11BodyResolution Area2Rank11HandstandDamage
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Module R9I := us_interaction.
Module R9M := us_mario.
Module R9S := us_mario_step.
Module R9C := us_mario_actions_cutscene.

Inductive Rank9ANative :=
| R9Collect | R9Initialize | R9Dance | R9Fall | R9Stop | R9Ledge.

Definition rank9a_body version native : function :=
  match version, native with
  | VersionUS, R9Collect => us_interaction.f_interact_star_or_key
  | VersionJP, R9Collect => jp_interaction.f_interact_star_or_key
  | VersionUS, R9Initialize => us_mario.f_set_mario_action_cutscene
  | VersionJP, R9Initialize => jp_mario.f_set_mario_action_cutscene
  | VersionUS, R9Dance => us_mario_actions_cutscene.f_act_star_dance
  | VersionJP, R9Dance => jp_mario_actions_cutscene.f_act_star_dance
  | VersionUS, R9Fall => us_mario_actions_cutscene.f_act_fall_after_star_grab
  | VersionJP, R9Fall => jp_mario_actions_cutscene.f_act_fall_after_star_grab
  | VersionUS, R9Stop => us_mario_step.f_stop_and_set_height_to_floor
  | VersionJP, R9Stop => jp_mario_step.f_stop_and_set_height_to_floor
  | VersionUS, R9Ledge => us_mario_step.f_check_ledge_grab
  | VersionJP, R9Ledge => jp_mario_step.f_check_ledge_grab
  end.

Definition rank9a_ident native : ident := match native with
| R9Collect => R9I._interact_star_or_key
| R9Initialize => R9M._set_mario_action_cutscene
| R9Dance => R9C._act_star_dance | R9Fall => R9C._act_fall_after_star_grab
| R9Stop => R9S._stop_and_set_height_to_floor
| R9Ledge => R9S._check_ledge_grab end.

Definition rank9a_unit native : nat := match native with
| R9Collect => 10 | R9Initialize => 1
| R9Dance | R9Fall => 4 | R9Stop | R9Ledge => 9 end.

Definition rank9a_us_definitions native := match native with
| R9Collect => us_interaction.global_definitions
| R9Initialize => us_mario.global_definitions
| R9Dance | R9Fall => us_mario_actions_cutscene.global_definitions
| R9Stop | R9Ledge => us_mario_step.global_definitions end.

Lemma rank9a_us_source_receipt : forall native,
  nth_error (rank9a_us_definitions native)
    (rank11_definition_index (rank9a_ident native) (rank9a_us_definitions native)) =
  Some (rank9a_ident native, Gfun (Internal (rank9a_body VersionUS native))).
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank9a_us_source_member : forall native,
  In (rank9a_ident native, Gfun (Internal (rank9a_body VersionUS native)))
    (unit_global_definitions us_units).
Proof.
  intro native. eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (rank9a_unit native) us_units).
  - exact (us_nlist_at_nIn _ (rank9a_unit native) us_units).
  - destruct native; eapply nth_error_In.
    + exact (rank9a_us_source_receipt R9Collect).
    + exact (rank9a_us_source_receipt R9Initialize).
    + exact (rank9a_us_source_receipt R9Dance).
    + exact (rank9a_us_source_receipt R9Fall).
    + exact (rank9a_us_source_receipt R9Stop).
    + exact (rank9a_us_source_receipt R9Ledge).
Qed.

Lemma rank9a_us_selection : forall native,
  us_normalized_global_definition_map ! (rank9a_ident native) =
    Some (Gfun (Internal (rank9a_body VersionUS native))).
Proof.
  intro native. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact (rank9a_us_source_member native).
Qed.

Lemma rank9a_us_no_repair : forall native,
  us_selected_definition_needs_viewport_repair
    (rank9a_ident native, Gfun (Internal (rank9a_body VersionUS native))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank9a_us_selected_member : forall native,
  In (rank9a_ident native, Gfun (Internal (rank9a_body VersionUS native)))
    us_viewport_repaired_global_definitions.
Proof.
  intro native. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite rank9a_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact (rank9a_us_selection native).
Qed.

Lemma rank9a_jp_source_receipt : forall native,
  (prog_defmap (nlist_at (rank9a_unit native) jp_cleaned_units)) !
    (rank9a_ident native) = Some (Gfun (Internal (rank9a_body VersionJP native))).
Proof. intros []; vm_compute; reflexivity. Qed.

Theorem rank9a_selected_body_resolves : forall version native,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (rank9a_ident native) = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank9a_body version native)).
Proof.
  intros [] native.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (rank9a_us_selected_member native).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at (rank9a_unit native) jp_cleaned_units)).
    + exact (nlist_at_nIn _ (rank9a_unit native) jp_cleaned_units).
    + exact (rank9a_jp_source_receipt native).
Qed.

(** This subtree begins AFTER the healthy-pickup guard and stop-riding call.
    The proof below neither assumes those have run safely nor erases them. *)
Definition rank9a_selection_tail version :=
  match rank11_right_sequence_tail 3 (fn_body (rank9a_body version R9Collect)) with
  | Ssequence (Ssequence _ (Sifthenelse _ yes _)) _ =>
      rank11_right_sequence_tail 2 yes
  | _ => Sskip end.

Definition rank9a_selection_fragment version :=
  match rank9a_selection_tail version with
  | Ssequence a (Ssequence b (Ssequence c (Ssequence d _))) =>
      Ssequence a (Ssequence b (Ssequence c d))
  | _ => Sskip end.

Definition rank9a_select_flag temporary bit chosen :=
  Ssequence
    (Sset temporary (rank11_mario_field_expression R9M._action tuint))
    (Sifthenelse (Ebinop Oand (Etempvar temporary tuint)
      (rank11_flag_expression bit) tuint)
      (Sset R9I._starGrabAction (Econst_int (Int.repr chosen) tint)) Sskip).

Definition rank9a_selection_statement :=
  Ssequence
    (Sifthenelse (Etempvar R9I._noExit tuint)
      (Sset R9I._starGrabAction (Econst_int (Int.repr 4871) tint)) Sskip)
    (Ssequence (rank9a_select_flag R9I._t'11 13 4867)
      (Ssequence (rank9a_select_flag R9I._t'10 14 4867)
        (rank9a_select_flag R9I._t'9 11 6404))).

Theorem rank9a_selection_is_generated : forall version,
  rank9a_selection_fragment version = rank9a_selection_statement.
Proof. intros []; reflexivity. Qed.

(** Six attached pole actions, distinct from the AIR-flagged pole jump. *)
Definition rank9a_attached_actions : list int :=
  map Int.repr [135267136; 1049409; 1049410; 1049411; 1049412; 1049413].

Definition rank9a_attached_dispatch : list (Z * ident) :=
  [(135267136, R11U._act_holding_pole); (1049409, R11U._act_grab_pole_slow);
   (1049410, R11U._act_grab_pole_fast); (1049411, R11U._act_climbing_pole);
   (1049412, R11U._act_top_of_pole_transition); (1049413, R11U._act_top_of_pole)].

Theorem rank9a_attached_actions_are_real_dispatch_cases :
  map (fun entry => Int.repr (fst entry)) rank9a_attached_dispatch =
    rank9a_attached_actions /\
  forallb (fun entry => switch_case_calls_ident_s (fst entry) (snd entry)
    (fn_body us_mario_actions_automatic.f_mario_execute_automatic_action))
    rank9a_attached_dispatch = true /\
  forallb (fun entry => switch_case_calls_ident_s (fst entry) (snd entry)
    (fn_body jp_mario_actions_automatic.f_mario_execute_automatic_action))
    rank9a_attached_dispatch = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank9a_attached_masks : forall action,
  In action rank9a_attached_actions ->
  Int.and action (Int.repr 8192) = Int.zero /\
  Int.and action (Int.repr 16384) = Int.zero /\
  Int.and action (Int.repr 2048) = Int.zero.
Proof.
  intros action H. cbn in H.
  repeat destruct H as [H | H]; try contradiction; subst action;
    vm_compute; repeat split; reflexivity.
Qed.

Definition rank9a_snap_fragment version :=
  match rank11_right_sequence_tail 3 (fn_body (rank9a_body version R9Stop)) with
  | Ssequence snap _ => snap | _ => Sskip end.

Definition rank9a_snap_statement :=
  Ssequence
    (Sset R9S._t'2 (rank11_mario_field_expression R9M._floorHeight tfloat))
    (Sassign rank11_mario_y_expression (Etempvar R9S._t'2 tfloat)).

Theorem rank9a_snap_is_generated : forall version,
  rank9a_snap_fragment version = rank9a_snap_statement.
Proof. intros []; reflexivity. Qed.

Definition rank9a_ledge_prefix version := match fn_body (rank9a_body version R9Ledge) with
| Ssequence prefix _ => prefix | _ => Sskip end.

Definition rank9a_velocity_y_expression :=
  Ederef (Ebinop Oadd
    (rank11_mario_field_expression R9M._vel (tarray tfloat 3))
    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat.

Definition rank9a_ledge_prefix_statement :=
  Ssequence (Sset R9S._t'27 rank9a_velocity_y_expression)
    (Sifthenelse (Ebinop Ogt (Etempvar R9S._t'27 tfloat)
      (Econst_int (Int.repr 0) tint) tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint))) Sskip).

Theorem rank9a_ledge_prefix_is_generated : forall version,
  rank9a_ledge_prefix version = rank9a_ledge_prefix_statement.
Proof. intros []; reflexivity. Qed.

Definition rank9a_initializer_cases version := match fn_body (rank9a_body version R9Initialize) with
| Ssequence (Sswitch _ cases) _ => cases | _ => LSnil end.

Theorem rank9a_dance_initializer_has_no_selected_case : forall version,
  select_switch 4871 (rank9a_initializer_cases version) = LSnil.
Proof. intros []; reflexivity. Qed.

Theorem rank9a_dance_and_fall_call_receipts : forall version,
  calls_ident_s R9C._stop_and_set_height_to_floor
    (fn_body (rank9a_body version R9Dance)) = true /\
  calls_ident_s R9C._perform_air_step
    (fn_body (rank9a_body version R9Dance)) = false /\
  calls_ident_s R9C._perform_air_step
    (fn_body (rank9a_body version R9Fall)) = true.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.
