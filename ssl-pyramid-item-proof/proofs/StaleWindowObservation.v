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
From compcert Require Import AST Clight ClightBigstep Clightdefs Coqlib Ctypes
  Errors Events Globalenvs Integers Maps Memory Values.
From SSLPyramid.Proofs Require Import
  ASTFacts GraphTraversalModel NonMarioReferenceFacts OutsideObjectChannels
  RenderHeldObjectFacts Spec StalePointerModel TransitionFacts
  TraversalModel UnloadObjectSemantics.

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

Definition obj_behaviors_stmt_ignores_stale_mario_object_refs
    (stmt : statement) : Prop :=
  statement_mentions_field_s OB._heldObj stmt = false /\
  statement_mentions_field_s OB._usedObj stmt = false /\
  statement_mentions_field_s OB._riddenObj stmt = false /\
  statement_mentions_field_s OB._interactObj stmt = false.

Definition behavior_actions_stmt_ignores_stale_mario_object_refs
    (stmt : statement) : Prop :=
  statement_mentions_field_s B._heldObj stmt = false /\
  statement_mentions_field_s B._usedObj stmt = false /\
  statement_mentions_field_s B._riddenObj stmt = false /\
  statement_mentions_field_s B._interactObj stmt = false.

Theorem ssl_pyramid_mechanism_behaviors_do_not_mention_stale_mario_object_refs :
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_spindel_init) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_spindel_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_ssl_moving_pyramid_wall_init) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_ssl_moving_pyramid_wall_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_elevator_init) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_elevator_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_elevator_trajectory_marker_ball_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_top_init) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_top_spinning) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_top_explode) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_top_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_top_fragment_init) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_top_fragment_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_pyramid_pillar_touch_detector_loop) /\
  obj_behaviors_stmt_ignores_stale_mario_object_refs
    (fn_body OB.f_bhv_sand_sound_loop) /\
  behavior_actions_stmt_ignores_stale_mario_object_refs
    (fn_body B.f_bhv_pole_init) /\
  behavior_actions_stmt_ignores_stale_mario_object_refs
    (fn_body B.f_bhv_pole_base_loop) /\
  behavior_actions_stmt_ignores_stale_mario_object_refs
    (fn_body B.f_bhv_giant_pole_loop) /\
  behavior_actions_stmt_ignores_stale_mario_object_refs
    (fn_body B.f_bhv_grindel_thwomp_loop) /\
  behavior_actions_stmt_ignores_stale_mario_object_refs
    (fn_body B.f_bhv_tilting_inverted_pyramid_loop).
Proof. repeat split; vm_compute; reflexivity. Qed.

Definition stale_mario_object_refs_pyramid_behavior_update_audit : Prop :=
  proposition_of load_area_direct_call_order /\
  proposition_of load_area_does_not_call_update_objects /\
  proposition_of load_mario_area_does_not_call_update_objects /\
  proposition_of
    ssl_pyramid_mechanism_behaviors_do_not_mention_stale_mario_object_refs /\
  audited_mario_stale_ref_no_observation_before_cleanup.

Theorem stale_mario_object_refs_pyramid_behavior_update_audit_holds :
  stale_mario_object_refs_pyramid_behavior_update_audit.
Proof.
  unfold stale_mario_object_refs_pyramid_behavior_update_audit,
    proposition_of.
  repeat split;
    first
      [ exact load_area_direct_call_order
      | exact load_area_does_not_call_update_objects
      | exact load_mario_area_does_not_call_update_objects
      | exact ssl_pyramid_mechanism_behaviors_do_not_mention_stale_mario_object_refs
      | exact audited_mario_stale_ref_no_observation_before_cleanup_holds ].
Qed.

Definition disappeared_warp_held_object_drop_folklore_audit : Prop :=
  proposition_of interact_warp_disappeared_path_stops_riding_not_holding /\
  proposition_of act_disappeared_triggers_warp_without_dropping_held_object /\
  proposition_of level_transition_bodies_do_not_drop_held_object_before_reinit.

Theorem disappeared_warp_held_object_drop_folklore_audit_holds :
  disappeared_warp_held_object_drop_folklore_audit.
Proof.
  unfold disappeared_warp_held_object_drop_folklore_audit,
    proposition_of.
  repeat split;
    first
      [ exact interact_warp_disappeared_path_stops_riding_not_holding
      | exact act_disappeared_triggers_warp_without_dropping_held_object
      | exact level_transition_bodies_do_not_drop_held_object_before_reinit ].
Qed.

Definition normal_interact_warp_ridden_object_clearance_audit : Prop :=
  proposition_of normal_interact_warp_clears_ridden_before_warp_completion.

Theorem normal_interact_warp_ridden_object_clearance_audit_holds :
  normal_interact_warp_ridden_object_clearance_audit.
Proof.
  unfold normal_interact_warp_ridden_object_clearance_audit,
    proposition_of.
  exact normal_interact_warp_clears_ridden_before_warp_completion.
Qed.

Record audited_technical_stale_window_counterexample
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  audited_technical_stale_window_base :
    technical_stale_window_counterexample before pool_block window;
  audited_technical_stale_window_no_generated_use :
    audited_mario_stale_ref_no_observation_before_cleanup
}.

Record audited_ridden_technical_stale_window_counterexample
    (before : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  audited_ridden_technical_stale_window_base :
    ridden_technical_stale_window_counterexample
      before pool_block window;
  audited_ridden_technical_stale_window_no_generated_use :
    audited_mario_stale_ref_no_observation_before_cleanup
}.

Record audited_technical_stale_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  audited_technical_stale_reuse_base :
    technical_stale_slot_reuse_counterexample
      before after_load pool_block window;
  audited_technical_stale_reuse_no_generated_use :
    audited_mario_stale_ref_no_observation_before_cleanup
}.

Record audited_ridden_technical_stale_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  audited_ridden_technical_stale_reuse_base :
    ridden_technical_stale_slot_reuse_counterexample
      before after_load pool_block window;
  audited_ridden_technical_stale_reuse_no_generated_use :
    audited_mario_stale_ref_no_observation_before_cleanup
}.

Record audited_technical_stale_pyramid_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  audited_technical_stale_pyramid_reuse_base :
    technical_stale_pyramid_slot_reuse_counterexample
      before after_load pool_block window;
  audited_technical_stale_pyramid_reuse_no_generated_use :
    audited_mario_stale_ref_no_observation_before_cleanup
}.

Record audited_ridden_technical_stale_pyramid_slot_reuse_counterexample
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop := {
  audited_ridden_technical_stale_pyramid_reuse_base :
    ridden_technical_stale_pyramid_slot_reuse_counterexample
      before after_load pool_block window;
  audited_ridden_technical_stale_pyramid_reuse_no_generated_use :
    audited_mario_stale_ref_no_observation_before_cleanup
}.

Theorem held_grab_constructs_audited_technical_stale_window_counterexample :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      audited_technical_stale_window_counterexample
        before pool_block window.
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  destruct
    (held_grab_constructs_technical_stale_window_counterexample
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hcounterexample).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hcounterexample.
  - exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.

Theorem held_grab_constructs_audited_technical_pyramid_slot_reuse_counterexample
    :
  forall before allocation_start after_active_flags_store after_load
      pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    same_slot_pyramid_allocation_store_trace
      allocation_start after_active_flags_store after_load
      pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      audited_technical_stale_pyramid_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before allocation_start after_active_flags_store after_load
    pool_block outside_slot destination_spawn_slot Houtside Hstores.
  destruct
    (held_grab_constructs_technical_pyramid_slot_reuse_counterexample
       before allocation_start after_active_flags_store after_load
       pool_block outside_slot destination_spawn_slot Houtside Hstores)
    as (window & Hwindow & Hcounterexample).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hcounterexample.
  - exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
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

Theorem shell_ride_constructs_audited_ridden_technical_stale_window_counterexample :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window
          outside_slot destination_spawn_slot /\
      audited_ridden_technical_stale_window_counterexample
        before pool_block window.
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  destruct
    (shell_ride_constructs_ridden_technical_stale_window_counterexample
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hcounterexample).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hcounterexample.
  - exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.

Theorem shell_ride_constructs_audited_ridden_technical_pyramid_slot_reuse_counterexample
    :
  forall before allocation_start after_active_flags_store after_load
      pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    same_slot_pyramid_allocation_store_trace
      allocation_start after_active_flags_store after_load
      pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window
          outside_slot destination_spawn_slot /\
      audited_ridden_technical_stale_pyramid_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before allocation_start after_active_flags_store after_load
    pool_block outside_slot destination_spawn_slot Houtside Hstores.
  destruct
    (shell_ride_constructs_ridden_technical_pyramid_slot_reuse_counterexample
       before allocation_start after_active_flags_store after_load
       pool_block outside_slot destination_spawn_slot Houtside Hstores)
    as (window & Hwindow & Hcounterexample).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hcounterexample.
  - exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.

