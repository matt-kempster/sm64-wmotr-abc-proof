(** Ink's graphical-position fallback proposal.

    The source contains a real scheduling primitive:

    - object collision observes MarioObject before Mario's behavior update;
    - geometry first observes MarioState;
    - a failed first floor query copies header.gfx.pos into MarioState;
    - interaction processing can then consume the already cached warp;
    - ACT_DISAPPEARED snaps to the retry floor; and
    - the later state-to-object copy and platform query observe that snap.

    This file proves the coordinate/control-flow arithmetic for that primitive,
    including local and Parallel-Universe graphical samples.  It does not claim
    that a clean retail execution can construct the required pre-existing
    MarioObject/header.gfx.pos split, nor that the live floor lists produce the
    posited miss/top outcomes. *)

From Coq Require Import List ZArith Lia.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  ClightFacts CollisionMeshFacts PyramidTopPU PyramidTopSurface
  Area1PlatformExhaustiveness.

Import ListNotations.
Local Open Scope Z_scope.

(** * Concrete Area-1 floor-miss diagnostic *)

Definition ink_warp_floor_miss_position : PositionZ := {|
  position_x := -2200;
  position_y := 768;
  position_z := -1024
|}.

Definition ink_vertex_xz (x z : Z) : VertexXZ := {|
  vertex_x := Int.repr x;
  vertex_z := Int.repr z
|}.

Definition ink_floor_edge_values
    (query a b c : VertexXZ) : list Z :=
  map Int.signed
    [floor_edge_value query a b;
     floor_edge_value query b c;
     floor_edge_value query c a].

Definition ink_query_xz := ink_vertex_xz (-2200) (-1024).
Definition ink_vertex_265 := ink_vertex_xz (-2559) (-511).
Definition ink_vertex_266 := ink_vertex_xz (-2149) (-921).
Definition ink_vertex_372 := ink_vertex_xz (-2149) (-1125).
Definition ink_vertex_498 := ink_vertex_xz (-1945) (-921).
Definition ink_vertex_500 := ink_vertex_xz (-1945) (-1125).
Definition ink_vertex_501 := ink_vertex_xz (-2149) (-1125).
Definition ink_vertex_502 := ink_vertex_xz (-2149) (-921).

(** The two y=768 pillar triangles each reject the point on an exact signed
    edge test.  The y=1280 plateau triangle accepts it in X/Z, but the query is
    434 units below the floor-search buffer.  The nearby west wall's plane
    offset is just outside both wall-query radii.  The other three axis-aligned
    faces are farther away.

    This theorem is intentionally not called a complete [find_floor] or wall
    result: it does not execute the live static/dynamic partition lists. *)
Definition ink_geometry_kernel : Prop :=
  selected_ink_area1_vertex_receipts area1_collision_vertices_us /\
  selected_ink_area1_vertex_receipts area1_collision_vertices_jp /\
  firstn 30 (skipn 3320 area1_collision_words_us) =
    selected_ink_area1_triangle_word_slice /\
  firstn 30 (skipn 3320 area1_collision_words_jp) =
    selected_ink_area1_triangle_word_slice /\
  upper_warp_contact ink_warp_floor_miss_position /\
  ink_floor_edge_values
    ink_query_xz ink_vertex_498 ink_vertex_500 ink_vertex_501 =
      [52020; 20604; -31008] /\
  ink_floor_edge_values
    ink_query_xz ink_vertex_498 ink_vertex_501 ink_vertex_502 =
      [31008; -10404; 21012] /\
  ink_floor_edge_values
    ink_query_xz ink_vertex_265 ink_vertex_266 ink_vertex_372 =
      [63140; 10404; 10096] /\
  position_x ink_warp_floor_miss_position + 2149 = -51 /\
  position_x ink_warp_floor_miss_position + 2149 < -50 /\
  position_x ink_warp_floor_miss_position + 2149 < -24 /\
  - position_x ink_warp_floor_miss_position - 1945 = 255 /\
  position_z ink_warp_floor_miss_position + 1125 = 101 /\
  - position_z ink_warp_floor_miss_position - 921 = 103 /\
  763 <= position_y ink_warp_floor_miss_position + 60 <= 1285 /\
  763 <= position_y ink_warp_floor_miss_position + 30 <= 1285 /\
  position_y ink_warp_floor_miss_position -
    (1280 - find_floor_upward_buffer) = -434 /\
  position_y ink_warp_floor_miss_position -
    (1280 - find_floor_upward_buffer) < 0.

