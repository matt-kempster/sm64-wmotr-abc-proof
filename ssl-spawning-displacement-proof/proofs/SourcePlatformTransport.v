From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec FreeListReuse SSLFacts
  PyramidTopWarp ClonedPlatformWarp SSLStartCloneRoute SourcePlatformOverlap.

Import ListNotations.
Local Open Scope Z_scope.

Record platform_center_envelope := {
  envelope_min_x : Z;
  envelope_max_x : Z;
  envelope_min_y : Z;
  envelope_max_y : Z;
  envelope_min_z : Z;
  envelope_max_z : Z
}.

Definition platform_envelope_overlaps_warp_bbox
    (envelope : platform_center_envelope)
    (bbox : platform_bbox)
    (warp : area1_warp_hitbox)
    (mario_hitbox_height : Z) : Prop :=
  exists x y z,
    envelope_min_x envelope - platform_bbox_half_x bbox <= x <=
      envelope_max_x envelope + platform_bbox_half_x bbox /\
    envelope_min_z envelope - platform_bbox_half_z bbox <= z <=
      envelope_max_z envelope + platform_bbox_half_z bbox /\
    envelope_min_y envelope + platform_bbox_min_relative_y bbox <= y <=
      envelope_max_y envelope + platform_bbox_max_relative_y bbox /\
    point_in_warp_bbox warp mario_hitbox_height x y z.

Ltac solve_no_platform_envelope_warp_overlap :=
  unfold platform_envelope_overlaps_warp_bbox, point_in_warp_bbox,
    within_axis, vertical_intervals_overlap,
    area1_warp_low_y, area1_warp_high_y in *;
  intros (x & y & z & Hx & Hz & Hy & Hwarp);
  destruct Hx as [Hx_min Hx_max];
  destruct Hz as [Hz_min Hz_max];
  destruct Hy as [Hy_min Hy_max];
  destruct Hwarp as [[Hwx_min Hwx_max] [[Hwz_min Hwz_max] [Hwy_low Hwy_high]]];
  cbn in *;
  lia.

Definition pyramid_top_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := -2087;
  envelope_max_x := -2007;
  envelope_min_y := 1536;
  envelope_max_y := 100000;
  envelope_min_z := -1023;
  envelope_max_z := -1023
|}.

Definition tox_box_1_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := -3332;
  envelope_max_x := 764;
  envelope_min_y := -1000;
  envelope_max_y := 1000;
  envelope_min_z := -6407;
  envelope_max_z := -4871
|}.

Definition tox_box_2_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := -253;
  envelope_max_x := 2819;
  envelope_min_y := -1000;
  envelope_max_y := 1000;
  envelope_min_z := -5889;
  envelope_max_z := -3841
|}.

Definition tox_box_3_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := 4361;
  envelope_max_x := 5385;
  envelope_min_y := -1000;
  envelope_max_y := 1000;
  envelope_min_z := -3847;
  envelope_max_z := -775
|}.

Inductive tox_box_builtin_motion_envelope_for :
    ssl_object -> platform_center_envelope -> Prop :=
| ToxBox1BuiltinMotionEnvelope :
    tox_box_builtin_motion_envelope_for
      ssl_tox_box_1 tox_box_1_builtin_motion_envelope
| ToxBox2BuiltinMotionEnvelope :
    tox_box_builtin_motion_envelope_for
      ssl_tox_box_2 tox_box_2_builtin_motion_envelope
| ToxBox3BuiltinMotionEnvelope :
    tox_box_builtin_motion_envelope_for
      ssl_tox_box_3 tox_box_3_builtin_motion_envelope.

Definition breakable_box_1_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := 5900;
  envelope_max_x := 5900;
  envelope_min_y := 51;
  envelope_max_y := 51;
  envelope_min_z := 4400;
  envelope_max_z := 4400
|}.

Definition breakable_box_2_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := 5900;
  envelope_max_x := 5900;
  envelope_min_y := 51;
  envelope_max_y := 51;
  envelope_min_z := 2311;
  envelope_max_z := 2311
|}.

Inductive breakable_box_builtin_motion_envelope_for :
    ssl_object -> platform_center_envelope -> Prop :=
| BreakableBox1BuiltinMotionEnvelope :
    breakable_box_builtin_motion_envelope_for
      ssl_breakable_box_no_coins_1 breakable_box_1_builtin_motion_envelope
| BreakableBox2BuiltinMotionEnvelope :
    breakable_box_builtin_motion_envelope_for
      ssl_breakable_box_no_coins_2 breakable_box_2_builtin_motion_envelope.

Definition message_panel_1_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := 5702;
  envelope_max_x := 5702;
  envelope_min_y := -100000;
  envelope_max_y := 100000;
  envelope_min_z := 2974;
  envelope_max_z := 2974
|}.

Definition message_panel_2_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := -3260;
  envelope_max_x := -3260;
  envelope_min_y := -100000;
  envelope_max_y := 100000;
  envelope_min_z := 800;
  envelope_max_z := 800
|}.

