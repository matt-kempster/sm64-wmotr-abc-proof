(* Integration point between the provenance model and the generated-code
   no-observation audit.

   StalePointerModel shows that an outside held-object epoch can survive into
   the post-load / pre-init_mario window.  TransitionFacts shows that the
   obvious generated load/reinit bodies do not mention Mario's stale object
   reference roots before init_mario / init_mario_after_warp clears or rebinds
   them.  This file packages the combination as a single corollary so the
   checklist can stop treating those as two loose facts.
 *)

From Coq Require Import List ZArith.
Import ListNotations.
From compcert Require Import AST Clight Memory Values.
From SSLPyramid.Proofs Require Import
  ASTFacts GraphTraversalModel NonMarioReferenceFacts OutsideObjectChannels
  RenderHeldObjectFacts Spec StalePointerModel TransitionFacts
  TraversalModel.

Local Open Scope Z_scope.

Definition proposition_of {P : Prop} (_ : P) : Prop := P.

Definition audited_mario_stale_ref_no_observation_before_cleanup : Prop :=
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_mario_area) = false /\
  field_mentioners O.prog O._heldObj = [] /\
  field_mentioners O.prog O._usedObj = [] /\
  field_mentioners O.prog O._riddenObj = [] /\
  field_mentioners O.prog O._interactObj = [] /\
  statement_mentions_field_before_call_s L._init_mario L._heldObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._usedObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._riddenObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._interactObj
    (fn_body L.f_init_mario_after_warp) = false.

Theorem audited_mario_stale_ref_no_observation_before_cleanup_holds :
  audited_mario_stale_ref_no_observation_before_cleanup.
Proof.
  exact pyramid_load_window_stale_refs_not_observed_before_cleanup.
Qed.

Theorem held_grab_stale_load_window_is_unobserved_before_cleanup :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      stale_outside_reference_after_pyramid_load
        before pool_block window /\
      ~ stale_outside_reference before pool_block
          (refs_after_mario_reinit window) /\
      audited_mario_stale_ref_no_observation_before_cleanup.
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  destruct
    (outside_held_grab_can_leave_stale_reference_across_pyramid_load
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hstale & Hclean).
  exists window.
  split; [exact Hwindow |].
  split; [exact Hstale |].
  split; [exact Hclean |].
  exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.

Theorem held_grab_reused_slot_alias_is_unobserved_before_cleanup :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      stale_outside_reference_aliases_live_slot
        before after_load pool_block
        (refs_after_pyramid_load_before_mario_init window) /\
      ~ stale_outside_reference before pool_block
          (refs_after_mario_reinit window) /\
      audited_mario_stale_ref_no_observation_before_cleanup.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (held_grab_stale_reference_would_alias_reused_slot_after_load
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Halias).
  exists window.
  split; [exact Hwindow |].
  split; [exact Halias |].
  split.
  - subst window.
    apply post_pyramid_warp_shape_has_no_stale_outside_reference
      with (destination_spawn_slot := destination_spawn_slot).
    apply post_reinit_refs_have_post_pyramid_warp_shape.
  - exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.

Inductive high_risk_outside_pointer_root : Type :=
| RootMarioInteractObj
| RootMarioHeldObj
| RootMarioUsedObj
| RootMarioRiddenObj
| RootObjectParentObj
| RootObjectPrevObj
| RootObjectPlatform
| RootObjectCollidedObjs
| RootObjectRawDataAsObject
| RootGraphObjectSharedChild
| RootGraphHeldObjectObjNode
| RootGraphTreeOrSiblingLink.

Definition high_risk_outside_pointer_roots
    : list high_risk_outside_pointer_root :=
  [RootMarioInteractObj;
   RootMarioHeldObj;
   RootMarioUsedObj;
   RootMarioRiddenObj;
   RootObjectParentObj;
   RootObjectPrevObj;
   RootObjectPlatform;
   RootObjectCollidedObjs;
   RootObjectRawDataAsObject;
   RootGraphObjectSharedChild;
   RootGraphHeldObjectObjNode;
   RootGraphTreeOrSiblingLink].

Definition root_is_mario_state_reference
    (root : high_risk_outside_pointer_root) : bool :=
  match root with
  | RootMarioInteractObj
  | RootMarioHeldObj
  | RootMarioUsedObj
  | RootMarioRiddenObj => true
  | _ => false
  end.

Definition root_is_object_owned_reference
    (root : high_risk_outside_pointer_root) : bool :=
  match root with
  | RootObjectParentObj
  | RootObjectPrevObj
  | RootObjectPlatform
  | RootObjectCollidedObjs
  | RootObjectRawDataAsObject => true
  | _ => false
  end.

Definition root_is_graph_reference
    (root : high_risk_outside_pointer_root) : bool :=
  match root with
  | RootGraphObjectSharedChild
  | RootGraphHeldObjectObjNode
  | RootGraphTreeOrSiblingLink => true
  | _ => false
  end.

