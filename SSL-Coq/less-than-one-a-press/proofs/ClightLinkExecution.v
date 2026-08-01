(** Retail execution boundary after syntactic Clight linking.

    This file deliberately separates four facts that are easy to conflate:

    - CompCert's official linker resolves a source [Internal] definition to
      that exact body in the linked program;
    - global blocks of a source unit and the linked program are not assumed to
      have the same number, so they are related by their symbol name;
    - a reachable [Callstate (External ...)] is a genuinely unresolved global
      definition, rather than a cross-translation-unit declaration whose body
      was linked in; and
    - CompCert leaves [EF_external] behavior abstract.  Writable-memory frame
      conditions therefore remain explicit, local hypotheses.

    None of the interfaces below assumes the target Graphics/Object gap or a
    star-collection conclusion. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Errors Events Globalenvs
  Integers Linking Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import LinkedClightPrograms
  NormalizedClightPrograms CleanedClightPrograms.

Import ListNotations.
Local Open Scope Z_scope.

(** * Consequences of an actual successful [link_list] *)

Section OFFICIAL_LINK.

Variable units : nlist Clight.program.
Variable linked : Clight.program.
Hypothesis official_link : link_list units = Some linked.

Lemma official_link_unit_linkorder :
  forall unit,
    nIn unit units ->
    linkorder unit linked.
Proof.
  intros unit Hin.
  eapply link_list_linkorder; eauto.
Qed.

Lemma official_link_preserves_definition :
  forall unit id (definition : globdef Clight.fundef type),
    nIn unit units ->
    (prog_defmap unit) ! id = Some definition ->
    exists linked_definition,
      (prog_defmap linked) ! id = Some linked_definition /\
      linkorder definition linked_definition.
Proof.
  intros unit id definition Hunit Hdefinition.
  pose proof (official_link_unit_linkorder unit Hunit) as Hlinkorder.
  destruct Hlinkorder as [Hprogram_linkorder _].
  exact (prog_defmap_linkorder (program_of_program unit)
    (program_of_program linked) id definition
    Hprogram_linkorder Hdefinition).
Qed.

(** An internal body cannot be replaced by another body, nor remain an
    external declaration: [linkorder_fundef] has no such constructor. *)
Theorem official_link_resolves_internal_definition :
  forall unit id body,
    nIn unit units ->
    (prog_defmap unit) ! id = Some (Gfun (Internal body)) ->
    (prog_defmap linked) ! id = Some (Gfun (Internal body)).
Proof.
  intros unit id body Hunit Hbody.
  destruct (official_link_preserves_definition unit id
              (Gfun (Internal body)) Hunit Hbody)
    as [linked_definition [Hlinked Horder]].
  inversion Horder; subst.
  match goal with
  | Hf : linkorder (Internal body) _ |- _ => inversion Hf; subst
  end.
  exact Hlinked.
Qed.

Theorem official_link_resolves_internal_globalenv :
  forall unit id body,
    nIn unit units ->
    (prog_defmap unit) ! id = Some (Gfun (Internal body)) ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) id = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal body).
Proof.
  intros unit id body Hunit Hbody.
  pose proof
    (official_link_resolves_internal_definition unit id body Hunit Hbody)
    as Hlinked.
  apply (proj1 (Genv.find_def_symbol linked id
                  (Gfun (Internal body)))) in Hlinked.
  destruct Hlinked as [block [Hsymbol Hdefinition]].
  exists block; split; auto.
  apply Genv.find_funct_ptr_iff.
  exact Hdefinition.
Qed.

(** This formulation retains the external declaration as an audited witness,
    but resolution follows from the body-bearing unit and the official link. *)
Theorem official_link_resolves_cross_tu_external_declaration :
  forall declaration_unit definition_unit id external_name signature
      argument_types result_type calling_convention body,
    nIn declaration_unit units ->
    nIn definition_unit units ->
    (prog_defmap declaration_unit) ! id =
      Some (Gfun (External (EF_external external_name signature)
        argument_types result_type calling_convention)) ->
    (prog_defmap definition_unit) ! id = Some (Gfun (Internal body)) ->
    (prog_defmap linked) ! id = Some (Gfun (Internal body)) /\
    exists block,
      Genv.find_symbol (Clight.globalenv linked) id = Some block /\
      Genv.find_funct_ptr (Clight.globalenv linked) block =
        Some (Internal body).
Proof.
  intros declaration_unit definition_unit id external_name signature
    argument_types result_type calling_convention body
    Hdeclaration_unit Hdefinition_unit Hdeclaration Hdefinition.
  split.
  - eapply official_link_resolves_internal_definition; eauto.
  - eapply official_link_resolves_internal_globalenv; eauto.
Qed.

(** Conversely, a definition that is still external in the official result
    has no source unit containing an internal body at that global identifier. *)
Theorem official_link_external_definition_has_no_internal_source :
  forall id external_function argument_types result_type calling_convention
      unit body,
    (prog_defmap linked) ! id =
      Some (Gfun (External external_function argument_types result_type
        calling_convention)) ->
    nIn unit units ->
    (prog_defmap unit) ! id <> Some (Gfun (Internal body)).
Proof.
  intros id external_function argument_types result_type calling_convention
    unit body Hexternal Hunit Hinternal.
  pose proof
    (official_link_resolves_internal_definition unit id body Hunit Hinternal)
    as Hresolved.
  rewrite Hexternal in Hresolved.
  discriminate.
Qed.

Lemma official_link_preserves_symbol_domain :
  forall unit id source_block,
    nIn unit units ->
    Genv.find_symbol (Clight.globalenv unit) id = Some source_block ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv linked) id = Some linked_block.
Proof.
  intros unit id source_block Hunit Hsource.
  pose proof
    (@Genv.find_symbol_inversion Clight.fundef type
      (program_of_program unit) id source_block Hsource) as Hname.
  destruct (@prog_defmap_dom Clight.fundef type
              (program_of_program unit) id Hname)
    as [definition Hdefinition].
  destruct (official_link_preserves_definition unit id definition
              Hunit Hdefinition)
    as [linked_definition [Hlinked _]].
  apply in_prog_defmap in Hlinked.
  eapply Genv.find_symbol_exists; eauto.
Qed.

End OFFICIAL_LINK.

(** Global environments allocate blocks in definition-list order.  Linking
    canonicalizes that order, so equal identifiers, not equal block numbers,
    are the sound cross-program correspondence. *)
Definition symbol_block_map
    (source target : Clight.program) : meminj :=
  fun source_block =>
    match Genv.invert_symbol (Clight.globalenv source) source_block with
    | Some id =>
        match Genv.find_symbol (Clight.globalenv target) id with
        | Some target_block => Some (target_block, 0)
        | None => None
        end
    | None => None
    end.

Lemma symbol_block_map_named_symbol :
  forall source target id source_block target_block,
    Genv.find_symbol (Clight.globalenv source) id = Some source_block ->
    Genv.find_symbol (Clight.globalenv target) id = Some target_block ->
    symbol_block_map source target source_block = Some (target_block, 0).
Proof.
  intros source target id source_block target_block Hsource Htarget.
  unfold symbol_block_map.
  rewrite (@Genv.find_invert_symbol Clight.fundef type
    (Clight.globalenv source) id source_block Hsource).
  now rewrite Htarget.
Qed.

Theorem official_link_symbol_block_map_is_total_on_unit_symbols :
  forall units linked unit id source_block,
    link_list units = Some linked ->
    nIn unit units ->
    Genv.find_symbol (Clight.globalenv unit) id = Some source_block ->
    exists target_block,
      Genv.find_symbol (Clight.globalenv linked) id = Some target_block /\
      symbol_block_map unit linked source_block = Some (target_block, 0).
Proof.
  intros units linked unit id source_block Hlink Hunit Hsource.
  destruct (official_link_preserves_symbol_domain units linked Hlink unit id
              source_block Hunit Hsource) as [target_block Htarget].
  exists target_block; split; auto.
  eapply symbol_block_map_named_symbol; eauto.
Qed.

(** This proposition is the concrete initial-memory work that symbol lookup
    alone does not discharge.  It uses CompCert's actual initial memories and
    the explicit name-based block injection. *)
Definition OfficialLinkInitialMemoryInjection
    (source linked : Clight.program) : Prop :=
  exists source_memory linked_memory,
    Genv.init_mem source = Some source_memory /\
    Genv.init_mem linked = Some linked_memory /\
    Mem.inject (symbol_block_map source linked)
      source_memory linked_memory.

(** [symbol_block_map] determines where a named source block goes, but
    CompCert's external-call injection theorem deliberately asks for more:
    public-symbol status and volatility must also be preserved.  The next two
    predicates expose exactly those two environment obligations. *)
Definition OfficialLinkPublicSymbolsAgree
    (source linked : Clight.program) : Prop :=
  forall id,
    Senv.public_symbol (Clight.globalenv linked) id =
    Senv.public_symbol (Clight.globalenv source) id.

Definition OfficialLinkMappedVolatilityAgree
    (source linked : Clight.program) : Prop :=
  forall source_block linked_block delta,
    symbol_block_map source linked source_block =
      Some (linked_block, delta) ->
    Senv.block_is_volatile (Clight.globalenv linked) linked_block =
    Senv.block_is_volatile (Clight.globalenv source) source_block.

Definition NamedSymbolCoverage (source linked : Clight.program) : Prop :=
  forall id source_block,
    Genv.find_symbol (Clight.globalenv source) id = Some source_block ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv linked) id = Some linked_block.

Definition GlobalDefinitionMapAgreement
    (source linked : Clight.program) : Prop :=
  forall id, (prog_defmap source) ! id = (prog_defmap linked) ! id.

Definition PublicIdentifierAgreement
    (source linked : Clight.program) : Prop :=
  forall id, In id source.(prog_public) <-> In id linked.(prog_public).

Lemma global_definition_map_agreement_gives_symbol_coverage :
  forall source linked,
    GlobalDefinitionMapAgreement source linked ->
    NamedSymbolCoverage source linked.
Proof.
  intros source linked Hagree id source_block Hsource.
  pose proof
    (@Genv.find_symbol_inversion Clight.fundef type
      (program_of_program source) id source_block Hsource) as Hname.
  destruct (@prog_defmap_dom Clight.fundef type
    (program_of_program source) id Hname) as [definition Hdefinition].
  specialize (Hagree id).
  assert (Hlinked : (prog_defmap linked) ! id = Some definition).
  { now rewrite <- Hagree. }
  apply in_prog_defmap in Hlinked.
  eapply Genv.find_symbol_exists; eauto.
Qed.

Lemma global_definition_map_agreement_gives_symbol_domain_equivalence :
  forall source linked,
    GlobalDefinitionMapAgreement source linked ->
    NamedSymbolCoverage source linked /\ NamedSymbolCoverage linked source.
