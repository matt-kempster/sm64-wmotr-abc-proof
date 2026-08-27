(** Live main-pool range separation and floor-list projection for Rank 1.

    The surface and surface-node pools are not separate CompCert blocks.  They
    are consecutive manual allocations inside the shared main-pool backing
    block, and their addresses are published through writable globals.  This
    file therefore protects byte intervals, not C types or whole blocks.

    The results have three layers.

    - The allocator arithmetic fixes the exact two payload intervals and the
      intervening 16-byte allocator header.  A hash-gated, read-only JP receipt
      supplies their concrete addresses at the accepted level-select entry.

    - CompCert [Mem.store] and [Mem.storebytes] preserve both payloads whenever
      the actual store interval misses them.  Conversely, the first store that
      breaks this frame must be in the same backing block and overlap one of
      the two intervals.  Merely possessing a type-punned pointer into the
      shared main pool is therefore not a counterexample.

    - A small logical surface-list trace carries insertion provenance through
      frame-preserving steps.  A selected dynamic node with a recognized stock
      insertion projects to [stock_area1_final_platform_query]; static nodes
      project to [None].  This isolates the remaining live bridge to exact
      insertion classification, epoch preservation, and query selection.

    No theorem below treats an out-of-bounds access, a main-pool rewind/reuse,
    DMA, ACE, or continuation after undefined behavior as a successful Clight
    step. *)

From Coq Require Import Classical_Pred_Type Classical_Prop Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_game_init us_level_script us_memory us_surface_load
  jp_game_init jp_level_script jp_memory jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PlatformExhaustiveness Area1Rank1ResidualClosure GameTypes
  Area1SurfaceWriteClosure
  Area1Rank3PayloadWriterClosure InkTimer131RetailMipsFrames
  PlatformPointerProvenance PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

Module A1SPR_USM := us_memory.
Module A1SPR_USS := us_surface_load.
Module A1SPR_USG := us_game_init.
Module A1SPR_USL := us_level_script.
Module A1SPR_JPM := jp_memory.
Module A1SPR_JPS := jp_surface_load.
Module A1SPR_JPG := jp_game_init.
Module A1SPR_JPL := jp_level_script.

(** * Exact allocator layout *)

Definition surface_node_capacity : Z := 7000.
Definition surface_capacity : Z := 2300.
Definition surface_node_size : Z := 8.
Definition surface_size : Z := 48.
Definition main_pool_header_size : Z := 16.

Definition align16 (size : Z) : Z := ((size + 15) / 16) * 16.
Definition main_pool_allocation_span (size : Z) : Z :=
  align16 size + main_pool_header_size.

Definition surface_node_payload_bytes : Z :=
  surface_node_capacity * surface_node_size.
Definition surface_payload_bytes : Z := surface_capacity * surface_size.

Record MainPoolSurfaceRanges : Type := {
  surface_main_block : block;
  surface_initial_left_header : Z
}.

Definition surface_node_lo (ranges : MainPoolSurfaceRanges) : Z :=
  surface_initial_left_header ranges + main_pool_header_size.
Definition surface_node_hi (ranges : MainPoolSurfaceRanges) : Z :=
  surface_node_lo ranges + surface_node_payload_bytes.
Definition surface_header_lo (ranges : MainPoolSurfaceRanges) : Z :=
  surface_node_hi ranges.
Definition surface_header_hi (ranges : MainPoolSurfaceRanges) : Z :=
  surface_header_lo ranges + main_pool_header_size.
Definition surface_pool_lo (ranges : MainPoolSurfaceRanges) : Z :=
  surface_header_hi ranges.
Definition surface_pool_hi (ranges : MainPoolSurfaceRanges) : Z :=
  surface_pool_lo ranges + surface_payload_bytes.

Definition surface_payload_byte
    (ranges : MainPoolSurfaceRanges) (target_block : block)
    (offset : Z) : Prop :=
  target_block = surface_main_block ranges /\
  ((surface_node_lo ranges <= offset < surface_node_hi ranges) \/
   (surface_pool_lo ranges <= offset < surface_pool_hi ranges)).

Definition surface_payload_hull_byte
    (ranges : MainPoolSurfaceRanges) (target_block : block)
    (offset : Z) : Prop :=
  target_block = surface_main_block ranges /\
  surface_node_lo ranges <= offset < surface_pool_hi ranges.

Theorem generated_surface_struct_sizes_are_exact :
  sizeof (prog_comp_env A1SPR_USS.prog)
    (Tstruct A1SPR_USS._SurfaceNode noattr) = surface_node_size /\
  sizeof (prog_comp_env A1SPR_USS.prog)
    (Tstruct A1SPR_USS._Surface noattr) = surface_size /\
  sizeof (prog_comp_env A1SPR_JPS.prog)
    (Tstruct A1SPR_JPS._SurfaceNode noattr) = surface_node_size /\
  sizeof (prog_comp_env A1SPR_JPS.prog)
    (Tstruct A1SPR_JPS._Surface noattr) = surface_size.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem surface_pool_two_left_allocations_have_exact_layout :
  surface_node_payload_bytes = 56000 /\
  surface_payload_bytes = 110400 /\
  main_pool_allocation_span surface_node_payload_bytes = 56016 /\
  main_pool_allocation_span surface_payload_bytes = 110416.
Proof.
  vm_compute. repeat split.
Qed.

Theorem surface_pool_offsets_from_initial_header_are_exact :
  forall ranges,
    surface_node_hi ranges =
      surface_initial_left_header ranges + 56016 /\
    surface_pool_lo ranges =
      surface_initial_left_header ranges + 56032 /\
    surface_pool_hi ranges =
      surface_initial_left_header ranges + 166432.
Proof.
  intros [pool_block initial_header].
  cbv [surface_node_hi surface_node_lo
    surface_pool_lo surface_header_hi surface_header_lo surface_pool_hi
    surface_node_payload_bytes surface_payload_bytes
    surface_node_capacity surface_capacity surface_node_size surface_size
    main_pool_header_size].
  lia.
Qed.

Theorem node_header_and_surface_intervals_are_ordered :
  forall ranges,
    surface_node_lo ranges < surface_node_hi ranges /\
    surface_node_hi ranges = surface_header_lo ranges /\
    surface_header_lo ranges + 16 = surface_header_hi ranges /\
    surface_header_hi ranges = surface_pool_lo ranges /\
    surface_pool_lo ranges < surface_pool_hi ranges.
Proof.
  intros [pool_block initial_header].
  cbv [surface_node_lo surface_node_hi surface_header_lo
    surface_header_hi surface_pool_lo surface_pool_hi
    surface_node_payload_bytes surface_payload_bytes
    surface_node_capacity surface_capacity surface_node_size surface_size
    main_pool_header_size].
  lia.
Qed.

