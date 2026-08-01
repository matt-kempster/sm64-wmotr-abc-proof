From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** JP global-variable and function-declaration receipt.  The audit itself
    shares one source list and one normalized definition map. *)
Theorem jp_declaration_compatibility_audit_checked :
  JPDeclarationCompatibilityAudit.
Proof. vm_compute. repeat split; reflexivity. Qed.
