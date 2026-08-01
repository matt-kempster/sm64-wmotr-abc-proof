From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Errors Linking Maps.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms.

Import ListNotations.

(** This file constructs the cleaned translation units used by the official
    CompCert linker.  Global definitions are never moved: the streaming
    selector retains a chosen declaration in the same unit in which that
    declaration occurred.  All units receive the canonical composite list as
    an explicit cleaned-header environment.  That header normalization is a
    structural linking device, not yet a semantic refinement of anonymous C
    tags in the original separately generated units. *)

Definition public_idents_for_definitions
    (public : PTree.t unit)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst (filter
    (fun entry => identifier_in_set public (fst entry)) definitions).

Definition cleaned_translation_unit
    (normalized source : Clight.program)
    (definitions : list (ident * globdef Clight.fundef type))
    : Clight.program :=
  {| prog_defs := definitions;
     prog_public := public_idents_for_definitions
       (identifier_set source.(prog_public)) definitions;
     prog_main := source.(prog_main);
     prog_types := normalized.(prog_types);
     prog_comp_env := normalized.(prog_comp_env);
     prog_comp_env_eq := normalized.(prog_comp_env_eq) |}.

Fixpoint clean_translation_units_from
    (selected : global_definition_map)
    (normalized : Clight.program) (seen : PTree.t unit)
    (source : nlist Clight.program)
    : nlist Clight.program * PTree.t unit :=
  match source with
  | nbase unit =>
      let '(definitions, final_seen) :=
        select_source_owned_definitions_from selected seen unit.(prog_defs) in
      (nbase (cleaned_translation_unit normalized unit definitions),
       final_seen)
  | ncons unit rest =>
      let '(definitions, next_seen) :=
        select_source_owned_definitions_from selected seen unit.(prog_defs) in
      let '(cleaned_rest, final_seen) :=
        clean_translation_units_from selected normalized next_seen rest in
      (ncons (cleaned_translation_unit normalized unit definitions)
             cleaned_rest,
       final_seen)
  end.

Definition clean_translation_units
    (source : nlist Clight.program) (normalized : Clight.program)
    : nlist Clight.program :=
  fst (clean_translation_units_from
    (normalize_global_definition_map (unit_global_definitions source))
    normalized (PTree.empty _) source).

Definition us_cleaned_units : nlist Clight.program :=
  clean_translation_units us_units us_normalized_semantic_slice.

Definition jp_cleaned_units : nlist Clight.program :=
  clean_translation_units jp_units jp_normalized_semantic_slice.

(** Every selected definition is an exact member of its corresponding source
    unit.  This is the key anti-degeneracy property: no function body can be
    collected into an unrelated all-in-one unit. *)
Lemma select_source_owned_definitions_from_incl :
  forall selected seen source,
    incl (fst (select_source_owned_definitions_from selected seen source))
         source.
Proof.
  intros selected seen source. revert seen.
  induction source as [| [id candidate] rest IH]; intros seen; cbn.
  - apply incl_refl.
  - destruct (preserve_definition_verbatim (id, candidate)) eqn:Hpreserve.
    + destruct (select_source_owned_definitions_from selected
                  (PTree.set id tt seen) rest) as [definitions final_seen]
        eqn:Hrest; cbn.
      intros entry Hentry. destruct Hentry as [<- | Hentry].
      * now left.
      * right. specialize (IH (PTree.set id tt seen)).
        rewrite Hrest in IH. exact (IH _ Hentry).
    + destruct (PTree.get id seen) as [[] |] eqn:Hseen;
      [exact (incl_tl _ (IH seen)) |].
      destruct (PTree.get id selected) as [chosen |] eqn:Hchosen;
      [| exact (incl_tl _ (IH seen))].
      destruct (Nat.eqb (global_definition_strength candidate)
                        (global_definition_strength chosen)) eqn:Hstrength.
      * destruct (select_source_owned_definitions_from selected
                    (PTree.set id tt seen) rest) as [definitions final_seen]
          eqn:Hrest; cbn.
        intros entry Hentry. destruct Hentry as [<- | Hentry].
        -- now left.
        -- right. specialize (IH (PTree.set id tt seen)).
           rewrite Hrest in IH. exact (IH _ Hentry).
      * exact (incl_tl _ (IH seen)).
Qed.

Lemma select_source_owned_definitions_from_preserves_verbatim :
  forall selected seen source,
    incl (filter preserve_definition_verbatim source)
         (fst (select_source_owned_definitions_from selected seen source)).
Proof.
  intros selected seen source. revert seen.
  induction source as [| [id candidate] rest IH]; intros seen; cbn.
  - apply incl_refl.
  - destruct (preserve_definition_verbatim (id, candidate)) eqn:Hpreserve.
    + destruct (select_source_owned_definitions_from selected
                  (PTree.set id tt seen) rest) as [definitions final_seen]
        eqn:Hrest; cbn.
      intros entry [<- | Hentry].
      * now left.
      * right. specialize (IH (PTree.set id tt seen)).
        rewrite Hrest in IH. exact (IH _ Hentry).
    + destruct (PTree.get id seen) as [[] |] eqn:Hseen.
      * exact (IH seen).
      * destruct (PTree.get id selected) as [chosen |] eqn:Hchosen.
        -- destruct (Nat.eqb (global_definition_strength candidate)
                            (global_definition_strength chosen)) eqn:Hstrength.
           ++ destruct (select_source_owned_definitions_from selected
                         (PTree.set id tt seen) rest)
                as [definitions final_seen] eqn:Hrest; cbn.
              intros entry Hentry. right.
              specialize (IH (PTree.set id tt seen)).
              rewrite Hrest in IH. exact (IH _ Hentry).
           ++ exact (IH seen).
        -- exact (IH seen).
Qed.

Lemma clean_translation_units_from_pointwise_ownership :
  forall selected normalized seen source,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source
      (fst (clean_translation_units_from
        selected normalized seen source)).
Proof.
  intros selected normalized seen source. revert seen.
  induction source as [unit | unit rest IH]; intros seen; cbn.
  - destruct (select_source_owned_definitions_from
                selected seen (prog_defs unit)) as [definitions final_seen]
      eqn:Hselected; cbn.
    constructor. repeat split.
    + pose proof (select_source_owned_definitions_from_incl
        selected seen (prog_defs unit)) as Hincl.
      rewrite Hselected in Hincl. exact Hincl.
    + unfold public_idents_for_definitions.
      intros id Hid. apply in_map_iff in Hid.
      destruct Hid as ([entry_id entry_definition] & <- & Hin).
      apply filter_In in Hin. destruct Hin as [_ Hpublic].
      now apply identifier_in_set_sound in Hpublic.
    + unfold public_idents_for_definitions, global_identifiers.
      apply incl_map. intros entry Hentry.
      now apply filter_In in Hentry.
  - destruct (select_source_owned_definitions_from
                selected seen (prog_defs unit)) as [definitions next_seen]
      eqn:Hselected; cbn.
    destruct (clean_translation_units_from
                selected normalized next_seen rest)
      as [cleaned_rest final_seen] eqn:Hrest; cbn.
    constructor.
    + repeat split.
      * pose proof (select_source_owned_definitions_from_incl
          selected seen (prog_defs unit)) as Hincl.
        rewrite Hselected in Hincl. exact Hincl.
      * unfold public_idents_for_definitions.
        intros id Hid. apply in_map_iff in Hid.
        destruct Hid as ([entry_id entry_definition] & <- & Hin).
        apply filter_In in Hin. destruct Hin as [_ Hpublic].
        now apply identifier_in_set_sound in Hpublic.
      * unfold public_idents_for_definitions, global_identifiers.
        apply incl_map. intros entry Hentry.
        now apply filter_In in Hentry.
    + specialize (IH next_seen). rewrite Hrest in IH. exact IH.
