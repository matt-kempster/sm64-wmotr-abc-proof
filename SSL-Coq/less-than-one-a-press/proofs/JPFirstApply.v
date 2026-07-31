From Coq Require Import Bool Lia List.
From compcert Require Import Clight Events.
From LessThanOneAPress.Generated Require Import
  jp_game_init jp_level_update jp_platform_displacement jp_spawn_object.
From LessThanOneAPress.Proofs Require Import
  GameTypes CleanEntry ClightRefinement JPSlotLifetime.

Import ListNotations.

Module JPFirstApplyGameInit := jp_game_init.
Module JPFirstApplyLevel := jp_level_update.
Module JPFirstApplyPlatform := jp_platform_displacement.
Module JPFirstApplySpawn := jp_spawn_object.

(** This file separates three statements which must not be conflated:

    - the finite allocation arithmetic;
    - the order "first destination apply, first destination input poll,
      second destination apply";
    - the still-pending projection of those facts from the live JP Clight
      execution.

    In particular, none of the arithmetic theorems below asserts that a
    retail execution realizes the stated allocation census.  That connection
    is the explicit source-projection obligation at the end of the file. *)

(** The 74 loader allocations are decomposed rather than introduced as an
    unexplained total: three special-geometry objects, fifty macro objects,
    twenty SpawnInfo objects, and Mario. *)
Definition jp_loader_special_geometry_allocations : nat := 3.
Definition jp_loader_macro_allocations : nat := 50.
Definition jp_loader_spawninfo_allocations : nat := 20.
Definition jp_loader_mario_allocations : nat := 1.

Definition jp_loader_fresh_allocations : nat :=
  jp_loader_special_geometry_allocations +
  jp_loader_macro_allocations +
  jp_loader_spawninfo_allocations +
  jp_loader_mario_allocations.

Definition jp_marker_ball_fresh_allocations : nat := 10.

Definition jp_saved_cap_fresh_allocations (saved_cap : bool) : nat :=
  if saved_cap then 1 else 0.

Definition jp_pre_true_first_apply_fresh_allocations
    (saved_cap : bool) : nat :=
  jp_loader_fresh_allocations +
  jp_marker_ball_fresh_allocations +
  jp_saved_cap_fresh_allocations saved_cap.

Theorem jp_loader_allocation_decomposition_is_74 :
  jp_loader_fresh_allocations = 74.
Proof. reflexivity. Qed.

(** Conditional Spindel ordinal extracted from the reversed SpawnInfo order.
    These are one-based allocation ordinals until the final [pred].  The
    arithmetic does not assert that respawn filtering or a concrete retail
    trace actually makes every listed predecessor allocate; that execution
    connection remains part of the source-projection evidence below. *)
Definition jp_spindel_reversed_spawninfo_ordinal_one_based : nat := 11.

Definition jp_spindel_conditional_overall_ordinal_one_based : nat :=
  jp_loader_special_geometry_allocations +
  jp_loader_macro_allocations +
  jp_spindel_reversed_spawninfo_ordinal_one_based.

Definition jp_spindel_conditional_free_list_depth_zero_based : nat :=
  pred jp_spindel_conditional_overall_ordinal_one_based.

Theorem jp_spindel_reversed_spawninfo_ordinal_is_11 :
  jp_spindel_reversed_spawninfo_ordinal_one_based = 11.
Proof. reflexivity. Qed.

Theorem jp_spindel_conditional_overall_allocation_is_64 :
  jp_spindel_conditional_overall_ordinal_one_based = 64.
Proof. reflexivity. Qed.

Theorem jp_spindel_conditional_free_list_depth_is_63 :
  jp_spindel_conditional_free_list_depth_zero_based = 63.
Proof. reflexivity. Qed.

Theorem jp_spindel_conditional_ordinal_bundle :
  jp_spindel_reversed_spawninfo_ordinal_one_based = 11 /\
  jp_spindel_conditional_overall_ordinal_one_based = 64 /\
  jp_spindel_conditional_free_list_depth_zero_based = 63.
Proof. repeat split; reflexivity. Qed.

Theorem jp_pre_true_first_apply_count_without_saved_cap :
  jp_pre_true_first_apply_fresh_allocations false = 84.
