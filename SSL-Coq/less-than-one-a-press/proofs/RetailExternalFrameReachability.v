(** A finite unresolved-external boundary for the dialog/depth spine.

    CompCert's semantics does not infer a writable-memory frame for an
    [EF_external] from its prototype or from absence of a protected pointer in
    the argument list.  Before supplying implementation-specific frames, it is
    nevertheless useful to reduce the 133/132 declaration-wide inventories to
    the externals that the concrete dialog/depth spine can call directly.

    This file performs that reduction over the selected normalized-definition
    maps used to construct the source-owned cleaned units.  The result is a
    direct-callee boundary theorem, not a transitive call-graph closure and not
    a claim that the ten remaining externals preserve writable retail state.

    In particular, this result cannot inhabit [RetailExternalFrameBoundary]:
    that record protects every byte of the entire object pool, whereas some
    omitted retail helpers are legitimate object writers.  Full step 6 needs
    callsite- and slot-sensitive frames together with writer refinement. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Events Globalenvs Maps
  Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import
  us_mario us_mario_actions_cutscene us_mario_step
  jp_mario jp_mario_actions_cutscene jp_mario_step.
From LessThanOneAPress.Proofs Require Import LinkedClightPrograms
  NormalizedClightPrograms.

Import ListNotations.

Module REF_USMario := us_mario.
Module REF_USCutscene := us_mario_actions_cutscene.
Module REF_USStep := us_mario_step.
Module REF_JPMario := jp_mario.
Module REF_JPCutscene := jp_mario_actions_cutscene.
Module REF_JPStep := jp_mario_step.

Definition ident_in (id : ident) (ids : list ident) : bool :=
  existsb (Pos.eqb id) ids.

Lemma ident_in_spec :
  forall id ids, ident_in id ids = true <-> In id ids.
Proof.
  intros id ids. unfold ident_in.
  rewrite existsb_exists.
  split.
  - intros [found [Hin Hequal]].
    apply Pos.eqb_eq in Hequal. now subst found.
  - intros Hin. exists id. split; [exact Hin | apply Pos.eqb_refl].
Qed.

(** * Correct callsite-sensitive frame interface *)

(** The protected footprint may depend on the concrete external constructor,
    actual argument values, and current memory.  This is essential for
    selecting one live object slot or one pointer cell instead of declaring
    the complete object pool immutable. *)
Definition ExternalProtectedCellPolicy : Type :=
  external_function -> list val -> Mem.mem -> block -> Z -> Prop.

(** Legitimate effects such as [create_sound_spawner]'s allocation belong in
    the normal linked-writer/lifecycle refinement, not in a false frame. *)
Definition ExternalWriterRefinement : Type :=
  external_function -> list val -> Mem.mem -> trace -> val -> Mem.mem -> Prop.

(** Reachability must be relative to the concrete runtime boundary chosen for
    the semantic slice.  The selected programs do not contain their declared
    [_main], so quantifying over [Clight.initial_state] would make every such
    premise vacuous. *)
Definition ClightExecutionOrigin : Type := Clight.state -> Prop.

Definition ReachableExternalCallFrame
    (program : Clight.program) (origin : ClightExecutionOrigin)
    (protected : ExternalProtectedCellPolicy)
    (external : external_function) : Prop :=
  forall initial reach_trace argument_types result_type calling_convention
      arguments continuation before step_trace result after,
    origin initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial reach_trace
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before) ->
    Clight.step2 (Clight.globalenv program)
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before)
      step_trace (Returnstate result continuation after) ->
    Mem.unchanged_on (protected external arguments before) before after.

Definition constant_external_protected_cells
    (protected : block -> Z -> Prop) : ExternalProtectedCellPolicy :=
  fun _ _ _ => protected.

(** This is definitionally the declaration-wide interface named
    [ExternalCallFrame] in [ClightLinkExecution].  It is repeated here so the
    finite inventory need not import the much larger cleaned-link execution
    development merely to state the one-way compatibility theorem. *)
Definition LegacyExternalCallFrame
    (protected : block -> Z -> Prop) (external : external_function) : Prop :=
  forall ge arguments before trace result after,
    external_call external ge arguments before trace result after ->
    Mem.unchanged_on protected before after.

