From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  CompositeLayoutRefinement USAreaViewportReferenceCertificate
  USCutsceneViewportReferenceCertificate.

(** Syntactic whole-body receipts for the US viewport tag repair.  These are
    intentionally separate from the cheap layout receipts: they traverse the
    generated statements of two translation units and therefore have a very
    different clean-build cost. *)

Theorem us_affected_viewport_globals_audit_checked :
  USAffectedViewportGlobalsAudit.
Proof.
  split.
  - exact us_area_viewport_affected_globals_checked.
  - exact us_cutscene_viewport_affected_globals_checked.
Qed.
