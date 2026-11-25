From Coq Require Import ZArith List Bool String.
From compcert Require Import Integers Floats Values Ctypesdefs.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame.
Import ListNotations.
Open Scope Z_scope.
(* the lid's reachable VM states: index, opcode, successors' indices *)
Eval vm_compute in
  map (fun st => (v_i st, List.length (v_k st), opc st,
                  match succs st with Some l => map v_i l | None => [] end))
      (filter (fun st => Pos.eqb (v_s st) ObjWorld.LIDS) vm_tab).
Eval vm_compute in existsb (Pos.eqb ObjWorld.LIDS) BhvStep.sp_scripts.
Eval vm_compute in existsb (Pos.eqb ObjWorld.LIDS) ObjWorld.live_bhvs.
Eval vm_compute in ObjWorld.cannon_lid_xyz.
Eval vm_compute in BhvStep.brk_ops.
