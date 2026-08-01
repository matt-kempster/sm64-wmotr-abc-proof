From Coq Require Import List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Errors Globalenvs Linking Maps.
From LessThanOneAPress.Proofs Require Import LinkedClightPrograms.

Import ListNotations.

(** This file constructs a deliberately *normalized semantic slice*.  It is
    not the result of [Linking.link], and no theorem below gives it C
    separate-compilation semantics.  The construction is nevertheless an
    actual [Clight.program]: it keeps one declaration for each global atom,
    using the deterministic precedence rule documented below. *)

Fixpoint nlist_to_list {A : Type} (units : nlist A) : list A :=
  match units with
  | nbase unit => [unit]
  | ncons unit rest => unit :: nlist_to_list rest
  end.

Definition unit_global_definitions (units : nlist Clight.program) :=
  concat (map (@prog_defs Clight.function) (nlist_to_list units)).

Definition unit_public_idents (units : nlist Clight.program) :=
  concat (map (@prog_public Clight.function) (nlist_to_list units)).

Definition unit_composite_definitions (units : nlist Clight.program) :=
  concat (map (@Ctypes.prog_types Clight.function) (nlist_to_list units)).

Definition singleton_init_space (init : list init_data) : bool :=
  match init with
  | [Init_space _] => true
  | _ => false
  end.

(** Larger strengths win.  [Internal] beats [External]; an initialized
    non-tentative variable beats an [Init_space]-only tentative definition,
    which in turn beats an empty extern declaration.  Function/variable atom
    clashes are also resolved deterministically, although checked theorems
    below establish that none occurs in the selected inputs. *)
Definition global_definition_strength
    (definition : globdef Clight.fundef type) : nat :=
  match definition with
  | Gfun (Internal _) => 4
  | Gvar variable =>
      match gvar_init variable with
      | [] => 1
      | _ => if singleton_init_space (gvar_init variable) then 2 else 3
      end
  | Gfun (External _ _ _ _) => 0
  end.

Definition preserve_definition_verbatim
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (Internal _) => true
  | Gvar variable =>
      match gvar_init variable with
      | [] => false
      | _ => negb (singleton_init_space (gvar_init variable))
      end
  | _ => false
  end.

Fixpoint lookup_global_definition
    (id : ident) (definitions : list (ident * globdef Clight.fundef type))
    : option (globdef Clight.fundef type) :=
  match definitions with
  | [] => None
  | (candidate_id, candidate) :: rest =>
      if peq id candidate_id then Some candidate
      else lookup_global_definition id rest
  end.

Fixpoint replace_global_definition
    (id : ident) (replacement : globdef Clight.fundef type)
    (definitions : list (ident * globdef Clight.fundef type)) :=
  match definitions with
  | [] => []
  | (candidate_id, candidate) :: rest =>
      if peq id candidate_id
      then (candidate_id, replacement) :: rest
      else (candidate_id, candidate) ::
           replace_global_definition id replacement rest
  end.

Definition insert_preferred_global_definition
    (definitions : list (ident * globdef Clight.fundef type))
    (entry : ident * globdef Clight.fundef type) :=
  let '(id, candidate) := entry in
  match lookup_global_definition id definitions with
  | None => definitions ++ [entry]
  | Some incumbent =>
      if Nat.ltb (global_definition_strength incumbent)
                   (global_definition_strength candidate)
      then replace_global_definition id candidate definitions
      else definitions
  end.

Definition normalize_global_definitions_list
    (definitions : list (ident * globdef Clight.fundef type)) :=
  fold_left insert_preferred_global_definition definitions [].

Lemma replace_global_definition_incl :
  forall id replacement definitions universe,
    incl definitions universe ->
    In (id, replacement) universe ->
    incl (replace_global_definition id replacement definitions) universe.
Proof.
  intros id replacement definitions.
  induction definitions as [| [candidate_id candidate] rest IH];
    intros universe Hincl Hreplacement entry Hentry; cbn in *.
  - contradiction.
  - destruct (peq id candidate_id) as [Heq | Hneq].
    + subst candidate_id. cbn in Hentry. destruct Hentry as [<- | Hentry].
      * exact Hreplacement.
      * apply Hincl. now right.
    + cbn in Hentry. destruct Hentry as [<- | Hentry].
      * apply Hincl. now left.
      * eapply IH; try exact Hentry; try exact Hreplacement.
        intros source Hsource. apply Hincl. now right.
