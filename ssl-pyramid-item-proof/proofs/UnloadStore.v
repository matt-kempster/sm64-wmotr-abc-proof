From Coq Require Import Lia ZArith.
From compcert Require Import AST Integers Memory Values.
From SSLPyramid.Proofs Require Import Spec.

Local Open Scope Z_scope.

Theorem store_zero_deactivates_slot :
  forall memory memory' pool_block slot,
    Mem.store Mint16signed memory pool_block
      (object_field_address slot object_active_flags_offset)
      (Vint Int.zero) = Some memory' ->
    slot_deactivated memory' pool_block slot.
Proof.
  intros memory memory' pool_block slot Hstore.
  unfold slot_deactivated.
  pose proof
    (Mem.load_store_same _ _ _ _ _ _ Hstore) as Hload.
  cbn [Val.load_result] in Hload.
  exact Hload.
Qed.

Theorem store_other_slot_preserves_deactivated :
  forall memory memory' pool_block kept_slot changed_slot,
    kept_slot <> changed_slot ->
    Mem.store Mint16signed memory pool_block
      (object_field_address changed_slot object_active_flags_offset)
      (Vint Int.zero) = Some memory' ->
    slot_deactivated memory pool_block kept_slot ->
    slot_deactivated memory' pool_block kept_slot.
Proof.
  intros memory memory' pool_block kept_slot changed_slot
    Hdifferent Hstore Hdeactivated.
  unfold slot_deactivated in *.
  rewrite
    (Mem.load_store_other _ _ _ _ _ _ Hstore).
  - exact Hdeactivated.
  - right.
    destruct (Z.lt_trichotomy kept_slot changed_slot)
      as [Hlt | [Heq | Hgt]].
    + left.
      unfold object_field_address, object_slot_size,
        object_active_flags_offset.
      simpl.
      lia.
    + contradiction.
    + right.
      unfold object_field_address, object_slot_size,
        object_active_flags_offset.
      simpl.
      lia.
Qed.
