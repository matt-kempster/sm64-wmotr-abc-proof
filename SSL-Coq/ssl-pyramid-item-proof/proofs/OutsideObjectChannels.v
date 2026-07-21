From Coq Require Import Bool List PArith.BinPos ZArith.
Import ListNotations.
From compcert Require Import AST Clight Integers.
From SSLPyramid.Generated Require Import
  behavior_actions interaction level_update macro_special_objects mario
  obj_behaviors ssl_area1_macro.
From SSLPyramid.Proofs Require Import ASTFacts.

Module B := behavior_actions.
Module I := interaction.
Module L := level_update.
Module P := macro_special_objects.
Module M := mario.
Module OB := obj_behaviors.
Module SM := ssl_area1_macro.

Local Open Scope Z_scope.

Inductive outside_pyramid_channel_id : Type :=
| ChannelSmallBreakableBox
| ChannelFirstBobomb
| ChannelSecondBobomb
| ChannelFirstJumpingBox
| ChannelSecondJumpingBox
| ChannelKoopaShellBox
| ChannelFirstWingCapBox
| ChannelSecondWingCapBox
| ChannelThirdWingCapBox.

Inductive outside_pyramid_channel_class : Type :=
| DirectGrabbableObject
| SpawnedRiddenShell
| CapPowerupState.

Inductive outside_pyramid_reference_route : Type :=
| HeldUsedOrInteractReference
| RiddenShellReference
| CapTimerAndFlagsState
| NoReferenceRoute.

Record outside_pyramid_channel_risk := {
  risk_direct_object_transfer : bool;
  risk_stale_pointer_or_cloning : bool;
  risk_ordinary_state_only : bool;
  risk_irrelevant_to_item_identity : bool
}.

Record outside_pyramid_channel_classification := {
  classified_channel_id : outside_pyramid_channel_id;
  classified_route : outside_pyramid_reference_route;
  classified_risk : outside_pyramid_channel_risk
}.

Record outside_pyramid_object_channel := {
  channel_id : outside_pyramid_channel_id;
  channel_preset_index : nat;
  channel_encoded_preset : Z;
  channel_x : Z;
  channel_y : Z;
  channel_z : Z;
  channel_macro_parameter : Z;
  channel_behavior : ident;
  channel_preset_parameter : Z;
  channel_class : outside_pyramid_channel_class
}.

Definition direct_grabbable_risk : outside_pyramid_channel_risk := {|
  risk_direct_object_transfer := true;
  risk_stale_pointer_or_cloning := true;
  risk_ordinary_state_only := false;
  risk_irrelevant_to_item_identity := false
|}.

Definition spawned_ridden_shell_risk : outside_pyramid_channel_risk := {|
  risk_direct_object_transfer := true;
  risk_stale_pointer_or_cloning := true;
  risk_ordinary_state_only := false;
  risk_irrelevant_to_item_identity := false
|}.

Definition cap_powerup_state_risk : outside_pyramid_channel_risk := {|
  risk_direct_object_transfer := false;
  risk_stale_pointer_or_cloning := false;
  risk_ordinary_state_only := true;
  risk_irrelevant_to_item_identity := false
|}.

Definition channel_carries_object_pool_item_identity
    (classification : outside_pyramid_channel_classification) : bool :=
  risk_direct_object_transfer (classified_risk classification) ||
  risk_stale_pointer_or_cloning (classified_risk classification).

Definition macro_object_tuple : Type := (Z * Z * Z * Z * Z)%type.

Definition channel_macro_tuple
    (channel : outside_pyramid_object_channel) : macro_object_tuple :=
  (channel_encoded_preset channel,
   channel_x channel,
   channel_y channel,
   channel_z channel,
   channel_macro_parameter channel).

Definition int16_signed (value : int) : Z := Int.signed value.

Definition init_int16_in
    (encoded_presets : list Z) (found : int) : bool :=
  existsb (fun expected => int16_matches found expected) encoded_presets.

