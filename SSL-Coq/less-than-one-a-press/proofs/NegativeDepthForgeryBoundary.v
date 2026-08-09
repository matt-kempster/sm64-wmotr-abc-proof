(** Bounded forgery audit for the negative-quicksand installer.

    [ZeroAQuicksandEntryBoundary] excludes the ordinary clean no-A route to
    the late landing state.  This file checks the remaining mutable source
    objects which could counterfeit that state: all nine landing descriptors,
    the interaction-dispatch table, and the render-time held-node index which
    can select [gMarioStates].  It also proves byte-precise CompCert memory
    frames for the live action cell.

    No concrete clean-reachable forge is constructed here.  The results are
    generated-AST and CompCert-memory boundaries.  Compiled flat-address OOB
    behavior, live pointer provenance, external effects, and preservation of
    writable globals remain explicit obligations at the end. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import AST Clight Coqlib Ctypes Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_graph_node us_interaction us_mario_misc
  jp_graph_node jp_interaction jp_mario_misc.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ActionDepthAliasCensus EntryMemory
  LongJumpProvenanceBoundary ZeroAQuicksandEntryBoundary.

Import ListNotations.
Local Open Scope Z_scope.

Module NDF_USGraph := us_graph_node.
Module NDF_USInteraction := us_interaction.
Module NDF_USMisc := us_mario_misc.
Module NDF_JPGraph := jp_graph_node.
Module NDF_JPInteraction := jp_interaction.
Module NDF_JPMisc := jp_mario_misc.

(** * Writable landing descriptors *)

Definition ndf_us_landing_descriptor_idents : list ident :=
  [AD_USMove._sJumpLandAction; AD_USMove._sFreefallLandAction;
   AD_USMove._sSideFlipLandAction; AD_USMove._sHoldJumpLandAction;
   AD_USMove._sHoldFreefallLandAction; AD_USMove._sLongJumpLandAction;
   AD_USMove._sDoubleJumpLandAction; AD_USMove._sTripleJumpLandAction;
   AD_USMove._sBackflipLandAction].

Definition ndf_jp_landing_descriptor_idents : list ident :=
  [AD_JPMove._sJumpLandAction; AD_JPMove._sFreefallLandAction;
   AD_JPMove._sSideFlipLandAction; AD_JPMove._sHoldJumpLandAction;
   AD_JPMove._sHoldFreefallLandAction; AD_JPMove._sLongJumpLandAction;
   AD_JPMove._sDoubleJumpLandAction; AD_JPMove._sTripleJumpLandAction;
   AD_JPMove._sBackflipLandAction].

Definition ndf_nine_empty_ident_lists : list (list ident) :=
  [[]; []; []; []; []; []; []; []; []].

(** A four-frame descriptor corrupted to a larger frame count is just as
    relevant as corrupting [sLongJumpLandAction].  None of the nine globals
    has a direct generated assignment; all are nevertheless writable. *)
Theorem all_landing_descriptors_have_no_direct_generated_assignment :
  map
    (fun descriptor =>
       internal_function_assignment_sites descriptor us_generated_definitions)
    ndf_us_landing_descriptor_idents = ndf_nine_empty_ident_lists /\
  map
    (fun descriptor =>
       internal_function_assignment_sites
         descriptor jp_generated_definitions_for_alias)
    ndf_jp_landing_descriptor_idents = ndf_nine_empty_ident_lists /\
  map (@gvar_readonly type) us_landing_descriptors =
    [false; false; false; false; false; false; false; false; false] /\
  map (@gvar_readonly type) jp_landing_descriptors =
    [false; false; false; false; false; false; false; false; false].
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Every normal address formation is localized to the matching landing
    wrapper.  Thus a store through any other descriptor alias is not produced
    by ordinary typed source flow in the generated union. *)
Theorem landing_descriptor_address_sites_are_exact :
  map
    (fun descriptor =>
       internal_function_address_sites descriptor us_generated_definitions)
    ndf_us_landing_descriptor_idents =
    [[AD_USMove._act_jump_land]; [AD_USMove._act_freefall_land];
     [AD_USMove._act_side_flip_land]; [AD_USMove._act_hold_jump_land];
     [AD_USMove._act_hold_freefall_land]; [AD_USMove._act_long_jump_land];
     [AD_USMove._act_double_jump_land]; [AD_USMove._act_triple_jump_land];
     [AD_USMove._act_backflip_land]] /\
  map
    (fun descriptor =>
       internal_function_address_sites
         descriptor jp_generated_definitions_for_alias)
    ndf_jp_landing_descriptor_idents =
    [[AD_JPMove._act_jump_land]; [AD_JPMove._act_freefall_land];
     [AD_JPMove._act_side_flip_land]; [AD_JPMove._act_hold_jump_land];
     [AD_JPMove._act_hold_freefall_land]; [AD_JPMove._act_long_jump_land];
     [AD_JPMove._act_double_jump_land]; [AD_JPMove._act_triple_jump_land];
     [AD_JPMove._act_backflip_land]].
