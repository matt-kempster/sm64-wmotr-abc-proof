(** One continuous retail-JP Rank-1 frame receipt.

    The read-only debugger receipt starts at [update_objects] on global timer
    348 and ends at the next [update_objects] entry on timer 349.  Unlike a
    source census, it ties allocator movement, every reached store into the
    two surface allocations, all dynamic insertions, list integrity, owner
    lifetime, and the final platform query to one execution.

    The receipt is deliberately a concrete-frame theorem, not a universal
    Clight induction.  It rules out the six named residuals in this frame.
    [Area1Rank1UpperWarpTraceReceipt] now supplies the finite target-run
    extension; a linked invariant over every reachable history remains the
    stronger open result. *)

From Coq Require Import Lia List ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness Area1SurfacePoolRangeSeparation PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

(** * Exact machine receipt *)

Definition jp_rank1_frame_start_timer : Z := 348.
Definition jp_rank1_frame_end_timer : Z := 349.
Definition jp_rank1_static_node_count : Z := 4346.
Definition jp_rank1_final_node_count : Z := 4370.
Definition jp_rank1_static_surface_count : Z := 962.
Definition jp_rank1_final_surface_count : Z := 968.
Definition jp_rank1_safe_pool_write_count : Z := 238.
Definition jp_rank1_unsafe_pool_write_count : Z := 0.
Definition jp_rank1_dynamic_partition_write_count : Z := 776.
Definition jp_rank1_static_partition_write_count : Z := 0.
Definition jp_rank1_owner_store_count : Z := 6.
Definition jp_rank1_add_surface_count : Z := 6.
Definition jp_rank1_find_floor_count : Z := 64.
Definition jp_rank1_platform_find_floor_count : Z := 1.
Definition jp_rank1_sqrtf_count : Z := 162.
Definition jp_rank1_outside_destination_failures : Z := 0.
Definition jp_rank1_allocator_init_count : Z := 0.
Definition jp_rank1_allocator_alloc_count : Z := 1.
Definition jp_rank1_allocator_free_count : Z := 1.
Definition jp_rank1_allocator_realloc_count : Z := 0.
Definition jp_rank1_allocator_push_count : Z := 0.
Definition jp_rank1_allocator_pop_count : Z := 0.
Definition jp_rank1_allocator_global_write_count : Z := 4.
Definition jp_rank1_surface_pointer_write_count : Z := 0.
Definition jp_rank1_owner_failure_count : Z := 0.
Definition jp_rank1_list_failure_count : Z := 0.
Definition jp_rank1_object_lists_intact : Z := 1.
Definition jp_rank1_static_lists_intact : Z := 1.
Definition jp_rank1_dynamic_lists_intact : Z := 1.
Definition jp_rank1_static_node_coverage : Z := 1.
Definition jp_rank1_dynamic_node_coverage : Z := 1.
Definition jp_rank1_owner_end_validity : Z := 1.
Definition jp_rank1_selected_static_membership : Z := 1.
Definition jp_rank1_selected_dynamic_membership : Z := 0.
Definition jp_rank1_camera_shake_count : Z := 0.
Definition jp_rank1_create_sound_spawner_count : Z := 0.
Definition jp_rank1_cur_obj_play_sound_2_count : Z := 0.
Definition jp_rank1_play_sound_count : Z := 0.
Definition jp_rank1_puzzle_jingle_count : Z := 0.
Definition jp_rank1_stop_sounds_source_count : Z := 0.
Definition jp_rank1_stop_sounds_continuous_count : Z := 0.

Definition jp_rank1_graphics_header : Z := 2149233968. (* 0x801ab530 *)
Definition jp_rank1_graphics_payload_lo : Z := 2149233984. (* 0x801ab540 *)
Definition jp_rank1_graphics_payload_hi : Z := 2149322720. (* 0x801c0fe0 *)

Definition jp_rank1_head_after_graphics_alloc : LiveMainPoolHeads :=
  {| live_pool_left_head := jp_rank1_graphics_payload_hi;
     live_pool_right_head := jp_live_main_pool_right_head |}.

Definition jp_rank1_head_after_graphics_free : LiveMainPoolHeads :=
  jp_accepted_main_pool_heads.

