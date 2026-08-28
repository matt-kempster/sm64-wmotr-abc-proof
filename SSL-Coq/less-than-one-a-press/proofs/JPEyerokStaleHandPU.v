(** PU-scale branch of the original-JP stale-Eyerok-hand proposal.

    This file first keeps four gates separate, then packages their one exact
    conditional conjunction.  It proves a three-period signed-16 warp alias,
    extracts the real static ceiling and closed-hand Pedro geometry, records
    the two allocation counts which place Spindel into a source-audited stale-
    hand ordinal, and evaluates Spindel's nonzero binary32 displacement from
    the floor-snapped input.  It does not assume a live hand-on-warp execution,
    a controller-reached set of ten or eleven suppressed coins, pointer
    lifetime, or a later Act-3 collection trace; the closure results below show
    that stock hand motion, ordinary loading, and both Eyerok dialog windows do
    not construct that PU installation. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Floats Integers.
From LessThanOneAPress.Generated Require Import
  jp_behavior_data jp_math_util jp_ssl_area2_macro.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1NonlocalPlatformMirror Area1PhaseSplit CollisionMeshFacts
  FirstTargetRefinement JPEyerokStaleHand PyramidTopPU PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

Module JPEPU_JPMath := jp_math_util.

(** * Signed-16 collision match *)

Definition jp_pu_y_periods : Z := 4.
Definition jp_pu_z_periods : Z := 160.
Definition jp_pu_area3_warp_x : Z := 0.
Definition jp_pu_area3_warp_query_y : Z :=
  347 + 65536 * jp_pu_y_periods.
Definition jp_pu_area3_warp_z : Z := -1100 + 65536 * jp_pu_z_periods.

Theorem jp_pu_star_band_point_has_exact_warp_query_alias :
  jp_pu_area3_warp_query_y = 262491 /\
  jp_pu_area3_warp_z = 10484660 /\
  signed16 jp_pu_area3_warp_x = 0 /\
  signed16 jp_pu_area3_warp_query_y = 347 /\
  signed16 jp_pu_area3_warp_z = -1100.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** PU periods do not create a second local collision point.  In particular,
    every Z-period copy of the chosen warp sample still queries local
    Z=[-1100], not the sleeping-hand/Pedro neighborhood around Z=[-3393]. *)
Theorem jp_pu_z_periods_preserve_only_the_warp_local_sample :
  forall periods,
    signed16 (-1100 + 65536 * periods) = -1100 /\
    signed16 (-1100 + 65536 * periods) <> known_pedro_hand_pivot_z.
Proof.
  intros periods.
  unfold signed16, known_pedro_hand_pivot_z.
  replace (-1100 + 65536 * periods + 32768)
    with (31668 + 65536 * periods) by ring.
  rewrite Z.add_mod by lia.
  rewrite Z.mul_mod by lia.
  vm_compute.
  split; [reflexivity | discriminate].
Qed.

(** A dynamic surface is built from signed-16 vertices, so an interpolated
    floor over one of its triangles remains between the signed-16 extrema.
    This integer theorem isolates the decisive platform-proximity failure of
    the four-Y-period witness: its raw Y cannot be within the strict four-unit
    [update_mario_platform] tolerance of any such ordinary floor.  It does not
    preclude a distinct local Object sample produced by a State/Object split. *)
Definition jp_pu_integer_platform_close (raw_y floor_y : Z) : Prop :=
  Z.abs (raw_y - floor_y) < 4.

Theorem jp_pu_four_y_period_sample_cannot_install_a_signed16_floor :
  forall floor_y,
    -32768 <= floor_y <= 32767 ->
    ~ jp_pu_integer_platform_close jp_pu_area3_warp_query_y floor_y.
Proof.
  intros floor_y Hrange Hclose.
  unfold jp_pu_integer_platform_close, jp_pu_area3_warp_query_y,
    jp_pu_y_periods in Hclose.
  rewrite Z.abs_eq in Hclose by lia.
  lia.
Qed.

Definition jp_pu_recorded_local_entry_y : float32 :=
  Float32.of_bits (Int.repr 1135413836). (* 346.08044f *)

Definition jp_pu_four_period_entry_y : float32 :=
  Float32.add jp_pu_recorded_local_entry_y (f32_of_Z (4 * 65536)).

Theorem jp_pu_four_y_period_sample_fails_the_exact_recorded_floor_test :
  Float32.to_int jp_pu_four_period_entry_y = Some (Int.repr 262490) /\
  Float32.cmp Clt
    (Float32.abs
      (Float32.sub jp_pu_four_period_entry_y jp_pu_recorded_local_entry_y))
    (f32_of_Z 4) = false.
Proof. vm_compute. split; reflexivity. Qed.

(** The generated closed and open hand meshes have exact local Y ranges.
    At scale 1.5 their complete bottom-to-top spans are 301.5 and 507 units,
    respectively—both larger than the 160-unit Pedro cutoff.  This is an
    exact mesh fact, not by itself a claim that an unrelated static ceiling
    cannot form a different narrow gap with the hand's upward face. *)
Definition jp_pu_vertex_y_between
    (lower upper : Z) (vertex : Z * Z * Z) : Prop :=
  let '(_, y, _) := vertex in lower <= y <= upper.

Theorem jp_pu_active_hand_mesh_y_ranges_are_exact :
  Forall (jp_pu_vertex_y_between 3 204)
    jp_eyerok_sleep_box_vertices /\
  Forall (jp_pu_vertex_y_between 0 338)
    jp_eyerok_open_vertices.
Proof.
  vm_compute;
  repeat match goal with
  | |- _ /\ _ => split
  | |- Forall _ [] => apply Forall_nil
  | |- Forall _ (_ :: _) => apply Forall_cons
  end;
  easy.
Qed.

Definition jp_pu_pedro_cutoff_doubled : Z := 2 * 160.
Definition jp_pu_closed_mesh_span_doubled : Z := 3 * (204 - 3).
Definition jp_pu_open_mesh_span_doubled : Z := 3 * (338 - 0).

Theorem jp_pu_active_hand_own_mesh_spans_exceed_pedro_cutoff :
  jp_pu_closed_mesh_span_doubled = 603 /\
  jp_pu_open_mesh_span_doubled = 1014 /\
  jp_pu_pedro_cutoff_doubled < jp_pu_closed_mesh_span_doubled /\
  jp_pu_pedro_cutoff_doubled < jp_pu_open_mesh_span_doubled.
Proof.
  vm_compute.
  repeat split; try easy.
Qed.

(** The only already-constructed stock Eyerok Pedro configurations use the
    side-specific sleeping/waking meshes at the home pivot.  Their coarse
    transformed envelope remains strictly behind the Area-3 warp.  Adding PU
    periods cannot repair that local separation because [signed16] removes
    exactly those periods before the surface query. *)
Theorem jp_pu_known_pedro_geometry_cannot_also_cover_the_warp :
  forall transformed_local_z warp_z periods,
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    known_pedro_hand_pivot_z + transformed_local_z < warp_z /\
    signed16 (-1100 + 65536 * periods) <> known_pedro_hand_pivot_z.
Proof.
  intros transformed_local_z warp_z periods Hlocal Hwarp.
  split.
  - eapply known_pedro_hand_envelope_is_separate_from_warp_1d; eauto.
  - exact (proj2 (jp_pu_z_periods_preserve_only_the_warp_local_sample periods)).
Qed.

(** * A distinct static-ceiling Pedro target at the warp

    The sleeping-hand Pedro strips remain spatially irrelevant, but they are
    not the only possible source of a narrow gap.  The generated Area-3 mesh
    contains a downward-facing Y=[768] ceiling directly above the warp.  The
    following finite receipt pins its four vertices and the particular
    triangle containing local point [(0,-1100)]. *)

Definition jp_pu_area3_ceiling_768_vertices : list (option (Z * Z * Z)) :=
  map (nth_error jp_area3_collision_vertices) [76%nat; 77%nat; 115%nat; 119%nat].

Definition jp_pu_area3_lower_warp_ceiling_vertices :
    list (option (Z * Z * Z)) :=
  map (nth_error jp_area3_collision_vertices) [70%nat; 71%nat; 107%nat].

Definition jp_pu_area3_collision_words : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_area_3_collision).

