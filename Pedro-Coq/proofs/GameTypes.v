From Coq Require Import List ZArith.
From compcert Require Import AST Clight Floats Integers.

Inductive GameVersion : Type :=
| VersionUS
| VersionJP.

Definition supported_version (version : GameVersion) : Prop :=
  match version with
  | VersionUS | VersionJP => True
  end.

Inductive FlatFloorClass : Type :=
| VerySlippery
| Slippery
| DefaultFloor
| NotSlippery.

Definition f32_of_bits (bits : Z) : float32 :=
  Float32.of_bits (Int.repr bits).

Definition f32_very_slippery_factor : float32 := f32_of_bits 1045220557.
Definition f32_slippery_factor : float32 := f32_of_bits 1060320051.
Definition f32_default_factor : float32 := f32_of_bits 1073741824.
Definition f32_not_slippery_factor : float32 := f32_of_bits 1077936128.
Definition f32_landing_decel_coefficient : float32 := f32_of_bits 1073741824.
Definition f32_analog_factor : float32 := f32_of_bits 1065017672.
Definition f32_dust_threshold : float32 := f32_of_bits 1098907648.

Definition flat_floor_decel_factor (class : FlatFloorClass) : float32 :=
  match class with
  | VerySlippery => f32_very_slippery_factor
  | Slippery => f32_slippery_factor
  | DefaultFloor => f32_default_factor
  | NotSlippery => f32_not_slippery_factor
  end.

Definition flat_floor_decel (class : FlatFloorClass) : float32 :=
  Float32.mul f32_landing_decel_coefficient
    (flat_floor_decel_factor class).

Definition dust_gate (speed : float32) : bool :=
  Float32.cmp Clt f32_dust_threshold speed.

Definition flat_analog_after (speed : float32) : float32 :=
  Float32.mul speed f32_analog_factor.

Definition flat_neutral_after
    (class : FlatFloorClass) (speed : float32) : float32 :=
  Float32.sub speed (flat_floor_decel class).

(** This is only the exact arithmetic kernel for a flat referenced floor. It
    does not assert that a Mario state is reachable or remains in a Pedro spot. *)
Definition flat_landing_tap_witness
    (class : FlatFloorClass) (speed : float32) : Prop :=
  dust_gate (flat_analog_after speed) = true /\
  dust_gate (flat_neutral_after class speed) = false.
