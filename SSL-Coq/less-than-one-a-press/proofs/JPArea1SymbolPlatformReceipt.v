(** Focused JP [platform_displacement] receipt for the Area-1 boundary. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms.

Definition jp_platform_displacement_source_unit : Clight.program :=
  nlist_at 29%nat jp_units.

Theorem jp_platform_displacement_source_unit_public_name_checked :
  In jp_platform_displacement._gMarioPlatform
    (prog_public jp_platform_displacement_source_unit).
Proof.
  vm_compute.
  tauto.
Qed.

Lemma cleaned_public_identifiers_have_definition_names :
  forall normalized source cleaned,
    nlist_forall2
      (CleanedUnitOwnsGlobalsAndUsesNormalizedHeader normalized)
      source cleaned ->
    incl (unit_public_idents cleaned)
      (global_identifiers (unit_global_definitions cleaned)).
Proof.
  intros normalized source cleaned Hownership.
  induction Hownership; cbn.
  - rewrite !app_nil_r. exact (proj1 (proj2 (proj2 H))).
  - unfold global_identifiers in *.
    rewrite map_app. intros id Hin. apply in_app_or in Hin.
    apply in_or_app. destruct Hin as [Hin | Hin].
    + left. exact (proj1 (proj2 (proj2 H)) id Hin).
    + right. exact (IHHownership id Hin).
Qed.

Lemma global_identifier_has_definition :
  forall definitions id,
    In id (global_identifiers definitions) ->
    exists definition, In (id, definition) definitions.
Proof.
  intros definitions id Hin.
  unfold global_identifiers in Hin.
  apply in_map_iff in Hin.
  destruct Hin as [[definition_id definition] [Hid Hdefinition]].
  cbn in Hid. subst definition_id. now exists definition.
Qed.

Lemma aggregate_definition_has_linked_symbol :
  forall units linked id definition,
    In (id, definition) (unit_global_definitions units) ->
    link_list units = Some linked ->
    exists block,
      Genv.find_symbol (Clight.globalenv linked) id = Some block.
Proof.
  intros units linked id definition Hdefinition Hlink.
  destruct (unit_global_definition_has_owner units id definition Hdefinition)
    as [unit [Hunit Hunit_definition]].
  assert (Hunit_symbol : exists source_block,
    Genv.find_symbol (Clight.globalenv unit) id = Some source_block).
  { eapply Genv.find_symbol_exists. exact Hunit_definition. }
  destruct Hunit_symbol as [source_block Hsource_symbol].
  eapply (official_link_preserves_symbol_domain units linked Hlink); eauto.
Qed.

Theorem jp_official_area1_platform_pointer_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_platform_displacement._gMarioPlatform = Some block.
Proof.
  assert (Hsource_union_public :
    In jp_platform_displacement._gMarioPlatform
      (unit_public_idents jp_units)).
  { unfold unit_public_idents. apply in_concat.
    exists (prog_public jp_platform_displacement_source_unit). split.
    - apply in_map. apply nIn_to_nlist_to_list_membership.
      unfold jp_platform_displacement_source_unit. apply nlist_at_nIn.
    - exact jp_platform_displacement_source_unit_public_name_checked. }
  pose proof
    (jp_cleaned_public_identifier_coverage
      jp_platform_displacement._gMarioPlatform Hsource_union_public)
    as Hcleaned_union_public.
  pose proof (cleaned_public_identifiers_have_definition_names
    jp_normalized_semantic_slice jp_units jp_cleaned_units
    jp_cleaned_units_pointwise_ownership
    jp_platform_displacement._gMarioPlatform Hcleaned_union_public) as Hname.
  destruct (global_identifier_has_definition
    (unit_global_definitions jp_cleaned_units)
    jp_platform_displacement._gMarioPlatform Hname) as
    [definition Hdefinition].
  eapply aggregate_definition_has_linked_symbol.
  - exact Hdefinition.
  - exact jp_cleaned_units_official_link.
Qed.
