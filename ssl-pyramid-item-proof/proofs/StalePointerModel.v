(* A small provenance model for the stale-pointer cloning concern.

   The main transfer claim uses allocation epochs rather than raw addresses.
   This file makes that distinction explicit for Mario's object-reference
   fields.  If an outside slot is unloaded and later reused by an in-pyramid
   object, the raw pointer value may be equal, but the allocation epoch is not
   the outside item unless one of Mario's references preserves that old epoch.

   The generated-Clight facts in TransitionFacts establish two distinct
   points in the transition spine:

   - warp_area unloads the old area and calls load_area for the destination
     before it calls init_mario_after_warp;
   - init_mario then clears heldObj/riddenObj/usedObj, and
     init_mario_after_warp assigns interactObj/usedObj from the destination
     spawn object after the init_mario call.

   So "survives the Pyramid load" and "survives until Pyramid play resumes"
   are different claims.  The former has a model witness below; the latter is
   the already-proved post_pyramid_warp_reference_shape theorem.
 *)

From Coq Require Import Lia List ZArith.
Import ListNotations.
From compcert Require Import AST Integers Memory Values.
From SSLPyramid.Proofs Require Import Spec.

Local Open Scope Z_scope.

Inductive object_reference_origin : Type :=
| NoObjectReference
| OutsideAllocationEpoch : Z -> object_reference_origin
| DestinationSpawnObject : Z -> object_reference_origin
| OtherObjectReference : Z -> object_reference_origin.

Record mario_reference_origins := {
  ref_interact_object : object_reference_origin;
  ref_held_object : object_reference_origin;
  ref_used_object : object_reference_origin;
  ref_ridden_object : object_reference_origin
}.

Definition mario_reference_origin_list
    (refs : mario_reference_origins) : list object_reference_origin :=
  [ref_interact_object refs;
   ref_held_object refs;
   ref_used_object refs;
   ref_ridden_object refs].

Definition stale_outside_reference
    (before : mem) (pool_block : block)
    (refs : mario_reference_origins) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    In (OutsideAllocationEpoch slot) (mario_reference_origin_list refs).

Definition stale_ridden_outside_reference
    (before : mem) (pool_block : block)
    (refs : mario_reference_origins) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    ref_ridden_object refs = OutsideAllocationEpoch slot.

Definition post_pyramid_warp_reference_shape
    (destination_spawn_slot : Z) (refs : mario_reference_origins) : Prop :=
  ref_interact_object refs = DestinationSpawnObject destination_spawn_slot /\
  ref_held_object refs = NoObjectReference /\
  ref_used_object refs = DestinationSpawnObject destination_spawn_slot /\
  ref_ridden_object refs = NoObjectReference.

Record pyramid_load_window_reference_origins := {
  refs_before_area_unload : mario_reference_origins;
  refs_after_pyramid_load_before_mario_init : mario_reference_origins;
  refs_after_mario_reinit : mario_reference_origins
}.

Definition outside_held_grab_refs
    (outside_slot : Z) : mario_reference_origins := {|
  ref_interact_object := NoObjectReference;
  ref_held_object := OutsideAllocationEpoch outside_slot;
  ref_used_object := NoObjectReference;
  ref_ridden_object := NoObjectReference
|}.

Definition outside_shell_ride_refs
    (outside_slot : Z) : mario_reference_origins := {|
  ref_interact_object := OutsideAllocationEpoch outside_slot;
  ref_held_object := NoObjectReference;
  ref_used_object := OutsideAllocationEpoch outside_slot;
  ref_ridden_object := OutsideAllocationEpoch outside_slot
|}.

Definition post_reinit_refs
    (destination_spawn_slot : Z) : mario_reference_origins := {|
  ref_interact_object := DestinationSpawnObject destination_spawn_slot;
  ref_held_object := NoObjectReference;
  ref_used_object := DestinationSpawnObject destination_spawn_slot;
  ref_ridden_object := NoObjectReference
|}.

Definition outside_held_grab_load_window
    (outside_slot destination_spawn_slot : Z)
    : pyramid_load_window_reference_origins := {|
  refs_before_area_unload := outside_held_grab_refs outside_slot;
  refs_after_pyramid_load_before_mario_init :=
    outside_held_grab_refs outside_slot;
  refs_after_mario_reinit := post_reinit_refs destination_spawn_slot
|}.