Definition root_is_render_held_reference
    (root : high_risk_outside_pointer_root) : bool :=
  match root with
  | RootGraphHeldObjectObjNode => true
  | _ => false
  end.

Theorem high_risk_outside_pointer_roots_complete :
  forall root,
    In root high_risk_outside_pointer_roots.
Proof.
  intros [] ; simpl; eauto 20.
Qed.

Theorem high_risk_outside_pointer_root_classification_exact :
  map
    (fun root =>
       (root,
        root_is_mario_state_reference root,
        root_is_object_owned_reference root,
        root_is_graph_reference root,
        root_is_render_held_reference root))
    high_risk_outside_pointer_roots =
  [(RootMarioInteractObj, true, false, false, false);
   (RootMarioHeldObj, true, false, false, false);
   (RootMarioUsedObj, true, false, false, false);
   (RootMarioRiddenObj, true, false, false, false);
   (RootObjectParentObj, false, true, false, false);
   (RootObjectPrevObj, false, true, false, false);
   (RootObjectPlatform, false, true, false, false);
   (RootObjectCollidedObjs, false, true, false, false);
   (RootObjectRawDataAsObject, false, true, false, false);
   (RootGraphObjectSharedChild, false, false, true, false);
   (RootGraphHeldObjectObjNode, false, false, true, true);
   (RootGraphTreeOrSiblingLink, false, false, true, false)].
Proof. vm_compute; reflexivity. Qed.

Definition high_risk_pointer_roots_load_window_audit : Prop :=
  audited_mario_stale_ref_no_observation_before_cleanup /\
  proposition_of
    pyramid_load_window_full_object_owned_roots_not_mentioned_before_cleanup /\
  proposition_of
    pyramid_load_window_mario_platform_externals_not_called_before_cleanup /\
  proposition_of
    pyramid_load_window_graph_specific_roots_not_mentioned_before_cleanup /\
  proposition_of
    pyramid_load_window_typed_graph_node_link_audit.

Theorem high_risk_pointer_roots_load_window_audit_holds :
  high_risk_pointer_roots_load_window_audit.
Proof.
  unfold high_risk_pointer_roots_load_window_audit, proposition_of.
  split; [exact audited_mario_stale_ref_no_observation_before_cleanup_holds |].
  split;
    [ exact pyramid_load_window_full_object_owned_roots_not_mentioned_before_cleanup
    |].
  split;
    [ exact pyramid_load_window_mario_platform_externals_not_called_before_cleanup
    |].
  split;
    [ exact pyramid_load_window_graph_specific_roots_not_mentioned_before_cleanup
    |].
  exact pyramid_load_window_typed_graph_node_link_audit.
Qed.

Record outside_pointer_observation := {
  observed_pointer_root : high_risk_outside_pointer_root;
  observed_pointer_origin : object_reference_origin
}.

Definition observation_mentions_outside_slot
    (before : mem) (pool_block : block)
    (observation : outside_pointer_observation) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    observed_pointer_origin observation = OutsideAllocationEpoch slot.

Definition persistent_outside_pointer_counterexample_candidate
    (before : mem) (pool_block : block)
    (observation : outside_pointer_observation) : Prop :=
  In (observed_pointer_root observation)
    high_risk_outside_pointer_roots /\
  observation_mentions_outside_slot before pool_block observation.

Theorem persistent_outside_pointer_from_high_risk_root_is_counterexample_candidate :
  forall before pool_block root slot,
    In root high_risk_outside_pointer_roots ->
    outside_live_slot before pool_block slot ->
    persistent_outside_pointer_counterexample_candidate before pool_block
      {| observed_pointer_root := root;
         observed_pointer_origin := OutsideAllocationEpoch slot |}.
Proof.
  intros before pool_block root slot Hroot Houtside.
  split; [exact Hroot |].
  exists slot.
  split; [exact Houtside | reflexivity].
Qed.

Theorem post_init_mario_refs_have_no_stale_outside_reference :
  forall before pool_block destination_spawn_slot,
    ~ stale_outside_reference before pool_block
        (post_reinit_refs destination_spawn_slot).
Proof.
  intros before pool_block destination_spawn_slot.
  apply post_pyramid_warp_shape_has_no_stale_outside_reference
    with (destination_spawn_slot := destination_spawn_slot).
  apply post_reinit_refs_have_post_pyramid_warp_shape.
Qed.

Definition normal_post_init_mario_root_origin
    (destination_spawn_slot : Z)
    (root : high_risk_outside_pointer_root)
    : option object_reference_origin :=
  match root with
  | RootMarioInteractObj =>
      Some (DestinationSpawnObject destination_spawn_slot)
  | RootMarioHeldObj =>
      Some NoObjectReference
  | RootMarioUsedObj =>
      Some (DestinationSpawnObject destination_spawn_slot)
  | RootMarioRiddenObj =>
      Some NoObjectReference
  | _ =>
      None
  end.