(** The Area-3 stream begins with two header words and 122 three-word
    vertices.  Its first surface block then has a two-word
    [SURFACE_DEFAULT,158] header followed by these 158 triangles. *)
Definition jp_pu_area3_default_triangles : list (Z * Z * Z) :=
  triples_from_words
    (firstn (3 * 158) (skipn 370 jp_pu_area3_collision_words)).

Theorem jp_pu_area3_ceiling_768_vertices_are_exact :
  jp_pu_area3_ceiling_768_vertices =
    [Some (192, 768, -2432); Some (192, 768, -1023);
     Some (-191, 768, -1023); Some (-191, 768, -2432)].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_pu_area3_lower_warp_ceiling_vertices_are_exact :
  jp_pu_area3_lower_warp_ceiling_vertices =
    [Some (-2559, -409, -370); Some (192, -409, -1664);
     Some (2560, -409, -370)].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_pu_area3_ceiling_triangle_commands_are_exact :
  firstn 2 (skipn 368 jp_pu_area3_collision_words) = [0; 158] /\
  nth_error jp_pu_area3_default_triangles 129%nat =
    Some (76, 77, 115) /\
  nth_error jp_pu_area3_default_triangles 141%nat =
    Some (76, 115, 119).
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition jp_pu_edge_cross_xz
    (first second point : Z * Z) : Z :=
  let '(first_x, first_z) := first in
  let '(second_x, second_z) := second in
  let '(point_x, point_z) := point in
  (second_x - first_x) * (point_z - first_z) -
  (second_z - first_z) * (point_x - first_x).

(** This is the Y component of [(second-first) x (third-first)].  A negative
    value is the orientation used to place the face in the ceiling list. *)
Definition jp_pu_triangle_normal_y
    (first second third : Z * Z) : Z :=
  - jp_pu_edge_cross_xz first second third.

Definition jp_pu_ceiling_triangle_contains_warp_sample : Prop :=
  let point := (0, -1100) in
  let first := (192, -2432) in
  let second := (192, -1023) in
  let third := (-191, -1023) in
  0 <= jp_pu_edge_cross_xz first second point /\
  0 <= jp_pu_edge_cross_xz second third point /\
  0 <= jp_pu_edge_cross_xz third first point.

Theorem jp_pu_static_ceiling_triangle_contains_the_warp_sample :
  jp_pu_ceiling_triangle_contains_warp_sample /\
  jp_pu_edge_cross_xz (192, -2432) (192, -1023) (0, -1100) = 270528 /\
  jp_pu_edge_cross_xz (192, -1023) (-191, -1023) (0, -1100) = 29491 /\
  jp_pu_edge_cross_xz (-191, -1023) (192, -2432) (0, -1100) = 239628.
Proof. vm_compute. repeat split; easy. Qed.

Theorem jp_pu_static_ceiling_triangle_has_negative_y_orientation :
  jp_pu_triangle_normal_y
    (192, -2432) (192, -1023) (-191, -1023) = -539647 /\
  jp_pu_triangle_normal_y
    (192, -2432) (192, -1023) (-191, -1023) < 0.
Proof. vm_compute. split; easy. Qed.

(** At yaw zero and scale 1.5, the closed hand top at local Y=[204]
    contributes exactly 306 world units.  A pivot Y=[302] therefore places
    that owned floor at Y=[608].  The static ceiling at Y=[768] leaves the
    exact 160-unit non-updating landing gap.  The local top triangles both
    contain [(0,0)], so the hypothetical pivot [(0,302,-1100)] puts their
    owned floor at the same X/Z as the warp. *)
Definition jp_pu_closed_top_world_offset_y : Z := 306.
Definition jp_pu_ceiling_pedro_hand_pivot_y : Z := 302.
Definition jp_pu_ceiling_pedro_floor_y : Z :=
  jp_pu_ceiling_pedro_hand_pivot_y + jp_pu_closed_top_world_offset_y.
Definition jp_pu_ceiling_y : Z := 768.
Definition jp_pu_ceiling_pedro_z_periods : Z := -3.
Definition jp_pu_ceiling_pedro_raw_z : Z :=
  -1100 + 65536 * jp_pu_ceiling_pedro_z_periods.

Definition jp_pu_closed_top_contains_local_origin : Prop :=
  let point := (0, 0) in
  let first := (-63, -90) in
  let second := (68, 147) in
  let third := (68, -134) in
  jp_pu_edge_cross_xz first second point <= 0 /\
  jp_pu_edge_cross_xz second third point <= 0 /\
  jp_pu_edge_cross_xz third first point <= 0.

Definition jp_pu_pedro_retention_gap (floor_y ceiling_y : Z) : Prop :=
  floor_y <= ceiling_y /\ ceiling_y - floor_y <= 160.

Definition jp_pu_closed_hand_pedro_pivot_band (pivot_y : Z) : Prop :=
  302 <= pivot_y <= 460.

