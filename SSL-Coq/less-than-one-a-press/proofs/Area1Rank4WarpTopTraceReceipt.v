(** Finite original-JP receipt for Rank 4: relocate the upper warp/top or
    create a collision-preserving top clone.

    The ROM-hash-gated, read-only machine trace uses the already-checked
    zero-A four-pillar controller schedule.  It fixes the canonical top and
    node-1E upper-warp identities at timer 348, scans all 240 object slots on
    every frame through timer 2809, watches the canonical identity/position
    cells through both MIPS RAM aliases, and checks the owner and pose at
    every actual top-collision load.

    This is deliberately a finite trace theorem.  It combines with the
    generated-source census in [Area1WarpTopCloneCensus], but it is not a
    universal reachability induction or an IDO-MIPS-to-Clight simulation. *)

From Coq Require Import Lia List ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1Rank1UpperWarpTraceReceipt Area1WarpTopCloneCensus.

Import ListNotations.
Local Open Scope Z_scope.

(** * Complementary generated-source boundary *)

Definition JPRank4StockSourceCensus : Prop :=
  internal_body_mentioning_ids CJBD._ssl_seg7_collision_pyramid_top
    jp_source_definitions = [] /\
  initializer_addrof_owner_ids CJBD._ssl_seg7_collision_pyramid_top
    jp_source_definitions = [CJBD._bhvPyramidTop] /\
  internal_body_mentioning_ids CJBD._bhvPyramidTop
    jp_source_definitions = [] /\
  initializer_addrof_owner_ids CJBD._bhvPyramidTop
    jp_source_definitions = [CJSS._script_func_local_1] /\
  internal_body_mentioning_ids CJBD._bhvWarp
    jp_source_definitions = [] /\
  initializer_addrof_owner_ids CJBD._bhvWarp
    jp_source_definitions = [CJA._sWarpBhvSpawnTable; CJSS._level_ssl_entry] /\
  internal_object_field_assignment_sites
    CJSO._Object CJSO._collisionData jp_source_definitions =
      expected_jp_collision_data_writers.

Theorem jp_rank4_stock_source_census_checked :
  JPRank4StockSourceCensus.
Proof.
  unfold JPRank4StockSourceCensus.
  destruct jp_top_static_reference_census as
    [Hmesh_body [Hmesh_initializer [Htop_body Htop_initializer]]].
  destruct jp_warp_static_reference_census as
    [Hwarp_body Hwarp_initializer].
  repeat split; try assumption.
Qed.

(** * Exact endpoint identities and interval *)

Definition jp_rank4_trace_start_timer : Z := 348.
Definition jp_rank4_trace_exclusive_end_timer : Z := 2810.
Definition jp_rank4_trace_frames : Z := 2462.
Definition jp_rank4_trace_frame_failures : Z := 0.

Definition jp_rank4_top_address : Z := 2150912504.
Definition jp_rank4_top_slot : Z := 61.
Definition jp_rank4_top_behavior : Z := 2148449972.
Definition jp_rank4_top_collision : Z := 2148575956.
Definition jp_rank4_upper_warp_address : Z := 2150914328.
Definition jp_rank4_upper_warp_slot : Z := 64.
Definition jp_rank4_upper_warp_behavior : Z := 2148436640.
Definition jp_rank4_upper_warp_collision : Z := 0.
Definition jp_rank4_upper_warp_x : Z := -2048.
Definition jp_rank4_upper_warp_y : Z := 768.
Definition jp_rank4_upper_warp_z : Z := -1024.

(** * Whole-pool census and lifecycle totals *)

Definition jp_rank4_top_active_frames : Z := 2353.
Definition jp_rank4_top_absent_frames : Z := 109.
Definition jp_rank4_warp_active_frames : Z := 2462.
Definition jp_rank4_top_behavior_maximum : Z := 1.
Definition jp_rank4_top_collision_maximum : Z := 1.
Definition jp_rank4_upper_warp_maximum : Z := 1.
Definition jp_rank4_top_resurrections : Z := 0.

Definition jp_rank4_top_position_writes : Z := 436.
Definition jp_rank4_live_top_position_writes : Z := 302.
Definition jp_rank4_retired_slot_position_writes : Z := 134.
Definition jp_rank4_top_identity_writes : Z := 6.
Definition jp_rank4_live_top_identity_writes : Z := 0.
Definition jp_rank4_retired_slot_identity_writes : Z := 6.

Definition jp_rank4_retired_slot_reuse_timers : list Z :=
  [2712; 2743; 2775].
Definition jp_rank4_collision_clear_writer : Z := 2150404716.
Definition jp_rank4_behavior_install_writer : Z := 2150405304.
Definition jp_rank4_replacement_behaviors : list Z :=
  [2148436732; 2148438364; 2148438228].

