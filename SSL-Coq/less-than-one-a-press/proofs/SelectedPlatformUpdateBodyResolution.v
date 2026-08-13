(** Pin the raw-Object final-query receipt to the exact
    [update_mario_platform] bodies resolved by both selected Clight targets.

    This closes a source/body-selection ambiguity only.  It does not prove
    that a particular SSL Area 1 execution reaches the function, that its
    non-null branch completes, or that the sampled Object cells and pointer
    survive to the next collision without alias or external-frame writes. *)

From Coq Require Import Bool List.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Generated Require Import
  jp_platform_displacement us_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  Area1QueryScheduleClosure CleanedClightPrograms GameTypes
  JPPlatformUpdateCleanedReceipt
  SelectedClightTarget SuccessfulMakeProgramResolution
  USPlatformUpdateRepairReceipt USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection.
From LessThanOneAPress.Proofs Require Import USWholeASTTagRepair.

Theorem us_selected_platform_update_resolves_exact_body :
  exists platform_update_block,
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target VersionUS))
      us_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr
      (Clight.globalenv (selected_clight_target VersionUS))
      platform_update_block =
        Some (Internal us_platform_displacement.f_update_mario_platform).
Proof.
  change (exists platform_update_block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr (Clight.globalenv us_viewport_repaired_program)
      platform_update_block =
        Some (Internal us_platform_displacement.f_update_mario_platform)).
  eapply program_definitions_resolve_internal_globalenv.
  - exact us_viewport_repaired_program_definitions_checked.
  - exact us_viewport_repaired_definition_names_norepet.
  - exact us_platform_update_repaired_definition_member.
Qed.

Theorem jp_selected_platform_update_resolves_exact_body :
  exists platform_update_block,
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target VersionJP))
      jp_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr
      (Clight.globalenv (selected_clight_target VersionJP))
      platform_update_block =
        Some (Internal jp_platform_displacement.f_update_mario_platform).
Proof.
  change (exists platform_update_block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr (Clight.globalenv jp_official_cleaned_slice)
      platform_update_block =
        Some (Internal jp_platform_displacement.f_update_mario_platform)).
  exact jp_platform_update_resolves_exact_body.
Qed.

Lemma us_platform_update_raw_query_prefix_checked :
  contains_final_query_from_raw_mario_object_prefix_s
    us_platform_displacement._gMarioObject
    us_platform_displacement._rawData
    us_platform_displacement._asF32
    us_platform_displacement._find_floor
    us_platform_displacement._marioX
    us_platform_displacement._marioY
    us_platform_displacement._marioZ
    (fn_body us_platform_displacement.f_update_mario_platform) = true.
Proof.
  pose proof area1_final_query_overwrite_source_checked as Hsource.
  unfold area1_final_query_overwrite_source_claim in Hsource.
  tauto.
Qed.

Lemma jp_platform_update_raw_query_prefix_checked :
  contains_final_query_from_raw_mario_object_prefix_s
    jp_platform_displacement._gMarioObject
    jp_platform_displacement._rawData
    jp_platform_displacement._asF32
    jp_platform_displacement._find_floor
    jp_platform_displacement._marioX
    jp_platform_displacement._marioY
    jp_platform_displacement._marioZ
    (fn_body jp_platform_displacement.f_update_mario_platform) = true.
Proof.
  pose proof area1_final_query_overwrite_source_checked as Hsource.
  unfold area1_final_query_overwrite_source_claim in Hsource.
  tauto.
Qed.

Definition selected_platform_update_body_query_receipt : Prop :=
  (exists platform_update_block,
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target VersionUS))
      us_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr
      (Clight.globalenv (selected_clight_target VersionUS))
      platform_update_block =
        Some (Internal us_platform_displacement.f_update_mario_platform) /\
    contains_final_query_from_raw_mario_object_prefix_s
      us_platform_displacement._gMarioObject
      us_platform_displacement._rawData
      us_platform_displacement._asF32
      us_platform_displacement._find_floor
      us_platform_displacement._marioX
      us_platform_displacement._marioY
      us_platform_displacement._marioZ
      (fn_body us_platform_displacement.f_update_mario_platform) = true) /\
  (exists platform_update_block,
    Genv.find_symbol
      (Clight.globalenv (selected_clight_target VersionJP))
      jp_platform_displacement._update_mario_platform =
        Some platform_update_block /\
    Genv.find_funct_ptr
      (Clight.globalenv (selected_clight_target VersionJP))
      platform_update_block =
        Some (Internal jp_platform_displacement.f_update_mario_platform) /\
    contains_final_query_from_raw_mario_object_prefix_s
      jp_platform_displacement._gMarioObject
      jp_platform_displacement._rawData
      jp_platform_displacement._asF32
      jp_platform_displacement._find_floor
      jp_platform_displacement._marioX
      jp_platform_displacement._marioY
      jp_platform_displacement._marioZ
      (fn_body jp_platform_displacement.f_update_mario_platform) = true).

Theorem selected_platform_update_body_query_receipt_checked :
  selected_platform_update_body_query_receipt.
Proof.
  unfold selected_platform_update_body_query_receipt.
  split.
  - destruct us_selected_platform_update_resolves_exact_body as
      [platform_update_block [Hsymbol Hbody]].
    exists platform_update_block. split; [exact Hsymbol |].
    split; [exact Hbody |].
    exact us_platform_update_raw_query_prefix_checked.
  - destruct jp_selected_platform_update_resolves_exact_body as
      [platform_update_block [Hsymbol Hbody]].
    exists platform_update_block. split; [exact Hsymbol |].
    split; [exact Hbody |].
    exact jp_platform_update_raw_query_prefix_checked.
Qed.