(** A later left allocation starts after the second allocation's terminal
    header.  This theorem is the arithmetic part of the live-epoch condition;
    [main_pool_free], [main_pool_pop_state], or reinitialization must separately
    be excluded because any of them can rewind the logical head. *)
Theorem later_left_payload_after_surface_pool_is_disjoint :
  forall ranges later_header later_size,
    surface_pool_hi ranges <= later_header ->
    0 <= later_size ->
    surface_pool_hi ranges <= later_header + main_pool_header_size /\
    surface_node_hi ranges <= later_header + main_pool_header_size.
Proof.
  intros ranges later_header later_size Hhead Hsize.
  pose proof (node_header_and_surface_intervals_are_ordered ranges)
    as [Hnode [Hnode_header [Hheader [Hsurface_header Hsurface]]]].
  split; unfold main_pool_header_size; lia.
Qed.

(** * Hash-gated JP live address receipt *)

Definition jp_live_surface_node_lo : Z := 2149067552. (* 0x80182b20 *)
Definition jp_live_surface_node_hi : Z := 2149123552. (* 0x801905e0 *)
Definition jp_live_surface_pool_lo : Z := 2149123568. (* 0x801905f0 *)
Definition jp_live_surface_pool_hi : Z := 2149233968. (* 0x801ab530 *)
Definition jp_live_main_pool_start : Z := 2147860496. (* 0x8005c010 *)
Definition jp_live_main_pool_end : Z := 2149322736.   (* 0x801c0ff0 *)
Definition jp_live_main_pool_left_head : Z := 2149233968. (* 0x801ab530 *)
Definition jp_live_main_pool_right_head : Z := 2149322736. (* 0x801c0ff0 *)
Definition jp_live_main_pool_free_space : Z := 88752.     (* 0x00015ab0 *)

Record JPAcceptedSurfacePoolReceipt : Prop := {
  jp_surface_receipt_timer : (348 : Z) = 348;
  jp_surface_receipt_node_bytes :
    jp_live_surface_node_hi - jp_live_surface_node_lo = 56000;
  jp_surface_receipt_header_gap :
    jp_live_surface_pool_lo - jp_live_surface_node_hi = 16;
  jp_surface_receipt_surface_bytes :
    jp_live_surface_pool_hi - jp_live_surface_pool_lo = 110400;
  jp_surface_receipt_is_last_left_allocation :
    jp_live_main_pool_left_head = jp_live_surface_pool_hi;
  jp_surface_receipt_live_heads_ordered :
    jp_live_main_pool_left_head <= jp_live_main_pool_right_head;
  jp_surface_receipt_pool_payload_bounds :
    jp_live_main_pool_start = 2147860496 /\
    jp_live_main_pool_end = jp_live_main_pool_right_head;
  jp_surface_receipt_free_space :
    jp_live_main_pool_free_space = 88752
}.

Theorem jp_accepted_surface_pool_receipt_checked :
  JPAcceptedSurfacePoolReceipt.
Proof.
  constructor.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - unfold jp_live_main_pool_left_head, jp_live_main_pool_right_head. lia.
  - split; reflexivity.
  - reflexivity.
Qed.

Definition jp_retail_store_misses_surface_pool_hull
    (event : JPMipsStoreEvent) : Prop :=
  jp_store_event_address event + jp_store_event_width event <=
      jp_live_surface_node_lo \/
  jp_live_surface_pool_hi <= jp_store_event_address event.

(** The stock 4 MiB link layout puts the manual main pool at
    [0x8005c000,0x801c1000).  The separately linked decompression buffer starts
    exactly at the upper boundary; the JP audio heap follows its 0xd000-byte
    prefix.  These bounds matter for puzzle-jingle DMA: a valid audio-pool
    destination is close to the main pool in physical RAM, but is not inside
    it and is still above both live surface payloads. *)
Definition jp_main_pool_lo : Z := 2147860480.       (* 0x8005c000 *)
Definition jp_main_pool_hi : Z := 2149322752.       (* 0x801c1000 *)
Definition jp_decompression_heap_lo : Z := 2149322752.
Definition jp_audio_heap_lo : Z := 2149376000.      (* 0x801ce000 *)
Definition jp_audio_heap_hi : Z := 2149577216.      (* 0x801ff200 *)

Theorem jp_live_surface_ranges_are_inside_main_pool_and_below_audio :
  jp_main_pool_lo <= jp_live_surface_node_lo /\
  jp_live_surface_pool_hi <= jp_main_pool_hi /\
  jp_main_pool_hi = jp_decompression_heap_lo /\
  jp_decompression_heap_lo + 53248 = jp_audio_heap_lo /\
  jp_audio_heap_lo + 201216 = jp_audio_heap_hi.
Proof.
  unfold jp_main_pool_lo, jp_main_pool_hi, jp_live_surface_node_lo,
    jp_live_surface_pool_hi, jp_decompression_heap_lo, jp_audio_heap_lo,
    jp_audio_heap_hi. repeat split; lia.
Qed.

Record LogicalMainPoolAllocation : Type := {
  logical_allocation_lo : Z;
  logical_allocation_hi : Z
}.

Definition valid_logical_allocation
    (allocation : LogicalMainPoolAllocation) : Prop :=
  jp_main_pool_lo <= logical_allocation_lo allocation /\
  logical_allocation_lo allocation < logical_allocation_hi allocation /\
  logical_allocation_hi allocation <= jp_main_pool_hi.

Definition logical_allocation_access
    (allocation : LogicalMainPoolAllocation) (address width : Z) : Prop :=
  0 < width /\
  logical_allocation_lo allocation <= address /\
  address + width <= logical_allocation_hi allocation.

Definition logical_allocation_misses_live_surface_hull
    (allocation : LogicalMainPoolAllocation) : Prop :=
  logical_allocation_hi allocation <= jp_live_surface_node_lo \/
  jp_live_surface_pool_hi <= logical_allocation_lo allocation.

Theorem owned_main_pool_access_in_separate_range_misses_live_surface_pools :
  forall allocation pc address width,
    logical_allocation_access allocation address width ->
    logical_allocation_misses_live_surface_hull allocation ->
    jp_retail_store_misses_surface_pool_hull
      (jp_store_event pc address width).
Proof.
  intros allocation pc address width
    [Hwidth [Hlo Hhi]] [Hbelow | Habove].
  - left. cbn. lia.
  - right. cbn. lia.
Qed.

(** This is the useful verdict for a pre-existing/type-punned pointer.  A
    pointer into some other logical main-pool allocation is not dangerous by
    itself.  If a valid access through it fails the surface frame, then that
    logical allocation's interval really overlaps the live surface hull; the
    shared CompCert block alone is not enough. *)