Definition message_panel_3_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := 5130;
  envelope_max_x := 5130;
  envelope_min_y := -100000;
  envelope_max_y := 100000;
  envelope_min_z := -370;
  envelope_max_z := -370
|}.

Inductive message_panel_builtin_motion_envelope_for :
    ssl_object -> platform_center_envelope -> Prop :=
| MessagePanel1BuiltinMotionEnvelope :
    message_panel_builtin_motion_envelope_for
      ssl_message_panel_1 message_panel_1_builtin_motion_envelope
| MessagePanel2BuiltinMotionEnvelope :
    message_panel_builtin_motion_envelope_for
      ssl_message_panel_2 message_panel_2_builtin_motion_envelope
| MessagePanel3BuiltinMotionEnvelope :
    message_panel_builtin_motion_envelope_for
      ssl_message_panel_3 message_panel_3_builtin_motion_envelope.

Definition cannon_lid_builtin_motion_envelope : platform_center_envelope := {|
  envelope_min_x := 6863;
  envelope_max_x := 7063;
  envelope_min_y := -15;
  envelope_max_y := 0;
  envelope_min_z := -6860;
  envelope_max_z := -6860
|}.

Theorem pyramid_top_builtin_motion_does_not_overlap_area1_to_area2_warps :
  forall warp,
    In warp ssl_area1_to_area2_warps ->
    ~ platform_envelope_overlaps_warp_bbox
        pyramid_top_builtin_motion_envelope
        pyramid_top_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros warp Hwarp.
  destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_envelope_warp_overlap.
Qed.

Theorem tox_box_builtin_motion_envelopes_do_not_overlap_area1_to_area2_warps :
  forall obj envelope warp,
    In obj [ssl_tox_box_1; ssl_tox_box_2; ssl_tox_box_3] ->
    tox_box_builtin_motion_envelope_for obj envelope ->
    In warp ssl_area1_to_area2_warps ->
    ~ platform_envelope_overlaps_warp_bbox
        envelope tox_box_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros obj envelope warp Hobj Henvelope Hwarp.
  destruct Hobj as [Hobj | [Hobj | [Hobj | []]]]; subst obj;
    inversion Henvelope; subst envelope;
    destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_envelope_warp_overlap.
Qed.

Theorem breakable_box_builtin_motion_envelopes_do_not_overlap_area1_to_area2_warps :
  forall obj envelope warp,
    In obj ssl_area1_breakable_box_sources ->
    breakable_box_builtin_motion_envelope_for obj envelope ->
    In warp ssl_area1_to_area2_warps ->
    ~ platform_envelope_overlaps_warp_bbox
        envelope breakable_box_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros obj envelope warp Hobj Henvelope Hwarp.
  destruct Hobj as [Hobj | [Hobj | []]]; subst obj;
    inversion Henvelope; subst envelope;
    destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_envelope_warp_overlap.
Qed.

Theorem message_panel_builtin_motion_envelopes_do_not_overlap_area1_to_area2_warps :
  forall obj envelope warp,
    In obj ssl_area1_message_panel_sources ->
    message_panel_builtin_motion_envelope_for obj envelope ->
    In warp ssl_area1_to_area2_warps ->
    ~ platform_envelope_overlaps_warp_bbox
        envelope message_panel_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros obj envelope warp Hobj Henvelope Hwarp.
  destruct Hobj as [Hobj | [Hobj | [Hobj | []]]]; subst obj;
    inversion Henvelope; subst envelope;
    destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_envelope_warp_overlap.
Qed.

Theorem cannon_lid_builtin_motion_does_not_overlap_area1_to_area2_warps :
  forall warp,
    In warp ssl_area1_to_area2_warps ->
    ~ platform_envelope_overlaps_warp_bbox
        cannon_lid_builtin_motion_envelope
        cannon_lid_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros warp Hwarp.
  destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_envelope_warp_overlap.
Qed.

Definition exclamation_box_collision_loaded_position_is_home : bool := true.

Theorem exclamation_box_collision_loaded_motion_does_not_overlap_area1_to_area2_warps :
  exclamation_box_collision_loaded_position_is_home = true /\
  forall obj warp,
    In obj ssl_area1_exclamation_box_sources ->
    In warp ssl_area1_to_area2_warps ->
    ~ platform_bbox_overlaps_warp_bbox
        obj exclamation_box_bbox warp cloned_route_mario_hitbox_height.
Proof.
  split.
  - reflexivity.
  - apply original_exclamation_boxes_do_not_overlap_area1_to_area2_warps.
Qed.

Inductive modeled_source_platform_transport : Type :=
| BuiltInPyramidTopMotion
| BuiltInToxBoxMotion
| BuiltInBreakableBoxMotion
| BuiltInMessagePanelMotion
| BuiltInCannonLidMotion
| BuiltInExclamationBoxCollisionMotion
| FakeObjectGrabDropExclamationBox
| NoDropHeldExclamationBox.

