From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** Whole-body scan for the cutscene translation unit.  Kept separate so the
    VM never retains it together with the area-unit scan. *)
Theorem us_cutscene_viewport_affected_globals_checked :
  globals_mentioning_any us_cutscene_viewport_tag_family
    us_mario_actions_cutscene.global_definitions =
    us_expected_cutscene_viewport_affected_globals.
Proof. vm_compute. reflexivity. Qed.