Definition normal_post_init_root_survives_as_outside
    (before : mem) (pool_block : block)
    (destination_spawn_slot : Z)
    (root : high_risk_outside_pointer_root) : Prop :=
  exists origin slot,
    normal_post_init_mario_root_origin destination_spawn_slot root =
      Some origin /\
    outside_live_slot before pool_block slot /\
    origin = OutsideAllocationEpoch slot.

Theorem normal_post_init_mario_root_origins_match_post_reinit_refs :
  forall destination_spawn_slot,
    [normal_post_init_mario_root_origin
       destination_spawn_slot RootMarioInteractObj;
     normal_post_init_mario_root_origin
       destination_spawn_slot RootMarioHeldObj;
     normal_post_init_mario_root_origin
       destination_spawn_slot RootMarioUsedObj;
     normal_post_init_mario_root_origin
       destination_spawn_slot RootMarioRiddenObj] =
    map Some
      (mario_reference_origin_list
         (post_reinit_refs destination_spawn_slot)).
Proof.
  intros destination_spawn_slot.
  vm_compute.
  reflexivity.
Qed.

Theorem normal_post_init_mario_high_risk_roots_do_not_persist :
  forall before pool_block destination_spawn_slot root,
    root_is_mario_state_reference root = true ->
    ~ normal_post_init_root_survives_as_outside
        before pool_block destination_spawn_slot root.
Proof.
  intros before pool_block destination_spawn_slot root Hmario Hsurvives.
  destruct Hsurvives as (origin & slot & Horigin & _ & Houtside_epoch).
  destruct root; simpl in Hmario; try discriminate;
    simpl in Horigin; inversion Horigin; subst origin; discriminate.
Qed.

Definition normal_post_init_high_risk_root_outcome
    (before : mem) (pool_block : block)
    (destination_spawn_slot : Z)
    (root : high_risk_outside_pointer_root) : Prop :=
  (root_is_mario_state_reference root = true /\
   ~ normal_post_init_root_survives_as_outside
       before pool_block destination_spawn_slot root) \/
  (root_is_mario_state_reference root = false /\
   forall slot,
     outside_live_slot before pool_block slot ->
     persistent_outside_pointer_counterexample_candidate before pool_block
       {| observed_pointer_root := root;
          observed_pointer_origin := OutsideAllocationEpoch slot |}).

Theorem normal_path_high_risk_roots_do_not_persist_or_are_candidates :
  forall before pool_block destination_spawn_slot root,
    In root high_risk_outside_pointer_roots ->
    normal_post_init_high_risk_root_outcome
      before pool_block destination_spawn_slot root.
Proof.
  intros before pool_block destination_spawn_slot root Hroot.
  destruct root; simpl in *.
  all: try
    (left;
     split;
     [reflexivity
     | apply normal_post_init_mario_high_risk_roots_do_not_persist;
       reflexivity]).
  all: right.
  all: split; [reflexivity |].
  all: intros slot Houtside.
  all: apply persistent_outside_pointer_from_high_risk_root_is_counterexample_candidate;
    assumption.
Qed.

Definition normal_ssl_pyramid_change_area_high_risk_root_certificate : Prop :=
  proposition_of normal_gameplay_ssl_warp_entry_action_nonzero_syntactic_certificate /\
  proposition_of warp_area_loads_destination_before_mario_reference_cleanup /\
  proposition_of init_mario_after_warp_cleanup_is_guarded_by_action_nonzero /\
  proposition_of init_mario_clears_held_object /\
  proposition_of init_mario_clears_ridden_object /\
  proposition_of init_mario_clears_used_object /\
  high_risk_pointer_roots_load_window_audit /\
  forall before pool_block destination_spawn_slot root,
    In root high_risk_outside_pointer_roots ->
    normal_post_init_high_risk_root_outcome
      before pool_block destination_spawn_slot root.

Theorem normal_ssl_pyramid_change_area_high_risk_root_certificate_holds :
  normal_ssl_pyramid_change_area_high_risk_root_certificate.
Proof.
  unfold normal_ssl_pyramid_change_area_high_risk_root_certificate,
    proposition_of.
  split; [exact normal_gameplay_ssl_warp_entry_action_nonzero_syntactic_certificate |].
  split; [exact warp_area_loads_destination_before_mario_reference_cleanup |].
  split; [exact init_mario_after_warp_cleanup_is_guarded_by_action_nonzero |].
  split; [exact init_mario_clears_held_object |].
  split; [exact init_mario_clears_ridden_object |].
  split; [exact init_mario_clears_used_object |].
  split; [exact high_risk_pointer_roots_load_window_audit_holds |].
  intros before pool_block destination_spawn_slot root Hroot.
  apply normal_path_high_risk_roots_do_not_persist_or_are_candidates.
  exact Hroot.
Qed.

