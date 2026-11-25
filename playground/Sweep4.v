(* probe (not on the spine): class the live residual natives by what their
   reference closure reaches *)
From Coq Require Import ZArith List Bool String.
From compcert Require Import Integers AST Ctypesdefs.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame NativeSweep.
Import ListNotations.
Open Scope Z_scope.
Definition reach (x : string) (f : ident) : bool := existsb (Pos.eqb (ident_of_string x)) (closure_of [f]).
Definition keys : list string :=
  ["allocate_object"; "unload_object"; "gMarioStates"; "gMarioObject"; "load_object_collision_model";
   "gMarioPlatform"; "cur_obj_nearest_object_with_behavior"; "save_file_set_flags"]%string.
Definition cls (f : ident) : list bool := map (fun x => reach x f) keys.
Eval vm_compute in map (fun f => (string_of_ident f, cls f)) NativeSweep.live_res_natives.
Eval vm_compute in
  map (fun x => (NativeSweep.sname x)) (filter (fun x => negb (NativeSweep.sp (fst (fst x)))) NativeSweep.live_sites).
