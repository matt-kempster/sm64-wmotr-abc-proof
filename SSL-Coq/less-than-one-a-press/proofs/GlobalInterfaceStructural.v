(** Structural selector and cleaning core for later global-interface proofs.

    The proofs in this file deliberately remain abstract in the translation
    units.  They neither reduce nor instantiate either concrete
    4,000-definition program and do not yet prove concrete global-interface
    agreement. *)

From Coq Require Import List Lia.
From compcert Require Import AST Clight Coqlib Ctypes Errors Linking Maps.
From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms CleanedClightPrograms
  ClightGlobalMemoryRefinement.

Import ListNotations.

(** * Exactness of the preserved strong declarations *)

Lemma filtered_identifier_definition_unique :
  forall (predicate : ident * globdef Clight.fundef type -> bool)
      definitions id left_definition right_definition,
    NoDup (map fst (filter predicate definitions)) ->
    predicate (id, left_definition) = true ->
    predicate (id, right_definition) = true ->
    In (id, left_definition) definitions ->
    In (id, right_definition) definitions ->
    left_definition = right_definition.
Proof.
  intros predicate definitions id left_definition right_definition
    Hunique Hleft_predicate Hright_predicate Hleft Hright.
  eapply nodup_global_identifiers_definition_unique
    with (definitions := filter predicate definitions) (id := id).
  - exact Hunique.
  - apply filter_In. now split.
  - apply filter_In. now split.
Qed.

Lemma checked_internal_selection_is_exact :
  forall definitions selected,
    identifiers_unique (internal_identifiers definitions) = true ->
    all_internal_identifiers_selected definitions selected = true ->
    map_values_have_source_provenance selected definitions ->
    forall id body,
      In (id, Gfun (Internal body)) definitions ->
      PTree.get id selected = Some (Gfun (Internal body)).
Proof.
  intros definitions selected Hunique_checked Hall Hprovenance id body Hin.
  pose proof (identifiers_unique_nodup _ Hunique_checked) as Hunique.
  unfold all_internal_identifiers_selected in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall (id, Gfun (Internal body)) Hin).
  cbn [internal_identifier_selected] in Hall.
  destruct (PTree.get id selected) as
    [[selected_function | selected_variable] |] eqn:Hselected;
    try discriminate.
  destruct selected_function as
    [selected_body | external argument_types result_type calling_convention];
    try discriminate.
  assert (Hselected_source :
    In (id, Gfun (Internal selected_body)) definitions).
  { now eapply Hprovenance. }
  assert (Hequal :
    (Gfun (Internal body) : globdef Clight.fundef type) =
    Gfun (Internal selected_body)).
  {
    eapply filtered_identifier_definition_unique
      with (predicate := is_internal) (definitions := definitions)
           (id := id).
    - exact Hunique.
    - reflexivity.
    - reflexivity.
    - exact Hin.
    - exact Hselected_source.
  }
  inversion Hequal; subst selected_body. reflexivity.
Qed.

Lemma checked_definitive_selection_is_exact :
  forall definitions selected,
    identifiers_unique
      (definitive_variable_identifiers definitions) = true ->
    all_definitive_identifiers_selected definitions selected = true ->
    map_values_have_source_provenance selected definitions ->
    forall id variable,
      definitive_variable variable = true ->
      In (id, Gvar variable) definitions ->
      PTree.get id selected = Some (Gvar variable).
Proof.
  intros definitions selected Hunique_checked Hall Hprovenance
    id variable Hdefinitive Hin.
  pose proof (identifiers_unique_nodup _ Hunique_checked) as Hunique.
  unfold all_definitive_identifiers_selected in Hall.
  rewrite forallb_forall in Hall.
  specialize (Hall (id, Gvar variable) Hin).
  cbn [definitive_identifier_selected] in Hall.
  rewrite Hdefinitive in Hall.
  destruct (PTree.get id selected) as
    [[selected_function | selected_variable] |] eqn:Hselected;
    try discriminate.
  destruct (definitive_variable selected_variable) eqn:Hselected_definitive;
    try discriminate.
  assert (Hselected_source : In (id, Gvar selected_variable) definitions).
  { now eapply Hprovenance. }
  assert (Hequal :
    (Gvar variable : globdef Clight.fundef type) = Gvar selected_variable).
  {
    eapply filtered_identifier_definition_unique
      with (predicate := is_definitive_variable)
           (definitions := definitions) (id := id).
    - exact Hunique.
    - cbn [is_definitive_variable]. exact Hdefinitive.
    - cbn [is_definitive_variable]. exact Hselected_definitive.
    - exact Hin.
    - exact Hselected_source.
  }
  inversion Hequal; subst selected_variable. reflexivity.