Qed.

Lemma clean_translation_units_from_preserves_verbatim :
  forall selected normalized seen source,
    incl (filter preserve_definition_verbatim
            (unit_global_definitions source))
         (unit_global_definitions
            (fst (clean_translation_units_from
              selected normalized seen source))).
Proof.
  intros selected normalized seen source. revert seen.
  induction source as [unit | unit rest IH]; intros seen; cbn.
  - destruct (select_source_owned_definitions_from
                selected seen (prog_defs unit)) as [definitions final_seen]
      eqn:Hselected; cbn. rewrite ! app_nil_r.
    pose proof (select_source_owned_definitions_from_preserves_verbatim
      selected seen (prog_defs unit)) as Hpreserved.
    now rewrite Hselected in Hpreserved.
  - destruct (select_source_owned_definitions_from
                selected seen (prog_defs unit)) as [definitions next_seen]
      eqn:Hselected; cbn.
    destruct (clean_translation_units_from
                selected normalized next_seen rest)
      as [cleaned_rest final_seen] eqn:Hrest; cbn.
    rewrite filter_app. intros definition Hin. apply in_app_or in Hin.
    destruct Hin as [Hin | Hin].
    + apply in_or_app. left.
      pose proof (select_source_owned_definitions_from_preserves_verbatim
        selected seen (prog_defs unit)) as Hpreserved.
      rewrite Hselected in Hpreserved. exact (Hpreserved definition Hin).
    + apply in_or_app. right. specialize (IH next_seen).
      rewrite Hrest in IH. exact (IH definition Hin).
Qed.

Theorem us_cleaned_units_preserve_strong_definitions_verbatim :
  incl (filter preserve_definition_verbatim
          (unit_global_definitions us_units))
       (unit_global_definitions us_cleaned_units).
Proof. apply clean_translation_units_from_preserves_verbatim. Qed.

Theorem jp_cleaned_units_preserve_strong_definitions_verbatim :
  incl (filter preserve_definition_verbatim
          (unit_global_definitions jp_units))
       (unit_global_definitions jp_cleaned_units).
Proof. apply clean_translation_units_from_preserves_verbatim. Qed.

Theorem us_cleaned_units_pointwise_ownership :
  nlist_forall2
    (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader
      us_normalized_semantic_slice)
    us_units us_cleaned_units.
Proof.
  apply clean_translation_units_from_pointwise_ownership.
Qed.

Theorem jp_cleaned_units_pointwise_ownership :
  nlist_forall2
    (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader
      jp_normalized_semantic_slice)
    jp_units jp_cleaned_units.
Proof.
  apply clean_translation_units_from_pointwise_ownership.
Qed.

Lemma pointwise_global_ownership_implies_aggregate_provenance :
  forall normalized source cleaned,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source cleaned ->
    incl (unit_global_definitions cleaned)
         (unit_global_definitions source).
Proof.
  intros normalized source cleaned Hpointwise.
  induction Hpointwise; cbn.
  - rewrite ! app_nil_r. exact (proj1 H).
  - intros definition Hin. apply in_app_or in Hin.
    destruct Hin as [Hin | Hin].
    + apply in_or_app. left. exact (proj1 H definition Hin).
    + apply in_or_app. right. exact (IHHpointwise definition Hin).
Qed.

Theorem us_cleaned_global_definitions_have_pointwise_source_provenance :
  incl (unit_global_definitions us_cleaned_units)
       (unit_global_definitions us_units).
Proof.
  eapply pointwise_global_ownership_implies_aggregate_provenance.
  exact us_cleaned_units_pointwise_ownership.
Qed.

Theorem jp_cleaned_global_definitions_have_pointwise_source_provenance :
  incl (unit_global_definitions jp_cleaned_units)
       (unit_global_definitions jp_units).
Proof.
  eapply pointwise_global_ownership_implies_aggregate_provenance.
  exact jp_cleaned_units_pointwise_ownership.
Qed.

Theorem us_cleaned_unit_count_checked :
  nlist_length us_cleaned_units = nlist_length us_units.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_cleaned_unit_count_checked :
  nlist_length jp_cleaned_units = nlist_length jp_units.
Proof. vm_compute. reflexivity. Qed.

(** Identifier-only certificates used to prove AST-link success without
    normalizing a 4,000-definition linked AST. *)
Lemma identifiers_unique_from_seen_excludes :
  forall seen ids id,
    PTree.get id seen = Some tt ->
    identifiers_unique_from seen ids = true ->
    ~ In id ids.
Proof.
  intros seen ids. revert seen.
  induction ids as [| candidate rest IH]; intros seen id Hseen Hunique Hin.
  - contradiction.
  - cbn in Hunique. destruct (PTree.get candidate seen) as [[] |] eqn:Hcandidate;
      try discriminate.
    destruct Hin as [<- | Hin].
    + congruence.
    + eapply (IH (PTree.set candidate tt seen) id); eauto.
      rewrite PTree.gsspec. destruct (peq id candidate); [reflexivity | exact Hseen].
Qed.

Lemma identifiers_unique_from_nodup :
  forall seen ids,
    identifiers_unique_from seen ids = true -> NoDup ids.
Proof.
  intros seen ids. revert seen.
  induction ids as [| id rest IH]; intros seen Hunique.
  - constructor.
  - cbn in Hunique. destruct (PTree.get id seen) as [[] |] eqn:Hseen;
      try discriminate.
    constructor.
    + eapply identifiers_unique_from_seen_excludes.
      * apply PTree.gss.
      * exact Hunique.
    + now apply IH with (seen := PTree.set id tt seen).
Qed.

Lemma identifiers_unique_nodup :
  forall ids, identifiers_unique ids = true -> NoDup ids.
Proof.
  intros ids Hunique. now apply identifiers_unique_from_nodup in Hunique.
Qed.

Definition ast_global_names
    (program : AST.program Clight.fundef type) : list ident :=
  AST.prog_defs_names program.

Fixpoint cleaned_global_identifiers (units : nlist Clight.program) : list ident :=
  match units with
  | nbase unit => ast_global_names (program_components unit)
  | ncons unit rest =>
      ast_global_names (program_components unit) ++
      cleaned_global_identifiers rest
  end.

Theorem us_cleaned_global_identifiers_unique_checked :
  identifiers_unique (cleaned_global_identifiers us_cleaned_units) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_cleaned_global_identifiers_unique_checked :
  identifiers_unique (cleaned_global_identifiers jp_cleaned_units) = true.
Proof. vm_compute. reflexivity. Qed.

Definition identifiers_includedb
    (source selected : list ident) : bool :=
  let selected_set := identifier_set selected in
  forallb (identifier_in_set selected_set) source.

Lemma identifiers_includedb_sound :
  forall source selected,
    identifiers_includedb source selected = true -> incl source selected.
Proof.
  intros source selected Hchecked id Hin.
  unfold identifiers_includedb in Hchecked.
  rewrite forallb_forall in Hchecked.
  specialize (Hchecked id Hin).
  now apply identifier_in_set_sound in Hchecked.
Qed.

Record CleanedIdentifierCoverageAudit : Type := {
  audit_global_identifier_coverage : bool;
  audit_public_identifier_coverage : bool;
  audit_composite_identifier_coverage : bool
}.

