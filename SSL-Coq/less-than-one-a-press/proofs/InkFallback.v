(** Ink's graphical-position fallback proposal.

    The source contains a real scheduling primitive:

    - object collision observes MarioObject before Mario's behavior update;
    - geometry first observes MarioState;
    - a failed first floor query copies header.gfx.pos into MarioState;
    - interaction processing can then consume the already cached warp;
    - ACT_DISAPPEARED snaps to the retry floor; and
    - the later state-to-object copy and platform query observe that snap.

    This file proves a source-shape receipt and the coordinate arithmetic for a
    handwritten conditional pipeline, including local and Parallel-Universe
    graphical samples.  It does not execute that control flow in Clight, claim
    that a clean retail execution can construct the required pre-existing
    MarioObject/header.gfx.pos split, or prove that the live floor lists produce
    the posited miss/top outcomes. *)

From Coq Require Import List ZArith Lia.
From compcert Require Import
  AST Clight Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  GameTypes ClightFacts CollisionMeshFacts PyramidTopPU PyramidTopSurface
  Area1PlatformExhaustiveness ClightRefinement FirstTargetRefinement.

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
  selected_ink_area1_surface_receipts area1_collision_words_us /\
  selected_ink_area1_surface_receipts area1_collision_words_jp /\
  3174 + 2 + 48 * 3 = 3320 /\
  48 + 10 = 58 /\
  3628 + 2 + 55 * 3 = 3795 /\
  55 < 288 /\
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
  split; [exact selected_ink_area1_surface_receipts_exact_us |].
  split; [exact selected_ink_area1_surface_receipts_exact_jp |].
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

(** The three generated Area-1 water boxes are kept explicit so the
    route-specific dry bound is not inferred from a picture.  The exact
    21-word water-box tail is part of [ink_geometry_kernel]. *)
Definition inside_water_box_xz
    (position : PositionZ)
    (min_x min_z max_x max_z : Z) : Prop :=
  min_x <= position_x position <= max_x /\
  min_z <= position_z position <= max_z.

Definition inside_checked_area1_water_box
    (position : PositionZ) : Prop :=
  inside_water_box_xz position 1024 (-7065) 7578 (-716) \/
  inside_water_box_xz position (-3993) (-7065) 1024 (-4197) \/
  inside_water_box_xz position (-6911) (-7167) (-4223) (-4607).

Theorem upper_warp_center_is_outside_checked_area1_water_boxes :
  ~ inside_checked_area1_water_box upper_warp_center.
Proof.
  unfold inside_checked_area1_water_box, inside_water_box_xz,
    upper_warp_center, upper_warp_x, upper_warp_y, upper_warp_z.
  cbn. lia.
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
    (retry_selects_loaded_top_surface : PositionZ -> Z -> Prop) : Prop :=
  first_query_returns_none ink_warp_floor_miss_position /\
  (retry_selects_loaded_top_surface ink_local_top_graphics_position 1791 \/
   retry_selects_loaded_top_surface pu_top_floor_candidate 1791).

(** This legacy interface is a predicate schema, not a closed retail
    proposition.  The following theorem makes that limitation executable:
    unconstrained interpretations can make it either true or false.  A future
    replacement must quantify over concrete [find_floor] call segments and
    live list memory, as the sink and lifecycle interfaces attempt to do. *)
Theorem ink_surface_refinement_schema_is_predicate_sensitive :
  InkFallbackSurfaceRefinementObligation
    (fun _ => True) (fun _ _ => True) /\
  ~ InkFallbackSurfaceRefinementObligation
      (fun _ => False) (fun _ _ => False).
Proof.
  unfold InkFallbackSurfaceRefinementObligation.
  split.
  - intuition.
  - intros (Hfalse & _). exact Hfalse.
Qed.

(** The delayed-warp cell is modeled as a first-writer latch.  [InkFatalWarp]
    abstracts either the requested death operation or the game-over operation
    to which [level_trigger_warp] rewrites it at zero lives.  The generated-AST
    facts below are pinned structural anchors for the retry-null call and the
    source order; they do not yet refine a concrete multi-frame Clight run to
    this tiny transition system or prove that its initial cell is empty. *)
Inductive InkDelayedWarpOperation : Type :=
| InkFatalWarp
| InkUpperObjectWarp.

Definition ink_request_delayed_warp
    (pending : option InkDelayedWarpOperation)
    (requested : InkDelayedWarpOperation) :
    option InkDelayedWarpOperation :=
  match pending with
  | None => Some requested
  | Some existing => Some existing
  end.

Theorem ink_delayed_warp_request_is_first_writer :
  forall existing requested,
    ink_request_delayed_warp (Some existing) requested = Some existing.
Proof. reflexivity. Qed.

Theorem ink_retry_null_fatal_latch_blocks_later_upper_request :
  ink_request_delayed_warp
    (ink_request_delayed_warp None InkFatalWarp)
    InkUpperObjectWarp =
  Some InkFatalWarp.
Proof. reflexivity. Qed.

(** This equation assumes an empty latch; a successful graphical retry does
    not by itself establish that premise. *)
Theorem ink_empty_latch_accepts_upper_request :
  ink_request_delayed_warp None InkUpperObjectWarp =
  Some InkUpperObjectWarp.
Proof. reflexivity. Qed.

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

(** [execute_mario_action] unconditionally calls
    [sink_mario_in_quicksand] after the disappeared action and before
    [copy_mario_state_to_object].  The real function writes binary32
    [marioObj->header.gfx.pos[1]] and, when non-null, also
    the row-3/column-1 entry of [marioObj->header.gfx.throwMatrix].  This projected integer phase
    marker records only the first Graphics-position write.  A zero value is
    used by the concrete coordinate witnesses below.  Proving that value and
    the normal non-aliasing provenance of [throwMatrix] in live memory remain
    part of action/state and sink-memory refinement. *)
Definition modeled_graphics_sink_only
    (sink_depth : Z) (views : MarioThreeView) : MarioThreeView := {|
  three_state_position := three_state_position views;
  three_object_position := three_object_position views;
  three_graphics_position :=
    position_with_y
      (three_graphics_position views)
      (position_y (three_graphics_position views) - sink_depth)
|}.

Definition ink_conditional_pipeline
    (floor_y sink_depth : Z) (views : MarioThreeView) : MarioThreeView :=
  copy_state_to_object
    (modeled_graphics_sink_only sink_depth
      (disappeared_snap_to_floor floor_y
        (copy_graphics_to_state views))).

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

(** Closed arithmetic for the two direct riding-shell graphical-Y additions
    found in the pinned source.  The US/JP source-shape kernel separately pins
    the corresponding binary32 literals in the named air and ground helpers. *)
Definition riding_shell_air_graphics_y_offset : Z := 42.
Definition riding_shell_ground_graphics_y_offset : Z := 45.

Theorem shell_graphics_y_offsets_fit_dry_audit_bound :
  riding_shell_air_graphics_y_offset = 42 /\
  riding_shell_ground_graphics_y_offset = 45 /\
  riding_shell_air_graphics_y_offset <= 45 /\
  riding_shell_ground_graphics_y_offset <= 45.
Proof.
  unfold riding_shell_air_graphics_y_offset,
    riding_shell_ground_graphics_y_offset.
  repeat split; lia.
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
    the update adds [0.25f] and the landing path subtracts [4.0f], producing
    the exact negative-depth operand [-2.6500000953674316f].  The final
    definition below checks the subtraction from a zero Graphics base, yielding
    [+2.6500000953674316f].  The actual binary32 delta at another Graphics Y is
    base-dependent and is left to the writer-range refinement.

    These equations check only the exact CompCert binary32 arithmetic.  The
    In the normal action graph the prepared action requires a prior A-edge
    setup.  Static upper-warp support cannot generate this adjustment, but a
    previously negative depth may persist into the disappeared-action frame;
    clean no-A action/state closure remains part of the writer refinement
    obligation. *)
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