Theorem ink_geometry_kernel_checked :
  ink_geometry_kernel.
Proof.
  unfold ink_geometry_kernel.
  split; [exact selected_ink_area1_vertex_receipts_exact_us |].
  split; [exact selected_ink_area1_vertex_receipts_exact_jp |].
  split; [exact selected_ink_area1_triangle_words_exact_us |].
  split; [exact selected_ink_area1_triangle_words_exact_jp |].
  unfold ink_warp_floor_miss_position, ink_floor_edge_values, ink_query_xz,
    ink_vertex_265, ink_vertex_266, ink_vertex_372, ink_vertex_498,
    ink_vertex_500, ink_vertex_501, ink_vertex_502, ink_vertex_xz,
    upper_warp_contact, horizontal_distance_squared, upper_warp_center,
    upper_warp_x, upper_warp_y, upper_warp_z, upper_warp_radius,
    upper_warp_height, mario_hitbox_radius, mario_hitbox_height,
    find_floor_upward_buffer.
  vm_compute.
  repeat split; try reflexivity; try lia.
  all: discriminate.
Qed.

(** The existing fifteen-owner stock abstraction also excludes every modeled
    dynamic-floor candidate for the first query.  For the top, the 78-unit
    height guard fails; every other owner is horizontally disjoint.  This is
    stronger than the selected-triangle arithmetic but still awaits the
    linked proof that live Clight surface ownership projects into that finite
    inventory. *)
Definition stock_dynamic_geometry_floor_candidate
    (owner : Area1SurfaceOwnerKind)
    (query : PositionZ)
    (floor_y : Z) : Prop :=
  inside_horizontal_envelope (area1_owner_envelope owner) query /\
  (match owner with
   | A1PyramidTop => pyramid_top_floor_min_y <= floor_y
   | _ => True
   end) /\
  floor_query_can_return query floor_y.

Theorem ink_first_query_has_no_modeled_stock_dynamic_floor_candidate :
  forall owner floor_y,
    ~ stock_dynamic_geometry_floor_candidate
        owner ink_warp_floor_miss_position floor_y.
Proof.
  intros owner floor_y
    (Hinside & Howner_floor & Hquery).
  destruct (area1_surface_owner_eq_dec owner A1PyramidTop)
    as [Htop | Hnot_top].
  - subst owner.
    cbn in Howner_floor.
    eapply upper_warp_altitude_cannot_query_live_top_floor
      with (query := ink_warp_floor_miss_position)
           (floor_y := floor_y).
    + change (608 <= 768 <= 818). lia.
    + exact Howner_floor.
    + exact Hquery.
  - eapply non_top_owner_envelope_disjoint_from_upper_warp
      with (owner := owner)
           (position := ink_warp_floor_miss_position).
    + exact Hnot_top.
    + unfold ink_warp_floor_miss_position, upper_warp_contact,
        horizontal_distance_squared, upper_warp_center, upper_warp_radius,
        mario_hitbox_radius, upper_warp_y, upper_warp_height,
        mario_hitbox_height.
      cbn. repeat split; lia.
    + exact Hinside.
Qed.

(** * Three independently sampled coordinate views *)

Definition ink_local_top_graphics_position : PositionZ := {|
  position_x := -2048;
  position_y := 1791;
  position_z := -1024
|}.

(** The still-missing live-list fact is stated narrowly.  A future Clight
    refinement must derive these outcomes rather than postulate them. *)
Definition InkFallbackSurfaceRefinementObligation
    (first_query_returns_none : PositionZ -> Prop)
    (retry_selects_live_top : PositionZ -> Z -> Prop) : Prop :=
  first_query_returns_none ink_warp_floor_miss_position /\
  (retry_selects_live_top ink_local_top_graphics_position 1791 \/
   retry_selects_live_top pu_top_floor_candidate 1791).

Record MarioThreeView : Type := {
  three_state_position : PositionZ;
  three_object_position : PositionZ;
  three_graphics_position : PositionZ
}.

Definition write_state_only
    (next_state : PositionZ) (views : MarioThreeView) : MarioThreeView := {|
  three_state_position := next_state;
  three_object_position := three_object_position views;
  three_graphics_position := three_graphics_position views
|}.

