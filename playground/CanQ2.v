From Coq Require Import ZArith List Bool.
From compcert Require Import Integers Floats Values.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep.
From SM64.Generated Require behavior_data.
Import ListNotations.
Open Scope Z_scope.
(* bhvCannon's words: (index, opcode, byte2, low16) *)
Eval vm_compute in map (fun i => (i, option_map (fun w => (Z.shiftr w 24, byte2 w, Z.land w 65535))
                    (word_at behavior_data._bhvCannon i))) (seq 0 16).
(* the VM states of bhvCannon in vm_tab *)
Eval vm_compute in map (fun st => (v_i st, length (v_k st)))
  (filter (fun st => Pos.eqb (v_s st) behavior_data._bhvCannon) vm_tab).
Eval vm_compute in map (fun st => (v_i st, succs st))
  (filter (fun st => Pos.eqb (v_s st) behavior_data._bhvCannon) vm_tab).