Definition object_owned_high_risk_roots
    : list high_risk_outside_pointer_root :=
  [RootObjectParentObj;
   RootObjectPrevObj;
   RootObjectPlatform;
   RootObjectCollidedObjs;
   RootObjectRawDataAsObject].

Definition graph_and_render_high_risk_roots
    : list high_risk_outside_pointer_root :=
  [RootGraphObjectSharedChild;
   RootGraphHeldObjectObjNode;
   RootGraphTreeOrSiblingLink].

Theorem object_owned_high_risk_roots_exact :
  object_owned_high_risk_roots =
  filter root_is_object_owned_reference high_risk_outside_pointer_roots.
Proof. vm_compute; reflexivity. Qed.

Theorem graph_and_render_high_risk_roots_exact :
  graph_and_render_high_risk_roots =
  filter root_is_graph_reference high_risk_outside_pointer_roots.
Proof. vm_compute; reflexivity. Qed.

Theorem object_owned_high_risk_roots_are_high_risk :
  forall root,
    In root object_owned_high_risk_roots ->
    In root high_risk_outside_pointer_roots.
Proof.
  intros root Hroot.
  destruct root; simpl in *; intuition congruence.
Qed.

Theorem graph_and_render_high_risk_roots_are_high_risk :
  forall root,
    In root graph_and_render_high_risk_roots ->
    In root high_risk_outside_pointer_roots.
Proof.
  intros root Hroot.
  destruct root; simpl in *; intuition congruence.
Qed.

Theorem object_owned_root_survivor_is_counterexample_candidate :
  forall before pool_block root slot,
    In root object_owned_high_risk_roots ->
    outside_live_slot before pool_block slot ->
    persistent_outside_pointer_counterexample_candidate before pool_block
      {| observed_pointer_root := root;
         observed_pointer_origin := OutsideAllocationEpoch slot |}.
Proof.
  intros before pool_block root slot Hroot Houtside.
  apply persistent_outside_pointer_from_high_risk_root_is_counterexample_candidate.
  - apply object_owned_high_risk_roots_are_high_risk.
    exact Hroot.
  - exact Houtside.
Qed.

Theorem graph_or_render_root_survivor_is_counterexample_candidate :
  forall before pool_block root slot,
    In root graph_and_render_high_risk_roots ->
    outside_live_slot before pool_block slot ->
    persistent_outside_pointer_counterexample_candidate before pool_block
      {| observed_pointer_root := root;
         observed_pointer_origin := OutsideAllocationEpoch slot |}.
Proof.
  intros before pool_block root slot Hroot Houtside.
  apply persistent_outside_pointer_from_high_risk_root_is_counterexample_candidate.
  - apply graph_and_render_high_risk_roots_are_high_risk.
    exact Hroot.
  - exact Houtside.
Qed.

Definition object_owned_root_generated_cleanup_boundary : Prop :=
  proposition_of object_owned_scalar_object_reference_fields /\
  proposition_of object_owned_array_object_reference_fields /\
  proposition_of object_raw_data_object_reference_array_fields /\
  proposition_of spawn_object_owned_reference_writers /\
  proposition_of object_helpers_owned_reference_writers /\
  proposition_of object_list_processor_has_no_owned_reference_writers /\
  proposition_of transition_side_modules_have_no_owned_reference_writers /\
  proposition_of object_owned_platform_writers /\
  proposition_of object_owned_collided_object_array_writers /\
  proposition_of object_owned_raw_behavior_object_slot_writers /\
  proposition_of pyramid_load_window_full_object_owned_roots_not_mentioned_before_cleanup /\
  proposition_of generated_unload_targets_trace_clears_outside /\
  proposition_of generated_unload_targets_trace_forbids_transfer.

Theorem object_owned_root_generated_cleanup_boundary_holds :
  object_owned_root_generated_cleanup_boundary.
Proof.
  unfold object_owned_root_generated_cleanup_boundary, proposition_of.
  repeat split;
    first
      [ exact object_owned_scalar_object_reference_fields
      | exact object_owned_array_object_reference_fields
      | exact object_raw_data_object_reference_array_fields
      | exact spawn_object_owned_reference_writers
      | exact object_helpers_owned_reference_writers
      | exact object_list_processor_has_no_owned_reference_writers
      | exact transition_side_modules_have_no_owned_reference_writers
      | exact object_owned_platform_writers
      | exact object_owned_collided_object_array_writers
      | exact object_owned_raw_behavior_object_slot_writers
      | exact pyramid_load_window_full_object_owned_roots_not_mentioned_before_cleanup
      | exact generated_unload_targets_trace_clears_outside
      | exact generated_unload_targets_trace_forbids_transfer ].
Qed.