Qed.

Lemma checked_preserved_selection_is_exact :
  forall definitions selected,
    identifiers_unique (internal_identifiers definitions) = true ->
    identifiers_unique
      (definitive_variable_identifiers definitions) = true ->
    all_internal_identifiers_selected definitions selected = true ->
    all_definitive_identifiers_selected definitions selected = true ->
    map_values_have_source_provenance selected definitions ->
    forall id definition,
      preserve_definition_verbatim (id, definition) = true ->
      In (id, definition) definitions ->
      PTree.get id selected = Some definition.
Proof.
  intros definitions selected Hinternal_unique Hdefinitive_unique
    Hinternal_selected Hdefinitive_selected Hprovenance
    id definition Hpreserve Hin.
  destruct definition as [[body | external arguments result calling] | variable].
  - eapply checked_internal_selection_is_exact; eauto.
  - discriminate.
  - cbn [preserve_definition_verbatim] in Hpreserve.
    eapply checked_definitive_selection_is_exact; eauto.
Qed.

(** * The weak-declaration selector chooses the normalization payload *)

Fixpoint first_definition_at_strength
    (query : ident) (strength : nat)
    (definitions : list (ident * globdef Clight.fundef type))
    : option (globdef Clight.fundef type) :=
  match definitions with
  | [] => None
  | (id, candidate) :: rest =>
      if peq query id then
        if Nat.eqb (global_definition_strength candidate) strength
        then Some candidate
        else first_definition_at_strength query strength rest
      else first_definition_at_strength query strength rest
  end.

Lemma first_definition_at_strength_app :
  forall query strength left right,
    first_definition_at_strength query strength (left ++ right) =
    match first_definition_at_strength query strength left with
    | Some definition => Some definition
    | None => first_definition_at_strength query strength right
    end.
Proof.
  intros query strength left. induction left as [| [id definition] rest IH];
    intros right; cbn.
  - reflexivity.
  - destruct (peq query id); [destruct (Nat.eqb
      (global_definition_strength definition) strength) |]; auto.
Qed.

Lemma first_definition_at_strength_none :
  forall query strength definitions,
    (forall definition,
      In (query, definition) definitions ->
      global_definition_strength definition <> strength) ->
    first_definition_at_strength query strength definitions = None.
Proof.
  intros query strength definitions Hnone.
  induction definitions as [| [id candidate] rest IH]; cbn.
  - reflexivity.
  - destruct (peq query id) as [<- | Hdifferent].
    + assert (Hdifferent_strength :
        global_definition_strength candidate <> strength).
      { intro Hstrength. eapply (Hnone candidate); [now left | exact Hstrength]. }
      apply Nat.eqb_neq in Hdifferent_strength.
      rewrite Hdifferent_strength.
      apply IH. intros definition Hin Hstrength.
      eapply (Hnone definition); [now right | exact Hstrength].
    + apply IH. intros definition Hin Hstrength.
      eapply (Hnone definition); [now right | exact Hstrength].
Qed.

(** The normalization scan is left biased.  Consequently its selected
    payload is literally the first declaration at the selected (maximal)
    strength, not merely some declaration of equal strength. *)
Lemma scan_result_is_first_at_its_strength :
  forall definitions query selected,
    scan_global_definition query None definitions = Some selected ->
    first_definition_at_strength query
      (global_definition_strength selected) definitions = Some selected.