Fixpoint write_state_only_prefix
    (positions : list PositionZ) (views : MarioThreeView) : MarioThreeView :=
  match positions with
  | [] => views
  | position :: rest =>
      write_state_only_prefix rest (write_state_only position views)
  end.

Theorem state_only_prefix_preserves_collision_and_fallback_samples :
  forall positions views,
    three_object_position (write_state_only_prefix positions views) =
      three_object_position views /\
    three_graphics_position (write_state_only_prefix positions views) =
      three_graphics_position views /\
    (upper_warp_contact
       (three_object_position (write_state_only_prefix positions views)) <->
     upper_warp_contact (three_object_position views)).
Proof.
  induction positions as [| position positions IH]; intros views.
  - cbn. intuition.
  - cbn.
    specialize (IH (write_state_only position views)).
    destruct IH as (Hobject & Hgraphics & Hwarp).
    cbn in Hobject, Hgraphics, Hwarp.
    split; [exact Hobject |].
    split; [exact Hgraphics |].
    exact Hwarp.
Qed.

Corollary state_only_prefix_cannot_create_object_graphics_split :
  forall positions views,
    three_object_position views = three_graphics_position views ->
    three_object_position (write_state_only_prefix positions views) =
      three_graphics_position (write_state_only_prefix positions views).
Proof.
  intros positions views Hsynchronized.
  pose proof
    (state_only_prefix_preserves_collision_and_fallback_samples
      positions views) as (Hobject & Hgraphics & _).
  rewrite Hobject, Hgraphics.
  exact Hsynchronized.
Qed.

(** This theorem covers both local State motion and arbitrary PU/platform
    endpoints: no magnitude or signed-16 locality premise is needed.  Such a
    writer can change MarioState, but cannot independently seed the old
    collision Object and fallback Graphics samples. *)
Theorem arbitrary_ordinary_or_pu_state_only_prefix_needs_preexisting_split :
  forall positions views,
    three_object_position views = three_graphics_position views ->
    three_object_position (write_state_only_prefix positions views) <>
      three_graphics_position (write_state_only_prefix positions views) ->
    False.
Proof.
  intros positions views Hsynchronized Hsplit.
  apply Hsplit.
  now apply state_only_prefix_cannot_create_object_graphics_split.
Qed.

(** * The exact conditional fallback schedule *)

Definition position_with_y (position : PositionZ) (new_y : Z) : PositionZ := {|
  position_x := position_x position;
  position_y := new_y;
  position_z := position_z position
|}.

Definition copy_graphics_to_state (views : MarioThreeView) : MarioThreeView := {|
  three_state_position := three_graphics_position views;
  three_object_position := three_object_position views;
  three_graphics_position := three_graphics_position views
|}.

Definition disappeared_snap_to_floor
    (floor_y : Z) (views : MarioThreeView) : MarioThreeView :=
  let snapped := position_with_y (three_state_position views) floor_y in
  {|
    three_state_position := snapped;
    three_object_position := three_object_position views;
    three_graphics_position := snapped
  |}.

Definition copy_state_to_object (views : MarioThreeView) : MarioThreeView := {|
  three_state_position := three_state_position views;
  three_object_position := three_state_position views;
  three_graphics_position := three_graphics_position views
|}.

Definition ink_conditional_pipeline
    (floor_y : Z) (views : MarioThreeView) : MarioThreeView :=
  copy_state_to_object
    (disappeared_snap_to_floor floor_y
      (copy_graphics_to_state views)).

(** These are the coordinate arithmetic properties required before the
    branch.  The graphical retry sample need only be within find_floor's
    78-unit upward allowance; ACT_DISAPPEARED performs the later exact snap.
    The predicate does not assert the first-query miss, live ownership, list
    selection, or the cached interaction bit. *)
Definition InkFallbackReady
    (views : MarioThreeView) (floor_y : Z) : Prop :=
  upper_warp_contact (three_object_position views) /\
  pyramid_top_floor_min_y <= floor_y /\
  floor_query_can_return (three_graphics_position views) floor_y.

Theorem ink_ready_requires_at_least_385_graphics_y_separation :
  forall views floor_y,
    -32768 <= position_y (three_graphics_position views) < 32768 ->
    InkFallbackReady views floor_y ->
    384 <
      position_y (three_graphics_position views) -
      position_y (three_object_position views).
