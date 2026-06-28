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

From Coq Require Import Classical List ZArith.
Import ListNotations.
From compcert Require Import AST Coqlib Ctypes Clight ClightBigstep Errors
  Events Globalenvs Integers Maps Memory Values.
From SSLPyramid.Proofs Require Import ASTFacts TransitionFacts.

Local Open Scope Z_scope.

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

Definition graph_node_ce : composite_env := prog_comp_env G.prog.

Definition graph_node_ge : genv := globalenv G.prog.

Definition generated_graph_node_members : members :=
  match graph_node_ce ! G._GraphNode with
  | Some composite => co_members composite
  | None => nil
  end.

Definition graph_node_prev_field_offset : Z := 4.
Definition graph_node_next_field_offset : Z := 8.
Definition graph_node_parent_field_offset : Z := 12.
Definition graph_node_children_field_offset : Z := 16.

Theorem generated_graph_node_prev_layout :
  field_offset graph_node_ce G._prev generated_graph_node_members =
  OK (graph_node_prev_field_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem generated_graph_node_next_layout :
  field_offset graph_node_ce G._next generated_graph_node_members =
  OK (graph_node_next_field_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem generated_graph_node_parent_layout :
  field_offset graph_node_ce G._parent generated_graph_node_members =
  OK (graph_node_parent_field_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem generated_graph_node_children_layout :
  field_offset graph_node_ce G._children generated_graph_node_members =
  OK (graph_node_children_field_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Definition geo_remove_child_body : statement :=
  fn_body G.f_geo_remove_child.

Definition geo_remove_child_read_parent : statement :=
  match geo_remove_child_body with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_remove_child_after_parent : statement :=
  match geo_remove_child_body with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition geo_remove_child_read_first_child : statement :=
  match geo_remove_child_after_parent with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_remove_child_after_first_child : statement :=
  match geo_remove_child_after_parent with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition geo_remove_child_prev_next_splice : statement :=
  match geo_remove_child_after_first_child with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_remove_child_after_prev_next_splice : statement :=
  match geo_remove_child_after_first_child with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition geo_remove_child_next_prev_splice : statement :=
  match geo_remove_child_after_prev_next_splice with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_remove_child_after_next_prev_splice : statement :=
  match geo_remove_child_after_prev_next_splice with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition geo_remove_child_parent_children_branch : statement :=
  match geo_remove_child_after_next_prev_splice with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_remove_child_return_parent : statement :=
  match geo_remove_child_after_next_prev_splice with
  | Ssequence _ tail => tail
  | body => body
  end.

Theorem geo_remove_child_body_split :
  geo_remove_child_body =
  Ssequence geo_remove_child_read_parent geo_remove_child_after_parent.
Proof. reflexivity. Qed.

Theorem geo_remove_child_after_parent_split :
  geo_remove_child_after_parent =
  Ssequence geo_remove_child_read_first_child
    geo_remove_child_after_first_child.
Proof. reflexivity. Qed.

Theorem geo_remove_child_after_first_child_split :
  geo_remove_child_after_first_child =
  Ssequence geo_remove_child_prev_next_splice
    geo_remove_child_after_prev_next_splice.
Proof. reflexivity. Qed.

Theorem geo_remove_child_after_prev_next_splice_split :
  geo_remove_child_after_prev_next_splice =
  Ssequence geo_remove_child_next_prev_splice
    geo_remove_child_after_next_prev_splice.
Proof. reflexivity. Qed.

Theorem geo_remove_child_after_next_prev_splice_split :
  geo_remove_child_after_next_prev_splice =
  Ssequence geo_remove_child_parent_children_branch
    geo_remove_child_return_parent.
Proof. reflexivity. Qed.

Definition geo_add_child_body : statement :=
  fn_body G.f_geo_add_child.

Definition geo_add_child_top_if : statement :=
  match geo_add_child_body with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_add_child_return_child : statement :=
  match geo_add_child_body with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition geo_add_child_then_branch : statement :=
  match geo_add_child_top_if with
  | Sifthenelse _ then_branch _ => then_branch
  | body => body
  end.

Definition geo_add_child_assign_parent : statement :=
  match geo_add_child_then_branch with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_add_child_after_assign_parent : statement :=
  match geo_add_child_then_branch with
  | Ssequence _ tail => tail
  | body => body
  end.

Definition geo_add_child_read_parent_first_child : statement :=
  match geo_add_child_after_assign_parent with
  | Ssequence head _ => head
  | body => body
  end.

Definition geo_add_child_children_branch : statement :=
  match geo_add_child_after_assign_parent with
  | Ssequence _ tail => tail
  | body => body
  end.

Theorem geo_add_child_body_split :
  geo_add_child_body =
  Ssequence geo_add_child_top_if geo_add_child_return_child.
Proof. reflexivity. Qed.

Theorem geo_add_child_then_branch_split :
  geo_add_child_then_branch =
  Ssequence geo_add_child_assign_parent
    geo_add_child_after_assign_parent.
Proof. reflexivity. Qed.

Theorem geo_add_child_after_assign_parent_split :
  geo_add_child_after_assign_parent =
  Ssequence geo_add_child_read_parent_first_child
    geo_add_child_children_branch.
Proof. reflexivity. Qed.

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

Definition graph_node_pointer : Type := (block * ptrofs)%type.

Definition graph_node_pointer_value (node : graph_node_pointer) : val :=
  Vptr (fst node) (snd node).

Definition graph_node_field_address
    (node : graph_node_pointer) (field_offset : Z) : val :=
  Vptr (fst node) (Ptrofs.add (snd node) (Ptrofs.repr field_offset)).

Definition graph_node_field_load
    (memory : mem) (node : graph_node_pointer) (field_offset : Z)
    : option val :=
  Mem.loadv Mint32 memory (graph_node_field_address node field_offset).

Definition graph_node_field_load_ptr
    (memory : mem) (node : graph_node_pointer) (field_offset : Z)
    : option graph_node_pointer :=
  match graph_node_field_load memory node field_offset with
  | Some (Vptr block offset) => Some (block, offset)
  | _ => None
  end.

Definition graph_node_field_store_value
    (before after : mem) (node : graph_node_pointer)
    (field_offset : Z) (value : val) : Prop :=
  Mem.storev Mint32 before
    (graph_node_field_address node field_offset) value = Some after.

Definition graph_node_field_store_ptr
    (before after : mem) (node : graph_node_pointer)
    (field_offset : Z) (value : graph_node_pointer) : Prop :=
  graph_node_field_store_value before after node field_offset
    (graph_node_pointer_value value).

Definition graph_node_field_store_null
    (before after : mem) (node : graph_node_pointer)
    (field_offset : Z) : Prop :=
  graph_node_field_store_value before after node field_offset (Vint Int.zero).

Lemma graph_node_field_store_ptr_load_same :
  forall before after node field_offset value,
    graph_node_field_store_ptr before after node field_offset value ->
    graph_node_field_load_ptr after node field_offset = Some value.
Proof.
  intros before after [node_block node_offset] field_offset
    [value_block value_offset] Hstore.
  unfold graph_node_field_store_ptr, graph_node_field_store_value,
    graph_node_pointer_value, graph_node_field_load_ptr,
    graph_node_field_load, graph_node_field_address in *.
  cbn in *.
  unfold Mem.storev in Hstore.
  cbn in Hstore.
  rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore).
  reflexivity.
Qed.

Lemma graph_node_field_store_null_load_ptr_none :
  forall before after node field_offset,
    graph_node_field_store_null before after node field_offset ->
    graph_node_field_load_ptr after node field_offset = None.
Proof.
  intros before after [node_block node_offset] field_offset Hstore.
  unfold graph_node_field_store_null, graph_node_field_store_value,
    graph_node_field_load_ptr, graph_node_field_load,
    graph_node_field_address in *.
  cbn in *.
  unfold Mem.storev in Hstore.
  cbn in Hstore.
  rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore).
  reflexivity.
Qed.

Definition concrete_graph_links (memory : mem)
    : graph_links graph_node_pointer :=
  {|
    graph_child := fun node =>
      graph_node_field_load_ptr
        memory node graph_node_children_field_offset;
    graph_next := fun node =>
      graph_node_field_load_ptr
        memory node graph_node_next_field_offset
  |}.

Definition geo_remove_child_exec_spine
    (e : env) (le : temp_env) (memory : mem)
    (trace : trace) (le' : temp_env) (memory' : mem)
    (outcome : outcome) : Prop :=
  exists trace_parent le_parent memory_parent
         trace_first le_first memory_first
         trace_prev_next le_prev_next memory_prev_next
         trace_next_prev le_next_prev memory_next_prev
         trace_children le_children memory_children
         trace_return,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_read_parent
      trace_parent le_parent memory_parent Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_parent memory_parent
      geo_remove_child_read_first_child
      trace_first le_first memory_first Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_first memory_first
      geo_remove_child_prev_next_splice
      trace_prev_next le_prev_next memory_prev_next Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_prev_next memory_prev_next
      geo_remove_child_next_prev_splice
      trace_next_prev le_next_prev memory_next_prev Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_next_prev memory_next_prev
      geo_remove_child_parent_children_branch
      trace_children le_children memory_children Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_children memory_children
      geo_remove_child_return_parent
      trace_return le' memory' outcome.

Definition geo_add_child_body_exec_spine
    (e : env) (le : temp_env) (memory : mem)
    (trace : trace) (le' : temp_env) (memory' : mem)
    (outcome : outcome) : Prop :=
  exists trace_top le_top memory_top trace_return,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_top_if trace_top le_top memory_top Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_top memory_top
      geo_add_child_return_child trace_return le' memory' outcome.

Definition geo_add_child_then_branch_exec_spine
    (e : env) (le : temp_env) (memory : mem)
    (trace : trace) (le' : temp_env) (memory' : mem)
    (outcome : outcome) : Prop :=
  exists trace_parent le_parent memory_parent
         trace_first le_first memory_first
         trace_branch,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_assign_parent
      trace_parent le_parent memory_parent Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_parent memory_parent
      geo_add_child_read_parent_first_child
      trace_first le_first memory_first Out_normal /\
    exec_stmt function_entry2 graph_node_ge e le_first memory_first
      geo_add_child_children_branch
      trace_branch le' memory' outcome.

Ltac impossible_generated_prefix :=
  repeat match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H
  | H : outcome_result_value _ _ = _ |- _ => inv H
  | b : bool |- _ => destruct b
  end; congruence.

Lemma exec_geo_remove_child_parent_children_branch_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_parent_children_branch trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_remove_child_parent_children_branch,
    geo_remove_child_after_next_prev_splice,
    geo_remove_child_after_prev_next_splice,
    geo_remove_child_after_first_child,
    geo_remove_child_after_parent,
    geo_remove_child_body in Hexec.
  cbn in Hexec.
  repeat match goal with
  | b : bool |- _ => destruct b
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H
  end;
  reflexivity.
Qed.

Lemma exec_geo_remove_child_prev_next_splice_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_prev_next_splice trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_remove_child_prev_next_splice,
    geo_remove_child_after_first_child,
    geo_remove_child_after_parent,
    geo_remove_child_body in Hexec.
  cbn in Hexec.
  repeat match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
  end;
  reflexivity.
Qed.

Lemma exec_geo_remove_child_next_prev_splice_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_next_prev_splice trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_remove_child_next_prev_splice,
    geo_remove_child_after_prev_next_splice,
    geo_remove_child_after_first_child,
    geo_remove_child_after_parent,
    geo_remove_child_body in Hexec.
  cbn in Hexec.
  repeat match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
  end;
  reflexivity.
Qed.

Lemma exec_geo_remove_child_read_parent_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_read_parent trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_remove_child_read_parent, geo_remove_child_body in Hexec.
  cbn in Hexec.
  inv Hexec.
  reflexivity.
Qed.

Lemma exec_geo_remove_child_read_first_child_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_read_first_child trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_remove_child_read_first_child,
    geo_remove_child_after_parent,
    geo_remove_child_body in Hexec.
  cbn in Hexec.
  inv Hexec.
  reflexivity.
Qed.

Lemma exec_geo_add_child_top_if_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_top_if trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_add_child_top_if, geo_add_child_body in Hexec.
  cbn in Hexec.
  repeat match goal with
  | b : bool |- _ => destruct b
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H
  end;
  reflexivity.
Qed.

Lemma exec_geo_add_child_assign_parent_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_assign_parent trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_add_child_assign_parent, geo_add_child_then_branch,
    geo_add_child_top_if, geo_add_child_body in Hexec.
  cbn in Hexec.
  inv Hexec.
  reflexivity.
Qed.

Lemma exec_geo_add_child_read_parent_first_child_normal :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_read_parent_first_child trace le' memory' outcome ->
    outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_add_child_read_parent_first_child,
    geo_add_child_after_assign_parent,
    geo_add_child_then_branch,
    geo_add_child_top_if, geo_add_child_body in Hexec.
  cbn in Hexec.
  inv Hexec.
  reflexivity.
Qed.

Theorem exec_geo_remove_child_body_inverts_spine :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_remove_child_body trace le' memory' outcome ->
    geo_remove_child_exec_spine
      e le memory trace le' memory' outcome.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  rewrite geo_remove_child_body_split in Hexec.
  inv Hexec.
  - match goal with
    | Hrest :
        exec_stmt _ _ _ _ _
          geo_remove_child_after_parent _ _ _ _ |- _ =>
        rewrite geo_remove_child_after_parent_split in Hrest;
        inv Hrest
    end.
    + match goal with
      | Hrest :
          exec_stmt _ _ _ _ _
            geo_remove_child_after_first_child _ _ _ _ |- _ =>
          rewrite geo_remove_child_after_first_child_split in Hrest;
          inv Hrest
      end.
      * match goal with
        | Hrest :
            exec_stmt _ _ _ _ _
              geo_remove_child_after_prev_next_splice _ _ _ _ |- _ =>
            rewrite geo_remove_child_after_prev_next_splice_split in Hrest;
            inv Hrest
        end.
        -- match goal with
           | Hrest :
               exec_stmt _ _ _ _ _
                 geo_remove_child_after_next_prev_splice _ _ _ _ |- _ =>
               rewrite geo_remove_child_after_next_prev_splice_split in Hrest;
               inv Hrest
           end.
           ++ repeat eexists; repeat split; eassumption.
            ++ match goal with
               | Hfirst :
                   exec_stmt _ _ _ _ _
                     geo_remove_child_parent_children_branch _ _ _ ?out,
                 Hneq : ?out <> Out_normal |- _ =>
                   apply exec_geo_remove_child_parent_children_branch_normal
                     in Hfirst;
                   contradiction
               end.
        -- match goal with
           | Hfirst :
               exec_stmt _ _ _ _ _
                 geo_remove_child_next_prev_splice _ _ _ ?out,
             Hneq : ?out <> Out_normal |- _ =>
               apply exec_geo_remove_child_next_prev_splice_normal
                 in Hfirst;
               contradiction
           end.
      * match goal with
        | Hfirst :
            exec_stmt _ _ _ _ _
              geo_remove_child_prev_next_splice _ _ _ ?out,
          Hneq : ?out <> Out_normal |- _ =>
            apply exec_geo_remove_child_prev_next_splice_normal
              in Hfirst;
            contradiction
        end.
    + match goal with
      | Hfirst :
          exec_stmt _ _ _ _ _
            geo_remove_child_read_first_child _ _ _ ?out,
        Hneq : ?out <> Out_normal |- _ =>
          apply exec_geo_remove_child_read_first_child_normal in Hfirst;
          contradiction
      end.
  - match goal with
    | Hfirst :
        exec_stmt _ _ _ _ _
          geo_remove_child_read_parent _ _ _ ?out,
      Hneq : ?out <> Out_normal |- _ =>
        apply exec_geo_remove_child_read_parent_normal in Hfirst;
        contradiction
    end.
Qed.

Theorem exec_geo_add_child_body_inverts_top_spine :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_body trace le' memory' outcome ->
    geo_add_child_body_exec_spine
      e le memory trace le' memory' outcome.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  rewrite geo_add_child_body_split in Hexec.
  inv Hexec.
  - repeat eexists; repeat split; eassumption.
  - match goal with
    | Hfirst :
        exec_stmt _ _ _ _ _
          geo_add_child_top_if _ _ _ ?out,
      Hneq : ?out <> Out_normal |- _ =>
        apply exec_geo_add_child_top_if_normal in Hfirst;
        contradiction
    end.
Qed.

Theorem exec_geo_add_child_then_branch_inverts_spine :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_add_child_then_branch trace le' memory' outcome ->
    geo_add_child_then_branch_exec_spine
      e le memory trace le' memory' outcome.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  rewrite geo_add_child_then_branch_split in Hexec.
  inv Hexec.
  - match goal with
    | Hrest :
        exec_stmt _ _ _ _ _
          geo_add_child_after_assign_parent _ _ _ _ |- _ =>
        rewrite geo_add_child_after_assign_parent_split in Hrest;
        inv Hrest
    end.
    + repeat eexists; repeat split; eassumption.
    + match goal with
      | Hfirst :
          exec_stmt _ _ _ _ _
            geo_add_child_read_parent_first_child _ _ _ ?out,
        Hneq : ?out <> Out_normal |- _ =>
          apply exec_geo_add_child_read_parent_first_child_normal in Hfirst;
          contradiction
      end.
  - match goal with
    | Hfirst :
        exec_stmt _ _ _ _ _
          geo_add_child_assign_parent _ _ _ ?out,
      Hneq : ?out <> Out_normal |- _ =>
        apply exec_geo_add_child_assign_parent_normal in Hfirst;
        contradiction
    end.
Qed.

Definition geo_remove_child_compcert_store_trace
    (before after : mem)
    (removed parent previous next : graph_node_pointer) : Prop :=
  exists after_prev_next after_next_prev,
    graph_node_field_store_ptr before
      after_prev_next previous graph_node_next_field_offset next /\
    graph_node_field_store_ptr
      after_prev_next after_next_prev
      next graph_node_prev_field_offset previous /\
    (after = after_next_prev \/
    graph_node_field_store_ptr
      after_next_prev after
      parent graph_node_children_field_offset next \/
    graph_node_field_store_null
      after_next_prev after
      parent graph_node_children_field_offset).

Record geo_remove_child_memory_effect
    (before after : mem)
    (removed parent previous next : graph_node_pointer) : Prop := {
  geo_remove_child_memory_generated_body :
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
  geo_remove_child_memory_parent_read :
    graph_node_field_load_ptr before
      removed graph_node_parent_field_offset = Some parent;
  geo_remove_child_memory_prev_read :
    graph_node_field_load_ptr before
      removed graph_node_prev_field_offset = Some previous;
  geo_remove_child_memory_next_read :
    graph_node_field_load_ptr before
      removed graph_node_next_field_offset = Some next;
  geo_remove_child_memory_store_trace :
    geo_remove_child_compcert_store_trace before after
      removed parent previous next;
  geo_remove_child_memory_parent_child_after :
    forall to,
      graph_node_field_load_ptr after
        parent graph_node_children_field_offset = Some to ->
      graph_node_field_load_ptr before
        parent graph_node_children_field_offset = Some to \/
      graph_node_field_load_ptr before
        parent graph_node_children_field_offset = Some removed /\
      graph_node_field_load_ptr before
        removed graph_node_next_field_offset = Some to;
  geo_remove_child_memory_previous_next_after :
    forall to,
      graph_node_field_load_ptr after
        previous graph_node_next_field_offset = Some to ->
      graph_node_field_load_ptr before
        previous graph_node_next_field_offset = Some to \/
      graph_node_field_load_ptr before
        previous graph_node_next_field_offset = Some removed /\
      graph_node_field_load_ptr before
        removed graph_node_next_field_offset = Some to;
  geo_remove_child_memory_children_frame :
    forall from,
      from <> parent ->
      graph_node_field_load_ptr after
        from graph_node_children_field_offset =
      graph_node_field_load_ptr before
        from graph_node_children_field_offset;
  geo_remove_child_memory_next_frame :
    forall from,
      from <> previous ->
      graph_node_field_load_ptr after
        from graph_node_next_field_offset =
      graph_node_field_load_ptr before
        from graph_node_next_field_offset;
  geo_remove_child_memory_no_after_incoming_to_removed :
    forall from,
      from <> removed ->
      graph_node_field_load_ptr after
        from graph_node_children_field_offset <> Some removed /\
      graph_node_field_load_ptr after
        from graph_node_next_field_offset <> Some removed
}.

Record geo_remove_child_exec_memory_obligations
    (before after : mem)
    (removed parent previous next : graph_node_pointer) : Prop := {
  geo_remove_child_exec_parent_read :
    graph_node_field_load_ptr before
      removed graph_node_parent_field_offset = Some parent;
  geo_remove_child_exec_prev_read :
    graph_node_field_load_ptr before
      removed graph_node_prev_field_offset = Some previous;
  geo_remove_child_exec_next_read :
    graph_node_field_load_ptr before
      removed graph_node_next_field_offset = Some next;
  geo_remove_child_exec_store_trace :
    geo_remove_child_compcert_store_trace before after
      removed parent previous next;
  geo_remove_child_exec_parent_child_after :
    forall to,
      graph_node_field_load_ptr after
        parent graph_node_children_field_offset = Some to ->
      graph_node_field_load_ptr before
        parent graph_node_children_field_offset = Some to \/
      graph_node_field_load_ptr before
        parent graph_node_children_field_offset = Some removed /\
      graph_node_field_load_ptr before
        removed graph_node_next_field_offset = Some to;
  geo_remove_child_exec_previous_next_after :
    forall to,
      graph_node_field_load_ptr after
        previous graph_node_next_field_offset = Some to ->
      graph_node_field_load_ptr before
        previous graph_node_next_field_offset = Some to \/
      graph_node_field_load_ptr before
        previous graph_node_next_field_offset = Some removed /\
      graph_node_field_load_ptr before
        removed graph_node_next_field_offset = Some to;
  geo_remove_child_exec_children_frame :
    forall from,
      from <> parent ->
      graph_node_field_load_ptr after
        from graph_node_children_field_offset =
      graph_node_field_load_ptr before
        from graph_node_children_field_offset;
  geo_remove_child_exec_next_frame :
    forall from,
      from <> previous ->
      graph_node_field_load_ptr after
        from graph_node_next_field_offset =
      graph_node_field_load_ptr before
        from graph_node_next_field_offset;
  geo_remove_child_exec_no_after_incoming_to_removed :
    forall from,
      from <> removed ->
      graph_node_field_load_ptr after
        from graph_node_children_field_offset <> Some removed /\
      graph_node_field_load_ptr after
        from graph_node_next_field_offset <> Some removed
}.

Theorem geo_remove_child_memory_effect_from_exec_stmt :
  forall e le before trace le' after outcome
    removed parent previous next,
    exec_stmt function_entry2 graph_node_ge e le before
      geo_remove_child_body trace le' after outcome ->
    geo_remove_child_exec_memory_obligations before after
      removed parent previous next ->
    geo_remove_child_memory_effect before after
      removed parent previous next.
Proof.
  intros e le before trace le' after outcome
    removed parent previous next Hexec Hobligations.
  pose proof
    (exec_geo_remove_child_body_inverts_spine
       e le before trace le' after outcome Hexec) as _Hspine.
  destruct Hobligations as
    [Hparent Hprev Hnext Hstores Hparent_child Hprevious_next
     Hchildren_frame Hnext_frame Hno_incoming].
  refine {| geo_remove_child_memory_generated_body := _;
            geo_remove_child_memory_parent_read := Hparent;
            geo_remove_child_memory_prev_read := Hprev;
            geo_remove_child_memory_next_read := Hnext;
            geo_remove_child_memory_store_trace := Hstores;
            geo_remove_child_memory_parent_child_after := Hparent_child;
            geo_remove_child_memory_previous_next_after := Hprevious_next;
            geo_remove_child_memory_children_frame := Hchildren_frame;
            geo_remove_child_memory_next_frame := Hnext_frame;
            geo_remove_child_memory_no_after_incoming_to_removed :=
              Hno_incoming |}.
  exact geo_remove_child_relink_shape_audit.
Qed.

Theorem geo_remove_child_graph_effect_from_memory_effect :
  forall before after removed parent previous next,
    geo_remove_child_memory_effect before after
      removed parent previous next ->
    geo_remove_child_graph_effect graph_node_pointer
      (concrete_graph_links before) (concrete_graph_links after) removed.
Proof.
  intros before after removed parent previous next Hmemory.
  destruct Hmemory as
    [_ _ _ _ _ Hparent_child Hprevious_next Hchildren_frame
     Hnext_frame Hno_incoming].
  split.
  - intros from to Hstep.
    destruct Hstep as [from to Hchild | from to Hnext]; cbn in *.
    + destruct (classic (from = parent)) as [Hfrom | Hfrom].
      * subst from.
        destruct (Hparent_child to Hchild) as
          [Hold | [Hparent_removed Hremoved_to]].
        -- left. apply GraphChildStep. exact Hold.
        -- right. split.
           ++ apply GraphChildStep. exact Hparent_removed.
           ++ apply GraphNextStep. exact Hremoved_to.
      * rewrite Hchildren_frame in Hchild by exact Hfrom.
        left. apply GraphChildStep. exact Hchild.
    + destruct (classic (from = previous)) as [Hfrom | Hfrom].
      * subst from.
        destruct (Hprevious_next to Hnext) as
          [Hold | [Hprevious_removed Hremoved_to]].
        -- left. apply GraphNextStep. exact Hold.
        -- right. split.
           ++ apply GraphNextStep. exact Hprevious_removed.
           ++ apply GraphNextStep. exact Hremoved_to.
      * rewrite Hnext_frame in Hnext by exact Hfrom.
        left. apply GraphNextStep. exact Hnext.
  - intros from Hfrom Hstep.
    destruct Hstep as [from to Hchild | from to Hnext]; cbn in *.
    + destruct (Hno_incoming from Hfrom) as [Hno_child _].
      exact (Hno_child Hchild).
    + destruct (Hno_incoming from Hfrom) as [_ Hno_next].
      exact (Hno_next Hnext).
Qed.

Theorem geo_remove_child_semantic_execution_from_memory_effect :
  forall before after removed parent previous next,
    geo_remove_child_memory_effect before after
      removed parent previous next ->
    geo_remove_child_semantic_execution graph_node_pointer
      (concrete_graph_links before) (concrete_graph_links after) removed.
Proof.
  intros before after removed parent previous next Hmemory.
  apply geo_remove_child_semantic_execution_from_graph_effect.
  eapply geo_remove_child_graph_effect_from_memory_effect.
  exact Hmemory.
Qed.

Definition geo_add_child_compcert_store_trace
    (before after : mem) (parent child : graph_node_pointer) : Prop :=
  exists after_parent after_parent_children after_child_prev after_child_next,
    graph_node_field_store_ptr before
      after_parent child graph_node_parent_field_offset parent /\
    (after_parent_children = after_parent \/
     graph_node_field_store_ptr after_parent after_parent_children
       parent graph_node_children_field_offset child) /\
    (graph_node_field_store_ptr after_parent_children
       after_child_prev child graph_node_prev_field_offset child \/
    exists parent_last_child,
      graph_node_field_store_ptr after_parent_children
        after_child_prev child graph_node_prev_field_offset
        parent_last_child) /\
    (graph_node_field_store_ptr after_child_prev
       after_child_next child graph_node_next_field_offset child \/
    exists parent_first_child,
      graph_node_field_store_ptr after_child_prev
        after_child_next child graph_node_next_field_offset
        parent_first_child) /\
    (after = after_child_next \/
    exists parent_first_child parent_last_child after_first_prev,
      graph_node_field_store_ptr after_child_next
        after_first_prev
        parent_first_child graph_node_prev_field_offset child /\
      graph_node_field_store_ptr after_first_prev after
        parent_last_child graph_node_next_field_offset child).

Record geo_add_child_memory_effect
    (before after : mem) (parent child : graph_node_pointer) : Prop := {
  geo_add_child_memory_generated_body :
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
  geo_add_child_memory_parent_store_observed :
    graph_node_field_load_ptr after
      child graph_node_parent_field_offset = Some parent;
  geo_add_child_memory_store_trace :
    geo_add_child_compcert_store_trace before after parent child;
  geo_add_child_memory_children_after :
    forall from to,
      graph_node_field_load_ptr after
        from graph_node_children_field_offset = Some to ->
      graph_node_field_load_ptr before
        from graph_node_children_field_offset = Some to \/
      (from = parent /\ to = child);
  geo_add_child_memory_next_after :
    forall from to,
      graph_node_field_load_ptr after
        from graph_node_next_field_offset = Some to ->
      graph_node_field_load_ptr before
        from graph_node_next_field_offset = Some to \/
      (from = child /\
       (to = child \/
        graph_link_reachable graph_node_pointer
          (concrete_graph_links before) parent to)) \/
      (graph_link_reachable graph_node_pointer
        (concrete_graph_links before) parent from /\ to = child)
}.

Record geo_add_child_exec_memory_obligations
    (before after : mem) (parent child : graph_node_pointer) : Prop := {
  geo_add_child_exec_parent_store_observed :
    graph_node_field_load_ptr after
      child graph_node_parent_field_offset = Some parent;
  geo_add_child_exec_store_trace :
    geo_add_child_compcert_store_trace before after parent child;
  geo_add_child_exec_children_after :
    forall from to,
      graph_node_field_load_ptr after
        from graph_node_children_field_offset = Some to ->
      graph_node_field_load_ptr before
        from graph_node_children_field_offset = Some to \/
      (from = parent /\ to = child);
  geo_add_child_exec_next_after :
    forall from to,
      graph_node_field_load_ptr after
        from graph_node_next_field_offset = Some to ->
      graph_node_field_load_ptr before
        from graph_node_next_field_offset = Some to \/
      (from = child /\
       (to = child \/
        graph_link_reachable graph_node_pointer
          (concrete_graph_links before) parent to)) \/
      (graph_link_reachable graph_node_pointer
        (concrete_graph_links before) parent from /\ to = child)
}.

Theorem geo_add_child_memory_effect_from_then_branch_exec_stmt :
  forall e le before trace le' after outcome parent child,
    exec_stmt function_entry2 graph_node_ge e le before
      geo_add_child_then_branch trace le' after outcome ->
    geo_add_child_exec_memory_obligations before after parent child ->
    geo_add_child_memory_effect before after parent child.
Proof.
  intros e le before trace le' after outcome parent child
    Hexec Hobligations.
  pose proof
    (exec_geo_add_child_then_branch_inverts_spine
       e le before trace le' after outcome Hexec) as _Hspine.
  destruct Hobligations as
    [Hparent Hstores Hchildren_after Hnext_after].
  refine {| geo_add_child_memory_generated_body := _;
            geo_add_child_memory_parent_store_observed := Hparent;
            geo_add_child_memory_store_trace := Hstores;
            geo_add_child_memory_children_after := Hchildren_after;
            geo_add_child_memory_next_after := Hnext_after |}.
  exact geo_add_child_relink_shape_audit.
Qed.

Theorem geo_add_child_graph_effect_from_memory_effect :
  forall before after parent child,
    geo_add_child_memory_effect before after parent child ->
    geo_add_child_graph_effect graph_node_pointer
      (concrete_graph_links before) (concrete_graph_links after)
      parent child.
Proof.
  intros before after parent child Hmemory.
  destruct Hmemory as [_ _ _ Hchildren_after Hnext_after].
  split.
  intros from to Hstep.
  destruct Hstep as [from to Hchild | from to Hnext]; cbn in *.
  - destruct (Hchildren_after from to Hchild) as
      [Hold | [Hfrom_parent Hto_child]].
    + left. apply GraphChildStep. exact Hold.
    + right. left. split; assumption.
  - destruct (Hnext_after from to Hnext) as
      [Hold |
       [[Hfrom_child [Hto_child | Hparent_to]] |
        [Hparent_from Hto_child]]].
    + left. apply GraphNextStep. exact Hold.
    + right. right. left.
      split; [exact Hfrom_child | left; exact Hto_child].
    + right. right. left.
      split; [exact Hfrom_child | right; exact Hparent_to].
    + right. right. right.
      split; assumption.
Qed.

Theorem geo_add_child_semantic_execution_from_memory_effect :
  forall before after parent child,
    geo_add_child_memory_effect before after parent child ->
    geo_add_child_semantic_execution graph_node_pointer
      (concrete_graph_links before) (concrete_graph_links after)
      parent child.
Proof.
  intros before after parent child Hmemory.
  apply geo_add_child_semantic_execution_from_graph_effect.
  eapply geo_add_child_graph_effect_from_memory_effect.
  exact Hmemory.
Qed.

Definition graph_node_safe_for_generated_traversal
    (current_or_destination dead_not_outside : graph_node_pointer -> Prop)
    (node : graph_node_pointer) : Prop :=
  current_or_destination node \/ dead_not_outside node.

Theorem parked_removed_node_is_safe_for_generated_traversal :
  forall
    (current_or_destination dead_not_outside : graph_node_pointer -> Prop)
    removed,
    dead_not_outside removed ->
    graph_node_safe_for_generated_traversal
      current_or_destination dead_not_outside removed.
Proof.
  intros current_or_destination dead_not_outside removed Hdead.
  right. exact Hdead.
Qed.

Theorem generated_relink_memory_effects_confine_traversal :
  forall before_unload after_remove after_add
    (safe_node : graph_node_pointer -> Prop)
    object_parent_first_child current_area_root removed
    remove_parent remove_previous remove_next add_parent add_child,
    generated_load_area_graph_traversals_confined graph_node_pointer
      (concrete_graph_links before_unload) safe_node
      object_parent_first_child current_area_root ->
    graph_links_preserve graph_node_pointer
      (concrete_graph_links before_unload) safe_node ->
    generated_roots_exclude_node graph_node_pointer
      object_parent_first_child current_area_root removed ->
    geo_remove_child_memory_effect before_unload after_remove
      removed remove_parent remove_previous remove_next ->
    safe_node add_parent ->
    safe_node add_child ->
    geo_add_child_memory_effect after_remove after_add add_parent add_child ->
    generated_load_area_graph_traversals_confined graph_node_pointer
      (concrete_graph_links after_add) safe_node
      object_parent_first_child current_area_root.
Proof.
  intros before_unload after_remove after_add safe_node
    object_parent_first_child current_area_root removed
    remove_parent remove_previous remove_next add_parent add_child
    Hbefore Hpres Hroots Hremove_memory Hadd_parent Hadd_child Hadd_memory.
  eapply
    (generated_relink_semantic_executions_confine_traversal
       graph_node_pointer).
  - exact Hbefore.
  - exact Hpres.
  - exact Hroots.
  - eapply geo_remove_child_semantic_execution_from_memory_effect.
    exact Hremove_memory.
  - exact Hadd_parent.
  - exact Hadd_child.
  - eapply geo_add_child_semantic_execution_from_memory_effect.
    exact Hadd_memory.
Qed.

Theorem generated_relink_exec_stmt_effects_confine_traversal :
  forall remove_env remove_temps before_unload
    remove_trace remove_temps' after_remove remove_outcome
    add_env add_temps add_trace add_temps' after_add add_outcome
    (safe_node : graph_node_pointer -> Prop)
    object_parent_first_child current_area_root removed
    remove_parent remove_previous remove_next add_parent add_child,
    exec_stmt function_entry2 graph_node_ge remove_env remove_temps
      before_unload geo_remove_child_body
      remove_trace remove_temps' after_remove remove_outcome ->
    geo_remove_child_exec_memory_obligations
      before_unload after_remove
      removed remove_parent remove_previous remove_next ->
    exec_stmt function_entry2 graph_node_ge add_env add_temps
      after_remove geo_add_child_then_branch
      add_trace add_temps' after_add add_outcome ->
    geo_add_child_exec_memory_obligations
      after_remove after_add add_parent add_child ->
    generated_load_area_graph_traversals_confined graph_node_pointer
      (concrete_graph_links before_unload) safe_node
      object_parent_first_child current_area_root ->
    graph_links_preserve graph_node_pointer
      (concrete_graph_links before_unload) safe_node ->
    generated_roots_exclude_node graph_node_pointer
      object_parent_first_child current_area_root removed ->
    safe_node add_parent ->
    safe_node add_child ->
    generated_load_area_graph_traversals_confined graph_node_pointer
      (concrete_graph_links after_add) safe_node
      object_parent_first_child current_area_root.
Proof.
  intros remove_env remove_temps before_unload
    remove_trace remove_temps' after_remove remove_outcome
    add_env add_temps add_trace add_temps' after_add add_outcome
    safe_node object_parent_first_child current_area_root removed
    remove_parent remove_previous remove_next add_parent add_child
    Hremove_exec Hremove_obligations Hadd_exec Hadd_obligations
    Hbefore Hpres Hroots Hadd_parent Hadd_child.
  eapply generated_relink_memory_effects_confine_traversal.
  - exact Hbefore.
  - exact Hpres.
  - exact Hroots.
  - eapply geo_remove_child_memory_effect_from_exec_stmt; eauto.
  - exact Hadd_parent.
  - exact Hadd_child.
  - eapply geo_add_child_memory_effect_from_then_branch_exec_stmt; eauto.
Qed.

Theorem generated_unload_parking_memory_effect_confines_traversal :
  forall before_unload after_remove after_parking
    (current_or_destination dead_not_outside : graph_node_pointer -> Prop)
    object_parent_first_child current_area_root removed
    remove_parent remove_previous remove_next object_parent_graph_node,
    generated_load_area_graph_traversals_confined graph_node_pointer
      (concrete_graph_links before_unload)
      (graph_node_safe_for_generated_traversal
        current_or_destination dead_not_outside)
      object_parent_first_child current_area_root ->
    graph_links_preserve graph_node_pointer
      (concrete_graph_links before_unload)
      (graph_node_safe_for_generated_traversal
        current_or_destination dead_not_outside) ->
    generated_roots_exclude_node graph_node_pointer
      object_parent_first_child current_area_root removed ->
    geo_remove_child_memory_effect before_unload after_remove
      removed remove_parent remove_previous remove_next ->
    graph_node_safe_for_generated_traversal
      current_or_destination dead_not_outside object_parent_graph_node ->
    dead_not_outside removed ->
    geo_add_child_memory_effect after_remove after_parking
      object_parent_graph_node removed ->
    generated_load_area_graph_traversals_confined graph_node_pointer
      (concrete_graph_links after_parking)
      (graph_node_safe_for_generated_traversal
        current_or_destination dead_not_outside)
      object_parent_first_child current_area_root.
Proof.
  intros before_unload after_remove after_parking
    current_or_destination dead_not_outside object_parent_first_child
    current_area_root removed remove_parent remove_previous remove_next
    object_parent_graph_node Hbefore Hpres Hroots Hremove_memory
    Hpark_parent Hdead_removed Hparking_memory.
  eapply generated_relink_memory_effects_confine_traversal.
  - exact Hbefore.
  - exact Hpres.
  - exact Hroots.
  - exact Hremove_memory.
  - exact Hpark_parent.
  - apply parked_removed_node_is_safe_for_generated_traversal.
    exact Hdead_removed.
  - exact Hparking_memory.
Qed.