Fixpoint collect_macro_objects_with_presets
    (data : list init_data) (encoded_presets : list Z)
    : list macro_object_tuple :=
  match data with
  | Init_int16 p :: Init_int16 x :: Init_int16 y ::
    Init_int16 z :: Init_int16 parameter :: rest =>
      let entry :=
        (int16_signed p, int16_signed x, int16_signed y,
         int16_signed z, int16_signed parameter) in
      if init_int16_in encoded_presets p
      then entry :: collect_macro_objects_with_presets rest encoded_presets
      else collect_macro_objects_with_presets rest encoded_presets
  | _ => []
  end.

Definition channel_encoded_preset_matches
    (channel : outside_pyramid_object_channel) : bool :=
  Z.eqb (channel_encoded_preset channel)
    (Z.of_nat (channel_preset_index channel) + 31).

Definition channel_macro_object_present
    (channel : outside_pyramid_object_channel) : bool :=
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    (channel_encoded_preset channel)
    (channel_x channel)
    (channel_y channel)
    (channel_z channel)
    (channel_macro_parameter channel).

Definition channel_preset_behavior_matches
    (channel : outside_pyramid_object_channel) : bool :=
  match macro_preset_behavior_at
          (channel_preset_index channel)
          (gvar_init P.v_sMacroObjectPresets) with
  | Some behavior => Pos.eqb behavior (channel_behavior channel)
  | None => false
  end.

Definition channel_preset_parameter_matches
    (channel : outside_pyramid_object_channel) : bool :=
  match macro_preset_param_at
          (channel_preset_index channel)
          (gvar_init P.v_sMacroObjectPresets) with
  | Some parameter => int16_matches parameter (channel_preset_parameter channel)
  | None => false
  end.

Definition channel_matches_generated_tables
    (channel : outside_pyramid_object_channel) : bool :=
  channel_encoded_preset_matches channel &&
  channel_macro_object_present channel &&
  channel_preset_behavior_matches channel &&
  channel_preset_parameter_matches channel.

Definition outside_pyramid_object_channels
    : list outside_pyramid_object_channel :=
  [{| channel_id := ChannelSmallBreakableBox;
      channel_preset_index := 72%nat;
      channel_encoded_preset := 103;
      channel_x := 5900;
      channel_y := 50;
      channel_z := 3440;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvBreakableBoxSmall;
      channel_preset_parameter := 0;
      channel_class := DirectGrabbableObject |};
   {| channel_id := ChannelFirstBobomb;
      channel_preset_index := 111%nat;
      channel_encoded_preset := 142;
      channel_x := 3800;
      channel_y := 0;
      channel_z := 6000;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvBobomb;
      channel_preset_parameter := 0;
      channel_class := DirectGrabbableObject |};
   {| channel_id := ChannelSecondBobomb;
      channel_preset_index := 111%nat;
      channel_encoded_preset := 142;
      channel_x := 1750;
      channel_y := 0;
      channel_z := 6450;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvBobomb;
      channel_preset_parameter := 0;
      channel_class := DirectGrabbableObject |};
   {| channel_id := ChannelFirstJumpingBox;
      channel_preset_index := 87%nat;
      channel_encoded_preset := 118;
      channel_x := 1120;
      channel_y := 0;
      channel_z := 6480;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvJumpingBox;
      channel_preset_parameter := 0;
      channel_class := DirectGrabbableObject |};
   {| channel_id := ChannelSecondJumpingBox;
      channel_preset_index := 87%nat;
      channel_encoded_preset := 118;
      channel_x := -5200;
      channel_y := 0;
      channel_z := 1700;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvJumpingBox;
      channel_preset_parameter := 0;
      channel_class := DirectGrabbableObject |};
   {| channel_id := ChannelKoopaShellBox;
      channel_preset_index := 63%nat;
      channel_encoded_preset := 94;
      channel_x := 5840;
      channel_y := 940;
      channel_z := 2500;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvExclamationBox;
      channel_preset_parameter := 3;
      channel_class := SpawnedRiddenShell |};
   {| channel_id := ChannelFirstWingCapBox;
      channel_preset_index := 60%nat;
      channel_encoded_preset := 91;
      channel_x := 6900;
      channel_y := 350;
      channel_z := -5400;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvExclamationBox;
      channel_preset_parameter := 0;
      channel_class := CapPowerupState |};
   {| channel_id := ChannelSecondWingCapBox;
      channel_preset_index := 60%nat;
      channel_encoded_preset := 91;
      channel_x := -3000;
      channel_y := 500;
      channel_z := 800;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvExclamationBox;
      channel_preset_parameter := 0;
      channel_class := CapPowerupState |};
   {| channel_id := ChannelThirdWingCapBox;
      channel_preset_index := 60%nat;
      channel_encoded_preset := 91;
      channel_x := 5860;
      channel_y := 940;
      channel_z := 4180;
      channel_macro_parameter := 0;
      channel_behavior := P._bhvExclamationBox;
      channel_preset_parameter := 0;
      channel_class := CapPowerupState |}].

