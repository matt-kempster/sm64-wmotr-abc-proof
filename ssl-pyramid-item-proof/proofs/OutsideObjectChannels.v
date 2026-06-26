From Coq Require Import Bool List PArith.BinPos ZArith.
Import ListNotations.
From compcert Require Import AST Integers.
From SSLPyramid.Generated Require Import
  behavior_actions macro_special_objects obj_behaviors ssl_area1_macro.
From SSLPyramid.Proofs Require Import ASTFacts.

Module B := behavior_actions.
Module P := macro_special_objects.
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

Theorem outside_pyramid_direct_channels_are_grabbable_behaviors :
  first_int32 (gvar_init OB.v_sBreakableBoxSmallHitbox) =
    Some (Int.repr 2) /\
  first_int32 (gvar_init OB.v_sBobombHitbox) =
    Some (Int.repr 2) /\
  first_int32 (gvar_init B.v_sJumpingBoxHitbox) =
    Some (Int.repr 2).
Proof. vm_compute; auto. Qed.