Qed.

Lemma insert_preferred_global_definition_incl :
  forall definitions entry universe,
    incl definitions universe ->
    In entry universe ->
    incl (insert_preferred_global_definition definitions entry) universe.
Proof.
  intros definitions [id candidate] universe Hincl Hentry.
  unfold insert_preferred_global_definition.
  destruct (lookup_global_definition id definitions) as [incumbent |].
  - destruct (Nat.ltb (global_definition_strength incumbent)
                     (global_definition_strength candidate)).
    + now apply replace_global_definition_incl.
    + exact Hincl.
  - intros selected Hselected. apply in_app_or in Hselected.
    destruct Hselected as [Hselected | [Hselected | []]].
    + now apply Hincl.
    + now subst selected.
Qed.

Lemma fold_normalized_definitions_incl :
  forall remaining accumulator universe,
    incl accumulator universe ->
    incl remaining universe ->
    incl (fold_left insert_preferred_global_definition
                    remaining accumulator) universe.
Proof.
  induction remaining as [| entry rest IH]; intros accumulator universe Hacc Hrest.
  - exact Hacc.
  - cbn. apply IH.
    + apply insert_preferred_global_definition_incl.
      * exact Hacc.
      * apply Hrest. now left.
    + intros candidate Hcandidate. apply Hrest. now right.
Qed.

Theorem normalized_definitions_are_source_entries :
  forall source,
    incl (normalize_global_definitions_list source) source.
Proof.
  intros source. apply fold_normalized_definitions_incl.
  - intros entry Hentry. contradiction.
  - apply incl_refl.
Qed.

(** The executable construction uses CompCert's positive-key trie instead of
    the specification list fold above.  This avoids quadratic normalization
    over the repeated declarations in 38 generated translation units. *)
Definition global_definition_map := PTree.t (globdef Clight.fundef type).

Definition insert_preferred_global_definition_map
    (definitions : global_definition_map)
    (entry : ident * globdef Clight.fundef type) : global_definition_map :=
  let '(id, candidate) := entry in
  match PTree.get id definitions with
  | None => PTree.set id candidate definitions
  | Some incumbent =>
      if Nat.ltb (global_definition_strength incumbent)
                   (global_definition_strength candidate)
      then PTree.set id candidate definitions
      else definitions
  end.

Definition normalize_global_definition_map
    (definitions : list (ident * globdef Clight.fundef type)) :=
  fold_left insert_preferred_global_definition_map definitions
    (PTree.empty _).

Definition normalize_global_definitions
    (definitions : list (ident * globdef Clight.fundef type)) :=
  PTree.elements (normalize_global_definition_map definitions).

(** [AST.link_prog] always emits the final definition map through
    [PTree.elements].  Keeping this canonical order is therefore necessary
    for a multi-translation-unit [link_list] result to be definitionally the
    normalized program; a source-order prefix cannot be the result of the
    official linker. *)

Definition map_values_have_source_provenance
    (definitions : global_definition_map)
    (source : list (ident * globdef Clight.fundef type)) : Prop :=
  forall id definition,
    PTree.get id definitions = Some definition ->
    In (id, definition) source.

Lemma insert_preferred_global_definition_map_provenance :
  forall definitions entry source,
    map_values_have_source_provenance definitions source ->
    In entry source ->
    map_values_have_source_provenance
      (insert_preferred_global_definition_map definitions entry) source.
Proof.
  intros definitions [id candidate] source Hprovenance Hentry.
  unfold insert_preferred_global_definition_map.
  destruct (PTree.get id definitions) as [incumbent |].
  - destruct (Nat.ltb (global_definition_strength incumbent)
                     (global_definition_strength candidate)) eqn:Hstrong.
    + intros query definition Hget.
      destruct (peq query id) as [Heq | Hneq].
      * subst query. rewrite PTree.gss in Hget. inversion Hget; subst.
        exact Hentry.
      * rewrite PTree.gso in Hget by exact Hneq.
        now eapply Hprovenance.
    + exact Hprovenance.
  - intros query definition Hget.
    destruct (peq query id) as [Heq | Hneq].
    + subst query. rewrite PTree.gss in Hget. inversion Hget; subst.
      exact Hentry.
    + rewrite PTree.gso in Hget by exact Hneq.
      now eapply Hprovenance.
Qed.