Definition outside_pyramid_object_channel_ids
    : list outside_pyramid_channel_id :=
  map channel_id outside_pyramid_object_channels.

Definition outside_pyramid_transport_relevant_encoded_presets : list Z :=
  [103; 142; 118; 94; 91].

Definition outside_pyramid_transport_relevant_macro_entries
    : list macro_object_tuple :=
  collect_macro_objects_with_presets
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    outside_pyramid_transport_relevant_encoded_presets.

Definition channel_is_direct_grabbable
    (channel : outside_pyramid_object_channel) : bool :=
  match channel_class channel with
  | DirectGrabbableObject => true
  | _ => false
  end.

Definition outside_pyramid_direct_grabbable_channels
    : list outside_pyramid_object_channel :=
  filter channel_is_direct_grabbable outside_pyramid_object_channels.

Definition classify_outside_pyramid_channel
    (channel : outside_pyramid_object_channel)
    : outside_pyramid_channel_classification :=
  match channel_class channel with
  | DirectGrabbableObject => {|
      classified_channel_id := channel_id channel;
      classified_route := HeldUsedOrInteractReference;
      classified_risk := direct_grabbable_risk
    |}
  | SpawnedRiddenShell => {|
      classified_channel_id := channel_id channel;
      classified_route := RiddenShellReference;
      classified_risk := spawned_ridden_shell_risk
    |}
  | CapPowerupState => {|
      classified_channel_id := channel_id channel;
      classified_route := CapTimerAndFlagsState;
      classified_risk := cap_powerup_state_risk
    |}
  end.

Definition outside_pyramid_channel_classifications_shell_first
    : list outside_pyramid_channel_classification :=
  [{| classified_channel_id := ChannelKoopaShellBox;
      classified_route := RiddenShellReference;
      classified_risk := spawned_ridden_shell_risk |};
   {| classified_channel_id := ChannelSmallBreakableBox;
      classified_route := HeldUsedOrInteractReference;
      classified_risk := direct_grabbable_risk |};
   {| classified_channel_id := ChannelFirstBobomb;
      classified_route := HeldUsedOrInteractReference;
      classified_risk := direct_grabbable_risk |};
   {| classified_channel_id := ChannelSecondBobomb;
      classified_route := HeldUsedOrInteractReference;
      classified_risk := direct_grabbable_risk |};
   {| classified_channel_id := ChannelFirstJumpingBox;
      classified_route := HeldUsedOrInteractReference;
      classified_risk := direct_grabbable_risk |};
   {| classified_channel_id := ChannelSecondJumpingBox;
      classified_route := HeldUsedOrInteractReference;
      classified_risk := direct_grabbable_risk |};
   {| classified_channel_id := ChannelFirstWingCapBox;
      classified_route := CapTimerAndFlagsState;
      classified_risk := cap_powerup_state_risk |};
   {| classified_channel_id := ChannelSecondWingCapBox;
      classified_route := CapTimerAndFlagsState;
      classified_risk := cap_powerup_state_risk |};
   {| classified_channel_id := ChannelThirdWingCapBox;
      classified_route := CapTimerAndFlagsState;
      classified_risk := cap_powerup_state_risk |}].