(** * Installed collision and pose checks *)

Definition jp_rank4_top_collision_load_calls : Z := 2353.
Definition jp_rank4_bad_top_collision_load_calls : Z := 0.
Definition jp_rank4_upper_warp_collision_load_calls : Z := 0.
Definition jp_rank4_warp_position_writes : Z := 0.
Definition jp_rank4_warp_collision_writes : Z := 0.
Definition jp_rank4_warp_identity_writes : Z := 0.

Definition jp_rank4_top_min_x : Z := -2087.
Definition jp_rank4_top_max_x : Z := -2007.
Definition jp_rank4_top_min_y : Z := 1536.
(** The printed binary32 maximum is 1878.07104; this lower integer upper
    bound is sufficient to prove it remains below the warp-independent
    cutoff 1879 used by the source-shaped motion theorem. *)
Definition jp_rank4_top_max_y_integer_ceiling : Z := 1879.
Definition jp_rank4_top_min_z : Z := -1023.
Definition jp_rank4_top_max_z : Z := -1023.

Record JPRank4WarpTopTraceReceipt : Prop := {
  jp_rank4_receipt_interval :
    jp_rank4_trace_exclusive_end_timer - jp_rank4_trace_start_timer =
      jp_rank4_trace_frames;
  jp_rank4_receipt_canonical_identities :
    jp_rank4_top_address = 2150912504 /\
    jp_rank4_top_slot = 61 /\
    jp_rank4_top_behavior = 2148449972 /\
    jp_rank4_top_collision = 2148575956 /\
    jp_rank4_upper_warp_address = 2150914328 /\
    jp_rank4_upper_warp_slot = 64 /\
    jp_rank4_upper_warp_behavior = 2148436640 /\
    jp_rank4_upper_warp_collision = 0 /\
    jp_rank4_upper_warp_x = -2048 /\
    jp_rank4_upper_warp_y = 768 /\
    jp_rank4_upper_warp_z = -1024;
  jp_rank4_receipt_frame_census :
    jp_rank4_trace_frames = 2462 /\
    jp_rank4_trace_frame_failures = 0 /\
    jp_rank4_top_behavior_maximum = 1 /\
    jp_rank4_top_collision_maximum = 1 /\
    jp_rank4_upper_warp_maximum = 1;
  jp_rank4_receipt_lifetimes_partition_interval :
    jp_rank4_top_active_frames + jp_rank4_top_absent_frames =
      jp_rank4_trace_frames /\
    jp_rank4_warp_active_frames = jp_rank4_trace_frames /\
    jp_rank4_top_resurrections = 0;
  jp_rank4_receipt_live_and_retired_writes_partition :
    jp_rank4_top_position_writes =
      jp_rank4_live_top_position_writes +
        jp_rank4_retired_slot_position_writes /\
    jp_rank4_top_identity_writes =
      jp_rank4_live_top_identity_writes +
        jp_rank4_retired_slot_identity_writes /\
    jp_rank4_live_top_identity_writes = 0;
  jp_rank4_receipt_reuse_is_collision_clear_then_new_behavior :
    jp_rank4_retired_slot_reuse_timers = [2712; 2743; 2775] /\
    jp_rank4_collision_clear_writer = 2150404716 /\
    jp_rank4_behavior_install_writer = 2150405304 /\
    jp_rank4_replacement_behaviors =
      [2148436732; 2148438364; 2148438228] /\
    jp_rank4_retired_slot_identity_writes = 6;
  jp_rank4_receipt_every_top_load_has_canonical_owner_and_pose :
    jp_rank4_top_collision_load_calls =
      jp_rank4_top_active_frames /\
    jp_rank4_bad_top_collision_load_calls = 0;
  jp_rank4_receipt_warp_is_fixed_and_nonstandable :
    jp_rank4_upper_warp_collision_load_calls = 0 /\
    jp_rank4_warp_position_writes = 0 /\
    jp_rank4_warp_collision_writes = 0 /\
    jp_rank4_warp_identity_writes = 0;
  jp_rank4_receipt_top_envelope :
    jp_rank4_top_min_x = -2087 /\
    jp_rank4_top_max_x = -2007 /\
    jp_rank4_top_min_y = 1536 /\
    jp_rank4_top_max_y_integer_ceiling = 1879 /\
    jp_rank4_top_min_z = -1023 /\
    jp_rank4_top_max_z = -1023
}.

Theorem jp_rank4_warp_top_trace_receipt_checked :
  JPRank4WarpTopTraceReceipt.
