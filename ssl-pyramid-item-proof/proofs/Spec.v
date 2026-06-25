(* Audited vocabulary for the eventual impossibility theorem.

   Object identity is allocation-epoch identity: an item crosses the boundary
   only if its gObjectPool slot remains continuously active through the
   post-unload / pre-area-2-load barrier. If the slot is deactivated and later
   reused, the later occupant is a new object even though its address is equal.
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
