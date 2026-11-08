(* spine-root: the census behind BhvStep.native_vals' VM-cell side (the
   rows Hobj_cou_nt / Hobj_cou_t carry native_vals inside rest_keeps). *)
(* ======================================================================= *)
(* NativeVmCensus.v -- WHO, AMONG THE NATIVES, WRITES A VM CELL OR THE     *)
(* CURSOR? (GOAL 2 objects, 2026-11-08)                                    *)
(*                                                                         *)
(* INV_k's ghost clause nvB scr says the bytes where the real memory and   *)
(* the ghost differ -- slot k's VM cells (curBhvCommand, bhvStackIndex,    *)
(* bhvStack) and gCurBhvCommand -- hold only script pointers.  A native    *)
(* storing any other pointer there would falsify it.  This scans the code  *)
(* of every live native (BehaviorScripts.wmotr_live_natives, closed under  *)
(* references, AngleVelCensus.close2: 1429 functions; the interpreter      *)
(* cur_obj_update is NOT in it) for:                                       *)
(*   1 a store whose lvalue path names a VM field or gCurBhvCommand;       *)
(*   2 a store of a whole struct Object;                                   *)
(*   3 a call / builtin handed the address of a VM field or the cursor;    *)
(*   4 a builtin (memcpy / memset) handed an Object pointer.               *)
(* RESULT (vm): only kind 1, in three functions:                           *)
(*   - obj_set_held_state (curBhvCommand := segmented_to_virtual(held      *)
(*     behavior), a script; bhvStackIndex := 0), called only by Mario's   *)
(*     code (mario_grab_used_object / drop / throw: Mario's native, a      *)
(*     special state, native_res);                                         *)
(*   - create_object (curBhvCommand := the spawned script), on the slot     *)
(*     allocate_object just returned, called only by spawn_object_at_origin;*)
(*   - allocate_object (bhvStackIndex := 0, an int).                       *)
(* No native stores gCurBhvCommand.  So no native writes a non-script     *)
(* pointer into a VM cell or the cursor: NO FOUND; INV_k's clause stands.  *)
(* (A census, not a proof: native_vals stays inside the keeps rows.)       *)
(* ======================================================================= *)
From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight Maps Ctypesdefs.
From SM64.Generated Require behavior_data behavior_script object_helpers spawn_object.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts AngleVelCensus.
Import ListNotations.
Local Open Scope Z_scope.

Definition VMF : list ident := [behavior_script._curBhvCommand; behavior_script._bhvStackIndex; behavior_script._bhvStack].
Definition CUR : ident := behavior_script._gCurBhvCommand.
Definition OBJ : ident := behavior_script._Object.

(* the fields / globals named on an lvalue's path *)
Fixpoint lnames (a : expr) : list ident :=
  match a with
  | Efield b f _ => f :: lnames b
  | Evar x _ => [x]
  | Ederef b _ | Eaddrof b _ | Ecast b _ | Eunop _ b _ => lnames b
  | Ebinop _ x y _ => lnames x ++ lnames y
  | _ => nil
  end.
Definition hits (a : expr) : bool :=
  existsb (fun x => existsb (Pos.eqb x) (CUR :: VMF)) (lnames a).
Definition is_obj_struct (ty : type) : bool :=
  match ty with Tstruct s _ => Pos.eqb s OBJ | _ => false end.
Definition ptr_to_obj (ty : type) : bool :=
  match ty with Tpointer t _ => is_obj_struct t | _ => false end.

Fixpoint shits (s : statement) : list (nat * expr) :=
  match s with
  | Sassign a b => (if hits a then [(1%nat, a)] else nil) ++ (if is_obj_struct (typeof a) then [(2%nat, a)] else nil)
  | Scall _ _ al => flat_map (fun a => match a with Eaddrof l _ => if hits l then [(3%nat, a)] else nil | _ => nil end) al
  | Sbuiltin _ _ _ al => flat_map (fun a => (match a with Eaddrof l _ => if hits l then [(3%nat, a)] else nil | _ => nil end)
                                         ++ (if ptr_to_obj (typeof a) then [(4%nat, a)] else nil)) al
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => shits a ++ shits b
  | Sswitch _ ls => shits_ls ls
  | Slabel _ a => shits a
  | _ => nil
  end
with shits_ls (ls : labeled_statements) : list (nat * expr) :=
  match ls with LSnil => nil | LScons _ a r => shits a ++ shits_ls r end.

Definition body_of (f : ident) : list statement :=
  match PTree.get f fns2 with Some es => map snd es | None => nil end.

Definition ncode : list ident :=
  map fst (PTree.elements (close2 1000000 wmotr_live_natives (PTree.empty _))).

Definition callers (x : ident) : list string :=
  map string_of_ident (filter (fun f => existsb (fun s => existsb (Pos.eqb x) (svars s)) (body_of f)) ncode).

Definition vm_hits : list (string * list (nat * list string)) :=
  flat_map (fun f => match flat_map shits (body_of f) with
                     | nil => nil
                     | hs => [(string_of_ident f, map (fun p => (fst p, map string_of_ident (lnames (snd p)))) hs)] end)
    ncode.

Lemma native_vm_value :
  existsb (Pos.eqb behavior_script._cur_obj_update) ncode = false
  /\ vm_hits =
     [("obj_set_held_state"%string, [(1%nat, ["curBhvCommand"%string]); (1%nat, ["bhvStackIndex"%string])]);
      ("create_object"%string, [(1%nat, ["curBhvCommand"%string])]);
      ("allocate_object"%string, [(1%nat, ["bhvStackIndex"%string])])]
  /\ callers object_helpers._obj_set_held_state
     = ["mario_grab_used_object"%string; "mario_drop_held_object"%string; "mario_throw_held_object"%string]
  /\ callers spawn_object._create_object = ["spawn_object_at_origin"%string].
Proof. vm_compute. repeat split; reflexivity. Qed.