(** Within [MarioThreeView], the projected quicksand sink changes Graphics
    only.  Consequently its modeled value cannot change the raw Object
    coordinate copied from snapped State.  This does not prove the omitted
    [throwMatrix] store is disjoint in Clight memory, nor that later object-list
    updates and unloading preserve the sample through the final query. *)
Theorem modeled_graphics_sink_does_not_change_pipeline_object :
  forall floor_y sink_depth views,
    three_object_position
      (ink_conditional_pipeline floor_y sink_depth views) =
    position_with_y (three_graphics_position views) floor_y.
Proof. reflexivity. Qed.

(** A coordinate witness for the handwritten conditional pipeline.  The
    separate source-shape theorem shows that the relevant retry branch exists,
    while [InkFallbackSurfaceRefinementObligation] records the missing Clight
    facts that the first query returns NULL and the retry selects a loaded
    top-owned surface.  The inherited predicate name
    [live_top_platform_capture] expresses only the capture geometry; it does
    not assert that the owning object remains active.
    This theorem therefore refutes an arithmetic/update-order-only objection;
    it is not a Clight control-flow execution. *)
Theorem ink_local_conditional_pipeline_coordinate_witness :
  InkFallbackReady ink_local_conditional_prestate 1791 /\
  three_state_position ink_local_conditional_prestate =
    ink_warp_floor_miss_position /\
  three_object_position (ink_conditional_pipeline 1791 0
    ink_local_conditional_prestate) = ink_local_top_graphics_position /\
  three_graphics_position (ink_conditional_pipeline 1791 0
    ink_local_conditional_prestate) = ink_local_top_graphics_position /\
  live_top_platform_capture
    (three_object_position
      (ink_conditional_pipeline 1791 0
        ink_local_conditional_prestate)) 1791 /\
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
      modeled_graphics_sink_only,
      disappeared_snap_to_floor, copy_graphics_to_state, position_with_y.
    cbn.
    split; [reflexivity |].
    split; [reflexivity |].
    split.
    + exact ink_local_top_is_a_capture_sample.
    + exact ink_local_top_alias_floor_arithmetic.
Qed.

Theorem ink_pu_conditional_pipeline_coordinate_witness :
  InkFallbackReady ink_pu_conditional_prestate 1791 /\
  three_state_position ink_pu_conditional_prestate =
    ink_warp_floor_miss_position /\
  three_object_position
    (ink_conditional_pipeline 1791 0 ink_pu_conditional_prestate) =
      pu_top_floor_candidate /\
  three_graphics_position
    (ink_conditional_pipeline 1791 0 ink_pu_conditional_prestate) =
      pu_top_floor_candidate /\
  live_top_platform_capture
    (three_object_position
      (ink_conditional_pipeline 1791 0 ink_pu_conditional_prestate)) 1791 /\
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
      modeled_graphics_sink_only,
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
    samples needed by one of the two conditional coordinate witnesses. *)
Definition Area1InkPrestateReachabilityObligation
    (reachable_clean_no_a_area1 : MarioThreeView -> Prop) : Prop :=
  exists views,
    reachable_clean_no_a_area1 views /\
    three_state_position views = ink_warp_floor_miss_position /\
    upper_warp_contact (three_object_position views) /\
    (three_graphics_position views = ink_local_top_graphics_position \/
     three_graphics_position views = pu_top_floor_candidate).

(** Like the surface schema above, this proposition cannot decide retail
    reachability until its predicate is tied to a clean linked execution. *)
Theorem area1_ink_prestate_schema_is_predicate_sensitive :
  Area1InkPrestateReachabilityObligation
    (fun views => views = ink_local_conditional_prestate) /\
  ~ Area1InkPrestateReachabilityObligation (fun _ => False).
Proof.
  split.
  - exists ink_local_conditional_prestate.
    unfold ink_local_conditional_prestate.
    cbn.
    split; [reflexivity |].
    split; [reflexivity |].
    split.
    + unfold upper_warp_contact, horizontal_distance_squared,
        upper_warp_center, upper_warp_radius, mario_hitbox_radius,
        upper_warp_y, upper_warp_height, mario_hitbox_height.
      cbn. repeat split; lia.
    + left. reflexivity.
  - intros (views & Hfalse & _). exact Hfalse.
Qed.

(** Either proposed local/PU graphics sample is at Y=1791.  Any collision
    Object still overlapping the upper warp is at most Y=818, so the exact
    reachability schema needs a Graphics-minus-Object gap of at least 973
    units.  This is stronger than the more general 385-unit
    [InkFallbackReady] lower bound. *)
Theorem area1_ink_prestate_requires_at_least_973_graphics_y_gap :
  forall views,
    three_state_position views = ink_warp_floor_miss_position ->
    upper_warp_contact (three_object_position views) ->
    (three_graphics_position views = ink_local_top_graphics_position \/
     three_graphics_position views = pu_top_floor_candidate) ->
    972 <
      position_y (three_graphics_position views) -
      position_y (three_object_position views).
Proof.
  intros views _ (_ & Hobject_upper & _) Hgraphics.
  change (position_y (three_object_position views) <= 818)
    in Hobject_upper.
  destruct Hgraphics as [Hgraphics | Hgraphics].
  - rewrite Hgraphics.
    change (972 < 1791 - position_y (three_object_position views)).
    lia.
  - rewrite Hgraphics.
    change (972 < 1791 - position_y (three_object_position views)).
    lia.
Qed.

(** The source census can be connected without baking the target region into
    an oracle.  A retail transition is covered when it is either State-only,
    an exact object/graphics synchronization, or a graphics-specific writer
    whose positive Graphics-minus-Object Y offset is at most the modeled audit
    target below.

    [208] is deliberately not presented as a derived source bound.  The source
    audit motivates it because a water-pitch offset at most 60 and an s16-only
    swimming bob below 148 can compose across the water-step floor branch.
    [Area1InkWriterCoverageObligation] must still prove that every reachable
    retail writer refines to this relation.  The upper warp is outside the
    checked water boxes, where the route-specific audit target is 45. *)
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

(** The writer interface is likewise a schema until [retail_position_step] is
    a concrete Clight-derived relation.  [True] admits the exact high-Graphics
    transition that the audited relation rejects. *)
Definition ink_synchronized_upper_warp_views : MarioThreeView := {|
  three_state_position := upper_warp_center;
  three_object_position := upper_warp_center;
  three_graphics_position := upper_warp_center
|}.

Lemma ink_high_graphics_transition_is_not_an_audited_writer :
  ~ AuditedArea1PositionWriterStep
      ink_synchronized_upper_warp_views ink_local_conditional_prestate.
Proof.
  intros Hwriter.
  inversion Hwriter; subst;
    unfold ink_synchronized_upper_warp_views,
      ink_local_conditional_prestate, ink_local_top_graphics_position,
      ink_warp_floor_miss_position, upper_warp_center, upper_warp_x,
      upper_warp_y, upper_warp_z, audited_graphics_y_gap_bound in *;
    cbn in *;
    try lia;
    discriminate.
Qed.

Theorem area1_ink_writer_coverage_schema_is_predicate_sensitive :
  Area1InkWriterCoverageObligation AuditedArea1PositionWriterStep /\
  ~ Area1InkWriterCoverageObligation (fun _ _ => True).