Definition outside_shell_ride_load_window
    (outside_slot destination_spawn_slot : Z)
    : pyramid_load_window_reference_origins := {|
  refs_before_area_unload := outside_shell_ride_refs outside_slot;
  refs_after_pyramid_load_before_mario_init :=
    outside_shell_ride_refs outside_slot;
  refs_after_mario_reinit := post_reinit_refs destination_spawn_slot
|}.

(* Model-only shape: this is useful for saying what a ridden-object stale
   window would look like, but the normal Pyramid object-warp route does not
   establish this shape.  The generated-code audit in TransitionFacts proves
   interact_warp calls mario_stop_riding_object first, and that helper clears
   riddenObj before interact_warp hands off to the delayed-warp path. *)

Definition stale_outside_reference_after_pyramid_load
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  stale_outside_reference before pool_block
    (refs_after_pyramid_load_before_mario_init window).

Definition stale_ridden_outside_reference_after_pyramid_load
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  stale_ridden_outside_reference before pool_block
    (refs_after_pyramid_load_before_mario_init window).

Definition technical_stale_pointer_smuggled_into_load_window
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  stale_outside_reference_after_pyramid_load before pool_block window.

Definition stale_outside_reference_aliases_live_slot
    (before after_load : mem) (pool_block : block)
    (refs : mario_reference_origins) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    slot_active after_load pool_block slot /\
    In (OutsideAllocationEpoch slot) (mario_reference_origin_list refs).

Definition stale_ridden_reference_aliases_live_slot
    (before after_load : mem) (pool_block : block)
    (refs : mario_reference_origins) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    slot_active after_load pool_block slot /\
    ref_ridden_object refs = OutsideAllocationEpoch slot.

Definition technical_stale_slot_alias_during_load
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  stale_outside_reference_aliases_live_slot before after_load pool_block
    (refs_after_pyramid_load_before_mario_init window).

Definition no_technical_stale_pointer_after_mario_reinit
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  ~ stale_outside_reference before pool_block
      (refs_after_mario_reinit window).

Definition object_allocation_active_flags_value :=
  Int.repr 257.

Definition same_slot_pyramid_allocation_store_trace
    (allocation_start after_area_store after_load : mem)
    (pool_block : block) (slot : Z) : Prop :=
  Mem.store Mint8signed allocation_start pool_block
    (object_field_address slot object_active_area_offset)
    (Vint (Int.repr ssl_pyramid_area)) =
    Some after_area_store /\
  Mem.store Mint16signed after_area_store pool_block
    (object_field_address slot object_active_flags_offset)
    (Vint object_allocation_active_flags_value) =
    Some after_load.

Definition free_list_slots : Type := list Z.

Definition deallocate_pushes_slot_to_free_list
    (before : free_list_slots) (slot : Z)
    (after : free_list_slots) : Prop :=
  after = slot :: before.

Definition allocation_pops_free_list_head
    (before : free_list_slots) (slot : Z)
    (after : free_list_slots) : Prop :=
  before = slot :: after.

Definition allocation_count_reaches_watched_slot
    (free_list : free_list_slots) (watched_slot : Z)
    (allocation_count : nat) : Prop :=
  exists newer_slots older_slots,
    free_list = newer_slots ++ watched_slot :: older_slots /\
    (length newer_slots < allocation_count)%nat.

Theorem deallocate_push_then_first_allocation_reuses_same_slot :
  forall before after_push after_pop watched_slot popped_slot,
    deallocate_pushes_slot_to_free_list
      before watched_slot after_push ->
    allocation_pops_free_list_head
      after_push popped_slot after_pop ->
    popped_slot = watched_slot.
Proof.
  intros before after_push after_pop watched_slot popped_slot Hpush Hpop.
  unfold deallocate_pushes_slot_to_free_list,
    allocation_pops_free_list_head in *.
  subst after_push.
  inversion Hpop.
  reflexivity.
Qed.

Theorem deallocated_slot_at_head_is_reached_by_one_allocation :
  forall before after_push watched_slot,
    deallocate_pushes_slot_to_free_list
      before watched_slot after_push ->
    allocation_count_reaches_watched_slot after_push watched_slot 1%nat.