Definition cleaned_identifier_coverage_audit
    (source cleaned : nlist Clight.program) : CleanedIdentifierCoverageAudit :=
  {| audit_global_identifier_coverage := identifiers_includedb
       (global_identifiers (unit_global_definitions source))
       (global_identifiers (unit_global_definitions cleaned));
     audit_public_identifier_coverage := identifiers_includedb
       (unit_public_idents source) (unit_public_idents cleaned);
     audit_composite_identifier_coverage := identifiers_includedb
       (composite_identifiers (unit_composite_definitions source))
       (composite_identifiers (unit_composite_definitions cleaned)) |}.

Definition all_identifier_coverage_checks_pass : CleanedIdentifierCoverageAudit :=
  {| audit_global_identifier_coverage := true;
     audit_public_identifier_coverage := true;
     audit_composite_identifier_coverage := true |}.

(** Project the consolidated certificate while [source] and [cleaned] remain
    variables.  Performing this record reduction after specializing to the
    several-thousand-definition concrete programs makes conversion traverse
    the complete generated terms and can overflow Rocq's stack. *)
Lemma cleaned_identifier_coverage_audit_global_checked :
  forall source cleaned,
    cleaned_identifier_coverage_audit source cleaned =
      all_identifier_coverage_checks_pass ->
    identifiers_includedb
      (global_identifiers (unit_global_definitions source))
      (global_identifiers (unit_global_definitions cleaned)) = true.
Proof.
  intros source cleaned Haudit.
  pose proof (f_equal audit_global_identifier_coverage Haudit) as Hfield.
  cbn [cleaned_identifier_coverage_audit
       all_identifier_coverage_checks_pass] in Hfield.
  exact Hfield.
Qed.

Lemma cleaned_identifier_coverage_audit_public_checked :
  forall source cleaned,
    cleaned_identifier_coverage_audit source cleaned =
      all_identifier_coverage_checks_pass ->
    identifiers_includedb
      (unit_public_idents source) (unit_public_idents cleaned) = true.
Proof.
  intros source cleaned Haudit.
  pose proof (f_equal audit_public_identifier_coverage Haudit) as Hfield.
  cbn [cleaned_identifier_coverage_audit
       all_identifier_coverage_checks_pass] in Hfield.
  exact Hfield.
Qed.

Lemma cleaned_identifier_coverage_audit_composite_checked :
  forall source cleaned,
    cleaned_identifier_coverage_audit source cleaned =
      all_identifier_coverage_checks_pass ->
    identifiers_includedb
      (composite_identifiers (unit_composite_definitions source))
      (composite_identifiers (unit_composite_definitions cleaned)) = true.
Proof.
  intros source cleaned Haudit.
  pose proof (f_equal audit_composite_identifier_coverage Haudit) as Hfield.
  cbn [cleaned_identifier_coverage_audit
       all_identifier_coverage_checks_pass] in Hfield.
  exact Hfield.
Qed.

Lemma cleaned_identifier_coverage_audit_sound :
  forall source cleaned,
    cleaned_identifier_coverage_audit source cleaned =
      all_identifier_coverage_checks_pass ->
    incl (global_identifiers (unit_global_definitions source))
         (global_identifiers (unit_global_definitions cleaned)) /\
    incl (unit_public_idents source) (unit_public_idents cleaned) /\
    incl (composite_identifiers (unit_composite_definitions source))
         (composite_identifiers (unit_composite_definitions cleaned)).
Proof.
  intros source cleaned Haudit. repeat split;
    apply identifiers_includedb_sound.
  - now apply cleaned_identifier_coverage_audit_global_checked.
  - now apply cleaned_identifier_coverage_audit_public_checked.
  - now apply cleaned_identifier_coverage_audit_composite_checked.
Qed.

Definition ast_global_names_disjoint
    (left right : AST.program Clight.fundef type) : Prop :=
  forall id, In id (ast_global_names left) ->
             ~ In id (ast_global_names right).

Lemma ast_prog_defmap_name :
  forall (program : AST.program Clight.fundef type) id definition,
    (AST.prog_defmap program) ! id = Some definition ->
    In id (ast_global_names program).
Proof.
  intros program id definition Hget.
  unfold ast_global_names, AST.prog_defs_names.
  apply in_map_iff. exists (id, definition). split; [reflexivity |].
  now apply AST.in_prog_defmap in Hget.
Qed.

(** Opaque one-sided reductions for [link_prog_merge].  Rewriting with these
    lemmas is deliberately preferable to [cbn] on a hypothesis containing a
    [globdef]: generic simplification can inspect an arbitrary internal Clight
    body even though the option shape already determines the result. *)
Lemma link_prog_merge_some_none :
  forall definition : globdef Clight.fundef type,
    @link_prog_merge Clight.fundef type _ _
      (Some definition) None = Some definition.
Proof. reflexivity. Qed.

Lemma link_prog_merge_none_some :
  forall definition : globdef Clight.fundef type,
    @link_prog_merge Clight.fundef type _ _
      None (Some definition) = Some definition.
Proof. reflexivity. Qed.

Lemma link_prog_merge_none_none :
  @link_prog_merge Clight.fundef type _ _ None None = None.
Proof. reflexivity. Qed.

(** Keep the payload type abstract while reasoning about [PTree.combine].
    In particular, this prevents conversion from inspecting a concrete
    [Clight.fundef] merely to reduce a one-sided option merge. *)
Lemma ptree_combine_disjoint_get_iff :
  forall (A : Type) (merge : option A -> option A -> option A)
      (left right : PTree.t A),
    (forall definition, merge (Some definition) None = Some definition) ->
    (forall definition, merge None (Some definition) = Some definition) ->
    merge None None = None ->
    (forall id left_definition right_definition,
      left ! id = Some left_definition ->
      right ! id = Some right_definition -> False) ->
    forall id definition,
      (PTree.combine merge left right) ! id = Some definition <->
      left ! id = Some definition \/ right ! id = Some definition.
Proof.
  intros A merge left right Hsome_none Hnone_some Hnone_none
    Hdisjoint id definition.
  rewrite PTree.gcombine by exact Hnone_none.
  destruct (left ! id) as [left_definition |] eqn:Hleft;
    destruct (right ! id) as [right_definition |] eqn:Hright.
  - exfalso. eapply Hdisjoint; eauto.
  - rewrite Hsome_none. intuition congruence.
  - rewrite Hnone_some. intuition congruence.
  - rewrite Hnone_none. intuition discriminate.
Qed.

Lemma ast_link_disjoint_programs :
  forall (left right : AST.program Clight.fundef type),
    left.(AST.prog_main) = right.(AST.prog_main) ->
    ast_global_names_disjoint left right ->
    exists linked,
      link left right = Some linked /\
      (forall id,
        In id (ast_global_names linked) <->
        In id (ast_global_names left) \/
        In id (ast_global_names right)) /\
      (forall id definition,
        In (id, definition) linked.(AST.prog_defs) ->
        In (id, definition) left.(AST.prog_defs) \/
        In (id, definition) right.(AST.prog_defs)) /\
      linked.(AST.prog_main) = left.(AST.prog_main).
Proof.
  intros left right Hmain Hdisjoint.
  assert (Hmap_disjoint :
    forall id left_definition right_definition,
      (AST.prog_defmap left) ! id = Some left_definition ->
      (AST.prog_defmap right) ! id = Some right_definition -> False).
  {
    intros id left_definition right_definition Hleft Hright.
    eapply (Hdisjoint id).
    - exact (ast_prog_defmap_name left id left_definition Hleft).
    - exact (ast_prog_defmap_name right id right_definition Hright).
  }
  set (merged_map := PTree.combine (@link_prog_merge Clight.fundef type _ _)
    (AST.prog_defmap left) (AST.prog_defmap right)).
  set (linked :=
    {| AST.prog_defs := PTree.elements merged_map;
       AST.prog_public := left.(AST.prog_public) ++ right.(AST.prog_public);
       AST.prog_main := left.(AST.prog_main) |}).
  assert (Hlink : link left right = Some linked).
  {
    unfold linked, merged_map.
    apply link_prog_succeeds; [exact Hmain |].
    intros id left_definition right_definition Hleft Hright.
    exfalso.
    exact (Hmap_disjoint id left_definition right_definition Hleft Hright).
  }
  assert (Hmerged_get :
    forall id definition,
      merged_map ! id = Some definition <->
      (AST.prog_defmap left) ! id = Some definition \/
      (AST.prog_defmap right) ! id = Some definition).
  {
    intros id definition. unfold merged_map.
    eapply ptree_combine_disjoint_get_iff.
    - exact link_prog_merge_some_none.
    - exact link_prog_merge_none_some.
    - exact link_prog_merge_none_none.
    - exact Hmap_disjoint.
  }
  exists linked. split; [exact Hlink |]. split.
  - intros id. split.
    + intros Hin.
      destruct (AST.prog_defmap_dom linked id Hin) as [definition Hget].
      unfold linked in Hget. rewrite prog_defmap_elements in Hget.
      apply Hmerged_get in Hget. destruct Hget as [Hleft | Hright].
      * left. exact (ast_prog_defmap_name left id definition Hleft).
      * right. exact (ast_prog_defmap_name right id definition Hright).
    + intros [Hin | Hin].
      * destruct (AST.prog_defmap_dom left id Hin) as [definition Hleft].
        apply (ast_prog_defmap_name linked id definition).
        unfold linked. rewrite prog_defmap_elements.
        apply Hmerged_get. now left.
      * destruct (AST.prog_defmap_dom right id Hin) as [definition Hright].
        apply (ast_prog_defmap_name linked id definition).
        unfold linked. rewrite prog_defmap_elements.
        apply Hmerged_get. now right.
  - split.
    + intros id definition Hin.
      unfold linked in Hin.
      apply PTree.elements_complete in Hin.
      apply Hmerged_get in Hin. destruct Hin as [Hleft | Hright].
      * left. now apply AST.in_prog_defmap in Hleft.
      * right. now apply AST.in_prog_defmap in Hright.
    + reflexivity.
Qed.

Fixpoint units_share_main
    (main : ident) (units : nlist Clight.program) : Prop :=
  match units with
  | nbase unit => unit.(prog_main) = main
  | ncons unit rest =>
      unit.(prog_main) = main /\ units_share_main main rest
  end.

Definition ident_eqb (left right : ident) : bool :=
  if peq left right then true else false.

Fixpoint units_share_mainb
    (main : ident) (units : nlist Clight.program) : bool :=
  match units with
  | nbase unit => ident_eqb unit.(prog_main) main
  | ncons unit rest =>
      andb (ident_eqb unit.(prog_main) main)
           (units_share_mainb main rest)
  end.

Lemma units_share_mainb_sound :
  forall main units,
    units_share_mainb main units = true -> units_share_main main units.
Proof.
  intros main units. induction units as [unit | unit rest IH]; cbn.
  - unfold ident_eqb. destruct (peq (prog_main unit) main); congruence.
  - rewrite andb_true_iff. intros [Hunit Hrest]. split.
    + unfold ident_eqb in Hunit.
      destruct (peq (prog_main unit) main); congruence.
    + now apply IH.
Qed.

Theorem us_cleaned_units_share_main_checked :
  units_share_mainb us_game_init._main us_cleaned_units = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_cleaned_units_share_main_checked :
  units_share_mainb jp_game_init._main jp_cleaned_units = true.
Proof. vm_compute. reflexivity. Qed.

Lemma NoDup_app_inv :
  forall (A : Type) (left right : list A),
    NoDup (left ++ right) ->
    NoDup left /\ NoDup right /\
    (forall value, In value left -> In value right -> False).
Proof.
  intros A left. induction left as [| value left IH]; intros right Hnodup.
  - cbn in Hnodup. split; [constructor |]. split; [exact Hnodup |].
    intros candidate Hcandidate. contradiction.
  - cbn in Hnodup. inversion Hnodup as [| ? ? Hfresh Htail]; subst.
    destruct (IH right Htail) as (Hleft & Hright & Hcross).
    repeat split.
    + constructor.
      * intro Hin. apply Hfresh. apply in_or_app. now left.
      * exact Hleft.
    + exact Hright.
    + intros candidate [<- | Hin_left] Hin_right.
      * apply Hfresh. apply in_or_app. now right.
      * exact (Hcross candidate Hin_left Hin_right).
Qed.

Theorem ast_link_list_unique_names :
  forall units main,
    units_share_main main units ->
    NoDup (cleaned_global_identifiers units) ->
    exists linked,
      link_list (map_nlist program_components units) = Some linked /\
      (forall id,
        In id (ast_global_names linked) <->
        In id (cleaned_global_identifiers units)) /\
      (forall id definition,
        In (id, definition) linked.(AST.prog_defs) ->
        In (id, definition) (unit_global_definitions units)) /\
      linked.(AST.prog_main) = main.
Proof.
  intros units. induction units as [unit | unit rest IH]; intros main Hmain Hnodup.
  - exists (program_components unit). cbn in *. split; [reflexivity |].
    split; [tauto |]. split; [| exact Hmain].
    intros id definition Hin. apply in_or_app. now left.
  - cbn in Hmain, Hnodup |- *. destruct Hmain as [Hunit_main Hrest_main].
    destruct (NoDup_app_inv _ _ _ Hnodup)
      as (Hunit_nodup & Hrest_nodup & Hcross).
    destruct (IH main Hrest_main Hrest_nodup)
      as (rest_linked & Hrest_link & Hrest_domain &
          Hrest_provenance & Hrest_linked_main).
    assert (Hdisjoint :
      ast_global_names_disjoint (program_components unit) rest_linked).
    {
      intros id Hunit_id Hrest_id.
      apply Hrest_domain in Hrest_id.
      exact (Hcross id Hunit_id Hrest_id).
    }
    destruct (ast_link_disjoint_programs
      (program_components unit) rest_linked)
      as (linked & Hlink & Hdomain & Hprovenance & Hlinked_main).
    { cbn. now rewrite Hunit_main, Hrest_linked_main. }
    { exact Hdisjoint. }
    exists linked. split.
    + now rewrite Hrest_link, Hlink.
    + split.
      * intros query. rewrite Hdomain, Hrest_domain, in_app_iff. tauto.
      * split.
        -- intros id definition Hin.
           destruct (Hprovenance id definition Hin) as [Hin_unit | Hin_rest].
           ++ apply in_or_app. now left.
           ++ apply in_or_app. right.
              exact (Hrest_provenance id definition Hin_rest).
        -- transitivity (prog_main unit);
             [exact Hlinked_main | exact Hunit_main].
Qed.

(** Project the concrete-link witness while the unit list is still abstract.
    Keeping both executable receipts as inputs prevents later US/JP uses from
    eliminating the richer recursive theorem over large concrete Clight
    syntax. *)
Theorem ast_link_list_exists_from_checks :
  forall units main,
    units_share_mainb main units = true ->
    identifiers_unique (cleaned_global_identifiers units) = true ->
    exists linked,
      link_list (map_nlist program_components units) = Some linked.
Proof.
  intros units main Hmain_checked Hunique_checked.
  pose proof (units_share_mainb_sound main units Hmain_checked) as Hmain.
  pose proof (identifiers_unique_nodup _ Hunique_checked) as Hnodup.
  destruct (ast_link_list_unique_names units main Hmain Hnodup)
    as (linked & Hlink & _).
  now exists linked.
Qed.

Theorem us_cleaned_ast_link_exists :
  exists linked,
    link_list (map_nlist program_components us_cleaned_units) = Some linked.
Proof.
  exact (ast_link_list_exists_from_checks
    us_cleaned_units us_game_init._main
    us_cleaned_units_share_main_checked
    us_cleaned_global_identifiers_unique_checked).
Qed.

Theorem jp_cleaned_ast_link_exists :
  exists linked,
    link_list (map_nlist program_components jp_cleaned_units) = Some linked.
Proof.
  exact (ast_link_list_exists_from_checks
    jp_cleaned_units jp_game_init._main
    jp_cleaned_units_share_main_checked
    jp_cleaned_global_identifiers_unique_checked).
Qed.

Fixpoint units_use_composite_header
    (types : list composite_definition)
    (units : nlist Clight.program) : Prop :=
  match units with
  | nbase unit => unit.(prog_types) = types
  | ncons unit rest =>
      unit.(prog_types) = types /\
      units_use_composite_header types rest
  end.

Lemma pointwise_ownership_uses_composite_header :
  forall normalized source cleaned,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source cleaned ->
    units_use_composite_header normalized.(prog_types) cleaned.
Proof.
  intros normalized source cleaned Hpointwise.
  induction Hpointwise; cbn.
  - destruct H as (_ & _ & _ & _ & Htypes). exact Htypes.
  - destruct H as (_ & _ & _ & _ & Htypes). now split.
Qed.

Lemma composite_link_list_shared_header :
  forall units types,
    units_use_composite_header types units ->
    link types types = Some types ->
    link_list (map_nlist composite_components units) = Some types.
Proof.
  intros units. induction units as [unit | unit rest IH];
    intros types Hheaders Hself; cbn in *;
    unfold composite_components in *.
  - now rewrite Hheaders.
  - destruct Hheaders as [Hunit Hrest].
    rewrite (IH types Hrest Hself), Hunit. exact Hself.
Qed.

Lemma units_using_header_have_aggregate_composite_provenance :
  forall units types universe,
    units_use_composite_header types units ->
    incl types universe ->
    incl (unit_composite_definitions units) universe.
Proof.
  intros units. induction units as [unit | unit rest IH];
    intros types universe Hheaders Hprovenance; cbn in *.
  - rewrite Hheaders, app_nil_r. exact Hprovenance.
  - destruct Hheaders as [Hunit Hrest]. intros definition Hin.
    apply in_app_or in Hin. destruct Hin as [Hin | Hin].
    + apply Hprovenance. now rewrite <- Hunit.
    + eapply IH; eauto.
Qed.

Theorem us_normalized_slice_types_are_normalized_composites :
  us_normalized_semantic_slice.(prog_types) = us_normalized_composites.
Proof.
  vm_compute. reflexivity.
Qed.

Theorem jp_normalized_slice_types_are_normalized_composites :
  jp_normalized_semantic_slice.(prog_types) = jp_normalized_composites.
Proof.
  vm_compute. reflexivity.
Qed.

Theorem us_cleaned_composites_have_source_provenance :
  incl (unit_composite_definitions us_cleaned_units)
       (unit_composite_definitions us_units).
Proof.
  eapply units_using_header_have_aggregate_composite_provenance.
  - exact (pointwise_ownership_uses_composite_header
      us_normalized_semantic_slice us_units us_cleaned_units
      us_cleaned_units_pointwise_ownership).
  - rewrite us_normalized_slice_types_are_normalized_composites.
    apply normalized_composites_have_source_provenance.
Qed.

Theorem jp_cleaned_composites_have_source_provenance :
  incl (unit_composite_definitions jp_cleaned_units)
       (unit_composite_definitions jp_units).
Proof.
  eapply units_using_header_have_aggregate_composite_provenance.
  - exact (pointwise_ownership_uses_composite_header
      jp_normalized_semantic_slice jp_units jp_cleaned_units
      jp_cleaned_units_pointwise_ownership).
  - rewrite jp_normalized_slice_types_are_normalized_composites.
    apply normalized_composites_have_source_provenance.
Qed.

Theorem us_normalized_composite_header_self_link_checked :
  link us_normalized_semantic_slice.(prog_types)
       us_normalized_semantic_slice.(prog_types) =
  Some us_normalized_semantic_slice.(prog_types).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_normalized_composite_header_self_link_checked :
  link jp_normalized_semantic_slice.(prog_types)
       jp_normalized_semantic_slice.(prog_types) =
  Some jp_normalized_semantic_slice.(prog_types).
Proof. vm_compute. reflexivity. Qed.

Theorem us_cleaned_composite_link :
  link_list (map_nlist composite_components us_cleaned_units) =
  Some us_normalized_semantic_slice.(prog_types).
Proof.
  eapply composite_link_list_shared_header.
  - exact (pointwise_ownership_uses_composite_header
      us_normalized_semantic_slice us_units us_cleaned_units
      us_cleaned_units_pointwise_ownership).
  - exact us_normalized_composite_header_self_link_checked.
Qed.

Theorem jp_cleaned_composite_link :
  link_list (map_nlist composite_components jp_cleaned_units) =
  Some jp_normalized_semantic_slice.(prog_types).
Proof.
  eapply composite_link_list_shared_header.
  - exact (pointwise_ownership_uses_composite_header
      jp_normalized_semantic_slice jp_units jp_cleaned_units
      jp_cleaned_units_pointwise_ownership).
  - exact jp_normalized_composite_header_self_link_checked.
Qed.

Lemma clight_link_projects_composite_components :
  forall (left right linked : Clight.program),
    link left right = Some linked ->
    link (composite_components left) (composite_components right) =
    Some (composite_components linked).
Proof.
  intros left right linked Hlink.
  Local Transparent Ctypes.Linker_program.
  unfold link, Ctypes.Linker_program, Ctypes.link_program in Hlink.
  destruct (link (Ctypes.program_of_program left)
    (Ctypes.program_of_program right))
    as [ast |] eqn:Hast; try discriminate.
  destruct (Ctypes.lift_option
    (link (Ctypes.prog_types left) (Ctypes.prog_types right)))
    as [[types Htypes] | Htypes]; try discriminate.
  destruct (Ctypes.link_build_composite_env
    (prog_types left) (prog_types right) types
    (prog_comp_env left) (prog_comp_env right)
    (prog_comp_env_eq left) (prog_comp_env_eq right)
    Htypes) as (env & Henv & Hextends).
  inversion Hlink; subst linked. exact Htypes.
Qed.

Lemma clight_link_list_projects_composite_components :
  forall (units : nlist Clight.program) linked,
    link_list units = Some linked ->
    link_list (map_nlist composite_components units) =
    Some (composite_components linked).
Proof.
  induction units as [unit | unit rest IH]; cbn.
  - intros linked Hlink. now inversion Hlink.
  - intros linked Hlink.
    destruct (link_list rest) as [rest_linked |] eqn:Hrest;
      try discriminate.
    specialize (IH rest_linked eq_refl). rewrite IH.
    now eapply clight_link_projects_composite_components.
Qed.

Lemma ast_and_composite_links_lift_to_clight_link :
  forall units ast_linked composite_linked,
    link_list (map_nlist program_components units) = Some ast_linked ->
    link_list (map_nlist composite_components units) = Some composite_linked ->
    exists linked, link_list units = Some linked.
Proof.
  induction units as [unit | unit rest IH];
    intros ast_linked composite_linked Hast Htypes; cbn in *.
  - exists unit. reflexivity.
  - destruct (link_list (map_nlist program_components rest))
      as [rest_ast |] eqn:Hrest_ast; try discriminate.
    destruct (link_list (map_nlist composite_components rest))
      as [rest_types |] eqn:Hrest_types; try discriminate.
    destruct (IH rest_ast rest_types eq_refl eq_refl)
      as [rest_linked Hrest_linked].
    pose proof (clight_link_list_projects_program_components
      rest rest_linked Hrest_linked) as Hrest_ast_projection.
    pose proof (clight_link_list_projects_composite_components
      rest rest_linked Hrest_linked) as Hrest_type_projection.
    rewrite Hrest_ast in Hrest_ast_projection.
    rewrite Hrest_types in Hrest_type_projection.
    inversion Hrest_ast_projection; subst rest_ast.
    inversion Hrest_type_projection; subst rest_types.
    rewrite Hrest_linked.
    unfold program_components in Hast.
    unfold Clight.fundef in Hast.
    unfold composite_components in Htypes.
    change (link (prog_types unit) (prog_types rest_linked) =
      Some composite_linked) in Htypes.
    Local Transparent Ctypes.Linker_program.
    change (exists linked, Ctypes.link_program unit rest_linked = Some linked).
    unfold Ctypes.link_program.
    rewrite Hast.
    destruct (Ctypes.lift_option
      (link (prog_types unit) (prog_types rest_linked)))
      as [[types Hlinked_types] | Hlinked_types].
    + destruct (Ctypes.link_build_composite_env
        (prog_types unit) (prog_types rest_linked) types
        (prog_comp_env unit) (prog_comp_env rest_linked)
        (prog_comp_env_eq unit) (prog_comp_env_eq rest_linked)
        Hlinked_types) as (env & Henv & Hextends).
      eexists. reflexivity.
    + rewrite Hlinked_types in Htypes. discriminate.
Qed.

(** Eliminate the component witnesses while [units] is still abstract.  This
    prevents concrete US/JP proofs from reducing the recursive AST-link
    witness over their large generated terms. *)
Theorem clight_link_list_exists_from_component_links :
  forall units composite_linked,
    (exists ast_linked,
      link_list (map_nlist program_components units) = Some ast_linked) ->
    link_list (map_nlist composite_components units) = Some composite_linked ->
    exists linked, link_list units = Some linked.
Proof.
  intros units composite_linked [ast_linked Hast] Htypes.
  exact (ast_and_composite_links_lift_to_clight_link
    units ast_linked composite_linked Hast Htypes).
Qed.

Theorem us_cleaned_official_link_exists :
  exists linked, link_list us_cleaned_units = Some linked.
Proof.
  exact (clight_link_list_exists_from_component_links
    us_cleaned_units us_normalized_semantic_slice.(prog_types)
    us_cleaned_ast_link_exists us_cleaned_composite_link).
Qed.

Theorem jp_cleaned_official_link_exists :
  exists linked, link_list jp_cleaned_units = Some linked.
Proof.
  exact (clight_link_list_exists_from_component_links
    jp_cleaned_units jp_normalized_semantic_slice.(prog_types)
    jp_cleaned_ast_link_exists jp_cleaned_composite_link).
Qed.

Definition us_cleaned_official_link_result := link_list us_cleaned_units.
Definition jp_cleaned_official_link_result := link_list jp_cleaned_units.

Definition us_official_cleaned_slice : Clight.program :=
  match us_cleaned_official_link_result with
  | Some linked => linked
  | None => us_normalized_semantic_slice
  end.

Definition jp_official_cleaned_slice : Clight.program :=
  match jp_cleaned_official_link_result with
  | Some linked => linked
  | None => jp_normalized_semantic_slice
  end.

Lemma successful_option_is_exact_total_result :
  forall (result : option Clight.program) fallback,
    (exists value, result = Some value) ->
    result = Some
      (match result with Some value => value | None => fallback end).
Proof.
  intros result fallback [value Hresult]. now subst result.
Qed.

Theorem us_cleaned_units_official_link :
  link_list us_cleaned_units = Some us_official_cleaned_slice.
Proof.
  unfold us_official_cleaned_slice, us_cleaned_official_link_result.
  apply successful_option_is_exact_total_result.
  exact us_cleaned_official_link_exists.
Qed.

Theorem jp_cleaned_units_official_link :
  link_list jp_cleaned_units = Some jp_official_cleaned_slice.
Proof.
  unfold jp_official_cleaned_slice, jp_cleaned_official_link_result.
  apply successful_option_is_exact_total_result.
  exact jp_cleaned_official_link_exists.
Qed.

(** The definition list of an official Clight link is not merely name-equivalent
    to the cleaned inputs: every linked [(id, definition)] pair is copied
    verbatim from one of those inputs.  The proof projects the successful
    Clight link to the official AST linker, then uses the disjoint-name link
    construction above. *)
Lemma official_linked_definitions_have_cleaned_unit_provenance :
  forall units linked main,
    units_share_main main units ->
    NoDup (cleaned_global_identifiers units) ->
    link_list units = Some linked ->
    forall id definition,
      In (id, definition) linked.(prog_defs) ->
      In (id, definition) (unit_global_definitions units).
Proof.
  intros units linked main Hmain Hunique Hlink id definition Hin.
  destruct (ast_link_list_unique_names units main Hmain Hunique)
    as (ast_linked & Hast & Hdomain & Hprovenance & Hlinked_main).
  pose proof (clight_link_list_projects_program_components
    units linked Hlink) as Hprojection.
  rewrite Hast in Hprojection. inversion Hprojection; subst ast_linked.
  exact (Hprovenance id definition Hin).
Qed.

Lemma cleaned_global_identifiers_are_aggregate_global_identifiers :
  forall units,
    cleaned_global_identifiers units =
    global_identifiers (unit_global_definitions units).
Proof.
  intros units. induction units as [unit | unit rest IH]; cbn.
  - now rewrite app_nil_r.
  - unfold global_identifiers in *. now rewrite map_app, IH.
Qed.

Lemma nodup_global_identifiers_definition_unique :
  forall definitions id left_definition right_definition,
    NoDup (global_identifiers definitions) ->
    In (id, left_definition) definitions ->
    In (id, right_definition) definitions ->
    left_definition = right_definition.
Proof.
  intros definitions. induction definitions as
    [| [head_id head_definition] rest IH];
    intros id left_definition right_definition Hunique Hleft Hright; cbn in *.
  - contradiction.
  - inversion Hunique as [| ? ? Hfresh Htail]; subst.
    destruct Hleft as [Hleft | Hleft];
      destruct Hright as [Hright | Hright].
    + inversion Hleft; inversion Hright; congruence.
    + inversion Hleft; subst id left_definition.
      exfalso. apply Hfresh.
      exact (in_map (@fst ident (globdef Clight.fundef type))
        rest (head_id, right_definition) Hright).
    + inversion Hright; subst id right_definition.
      exfalso. apply Hfresh.
      exact (in_map (@fst ident (globdef Clight.fundef type))
        rest (head_id, left_definition) Hleft).
    + eapply IH.
      * unfold global_identifiers. exact Htail.
      * exact Hleft.
      * exact Hright.
Qed.

(** Conversely, global name uniqueness makes every cleaned input definition
    recoverable verbatim from the official output.  Name-domain equality gives
    an output definition with the same identifier; output provenance and
    [NoDup] force its payload to be the input payload. *)
Lemma official_linked_definitions_include_cleaned_unit_definitions :
  forall units linked main,
    units_share_main main units ->
    NoDup (cleaned_global_identifiers units) ->
    link_list units = Some linked ->
    incl (unit_global_definitions units) linked.(prog_defs).
Proof.
  intros units linked main Hmain Hunique Hlink [id definition] Hin.
  destruct (ast_link_list_unique_names units main Hmain Hunique)
    as (ast_linked & Hast & Hdomain & Hprovenance & Hlinked_main).
  pose proof (clight_link_list_projects_program_components
    units linked Hlink) as Hprojection.
  rewrite Hast in Hprojection. inversion Hprojection; subst ast_linked.
  assert (Haggregate_unique :
    NoDup (global_identifiers (unit_global_definitions units))).
  {
    now rewrite <- cleaned_global_identifiers_are_aggregate_global_identifiers.
  }
  assert (Hid : In id (cleaned_global_identifiers units)).
  {
    rewrite cleaned_global_identifiers_are_aggregate_global_identifiers.
    unfold global_identifiers. apply in_map_iff.
    exists (id, definition). now split.
  }
  apply (proj2 (Hdomain id)) in Hid.
  destruct (AST.prog_defmap_dom (program_components linked) id Hid)
    as [linked_definition Hget].
  pose proof Hget as Hlinked_entry.
  apply AST.in_prog_defmap in Hlinked_entry.
  pose proof (Hprovenance id linked_definition Hlinked_entry)
    as Hlinked_provenance.
  assert (definition = linked_definition).
  {
    eapply nodup_global_identifiers_definition_unique; eauto.
  }
  now subst linked_definition.
Qed.

(** Package both directions while the unit list remains abstract.  Concrete
    US/JP clients consume only this opaque theorem, rather than eliminating
    [ast_link_list_unique_names] over generated Clight syntax. *)
Theorem official_linked_definition_membership_exact_from_checks :
  forall units linked main,
    units_share_mainb main units = true ->
    identifiers_unique (cleaned_global_identifiers units) = true ->
    link_list units = Some linked ->
    forall entry,
      In entry linked.(prog_defs) <->
      In entry (unit_global_definitions units).
Proof.
  intros units linked main Hmain_checked Hunique_checked Hlink entry.
  pose proof (units_share_mainb_sound main units Hmain_checked) as Hmain.
  pose proof (identifiers_unique_nodup _ Hunique_checked) as Hunique.
  split.
  - destruct entry as [id definition].
    exact (official_linked_definitions_have_cleaned_unit_provenance
      units linked main Hmain Hunique Hlink id definition).
  - exact (official_linked_definitions_include_cleaned_unit_definitions
      units linked main Hmain Hunique Hlink entry).
Qed.

Theorem us_official_cleaned_definition_membership_exact :
  forall entry,
    In entry us_official_cleaned_slice.(prog_defs) <->
    In entry (unit_global_definitions us_cleaned_units).
Proof.
  exact (official_linked_definition_membership_exact_from_checks
    us_cleaned_units us_official_cleaned_slice us_game_init._main
    us_cleaned_units_share_main_checked
    us_cleaned_global_identifiers_unique_checked
    us_cleaned_units_official_link).
Qed.

Theorem jp_official_cleaned_definition_membership_exact :
  forall entry,
    In entry jp_official_cleaned_slice.(prog_defs) <->
    In entry (unit_global_definitions jp_cleaned_units).
Proof.
  exact (official_linked_definition_membership_exact_from_checks
    jp_cleaned_units jp_official_cleaned_slice jp_game_init._main
    jp_cleaned_units_share_main_checked
    jp_cleaned_global_identifiers_unique_checked
    jp_cleaned_units_official_link).
Qed.

Theorem us_official_cleaned_definition_provenance :
  forall id definition,
    In (id, definition) us_official_cleaned_slice.(prog_defs) ->
    In (id, definition) (unit_global_definitions us_cleaned_units).
Proof.
  intros id definition Hin.
  exact (proj1
    (us_official_cleaned_definition_membership_exact (id, definition)) Hin).
Qed.

Theorem jp_official_cleaned_definition_provenance :
  forall id definition,
    In (id, definition) jp_official_cleaned_slice.(prog_defs) ->
    In (id, definition) (unit_global_definitions jp_cleaned_units).
Proof.
  intros id definition Hin.
  exact (proj1
    (jp_official_cleaned_definition_membership_exact (id, definition)) Hin).
Qed.

Theorem us_cleaned_definitions_have_official_membership :
  incl (unit_global_definitions us_cleaned_units)
       us_official_cleaned_slice.(prog_defs).
Proof.
  intros entry Hin.
  exact (proj2 (us_official_cleaned_definition_membership_exact entry) Hin).
Qed.

Theorem jp_cleaned_definitions_have_official_membership :
  incl (unit_global_definitions jp_cleaned_units)
       jp_official_cleaned_slice.(prog_defs).
Proof.
  intros entry Hin.
  exact (proj2 (jp_official_cleaned_definition_membership_exact entry) Hin).
Qed.

Theorem official_preserves_source_strong_definitions_from_membership :
  forall source cleaned official,
    incl (filter preserve_definition_verbatim
            (unit_global_definitions source))
         (unit_global_definitions cleaned) ->
    incl (unit_global_definitions cleaned) official.(prog_defs) ->
    incl (filter preserve_definition_verbatim
            (unit_global_definitions source))
         official.(prog_defs).
Proof.
  intros source cleaned official Hsource Hofficial entry Hin.
  exact (Hofficial entry (Hsource entry Hin)).
Qed.

Theorem us_official_preserves_source_strong_definitions_verbatim :
  incl (filter preserve_definition_verbatim
          (unit_global_definitions us_units))
       us_official_cleaned_slice.(prog_defs).
Proof.
  exact (official_preserves_source_strong_definitions_from_membership
    us_units us_cleaned_units us_official_cleaned_slice
    us_cleaned_units_preserve_strong_definitions_verbatim
    us_cleaned_definitions_have_official_membership).
Qed.

Theorem jp_official_preserves_source_strong_definitions_verbatim :
  incl (filter preserve_definition_verbatim
          (unit_global_definitions jp_units))
       jp_official_cleaned_slice.(prog_defs).
Proof.
  exact (official_preserves_source_strong_definitions_from_membership
    jp_units jp_cleaned_units jp_official_cleaned_slice
    jp_cleaned_units_preserve_strong_definitions_verbatim
    jp_cleaned_definitions_have_official_membership).
Qed.

Theorem official_definition_source_provenance_transitive :
  forall source cleaned official,
    (forall id definition,
      In (id, definition) official.(prog_defs) ->
      In (id, definition) (unit_global_definitions cleaned)) ->
    incl (unit_global_definitions cleaned)
         (unit_global_definitions source) ->
    forall id definition,
      In (id, definition) official.(prog_defs) ->
      In (id, definition) (unit_global_definitions source).
Proof.
  intros source cleaned official Hofficial Hsource id definition Hin.
  exact (Hsource (id, definition) (Hofficial id definition Hin)).
Qed.

Theorem us_official_cleaned_definition_source_provenance :
  forall id definition,
    In (id, definition) us_official_cleaned_slice.(prog_defs) ->
    In (id, definition) (unit_global_definitions us_units).
Proof.
  exact (official_definition_source_provenance_transitive
    us_units us_cleaned_units us_official_cleaned_slice
    us_official_cleaned_definition_provenance
    us_cleaned_global_definitions_have_pointwise_source_provenance).
Qed.

Theorem jp_official_cleaned_definition_source_provenance :
  forall id definition,
    In (id, definition) jp_official_cleaned_slice.(prog_defs) ->
    In (id, definition) (unit_global_definitions jp_units).
Proof.
  exact (official_definition_source_provenance_transitive
    jp_units jp_cleaned_units jp_official_cleaned_slice
    jp_official_cleaned_definition_provenance
    jp_cleaned_global_definitions_have_pointwise_source_provenance).
Qed.

Theorem official_link_uses_projected_composite_header :
  forall units linked types,
    link_list units = Some linked ->
    link_list (map_nlist composite_components units) = Some types ->
    linked.(prog_types) = types.
Proof.
  intros units linked types Hlink Htypes.
  pose proof (clight_link_list_projects_composite_components
    units linked Hlink) as Hprojection.
  rewrite Htypes in Hprojection. now inversion Hprojection.
Qed.

Theorem us_official_cleaned_slice_uses_normalized_composite_header :
  us_official_cleaned_slice.(prog_types) =
  us_normalized_semantic_slice.(prog_types).
Proof.
  exact (official_link_uses_projected_composite_header
    us_cleaned_units us_official_cleaned_slice
    us_normalized_semantic_slice.(prog_types)
    us_cleaned_units_official_link us_cleaned_composite_link).
Qed.

Theorem jp_official_cleaned_slice_uses_normalized_composite_header :
  jp_official_cleaned_slice.(prog_types) =
  jp_normalized_semantic_slice.(prog_types).
Proof.
  exact (official_link_uses_projected_composite_header
    jp_cleaned_units jp_official_cleaned_slice
    jp_normalized_semantic_slice.(prog_types)
    jp_cleaned_units_official_link jp_cleaned_composite_link).
Qed.

Lemma pointwise_ownership_transport_header :
  forall source cleaned candidate official,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader candidate)
      source cleaned ->
    official.(prog_types) = candidate.(prog_types) ->
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader official)
      source cleaned.
