From Coq Require Import ZArith List Bool.
From compcert Require Import Integers Floats Values.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame.
From SM64.Generated Require behavior_data.
Import ListNotations.
Open Scope Z_scope.
Definition live (s : AST.ident) : bool := existsb (Pos.eqb s) ObjWorld.live_bhvs.
Definition sp (s : AST.ident) : bool := existsb (Pos.eqb s) BhvStep.sp_scripts.
(* every CALL_NATIVE site: (script, word, native, special?, live?, bulk?) *)
Definition sites : list (AST.ident * nat * AST.ident * bool * bool * bool) :=
  flat_map (fun st => map (fun f => (v_s st, v_i st, f, sp (v_s st), live (v_s st),
                                     BhvStep.has_null f ObjFrame.self_tab_n)) (BhvStep.cn_st st)) vm_tab.
Fixpoint dd (l : list (AST.ident * nat * AST.ident * bool * bool * bool)) :=
  match l with [] => [] | x :: l' =>
    if existsb (fun y => let '(s, i, f, _, _, _) := x in let '(s', i', f', _, _, _) := y in
                         Pos.eqb s s' && Nat.eqb i i' && Pos.eqb f f') l' then dd l' else x :: dd l' end.
Eval vm_compute in filter (fun '(s, i, f, a, b, c) => (a || negb c)) (dd sites).
