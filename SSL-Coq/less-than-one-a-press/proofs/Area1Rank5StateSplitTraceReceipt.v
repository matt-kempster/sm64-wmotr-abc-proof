(** Finite original-JP receipt for Rank 5 and Rank 5A.

    A ROM-hash-gated, read-only debugger trace follows the already checked
    zero-A four-pillar execution from timer 348 through timer 2809.  Unlike
    the earlier controller-boundary samples, this audit observes the
    intra-frame chronology: cached-platform apply, collision, Mario's
    State-to-Object copy, the whole post-copy tail, final platform selection,
    and the next frame's pre-apply prefix.

    Every protected CPU store is watched.  The receipt therefore covers
    reached direct and indirect callbacks, retail outside callees, aliases,
    and lifecycle code on this execution without assuming their source-level
    destination.  This remains a finite machine-trace theorem, not a theorem
    about every controller history, an IDO-to-Clight simulation, or execution
    after undefined behavior. *)

From Coq Require Import List ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1PostCopyTailClassification Area1PrecollisionWriterClosure
  Area1Rank1UpperWarpTraceReceipt.

Import ListNotations.
Local Open Scope Z_scope.

(** * Exact interval and phase totals *)

Definition jp_rank5_trace_start_timer : Z := 348.
Definition jp_rank5_trace_exclusive_end_timer : Z := 2810.
Definition jp_rank5_trace_frames : Z := 2462.
Definition jp_rank5_frames_started : Z := 2462.
Definition jp_rank5_frames_finished : Z := 2462.

Definition jp_rank5_apply_entries : Z := 2462.
Definition jp_rank5_apply_returns : Z := 2462.
Definition jp_rank5_collision_entries : Z := 2462.
Definition jp_rank5_collision_returns : Z := 2462.
Definition jp_rank5_copy_returns : Z := 2462.
Definition jp_rank5_bhv_mario_returns : Z := 2462.
Definition jp_rank5_post_nonterrain_checks : Z := 2462.
Definition jp_rank5_post_unload_checks : Z := 2462.
Definition jp_rank5_post_final_query_checks : Z := 2462.

(** * Identity and synchronized-view checks *)

Definition jp_rank5_order_failures : Z := 0.
Definition jp_rank5_identity_failures : Z := 0.
Definition jp_rank5_identity_writes : Z := 0.
Definition jp_rank5_behavior_or_dispatch_writes : Z := 0.
Definition jp_rank5_entry_state_object_mismatches : Z := 0.
Definition jp_rank5_apply_entry_state_object_mismatches : Z := 0.
Definition jp_rank5_post_apply_state_object_mismatches : Z := 0.
Definition jp_rank5_collision_state_object_mismatches : Z := 0.
Definition jp_rank5_copy_receiver_failures : Z := 0.
Definition jp_rank5_copy_state_object_mismatches : Z := 0.
Definition jp_rank5_postcopy_tail_mismatches : Z := 0.
Definition jp_rank5_write_decode_failures : Z := 0.

(** * Rank-5 post-copy and between-frame writer window *)

Definition jp_rank5_preapply_state_writes : Z := 0.
Definition jp_rank5_preapply_object_writes : Z := 0.
Definition jp_rank5_postcopy_state_writes : Z := 0.
Definition jp_rank5_postcopy_object_writes : Z := 0.

(** * Rank-5A cached-platform apply window *)

Definition jp_rank5_apply_helper_calls : Z := 0.
Definition jp_rank5_nonnull_apply_entries : Z := 0.
Definition jp_rank5_invalid_apply_owners : Z := 0.
Definition jp_rank5_apply_state_changes : Z := 0.
Definition jp_rank5_apply_object_changes : Z := 0.
Definition jp_rank5_apply_graphics_changes : Z := 0.
Definition jp_rank5_apply_state_writes : Z := 0.
Definition jp_rank5_apply_object_writes : Z := 0.
Definition jp_rank5_apply_graphics_writes : Z := 0.
Definition jp_rank5_precollision_object_changes : Z := 0.