Lemma local_external_callstate_step_inv :
  forall (ge : Clight.genv) external argument_types result_type
      calling_convention arguments continuation before trace after_state,
    Clight.step2 ge
      (Callstate (External external argument_types result_type
        calling_convention) arguments continuation before)
      trace after_state ->
    exists result after,
      after_state = Returnstate result continuation after /\
      external_call external (Genv.to_senv ge)
        arguments before trace result after.
Proof.
  intros ge external argument_types result_type calling_convention arguments
    continuation before trace after_state Hstep.
  inversion Hstep; subst; eauto.
Qed.

(** The old declaration-wide premise is sufficient for the new reachable
    interface when the footprint is constant.  The converse is intentionally
    absent: the reachable interface is strictly more precise about arguments,
    memory, and control flow. *)
Theorem legacy_external_call_frame_implies_reachable_frame :
  forall program origin protected external,
    LegacyExternalCallFrame protected external ->
    ReachableExternalCallFrame program origin
      (constant_external_protected_cells protected) external.
Proof.
  intros program origin protected external Hlegacy initial reach_trace argument_types
    result_type calling_convention arguments continuation before step_trace
    result after _ _ Hstep.
  unfold constant_external_protected_cells.
  destruct (local_external_callstate_step_inv
    (Clight.globalenv program) external argument_types result_type
    calling_convention arguments continuation before step_trace
    (Returnstate result continuation after) Hstep)
    as [actual_result [actual_after [Hequal Hcall]]].
  inversion Hequal; subst.
  exact (Hlegacy (Genv.to_senv (Clight.globalenv program)) arguments before
    step_trace actual_result actual_after Hcall).
Qed.

(** Every reachable unresolved call must be classified locally.  The left
    branch is a byte frame for precisely the protected cells selected at that
    callsite.  The right branch carries the effect into writer/lifecycle
    refinement.  In particular, object creation is never discharged merely by
    calling it an external frame. *)
Record CallsiteSensitiveUnresolvedExternalInventory
    (program : Clight.program) (origin : ClightExecutionOrigin)
    (protected : ExternalProtectedCellPolicy)
    (writer : ExternalWriterRefinement) : Prop := {
  reachable_unresolved_external_effect_is_framed_or_refined :
    forall initial reach_trace name signature argument_types result_type
        calling_convention arguments continuation before step_trace result
        after,
      origin initial ->
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        initial reach_trace
        (Callstate (External (EF_external name signature) argument_types
          result_type calling_convention) arguments continuation before) ->
      Clight.step2 (Clight.globalenv program)
        (Callstate (External (EF_external name signature) argument_types
          result_type calling_convention) arguments continuation before)
        step_trace (Returnstate result continuation after) ->
      Mem.unchanged_on
        (protected (EF_external name signature) arguments before)
        before after \/
      writer (EF_external name signature) arguments before step_trace result
        after
}.

Theorem reachable_frames_supply_callsite_sensitive_inventory :
  forall program origin protected writer,
    (forall name signature,
      ReachableExternalCallFrame program origin protected
        (EF_external name signature)) ->
    CallsiteSensitiveUnresolvedExternalInventory
      program origin protected writer.
Proof.
  intros program origin protected writer Hframes. constructor.
  intros initial reach_trace name signature argument_types result_type
    calling_convention arguments continuation before step_trace result after
    Hinitial Hreachable Hstep.
  left. eapply Hframes; eauto.
Qed.

(** Local copy of the small direct-[Evar] call walker.  Indirect calls are not
    silently classified as externals by this function. *)
Fixpoint statement_direct_callees (body : statement) : list ident :=
  match body with
  | Sskip | Sassign _ _ | Sset _ _ | Sbreak | Scontinue | Sgoto _ => []
  | Scall _ (Evar callee _) _ => [callee]
  | Scall _ _ _ | Sbuiltin _ _ _ _ | Sreturn _ => []
  | Ssequence first second | Sloop first second =>
      statement_direct_callees first ++ statement_direct_callees second
  | Sifthenelse _ yes no =>
      statement_direct_callees yes ++ statement_direct_callees no
  | Sswitch _ cases => labeled_direct_callees cases
  | Slabel _ nested => statement_direct_callees nested
  end