Proof.
  intros source linked Hagree. split.
  - now apply global_definition_map_agreement_gives_symbol_coverage.
  - apply global_definition_map_agreement_gives_symbol_coverage.
    intros id. symmetry. apply Hagree.
Qed.

Lemma named_blocks_have_agreed_definitions :
  forall source linked id source_block linked_block,
    GlobalDefinitionMapAgreement source linked ->
    Genv.find_symbol (Clight.globalenv source) id = Some source_block ->
    Genv.find_symbol (Clight.globalenv linked) id = Some linked_block ->
    exists definition,
      Genv.find_def (Clight.globalenv source) source_block = Some definition /\
      Genv.find_def (Clight.globalenv linked) linked_block = Some definition.
Proof.
  intros source linked id source_block linked_block Hagree Hsource Hlinked.
  pose proof
    (@Genv.find_symbol_inversion Clight.fundef type
      (program_of_program source) id source_block Hsource) as Hname.
  destruct (@prog_defmap_dom Clight.fundef type
    (program_of_program source) id Hname) as [definition Hdefinition].
  exists definition. split.
  - apply (proj1 (Genv.find_def_symbol source id definition)) in Hdefinition.
    destruct Hdefinition as [actual_block [Hactual Hdefinition]].
    change (Genv.find_symbol (Genv.globalenv source) id =
      Some source_block) in Hsource.
    rewrite Hsource in Hactual. now inversion Hactual.
  - specialize (Hagree id).
    change ((AST.prog_defmap (program_of_program source)) ! id =
      (AST.prog_defmap (program_of_program linked)) ! id) in Hagree.
    change ((AST.prog_defmap (program_of_program source)) ! id =
      Some definition) in Hdefinition.
    rewrite Hagree in Hdefinition.
    apply (proj1 (Genv.find_def_symbol linked id definition)) in Hdefinition.
    destruct Hdefinition as [actual_block [Hactual Hdefinition]].
    change (Genv.find_symbol (Genv.globalenv linked) id =
      Some linked_block) in Hlinked.
    rewrite Hlinked in Hactual. now inversion Hactual.
Qed.

Lemma proj_sumbool_iff_congr :
  forall (P Q : Prop) (decide_P : {P} + {~ P}) (decide_Q : {Q} + {~ Q}),
    (P <-> Q) ->
    proj_sumbool decide_P = proj_sumbool decide_Q.
Proof.
  intros P Q [HP | HnotP] [HQ | HnotQ] Hequivalent; cbn;
    try reflexivity.
  - exfalso. apply HnotQ. now apply (proj1 Hequivalent).
  - exfalso. apply HnotP. now apply (proj2 Hequivalent).
Qed.

Theorem global_interface_agreement_gives_public_symbols :
  forall source linked,
    GlobalDefinitionMapAgreement source linked ->
    PublicIdentifierAgreement source linked ->
    OfficialLinkPublicSymbolsAgree source linked.
Proof.
  intros source linked Hdefinitions Hpublic id.
  destruct (global_definition_map_agreement_gives_symbol_domain_equivalence
    source linked Hdefinitions) as [Hforward Hbackward].
  change (Genv.public_symbol (Genv.globalenv linked) id =
    Genv.public_symbol (Genv.globalenv source) id).
  unfold Genv.public_symbol.
  destruct (Genv.find_symbol (Genv.globalenv linked) id)
    as [linked_block |] eqn:Hlinked;
  destruct (Genv.find_symbol (Genv.globalenv source) id)
    as [source_block |] eqn:Hsource.
  - rewrite ! Genv.globalenv_public.
    apply proj_sumbool_iff_congr.
    symmetry. apply Hpublic.
  - destruct (Hbackward id linked_block Hlinked) as [source_block Hfound].
    change (Genv.find_symbol (Clight.globalenv source) id = None) in Hsource.
    rewrite Hsource in Hfound. discriminate.
  - destruct (Hforward id source_block Hsource) as [linked_block Hfound].
    change (Genv.find_symbol (Clight.globalenv linked) id = None) in Hlinked.
    rewrite Hlinked in Hfound. discriminate.
  - reflexivity.
Qed.

Theorem global_definition_map_agreement_gives_mapped_volatility :
  forall source linked,
    GlobalDefinitionMapAgreement source linked ->
    OfficialLinkMappedVolatilityAgree source linked.
Proof.
  intros source linked Hdefinitions source_block linked_block delta Hmap.
  unfold symbol_block_map in Hmap.
  destruct (Genv.invert_symbol (Clight.globalenv source) source_block)
    as [id |] eqn:Hsource_invert; try discriminate.
  destruct (Genv.find_symbol (Clight.globalenv linked) id)
    as [actual_linked_block |] eqn:Hlinked; try discriminate.
  inversion Hmap; subst actual_linked_block delta.
  pose proof (@Genv.invert_find_symbol Clight.fundef type
    (Clight.globalenv source) id source_block Hsource_invert) as Hsource.
  destruct (named_blocks_have_agreed_definitions source linked id
    source_block linked_block Hdefinitions Hsource Hlinked)
    as [definition [Hsource_definition Hlinked_definition]].
  change (Genv.block_is_volatile (Genv.globalenv linked) linked_block =
    Genv.block_is_volatile (Genv.globalenv source) source_block).
  unfold Genv.block_is_volatile, Genv.find_var_info.
  change (Genv.find_def (Genv.globalenv source) source_block =
    Some definition) in Hsource_definition.
  change (Genv.find_def (Genv.globalenv linked) linked_block =
    Some definition) in Hlinked_definition.
  now rewrite Hsource_definition, Hlinked_definition.
Qed.

(** This is the reusable environment theorem.  Unlike the unit-link
    corollary below, its source can be a whole cleaned semantic program whose
    public-symbol set is capable of agreeing with the official target. *)
Theorem symbol_block_map_is_external_environment_injection :
  forall source linked,
    NamedSymbolCoverage source linked ->
    OfficialLinkPublicSymbolsAgree source linked ->
    OfficialLinkMappedVolatilityAgree source linked ->
    symbols_inject (symbol_block_map source linked)
      (Clight.globalenv source) (Clight.globalenv linked).
Proof.
  intros source linked Hcoverage Hpublic Hvolatile.
  split.
  - exact Hpublic.
  - split.
    + intros queried_id source_block linked_block delta Hmap Hsource.
      unfold symbol_block_map in Hmap.
      rewrite (@Genv.find_invert_symbol Clight.fundef type
        (Clight.globalenv source) queried_id source_block Hsource) in Hmap.
      destruct (Genv.find_symbol (Clight.globalenv linked) queried_id)
        as [actual_block |] eqn:Hlinked; try discriminate.
      inversion Hmap; subst actual_block delta.
      now split.
    + split.
      * intros queried_id source_block Hpublic_source Hsource.
        destruct (Hcoverage queried_id source_block Hsource)
          as [linked_block Hlinked].
        exists linked_block. split; [|exact Hlinked].
        change (Genv.find_symbol (Clight.globalenv source) queried_id =
          Some source_block) in Hsource.
        exact (symbol_block_map_named_symbol source linked queried_id
          source_block linked_block Hsource Hlinked).
      * exact Hvolatile.
Qed.

(** Equal global-definition maps and public-name sets are sufficient for the
    official name-based block map to satisfy CompCert's full external-call
    environment relation. *)
Theorem global_interface_agreement_is_external_environment_injection :
  forall source linked,
    GlobalDefinitionMapAgreement source linked ->
    PublicIdentifierAgreement source linked ->
    symbols_inject (symbol_block_map source linked)
      (Clight.globalenv source) (Clight.globalenv linked).
Proof.
  intros source linked Hdefinitions Hpublic.
  eapply symbol_block_map_is_external_environment_injection.
  - now apply global_definition_map_agreement_gives_symbol_coverage.
  - now apply global_interface_agreement_gives_public_symbols.
  - now apply global_definition_map_agreement_gives_mapped_volatility.
Qed.

(** A successful official link supplies the two name-translation clauses of
    [symbols_inject].  Publicness and volatility remain separate, concrete
    global-environment checks; they are not consequences of mere name
    coverage. *)
Theorem official_link_symbol_map_is_external_environment_injection :
  forall units linked source,
    link_list units = Some linked ->
    nIn source units ->
    OfficialLinkPublicSymbolsAgree source linked ->
    OfficialLinkMappedVolatilityAgree source linked ->
    symbols_inject (symbol_block_map source linked)
      (Clight.globalenv source) (Clight.globalenv linked).
Proof.
  intros units linked source Hlink Hunit Hpublic Hvolatile.
  eapply symbol_block_map_is_external_environment_injection; eauto.
  intros id source_block Hsource.
  destruct (official_link_symbol_block_map_is_total_on_unit_symbols
    units linked source id source_block Hlink Hunit Hsource)
    as [linked_block [Hlinked Hmap]].
  now exists linked_block.
Qed.

(** * A bounded execution bridge for global [Evar] lvalues *)

(** Name coverage maps a resolved source global pointer to the target pointer
    with zero displacement.  This is a value-level consequence of the actual
    [symbol_block_map], not an assumption that the two global environments use
    equal block numbers. *)
Lemma named_symbol_coverage_injects_global_pointer :
  forall source target id source_block,
    NamedSymbolCoverage source target ->
    Genv.find_symbol (Clight.globalenv source) id = Some source_block ->
    exists target_block,
      Genv.find_symbol (Clight.globalenv target) id = Some target_block /\
      symbol_block_map source target source_block = Some (target_block, 0) /\
      Val.inject (symbol_block_map source target)
        (Vptr source_block (Ptrofs.repr 0))
        (Vptr target_block (Ptrofs.repr 0)).
Proof.
  intros source target id source_block Hcoverage Hsource.
  destruct (Hcoverage id source_block Hsource) as [target_block Htarget].
  assert (Hmap : symbol_block_map source target source_block =
      Some (target_block, 0)).
  { eapply symbol_block_map_named_symbol; eauto. }
  exists target_block. repeat split.
  - exact Htarget.
  - exact Hmap.
  - econstructor.
    + exact Hmap.
    + now rewrite Ptrofs.add_zero.
Qed.

(** This theorem crosses exactly one Clight evaluation rule.  Both function
    environments must state that [id] is not a stack-allocated local, because
    [NamedSymbolCoverage] relates global environments only.  The current
    memories must already be related by the name-based injection.  Under those
    explicit premises, the same typed [Evar] has source and target
    [eval_lvalue] derivations whose returned pointers are injected.

    This does not relate arbitrary expressions, local bindings, composite
    layouts, continuations, or internal Clight steps.  In particular, applying
    it to the original generated units and the cleaned official targets still
    requires a separately proved retail global-interface relation and the
    relevant current-state [Mem.inject]. *)