Proof.
  intros before after_push watched_slot Hpush.
  unfold deallocate_pushes_slot_to_free_list in Hpush.
  subst after_push.
  unfold allocation_count_reaches_watched_slot.
  exists [], before.
  split; [reflexivity | cbn; lia].
Qed.

Theorem watched_slot_under_newer_free_slots_needs_enough_allocations :
  forall newer_slots older_slots watched_slot allocation_count,
    (length newer_slots < allocation_count)%nat ->
    allocation_count_reaches_watched_slot
      (newer_slots ++ watched_slot :: older_slots)
      watched_slot allocation_count.
Proof.
  intros newer_slots older_slots watched_slot allocation_count Hcount.
  unfold allocation_count_reaches_watched_slot.
  exists newer_slots, older_slots.
  split; [reflexivity | exact Hcount].
Qed.

Record same_slot_pyramid_allocation_receipt
    (allocation_start after_area_store after_load : mem)
    (pool_block : block) (free_list : free_list_slots)
    (slot : Z) (allocation_count : nat) : Prop := {
  receipt_allocation_count_reaches_slot :
    allocation_count_reaches_watched_slot
      free_list slot allocation_count;
  receipt_area_store :
    Mem.store Mint8signed allocation_start pool_block
      (object_field_address slot object_active_area_offset)
      (Vint (Int.repr ssl_pyramid_area)) =
      Some after_area_store;
  receipt_active_flags_store :
    Mem.store Mint16signed after_area_store pool_block
      (object_field_address slot object_active_flags_offset)
      (Vint object_allocation_active_flags_value) =
      Some after_load
}.

Theorem same_slot_pyramid_allocation_store_trace_from_receipt :
  forall allocation_start after_area_store after_load
      pool_block free_list slot allocation_count,
    same_slot_pyramid_allocation_receipt
      allocation_start after_area_store after_load
      pool_block free_list slot allocation_count ->
    same_slot_pyramid_allocation_store_trace
      allocation_start after_area_store after_load pool_block slot.
Proof.
  intros allocation_start after_area_store after_load
    pool_block free_list slot allocation_count Hreceipt.
  destruct Hreceipt as [_ Harea Hactive].
  split; assumption.
Qed.

Definition slot_active_as_pyramid_object
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  slot_active memory pool_block slot /\
  slot_belongs_to_area memory pool_block slot ssl_pyramid_area.

Definition stale_outside_reference_aliases_pyramid_slot
    (before after_load : mem) (pool_block : block)
    (refs : mario_reference_origins) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    slot_active_as_pyramid_object after_load pool_block slot /\
    In (OutsideAllocationEpoch slot) (mario_reference_origin_list refs).

Definition technical_stale_pyramid_slot_alias_during_load
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  stale_outside_reference_aliases_pyramid_slot before after_load pool_block
    (refs_after_pyramid_load_before_mario_init window).

Record technical_stale_window_counterexample
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  technical_stale_window_has_stale_pointer :
    technical_stale_pointer_smuggled_into_load_window
      before pool_block window;
  technical_stale_window_is_cleared_by_reinit :
    no_technical_stale_pointer_after_mario_reinit
      before pool_block window
}.

Record technical_stale_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  technical_stale_reuse_has_stale_window :
    technical_stale_window_counterexample before pool_block window;
  technical_stale_reuse_aliases_live_slot :
    technical_stale_slot_alias_during_load
      before after_load pool_block window
}.

Record technical_stale_pyramid_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  technical_stale_pyramid_reuse_base :
    technical_stale_slot_reuse_counterexample
      before after_load pool_block window;
  technical_stale_pyramid_reuse_aliases_pyramid_slot :
    technical_stale_pyramid_slot_alias_during_load
      before after_load pool_block window
}.

Record ridden_technical_stale_window_counterexample
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  ridden_technical_stale_window_base :
    technical_stale_window_counterexample before pool_block window;
  ridden_technical_stale_window_has_ridden_pointer :
    stale_ridden_outside_reference_after_pyramid_load
      before pool_block window
}.

Record ridden_technical_stale_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  ridden_technical_stale_reuse_base :
    technical_stale_slot_reuse_counterexample
      before after_load pool_block window;
  ridden_technical_stale_reuse_aliases_ridden_slot :
    stale_ridden_reference_aliases_live_slot
      before after_load pool_block
      (refs_after_pyramid_load_before_mario_init window)
}.

