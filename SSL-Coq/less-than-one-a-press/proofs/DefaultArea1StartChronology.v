(** Default SSL Area-1 execution and platform-lineage boundary.

    SSL Area 1 is the engine's [AREA(1)], the exterior desert.  Its ordinary
    painting entry is the node-0x0A spin-airborne spawn at
    (653,1038,6566).

    This module replaces task-entry/castle-prefix nonvacuity for gameplay
    runs with an explicit scope boundary on the memory of a real selected-
    program Clight state.  It does not construct such a boundary or run.
    The user-authorized boundary remains an explicit premise, while the run
    must contain at least one Clight transition and end at a selected frame
    boundary.

    The platform chronology is not seeded by an unrelated abstract [None].
    [decode_area1_platform_chronology_seed] reads the very
    [gMarioPlatform] cell named by the entry-address witness.  The boundary's
    concrete null load therefore computes to the null chronology lineage for
    both retail versions, including JP. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Integers Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness ClightRefinement DefaultArea1StartBoundary
  EntryMemory GameTypes OrdinaryArea1EntryMemory SelectedClightTarget
  StateFirstPlatformChronology StockProjectionExhaustiveness.

Local Open Scope Z_scope.

(** Every Clight control-state constructor carries the memory on which the
    start boundary is asserted.  This local name avoids depending on the
    later first-target refinement module. *)
Definition default_area1_clight_state_memory
    (state : Clight.state) : Mem.mem :=
  match state with
  | Clight.State _ _ _ _ _ memory => memory
  | Clight.Callstate _ _ _ memory => memory
  | Clight.Returnstate _ _ memory => memory
  end.

Definition platform_retail_version_of_game_version
    (version : GameVersion) : PlatformRetailVersion :=
  match version with
  | VersionUS => PlatformUS
  | VersionJP => PlatformJP
  end.

(** [Some seed] means that the concrete global was decoded.  [Some None]
    means a decoded null pointer; outer [None] means that no supported pointer
    seed was obtained.  Non-null owners need live owner/slot projection and
    are deliberately not guessed by this decoder. *)
Definition decode_area1_platform_chronology_seed
    (memory : Mem.mem) (addresses : Area1EntryAddresses) :
    option (option (Area1InboundNode * Area1DynamicOwnerObservation)) :=
  match load_at Mptr memory
      (area1_platform_pointer_cell_block addresses) 0 0 with
  | Some (Vint word) =>
      if Int.eq word Int.zero then Some None else None
  | _ => None
  end.

Theorem default_area1_start_boundary_decodes_null_platform_seed :
  forall version program memory world previous_down current_down,
    DefaultArea1StartBoundary version program memory world
      previous_down current_down ->
    decode_area1_platform_chronology_seed memory
      (default_area1_entry_addresses world) = Some None.
Proof.
  intros version program memory world previous_down current_down Hstart.
  destruct Hstart as [_ _ _ _ _ _ Hnull _].
  unfold decode_area1_platform_chronology_seed.
  rewrite Hnull.
  reflexivity.
Qed.

Theorem default_area1_start_boundary_has_null_initial_lineage :
  forall version program memory world previous_down current_down,
    DefaultArea1StartBoundary version program memory world
      previous_down current_down ->
    decode_area1_platform_chronology_seed memory
      (default_area1_entry_addresses world) = Some None /\
    initial_platform_lineage
      (platform_retail_version_of_game_version version) None =
      PlatformLineageNull.
Proof.
  intros version program memory world previous_down current_down Hstart.
  split.
  - exact (default_area1_start_boundary_decodes_null_platform_seed
      version program memory world previous_down current_down Hstart).
  - destruct version; reflexivity.
Qed.

(** A non-vacuous gameplay run begins at the declared default exterior
    boundary itself.  [Smallstep.plus], rather than only the reflexive
    [ImportedClightRun.run_steps], requires at least one actual Clight step.
    The end condition makes [WholeProgramClightRefinementObligation]
    applicable to this same run. *)
Record DefaultArea1ActiveSelectedRun
    (projection : ClightObservationProjection)
    (run : ImportedClightRun) (initial : GameState)
    (world : DefaultArea1WorldAddresses)
    (previous_down current_down : int) : Prop := {
  default_area1_active_selected_projection :
    SelectedClightObservationProjection projection;
  default_area1_active_run_uses_projection :
    RunUsesProjection projection run;
  default_area1_active_start_projects :
    project_state projection (run_start run) = Some initial;
  default_area1_active_start_version :
    state_version initial = projection_version projection;
  default_area1_active_start_boundary :
    DefaultArea1StartBoundary
      (projection_version projection) (projection_program projection)
      (default_area1_clight_state_memory (run_start run)) world
      previous_down current_down;
  default_area1_active_positive_execution :
    @Smallstep.plus _ _ Clight.step2
      (Clight.globalenv (run_program run))
      (run_start run) (run_trace run) (run_final run);
  default_area1_active_ends_at_frame_boundary :
    RunEndsAtSelectedFrameBoundary projection run
}.

Definition DefaultArea1StartProjectionNonvacuityObligation
    (projection : ClightObservationProjection) : Prop :=
  exists run initial world previous_down current_down,
    DefaultArea1ActiveSelectedRun projection run initial world
      previous_down current_down.

(** This is the selected-target capstone with clean-entry surjectivity and
    castle-to-entry execution removed from gameplay scope.  Legacy runtime
    task-start witnesses remain inside source/target construction evidence;
    they are not the start state of the active gameplay run quantified here. *)
Definition DefaultArea1SelectedTargetRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  SelectedClightObservationProjection projection /\
  SelectedTargetSourceRefinementObligation projection /\
  SelectedTargetAuditTransportObligation projection /\
  WholeProgramClightRefinementObligation projection /\
  DefaultArea1StartProjectionNonvacuityObligation projection.

Theorem default_area1_active_run_decodes_null_chronology_seed :
  forall projection run initial world previous_down current_down,
    DefaultArea1ActiveSelectedRun projection run initial world
      previous_down current_down ->
    decode_area1_platform_chronology_seed
      (default_area1_clight_state_memory (run_start run))
      (default_area1_entry_addresses world) =
      Some None /\
    initial_platform_lineage
      (platform_retail_version_of_game_version
        (projection_version projection)) None = PlatformLineageNull.
Proof.
  intros projection run initial world previous_down current_down Hrun.
  eapply default_area1_start_boundary_has_null_initial_lineage.
  exact (default_area1_active_start_boundary
    projection run initial world previous_down current_down Hrun).
Qed.

(** The linked pre-apply projection must use the seed decoded from the same
    active run-start memory.  This rules out satisfying the chronology record
    with a freely chosen abstract JP inbound seed. *)
Record DefaultArea1ActivePreapplyProjection
    (projection : ClightObservationProjection)
    (run : ImportedClightRun) (initial : GameState)
    (world : DefaultArea1WorldAddresses)
    (previous_down current_down : int)
    (preapply : UpperWarpPrecollisionApplyProjection) : Prop := {
  default_area1_preapply_active_run :
    DefaultArea1ActiveSelectedRun projection run initial world
      previous_down current_down;
  default_area1_preapply_version_exact :
    projected_platform_version preapply =
      platform_retail_version_of_game_version
        (projection_version projection);
  default_area1_preapply_seed_from_run_start_memory :
    decode_area1_platform_chronology_seed
      (default_area1_clight_state_memory (run_start run))
      (default_area1_entry_addresses world) =
      Some (projected_jp_inbound_seed preapply)
}.

Theorem default_area1_active_preapply_seed_is_null :
  forall projection run initial world previous_down current_down preapply,
    DefaultArea1ActivePreapplyProjection projection run initial world
      previous_down current_down preapply ->
    projected_jp_inbound_seed preapply = None /\
    initial_platform_lineage (projected_platform_version preapply)
      (projected_jp_inbound_seed preapply) = PlatformLineageNull.
Proof.
  intros projection run initial world previous_down current_down preapply
    Hpreapply.
  pose proof (default_area1_active_run_decodes_null_chronology_seed
    projection run initial world previous_down current_down
    (default_area1_preapply_active_run
      projection run initial world previous_down current_down preapply
      Hpreapply)) as [Hdecoded Hlineage].
  pose proof (default_area1_preapply_seed_from_run_start_memory
    projection run initial world previous_down current_down preapply
    Hpreapply) as Hseed.
  rewrite Hdecoded in Hseed.
  injection Hseed as Hseed_none.
  split.
  - symmetry. exact Hseed_none.
  - rewrite <- Hseed_none.
  rewrite (default_area1_preapply_version_exact
    projection run initial world previous_down current_down preapply
    Hpreapply).
  exact Hlineage.
Qed.

(** With a null decoded boundary seed, a final JP-inbound lineage is
    impossible.  The generic chronology theorem proves that completed
    queries, clears, and skips cannot manufacture that constructor. *)
Theorem default_area1_active_preapply_has_no_jp_inbound_final_lineage :
  forall projection run initial world previous_down current_down preapply
      node owner skipped,
    DefaultArea1ActivePreapplyProjection projection run initial world
      previous_down current_down preapply ->
    projected_final_lineage preapply <>
      PlatformLineageJPInbound node owner skipped.
Proof.
  intros projection run initial world previous_down current_down preapply
    node owner skipped Hpreapply.
  destruct (default_area1_active_preapply_seed_is_null
    projection run initial world previous_down current_down preapply
    Hpreapply) as [Hseed Hinitial].
  unfold projected_final_lineage.
  rewrite Hinitial.
  apply null_seed_chronology_cannot_produce_jp_inbound.
Qed.

(** The active default-start witness and whole-program refinement produce a
    certificate for that very run.  This theorem prevents the capstone's
    refinement conjunct from being discharged only on unrelated runs. *)
Theorem default_area1_start_refinement_is_nonvacuous :
  forall projection,
    WholeProgramClightRefinementObligation projection ->
    DefaultArea1StartProjectionNonvacuityObligation projection ->
    exists run initial addresses previous_down current_down
        (certificate : ClightFrameRefinementCertificate projection run initial),
      DefaultArea1ActiveSelectedRun projection run initial addresses
        previous_down current_down.
Proof.
  intros projection Hrefinement Hnonvacuity.
  destruct Hnonvacuity as
    (run & initial & addresses & previous_down & current_down & Hrun).
  destruct (Hrefinement run initial
    (default_area1_active_run_uses_projection
      projection run initial addresses previous_down current_down Hrun)
    (default_area1_active_start_projects
      projection run initial addresses previous_down current_down Hrun)
    (default_area1_active_ends_at_frame_boundary
      projection run initial addresses previous_down current_down Hrun))
    as [certificate _].
  exists run, initial, addresses, previous_down, current_down, certificate.
  exact Hrun.
Qed.

Theorem default_area1_selected_target_refinement_supplies_active_certificate :
  forall projection,
    DefaultArea1SelectedTargetRefinementObligation projection ->
    exists run initial addresses previous_down current_down
        (certificate : ClightFrameRefinementCertificate projection run initial),
      DefaultArea1ActiveSelectedRun projection run initial addresses
        previous_down current_down.
Proof.
  intros projection (_ & _ & _ & Hrefinement & Hnonvacuity).
  now eapply default_area1_start_refinement_is_nonvacuous.
Qed.