Theorem named_global_evar_lvalue_execution_bridge :
  forall source target id evar_type
      source_environment target_environment
      source_locals target_locals source_memory target_memory source_block,
    NamedSymbolCoverage source target ->
    source_environment ! id = None ->
    target_environment ! id = None ->
    Genv.find_symbol (Clight.globalenv source) id = Some source_block ->
    Mem.inject (symbol_block_map source target) source_memory target_memory ->
    exists target_block,
      Genv.find_symbol (Clight.globalenv target) id = Some target_block /\
      symbol_block_map source target source_block = Some (target_block, 0) /\
      @eval_lvalue (Clight.globalenv source) source_environment source_locals
        source_memory (Evar id evar_type) source_block (Ptrofs.repr 0) Full /\
      @eval_lvalue (Clight.globalenv target) target_environment target_locals
        target_memory (Evar id evar_type) target_block (Ptrofs.repr 0) Full /\
      Val.inject (symbol_block_map source target)
        (Vptr source_block (Ptrofs.repr 0))
        (Vptr target_block (Ptrofs.repr 0)) /\
      Mem.inject (symbol_block_map source target) source_memory target_memory.
Proof.
  intros source target id evar_type source_environment target_environment
    source_locals target_locals source_memory target_memory source_block
    Hcoverage Hsource_local Htarget_local Hsource_symbol Hmemory.
  destruct (named_symbol_coverage_injects_global_pointer source target id
    source_block Hcoverage Hsource_symbol)
    as [target_block [Htarget_symbol [Hmap Hpointer]]].
  exists target_block. split.
  - exact Htarget_symbol.
  - split.
    + exact Hmap.
    + split.
      * now apply eval_Evar_global.
      * split.
        -- now apply eval_Evar_global.
        -- split.
           ++ exact Hpointer.
           ++ exact Hmemory.
Qed.

(** * Complete retained-body [Evar] census *)

Fixpoint expression_evar_identifiers (expression : expr) : list ident :=
  match expression with
  | Evar id _ => [id]
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _
  | Efield inner _ _ => expression_evar_identifiers inner
  | Ebinop _ left_expression right_expression _ =>
      expression_evar_identifiers left_expression ++
      expression_evar_identifiers right_expression
  | _ => []
  end.

Definition expression_list_evar_identifiers (expressions : list expr) :
    list ident :=
  concat (map expression_evar_identifiers expressions).

Fixpoint statement_evar_identifiers (statement : statement) : list ident :=
  match statement with
  | Sassign left_expression right_expression =>
      expression_evar_identifiers left_expression ++
      expression_evar_identifiers right_expression
  | Sset _ right_expression => expression_evar_identifiers right_expression
  | Scall _ callee arguments =>
      expression_evar_identifiers callee ++
      expression_list_evar_identifiers arguments
  | Sbuiltin _ _ _ arguments =>
      expression_list_evar_identifiers arguments
  | Ssequence first second | Sloop first second =>
      statement_evar_identifiers first ++ statement_evar_identifiers second
  | Sifthenelse condition yes_branch no_branch =>
      expression_evar_identifiers condition ++
      statement_evar_identifiers yes_branch ++
      statement_evar_identifiers no_branch
  | Sreturn (Some result) => expression_evar_identifiers result
  | Sswitch selector cases =>
      expression_evar_identifiers selector ++
      labeled_statements_evar_identifiers cases
  | Slabel _ body => statement_evar_identifiers body
  | _ => []
  end
with labeled_statements_evar_identifiers
    (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      statement_evar_identifiers body ++
      labeled_statements_evar_identifiers rest
  end.

Definition function_local_identifiers (body : function) : list ident :=
  map fst (fn_params body ++ fn_vars body).

Definition program_defines_identifier
    (program : Clight.program) (id : ident) : bool :=
  match (prog_defmap program) ! id with
  | Some _ => true
  | None => false
  end.

Lemma program_defines_identifier_has_symbol :
  forall program id,
    program_defines_identifier program id = true ->
    exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block.
Proof.
  intros program id Hdefined.
  unfold program_defines_identifier in Hdefined.
  destruct ((prog_defmap program) ! id) as [definition |] eqn:Hdefinition;
    try discriminate.
  apply in_prog_defmap in Hdefinition.
  eapply Genv.find_symbol_exists; eauto.
Qed.

(** * Source-union [Evar] census and official-target transfer *)

(** This second census does not assume that the normalized semantic candidate
    is the eventual official-link result.  It checks every source-unit
    internal body against the union of names present in those source units. *)
Definition source_union_defines_identifier
    (units : nlist Clight.program) (id : ident) : bool :=
  existsb (fun entry => Pos.eqb id (fst entry))
    (unit_global_definitions units).

Definition source_function_evar_identifier_resolved
    (units : nlist Clight.program) (body : function) (id : ident) : bool :=
  if in_dec peq id (function_local_identifiers body)
  then true
  else source_union_defines_identifier units id.

Definition source_internal_body_evars_resolved
    (units : nlist Clight.program)
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (Internal body) =>
      forallb (source_function_evar_identifier_resolved units body)
        (statement_evar_identifiers (fn_body body))
  | _ => true
  end.

Definition all_source_internal_body_evars_resolved
    (units : nlist Clight.program) : bool :=
  forallb (source_internal_body_evars_resolved units)
    (unit_global_definitions units).

Theorem us_source_union_all_internal_body_evars_resolve :
  all_source_internal_body_evars_resolved us_units = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_source_union_all_internal_body_evars_resolve :
  all_source_internal_body_evars_resolved jp_units = true.
Proof. vm_compute. reflexivity. Qed.

Lemma source_union_defines_identifier_sound :
  forall units id,
    source_union_defines_identifier units id = true ->
    exists definition,
      In (id, definition) (unit_global_definitions units).
Proof.
  intros units id Hdefined.
  unfold source_union_defines_identifier in Hdefined.
  rewrite existsb_exists in Hdefined.
  destruct Hdefined as [[entry_id definition] [Hentry Hid]].
  cbn in Hid. apply Pos.eqb_eq in Hid. subst entry_id.
  now exists definition.
Qed.

Theorem checked_source_internal_body_global_evar_has_source_definition :
  forall units function_id body global_id,
    all_source_internal_body_evars_resolved units = true ->
    In (function_id, Gfun (Internal body))
      (unit_global_definitions units) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    exists definition,
      In (global_id, definition) (unit_global_definitions units).
Proof.
  intros units function_id body global_id Hall Hbody Hoccurs Hnotlocal.
  unfold all_source_internal_body_evars_resolved in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall (function_id, Gfun (Internal body)) Hbody).
  change (forallb (source_function_evar_identifier_resolved units body)
    (statement_evar_identifiers (fn_body body)) = true) in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall global_id Hoccurs).
  unfold source_function_evar_identifier_resolved in Hall.
  destruct (in_dec peq global_id (function_local_identifiers body));
    try contradiction.
  now apply source_union_defines_identifier_sound in Hall.
Qed.

Lemma nlist_to_list_membership_to_nIn :
  forall (A : Type) (value : A) units,
    In value (nlist_to_list units) ->
    nIn value units.
Proof.
  intros A value units. induction units as [head | head rest IH]; cbn.
  - intros [Heq | Hnone]; [exact Heq | contradiction].
  - intros [Heq | Hin]; [now left | right; now apply IH].
Qed.

Lemma unit_global_definition_has_owner :
  forall units id definition,
    In (id, definition) (unit_global_definitions units) ->
    exists unit,
      nIn unit units /\ In (id, definition) (prog_defs unit).
Proof.
  intros units id definition Hdefinition.
  unfold unit_global_definitions in Hdefinition.
  apply in_concat in Hdefinition.
  destruct Hdefinition as [definitions [Hdefinitions Hentry]].
  apply in_map_iff in Hdefinitions.
  destruct Hdefinitions as [unit [Hdefinitions Hunit]].
  subst definitions.
  exists unit. split; auto.
  now apply nlist_to_list_membership_to_nIn.
Qed.

(** This exact structural bridge is intentionally separate from the source
    census.  It says that every source-union name has a definition in one of
    the cleaned units.  Proving it for a cleaner is sufficient for symbol
    transfer; it does not assert equality with the normalized candidate. *)
Definition SourceUnionIdentifierCoverage
    (source_units cleaned_units : nlist Clight.program) : Prop :=
  forall id,
    (exists source_definition,
      In (id, source_definition) (unit_global_definitions source_units)) ->
    exists cleaned_unit cleaned_definition,
      nIn cleaned_unit cleaned_units /\
      In (id, cleaned_definition) (prog_defs cleaned_unit).

Lemma source_union_identifier_coverage_from_global_identifiers_incl :
  forall source_units cleaned_units,
    incl (global_identifiers (unit_global_definitions source_units))
         (global_identifiers (unit_global_definitions cleaned_units)) ->
    SourceUnionIdentifierCoverage source_units cleaned_units.
Proof.
  intros source_units cleaned_units Hidentifiers id Hsource.
  destruct Hsource as [source_definition Hsource].
  assert (Hsource_id :
    In id (global_identifiers (unit_global_definitions source_units))).
  { unfold global_identifiers.
    exact (in_map (@fst ident (globdef Clight.fundef type))
      (unit_global_definitions source_units) (id, source_definition) Hsource). }
  specialize (Hidentifiers id Hsource_id).
  unfold global_identifiers in Hidentifiers.
  apply in_map_iff in Hidentifiers.
  destruct Hidentifiers as [[cleaned_id cleaned_definition]
    [Hid Hcleaned]].
  cbn in Hid. subst cleaned_id.
  destruct (unit_global_definition_has_owner cleaned_units id
    cleaned_definition Hcleaned) as [cleaned_unit [Hunit Hdefinition]].
  exists cleaned_unit, cleaned_definition. auto.
Qed.

Theorem us_source_union_identifier_coverage_for_cleaned_units :
  SourceUnionIdentifierCoverage us_units us_cleaned_units.
Proof.
  apply source_union_identifier_coverage_from_global_identifiers_incl.
  exact us_cleaned_global_identifier_coverage.
Qed.

Theorem jp_source_union_identifier_coverage_for_cleaned_units :
  SourceUnionIdentifierCoverage jp_units jp_cleaned_units.
Proof.
  apply source_union_identifier_coverage_from_global_identifiers_incl.
  exact jp_cleaned_global_identifier_coverage.
Qed.

Theorem checked_source_evar_resolves_in_official_cleaned_link :
  forall source_units cleaned_units linked function_id body global_id,
    all_source_internal_body_evars_resolved source_units = true ->
    In (function_id, Gfun (Internal body))
      (unit_global_definitions source_units) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    SourceUnionIdentifierCoverage source_units cleaned_units ->
    link_list cleaned_units = Some linked ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv linked) global_id =
        Some linked_block.
