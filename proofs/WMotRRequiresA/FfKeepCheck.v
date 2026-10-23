(* ====================================================================== *)
(* FfKeepCheck (GOAL 2): the syntactic check that an outcome of the walk  *)
(* of act_freefall keeps the frame world (FrameSplit.fworld).  It runs on  *)
(* every outcome of the same walk as FfClass.ff_ok (FfRun.ffcheck12);      *)
(* FfKeep proves what it means.                                           *)
(*                                                                        *)
(* An outcome passes when                                                 *)
(*   - the action is a constant on GOAL 2's no-A list (NoAActions), and   *)
(*     not a pole action or ACT_IN_CANNON (WMotRWorld.used_acts: those    *)
(*     need usedObj facts the walks do not track);                        *)
(*   - the cells the frame world reads and the walk must not touch are    *)
(*     their entry cells: m->input, ceil, heldObj, riddenObj, marioObj,    *)
(*     area, controller, animList, quicksandDepth; the anim list's buffer *)
(*     pointer; Mario's object's interactStatus, numCollidedObjs,         *)
(*     collidedObjs[4], interactType, oPosY and hitbox fields;            *)
(*   - m->floor is the entry cell or a find_floor surface (a world fact   *)
(*     and FloorExec's surface fact);                                     *)
(*   - m->wall is the entry cell, NULL, or a find_wall_collisions surface *)
(*     (a world fact and the surface fact);                               *)
(*   - only the DMA regions are clobbered.                                *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib AST Integers Values Memory.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import FloorExec AirMatch NoAActions WMotRWorld.
Import ListNotations.

Definition SZ_SURF : Z := 48.

Section FK.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO rLD kS : positive) (clok : list positive).

(* the cells the walk must leave as they were *)
Definition fk_same : list (positive * Z * memory_chunk) :=
  [(rM, 2, Mint16unsigned); (rM, 100, Mint32); (rM, 124, Mint32); (rM, 132, Mint32);
   (rM, 136, Mint32); (rM, 144, Mint32); (rM, 156, Mint32); (rM, 160, Mint32);
   (rM, 192, Mfloat32); (rM, 148, Mint32); (rLD, 8, Mint32); (rLD, 0, Mint32);
   (rO, O_INTERACT_STATUS, Mint32); (rO, NUMCOLL_OFF, Mint16signed);
   (rO, COLL_OFF, Mint32); (rO, COLL_OFF + 4, Mint32); (rO, COLL_OFF + 8, Mint32);
   (rO, COLL_OFF + 12, Mint32);
   (rO, O_INTERACT_TYPE, Mint32); (rO, O_POSY, Mfloat32); (rO, HITBOX_DOWN_OFF, Mfloat32);
   (rO, HITBOX_H_OFF, Mfloat32)].

Definition has (pc : list fact) (f : fact) : bool := existsb (fbeq f) pc.

Definition fk_ok (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  let same (k : positive * Z * memory_chunk) :=
    let '(r, o, ch) := k in
    match LD r o ch with Some a => sveqb a (init_cell kv r o ch) | None => false end in
  let surf (p : sval) := has (g_pc g) (Fuser kS (p :: wargs R0)) in
  match LD rM 12 Mint32 with
  | Some (Sconst (Vint a)) => existsb (Z.eqb (Int.unsigned a)) R_noA_list
                              && negb (existsb (Z.eqb (Int.unsigned a)) used_acts)
  | _ => false
  end
  && forallb same fk_same
  && match LD rM 104 Mint32 with
     | Some p => sveqb p (init_cell kv rM 104 Mint32) || (has (g_pc g) (Fworld p SZ_SURF) && surf p)
     | None => false
     end
  && match LD rM 96 Mint32 with
     | Some p => sveqb p (init_cell kv rM 96 Mint32) || sveqb p (Sconst (Vint Int.zero))
                 || (has (g_pc g) (Fworld p SZ_SURF) && surf p)
     | None => false
     end
  && forallb (fun r => existsb (Pos.eqb r) clok) (g_cl g).
End FK.