Definition outside_pyramid_classified_channel_ids
    : list outside_pyramid_channel_id :=
  map classified_channel_id
    outside_pyramid_channel_classifications_shell_first.

Definition classification_uses_held_reference_route
    (classification : outside_pyramid_channel_classification) : bool :=
  match classified_route classification with
  | HeldUsedOrInteractReference => true
  | _ => false
  end.

Definition outside_pyramid_held_reference_channel_classifications
    : list outside_pyramid_channel_classification :=
  filter classification_uses_held_reference_route
    outside_pyramid_channel_classifications_shell_first.

Theorem outside_pyramid_object_channel_count :
  length outside_pyramid_object_channels = 9%nat.
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_object_channel_ids_complete :
  forall channel_id,
    In channel_id outside_pyramid_object_channel_ids.
Proof.
  intros [] ; simpl; eauto 10.
Qed.

Theorem outside_pyramid_object_channel_records_cover_ids :
  forall wanted_channel_id,
    exists channel,
      In channel outside_pyramid_object_channels /\
      channel_id channel = wanted_channel_id.
Proof.
  intros [] ; simpl; eauto 12.
Qed.

Theorem outside_pyramid_object_channels_match_generated_tables :
  forallb channel_matches_generated_tables
    outside_pyramid_object_channels = true.
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_channel_classification_count :
  length outside_pyramid_channel_classifications_shell_first = 9%nat.
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_direct_grabbable_channels_exact :
  map (fun channel =>
         (channel_id channel, channel_behavior channel,
          channel_preset_index channel, channel_x channel,
          channel_y channel, channel_z channel))
    outside_pyramid_direct_grabbable_channels =
  [(ChannelSmallBreakableBox, P._bhvBreakableBoxSmall,
      72%nat, 5900, 50, 3440);
   (ChannelFirstBobomb, P._bhvBobomb, 111%nat, 3800, 0, 6000);
   (ChannelSecondBobomb, P._bhvBobomb, 111%nat, 1750, 0, 6450);
   (ChannelFirstJumpingBox, P._bhvJumpingBox,
      87%nat, 1120, 0, 6480);
   (ChannelSecondJumpingBox, P._bhvJumpingBox,
      87%nat, -5200, 0, 1700)].
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_held_reference_channels_are_exact_direct_grabbables :
  map classified_channel_id
    outside_pyramid_held_reference_channel_classifications =
  map channel_id outside_pyramid_direct_grabbable_channels.
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_held_reference_classifications_exact :
  map (fun classification =>
         (classified_channel_id classification,
          classified_route classification,
          risk_direct_object_transfer
            (classified_risk classification),
          risk_stale_pointer_or_cloning
            (classified_risk classification)))
    outside_pyramid_held_reference_channel_classifications =
  [(ChannelSmallBreakableBox, HeldUsedOrInteractReference, true, true);
   (ChannelFirstBobomb, HeldUsedOrInteractReference, true, true);
   (ChannelSecondBobomb, HeldUsedOrInteractReference, true, true);
   (ChannelFirstJumpingBox, HeldUsedOrInteractReference, true, true);
   (ChannelSecondJumpingBox, HeldUsedOrInteractReference, true, true)].
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_channel_classifications_start_with_shell :
  match outside_pyramid_channel_classifications_shell_first with
  | shell :: _ =>
      classified_channel_id shell = ChannelKoopaShellBox /\
      classified_route shell = RiddenShellReference /\
      classified_risk shell = spawned_ridden_shell_risk
  | [] => False
  end.
Proof. vm_compute; auto. Qed.

Theorem outside_pyramid_classified_channel_ids_complete :
  forall channel_id,
    In channel_id outside_pyramid_classified_channel_ids.
Proof.
  intros [] ; simpl; eauto 10.
Qed.

Theorem outside_pyramid_channel_classifications_cover_channels :
  forall channel,
    In channel outside_pyramid_object_channels ->
    In (channel_id channel) outside_pyramid_classified_channel_ids.
Proof.
  intros channel Hin.
  repeat
    (destruct Hin as [<- | Hin];
     [simpl; eauto 10 |]).
  contradiction.
Qed.