Lemma fold_global_definition_map_provenance :
  forall remaining definitions source,
    map_values_have_source_provenance definitions source ->
    incl remaining source ->
    map_values_have_source_provenance
      (fold_left insert_preferred_global_definition_map
        remaining definitions) source.
Proof.
  induction remaining as [| entry rest IH]; intros definitions source Hdefs Hrest.
  - exact Hdefs.
  - cbn. apply IH.
    + apply insert_preferred_global_definition_map_provenance.
      * exact Hdefs.
      * apply Hrest. now left.
    + intros candidate Hcandidate. apply Hrest. now right.
Qed.

Theorem normalized_definition_map_has_source_provenance :
  forall source,
    map_values_have_source_provenance
      (normalize_global_definition_map source) source.
Proof.
  intros source. apply fold_global_definition_map_provenance.
  - intros id definition Hget. rewrite PTree.gempty in Hget. discriminate.
  - apply incl_refl.
Qed.

Theorem normalized_definitions_have_source_provenance :
  forall source,
    incl (normalize_global_definitions source) source.
Proof.
  intros source [id definition] Hin.
  apply PTree.elements_complete in Hin.
  now eapply normalized_definition_map_has_source_provenance.
Qed.

Theorem every_selected_internal_body_is_preserved_verbatim :
  forall source id body,
    PTree.get id (normalize_global_definition_map source) =
      Some (Gfun (Internal body)) ->
    In (id, Gfun (Internal body)) (normalize_global_definitions source).
Proof.
  intros source id body Hget.
  apply PTree.elements_correct.
  exact Hget.
Qed.

Theorem every_selected_definitive_initializer_is_preserved_verbatim :
  forall source id variable,
    PTree.get id (normalize_global_definition_map source) =
      Some (Gvar variable) ->
    In (id, Gvar variable) (normalize_global_definitions source).
Proof.
  intros source id variable Hget.
  apply PTree.elements_correct.
  exact Hget.
Qed.

Definition composite_ident (definition : composite_definition) : ident :=
  match definition with
  | Composite id _ _ _ => id
  end.

Fixpoint composite_ident_occurs
    (id : ident) (definitions : list composite_definition) : bool :=
  match definitions with
  | [] => false
  | definition :: rest =>
      if peq id (composite_ident definition) then true
      else composite_ident_occurs id rest
  end.

Definition insert_first_composite
    (definitions : list composite_definition)
    (candidate : composite_definition) :=
  if composite_ident_occurs (composite_ident candidate) definitions
  then definitions
  else definitions ++ [candidate].

(** Composite identifiers are retained at their first occurrence.  This
    makes [build_composite_env] executable, but it is not a claim that a
    translation-unit-local anonymous tag has source-level linkage.  That
    precise mismatch remains outside the structural
    [NormalizedCleanedUnitsOfficialLinkStructuralObligation] below. *)
Definition normalize_composite_definitions
    (definitions : list composite_definition) :=
  fold_left insert_first_composite definitions [].

Lemma insert_first_composite_incl :
  forall definitions candidate universe,
    incl definitions universe ->
    In candidate universe ->
    incl (insert_first_composite definitions candidate) universe.
Proof.
  intros definitions candidate universe Hdefinitions Hcandidate.
  unfold insert_first_composite.
  destruct (composite_ident_occurs (composite_ident candidate) definitions).
  - exact Hdefinitions.
  - intros definition Hin. apply in_app_or in Hin.
    destruct Hin as [Hin | [<- | []]]; auto.
Qed.

Lemma fold_first_composites_incl :
  forall remaining accumulator universe,
    incl accumulator universe ->
    incl remaining universe ->
    incl (fold_left insert_first_composite remaining accumulator) universe.
Proof.
  induction remaining as [| candidate rest IH];
    intros accumulator universe Haccumulator Hremaining.
  - exact Haccumulator.
  - cbn. apply IH.
    + apply insert_first_composite_incl; auto.
      apply Hremaining. now left.
    + intros definition Hin. apply Hremaining. now right.
Qed.

Theorem normalized_composites_have_source_provenance :
  forall source,
    incl (normalize_composite_definitions source) source.
Proof.
  intros source. apply fold_first_composites_incl.
  - intros definition Hin. contradiction.
  - apply incl_refl.
Qed.