Proof.
  intros source cleaned candidate official Hpointwise Htypes.
  induction Hpointwise.
  - constructor. destruct H as
      (Hdefs & Hpublic & Hpublic_def & Hmain & Hheader).
    repeat split; auto. now rewrite Htypes.
  - constructor.
    + destruct H as (Hdefs & Hpublic & Hpublic_def & Hmain & Hheader).
      repeat split; auto. now rewrite Htypes.
    + exact IHHpointwise.
Qed.

Theorem us_cleaned_units_pointwise_official_ownership :
  nlist_forall2
    (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader
      us_official_cleaned_slice)
    us_units us_cleaned_units.
Proof.
  exact (pointwise_ownership_transport_header
    us_units us_cleaned_units us_normalized_semantic_slice
    us_official_cleaned_slice us_cleaned_units_pointwise_ownership
    us_official_cleaned_slice_uses_normalized_composite_header).
Qed.

Theorem jp_cleaned_units_pointwise_official_ownership :
  nlist_forall2
    (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader
      jp_official_cleaned_slice)
    jp_units jp_cleaned_units.
Proof.
  exact (pointwise_ownership_transport_header
    jp_units jp_cleaned_units jp_normalized_semantic_slice
    jp_official_cleaned_slice jp_cleaned_units_pointwise_ownership
    jp_official_cleaned_slice_uses_normalized_composite_header).