Proof.
  split.
  - intros before after Hstep. exact Hstep.
  - intros Hcoverage.
    apply ink_high_graphics_transition_is_not_an_audited_writer.
    apply Hcoverage. exact I.
Qed.

Definition Area1InkWriterExecutionCoverage
    (entry : MarioThreeView)
    (reachable_clean_no_a_area1 : MarioThreeView -> Prop) : Prop :=
  forall views,
    reachable_clean_no_a_area1 views ->
    AuditedArea1WriterExecution entry views.

(** This is the useful direction of the reachability question.  Entry
    synchronization and complete writer-execution coverage refute the exact
    Ink prestate schema; the retail work is now isolated to deriving those
    two premises from the linked US/JP execution. *)
Theorem audited_writer_coverage_refutes_area1_ink_prestate :
  forall entry reachable_clean_no_a_area1,
    graphics_y_gap_is_audited entry ->
    Area1InkWriterExecutionCoverage
      entry reachable_clean_no_a_area1 ->
    ~ Area1InkPrestateReachabilityObligation
        reachable_clean_no_a_area1.
Proof.
  intros entry reachable Hentry Hcoverage
    (views & Hreachable & Hstate & Hcontact & Hgraphics).
  pose proof
    (Hcoverage views Hreachable) as Hexecution.
  pose proof
    (audited_area1_writer_execution_preserves_graphics_y_gap
      entry views Hentry Hexecution) as Hbounded.
  pose proof
    (area1_ink_prestate_requires_at_least_973_graphics_y_gap
      views Hstate Hcontact Hgraphics) as Hrequired.
  unfold graphics_y_gap_is_audited,
    audited_graphics_y_gap_bound in Hbounded.
  lia.
Qed.

(** * Concrete memory boundaries for the two remaining scheduling gaps *)

Definition ink_address_offset
    (base : Ptrofs.int) (delta : Z) : Z :=
  Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr delta)).

Definition ink_load_single
    (memory : Mem.mem) (block : Values.block)
    (base : Ptrofs.int) (delta : Z) (value : float32) : Prop :=
  Mem.load AST.Mfloat32 memory block (ink_address_offset base delta) =
    Some (Values.Vsingle value).

Definition ink_load_pointer
    (memory : Mem.mem) (block : Values.block)
    (base : Ptrofs.int) (delta : Z) (value : Values.val) : Prop :=
  Mem.load AST.Mptr memory block (ink_address_offset base delta) =
    Some value.

Definition ink_load_vec3f
    (memory : Mem.mem) (block : Values.block)
    (base : Ptrofs.int) (delta : Z) (position : Vec3f) : Prop :=
  ink_load_single memory block base delta (vec_x position) /\
  ink_load_single memory block base (delta + 4) (vec_y position) /\
  ink_load_single memory block base (delta + 8) (vec_z position).

Definition ink_position_f32 (position : PositionZ) : Vec3f := {|
  vec_x := f32_of_Z (position_x position);
  vec_y := f32_of_Z (position_y position);
  vec_z := f32_of_Z (position_z position)
|}.

Definition ink_load_position
    (memory : Mem.mem) (block : Values.block)
    (base : Ptrofs.int) (delta : Z) (position : PositionZ) : Prop :=
  ink_load_vec3f memory block base delta (ink_position_f32 position).

Definition ink_subtract_depth_from_y
    (position : Vec3f) (depth : float32) : Vec3f := {|
  vec_x := vec_x position;
  vec_y := Float32.sub (vec_y position) depth;
  vec_z := vec_z position
|}.

Record InkMemorySlice : Type := {
  ink_slice_block : Values.block;
  ink_slice_start : Z;
  ink_slice_bytes : Z
}.

Definition ink_relative_slice
    (block : Values.block) (base : Ptrofs.int)
    (delta bytes : Z) : InkMemorySlice := {|
  ink_slice_block := block;
  ink_slice_start := ink_address_offset base delta;
  ink_slice_bytes := bytes
|}.

Definition ink_slices_disjoint
    (left right : InkMemorySlice) : Prop :=
  ink_slice_block left <> ink_slice_block right \/
  ink_slice_start left + ink_slice_bytes left <= ink_slice_start right \/
  ink_slice_start right + ink_slice_bytes right <= ink_slice_start left.

(** Counterexample to using linear aggregate intervals for modular pointers.
    On 32-bit CompCert pointers, the Graphics aggregate begins four bytes
    before the modulus and wraps.  The matrix cell begins at zero.  The
    existing predicate declares the two aggregates disjoint even though
    Graphics Y and matrix[3][1] are the same concrete address. *)
Definition ink_wrap_counterexample_block : Values.block := 1%positive.
Definition ink_wrap_object_offset : Ptrofs.int :=
  Ptrofs.repr 4294967260.
Definition ink_wrap_matrix_offset : Ptrofs.int :=
  Ptrofs.repr 4294967244.

Theorem ink_linear_slice_disjointness_misses_pointer_wrap_alias :
  ink_slices_disjoint
    (ink_relative_slice
      ink_wrap_counterexample_block ink_wrap_object_offset 32 12)
    (ink_relative_slice
      ink_wrap_counterexample_block ink_wrap_matrix_offset 52 4) /\
  ink_address_offset ink_wrap_object_offset 36 =
    ink_address_offset ink_wrap_matrix_offset 52.
Proof.
  split.
  - unfold ink_slices_disjoint, ink_relative_slice,
      ink_wrap_counterexample_block, ink_wrap_object_offset,
      ink_wrap_matrix_offset, ink_address_offset.
    cbn.
    right. right.
    change (4 <= 4294967292). lia.
  - vm_compute. reflexivity.
Qed.

Definition InkMemoryAddress : Type := Values.block * Ptrofs.int.

Definition ink_pointer_value
    (target : option InkMemoryAddress) : Values.val :=
  match target with
  | None => Values.Vnullptr
  | Some (block, offset) => Values.Vptr block offset
  end.

Definition ink_sink_function
    (version : GameVersion) : Clight.function :=
  match version with
  | VersionUS => UMI.f_sink_mario_in_quicksand
  | VersionJP => JMI.f_sink_mario_in_quicksand
  end.

Definition ink_sink_layout_slices
    (state_block : Values.block) (state_offset : Ptrofs.int)
    (object_block : Values.block) (object_offset : Ptrofs.int)
    (throw_target : option InkMemoryAddress) : list InkMemorySlice :=
  [ ink_relative_slice state_block state_offset 60 12;
    ink_relative_slice state_block state_offset 136 4;
    ink_relative_slice state_block state_offset 192 4;
    ink_relative_slice object_block object_offset 32 12;
    ink_relative_slice object_block object_offset 80 4;
    ink_relative_slice object_block object_offset 160 12 ] ++
  match throw_target with
  | None => []
  | Some (matrix_block, matrix_offset) =>
      [ink_relative_slice matrix_block matrix_offset 52 4]
  end.

(** Repaired non-aliasing inventory.  Each entry is one actual four-byte load
    or store cell after modular pointer addition rather than a linear
    aggregate.  The successful aligned [Mem.load] premises in an inhabited
    call segment establish that its listed cells are valid; the inventory
    alone does not rule out every wrapping base offset. *)
