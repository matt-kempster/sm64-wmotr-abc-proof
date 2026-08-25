(** Conditional capability proof for a future machine-level writable-table
    mutation at the second SSL Area-2 pole.

    This file does not assert that any selected in-bounds Clight execution can
    mutate the tables.  [WritableActionTableReachedExecution] proves the
    opposite for that model.  Instead, it preserves the useful consequence
    for a future retail-machine extension: if a post-climb mutation redirects
    the pole handler through the stock Snufit/damage path and changes the
    selected airborne knockback word to [ACT_LONG_JUMP], the normal action
    setter supplies a 24-unit horizontal speed and 30-unit vertical speed.

    The executable kernel below then follows the no-analog, clear-quarter-step
    branch of the authentic binary32 update order.  It applies 0.35 drag,
    advances four quarters, and applies long-jump gravity 2.  After five
    frames the southbound witness is inside the already authenticated lower
    target-air cell.  Mutation reachability, exact post-climb timing, live
    interaction selection, and proof that all five retail collision quarters
    are clear remain an explicit bridge rather than being assumed away. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_mario jp_mario us_mario_actions_airborne jp_mario_actions_airborne
  us_mario_actions_automatic jp_mario_actions_automatic
  us_mario_step jp_mario_step.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts GameTypes InputSemantics Area2LowerTargetCut
  WritableActionTableClosure.

Import ListNotations.
Local Open Scope Z_scope.

Module HPLJ_USMario := us_mario.
Module HPLJ_JPMario := jp_mario.
Module HPLJ_USAir := us_mario_actions_airborne.
Module HPLJ_JPAir := jp_mario_actions_airborne.
Module HPLJ_USAuto := us_mario_actions_automatic.
Module HPLJ_JPAuto := jp_mario_actions_automatic.
Module HPLJ_USStep := us_mario_step.
Module HPLJ_JPStep := jp_mario_step.

(** * Exact hypothetical two-word payload *)

Definition hplj_pole_snufit_handlers_us : list init_data :=
  wat_replace_nth 45
    (Init_addrof WAT_US._interact_snufit_bullet (Ptrofs.repr 0))
    (gvar_init WAT_US.v_sInteractionHandlers).

Definition hplj_pole_snufit_handlers_jp : list init_data :=
  wat_replace_nth 45
    (Init_addrof WAT_JP._interact_snufit_bullet (Ptrofs.repr 0))
    (gvar_init WAT_JP.v_sInteractionHandlers).

(** Flattened index 3 is terrain row 1 (air/on-pole), strength column 0.
    The witness deliberately chooses the forward branch and ordinary health /
    damage column.  Other directions or columns require their corresponding
    word to be changed as well. *)
Definition hplj_forward_air_weak_actions_us : list init_data :=
  wat_replace_nth 3
    (Init_int32 (Int.repr wat_act_long_jump))
    (gvar_init WAT_US.v_sForwardKnockbackActions).

Definition hplj_forward_air_weak_actions_jp : list init_data :=
  wat_replace_nth 3
    (Init_int32 (Int.repr wat_act_long_jump))
    (gvar_init WAT_JP.v_sForwardKnockbackActions).

(** If the redirected handler fires while Mario is still in a ground action,
    [determine_knockback_action] selects terrain row 0 instead.  The otherwise
    analogous early-contact payload therefore changes flattened index 0, not
    index 3. *)
Definition hplj_forward_ground_weak_actions_us : list init_data :=
  wat_replace_nth 0
    (Init_int32 (Int.repr wat_act_long_jump))
    (gvar_init WAT_US.v_sForwardKnockbackActions).

Definition hplj_forward_ground_weak_actions_jp : list init_data :=
  wat_replace_nth 0
    (Init_int32 (Int.repr wat_act_long_jump))
    (gvar_init WAT_JP.v_sForwardKnockbackActions).

Definition HypotheticalPoleLongJumpTablePayload : Prop :=
  nth_error hplj_pole_snufit_handlers_us 45 =
    Some (Init_addrof WAT_US._interact_snufit_bullet (Ptrofs.repr 0)) /\
  nth_error hplj_pole_snufit_handlers_jp 45 =
    Some (Init_addrof WAT_JP._interact_snufit_bullet (Ptrofs.repr 0)) /\
  nth_error hplj_forward_air_weak_actions_us 3 =
    Some (Init_int32 (Int.repr 50333832)) /\
  nth_error hplj_forward_air_weak_actions_jp 3 =
    Some (Init_int32 (Int.repr 50333832)).

Theorem hypothetical_pole_long_jump_table_payload_is_exact :
  HypotheticalPoleLongJumpTablePayload.
Proof.
  unfold HypotheticalPoleLongJumpTablePayload,
    hplj_pole_snufit_handlers_us, hplj_pole_snufit_handlers_jp,
    hplj_forward_air_weak_actions_us, hplj_forward_air_weak_actions_jp,
    wat_act_long_jump.
  vm_compute. repeat split; reflexivity.
Qed.

Definition HypotheticalEarlyGroundPoleLongJumpTablePayload : Prop :=
  nth_error hplj_pole_snufit_handlers_us 45 =
    Some (Init_addrof WAT_US._interact_snufit_bullet (Ptrofs.repr 0)) /\
  nth_error hplj_pole_snufit_handlers_jp 45 =
    Some (Init_addrof WAT_JP._interact_snufit_bullet (Ptrofs.repr 0)) /\
  nth_error hplj_forward_ground_weak_actions_us 0 =
    Some (Init_int32 (Int.repr 50333832)) /\
  nth_error hplj_forward_ground_weak_actions_jp 0 =
    Some (Init_int32 (Int.repr 50333832)).

Theorem hypothetical_early_ground_pole_long_jump_payload_is_exact :
  HypotheticalEarlyGroundPoleLongJumpTablePayload.
Proof.
  unfold HypotheticalEarlyGroundPoleLongJumpTablePayload,
    hplj_pole_snufit_handlers_us, hplj_pole_snufit_handlers_jp,
    hplj_forward_ground_weak_actions_us,
    hplj_forward_ground_weak_actions_jp, wat_act_long_jump.
  vm_compute. repeat split; reflexivity.
Qed.

(** A single static pole-handler cell cannot simultaneously retain the stock
    grab handler and contain the Snufit redirection.  Combined with the
    checked terminal table read, this is why a preinstalled pole-row edit is
    not top-selective: preserving the ordinary climb requires changing the
    cell only after the grab, or using code/a different interaction. *)
Definition StaticPoleHandlerPreservesGrabAndRedirectsUS
    (handlers : list init_data) : Prop :=
  nth_error handlers 45 =
    Some (Init_addrof WAT_US._interact_pole (Ptrofs.repr 0)) /\
  nth_error handlers 45 =
    Some (Init_addrof WAT_US._interact_snufit_bullet (Ptrofs.repr 0)).

Definition StaticPoleHandlerPreservesGrabAndRedirectsJP
    (handlers : list init_data) : Prop :=
  nth_error handlers 45 =
    Some (Init_addrof WAT_JP._interact_pole (Ptrofs.repr 0)) /\
  nth_error handlers 45 =
    Some (Init_addrof WAT_JP._interact_snufit_bullet (Ptrofs.repr 0)).

Theorem no_single_static_pole_handler_word_preserves_grab_and_redirects :
  (forall handlers, ~ StaticPoleHandlerPreservesGrabAndRedirectsUS handlers) /\
  (forall handlers, ~ StaticPoleHandlerPreservesGrabAndRedirectsJP handlers).
Proof.
  split; intros handlers [Hstock Hredirect];
    rewrite Hstock in Hredirect; discriminate.
Qed.

Theorem early_pole_handler_payload_is_not_the_stock_grab_handler :
  nth_error hplj_pole_snufit_handlers_us 45 <>
    Some (Init_addrof WAT_US._interact_pole (Ptrofs.repr 0)) /\
  nth_error hplj_pole_snufit_handlers_jp 45 <>
    Some (Init_addrof WAT_JP._interact_pole (Ptrofs.repr 0)).
Proof.
  unfold hplj_pole_snufit_handlers_us, hplj_pole_snufit_handlers_jp.
  vm_compute. split; discriminate.
Qed.

(** A mutation of only the knockback word is different from replacing the
    pole handler.  The stock pole-handler word remains present, and neither
    version's [interact_pole] body reads either knockback table.  This is a
    generated source-shape fact, not a linked behavioral-equivalence proof,
    but it records why the knockback half may be preinstalled harmlessly and
    still cannot fire by itself during an ordinary grab or climb. *)
Definition hplj_body_avoids_known_tables
    (interaction forward backward : ident) (body : statement) : Prop :=
  statement_mentions_ident_s interaction body = false /\
  statement_mentions_ident_s forward body = false /\
  statement_mentions_ident_s backward body = false.

Definition hplj_body_avoids_known_tablesb
    (interaction forward backward : ident) (body : statement) : bool :=
  negb (statement_mentions_ident_s interaction body) &&
  negb (statement_mentions_ident_s forward body) &&
  negb (statement_mentions_ident_s backward body).

Definition hplj_us_pole_action_bodies : list statement :=
  [fn_body HPLJ_USAuto.f_act_grab_pole_slow;
   fn_body HPLJ_USAuto.f_act_grab_pole_fast;
   fn_body HPLJ_USAuto.f_act_holding_pole;
   fn_body HPLJ_USAuto.f_act_climbing_pole;
   fn_body HPLJ_USAuto.f_act_top_of_pole_transition;
   fn_body HPLJ_USAuto.f_act_top_of_pole].

Definition hplj_jp_pole_action_bodies : list statement :=
  [fn_body HPLJ_JPAuto.f_act_grab_pole_slow;
   fn_body HPLJ_JPAuto.f_act_grab_pole_fast;
   fn_body HPLJ_JPAuto.f_act_holding_pole;
   fn_body HPLJ_JPAuto.f_act_climbing_pole;
   fn_body HPLJ_JPAuto.f_act_top_of_pole_transition;
   fn_body HPLJ_JPAuto.f_act_top_of_pole].

Definition HypotheticalPreinstalledKnockbackOnlySourceShape : Prop :=
  nth_error (gvar_init WAT_US.v_sInteractionHandlers) 45 =
    Some (Init_addrof WAT_US._interact_pole (Ptrofs.repr 0)) /\
  nth_error hplj_forward_air_weak_actions_us 3 =
    Some (Init_int32 (Int.repr wat_act_long_jump)) /\
  hplj_body_avoids_known_tables
    WAT_US._sInteractionHandlers WAT_US._sForwardKnockbackActions
    WAT_US._sBackwardKnockbackActions (fn_body WAT_US.f_interact_pole) /\
  forallb
    (hplj_body_avoids_known_tablesb
      WAT_US._sInteractionHandlers WAT_US._sForwardKnockbackActions
      WAT_US._sBackwardKnockbackActions)
    hplj_us_pole_action_bodies = true /\
  nth_error (gvar_init WAT_JP.v_sInteractionHandlers) 45 =
    Some (Init_addrof WAT_JP._interact_pole (Ptrofs.repr 0)) /\
  nth_error hplj_forward_air_weak_actions_jp 3 =
    Some (Init_int32 (Int.repr wat_act_long_jump)) /\
  hplj_body_avoids_known_tables
    WAT_JP._sInteractionHandlers WAT_JP._sForwardKnockbackActions
    WAT_JP._sBackwardKnockbackActions (fn_body WAT_JP.f_interact_pole) /\
  forallb
    (hplj_body_avoids_known_tablesb
      WAT_JP._sInteractionHandlers WAT_JP._sForwardKnockbackActions
      WAT_JP._sBackwardKnockbackActions)
    hplj_jp_pole_action_bodies = true.

Theorem hypothetical_preinstalled_knockback_only_source_shape_holds :
  HypotheticalPreinstalledKnockbackOnlySourceShape.
Proof.
  unfold HypotheticalPreinstalledKnockbackOnlySourceShape,
    hplj_body_avoids_known_tables, hplj_body_avoids_known_tablesb,
    hplj_us_pole_action_bodies, hplj_jp_pole_action_bodies,
    hplj_forward_air_weak_actions_us, hplj_forward_air_weak_actions_jp,
    wat_act_long_jump.
  vm_compute. repeat split; reflexivity.
Qed.

(** Reaching the handstand does not create a hidden read of any of the three
    audited tables.  The generated automatic-action dispatcher calls
    [act_top_of_pole] directly; that body mentions none of the tables and its
    stock setter call requests [ACT_TOP_OF_POLE_JUMP], not [ACT_LONG_JUMP].
    Consequently no static mutation confined to those tables can change the
    handstand branch itself.  A top-only effect needs a later interaction or
    a machine-code/data patch outside this three-table mechanism. *)
Definition TopOfPoleKnownTableIndependenceSourceShape : Prop :=
  calls_ident_s HPLJ_USAuto._act_top_of_pole
    (fn_body HPLJ_USAuto.f_mario_execute_automatic_action) = true /\
  hplj_body_avoids_known_tables
    WAT_US._sInteractionHandlers WAT_US._sForwardKnockbackActions
    WAT_US._sBackwardKnockbackActions
    (fn_body HPLJ_USAuto.f_act_top_of_pole) /\
  calls_ident_with_second_int_literal_s HPLJ_USAuto._set_mario_action
    act_top_of_pole_jump_bits (fn_body HPLJ_USAuto.f_act_top_of_pole) = true /\
  calls_ident_with_second_int_literal_s HPLJ_USAuto._set_mario_action
    wat_act_long_jump (fn_body HPLJ_USAuto.f_act_top_of_pole) = false /\
  calls_ident_s HPLJ_JPAuto._act_top_of_pole
    (fn_body HPLJ_JPAuto.f_mario_execute_automatic_action) = true /\
  hplj_body_avoids_known_tables
    WAT_JP._sInteractionHandlers WAT_JP._sForwardKnockbackActions
    WAT_JP._sBackwardKnockbackActions
    (fn_body HPLJ_JPAuto.f_act_top_of_pole) /\
  calls_ident_with_second_int_literal_s HPLJ_JPAuto._set_mario_action
    act_top_of_pole_jump_bits (fn_body HPLJ_JPAuto.f_act_top_of_pole) = true /\
  calls_ident_with_second_int_literal_s HPLJ_JPAuto._set_mario_action
    wat_act_long_jump (fn_body HPLJ_JPAuto.f_act_top_of_pole) = false.

Theorem top_of_pole_does_not_read_the_known_writable_tables :
  TopOfPoleKnownTableIndependenceSourceShape.
Proof.
  unfold TopOfPoleKnownTableIndependenceSourceShape,
    hplj_body_avoids_known_tables, act_top_of_pole_jump_bits,
    wat_act_long_jump.
  vm_compute. repeat split; reflexivity.
Qed.

(** These are source-shape receipts, not a semantic execution theorem.  They
    pin the selected generated US/JP consumers to the constants used by the
    arithmetic kernel: the long-jump setter case contains 30 and 1.5, the
    airborne update contains 0.35 drag, and gravity contains 2. *)
Definition HypotheticalPoleLongJumpStockSourceShape : Prop :=
  KnockbackMutationConsumerBoundary /\
  fn_params WAT_US.f_interact_pole =
    fn_params WAT_US.f_interact_snufit_bullet /\
  fn_params WAT_JP.f_interact_pole =
    fn_params WAT_JP.f_interact_snufit_bullet /\
  switch_case_mentions_float32_bits_s
    wat_act_long_jump 1106247680
    (fn_body HPLJ_USMario.f_set_mario_action_airborne) = true /\
  switch_case_mentions_float32_bits_s
    wat_act_long_jump 1069547520
    (fn_body HPLJ_USMario.f_set_mario_action_airborne) = true /\
  switch_case_mentions_float32_bits_s
    wat_act_long_jump 1106247680
    (fn_body HPLJ_JPMario.f_set_mario_action_airborne) = true /\
  switch_case_mentions_float32_bits_s
    wat_act_long_jump 1069547520
    (fn_body HPLJ_JPMario.f_set_mario_action_airborne) = true /\
  statement_mentions_float32_bits_s 1051931443
    (fn_body HPLJ_USAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s 1051931443
    (fn_body HPLJ_JPAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s 1073741824
    (fn_body HPLJ_USStep.f_apply_gravity) = true /\
  statement_mentions_float32_bits_s 1073741824
    (fn_body HPLJ_JPStep.f_apply_gravity) = true.

Theorem hypothetical_pole_long_jump_stock_source_shape_holds :
  HypotheticalPoleLongJumpStockSourceShape.
Proof.
  unfold HypotheticalPoleLongJumpStockSourceShape.
  split; [exact a_mutated_selected_knockback_word_reaches_an_action_setter |].
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact binary32 clear-space trajectory *)

Definition hplj_f32_drag : float32 := f32_bits 1051931443. (* 0.35f *)
Definition hplj_f32_sixteen : float32 := f32_bits 1098907648.
Definition hplj_f32_one_point_five : float32 := f32_bits 1069547520.
Definition hplj_f32_twenty_four : float32 := f32_bits 1103101952.
Definition hplj_f32_thirty : float32 := f32_bits 1106247680.
Definition hplj_f32_two : float32 := f32_bits 1073741824.
Definition hplj_f32_four : float32 := f32_bits 1082130432.

Theorem stock_knockback_minimum_and_long_jump_multiplier_make_twenty_four :
  Float32.to_bits
    (Float32.mul hplj_f32_sixteen hplj_f32_one_point_five) =
    Int.repr 1103101952.
Proof. vm_compute. reflexivity. Qed.

Record HypotheticalPoleLongJumpState := {
  hplj_position : Vec3f;
  hplj_forward_speed : float32;
  hplj_vertical_speed : float32
}.

Definition hplj_initial_state : HypotheticalPoleLongJumpState :=
  {| hplj_position := lower_pole_top_position;
     hplj_forward_speed := hplj_f32_twenty_four;
     hplj_vertical_speed := hplj_f32_thirty |}.

(** Four sequential rounded additions match the position-update part of four
    successful [perform_air_quarter_step] calls. *)
Definition hplj_four_quarter_add
    (position velocity : float32) : float32 :=
  let quarter := Float32.div velocity hplj_f32_four in
  Float32.add
    (Float32.add
      (Float32.add
        (Float32.add position quarter) quarter) quarter) quarter.

(** Southbound, no-analog, no-wind, all-quarters-clear branch.  The positive
    speed premise needed by [approach_f32] is true throughout these five
    concrete frames, so its selected branch is subtraction by 0.35. *)
Definition hplj_clear_south_step
    (state : HypotheticalPoleLongJumpState)
    : HypotheticalPoleLongJumpState :=
  let next_forward :=
    Float32.sub (hplj_forward_speed state) hplj_f32_drag in
  let position := hplj_position state in
  {| hplj_position :=
       {| vec_x := vec_x position;
          vec_y := hplj_four_quarter_add
            (vec_y position) (hplj_vertical_speed state);
          vec_z := hplj_four_quarter_add
            (vec_z position) (Float32.neg next_forward) |};
     hplj_forward_speed := next_forward;
     hplj_vertical_speed :=
       Float32.sub (hplj_vertical_speed state) hplj_f32_two |}.

Fixpoint hplj_iterate_clear_south
    (frames : nat) (state : HypotheticalPoleLongJumpState)
    : HypotheticalPoleLongJumpState :=
  match frames with
  | O => state
  | S frames' =>
      hplj_iterate_clear_south frames' (hplj_clear_south_step state)
  end.

Fixpoint hplj_clear_south_trace
    (frames : nat) (state : HypotheticalPoleLongJumpState)
    : list HypotheticalPoleLongJumpState :=
  match frames with
  | O => []
  | S frames' =>
      let next := hplj_clear_south_step state in
      next :: hplj_clear_south_trace frames' next
  end.

Definition hplj_after_five_clear_frames : HypotheticalPoleLongJumpState :=
  hplj_iterate_clear_south 5 hplj_initial_state.

Definition hplj_first_five_clear_states : list HypotheticalPoleLongJumpState :=
  [hplj_iterate_clear_south 1 hplj_initial_state;
   hplj_iterate_clear_south 2 hplj_initial_state;
   hplj_iterate_clear_south 3 hplj_initial_state;
   hplj_iterate_clear_south 4 hplj_initial_state;
   hplj_after_five_clear_frames].

Theorem hypothetical_pole_long_jump_fifth_frame_position_is_exact :
  Float32.to_bits
    (vec_x (hplj_position hplj_after_five_clear_frames)) = Int.repr 0 /\
  Float32.to_bits
    (vec_y (hplj_position hplj_after_five_clear_frames)) =
      Int.repr 1166127104 /\ (* 4150.0f *)
  Float32.to_bits
    (vec_z (hplj_position hplj_after_five_clear_frames)) =
      Int.repr 1150814208. (* 1216.25f *)
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem hypothetical_pole_long_jump_first_five_frames_stay_above_ring :
  forallb
    (fun state =>
      Float32.cmp Clt (f32_bits 1165385728)
        (vec_y (hplj_position state)))
    hplj_first_five_clear_states = true.
Proof. vm_compute. reflexivity. Qed.

Theorem hypothetical_pole_long_jump_enters_lower_target_air_on_frame_five :
  position_in_lower_ring_target_air
    (hplj_position hplj_after_five_clear_frames) = true.
Proof. vm_compute. reflexivity. Qed.

(** * Mutation already active at first pole contact *)

(** This is the strongest simple early-contact test: it grants a genuine,
    fully initialized long jump at the normalized fifth-floor pole base.  A
    real ground contact needs the row-0 payload above; an airborne first
    contact uses row 1.  In either case, replacing [interact_pole] means the
    stock grab/climb transition does not run on that collision. *)
Definition hplj_base_contact_state : HypotheticalPoleLongJumpState :=
  {| hplj_position :=
       {| vec_x := f32_zero;
          vec_y := f32_bits 1162346496;  (* 3200.0f *)
          vec_z := f32_bits 1151754240 |};
     hplj_forward_speed := hplj_f32_twenty_four;
     hplj_vertical_speed := hplj_f32_thirty |}.

Definition hplj_base_contact_first_31_states :
    list HypotheticalPoleLongJumpState :=
  hplj_clear_south_trace 31 hplj_base_contact_state.

Theorem hypothetical_base_contact_long_jump_peak_is_3440 :
  Float32.to_bits
    (vec_y
      (hplj_position
        (hplj_iterate_clear_south 15 hplj_base_contact_state))) =
      Int.repr 1163329536 /\
  Float32.to_bits
    (vec_y
      (hplj_position
        (hplj_iterate_clear_south 16 hplj_base_contact_state))) =
      Int.repr 1163329536.
Proof. vm_compute. split; reflexivity. Qed.

Theorem hypothetical_base_contact_single_long_jump_misses_target_air :
  forallb
    (fun state =>
      negb
        (position_in_lower_ring_target_air (hplj_position state)))
    hplj_base_contact_first_31_states = true.
Proof. vm_compute. reflexivity. Qed.

(** 3702 is the exact clear-kernel threshold at which the 240-unit vertical
    rise reaches the ring plane.  This is not a reachability claim: it records
    that an early mutation can still work if some independent route first
    supplies a pole contact at or above this height. *)
Definition hplj_threshold_contact_state : HypotheticalPoleLongJumpState :=
  {| hplj_position :=
       {| vec_x := f32_zero;
          vec_y := f32_bits 1164402688;  (* 3702.0f *)
          vec_z := f32_bits 1151754240 |};
     hplj_forward_speed := hplj_f32_twenty_four;
     hplj_vertical_speed := hplj_f32_thirty |}.

Theorem hypothetical_3702_contact_enters_target_air_at_the_apex :
  Float32.to_bits
    (vec_x
      (hplj_position
        (hplj_iterate_clear_south 15 hplj_threshold_contact_state))) =
      Int.repr 0 /\
  Float32.to_bits
    (vec_y
      (hplj_position
        (hplj_iterate_clear_south 15 hplj_threshold_contact_state))) =
      Int.repr 1165385728 /\ (* 3942.0f *)
  Float32.to_bits
    (vec_z
      (hplj_position
        (hplj_iterate_clear_south 15 hplj_threshold_contact_state))) =
      Int.repr 1149059072 /\ (* 1013.0f *)
  position_in_lower_ring_target_air
    (hplj_position
      (hplj_iterate_clear_south 15 hplj_threshold_contact_state)) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The mutation supplies the action; the five trajectory frames themselves
    contain neither an A edge nor an A hold. *)
Definition hplj_zero_button_frame : FrameInput :=
  {| frame_previous_down := Int.zero;
     frame_current_down := Int.zero |}.

Definition hplj_five_frame_inputs : list FrameInput :=
  [hplj_zero_button_frame; hplj_zero_button_frame;
   hplj_zero_button_frame; hplj_zero_button_frame;
   hplj_zero_button_frame].

Theorem hypothetical_pole_long_jump_five_frames_use_zero_a_presses :
  coherent_input_history Int.zero hplj_five_frame_inputs /\
  fewer_than_one_a_press hplj_five_frame_inputs.
Proof.
  split.
  - vm_compute. repeat split; reflexivity.
  - repeat constructor; vm_compute; reflexivity.
Qed.

(** This is the exact future bridge.  It is intentionally uninhabited here:
    a retail-machine execution must provide the post-climb mutation, select
    the forward air/weak cell, enter the normal action setter, and show that
    each of the twenty collision quarters realizes [hplj_clear_south_step]. *)
Definition HypotheticalPoleLongJumpRetailBridge
    {MachineState : Type}
    (mutation_active_after_climb : MachineState -> Prop)
    (projects_to_hplj : MachineState -> HypotheticalPoleLongJumpState -> Prop)
    (retail_step : MachineState -> MachineState -> Prop) : Prop :=
  exists state0 state1 state2 state3 state4 state5,
    mutation_active_after_climb state0 /\
    projects_to_hplj state0 hplj_initial_state /\
    retail_step state0 state1 /\
    projects_to_hplj state1
      (hplj_iterate_clear_south 1 hplj_initial_state) /\
    retail_step state1 state2 /\
    projects_to_hplj state2
      (hplj_iterate_clear_south 2 hplj_initial_state) /\
    retail_step state2 state3 /\
    projects_to_hplj state3
      (hplj_iterate_clear_south 3 hplj_initial_state) /\
    retail_step state3 state4 /\
    projects_to_hplj state4
      (hplj_iterate_clear_south 4 hplj_initial_state) /\
    retail_step state4 state5 /\
    projects_to_hplj state5 hplj_after_five_clear_frames.

Theorem hypothetical_pole_long_jump_checked_boundary_holds :
  HypotheticalPoleLongJumpTablePayload /\
  HypotheticalEarlyGroundPoleLongJumpTablePayload /\
  HypotheticalPreinstalledKnockbackOnlySourceShape /\
  TopOfPoleKnownTableIndependenceSourceShape /\
  (forall handlers,
    ~ StaticPoleHandlerPreservesGrabAndRedirectsUS handlers) /\
  (forall handlers,
    ~ StaticPoleHandlerPreservesGrabAndRedirectsJP handlers) /\
  HypotheticalPoleLongJumpStockSourceShape /\
  Float32.to_bits
    (Float32.mul hplj_f32_sixteen hplj_f32_one_point_five) =
      Int.repr 1103101952 /\
  Float32.to_bits
    (vec_y (hplj_position hplj_after_five_clear_frames)) =
      Int.repr 1166127104 /\
  Float32.to_bits
    (vec_z (hplj_position hplj_after_five_clear_frames)) =
      Int.repr 1150814208 /\
  position_in_lower_ring_target_air
    (hplj_position hplj_after_five_clear_frames) = true /\
  forallb
    (fun state =>
      negb
        (position_in_lower_ring_target_air (hplj_position state)))
    hplj_base_contact_first_31_states = true /\
  position_in_lower_ring_target_air
    (hplj_position
      (hplj_iterate_clear_south 15 hplj_threshold_contact_state)) = true /\
  fewer_than_one_a_press hplj_five_frame_inputs.
Proof.
  split; [exact hypothetical_pole_long_jump_table_payload_is_exact |].
  split; [exact hypothetical_early_ground_pole_long_jump_payload_is_exact |].
  split; [exact hypothetical_preinstalled_knockback_only_source_shape_holds |].
  split; [exact top_of_pole_does_not_read_the_known_writable_tables |].
  split; [exact (proj1 no_single_static_pole_handler_word_preserves_grab_and_redirects) |].
  split; [exact (proj2 no_single_static_pole_handler_word_preserves_grab_and_redirects) |].
  split; [exact hypothetical_pole_long_jump_stock_source_shape_holds |].
  split; [exact stock_knockback_minimum_and_long_jump_multiplier_make_twenty_four |].
  split; [exact (proj1 (proj2 hypothetical_pole_long_jump_fifth_frame_position_is_exact)) |].
  split; [exact (proj2 (proj2 hypothetical_pole_long_jump_fifth_frame_position_is_exact)) |].
  split; [exact hypothetical_pole_long_jump_enters_lower_target_air_on_frame_five |].
  split; [exact hypothetical_base_contact_single_long_jump_misses_target_air |].
  split; [exact (proj2 (proj2 (proj2 hypothetical_3702_contact_enters_target_air_at_the_apex))) |].
  exact (proj2 hypothetical_pole_long_jump_five_frames_use_zero_a_presses).
Qed.
