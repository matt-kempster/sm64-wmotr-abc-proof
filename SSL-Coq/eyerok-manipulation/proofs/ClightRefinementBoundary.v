From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Ctypes Events Maps Smallstep.
From SSLEyerok.Generated Require game_init level_update
  mario_actions_moving mario_actions_object mario_actions_stationary
  obj_behaviors_2 object_list_processor.
From SSLEyerok.Proofs Require Import Area2Route AuthenticReachability
  GeneratedFacts Spec StateMachine.

Local Open Scope Z_scope.

(** A [clight_frame_run] is one coherent CompCert Clight execution.  Each
    selected frame boundary follows the preceding boundary by a nonempty
    sequence of genuine [Clight.step2] small steps.  This record deliberately
    leaves the choice of frame boundaries abstract; proving that they are the
    original game's normal-frame boundaries is part of the refinement premise
    below. *)
Record clight_frame_run (linked : Clight.program) : Type := {
  cfr_state : nat -> Clight.state;
  cfr_initial : Clight.initial_state linked (cfr_state O);
  cfr_segment : forall frame, exists trace : Events.trace,
    Smallstep.plus Clight.step2 (Clight.globalenv linked)
      (cfr_state frame) trace (cfr_state (S frame))
}.

(** [observe_y] is intentionally a total abstract observer.  A complete
    bridge must prove that it reads binary32 [oPosY] from the intended live
    Eyerok hand at the chosen frame boundary and justifies the conversion to
    [Z].  Merely supplying a function of this type is not such a proof. *)
Definition clight_height_refines_audited
    (linked : Clight.program) (run : clight_frame_run linked)
    (observe_y : Clight.state -> Z) (a_policy : nat -> bool)
    (rank : hand_rank) : Prop :=
  forall frame, exists modeled,
    audited_coupled_reachable a_policy rank frame modeled /\
    observe_y (cfr_state linked run frame) =
      state_y (coupled_vertical modeled).

Definition clight_height_unbounded
    (linked : Clight.program) (run : clight_frame_run linked)
    (observe_y : Clight.state -> Z) : Prop :=
  forall bound, exists frame,
    bound < observe_y (cfr_state linked run frame).

Theorem clight_origin_bounded_if_refined :
  forall linked (run : clight_frame_run linked) observe_y a_policy rank,
    clight_height_refines_audited linked run observe_y a_policy rank ->
    forall frame,
      observe_y (cfr_state linked run frame) <= global_height_ceiling.
Proof.
  intros linked run observe_y a_policy rank Hrefines frame.
  destruct (Hrefines frame) as (modeled & Hreachable & Hobservation).
  rewrite Hobservation.
  exact (audited_coupled_hand_origin_bounded
    a_policy rank frame modeled Hreachable).
Qed.

Corollary clight_origin_1467_bounded_if_refined :
  forall linked (run : clight_frame_run linked) observe_y a_policy rank,
    clight_height_refines_audited linked run observe_y a_policy rank ->
    forall frame, observe_y (cfr_state linked run frame) <= 1467.
Proof.
  intros linked run observe_y a_policy rank Hrefines frame.
  pose proof (clight_origin_bounded_if_refined
    linked run observe_y a_policy rank Hrefines frame) as Hbound.
  exact Hbound.
Qed.

Corollary clight_surface_1974_bounded_if_refined :
  forall linked (run : clight_frame_run linked) observe_y a_policy rank,
    clight_height_refines_audited linked run observe_y a_policy rank ->
    forall frame,
      observe_y (cfr_state linked run frame) + hand_collision_top_max <= 1974.
Proof.
  intros linked run observe_y a_policy rank Hrefines frame.
  pose proof (clight_origin_1467_bounded_if_refined
    linked run observe_y a_policy rank Hrefines frame) as Hbound.
  cbv [hand_collision_top_max]. lia.
Qed.

Corollary clight_mario_peak_2604_bounded_if_refined :
  forall linked (run : clight_frame_run linked) observe_y a_policy rank,
    clight_height_refines_audited linked run observe_y a_policy rank ->
    forall frame,
      observe_y (cfr_state linked run frame) + hand_collision_top_max +
        mario_triple_jump_rise_max <= 2604.
Proof.
  intros linked run observe_y a_policy rank Hrefines frame.
  pose proof (clight_surface_1974_bounded_if_refined
    linked run observe_y a_policy rank Hrefines frame) as Hbound.
  cbv [mario_triple_jump_rise_max]. lia.