Proof. reflexivity. Qed.

Theorem jp_pre_true_first_apply_count_with_saved_cap :
  jp_pre_true_first_apply_fresh_allocations true = 85.
Proof. reflexivity. Qed.

Theorem jp_pre_true_first_apply_count_exact :
  forall saved_cap,
    jp_pre_true_first_apply_fresh_allocations saved_cap =
      if saved_cap then 85 else 84.
Proof. now destruct saved_cap. Qed.

(** Allocation pops a prefix from the LIFO free list.  These definitions are
    deliberately list based: a free-list depth is a position in this list,
    not an object-pool array index. *)
Definition jp_popped_free_list_prefix
    {Slot : Type} (saved_cap : bool) (free_list : list Slot) : list Slot :=
  firstn (jp_pre_true_first_apply_fresh_allocations saved_cap) free_list.

Definition jp_surviving_free_list_suffix
    {Slot : Type} (saved_cap : bool) (free_list : list Slot) : list Slot :=
  skipn (jp_pre_true_first_apply_fresh_allocations saved_cap) free_list.

Definition jp_free_list_depth_is_popped
    (saved_cap : bool) (depth : nat) : Prop :=
  depth < jp_pre_true_first_apply_fresh_allocations saved_cap.

Definition jp_free_list_depth_survives
    (saved_cap : bool) (depth : nat) : Prop :=
  jp_pre_true_first_apply_fresh_allocations saved_cap <= depth.

Definition jp_free_list_slot_is_selected_for_reuse
    {Slot : Type} (saved_cap : bool) (free_list : list Slot)
    (slot : Slot) : Prop :=
  In slot (jp_popped_free_list_prefix saved_cap free_list).

Definition jp_free_list_slot_survives
    {Slot : Type} (saved_cap : bool) (free_list : list Slot)
    (slot : Slot) : Prop :=
  In slot (jp_surviving_free_list_suffix saved_cap free_list).

Lemma nth_error_firstn_before :
  forall (Slot : Type) (free_list : list Slot) count depth,
    depth < count ->
    nth_error (firstn count free_list) depth =
      nth_error free_list depth.
Proof.
  intros Slot free_list.
  induction free_list as [|head tail IH]; intros count depth Hdepth.
  - now destruct count.
  - destruct count as [|count]; [lia|].
    destruct depth as [|depth]; [reflexivity|].
    simpl. apply IH. lia.
Qed.

Lemma nth_error_skipn_plus :
  forall (Slot : Type) (free_list : list Slot) count residual,
    nth_error (skipn count free_list) residual =
      nth_error free_list (count + residual).
Proof.
  intros Slot free_list count.
  revert free_list.
  induction count as [|count IH]; intros free_list residual.
  - reflexivity.
  - destruct free_list as [|head tail].
    + destruct residual; reflexivity.
    + simpl. apply IH.
Qed.

Theorem popped_depth_lookup_is_preserved :
  forall (Slot : Type) (saved_cap : bool) (free_list : list Slot)
      depth slot,
    jp_free_list_depth_is_popped saved_cap depth ->
    nth_error free_list depth = Some slot ->
    nth_error (jp_popped_free_list_prefix saved_cap free_list) depth =
      Some slot.
Proof.
  intros Slot saved_cap free_list depth slot Hdepth Hlookup.
  unfold jp_popped_free_list_prefix.
  rewrite nth_error_firstn_before by exact Hdepth.
  exact Hlookup.
Qed.

Theorem surviving_depth_lookup_is_shifted_exactly :
  forall (Slot : Type) (saved_cap : bool) (free_list : list Slot)
      depth slot,
    jp_free_list_depth_survives saved_cap depth ->
    nth_error free_list depth = Some slot ->
    nth_error (jp_surviving_free_list_suffix saved_cap free_list)
      (depth - jp_pre_true_first_apply_fresh_allocations saved_cap) =
      Some slot.
Proof.
  intros Slot saved_cap free_list depth slot Hdepth Hlookup.
  unfold jp_free_list_depth_survives in Hdepth.
  unfold jp_surviving_free_list_suffix.
  rewrite nth_error_skipn_plus.
  replace
    (jp_pre_true_first_apply_fresh_allocations saved_cap +
      (depth - jp_pre_true_first_apply_fresh_allocations saved_cap))
    with depth by lia.
  exact Hlookup.