Theorem failed_owned_alias_frame_exposes_logical_range_overlap :
  forall allocation pc address width,
    logical_allocation_access allocation address width ->
    ~ jp_retail_store_misses_surface_pool_hull
        (jp_store_event pc address width) ->
    logical_allocation_lo allocation < jp_live_surface_pool_hi /\
    jp_live_surface_node_lo < logical_allocation_hi allocation.
Proof.
  intros allocation pc address width Haccess Hfailure.
  destruct Haccess as [Hwidth [Hlo Hhi]].
  unfold jp_retail_store_misses_surface_pool_hull in Hfailure.
  cbn in Hfailure.
  split; lia.
Qed.

(** * Live main-pool epoch invariant *)

(** CompCert sees one backing allocation, while the retail allocator maintains
    two logical heads inside it.  This state records exactly the part needed by
    the surface proof.  The surface payloads remain live when the left head is
    not rewound below their end and the two heads have not crossed. *)
Record LiveMainPoolHeads : Type := {
  live_pool_left_head : Z;
  live_pool_right_head : Z
}.

Definition live_surface_pool_epoch
    (ranges : MainPoolSurfaceRanges) (heads : LiveMainPoolHeads) : Prop :=
  surface_pool_hi ranges <= live_pool_left_head heads /\
  live_pool_left_head heads <= live_pool_right_head heads.

Definition jp_accepted_main_pool_heads : LiveMainPoolHeads :=
  {| live_pool_left_head := jp_live_main_pool_left_head;
     live_pool_right_head := jp_live_main_pool_right_head |}.

Definition jp_accepted_surface_ranges (main_block : block) :
    MainPoolSurfaceRanges :=
  {| surface_main_block := main_block;
     surface_initial_left_header :=
       jp_live_surface_node_lo - main_pool_header_size |}.

Theorem jp_accepted_ranges_reconstruct_all_four_endpoints :
  forall main_block,
    surface_node_lo (jp_accepted_surface_ranges main_block) =
      jp_live_surface_node_lo /\
    surface_node_hi (jp_accepted_surface_ranges main_block) =
      jp_live_surface_node_hi /\
    surface_pool_lo (jp_accepted_surface_ranges main_block) =
      jp_live_surface_pool_lo /\
    surface_pool_hi (jp_accepted_surface_ranges main_block) =
      jp_live_surface_pool_hi.
Proof.
  intros main_block.
  unfold jp_accepted_surface_ranges, surface_node_lo, surface_node_hi,
    surface_header_lo, surface_header_hi, surface_pool_lo, surface_pool_hi,
    surface_node_payload_bytes, surface_payload_bytes,
    surface_node_capacity, surface_capacity, surface_node_size, surface_size,
    main_pool_header_size, jp_live_surface_node_lo,
    jp_live_surface_node_hi, jp_live_surface_pool_lo,
    jp_live_surface_pool_hi. cbn. repeat split; lia.
Qed.

Theorem jp_accepted_heads_begin_live_surface_epoch :
  forall main_block,
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_accepted_main_pool_heads.
Proof.
  intros main_block.
  change (2149233968 <= 2149233968 /\ 2149233968 <= 2149322736).
  split; lia.
Qed.

(** These are precisely the main-pool operations that may remain inside a
    protected live epoch: a frame, a successful left or right allocation in
    the free gap, or a saved-state restoration whose recorded heads are still
    above the surface allocations.  Reinitialization, a free/reallocation, or
    a pop below the surface end deliberately has no constructor. *)
Inductive LiveMainPoolEpochStep (ranges : MainPoolSurfaceRanges) :
    LiveMainPoolHeads -> LiveMainPoolHeads -> Prop :=
| LiveMainPoolFrame : forall heads,
    LiveMainPoolEpochStep ranges heads heads
| LiveMainPoolLeftAllocation : forall before span,
    0 < span ->
    live_pool_left_head before + span <= live_pool_right_head before ->
    LiveMainPoolEpochStep ranges before
      {| live_pool_left_head := live_pool_left_head before + span;
         live_pool_right_head := live_pool_right_head before |}
| LiveMainPoolRightAllocation : forall before span,
    0 < span ->
    live_pool_left_head before <= live_pool_right_head before - span ->
    LiveMainPoolEpochStep ranges before
      {| live_pool_left_head := live_pool_left_head before;
         live_pool_right_head := live_pool_right_head before - span |}
| LiveMainPoolRestoreAboveSurface : forall before after,
    surface_pool_hi ranges <= live_pool_left_head after ->
    live_pool_left_head after <= live_pool_right_head after ->
    LiveMainPoolEpochStep ranges before after
| LiveMainPoolEpochTrans : forall first middle final,
    LiveMainPoolEpochStep ranges first middle ->
    LiveMainPoolEpochStep ranges middle final ->
    LiveMainPoolEpochStep ranges first final.

Theorem live_main_pool_epoch_step_preserves_surface_ranges :
  forall ranges before after,
    live_surface_pool_epoch ranges before ->
    LiveMainPoolEpochStep ranges before after ->
    live_surface_pool_epoch ranges after.
Proof.
  intros ranges before after Hlive Hstep.
  induction Hstep.
  - exact Hlive.
  - unfold live_surface_pool_epoch in *. cbn in *.
    destruct Hlive as [Hsurface Hheads]. split; lia.
  - unfold live_surface_pool_epoch in *. cbn in *.
    destruct Hlive as [Hsurface Hheads]. split; lia.
  - unfold live_surface_pool_epoch. split; assumption.
  - apply IHHstep2. apply IHHstep1. exact Hlive.
Qed.

Definition live_left_allocation
    (before : LiveMainPoolHeads) (span : Z) : LogicalMainPoolAllocation :=
  {| logical_allocation_lo :=
       live_pool_left_head before + main_pool_header_size;
     logical_allocation_hi := live_pool_left_head before + span |}.

Definition live_right_allocation
    (before : LiveMainPoolHeads) (span : Z) : LogicalMainPoolAllocation :=
  {| logical_allocation_lo :=
       live_pool_right_head before - span + main_pool_header_size;
     logical_allocation_hi := live_pool_right_head before |}.

Theorem live_left_allocation_is_above_surface_hull :
  forall ranges before span,
    surface_pool_hi ranges = jp_live_surface_pool_hi ->
    live_surface_pool_epoch ranges before ->
    main_pool_header_size < span ->
    logical_allocation_misses_live_surface_hull
      (live_left_allocation before span).
Proof.
  intros ranges before span Hendpoint [Hsurface Hheads] Hspan.
  right. cbn. unfold main_pool_header_size. rewrite <- Hendpoint. lia.
Qed.

Theorem live_right_allocation_is_above_surface_hull :
  forall ranges before span,
    surface_pool_hi ranges = jp_live_surface_pool_hi ->
    live_surface_pool_epoch ranges before ->
    main_pool_header_size < span ->
    live_pool_left_head before <= live_pool_right_head before - span ->
    logical_allocation_misses_live_surface_hull
      (live_right_allocation before span).
