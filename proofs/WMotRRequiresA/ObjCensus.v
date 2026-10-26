(* spine-root: B3a, the census behind ObjLoop's ring rows (Hobj_step_*:
   "the node stays in its ring").  A certificate over BehaviorScripts'
   WMotR closure, consumed when B3 steps cur_obj_update. *)
(* ======================================================================= *)
(* ObjCensus.v -- which WMotR objects can move a list node between rings.  *)
(*                                                                         *)
(* A slot changes list only by being freed and reallocated:                *)
(*   unload_object -> deallocate_object (to the free list), and            *)
(*   create_object -> allocate_object -> try_allocate_object (to the end   *)
(*   of the list named by the script's BEGIN, else OBJ_LIST_DEFAULT = 8).  *)
(* With the pool full, allocate_object frees find_unimportant_object(),    *)
(* the FIRST node of OBJ_LIST_UNIMPORTANT (12), and hands that slot to the *)
(* new object.  If that node is the object being updated, it leaves its    *)
(* list for the spawned object's list.  spawn_object.c says "I don't know  *)
(* of any unimportant objects that spawn other objects".                   *)
(*                                                                         *)
(* FOUND 2026-10-26: over the WMotR closure that comment is FALSE.  Five   *)
(* list-12 behaviors reach allocate_object (unimp_allocators_value); three *)
(* of them only spawn list-12 objects (the freed node is re-appended to    *)
(* list 12: membership survives, the walk ends early), and the remaining   *)
(* cases are WATER behaviors whose spawns land in list 8:                  *)
(*   bhvObjectBubble -> bhvBubbleSplash, bhvWaterDroplet ->                *)
(*   bhvWaterDropletSplash, and (over-approximated: a script CALL target,  *)
(*   not a spawn) bhvSmallWaterWave -> bhvSmallWaterWave398.               *)
(* If such a node moves to list 8 the real walk does not meet its head     *)
(* again: it runs on through list 8's HEAD as if it were an object, which  *)
(* reads past gObjectListArray -- undefined, not a clean hang -- so the    *)
(* ring row cannot be dropped for that case; it must be shown not to       *)
(* happen (WMotR has no water: FfWorld.env_w).                             *)
(*                                                                         *)
(* Also certified: in the closure, only allocate_object calls              *)
(* unload_object, only create_object calls allocate_object, and only       *)
(* try_allocate_object / deallocate_object assign an ObjectNode's next or  *)
(* prev field by name (a store through a cast pointer is not seen by this  *)
(* syntactic scan; B3's stepping must cover it).                           *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Maps Ctypesdefs Clight.
From SM64.Generated Require behavior_data spawn_object object_list_processor.
From SM64.Proofs Require Import CensusV2.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts.
Import ListNotations.
Local Open Scope Z_scope.

(* the object list a script's object is created in (create_object) *)
Definition first_word (b : ident) : option Z :=
  match find (fun p => Pos.eqb (fst p) b) behavior_data.global_definitions with
  | Some (_, Gvar v) => match gvar_init v with Init_int32 n :: _ => Some (Int.unsigned n) | _ => None end
  | _ => None
  end.
Definition list_of (b : ident) : Z :=
  match first_word b with
  | Some w => if Z.shiftr w 24 =? 0 then Z.land (Z.shiftr w 16) 65535 else 8
  | None => 8
  end.

Definition OBJ_LIST_UNIMPORTANT : Z := 12.

Definition set_of (l : list ident) : PTree.t unit :=
  fold_left (fun t x => PTree.set x tt t) l (PTree.empty _).

Definition allocs (b : ident) : bool := memb spawn_object._allocate_object (set_of (closure_of [b])).

(* list-12 behaviors of the closure that can reach allocate_object *)
Definition unimp_allocators : list ident :=
  filter (fun b => (list_of b =? OBJ_LIST_UNIMPORTANT) && allocs b) reached_bhvs.

Lemma unimp_allocators_value : map string_of_ident unimp_allocators =
  [ "bhvObjectBubble"; "bhvWaterDroplet"; "bhvSmallWaterWave"; "bhvSmallParticle";
    "bhvSparkleSpawn" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* what they can bring into being outside list 12 *)
Definition offlist (b : ident) : list ident :=
  filter (fun x => is_bhv_sym x && negb (list_of x =? OBJ_LIST_UNIMPORTANT)) (closure_of [b]).

Lemma offlist_value : map (fun b => (string_of_ident b, map string_of_ident (offlist b))) unimp_allocators =
  [ ("bhvObjectBubble", ["bhvBubbleSplash"]);
    ("bhvWaterDroplet", ["bhvWaterDropletSplash"]);
    ("bhvSmallWaterWave", ["bhvSmallWaterWave398"]);
    ("bhvSmallParticle", []);
    ("bhvSparkleSpawn", []) ]%string.
Proof. vm_compute. reflexivity. Qed.

(* the water movers: the only list-12 objects whose spawn can move a node off list 12 *)
Definition water_movers : list ident := filter (fun b => negb (match offlist b with [] => true | _ => false end)) unimp_allocators.

Lemma water_movers_value : map string_of_ident water_movers =
  [ "bhvObjectBubble"; "bhvWaterDroplet"; "bhvSmallWaterWave" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* callers, within the closure *)
Definition callers (g : ident) : list ident :=
  filter (fun x => existsb (Pos.eqb g) (refs_of x)) wmotr_closure.

Lemma unload_callers : map string_of_ident (callers spawn_object._unload_object) = [ "allocate_object" ]%string.
Proof. vm_compute. reflexivity. Qed.
Lemma allocate_callers : map string_of_ident (callers spawn_object._allocate_object) = [ "create_object" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* assignments to an ObjectNode's next / prev field, by name *)
Definition is_node_link (a : expr) : bool :=
  match a with
  | Efield b f _ =>
      match typeof b with
      | Tstruct s _ => Pos.eqb s object_list_processor._ObjectNode
                       && (Pos.eqb f object_list_processor._next || Pos.eqb f object_list_processor._prev)
      | _ => false
      end
  | _ => false
  end.

Fixpoint link_store (s : statement) : bool :=
  match s with
  | Sassign a _ => is_node_link a
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => link_store s1 || link_store s2
  | Sswitch _ ls => link_store_ls ls
  | Slabel _ s1 => link_store s1
  | _ => false
  end
with link_store_ls (ls : labeled_statements) : bool :=
  match ls with LSnil => false | LScons _ s r => link_store s || link_store_ls r end.

Definition link_writers : list ident :=
  filter (fun x => match PTree.get x fns with
                   | Some es => existsb (fun e => link_store (snd e)) es
                   | None => false
                   end) wmotr_closure.

Lemma link_writers_value : map string_of_ident link_writers =
  [ "deallocate_object"; "try_allocate_object" ]%string.
Proof. vm_compute. reflexivity. Qed.