(** Protected-coordinate stores after the apply call has returned and through
    the return from [detect_object_collisions].  These counters are separate
    from both the stores made inside the platform-apply body and the later
    post-copy writer window: endpoint equality alone would not exclude a
    transient split that was repaired before collision detection returned. *)
Definition jp_rank5_postapply_state_writes : Z := 0.
Definition jp_rank5_postapply_object_writes : Z := 0.
Definition jp_rank5_postapply_graphics_writes : Z := 0.

Definition jp_rank5_global_platform_writes : Z := 2462.
Definition jp_rank5_object_platform_writes : Z := 2462.
Definition jp_rank5_nonnull_platform_writes : Z := 0.
Definition jp_rank5_unexpected_platform_writes : Z := 0.

(** The four authenticated writer/count pairs are, respectively, the
    ownerless global and Object clears followed by the distance-failure
    global and Object clears.  No owner-store PC occurs. *)
Definition jp_rank5_platform_writer_counts : list (Z * Z) :=
  [(2150400072, 2130); (2150400084, 2130);
   (2150399980, 332); (2150399992, 332)].

(** * Exact upper-warp apply samples *)

Definition jp_rank5_upper_warp_apply_timers : list Z :=
  [2807; 2808; 2809].
Definition jp_rank5_upper_warp_apply_entries : Z := 3.
Definition jp_rank5_upper_warp_nonnull_entries : Z := 0.
Definition jp_rank5_upper_warp_state_changes : Z := 0.
Definition jp_rank5_upper_warp_platform_values : list Z := [0; 0; 0].
Definition jp_rank5_upper_warp_time_stop_values : list Z := [0; 0; 0].

(** Unsigned binary32 words for
    [(-2033.87939453125, 768, -1037.05859375)].  State, raw Object, and
    Graphics have this same triple at all three apply entries. *)
Definition jp_rank5_upper_warp_xyz_bits : list Z :=
  [3304995876; 1145044992; 3296829920].
Definition jp_rank5_upper_warp_state_samples : list (list Z) :=
  repeat jp_rank5_upper_warp_xyz_bits 3.
Definition jp_rank5_upper_warp_object_samples : list (list Z) :=
  repeat jp_rank5_upper_warp_xyz_bits 3.
Definition jp_rank5_upper_warp_graphics_samples : list (list Z) :=
  repeat jp_rank5_upper_warp_xyz_bits 3.

