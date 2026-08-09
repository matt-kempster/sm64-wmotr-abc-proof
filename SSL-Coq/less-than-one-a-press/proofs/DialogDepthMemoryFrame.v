(** A concrete memory frame for the star-dance/automatic-dialog bridge.

    [MarioState.action], [prevAction], [actionState], [actionTimer], and
    [actionArg] share the same allocation as [quicksandDepth].  Consequently
    a separate-block argument is not enough to show that the action changes
    performed by [general_star_dance_handler], [set_mario_action], and
    [act_reading_automatic_dialog] preserve a negative depth payload.

    This file closes that narrower issue.  It checks the relevant US and JP
    layouts in the generated Clight composite environments, then proves with
    CompCert's actual [Mem.store]/[Mem.load] semantics that every successful
    store to one of those control cells preserves the binary32 load at the
    retail [quicksandDepth] offset.  The result composes across any finite
    sequence of such stores.  Stores to Mario's Object or BodyState are also
    covered when their blocks do not alias the MarioState block.

    This is not yet an execution theorem for the full dialog chronology.
    Refining the generated statements to the store relation below still
    requires one valid Mario pointer throughout the calls, plus frame
    conditions for unresolved external calls and exclusions for forged or
    out-of-bounds aliases. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Ctypes Errors Memory Values.
From LessThanOneAPress.Generated Require Import
  us_mario us_mario_actions_cutscene us_mario_step
  jp_mario jp_mario_actions_cutscene jp_mario_step.
From LessThanOneAPress.Proofs Require Import
  ASTFacts EntryMemory OrdinaryArea1EntryMemory.

Import ListNotations.
Local Open Scope Z_scope.

Module DDMF_US := us_mario.
Module DDMF_USCutscene := us_mario_actions_cutscene.
Module DDMF_USStep := us_mario_step.
Module DDMF_JP := jp_mario.
Module DDMF_JPCutscene := jp_mario_actions_cutscene.
Module DDMF_JPStep := jp_mario_step.

(** * Bilateral generated layout receipt *)

Definition mario_state_flags_offset : Z := 4.
Definition mario_state_previous_action_offset : Z := 16.

Theorem dialog_depth_control_layout_exact_us_jp :
  generated_field_offset DDMF_US.prog DDMF_US._MarioState DDMF_US._flags =
    Some (OK (mario_state_flags_offset, Full)) /\
  generated_field_offset DDMF_US.prog DDMF_US._MarioState
      DDMF_US._action =
    Some (OK (mario_state_action_offset, Full)) /\
  generated_field_offset DDMF_US.prog DDMF_US._MarioState
      DDMF_US._prevAction =
    Some (OK (mario_state_previous_action_offset, Full)) /\
  generated_field_offset DDMF_US.prog DDMF_US._MarioState
      DDMF_US._actionState =
    Some (OK (mario_state_action_state_offset, Full)) /\
  generated_field_offset DDMF_US.prog DDMF_US._MarioState
      DDMF_US._actionTimer =
    Some (OK (mario_state_action_timer_offset, Full)) /\
  generated_field_offset DDMF_US.prog DDMF_US._MarioState
      DDMF_US._actionArg =
    Some (OK (mario_state_action_arg_offset, Full)) /\
  generated_field_offset DDMF_US.prog DDMF_US._MarioState
      DDMF_US._quicksandDepth =
    Some (OK (mario_state_quicksand_depth_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState DDMF_JP._flags =
    Some (OK (mario_state_flags_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState
      DDMF_JP._action =
    Some (OK (mario_state_action_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState
      DDMF_JP._prevAction =
    Some (OK (mario_state_previous_action_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState
      DDMF_JP._actionState =
    Some (OK (mario_state_action_state_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState
      DDMF_JP._actionTimer =
    Some (OK (mario_state_action_timer_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState
      DDMF_JP._actionArg =
    Some (OK (mario_state_action_arg_offset, Full)) /\
  generated_field_offset DDMF_JP.prog DDMF_JP._MarioState
      DDMF_JP._quicksandDepth =
    Some (OK (mario_state_quicksand_depth_offset, Full)).
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The seven generated bodies on the direct star-dance-to-dialog spine do
    not directly assign either [quicksandDepth] or the only MarioState field
    lying after it, [gettingBlownGravity].  This is a syntax theorem, not an
    alias or call-frame theorem; its purpose is to justify why the typed
    direct stores on this spine can be refined to prefix stores below. *)
Definition dialog_depth_spine_direct_nonwriter_claim : Prop :=
  assigns_field_named_s DDMF_US._quicksandDepth
    (fn_body DDMF_US.f_set_mario_action_cutscene) = false /\
  assigns_field_named_s DDMF_US._gettingBlownGravity
    (fn_body DDMF_US.f_set_mario_action_cutscene) = false /\
  assigns_field_named_s DDMF_US._quicksandDepth
    (fn_body DDMF_US.f_set_mario_action) = false /\
  assigns_field_named_s DDMF_US._gettingBlownGravity
    (fn_body DDMF_US.f_set_mario_action) = false /\
  assigns_field_named_s DDMF_US._quicksandDepth
    (fn_body DDMF_US.f_sink_mario_in_quicksand) = false /\
  assigns_field_named_s DDMF_US._gettingBlownGravity
    (fn_body DDMF_US.f_sink_mario_in_quicksand) = false /\
  assigns_field_named_s DDMF_USCutscene._quicksandDepth
    (fn_body DDMF_USCutscene.f_general_star_dance_handler) = false /\
  assigns_field_named_s DDMF_USCutscene._gettingBlownGravity
    (fn_body DDMF_USCutscene.f_general_star_dance_handler) = false /\
  assigns_field_named_s DDMF_USCutscene._quicksandDepth
    (fn_body DDMF_USCutscene.f_act_star_dance) = false /\
  assigns_field_named_s DDMF_USCutscene._gettingBlownGravity
    (fn_body DDMF_USCutscene.f_act_star_dance) = false /\
  assigns_field_named_s DDMF_USCutscene._quicksandDepth
    (fn_body DDMF_USCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s DDMF_USCutscene._gettingBlownGravity
    (fn_body DDMF_USCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s DDMF_USStep._quicksandDepth
    (fn_body DDMF_USStep.f_stop_and_set_height_to_floor) = false /\
  assigns_field_named_s DDMF_USStep._gettingBlownGravity
    (fn_body DDMF_USStep.f_stop_and_set_height_to_floor) = false /\
  assigns_field_named_s DDMF_JP._quicksandDepth
    (fn_body DDMF_JP.f_set_mario_action_cutscene) = false /\
  assigns_field_named_s DDMF_JP._gettingBlownGravity
    (fn_body DDMF_JP.f_set_mario_action_cutscene) = false /\
  assigns_field_named_s DDMF_JP._quicksandDepth
    (fn_body DDMF_JP.f_set_mario_action) = false /\
  assigns_field_named_s DDMF_JP._gettingBlownGravity
    (fn_body DDMF_JP.f_set_mario_action) = false /\
  assigns_field_named_s DDMF_JP._quicksandDepth
    (fn_body DDMF_JP.f_sink_mario_in_quicksand) = false /\
  assigns_field_named_s DDMF_JP._gettingBlownGravity
    (fn_body DDMF_JP.f_sink_mario_in_quicksand) = false /\
  assigns_field_named_s DDMF_JPCutscene._quicksandDepth
    (fn_body DDMF_JPCutscene.f_general_star_dance_handler) = false /\
  assigns_field_named_s DDMF_JPCutscene._gettingBlownGravity
    (fn_body DDMF_JPCutscene.f_general_star_dance_handler) = false /\
  assigns_field_named_s DDMF_JPCutscene._quicksandDepth
    (fn_body DDMF_JPCutscene.f_act_star_dance) = false /\
  assigns_field_named_s DDMF_JPCutscene._gettingBlownGravity
    (fn_body DDMF_JPCutscene.f_act_star_dance) = false /\
  assigns_field_named_s DDMF_JPCutscene._quicksandDepth
    (fn_body DDMF_JPCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s DDMF_JPCutscene._gettingBlownGravity
    (fn_body DDMF_JPCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s DDMF_JPStep._quicksandDepth
    (fn_body DDMF_JPStep.f_stop_and_set_height_to_floor) = false /\
  assigns_field_named_s DDMF_JPStep._gettingBlownGravity
    (fn_body DDMF_JPStep.f_stop_and_set_height_to_floor) = false.

Theorem dialog_depth_spine_direct_nonwriter_checked :
  dialog_depth_spine_direct_nonwriter_claim.
Proof.
  unfold dialog_depth_spine_direct_nonwriter_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * The actual CompCert-memory frame *)

Definition dialog_depth_load
    (memory : Mem.mem) (state_block : block) (state_base : Z) : option val :=
  Mem.load Mfloat32 memory state_block
    (state_base + mario_state_quicksand_depth_offset).

Lemma store_before_dialog_depth_preserves_load :
  forall before after chunk state_block state_base relative_offset value,
    relative_offset + size_chunk chunk <=
      mario_state_quicksand_depth_offset ->
    Mem.store chunk before state_block (state_base + relative_offset) value =
      Some after ->
    dialog_depth_load after state_block state_base =
      dialog_depth_load before state_block state_base.
Proof.
  intros before after chunk state_block state_base relative_offset value
    Hbefore Hstore.
  unfold dialog_depth_load.
  eapply Mem.load_store_other; eauto.
  right; right. lia.
Qed.

Lemma separate_block_store_preserves_dialog_depth_load :
  forall before after chunk state_block write_block state_base
      write_offset value,
    write_block <> state_block ->
    Mem.store chunk before write_block write_offset value = Some after ->
    dialog_depth_load after state_block state_base =
      dialog_depth_load before state_block state_base.
Proof.
  intros before after chunk state_block write_block state_base
    write_offset value Hseparate Hstore.
  unfold dialog_depth_load.
  eapply Mem.load_store_other; eauto.
Qed.

(** Compose the two concrete frame cases.  Same-MarioState writes are allowed
    at any typed prefix offset ending before 192, not only at action-control
    fields; this also covers the State position/velocity stores in
    [stop_and_set_height_to_floor]. *)
Inductive dialog_depth_framed_store
    (state_block : block) (state_base : Z) : Mem.mem -> Mem.mem -> Prop :=
| dialog_depth_framed_state_prefix :
    forall before after chunk relative_offset value,
      relative_offset + size_chunk chunk <=
        mario_state_quicksand_depth_offset ->
      Mem.store chunk before state_block (state_base + relative_offset) value =
        Some after ->
      dialog_depth_framed_store state_block state_base before after
| dialog_depth_framed_separate_block :
    forall before after chunk write_block write_offset value,
      write_block <> state_block ->
      Mem.store chunk before write_block write_offset value = Some after ->
      dialog_depth_framed_store state_block state_base before after.

Lemma one_dialog_depth_framed_store_preserves_load :
  forall state_block state_base before after,
    dialog_depth_framed_store state_block state_base before after ->
    dialog_depth_load after state_block state_base =
      dialog_depth_load before state_block state_base.
Proof.
  intros state_block state_base before after Hstore.
  destruct Hstore.
  - eapply store_before_dialog_depth_preserves_load; eauto.
  - eapply separate_block_store_preserves_dialog_depth_load; eauto.
Qed.

Inductive dialog_depth_framed_store_sequence
    (state_block : block) (state_base : Z) : Mem.mem -> Mem.mem -> Prop :=
| dialog_depth_framed_store_sequence_refl :
    forall memory,
      dialog_depth_framed_store_sequence state_block state_base memory memory
| dialog_depth_framed_store_sequence_step :
    forall before middle after,
      dialog_depth_framed_store state_block state_base before middle ->
      dialog_depth_framed_store_sequence state_block state_base middle after ->
      dialog_depth_framed_store_sequence state_block state_base before after.

Theorem finite_dialog_depth_framed_store_sequence_preserves_load :
  forall state_block state_base before after,
    dialog_depth_framed_store_sequence state_block state_base before after ->
    dialog_depth_load after state_block state_base =
      dialog_depth_load before state_block state_base.
Proof.
  intros state_block state_base before after Hstores.
  induction Hstores.
  - reflexivity.
  - rewrite IHHstores.
    now apply one_dialog_depth_framed_store_preserves_load in H.
Qed.

Corollary finite_dialog_depth_framed_stores_preserve_exact_word :
  forall state_block state_base before after depth,
    dialog_depth_framed_store_sequence state_block state_base before after ->
    dialog_depth_load before state_block state_base = Some (Vsingle depth) ->
    dialog_depth_load after state_block state_base = Some (Vsingle depth).
Proof.
  intros state_block state_base before after depth Hstores Hdepth.
  rewrite (finite_dialog_depth_framed_store_sequence_preserves_load
    state_block state_base before after Hstores).
  exact Hdepth.
Qed.

(** The linked Area-1 symbol certificates already prove that MarioState and
    the Object pool occupy different global blocks.  Instantiate that result
    here so a successful Graphics/Object write has a concrete depth frame,
    rather than leaving block separation as an unrelated hypothesis. *)
Theorem us_area1_object_pool_store_preserves_dialog_depth_load :
  forall ge addresses before after chunk write_offset value state_base,
    USArea1EntrySymbolBindings ge addresses ->
    Mem.store chunk before (area1_object_pool_block addresses)
      write_offset value = Some after ->
    dialog_depth_load after (area1_state_storage_block addresses) state_base =
      dialog_depth_load before (area1_state_storage_block addresses) state_base.
Proof.
  intros ge addresses before after chunk write_offset value state_base
    Hbindings Hstore.
  pose proof
    (us_area1_entry_storage_blocks_pairwise_distinct ge addresses Hbindings)
    as [_ [Hstate_object _]].
  eapply separate_block_store_preserves_dialog_depth_load with
    (write_block := area1_object_pool_block addresses).
  - intros Hequal. apply Hstate_object. symmetry. exact Hequal.
  - exact Hstore.
Qed.

Theorem jp_area1_object_pool_store_preserves_dialog_depth_load :
  forall ge addresses before after chunk write_offset value state_base,
    JPArea1EntrySymbolBindings ge addresses ->
    Mem.store chunk before (area1_object_pool_block addresses)
      write_offset value = Some after ->
    dialog_depth_load after (area1_state_storage_block addresses) state_base =
      dialog_depth_load before (area1_state_storage_block addresses) state_base.
Proof.
  intros ge addresses before after chunk write_offset value state_base
    Hbindings Hstore.
  pose proof
    (jp_area1_entry_storage_blocks_pairwise_distinct ge addresses Hbindings)
    as [_ [Hstate_object _]].
  eapply separate_block_store_preserves_dialog_depth_load with
    (write_block := area1_object_pool_block addresses).
  - intros Hequal. apply Hstate_object. symmetry. exact Hequal.
  - exact Hstore.
Qed.

(** These are precisely the same-allocation control cells written by the
    central action setter and by the automatic-dialog state machine. *)
Inductive DialogControlCell : Type :=
| DialogFlags
| DialogAction
| DialogPreviousAction
| DialogActionState
| DialogActionTimer
| DialogActionArgument.

Definition dialog_control_cell_offset (cell : DialogControlCell) : Z :=
  match cell with
  | DialogFlags => mario_state_flags_offset
  | DialogAction => mario_state_action_offset
  | DialogPreviousAction => mario_state_previous_action_offset
  | DialogActionState => mario_state_action_state_offset
  | DialogActionTimer => mario_state_action_timer_offset
  | DialogActionArgument => mario_state_action_arg_offset
  end.

Definition dialog_control_cell_chunk (cell : DialogControlCell) : memory_chunk :=
  match cell with
  | DialogActionState | DialogActionTimer => Mint16unsigned
  | _ => Mint32
  end.

Theorem every_dialog_control_cell_ends_before_quicksand_depth :
  forall cell,
    dialog_control_cell_offset cell +
      size_chunk (dialog_control_cell_chunk cell) <=
    mario_state_quicksand_depth_offset.
Proof.
  intros [];
    cbv [dialog_control_cell_offset dialog_control_cell_chunk
      mario_state_flags_offset mario_state_action_offset
      mario_state_previous_action_offset mario_state_action_state_offset
      mario_state_action_timer_offset mario_state_action_arg_offset
      mario_state_quicksand_depth_offset size_chunk];
    lia.
Qed.

Definition store_dialog_control_cell
    (cell : DialogControlCell) (state_block : block) (state_base : Z)
    (value : val) (before after : Mem.mem) : Prop :=
  Mem.store (dialog_control_cell_chunk cell) before state_block
    (state_base + dialog_control_cell_offset cell) value = Some after.

Theorem one_dialog_control_store_preserves_depth_load :
  forall cell state_block state_base value before after,
    store_dialog_control_cell cell state_block state_base value before after ->
    dialog_depth_load after state_block state_base =
      dialog_depth_load before state_block state_base.
Proof.
  intros cell state_block state_base value before after Hstore.
  eapply store_before_dialog_depth_preserves_load.
  - apply every_dialog_control_cell_ends_before_quicksand_depth.
  - exact Hstore.
Qed.

Inductive dialog_control_store_sequence
    (state_block : block) (state_base : Z) : Mem.mem -> Mem.mem -> Prop :=
| dialog_control_store_sequence_refl :
    forall memory,
      dialog_control_store_sequence state_block state_base memory memory
| dialog_control_store_sequence_step :
    forall before middle after cell value,
      store_dialog_control_cell cell state_block state_base value
        before middle ->
      dialog_control_store_sequence state_block state_base middle after ->
      dialog_control_store_sequence state_block state_base before after.

Theorem finite_dialog_control_store_sequence_preserves_depth_load :
  forall state_block state_base before after,
    dialog_control_store_sequence state_block state_base before after ->
    dialog_depth_load after state_block state_base =
      dialog_depth_load before state_block state_base.
Proof.
  intros state_block state_base before after Hstores.
  induction Hstores.
  - reflexivity.
  - rewrite IHHstores.
    now apply one_dialog_control_store_preserves_depth_load in H.
Qed.

(** This corollary is the useful negative-payload formulation.  It preserves
    the exact binary32 value, rather than merely its sign or a real-number
    abstraction. *)
Corollary finite_dialog_control_stores_preserve_negative_depth_word :
  forall state_block state_base before after depth,
    dialog_control_store_sequence state_block state_base before after ->
    dialog_depth_load before state_block state_base = Some (Vsingle depth) ->
    dialog_depth_load after state_block state_base = Some (Vsingle depth).
Proof.
  intros state_block state_base before after depth Hstores Hdepth.
  rewrite (finite_dialog_control_store_sequence_preserves_depth_load
    state_block state_base before after Hstores).
  exact Hdepth.
Qed.

(** * Remaining execution boundary *)

Definition DialogDepthLinkedExecutionFrameObligation
    {State : Type}
    (linked_star_dance_to_dialog_step : State -> State -> Prop)
    (same_valid_mario_pointer : State -> State -> Prop)
    (direct_stores_refine_prefix_or_separate_blocks : State -> State -> Prop)
    (external_calls_preserve_depth_cell : State -> State -> Prop)
    (no_forged_or_oob_depth_alias : State -> State -> Prop) : Prop :=
  forall before after,
    linked_star_dance_to_dialog_step before after ->
    same_valid_mario_pointer before after /\
    direct_stores_refine_prefix_or_separate_blocks before after /\
    external_calls_preserve_depth_cell before after /\
    no_forged_or_oob_depth_alias before after.