Qed.

Theorem popped_depth_selects_present_slot_for_reuse :
  forall (Slot : Type) (saved_cap : bool) (free_list : list Slot)
      depth slot,
    jp_free_list_depth_is_popped saved_cap depth ->
    nth_error free_list depth = Some slot ->
    jp_free_list_slot_is_selected_for_reuse saved_cap free_list slot.
Proof.
  intros Slot saved_cap free_list depth slot Hdepth Hlookup.
  unfold jp_free_list_slot_is_selected_for_reuse.
  eapply nth_error_In.
  exact
    (popped_depth_lookup_is_preserved
      Slot saved_cap free_list depth slot Hdepth Hlookup).
Qed.

Theorem surviving_depth_preserves_present_slot :
  forall (Slot : Type) (saved_cap : bool) (free_list : list Slot)
      depth slot,
    jp_free_list_depth_survives saved_cap depth ->
    nth_error free_list depth = Some slot ->
    jp_free_list_slot_survives saved_cap free_list slot.
Proof.
  intros Slot saved_cap free_list depth slot Hdepth Hlookup.
  unfold jp_free_list_slot_survives.
  eapply nth_error_In.
  exact
    (surviving_depth_lookup_is_shifted_exactly
      Slot saved_cap free_list depth slot Hdepth Hlookup).
Qed.

Theorem jp_no_cap_popped_depths_are_exactly_0_through_83 :
  forall depth,
    jp_free_list_depth_is_popped false depth <-> depth <= 83.
Proof. intro depth. unfold jp_free_list_depth_is_popped. cbn. lia. Qed.

Theorem jp_no_cap_surviving_depths_begin_at_84 :
  forall depth,
    jp_free_list_depth_survives false depth <-> 84 <= depth.
Proof. intro depth. unfold jp_free_list_depth_survives. cbn. tauto. Qed.

Theorem jp_saved_cap_popped_depths_are_exactly_0_through_84 :
  forall depth,
    jp_free_list_depth_is_popped true depth <-> depth <= 84.
Proof. intro depth. unfold jp_free_list_depth_is_popped. cbn. lia. Qed.

Theorem jp_saved_cap_surviving_depths_begin_at_85 :
  forall depth,
    jp_free_list_depth_survives true depth <-> 85 <= depth.
Proof. intro depth. unfold jp_free_list_depth_survives. cbn. tauto. Qed.

(** These four corollaries instantiate the depth arithmetic over the existing
    LIFO construction [free_list_after_early_release].  "Selected for reuse"
    here means membership in the exact prefix popped by the modeled fresh
    allocation count; the final source obligation must establish that the live
    allocator realizes this list model. *)
Theorem jp_no_cap_early_release_depth_0_through_83_is_selected :
  forall (Slot : Type) (initial bulk : list Slot) (watched slot : Slot)
      depth,
    depth <= 83 ->
    nth_error (free_list_after_early_release initial bulk watched) depth =
      Some slot ->
    jp_free_list_slot_is_selected_for_reuse false
      (free_list_after_early_release initial bulk watched) slot.
Proof.
  intros Slot initial bulk watched slot depth Hdepth Hlookup.
  eapply popped_depth_selects_present_slot_for_reuse; [|exact Hlookup].
  now apply (proj2 (jp_no_cap_popped_depths_are_exactly_0_through_83 depth)).
Qed.

Theorem jp_no_cap_early_release_depth_84_or_later_survives :
  forall (Slot : Type) (initial bulk : list Slot) (watched slot : Slot)
      depth,
    84 <= depth ->
    nth_error (free_list_after_early_release initial bulk watched) depth =
      Some slot ->
    jp_free_list_slot_survives false
      (free_list_after_early_release initial bulk watched) slot.
Proof.
  intros Slot initial bulk watched slot depth Hdepth Hlookup.
  eapply surviving_depth_preserves_present_slot; [|exact Hlookup].
  now apply (proj2 (jp_no_cap_surviving_depths_begin_at_84 depth)).
Qed.