Definition ink_sink_layout_cells
    (state_block : Values.block) (state_offset : Ptrofs.int)
    (object_block : Values.block) (object_offset : Ptrofs.int)
    (throw_target : option InkMemoryAddress) : list InkMemorySlice :=
  [ ink_relative_slice state_block state_offset 60 4;
    ink_relative_slice state_block state_offset 64 4;
    ink_relative_slice state_block state_offset 68 4;
    ink_relative_slice state_block state_offset 136 4;
    ink_relative_slice state_block state_offset 192 4;
    ink_relative_slice object_block object_offset 32 4;
    ink_relative_slice object_block object_offset 36 4;
    ink_relative_slice object_block object_offset 40 4;
    ink_relative_slice object_block object_offset 80 4;
    ink_relative_slice object_block object_offset 160 4;
    ink_relative_slice object_block object_offset 164 4;
    ink_relative_slice object_block object_offset 168 4 ] ++
  match throw_target with
  | None => []
  | Some (matrix_block, matrix_offset) =>
      [ink_relative_slice matrix_block matrix_offset 52 4]
  end.

Definition ink_is_sink_return
    (continuation : Clight.cont) (state : Clight.state) : Prop :=
  exists memory,
    state = Clight.Returnstate Values.Vundef continuation memory.

(** Unlike an unrestricted [Smallstep.star], this relation stops at the first
    matching return.  In particular, it cannot resume a caller loop from that
    return and execute the sink a second time before choosing its endpoint. *)
Inductive ink_steps_to_first_sink_return
    (ge : Clight.genv) (continuation : Clight.cont) :
    Clight.state -> Events.trace -> Clight.state -> Prop :=
| InkFirstSinkReturnNow :
    forall before step_trace after,
      Clight.step2 ge before step_trace after ->
      ink_is_sink_return continuation after ->
      ink_steps_to_first_sink_return
        ge continuation before step_trace after
| InkFirstSinkReturnLater :
    forall before first_trace middle rest_trace after,
      Clight.step2 ge before first_trace middle ->
      ~ ink_is_sink_return continuation middle ->
      ink_steps_to_first_sink_return
        ge continuation middle rest_trace after ->
      ink_steps_to_first_sink_return
        ge continuation before (first_trace ++ rest_trace) after.

(** A candidate is an actual complete Clight call/return segment for the
    selected US or JP [sink_mario_in_quicksand] body.  Its premises recover the
    concrete MarioState pointer, MarioObject pointer, binary32 depth, all three
    position views, and the optional throw-matrix cell from CompCert memory.
    The original version used an unrestricted [Smallstep.star] and aggregate
    linear slices.  Those choices admitted a repeated-call trace and a
    pointer-wrap alias.  The repaired record stops at the first matching
    return and requires pairwise disjoint actual modular cells. *)
Record InkFallbackSinkCallSegment : Type := {
  ink_sink_projection : ClightObservationProjection;
  ink_sink_before : Clight.state;
  ink_sink_after : Clight.state;
  ink_sink_trace : Events.trace;
  ink_sink_continuation : Clight.cont;
  ink_sink_state_block : Values.block;
  ink_sink_state_offset : Ptrofs.int;
  ink_sink_object_block : Values.block;
  ink_sink_object_offset : Ptrofs.int;
  ink_sink_depth : float32;
  ink_sink_state_position : Vec3f;
  ink_sink_raw_object_position : Vec3f;
  ink_sink_graphics_position : Vec3f;
  ink_sink_throw_target : option InkMemoryAddress;
  ink_sink_throw_prior_value : float32;
  ink_sink_call_state :
    ink_sink_before =
      Clight.Callstate
        (Ctypes.Internal
          (ink_sink_function
            (projection_version ink_sink_projection)))
        [Values.Vptr ink_sink_state_block ink_sink_state_offset]
        ink_sink_continuation
        (clight_state_memory ink_sink_before);
  ink_sink_steps :
    ink_steps_to_first_sink_return
      (Clight.globalenv (projection_program ink_sink_projection))
      ink_sink_continuation
      ink_sink_before ink_sink_trace ink_sink_after;
  ink_sink_return_state :
    ink_sink_after =
      Clight.Returnstate Values.Vundef ink_sink_continuation
        (clight_state_memory ink_sink_after);
  ink_sink_object_pointer_before :
    ink_load_pointer
      (clight_state_memory ink_sink_before)
      ink_sink_state_block ink_sink_state_offset 136
      (Values.Vptr ink_sink_object_block ink_sink_object_offset);
  ink_sink_depth_before :
    ink_load_single
      (clight_state_memory ink_sink_before)
      ink_sink_state_block ink_sink_state_offset 192 ink_sink_depth;
  ink_sink_state_position_before :
    ink_load_vec3f
      (clight_state_memory ink_sink_before)
      ink_sink_state_block ink_sink_state_offset 60
      ink_sink_state_position;
  ink_sink_raw_object_position_before :
    ink_load_vec3f
      (clight_state_memory ink_sink_before)
      ink_sink_object_block ink_sink_object_offset 160
      ink_sink_raw_object_position;
  ink_sink_graphics_position_before :
    ink_load_vec3f
      (clight_state_memory ink_sink_before)
      ink_sink_object_block ink_sink_object_offset 32
      ink_sink_graphics_position;
  ink_sink_throw_pointer_before :
    ink_load_pointer
      (clight_state_memory ink_sink_before)
      ink_sink_object_block ink_sink_object_offset 80
      (ink_pointer_value ink_sink_throw_target);
  ink_sink_throw_cell_before :
    match ink_sink_throw_target with
    | None => True
    | Some (matrix_block, matrix_offset) =>
        ink_load_single
          (clight_state_memory ink_sink_before)
          matrix_block matrix_offset 52 ink_sink_throw_prior_value
    end;
  ink_sink_layout_disjoint :
    ForallOrdPairs ink_slices_disjoint
      (ink_sink_layout_cells
        ink_sink_state_block ink_sink_state_offset
        ink_sink_object_block ink_sink_object_offset
        ink_sink_throw_target)
}.

Definition ink_sink_write_location
    (segment : InkFallbackSinkCallSegment)
    (block : Values.block) (offset : Z) : Prop :=
  (block = ink_sink_object_block segment /\
   ink_address_offset (ink_sink_object_offset segment) 36 <= offset <
     ink_address_offset (ink_sink_object_offset segment) 36 + 4) \/
  match ink_sink_throw_target segment with
  | None => False
  | Some (matrix_block, matrix_offset) =>
      block = matrix_block /\
      ink_address_offset matrix_offset 52 <= offset <
        ink_address_offset matrix_offset 52 + 4
  end.

Definition InkFallbackSinkMemoryPostcondition
    (segment : InkFallbackSinkCallSegment) : Prop :=
  ink_load_pointer
    (clight_state_memory (ink_sink_after segment))
    (ink_sink_state_block segment) (ink_sink_state_offset segment) 136
    (Values.Vptr
      (ink_sink_object_block segment) (ink_sink_object_offset segment)) /\
  ink_load_single
    (clight_state_memory (ink_sink_after segment))
    (ink_sink_state_block segment) (ink_sink_state_offset segment) 192
    (ink_sink_depth segment) /\
  ink_load_vec3f
    (clight_state_memory (ink_sink_after segment))
    (ink_sink_state_block segment) (ink_sink_state_offset segment) 60
    (ink_sink_state_position segment) /\
  ink_load_vec3f
    (clight_state_memory (ink_sink_after segment))
    (ink_sink_object_block segment) (ink_sink_object_offset segment) 160
    (ink_sink_raw_object_position segment) /\
  ink_load_vec3f
    (clight_state_memory (ink_sink_after segment))
    (ink_sink_object_block segment) (ink_sink_object_offset segment) 32
    (ink_subtract_depth_from_y
      (ink_sink_graphics_position segment) (ink_sink_depth segment)) /\
  ink_load_pointer
    (clight_state_memory (ink_sink_after segment))
    (ink_sink_object_block segment) (ink_sink_object_offset segment) 80
    (ink_pointer_value (ink_sink_throw_target segment)) /\
  (match ink_sink_throw_target segment with
   | None => True
   | Some (matrix_block, matrix_offset) =>
       ink_load_single
         (clight_state_memory (ink_sink_after segment))
         matrix_block matrix_offset 52
         (Float32.sub
           (ink_sink_throw_prior_value segment) (ink_sink_depth segment))
   end) /\
  Mem.unchanged_on
    (fun block offset => ~ ink_sink_write_location segment block offset)
    (clight_state_memory (ink_sink_before segment))
    (clight_state_memory (ink_sink_after segment)).

