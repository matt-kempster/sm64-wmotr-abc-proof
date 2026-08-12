(** Abstract name-domain transport through global-definition normalization. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Maps.
From LessThanOneAPress.Proofs Require Import
  ClightGlobalMemoryRefinement NormalizedClightPrograms.

Lemma prefer_global_definition_some :
  forall incumbent candidate,
    exists selected,
      prefer_global_definition (Some incumbent) candidate = Some selected.
Proof.
  intros incumbent [candidate |].
  - unfold prefer_global_definition.
    destruct (Nat.ltb (global_definition_strength incumbent)
      (global_definition_strength candidate)); eauto.
  - now exists incumbent.
Qed.

Lemma scan_global_definition_from_some_is_some :
  forall definitions query incumbent,
    exists selected,
      scan_global_definition query (Some incumbent) definitions =
        Some selected.
Proof.
  induction definitions as [| [id candidate] rest IH];
    intros query incumbent.
  - now exists incumbent.
  - change (exists selected,
      scan_global_definition query
        (if peq query id
         then prefer_global_definition (Some incumbent) (Some candidate)
         else Some incumbent) rest = Some selected).
    destruct (peq query id).
    + destruct (prefer_global_definition_some incumbent (Some candidate))
        as [next Hnext].
      rewrite Hnext. apply IH.
    + apply IH.
Qed.

Lemma source_definition_scan_is_some :
  forall definitions id definition,
    In (id, definition) definitions ->
    exists selected,
      scan_global_definition id None definitions = Some selected.
Proof.
  induction definitions as [| [head_id candidate] rest IH];
    intros id definition Hin; cbn in Hin |- *.
  - contradiction.
  - destruct Hin as [Hequal | Hin].
    + inversion Hequal; subst head_id candidate.
      destruct (peq id id) as [_ | Habsurd]; [|contradiction].
      apply scan_global_definition_from_some_is_some.
    + destruct (peq id head_id).
      * apply scan_global_definition_from_some_is_some.
      * now apply IH with (definition := definition).
Qed.

Theorem source_definition_has_normalized_name :
  forall definitions id definition,
    In (id, definition) definitions ->
    exists selected,
      In (id, selected) (normalize_global_definitions definitions).
Proof.
  intros definitions id definition Hin.
  destruct (source_definition_scan_is_some definitions id definition Hin)
    as [selected Hscan].
  exists selected.
  unfold normalize_global_definitions.
  apply PTree.elements_correct.
  rewrite normalized_global_definition_map_get_scan.
  exact Hscan.
Qed.
