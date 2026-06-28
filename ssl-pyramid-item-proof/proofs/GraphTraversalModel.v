(* Abstract graph-traversal model for the typed GraphNode audit.

   TransitionFacts pins the generated-code side:

   - load_area directly has no generic GraphNode parent/children/prev/next
     field access;
   - load_area calls load_obj_warp_nodes and geo_call_global_function_nodes;
   - load_obj_warp_nodes reads GraphNode.children, GraphNode.next, children;
   - geo_call_global_function_nodes and its helper walk children/next links.

   This file packages the semantic shape that remains.  The generated graph
   traversals are safe exactly when the graph roots they start from are already
   confined to the current/destination tree and child/next links preserve that
   confinement.  If an outside GraphNode survives and is reachable from those
   roots, that is a concrete counterexample candidate for the stale-window
   investigation rather than a boring no-observation fact.
 *)

From Coq Require Import Classical List.
Import ListNotations.
From compcert Require Import Clight.
From SSLPyramid.Proofs Require Import ASTFacts TransitionFacts.

Theorem geo_call_global_function_nodes_typed_graph_node_link_fields :
  statement_graph_node_link_fields_s
    (fn_body G.f_geo_call_global_function_nodes) =
  [G._children; G._children].
Proof. vm_compute; reflexivity. Qed.

Theorem geo_call_global_function_nodes_helper_typed_graph_node_link_fields :
  statement_graph_node_link_fields_s
    (fn_body G.f_geo_call_global_function_nodes_helper) =
  [G._children; G._children; G._next].
Proof. vm_compute; reflexivity. Qed.

Definition generated_graph_traversal_audit : Prop :=
  statement_graph_node_link_fields_s (fn_body A.f_load_area) = [] /\
  statement_graph_node_link_fields_s (fn_body A.f_load_obj_warp_nodes) =
    [G._children; G._next; G._children] /\
  event_subsequenceb
    [Event_call A._load_obj_warp_nodes;
     Event_call A._geo_call_global_function_nodes]
    (statement_events_s (fn_body A.f_load_area)) = true /\
  statement_graph_node_link_fields_s
    (fn_body G.f_geo_call_global_function_nodes) =
    [G._children; G._children] /\
  statement_graph_node_link_fields_s
    (fn_body G.f_geo_call_global_function_nodes_helper) =
    [G._children; G._children; G._next] /\
  graph_node_link_field_mentioners G.prog =
    [G._init_scene_graph_node_links;
     G._geo_add_child;
     G._geo_remove_child;
     G._geo_make_first_child;
     G._geo_call_global_function_nodes_helper;
     G._geo_call_global_function_nodes;
     G._geo_find_root].

Theorem generated_graph_traversal_audit_holds :
  generated_graph_traversal_audit.
Proof.
  repeat split;
    first
      [ exact load_area_direct_typed_graph_node_link_fields
      | exact load_obj_warp_nodes_typed_graph_node_link_fields
      | exact load_area_calls_graph_node_link_traversal_helpers
      | exact geo_call_global_function_nodes_typed_graph_node_link_fields
      | exact geo_call_global_function_nodes_helper_typed_graph_node_link_fields
      | exact graph_node_typed_graph_node_link_field_mentioners ].
Qed.

