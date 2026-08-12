(** Lightweight combination of the independently checked US and JP finite
    dialog/depth direct-callee inventories. *)

From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability
  DialogDepthUSFiniteInventory
  DialogDepthJPFiniteInventory.

Theorem dialog_depth_finite_inventory_obligation_closed :
  DialogDepthFiniteInventoryObligation.
Proof.
  unfold DialogDepthFiniteInventoryObligation.
  destruct us_dialog_depth_finite_inventory_closed as [Hus_set Hus_length].
  destruct jp_dialog_depth_finite_inventory_closed as [Hjp_set Hjp_length].
  repeat split; assumption.
Qed.