Theorem outside_pyramid_classification_is_not_irrelevant :
  forall classification,
    In classification outside_pyramid_channel_classifications_shell_first ->
    risk_irrelevant_to_item_identity
      (classified_risk classification) = false.
Proof.
  intros classification Hin.
  repeat
    (destruct Hin as [<- | Hin];
     [vm_compute; reflexivity |]).
  contradiction.
Qed.

Theorem outside_pyramid_classification_exact :
  map (fun classification =>
         (classified_channel_id classification,
          classified_route classification,
          risk_direct_object_transfer
            (classified_risk classification),
          risk_stale_pointer_or_cloning
            (classified_risk classification),
          risk_ordinary_state_only
            (classified_risk classification),
          risk_irrelevant_to_item_identity
            (classified_risk classification)))
    outside_pyramid_channel_classifications_shell_first =
  [(ChannelKoopaShellBox, RiddenShellReference, true, true, false, false);
   (ChannelSmallBreakableBox, HeldUsedOrInteractReference,
      true, true, false, false);
   (ChannelFirstBobomb, HeldUsedOrInteractReference,
      true, true, false, false);
   (ChannelSecondBobomb, HeldUsedOrInteractReference,
      true, true, false, false);
   (ChannelFirstJumpingBox, HeldUsedOrInteractReference,
      true, true, false, false);
   (ChannelSecondJumpingBox, HeldUsedOrInteractReference,
      true, true, false, false);
   (ChannelFirstWingCapBox, CapTimerAndFlagsState,
      false, false, true, false);
   (ChannelSecondWingCapBox, CapTimerAndFlagsState,
      false, false, true, false);
   (ChannelThirdWingCapBox, CapTimerAndFlagsState,
      false, false, true, false)].
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_object_pool_item_identity_channels_exact :
  map (fun classification =>
         (classified_channel_id classification,
          channel_carries_object_pool_item_identity classification))
    outside_pyramid_channel_classifications_shell_first =
  [(ChannelKoopaShellBox, true);
   (ChannelSmallBreakableBox, true);
   (ChannelFirstBobomb, true);
   (ChannelSecondBobomb, true);
   (ChannelFirstJumpingBox, true);
   (ChannelSecondJumpingBox, true);
   (ChannelFirstWingCapBox, false);
   (ChannelSecondWingCapBox, false);
   (ChannelThirdWingCapBox, false)].
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_transport_relevant_macro_entries_exact :
  outside_pyramid_transport_relevant_macro_entries =
  [(91, 6900, 350, -5400, 0);
   (91, -3000, 500, 800, 0);
   (103, 5900, 50, 3440, 0);
   (94, 5840, 940, 2500, 0);
   (91, 5860, 940, 4180, 0);
   (142, 3800, 0, 6000, 0);
   (142, 1750, 0, 6450, 0);
   (118, 1120, 0, 6480, 0);
   (118, -5200, 0, 1700, 0)].
Proof. vm_compute; reflexivity. Qed.

Theorem outside_pyramid_transport_relevant_macro_counts :
  count_macro_objects_with_preset
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs) 103 = 1%nat /\
  count_macro_objects_with_preset
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs) 142 = 2%nat /\
  count_macro_objects_with_preset
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs) 118 = 2%nat /\
  count_macro_objects_with_preset
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs) 94 = 1%nat /\
  count_macro_objects_with_preset
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs) 91 = 3%nat.
Proof. vm_compute; auto. Qed.

Theorem outside_pyramid_exclamation_box_contents :
  exclamation_box_content_behavior_at 3
    (gvar_init B.v_sExclamationBoxContents) =
    Some B._bhvKoopaShell /\
  exclamation_box_content_behavior_at 0
    (gvar_init B.v_sExclamationBoxContents) =
    Some B._bhvWingCap.
Proof. vm_compute; auto. Qed.