Theorem jp_saved_cap_early_release_depth_0_through_84_is_selected :
  forall (Slot : Type) (initial bulk : list Slot) (watched slot : Slot)
      depth,
    depth <= 84 ->
    nth_error (free_list_after_early_release initial bulk watched) depth =
      Some slot ->
    jp_free_list_slot_is_selected_for_reuse true
      (free_list_after_early_release initial bulk watched) slot.
Proof.
  intros Slot initial bulk watched slot depth Hdepth Hlookup.
  eapply popped_depth_selects_present_slot_for_reuse; [|exact Hlookup].
  now apply (proj2 (jp_saved_cap_popped_depths_are_exactly_0_through_84 depth)).
Qed.

Theorem jp_saved_cap_early_release_depth_85_or_later_survives :
  forall (Slot : Type) (initial bulk : list Slot) (watched slot : Slot)
      depth,
    85 <= depth ->
    nth_error (free_list_after_early_release initial bulk watched) depth =
      Some slot ->
    jp_free_list_slot_survives true
      (free_list_after_early_release initial bulk watched) slot.
Proof.
  intros Slot initial bulk watched slot depth Hdepth Hlookup.
  eapply surviving_depth_preserves_present_slot; [|exact Hlookup].
  now apply (proj2 (jp_saved_cap_surviving_depths_begin_at_85 depth)).
Qed.

Theorem every_free_list_depth_is_popped_or_survives :
  forall saved_cap depth,
    jp_free_list_depth_is_popped saved_cap depth \/
    jp_free_list_depth_survives saved_cap depth.
Proof.
  intros saved_cap depth.
  unfold jp_free_list_depth_is_popped, jp_free_list_depth_survives.
  lia.
Qed.

Theorem no_free_list_depth_is_both_popped_and_survives :
  forall saved_cap depth,
    ~ (jp_free_list_depth_is_popped saved_cap depth /\
       jp_free_list_depth_survives saved_cap depth).
Proof.
  intros saved_cap depth.
  unfold jp_free_list_depth_is_popped, jp_free_list_depth_survives.
  lia.
Qed.

(** A small concrete LIFO witness refutes the accidental identification of
    numerical pool slot 60 with free-list depth 60.  It uses the existing
    [free_list_after_early_release] definition.  In this valid distinct-slot
    fragment, pool slot 60 occurs at depth 23, while depth 60 names slot 23.
    This is a type/ordering fact only; it is not asserted to be the retail
    Area-2 free list. *)
Definition jp_pool_slot_depth_separation_witness : list nat :=
  free_list_after_early_release [] (seq 0 84) 200.

Theorem pool_slot_60_and_free_list_depth_60_are_not_equivalent :
  nth_error jp_pool_slot_depth_separation_witness 23 = Some 60 /\
  nth_error jp_pool_slot_depth_separation_witness 60 = Some 23 /\
  nth_error jp_pool_slot_depth_separation_witness 60 <> Some 60.
Proof. vm_compute. repeat split; discriminate. Qed.

(** The timing model contains generic observations, not constructors named
    "first" or "second".  First and second occurrence are derived from list
    positions, avoiding a model which assumes its conclusion in an event
    label. *)
Inductive JPFirstApplyObservation : Type :=
| JPObservedArea2PlatformApply
| JPObservedArea2ControllerPoll
| JPObservedOther.

Definition jp_first_occurrence
    (event : JPFirstApplyObservation)
    (observations : list JPFirstApplyObservation)
    (index : nat) : Prop :=
  nth_error observations index = Some event /\
  forall earlier,
    earlier < index ->
    nth_error observations earlier <> Some event.

Definition jp_second_occurrence
    (event : JPFirstApplyObservation)
    (observations : list JPFirstApplyObservation)
    (index : nat) : Prop :=
  exists first,
    first < index /\
    jp_first_occurrence event observations first /\
    nth_error observations index = Some event /\
    (forall between,
      first < between ->
      between < index ->
      nth_error observations between <> Some event).

