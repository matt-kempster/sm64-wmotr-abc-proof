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

From Coq Require Import List ZArith.
Import ListNotations.
From compcert Require Import AST Memory Values.
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

Definition stale_outside_reference_after_pyramid_load
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  stale_outside_reference before pool_block
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