Fixpoint lookup_composite_definition
    (id : ident) (definitions : list composite_definition)
    : option composite_definition :=
  match definitions with
  | [] => None
  | definition :: rest =>
      if peq id (composite_ident definition) then Some definition
      else lookup_composite_definition id rest
  end.

Definition composite_definition_compatible
    (declaration selected : composite_definition) : bool :=
  match link [declaration] [selected] with
  | Some _ => true
  | None => false
  end.

Definition residual_composite_mismatch
    (selected : list composite_definition)
    (declaration : composite_definition) : option ident :=
  let id := composite_ident declaration in
  match lookup_composite_definition id selected with
  | Some definition =>
      if composite_definition_compatible declaration definition
      then None else Some id
  | None => Some id
  end.

Definition residual_composite_mismatches
    (source selected : list composite_definition) : list ident :=
  nodup peq (fold_right
    (fun declaration residuals =>
       match residual_composite_mismatch selected declaration with
       | Some id => id :: residuals
       | None => residuals
       end) [] source).

Fixpoint identifier_set (ids : list ident) : PTree.t unit :=
  match ids with
  | [] => PTree.empty _
  | id :: rest => PTree.set id tt (identifier_set rest)
  end.

Definition identifier_in_set (ids : PTree.t unit) (id : ident) : bool :=
  match PTree.get id ids with Some _ => true | None => false end.

Lemma identifier_in_set_sound :
  forall ids id,
    identifier_in_set (identifier_set ids) id = true -> In id ids.
Proof.
  induction ids as [| candidate rest IH]; intros id Hin;
    unfold identifier_in_set in Hin; cbn [identifier_set] in Hin.
  - rewrite PTree.gempty in Hin. discriminate.
  - rewrite PTree.gsspec in Hin.
    destruct (peq id candidate) as [<- | Hneq].
    + now left.
    + right. now apply IH.
Qed.

(** Preserve every source Internal and definitive initializer verbatim.  For
    weaker declarations, select the first source occurrence having the
    strength of the map-selected declaration.  The generated US/JP inputs
    separately certify that preserved identifiers are unique, so unconditional
    preservation does not introduce a duplicate global there.  Carrying
    [seen] makes weak selection compositional across unit boundaries. *)
Fixpoint select_source_owned_definitions_from
    (selected : global_definition_map) (seen : PTree.t unit)
    (source : list (ident * globdef Clight.fundef type))
    : list (ident * globdef Clight.fundef type) * PTree.t unit :=
  match source with
  | [] => ([], seen)
  | ((id, candidate) as entry) :: rest =>
      if preserve_definition_verbatim entry then
        let '(selected_rest, final_seen) :=
          select_source_owned_definitions_from selected
            (PTree.set id tt seen) rest in
        (entry :: selected_rest, final_seen)
      else
        match PTree.get id seen, PTree.get id selected with
        | None, Some chosen =>
            if Nat.eqb (global_definition_strength candidate)
                       (global_definition_strength chosen)
            then
              let '(selected_rest, final_seen) :=
                select_source_owned_definitions_from selected
                  (PTree.set id tt seen) rest in
              (entry :: selected_rest, final_seen)
            else select_source_owned_definitions_from selected seen rest
        | _, _ => select_source_owned_definitions_from selected seen rest
        end
  end.

Definition select_source_owned_definitions
    (source : list (ident * globdef Clight.fundef type)) :=
  fst (select_source_owned_definitions_from
    (normalize_global_definition_map source) (PTree.empty _) source).

Definition public_definitions_in_source_order
    (source_definitions : list (ident * globdef Clight.fundef type))
    (source_public : list ident) : list ident :=
  let public := identifier_set source_public in
  map fst (filter
    (fun entry => identifier_in_set public (fst entry))
    (select_source_owned_definitions source_definitions)).

Definition us_normalized_global_definitions :=
  normalize_global_definitions (unit_global_definitions us_units).

Definition jp_normalized_global_definitions :=
  normalize_global_definitions (unit_global_definitions jp_units).

Definition us_normalized_global_definition_map :=
  normalize_global_definition_map (unit_global_definitions us_units).

Definition jp_normalized_global_definition_map :=
  normalize_global_definition_map (unit_global_definitions jp_units).

Definition us_normalized_composites :=
  normalize_composite_definitions (unit_composite_definitions us_units).

Definition jp_normalized_composites :=
  normalize_composite_definitions (unit_composite_definitions jp_units).

