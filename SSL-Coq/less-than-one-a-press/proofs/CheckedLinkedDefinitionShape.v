(** Abstract checked-source shape transport for one linked definition. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Maps.

Import ListNotations.

(** All collections and programs remain abstract here.  A linked definition
    enters the checked source collection through provenance; [forallb] then
    supplies the requested payload shape at the selected identifier. *)
Lemma checked_provenance_supplies_linked_definition_shape :
  forall
      (source_definitions : list (ident * globdef Clight.fundef type))
      (linked : Clight.program) (id : ident)
      (checker : ident * globdef Clight.fundef type -> bool)
      (shape : globdef Clight.fundef type -> bool)
      (definition : globdef Clight.fundef type),
    (forall candidate, checker (id, candidate) = shape candidate) ->
    forallb checker source_definitions = true ->
    (forall candidate,
      In (id, candidate) linked.(prog_defs) ->
      In (id, candidate) source_definitions) ->
    (prog_defmap linked) ! id = Some definition ->
    shape definition = true.
Proof.
  intros source_definitions linked id checker shape definition
    Hchecker Hchecked Hprovenance Hdefinition.
  pose proof Hdefinition as Hlinked_membership.
  apply AST.in_prog_defmap in Hlinked_membership.
  pose proof (Hprovenance definition Hlinked_membership) as Hsource.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked (id, definition) Hsource).
  now rewrite Hchecker in Hchecked.
Qed.
