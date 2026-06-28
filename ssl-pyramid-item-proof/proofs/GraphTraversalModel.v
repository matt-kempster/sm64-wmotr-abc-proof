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