Record ridden_technical_stale_pyramid_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  ridden_technical_stale_pyramid_reuse_base :
    ridden_technical_stale_slot_reuse_counterexample
      before after_load pool_block window;
  ridden_technical_stale_pyramid_reuse_aliases_pyramid_slot :
    technical_stale_pyramid_slot_alias_during_load
      before after_load pool_block window
}.

Theorem same_slot_pyramid_allocation_store_trace_gives_pyramid_live_slot :
  forall allocation_start after_area_store after_load pool_block slot,
    same_slot_pyramid_allocation_store_trace
      allocation_start after_area_store after_load pool_block slot ->
    slot_active_as_pyramid_object after_load pool_block slot.
Proof.
  intros allocation_start after_area_store after_load pool_block slot Hstores.
  destruct Hstores as (Harea_store & Hactive_store).
  split.
  - exists (Int.sign_ext 16 object_allocation_active_flags_value).
    split.
    + unfold slot_active, object_allocation_active_flags_value.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Hactive_store).
      reflexivity.
    + unfold object_allocation_active_flags_value.
      vm_compute.
      discriminate.
  - unfold slot_belongs_to_area.
    rewrite (Mem.load_store_other
      Mint16signed after_area_store pool_block
      (object_field_address slot object_active_flags_offset)
      (Vint object_allocation_active_flags_value) after_load
      Hactive_store
      Mint8signed pool_block
      (object_field_address slot object_active_area_offset)).
    + rewrite (Mem.load_store_same _ _ _ _ _ _ Harea_store).
      unfold ssl_pyramid_area.
      vm_compute.
      reflexivity.
    + right; left.
      unfold object_field_address, object_active_area_offset,
        object_active_flags_offset, object_slot_size.
      simpl.
      lia.
Qed.

Theorem post_pyramid_warp_shape_has_no_stale_outside_reference :
  forall before pool_block destination_spawn_slot refs,
    post_pyramid_warp_reference_shape destination_spawn_slot refs ->
    ~ stale_outside_reference before pool_block refs.
Proof.
  intros before pool_block destination_spawn_slot refs Hshape Hstale.
  destruct Hshape as (Hinteract & Hheld & Hused & Hridden).
  destruct Hstale as (slot & _ & Hin).
  unfold mario_reference_origin_list in Hin.
  destruct refs as [interact held used ridden].
  cbn in *.
  subst interact held used ridden.
  repeat
    (destruct Hin as [Hin | Hin];
     [discriminate |]).
  contradiction.
Qed.

Theorem post_reinit_refs_have_post_pyramid_warp_shape :
  forall destination_spawn_slot,
    post_pyramid_warp_reference_shape destination_spawn_slot
      (post_reinit_refs destination_spawn_slot).
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem outside_held_grab_can_leave_stale_reference_across_pyramid_load :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window outside_slot destination_spawn_slot /\
      stale_outside_reference_after_pyramid_load
        before pool_block window /\
      ~ stale_outside_reference before pool_block
          (refs_after_mario_reinit window).
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  exists (outside_held_grab_load_window
            outside_slot destination_spawn_slot).
  split.
  - reflexivity.
  - split.
    + exists outside_slot.
      split; [exact Houtside |].
      unfold mario_reference_origin_list,
        outside_held_grab_load_window, outside_held_grab_refs.
      simpl.
      right; left; reflexivity.
    + apply post_pyramid_warp_shape_has_no_stale_outside_reference
        with (destination_spawn_slot := destination_spawn_slot).
      apply post_reinit_refs_have_post_pyramid_warp_shape.
Qed.

Theorem held_grab_constructs_technical_stale_window_counterexample :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window outside_slot destination_spawn_slot /\
      technical_stale_window_counterexample
        before pool_block window.
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  destruct
    (outside_held_grab_can_leave_stale_reference_across_pyramid_load
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hstale & Hclean).
  exists window.
  split; [exact Hwindow |].
  constructor; [exact Hstale | exact Hclean].
Qed.

