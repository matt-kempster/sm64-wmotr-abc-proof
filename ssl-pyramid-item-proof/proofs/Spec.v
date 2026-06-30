(* Audited vocabulary for the eventual impossibility theorem.

   Object identity is allocation-epoch identity: an item crosses the boundary
   only if its gObjectPool slot remains continuously active through the
   post-unload / pre-area-2-load barrier. If the slot is deactivated and later
   reused, the later occupant is a new object even though its address is equal.

   This deliberately separates three things that are easy to conflate:

   - a gameplay item identity: a live outside-area gObjectPool allocation epoch;
   - a gameplay-usable transfer: that same allocation epoch remains active
     through the Pyramid unload/load barrier and into the later state;
   - a stale raw/Mario pointer: a reference field can still contain the old
     slot address or provenance during a short load window even though the
     object allocation epoch has been deactivated. That is a technical
     stale-pointer phenomenon, not by itself a usable item transfer.
 *)

From Coq Require Import ZArith.
From compcert Require Import AST Integers Memory Values.

Local Open Scope Z_scope.

Definition object_pool_capacity : Z := 240.
Definition object_slot_size : Z := 608.
Definition object_active_area_offset : Z := 25.
Definition object_active_flags_offset : Z := 116.

Definition warp_dest_type_offset : Z := 0.
Definition warp_dest_level_offset : Z := 1.
Definition warp_dest_area_offset : Z := 2.
Definition warp_dest_node_offset : Z := 3.

Definition level_ssl : Z := 8.
Definition ssl_outside_area : Z := 1.
Definition ssl_pyramid_area : Z := 2.
Definition warp_type_change_area : Z := 2.

Definition valid_object_slot (slot : Z) : Prop :=
  0 <= slot < object_pool_capacity.

Definition object_field_address (slot field_offset : Z) : Z :=
  slot * object_slot_size + field_offset.

