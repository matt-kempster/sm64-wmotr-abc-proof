(** Exact semantic-target selection for observation projections.

    The original 38-unit programs cannot share a single CompCert [linkorder]
    upper bound because several generated units give the same composite tag
    different definitions.  In particular, requiring [TargetLinkedProgram]
    made both US and JP observation projections uninhabitable.

    This module uses the programs that the linking tranche actually built:
    the whole-AST viewport-repaired US program and the official cleaned JP
    program.  The selection evidence proves only that the chosen construction
    succeeded.  Header normalization is retained below as a structural
    separate-compilation audit; execution starts from the resulting whole
    linked program, never from a standalone translation unit whose unresolved
    cross-unit calls have [EF_external] semantics.  The US tag repair remains
    an explicit whole-program lockstep obligation, and neither Clight program
    is identified here with retail MIPS execution. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Errors Globalenvs Linking Memory Values.
From LessThanOneAPress.Generated Require Import us_game_init jp_game_init.
From LessThanOneAPress.Proofs Require Import
  GameTypes LinkedClightPrograms CleanedClightPrograms
  ClightRefinement ClightEndToEndRefinement
  ClightLinkExecution NormalizedClightPrograms RetailExternalFrames
  USViewportRepairedProgramCertificate
  USWholeASTTagRepair.

Import ListNotations.

Definition selected_clight_target (version : GameVersion) : Clight.program :=
  match version with
  | VersionUS => us_viewport_repaired_program
  | VersionJP => jp_official_cleaned_slice
  end.

(** The official cleaned link is the semantic source.  This is the first
    whole program in the construction: cross-unit callees have been resolved
    by [link_list], so its [Clight.step2] relation does not expose them as the
    arbitrary external oracle of a standalone generated unit. *)
Definition selected_clight_source (version : GameVersion) : Clight.program :=
  match version with
  | VersionUS => us_official_cleaned_slice
  | VersionJP => jp_official_cleaned_slice
  end.

Definition selected_original_units
    (version : GameVersion) : nlist Clight.program :=
  match version with
  | VersionUS => us_units
  | VersionJP => jp_units
  end.

(** These generated slices do not contain the platform boot [main] body even
    though [prog_main] names it.  Their concrete execution boundary is the
    game task entry exported by [game_init]. *)
Definition selected_runtime_entry_ident (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_game_init._thread5_game_loop
  | VersionJP => jp_game_init._thread5_game_loop
  end.

(** A real start state for the selected semantic slice.  This deliberately
    does not use [Clight.initial_state], whose missing [_main] premise makes it
    uninhabitable for the current slice.  Future retail linkage must still
    justify the initialized memory and OS-to-task handoff represented by this
    boundary.  The generated task's single pointer argument is pinned to the
    null value and an actual first Clight step rules out a stuck start. *)
Definition SelectedRuntimeTaskStart
    (version : GameVersion) (program : Clight.program)
    (state : Clight.state) : Prop :=
  exists (initial_memory : Mem.mem) (entry_block : block)
      (entry_function : function),
    Genv.init_mem program = Some initial_memory /\
    Genv.find_symbol (Clight.globalenv program)
      (selected_runtime_entry_ident version) = Some entry_block /\
    Genv.find_funct_ptr (Clight.globalenv program) entry_block =
      Some (Internal entry_function) /\
    state = Callstate (Internal entry_function)
      [Vnullptr] Kstop initial_memory /\
    exists step_trace next_state,
      Clight.step2 (Clight.globalenv program) state step_trace next_state.

Definition selected_runtime_origin
    (projection : ClightObservationProjection) :
    Clight.state -> Prop :=
  SelectedRuntimeTaskStart
    (projection_version projection) (projection_program projection).

Definition SelectedClightTargetBuildEvidence
    (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      us_viewport_repaired_program_builds = true
  | VersionJP =>
      link_list jp_cleaned_units = Some jp_official_cleaned_slice
  end.

Theorem selected_clight_target_builds_checked :
  forall version, SelectedClightTargetBuildEvidence version.
Proof.
  intros []; cbn.
  - exact us_viewport_repaired_program_success_flag_checked.
  - exact jp_cleaned_units_official_link.
Qed.

Record SelectedClightObservationProjection
    (projection : ClightObservationProjection) : Prop := {
  selected_projection_program_exact :
    projection_program projection =
      selected_clight_target (projection_version projection);
  selected_projection_target_built :
    SelectedClightTargetBuildEvidence (projection_version projection)
}.

Theorem selected_clight_observation_projection_checked :
  forall projection,
    projection_program projection =
      selected_clight_target (projection_version projection) ->
    SelectedClightObservationProjection projection.
Proof.
  intros projection Hexact. constructor.
  - exact Hexact.
  - apply selected_clight_target_builds_checked.
Qed.

(** This checked structural certificate is the precise claim made about the
    38 original generated units.  It records source ownership of retained
    definitions, verbatim preservation, identifier/composite coverage, use of
    the normalized header, and successful official linking.  It deliberately
    makes no closed-world [Clight.step2] claim about a standalone unit: such a
    claim would give its unresolved cross-unit [EF_external] declarations an
    unconstrained oracle meaning and would quantify over fabricated raw
    [Clight.state] values unrelated to that unit. *)
Definition OriginalUnitsHeaderNormalizationStructuralObligation
    (version : GameVersion) : Prop :=
  NormalizedCleanedUnitsOfficialLinkStructuralObligation
    (selected_original_units version) (selected_clight_source version).

Theorem original_units_header_normalization_structural_checked :
  forall version,
    OriginalUnitsHeaderNormalizationStructuralObligation version.
Proof.
  intros []; cbn.
  - exact us_normalized_cleaned_units_official_link_structural.
  - exact jp_normalized_cleaned_units_official_link_structural.
Qed.

(** Semantic transport begins only after separate compilation has produced a
    whole linked source.  A standard lockstep record supplies public-symbol,
    initial/final-state, and one-step preservation.  The related task-entry
    pair makes the relation nonempty at an actual first-step boundary, ruling
    out [False] and other wholly vacuous match relations.  For US this is the
    semantic obligation for the whole-AST viewport repair; for JP the selected
    target is the exact official cleaned source. *)
Definition WholeLinkedSourceToSelectedTargetRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  exists components : ClightLockstepComponents
      (selected_clight_source (projection_version projection))
      (projection_program projection),
    exists source_start target_start,
      SelectedRuntimeTaskStart
        (projection_version projection)
        (selected_clight_source (projection_version projection))
        source_start /\
      SelectedRuntimeTaskStart
        (projection_version projection)
        (projection_program projection) target_start /\
      lockstep_match_states _ _ components source_start target_start.

Definition SelectedTargetSourceRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  OriginalUnitsHeaderNormalizationStructuralObligation
    (projection_version projection) /\
  WholeLinkedSourceToSelectedTargetRefinementObligation projection.

(** Syntax/global checks must be stated on the actual selected program.  This
    prevents official-cleaned-slice certificates from being silently reused
    for the repaired US program without a preservation theorem. *)
Record SelectedTargetSyntaxAuditObligation
    (projection : ClightObservationProjection) : Prop := {
  selected_target_has_no_direct_sbuiltin :
    program_direct_sbuiltins (projection_program projection) = [];
  selected_target_external_constructors_supported :
    forallb external_global_has_supported_constructor
      (prog_defs (projection_program projection)) = true;
  selected_target_internal_evars_resolve :
    forall function_id body global_id,
      In (function_id, Gfun (Internal body))
        (prog_defs (projection_program projection)) ->
      In global_id (statement_evar_identifiers (fn_body body)) ->
      ~ In global_id (function_local_identifiers body) ->
      exists block,
        Genv.find_symbol (Clight.globalenv (projection_program projection))
          global_id = Some block;
  selected_target_init_addrof_resolves :
    forall global_id,
      In global_id
        (program_init_addrof_identifiers (projection_program projection)) ->
      exists block,
        Genv.find_symbol (Clight.globalenv (projection_program projection))
          global_id = Some block
}.

Lemma official_definition_provenance_transfers_supported_constructors :
  forall source_units linked,
    OfficialSourceDefinitionProvenance source_units linked ->
    source_global_external_constructors_complete source_units = true ->
    forallb external_global_has_supported_constructor
      (prog_defs linked) = true.
Proof.
  intros source_units linked Hprovenance Hsource.
  unfold source_global_external_constructors_complete in Hsource.
  rewrite forallb_forall in Hsource |- *.
  intros [id definition] Hin.
  exact (Hsource (id, definition) (Hprovenance id definition Hin)).
Qed.

Theorem jp_official_external_constructors_supported :
  forallb external_global_has_supported_constructor
    (prog_defs jp_official_cleaned_slice) = true.
Proof.
  eapply official_definition_provenance_transfers_supported_constructors.
  - exact jp_official_source_definition_provenance.
  - exact jp_source_global_external_constructors_complete.
Qed.

(** All four syntax/global-shape fields are closed for the concrete selected
    JP target.  This theorem deliberately stops before the five core-symbol
    existence facts and before any small-step or retail-execution claim. *)
Theorem jp_selected_target_syntax_audit_checked :
  forall projection,
    projection_program projection = jp_official_cleaned_slice ->
    SelectedTargetSyntaxAuditObligation projection.
Proof.
  intros projection Hprogram.
  constructor; rewrite Hprogram.
  - exact jp_official_target_has_no_direct_sbuiltin.
  - exact jp_official_external_constructors_supported.
  - exact jp_official_internal_body_evar_resolves.
  - exact jp_official_init_addrof_identifier_resolves.
Qed.

Definition selected_target_core_identifiers
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS => us_retail_state_global_identifiers
  | VersionJP => jp_retail_state_global_identifiers
  end.

Definition SelectedTargetCoreSymbolsObligation
    (projection : ClightObservationProjection) : Prop :=
  forall id,
    In id (selected_target_core_identifiers
      (projection_version projection)) ->
    exists block,
      Genv.find_symbol (Clight.globalenv (projection_program projection)) id =
        Some block.

(** The selected US target is a repaired program, not the official cleaned
    slice used by several existing certificates.  Its semantic repair proof
    is the whole-program lockstep above, rather than the older step-only
    repair predicate.  This audit therefore pins the concrete construction
    and performs fresh checks over the actual selected target without
    claiming a second, weaker simulation. *)
Definition SelectedTargetAuditTransportObligation
    (projection : ClightObservationProjection) : Prop :=
  (match projection_version projection with
   | VersionUS =>
       projection_program projection = us_viewport_repaired_program
   | VersionJP => projection_program projection = jp_official_cleaned_slice
   end) /\
  SelectedTargetSyntaxAuditObligation projection /\
  SelectedTargetCoreSymbolsObligation projection.

Definition SelectedTargetClightRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  SelectedClightObservationProjection projection /\
  SelectedTargetSourceRefinementObligation projection /\
  SelectedTargetAuditTransportObligation projection /\
  TargetClightRefinementObligation projection.

Theorem selected_projection_uses_built_target :
  forall projection,
    SelectedClightObservationProjection projection ->
    projection_program projection =
      selected_clight_target (projection_version projection) /\
    SelectedClightTargetBuildEvidence (projection_version projection).
Proof.
  intros projection Hselection.
  destruct Hselection. split; assumption.
Qed.

(** Remaining semantic boundary: the repaired-US anchored
    whole-linked-source lockstep must be inhabited, and each selected Clight
    task execution must ultimately be related to compiled retail execution.
    [JPSelectedRuntimeTaskStart] closes the definitionally reflexive JP
    source-to-selected instance in a downstream module.  Original-unit
    ownership and header normalization are closed structurally above; no
    standalone-unit external-oracle execution is advertised.  This
    target-selection module itself manufactures neither semantic witness. *)