Proof.
  intros ranges before span Hendpoint [Hsurface Hheads] Hspan Hfits.
  right. cbn. unfold main_pool_header_size. rewrite <- Hendpoint. lia.
Qed.

(** Therefore a first logical allocator step that loses the surface epoch is
    not an ordinary allocation or a safe saved-state restoration.  It exposes
    exactly the rewind/reuse/lifetime escape that the earlier alias audit left
    unnamed. *)
Theorem first_surface_epoch_failure_exposes_unclassified_allocator_step :
  forall ranges before after,
    live_surface_pool_epoch ranges before ->
    ~ live_surface_pool_epoch ranges after ->
    ~ LiveMainPoolEpochStep ranges before after.
Proof.
  intros ranges before after Hbefore Hafter Hstep.
  apply Hafter.
  eapply live_main_pool_epoch_step_preserves_surface_ranges; eauto.
Qed.

Definition jp_entry_stack_envelope_misses_surface_pool_hull
    (entry_sp : Z) : Prop :=
  entry_sp <= jp_live_surface_node_lo \/
  jp_live_surface_pool_hi <= entry_sp - 128.

Theorem jp_existing_sound_root_effect_misses_live_surface_pools :
  forall root entry_sp event,
    jp_entry_stack_envelope_misses_surface_pool_hull entry_sp ->
    JPMipsExternalStoreEffect root entry_sp event ->
    jp_retail_store_misses_surface_pool_hull event.
Proof.
  intros root entry_sp event Hstack Heffect.
  destruct Heffect as
    [shape Hshape
    |bank index Hroot Hbank Hindex
    |bank index Hroot Hbank Hindex
    |Hroot
    |shape Hroot Hshape].
  - pose proof (jp_root_stack_shape_bounds root shape Hshape)
      as [Hlower [Hwidth Hupper]].
    change
      (entry_sp + jp_store_shape_offset shape +
          jp_store_shape_width shape <= jp_live_surface_node_lo \/
       jp_live_surface_pool_hi <=
          entry_sp + jp_store_shape_offset shape).
    destruct Hstack; [left | right]; lia.
  - change
      (jp_audio_bank_base + bank * 1120 + index * 28 + 20 + 4 <=
          jp_live_surface_node_lo \/
       jp_live_surface_pool_hi <=
          jp_audio_bank_base + bank * 1120 + index * 28 + 20).
    assert (0 <= bank * 1120) by
      (apply Z.mul_nonneg_nonneg; lia).
    assert (0 <= index * 28) by
      (apply Z.mul_nonneg_nonneg; lia).
    right. unfold jp_audio_bank_base, jp_live_surface_pool_hi. lia.
  - change
      (jp_audio_bank_base + bank * 1120 + index * 28 + 20 + 4 <=
          jp_live_surface_node_lo \/
       jp_live_surface_pool_hi <=
          jp_audio_bank_base + bank * 1120 + index * 28 + 20).
    destruct Hbank as [Hbank | [Hbank | [Hbank | Hbank]]];
      try contradiction; subst bank;
      assert (0 <= index * 28) by
        (apply Z.mul_nonneg_nonneg; lia);
      right; unfold jp_audio_bank_base, jp_live_surface_pool_hi; lia.
  - change
      (jp_music_mask_address + 2 <= jp_live_surface_node_lo \/
       jp_live_surface_pool_hi <= jp_music_mask_address).
    right. unfold jp_music_mask_address, jp_live_surface_pool_hi. lia.
  - pose proof (jp_sequence_store_shape_bounds shape Hshape)
      as [Hlower [Hwidth Hupper]].
    change
      (jp_sequence_player_zero + jp_store_shape_offset shape +
          jp_store_shape_width shape <= jp_live_surface_node_lo \/
       jp_live_surface_pool_hi <=
          jp_sequence_player_zero + jp_store_shape_offset shape).
    right. unfold jp_sequence_player_zero, jp_live_surface_pool_hi. lia.
Qed.

Theorem jp_timer131_continuous_stack_misses_live_surface_pools :
  jp_entry_stack_envelope_misses_surface_pool_hull
    jp_timer131_continuous_entry_sp.
Proof.
  unfold jp_entry_stack_envelope_misses_surface_pool_hull,
    jp_timer131_continuous_entry_sp, jp_live_surface_node_lo,
    jp_live_surface_pool_hi. lia.
Qed.

(** * Rank-1 outside-root protected frames *)

(** The companion hash-gated verifier authenticates all 163 instructions in
    these five direct roots.  These are the complete store and direct-call
    projections of those ranges; the called routines are handled by the
    protected-region effect relation below rather than silently folded into a
    direct-root claim. *)
Definition jp_rank1_direct_store_words : list (Z * Z) :=
  [(2150102084, 2948530220); (2150102088, 2946760760);
   (2150102092, 2946826300); (2150102096, 2946891840);
   (2150102100, 2946957380); (2150102104, 2947547176);
   (2150102196, 3886284816); (2150102200, 3886415892);
   (2150102208, 3886546968); (2150102248, 3886678032);
   (2150102252, 3887071252); (2150102260, 3887202328);
   (2150102324, 3886284816); (2150102328, 3886415892);
   (2150102336, 3886546968); (2150102396, 3886678032);
   (2150102400, 3887071252); (2150102408, 3887202328);
   (2150405736, 2948530196); (2150405740, 2946760736);
   (2150405768, 2946629660); (2150405780, 2918056180);
   (2150405892, 2948530196); (2150405896, 2946760728);
   (2150751384, 2892234752); (2150751388, 2892300292);
   (2150751396, 2698510336); (2150765100, 2948530196);
   (2150765128, 2687377692)].

Definition jp_rank1_direct_call_edges : list (Z * Z) :=
  [(2150102204, 2150148736); (2150102256, 2150148736);
   (2150102276, 2150212884); (2150102332, 2150148736);
   (2150102352, 2150212884); (2150102404, 2150148736);
   (2150102424, 2150212884); (2150405760, 2150229584);
   (2150405936, 2150751352); (2150765112, 2150758032);
   (2150765132, 2150760676)].

Record JPRank1DirectRootMachineReceipt : Prop := {
  jp_rank1_direct_instruction_count :
    (97 + 19 + 20 + 12 + 15)%nat = 163%nat;
  jp_rank1_direct_store_count :
    length jp_rank1_direct_store_words = 29%nat;
  jp_rank1_direct_call_count :
    length jp_rank1_direct_call_edges = 11%nat
}.

Theorem jp_rank1_direct_root_machine_receipt_checked :
  JPRank1DirectRootMachineReceipt.
Proof. constructor; vm_compute; reflexivity. Qed.

Inductive JPRank1OutsideRoot : Type :=
| JPRank1PuzzleJingle
| JPRank1CreateSoundSpawner
| JPRank1CurObjectSound
| JPRank1CameraShake
| JPRank1Sqrtf
| JPRank1StopSoundsFromSource.