Proof.
  intros definitions. induction definitions as
    [| [id candidate] rest IH]; intros query selected Hscan; cbn in Hscan |- *.
  - discriminate.
  - destruct (peq query id) as [Hequal | Hdifferent].
    + subst id.
      change (scan_global_definition query (Some candidate) rest =
        Some selected) in Hscan.
      rewrite scan_global_definition_factor in Hscan.
      destruct (scan_global_definition query None rest)
        as [rest_selected |] eqn:Hrest.
      * cbn [prefer_global_definition] in Hscan.
        destruct (Nat.ltb (global_definition_strength candidate)
                          (global_definition_strength rest_selected))
          eqn:Hstronger.
        -- inversion Hscan; subst selected.
           destruct (peq query query) as [_ | Habsurd]; [|contradiction].
           assert (Hdifferent_strength :
             global_definition_strength candidate <>
             global_definition_strength rest_selected).
           { apply Nat.ltb_lt in Hstronger. lia. }
           apply Nat.eqb_neq in Hdifferent_strength.
           rewrite Hdifferent_strength.
           now apply IH.
        -- inversion Hscan; subst selected.
           destruct (peq query query) as [_ | Habsurd]; [|contradiction].
           now rewrite Nat.eqb_refl.
      * cbn [prefer_global_definition] in Hscan.
        inversion Hscan; subst selected.
        destruct (peq query query) as [_ | Habsurd]; [|contradiction].
        now rewrite Nat.eqb_refl.
    + now apply IH.
Qed.

Definition SeenCoversSelectedStrength
    (selected : global_definition_map)
    (prefix : list (ident * globdef Clight.fundef type))
    (seen : PTree.t unit) : Prop :=
  forall id selected_definition candidate,
    PTree.get id selected = Some selected_definition ->
    In (id, candidate) prefix ->
    global_definition_strength candidate =
      global_definition_strength selected_definition ->
    PTree.get id seen = Some tt.

Definition selector_emits_entry
    (selected : global_definition_map) (seen : PTree.t unit)
    (entry : ident * globdef Clight.fundef type) : bool :=
  let '(id, candidate) := entry in
  if preserve_definition_verbatim entry then true
  else
    match PTree.get id seen, PTree.get id selected with
    | None, Some chosen =>
        Nat.eqb (global_definition_strength candidate)
                (global_definition_strength chosen)
    | _, _ => false
    end.

Definition selector_seen_after_entry
    (selected : global_definition_map) (seen : PTree.t unit)
    (entry : ident * globdef Clight.fundef type) : PTree.t unit :=
  if selector_emits_entry selected seen entry
  then PTree.set (fst entry) tt seen
  else seen.

Lemma select_source_owned_definitions_from_cons :
  forall selected seen entry rest,
    select_source_owned_definitions_from selected seen (entry :: rest) =
    let next_seen := selector_seen_after_entry selected seen entry in
    let '(selected_rest, final_seen) :=
      select_source_owned_definitions_from selected next_seen rest in
    (if selector_emits_entry selected seen entry
     then entry :: selected_rest else selected_rest,
     final_seen).
Proof.
  intros selected seen [id candidate] rest.
  unfold selector_seen_after_entry, selector_emits_entry.
  cbn [select_source_owned_definitions_from].
  change (fst (id, candidate)) with id.
  destruct (preserve_definition_verbatim (id, candidate)).
  - destruct (select_source_owned_definitions_from selected
      (PTree.set id tt seen) rest). reflexivity.
  - destruct (PTree.get id seen) as [[] |].
    + destruct (select_source_owned_definitions_from selected seen rest).
      reflexivity.
    + destruct (PTree.get id selected) as [chosen |].
      * destruct (Nat.eqb (global_definition_strength candidate)
                          (global_definition_strength chosen)).
        -- destruct (select_source_owned_definitions_from selected
             (PTree.set id tt seen) rest). reflexivity.
        -- destruct (select_source_owned_definitions_from selected seen rest).
           reflexivity.
      * destruct (select_source_owned_definitions_from selected seen rest).
        reflexivity.
Qed.

Lemma selector_seen_after_entry_preserves_seen :
  forall selected seen entry id,
    PTree.get id seen = Some tt ->
    PTree.get id (selector_seen_after_entry selected seen entry) = Some tt.
Proof.
  intros selected seen [entry_id definition] id Hseen.
  unfold selector_seen_after_entry.
  change (fst (entry_id, definition)) with entry_id.
  destruct (selector_emits_entry selected seen (entry_id, definition));
    [|exact Hseen].
  rewrite PTree.gsspec. destruct (peq id entry_id); [reflexivity | exact Hseen].
Qed.

Lemma selector_seen_after_entry_covers_extended_prefix :
  forall selected prefix seen entry,
    SeenCoversSelectedStrength selected prefix seen ->
    SeenCoversSelectedStrength selected (prefix ++ [entry])
      (selector_seen_after_entry selected seen entry).
