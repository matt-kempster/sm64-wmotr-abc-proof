(** Concrete syntax/global audit for the selected official-cleaned JP target.

    Only the five globals in [jp_retail_state_global_identifiers] are needed
    here.  Their focused source receipts avoid reducing the complete Area-1
    binding record or the full linked definition map. *)

From Coq Require Import List.
From compcert Require Import AST Clight Globalenvs.
From LessThanOneAPress.Proofs Require Import
  GameTypes ClightRefinement CleanedClightPrograms SelectedClightTarget
  JPArea1SymbolGameInitReceipt
  JPArea1SymbolMarioObjectReceipt
  JPArea1SymbolMarioStatesReceipt
  JPArea1SymbolObjectPoolReceipt
  JPSelectedRuntimeTaskStart.

Theorem jp_selected_target_core_symbols_checked :
  forall projection,
    projection_version projection = VersionJP ->
    projection_program projection = jp_official_cleaned_slice ->
    SelectedTargetCoreSymbolsObligation projection.
Proof.
  intros projection Hversion Hprogram id Hin.
  rewrite Hversion in Hin.
  cbn in Hin.
  rewrite Hprogram.
  destruct Hin as [<- | Hin].
  - exact jp_official_area1_state_storage_symbol_exists.
  - destruct Hin as [<- | Hin].
    + exact jp_official_area1_object_pool_symbol_exists.
    + destruct Hin as [<- | Hin].
      * exact jp_official_area1_mario_object_pointer_symbol_exists.
      * destruct Hin as [<- | Hin].
        -- exact jp_official_area1_controller_storage_symbol_exists.
        -- destruct Hin as [<- | Hin].
           ++ exact jp_official_player1_controller_pointer_symbol_exists.
           ++ contradiction.
Qed.

Theorem jp_selected_target_audit_transport_checked :
  forall projection,
    projection_version projection = VersionJP ->
    projection_program projection = jp_official_cleaned_slice ->
    SelectedTargetAuditTransportObligation projection.
Proof.
  intros projection Hversion Hprogram.
  unfold SelectedTargetAuditTransportObligation.
  rewrite Hversion.
  split.
  - exact Hprogram.
  - split.
    + now apply jp_selected_target_syntax_audit_checked.
    + now apply jp_selected_target_core_symbols_checked.
Qed.

(** For the selected JP program, construction, source identity refinement,
    and the concrete syntax/global audit are all discharged.  Consequently
    only the generic target-execution refinement remains to inhabit the full
    selected-target boundary. *)
Theorem jp_selected_target_refinement_from_target_clight :
  forall projection,
    projection_version projection = VersionJP ->
    projection_program projection = jp_official_cleaned_slice ->
    TargetClightRefinementObligation projection ->
    SelectedTargetClightRefinementObligation projection.
Proof.
  intros projection Hversion Hprogram Htarget.
  unfold SelectedTargetClightRefinementObligation.
  split.
  - apply selected_clight_observation_projection_checked.
    rewrite Hversion. cbn. exact Hprogram.
  - split.
    + now apply jp_selected_target_source_refinement_checked.
    + split.
      * now apply jp_selected_target_audit_transport_checked.
      * exact Htarget.
Qed.
