From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** Whole-body scan for the area translation unit.  Kept separate so the VM
    releases its generated-statement graph before the cutscene scan starts. *)
Theorem us_area_viewport_affected_globals_checked :
  globals_mentioning_any us_area_viewport_tag_family us_area.global_definitions =
    us_expected_area_viewport_affected_globals.
Proof. vm_compute. reflexivity. Qed.
