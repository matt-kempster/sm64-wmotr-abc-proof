(** Rank 11: clean regular-Goomba installer boundary.

    Ordinary enemy damage is already known to dismount Mario from the second
    pole and land him on the upper ring.  This file separates that useful
    payoff from the missing installation.  It checks the complete stock
    Area-2 Goomba roster in both selected programs, the regular hitbox and
    jump source shape, the contact arithmetic at the ring, and a reviewed
    finite source-mesh receipt for ordinary walking, jump-floor snaps, a very
    permissive two-Goomba horizontal separation, and the only low-tier
    vertical moving support.

    The mesh receipt is produced by
    [instrumentation/rank11-goomba-installer/analyze_mesh.js].  Coq checks the
    receipt and its consequences; it does not pretend that the JavaScript
    connected-component computation is a Clight execution theorem.  Thus the
    conclusion closes the stated ordinary stock installation envelope, not
    H/F/R partial updates, a stale or forged object, an outside writer, OOB,
    DMA, or ACE. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts Area2LowerTargetCut Area2Rank11HandstandDamage
  Area2Rank12ObjectImpulse.

Import ListNotations.
Local Open Scope Z_scope.

(** * Every stock Area-2 Goomba *)

Definition rank11_area2_singleton_goombas : list (list Z) :=
  [[68; 3263; 778; 3157; 0];
   [68; 3389; 0; -1978; 0];
   [68; -3638; 0; 1928; 0];
   [68; 3263; 652; 2200; 0];
   [68; 3431; 673; -1373; 0];
   [68; -2100; 0; 3316; 0]].

Definition rank11_area2_triplet_spawners : list (list Z) :=
  [[63; 3181; 0; 3587; 0]].

Definition Rank11Area2GoombaRosterSourceShape : Prop :=
  records_with_tag 68 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) =
    rank11_area2_singleton_goombas /\
  records_with_tag 68 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) =
    rank11_area2_singleton_goombas /\
  records_with_tag 63 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) =
    rank11_area2_triplet_spawners /\
  records_with_tag 63 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) =
    rank11_area2_triplet_spawners /\
  records_with_tag 61 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) = [] /\
  records_with_tag 61 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) = [] /\
  records_with_tag 62 (gvar_init UAM.v_ssl_seg7_area_2_macro_objs) = [] /\
  records_with_tag 62 (gvar_init JAM.v_ssl_seg7_area_2_macro_objs) = [] /\
  calls_ident_s UEye._spawn_object_relative
    (fn_body UEye.f_bhv_goomba_triplet_spawner_update) = true /\
  calls_ident_s JEye._spawn_object_relative
    (fn_body JEye.f_bhv_goomba_triplet_spawner_update) = true.

Theorem rank11_area2_goomba_roster_source_shape_checked :
  Rank11Area2GoombaRosterSourceShape.
Proof.
  unfold Rank11Area2GoombaRosterSourceShape,
    rank11_area2_singleton_goombas, rank11_area2_triplet_spawners.
  vm_compute. repeat split; reflexivity.
Qed.

(** * The useful contact really is geometrically available *)

Definition rank11_goomba_hitbox_initializer : list init_data :=
  [Init_int32 (Int.repr 32768); (* INTERACT_BOUNCE_TOP *)
   Init_int8 (Int.repr 0); Init_int8 (Int.repr 1);
   Init_int8 (Int.repr 0); Init_int8 (Int.repr 1);
   Init_int16 (Int.repr 72); Init_int16 (Int.repr 50);
   Init_int16 (Int.repr 42); Init_int16 (Int.repr 40)].

