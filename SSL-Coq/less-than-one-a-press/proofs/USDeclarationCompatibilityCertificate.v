From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** US global-variable and function-declaration receipt.  The audit itself
    shares one source list and one normalized definition map. *)
Theorem us_declaration_compatibility_audit_checked :
  USDeclarationCompatibilityAudit.
Proof. vm_compute. repeat split; reflexivity. Qed.
