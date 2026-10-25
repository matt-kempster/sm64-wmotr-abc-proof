(* spine-root: GOAL 2's platform-fact certificate -- the objects Mario can
   stand on in WMotR never get a nonzero angle velocity, read off the
   generated behavior scripts and C bodies.  It backs the platform clause of
   the labeled objects spec (HeightFrame.seg_rest_spec, TRUST.md 0.7), like
   HeldObjCensus backs the no-held-object clause. *)
(* ======================================================================= *)
(* GOAL 2: CAN MARIO'S PLATFORM ROTATE?                                     *)
(*                                                                          *)
(* apply_mario_platform_displacement rotates Mario about gMarioPlatform     *)
(* when its oAngleVelPitch / Yaw / Roll (rawData slots 0x23..0x25,          *)
(* object_fields.h) are nonzero, and that changes his y.  gMarioPlatform is *)
(* written only by update_mario_platform (floor->object of Mario's floor)   *)
(* and clear_mario_platform (NULL).  So the question is which objects own   *)
(* surfaces and whether they can rotate.                                    *)
(*                                                                          *)
(* Owners of surfaces: of the behaviors WMotR can spawn, exactly            *)
(* bhvExclamationBox and bhvCannonClosed have LOAD_COLLISION_DATA           *)
(* (BehaviorScripts.reached_bhvs_value lists the two meshes;                *)
(* WMotRLevel.collision_of).  Their slots are zeroed at allocation          *)
(* (spawn_object.c allocate_object), so their angle velocity starts at 0.   *)
(* This file pins, over the generated code:                                 *)
(*   (1) the two scripts contain no field command on slots 0x23..0x25;      *)
(*   (2) every store to a rawData slot of an object in the code the two     *)
(*       behaviors run (their natives, cur_obj_update, the behavior         *)
(*       command table, and everything those call; spawned behaviors'      *)
(*       scripts are NOT followed: their code runs with o = the new         *)
(*       object), that is a constant slot 0x23..0x25 or a variable slot,    *)
(*       with the base it stores through;                                   *)
(*   (3) the same over EVERY function of the object TUs, for slots          *)
(*       0x23..0x25 with a constant index.                                  *)
(* Reading of the result (the lemmas below): the only angle-velocity       *)
(* stores reachable from the two behaviors are spawn_triangle_break_       *)
(* particles' (through `triangle`, the object spawn_object just returned)  *)
(* and the variable-slot stores of the script commands (whose fields are   *)
(* the scripts' own, (1)) and of allocate_object's zeroing loop (the new   *)
(* object).  None targets the box or the lid.  What this does not cover:   *)
(* stores through casts of an object pointer to another type (none is      *)
(* known in these TUs), and code outside the listed TUs.                   *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight Maps Ctypesdefs.
From SM64.Generated Require behavior_data behavior_actions behavior_script surface_load
  object_helpers obj_behaviors obj_behaviors_2 spawn_object object_list_processor
  macro_special_objects.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts.
Import ListNotations.

Local Open Scope Z_scope.

Definition RAW : ident := behavior_actions._rawData.
Definition GCUR : ident := behavior_actions._gCurrentObject.

(* the angle-velocity slots: OBJECT_FIELD_S32(0x23 / 0x24 / 0x25) *)
Definition av_slot (k : Z) : bool := (35 <=? k) && (k <=? 37).

(* the base an object store goes through *)
Inductive base := BSelf | BTemp (t : ident) | BOther.
Definition base_of (b : expr) : base :=
  match b with
  | Ederef (Evar x _) _ => if Pos.eqb x GCUR then BSelf else BOther
  | Ederef (Etempvar t _) _ => BTemp t
  | _ => BOther
  end.

Inductive slot := SConst (k : Z) | SVar.
(* a constant index, folded (object_fields.h writes e.g. 0x06 + 1) *)
Fixpoint const_of (i : expr) : option Z :=
  match i with
  | Econst_int n _ => Some (Int.signed n)
  | Ecast a _ => const_of a
  | Ebinop Oadd a b _ =>
      match const_of a, const_of b with Some x, Some y => Some (x + y) | _, _ => None end
  | Ebinop Osub a b _ =>
      match const_of a, const_of b with Some x, Some y => Some (x - y) | _, _ => None end
  | _ => None
  end.
Definition slot_of (i : expr) : slot :=
  match const_of i with Some k => SConst k | None => SVar end.

(* `X.rawData.asYY[i]` as an lvalue: its base and slot *)
Definition raw_lhs (a : expr) : option (base * slot) :=
  match a with
  | Ederef (Ebinop Oadd (Efield (Efield b rd _) _ _) i _) _ =>
      if Pos.eqb rd RAW then Some (base_of b, slot_of i) else None
  | _ => None
  end.

(* the address of an angle-velocity (or variable) slot taken anywhere *)
Fixpoint av_addr (a : expr) : nat :=
  match a with
  | Eaddrof b _ =>
      (match raw_lhs b with
       | Some (_, SConst k) => if av_slot k then 1 else 0
       | Some (_, SVar) => 1
       | None => 0
       end) + av_addr b
  | Efield b _ _ | Ederef b _ | Eunop _ b _ | Ecast b _ => av_addr b
  | Ebinop _ x y _ => av_addr x + av_addr y
  | _ => 0
  end%nat.

Inductive ev := AVStore (b : base) (k : Z) | VarStore (b : base) | AVAddr.

Definition lhs_ev (a : expr) : list ev :=
  match raw_lhs a with
  | Some (b, SConst k) => if av_slot k then [AVStore b k] else nil
  | Some (b, SVar) => [VarStore b]
  | None => nil
  end.

Definition addr_evs (al : list expr) : list ev :=
  flat_map (fun a => repeat AVAddr (av_addr a)) al.

Fixpoint scan (s : statement) : list ev :=
  match s with
  | Sassign a1 a2 => lhs_ev a1 ++ addr_evs [a1; a2]
  | Sset _ a => addr_evs [a]
  | Scall _ f al => addr_evs (f :: al)
  | Sbuiltin _ _ _ al => addr_evs al
  | Ssequence a b | Sloop a b => scan a ++ scan b
  | Sifthenelse c a b => addr_evs [c] ++ scan a ++ scan b
  | Sreturn (Some a) => addr_evs [a]
  | Sswitch a ls => addr_evs [a] ++ scan_ls ls
  | Slabel _ a => scan a
  | _ => nil
  end
with scan_ls (ls : labeled_statements) : list ev :=
  match ls with LSnil => nil | LScons _ a r => scan a ++ scan_ls r end.

(* ---- the TUs: BehaviorScripts' object TUs, which since 2026-10-24 include
   the behavior interpreter (behavior_script.c) and the collision loader
   (surface_load.c); appending them again would count their bodies twice ---- *)
Definition tus2 : list (list (ident * globdef fundef type)) := all_tus.

Definition fns2 : PTree.t (list fn_entry) := fold_left add_fns tus2 (PTree.empty _).

Definition gvar_tab2 : PTree.t (list ident) :=
  fold_left (fun t defs => fold_left (fun t '(id, g) =>
    match g with
    | Gvar v => PTree.set id (script_refs (gvar_init v) ++ match PTree.get id t with Some o => o | None => nil end) t
    | _ => t
    end) defs t) tus2 (PTree.empty _).

(* what a function or table refers to, minus behavior scripts (a spawned
   behavior's code runs on the new object, not on the caller) *)
Definition refs2 (x : ident) : list ident :=
  filter (fun y => negb (is_bhv_sym y))
    (match PTree.get x fns2 with
     | Some es => dedup (flat_map (fun e => svars (snd e)) es)
     | None => match PTree.get x gvar_tab2 with Some r => r | None => nil end
     end).

Fixpoint close2 (fuel : nat) (work : list ident) (seen : PTree.t unit) : PTree.t unit :=
  match fuel with
  | O => seen
  | S fuel =>
      match work with
      | nil => seen
      | x :: w =>
          if memb x seen then close2 fuel w seen
          else close2 fuel (refs2 x ++ w) (PTree.set x tt seen)
      end
  end.

(* the natives a script calls *)
Definition natives (b : ident) : list ident :=
  match script_of b with
  | Some cs => flat_map (fun c => match c with CNative f => [f] | _ => nil end) cs
  | None => nil
  end.

(* the code a box or a lid runs: its natives, and the interpreter *)
Definition plat_roots : list ident :=
  natives behavior_data._bhvExclamationBox ++ natives behavior_data._bhvCannonClosed
  ++ [behavior_script._cur_obj_update].

Definition plat_code : list ident :=
  map fst (PTree.elements (close2 1000000 plat_roots (PTree.empty _))).

Definition scan_fn (x : ident) : list ev :=
  match PTree.get x fns2 with
  | Some es => flat_map (fun e => scan (snd e)) es
  | None => nil
  end.

Definition plat_evs : list (ident * ev) :=
  flat_map (fun x => map (fun e => (x, e)) (scan_fn x)) plat_code.

(* every function of the TUs: its constant angle-velocity stores *)
Definition all_av : list (ident * ev) :=
  flat_map (fun '(x, _) =>
    flat_map (fun e => match e with AVStore _ _ | AVAddr => [(x, e)] | VarStore _ => nil end)
             (scan_fn x))
    (PTree.elements fns2).

(* ---- (1) the scripts: no field command on 0x23..0x25.  Conservative: no
   int word of either script, read as a command header, names a field op
   (behavior_script.c's table: 0x0D..0x18 ADD/SET/OR/BIT_CLEAR/random,
   0x1F SUM_FLOAT, 0x20 SUM_INT, 0x27 LOAD_ANIMATIONS, 0x36 SET_INT_UNUSED)
   on those slots ---- *)
Definition field_op (op : Z) : bool :=
  ((13 <=? op) && (op <=? 24)) || (op =? 31) || (op =? 32) || (op =? 39) || (op =? 54).

Definition script_words_ok (l : list init_data) : bool :=
  forallb (fun d => match d with
                    | Init_int32 n =>
                        let w := Int.unsigned n in
                        negb (field_op (Z.shiftr w 24) && av_slot (Z.land (Z.shiftr w 16) 255))
                    | _ => true
                    end) l.

Lemma scripts_set_no_angle_vel :
  script_words_ok (gvar_init behavior_data.v_bhvExclamationBox) = true
  /\ script_words_ok (gvar_init behavior_data.v_bhvCannonClosed) = true.
Proof. vm_compute. split; reflexivity. Qed.

(* the two scripts decode, and these are their natives *)
Lemma plat_natives :
  map string_of_ident (natives behavior_data._bhvExclamationBox) = ["bhv_exclamation_box_loop"]%string
  /\ map string_of_ident (natives behavior_data._bhvCannonClosed)
     = ["bhv_cannon_closed_init"; "bhv_cannon_closed_loop"; "load_object_collision_model"]%string.
Proof. vm_compute. split; reflexivity. Qed.

Definition ev_str (p : ident * ev) : string * string * Z :=
  let '(x, e) := p in
  match e with
  | AVStore BSelf k => (string_of_ident x, "self"%string, k)
  | AVStore (BTemp t) k => (string_of_ident x, string_of_ident t, k)
  | AVStore BOther k => (string_of_ident x, "other"%string, k)
  | VarStore BSelf => (string_of_ident x, "self"%string, -1)
  | VarStore (BTemp t) => (string_of_ident x, string_of_ident t, -1)
  | VarStore BOther => (string_of_ident x, "other"%string, -1)
  | AVAddr => (string_of_ident x, "addr"%string, -2)
  end.

(* ---- (2) the stores, pinned: the only constant angle-velocity stores
   reachable from the box and the lid are spawn_triangle_break_particles'
   (through `triangle`, the object spawn_object just returned: a new
   particle, not the caller); the variable-slot stores are allocate_object's
   zeroing loop (the new object) and the behavior commands' (their slots
   are the scripts' own field operands, which (1) shows are not
   0x23..0x25).  So neither the box nor the lid ever gets a nonzero angle
   velocity. ---- *)
Definition fn_slot (p : ident * ev) : string * Z :=
  let '(f, _, k) := ev_str p in (f, k).

Lemma plat_av_stores :
  map fn_slot plat_evs =
  [("spawn_triangle_break_particles", 35); ("spawn_triangle_break_particles", 36);
   ("spawn_triangle_break_particles", 35); ("allocate_object", -1);
   ("bhv_cmd_or_int", -1); ("bhv_cmd_set_int_unused", -1); ("bhv_cmd_set_int_rand_rshift", -1);
   ("bhv_cmd_set_int", -1); ("bhv_cmd_set_random_int", -1); ("bhv_cmd_set_random_float", -1);
   ("bhv_cmd_set_float", -1); ("bhv_cmd_sum_int", -1); ("bhv_cmd_sum_float", -1);
   ("bhv_cmd_add_int_rand_rshift", -1); ("bhv_cmd_add_int", -1); ("bhv_cmd_add_random_float", -1);
   ("bhv_cmd_add_float", -1); ("bhv_cmd_animate_texture", -1); ("bhv_cmd_parent_bit_clear", -1);
   ("bhv_cmd_load_animations", -1); ("bhv_cmd_bit_clear", -1)]%string.
Proof. vm_compute. reflexivity. Qed.

(* the triangle stores go through spawn_triangle_break_particles' temp
   `triangle`, never through gCurrentObject *)
Lemma plat_av_not_self :
  forallb (fun p => match snd p with AVStore BSelf _ => false | _ => true end) plat_evs = true.
Proof. vm_compute. reflexivity. Qed.

(* non-vacuity of the scan: over every object function it does find the
   rotating platforms' stores (e.g. bhv_merry_go_round_loop, the WF wooden
   platform), none of which WMotR spawns (BehaviorScripts) *)
Lemma all_av_finds_rotators :
  existsb (fun p => String.eqb (fst (fn_slot p)) "bhv_merry_go_round_loop") all_av = true.
Proof. vm_compute. reflexivity. Qed.