Record JPRank5StateSplitTraceReceipt : Prop := {
  jp_rank5_receipt_interval :
    jp_rank5_trace_exclusive_end_timer - jp_rank5_trace_start_timer =
      jp_rank5_trace_frames;
  jp_rank5_receipt_all_phases_reached_once_per_frame :
    jp_rank5_frames_started = jp_rank5_trace_frames /\
    jp_rank5_frames_finished = jp_rank5_trace_frames /\
    jp_rank5_apply_entries = jp_rank5_trace_frames /\
    jp_rank5_apply_returns = jp_rank5_trace_frames /\
    jp_rank5_collision_entries = jp_rank5_trace_frames /\
    jp_rank5_collision_returns = jp_rank5_trace_frames /\
    jp_rank5_copy_returns = jp_rank5_trace_frames /\
    jp_rank5_bhv_mario_returns = jp_rank5_trace_frames /\
    jp_rank5_post_nonterrain_checks = jp_rank5_trace_frames /\
    jp_rank5_post_unload_checks = jp_rank5_trace_frames /\
    jp_rank5_post_final_query_checks = jp_rank5_trace_frames;
  jp_rank5_receipt_identity_and_order_intact :
    jp_rank5_order_failures = 0 /\
    jp_rank5_identity_failures = 0 /\
    jp_rank5_identity_writes = 0 /\
    jp_rank5_behavior_or_dispatch_writes = 0 /\
    jp_rank5_write_decode_failures = 0;
  jp_rank5_receipt_every_checked_view_is_synchronized :
    jp_rank5_entry_state_object_mismatches = 0 /\
    jp_rank5_apply_entry_state_object_mismatches = 0 /\
    jp_rank5_post_apply_state_object_mismatches = 0 /\
    jp_rank5_collision_state_object_mismatches = 0 /\
    jp_rank5_copy_receiver_failures = 0 /\
    jp_rank5_copy_state_object_mismatches = 0 /\
    jp_rank5_postcopy_tail_mismatches = 0;
  jp_rank5_receipt_postcopy_and_preapply_windows_have_no_writer :
    jp_rank5_preapply_state_writes = 0 /\
    jp_rank5_preapply_object_writes = 0 /\
    jp_rank5_postcopy_state_writes = 0 /\
    jp_rank5_postcopy_object_writes = 0;
  jp_rank5_receipt_platform_apply_is_ineffective :
    jp_rank5_apply_helper_calls = 0 /\
    jp_rank5_nonnull_apply_entries = 0 /\
    jp_rank5_invalid_apply_owners = 0 /\
    jp_rank5_apply_state_changes = 0 /\
    jp_rank5_apply_object_changes = 0 /\
    jp_rank5_apply_graphics_changes = 0 /\
    jp_rank5_apply_state_writes = 0 /\
    jp_rank5_apply_object_writes = 0 /\
    jp_rank5_apply_graphics_writes = 0 /\
    jp_rank5_precollision_object_changes = 0;
  jp_rank5_receipt_apply_return_through_collision_has_no_protected_writer :
    jp_rank5_postapply_state_writes = 0 /\
    jp_rank5_postapply_object_writes = 0 /\
    jp_rank5_postapply_graphics_writes = 0;
  jp_rank5_receipt_platform_cells_receive_only_checked_nulls :
    jp_rank5_global_platform_writes = jp_rank5_trace_frames /\
    jp_rank5_object_platform_writes = jp_rank5_trace_frames /\
    jp_rank5_nonnull_platform_writes = 0 /\
    jp_rank5_unexpected_platform_writes = 0 /\
    jp_rank5_platform_writer_counts =
      [(2150400072, 2130); (2150400084, 2130);
       (2150399980, 332); (2150399992, 332)];
  jp_rank5_receipt_upper_warp_apply_is_null_and_synchronized :
    jp_rank5_upper_warp_apply_timers = [2807; 2808; 2809] /\
    jp_rank5_upper_warp_apply_entries = 3 /\
    jp_rank5_upper_warp_nonnull_entries = 0 /\
    jp_rank5_upper_warp_state_changes = 0 /\
    jp_rank5_upper_warp_platform_values = [0; 0; 0] /\
    jp_rank5_upper_warp_time_stop_values = [0; 0; 0] /\
    jp_rank5_upper_warp_state_samples =
      repeat [3304995876; 1145044992; 3296829920] 3 /\
    jp_rank5_upper_warp_object_samples =
      jp_rank5_upper_warp_state_samples /\
    jp_rank5_upper_warp_graphics_samples =
      jp_rank5_upper_warp_state_samples
}.

Theorem jp_rank5_state_split_trace_receipt_checked :
  JPRank5StateSplitTraceReceipt.
Proof.
  constructor; cbv; repeat split; reflexivity.
Qed.

(** Rank 5 is absent on this trace: after every successful copy, no watched
    State or raw-Object coordinate store occurs in the remaining tail or the
    next pre-apply prefix, while receiver identity and bitwise synchronization
    survive at every checked boundary. *)
Definition JPRank5PostCopyTraceEscapesAbsent : Prop :=
  jp_rank5_order_failures = 0 /\
  jp_rank5_identity_failures = 0 /\
  jp_rank5_identity_writes = 0 /\
  jp_rank5_behavior_or_dispatch_writes = 0 /\
  jp_rank5_write_decode_failures = 0 /\
  jp_rank5_copy_receiver_failures = 0 /\
  jp_rank5_copy_state_object_mismatches = 0 /\
  jp_rank5_preapply_state_writes = 0 /\
  jp_rank5_preapply_object_writes = 0 /\
  jp_rank5_postcopy_state_writes = 0 /\
  jp_rank5_postcopy_object_writes = 0 /\
  jp_rank5_postcopy_tail_mismatches = 0.

Theorem jp_rank5_postcopy_trace_escapes_absent :
  JPRank5PostCopyTraceEscapesAbsent.
Proof.
  unfold JPRank5PostCopyTraceEscapesAbsent.
  cbv; repeat split; reflexivity.
