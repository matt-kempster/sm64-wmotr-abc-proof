(** Source-complete and official-link provenance for [gMarioPlatform].

    Ink's candidate needs a non-null platform pointer at the beginning of an
    Area-1 object-update frame.  The finite stock-owner model is useful only
    after proving that retail execution cannot install the pointer through an
    unclassified writer.  This file closes the direct Clight syntax part of
    that question over all 38 translated units and packages it with the
    one-way source-definition provenance needed for a future official-link
    direct-syntax upper bound.  It does not itself prove an exact official
    target writer/caller census.

    The results do not yet exclude a store through a fabricated or pre-existing
    alias, nor an [EF_external] which writes the global block.  Those are the
    remaining memory-safety/frame obligations, stated explicitly below. *)

From Coq Require Import List PArith.BinPos.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_object_list_processor us_platform_displacement
  jp_object_list_processor jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  ASTFacts LinkedClightPrograms NormalizedClightPrograms
  CleanedClightPrograms ClightLinkExecution.

Import ListNotations.

Module PPP_USObjects := us_object_list_processor.
Module PPP_USPlatform := us_platform_displacement.
Module PPP_JPObjects := jp_object_list_processor.
Module PPP_JPPlatform := jp_platform_displacement.

Definition rhs_is_temp_or_null_pointer
    (source_temp : ident) (rhs : expr) : bool :=
  match rhs with
  | Etempvar found _ => Pos.eqb found source_temp
  | _ => rhs_is_null_pointer rhs
  end.

(** Universal, rather than existential, recognizers for the two pieces of the
    generated dataflow.  Every assignment to the selected global must be null
    or the chosen temporary, and every assignment to that temporary must load
    the selected struct field. *)
