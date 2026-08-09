(** A checked static candidate for the long-jump-landing quicksand split.

    This module records one especially simple boundary in the generated SSL
    Area-1 collision stream.  It proves exact initializer receipts for both
    selected versions and checks the elementary projected-triangle and height
    arithmetic at two sample points:

      pre  = (5760, 0, 4856), on a default floor;
      post = (5760, ?, 4900), over shallow moving quicksand.

    The samples are 44 units apart in Z.  The quicksand plane at the post
    sample has height -300/37, a drop of less than 100 units from the default
    floor.  These are static-data and rational-arithmetic facts only.  In
    particular, projected membership does not execute [find_floor], resolve
    walls or ceilings, reproduce four binary32 quarter steps, establish a
    clean zero-A long-jump action, or connect the resulting depth to a stock
    no-exit star.  Named predicate schemas at the end keep those live-execution
    bridges explicit and unproved. *)

From Coq Require Import Bool List QArith ZArith Lia.
From compcert Require Import AST.
From LessThanOneAPress.Generated Require Import
  us_ssl_collision jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

(** * Receipts from the generated collision initializer *)

Definition a1ljq_us_words : list Z :=
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision).

Definition a1ljq_jp_words : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision).

Definition a1ljq_slice
    (offset count : nat) (words : list Z) : list Z :=
  firstn count (skipn offset words).

(** The collision stream begins with [COL_INIT; vertex_count], hence vertex
    [i] begins at word [2 + 3*i]. *)
Definition a1ljq_vertex_words
    (index : nat) (words : list Z) : list Z :=
  a1ljq_slice (2 + 3 * index)%nat 3 words.

(** Offsets 1724 and 2652 are group headers in the generated int16 stream.
    Surface 0 is [SURFACE_DEFAULT]; surface 37 (0x25) is
    [SURFACE_SHALLOW_MOVING_QUICKSAND].  The latter group stores four words
    per special triangle: three vertex indices followed by the force value. *)
Definition a1ljq_crossing_data_receipt (words : list Z) : Prop :=
  a1ljq_vertex_words 61 words = [5376; -50; 5086] /\
  a1ljq_vertex_words 120 words = [6272; 0; 4864] /\
  a1ljq_vertex_words 125 words = [5248; 0; 4864] /\
  a1ljq_vertex_words 473 words = [6656; 0; 4608] /\
  a1ljq_slice 1724 2 words = [0; 111] /\
  a1ljq_slice 1987 3 words = [120; 473; 125] /\
  a1ljq_slice 2652 2 words = [37; 60] /\
  a1ljq_slice 2822 4 words = [120; 125; 61; 0].

Theorem a1ljq_crossing_data_exact_us :
  a1ljq_crossing_data_receipt a1ljq_us_words.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem a1ljq_crossing_data_exact_jp :
  a1ljq_crossing_data_receipt a1ljq_jp_words.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem a1ljq_crossing_data_is_version_identical :
  a1ljq_slice 1724 1102 a1ljq_us_words =
    a1ljq_slice 1724 1102 a1ljq_jp_words.
Proof. vm_compute. reflexivity. Qed.

(** * Transparent projected-triangle model *)

Record A1LJQPoint : Type := {
  a1ljq_x : Z;
  a1ljq_y : Z;
  a1ljq_z : Z
}.

Definition a1ljq_v61 : A1LJQPoint :=
  {| a1ljq_x := 5376; a1ljq_y := -50; a1ljq_z := 5086 |}.
Definition a1ljq_v120 : A1LJQPoint :=
  {| a1ljq_x := 6272; a1ljq_y := 0; a1ljq_z := 4864 |}.
Definition a1ljq_v125 : A1LJQPoint :=
  {| a1ljq_x := 5248; a1ljq_y := 0; a1ljq_z := 4864 |}.
Definition a1ljq_v473 : A1LJQPoint :=
  {| a1ljq_x := 6656; a1ljq_y := 0; a1ljq_z := 4608 |}.

