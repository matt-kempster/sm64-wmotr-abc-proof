From Coq Require Import ZArith List Bool.
From compcert Require Import Integers Floats Values.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep.
From SM64.Generated Require behavior_data.
Import ListNotations.
Open Scope Z_scope.
Definition hits : list (positive * nat * Z * Z) :=
  map (fun st => (v_s st, v_i st, opc st, byte2 (w0 st)))
    (filter (fun st => (existsb (Z.eqb (opc st)) [13; 31; 20; 21; 19; 47; 16])
                       && existsb (Z.eqb (byte2 (w0 st))) [6; 7; 8; 27; 35; 36; 37; 42; 49]) vm_tab).
(* which are special scripts *)
Eval vm_compute in map (fun '(s, i, op, f) => (s, i, op, f, existsb (Pos.eqb s) BhvStep.sp_scripts)) hits.
Eval vm_compute in map (fun '(s, i, op, f) =>
   (s, i, op, f,
    [Pos.eqb s behavior_data._bhvExclamationBox; Pos.eqb s behavior_data._bhvJumpingBox;
     Pos.eqb s behavior_data._bhvCannonClosed; Pos.eqb s behavior_data._bhvHiddenRedCoinStar;
     Pos.eqb s behavior_data._bhvPoleGrabbing; Pos.eqb s behavior_data._bhvCannon; Pos.eqb s behavior_data._bhvMario]))
  (filter (fun '(s, _, _, _) => existsb (Pos.eqb s) BhvStep.sp_scripts) hits).
Eval vm_compute in map (fun s => (s, [Pos.eqb s behavior_data._bhvExclamationBox; Pos.eqb s behavior_data._bhvJumpingBox;
     Pos.eqb s behavior_data._bhvCannonClosed; Pos.eqb s behavior_data._bhvHiddenRedCoinStar;
     Pos.eqb s behavior_data._bhvPoleGrabbing; Pos.eqb s behavior_data._bhvCannon; Pos.eqb s behavior_data._bhvMario])) BhvStep.sp_scripts.