Theorem shell_ride_ridden_stale_load_window_is_unobserved_before_cleanup :
  forall before pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window
          outside_slot destination_spawn_slot /\
      stale_outside_reference_after_pyramid_load
        before pool_block window /\
      stale_ridden_outside_reference_after_pyramid_load
        before pool_block window /\
      ~ stale_outside_reference before pool_block
          (refs_after_mario_reinit window) /\
      audited_mario_stale_ref_no_observation_before_cleanup.
Proof.
  intros before pool_block outside_slot destination_spawn_slot Houtside.
  destruct
    (outside_shell_ride_can_leave_ridden_stale_reference_across_pyramid_load
       before pool_block outside_slot destination_spawn_slot Houtside)
    as (window & Hwindow & Hstale & Hridden & Hclean).
  exists window.
  split; [exact Hwindow |].
  split; [exact Hstale |].
  split; [exact Hridden |].
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

Theorem held_grab_constructs_audited_technical_slot_reuse_counterexample :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      audited_technical_stale_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (held_grab_constructs_technical_slot_reuse_counterexample
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hcounterexample).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hcounterexample.
  - exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.

Definition technical_stale_slot_alias_without_generated_use
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  technical_stale_pointer_smuggled_into_load_window
    before pool_block window /\
  technical_stale_slot_alias_during_load
    before after_load pool_block window /\
  no_technical_stale_pointer_after_mario_reinit
    before pool_block window /\
  audited_mario_stale_ref_no_observation_before_cleanup.

Record concrete_same_slot_allocation_assign_locs
    (active_area_ce : composite_env)
    (allocation_start after_active_flags_store after_load : mem)
    (pool_block : block) (slot : Z) : Prop := {
  concrete_active_flags_assign_loc :
    assign_loc unload_object_ce tshort allocation_start pool_block
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr object_active_flags_offset))
      Full (Vint object_allocation_active_flags_value)
      after_active_flags_store;
  concrete_active_area_assign_loc :
    assign_loc active_area_ce tschar after_active_flags_store pool_block
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr object_active_area_offset))
      Full (Vint (Int.repr ssl_pyramid_area))
      after_load
}.

Theorem same_slot_pyramid_allocation_store_trace_from_linked_assign_locs :
  forall active_area_ce allocation_start after_active_flags_store after_load
      pool_block slot,
    valid_object_slot slot ->
    concrete_same_slot_allocation_assign_locs active_area_ce
      allocation_start after_active_flags_store after_load pool_block slot ->
    same_slot_pyramid_allocation_store_trace
      allocation_start after_active_flags_store after_load pool_block slot.
Proof.
  intros active_area_ce allocation_start after_active_flags_store after_load
    pool_block slot Hvalid Hassigns.
  destruct Hassigns as [Hactive_flags Hactive_area].
  split.
  - unfold object_allocation_active_flags_value in Hactive_flags.
    eapply assign_loc_active_flags_allocation_store; eauto.
  - eapply assign_loc_active_area_store; eauto.
Qed.

Theorem same_slot_pyramid_allocation_receipt_from_linked_assign_locs :
  forall active_area_ce allocation_start after_active_flags_store after_load
      pool_block free_list slot allocation_count,
    valid_object_slot slot ->
    allocation_count_reaches_watched_slot
      free_list slot allocation_count ->
    concrete_same_slot_allocation_assign_locs active_area_ce
      allocation_start after_active_flags_store after_load pool_block slot ->
    same_slot_pyramid_allocation_receipt
      allocation_start after_active_flags_store after_load
      pool_block free_list slot allocation_count.
Proof.
  intros active_area_ce allocation_start after_active_flags_store after_load
    pool_block free_list slot allocation_count Hvalid Hcount Hassigns.
  destruct Hassigns as [Hactive_flags Hactive_area].
  constructor.
  - exact Hcount.
  - unfold object_allocation_active_flags_value in Hactive_flags.
    eapply assign_loc_active_flags_allocation_store; eauto.
  - eapply assign_loc_active_area_store; eauto.
Qed.

Definition geo_obj_init_spawninfo_active_area_source : expr :=
  Efield
    (Ederef
      (Etempvar G._spawn (tptr (Tstruct G._SpawnInfo noattr)))
      (Tstruct G._SpawnInfo noattr))
    G._activeAreaIndex tschar.

Definition geo_obj_init_spawninfo_active_area_lhs : expr :=
  Efield
    (Ederef
      (Etempvar G._graphNode
        (tptr (Tstruct G._GraphNodeObject noattr)))
      (Tstruct G._GraphNodeObject noattr))
    G._activeAreaIndex tschar.

Definition geo_obj_init_spawninfo_active_area_rhs : expr :=
  Etempvar G._t'6 tschar.

Definition geo_obj_init_spawninfo_active_area_set : statement :=
  Sset G._t'6 geo_obj_init_spawninfo_active_area_source.

Definition geo_obj_init_spawninfo_active_area_assign : statement :=
  Sassign geo_obj_init_spawninfo_active_area_lhs
    geo_obj_init_spawninfo_active_area_rhs.

Definition geo_obj_init_spawninfo_active_area_copy : statement :=
  Ssequence geo_obj_init_spawninfo_active_area_set
    geo_obj_init_spawninfo_active_area_assign.

Definition generated_graph_node_object_members : members :=
  match graph_node_ce ! G._GraphNodeObject with
  | Some composite => co_members composite
  | None => nil
  end.

Definition generated_spawn_info_members : members :=
  match graph_node_ce ! G._SpawnInfo with
  | Some composite => co_members composite
  | None => nil
  end.

Definition spawn_info_active_area_offset : Z := 13.