Theorem jp_pu_closed_hand_pedro_pivot_band_is_exact :
  forall pivot_y,
    jp_pu_closed_hand_pedro_pivot_band pivot_y ->
    347 < pivot_y + jp_pu_closed_top_world_offset_y /\
    jp_pu_pedro_retention_gap
      (pivot_y + jp_pu_closed_top_world_offset_y) jp_pu_ceiling_y /\
    pivot_y + jp_pu_closed_top_world_offset_y + 80 <=
      jp_pu_ceiling_y + 78.
Proof.
  unfold jp_pu_closed_hand_pedro_pivot_band,
    jp_pu_closed_top_world_offset_y, jp_pu_pedro_retention_gap,
    jp_pu_ceiling_y.
  intros pivot_y Hband.
  repeat split; lia.
Qed.

Definition jp_pu_warp_standing_closed_top_y : float32 :=
  Float32.add jp_pu_recorded_local_entry_y
    (f32_of_Z jp_pu_closed_top_world_offset_y).

Definition jp_pu_warp_standing_closed_top_gap : float32 :=
  Float32.sub (f32_of_Z jp_pu_ceiling_y)
    jp_pu_warp_standing_closed_top_y.

Definition jp_pu_warp_standing_closed_top_y_int : Z := 652.

Theorem jp_pu_warp_standing_closed_top_is_an_exact_pedro_pair :
  Float32.to_bits jp_pu_warp_standing_closed_top_y =
      Int.repr 1143145766 /\
  Float32.to_bits jp_pu_warp_standing_closed_top_gap =
      Int.repr 1122490064 /\
  Float32.to_int jp_pu_warp_standing_closed_top_y =
      Some (Int.repr jp_pu_warp_standing_closed_top_y_int) /\
  Float32.cmp Cle jp_pu_warp_standing_closed_top_gap (f32_of_Z 160) = true /\
  Float32.cmp Clt jp_pu_recorded_local_entry_y
      jp_pu_warp_standing_closed_top_y = true /\
  Float32.cmp Cle
      (Float32.add jp_pu_warp_standing_closed_top_y (f32_of_Z 80))
      (Float32.add (f32_of_Z jp_pu_ceiling_y) (f32_of_Z 78)) = true /\
  Float32.cmp Clt
      (Float32.abs
        (Float32.sub jp_pu_warp_standing_closed_top_y
          jp_pu_warp_standing_closed_top_y))
      (f32_of_Z 4) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The pinned source audit enumerates exactly two static downward faces at the
    warp sample: Y=[-409] and Y=[768].  At the closed top, the lower one and the
    hand's own local-Y=[3] underside both fail the ceiling query's 78-unit
    buffer, while Y=[768] passes it. *)
Theorem jp_pu_warp_standing_ceiling_buffer_choices_are_exact :
  jp_pu_warp_standing_closed_top_y_int + 80 > -409 + 78 /\
  jp_pu_warp_standing_closed_top_y_int + 80 <= 768 + 78 /\
  (3 * 204 + 2 * 80) - (3 * 3 + 2 * 78) = 607 /\
  0 < 607.
Proof. vm_compute. repeat split; easy. Qed.

Definition jp_pu_floor_after_landing
    (cached selected : CachedArea3Floor) (floor_y ceiling_y : Z)
    : CachedArea3Floor :=
  if 160 <? ceiling_y - floor_y then selected else cached.

Theorem jp_pu_closed_hand_lower_boundary_has_exact_retention_geometry :
  jp_pu_closed_top_world_offset_y = 3 * 204 / 2 /\
  jp_pu_ceiling_pedro_floor_y = 608 /\
  jp_pu_ceiling_pedro_raw_z = -197708 /\
  signed16 jp_pu_ceiling_pedro_raw_z = -1100 /\
  jp_pu_closed_top_contains_local_origin /\
  jp_pu_pedro_retention_gap
    jp_pu_ceiling_pedro_floor_y jp_pu_ceiling_y /\
  jp_pu_floor_after_landing CachedWarp1D (CachedHandFloor EyerokRight)
    jp_pu_ceiling_pedro_floor_y jp_pu_ceiling_y = CachedWarp1D /\
  jp_pu_integer_platform_close
    jp_pu_ceiling_pedro_floor_y jp_pu_ceiling_pedro_floor_y.
Proof.
  vm_compute.
  repeat split; try easy.
Qed.

(** This is the now-precise live reachability target, not a trace witness.  The
    arithmetic above constructs the spatial landing and subsequent zero-
    distance platform test; a clean execution still has to put a live closed
    hand at such a pose while Mario retains [CachedWarp1D]. *)
Record JPEyerokPUCeilingPedroTarget : Type := {
  jp_pu_ceiling_pedro_side : EyerokHandSide;
  jp_pu_ceiling_pedro_cached_floor : CachedArea3Floor;
  jp_pu_ceiling_pedro_fresh_owner : FreshPlatformOwner;
  jp_pu_ceiling_pedro_live_pivot : Z * Z * Z;
  jp_pu_ceiling_pedro_cache_is_warp :
    jp_pu_ceiling_pedro_cached_floor = CachedWarp1D;
  jp_pu_ceiling_pedro_owner_is_live_hand :
    refreshed_platform_address jp_pu_ceiling_pedro_fresh_owner =
      Some jp_pu_ceiling_pedro_side;
  jp_pu_ceiling_pedro_pose_is_target :
    let '(pivot_x, pivot_y, pivot_z) := jp_pu_ceiling_pedro_live_pivot in
    signed16 pivot_x = 0 /\
    jp_pu_closed_hand_pedro_pivot_band pivot_y /\
    signed16 pivot_z = -1100
}.

