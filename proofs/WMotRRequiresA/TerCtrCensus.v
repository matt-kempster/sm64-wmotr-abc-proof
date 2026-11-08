(* spine-root: the census behind HeightFrame.Hobj_ter_ctr (ObjStep.ter_ctr_row,
   the terrain step's counter row), like CollisionCensus behind ter_row. *)
(* ======================================================================= *)
(* TerCtrCensus.v -- HOW MANY TIMES ONE TERRAIN UPDATE CAN LOAD SURFACES   *)
(* (GOAL 2 objects, 2026-11-08).                                           *)
(*                                                                         *)
(* The counter row ObjStep.ter_ctr_row says one terrain object's update    *)
(* (cur_obj_update on a node of list 11 / 9) grows gSurfacesAllocated by   *)
(* at most the object's budget (OW.sdyn: 12 for the box, 2 for the lid, 0  *)
(* for the coin formation; 0 in a time stop).  The budget is per LOAD      *)
(* (the meshes are pinned: ObjWorld.mesh_tris_pinned, coll_pin), so the    *)
(* row is true exactly when no update reaches load_object_collision_model  *)
(* (or any other counter writer) more than once.  This file checks that    *)
(* over the generated code, for every VM state of the terrain scripts      *)
(* (BhvVM.vm_tab, CollisionCensus.terrain_bhvs):                           *)
(*   - lookup (tab n b) f: a bound on the load_object_collision_model     *)
(*     calls one call of f makes, through its body and every nested call  *)
(*     (direct, and indirect through any address-taken function of the    *)
(*     right type), n levels deep (deeper = BIG); a loop around a call    *)
(*     that can load is BIG; another counter writer is BIG;               *)
(*   - upd n fuel st: the bound for one update entered at VM state st:    *)
(*     the command's handler (or, for CALL_NATIVE, the native), plus --   *)
(*     unless the command always returns BHV_PROC_BREAK (always_brk: its  *)
(*     handler's every return is 1) -- the worst successor state;        *)
(*   - ter_ctr_value: the worst start state, per terrain script.           *)
(* RESULT (vm): bhvExclamationBox 1, bhvCoinFormation 0, bhvCannonClosed   *)
(* 1 -- at two depths / fuels, so the bound is not a fuel artefact.  The   *)
(* cannon lid's last frame (its loop's CALL_NATIVE load, then the         *)
(* deactivate) is one of the lid's start states, so it is counted.  No    *)
(* FOUND: no terrain update loads twice.                                  *)
(* This is a census (evidence), not a proof of ter_ctr_row: that row stays *)
(* a premise of the capstones (TRUST.md, "terrain counter row").           *)
(* ======================================================================= *)
From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight Maps Ctypesdefs.
From SM64.Generated Require behavior_data behavior_script surface_load.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts AngleVelCensus BhvVM.
From SM64.Proofs.WMotRRequiresA Require CollisionCensus.
Import ListNotations.
Local Open Scope Z_scope.

Module CC := CollisionCensus.

(* the handler BehaviorCmdTable names for an opcode *)
Definition cmdtab : list init_data :=
  match find (fun p => Pos.eqb (fst p) behavior_script._BehaviorCmdTable) behavior_script.global_definitions with
  | Some (_, Gvar v) => gvar_init v | _ => nil end.
Definition handler (op : Z) : option ident :=
  match nth_error cmdtab (Z.to_nat op) with Some (Init_addrof f _) => Some f | _ => None end.

(* every return of the handler's body returns 1 (BHV_PROC_BREAK) *)
Fixpoint rets (s : statement) : list (option expr) :=
  match s with
  | Sreturn r => [r]
  | Ssequence a b | Sloop a b | Sifthenelse _ a b => rets a ++ rets b
  | Sswitch _ ls => rets_ls ls
  | Slabel _ a => rets a
  | _ => nil
  end
with rets_ls (ls : labeled_statements) : list (option expr) :=
  match ls with LSnil => nil | LScons _ a r => rets a ++ rets_ls r end.
Definition is1 (r : option expr) : bool :=
  match r with Some (Econst_int i _) => Int.eq i Int.one | _ => false end.
Definition always_brk (op : Z) : bool :=
  match handler op with
  | Some f => match CC.body_of f with
              | nil => false
              | bs => forallb (fun s => match rets s with nil => false | rs => forallb is1 rs end) bs end
  | None => false end.

(* the break commands: delay, end_repeat, end_loop, break, break_unused,
   deactivate, delay_var; end_repeat_continue (7) is not one *)
Lemma always_brk_value :
  map (fun op => (op, match handler op with Some f => string_of_ident f | None => ""%string end, always_brk op))
      [1;6;7;9;10;11;29;37]
  = [(1, "bhv_cmd_delay"%string, true); (6, "bhv_cmd_end_repeat"%string, true);
     (7, "bhv_cmd_end_repeat_continue"%string, false); (9, "bhv_cmd_end_loop"%string, true);
     (10, "bhv_cmd_break"%string, true); (11, "bhv_cmd_break_unused"%string, true);
     (29, "bhv_cmd_deactivate"%string, true); (37, "bhv_cmd_delay_var"%string, true)].
Proof. vm_compute. reflexivity. Qed.

(* the most load_object_collision_model calls a call makes (BIG: unbounded,
   or another counter writer) *)
Definition BIG : nat := 1000%nat.
Definition other_writers : list ident := filter (fun f => negb (Pos.eqb f CC.LOCM)) CC.surf_writers.

Section MC.
  Variable mcf : ident -> nat.     (* the callee bound, one level down *)
  Variable indf : type -> nat.     (* the bound for an indirect call of this type *)
  Fixpoint mcs (s : statement) : nat :=
    match s with
    | Scall _ (Evar g _) _ => mcf g
    | Scall _ fe _ => indf (typeof fe)
    | Ssequence a b => mcs a + mcs b
    | Sifthenelse _ a b => Nat.max (mcs a) (mcs b)
    | Sloop a b => if Nat.eqb (mcs a + mcs b) 0 then 0 else BIG
    | Sswitch _ ls => mcs_ls ls
    | Slabel _ a => mcs a
    | _ => 0
    end%nat
  with mcs_ls (ls : labeled_statements) : nat :=
    match ls with LSnil => 0 | LScons _ a r => mcs a + mcs_ls r end%nat.
End MC.

(* every function's type, from the TUs *)
Definition fty : PTree.t type :=
  fold_left (fun t defs => fold_left (fun t '(id, g) =>
    match g with
    | Gfun (Internal f) => PTree.set id (type_of_function f) t
    | Gfun (External _ targs tres cc) => PTree.set id (Tfunction targs tres cc) t
    | _ => t
    end) defs t) all_tus (PTree.empty _).
(* the function type a callee expression calls *)
Definition callty (ty : type) : type :=
  match ty with Tpointer t _ => t | t => t end.
Definition ty_matches (ty : type) (f : ident) : bool :=
  match PTree.get f fty with
  | Some t => if type_eq t (callty ty) then true else false
  | None => true
  end.

(* the functions whose address is taken: named outside a direct call's
   callee position in a body, or held in a table (a global's initializer) *)
Fixpoint evf (a : expr) : list ident :=
  match a with
  | Evar x (Tfunction _ _ _) => [x]
  | Eaddrof b _ | Ederef b _ | Efield b _ _ | Eunop _ b _ | Ecast b _ => evf b
  | Ebinop _ x y _ => evf x ++ evf y
  | _ => nil
  end.
Fixpoint sevf (s : statement) : list ident :=
  match s with
  | Sassign a b => evf a ++ evf b
  | Sset _ a => evf a
  | Scall _ fe al => match fe with Evar _ _ => nil | _ => evf fe end ++ flat_map evf al
  | Sbuiltin _ _ _ al => flat_map evf al
  | Ssequence a b | Sloop a b => sevf a ++ sevf b
  | Sifthenelse c a b => evf c ++ sevf a ++ sevf b
  | Sreturn (Some a) => evf a
  | Sswitch a ls => evf a ++ sevf_ls ls
  | Slabel _ a => sevf a
  | _ => nil
  end
with sevf_ls (ls : labeled_statements) : list ident :=
  match ls with LSnil => nil | LScons _ a r => sevf a ++ sevf_ls r end.
Definition addr_taken (code : list ident) : list ident :=
  filter (fun f => existsb (Pos.eqb f)
            (flat_map (fun x => flat_map sevf (CC.body_of x)
                                ++ match PTree.get x gvar_tab2 with Some r => r | None => nil end) code)) code.

(* one level of the bound, from the previous level's table *)
Definition lookup (t : list (ident * nat)) (g : ident) : nat :=
  if Pos.eqb g CC.LOCM then 1%nat
  else if existsb (Pos.eqb g) other_writers then BIG
  else match find (fun p => Pos.eqb (fst p) g) t with Some (_, n) => n | None => 0%nat end.
Definition step_tab (code ats : list ident) (t : list (ident * nat)) : list (ident * nat) :=
  let indf := fun ty => fold_left Nat.max (map (lookup t) (filter (ty_matches ty) ats)) 0%nat in
  map (fun f => (f, if Pos.eqb f CC.LOCM then 1%nat
                    else if existsb (Pos.eqb f) other_writers then BIG
                    else fold_left Nat.max (map (mcs (lookup t) indf) (CC.body_of f)) 0%nat)) code.
Fixpoint iter_tab (code ats : list ident) (n : nat) : list (ident * nat) :=
  match n with O => map (fun f => (f, BIG)) code | S n' => step_tab code ats (iter_tab code ats n') end.

(* one update, entered at VM state st *)
Definition op_of (st : vst) : Z := match word_at (v_s st) (v_i st) with Some w => Z.shiftr w 24 | None => -1 end.
Definition native_at (st : vst) : option ident :=
  match nth_error (words (v_s st)) (v_i st + 1) with Some (Init_addrof f _) => Some f | _ => None end.
(* the per-call bounds, n levels deep, computed once per script *)
Definition tab (n : nat) (b : ident) : list (ident * nat) :=
  let c := CC.code_of b in iter_tab c (addr_taken c) n.
Definition wst (t : list (ident * nat)) (st : vst) : nat :=
  if Z.eqb (op_of st) 12 then match native_at st with Some f => lookup t f | None => BIG end
  else match handler (op_of st) with Some f => lookup t f | None => BIG end.
Fixpoint upd (t : list (ident * nat)) (fuel : nat) (st : vst) : nat :=
  match fuel with O => BIG | S fuel' =>
    wst t st + (if always_brk (op_of st) then 0
                else match succs st with
                     | Some l => fold_left Nat.max (map (upd t fuel') l) 0
                     | None => BIG end) end%nat.

Definition ter_states : list vst := filter (fun st => existsb (Pos.eqb (v_s st)) CC.terrain_bhvs) vm_tab.
(* the worst start state of script b (its states run b's code: tab n b) *)
Definition worst (n fuel : nat) (b : ident) : nat :=
  let t := tab n b in
  fold_left Nat.max (map (upd t fuel) (filter (fun st => Pos.eqb (v_s st) b) ter_states)) 0%nat.

(* THE CENSUS: at most one load per update, per terrain script *)
Lemma ter_ctr_value :
  map (fun b => (string_of_ident b, worst 24 40 b, worst 48 80 b)) CC.terrain_bhvs
  = [("bhvExclamationBox"%string, 1%nat, 1%nat); ("bhvCoinFormation"%string, 0%nat, 0%nat);
     ("bhvCannonClosed"%string, 1%nat, 1%nat)].
Proof. vm_compute. reflexivity. Qed.