Fixpoint all_global_assignments_from_temp_or_null_s
    (global source_temp : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      if lhs_global_is global lhs
      then rhs_is_temp_or_null_pointer source_temp rhs
      else true
  | Ssequence a b | Sloop a b =>
      all_global_assignments_from_temp_or_null_s global source_temp a &&
      all_global_assignments_from_temp_or_null_s global source_temp b
  | Sifthenelse _ a b =>
      all_global_assignments_from_temp_or_null_s global source_temp a &&
      all_global_assignments_from_temp_or_null_s global source_temp b
  | Sswitch _ cases =>
      all_global_assignments_from_temp_or_null_ls
        global source_temp cases
  | Slabel _ body =>
      all_global_assignments_from_temp_or_null_s global source_temp body
  | _ => true
  end
with all_global_assignments_from_temp_or_null_ls
    (global source_temp : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      all_global_assignments_from_temp_or_null_s
        global source_temp body &&
      all_global_assignments_from_temp_or_null_ls
        global source_temp rest
  end.

Fixpoint all_temp_sets_from_struct_field_s
    (target_temp struct_tag field : ident) (s : statement) : bool :=
  match s with
  | Sset found rhs =>
      if Pos.eqb found target_temp
      then rhs_is_struct_field_read struct_tag field rhs
      else true
  | Ssequence a b | Sloop a b =>
      all_temp_sets_from_struct_field_s target_temp struct_tag field a &&
      all_temp_sets_from_struct_field_s target_temp struct_tag field b
  | Sifthenelse _ a b =>
      all_temp_sets_from_struct_field_s target_temp struct_tag field a &&
      all_temp_sets_from_struct_field_s target_temp struct_tag field b
  | Sswitch _ cases =>
      all_temp_sets_from_struct_field_ls target_temp struct_tag field cases
  | Slabel _ body =>
      all_temp_sets_from_struct_field_s target_temp struct_tag field body
  | _ => true
  end
with all_temp_sets_from_struct_field_ls
    (target_temp struct_tag field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      all_temp_sets_from_struct_field_s
        target_temp struct_tag field body &&
      all_temp_sets_from_struct_field_ls
        target_temp struct_tag field rest
  end.

(** Enumerate internal functions containing a direct call to one identifier.
    Like the assignment recognizer in [ASTFacts], this is a syntax census and
    deliberately says nothing about reachability of the call site. *)
Fixpoint internal_function_direct_call_sites
    (callee : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if calls_ident_s callee (fn_body body)
      then id :: internal_function_direct_call_sites callee rest
      else internal_function_direct_call_sites callee rest
  | _ :: rest => internal_function_direct_call_sites callee rest
  end.

Lemma internal_function_assignment_sites_complete :
  forall target definitions id body,
    In (id, Gfun (Internal body)) definitions ->
    statement_assigns_ident_s target (fn_body body) = true ->
    In id (internal_function_assignment_sites target definitions).
Proof.
  intros target definitions.
  induction definitions as [| [head_id head_definition] rest IH];
    intros id body Hin Hassign; cbn in Hin; [contradiction |].
  destruct Hin as [Heq | Hin].
  - inversion Heq; subst head_id head_definition.
    cbn. rewrite Hassign. now left.
  - destruct head_definition as [function_definition | variable].
    + destruct function_definition as [internal | external args result cc].
      * cbn.
        destruct (statement_assigns_ident_s target (fn_body internal));
          [right |]; now apply IH with (body := body).
      * cbn. now apply IH with (body := body).
    + cbn. now apply IH with (body := body).
Qed.

Lemma internal_function_address_sites_complete :
  forall target definitions id body,
    In (id, Gfun (Internal body)) definitions ->
    statement_takes_address_of_ident_s target (fn_body body) = true ->
    In id (internal_function_address_sites target definitions).
Proof.
  intros target definitions.
  induction definitions as [| [head_id head_definition] rest IH];
    intros id body Hin Haddress; cbn in Hin; [contradiction |].
  destruct Hin as [Heq | Hin].
  - inversion Heq; subst head_id head_definition.
    cbn. rewrite Haddress. now left.
  - destruct head_definition as [function_definition | variable].
    + destruct function_definition as [internal | external args result cc].
      * cbn.
        destruct (statement_takes_address_of_ident_s
                    target (fn_body internal));
          [right |]; now apply IH with (body := body).
      * cbn. now apply IH with (body := body).
    + cbn. now apply IH with (body := body).
Qed.

Lemma internal_function_direct_call_sites_complete :
  forall callee definitions id body,
    In (id, Gfun (Internal body)) definitions ->
    calls_ident_s callee (fn_body body) = true ->
    In id (internal_function_direct_call_sites callee definitions).
Proof.
  intros callee definitions.
  induction definitions as [| [head_id head_definition] rest IH];
    intros id body Hin Hcall; cbn in Hin; [contradiction |].
  destruct Hin as [Heq | Hin].
  - inversion Heq; subst head_id head_definition.
    cbn. rewrite Hcall. now left.
  - destruct head_definition as [function_definition | variable].
    + destruct function_definition as [internal | external args result cc].
      * cbn.
        destruct (calls_ident_s callee (fn_body internal));
          [right |]; now apply IH with (body := body).
      * cbn. now apply IH with (body := body).
    + cbn. now apply IH with (body := body).
Qed.

(** Evaluate each complete 38-unit source union once.  Keeping the five
    inventories in one closed proposition avoids rescanning the very large
    generated AST for every projected theorem below. *)
Definition USPlatformPointerSourceUnionCensus : Prop :=
  internal_function_assignment_sites
    PPP_USPlatform._gMarioPlatform
    (unit_global_definitions us_units) =
      [PPP_USPlatform._update_mario_platform;
       PPP_USPlatform._clear_mario_platform] /\
  internal_function_address_sites
    PPP_USPlatform._gMarioPlatform
    (unit_global_definitions us_units) = [] /\
  internal_function_direct_call_sites
    PPP_USPlatform._update_mario_platform
    (unit_global_definitions us_units) =
      [PPP_USObjects._update_objects] /\
  internal_function_direct_call_sites
    PPP_USPlatform._clear_mario_platform
    (unit_global_definitions us_units) =
      [PPP_USObjects._spawn_objects_from_info] /\
  existsb (Pos.eqb PPP_USPlatform._gMarioPlatform)
    (source_union_init_addrof_identifiers us_units) = false.

Definition JPPlatformPointerSourceUnionCensus : Prop :=
  internal_function_assignment_sites
    PPP_JPPlatform._gMarioPlatform
    (unit_global_definitions jp_units) =
      [PPP_JPPlatform._update_mario_platform] /\
  internal_function_address_sites
    PPP_JPPlatform._gMarioPlatform
    (unit_global_definitions jp_units) = [] /\
  internal_function_direct_call_sites
    PPP_JPPlatform._update_mario_platform
    (unit_global_definitions jp_units) =
      [PPP_JPObjects._update_objects] /\
  internal_function_direct_call_sites
    PPP_USPlatform._clear_mario_platform
    (unit_global_definitions jp_units) = [] /\
  existsb (Pos.eqb PPP_JPPlatform._gMarioPlatform)
    (source_union_init_addrof_identifiers jp_units) = false.

Theorem us_platform_pointer_source_union_census_checked :
  USPlatformPointerSourceUnionCensus.
Proof.
  unfold USPlatformPointerSourceUnionCensus.
  vm_compute. repeat split; reflexivity.
Qed.

Theorem jp_platform_pointer_source_union_census_checked :
  JPPlatformPointerSourceUnionCensus.
Proof.
  unfold JPPlatformPointerSourceUnionCensus.
  vm_compute. repeat split; reflexivity.
Qed.

Lemma ident_existsb_false_not_in :
  forall needle identifiers,
    existsb (Pos.eqb needle) identifiers = false ->
    ~ In needle identifiers.
Proof.
  intros needle identifiers Hnone Hin.
  assert (Hexists : existsb (Pos.eqb needle) identifiers = true).
  { apply existsb_exists.
    exists needle. split; [exact Hin | apply Pos.eqb_refl]. }
  rewrite Hnone in Hexists. discriminate.
Qed.

(** Across the complete generated source unions, these are the only direct
    assignments to the platform global.  US has the explicit spawn clear;
    JP has only the final floor-query recomputation. *)
Theorem us_platform_global_direct_writer_census :
  internal_function_assignment_sites
    PPP_USPlatform._gMarioPlatform
    (unit_global_definitions us_units) =
  [PPP_USPlatform._update_mario_platform;
   PPP_USPlatform._clear_mario_platform].
Proof.
  exact (proj1 us_platform_pointer_source_union_census_checked).
Qed.

Theorem jp_platform_global_direct_writer_census :
  internal_function_assignment_sites
    PPP_JPPlatform._gMarioPlatform
    (unit_global_definitions jp_units) =
  [PPP_JPPlatform._update_mario_platform].
Proof.
  exact (proj1 jp_platform_pointer_source_union_census_checked).
Qed.

(** In both versions every non-null store in the one update body comes from
    temporary [_t'9], and every write to [_t'9] is a read of
    [Surface.object].  The update also calls [find_floor].  This is the exact
    source-level chain; preserving the value through the intervening Clight
    steps and identifying [_floor] with the call result remain semantic. *)
Definition USPlatformUpdateValueFlowSourceShape : Prop :=
  calls_ident_s PPP_USPlatform._find_floor
    (fn_body PPP_USPlatform.f_update_mario_platform) = true /\
  all_global_assignments_from_temp_or_null_s
    PPP_USPlatform._gMarioPlatform PPP_USPlatform._t'9
    (fn_body PPP_USPlatform.f_update_mario_platform) = true /\
  all_temp_sets_from_struct_field_s
    PPP_USPlatform._t'9 PPP_USPlatform._Surface PPP_USPlatform._object
    (fn_body PPP_USPlatform.f_update_mario_platform) = true.

Definition JPPlatformUpdateValueFlowSourceShape : Prop :=
  calls_ident_s PPP_JPPlatform._find_floor
    (fn_body PPP_JPPlatform.f_update_mario_platform) = true /\
  all_global_assignments_from_temp_or_null_s
    PPP_JPPlatform._gMarioPlatform PPP_JPPlatform._t'9
    (fn_body PPP_JPPlatform.f_update_mario_platform) = true /\
  all_temp_sets_from_struct_field_s
    PPP_JPPlatform._t'9 PPP_JPPlatform._Surface PPP_JPPlatform._object
    (fn_body PPP_JPPlatform.f_update_mario_platform) = true.

Theorem us_platform_update_value_flow_source_shape_checked :
  USPlatformUpdateValueFlowSourceShape.
Proof. unfold USPlatformUpdateValueFlowSourceShape; vm_compute; tauto. Qed.

Theorem jp_platform_update_value_flow_source_shape_checked :
  JPPlatformUpdateValueFlowSourceShape.
Proof. unfold JPPlatformUpdateValueFlowSourceShape; vm_compute; tauto. Qed.

Theorem us_platform_clear_only_writes_null_source_shape :
  all_global_assignments_from_temp_or_null_s
    PPP_USPlatform._gMarioPlatform PPP_USPlatform._t'9
    (fn_body PPP_USPlatform.f_clear_mario_platform) = true /\
  assigns_ident_from_temp_s
    PPP_USPlatform._gMarioPlatform PPP_USPlatform._t'9
    (fn_body PPP_USPlatform.f_clear_mario_platform) = false.
Proof. vm_compute. split; reflexivity. Qed.

(** No translated internal body explicitly takes the address of the global
    cell.  Consequently ordinary source-level pointer flow cannot hand that
    address to a helper or external call.  Integer-to-pointer fabrication,
    undefined out-of-bounds writes, and aliases already present in memory are
    semantic questions and are not discharged by this syntax fact. *)
Theorem us_platform_global_address_site_census :
  internal_function_address_sites
    PPP_USPlatform._gMarioPlatform
    (unit_global_definitions us_units) = [].
Proof.
  exact (proj1 (proj2 us_platform_pointer_source_union_census_checked)).
Qed.

Theorem jp_platform_global_address_site_census :
  internal_function_address_sites
    PPP_JPPlatform._gMarioPlatform
    (unit_global_definitions jp_units) = [].
Proof.
  exact (proj1 (proj2 jp_platform_pointer_source_union_census_checked)).
Qed.

(** No static initializer in either complete generated source union contains
    a relocation to the [gMarioPlatform] cell.  Combined with the no-address
    census, this rules out the two ordinary source mechanisms for creating a
    pointer to that cell before execution starts or while an internal body
    runs. *)
Theorem us_platform_global_initializer_relocation_absent :
  ~ In PPP_USPlatform._gMarioPlatform
      (source_union_init_addrof_identifiers us_units).
Proof.
  apply ident_existsb_false_not_in.
  exact (proj2 (proj2 (proj2 (proj2
    us_platform_pointer_source_union_census_checked)))).
Qed.

Theorem jp_platform_global_initializer_relocation_absent :
  ~ In PPP_JPPlatform._gMarioPlatform
      (source_union_init_addrof_identifiers jp_units).
Proof.
  apply ident_existsb_false_not_in.
  exact (proj2 (proj2 (proj2 (proj2
    jp_platform_pointer_source_union_census_checked)))).
Qed.

(** The call graph is equally small: the normal updater is called only from
    [update_objects], and the US-only clear is called only while spawning the
    area's objects. *)
Theorem us_platform_writer_direct_caller_census :
  internal_function_direct_call_sites
    PPP_USPlatform._update_mario_platform
    (unit_global_definitions us_units) =
      [PPP_USObjects._update_objects] /\
  internal_function_direct_call_sites
    PPP_USPlatform._clear_mario_platform
    (unit_global_definitions us_units) =
      [PPP_USObjects._spawn_objects_from_info].
Proof.
  split.
  - exact (proj1 (proj2 (proj2
      us_platform_pointer_source_union_census_checked))).
  - exact (proj1 (proj2 (proj2 (proj2
      us_platform_pointer_source_union_census_checked)))).
Qed.

Theorem jp_platform_writer_direct_caller_census :
  internal_function_direct_call_sites
    PPP_JPPlatform._update_mario_platform
    (unit_global_definitions jp_units) =
      [PPP_JPObjects._update_objects] /\
  internal_function_direct_call_sites
    PPP_USPlatform._clear_mario_platform
    (unit_global_definitions jp_units) = [].
Proof.
  split.
  - exact (proj1 (proj2 (proj2
      jp_platform_pointer_source_union_census_checked))).
  - exact (proj1 (proj2 (proj2 (proj2
      jp_platform_pointer_source_union_census_checked)))).
Qed.

Theorem us_official_initializer_has_no_platform_global_relocation :
  ~ In PPP_USPlatform._gMarioPlatform
      (program_init_addrof_identifiers us_official_cleaned_slice).
Proof.
  intros Hofficial.
  apply us_platform_global_initializer_relocation_absent.
  eapply official_definition_provenance_transfers_init_addrof_occurrence.
  - exact us_official_source_definition_provenance.
  - exact Hofficial.
Qed.

Theorem jp_official_initializer_has_no_platform_global_relocation :
  ~ In PPP_JPPlatform._gMarioPlatform
      (program_init_addrof_identifiers jp_official_cleaned_slice).
Proof.
  intros Hofficial.
  apply jp_platform_global_initializer_relocation_absent.
  eapply official_definition_provenance_transfers_init_addrof_occurrence.
  - exact jp_official_source_definition_provenance.
  - exact Hofficial.
Qed.

(** Definition provenance of the official links and the generic completeness
    lemmas above are ingredients for a future direct-syntax upper bound on
    linked bodies.  We package those ingredients without claiming an exact
    official-target writer/caller census or repeatedly reducing the very large
    official [prog_defs] terms during compilation. *)
Definition OfficialPlatformPointerSyntaxBoundary : Prop :=
  OfficialSourceDefinitionProvenance
    us_units us_official_cleaned_slice /\
  OfficialSourceDefinitionProvenance
    jp_units jp_official_cleaned_slice /\
  USPlatformPointerSourceUnionCensus /\
  JPPlatformPointerSourceUnionCensus /\
  USPlatformUpdateValueFlowSourceShape /\
  JPPlatformUpdateValueFlowSourceShape /\
  (all_global_assignments_from_temp_or_null_s
      PPP_USPlatform._gMarioPlatform PPP_USPlatform._t'9
      (fn_body PPP_USPlatform.f_clear_mario_platform) = true /\
   assigns_ident_from_temp_s
      PPP_USPlatform._gMarioPlatform PPP_USPlatform._t'9
      (fn_body PPP_USPlatform.f_clear_mario_platform) = false) /\
  ~ In PPP_USPlatform._gMarioPlatform
      (program_init_addrof_identifiers us_official_cleaned_slice) /\
  ~ In PPP_JPPlatform._gMarioPlatform
      (program_init_addrof_identifiers jp_official_cleaned_slice).

Theorem official_platform_pointer_syntax_boundary_holds :
  OfficialPlatformPointerSyntaxBoundary.
Proof.
  unfold OfficialPlatformPointerSyntaxBoundary.
  split; [exact us_official_source_definition_provenance |].
  split; [exact jp_official_source_definition_provenance |].
  split; [exact us_platform_pointer_source_union_census_checked |].
  split; [exact jp_platform_pointer_source_union_census_checked |].
  split; [exact us_platform_update_value_flow_source_shape_checked |].
  split; [exact jp_platform_update_value_flow_source_shape_checked |].
  split; [exact us_platform_clear_only_writes_null_source_shape |].
  split; [exact us_official_initializer_has_no_platform_global_relocation |].
  exact jp_official_initializer_has_no_platform_global_relocation.
Qed.

(** Exact semantic residue.  The first two conjuncts turn the linked syntax
    classification into a step theorem; the last identifies the dataflow
    fact needed to project [update_mario_platform]'s non-null store to the
    owner returned by the immediately preceding [find_floor]. *)
Definition PlatformPointerSemanticClosureObligation
    (reachable_aliased_platform_global_store : Prop)
    (reachable_external_platform_global_store : Prop)
    (reachable_update_store_not_from_floor_owner : Prop) : Prop :=
  ~ reachable_aliased_platform_global_store /\
  ~ reachable_external_platform_global_store /\
  ~ reachable_update_store_not_from_floor_owner.

(** Once the three semantic residues are closed, the syntax results above can
    be lifted to a genuine reachable-step theorem: a newly installed non-null
    pointer came from the owner field of the effective floor query, while the
    US spawn event can only clear it.  That lifting is intentionally not stated
    as a theorem here because no linked reachable-store classification yet
    inhabits [PlatformPointerSemanticClosureObligation]. *)