(** This is the exact spatial fact the live query must add: a dynamic hand
    surface, not merely the static warp, has to be selected at this same
    signed-16 sample while Mario's cached floor remains [CachedWarp1D]. *)
Record JPEyerokPURetainedFloorTarget : Type := {
  jp_pu_cached_floor : CachedArea3Floor;
  jp_pu_fresh_owner : FreshPlatformOwner;
  jp_pu_query_x_s16 : Z;
  jp_pu_query_y_s16 : Z;
  jp_pu_query_z_s16 : Z;
  jp_pu_cached_floor_is_warp : jp_pu_cached_floor = CachedWarp1D;
  jp_pu_query_is_star_band_alias :
    jp_pu_query_x_s16 = 0 /\
    jp_pu_query_y_s16 = 347 /\
    jp_pu_query_z_s16 = -1100;
  jp_pu_fresh_owner_is_hand :
    exists side, refreshed_platform_address jp_pu_fresh_owner = Some side
}.

(** * Allocation ordinal and nonzero payload receipt *)

Inductive JPEyerokHandDeathOrder :=
| JPEyerokFirstHandDeath
| JPEyerokLastHandDeath.

Record JPEyerokPUSpindelReceipt : Type := {
  jp_pu_death_order : JPEyerokHandDeathOrder;
  jp_pu_objects_ahead_of_freed_hand : nat;
  jp_pu_stale_destination_allocation : nat;
  jp_pu_suppressed_area2_macros : nat;
  jp_pu_spindel_allocation : nat;
  jp_pu_spindel_behavior_address : Z;
  jp_pu_spindel_behavior_words : list Z;
  jp_pu_spindel_position_bits : Z * Z * Z;
  jp_pu_spindel_velocity_bits : Z * Z * Z;
  jp_pu_spindel_face_angle : Z * Z * Z;
  jp_pu_spindel_angle_velocity : Z * Z * Z
}.

(** First-hand death leaves 51 hand-death spawns, the boss, and the sibling
    hand ahead of the freed cell.  Ten suppressed Area-2 macro allocations
    make Spindel allocation 54. *)
Definition jp_pu_first_hand_spindel_receipt : JPEyerokPUSpindelReceipt := {|
  jp_pu_death_order := JPEyerokFirstHandDeath;
  jp_pu_objects_ahead_of_freed_hand := 53;
  jp_pu_stale_destination_allocation := 54;
  jp_pu_suppressed_area2_macros := 10;
  jp_pu_spindel_allocation := 54;
  jp_pu_spindel_behavior_address := 2148449792; (* 0x800ebe00 *)
  jp_pu_spindel_behavior_words := [589824; 285278225; 704643072];
  jp_pu_spindel_position_bits :=
    (3306790912, 1157886994, 3300007936);
  jp_pu_spindel_velocity_bits := (0, 0, 1084227584);
  jp_pu_spindel_face_angle := (256, 0, 0);
  jp_pu_spindel_angle_velocity := (256, 0, 0)
|}.

(** Last-hand death has no sibling ahead of the freed cell.  Eleven
    suppressed Area-2 macro allocations make Spindel allocation 53. *)
Definition jp_pu_last_hand_spindel_receipt : JPEyerokPUSpindelReceipt := {|
  jp_pu_death_order := JPEyerokLastHandDeath;
  jp_pu_objects_ahead_of_freed_hand := 52;
  jp_pu_stale_destination_allocation := 53;
  jp_pu_suppressed_area2_macros := 11;
  jp_pu_spindel_allocation := 53;
  jp_pu_spindel_behavior_address := 2148449792; (* 0x800ebe00 *)
  jp_pu_spindel_behavior_words := [589824; 285278225; 704643072];
  jp_pu_spindel_position_bits :=
    (3306790912, 1157886994, 3300007936);
  jp_pu_spindel_velocity_bits := (0, 0, 1084227584);
  jp_pu_spindel_face_angle := (256, 0, 0);
  jp_pu_spindel_angle_velocity := (256, 0, 0)
|}.

Definition jp_pu_spindel_receipts : list JPEyerokPUSpindelReceipt :=
  [jp_pu_first_hand_spindel_receipt; jp_pu_last_hand_spindel_receipt].

Definition jp_spindel_generated_command_words : list Z :=
  firstn 3 (init_int32_unsigned_values
    (gvar_init jp_behavior_data.v_bhvSpindel)).

Theorem jp_spindel_generated_command_words_are_exact :
  jp_spindel_generated_command_words =
    [589824; 285278225; 704643072].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_pu_spindel_receipts_align_with_the_stale_ordinals :
  Forall (fun receipt =>
    jp_pu_stale_destination_allocation receipt =
      S (jp_pu_objects_ahead_of_freed_hand receipt) /\
    jp_pu_spindel_allocation receipt =
      jp_pu_stale_destination_allocation receipt /\
    (jp_pu_suppressed_area2_macros receipt +
      jp_pu_spindel_allocation receipt)%nat = 64%nat)
    jp_pu_spindel_receipts.
Proof. repeat constructor; repeat split; reflexivity. Qed.

Theorem jp_pu_spindel_receipts_have_one_exact_nonzero_payload :
  Forall (fun receipt =>
    jp_pu_spindel_behavior_address receipt = 2148449792 /\
    jp_pu_spindel_behavior_words receipt =
      jp_spindel_generated_command_words /\
    jp_pu_spindel_position_bits receipt =
      (3306790912, 1157886994, 3300007936) /\
    jp_pu_spindel_velocity_bits receipt = (0, 0, 1084227584) /\
    jp_pu_spindel_face_angle receipt = (256, 0, 0) /\
    jp_pu_spindel_angle_velocity receipt = (256, 0, 0))
    jp_pu_spindel_receipts.
Proof.
  rewrite jp_spindel_generated_command_words_are_exact.
  repeat constructor; repeat split; reflexivity.
Qed.

(** * Exact first Spindel displacement on the star-altitude alias *)

Definition jp_pu_sine_table_float (index : nat) : float32 :=
  match nth_error (gvar_init JPEPU_JPMath.v_gSineTable) index with
  | Some (Init_float32 value) => value
  | _ => Float32.of_bits Int.zero
  end.

Definition jp_pu_identity_matrix : F32LinearMatrix :=
  f32_rotate_zxy_from_trig
    (jp_pu_sine_table_float 0) (jp_pu_sine_table_float 1024)
    (jp_pu_sine_table_float 0) (jp_pu_sine_table_float 1024)
    (jp_pu_sine_table_float 0) (jp_pu_sine_table_float 1024).

Definition jp_pu_spindel_pitch256_matrix : F32LinearMatrix :=
  f32_rotate_zxy_from_trig
    (jp_pu_sine_table_float 16) (jp_pu_sine_table_float 1040)
    (jp_pu_sine_table_float 0) (jp_pu_sine_table_float 1024)
    (jp_pu_sine_table_float 0) (jp_pu_sine_table_float 1024).

Definition jp_pu_spindel_pivot : F32Vec3 := {|
  f32_x := Float32.of_bits (Int.repr 3306790912);
  f32_y := Float32.of_bits (Int.repr 1157886994);
  f32_z := Float32.of_bits (Int.repr 3300007936)
|}.

Definition jp_pu_area2_first_apply_input : F32Vec3 := {|
  f32_x := f32_of_Z 0;
  f32_y := jp_pu_four_period_entry_y;
  f32_z := f32_of_Z jp_pu_area3_warp_z
|}.

Definition jp_pu_area2_first_apply_velocity_adjusted : F32Vec3 := {|
  f32_x := f32_x jp_pu_area2_first_apply_input;
  f32_y := f32_y jp_pu_area2_first_apply_input;
  f32_z := Float32.add
    (f32_z jp_pu_area2_first_apply_input) (f32_of_Z 5)
|}.

Definition jp_pu_spindel_first_displaced_state : F32Vec3 :=
  let offset := f32_vec_sub
    jp_pu_area2_first_apply_velocity_adjusted jp_pu_spindel_pivot in
  let relative := f32_linear_transpose_mul jp_pu_identity_matrix offset in
  let new_offset := f32_linear_mul jp_pu_spindel_pitch256_matrix relative in
  f32_vec_add jp_pu_spindel_pivot new_offset.

Theorem jp_pu_spindel_first_displacement_is_exact :
  Float32.to_bits (f32_x jp_pu_spindel_first_displaced_state) =
      Int.repr 0 /\
  Float32.to_bits (f32_y jp_pu_spindel_first_displaced_state) =
      Int.repr 1168011561 /\
  Float32.to_bits (f32_z jp_pu_spindel_first_displaced_state) =
      Int.repr 1260390489 /\
  Float32.to_int (f32_x jp_pu_spindel_first_displaced_state) =
      Some Int.zero /\
  Float32.to_int (f32_y jp_pu_spindel_first_displaced_state) =
      Some (Int.repr 5070) /\
  Float32.to_int (f32_z jp_pu_spindel_first_displaced_state) =
      Some (Int.repr 10487897).
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The result is [5070.145f] vertically: inside the unscaled star's
    [5050,5100] vertical interval.  Its Z coordinate is still a remote
    [10487897.0f], whose signed-16 collision projection is [2137].  Thus the
    first apply supplies the requested large lever arm but does not itself
    reanchor Mario to the Act-3 star at [(500,5050,-500)]. *)