Proof.
  intros source_units cleaned_units linked function_id body global_id
    Hall Hbody Hoccurs Hnotlocal Hcoverage Hlink.
  destruct (checked_source_internal_body_global_evar_has_source_definition
    source_units function_id body global_id Hall Hbody Hoccurs Hnotlocal)
    as [source_definition Hsource_definition].
  destruct (Hcoverage global_id
    (ex_intro _ source_definition Hsource_definition))
    as [cleaned_unit [cleaned_definition [Hunit Hdefinition]]].
  assert (Hsource_symbol : exists source_block,
    Genv.find_symbol (Clight.globalenv cleaned_unit) global_id =
      Some source_block).
  { eapply Genv.find_symbol_exists. exact Hdefinition. }
  destruct Hsource_symbol as [source_block Hsource_symbol].
  eapply official_link_preserves_symbol_domain; eauto.
Qed.

Theorem us_source_evar_resolves_in_official_target :
  forall function_id body global_id,
    In (function_id, Gfun (Internal body))
      (unit_global_definitions us_units) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv us_official_cleaned_slice) global_id =
        Some linked_block.
Proof.
  intros function_id body global_id Hbody Hoccurs Hnotlocal.
  eapply checked_source_evar_resolves_in_official_cleaned_link.
  - exact us_source_union_all_internal_body_evars_resolve.
  - exact Hbody.
  - exact Hoccurs.
  - exact Hnotlocal.
  - exact us_source_union_identifier_coverage_for_cleaned_units.
  - exact us_cleaned_units_official_link.
Qed.

Theorem jp_source_evar_resolves_in_official_target :
  forall function_id body global_id,
    In (function_id, Gfun (Internal body))
      (unit_global_definitions jp_units) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice) global_id =
        Some linked_block.
Proof.
  intros function_id body global_id Hbody Hoccurs Hnotlocal.
  eapply checked_source_evar_resolves_in_official_cleaned_link.
  - exact jp_source_union_all_internal_body_evars_resolve.
  - exact Hbody.
  - exact Hoccurs.
  - exact Hnotlocal.
  - exact jp_source_union_identifier_coverage_for_cleaned_units.
  - exact jp_cleaned_units_official_link.
Qed.

(** * [Init_addrof] relocation census and transfer *)

Definition init_data_addrof_identifiers (datum : init_data) : list ident :=
  match datum with
  | Init_addrof id _ => [id]
  | _ => []
  end.

Definition global_definition_init_addrof_identifiers
    (entry : ident * globdef Clight.fundef type) : list ident :=
  match snd entry with
  | Gvar variable =>
      concat (map init_data_addrof_identifiers (gvar_init variable))
  | _ => []
  end.

Definition program_init_addrof_identifiers
    (program : Clight.program) : list ident :=
  concat (map global_definition_init_addrof_identifiers
    (prog_defs program)).

Definition source_union_init_addrof_identifiers
    (units : nlist Clight.program) : list ident :=
  concat (map global_definition_init_addrof_identifiers
    (unit_global_definitions units)).

Definition all_program_init_addrof_identifiers_resolved
    (program : Clight.program) : bool :=
  forallb (program_defines_identifier program)
    (program_init_addrof_identifiers program).

Definition all_source_union_init_addrof_identifiers_resolved
    (units : nlist Clight.program) : bool :=
  forallb (source_union_defines_identifier units)
    (source_union_init_addrof_identifiers units).

Theorem us_normalized_all_init_addrof_identifiers_resolve :
  all_program_init_addrof_identifiers_resolved
    us_normalized_semantic_slice = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_all_init_addrof_identifiers_resolve :
  all_program_init_addrof_identifiers_resolved
    jp_normalized_semantic_slice = true.
Proof. vm_compute. reflexivity. Qed.

Theorem us_source_union_all_init_addrof_identifiers_resolve :
  all_source_union_init_addrof_identifiers_resolved us_units = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_source_union_all_init_addrof_identifiers_resolve :
  all_source_union_init_addrof_identifiers_resolved jp_units = true.
Proof. vm_compute. reflexivity. Qed.

Theorem checked_program_init_addrof_identifier_resolves :
  forall program id,
    all_program_init_addrof_identifiers_resolved program = true ->
    In id (program_init_addrof_identifiers program) ->
    exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block.
Proof.
  intros program id Hall Hin.
  unfold all_program_init_addrof_identifiers_resolved in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall id Hin).
  now apply program_defines_identifier_has_symbol.
Qed.

Lemma checked_source_union_init_addrof_identifier_has_definition :
  forall units id,
    all_source_union_init_addrof_identifiers_resolved units = true ->
    In id (source_union_init_addrof_identifiers units) ->
    exists definition,
      In (id, definition) (unit_global_definitions units).
Proof.
  intros units id Hall Hin.
  unfold all_source_union_init_addrof_identifiers_resolved in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall id Hin).
  now apply source_union_defines_identifier_sound in Hall.
Qed.

Theorem checked_source_init_addrof_resolves_in_official_cleaned_link :
  forall source_units cleaned_units linked id,
    all_source_union_init_addrof_identifiers_resolved source_units = true ->
    In id (source_union_init_addrof_identifiers source_units) ->
    SourceUnionIdentifierCoverage source_units cleaned_units ->
    link_list cleaned_units = Some linked ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv linked) id = Some linked_block.
Proof.
  intros source_units cleaned_units linked id Hall Hin Hcoverage Hlink.
  destruct (checked_source_union_init_addrof_identifier_has_definition
    source_units id Hall Hin) as [source_definition Hsource_definition].
  destruct (Hcoverage id (ex_intro _ source_definition Hsource_definition))
    as [cleaned_unit [cleaned_definition [Hunit Hdefinition]]].
  assert (Hsource_symbol : exists source_block,
    Genv.find_symbol (Clight.globalenv cleaned_unit) id =
      Some source_block).
  { eapply Genv.find_symbol_exists. exact Hdefinition. }
  destruct Hsource_symbol as [source_block Hsource_symbol].
  eapply official_link_preserves_symbol_domain; eauto.
Qed.

Theorem us_source_init_addrof_resolves_in_official_target :
  forall id,
    In id (source_union_init_addrof_identifiers us_units) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv us_official_cleaned_slice) id =
        Some linked_block.
Proof.
  intros id Hin.
  eapply checked_source_init_addrof_resolves_in_official_cleaned_link.
  - exact us_source_union_all_init_addrof_identifiers_resolve.
  - exact Hin.
  - exact us_source_union_identifier_coverage_for_cleaned_units.
  - exact us_cleaned_units_official_link.
Qed.

Theorem jp_source_init_addrof_resolves_in_official_target :
  forall id,
    In id (source_union_init_addrof_identifiers jp_units) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice) id =
        Some linked_block.
Proof.
  intros id Hin.
  eapply checked_source_init_addrof_resolves_in_official_cleaned_link.
  - exact jp_source_union_all_init_addrof_identifiers_resolve.
  - exact Hin.
  - exact jp_source_union_identifier_coverage_for_cleaned_units.
  - exact jp_cleaned_units_official_link.
Qed.

(** * Exact unresolved global-function inventory *)

(** This census covers global [External] fundefs.  A direct [Sbuiltin] embeds
    its [external_function] in a statement rather than in [prog_defs]; its
    separate step inversion and conditional frame theorem appear below. *)

Definition is_external_global_definition
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (External _ _ _ _) => true
  | _ => false
  end.

Definition external_global_has_supported_constructor
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (External (EF_external _ _) _ _ _) => true
  | Gfun (External (EF_builtin _ _) _ _ _) => true
  | Gfun (External (EF_runtime _ _) _ _ _) => true
  | Gfun (External _ _ _ _) => false
  | _ => true
  end.

Definition external_definition_identifiers
    (program : Clight.program) : list ident :=
  map fst (filter is_external_global_definition (prog_defs program)).

(** Exact target-definition provenance is stronger than name coverage.  It is
    the structural fact needed to transfer source-union syntax inventories to
    the official result without evaluating the entire link inside the kernel. *)
Definition OfficialSourceDefinitionProvenance
    (source_units : nlist Clight.program) (linked : Clight.program) : Prop :=
  forall id definition,
    In (id, definition) (prog_defs linked) ->
    In (id, definition) (unit_global_definitions source_units).

Theorem us_official_definitions_have_cleaned_provenance :
  incl (prog_defs us_official_cleaned_slice)
       (unit_global_definitions us_cleaned_units).
Proof.
  intros [id definition] Hin.
  exact (us_official_cleaned_definition_provenance id definition Hin).
Qed.

Theorem jp_official_definitions_have_cleaned_provenance :
  incl (prog_defs jp_official_cleaned_slice)
       (unit_global_definitions jp_cleaned_units).
Proof.
  intros [id definition] Hin.
  exact (jp_official_cleaned_definition_provenance id definition Hin).
Qed.

Theorem us_official_source_definition_provenance :
  OfficialSourceDefinitionProvenance us_units us_official_cleaned_slice.
Proof.
  exact us_official_cleaned_definition_source_provenance.
Qed.

Theorem jp_official_source_definition_provenance :
  OfficialSourceDefinitionProvenance jp_units jp_official_cleaned_slice.
Proof.
  exact jp_official_cleaned_definition_source_provenance.
Qed.

Theorem us_official_internal_body_evar_resolves :
  forall function_id body global_id,
    In (function_id, Gfun (Internal body))
      (prog_defs us_official_cleaned_slice) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv us_official_cleaned_slice) global_id =
        Some linked_block.
Proof.
  intros function_id body global_id Hbody Hoccurs Hnotlocal.
  assert (Hsource_body :
    In (function_id, Gfun (Internal body))
      (unit_global_definitions us_units)).
  { exact (us_official_source_definition_provenance function_id
      (Gfun (Internal body)) Hbody). }
  exact (us_source_evar_resolves_in_official_target function_id body global_id
    Hsource_body Hoccurs Hnotlocal).
Qed.

Theorem jp_official_internal_body_evar_resolves :
  forall function_id body global_id,
    In (function_id, Gfun (Internal body))
      (prog_defs jp_official_cleaned_slice) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice) global_id =
        Some linked_block.
Proof.
  intros function_id body global_id Hbody Hoccurs Hnotlocal.
  assert (Hsource_body :
    In (function_id, Gfun (Internal body))
      (unit_global_definitions jp_units)).
  { exact (jp_official_source_definition_provenance function_id
      (Gfun (Internal body)) Hbody). }
  exact (jp_source_evar_resolves_in_official_target function_id body global_id
    Hsource_body Hoccurs Hnotlocal).
Qed.

Lemma official_definition_provenance_transfers_init_addrof_occurrence :
  forall source_units linked referenced_id,
    OfficialSourceDefinitionProvenance source_units linked ->
    In referenced_id (program_init_addrof_identifiers linked) ->
    In referenced_id (source_union_init_addrof_identifiers source_units).
