(** Rank 12: Area-2 object-impulse boundary.

    The most promising named actor is a homing Amp: two are really spawned
    near the second-pole tier, and its give-up run is long enough that a live
    controller search should not assume the Amp remains inside its nominal
    1,500-unit chase radius.  This file therefore grants ideal installation
    at the pole and asks the payoff question.

    The generated US and JP programs agree on the answer.  A pole grab first
    clears Mario's forward speed.  An Amp uses the shock interaction, which
    contains no object-push call and selects ACT_SHOCKED for the non-water
    case.  The airborne/on-pole shocked action calls
    [mario_set_forward_vel(m, 0)] before [perform_air_step]; the setter writes
    forwardVel and both horizontal velocity components, but not vertical
    velocity.  Thus the Amp is a brake/action change rather than a horizontal
    impulse.  Any useful crossing after it must come from a separately proved
    wall response, support change, platform carry, or pre-existing crossing.

    The roster receipt also makes the search finite.  Area 2 has exactly two
    homing Amps and one circling Amp.  Its macro list contains none of the
    cannon, shell, Tweester, Heave-Ho, Chuckya, Fly Guy, or jumping-box preset
    families, while the exact scripted list contains only the already known
    poles, Grindels, Spindel, moving walls, elevator, sound loops, and stars.
    This is a selected-source boundary, not a universal live-reachability or
    collision-resolution theorem. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

(** * Exact Area-2 actor inventory *)

Definition rank12_area2_scripted_us : list ident :=
  initializer_addrof_idents (gvar_init USS.v_script_func_local_4) ++
  initializer_addrof_idents (gvar_init USS.v_script_func_local_5).

Definition rank12_area2_scripted_jp : list ident :=
  initializer_addrof_idents (gvar_init JSS.v_script_func_local_4) ++
  initializer_addrof_idents (gvar_init JSS.v_script_func_local_5).

Definition rank12_expected_area2_scripted_us : list ident :=
  [USS._bhvPoleGrabbing; USS._bhvPoleGrabbing;
   USS._bhvGrindel; USS._bhvHorizontalGrindel;
   USS._bhvHorizontalGrindel; USS._bhvSpindel;
   USS._bhvSSLMovingPyramidWall; USS._bhvSSLMovingPyramidWall;
   USS._bhvSSLMovingPyramidWall; USS._bhvSSLMovingPyramidWall;
   USS._bhvPyramidElevator;
   USS._bhvSandSoundLoop; USS._bhvSandSoundLoop;
   USS._bhvSandSoundLoop; USS._bhvStar; USS._bhvHiddenStar].

Definition rank12_expected_area2_scripted_jp : list ident :=
  [JSS._bhvPoleGrabbing; JSS._bhvPoleGrabbing;
   JSS._bhvGrindel; JSS._bhvHorizontalGrindel;
   JSS._bhvHorizontalGrindel; JSS._bhvSpindel;
   JSS._bhvSSLMovingPyramidWall; JSS._bhvSSLMovingPyramidWall;
   JSS._bhvSSLMovingPyramidWall; JSS._bhvSSLMovingPyramidWall;
   JSS._bhvPyramidElevator;
   JSS._bhvSandSoundLoop; JSS._bhvSandSoundLoop;
   JSS._bhvSandSoundLoop; JSS._bhvStar; JSS._bhvHiddenStar].

Fixpoint rank12_every_fifth (values : list Z) : list Z :=
  match values with
  | first :: _ :: _ :: _ :: _ :: rest =>
      first :: rank12_every_fifth rest
  | _ => []
  end.

Definition rank12_macro_preset_id (encoded : Z) : Z :=
  Z.land encoded 511 - 31.

Definition rank12_area2_macro_presets_us : list Z :=
  map rank12_macro_preset_id
    (rank12_every_fifth
      (init_int16_values (gvar_init UAM.v_ssl_seg7_area_2_macro_objs))).

Definition rank12_area2_macro_presets_jp : list Z :=
  map rank12_macro_preset_id
    (rank12_every_fifth
      (init_int16_values (gvar_init JAM.v_ssl_seg7_area_2_macro_objs))).

Definition rank12_expected_homing_amps : list (list Z) :=
  [[69; 1621; 3368; -1142; 0];
   [69; 1621; 3389; 478; 0]].

Definition rank12_expected_circling_amps : list (list Z) :=
  [[70; 3056; 736; -3267; 1]].

(** Decoded preset indices for the absent large-motion families: closed and
    open cannons, Chuckya, box shell, underwater shell, Bullet Bill cannon,
    Heave-Ho, jumping box, Tweester/tornado, and Fly Guy. *)
Definition rank12_absent_impulse_presets : list Z :=
  [22; 35; 36; 63; 78; 81; 82; 87; 138; 154].

Definition rank12_has_absent_impulse_preset (preset : Z) : bool :=
  existsb (Z.eqb preset) rank12_absent_impulse_presets.

Definition Rank12Area2RosterSourceShape : Prop :=
  records_with_tag 69 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) =
    rank12_expected_homing_amps /\
  records_with_tag 69 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) =
    rank12_expected_homing_amps /\
  records_with_tag 70 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) =
    rank12_expected_circling_amps /\
  records_with_tag 70 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) =
    rank12_expected_circling_amps /\
  forallb (fun preset => negb (rank12_has_absent_impulse_preset preset))
    rank12_area2_macro_presets_us = true /\
  forallb (fun preset => negb (rank12_has_absent_impulse_preset preset))
    rank12_area2_macro_presets_jp = true /\
  rank12_area2_scripted_us = rank12_expected_area2_scripted_us /\
  rank12_area2_scripted_jp = rank12_expected_area2_scripted_jp.

