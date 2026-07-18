From Coq Require Import ZArith.
From compcert Require Import AST Ctypes Clight Errors Maps.
From DemoWarp.Generated Require Import game_init mario.

Module G := game_init.
Module M := mario.

Local Open Scope Z_scope.

Definition demo_ce : composite_env := prog_comp_env G.prog.

Definition demo_input_members : members :=
  match demo_ce ! G._DemoInput with
  | Some composite => co_members composite
  | None => nil
  end.

Theorem generated_demo_timer_offset :
  field_offset demo_ce G._timer demo_input_members = OK (0, Full).
Proof. vm_compute. reflexivity. Qed.

Theorem generated_demo_input_size :
  sizeof demo_ce (Tstruct G._DemoInput noattr) = 4.
Proof. vm_compute. reflexivity. Qed.

Definition mario_ce : composite_env := prog_comp_env M.prog.

Definition mario_state_members : members :=
  match mario_ce ! M._MarioState with
  | Some composite => co_members composite
  | None => nil
  end.

Theorem generated_mario_pos_offset :
  field_offset mario_ce M._pos mario_state_members = OK (60, Full).
Proof. vm_compute. reflexivity. Qed.

Theorem generated_float_size :
  sizeof mario_ce (Tfloat F32 noattr) = 4.
Proof. vm_compute. reflexivity. Qed.

Definition mario_y_first_byte_offset : Z := 60 + 4.

Theorem generated_mario_y_first_byte_offset :
  mario_y_first_byte_offset = 64.
Proof. reflexivity. Qed.

Definition generated_layout_claim : Prop :=
  field_offset demo_ce G._timer demo_input_members = OK (0, Full) /\
  sizeof demo_ce (Tstruct G._DemoInput noattr) = 4 /\
  field_offset mario_ce M._pos mario_state_members = OK (60, Full) /\
  sizeof mario_ce (Tfloat F32 noattr) = 4 /\
  mario_y_first_byte_offset = 64.

Theorem generated_layout_certificate : generated_layout_claim.
Proof.
  unfold generated_layout_claim.
  split; [apply generated_demo_timer_offset |].
  split; [apply generated_demo_input_size |].
  split; [apply generated_mario_pos_offset |].
  split; [apply generated_float_size |].
  apply generated_mario_y_first_byte_offset.
Qed.