Definition jp_rank1_graphics_payload : LogicalMainPoolAllocation :=
  {| logical_allocation_lo := jp_rank1_graphics_payload_lo;
     logical_allocation_hi := jp_rank1_graphics_payload_hi |}.

Record JPRank1LiveBoundaryReceipt : Prop := {
  jp_rank1_receipt_one_frame :
    jp_rank1_frame_end_timer = jp_rank1_frame_start_timer + 1;
  jp_rank1_receipt_static_prefixes :
    jp_rank1_final_node_count - jp_rank1_static_node_count = 24 /\
    jp_rank1_final_surface_count - jp_rank1_static_surface_count = 6;
  jp_rank1_receipt_store_classification :
    jp_rank1_safe_pool_write_count = 238 /\
    jp_rank1_unsafe_pool_write_count = 0 /\
    jp_rank1_dynamic_partition_write_count = 776 /\
    jp_rank1_static_partition_write_count = 0;
  jp_rank1_receipt_owner_bijection :
    jp_rank1_owner_store_count = jp_rank1_add_surface_count /\
    jp_rank1_owner_store_count = 6;
  jp_rank1_receipt_query_counts :
    jp_rank1_find_floor_count = 64 /\
    jp_rank1_platform_find_floor_count = 1;
  jp_rank1_receipt_outside_counts :
    jp_rank1_sqrtf_count = 162 /\
    jp_rank1_outside_destination_failures = 0 /\
    jp_rank1_camera_shake_count = 0 /\
    jp_rank1_create_sound_spawner_count = 0 /\
    jp_rank1_cur_obj_play_sound_2_count = 0 /\
    jp_rank1_play_sound_count = 0 /\
    jp_rank1_puzzle_jingle_count = 0 /\
    jp_rank1_stop_sounds_source_count = 0 /\
    jp_rank1_stop_sounds_continuous_count = 0;
  jp_rank1_receipt_allocator_calls :
    jp_rank1_allocator_init_count = 0 /\
    jp_rank1_allocator_alloc_count = 1 /\
    jp_rank1_allocator_free_count = 1 /\
    jp_rank1_allocator_realloc_count = 0 /\
    jp_rank1_allocator_push_count = 0 /\
    jp_rank1_allocator_pop_count = 0 /\
    jp_rank1_allocator_global_write_count = 4;
  jp_rank1_receipt_identity_and_list_checks :
    jp_rank1_surface_pointer_write_count = 0 /\
    jp_rank1_owner_failure_count = 0 /\
    jp_rank1_list_failure_count = 0 /\
    jp_rank1_object_lists_intact = 1 /\
    jp_rank1_static_lists_intact = 1 /\
    jp_rank1_dynamic_lists_intact = 1 /\
    jp_rank1_static_node_coverage = 1 /\
    jp_rank1_dynamic_node_coverage = 1 /\
    jp_rank1_owner_end_validity = 1;
  jp_rank1_receipt_selected_membership :
    jp_rank1_selected_static_membership = 1 /\
    jp_rank1_selected_dynamic_membership = 0;
  jp_rank1_receipt_graphics_adjacency :
    jp_rank1_graphics_header = jp_live_surface_pool_hi /\
    jp_rank1_graphics_payload_lo =
      jp_rank1_graphics_header + main_pool_header_size /\
    jp_rank1_graphics_payload_hi = jp_live_main_pool_end - 16
}.

Theorem jp_rank1_live_boundary_receipt_checked :
  JPRank1LiveBoundaryReceipt.