Proof.
  intros selected prefix seen [entry_id candidate] Hcovers
    id selected_definition observed Hselected Hin Hstrength.
  apply in_app_or in Hin. destruct Hin as [Hin | [Hequal | []]].
  - apply selector_seen_after_entry_preserves_seen.
    eapply Hcovers.
    + exact Hselected.
    + exact Hin.
    + exact Hstrength.
  - inversion Hequal; subst id observed.
    unfold selector_seen_after_entry, selector_emits_entry.
    change (fst (entry_id, candidate)) with entry_id.
    destruct (preserve_definition_verbatim (entry_id, candidate)) eqn:Hpreserve.
    + apply PTree.gss.
    + destruct (PTree.get entry_id seen) as [[] |] eqn:Hseen.
      * exact Hseen.
      * rewrite Hselected.
        assert (Hequal_strength :
          Nat.eqb (global_definition_strength candidate)
                  (global_definition_strength selected_definition) = true).
        { now apply Nat.eqb_eq. }
        rewrite Hequal_strength.
        apply PTree.gss.
Qed.

Lemma selector_emitted_entry_is_selected :
  forall all selected prefix seen entry rest,
    all = prefix ++ entry :: rest ->
    (forall id,
      PTree.get id selected = scan_global_definition id None all) ->
    (forall id definition,
      preserve_definition_verbatim (id, definition) = true ->
      In (id, definition) all ->
      PTree.get id selected = Some definition) ->
    SeenCoversSelectedStrength selected prefix seen ->
    selector_emits_entry selected seen entry = true ->
    PTree.get (fst entry) selected = Some (snd entry).
Proof.
  intros all selected prefix seen [id candidate] rest Hall Hscan
    Hpreserved Hcovers Hemitted.
  unfold selector_emits_entry in Hemitted.
  destruct (preserve_definition_verbatim (id, candidate)) eqn:Hpreserve.
  - apply Hpreserved; [exact Hpreserve |].
    rewrite Hall. apply in_or_app. right. now left.
  - destruct (PTree.get id seen) as [[] |] eqn:Hseen; try discriminate.
    destruct (PTree.get id selected) as [selected_definition |]
      eqn:Hselected; try discriminate.
    apply Nat.eqb_eq in Hemitted.
    assert (Hprefix_none :
      first_definition_at_strength id
        (global_definition_strength selected_definition) prefix = None).
    {
      apply first_definition_at_strength_none.
      intros definition Hin Hstrength.
      specialize (Hcovers id selected_definition definition
        Hselected Hin Hstrength).
      congruence.
    }
    assert (Hfirst_candidate :
      first_definition_at_strength id
        (global_definition_strength selected_definition) all =
      Some candidate).
    {
      rewrite Hall, first_definition_at_strength_app, Hprefix_none.
      cbn. destruct (peq id id) as [_ | Habsurd]; [|contradiction].
      assert (Hequal_strength :
        Nat.eqb (global_definition_strength candidate)
                (global_definition_strength selected_definition) = true).
      { now apply Nat.eqb_eq. }
      rewrite Hequal_strength.
      reflexivity.
    }
    assert (Hselected_scan :
      scan_global_definition id None all = Some selected_definition).
    { rewrite <- Hscan. exact Hselected. }
    pose proof (scan_result_is_first_at_its_strength
      all id selected_definition Hselected_scan) as Hfirst_selected.
    rewrite Hfirst_candidate in Hfirst_selected.
    inversion Hfirst_selected; subst selected_definition.
    change (PTree.get id selected = Some candidate).
    exact Hselected.
Qed.

Lemma select_source_owned_definitions_from_sound :
  forall all selected prefix rest seen,
    all = prefix ++ rest ->
    (forall id,
      PTree.get id selected = scan_global_definition id None all) ->
    (forall id definition,
      preserve_definition_verbatim (id, definition) = true ->
      In (id, definition) all ->
      PTree.get id selected = Some definition) ->
    SeenCoversSelectedStrength selected prefix seen ->
    forall id definition,
      In (id, definition)
        (fst (select_source_owned_definitions_from selected seen rest)) ->
      PTree.get id selected = Some definition.