Qed.

(** Keep the two expensive concrete VM evaluations after all generic link and
    provenance proofs.  This makes proof-development failures surface before
    the several-minute certificate computation, without changing the trusted
    result or the clean-build command. *)
Theorem us_cleaned_identifier_coverage_audit_checked :
  cleaned_identifier_coverage_audit us_units us_cleaned_units =
  all_identifier_coverage_checks_pass.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_cleaned_identifier_coverage_audit_checked :
  cleaned_identifier_coverage_audit jp_units jp_cleaned_units =
  all_identifier_coverage_checks_pass.
Proof. vm_compute. reflexivity. Qed.

Theorem us_cleaned_global_identifier_coverage :
  incl (global_identifiers (unit_global_definitions us_units))
       (global_identifiers (unit_global_definitions us_cleaned_units)).
Proof.
  pose proof (cleaned_identifier_coverage_audit_sound
    us_units us_cleaned_units
    us_cleaned_identifier_coverage_audit_checked) as Hcoverage.
  exact (proj1 Hcoverage).
Qed.

Theorem jp_cleaned_global_identifier_coverage :
  incl (global_identifiers (unit_global_definitions jp_units))
       (global_identifiers (unit_global_definitions jp_cleaned_units)).
Proof.
  pose proof (cleaned_identifier_coverage_audit_sound
    jp_units jp_cleaned_units
    jp_cleaned_identifier_coverage_audit_checked) as Hcoverage.
  exact (proj1 Hcoverage).