Definition slot_active (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  exists flags,
    Mem.load Mint16signed memory pool_block
      (object_field_address slot object_active_flags_offset) =
      Some (Vint flags) /\
    flags <> Int.zero.

Definition slot_deactivated
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  Mem.load Mint16signed memory pool_block
    (object_field_address slot object_active_flags_offset) =
    Some (Vint Int.zero).

Definition slot_belongs_to_area
    (memory : mem) (pool_block : block) (slot area : Z) : Prop :=
  Mem.load Mint8signed memory pool_block
    (object_field_address slot object_active_area_offset) =
    Some (Vint (Int.repr area)).

Definition outside_live_slot
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  valid_object_slot slot /\
  slot_active memory pool_block slot /\
  slot_belongs_to_area memory pool_block slot 1.

Definition outside_pyramid_item_identity
    (memory : mem) (pool_block : block) (slot : Z) : Prop :=
  outside_live_slot memory pool_block slot.

Definition item_identity_continuously_enters_pyramid
    (before barrier after : mem) (pool_block : block) (slot : Z)
    : Prop :=
  outside_pyramid_item_identity before pool_block slot /\
  slot_active barrier pool_block slot /\
  slot_active after pool_block slot.

Definition no_outside_pyramid_item_identity_enters_pyramid
    (before barrier after : mem) (pool_block : block) : Prop :=
  forall slot,
    outside_pyramid_item_identity before pool_block slot ->
    ~ (slot_active barrier pool_block slot /\
       slot_active after pool_block slot).

Definition pyramid_warp_pending
    (memory : mem) (warp_dest_block current_area_block : block) : Prop :=
  Mem.load Mint8unsigned memory warp_dest_block warp_dest_type_offset =
    Some (Vint (Int.repr warp_type_change_area)) /\
  Mem.load Mint8unsigned memory warp_dest_block warp_dest_level_offset =
    Some (Vint (Int.repr level_ssl)) /\
  Mem.load Mint8unsigned memory warp_dest_block warp_dest_area_offset =
    Some (Vint (Int.repr ssl_pyramid_area)) /\
  (Mem.load Mint8unsigned memory warp_dest_block warp_dest_node_offset =
      Some (Vint (Int.repr 10)) \/
   Mem.load Mint8unsigned memory warp_dest_block warp_dest_node_offset =
      Some (Vint (Int.repr 20))) /\
  Mem.load Mint16signed memory current_area_block 0 =
    Some (Vint (Int.repr ssl_outside_area)).

Definition outside_slots_cleared_at_barrier
    (before barrier : mem) (pool_block : block) : Prop :=
  forall slot,
    outside_live_slot before pool_block slot ->
    slot_deactivated barrier pool_block slot.

Definition continuous_item_transfer
    (before barrier after : mem) (pool_block : block) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    slot_active barrier pool_block slot /\
    slot_active after pool_block slot.

Definition gameplay_usable_item_transfer
    (before barrier after : mem) (pool_block : block) : Prop :=
  exists slot,
    item_identity_continuously_enters_pyramid
      before barrier after pool_block slot.

Theorem continuous_item_transfer_iff_gameplay_usable_item_transfer :
  forall before barrier after pool_block,
    continuous_item_transfer before barrier after pool_block <->
    gameplay_usable_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block.
  unfold continuous_item_transfer, gameplay_usable_item_transfer,
    item_identity_continuously_enters_pyramid, outside_pyramid_item_identity.
  split.
  - intros (slot & Houtside & Hactive_barrier & Hactive_after).
    exists slot.
    split; [exact Houtside |].
    split; [exact Hactive_barrier | exact Hactive_after].
  - intros (slot & Houtside & Hactive_barrier & Hactive_after).
    exists slot.
    split; [exact Houtside |].
    split; [exact Hactive_barrier | exact Hactive_after].
Qed.

Theorem no_outside_item_identity_entry_forbids_gameplay_usable_transfer :
  forall before barrier after pool_block,
    no_outside_pyramid_item_identity_enters_pyramid
      before barrier after pool_block ->
    ~ gameplay_usable_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block Hnone.
  intros (slot & Houtside & Hactive_barrier & Hactive_after).
  exact (Hnone slot Houtside (conj Hactive_barrier Hactive_after)).
Qed.

Theorem no_outside_item_identity_entry_forbids_continuous_transfer :
  forall before barrier after pool_block,
    no_outside_pyramid_item_identity_enters_pyramid
      before barrier after pool_block ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block Hnone Htransfer.
  apply
    (no_outside_item_identity_entry_forbids_gameplay_usable_transfer
       before barrier after pool_block Hnone).
  apply continuous_item_transfer_iff_gameplay_usable_item_transfer.
  exact Htransfer.
Qed.

Theorem outside_slots_cleared_forbids_item_identity_entry :
  forall before barrier after pool_block,
    outside_slots_cleared_at_barrier before barrier pool_block ->
    no_outside_pyramid_item_identity_enters_pyramid
      before barrier after pool_block.
Proof.
  intros before barrier after pool_block Hcleared slot Houtside.
  intros (Hactive_barrier & _).
  specialize (Hcleared slot Houtside).
  destruct Hactive_barrier as (flags & Hload & Hnonzero).
  rewrite Hcleared in Hload.
  inversion Hload.
  apply Hnonzero.
  symmetry.
  assumption.
Qed.

Theorem deactivated_slot_forbids_same_item_identity_entry :
  forall before barrier after pool_block slot,
    outside_pyramid_item_identity before pool_block slot ->
    slot_deactivated barrier pool_block slot ->
    ~ item_identity_continuously_enters_pyramid
        before barrier after pool_block slot.
Proof.
  intros before barrier after pool_block slot _ Hdeactivated Hentry.
  destruct Hentry as (_ & Hactive_barrier & _).
  destruct Hactive_barrier as (flags & Hload & Hnonzero).
  rewrite Hdeactivated in Hload.
  inversion Hload.
  apply Hnonzero.
  symmetry.
  assumption.
Qed.

Theorem cleared_barrier_forbids_continuous_transfer :
  forall before barrier after pool_block,
    outside_slots_cleared_at_barrier before barrier pool_block ->
    ~ continuous_item_transfer before barrier after pool_block.
Proof.
  intros before barrier after pool_block Hcleared.
  intros (slot & Houtside & Hactive_barrier & _).
  specialize (Hcleared slot Houtside).
  destruct Hactive_barrier as (flags & Hload & Hnonzero).
  rewrite Hcleared in Hload.
  inversion Hload.
  apply Hnonzero.
  symmetry.
  assumption.
Qed.