Definition graph_and_render_root_generated_cleanup_boundary : Prop :=
  proposition_of graph_node_reference_fields /\
  proposition_of graph_node_object_shared_child_reference_fields /\
  proposition_of graph_node_held_object_reference_fields /\
  proposition_of graph_node_tree_link_writers /\
  proposition_of graph_node_shared_child_writers /\
  proposition_of graph_node_held_object_objnode_writers /\
  proposition_of init_graph_node_held_object_stores_objnode_parameter /\
  proposition_of mario_misc_render_held_object_refreshes_from_mario_heldObj /\
  proposition_of geo_switch_mario_hand_grab_pos_direct_objnode_writers /\
  proposition_of geo_switch_mario_hand_grab_pos_refreshes_objnode_from_mario_heldObj /\
  proposition_of pyramid_load_window_graph_specific_roots_not_mentioned_before_cleanup /\
  proposition_of pyramid_load_window_typed_graph_node_link_audit /\
  proposition_of generated_graph_traversal_confinement_or_counterexample_candidate /\
  proposition_of surviving_outside_graph_link_is_counterexample_candidate.

Theorem graph_and_render_root_generated_cleanup_boundary_holds :
  graph_and_render_root_generated_cleanup_boundary.
Proof.
  unfold graph_and_render_root_generated_cleanup_boundary, proposition_of.
  repeat split;
    first
      [ exact graph_node_reference_fields
      | exact graph_node_object_shared_child_reference_fields
      | exact graph_node_held_object_reference_fields
      | exact graph_node_tree_link_writers
      | exact graph_node_shared_child_writers
      | exact graph_node_held_object_objnode_writers
      | exact init_graph_node_held_object_stores_objnode_parameter
      | exact mario_misc_render_held_object_refreshes_from_mario_heldObj
      | exact geo_switch_mario_hand_grab_pos_direct_objnode_writers
      | exact geo_switch_mario_hand_grab_pos_refreshes_objnode_from_mario_heldObj
      | exact pyramid_load_window_graph_specific_roots_not_mentioned_before_cleanup
      | exact pyramid_load_window_typed_graph_node_link_audit
      | exact generated_graph_traversal_confinement_or_counterexample_candidate
      | exact surviving_outside_graph_link_is_counterexample_candidate ].
Qed.

Definition mario_platform_helper_precleanup_boundary : Prop :=
  proposition_of pyramid_load_window_mario_platform_externals_not_called_before_cleanup.

Theorem mario_platform_helper_precleanup_boundary_holds :
  mario_platform_helper_precleanup_boundary.
Proof.
  unfold mario_platform_helper_precleanup_boundary, proposition_of.
  exact pyramid_load_window_mario_platform_externals_not_called_before_cleanup.
Qed.

Definition non_mario_high_risk_root_survivor_boundary : Prop :=
  object_owned_root_generated_cleanup_boundary /\
  graph_and_render_root_generated_cleanup_boundary /\
  mario_platform_helper_precleanup_boundary /\
  (forall before pool_block root slot,
    In root object_owned_high_risk_roots ->
    outside_live_slot before pool_block slot ->
    persistent_outside_pointer_counterexample_candidate before pool_block
      {| observed_pointer_root := root;
         observed_pointer_origin := OutsideAllocationEpoch slot |}) /\
  (forall before pool_block root slot,
    In root graph_and_render_high_risk_roots ->
    outside_live_slot before pool_block slot ->
    persistent_outside_pointer_counterexample_candidate before pool_block
      {| observed_pointer_root := root;
         observed_pointer_origin := OutsideAllocationEpoch slot |}).

Theorem non_mario_high_risk_root_survivor_boundary_holds :
  non_mario_high_risk_root_survivor_boundary.
Proof.
  unfold non_mario_high_risk_root_survivor_boundary.
  split; [exact object_owned_root_generated_cleanup_boundary_holds |].
  split; [exact graph_and_render_root_generated_cleanup_boundary_holds |].
  split; [exact mario_platform_helper_precleanup_boundary_holds |].
  split.
  - intros before pool_block root slot Hroot Houtside.
    eapply object_owned_root_survivor_is_counterexample_candidate; eauto.
  - intros before pool_block root slot Hroot Houtside.
    eapply graph_or_render_root_survivor_is_counterexample_candidate; eauto.
Qed.

Definition root_origin_observations :=
  list (high_risk_outside_pointer_root * object_reference_origin).

Definition origin_mentions_outside_epoch
    (before : mem) (pool_block : block)
    (origin : object_reference_origin) : Prop :=
  exists slot,
    outside_live_slot before pool_block slot /\
    origin = OutsideAllocationEpoch slot.

Definition origin_clean_of_outside_epochs
    (before : mem) (pool_block : block)
    (origin : object_reference_origin) : Prop :=
  forall slot,
    outside_live_slot before pool_block slot ->
    origin <> OutsideAllocationEpoch slot.

Definition root_origin_observations_have_no_outside_epoch
    (before : mem) (pool_block : block)
    (roots : list high_risk_outside_pointer_root)
    (observations : root_origin_observations) : Prop :=
  forall root origin slot,
    In root roots ->
    In (root, origin) observations ->
    outside_live_slot before pool_block slot ->
    origin <> OutsideAllocationEpoch slot.