Proof. vm_compute. split; reflexivity. Qed.

(** If a live four-frame descriptor admits the late body, its frame-count
    cell differs from the generated initializer.  A forged timer alone cannot
    bypass the [timer >= numFrames] return. *)
Theorem non_long_negative_body_requires_descriptor_frame_corruption :
  forall kind live_frames before timer,
    kind <> StockLongJumpLand ->
    0 <= before ->
    1 <= timer < live_frames ->
    projected_landing_depth before timer < 0 ->
    live_frames <> stock_landing_frames kind.
Proof.
  intros kind live_frames before timer Hnot Hbefore Hbody Hnegative Hequal.
  subst live_frames.
  assert (Hrun : stock_landing_body_runs kind timer).
  { unfold stock_landing_body_runs. exact Hbody. }
  destruct
    (stock_landing_negative_from_nonnegative_requires_long_jump
       kind before timer Hbefore Hrun Hnegative) as [Hlong _].
  exact (Hnot Hlong).
Qed.

(** * Interaction callback retargeting *)

Fixpoint ndf_addrof_initializers (data : list init_data) : list ident :=
  match data with
  | [] => []
  | Init_addrof id _ :: rest => id :: ndf_addrof_initializers rest
  | _ :: rest => ndf_addrof_initializers rest
  end.

Definition ndf_expected_interaction_handlers : list ident :=
  [NDF_USInteraction._interact_coin;
   NDF_USInteraction._interact_water_ring;
   NDF_USInteraction._interact_star_or_key;
   NDF_USInteraction._interact_bbh_entrance;
   NDF_USInteraction._interact_warp;
   NDF_USInteraction._interact_warp_door;
   NDF_USInteraction._interact_door;
   NDF_USInteraction._interact_cannon_base;
   NDF_USInteraction._interact_igloo_barrier;
   NDF_USInteraction._interact_tornado;
   NDF_USInteraction._interact_whirlpool;
   NDF_USInteraction._interact_strong_wind;
   NDF_USInteraction._interact_flame;
   NDF_USInteraction._interact_snufit_bullet;
   NDF_USInteraction._interact_clam_or_bubba;
   NDF_USInteraction._interact_bully;
   NDF_USInteraction._interact_shock;
   NDF_USInteraction._interact_bounce_top;
   NDF_USInteraction._interact_mr_blizzard;
   NDF_USInteraction._interact_hit_from_below;
   NDF_USInteraction._interact_bounce_top;
   NDF_USInteraction._interact_damage;
   NDF_USInteraction._interact_pole;
   NDF_USInteraction._interact_hoot;
   NDF_USInteraction._interact_breakable;
   NDF_USInteraction._interact_bounce_top;
   NDF_USInteraction._interact_koopa_shell;
   NDF_USInteraction._interact_unknown_08;
   NDF_USInteraction._interact_cap;
   NDF_USInteraction._interact_grabbable;
   NDF_USInteraction._interact_text].

(** Identifier atoms are stable between these generated versions. *)
Theorem interaction_handler_table_initializer_is_exact_bilateral :
  ndf_addrof_initializers
      (gvar_init NDF_USInteraction.v_sInteractionHandlers) =
    ndf_expected_interaction_handlers /\
  ndf_addrof_initializers
      (gvar_init NDF_JPInteraction.v_sInteractionHandlers) =
    ndf_expected_interaction_handlers /\
  gvar_readonly NDF_USInteraction.v_sInteractionHandlers = false /\
  gvar_readonly NDF_JPInteraction.v_sInteractionHandlers = false /\
  internal_function_assignment_sites
      NDF_USInteraction._sInteractionHandlers us_generated_definitions = [] /\
  internal_function_assignment_sites
      NDF_JPInteraction._sInteractionHandlers
      jp_generated_definitions_for_alias = [].
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Corrupting a landing callback cannot by itself bypass zero A: the sole
    landing indirect call remains syntactically below [m->input & 2].  The
    second indirect MarioState call is the mutable interaction table above. *)
Theorem indirect_mario_state_calls_are_guarded_landing_or_interaction_table :
  internal_indirect_struct_pointer_call_sites
      AD_USMario._MarioState us_generated_definitions =
    [AD_USMove._common_landing_cancels;
     AD_USInteraction._mario_process_interactions] /\
  internal_indirect_struct_pointer_call_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias =
    [AD_JPMove._common_landing_cancels;
     AD_JPInteraction._mario_process_interactions] /\
  contains_field_mask_guarded_indirect_struct_pointer_call_s
      AD_USMove._input 2 AD_USMario._MarioState
      (fn_body AD_USMove.f_common_landing_cancels) = true /\
  contains_field_mask_guarded_indirect_struct_pointer_call_s
      AD_JPMove._input 2 AD_JPMario._MarioState
      (fn_body AD_JPMove.f_common_landing_cancels) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * The one source-visible indexed-state indirect writer caveat *)