Definition jp_sound_request_count : Z := 2150833716. (* 0x80331e34 *)
Definition jp_sound_request_base : Z := 2151022888.  (* 0x80360128 *)
Definition jp_puzzle_music_state : Z := 2150834460.  (* 0x8033211c *)

(** This relation is an exact protected-memory frame, not a claim that the
    callees only modify one semantic object.  For the surface proof their
    complete store footprint has four relevant regions: nested game-thread
    stack, fixed/static game state, the static object pool, and the separately
    linked JP audio heap.  Each constructor records the address formula or
    the containing valid region.  A forged descriptor that points an audio or
    object write back into the main pool does not satisfy this relation and is
    therefore exposed as the first failed frame rather than assumed away. *)
Inductive JPRank1OutsideStoreEffect
    (root : JPRank1OutsideRoot) (entry_sp : Z) : JPMipsStoreEvent -> Prop :=
| JPRank1NestedStackStore : forall pc offset width,
    -65536 <= offset ->
    0 < width ->
    offset + width <= 256 ->
    root <> JPRank1Sqrtf ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event pc (entry_sp + offset) width)
| JPRank1StaticStore : forall pc address width,
    root <> JPRank1Sqrtf ->
    jp_main_pool_hi <= address ->
    0 < width ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event pc address width)
| JPRank1AudioHeapStore : forall pc address width,
    root = JPRank1PuzzleJingle ->
    jp_audio_heap_lo <= address ->
    address + width <= jp_audio_heap_hi ->
    0 < width ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event pc address width)
| JPRank1CreateObjectPoolStore : forall pc address width,
    root = JPRank1CreateSoundSpawner ->
    jp_object_pool_start <= address ->
    address + width <= jp_object_pool_end ->
    0 < width ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event pc address width)
| JPRank1CurSoundRequestStore : forall index field_offset,
    root = JPRank1CurObjectSound ->
    0 <= index < 256 ->
    In field_offset [0; 4] ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event
        (if Z.eqb field_offset 0 then 2150751384 else 2150751388)
        (jp_sound_request_base + index * 8 + field_offset) 4)
| JPRank1CurSoundCountStore :
    root = JPRank1CurObjectSound ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event 2150751396 jp_sound_request_count 1)
| JPRank1PuzzleMusicStore :
    root = JPRank1PuzzleJingle ->
    JPRank1OutsideStoreEffect root entry_sp
      (jp_store_event 2150765128 jp_puzzle_music_state 1)
| JPRank1ExistingStopSoundStore : forall event,
    root = JPRank1StopSoundsFromSource ->
    JPMipsExternalStoreEffect JPMipsStopSoundsFromSource entry_sp event ->
    JPRank1OutsideStoreEffect root entry_sp event.

Definition jp_rank1_entry_stack_misses_surface_hull (entry_sp : Z) : Prop :=
  jp_live_surface_pool_hi <= entry_sp - 65536.

Theorem jp_rank1_outside_effect_misses_live_surface_pools :
  forall root entry_sp event,
    jp_rank1_entry_stack_misses_surface_hull entry_sp ->
    JPRank1OutsideStoreEffect root entry_sp event ->
    jp_retail_store_misses_surface_pool_hull event.
Proof.
  intros root entry_sp event Hstack Heffect.
  destruct Heffect as
    [pc offset width Hoffset Hwidth Hupper Hnot_sqrt
    |pc address width Hnot_sqrt Habove Hwidth
    |pc address width Hroot Hlo Hhi Hwidth
    |pc address width Hroot Hlo Hhi Hwidth
    |index field_offset Hroot Hindex Hfield
    |Hroot |Hroot |event Hroot Heffect].
  - right. cbn. unfold jp_rank1_entry_stack_misses_surface_hull in Hstack.
    lia.
  - right. cbn. unfold jp_main_pool_hi, jp_live_surface_pool_hi in *.
    lia.
  - right. cbn. unfold jp_audio_heap_lo, jp_live_surface_pool_hi in *.
    lia.
  - right. cbn. unfold jp_object_pool_start, jp_live_surface_pool_hi in *.
    lia.
  - destruct Hfield as [Hfield | [Hfield | Hfield]];
      try contradiction; subst field_offset.
    + right. change
        (jp_live_surface_pool_hi <=
          jp_sound_request_base + index * 8 + 0).
      assert (0 <= index * 8) by
        (apply Z.mul_nonneg_nonneg; lia).
      unfold jp_sound_request_base, jp_live_surface_pool_hi. lia.
    + right. change
        (jp_live_surface_pool_hi <=
          jp_sound_request_base + index * 8 + 4).
      assert (0 <= index * 8) by
        (apply Z.mul_nonneg_nonneg; lia).
      unfold jp_sound_request_base, jp_live_surface_pool_hi. lia.
  - right. cbn. unfold jp_sound_request_count, jp_live_surface_pool_hi. lia.
  - right. cbn. unfold jp_puzzle_music_state, jp_live_surface_pool_hi. lia.
  - eapply jp_existing_sound_root_effect_misses_live_surface_pools; eauto.
    unfold jp_entry_stack_envelope_misses_surface_pool_hull,
      jp_rank1_entry_stack_misses_surface_hull in *.
    right. lia.
Qed.

Definition JPRank1OutsideStoreTrace
    (root : JPRank1OutsideRoot) (entry_sp : Z)
    (trace : list JPMipsStoreEvent) : Prop :=
  Forall (JPRank1OutsideStoreEffect root entry_sp) trace.

Theorem jp_rank1_outside_trace_misses_live_surface_pools :
  forall root entry_sp trace,
    jp_rank1_entry_stack_misses_surface_hull entry_sp ->
    JPRank1OutsideStoreTrace root entry_sp trace ->
    Forall jp_retail_store_misses_surface_pool_hull trace.
Proof.
  intros root entry_sp trace Hstack Htrace.
  induction Htrace; constructor; eauto using
    jp_rank1_outside_effect_misses_live_surface_pools.
Qed.

(** * CompCert byte-range frame *)

Definition store_interval_misses_surface_payloads
    (ranges : MainPoolSurfaceRanges) (chunk : memory_chunk)
    (store_block : block) (store_offset : Z) : Prop :=
  forall byte_offset,
    store_offset <= byte_offset < store_offset + size_chunk chunk ->
    ~ surface_payload_byte ranges store_block byte_offset.

Definition storebytes_interval_misses_surface_payloads
    (ranges : MainPoolSurfaceRanges) (bytes : list memval)
    (store_block : block) (store_offset : Z) : Prop :=
  forall byte_offset,
    store_offset <= byte_offset < store_offset + Z.of_nat (length bytes) ->
    ~ surface_payload_byte ranges store_block byte_offset.