Theorem generated_graph_node_object_active_area_layout :
  field_offset graph_node_ce G._activeAreaIndex
    generated_graph_node_object_members =
  OK (object_active_area_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Theorem generated_spawn_info_active_area_layout :
  field_offset graph_node_ce G._activeAreaIndex
    generated_spawn_info_members =
  OK (spawn_info_active_area_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Lemma graph_node_object_struct_deref_loc_pointer_same :
  forall memory object_block object_offset loc ofs,
    deref_loc (Tstruct G._GraphNodeObject noattr) memory object_block
      object_offset Full (Vptr loc ofs) ->
    loc = object_block /\ ofs = object_offset.
Proof.
  intros memory object_block object_offset loc ofs Hderef.
  inv Hderef;
    simpl in *;
    try discriminate.
  split; reflexivity.
Qed.

Lemma spawn_info_struct_deref_loc_pointer_same :
  forall memory spawn_block spawn_offset loc ofs,
    deref_loc (Tstruct G._SpawnInfo noattr) memory spawn_block
      spawn_offset Full (Vptr loc ofs) ->
    loc = spawn_block /\ ofs = spawn_offset.
Proof.
  intros memory spawn_block spawn_offset loc ofs Hderef.
  inv Hderef;
    simpl in *;
    try discriminate.
  split; reflexivity.
Qed.

Definition spawninfo_active_area_read
    (memory : mem) (spawn_block : block) (spawn_offset : ptrofs)
    (area : Z) : Prop :=
  Mem.loadv Mint8signed memory
    (Vptr spawn_block
      (Ptrofs.add spawn_offset
        (Ptrofs.repr spawn_info_active_area_offset))) =
  Some (Vint (Int.repr area)).

Definition level_script_ge : genv := globalenv LS.prog.

Definition level_script_ce : composite_env := prog_comp_env LS.prog.

Lemma level_script_genv_cenv :
  genv_cenv level_script_ge = level_script_ce.
Proof.
  unfold level_script_ge, level_script_ce, globalenv.
  cbn [genv_cenv].
  reflexivity.
Qed.

Definition level_script_spawn_info_members : members :=
  match level_script_ce ! LS._SpawnInfo with
  | Some composite => co_members composite
  | None => nil
  end.

Theorem level_script_spawn_info_active_area_layout :
  field_offset level_script_ce LS._activeAreaIndex
    level_script_spawn_info_members =
  OK (spawn_info_active_area_offset, Full).
Proof. vm_compute; reflexivity. Qed.

Definition level_cmd_place_object_current_area_read
    (e : env) (memory : mem) (area : Z) : Prop :=
  exists area_block,
    e ! LS._sCurrAreaIndex = None /\
    Genv.find_symbol level_script_ge LS._sCurrAreaIndex = Some area_block /\
    Mem.loadv Mint16signed memory (Vptr area_block Ptrofs.zero) =
      Some (Vint (Int.repr area)).

Definition level_cmd_place_object_active_area_source : expr :=
  Evar LS._sCurrAreaIndex tshort.

Definition level_cmd_place_object_active_area_lhs : expr :=
  Efield
    (Ederef
      (Etempvar LS._spawnInfo
        (tptr (Tstruct LS._SpawnInfo noattr)))
      (Tstruct LS._SpawnInfo noattr))
    LS._activeAreaIndex tschar.

Definition level_cmd_place_object_active_area_rhs : expr :=
  Etempvar LS._t'17 tshort.

Definition level_cmd_place_object_active_area_set : statement :=
  Sset LS._t'17 level_cmd_place_object_active_area_source.

Definition level_cmd_place_object_active_area_assign : statement :=
  Sassign level_cmd_place_object_active_area_lhs
    level_cmd_place_object_active_area_rhs.

Definition level_cmd_place_object_active_area_copy : statement :=
  Ssequence level_cmd_place_object_active_area_set
    level_cmd_place_object_active_area_assign.

Lemma level_script_spawn_info_struct_deref_loc_pointer_same :
  forall memory spawn_block spawn_offset loc ofs,
    deref_loc (Tstruct LS._SpawnInfo noattr) memory spawn_block
      spawn_offset Full (Vptr loc ofs) ->
    loc = spawn_block /\ ofs = spawn_offset.
Proof.
  intros memory spawn_block spawn_offset loc ofs Hderef.
  inv Hderef;
    simpl in *;
    try discriminate.
  split; reflexivity.
Qed.

Lemma eval_level_cmd_place_object_current_area_source :
  forall e le memory area,
    level_cmd_place_object_current_area_read e memory area ->
    eval_expr level_script_ge e le memory
      level_cmd_place_object_active_area_source
      (Vint (Int.repr area)).
Proof.
  intros e le memory area Hread.
  destruct Hread as (area_block & Hlocal & Hsymbol & Hload).
  unfold level_cmd_place_object_active_area_source.
  eapply eval_Elvalue.
  - apply eval_Evar_global.
    + exact Hlocal.
    + exact Hsymbol.
  - econstructor.
    + reflexivity.
    + exact Hload.
Qed.

Lemma eval_level_cmd_place_object_current_area_source_value :
  forall e le memory area raw_value,
    level_cmd_place_object_current_area_read e memory area ->
    eval_expr level_script_ge e le memory
      level_cmd_place_object_active_area_source raw_value ->
    raw_value = Vint (Int.repr area).
Proof.
  intros e le memory area raw_value Hread Hexpr.
  destruct Hread as (area_block & Hlocal & Hsymbol & Hload).
  unfold level_cmd_place_object_active_area_source in Hexpr.
  inv Hexpr.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
  end.
  - congruence.
  - assert (loc = area_block) by congruence.
    subst loc.
    inv H0;
      match goal with
      | Haccess :
          access_mode (typeof (Evar LS._sCurrAreaIndex tshort)) =
          By_value ?chunk |- _ =>
          cbn [typeof access_mode] in Haccess;
          inv Haccess
      | Haccess :
          access_mode (typeof (Evar LS._sCurrAreaIndex tshort)) =
          By_reference |- _ =>
          cbn [typeof access_mode] in Haccess;
          discriminate
      | Haccess :
          access_mode (typeof (Evar LS._sCurrAreaIndex tshort)) =
          By_copy |- _ =>
          cbn [typeof access_mode] in Haccess;
          discriminate
      end.
    match goal with
    | Hmem :
        Mem.loadv Mint16signed memory (Vptr area_block Ptrofs.zero) =
        Some raw_value |- _ =>
        rewrite Hload in Hmem;
        inv Hmem
    end.
    reflexivity.
Qed.

Lemma eval_level_cmd_place_object_active_area_lvalue_normalizes :
  forall e le memory spawn_block spawn_offset loc ofs bf,
    le ! LS._spawnInfo = Some (Vptr spawn_block spawn_offset) ->
    eval_lvalue level_script_ge e le memory
      level_cmd_place_object_active_area_lhs loc ofs bf ->
    loc = spawn_block /\
    ofs =
      Ptrofs.add spawn_offset
        (Ptrofs.repr spawn_info_active_area_offset) /\
    bf = Full.
Proof.
  intros e le memory spawn_block spawn_offset loc ofs bf Hspawn Hlv.
  unfold level_cmd_place_object_active_area_lhs in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with
  | Hbase :
      eval_expr level_script_ge e le memory
        (Ederef
          (Etempvar LS._spawnInfo
            (tptr (Tstruct LS._SpawnInfo noattr)))
          (Tstruct LS._SpawnInfo noattr))
        (Vptr ?base_block ?base_ofs) |- _ =>
      inv Hbase
  end.
  match goal with
  | Hptr : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hptr
  end.
  match goal with
  | Htemp :
      eval_expr level_script_ge e le memory
        (Etempvar LS._spawnInfo
          (tptr (Tstruct LS._SpawnInfo noattr)))
        (Vptr ?base_block ?base_ofs) |- _ =>
      inv Htemp;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : ?temps ! LS._spawnInfo = Some (Vptr ?base_block ?base_ofs) |- _ =>
      assert (base_block = spawn_block) by congruence;
      assert (base_ofs = spawn_offset) by congruence;
      subst base_block base_ofs
  end.
  all:
    try match goal with
    | Hderef :
        deref_loc (Tstruct LS._SpawnInfo noattr) ?mem ?object_block
          ?object_offset Full (Vptr ?base_block ?base_ofs)
        |- _ =>
        pose proof
          (level_script_spawn_info_struct_deref_loc_pointer_same
            mem object_block object_offset base_block base_ofs Hderef)
          as (Hbase_block & Hbase_ofs);
        subst base_block base_ofs
    end.
  rewrite level_script_genv_cenv in *.
  repeat match goal with
  | H : context[typeof (Ederef _ _)] |- _ => progress (cbn [typeof] in H)
  | H : context[typeof (Etempvar _ _)] |- _ =>
      progress (cbn [typeof] in H)
  end.
  match goal with Hty : Tstruct _ _ = Tstruct _ _ |- _ => inv Hty end.
  match goal with
  | Hco : level_script_ce ! LS._SpawnInfo = Some ?co,
    Hfield :
      field_offset level_script_ce LS._activeAreaIndex (co_members ?co) =
      OK (?delta, ?field_bf) |- _ =>
      assert (Hmembers : co_members co = level_script_spawn_info_members) by
        (unfold level_script_spawn_info_members;
         rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite level_script_spawn_info_active_area_layout in Hfield;
      inv Hfield
  end.
  all:
    match goal with
    | Hderef :
        deref_loc (Tstruct LS._SpawnInfo noattr) ?mem ?object_block
          ?object_offset Full (Vptr ?base_block ?base_ofs)
        |- _ =>
        let Hsame := fresh "Hsame" in
        pose proof
          (level_script_spawn_info_struct_deref_loc_pointer_same
            mem object_block object_offset base_block base_ofs Hderef)
          as Hsame;
        clear Hderef;
        destruct Hsame as [? ?];
        subst base_block base_ofs
    | _ => idtac
    end;
    repeat split; reflexivity.
Qed.

Definition level_script_sassign_effect
    (lhs rhs : expr) (e : env) (le : temp_env)
    (before after : mem) : Prop :=
  exists loc ofs bf raw_value stored_value,
    eval_lvalue level_script_ge e le before lhs loc ofs bf /\
    eval_expr level_script_ge e le before rhs raw_value /\
    Cop.sem_cast raw_value (typeof rhs) (typeof lhs) before =
      Some stored_value /\
    assign_loc level_script_ce (typeof lhs) before loc ofs bf
      stored_value after.

Lemma exec_level_script_sassign_effect_from_exec_stmt :
  forall e le before lhs rhs trace le' after outcome,
    exec_stmt function_entry2 level_script_ge e le before
      (Sassign lhs rhs) trace le' after outcome ->
    level_script_sassign_effect lhs rhs e le before after /\
    trace = E0 /\ le' = le /\ outcome = Out_normal.
Proof.
  intros e le before lhs rhs trace le' after outcome Hexec.
  inv Hexec.
  rewrite level_script_genv_cenv in *.
  split.
  - unfold level_script_sassign_effect.
    repeat eexists; eauto.
  - repeat split; reflexivity.
Qed.

Lemma exec_level_script_sset_effect_from_exec_stmt :
  forall e le before target rhs trace le' after outcome,
    exec_stmt function_entry2 level_script_ge e le before
      (Sset target rhs) trace le' after outcome ->
    exists value,
      eval_expr level_script_ge e le before rhs value /\
      trace = E0 /\
      le' = PTree.set target value le /\
      after = before /\
      outcome = Out_normal.
Proof.
  intros e le before target rhs trace le' after outcome Hexec.
  inv Hexec.
  exists v.
  repeat split; reflexivity || assumption.
Qed.

Lemma level_cmd_place_object_active_area_sassign_effect_assign_loc :
  forall e le before after spawn_block spawn_offset,
    le ! LS._spawnInfo = Some (Vptr spawn_block spawn_offset) ->
    le ! LS._t'17 = Some (Vint (Int.repr ssl_pyramid_area)) ->
    level_script_sassign_effect
      level_cmd_place_object_active_area_lhs
      level_cmd_place_object_active_area_rhs
      e le before after ->
    assign_loc level_script_ce tschar before spawn_block
      (Ptrofs.add spawn_offset
        (Ptrofs.repr spawn_info_active_area_offset))
      Full (Vint (Int.repr ssl_pyramid_area)) after.
Proof.
  intros e le before after spawn_block spawn_offset
    Hspawn Htemp Heffect.
  destruct Heffect as
    (loc & ofs & bf & raw_value & stored_value &
      Hlv & Hrhs & Hcast & Hassign).
  unfold level_cmd_place_object_active_area_rhs in Hrhs.
  inv Hrhs;
    try (match goal with
         | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
             solve [inv Hl]
         end).
  match goal with
  | Hlookup : le ! LS._t'17 = Some ?raw |- _ =>
      assert (raw = Vint (Int.repr ssl_pyramid_area)) by congruence;
      subst raw
  end.
  vm_compute in Hcast.
  inv Hcast.
  pose proof
    (eval_level_cmd_place_object_active_area_lvalue_normalizes
      e le before spawn_block spawn_offset loc ofs bf Hspawn Hlv)
    as (Hloc & Hofs & Hbf).
  subst loc ofs bf.
  cbn in Hassign.
  exact Hassign.
Qed.

Theorem exec_level_cmd_place_object_active_area_copy_gives_spawninfo_active_area_read :
  forall e le before after trace le' outcome spawn_block spawn_offset,
    le ! LS._spawnInfo = Some (Vptr spawn_block spawn_offset) ->
    level_cmd_place_object_current_area_read
      e before ssl_pyramid_area ->
    exec_stmt function_entry2 level_script_ge e le before
      level_cmd_place_object_active_area_copy trace le' after outcome ->
    spawninfo_active_area_read
      after spawn_block spawn_offset ssl_pyramid_area /\
    trace = E0 /\ outcome = Out_normal.
Proof.
  intros e le before after trace le' outcome spawn_block spawn_offset
    Hspawn Harea Hexec.
  unfold level_cmd_place_object_active_area_copy in Hexec.
  inv Hexec.
  - match goal with
    | Hset :
        exec_stmt function_entry2 level_script_ge e le before
          level_cmd_place_object_active_area_set _ _ _ _ |- _ =>
        destruct
          (exec_level_script_sset_effect_from_exec_stmt
            e le before LS._t'17 level_cmd_place_object_active_area_source
            _ _ _ _ Hset)
          as (read_value & Hread & Htrace_set & Hle_set & Hmemory_set
              & Hout_set);
        subst
    end.
    assert (read_value = Vint (Int.repr ssl_pyramid_area)).
    { eapply eval_level_cmd_place_object_current_area_source_value; eauto. }
    subst read_value.
    match goal with
    | Hassign :
        exec_stmt function_entry2 level_script_ge e
          (PTree.set LS._t'17 (Vint (Int.repr ssl_pyramid_area)) le)
          before level_cmd_place_object_active_area_assign _ _ _ _ |- _ =>
        destruct
          (exec_level_script_sassign_effect_from_exec_stmt
            e (PTree.set LS._t'17 (Vint (Int.repr ssl_pyramid_area)) le)
            before level_cmd_place_object_active_area_lhs
            level_cmd_place_object_active_area_rhs _ _ _ _ Hassign)
          as (Heffect & Htrace_assign & Hle_assign & Hout_assign);
        subst
    end.
    assert (Hspawn_after_set :
      (PTree.set LS._t'17 (Vint (Int.repr ssl_pyramid_area)) le) !
        LS._spawnInfo = Some (Vptr spawn_block spawn_offset)).
    { rewrite PTree.gso.
      - exact Hspawn.
      - intro Heq.
        vm_compute in Heq.
        discriminate. }
    assert (Ht17_after_set :
      (PTree.set LS._t'17 (Vint (Int.repr ssl_pyramid_area)) le) !
        LS._t'17 = Some (Vint (Int.repr ssl_pyramid_area))).
    { rewrite PTree.gss.
      reflexivity. }
    pose proof
      (level_cmd_place_object_active_area_sassign_effect_assign_loc
        e (PTree.set LS._t'17 (Vint (Int.repr ssl_pyramid_area)) le)
        before after spawn_block spawn_offset
        Hspawn_after_set Ht17_after_set Heffect)
      as Hassign_loc.
    pose proof
      (assign_loc_tschar_store
        level_script_ce before spawn_block
        (Ptrofs.add spawn_offset
          (Ptrofs.repr spawn_info_active_area_offset))
        (Int.repr ssl_pyramid_area) after Hassign_loc)
      as Hstore.
    split.
    + unfold spawninfo_active_area_read, Mem.loadv.
      cbn.
      erewrite Mem.load_store_same by exact Hstore.
      reflexivity.
    + repeat split; simpl; reflexivity.
  - match goal with
    | Hset :
        exec_stmt function_entry2 level_script_ge e le before
          level_cmd_place_object_active_area_set _ _ _ _ |- _ =>
        destruct
          (exec_level_script_sset_effect_from_exec_stmt
            e le before LS._t'17 level_cmd_place_object_active_area_source
            _ _ _ _ Hset)
          as (_ & _ & _ & _ & _ & Hout_set);
        subst
    end.
    contradiction.
Qed.

Lemma eval_geo_obj_init_spawninfo_active_area_lvalue_normalizes :
  forall e le memory pool_block slot loc ofs bf,
    le ! G._graphNode =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    eval_lvalue graph_node_ge e le memory
      geo_obj_init_spawninfo_active_area_lhs loc ofs bf ->
    loc = pool_block /\
    ofs =
      Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr object_active_area_offset) /\
    bf = Full.
Proof.
  intros e le memory pool_block slot loc ofs bf HgraphNode Hlv.
  unfold geo_obj_init_spawninfo_active_area_lhs in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with
  | Hbase :
      eval_expr graph_node_ge e le memory
        (Ederef
          (Etempvar G._graphNode
            (tptr (Tstruct G._GraphNodeObject noattr)))
          (Tstruct G._GraphNodeObject noattr))
        (Vptr ?base_block ?base_ofs) |- _ =>
      inv Hbase
  end.
  match goal with
  | Hptr : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hptr
  end.
  match goal with
  | Htemp :
      eval_expr graph_node_ge e le memory
        (Etempvar G._graphNode
          (tptr (Tstruct G._GraphNodeObject noattr)))
        (Vptr ?base_block ?base_ofs) |- _ =>
      inv Htemp;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : ?temps ! G._graphNode = Some (Vptr ?base_block ?base_ofs) |- _ =>
      assert (base_block = pool_block) by congruence;
      assert (base_ofs = Ptrofs.repr (slot * object_slot_size)) by congruence;
      subst base_block base_ofs
  end.
  all:
    try match goal with
    | Hderef :
        deref_loc (Tstruct G._GraphNodeObject noattr) ?mem ?object_block
          ?object_offset Full (Vptr ?base_block ?base_ofs)
        |- _ =>
        pose proof
          (graph_node_object_struct_deref_loc_pointer_same
            mem object_block object_offset base_block base_ofs Hderef)
          as (Hbase_block & Hbase_ofs);
        subst base_block base_ofs
    end.
  rewrite graph_node_genv_cenv in *.
  repeat match goal with
  | H : context[typeof (Ederef _ _)] |- _ => progress (cbn [typeof] in H)
  | H : context[typeof (Etempvar _ _)] |- _ =>
      progress (cbn [typeof] in H)
  end.
  match goal with Hty : Tstruct _ _ = Tstruct _ _ |- _ => inv Hty end.
  match goal with
  | Hco : graph_node_ce ! G._GraphNodeObject = Some ?co,
    Hfield :
      field_offset graph_node_ce G._activeAreaIndex (co_members ?co) =
      OK (?delta, ?field_bf) |- _ =>
      assert (Hmembers : co_members co =
        generated_graph_node_object_members) by
        (unfold generated_graph_node_object_members;
         rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite generated_graph_node_object_active_area_layout in Hfield;
      inv Hfield
  end.
  all:
    match goal with
    | Hderef :
        deref_loc (Tstruct G._GraphNodeObject noattr) ?mem ?object_block
          ?object_offset Full (Vptr ?base_block ?base_ofs)
        |- _ =>
        let Hsame := fresh "Hsame" in
        pose proof
          (graph_node_object_struct_deref_loc_pointer_same
            mem object_block object_offset base_block base_ofs Hderef)
          as Hsame;
        clear Hderef;
        destruct Hsame as [? ?];
        subst base_block base_ofs
    | _ => idtac
    end;
    repeat split; reflexivity.
Qed.

Lemma eval_geo_obj_init_spawninfo_active_area_source_lvalue_normalizes :
  forall e le memory spawn_block spawn_offset loc ofs bf,
    le ! G._spawn = Some (Vptr spawn_block spawn_offset) ->
    eval_lvalue graph_node_ge e le memory
      geo_obj_init_spawninfo_active_area_source loc ofs bf ->
    loc = spawn_block /\
    ofs =
      Ptrofs.add spawn_offset
        (Ptrofs.repr spawn_info_active_area_offset) /\
    bf = Full.
Proof.
  intros e le memory spawn_block spawn_offset loc ofs bf Hspawn Hlv.
  unfold geo_obj_init_spawninfo_active_area_source in Hlv.
  inv Hlv;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with
  | Hbase :
      eval_expr graph_node_ge e le memory
        (Ederef
          (Etempvar G._spawn (tptr (Tstruct G._SpawnInfo noattr)))
          (Tstruct G._SpawnInfo noattr))
        (Vptr ?base_block ?base_ofs) |- _ =>
      inv Hbase
  end.
  match goal with
  | Hptr : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hptr
  end.
  match goal with
  | Htemp :
      eval_expr graph_node_ge e le memory
        (Etempvar G._spawn (tptr (Tstruct G._SpawnInfo noattr)))
        (Vptr ?base_block ?base_ofs) |- _ =>
      inv Htemp;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
               solve [inv Hl]
           end)
  end.
  match goal with
  | Hlookup : ?temps ! G._spawn = Some (Vptr ?base_block ?base_ofs) |- _ =>
      assert (base_block = spawn_block) by congruence;
      assert (base_ofs = spawn_offset) by congruence;
      subst base_block base_ofs
  end.
  all:
    try match goal with
    | Hderef :
        deref_loc (Tstruct G._SpawnInfo noattr) ?mem ?object_block
          ?object_offset Full (Vptr ?base_block ?base_ofs)
        |- _ =>
        pose proof
          (spawn_info_struct_deref_loc_pointer_same
            mem object_block object_offset base_block base_ofs Hderef)
          as (Hbase_block & Hbase_ofs);
        subst base_block base_ofs
    end.
  rewrite graph_node_genv_cenv in *.
  repeat match goal with
  | H : context[typeof (Ederef _ _)] |- _ => progress (cbn [typeof] in H)
  | H : context[typeof (Etempvar _ _)] |- _ =>
      progress (cbn [typeof] in H)
  end.
  match goal with Hty : Tstruct _ _ = Tstruct _ _ |- _ => inv Hty end.
  match goal with
  | Hco : graph_node_ce ! G._SpawnInfo = Some ?co,
    Hfield :
      field_offset graph_node_ce G._activeAreaIndex (co_members ?co) =
      OK (?delta, ?field_bf) |- _ =>
      assert (Hmembers : co_members co = generated_spawn_info_members) by
        (unfold generated_spawn_info_members;
         rewrite Hco; reflexivity);
      rewrite Hmembers in Hfield;
      rewrite generated_spawn_info_active_area_layout in Hfield;
      inv Hfield
  end.
  all:
    match goal with
    | Hderef :
        deref_loc (Tstruct G._SpawnInfo noattr) ?mem ?object_block
          ?object_offset Full (Vptr ?base_block ?base_ofs)
        |- _ =>
        let Hsame := fresh "Hsame" in
        pose proof
          (spawn_info_struct_deref_loc_pointer_same
            mem object_block object_offset base_block base_ofs Hderef)
          as Hsame;
        clear Hderef;
        destruct Hsame as [? ?];
        subst base_block base_ofs
    | _ => idtac
    end;
    repeat split; reflexivity.
Qed.

Lemma eval_geo_obj_init_spawninfo_active_area_source_reads_area :
  forall e le memory spawn_block spawn_offset area raw_value,
    le ! G._spawn = Some (Vptr spawn_block spawn_offset) ->
    spawninfo_active_area_read memory spawn_block spawn_offset area ->
    eval_expr graph_node_ge e le memory
      geo_obj_init_spawninfo_active_area_source raw_value ->
    raw_value = Vint (Int.repr area).
Proof.
  intros e le memory spawn_block spawn_offset area raw_value
    Hspawn Hload Hexpr.
  unfold spawninfo_active_area_read in Hload.
  inv Hexpr.
  pose proof
    (eval_geo_obj_init_spawninfo_active_area_source_lvalue_normalizes
      e le memory spawn_block spawn_offset loc ofs bf Hspawn H)
    as (Hloc & Hofs & Hbf).
  subst loc ofs bf.
  inv H0;
    simpl in *;
    try discriminate.
  inversion H1; subst.
  unfold Mem.loadv in H2.
  rewrite Hload in H2.
  inv H2.
  reflexivity.
Qed.

Definition geo_obj_init_spawninfo_active_area_copy_effect
    (e : env) (le : temp_env) (before after : mem) : Prop :=
  exists read_value,
    eval_expr graph_node_ge e le before
      geo_obj_init_spawninfo_active_area_source
      read_value /\
    generated_sassign_effect
      geo_obj_init_spawninfo_active_area_lhs
      geo_obj_init_spawninfo_active_area_rhs
      e
      (PTree.set G._t'6 read_value le)
      before after.

Theorem exec_geo_obj_init_spawninfo_active_area_assign_exposes_sassign_effect :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_obj_init_spawninfo_active_area_assign trace le' memory' outcome ->
    generated_sassign_effect
      geo_obj_init_spawninfo_active_area_lhs
      geo_obj_init_spawninfo_active_area_rhs
      e le memory memory' /\
    trace = E0 /\ le' = le /\ outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_obj_init_spawninfo_active_area_assign in Hexec.
  eapply exec_generated_sassign_effect_from_exec_stmt.
  exact Hexec.
Qed.

Theorem exec_geo_obj_init_spawninfo_active_area_copy_exposes_effect :
  forall e le memory trace le' memory' outcome,
    exec_stmt function_entry2 graph_node_ge e le memory
      geo_obj_init_spawninfo_active_area_copy trace le' memory' outcome ->
    geo_obj_init_spawninfo_active_area_copy_effect e le memory memory' /\
    trace = E0 /\ outcome = Out_normal.
Proof.
  intros e le memory trace le' memory' outcome Hexec.
  unfold geo_obj_init_spawninfo_active_area_copy in Hexec.
  inv Hexec.
  - match goal with
    | Hset :
        exec_stmt function_entry2 graph_node_ge e le memory
          geo_obj_init_spawninfo_active_area_set _ _ _ _ |- _ =>
        destruct
          (exec_generated_sset_effect_from_exec_stmt
            e le memory G._t'6 geo_obj_init_spawninfo_active_area_source
            _ _ _ _ Hset)
          as (read_value & Hread & Htrace_set & Hle_set & Hmemory_set
              & Hout_set);
        subst
    end.
    match goal with
    | Hassign :
        exec_stmt function_entry2 graph_node_ge e
          (PTree.set G._t'6 ?read_value le) memory
          geo_obj_init_spawninfo_active_area_assign _ _ _ _ |- _ =>
        destruct
          (exec_geo_obj_init_spawninfo_active_area_assign_exposes_sassign_effect
            e (PTree.set G._t'6 read_value le) memory _ _ _ _ Hassign)
          as (Heffect & Htrace_assign & Hle_assign & Hout_assign);
        subst
    end.
    split.
    + exists read_value.
      split; assumption.
    + repeat split; simpl; reflexivity.
  - match goal with
    | Hset :
        exec_stmt function_entry2 graph_node_ge e le memory
          geo_obj_init_spawninfo_active_area_set _ _ _ _ |- _ =>
        destruct
          (exec_generated_sset_effect_from_exec_stmt
            e le memory G._t'6 geo_obj_init_spawninfo_active_area_source
            _ _ _ _ Hset)
          as (_ & _ & _ & _ & _ & Hout_set);
        subst
    end.
    contradiction.
Qed.

Theorem geo_obj_init_spawninfo_active_area_copy_effect_assign_loc :
  forall e le before after pool_block slot spawn_block spawn_offset,
    le ! G._graphNode =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    le ! G._spawn = Some (Vptr spawn_block spawn_offset) ->
    spawninfo_active_area_read
      before spawn_block spawn_offset ssl_pyramid_area ->
    geo_obj_init_spawninfo_active_area_copy_effect e le before after ->
    assign_loc graph_node_ge tschar before pool_block
      (Ptrofs.add
        (Ptrofs.repr ((slot * object_slot_size)%Z))
        (Ptrofs.repr object_active_area_offset))
      Full (Vint (Int.repr ssl_pyramid_area)) after.
Proof.
  intros e le before after pool_block slot spawn_block spawn_offset
    HgraphNode Hspawn Hspawn_area Heffect.
  destruct Heffect as (read_value & Hread & Heffect).
  pose proof
    (eval_geo_obj_init_spawninfo_active_area_source_reads_area
      e le before spawn_block spawn_offset ssl_pyramid_area
      read_value Hspawn Hspawn_area Hread) as Hread_value.
  subst read_value.
  destruct Heffect as
    (loc & ofs & bf & raw_value & stored_value &
      Hlv & Hrhs & Hcast & Hassign).
  unfold geo_obj_init_spawninfo_active_area_rhs in Hrhs.
  inv Hrhs;
    try (match goal with
         | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
             solve [inv Hl]
         end).
  match goal with
  | Hlookup :
      (PTree.set G._t'6 (Vint (Int.repr ssl_pyramid_area)) le) !
        G._t'6 = Some ?raw |- _ =>
      rewrite PTree.gss in Hlookup;
      inv Hlookup
  end.
  vm_compute in Hcast.
  inv Hcast.
  assert (HgraphNode_after_set :
    (PTree.set G._t'6 (Vint (Int.repr ssl_pyramid_area)) le) !
      G._graphNode =
    Some (Vptr pool_block
      (Ptrofs.repr ((slot * object_slot_size)%Z)))).
  { rewrite PTree.gso.
    - exact HgraphNode.
    - intro Heq.
      vm_compute in Heq.
      discriminate. }
  pose proof
    (eval_geo_obj_init_spawninfo_active_area_lvalue_normalizes
      e
      (PTree.set G._t'6 (Vint (Int.repr ssl_pyramid_area)) le)
      before pool_block slot loc ofs bf
      HgraphNode_after_set Hlv) as (Hloc & Hofs & Hbf).
  subst loc ofs bf.
  cbn in Hassign.
  exact Hassign.
Qed.

Theorem concrete_same_slot_allocation_assign_locs_from_generated_effects :
  forall allocation_e allocation_le active_area_e active_area_le
      allocation_start after_active_flags_store after_load
      pool_block slot spawn_block spawn_offset,
    allocation_le ! S._obj =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    allocate_object_active_flags_value_effect
      allocation_e allocation_le allocation_start after_active_flags_store ->
    active_area_le ! G._graphNode =
      Some (Vptr pool_block
        (Ptrofs.repr ((slot * object_slot_size)%Z))) ->
    active_area_le ! G._spawn = Some (Vptr spawn_block spawn_offset) ->
    spawninfo_active_area_read
      after_active_flags_store spawn_block spawn_offset ssl_pyramid_area ->
    geo_obj_init_spawninfo_active_area_copy_effect
      active_area_e active_area_le after_active_flags_store after_load ->
    concrete_same_slot_allocation_assign_locs graph_node_ge
      allocation_start after_active_flags_store after_load pool_block slot.
Proof.
  intros allocation_e allocation_le active_area_e active_area_le
    allocation_start after_active_flags_store after_load
    pool_block slot spawn_block spawn_offset
    Hobj Heffect_active_flags HgraphNode Hspawn Hspawn_area
    Heffect_active_area.
  constructor.
  - unfold object_allocation_active_flags_value.
    eapply allocate_object_active_flags_value_effect_assign_loc; eauto.
  - eapply geo_obj_init_spawninfo_active_area_copy_effect_assign_loc; eauto.
Qed.

Definition generated_same_slot_assignment_inversion_audit : Prop :=
  proposition_of exec_allocate_object_active_flags_assign_exposes_sassign_effect /\
  proposition_of exec_allocate_object_active_flags_assign_exposes_value_effect /\
  proposition_of exec_allocate_object_active_flags_assign_exposes_slot_assign_loc /\
  proposition_of
    exec_geo_obj_init_spawninfo_active_area_assign_exposes_sassign_effect /\
  proposition_of
    exec_geo_obj_init_spawninfo_active_area_copy_exposes_effect /\
  proposition_of geo_obj_init_spawninfo_active_area_copy_effect_assign_loc /\
  proposition_of concrete_same_slot_allocation_assign_locs_from_generated_effects.

Theorem generated_same_slot_assignment_inversion_audit_holds :
  generated_same_slot_assignment_inversion_audit.
Proof.
  unfold generated_same_slot_assignment_inversion_audit,
    proposition_of.
  split; [exact exec_allocate_object_active_flags_assign_exposes_sassign_effect |].
  split; [exact exec_allocate_object_active_flags_assign_exposes_value_effect |].
  split; [exact exec_allocate_object_active_flags_assign_exposes_slot_assign_loc |].
  split.
  - exact exec_geo_obj_init_spawninfo_active_area_assign_exposes_sassign_effect.
  - split; [exact exec_geo_obj_init_spawninfo_active_area_copy_exposes_effect |].
    split; [exact geo_obj_init_spawninfo_active_area_copy_effect_assign_loc |].
    exact concrete_same_slot_allocation_assign_locs_from_generated_effects.
Qed.

Definition same_slot_reuse_generated_order_receipt_audit : Prop :=
  proposition_of generated_same_slot_reuse_order_spine_holds /\
  proposition_of ssl_pyramid_destination_spawn_info_source_supplies_area_2 /\
  proposition_of level_cmd_place_object_copies_current_area_to_spawn_active_area /\
  proposition_of
    ssl_pyramid_destination_allocation_count_before_init_lower_bound_is_70 /\
  proposition_of deallocate_push_then_first_allocation_reuses_same_slot /\
  proposition_of deallocated_slot_at_head_is_reached_by_one_allocation /\
  proposition_of watched_slot_under_newer_free_slots_needs_enough_allocations /\
  proposition_of unload_order_suffix_gives_watched_slot_free_list_depth /\
  proposition_of same_slot_pyramid_allocation_store_trace_from_receipt /\
  proposition_of
    same_slot_pyramid_allocation_store_trace_from_linked_assign_locs /\
  proposition_of generated_same_slot_assignment_inversion_audit_holds.

Theorem ssl_pyramid_destination_allocations_reach_slot_if_depth_below_70 :
  forall newer_slots older_slots watched_slot,
    (length newer_slots <
     ssl_pyramid_destination_allocation_count_before_init_lower_bound)%nat ->
    allocation_count_reaches_watched_slot
      (newer_slots ++ watched_slot :: older_slots)
      watched_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound.
Proof.
  intros newer_slots older_slots watched_slot Hdepth.
  apply watched_slot_under_newer_free_slots_needs_enough_allocations.
  exact Hdepth.
Qed.

Theorem generated_unload_suffix_depth_reaches_watched_slot_if_below_70 :
  forall initial_free_list prefix suffix watched_slot,
    (length suffix <
     ssl_pyramid_destination_allocation_count_before_init_lower_bound)%nat ->
    allocation_count_reaches_watched_slot
      (free_list_after_deallocation_targets initial_free_list
        (prefix ++ watched_slot :: suffix))
      watched_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound.
Proof.
  intros initial_free_list prefix suffix watched_slot Hdepth.
  apply unload_order_suffix_gives_watched_slot_free_list_depth.
  exact Hdepth.
Qed.

Theorem generated_traversal_free_list_depth_from_unload_targets :
  forall before barrier pool_block snapshot initial_free_list
      prefix suffix watched_slot allocation_count,
    generated_object_list_traversal_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    unload_targets ssl_outside_area snapshot =
      prefix ++ watched_slot :: suffix ->
    (length suffix < allocation_count)%nat ->
    allocation_count_reaches_watched_slot
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      watched_slot allocation_count.
Proof.
  intros before barrier pool_block snapshot initial_free_list
    prefix suffix watched_slot allocation_count _ Htargets Hdepth.
  rewrite Htargets.
  apply unload_order_suffix_gives_watched_slot_free_list_depth.
  exact Hdepth.
Qed.

Theorem generated_traversal_reaches_watched_slot_if_suffix_below_70 :
  forall before barrier pool_block snapshot initial_free_list
      prefix suffix watched_slot,
    generated_object_list_traversal_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    unload_targets ssl_outside_area snapshot =
      prefix ++ watched_slot :: suffix ->
    (length suffix <
     ssl_pyramid_destination_allocation_count_before_init_lower_bound)%nat ->
    allocation_count_reaches_watched_slot
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      watched_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound.
Proof.
  intros before barrier pool_block snapshot initial_free_list
    prefix suffix watched_slot Hcertificate Htargets Hdepth.
  eapply generated_traversal_free_list_depth_from_unload_targets;
    eauto.
Qed.

Record unload_objects_from_area_generated_loop_certificate
    (before barrier : mem) (pool_block : block) (area : Z)
    (snapshot : object_list_snapshot) : Prop := {
  generated_loop_body_is_f_unload_objects_from_area :
    proposition_of unload_objects_from_area_traversal_spine;
  generated_loop_snapshot_well_formed :
    snapshot_well_formed before pool_block snapshot;
  generated_loop_unload_trace :
    generated_unload_execution_trace pool_block before
      (unload_targets area snapshot) barrier
}.

Theorem generated_object_list_traversal_certificate_from_f_unload_objects_from_area_loop :
  forall before barrier pool_block area snapshot,
    unload_objects_from_area_generated_loop_certificate
      before barrier pool_block area snapshot ->
    generated_object_list_traversal_certificate
      before barrier pool_block area snapshot.
Proof.
  intros before barrier pool_block area snapshot Hloop.
  destruct Hloop as [_ Hsnapshot Htrace].
  constructor.
  - exact Hsnapshot.
  - exact Htrace.
Qed.

Lemma nth_error_factorizes_list :
  forall {A : Type} (xs : list A) index value,
    nth_error xs index = Some value ->
    xs = firstn index xs ++ value :: skipn (S index) xs.
Proof.
  intros A xs.
  induction xs as [| head tail IHtail].
  - intros [| index] value Hnth; inversion Hnth.
  - intros [| index] value Hnth.
    + simpl in Hnth.
      inversion Hnth; subst.
      reflexivity.
    + simpl in Hnth.
      simpl.
      f_equal.
      apply IHtail.
      exact Hnth.
Qed.

Theorem generated_loop_reaches_watched_slot_by_target_index_if_tail_below_70 :
  forall before barrier pool_block snapshot initial_free_list
      target_index watched_slot,
    unload_objects_from_area_generated_loop_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    nth_error (unload_targets ssl_outside_area snapshot) target_index =
      Some watched_slot ->
    (length
      (skipn (S target_index)
        (unload_targets ssl_outside_area snapshot)) <
     ssl_pyramid_destination_allocation_count_before_init_lower_bound)%nat ->
    allocation_count_reaches_watched_slot
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      watched_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound.
Proof.
  intros before barrier pool_block snapshot initial_free_list
    target_index watched_slot Hloop Hnth Htail_depth.
  eapply generated_traversal_reaches_watched_slot_if_suffix_below_70
    with
      (before := before)
      (barrier := barrier)
      (pool_block := pool_block)
      (snapshot := snapshot)
      (prefix :=
        firstn target_index (unload_targets ssl_outside_area snapshot))
      (suffix :=
        skipn (S target_index)
          (unload_targets ssl_outside_area snapshot)).
  - eapply
      generated_object_list_traversal_certificate_from_f_unload_objects_from_area_loop.
    exact Hloop.
  - apply nth_error_factorizes_list.
    exact Hnth.
  - exact Htail_depth.
Qed.

Theorem generated_loop_reaches_watched_slot_if_target_list_at_most_70 :
  forall before barrier pool_block snapshot initial_free_list watched_slot,
    unload_objects_from_area_generated_loop_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    In watched_slot (unload_targets ssl_outside_area snapshot) ->
    (length (unload_targets ssl_outside_area snapshot) <=
     ssl_pyramid_destination_allocation_count_before_init_lower_bound)%nat ->
    allocation_count_reaches_watched_slot
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      watched_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound.
Proof.
  intros before barrier pool_block snapshot initial_free_list
    watched_slot Hloop Hin Htarget_count.
  destruct
    (in_split watched_slot
      (unload_targets ssl_outside_area snapshot) Hin)
    as (prefix & suffix & Htargets).
  eapply generated_traversal_reaches_watched_slot_if_suffix_below_70
    with
      (before := before)
      (barrier := barrier)
      (pool_block := pool_block)
      (snapshot := snapshot)
      (prefix := prefix)
      (suffix := suffix).
  - eapply
      generated_object_list_traversal_certificate_from_f_unload_objects_from_area_loop.
    exact Hloop.
  - exact Htargets.
  - rewrite Htargets in Htarget_count.
    rewrite app_length in Htarget_count.
    simpl in Htarget_count.
    lia.
Qed.

Theorem held_grab_generated_loop_same_slot_reuse_counterexample_if_target_list_at_most_70 :
  forall before barrier allocation_start after_active_flags_store after_load
      active_area_ce pool_block snapshot initial_free_list outside_slot
      destination_spawn_slot,
    unload_objects_from_area_generated_loop_certificate
      before barrier pool_block ssl_outside_area snapshot ->
    In outside_slot (unload_targets ssl_outside_area snapshot) ->
    (length (unload_targets ssl_outside_area snapshot) <=
     ssl_pyramid_destination_allocation_count_before_init_lower_bound)%nat ->
    outside_live_slot before pool_block outside_slot ->
    concrete_same_slot_allocation_assign_locs active_area_ce
      allocation_start after_active_flags_store after_load
      pool_block outside_slot ->
    same_slot_pyramid_allocation_receipt
      allocation_start after_active_flags_store after_load
      pool_block
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      outside_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound /\
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      audited_technical_stale_pyramid_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before barrier allocation_start after_active_flags_store after_load
    active_area_ce pool_block snapshot initial_free_list outside_slot
    destination_spawn_slot Hloop Hin Htarget_count Houtside Hassigns.
  assert (Hreaches :
    allocation_count_reaches_watched_slot
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      outside_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound).
  { eapply generated_loop_reaches_watched_slot_if_target_list_at_most_70;
      eauto. }
  assert (Hvalid : valid_object_slot outside_slot).
  { destruct Houtside as (Hvalid & _).
    exact Hvalid. }
  pose proof
    (same_slot_pyramid_allocation_receipt_from_linked_assign_locs
      active_area_ce allocation_start after_active_flags_store after_load
      pool_block
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      outside_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound
      Hvalid Hreaches Hassigns) as Hreceipt.
  pose proof
    (same_slot_pyramid_allocation_store_trace_from_receipt
      allocation_start after_active_flags_store after_load
      pool_block
      (free_list_after_deallocation_targets initial_free_list
        (unload_targets ssl_outside_area snapshot))
      outside_slot
      ssl_pyramid_destination_allocation_count_before_init_lower_bound
      Hreceipt) as Hstores.
  split; [exact Hreceipt |].
  eapply held_grab_constructs_audited_technical_pyramid_slot_reuse_counterexample;
    eauto.
Qed.

Definition generated_unload_traversal_certificate_audit : Prop :=
  proposition_of unload_objects_from_area_traversal_spine /\
  proposition_of
    generated_object_list_traversal_certificate_from_f_unload_objects_from_area_loop /\
  proposition_of
    generated_loop_reaches_watched_slot_by_target_index_if_tail_below_70 /\
  proposition_of
    generated_loop_reaches_watched_slot_if_target_list_at_most_70 /\
  proposition_of
    held_grab_generated_loop_same_slot_reuse_counterexample_if_target_list_at_most_70.

Theorem generated_unload_traversal_certificate_audit_holds :
  generated_unload_traversal_certificate_audit.
Proof.
  unfold generated_unload_traversal_certificate_audit,
    proposition_of.
  split; [exact unload_objects_from_area_traversal_spine |].
  split.
  - exact
      generated_object_list_traversal_certificate_from_f_unload_objects_from_area_loop.
  - split.
    + exact
        generated_loop_reaches_watched_slot_by_target_index_if_tail_below_70.
    + split.
      * exact generated_loop_reaches_watched_slot_if_target_list_at_most_70.
      * exact
          held_grab_generated_loop_same_slot_reuse_counterexample_if_target_list_at_most_70.
Qed.

Theorem same_slot_reuse_generated_order_receipt_audit_holds :
  same_slot_reuse_generated_order_receipt_audit.
Proof.
  unfold same_slot_reuse_generated_order_receipt_audit,
    proposition_of.
  split; [exact generated_same_slot_reuse_order_spine_holds |].
  split; [exact ssl_pyramid_destination_spawn_info_source_supplies_area_2 |].
  split;
    [ exact level_cmd_place_object_copies_current_area_to_spawn_active_area
    |].
  split;
    [ exact
        ssl_pyramid_destination_allocation_count_before_init_lower_bound_is_70
    |].
  split; [exact deallocate_push_then_first_allocation_reuses_same_slot |].
  split; [exact deallocated_slot_at_head_is_reached_by_one_allocation |].
  split; [exact watched_slot_under_newer_free_slots_needs_enough_allocations |].
  split; [exact unload_order_suffix_gives_watched_slot_free_list_depth |].
  split; [exact same_slot_pyramid_allocation_store_trace_from_receipt |].
  split; [exact same_slot_pyramid_allocation_store_trace_from_linked_assign_locs |].
  exact generated_same_slot_assignment_inversion_audit_holds.
Qed.

Theorem held_grab_reused_slot_alias_is_technical_not_gameplay_useful :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_held_grab_load_window
          outside_slot destination_spawn_slot /\
      technical_stale_slot_alias_without_generated_use
        before after_load pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (held_grab_reused_slot_alias_is_unobserved_before_cleanup
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Halias & Hclean & Haudit).
  exists window.
  split; [exact Hwindow |].
  split.
  - subst window.
    unfold technical_stale_pointer_smuggled_into_load_window,
      stale_outside_reference_after_pyramid_load.
    exists outside_slot.
    split; [exact Houtside |].
    unfold mario_reference_origin_list, outside_held_grab_load_window,
      outside_held_grab_refs.
    simpl.
    right; left; reflexivity.
  - split; [exact Halias |].
    split; [exact Hclean | exact Haudit].
Qed.

Definition direct_grabbable_held_stale_reference_audit : Prop :=
  proposition_of outside_pyramid_direct_grabbable_channels_exact /\
  proposition_of
    outside_pyramid_held_reference_channels_are_exact_direct_grabbables /\
  proposition_of outside_pyramid_held_reference_classifications_exact /\
  proposition_of outside_pyramid_direct_channels_are_grabbable_behaviors /\
  proposition_of interact_grabbable_sets_interact_root_not_ridden /\
  proposition_of mario_check_object_grab_moves_interact_to_used_not_ridden /\
  proposition_of mario_grab_used_object_moves_used_to_held_not_ridden /\
  proposition_of direct_grabbable_channel_mario_reference_cleanup_evidence /\
  proposition_of
    held_grab_constructs_audited_technical_stale_window_counterexample /\
  proposition_of
    held_grab_constructs_audited_technical_slot_reuse_counterexample /\
  proposition_of
    held_grab_constructs_audited_technical_pyramid_slot_reuse_counterexample /\
  proposition_of held_grab_reused_slot_alias_is_technical_not_gameplay_useful.

Theorem direct_grabbable_held_stale_reference_audit_holds :
  direct_grabbable_held_stale_reference_audit.
Proof.
  unfold direct_grabbable_held_stale_reference_audit,
    proposition_of.
  repeat split;
    first
      [ exact outside_pyramid_direct_grabbable_channels_exact
      | exact outside_pyramid_held_reference_channels_are_exact_direct_grabbables
      | exact outside_pyramid_held_reference_classifications_exact
      | exact outside_pyramid_direct_channels_are_grabbable_behaviors
      | exact interact_grabbable_sets_interact_root_not_ridden
      | exact mario_check_object_grab_moves_interact_to_used_not_ridden
      | exact mario_grab_used_object_moves_used_to_held_not_ridden
      | exact direct_grabbable_channel_mario_reference_cleanup_evidence
      | exact held_grab_constructs_audited_technical_stale_window_counterexample
      | exact held_grab_constructs_audited_technical_slot_reuse_counterexample
      | exact held_grab_constructs_audited_technical_pyramid_slot_reuse_counterexample
      | exact held_grab_reused_slot_alias_is_technical_not_gameplay_useful ].
Qed.

Definition shell_ride_ridden_alias_without_generated_use
    (before after_load : mem) (pool_block : block)
    (window : pyramid_load_window_reference_origins) : Prop :=
  technical_stale_slot_alias_without_generated_use
    before after_load pool_block window /\
  stale_ridden_reference_aliases_live_slot
    before after_load pool_block
    (refs_after_pyramid_load_before_mario_init window).

Theorem shell_ride_reused_slot_alias_is_technical_not_gameplay_useful :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window
          outside_slot destination_spawn_slot /\
      shell_ride_ridden_alias_without_generated_use
        before after_load pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (ridden_shell_stale_slot_alias_is_conditional_on_reuse
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hstale & Halias & Hridden_alias & Hclean).
  exists window.
  split; [exact Hwindow |].
  split.
  - split; [exact Hstale |].
    split; [exact Halias |].
    split;
      [ exact Hclean
      | exact audited_mario_stale_ref_no_observation_before_cleanup_holds ].
  - exact Hridden_alias.
Qed.

Theorem shell_ride_constructs_audited_ridden_technical_slot_reuse_counterexample :
  forall before after_load pool_block outside_slot destination_spawn_slot,
    outside_live_slot before pool_block outside_slot ->
    slot_active after_load pool_block outside_slot ->
    exists window,
      window =
        outside_shell_ride_load_window
          outside_slot destination_spawn_slot /\
      audited_ridden_technical_stale_slot_reuse_counterexample
        before after_load pool_block window.
Proof.
  intros before after_load pool_block outside_slot
    destination_spawn_slot Houtside Hactive_after_load.
  destruct
    (shell_ride_constructs_ridden_technical_slot_reuse_counterexample
       before after_load pool_block outside_slot destination_spawn_slot
       Houtside Hactive_after_load)
    as (window & Hwindow & Hcounterexample).
  exists window.
  split; [exact Hwindow |].
  constructor.
  - exact Hcounterexample.
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

Definition weird_action_zero_entry_audit : Prop :=
  proposition_of act_uninitialized_is_zero /\
  proposition_of init_mario_from_save_file_sets_action_uninitialized /\
  proposition_of init_mario_assigns_nonzero_initial_action_shape /\
  proposition_of nonnormal_script_init_debug_demo_warp_entry_audit /\
  proposition_of normal_gameplay_ssl_warp_entry_action_nonzero_syntactic_certificate.

Theorem weird_action_zero_entry_audit_holds :
  weird_action_zero_entry_audit.
Proof.
  unfold weird_action_zero_entry_audit, proposition_of.
  split; [exact act_uninitialized_is_zero |].
  split; [exact init_mario_from_save_file_sets_action_uninitialized |].
  split; [exact init_mario_assigns_nonzero_initial_action_shape |].
  split; [exact nonnormal_script_init_debug_demo_warp_entry_audit |].
  exact normal_gameplay_ssl_warp_entry_action_nonzero_syntactic_certificate.
Qed.

Definition action_zero_stale_mario_root_counterexample_candidate
    (before : mem) (pool_block : block)
    (root : high_risk_outside_pointer_root) (slot : Z) : Prop :=
  root_is_mario_state_reference root = true /\
  persistent_outside_pointer_counterexample_candidate before pool_block
    {| observed_pointer_root := root;
       observed_pointer_origin := OutsideAllocationEpoch slot |}.

Theorem weird_action_zero_stale_mario_root_is_counterexample_candidate :
  forall before pool_block root slot,
    root_is_mario_state_reference root = true ->
    outside_live_slot before pool_block slot ->
    action_zero_stale_mario_root_counterexample_candidate
      before pool_block root slot.
Proof.
  intros before pool_block root slot Hmario Houtside.
  split; [exact Hmario |].
  apply persistent_outside_pointer_from_high_risk_root_is_counterexample_candidate.
  - apply high_risk_outside_pointer_roots_complete.
  - exact Houtside.
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

Theorem count_zero_collided_storage_has_no_active_origins :
  forall stale_collided_storage,
    active_collided_object_origins_after_count
      0 stale_collided_storage = [].
Proof. reflexivity. Qed.

Definition collided_object_array_count_guard_audit : Prop :=
  proposition_of generated_collided_object_array_readers /\
  proposition_of generated_collided_object_array_reads_are_count_preceded /\
  proposition_of object_owned_collided_object_array_writers /\
  proposition_of count_zero_collided_storage_has_no_active_origins.

Theorem collided_object_array_count_guard_audit_holds :
  collided_object_array_count_guard_audit.
Proof.
  unfold collided_object_array_count_guard_audit, proposition_of.
  repeat split;
    first
      [ exact generated_collided_object_array_readers
      | exact generated_collided_object_array_reads_are_count_preceded
      | exact object_owned_collided_object_array_writers
      | exact count_zero_collided_storage_has_no_active_origins ].
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
  proposition_of collided_object_array_count_guard_audit_holds /\
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
      | exact collided_object_array_count_guard_audit_holds
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
  direct_grabbable_held_stale_reference_audit /\
  proposition_of shell_channel_generated_ridden_object_evidence /\
  normal_interact_warp_ridden_object_clearance_audit /\
  proposition_of
    held_grab_constructs_audited_technical_stale_window_counterexample /\
  proposition_of
    shell_ride_constructs_audited_ridden_technical_stale_window_counterexample /\
  proposition_of
    held_grab_constructs_audited_technical_slot_reuse_counterexample /\
  proposition_of
    shell_ride_constructs_audited_ridden_technical_slot_reuse_counterexample /\
  proposition_of
    held_grab_constructs_audited_technical_pyramid_slot_reuse_counterexample /\
  proposition_of
    shell_ride_constructs_audited_ridden_technical_pyramid_slot_reuse_counterexample /\
  stale_mario_object_refs_pyramid_behavior_update_audit /\
  disappeared_warp_held_object_drop_folklore_audit /\
  proposition_of
    shell_ride_ridden_stale_load_window_is_unobserved_before_cleanup /\
  proposition_of
    shell_ride_reused_slot_alias_is_technical_not_gameplay_useful /\
  proposition_of direct_grabbable_channel_mario_reference_cleanup_evidence /\
  audited_mario_stale_ref_no_observation_before_cleanup.

Theorem shell_and_grabbable_stale_channel_load_window_audit_holds :
  shell_and_grabbable_stale_channel_load_window_audit.
Proof.
  unfold shell_and_grabbable_stale_channel_load_window_audit,
    proposition_of.
  split; [exact outside_pyramid_channel_classifications_start_with_shell |].
  split; [exact direct_grabbable_held_stale_reference_audit_holds |].
  split; [exact shell_channel_generated_ridden_object_evidence |].
  split; [exact normal_interact_warp_ridden_object_clearance_audit_holds |].
  split; [
    exact held_grab_constructs_audited_technical_stale_window_counterexample
  |].
  split; [
    exact shell_ride_constructs_audited_ridden_technical_stale_window_counterexample
  |].
  split; [
    exact held_grab_constructs_audited_technical_slot_reuse_counterexample
  |].
  split; [
    exact shell_ride_constructs_audited_ridden_technical_slot_reuse_counterexample
  |].
  split; [
    exact held_grab_constructs_audited_technical_pyramid_slot_reuse_counterexample
  |].
  split; [
    exact shell_ride_constructs_audited_ridden_technical_pyramid_slot_reuse_counterexample
  |].
  split; [
    exact stale_mario_object_refs_pyramid_behavior_update_audit_holds
  |].
  split; [
    exact disappeared_warp_held_object_drop_folklore_audit_holds
  |].
  split; [exact shell_ride_ridden_stale_load_window_is_unobserved_before_cleanup |].
  split; [exact shell_ride_reused_slot_alias_is_technical_not_gameplay_useful |].
  split; [exact direct_grabbable_channel_mario_reference_cleanup_evidence |].
  exact audited_mario_stale_ref_no_observation_before_cleanup_holds.
Qed.
