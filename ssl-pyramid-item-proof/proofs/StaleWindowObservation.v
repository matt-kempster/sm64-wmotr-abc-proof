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
  OutsideObjectChannels Spec StalePointerModel TransitionFacts.

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
