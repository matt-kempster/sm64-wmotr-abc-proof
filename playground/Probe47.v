From Coq Require Import ZArith List Bool String.
From compcert Require Import Integers Floats Values Ctypesdefs.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame.
Import ListNotations.
Open Scope Z_scope.
Definition live (s : AST.ident) : bool := existsb (Pos.eqb s) ObjWorld.live_bhvs.
Eval vm_compute in
  map (fun st => (string_of_ident (v_s st), v_i st, opc st, live (v_s st)))
      (filter (fun st => existsb (Z.eqb 47) (fields_of st)) vm_tab).
Eval vm_compute in map string_of_ident ObjWorld.live_bhvs.
Eval vm_compute in map string_of_ident BhvStep.sp_scripts.