Definition a1ljq_pre_sample : A1LJQPoint :=
  {| a1ljq_x := 5760; a1ljq_y := 0; a1ljq_z := 4856 |}.
Definition a1ljq_post_sample : A1LJQPoint :=
  {| a1ljq_x := 5760; a1ljq_y := 0; a1ljq_z := 4900 |}.

Definition a1ljq_cross_xz
    (a b p : A1LJQPoint) : Z :=
  (a1ljq_x b - a1ljq_x a) * (a1ljq_z p - a1ljq_z a) -
  (a1ljq_z b - a1ljq_z a) * (a1ljq_x p - a1ljq_x a).

Definition a1ljq_all_nonnegative (a b c : Z) : bool :=
  Z.leb 0 a && Z.leb 0 b && Z.leb 0 c.

Definition a1ljq_all_nonpositive (a b c : Z) : bool :=
  Z.leb a 0 && Z.leb b 0 && Z.leb c 0.

(** Inclusive membership in the triangle's XZ projection.  This is not the
    engine's surface-list search or maximum-height selection rule. *)
Definition a1ljq_inside_xz
    (a b c p : A1LJQPoint) : bool :=
  let ab := a1ljq_cross_xz a b p in
  let bc := a1ljq_cross_xz b c p in
  let ca := a1ljq_cross_xz c a p in
  a1ljq_all_nonnegative ab bc ca ||
  a1ljq_all_nonpositive ab bc ca.

Definition a1ljq_default_projection_contains (p : A1LJQPoint) : bool :=
  a1ljq_inside_xz a1ljq_v120 a1ljq_v473 a1ljq_v125 p.

Definition a1ljq_shallow_projection_contains (p : A1LJQPoint) : bool :=
  a1ljq_inside_xz a1ljq_v120 a1ljq_v125 a1ljq_v61 p.

Theorem a1ljq_pre_sample_projection_classified :
  a1ljq_default_projection_contains a1ljq_pre_sample = true /\
  a1ljq_shallow_projection_contains a1ljq_pre_sample = false.
Proof. vm_compute. split; reflexivity. Qed.

Theorem a1ljq_post_sample_projection_classified :
  a1ljq_default_projection_contains a1ljq_post_sample = false /\
  a1ljq_shallow_projection_contains a1ljq_post_sample = true.
Proof. vm_compute. split; reflexivity. Qed.

(** The shallow triangle has a horizontal y=0 edge at z=4864 and its third
    vertex is y=-50 at z=5086.  Its plane height is independent of X. *)
Definition a1ljq_shallow_height_at_z (z : Z) : Q :=
  ((-50) * inject_Z (z - 4864) / 222)%Q.

Theorem a1ljq_shallow_height_interpolates_checked_vertices :
  a1ljq_shallow_height_at_z 4864 == 0 /\
  a1ljq_shallow_height_at_z 5086 == -50.
Proof. vm_compute. split; reflexivity. Qed.

Theorem a1ljq_sample_heights_exact :
  (0 : Q) == 0 /\
  a1ljq_shallow_height_at_z (a1ljq_z a1ljq_post_sample) ==
    (-300 / 37)%Q.
Proof. vm_compute. split; reflexivity. Qed.

Theorem a1ljq_horizontal_delta_is_44 :
  a1ljq_x a1ljq_post_sample - a1ljq_x a1ljq_pre_sample = 0 /\
  a1ljq_z a1ljq_post_sample - a1ljq_z a1ljq_pre_sample = 44.
Proof. vm_compute. split; reflexivity. Qed.

(** [perform_ground_quarter_step] uses a 100.0f separation test before
    returning [GROUND_STEP_LEFT_GROUND].  This theorem proves only the exact
    rational comparison for the two static planes, not the binary32 branch. *)
Theorem a1ljq_vertical_drop_is_below_100 :
  ((0 : Q) - a1ljq_shallow_height_at_z
      (a1ljq_z a1ljq_post_sample) < 100)%Q.
Proof. vm_compute. reflexivity. Qed.

(** * Explicit live-execution bridges *)

Inductive A1LJQRetailVersion : Type :=
| A1LJQVersionUS
| A1LJQVersionJP.

(** [linked_find_floor_selects version x y z surface triangle] must mean an
    execution of the real linked surface-list code in live retail memory. *)
Definition Area1CrossingFindFloorSelectionObligation
    (version : A1LJQRetailVersion)
    (linked_find_floor_selects :
      A1LJQRetailVersion -> Z -> Z -> Z -> Z -> list Z -> Prop) : Prop :=
  linked_find_floor_selects version 5760 0 4856 0 [120; 473; 125] /\
  linked_find_floor_selects version 5760 0 4900 37 [120; 125; 61].

(** The predicate must cover the four real binary32 quarter steps, both wall
    queries per quarter, floor/ceiling selection, and the final non-cancelling
    ground-step result.  Timer is the postincrement landing-body timer. *)
Definition Area1FourQuarterBinary32GroundStepReachabilityObligation
    (version : A1LJQRetailVersion)
    (linked_four_quarter_ground_step :
      A1LJQRetailVersion -> Z -> Z -> Z -> Z -> Z -> Prop) : Prop :=
  linked_four_quarter_ground_step version 4 5760 4856 5760 4900 \/
  linked_four_quarter_ground_step version 5 5760 4856 5760 4900.

(** This predicate must be derived from a clean entry and the actual action
    transition history; an already-active long-jump landing state is not by
    itself a provenance proof. *)
Definition Area1LongJumpNoAProvenanceObligation
    (version : A1LJQRetailVersion)
    (clean_zero_a_reaches_landing_body_timer :
      A1LJQRetailVersion -> Z -> Prop) : Prop :=
  clean_zero_a_reaches_landing_body_timer version 4 \/
  clean_zero_a_reaches_landing_body_timer version 5.

(** The bridge predicate must identify a stock, active, tangible no-exit star;
    prove no cached contact before the crossing and contact on the following
    collision pass; select [ACT_STAR_DANCE_NO_EXIT] before any ordinary depth
    updater; cross a star-count milestone; and enter
    [ACT_READING_AUTOMATIC_DIALOG] without an A edge. *)
Definition Area1NoExitStarAutomaticDialogBridgeObligation
    (version : A1LJQRetailVersion)
    (stock_no_exit_star_bridge :
      A1LJQRetailVersion -> Z -> Z -> Z -> Prop) : Prop :=
  stock_no_exit_star_bridge version 4 5760 4900 \/
  stock_no_exit_star_bridge version 5 5760 4900.

(** These schemas are intentionally sensitive to their linked-execution
    interpretations.  Static arithmetic cannot close them. *)
Theorem a1ljq_live_execution_schemas_are_not_static_facts :
  (forall version,
    Area1CrossingFindFloorSelectionObligation version
      (fun _ _ _ _ _ _ => True)) /\
  (forall version,
    Area1FourQuarterBinary32GroundStepReachabilityObligation version
      (fun _ _ _ _ _ _ => True)) /\
  (forall version,
    Area1LongJumpNoAProvenanceObligation version
      (fun _ _ => True)) /\
  (forall version,
    Area1NoExitStarAutomaticDialogBridgeObligation version
      (fun _ _ _ _ => True)) /\
  ~ Area1FourQuarterBinary32GroundStepReachabilityObligation
      A1LJQVersionJP (fun _ _ _ _ _ _ => False) /\
  ~ Area1NoExitStarAutomaticDialogBridgeObligation
      A1LJQVersionJP (fun _ _ _ _ => False).
Proof.
  unfold Area1CrossingFindFloorSelectionObligation,
    Area1FourQuarterBinary32GroundStepReachabilityObligation,
    Area1LongJumpNoAProvenanceObligation,
    Area1NoExitStarAutomaticDialogBridgeObligation.
  repeat split; intros; cbn; tauto.
Qed.
