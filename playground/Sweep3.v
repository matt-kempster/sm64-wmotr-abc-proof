From Coq Require Import ZArith List Bool String.
From compcert Require Import Integers Floats Values Ctypesdefs.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame.
From SM64.Generated Require behavior_data.
Import ListNotations.
Open Scope Z_scope.
Definition live (s : AST.ident) : bool := existsb (Pos.eqb s) ObjWorld.live_bhvs.
Definition sp (s : AST.ident) : bool := existsb (Pos.eqb s) BhvStep.sp_scripts.
Definition res_nat : list AST.ident :=
  BhvStep.idd (flat_map (fun st =>
    if live (v_s st) then
      filter (fun f => sp (v_s st) || negb (BhvStep.has_null f ObjFrame.self_tab_n)) (BhvStep.cn_st st)
    else []) vm_tab).
Definition cut_reach (f : AST.ident) : list AST.ident :=
  filter (fun x => existsb (Pos.eqb x) ObjWorld.cut_bhvs) (closure_of [f]).
Definition unlive_reach (f : AST.ident) : list AST.ident :=
  filter (fun x => is_bhv_sym x && negb (live x)) (closure_of [f]).
Eval vm_compute in List.length res_nat.
Eval vm_compute in
  map (fun f => (string_of_ident f, map string_of_ident (unlive_reach f)))
      (filter (fun f => match unlive_reach f with [] => false | _ => true end) res_nat).