Definition Rank11GoombaMovementSourceShape : Prop :=
  gvar_init UEye.v_sGoombaHitbox = rank11_goomba_hitbox_initializer /\
  gvar_init JEye.v_sGoombaHitbox = rank11_goomba_hitbox_initializer /\
  firstn 4 (gvar_init UEye.v_sGoombaProperties) =
    regular_goomba_property_prefix /\
  firstn 4 (gvar_init JEye.v_sGoombaProperties) =
    regular_goomba_property_prefix /\
  calls_ident_s UEye._obj_set_hitbox
    (fn_body UEye.f_bhv_goomba_init) = true /\
  calls_ident_s JEye._obj_set_hitbox
    (fn_body JEye.f_bhv_goomba_init) = true /\
  assigns_field_named_s UOH._hitboxRadius
    (fn_body UOH.f_obj_set_hitbox) = true /\
  assigns_field_named_s UOH._hitboxHeight
    (fn_body UOH.f_obj_set_hitbox) = true /\
  statement_mentions_ident_s UOH._scale
    (fn_body UOH.f_obj_set_hitbox) = true /\
  assigns_field_named_s JOH._hitboxRadius
    (fn_body JOH.f_obj_set_hitbox) = true /\
  assigns_field_named_s JOH._hitboxHeight
    (fn_body JOH.f_obj_set_hitbox) = true /\
  statement_mentions_ident_s JOH._scale
    (fn_body JOH.f_obj_set_hitbox) = true /\
  assigns_array_slot_int_constant_s UEye._asS32 49 2
    (fn_body UEye.f_goomba_begin_jump) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 2
    (fn_body JEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body UEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1077936128
    (fn_body UEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body JEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s 1077936128
    (fn_body JEye.f_goomba_begin_jump) = true /\
  statement_mentions_float32_bits_s float32_seventy_eight_bits
    (fn_body USurface.f_find_floor_from_list) = true /\
  statement_mentions_float32_bits_s float32_seventy_eight_bits
    (fn_body JSurface.f_find_floor_from_list) = true /\
  assigns_array_slot_s UEye._asF32 7
    (fn_body UEye.f_obj_resolve_object_collisions) = false /\
  assigns_array_slot_s JEye._asF32 7
    (fn_body JEye.f_obj_resolve_object_collisions) = false.

Theorem rank11_goomba_movement_source_shape_checked :
  Rank11GoombaMovementSourceShape.
Proof.
  unfold Rank11GoombaMovementSourceShape,
    rank11_goomba_hitbox_initializer.
  vm_compute. repeat split; reflexivity.
Qed.

(** Radius and height are written after applying the regular 1.5 scale.
    Hundredths/tenths are unnecessary here: all resulting values are exact. *)
Definition rank11_regular_goomba_radius : Z := 108.
Definition rank11_regular_goomba_height : Z := 75.
Definition rank11_mario_hitbox_radius : Z := 37.
Definition rank11_pole_to_ring_inner_edge : Z := 102.
Definition rank11_holding_mario_y : Z := 4020.
Definition rank11_ring_goomba_y : Z := 3942.
Definition rank11_first_jump_rise : Z := 21.

Theorem rank11_regular_goomba_scaled_hitbox_is_exact :
  72 * 15 = rank11_regular_goomba_radius * 10 /\
  50 * 15 = rank11_regular_goomba_height * 10.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank11_ring_goomba_needs_only_its_first_jump_update :
  rank11_ring_goomba_y + rank11_regular_goomba_height <
    rank11_holding_mario_y /\
  rank11_holding_mario_y <=
    rank11_ring_goomba_y + rank11_first_jump_rise +
      rank11_regular_goomba_height /\
  rank11_pole_to_ring_inner_edge <
    rank11_regular_goomba_radius + rank11_mario_hitbox_radius.
Proof.
  unfold rank11_ring_goomba_y, rank11_regular_goomba_height,
    rank11_holding_mario_y, rank11_first_jump_rise,
    rank11_pole_to_ring_inner_edge, rank11_regular_goomba_radius,
    rank11_mario_hitbox_radius.
  lia.
Qed.

(** [goomba_begin_jump] writes 25 and regular gravity is -4, so the first
    move rises by 21.  The exact subsequent pre-query heights peak at 66. *)
Definition rank11_goomba_jump_rises : list Z := [21; 38; 51; 60; 65; 66].

Theorem rank11_goomba_jump_and_floor_query_limits :
  Forall (fun rise => rise <= 66) rank11_goomba_jump_rises /\
  In 66 rank11_goomba_jump_rises /\
  66 + 78 = 144.
Proof.
  unfold rank11_goomba_jump_rises.
  split.
  - constructor; [lia |].
    constructor; [lia |].
    constructor; [lia |].
    constructor; [lia |].
    constructor; [lia |].
    constructor; [lia | constructor].
  - split.
    + right. right. right. right. right. left. reflexivity.
    + reflexivity.
Qed.

(** * Reviewed finite mesh receipt

    Components are the analyzer's stable numbering for the pinned 1,080
    vertices and 1,558 triangles.  A transition is deliberately permissive:
    ordinary chase movement may bridge 30 X/Z units with the source floor
    tolerances, jump-floor snapping may rise 144, and the pair audit separately
    grants a full 216-unit horizontal separation. *)

Record Rank11MeshReachabilityReceipt := {
  rank11_mesh_origin : Z;
  rank11_mesh_start_component : Z;
  rank11_mesh_reachable_components : list Z;
  rank11_mesh_reachable_max_y : Z
}.

Definition rank11_mesh_receipts : list Rank11MeshReachabilityReceipt :=
  [{| rank11_mesh_origin := 1; rank11_mesh_start_component := 47;
      rank11_mesh_reachable_components := [46; 47];
      rank11_mesh_reachable_max_y := 640 |};
   {| rank11_mesh_origin := 2; rank11_mesh_start_component := 0;
      rank11_mesh_reachable_components := [0; 56; 58; 59; 60; 61; 62; 63];
      rank11_mesh_reachable_max_y := 113 |};
   {| rank11_mesh_origin := 3; rank11_mesh_start_component := 0;
      rank11_mesh_reachable_components := [0; 56; 58; 59; 60; 61; 62; 63];
      rank11_mesh_reachable_max_y := 113 |};
   {| rank11_mesh_origin := 4; rank11_mesh_start_component := 46;
      rank11_mesh_reachable_components := [46; 47];
      rank11_mesh_reachable_max_y := 640 |};
   {| rank11_mesh_origin := 5; rank11_mesh_start_component := 45;
      rank11_mesh_reachable_components :=
        [20; 21; 22; 23; 24; 25; 26; 45; 48; 49; 51; 52; 53];
      rank11_mesh_reachable_max_y := 640 |};
   {| rank11_mesh_origin := 6; rank11_mesh_start_component := 0;
      rank11_mesh_reachable_components := [0; 56; 58; 59; 60; 61; 62; 63];
      rank11_mesh_reachable_max_y := 113 |};
   {| rank11_mesh_origin := 7; rank11_mesh_start_component := 0;
      rank11_mesh_reachable_components := [0; 56; 58; 59; 60; 61; 62; 63];
      rank11_mesh_reachable_max_y := 113 |};
   {| rank11_mesh_origin := 8; rank11_mesh_start_component := 0;
      rank11_mesh_reachable_components := [0; 56; 58; 59; 60; 61; 62; 63];
      rank11_mesh_reachable_max_y := 113 |};
   {| rank11_mesh_origin := 9; rank11_mesh_start_component := 0;
      rank11_mesh_reachable_components := [0; 56; 58; 59; 60; 61; 62; 63];
      rank11_mesh_reachable_max_y := 113 |}].

Definition rank11_goal_component : Z := 74.

Definition rank11_mesh_receipt_excludes_goal
    (receipt : Rank11MeshReachabilityReceipt) : bool :=
  negb (existsb (Z.eqb rank11_goal_component)
    (rank11_mesh_reachable_components receipt)) &&
  (rank11_mesh_reachable_max_y receipt <? lower_ring_floor_y).

Theorem rank11_every_stock_spawn_is_below_and_disconnected_from_ring :
  length rank11_mesh_receipts = 9%nat /\
  forallb rank11_mesh_receipt_excludes_goal rank11_mesh_receipts = true.
Proof. vm_compute. split; reflexivity. Qed.

(** The separate pair graph grants more than a regular Goomba diameter to
    every potential transition.  It still finds no route from any of the nine
    damaging actors to component 74. *)
Definition rank11_pair_abstract_paths : list (option (list Z)) :=
  [None; None; None; None; None; None; None; None; None].

Theorem rank11_pair_separation_overapproximation_finds_no_path :
  length rank11_pair_abstract_paths = 9%nat /\
  forallb (fun path => match path with None => true | Some _ => false end)
    rank11_pair_abstract_paths = true /\
  2 * rank11_regular_goomba_radius = 216.
Proof.
  unfold rank11_pair_abstract_paths, rank11_regular_goomba_radius.
  vm_compute. repeat split; reflexivity.
Qed.

(** The low vertical Grindel's local top is 450.  Its stock raise reaches
    base Y=695, hence top Y=1145.  The only static components within 250 X/Z
    units of its top footprint have heights -101, 0, 72, or 640; in
    particular it has no upper discharge floor. *)
Definition rank11_grindel_nearby_static_heights : list Z :=
  [0; -101; 72; 72; 640; 640].

Theorem rank11_low_grindel_has_no_upward_discharge :
  Forall (fun y => y <= 640) rank11_grindel_nearby_static_heights /\
  695 + 450 = 1145 /\
  1145 < lower_ring_floor_y.
Proof.
  unfold rank11_grindel_nearby_static_heights, lower_ring_floor_y.
  split.
  - constructor; [lia |].
    constructor; [lia |].
    constructor; [lia |].
    constructor; [lia |].
    constructor; [lia |].
    constructor; [lia | constructor].
  - split; reflexivity.
Qed.

Record Area2Rank11OrdinaryGoombaInstallerBoundary : Prop := {
  rank11_installer_roster : Rank11Area2GoombaRosterSourceShape;
  rank11_installer_movement_source : Rank11GoombaMovementSourceShape;
  rank11_installer_contact_available :
    rank11_ring_goomba_y + rank11_regular_goomba_height <
      rank11_holding_mario_y /\
    rank11_holding_mario_y <=
      rank11_ring_goomba_y + rank11_first_jump_rise +
        rank11_regular_goomba_height /\
    rank11_pole_to_ring_inner_edge <
      rank11_regular_goomba_radius + rank11_mario_hitbox_radius;
  rank11_installer_static_receipt :
    length rank11_mesh_receipts = 9%nat /\
    forallb rank11_mesh_receipt_excludes_goal rank11_mesh_receipts = true;
  rank11_installer_pair_receipt :
    length rank11_pair_abstract_paths = 9%nat /\
    forallb (fun path => match path with None => true | Some _ => false end)
      rank11_pair_abstract_paths = true /\
    2 * rank11_regular_goomba_radius = 216;
  rank11_installer_low_lift_closed :
    Forall (fun y => y <= 640) rank11_grindel_nearby_static_heights /\
    695 + 450 = 1145 /\
    1145 < lower_ring_floor_y;
  rank11_installer_amp_payoff_closed : Area2Rank12ShockCompositeClosure
}.

Theorem area2_rank11_ordinary_goomba_installer_boundary_holds :
  Area2Rank11OrdinaryGoombaInstallerBoundary.
Proof.
  constructor.
  - exact rank11_area2_goomba_roster_source_shape_checked.
  - exact rank11_goomba_movement_source_shape_checked.
  - exact rank11_ring_goomba_needs_only_its_first_jump_update.
  - exact rank11_every_stock_spawn_is_below_and_disconnected_from_ring.
  - exact rank11_pair_separation_overapproximation_finds_no_path.
  - exact rank11_low_grindel_has_no_upward_discharge.
  - exact area2_rank12_shock_composite_closure_holds.
Qed.