Definition root_origin_observations_have_survivor
    (before : mem) (pool_block : block)
    (roots : list high_risk_outside_pointer_root)
    (observations : root_origin_observations) : Prop :=
  exists root origin slot,
    In root roots /\
    In (root, origin) observations /\
    outside_live_slot before pool_block slot /\
    origin = OutsideAllocationEpoch slot.

Theorem clean_root_origin_observations_eliminate_survivors :
  forall before pool_block roots observations,
    root_origin_observations_have_no_outside_epoch
      before pool_block roots observations ->
    ~ root_origin_observations_have_survivor
        before pool_block roots observations.
Proof.
  intros before pool_block roots observations Hclean Hsurvivor.
  destruct Hsurvivor as
    (root & origin & slot & Hroot & Hobs & Houtside & Horigin).
  exact (Hclean root origin slot Hroot Hobs Houtside Horigin).
Qed.

Theorem object_owned_root_origin_survivor_is_counterexample_candidate :
  forall before pool_block observations,
    root_origin_observations_have_survivor
      before pool_block object_owned_high_risk_roots observations ->
    exists root origin,
      In (root, origin) observations /\
      persistent_outside_pointer_counterexample_candidate before pool_block
        {| observed_pointer_root := root;
           observed_pointer_origin := origin |}.
Proof.
  intros before pool_block observations Hsurvivor.
  destruct Hsurvivor as
    (root & origin & slot & Hroot & Hobs & Houtside & Horigin).
  exists root, origin.
  split; [exact Hobs |].
  subst origin.
  eapply object_owned_root_survivor_is_counterexample_candidate; eauto.
Qed.

Theorem graph_or_render_root_origin_survivor_is_counterexample_candidate :
  forall before pool_block observations,
    root_origin_observations_have_survivor
      before pool_block graph_and_render_high_risk_roots observations ->
    exists root origin,
      In (root, origin) observations /\
      persistent_outside_pointer_counterexample_candidate before pool_block
        {| observed_pointer_root := root;
           observed_pointer_origin := origin |}.
Proof.
  intros before pool_block observations Hsurvivor.
  destruct Hsurvivor as
    (root & origin & slot & Hroot & Hobs & Houtside & Horigin).
  exists root, origin.
  split; [exact Hobs |].
  subst origin.
  eapply graph_or_render_root_survivor_is_counterexample_candidate; eauto.
Qed.

Definition object_owned_root_epoch_invariant
    (before : mem) (pool_block : block)
    (observations : root_origin_observations) : Prop :=
  root_origin_observations_have_no_outside_epoch
    before pool_block object_owned_high_risk_roots observations.

Theorem object_owned_root_epoch_invariant_eliminates_survivors :
  forall before pool_block observations,
    object_owned_root_epoch_invariant before pool_block observations ->
    ~ root_origin_observations_have_survivor
        before pool_block object_owned_high_risk_roots observations.
Proof.
  intros before pool_block observations Hclean.
  apply clean_root_origin_observations_eliminate_survivors.
  exact Hclean.
Qed.

Definition allocate_object_object_owned_root_init_audit : Prop :=
  event_subsequenceb
    [Event_assign_field_from_temp S._parentObj S._obj;
     Event_assign_field_null S._prevObj;
     Event_assign_field_null S._platform]
    (statement_events_s (fn_body S.f_allocate_object)) = true /\
  assigns_zero_to_field_s S._numCollidedObjs
    (fn_body S.f_allocate_object) = true /\
  statement_mentions_field_s S._rawData
    (fn_body S.f_allocate_object) = true /\
  statement_mentions_field_s S._asObject
    (fn_body S.f_allocate_object) = false.

Theorem allocate_object_object_owned_root_init_audit_holds :
  allocate_object_object_owned_root_init_audit.
Proof.
  unfold allocate_object_object_owned_root_init_audit.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition spawn_objects_from_info_linked_object_owned_audit : Prop :=
  event_subsequenceb
    [Event_call O._clear_mario_platform;
     Event_call O._create_object]
    (statement_events_s (fn_body O.f_spawn_objects_from_info)) = true /\
  calls_ident_s O._apply_mario_platform_displacement
    (fn_body O.f_spawn_objects_from_info) = false /\
  calls_ident_s O._update_mario_platform
    (fn_body O.f_spawn_objects_from_info) = false /\
  field_mentioners O.prog O._parentObj = [] /\
  field_mentioners O.prog O._prevObj = [] /\
  field_mentioners O.prog O._platform = [] /\
  field_mentioners O.prog O._collidedObjs = [] /\
  field_mentioners O.prog O._asObject = [].

Theorem spawn_objects_from_info_linked_object_owned_audit_holds :
  spawn_objects_from_info_linked_object_owned_audit.
Proof.
  unfold spawn_objects_from_info_linked_object_owned_audit.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition active_collided_object_origins_after_count
    (count : nat) (origins : list object_reference_origin)
    : list object_reference_origin :=
  firstn count origins.

