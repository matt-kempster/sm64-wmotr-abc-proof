(** Whole-linked-source reduction for the exact rank-3 pitch payload.

    The earlier rank-3 proof checked only the twenty-nine native bodies of the
    fifteen canonical SSL Area-1 surface-owner families.  This file follows
    every syntactically direct internal call from those bodies to a checked
    fixed point in all thirty-eight modeled US and JP translation units.  It
    also compares that closed set with the complete whole-game census of
    assignments to Object raw-data word 35 (pitch angular velocity).

    In both versions there are twenty-eight named writer bodies in the whole
    modeled game, but exactly one is in the canonical owners' direct call
    closure: [spawn_triangle_break_particles].  The existing source receipt
    and arithmetic theorem restrict its stock branches to 3840 or 6400, both
    unequal to the required signed half-turn -32768.  Six declarations in the
    fixed point have no internal body in the selected thirty-eight-unit
    program; they are reported exactly rather than silently framed.

    This is a direct-call result.  An indirect/forged dispatch, replacement
    object lifetime, valid pre-existing alias, or one of the six unresolved
    calls still needs a linked reachability/effect argument. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_obj_behaviors us_object_helpers us_spawn_object
  jp_behavior_actions jp_obj_behaviors jp_object_helpers jp_spawn_object.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1NonlocalPlatformInstallationClosure Area1NonlocalPlatformMirror
  Area1PrecollisionWriterClosure JPGeneratedWriterCensus
  FirstTargetRefinement LinkedClightPrograms NormalizedClightPrograms.

Import ListNotations.
Local Open Scope Z_scope.

Module A1R3_USActions := us_behavior_actions.
Module A1R3_USObjects := us_obj_behaviors.
Module A1R3_USHelpers := us_object_helpers.
Module A1R3_USSpawn := us_spawn_object.
Module A1R3_JPActions := jp_behavior_actions.
Module A1R3_JPObjects := jp_obj_behaviors.
Module A1R3_JPHelpers := jp_object_helpers.
Module A1R3_JPSpawn := jp_spawn_object.

Definition rank3_us_definitions :
    list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type) :=
  unit_global_definitions us_units.

Definition rank3_jp_definitions :
    list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type) :=
  unit_global_definitions jp_units.

Fixpoint internal_direct_callees_for_ident
    (target : ident)
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    : list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Ctypes.Internal body)) :: rest =>
      if Pos.eqb id target
      then direct_callees_s (fn_body body) ++
           internal_direct_callees_for_ident target rest
      else internal_direct_callees_for_ident target rest
  | _ :: rest => internal_direct_callees_for_ident target rest
  end.

Fixpoint ident_has_internal_body
    (target : ident)
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    : bool :=
  match definitions with
  | [] => false
  | (id, Gfun (Ctypes.Internal _)) :: rest =>
      Pos.eqb id target || ident_has_internal_body target rest
  | _ :: rest => ident_has_internal_body target rest
  end.

Definition expand_internal_direct_calls
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    (identifiers : list ident) : list ident :=
  nodup Pos.eq_dec
    (identifiers ++
     concat
       (map
         (fun id => internal_direct_callees_for_ident id definitions)
         identifiers)).

Fixpoint internal_direct_call_closure
    (fuel : nat)
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    (roots : list ident) : list ident :=
  match fuel with
  | O => nodup Pos.eq_dec roots
  | S rest =>
      expand_internal_direct_calls definitions
        (internal_direct_call_closure rest definitions roots)
  end.

Definition native_body_direct_callees
    (bodies : list Clight.function) : list ident :=
  concat (map (fun body => direct_callees_s (fn_body body)) bodies).

Definition rank3_us_owner_call_closure (fuel : nat) : list ident :=
  internal_direct_call_closure fuel rank3_us_definitions
    (native_body_direct_callees us_area1_stock_surface_native_bodies).

Definition rank3_jp_owner_call_closure (fuel : nat) : list ident :=
  internal_direct_call_closure fuel rank3_jp_definitions
    (native_body_direct_callees jp_area1_stock_surface_native_bodies).

Definition rank3_us_named_pitch_writers : list ident :=
  internal_array_slot_assignment_sites A1R3_USActions._asS32 35
    rank3_us_definitions.

Definition rank3_jp_named_pitch_writers : list ident :=
  internal_array_slot_assignment_sites A1R3_JPActions._asS32 35
    rank3_jp_definitions.

Definition identifiers_in
    (haystack needles : list ident) : list ident :=
  filter
    (fun candidate => existsb (Pos.eqb candidate) needles)
    haystack.

