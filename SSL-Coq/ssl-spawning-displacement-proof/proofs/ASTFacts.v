From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Ctypes Clight Integers.

Import ListNotations.

Fixpoint calls_ident_s (callee : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) _ => Pos.eqb id callee
  | Ssequence s1 s2 =>
      calls_ident_s callee s1 || calls_ident_s callee s2
  | Sifthenelse _ s1 s2 =>
      calls_ident_s callee s1 || calls_ident_s callee s2
  | Sloop s1 s2 =>
      calls_ident_s callee s1 || calls_ident_s callee s2
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
  | Ssequence s1 s2 =>
      direct_callees_s s1 ++ direct_callees_s s2
  | Sifthenelse _ s1 s2 =>
      direct_callees_s s1 ++ direct_callees_s s2
  | Sloop s1 s2 =>
      direct_callees_s s1 ++ direct_callees_s s2
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

Fixpoint expression_mentions_ident (needle : ident) (e : expr) : bool :=
  match e with
  | Evar id _ => Pos.eqb id needle
  | Etempvar id _ => Pos.eqb id needle
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ =>
      expression_mentions_ident needle inner
  | Efield inner field _ =>
      expression_mentions_ident needle inner || Pos.eqb field needle
  | Ebinop _ lhs rhs _ =>
      expression_mentions_ident needle lhs ||
      expression_mentions_ident needle rhs
  | Esizeof _ _ | Ealignof _ _ | Econst_int _ _
  | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ =>
      false
  end.

Fixpoint expression_mentions_int (needle : Z) (e : expr) : bool :=
  match e with
  | Econst_int found _ => Int.eq found (Int.repr needle)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ | Efield inner _ _ =>
      expression_mentions_int needle inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_int needle lhs ||
      expression_mentions_int needle rhs
  | Evar _ _ | Etempvar _ _ | Esizeof _ _ | Ealignof _ _
  | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ =>
      false
  end.

Fixpoint statement_mentions_ident_s (needle : ident) (s : statement) : bool :=
  match s with
  | Sskip => false
  | Sassign lhs rhs =>
      expression_mentions_ident needle lhs ||
      expression_mentions_ident needle rhs
  | Sset _ rhs => expression_mentions_ident needle rhs
  | Scall _ fn args =>
      expression_mentions_ident needle fn ||
      existsb (expression_mentions_ident needle) args
  | Sbuiltin _ _ _ args =>
      existsb (expression_mentions_ident needle) args
  | Ssequence s1 s2 =>
      statement_mentions_ident_s needle s1 ||
      statement_mentions_ident_s needle s2
  | Sifthenelse cond s1 s2 =>
      expression_mentions_ident needle cond ||
      statement_mentions_ident_s needle s1 ||
      statement_mentions_ident_s needle s2
  | Sloop s1 s2 =>
      statement_mentions_ident_s needle s1 ||
      statement_mentions_ident_s needle s2
  | Sbreak | Scontinue | Sreturn None => false
  | Sreturn (Some e) => expression_mentions_ident needle e
  | Sswitch e cases =>
      expression_mentions_ident needle e ||
      statement_mentions_ident_ls needle cases
  | Slabel _ body => statement_mentions_ident_s needle body
  | Sgoto _ => false
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
  | Sskip => false
  | Sassign lhs rhs =>
      expression_mentions_int needle lhs || expression_mentions_int needle rhs
  | Sset _ rhs => expression_mentions_int needle rhs
  | Scall _ fn args =>
      expression_mentions_int needle fn ||
      existsb (expression_mentions_int needle) args
  | Sbuiltin _ _ _ args =>
      existsb (expression_mentions_int needle) args
  | Ssequence s1 s2 =>
      statement_mentions_int_s needle s1 ||
      statement_mentions_int_s needle s2
  | Sifthenelse cond s1 s2 =>
      expression_mentions_int needle cond ||
      statement_mentions_int_s needle s1 ||
      statement_mentions_int_s needle s2
  | Sloop s1 s2 =>
      statement_mentions_int_s needle s1 ||
      statement_mentions_int_s needle s2
  | Sbreak | Scontinue | Sreturn None => false
  | Sreturn (Some e) => expression_mentions_int needle e
  | Sswitch e cases =>
      expression_mentions_int needle e ||
      statement_mentions_int_ls needle cases
  | Slabel _ body => statement_mentions_int_s needle body
  | Sgoto _ => false
  end
