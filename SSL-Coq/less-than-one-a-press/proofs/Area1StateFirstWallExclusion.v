(** Wall-list exclusion for the nonlocal-Y State-first candidate.

    The candidate enters [update_mario_geometry_inputs] with MarioState Y
    equal to 67314.0f.  Its two wall passes sample Y + 60.0f and Y + 30.0f.
    A retail [Surface.upperY] is a signed 16-bit [TerrainData], so neither
    sample can pass the first vertical range guard of
    [find_wall_collisions_from_list].  Under the pinned source control order,
    no wall in either the dynamic or static list reaches the later X/Z push
    statements.

    This file proves the finite arithmetic, a guard-occurrence AST receipt,
    and a source-shaped traversal theorem.  It does not prove guard dominance
    or a linked Clight execution: projecting the live control order, list
    nodes, signed field loads, call arguments, and returned X/Z stores into the
    traversal remains the explicitly named refinement obligation at the end
    of the file. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Clight Floats Integers.
From LessThanOneAPress.Proofs Require Import ClightFacts PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

Definition timer131_state_first_y : float32 :=
  Float32.of_bits (Int.repr 1199798528).  (* 67314.0f *)

Definition timer131_upper_wall_offset : float32 :=
  Float32.of_bits (Int.repr 1114636288).  (* 60.0f *)

Definition timer131_lower_wall_offset : float32 :=
  Float32.of_bits (Int.repr 1106247680).  (* 30.0f *)

Definition timer131_upper_wall_sample_y : float32 :=
  Float32.add timer131_state_first_y timer131_upper_wall_offset.

Definition timer131_lower_wall_sample_y : float32 :=
  Float32.add timer131_state_first_y timer131_lower_wall_offset.

Definition terrain_s16_max_f32 : float32 :=
  Float32.of_bits (Int.repr 1191181824).  (* 32767.0f *)

(** Exact CompCert binary32 evaluation of the two source expressions. *)
Theorem timer131_wall_sample_binary32_values_checked :
  Float32.to_bits timer131_upper_wall_sample_y =
      Int.repr 1199806208 /\  (* 67374.0f *)
  Float32.to_bits timer131_lower_wall_sample_y =
      Int.repr 1199802368 /\  (* 67344.0f *)
  Float32.cmp Clt terrain_s16_max_f32
      timer131_upper_wall_sample_y = true /\
  Float32.cmp Clt terrain_s16_max_f32
      timer131_lower_wall_sample_y = true.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition terrain_s16_value (value : Z) : Prop :=
  -32768 <= value <= 32767.

(** Integer presentation of the source guard [y > surf->upperY].  The exact
    binary32 theorem above checks the largest promoted signed-16 endpoint;
    the linked refinement must connect the live promotion/comparison to this
    presentation. *)
Definition source_wall_upper_guard_skips
    (state_y offset surface_upper_y : Z) : Prop :=
  surface_upper_y < state_y + offset.

Theorem timer131_both_wall_guards_skip_every_s16_upper_y :
  forall surface_upper_y,
    terrain_s16_value surface_upper_y ->
    source_wall_upper_guard_skips 67314 60 surface_upper_y /\
    source_wall_upper_guard_skips 67314 30 surface_upper_y.
Proof.
  intros surface_upper_y Hrange.
  unfold terrain_s16_value in Hrange.
  unfold source_wall_upper_guard_skips.
  lia.
Qed.

Inductive Timer131WallPass : Type :=
| Timer131UpperWallPass
| Timer131LowerWallPass.

Definition timer131_wall_pass_offset (pass : Timer131WallPass) : Z :=
  match pass with
  | Timer131UpperWallPass => 60
  | Timer131LowerWallPass => 30
  end.

(** A small control-flow mirror of the relevant list loop.  [WallVisitSkip]
    is the source's early [continue].  [WallVisitPush] represents reaching a
    later X/Z push after the upper-Y guard did not reject the surface; its
    X/Z result is deliberately unconstrained. *)
Inductive SourceShapedWallListPass
    (pass : Timer131WallPass) :
    list Z -> (Z * Z) -> (Z * Z) -> Prop :=
| WallVisitDone :
    forall xz,
      SourceShapedWallListPass pass [] xz xz
| WallVisitSkip :
    forall upper_y remaining xz final_xz,
      terrain_s16_value upper_y ->
      source_wall_upper_guard_skips
        67314 (timer131_wall_pass_offset pass) upper_y ->
      SourceShapedWallListPass pass remaining xz final_xz ->
      SourceShapedWallListPass pass
        (upper_y :: remaining) xz final_xz
| WallVisitPush :
    forall upper_y remaining before_xz pushed_xz final_xz,
      terrain_s16_value upper_y ->
      ~ source_wall_upper_guard_skips
          67314 (timer131_wall_pass_offset pass) upper_y ->
      SourceShapedWallListPass pass remaining pushed_xz final_xz ->
      SourceShapedWallListPass pass
        (upper_y :: remaining) before_xz final_xz.

Lemma timer131_wall_pass_guard_skips :
  forall pass upper_y,
    terrain_s16_value upper_y ->
    source_wall_upper_guard_skips
      67314 (timer131_wall_pass_offset pass) upper_y.
Proof.
  intros pass upper_y Hrange.
  destruct pass; cbn.
  - exact (proj1
      (timer131_both_wall_guards_skip_every_s16_upper_y upper_y Hrange)).
  - exact (proj2
      (timer131_both_wall_guards_skip_every_s16_upper_y upper_y Hrange)).
Qed.

(** Every surface takes the early guard, so the constructor representing a
    later X/Z push is unreachable.  The result is independent of list order,
    ownership, normals, plane equations, and static-versus-dynamic origin. *)
Theorem timer131_source_shaped_wall_list_pass_preserves_xz :
  forall pass upper_ys before_xz after_xz,
    SourceShapedWallListPass pass upper_ys before_xz after_xz ->
    after_xz = before_xz.
Proof.
  intros pass upper_ys before_xz after_xz Hpass.
  induction Hpass.
  - reflexivity.
  - exact IHHpass.
  - exfalso.
    apply H0.
    now apply timer131_wall_pass_guard_skips.
Qed.

Corollary timer131_both_source_shaped_wall_passes_preserve_xz :
  forall upper_ys before_xz upper_after_xz lower_after_xz,
    SourceShapedWallListPass
      Timer131UpperWallPass upper_ys before_xz upper_after_xz ->
    SourceShapedWallListPass
      Timer131LowerWallPass upper_ys before_xz lower_after_xz ->
    upper_after_xz = before_xz /\ lower_after_xz = before_xz.
Proof.
  intros upper_ys before_xz upper_after_xz lower_after_xz
    Hupper Hlower.
  split.
  - exact
      (timer131_source_shaped_wall_list_pass_preserves_xz
        Timer131UpperWallPass upper_ys before_xz upper_after_xz Hupper).
  - exact
      (timer131_source_shaped_wall_list_pass_preserves_xz
        Timer131LowerWallPass upper_ys before_xz lower_after_xz Hlower).
Qed.

(** Both generated versions contain the strict temporary-Y greater-than
    loaded-[upperY] guard in the real list body.  These are AST receipts, not
    an execution or memory-typing proof. *)
Definition Timer131WallGuardSourceShapeReceipts : Prop :=
  contains_strict_temp_gt_loaded_field_s USurface._y USurface._upperY
    (Clight.fn_body USurface.f_find_wall_collisions_from_list) = true /\
  contains_strict_temp_gt_loaded_field_s JSurface._y JSurface._upperY
    (Clight.fn_body JSurface.f_find_wall_collisions_from_list) = true.

Theorem timer131_wall_guard_source_shape_receipts_checked :
  Timer131WallGuardSourceShapeReceipts.
Proof.
  split.
  - exact wall_upper_y_strict_rejection_source_shape_us.
  - exact wall_upper_y_strict_rejection_source_shape_jp.
Qed.

(** A projection interface for the remaining linked proof.  [executes_pass]
    must identify an actual US/JP call segment of the real wall function;
    [project] must read the base [WallCollisionData.y] before the pass-specific
    offset, traversed live [Surface.upperY] fields, and before/after X/Z values
    from Clight memory.  The obligation then requires each such concrete
    segment to refine the source-shaped traversal above.  No theorem in this
    file assumes or inhabits it. *)
Definition Timer131WallListClightMemoryRefinementObligation
    (executes_pass :
      Timer131WallPass -> Clight.state -> Clight.state -> Prop)
    (project :
      Clight.state -> option (float32 * list Z * (Z * Z))) : Prop :=
  forall pass before after sample_y upper_ys before_xz after_xz,
    executes_pass pass before after ->
    project before = Some (sample_y, upper_ys, before_xz) ->
    project after = Some (sample_y, upper_ys, after_xz) ->
    sample_y = timer131_state_first_y ->
    SourceShapedWallListPass pass upper_ys before_xz after_xz.

Definition Area1StateFirstWallExclusionCheckedBoundary : Prop :=
  Timer131WallGuardSourceShapeReceipts /\
  Float32.to_bits timer131_upper_wall_sample_y = Int.repr 1199806208 /\
  Float32.to_bits timer131_lower_wall_sample_y = Int.repr 1199802368 /\
  (forall pass upper_ys before_xz after_xz,
    SourceShapedWallListPass pass upper_ys before_xz after_xz ->
    after_xz = before_xz).

Theorem area1_state_first_wall_exclusion_checked_boundary :
  Area1StateFirstWallExclusionCheckedBoundary.
Proof.
  unfold Area1StateFirstWallExclusionCheckedBoundary.
  split; [exact timer131_wall_guard_source_shape_receipts_checked |].
  destruct timer131_wall_sample_binary32_values_checked
    as (Hupper & Hlower & _).
  split; [exact Hupper |].
  split; [exact Hlower |].
  exact timer131_source_shaped_wall_list_pass_preserves_xz.
Qed.
