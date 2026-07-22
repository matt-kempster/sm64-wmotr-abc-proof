From Coq Require Import Bool List ZArith.
From compcert Require Import Clight Integers.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

Definition a_button_mask : Int.int := Int.repr 32768.

(* This is the expression assigned to Controller.buttonPressed in game_init.c. *)
Definition edge_pressed (current previous_down : Int.int) : Int.int :=
  Int.and current (Int.xor current previous_down).

Definition a_button_pressed (current previous_down : Int.int) : bool :=
  Int.testbit (edge_pressed current previous_down) 15.

Definition a_button_down (current : Int.int) : bool :=
  Int.testbit current 15.

Record FrameInput := {
  frame_previous_down : Int.int;
  frame_current_down : Int.int
}.

Definition frame_has_no_a_press (input : FrameInput) : Prop :=
  a_button_pressed (frame_current_down input) (frame_previous_down input) = false.

Definition fewer_than_one_a_press (inputs : list FrameInput) : Prop :=
  Forall frame_has_no_a_press inputs.

Fixpoint coherent_input_history
    (expected_previous : Int.int) (inputs : list FrameInput) : Prop :=
  match inputs with
  | [] => True
  | input :: rest =>
      frame_previous_down input = expected_previous /\
      coherent_input_history (frame_current_down input) rest
  end.

Theorem held_a_at_entry_is_permitted :
  frame_has_no_a_press
    {| frame_previous_down := a_button_mask;
       frame_current_down := a_button_mask |} /\
  a_button_down a_button_mask = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem generated_controller_has_pressed_operator_shape_us :
  assigns_pressed_operator_shape_s us_game_init._buttonPressed
    (Clight.fn_body us_game_init.f_read_controller_inputs) = true.
Proof. exact controller_pressed_operator_source_shape_us. Qed.

Theorem generated_controller_has_pressed_operator_shape_jp :
  assigns_pressed_operator_shape_s jp_game_init._buttonPressed
    (Clight.fn_body jp_game_init.f_read_controller_inputs) = true.
Proof. exact controller_pressed_operator_source_shape_jp. Qed.