Theorem outside_shell_ride_can_leave_ridden_stale_reference_across_pyramid_load :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window outside_slot destination_spawn_slot /\
      stale_outside_reference_after_pyramid_load
        before pool_block window /\
      stale_ridden_outside_reference_after_pyramid_load
        before pool_block window /\
      ~ stale_outside_reference before pool_block
          (refs_after_mario_reinit window).
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  exists (outside_shell_ride_load_window
            outside_slot destination_spawn_slot).
  split; [reflexivity |].
  split.
  - exists outside_slot.
    split; [exact Houtside |].
    unfold mario_reference_origin_list,
      outside_shell_ride_load_window, outside_shell_ride_refs.
    simpl.
    left; reflexivity.
  - split.
    + exists outside_slot.
      split; [exact Houtside |].
      unfold outside_shell_ride_load_window, outside_shell_ride_refs.
      simpl.
      reflexivity.
    + apply post_pyramid_warp_shape_has_no_stale_outside_reference
        with (destination_spawn_slot := destination_spawn_slot).
      apply post_reinit_refs_have_post_pyramid_warp_shape.
Qed.

Theorem shell_ride_constructs_ridden_technical_stale_window_counterexample :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window outside_slot destination_spawn_slot /\
      ridden_technical_stale_window_counterexample
        before pool_block window.
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  destruct
    (outside_shell_ride_can_leave_ridden_stale_reference_across_pyramid_load
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hstale & Hridden & Hclean).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - constructor; [exact Hstale | exact Hclean].
  - exact Hridden.
Qed.

Theorem held_grab_stale_reference_would_alias_reused_slot_after_load :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window outside_slot destination_spawn_slot /\
      stale_outside_reference_aliases_live_slot
        before after_load pool_block
        (refs_after_pyramid_load_before_mario_init window).
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  exists (outside_held_grab_load_window
            outside_slot destination_spawn_slot).
  split; [reflexivity |].
  exists outside_slot.
  split; [exact Houtside |].
  split; [exact Hactive_after_load |].
  unfold mario_reference_origin_list,
    outside_held_grab_load_window, outside_held_grab_refs.
  simpl.
  right; left; reflexivity.
Qed.

Theorem ridden_shell_stale_reference_would_alias_reused_slot_after_load :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window outside_slot destination_spawn_slot /\
      stale_outside_reference_aliases_live_slot
        before after_load pool_block
        (refs_after_pyramid_load_before_mario_init window) /\
      stale_ridden_reference_aliases_live_slot
        before after_load pool_block
        (refs_after_pyramid_load_before_mario_init window).
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  exists (outside_shell_ride_load_window
            outside_slot destination_spawn_slot).
  split; [reflexivity |].
  split.
  - exists outside_slot.
    split; [exact Houtside |].
    split; [exact Hactive_after_load |].
    unfold mario_reference_origin_list,
      outside_shell_ride_load_window, outside_shell_ride_refs.
    simpl.
    left; reflexivity.
  - exists outside_slot.
    split; [exact Houtside |].
    split; [exact Hactive_after_load |].
    unfold outside_shell_ride_load_window, outside_shell_ride_refs.
    simpl.
    reflexivity.
Qed.

Theorem held_grab_stale_slot_alias_is_conditional_on_reuse :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window outside_slot destination_spawn_slot /\
      technical_stale_pointer_smuggled_into_load_window
        before pool_block window /\
      technical_stale_slot_alias_during_load
        before after_load pool_block window /\
      no_technical_stale_pointer_after_mario_reinit
        before pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (outside_held_grab_can_leave_stale_reference_across_pyramid_load
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hstale & Hclean).
  exists window.
  split; [exact Hwindow |].
  split; [exact Hstale |].
  split.
  - subst window.
    unfold technical_stale_slot_alias_during_load.
    destruct
      (held_grab_stale_reference_would_alias_reused_slot_after_load
         before after_load pool_block outside_slot destination_spawn_slot
         Houtside Hactive_after_load)
      as (alias_window & Halias_window & Halias).
    inversion Halias_window.
    subst alias_window.
    exact Halias.
  - exact Hclean.
Qed.

Theorem held_grab_constructs_technical_slot_reuse_counterexample :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window outside_slot destination_spawn_slot /\
      technical_stale_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (held_grab_stale_slot_alias_is_conditional_on_reuse
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hstale & Halias & Hclean).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - constructor; [exact Hstale | exact Hclean].
  - exact Halias.
Qed.

