From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Ctypes Clight Integers.
From DemoWarp.Generated Require Import game_init os_cont_start_read_data.

Import ListNotations.
Module G := game_init.
Module O := os_cont_start_read_data.

Inductive controller_lvalue_shape : Type :=
| Controller_local_response
| Controller_pad_field
| Controller_other.

Definition classify_controller_lvalue (lhs : expr) : controller_lvalue_shape :=
  match lhs with
  | Evar found _ =>
      if Pos.eqb found O._response
      then Controller_local_response
      else Controller_other
  | Efield
      (Ederef (Etempvar base _) (Tstruct struct_id _)) _ _ =>
      if Pos.eqb base O._pad && Pos.eqb struct_id O.__319
      then Controller_pad_field
      else Controller_other
  | _ => Controller_other
  end.

Fixpoint controller_lvalues_s (s : statement) : list controller_lvalue_shape :=
  (match s with
   | Sassign lhs _ => [classify_controller_lvalue lhs]
   | _ => []
   end) ++
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => controller_lvalues_s first ++ controller_lvalues_s second
  | Slabel _ body => controller_lvalues_s body
  | Sswitch _ cases => controller_lvalues_ls cases
  | _ => []
  end
with controller_lvalues_ls (cases : labeled_statements)
    : list controller_lvalue_shape :=
  match cases with
  | LSnil => []
  | LScons _ body rest => controller_lvalues_s body ++ controller_lvalues_ls rest
  end.

Fixpoint calls_any_s (s : statement) : bool :=
  (match s with Scall _ _ _ | Sbuiltin _ _ _ _ => true | _ => false end) ||
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second => calls_any_s first || calls_any_s second
  | Slabel _ body => calls_any_s body
  | Sswitch _ cases => calls_any_ls cases
  | _ => false
  end
with calls_any_ls (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => calls_any_s body || calls_any_ls rest
  end.

Fixpoint controller_read_call_count_s (s : statement) : nat :=
  (match s with
   | Scall None (Evar callee _)
       [Ebinop Oadd (Evar pads _) (Econst_int zero _) _] =>
       if Pos.eqb callee G._osContGetReadData &&
          Pos.eqb pads G._gControllerPads && Int.eq zero Int.zero
       then 1%nat else 0%nat
   | _ => 0%nat
   end) +
  match s with
  | Ssequence first second
  | Sifthenelse _ first second
  | Sloop first second =>
      controller_read_call_count_s first + controller_read_call_count_s second
  | Slabel _ body => controller_read_call_count_s body
  | Sswitch _ cases => controller_read_call_count_ls cases
  | _ => 0%nat
  end
with controller_read_call_count_ls (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      controller_read_call_count_s body + controller_read_call_count_ls rest
  end.

Theorem generated_controller_parser_store_surface :
  controller_lvalues_s (fn_body O.f_osContGetReadData) =
    [Controller_local_response;
     Controller_pad_field;
     Controller_pad_field;
     Controller_pad_field;
     Controller_pad_field].
Proof. vm_compute. reflexivity. Qed.

Theorem generated_controller_parser_is_call_free :
  calls_any_s (fn_body O.f_osContGetReadData) = false.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_game_passes_controller_pad_global :
  controller_read_call_count_s (fn_body G.f_read_controller_inputs) = 1%nat.
Proof. vm_compute. reflexivity. Qed.

Definition generated_controller_input_surface_claim : Prop :=
  controller_lvalues_s (fn_body O.f_osContGetReadData) =
    [Controller_local_response;
     Controller_pad_field;
     Controller_pad_field;
     Controller_pad_field;
     Controller_pad_field] /\
  calls_any_s (fn_body O.f_osContGetReadData) = false /\
  controller_read_call_count_s (fn_body G.f_read_controller_inputs) = 1%nat.

Theorem generated_controller_input_surface_certificate :
  generated_controller_input_surface_claim.
Proof.
  exact (conj generated_controller_parser_store_surface
    (conj generated_controller_parser_is_call_free
      generated_game_passes_controller_pad_global)).
Qed.
