From Coq Require Import Bool ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import GameTypes.

Local Open Scope Z_scope.

Definition horizontal_distance (a b : Vec3f) : float32 :=
  let dx := Float32.sub (vec_x a) (vec_x b) in
  let dz := Float32.sub (vec_z a) (vec_z b) in
  Float32.sqrt
    (Float32.add (Float32.mul dx dx) (Float32.mul dz dz)).

Definition hitbox_bottom (position : Vec3f) (hitbox : Hitbox) : float32 :=
  Float32.sub (vec_y position) (hitbox_down_offset hitbox).

Definition hitbox_top (position : Vec3f) (hitbox : Hitbox) : float32 :=
  Float32.add (hitbox_height hitbox) (hitbox_bottom position hitbox).

(* Handwritten Float32 formula intended to mirror detect_object_hitbox_overlap,
   including strict radius and inclusive vertical boundary checks.  Its
   execution-level refinement from generated Clight remains pending. *)
Definition hitboxes_overlap
    (a_position : Vec3f) (a_hitbox : Hitbox)
    (b_position : Vec3f) (b_hitbox : Hitbox) : bool :=
  andb
    (Float32.cmp Clt
       (horizontal_distance a_position b_position)
       (Float32.add (hitbox_radius a_hitbox) (hitbox_radius b_hitbox)))
    (andb
       (negb (Float32.cmp Clt
          (hitbox_top b_position b_hitbox)
          (hitbox_bottom a_position a_hitbox)))
       (negb (Float32.cmp Clt
          (hitbox_top a_position a_hitbox)
          (hitbox_bottom b_position b_hitbox)))).

Definition collision_phase_overlap (phase : CollisionPhase) : Prop :=
  object_ref_equal
    (collision_mario_ref phase) (collision_player_ref phase) /\
  collision_area phase = pyramid_area_id /\
  collision_after_platform_displacement phase = true /\
  collision_before_behavior_update phase = true /\
  collision_instant_warp_pending phase = false /\
  Int.lt (collision_mario_count_before phase) (Int.repr 4) = true /\
  Int.lt (collision_target_count_before phase) (Int.repr 4) = true /\
  hitboxes_overlap
    (collision_mario_position phase) (collision_mario_hitbox phase)
    (collision_target_position phase) (collision_target_hitbox phase) = true /\
  collision_pair_registered phase = true.

Definition overlaps_object (phase : CollisionPhase) (o : ObjectState) : Prop :=
  object_ref_equal (collision_target_ref phase) (object_ref o) /\
  collision_target_position phase = object_position o /\
  collision_target_hitbox phase = object_hitbox o /\
  collision_phase_overlap phase.

Definition act3_star_interaction_region
    (phase : CollisionPhase) (o : ObjectState) : Prop :=
  active_star_or_key act3_index o /\ overlaps_object phase o.

Definition upper_hidden_trigger_overlap
    (phase : CollisionPhase) (o : ObjectState) : Prop :=
  active_object o /\
  object_behavior o = BehaviorHiddenStarTrigger /\
  object_origin o = PyramidMacroTrigger /\
  overlaps_object phase o.

Theorem registered_overlap_uses_collision_phase :
  forall phase o,
    overlaps_object phase o ->
    collision_after_platform_displacement phase = true /\
    collision_before_behavior_update phase = true /\
    collision_pair_registered phase = true.
Proof.
  intros phase o
    (_ & _ & _ & _ & _ & Hafter & Hbefore & _ & _ & _ & _ & Hregistered).
  repeat split; assumption.
Qed.

Theorem registered_overlap_uses_designated_player :
  forall phase o,
    overlaps_object phase o ->
    object_ref_equal
      (collision_mario_ref phase) (collision_player_ref phase).
Proof.
  intros phase o (_ & _ & _ & Hplayer & _).
  exact Hplayer.
Qed.