Theorem rank12_area2_roster_source_shape_checked :
  Rank12Area2RosterSourceShape.
Proof.
  unfold Rank12Area2RosterSourceShape,
    rank12_expected_homing_amps, rank12_expected_circling_amps,
    rank12_absent_impulse_presets, rank12_has_absent_impulse_preset,
    rank12_area2_macro_presets_us, rank12_area2_macro_presets_jp,
    rank12_macro_preset_id, rank12_area2_scripted_us,
    rank12_area2_scripted_jp, rank12_expected_area2_scripted_us,
    rank12_expected_area2_scripted_jp.
  vm_compute. repeat split; reflexivity.
Qed.

(** * The Amp's real interaction and the shocked action *)

Definition rank12_amp_hitbox_initializer : list init_data :=
  [Init_int32 (Int.repr 536870912); (* INTERACT_SHOCK *)
   Init_int8 (Int.repr 40);        (* down offset *)
   Init_int8 (Int.repr 1);         (* damage *)
   Init_int8 (Int.repr 0); Init_int8 (Int.repr 0);
   Init_int16 (Int.repr 40);       (* hitbox radius *)
   Init_int16 (Int.repr 50);       (* hitbox height *)
   Init_int16 (Int.repr 50); Init_int16 (Int.repr 60)].

Definition rank12_act_shocked : Z := 131896. (* 0x00020338 *)

(** Match the actual non-water call

      drop_and_set_mario_action(m, ACT_SHOCKED, actionArg)

    rather than finding the callee and action constant independently. *)
Definition rank12_is_shocked_call_s
    (callee : ident) (action : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found _)
      [Etempvar _ _; Econst_int found_action _; Etempvar _ _] =>
      Pos.eqb found callee && Int.eq found_action (Int.repr action)
  | _ => false
  end.

Fixpoint rank12_calls_shocked_s
    (callee : ident) (action : Z) (s : statement) : bool :=
  rank12_is_shocked_call_s callee action s ||
  match s with
  | Ssequence first second | Sloop first second =>
      rank12_calls_shocked_s callee action first ||
      rank12_calls_shocked_s callee action second
  | Sifthenelse _ yes_branch no_branch =>
      rank12_calls_shocked_s callee action yes_branch ||
      rank12_calls_shocked_s callee action no_branch
  | Sswitch _ cases => rank12_calls_shocked_ls callee action cases
  | Slabel _ body => rank12_calls_shocked_s callee action body
  | _ => false
  end
with rank12_calls_shocked_ls
    (callee : ident) (action : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      rank12_calls_shocked_s callee action body ||
      rank12_calls_shocked_ls callee action rest
  end.

Definition Rank12AmpInteractionSourceShape : Prop :=
  gvar_init UOB.v_sAmpHitbox = rank12_amp_hitbox_initializer /\
  gvar_init JOB.v_sAmpHitbox = rank12_amp_hitbox_initializer /\
  calls_ident_s UOB._obj_set_hitbox
    (fn_body UOB.f_check_amp_attack) = true /\
  calls_ident_s JOB._obj_set_hitbox
    (fn_body JOB.f_check_amp_attack) = true /\
  calls_ident_s UOB._check_amp_attack
    (fn_body UOB.f_homing_amp_chase_loop) = true /\
  calls_ident_s JOB._check_amp_attack
    (fn_body JOB.f_homing_amp_chase_loop) = true /\
  calls_ident_s UOB._object_step
    (fn_body UOB.f_bhv_homing_amp_loop) = true /\
  calls_ident_s JOB._object_step
    (fn_body JOB.f_bhv_homing_amp_loop) = true /\
  calls_ident_s UI._drop_and_set_mario_action
    (fn_body UI.f_interact_shock) = true /\
  calls_ident_s JI._drop_and_set_mario_action
    (fn_body JI.f_interact_shock) = true /\
  rank12_calls_shocked_s UI._drop_and_set_mario_action rank12_act_shocked
    (fn_body UI.f_interact_shock) = true /\
  rank12_calls_shocked_s JI._drop_and_set_mario_action rank12_act_shocked
    (fn_body JI.f_interact_shock) = true /\
  calls_ident_s UI._push_mario_out_of_object
    (fn_body UI.f_interact_shock) = false /\
  calls_ident_s JI._push_mario_out_of_object
    (fn_body JI.f_interact_shock) = false /\
  (** Stock pole acquisition has already erased inherited forward speed. *)
  assigns_field_float32_constant_s UI._forwardVel 0
    (fn_body UI.f_interact_pole) = true /\
  assigns_field_float32_constant_s JI._forwardVel 0
    (fn_body JI.f_interact_pole) = true /\
  assigns_array_slot_float32_constant_s UI._vel 1 0
    (fn_body UI.f_interact_pole) = true /\
  assigns_array_slot_float32_constant_s JI._vel 1 0
    (fn_body JI.f_interact_pole) = true /\
  (** The shocked action applies the zero before its air collision step. *)
  ident_subsequenceb
    [UCutscene._mario_set_forward_vel; UCutscene._perform_air_step]
    (direct_callees_s (fn_body UCutscene.f_act_shocked)) = true /\
  ident_subsequenceb
    [JCutscene._mario_set_forward_vel; JCutscene._perform_air_step]
    (direct_callees_s (fn_body JCutscene.f_act_shocked)) = true /\
  calls_ident_with_float32_arg_s UCutscene._mario_set_forward_vel 0
    (fn_body UCutscene.f_act_shocked) = true /\
  calls_ident_with_float32_arg_s JCutscene._mario_set_forward_vel 0
    (fn_body JCutscene.f_act_shocked) = true /\
  calls_ident_s UCutscene._stop_and_set_height_to_floor
    (fn_body UCutscene.f_act_shocked) = true /\
  calls_ident_s JCutscene._stop_and_set_height_to_floor
    (fn_body JCutscene.f_act_shocked) = true /\
  assigns_array_slot_s UCutscene._vel 1
    (fn_body UCutscene.f_act_shocked) = false /\
  assigns_array_slot_s JCutscene._vel 1
    (fn_body JCutscene.f_act_shocked) = false /\
  (** The called setter writes X/Z velocity slots and leaves Y to the existing
      air/collision path. *)
  assigns_through_field_s UMI._forwardVel
    (fn_body UMI.f_mario_set_forward_vel) = true /\
  statement_mentions_array_slot_s UMI._vel 0
    (fn_body UMI.f_mario_set_forward_vel) = true /\
  statement_mentions_array_slot_s UMI._vel 1
    (fn_body UMI.f_mario_set_forward_vel) = false /\
  statement_mentions_array_slot_s UMI._vel 2
    (fn_body UMI.f_mario_set_forward_vel) = true /\
  assigns_through_field_s JMI._forwardVel
    (fn_body JMI.f_mario_set_forward_vel) = true /\
  statement_mentions_array_slot_s JMI._vel 0
    (fn_body JMI.f_mario_set_forward_vel) = true /\
  statement_mentions_array_slot_s JMI._vel 1
    (fn_body JMI.f_mario_set_forward_vel) = false /\
  statement_mentions_array_slot_s JMI._vel 2
    (fn_body JMI.f_mario_set_forward_vel) = true.

Theorem rank12_amp_interaction_source_shape_checked :
  Rank12AmpInteractionSourceShape.
Proof.
  unfold Rank12AmpInteractionSourceShape,
    rank12_amp_hitbox_initializer, rank12_act_shocked.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Favorable installation still has no direct horizontal payoff *)

(** Hundredths of a unit avoid pretending that this arithmetic replaces the
    linked Float32 action proof.  The inner edge of the checked target ring is
    101 units from the pole centre. *)
Definition rank12_lower_ring_distance : Z := 10100.

Definition rank12_amp_shock_forward (_inherited : Z) : Z := 0.

Definition rank12_direct_horizontal_displacement
    (frames inherited_speed : Z) : Z :=
  frames * Z.abs (rank12_amp_shock_forward inherited_speed).

Theorem rank12_installed_amp_cannot_supply_direct_pole_dismount :
  forall frames inherited_speed,
    0 <= frames ->
    rank12_direct_horizontal_displacement frames inherited_speed = 0 /\
    rank12_direct_horizontal_displacement frames inherited_speed <
      rank12_lower_ring_distance.
Proof.
  intros frames inherited_speed Hframes.
  unfold rank12_direct_horizontal_displacement,
    rank12_amp_shock_forward, rank12_lower_ring_distance.
  simpl. lia.
Qed.

(** The nearest homing Amp starts about 1,832 horizontal units from the pole.
    Its 1,500-unit chase radius plus 151 favorable 15-unit give-up updates is
    more than enough in pure distance.  This deliberately prevents the final
    boundary from hiding an unproved "the Amp cannot get there" premise. *)
Theorem rank12_granted_amp_installation_distance_budget :
  1621 * 1621 + (478 - 1331) * (478 - 1331) <= 1832 * 1832 /\
  1832 <= 1500 + 151 * 15.
Proof. lia. Qed.

Record Area2Rank12ObjectImpulseBoundary : Prop := {
  rank12_boundary_roster : Rank12Area2RosterSourceShape;
  rank12_boundary_amp_source : Rank12AmpInteractionSourceShape;
  rank12_boundary_grants_installation :
    1621 * 1621 + (478 - 1331) * (478 - 1331) <= 1832 * 1832 /\
    1832 <= 1500 + 151 * 15;
  rank12_boundary_no_direct_dismount :
    forall frames inherited_speed,
      0 <= frames ->
      rank12_direct_horizontal_displacement frames inherited_speed = 0 /\
      rank12_direct_horizontal_displacement frames inherited_speed <
        rank12_lower_ring_distance
}.

Theorem area2_rank12_object_impulse_boundary_holds :
  Area2Rank12ObjectImpulseBoundary.
Proof.
  constructor.
  - exact rank12_area2_roster_source_shape_checked.
  - exact rank12_amp_interaction_source_shape_checked.
  - exact rank12_granted_amp_installation_distance_budget.
  - exact rank12_installed_amp_cannot_supply_direct_pole_dismount.
Qed.
