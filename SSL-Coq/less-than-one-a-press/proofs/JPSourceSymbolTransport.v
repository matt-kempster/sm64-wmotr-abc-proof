(** Source-definition symbol transport for the official cleaned JP link.

    This module is deliberately confined to the cleaned/linking layer.  The
    generic theorem first moves an explicit definition receipt from one
    source unit into the source union, then uses source-union identifier
    coverage and a successful official link to obtain a target symbol.  The
    JP theorem merely supplies the already-checked concrete coverage and link
    witnesses.  No execution, entry-memory, or zero-A definitions occur here. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution LinkedClightPrograms
  NormalizedClightPrograms.

Import ListNotations.

Lemma nIn_to_nlist_to_list_membership :
  forall (A : Type) (value : A) units,
    nIn value units -> In value (nlist_to_list units).
Proof.
  intros A value units. induction units as [head | head rest IH]; cbn.
  - intros Heq. now left.
  - intros [Heq | Hin].
    + now left.
    + right. now apply IH.
Qed.

Lemma source_unit_definition_enters_source_union :
  forall (units : nlist Clight.program) (unit : Clight.program)
      id (definition : globdef Clight.fundef type),
    nIn unit units ->
    In (id, definition) (prog_defs unit) ->
    In (id, definition) (unit_global_definitions units).
Proof.
  intros units unit id definition Hunit Hdefinition.
  unfold unit_global_definitions. apply in_concat.
  exists (prog_defs unit). split; [|exact Hdefinition].
  apply in_map. now apply nIn_to_nlist_to_list_membership.
Qed.

(** This is the reusable transport theorem.  It does not require the cleaned
    unit containing [id] to be the same unit that supplied the source receipt;
    [SourceUnionIdentifierCoverage] records exactly the admissible
    source-to-cleaned redistribution. *)
Theorem source_unit_definition_has_official_link_symbol :
  forall (source_units cleaned_units : nlist Clight.program)
      (linked unit : Clight.program) id
      (definition : globdef Clight.fundef type),
    nIn unit source_units ->
    In (id, definition) (prog_defs unit) ->
    SourceUnionIdentifierCoverage source_units cleaned_units ->
    link_list cleaned_units = Some linked ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) id = Some block.
Proof.
  intros source_units cleaned_units linked unit id definition
    Hsource_unit Hsource_definition Hcoverage Hlink.
  assert (Hin_union :
    In (id, definition) (unit_global_definitions source_units)).
  { eapply source_unit_definition_enters_source_union; eauto. }
  destruct (Hcoverage id (ex_intro _ definition Hin_union)) as
    [cleaned_unit [cleaned_definition [Hcleaned_unit Hcleaned_definition]]].
  assert (Hcleaned_symbol : exists source_block,
    Genv.find_symbol (Clight.globalenv cleaned_unit) id = Some source_block).
  { eapply Genv.find_symbol_exists. exact Hcleaned_definition. }
  destruct Hcleaned_symbol as [source_block Hsource_symbol].
  eapply (official_link_preserves_symbol_domain
    cleaned_units linked Hlink); eauto.
Qed.

(** Concrete JP specialization.  One explicit generated-unit definition
    receipt is enough to establish existence of the identically named symbol
    in the official cleaned JP program. *)
Corollary jp_source_definition_has_official_symbol :
  forall unit id definition,
    nIn unit jp_units ->
    In (id, definition) (prog_defs unit) ->
    exists block,
      Genv.find_symbol
        (Clight.globalenv jp_official_cleaned_slice) id = Some block.
Proof.
  intros unit id definition Hunit Hdefinition.
  eapply source_unit_definition_has_official_link_symbol; eauto.
  - exact jp_source_union_identifier_coverage_for_cleaned_units.
  - exact jp_cleaned_units_official_link.
Qed.
