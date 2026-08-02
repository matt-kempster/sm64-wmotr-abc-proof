From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Proofs Require Import GameTypes.

Definition f32_speed_16_375 : float32 := f32_of_bits 1099104256.
Definition f32_speed_17 : float32 := f32_of_bits 1099431936.

Definition flat_tap_speed (class : FlatFloorClass) : float32 :=
  match class with
  | VerySlippery => f32_speed_16_375
  | Slippery | DefaultFloor | NotSlippery => f32_speed_17
  end.

Theorem very_slippery_flat_landing_tap_checked :
  flat_landing_tap_witness VerySlippery f32_speed_16_375.
Proof.
  vm_compute.
  split; reflexivity.
Qed.
Theorem slippery_flat_landing_tap_checked :
  flat_landing_tap_witness Slippery f32_speed_17.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem default_flat_landing_tap_checked :
  flat_landing_tap_witness DefaultFloor f32_speed_17.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem not_slippery_flat_landing_tap_checked :
  flat_landing_tap_witness NotSlippery f32_speed_17.
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem every_flat_floor_class_has_landing_tap :
  forall class, flat_landing_tap_witness class (flat_tap_speed class).
Proof.
  intros [].
  - exact very_slippery_flat_landing_tap_checked.
  - exact slippery_flat_landing_tap_checked.
  - exact default_flat_landing_tap_checked.
  - exact not_slippery_flat_landing_tap_checked.
Qed.

Theorem every_flat_floor_class_has_some_landing_tap :
  forall class, exists speed, flat_landing_tap_witness class speed.
Proof.
  intro class.
  exists (flat_tap_speed class).
  apply every_flat_floor_class_has_landing_tap.
Qed.