Definition us_normalized_public_idents :=
  public_definitions_in_source_order
    (unit_global_definitions us_units) (unit_public_idents us_units).

Definition jp_normalized_public_idents :=
  public_definitions_in_source_order
    (unit_global_definitions jp_units) (unit_public_idents jp_units).

Definition us_normalized_make_program :=
  Ctypes.make_program us_normalized_composites
    us_normalized_global_definitions us_normalized_public_idents
    us_game_init._main.

Definition jp_normalized_make_program :=
  Ctypes.make_program jp_normalized_composites
    jp_normalized_global_definitions jp_normalized_public_idents
    jp_game_init._main.

(** The fallback branches make these total Coq definitions.  The checked
    success theorems below establish that neither branch is selected.  Unlike
    a bare proof placeholder, [make_program] actually runs
    [build_composite_env] and packages its equality certificate. *)
Definition us_normalized_semantic_slice : Clight.program :=
  match us_normalized_make_program with
  | OK program => program
  | Error _ => us_game_init.prog
  end.

Definition jp_normalized_semantic_slice : Clight.program :=
  match jp_normalized_make_program with
  | OK program => program
  | Error _ => jp_game_init.prog
  end.

Definition us_normalized_globalenv : Genv.t Clight.fundef type :=
  Clight.globalenv us_normalized_semantic_slice.

Definition jp_normalized_globalenv : Genv.t Clight.fundef type :=
  Clight.globalenv jp_normalized_semantic_slice.

Definition make_program_succeeds (result : res Clight.program) : bool :=
  match result with OK _ => true | Error _ => false end.

Theorem us_normalized_make_program_success_flag_checked :
  make_program_succeeds us_normalized_make_program = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_make_program_success_flag_checked :
  make_program_succeeds jp_normalized_make_program = true.
Proof. vm_compute. reflexivity. Qed.

Lemma make_program_success_result :
  forall (result : res Clight.program) fallback,
    make_program_succeeds result = true ->
    result = OK
      (match result with OK program => program | Error _ => fallback end).
Proof.
  intros result fallback Hsuccess. destruct result; cbn in Hsuccess.
  - reflexivity.
  - discriminate.
Qed.

Theorem us_normalized_make_program_success_checked :
  us_normalized_make_program = OK us_normalized_semantic_slice.
Proof.
  unfold us_normalized_semantic_slice.
  apply make_program_success_result.
  exact us_normalized_make_program_success_flag_checked.
Qed.

Theorem jp_normalized_make_program_success_checked :
  jp_normalized_make_program = OK jp_normalized_semantic_slice.
Proof.
  unfold jp_normalized_semantic_slice.
  apply make_program_success_result.
  exact jp_normalized_make_program_success_flag_checked.
Qed.

(** Executable coverage audits.  Exact body/initializer preservation follows
    from [normalized_definitions_are_source_entries] below: the normalization
    never constructs or edits a definition. *)
Definition internal_identifier_selected
    (selected : global_definition_map)
    (entry : ident * globdef Clight.fundef type) : bool :=
  match entry with
  | (id, Gfun (Internal _)) =>
      match PTree.get id selected with
      | Some (Gfun (Internal _)) => true
      | _ => false
      end
  | _ => true
  end.

Definition definitive_variable (variable : globvar type) : bool :=
  match gvar_init variable with
  | [] => false
  | _ => negb (singleton_init_space (gvar_init variable))
  end.

Definition definitive_identifier_selected
    (selected : global_definition_map)
    (entry : ident * globdef Clight.fundef type) : bool :=
  match entry with
  | (id, Gvar variable) =>
      if definitive_variable variable then
        match PTree.get id selected with
        | Some (Gvar selected_variable) => definitive_variable selected_variable
        | _ => false
        end
      else true
  | _ => true
  end.

Definition all_internal_identifiers_selected
    (source : list (ident * globdef Clight.fundef type))
    (selected : global_definition_map) : bool :=
  forallb (internal_identifier_selected selected) source.

Definition all_definitive_identifiers_selected
    (source : list (ident * globdef Clight.fundef type))
    (selected : global_definition_map) : bool :=
  forallb (definitive_identifier_selected selected) source.