Theorem separated_store_preserves_both_surface_payloads :
  forall ranges chunk before store_block store_offset value after,
    Mem.store chunk before store_block store_offset value = Some after ->
    store_interval_misses_surface_payloads
      ranges chunk store_block store_offset ->
    Mem.unchanged_on (surface_payload_byte ranges) before after.
Proof.
  intros ranges chunk before store_block store_offset value after
    Hstore Hmiss.
  eapply Mem.store_unchanged_on; eauto.
Qed.

Theorem separated_storebytes_preserves_both_surface_payloads :
  forall ranges before store_block store_offset bytes after,
    Mem.storebytes before store_block store_offset bytes = Some after ->
    storebytes_interval_misses_surface_payloads
      ranges bytes store_block store_offset ->
    Mem.unchanged_on (surface_payload_byte ranges) before after.
Proof.
  intros ranges before store_block store_offset bytes after Hstore Hmiss.
  eapply Mem.storebytes_unchanged_on; eauto.
Qed.

Theorem store_to_other_compcert_block_preserves_surface_payloads :
  forall ranges chunk before store_block store_offset value after,
    store_block <> surface_main_block ranges ->
    Mem.store chunk before store_block store_offset value = Some after ->
    Mem.unchanged_on (surface_payload_byte ranges) before after.
Proof.
  intros ranges chunk before store_block store_offset value after
    Hother Hstore.
  eapply separated_store_preserves_both_surface_payloads; [eassumption |].
  intros byte_offset _ [Hequal _]. contradiction.
Qed.

Theorem same_block_store_below_node_pool_preserves_surface_payloads :
  forall ranges chunk before store_offset value after,
    store_offset + size_chunk chunk <= surface_node_lo ranges ->
    Mem.store chunk before (surface_main_block ranges) store_offset value =
      Some after ->
    Mem.unchanged_on (surface_payload_byte ranges) before after.
Proof.
  intros ranges chunk before store_offset value after Hbelow Hstore.
  pose proof (node_header_and_surface_intervals_are_ordered ranges)
    as [Hnode_order [Hnode_header [Hheader [Hsurface_header Hsurface_order]]]].
  eapply separated_store_preserves_both_surface_payloads; [eassumption |].
  intros byte_offset Hstore_byte [_ [[Hnode _] | [Hsurface _]]]; lia.
Qed.

Theorem same_block_store_above_surface_pool_preserves_surface_payloads :
  forall ranges chunk before store_offset value after,
    surface_pool_hi ranges <= store_offset ->
    Mem.store chunk before (surface_main_block ranges) store_offset value =
      Some after ->
    Mem.unchanged_on (surface_payload_byte ranges) before after.
Proof.
  intros ranges chunk before store_offset value after Habove Hstore.
  pose proof (node_header_and_surface_intervals_are_ordered ranges)
    as [Hnode_order [Hnode_header [Hheader [Hsurface_header Hsurface_order]]]].
  eapply separated_store_preserves_both_surface_payloads; [eassumption |].
  intros byte_offset Hstore_byte [_ [[_ Hnode] | [_ Hsurface]]]; lia.
Qed.

(** This is the decisive type-punned-alias reduction.  A failed frame cannot
    be blamed merely on the common backing allocation: it exposes an actual
    byte in the store interval which is also a node or surface payload byte. *)
Theorem first_surface_frame_failure_exposes_same_block_overlap :
  forall ranges chunk before store_block store_offset value after,
    Mem.store chunk before store_block store_offset value = Some after ->
    ~ Mem.unchanged_on (surface_payload_byte ranges) before after ->
    store_block = surface_main_block ranges /\
    exists byte_offset,
      store_offset <= byte_offset < store_offset + size_chunk chunk /\
      ((surface_node_lo ranges <= byte_offset < surface_node_hi ranges) \/
       (surface_pool_lo ranges <= byte_offset < surface_pool_hi ranges)).
Proof.
  intros ranges chunk before store_block store_offset value after
    Hstore Hchanged.
  destruct (classic (store_interval_misses_surface_payloads
    ranges chunk store_block store_offset)) as [Hmiss | Hnot_miss].
  - exfalso. apply Hchanged.
    exact (separated_store_preserves_both_surface_payloads
      ranges chunk before store_block store_offset value after Hstore Hmiss).
  - unfold store_interval_misses_surface_payloads in Hnot_miss.
    apply not_all_ex_not in Hnot_miss.
    destruct Hnot_miss as [byte_offset Hnot].
    apply imply_to_and in Hnot.
    destruct Hnot as [Hinside Hnot_not].
    apply NNPP in Hnot_not.
    destruct Hnot_not as [Hblock Hpayload].
    split; [exact Hblock |].
    exists byte_offset. split; assumption.
Qed.

Theorem protected_surface_load_survives_range_frame :
  forall ranges before after chunk load_block load_offset value,
    Mem.unchanged_on (surface_payload_byte ranges) before after ->
    (forall byte_offset,
      load_offset <= byte_offset < load_offset + size_chunk chunk ->
      surface_payload_byte ranges load_block byte_offset) ->
    Mem.load chunk before load_block load_offset = Some value ->
    Mem.load chunk after load_block load_offset = Some value.
Proof.
  intros. eapply Mem.load_unchanged_on; eauto.
Qed.

(** * Source census for the epoch and public aliases *)

Definition MainPoolAllocationCallerClaim : Prop :=
  internal_function_direct_call_sites A1SPR_USM._main_pool_alloc
    rank3_us_definitions =
      [A1SPR_USG._setup_game_memory;
       A1SPR_USL._level_cmd_load_mario_head;
       A1SPR_USM._main_pool_realloc;
       A1SPR_USM._main_pool_push_state;
       A1SPR_USM._dynamic_dma_read;
       A1SPR_USM._load_to_fixed_pool_addr;
       A1SPR_USM._load_segment_decompress;
       A1SPR_USM._load_segment_decompress_heap;
       A1SPR_USM._alloc_only_pool_init;
       A1SPR_USM._mem_pool_init;
       A1SPR_USS._alloc_surface_pools] /\
  internal_function_direct_call_sites A1SPR_JPM._main_pool_alloc
    rank3_jp_definitions =
      [A1SPR_JPG._setup_game_memory;
       A1SPR_JPL._level_cmd_load_mario_head;
       A1SPR_JPM._main_pool_realloc;
       A1SPR_JPM._main_pool_push_state;
       A1SPR_JPM._dynamic_dma_read;
       A1SPR_JPM._load_to_fixed_pool_addr;
       A1SPR_JPM._load_segment_decompress;
       A1SPR_JPM._load_segment_decompress_heap;
       A1SPR_JPM._alloc_only_pool_init;
       A1SPR_JPM._mem_pool_init;
       A1SPR_JPS._alloc_surface_pools].

