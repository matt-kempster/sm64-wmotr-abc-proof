(** Official-link syntax closure for the five platform-lineage residuals.

    [PlatformPointerProvenance] computes the complete source-union writer,
    address-taken, and caller censuses for [gMarioPlatform].  This file lifts
    those upper bounds to the constructed US and JP official cleaned linked
    Clight slices.  The companion [JPLinkedPlatformGlobal] module connects the
    exact JP updater fragment to local Clight steps.

    The upper bounds eliminate an extra recognized direct internal writer as
    an explanation of any of the five residuals.  They do not classify the
    live owner returned by [find_floor], prove pool-slot/ghost-epoch provenance,
    frame aliases or
    unresolved external calls, or prove that the previous query sample equals
    the next collision sample.  Consequently no theorem below claims that a
    clean reachable retail execution eliminates all five cases. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_object_list_processor us_platform_displacement
  jp_object_list_processor jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PlatformExhaustiveness CleanedClightPrograms GameTypes
  ClightLinkExecution LinkedClightPrograms NormalizedClightPrograms
  PlatformPointerProvenance StateFirstPlatformChronology
  StockProjectionExhaustiveness.

Import ListNotations.

Module LPLS_USObjects := us_object_list_processor.
Module LPLS_USPlatform := us_platform_displacement.
Module LPLS_JPObjects := jp_object_list_processor.
Module LPLS_JPPlatform := jp_platform_displacement.

(** Upper bounds for every direct internal writer in the official programs.
    This is an actual linked-[prog_defs] theorem.  It is deliberately not an
    alias-store theorem: a store through an unrelated pointer has no
    [Evar gMarioPlatform] lvalue for this census to recognize. *)
Theorem official_us_direct_platform_writer_is_known :
  forall id body,
    In (id, Gfun (Internal body))
      us_official_cleaned_slice.(prog_defs) ->
    statement_assigns_ident_s LPLS_USPlatform._gMarioPlatform
      (fn_body body) = true ->
    id = LPLS_USPlatform._update_mario_platform \/
    id = LPLS_USPlatform._clear_mario_platform.
Proof.
  intros id body Hofficial Hassign.
  pose proof
    (us_official_source_definition_provenance
      id (Gfun (Internal body)) Hofficial) as Hsource.
  clear Hofficial.
  pose proof
    (internal_function_assignment_sites_complete
      LPLS_USPlatform._gMarioPlatform
      (unit_global_definitions us_units) id body Hsource Hassign) as Hsite.
  clear Hsource Hassign.
  rewrite us_platform_global_direct_writer_census in Hsite.
  cbn in Hsite.
  destruct Hsite as [Hupdate | [Hclear | Hnone]].
  - left. symmetry. exact Hupdate.
  - right. symmetry. exact Hclear.
  - contradiction.
Qed.

Theorem official_jp_direct_platform_writer_is_update :
  forall id body,
    In (id, Gfun (Internal body))
      jp_official_cleaned_slice.(prog_defs) ->
    statement_assigns_ident_s LPLS_JPPlatform._gMarioPlatform
      (fn_body body) = true ->
    id = LPLS_JPPlatform._update_mario_platform.
Proof.
  intros id body Hofficial Hassign.
  pose proof
    (jp_official_source_definition_provenance
      id (Gfun (Internal body)) Hofficial) as Hsource.
  clear Hofficial.
  pose proof
    (internal_function_assignment_sites_complete
      LPLS_JPPlatform._gMarioPlatform
      (unit_global_definitions jp_units) id body Hsource Hassign) as Hsite.
  clear Hsource Hassign.
  rewrite jp_platform_global_direct_writer_census in Hsite.
  cbn in Hsite.
  destruct Hsite as [Hupdate | Hnone].
  - symmetry. exact Hupdate.
  - contradiction.
Qed.

Theorem official_links_have_no_direct_platform_cell_address_site :
  (forall id body,
    In (id, Gfun (Internal body))
      us_official_cleaned_slice.(prog_defs) ->
    statement_takes_address_of_ident_s
      LPLS_USPlatform._gMarioPlatform (fn_body body) = false) /\
  (forall id body,
    In (id, Gfun (Internal body))
      jp_official_cleaned_slice.(prog_defs) ->
    statement_takes_address_of_ident_s
      LPLS_JPPlatform._gMarioPlatform (fn_body body) = false).
Proof.
  split; intros id body Hofficial.
  - destruct (statement_takes_address_of_ident_s
      LPLS_USPlatform._gMarioPlatform (fn_body body)) eqn:Haddress;
      [| reflexivity].
    exfalso.
    pose proof
      (us_official_source_definition_provenance
        id (Gfun (Internal body)) Hofficial) as Hsource.
    clear Hofficial.
    pose proof
      (internal_function_address_sites_complete
        LPLS_USPlatform._gMarioPlatform
        (unit_global_definitions us_units) id body Hsource Haddress) as Hsite.
    clear Hsource Haddress.
    rewrite us_platform_global_address_site_census in Hsite.
    contradiction.
  - destruct (statement_takes_address_of_ident_s
      LPLS_JPPlatform._gMarioPlatform (fn_body body)) eqn:Haddress;
      [| reflexivity].
    exfalso.
    pose proof
      (jp_official_source_definition_provenance
        id (Gfun (Internal body)) Hofficial) as Hsource.
    clear Hofficial.
    pose proof
      (internal_function_address_sites_complete
        LPLS_JPPlatform._gMarioPlatform
        (unit_global_definitions jp_units) id body Hsource Haddress) as Hsite.
    clear Hsource Haddress.
    rewrite jp_platform_global_address_site_census in Hsite.
    contradiction.
Qed.

(** The only direct caller of the updater in either official linked program
    is [update_objects].  Cross-unit declarations cannot appear here because
    this theorem quantifies only over retained [Internal] bodies. *)
Theorem official_platform_update_direct_caller_is_update_objects :
  (forall id body,
    In (id, Gfun (Internal body))
      us_official_cleaned_slice.(prog_defs) ->
    calls_ident_s LPLS_USPlatform._update_mario_platform
      (fn_body body) = true ->
    id = LPLS_USObjects._update_objects) /\
  (forall id body,
    In (id, Gfun (Internal body))
      jp_official_cleaned_slice.(prog_defs) ->
    calls_ident_s LPLS_JPPlatform._update_mario_platform
      (fn_body body) = true ->
    id = LPLS_JPObjects._update_objects).
Proof.
  split; intros id body Hofficial Hcall.
  - pose proof
      (us_official_source_definition_provenance
        id (Gfun (Internal body)) Hofficial) as Hsource.
    clear Hofficial.
    pose proof
      (internal_function_direct_call_sites_complete
        LPLS_USPlatform._update_mario_platform
        (unit_global_definitions us_units) id body Hsource Hcall) as Hsite.
    clear Hsource Hcall.
    rewrite (proj1 us_platform_writer_direct_caller_census) in Hsite.
    cbn in Hsite.
    destruct Hsite as [Hcaller | Hnone].
    + symmetry. exact Hcaller.
    + contradiction.
  - pose proof
      (jp_official_source_definition_provenance
        id (Gfun (Internal body)) Hofficial) as Hsource.
    clear Hofficial.
    pose proof
      (internal_function_direct_call_sites_complete
        LPLS_JPPlatform._update_mario_platform
        (unit_global_definitions jp_units) id body Hsource Hcall) as Hsite.
    clear Hsource Hcall.
    rewrite (proj1 jp_platform_writer_direct_caller_census) in Hsite.
    cbn in Hsite.
    destruct Hsite as [Hcaller | Hnone].
    + symmetry. exact Hcaller.
    + contradiction.
Qed.

(** Five separate linked premises close the five residuals.  Stating them
    separately documents the exact semantic work left by the official syntax
    results above: current-sample stability; live geometry; raw identity and
    epoch; owner classification; and absence of transported JP lineage. *)
Record FiveLinkedLineageClosures
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (projection : UpperWarpPrecollisionApplyProjection) : Prop := {
  linked_query_sample_is_current :
    forall source owner skipped,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      source = projected_collision_position projection;
  linked_owner_is_classified :
    forall source owner skipped,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      exists kind, observed_owner_kind owner = Some kind;
  linked_owner_identity_is_canonical :
    forall source owner skipped kind,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      observed_owner_kind owner = Some kind ->
      observed_owner_ref owner = canonical_ref kind;
  linked_owner_geometry_is_modeled :
    forall source owner skipped kind,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      observed_owner_kind owner = Some kind ->
      stock_area1_dynamic_floor_candidate kind
        (observed_owner_query_position owner)
        (observed_owner_floor_y owner);
  linked_no_retained_jp_transport :
    forall node owner skipped,
      projected_final_lineage projection =
        PlatformLineageJPInbound node owner skipped ->
      False
}.

Theorem five_linked_lineage_closures_rule_out_installer :
  forall canonical_ref projection,
    FiveLinkedLineageClosures canonical_ref projection ->
    False.
Proof.
  intros canonical_ref projection Hclosures.
  eapply stock_closed_projection_rules_out_state_first_platform_apply.
  - intros source owner skipped Hlineage.
    split.
    + exact (linked_query_sample_is_current
        canonical_ref projection Hclosures source owner skipped Hlineage).
    + destruct (linked_owner_is_classified
        canonical_ref projection Hclosures source owner skipped Hlineage)
        as [kind Hkind].
      exists kind. split; [exact Hkind |]. split.
      * exact (linked_owner_identity_is_canonical
          canonical_ref projection Hclosures source owner skipped kind
          Hlineage Hkind).
      * exact (linked_owner_geometry_is_modeled
          canonical_ref projection Hclosures source owner skipped kind
          Hlineage Hkind).
  - exact (linked_no_retained_jp_transport
      canonical_ref projection Hclosures).
Qed.

(** Once a supplied pre-apply projection uses the null platform seed decoded
    from the scoped default Area 1 boundary, retained JP inbound lineage is no
    longer an independent closure premise.  Deriving that projection's events
    from a linked run is separate.  The four remaining fields say only what a
    completed live query must project to: the current sample, a classified
    owner, canonical identity, and modeled stock geometry. *)
Record FourNullSeedLinkedLineageClosures
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (projection : UpperWarpPrecollisionApplyProjection) : Prop := {
  null_seed_query_sample_is_current :
    forall source owner skipped,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      source = projected_collision_position projection;
  null_seed_owner_is_classified :
    forall source owner skipped,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      exists kind, observed_owner_kind owner = Some kind;
  null_seed_owner_identity_is_canonical :
    forall source owner skipped kind,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      observed_owner_kind owner = Some kind ->
      observed_owner_ref owner = canonical_ref kind;
  null_seed_owner_geometry_is_modeled :
    forall source owner skipped kind,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      observed_owner_kind owner = Some kind ->
      stock_area1_dynamic_floor_candidate kind
        (observed_owner_query_position owner)
        (observed_owner_floor_y owner)
}.

(** Stronger compact interface: callers may package the preceding four
    fields into this one completed-query fact.  The seed equality is concrete
    chronology input, not the desired no-installer conclusion. *)
Theorem null_seed_completed_query_closure_rules_out_installer :
  forall canonical_ref projection,
    projected_jp_inbound_seed projection = None ->
    (forall source owner skipped,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      source = projected_collision_position projection /\
      CanonicalModeledCandidateObservation canonical_ref owner) ->
    False.
Proof.
  intros canonical_ref projection Hnull Hquery.
  eapply stock_closed_projection_rules_out_state_first_platform_apply.
  - exact Hquery.
  - intros node owner skipped Hinbound.
    unfold projected_final_lineage in Hinbound.
    rewrite Hnull in Hinbound.
    destruct (projected_platform_version projection);
      eapply null_seed_chronology_cannot_produce_jp_inbound;
      exact Hinbound.
Qed.

Theorem four_null_seed_linked_lineage_closures_rule_out_installer :
  forall canonical_ref projection,
    projected_jp_inbound_seed projection = None ->
    FourNullSeedLinkedLineageClosures canonical_ref projection ->
    False.
Proof.
  intros canonical_ref projection Hnull Hclosures.
  eapply null_seed_completed_query_closure_rules_out_installer;
    [exact Hnull |].
  intros source owner skipped Hlineage.
  split.
  - exact (null_seed_query_sample_is_current
      canonical_ref projection Hclosures source owner skipped Hlineage).
  - destruct (null_seed_owner_is_classified
      canonical_ref projection Hclosures source owner skipped Hlineage)
      as [kind Hkind].
    exists kind. split; [exact Hkind |]. split.
    + exact (null_seed_owner_identity_is_canonical
        canonical_ref projection Hclosures source owner skipped kind
        Hlineage Hkind).
    + exact (null_seed_owner_geometry_is_modeled
        canonical_ref projection Hclosures source owner skipped kind
        Hlineage Hkind).
Qed.

(** Admission-free checked boundary.  The preceding conjuncts are concrete
    official-link results.  The final implication is not an assertion that a
    clean run inhabits [FiveLinkedLineageClosures]; it only checks that those
    five non-circular linked facts would close the existing residual split. *)
Definition LinkedPlatformLineageSyntaxCheckedBoundary : Prop :=
  (forall id body,
    In (id, Gfun (Internal body))
      us_official_cleaned_slice.(prog_defs) ->
    statement_assigns_ident_s LPLS_USPlatform._gMarioPlatform
      (fn_body body) = true ->
    id = LPLS_USPlatform._update_mario_platform \/
    id = LPLS_USPlatform._clear_mario_platform) /\
  (forall id body,
    In (id, Gfun (Internal body))
      jp_official_cleaned_slice.(prog_defs) ->
    statement_assigns_ident_s LPLS_JPPlatform._gMarioPlatform
      (fn_body body) = true ->
    id = LPLS_JPPlatform._update_mario_platform) /\
  ((forall id body,
      In (id, Gfun (Internal body))
        us_official_cleaned_slice.(prog_defs) ->
      statement_takes_address_of_ident_s
        LPLS_USPlatform._gMarioPlatform (fn_body body) = false) /\
   (forall id body,
      In (id, Gfun (Internal body))
        jp_official_cleaned_slice.(prog_defs) ->
      statement_takes_address_of_ident_s
        LPLS_JPPlatform._gMarioPlatform (fn_body body) = false)) /\
  ((forall id body,
      In (id, Gfun (Internal body))
        us_official_cleaned_slice.(prog_defs) ->
      calls_ident_s LPLS_USPlatform._update_mario_platform
        (fn_body body) = true ->
      id = LPLS_USObjects._update_objects) /\
   (forall id body,
      In (id, Gfun (Internal body))
        jp_official_cleaned_slice.(prog_defs) ->
      calls_ident_s LPLS_JPPlatform._update_mario_platform
        (fn_body body) = true ->
      id = LPLS_JPObjects._update_objects)) /\
  (forall canonical_ref projection,
    FiveLinkedLineageClosures canonical_ref projection -> False).

Theorem linked_platform_lineage_syntax_checked_boundary_holds :
  LinkedPlatformLineageSyntaxCheckedBoundary.
Proof.
  unfold LinkedPlatformLineageSyntaxCheckedBoundary.
  split; [exact official_us_direct_platform_writer_is_known |].
  split; [exact official_jp_direct_platform_writer_is_update |].
  split; [exact official_links_have_no_direct_platform_cell_address_site |].
  split; [exact official_platform_update_direct_caller_is_update_objects |].
  exact five_linked_lineage_closures_rule_out_installer.
Qed.