(** The held-object render callback indexes [gMarioStates] by a graph-node
    [playerIndex], then calls the transform writer.  Proving that the stock
    index and body-state pointer remain valid is therefore a linked-memory
    provenance obligation, not something a per-function AST fact can settle. *)
Theorem held_node_indexed_transform_writer_is_present_bilateral :
  statement_mentions_ident_s NDF_USMisc._gMarioStates
      (fn_body NDF_USMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  statement_mentions_ident_s NDF_USMisc._playerIndex
      (fn_body NDF_USMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  calls_ident_s NDF_USMisc._get_pos_from_transform_mtx
      (fn_body NDF_USMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  statement_mentions_ident_s NDF_JPMisc._gMarioStates
      (fn_body NDF_JPMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  statement_mentions_ident_s NDF_JPMisc._playerIndex
      (fn_body NDF_JPMisc.f_geo_switch_mario_hand_grab_pos) = true /\
  calls_ident_s NDF_JPMisc._get_pos_from_transform_mtx
      (fn_body NDF_JPMisc.f_geo_switch_mario_hand_grab_pos) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Byte-precise CompCert action-cell frame *)

Definition ndf_action_cell_load
    (memory : Mem.mem) (state_block : block) (state_base : Z) : option val :=
  Mem.load Mint32 memory state_block
    (state_base + mario_state_action_offset).

Lemma framed_store_preserves_action_cell :
  forall before after chunk state_block write_block state_base
      write_offset value,
    (write_block <> state_block \/
     write_offset + size_chunk chunk <=
       state_base + mario_state_action_offset \/
     state_base + mario_state_action_offset + 4 <= write_offset) ->
    Mem.store chunk before write_block write_offset value = Some after ->
    ndf_action_cell_load after state_block state_base =
      ndf_action_cell_load before state_block state_base.
Proof.
  intros before after chunk state_block write_block state_base
    write_offset value Hframe Hstore.
  unfold ndf_action_cell_load.
  eapply Mem.load_store_other; eauto.
  destruct Hframe as [Hblock | [Hwrite_before | Haction_before]].
  - left. congruence.
  - right. right. exact Hwrite_before.
  - right. left. cbn. exact Haction_before.
Qed.

Theorem changed_action_cell_requires_same_block_and_byte_overlap :
  forall before after chunk state_block write_block state_base
      write_offset value,
    Mem.store chunk before write_block write_offset value = Some after ->
    ndf_action_cell_load after state_block state_base <>
      ndf_action_cell_load before state_block state_base ->
    write_block = state_block /\
    write_offset < state_base + mario_state_action_offset + 4 /\
    state_base + mario_state_action_offset <
      write_offset + size_chunk chunk.
Proof.
  intros before after chunk state_block write_block state_base
    write_offset value Hstore Hchanged.
  destruct (peq write_block state_block) as [Hblock | Hblock].
  2: exfalso; apply Hchanged;
     eapply framed_store_preserves_action_cell; eauto; left; exact Hblock.
  subst write_block. split; [reflexivity |].
  split.
  - destruct (Z_lt_ge_dec write_offset
      (state_base + mario_state_action_offset + 4)); auto.
    exfalso. apply Hchanged.
    eapply framed_store_preserves_action_cell; eauto.
    right. right. lia.
  - destruct (Z_lt_ge_dec
      (state_base + mario_state_action_offset)
      (write_offset + size_chunk chunk)); auto.
    exfalso. apply Hchanged.
    eapply framed_store_preserves_action_cell; eauto.
    right. left. lia.
Qed.

(** The exact remaining semantic bridge.  It is a definition, not an axiom,
    and no theorem above assumes it. *)
Definition NegativeDepthForgeryLinkedClosureObligation
    (clean_zero_edge_step : Type)
    (descriptor_or_dispatch_changed : clean_zero_edge_step -> Prop)
    (sensitive_state_changed_by_unframed_store : clean_zero_edge_step -> Prop)
    (held_node_index_or_body_pointer_forged : clean_zero_edge_step -> Prop)
    (input_bit_two_without_controller_edge : clean_zero_edge_step -> Prop)
    (unframed_external_effect : clean_zero_edge_step -> Prop) : Prop :=
  (forall step, ~ descriptor_or_dispatch_changed step) /\
  (forall step, ~ sensitive_state_changed_by_unframed_store step) /\
  (forall step, ~ held_node_index_or_body_pointer_forged step) /\
  (forall step, ~ input_bit_two_without_controller_edge step) /\
  (forall step, ~ unframed_external_effect step).

(** Verdict: there is no ordinary generated writer for the descriptor/table
    payloads and no concrete reachable forge in this module.  Retail closure
    still requires the proposition above, especially compiled-layout OOB
    exclusion; CompCert's distinct-block semantics alone cannot justify the
    behavior of undefined C on the N64 binary. *)