with statement_mentions_int_ls
       (needle : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_int_s needle body ||
      statement_mentions_int_ls needle rest
  end.

Fixpoint assigns_field_named_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign (Efield _ found _) _ => Pos.eqb found field
  | Ssequence s1 s2 =>
      assigns_field_named_s field s1 ||
      assigns_field_named_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_field_named_s field s1 ||
      assigns_field_named_s field s2
  | Sloop s1 s2 =>
      assigns_field_named_s field s1 ||
      assigns_field_named_s field s2
  | Slabel _ body => assigns_field_named_s field body
  | Sswitch _ cases => assigns_field_named_ls field cases
  | _ => false
  end
with assigns_field_named_ls
       (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_named_s field body ||
      assigns_field_named_ls field rest
  end.

Fixpoint expression_is_zero (e : expr) : bool :=
  match e with
  | Econst_int found _ => Int.eq found Int.zero
  | Ecast inner _ => expression_is_zero inner
  | _ => false
  end.

Fixpoint assigns_field_zero_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign (Efield _ found _) rhs =>
      Pos.eqb found field && expression_is_zero rhs
  | Ssequence s1 s2 =>
      assigns_field_zero_s field s1 || assigns_field_zero_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_field_zero_s field s1 || assigns_field_zero_s field s2
  | Sloop s1 s2 =>
      assigns_field_zero_s field s1 || assigns_field_zero_s field s2
  | Slabel _ body => assigns_field_zero_s field body
  | Sswitch _ cases => assigns_field_zero_ls field cases
  | _ => false
  end
with assigns_field_zero_ls
       (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_zero_s field body || assigns_field_zero_ls field rest
  end.

Fixpoint assigns_field_from_ident_s
    (field source : ident) (s : statement) : bool :=
  match s with
  | Sassign (Efield _ found _) rhs =>
      Pos.eqb found field && expression_mentions_ident source rhs
  | Ssequence s1 s2 =>
      assigns_field_from_ident_s field source s1 ||
      assigns_field_from_ident_s field source s2
  | Sifthenelse _ s1 s2 =>
      assigns_field_from_ident_s field source s1 ||
      assigns_field_from_ident_s field source s2
  | Sloop s1 s2 =>
      assigns_field_from_ident_s field source s1 ||
      assigns_field_from_ident_s field source s2
  | Slabel _ body => assigns_field_from_ident_s field source body
  | Sswitch _ cases => assigns_field_from_ident_ls field source cases
  | _ => false
  end
with assigns_field_from_ident_ls
       (field source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_from_ident_s field source body ||
      assigns_field_from_ident_ls field source rest
  end.

Definition sequence_copies_field_via_temp
    (target source : ident) (first second : statement) : bool :=
  match first, second with
  | Sset written_temp (Efield _ found_source _),
    Sassign (Efield _ found_target _) (Etempvar read_temp _) =>
      Pos.eqb found_source source &&
      Pos.eqb found_target target &&
      Pos.eqb written_temp read_temp
  | _, _ => false
  end.

Fixpoint copies_field_via_temp_s
    (target source : ident) (s : statement) : bool :=
  match s with
  | Ssequence s1 s2 =>
      sequence_copies_field_via_temp target source s1 s2 ||
      copies_field_via_temp_s target source s1 ||
      copies_field_via_temp_s target source s2
  | Sifthenelse _ s1 s2 =>
      copies_field_via_temp_s target source s1 ||
      copies_field_via_temp_s target source s2
  | Sloop s1 s2 =>
      copies_field_via_temp_s target source s1 ||
      copies_field_via_temp_s target source s2
  | Slabel _ body => copies_field_via_temp_s target source body
  | Sswitch _ cases => copies_field_via_temp_ls target source cases
  | _ => false
  end
with copies_field_via_temp_ls
       (target source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      copies_field_via_temp_s target source body ||
      copies_field_via_temp_ls target source rest
  end.

Fixpoint statement_contains_break_s (s : statement) : bool :=
  match s with
  | Sbreak => true
  | Ssequence s1 s2 =>
      statement_contains_break_s s1 || statement_contains_break_s s2
  | Sifthenelse _ s1 s2 =>
      statement_contains_break_s s1 || statement_contains_break_s s2
  | Sloop s1 s2 =>
      statement_contains_break_s s1 || statement_contains_break_s s2
  | Slabel _ body => statement_contains_break_s body
  | Sswitch _ cases => statement_contains_break_ls cases
  | _ => false
  end
with statement_contains_break_ls (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_contains_break_s body || statement_contains_break_ls rest
  end.

Fixpoint returns_int_s (value : Z) (s : statement) : bool :=
  match s with
  | Sreturn (Some (Econst_int found _)) =>
      Int.eq found (Int.repr value)
  | Ssequence s1 s2 => returns_int_s value s1 || returns_int_s value s2
  | Sifthenelse _ s1 s2 =>
      returns_int_s value s1 || returns_int_s value s2
  | Sloop s1 s2 => returns_int_s value s1 || returns_int_s value s2
  | Slabel _ body => returns_int_s value body
  | Sswitch _ cases => returns_int_ls value cases
  | _ => false
  end
with returns_int_ls (value : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      returns_int_s value body || returns_int_ls value rest
  end.

Definition internal_functions
    (definitions : list (ident * globdef fundef type))
    : list (ident * function) :=
  fold_right
    (fun definition acc =>
       match definition with
       | (id, Gfun (Internal body)) => (id, body) :: acc
       | _ => acc
       end)
    [] definitions.

Definition direct_field_writers
    (program : Clight.program) (field : ident) : list ident :=
  map fst
    (filter
      (fun named_function =>
         assigns_field_named_s field (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Definition direct_callers
    (program : Clight.program) (callee : ident) : list ident :=
  map fst
    (filter
      (fun named_function =>
         calls_ident_s callee (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Fixpoint ident_subsequenceb (needle haystack : list ident) : bool :=
  match needle with
  | [] => true
  | wanted :: rest =>
      match haystack with
      | [] => false
      | found :: haystack_rest =>
          if Pos.eqb wanted found
          then ident_subsequenceb rest haystack_rest
          else ident_subsequenceb needle haystack_rest
      end
  end.

Fixpoint ident_index (needle : ident) (haystack : list ident) : option nat :=
  match haystack with
  | [] => None
  | found :: rest =>
      if Pos.eqb needle found
      then Some 0%nat
      else option_map S (ident_index needle rest)
  end.

Definition initializer_mentions_addrof
    (needle : ident) (data : init_data) : bool :=
  match data with
  | Init_addrof found _ => Pos.eqb found needle
  | _ => false
  end.

Definition initializer_mentions_int (needle : Z) (data : init_data) : bool :=
  match data with
  | Init_int8 found | Init_int16 found | Init_int32 found =>
      Int.eq found (Int.repr needle)
  | _ => false
  end.

Definition initializer_list_mentions_addrof
    (needle : ident) (init : list init_data) : bool :=
  existsb (initializer_mentions_addrof needle) init.

Definition initializer_list_mentions_int
    (needle : Z) (init : list init_data) : bool :=
  existsb (initializer_mentions_int needle) init.

Definition initializer_addrofs (init : list init_data) : list ident :=
  fold_right
    (fun data acc =>
       match data with
       | Init_addrof found _ => found :: acc
       | _ => acc
       end)
    [] init.

Definition program_global_initializer
    (program : Clight.program) (needle : ident) : option (list init_data) :=
  fold_right
    (fun definition acc =>
       match definition with
       | (found, Gvar variable) =>
           if Pos.eqb found needle then Some (gvar_init variable) else acc
       | _ => acc
       end)
    None (prog_defs program).
