(** Exact resolution of JP [update_mario_platform] through the official
    cleaned link.  This is a body-resolution fact, not an execution claim. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution JPWarpLevelEntryResolution.

(** [jp_platform_displacement] is cleaned unit 29 in the zero-based order. *)
Definition jp_platform_displacement_cleaned_unit : Clight.program :=
  nlist_at 29%nat jp_cleaned_units.

Theorem jp_platform_update_cleaned_unit_defmap_checked :
  (prog_defmap jp_platform_displacement_cleaned_unit) !
      jp_platform_displacement._update_mario_platform =
    Some (Gfun (Internal jp_platform_displacement.f_update_mario_platform)).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_platform_update_resolves_exact_body :
  exists platform_update_block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr (Clight.globalenv jp_official_cleaned_slice)
      platform_update_block =
        Some (Internal jp_platform_displacement.f_update_mario_platform).
Proof.
  eapply (official_link_resolves_internal_globalenv
    jp_cleaned_units jp_official_cleaned_slice
    jp_cleaned_units_official_link
    jp_platform_displacement_cleaned_unit
    jp_platform_displacement._update_mario_platform
    jp_platform_displacement.f_update_mario_platform).
  - exact (nlist_at_nIn _ 29%nat jp_cleaned_units).
  - exact jp_platform_update_cleaned_unit_defmap_checked.
Qed.
