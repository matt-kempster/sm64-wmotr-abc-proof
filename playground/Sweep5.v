(* probe (not on the spine): the live scripts, and who references the star family *)
From Coq Require Import ZArith List Bool String.
From compcert Require Import Integers AST Ctypesdefs.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame NativeSweep.
Import ListNotations.
Open Scope Z_scope.
Eval vm_compute in map string_of_ident ObjWorld.live_bhvs.
Definition fam : list ident := map ident_of_string
  ["bhvStar"; "bhvStarSpawnCoordinates"; "bhvCelebrationStar"; "bhvSpawnedStarNoLevelExit";
   "bhvBowserKey"; "bhvBowserKeyUnlockDoor"; "bhvBowserKeyCourseExit"; "bhvEndToad"; "bhvEndPeach";
   "bhvGrandStar"; "bhvHiddenStarTrigger"; "bhvUnlockDoorStar"]%string.
(* direct referrers: functions / tables / scripts in the closure that mention a family member *)
Eval vm_compute in
  map (fun x => (string_of_ident x, map string_of_ident (filter (fun y => existsb (Pos.eqb y) fam) (refs_of x))))
      (filter (fun x => existsb (fun y => existsb (Pos.eqb y) fam) (refs_of x)) wmotr_closure).
(* live natives sites of family scripts *)
Eval vm_compute in
  map NativeSweep.sname (filter (fun x => existsb (Pos.eqb (fst (fst x))) fam) NativeSweep.live_sites).
