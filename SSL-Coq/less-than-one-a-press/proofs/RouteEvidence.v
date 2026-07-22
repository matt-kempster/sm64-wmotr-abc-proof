(* Narrow lemmas re-established from archived route investigations.

   The integer route relations in this file are deliberately prefixed
   [legacy_].  They are useful subcase certificates and regression tests, but
   no theorem here claims a simulation from a linked Clight execution. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Coqlib AST Integers Memory Values.
From LessThanOneAPress.Proofs Require Import InputSemantics.

Import ListNotations.
Local Open Scope Z_scope.

Definition held_a_frame : FrameInput :=
  {| frame_previous_down := a_button_mask;
     frame_current_down := a_button_mask |}.

Lemma held_a_frame_has_no_press_edge :
  frame_has_no_a_press held_a_frame.
Proof. vm_compute. reflexivity. Qed.

Theorem continuously_held_a_has_no_press_edges :
  forall frame_count,
    fewer_than_one_a_press (repeat held_a_frame frame_count).
Proof.
  intros frame_count.
  unfold fewer_than_one_a_press.
  induction frame_count as [| frame_count IH]; cbn.
  - constructor.
  - constructor.
    + exact held_a_frame_has_no_press_edge.
    + exact IH.
Qed.

(* Re-established kernel of the archived parallel-universe alias-gap proof.
   Its hypotheses expose both the bounded delta and the existence of a static
   alias.  Coverage of every retail position writer remains a separate Layer B
   obligation. *)
Definition legacy_pu_quarter_step_bound : Z := 256.
Definition legacy_pu_coordinate_period : Z := 65536.
Definition legacy_pu_local_min : Z := -4148.
Definition legacy_pu_local_max : Z := 6758.

Definition legacy_pu_local_coordinate (coordinate : Z) : Prop :=
  legacy_pu_local_min <= coordinate <= legacy_pu_local_max.

Record LegacyAcceptedStaticQstep (before after : Z) : Prop := {
  legacy_qstep_before_local : legacy_pu_local_coordinate before;
  legacy_qstep_has_bounded_delta :
    exists delta,
      after = before + delta /\
      Z.abs delta <= legacy_pu_quarter_step_bound;
  legacy_qstep_has_static_alias :
    exists local period_index,
      legacy_pu_local_coordinate local /\
      after = local + legacy_pu_coordinate_period * period_index
}.

Theorem legacy_bounded_static_qstep_cannot_change_alias_period :
  forall before after,
    LegacyAcceptedStaticQstep before after ->
    legacy_pu_local_coordinate after.
Proof.
  intros before after Hstep.
  destruct Hstep as
    [Hbefore [delta [Hafter Hdelta]]
      [local [period_index [Hlocal Halias]]]].
  unfold legacy_pu_local_coordinate, legacy_pu_local_min,
    legacy_pu_local_max in Hbefore, Hlocal |- *.
  unfold legacy_pu_quarter_step_bound in Hdelta.
  apply Z.abs_le in Hdelta.
  unfold legacy_pu_coordinate_period in Halias.
  assert (period_index = 0) by nia.
  subst period_index.
  cbn in Halias.
  nia.
Qed.

(* Re-established kernel of the archived normalized-pole soft-bonk bound.
   These mathematical-integer bounds do not cover every lower-entry route and
   are not substituted for Float32 collision-phase reachability. *)
Definition legacy_pole_base_y : Z := 3200.
Definition legacy_pole_parameter : Z := 92.
Definition legacy_pole_hitbox_height : Z := legacy_pole_parameter * 10.
Definition legacy_pole_top_offset : Z := 100.
Definition legacy_pole_top_y : Z :=
  legacy_pole_base_y + legacy_pole_hitbox_height - legacy_pole_top_offset.
Definition legacy_sixth_floor_y : Z := 3942.
Definition legacy_hole_west_clearance : Z := 101.
Definition legacy_pole_push_radius : Z := 70.
Definition legacy_non_a_speed_upper : Z := 2.

Definition legacy_soft_height_upper (frames : Z) : Z :=
  legacy_pole_top_y - 2 * frames * (frames - 1).

Definition legacy_soft_radius_upper (frames : Z) : Z :=
  legacy_pole_push_radius + legacy_non_a_speed_upper * frames.

Definition LegacySoftPoleClearable (frames : Z) : Prop :=
  legacy_hole_west_clearance <= legacy_soft_radius_upper frames /\
  legacy_sixth_floor_y <= legacy_soft_height_upper frames.

Lemma legacy_soft_last_eligible_frame :
  forall frames,
    0 <= frames ->
    legacy_sixth_floor_y <= legacy_soft_height_upper frames ->
    frames <= 6.
Proof.
  intros frames Hnonnegative Hheight.
  unfold legacy_sixth_floor_y, legacy_soft_height_upper,
    legacy_pole_top_y, legacy_pole_base_y, legacy_pole_hitbox_height,
    legacy_pole_parameter, legacy_pole_top_offset in *.
  nia.
Qed.

Lemma legacy_soft_max_radius_before_floor :
  forall frames,
    0 <= frames ->
    legacy_sixth_floor_y <= legacy_soft_height_upper frames ->
    legacy_soft_radius_upper frames <= 82.
Proof.
  intros frames Hnonnegative Hheight.
  pose proof (legacy_soft_last_eligible_frame frames Hnonnegative Hheight).
  unfold legacy_soft_radius_upper, legacy_pole_push_radius,
    legacy_non_a_speed_upper.
  lia.
Qed.

Theorem legacy_normalized_pole_soft_bonk_never_clears :
  forall frames,
    0 <= frames ->
    ~ LegacySoftPoleClearable frames.
Proof.
  intros frames Hnonnegative [Hradius Hheight].
  pose proof
    (legacy_soft_max_radius_before_floor frames Hnonnegative Hheight).
  unfold legacy_hole_west_clearance in Hradius.
  lia.
Qed.

(* The useful generic memory-frame lemma from demo-warp is revision-neutral.
   It says only that a store to a distinct CompCert block preserves a load;
   the current project does not yet provide a whole-program block-provenance
   proof connecting this lemma to Mario or demo memory. *)
Theorem separate_block_store_preserves_load :
  forall before after write_chunk read_chunk
      write_block read_block write_offset read_offset value,
    write_block <> read_block ->
    Mem.store write_chunk before write_block write_offset value = Some after ->
    Mem.load read_chunk after read_block read_offset =
      Mem.load read_chunk before read_block read_offset.
Proof.
  intros before after write_chunk read_chunk
    write_block read_block write_offset read_offset value
    Hseparate Hstore.
  eapply Mem.load_store_other; eauto.
Qed.

Theorem changed_load_after_store_requires_same_block :
  forall before after write_chunk read_chunk
      write_block read_block write_offset read_offset value,
    Mem.store write_chunk before write_block write_offset value = Some after ->
    Mem.load read_chunk after read_block read_offset <>
      Mem.load read_chunk before read_block read_offset ->
    write_block = read_block.
Proof.
  intros before after write_chunk read_chunk
    write_block read_block write_offset read_offset value Hstore Hchanged.
  destruct (peq write_block read_block) as [Hequal | Hseparate].
  - exact Hequal.
  - exfalso. apply Hchanged.
    eapply separate_block_store_preserves_load; eauto.
Qed.
