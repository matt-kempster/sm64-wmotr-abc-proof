From Coq Require Import List PArith.BinPos.
From compcert Require Import AST Clight.
From SSLPU.Generated Require Import pu_model.

Import ListNotations.

Fixpoint direct_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Sifthenelse _ s1 s2 =>
      direct_callees_s s1 ++ direct_callees_s s2
  | Sloop s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Slabel _ body => direct_callees_s body
  | Sswitch _ cases => direct_callees_ls cases
  | _ => []
  end
with direct_callees_ls (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      direct_callees_s body ++ direct_callees_ls rest
  end.

Definition lvalue_top_field (e : expr) : option ident :=
  match e with
  | Efield _ field _ => Some field
  | _ => None
  end.

Fixpoint assigns_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ =>
      match lvalue_top_field lhs with
      | Some found => Pos.eqb found field
      | None => false
      end
  | Ssequence s1 s2 =>
      assigns_field_s field s1 || assigns_field_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_field_s field s1 || assigns_field_s field s2
  | Sloop s1 s2 =>
      assigns_field_s field s1 || assigns_field_s field s2
  | Slabel _ body => assigns_field_s field body
  | Sswitch _ cases => assigns_field_ls field cases
  | _ => false
  end
with assigns_field_ls (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_s field body || assigns_field_ls field rest
  end.

Record generated_pu_model_shape : Prop := {
  shape_coord_detector_calls_abs :
    direct_callees_s (fn_body f_is_parallel_universe_coord) =
      [_pu_abs];
  shape_state_detector_checks_x_then_z :
    direct_callees_s (fn_body f_in_parallel_universe) =
      [_is_parallel_universe_coord; _is_parallel_universe_coord];
  shape_normal_step_clamps_deltas_and_coordinates :
    direct_callees_s (fn_body f_ssl_area2_normal_step) =
      [_clamp_normal_step; _clamp_normal_step;
       _clamp_area2_coord; _clamp_area2_coord];
  shape_capstone_calls_step_then_detector :
    direct_callees_s
      (fn_body f_ssl_area2_step_enters_parallel_universe) =
      [_ssl_area2_normal_step; _in_parallel_universe];
  shape_normal_step_does_not_assign_area :
    assigns_field_s _area (fn_body f_ssl_area2_normal_step) = false;
  shape_normal_step_assigns_x :
    assigns_field_s _x (fn_body f_ssl_area2_normal_step) = true;
  shape_normal_step_assigns_z :
    assigns_field_s _z (fn_body f_ssl_area2_normal_step) = true
}.

Theorem generated_pu_model_shape_holds :
  generated_pu_model_shape.
Proof.
  constructor; reflexivity.
Qed.