Qed.

Theorem clight_no_unbounded_rise_if_refined :
  forall linked (run : clight_frame_run linked) observe_y a_policy rank,
    clight_height_refines_audited linked run observe_y a_policy rank ->
    ~ clight_height_unbounded linked run observe_y.
Proof.
  intros linked run observe_y a_policy rank Hrefines Hunbounded.
  destruct (Hunbounded global_height_ceiling) as (frame & Hhigher).
  pose proof (clight_origin_bounded_if_refined
    linked run observe_y a_policy rank Hrefines frame) as Hbounded.
  lia.
Qed.

Definition clight_program_defmap (linked : Clight.program) :=
  PTree_Properties.of_list (Ctypes.prog_defs linked).

(** This premise says that a proposed linked program resolves the selected
    names to the exact generated function bodies.  The project proves the
    analogous facts separately for each generated translation unit, but does
    not construct a complete linked whole-game program satisfying this
    predicate. *)
Definition eyerok_link_members (linked : Clight.program) : Prop :=
  PTree.get obj_behaviors_2._bhv_eyerok_hand_loop
    (clight_program_defmap linked) =
      Some (Gfun (Internal obj_behaviors_2.f_bhv_eyerok_hand_loop)) /\
  PTree.get level_update._play_mode_normal
    (clight_program_defmap linked) =
      Some (Gfun (Internal level_update.f_play_mode_normal)) /\
  PTree.get object_list_processor._update_objects
    (clight_program_defmap linked) =
      Some (Gfun (Internal object_list_processor.f_update_objects)) /\
  PTree.get game_init._read_controller_inputs
    (clight_program_defmap linked) =
      Some (Gfun (Internal game_init.f_read_controller_inputs)) /\
  PTree.get mario_actions_moving._check_ground_dive_or_punch
    (clight_program_defmap linked) =
      Some (Gfun (Internal
        mario_actions_moving.f_check_ground_dive_or_punch)) /\
  PTree.get mario_actions_moving._act_move_punching
    (clight_program_defmap linked) =
      Some (Gfun (Internal mario_actions_moving.f_act_move_punching)) /\
  PTree.get mario_actions_object._act_punching
    (clight_program_defmap linked) =
      Some (Gfun (Internal mario_actions_object.f_act_punching)) /\
  PTree.get mario_actions_stationary._act_crouching
    (clight_program_defmap linked) =
      Some (Gfun (Internal mario_actions_stationary.f_act_crouching)).

(** The certificate intentionally quantifies over, rather than constructs, a
    linked program and its refinement.  AST resolution/call-site-traversal
    facts are evidence about the pinned translation units; they do not
    discharge the semantic premise. *)
Definition clight_refinement_boundary_certificate : Prop :=
  generated_unit_resolution_shape /\
  generated_callsite_traversal_shape /\
  generated_controller_action_shape /\
  forall linked (run : clight_frame_run linked) observe_y a_policy rank,
    eyerok_link_members linked ->
    clight_height_refines_audited linked run observe_y a_policy rank ->
    (forall frame,
      observe_y (cfr_state linked run frame) <= 1467) /\
    (forall frame,
      observe_y (cfr_state linked run frame) + hand_collision_top_max <=
        1974) /\
    (forall frame,
      observe_y (cfr_state linked run frame) + hand_collision_top_max +
        mario_triple_jump_rise_max <= 2604) /\
    ~ clight_height_unbounded linked run observe_y.

Theorem clight_refinement_boundary_certificate_holds :
  clight_refinement_boundary_certificate.
Proof.
  unfold clight_refinement_boundary_certificate.
  refine (conj generated_unit_resolution_shape_holds _).
  refine (conj generated_callsite_traversal_shape_holds _).
  refine (conj generated_controller_action_shape_holds _).
  intros linked run observe_y a_policy rank _ Hrefines.
  repeat split.
  - exact (clight_origin_1467_bounded_if_refined
      linked run observe_y a_policy rank Hrefines).
  - exact (clight_surface_1974_bounded_if_refined
      linked run observe_y a_policy rank Hrefines).
  - exact (clight_mario_peak_2604_bounded_if_refined
      linked run observe_y a_policy rank Hrefines).
  - exact (clight_no_unbounded_rise_if_refined
      linked run observe_y a_policy rank Hrefines).
Qed.
