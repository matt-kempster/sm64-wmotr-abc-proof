From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Floats Integers.
From SSLEyerok.Generated Require behavior_script eyerok_model
  obj_behaviors_2 object_helpers object_list_processor.

Import ListNotations.

Fixpoint expr_mentions_int_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_int value _ => Int.eq value (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_int_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_int_bits bits lhs || expr_mentions_int_bits bits rhs
  | Efield inner _ _ => expr_mentions_int_bits bits inner
  | _ => false
  end.

Fixpoint exprs_mentions_int_bits (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_int_bits bits arg || exprs_mentions_int_bits bits rest
  end.

Fixpoint stmt_mentions_int_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expr_mentions_int_bits bits lhs || expr_mentions_int_bits bits rhs
  | Sset _ rhs => expr_mentions_int_bits bits rhs
  | Scall _ fn args =>
      expr_mentions_int_bits bits fn || exprs_mentions_int_bits bits args
  | Ssequence s1 s2 =>
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_int_bits bits test ||
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sloop s1 s2 =>
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sreturn (Some value) => expr_mentions_int_bits bits value
  | Sswitch key cases =>
      expr_mentions_int_bits bits key || cases_mentions_int_bits bits cases
  | Slabel _ body => stmt_mentions_int_bits bits body
  | _ => false
  end
with cases_mentions_int_bits (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_int_bits bits body || cases_mentions_int_bits bits rest
  end.

Fixpoint expr_count_single (e : expr) : nat :=
  match e with
  | Econst_single _ _ => 1%nat
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_count_single inner
  | Ebinop _ lhs rhs _ =>
      (expr_count_single lhs + expr_count_single rhs)%nat
  | Efield inner _ _ => expr_count_single inner
  | _ => 0%nat
  end.

Fixpoint exprs_count_single (args : list expr) : nat :=
  match args with
  | [] => 0%nat
  | arg :: rest =>
      (expr_count_single arg + exprs_count_single rest)%nat
  end.

Fixpoint stmt_count_single (s : statement) : nat :=
  match s with
  | Sassign lhs rhs =>
      (expr_count_single lhs + expr_count_single rhs)%nat
  | Sset _ rhs => expr_count_single rhs
  | Scall _ fn args =>
      (expr_count_single fn + exprs_count_single args)%nat
  | Ssequence s1 s2 =>
      (stmt_count_single s1 + stmt_count_single s2)%nat
  | Sifthenelse test s1 s2 =>
      (expr_count_single test + stmt_count_single s1 + stmt_count_single s2)%nat
  | Sloop s1 s2 =>
      (stmt_count_single s1 + stmt_count_single s2)%nat
  | Sreturn (Some value) => expr_count_single value
  | Sswitch key cases =>
      (expr_count_single key + cases_count_single cases)%nat
  | Slabel _ body => stmt_count_single body
  | _ => 0%nat
  end
with cases_count_single (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (stmt_count_single body + cases_count_single rest)%nat
  end.

Fixpoint expr_mentions_neg (e : expr) : bool :=
  match e with
  | Eunop _ _ _ => true
  | Ederef inner _ | Eaddrof inner _ | Ecast inner _ =>
      expr_mentions_neg inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_neg lhs || expr_mentions_neg rhs
  | Efield inner _ _ => expr_mentions_neg inner
  | _ => false
  end.

Fixpoint stmt_mentions_neg (s : statement) : bool :=
  match s with
  | Sassign lhs rhs => expr_mentions_neg lhs || expr_mentions_neg rhs
  | Sset _ rhs => expr_mentions_neg rhs
  | Scall _ fn _ => expr_mentions_neg fn
  | Ssequence s1 s2 => stmt_mentions_neg s1 || stmt_mentions_neg s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_neg test || stmt_mentions_neg s1 || stmt_mentions_neg s2
  | Sloop s1 s2 => stmt_mentions_neg s1 || stmt_mentions_neg s2
  | Sreturn (Some value) => expr_mentions_neg value
  | Sswitch key cases => expr_mentions_neg key || cases_mentions_neg cases
  | Slabel _ body => stmt_mentions_neg body
  | _ => false
  end
with cases_mentions_neg (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => stmt_mentions_neg body || cases_mentions_neg rest
  end.

Fixpoint direct_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Sifthenelse _ s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Sloop s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Slabel _ body => direct_callees_s body
  | Sswitch _ cases => direct_callees_ls cases
  | _ => []
  end
with direct_callees_ls (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest => direct_callees_s body ++ direct_callees_ls rest
  end.

Fixpoint ident_mem (needle : ident) (ids : list ident) : bool :=
  match ids with
  | [] => false
  | id :: rest => Pos.eqb needle id || ident_mem needle rest
  end.

Definition generated_model_shape : Prop :=
  stmt_mentions_int_bits 896 (fn_body eyerok_model.f_eyerok_support_ceiling) = true /\
  stmt_mentions_int_bits 1703 (fn_body eyerok_model.f_eyerok_support_ceiling) = true /\
  stmt_mentions_int_bits 1196 (fn_body eyerok_model.f_eyerok_height_ceiling) = true /\
  stmt_mentions_int_bits 2003 (fn_body eyerok_model.f_eyerok_height_ceiling) = true /\
  stmt_mentions_int_bits 98 (fn_body eyerok_model.f_eyerok_action_ascent_budget) = true /\
  stmt_mentions_int_bits 288 (fn_body eyerok_model.f_eyerok_action_ascent_budget) = true /\
  stmt_mentions_int_bits 285 (fn_body eyerok_model.f_eyerok_action_ascent_budget) = true /\
  stmt_mentions_int_bits 100 (fn_body eyerok_model.f_eyerok_runaway_frame) = true /\
  stmt_mentions_int_bits 300 (fn_body eyerok_model.f_eyerok_safe_envelope) = true.

Theorem generated_model_shape_holds : generated_model_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition generated_critical_source_shape : Prop :=
  stmt_count_single
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = 4%nat /\
  stmt_mentions_neg
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = true /\
  stmt_count_single
    (fn_body obj_behaviors_2.f_eyerok_hand_act_double_pound) = 7%nat /\
  stmt_mentions_neg
    (fn_body obj_behaviors_2.f_eyerok_hand_act_double_pound) = true /\
  ident_mem obj_behaviors_2._cur_obj_move_standard
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  stmt_count_single
    (fn_body object_helpers.f_cur_obj_move_y_and_get_water_level) = 2%nat /\
  stmt_mentions_neg
    (fn_body object_helpers.f_cur_obj_move_y_and_get_water_level) = true /\
  ident_mem object_helpers._cur_obj_move_y
    (direct_callees_s (fn_body object_helpers.f_cur_obj_move_standard)) = true /\
  ident_mem object_list_processor._clear_dynamic_surfaces
    (direct_callees_s (fn_body object_list_processor.f_update_objects)) = true.

Theorem generated_critical_source_shape_holds : generated_critical_source_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.
