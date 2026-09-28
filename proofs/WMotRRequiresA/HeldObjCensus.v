(* spine-root: GOAL 2's coin-link groundwork, machine-checked -- the
   complete list of places the generated TUs can make Mario hold an object,
   the one route by which Mario's code moves another object (the drop / throw
   writes heldObj->oPosY; this is how cloning works).  A certificate, like
   YWriterCensus: it will be consumed by the coin-link row ("coin #2 never
   moves"), TRUST.md 0.3. *)
(* ======================================================================= *)
(* GOAL 2: CAN MARIO EVER HOLD SOMETHING?                                   *)
(*                                                                          *)
(* The coin link needs coin #2 to stay at y = 3140.  The only Mario-side    *)
(* code that moves another object is mario_drop_held_object /               *)
(* mario_throw_held_object, which write m->heldObj->oPos*.  So it suffices  *)
(* that heldObj stays NULL in a no-A WMotR run.  This file pins, over every *)
(* function of the generated code TUs (via global_definitions, never       *)
(* `prog`):                                                                  *)
(*   (1) every store to a MarioState's heldObj, and what it stores: all are *)
(*       NULL except one, in mario_grab_used_object, which stores usedObj;  *)
(*   (2) heldObj's address never escapes, so there are no other writers;    *)
(*   (3) the call sites of mario_grab_used_object;                          *)
(*   (4) every store to MarioState.input that can set the grab bit          *)
(*       INPUT_INTERACT_OBJ_GRABBABLE (0x800): only interact_grabbable.     *)
(* What stays open: that each call site in (3) is reached only after a      *)
(* grab check (an action-entry fact), and that WMotR spawns no              *)
(* INTERACT_GRABBABLE object (object census, TRUST.md 0.7).                 *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight.
From SM64.Generated Require mario mario_step mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_misc surface_collision
  math_util shadow.
Import ListNotations.

Local Open Scope Z_scope.

Definition MS : ident := mario._MarioState.
Definition HELD : ident := mario._heldObj.
Definition USED : ident := mario._usedObj.
Definition INPUT : ident := mario._input.
Definition GRAB_BIT : Z := 2048.   (* INPUT_INTERACT_OBJ_GRABBABLE, sm64.h:63 *)

(* `b.fld` with b a MarioState lvalue *)
Definition is_ms_field (fld : ident) (a : expr) : bool :=
  match a with
  | Efield b f _ =>
      Pos.eqb f fld && match typeof b with Tstruct id _ => Pos.eqb id MS | _ => false end
  | _ => false
  end.

(* the address of b.heldObj taken anywhere inside an expression *)
Fixpoint held_addr (a : expr) : nat :=
  match a with
  | Eaddrof b _ => (if is_ms_field HELD b then 1 else 0) + held_addr b
  | Efield b _ _ => held_addr b
  | Ederef b _ => held_addr b
  | Eunop _ b _ => held_addr b
  | Ebinop _ x y _ => held_addr x + held_addr y
  | Ecast b _ => held_addr b
  | _ => 0
  end%nat.

(* does an integer constant with the grab bit occur in the expression? *)
Fixpoint has_grab_const (a : expr) : bool :=
  match a with
  | Econst_int n _ => negb (Z.land (Int.unsigned n) GRAB_BIT =? 0)
  | Econst_long n _ => negb (Z.land (Int64.unsigned n) GRAB_BIT =? 0)
  | Efield b _ _ | Ederef b _ | Eaddrof b _ | Eunop _ b _ | Ecast b _ => has_grab_const b
  | Ebinop _ x y _ => has_grab_const x || has_grab_const y
  | _ => false
  end.

(* what a heldObj store writes *)
Inductive rhs := RNull | RUsedObj | RTemp (t : ident) | ROther.
Definition rhs_of (a : expr) : rhs :=
  match a with
  | Ecast (Econst_int n _) _ | Econst_int n _ => if Int.eq n Int.zero then RNull else ROther
  | Efield _ _ _ => if is_ms_field USED a then RUsedObj else ROther
  | Etempvar t _ => RTemp t
  | _ => ROther
  end.

Inductive ev :=
  | HeldStore (r : rhs)
  | HeldAddr                          (* &m->heldObj taken *)
  | GrabCall                          (* a call of mario_grab_used_object *)
  | InputStore (sets_grab : bool).    (* m->input := e; does e carry 0x800? *)

Definition callee_of (a : expr) : ident :=
  match a with Evar f _ => f | _ => 1%positive end.

Definition exprs_ev (al : list expr) : list ev :=
  flat_map (fun a => repeat HeldAddr (held_addr a)) al.

Fixpoint scan (s : statement) : list ev :=
  match s with
  | Sassign a1 a2 =>
      (if is_ms_field HELD a1 then [HeldStore (rhs_of a2)] else nil)
      ++ (if is_ms_field INPUT a1 then [InputStore (has_grab_const a2)] else nil)
      ++ exprs_ev [a1; a2]
  | Sset _ a => exprs_ev [a]
  | Scall _ f al =>
      (if Pos.eqb (callee_of f) interaction._mario_grab_used_object then [GrabCall] else nil)
      ++ exprs_ev (f :: al)
  | Sbuiltin _ _ _ al => exprs_ev al
  | Ssequence a b => scan a ++ scan b
  | Sifthenelse c a b => exprs_ev [c] ++ scan a ++ scan b
  | Sloop a b => scan a ++ scan b
  | Sreturn (Some a) => exprs_ev [a]
  | Sswitch a ls => exprs_ev [a] ++ scan_ls ls
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
  ++ scan_defs level_update.global_definitions
  ++ scan_defs mario_misc.global_definitions
  ++ scan_defs surface_collision.global_definitions
  ++ scan_defs math_util.global_definitions
  ++ scan_defs shadow.global_definitions.

From compcert Require Import Ctypesdefs.
From Coq Require Import String.

Definition name (p : ident * ev) : string := string_of_ident (fst p).

(* ----------------------------------------------------------------------- *)
(* The census, pinned.                                                      *)
(* ----------------------------------------------------------------------- *)
Definition show (e : ev) : string :=
  match e with
  | HeldStore RNull => "heldObj := NULL"
  | HeldStore RUsedObj => "heldObj := usedObj"
  | HeldStore (RTemp _) => "heldObj := temp"
  | HeldStore ROther => "heldObj := ?"
  | HeldAddr => "&heldObj"
  | GrabCall => "mario_grab_used_object()"
  | InputStore true => "input |= GRAB"
  | InputStore false => "input := ..."
  end.
Definition relevant (p : ident * ev) : bool :=
  match snd p with InputStore false => false | _ => true end.

(* (1)-(4) at once: every heldObj store, heldObj address, grab call and
   grab-bit store in the generated code.  No `&heldObj` occurs, so these
   stores are the only writers (2).  All stores are NULL except the one in
   mario_grab_used_object (1); only interact_grabbable sets the grab bit (4). *)
Lemma held_census_value :
  map (fun p => (name p, show (snd p))) (filter relevant census) = [
     ("init_mario", "heldObj := NULL");
     ("act_dive_slide", "mario_grab_used_object()");
     ("act_dive", "mario_grab_used_object()");
     ("act_crazy_box_bounce", "heldObj := NULL");
     ("act_water_shell_swimming", "heldObj := NULL");
     ("check_water_grab", "mario_grab_used_object()");
     ("check_common_submerged_cancels", "heldObj := NULL");
     ("act_picking_up", "mario_grab_used_object()");
     ("act_picking_up_bowser", "mario_grab_used_object()");
     ("mario_grab_used_object", "heldObj := temp");
     ("mario_drop_held_object", "heldObj := NULL");
     ("mario_throw_held_object", "heldObj := NULL");
     ("interact_grabbable", "input |= GRAB") ]%string.
Proof. vm_compute. reflexivity. Qed.

(* the temp mario_grab_used_object stores was loaded from m->usedObj *)
Fixpoint temp_sources (s : statement) : list (ident * bool) :=
  match s with
  | Sset t a => [(t, is_ms_field USED a)]
  | Ssequence a b | Sifthenelse _ a b | Sloop a b => temp_sources a ++ temp_sources b
  | _ => nil
  end.
Definition grab_store_temp : list ident :=
  flat_map (fun e => match e with HeldStore (RTemp t) => [t] | _ => nil end)
           (scan (fn_body interaction.f_mario_grab_used_object)).
Lemma grab_stores_usedObj :
  grab_store_temp = [interaction._t'3] /\
  In (interaction._t'3, true) (temp_sources (fn_body interaction.f_mario_grab_used_object)) /\
  forallb (fun p => negb (Pos.eqb (fst p) interaction._t'3) || snd p)
          (temp_sources (fn_body interaction.f_mario_grab_used_object)) = true.
Proof. vm_compute. auto 10. Qed.
