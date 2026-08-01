From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

Import ListNotations.

(** Executable receipt for the US-only anonymous-viewport-tag collision. *)

Theorem us_viewport_collision_audit_checked : USViewportCollisionAudit.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem us_538_collision_has_different_member_names_checked :
  option_map composite_member_names
    (lookup_composite us_area.prog us_area.__538) =
      Some [us_area._vscale; us_area._vtrans] /\
  option_map composite_member_names
    (lookup_composite us_game_init.prog us_game_init.__538) =
      Some [us_game_init._cmd; us_game_init._sl; us_game_init._tl;
            us_game_init._pad; us_game_init._tile; us_game_init._sh;
            us_game_init._th].
Proof.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem us_538_collision_has_different_checked_layout :
  option_map composite_size_and_alignment
    (lookup_composite us_area.prog us_area.__538) = Some (16%Z, 2%Z) /\
  option_map composite_size_and_alignment
    (lookup_composite us_game_init.prog us_game_init.__538) = Some (8%Z, 4%Z) /\
  composite_env_tag_storage_compatible
    us_normalized_composite_env us_area.__538
    (prog_comp_env us_area.prog) = false.
Proof.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem us_normalized_slice_selects_nonviewport_538_checked :
  option_map composite_member_names
    (lookup_composite_env us_normalized_composite_env us_area.__538) =
      Some [us_game_init._cmd; us_game_init._sl; us_game_init._tl;
            us_game_init._pad; us_game_init._tile; us_game_init._sh;
            us_game_init._th].
Proof.
  vm_compute. reflexivity.
Qed.

Theorem us_viewport_wrapper_size_is_corrupted_by_538_selection_checked :
  sizeof (prog_comp_env us_area.prog)
      (Tunion us_area.__540 noattr) = 16%Z /\
  sizeof (prog_comp_env us_mario_actions_cutscene.prog)
      (Tunion us_mario_actions_cutscene.__540 noattr) = 16%Z /\
  sizeof us_normalized_composite_env
      (Tunion us_area.__540 noattr) = 8%Z.
Proof.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem us_viewport_initializer_exceeds_normalized_type_checked :
  initializer_size_bytes (gvar_init us_area.v_D_8032CF00) = 16%Z /\
  sizeof us_normalized_composite_env
    (gvar_info us_area.v_D_8032CF00) = 8%Z /\
  (sizeof us_normalized_composite_env
    (gvar_info us_area.v_D_8032CF00) <
   initializer_size_bytes (gvar_init us_area.v_D_8032CF00))%Z.
Proof.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem us_viewport_538_occurs_in_exactly_two_units_checked :
  us_viewport_538_unit_indices = [4%nat; 27%nat].
Proof.
  vm_compute. reflexivity.
Qed.