Theorem shell_channel_generated_ridden_object_evidence :
  exclamation_box_content_behavior_at 3
    (gvar_init B.v_sExclamationBoxContents) =
    Some B._bhvKoopaShell /\
  first_int32 (gvar_init B.v_sKoopaShellHitbox) =
    Some (Int.repr 524288) /\
  event_subsequenceb
    [Event_assign_field_from_temp I._interactObj I._o;
     Event_assign_field_from_temp I._usedObj I._o;
     Event_assign_field_from_temp I._riddenObj I._o]
    (statement_events_s (fn_body I.f_interact_koopa_shell)) = true /\
  assigns_zero_to_field_s M._riddenObj (fn_body M.f_init_mario) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem outside_pyramid_direct_channels_are_grabbable_behaviors :
  first_int32 (gvar_init OB.v_sBreakableBoxSmallHitbox) =
    Some (Int.repr 2) /\
  first_int32 (gvar_init OB.v_sBobombHitbox) =
    Some (Int.repr 2) /\
  first_int32 (gvar_init B.v_sJumpingBoxHitbox) =
    Some (Int.repr 2).
Proof. vm_compute; auto. Qed.

Theorem interact_grabbable_sets_interact_root_not_ridden :
  event_subsequenceb
    [Event_call I._able_to_grab_object;
     Event_assign_field_from_temp I._interactObj I._o]
    (statement_events_s (fn_body I.f_interact_grabbable)) = true /\
  assigns_field_s I._usedObj
    (fn_body I.f_interact_grabbable) = false /\
  assigns_field_s I._riddenObj
    (fn_body I.f_interact_grabbable) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem mario_check_object_grab_moves_interact_to_used_not_ridden :
  event_subsequenceb
    [Event_set_temp_from_field I._t'13 I._m I._interactObj;
     Event_assign_field_from_temp I._usedObj I._t'13]
    (statement_events_s (fn_body I.f_mario_check_object_grab)) = true /\
  event_subsequenceb
    [Event_set_temp_from_field I._t'10 I._m I._interactObj;
     Event_assign_field_from_temp I._usedObj I._t'10]
    (statement_events_s (fn_body I.f_mario_check_object_grab)) = true /\
  assigns_field_s I._riddenObj
    (fn_body I.f_mario_check_object_grab) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem mario_grab_used_object_moves_used_to_held_not_ridden :
  event_subsequenceb
    [Event_set_temp_from_field I._t'1 I._m I._heldObj;
     Event_set_temp_from_field I._t'3 I._m I._usedObj;
     Event_assign_field_from_temp I._heldObj I._t'3;
     Event_call I._obj_set_held_state]
    (statement_events_s (fn_body I.f_mario_grab_used_object)) = true /\
  assigns_field_s I._riddenObj
    (fn_body I.f_mario_grab_used_object) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem direct_grabbable_channel_mario_reference_cleanup_evidence :
  first_int32 (gvar_init OB.v_sBreakableBoxSmallHitbox) =
    Some (Int.repr 2) /\
  first_int32 (gvar_init OB.v_sBobombHitbox) =
    Some (Int.repr 2) /\
  first_int32 (gvar_init B.v_sJumpingBoxHitbox) =
    Some (Int.repr 2) /\
  assigns_zero_to_field_s M._heldObj (fn_body M.f_init_mario) = true /\
  assigns_zero_to_field_s M._usedObj (fn_body M.f_init_mario) = true /\
  event_subsequenceb
    [Event_call L._init_mario;
     Event_set_temp_from_field L._t'41 L._spawnNode L._object;
     Event_assign_field_from_temp L._interactObj L._t'41;
     Event_set_temp_from_field L._t'39 L._spawnNode L._object;
     Event_assign_field_from_temp L._usedObj L._t'39]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem wing_cap_channel_state_only_generated_evidence :
  exclamation_box_content_behavior_at 0
    (gvar_init B.v_sExclamationBoxContents) =
    Some B._bhvWingCap /\
  assigns_zero_to_field_s M._capTimer (fn_body M.f_init_mario) = true /\
  assigns_field_s L._capTimer
    (fn_body L.f_set_mario_initial_cap_powerup) = true /\
  direct_field_writers L.prog L._capTimer =
    [L._set_mario_initial_cap_powerup].
Proof. vm_compute; repeat split; reflexivity. Qed.