Proof.
  intros views floor_y Hgraphics_range
    (Hwarp & Hfloor & Hquery).
  exact
    (upper_warp_to_live_top_query_requires_385_y_units
      (three_object_position views)
      (three_graphics_position views)
      floor_y Hwarp Hgraphics_range Hfloor Hquery).
Qed.

(** Closed arithmetic for the largest positive dry ordinary visual offset
    found in the source census: riding-shell ground rendering adds 45 units.
    A later Clight action-closure proof still has to derive the [<= 45] premise
    for every clean dry Area-1 frame. *)
Theorem dry_graphics_offset_cannot_supply_top_retry :
  forall object_position graphics_position floor_y,
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    position_y graphics_position - position_y object_position <= 45 ->
    pyramid_top_floor_min_y <= floor_y ->
    ~ floor_query_can_return graphics_position floor_y.
Proof.
  intros object_position graphics_position floor_y
    Hwarp Hgraphics_range Hoffset Hfloor Hquery.
  pose proof
    (upper_warp_to_live_top_query_requires_385_y_units
      object_position graphics_position floor_y
      Hwarp Hgraphics_range Hfloor Hquery) as Hrequired.
  lia.
Qed.

(** A precision correction to the writer census.  It would be unsound to say
    that [sink_mario_in_quicksand] always lowers Graphics.  In the source-shaped
    prepared [ACT_LONG_JUMP_LAND] case, pre-frame [actionTimer = 4] is
    incremented before the landing adjustment.  Starting from depth [1.1f],
    the update adds [0.25f], the landing path subtracts [4.0f], and the final
    Graphics subtraction therefore raises Y by about [2.65].

    These equations check only the exact CompCert binary32 arithmetic.  The
    prepared action requires a prior A-edge setup, the upper warp is not
    quicksand, and clean no-A action closure remains part of the writer
    refinement obligation. *)
Definition prepared_landing_depth_after_update : float32 :=
  Float32.add
    (Float32.of_bits (Int.repr 1066192077))  (* 1.1f *)
    (Float32.of_bits (Int.repr 1048576000)). (* 0.25f *)

Definition prepared_landing_quicksand_depth : float32 :=
  Float32.sub prepared_landing_depth_after_update
    (Float32.of_bits (Int.repr 1082130432)). (* 4.0f *)

Definition prepared_landing_graphics_y_raise : float32 :=
  Float32.sub
    (Float32.of_bits (Int.repr 0))
    prepared_landing_quicksand_depth.

Theorem prepared_landing_quicksand_raise_arithmetic_checked :
  Float32.to_bits prepared_landing_depth_after_update =
    Int.repr 1068289229 /\ (* 1.350000023841858f *)
  Float32.to_bits prepared_landing_quicksand_depth =
    Int.repr 3223951770 /\ (* -2.6500000953674316f *)
  Float32.to_bits prepared_landing_graphics_y_raise =
    Int.repr 1076468122 /\ (* 2.6500000953674316f *)
  Float32.cmp Clt prepared_landing_graphics_y_raise
    (Float32.of_bits (Int.repr 1110704128)) = true. (* 45.0f *)
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem synchronized_object_graphics_cannot_be_ink_ready :
  forall views floor_y,
    three_object_position views = three_graphics_position views ->
    ~ InkFallbackReady views floor_y.
Proof.
  intros views floor_y Hsynchronized (Hwarp & Hfloor & Hquery).
  rewrite <- Hsynchronized in Hquery.
  eapply upper_warp_altitude_cannot_query_live_top_floor.
  - exact
      (upper_warp_contact_y_bounds
        (three_object_position views) Hwarp).
  - exact Hfloor.
  - exact Hquery.
Qed.

Theorem state_only_prefix_from_synchronized_sample_cannot_be_ink_ready :
  forall positions views floor_y,
    three_object_position views = three_graphics_position views ->
    ~ InkFallbackReady (write_state_only_prefix positions views) floor_y.
Proof.
  intros positions views floor_y Hsynchronized.
  apply synchronized_object_graphics_cannot_be_ink_ready.
  now apply state_only_prefix_cannot_create_object_graphics_split.
Qed.

Theorem ink_local_top_alias_floor_arithmetic :
  pu_top_alias_floor_arithmetic ink_local_top_graphics_position 1791.
