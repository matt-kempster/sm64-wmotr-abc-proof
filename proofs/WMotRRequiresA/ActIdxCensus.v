(* spine-root: the oAction-STORE census behind obj_w's ACTION clause
   (ObjWorld.act_ok, ow_act: a slot running one of the 3 action-table
   behaviors has 0 <= oAction < its table's length) -- the carry
   certificate for cur_obj_call_action_function's tbl[o->oAction] bound
   (TRUST 3.2 UB worklist). *)
(* ====================================================================== *)
(* CAN tbl[o->oAction] READ OUT OF BOUNDS IN WMOTR?                        *)
(*                                                                        *)
(* cur_obj_call_action_function(tbl) runs tbl[o->oAction]() with no bounds *)
(* check.  The WMotR objects that call it are the three of                *)
(* ObjWorld.act_pairs: bhvJumpingBox (sJumpingBoxActions, 2 entries),     *)
(* bhvCannon (sOpenedCannonActions, 7), bhvExclamationBox                 *)
(* (sExclamationBoxActions, 6).  oAction is rawData.asS32[49].  Every way *)
(* the generated link writes it, machine-checked:                         *)
(*                                                                        *)
(* 1. THE BEHAVIOR'S OWN CODE (bclos B: the CALL_NATIVE targets of B's    *)
(*    reachable script states, BhvVM, closed under direct calls and the   *)
(*    table entries cur_obj_call_action_function is handed; no other      *)
(*    indirect call, bclos_indirect): every oAction store is a constant   *)
(*    in [0, len) or a helper's parameter that every call in bclos B     *)
(*    passes as such a constant (cur_obj_get_thrown_or_placed(.., 1),     *)
(*    cur_obj_unrender_set_action_and_anim(-1, 0) for the jumping box)    *)
(*    (own_stores_ok).                                                     *)
(* 2. THE GENERIC OBJECT STEP (gen_clos: area_update_objects and the 56   *)
(*    behavior-command handlers, under direct calls): no oAction store;  *)
(*    its computed-index rawData stores are the command handlers and      *)
(*    allocate_object's zeroing loop (value 0) (gen_census).              *)
(* 3. SCRIPTS: no reachable script state (BhvVM.vm_tab) runs a field-     *)
(*    writing command on field 49 (script_census).                        *)
(* 4. OTHER OBJECTS' CODE AND MARIO: every oAction store through a        *)
(*    pointer other than gCurrentObject in the whole link is listed       *)
(*    (other_stores); the only one in the WMotR closure (live_clos: the   *)
(*    live natives, Mario's frame included) is act_in_cannon's            *)
(*    m->usedObj->oAction = 2, behind INPUT_A_PRESSED, on the cannon      *)
(*    (in range of sOpenedCannonActions; a no-A run never executes it).   *)
(*    The others belong to natives no WMotR script reaches.               *)
(* 5. COMPUTED INDICES in live_clos: obj_translate_local (index 6..8),   *)
(*    obj_turn_toward_object (16), allocate_object (0) -- never 49        *)
(*    (computed_census); no &rawData escapes in the closure              *)
(*    (escape_census).                                                    *)
(*                                                                        *)
(* So, modulo the carry (a slot whose behavior is B runs B's script       *)
(* states; obj_w's CMDPOS clause pins the script side), every write of a  *)
(* B slot's oAction is in range: ow_act is carried.  For the objects       *)
(* agent: this is the certificate for the ow_act step of the object loop. *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Ctypesdefs Clightdefs.
From SM64.Generated Require object_helpers behavior_script area spawn_object mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus ActWriterCensus BhvVM BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjAct ObjWorld.
Import ListNotations.

Definition RAW : ident := object_helpers._rawData.
Definition GCUR : ident := object_helpers._gCurrentObject.
Definition OACT_IDX : Z := 49.

(* a rawData cell: (object expression, index expression) *)
Definition raw_cell (a : expr) : option (expr * expr) :=
  match a with
  | Ederef (Ebinop Oadd (Efield (Efield b fr _) _ _) i _) _ =>
      if Pos.eqb fr RAW then Some (b, i) else None
  | _ => None
  end.

Fixpoint cval (i : expr) : option Z :=
  match i with
  | Econst_int n _ => Some (Int.signed n)
  | Ebinop Oadd a b _ => match cval a, cval b with Some x, Some y => Some (x + y)%Z | _, _ => None end
  | Eunop Oneg a _ => match cval a with Some x => Some (- x)%Z | None => None end
  | Ecast a _ => cval a
  | _ => None
  end.

Fixpoint strip (a : expr) : expr := match a with Ecast a1 _ => strip a1 | _ => a end.

Fixpoint ssets (t : ident) (s : statement) : list expr :=
  match s with
  | Sset t' r => if Pos.eqb t t' then [r] else []
  | Scall (Some t') _ _ => if Pos.eqb t t' then [Econst_int Int.zero tint] else []
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => ssets t s1 ++ ssets t s2
  | Slabel _ s1 => ssets t s1
  | Sswitch _ sl => ssets_ls t sl
  | _ => []
  end
with ssets_ls (t : ident) (sl : labeled_statements) : list expr :=
  match sl with LSnil => [] | LScons _ s sl' => ssets t s ++ ssets_ls t sl' end.

Definition is_gcur (e : expr) : bool := match e with Evar x _ => Pos.eqb x GCUR | _ => false end.

(* the object expression is gCurrentObject (directly or via temps set only from it) *)
Definition cur_base (body : statement) (b : expr) : bool :=
  match b with
  | Ederef (Etempvar t _) _ => match ssets t body with nil => false | l => forallb is_gcur l end
  | Ederef (Evar x _) _ => Pos.eqb x GCUR
  | _ => false
  end.

(* every rawData store: (through gCurrentObject?, constant index?, value) *)
Fixpoint rst (body : statement) (s : statement) : list (bool * option Z * expr) :=
  match s with
  | Sassign l r =>
      match raw_cell l with
      | Some (b, i) => [(cur_base body b, cval i, r)]
      | None => []
      end
  | Ssequence s1 s2 | Sloop s1 s2 | Sifthenelse _ s1 s2 => rst body s1 ++ rst body s2
  | Slabel _ s1 => rst body s1
  | Sswitch _ sl => rst_ls body sl
  | _ => []
  end
with rst_ls (body : statement) (sl : labeled_statements) : list (bool * option Z * expr) :=
  match sl with LSnil => [] | LScons _ s sl' => rst body s ++ rst_ls body sl' end.

Definition stores_of (x : ident) : list (bool * option Z * expr) :=
  match fn_tab ! x with Some (_, f) => rst (fn_body f) (fn_body f) | None => [] end.

Definition is49 (o : option Z) : bool := match o with Some z => Z.eqb z OACT_IDX | None => false end.
Definition is_comp (o : option Z) : bool := match o with None => true | Some _ => false end.

(* ---------------------------------------------------------------------- *)
(* Closures.                                                                *)
(* ---------------------------------------------------------------------- *)

(* the CALL_NATIVE targets of B's reachable script states *)
Definition bstates (b : ident) : list vst := opt_list (explore 100000 (entries b) []).
Definition natives_of (b : ident) : list ident :=
  inodup (flat_map (fun st => match word_at (v_s st) (v_i st) with
     | Some w => if Z.eqb (Z.shiftr w 24) 12 then
                   match nth_error (words (v_s st)) (S (v_i st)) with Some (Init_addrof g _) => [g] | _ => [] end
                 else []
     | None => [] end) (bstates b)).

(* direct calls, plus the entries of the live tables handed to
   cur_obj_call_action_function *)
Definition caf_tables (f : function) : list ident :=
  filter (fun t => memi t ObjAct.live_tables)
    (flat_map (flat_map evars) (calls_to ObjAct.CAF (fn_body f))).

Definition bsucc (x : ident) : list ident :=
  match fn_tab ! x with
  | Some (_, f) => ObjAct.dcalls (fn_body f) ++ flat_map ObjAct.tentries (caf_tables f)
  | None => []
  end.

Fixpoint bclose (fuel : nat) (work seen : list ident) : list ident :=
  match fuel with O => seen | S n =>
    match work with
    | nil => seen
    | x :: w => if memi x seen then bclose n w seen else bclose n (bsucc x ++ w) (x :: seen)
    end end.

Definition bclos (b : ident) : list ident := bclose 100000 (natives_of b) [].

Definition cmdtab : list ident :=
  flat_map (fun d => match d with Init_addrof g _ => [g] | _ => [] end)
    (ObjAct.tinit behavior_script._BehaviorCmdTable).

Definition live_clos : list ident := bclose 100000 wmotr_live_natives [].
Definition gen_clos : list ident := bclose 100000 (area._area_update_objects :: cmdtab) [].

(* functions of a closure that make an indirect call (ObjAct.dcalls's 1) *)
Definition indirect_fns (cl : list ident) : list ident :=
  filter (fun x => match fn_tab ! x with
    | Some (_, f) => memi 1%positive (ObjAct.dcalls (fn_body f)) | None => false end) cl.

(* ---------------------------------------------------------------------- *)
(* 1. The behaviors' own stores.                                            *)
(* ---------------------------------------------------------------------- *)

Fixpoint index_of (x : ident) (l : list (ident * type)) (i : nat) : option nat :=
  match l with nil => None | (y, _) :: l' => if Pos.eqb x y then Some i else index_of x l' (S i) end.

Definition in_range (n : Z) (e : expr) : bool :=
  match cval e with Some c => Z.leb 0 c && Z.ltb c n | None => false end.

Definition calls_in (cl : list ident) (g : ident) : list (list expr) :=
  flat_map (fun x => match fn_tab ! x with
    | Some (_, f) => calls_to g (fn_body f) | None => [] end) cl.

(* a stored value: a constant in range, or parameter i of x that every call
   of x in cl passes as a constant in range *)
Definition val_ok (cl : list ident) (n : Z) (x : ident) (r : expr) : bool :=
  in_range n r ||
  match strip r, fn_tab ! x with
  | Etempvar p _, Some (_, f) =>
      match index_of p (fn_params f) 0 with
      | Some i => let cs := calls_in cl x in
                  negb (Nat.eqb (List.length cs) 0)
                  && forallb (fun al => match nth_error al i with
                                        | Some a => in_range n a | None => false end) cs
      | None => false
      end
  | _, _ => false
  end.

Definition own_ok (b t : ident) : bool :=
  let cl := bclos b in
  let n := ObjWorld.tlen t in
  forallb (fun x => forallb (fun '(_, i, r) => negb (is49 i) || val_ok cl n x r) (stores_of x)) cl.

Lemma act_natives :
  map (fun '(b, _) => map string_of_ident (natives_of b)) ObjWorld.act_pairs =
    [["bhv_jumping_box_loop"]; ["bhv_cannon_base_loop"]; ["bhv_exclamation_box_loop"]]%string.
Proof. vm_compute. reflexivity. Qed.


(* each behavior's closure hands cur_obj_call_action_function exactly its
   own table, and makes no other indirect call *)
Definition tables_of (b : ident) : list ident :=
  inodup (flat_map (fun x => match fn_tab ! x with Some (_, f) => caf_tables f | None => [] end) (bclos b)).

Lemma bclos_tables :
  forallb (fun '(b, t) => match tables_of b with [t'] => Pos.eqb t t' | _ => false end) ObjWorld.act_pairs = true
  /\ map (fun '(b, _) => map string_of_ident (indirect_fns (bclos b))) ObjWorld.act_pairs
     = [["cur_obj_call_action_function"]; ["cur_obj_call_action_function"];
        ["cur_obj_call_action_function"]]%string.
Proof. split; vm_compute; reflexivity. Qed.

(* THE OWN-STORE CENSUS: every oAction store in B's closure is in range of B's table *)
Lemma own_stores_ok : forallb (fun '(b, t) => own_ok b t) ObjWorld.act_pairs = true.
Proof. vm_compute. reflexivity. Qed.

(* non-vacuity: the stores it saw, per behavior (17) *)
Lemma own_stores_count :
  map (fun '(b, _) => List.length (flat_map (fun x => filter (fun '(_, i, _) => is49 i) (stores_of x)) (bclos b)))
    ObjWorld.act_pairs = [3; 6; 8]%nat.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The generic object step.                                              *)
(* ---------------------------------------------------------------------- *)

Definition comp_fns (cl : list ident) : list ident :=
  filter (fun x => existsb (fun '(_, i, _) => is_comp i) (stores_of x)) cl.

Lemma gen_census :
  forallb (fun x => forallb (fun '(_, i, _) => negb (is49 i)) (stores_of x)) gen_clos = true
  /\ forallb (fun x => memi x cmdtab || Pos.eqb x spawn_object._allocate_object) (comp_fns gen_clos) = true
  /\ map (fun '(_, i, r) => (i, cval r))
       (filter (fun '(_, i, _) => is_comp i) (stores_of spawn_object._allocate_object)) = [(None, Some 0%Z)].
Proof. vm_compute. auto. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. Scripts.                                                              *)
(* ---------------------------------------------------------------------- *)

(* opcodes whose handler stores rawData at a computed index *)
Definition writer_op (op : Z) : bool :=
  match nth_error cmdtab (Z.to_nat op) with
  | Some h => existsb (fun '(_, i, _) => is_comp i || is49 i) (stores_of h)
  | None => true
  end.

(* the field byte of every field-writing command (SET_INT, ADD_INT, OR_INT,
   BIT_CLEAR, SUM_INT, the random / float setters, LOAD_ANIMATIONS,
   PARENT_BIT_CLEAR, ANIMATE_TEXTURE, SET_INT_UNUSED) is bits 16..23 *)
Lemma script_census :
  List.length cmdtab = 56%nat
  /\ filter (fun st => match word_at (v_s st) (v_i st) with
       | Some w => writer_op (Z.shiftr w 24) && Z.eqb (Z.land (Z.shiftr w 16) 255) OACT_IDX
       | None => false end) vm_tab = [].
Proof. split; vm_compute; reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. Stores through another object pointer, link-wide.                    *)
(* ---------------------------------------------------------------------- *)

Definition other_stores : list (string * bool) :=
  flat_map (fun '(_, x, f) => map (fun _ => (string_of_ident x, memi x (live_clos ++ gen_clos)))
     (filter (fun '(c, i, _) => is49 i && negb c) (rst (fn_body f) (fn_body f)))) all_fns.

Lemma other_stores_value :
  other_stores =
    [("act_in_cannon", true); ("bowser_thrown_dropped_update", false);
     ("bhv_lll_bowser_puzzle_spawn_piece", false); ("snowmans_bottom_act_2", false);
     ("enemy_lakitu_sub_act_no_spiny", false); ("bhv_water_bomb_spawner_update", false);
     ("bhv_bookend_spawn_loop", false); ("bookshelf_manager_act_2", false);
     ("bhv_book_switch_loop", false)]%string.
Proof. vm_compute. reflexivity. Qed.

(* act_in_cannon's store is the constant 2 (sOpenedCannonActions has 7) *)
Lemma cannon_store :
  map (fun '(c, i, r) => (c, i, cval r))
    (filter (fun '(_, i, _) => is49 i) (stores_of mario_actions_automatic._act_in_cannon))
  = [(false, Some 49%Z, Some 2%Z)].
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 5. Computed indices and escapes.                                         *)
(* ---------------------------------------------------------------------- *)

Lemma computed_census :
  map string_of_ident (comp_fns live_clos)
    = ["obj_turn_toward_object"; "obj_translate_local"; "allocate_object"]%string
  /\ map (fun al => map cval al) (calls_in (live_clos ++ gen_clos) object_helpers._obj_translate_local)
     = [[None; Some 6%Z; Some 44%Z]]
  /\ map (fun al => map cval al) (calls_in (live_clos ++ gen_clos) object_helpers._obj_turn_toward_object)
     = [[None; None; Some 16%Z; Some 4096%Z]].
Proof. vm_compute. auto. Qed.

(* &rawData (or a cell of it) never escapes in the objects + camera closure *)
Fixpoint resc (a : expr) : bool :=
  match a with
  | Eaddrof b _ => match b with
                   | Efield _ fr _ => Pos.eqb fr RAW
                   | _ => match raw_cell b with Some _ => true | None => false end
                   end || resc b
  | Efield (Efield _ fr _) _ (Tarray _ _ _) => Pos.eqb fr RAW
  | Ederef a1 _ | Efield a1 _ _ | Eunop _ a1 _ | Ecast a1 _ => resc a1
  | Ebinop _ a1 a2 _ => match a with
                        | Ebinop Oadd (Efield (Efield _ fr _) _ _) i _ => resc i
                        | _ => resc a1 || resc a2 end
  | _ => false
  end.

Fixpoint rsc (s : statement) : bool :=
  match s with
  | Sassign l r => resc l || resc r
  | Sset _ r => resc r
  | Scall _ f al => existsb resc al
  | Sbuiltin _ _ _ al => existsb resc al
  | Ssequence s1 s2 | Sloop s1 s2 => rsc s1 || rsc s2
  | Sifthenelse c s1 s2 => resc c || rsc s1 || rsc s2
  | Slabel _ s1 => rsc s1
  | Sswitch a sl => resc a || rsc_ls sl
  | Sreturn (Some a) => resc a
  | _ => false
  end
with rsc_ls (sl : labeled_statements) : bool :=
  match sl with LSnil => false | LScons _ s sl' => rsc s || rsc_ls sl' end.

Lemma escape_census :
  filter (fun x => match fn_tab ! x with Some (_, f) => rsc (fn_body f) | None => false end)
    (clos ++ live_clos ++ gen_clos) = [].
Proof. vm_compute. reflexivity. Qed.