Theorem unload_object_graph_relink_call_order :
  event_subsequenceb
    [Event_call S._geo_remove_child;
     Event_call S._geo_add_child;
     Event_call S._deallocate_object]
    (statement_events_s (fn_body S.f_unload_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem try_allocate_object_graph_relink_call_order :
  event_subsequenceb
    [Event_call S._geo_remove_child;
     Event_call S._geo_add_child]
    (statement_events_s (fn_body S.f_try_allocate_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem allocate_object_retry_relink_call_order :
  event_subsequenceb
    [Event_call S._try_allocate_object;
     Event_call S._unload_object;
     Event_call S._try_allocate_object]
    (statement_events_s (fn_body S.f_allocate_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem load_area_builds_destination_graph_before_traversal :
  event_subsequenceb
    [Event_call A._spawn_objects_from_info;
     Event_call A._load_obj_warp_nodes;
     Event_call A._geo_call_global_function_nodes]
    (statement_events_s (fn_body A.f_load_area)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem geo_remove_child_relink_shape_audit :
  direct_callees_s (fn_body G.f_geo_remove_child) = [] /\
  event_subsequenceb
    [Event_set_temp_from_field G._parent G._graphNode G._parent;
     Event_set_temp_from_field G._t'6 G._graphNode G._prev;
     Event_set_temp_from_field G._t'7 G._graphNode G._next;
     Event_assign_field_from_temp G._next G._t'7;
     Event_set_temp_from_field G._t'4 G._graphNode G._next;
     Event_set_temp_from_field G._t'5 G._graphNode G._prev;
     Event_assign_field_from_temp G._prev G._t'5]
    (statement_events_s (fn_body G.f_geo_remove_child)) = true /\
  assigns_through_temp_s G._firstChild
    (fn_body G.f_geo_remove_child) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem geo_add_child_relink_shape_audit :
  direct_callees_s (fn_body G.f_geo_add_child) = [] /\
  event_subsequenceb
    [Event_assign_field_from_temp G._parent G._parent;
     Event_set_temp_from_field G._parentFirstChild G._parent G._children;
     Event_assign_field_from_temp G._children G._childNode]
    (statement_events_s (fn_body G.f_geo_add_child)) = true /\
  event_subsequenceb
    [Event_assign_field_from_temp G._prev G._parentLastChild;
     Event_assign_field_from_temp G._next G._parentFirstChild;
     Event_assign_field_from_temp G._prev G._childNode;
     Event_assign_field_from_temp G._next G._childNode]
    (statement_events_s (fn_body G.f_geo_add_child)) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition generated_unload_load_graph_relink_audit : Prop :=
  event_subsequenceb
    [Event_call S._geo_remove_child;
     Event_call S._geo_add_child;
     Event_call S._deallocate_object]
    (statement_events_s (fn_body S.f_unload_object)) = true /\
  event_subsequenceb
    [Event_call S._geo_remove_child;
     Event_call S._geo_add_child]
    (statement_events_s (fn_body S.f_try_allocate_object)) = true /\
  event_subsequenceb
    [Event_call S._try_allocate_object;
     Event_call S._unload_object;
     Event_call S._try_allocate_object]
    (statement_events_s (fn_body S.f_allocate_object)) = true /\
  event_subsequenceb
    [Event_call A._spawn_objects_from_info;
     Event_call A._load_obj_warp_nodes;
     Event_call A._geo_call_global_function_nodes]
    (statement_events_s (fn_body A.f_load_area)) = true /\
  direct_callees_s (fn_body G.f_geo_remove_child) = [] /\
  direct_callees_s (fn_body G.f_geo_add_child) = [].

Theorem generated_unload_load_graph_relink_audit_holds :
  generated_unload_load_graph_relink_audit.
Proof.
  repeat split;
    first
      [ exact unload_object_graph_relink_call_order
      | exact try_allocate_object_graph_relink_call_order
      | exact allocate_object_retry_relink_call_order
      | exact load_area_builds_destination_graph_before_traversal
      | destruct geo_remove_child_relink_shape_audit as [H _]; exact H
      | destruct geo_add_child_relink_shape_audit as [H _]; exact H ].
Qed.

Section AbstractGraph.

Variable graph_node_id : Type.

Record graph_links := {
  graph_child : graph_node_id -> option graph_node_id;
  graph_next : graph_node_id -> option graph_node_id
}.

Inductive graph_link_step
    (links : graph_links) : graph_node_id -> graph_node_id -> Prop :=
| GraphChildStep :
    forall from to,
      graph_child links from = Some to ->
      graph_link_step links from to
| GraphNextStep :
    forall from to,
      graph_next links from = Some to ->
      graph_link_step links from to.

Inductive graph_link_reachable
    (links : graph_links) : graph_node_id -> graph_node_id -> Prop :=
| GraphReachHere :
    forall root,
      graph_link_reachable links root root
| GraphReachStep :
    forall root mid target,
      graph_link_step links root mid ->
      graph_link_reachable links mid target ->
      graph_link_reachable links root target.

Definition graph_links_preserve
    (links : graph_links) (current_or_destination : graph_node_id -> Prop)
    : Prop :=
  forall from to,
    current_or_destination from ->
    graph_link_step links from to ->
    current_or_destination to.

Definition graph_traversal_confined
    (links : graph_links) (current_or_destination : graph_node_id -> Prop)
    (root : graph_node_id) : Prop :=
  forall node,
    graph_link_reachable links root node ->
    current_or_destination node.

Definition generated_load_area_graph_roots
    (object_parent_first_child current_area_root : graph_node_id)
    : list graph_node_id :=
  [object_parent_first_child; current_area_root].

Definition generated_load_area_graph_traversals_confined
    (links : graph_links) (current_or_destination : graph_node_id -> Prop)
    (object_parent_first_child current_area_root : graph_node_id) : Prop :=
  forall root,
    In root
      (generated_load_area_graph_roots
         object_parent_first_child current_area_root) ->
    graph_traversal_confined links current_or_destination root.

Definition generated_roots_exclude_node
    (object_parent_first_child current_area_root removed : graph_node_id)
    : Prop :=
  object_parent_first_child <> removed /\
  current_area_root <> removed.

Definition generated_root_reachability_preserved_or_new_current
    (before after : graph_links)
    (current_or_destination : graph_node_id -> Prop)
    (object_parent_first_child current_area_root : graph_node_id) : Prop :=
  forall root node,
    In root
      (generated_load_area_graph_roots
         object_parent_first_child current_area_root) ->
    graph_link_reachable after root node ->
    graph_link_reachable before root node \/ current_or_destination node.

Definition generated_root_reachability_after_remove
    (before after : graph_links)
    (object_parent_first_child current_area_root removed : graph_node_id)
    : Prop :=
  forall root node,
    In root
      (generated_load_area_graph_roots
         object_parent_first_child current_area_root) ->
    graph_link_reachable after root node ->
    node <> removed /\ graph_link_reachable before root node.

Definition generated_root_reachability_after_add_current
    (before after : graph_links)
    (current_or_destination : graph_node_id -> Prop)
    (object_parent_first_child current_area_root : graph_node_id) : Prop :=
  forall root node,
    In root
      (generated_load_area_graph_roots
         object_parent_first_child current_area_root) ->
    graph_link_reachable after root node ->
    graph_link_reachable before root node \/ current_or_destination node.

Record geo_remove_child_graph_effect
    (before after : graph_links) (removed : graph_node_id) : Prop := {
  geo_remove_child_after_step_old_or_skip :
    forall from to,
      graph_link_step after from to ->
      graph_link_step before from to \/
      (graph_link_step before from removed /\
       graph_link_step before removed to);
  geo_remove_child_no_new_incoming_to_removed :
    forall from,
      from <> removed ->
      ~ graph_link_step after from removed
}.

Record geo_add_child_graph_effect
    (before after : graph_links)
    (parent child : graph_node_id) : Prop := {
  geo_add_child_after_step_old_or_insert :
    forall from to,
      graph_link_step after from to ->
      graph_link_step before from to \/
      (from = parent /\ to = child) \/
      (from = child /\
       (to = child \/ graph_link_reachable before parent to)) \/
      (graph_link_reachable before parent from /\ to = child)
}.

Record geo_remove_child_semantic_execution
    (before after : graph_links) (removed : graph_node_id) : Prop := {
  geo_remove_child_execution_generated_body :
    direct_callees_s (fn_body G.f_geo_remove_child) = [] /\
    event_subsequenceb
      [Event_set_temp_from_field G._parent G._graphNode G._parent;
       Event_set_temp_from_field G._t'6 G._graphNode G._prev;
       Event_set_temp_from_field G._t'7 G._graphNode G._next;
       Event_assign_field_from_temp G._next G._t'7;
       Event_set_temp_from_field G._t'4 G._graphNode G._next;
       Event_set_temp_from_field G._t'5 G._graphNode G._prev;
       Event_assign_field_from_temp G._prev G._t'5]
      (statement_events_s (fn_body G.f_geo_remove_child)) = true /\
    assigns_through_temp_s G._firstChild
      (fn_body G.f_geo_remove_child) = true;
  geo_remove_child_execution_graph_effect :
    geo_remove_child_graph_effect before after removed
}.

Record geo_add_child_semantic_execution
    (before after : graph_links)
    (parent child : graph_node_id) : Prop := {
  geo_add_child_execution_generated_body :
    direct_callees_s (fn_body G.f_geo_add_child) = [] /\
    event_subsequenceb
      [Event_assign_field_from_temp G._parent G._parent;
       Event_set_temp_from_field G._parentFirstChild G._parent G._children;
       Event_assign_field_from_temp G._children G._childNode]
      (statement_events_s (fn_body G.f_geo_add_child)) = true /\
    event_subsequenceb
      [Event_assign_field_from_temp G._prev G._parentLastChild;
       Event_assign_field_from_temp G._next G._parentFirstChild;
       Event_assign_field_from_temp G._prev G._childNode;
       Event_assign_field_from_temp G._next G._childNode]
      (statement_events_s (fn_body G.f_geo_add_child)) = true;
  geo_add_child_execution_graph_effect :
    geo_add_child_graph_effect before after parent child
}.

Lemma graph_link_reachable_preserves :
  forall links (current_or_destination : graph_node_id -> Prop) root node,
    current_or_destination root ->
    graph_links_preserve links current_or_destination ->
    graph_link_reachable links root node ->
    current_or_destination node.
Proof.
  intros links current_or_destination root node Hroot Hpres Hreach.
  revert Hroot.
  induction Hreach as [root' | root' mid target Hstep _ IH].
  - intros Hroot.
    exact Hroot.
  - intros Hroot.
    apply IH.
    eapply Hpres; eauto.
Qed.

Theorem geo_remove_child_semantic_execution_from_graph_effect :
  forall before after removed,
    geo_remove_child_graph_effect before after removed ->
    geo_remove_child_semantic_execution before after removed.
Proof.
  intros before after removed Heffect.
  split.
  - exact geo_remove_child_relink_shape_audit.
  - exact Heffect.
Qed.

Theorem geo_add_child_semantic_execution_from_graph_effect :
  forall before after parent child,
    geo_add_child_graph_effect before after parent child ->
    geo_add_child_semantic_execution before after parent child.
Proof.
  intros before after parent child Heffect.
  split.
  - exact geo_add_child_relink_shape_audit.
  - exact Heffect.
Qed.

Lemma geo_remove_child_graph_effect_preserves_links :
  forall before after (current_or_destination : graph_node_id -> Prop)
    removed,
    graph_links_preserve before current_or_destination ->
    geo_remove_child_graph_effect before after removed ->
    graph_links_preserve after current_or_destination.
Proof.
  intros before after current_or_destination removed Hbefore Hremove
    from to Hfrom Hstep.
  destruct Hremove as [Hedge _].
  destruct (Hedge from to Hstep) as [Hold | [Hfrom_removed Hremoved_to]].
  - eapply Hbefore; eauto.
  - eapply Hbefore.
    + eapply Hbefore; eauto.
    + exact Hremoved_to.
Qed.

Lemma geo_remove_child_reachability_skips_removed :
  forall before after removed start target,
    geo_remove_child_graph_effect before after removed ->
    start <> removed ->
    graph_link_reachable after start target ->
    target <> removed /\ graph_link_reachable before start target.
Proof.
  intros before after removed start target Hremove Hstart Hreach.
  destruct Hremove as [Hedge Hno_incoming].
  revert Hstart.
  induction Hreach as [root | root mid target Hstep _ IH].
  - intros Hroot.
    split.
    + exact Hroot.
    + constructor.
  - intros Hroot.
    assert (Hmid : mid <> removed).
    { intro Hmid.
      subst mid.
      exact (Hno_incoming root Hroot Hstep). }
    destruct (IH Hmid) as [Htarget Hbefore_tail].
    destruct (Hedge root mid Hstep) as
      [Hold | [Hroot_removed Hremoved_mid]].
    + split.
      * exact Htarget.
      * eapply GraphReachStep.
        -- exact Hold.
        -- exact Hbefore_tail.
    + split.
      * exact Htarget.
      * eapply GraphReachStep.
        -- exact Hroot_removed.
        -- eapply GraphReachStep.
           ++ exact Hremoved_mid.
           ++ exact Hbefore_tail.
Qed.

Theorem geo_remove_child_semantic_execution_satisfies_reachability_after_remove :
  forall before after object_parent_first_child current_area_root removed,
    generated_roots_exclude_node
      object_parent_first_child current_area_root removed ->
    geo_remove_child_semantic_execution before after removed ->
    generated_root_reachability_after_remove
      before after object_parent_first_child current_area_root removed.
Proof.
  intros before after object_parent_first_child current_area_root removed
    [Hobject_root Hcurrent_root] Hexec root node Hroot Hreach.
  destruct Hexec as [_ Heffect].
  assert (Hroot_not_removed : root <> removed).
  { destruct Hroot as [Hroot | [Hroot | Hroot]].
    - subst root. exact Hobject_root.
    - subst root. exact Hcurrent_root.
    - contradiction.
  }
  exact
    (geo_remove_child_reachability_skips_removed
       before after removed root node Heffect Hroot_not_removed Hreach).
Qed.

Lemma geo_add_child_graph_effect_preserves_links :
  forall before after (current_or_destination : graph_node_id -> Prop)
    parent child,
    graph_links_preserve before current_or_destination ->
    current_or_destination parent ->
    current_or_destination child ->
    geo_add_child_graph_effect before after parent child ->
    graph_links_preserve after current_or_destination.
Proof.
  intros before after current_or_destination parent child
    Hbefore Hparent Hchild Hadd from to Hfrom Hstep.
  destruct Hadd as [Hedge].
  destruct (Hedge from to Hstep) as
    [Hold |
     [[Hfrom_parent Hto_child] |
      [[Hfrom_child [Hto_child | Hparent_to]] |
       [Hparent_from Hto_child]]]].
  - eapply Hbefore; eauto.
  - subst to.
    exact Hchild.
  - subst to.
    exact Hchild.
  - eapply graph_link_reachable_preserves.
    + exact Hparent.
    + exact Hbefore.
    + exact Hparent_to.
  - subst to.
    exact Hchild.
Qed.

Theorem geo_add_child_semantic_execution_satisfies_reachability_after_add_current :
  forall before after (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root parent child,
    generated_load_area_graph_traversals_confined
      before current_or_destination
      object_parent_first_child current_area_root ->
    graph_links_preserve before current_or_destination ->
    current_or_destination parent ->
    current_or_destination child ->
    geo_add_child_semantic_execution before after parent child ->
    generated_root_reachability_after_add_current
      before after current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros before after current_or_destination object_parent_first_child
    current_area_root parent child Hbefore Hpres Hparent Hchild Hexec
    root node Hroot Hreach.
  destruct Hexec as [_ Heffect].
  right.
  eapply graph_link_reachable_preserves.
  - exact (Hbefore root Hroot root (@GraphReachHere before root)).
  - exact
      (geo_add_child_graph_effect_preserves_links
         before after current_or_destination parent child
         Hpres Hparent Hchild Heffect).
  - exact Hreach.
Qed.

Theorem generated_graph_traversals_confined_under_root_closure :
  forall links (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root,
    current_or_destination object_parent_first_child ->
    current_or_destination current_area_root ->
    graph_links_preserve links current_or_destination ->
    generated_load_area_graph_traversals_confined
      links current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros links current_or_destination object_parent_first_child
    current_area_root Hobject_root Hcurrent_root Hpres root Hin node Hreach.
  destruct Hin as [Hroot | [Hroot | Hin]].
  - subst root.
    eapply graph_link_reachable_preserves.
    + exact Hobject_root.
    + exact Hpres.
    + exact Hreach.
  - subst root.
    eapply graph_link_reachable_preserves.
    + exact Hcurrent_root.
    + exact Hpres.
    + exact Hreach.
  - contradiction.
Qed.

Theorem generated_graph_confinement_after_relink_effect :
  forall before after (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root,
    generated_load_area_graph_traversals_confined
      before current_or_destination
      object_parent_first_child current_area_root ->
    generated_root_reachability_preserved_or_new_current
      before after current_or_destination
      object_parent_first_child current_area_root ->
    generated_load_area_graph_traversals_confined
      after current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros before after current_or_destination object_parent_first_child
    current_area_root Hbefore Heffect root Hroot node Hreach.
  destruct (Heffect root node Hroot Hreach) as [Hold | Hnew].
  - exact (Hbefore root Hroot node Hold).
  - exact Hnew.
Qed.

Theorem geo_remove_child_effect_preserves_generated_confinement :
  forall before after (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root removed,
    generated_load_area_graph_traversals_confined
      before current_or_destination
      object_parent_first_child current_area_root ->
    generated_root_reachability_after_remove
      before after object_parent_first_child current_area_root removed ->
    generated_load_area_graph_traversals_confined
      after current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros before after current_or_destination object_parent_first_child
    current_area_root removed Hbefore Hremove.
  eapply generated_graph_confinement_after_relink_effect.
  - exact Hbefore.
  - intros root node Hroot Hreach.
    destruct (Hremove root node Hroot Hreach) as (_ & Hold).
    left. exact Hold.
Qed.

Theorem geo_add_child_current_destination_effect_preserves_generated_confinement :
  forall before after (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root,
    generated_load_area_graph_traversals_confined
      before current_or_destination
      object_parent_first_child current_area_root ->
    generated_root_reachability_after_add_current
      before after current_or_destination
      object_parent_first_child current_area_root ->
    generated_load_area_graph_traversals_confined
      after current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros before after current_or_destination object_parent_first_child
    current_area_root Hbefore Hadd.
  eapply generated_graph_confinement_after_relink_effect; eauto.
Qed.

Theorem unload_load_relink_effects_confine_generated_traversal :
  forall before_unload after_unload after_load
    (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root removed,
    generated_load_area_graph_traversals_confined
      before_unload current_or_destination
      object_parent_first_child current_area_root ->
    generated_root_reachability_after_remove
      before_unload after_unload
      object_parent_first_child current_area_root removed ->
    generated_root_reachability_after_add_current
      after_unload after_load current_or_destination
      object_parent_first_child current_area_root ->
    generated_load_area_graph_traversals_confined
      after_load current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros before_unload after_unload after_load current_or_destination
    object_parent_first_child current_area_root removed Hbefore
    Hremove Hadd.
  eapply geo_add_child_current_destination_effect_preserves_generated_confinement.
  - eapply geo_remove_child_effect_preserves_generated_confinement; eauto.
  - exact Hadd.
Qed.

Theorem generated_relink_semantic_executions_confine_traversal :
  forall before_unload after_remove after_add
    (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root removed
    add_parent add_child,
    generated_load_area_graph_traversals_confined
      before_unload current_or_destination
      object_parent_first_child current_area_root ->
    graph_links_preserve before_unload current_or_destination ->
    generated_roots_exclude_node
      object_parent_first_child current_area_root removed ->
    geo_remove_child_semantic_execution
      before_unload after_remove removed ->
    current_or_destination add_parent ->
    current_or_destination add_child ->
    geo_add_child_semantic_execution
      after_remove after_add add_parent add_child ->
    generated_load_area_graph_traversals_confined
      after_add current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros before_unload after_remove after_add current_or_destination
    object_parent_first_child current_area_root removed
    add_parent add_child Hbefore Hpres Hroots Hremove_exec
    Hadd_parent Hadd_child Hadd_exec.
  assert (Hremove_post :
    generated_root_reachability_after_remove
      before_unload after_remove
      object_parent_first_child current_area_root removed).
  { exact
      (geo_remove_child_semantic_execution_satisfies_reachability_after_remove
         before_unload after_remove object_parent_first_child
         current_area_root removed Hroots Hremove_exec). }
  assert (Hafter_remove_confined :
    generated_load_area_graph_traversals_confined
      after_remove current_or_destination
      object_parent_first_child current_area_root).
  { exact
      (geo_remove_child_effect_preserves_generated_confinement
         before_unload after_remove current_or_destination
         object_parent_first_child current_area_root removed
         Hbefore Hremove_post). }
  assert (Hafter_remove_preserve :
    graph_links_preserve after_remove current_or_destination).
  { destruct Hremove_exec as [_ Hremove_effect].
    exact
      (geo_remove_child_graph_effect_preserves_links
         before_unload after_remove current_or_destination removed
         Hpres Hremove_effect). }
  assert (Hadd_post :
    generated_root_reachability_after_add_current
      after_remove after_add current_or_destination
      object_parent_first_child current_area_root).
  { exact
      (geo_add_child_semantic_execution_satisfies_reachability_after_add_current
         after_remove after_add current_or_destination
         object_parent_first_child current_area_root add_parent add_child
         Hafter_remove_confined Hafter_remove_preserve
         Hadd_parent Hadd_child Hadd_exec). }
  exact
    (geo_add_child_current_destination_effect_preserves_generated_confinement
       after_remove after_add current_or_destination
       object_parent_first_child current_area_root
       Hafter_remove_confined Hadd_post).
Qed.

Definition graph_link_counterexample_candidate
    (links : graph_links) (current_or_destination : graph_node_id -> Prop)
    (object_parent_first_child current_area_root : graph_node_id) : Prop :=
  exists counterexample_graph_root counterexample_graph_node,
    In counterexample_graph_root
      (generated_load_area_graph_roots
         object_parent_first_child current_area_root) /\
    graph_link_reachable links
      counterexample_graph_root counterexample_graph_node /\
    ~ current_or_destination counterexample_graph_node.

Theorem surviving_outside_graph_link_is_counterexample_candidate :
  forall links (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root root outside_node,
    In root
      (generated_load_area_graph_roots
         object_parent_first_child current_area_root) ->
    graph_link_reachable links root outside_node ->
    ~ current_or_destination outside_node ->
    graph_link_counterexample_candidate
      links current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros links current_or_destination object_parent_first_child
    current_area_root root outside_node Hroot Hreachable Houtside.
  exists root, outside_node.
  repeat split; assumption.
Qed.

Theorem generated_graph_traversal_confinement_or_counterexample_candidate :
  forall links (current_or_destination : graph_node_id -> Prop)
    object_parent_first_child current_area_root,
    generated_load_area_graph_traversals_confined
      links current_or_destination
      object_parent_first_child current_area_root \/
    graph_link_counterexample_candidate
      links current_or_destination
      object_parent_first_child current_area_root.
Proof.
  intros links current_or_destination
    object_parent_first_child current_area_root.
  unfold generated_load_area_graph_traversals_confined,
    graph_traversal_confined.
  destruct
    (classic
       (forall root,
          In root
            (generated_load_area_graph_roots
               object_parent_first_child current_area_root) ->
          forall node,
            graph_link_reachable links root node ->
            current_or_destination node)) as [Hconfined | Hnot_confined].
  - left. exact Hconfined.
  - right.
    apply not_all_ex_not in Hnot_confined.
    destruct Hnot_confined as (root & Hroot_bad).
    apply imply_to_and in Hroot_bad.
    destruct Hroot_bad as (Hroot & Hnode_bad).
    apply not_all_ex_not in Hnode_bad.
    destruct Hnode_bad as (node & Hnode_bad).
    apply imply_to_and in Hnode_bad.
    destruct Hnode_bad as (Hreachable & Houtside).
    eapply surviving_outside_graph_link_is_counterexample_candidate; eauto.
Qed.

End AbstractGraph.