Qed.

(** Rank 5A is absent on this trace: every final-query platform write is a
    checked null from one of the four authenticated clear stores, every apply
    loads null, the displacement helper is never reached, and collision sees
    no split.  The already-proved conditional platform effect is not denied;
    this receipt disproves its origin on this particular clean execution. *)
Definition JPRank5APrecollisionTraceEscapesAbsent : Prop :=
  jp_rank5_write_decode_failures = 0 /\
  jp_rank5_nonnull_platform_writes = 0 /\
  jp_rank5_unexpected_platform_writes = 0 /\
  jp_rank5_nonnull_apply_entries = 0 /\
  jp_rank5_apply_helper_calls = 0 /\
  jp_rank5_apply_state_changes = 0 /\
  jp_rank5_apply_object_changes = 0 /\
  jp_rank5_apply_graphics_changes = 0 /\
  jp_rank5_apply_state_writes = 0 /\
  jp_rank5_apply_object_writes = 0 /\
  jp_rank5_apply_graphics_writes = 0 /\
  jp_rank5_postapply_state_writes = 0 /\
  jp_rank5_postapply_object_writes = 0 /\
  jp_rank5_postapply_graphics_writes = 0 /\
  jp_rank5_apply_entry_state_object_mismatches = 0 /\
  jp_rank5_post_apply_state_object_mismatches = 0 /\
  jp_rank5_collision_state_object_mismatches = 0 /\
  jp_rank5_precollision_object_changes = 0 /\
  jp_rank5_upper_warp_nonnull_entries = 0 /\
  jp_rank5_upper_warp_state_changes = 0.

Theorem jp_rank5a_precollision_trace_escapes_absent :
  JPRank5APrecollisionTraceEscapesAbsent.
Proof.
  unfold JPRank5APrecollisionTraceEscapesAbsent.
  cbv; repeat split; reflexivity.
Qed.

(** No protected coordinate store is merely hidden between the two
    synchronized collision checkpoints.  Keeping this as a named consequence
    prevents the trace verdict from being weakened to endpoint sampling. *)
Definition JPRank5PostApplyCollisionTraceWritesAbsent : Prop :=
  jp_rank5_postapply_state_writes = 0 /\
  jp_rank5_postapply_object_writes = 0 /\
  jp_rank5_postapply_graphics_writes = 0.

Theorem jp_rank5_postapply_collision_trace_writes_absent :
  JPRank5PostApplyCollisionTraceWritesAbsent.
Proof.
  unfold JPRank5PostApplyCollisionTraceWritesAbsent.
  cbv; repeat split; reflexivity.
Qed.

(** Source classifications and the route-matched machine facts are kept as
    separate conjuncts: combining them does not silently turn the one trace
    into a universal Clight or controller-history theorem. *)
Definition Area1Rank5StateSplitTraceCheckedBoundary : Prop :=
  (@Area1PostCopyTailClassificationCheckedBoundary
    (Z * Z * Z)%type Z) /\
  Area1PrecollisionWriterSourceBoundary /\
  JPRank1UpperWarpTraceReceipt /\
  JPRank5StateSplitTraceReceipt /\
  JPRank5PostCopyTraceEscapesAbsent /\
  JPRank5APrecollisionTraceEscapesAbsent /\
  JPRank5PostApplyCollisionTraceWritesAbsent.

Theorem area1_rank5_state_split_trace_checked_boundary_holds :
  Area1Rank5StateSplitTraceCheckedBoundary.
Proof.
  unfold Area1Rank5StateSplitTraceCheckedBoundary.
  split; [exact (@area1_postcopy_tail_classification_checked_boundary_holds
    (Z * Z * Z)%type Z) |].
  split; [exact area1_precollision_writer_source_boundary_checked |].
  split; [exact jp_rank1_upper_warp_trace_receipt_checked |].
  split; [exact jp_rank5_state_split_trace_receipt_checked |].
  split; [exact jp_rank5_postcopy_trace_escapes_absent |].
  split; [exact jp_rank5a_precollision_trace_escapes_absent |].
  exact jp_rank5_postapply_collision_trace_writes_absent.
Qed.