Definition unresolved_identifiers
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    (identifiers : list ident) : list ident :=
  filter (fun id => negb (ident_has_internal_body id definitions)) identifiers.

Definition same_identifier_set (left right : list ident) : bool :=
  forallb (fun id => existsb (Pos.eqb id) right) left &&
  forallb (fun id => existsb (Pos.eqb id) left) right.

Definition internal_direct_call_set_is_closed
    (definitions :
      list (ident * globdef (Ctypes.fundef Clight.function) Ctypes.type))
    (identifiers : list ident) : bool :=
  forallb
    (fun id =>
      forallb
        (fun callee => existsb (Pos.eqb callee) identifiers)
        (internal_direct_callees_for_ident id definitions))
    identifiers.

Definition rank3_owner_direct_closure_claim : Prop :=
  length rank3_us_named_pitch_writers = 28%nat /\
  length rank3_jp_named_pitch_writers = 28%nat /\
  same_identifier_set
    rank3_us_named_pitch_writers rank3_jp_named_pitch_writers = true /\
  length (rank3_us_owner_call_closure 5) = 93%nat /\
  length (rank3_jp_owner_call_closure 5) = 93%nat /\
  same_identifier_set
    (rank3_us_owner_call_closure 6)
    (rank3_us_owner_call_closure 5) = true /\
  same_identifier_set
    (rank3_jp_owner_call_closure 6)
    (rank3_jp_owner_call_closure 5) = true /\
  internal_direct_call_set_is_closed rank3_us_definitions
    (rank3_us_owner_call_closure 5) = true /\
  internal_direct_call_set_is_closed rank3_jp_definitions
    (rank3_jp_owner_call_closure 5) = true /\
  identifiers_in rank3_us_named_pitch_writers
    (rank3_us_owner_call_closure 5) =
      [A1R3_USHelpers._spawn_triangle_break_particles] /\
  identifiers_in rank3_jp_named_pitch_writers
    (rank3_jp_owner_call_closure 5) =
      [A1R3_JPHelpers._spawn_triangle_break_particles] /\
  unresolved_identifiers rank3_us_definitions
    (rank3_us_owner_call_closure 5) =
      [A1R3_USObjects._play_puzzle_jingle;
       A1R3_USHelpers._create_sound_spawner;
       A1R3_USHelpers._cur_obj_play_sound_2;
       A1R3_USHelpers._set_camera_shake_from_point;
       A1R3_USHelpers._sqrtf;
       A1R3_USSpawn._stop_sounds_from_source] /\
  unresolved_identifiers rank3_jp_definitions
    (rank3_jp_owner_call_closure 5) =
      [A1R3_JPObjects._play_puzzle_jingle;
       A1R3_JPHelpers._create_sound_spawner;
       A1R3_JPHelpers._cur_obj_play_sound_2;
       A1R3_JPHelpers._set_camera_shake_from_point;
       A1R3_JPHelpers._sqrtf;
       A1R3_JPSpawn._stop_sounds_from_source].

(** Keep the expensive generated-AST computations in small opaque receipts.
    Besides making failures local, this prevents the final conjunction proof
    from normalizing the same thirty-eight-unit corpus repeatedly. *)
Theorem rank3_named_pitch_writer_inventory_checked :
  length rank3_us_named_pitch_writers = 28%nat /\
  length rank3_jp_named_pitch_writers = 28%nat /\
  same_identifier_set
    rank3_us_named_pitch_writers rank3_jp_named_pitch_writers = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank3_owner_call_closure_sizes_checked :
  length (rank3_us_owner_call_closure 5) = 93%nat /\
  length (rank3_jp_owner_call_closure 5) = 93%nat.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank3_owner_call_closure_fixed_sets_checked :
  same_identifier_set
    (rank3_us_owner_call_closure 6)
    (rank3_us_owner_call_closure 5) = true /\
  same_identifier_set
    (rank3_jp_owner_call_closure 6)
    (rank3_jp_owner_call_closure 5) = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank3_owner_call_closure_closed_checked :
  internal_direct_call_set_is_closed rank3_us_definitions
    (rank3_us_owner_call_closure 5) = true /\
  internal_direct_call_set_is_closed rank3_jp_definitions
    (rank3_jp_owner_call_closure 5) = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank3_owner_pitch_writer_intersections_checked :
  identifiers_in rank3_us_named_pitch_writers
    (rank3_us_owner_call_closure 5) =
      [A1R3_USHelpers._spawn_triangle_break_particles] /\
  identifiers_in rank3_jp_named_pitch_writers
    (rank3_jp_owner_call_closure 5) =
      [A1R3_JPHelpers._spawn_triangle_break_particles].
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank3_owner_unresolved_call_inventory_checked :
  unresolved_identifiers rank3_us_definitions
    (rank3_us_owner_call_closure 5) =
      [A1R3_USObjects._play_puzzle_jingle;
       A1R3_USHelpers._create_sound_spawner;
       A1R3_USHelpers._cur_obj_play_sound_2;
       A1R3_USHelpers._set_camera_shake_from_point;
       A1R3_USHelpers._sqrtf;
       A1R3_USSpawn._stop_sounds_from_source] /\
  unresolved_identifiers rank3_jp_definitions
    (rank3_jp_owner_call_closure 5) =
      [A1R3_JPObjects._play_puzzle_jingle;
       A1R3_JPHelpers._create_sound_spawner;
       A1R3_JPHelpers._cur_obj_play_sound_2;
       A1R3_JPHelpers._set_camera_shake_from_point;
       A1R3_JPHelpers._sqrtf;
       A1R3_JPSpawn._stop_sounds_from_source].
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank3_owner_direct_closure_checked :
  rank3_owner_direct_closure_claim.
