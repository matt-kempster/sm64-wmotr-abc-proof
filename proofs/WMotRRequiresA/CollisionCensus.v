(* spine-root: GOAL 2's dynamic-surface counter -- the collision census
   behind the terrain step rows' counter / ring claims (TRUST 0.7,
   "walk-indexed counter bound").  Machine-checked over the generated code,
   like AngleVelCensus / HeldObjCensus. *)
(* ======================================================================= *)
(* WHO LOADS DYNAMIC SURFACES IN WMotR, AND WHAT A TERRAIN STEP CAN DO TO  *)
(* THE OBJECT LISTS (2026-11-02).                                           *)
(*                                                                          *)
(* gSurfacesAllocated / gSurfaceNodesAllocated grow only through           *)
(* alloc_surface / alloc_surface_node, called by load_object_collision_    *)
(* model (an object's step) and the level load.  This file pins, over the  *)
(* generated code of the behaviors WMotR can spawn (BehaviorScripts.       *)
(* reached_bhvs; each behavior's code = its script's natives plus the      *)
(* behavior interpreter cur_obj_update and everything they reference,      *)
(* AngleVelCensus.close2; a spawned behavior's code is not followed, it    *)
(* runs on the new object):                                                *)
(*   (1) the counters' writers (surf_writers_value);                       *)
(*   (2) the LOADERS: only bhvExclamationBox and bhvCannonClosed reach a    *)
(*       writer or load_object_collision_model (loaders_value), each with   *)
(*       ONE call per step: the box through its one call site               *)
(*       (exclamation_box_act_2, one action function per                    *)
(*       cur_obj_call_action_function), the lid through its script's one   *)
(*       CALL_NATIVE in the loop body (loader_calls);                       *)
(*   (3) the TIME-STOP gate: load_object_collision_model loads surfaces     *)
(*       only under `!(gTimeStopState & TIME_STOP_ACTIVE)`, and             *)
(*       clear_dynamic_surfaces resets the counters only under the same     *)
(*       test (gates_value);                                               *)
(*   (4) the TERRAIN scripts: the behaviors whose BEGIN list is            *)
(*       OBJ_LIST_SURFACE (9) or OBJ_LIST_SPAWNER (11) are the box, the     *)
(*       lid and bhvCoinFormation; none of their code writes                *)
(*       gTimeStopState, none has a GOTO / CALL, and the only writers of    *)
(*       gTimeStopState are bhvMario, bhvSpawnedStarNoLevelExit and          *)
(*       bhvStarSpawnCoordinates (lists 0 and 6) (terrain_value,            *)
(*       ts_writers_value);                                                *)
(*   (5) the LIST surgery: the only object-node next/prev stores are        *)
(*       try_allocate_object's (TAIL insertion, in the generated store      *)
(*       order: freeList.next, nextObj.prev, nextObj.next,                  *)
(*       destList->prev->next, destList.prev) and deallocate_object's,      *)
(*       which only unload_object calls, which only allocate_object's       *)
(*       pool-full path calls, on find_unimportant_object's result, the     *)
(*       first node of gObjectLists[OBJ_LIST_UNIMPORTANT = 12]             *)
(*       (list_value);                                                     *)
(*   (6) the object-field stores a step can make to ANOTHER object's        *)
(*       script / behavior / mesh: curBhvCommand (cur_obj_update: self;     *)
(*       create_object: the new object; obj_set_held_state: a held          *)
(*       object, reachable from none of the terrain scripts), behavior      *)
(*       (cur_obj_set_behavior: self, from coin code only; create_object),  *)
(*       collisionData (allocate_object: the new object;                   *)
(*       bhv_cmd_load_collision_data: self) (fields_value);                *)
(*   (7) no reached code spawns a box or a lid: the one function naming    *)
(*       either is bobomb_buddy_cannon_dialog, which looks the lid up       *)
(*       (cur_obj_nearest_object_with_behavior), and no reached script has  *)
(*       a SPAWN_* of them (spawn_value).                                   *)
(* What this does not cover: calls through function pointers outside the  *)
(* script natives and the tables close2 follows, and code outside the      *)
(* listed TUs (as AngleVelCensus).                                         *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool String DecimalString.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight Maps Ctypesdefs.
From SM64.Generated Require behavior_data behavior_actions behavior_script surface_load
  object_helpers obj_behaviors obj_behaviors_2 spawn_object object_list_processor
  macro_special_objects.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts AngleVelCensus.
Import ListNotations.

Local Open Scope Z_scope.

Definition LOCM : ident := surface_load._load_object_collision_model.
Definition SA : ident := surface_load._gSurfacesAllocated.
Definition SNA : ident := surface_load._gSurfaceNodesAllocated.
Definition TS : ident := surface_load._gTimeStopState.
Definition BOX : ident := behavior_data._bhvExclamationBox.
Definition LID : ident := behavior_data._bhvCannonClosed.

(* a behavior's step code *)
Definition code_of (b : ident) : list ident :=
  map fst (PTree.elements (close2 1000000 (natives b ++ [behavior_script._cur_obj_update]) (PTree.empty _))).

(* all the reached code *)
Definition all_code : list ident :=
  map fst (PTree.elements (close2 1000000 (flat_map natives reached_bhvs ++ [behavior_script._cur_obj_update])
                                  (PTree.empty _))).

Definition body_of (f : ident) : list statement :=
  match PTree.get f fns2 with Some es => map snd es | None => nil end.

(* f's body names the global / function x *)
Definition mentions (x f : ident) : bool := existsb (fun s => existsb (Pos.eqb x) (svars s)) (body_of f).

(* ---- (1) the counters' writers ---- *)
Definition surf_writers : list ident :=
  filter (fun f => mentions SA f || mentions SNA f) (map fst (PTree.elements fns2)).

Lemma surf_writers_value :
  map string_of_ident surf_writers =
  ["clear_dynamic_surfaces"; "alloc_surface_node"; "alloc_surface"; "load_area_terrain";
   "debug_surface_list_info"]%string.
Proof. vm_compute. reflexivity. Qed.

(* ---- (2) the loaders ---- *)
Definition loads (b : ident) : bool :=
  existsb (fun f => mentions SA f || mentions SNA f || Pos.eqb f LOCM) (code_of b).

Lemma loaders_value : map string_of_ident (filter loads reached_bhvs) = ["bhvExclamationBox"; "bhvCannonClosed"]%string.
Proof. vm_compute. reflexivity. Qed.

(* the call sites of x in a statement *)
Fixpoint ncalls (x : ident) (s : statement) : nat :=
  match s with
  | Scall _ (Evar f _) _ => if Pos.eqb f x then 1 else 0
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => ncalls x a + ncalls x b
  | Sswitch _ ls => ncalls_ls x ls
  | Slabel _ a => ncalls x a
  | _ => 0
  end%nat
with ncalls_ls (x : ident) (ls : labeled_statements) : nat :=
  match ls with LSnil => 0 | LScons _ a r => ncalls x a + ncalls_ls x r end%nat.

Definition sites (b : ident) : list (string * nat) :=
  flat_map (fun f => let n := fold_left (fun a s => a + ncalls LOCM s)%nat (body_of f) 0%nat in
                     if Nat.eqb n 0 then [] else [(string_of_ident f, n)]) (code_of b).

Lemma loader_calls :
  (map string_of_ident (natives BOX), sites BOX)
    = (["bhv_exclamation_box_loop"]%string, [("exclamation_box_act_2"%string, 1%nat)])
  /\ (map string_of_ident (natives LID), sites LID)
    = (["bhv_cannon_closed_init"; "bhv_cannon_closed_loop"; "load_object_collision_model"]%string, []).
Proof. vm_compute. split; reflexivity. Qed.

(* ---- (3) the time-stop gate.  clightgen turns `!(gTimeStopState &
   TIME_STOP_ACTIVE) && a && b` into temps: t := gTimeStopState;
   if (!(t & (1 << 6))) t2 := a else t2 := 0; if (t2) t3 := b else t3 := 0;
   if (t3) { ... }.  A GATE is the condition !(x & (1 << 6)) with x
   gTimeStopState or a temp loaded from it, or a temp that is set to a
   non-zero value only in the then-branch of a gate.  Listed: the calls to
   xs / stores to xs NOT in the then-branch of a gate (the else-branch of
   a gate is not gated). ---- *)
Definition TSA_ok (k : expr) : bool :=
  match k with
  | Ebinop Oshl (Econst_int x _) (Econst_int y _) _ => Int.eq x Int.one && Int.eq y (Int.repr 6)
  | _ => false
  end.

(* temps loaded straight from gTimeStopState *)
Fixpoint ts_temps (s : statement) : list ident :=
  match s with
  | Sset t (Evar g _) => if Pos.eqb g TS then [t] else []
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => ts_temps a ++ ts_temps b
  | Sswitch _ ls => ts_temps_ls ls
  | Slabel _ a => ts_temps a
  | _ => []
  end
with ts_temps_ls (ls : labeled_statements) : list ident :=
  match ls with LSnil => [] | LScons _ a r => ts_temps a ++ ts_temps_ls r end.

Definition gate (tv gs : list ident) (c : expr) : bool :=
  match c with
  | Eunop Onotbool (Ebinop Oand x k _) _ =>
      TSA_ok k &&
      match x with
      | Evar g _ => Pos.eqb g TS
      | Etempvar t _ => existsb (Pos.eqb t) tv
      | _ => false
      end
  | Etempvar t _ => existsb (Pos.eqb t) gs
  | _ => false
  end.

Fixpoint ungated (tv gs xs : list ident) (s : statement) : list ident :=
  match s with
  | Scall _ (Evar f _) _ => if existsb (Pos.eqb f) xs then [f] else []
  | Sassign (Evar g _) _ => if existsb (Pos.eqb g) xs then [g] else []
  | Sset t (Econst_int n _) => if existsb (Pos.eqb t) xs && negb (Int.eq n Int.zero) then [t] else []
  | Sset t _ => if existsb (Pos.eqb t) xs then [t] else []
  | Sifthenelse c a b => (if gate tv gs c then [] else ungated tv gs xs a) ++ ungated tv gs xs b
  | Ssequence a b | Sloop a b => ungated tv gs xs a ++ ungated tv gs xs b
  | Sswitch _ ls => ungated_ls tv gs xs ls
  | Slabel _ a => ungated tv gs xs a
  | _ => []
  end
with ungated_ls (tv gs xs : list ident) (ls : labeled_statements) : list ident :=
  match ls with LSnil => [] | LScons _ a r => ungated tv gs xs a ++ ungated_ls tv gs xs r end.

(* every temp a body sets *)
Fixpoint set_temps (s : statement) : list ident :=
  match s with
  | Sset t _ => [t]
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => set_temps a ++ set_temps b
  | Sswitch _ ls => set_temps_ls ls
  | Slabel _ a => set_temps a
  | _ => []
  end
with set_temps_ls (ls : labeled_statements) : list ident :=
  match ls with LSnil => [] | LScons _ a r => set_temps a ++ set_temps_ls r end.

(* gate temps: set non-zero only in a gate's then-branch (iterated) *)
Definition gate_step (s : statement) (gs : list ident) : list ident :=
  let tv := ts_temps s in
  filter (fun t => negb (existsb (Pos.eqb t) tv) && match ungated tv gs [t] s with [] => true | _ => false end)
         (dedup (set_temps s)).
Definition gates (s : statement) : list ident := gate_step s (gate_step s (gate_step s [])).

Definition ungated_in (xs : list ident) (s : statement) : list ident :=
  ungated (ts_temps s) (gates s) xs s.

(* the same, all of them (non-vacuity of the scan) *)
Fixpoint occ (xs : list ident) (s : statement) : list ident :=
  match s with
  | Scall _ (Evar f _) _ => if existsb (Pos.eqb f) xs then [f] else []
  | Sassign (Evar g _) _ => if existsb (Pos.eqb g) xs then [g] else []
  | Sifthenelse _ a b | Ssequence a b | Sloop a b => occ xs a ++ occ xs b
  | Sswitch _ ls => occ_ls xs ls
  | Slabel _ a => occ xs a
  | _ => []
  end
with occ_ls (xs : list ident) (ls : labeled_statements) : list ident :=
  match ls with LSnil => [] | LScons _ a r => occ xs a ++ occ_ls xs r end.

Definition LOADS : list ident := [surface_load._load_object_surfaces; surface_load._transform_object_vertices].
Definition RESETS : list ident := [SA; SNA; surface_load._clear_spatial_partition].

Lemma gates_value :
  (map string_of_ident (occ LOADS (fn_body surface_load.f_load_object_collision_model)),
   ungated_in LOADS (fn_body surface_load.f_load_object_collision_model))
    = (["transform_object_vertices"; "load_object_surfaces"]%string, [])
  /\ (map string_of_ident (occ RESETS (fn_body surface_load.f_clear_dynamic_surfaces)),
      ungated_in RESETS (fn_body surface_load.f_clear_dynamic_surfaces))
    = (["gSurfacesAllocated"; "gSurfaceNodesAllocated"; "clear_spatial_partition"]%string, []).
Proof. vm_compute. split; reflexivity. Qed.

(* ---- (4) the terrain scripts and the time-stop writers ---- *)
Definition begin_list (b : ident) : Z :=
  match find (fun p => Pos.eqb (fst p) b) behavior_data.global_definitions with
  | Some (_, Gvar v) =>
      match gvar_init v with Init_int32 n :: _ => Z.land (Z.shiftr (Int.unsigned n) 16) 255 | _ => -1 end
  | _ => -2
  end.

Fixpoint gstore (g : ident) (s : statement) : bool :=
  match s with
  | Sassign (Evar x _) _ => Pos.eqb x g
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => gstore g a || gstore g b
  | Sswitch _ ls => gstore_ls g ls
  | Slabel _ a => gstore g a
  | _ => false
  end
with gstore_ls (g : ident) (l : labeled_statements) : bool :=
  match l with LSnil => false | LScons _ a r => gstore g a || gstore_ls g r end.

Definition writes (g f : ident) : bool := existsb (gstore g) (body_of f).

Definition jumps (b : ident) : bool :=
  match script_of b with
  | Some cs => existsb (fun c => match c with CJump _ => true | _ => false end) cs
  | None => true
  end.

Definition terrain_bhvs : list ident :=
  filter (fun b => (begin_list b =? 9) || (begin_list b =? 11)) reached_bhvs.

Lemma terrain_value :
  map (fun b => (string_of_ident b, begin_list b, existsb (writes TS) (code_of b), jumps b,
                 existsb (Pos.eqb object_helpers._obj_set_held_state) (code_of b)))
      terrain_bhvs
  = [("bhvExclamationBox"%string, 9, false, false, false);
     ("bhvCoinFormation"%string, 11, false, false, false);
     ("bhvCannonClosed"%string, 9, false, false, false)].
Proof. vm_compute. reflexivity. Qed.

Lemma ts_writers_value :
  map (fun b => (string_of_ident b, begin_list b)) (filter (fun b => existsb (writes TS) (code_of b)) reached_bhvs)
  = [("bhvMario"%string, 0); ("bhvSpawnedStarNoLevelExit"%string, 6); ("bhvStarSpawnCoordinates"%string, 6)].
Proof. vm_compute. reflexivity. Qed.

(* ---- (5) the list surgery ---- *)
(* stores to a field fld, with the base they go through *)
(* clightgen's temps t'N are the positives 127 + N *)
Definition tmp_str (t : ident) : string :=
  if Pos.ltb t 1000 then ("t'" ++ NilEmpty.string_of_uint (Nat.to_uint (Pos.to_nat t - 127)))%string
  else string_of_ident t.

Definition base_str (b : expr) : string :=
  match b with
  | Ederef (Evar x _) _ => ("var " ++ string_of_ident x)%string
  | Ederef (Etempvar t _) _ => ("tmp " ++ tmp_str t)%string
  | _ => "other"%string
  end.

Fixpoint fstores (flds : list ident) (s : statement) : list (string * string) :=
  match s with
  | Sassign (Efield b f _) _ => if existsb (Pos.eqb f) flds then [(string_of_ident f, base_str b)] else []
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => fstores flds a ++ fstores flds b
  | Sswitch _ ls => fstores_ls flds ls
  | Slabel _ a => fstores flds a
  | _ => []
  end
with fstores_ls (flds : list ident) (ls : labeled_statements) : list (string * string) :=
  match ls with LSnil => [] | LScons _ a r => fstores flds a ++ fstores_ls flds r end.

Definition fld_sites (flds : list ident) : list (string * list (string * string)) :=
  flat_map (fun f => match flat_map (fstores flds) (body_of f) with
                     | [] => []
                     | l => [(string_of_ident f, l)]
                     end) all_code.

Definition callers (x : ident) : list string :=
  map string_of_ident (filter (fun f => existsb (Pos.eqb x) (refs2 f)) all_code).

(* (the geo / surface-node functions' stores are to GraphNode / SurfaceNode
   fields of the same names, other structs; t'2 in try_allocate_object is
   destList->prev, t'2 / t'4 in deallocate_object obj->prev / obj->next) *)
Lemma list_value :
  fld_sites [spawn_object._next; spawn_object._prev]
  = [("geo_add_child"%string,
      [("prev"%string, "tmp childNode"%string); ("next"%string, "tmp childNode"%string);
       ("prev"%string, "tmp childNode"%string); ("next"%string, "tmp childNode"%string);
       ("prev"%string, "tmp parentFirstChild"%string); ("next"%string, "tmp parentLastChild"%string)]);
     ("geo_remove_child"%string, [("next"%string, "tmp t'6"%string); ("prev"%string, "tmp t'4"%string)]);
     ("alloc_surface_node"%string, [("next"%string, "tmp node"%string)]);
     ("add_surface_to_cell"%string, [("next"%string, "tmp newNode"%string); ("next"%string, "tmp list"%string)]);
     ("deallocate_object"%string,
      [("prev"%string, "tmp t'4"%string); ("next"%string, "tmp t'2"%string);
       ("next"%string, "tmp obj"%string); ("next"%string, "tmp freeList"%string)]);
     ("try_allocate_object"%string,
      [("next"%string, "tmp freeList"%string); ("prev"%string, "tmp nextObj"%string);
       ("next"%string, "tmp nextObj"%string); ("next"%string, "tmp t'2"%string);
       ("prev"%string, "tmp destList"%string)])]
  /\ callers spawn_object._deallocate_object = ["unload_object"%string]
  /\ callers spawn_object._unload_object = ["allocate_object"%string]
  /\ callers spawn_object._find_unimportant_object = ["allocate_object"%string]
  /\ callers spawn_object._try_allocate_object = ["allocate_object"%string].
Proof. vm_compute. repeat split; reflexivity. Qed.

(* ---- (6) script / behavior / mesh stores (t'48 in cur_obj_update, t'2
   in cur_obj_set_behavior and t'3 in bhv_cmd_load_collision_data are
   gCurrentObject: self) ---- *)
Lemma fields_value :
  fld_sites [behavior_script._curBhvCommand]
    = [("obj_set_held_state"%string, [("curBhvCommand"%string, "tmp obj"%string)]);
       ("cur_obj_update"%string, [("curBhvCommand"%string, "tmp t'48"%string)]);
       ("create_object"%string, [("curBhvCommand"%string, "tmp obj"%string)])]
  /\ fld_sites [surface_load._behavior]
    = [("cur_obj_set_behavior"%string, [("behavior"%string, "tmp t'2"%string)]);
       ("create_object"%string, [("behavior"%string, "tmp obj"%string)])]
  /\ fld_sites [surface_load._collisionData]
    = [("allocate_object"%string, [("collisionData"%string, "tmp obj"%string)]);
       ("bhv_cmd_load_collision_data"%string, [("collisionData"%string, "tmp t'3"%string)])]
  /\ map string_of_ident (filter (fun b => existsb (Pos.eqb behavior_actions._cur_obj_set_behavior) (code_of b)) reached_bhvs)
    = ["bhvYellowCoin"; "bhvCoinFormationSpawn"; "bhvSingleCoinGetsSpawned"]%string.
Proof. vm_compute. repeat split; reflexivity. Qed.

(* ---- (7) nobody spawns a box or a lid ---- *)
Lemma spawn_value :
  map string_of_ident (filter (fun f => mentions BOX f || mentions LID f) all_code)
    = ["bobomb_buddy_cannon_dialog"%string]
  /\ forallb (fun b => match script_of b with
                       | Some cs => forallb (fun c => match c with
                                                      | CSpawn x => negb (Pos.eqb x BOX || Pos.eqb x LID)
                                                      | _ => true end) cs
                       | None => true end) reached_bhvs = true.
Proof. vm_compute. split; reflexivity. Qed.