Theorem jp_pu_spindel_first_displacement_reaches_star_altitude_only :
  5050 <= 5070 <= 5100 /\
  Int.sign_ext 16 (Int.repr 10487897) = Int.repr 2137 /\
  signed16 10487897 = 2137 /\
  117 <= Z.abs (0 - 500) /\
  117 <= Z.abs (10487897 - (-500)).
Proof.
  split; [lia |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split.
  - change (117 <= 500). lia.
  - change (117 <= 10488397). lia.
Qed.

(** The retained-floor target also has its own Z-only PU continuation.  It
    starts at the exact Pedro floor Y=[608] and uses three negative Z periods,
    so unlike the four-Y witness the same raw sample can pass the platform
    tolerance test.  Spindel's first apply raises it to [5425.355957f].  That
    is above the Act-3 star rather than an immediate collection, but it is a
    concrete nonzero lever-arm result from the retained-floor geometry. *)
Definition jp_pu_ceiling_pedro_apply_input : F32Vec3 := {|
  f32_x := f32_of_Z 0;
  f32_y := f32_of_Z jp_pu_ceiling_pedro_floor_y;
  f32_z := f32_of_Z jp_pu_ceiling_pedro_raw_z
|}.

Definition jp_pu_ceiling_pedro_apply_velocity_adjusted : F32Vec3 := {|
  f32_x := f32_x jp_pu_ceiling_pedro_apply_input;
  f32_y := f32_y jp_pu_ceiling_pedro_apply_input;
  f32_z := Float32.add
    (f32_z jp_pu_ceiling_pedro_apply_input) (f32_of_Z 5)
|}.

Definition jp_pu_ceiling_pedro_spindel_result : F32Vec3 :=
  let offset := f32_vec_sub
    jp_pu_ceiling_pedro_apply_velocity_adjusted jp_pu_spindel_pivot in
  let relative := f32_linear_transpose_mul jp_pu_identity_matrix offset in
  let new_offset := f32_linear_mul jp_pu_spindel_pitch256_matrix relative in
  f32_vec_add jp_pu_spindel_pivot new_offset.

Definition jp_pu_warp_standing_spindel_input : F32Vec3 := {|
  f32_x := f32_of_Z 0;
  f32_y := jp_pu_warp_standing_closed_top_y;
  f32_z := f32_of_Z jp_pu_ceiling_pedro_raw_z
|}.

Definition jp_pu_warp_standing_spindel_velocity_adjusted : F32Vec3 := {|
  f32_x := f32_x jp_pu_warp_standing_spindel_input;
  f32_y := f32_y jp_pu_warp_standing_spindel_input;
  f32_z := Float32.add
    (f32_z jp_pu_warp_standing_spindel_input) (f32_of_Z 5)
|}.

Definition jp_pu_warp_standing_spindel_result : F32Vec3 :=
  let offset := f32_vec_sub
    jp_pu_warp_standing_spindel_velocity_adjusted jp_pu_spindel_pivot in
  let relative := f32_linear_transpose_mul jp_pu_identity_matrix offset in
  let new_offset := f32_linear_mul jp_pu_spindel_pitch256_matrix relative in
  f32_vec_add jp_pu_spindel_pivot new_offset.

Theorem jp_pu_warp_standing_spindel_displacement_is_exact :
  Float32.to_bits (f32_x jp_pu_warp_standing_spindel_result) = Int.zero /\
  Float32.to_bits (f32_y jp_pu_warp_standing_spindel_result) =
    Int.repr 1168829283 /\
  Float32.to_bits (f32_z jp_pu_warp_standing_spindel_result) =
    Int.repr 3359706093 /\
  Float32.to_int (f32_y jp_pu_warp_standing_spindel_result) =
    Some (Int.repr 5469) /\
  Float32.to_int (f32_z jp_pu_warp_standing_spindel_result) =
    Some (Int.repr (-197679)) /\
  signed16 (-197679) = -1071 /\
  5100 < 5469.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** A hand left at the ordinary warp copy cannot be freshly loaded while
    Mario is already three negative Z periods away: the raw Z separation alone
    is 196608, whereas an ordinary object's collision distance is 1000.  A live
    construction must therefore move the hand into Mario's PU or transport
    Mario after the surface has been loaded (including any valid retained-
    partition scheduling mechanism). *)
Definition jp_pu_ordinary_warp_hand_z : Z := -1100.
Definition jp_pu_default_collision_distance : Z := 1000.