with labeled_direct_callees (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      statement_direct_callees body ++ labeled_direct_callees rest
  end.

(** Normalization is pointwise by identifier.  These lemmas let an executable
    receipt normalize only definitions whose identifiers occur in the finite
    query set, while retaining a theorem about the full selected map. *)
Definition entry_identifier_in
    (ids : list ident) (entry : ident * globdef Clight.fundef type) : bool :=
  ident_in (fst entry) ids.

(** Filtering after [unit_global_definitions] first materializes the entire
    concatenated 4k-definition list under call-by-value evaluation.  This
    streaming form filters each translation unit before appending, so the
    executable receipt retains only the finite queried entries. *)
Fixpoint filtered_unit_global_definitions
    (ids : list ident) (units : nlist Clight.program)
    : list (ident * globdef Clight.fundef type) :=
  match units with
  | nbase unit => filter (entry_identifier_in ids) (prog_defs unit)
  | ncons unit rest =>
      filter (entry_identifier_in ids) (prog_defs unit) ++
      filtered_unit_global_definitions ids rest
  end.

Lemma filtered_unit_global_definitions_eq :
  forall ids units,
    filtered_unit_global_definitions ids units =
    filter (entry_identifier_in ids) (unit_global_definitions units).
Proof.
  intros ids units. unfold unit_global_definitions.
  induction units as [unit | unit rest IH].
  - cbn [filtered_unit_global_definitions nlist_to_list List.map List.concat].
    now rewrite app_nil_r.
  - cbn [filtered_unit_global_definitions nlist_to_list List.map List.concat].
    rewrite filter_app, IH. reflexivity.
Qed.

Lemma insert_preferred_other_identifier_get :
  forall definitions entry query,
    query <> fst entry ->
    PTree.get query
      (insert_preferred_global_definition_map definitions entry) =
    PTree.get query definitions.
Proof.
  intros definitions [id candidate] query Hdifferent.
  unfold insert_preferred_global_definition_map. cbn in Hdifferent.
  destruct (PTree.get id definitions) as [incumbent |].
  - destruct (Nat.ltb (global_definition_strength incumbent)
                       (global_definition_strength candidate)).
    + rewrite PTree.gso by exact Hdifferent; reflexivity.
    + reflexivity.
  - rewrite PTree.gso by exact Hdifferent; reflexivity.
Qed.

Lemma insert_preferred_get_respects_existing_get :
  forall left right entry query,
    PTree.get query left = PTree.get query right ->
    PTree.get query
      (insert_preferred_global_definition_map left entry) =
    PTree.get query
      (insert_preferred_global_definition_map right entry).
Proof.
  intros left right [id candidate] query Hequal.
  destruct (peq query id) as [-> | Hdifferent].
  - unfold insert_preferred_global_definition_map.
    destruct (PTree.get id left) as [incumbent |] eqn:Hleft.
    + assert (Hright : PTree.get id right = Some incumbent) by congruence.
      rewrite Hright.
      destruct (Nat.ltb (global_definition_strength incumbent)
                         (global_definition_strength candidate)).
      * rewrite !PTree.gss. reflexivity.
      * rewrite Hleft. exact Hequal.
    + assert (Hright : PTree.get id right = None) by congruence.
      rewrite Hright, !PTree.gss. reflexivity.
  - rewrite !insert_preferred_other_identifier_get by exact Hdifferent.
    exact Hequal.
Qed.

Lemma filtered_normalization_fold_preserves_queried_get :
  forall source ids query left right,
    PTree.get query left = PTree.get query right ->
    ident_in query ids = true ->
    PTree.get query
      (fold_left insert_preferred_global_definition_map
        (filter (entry_identifier_in ids) source) left) =
    PTree.get query
      (fold_left insert_preferred_global_definition_map source right).
Proof.
  induction source as [| [id candidate] rest IH];
    intros ids query left right Hequal Hquery.
  - cbn. exact Hequal.
  - change
      (PTree.get query
        (fold_left insert_preferred_global_definition_map
          (if ident_in id ids
           then (id, candidate) ::
             filter (entry_identifier_in ids) rest
           else filter (entry_identifier_in ids) rest) left) =
       PTree.get query
        (fold_left insert_preferred_global_definition_map rest
          (insert_preferred_global_definition_map right (id, candidate)))).
    destruct (ident_in id ids) eqn:Hentry.
    + change
        (PTree.get query
          (fold_left insert_preferred_global_definition_map
            (filter (entry_identifier_in ids) rest)
            (insert_preferred_global_definition_map left (id, candidate))) =
         PTree.get query
          (fold_left insert_preferred_global_definition_map rest
            (insert_preferred_global_definition_map right (id, candidate)))).
      apply IH;
        [now apply insert_preferred_get_respects_existing_get | exact Hquery].
    + change
        (PTree.get query
          (fold_left insert_preferred_global_definition_map
            (filter (entry_identifier_in ids) rest) left) =
         PTree.get query
          (fold_left insert_preferred_global_definition_map rest
            (insert_preferred_global_definition_map right (id, candidate)))).
      apply IH; [|exact Hquery].
      rewrite insert_preferred_other_identifier_get.
      * exact Hequal.
      * intros Hsame. cbn in Hsame. subst query.
        rewrite Hentry in Hquery. discriminate.
Qed.

Theorem filtered_normalization_preserves_queried_get :
  forall source ids query,
    ident_in query ids = true ->
    PTree.get query
      (normalize_global_definition_map
        (filter (entry_identifier_in ids) source)) =
    PTree.get query (normalize_global_definition_map source).
Proof.
  intros source ids query Hquery.
  unfold normalize_global_definition_map.
  apply filtered_normalization_fold_preserves_queried_get; auto.
Qed.

(** The seven bodies already isolated by [DialogDepthMemoryFrame]. *)
Definition us_dialog_depth_spine_direct_callees : list ident :=
  nodup peq
    (statement_direct_callees
       (fn_body REF_USMario.f_set_mario_action_cutscene) ++
     statement_direct_callees (fn_body REF_USMario.f_set_mario_action) ++
     statement_direct_callees (fn_body REF_USMario.f_sink_mario_in_quicksand) ++
     statement_direct_callees
       (fn_body REF_USCutscene.f_general_star_dance_handler) ++
     statement_direct_callees (fn_body REF_USCutscene.f_act_star_dance) ++
     statement_direct_callees
       (fn_body REF_USCutscene.f_act_reading_automatic_dialog) ++
     statement_direct_callees
       (fn_body REF_USStep.f_stop_and_set_height_to_floor)).

Definition jp_dialog_depth_spine_direct_callees : list ident :=
  nodup peq
    (statement_direct_callees
       (fn_body REF_JPMario.f_set_mario_action_cutscene) ++
     statement_direct_callees (fn_body REF_JPMario.f_set_mario_action) ++
     statement_direct_callees (fn_body REF_JPMario.f_sink_mario_in_quicksand) ++
     statement_direct_callees
       (fn_body REF_JPCutscene.f_general_star_dance_handler) ++
     statement_direct_callees (fn_body REF_JPCutscene.f_act_star_dance) ++
     statement_direct_callees
       (fn_body REF_JPCutscene.f_act_reading_automatic_dialog) ++
     statement_direct_callees
       (fn_body REF_JPStep.f_stop_and_set_height_to_floor)).

Definition selected_unresolved_external_identifier
    (definitions : global_definition_map) (id : ident) : bool :=
  match PTree.get id definitions with
  | Some (Gfun (External (EF_external _ _) _ _ _)) => true
  | _ => false
  end.

Definition retain_selected_unresolved_external_identifiers
    (definitions : global_definition_map) (ids : list ident) : list ident :=
  filter (selected_unresolved_external_identifier definitions) ids.

Definition us_dialog_depth_spine_definition_map : global_definition_map :=
  normalize_global_definition_map
    (filtered_unit_global_definitions
      us_dialog_depth_spine_direct_callees us_units).

Definition jp_dialog_depth_spine_definition_map : global_definition_map :=
  normalize_global_definition_map
    (filtered_unit_global_definitions
      jp_dialog_depth_spine_direct_callees jp_units).

Definition us_dialog_depth_spine_unresolved : list ident :=
  retain_selected_unresolved_external_identifiers
    us_dialog_depth_spine_definition_map
    us_dialog_depth_spine_direct_callees.

Definition jp_dialog_depth_spine_unresolved : list ident :=
  retain_selected_unresolved_external_identifiers
    jp_dialog_depth_spine_definition_map
    jp_dialog_depth_spine_direct_callees.

(** Candidate finite inventory from the source audit.  These are the ten
    implementations located outside the selected translation units.  The
    lists are recorded explicitly, but this resource-bounded file does not
    claim that evaluation against the generated source universe completed. *)
Definition us_dialog_depth_expected_unresolved : list ident :=
  [REF_USCutscene._create_dialog_box;
   REF_USCutscene._create_dialog_box_with_var;
   REF_USCutscene._get_dialog_id;
   REF_USCutscene._play_cutscene_music;
   REF_USCutscene._disable_background_sound;
   REF_USCutscene._play_course_clear;
   REF_USCutscene._play_music;
   REF_USCutscene._play_sound;
   REF_USCutscene._create_dialog_box_with_response;
   REF_USCutscene._enable_background_sound].

Definition jp_dialog_depth_expected_unresolved : list ident :=
  [REF_JPCutscene._create_dialog_box;
   REF_JPCutscene._create_dialog_box_with_var;
   REF_JPCutscene._get_dialog_id;
   REF_JPCutscene._play_cutscene_music;
   REF_JPCutscene._disable_background_sound;
   REF_JPCutscene._play_course_clear;
   REF_JPCutscene._play_music;
   REF_JPCutscene._play_sound;
   REF_JPCutscene._create_dialog_box_with_response;
   REF_JPCutscene._enable_background_sound].

Definition same_ident_set (left right : list ident) : bool :=
  forallb (fun id => ident_in id right) left &&
  forallb (fun id => ident_in id left) right.

Lemma same_ident_set_spec :
  forall left right,
    same_ident_set left right = true <->
    forall id, In id left <-> In id right.
Proof.
  intros left right. unfold same_ident_set.
  rewrite andb_true_iff. split.
  - intros [Hleft Hright] id. split; intros Hin.
    + apply ident_in_spec.
      apply (proj1 (forallb_forall _ _) Hleft id Hin).
    + apply ident_in_spec.
      apply (proj1 (forallb_forall _ _) Hright id Hin).
  - intros Hsets. split; apply forallb_forall; intros id Hin;
      apply ident_in_spec.
    + exact (proj1 (Hsets id) Hin).
    + exact (proj2 (Hsets id) Hin).
Qed.

(** This module states the finite audit but does not inhabit it inline: direct
    evaluation of the full generated AST exceeded the available memory.  The
    split translation-unit receipts in [DialogDepthFiniteInventory] close the
    same proposition without one monolithic computation. *)
Definition DialogDepthFiniteInventoryObligation : Prop :=
  same_ident_set us_dialog_depth_spine_unresolved
    us_dialog_depth_expected_unresolved = true /\
  List.length us_dialog_depth_spine_unresolved = 10%nat /\
  same_ident_set jp_dialog_depth_spine_unresolved
    jp_dialog_depth_expected_unresolved = true /\
  List.length jp_dialog_depth_spine_unresolved = 10%nat.

(** Generic Boolean soundness, independent of the split finite receipt. *)
Lemma selected_unresolved_external_identifier_sound :
  forall definitions id,
    selected_unresolved_external_identifier definitions id = true ->
    exists name signature argument_types result_type calling_convention,
      PTree.get id definitions =
        Some (Gfun (External (EF_external name signature)
          argument_types result_type calling_convention)).
Proof.
  intros definitions id Hchecked.
  unfold selected_unresolved_external_identifier in Hchecked.
  destruct (PTree.get id definitions) as [definition |] eqn:Hget;
    try discriminate.
  destruct definition as [definition | variable]; try discriminate.
  destruct definition as [body | external argument_types result_type
      calling_convention]; try discriminate.
  destruct external; cbn in Hchecked; try discriminate.
  do 5 eexists. reflexivity.
Qed.

(** Source audit note (not a theorem in this resource-bounded certificate):
    the generated star-dance call passes a local temporary [_t'17], not [m]
    or [_marioObj], directly to [play_sound].  Immediately beforehand,
    [_t'17] is assigned [m->marioObj], and the second call argument selects
    [_cameraToObject] through that temporary.  A future small callsite lemma
    should prove this assignment/evaluation chain without repeatedly reducing
    the complete generated function body.  Until then, no pointer-validity or
    non-alias conclusion is drawn from this source observation. *)
