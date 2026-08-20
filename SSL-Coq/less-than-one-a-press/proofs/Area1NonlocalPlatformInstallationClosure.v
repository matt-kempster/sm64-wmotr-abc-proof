(** Stock-installation closure for the exact rank-3 platform mirror.

    [Area1NonlocalPlatformMirror] now supplies bytes which map synchronized
    upper-warp-centre Mario State [(-2048,768,-1024)] to the signed-16 alias
    [(-1862,67314,-902)] in one call.  The platform first contributes X/Z
    velocity [(186,0,122)] and then performs the checked pitch half-turn.
    This file asks the preceding question: can a clean SSL Area-1 scheduler
    state actually reach that call with a non-null [gMarioPlatform] and those
    bytes?

    The answer is negative inside the project's stock scheduler/owner model.
    The exact raw Object position is the upper-warp centre, and every finite
    trace built from a stock seed, completed final queries, preserving frozen
    carries, US clears, and checked JP inbound nodes has a null platform at
    such a boundary.  Consequently the exact payload cannot be installed by
    that model; the contradiction occurs before its matrix arithmetic.

    A second theorem is deliberately constructive about the residual.  If a
    linked boundary trace is classified step-by-step as either a stock step or
    one of [Area1InstallerProjectionEscape]'s six cases, every successful
    exact installation contains an actual escape step.  This does not claim
    those escapes impossible in retail execution.  It makes the remaining
    work precise: alias/external platform-cell writes, owner/surface projection
    failure, a post-query Object writer, a moving query skip, unchecked inbound
    retention, or an unclassified scheduler shape.

    The final source/finite receipts also rule out the obvious payload owners.
    All fifteen canonical surface-owner callback bodies have no direct pitch-
    angular-velocity store; fresh allocation zeroes that word; the two checked
    break-fragment branches use [3840] or [6400], not [-32768]; and the stock
    pyramid top never reaches pivot Y [34041] in its complete spinning model.
    These are not a transitive whole-program alias proof, so forged behavior,
    indirect/OOB writes, and noncanonical slot reuse remain escape cases. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_obj_behaviors
  jp_behavior_actions jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1InstallerTemporalClosure Area1NonlocalPlatformMirror
  Area1PhaseSplit Area1PlatformExhaustiveness Area1PrecollisionWriterClosure
  FirstTargetRefinement GameTypes PyramidTopPU PyramidTopSurface
  StockWarpTopMotion.

Import ListNotations.
Local Open Scope Z_scope.

Module A1NPIC_USActions := us_behavior_actions.
Module A1NPIC_USObjects := us_obj_behaviors.
Module A1NPIC_JPActions := jp_behavior_actions.
Module A1NPIC_JPObjects := jp_obj_behaviors.

(** The old rotation-only receipt starts here.  This point is not actually in
    upper-warp contact; treating it as the raw collision Object would silently
    assume the horizontal part of the desired split. *)
Definition rank3_rotation_only_input_position : PositionZ :=
  {| position_x := -1862;
     position_y := 768;
     position_z := -902 |}.

Theorem rank3_rotation_only_input_misses_upper_warp :
  ~ upper_warp_contact rank3_rotation_only_input_position.
Proof.
  unfold upper_warp_contact, horizontal_distance_squared,
    rank3_rotation_only_input_position, upper_warp_center,
    upper_warp_radius, mario_hitbox_radius,
    upper_warp_x, upper_warp_z, upper_warp_y, upper_warp_height,
    mario_hitbox_height.
  cbn. lia.
Qed.

Definition rank3_clean_collision_position : PositionZ := upper_warp_center.

Theorem rank3_clean_collision_position_hits_upper_warp :
  upper_warp_contact rank3_clean_collision_position.
Proof.
  unfold rank3_clean_collision_position, upper_warp_contact,
    horizontal_distance_squared, upper_warp_center,
    upper_warp_radius, mario_hitbox_radius,
    upper_warp_y, upper_warp_height, mario_hitbox_height.
  cbn. repeat split; lia.
Qed.

Theorem rank3_rotation_only_receipt_requires_preexisting_horizontal_split :
  position_x rank3_rotation_only_input_position <>
      position_x rank3_clean_collision_position /\
  position_z rank3_rotation_only_input_position <>
      position_z rank3_clean_collision_position.
Proof.
  unfold rank3_rotation_only_input_position, rank3_clean_collision_position,
    upper_warp_center. cbn. split; discriminate.
Qed.

(** A clean attempt relative to the already-audited stock scheduler model.
    The payload equality is retained in the record even though pointer
    provenance yields the contradiction first. *)
Record Rank3StockExactPayloadInstallation : Type := {
  rank3_stock_install_start : Area1PrecollisionSnapshot;
  rank3_stock_install_preapply : Area1PrecollisionSnapshot;
  rank3_stock_install_seed :
    StockArea1InstallerSeed rank3_stock_install_start;
  rank3_stock_install_trace :
    StockArea1SchedulerBoundaryTrace
      rank3_stock_install_start rank3_stock_install_preapply;
  rank3_stock_install_object_exact :
    precollision_object_position rank3_stock_install_preapply =
      rank3_clean_collision_position;
  rank3_stock_install_platform_nonnull :
    precollision_platform_owner rank3_stock_install_preapply <> None;
  rank3_stock_install_payload : PlatformDisplacementRawPayload;
  rank3_stock_install_payload_exact :
    rank3_stock_install_payload = rank3_full_split_payload
}.

Theorem no_stock_rank3_exact_payload_installation :
  Rank3StockExactPayloadInstallation -> False.
Proof.
  intros attempt.
  eapply no_stock_temporal_platform_installer.
  refine
    {| temporal_installer_start := rank3_stock_install_start attempt;
       temporal_installer_preapply := rank3_stock_install_preapply attempt;
       temporal_installer_seed := rank3_stock_install_seed attempt;
       temporal_installer_trace := rank3_stock_install_trace attempt;
       temporal_installer_object_hits_upper_warp := _;
       temporal_installer_platform_is_nonnull :=
         rank3_stock_install_platform_nonnull attempt |}.
  rewrite (rank3_stock_install_object_exact attempt).
  exact rank3_clean_collision_position_hits_upper_warp.
Qed.

(** A trace relation which retains the precise escape constructor and the
    boundary edge on which it occurred. *)
Section ClassifiedTrace.

Variable projects_escape :
  Area1InstallerProjectionEscape ->
  Area1PrecollisionSnapshot -> Area1PrecollisionSnapshot -> Prop.

Definition Rank3ClassifiedBoundaryStep
    (before after : Area1PrecollisionSnapshot) : Prop :=
  StockArea1SchedulerBoundaryStep before after \/
  exists escape, projects_escape escape before after.

Inductive Rank3ClassifiedBoundaryTrace :
    Area1PrecollisionSnapshot -> Area1PrecollisionSnapshot -> Prop :=
| Rank3ClassifiedTraceNil :
    forall snapshot, Rank3ClassifiedBoundaryTrace snapshot snapshot
| Rank3ClassifiedTraceCons :
    forall before middle after,
      Rank3ClassifiedBoundaryStep before middle ->
      Rank3ClassifiedBoundaryTrace middle after ->
      Rank3ClassifiedBoundaryTrace before after.

Theorem rank3_classified_trace_is_stock_or_exposes_escape :
  forall before after,
    Rank3ClassifiedBoundaryTrace before after ->
    StockArea1SchedulerBoundaryTrace before after \/
    exists escape edge_before edge_after,
      projects_escape escape edge_before edge_after.
Proof.
  intros before after trace.
  induction trace as
    [snapshot | before middle after Hstep Htail IH].
  - left. apply StockSchedulerTraceNil.
  - destruct Hstep as [Hstock | (escape & Hescape)].
    + destruct IH as [Hstock_tail | Htail_escape].
      * left. eapply StockSchedulerTraceCons; eauto.
      * right. exact Htail_escape.
    + right. exists escape, before, middle. exact Hescape.
Qed.

Record Rank3ClassifiedExactPayloadInstallation : Type := {
  rank3_classified_install_start : Area1PrecollisionSnapshot;
  rank3_classified_install_preapply : Area1PrecollisionSnapshot;
  rank3_classified_install_seed :
    StockArea1InstallerSeed rank3_classified_install_start;
  rank3_classified_install_trace :
    Rank3ClassifiedBoundaryTrace
      rank3_classified_install_start rank3_classified_install_preapply;
  rank3_classified_install_object_exact :
    precollision_object_position rank3_classified_install_preapply =
      rank3_clean_collision_position;
  rank3_classified_install_platform_nonnull :
    precollision_platform_owner rank3_classified_install_preapply <> None;
  rank3_classified_install_payload : PlatformDisplacementRawPayload;
  rank3_classified_install_payload_exact :
    rank3_classified_install_payload = rank3_full_split_payload
}.

Theorem rank3_exact_installation_requires_projection_escape :
  forall attempt : Rank3ClassifiedExactPayloadInstallation,
    exists escape edge_before edge_after,
      projects_escape escape edge_before edge_after.
Proof.
  intros attempt.
  destruct (rank3_classified_trace_is_stock_or_exposes_escape
    (rank3_classified_install_start attempt)
    (rank3_classified_install_preapply attempt)
    (rank3_classified_install_trace attempt)) as [Hstock | Hescape].
  - exfalso.
    eapply no_stock_temporal_platform_installer.
    refine
      {| temporal_installer_start := rank3_classified_install_start attempt;
         temporal_installer_preapply := rank3_classified_install_preapply attempt;
         temporal_installer_seed := rank3_classified_install_seed attempt;
         temporal_installer_trace := Hstock;
         temporal_installer_object_hits_upper_warp := _;
         temporal_installer_platform_is_nonnull :=
           rank3_classified_install_platform_nonnull attempt |}.
    rewrite (rank3_classified_install_object_exact attempt).
    exact rank3_clean_collision_position_hits_upper_warp.
  - exact Hescape.
Qed.

End ClassifiedTrace.

(** Direct generated-source checks for the obvious canonical/replacement
    payload owners.  The 29-body lists are exactly the native callbacks of the
    fifteen finite stock surface owners.  The pyramid-fragment loop changes
    face pitch but not the angular-velocity word used by platform
    displacement. *)
Definition rank3_direct_pitch_writer_source_claim : Prop :=
  map
    (fun body =>
      assigns_array_slot_s A1NPIC_USActions._asS32 35 (fn_body body))
    us_area1_stock_surface_native_bodies = repeat false 29 /\
  map
    (fun body =>
      assigns_array_slot_s A1NPIC_JPActions._asS32 35 (fn_body body))
    jp_area1_stock_surface_native_bodies = repeat false 29 /\
  assigns_array_slot_s A1NPIC_USObjects._asS32 35
    (fn_body A1NPIC_USObjects.f_bhv_pyramid_top_fragment_loop) = false /\
  assigns_array_slot_s A1NPIC_JPObjects._asS32 35
    (fn_body A1NPIC_JPObjects.f_bhv_pyramid_top_fragment_loop) = false /\
  area1_fragment_writer_source_claim.

Theorem rank3_direct_pitch_writer_source_checked :
  rank3_direct_pitch_writer_source_claim.
Proof.
  unfold rank3_direct_pitch_writer_source_claim.
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  exact area1_fragment_writer_source_checked.
Qed.

(** Values in the narrow finite payload classes currently justified for a
    canonical surface or same-frame Area-1 fragment replacement.  This
    datatype is not claimed to cover forged behavior or arbitrary aliases. *)
Inductive KnownArea1PreapplyPitchSource : Type :=
| PitchFromFreshOrCanonicalSurface
| PitchFromDirtBreakFragment
| PitchFromCartoonBreakFragment
| PitchFromPyramidTopFragment.

Definition known_area1_preapply_pitch_velocity
    (source : KnownArea1PreapplyPitchSource) : Z :=
  match source with
  | PitchFromFreshOrCanonicalSurface => 0
  | PitchFromDirtBreakFragment => 3840
  | PitchFromCartoonBreakFragment => 6400
  | PitchFromPyramidTopFragment => 0
  end.

Theorem rank3_required_pitch_velocity_is_negative_half_turn :
  Int.signed
    (platform_payload_rotation_pitch_s16 rank3_full_split_payload) = -32768.
Proof. vm_compute. reflexivity. Qed.

Theorem known_area1_preapply_pitch_never_matches_rank3_half_turn :
  forall source,
    known_area1_preapply_pitch_velocity source <>
      Int.signed
        (platform_payload_rotation_pitch_s16 rank3_full_split_payload).
Proof.
  intros source. destruct source; vm_compute; discriminate.
Qed.

Definition stock_top_never_has_rank3_pivot_b (timer : nat) : bool :=
  negb
    (Float32.cmp Ceq
      (modeled_stock_top_center_y timer)
      (f32_of_Z 34041)).

Theorem stock_top_never_has_rank3_pivot_checked :
  forallb stock_top_never_has_rank3_pivot_b (seq 0 151) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem checked_fragment_pivots_are_not_rank3_pivot :
  Float32.cmp Ceq (f32_y area1_fragment_pivot) (f32_of_Z 34041) = false /\
  Float32.cmp Ceq
    (f32_y area1_candidate_fragment_pivot) (f32_of_Z 34041) = false.
Proof. vm_compute. split; reflexivity. Qed.

Definition Area1NonlocalPlatformInstallationCheckedBoundary : Prop :=
  ~ upper_warp_contact rank3_rotation_only_input_position /\
  upper_warp_contact rank3_clean_collision_position /\
  (position_x rank3_rotation_only_input_position <>
      position_x rank3_clean_collision_position /\
   position_z rank3_rotation_only_input_position <>
      position_z rank3_clean_collision_position) /\
  rank3_direct_pitch_writer_source_claim /\
  forallb stock_top_never_has_rank3_pivot_b (seq 0 151) = true /\
  (Float32.cmp Ceq (f32_y area1_fragment_pivot) (f32_of_Z 34041) = false /\
   Float32.cmp Ceq
     (f32_y area1_candidate_fragment_pivot) (f32_of_Z 34041) = false) /\
  (forall source,
    known_area1_preapply_pitch_velocity source <>
      Int.signed
        (platform_payload_rotation_pitch_s16 rank3_full_split_payload)) /\
  (Rank3StockExactPayloadInstallation -> False) /\
  (forall projects_escape
      (attempt : Rank3ClassifiedExactPayloadInstallation projects_escape),
    exists escape edge_before edge_after,
      projects_escape escape edge_before edge_after).

Theorem area1_nonlocal_platform_installation_checked_boundary_holds :
  Area1NonlocalPlatformInstallationCheckedBoundary.
Proof.
  unfold Area1NonlocalPlatformInstallationCheckedBoundary.
  split; [exact rank3_rotation_only_input_misses_upper_warp |].
  split; [exact rank3_clean_collision_position_hits_upper_warp |].
  split; [exact rank3_rotation_only_receipt_requires_preexisting_horizontal_split |].
  split; [exact rank3_direct_pitch_writer_source_checked |].
  split; [exact stock_top_never_has_rank3_pivot_checked |].
  split; [exact checked_fragment_pivots_are_not_rank3_pivot |].
  split; [exact known_area1_preapply_pitch_never_matches_rank3_half_turn |].
  split; [exact no_stock_rank3_exact_payload_installation |].
  exact rank3_exact_installation_requires_projection_escape.
Qed.