Proof.
  constructor; unfold jp_rank4_trace_start_timer,
    jp_rank4_trace_exclusive_end_timer, jp_rank4_trace_frames,
    jp_rank4_trace_frame_failures, jp_rank4_top_address,
    jp_rank4_top_slot, jp_rank4_top_behavior, jp_rank4_top_collision,
    jp_rank4_upper_warp_address, jp_rank4_upper_warp_slot,
    jp_rank4_upper_warp_behavior, jp_rank4_upper_warp_collision,
    jp_rank4_upper_warp_x, jp_rank4_upper_warp_y,
    jp_rank4_upper_warp_z, jp_rank4_top_active_frames,
    jp_rank4_top_absent_frames, jp_rank4_warp_active_frames,
    jp_rank4_top_behavior_maximum, jp_rank4_top_collision_maximum,
    jp_rank4_upper_warp_maximum, jp_rank4_top_resurrections,
    jp_rank4_top_position_writes, jp_rank4_live_top_position_writes,
    jp_rank4_retired_slot_position_writes, jp_rank4_top_identity_writes,
    jp_rank4_live_top_identity_writes,
    jp_rank4_retired_slot_identity_writes,
    jp_rank4_retired_slot_reuse_timers,
    jp_rank4_collision_clear_writer, jp_rank4_behavior_install_writer,
    jp_rank4_replacement_behaviors, jp_rank4_top_collision_load_calls,
    jp_rank4_bad_top_collision_load_calls,
    jp_rank4_upper_warp_collision_load_calls,
    jp_rank4_warp_position_writes, jp_rank4_warp_collision_writes,
    jp_rank4_warp_identity_writes, jp_rank4_top_min_x,
    jp_rank4_top_max_x, jp_rank4_top_min_y,
    jp_rank4_top_max_y_integer_ceiling, jp_rank4_top_min_z,
    jp_rank4_top_max_z;
    cbn; repeat split; try reflexivity; lia.
Qed.

(** A trace witness would be a duplicate top identity/collision owner, a
    resurrected top, a bad owner or pose at top-mesh installation, a warp
    position/identity/collision write, or an attempt by the warp to install
    moving collision.  Every listed counter is zero or has maximum one. *)
Definition JPRank4WarpTopTraceEscapesAbsent : Prop :=
  jp_rank4_trace_frame_failures = 0 /\
  jp_rank4_top_behavior_maximum = 1 /\
  jp_rank4_top_collision_maximum = 1 /\
  jp_rank4_upper_warp_maximum = 1 /\
  jp_rank4_top_resurrections = 0 /\
  jp_rank4_live_top_identity_writes = 0 /\
  jp_rank4_bad_top_collision_load_calls = 0 /\
  jp_rank4_upper_warp_collision_load_calls = 0 /\
  jp_rank4_warp_position_writes = 0 /\
  jp_rank4_warp_collision_writes = 0 /\
  jp_rank4_warp_identity_writes = 0.

Theorem jp_rank4_warp_top_trace_escapes_absent :
  JPRank4WarpTopTraceEscapesAbsent.
Proof.
  unfold JPRank4WarpTopTraceEscapesAbsent,
    jp_rank4_trace_frame_failures, jp_rank4_top_behavior_maximum,
    jp_rank4_top_collision_maximum, jp_rank4_upper_warp_maximum,
    jp_rank4_top_resurrections, jp_rank4_live_top_identity_writes,
    jp_rank4_bad_top_collision_load_calls,
    jp_rank4_upper_warp_collision_load_calls,
    jp_rank4_warp_position_writes, jp_rank4_warp_collision_writes,
    jp_rank4_warp_identity_writes.
  repeat split; reflexivity.
Qed.

(** The route receipt is the same uninterrupted zero-A upper-warp execution,
    so the Rank-4 identity/collision checks and the earlier complete
    floor-query/lifecycle checks can be consumed together. *)
Definition Area1Rank4WarpTopTraceCheckedBoundary : Prop :=
  JPRank4StockSourceCensus /\
  JPRank1UpperWarpTraceReceipt /\
  JPRank4WarpTopTraceReceipt /\
  JPRank4WarpTopTraceEscapesAbsent.

Theorem area1_rank4_warp_top_trace_checked_boundary_holds :
  Area1Rank4WarpTopTraceCheckedBoundary.
Proof.
  unfold Area1Rank4WarpTopTraceCheckedBoundary.
  split; [exact jp_rank4_stock_source_census_checked |].
  split; [exact jp_rank1_upper_warp_trace_receipt_checked |].
  split; [exact jp_rank4_warp_top_trace_receipt_checked |].
  exact jp_rank4_warp_top_trace_escapes_absent.
Qed.