Proof.
  assert (Hquery :
    floor_query_can_return ink_local_top_graphics_position 1791).
  {
    unfold floor_query_can_return, ink_local_top_graphics_position,
      find_floor_upward_buffer.
    change (1791 - 78 <= signed16 1791).
    rewrite signed16_in_range by lia.
    lia.
  }
  pose proof pyramid_top_negative_z_edge_witness_holds as Hedge.
  unfold pyramid_top_negative_z_edge_witness in Hedge.
  destruct Hedge as (Hsource_edge & Hedge_x & Hedge_y & Hedge_z).
  unfold pyramid_top_negative_z_edge_claim in Hsource_edge.
  destruct Hsource_edge as (Hface & Hvertex_4 & Hvertex_3).
  unfold pu_top_alias_floor_arithmetic, ink_local_top_graphics_position,
    pyramid_top_home_x, pyramid_top_home_y, pyramid_top_home_z.
  repeat split; try exact Hquery; try assumption;
    try (vm_compute; reflexivity).
  all: try discriminate; try lia.
Qed.

Theorem ink_local_top_is_a_capture_sample :
  live_top_platform_capture ink_local_top_graphics_position 1791.
Proof.
  unfold live_top_platform_capture, ink_local_top_graphics_position,
    pyramid_top_floor_min_y, platform_floor_tolerance.
  cbn. lia.
Qed.

Definition ink_local_conditional_prestate : MarioThreeView := {|
  three_state_position := ink_warp_floor_miss_position;
  three_object_position := upper_warp_center;
  three_graphics_position := ink_local_top_graphics_position
|}.

Definition ink_pu_conditional_prestate : MarioThreeView := {|
  three_state_position := ink_warp_floor_miss_position;
  three_object_position := upper_warp_center;
  three_graphics_position := pu_top_floor_candidate
|}.