Theorem jp_pu_ordinary_hand_and_pu_mario_cannot_be_a_fresh_proximity_load :
  Z.abs (jp_pu_ceiling_pedro_raw_z - jp_pu_ordinary_warp_hand_z) = 196608 /\
  ~ Z.abs (jp_pu_ceiling_pedro_raw_z - jp_pu_ordinary_warp_hand_z) <
      jp_pu_default_collision_distance.
Proof.
  vm_compute.
  split; try reflexivity.
  discriminate.
Qed.

(** * Closing the surface-availability alternatives

    The complete Area-3 static mesh is confined to one small Z interval.  The
    extra 459 units below are deliberately conservative: they grant a second
    hand every possible yaw-zero-independent horizontal offset of the first
    hand's collision mesh.  Thus [-4413,204] is wider than the stock static
    support and wider than the one-hand-on-another dynamic-support case. *)
Definition jp_pu_area3_static_z_min : Z := -3954.
Definition jp_pu_area3_static_z_max : Z := -255.
Definition jp_pu_stock_hand_support_z_min : Z :=
  jp_pu_area3_static_z_min - ordinary_hand_mesh_z_offset_max.
Definition jp_pu_stock_hand_support_z_max : Z :=
  jp_pu_area3_static_z_max + ordinary_hand_mesh_z_offset_max.

Definition jp_pu_vertex_z_between
    (lower upper : Z) (vertex : Z * Z * Z) : Prop :=
  let '(_, _, z) := vertex in lower <= z <= upper.

Theorem jp_pu_area3_static_vertices_have_exact_ordinary_z_envelope :
  Forall (jp_pu_vertex_z_between
    jp_pu_area3_static_z_min jp_pu_area3_static_z_max)
    jp_area3_collision_vertices.
Proof.
  vm_compute;
  repeat match goal with
  | |- Forall _ [] => apply Forall_nil
  | |- Forall _ (_ :: _) => apply Forall_cons
  end;
  easy.
Qed.

Definition jp_pu_stock_hand_stays_in_local_support (hand_z : Z) : Prop :=
  jp_pu_stock_hand_support_z_min <= hand_z <=
    jp_pu_stock_hand_support_z_max.

Theorem jp_pu_stock_hand_support_envelope_is_exact :
  jp_pu_stock_hand_support_z_min = -4413 /\
  jp_pu_stock_hand_support_z_max = 204.
Proof. vm_compute. split; reflexivity. Qed.

(** Once the source audit has supplied the stock support invariant, no hand
    in that envelope can be close enough to load collision for the selected
    three-period Mario sample.  A positive same-PU-hand construction must
    therefore exhibit the first source step which breaks that invariant. *)
Theorem jp_pu_stock_supported_hand_cannot_load_at_selected_pu :
  forall hand_z,
    jp_pu_stock_hand_stays_in_local_support hand_z ->
    jp_pu_default_collision_distance <=
      Z.abs (jp_pu_ceiling_pedro_raw_z - hand_z).
Proof.
  unfold jp_pu_stock_hand_stays_in_local_support,
    jp_pu_stock_hand_support_z_min, jp_pu_stock_hand_support_z_max,
    jp_pu_area3_static_z_min, jp_pu_area3_static_z_max,
    ordinary_hand_mesh_z_offset_max, jp_pu_default_collision_distance,
    jp_pu_ceiling_pedro_raw_z, jp_pu_ceiling_pedro_z_periods.
  intros hand_z Hrange.
  rewrite Z.abs_neq by lia.
  lia.
Qed.