Proof.
  intros all selected prefix rest. revert prefix.
  induction rest as [| entry tail IH]; intros prefix seen Hall Hscan
    Hpreserved Hcovers id definition Hin.
  - contradiction.
  - destruct entry as [entry_id entry_definition].
    rewrite select_source_owned_definitions_from_cons in Hin.
    set (next_seen := selector_seen_after_entry selected seen
      (entry_id, entry_definition)) in *.
    cbv zeta in Hin.
    destruct (select_source_owned_definitions_from selected next_seen tail)
      as [selected_tail final_seen] eqn:Htail.
    destruct (selector_emits_entry selected seen
      (entry_id, entry_definition)) eqn:Hemitted;
      cbn in Hin.
    + destruct Hin as [Hequal | Hin].
      * inversion Hequal; subst id definition.
        eapply selector_emitted_entry_is_selected
          with (all := all) (selected := selected) (prefix := prefix)
               (seen := seen) (entry := (entry_id, entry_definition))
               (rest := tail); eauto.
      * eapply (IH (prefix ++ [(entry_id, entry_definition)]) next_seen).
        -- rewrite Hall, <- app_assoc. reflexivity.
        -- exact Hscan.
        -- exact Hpreserved.
        -- subst next_seen.
           now apply selector_seen_after_entry_covers_extended_prefix.
        -- rewrite Htail. exact Hin.
    + eapply (IH (prefix ++ [(entry_id, entry_definition)]) next_seen).
      * rewrite Hall, <- app_assoc. reflexivity.
      * exact Hscan.
      * exact Hpreserved.
      * subst next_seen.
        now apply selector_seen_after_entry_covers_extended_prefix.
      * rewrite Htail. exact Hin.
Qed.

Lemma select_source_owned_definitions_sound :
  forall definitions selected,
    (forall id,
      PTree.get id selected =
      scan_global_definition id None definitions) ->
    (forall id definition,
      preserve_definition_verbatim (id, definition) = true ->
      In (id, definition) definitions ->
      PTree.get id selected = Some definition) ->
    forall id definition,
      In (id, definition)
        (fst (select_source_owned_definitions_from selected (PTree.empty _)
          definitions)) ->
      PTree.get id selected = Some definition.
Proof.
  intros definitions selected Hscan Hpreserved.
  eapply select_source_owned_definitions_from_sound
    with (all := definitions) (prefix := []).
  - reflexivity.
  - exact Hscan.
  - exact Hpreserved.
  - intros id selected_definition candidate Hselected Hin. contradiction.
Qed.

(** * Flattening the unitwise selector *)

Lemma select_source_owned_definitions_from_app :
  forall selected seen left right,
    select_source_owned_definitions_from selected seen (left ++ right) =
    let '(selected_left, next_seen) :=
      select_source_owned_definitions_from selected seen left in
    let '(selected_right, final_seen) :=
      select_source_owned_definitions_from selected next_seen right in
    (selected_left ++ selected_right, final_seen).
Proof.
  intros selected seen left. revert seen.
  induction left as [| entry rest IH]; intros seen right.
  - cbn [app select_source_owned_definitions_from].
    destruct (select_source_owned_definitions_from selected seen right).
    reflexivity.
  - cbn [app].
    rewrite ! select_source_owned_definitions_from_cons.
    set (next_seen := selector_seen_after_entry selected seen entry) in *.
    cbv zeta.
    rewrite (IH next_seen right).
    destruct (select_source_owned_definitions_from selected next_seen rest)
      as [selected_rest after_left] eqn:Hleft.
    destruct (select_source_owned_definitions_from selected after_left right)
      as [selected_right final_seen] eqn:Hright.
    destruct (selector_emits_entry selected seen entry); reflexivity.
Qed.

Lemma clean_translation_units_from_selection_fusion :
  forall selected normalized seen units,
    let '(cleaned, final_seen) :=
      clean_translation_units_from selected normalized seen units in
    (unit_global_definitions cleaned, final_seen) =
    select_source_owned_definitions_from selected seen
      (unit_global_definitions units).
