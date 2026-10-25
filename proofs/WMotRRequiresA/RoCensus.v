(* spine-root: OBJECTS S3 groundwork -- the READ-ONLY census for the action
   tables (cur_obj_call_action_function's argument) and the behavior
   scripts (behavior_data's globals): which code anywhere in the link can
   store into them, and where their addresses go.  A census, not a proof:
   it scopes the RO class (open items (c) / (e) of ObjFrame). *)
(* ====================================================================== *)
(* RoCensus.v                                                             *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Maps AST Integers Ctypes Cop Clight Ctypesdefs Clightdefs.
From SM64.Generated Require mario behavior_data behavior_script object_helpers obj_behaviors.
From SM64.Proofs Require Import LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable.
Import ListNotations.

Definition memi (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Fixpoint inodup (l : list ident) : list ident :=
  match l with
  | nil => nil
  | x :: l' => let t := inodup l' in if memi x t then t else x :: t
  end.

(* every internal function of the link, with its TU index in lprogs *)
Definition tu_fns (i : nat) (p : Clight.program) : list (nat * ident * function) :=
  flat_map (fun '(id, g) =>
    match g with Gfun (Internal f) => [(i, id, f)] | _ => nil end) (prog_defs p).

Fixpoint idx_fns (i : nat) (l : list Clight.program) : list (nat * ident * function) :=
  match l with nil => nil | p :: l' => tu_fns i p ++ idx_fns (S i) l' end.

Definition all_fns : list (nat * ident * function) := idx_fns O lprogs.

Definition fn_tab : PTree.t (nat * function) :=
  fold_left (fun t '(i, id, f) => match t ! id with Some _ => t | None => PTree.set id (i, f) t end)
    all_fns (PTree.empty _).

(* ---------------------------------------------------------------------- *)
(* The RO candidates.                                                      *)
(* ---------------------------------------------------------------------- *)

Fixpoint evars (a : expr) : list ident :=
  match a with
  | Evar x _ => [x]
  | Ederef a1 _ | Efield a1 _ _ | Eaddrof a1 _ | Eunop _ a1 _ | Ecast a1 _ => evars a1
  | Ebinop _ a1 a2 _ => evars a1 ++ evars a2
  | _ => nil
  end.

Fixpoint calls_to (g : ident) (s : statement) : list (list expr) :=
  match s with
  | Scall _ (Evar h _) args => if Pos.eqb g h then [args] else nil
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => calls_to g s1 ++ calls_to g s2
  | Slabel _ s1 => calls_to g s1
  | Sswitch _ sl => calls_to_ls g sl
  | _ => nil
  end
with calls_to_ls (g : ident) (sl : labeled_statements) : list (list expr) :=
  match sl with LSnil => nil | LScons _ s sl' => calls_to g s ++ calls_to_ls g sl' end.

(* (A) every global handed to cur_obj_call_action_function, in any TU *)
Definition act_tables : list ident :=
  inodup (flat_map (fun '(_, _, f) =>
    flat_map (flat_map evars) (calls_to object_helpers._cur_obj_call_action_function (fn_body f)))
    all_fns).

(* (B) behavior_data's defined variables: the behavior scripts *)
Definition bhv_scripts : list ident :=
  flat_map (fun '(id, g) =>
    match g with Gvar v => match gvar_init v with nil => nil | _ => [id] end | _ => nil end)
    (prog_defs behavior_data.prog).

Definition ro_syms : list ident := act_tables ++ bhv_scripts.

(* ---------------------------------------------------------------------- *)
(* The flow analysis.                                                      *)
(*                                                                         *)
(* A value is TRACKED if it may be (derived from) the address of an RO      *)
(* symbol: an RO array as an rvalue (its address), a tracked temp, pointer  *)
(* arithmetic / casts of a tracked value, or a load from a HOLDER (a global  *)
(* or a struct field a tracked value has been stored into, or an           *)
(* initializer that holds an RO address).  The holders grow to a fixpoint. *)
(* A store whose target block may be RO is SStore -- the sites that break  *)
(* the "never a store target" fact.                                         *)
(* ---------------------------------------------------------------------- *)

(* HG g: global g; HF f: struct field f (by name); HR u o: the 4-byte
   cell at byte offset o of union u (any member, any view: a pointer can
   only be read back by a same-size load at the same offset); HRA u: union
   u at an unknown offset; HU: unknown *)
Inductive holder := HG (g : ident) | HF (f : ident) | HR (u : ident) (o : Z) | HRA (u : ident) | HU.

Definition holder_beq (a b : holder) : bool :=
  match a, b with
  | HG x, HG y | HF x, HF y | HRA x, HRA y => Pos.eqb x y
  | HR x o, HR y p => Pos.eqb x y && Z.eqb o p
  | HU, HU => true
  | _, _ => false
  end.

Definition hmem (h : holder) (l : list holder) : bool := existsb (holder_beq h) l.

(* a load from h may read a value stored into a holder of l *)
Definition hhit (h : holder) (l : list holder) : bool :=
  existsb (fun x =>
    match h, x with
    | HR u _, HRA v | HRA u, HR v _ | HRA u, HRA v => Pos.eqb u v
    | _, _ => holder_beq h x
    end) l.

Definition by_ref (ty : type) : bool :=
  match ty with
  | Tarray _ _ _ | Tfunction _ _ _ | Tstruct _ _ | Tunion _ _ => true
  | _ => false
  end.

Definition esz (ty : type) : Z :=
  match ty with
  | Tint I8 _ _ | Tint IBool _ _ => 1
  | Tint I16 _ _ => 2
  | Tlong _ _ | Tfloat F64 _ => 8
  | _ => 4
  end.

Fixpoint cint (a : expr) : option Z :=
  match a with
  | Econst_int k _ => Some (Int.signed k)
  | Ecast a1 _ => cint a1
  | Ebinop Oadd a1 a2 _ =>
      match cint a1, cint a2 with Some x, Some y => Some (x + y) | _, _ => None end
  | Ebinop Omul a1 a2 _ =>
      match cint a1, cint a2 with Some x, Some y => Some (x * y) | _, _ => None end
  | _ => None
  end.

Definition uni (b : expr) : option ident :=
  match typeof b with Tunion u _ => Some u | _ => None end.

(* the array a pointer expression decays from, if any (u: union-precise) *)
Fixpoint phold (u : bool) (p : expr) : holder :=
  match p with
  | Ebinop _ p1 _ _ | Ecast p1 _ => phold u p1
  | Evar g ty => if by_ref ty then HG g else HU
  | Efield b f ty =>
      if by_ref ty then
        match u, uni b with true, Some un => HRA un | _, _ => HF f end
      else HU
  | _ => HU
  end.

(* where an lvalue lives, as a holder *)
Definition lhold (u : bool) (l : expr) : holder :=
  match l with
  | Evar g _ => HG g
  | Efield b f _ => match u, uni b with true, Some un => HR un 0 | _, _ => HF f end
  | Ederef p _ =>
      match u, p with
      | true, Ebinop Oadd (Efield c _ (Tarray elt _ _)) idx _ =>
          match uni c with
          | Some un => match cint idx with Some k => HR un (k * esz elt) | None => HRA un end
          | None => phold u p
          end
      | _, _ => phold u p
      end
  | _ => HU
  end.

Record env := { e_src : list ident; e_hold : list holder; e_tmp : list ident; e_deep : bool; e_un : bool }.

(* the types whose values can be pointers (ILP32: a pointer survives a cast
   to a 32-bit int and int arithmetic, never a float, a short, a byte or a
   64-bit long -- such loads / casts of a pointer give Vundef) *)
Definition ptr_ok (ty : type) : bool :=
  match ty with
  | Tpointer _ _ | Tint I32 _ _ | Tarray _ _ _ | Tfunction _ _ _ | Tstruct _ _ | Tunion _ _ => true
  | _ => false
  end.

Fixpoint tv (E : env) (a : expr) : bool :=
  ptr_ok (typeof a) &&
  match a with
  | Evar x ty => if by_ref ty then memi x (e_src E) else hmem (HG x) (e_hold E)
  | Etempvar t _ => memi t (e_tmp E)
  | Ederef p ty =>
      if by_ref ty then tv E p
      else hhit (lhold (e_un E) a) (e_hold E) || (e_deep E && tv E p)
  | Efield b f ty =>
      if by_ref ty then lv E b
      else hhit (lhold (e_un E) a) (e_hold E) || (e_deep E && lv E b)
  | Eaddrof l _ => lv E l
  | Ecast a1 _ => tv E a1
  | Ebinop op a1 a2 _ =>
      match op with Oadd | Osub => tv E a1 || tv E a2 | _ => false end
  | _ => false
  end
with lv (E : env) (l : expr) : bool :=
  match l with
  | Evar x _ => memi x (e_src E)
  | Ederef p _ => tv E p
  | Efield b _ _ => lv E b
  | _ => false
  end.

Inductive kind :=
  | KStore                          (* store whose target may be an RO block *)
  | KVal (h : holder)               (* tracked value stored into h *)
  | KSet (t : ident)                (* tracked value into temp t *)
  | KArg (callee : ident) (i : nat) (* tracked value passed as argument i *)
  | KArgInd                         (* ... to an indirect call *)
  | KBuiltin                        (* ... to a builtin *)
  | KRet.                           (* ... returned *)

Fixpoint arg_sites (E : env) (callee : option ident) (i : nat) (al : list expr) : list kind :=
  match al with
  | nil => nil
  | a :: al' =>
      (if tv E a then [match callee with Some g => KArg g i | None => KArgInd end] else nil)
      ++ arg_sites E callee (S i) al'
  end.

Fixpoint any_tracked_arg (E : env) (g : ident) (rc : list (ident * nat)) (i : nat) (al : list expr) : bool :=
  match al with
  | nil => false
  | a :: al' =>
      (tv E a && existsb (fun '(h, j) => Pos.eqb g h && Nat.eqb i j) rc)
      || any_tracked_arg E g rc (S i) al'
  end.

(* rc: (callee, i) whose return may carry argument i; rg: callees whose
   return may be tracked regardless *)
Fixpoint ksites (E : env) (rc : list (ident * nat)) (rg : list ident) (s : statement) : list kind :=
  match s with
  | Sassign l r =>
      (if lv E l then [KStore] else nil) ++ (if tv E r then [KVal (lhold (e_un E) l)] else nil)
  | Sset t a => if tv E a then [KSet t] else nil
  | Scall o f al =>
      let cal := match f with Evar g _ => Some g | _ => None end in
      arg_sites E cal O al ++
      match o, cal with
      | Some t, Some g => if memi g rg || any_tracked_arg E g rc O al then [KSet t] else nil
      | _, _ => nil
      end
  | Sbuiltin _ _ _ al => if existsb (tv E) al then [KBuiltin] else nil
  | Sreturn (Some a) => if tv E a then [KRet] else nil
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => ksites E rc rg s1 ++ ksites E rc rg s2
  | Slabel _ s1 => ksites E rc rg s1
  | Sswitch _ sl => ksites_ls E rc rg sl
  | _ => nil
  end
with ksites_ls (E : env) (rc : list (ident * nat)) (rg : list ident) (sl : labeled_statements) : list kind :=
  match sl with LSnil => nil | LScons _ s sl' => ksites E rc rg s ++ ksites_ls E rc rg sl' end.

Definition ksets (l : list kind) : list ident :=
  flat_map (fun k => match k with KSet t => [t] | _ => nil end) l.

(* the temps of one body, to a fixpoint *)
Fixpoint fn_sites (fuel : nat) (src : list ident) (hold : list holder) (deep un : bool)
    (rc : list (ident * nat)) (rg : list ident) (tmp : list ident) (f : function) : list kind :=
  let ks := ksites {| e_src := src; e_hold := hold; e_tmp := tmp; e_deep := deep; e_un := un |} rc rg (fn_body f) in
  match fuel with
  | O => ks
  | S fuel' =>
      let tmp' := inodup (tmp ++ ksets ks) in
      if Nat.eqb (List.length tmp') (List.length tmp) then ks
      else fn_sites fuel' src hold deep un rc rg tmp' f
  end.

(* ---------------------------------------------------------------------- *)
(* The whole-link fixpoint.                                                *)
(* ---------------------------------------------------------------------- *)

(* the initializers holding an RO address *)
Definition init_refs : list (nat * ident * bool) :=
  let fix go (i : nat) (l : list Clight.program) :=
    match l with
    | nil => nil
    | p :: l' =>
        flat_map (fun '(id, g) =>
          match g with
          | Gvar v =>
              if existsb (fun d => match d with Init_addrof x _ => memi x ro_syms | _ => false end)
                   (gvar_init v)
              then [(i, id, gvar_readonly v)] else nil
          | _ => nil
          end) (prog_defs p) ++ go (S i) l'
    end in
  go O lprogs.

Definition init_holders : list holder := map (fun '(_, id, _) => HG id) init_refs.

(* a site record: TU, function, seeded parameter (None: the global run), kind *)
Definition srec : Type := (nat * ident * option nat * kind)%type.

Definition param_name (f : function) (i : nat) : option ident :=
  option_map fst (nth_error (fn_params f) i).

(* one round: every function unseeded, then every (callee, i) seeded *)
Definition round (hold : list holder) (rc : list (ident * nat)) (rg : list ident)
    (deep un : bool) (pairs : list (ident * nat)) : list srec :=
  flat_map (fun '(i, id, f) =>
    map (fun k => (i, id, None, k)) (fn_sites 6 ro_syms hold deep un rc rg nil f)) all_fns
  ++ flat_map (fun '(g, j) =>
       match fn_tab ! g with
       | Some (i, f) =>
           match param_name f j with
           | Some t => map (fun k => (i, g, Some j, k)) (fn_sites 6 nil hold deep un rc rg [t] f)
           | None => nil
           end
       | None => nil
       end) pairs.

Definition hnodup (l : list holder) : list holder :=
  fold_right (fun h t => if hmem h t then t else h :: t) nil l.

Definition pnodup (l : list (ident * nat)) : list (ident * nat) :=
  fold_right (fun '(g, j) t =>
    if existsb (fun '(h, k) => Pos.eqb g h && Nat.eqb j k) t then t else (g, j) :: t) nil l.

Definition new_holders (rs : list srec) : list holder :=
  flat_map (fun '(_, _, _, k) => match k with KVal HU => nil | KVal h => [h] | _ => nil end) rs.

Definition new_pairs (rs : list srec) : list (ident * nat) :=
  flat_map (fun '(_, _, _, k) => match k with KArg g j => [(g, j)] | _ => nil end) rs.

Definition new_rc (rs : list srec) : list (ident * nat) :=
  flat_map (fun '(_, g, o, k) => match o, k with Some j, KRet => [(g, j)] | _, _ => nil end) rs.

Definition new_rg (rs : list srec) : list ident :=
  flat_map (fun '(_, g, o, k) => match o, k with None, KRet => [g] | _, _ => nil end) rs.

Record st := { s_hold : list holder; s_rc : list (ident * nat); s_rg : list ident;
               s_pairs : list (ident * nat); s_out : list srec }.

Fixpoint fix_run (fuel : nat) (deep un : bool) (ex : list holder) (S0 : st) : st :=
  let rs := round (s_hold S0) (s_rc S0) (s_rg S0) deep un (s_pairs S0) in
  let S1 := {| s_hold := hnodup (s_hold S0 ++ filter (fun h => negb (hmem h ex)) (new_holders rs));
               s_rc := pnodup (s_rc S0 ++ new_rc rs);
               s_rg := inodup (s_rg S0 ++ new_rg rs);
               s_pairs := pnodup (s_pairs S0 ++ new_pairs rs);
               s_out := rs |} in
  match fuel with
  | O => S1
  | S fuel' =>
      if Nat.eqb (List.length (s_hold S1)) (List.length (s_hold S0))
         && Nat.eqb (List.length (s_rc S1)) (List.length (s_rc S0))
         && Nat.eqb (List.length (s_rg S1)) (List.length (s_rg S0))
         && Nat.eqb (List.length (s_pairs S1)) (List.length (s_pairs S0))
      then S1 else fix_run fuel' deep un ex S1
  end.

Definition st0 : st := {| s_hold := init_holders; s_rc := nil; s_rg := nil; s_pairs := nil; s_out := nil |}.

Definition shallow : st := fix_run 8 false false nil st0.
Definition shallow_u : st := fix_run 30 false true nil st0.

(* ---------------------------------------------------------------------- *)
(* Readable views.                                                         *)
(* ---------------------------------------------------------------------- *)

Definition hname (h : holder) : string :=
  match h with
  | HG g => ("global " ++ string_of_ident g)%string
  | HF f => ("field " ++ string_of_ident f)%string
  | HR u _ => ("union " ++ string_of_ident u ++ " @k")%string
  | HRA u => ("union " ++ string_of_ident u ++ " @?")%string
  | HU => "unknown"%string
  end.

Definition kname (k : kind) : string :=
  match k with
  | KStore => "STORE"%string
  | KVal h => ("val->" ++ hname h)%string
  | KSet t => ("set " ++ string_of_ident t)%string
  | KArg g i => ("arg " ++ string_of_ident g)%string
  | KArgInd => "arg-indirect"%string
  | KBuiltin => "builtin"%string
  | KRet => "ret"%string
  end.

Definition is_set (k : kind) : bool := match k with KSet _ => true | _ => false end.

Definition view (rs : list srec) : list (string * string) :=
  map (fun '(_, g, _, k) => (string_of_ident g, kname k))
    (filter (fun '(_, _, _, k) => negb (is_set k)) rs).

Definition stores_of (rs : list srec) : list (string * string) :=
  map (fun '(_, g, _, k) => (string_of_ident g, kname k))
    (filter (fun '(_, _, _, k) => match k with KStore => true | _ => false end) rs).

(* ====================================================================== *)
(* THE PINNED CENSUS (vm, over every TU of lprogs)                         *)
(* ====================================================================== *)

(* the candidates: 35 action tables, 533 behavior scripts *)
Lemma act_tables_count : List.length act_tables = 35%nat.
Proof. vm_compute. reflexivity. Qed.

Lemma bhv_scripts_count : List.length bhv_scripts = 533%nat.
Proof. vm_compute. reflexivity. Qed.

(* none is const: every candidate's definition has gvar_readonly = false,
   so CompCert's permissions do not protect them for free *)
Definition ro_readonly : list ident :=
  flat_map (fun p => flat_map (fun '(id, g) =>
    match g with
    | Gvar v => if memi id ro_syms && gvar_readonly v then [id] else nil
    | _ => nil
    end) (prog_defs p)) lprogs.

Lemma ro_none_readonly : ro_readonly = nil.
Proof. vm_compute. reflexivity. Qed.

(* the initializers holding a candidate's address: 51 globals (the 41
   behavior scripts that name another script, the macro / special / warp
   spawn tables, the particle and droplet parameter tables, the
   exclamation-box contents, the butterfly activation data), none const *)
Lemma init_refs_count : List.length init_refs = 51%nat.
Proof. vm_compute. reflexivity. Qed.

Lemma init_refs_writable : forallb (fun '(_, _, r) => negb r) init_refs = true.
Proof. vm_compute. reflexivity. Qed.

(* a run's verdict: a fixpoint (one more round adds no holder / pair /
   summary), no store into a candidate, no address escaping to an unknown
   location, an indirect call or a builtin *)
Definition bad_kind (k : kind) : bool :=
  match k with KStore | KVal HU | KArgInd | KBuiltin => true | _ => false end.

Definition run_ok (deep un : bool) (ex : list holder) (S0 : st) : bool :=
  let S1 := fix_run 0 deep un ex S0 in
  Nat.eqb (List.length (s_hold S1)) (List.length (s_hold S0))
  && Nat.eqb (List.length (s_pairs S1)) (List.length (s_pairs S0))
  && Nat.eqb (List.length (s_rc S1)) (List.length (s_rc S0))
  && Nat.eqb (List.length (s_rg S1)) (List.length (s_rg S0))
  && negb (existsb (fun '(_, _, _, k) => bad_kind k) (s_out S1)).

(* the holders a run grew, beyond the initializers *)
Definition grown (S0 : st) : list string :=
  map hname (filter (fun h => negb (hmem h init_holders)) (s_hold S0)).

(* (1) BY FIELD NAME (a union member's views kept apart): no code in the
   link stores into a candidate, even through a pointer read back from a
   holder; the addresses go only to gCurBhvCommand, the object fields
   curBhvCommand / behavior / bhvStack, rawData.asConstVoidPtr
   (create_respawner), and 36 (callee, parameter) pairs none of which
   stores through its parameter *)
Lemma ro_name_census : run_ok false false nil shallow = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ro_name_holders :
  grown shallow = ["global gCurBhvCommand"; "field bhvStack"; "field asConstVoidPtr";
                   "field curBhvCommand"; "field behavior"]%string.
Proof. vm_compute. reflexivity. Qed.

Lemma ro_name_pairs : List.length (s_pairs shallow) = 36%nat.
Proof. vm_compute. reflexivity. Qed.

(* (2) BY UNION CELL (sound against reading a pointer back through another
   view of the same 4-byte rawData cell): ONE cell breaks the cheap
   invariant -- create_respawner stores the respawned behavior's script
   into rawData byte 116 (slot 29, oRespawnerBehaviorToRespawn), a slot
   other behaviors use as an int; tracked as a union cell, that store
   alone floods the run (6366 spurious store sites).  With that one cell
   charged to a per-behavior slot fact, the union-precise run is clean. *)
Definition raw_union : ident := ident_of_string "_anon_2a845cdd6eb9".
Definition respawn_cell : holder := HR raw_union 116.

Definition union_sites (S0 : st) : list (string * string) :=
  view (filter (fun '(_, _, _, k) => match k with KVal (HR _ _) | KVal (HRA _) => true | _ => false end)
          (s_out S0)).

Definition shallow_x : st := fix_run 30 false true [respawn_cell] st0.

Lemma ro_union_census : run_ok false true [respawn_cell] shallow_x = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ro_union_only_respawner :
  union_sites shallow_x = [("create_respawner", "val->union _anon_2a845cdd6eb9 @k")]%string.
Proof. vm_compute. reflexivity. Qed.

(* (3) DEEP (a pointer read THROUGH a candidate -- a script's own pointer
   operands -- is tracked too): still no store into a candidate *)
Lemma ro_deep_no_store :
  negb (existsb (fun '(_, _, _, k) => match k with KStore => true | _ => false end)
          (s_out (fix_run 0 true true [respawn_cell] shallow_x))) = true.
Proof. vm_compute. reflexivity. Qed.

(* the respawner is outside the WMotR object closure (ObjTable.otab) *)
Lemma respawner_not_in_wmotr_closure :
  existsb (fun '(f, _, _) => Pos.eqb f obj_behaviors._create_respawner) otab = false.
Proof. vm_compute. reflexivity. Qed.
