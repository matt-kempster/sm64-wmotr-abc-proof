(** Concrete selected-target audit capstone for the repaired US program. *)

From Coq Require Import List.
From compcert Require Import AST Clight Globalenvs.
From LessThanOneAPress.Proofs Require Import
  GameTypes ClightRefinement SelectedClightTarget USRepairedSyntaxAudit
  USSelectedCoreGameInitReceipt USSelectedCoreObjectListReceipt
  USWholeASTTagRepair.

Theorem us_selected_target_core_symbols_checked :
  forall projection,
    projection_version projection = VersionUS ->
    projection_program projection = us_viewport_repaired_program ->
    SelectedTargetCoreSymbolsObligation projection.
Proof.
  intros projection Hversion Hprogram id Hin.
  rewrite Hversion in Hin. cbn in Hin. rewrite Hprogram.
  destruct Hin as [<- | Hin].
  - exact us_repaired_state_storage_symbol_exists.
  - destruct Hin as [<- | Hin].
    + exact us_repaired_object_pool_symbol_exists.
    + destruct Hin as [<- | Hin].
      * exact us_repaired_mario_object_pointer_symbol_exists.
      * destruct Hin as [<- | Hin].
        -- exact us_repaired_controller_storage_symbol_exists.
        -- destruct Hin as [<- | Hin].
           ++ exact us_repaired_player1_controller_pointer_symbol_exists.
           ++ contradiction.
Qed.

Theorem us_selected_target_audit_transport_checked :
  forall projection,
    projection_version projection = VersionUS ->
    projection_program projection = us_viewport_repaired_program ->
    SelectedTargetAuditTransportObligation projection.
Proof.
  intros projection Hversion Hprogram.
  unfold SelectedTargetAuditTransportObligation.
  rewrite Hversion. split.
  - exact Hprogram.
  - split.
    + now apply us_selected_target_syntax_audit_checked.
    + now apply us_selected_target_core_symbols_checked.
Qed.