Proof.
  intros source_units linked referenced_id Hprovenance Hin.
  unfold program_init_addrof_identifiers in Hin.
  apply in_concat in Hin.
  destruct Hin as [identifiers [Hidentifiers Hreferenced]].
  apply in_map_iff in Hidentifiers.
  destruct Hidentifiers as [[definition_id definition]
    [Hidentifiers Hdefinition]].
  subst identifiers.
  specialize (Hprovenance definition_id definition Hdefinition).
  unfold source_union_init_addrof_identifiers.
  apply in_concat.
  exists (global_definition_init_addrof_identifiers
    (definition_id, definition)).
  split; [now apply in_map | exact Hreferenced].
Qed.

Theorem us_official_init_addrof_identifier_resolves :
  forall id,
    In id (program_init_addrof_identifiers us_official_cleaned_slice) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv us_official_cleaned_slice) id =
        Some linked_block.
Proof.
  intros id Hin.
  assert (Hsource :
    In id (source_union_init_addrof_identifiers us_units)).
  { exact (official_definition_provenance_transfers_init_addrof_occurrence
      us_units us_official_cleaned_slice id
      us_official_source_definition_provenance Hin). }
  exact (us_source_init_addrof_resolves_in_official_target id Hsource).
Qed.

Theorem jp_official_init_addrof_identifier_resolves :
  forall id,
    In id (program_init_addrof_identifiers jp_official_cleaned_slice) ->
    exists linked_block,
      Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice) id =
        Some linked_block.
Proof.
  intros id Hin.
  assert (Hsource :
    In id (source_union_init_addrof_identifiers jp_units)).
  { exact (official_definition_provenance_transfers_init_addrof_occurrence
      jp_units jp_official_cleaned_slice id
      jp_official_source_definition_provenance Hin). }
  exact (jp_source_init_addrof_resolves_in_official_target id Hsource).
Qed.

Definition source_global_external_constructors_complete
    (source_units : nlist Clight.program) : bool :=
  forallb external_global_has_supported_constructor
    (unit_global_definitions source_units).

Theorem us_source_global_external_constructors_complete :
  source_global_external_constructors_complete us_units = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_source_global_external_constructors_complete :
  source_global_external_constructors_complete jp_units = true.
Proof. vm_compute. reflexivity. Qed.

Lemma checked_source_definition_external_has_supported_constructor :
  forall source_units id external argument_types result_type
      calling_convention,
    source_global_external_constructors_complete source_units = true ->
    In (id, Gfun (External external argument_types result_type
      calling_convention)) (unit_global_definitions source_units) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros source_units id external argument_types result_type
    calling_convention Hall Hin.
  unfold source_global_external_constructors_complete in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall _ Hin).
  cbn [external_global_has_supported_constructor] in Hall.
  destruct external; try discriminate; eauto 8.
Qed.

Theorem official_target_external_has_source_checked_constructor :
  forall source_units linked id external argument_types result_type
      calling_convention,
    OfficialSourceDefinitionProvenance source_units linked ->
    source_global_external_constructors_complete source_units = true ->
    In (id, Gfun (External external argument_types result_type
      calling_convention)) (prog_defs linked) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros source_units linked id external argument_types result_type
    calling_convention Hprovenance Hall Hin.
  exact (checked_source_definition_external_has_supported_constructor
    source_units id external argument_types result_type calling_convention
    Hall (Hprovenance id
      (Gfun (External external argument_types result_type calling_convention))
      Hin)).
Qed.

Theorem us_official_external_has_supported_constructor :
  forall id external argument_types result_type calling_convention,
    In (id, Gfun (External external argument_types result_type
      calling_convention)) (prog_defs us_official_cleaned_slice) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros id external argument_types result_type calling_convention Hin.
  exact (official_target_external_has_source_checked_constructor
    us_units us_official_cleaned_slice id external argument_types result_type
    calling_convention us_official_source_definition_provenance
    us_source_global_external_constructors_complete Hin).
Qed.

Theorem jp_official_external_has_supported_constructor :
  forall id external argument_types result_type calling_convention,
    In (id, Gfun (External external argument_types result_type
      calling_convention)) (prog_defs jp_official_cleaned_slice) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros id external argument_types result_type calling_convention Hin.
  exact (official_target_external_has_source_checked_constructor
    jp_units jp_official_cleaned_slice id external argument_types result_type
    calling_convention jp_official_source_definition_provenance
    jp_source_global_external_constructors_complete Hin).
Qed.

Definition is_true_ef_external_global_definition
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (External (EF_external _ _) _ _ _) => true
  | _ => false
  end.

Definition is_ef_builtin_global_definition
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (External (EF_builtin _ _) _ _ _) => true
  | _ => false
  end.

Definition is_ef_runtime_global_definition
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (External (EF_runtime _ _) _ _ _) => true
  | _ => false
  end.

Definition true_unresolved_external_identifiers
    (program : Clight.program) : list ident :=
  map fst
    (filter is_true_ef_external_global_definition (prog_defs program)).

(** The executable list above is an exact inventory, not merely a count.
    Membership is equivalent to an [EF_external] definition when the program
    definition names are unique. *)
Lemma true_unresolved_external_identifier_sound :
  forall (program : Clight.program) id,
    list_norepet (prog_defs_names program) ->
    In id (true_unresolved_external_identifiers program) ->
    exists name signature argument_types result_type calling_convention,
      (prog_defmap program) ! id =
        Some (Gfun (External (EF_external name signature)
          argument_types result_type calling_convention)).
Proof.
  intros program id Hnorepet Hinventory.
  unfold true_unresolved_external_identifiers in Hinventory.
  apply in_map_iff in Hinventory.
  destruct Hinventory as [[entry_id definition] [Hid Hfiltered]].
  cbn in Hid. subst entry_id.
  apply filter_In in Hfiltered.
  destruct Hfiltered as [Hentry Hkind].
  destruct definition as [definition | variable]; try discriminate.
  destruct definition as [body | external argument_types result_type
      calling_convention]; try discriminate.
  destruct external; try discriminate.
  exists name, sg, argument_types, result_type, calling_convention.
  eapply prog_defmap_norepet; eauto.
Qed.

Lemma true_unresolved_external_identifier_complete :
  forall (program : Clight.program) id name signature argument_types result_type
      calling_convention,
    (prog_defmap program) ! id =
      Some (Gfun (External (EF_external name signature)
        argument_types result_type calling_convention)) ->
    In id (true_unresolved_external_identifiers program).
Proof.
  intros program id name signature argument_types result_type
    calling_convention Hdefinition.
  unfold true_unresolved_external_identifiers.
  apply in_map_iff.
  exists (id, Gfun (External (EF_external name signature)
    argument_types result_type calling_convention)).
  split; [reflexivity |].
  apply filter_In. split.
  - now apply in_prog_defmap in Hdefinition.
  - reflexivity.
Qed.

Theorem us_normalized_external_definition_count :
  length (external_definition_identifiers us_normalized_semantic_slice) =
    227%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_external_definition_count :
  length (external_definition_identifiers jp_normalized_semantic_slice) =
    226%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_normalized_true_unresolved_external_count :
  length
    (true_unresolved_external_identifiers us_normalized_semantic_slice) =
  133%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_true_unresolved_external_count :
  length
    (true_unresolved_external_identifiers jp_normalized_semantic_slice) =
  132%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_normalized_external_constructor_partition :
  (length (filter is_true_ef_external_global_definition
      (prog_defs us_normalized_semantic_slice)),
   length (filter is_ef_builtin_global_definition
      (prog_defs us_normalized_semantic_slice)),
   length (filter is_ef_runtime_global_definition
      (prog_defs us_normalized_semantic_slice))) =
  (133%nat, 75%nat, 19%nat).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_external_constructor_partition :
  (length (filter is_true_ef_external_global_definition
      (prog_defs jp_normalized_semantic_slice)),
   length (filter is_ef_builtin_global_definition
      (prog_defs jp_normalized_semantic_slice)),
   length (filter is_ef_runtime_global_definition
      (prog_defs jp_normalized_semantic_slice))) =
  (132%nat, 75%nat, 19%nat).
Proof. vm_compute. reflexivity. Qed.

Theorem us_normalized_global_external_constructors_complete :
  forallb external_global_has_supported_constructor
    (prog_defs us_normalized_semantic_slice) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_global_external_constructors_complete :
  forallb external_global_has_supported_constructor
    (prog_defs jp_normalized_semantic_slice) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma checked_program_external_has_supported_constructor :
  forall (program : Clight.program) id external argument_types result_type
      calling_convention,
    list_norepet (prog_defs_names program) ->
    forallb external_global_has_supported_constructor
      (prog_defs program) = true ->
    (prog_defmap program) ! id =
      Some (Gfun (External external argument_types result_type
        calling_convention)) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros program id external argument_types result_type calling_convention
    Hnorepet Hall Hdefinition.
  pose proof Hdefinition as Hin.
  apply in_prog_defmap in Hin.
  apply forallb_forall with
    (x := (id, Gfun (External external argument_types result_type
      calling_convention))) in Hall; auto.
  cbn [external_global_has_supported_constructor] in Hall.
  destruct external; try discriminate; eauto 8.
Qed.

Theorem global_definition_map_agreement_transfers_external_constructor :
  forall source linked id external argument_types result_type
      calling_convention,
    GlobalDefinitionMapAgreement source linked ->
    list_norepet (prog_defs_names source) ->
    forallb external_global_has_supported_constructor
      (prog_defs source) = true ->
    (prog_defmap linked) ! id =
      Some (Gfun (External external argument_types result_type
        calling_convention)) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros source linked id external argument_types result_type
    calling_convention Hagree Hnorepet Hall Hlinked.
  eapply checked_program_external_has_supported_constructor;
    [exact Hnorepet | exact Hall |].
  exact (eq_trans (Hagree id) Hlinked).
Qed.

(** * Direct [Sbuiltin] census *)

(** A direct [Sbuiltin] does not pass through a global [External] fundef, so
    it needs a separate, body-recursive census. *)
Fixpoint statement_direct_sbuiltins (statement : statement) :
    list external_function :=
  match statement with
  | Sbuiltin _ external _ _ => [external]
  | Ssequence first second | Sloop first second =>
      statement_direct_sbuiltins first ++ statement_direct_sbuiltins second
  | Sifthenelse _ yes_branch no_branch =>
      statement_direct_sbuiltins yes_branch ++
      statement_direct_sbuiltins no_branch
  | Sswitch _ cases => labeled_statements_direct_sbuiltins cases
  | Slabel _ body => statement_direct_sbuiltins body
  | _ => []
  end
