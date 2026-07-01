From Coq Require Import Bool List PArith.BinPos.
From compcert Require Import AST Ctypes Clight.

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
  | Ecast inner _ | Efield inner _ _ =>
      expression_mentions_ident needle inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_ident needle lhs ||
      expression_mentions_ident needle rhs
  | Esizeof _ _ | Ealignof _ _ | Econst_int _ _
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