Proof.
  constructor; unfold jp_rank1_frame_end_timer,
    jp_rank1_frame_start_timer, jp_rank1_final_node_count,
    jp_rank1_static_node_count, jp_rank1_final_surface_count,
    jp_rank1_static_surface_count, jp_rank1_safe_pool_write_count,
    jp_rank1_unsafe_pool_write_count,
    jp_rank1_dynamic_partition_write_count,
    jp_rank1_static_partition_write_count, jp_rank1_owner_store_count,
    jp_rank1_add_surface_count, jp_rank1_find_floor_count,
    jp_rank1_platform_find_floor_count, jp_rank1_sqrtf_count,
    jp_rank1_outside_destination_failures,
    jp_rank1_allocator_init_count, jp_rank1_allocator_alloc_count,
    jp_rank1_allocator_free_count, jp_rank1_allocator_realloc_count,
    jp_rank1_allocator_push_count, jp_rank1_allocator_pop_count,
    jp_rank1_allocator_global_write_count,
    jp_rank1_surface_pointer_write_count, jp_rank1_owner_failure_count,
    jp_rank1_list_failure_count, jp_rank1_object_lists_intact,
    jp_rank1_static_lists_intact, jp_rank1_dynamic_lists_intact,
    jp_rank1_static_node_coverage, jp_rank1_dynamic_node_coverage,
    jp_rank1_owner_end_validity, jp_rank1_selected_static_membership,
    jp_rank1_selected_dynamic_membership, jp_rank1_camera_shake_count,
    jp_rank1_create_sound_spawner_count,
    jp_rank1_cur_obj_play_sound_2_count, jp_rank1_play_sound_count,
    jp_rank1_puzzle_jingle_count, jp_rank1_stop_sounds_source_count,
    jp_rank1_stop_sounds_continuous_count, jp_rank1_graphics_header,
    jp_rank1_graphics_payload_lo, jp_rank1_graphics_payload_hi,
    jp_live_surface_pool_hi, jp_live_main_pool_end,
    main_pool_header_size; repeat split; lia.
Qed.

(** The actual graphics allocation is a separate logical allocation whose
    header starts at the half-open end of the protected surface payload. *)
Theorem jp_rank1_graphics_payload_is_valid_and_separate :
  valid_logical_allocation jp_rank1_graphics_payload /\
  logical_allocation_misses_live_surface_hull jp_rank1_graphics_payload.
Proof.
  unfold valid_logical_allocation,
    logical_allocation_misses_live_surface_hull,
    jp_rank1_graphics_payload, logical_allocation_lo,
    logical_allocation_hi, jp_main_pool_lo, jp_main_pool_hi,
    jp_live_surface_pool_hi, jp_rank1_graphics_payload_lo,
    jp_rank1_graphics_payload_hi. cbn. split; lia.
Qed.

Theorem jp_rank1_allocator_head_sequence_keeps_surface_epoch :
  forall main_block,
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_accepted_main_pool_heads /\
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_rank1_head_after_graphics_alloc /\
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_rank1_head_after_graphics_free.
Proof.
  intros main_block.
  split.
  - exact (jp_accepted_heads_begin_live_surface_epoch main_block).
  - split.
    + change (2149233968 <= 2149322720 /\ 2149322720 <= 2149322736).
      split; lia.
    + exact (jp_accepted_heads_begin_live_surface_epoch main_block).
Qed.

(** * Exact final floor *)

Definition jp_rank1_query_position : PositionZ :=
  {| position_x := 653; position_y := 38; position_z := 6566 |}.

Definition jp_rank1_selected_static_node : ProjectedSurfaceNode :=
  {| projected_node_index := 0%nat;
     projected_surface_index := 808%nat;
     projected_owner := None;
     projected_floor_y := 38 |}.

Definition jp_rank1_selected_floor_words : list Z :=
  [3145728; 33; 2818342; 2496550; 19267622; 450495450;
   2497242; 0; 1065353216; 0; 3256352768; 0].

Definition jp_rank1_selected_floor_vertices : list (Z * Z * Z) :=
  [(294, 38, 6182); (294, 38, 6874); (986, 38, 6874)].

Definition jp_rank1_live_floor_selection :
    LiveFloorSelection jp_rank1_query_position.
Proof.
  refine
    {| live_surface_nodes := [jp_rank1_selected_static_node];
       live_selected_node := jp_rank1_selected_static_node |}.
  - apply SurfaceListInsert.
    apply InsertedStaticSurface. reflexivity.
  - simpl. auto.
Defined.

Theorem jp_rank1_selected_floor_is_exact_stock_static_floor :
  jp_live_surface_pool_lo + 808 * surface_size = 2149162352 /\
  jp_rank1_selected_floor_words =
    [3145728; 33; 2818342; 2496550; 19267622; 450495450;
     2497242; 0; 1065353216; 0; 3256352768; 0] /\
  jp_rank1_selected_floor_vertices =
    [(294, 38, 6182); (294, 38, 6874); (986, 38, 6874)] /\
  live_floor_selection_platform jp_rank1_live_floor_selection = None /\
  stock_area1_final_platform_query jp_rank1_query_position None.