Record JPCorrectedFirstApplyChronology
    (observations : list JPFirstApplyObservation) : Type := {
  jp_true_first_apply_index : nat;
  jp_first_area2_poll_index : nat;
  jp_next_area2_apply_index : nat;
  jp_true_first_apply_occurrence :
    jp_first_occurrence JPObservedArea2PlatformApply observations
      jp_true_first_apply_index;
  jp_first_area2_poll_occurrence :
    jp_first_occurrence JPObservedArea2ControllerPoll observations
      jp_first_area2_poll_index;
  jp_next_area2_apply_lookup :
    nth_error observations jp_next_area2_apply_index =
      Some JPObservedArea2PlatformApply;
  jp_no_apply_between_first_and_next :
    forall between,
      jp_true_first_apply_index < between ->
      between < jp_next_area2_apply_index ->
      nth_error observations between <>
        Some JPObservedArea2PlatformApply;
  jp_first_apply_before_first_poll :
    jp_true_first_apply_index < jp_first_area2_poll_index;
  jp_first_poll_before_next_apply :
    jp_first_area2_poll_index < jp_next_area2_apply_index
}.

Theorem corrected_next_apply_is_the_second_occurrence :
  forall observations
      (chronology : JPCorrectedFirstApplyChronology observations),
    jp_second_occurrence JPObservedArea2PlatformApply observations
      (jp_next_area2_apply_index observations chronology).
Proof.
  intros observations chronology.
  exists (jp_true_first_apply_index observations chronology).
  split.
  - pose proof (jp_first_apply_before_first_poll observations chronology).
    pose proof (jp_first_poll_before_next_apply observations chronology).
    lia.
  - split.
    + exact (jp_true_first_apply_occurrence observations chronology).
    + split.
      * exact (jp_next_area2_apply_lookup observations chronology).
      * exact (jp_no_apply_between_first_and_next observations chronology).
Qed.

(** The existing instrumentation writes its payload at the first Area-2
    controller/input poll.  The following theorem is deliberately temporal:
    it says the write is too late for the true first apply and precedes the
    next (therefore second) apply.  It does not claim that the payload is
    retail reachable or that the second apply consumes particular bytes. *)
Theorem first_poll_fixture_boundary_is_after_first_apply_before_second :
  forall observations
      (chronology : JPCorrectedFirstApplyChronology observations)
      fixture_write_index,
    fixture_write_index =
      jp_first_area2_poll_index observations chronology ->
    jp_true_first_apply_index observations chronology < fixture_write_index /\
    fixture_write_index <
      jp_next_area2_apply_index observations chronology /\
    jp_second_occurrence JPObservedArea2PlatformApply observations
      (jp_next_area2_apply_index observations chronology).
Proof.
  intros observations chronology fixture_write_index Hwrite.
  subst fixture_write_index.
  repeat split.
  - exact (jp_first_apply_before_first_poll observations chronology).
  - exact (jp_first_poll_before_next_apply observations chronology).
  - exact (corrected_next_apply_is_the_second_occurrence observations chronology).
Qed.

(** Allocation causes label an ordered source census.  The labels themselves
    are not retail facts: the source-projection evidence below must supply the
    concrete allocator entry state for every label, in execution order. *)
Inductive JPPreapplyAllocationCause : Type :=
| JPLoaderAllocation
| JPMarkerBallAllocation
| JPSavedCapAllocation.

Record JPPreapplyAllocationObservation : Type := {
  jp_preapply_allocation_state : Clight.state;
  jp_preapply_allocation_cause : JPPreapplyAllocationCause
}.

Fixpoint jp_count_allocation_cause
    (cause : JPPreapplyAllocationCause)
    (observations : list JPPreapplyAllocationObservation) : nat :=
  match observations with
  | [] => 0
  | observation :: rest =>
      (match cause, jp_preapply_allocation_cause observation with
       | JPLoaderAllocation, JPLoaderAllocation
       | JPMarkerBallAllocation, JPMarkerBallAllocation
       | JPSavedCapAllocation, JPSavedCapAllocation => 1
       | _, _ => 0
       end) + jp_count_allocation_cause cause rest
  end.

Theorem jp_allocation_cause_counts_partition_length :
  forall observations,
    length observations =
      jp_count_allocation_cause JPLoaderAllocation observations +
      jp_count_allocation_cause JPMarkerBallAllocation observations +
      jp_count_allocation_cause JPSavedCapAllocation observations.
Proof.
  induction observations as [|observation rest IH].
  - reflexivity.
  - destruct observation as [allocation_state cause].
    destruct cause; cbn in *; lia.
