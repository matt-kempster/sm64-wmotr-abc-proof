From Coq Require Import ZArith List Bool.
From compcert Require Import Integers Floats Values.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep.
Import ListNotations.
Open Scope Z_scope.
Eval vm_compute in (match word_at ObjWorld.CANS 6 with Some w =>
  map (fun y => (if Float32.eq_dec (Float32.add (Float32.of_int (Int.repr y)) (BhvStep.f32_of w)) (Float32.of_int (Int.repr (y - 340))) then true else false,
                 existsb (Z.eqb (y - 340 + CANNON_SEAT)) wmotr_cannon_list)) ObjWorld.cannon_lids | None => [] end).
Eval vm_compute in ObjWorld.placed macro_special_objects._bhvCannonClosed.
Eval vm_compute in map (fun '(x, y, z) =>
  (existsb (fun '(x', z', y') => (x =? x') && (z =? z') && (y' =? y + CANNON_SEAT)) wmotr_cannon_xzy,
   existsb (fun '(x', z', y') => (x =? x') && (z =? z') && (y' =? y - 340 + CANNON_SEAT)) wmotr_cannon_xzy,
   existsb (Z.eqb (y + CANNON_SEAT)) wmotr_cannon_list))
  (ObjWorld.placed macro_special_objects._bhvCannonClosed).
Eval vm_compute in List.length wmotr_cannon_xzy.
Eval vm_compute in wmotr_cannon_homes.
Eval vm_compute in filter (fun st => Pos.eqb (v_s st) ObjWorld.CANS) vm_tab.