Definition object_owned_observations_from_origins
    (parent prev platform : object_reference_origin)
    (active_collided raw_as_object : list object_reference_origin)
    : root_origin_observations :=
  [(RootObjectParentObj, parent);
   (RootObjectPrevObj, prev);
   (RootObjectPlatform, platform)] ++
  map (fun origin => (RootObjectCollidedObjs, origin)) active_collided ++
  map (fun origin => (RootObjectRawDataAsObject, origin)) raw_as_object.

Definition freshly_allocated_destination_object_owned_observations
    (allocated_slot : Z)
    (stale_collided_storage : list object_reference_origin)
    : root_origin_observations :=
  object_owned_observations_from_origins
    (OtherObjectReference allocated_slot)
    NoObjectReference
    NoObjectReference
    (active_collided_object_origins_after_count 0 stale_collided_storage)
    [NoObjectReference].

Theorem freshly_allocated_destination_object_owned_epoch_invariant :
  forall before pool_block allocated_slot stale_collided_storage,
    object_owned_root_epoch_invariant before pool_block
      (freshly_allocated_destination_object_owned_observations
         allocated_slot stale_collided_storage).
Proof.
  intros before pool_block allocated_slot stale_collided_storage.
  unfold object_owned_root_epoch_invariant,
    root_origin_observations_have_no_outside_epoch,
    freshly_allocated_destination_object_owned_observations,
    object_owned_observations_from_origins,
    active_collided_object_origins_after_count.
  simpl.
  intros root origin slot _ Hobs _ Horigin.
  repeat
    (destruct Hobs as [Hobs | Hobs];
     [inversion Hobs; subst origin; discriminate |]).
  contradiction.
Qed.

Theorem freshly_allocated_destination_object_owned_roots_do_not_survive :
  forall before pool_block allocated_slot stale_collided_storage,
    ~ root_origin_observations_have_survivor before pool_block
        object_owned_high_risk_roots
        (freshly_allocated_destination_object_owned_observations
           allocated_slot stale_collided_storage).
Proof.
  intros before pool_block allocated_slot stale_collided_storage.
  apply object_owned_root_epoch_invariant_eliminates_survivors.
  apply freshly_allocated_destination_object_owned_epoch_invariant.
Qed.

Theorem object_owned_observations_clean_or_counterexample :
  forall before pool_block observations,
    object_owned_root_epoch_invariant before pool_block observations \/
    root_origin_observations_have_survivor
      before pool_block object_owned_high_risk_roots observations ->
    (~ root_origin_observations_have_survivor
        before pool_block object_owned_high_risk_roots observations) \/
    exists root origin,
      In (root, origin) observations /\
      persistent_outside_pointer_counterexample_candidate before pool_block
        {| observed_pointer_root := root;
           observed_pointer_origin := origin |}.
Proof.
  intros before pool_block observations Houtcome.
  destruct Houtcome as [Hclean | Hsurvivor].
  - left.
    apply object_owned_root_epoch_invariant_eliminates_survivors.
    exact Hclean.
  - right.
    apply object_owned_root_origin_survivor_is_counterexample_candidate.
    exact Hsurvivor.
Qed.

Definition graph_or_render_root_epoch_invariant
    (before : mem) (pool_block : block)
    (observations : root_origin_observations) : Prop :=
  root_origin_observations_have_no_outside_epoch
    before pool_block graph_and_render_high_risk_roots observations.

Theorem graph_or_render_root_epoch_invariant_eliminates_survivors :
  forall before pool_block observations,
    graph_or_render_root_epoch_invariant before pool_block observations ->
    ~ root_origin_observations_have_survivor
        before pool_block graph_and_render_high_risk_roots observations.
Proof.
  intros before pool_block observations Hclean.
  apply clean_root_origin_observations_eliminate_survivors.
  exact Hclean.
Qed.

Definition render_held_objnode_origin_after_post_init
    (destination_spawn_slot : Z) : object_reference_origin :=
  ref_held_object (post_reinit_refs destination_spawn_slot).

Definition render_held_post_init_observations
    (destination_spawn_slot : Z) : root_origin_observations :=
  [(RootGraphHeldObjectObjNode,
    render_held_objnode_origin_after_post_init destination_spawn_slot)].

Theorem render_held_objnode_origin_after_post_init_is_no_object :
  forall destination_spawn_slot,
    render_held_objnode_origin_after_post_init destination_spawn_slot =
    NoObjectReference.
Proof.
  intros destination_spawn_slot.
  vm_compute.
  reflexivity.
Qed.

Theorem render_held_objnode_origin_after_post_init_has_no_outside_epoch :
  forall before pool_block destination_spawn_slot,
    ~ origin_mentions_outside_epoch before pool_block
        (render_held_objnode_origin_after_post_init destination_spawn_slot).