with labeled_statements_direct_sbuiltins (cases : labeled_statements) :
    list external_function :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      statement_direct_sbuiltins body ++
      labeled_statements_direct_sbuiltins rest
  end.

Definition global_definition_direct_sbuiltins
    (entry : ident * globdef Clight.fundef type) : list external_function :=
  match snd entry with
  | Gfun (Internal body) => statement_direct_sbuiltins (fn_body body)
  | _ => []
  end.

Definition program_direct_sbuiltins (program : Clight.program) :
    list external_function :=
  concat (map global_definition_direct_sbuiltins (prog_defs program)).

Definition source_union_direct_sbuiltins
    (source_units : nlist Clight.program) : list external_function :=
  concat (map global_definition_direct_sbuiltins
    (unit_global_definitions source_units)).

Theorem us_source_union_has_no_direct_sbuiltin :
  source_union_direct_sbuiltins us_units = [].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_source_union_has_no_direct_sbuiltin :
  source_union_direct_sbuiltins jp_units = [].
Proof. vm_compute. reflexivity. Qed.

Definition defmap_internal_bodies_have_no_direct_sbuiltin
    (program : Clight.program) : Prop :=
  forall id body,
    (prog_defmap program) ! id = Some (Gfun (Internal body)) ->
    statement_direct_sbuiltins (fn_body body) = [].

Lemma empty_program_direct_sbuiltin_inventory_implies_defmap_empty :
  forall program,
    program_direct_sbuiltins program = [] ->
    defmap_internal_bodies_have_no_direct_sbuiltin program.
Proof.
  intros program Hempty id body Hbody.
  apply in_prog_defmap in Hbody.
  destruct (statement_direct_sbuiltins (fn_body body))
    as [| external rest] eqn:Hbuiltins; auto.
  exfalso.
  assert (Hexternal : In external (program_direct_sbuiltins program)).
  {
    unfold program_direct_sbuiltins. apply in_concat.
    exists (global_definition_direct_sbuiltins
      (id, Gfun (Internal body))).
    split; [now apply in_map |].
    change (In external (statement_direct_sbuiltins (fn_body body))).
    rewrite Hbuiltins. now left.
  }
  rewrite Hempty in Hexternal. contradiction.
Qed.

Theorem global_definition_map_agreement_transfers_no_direct_sbuiltin :
  forall source linked,
    GlobalDefinitionMapAgreement source linked ->
    defmap_internal_bodies_have_no_direct_sbuiltin source ->
    defmap_internal_bodies_have_no_direct_sbuiltin linked.
Proof.
  intros source linked Hagree Hsource id body Hlinked.
  exact (Hsource id body (eq_trans (Hagree id) Hlinked)).
Qed.

Lemma official_definition_provenance_transfers_no_direct_sbuiltin :
  forall source_units linked,
    OfficialSourceDefinitionProvenance source_units linked ->
    source_union_direct_sbuiltins source_units = [] ->
    program_direct_sbuiltins linked = [].
Proof.
  intros source_units linked Hprovenance Hsource.
  destruct (program_direct_sbuiltins linked)
    as [| external rest] eqn:Htarget; auto.
  exfalso.
  assert (Hexternal_target :
    In external (program_direct_sbuiltins linked)).
  { rewrite Htarget. now left. }
  unfold program_direct_sbuiltins in Hexternal_target.
  apply in_concat in Hexternal_target.
  destruct Hexternal_target as [builtins [Hbuiltins Hexternal]].
  apply in_map_iff in Hbuiltins.
  destruct Hbuiltins as [[id definition] [Hbuiltins Hdefinition]].
  subst builtins.
  specialize (Hprovenance id definition Hdefinition).
  assert (Hexternal_source :
    In external (source_union_direct_sbuiltins source_units)).
  {
    unfold source_union_direct_sbuiltins.
    apply in_concat.
    exists (global_definition_direct_sbuiltins (id, definition)).
    split; [now apply in_map | exact Hexternal].
  }
  rewrite Hsource in Hexternal_source. contradiction.
Qed.

Theorem us_official_target_has_no_direct_sbuiltin :
  program_direct_sbuiltins us_official_cleaned_slice = [].
Proof.
  exact (official_definition_provenance_transfers_no_direct_sbuiltin
    us_units us_official_cleaned_slice
    us_official_source_definition_provenance
    us_source_union_has_no_direct_sbuiltin).
Qed.

Theorem jp_official_target_has_no_direct_sbuiltin :
  program_direct_sbuiltins jp_official_cleaned_slice = [].
Proof.
  exact (official_definition_provenance_transfers_no_direct_sbuiltin
    jp_units jp_official_cleaned_slice
    jp_official_source_definition_provenance
    jp_source_union_has_no_direct_sbuiltin).
Qed.

(** * Reachable call-state provenance *)

Definition callstate_resolved (ge : Clight.genv) (state : Clight.state) : Prop :=
  match state with
  | Callstate definition _ _ _ =>
      exists block, Genv.find_funct_ptr ge block = Some definition
  | _ => True
  end.

Lemma clight_step_target_callstate_resolved :
  forall (ge : Clight.genv) before trace definition arguments continuation memory,
    Clight.step2 ge before trace
      (Callstate definition arguments continuation memory) ->
    exists block, Genv.find_funct_ptr ge block = Some definition.
Proof.
  intros ge before trace definition arguments continuation memory Hstep.
  inversion Hstep; subst.
  exploit Genv.find_funct_inv; eauto.
  intros [block Hvalue]. subst.
  exists block.
  rewrite Genv.find_funct_find_funct_ptr in *.
  assumption.
Qed.

Lemma clight_step_preserves_callstate_resolution :
  forall (ge : Clight.genv) before trace after,
    Clight.step2 ge before trace after ->
    callstate_resolved ge after.
Proof.
  intros ge before trace after Hstep.
  destruct after; cbn [callstate_resolved]; auto.
  eapply clight_step_target_callstate_resolved; eauto.
Qed.

Lemma clight_initial_state_callstate_resolved :
  forall program state,
    Clight.initial_state program state ->
    callstate_resolved (Clight.globalenv program) state.
Proof.
  intros program state Hinitial.
  inversion Hinitial; subst.
  cbn [callstate_resolved].
  eauto.
Qed.

Theorem clight_reachable_callstate_resolved :
  forall program initial trace state,
    Clight.initial_state program initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial trace state ->
    callstate_resolved (Clight.globalenv program) state.
Proof.
  intros program initial trace state Hinitial Hstar.
  pose proof
    (clight_initial_state_callstate_resolved program initial Hinitial)
    as Hresolved.
  clear Hinitial.
  revert Hresolved.
  induction Hstar; intros Hresolved.
  - exact Hresolved.
  - apply IHHstar.
    eapply clight_step_preserves_callstate_resolution; eauto.
Qed.

Theorem clight_reachable_external_callstate_has_program_entry :
  forall program initial trace external argument_types result_type
      calling_convention arguments continuation memory,
    Clight.initial_state program initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation memory) ->
    exists id,
      In (id, Gfun (External external argument_types result_type
        calling_convention)) (prog_defs program).
Proof.
  intros program initial trace external argument_types result_type
    calling_convention arguments continuation memory Hinitial Hstar.
  pose proof (clight_reachable_callstate_resolved program initial trace _
    Hinitial Hstar) as Hresolved.
  cbn [callstate_resolved] in Hresolved.
  destruct Hresolved as [block Hfunction].
  now apply Genv.find_funct_ptr_inversion in Hfunction.
Qed.

(** Package reachable-entry provenance with an abstract constructor census
    before specializing a concrete linked program.  This opaque boundary keeps
    the US/JP corollaries from normalizing the complete generated definition
    list while checking the application. *)
Theorem clight_reachable_external_callstate_is_classified :
  forall program initial trace external argument_types result_type
      calling_convention arguments continuation memory,
    (forall id,
      In (id, Gfun (External external argument_types result_type
        calling_convention)) (prog_defs program) ->
      (exists name signature, external = EF_external name signature) \/
      (exists name signature, external = EF_builtin name signature) \/
      (exists name signature, external = EF_runtime name signature)) ->
    Clight.initial_state program initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation memory) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros program initial trace external argument_types result_type
    calling_convention arguments continuation memory Hclassified
    Hinitial Hstar.
  destruct (clight_reachable_external_callstate_has_program_entry
    program initial trace external argument_types result_type
    calling_convention arguments continuation memory Hinitial Hstar)
    as [id Hentry].
  exact (Hclassified id Hentry).
Qed.

Theorem us_reachable_official_external_callstate_is_classified :
  forall initial trace external argument_types result_type
      calling_convention arguments continuation memory,
    Clight.initial_state us_official_cleaned_slice initial ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv us_official_cleaned_slice)
      initial trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation memory) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros initial trace external argument_types result_type calling_convention
    arguments continuation memory Hinitial Hstar.
  exact (clight_reachable_external_callstate_is_classified
    us_official_cleaned_slice initial trace external argument_types
    result_type calling_convention arguments continuation memory
    (fun id => us_official_external_has_supported_constructor id external
      argument_types result_type calling_convention)
    Hinitial Hstar).
Qed.

Theorem jp_reachable_official_external_callstate_is_classified :
  forall initial trace external argument_types result_type
      calling_convention arguments continuation memory,
    Clight.initial_state jp_official_cleaned_slice initial ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      initial trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation memory) ->
    (exists name signature, external = EF_external name signature) \/
    (exists name signature, external = EF_builtin name signature) \/
    (exists name signature, external = EF_runtime name signature).
Proof.
  intros initial trace external argument_types result_type calling_convention
    arguments continuation memory Hinitial Hstar.
  exact (clight_reachable_external_callstate_is_classified
    jp_official_cleaned_slice initial trace external argument_types
    result_type calling_convention arguments continuation memory
    (fun id => jp_official_external_has_supported_constructor id external
      argument_types result_type calling_convention)
    Hinitial Hstar).
Qed.

Theorem clight_reachable_external_callstate_has_program_identifier :
  forall (program : Clight.program) initial trace external argument_types result_type
      calling_convention arguments continuation memory,
    list_norepet (prog_defs_names program) ->
    Clight.initial_state program initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation memory) ->
    exists id,
      (prog_defmap program) ! id =
        Some (Gfun (External external argument_types result_type
          calling_convention)).
Proof.
  intros program initial trace external argument_types result_type
    calling_convention arguments continuation memory Hnorepet Hinitial Hstar.
  pose proof
    (clight_reachable_callstate_resolved program initial trace _
      Hinitial Hstar) as Hresolved.
  cbn [callstate_resolved] in Hresolved.
  destruct Hresolved as [block Hfunction].
  pose proof Hfunction as Hin.
  apply Genv.find_funct_ptr_inversion in Hin.
  destruct Hin as [id Hin].
  exists id.
  eapply prog_defmap_norepet; eauto.
