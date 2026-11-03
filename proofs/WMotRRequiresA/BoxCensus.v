(* spine-root: GOAL 2 objects -- WMotR's exclamation boxes resolved from
   their real bparams, and the spawn closure with the box contents table
   narrowed to what those boxes can actually spawn.  Consumed by BhvStep
   (SET_INTERACT_TYPE's computed argument: the KIND clause). *)
(* ====================================================================== *)
(* BoxCensus.v                                                            *)
(*                                                                        *)
(* BehaviorScripts.wmotr_closure_g follows every symbol a body or table  *)
(* mentions.  sExclamationBoxContents (exclamation_box.inc.c) mentions    *)
(* every box content -- caps, coins, 1-ups, stars, and bhvKoopaShell,    *)
(* whose bhv_koopa_shell_flame_spawn spawns bhvKoopaShellFlame           *)
(* (INTERACT_FLAME, 0x40000: NOT in wmotr_interact_types; a flame on     *)
(* Mario means ACT_BURNING_JUMP, a height escape).  But a box spawns     *)
(* only the entries whose id is its oBehParams2ndByte                    *)
(* (exclamation_box_spawn_contents), and that byte comes from the macro  *)
(* loader (spawn_macro_objects, macro_special_objects.c, generated       *)
(* lines ~2860-3070):                                                    *)
(*   if (preset.param != 0)                                               *)
(*     params = (params & 0xFF00) + (preset.param & 0x00FF);              *)
(*   newObj->oBehParams2ndByte = params & 0x00FF;            (field 47)   *)
(* So this file decodes                                                  *)
(*   - every WMotR box: its preset param and its macro param,            *)
(*   - the contents table (id, behavior),                                *)
(* and closes the spawn graph with the table's edge cut down to the      *)
(* contents of those ids.                                                 *)
(*                                                                        *)
(* PHANTOM CHECK (what a reader must also believe; none is a premise of  *)
(* a lemma here, they are what makes the narrowed closure the RIGHT      *)
(* set):                                                                  *)
(*  (a) no script command in the closure writes field 47 of a box, and   *)
(*      the five C writers of a rawData[47] cell in the closure          *)
(*      (writers47_value: cur_obj_spawn_particles, spawn_object_relative,*)
(*      spawn_default_star, spawn_red_coin_cutscene_star,                 *)
(*      bhv_cannon_closed_init) write a NEW child's byte or the cannon's *)
(*      own -- never a live box's.  Pinned below as a census, not proved *)
(*      per target;                                                       *)
(*  (b) no level-script OBJECT places a box (box_not_scripted): every    *)
(*      WMotR box is a macro object;                                     *)
(*  (c) the debug spawner stays gated (obj_w's DEBUG clause), as for     *)
(*      wmotr_closure_g.                                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Clight Maps Ctypesdefs Clightdefs.
From SM64.Generated Require behavior_data behavior_actions macro_special_objects wmotr_script.
From SM64.Proofs.WMotRRequiresA Require Import WMotRLevel BehaviorScripts.
Import ListNotations.

Local Open Scope Z_scope.

(* ---- the boxes and their content ids ---- *)
Fixpoint preset_params (l : list init_data) : list Z :=
  match l with
  | Init_addrof _ _ :: _ :: Init_int16 p :: r => Int.signed p :: preset_params r
  | _ => nil
  end.
Definition pparams : list Z := preset_params (gvar_init macro_special_objects.v_sMacroObjectPresets).

Definition is_box (o : mobj) : bool := Pos.eqb (bhv_of o) macro_special_objects._bhvExclamationBox.

(* spawn_macro_objects' oBehParams2ndByte *)
Definition box_id (o : mobj) : Z :=
  let pp := nth (Z.to_nat (m_preset o)) pparams 0 in
  if pp =? 0 then Z.land (m_param o) 255 else Z.land pp 255.

Definition box_ids : list Z := nodup Z.eq_dec (map box_id (filter is_box wmotr_macro_objs)).

(* the 7 boxes: one 1-up box (preset 67, preset param 7), six wing-cap
   boxes (preset 60, params 0) *)
Lemma boxes_value :
  map (fun o => (m_preset o, nth (Z.to_nat (m_preset o)) pparams 0, m_param o))
      (filter is_box wmotr_macro_objs)
  = [(67, 7, 0); (60, 0, 0); (60, 0, 0); (60, 0, 0); (60, 0, 0); (60, 0, 0); (60, 0, 0)].
Proof. vm_compute. reflexivity. Qed.

Lemma box_ids_value : box_ids = [7; 0].
Proof. vm_compute. reflexivity. Qed.

(* (b): no box comes from the level script *)
Lemma box_not_scripted :
  existsb (Pos.eqb macro_special_objects._bhvExclamationBox)
    (script_refs (gvar_init wmotr_script.v_level_wmotr_entry)
     ++ script_refs (gvar_init wmotr_script.v_script_func_local_1)
     ++ script_refs (gvar_init wmotr_script.v_script_func_local_2)) = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the contents table: { id, unk1, unk2, model, behavior } ---- *)
Fixpoint contents (l : list init_data) : list (Z * ident) :=
  match l with
  | Init_int8 i :: _ :: _ :: _ :: Init_addrof b _ :: r => (Int.unsigned i, b) :: contents r
  | _ => nil
  end.
Definition box_table : list (Z * ident) := contents (gvar_init behavior_actions.v_sExclamationBoxContents).

Definition box_bhvs : list ident :=
  map snd (filter (fun e => existsb (Z.eqb (fst e)) box_ids) box_table).

(* the table really holds the shell (id 3) -- the cut is not vacuous *)
Lemma table_has_shell : In (3, behavior_actions._bhvKoopaShell) box_table.
Proof. vm_compute. tauto. Qed.

Lemma box_bhvs_value : map string_of_ident box_bhvs = ["bhvWingCap"; "bhv1UpWalking"]%string.
Proof. vm_compute. reflexivity. Qed.

(* ---- the closure, the table's edge narrowed ---- *)
Definition refs_b (x : ident) : list ident :=
  if Pos.eqb x behavior_actions._sExclamationBoxContents then box_bhvs
  else if debug_gated x then nil else refs_of x.

Fixpoint close_b (fuel : nat) (work : list ident) (seen : PTree.t unit) : PTree.t unit :=
  match fuel with
  | O => seen
  | S fuel =>
      match work with
      | nil => seen
      | x :: w => if memb x seen then close_b fuel w seen
                  else close_b fuel (refs_b x ++ w) (PTree.set x tt seen)
      end
  end.

Definition wmotr_closure_b : list ident :=
  map fst (PTree.elements (close_b 1000000 placed (PTree.empty _))).

(* the only bodies / tables of the gated closure that mention the shell are
   the contents table and the (gated) debug spawner; the flame only from
   the shell's flame spawner *)
Lemma shell_refs :
  map string_of_ident (filter (fun x => existsb (Pos.eqb behavior_actions._bhvKoopaShell) (refs_of x))
                              wmotr_closure_g)
  = ["sExclamationBoxContents"; "try_do_mario_debug_object_spawn"]%string.
Proof. vm_compute. reflexivity. Qed.

(* THE CENSUS: with the boxes resolved, neither the shell nor its flame
   can come into being in WMotR *)
Lemma shell_unreached : existsb (Pos.eqb behavior_actions._bhvKoopaShell) wmotr_closure_b = false.
Proof. vm_compute. reflexivity. Qed.
Lemma flame_unreached : existsb (Pos.eqb behavior_data._bhvKoopaShellFlame) wmotr_closure_b = false.
Proof. vm_compute. reflexivity. Qed.

(* non-vacuity: the cut keeps what the boxes really spawn, and the flame
   IS in the uncut closure (the narrowing is what excludes it) *)
Lemma box_contents_reached :
  existsb (Pos.eqb behavior_data._bhvWingCap) wmotr_closure_b
  && existsb (Pos.eqb behavior_data._bhv1UpWalking) wmotr_closure_b = true.
Proof. vm_compute. reflexivity. Qed.
Lemma flame_in_uncut : existsb (Pos.eqb behavior_data._bhvKoopaShellFlame) wmotr_closure_g = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- (a): the writers of a rawData[47] cell ---- *)
Definition is_f47 (a : expr) : bool :=
  match a with
  | Ederef (Ebinop Oadd (Efield (Efield _ rd _) _ _) i _) _ =>
      Pos.eqb rd behavior_actions._rawData && (cidx_z i =? 47)
  | _ => false
  end.
Fixpoint st47 (s : statement) : bool :=
  match s with
  | Sassign a _ => is_f47 a
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => st47 a || st47 b
  | Sswitch _ ls => st47_ls ls
  | Slabel _ a => st47 a
  | _ => false
  end
with st47_ls (ls : labeled_statements) : bool :=
  match ls with LSnil => false | LScons _ a r => st47 a || st47_ls r end.

Lemma writers47_value :
  map string_of_ident (filter (fun x => match PTree.get x fns with
                                        | Some es => existsb (fun e => st47 (snd e)) es
                                        | None => false end) wmotr_closure_b)
  = ["cur_obj_spawn_particles"; "spawn_object_relative"; "spawn_default_star";
     "spawn_red_coin_cutscene_star"; "bhv_cannon_closed_init"]%string.
Proof. vm_compute. reflexivity. Qed.

Lemma script47_value :
  map string_of_ident (filter (fun x => match script_of x with
     | Some cs => existsb (fun c => match c with CSetInt _ f _ => f =? 47 | _ => false end) cs
     | None => false end) (filter is_bhv_sym wmotr_closure_b))
  = [].
Proof. vm_compute. reflexivity. Qed.