Definition modeled_transport_can_leave_standable_surface_at_area2_warp
    (mechanism : modeled_source_platform_transport) : Prop :=
  match mechanism with
  | BuiltInPyramidTopMotion =>
      exists warp,
        In warp ssl_area1_to_area2_warps /\
        platform_envelope_overlaps_warp_bbox
          pyramid_top_builtin_motion_envelope
          pyramid_top_bbox warp cloned_route_mario_hitbox_height
  | BuiltInToxBoxMotion =>
      exists obj envelope warp,
        In obj [ssl_tox_box_1; ssl_tox_box_2; ssl_tox_box_3] /\
        tox_box_builtin_motion_envelope_for obj envelope /\
        In warp ssl_area1_to_area2_warps /\
        platform_envelope_overlaps_warp_bbox
          envelope tox_box_bbox warp cloned_route_mario_hitbox_height
  | BuiltInBreakableBoxMotion =>
      exists obj envelope warp,
        In obj ssl_area1_breakable_box_sources /\
        breakable_box_builtin_motion_envelope_for obj envelope /\
        In warp ssl_area1_to_area2_warps /\
        platform_envelope_overlaps_warp_bbox
          envelope breakable_box_bbox warp cloned_route_mario_hitbox_height
  | BuiltInMessagePanelMotion =>
      exists obj envelope warp,
        In obj ssl_area1_message_panel_sources /\
        message_panel_builtin_motion_envelope_for obj envelope /\
        In warp ssl_area1_to_area2_warps /\
        platform_envelope_overlaps_warp_bbox
          envelope message_panel_bbox warp cloned_route_mario_hitbox_height
  | BuiltInCannonLidMotion =>
      exists warp,
        In warp ssl_area1_to_area2_warps /\
        platform_envelope_overlaps_warp_bbox
          cannon_lid_builtin_motion_envelope
          cannon_lid_bbox warp cloned_route_mario_hitbox_height
  | BuiltInExclamationBoxCollisionMotion =>
      exists obj warp,
        In obj ssl_area1_exclamation_box_sources /\
        In warp ssl_area1_to_area2_warps /\
        platform_bbox_overlaps_warp_bbox
          obj exclamation_box_bbox warp cloned_route_mario_hitbox_height
  | FakeObjectGrabDropExclamationBox =>
      fake_object_grab_drop_produces_standable_exclamation_box
  | NoDropHeldExclamationBox =>
      no_drop_fake_box_at_warp_proper_can_seed_platform
  end.

Theorem modeled_source_platform_transport_mechanisms_do_not_seed_warp :
  forall mechanism,
    ~ modeled_transport_can_leave_standable_surface_at_area2_warp mechanism.
Proof.
  intros mechanism Hseed.
  destruct mechanism.
  - destruct Hseed as [warp [Hwarp Hoverlap]].
    exact
      (pyramid_top_builtin_motion_does_not_overlap_area1_to_area2_warps
        warp Hwarp Hoverlap).
  - destruct Hseed as (obj & envelope & warp & Hobj & Henvelope & Hwarp & Hoverlap).
    exact
      (tox_box_builtin_motion_envelopes_do_not_overlap_area1_to_area2_warps
        obj envelope warp Hobj Henvelope Hwarp Hoverlap).
  - destruct Hseed as (obj & envelope & warp & Hobj & Henvelope & Hwarp & Hoverlap).
    exact
      (breakable_box_builtin_motion_envelopes_do_not_overlap_area1_to_area2_warps
        obj envelope warp Hobj Henvelope Hwarp Hoverlap).
  - destruct Hseed as (obj & envelope & warp & Hobj & Henvelope & Hwarp & Hoverlap).
    exact
      (message_panel_builtin_motion_envelopes_do_not_overlap_area1_to_area2_warps
        obj envelope warp Hobj Henvelope Hwarp Hoverlap).
  - destruct Hseed as [warp [Hwarp Hoverlap]].
    exact
      (cannon_lid_builtin_motion_does_not_overlap_area1_to_area2_warps
        warp Hwarp Hoverlap).
  - destruct Hseed as (obj & warp & Hobj & Hwarp & Hoverlap).
    destruct exclamation_box_collision_loaded_motion_does_not_overlap_area1_to_area2_warps
      as [_ Hno_overlap].
    exact (Hno_overlap obj warp Hobj Hwarp Hoverlap).
  - exact (fake_object_grab_drop_exclamation_box_cannot_seed_platform Hseed).
  - exact (no_drop_fake_box_at_warp_proper_cannot_seed_platform Hseed).
Qed.

Definition modeled_transport_spindel_depth_route
    (mechanism : modeled_source_platform_transport) : Prop :=
  modeled_transport_can_leave_standable_surface_at_area2_warp mechanism /\
  exists seed_state watched kind free_list,
    area1_source_platform_seed seed_state watched kind /\
    nth_allocation_reuses_slot
      free_list ssl_area2_spindel_allocation_index watched.

Theorem no_modeled_transport_spindel_depth_route :
  forall mechanism,
    ~ modeled_transport_spindel_depth_route mechanism.
Proof.
  intros mechanism [Htransport _].
  exact
    (modeled_source_platform_transport_mechanisms_do_not_seed_warp
      mechanism Htransport).
Qed.
