(* A small provenance model for the stale-pointer cloning concern.

   The main transfer claim uses allocation epochs rather than raw addresses.
   This file makes that distinction explicit for Mario's object-reference
   fields.  If an outside slot is unloaded and later reused by an in-pyramid
   object, the raw pointer value may be equal, but the allocation epoch is not
   the outside item unless one of Mario's references preserves that old epoch.

   The generated-Clight facts in TransitionFacts establish the relevant spine:
   init_mario clears heldObj/riddenObj/usedObj, and init_mario_after_warp then
   assigns interactObj/usedObj from the destination spawn object after the
   init_mario call.
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