Qed.

Theorem us_cleaned_public_identifier_coverage :
  incl (unit_public_idents us_units) (unit_public_idents us_cleaned_units).
Proof.
  pose proof (cleaned_identifier_coverage_audit_sound
    us_units us_cleaned_units
    us_cleaned_identifier_coverage_audit_checked) as Hcoverage.
  exact (proj1 (proj2 Hcoverage)).
Qed.

Theorem jp_cleaned_public_identifier_coverage :
  incl (unit_public_idents jp_units) (unit_public_idents jp_cleaned_units).
Proof.
  pose proof (cleaned_identifier_coverage_audit_sound
    jp_units jp_cleaned_units
    jp_cleaned_identifier_coverage_audit_checked) as Hcoverage.
  exact (proj1 (proj2 Hcoverage)).
Qed.

Theorem us_cleaned_composite_identifier_coverage :
  incl (composite_identifiers (unit_composite_definitions us_units))
       (composite_identifiers
          (unit_composite_definitions us_cleaned_units)).
Proof.
  pose proof (cleaned_identifier_coverage_audit_sound
    us_units us_cleaned_units
    us_cleaned_identifier_coverage_audit_checked) as Hcoverage.
  exact (proj2 (proj2 Hcoverage)).
Qed.

Theorem jp_cleaned_composite_identifier_coverage :
  incl (composite_identifiers (unit_composite_definitions jp_units))
       (composite_identifiers
          (unit_composite_definitions jp_cleaned_units)).