(** In a normal frame the surface is loaded before Mario updates.  Even if a
    prior platform contributes 50 units in the helpful direction, moving from
    the strict 1000-unit load neighborhood to the selected PU in that same
    frame forces Mario's own raw Z contribution to be at most [-195559]. *)
Definition jp_pu_near_ordinary_hand_z (mario_z : Z) : Prop :=
  Z.abs (mario_z - jp_pu_ordinary_warp_hand_z) <
    jp_pu_default_collision_distance.

Definition jp_pu_platform_z_delta_bounded (delta_z : Z) : Prop :=
  Z.abs delta_z <= 50.

Theorem jp_pu_fresh_load_then_transport_requires_huge_mario_z_step :
  forall before_z platform_delta mario_delta,
    jp_pu_near_ordinary_hand_z before_z ->
    jp_pu_platform_z_delta_bounded platform_delta ->
    before_z + platform_delta + mario_delta =
      jp_pu_ceiling_pedro_raw_z ->
    mario_delta <= -195559 /\ 195559 <= Z.abs mario_delta.
Proof.
  unfold jp_pu_near_ordinary_hand_z,
    jp_pu_platform_z_delta_bounded, jp_pu_ordinary_warp_hand_z,
    jp_pu_default_collision_distance,
    jp_pu_ceiling_pedro_raw_z, jp_pu_ceiling_pedro_z_periods.
  intros before_z platform_delta mario_delta Hnear Hplatform Heq.
  apply Z.abs_lt in Hnear.
  apply Z.abs_le in Hplatform.
  assert (Hnegative : mario_delta < 0) by lia.
  split; [lia |].
  rewrite Z.abs_neq by lia.
  lia.
Qed.

(** Time stop can retain an already-built dynamic partition, but it does not
    make the empty space between signed-16 copies into floor.  Granting the
    same conservative support envelope, the first negative-period copy ends
    at [-65332], leaving a raw 60919-unit open interval.  Any sequence whose
    collision-relevant endpoints always lie in one supported copy must cross
    that interval in one horizontal step. *)
Definition jp_pu_first_negative_support_z_min : Z :=
  jp_pu_stock_hand_support_z_min - 65536.
Definition jp_pu_first_negative_support_z_max : Z :=
  jp_pu_stock_hand_support_z_max - 65536.
Definition jp_pu_first_period_open_gap : Z :=
  jp_pu_stock_hand_support_z_min - jp_pu_first_negative_support_z_max.

Theorem jp_pu_retained_surface_first_period_gap_is_exact :
  jp_pu_first_negative_support_z_min = -69949 /\
  jp_pu_first_negative_support_z_max = -65332 /\
  jp_pu_first_period_open_gap = 60919.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_pu_crossing_between_supported_periods_requires_60919_step :
  forall before_z after_z,
    jp_pu_stock_hand_stays_in_local_support before_z ->
    jp_pu_first_negative_support_z_min <= after_z <=
      jp_pu_first_negative_support_z_max ->
    60919 <= Z.abs (after_z - before_z).
Proof.
  unfold jp_pu_first_negative_support_z_min,
    jp_pu_first_negative_support_z_max,
    jp_pu_stock_hand_stays_in_local_support,
    jp_pu_stock_hand_support_z_min, jp_pu_stock_hand_support_z_max,
    jp_pu_area3_static_z_min, jp_pu_area3_static_z_max,
    ordinary_hand_mesh_z_offset_max.
  intros before_z after_z Hbefore Hafter.
  rewrite Z.abs_neq by lia.
  lia.
Qed.

(** The apparent unfixed-dialog escape is eliminated by Eyerok's lifecycle,
    before any airborne-distance bound is needed.  The source audit establishes
    that Area 3 has exactly two Eyerok dialog callsites.  At the intro both
    hands are still pre-fight at their spawn/home Z [-3393], whose deliberately
    coarse collision envelope ends at [-2934], well behind the warp.  At the
    death dialog no live hand remains: the hand death animation lasts 40 frames
    and the boss does not ask for dialog until timer 60. *)
Inductive JPEyerokStockDialogWindow : Type :=
| JPEyerokIntroDialog
| JPEyerokDeathDialog.

Definition jp_pu_dialog_live_hand_pivot_z
    (window : JPEyerokStockDialogWindow) : option Z :=
  match window with
  | JPEyerokIntroDialog => Some known_pedro_hand_pivot_z
  | JPEyerokDeathDialog => None
  end.

Definition jp_pu_dialog_can_retain_hand_over_warp
    (window : JPEyerokStockDialogWindow) : Prop :=
  exists pivot_z,
    jp_pu_dialog_live_hand_pivot_z window = Some pivot_z /\
    area3_warp_1d_z_min <= pivot_z + ordinary_hand_mesh_z_offset_max.

Theorem jp_pu_no_stock_dialog_window_can_retain_a_warp_hand :
  forall window, ~ jp_pu_dialog_can_retain_hand_over_warp window.
Proof.
  intros [|]; unfold jp_pu_dialog_can_retain_hand_over_warp,
    jp_pu_dialog_live_hand_pivot_z.
  - intros [pivot_z [Hpivot Hreach]].
    inversion Hpivot; subst pivot_z.
    unfold known_pedro_hand_pivot_z, area3_warp_1d_z_min,
      ordinary_hand_mesh_z_offset_max in Hreach.
    lia.
  - intros [pivot_z [Hpivot _]].
    discriminate.
Qed.

Definition jp_pu_hand_die_animation_frames : Z := 40.
Definition jp_pu_boss_death_dialog_timer : Z := 60.

Theorem jp_pu_hands_finish_dying_before_the_death_dialog :
  jp_pu_hand_die_animation_frames < jp_pu_boss_death_dialog_timer.
Proof. vm_compute. reflexivity. Qed.

(** * Legitimate Area-2 allocation suppression inventory

    The injected allocation census needed ten or eleven omitted macro
    allocations.  The initializer itself contains fifteen individual yellow
    coins.  Unlike the injection, these are ordinary collectible objects with
    per-record respawn storage; reachability of a chosen ten/eleven-coin
    controller trajectory remains a separate execution obligation. *)
Definition jp_pu_area2_yellow_coin_1_records : list (list Z) :=
  records_with_tag 31
    (gvar_init jp_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs).

Definition jp_pu_area2_yellow_coin_2_records : list (list Z) :=
  records_with_tag 32
    (gvar_init jp_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs).

Definition jp_pu_area2_individual_coin_records : list (list Z) :=
  jp_pu_area2_yellow_coin_1_records ++
  jp_pu_area2_yellow_coin_2_records.

Theorem jp_pu_area2_individual_coin_records_are_exact :
  jp_pu_area2_yellow_coin_1_records =
    [[31; 736; 2652; -2250; 0];
     [31; 736; 2546; -2250; 0];
     [31; 1368; 3263; -2250; 0];
     [31; 1368; 3135; -2250; 0];
     [31; -260; 2950; -600; 0];
     [31; 260; 1977; -600; 0];
     [31; -1940; 1239; -600; 0];
     [31; -1940; 1239; 2320; 0];
     [31; 260; 3923; -600; 0]] /\
  jp_pu_area2_yellow_coin_2_records =
    [[32; 1873; 0; -3495; 0];
     [32; 1200; 0; -3495; 0];
     [32; -2047; 1664; 3076; 0];
     [32; -2047; 1536; 2870; 0];
     [32; -1840; 1357; 3076; 0];
     [32; -1840; 1408; 2870; 0]].
Proof. vm_compute. split; reflexivity. Qed.

Definition jp_pu_ten_coin_suppression_candidate : list (list Z) :=
  firstn 10 jp_pu_area2_individual_coin_records.
Definition jp_pu_eleven_coin_suppression_candidate : list (list Z) :=
  firstn 11 jp_pu_area2_individual_coin_records.

Theorem jp_pu_area2_has_enough_individual_coins_for_both_ordinals :
  length jp_pu_area2_individual_coin_records = 15%nat /\
  length jp_pu_ten_coin_suppression_candidate = 10%nat /\
  length jp_pu_eleven_coin_suppression_candidate = 11%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Raw-coordinate continuation obstruction *)
Definition jp_pu_spindel_result_z_int : Z := -197679.
Definition jp_pu_act3_star_z : Z := -500.
Definition jp_pu_area2_warp_object_zs : list Z := [6451; 256; 2900; -2647].

Theorem jp_pu_spindel_result_is_not_raw_close_to_star_or_area2_warps :
  Z.abs (jp_pu_spindel_result_z_int - jp_pu_act3_star_z) = 197179 /\
  Forall (fun target_z =>
    1000 < Z.abs (jp_pu_spindel_result_z_int - target_z))
    jp_pu_area2_warp_object_zs.
Proof.
  unfold jp_pu_spindel_result_z_int, jp_pu_act3_star_z,
    jp_pu_area2_warp_object_zs.
  split.
  - rewrite Z.abs_neq by lia. lia.
  - apply Forall_cons.
    + rewrite Z.abs_neq by lia. lia.
    + apply Forall_cons.
      * rewrite Z.abs_neq by lia. lia.
      * apply Forall_cons.
        -- rewrite Z.abs_neq by lia. lia.
        -- apply Forall_cons.
           ++ rewrite Z.abs_neq by lia. lia.
           ++ apply Forall_nil.
Qed.

Definition jp_pu_zero_displacement_instant_warp_z (raw_z : Z) : Z := raw_z.

Theorem jp_pu_zero_displacement_instant_warp_does_not_reanchor :
  jp_pu_zero_displacement_instant_warp_z jp_pu_spindel_result_z_int =
    jp_pu_spindel_result_z_int /\
  Z.abs
    (jp_pu_zero_displacement_instant_warp_z jp_pu_spindel_result_z_int -
      jp_pu_act3_star_z) = 197179.
