(** One isolated binary32-to-word receipt for the route-relevant nonlocal Y.
    This file is intentionally tiny: CompCert's executable binary32 conversion
    is expensive enough that keeping it out of the larger surface module
    materially lowers peak checker memory. *)

From Coq Require Import ZArith.
From compcert Require Import Clightdefs Cop Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  Area1NonlocalCastSemantics GameTypes.

Local Open Scope Z_scope.
Import Clightdefs.ClightNotations.

Definition timer131_nonlocal_y_float : float32 :=
  f32_bits 1199798528. (* 0x47837900 = 67314.0f *)

Definition timer131_midface_x_float : float32 :=
  f32_bits 3303587840. (* 0xc4e8c000 = -1862.0f *)

Definition timer131_midface_z_float : float32 :=
  f32_bits 3294724096. (* 0xc4618000 = -902.0f *)

Theorem timer131_nonlocal_y_binary32_cast_checked :
  Float32.to_int timer131_nonlocal_y_float = Some (Int.repr 67314) /\
  terrain_s16_from_float timer131_nonlocal_y_float = Some 1778.
Proof.
  unfold timer131_nonlocal_y_float, terrain_s16_from_float,
    terrain_s16_from_word, f32_bits.
  vm_compute. split; reflexivity.
Qed.

Theorem timer131_midface_x_binary32_cast_checked :
  Float32.to_int timer131_midface_x_float = Some (Int.repr (-1862)) /\
  terrain_s16_from_float timer131_midface_x_float = Some (-1862).
Proof.
  unfold timer131_midface_x_float, terrain_s16_from_float,
    terrain_s16_from_word, f32_bits.
  vm_compute. split; reflexivity.
Qed.

Theorem timer131_midface_z_binary32_cast_checked :
  Float32.to_int timer131_midface_z_float = Some (Int.repr (-902)) /\
  terrain_s16_from_float timer131_midface_z_float = Some (-902).
Proof.
  unfold timer131_midface_z_float, terrain_s16_from_float,
    terrain_s16_from_word, f32_bits.
  vm_compute. split; reflexivity.
Qed.

Definition timer131_nonlocal_y_state_float : Vec3f :=
  {| vec_x := timer131_midface_x_float;
     vec_y := timer131_nonlocal_y_float;
     vec_z := timer131_midface_z_float |}.

Theorem timer131_nonlocal_y_vector_cast_components_checked :
  terrain_s16_from_float (vec_x timer131_nonlocal_y_state_float) =
    Some (-1862) /\
  terrain_s16_from_float (vec_y timer131_nonlocal_y_state_float) =
    Some 1778 /\
  terrain_s16_from_float (vec_z timer131_nonlocal_y_state_float) =
    Some (-902).
Proof.
  unfold timer131_nonlocal_y_state_float.
  cbn.
  split; [exact (proj2 timer131_midface_x_binary32_cast_checked) |].
  split; [exact (proj2 timer131_nonlocal_y_binary32_cast_checked) |].
  exact (proj2 timer131_midface_z_binary32_cast_checked).
Qed.

(** The generated [find_floor] prefix casts each input from [float] to signed
    [short].  This closes the CompCert value semantics for the new vector; it
    does not by itself execute the generated statements or relate them to a
    target-MIPS instruction trace. *)
Definition timer131_concrete_short_cast
    (value : float32) (memory : Mem.mem) : option val :=
  match Cop.sem_cast (Vsingle value) tfloat tshort memory with
  | Some result => Cop.sem_cast result tshort tshort memory
  | None => None
  end.

Theorem timer131_nonlocal_vector_compcert_short_casts_checked :
  forall memory,
    timer131_concrete_short_cast timer131_midface_x_float memory =
      Some (Vint (Int.repr (-1862))) /\
    timer131_concrete_short_cast timer131_nonlocal_y_float memory =
      Some (Vint (Int.repr 1778)) /\
    timer131_concrete_short_cast timer131_midface_z_float memory =
      Some (Vint (Int.repr (-902))).
Proof.
  intros memory.
  unfold timer131_concrete_short_cast, timer131_midface_x_float,
    timer131_nonlocal_y_float, timer131_midface_z_float, f32_bits.
  vm_compute. repeat split; reflexivity.
Qed.

(** Value-level arithmetic for the authenticated retail
    [trunc.w.s; mfc1; sh; lh] instruction shape.  The ROM attribution and MIPS
    small-step refinement remain separate evidence. *)
Theorem timer131_nonlocal_vector_target_prefix_arithmetic_checked :
  target_terrain_cast_prefix true timer131_midface_x_float =
      TargetCastCoordinate (-1862) /\
  target_terrain_cast_prefix true timer131_nonlocal_y_float =
      TargetCastCoordinate 1778 /\
  target_terrain_cast_prefix true timer131_midface_z_float =
      TargetCastCoordinate (-902).
Proof.
  unfold target_terrain_cast_prefix, timer131_midface_x_float,
    timer131_nonlocal_y_float, timer131_midface_z_float, f32_bits,
    terrain_s16_from_word.
  vm_compute. repeat split; reflexivity.
Qed.

Definition Timer131NonlocalVectorCastSemantics : Prop :=
  (forall memory,
    timer131_concrete_short_cast timer131_midface_x_float memory =
        Some (Vint (Int.repr (-1862))) /\
    timer131_concrete_short_cast timer131_nonlocal_y_float memory =
        Some (Vint (Int.repr 1778)) /\
    timer131_concrete_short_cast timer131_midface_z_float memory =
        Some (Vint (Int.repr (-902)))) /\
  target_terrain_cast_prefix true timer131_midface_x_float =
      TargetCastCoordinate (-1862) /\
  target_terrain_cast_prefix true timer131_nonlocal_y_float =
      TargetCastCoordinate 1778 /\
  target_terrain_cast_prefix true timer131_midface_z_float =
      TargetCastCoordinate (-902).

Theorem timer131_nonlocal_vector_cast_semantics_checked :
  Timer131NonlocalVectorCastSemantics.
Proof.
  unfold Timer131NonlocalVectorCastSemantics.
  split; [exact timer131_nonlocal_vector_compcert_short_casts_checked |].
  exact timer131_nonlocal_vector_target_prefix_arithmetic_checked.
Qed.
