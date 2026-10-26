(* spine-root: GOAL 1 over the whole frame -- the ACTION-WRITER census of
   the objects phase and the camera, machine-checked on the generated code:
   the certificate behind the GOAL-1 content of the per-object rows
   Hobj_step_* (NoAImpliesNoFlyFrame's header).  A census, not yet a
   semantic carry: the narrow row "keeps action outside T" will be proved
   from it plus the object step's footprint. *)
(* ====================================================================== *)
(* WHO CAN WRITE MARIO'S ACTION OUTSIDE MARIO'S FRAME?                     *)
(*                                                                        *)
(* GOAL 1 over the frame needs: no object update and no camera code sets  *)
(* Mario's action into the no-A taint set T = {ACT_FLYING,                *)
(* ACT_FLYING_TRIPLE_JUMP, ACT_SHOT_FROM_CANNON} (Taint.is_tainted).       *)
(*                                                                        *)
(* 1. THE CLOSURE (clos): every internal function of the link (ObjTable.  *)
(*    lprogs, all its TUs; via prog_defs, as RoCensus) reachable from     *)
(*    area_update_objects and update_camera, with execute_mario_action    *)
(*    CUT (Mario's frame: the hole, covered by GOAL 1's frame proof).      *)
(*    Edges: the direct calls, and for an INDIRECT call every address-    *)
(*    taken function (an initializer's Init_addrof, or a function value   *)
(*    in a body) whose type is exactly the call site's function type:    *)
(*    Clight's exec_Scall requires classify_fun (typeof a) = fun_case_f   *)
(*    tyargs tyres cc and type_of_fundef f = Tfunction tyargs tyres cc,   *)
(*    so a call to a function of another type is stuck.  2217 functions;  *)
(*    the externals reached (osSetTimer, __osSiRawStartDma, osRecvMesg,   *)
(*    osSendMesg, bcopy, load_sequence, sqrtf) are GOAL 1's model-        *)
(*    boundary rows.                                                       *)
(* 2. THE CENSUS (census): in every body of clos, every store to a        *)
(*    MarioState's action field, every escape of its address (&b.action), *)
(*    every whole-MarioState assignment, and every call of the setter     *)
(*    family (set_mario_action, drop_and_set_mario_action,                *)
(*    hurt_and_set_mario_action, set_jumping_action) with its action      *)
(*    argument.  RESULT (census_value): exactly two events --             *)
(*      set_mario_action's own `m->action = action` store, and            *)
(*      set_mario_npc_dialog's set_mario_action(gMarioState,              *)
(*        ACT_READING_NPC_DIALOG = 0x20001306, arg), not in T.            *)
(*    No escape, no copy, no other setter call.  Since no setter but      *)
(*    set_jumping_action is address-taken, and set_jumping_action is not  *)
(*    in clos (setters_not_indirect), set_mario_action is entered in clos *)
(*    only from set_mario_npc_dialog, with that constant.                 *)
(* 3. mario_set_flag (gMarioStates[0].flags |= flag) has no direct call   *)
(*    and its address is never taken (mario_set_flag_uncalled).            *)
(* 4. The cannon shot: act_in_cannon (the only ACT_SHOT_FROM_CANNON       *)
(*    setter, Taint.v) is not in clos (cannon_out).                       *)
(* 5. For the footprint side: the functions of clos that store into ANY   *)
(*    MarioState field (ms_store_fns): object code moving / healing /     *)
(*    pushing Mario, the cap, the held object, and set_mario_action's     *)
(*    group helpers.                                                       *)
(*                                                                        *)
(* NOT covered (as YWriterCensus, TRUST 0.9): a store into Mario's action *)
(* cell through a pointer of another type (a cast MarioState pointer, an  *)
(* out-of-bounds index into another object): ruling it out is the         *)
(* object step's FOOTPRINT (its stores land in pool slots / SafeB blocks, *)
(* and gMarioStates is not SafeB); the semantics of set_mario_action on   *)
(* ACT_READING_NPC_DIALOG (its group helper returns the action unchanged) *)
(* is a walk of its body.  Both belong to the semantic row.               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Ctypesdefs Clightdefs.
From SM64.Generated Require mario area camera object_helpers mario_actions_cutscene mario_actions_automatic.
From SM64.Proofs Require Import LinkedTwelve Taint.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The call graph of the link, over-approximated.                       *)
(* ---------------------------------------------------------------------- *)

Definition is_fn_ty (t : type) : bool := match t with Tfunction _ _ _ => true | _ => false end.

(* the function idents an expression mentions as values (address taken) *)
Fixpoint fvals (a : expr) : list ident :=
  match a with
  | Evar x t => if is_fn_ty t then [x] else nil
  | Ederef a1 _ | Efield a1 _ _ | Eaddrof a1 _ | Eunop _ a1 _ | Ecast a1 _ => fvals a1
  | Ebinop _ a1 a2 _ => fvals a1 ++ fvals a2
  | _ => nil
  end.

Definition direct (f : expr) : option ident :=
  match f with Evar g t => if is_fn_ty t then Some g else None | _ => None end.

(* (direct callees, the function types of the indirect calls, function
   values taken).  An indirect call can only reach a function of exactly the
   call site's type: Clight's exec_Scall requires classify_fun (typeof a) =
   fun_case_f tyargs tyres cc and type_of_fundef f = Tfunction tyargs tyres cc;
   a call site of another type is stuck. *)
Fixpoint cg (s : statement) : list ident * list type * list ident :=
  match s with
  | Sassign l r => (nil, nil, fvals l ++ fvals r)
  | Sset _ a => (nil, nil, fvals a)
  | Scall _ f al =>
      match direct f with
      | Some g => ([g], nil, flat_map fvals al)
      | None =>
          (nil, match classify_fun (typeof f) with
                | fun_case_f args res cc => [Tfunction args res cc]
                | fun_default => nil
                end, fvals f ++ flat_map fvals al)
      end
  | Sbuiltin _ _ _ al => (nil, nil, flat_map fvals al)
  | Ssequence s1 s2 | Sloop s1 s2 =>
      let '(c1, i1, v1) := cg s1 in let '(c2, i2, v2) := cg s2 in (c1 ++ c2, i1 ++ i2, v1 ++ v2)
  | Sifthenelse c s1 s2 =>
      let '(c1, i1, v1) := cg s1 in let '(c2, i2, v2) := cg s2 in (c1 ++ c2, i1 ++ i2, fvals c ++ v1 ++ v2)
  | Slabel _ s1 => cg s1
  | Sswitch a sl => let '(c, i, v) := cg_ls sl in (c, i, fvals a ++ v)
  | Sreturn (Some a) => (nil, nil, fvals a)
  | _ => (nil, nil, nil)
  end
with cg_ls (sl : labeled_statements) : list ident * list type * list ident :=
  match sl with
  | LSnil => (nil, nil, nil)
  | LScons _ s sl' => let '(c1, i1, v1) := cg s in let '(c2, i2, v2) := cg_ls sl' in
                      (c1 ++ c2, i1 ++ i2, v1 ++ v2)
  end.

(* functions whose address an initializer holds (behavior scripts' natives,
   action tables, geo layouts) *)
Definition init_addrs (p : Clight.program) : list ident :=
  flat_map (fun '(id, g) =>
    match g with
    | Gvar v => flat_map (fun d => match d with Init_addrof x _ => [x] | _ => nil end) (gvar_init v)
    | _ => nil
    end) (prog_defs p).

(* every internal function whose address is taken anywhere in the link *)
Definition addr_taken : list ident :=
  inodup (filter (fun x => match fn_tab ! x with Some _ => true | None => false end)
    (flat_map init_addrs lprogs
     ++ flat_map (fun '(_, _, f) => let '(_, _, v) := cg (fn_body f) in v) all_fns)).

Definition tyb (t1 t2 : type) : bool := if type_eq t1 t2 then true else false.

(* the address-taken functions an indirect call of type t can reach *)
Definition targets (t : type) : list ident :=
  filter (fun x => match fn_tab ! x with
                   | Some (_, f) => tyb (type_of_function f) t
                   | None => false
                   end) addr_taken.

(* successors of a function: its direct callees, and every address-taken
   function of an indirect call site's type *)
Definition succ (x : ident) : list ident :=
  match fn_tab ! x with
  | Some (_, f) => let '(c, i, _) := cg (fn_body f) in c ++ flat_map targets i
  | None => nil
  end.

Fixpoint close (fuel : nat) (cut : list ident) (work seen : list ident) : list ident :=
  match fuel with
  | O => seen
  | S n =>
      match work with
      | nil => seen
      | x :: w =>
          if memi x seen || memi x cut then close n cut w seen
          else close n cut (succ x ++ w) (x :: seen)
      end
  end.

(* THE CLOSURE: the objects phase (area_update_objects) and the camera
   (update_camera), with Mario's frame (execute_mario_action) cut out *)
Definition hole : list ident := [mario._execute_mario_action].
Definition roots : list ident := [area._area_update_objects; camera._update_camera].
Definition clos : list ident := close 100000 hole roots nil.

Definition internal_of (x : ident) : bool := match fn_tab ! x with Some _ => true | None => false end.

(* ---------------------------------------------------------------------- *)
(* 2. The action writes inside the closure.                                *)
(* ---------------------------------------------------------------------- *)

Definition MS : ident := mario._MarioState.
Definition ACT : ident := mario._action.

Definition is_ms (t : type) : bool := match t with Tstruct id _ => Pos.eqb id MS | _ => false end.

(* b.action with b a MarioState *)
Definition is_act (a : expr) : bool :=
  match a with Efield b f _ => Pos.eqb f ACT && is_ms (typeof b) | _ => false end.

(* &b.action somewhere inside an expression *)
Fixpoint act_esc (a : expr) : bool :=
  match a with
  | Eaddrof b _ => is_act b || act_esc b
  | Ederef a1 _ | Efield a1 _ _ | Eunop _ a1 _ | Ecast a1 _ => act_esc a1
  | Ebinop _ a1 a2 _ => act_esc a1 || act_esc a2
  | _ => false
  end.

Inductive aev :=
  | AStore (rhs : option Z)              (* b.action := (a constant, or computed) *)
  | AEsc                                 (* &b.action escapes *)
  | ACopy                                (* a whole MarioState assigned *)
  | ASetter (g : ident) (arg : option Z) (* a setter-family call's action argument *)
  | ASetterShort (g : ident).            (* a setter call with < 2 arguments *)

Definition kconst (a : expr) : option Z :=
  match a with
  | Econst_int n _ => Some (Int.unsigned n)
  | Ecast (Econst_int n _) _ => Some (Int.unsigned n)
  | _ => None
  end.

Definition setters : list ident :=
  [mario._set_mario_action; mario._drop_and_set_mario_action;
   mario._hurt_and_set_mario_action; mario._set_jumping_action].

Fixpoint ascan (s : statement) : list aev :=
  match s with
  | Sassign l r =>
      (if is_act l then [AStore (kconst r)] else nil)
      ++ (if is_ms (typeof l) then [ACopy] else nil)
      ++ (if act_esc l || act_esc r then [AEsc] else nil)
  | Sset _ a => if act_esc a then [AEsc] else nil
  | Scall _ f al =>
      (match direct f with
       | Some g => if memi g setters then
                     match al with _ :: a :: _ => [ASetter g (kconst a)] | _ => [ASetterShort g] end
                   else nil
       | None => nil
       end)
      ++ (if existsb act_esc al || act_esc f then [AEsc] else nil)
  | Sbuiltin _ _ _ al => if existsb act_esc al then [AEsc] else nil
  | Ssequence s1 s2 | Sloop s1 s2 => ascan s1 ++ ascan s2
  | Sifthenelse c s1 s2 => (if act_esc c then [AEsc] else nil) ++ ascan s1 ++ ascan s2
  | Slabel _ s1 => ascan s1
  | Sswitch a sl => (if act_esc a then [AEsc] else nil) ++ ascan_ls sl
  | Sreturn (Some a) => if act_esc a then [AEsc] else nil
  | _ => nil
  end
with ascan_ls (sl : labeled_statements) : list aev :=
  match sl with LSnil => nil | LScons _ s sl' => ascan s ++ ascan_ls sl' end.

Definition census_of (x : ident) : list (ident * aev) :=
  match fn_tab ! x with
  | Some (_, f) => map (fun e => (x, e)) (ascan (fn_body f))
  | None => nil
  end.

Definition census : list (ident * aev) := flat_map census_of clos.

Definition show (p : ident * aev) : string * string :=
  (string_of_ident (fst p),
   match snd p with
   | AStore None => "store computed" | AStore (Some _) => "store const"
   | AEsc => "escape" | ACopy => "copy"
   | ASetter g None => "setter computed " ++ string_of_ident g
   | ASetter g (Some z) => if is_tainted (Int.repr z) then "setter TAINTED " ++ string_of_ident g
                            else "setter const " ++ string_of_ident g
   | ASetterShort g => "setter short " ++ string_of_ident g
   end)%string.

(* every store into a MarioState field, in the closure *)
Fixpoint mfs (s : statement) : list ident :=
  match s with
  | Sassign (Efield b f _) _ => if is_ms (typeof b) then [f] else nil
  | Sassign (Ederef (Ebinop _ (Efield b f _) _ _) _) _ => if is_ms (typeof b) then [f] else nil
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => mfs s1 ++ mfs s2
  | Slabel _ s1 => mfs s1
  | Sswitch _ sl => mfs_ls sl
  | _ => nil
  end
with mfs_ls (sl : labeled_statements) : list ident :=
  match sl with LSnil => nil | LScons _ s sl' => mfs s ++ mfs_ls sl' end.

Definition ms_stores : list (ident * ident) :=
  flat_map (fun x => match fn_tab ! x with
                     | Some (_, f) => map (fun g => (x, g)) (mfs (fn_body f))
                     | None => nil end) clos.

(* ---------------------------------------------------------------------- *)
(* 3. The census, pinned.                                                  *)
(* ---------------------------------------------------------------------- *)

Definition ACT_READING_NPC_DIALOG_Z : Z := 536875782.   (* 0x20001306 *)

Lemma clos_size : List.length clos = 2217%nat.
Proof. vm_compute. reflexivity. Qed.

(* THE CENSUS: two action events in the whole objects + camera closure *)
Lemma census_value :
  census = [(mario._set_mario_action, AStore None);
            (mario_actions_cutscene._set_mario_npc_dialog,
               ASetter mario._set_mario_action (Some ACT_READING_NPC_DIALOG_Z))].
Proof. vm_compute. reflexivity. Qed.

Lemma npc_dialog_not_tainted : is_tainted (Int.repr ACT_READING_NPC_DIALOG_Z) = false.
Proof. vm_compute. reflexivity. Qed.

(* no setter is reached by an indirect call inside clos *)
Lemma setters_not_indirect :
  map (fun g => memi g addr_taken) setters = [false; false; false; true]
  /\ memi mario._set_jumping_action clos = false.
Proof. split; vm_compute; reflexivity. Qed.

Lemma mario_set_flag_uncalled :
  filter (fun '(_, _, f) => negb (Nat.eqb (List.length (calls_to object_helpers._mario_set_flag (fn_body f))) 0))
    all_fns = nil
  /\ memi object_helpers._mario_set_flag addr_taken = false.
Proof. split; vm_compute; reflexivity. Qed.

Lemma cannon_out : memi mario_actions_automatic._act_in_cannon clos = false.
Proof. vm_compute. reflexivity. Qed.

(* the MarioState-field writers of clos (60 stores), for the footprint *)
Lemma ms_store_fns :
  map string_of_ident (inodup (map fst ms_stores)) =
    ["bhv_recovery_heart_loop"; "yoshi_give_present_loop"; "bhv_1up_interact";
     "mario_drop_held_object"; "mario_retrieve_cap"; "mario_lose_cap_to_enemy";
     "set_mario_pos"; "apply_platform_displacement"; "bhv_heave_ho_throw_mario_loop";
     "common_anchor_mario_behavior"; "cur_obj_push_mario_away"; "set_mario_action_cutscene";
     "set_mario_action_submerged"; "mario_set_forward_vel"; "set_mario_y_vel_based_on_fspeed";
     "set_mario_action_airborne"; "set_mario_action_moving"; "set_mario_action";
     "set_mario_npc_dialog"]%string
  /\ List.length ms_stores = 60%nat.
Proof. split; vm_compute; reflexivity. Qed.