Proof. vm_compute. split; reflexivity. Qed.

Theorem jp_pu_ceiling_pedro_spindel_displacement_is_exact :
  signed16 jp_pu_ceiling_pedro_raw_z = -1100 /\
  Float32.to_bits (f32_x jp_pu_ceiling_pedro_spindel_result) = Int.zero /\
  Float32.to_bits (f32_y jp_pu_ceiling_pedro_spindel_result) =
    Int.repr 1168739033 /\
  Float32.to_bits (f32_z jp_pu_ceiling_pedro_spindel_result) =
    Int.repr 3359706162 /\
  Float32.to_int (f32_y jp_pu_ceiling_pedro_spindel_result) =
    Some (Int.repr 5425) /\
  Float32.to_int (f32_z jp_pu_ceiling_pedro_spindel_result) =
    Some (Int.repr (-197680)) /\
  5100 < 5425.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The four requested arithmetic/identity gates are now jointly checked.
    The retention field is intentionally a conditional source-shaped branch,
    not a claim that a controller-reachable execution has entered it. *)
Record JPEyerokPUConditionalFourGateCertificate : Prop := {
  jp_pu_gate_signed16_match :
    signed16 jp_pu_ceiling_pedro_raw_z = -1100;
  jp_pu_gate_retained_floor_geometry :
    jp_pu_floor_after_landing CachedWarp1D (CachedHandFloor EyerokRight)
      jp_pu_warp_standing_closed_top_y_int jp_pu_ceiling_y = CachedWarp1D;
  jp_pu_gate_nonzero_payload :
    Forall (fun receipt =>
      jp_pu_spindel_velocity_bits receipt = (0, 0, 1084227584) /\
      jp_pu_spindel_angle_velocity receipt = (256, 0, 0))
      jp_pu_spindel_receipts;
  jp_pu_gate_lever_arm :
    Float32.to_bits (f32_y jp_pu_warp_standing_spindel_result) =
      Int.repr 1168829283 /\
    Float32.to_int (f32_y jp_pu_warp_standing_spindel_result) =
      Some (Int.repr 5469)
}.

Theorem jp_pu_conditional_four_gate_certificate_holds :
  JPEyerokPUConditionalFourGateCertificate.
Proof.
  constructor.
  - vm_compute. reflexivity.
  - vm_compute. reflexivity.
  - repeat constructor; repeat split; reflexivity.
  - pose proof jp_pu_warp_standing_spindel_displacement_is_exact as Hexact.
    split.
    + exact (proj1 (proj2 Hexact)).
    + exact (proj1 (proj2 (proj2 (proj2 Hexact)))).
Qed.

(** These are only the finite conditional setup targets represented in this
    file.  The source/arithmetical closure above disproves their stock clean PU
    installation; the death/unload, coin, and Act-3 fields are retained so a
    future explicit lifecycle or machine-level premise can reuse the checked
    arithmetic without mistaking it for a controller-reachable trace. *)
Definition JPEyerokStaleHandPUFormalizedSetupTargets : Type :=
  (JPEyerokPURetainedFloorTarget + JPEyerokPUCeilingPedroTarget) *
  { controller_reached_suppression_count : nat |
      controller_reached_suppression_count = 10%nat \/
      controller_reached_suppression_count = 11%nat }.

Print Assumptions jp_pu_star_band_point_has_exact_warp_query_alias.
Print Assumptions jp_pu_z_periods_preserve_only_the_warp_local_sample.
Print Assumptions jp_pu_four_y_period_sample_cannot_install_a_signed16_floor.
Print Assumptions jp_pu_four_y_period_sample_fails_the_exact_recorded_floor_test.
Print Assumptions jp_pu_active_hand_mesh_y_ranges_are_exact.
Print Assumptions jp_pu_active_hand_own_mesh_spans_exceed_pedro_cutoff.
Print Assumptions jp_pu_known_pedro_geometry_cannot_also_cover_the_warp.
Print Assumptions jp_pu_area3_ceiling_768_vertices_are_exact.
Print Assumptions jp_pu_area3_lower_warp_ceiling_vertices_are_exact.
Print Assumptions jp_pu_area3_ceiling_triangle_commands_are_exact.
Print Assumptions jp_pu_static_ceiling_triangle_contains_the_warp_sample.
Print Assumptions jp_pu_static_ceiling_triangle_has_negative_y_orientation.
Print Assumptions jp_pu_closed_hand_lower_boundary_has_exact_retention_geometry.
Print Assumptions jp_pu_closed_hand_pedro_pivot_band_is_exact.
Print Assumptions jp_pu_warp_standing_closed_top_is_an_exact_pedro_pair.
Print Assumptions jp_pu_warp_standing_ceiling_buffer_choices_are_exact.
Print Assumptions jp_pu_spindel_receipts_align_with_the_stale_ordinals.
Print Assumptions jp_pu_spindel_receipts_have_one_exact_nonzero_payload.
Print Assumptions jp_pu_spindel_first_displacement_is_exact.
Print Assumptions jp_pu_spindel_first_displacement_reaches_star_altitude_only.
Print Assumptions jp_pu_ceiling_pedro_spindel_displacement_is_exact.
Print Assumptions jp_pu_warp_standing_spindel_displacement_is_exact.
Print Assumptions jp_pu_ordinary_hand_and_pu_mario_cannot_be_a_fresh_proximity_load.
Print Assumptions jp_pu_area3_static_vertices_have_exact_ordinary_z_envelope.
Print Assumptions jp_pu_stock_hand_support_envelope_is_exact.
Print Assumptions jp_pu_stock_supported_hand_cannot_load_at_selected_pu.
Print Assumptions jp_pu_fresh_load_then_transport_requires_huge_mario_z_step.
Print Assumptions jp_pu_retained_surface_first_period_gap_is_exact.
Print Assumptions jp_pu_crossing_between_supported_periods_requires_60919_step.
Print Assumptions jp_pu_no_stock_dialog_window_can_retain_a_warp_hand.
Print Assumptions jp_pu_hands_finish_dying_before_the_death_dialog.
Print Assumptions jp_pu_area2_individual_coin_records_are_exact.
Print Assumptions jp_pu_area2_has_enough_individual_coins_for_both_ordinals.
Print Assumptions jp_pu_spindel_result_is_not_raw_close_to_star_or_area2_warps.
Print Assumptions jp_pu_zero_displacement_instant_warp_does_not_reanchor.
Print Assumptions jp_pu_conditional_four_gate_certificate_holds.