Proof.
  pose proof (cleaned_identifier_coverage_audit_sound
    jp_units jp_cleaned_units
    jp_cleaned_identifier_coverage_audit_checked) as Hcoverage.
  exact (proj2 (proj2 Hcoverage)).
Qed.

Theorem us_normalized_cleaned_units_official_link_structural :
  NormalizedCleanedUnitsOfficialLinkStructuralObligation
    us_units us_official_cleaned_slice.
Proof.
  exists us_cleaned_units.
  split; [exact us_cleaned_unit_count_checked |].
  split; [exact us_cleaned_units_pointwise_official_ownership |].
  split; [exact us_cleaned_units_official_link |].
  split; [exact us_cleaned_global_definitions_have_pointwise_source_provenance |].
  split; [exact us_cleaned_units_preserve_strong_definitions_verbatim |].
  split; [exact us_cleaned_global_identifier_coverage |].
  split; [exact us_cleaned_public_identifier_coverage |].
  split; [exact us_cleaned_composites_have_source_provenance |].
  exact us_cleaned_composite_identifier_coverage.
Qed.

Theorem jp_normalized_cleaned_units_official_link_structural :
  NormalizedCleanedUnitsOfficialLinkStructuralObligation
    jp_units jp_official_cleaned_slice.
Proof.
  exists jp_cleaned_units.
  split; [exact jp_cleaned_unit_count_checked |].
  split; [exact jp_cleaned_units_pointwise_official_ownership |].
  split; [exact jp_cleaned_units_official_link |].
  split; [exact jp_cleaned_global_definitions_have_pointwise_source_provenance |].
  split; [exact jp_cleaned_units_preserve_strong_definitions_verbatim |].
  split; [exact jp_cleaned_global_identifier_coverage |].
  split; [exact jp_cleaned_public_identifier_coverage |].
  split; [exact jp_cleaned_composites_have_source_provenance |].
  exact jp_cleaned_composite_identifier_coverage.
Qed.
