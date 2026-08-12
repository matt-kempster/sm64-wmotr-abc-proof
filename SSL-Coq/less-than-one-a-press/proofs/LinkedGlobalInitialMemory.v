(** Resource-bounded structural lemmas for linked global variables.

    The concrete linked programs in this development contain thousands of
    generated definitions.  These lemmas keep the global-environment and
    initial-memory eliminations abstract, so clients can instantiate opaque
    source/link receipts without asking conversion to inspect a concrete
    linked AST. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Maps Memory.

Import ListNotations.
Local Open Scope Z_scope.

Definition identifier_definition_shape_ok
    (id : ident) (shape : globdef Clight.fundef type -> bool)
    (entry : ident * globdef Clight.fundef type) : bool :=
  if Pos.eqb (fst entry) id then shape (snd entry) else true.

Lemma checked_entry_predicate_shape_sound :
  forall
      (definitions : list (ident * globdef Clight.fundef type))
      (id : ident) (shape : globdef Clight.fundef type -> bool)
      (checker : ident * globdef Clight.fundef type -> bool)
      (definition : globdef Clight.fundef type),
    (forall candidate, checker (id, candidate) = shape candidate) ->
    forallb checker definitions = true ->
    In (id, definition) definitions ->
    shape definition = true.
Proof.
  intros definitions id shape checker definition
    Hchecker Hchecked Hdefinition.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked (id, definition) Hdefinition).
  now rewrite Hchecker in Hchecked.
Qed.

Lemma checked_identifier_definition_shape_sound :
  forall
      (definitions : list (ident * globdef Clight.fundef type))
      (id : ident) (shape : globdef Clight.fundef type -> bool)
      (definition : globdef Clight.fundef type),
    forallb (identifier_definition_shape_ok id shape) definitions = true ->
    In (id, definition) definitions ->
    shape definition = true.
Proof.
  intros definitions id shape definition Hchecked Hdefinition.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked (id, definition) Hdefinition).
  unfold identifier_definition_shape_ok in Hchecked.
  cbn [fst snd] in Hchecked.
  now rewrite Pos.eqb_refl in Hchecked.
Qed.

(** A symbol, exact linked-to-source membership, and a checked shape are
    enough to recover the same block through [find_var_info].  All operations
    on [program] occur while it is an abstract variable. *)
Lemma linked_symbol_with_source_shape_has_variable :
  forall (program : Clight.program)
      (source_definitions : list (ident * globdef Clight.fundef type))
      id shape (variable_property : globvar type -> Prop),
    (forall definition,
      In (id, definition) program.(prog_defs) ->
      In (id, definition) source_definitions) ->
    (forall definition,
      In (id, definition) source_definitions -> shape definition = true) ->
    (forall definition,
      shape definition = true ->
      exists variable,
        definition = Gvar variable /\ variable_property variable) ->
    (exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block) ->
    exists block variable,
      Genv.find_symbol (Clight.globalenv program) id = Some block /\
      Genv.find_var_info (Clight.globalenv program) block = Some variable /\
      variable_property variable.
Proof.
  intros program source_definitions id shape variable_property
    Hprovenance Hshape Hdecode [block Hsymbol].
  pose proof
    (@Genv.find_symbol_inversion Clight.fundef type
      (Ctypes.program_of_program program) id block Hsymbol) as Hdomain.
  destruct
    (@AST.prog_defmap_dom Clight.fundef type
      (Ctypes.program_of_program program) id Hdomain)
    as [definition Hdefinition].
  pose proof Hdefinition as Hlinked_definition.
  apply AST.in_prog_defmap in Hlinked_definition.
  pose proof (Hshape definition
    (Hprovenance definition Hlinked_definition)) as Hchecked_shape.
  destruct (Hdecode definition Hchecked_shape)
    as [variable [-> Hvariable_property]].
  apply (proj1 (Genv.find_def_symbol program id (Gvar variable)))
    in Hdefinition.
  destruct Hdefinition as
    [definition_block [Hdefinition_symbol Hdefinition]].
  change (Genv.find_symbol (Clight.globalenv program) id =
    Some definition_block) in Hdefinition_symbol.
  rewrite Hsymbol in Hdefinition_symbol.
  inversion Hdefinition_symbol; subst definition_block.
  exists block, variable.
  repeat split.
  - exact Hsymbol.
  - apply Genv.find_var_info_iff. exact Hdefinition.
  - exact Hvariable_property.
Qed.

Lemma linked_symbol_with_definition_shape_has_variable :
  forall (program : Clight.program) id shape
      (variable_property : globvar type -> Prop),
    (forall definition,
      In (id, definition) program.(prog_defs) -> shape definition = true) ->
    (forall definition,
      shape definition = true ->
      exists variable,
        definition = Gvar variable /\ variable_property variable) ->
    (exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block) ->
    exists block variable,
      Genv.find_symbol (Clight.globalenv program) id = Some block /\
      Genv.find_var_info (Clight.globalenv program) block = Some variable /\
      variable_property variable.
Proof.
  intros program id shape variable_property Hshape Hdecode Hsymbol.
  eapply (linked_symbol_with_source_shape_has_variable
    program program.(prog_defs) id shape variable_property).
  - intros definition Hdefinition. exact Hdefinition.
  - exact Hshape.
  - exact Hdecode.
  - exact Hsymbol.
Qed.

(** An exact definition-map receipt gives the corresponding global block and
    variable lookup without evaluating the concrete program. *)
Lemma variable_definition_map_resolves_globalenv :
  forall (program : Clight.program) id variable,
    (prog_defmap program) ! id = Some (Gvar variable) ->
    exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block /\
      Genv.find_var_info (Clight.globalenv program) block = Some variable.
Proof.
  intros program id variable Hdefinition.
  apply (proj1 (Genv.find_def_symbol program id (Gvar variable)))
    in Hdefinition.
  destruct Hdefinition as [block [Hsymbol Hdefinition]].
  exists block. split.
  - exact Hsymbol.
  - apply Genv.find_var_info_iff. exact Hdefinition.
Qed.

(** CompCert's initial-memory characterization yields the writable interval
    of a non-readonly, nonvolatile [Init_space] global. *)
Lemma initialized_writable_space_has_range_permission :
  forall (program : Clight.program) memory block variable bytes low high,
    Genv.init_mem program = Some memory ->
    Genv.find_var_info (Clight.globalenv program) block = Some variable ->
    gvar_init variable = [Init_space bytes] ->
    gvar_readonly variable = false ->
    gvar_volatile variable = false ->
    0 <= low -> low <= high -> high <= bytes ->
    Mem.range_perm memory block low high Cur Writable.
Proof.
  intros program memory block variable bytes low high
    Hinitial Hvariable Hinitializer Hwritable Hnonvolatile
    Hlow Hordered Hhigh.
  pose proof (proj1 (@Genv.init_mem_characterization
      Clight.fundef type program block variable memory
      Hvariable Hinitial)) as Hrange.
  rewrite Hinitializer in Hrange.
  unfold Genv.perm_globvar in Hrange.
  rewrite Hnonvolatile, Hwritable in Hrange.
  cbn in Hrange.
  intros offset Hoffset.
  apply Hrange.
  lia.
Qed.