Qed.

(** Combining reachable-call provenance with an official link classifies the
    three global-External constructors retained by the selected programs and
    proves that none hides an input-unit internal body.  The first disjunct is
    the genuine unresolved-[EF_external] case; builtins and runtime helpers are
    kept separate. *)
Theorem official_link_reachable_external_callstate_is_classified_and_unresolved :
  forall (units : nlist Clight.program) (linked : Clight.program)
      initial trace external argument_types result_type
      calling_convention arguments continuation memory,
    link_list units = Some linked ->
    list_norepet (prog_defs_names linked) ->
    forallb external_global_has_supported_constructor
      (prog_defs linked) = true ->
    Clight.initial_state linked initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv linked)
      initial trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation memory) ->
    exists id,
      ((exists name signature, external = EF_external name signature) \/
       (exists name signature, external = EF_builtin name signature) \/
       (exists name signature, external = EF_runtime name signature)) /\
      (prog_defmap linked) ! id =
        Some (Gfun (External external argument_types result_type
          calling_convention)) /\
      forall unit body,
        nIn unit units ->
        (prog_defmap unit) ! id <> Some (Gfun (Internal body)).
Proof.
  intros units linked initial trace external argument_types result_type
    calling_convention arguments continuation memory Hlink Hnorepet
    Hall Hinitial Hreachable.
  destruct (clight_reachable_external_callstate_has_program_identifier
              linked initial trace external argument_types result_type
              calling_convention arguments continuation memory
              Hnorepet Hinitial Hreachable)
    as [id Hdefinition].
  pose proof
    (checked_program_external_has_supported_constructor linked id external
      argument_types result_type calling_convention Hnorepet Hall Hdefinition)
    as Hconstructor.
  exists id.
  split; [exact Hconstructor |].
  split; [exact Hdefinition |].
  intros unit body Hunit.
  eapply official_link_external_definition_has_no_internal_source; eauto.
Qed.

(** * External-call frames and a checked local small-step consequence *)

(** A frame is stated directly as CompCert's byte-level [Mem.unchanged_on].
    It is local to one [external_function] and one protected footprint.  This
    is not a star-impossibility oracle and says nothing about internal stores. *)
Definition ExternalCallFrame
    (protected : block -> Z -> Prop) (external : external_function) : Prop :=
  forall ge arguments before trace result after,
    external_call external ge arguments before trace result after ->
    Mem.unchanged_on protected before after.

(** The remaining frame obligation is indexed by the concrete program
    definitions.  It asks for a byte-level frame only for genuine unresolved
    [EF_external] definitions; [EF_builtin] and [EF_runtime] calls stay in
    their distinct CompCert cases. *)
Definition TrueUnresolvedExternalFrames
    (program : Clight.program) (protected : block -> Z -> Prop) : Prop :=
  forall id name signature argument_types result_type calling_convention,
    (prog_defmap program) ! id =
      Some (Gfun (External (EF_external name signature)
        argument_types result_type calling_convention)) ->
    ExternalCallFrame protected (EF_external name signature).

(** Environment transport and writable-memory framing are independent.
    [external_call_symbols_preserved] reuses the very same call only when the
    two symbol environments are equivalent. *)
Theorem external_call_executes_in_equivalent_environment :
  forall external source_ge target_ge arguments before trace result after,
    Senv.equiv source_ge target_ge ->
    external_call external source_ge arguments before trace result after ->
    external_call external target_ge arguments before trace result after.
Proof.
  intros external source_ge target_ge arguments before trace result after
    Hequivalent Hcall.
  eapply external_call_symbols_preserved; eauto.
Qed.

(** For name-related but differently allocated programs, CompCert's actual
    execution principle is memory injection, not same-block identity.  The
    result includes the two precise unchanged regions guaranteed by CompCert;
    neither region is an arbitrary writable Mario/Object footprint. *)
Theorem external_call_executes_under_memory_injection :
  forall external source_ge target_ge source_arguments source_before trace
      source_result source_after injection target_before target_arguments,
    symbols_inject injection source_ge target_ge ->
    external_call external source_ge source_arguments source_before trace
      source_result source_after ->
    Mem.inject injection source_before target_before ->
    Val.inject_list injection source_arguments target_arguments ->
    exists injection' target_result target_after,
      external_call external target_ge target_arguments target_before trace
        target_result target_after /\
      Val.inject injection' source_result target_result /\
      Mem.inject injection' source_after target_after /\
      Mem.unchanged_on (loc_unmapped injection) source_before source_after /\
      Mem.unchanged_on (loc_out_of_reach injection source_before)
        target_before target_after /\
      inject_incr injection injection' /\
      inject_separated injection injection' source_before target_before.
Proof.
  intros external source_ge target_ge source_arguments source_before trace
    source_result source_after injection target_before target_arguments
    Hsymbols Hcall Hmemory Harguments.
  eapply external_call_mem_inject_gen; eauto.
Qed.

Theorem external_call_executes_across_global_interface :
  forall source linked external source_arguments source_before trace
      source_result source_after target_before target_arguments,
    GlobalDefinitionMapAgreement source linked ->
    PublicIdentifierAgreement source linked ->
    Mem.inject (symbol_block_map source linked) source_before target_before ->
    Val.inject_list (symbol_block_map source linked)
      source_arguments target_arguments ->
    external_call external (Clight.globalenv source) source_arguments
      source_before trace source_result source_after ->
    exists injection' target_result target_after,
      external_call external (Clight.globalenv linked) target_arguments
        target_before trace target_result target_after /\
      Val.inject injection' source_result target_result /\
      Mem.inject injection' source_after target_after /\
      Mem.unchanged_on (loc_unmapped (symbol_block_map source linked))
        source_before source_after /\
      Mem.unchanged_on
        (loc_out_of_reach (symbol_block_map source linked) source_before)
        target_before target_after /\
      inject_incr (symbol_block_map source linked) injection' /\
      inject_separated (symbol_block_map source linked) injection'
        source_before target_before.
Proof.
  intros source linked external source_arguments source_before trace
    source_result source_after target_before target_arguments Hdefinitions
    Hpublic Hmemory Harguments Hcall.
  eapply external_call_executes_under_memory_injection; eauto.
  now apply global_interface_agreement_is_external_environment_injection.
Qed.

Lemma clight_external_callstate_step_inv :
  forall (ge : Clight.genv) external argument_types result_type calling_convention
      arguments continuation before trace after_state,
    Clight.step2 ge
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before)
      trace after_state ->
    exists result after,
      after_state = Returnstate result continuation after /\
      external_call external ge arguments before trace result after.
Proof.
  intros ge external argument_types result_type calling_convention arguments
    continuation before trace after_state Hstep.
  inversion Hstep; subst; eauto.
Qed.

(** A [Callstate (External ...)] step can therefore be replayed in a linked
    environment using injected arguments and memory.  Continuations are
    deliberately independent: an external call does not inspect them, and a
    whole-program simulation must relate them separately. *)
Theorem clight_external_callstate_step_injects :
  forall (source_ge target_ge : Clight.genv) external argument_types result_type
      calling_convention source_arguments target_arguments
      source_continuation target_continuation source_before target_before
      trace source_after_state injection,
    symbols_inject injection source_ge target_ge ->
    Mem.inject injection source_before target_before ->
    Val.inject_list injection source_arguments target_arguments ->
    Clight.step2 source_ge
      (Callstate (External external argument_types result_type
        calling_convention) source_arguments source_continuation source_before)
      trace source_after_state ->
    exists injection' source_result source_after target_result target_after,
      source_after_state =
        Returnstate source_result source_continuation source_after /\
      Clight.step2 target_ge
        (Callstate (External external argument_types result_type
          calling_convention) target_arguments target_continuation target_before)
        trace (Returnstate target_result target_continuation target_after) /\
      Val.inject injection' source_result target_result /\
      Mem.inject injection' source_after target_after /\
      Mem.unchanged_on (loc_unmapped injection) source_before source_after /\
      Mem.unchanged_on (loc_out_of_reach injection source_before)
        target_before target_after /\
      inject_incr injection injection' /\
      inject_separated injection injection' source_before target_before.
Proof.
  intros source_ge target_ge external argument_types result_type
    calling_convention source_arguments target_arguments source_continuation
    target_continuation source_before target_before trace source_after_state
    injection Hsymbols Hmemory Harguments Hstep.
  destruct (clight_external_callstate_step_inv source_ge external
    argument_types result_type calling_convention source_arguments
    source_continuation source_before trace source_after_state Hstep)
    as [source_result [source_after [Hstate Hcall]]].
  destruct (external_call_executes_under_memory_injection external source_ge
    target_ge source_arguments source_before trace source_result source_after
    injection target_before target_arguments Hsymbols Hcall Hmemory Harguments)
    as [injection' [target_result [target_after
      (Htarget_call & Hresult & Htarget_memory & Hunmapped & Hout_of_reach &
       Hincr & Hseparated)]]].
  exists injection', source_result, source_after, target_result, target_after.
  split; [exact Hstate |].
  split.
  - now constructor.
  - split; [exact Hresult |].
    split; [exact Htarget_memory |].
    split; [exact Hunmapped |].
    split; [exact Hout_of_reach |].
    split; [exact Hincr |].
    exact Hseparated.
Qed.

(** [Sbuiltin] bypasses [Callstate]: its [external_call] is performed in the
    statement step itself.  The following inversion keeps that execution path
    in the frame boundary instead of silently treating every external effect
    as a resolved global-function call. *)
Lemma clight_sbuiltin_step_inv :
  forall (ge : Clight.genv) function optid external argument_types arguments continuation
      environment local_environment before trace after_state,
    Clight.step2 ge
      (State function
        (Sbuiltin optid external argument_types arguments)
        continuation environment local_environment before)
      trace after_state ->
    exists (argument_values : list val) result after,
      @eval_exprlist ge environment local_environment before
        arguments argument_types argument_values /\
      external_call external ge argument_values before trace result after /\
      after_state =
        State function Sskip continuation environment
          (set_opttemp optid result local_environment) after.
Proof.
  intros ge function optid external argument_types arguments continuation
    environment local_environment before trace after_state Hstep.
  inversion Hstep; subst.
  exists vargs, vres, m'.
  split; [assumption |].
  split; [assumption |].
  reflexivity.
  all: match goal with
  | Himpossible :
      Sbuiltin _ _ _ _ = Sskip \/ Sbuiltin _ _ _ _ = Scontinue |- _ =>
      destruct Himpossible; discriminate
  | Himpossible :
      Sbuiltin _ _ _ _ = Sskip \/ Sbuiltin _ _ _ _ = Sbreak |- _ =>
      destruct Himpossible; discriminate
  end.
Qed.