Definition is_internal (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with Gfun (Internal _) => true | _ => false end.

Definition is_external_function
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with Gfun (External _ _ _ _) => true | _ => false end.

Definition is_definitive_variable
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable => definitive_variable variable
  | _ => false
  end.

Definition is_tentative_variable
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable => singleton_init_space (gvar_init variable)
  | _ => false
  end.

Definition is_extern_variable
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable =>
      match gvar_init variable with [] => true | _ => false end
  | _ => false
  end.

Definition selected_class_counts
    (definitions : list (ident * globdef Clight.fundef type)) :=
  (length (filter is_internal definitions),
   length (filter is_external_function definitions),
   length (filter is_definitive_variable definitions),
   length (filter is_tentative_variable definitions),
   length (filter is_extern_variable definitions)).

(** Declaration compatibility used only for the duplicate-[Gvar] audit.
    Literal equality is accepted.  Otherwise the sole normalization allowed
    here is an incomplete array bound [0] refined by a complete array bound,
    with exactly equal element type and attributes. *)
Definition incomplete_array_declaration_compatible
    (declaration selected : type) : bool :=
  match declaration, selected with
  | Tarray declaration_element declaration_count declaration_attr,
    Tarray selected_element selected_count selected_attr =>
      if type_eq declaration_element selected_element then
        if attr_eq declaration_attr selected_attr then
          andb (Z.eqb declaration_count 0) (negb (Z.eqb selected_count 0))
        else false
      else false
  | _, _ => false
  end.

Definition declaration_type_compatible
    (declaration selected : type) : bool :=
  if type_eq declaration selected then true
  else incomplete_array_declaration_compatible declaration selected.

Definition clight_fundef_type (definition : Clight.fundef) : type :=
  match definition with
  | Internal function =>
      Tfunction (map snd (fn_params function))
        (fn_return function) (fn_callconv function)
  | External _ arguments result calling_convention =>
      Tfunction arguments result calling_convention
  end.

Definition residual_function_signature_mismatch
    (selected : global_definition_map)
    (entry : ident * globdef Clight.fundef type) : option ident :=
  match entry with
  | (id, Gfun declaration) =>
      match PTree.get id selected with
      | Some (Gfun definition) =>
          if type_eq (clight_fundef_type declaration)
                     (clight_fundef_type definition)
          then None else Some id
      | _ => Some id
      end
  | _ => None
  end.

Definition residual_function_signature_mismatches
    (source : list (ident * globdef Clight.fundef type))
    (selected : global_definition_map) : list ident :=
  nodup peq (fold_right
    (fun entry residuals =>
       match residual_function_signature_mismatch selected entry with
       | Some id => id :: residuals
       | None => residuals
       end) [] source).

Definition residual_gvar_type_mismatch
    (selected : global_definition_map)
    (entry : ident * globdef Clight.fundef type) : option ident :=
  match entry with
  | (id, Gvar declaration) =>
      match PTree.get id selected with
      | Some (Gvar definition) =>
          if declaration_type_compatible
               (gvar_info declaration) (gvar_info definition)
          then None else Some id
      | _ => Some id
      end
  | _ => None
  end.

Definition residual_gvar_type_mismatches
    (source : list (ident * globdef Clight.fundef type))
    (selected : global_definition_map) : list ident :=
  nodup peq (fold_right
    (fun entry residuals =>
       match residual_gvar_type_mismatch selected entry with
       | Some id => id :: residuals
       | None => residuals
       end) [] source).

(** A non-vacuous *structural* boundary for an official cleaned link.  A
    witness must provide a same-sized list of cleaned translation units whose
    actual CompCert [link_list] result is exactly [normalized].  The pointwise
    relation below prevents a degenerate witness that puts all bodies in one
    padded unit: every cleaned global must occur verbatim in the corresponding
    source translation unit.  Each unit uses the canonical normalized
    composite list as a cleaned shared-header environment.  Every emitted
    definition/composite must still come from the selected source units; every
    source Internal or definitive [Gvar] must remain verbatim; and every
    source symbol/composite tag must still be represented.  This deliberately
    says nothing about expression typing, composite-member layouts, global
    block injections, or execution simulation.  Those semantic refinement
    obligations remain open and this exploratory slice is not used as linked
    retail semantics. *)
Definition global_identifiers
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst definitions.

Definition composite_identifiers
    (definitions : list composite_definition) : list ident :=
  map composite_ident definitions.

Definition CleanedUnitOwnsGlobalsAndUsesNormalizedHeader
    (normalized source cleaned : Clight.program) : Prop :=
  incl cleaned.(prog_defs) source.(prog_defs) /\
  incl cleaned.(prog_public) source.(prog_public) /\
  incl cleaned.(prog_public) (global_identifiers cleaned.(prog_defs)) /\
  cleaned.(prog_main) = source.(prog_main) /\
  cleaned.(prog_types) = normalized.(prog_types).

Definition NormalizedCleanedUnitsOfficialLinkStructuralObligation
    (source_units : nlist Clight.program)
    (normalized : Clight.program) : Prop :=
  exists cleaned_units : nlist Clight.program,
    nlist_length cleaned_units = nlist_length source_units /\
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source_units cleaned_units /\
    link_list cleaned_units = Some normalized /\
    incl (unit_global_definitions cleaned_units)
         (unit_global_definitions source_units) /\
    incl (filter preserve_definition_verbatim
            (unit_global_definitions source_units))
         (unit_global_definitions cleaned_units) /\
    incl (global_identifiers (unit_global_definitions source_units))
         (global_identifiers (unit_global_definitions cleaned_units)) /\
    incl (unit_public_idents source_units)
         (unit_public_idents cleaned_units) /\
    incl (unit_composite_definitions cleaned_units)
         (unit_composite_definitions source_units) /\
    incl (composite_identifiers (unit_composite_definitions source_units))
         (composite_identifiers (unit_composite_definitions cleaned_units)).

(** No proof of [NormalizedCleanedUnitsOfficialLinkStructuralObligation] is
    postulated here.  [CleanedClightPrograms] constructs US and JP inhabitants,
    but they establish only a syntactic official-link bridge;
    separate-compilation semantics still requires CompCert-compatible
    declaration, composite, memory, and execution refinement theorems. *)

Definition internal_identifiers
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst (filter is_internal definitions).

Definition definitive_variable_identifiers
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst (filter is_definitive_variable definitions).

Fixpoint identifiers_unique_from
    (seen : PTree.t unit) (ids : list ident) : bool :=
  match ids with
  | [] => true
  | id :: rest =>
      match PTree.get id seen with
      | Some _ => false
      | None => identifiers_unique_from (PTree.set id tt seen) rest
      end
  end.

Definition identifiers_unique (ids : list ident) : bool :=
  identifiers_unique_from (PTree.empty _) ids.

Theorem us_normalized_definition_count_checked :
  length us_normalized_global_definitions = 4334%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_definition_count_checked :
  length jp_normalized_global_definitions = 4317%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_normalized_definition_classes_checked :
  selected_class_counts us_normalized_global_definitions =
    (2567%nat, 227%nat, 1069%nat, 157%nat, 314%nat).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_definition_classes_checked :
  selected_class_counts jp_normalized_global_definitions =
    (2561%nat, 226%nat, 1060%nat, 156%nat, 314%nat).
Proof. vm_compute. reflexivity. Qed.

Theorem us_internal_identifiers_are_unique_checked :
  identifiers_unique
    (internal_identifiers (unit_global_definitions us_units)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_internal_identifiers_are_unique_checked :
  identifiers_unique
    (internal_identifiers (unit_global_definitions jp_units)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem us_definitive_identifiers_are_unique_checked :
  identifiers_unique
    (definitive_variable_identifiers (unit_global_definitions us_units)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_definitive_identifiers_are_unique_checked :
  identifiers_unique
    (definitive_variable_identifiers (unit_global_definitions jp_units)) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem us_all_internal_identifiers_selected_checked :
  all_internal_identifiers_selected
    (unit_global_definitions us_units)
    us_normalized_global_definition_map = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_all_internal_identifiers_selected_checked :
  all_internal_identifiers_selected
    (unit_global_definitions jp_units)
    jp_normalized_global_definition_map = true.
Proof. vm_compute. reflexivity. Qed.

Theorem us_all_definitive_identifiers_selected_checked :
  all_definitive_identifiers_selected
    (unit_global_definitions us_units)
    us_normalized_global_definition_map = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_all_definitive_identifiers_selected_checked :
  all_definitive_identifiers_selected
    (unit_global_definitions jp_units)
    jp_normalized_global_definition_map = true.
Proof. vm_compute. reflexivity. Qed.

Theorem us_selected_definitions_have_source_provenance :
  incl us_normalized_global_definitions
       (unit_global_definitions us_units).
Proof. apply normalized_definitions_have_source_provenance. Qed.

Theorem jp_selected_definitions_have_source_provenance :
  incl jp_normalized_global_definitions
       (unit_global_definitions jp_units).
Proof. apply normalized_definitions_have_source_provenance. Qed.

Theorem us_normalized_composite_count_checked :
  length us_normalized_composites = 174%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_composite_count_checked :
  length jp_normalized_composites = 140%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_gdisplaylisthead_selected_definition_checked :
  PTree.get us_game_init._gDisplayListHead
    us_normalized_global_definition_map =
  Some (Gvar us_game_init.v_gDisplayListHead).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_gdisplaylisthead_selected_definition_checked :
  PTree.get jp_game_init._gDisplayListHead
    jp_normalized_global_definition_map =
  Some (Gvar jp_game_init.v_gDisplayListHead).
Proof. vm_compute. reflexivity. Qed.

Theorem us_gdisplaylisthead_exact_type_expressions :
  gvar_info us_game_init.v_gDisplayListHead =
    Tpointer (Tunion us_game_init.__549 noattr) noattr /\
  gvar_info us_area.v_gDisplayListHead =
    Tpointer (Tunion us_area.__613 noattr) noattr /\
  declaration_type_compatible
    (gvar_info us_area.v_gDisplayListHead)
    (gvar_info us_game_init.v_gDisplayListHead) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_gdisplaylisthead_exact_type_expressions :
  gvar_info jp_game_init.v_gDisplayListHead =
    Tpointer (Tunion jp_game_init.__512 noattr) noattr /\
  gvar_info jp_area.v_gDisplayListHead =
    Tpointer (Tunion jp_area.__576 noattr) noattr /\
  declaration_type_compatible
    (gvar_info jp_area.v_gDisplayListHead)
    (gvar_info jp_game_init.v_gDisplayListHead) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition us_residual_function_signature_mismatches :=
  residual_function_signature_mismatches
    (unit_global_definitions us_units) us_normalized_global_definition_map.

Definition jp_residual_function_signature_mismatches :=
  residual_function_signature_mismatches
    (unit_global_definitions jp_units) jp_normalized_global_definition_map.

Theorem us_residual_function_signature_mismatch_count_checked :
  length us_residual_function_signature_mismatches = 3%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_residual_function_signature_mismatch_count_checked :
  length jp_residual_function_signature_mismatches = 3%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_exact_residual_gvar_type_mismatch_checked :
  residual_gvar_type_mismatches
    (unit_global_definitions us_units) us_normalized_global_definition_map =
  [us_game_init._gDisplayListHead].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_exact_residual_gvar_type_mismatch_checked :
  residual_gvar_type_mismatches
    (unit_global_definitions jp_units) jp_normalized_global_definition_map =
  [jp_game_init._gDisplayListHead].
Proof. vm_compute. reflexivity. Qed.

Definition us_residual_composite_mismatches :=
  residual_composite_mismatches
    (unit_composite_definitions us_units) us_normalized_composites.

Definition jp_residual_composite_mismatches :=
  residual_composite_mismatches
    (unit_composite_definitions jp_units) jp_normalized_composites.

Theorem us_residual_composite_mismatch_count_checked :
  length us_residual_composite_mismatches = 6%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_residual_composite_mismatch_count_checked :
  length jp_residual_composite_mismatches = 5%nat.
Proof. vm_compute. reflexivity. Qed.

Theorem us_residual_composite_mismatch_members_checked :
  In us_game_init.__538 us_residual_composite_mismatches /\
  In us_game_init._Controller us_residual_composite_mismatches /\
  In us_behavior_actions._FnGraphNode us_residual_composite_mismatches /\
  In us_behavior_actions._GraphNodeCamera us_residual_composite_mismatches /\
  In us_behavior_actions._Object us_residual_composite_mismatches /\
  In us_behavior_actions._Surface us_residual_composite_mismatches.
Proof. vm_compute. repeat split; tauto. Qed.

Theorem jp_residual_composite_mismatch_members_checked :
  In jp_behavior_actions._Controller jp_residual_composite_mismatches /\
  In jp_behavior_actions._FnGraphNode jp_residual_composite_mismatches /\
  In jp_behavior_actions._GraphNodeCamera jp_residual_composite_mismatches /\
  In jp_level_update._Object jp_residual_composite_mismatches /\
  In jp_behavior_actions._Surface jp_residual_composite_mismatches.
Proof. vm_compute. repeat split; tauto. Qed.