Proof.
  unfold rank3_owner_direct_closure_claim.
  destruct rank3_named_pitch_writer_inventory_checked
    as (Hus_writers & Hjp_writers & Hwriter_set).
  destruct rank3_owner_call_closure_sizes_checked
    as (Hus_size & Hjp_size).
  destruct rank3_owner_call_closure_fixed_sets_checked
    as (Hus_fixed & Hjp_fixed).
  destruct rank3_owner_call_closure_closed_checked
    as (Hus_closed & Hjp_closed).
  destruct rank3_owner_pitch_writer_intersections_checked
    as (Hus_intersection & Hjp_intersection).
  destruct rank3_owner_unresolved_call_inventory_checked
    as (Hus_external & Hjp_external).
  split; [exact Hus_writers |].
  split; [exact Hjp_writers |].
  split; [exact Hwriter_set |].
  split; [exact Hus_size |].
  split; [exact Hjp_size |].
  split; [exact Hus_fixed |].
  split; [exact Hjp_fixed |].
  split; [exact Hus_closed |].
  split; [exact Hjp_closed |].
  split; [exact Hus_intersection |].
  split; [exact Hjp_intersection |].
  split; [exact Hus_external |].
  exact Hjp_external.
Qed.

(** Set equality of iterations five and six is the checked fixed-point
    receipt.  By the definition of [internal_direct_call_closure], iteration
    six is one expansion of iteration five. *)
Theorem rank3_us_owner_call_closure_is_fixed :
  same_identifier_set
    (rank3_us_owner_call_closure 6)
    (rank3_us_owner_call_closure 5) = true.
Proof.
  exact (proj1 rank3_owner_call_closure_fixed_sets_checked).
Qed.

Theorem rank3_jp_owner_call_closure_is_fixed :
  same_identifier_set
    (rank3_jp_owner_call_closure 6)
    (rank3_jp_owner_call_closure 5) = true.
Proof.
  exact (proj2 rank3_owner_call_closure_fixed_sets_checked).
Qed.

Theorem rank3_checked_known_pitch_values_exclude_required_half_turn :
  forall source,
    known_area1_preapply_pitch_velocity source <>
      Int.signed
        (platform_payload_rotation_pitch_s16 rank3_full_split_payload).
Proof.
  exact known_area1_preapply_pitch_never_matches_rank3_half_turn.
Qed.

Definition Area1Rank3PayloadWriterCheckedBoundary : Prop :=
  rank3_owner_direct_closure_claim /\
  same_identifier_set
    (rank3_us_owner_call_closure 6)
    (rank3_us_owner_call_closure 5) = true /\
  same_identifier_set
    (rank3_jp_owner_call_closure 6)
    (rank3_jp_owner_call_closure 5) = true /\
  (forall source,
    known_area1_preapply_pitch_velocity source <>
      Int.signed
        (platform_payload_rotation_pitch_s16 rank3_full_split_payload)).

Theorem area1_rank3_payload_writer_checked_boundary_holds :
  Area1Rank3PayloadWriterCheckedBoundary.
Proof.
  split; [exact rank3_owner_direct_closure_checked |].
  split; [exact rank3_us_owner_call_closure_is_fixed |].
  split; [exact rank3_jp_owner_call_closure_is_fixed |].
  exact rank3_checked_known_pitch_values_exclude_required_half_turn.
Qed.