(** This repaired concrete function-correctness obligation quantifies over
    first-return, modular-cell-disjoint call segments.  Every such linked
    target call segment satisfying the explicit memory-layout premises must
    have exactly the projected Graphics write and optional matrix write above.
    It remains unproved; the two concrete defects in its predecessor are
    formally recorded by [ink_linear_slice_disjointness_misses_pointer_wrap_alias]
    and the first-return relation above. *)
Definition InkFallbackSinkMemoryRefinementObligation : Prop :=
  forall segment : InkFallbackSinkCallSegment,
    InkFallbackSinkMemoryPostcondition segment.

Definition ink_platform_global_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UPD._gMarioPlatform
  | VersionJP => JPD._gMarioPlatform
  end.

Definition ink_mario_object_global_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UPD._gMarioObject
  | VersionJP => JPD._gMarioObject
  end.

Definition ink_mario_states_global_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UPD._gMarioStates
  | VersionJP => JPD._gMarioStates
  end.

Definition ink_pyramid_top_behavior_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UBD._bhvPyramidTop
  | VersionJP => JBD._bhvPyramidTop
  end.

Definition ink_pyramid_top_collision_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UBD._ssl_seg7_collision_pyramid_top
  | VersionJP => JBD._ssl_seg7_collision_pyramid_top
  end.

Definition ink_platform_floor_local_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UPD._floor
  | VersionJP => JPD._floor
  end.

Definition ink_platform_floor_result_temp_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UPD._t'1
  | VersionJP => JPD._t'1
  end.

Definition ink_platform_surface_struct_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => UPD._Surface
  | VersionJP => JPD._Surface
  end.

Definition ink_platform_surface_pointer_type
    (version : GameVersion) : Ctypes.type :=
  Ctypes.Tpointer
    (Ctypes.Tstruct
      (ink_platform_surface_struct_ident version) Ctypes.noattr)
    Ctypes.noattr.

Definition ink_copy_state_to_object_function
    (version : GameVersion) : Clight.function :=
  match version with
  | VersionUS => UOL.f_copy_mario_state_to_object
  | VersionJP => JOL.f_copy_mario_state_to_object
  end.

Definition ink_update_non_terrain_function
    (version : GameVersion) : Clight.function :=
  match version with
  | VersionUS => UOL.f_update_non_terrain_objects
  | VersionJP => JOL.f_update_non_terrain_objects
  end.

Definition ink_unload_deactivated_function
    (version : GameVersion) : Clight.function :=
  match version with
  | VersionUS => UOL.f_unload_deactivated_objects
  | VersionJP => JOL.f_unload_deactivated_objects
  end.

Definition ink_update_platform_function
    (version : GameVersion) : Clight.function :=
  match version with
  | VersionUS => UPD.f_update_mario_platform
  | VersionJP => JPD.f_update_mario_platform
  end.

Definition ink_void_call_entry
    (function : Clight.function) (continuation : Clight.cont)
    (state : Clight.state) : Prop :=
  state =
    Clight.Callstate (Ctypes.Internal function) [] continuation
      (clight_state_memory state).

Definition ink_void_call_return
    (continuation : Clight.cont) (state : Clight.state) : Prop :=
  state =
    Clight.Returnstate Values.Vundef continuation
      (clight_state_memory state).

Definition ink_linked_steps
    (projection : ClightObservationProjection)
    (before : Clight.state) (trace : Events.trace)
    (after : Clight.state) : Prop :=
  @Smallstep.star _ _ Clight.step2
    (Clight.globalenv (projection_program projection))
    before trace after.

Definition ink_pyramid_top_home_f32 : Vec3f := {|
  vec_x := f32_of_Z pyramid_top_home_x;
  vec_y := f32_of_Z pyramid_top_home_y;
  vec_z := f32_of_Z pyramid_top_home_z
|}.

(** Equal symbolic Y fields do not by themselves force the retail
    [absf(marioY - floorHeight) < 4.0f] branch.  A quiet NaN equals itself in
    Coq's meta-level equality, but the generated binary32 comparison is false.
    The lifecycle refinement therefore needs a finite coordinate bound (or an
    exact proof of this comparison) derived from concrete surface geometry. *)
Definition ink_quiet_nan : float32 :=
  Float32.of_bits (Int.repr 2143289344).

Theorem equal_binary32_samples_do_not_imply_platform_tolerance :
  ink_quiet_nan = ink_quiet_nan /\
  Float32.cmp Clt
    (Float32.abs (Float32.sub ink_quiet_nan ink_quiet_nan))
    (f32_of_Z 4) = false.
Proof. vm_compute. split; reflexivity. Qed.

Definition ink_find_floor_return_control_point
    (projection : ClightObservationProjection)
    (state : Clight.state) (floor_height : float32)
    (caller_env : Clight.env) (caller_temporaries : Clight.temp_env)
    (rest_continuation : Clight.cont) : Prop :=
  state =
    Clight.Returnstate
      (Values.Vsingle floor_height)
      (Clight.Kcall
        (Some
          (ink_platform_floor_result_temp_ident
            (projection_version projection)))
        (ink_update_platform_function (projection_version projection))
        caller_env caller_temporaries rest_continuation)
      (clight_state_memory state).

Definition ink_selected_floor_local_pointer
    (projection : ClightObservationProjection)
    (state : Clight.state) (caller_env : Clight.env)
    (floor_local_block surface_block : Values.block)
    (surface_offset : Ptrofs.int) : Prop :=
  PTree.get
    (ink_platform_floor_local_ident (projection_version projection))
    caller_env =
    Some
      (floor_local_block,
       ink_platform_surface_pointer_type (projection_version projection)) /\
  Mem.load AST.Mptr (clight_state_memory state) floor_local_block 0 =
    Some (Values.Vptr surface_block surface_offset).

(** The current projection has no primitive pointer-to-[SurfaceRef] map.
    This named proposition therefore states the exact co-observation that a
    later construction must establish: the concrete MarioState floor field
    contains the selected pointer in the same Clight state that projects to an
    abstract state whose Mario floor is the given stable surface name. *)
Definition InkSelectedSurfaceProjectionLink
    (projection : ClightObservationProjection)
    (state : Clight.state) (abstract_state : GameState)
    (mario_state_block : Values.block)
    (mario_state_offset : Ptrofs.int)
    (surface_block : Values.block) (surface_offset : Ptrofs.int)
    (surface_ref : SurfaceRef) : Prop :=
  project_state projection state = Some abstract_state /\
  ink_load_pointer
    (clight_state_memory state)
    mario_state_block mario_state_offset 104
    (Values.Vptr surface_block surface_offset) /\
  mario_floor (state_mario_kinematics abstract_state) = surface_ref.