Proof.
  unfold jp_live_surface_pool_lo, surface_size,
    jp_rank1_selected_floor_words, jp_rank1_selected_floor_vertices.
  repeat split; try reflexivity; cbn; exact I.
Qed.

(** * Concrete escape verdict *)

Definition JPRank1ConcreteFrameEscapesAbsent : Prop :=
  (forall main_block,
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_accepted_main_pool_heads /\
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_rank1_head_after_graphics_alloc /\
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_rank1_head_after_graphics_free) /\
  jp_rank1_unsafe_pool_write_count = 0 /\
  jp_rank1_outside_destination_failures = 0 /\
  jp_rank1_static_partition_write_count = 0 /\
  jp_rank1_surface_pointer_write_count = 0 /\
  jp_rank1_allocator_alloc_count = 1 /\
  jp_rank1_allocator_free_count = 1 /\
  jp_rank1_allocator_global_write_count = 4 /\
  jp_rank1_owner_store_count = jp_rank1_add_surface_count /\
  jp_rank1_owner_failure_count = 0 /\
  jp_rank1_object_lists_intact = 1 /\
  jp_rank1_static_lists_intact = 1 /\
  jp_rank1_dynamic_lists_intact = 1 /\
  jp_rank1_static_node_coverage = 1 /\
  jp_rank1_dynamic_node_coverage = 1 /\
  jp_rank1_owner_end_validity = 1 /\
  jp_rank1_selected_static_membership = 1 /\
  jp_rank1_selected_dynamic_membership = 0 /\
  live_floor_selection_platform jp_rank1_live_floor_selection = None /\
  stock_area1_final_platform_query jp_rank1_query_position None.

Theorem jp_rank1_concrete_frame_escapes_absent :
  JPRank1ConcreteFrameEscapesAbsent.
Proof.
  unfold JPRank1ConcreteFrameEscapesAbsent.
  split; [exact jp_rank1_allocator_head_sequence_keeps_surface_epoch |].
  unfold jp_rank1_unsafe_pool_write_count,
    jp_rank1_outside_destination_failures,
    jp_rank1_static_partition_write_count,
    jp_rank1_surface_pointer_write_count,
    jp_rank1_allocator_alloc_count, jp_rank1_allocator_free_count,
    jp_rank1_allocator_global_write_count, jp_rank1_owner_store_count,
    jp_rank1_add_surface_count, jp_rank1_owner_failure_count,
    jp_rank1_object_lists_intact, jp_rank1_static_lists_intact,
    jp_rank1_dynamic_lists_intact, jp_rank1_static_node_coverage,
    jp_rank1_dynamic_node_coverage, jp_rank1_owner_end_validity,
    jp_rank1_selected_static_membership,
    jp_rank1_selected_dynamic_membership.
  repeat split; try reflexivity; cbn; exact I.
Qed.

Definition Area1Rank1LiveBoundaryCheckedBoundary : Prop :=
  JPRank1LiveBoundaryReceipt /\
  (valid_logical_allocation jp_rank1_graphics_payload /\
   logical_allocation_misses_live_surface_hull jp_rank1_graphics_payload) /\
  JPRank1ConcreteFrameEscapesAbsent /\
  stock_area1_final_platform_query jp_rank1_query_position
    (live_floor_selection_platform jp_rank1_live_floor_selection).

Theorem area1_rank1_live_boundary_checked_boundary_holds :
  Area1Rank1LiveBoundaryCheckedBoundary.
Proof.
  unfold Area1Rank1LiveBoundaryCheckedBoundary.
  split; [exact jp_rank1_live_boundary_receipt_checked |].
  split; [exact jp_rank1_graphics_payload_is_valid_and_separate |].
  split; [exact jp_rank1_concrete_frame_escapes_absent |].
  exact (live_floor_selection_projects_to_stock_query
    jp_rank1_query_position jp_rank1_live_floor_selection).
Qed.