Qed.

Fixpoint jp_allocation_observations_follow_run
    (run : ImportedClightRun)
    (observations : list JPPreapplyAllocationObservation) : Prop :=
  match observations with
  | first :: ((second :: _) as rest) =>
      (exists trace,
        clight_run_plus run
          (jp_preapply_allocation_state first) trace
          (jp_preapply_allocation_state second)) /\
      jp_allocation_observations_follow_run run rest
  | _ => True
  end.

(** Caller-supplied control-point evidence separates the preload/Area-1 run
    start from the clean Area-2 state projected at the true first destination
    apply.  [initial] is intentionally unconstrained here: the frame
    certificate still pins it to the concrete run start, which may be before
    [warp_area]. *)
Record JPDestinationWarpFirstApplyControlPointEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    : Type := {
  jp_control_destination_warp_boundary_state : Clight.state;
  jp_control_destination_warp_boundary_is_entry :
    clight_state_enters_function
      JPFirstApplyLevel.f_warp_area
      jp_control_destination_warp_boundary_state;
  jp_control_first_apply_state : Clight.state;
  jp_control_destination_warp_to_first_apply_trace : Events.trace;
  jp_control_destination_warp_to_first_apply :
    clight_run_plus run
      jp_control_destination_warp_boundary_state
      jp_control_destination_warp_to_first_apply_trace
      jp_control_first_apply_state;
  jp_control_first_apply_is_platform_entry :
    clight_state_enters_function
      JPFirstApplyPlatform.f_apply_mario_platform_displacement
      jp_control_first_apply_state;
  jp_control_no_platform_entry_between_warp_and_first_apply :
    forall candidate trace_from_warp trace_to_first,
      clight_run_plus run
        jp_control_destination_warp_boundary_state trace_from_warp candidate ->
      clight_run_plus run
        candidate trace_to_first jp_control_first_apply_state ->
      ~ clight_state_enters_function
          JPFirstApplyPlatform.f_apply_mario_platform_displacement candidate;
  jp_control_first_apply_abstract_state : GameState;
  jp_control_first_apply_projection :
    project_state projection jp_control_first_apply_state =
      Some jp_control_first_apply_abstract_state;
  jp_control_first_apply_is_clean_entry :
    CleanPyramidEntry jp_control_first_apply_abstract_state;
  jp_control_first_apply_is_jp :
    state_version jp_control_first_apply_abstract_state = VersionJP;
  jp_control_first_apply_is_upper_entry :
    state_entrance jp_control_first_apply_abstract_state = UpperEntrance
}.

Arguments jp_control_destination_warp_boundary_state
  {projection run initial certificate} _.
Arguments jp_control_first_apply_state
  {projection run initial certificate} _.

(** The remaining source connection is data-bearing evidence, not an axiom.
    Its scope starts at the caller-proved destination [warp_area] entry,
    rather than [run_start].  Consequently its exact allocation census cannot
    be polluted by arbitrary earlier Area-1 allocator calls.

    The first-poll clause independently excludes a controller poll strictly
    between the destination-scoped first apply and the selected poll. *)
Record JPFirstApplySourceProjectionEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (control :
      JPDestinationWarpFirstApplyControlPointEvidence
        projection run initial certificate)
    (saved_cap : bool) : Type := {
  jp_source_first_poll_state : Clight.state;
  jp_source_next_apply_state : Clight.state;
  jp_source_first_apply_to_poll_trace : Events.trace;
  jp_source_poll_to_next_apply_trace : Events.trace;
  jp_source_first_apply_to_poll :
    clight_run_plus run
      (jp_control_first_apply_state control)
      jp_source_first_apply_to_poll_trace
      jp_source_first_poll_state;
  jp_source_poll_is_controller_entry :
    clight_state_enters_function
      JPFirstApplyGameInit.f_read_controller_inputs
      jp_source_first_poll_state;
  jp_source_no_controller_poll_between_first_apply_and_poll :
    forall candidate trace_from_apply trace_to_poll,
      clight_run_plus run
        (jp_control_first_apply_state control) trace_from_apply candidate ->
      clight_run_plus run
        candidate trace_to_poll jp_source_first_poll_state ->
      ~ clight_state_enters_function
          JPFirstApplyGameInit.f_read_controller_inputs candidate;
  jp_source_poll_to_next_apply :
    clight_run_plus run
      jp_source_first_poll_state jp_source_poll_to_next_apply_trace
      jp_source_next_apply_state;
  jp_source_next_apply_is_platform_entry :
    clight_state_enters_function
      JPFirstApplyPlatform.f_apply_mario_platform_displacement
      jp_source_next_apply_state;
  jp_source_no_intervening_platform_entry :
    forall candidate trace_from_first trace_to_next,
      clight_run_plus run
        (jp_control_first_apply_state control) trace_from_first candidate ->
      clight_run_plus run
        candidate trace_to_next jp_source_next_apply_state ->
      ~ clight_state_enters_function
          JPFirstApplyPlatform.f_apply_mario_platform_displacement candidate;
  jp_source_preapply_allocations : list JPPreapplyAllocationObservation;
  jp_source_loader_count :
    jp_count_allocation_cause
      JPLoaderAllocation jp_source_preapply_allocations =
      jp_loader_fresh_allocations;
  jp_source_marker_ball_count :
    jp_count_allocation_cause
      JPMarkerBallAllocation jp_source_preapply_allocations =
      jp_marker_ball_fresh_allocations;
  jp_source_saved_cap_count :
    jp_count_allocation_cause
      JPSavedCapAllocation jp_source_preapply_allocations =
      jp_saved_cap_fresh_allocations saved_cap;
  jp_source_allocation_states_are_distinct :
    NoDup
      (map jp_preapply_allocation_state jp_source_preapply_allocations);
  jp_source_allocation_census_is_execution_ordered :
    jp_allocation_observations_follow_run
      run jp_source_preapply_allocations;
  jp_source_listed_allocations_are_preapply_entries :
    forall observation,
      In observation jp_source_preapply_allocations ->
      clight_state_enters_function
        JPFirstApplySpawn.f_allocate_object
        (jp_preapply_allocation_state observation) /\
      exists trace_from_warp trace_to_first,
        clight_run_plus run
          (jp_control_destination_warp_boundary_state control) trace_from_warp
          (jp_preapply_allocation_state observation) /\
        clight_run_plus run
          (jp_preapply_allocation_state observation) trace_to_first
          (jp_control_first_apply_state control);
  jp_source_every_preapply_allocation_is_listed :
    forall allocation_state trace_from_warp trace_to_first,
      clight_run_plus run
        (jp_control_destination_warp_boundary_state control) trace_from_warp
        allocation_state ->
      clight_run_plus run allocation_state trace_to_first
        (jp_control_first_apply_state control) ->
      clight_state_enters_function
        JPFirstApplySpawn.f_allocate_object allocation_state ->
      exists observation,
        In observation jp_source_preapply_allocations /\
        jp_preapply_allocation_state observation = allocation_state
}.

Theorem projected_preapply_allocation_census_has_exact_length :
  forall projection run initial certificate control saved_cap
      (evidence :
        JPFirstApplySourceProjectionEvidence
          projection run initial certificate control saved_cap),
    length
      (jp_source_preapply_allocations
        projection run initial certificate control saved_cap evidence) =
    jp_pre_true_first_apply_fresh_allocations saved_cap.
Proof.
  intros projection run initial certificate control saved_cap evidence.
  rewrite jp_allocation_cause_counts_partition_length.
  rewrite
    (jp_source_loader_count
      projection run initial certificate control saved_cap evidence),
    (jp_source_marker_ball_count
      projection run initial certificate control saved_cap evidence),
    (jp_source_saved_cap_count
      projection run initial certificate control saved_cap evidence).
  reflexivity.
Qed.

(** This is the named pending theorem shape.  Inhabiting it must extract the
    chronology and allocation census from the selected generated JP program;
    no constructor or proof is supplied in this file. *)
Definition JPFirstApplySourceProjectionObligation
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (control :
      JPDestinationWarpFirstApplyControlPointEvidence
        projection run initial certificate) : Type :=
  RunUsesProjection projection run ->
  { saved_cap : bool &
    JPFirstApplySourceProjectionEvidence
      projection run initial certificate control saved_cap }.