(** A coordinate/control-flow countermodel, conditional on the first floor
    query returning NULL and the retry selecting the live top at height 1791.
    It demonstrates that update order does not itself refute Ink's primitive. *)
Theorem ink_local_conditional_control_flow_countermodel :
  InkFallbackReady ink_local_conditional_prestate 1791 /\
  three_state_position ink_local_conditional_prestate =
    ink_warp_floor_miss_position /\
  three_object_position (ink_conditional_pipeline 1791
    ink_local_conditional_prestate) = ink_local_top_graphics_position /\
  three_graphics_position (ink_conditional_pipeline 1791
    ink_local_conditional_prestate) = ink_local_top_graphics_position /\
  live_top_platform_capture
    (three_object_position
      (ink_conditional_pipeline 1791 ink_local_conditional_prestate)) 1791 /\
  pu_top_alias_floor_arithmetic ink_local_top_graphics_position 1791.
Proof.
  unfold InkFallbackReady, ink_local_conditional_prestate.
  cbn.
  split.
  - split.
    + unfold upper_warp_contact, horizontal_distance_squared,
        upper_warp_center, upper_warp_radius, mario_hitbox_radius,
        upper_warp_y, upper_warp_height, mario_hitbox_height.
      cbn. repeat split; lia.
    + split.
      * unfold pyramid_top_floor_min_y. lia.
      * unfold floor_query_can_return, ink_local_top_graphics_position,
          find_floor_upward_buffer.
        change (1791 - 78 <= signed16 1791).
        rewrite signed16_in_range by lia.
        lia.
  - split; [reflexivity |].
    unfold ink_conditional_pipeline, copy_state_to_object,
      disappeared_snap_to_floor, copy_graphics_to_state, position_with_y.
    cbn.
    split; [reflexivity |].
    split; [reflexivity |].
    split.
    + exact ink_local_top_is_a_capture_sample.
    + exact ink_local_top_alias_floor_arithmetic.
Qed.

Theorem ink_pu_conditional_control_flow_countermodel :
  InkFallbackReady ink_pu_conditional_prestate 1791 /\
  three_state_position ink_pu_conditional_prestate =
    ink_warp_floor_miss_position /\
  three_object_position
    (ink_conditional_pipeline 1791 ink_pu_conditional_prestate) =
      pu_top_floor_candidate /\
  three_graphics_position
    (ink_conditional_pipeline 1791 ink_pu_conditional_prestate) =
      pu_top_floor_candidate /\
  live_top_platform_capture
    (three_object_position
      (ink_conditional_pipeline 1791 ink_pu_conditional_prestate)) 1791 /\
  pu_top_alias_floor_arithmetic pu_top_floor_candidate 1791.
Proof.
  unfold InkFallbackReady, ink_pu_conditional_prestate.
  cbn.
  split.
  - split.
    + unfold upper_warp_contact, horizontal_distance_squared,
        upper_warp_center, upper_warp_radius, mario_hitbox_radius,
        upper_warp_y, upper_warp_height, mario_hitbox_height.
      cbn. repeat split; lia.
    + split.
      * unfold pyramid_top_floor_min_y. lia.
      * unfold floor_query_can_return, pu_top_floor_candidate,
          find_floor_upward_buffer.
        change (1791 - 78 <= signed16 1791).
        rewrite signed16_in_range by lia.
        lia.
  - split; [reflexivity |].
    unfold ink_conditional_pipeline, copy_state_to_object,
      disappeared_snap_to_floor, copy_graphics_to_state, position_with_y.
    cbn.
    split; [reflexivity |].
    split; [reflexivity |].
    split.
    + exact pu_top_candidate_is_a_capture_sample.
    + exact pu_top_candidate_alias_floor_arithmetic.
Qed.

(** * Narrow remaining reachability/linkage obligations *)

(** This obligation asks for the missing constructor, rather than assuming it:
    a reachable clean/no-A Area-1 state must exhibit the State/Object/Graphics
    samples needed by one of the two conditional countermodels. *)
Definition Area1InkPrestateReachabilityObligation
    (reachable_clean_no_a_area1 : MarioThreeView -> Prop) : Prop :=
  exists views,
    reachable_clean_no_a_area1 views /\
    three_state_position views = ink_warp_floor_miss_position /\
    upper_warp_contact (three_object_position views) /\
    (three_graphics_position views = ink_local_top_graphics_position \/
     three_graphics_position views = pu_top_floor_candidate).

(** The source census can be connected without baking the target region into
    an oracle.  A retail transition is covered when it is either State-only,
    an exact object/graphics synchronization, or a graphics-specific writer
    whose positive Graphics-minus-Object Y offset is at most this conservative
    bound. *)
(** Conservative source/type bound: a water-pitch offset of 60 and the
    s16-only swimming-bob bound below 148 can compose across the water-step
    floor branch.  The upper warp is dry (where the exact relevant source
    maximum is 45), but using 208 here keeps the generic writer relation
    honest without relying on that action-closure fact. *)
Definition audited_graphics_y_gap_bound : Z := 208.

Theorem audited_graphics_y_gap_bound_is_below_ink_requirement :
  audited_graphics_y_gap_bound < 385.
Proof. unfold audited_graphics_y_gap_bound; lia. Qed.

Inductive AuditedArea1PositionWriterStep :
    MarioThreeView -> MarioThreeView -> Prop :=
| AuditedStateOnlyWriter :
    forall before next_state,
      AuditedArea1PositionWriterStep
        before (write_state_only next_state before)
| AuditedSynchronizedWriter :
    forall before position,
      AuditedArea1PositionWriterStep before {|
        three_state_position := position;
        three_object_position := position;
        three_graphics_position := position
      |}
| AuditedBoundedGraphicsWriter :
    forall before state_position object_position graphics_position,
      position_y graphics_position - position_y object_position <=
        audited_graphics_y_gap_bound ->
      AuditedArea1PositionWriterStep before {|
        three_state_position := state_position;
        three_object_position := object_position;
        three_graphics_position := graphics_position
      |}.

Inductive AuditedArea1WriterExecution :
    MarioThreeView -> MarioThreeView -> Prop :=
| AuditedArea1WriterExecutionNil :
    forall views, AuditedArea1WriterExecution views views
| AuditedArea1WriterExecutionCons :
    forall before middle after,
      AuditedArea1PositionWriterStep before middle ->
      AuditedArea1WriterExecution middle after ->
      AuditedArea1WriterExecution before after.

Definition graphics_y_gap_is_audited (views : MarioThreeView) : Prop :=
  position_y (three_graphics_position views) -
    position_y (three_object_position views) <= audited_graphics_y_gap_bound.

Lemma audited_area1_writer_step_preserves_graphics_y_gap :
  forall before after,
    graphics_y_gap_is_audited before ->
    AuditedArea1PositionWriterStep before after ->
    graphics_y_gap_is_audited after.
Proof.
  intros before after Hbefore Hstep.
  inversion Hstep; subst; unfold graphics_y_gap_is_audited in *; cbn in *.
  - exact Hbefore.
  - unfold audited_graphics_y_gap_bound. lia.
  - exact H.
Qed.

Theorem audited_area1_writer_execution_preserves_graphics_y_gap :
  forall before after,
    graphics_y_gap_is_audited before ->
    AuditedArea1WriterExecution before after ->
    graphics_y_gap_is_audited after.
Proof.
  intros before after Hbounded Hexecution.
  induction Hexecution as
    [views | before middle after Hstep Hexecution IH].
  - exact Hbounded.
  - apply IH.
    eapply audited_area1_writer_step_preserves_graphics_y_gap.
    + exact Hbounded.
    + exact Hstep.
Qed.

Theorem audited_area1_writer_execution_cannot_create_ink_ready :
  forall before after floor_y,
    graphics_y_gap_is_audited before ->
    AuditedArea1WriterExecution before after ->
    -32768 <= position_y (three_graphics_position after) < 32768 ->
    ~ InkFallbackReady after floor_y.
Proof.
  intros before after floor_y Hbefore Hexecution Hgraphics_range Hready.
  pose proof
    (audited_area1_writer_execution_preserves_graphics_y_gap
      before after Hbefore Hexecution) as Hafter.
  pose proof
    (ink_ready_requires_at_least_385_graphics_y_separation
      after floor_y Hgraphics_range Hready) as Hrequired.
  unfold graphics_y_gap_is_audited, audited_graphics_y_gap_bound in Hafter.
  lia.
Qed.

Definition Area1InkWriterCoverageObligation
    (retail_position_step : MarioThreeView -> MarioThreeView -> Prop) : Prop :=
  forall before after,
    retail_position_step before after ->
    AuditedArea1PositionWriterStep before after.

(** Generated-Clight syntax anchors for both versions.  This does not replace
    the small-step memory/dataflow and writer-coverage obligations above. *)
Definition InkFallbackSourceShapeKernel : Prop :=
  graphical_floor_fallback_source_shape_us_claim /\
  graphical_floor_fallback_source_shape_jp_claim /\
  mario_entry_coordinate_sync_source_shape_us_claim /\
  mario_entry_coordinate_sync_source_shape_jp_claim.

Theorem ink_fallback_source_shape_kernel_checked :
  InkFallbackSourceShapeKernel.
Proof.
  unfold InkFallbackSourceShapeKernel.
  split; [exact graphical_floor_fallback_source_shape_us |].
  split; [exact graphical_floor_fallback_source_shape_jp |].
  split; [exact mario_entry_coordinate_sync_source_shape_us |].
  exact mario_entry_coordinate_sync_source_shape_jp.
Qed.

(** Final audited boundary:

    - the fallback scheduling primitive is not refuted;
    - local and PU graphical samples both satisfy the conditional arithmetic;
    - arbitrary ordinary/PU State-only prefixes cannot manufacture the needed
      Object/Graphics split from synchronized input; and
    - clean retail writer coverage and live floor selection remain open. *)
Definition InkFallbackCheckedBoundary : Prop :=
  ink_geometry_kernel /\
  InkFallbackReady ink_local_conditional_prestate 1791 /\
  InkFallbackReady ink_pu_conditional_prestate 1791 /\
  InkFallbackSourceShapeKernel /\
  Float32.to_bits prepared_landing_graphics_y_raise =
    Int.repr 1076468122 /\
  audited_graphics_y_gap_bound < 385 /\
  (forall positions views floor_y,
    three_object_position views = three_graphics_position views ->
    ~ InkFallbackReady (write_state_only_prefix positions views) floor_y).

Theorem ink_fallback_checked_boundary :
  InkFallbackCheckedBoundary.
Proof.
  unfold InkFallbackCheckedBoundary.
  split; [exact ink_geometry_kernel_checked |].
  split.
  - exact (proj1 ink_local_conditional_control_flow_countermodel).
  - split.
    + exact (proj1 ink_pu_conditional_control_flow_countermodel).
    + split; [exact ink_fallback_source_shape_kernel_checked |].
      split.
      * exact (proj1 (proj2 (proj2
          prepared_landing_quicksand_raise_arithmetic_checked))).
      * split.
        -- exact audited_graphics_y_gap_bound_is_below_ink_requirement.
        -- exact state_only_prefix_from_synchronized_sample_cannot_be_ink_ready.
Qed.
