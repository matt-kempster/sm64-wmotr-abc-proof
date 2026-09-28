(* spine-root: GOAL 2's pos[1] writer census, machine-checked -- the
   complete list of places the twelve linked TUs can change Mario's height,
   i.e. the site-by-site checklist Hframe_is_move_chain must discharge.  Not
   load-bearing for the capstone yet (it is a certificate, like
   Linked12Sat): it will be consumed when that row is walked per site. *)
(* ======================================================================= *)
(* GOAL 2: WHERE CAN MARIO'S HEIGHT CHANGE?                                 *)
(*                                                                          *)
(* Mario's height is MarioState.pos[1].  A frame can change it only by      *)
(*   (1) a store to an element of some MarioState's pos, or                 *)
(*   (2) a store through a pointer INTO pos, which the code must first      *)
(*       obtain by letting pos's address escape: a bare `m->pos` (the array *)
(*       decays to a pointer) or `&m->pos[i]`, passed to a call, kept in a  *)
(*       temp, stored, or returned.                                         *)
(* This file scans every function body of the twelve linked TUs             *)
(* (generated/*.v, via global_definitions -- never `prog`, whose composite  *)
(* env OOMs) and lists every event of kind (1) or (2), plus whole-struct    *)
(* MarioState copies.  `census_value` pins the list; docs/goal2-posy-       *)
(* writer-census.md is the human reading of it.                             *)
(*                                                                          *)
(* Not covered by the scan (TRUST.md 0.9): pointer arithmetic on a          *)
(* MarioState pointer other than field access (none is expected in the      *)
(* decomp); and code outside the twelve TUs that receives a MarioState      *)
(* pointer (GOAL 1's external rows say what those may do).                  *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight.
From SM64.Generated Require mario mario_step mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update.
Import ListNotations.

Local Open Scope Z_scope.

Definition MS : ident := mario._MarioState.
Definition POS : ident := mario._pos.

(* `b.pos` with b a MarioState lvalue *)
Definition is_pos (a : expr) : bool :=
  match a with
  | Efield b f _ =>
      Pos.eqb f POS && match typeof b with Tstruct id _ => Pos.eqb id MS | _ => false end
  | _ => false
  end.

Definition cidx (i : expr) : Z :=
  match i with
  | Econst_int n _ => Int.signed n
  | Ecast (Econst_int n _) _ => Int.signed n
  | _ => -1
  end.

(* the pos-escapes of an expression: -1 = the whole vector (decayed),
   k >= 0 = &pos[k], -2 = &pos[non-constant] *)
Fixpoint esc (a : expr) : list Z :=
  match a with
  | Ederef (Ebinop Oadd p i _) _ =>
      if is_pos p then esc i            (* an element READ: no escape *)
      else esc p ++ esc i
  | Eaddrof (Ederef (Ebinop Oadd p i _) _) _ =>
      if is_pos p then (if cidx i <? 0 then -2 else cidx i) :: esc i
      else esc p ++ esc i
  (* &pos[i] is normalized by clightgen to the address arithmetic pos + i *)
  | Ebinop Oadd p i _ =>
      if is_pos p then (if cidx i <? 0 then -2 else cidx i) :: esc i
      else esc p ++ esc i
  | Efield b _ _ => if is_pos a then [-1] else esc b
  | Ederef b _ => esc b
  | Eaddrof b _ => esc b
  | Eunop _ b _ => esc b
  | Ebinop _ x y _ => esc x ++ esc y
  | Ecast b _ => esc b
  | _ => nil
  end.

Inductive ev :=
  | Store (k : Z)                      (* pos[k] := ...  (k = -1: non-constant) *)
  | EscCall (callee : ident) (arg : nat) (k : Z)
  | EscSet (k : Z)                     (* kept in a temp *)
  | EscStore (k : Z)                   (* stored to memory *)
  | EscOther (k : Z)                   (* a condition, return, switch, ... *)
  | StructCopy.                        (* a whole MarioState assignment *)

Definition callee_of (a : expr) : ident :=
  match a with Evar f _ => f | _ => 1%positive end.

Fixpoint args_esc (callee : ident) (n : nat) (al : list expr) : list ev :=
  match al with
  | nil => nil
  | a :: r => map (EscCall callee n) (esc a) ++ args_esc callee (S n) r
  end.

(* the lvalue side of an assignment *)
Definition lhs_ev (a : expr) : list ev :=
  match a with
  | Ederef (Ebinop Oadd p i _) _ =>
      if is_pos p then Store (cidx i) :: map EscOther (esc i)
      else map EscOther (esc p ++ esc i)
  | _ => map EscOther (esc a)
  end.

Definition is_ms_type (t : type) : bool :=
  match t with Tstruct id _ => Pos.eqb id MS | _ => false end.

Fixpoint scan (s : statement) : list ev :=
  match s with
  | Sassign a1 a2 =>
      (if is_ms_type (typeof a1) then [StructCopy] else nil)
      ++ lhs_ev a1 ++ map EscStore (esc a2)
  | Sset _ a => map EscSet (esc a)
  | Scall _ f al => map EscOther (esc f) ++ args_esc (callee_of f) O al
  | Sbuiltin _ _ _ al => args_esc 1%positive O al
  | Ssequence a b => scan a ++ scan b
  | Sifthenelse c a b => map EscOther (esc c) ++ scan a ++ scan b
  | Sloop a b => scan a ++ scan b
  | Sreturn (Some a) => map EscOther (esc a)
  | Sswitch a ls => map EscOther (esc a) ++ scan_ls ls
  | Slabel _ a => scan a
  | _ => nil
  end
with scan_ls (ls : labeled_statements) : list ev :=
  match ls with
  | LSnil => nil
  | LScons _ a r => scan a ++ scan_ls r
  end.

Definition scan_defs (defs : list (ident * globdef fundef type)) : list (ident * ev) :=
  flat_map (fun '(id, g) =>
    match g with
    | Gfun (Internal f) => map (fun e => (id, e)) (scan (fn_body f))
    | _ => nil
    end) defs.

Definition census : list (ident * ev) :=
  scan_defs mario.global_definitions
  ++ scan_defs mario_step.global_definitions
  ++ scan_defs mario_actions_stationary.global_definitions
  ++ scan_defs mario_actions_moving.global_definitions
  ++ scan_defs mario_actions_airborne.global_definitions
  ++ scan_defs mario_actions_submerged.global_definitions
  ++ scan_defs mario_actions_cutscene.global_definitions
  ++ scan_defs mario_actions_automatic.global_definitions
  ++ scan_defs mario_actions_object.global_definitions
  ++ scan_defs interaction.global_definitions
  ++ scan_defs behavior_actions.global_definitions
  ++ scan_defs level_update.global_definitions.

From compcert Require Import Ctypesdefs.
From Coq Require Import String.

(* ----------------------------------------------------------------------- *)
(* The census, pinned.                                                      *)
(* ----------------------------------------------------------------------- *)
Definition y_store (p : ident * ev) : bool :=
  match snd p with Store k => (k =? 1) || (k <? 0) | _ => false end.
Definition only_store_or_call (p : ident * ev) : bool :=
  match snd p with Store _ | EscCall _ _ _ => true | _ => false end.

(* 1. pos's address never goes into a temp, into memory, into a condition or
      a return, and no whole MarioState is copied: every event is a direct
      element store or an escape straight into a call argument. *)
Lemma census_shape : List.length census = 133%nat /\ forallb only_store_or_call census = true.
Proof. vm_compute. auto. Qed.

(* 2. the direct stores to pos[1] (none uses a non-constant index) *)
Definition y_store_sites : list string :=
  map (fun p => string_of_ident (fst p)) (filter y_store census).
Lemma y_store_sites_value : y_store_sites = [
     "update_mario_pos_for_anim"; "set_water_plunge_action"; "init_mario";
     "stop_and_set_height_to_floor"; "stationary_ground_step"; "perform_air_quarter_step";
     "perform_air_quarter_step"; "perform_air_quarter_step"; "perform_air_quarter_step";
     "perform_air_quarter_step"; "act_shockwave_bounce"; "act_shockwave_bounce";
     "align_with_floor"; "act_ground_pound"; "act_riding_hoot";
     "act_caught_in_whirlpool"; "check_common_submerged_cancels"; "end_peach_cutscene_run_to_peach";
     "set_pole_position"; "set_pole_position"; "set_pole_position";
     "set_pole_position"; "update_hang_stationary"; "let_go_of_ledge";
     "let_go_of_ledge"; "act_in_cannon"; "act_in_cannon";
     "act_tornado_twirling"; "act_tornado_twirling"; "bounce_off_object";
     "check_instant_warp" ]%string.
Proof. vm_compute. reflexivity. Qed.

(* 3. escapes a callee writes through.  Callee semantics (TRUST.md 0.9):
      vec3f_copy / vec3f_set / vec3s_to_vec3f write their arg 0 (math_util.c);
      f32_find_wall_collision writes *yPtr back UNCHANGED (arg 1,
      surface_collision.c).  vec3f_copy's arg 1, vec3f_find_ceil's arg 0 and
      mtxf_align_terrain_triangle's arg 1 are only read. *)
Definition writes_through (callee : ident) (n : nat) : bool :=
  match n with
  | O => Pos.eqb callee mario._vec3f_copy || Pos.eqb callee mario._vec3f_set
         || Pos.eqb callee mario._vec3s_to_vec3f
  | S O => Pos.eqb callee mario._f32_find_wall_collision
  | _ => false
  end.
Definition y_escape_write (p : ident * ev) : bool :=
  match snd p with
  | EscCall c n k => ((k =? 1) || (k <? 0)) && writes_through c n
  | _ => false
  end.
Definition y_escape_sites : list (string * string) :=
  map (fun p => match snd p with
                | EscCall c _ _ => (string_of_ident (fst p), string_of_ident c)
                | _ => (""%string, ""%string)
                end) (filter y_escape_write census).
Lemma y_escape_sites_value : y_escape_sites = [
     ("update_mario_geometry_inputs", "f32_find_wall_collision");
     ("update_mario_geometry_inputs", "f32_find_wall_collision");
     ("update_mario_geometry_inputs", "vec3f_copy");
     ("init_mario", "vec3s_to_vec3f");
     ("perform_ground_quarter_step", "vec3f_copy");
     ("perform_ground_quarter_step", "vec3f_set");
     ("check_ledge_grab", "vec3f_copy");
     ("perform_air_quarter_step", "vec3f_copy");
     ("perform_air_quarter_step", "vec3f_copy");
     ("perform_water_full_step", "vec3f_copy");
     ("perform_water_full_step", "vec3f_set");
     ("perform_water_full_step", "vec3f_set");
     ("act_debug_free_move", "vec3f_copy");
     ("jumbo_star_cutscene_taking_off", "vec3f_set");
     ("jumbo_star_cutscene_flying", "vec3f_copy");
     ("set_pole_position", "f32_find_wall_collision");
     ("set_pole_position", "f32_find_wall_collision");
     ("perform_hanging_step", "vec3f_copy");
     ("act_grabbed", "vec3f_copy");
     ("act_tornado_twirling", "vec3f_copy");
     ("push_mario_out_of_object", "f32_find_wall_collision") ]%string.
Proof. vm_compute. reflexivity. Qed.

(* every other escape of pos (or of &pos[1]) goes to a read-only argument *)
Definition read_only_escape (p : ident * ev) : bool :=
  match snd p with
  | EscCall c n k =>
      negb ((k =? 1) || (k <? 0)) || writes_through c n
      || (Pos.eqb c mario._vec3f_copy && Nat.eqb n 1)
      || (Pos.eqb c mario._vec3f_find_ceil && Nat.eqb n 0)
      || (Pos.eqb c mario_actions_moving._mtxf_align_terrain_triangle && Nat.eqb n 1)
  | _ => true
  end.
Lemma other_escapes_read_only : forallb read_only_escape census = true.
Proof. vm_compute. reflexivity. Qed.

(* THE CENSUS: inside the twelve linked TUs, Mario's height can change at
   exactly these 31 + 21 = 52 sites (code outside them: TRUST.md 0.9). *)
Lemma y_writer_count : (List.length y_store_sites + List.length y_escape_sites = 52)%nat.
Proof. rewrite y_store_sites_value, y_escape_sites_value. reflexivity. Qed.
