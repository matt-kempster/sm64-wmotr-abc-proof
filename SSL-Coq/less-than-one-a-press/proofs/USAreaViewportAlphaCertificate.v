From Coq Require Import ZArith.
From compcert Require Import Ctypes.
From LessThanOneAPress.Proofs Require Import CompositeLayoutRefinement.

(** Local type/composite alpha-renaming receipt for the area unit. *)
Theorem us_area_viewport_renamed_tag_layout_checked :
  built_composite_tag_layout us_area_viewport_renamed_composites
    us_area_viewport_fresh_tag = Some (16%Z, 2%Z).
Proof. vm_compute. reflexivity. Qed.

Theorem us_area_viewport_tag_alpha_renaming_layout_constructed :
  USAreaViewportTagAlphaRenamingLayoutObligation
    us_area_viewport_fresh_tag us_area_viewport_renamed_composites.
Proof.
  unfold USAreaViewportTagAlphaRenamingLayoutObligation.
  split.
  - vm_compute. congruence.
  - split.
    + unfold tag_absent_from_composites. intro Hin.
      vm_compute in Hin. intuition congruence.
    + split.
      * reflexivity.
      * destruct (built_composite_tag_layout_sound _ _ _ _
          us_area_viewport_renamed_tag_layout_checked)
          as (renamed_env & value & Hbuild & Hget & Hsize & Halign).
        exists renamed_env. split; [exact Hbuild |]. split.
        -- cbn [sizeof]. rewrite Hget, Hsize. vm_compute. reflexivity.
        -- cbn [alignof]. rewrite Hget, Halign. vm_compute. reflexivity.
Qed.