Inductive InkTopOwnerPostCopyEpochCase
    (owner_ref : ObjectRef) (current : ObjectState) : Prop :=
| InkTopOwnerActiveAtPostCopy :
    object_ref_equal (object_ref current) owner_ref ->
    object_active current = true ->
    InkTopOwnerPostCopyEpochCase owner_ref current
| InkTopOwnerInactiveAtPostCopy :
    object_ref_equal (object_ref current) owner_ref ->
    object_active current = false ->
    InkTopOwnerPostCopyEpochCase owner_ref current.

Inductive InkTopOwnerEpochOutcome
    (owner_ref : ObjectRef) (pool : list ObjectState) : Prop :=
| InkTopOwnerStillActive :
    forall current,
      nth_error pool (object_slot owner_ref) = Some current ->
      object_ref_equal (object_ref current) owner_ref ->
      object_active current = true ->
      InkTopOwnerEpochOutcome owner_ref pool
| InkTopOwnerInactiveSameEpoch :
    forall current,
      nth_error pool (object_slot owner_ref) = Some current ->
      object_ref_equal (object_ref current) owner_ref ->
      object_active current = false ->
      InkTopOwnerEpochOutcome owner_ref pool.

(** The explicit call/return states below identify four concrete control
    points inside one imported run.  The non-terrain call encloses the
    [copy_mario_state_to_object] call; after its return, the run reaches the
    non-terrain return, then complete calls to
    [unload_deactivated_objects] and [update_mario_platform].

    The selected sample and floor height are arbitrary binary32 values.  The
    local/PU home-pose witnesses above use 1791, but an explosion-frame top has
    a later translated/rotated pose with potentially non-integral coordinates.
    Constructing this record must recover that concrete transform and selected
    surface; it may not silently reuse the home-pose floor.  The pre-unload
    allocation is pinned by exact slot/epoch, Area 1, the static top home
    coordinates, concrete [bhvPyramidTop] and collision-data symbols, and the
    loaded surface-owner pointer. *)