Proof.
  intros selected normalized seen units. revert seen.
  induction units as [unit | unit rest IH]; intros seen.
  - cbn [clean_translation_units_from unit_global_definitions nlist_to_list].
    destruct (select_source_owned_definitions_from selected seen
      (prog_defs unit)) as [definitions final_seen] eqn:Hselected.
    unfold unit_global_definitions.
    cbn [nlist_to_list cleaned_translation_unit].
    cbn [map concat app cleaned_translation_unit].
    rewrite ! app_nil_r.
    cbn [cleaned_translation_unit].
    symmetry. exact Hselected.
  - cbn [clean_translation_units_from unit_global_definitions nlist_to_list].
    destruct (select_source_owned_definitions_from selected seen
      (prog_defs unit)) as [definitions next_seen] eqn:Hselected.
    destruct (clean_translation_units_from selected normalized next_seen rest)
      as [cleaned_rest final_seen] eqn:Hcleaned.
    change
      ((prog_defs (cleaned_translation_unit normalized unit definitions) ++
          unit_global_definitions cleaned_rest, final_seen) =
       select_source_owned_definitions_from selected seen
         (prog_defs unit ++ unit_global_definitions rest)).
    cbn [cleaned_translation_unit].
    rewrite select_source_owned_definitions_from_app, Hselected.
    pose proof (IH next_seen) as Hrest.
    rewrite Hcleaned in Hrest. cbn in Hrest.
    inversion Hrest. reflexivity.
Qed.

Lemma clean_translation_units_definition_selection :
  forall source normalized,
    unit_global_definitions (clean_translation_units source normalized) =
    fst (select_source_owned_definitions_from
      (normalize_global_definition_map (unit_global_definitions source))
      (PTree.empty _) (unit_global_definitions source)).
Proof.
  intros source normalized.
  unfold clean_translation_units.
  destruct (clean_translation_units_from
    (normalize_global_definition_map (unit_global_definitions source))
    normalized (PTree.empty _) source) as [cleaned final_seen] eqn:Hcleaned.
  pose proof (clean_translation_units_from_selection_fusion
    (normalize_global_definition_map (unit_global_definitions source))
    normalized (PTree.empty _) source) as Hfusion.
  rewrite Hcleaned in Hfusion. cbn in Hfusion.
  now inversion Hfusion.
Qed.

Lemma clean_translation_units_definition_is_exact_selection :
  forall source normalized,
    (forall id definition,
      preserve_definition_verbatim (id, definition) = true ->
      In (id, definition) (unit_global_definitions source) ->
      PTree.get id
        (normalize_global_definition_map (unit_global_definitions source)) =
      Some definition) ->
    forall id definition,
      In (id, definition)
        (unit_global_definitions
          (clean_translation_units source normalized)) ->
      PTree.get id
        (normalize_global_definition_map (unit_global_definitions source)) =
      Some definition.
Proof.
  intros source normalized Hpreserved id definition Hin.
  rewrite clean_translation_units_definition_selection in Hin.
  eapply select_source_owned_definitions_sound; [| | exact Hin].
  - apply normalized_global_definition_map_get_scan.
  - exact Hpreserved.
Qed.

(** This capstone composes the checked strong-declaration exactness theorem
    with selector soundness and the append/unit fusion lemmas above.  It stays
    abstract in the source unit list: concrete US and JP instantiation remains
    open and must not be inferred from this theorem. *)
Theorem generic_checked_cleaned_definition_exactness_capstone :
  forall source normalized,
    identifiers_unique
      (internal_identifiers (unit_global_definitions source)) = true ->
    identifiers_unique
      (definitive_variable_identifiers
        (unit_global_definitions source)) = true ->
    all_internal_identifiers_selected
      (unit_global_definitions source)
      (normalize_global_definition_map
        (unit_global_definitions source)) = true ->
    all_definitive_identifiers_selected
      (unit_global_definitions source)
      (normalize_global_definition_map
        (unit_global_definitions source)) = true ->
    forall id definition,
      In (id, definition)
        (unit_global_definitions
          (clean_translation_units source normalized)) ->
      PTree.get id
        (normalize_global_definition_map
          (unit_global_definitions source)) = Some definition.
Proof.
  intros source normalized Hinternal_unique Hdefinitive_unique
    Hinternal_selected Hdefinitive_selected id definition Hin.
  eapply clean_translation_units_definition_is_exact_selection.
  - eapply checked_preserved_selection_is_exact.
    + exact Hinternal_unique.
    + exact Hdefinitive_unique.
    + exact Hinternal_selected.
    + exact Hdefinitive_selected.
    + apply normalized_definition_map_has_source_provenance.
  - exact Hin.
Qed.
