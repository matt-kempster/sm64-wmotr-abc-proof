From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** JP composite-layout receipt, compiled independently from all generated
    function/global declarations. *)
Theorem jp_composite_compatibility_audit_checked :
  JPCompositeCompatibilityAudit.
Proof. vm_compute. split; reflexivity. Qed.
