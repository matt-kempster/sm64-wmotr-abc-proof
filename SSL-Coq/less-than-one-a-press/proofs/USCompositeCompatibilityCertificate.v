From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** US composite-layout receipt, compiled independently from all generated
    function/global declarations. *)
Theorem us_composite_compatibility_audit_checked :
  USCompositeCompatibilityAudit.
Proof. vm_compute. split; reflexivity. Qed.