(** Expression evaluation is a distinct part of the source-to-linked
    simulation.  This predicate says exactly what the direct-builtin case
    consumes after the target expression list has been evaluated. *)
Definition BuiltinArgumentEvaluationInjection
    (source_ge target_ge : Clight.genv) (injection : meminj)
    (source_environment target_environment : env)
    (source_locals target_locals : temp_env)
    (source_memory target_memory : mem)
    (arguments : list expr) (argument_types : list type)
    (target_values : list val) : Prop :=
  @eval_exprlist target_ge target_environment target_locals target_memory
    arguments argument_types target_values /\
  forall source_values,
    @eval_exprlist source_ge source_environment source_locals source_memory
      arguments argument_types source_values ->
    Val.inject_list injection source_values target_values.

(** Direct [Sbuiltin] execution uses the same CompCert injection theorem once
    expression evaluation has supplied injected arguments.  Thus this closes
    the external-call part of the case while leaving expression/environment
    refinement explicit. *)
Theorem clight_sbuiltin_step_injects_after_argument_evaluation :
  forall (source_ge target_ge : Clight.genv)
      source_function target_function optid external
      argument_types arguments source_continuation target_continuation
      source_environment target_environment source_locals target_locals
      source_before target_before trace source_after_state injection
      target_argument_values,
    symbols_inject injection source_ge target_ge ->
    Mem.inject injection source_before target_before ->
    BuiltinArgumentEvaluationInjection source_ge target_ge injection
      source_environment target_environment source_locals target_locals
      source_before target_before arguments argument_types
      target_argument_values ->
    Clight.step2 source_ge
      (State source_function
        (Sbuiltin optid external argument_types arguments)
        source_continuation source_environment source_locals source_before)
      trace source_after_state ->
    exists injection' source_argument_values source_result source_after
        target_result target_after,
      source_after_state =
        State source_function Sskip source_continuation source_environment
          (set_opttemp optid source_result source_locals) source_after /\
      Clight.step2 target_ge
        (State target_function
          (Sbuiltin optid external argument_types arguments)
          target_continuation target_environment target_locals target_before)
        trace
        (State target_function Sskip target_continuation target_environment
          (set_opttemp optid target_result target_locals) target_after) /\
      Val.inject_list injection source_argument_values target_argument_values /\
      Val.inject injection' source_result target_result /\
      Mem.inject injection' source_after target_after /\
      Mem.unchanged_on (loc_unmapped injection) source_before source_after /\
      Mem.unchanged_on (loc_out_of_reach injection source_before)
        target_before target_after /\
      inject_incr injection injection' /\
      inject_separated injection injection' source_before target_before.
Proof.
  intros source_ge target_ge source_function target_function optid external
    argument_types arguments source_continuation target_continuation
    source_environment target_environment source_locals target_locals
    source_before target_before trace source_after_state injection
    target_argument_values Hsymbols Hmemory [Htarget_eval Harguments] Hstep.
  destruct (clight_sbuiltin_step_inv source_ge source_function optid external
    argument_types arguments source_continuation source_environment
    source_locals source_before trace source_after_state Hstep)
    as [source_argument_values [source_result [source_after
      [Hsource_eval [Hsource_call Hsource_state]]]]].
  specialize (Harguments source_argument_values Hsource_eval).
  destruct (external_call_executes_under_memory_injection external source_ge
    target_ge source_argument_values source_before trace source_result
    source_after injection target_before target_argument_values Hsymbols
    Hsource_call Hmemory Harguments)
    as [injection' [target_result [target_after
      (Htarget_call & Hresult & Htarget_memory & Hunmapped & Hout_of_reach &
       Hincr & Hseparated)]]].
  exists injection', source_argument_values, source_result, source_after,
    target_result, target_after.
  split.
  - exact Hsource_state.
  - split.
    + eapply Clight.step_builtin.
      * exact Htarget_eval.
      * exact Htarget_call.
    + split; [exact Harguments |].
      split; [exact Hresult |].
      split; [exact Htarget_memory |].
      split; [exact Hunmapped |].
      split; [exact Hout_of_reach |].
      split; [exact Hincr |].
      exact Hseparated.
Qed.

Theorem clight_sbuiltin_step_obeys_explicit_frame :
  forall protected (ge : Clight.genv)
      function optid external argument_types arguments
      continuation environment local_environment before trace after_state,
    ExternalCallFrame protected external ->
    Clight.step2 ge
      (State function
        (Sbuiltin optid external argument_types arguments)
        continuation environment local_environment before)
      trace after_state ->
    exists (argument_values : list val) result after,
      @eval_exprlist ge environment local_environment before
        arguments argument_types argument_values /\
      external_call external ge argument_values before trace result after /\
      after_state =
        State function Sskip continuation environment
          (set_opttemp optid result local_environment) after /\
      Mem.unchanged_on protected before after.
Proof.
  intros protected ge function optid external argument_types arguments
    continuation environment local_environment before trace after_state
    Hframe Hstep.
  destruct (clight_sbuiltin_step_inv ge function optid external
    argument_types arguments continuation environment local_environment
    before trace after_state Hstep)
    as [argument_values [result [after [Heval [Hcall Hstate]]]]].
  exists argument_values, result, after.
  split; [exact Heval |].
  split; [exact Hcall |].
  split; [exact Hstate |].
  unfold ExternalCallFrame in Hframe.
  exact (Hframe ge argument_values before trace result after Hcall).
Qed.

Theorem clight_external_callstate_obeys_explicit_frame :
  forall protected (ge : Clight.genv)
      external argument_types result_type calling_convention
      arguments continuation before trace result after,
    ExternalCallFrame protected external ->
    Clight.step2 ge
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before)
      trace (Returnstate result continuation after) ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected ge external argument_types result_type calling_convention
    arguments continuation before trace result after Hframe Hstep.
  destruct (clight_external_callstate_step_inv ge external argument_types
              result_type calling_convention arguments continuation before
              trace _ Hstep) as [actual_result [actual_after [Heq Hcall]]].
  inversion Heq; subst.
  unfold ExternalCallFrame in Hframe.
  exact (Hframe ge arguments before trace actual_result actual_after Hcall).
Qed.

Theorem clight_reachable_true_external_step_obeys_inventory_frame :
  forall (program : Clight.program) protected initial reach_trace name signature
      argument_types
      result_type calling_convention arguments continuation before step_trace
      result after,
    list_norepet (prog_defs_names program) ->
    TrueUnresolvedExternalFrames program protected ->
    Clight.initial_state program initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial reach_trace
      (Callstate (External (EF_external name signature) argument_types
        result_type calling_convention) arguments continuation before) ->
    Clight.step2 (Clight.globalenv program)
      (Callstate (External (EF_external name signature) argument_types
        result_type calling_convention) arguments continuation before)
      step_trace (Returnstate result continuation after) ->
    Mem.unchanged_on protected before after.
Proof.
  intros program protected initial reach_trace name signature argument_types
    result_type calling_convention arguments continuation before step_trace
    result after Hnorepet Hframes Hinitial Hreachable Hstep.
  destruct (clight_reachable_external_callstate_has_program_identifier
    program initial reach_trace (EF_external name signature) argument_types
    result_type calling_convention arguments continuation before Hnorepet
    Hinitial Hreachable) as [id Hdefinition].
  eapply clight_external_callstate_obeys_explicit_frame.
  - unfold TrueUnresolvedExternalFrames in Hframes.
    exact (Hframes id name signature argument_types result_type
      calling_convention Hdefinition).
  - exact Hstep.
Qed.

Corollary clight_external_callstate_frame_preserves_load :
  forall protected (ge : Clight.genv)
      external argument_types result_type calling_convention
      arguments continuation before trace result after chunk block offset value,
    ExternalCallFrame protected external ->
    Clight.step2 ge
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before)
      trace (Returnstate result continuation after) ->
    (forall byte_offset,
      offset <= byte_offset < offset + size_chunk chunk ->
      protected block byte_offset) ->
    Mem.load chunk before block offset = Some value ->
    Mem.load chunk after block offset = Some value.
Proof.
  intros protected ge external argument_types result_type calling_convention
    arguments continuation before trace result after chunk block offset value
    Hframe Hstep Hprotected Hload.
  eapply Mem.load_unchanged_on; eauto.
  eapply clight_external_callstate_obeys_explicit_frame; eauto.
Qed.

(** CompCert proves only this generic read-only implication for arbitrary
    external semantics.  It does not yield [ExternalCallFrame] for writable
    Mario/object/controller cells. *)
Theorem clight_external_callstate_generic_readonly_guarantee :
  forall (ge : Clight.genv)
      external argument_types result_type calling_convention arguments
      continuation before trace result after block offset length bytes,
    Clight.step2 ge
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before)
      trace (Returnstate result continuation after) ->
    Mem.valid_block before block ->
    Mem.loadbytes after block offset length = Some bytes ->
    (forall byte_offset,
      offset <= byte_offset < offset + length ->
      ~ Mem.perm before block byte_offset Max Writable) ->
    Mem.loadbytes before block offset length = Some bytes.
Proof.
  intros ge external argument_types result_type calling_convention arguments
    continuation before trace result after block offset length bytes Hstep
    Hvalid Hload Hreadonly.
  destruct (clight_external_callstate_step_inv ge external argument_types
              result_type calling_convention arguments continuation before
              trace _ Hstep) as [actual_result [actual_after [Heq Hcall]]].
  inversion Heq; subst.
  eapply external_call_readonly; eauto.
Qed.

(** * Identity simulation for an exact official-link result *)

Theorem clight_semantics2_identity_forward_simulation :
  forall program,
    Smallstep.forward_simulation
      (Clight.semantics2 program) (Clight.semantics2 program).
Proof.
  intros program.
  eapply Smallstep.forward_simulation_step with
    (match_states := fun left right => left = right).
  - intros id. reflexivity.
  - intros state Hinitial. exists state. split; auto.
  - intros left right result Heq Hfinal. now subst right.
  - intros left trace left' Hstep right Heq.
    subst right. exists left'. auto.
Qed.

Theorem exact_official_link_result_has_identity_semantics :
  forall units target linked,
    link_list units = Some target ->
    link_list units = Some linked ->
    Smallstep.forward_simulation
      (Clight.semantics2 linked) (Clight.semantics2 target).
Proof.
  intros units target linked Htarget Hlinked.
  rewrite Htarget in Hlinked.
  inversion Hlinked; subst linked.
  apply clight_semantics2_identity_forward_simulation.
Qed.

(** The remaining source-to-cleaned connection is intentionally a standard
    semantic simulation, not a hand-written result-shaped predicate. *)
Definition OriginalToCleanedClightSimulation
    (original cleaned : Clight.program) : Prop :=
  Smallstep.forward_simulation
    (Clight.semantics2 original) (Clight.semantics2 cleaned).