Proof.
  intros before pool_block destination_spawn_slot Hsurvivor.
  destruct Hsurvivor as (slot & _ & Horigin).
  rewrite render_held_objnode_origin_after_post_init_is_no_object in Horigin.
  discriminate.
Qed.

Theorem render_held_post_init_observations_have_no_survivor :
  forall before pool_block destination_spawn_slot,
    ~ root_origin_observations_have_survivor before pool_block
        [RootGraphHeldObjectObjNode]
        (render_held_post_init_observations destination_spawn_slot).
Proof.
  intros before pool_block destination_spawn_slot.
  apply clean_root_origin_observations_eliminate_survivors.
  unfold root_origin_observations_have_no_outside_epoch,
    render_held_post_init_observations.
  intros root origin slot Hroot Hobs _ Horigin.
  destruct Hroot as [Hroot | Hroot]; [subst root | contradiction].
  destruct Hobs as [Hobs | Hobs]; [inversion Hobs; subst origin | contradiction].
  unfold render_held_objnode_origin_after_post_init, post_reinit_refs in *.
  simpl in *.
  discriminate.
Qed.

Theorem graph_confinement_eliminates_reachable_outside_graph_node :
  forall (graph_node_id : Type)
    (links : graph_links graph_node_id)
    (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root root outside_node,
    @generated_load_area_graph_traversals_confined graph_node_id
      links current_or_destination
      object_parent_first_child current_area_root ->
    In root
      (@generated_load_area_graph_roots graph_node_id
         object_parent_first_child current_area_root) ->
    @graph_link_reachable graph_node_id links root outside_node ->
    ~ current_or_destination outside_node ->
    False.
Proof.
  intros graph_node_id links current_or_destination object_parent_first_child
    current_area_root root outside_node Hconfined Hroot Hreachable Houtside.
  apply Houtside.
  exact (Hconfined root Hroot outside_node Hreachable).
Qed.

Definition channel_side_survivor_elimination_certificate : Prop :=
  proposition_of object_owned_root_epoch_invariant_eliminates_survivors /\
  proposition_of object_owned_root_origin_survivor_is_counterexample_candidate /\
  proposition_of allocate_object_object_owned_root_init_audit_holds /\
  proposition_of spawn_objects_from_info_linked_object_owned_audit_holds /\
  proposition_of freshly_allocated_destination_object_owned_roots_do_not_survive /\
  proposition_of object_owned_observations_clean_or_counterexample /\
  proposition_of graph_or_render_root_epoch_invariant_eliminates_survivors /\
  proposition_of graph_or_render_root_origin_survivor_is_counterexample_candidate /\
  proposition_of render_held_objnode_origin_after_post_init_is_no_object /\
  proposition_of render_held_post_init_observations_have_no_survivor /\
  proposition_of graph_confinement_eliminates_reachable_outside_graph_node /\
  proposition_of generated_graph_traversal_confinement_or_counterexample_candidate /\
  proposition_of mario_platform_helper_precleanup_boundary_holds.

Theorem channel_side_survivor_elimination_certificate_holds :
  channel_side_survivor_elimination_certificate.
Proof.
  unfold channel_side_survivor_elimination_certificate, proposition_of.
  repeat split;
    first
      [ exact object_owned_root_epoch_invariant_eliminates_survivors
      | exact object_owned_root_origin_survivor_is_counterexample_candidate
      | exact allocate_object_object_owned_root_init_audit_holds
      | exact spawn_objects_from_info_linked_object_owned_audit_holds
      | exact freshly_allocated_destination_object_owned_roots_do_not_survive
      | exact object_owned_observations_clean_or_counterexample
      | exact graph_or_render_root_epoch_invariant_eliminates_survivors
      | exact graph_or_render_root_origin_survivor_is_counterexample_candidate
      | exact render_held_objnode_origin_after_post_init_is_no_object
      | exact render_held_post_init_observations_have_no_survivor
      | exact graph_confinement_eliminates_reachable_outside_graph_node
      | exact generated_graph_traversal_confinement_or_counterexample_candidate
      | exact mario_platform_helper_precleanup_boundary_holds ].
Qed.

Definition shell_and_grabbable_stale_channel_load_window_audit : Prop :=
  proposition_of
    outside_pyramid_channel_classifications_start_with_shell /\
  proposition_of shell_channel_generated_ridden_object_evidence /\
  proposition_of direct_grabbable_channel_mario_reference_cleanup_evidence /\
  audited_mario_stale_ref_no_observation_before_cleanup.

Theorem shell_and_grabbable_stale_channel_load_window_audit_holds :
  shell_and_grabbable_stale_channel_load_window_audit.
Proof.
  unfold shell_and_grabbable_stale_channel_load_window_audit,
    proposition_of.
  split; [exact outside_pyramid_channel_classifications_start_with_shell |].
  split; [exact shell_channel_generated_ridden_object_evidence |].
  split; [exact direct_grabbable_channel_mario_reference_cleanup_evidence |].
  exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.
