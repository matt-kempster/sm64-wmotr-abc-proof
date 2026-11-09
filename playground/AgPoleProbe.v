From Coq Require Import ZArith List.
From SM64.Generated Require behavior_data.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Proofs.WMotRRequiresA Require ObjWorld.
Import ListNotations.
Local Open Scope Z_scope.

Eval vm_compute in map (fun i => option_map (fun w => (Z.shiftr w 24, byte2 w, Z.land w 65535)) (word_at behavior_data._bhvPoleGrabbing i))
  [0;1;2;3;4;5;6;7;8;9;10;11]%nat.
Eval vm_compute in (List.length (filter (fun st => Pos.eqb (v_s st) behavior_data._bhvPoleGrabbing) vm_tab)).
Eval vm_compute in (map v_i (filter (fun st => Pos.eqb (v_s st) behavior_data._bhvPoleGrabbing) vm_tab)).
Eval vm_compute in (existsb (Pos.eqb behavior_data._bhvPoleGrabbing) ObjWorld.live_bhvs).
