(** Transport the exact normalized US [_warp_level] definition through the
    targeted viewport-tag repair.  The focused boolean computation is kept
    in [USWarpLevelViewportReceipt]. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Maps.
From LessThanOneAPress.Generated Require Import us_level_update.
From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms USWholeASTTagRepair
  USWarpLevelNormalizedReceipt USWarpLevelRepairIdentity.

Lemma fixed_point_enters_mapped_list :
  forall (A : Type) (function : A -> A) (entry : A) entries,
    function entry = entry ->
    In entry entries ->
    In entry (map function entries).
Proof.
  intros A function entry entries Hfixed Hin.
  apply in_map_iff.
  exists entry. now split.
Qed.

Theorem us_warp_level_repaired_definition_member :
  In (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions.
  eapply fixed_point_enters_mapped_list.
  - exact us_warp_level_repair_is_identity.
  - exact us_warp_level_normalized_definition_member.
Qed.