Record InkFallbackPostCopyLifecycleSegment : Type := {
  ink_lifecycle_projection : ClightObservationProjection;
  ink_lifecycle_run : ImportedClightRun;
  ink_lifecycle_uses_projection :
    RunUsesProjection ink_lifecycle_projection ink_lifecycle_run;
  ink_lifecycle_sample : Vec3f;
  ink_lifecycle_floor_height : float32;
  ink_lifecycle_remaining_entry : Clight.state;
  ink_lifecycle_copy_entry : Clight.state;
  ink_lifecycle_copy_return : Clight.state;
  ink_lifecycle_remaining_return : Clight.state;
  ink_lifecycle_unload_entry : Clight.state;
  ink_lifecycle_unload_return : Clight.state;
  ink_lifecycle_query_entry : Clight.state;
  ink_lifecycle_find_floor_return : Clight.state;
  ink_lifecycle_query_return : Clight.state;
  ink_lifecycle_remaining_continuation : Clight.cont;
  ink_lifecycle_copy_continuation : Clight.cont;
  ink_lifecycle_unload_continuation : Clight.cont;
  ink_lifecycle_query_continuation : Clight.cont;
  ink_lifecycle_find_floor_caller_env : Clight.env;
  ink_lifecycle_find_floor_caller_temporaries : Clight.temp_env;
  ink_lifecycle_find_floor_rest_continuation : Clight.cont;
  ink_lifecycle_floor_local_block : Values.block;
  ink_lifecycle_prefix_trace : Events.trace;
  ink_lifecycle_remaining_to_copy_trace : Events.trace;
  ink_lifecycle_copy_trace : Events.trace;
  ink_lifecycle_copy_to_remaining_return_trace : Events.trace;
  ink_lifecycle_to_unload_trace : Events.trace;
  ink_lifecycle_unload_trace : Events.trace;
  ink_lifecycle_to_query_trace : Events.trace;
  ink_lifecycle_query_to_find_floor_trace : Events.trace;
  ink_lifecycle_find_floor_to_query_return_trace : Events.trace;
  ink_lifecycle_query_trace : Events.trace;
  ink_lifecycle_suffix_trace : Events.trace;
  ink_lifecycle_prefix_steps :
    ink_linked_steps ink_lifecycle_projection
      (run_start ink_lifecycle_run) ink_lifecycle_prefix_trace
      ink_lifecycle_remaining_entry;
  ink_lifecycle_remaining_is_entry :
    ink_void_call_entry
      (ink_update_non_terrain_function
        (projection_version ink_lifecycle_projection))
      ink_lifecycle_remaining_continuation
      ink_lifecycle_remaining_entry;
  ink_lifecycle_remaining_to_copy_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_remaining_entry ink_lifecycle_remaining_to_copy_trace
      ink_lifecycle_copy_entry;
  ink_lifecycle_copy_is_entry :
    ink_void_call_entry
      (ink_copy_state_to_object_function
        (projection_version ink_lifecycle_projection))
      ink_lifecycle_copy_continuation ink_lifecycle_copy_entry;
  ink_lifecycle_copy_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_copy_entry ink_lifecycle_copy_trace
      ink_lifecycle_copy_return;
  ink_lifecycle_copy_is_return :
    ink_void_call_return
      ink_lifecycle_copy_continuation ink_lifecycle_copy_return;
  ink_lifecycle_copy_to_remaining_return_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_copy_return
      ink_lifecycle_copy_to_remaining_return_trace
      ink_lifecycle_remaining_return;
  ink_lifecycle_remaining_is_return :
    ink_void_call_return
      ink_lifecycle_remaining_continuation
      ink_lifecycle_remaining_return;
  ink_lifecycle_to_unload_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_remaining_return ink_lifecycle_to_unload_trace
      ink_lifecycle_unload_entry;
  ink_lifecycle_unload_is_entry :
    ink_void_call_entry
      (ink_unload_deactivated_function
        (projection_version ink_lifecycle_projection))
      ink_lifecycle_unload_continuation ink_lifecycle_unload_entry;
  ink_lifecycle_unload_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_unload_entry ink_lifecycle_unload_trace
      ink_lifecycle_unload_return;
  ink_lifecycle_unload_is_return :
    ink_void_call_return
      ink_lifecycle_unload_continuation ink_lifecycle_unload_return;
  ink_lifecycle_to_query_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_unload_return ink_lifecycle_to_query_trace
      ink_lifecycle_query_entry;
  ink_lifecycle_query_is_entry :
    ink_void_call_entry
      (ink_update_platform_function
        (projection_version ink_lifecycle_projection))
      ink_lifecycle_query_continuation ink_lifecycle_query_entry;
  ink_lifecycle_query_to_find_floor_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_query_entry
      ink_lifecycle_query_to_find_floor_trace
      ink_lifecycle_find_floor_return;
  ink_lifecycle_find_floor_is_return :
    ink_find_floor_return_control_point
      ink_lifecycle_projection ink_lifecycle_find_floor_return
      ink_lifecycle_floor_height
      ink_lifecycle_find_floor_caller_env
      ink_lifecycle_find_floor_caller_temporaries
      ink_lifecycle_find_floor_rest_continuation;
  ink_lifecycle_find_floor_to_query_return_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_find_floor_return
      ink_lifecycle_find_floor_to_query_return_trace
      ink_lifecycle_query_return;
  ink_lifecycle_query_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_query_entry ink_lifecycle_query_trace
      ink_lifecycle_query_return;
  ink_lifecycle_query_trace_decomposition :
    ink_lifecycle_query_trace =
      ink_lifecycle_query_to_find_floor_trace ++
      ink_lifecycle_find_floor_to_query_return_trace;
  ink_lifecycle_query_is_return :
    ink_void_call_return
      ink_lifecycle_query_continuation ink_lifecycle_query_return;
  ink_lifecycle_suffix_steps :
    ink_linked_steps ink_lifecycle_projection
      ink_lifecycle_query_return ink_lifecycle_suffix_trace
      (run_final ink_lifecycle_run);
  ink_lifecycle_trace_decomposition :
    run_trace ink_lifecycle_run =
      ink_lifecycle_prefix_trace ++
      ink_lifecycle_remaining_to_copy_trace ++
      ink_lifecycle_copy_trace ++
      ink_lifecycle_copy_to_remaining_return_trace ++
      ink_lifecycle_to_unload_trace ++
      ink_lifecycle_unload_trace ++
      ink_lifecycle_to_query_trace ++
      ink_lifecycle_query_trace ++
      ink_lifecycle_suffix_trace;
  ink_lifecycle_post_copy_game : GameState;
  ink_lifecycle_after_unload_game : GameState;
  ink_lifecycle_after_query_game : GameState;
  ink_lifecycle_post_copy_projection :
    project_state ink_lifecycle_projection ink_lifecycle_copy_return =
      Some ink_lifecycle_post_copy_game;
  ink_lifecycle_after_unload_projection :
    project_state ink_lifecycle_projection ink_lifecycle_unload_return =
      Some ink_lifecycle_after_unload_game;
  ink_lifecycle_after_query_projection :
    project_state ink_lifecycle_projection ink_lifecycle_query_return =
      Some ink_lifecycle_after_query_game;
  ink_lifecycle_mario_state_block : Values.block;
  ink_lifecycle_mario_state_offset : Ptrofs.int;
  ink_lifecycle_mario_object_global_block : Values.block;
  ink_lifecycle_mario_object_block : Values.block;
  ink_lifecycle_mario_object_offset : Ptrofs.int;
  ink_lifecycle_surface_block : Values.block;
  ink_lifecycle_surface_offset : Ptrofs.int;
  ink_lifecycle_owner_block : Values.block;
  ink_lifecycle_owner_offset : Ptrofs.int;
  ink_lifecycle_top_behavior_block : Values.block;
  ink_lifecycle_top_collision_block : Values.block;
  ink_lifecycle_surface_ref : SurfaceRef;
  ink_lifecycle_owner_ref : ObjectRef;
  ink_lifecycle_owner_before : ObjectState;
  ink_lifecycle_platform : RawPlatformPointer;
  ink_lifecycle_mario_state_symbol :
    Genv.find_symbol
      (Clight.globalenv
        (projection_program ink_lifecycle_projection))
      (ink_mario_states_global_ident
        (projection_version ink_lifecycle_projection)) =
      Some ink_lifecycle_mario_state_block;
  ink_lifecycle_mario_state_is_first :
    ink_lifecycle_mario_state_offset = Ptrofs.zero;
  ink_lifecycle_mario_state_position_at_copy :
    ink_load_vec3f
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_mario_state_block ink_lifecycle_mario_state_offset 60
      ink_lifecycle_sample;
  ink_lifecycle_mario_state_floor_at_copy :
    ink_load_pointer
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_mario_state_block ink_lifecycle_mario_state_offset 104
      (Values.Vptr ink_lifecycle_surface_block ink_lifecycle_surface_offset);
  ink_lifecycle_mario_state_floor_height_at_copy :
    ink_load_single
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_mario_state_block ink_lifecycle_mario_state_offset 112
      ink_lifecycle_floor_height;
  ink_lifecycle_mario_state_object_at_copy :
    ink_load_pointer
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_mario_state_block ink_lifecycle_mario_state_offset 136
      (Values.Vptr
        ink_lifecycle_mario_object_block ink_lifecycle_mario_object_offset);
  ink_lifecycle_raw_object_at_copy :
    ink_load_vec3f
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_mario_object_block ink_lifecycle_mario_object_offset 160
      ink_lifecycle_sample;
  ink_lifecycle_disappeared_snap_y :
    vec_y ink_lifecycle_sample = ink_lifecycle_floor_height;
  ink_lifecycle_projected_post_copy_position :
    mario_position
      (state_mario_kinematics ink_lifecycle_post_copy_game) =
      ink_lifecycle_sample;
  ink_lifecycle_selected_surface_projection_link :
    InkSelectedSurfaceProjectionLink
      ink_lifecycle_projection ink_lifecycle_copy_return
      ink_lifecycle_post_copy_game
      ink_lifecycle_mario_state_block ink_lifecycle_mario_state_offset
      ink_lifecycle_surface_block ink_lifecycle_surface_offset
      ink_lifecycle_surface_ref;
  ink_lifecycle_projected_post_copy_floor_height :
    mario_floor_height
      (state_mario_kinematics ink_lifecycle_post_copy_game) =
      ink_lifecycle_floor_height;
  ink_lifecycle_mario_object_symbol :
    Genv.find_symbol
      (Clight.globalenv
        (projection_program ink_lifecycle_projection))
      (ink_mario_object_global_ident
        (projection_version ink_lifecycle_projection)) =
      Some ink_lifecycle_mario_object_global_block;
  ink_lifecycle_query_uses_this_mario_object :
    Mem.load AST.Mptr
      (clight_state_memory ink_lifecycle_query_entry)
      ink_lifecycle_mario_object_global_block 0 =
      Some
        (Values.Vptr
          ink_lifecycle_mario_object_block ink_lifecycle_mario_object_offset);
  ink_lifecycle_selected_floor_local :
    ink_selected_floor_local_pointer
      ink_lifecycle_projection ink_lifecycle_find_floor_return
      ink_lifecycle_find_floor_caller_env ink_lifecycle_floor_local_block
      ink_lifecycle_surface_block ink_lifecycle_surface_offset;
  ink_lifecycle_surface_owner_at_copy :
    ink_load_pointer
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_surface_block ink_lifecycle_surface_offset 44
      (Values.Vptr ink_lifecycle_owner_block ink_lifecycle_owner_offset);
  ink_lifecycle_selected_surface_owner :
    ink_load_pointer
      (clight_state_memory ink_lifecycle_find_floor_return)
      ink_lifecycle_surface_block ink_lifecycle_surface_offset 44
      (Values.Vptr ink_lifecycle_owner_block ink_lifecycle_owner_offset);
  ink_lifecycle_owner_before_lookup :
    nth_error (state_object_pool ink_lifecycle_post_copy_game)
      (object_slot ink_lifecycle_owner_ref) =
      Some ink_lifecycle_owner_before;
  ink_lifecycle_owner_before_ref :
    object_ref_equal
      (object_ref ink_lifecycle_owner_before) ink_lifecycle_owner_ref;
  ink_lifecycle_owner_position_at_copy :
    ink_load_vec3f
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_owner_block ink_lifecycle_owner_offset 160
      (object_position ink_lifecycle_owner_before);
  ink_lifecycle_owner_post_copy_epoch_case :
    InkTopOwnerPostCopyEpochCase
      ink_lifecycle_owner_ref ink_lifecycle_owner_before;
  ink_lifecycle_owner_before_area :
    object_area ink_lifecycle_owner_before = ssl_area1_id;
  ink_lifecycle_owner_before_behavior :
    object_behavior ink_lifecycle_owner_before = BehaviorOther;
  ink_lifecycle_owner_before_origin :
    object_origin ink_lifecycle_owner_before = RuntimeOtherOrigin;
  ink_lifecycle_owner_before_home :
    object_home_position ink_lifecycle_owner_before =
      ink_pyramid_top_home_f32;
  ink_lifecycle_top_behavior_symbol :
    Genv.find_symbol
      (Clight.globalenv
        (projection_program ink_lifecycle_projection))
      (ink_pyramid_top_behavior_ident
        (projection_version ink_lifecycle_projection)) =
      Some ink_lifecycle_top_behavior_block;
  ink_lifecycle_owner_behavior_pointer_at_copy :
    ink_load_pointer
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_owner_block ink_lifecycle_owner_offset 524
      (Values.Vptr ink_lifecycle_top_behavior_block Ptrofs.zero);
  ink_lifecycle_top_collision_symbol :
    Genv.find_symbol
      (Clight.globalenv
        (projection_program ink_lifecycle_projection))
      (ink_pyramid_top_collision_ident
        (projection_version ink_lifecycle_projection)) =
      Some ink_lifecycle_top_collision_block;
  ink_lifecycle_owner_collision_pointer_at_copy :
    ink_load_pointer
      (clight_state_memory ink_lifecycle_copy_return)
      ink_lifecycle_owner_block ink_lifecycle_owner_offset 536
      (Values.Vptr ink_lifecycle_top_collision_block Ptrofs.zero);
  ink_lifecycle_platform_ref :
    object_ref_equal
      (captured_platform_ref ink_lifecycle_platform)
      ink_lifecycle_owner_ref
}.

