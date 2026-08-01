From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** All-unit freshness receipt for the replacement US viewport tag.  It is
    compiled independently from declaration compatibility so the VM does not
    retain both all-unit traversals in one process. *)
Theorem us_area_viewport_fresh_tag_is_globally_unused_receipt :
  USFreshTagGloballyUnused us_area_viewport_fresh_tag.
Proof. vm_compute. repeat split; reflexivity. Qed.