Theorem main_pool_allocation_callers_are_exact :
  MainPoolAllocationCallerClaim.
Proof.
  unfold MainPoolAllocationCallerClaim.
  vm_compute. split; reflexivity.
Qed.

Definition MainPoolEpochMutatorSourceClaim : Prop :=
  internal_function_assignment_sites A1SPR_USM._sPoolStart
    rank3_us_definitions = [A1SPR_USM._main_pool_init] /\
  internal_function_assignment_sites A1SPR_USM._sPoolEnd
    rank3_us_definitions = [A1SPR_USM._main_pool_init] /\
  internal_function_assignment_sites A1SPR_USM._sPoolFreeSpace
    rank3_us_definitions =
      [A1SPR_USM._main_pool_init; A1SPR_USM._main_pool_alloc;
       A1SPR_USM._main_pool_free; A1SPR_USM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_USM._sPoolListHeadL
    rank3_us_definitions =
      [A1SPR_USM._main_pool_init; A1SPR_USM._main_pool_alloc;
       A1SPR_USM._main_pool_free; A1SPR_USM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_USM._sPoolListHeadR
    rank3_us_definitions =
      [A1SPR_USM._main_pool_init; A1SPR_USM._main_pool_alloc;
       A1SPR_USM._main_pool_free; A1SPR_USM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_USM._gMainPoolState
    rank3_us_definitions =
      [A1SPR_USM._main_pool_push_state; A1SPR_USM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_JPM._sPoolStart
    rank3_jp_definitions = [A1SPR_JPM._main_pool_init] /\
  internal_function_assignment_sites A1SPR_JPM._sPoolEnd
    rank3_jp_definitions = [A1SPR_JPM._main_pool_init] /\
  internal_function_assignment_sites A1SPR_JPM._sPoolFreeSpace
    rank3_jp_definitions =
      [A1SPR_JPM._main_pool_init; A1SPR_JPM._main_pool_alloc;
       A1SPR_JPM._main_pool_free; A1SPR_JPM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_JPM._sPoolListHeadL
    rank3_jp_definitions =
      [A1SPR_JPM._main_pool_init; A1SPR_JPM._main_pool_alloc;
       A1SPR_JPM._main_pool_free; A1SPR_JPM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_JPM._sPoolListHeadR
    rank3_jp_definitions =
      [A1SPR_JPM._main_pool_init; A1SPR_JPM._main_pool_alloc;
       A1SPR_JPM._main_pool_free; A1SPR_JPM._main_pool_pop_state] /\
  internal_function_assignment_sites A1SPR_JPM._gMainPoolState
    rank3_jp_definitions =
      [A1SPR_JPM._main_pool_push_state; A1SPR_JPM._main_pool_pop_state].

Theorem main_pool_epoch_mutator_source_census_checked :
  MainPoolEpochMutatorSourceClaim.
Proof.
  unfold MainPoolEpochMutatorSourceClaim.
  vm_compute. repeat split; reflexivity.
Qed.

Definition CanonicalOwnerMainPoolEpochIsolationClaim : Prop :=
  identifiers_in
    [A1SPR_USM._main_pool_init; A1SPR_USM._main_pool_alloc;
     A1SPR_USM._main_pool_free; A1SPR_USM._main_pool_realloc;
     A1SPR_USM._main_pool_push_state; A1SPR_USM._main_pool_pop_state]
    (rank3_us_owner_call_closure 5) = [] /\
  identifiers_in
    [A1SPR_JPM._main_pool_init; A1SPR_JPM._main_pool_alloc;
     A1SPR_JPM._main_pool_free; A1SPR_JPM._main_pool_realloc;
     A1SPR_JPM._main_pool_push_state; A1SPR_JPM._main_pool_pop_state]
    (rank3_jp_owner_call_closure 5) = [].

Theorem canonical_owner_closure_does_not_rewind_main_pool :
  CanonicalOwnerMainPoolEpochIsolationClaim.
Proof.
  unfold CanonicalOwnerMainPoolEpochIsolationClaim.
  vm_compute. split; reflexivity.
Qed.

Definition SurfacePoolGlobalUseClaim : Prop :=
  internal_statement_mention_sites A1SPR_USS._sSurfaceNodePool
    rank3_us_definitions =
      [A1SPR_USS._alloc_surface_node; A1SPR_USS._alloc_surface_pools] /\
  internal_statement_mention_sites A1SPR_USS._sSurfacePool
    rank3_us_definitions =
      [A1SPR_USS._alloc_surface; A1SPR_USS._alloc_surface_pools] /\
  internal_statement_mention_sites A1SPR_JPS._sSurfaceNodePool
    rank3_jp_definitions =
      [A1SPR_JPS._alloc_surface_node; A1SPR_JPS._alloc_surface_pools] /\
  internal_statement_mention_sites A1SPR_JPS._sSurfacePool
    rank3_jp_definitions =
      [A1SPR_JPS._alloc_surface; A1SPR_JPS._alloc_surface_pools] /\
  internal_function_address_sites A1SPR_USS._sSurfaceNodePool
    rank3_us_definitions = [] /\
  internal_function_address_sites A1SPR_USS._sSurfacePool
    rank3_us_definitions = [] /\
  internal_function_address_sites A1SPR_JPS._sSurfaceNodePool
    rank3_jp_definitions = [] /\
  internal_function_address_sites A1SPR_JPS._sSurfacePool
    rank3_jp_definitions = [].

Theorem surface_pool_global_use_census_checked :
  SurfacePoolGlobalUseClaim.
Proof.
  unfold SurfacePoolGlobalUseClaim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Live floor projection through a protected insertion trace *)

Record ProjectedSurfaceNode : Type := {
  projected_node_index : nat;
  projected_surface_index : nat;
  projected_owner : option Area1SurfaceOwnerKind;
  projected_floor_y : Z
}.

Inductive ClassifiedSurfaceInsertion :
    PositionZ -> ProjectedSurfaceNode -> Prop :=
| InsertedStaticSurface : forall position node,
    projected_owner node = None ->
    ClassifiedSurfaceInsertion position node
| InsertedRecognizedDynamicSurface : forall position node owner,
    projected_owner node = Some owner ->
    stock_area1_dynamic_floor_candidate owner position
      (projected_floor_y node) ->
    ClassifiedSurfaceInsertion position node.

(** A trace may retain a list unchanged (including when a clear is skipped),
    insert a node whose owner/contact was classified at the query position, or
    perform the real clear.  There is deliberately no arbitrary node-copy or
    owner-mutation constructor: the first such live step is the concrete
    alias/lifecycle failure this proof is meant to expose. *)
Inductive ClassifiedSurfaceListTrace (position : PositionZ) :
    list ProjectedSurfaceNode -> list ProjectedSurfaceNode -> Prop :=
| SurfaceListFrame : forall nodes,
    ClassifiedSurfaceListTrace position nodes nodes
| SurfaceListInsert : forall nodes node,
    ClassifiedSurfaceInsertion position node ->
    ClassifiedSurfaceListTrace position nodes (node :: nodes)
| SurfaceListClear : forall nodes,
    ClassifiedSurfaceListTrace position nodes []
| SurfaceListTrans : forall first middle final,
    ClassifiedSurfaceListTrace position first middle ->
    ClassifiedSurfaceListTrace position middle final ->
    ClassifiedSurfaceListTrace position first final.

Theorem classified_surface_list_trace_preserves_provenance :
  forall position before after,
    Forall (ClassifiedSurfaceInsertion position) before ->
    ClassifiedSurfaceListTrace position before after ->
    Forall (ClassifiedSurfaceInsertion position) after.
Proof.
  intros position before after Hbefore Htrace.
  induction Htrace.
  - exact Hbefore.
  - constructor; assumption.
  - constructor.
  - apply IHHtrace2. apply IHHtrace1. exact Hbefore.
Qed.

Record LiveFloorSelection (position : PositionZ) : Type := {
  live_surface_nodes : list ProjectedSurfaceNode;
  live_selected_node : ProjectedSurfaceNode;
  live_surface_list_trace :
    ClassifiedSurfaceListTrace position [] live_surface_nodes;
  live_selected_node_in_current_list :
    In live_selected_node live_surface_nodes
}.

Definition live_floor_selection_platform {position}
    (selection : LiveFloorSelection position) :
    option Area1SurfaceOwnerKind :=
  projected_owner (live_selected_node position selection).

Theorem live_floor_selection_projects_to_stock_query :
  forall position (selection : LiveFloorSelection position),
    stock_area1_final_platform_query position
      (live_floor_selection_platform selection).
Proof.
  intros position [nodes node Htrace Hlisted].
  pose proof (classified_surface_list_trace_preserves_provenance
    position [] nodes (Forall_nil _) Htrace) as Hall.
  apply Forall_forall with (x := node) in Hall; [| exact Hlisted].
  inversion Hall as [actual_position actual_node Hstatic
    |actual_position actual_node owner Howner Hcandidate]; subst; cbn in *.
  - change (stock_area1_final_platform_query position
      (projected_owner node)).
    rewrite Hstatic. exact I.
  - change (stock_area1_final_platform_query position
      (projected_owner node)).
    rewrite Howner. exists (projected_floor_y node). exact Hcandidate.
Qed.

Theorem upper_warp_live_floor_selection_is_static_or_null_owner :
  forall position (selection : LiveFloorSelection position),
    upper_warp_contact position ->
    live_floor_selection_platform selection = None.
Proof.
  intros position selection Hwarp.
  eapply stock_upper_warp_final_query_clears_platform; [exact Hwarp |].
  exact (live_floor_selection_projects_to_stock_query position selection).
Qed.

Definition JPRank1OutsideFrameCheckedBoundary : Prop :=
  JPRank1DirectRootMachineReceipt /\
  (jp_main_pool_lo <= jp_live_surface_node_lo /\
   jp_live_surface_pool_hi <= jp_main_pool_hi /\
   jp_main_pool_hi = jp_decompression_heap_lo /\
   jp_decompression_heap_lo + 53248 = jp_audio_heap_lo /\
   jp_audio_heap_lo + 201216 = jp_audio_heap_hi) /\
  (forall root entry_sp trace,
    jp_rank1_entry_stack_misses_surface_hull entry_sp ->
    JPRank1OutsideStoreTrace root entry_sp trace ->
    Forall jp_retail_store_misses_surface_pool_hull trace).

Theorem jp_rank1_outside_frame_checked_boundary_holds :
  JPRank1OutsideFrameCheckedBoundary.
Proof.
  unfold JPRank1OutsideFrameCheckedBoundary.
  split; [exact jp_rank1_direct_root_machine_receipt_checked |].
  split; [exact jp_live_surface_ranges_are_inside_main_pool_and_below_audio |].
  exact jp_rank1_outside_trace_misses_live_surface_pools.
Qed.

(** The combined checked boundary closes the vague form of the alias claim.
    Within a live epoch, a pre-existing or type-punned main-pool pointer matters
    only when a reached defined store actually overlaps a protected interval.
    Constructing every real [LiveFloorSelection] still requires the linked
    list/query execution and exact frames for outside roots not covered by the
    existing sound/sqrtf certificate. *)
Definition Area1SurfacePoolRangeSeparationBoundary : Prop :=
  JPAcceptedSurfacePoolReceipt /\
  (forall main_block,
    live_surface_pool_epoch (jp_accepted_surface_ranges main_block)
      jp_accepted_main_pool_heads) /\
  (forall ranges before after,
    live_surface_pool_epoch ranges before ->
    LiveMainPoolEpochStep ranges before after ->
    live_surface_pool_epoch ranges after) /\
  MainPoolAllocationCallerClaim /\
  MainPoolEpochMutatorSourceClaim /\
  CanonicalOwnerMainPoolEpochIsolationClaim /\
  SurfacePoolGlobalUseClaim /\
  Area1SurfaceWriteClosureBoundary /\
  JPRank1OutsideFrameCheckedBoundary /\
  (forall ranges chunk before store_block store_offset value after,
    Mem.store chunk before store_block store_offset value = Some after ->
    ~ Mem.unchanged_on (surface_payload_byte ranges) before after ->
    store_block = surface_main_block ranges /\
    exists byte_offset,
      store_offset <= byte_offset < store_offset + size_chunk chunk /\
      ((surface_node_lo ranges <= byte_offset < surface_node_hi ranges) \/
       (surface_pool_lo ranges <= byte_offset < surface_pool_hi ranges))) /\
  (forall position (selection : LiveFloorSelection position),
    stock_area1_final_platform_query position
      (live_floor_selection_platform selection)).

Theorem area1_surface_pool_range_separation_boundary_holds :
  Area1SurfacePoolRangeSeparationBoundary.
Proof.
  unfold Area1SurfacePoolRangeSeparationBoundary.
  split; [exact jp_accepted_surface_pool_receipt_checked |].
  split; [exact jp_accepted_heads_begin_live_surface_epoch |].
  split; [exact live_main_pool_epoch_step_preserves_surface_ranges |].
  split; [exact main_pool_allocation_callers_are_exact |].
  split; [exact main_pool_epoch_mutator_source_census_checked |].
  split; [exact canonical_owner_closure_does_not_rewind_main_pool |].
  split; [exact surface_pool_global_use_census_checked |].
  split; [exact area1_surface_write_closure_boundary_holds |].
  split; [exact jp_rank1_outside_frame_checked_boundary_holds |].
  split.
  - exact first_surface_frame_failure_exposes_same_block_overlap.
  - exact live_floor_selection_projects_to_stock_query.
Qed.