Definition InkFallbackPostCopyLifecyclePostcondition
    (segment : InkFallbackPostCopyLifecycleSegment) : Prop :=
  ink_load_vec3f
    (clight_state_memory
      (ink_lifecycle_remaining_return segment))
    (ink_lifecycle_mario_object_block segment)
    (ink_lifecycle_mario_object_offset segment) 160
    (ink_lifecycle_sample segment) /\
  ink_load_vec3f
    (clight_state_memory (ink_lifecycle_unload_return segment))
    (ink_lifecycle_mario_object_block segment)
    (ink_lifecycle_mario_object_offset segment) 160
    (ink_lifecycle_sample segment) /\
  ink_load_vec3f
    (clight_state_memory (ink_lifecycle_query_return segment))
    (ink_lifecycle_mario_object_block segment)
    (ink_lifecycle_mario_object_offset segment) 160
    (ink_lifecycle_sample segment) /\
  ink_load_pointer
    (clight_state_memory (ink_lifecycle_unload_return segment))
    (ink_lifecycle_surface_block segment)
    (ink_lifecycle_surface_offset segment) 44
    (Values.Vptr
      (ink_lifecycle_owner_block segment)
      (ink_lifecycle_owner_offset segment)) /\
  ink_load_pointer
    (clight_state_memory (ink_lifecycle_query_return segment))
    (ink_lifecycle_surface_block segment)
    (ink_lifecycle_surface_offset segment) 44
    (Values.Vptr
      (ink_lifecycle_owner_block segment)
      (ink_lifecycle_owner_offset segment)) /\
  InkTopOwnerEpochOutcome
    (ink_lifecycle_owner_ref segment)
    (state_object_pool (ink_lifecycle_after_unload_game segment)) /\
  mario_floor
    (state_mario_kinematics
      (ink_lifecycle_after_query_game segment)) =
    ink_lifecycle_surface_ref segment /\
  mario_floor_height
    (state_mario_kinematics
      (ink_lifecycle_after_query_game segment)) =
    ink_lifecycle_floor_height segment /\
  state_mario_platform (ink_lifecycle_after_query_game segment) =
    Some (ink_lifecycle_platform segment) /\
  exists platform_global_block,
    Genv.find_symbol
      (Clight.globalenv
        (projection_program (ink_lifecycle_projection segment)))
      (ink_platform_global_ident
        (projection_version (ink_lifecycle_projection segment))) =
      Some platform_global_block /\
    Mem.load AST.Mptr
      (clight_state_memory (ink_lifecycle_query_return segment))
      platform_global_block 0 =
      Some
        (Values.Vptr
          (ink_lifecycle_owner_block segment)
          (ink_lifecycle_owner_offset segment)).

(** Audit status: do not try to prove this current universal statement.
    [project_state] is not yet a certified memory interpretation, the imported
    program omits the behavior-script interpreter that calls Mario's behavior,
    the subtraces are unrestricted stars, external calls lack the needed frame
    specifications, and equal arbitrary binary32 samples do not force the
    platform-tolerance branch.  Thus the statement can be unsafe under a
    hostile linked program/projection and vacuous under the exact current
    translation.  It is retained under its requested name so those defects
    remain visible while the repaired exact-link/anchored-run interface is
    built. *)
Definition InkFallbackPostCopyLifecycleRefinementObligation : Prop :=
  forall segment : InkFallbackPostCopyLifecycleSegment,
    InkFallbackPostCopyLifecyclePostcondition segment.

(** Generated-Clight syntax anchors for both versions.  This does not replace
    the small-step memory/dataflow and writer-coverage obligations above. *)
Definition InkFallbackSourceShapeKernel : Prop :=
  graphical_floor_fallback_source_shape_us_claim /\
  graphical_floor_fallback_source_shape_jp_claim /\
  shell_graphics_y_offsets_source_shape_us_claim /\
  shell_graphics_y_offsets_source_shape_jp_claim /\
  ink_retry_null_death_preemption_source_shape_us_claim /\
  ink_retry_null_death_preemption_source_shape_jp_claim /\
  mario_entry_coordinate_sync_source_shape_us_claim /\
  mario_entry_coordinate_sync_source_shape_jp_claim /\
  pyramid_top_spin_explosion_pose_source_shape_us_claim /\
  pyramid_top_spin_explosion_pose_source_shape_jp_claim /\
  ink_post_copy_lifecycle_source_shape_us_claim /\
  ink_post_copy_lifecycle_source_shape_jp_claim.

Theorem ink_fallback_source_shape_kernel_checked :
  InkFallbackSourceShapeKernel.
Proof.
  unfold InkFallbackSourceShapeKernel.
  split; [exact graphical_floor_fallback_source_shape_us |].
  split; [exact graphical_floor_fallback_source_shape_jp |].
  split; [exact shell_graphics_y_offsets_source_shape_us |].
  split; [exact shell_graphics_y_offsets_source_shape_jp |].
  split; [exact ink_retry_null_death_preemption_source_shape_us |].
  split; [exact ink_retry_null_death_preemption_source_shape_jp |].
  split; [exact mario_entry_coordinate_sync_source_shape_us |].
  split; [exact mario_entry_coordinate_sync_source_shape_jp |].
  split; [exact pyramid_top_spin_explosion_pose_source_shape_us |].
  split; [exact pyramid_top_spin_explosion_pose_source_shape_jp |].
  split; [exact ink_post_copy_lifecycle_source_shape_us |].
  exact ink_post_copy_lifecycle_source_shape_jp.
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
  - exact (proj1 ink_local_conditional_pipeline_coordinate_witness).
  - split.
    + exact (proj1 ink_pu_conditional_pipeline_coordinate_witness).
    + split; [exact ink_fallback_source_shape_kernel_checked |].
      split.
      * exact (proj1 (proj2 (proj2
          prepared_landing_quicksand_raise_arithmetic_checked))).
      * split.
        -- exact audited_graphics_y_gap_bound_is_below_ink_requirement.
        -- exact state_only_prefix_from_synchronized_sample_cannot_be_ink_ready.
Qed.
