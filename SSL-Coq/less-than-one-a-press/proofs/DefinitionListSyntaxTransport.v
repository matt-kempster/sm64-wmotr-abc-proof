(** Abstract syntax-inventory transport along definition-list inclusion. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import ClightLinkExecution.

Import ListNotations.

Lemma definition_list_provenance_transfers_no_direct_sbuiltin :
  forall source target,
    incl target source ->
    concat (map global_definition_direct_sbuiltins source) = [] ->
    concat (map global_definition_direct_sbuiltins target) = [].
Proof.
  intros source target Hprovenance Hsource.
  destruct (concat (map global_definition_direct_sbuiltins target))
    as [| external rest] eqn:Htarget; [reflexivity |].
  exfalso.
  assert (Hexternal_target :
    In external
      (concat (map global_definition_direct_sbuiltins target))).
  { rewrite Htarget. now left. }
  apply in_concat in Hexternal_target.
  destruct Hexternal_target as [builtins [Hbuiltins Hexternal]].
  apply in_map_iff in Hbuiltins.
  destruct Hbuiltins as [entry [Hbuiltins Hentry]]. subst builtins.
  assert (Hexternal_source :
    In external
      (concat (map global_definition_direct_sbuiltins source))).
  {
    apply in_concat.
    exists (global_definition_direct_sbuiltins entry).
    split.
    - apply in_map. exact (Hprovenance entry Hentry).
    - exact Hexternal.
  }
  rewrite Hsource in Hexternal_source. contradiction.
Qed.

Lemma definition_list_provenance_transfers_init_addrof_occurrence :
  forall source target referenced_id,
    incl target source ->
    In referenced_id
      (concat (map global_definition_init_addrof_identifiers target)) ->
    In referenced_id
      (concat (map global_definition_init_addrof_identifiers source)).
Proof.
  intros source target referenced_id Hprovenance Hin.
  apply in_concat in Hin.
  destruct Hin as [identifiers [Hidentifiers Hreferenced]].
  apply in_map_iff in Hidentifiers.
  destruct Hidentifiers as [entry [Hidentifiers Hentry]].
  subst identifiers.
  apply in_concat.
  exists (global_definition_init_addrof_identifiers entry).
  split.
  - apply in_map. exact (Hprovenance entry Hentry).
  - exact Hreferenced.
Qed.

Lemma definition_list_provenance_transfers_supported_constructors :
  forall source target,
    incl target source ->
    forallb external_global_has_supported_constructor source = true ->
    forallb external_global_has_supported_constructor target = true.
Proof.
  intros source target Hprovenance Hsource.
  rewrite forallb_forall in Hsource |- *.
  intros entry Hentry.
  exact (Hsource entry (Hprovenance entry Hentry)).
Qed.
