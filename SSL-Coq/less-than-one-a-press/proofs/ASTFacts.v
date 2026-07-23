From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Floats Integers.

Import ListNotations.

Fixpoint calls_ident_s (callee : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) _ => Pos.eqb id callee
  | Ssequence a b
  | Sloop a b => calls_ident_s callee a || calls_ident_s callee b
  | Sifthenelse _ a b => calls_ident_s callee a || calls_ident_s callee b
  | Slabel _ body => calls_ident_s callee body
  | Sswitch _ cases => calls_ident_ls callee cases
  | _ => false
  end
with calls_ident_ls (callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_ident_s callee body || calls_ident_ls callee rest
  end.

Fixpoint direct_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence a b
  | Sloop a b => direct_callees_s a ++ direct_callees_s b
  | Sifthenelse _ a b => direct_callees_s a ++ direct_callees_s b
  | Slabel _ body => direct_callees_s body
  | Sswitch _ cases => direct_callees_ls cases
  | _ => []
  end
with direct_callees_ls (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest => direct_callees_s body ++ direct_callees_ls rest
  end.

Fixpoint ident_subsequenceb (wanted found : list ident) : bool :=
  match wanted, found with
  | [], _ => true
  | _, [] => false
  | w :: ws, f :: fs =>
      if Pos.eqb w f
      then ident_subsequenceb ws fs
      else ident_subsequenceb wanted fs
  end.

Fixpoint ident_mem (needle : ident) (ids : list ident) : bool :=
  match ids with
  | [] => false
  | id :: rest => Pos.eqb needle id || ident_mem needle rest
  end.

Fixpoint expression_mentions_ident (needle : ident) (e : expr) : bool :=
  match e with
  | Evar id _ | Etempvar id _ => Pos.eqb id needle
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_ident needle inner
  | Efield inner field _ =>
      expression_mentions_ident needle inner || Pos.eqb field needle
  | Ebinop _ lhs rhs _ =>
      expression_mentions_ident needle lhs || expression_mentions_ident needle rhs
  | _ => false
  end.

Fixpoint expression_mentions_int (needle : Z) (e : expr) : bool :=
  match e with
  | Econst_int value _ => Int.eq value (Int.repr needle)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _
  | Efield inner _ _ => expression_mentions_int needle inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | _ => false
  end.

Fixpoint statement_mentions_ident_s (needle : ident) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_ident needle lhs || expression_mentions_ident needle rhs
  | Sset _ rhs => expression_mentions_ident needle rhs
  | Scall _ fn args =>
      expression_mentions_ident needle fn ||
      existsb (expression_mentions_ident needle) args
  | Sbuiltin _ _ _ args => existsb (expression_mentions_ident needle) args
  | Ssequence a b | Sloop a b =>
      statement_mentions_ident_s needle a || statement_mentions_ident_s needle b
  | Sifthenelse cond a b =>
      expression_mentions_ident needle cond ||
      statement_mentions_ident_s needle a || statement_mentions_ident_s needle b
  | Sreturn (Some value) => expression_mentions_ident needle value
  | Sswitch value cases =>
      expression_mentions_ident needle value ||
      statement_mentions_ident_ls needle cases
  | Slabel _ body => statement_mentions_ident_s needle body
  end
with statement_mentions_ident_ls
    (needle : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_ident_s needle body ||
      statement_mentions_ident_ls needle rest
  end.

Fixpoint statement_mentions_int_s (needle : Z) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign lhs rhs =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | Sset _ rhs => expression_mentions_int needle rhs
  | Scall _ fn args =>
      expression_mentions_int needle fn ||
      existsb (expression_mentions_int needle) args
  | Sbuiltin _ _ _ args => existsb (expression_mentions_int needle) args
  | Ssequence a b | Sloop a b =>
      statement_mentions_int_s needle a || statement_mentions_int_s needle b
  | Sifthenelse cond a b =>
      expression_mentions_int needle cond ||
      statement_mentions_int_s needle a || statement_mentions_int_s needle b
  | Sreturn (Some value) => expression_mentions_int needle value
  | Sswitch value cases =>
      expression_mentions_int needle value || statement_mentions_int_ls needle cases
  | Slabel _ body => statement_mentions_int_s needle body
  end
with statement_mentions_int_ls
    (needle : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_int_s needle body || statement_mentions_int_ls needle rest
  end.

Fixpoint expression_mentions_float32_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_single value _ => Int.eq (Float32.to_bits value) (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_float32_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_float32_bits bits lhs ||
      expression_mentions_float32_bits bits rhs
  | Efield inner _ _ => expression_mentions_float32_bits bits inner
  | _ => false
  end.

Fixpoint expressions_mention_float32_bits
    (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expression_mentions_float32_bits bits arg ||
      expressions_mention_float32_bits bits rest
  end.

Fixpoint statement_mentions_float32_bits_s
    (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expression_mentions_float32_bits bits lhs ||
      expression_mentions_float32_bits bits rhs
  | Sset _ rhs => expression_mentions_float32_bits bits rhs
  | Scall _ fn args =>
      expression_mentions_float32_bits bits fn ||
      expressions_mention_float32_bits bits args
  | Ssequence a b | Sloop a b =>
      statement_mentions_float32_bits_s bits a ||
      statement_mentions_float32_bits_s bits b
  | Sifthenelse cond a b =>
      expression_mentions_float32_bits bits cond ||
      statement_mentions_float32_bits_s bits a ||
      statement_mentions_float32_bits_s bits b
  | Sreturn (Some value) => expression_mentions_float32_bits bits value
  | Sswitch value cases =>
      expression_mentions_float32_bits bits value ||
      statements_mention_float32_bits bits cases
  | Slabel _ body => statement_mentions_float32_bits_s bits body
  | _ => false
  end
with statements_mention_float32_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_float32_bits_s bits body ||
      statements_mention_float32_bits bits rest
  end.

Fixpoint calls_ident_with_float32_arg_s
    (callee : ident) (bits : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) args =>
      Pos.eqb id callee && expressions_mention_float32_bits bits args
  | Ssequence a b | Sloop a b =>
      calls_ident_with_float32_arg_s callee bits a ||
      calls_ident_with_float32_arg_s callee bits b
  | Sifthenelse _ a b =>
      calls_ident_with_float32_arg_s callee bits a ||
      calls_ident_with_float32_arg_s callee bits b
  | Sswitch _ cases =>
      calls_ident_with_float32_arg_ls callee bits cases
  | Slabel _ body => calls_ident_with_float32_arg_s callee bits body
  | _ => false
  end
with calls_ident_with_float32_arg_ls
    (callee : ident) (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_ident_with_float32_arg_s callee bits body ||
      calls_ident_with_float32_arg_ls callee bits rest
  end.

Fixpoint expression_mentions_field (field : ident) (e : expr) : bool :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_field field inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_field field lhs || expression_mentions_field field rhs
  | Efield inner found _ =>
      Pos.eqb found field || expression_mentions_field field inner
  | _ => false
  end.

Fixpoint assigns_through_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => expression_mentions_field field lhs
  | Ssequence a b | Sloop a b =>
      assigns_through_field_s field a || assigns_through_field_s field b
  | Sifthenelse _ a b =>
      assigns_through_field_s field a || assigns_through_field_s field b
  | Sswitch _ cases => assigns_through_field_ls field cases
  | Slabel _ body => assigns_through_field_s field body
  | _ => false
  end
with assigns_through_field_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_through_field_s field body || assigns_through_field_ls field rest
  end.

Fixpoint statement_contains_loop_s (s : statement) : bool :=
  match s with
  | Ssequence a b | Sifthenelse _ a b =>
      statement_contains_loop_s a || statement_contains_loop_s b
  | Sloop _ _ => true
  | Sswitch _ cases => statements_contain_loop cases
  | Slabel _ body => statement_contains_loop_s body
  | _ => false
  end
with statements_contain_loop (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_contains_loop_s body || statements_contain_loop rest
  end.

Definition rhs_has_pressed_operator_shape (rhs : expr) : bool :=
  match rhs with
  | Ebinop Oand _ (Ebinop Oxor _ _ _) _ => true
  | _ => false
  end.

Definition lhs_field_is (field : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield _ found _ => Pos.eqb found field
  | _ => false
  end.

Fixpoint assigns_pressed_operator_shape_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      lhs_field_is field lhs && rhs_has_pressed_operator_shape rhs
  | Ssequence a b | Sloop a b =>
      assigns_pressed_operator_shape_s field a ||
      assigns_pressed_operator_shape_s field b
  | Sifthenelse _ a b =>
      assigns_pressed_operator_shape_s field a ||
      assigns_pressed_operator_shape_s field b
  | Sswitch _ cases => assigns_pressed_operator_shape_ls field cases
  | Slabel _ body => assigns_pressed_operator_shape_s field body
  | _ => false
  end
with assigns_pressed_operator_shape_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_pressed_operator_shape_s field body ||
      assigns_pressed_operator_shape_ls field rest
  end.

Fixpoint assigns_field_named_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lhs_field_is field lhs
  | Ssequence a b | Sloop a b =>
      assigns_field_named_s field a || assigns_field_named_s field b
  | Sifthenelse _ a b =>
      assigns_field_named_s field a || assigns_field_named_s field b
  | Sswitch _ cases => assigns_field_named_ls field cases
  | Slabel _ body => assigns_field_named_s field body
  | _ => false
  end
with assigns_field_named_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_named_s field body || assigns_field_named_ls field rest
  end.

Definition lhs_global_is (global : ident) (lhs : expr) : bool :=
  match lhs with
  | Evar found _ => Pos.eqb found global
  | _ => false
  end.

Fixpoint assigns_global_ident_s (global : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lhs_global_is global lhs
  | Ssequence a b | Sloop a b =>
      assigns_global_ident_s global a || assigns_global_ident_s global b
  | Sifthenelse _ a b =>
      assigns_global_ident_s global a || assigns_global_ident_s global b
  | Sswitch _ cases => assigns_global_ident_ls global cases
  | Slabel _ body => assigns_global_ident_s global body
  | _ => false
  end
with assigns_global_ident_ls
    (global : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_global_ident_s global body || assigns_global_ident_ls global rest
  end.

Definition initializer_mentions_addrof (needle : ident) (datum : init_data) : bool :=
  match datum with
  | Init_addrof found _ => Pos.eqb found needle
  | _ => false
  end.

Definition initializer_list_mentions_addrof
    (needle : ident) (values : list init_data) : bool :=
  existsb (initializer_mentions_addrof needle) values.

Fixpoint init_int16_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int16 value :: rest => Int.signed value :: init_int16_values rest
  | _ :: rest => init_int16_values rest
  end.

Fixpoint chunks5 (values : list Z) : list (list Z) :=
  match values with
  | a :: b :: c :: d :: e :: rest => [a; b; c; d; e] :: chunks5 rest
  | _ => []
  end.

Definition record_starts_with (tag : Z) (record : list Z) : bool :=
  match record with
  | found :: _ => Z.eqb found tag
  | [] => false
  end.

Definition records_with_tag (tag : Z) (values : list init_data) : list (list Z) :=
  filter (record_starts_with tag) (chunks5 (init_int16_values values)).