Theorem held_grab_constructs_technical_pyramid_slot_reuse_counterexample
    :
  forall before allocation_start after_area_store after_load
      pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    same_slot_pyramid_allocation_store_trace
      allocation_start after_area_store after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window outside_slot destination_spawn_slot /\
      technical_stale_pyramid_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before allocation_start after_area_store after_load
    pool_block outside_slot destination_spawn_slot Houtside Hstores.
  pose proof
    (same_slot_pyramid_allocation_store_trace_gives_pyramid_live_slot
       allocation_start after_area_store after_load pool_block outside_slot
       Hstores) as Hpyramid_live.
  destruct Hpyramid_live as (Hactive_after_load & Harea_after_load).
  destruct
    (held_grab_constructs_technical_slot_reuse_counterexample
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hbase).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hbase.
  - subst window.
    exists outside_slot.
    split; [exact Houtside |].
    split.
    + split; [exact Hactive_after_load | exact Harea_after_load].
    + unfold mario_reference_origin_list, outside_held_grab_load_window,
        outside_held_grab_refs.
      simpl.
      right; left; reflexivity.
Qed.

Theorem ridden_shell_stale_slot_alias_is_conditional_on_reuse :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window outside_slot destination_spawn_slot /\
      technical_stale_pointer_smuggled_into_load_window
        before pool_block window /\
      technical_stale_slot_alias_during_load
        before after_load pool_block window /\
      stale_ridden_reference_aliases_live_slot
        before after_load pool_block
        (refs_after_pyramid_load_before_mario_init window) /\
      no_technical_stale_pointer_after_mario_reinit
        before pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (outside_shell_ride_can_leave_ridden_stale_reference_across_pyramid_load
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hstale & _ & Hclean).
  destruct
    (ridden_shell_stale_reference_would_alias_reused_slot_after_load
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (alias_window & Halias_window & Halias & Hridden_alias).
  exists window.
  split; [exact Hwindow |].
  split; [exact Hstale |].
  subst window.
  inversion Halias_window.
  subst alias_window.
  split; [exact Halias |].
  split; [exact Hridden_alias | exact Hclean].
Qed.

Theorem shell_ride_constructs_ridden_technical_slot_reuse_counterexample :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window outside_slot destination_spawn_slot /\
      ridden_technical_stale_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (ridden_shell_stale_slot_alias_is_conditional_on_reuse
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hstale & Halias & Hridden_alias & Hclean).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - constructor.
    + constructor; [exact Hstale | exact Hclean].
    + exact Halias.
  - exact Hridden_alias.
Qed.

Theorem shell_ride_constructs_ridden_technical_pyramid_slot_reuse_counterexample
    :
  forall before allocation_start after_area_store after_load
      pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    same_slot_pyramid_allocation_store_trace
      allocation_start after_area_store after_load pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window outside_slot destination_spawn_slot /\
      ridden_technical_stale_pyramid_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before allocation_start after_area_store after_load
    pool_block outside_slot destination_spawn_slot Houtside Hstores.
  pose proof
    (same_slot_pyramid_allocation_store_trace_gives_pyramid_live_slot
       allocation_start after_area_store after_load pool_block outside_slot
       Hstores) as Hpyramid_live.
  destruct Hpyramid_live as (Hactive_after_load & Harea_after_load).
  destruct
    (shell_ride_constructs_ridden_technical_slot_reuse_counterexample
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hbase).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hbase.
  - subst window.
    exists outside_slot.
    split; [exact Houtside |].
    split.
    + split; [exact Hactive_after_load | exact Harea_after_load].
    + unfold mario_reference_origin_list, outside_shell_ride_load_window,
        outside_shell_ride_refs.
      simpl.
      left; reflexivity.
Qed.

Theorem deactivated_raw_slot_reuse_is_not_continuous_transfer :
  forall before barrier after pool_block slot,
    outside_live_slot before pool_block slot ->
    slot_deactivated barrier pool_block slot ->
    ~ (slot_active barrier pool_block slot /\
       slot_active after pool_block slot).
Proof.
  intros before barrier after pool_block slot Houtside Hdeactivated Hreuse.
  destruct Hreuse as (Hactive_barrier & _).
  destruct Hactive_barrier as (flags & Hload & Hnonzero).
  rewrite Hdeactivated in Hload.
  inversion Hload.
  apply Hnonzero.
  symmetry.
  assumption.
Qed.
