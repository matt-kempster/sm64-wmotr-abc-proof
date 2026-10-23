(* kept: general tool -- the second-generation path-splitting SYMBOLIC
   executor for CompCert Clight, PROVED TO COVER every big-step execution
   (ClightBigstep, function_entry2).  It generalizes SymExec.v (the first
   slice, docs/goal2-value-walk-plan.md section 7) with what perform_air_step
   and the rest of the Mario frame need:

   - stack LOCALS (fn_vars): each one is a fresh region whose block the
     proof picks when Mem.alloc runs; Mem.free_list drops its cells;
   - LOOPS (Sloop, unrolled under fuel) and decided SWITCHES;
   - EXTERNAL calls, answered by consumer-supplied CONTRACTS (each proved
     sound by the consumer, e.g. from a value row about find_floor);
   - FRESH symbols [Sfresh n]: values the executor does not know exactly
     (contract results, ...), denoted by an environment the proof extends;
   - WORLD pointers: reads through a pointer term [p] that a path fact
     [Fworld p n] says points at n bytes of the initial memory outside every
     consumer region (surfaces, ...): they read the initial memory.

   Meaning.  A symbolic value denotes a value under an environment
   [E : senv] (region blocks and bases, fresh values) at the INITIAL memory
   [m0].  Operators are evaluated at m0.  That is sound because along the
   run every block that is valid in m0 keeps its valid_pointer answers
   ([vp_old]); operators never see a pointer to a block allocated during the
   run: locals' addresses are refused under operators unless folded, and
   every other value points only at m0's PUBLIC blocks [gp] (a flat partial
   self-map of m0): the region blocks are public, the contents of public
   blocks point only at public blocks ([m0_closed], a premise; it is
   ClosedMem.closed_by gp m0, which external calls preserve), and fresh
   values do too ([rho_old]).  So CompCert's generic injection lemmas, at
   gp's flat image, transfer each operator from m to m0.

   THE THEOREM ([sx_call_sound]): if the executor returns paths for a call,
   then EVERY big-step execution of that call from a memory matching the
   symbolic start ends in a memory described by one of the paths, under an
   extension of the environment.  [None] means the executor refused;
   only a [Some] run carries meaning. *)

From Coq Require Import String List Lia.
From compcert Require Import Coqlib Errors Maps Integers Floats Values AST Memory
  Events Globalenvs Ctypes Cop Clight ClightBigstep.
From compcert Require SimplLocalsproof.
Import ListNotations.

Local Notation "'let?' x := a 'in' b" :=
  (match a with Some x => b | None => None end)
  (at level 200, x ident, a at level 100, b at level 200).

(* ---------------------------------------------------------------- *)
(* Symbolic values, facts, states                                     *)
(* ---------------------------------------------------------------- *)

Inductive sval : Type :=
  | Sconst (v : val)
  | Sptr (r : positive) (ofs : ptrofs)                (* region r, relative offset *)
  | Sinit (r : positive) (ofs : Z) (ch : memory_chunk) (* m0 cell of region r *)
  | Swld (p : sval) (k : Z) (ch : memory_chunk)       (* m0 cell at world pointer p, +k *)
  | Swoff (p : sval) (k : Z)                          (* world pointer p, +k *)
  | Sfresh (n : positive)
  | Sunop (op : unary_operation) (a : sval) (ty : type)
  | Sbinop (op : binary_operation) (a1 : sval) (t1 : type) (a2 : sval) (t2 : type)
  | Scast (a : sval) (t1 t2 : type)
  | Sldres (ch : memory_chunk) (a : sval).

Definition unop_eq (a b : unary_operation) : {a = b} + {a <> b}.
Proof. decide equality. Defined.
Definition binop_eq (a b : binary_operation) : {a = b} + {a <> b}.
Proof. decide equality. Defined.

Definition sval_eq (a b : sval) : {a = b} + {a <> b}.
Proof.
  decide equality;
    first [ apply Val.eq | apply type_eq | apply unop_eq | apply binop_eq
          | apply chunk_eq | apply Ptrofs.eq_dec | apply Z.eq_dec | apply Pos.eq_dec ].
Defined.

Definition sbeq (a b : sval) : bool := if sval_eq a b then true else false.

Inductive fact : Type :=
  | Fbool (c : sval) (ty : type) (b : bool)   (* bool_val (den c) ty m0 = Some b *)
  | Fworld (p : sval) (n : Z)                 (* p: n bytes of m0 outside every region *)
  | Fbits (t : sval) (mask : int)             (* den t = Vint i, i & mask = 0 *)
  | Fuser (k : positive) (args : list sval).  (* consumer-interpreted *)

Definition fact_eq (a b : fact) : {a = b} + {a <> b}.
Proof.
  decide equality;
    first [ apply sval_eq | apply type_eq | apply bool_dec | apply Z.eq_dec | apply Int.eq_dec
          | apply Pos.eq_dec | apply (list_eq_dec sval_eq) ].
Defined.

Definition fbeq (a b : fact) : bool := if fact_eq a b then true else false.

Definition sentry : Type := (positive * Z * memory_chunk * sval)%type.
Definition smem : Type := list sentry.

(* the part of the symbolic state that survives calls *)
Record gst : Type := mkg {
  g_sm : smem;            (* written cells, by region *)
  g_pc : list fact;       (* path facts *)
  g_nx : positive;        (* next unused name (regions and fresh values) *)
  g_loc : list positive;  (* live local regions *)
  g_cl : list positive    (* clobbered consumer regions: a contract changed
                             them, so their unwritten cells are unknown *)
}.

Inductive sout : Type :=
  | SOnormal | SObreak | SOcontinue | SOreturn (r : option (sval * type)).

Definition spath : Type := (PTree.t sval * gst * sout)%type.
Definition cpath : Type := (gst * sval)%type.

(* an external call contract: given the symbolic arguments and state,
   the possible outcomes (each a new state and a result value) *)
Definition xcontract : Type := list sval -> gst -> option (list cpath).

Inductive sloc : Type :=
  | Lreg (r : positive) (o : ptrofs)
  | Lwld (q : sval) (k : Z).

Fixpoint oflat {A B : Type} (f : A -> option (list B)) (l : list A) : option (list B) :=
  match l with
  | nil => Some nil
  | x :: l' =>
      match f x, oflat f l' with
      | Some a, Some b => Some (a ++ b)
      | _, _ => None
      end
  end.

Fixpoint omap {A B : Type} (f : A -> option B) (l : list A) : option (list B) :=
  match l with
  | nil => Some nil
  | x :: l' =>
      match f x, omap f l' with
      | Some a, Some b => Some (a :: b)
      | _, _ => None
      end
  end.

Definition non_undef (v : val) : bool := match v with Vundef => false | _ => true end.
Definition non_ptr (v : val) : bool := match v with Vptr _ _ => false | _ => true end.
Definition dummy_b : block := xH.

Section SYMEX.

Variable ge : genv.

(* Names below [nbase] are the consumer's regions; locals and fresh values
   are allocated from [nbase] upwards. *)
Variable nbase : positive.
(* The consumer's regions and their sizes (bytes from the region base). *)
Variable R0 : list (positive * Z).
(* Globals the code names directly ([Evar]), each a consumer region whose
   base is the global's block at offset 0. *)
Variable gtab : list (ident * positive).
(* Known initial values: cell (r, o, ch) of m0 holds [den sv]. *)
Variable kv : list (positive * Z * memory_chunk * sval).
(* Call contracts, by callee name: every external the code reaches needs
   one; an internal function may have one too (a summary, proved sound by
   the consumer, e.g. with this executor), which is then used instead of
   running its body. *)
Variable xc : ident -> option xcontract.
(* Joins.  [jkeys]: cells a join keeps exact (paths are joined only when
   they agree on them); [mergef id]: join the outcomes of calls to [id];
   [jloops]: join the states at every loop head and loop exit. *)
Variable jkeys : list (positive * Z * memory_chunk).
Variable mergef : ident -> bool.
Variable jloops : bool.

Definition is_local (r : positive) : bool := negb (Pos.ltb r nbase).

Definition loc_ptr (a : sval) : bool :=
  match a with Sptr r _ => is_local r | _ => false end.

Definition r0_size (r : positive) : option Z :=
  match find (fun x : positive * Z => Pos.eqb (fst x) r) R0 with
  | Some (_, sz) => Some sz
  | None => None
  end.

(* a cell the executor may touch: inside a consumer region, or in a live local *)
Definition inb (g : gst) (r : positive) (o : Z) (ch : memory_chunk) : bool :=
  if Pos.ltb r nbase then
    match r0_size r with
    | Some sz => (0 <=? o) && (o + size_chunk ch <=? sz)
    | None => false
    end
  else existsb (Pos.eqb r) (g_loc g) && (0 <=? o) && (o + size_chunk ch <=? Ptrofs.modulus).

Definition ovl (r : positive) (o : Z) (ch : memory_chunk) (e : sentry) : bool :=
  let '(r', o', ch', _) := e in
  Pos.eqb r r' && (o <? o' + size_chunk ch') && (o' <? o + size_chunk ch).

Definition exact (r : positive) (o : Z) (ch : memory_chunk) (e : sentry) : bool :=
  let '(r', o', ch', _) := e in
  Pos.eqb r r' && Z.eqb o o' && (if chunk_eq ch ch' then true else false).

Definition init_cell (r : positive) (o : Z) (ch : memory_chunk) : sval :=
  match find (fun (x : positive * Z * memory_chunk * sval) =>
                let '(r', o', ch', _) := x in
                Pos.eqb r r' && Z.eqb o o' && (if chunk_eq ch ch' then true else false)) kv with
  | Some (_, _, _, sv) => sv
  | None => Sinit r o ch
  end.

Definition sload (g : gst) (r : positive) (o : Z) (ch : memory_chunk) : option sval :=
  if inb g r o ch then
    match filter (ovl r o ch) (g_sm g) with
    | nil => if Pos.ltb r nbase && negb (existsb (Pos.eqb r) (g_cl g))
             then Some (init_cell r o ch) else None
    | e :: nil => if exact r o ch e then Some (snd e) else None
    | _ => None
    end
  else None.

Definition sstore (g : gst) (r : positive) (o : Z) (ch : memory_chunk) (v : sval)
    : option gst :=
  if inb g r o ch then
    if forallb (fun e => negb (ovl r o ch e) || exact r o ch e) (g_sm g)
    then Some (mkg ((r, o, ch, v) :: filter (fun e => negb (ovl r o ch e)) (g_sm g))
                   (g_pc g) (g_nx g) (g_loc g) (g_cl g))
    else None
  else None.

Definition world_ok (pc : list fact) (q : sval) (k : Z) (ch : memory_chunk) : bool :=
  existsb (fun f => match f with
                    | Fworld p n => sbeq p q && (0 <=? k) && (k + size_chunk ch <=? n)
                    | _ => false
                    end) pc.

(* p points into the same block as p' (syntactically: equal, or two
   addresses in one region) *)
Definition same_blk (p' p : sval) : bool :=
  sbeq p' p || match p', p with Sptr r1 _, Sptr r2 _ => Pos.eqb r1 r2 | _, _ => false end.

(* p is a world pointer into a whole block that holds no sized region (a
   fact [Fworld p' n] with n >= the address space, p' in p's block) *)
Definition wblock_ok (pc : list fact) (p : sval) : bool :=
  existsb (fun f => match f with
                    | Fworld p' n => same_blk p' p && (Ptrofs.modulus <=? n)
                    | _ => false
                    end) pc.

(* q = p + i, pointer plus integer: an element of such a block (a table
   indexed by a symbolic value) *)
Definition widx_ok (pc : list fact) (q : sval) : bool :=
  match q with
  | Sbinop Oadd p t1 _ t2 =>
      wblock_ok pc p && match classify_add t1 t2 with add_case_pi _ _ => true | _ => false end
  | _ => false
  end.

Definition wload (g : gst) (q : sval) (k : Z) (ch : memory_chunk) : option sval :=
  if world_ok (g_pc g) q k ch || widx_ok (g_pc g) q then Some (Swld q k ch) else None.

Definition loc_of (p : sval) : sloc :=
  match p with
  | Sptr r o => Lreg r o
  | Swoff q k => Lwld q k
  | _ => Lwld p 0
  end.

Definition addr_of (l : sloc) : sval :=
  match l with
  | Lreg r o => Sptr r o
  | Lwld q k => if Z.eqb k 0 then q else Swoff q k
  end.

Definition loc_add (l : sloc) (d : Z) : sloc :=
  match l with
  | Lreg r o => Lreg r (Ptrofs.add o (Ptrofs.repr d))
  | Lwld q k => Lwld q (k + d)
  end.

(* ---------------------------------------------------------------- *)
(* Folding                                                            *)
(* ---------------------------------------------------------------- *)

Definition known_zero (pc : list fact) (t : sval) (k : int) : bool :=
  existsb (fun f => match f with
                    | Fbits t' mask => sbeq t t' && Int.eq (Int.and k (Int.not mask)) Int.zero
                    | _ => false
                    end) pc.

Definition is_tint (t : type) : bool := match t with Tint _ _ _ => true | _ => false end.
Definition is_tptr (t : type) : bool := match t with Tpointer _ _ => true | _ => false end.

Definition fold_ptr_res (r : positive) (res : option val) : option sval :=
  match res with
  | Some (Vptr b o') => if eq_block b dummy_b then Some (Sptr r o') else None
  | _ => None
  end.

Definition fold_const (res : option val) : option sval :=
  match res with
  | Some v => if non_undef v && non_ptr v then Some (Sconst v) else None
  | None => None
  end.

Definition fold_bin (pc : list fact) (op : binary_operation) (a1 : sval) (t1 : type)
    (a2 : sval) (t2 : type) : option sval :=
  match a1, a2 with
  | Sconst v1, Sconst v2 => fold_const (sem_binary_operation ge op v1 t1 v2 t2 Mem.empty)
  | Sptr r o, Sconst v2 =>
      if non_ptr v2
      then fold_ptr_res r (sem_binary_operation ge op (Vptr dummy_b o) t1 v2 t2 Mem.empty)
      else None
  | Sconst v1, Sptr r o =>
      if non_ptr v1
      then fold_ptr_res r (sem_binary_operation ge op v1 t1 (Vptr dummy_b o) t2 Mem.empty)
      else None
  (* two addresses in one region: == / != compare their offsets (when the
     real comparison is defined at all, it is this one) *)
  | Sptr r1 o1, Sptr r2 o2 =>
      if Pos.eqb r1 r2 && is_tptr t1 && is_tptr t2 then
        match op with
        | Oeq => Some (Sconst (Val.of_bool (Ptrofs.eq o1 o2)))
        | One => Some (Sconst (Val.of_bool (negb (Ptrofs.eq o1 o2))))
        | _ => None
        end
      else None
  | _, Sconst (Vint k) =>
      match op with
      | Oand => if is_tint t1 && is_tint t2 && known_zero pc a1 k
                then Some (Sconst (Vint Int.zero)) else None
      | _ => None
      end
  | _, _ => None
  end.

Definition mk_bin (pc : list fact) (op : binary_operation) (a1 : sval) (t1 : type)
    (a2 : sval) (t2 : type) : option sval :=
  match fold_bin pc op a1 t1 a2 t2 with
  | Some t => Some t
  | None => if loc_ptr a1 || loc_ptr a2 then None else Some (Sbinop op a1 t1 a2 t2)
  end.

Definition mk_un (op : unary_operation) (a : sval) (ty : type) : option sval :=
  match a with
  | Sconst v =>
      match fold_const (sem_unary_operation op v ty Mem.empty) with
      | Some t => Some t
      | None => Some (Sunop op a ty)
      end
  | _ => if loc_ptr a then None else Some (Sunop op a ty)
  end.

(* casts that return their argument whenever they are defined *)
Definition cast_id (t1 t2 : type) : bool :=
  match classify_cast t1 t2 with
  | cast_case_pointer | cast_case_i2i I32 _ | cast_case_f2f | cast_case_s2s
  | cast_case_l2l | cast_case_struct _ _ | cast_case_union _ _ | cast_case_void => true
  | _ => false
  end.

Definition mk_cast (a : sval) (t1 t2 : type) : option sval :=
  if cast_id t1 t2 then Some a else
  match a with
  | Sconst v =>
      match fold_const (sem_cast v t1 t2 Mem.empty) with
      | Some t => Some t
      | None => Some (Scast a t1 t2)
      end
  | Sptr r o =>
      match fold_ptr_res r (sem_cast (Vptr dummy_b o) t1 t2 Mem.empty) with
      | Some t => Some t
      | None => if is_local r then None else Some (Scast a t1 t2)
      end
  | _ => Some (Scast a t1 t2)
  end.

Definition mk_ldres (ch : memory_chunk) (a : sval) : sval :=
  match a with
  | Sconst v => Sconst (Val.load_result ch v)
  | Sptr r o =>
      match Val.load_result ch (Vptr dummy_b o) with
      | Vptr _ o' => Sptr r o'
      | v => Sconst v
      end
  | _ => Sldres ch a
  end.

Fixpoint pc_lookup (pc : list fact) (c : sval) (ty : type) : option bool :=
  match pc with
  | nil => None
  | Fbool a t b :: pc' => if sbeq a c && (if type_eq t ty then true else false)
                          then Some b else pc_lookup pc' c ty
  | _ :: pc' => pc_lookup pc' c ty
  end.

Definition decide (pc : list fact) (c : sval) (ty : type) : option bool :=
  match c with
  | Sconst v => bool_val v ty Mem.empty
  | _ => pc_lookup pc c ty
  end.

Definition add_fact (g : gst) (f : fact) : gst :=
  mkg (g_sm g) (f :: g_pc g) (g_nx g) (g_loc g) (g_cl g).

(* ---------------------------------------------------------------- *)
(* Expressions                                                        *)
(* ---------------------------------------------------------------- *)

Definition sderef (ty : type) (g : gst) (l : sloc) : option sval :=
  match access_mode ty with
  | By_value ch =>
      match l with
      | Lreg r o =>
          match sload g r (Ptrofs.unsigned o) ch with
          | Some v => Some v
          (* a scalar global with no sized region (gtab only) read as
             world memory, when a fact [Fworld] places it *)
          | None => if Pos.ltb r nbase then wload g (Sptr r o) 0 ch else None
          end
      | Lwld q k => wload g q k ch
      end
  | By_reference | By_copy => Some (addr_of l)
  | By_nothing => None
  end.

Definition sfield_loc (tya : type) (i : ident) (l : sloc) : option sloc :=
  match tya with
  | Tstruct id _ =>
      match (genv_cenv ge) ! id with
      | Some co =>
          match field_offset ge i (co_members co) with
          | OK (delta, Full) => Some (loc_add l delta)
          | _ => None
          end
      | None => None
      end
  | Tunion id _ =>
      match (genv_cenv ge) ! id with
      | Some co =>
          match union_field_offset ge i (co_members co) with
          | OK (delta, Full) => Some (loc_add l delta)
          | _ => None
          end
      | None => None
      end
  | _ => None
  end.

Definition gfind (id : ident) : option positive :=
  match find (fun x : ident * positive => Pos.eqb (fst x) id) gtab with
  | Some (_, r) => Some r
  | None => None
  end.

Definition svar_loc (se : PTree.t (positive * type)) (id : ident) (ty : type) : option sloc :=
  match se ! id with
  | Some (r, ty') => if type_eq ty' ty then Some (Lreg r Ptrofs.zero) else None
  | None => match gfind id with Some r => Some (Lreg r Ptrofs.zero) | None => None end
  end.

Section SEXPR.
Variables (se : PTree.t (positive * type)) (le : PTree.t sval) (g : gst).

Fixpoint sx_expr (a : expr) : option sval :=
  match a with
  | Econst_int i _ => Some (Sconst (Vint i))
  | Econst_float f _ => Some (Sconst (Vfloat f))
  | Econst_single f _ => Some (Sconst (Vsingle f))
  | Econst_long i _ => Some (Sconst (Vlong i))
  | Etempvar id _ => le ! id
  | Eaddrof a1 _ => let? l := sx_lvalue a1 in Some (addr_of l)
  | Eunop op a1 _ => let? v1 := sx_expr a1 in mk_un op v1 (typeof a1)
  | Ebinop op a1 a2 _ =>
      let? v1 := sx_expr a1 in
      let? v2 := sx_expr a2 in
      mk_bin (g_pc g) op v1 (typeof a1) v2 (typeof a2)
  | Ecast a1 ty => let? v1 := sx_expr a1 in mk_cast v1 (typeof a1) ty
  | Esizeof ty1 _ => Some (Sconst (Vptrofs (Ptrofs.repr (sizeof ge ty1))))
  | Ealignof ty1 _ => Some (Sconst (Vptrofs (Ptrofs.repr (alignof ge ty1))))
  | Evar id ty => let? l := svar_loc se id ty in sderef ty g l
  | Ederef a1 ty => let? p := sx_expr a1 in sderef ty g (loc_of p)
  | Efield a1 i ty =>
      let? p := sx_expr a1 in
      let? l := sfield_loc (typeof a1) i (loc_of p) in
      sderef ty g l
  end

with sx_lvalue (a : expr) : option sloc :=
  match a with
  | Evar id ty => svar_loc se id ty
  | Ederef a1 _ => let? p := sx_expr a1 in Some (loc_of p)
  | Efield a1 i _ => let? p := sx_expr a1 in sfield_loc (typeof a1) i (loc_of p)
  | _ => None
  end.

Fixpoint sx_exprlist (al : list expr) (tyl : list type) : option (list sval) :=
  match al, tyl with
  | nil, nil => Some nil
  | a :: bl, ty :: tyl' =>
      let? v1 := sx_expr a in
      let? c := mk_cast v1 (typeof a) ty in
      let? vl := sx_exprlist bl tyl' in
      Some (c :: vl)
  | _, _ => None
  end.

End SEXPR.

(* an expression that must dereference a temp the path knows is a
   non-pointer constant (a NULL a contract returned): Clight has no
   evaluation of it, so a statement that evaluates it ends the path *)
Fixpoint nullx (le : PTree.t sval) (a : expr) : bool :=
  match a with
  | Ederef (Etempvar id _) _ =>
      match le ! id with Some (Sconst (Vint _)) => true | _ => false end
  | Ederef a1 _ => nullx le a1
  | Efield a1 _ _ => nullx le a1
  | Eaddrof a1 _ => nullx le a1
  | Eunop _ a1 _ => nullx le a1
  | Ecast a1 _ => nullx le a1
  | Ebinop _ a1 a2 _ => nullx le a1 || nullx le a2
  | _ => false
  end.


(* ---------------------------------------------------------------- *)
(* Joins                                                              *)
(* ---------------------------------------------------------------- *)

(* Join two paths into one that covers both, by ANTI-UNIFICATION: a slot on
   which they agree keeps its term; terms with the same operator are joined
   operand-wise; any other pair of terms becomes a fresh name, the SAME name
   for the same pair (a memo), so a relation that holds on both paths (pos =
   floorHeight) survives.  Facts are joined through the memo without new
   names: [Fworld f1 n] and [Fworld f2 n] become [Fworld k n] when the pair
   (f1, f2) already has the name k.  The proof gives each fresh name the
   value the real run has. *)
Definition memo : Type := list (sval * sval * positive).

Fixpoint mfind (mo : memo) (t1 t2 : sval) : option positive :=
  match mo with
  | nil => None
  | (a, b, k) :: mo' => if sbeq a t1 && sbeq b t2 then Some k else mfind mo' t1 t2
  end.

(* a fresh name for the pair; in read-only mode only a known one *)
Definition au_new (ro : bool) (t1 t2 : sval) (nx : positive) (mo : memo)
    : option (sval * positive * memo) :=
  match mfind mo t1 t2 with
  | Some k => Some (Sfresh k, nx, mo)
  | None =>
      if ro then None
      else if loc_ptr t1 || loc_ptr t2 then None
      else Some (Sfresh nx, Pos.succ nx, (t1, t2, nx) :: mo)
  end.

Fixpoint au (ro : bool) (t1 t2 : sval) (nx : positive) (mo : memo) {struct t1}
    : option (sval * positive * memo) :=
  if sbeq t1 t2 then Some (t1, nx, mo) else
  match t1, t2 with
  | Swld p k ch, Swld p' k' ch' =>
      if Z.eq_dec k k' then if chunk_eq ch ch' then
        match au ro p p' nx mo with
        | Some (x, n1, m1) => Some (Swld x k ch, n1, m1)
        | None => None
        end
      else au_new ro t1 t2 nx mo else au_new ro t1 t2 nx mo
  | Swoff p k, Swoff p' k' =>
      if Z.eq_dec k k' then
        match au ro p p' nx mo with
        | Some (x, n1, m1) => Some (Swoff x k, n1, m1)
        | None => None
        end
      else au_new ro t1 t2 nx mo
  | Sunop op a ty, Sunop op' a' ty' =>
      if unop_eq op op' then if type_eq ty ty' then
        match au ro a a' nx mo with
        | Some (x, n1, m1) => Some (Sunop op x ty, n1, m1)
        | None => None
        end
      else au_new ro t1 t2 nx mo else au_new ro t1 t2 nx mo
  | Sbinop op a1 ty1 a2 ty2, Sbinop op' a1' ty1' a2' ty2' =>
      if binop_eq op op' then if type_eq ty1 ty1' then if type_eq ty2 ty2' then
        match au ro a1 a1' nx mo with
        | Some (x, n1, m1) =>
            match au ro a2 a2' n1 m1 with
            | Some (y, n2, m2) => Some (Sbinop op x ty1 y ty2, n2, m2)
            | None => None
            end
        | None => None
        end
      else au_new ro t1 t2 nx mo else au_new ro t1 t2 nx mo else au_new ro t1 t2 nx mo
  | Scast a ta tb, Scast a' ta' tb' =>
      if type_eq ta ta' then if type_eq tb tb' then
        match au ro a a' nx mo with
        | Some (x, n1, m1) => Some (Scast x ta tb, n1, m1)
        | None => None
        end
      else au_new ro t1 t2 nx mo else au_new ro t1 t2 nx mo
  | Sldres ch a, Sldres ch' a' =>
      if chunk_eq ch ch' then
        match au ro a a' nx mo with
        | Some (x, n1, m1) => Some (Sldres ch x, n1, m1)
        | None => None
        end
      else au_new ro t1 t2 nx mo
  | _, _ => au_new ro t1 t2 nx mo
  end.

Fixpoint jtemps (l : list (ident * sval)) (le2 : PTree.t sval) (acc : PTree.t sval)
    (nx : positive) (mo : memo) : option (PTree.t sval * positive * memo) :=
  match l with
  | nil => Some (acc, nx, mo)
  | (id, t1) :: l' =>
      let? t2 := le2 ! id in
      match au false t1 t2 nx mo with
      | Some (t, nx', mo') => jtemps l' le2 (PTree.set id t acc) nx' mo'
      | None => None
      end
  end.

Definition skey (e : sentry) : positive * Z * memory_chunk :=
  let '(r, o, ch, _) := e in (r, o, ch).

Definition key_eq (a b : positive * Z * memory_chunk) : bool :=
  let '(r, o, ch) := a in let '(r', o', ch') := b in
  Pos.eqb r r' && Z.eqb o o' && (if chunk_eq ch ch' then true else false).

Fixpoint jmem (ks : list (positive * Z * memory_chunk)) (g1 g2 : gst) (nx : positive) (mo : memo)
    : option (smem * positive * memo) :=
  match ks with
  | nil => Some (nil, nx, mo)
  | (r, o, ch) :: ks' =>
      let? t1 := sload g1 r o ch in
      let? t2 := sload g2 r o ch in
      match au false t1 t2 nx mo with
      | Some (t, nx', mo') =>
          match jmem ks' g1 g2 nx' mo' with
          | Some (sm, nx'', mo'') => Some ((r, o, ch, t) :: sm, nx'', mo'')
          | None => None
          end
      | None => None
      end
  end.

Definition jkeys_of (g1 g2 : gst) : list (positive * Z * memory_chunk) :=
  let k1 := map skey (g_sm g1) in
  k1 ++ filter (fun k => negb (existsb (key_eq k) k1)) (map skey (g_sm g2)).

Definition jout (o1 o2 : sout) (nx : positive) (mo : memo) : option (sout * positive * memo) :=
  match o1, o2 with
  | SOnormal, SOnormal => Some (SOnormal, nx, mo)
  | SObreak, SObreak => Some (SObreak, nx, mo)
  | SOcontinue, SOcontinue => Some (SOcontinue, nx, mo)
  | SOreturn None, SOreturn None => Some (SOreturn None, nx, mo)
  | SOreturn (Some (v1, t1)), SOreturn (Some (v2, t2)) =>
      if type_eq t1 t2 then
        match au false v1 v2 nx mo with
        | Some (v, nx', mo') => Some (SOreturn (Some (v, t1)), nx', mo')
        | None => None
        end
      else None
  | _, _ => None
  end.

(* a list of terms of both paths, through the memo (no new names) *)
Fixpoint au_args (l1 l2 : list sval) (nx : positive) (mo : memo) : option (list sval) :=
  match l1, l2 with
  | nil, nil => Some nil
  | a1 :: l1', a2 :: l2' =>
      match au true a1 a2 nx mo, au_args l1' l2' nx mo with
      | Some (a, _, _), Some l => Some (a :: l)
      | _, _ => None
      end
  | _, _ => None
  end.

(* a fact of both paths, through the memo (no new names) *)
Definition au_fact (f1 f2 : fact) (nx : positive) (mo : memo) : option fact :=
  match f1, f2 with
  | Fbool c1 ty b, Fbool c2 ty' b' =>
      if type_eq ty ty' then if bool_dec b b' then
        match au true c1 c2 nx mo with Some (c, _, _) => Some (Fbool c ty b) | None => None end
      else None else None
  | Fworld p1 n, Fworld p2 n' =>
      if Z.eq_dec n n' then
        match au true p1 p2 nx mo with Some (p, _, _) => Some (Fworld p n) | None => None end
      else None
  | Fbits t1 k, Fbits t2 k' =>
      if Int.eq_dec k k' then
        match au true t1 t2 nx mo with Some (t, _, _) => Some (Fbits t k) | None => None end
      else None
  | Fuser k1 a1, Fuser k2 a2 =>
      if Pos.eq_dec k1 k2 then
        match au_args a1 a2 nx mo with Some a => Some (Fuser k1 a) | None => None end
      else None
  | _, _ => None
  end.

Fixpoint first_some {A B : Type} (f : A -> option B) (l : list A) : option B :=
  match l with
  | nil => None
  | x :: l' => match f x with Some y => Some y | None => first_some f l' end
  end.

Definition jfacts (pc1 pc2 : list fact) (nx : positive) (mo : memo) : list fact :=
  flat_map (fun f1 => match first_some (fun f2 => au_fact f1 f2 nx mo) pc2 with
                      | Some f => [f]
                      | None => nil
                      end) pc1.

Definition join2 (p1 p2 : spath) : option spath :=
  let '(le1, g1, o1) := p1 in
  let '(le2, g2, o2) := p2 in
  if list_eq_dec Pos.eq_dec (g_loc g1) (g_loc g2) then
  if list_eq_dec Pos.eq_dec (g_cl g1) (g_cl g2) then
  if list_eq_dec Pos.eq_dec (map fst (PTree.elements le1)) (map fst (PTree.elements le2)) then
    match jout o1 o2 (Pos.max (g_nx g1) (g_nx g2)) nil with
    | Some (o, nx1, mo1) =>
        match jtemps (PTree.elements le1) le2 (PTree.empty sval) nx1 mo1 with
        | Some (le, nx2, mo2) =>
            match jmem (jkeys_of g1 g2) g1 g2 nx2 mo2 with
            | Some (sm, nx3, mo3) =>
                Some (le, mkg sm (jfacts (g_pc g1) (g_pc g2) nx3 mo3) nx3 (g_loc g1) (g_cl g1), o)
            | None => None
            end
        | None => None
        end
    | None => None
    end
  else None else None else None.

(* the grouping key: paths are joined only when their keys agree *)
Definition pkey : Type := (nat * list (option sval) * list (ident * sval))%type.

Definition pkey_dec (a b : pkey) : {a = b} + {a <> b}.
Proof.
  decide equality;
    first [ apply (list_eq_dec (fun x y : ident * sval =>
                     ltac:(decide equality; first [ apply sval_eq | apply Pos.eq_dec ])))
          | decide equality; first [ apply (list_eq_dec (option_eq sval_eq)) | apply Nat.eq_dec ] ].
Defined.

Definition pkey_eq (a b : pkey) : bool := if pkey_dec a b then true else false.

Definition out_tag (o : sout) : nat * option sval :=
  match o with
  | SOnormal => (0%nat, None) | SObreak => (1%nat, None) | SOcontinue => (2%nat, None)
  | SOreturn None => (3%nat, None) | SOreturn (Some (v, _)) => (4%nat, Some v)
  end.

Definition is_const (t : sval) : bool := match t with Sconst _ => true | _ => false end.

(* a term's shape: fresh names erased (they are numbered per path, so two
   paths that made the same kind of choice differ only there).  Keys only
   decide which joins are tried; every join is sound. *)
Fixpoint skel (a : sval) : sval :=
  match a with
  | Sfresh _ => Sfresh xH
  | Swld p k ch => Swld (skel p) k ch
  | Swoff p k => Swoff (skel p) k
  | Sunop op a ty => Sunop op (skel a) ty
  | Sbinop op a1 t1 a2 t2 => Sbinop op (skel a1) t1 (skel a2) t2
  | Scast a t1 t2 => Scast (skel a) t1 t2
  | Sldres ch a => Sldres ch (skel a)
  | _ => a
  end.

(* the consumer facts that name v as their first argument, as their key
   and the shapes of their other arguments: a join that merges a cell whose
   facts differ in these would drop them, so they are part of the key *)
Definition utags (pc : list fact) (v : sval) : list (option sval) :=
  flat_map (fun f =>
    match f with
    | Fuser k (a :: rest) =>
        if sbeq a v then Some (Sconst (Vint (Int.repr (Zpos k)))) :: map (fun x => Some (skel x)) rest
        else nil
    | _ => nil
    end) pc.

Definition key_of (p : spath) : pkey :=
  let '(le, g, o) := p in
  let '(tag, ov) := out_tag o in
  (tag, option_map skel ov
          :: map (fun k => let '(r, o, ch) := k in option_map skel (sload g r o ch)) jkeys
          ++ flat_map (fun k => let '(r, o, ch) := k in
                         match sload g r o ch with Some v => None :: utags (g_pc g) v | None => nil end) jkeys,
   filter (fun x => is_const (snd x)) (PTree.elements le)).

Fixpoint jinsert (p : spath) (k : pkey) (acc : list (pkey * spath)) : list (pkey * spath) :=
  match acc with
  | nil => [(k, p)]
  | (k', q) :: acc' =>
      if pkey_eq k k' then
        match join2 q p with
        | Some j => (k', j) :: acc'
        | None => (k', q) :: jinsert p k acc'
        end
      else (k', q) :: jinsert p k acc'
  end.

Definition jgroup (ps : list spath) : list spath :=
  map snd (fold_left (fun acc p => jinsert p (key_of p) acc) ps nil).

Definition cp_to_sp (c : cpath) : spath :=
  let '(g, r) := c in (PTree.empty sval, g, SOreturn (Some (r, Tvoid))).

Definition sp_to_cp (p : spath) : option cpath :=
  match p with
  | (_, g, SOreturn (Some (r, _))) => Some (g, r)
  | _ => None
  end.

Definition jgroup_c (cs : list cpath) : option (list cpath) :=
  omap sp_to_cp (jgroup (map cp_to_sp cs)).

(* ---------------------------------------------------------------- *)
(* Statements and calls                                               *)
(* ---------------------------------------------------------------- *)

Definition sfun_lookup (id : ident) : option fundef :=
  match Genv.find_symbol ge id with
  | Some b => Genv.find_funct_ptr ge b
  | None => None
  end.

Fixpoint sbind (formals : list (ident * type)) (args : list sval) (le : PTree.t sval)
    : option (PTree.t sval) :=
  match formals, args with
  | nil, nil => Some le
  | (id, _) :: xl, a :: al => sbind xl al (PTree.set id a le)
  | _, _ => None
  end.

Fixpoint sundef (temps : list (ident * type)) : PTree.t sval :=
  match temps with
  | nil => PTree.empty sval
  | (id, _) :: temps' => PTree.set id (Sconst Vundef) (sundef temps')
  end.

(* allocate the locals: each gets the next name as its region *)
Fixpoint salloc (vars : list (ident * type)) (se : PTree.t (positive * type)) (g : gst)
    : PTree.t (positive * type) * gst :=
  match vars with
  | nil => (se, g)
  | (id, ty) :: vars' =>
      salloc vars' (PTree.set id (g_nx g, ty) se)
             (mkg (g_sm g) (g_pc g) (Pos.succ (g_nx g)) (g_nx g :: g_loc g) (g_cl g))
  end.

(* free the callee's locals: keep the caller's live regions [loc] *)
Definition sfree (loc : list positive) (g : gst) : gst :=
  mkg (filter (fun e : sentry => let '(r, _, _, _) := e in
                                 Pos.ltb r nbase || existsb (Pos.eqb r) loc) (g_sm g))
      (g_pc g) (g_nx g) loc (g_cl g).

Definition sresult (out : sout) (t : type) : option sval :=
  match out, t with
  | SOnormal, Tvoid => Some (Sconst Vundef)
  | SOreturn None, Tvoid => Some (Sconst Vundef)
  | SOreturn (Some (v, t')), ty => if type_eq ty Tvoid then None else mk_cast v t' ty
  | _, _ => None
  end.

Definition sset_opt (optid : option ident) (v : sval) (le : PTree.t sval) : PTree.t sval :=
  match optid with None => le | Some id => PTree.set id v le end.

Definition sout_switch (o : sout) : sout :=
  match o with SObreak => SOnormal | o => o end.

Definition lexits (rs : list (spath + spath)) : list spath :=
  flat_map (fun x => match x with inl p => [p] | inr _ => nil end) rs.
Definition lbacks (rs : list (spath + spath)) : list spath :=
  flat_map (fun x => match x with inr p => [p] | inl _ => nil end) rs.

(* a symbolic switch: one path per case label (with the fact c == n) and
   one for the default (with c != n for every label) *)
Fixpoint sw_labels (sl : labeled_statements) : list Z :=
  match sl with
  | LSnil => nil
  | LScons (Some n) _ sl' => n :: sw_labels sl'
  | LScons None _ sl' => sw_labels sl'
  end.

Definition labs_ok (l : list Z) : bool := forallb (fun n => (0 <=? n) && (n <? Int.modulus)) l.

Definition tint32 : type := Tint I32 Signed noattr.

Definition sweq (c : sval) (n : Z) : sval := Sbinop Oeq c tint32 (Sconst (Vint (Int.repr n))) tint32.

Definition add_facts (g : gst) (fs : list fact) : gst := fold_left add_fact fs g.

Definition sw_out (p : spath) : spath := let '(le', g', o) := p in (le', g', sout_switch o).

Definition sw_const (c : sval) : option val := match c with Sconst v => Some v | _ => None end.

(* a call passing an integer temp that still holds Vundef (never set on
   this path) has no evaluation: the argument cast of Vundef fails *)
Definition type_is_void (ty : type) : bool := match ty with Tvoid => true | _ => false end.

Definition undef_arg (le : PTree.t sval) (a : expr) (ty : type) : bool :=
  negb (type_is_void ty) &&
  match a with
  | Etempvar id (Tint _ _ _) =>
      match le ! id with Some (Sconst Vundef) => true | _ => false end
  | _ => false
  end.

Fixpoint undef_stuck (le : PTree.t sval) (al : list expr) (tyl : list type) : bool :=
  match al, tyl with
  | a :: al', ty :: tyl' => undef_arg le a ty || undef_stuck le al' tyl'
  | _, _ => false
  end.

(* the state after naming one fresh value *)
Definition gfresh (g : gst) : gst := mkg (g_sm g) (g_pc g) (Pos.succ (g_nx g)) (g_loc g) (g_cl g).

(* a field or dereference read of a cell whose chunk never yields a
   pointer *)
Definition opq_ch (ch : memory_chunk) : bool :=
  match ch with
  | Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned | Mfloat32 | Mfloat64 => true
  | _ => false
  end.
(* the read is of a whole cell: a dereference, or a struct field that is
   not a bitfield *)
Definition opq_full (a : expr) : bool :=
  match a with
  | Ederef _ _ => true
  | Efield a1 i _ =>
      match typeof a1 with
      | Tstruct id _ =>
          match (genv_cenv ge) ! id with
          | Some co => match field_offset ge i (co_members co) with OK (_, Full) => true | _ => false end
          | None => false
          end
      | _ => false
      end
  | _ => false
  end.
Definition opq_ok (a : expr) : bool :=
  opq_full a &&
  match a with
  | Efield _ _ ty | Ederef _ ty =>
      match access_mode ty with By_value ch => opq_ch ch | _ => false end
  | _ => false
  end.
(* its name: a small int read keeps its load_result, so the term itself
   says the value is in the chunk's range *)
Definition opq_term (a : expr) (n : positive) : sval :=
  match access_mode (typeof a) with
  | By_value ((Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned) as ch) => Sldres ch (Sfresh n)
  | _ => Sfresh n
  end.

Fixpoint sx_stmt (fuel : nat) (se : PTree.t (positive * type)) (le : PTree.t sval)
    (g : gst) (s : statement) {struct fuel} : option (list spath) :=
  match fuel with
  | O => None
  | S fuel' =>
  match s with
  | Sskip => Some [(le, g, SOnormal)]
  | Sassign a1 a2 =>
      let? l := sx_lvalue se le g a1 in
      let? v2 := sx_expr se le g a2 in
      match access_mode (typeof a1), l with
      | By_value ch, Lreg r o =>
          (* a cast result is val_casted, so the load_result of the stored
             value is itself (val_casted_load_result) *)
          let? c := mk_cast v2 (typeof a2) (typeof a1) in
          let? g' := sstore g r (Ptrofs.unsigned o) ch c in
          Some [(le, g', SOnormal)]
      | _, _ => None
      end
  | Sset id a =>
      if nullx le a then Some [] else
      match sx_expr se le g a with
      | Some v => Some [(PTree.set id v le, g, SOnormal)]
      | None =>
          (* a load the description cannot place (through an unknown
             pointer) of a non-pointer cell: its value is a fresh name *)
          if opq_ok a then Some [(PTree.set id (opq_term a (g_nx g)) le, gfresh g, SOnormal)]
          else None
      end
  | Scall optid (Evar id (Tfunction tyargs tyres cconv)) al =>
      match se ! id with
      | Some _ => None
      | None =>
          let? fd := sfun_lookup id in
          if type_eq (type_of_fundef fd) (Tfunction tyargs tyres cconv) then
            if undef_stuck le al tyargs then Some [] else
            let? args := sx_exprlist se le g al tyargs in
            let? cps0 := match xc id with
                         | Some k => k args g
                         | None => sx_call fuel' g fd args
                         end in
            let? cps := (if mergef id then jgroup_c cps0 else Some cps0) in
            Some (map (fun (x : cpath) => let '(g', r) := x in
                                          (sset_opt optid r le, g', SOnormal)) cps)
          else None
      end
  | Ssequence s1 s2 =>
      let? ps := sx_stmt fuel' se le g s1 in
      oflat (fun (p : spath) =>
               match p with
               | (le1, g1, SOnormal) => sx_stmt fuel' se le1 g1 s2
               | _ => Some [p]
               end) ps
  | Sifthenelse a s1 s2 =>
      let? c := sx_expr se le g a in
      match decide (g_pc g) c (typeof a) with
      | Some b => sx_stmt fuel' se le g (if b then s1 else s2)
      | None =>
          if loc_ptr c then None else
          let? p1 := sx_stmt fuel' se le (add_fact g (Fbool c (typeof a) true)) s1 in
          let? p2 := sx_stmt fuel' se le (add_fact g (Fbool c (typeof a) false)) s2 in
          Some (p1 ++ p2)
      end
  | Sloop s1 s2 => sx_loop fuel' se [(le, g, SOnormal)] s1 s2
  | Sswitch a sl =>
      let? c := sx_expr se le g a in
      match sw_const c with
      | Some v =>
          let? n := sem_switch_arg v (typeof a) in
          let? ps := sx_stmt fuel' se le g (seq_of_labeled_statement (select_switch n sl)) in
          Some (map sw_out ps)
      | None =>
          if is_tint (typeof a) && labs_ok (sw_labels sl) then
            let? ps1 := oflat (fun n =>
                          sx_stmt fuel' se le (add_fact g (Fbool (sweq c n) tint32 true))
                            (seq_of_labeled_statement (select_switch n sl))) (sw_labels sl) in
            let? ps2 := sx_stmt fuel' se le
                          (add_facts g (map (fun n => Fbool (sweq c n) tint32 false) (sw_labels sl)))
                          (seq_of_labeled_statement (select_switch_default sl)) in
            Some (map sw_out (ps1 ++ ps2))
          else None
      end
  | Sreturn None => Some [(le, g, SOreturn None)]
  | Sreturn (Some a) =>
      let? v := sx_expr se le g a in Some [(le, g, SOreturn (Some (v, typeof a)))]
  | Sbreak => Some [(le, g, SObreak)]
  | Scontinue => Some [(le, g, SOcontinue)]
  | _ => None
  end
  end

(* a loop runs all its live states together, one iteration per round, so
   the back edges of a round are joined before the next round *)
with sx_loop (fuel : nat) (se : PTree.t (positive * type)) (st : list spath)
    (s1 s2 : statement) {struct fuel} : option (list spath) :=
  match fuel with
  | O => None
  | S fuel' =>
  match st with
  | nil => Some nil
  | _ =>
      (* one iteration from every state: exits (left) and back edges (right) *)
      let? rs := oflat (fun (p0 : spath) =>
        let '(le, g, _) := p0 in
        let? ps1 := sx_stmt fuel' se le g s1 in
        oflat (fun (p : spath) =>
          let '(le1, g1, o1) := p in
          match o1 with
          | SObreak => Some [inl (le1, g1, SOnormal)]
          | SOreturn _ => Some [inl p]
          | SOnormal | SOcontinue =>
              let? ps2 := sx_stmt fuel' se le1 g1 s2 in
              Some (flat_map (fun (q : spath) =>
                let '(le2, g2, o2) := q in
                match o2 with
                | SOnormal => [inr q]
                | SObreak => [inl (le2, g2, SOnormal)]
                | SOreturn _ => [inl q]
                | SOcontinue => nil
                end) ps2)
          end) ps1) st in
      let exits := lexits rs in
      let backs := lbacks rs in
      let backs' := if jloops then jgroup backs else backs in
      let? more := sx_loop fuel' se backs' s1 s2 in
      Some (if jloops then jgroup (exits ++ more) else exits ++ more)
  end
  end
with sx_call (fuel : nat) (g : gst) (fd : fundef) (args : list sval)
    {struct fuel} : option (list cpath) :=
  match fuel with
  | O => None
  | S fuel' =>
  match fd with
  | Internal f =>
      if list_norepet_dec ident_eq (var_names f.(fn_vars)) then
      if list_norepet_dec ident_eq (var_names f.(fn_params)) then
      if list_disjoint_dec ident_eq (var_names f.(fn_params)) (var_names f.(fn_temps)) then
        let '(se, g1) := salloc f.(fn_vars) (PTree.empty _) g in
        let? le := sbind f.(fn_params) args (sundef f.(fn_temps)) in
        let? ps := sx_stmt fuel' se le g1 f.(fn_body) in
        omap (fun (p : spath) =>
                let '(_, g2, out) := p in
                let? r := sresult out f.(fn_return) in
                Some (sfree (g_loc g) g2, r)) ps
      else None else None else None
  | External _ _ _ _ => None
  end
  end.


(* ================================================================ *)
(* SOUNDNESS (coverage)                                               *)
(* ================================================================ *)

Variable m0 : mem.
(* the meaning of the consumer's facts [Fuser k args] *)
Variable uf : positive -> list (option val) -> Prop.

Local Notation nb0 := (Mem.nextblock m0).

(* m0's PUBLIC blocks: a flat partial self-map (Generic ClosedMem's
   closed_by).  Old values point only at public blocks, and only public
   blocks need pointer-closed contents ([m0_closed] below).  A real memory
   is closed only this way: an external call may leave blocks it allocated
   unmapped, with any contents. *)
Variable gp : meminj.
Hypothesis gp_flat : forall b b' d, gp b = Some (b', d) -> b' = b /\ d = 0.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b nb0.

Record senv : Type := mke {
  e_blk : positive -> block;
  e_base : positive -> ptrofs;
  e_rho : positive -> option val
}.

Definition val_old (v : val) : Prop :=
  match v with Vptr b _ => gp b <> None | _ => True end.

Lemma pub_plt : forall b, gp b <> None -> Plt b nb0.
Proof. intros b H. destruct (gp b) as [x|] eqn:G; [ exact (gp_old b x G) | congruence ]. Qed.

Lemma val_old_plt : forall b o, val_old (Vptr b o) -> Plt b nb0.
Proof.
  intros b o H. cbn in H. destruct (gp b) as [x|] eqn:G; [ exact (gp_old b x G) | congruence ].
Qed.

Fixpoint den (E : senv) (a : sval) : option val :=
  match a with
  | Sconst v => Some v
  | Sptr r o => Some (Vptr (e_blk E r) (Ptrofs.add (e_base E r) o))
  | Sinit r o ch => Mem.load ch m0 (e_blk E r) (Ptrofs.unsigned (e_base E r) + o)
  | Swld p k ch =>
      match den E p with
      | Some (Vptr b o) => Mem.load ch m0 b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr k)))
      | _ => None
      end
  | Swoff p k =>
      match den E p with
      | Some (Vptr b o) => Some (Vptr b (Ptrofs.add o (Ptrofs.repr k)))
      | _ => None
      end
  | Sfresh n => e_rho E n
  | Sunop op a ty => let? v := den E a in sem_unary_operation op v ty m0
  | Sbinop op a1 t1 a2 t2 =>
      let? v1 := den E a1 in let? v2 := den E a2 in sem_binary_operation ge op v1 t1 v2 t2 m0
  | Scast a t1 t2 => let? v := den E a in sem_cast v t1 t2 m0
  | Sldres ch a => let? v := den E a in Some (Val.load_result ch v)
  end.

(* names occurring in a term are below n *)
Fixpoint nlt (n : positive) (a : sval) : Prop :=
  match a with
  | Sconst _ => True
  | Sptr r _ => Plt r n
  | Sinit r _ _ => Plt r n
  | Swld p _ _ => nlt n p
  | Swoff p _ => nlt n p
  | Sfresh k => Plt k n
  | Sunop _ a _ => nlt n a
  | Sbinop _ a1 _ a2 _ => nlt n a1 /\ nlt n a2
  | Scast a _ _ => nlt n a
  | Sldres _ a => nlt n a
  end.

(* "deep old": no local region's address and no pointer constant inside;
   such a term denotes a value pointing only at m0's blocks *)
Fixpoint dold (a : sval) : Prop :=
  match a with
  | Sconst v => non_ptr v = true
  | Sptr r _ => Plt r nbase
  | Sinit r _ _ => Plt r nbase
  | Swld p _ _ => dold p
  | Swoff p _ => dold p
  | Sfresh _ => True
  | Sunop _ a _ => dold a
  | Sbinop _ a1 _ a2 _ => dold a1 /\ dold a2
  | Scast a _ _ => dold a
  | Sldres _ a => dold a
  end.

(* the shape every term in a state has: a region address, or deep old *)
Definition sok (n : positive) (a : sval) : Prop :=
  nlt n a /\ match a with Sptr _ _ => True | _ => dold a end.

Definition fact_nlt (n : positive) (f : fact) : Prop :=
  match f with
  | Fbool c _ _ => nlt n c
  | Fworld p _ => nlt n p
  | Fbits t _ => nlt n t
  | Fuser _ args => Forall (nlt n) args
  end.

Definition Ext (E E' : senv) (n : positive) : Prop :=
  forall k, Plt k n -> e_blk E' k = e_blk E k /\ e_base E' k = e_base E k /\ e_rho E' k = e_rho E k.

Definition addr (E : senv) (r : positive) (o : Z) : Z := Ptrofs.unsigned (e_base E r) + o.

Definition cell_disj (E : senv) (k : positive * Z * memory_chunk) (b : block) (z : Z)
    (ch : memory_chunk) : Prop :=
  let '(r, o, ch') := k in
  e_blk E r <> b \/ addr E r o + size_chunk ch' <= z \/ z + size_chunk ch <= addr E r o.

Definition fact_holds (E : senv) (f : fact) : Prop :=
  match f with
  | Fbool c ty b => exists v, den E c = Some v /\ bool_val v ty m0 = Some b
  | Fworld p n =>
      exists b o, den E p = Some (Vptr b o) /\ Plt b nb0 /\ 0 <= n
        /\ Ptrofs.unsigned o + n <= Ptrofs.modulus
        /\ (forall r sz, r0_size r = Some sz ->
              e_blk E r <> b \/ Ptrofs.unsigned (e_base E r) + sz <= Ptrofs.unsigned o
              \/ Ptrofs.unsigned o + n <= Ptrofs.unsigned (e_base E r))
  | Fbits t mask => exists i, den E t = Some (Vint i) /\ Int.and i mask = Int.zero
  | Fuser k args => uf k (map (den E) args)
  end.

(* a cell outside region r's whole range (a region without a size
   constrains nothing, so it counts as outside) *)
Definition rng_disj (E : senv) (r : positive) (b : block) (z : Z) (ch : memory_chunk) : Prop :=
  match r0_size r with
  | Some sz => e_blk E r <> b \/ Ptrofs.unsigned (e_base E r) + sz <= z
               \/ z + size_chunk ch <= Ptrofs.unsigned (e_base E r)
  | None => True
  end.

Lemma rng_disj_eq : forall E E' r b z ch, e_blk E' = e_blk E -> e_base E' = e_base E ->
  rng_disj E r b z ch -> rng_disj E' r b z ch.
Proof. intros E E' r b z ch A B. unfold rng_disj. rewrite A, B. auto. Qed.

(* the consumer's regions, the globals table and the known values *)
Definition env_ok (E : senv) : Prop :=
  (forall r, Plt r nbase -> gp (e_blk E r) <> None)
  /\ (forall r sz, r0_size r = Some sz ->
        Plt r nbase /\ 0 <= sz /\ Ptrofs.unsigned (e_base E r) + sz <= Ptrofs.modulus)
  /\ (forall r sz r' sz', r0_size r = Some sz -> r0_size r' = Some sz' -> r <> r' ->
        e_blk E r <> e_blk E r'
        \/ Ptrofs.unsigned (e_base E r) + sz <= Ptrofs.unsigned (e_base E r')
        \/ Ptrofs.unsigned (e_base E r') + sz' <= Ptrofs.unsigned (e_base E r))
  /\ (forall id r, gfind id = Some r ->
        Plt r nbase /\ e_base E r = Ptrofs.zero /\ Genv.find_symbol ge id = Some (e_blk E r))
  /\ (forall r o ch sv, In (r, o, ch, sv) kv ->
        Plt r nbase /\ sok nbase sv /\ Mem.load ch m0 (e_blk E r) (addr E r o) = den E sv)
  /\ (forall n v, e_rho E n = Some v -> val_old v).

(* old blocks keep exactly their m0 permissions (so a cell readable at m0
   is readable at m) *)
Definition vp_old (m : mem) : Prop :=
  forall b o k p, Plt b nb0 -> (Mem.perm m b o k p <-> Mem.perm m0 b o k p).

(* the symbolic global state describes memory m *)
Definition MMg (E : senv) (m : mem) (g : gst) : Prop :=
  env_ok E
  /\ Ple nbase (g_nx g)
  /\ (forall r o ch sv, In (r, o, ch, sv) (g_sm g) ->
        inb g r o ch = true /\ sok (g_nx g) sv
        /\ Mem.load ch m (e_blk E r) (addr E r o) = den E sv)
  /\ (forall b z ch, Plt b nb0 ->
        (forall e, In e (g_sm g) -> cell_disj E (skey e) b z ch) ->
        (forall r, In r (g_cl g) -> rng_disj E r b z ch) ->
        Mem.load ch m b z = Mem.load ch m0 b z)
  /\ vp_old m
  /\ Ple nb0 (Mem.nextblock m)
  /\ (forall f, In f (g_pc g) -> fact_nlt (g_nx g) f /\ fact_holds E f)
  /\ (forall r, In r (g_loc g) ->
        ~ Plt r nbase /\ Plt r (g_nx g) /\ e_base E r = Ptrofs.zero
        /\ ~ Plt (e_blk E r) nb0 /\ Plt (e_blk E r) (Mem.nextblock m))
  /\ (forall r r', In r (g_loc g) -> In r' (g_loc g) -> e_blk E r = e_blk E r' -> r = r').

(* ---------------------------------------------------------------- *)
(* Names, extension                                                   *)
(* ---------------------------------------------------------------- *)

Lemma Ext_refl : forall E n, Ext E E n.
Proof. intros E n k _. auto. Qed.

Lemma Ext_mono : forall E E' n n', Ext E E' n' -> Ple n n' -> Ext E E' n.
Proof. intros E E' n n' H L k Hk. apply H. unfold Plt, Ple in *. lia. Qed.

(* clobber regions are consumer regions, so an extension keeps their placement *)
Lemma rng_disj_Ext : forall E E' n r b z ch, env_ok E -> Ple nbase n -> Ext E E' n ->
  rng_disj E' r b z ch <-> rng_disj E r b z ch.
Proof.
  intros E E' n r b z ch EO L X. unfold rng_disj.
  destruct (r0_size r) as [sz|] eqn:S; [ | tauto ].
  destruct EO as (_ & A2 & _). destruct (A2 r sz S) as (P & _).
  destruct (X r) as (B1 & B2 & _); [ unfold Plt, Ple in *; lia | ]. rewrite B1, B2. tauto.
Qed.

Lemma Ext_trans : forall E1 E2 E3 n n', Ext E1 E2 n -> Ext E2 E3 n' -> Ple n n' -> Ext E1 E3 n.
Proof.
  intros E1 E2 E3 n n' A B L k Hk.
  destruct (A k Hk) as (A1 & A2 & A3).
  assert (Hk' : Plt k n') by (unfold Plt, Ple in *; lia).
  destruct (B k Hk') as (B1 & B2 & B3). rewrite B1, B2, B3. auto.
Qed.

Lemma nlt_mono : forall a n n', nlt n a -> Ple n n' -> nlt n' a.
Proof.
  induction a; cbn; intros n1 n2 H L; try tauto; try (unfold Plt, Ple in *; lia);
    eauto.
  destruct H; split; eauto.
Qed.

Lemma sok_mono : forall a n n', sok n a -> Ple n n' -> sok n' a.
Proof. intros a n n' [H1 H2] L. split; [ eapply nlt_mono; eauto | exact H2 ]. Qed.

Lemma den_ext : forall E E' n a, nlt n a -> Ext E E' n -> den E' a = den E a.
Proof.
  intros E E' n a. induction a; cbn; intros H X; auto.
  - destruct (X r H) as (-> & -> & _). reflexivity.
  - destruct (X r H) as (-> & -> & _). reflexivity.
  - rewrite IHa; auto.
  - rewrite IHa; auto.
  - destruct (X n0 H) as (_ & _ & ->). reflexivity.
  - rewrite IHa; auto.
  - destruct H. rewrite IHa1, IHa2; auto.
  - rewrite IHa; auto.
  - rewrite IHa; auto.
Qed.

Lemma Forall_nlt_mono : forall l n n', Forall (nlt n) l -> Ple n n' -> Forall (nlt n') l.
Proof. intros l n n' H L. eapply Forall_impl; [ | exact H ]. intros; eapply nlt_mono; eauto. Qed.

Lemma fact_nlt_mono : forall f n n', fact_nlt n f -> Ple n n' -> fact_nlt n' f.
Proof.
  intros f n1 n2 H L; destruct f; cbn in *; eauto using nlt_mono, Forall_nlt_mono.
Qed.

Lemma map_den_ext : forall E E' n l, Forall (nlt n) l -> Ext E E' n -> map (den E') l = map (den E) l.
Proof.
  intros E E' n l H X. induction H; cbn; auto. rewrite IHForall, (den_ext E E' n x); auto.
Qed.

Lemma env_ok_ext : forall E E', env_ok E -> Ext E E' nbase ->
  (forall n v, e_rho E' n = Some v -> val_old v) -> env_ok E'.
Proof.
  intros E E' (A1 & A2 & A3 & A4 & A5 & A6) X R.
  assert (XB : forall r, Plt r nbase -> e_blk E' r = e_blk E r /\ e_base E' r = e_base E r)
    by (intros r Hr; destruct (X r Hr) as (? & ? & _); auto).
  split; [ | split; [ | split; [ | split; [ | split ] ] ] ].
  - intros r Hr. rewrite (proj1 (XB r Hr)). auto.
  - intros r sz Hs. destruct (A2 r sz Hs) as (Hr & H1 & H2). rewrite (proj2 (XB r Hr)). auto.
  - intros r sz r' sz' Hs Hs' NE.
    destruct (A2 r sz Hs) as (Hr & _), (A2 r' sz' Hs') as (Hr' & _).
    rewrite (proj1 (XB r Hr)), (proj2 (XB r Hr)), (proj1 (XB r' Hr')), (proj2 (XB r' Hr')).
    auto.
  - intros id r G. destruct (A4 id r G) as (Hr & H1 & H2).
    rewrite (proj1 (XB r Hr)), (proj2 (XB r Hr)). auto.
  - intros r o ch sv IN. destruct (A5 r o ch sv IN) as (Hr & Hs & HL).
    split; [ exact Hr | split; [ exact Hs | ] ].
    unfold addr. rewrite (proj1 (XB r Hr)), (proj2 (XB r Hr)).
    rewrite (den_ext E E' nbase); [ exact HL | apply Hs | exact X ].
  - exact R.
Qed.

(* ---------------------------------------------------------------- *)
(* Memory independence of the operators (old values)                  *)
(* ---------------------------------------------------------------- *)

Definition fi : meminj := fun b => match gp b with Some _ => Some (b, 0) | None => None end.

Lemma fi_old : forall b b' d, fi b = Some (b', d) -> b' = b /\ d = 0 /\ Plt b nb0.
Proof.
  unfold fi; intros b b' d H. destruct (gp b) as [x|] eqn:G; [ | discriminate ].
  injection H as <- <-. split; [ reflexivity | split; [ reflexivity | exact (gp_old b x G) ] ].
Qed.

Lemma inj_old : forall v, val_old v -> Val.inject fi v v.
Proof.
  intros [] H; try constructor. econstructor.
  - unfold fi. cbn in H. destruct (gp b); [ reflexivity | contradiction ].
  - rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma inj_old_l : forall v w, Val.inject fi v w -> val_old v.
Proof.
  intros v w H. inv H; cbn; auto. unfold fi in H0. destruct (gp b1); congruence.
Qed.

Lemma inj_old_def : forall v w, Val.inject fi v w -> v <> Vundef -> v = w.
Proof.
  intros v w H N. inv H; auto; [ | congruence ].
  apply fi_old in H0. destruct H0 as (-> & -> & _). rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma inj_old_antisym : forall v w, Val.inject fi v w -> Val.inject fi w v -> v = w.
Proof.
  intros v w H1 H2. destruct v; try (apply inj_old_def; [ exact H1 | discriminate ]).
  inv H2; reflexivity.
Qed.

Definition vpo (m1 m2 : mem) : Prop :=
  forall b o, Plt b nb0 -> Mem.valid_pointer m1 b o = Mem.valid_pointer m2 b o.

Lemma vpo_sym : forall m1 m2, vpo m1 m2 -> vpo m2 m1.
Proof. unfold vpo; intros; symmetry; auto. Qed.

Section VPO.
Variables m1 m2 : mem.
Hypothesis A : vpo m1 m2.

Lemma vpo1 : forall b1 ofs b2 delta, fi b1 = Some (b2, delta) ->
  Mem.valid_pointer m1 b1 (Ptrofs.unsigned ofs) = true ->
  Mem.valid_pointer m2 b2 (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr delta))) = true.
Proof.
  intros b1 ofs b2 delta H V. apply fi_old in H. destruct H as (-> & -> & P).
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. rewrite <- A; auto.
Qed.

Lemma vpo2 : forall b1 ofs b2 delta, fi b1 = Some (b2, delta) ->
  Mem.weak_valid_pointer m1 b1 (Ptrofs.unsigned ofs) = true ->
  Mem.weak_valid_pointer m2 b2 (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr delta))) = true.
Proof.
  unfold Mem.weak_valid_pointer; intros b1 ofs b2 delta H V. apply fi_old in H.
  destruct H as (-> & -> & P).
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. rewrite <- !A; auto.
Qed.

Lemma vpo3 : forall b1 ofs b2 delta, fi b1 = Some (b2, delta) ->
  Mem.weak_valid_pointer m1 b1 (Ptrofs.unsigned ofs) = true ->
  0 <= Ptrofs.unsigned ofs + Ptrofs.unsigned (Ptrofs.repr delta) <= Ptrofs.max_unsigned.
Proof.
  intros b1 ofs b2 delta H V. apply fi_old in H. destruct H as (_ & -> & _).
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.unsigned_zero.
  pose proof (Ptrofs.unsigned_range_2 ofs). lia.
Qed.

Lemma vpo4 : forall b1 ofs1 b2 ofs2 b1' delta1 b2' delta2, b1 <> b2 ->
  Mem.valid_pointer m1 b1 (Ptrofs.unsigned ofs1) = true ->
  Mem.valid_pointer m1 b2 (Ptrofs.unsigned ofs2) = true ->
  fi b1 = Some (b1', delta1) -> fi b2 = Some (b2', delta2) ->
  b1' <> b2' \/
  Ptrofs.unsigned (Ptrofs.add ofs1 (Ptrofs.repr delta1)) <>
  Ptrofs.unsigned (Ptrofs.add ofs2 (Ptrofs.repr delta2)).
Proof.
  intros. apply fi_old in H2. apply fi_old in H3.
  destruct H2 as (-> & _), H3 as (-> & _). left; exact H.
Qed.
End VPO.

Lemma bin_old : forall m1 m2 op v1 t1 v2 t2 v, vpo m1 m2 -> val_old v1 -> val_old v2 ->
  sem_binary_operation ge op v1 t1 v2 t2 m1 = Some v ->
  sem_binary_operation ge op v1 t1 v2 t2 m2 = Some v /\ val_old v.
Proof.
  intros m1 m2 op v1 t1 v2 t2 v A O1 O2 H.
  destruct (sem_binary_operation_inj fi m1 m2 (vpo1 _ _ A) (vpo2 _ _ A) (vpo3 m1)
              (vpo4 m1) ge op v1 t1 v2 t2 v v1 v2 H (inj_old _ O1) (inj_old _ O2))
    as [w [Hw Iw]].
  pose proof (vpo_sym _ _ A) as A'.
  destruct (sem_binary_operation_inj fi m2 m1 (vpo1 _ _ A') (vpo2 _ _ A') (vpo3 m2)
              (vpo4 m2) ge op v1 t1 v2 t2 w v1 v2 Hw (inj_old _ O1) (inj_old _ O2))
    as [w' [Hw' Iw']].
  rewrite H in Hw'. inv Hw'.
  rewrite (inj_old_antisym _ _ Iw Iw'). split; [ exact Hw | ].
  eapply inj_old_l; eauto.
Qed.

Lemma un_old : forall m1 m2 op v1 ty v, vpo m1 m2 -> val_old v1 ->
  sem_unary_operation op v1 ty m1 = Some v -> sem_unary_operation op v1 ty m2 = Some v /\ val_old v.
Proof.
  intros m1 m2 op v1 ty v A O H.
  destruct (sem_unary_operation_inj fi m1 m2 (vpo2 _ _ A) op v1 ty v v1 H (inj_old _ O))
    as [w [Hw Iw]].
  pose proof (vpo_sym _ _ A) as A'.
  destruct (sem_unary_operation_inj fi m2 m1 (vpo2 _ _ A') op v1 ty w v1 Hw (inj_old _ O))
    as [w' [Hw' Iw']].
  rewrite H in Hw'. inv Hw'.
  rewrite (inj_old_antisym _ _ Iw Iw'). split; [ exact Hw | eapply inj_old_l; eauto ].
Qed.

Lemma cast_old : forall m1 m2 v1 t1 t2 v, vpo m1 m2 -> val_old v1 ->
  sem_cast v1 t1 t2 m1 = Some v -> sem_cast v1 t1 t2 m2 = Some v /\ val_old v.
Proof.
  intros m1 m2 v1 t1 t2 v A O H.
  destruct (sem_cast_inj fi m1 m2 (vpo2 _ _ A) v1 t1 t2 v v1 H (inj_old _ O))
    as [w [Hw Iw]].
  pose proof (vpo_sym _ _ A) as A'.
  destruct (sem_cast_inj fi m2 m1 (vpo2 _ _ A') v1 t1 t2 w v1 Hw (inj_old _ O))
    as [w' [Hw' Iw']].
  rewrite H in Hw'. inv Hw'.
  rewrite (inj_old_antisym _ _ Iw Iw'). split; [ exact Hw | eapply inj_old_l; eauto ].
Qed.

Lemma bool_old : forall m1 m2 v ty b, vpo m1 m2 -> val_old v ->
  bool_val v ty m1 = Some b -> bool_val v ty m2 = Some b.
Proof.
  intros m1 m2 v ty b A O H.
  exact (bool_val_inj fi m1 m2 (vpo2 _ _ A) v ty b v H (inj_old _ O)).
Qed.

Lemma vp_old_vpo : forall m, vp_old m -> vpo m m0.
Proof.
  unfold vp_old, vpo; intros m H b o OLD.
  destruct (Mem.valid_pointer m b o) eqn:E1; destruct (Mem.valid_pointer m0 b o) eqn:E2; auto.
  - apply Mem.valid_pointer_nonempty_perm in E1. apply (H b o Cur Nonempty OLD) in E1.
    apply Mem.valid_pointer_nonempty_perm in E1. congruence.
  - apply Mem.valid_pointer_nonempty_perm in E2. apply (H b o Cur Nonempty OLD) in E2.
    apply Mem.valid_pointer_nonempty_perm in E2. congruence.
Qed.

Lemma wvp_valid : forall m b o, Mem.weak_valid_pointer m b o = true -> Mem.valid_block m b.
Proof.
  intros m b o W. apply Mem.weak_valid_pointer_spec in W.
  destruct W as [W|W]; apply Mem.valid_pointer_nonempty_perm in W; eapply Mem.perm_valid_block; eauto.
Qed.

(* a defined bool_val at m0 only looks at m0's blocks, so it transfers *)
Lemma bool_val_m0_transfer : forall m v ty b, vpo m0 m ->
  bool_val v ty m0 = Some b -> bool_val v ty m = Some b.
Proof.
  intros m v ty b A H. destruct v as [ | | | | | b0 i ];
    [ exact H | | | | | ];
    [ eapply bool_old; [ exact A | exact I | exact H ] .. | ].
  unfold bool_val in *. destruct (classify_bool ty); destruct Archi.ptr64 eqn:P; cbn in *;
    try discriminate;
    destruct (Mem.weak_valid_pointer m0 b0 (Ptrofs.unsigned i)) eqn:W; try discriminate;
    pose proof (wvp_valid _ _ _ W) as V; unfold Mem.weak_valid_pointer in *;
    rewrite <- !(A b0 _ V); rewrite W; exact H.
Qed.

(* ---------------------------------------------------------------- *)
(* Old values                                                         *)
(* ---------------------------------------------------------------- *)

Hypothesis m0_closed : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old v.

Lemma load_result_old : forall ch v, val_old v -> val_old (Val.load_result ch v).
Proof.
  intros ch v H. destruct ch, v; cbn in *; auto; try (destruct Archi.ptr64; cbn; auto).
  all: unfold Val.norm_bool; destruct (Val.is_bool _); exact I.
Qed.

Lemma den_old : forall E a w, env_ok E -> dold a -> den E a = Some w -> val_old w.
Proof.
  intros E a. induction a; cbn; intros w EO D H.
  - inv H. destruct w; cbn in *; auto; discriminate.
  - inv H. cbn. destruct EO as (A1 & _). apply A1. exact D.
  - eapply m0_closed; [ destruct EO as (A1 & _); exact (A1 _ D) | exact H ].
  - destruct (den E a) as [[]|]; try discriminate.
    eapply m0_closed; [ exact (IHa _ EO D eq_refl) | exact H ].
  - destruct (den E a) as [[]|] eqn:Ea; try discriminate. inv H.
    cbn. exact (IHa _ EO D eq_refl).
  - destruct EO as (_ & _ & _ & _ & _ & R). eapply R; eauto.
  - destruct (den E a) as [v1|] eqn:Ea; [ | discriminate ].
    exact (proj2 (un_old m0 m0 _ _ _ _ (fun _ _ _ => eq_refl) (IHa _ EO D eq_refl) H)).
  - destruct D as [D1 D2].
    destruct (den E a1) as [v1|] eqn:E1; [ | discriminate ].
    destruct (den E a2) as [v2|] eqn:E2; [ | discriminate ].
    exact (proj2 (bin_old m0 m0 _ _ _ _ _ _ (fun _ _ _ => eq_refl)
                    (IHa1 _ EO D1 eq_refl) (IHa2 _ EO D2 eq_refl) H)).
  - destruct (den E a) as [v1|] eqn:Ea; [ | discriminate ].
    exact (proj2 (cast_old m0 m0 _ _ _ _ (fun _ _ _ => eq_refl) (IHa _ EO D eq_refl) H)).
  - destruct (den E a) as [v1|] eqn:Ea; [ | discriminate ]. inv H.
    apply load_result_old. exact (IHa _ EO D eq_refl).
Qed.

Lemma sok_old : forall E n a v, env_ok E -> sok n a -> loc_ptr a = false ->
  den E a = Some v -> val_old v.
Proof.
  intros E n a v EO [_ S] L D. destruct a; try (eapply den_old; eauto; fail).
  cbn in L, D. inv D. cbn. destruct EO as (A1 & _). apply A1.
  unfold is_local in L. apply negb_false_iff in L. apply Pos.ltb_lt. exact L.
Qed.

(* ---------------------------------------------------------------- *)
(* Cells                                                              *)
(* ---------------------------------------------------------------- *)

Lemma r0_size_in : forall r sz, r0_size r = Some sz -> In (r, sz) R0.
Proof.
  unfold r0_size; intros r sz H.
  destruct (find _ R0) as [[r' sz']|] eqn:F; [ | discriminate ]. inv H.
  apply find_some in F. destruct F as [IN E]. cbn in E. apply Pos.eqb_eq in E. subst. exact IN.
Qed.

Lemma inb_spec : forall g r o ch, inb g r o ch = true ->
  (Plt r nbase /\ exists sz, r0_size r = Some sz /\ 0 <= o /\ o + size_chunk ch <= sz)
  \/ (~ Plt r nbase /\ In r (g_loc g) /\ 0 <= o /\ o + size_chunk ch <= Ptrofs.modulus).
Proof.
  unfold inb; intros g r o ch H.
  destruct (Pos.ltb_spec r nbase) as [L | L].
  - left. split; [ exact L | ].
    destruct (r0_size r) as [sz|]; [ | discriminate ].
    apply andb_true_iff in H as [H1 H2]. apply Z.leb_le in H1. apply Z.leb_le in H2. eauto.
  - right. apply andb_true_iff in H as [H H3]. apply andb_true_iff in H as [H1 H2].
    apply existsb_exists in H1. destruct H1 as [x [IN E]]. apply Pos.eqb_eq in E. subst x.
    apply Z.leb_le in H2. apply Z.leb_le in H3.
    split; [ unfold Plt, Ple in *; lia | ]. auto.
Qed.

(* an in-bounds cell, in absolute terms *)
Lemma inb_abs : forall E m g r o ch, MMg E m g -> inb g r o ch = true ->
  0 <= o /\ 0 <= addr E r o /\ addr E r o + size_chunk ch <= Ptrofs.modulus.
Proof.
  intros E m g r o ch MM H. pose proof (Ptrofs.unsigned_range (e_base E r)) as BR.
  pose proof (size_chunk_pos ch) as SP.
  destruct (inb_spec _ _ _ _ H) as [(L & sz & S & O1 & O2) | (L & IN & O1 & O2)].
  - destruct MM as ((_ & A2 & _) & _). destruct (A2 r sz S) as (_ & _ & A). unfold addr. lia.
  - destruct MM as (_ & _ & _ & _ & _ & _ & _ & LOC & _).
    destruct (LOC r IN) as (_ & _ & B & _). unfold addr. rewrite B, Ptrofs.unsigned_zero. lia.
Qed.

Lemma addr_ptrofs : forall E m g r o ch, MMg E m g -> inb g r (Ptrofs.unsigned o) ch = true ->
  Ptrofs.unsigned (Ptrofs.add (e_base E r) o) = addr E r (Ptrofs.unsigned o).
Proof.
  intros E m g r o ch MM H. destruct (inb_abs _ _ _ _ _ _ MM H) as (_ & A1 & A2).
  pose proof (size_chunk_pos ch).
  unfold addr in *. rewrite Ptrofs.add_unsigned. apply Ptrofs.unsigned_repr.
  unfold Ptrofs.max_unsigned. lia.
Qed.

(* two in-bounds cells that do not overlap in the executor's terms do not
   overlap in memory *)
Lemma inb_disj : forall E m g r o ch r' o' ch', MMg E m g ->
  inb g r o ch = true -> inb g r' o' ch' = true ->
  r <> r' \/ o + size_chunk ch <= o' \/ o' + size_chunk ch' <= o ->
  cell_disj E (r, o, ch) (e_blk E r') (addr E r' o') ch'.
Proof.
  intros E m g r o ch r' o' ch' MM H H' D. cbn.
  pose proof MM as ((A1 & A2 & A3 & _) & _ & _ & _ & _ & _ & _ & LOC & LINJ).
  destruct (Pos.eq_dec r r') as [<- | NE].
  - destruct D as [D | D]; [ congruence | ]. right. unfold addr. lia.
  - destruct (inb_spec _ _ _ _ H) as [(L & sz & S & O1 & O2) | (L & IN & O1 & O2)];
    destruct (inb_spec _ _ _ _ H') as [(L' & sz' & S' & O1' & O2') | (L' & IN' & O1' & O2')].
    + destruct (A3 r sz r' sz' S S' NE) as [B | [B | B]]; [ left; exact B | right | right ];
        unfold addr; lia.
    + left. intro B. destruct (LOC r' IN') as (_ & _ & _ & N & _). apply N. rewrite <- B. eauto using pub_plt.
    + left. intro B. destruct (LOC r IN) as (_ & _ & _ & N & _). apply N. rewrite B. eauto using pub_plt.
    + left. intro B. apply NE. apply LINJ; auto.
Qed.

Lemma ovl_false : forall r o ch r' o' ch' sv,
  ovl r o ch (r', o', ch', sv) = false ->
  r <> r' \/ o' + size_chunk ch' <= o \/ o + size_chunk ch <= o'.
Proof.
  unfold ovl; intros.
  destruct (Pos.eqb_spec r r'); [ | left; auto]. subst. right.
  cbn [andb] in H. destruct (Z.ltb_spec o (o' + size_chunk ch')); cbn [andb] in H.
  - destruct (Z.ltb_spec o' (o + size_chunk ch)); [discriminate | right; lia].
  - left; lia.
Qed.

Lemma exact_true : forall r o ch r' o' ch' sv,
  exact r o ch (r', o', ch', sv) = true -> r = r' /\ o = o' /\ ch = ch'.
Proof.
  unfold exact; intros.
  destruct (Pos.eqb_spec r r'); [ | discriminate].
  destruct (Z.eqb_spec o o'); [ | discriminate].
  destruct (chunk_eq ch ch'); [ | discriminate].
  auto.
Qed.

Lemma filter_nil_iff : forall {A : Type} (f : A -> bool) l,
  filter f l = nil <-> (forall x, In x l -> f x = false).
Proof.
  intros A f l. induction l as [|a l IH]; cbn; [ tauto | ].
  destruct (f a) eqn:F; split; intros H.
  - discriminate.
  - rewrite (H a (or_introl eq_refl)) in F. discriminate.
  - intros x [<- | IN]; [ exact F | apply IH; auto ].
  - apply IH. intros x IN. apply H. auto.
Qed.

Lemma init_cell_den : forall E r o ch, env_ok E ->
  den E (init_cell r o ch) = Mem.load ch m0 (e_blk E r) (addr E r o)
  /\ (Plt r nbase -> sok nbase (init_cell r o ch)).
Proof.
  intros E r o ch EO. unfold init_cell.
  destruct (find _ kv) as [[[[r' o'] ch'] sv]|] eqn:F.
  - apply find_some in F. destruct F as [IN Hk].
    destruct (Pos.eqb_spec r r'); [ | discriminate]. subst.
    destruct (Z.eqb_spec o o'); [ | discriminate]. subst.
    destruct (chunk_eq ch ch'); [ | discriminate]. subst.
    destruct EO as (_ & _ & _ & _ & A5 & _). destruct (A5 _ _ _ _ IN) as (_ & S & L).
    split; [ symmetry; exact L | auto ].
  - split; [ reflexivity | ]. intros L. split; cbn; exact L.
Qed.

(* an in-bounds cell of an unclobbered consumer region is outside every
   other region's range (env_ok's disjointness) *)
Lemma cl_disj_region : forall E m g r o ch r', MMg E m g ->
  inb g r o ch = true -> Plt r nbase -> r <> r' ->
  rng_disj E r' (e_blk E r) (addr E r o) ch.
Proof.
  intros E m g r o ch r' MM H L NE. unfold rng_disj.
  destruct (r0_size r') as [sz'|] eqn:S'; [ | exact I ].
  pose proof MM as ((A1 & A2 & A3 & _) & _).
  destruct (inb_spec _ _ _ _ H) as [(_ & sz & S & O1 & O2) | (L' & _)];
    [ | exfalso; exact (L' L) ].
  destruct (A3 r sz r' sz' S S' NE) as [B | [B | B]].
  - left. intro B'. apply B. symmetry. exact B'.
  - right; right. unfold addr. lia.
  - right; left. unfold addr. lia.
Qed.

Lemma sload_sound : forall E m g r o ch sa, MMg E m g ->
  sload g r o ch = Some sa ->
  Mem.load ch m (e_blk E r) (addr E r o) = den E sa /\ sok (g_nx g) sa.
Proof.
  intros E m g r o ch sa MM H. unfold sload in H.
  destruct (inb g r o ch) eqn:IB; [ | discriminate ].
  pose proof MM as (EO & NB & ENT & FR & _).
  destruct (filter (ovl r o ch) (g_sm g)) as [|e [|e' l]] eqn:F.
  - destruct (Pos.ltb_spec r nbase) as [L | L]; [ | discriminate ].
    destruct (existsb (Pos.eqb r) (g_cl g)) eqn:CL; [ discriminate | ]. inv H.
    destruct (init_cell_den E r o ch EO) as [D S].
    split; [ | eapply sok_mono; [ exact (S L) | exact NB ] ].
    rewrite D. apply FR.
    + destruct EO as (A1 & _). apply pub_plt, A1. exact L.
    + intros [[[r' o'] ch'] sv] IN. cbn [skey].
      assert (OV : ovl r o ch (r', o', ch', sv) = false)
        by (apply (proj1 (filter_nil_iff _ _) F); exact IN).
      apply ovl_false in OV.
      destruct (ENT _ _ _ _ IN) as (IB' & _).
      eapply inb_disj; eauto. destruct OV as [OV | OV]; [ left; auto | right; lia ].
    + intros r' IN'. apply (cl_disj_region E m g r o ch r' MM IB L).
      intros <-. assert (C : existsb (Pos.eqb r) (g_cl g) = true)
        by (apply existsb_exists; exists r; split; [ exact IN' | apply Pos.eqb_refl ]).
      congruence.
  - destruct (exact r o ch e) eqn:X; [ | discriminate]. inv H.
    destruct e as [[[r' o'] ch'] sv]. apply exact_true in X. destruct X as (-> & -> & ->).
    assert (IN : In (r', o', ch', sv) (g_sm g))
      by (apply (filter_In (ovl r' o' ch')); rewrite F; left; auto).
    destruct (ENT _ _ _ _ IN) as (_ & S & L). cbn [snd]. auto.
  - discriminate.
Qed.

Lemma store_vp : forall ch m b o v m', Mem.store ch m b o v = Some m' ->
  forall b' o', Mem.valid_pointer m' b' o' = Mem.valid_pointer m b' o'.
Proof.
  intros ch m b o v m' S b' o'.
  destruct (Mem.valid_pointer m b' o') eqn:E1;
    destruct (Mem.valid_pointer m' b' o') eqn:E2; auto.
  - apply Mem.valid_pointer_nonempty_perm in E1.
    eapply Mem.perm_store_1 in E1; eauto.
    apply Mem.valid_pointer_nonempty_perm in E1. congruence.
  - apply Mem.valid_pointer_nonempty_perm in E2.
    eapply Mem.perm_store_2 in E2; eauto.
    apply Mem.valid_pointer_nonempty_perm in E2. congruence.
Qed.

Lemma sstore_sound : forall E m g r o ch sa v m' g',
  MMg E m g -> sstore g r o ch sa = Some g' -> sok (g_nx g) sa ->
  den E sa = Some v -> Val.load_result ch v = v ->
  Mem.store ch m (e_blk E r) (addr E r o) v = Some m' ->
  MMg E m' g' /\ g_nx g' = g_nx g /\ g_loc g' = g_loc g /\ g_pc g' = g_pc g.
Proof.
  intros E m g r o ch sa v m' g' MM SS SK D LR ST.
  unfold sstore in SS. destruct (inb g r o ch) eqn:IB; [ | discriminate ].
  destruct (forallb _ (g_sm g)) eqn:ALL; [ | discriminate ]. inv SS.
  rewrite forallb_forall in ALL.
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  cbn [g_nx g_loc g_pc g_sm]. split; [ | auto ].
  assert (NXm : Mem.nextblock m' = Mem.nextblock m) by (eapply Mem.nextblock_store; eauto).
  split; [ exact EO | split; [ exact NB | split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ] ] ].
  - (* entries *)
    intros r' o' ch' sv IN. cbn [g_sm] in IN. destruct IN as [Eq | IN].
    + inv Eq. split; [ exact IB | split; [ exact SK | ] ].
      rewrite (Mem.load_store_same _ _ _ _ _ _ ST). rewrite D, LR. reflexivity.
    + apply filter_In in IN. destruct IN as [IN NO].
      apply negb_true_iff in NO. apply ovl_false in NO.
      destruct (ENT _ _ _ _ IN) as (IB' & SK' & L). split; [ exact IB' | split; [ exact SK' | ] ].
      rewrite (Mem.load_store_other _ _ _ _ _ _ ST); [ exact L | ].
      assert (CD := inb_disj E m g r o ch r' o' ch' MM IB IB'
                      ltac:(destruct NO as [NO | NO]; [ left; auto | right; lia ])).
      cbn in CD. destruct CD as [CD | CD]; [ left; congruence | right; lia ].
  - (* frame *)
    intros b z ch' OLD NOV.
    assert (L1 : Mem.load ch' m' b z = Mem.load ch' m b z).
    { eapply Mem.load_store_other; eauto.
      specialize (NOV (r, o, ch, sa) (or_introl eq_refl)). cbn in NOV.
      destruct NOV as [NOV | NOV]; [ left; congruence | right; lia ]. }
    rewrite L1. apply FR; [ exact OLD | ].
    intros [[[re oe] che] sve] IN.
    destruct (ovl r o ch (re, oe, che, sve)) eqn:OV.
    + pose proof (ALL _ IN) as X. rewrite OV in X. cbn [negb orb] in X.
      apply exact_true in X. destruct X as (<- & <- & <-).
      exact (NOV (r, o, ch, sa) (or_introl eq_refl)).
    + apply NOV. right. apply filter_In. split; auto. rewrite OV. reflexivity.
  - intros b' o' k p OLD. rewrite <- (VP b' o' k p OLD).
    split; intro HH; [ eapply Mem.perm_store_2; eauto | eapply Mem.perm_store_1; eauto ].
  - rewrite NXm. exact NX.
  - exact PC.
  - intros r1 IN. destruct (LOC r1 IN) as (A & B & C & D' & F). rewrite NXm. auto.
  - exact LINJ.
Qed.

Lemma world_ok_spec : forall pc q k ch, world_ok pc q k ch = true ->
  exists n, In (Fworld q n) pc /\ 0 <= k /\ k + size_chunk ch <= n.
Proof.
  unfold world_ok; intros pc q k ch H. apply existsb_exists in H.
  destruct H as [f [IN H]]. destruct f; try discriminate.
  apply andb_true_iff in H as [H H3]. apply andb_true_iff in H as [H1 H2].
  unfold sbeq in H1. destruct (sval_eq p q); [ subst | discriminate ].
  apply Z.leb_le in H2. apply Z.leb_le in H3. eauto.
Qed.

Lemma wload_sound : forall E m g q k ch sa b o, MMg E m g ->
  wload g q k ch = Some sa -> den E q = Some (Vptr b o) -> sok (g_nx g) q -> dold q ->
  Mem.load ch m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr k))) = den E sa
  /\ sok (g_nx g) sa.
Proof.
  intros E m g q k ch sa b o MM H Dq Sq Oq. unfold wload in H.
  destruct (world_ok (g_pc g) q k ch) eqn:W; cbn [orb] in H.
  2:{ (* an element of a whole world block *)
    destruct (widx_ok (g_pc g) q) eqn:WI; [ | discriminate ]. inv H.
    pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
    pose proof Dq as Dq0.
    destruct q as [ | | | | | | | op p t1 i t2 | | ]; cbn [widx_ok] in WI; try discriminate.
    destruct op; try discriminate.
    assert (DS : den E (Swld (Sbinop Oadd p t1 i t2) k ch)
                 = Mem.load ch m0 b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr k)))).
    { change (den E (Swld (Sbinop Oadd p t1 i t2) k ch)) with
        (match den E (Sbinop Oadd p t1 i t2) with
         | Some (Vptr b' o') => Mem.load ch m0 b' (Ptrofs.unsigned (Ptrofs.add o' (Ptrofs.repr k)))
         | _ => None end).
      rewrite Dq0. reflexivity. }
    apply andb_true_iff in WI as [WB CA].
    unfold wblock_ok in WB. apply existsb_exists in WB. destruct WB as [f [INf Hf]].
    destruct f as [ | p0 n | | ]; try discriminate.
    apply andb_true_iff in Hf as [Hp Hn]. apply Z.leb_le in Hn.
    destruct (PC _ INf) as (_ & (bp & op & Dp & OLD & N0 & NM & DJ)).
    assert (DpB : exists o1, den E p = Some (Vptr bp o1)).
    { unfold same_blk, sbeq in Hp. destruct (sval_eq p0 p) as [<- | _]; [ eauto | ].
      cbn [orb] in Hp. destruct p0; try discriminate. destruct p; try discriminate.
      apply Pos.eqb_eq in Hp. subst. cbn [den] in Dp |- *. injection Dp as <- _. eauto. }
    destruct DpB as (o1 & Dp1).
    cbn [den] in Dq. rewrite Dp1 in Dq. destruct (den E i) as [vi|] eqn:Di; [ | discriminate ].
    cbn [sem_binary_operation] in Dq. unfold sem_add in Dq.
    destruct (classify_add t1 t2); try discriminate.
    unfold sem_add_ptr_int in Dq. destruct vi; try discriminate. injection Dq as <- <-.
    pose proof (Ptrofs.unsigned_range op) as ROP.
    assert (OP0 : Ptrofs.unsigned op = 0) by lia.
    split.
    - rewrite DS. apply FR; [ exact OLD | | ].
      + intros [[[re oe] che] sve] INe. cbn [skey cell_disj].
        destruct (ENT _ _ _ _ INe) as (IBe & _).
        destruct (inb_spec _ _ _ _ IBe) as [(L & sz & S & O1 & O2) | (L & INl & O1 & O2)].
        * pose proof (Ptrofs.unsigned_range (e_base E re)). pose proof (size_chunk_pos che).
          destruct (DJ re sz S) as [D | [D | D]]; [ left; exact D | exfalso; lia | exfalso; lia ].
        * left. intro B. destruct (LOC re INl) as (_ & _ & _ & NO & _). apply NO. rewrite B. exact OLD.
      + intros r _. unfold rng_disj. destruct (r0_size r) as [sz|] eqn:S; [ | exact I ].
        pose proof (Ptrofs.unsigned_range (e_base E r)).
        match goal with |- context [Ptrofs.unsigned ?z] =>
          match z with Ptrofs.add _ (Ptrofs.repr k) => pose proof (Ptrofs.unsigned_range z) end end.
        destruct (DJ r sz S) as [D | [D | D]]; [ left; exact D | right; left; lia | exfalso; lia ].
    - split; cbn; [ apply Sq | exact Oq ]. }
  inv H.
  destruct (world_ok_spec _ _ _ _ W) as (n & IN & K1 & K2).
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  destruct (PC _ IN) as (_ & (b' & o' & D' & OLD & N0 & NM & DJ)).
  rewrite Dq in D'. injection D' as <- <-.
  pose proof (size_chunk_pos ch). pose proof (Ptrofs.unsigned_range o).
  assert (AD : Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr k)) = Ptrofs.unsigned o + k).
  { rewrite Ptrofs.add_unsigned. rewrite (Ptrofs.unsigned_repr k)
      by (unfold Ptrofs.max_unsigned; lia).
    apply Ptrofs.unsigned_repr. unfold Ptrofs.max_unsigned; lia. }
  split.
  - cbn [den]. rewrite Dq. apply FR; [ exact OLD | | ].
    intros [[[re oe] che] sve] INe. cbn [skey cell_disj].
    destruct (ENT _ _ _ _ INe) as (IBe & _).
    destruct (inb_spec _ _ _ _ IBe) as [(L & sz & S & O1 & O2) | (L & INl & O1 & O2)].
    + destruct (DJ re sz S) as [D | [D | D]]; [ left; exact D | right | right ];
        unfold addr; rewrite AD; lia.
    + left. intro B. destruct (LOC re INl) as (_ & _ & _ & NO & _). apply NO. rewrite B. exact OLD.
    + intros r _. unfold rng_disj. destruct (r0_size r) as [sz|] eqn:S; [ | exact I ].
      destruct (DJ r sz S) as [D | [D | D]]; [ left; exact D | right; left | right; right ];
        rewrite AD; lia.
  - split; cbn; [ apply Sq | exact Oq ].
Qed.

(* ---------------------------------------------------------------- *)
(* Operators and folds                                                *)
(* ---------------------------------------------------------------- *)

Lemma vp_empty : forall b o, Mem.valid_pointer Mem.empty b o = false.
Proof.
  intros. apply not_true_iff_false. intro E.
  apply Mem.valid_pointer_nonempty_perm in E. eapply Mem.perm_empty; eauto.
Qed.

Lemma wvp_empty : forall b o, Mem.weak_valid_pointer Mem.empty b o = false.
Proof. intros. unfold Mem.weak_valid_pointer. rewrite !vp_empty. reflexivity. Qed.

Ltac empty_side :=
  intros; rewrite ?vp_empty, ?wvp_empty in *; discriminate.

Lemma inj_nonptr : forall f v, non_ptr v = true -> Val.inject f v v.
Proof. intros f v H. destruct v; try discriminate; constructor. Qed.

Lemma inj_nonptr_eq : forall f v w, non_ptr v = true -> non_undef v = true ->
  Val.inject f v w -> w = v.
Proof. intros f v w P U H. inv H; auto; discriminate. Qed.

Definition pinj (E : senv) (r : positive) : meminj :=
  fun b => if eq_block b dummy_b then Some (e_blk E r, Ptrofs.unsigned (e_base E r)) else None.

Lemma pinj_dummy : forall E r o,
  Val.inject (pinj E r) (Vptr dummy_b o) (Vptr (e_blk E r) (Ptrofs.add (e_base E r) o)).
Proof.
  intros. econstructor. unfold pinj. rewrite dec_eq_true. reflexivity.
  rewrite Ptrofs.repr_unsigned. apply Ptrofs.add_commut.
Qed.

Lemma fold_ptr_res_sound : forall E r res t w,
  fold_ptr_res r res = Some t ->
  (forall v, res = Some v -> Val.inject (pinj E r) v w) ->
  den E t = Some w /\ (exists o', t = Sptr r o').
Proof.
  intros E r res t w F H. unfold fold_ptr_res in F.
  destruct res as [[| | | | | b o']|]; try discriminate.
  destruct (eq_block b dummy_b); [ subst | discriminate ]. inv F.
  specialize (H _ eq_refl).
  inversion H as [ | | | | b1 ofs1 b2 ofs2 delta Hf Ho | ]; subst.
  unfold pinj in Hf. rewrite dec_eq_true in Hf. inv Hf.
  split; [ | eauto ]. cbn [den]. rewrite Ptrofs.repr_unsigned, Ptrofs.add_commut. reflexivity.
Qed.

Lemma fold_const_inv : forall res t, fold_const res = Some t ->
  exists v, res = Some v /\ t = Sconst v /\ non_undef v = true /\ non_ptr v = true.
Proof.
  unfold fold_const; intros res t H. destruct res as [v|]; [ | discriminate ].
  destruct (non_undef v) eqn:U; [ | discriminate ].
  destruct (non_ptr v) eqn:P; [ | discriminate ]. inv H. eauto.
Qed.

Lemma sem_and_tint : forall ce i k sz1 sg1 a1 sz2 sg2 a2 m v,
  sem_binary_operation ce Oand (Vint i) (Tint sz1 sg1 a1) (Vint k) (Tint sz2 sg2 a2) m = Some v ->
  v = Vint (Int.and i k).
Proof.
  intros ce i k sz1 sg1 a1 sz2 sg2 a2 m v H.
  unfold sem_binary_operation, sem_and, sem_binarith, sem_cast, classify_cast, binarith_type,
    classify_binarith in H.
  destruct sz1, sg1, sz2, sg2; destruct Archi.ptr64; cbn in H; inv H; reflexivity.
Qed.

Lemma known_zero_sound : forall E pc t k, known_zero pc t k = true ->
  (forall f, In f pc -> fact_holds E f) ->
  exists i, den E t = Some (Vint i) /\ Int.and i k = Int.zero.
Proof.
  unfold known_zero; intros E pc t k H PC.
  apply existsb_exists in H. destruct H as [f [Hin Hc]].
  destruct f as [ | | t' mask | ]; try discriminate. apply andb_true_iff in Hc as [Ht Hc].
  unfold sbeq in Ht. destruct (sval_eq t t'); [ subst | discriminate ].
  destruct (PC _ Hin) as [i [L M]]. cbn in M.
  exists i. split; [ exact L | ].
  apply Int.same_if_eq in Hc.
  apply Int.same_bits_eq. intros j Hj.
  rewrite Int.bits_and by exact Hj. rewrite Int.bits_zero.
  assert (A1 := f_equal (fun x => Int.testbit x j) M). cbv beta in A1.
  assert (A2 := f_equal (fun x => Int.testbit x j) Hc). cbv beta in A2.
  rewrite Int.bits_and in A1 by exact Hj. rewrite Int.bits_and in A2 by exact Hj.
  rewrite Int.bits_not in A2 by exact Hj. rewrite Int.bits_zero in A1, A2.
  destruct (Int.testbit i j), (Int.testbit k j), (Int.testbit mask j); cbn in *; congruence.
Qed.

Lemma fold_bin_inv : forall pc op a1 t1 a2 t2 t, fold_bin pc op a1 t1 a2 t2 = Some t ->
  (exists c1 c2, a1 = Sconst c1 /\ a2 = Sconst c2
     /\ fold_const (sem_binary_operation ge op c1 t1 c2 t2 Mem.empty) = Some t)
  \/ (exists r o c2, a1 = Sptr r o /\ a2 = Sconst c2 /\ non_ptr c2 = true
     /\ fold_ptr_res r (sem_binary_operation ge op (Vptr dummy_b o) t1 c2 t2 Mem.empty) = Some t)
  \/ (exists c1 r o, a1 = Sconst c1 /\ a2 = Sptr r o /\ non_ptr c1 = true
     /\ fold_ptr_res r (sem_binary_operation ge op c1 t1 (Vptr dummy_b o) t2 Mem.empty) = Some t)
  \/ (exists k, a2 = Sconst (Vint k) /\ op = Oand /\ is_tint t1 = true /\ is_tint t2 = true
     /\ known_zero pc a1 k = true /\ t = Sconst (Vint Int.zero))
  \/ (exists r o1 o2, a1 = Sptr r o1 /\ a2 = Sptr r o2 /\ is_tptr t1 = true /\ is_tptr t2 = true
     /\ ((op = Oeq /\ t = Sconst (Val.of_bool (Ptrofs.eq o1 o2)))
         \/ (op = One /\ t = Sconst (Val.of_bool (negb (Ptrofs.eq o1 o2)))))).
Proof.
  intros pc op a1 t1 a2 t2 t H. unfold fold_bin in H.
  destruct a1; destruct a2; cbv beta iota in H; try discriminate H.
  all: try (left; eauto 6; fail).
  all: try (destruct (non_ptr _) eqn:N; [ | discriminate H ]; right; left; eauto 7; fail).
  all: try (destruct (non_ptr _) eqn:N; [ | discriminate H ]; right; right; left; eauto 7; fail).
  all: try (match type of H with context [Pos.eqb ?x ?y] => destruct (Pos.eqb_spec x y) as [<- | _] end;
            destruct (is_tptr t1) eqn:T1; destruct (is_tptr t2) eqn:T2; cbn in H; try discriminate H;
            destruct op; try discriminate H; inv H; right; right; right; right; eauto 12; fail).
  all: destruct v; try discriminate H; destruct op; try discriminate H;
       destruct (is_tint t1) eqn:T1; destruct (is_tint t2) eqn:T2;
       destruct (known_zero _ _ _) eqn:K; cbn in H; try discriminate H; inv H;
       right; right; right; left; eauto 10.
Qed.

Section PPSAME.
Local Transparent Archi.ptr64.
Lemma sem_cmp_pp_same : forall ce op b x y p1 a1 p2 a2 m v, (op = Oeq \/ op = One) ->
  sem_binary_operation ce op (Vptr b x) (Tpointer p1 a1) (Vptr b y) (Tpointer p2 a2) m = Some v ->
  v = Val.of_bool (match op with Oeq => Ptrofs.eq x y | _ => negb (Ptrofs.eq x y) end).
Proof.
  intros ce op b x y p1 a1 p2 a2 m v Hop H.
  destruct Hop as [-> | ->]; cbn in H; unfold cmp_ptr, Val.cmpu_bool, option_map in H;
    cbn in H.
  all: repeat match type of H with
    | context [if ?c then _ else _] => let Ec := fresh "Ec" in destruct c eqn:Ec; cbn in H;
        try discriminate H; try (exfalso; congruence)
    end.
  all: inv H; reflexivity.
Qed.
End PPSAME.

Lemma sok_dold : forall n a, sok n a -> loc_ptr a = false -> dold a.
Proof.
  intros n a [_ S] L. destruct a; auto. cbn in *. unfold is_local in L.
  apply negb_false_iff in L. apply Pos.ltb_lt. exact L.
Qed.

Lemma sok_const : forall n v, non_ptr v = true -> sok n (Sconst v).
Proof. intros. split; cbn; auto. Qed.

Lemma sok_const_np : forall n v, sok n (Sconst v) -> non_ptr v = true.
Proof. intros n v [_ S]. exact S. Qed.

Section OPS.
Variables (E : senv) (m : mem) (g : gst).
Hypothesis MM : MMg E m g.
Local Notation n := (g_nx g).

Lemma MM_vpo : vpo m m0.
Proof. destruct MM as (_ & _ & _ & _ & VP & _). apply vp_old_vpo. exact VP. Qed.

Lemma MM_env : env_ok E.
Proof. destruct MM as (EO & _). exact EO. Qed.

Lemma MM_pc : forall f, In f (g_pc g) -> fact_holds E f.
Proof. destruct MM as (_ & _ & _ & _ & _ & _ & PC & _). intros f IN. apply PC. exact IN. Qed.

Lemma mk_bin_sound : forall op a1 t1 a2 t2 v1 v2 v t,
  den E a1 = Some v1 -> sok n a1 -> den E a2 = Some v2 -> sok n a2 ->
  sem_binary_operation ge op v1 t1 v2 t2 m = Some v ->
  mk_bin (g_pc g) op a1 t1 a2 t2 = Some t ->
  den E t = Some v /\ sok n t.
Proof.
  intros op a1 t1 a2 t2 v1 v2 v t D1 S1 D2 S2 H MK. unfold mk_bin in MK.
  destruct (fold_bin (g_pc g) op a1 t1 a2 t2) as [t'|] eqn:F.
  - inv MK. apply fold_bin_inv in F.
    destruct F as [(c1 & c2 & -> & -> & F) | [(r & o & c2 & -> & -> & NP & F)
                  | [(c1 & r & o & -> & -> & NP & F) | [(k & -> & -> & T1 & T2 & K & ->)
                  | (r & o1 & o2 & -> & -> & T1 & T2 & Hop)]]]].
    + apply fold_const_inv in F. destruct F as (w & Hw & -> & U & P).
      cbn [den] in D1, D2. inv D1. inv D2.
      destruct (sem_binary_operation_inj (fun _ => None) Mem.empty m ltac:(empty_side)
                  ltac:(empty_side) ltac:(empty_side) ltac:(empty_side) ge op v1 t1 v2 t2 w v1 v2 Hw
                  (inj_nonptr _ _ (sok_const_np _ _ S1)) (inj_nonptr _ _ (sok_const_np _ _ S2)))
        as [w' [Hw' Iw]].
      rewrite H in Hw'. inv Hw'. apply inj_nonptr_eq in Iw; auto. subst.
      split; [ reflexivity | apply sok_const; auto ].
    + cbn [den] in D1, D2. inv D1. inv D2.
      destruct (fold_ptr_res_sound E r _ _ v F) as [D Hs].
      { intros w Hw.
        destruct (sem_binary_operation_inj (pinj E r) Mem.empty m ltac:(empty_side)
                    ltac:(empty_side) ltac:(empty_side) ltac:(empty_side) ge op _ t1 v2 t2 w _ v2 Hw
                    (pinj_dummy E r o) (inj_nonptr _ _ NP)) as [w' [Hw' Iw]].
        rewrite H in Hw'. inv Hw'. exact Iw. }
      split; [ exact D | ]. destruct Hs as [o' ->]. split; cbn; auto. apply S1.
    + cbn [den] in D1, D2. inv D1. inv D2.
      destruct (fold_ptr_res_sound E r _ _ v F) as [D Hs].
      { intros w Hw.
        destruct (sem_binary_operation_inj (pinj E r) Mem.empty m ltac:(empty_side)
                    ltac:(empty_side) ltac:(empty_side) ltac:(empty_side) ge op v1 t1 _ t2 w v1 _ Hw
                    (inj_nonptr _ _ NP) (pinj_dummy E r o)) as [w' [Hw' Iw]].
        rewrite H in Hw'. inv Hw'. exact Iw. }
      split; [ exact D | ]. destruct Hs as [o' ->]. split; cbn; auto. apply S2.
    + destruct t1; try discriminate. destruct t2; try discriminate.
      destruct (known_zero_sound E _ _ _ K MM_pc) as (ix & Di & Ai).
      rewrite Di in D1. inv D1. cbn [den] in D2. inv D2.
      apply sem_and_tint in H. subst v. rewrite Ai.
      split; [ reflexivity | apply sok_const; reflexivity ].
    + (* two addresses in one region *)
      cbn [den] in D1, D2. inv D1. inv D2.
      destruct t1; try discriminate T1. destruct t2; try discriminate T2.
      assert (Q : Ptrofs.eq (Ptrofs.add (e_base E r) o1) (Ptrofs.add (e_base E r) o2) = Ptrofs.eq o1 o2).
      { rewrite (Ptrofs.add_commut _ o1), (Ptrofs.add_commut _ o2). apply Ptrofs.translate_eq. }
      destruct Hop as [(-> & ->) | (-> & ->)];
        apply sem_cmp_pp_same in H; try (left; reflexivity); try (right; reflexivity);
        subst v; rewrite Q; (split; [ reflexivity | apply sok_const ]);
        first [ destruct (Ptrofs.eq o1 o2); reflexivity ].
  - destruct (loc_ptr a1) eqn:L1; [ discriminate | ].
    destruct (loc_ptr a2) eqn:L2; [ discriminate | ]. inv MK.
    pose proof (sok_old E n a1 v1 MM_env S1 L1 D1) as O1.
    pose proof (sok_old E n a2 v2 MM_env S2 L2 D2) as O2.
    destruct (bin_old m m0 op v1 t1 v2 t2 v MM_vpo O1 O2 H) as [H0 _].
    split; [ cbn [den]; rewrite D1, D2; exact H0 | ].
    split; [ split; [ apply S1 | apply S2 ] | ].
    cbn. split; eapply sok_dold; eauto.
Qed.

Lemma mk_un_sound : forall op a ty v1 v t,
  den E a = Some v1 -> sok n a ->
  sem_unary_operation op v1 ty m = Some v ->
  mk_un op a ty = Some t -> den E t = Some v /\ sok n t.
Proof.
  intros op a ty v1 v t D S H MK.
  assert (GEN : loc_ptr a = false -> t = Sunop op a ty -> den E t = Some v /\ sok n t).
  { intros L ->. pose proof (sok_old E n a v1 MM_env S L D) as O.
    destruct (un_old m m0 op v1 ty v MM_vpo O H) as [H0 _].
    split; [ cbn [den]; rewrite D; exact H0 | ].
    split; [ apply S | cbn; eapply sok_dold; eauto ]. }
  unfold mk_un in MK.
  destruct a; try (cbv beta iota in MK; destruct (loc_ptr _) eqn:L;
                   [ discriminate | inv MK; apply GEN; auto ]; fail).
  cbn [den] in D. inv D.
  destruct (fold_const (sem_unary_operation op v1 ty Mem.empty)) as [t'|] eqn:F.
  - inv MK. apply fold_const_inv in F. destruct F as (w & Hw & -> & U & P).
    destruct (sem_unary_operation_inj (fun _ => None) Mem.empty m ltac:(empty_side) op v1 ty w v1 Hw
                (inj_nonptr _ _ (sok_const_np _ _ S))) as [w' [Hw' Iw]].
    rewrite H in Hw'. inv Hw'. apply inj_nonptr_eq in Iw; auto. subst.
    split; [ reflexivity | apply sok_const; auto ].
  - inv MK. apply GEN; reflexivity.
Qed.

Lemma cast_id_sound : forall t1 t2 v v' m', cast_id t1 t2 = true ->
  sem_cast v t1 t2 m' = Some v' -> v' = v.
Proof.
  intros t1 t2 v v' m' H C. unfold cast_id in H. unfold sem_cast in C.
  destruct (classify_cast t1 t2); try discriminate H.
  - destruct v; cbn in C; try discriminate C; inv C; reflexivity.
  - destruct sz2; try discriminate H. destruct v; try discriminate C. inv C.
    destruct si2; reflexivity.
  - destruct v; try discriminate C; inv C; reflexivity.
  - destruct v; try discriminate C; inv C; reflexivity.
  - destruct v; try discriminate C; inv C; reflexivity.
  - destruct v; try discriminate C. destruct (ident_eq _ _); inv C; reflexivity.
  - destruct v; try discriminate C. destruct (ident_eq _ _); inv C; reflexivity.
  - inv C. reflexivity.
Qed.

Lemma mk_cast_sound : forall a t1 t2 v1 v t,
  den E a = Some v1 -> sok n a ->
  sem_cast v1 t1 t2 m = Some v ->
  mk_cast a t1 t2 = Some t -> den E t = Some v /\ sok n t.
Proof.
  intros a t1 t2 v1 v t D S H MK.
  assert (GEN : loc_ptr a = false -> t = Scast a t1 t2 -> den E t = Some v /\ sok n t).
  { intros L ->. pose proof (sok_old E n a v1 MM_env S L D) as O.
    destruct (cast_old m m0 v1 t1 t2 v MM_vpo O H) as [H0 _].
    split; [ cbn [den]; rewrite D; exact H0 | ].
    split; [ apply S | cbn; eapply sok_dold; eauto ]. }
  unfold mk_cast in MK. destruct (cast_id t1 t2) eqn:CI.
  { inv MK. rewrite (cast_id_sound _ _ _ _ _ CI H). auto. }
  destruct a; try (cbv beta iota in MK; inv MK; apply GEN; reflexivity).
  - cbn [den] in D. inv D.
    destruct (fold_const (sem_cast v1 t1 t2 Mem.empty)) as [t'|] eqn:F.
    + inv MK. apply fold_const_inv in F. destruct F as (w & Hw & -> & U & P).
      destruct (sem_cast_inj (fun _ => None) Mem.empty m ltac:(empty_side) v1 t1 t2 w v1 Hw
                  (inj_nonptr _ _ (sok_const_np _ _ S))) as [w' [Hw' Iw]].
      rewrite H in Hw'. inv Hw'. apply inj_nonptr_eq in Iw; auto. subst.
      split; [ reflexivity | apply sok_const; auto ].
    + inv MK. apply GEN; reflexivity.
  - cbn [den] in D. inv D.
    destruct (fold_ptr_res r (sem_cast (Vptr dummy_b ofs) t1 t2 Mem.empty)) as [t'|] eqn:F.
    + inv MK.
      destruct (fold_ptr_res_sound E r _ t v F) as [D Hs].
      { intros w Hw.
        destruct (sem_cast_inj (pinj E r) Mem.empty m ltac:(empty_side) _ t1 t2 w _ Hw
                    (pinj_dummy E r ofs)) as [w' [Hw' Iw]].
        rewrite H in Hw'. inv Hw'. exact Iw. }
      split; [ exact D | ]. destruct Hs as [o' ->]. split; cbn; auto. apply S.
    + destruct (is_local r) eqn:L; [ discriminate | ]. inv MK. apply GEN; [ | reflexivity ].
      cbn. exact L.
Qed.

Lemma decide_sound : forall c ty v b b', den E c = Some v -> sok n c ->
  bool_val v ty m = Some b -> decide (g_pc g) c ty = Some b' -> b' = b.
Proof.
  intros c ty v b b' D S B H. unfold decide in H.
  assert (L : forall pc, (forall f, In f pc -> fact_holds E f) ->
                pc_lookup pc c ty = Some b' -> b' = b).
  { induction pc as [|f pc' IH]; intros P Hl; cbn [pc_lookup] in Hl; [ discriminate | ].
    destruct f; try (apply IH; [ intros; apply P; right; auto | exact Hl ]).
    destruct (sbeq c0 c && (if type_eq ty0 ty then true else false)) eqn:Q;
      [ | apply IH; [ intros; apply P; right; auto | exact Hl ] ].
    inv Hl. apply andb_true_iff in Q as [Q1 Q2]. unfold sbeq in Q1.
    destruct (sval_eq c0 c); [ subst | discriminate ].
    destruct (type_eq ty0 ty); [ subst | discriminate ].
    destruct (P _ (or_introl eq_refl)) as [v' [D' B']]. rewrite D in D'. inv D'.
    pose proof (bool_val_m0_transfer m v' ty b' (vpo_sym _ _ MM_vpo) B') as B2.
    congruence. }
  destruct c; try (apply (L _ MM_pc H)).
  cbn [den] in D. inv D.
  pose proof (bool_val_inj (fun _ => None) Mem.empty m ltac:(empty_side) v ty b' v H
                (inj_nonptr _ _ (sok_const_np _ _ S))).
  congruence.
Qed.

(* the fact a split adds holds *)
Lemma split_fact_sound : forall c ty v b, den E c = Some v -> sok n c -> loc_ptr c = false ->
  bool_val v ty m = Some b -> fact_nlt n (Fbool c ty b) /\ fact_holds E (Fbool c ty b).
Proof.
  intros c ty v b D S L B. split; [ apply S | ].
  exists v. split; [ exact D | ].
  eapply bool_old; [ exact MM_vpo | | exact B ]. eapply sok_old; eauto. exact MM_env.
Qed.

End OPS.

(* ---------------------------------------------------------------- *)
(* Locations and expressions                                          *)
(* ---------------------------------------------------------------- *)

Definition loc_den (E : senv) (l : sloc) : option (block * ptrofs) :=
  match l with
  | Lreg r o => Some (e_blk E r, Ptrofs.add (e_base E r) o)
  | Lwld q k =>
      match den E q with
      | Some (Vptr b o) => Some (b, Ptrofs.add o (Ptrofs.repr k))
      | _ => None
      end
  end.

Definition loc_ok (n : positive) (l : sloc) : Prop :=
  match l with Lreg r _ => Plt r n | Lwld q _ => nlt n q /\ dold q end.

Definition env_match (E : senv) (gl : list positive) (se : PTree.t (positive * type)) (e : env) : Prop :=
  forall id, match se ! id, e ! id with
             | Some (r, ty), Some (b, ty') => b = e_blk E r /\ ty = ty' /\ In r gl
             | None, None => True
             | _, _ => False
             end.

Definition temps_ok (E : senv) (n : positive) (tle : temp_env) (le : PTree.t sval) : Prop :=
  forall id a, le ! id = Some a -> exists v, tle ! id = Some v /\ den E a = Some v /\ sok n a.

Lemma nullx_sound : forall E n e tle le m, temps_ok E n tle le ->
  forall a, nullx le a = true ->
  (forall v, ~ eval_expr ge e tle m a v) /\ (forall b o bf, ~ eval_lvalue ge e tle m a b o bf).
Proof.
  intros E n e tle le m TM a.
  induction a as [ | | | | | id ty | a1 IH1 ty | a1 IH1 ty | op a1 IH1 ty | op a1 IH1 a2 IH2 ty
                 | a1 IH1 ty | a1 IH1 i ty | ty0 ty | ty0 ty ]; intros H; cbn [nullx] in H;
    try discriminate.
  - (* Ederef *)
    assert (NL : forall b o bf, ~ eval_lvalue ge e tle m (Ederef a1 ty) b o bf).
    { intros b o bf HL. inversion HL; subst.
      destruct a1; cbn [nullx] in H;
        try (apply (proj1 (IH1 H) _ H5)).
      destruct (le ! i) as [sv|] eqn:L; [| discriminate].
      destruct sv; try discriminate. destruct v; try discriminate.
      destruct (TM i _ L) as (v & Tv & Dv & _). cbn [den] in Dv. injection Dv as <-.
      inversion H5; subst; [congruence | inversion H0]. }
    split; [| exact NL].
    intros v HE. inversion HE; subst.
    (eapply NL; eassumption).
  - (* Eaddrof *)
    split; [intros v HE; inversion HE; subst;
            first [ solve [eapply (proj2 (IH1 H)); eassumption]
                  | match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inversion HL] end ]
           | intros b o bf HL; inversion HL].
  - (* Eunop *)
    split; [intros v HE; inversion HE; subst;
            first [ solve [eapply (proj1 (IH1 H)); eassumption]
                  | match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inversion HL] end ]
           | intros b o bf HL; inversion HL].
  - (* Ebinop *)
    apply orb_true_iff in H.
    split; [intros v HE; inversion HE; subst;
            first [ destruct H as [H | H];
                    [ (eapply (proj1 (IH1 H)); eassumption)
                    | (eapply (proj1 (IH2 H)); eassumption) ]
                  | match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inversion HL] end ]
           | intros b o bf HL; inversion HL].
  - (* Ecast *)
    split; [intros v HE; inversion HE; subst;
            first [ solve [eapply (proj1 (IH1 H)); eassumption]
                  | match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inversion HL] end ]
           | intros b o bf HL; inversion HL].
  - (* Efield *)
    assert (NL : forall b o bf, ~ eval_lvalue ge e tle m (Efield a1 i ty) b o bf).
    { intros b o bf HL. inversion HL; subst;
        (eapply (proj1 (IH1 H)); eassumption). }
    split; [| exact NL].
    intros v HE. inversion HE; subst.
    (eapply NL; eassumption).
Qed.

Lemma ptrofs_add_repr : forall o x y,
  Ptrofs.add (Ptrofs.add o (Ptrofs.repr x)) (Ptrofs.repr y) = Ptrofs.add o (Ptrofs.repr (x + y)).
Proof.
  intros. rewrite Ptrofs.add_assoc. f_equal. rewrite Ptrofs.add_unsigned.
  apply Ptrofs.eqm_samerepr. apply Ptrofs.eqm_add; apply Ptrofs.eqm_sym; apply Ptrofs.eqm_unsigned_repr.
Qed.

Lemma addr_of_sound : forall E n l b o, loc_den E l = Some (b, o) -> loc_ok n l ->
  den E (addr_of l) = Some (Vptr b o) /\ sok n (addr_of l).
Proof.
  intros E n [r o' | q k] b o D K; cbn in D, K |- *.
  - inv D. split; [ reflexivity | split; cbn; auto ].
  - destruct (den E q) as [[]|] eqn:Dq; try discriminate. inv D. destruct K as [K1 K2].
    destruct (Z.eqb_spec k 0).
    + subst. rewrite Ptrofs.add_zero. split; [ exact Dq | split; [ exact K1 | ] ].
      destruct q; auto.
    + cbn. rewrite Dq. split; [ reflexivity | split; cbn; auto ].
Qed.

Lemma loc_of_sound : forall E n p b o, den E p = Some (Vptr b o) -> sok n p ->
  loc_den E (loc_of p) = Some (b, o) /\ loc_ok n (loc_of p).
Proof.
  intros E n p b o D [S1 S2]. destruct p; cbn in D |- *;
    try (rewrite D, Ptrofs.add_zero; split; [ reflexivity | split; auto ]; fail).
  - inv D. discriminate S2.
  - inv D. split; [ reflexivity | exact S1 ].
  - destruct (den E p) as [[]|] eqn:Dp; try discriminate. inv D. cbn in S1, S2. auto.
Qed.

Lemma loc_add_sound : forall E n l d b o, loc_den E l = Some (b, o) -> loc_ok n l ->
  loc_den E (loc_add l d) = Some (b, Ptrofs.add o (Ptrofs.repr d)) /\ loc_ok n (loc_add l d).
Proof.
  intros E n [r o' | q k] d b o D K; cbn in D, K |- *.
  - inv D. rewrite Ptrofs.add_assoc. auto.
  - destruct (den E q) as [[]|] eqn:Dq; try discriminate. inv D.
    rewrite ptrofs_add_repr. auto.
Qed.

Lemma sfield_struct : forall tya i l l' id att co delta bf,
  sfield_loc tya i l = Some l' -> tya = Tstruct id att -> (genv_cenv ge) ! id = Some co ->
  field_offset ge i (co_members co) = OK (delta, bf) -> l' = loc_add l delta /\ bf = Full.
Proof.
  intros tya i l l' id att co delta bf S -> C F. cbn in S. rewrite C, F in S.
  destruct bf; [ inv S; auto | discriminate ].
Qed.

Lemma sfield_union : forall tya i l l' id att co delta bf,
  sfield_loc tya i l = Some l' -> tya = Tunion id att -> (genv_cenv ge) ! id = Some co ->
  union_field_offset ge i (co_members co) = OK (delta, bf) -> l' = loc_add l delta /\ bf = Full.
Proof.
  intros tya i l l' id att co delta bf S -> C F. cbn in S. rewrite C, F in S.
  destruct bf; [ inv S; auto | discriminate ].
Qed.

Lemma sderef_sound : forall E m g ty l b o v sa, MMg E m g ->
  loc_den E l = Some (b, o) -> loc_ok (g_nx g) l ->
  sderef ty g l = Some sa -> deref_loc ty m b o Full v ->
  den E sa = Some v /\ sok (g_nx g) sa.
Proof.
  intros E m g ty l b o v sa MM D K H DL. unfold sderef in H.
  inversion DL as [ch v' AM LD | AM | AM | ]; subst; rewrite AM in H.
  - destruct l as [r o' | q k]; cbn in D.
    + inv D. destruct (sload g r (Ptrofs.unsigned o') ch) as [sv|] eqn:SL.
      * inv H. assert (IB : inb g r (Ptrofs.unsigned o') ch = true)
          by (unfold sload in SL; destruct (inb _ _ _ _); [ reflexivity | discriminate ]).
        destruct (sload_sound _ _ _ _ _ _ _ MM SL) as [L S]. split; [ | exact S ].
        cbn in LD. rewrite (addr_ptrofs _ _ _ _ _ _ MM IB) in LD. congruence.
      * destruct (Pos.ltb r nbase) eqn:Lb; [ | discriminate H ].
        apply Pos.ltb_lt in Lb.
        destruct (wload_sound E m g (Sptr r o') 0 ch sa (e_blk E r) (Ptrofs.add (e_base E r) o')
                    MM H eq_refl (conj K I) Lb) as [L S].
        split; [ | exact S ]. rewrite Ptrofs.add_zero in L. cbn in LD. congruence.
    + destruct (den E q) as [[]|] eqn:Dq; try discriminate. inv D. destruct K as [K1 K2].
      assert (Sq : sok (g_nx g) q) by (split; [ exact K1 | destruct q; auto ]).
      destruct (wload_sound _ _ _ _ _ _ _ _ _ MM H Dq Sq K2) as [L S].
      split; [ | exact S ]. cbn in LD. congruence.
  - inv H. eapply addr_of_sound; eauto.
  - inv H. eapply addr_of_sound; eauto.
Qed.

Section EXPR.
Variables (E : senv) (m : mem) (g : gst) (se : PTree.t (positive * type)) (le : PTree.t sval)
  (e : env) (tle : temp_env).
Hypothesis MM : MMg E m g.
Hypothesis EM : env_match E (g_loc g) se e.
Hypothesis TM : temps_ok E (g_nx g) tle le.

Lemma sx_expr_lvalue_sound :
  (forall a v, eval_expr ge e tle m a v ->
     forall t, sx_expr se le g a = Some t -> den E t = Some v /\ sok (g_nx g) t)
  /\ (forall a b o bf, eval_lvalue ge e tle m a b o bf ->
     forall l, sx_lvalue se le g a = Some l ->
       loc_den E l = Some (b, o) /\ loc_ok (g_nx g) l /\ bf = Full).
Proof.
  apply (eval_expr_lvalue_ind ge e tle m
           (fun a v => forall t, sx_expr se le g a = Some t -> den E t = Some v /\ sok (g_nx g) t)
           (fun a b o bf => forall l, sx_lvalue se le g a = Some l ->
              loc_den E l = Some (b, o) /\ loc_ok (g_nx g) l /\ bf = Full));
    intros; cbv beta in *; simpl sx_expr in *; simpl sx_lvalue in *.
  - inv H. split; [ reflexivity | apply sok_const; reflexivity ].
  - inv H. split; [ reflexivity | apply sok_const; reflexivity ].
  - inv H. split; [ reflexivity | apply sok_const; reflexivity ].
  - inv H. split; [ reflexivity | apply sok_const; reflexivity ].
  - (* Etempvar *) destruct (TM _ _ H0) as (v' & T & D & S). rewrite H in T. inv T. auto.
  - (* Eaddrof *)
    destruct (sx_lvalue se le g a) as [l|] eqn:El; [ | discriminate]. inv H1.
    destruct (H0 l eq_refl) as (D & K & _). eapply addr_of_sound; eauto.
  - (* Eunop *)
    destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate].
    destruct (H0 s1 eq_refl) as [D S]. exact (mk_un_sound E m g MM _ _ _ _ _ _ D S H1 H2).
  - (* Ebinop *)
    destruct (sx_expr se le g a1) as [s1|] eqn:E1; [ | discriminate].
    destruct (sx_expr se le g a2) as [s2|] eqn:E2; [ | discriminate].
    destruct (H0 s1 eq_refl) as [D1 S1]. destruct (H2 s2 eq_refl) as [D2 S2].
    exact (mk_bin_sound E m g MM _ _ _ _ _ _ _ _ _ D1 S1 D2 S2 H3 H4).
  - (* Ecast *)
    destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate].
    destruct (H0 s1 eq_refl) as [D S]. exact (mk_cast_sound E m g MM _ _ _ _ _ _ D S H1 H2).
  - inv H. split; [ reflexivity | apply sok_const; unfold Vptrofs; destruct Archi.ptr64; reflexivity ].
  - inv H. split; [ reflexivity | apply sok_const; unfold Vptrofs; destruct Archi.ptr64; reflexivity ].
  - (* Elvalue *)
    destruct a; try discriminate; try (inv H; fail);
      simpl sx_expr in *; simpl sx_lvalue in *; simpl typeof in *.
    + (* Evar *)
      destruct (svar_loc se _ _) as [l|] eqn:El; [ | discriminate ].
      destruct (H0 l eq_refl) as (D & K & ->). eapply sderef_sound; eauto.
    + (* Ederef *)
      simpl sx_lvalue in H0.
      destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate].
      destruct (H0 _ eq_refl) as (D & K & ->). eapply sderef_sound; eauto.
    + (* Efield *)
      simpl sx_lvalue in H0.
      destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate].
      destruct (sfield_loc (typeof a) i (loc_of s1)) as [l|] eqn:F; [ | discriminate].
      destruct (H0 _ eq_refl) as (D & K & ->). eapply sderef_sound; eauto.
  - (* Evar local *)
    unfold svar_loc in H0. specialize (EM id). rewrite H in EM.
    destruct (se ! id) as [[r ty0]|]; [ | contradiction ]. destruct EM as (-> & <- & IN).
    destruct (type_eq ty0 ty0); [ | contradiction ]. inv H0.
    destruct MM as (_ & _ & _ & _ & _ & _ & _ & LOC & _).
    destruct (LOC r IN) as (_ & P & B & _). cbn. rewrite B, Ptrofs.add_zero. auto.
  - (* Evar global *)
    unfold svar_loc in H1. specialize (EM id). rewrite H in EM.
    destruct (se ! id) as [[r ty0]|]; [ contradiction | ].
    destruct (gfind id) as [r|] eqn:G; [ | discriminate ]. inv H1.
    destruct MM as ((_ & _ & _ & A4 & _) & NB & _).
    destruct (A4 id r G) as (P & B & F). rewrite F in H0. inv H0.
    cbn. rewrite B, Ptrofs.add_zero. split; [ reflexivity | split; [ | reflexivity ] ].
    unfold Plt, Ple in *. lia.
  - (* Ederef *)
    destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate]. inv H1.
    destruct (H0 _ eq_refl) as [D S]. destruct (loc_of_sound _ _ _ _ _ D S) as [D' K]. auto.
  - (* Efield struct *)
    destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate].
    destruct (H0 _ eq_refl) as [D S]. destruct (loc_of_sound _ _ _ _ _ D S) as [D' K].
    destruct (sfield_struct _ _ _ _ _ _ _ _ _ H4 H1 H2 H3) as [-> ->].
    destruct (loc_add_sound _ _ _ delta _ _ D' K). auto.
  - (* Efield union *)
    destruct (sx_expr se le g a) as [s1|] eqn:Ea; [ | discriminate].
    destruct (H0 _ eq_refl) as [D S]. destruct (loc_of_sound _ _ _ _ _ D S) as [D' K].
    destruct (sfield_union _ _ _ _ _ _ _ _ _ H4 H1 H2 H3) as [-> ->].
    destruct (loc_add_sound _ _ _ delta _ _ D' K). auto.
Qed.

Lemma sx_expr_sound : forall a v t, eval_expr ge e tle m a v ->
  sx_expr se le g a = Some t -> den E t = Some v /\ sok (g_nx g) t.
Proof. intros. eapply (proj1 sx_expr_lvalue_sound); eauto. Qed.

Lemma sx_lvalue_sound : forall a b o bf l, eval_lvalue ge e tle m a b o bf ->
  sx_lvalue se le g a = Some l -> loc_den E l = Some (b, o) /\ loc_ok (g_nx g) l /\ bf = Full.
Proof. intros. eapply (proj2 sx_expr_lvalue_sound); eauto. Qed.

Lemma sx_exprlist_sound : forall al tyl vl sl,
  eval_exprlist ge e tle m al tyl vl -> sx_exprlist se le g al tyl = Some sl ->
  Forall2 (fun a v => den E a = Some v /\ sok (g_nx g) a) sl vl.
Proof.
  intros al tyl vl sl H. revert sl.
  induction H as [| a bl ty tyl v1 v2 vl Ha Hc Hl IH]; intros sl Es; cbn [sx_exprlist] in Es.
  - inv Es. constructor.
  - destruct (sx_expr se le g a) as [s1|] eqn:E1; [ | discriminate].
    destruct (mk_cast s1 (typeof a) ty) as [c|] eqn:Ec; [ | discriminate].
    destruct (sx_exprlist se le g bl tyl) as [sl'|] eqn:E2; [ | discriminate]. inv Es.
    destruct (sx_expr_sound _ _ _ Ha E1) as [D S].
    constructor; [ eapply mk_cast_sound; eauto | apply IH; reflexivity ].
Qed.

End EXPR.

(* ---------------------------------------------------------------- *)
(* Path matches                                                       *)
(* ---------------------------------------------------------------- *)

Definition out_match (E : senv) (n : positive) (out : outcome) (so : sout) : Prop :=
  match out, so with
  | Out_normal, SOnormal => True
  | Out_break, SObreak => True
  | Out_continue, SOcontinue => True
  | Out_return None, SOreturn None => True
  | Out_return (Some (v, ty)), SOreturn (Some (t, ty')) => ty' = ty /\ den E t = Some v /\ sok n t
  | _, _ => False
  end.

(* a symbolic path describes a concrete statement outcome *)
Definition PM (E0 : senv) (n0 : positive) (gl : list positive)
    (tle : temp_env) (m : mem) (out : outcome) (p : spath) : Prop :=
  let '(le, g, so) := p in
  exists E, Ext E0 E n0 /\ MMg E m g /\ temps_ok E (g_nx g) tle le
            /\ out_match E (g_nx g) out so /\ Ple n0 (g_nx g) /\ g_loc g = gl.

(* a symbolic call path describes a concrete call result *)
Definition CM (E0 : senv) (n0 : positive) (gl : list positive) (m : mem) (v : val)
    (c : cpath) : Prop :=
  let '(g, r) := c in
  exists E, Ext E0 E n0 /\ MMg E m g /\ den E r = Some v /\ sok (g_nx g) r
            /\ Ple n0 (g_nx g) /\ g_loc g = gl.

(* environments that differ only in fresh values at or above n *)
Definition Rx (E E' : senv) (n : positive) : Prop :=
  e_blk E' = e_blk E /\ e_base E' = e_base E /\ (forall k, Plt k n -> e_rho E' k = e_rho E k).

Lemma Rx_refl : forall E n, Rx E E n.
Proof. intros. split; [ | split ]; auto. Qed.

Lemma Rx_Ext : forall E E' n, Rx E E' n -> Ext E E' n.
Proof. intros E E' n (A & B & C) k K. rewrite A, B, C; auto. Qed.

Lemma Rx_trans : forall E1 E2 E3 n n', Rx E1 E2 n -> Rx E2 E3 n' -> Ple n n' -> Rx E1 E3 n.
Proof.
  intros E1 E2 E3 n n' (A1 & B1 & C1) (A2 & B2 & C2) L.
  split; [ congruence | split; [ congruence | ] ].
  intros k K. rewrite C2 by (unfold Plt, Ple in *; lia). auto.
Qed.

Lemma Rx_mono : forall E E' n n', Rx E E' n' -> Ple n n' -> Rx E E' n.
Proof.
  intros E E' n n' (A & B & C) L. split; [ auto | split; [ auto | ] ].
  intros k K. apply C. unfold Plt, Ple in *; lia.
Qed.

Lemma den_Rx : forall E E' n a, Rx E E' n -> nlt n a -> den E' a = den E a.
Proof. intros. eapply den_ext; eauto. apply Rx_Ext; auto. Qed.

Definition upd (E : senv) (k : positive) (v : option val) : senv :=
  mke (e_blk E) (e_base E) (fun j => if Pos.eq_dec j k then v else e_rho E j).

Lemma Rx_upd : forall E k v, Rx E (upd E k v) k.
Proof.
  intros. split; [ reflexivity | split; [ reflexivity | ] ].
  intros j J. cbn. destruct (Pos.eq_dec j k); [ subst; exfalso; eapply Plt_strict; eauto | auto ].
Qed.

Lemma env_ok_Rx : forall E E' n, env_ok E -> Rx E E' n -> Ple nbase n ->
  (forall k v, e_rho E' k = Some v -> val_old v) -> env_ok E'.
Proof.
  intros E E' n EO R L RO. eapply env_ok_ext; eauto. apply Rx_Ext. eapply Rx_mono; eauto.
Qed.

Lemma addr_Rx : forall E E' n r o, Rx E E' n -> addr E' r o = addr E r o.
Proof. intros E E' n r o (A & B & _). unfold addr. rewrite B. auto. Qed.

Lemma cell_disj_Rx : forall E E' n k b z ch, Rx E E' n -> cell_disj E' k b z ch = cell_disj E k b z ch.
Proof.
  intros E E' n [[r o] ch'] b z ch R. cbn. rewrite (addr_Rx E E' n r o R).
  destruct R as (A & _). rewrite A. reflexivity.
Qed.

Lemma fact_holds_Rx : forall E E' n f, Rx E E' n -> fact_nlt n f -> fact_holds E f -> fact_holds E' f.
Proof.
  intros E E' n f R N H. pose proof R as (A & B & _).
  destruct f; cbn in N, H |- *.
  - rewrite (den_Rx E E' n); auto.
  - rewrite (den_Rx E E' n); auto. rewrite A, B. exact H.
  - rewrite (den_Rx E E' n); auto.
  - rewrite (map_den_ext E E' n); auto. apply Rx_Ext; auto.
Qed.

Lemma sok_nlt : forall n a, sok n a -> nlt n a.
Proof. intros n a [H _]. exact H. Qed.

Lemma out_match_mono : forall E E' n n' out so, out_match E n out so -> Rx E E' n -> Ple n n' ->
  out_match E' n' out so.
Proof.
  intros E E' n n' out so H R L.
  destruct out as [ | | | [[v ty]|]]; destruct so as [ | | | [[t ty']|]]; cbn in *; auto.
  destruct H as (H1 & H2 & H3). split; [ exact H1 | split ].
  - rewrite (den_Rx E E' n); auto. apply H3.
  - eapply sok_mono; eauto.
Qed.

Lemma temps_ok_ext : forall E E' n n' tle le, temps_ok E n tle le -> Ext E E' n -> Ple n n' ->
  temps_ok E' n' tle le.
Proof.
  intros E E' n n' tle le T X L id a H. destruct (T id a H) as (v & T1 & D & S).
  exists v. split; [ exact T1 | split ].
  - rewrite (den_ext E E' n); auto. apply S.
  - eapply sok_mono; eauto.
Qed.

Lemma out_match_ext : forall E E' n n' out so, out_match E n out so -> Ext E E' n -> Ple n n' ->
  out_match E' n' out so.
Proof.
  intros E E' n n' out so H X L.
  destruct out as [ | | | [[v ty]|]]; destruct so as [ | | | [[t ty']|]]; cbn in *; auto.
  destruct H as (H1 & H2 & H3). split; [ exact H1 | split ].
  - rewrite (den_ext E E' n); auto. apply H3.
  - eapply sok_mono; eauto.
Qed.

Lemma inb_loc : forall g g' r o ch, g_loc g' = g_loc g -> inb g' r o ch = inb g r o ch.
Proof. intros. unfold inb. rewrite H. reflexivity. Qed.

(* ---------------------------------------------------------------- *)
(* Joins are sound                                                    *)
(* ---------------------------------------------------------------- *)

Definition sel (sd : bool) (t1 t2 : sval) : sval := if sd then t1 else t2.

(* the join invariant: [Es] is the real side's environment, [nx0] the join's
   start, [E] the joined environment so far; each memo name holds the value
   its pair has on the real side *)
Definition MINV (sd : bool) (Es : senv) (nx0 : positive) (E : senv) (mo : memo) (nx : positive)
    : Prop :=
  Rx Es E nx0 /\ env_ok E /\ Ple nbase nx0 /\ Ple nx0 nx
  /\ (forall a b k, In (a, b, k) mo -> Plt k nx /\ e_rho E k = den Es (sel sd a b)).

Definition AUC (sd : bool) (Es : senv) (nx0 : positive) (E : senv) (ro : bool)
    (t1 t2 : sval) (nx : positive) (mo : memo) (t : sval) (nx' : positive) (mo' : memo) : Prop :=
  exists E', MINV sd Es nx0 E' mo' nx' /\ Rx E E' nx /\ Ple nx nx'
    /\ den E' t = den Es (sel sd t1 t2) /\ nlt nx' t
    /\ (dold (sel sd t1 t2) -> dold t) /\ (sok nx0 (sel sd t1 t2) -> sok nx' t)
    /\ (ro = true -> nx' = nx /\ mo' = mo).

Lemma mfind_in : forall mo t1 t2 k, mfind mo t1 t2 = Some k -> In (t1, t2, k) mo.
Proof.
  induction mo as [|[[a b] k'] mo IH]; intros t1 t2 k H; cbn in H; [ discriminate | ].
  destruct (sbeq a t1 && sbeq b t2) eqn:Q.
  - injection H as <-. apply andb_true_iff in Q as [Q1 Q2]. unfold sbeq in Q1, Q2.
    destruct (sval_eq a t1); [ | discriminate ]. destruct (sval_eq b t2); [ | discriminate ].
    subst. left; reflexivity.
  - right. eauto.
Qed.

Lemma sok_of_dold : forall n a, nlt n a -> dold a -> sok n a.
Proof. intros n a N D. split; [ exact N | destruct a; auto ]. Qed.

Lemma sok_struct : forall n0 n s t, nlt n t -> (dold s -> dold t) ->
  (forall r o, s <> Sptr r o) -> (forall r o, t <> Sptr r o) -> sok n0 s -> sok n t.
Proof.
  intros n0 n s t N D Hs Ht [_ S]. split; [ exact N | ].
  destruct t; try (exfalso; eapply Ht; reflexivity); apply D;
    (destruct s; [ exact S | exfalso; eapply Hs; reflexivity | exact S .. ]).
Qed.

Lemma au_eq_side : forall sd Es nx0 ro t1 nx mo E, MINV sd Es nx0 E mo nx -> nlt nx0 t1 ->
  AUC sd Es nx0 E ro t1 t1 nx mo t1 nx mo.
Proof.
  intros sd Es nx0 ro t1 nx mo E M N. pose proof M as (R & EO & L0 & L1 & MO).
  assert (SE : sel sd t1 t1 = t1) by (destruct sd; reflexivity).
  exists E. rewrite SE.
  split; [ exact M | split; [ apply Rx_refl | split; [ apply Ple_refl | split ] ] ].
  - eapply den_Rx; eauto.
  - split; [ eapply nlt_mono; eauto | split; [ auto | split ] ].
    + intros S. eapply sok_mono; eauto.
    + intros _. split; reflexivity.
Qed.

Lemma au_new_side : forall sd Es nx0 ro t1 t2 nx mo t nx' mo' E,
  au_new ro t1 t2 nx mo = Some (t, nx', mo') -> MINV sd Es nx0 E mo nx ->
  nlt nx0 (sel sd t1 t2) -> (ro = false -> sok nx0 (sel sd t1 t2)) ->
  AUC sd Es nx0 E ro t1 t2 nx mo t nx' mo'.
Proof.
  intros sd Es nx0 ro t1 t2 nx mo t nx' mo' E J M N S. unfold au_new in J.
  pose proof M as (R & EO & L0 & L1 & MO).
  destruct (mfind mo t1 t2) as [k|] eqn:F.
  - injection J as <- <- <-. apply mfind_in in F. destruct (MO _ _ _ F) as [K Ek].
    exists E. split; [ exact M | split; [ apply Rx_refl | split; [ apply Ple_refl | split ] ] ].
    + cbn. exact Ek.
    + split; [ cbn; exact K | split; [ cbn; auto | split ] ].
      * intros _. split; cbn; auto.
      * intros _. split; reflexivity.
  - destruct ro; [ discriminate | ].
    destruct (loc_ptr t1 || loc_ptr t2) eqn:LP; [ discriminate | ]. injection J as <- <- <-.
    apply orb_false_iff in LP as [LP1 LP2]. specialize (S eq_refl).
    set (E' := upd E nx (den Es (sel sd t1 t2))).
    assert (RU : Rx E E' nx) by apply Rx_upd.
    exists E'. split; [ | split; [ exact RU | split; [ apply Ple_succ | split ] ] ].
    + split; [ eapply Rx_trans; [ exact R | exact RU | exact L1 ] | split; [ | split; [ exact L0 | split ] ] ].
      * eapply env_ok_Rx; [ exact EO | exact RU | unfold Ple in *; lia | ].
        intros k v H. unfold E', upd in H; cbn in H. destruct (Pos.eq_dec k nx).
        -- eapply sok_old; [ exact EO | exact S | destruct sd; auto | ].
           rewrite (den_Rx Es E nx0); [ exact H | exact R | exact N ].
        -- destruct EO as (_ & _ & _ & _ & _ & RO). eapply RO; eauto.
      * unfold Ple in *; lia.
      * intros a b k [Eq | I].
        -- injection Eq as <- <- <-. split; [ apply Plt_succ | ].
           unfold E', upd; cbn. destruct (Pos.eq_dec nx nx); [ reflexivity | congruence ].
        -- destruct (MO a b k I) as [K Ek]. split; [ unfold Plt in *; lia | ].
           unfold E', upd; cbn. destruct (Pos.eq_dec k nx); [ subst; exfalso; eapply Plt_strict; eauto | exact Ek ].
    + unfold E', upd; cbn. destruct (Pos.eq_dec nx nx); [ reflexivity | congruence ].
    + split; [ cbn; apply Plt_succ | split; [ intros _; cbn; auto | split ] ].
      * intros _. split; cbn; [ apply Plt_succ | auto ].
      * intros H. discriminate.
Qed.

Ltac au_dec J :=
  repeat (match type of J with context [if ?d then _ else _] => destruct d end; cbn beta iota in J);
  subst.

Ltac au_new_solve := eapply au_new_side; [ eassumption | eassumption | eassumption | eassumption ].

Lemma au_side : forall sd Es nx0 ro t1 t2 nx mo t nx' mo' E,
  au ro t1 t2 nx mo = Some (t, nx', mo') -> MINV sd Es nx0 E mo nx ->
  nlt nx0 (sel sd t1 t2) -> (ro = false -> sok nx0 (sel sd t1 t2)) ->
  AUC sd Es nx0 E ro t1 t2 nx mo t nx' mo'.
Proof.
  intros sd Es nx0 ro t1.
  induction t1 as [ v | r o | r o ch | p IHp k ch | p IHp k | n | op a IHa ty
                  | op a1 IHa1 ty1 a2 IHa2 ty2 | a IHa ta tb | ch a IHa ];
    intros u nx mo w nx' mo' E J M N S; cbn [au] in J;
    (match type of J with context [sbeq ?x u] => destruct (sbeq x u) eqn:Q end;
     [ injection J as <- <- <-; unfold sbeq in Q;
       match type of Q with context [sval_eq ?x ?y] => destruct (sval_eq x y) as [<- | ]; [ | discriminate Q ] end;
       apply au_eq_side; [ exact M | destruct sd; exact N ] | ]).
  1-3,6: destruct u; cbn beta iota in J; au_new_solve.
  (* Swld *)
  - destruct u as [ | | | p' k' ch' | | | | | | ]; cbn beta iota in J; au_dec J; try au_new_solve.
    destruct (au ro p p' nx mo) as [[[x n1] m1]|] eqn:A; [ | discriminate J ].
    cbn beta iota in J. injection J as <- <- <-.
    destruct (IHp p' nx mo x n1 m1 E A M) as (E' & M' & R' & L' & D' & N' & DO' & SO' & RO').
    { destruct sd; exact N. }
    { intros F. destruct (S F) as [S1 S2]. apply sok_of_dold; [ destruct sd; exact S1 | destruct sd; exact S2 ]. }
    match goal with |- AUC _ _ _ _ _ ?T1 ?T2 _ _ ?T _ _ =>
      assert (DOt : dold (sel sd T1 T2) -> dold T) by (intros H; apply DO'; destruct sd; exact H) end.
    exists E'. split; [ exact M' | split; [ exact R' | split; [ exact L' | split ] ] ].
    { destruct sd; cbn [sel den] in D' |- *; rewrite D'; reflexivity. }
    split; [ exact N' | split; [ exact DOt | split; [ | exact RO' ] ] ].
    apply sok_struct; [ exact N' | exact DOt | intros ? ?; destruct sd; discriminate | intros ? ?; discriminate ].
  (* Swoff *)
  - destruct u as [ | | | | p' k' | | | | | ]; cbn beta iota in J; au_dec J; try au_new_solve.
    destruct (au ro p p' nx mo) as [[[x n1] m1]|] eqn:A; [ | discriminate J ].
    cbn beta iota in J. injection J as <- <- <-.
    destruct (IHp p' nx mo x n1 m1 E A M) as (E' & M' & R' & L' & D' & N' & DO' & SO' & RO').
    { destruct sd; exact N. }
    { intros F. destruct (S F) as [S1 S2]. apply sok_of_dold; [ destruct sd; exact S1 | destruct sd; exact S2 ]. }
    match goal with |- AUC _ _ _ _ _ ?T1 ?T2 _ _ ?T _ _ =>
      assert (DOt : dold (sel sd T1 T2) -> dold T) by (intros H; apply DO'; destruct sd; exact H) end.
    exists E'. split; [ exact M' | split; [ exact R' | split; [ exact L' | split ] ] ].
    { destruct sd; cbn [sel den] in D' |- *; rewrite D'; reflexivity. }
    split; [ exact N' | split; [ exact DOt | split; [ | exact RO' ] ] ].
    apply sok_struct; [ exact N' | exact DOt | intros ? ?; destruct sd; discriminate | intros ? ?; discriminate ].
  (* Sunop *)
  - destruct u as [ | | | | | | op' a' ty' | | | ]; cbn beta iota in J; au_dec J; try au_new_solve.
    destruct (au ro a a' nx mo) as [[[x n1] m1]|] eqn:A; [ | discriminate J ].
    cbn beta iota in J. injection J as <- <- <-.
    destruct (IHa a' nx mo x n1 m1 E A M) as (E' & M' & R' & L' & D' & N' & DO' & SO' & RO').
    { destruct sd; exact N. }
    { intros F. destruct (S F) as [S1 S2]. apply sok_of_dold; [ destruct sd; exact S1 | destruct sd; exact S2 ]. }
    match goal with |- AUC _ _ _ _ _ ?T1 ?T2 _ _ ?T _ _ =>
      assert (DOt : dold (sel sd T1 T2) -> dold T) by (intros H; apply DO'; destruct sd; exact H) end.
    exists E'. split; [ exact M' | split; [ exact R' | split; [ exact L' | split ] ] ].
    { destruct sd; cbn [sel den] in D' |- *; rewrite D'; reflexivity. }
    split; [ exact N' | split; [ exact DOt | split; [ | exact RO' ] ] ].
    apply sok_struct; [ exact N' | exact DOt | intros ? ?; destruct sd; discriminate | intros ? ?; discriminate ].
  (* Sbinop *)
  - destruct u as [ | | | | | | | op' b1 ty1' b2 ty2' | | ]; cbn beta iota in J; au_dec J; try au_new_solve.
    destruct (au ro a1 b1 nx mo) as [[[x n1] m1]|] eqn:A1; [ | discriminate J ]. cbn beta iota in J.
    destruct (au ro a2 b2 n1 m1) as [[[y n2] m2]|] eqn:A2; [ | discriminate J ]. cbn beta iota in J.
    injection J as <- <- <-.
    assert (Na : nlt nx0 (sel sd a1 b1) /\ nlt nx0 (sel sd a2 b2)) by (destruct sd; exact N).
    destruct Na as [Na1 Na2].
    assert (Sa : ro = false -> sok nx0 (sel sd a1 b1) /\ sok nx0 (sel sd a2 b2)).
    { intros F. pose proof (S F) as SF.
      destruct sd; destruct SF as [[S1 S1'] [S2 S2']]; split; apply sok_of_dold; assumption. }
    destruct (IHa1 b1 nx mo x n1 m1 E A1 M Na1 (fun F => proj1 (Sa F)))
      as (E1 & M1 & R1 & L1 & D1 & N1 & DO1 & SO1 & RO1).
    destruct (IHa2 b2 n1 m1 y n2 m2 E1 A2 M1 Na2 (fun F => proj2 (Sa F)))
      as (E2 & M2 & R2 & L2 & D2 & N2 & DO2 & SO2 & RO2).
    match goal with |- AUC _ _ _ _ _ ?T1 ?T2 _ _ ?T _ _ =>
      assert (DOt : dold (sel sd T1 T2) -> dold T) end.
    { intros H. destruct sd; destruct H as [H1 H2]; split; [ apply DO1 | apply DO2 | apply DO1 | apply DO2 ];
        assumption. }
    match goal with |- AUC _ _ _ _ _ _ _ _ _ ?T _ _ =>
      assert (NT : nlt n2 T) by (split; [ eapply nlt_mono; eauto | exact N2 ]) end.
    exists E2. split; [ exact M2 | split; [ eapply Rx_trans; eauto | split; [ eapply Ple_trans; eauto | split ] ] ].
    { rewrite <- (den_Rx E1 E2 n1 x R2 N1) in D1.
      destruct sd; cbn [sel den] in D1, D2 |- *; rewrite D1, D2; reflexivity. }
    split; [ exact NT | split; [ exact DOt | split ] ].
    + apply sok_struct; [ exact NT | exact DOt | intros ? ?; destruct sd; discriminate | intros ? ?; discriminate ].
    + intros H. destruct (RO1 H) as [-> ->]. destruct (RO2 H) as [-> ->]. split; reflexivity.
  (* Scast *)
  - destruct u as [ | | | | | | | | a' ta' tb' | ]; cbn beta iota in J; au_dec J; try au_new_solve.
    destruct (au ro a a' nx mo) as [[[x n1] m1]|] eqn:A; [ | discriminate J ].
    cbn beta iota in J. injection J as <- <- <-.
    destruct (IHa a' nx mo x n1 m1 E A M) as (E' & M' & R' & L' & D' & N' & DO' & SO' & RO').
    { destruct sd; exact N. }
    { intros F. destruct (S F) as [S1 S2]. apply sok_of_dold; [ destruct sd; exact S1 | destruct sd; exact S2 ]. }
    match goal with |- AUC _ _ _ _ _ ?T1 ?T2 _ _ ?T _ _ =>
      assert (DOt : dold (sel sd T1 T2) -> dold T) by (intros H; apply DO'; destruct sd; exact H) end.
    exists E'. split; [ exact M' | split; [ exact R' | split; [ exact L' | split ] ] ].
    { destruct sd; cbn [sel den] in D' |- *; rewrite D'; reflexivity. }
    split; [ exact N' | split; [ exact DOt | split; [ | exact RO' ] ] ].
    apply sok_struct; [ exact N' | exact DOt | intros ? ?; destruct sd; discriminate | intros ? ?; discriminate ].
  (* Sldres *)
  - destruct u as [ | | | | | | | | | ch' a' ]; cbn beta iota in J; au_dec J; try au_new_solve.
    destruct (au ro a a' nx mo) as [[[x n1] m1]|] eqn:A; [ | discriminate J ].
    cbn beta iota in J. injection J as <- <- <-.
    destruct (IHa a' nx mo x n1 m1 E A M) as (E' & M' & R' & L' & D' & N' & DO' & SO' & RO').
    { destruct sd; exact N. }
    { intros F. destruct (S F) as [S1 S2]. apply sok_of_dold; [ destruct sd; exact S1 | destruct sd; exact S2 ]. }
    match goal with |- AUC _ _ _ _ _ ?T1 ?T2 _ _ ?T _ _ =>
      assert (DOt : dold (sel sd T1 T2) -> dold T) by (intros H; apply DO'; destruct sd; exact H) end.
    exists E'. split; [ exact M' | split; [ exact R' | split; [ exact L' | split ] ] ].
    { destruct sd; cbn [sel den] in D' |- *; rewrite D'; reflexivity. }
    split; [ exact N' | split; [ exact DOt | split; [ | exact RO' ] ] ].
    apply sok_struct; [ exact N' | exact DOt | intros ? ?; destruct sd; discriminate | intros ? ?; discriminate ].
Qed.

Lemma jtemps_side : forall sd Es nx0 l le2 acc nx mo le nx2 mo2 E,
  jtemps l le2 acc nx mo = Some (le, nx2, mo2) -> MINV sd Es nx0 E mo nx ->
  (forall id t, acc ! id = Some t -> sok nx t) ->
  (forall id t1 t2, In (id, t1) l -> le2 ! id = Some t2 -> sok nx0 (sel sd t1 t2)) ->
  exists E', MINV sd Es nx0 E' mo2 nx2 /\ Rx E E' nx /\ Ple nx nx2 /\
    forall id t, le ! id = Some t -> sok nx2 t /\
      ((acc ! id = Some t /\ den E' t = den E t) \/
       (exists t1 t2, In (id, t1) l /\ le2 ! id = Some t2 /\ den E' t = den Es (sel sd t1 t2))).
Proof.
  intros sd Es nx0 l le2. induction l as [|[id t1] l IH]; intros acc nx mo le nx2 mo2 E J M A S;
    cbn [jtemps] in J.
  - injection J as <- <- <-.
    exists E. split; [ exact M | split; [ apply Rx_refl | split; [ apply Ple_refl | ] ] ].
    intros id t H. split; [ eapply A; eauto | left; auto ].
  - destruct (le2 ! id) as [t2|] eqn:T2; [ | discriminate ].
    destruct (au false t1 t2 nx mo) as [[[t nx'] mo']|] eqn:J2; [ | discriminate ].
    pose proof (S id t1 t2 (or_introl eq_refl) T2) as S0.
    destruct (au_side sd Es nx0 false t1 t2 nx mo t nx' mo' E J2 M (sok_nlt _ _ S0) (fun _ => S0))
      as (E1 & M1 & R1 & L1 & D1 & N1 & DO1 & SO1 & _).
    destruct (IH (PTree.set id t acc) nx' mo' le nx2 mo2 E1 J M1) as (E2 & M2 & R2 & L2 & H2).
    { intros id' t' H. rewrite PTree.gsspec in H. destruct (peq id' id).
      - inv H. exact (SO1 S0).
      - eapply sok_mono; [ eapply A; eauto | exact L1 ]. }
    { intros id' a b I B. exact (S id' a b (or_intror I) B). }
    exists E2. split; [ exact M2 | split; [ eapply Rx_trans; eauto | split ] ].
    { unfold Ple in *; lia. }
    intros id' t' H. destruct (H2 id' t' H) as [Sx [(Ha & Hd) | (a & b & I & B & Hd)]].
    + split; [ exact Sx | ]. rewrite PTree.gsspec in Ha. destruct (peq id' id).
      * subst. inv Ha. right. exists t1, t2. split; [ left; auto | split; [ exact T2 | ] ].
        rewrite Hd. exact D1.
      * left. split; [ exact Ha | ]. rewrite Hd. eapply den_Rx; [ exact R1 | ].
        apply sok_nlt. eapply A; eauto.
    + split; [ exact Sx | ]. right. exists a, b. split; [ right; exact I | split; [ exact B | exact Hd ] ].
Qed.

Lemma jmem_side : forall sd Es nx0 ks g1 g2 nx mo sm nx3 mo3 E,
  jmem ks g1 g2 nx mo = Some (sm, nx3, mo3) -> MINV sd Es nx0 E mo nx ->
  (forall r o ch t1 t2, In (r, o, ch) ks -> sload g1 r o ch = Some t1 -> sload g2 r o ch = Some t2 ->
     sok nx0 (sel sd t1 t2)) ->
  exists E', MINV sd Es nx0 E' mo3 nx3 /\ Rx E E' nx /\ Ple nx nx3 /\ map skey sm = ks /\
    forall r o ch t, In (r, o, ch, t) sm -> sok nx3 t /\
      exists t1 t2, sload g1 r o ch = Some t1 /\ sload g2 r o ch = Some t2
                    /\ den E' t = den Es (sel sd t1 t2).
Proof.
  intros sd Es nx0 ks g1 g2. induction ks as [|[[r o] ch] ks IH]; intros nx mo sm nx3 mo3 E J M S;
    cbn [jmem] in J.
  - injection J as <- <- <-.
    exists E. split; [ exact M | split; [ apply Rx_refl | split; [ apply Ple_refl | ] ] ].
    split; [ reflexivity | ]. intros r o ch t [].
  - destruct (sload g1 r o ch) as [t1|] eqn:T1; [ | discriminate ].
    destruct (sload g2 r o ch) as [t2|] eqn:T2; [ | discriminate ].
    destruct (au false t1 t2 nx mo) as [[[t nx'] mo']|] eqn:J2; [ | discriminate ].
    destruct (jmem ks g1 g2 nx' mo') as [[[sm' nx''] mo'']|] eqn:J3; [ | discriminate ].
    injection J as <- <- <-.
    pose proof (S r o ch t1 t2 (or_introl eq_refl) T1 T2) as S0.
    destruct (au_side sd Es nx0 false t1 t2 nx mo t nx' mo' E J2 M (sok_nlt _ _ S0) (fun _ => S0))
      as (E1 & M1 & R1 & L1 & D1 & N1 & DO1 & SO1 & _).
    destruct (IH nx' mo' sm' nx'' mo'' E1 J3 M1) as (E2 & M2 & R2 & L2 & K2 & H2).
    { intros r' o' ch' a b I A B. exact (S r' o' ch' a b (or_intror I) A B). }
    exists E2. split; [ exact M2 | split; [ eapply Rx_trans; eauto | split ] ].
    { unfold Ple in *; lia. }
    split; [ cbn; rewrite K2; reflexivity | ].
    intros r' o' ch' t' [Eq | I].
    + inv Eq. split; [ eapply sok_mono; [ exact (SO1 S0) | exact L2 ] | ].
      exists t1, t2. split; [ exact T1 | split; [ exact T2 | ] ].
      rewrite (den_Rx E1 E2 nx'); [ exact D1 | exact R2 | exact N1 ].
    + destruct (H2 _ _ _ _ I) as [Sx (a & b & A & B & Hd)]. split; [ exact Sx | ].
      exists a, b. split; [ exact A | split; [ exact B | exact Hd ] ].
Qed.

Lemma jout_side : forall (sd : bool) Es nx0 o1 o2 nx mo o nx1 mo1 E out,
  jout o1 o2 nx mo = Some (o, nx1, mo1) -> MINV sd Es nx0 E mo nx ->
  out_match Es nx0 out (if sd then o1 else o2) ->
  exists E', MINV sd Es nx0 E' mo1 nx1 /\ Rx E E' nx /\ Ple nx nx1 /\ out_match E' nx1 out o.
Proof.
  intros sd Es nx0 o1 o2 nx mo o nx1 mo1 E out J M OM.
  pose proof M as (R & EO & L0 & L1 & MO).
  assert (TRIV : o1 = o2 -> o = o1 -> nx1 = nx -> mo1 = mo ->
            exists E', MINV sd Es nx0 E' mo1 nx1 /\ Rx E E' nx /\ Ple nx nx1 /\ out_match E' nx1 out o).
  { intros <- -> -> ->. exists E. split; [ exact M | split; [ apply Rx_refl | split; [ apply Ple_refl | ] ] ].
    eapply out_match_mono; [ destruct sd; exact OM | exact R | exact L1 ]. }
  destruct o1 as [ | | | [[v1 t1]|]]; destruct o2 as [ | | | [[v2 t2]|]]; cbn [jout] in J; try discriminate;
    try (injection J as <- <- <-; apply TRIV; reflexivity).
  destruct (type_eq t1 t2); [ subst | discriminate ].
  destruct (au false v1 v2 nx mo) as [[[v nx'] mo']|] eqn:J2; [ | discriminate ].
  injection J as <- <- <-.
  destruct out as [ | | | [[w ty]|]]; destruct sd; cbn in OM; try contradiction.
  - destruct OM as (<- & Dw & Sw).
    destruct (au_side true Es nx0 false v1 v2 nx mo v nx' mo' E J2 M (sok_nlt _ _ Sw) (fun _ => Sw))
      as (E1 & M1 & R1 & L1' & D1 & N1 & _ & SO1 & _).
    exists E1. split; [ exact M1 | split; [ exact R1 | split; [ exact L1' | ] ] ].
    cbn. split; [ reflexivity | split; [ rewrite D1; exact Dw | exact (SO1 Sw) ] ].
  - destruct OM as (<- & Dw & Sw).
    destruct (au_side false Es nx0 false v1 v2 nx mo v nx' mo' E J2 M (sok_nlt _ _ Sw) (fun _ => Sw))
      as (E1 & M1 & R1 & L1' & D1 & N1 & _ & SO1 & _).
    exists E1. split; [ exact M1 | split; [ exact R1 | split; [ exact L1' | ] ] ].
    cbn. split; [ reflexivity | split; [ rewrite D1; exact Dw | exact (SO1 Sw) ] ].
Qed.

Lemma au_fact_side : forall (sd : bool) Es nx0 E mo nx f1 f2 f,
  au_fact f1 f2 nx mo = Some f -> MINV sd Es nx0 E mo nx ->
  fact_nlt nx0 (if sd then f1 else f2) -> fact_holds Es (if sd then f1 else f2) ->
  fact_nlt nx f /\ fact_holds E f.
Proof.
  intros sd Es nx0 E mo nx f1 f2 f J M FN FH.
  pose proof M as (R & EO & L0 & L1 & MO).
  assert (AU : forall c1 c2 c nx' mo', au true c1 c2 nx mo = Some (c, nx', mo') ->
            nlt nx0 (sel sd c1 c2) -> nlt nx c /\ den E c = den Es (sel sd c1 c2)).
  { intros c1 c2 c nx' mo' A N.
    destruct (au_side sd Es nx0 true c1 c2 nx mo c nx' mo' E A M N (fun F => ltac:(discriminate F)))
      as (E1 & M1 & R1 & L1' & D1 & N1 & _ & _ & RO1).
    destruct (RO1 eq_refl) as [-> ->]. split; [ exact N1 | ].
    rewrite <- D1. symmetry. eapply den_Rx; [ exact R1 | exact N1 ]. }
  pose proof R as (BA & BB & _).
  destruct f1 as [c1 ty1 b1 | p1 n1 | t1 k1 | u1 a1], f2 as [c2 ty2 b2 | p2 n2 | t2 k2 | u2 a2];
    cbn [au_fact] in J; try discriminate.
  - destruct (type_eq ty1 ty2); [ subst | discriminate ]. destruct (bool_dec b1 b2); [ subst | discriminate ].
    destruct (au true c1 c2 nx mo) as [[[c n'] m']|] eqn:A; [ | discriminate ]. injection J as <-.
    destruct (AU c1 c2 c n' m' A) as [N D]; [ destruct sd; exact FN | ].
    split; [ exact N | ]. cbn. rewrite D. destruct sd; exact FH.
  - destruct (Z.eq_dec n1 n2); [ subst | discriminate ].
    destruct (au true p1 p2 nx mo) as [[[c n'] m']|] eqn:A; [ | discriminate ]. injection J as <-.
    destruct (AU p1 p2 c n' m' A) as [N D]; [ destruct sd; exact FN | ].
    split; [ exact N | ]. cbn. rewrite D, BA, BB. destruct sd; exact FH.
  - destruct (Int.eq_dec k1 k2); [ subst | discriminate ].
    destruct (au true t1 t2 nx mo) as [[[c n'] m']|] eqn:A; [ | discriminate ]. injection J as <-.
    destruct (AU t1 t2 c n' m' A) as [N D]; [ destruct sd; exact FN | ].
    split; [ exact N | ]. cbn. rewrite D. destruct sd; exact FH.
  - destruct (Pos.eq_dec u1 u2); [ subst | discriminate ].
    destruct (au_args a1 a2 nx mo) as [a|] eqn:A; [ | discriminate ]. injection J as <-.
    assert (AL : forall l1 l2 l, au_args l1 l2 nx mo = Some l -> Forall (nlt nx0) (if sd then l1 else l2) ->
                   Forall (nlt nx) l /\ map (den E) l = map (den Es) (if sd then l1 else l2)).
    { induction l1 as [| c1 l1 IH]; intros [| c2 l2] l H N; cbn [au_args] in H; try discriminate.
      - injection H as <-. destruct sd; split; constructor.
      - destruct (au true c1 c2 nx mo) as [[[c n'] m']|] eqn:Ac; [ | discriminate ].
        destruct (au_args l1 l2 nx mo) as [l'|] eqn:Al; [ | discriminate ]. injection H as <-.
        assert (N' : nlt nx0 (sel sd c1 c2) /\ Forall (nlt nx0) (if sd then l1 else l2))
          by (destruct sd; inversion N; subst; split; assumption).
        destruct N' as (Nc & Nl).
        destruct (AU c1 c2 c n' m' Ac Nc) as [Nc' Dc].
        destruct (IH l2 l' Al Nl) as [Nl' Dl].
        split; [ constructor; assumption | ].
        destruct sd; cbn [map sel] in *; rewrite Dc, Dl; reflexivity. }
    destruct (AL a1 a2 a A) as [N D]; [ destruct sd; exact FN | ].
    split; [ exact N | ]. cbn [fact_holds]. rewrite D. destruct sd; exact FH.
Qed.

Lemma first_some_in : forall {A B : Type} (f : A -> option B) l y,
  first_some f l = Some y -> exists x, In x l /\ f x = Some y.
Proof.
  intros A B f l. induction l as [|a l IH]; intros y H; cbn in H; [ discriminate | ].
  destruct (f a) as [b|] eqn:F.
  - injection H as <-. exists a. split; [ left; reflexivity | exact F ].
  - destruct (IH y H) as (x & I & Fx). exists x. split; [ right; exact I | exact Fx ].
Qed.

Lemma jfacts_in : forall pc1 pc2 nx mo f, In f (jfacts pc1 pc2 nx mo) ->
  exists f1 f2, In f1 pc1 /\ In f2 pc2 /\ au_fact f1 f2 nx mo = Some f.
Proof.
  intros pc1 pc2 nx mo f I. unfold jfacts in I. apply in_flat_map in I. destruct I as (f1 & I1 & I2).
  destruct (first_some (fun f2 => au_fact f1 f2 nx mo) pc2) as [f'|] eqn:F; [ | destruct I2 ].
  destruct I2 as [<- | []]. destruct (first_some_in _ _ _ F) as (f2 & If2 & A).
  exists f1, f2. split; [ exact I1 | split; [ exact If2 | exact A ] ].
Qed.

Lemma key_eq_true : forall a b, key_eq a b = true -> a = b.
Proof.
  intros [[r o] ch] [[r' o'] ch'] H. unfold key_eq in H.
  destruct (Pos.eqb_spec r r'); [ | discriminate ].
  destruct (Z.eqb_spec o o'); [ | discriminate ].
  destruct (chunk_eq ch ch'); [ | discriminate ]. subst. reflexivity.
Qed.

Lemma jkeys_of_side : forall (sd : bool) g1 g2 e, In e (g_sm (if sd then g1 else g2)) ->
  In (skey e) (jkeys_of g1 g2).
Proof.
  intros sd g1 g2 e I. unfold jkeys_of. apply in_or_app. destruct sd.
  - left. apply in_map. exact I.
  - destruct (existsb (key_eq (skey e)) (map skey (g_sm g1))) eqn:X.
    + left. apply existsb_exists in X. destruct X as [k [Ik Ek]]. apply key_eq_true in Ek.
      subst. exact Ik.
    + right. apply filter_In. split; [ apply in_map; exact I | rewrite X; reflexivity ].
Qed.

Lemma join2_side : forall (sd : bool) p1 p2 p, join2 p1 p2 = Some p ->
  forall E0 n0 gl tle m out, PM E0 n0 gl tle m out (if sd then p1 else p2) ->
  PM E0 n0 gl tle m out p.
Proof.
  intros sd [[le1 g1] o1] [[le2 g2] o2] p J E0 n0 gl tle m out PMs. unfold join2 in J.
  destruct (list_eq_dec Pos.eq_dec (g_loc g1) (g_loc g2)) as [GL | ]; [ | discriminate ].
  destruct (list_eq_dec Pos.eq_dec (g_cl g1) (g_cl g2)) as [GC | ]; [ | discriminate ].
  destruct (list_eq_dec Pos.eq_dec _ _) as [KE | ]; [ | discriminate ].
  set (nx0 := Pos.max (g_nx g1) (g_nx g2)) in J.
  destruct (jout o1 o2 nx0 nil) as [[[o nx1] mo1]|] eqn:JO; [ | discriminate ].
  destruct (jtemps (PTree.elements le1) le2 (PTree.empty sval) nx1 mo1) as [[[le nx2] mo2]|] eqn:JT;
    [ | discriminate ].
  destruct (jmem (jkeys_of g1 g2) g1 g2 nx2 mo2) as [[[sm nx3] mo3]|] eqn:JM; [ | discriminate ].
  injection J as <-.
  set (gs := if sd then g1 else g2).
  set (les := if sd then le1 else le2).
  set (os := if sd then o1 else o2).
  assert (PMs' : exists E, Ext E0 E n0 /\ MMg E m gs /\ temps_ok E (g_nx gs) tle les
            /\ out_match E (g_nx gs) out os /\ Ple n0 (g_nx gs) /\ g_loc gs = gl)
    by (unfold gs, les, os; destruct sd; exact PMs).
  clear PMs. destruct PMs' as (Es & X0 & MM & TM & OM & P0 & GLs).
  assert (Lgs : Ple (g_nx gs) nx0) by (unfold gs, nx0; destruct sd; [ apply Pos.le_max_l | apply Pos.le_max_r ]).
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  assert (NB0 : Ple nbase nx0) by (unfold Ple in *; lia).
  assert (M0 : MINV sd Es nx0 Es nil nx0).
  { split; [ apply Rx_refl | split; [ exact EO | split; [ exact NB0 | split; [ apply Ple_refl | ] ] ] ].
    intros a b k []. }
  (* stage 1: outcome *)
  destruct (jout_side sd Es nx0 o1 o2 nx0 nil o nx1 mo1 Es out JO M0
              (out_match_mono Es Es _ _ _ _ OM (Rx_refl _ _) Lgs)) as (E1 & M1 & R1 & L1 & OM1).
  (* stage 2: temps *)
  destruct (jtemps_side sd Es nx0 (PTree.elements le1) le2 (PTree.empty sval) nx1 mo1 le nx2 mo2 E1 JT M1)
    as (E2 & M2 & R2 & L2 & TJ).
  { intros id t H. rewrite PTree.gempty in H. discriminate. }
  { intros id t1 t2 I B. apply PTree.elements_complete in I.
    assert (Hs : les ! id = Some (sel sd t1 t2)) by (unfold les, sel; destruct sd; auto).
    destruct (TM id _ Hs) as (_ & _ & _ & S). eapply sok_mono; [ exact S | exact Lgs ]. }
  (* stage 3: memory *)
  assert (SLs : forall r o ch t1 t2, sload g1 r o ch = Some t1 -> sload g2 r o ch = Some t2 ->
            sload gs r o ch = Some (sel sd t1 t2)) by (intros; unfold gs, sel; destruct sd; auto).
  destruct (jmem_side sd Es nx0 (jkeys_of g1 g2) g1 g2 nx2 mo2 sm nx3 mo3 E2 JM M2)
    as (E3 & M3 & R3 & L3 & K3 & MJ).
  { intros r o' ch t1 t2 I A B. pose proof (SLs _ _ _ _ _ A B) as Ss.
    destruct (sload_sound _ _ _ _ _ _ _ MM Ss) as [_ S]. eapply sok_mono; [ exact S | exact Lgs ]. }
  pose proof M3 as (R03 & EO3 & _ & L03 & _).
  assert (R13 : Rx E1 E3 nx1) by (eapply Rx_trans; [ exact R2 | exact R3 | exact L2 ]).
  assert (Rs3 : Rx Es E3 (g_nx gs)) by (eapply Rx_mono; eauto).
  assert (GL1 : g_loc gs = g_loc g1) by (unfold gs; destruct sd; auto).
  pose proof R03 as (BA & BB & _).
  exists E3. split; [ eapply Ext_trans; [ exact X0 | apply Rx_Ext; exact Rs3 | exact P0 ] | ].
  cbn [g_nx g_loc]. split; [ | split; [ | split; [ | split; [ unfold Ple in *; lia | congruence ] ] ] ].
  - (* MMg *)
    unfold MMg; cbn [g_nx g_loc g_sm g_pc].
    split; [ exact EO3 | split; [ unfold Ple in *; lia | split; [ | split; [ | split; [ exact VP | split; [ exact NX | split; [ | split ] ] ] ] ] ] ].
    + (* entries *)
      intros r o' ch t I. destruct (MJ r o' ch t I) as (S & t1 & t2 & A & B & Hd).
      pose proof (SLs _ _ _ _ _ A B) as Ss.
      split; [ | split; [ exact S | ] ].
      * cbn [g_sm]. unfold sload in Ss. destruct (inb gs r o' ch) eqn:IB; [ | discriminate ].
        rewrite (inb_loc gs); [ exact IB | cbn; congruence ].
      * destruct (sload_sound _ _ _ _ _ _ _ MM Ss) as [Ld Sd].
        rewrite Hd, BA, (addr_Rx Es E3 nx0 r o' R03). exact Ld.
    + (* frame *)
      intros b z ch OLD NOV CLD. apply FR; [ exact OLD | |
        intros r I; apply (rng_disj_eq E3 Es); [ symmetry; exact BA | symmetry; exact BB | apply CLD;
          cbn [g_cl]; unfold gs in I; destruct sd; [ exact I | rewrite GC; exact I ] ] ].
      intros e I. assert (IK : In (skey e) (map skey sm)).
      { rewrite K3. apply (jkeys_of_side sd). fold gs. exact I. }
      apply in_map_iff in IK. destruct IK as [e' [Ke I']].
      rewrite <- (cell_disj_Rx Es E3 nx0 _ _ _ _ R03). rewrite <- Ke. apply NOV. exact I'.
    + (* facts *)
      intros f I. destruct (jfacts_in _ _ _ _ _ I) as (f1 & f2 & I1 & I2 & A).
      assert (Is : In (if sd then f1 else f2) (g_pc gs)) by (unfold gs; destruct sd; assumption).
      destruct (PC _ Is) as [Fn Fh].
      eapply au_fact_side; [ exact A | exact M3 | eapply fact_nlt_mono; [ exact Fn | exact Lgs ] | exact Fh ].
    + (* locals *)
      intros r I. rewrite <- GL1 in I. destruct (LOC r I) as (A & B & C & D & F).
      rewrite BA, BB. split; [ exact A | split; [ unfold Plt, Ple in *; lia | auto ] ].
    + intros r r' I I'. rewrite BA. apply LINJ; rewrite GL1; auto.
  - (* temps *)
    intros id t H. destruct (TJ id t H) as [S [(Ha & _) | (t1 & t2 & I & B & Hd)]].
    + rewrite PTree.gempty in Ha. discriminate.
    + apply PTree.elements_complete in I.
      assert (Hs : les ! id = Some (sel sd t1 t2)) by (unfold les, sel; destruct sd; auto).
      destruct (TM id _ Hs) as (v & Tv & Dv & Sv). exists v. split; [ exact Tv | split ].
      * rewrite (den_Rx E2 E3 nx2 t R3 (sok_nlt _ _ S)), Hd. exact Dv.
      * eapply sok_mono; [ exact S | exact L3 ].
  - (* outcome *)
    eapply out_match_mono; [ exact OM1 | exact R13 | unfold Ple in *; lia ].
Qed.

Lemma join2_sound : forall p1 p2 p, join2 p1 p2 = Some p ->
  forall E0 n0 gl tle m out, PM E0 n0 gl tle m out p1 \/ PM E0 n0 gl tle m out p2 ->
  PM E0 n0 gl tle m out p.
Proof.
  intros p1 p2 p J E0 n0 gl tle m out [H | H].
  - exact (join2_side true p1 p2 p J E0 n0 gl tle m out H).
  - exact (join2_side false p1 p2 p J E0 n0 gl tle m out H).
Qed.

Section COVER.
Variable P : spath -> Prop.
Hypothesis PJ : forall p1 p2 p, join2 p1 p2 = Some p -> P p1 \/ P p2 -> P p.

Lemma jinsert_cover : forall acc p k,
  (P p -> exists q, In q (map snd (jinsert p k acc)) /\ P q)
  /\ (forall q, In q (map snd acc) -> P q -> exists q', In q' (map snd (jinsert p k acc)) /\ P q').
Proof.
  induction acc as [|[k' q] acc IH]; intros p k; cbn [jinsert].
  - split; [ intros H; exists p; split; [ left; auto | exact H ] | intros q [] ].
  - destruct (IH p k) as [IH1 IH2].
    destruct (pkey_eq k k'); [ destruct (join2 q p) as [j|] eqn:J | ].
    + split.
      * intros H. exists j. split; [ left; auto | eapply PJ; eauto ].
      * intros q0 [<- | I] H; [ exists j; split; [ left; auto | eapply PJ; eauto ] | ].
        exists q0. split; [ right; exact I | exact H ].
    + split.
      * intros H. destruct (IH1 H) as [q' [I Hq]]. exists q'. split; [ right; exact I | exact Hq ].
      * intros q0 [<- | I] H; [ exists q; split; [ left; auto | exact H ] | ].
        destruct (IH2 q0 I H) as [q' [I' Hq]]. exists q'. split; [ right; exact I' | exact Hq ].
    + split.
      * intros H. destruct (IH1 H) as [q' [I Hq]]. exists q'. split; [ right; exact I | exact Hq ].
      * intros q0 [<- | I] H; [ exists q; split; [ left; auto | exact H ] | ].
        destruct (IH2 q0 I H) as [q' [I' Hq]]. exists q'. split; [ right; exact I' | exact Hq ].
Qed.

Lemma jfold_cover : forall ps acc,
  (forall q, In q (map snd acc) -> P q ->
     exists q', In q' (map snd (fold_left (fun acc p => jinsert p (key_of p) acc) ps acc)) /\ P q')
  /\ (forall p, In p ps -> P p ->
     exists q', In q' (map snd (fold_left (fun acc p => jinsert p (key_of p) acc) ps acc)) /\ P q').
Proof.
  induction ps as [|p ps IH]; intros acc; cbn [fold_left].
  - split; [ intros q I H; exists q; auto | intros p [] ].
  - destruct (IH (jinsert p (key_of p) acc)) as [A B].
    destruct (jinsert_cover acc p (key_of p)) as [C D].
    split.
    + intros q I H. destruct (D q I H) as [q1 [I1 H1]]. eapply A; eauto.
    + intros p0 [<- | I] H.
      * destruct (C H) as [q1 [I1 H1]]. eapply A; eauto.
      * eapply B; eauto.
Qed.

Lemma jgroup_cover : forall ps p, In p ps -> P p -> exists q, In q (jgroup ps) /\ P q.
Proof. intros ps p I H. unfold jgroup. eapply (proj2 (jfold_cover ps nil)); eauto. Qed.

End COVER.

Lemma jgroup_PM : forall E0 n0 gl tle m out ps p, In p ps -> PM E0 n0 gl tle m out p ->
  exists q, In q (jgroup ps) /\ PM E0 n0 gl tle m out q.
Proof.
  intros. eapply jgroup_cover; eauto. intros p1 p2 p' J H'. eapply join2_sound; eauto.
Qed.

Lemma CM_sp : forall E0 n0 gl m v c, CM E0 n0 gl m v c ->
  PM E0 n0 gl (PTree.empty val) m (Out_return (Some (v, Tvoid))) (cp_to_sp c).
Proof.
  intros E0 n0 gl m v [g r] (E & X & MM & D & S & L & G). cbn.
  exists E. split; [ exact X | split; [ exact MM | split; [ | split; [ auto | auto ] ] ] ].
  intros id a H. rewrite PTree.gempty in H. discriminate.
Qed.

Lemma sp_CM : forall E0 n0 gl tle m v p c, sp_to_cp p = Some c ->
  PM E0 n0 gl tle m (Out_return (Some (v, Tvoid))) p -> CM E0 n0 gl m v c.
Proof.
  intros E0 n0 gl tle m v [[le g] o] c H P. cbn in H.
  destruct o as [ | | | [[r ty]|]]; try discriminate. inv H.
  destruct P as (E & X & MM & T & (_ & D & S) & L & G). exists E. auto 10.
Qed.

Lemma omap_in : forall {A B : Type} (f : A -> option B) l r x,
  omap f l = Some r -> In x l -> exists y, f x = Some y /\ In y r.
Proof.
  intros A B f l. induction l as [|a l IH]; intros r x H I; [ destruct I | ].
  cbn [omap] in H. destruct (f a) as [ya|] eqn:Fa; [ | discriminate].
  destruct (omap f l) as [rl|] eqn:Fl; [ | discriminate]. inv H.
  destruct I as [<- | I].
  - exists ya. split; auto. left. reflexivity.
  - destruct (IH rl x eq_refl I) as [y [Fy Iy]]. exists y. split; auto. right. exact Iy.
Qed.

Lemma oflat_in : forall {A B : Type} (f : A -> option (list B)) l r x,
  oflat f l = Some r -> In x l -> exists rx, f x = Some rx /\ (forall y, In y rx -> In y r).
Proof.
  intros A B f l. induction l as [|a l IH]; intros r x H I; [ destruct I | ].
  cbn [oflat] in H. destruct (f a) as [ra|] eqn:Fa; [ | discriminate].
  destruct (oflat f l) as [rl|] eqn:Fl; [ | discriminate]. inv H.
  destruct I as [<- | I].
  - exists ra. split; auto. intros y Y. apply in_or_app. left. exact Y.
  - destruct (IH rl x eq_refl I) as [rx [Fx Inc]]. exists rx. split; auto.
    intros y Y. apply in_or_app. right. auto.
Qed.

Lemma jgroup_c_cover : forall E0 n0 gl m v cs cs' c, jgroup_c cs = Some cs' -> In c cs ->
  CM E0 n0 gl m v c -> exists c', In c' cs' /\ CM E0 n0 gl m v c'.
Proof.
  intros E0 n0 gl m v cs cs' c J I H. unfold jgroup_c in J.
  destruct (jgroup_PM E0 n0 gl _ m _ (map cp_to_sp cs) (cp_to_sp c) (in_map _ _ _ I) (CM_sp _ _ _ _ _ _ H))
    as [q [Iq Pq]].
  destruct (omap_in _ _ _ _ J Iq) as [c' [Ec Ic]]. exists c'. split; [ exact Ic | ].
  eapply sp_CM; eauto.
Qed.

(* ---------------------------------------------------------------- *)
(* Locals: allocation and freeing                                     *)
(* ---------------------------------------------------------------- *)

Lemma inb_live : forall E m g r o ch, MMg E m g -> inb g r o ch = true ->
  Plt r (g_nx g) /\ Plt (e_blk E r) (Mem.nextblock m).
Proof.
  intros E m g r o ch MM H.
  pose proof MM as ((A1 & _) & NB & _ & _ & _ & NX & _ & LOC & _).
  destruct (inb_spec _ _ _ _ H) as [(L & _) | (L & IN & _)].
  - split; [ unfold Plt, Ple in *; lia | ]. pose proof (pub_plt _ (A1 r L)) as A1'. unfold Plt, Ple in *. clear A1; lia.
  - destruct (LOC r IN) as (_ & P & _ & _ & B). auto.
Qed.

Lemma inb_incl : forall g g' r o ch, inb g r o ch = true -> incl (g_loc g) (g_loc g') ->
  inb g' r o ch = true.
Proof.
  unfold inb; intros g g' r o ch H I. destruct (Pos.ltb r nbase); auto.
  apply andb_true_iff in H as [H H3]. apply andb_true_iff in H as [H1 H2].
  rewrite H2, H3, andb_true_r, andb_true_r. apply existsb_exists in H1.
  destruct H1 as [x [IN E]]. apply existsb_exists. exists x. split; auto.
Qed.

Lemma fact_holds_ext : forall E E' n f, env_ok E -> Ext E E' n -> Ple nbase n ->
  fact_nlt n f -> fact_holds E f -> fact_holds E' f.
Proof.
  intros E E' n f EO X L N H. destruct f; cbn in N, H |- *.
  - rewrite (den_ext E E' n); auto.
  - rewrite (den_ext E E' n); auto. destruct H as (b & o & D & P & N0 & NM & DJ).
    exists b, o. split; [ exact D | split; [ exact P | split; [ exact N0 | split; [ exact NM | ] ] ] ].
    intros r sz S. destruct EO as (_ & A2 & _). destruct (A2 r sz S) as (Hr & _).
    destruct (X r ltac:(unfold Plt, Ple in *; lia)) as (B1 & B2 & _). rewrite B1, B2. auto.
  - rewrite (den_ext E E' n); auto.
  - rewrite (map_den_ext E E' n); auto.
Qed.

Lemma alloc_vp_other : forall m lo hi m' b1 b o, Mem.alloc m lo hi = (m', b1) -> b <> b1 ->
  Mem.valid_pointer m' b o = Mem.valid_pointer m b o.
Proof.
  intros m lo hi m' b1 b o A N.
  destruct (Mem.valid_pointer m b o) eqn:E1; destruct (Mem.valid_pointer m' b o) eqn:E2; auto.
  - apply Mem.valid_pointer_nonempty_perm in E1. eapply Mem.perm_alloc_1 in E1; eauto.
    apply Mem.valid_pointer_nonempty_perm in E1. congruence.
  - apply Mem.valid_pointer_nonempty_perm in E2. eapply Mem.perm_alloc_4 in E2; eauto.
    apply Mem.valid_pointer_nonempty_perm in E2. congruence.
Qed.

Definition salloc1 (E : senv) (r : positive) (b : block) : senv :=
  mke (fun x => if Pos.eq_dec x r then b else e_blk E x)
      (fun x => if Pos.eq_dec x r then Ptrofs.zero else e_base E x) (e_rho E).

Lemma Ext_salloc1 : forall E r b, Ext E (salloc1 E r b) r.
Proof.
  intros E r b k K. cbn. destruct (Pos.eq_dec k r); [ subst; exfalso; eapply Plt_strict; eauto | auto ].
Qed.

Lemma alloc_one_sound : forall E m g se0 e0 id ty m1 b1,
  MMg E m g -> env_match E (g_loc g) se0 e0 -> Mem.alloc m 0 (sizeof ge ty) = (m1, b1) ->
  let g' := mkg (g_sm g) (g_pc g) (Pos.succ (g_nx g)) (g_nx g :: g_loc g) (g_cl g) in
  let E' := salloc1 E (g_nx g) b1 in
  MMg E' m1 g' /\ env_match E' (g_loc g') (PTree.set id (g_nx g, ty) se0) (PTree.set id (b1, ty) e0).
Proof.
  intros E m g se0 e0 id ty m1 b1 MM EM A g' E'.
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  set (nx := g_nx g) in *.
  assert (X : Ext E E' nx) by apply Ext_salloc1.
  assert (Bnew : b1 = Mem.nextblock m) by (eapply Mem.alloc_result; eauto).
  assert (NXm : Mem.nextblock m1 = Pos.succ (Mem.nextblock m)) by (eapply Mem.nextblock_alloc; eauto).
  assert (OLDLIVE : forall r, Plt r nx -> (Plt r nbase \/ In r (g_loc g)) ->
            e_blk E' r = e_blk E r /\ e_base E' r = e_base E r /\ Plt (e_blk E r) (Mem.nextblock m)).
  { intros r P H. destruct (X r P) as (B1 & B2 & _). split; [ exact B1 | split; [ exact B2 | ] ].
    destruct H as [H | H].
    - destruct EO as (A1 & _). pose proof (pub_plt _ (A1 r H)) as A1'. unfold Plt, Ple in *. lia.
    - destruct (LOC r H) as (_ & _ & _ & _ & F). exact F. }
  split.
  - split; [ | split; [ cbn; unfold nx, Ple in *; lia | split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ] ] ].
    + eapply env_ok_ext; [ exact EO | eapply Ext_mono; [ exact X | exact NB ] | ].
      destruct EO as (_ & _ & _ & _ & _ & R). exact R.
    + (* entries *)
      intros r o ch sv IN. cbn [g_sm g'] in IN. destruct (ENT r o ch sv IN) as (IB & S & L).
      destruct (inb_live _ _ _ _ _ _ MM IB) as [P _].
      assert (LV : Plt r nbase \/ In r (g_loc g)).
      { destruct (inb_spec _ _ _ _ IB) as [(Lr & _) | (_ & Ir & _)]; auto. }
      destruct (OLDLIVE r P LV) as (B1 & B2 & BL).
      split; [ eapply inb_incl; [ exact IB | cbn; intros x Ix; right; exact Ix ] | ].
      split; [ eapply sok_mono; [ exact S | cbn; apply Ple_succ ] | ].
      unfold addr. rewrite B1, B2. erewrite Mem.load_alloc_unchanged; [ | exact A | exact BL ].
      fold (addr E r o). rewrite L. symmetry. eapply den_ext; [ apply S | exact X ].
    + (* frame *)
      intros b z ch OLD NOV.
      intros CLD.
      erewrite Mem.load_alloc_unchanged; [ | exact A | unfold Mem.valid_block, Plt, Ple in *; lia ].
      apply FR; [ exact OLD | |
        intros r I; apply (rng_disj_Ext E E' nx); [ exact EO | exact NB | exact X | apply CLD; exact I ] ].
      intros e I. specialize (NOV e I).
      destruct e as [[[r o] ch'] sv]. destruct (ENT r o ch' sv I) as (IB & _).
      destruct (inb_live _ _ _ _ _ _ MM IB) as [P _].
      assert (LV : Plt r nbase \/ In r (g_loc g)).
      { destruct (inb_spec _ _ _ _ IB) as [(Lr & _) | (_ & Ir & _)]; auto. }
      destruct (OLDLIVE r P LV) as (B1 & B2 & _).
      cbn [cell_disj skey] in NOV |- *. unfold addr in *. rewrite B1, B2 in NOV. exact NOV.
    + intros b o k p OLD. rewrite <- (VP b o k p OLD).
      assert (NE : b <> b1) by (intro E0; subst; unfold Plt, Ple in *; lia).
      split; intro HH; [ eapply Mem.perm_alloc_4; eauto | eapply Mem.perm_alloc_1; eauto ].
    + rewrite NXm. unfold Ple in *. lia.
    + intros f I. cbn [g_pc g'] in I. destruct (PC f I) as [N H]. split.
      * eapply fact_nlt_mono; [ exact N | apply Ple_succ ].
      * eapply fact_holds_ext; eauto.
    + intros r I. cbn [g_loc g'] in I. destruct I as [<- | I].
      * cbn. destruct (Pos.eq_dec nx nx); [ | congruence ].
        split; [ unfold Plt, Ple in *; lia | split; [ apply Plt_succ | split; [ reflexivity | ] ] ].
        rewrite NXm, Bnew. split; [ unfold Plt, Ple in *; lia | apply Plt_succ ].
      * destruct (LOC r I) as (A0 & P & B & N & F).
        destruct (X r P) as (B1 & B2 & _). rewrite B1, B2.
        split; [ exact A0 | split; [ apply Plt_trans_succ; exact P | split; [ exact B | split; [ exact N | ] ] ] ].
        rewrite NXm. unfold Plt in *; lia.
    + intros r r' I I' Eq. cbn [g_loc g'] in I, I'.
      assert (OB : forall x, In x (g_loc g) -> e_blk E' x = e_blk E x /\ Plt (e_blk E x) b1).
      { intros x Ix. destruct (LOC x Ix) as (_ & P & _ & _ & F).
        destruct (X x P) as (B1 & _). rewrite Bnew. auto. }
      assert (NB1 : e_blk E' nx = b1) by (cbn; destruct (Pos.eq_dec nx nx); congruence).
      destruct I as [<- | I]; destruct I' as [<- | I']; auto.
      * destruct (OB r' I') as [B1 P]. rewrite NB1, B1 in Eq. rewrite Eq in P. exfalso; eapply Plt_strict; eauto.
      * destruct (OB r I) as [B1 P]. rewrite NB1, B1 in Eq. rewrite Eq in P. exfalso; eapply Plt_strict; eauto.
      * destruct (OB r I) as [B1 _], (OB r' I') as [B1' _]. apply LINJ; auto. congruence.
  - intros x. rewrite !PTree.gsspec. destruct (peq x id).
    + cbn. destruct (Pos.eq_dec nx nx); [ | congruence ]. split; [ reflexivity | split; [ reflexivity | left; reflexivity ] ].
    + specialize (EM x). destruct (se0 ! x) as [[r ty0]|]; destruct (e0 ! x) as [[b ty1]|]; auto.
      destruct EM as (-> & <- & I). destruct (LOC r I) as (_ & P & _).
      destruct (X r P) as (B1 & _). split; [ auto | split; [ reflexivity | right; exact I ] ].
Qed.

Lemma salloc_sound : forall vars se0 g se g1 e0 m e m1 E,
  salloc vars se0 g = (se, g1) ->
  alloc_variables ge e0 m vars e m1 ->
  MMg E m g -> env_match E (g_loc g) se0 e0 ->
  exists E1 newl, Ext E E1 (g_nx g) /\ MMg E1 m1 g1 /\ env_match E1 (g_loc g1) se e /\
    Ple (g_nx g) (g_nx g1) /\ g_loc g1 = newl ++ g_loc g /\
    (forall r, In r newl -> Ple (g_nx g) r) /\
    (forall id r ty, se ! id = Some (r, ty) -> se0 ! id = Some (r, ty) \/ In r newl).
Proof.
  induction vars as [|[id ty] vars IH]; intros se0 g se g1 e0 m e m1 E S AV MM EM;
    cbn [salloc] in S.
  - inv S. inv AV. exists E, nil. split; [ apply Ext_refl | split; [ exact MM | split; [ exact EM | ] ] ].
    split; [ apply Ple_refl | split; [ reflexivity | split; [ intros r [] | auto ] ] ].
  - inv AV.
    match goal with HA : Mem.alloc _ _ _ = (?m1', ?b1') |- _ => rename HA into A end.
    destruct (alloc_one_sound E m g se0 e0 id ty _ _ MM EM A) as [MM1 EM1].
    match goal with HV : alloc_variables _ _ _ vars e m1 |- _ => rename HV into AV' end.
    destruct (IH _ _ _ _ _ _ _ _ _ S AV' MM1 EM1) as (E2 & newl & X2 & MM2 & EM2 & L2 & G2 & F2 & SE2).
    exists E2, (newl ++ [g_nx g]). cbn [g_nx g_loc] in *.
    split; [ eapply Ext_trans; [ apply Ext_salloc1 | exact X2 | apply Ple_succ ] | ].
    split; [ exact MM2 | split; [ exact EM2 | split ] ].
    { eapply Ple_trans; [ apply Ple_succ | exact L2 ]. }
    split; [ rewrite G2, <- app_assoc; reflexivity | split ].
    + intros r I. apply in_app_or in I. destruct I as [I | [<- | []]]; [ | apply Ple_refl ].
      eapply Ple_trans; [ apply Ple_succ | exact (F2 r I) ].
    + intros id' r ty' H. destruct (SE2 id' r ty' H) as [H' | H'].
      * rewrite PTree.gsspec in H'. destruct (peq id' id).
        -- inv H'. right. apply in_or_app. right. left. reflexivity.
        -- left. exact H'.
      * right. apply in_or_app. left. exact H'.
Qed.

Lemma free_list_other : forall l m m', Mem.free_list m l = Some m' ->
  forall b, (forall lo hi, ~ In (b, lo, hi) l) ->
  (forall ch z, Mem.load ch m' b z = Mem.load ch m b z)
  /\ (forall z k p, Mem.perm m' b z k p <-> Mem.perm m b z k p)
  /\ Mem.nextblock m' = Mem.nextblock m.
Proof.
  induction l as [|[[b0 lo] hi] l IH]; intros m m' F b N; cbn in F.
  - inv F. split; [ auto | split; [ intros; reflexivity | auto ] ].
  - destruct (Mem.free m b0 lo hi) as [m1|] eqn:FR; [ | discriminate ].
    assert (NE : b <> b0) by (intro; subst; apply (N lo hi); left; reflexivity).
    destruct (IH m1 m' F b ltac:(intros lo' hi' I; apply (N lo' hi'); right; exact I)) as (A & B & C).
    split; [ | split ].
    + intros ch z. rewrite A. eapply Mem.load_free; eauto.
    + intros z k p. rewrite B.
      split; intro HH; [ eapply Mem.perm_free_3; eauto | eapply Mem.perm_free_1; eauto ].
    + rewrite C. eapply Mem.nextblock_free; eauto.
Qed.

Lemma free_list_nextblock : forall l m m', Mem.free_list m l = Some m' -> Mem.nextblock m' = Mem.nextblock m.
Proof.
  induction l as [|[[b0 lo] hi] l IH]; intros m m' F; cbn in F.
  - inv F. auto.
  - destruct (Mem.free m b0 lo hi) as [m1|] eqn:FR; [ | discriminate ].
    rewrite (IH _ _ F). eapply Mem.nextblock_free; eauto.
Qed.

Lemma sfree_sound : forall E m2 g2 m3 loc0 l,
  MMg E m2 g2 -> incl loc0 (g_loc g2) ->
  Mem.free_list m2 l = Some m3 ->
  (forall b lo hi, In (b, lo, hi) l -> exists r, In r (g_loc g2) /\ ~ In r loc0 /\ b = e_blk E r) ->
  MMg E m3 (sfree loc0 g2).
Proof.
  intros E m2 g2 m3 loc0 l MM INC F FB.
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  assert (NXm : Mem.nextblock m3 = Mem.nextblock m2) by (eapply free_list_nextblock; eauto).
  assert (OLDNF : forall b, Plt b (Mem.nextblock m0) -> forall lo hi, ~ In (b, lo, hi) l).
  { intros b OLD lo hi I. destruct (FB b lo hi I) as (r & Ir & _ & ->).
    destruct (LOC r Ir) as (_ & _ & _ & N & _). contradiction. }
  assert (KEEPNF : forall r, (Plt r nbase \/ In r loc0) -> forall lo hi, ~ In (e_blk E r, lo, hi) l).
  { intros r H lo hi I. destruct (FB _ lo hi I) as (r' & Ir' & Nr' & Eb).
    destruct H as [H | H].
    - destruct EO as (A1 & _). pose proof (pub_plt _ (A1 r H)) as A1'. rewrite Eb in A1'.
      destruct (LOC r' Ir') as (_ & _ & _ & N & _). contradiction.
    - apply Nr'. rewrite (LINJ r r' (INC r H) Ir' Eb) in H. exact H. }
  unfold sfree. unfold MMg; cbn [g_nx g_loc g_sm g_pc].
  split; [ exact EO | split; [ exact NB | split; [ | split; [ | split; [ | split; [ | split; [ exact PC | split ] ] ] ] ] ] ].
  - intros r o ch sv I. apply filter_In in I. destruct I as [I K].
    destruct (ENT r o ch sv I) as (IB & S & L).
    assert (KR : Plt r nbase \/ In r loc0).
    { apply orb_true_iff in K. destruct K as [K | K]; [ left; apply Pos.ltb_lt; exact K | right ].
      apply existsb_exists in K. destruct K as [x [Ix Ex]]. apply Pos.eqb_eq in Ex. subst. exact Ix. }
    split; [ | split; [ exact S | ] ].
    + unfold inb in IB |- *. cbn [g_loc]. destruct (Pos.ltb_spec r nbase); auto.
      destruct KR as [KR | KR]; [ unfold Plt, Ple in *; lia | ].
      apply andb_true_iff in IB as [IB H3]. apply andb_true_iff in IB as [_ H2].
      rewrite H2, H3, !andb_true_r. apply existsb_exists. exists r. split; [ exact KR | apply Pos.eqb_refl ].
    + destruct (free_list_other _ _ _ F _ (KEEPNF r KR)) as (A & _). rewrite A. exact L.
  - intros b z ch OLD NOV.
    destruct (free_list_other _ _ _ F _ (OLDNF b OLD)) as (A & _). rewrite A.
    apply FR; [ exact OLD | ]. intros [[[r o] ch'] sv] I.
    destruct (orb (Pos.ltb r nbase) (existsb (Pos.eqb r) loc0)) eqn:K.
    + apply NOV. apply filter_In. split; [ exact I | exact K ].
    + cbn. left. intro Eb. destruct (ENT r o ch' sv I) as (IB & _).
      destruct (inb_spec _ _ _ _ IB) as [(Lr & _) | (_ & Ir & _)].
      * apply Pos.ltb_lt in Lr. rewrite Lr in K. discriminate.
      * destruct (LOC r Ir) as (_ & _ & _ & N & _). apply N. rewrite Eb. exact OLD.
  - intros b o k p OLD. destruct (free_list_other _ _ _ F _ (OLDNF b OLD)) as (_ & B & _).
    rewrite B. apply VP. exact OLD.
  - rewrite NXm. exact NX.
  - intros r I. destruct (LOC r (INC r I)) as (A & B & C & D & G). rewrite NXm. auto.
  - intros r r' I I'. apply LINJ; apply INC; auto.
Qed.

(* ---------------------------------------------------------------- *)
(* Statement-level helpers                                            *)
(* ---------------------------------------------------------------- *)

Lemma env_match_ext : forall E E' n gl se e, env_match E gl se e -> Ext E E' n ->
  (forall r, In r gl -> Plt r n) -> env_match E' gl se e.
Proof.
  intros E E' n gl se e EM X L id. specialize (EM id).
  destruct (se ! id) as [[r ty]|]; destruct (e ! id) as [[b ty']|]; auto.
  destruct EM as (-> & <- & I). destruct (X r (L r I)) as (B & _). auto.
Qed.

Lemma MM_loc_lt : forall E m g r, MMg E m g -> In r (g_loc g) -> Plt r (g_nx g).
Proof.
  intros E m g r MM I. destruct MM as (_ & _ & _ & _ & _ & _ & _ & LOC & _).
  destruct (LOC r I) as (_ & P & _). exact P.
Qed.

Lemma MMg_add_fact : forall E m g f, MMg E m g -> fact_nlt (g_nx g) f -> fact_holds E f ->
  MMg E m (add_fact g f).
Proof.
  intros E m g f (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ) N H.
  unfold add_fact, MMg; cbn [g_nx g_loc g_sm g_pc].
  split; [ exact EO | split; [ exact NB | split; [ | split; [ exact FR | split; [ exact VP | split; [ exact NX | split; [ | split; [ exact LOC | exact LINJ ] ] ] ] ] ] ] ].
  - intros r o ch sv I. destruct (ENT r o ch sv I) as (IB & S & L). split; [ | auto ].
    rewrite <- IB. apply inb_loc. reflexivity.
  - intros f' [<- | I]; auto.
Qed.


(* ---- the simplest sound contract: memory unchanged, an unknown result ---- *)

(* the contract "memory unchanged, some result" (atan2s, ...) *)
Definition xc_fresh : xcontract := fun _ g => Some [(gfresh g, Sfresh (g_nx g))].

Lemma fresh_cm : forall E m g v, MMg E m g -> val_old v ->
  CM E (g_nx g) (g_loc g) m v (gfresh g, Sfresh (g_nx g)).
Proof.
  intros E m g v MM O. pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  set (nx := g_nx g) in *.
  set (E' := upd E nx (Some v)).
  assert (R : Rx E E' nx) by apply Rx_upd.
  assert (L1 : Ple nx (Pos.succ nx)) by (apply Ple_succ).
  exists E'. split; [ apply Rx_Ext; exact R | ].
  split; [ | split; [ cbn; destruct (Pos.eq_dec nx nx); [ reflexivity | congruence ] | ] ].
  - unfold MMg, gfresh; cbn [g_nx g_loc g_sm g_pc]. fold nx.
    split; [ | split; [ | split; [ | split; [ | split; [ exact VP | split; [ exact NX | split; [ | split ] ] ] ] ] ] ].
    + eapply env_ok_Rx; [ exact EO | exact R | exact NB | ].
      intros k w H. cbn in H. destruct (Pos.eq_dec k nx); [ inv H; exact O | ].
      destruct EO as (_ & _ & _ & _ & _ & RO). eapply RO; eauto.
    + eapply Ple_trans; [ exact NB | exact L1 ].
    + intros r o ch sv I. destruct (ENT r o ch sv I) as (IB & S & L).
      split; [ rewrite <- IB; apply inb_loc; reflexivity | ].
      split; [ eapply sok_mono; eauto | ].
      rewrite (addr_Rx E E' nx r o R). rewrite (den_Rx E E' nx sv R (sok_nlt _ _ S)). exact L.
    + intros b z ch P D. apply FR; [ exact P | ].
      intros e I. rewrite <- (cell_disj_Rx E E' nx _ b z ch R). auto.
    + intros f I. destruct (PC f I) as (N & H). split; [ eapply fact_nlt_mono; eauto | ].
      eapply fact_holds_Rx; eauto.
    + intros r I. destruct (LOC r I) as (A & B & C & D & F).
      split; [ exact A | split; [ eapply Plt_trans_succ; exact B | ]].
      split; [ exact C | split; [ exact D | exact F ] ].
    + exact LINJ.
  - split; [ split; [ cbn; apply Plt_succ | cbn; exact I ] | ].
    split; [ exact L1 | reflexivity ].
Qed.

(* a call that leaves memory unchanged and returns an old value is
   described by [xc_fresh] *)
Lemma xc_fresh_sound : forall E m g v args cps,
  xc_fresh args g = Some cps -> MMg E m g -> val_old v ->
  exists c, In c cps /\ CM E (g_nx g) (g_loc g) m v c.
Proof.
  intros E m g v args cps H MM O. inv H.
  eexists; split; [ left; reflexivity | apply fresh_cm; auto ].
Qed.

(* ---- a call that leaves every existing block as it was (it may only
   allocate): the fresh contract describes it too ---- *)
Lemma load_unch_valid : forall m m' ch b z,
  Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m' -> Mem.valid_block m b ->
  Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros m m' ch b z U V. destruct (Mem.load ch m b z) as [v|] eqn:L.
  - eapply Mem.load_unchanged_on; [ exact U | | exact L ]. intros. exact V.
  - destruct (Mem.load ch m' b z) as [v'|] eqn:L'; [ exfalso | reflexivity ].
    apply Mem.load_valid_access in L'. destruct L' as [RP AL].
    assert (VA : Mem.valid_access m ch b z Readable).
    { split; [ | exact AL ]. intros i Hi. eapply Mem.perm_unchanged_on_2; eauto. }
    destruct (Mem.valid_access_load _ _ _ _ VA) as [v'' Hv]. congruence.
Qed.

Lemma MMg_unch : forall E m m' g, MMg E m g ->
  Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m' -> MMg E m' g.
Proof.
  intros E m m' g MM U.
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  pose proof (Mem.unchanged_on_nextblock _ _ _ U) as NXU.
  assert (OV : forall b, Plt b nb0 -> Mem.valid_block m b).
  { intros b L. unfold Mem.valid_block, Plt, Ple in *. lia. }
  split; [ exact EO | split; [ exact NB | split; [ | split; [ | split; [ | split; [ | split; [ exact PC | split; [ | exact LINJ ] ] ] ] ] ] ] ].
  - intros r o ch sv I. destruct (ENT r o ch sv I) as (IB & S & L). split; [ exact IB | split; [ exact S | ] ].
    rewrite <- L. apply load_unch_valid; [ exact U | ].
    destruct (inb_spec _ _ _ _ IB) as [(Lr & _) | (Lr & INl & _)].
    + apply OV. destruct EO as (G & _). apply pub_plt. exact (G r Lr).
    + destruct (LOC r INl) as (_ & _ & _ & _ & P). exact P.
  - intros b z ch L D1 D2. rewrite (load_unch_valid m m' ch b z U (OV b L)). exact (FR b z ch L D1 D2).
  - intros b o k p L. rewrite <- (VP b o k p L). split; intro P.
    + exact (Mem.perm_unchanged_on_2 _ _ _ _ _ _ _ U (OV b L) (OV b L) P).
    + exact (Mem.perm_unchanged_on _ _ _ _ _ _ _ U (OV b L) P).
  - unfold Ple in *. lia.
  - intros r I. destruct (LOC r I) as (A & B & C & D & F). repeat split; auto.
    unfold Plt, Ple in *. lia.
Qed.

Lemma xc_fresh_unch_sound : forall E m m' g v args cps,
  xc_fresh args g = Some cps -> MMg E m g ->
  Mem.unchanged_on (fun b _ => Mem.valid_block m b) m m' -> val_old v ->
  exists c, In c cps /\ CM E (g_nx g) (g_loc g) m' v c.
Proof.
  intros E m m' g v args cps H MM U O.
  exact (xc_fresh_sound E m' g v args cps H (MMg_unch E m m' g MM U) O).
Qed.

(* ---- building blocks for contracts that write cells ---- *)

(* naming one fresh value keeps the description *)
Lemma MMg_fresh_o : forall E m g ov, MMg E m g -> (forall v, ov = Some v -> val_old v) ->
  MMg (upd E (g_nx g) ov) m (gfresh g).
Proof.
  intros E m g ov MM O.
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  set (nx := g_nx g) in *.
  assert (R : Rx E (upd E nx ov) nx) by apply Rx_upd.
  assert (L1 : Ple nx (Pos.succ nx)) by (apply Ple_succ).
  unfold MMg, gfresh; cbn [g_nx g_loc g_sm g_pc]. fold nx.
  split; [ | split; [ | split; [ | split; [ | split; [ exact VP | split; [ exact NX | split; [ | split ] ] ] ] ] ] ].
  - eapply env_ok_Rx; [ exact EO | exact R | exact NB | ].
    intros k w H. cbn in H. destruct (Pos.eq_dec k nx); [ exact (O w H) | ].
    destruct EO as (_ & _ & _ & _ & _ & RO). eapply RO; eauto.
  - eapply Ple_trans; [ exact NB | exact L1 ].
  - intros r o ch sv I. destruct (ENT r o ch sv I) as (IB & S & L).
    split; [ rewrite <- IB; apply inb_loc; reflexivity | ].
    split; [ eapply sok_mono; eauto | ].
    rewrite (addr_Rx E _ nx r o R). rewrite (den_Rx E _ nx sv R (sok_nlt _ _ S)). exact L.
  - intros b z ch P D. apply FR; [ exact P | ].
    intros e I. rewrite <- (cell_disj_Rx E _ nx _ b z ch R). auto.
  - intros f I. destruct (PC f I) as (N & H). split; [ eapply fact_nlt_mono; eauto | ].
    eapply fact_holds_Rx; eauto.
  - intros r I. destruct (LOC r I) as (A & B & C & D & F).
    split; [ exact A | split; [ eapply Plt_trans_succ; exact B | ]].
    split; [ exact C | split; [ exact D | exact F ] ].
  - exact LINJ.
Qed.

Lemma MMg_fresh : forall E m g v, MMg E m g -> val_old v ->
  MMg (upd E (g_nx g) (Some v)) m (gfresh g).
Proof.
  intros E m g v MM O. apply MMg_fresh_o; [ exact MM | intros w H; injection H as <-; exact O ].
Qed.

(* the description carries over to a memory that agrees on every cell it
   describes, has the same permissions on old blocks, and no fewer blocks *)
Lemma MMg_transfer : forall E m g m',
  MMg E m g ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall r o ch sv, In (r, o, ch, sv) (g_sm g) ->
     Mem.load ch m' (e_blk E r) (addr E r o) = Mem.load ch m (e_blk E r) (addr E r o)) ->
  (forall b z ch, Plt b nb0 -> (forall e, In e (g_sm g) -> cell_disj E (skey e) b z ch) ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  (forall b o k p, Plt b nb0 -> (Mem.perm m' b o k p <-> Mem.perm m b o k p)) ->
  MMg E m' g.
Proof.
  intros E m g m' MM NXm EN FRm P.
  pose proof MM as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  split; [ exact EO | split; [ exact NB | split; [ | split; [ | split; [ | split; [ | split; [ exact PC | split; [ | exact LINJ ] ] ] ] ] ] ] ].
  - intros r o ch sv I. destruct (ENT r o ch sv I) as (IB & S & L).
    rewrite (EN r o ch sv I). auto.
  - intros b z ch OLD D. rewrite (FRm b z ch OLD D). apply FR; assumption.
  - intros b o k p OLD. rewrite (P b o k p OLD). apply VP. exact OLD.
  - eapply Ple_trans; eassumption.
  - intros r I. destruct (LOC r I) as (A & B & C & D & F).
    split; [ exact A | split; [ exact B | split; [ exact C | split; [ exact D | ] ] ] ].
    unfold Plt, Ple in *. lia.
Qed.

(* what a store keeps: the new entry, and the old entries it does not overlap *)
Lemma sstore_in : forall g r o ch sa g' e,
  sstore g r o ch sa = Some g' -> In e (g_sm g') ->
  e = (r, o, ch, sa) \/ (In e (g_sm g) /\ ovl r o ch e = false).
Proof.
  intros g r o ch sa g' e S I. unfold sstore in S.
  destruct (inb g r o ch); [ | discriminate ].
  destruct (forallb _ (g_sm g)); [ | discriminate ]. inv S.
  cbn [g_sm] in I. destruct I as [<- | I]; [ left; reflexivity | right ].
  apply filter_In in I. destruct I as [I N]. apply negb_true_iff in N. auto.
Qed.

Lemma sstore_inb : forall g r o ch sa g',
  sstore g r o ch sa = Some g' -> inb g r o ch = true.
Proof.
  intros g r o ch sa g' S. unfold sstore in S. destruct (inb g r o ch); [ reflexivity | discriminate ].
Qed.

Lemma temps_ok_set : forall E n tle le id v a, temps_ok E n tle le -> den E a = Some v -> sok n a ->
  temps_ok E n (PTree.set id v tle) (PTree.set id a le).
Proof.
  intros E n tle le id v a T D S x t H. rewrite PTree.gsspec in H |- *.
  destruct (peq x id); [ inv H; eauto | apply T; exact H ].
Qed.

Lemma sundef_ok : forall E n temps, temps_ok E n (create_undef_temps temps) (sundef temps).
Proof.
  intros E n temps. induction temps as [|[id ty] temps IH]; cbn [create_undef_temps sundef].
  - intros x t H. rewrite PTree.gempty in H. discriminate.
  - apply temps_ok_set; [ exact IH | reflexivity | apply sok_const; reflexivity ].
Qed.

Lemma sbind_ok : forall E n params sargs vargs sle tle sle' tle',
  Forall2 (fun a v => den E a = Some v /\ sok n a) sargs vargs -> temps_ok E n tle sle ->
  sbind params sargs sle = Some sle' -> bind_parameter_temps params vargs tle = Some tle' ->
  temps_ok E n tle' sle'.
Proof.
  intros E n. induction params as [|[id t] params IH]; intros sargs vargs sle tle sle' tle' F T S B;
    inversion F as [| a v sargs' vargs' [Hd Hs] F']; subst; cbn [sbind bind_parameter_temps] in S, B;
    try discriminate.
  - inv S. inv B. exact T.
  - eapply IH; [ exact F' | apply temps_ok_set; eauto | exact S | exact B ].
Qed.

Lemma Forall2_den_ext : forall E E' n n' sargs vargs,
  Forall2 (fun a v => den E a = Some v /\ sok n a) sargs vargs -> Ext E E' n -> Ple n n' ->
  Forall2 (fun a v => den E' a = Some v /\ sok n' a) sargs vargs.
Proof.
  intros E E' n n' sargs vargs F X L. induction F as [|a v sa va [D S] F IH]; constructor; auto.
  split; [ rewrite (den_ext E E' n); auto; apply S | eapply sok_mono; eauto ].
Qed.

Lemma PM_trans : forall E0 E1 n0 n1 gl tle m out p, PM E1 n1 gl tle m out p ->
  Ext E0 E1 n0 -> Ple n0 n1 -> PM E0 n0 gl tle m out p.
Proof.
  intros E0 E1 n0 n1 gl tle m out [[le g] so] (E & X & R) X0 L.
  exists E. split; [ eapply Ext_trans; eauto | ].
  destruct R as (A & B & C & D & G). split; [ exact A | split; [ exact B | split; [ exact C | split; [ | exact G ] ] ] ].
  eapply Ple_trans; eauto.
Qed.

Lemma CM_trans : forall E0 E1 n0 n1 gl m v c, CM E1 n1 gl m v c ->
  Ext E0 E1 n0 -> Ple n0 n1 -> CM E0 n0 gl m v c.
Proof.
  intros E0 E1 n0 n1 gl m v [g r] (E & X & R) X0 L.
  exists E. split; [ eapply Ext_trans; eauto | ].
  destruct R as (A & B & C & D & G). split; [ exact A | split; [ exact B | split; [ exact C | split; [ | exact G ] ] ] ].
  eapply Ple_trans; eauto.
Qed.

Lemma out_match_switch : forall E n out so, out_match E n out so ->
  out_match E n (outcome_switch out) (sout_switch so).
Proof.
  intros E n out so H. destruct out as [ | | | [[v ty]|]]; destruct so as [ | | | [[t ty']|]];
    cbn in *; auto.
Qed.

Lemma sresult_sound : forall E m g out so ty r vres, MMg E m g -> out_match E (g_nx g) out so ->
  sresult so ty = Some r -> outcome_result_value out ty vres m ->
  den E r = Some vres /\ sok (g_nx g) r.
Proof.
  intros E m g out so ty r vres MM OM SR OR.
  destruct out as [ | | | [[v t]|]]; destruct so as [ | | | [[a t']|]]; cbn in OM; try contradiction.
  all: try (destruct ty; unfold sresult in SR; cbn in OR; try discriminate; try contradiction;
            inv SR; split; [ reflexivity | apply sok_const; reflexivity ]; fail).
  destruct OM as (-> & D & S). unfold sresult in SR.
  destruct (type_eq ty Tvoid); [ discriminate | ]. cbn in OR. destruct OR as [_ C].
  eapply mk_cast_sound; eauto.
Qed.

Lemma eval_Evar_fun2 : forall e tle m id targs tres cc vf, e ! id = None ->
  eval_expr ge e tle m (Evar id (Tfunction targs tres cc)) vf ->
  exists b, Genv.find_symbol ge id = Some b /\ vf = Vptr b Ptrofs.zero.
Proof.
  intros e tle m id targs tres cc vf N H. inv H.
  match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv HL end.
  - congruence.
  - match goal with HD : deref_loc _ _ _ _ _ _ |- _ => inv HD end; cbn in *; try discriminate.
    eexists; split; eauto.
Qed.

Lemma blocks_of_env_in : forall e b lo hi, In (b, lo, hi) (blocks_of_env ge e) ->
  exists id ty, e ! id = Some (b, ty).
Proof.
  intros e b lo hi I. unfold blocks_of_env in I. apply in_map_iff in I.
  destruct I as [[id [b' ty]] [Eq I]]. cbn in Eq. inv Eq.
  apply PTree.elements_complete in I. eauto.
Qed.

(* ---- symbolic switches and stuck calls ---- *)

Lemma sem_cast_undef_int : forall sz sg a ty m, ty <> Tvoid -> sem_cast Vundef (Tint sz sg a) ty m = None.
Proof.
  intros sz sg a ty m N. unfold sem_cast, classify_cast.
  destruct ty; [ congruence | .. ];
  repeat match goal with
         | |- context [match ?x with _ => _ end] =>
             first [ is_var x; destruct x | destruct x eqn:? ]
         end; try reflexivity;
  repeat match goal with H : context [match ?x with _ => _ end] |- _ => destruct x end; discriminate.
Qed.

Lemma undef_stuck_sound : forall E n e tle le m al tyl vl, temps_ok E n tle le ->
  undef_stuck le al tyl = true -> eval_exprlist ge e tle m al tyl vl -> False.
Proof.
  intros E n e tle le m al tyl vl TM US H.
  induction H as [| a bl ty tyl v1 v2 vl Ha Hc Hl IH]; cbn [undef_stuck] in US; [ discriminate | ].
  apply orb_true_iff in US as [U | U]; [ | exact (IH U) ].
  unfold undef_arg in U. apply andb_true_iff in U as [NV U].
  destruct a; try discriminate. destruct t; try discriminate.
  destruct (le ! i) as [sv|] eqn:L; [ | discriminate ].
  destruct sv; try discriminate. destruct v; try discriminate.
  destruct (TM _ _ L) as (v & Tv & Dv & _). cbn [den] in Dv. injection Dv as <-.
  assert (V1 : v1 = Vundef).
  { inv Ha; [ congruence | ].
    match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv HL end. }
  subst v1. cbn [typeof] in Hc. rewrite sem_cast_undef_int in Hc; [ discriminate | ].
  intro E0. subst ty. discriminate.
Qed.

Lemma sw_const_some : forall c v, sw_const c = Some v -> c = Sconst v.
Proof. intros c v H. destruct c; cbn in H; congruence. Qed.

Lemma select_switch_notin : forall n sl, ~ In n (sw_labels sl) ->
  select_switch n sl = select_switch_default sl.
Proof.
  intros n sl N. unfold select_switch.
  assert (H : select_switch_case n sl = None).
  { induction sl as [| [c|] s0 sl' IH]; cbn [select_switch_case sw_labels] in *; [ reflexivity | | ].
    - destruct (zeq c n) as [-> | _]; [ exfalso; apply N; left; reflexivity | ].
      apply IH. intro I. apply N. right. exact I.
    - apply IH. exact N. }
  rewrite H. reflexivity.
Qed.

Lemma add_facts_nx : forall fs g, g_nx (add_facts g fs) = g_nx g.
Proof. induction fs as [|f fs IH]; intros g; [ reflexivity | cbn [add_facts fold_left]; apply (IH (add_fact g f)) ]. Qed.

Lemma add_facts_loc : forall fs g, g_loc (add_facts g fs) = g_loc g.
Proof. induction fs as [|f fs IH]; intros g; [ reflexivity | cbn [add_facts fold_left]; apply (IH (add_fact g f)) ]. Qed.

Lemma MMg_add_facts : forall E m fs g, MMg E m g ->
  (forall f, In f fs -> fact_nlt (g_nx g) f /\ fact_holds E f) -> MMg E m (add_facts g fs).
Proof.
  intros E m fs. induction fs as [|f fs IH]; intros g MM H; [ exact MM | ].
  cbn [add_facts fold_left]. apply (IH (add_fact g f)).
  - destruct (H f (or_introl eq_refl)) as [N F]. exact (MMg_add_fact E m g f MM N F).
  - intros f' I. exact (H f' (or_intror I)).
Qed.

Lemma sweq_holds : forall E n c i z b, den E c = Some (Vint i) -> sok n c ->
  0 <= z < Int.modulus -> b = Int.eq i (Int.repr z) ->
  fact_nlt n (Fbool (sweq c z) tint32 b) /\ fact_holds E (Fbool (sweq c z) tint32 b).
Proof.
  intros E n c i z b D S Z ->. split.
  - cbn. split; [ apply S | exact I ].
  - exists (Val.of_bool (Int.eq i (Int.repr z))). split.
    + cbn [den sweq]. rewrite D. reflexivity.
    + destruct (Int.eq i (Int.repr z)); reflexivity.
Qed.

Lemma labs_ok_in : forall l z, labs_ok l = true -> In z l -> 0 <= z < Int.modulus.
Proof.
  intros l z H I. unfold labs_ok in H. rewrite forallb_forall in H.
  specialize (H z I). apply andb_true_iff in H as [H1 H2].
  apply Z.leb_le in H1. apply Z.ltb_lt in H2. lia.
Qed.

Lemma PM_sw_out : forall E n gl tle m out p, PM E n gl tle m out p ->
  PM E n gl tle m (outcome_switch out) (sw_out p).
Proof.
  intros E n gl tle m out [[le' g'] so] R. cbn [sw_out].
  destruct R as (E' & X & MM' & T' & O & L & G). exists E'.
  split; [ exact X | split; [ exact MM' | split; [ exact T' | split; [ | auto ] ] ] ].
  apply out_match_switch. exact O.
Qed.

(* the contracts are sound: every execution of a contracted call is
   described by one of the contract's outcomes *)
Hypothesis xc_sound : forall id k args g cps fd E m vargs t m' vres,
  xc id = Some k -> k args g = Some cps -> sfun_lookup id = Some fd ->
  MMg E m g -> Forall2 (fun a v => den E a = Some v /\ sok (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m fd vargs t m' vres ->
  exists c, In c cps /\ CM E (g_nx g) (g_loc g) m' vres c.

Definition den_opq (v : val) (md : mode) : Prop :=
  match md with
  | By_value ((Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned) as ch) => Val.load_result ch v = v
  | _ => True
  end.

(* an opaque read of a non-pointer cell yields no pointer, and its
   load_result is itself *)
Lemma opq_val_old : forall e tle m a v, eval_expr ge e tle m a v -> opq_ok a = true ->
  val_old v /\ den_opq v (access_mode (typeof a)).
Proof.
  intros e tle m a v H O. unfold opq_ok in O. apply andb_true_iff in O as [OF O].
  assert (Hty : exists ch, access_mode (typeof a) = By_value ch /\ opq_ch ch = true /\
                (match a with Efield _ _ _ | Ederef _ _ => True | _ => False end)).
  { destruct a; cbn in O |- *; try discriminate O;
      destruct (access_mode t) eqn:AM; try discriminate O; eauto. }
  destruct Hty as (ch & AM & CH & SH). rewrite AM. cbn [den_opq].
  inversion H; subst; try (cbn in SH; contradiction).
  assert (BF : bf = Full).
  { destruct a; cbn in SH; try contradiction; match goal with L : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inversion L; subst end;
      try reflexivity; cbn [opq_full] in OF;
      match goal with T : typeof _ = _ |- _ => rewrite T in OF end; try discriminate OF;
      match goal with C : (genv_cenv ge) ! _ = Some _ |- _ => rewrite C in OF end;
      match goal with F : field_offset _ _ _ = OK _ |- _ => rewrite F in OF end;
      destruct bf; [reflexivity | discriminate OF]. }
  subst bf.
  match goal with D : deref_loc _ _ _ _ _ _ |- _ => inversion D; subst end; try congruence.
  match goal with A : access_mode _ = By_value _, L : Mem.loadv _ _ _ = Some _ |- _ =>
    rewrite AM in A; injection A as <-; cbn [Mem.loadv] in L end.
  split.
  - destruct v; cbn; auto. exfalso.
    destruct ch; try discriminate CH;
      match goal with L : Mem.load _ _ _ _ = Some _ |- _ =>
        first [ apply Mem.load_cast in L; cbn in L; discriminate L
              | apply Mem.load_type in L; cbn in L; exact L ] end.
  - destruct ch; try discriminate CH; try exact I;
      match goal with L : Mem.load _ _ _ _ = Some _ |- _ => apply Mem.load_cast in L; cbn in L end;
      destruct v; cbn in *; try reflexivity; try discriminate; congruence.
Qed.

Lemma opq_term_den : forall E k v md, e_rho E k = Some v -> den_opq v md ->
  den E (match md with
         | By_value ((Mint8signed | Mint8unsigned | Mint16signed | Mint16unsigned) as ch) => Sldres ch (Sfresh k)
         | _ => Sfresh k end) = Some v.
Proof.
  intros E k v md R D.
  destruct md as [[] | | |]; cbn [den den_opq] in D |- *; rewrite R; try reflexivity; rewrite D; reflexivity.
Qed.

Ltac pm_here E :=
  exists E; split; [ apply Ext_refl | ];
  split; [ assumption | split; [ assumption | split; [ cbn; auto | split; [ apply Ple_refl | reflexivity ] ] ] ].

Theorem sx_sound : forall fuel,
  (forall se le g s ps E e tle m t tle' m' out,
     sx_stmt fuel se le g s = Some ps -> MMg E m g -> env_match E (g_loc g) se e ->
     temps_ok E (g_nx g) tle le ->
     exec_stmt function_entry2 ge e tle m s t tle' m' out ->
     exists p, In p ps /\ PM E (g_nx g) (g_loc g) tle' m' out p)
  /\ (forall se st s1 s2 ps E0 n0 gl e tle m t tle' m' out,
     sx_loop fuel se st s1 s2 = Some ps -> env_match E0 gl se e -> (forall r, In r gl -> Plt r n0) ->
     (exists p, In p st /\ PM E0 n0 gl tle m Out_normal p) ->
     exec_stmt function_entry2 ge e tle m (Sloop s1 s2) t tle' m' out ->
     exists q, In q ps /\ PM E0 n0 gl tle' m' out q)
  /\ (forall g fd args cps E m vargs t m' vres,
     sx_call fuel g fd args = Some cps -> MMg E m g ->
     Forall2 (fun a v => den E a = Some v /\ sok (g_nx g) a) args vargs ->
     eval_funcall function_entry2 ge m fd vargs t m' vres ->
     exists c, In c cps /\ CM E (g_nx g) (g_loc g) m' vres c).
Proof.
  induction fuel as [|fuel IH]; [ split; [ | split ]; intros; discriminate | ].
  destruct IH as (IHs & IHl & IHc).
  split; [ | split ].
  (* ============ statements ============ *)
  - intros se le g s ps E e tle m t tle' m' out Hs MM EM TM Hx.
    destruct s; simpl sx_stmt in Hs; try discriminate.
    + (* Sskip *)
      inv Hs. inv Hx. eexists; split; [ left; reflexivity | ]. pm_here E.
    + (* Sassign *)
      destruct (sx_lvalue se le g e0) as [l|] eqn:El; [ | discriminate ].
      destruct (sx_expr se le g e1) as [v2s|] eqn:Ev; [ | discriminate ].
      destruct (access_mode (typeof e0)) as [ch| | | ] eqn:AM; try discriminate.
      destruct l as [r o | q k]; try discriminate.
      destruct (mk_cast v2s (typeof e1) (typeof e0)) as [c|] eqn:Ec; [ | discriminate ].
      destruct (sstore g r (Ptrofs.unsigned o) ch c) as [g'|] eqn:Ss; [ | discriminate ].
      inv Hs. inv Hx.
      match goal with
      | HL : eval_lvalue _ _ _ _ e0 _ _ _, HE : eval_expr _ _ _ _ e1 _,
        HC : sem_cast _ _ _ _ = Some _, HA : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        destruct (sx_lvalue_sound E _ g se le e _ MM EM TM _ _ _ _ _ HL El) as (LD & _ & ->);
        destruct (sx_expr_sound E _ g se le e _ MM EM TM _ _ _ HE Ev) as [D2 S2];
        destruct (mk_cast_sound E _ g MM _ _ _ _ _ _ D2 S2 HC Ec) as [D3 S3];
        pose proof (cast_val_is_casted _ _ _ _ _ HC) as VC;
        inversion HA as [vv ch' mm AM' ST | | ]; subst; [ | congruence ];
        rewrite AM in AM'; injection AM' as <-; cbn [Mem.storev] in ST
      end.
      cbn in LD. inv LD.
      assert (IB : inb g r (Ptrofs.unsigned o) ch = true)
        by (unfold sstore in Ss; destruct (inb _ _ _ _); [ reflexivity | discriminate ]).
      rewrite (addr_ptrofs _ _ _ _ _ _ MM IB) in ST.
      destruct (sstore_sound _ _ _ _ _ _ _ _ _ _ MM Ss S3 D3
                  (SimplLocalsproof.val_casted_load_result _ _ _ VC AM) ST) as (MM' & NX & LC & _).
      eexists; split; [ left; reflexivity | ].
      exists E. split; [ apply Ext_refl | split; [ exact MM' | split; [ rewrite NX; exact TM | ] ] ].
      split; [ cbn; auto | split; [ rewrite NX; apply Ple_refl | exact LC ] ].
    + (* Sset *)
      destruct (nullx le e0) eqn:NX0.
      { exfalso. inv Hx. eapply (proj1 (nullx_sound E _ e _ le _ TM e0 NX0)); eassumption. }
      destruct (sx_expr se le g e0) as [vs|] eqn:Ev.
      { inv Hs. inv Hx.
        match goal with HE : eval_expr _ _ _ _ e0 _ |- _ =>
          destruct (sx_expr_sound E _ g se le e _ MM EM TM _ _ _ HE Ev) as [D S] end.
        eexists; split; [ left; reflexivity | ].
        exists E. split; [ apply Ext_refl | split; [ exact MM | split; [ apply temps_ok_set; auto | ] ] ].
        split; [ cbn; auto | split; [ apply Ple_refl | reflexivity ] ]. }
      destruct (opq_ok e0) eqn:OQ; [ | discriminate ]. inv Hs. inv Hx.
      match goal with HE : eval_expr _ _ _ _ e0 ?v |- _ =>
        destruct (opq_val_old _ _ _ _ _ HE OQ) as [VO DO]; rename v into vv end.
      eexists; split; [ left; reflexivity | ].
      exists (upd E (g_nx g) (Some vv)).
      unfold gfresh; cbn [g_nx g_loc].
      split; [ apply Rx_Ext, Rx_upd | ].
      split; [ apply (MMg_fresh E _ g vv MM VO) | ].
      split.
      { apply temps_ok_set.
        - eapply temps_ok_ext; [ exact TM | apply Rx_Ext, Rx_upd | apply Ple_succ ].
        - unfold opq_term. apply opq_term_den; [ cbn; destruct (Pos.eq_dec (g_nx g) (g_nx g)); [ reflexivity | congruence ] | exact DO ].
        - unfold opq_term. destruct (access_mode (typeof e0)) as [[] | | |];
            split; cbn; try apply Plt_succ; exact I. }
      split; [ cbn; auto | split; [ apply Ple_succ | reflexivity ] ].
    + (* Scall *)
      destruct e0; try discriminate.
      destruct t0 as [ | | | | | | targs tres cc | | ]; try discriminate.
      destruct (se ! i) eqn:Si; [ discriminate | ].
      destruct (sfun_lookup i) as [fd|] eqn:Fl; [ | discriminate ].
      destruct (type_eq (type_of_fundef fd) (Tfunction targs tres cc)); [ | discriminate ].
      destruct (undef_stuck le l targs) eqn:US.
      { exfalso. inv Hx.
        match goal with HCF : classify_fun _ = fun_case_f _ _ _ |- _ => cbn in HCF; inv HCF end.
        refine (undef_stuck_sound _ _ _ _ _ _ _ _ _ TM US _). eassumption. }
      destruct (sx_exprlist se le g l targs) as [sargs|] eqn:Ea; [ | discriminate ].
      destruct (match xc i with Some k => k sargs g | None => sx_call fuel g fd sargs end)
        as [cps0|] eqn:Ec0; [ | discriminate ].
      destruct (if mergef i then jgroup_c cps0 else Some cps0) as [cps|] eqn:Ec; [ | discriminate ].
      inv Hs.
      assert (Ei : e ! i = None) by (specialize (EM i); rewrite Si in EM; destruct (e ! i) as [[]|]; [ contradiction | reflexivity ]).
      inv Hx.
      match goal with
      | HCF : classify_fun _ = fun_case_f _ _ _, HF : eval_expr _ _ _ _ _ ?vf,
        HL : eval_exprlist _ _ _ _ _ _ _, HFF : Genv.find_funct _ ?vf = Some _,
        HEV : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        cbn in HCF; inv HCF;
        destruct (eval_Evar_fun2 _ _ _ _ _ _ _ _ Ei HF) as (b & Hb & ->);
        rewrite Genv.find_funct_find_funct_ptr in HFF;
        assert (Fl' := Fl); unfold sfun_lookup in Fl'; rewrite Hb in Fl'; rewrite Fl' in HFF; inv HFF;
        pose proof (sx_exprlist_sound E _ g se le e _ MM EM TM _ _ _ _ HL Ea) as FA;
        rename HEV into HEV0
      end.
      assert (C0 : exists c, In c cps0 /\ CM E (g_nx g) (g_loc g) m' vres c).
      { destruct (xc i) as [k|] eqn:Xi.
        - eapply xc_sound; eauto.
        - eapply IHc; eauto. }
      assert (C1 : exists c, In c cps /\ CM E (g_nx g) (g_loc g) m' vres c).
      { destruct C0 as [c [Ic Hc]]. destruct (mergef i).
        - eapply jgroup_c_cover; eauto.
        - inv Ec. eauto. }
      destruct C1 as [[g' r] [Ic (E' & X & MM' & Dr & Sr & L & G)]].
      exists (sset_opt o r le, g', SOnormal). split.
      * apply in_map_iff. exists (g', r). split; auto.
      * exists E'. split; [ exact X | split; [ exact MM' | split; [ | split; [ cbn; auto | auto ] ] ] ].
        assert (TM' : temps_ok E' (g_nx g') tle le) by (eapply temps_ok_ext; eauto).
        destruct o; cbn [set_opttemp sset_opt]; auto. apply temps_ok_set; auto.
    + (* Ssequence *)
      destruct (sx_stmt fuel se le g s1) as [ps1|] eqn:E1; [ | discriminate ].
      inv Hx.
      * (* s1 normal *)
        match goal with
        | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ Out_normal, H2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
          destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ E1 MM EM TM H1) as (p1 & In1 & PM1)
        end.
        destruct p1 as [[sl1 sg1] so1]. destruct PM1 as (E1' & X1 & MM1 & TM1 & O1 & L1 & G1).
        destruct so1; cbn in O1; try contradiction.
        destruct (oflat_in _ _ _ _ Hs In1) as (rx & Fx & Inc). cbv beta iota in Fx.
        assert (EM1 : env_match E1' (g_loc sg1) se e).
        { rewrite G1. eapply env_match_ext; eauto. intros r I. eapply MM_loc_lt; eauto. }
        match goal with H2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
          destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ Fx MM1 EM1 TM1 H2) as (p2 & In2 & PM2) end.
        exists p2. split; [ apply Inc; exact In2 | ]. rewrite G1 in PM2. eapply PM_trans; eauto.
      * (* s1 abrupt *)
        match goal with
        | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, HN : ?o <> Out_normal |- _ =>
          destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ E1 MM EM TM H1) as (p1 & In1 & PM1); rename HN into HN0
        end.
        destruct (oflat_in _ _ _ _ Hs In1) as (rx & Fx & Inc).
        exists p1. split; [ | exact PM1 ].
        apply Inc. destruct p1 as [[sl1 sg1] so1].
        destruct so1; cbv beta iota in Fx; try (inv Fx; left; reflexivity).
        destruct PM1 as (Ex & _ & _ & _ & O1 & _).
        destruct out as [ | | | [[? ?]|]]; cbn in O1; try contradiction.
    + (* Sifthenelse *)
      destruct (sx_expr se le g e0) as [c|] eqn:Ec; [ | discriminate ].
      inv Hx.
      match goal with
      | HE : eval_expr _ _ _ _ e0 _, HB : bool_val _ _ _ = Some _,
        HX : exec_stmt _ _ _ _ _ (if _ then _ else _) _ _ _ _ |- _ =>
        rename HE into HE0; rename HB into HB0; rename HX into HX0
      end.
      destruct (sx_expr_sound E _ g se le e _ MM EM TM _ _ _ HE0 Ec) as [Dc Sc].
      destruct (decide (g_pc g) c (typeof e0)) as [b'|] eqn:Dd.
      * rewrite (decide_sound E _ g MM _ _ _ _ _ Dc Sc HB0 Dd) in Hs.
        exact (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ Hs MM EM TM HX0).
      * destruct (loc_ptr c) eqn:LP; [ discriminate | ].
        destruct (sx_stmt fuel se le (add_fact g (Fbool c (typeof e0) true)) s1) as [p1|] eqn:P1;
          [ | discriminate ].
        destruct (sx_stmt fuel se le (add_fact g (Fbool c (typeof e0) false)) s2) as [p2|] eqn:P2;
          [ | discriminate ].
        inv Hs.
        match type of HB0 with
        | bool_val ?v1 _ _ = Some ?b =>
          destruct (split_fact_sound E _ g MM c (typeof e0) v1 b Dc Sc LP HB0) as [FN FH];
          pose proof (MMg_add_fact E _ g _ MM FN FH) as MMb;
          destruct b
        end.
        -- destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P1 MMb EM TM HX0) as (p & Hin & R).
           exists p. split; [ apply in_or_app; left; exact Hin | exact R ].
        -- destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P2 MMb EM TM HX0) as (p & Hin & R).
           exists p. split; [ apply in_or_app; right; exact Hin | exact R ].
    + (* Sloop *)
      eapply IHl; eauto.
      * intros r I. eapply MM_loc_lt; eauto.
      * eexists; split; [ left; reflexivity | ]. pm_here E.
    + (* Sbreak *)
      inv Hs. inv Hx. eexists; split; [ left; reflexivity | ]. pm_here E.
    + (* Scontinue *)
      inv Hs. inv Hx. eexists; split; [ left; reflexivity | ]. pm_here E.
    + (* Sreturn *)
      match type of Hx with exec_stmt _ _ _ _ _ (Sreturn ?x) _ _ _ _ => destruct x as [a|] end.
      * destruct (sx_expr se le g a) as [vs|] eqn:Ev; [ | discriminate ]. inv Hs. inv Hx.
        match goal with HE : eval_expr _ _ _ _ a _ |- _ =>
          destruct (sx_expr_sound E _ g se le e _ MM EM TM _ _ _ HE Ev) as [D S] end.
        eexists; split; [ left; reflexivity | ].
        exists E. split; [ apply Ext_refl | split; [ exact MM | split; [ exact TM | ] ] ].
        split; [ cbn; auto | split; [ apply Ple_refl | reflexivity ] ].
      * inv Hs. inv Hx. eexists; split; [ left; reflexivity | ]. pm_here E.
    + (* Sswitch *)
      destruct (sx_expr se le g e0) as [c|] eqn:Ec; [ | discriminate ].
      inv Hx.
      match goal with
      | HE : eval_expr _ _ _ _ e0 _, HS : sem_switch_arg _ _ = Some _,
        HX : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ =>
        destruct (sx_expr_sound E _ g se le e _ MM EM TM _ _ _ HE Ec) as [D Sc];
        rename HS into HS0; rename HX into HX0
      end.
      destruct (sw_const c) as [v'|] eqn:SC.
      * apply sw_const_some in SC. subst c. cbn [den] in D. injection D as <-.
        rewrite HS0 in Hs.
        match type of Hs with
        | (match ?X with Some _ => _ | None => _ end) = _ => destruct X as [ps1|] eqn:P1; [ | discriminate ]
        end.
        inv Hs.
        destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P1 MM EM TM HX0) as (p & Hin & R).
        exists (sw_out p). split; [ apply in_map; exact Hin | apply PM_sw_out; exact R ].
      * destruct (is_tint (typeof e0) && labs_ok (sw_labels l)) eqn:T; [ | discriminate ].
        apply andb_true_iff in T as [T1 T2].
        match type of Hs with
        | (match oflat ?F _ with Some _ => _ | None => _ end) = _ =>
            destruct (oflat F (sw_labels l)) as [ps1|] eqn:P1; [ | discriminate ]
        end.
        match type of Hs with
        | (match ?X with Some _ => _ | None => _ end) = _ => destruct X as [ps2|] eqn:P2; [ | discriminate ]
        end.
        inv Hs.
        destruct (typeof e0) eqn:TY; try discriminate T1.
        match type of HS0 with sem_switch_arg ?v _ = Some ?nn =>
          destruct v as [ | i0 | | | | ]; try discriminate HS0; cbn in HS0; injection HS0 as <-
        end.
        assert (FIN : forall tl mm oo p, In p (ps1 ++ ps2) -> PM E (g_nx g) (g_loc g) tl mm oo p ->
                  exists q, In q (map sw_out (ps1 ++ ps2))
                            /\ PM E (g_nx g) (g_loc g) tl mm (outcome_switch oo) q).
        { intros tl mm oo p I R. exists (sw_out p). split; [ apply in_map; exact I | apply PM_sw_out; exact R ]. }
        destruct (in_dec Z.eq_dec (Int.unsigned i0) (sw_labels l)) as [IN | NIN].
        -- destruct (oflat_in _ _ _ _ P1 IN) as (rx & Fx & Inc).
           destruct (sweq_holds E (g_nx g) c i0 (Int.unsigned i0) true D Sc (labs_ok_in _ _ T2 IN))
             as [FN FH]; [ rewrite Int.repr_unsigned, Int.eq_true; reflexivity | ].
           pose proof (MMg_add_fact E _ g _ MM FN FH) as MMb.
           destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ Fx MMb EM TM HX0) as (p & Hin & R).
           eapply FIN; [ apply in_or_app; left; apply Inc; exact Hin | exact R ].
        -- rewrite (select_switch_notin _ _ NIN) in HX0.
           assert (MMb : MMg E m (add_facts g (map (fun z => Fbool (sweq c z) tint32 false) (sw_labels l)))).
           { apply MMg_add_facts; [ exact MM | ].
             intros f If. apply in_map_iff in If. destruct If as (z & <- & Iz).
             apply (sweq_holds E (g_nx g) c i0 z false D Sc (labs_ok_in _ _ T2 Iz)).
             symmetry. apply Int.eq_false. intro Eq. apply NIN. subst i0.
             rewrite Int.unsigned_repr; [ exact Iz | ].
             pose proof (labs_ok_in _ _ T2 Iz). unfold Int.max_unsigned. lia. }
           assert (EMb : env_match E (g_loc (add_facts g (map (fun z => Fbool (sweq c z) tint32 false) (sw_labels l)))) se e)
             by (rewrite add_facts_loc; exact EM).
           assert (TMb : temps_ok E (g_nx (add_facts g (map (fun z => Fbool (sweq c z) tint32 false) (sw_labels l)))) tle le)
             by (rewrite add_facts_nx; exact TM).
           destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P2 MMb EMb TMb HX0) as (p & Hin & R).
           rewrite add_facts_nx, add_facts_loc in R.
           eapply FIN; [ apply in_or_app; right; exact Hin | exact R ].
  (* ============ loops ============ *)
  - intros se st s1 s2 ps E0 n0 gl e tle m t tle' m' out Hl EM LT (p & Ip & Pp) Hx.
    simpl sx_loop in Hl. destruct st as [|p0 st']; [ destruct Ip | ].
    match type of Hl with
    | match oflat ?F _ with _ => _ end = _ => set (fbody := F) in Hl
    end.
    destruct (oflat fbody (p0 :: st')) as [rs|] eqn:Ers; [ | discriminate ].
    destruct (sx_loop fuel se (if jloops then jgroup (lbacks rs) else lbacks rs) s1 s2) as [more|] eqn:Em;
      [ | discriminate ].
    inv Hl.
    assert (FIN : forall q, In q (lexits rs ++ more) -> PM E0 n0 gl tle' m' out q ->
              exists q', In q' (if jloops then jgroup (lexits rs ++ more) else lexits rs ++ more)
                         /\ PM E0 n0 gl tle' m' out q').
    { intros q I H. destruct jloops; [ eapply jgroup_PM; eauto | eauto ]. }
    assert (EXIT : forall q, In (inl q) rs -> PM E0 n0 gl tle' m' out q ->
              exists q', In q' (if jloops then jgroup (lexits rs ++ more) else lexits rs ++ more)
                         /\ PM E0 n0 gl tle' m' out q').
    { intros q I H. apply (FIN q); [ | exact H ]. apply in_or_app. left.
      unfold lexits. apply in_flat_map. exists (inl q). split; [ exact I | left; reflexivity ]. }
    destruct (oflat_in _ _ _ _ Ers Ip) as (rp & Fp & Incp).
    destruct p as [[le g] so]. destruct Pp as (E & X & MM & TM & _ & L0 & G0).
    unfold fbody in Fp. cbv beta iota in Fp.
    destruct (sx_stmt fuel se le g s1) as [ps1|] eqn:P1; [ | discriminate ].
    assert (EM1 : env_match E (g_loc g) se e) by (rewrite G0; eapply env_match_ext; eauto).
    assert (STEP1 : forall t1 tle1 m1 out1, exec_stmt function_entry2 ge e tle m s1 t1 tle1 m1 out1 ->
              exists p1, In p1 ps1 /\ PM E0 n0 gl tle1 m1 out1 p1).
    { intros t1 tle1 m1 out1 H1.
      destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P1 MM EM1 TM H1) as (p1 & I1 & PM1).
      exists p1. split; [ exact I1 | ]. rewrite G0 in PM1. eapply PM_trans; eauto. }
    inv Hx.
    + (* stop1: s1 breaks or returns *)
      match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o1, HB : out_break_or_return ?o1 _ |- _ =>
        destruct (STEP1 _ _ _ _ H1) as ([[sl1 sg1] so1] & I1 & (E1 & X1 & MM1 & TM1 & O1 & L1 & G1));
        destruct (oflat_in _ _ _ _ Fp I1) as (r1 & F1 & Inc1); inv HB end.
      * destruct so1; cbn in O1; try contradiction. cbv beta iota in F1. inv F1.
        eapply EXIT. apply Incp, Inc1. left; reflexivity.
        exists E1. auto 10.
      * destruct so1 as [ | | | ov1]; cbn in O1; try (destruct ov as [[? ?]|]; cbn in *; contradiction). cbv beta iota in F1. inv F1.
        eapply EXIT. apply Incp, Inc1. left; reflexivity.
        exists E1. auto 10.
    + (* stop2: s1 normal/continue, s2 breaks or returns *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o1, HN : out_normal_or_continue ?o1,
        H2 : exec_stmt _ _ _ _ _ s2 _ _ _ ?o2, HB : out_break_or_return ?o2 _ |- _ =>
        destruct (STEP1 _ _ _ _ H1) as ([[sl1 sg1] so1] & I1 & (E1 & X1 & MM1 & TM1 & O1 & L1 & G1));
        destruct (oflat_in _ _ _ _ Fp I1) as (r1 & F1 & Inc1);
        rename H2 into H20; rename HB into HB0; rename HN into HN0
      end.
      assert (EM2 : env_match E1 (g_loc sg1) se e) by (rewrite G1; exact (env_match_ext _ _ _ _ _ _ EM X1 LT)).
      assert (F1' : sx_stmt fuel se sl1 sg1 s2 = None \/ exists ps2, sx_stmt fuel se sl1 sg1 s2 = Some ps2
                     /\ r1 = flat_map (fun q : spath => let '(sl2, sg2, o2) := q in
                          match o2 with
                          | SOnormal => [inr q] | SObreak => [inl (sl2, sg2, SOnormal)]
                          | SOreturn _ => [inl q] | SOcontinue => nil end) ps2).
      { inv HN0; destruct so1; cbn in O1; try contradiction; cbv beta iota in F1;
          destruct (sx_stmt fuel se sl1 sg1 s2); inv F1; eauto. }
      destruct F1' as [F1' | (ps2 & P2 & ->)].
      { exfalso. inv HN0; destruct so1; cbn in O1; try contradiction; cbv beta iota in F1;
          rewrite F1' in F1; discriminate. }
      destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P2 MM1 EM2 TM1 H20) as ([[sl2 sg2] so2] & I2 & PM2).
      rewrite G1 in PM2. pose proof (PM_trans _ _ _ _ _ _ _ _ _ PM2 X1 L1) as PM2'.
      destruct PM2' as (E2 & X2 & MM2 & TM2 & O2 & L2 & G2).
      inv HB0.
      * destruct so2; cbn in O2; try contradiction.
        eapply EXIT; [ apply Incp, Inc1, in_flat_map; exists (sl2, sg2, SObreak); split; [ exact I2 | left; reflexivity ] | ].
        exists E2. auto 10.
      * destruct so2 as [ | | | ov2]; cbn in O2; try (destruct ov as [[? ?]|]; cbn in *; contradiction).
        eapply EXIT; [ apply Incp, Inc1, in_flat_map; exists (sl2, sg2, SOreturn ov2); split; [ exact I2 | left; reflexivity ] | ].
        exists E2. auto 10.
    + (* loop: another round *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o1, HN : out_normal_or_continue ?o1,
        H2 : exec_stmt _ _ _ _ _ s2 _ _ _ Out_normal,
        H3 : exec_stmt _ _ _ _ _ (Sloop s1 s2) _ _ _ _ |- _ =>
        destruct (STEP1 _ _ _ _ H1) as ([[sl1 sg1] so1] & I1 & (E1 & X1 & MM1 & TM1 & O1 & L1 & G1));
        destruct (oflat_in _ _ _ _ Fp I1) as (r1 & F1 & Inc1);
        rename H2 into H20; rename H3 into H30; rename HN into HN0
      end.
      assert (EM2 : env_match E1 (g_loc sg1) se e) by (rewrite G1; exact (env_match_ext _ _ _ _ _ _ EM X1 LT)).
      assert (F1' : sx_stmt fuel se sl1 sg1 s2 = None \/ exists ps2, sx_stmt fuel se sl1 sg1 s2 = Some ps2
                     /\ r1 = flat_map (fun q : spath => let '(sl2, sg2, o2) := q in
                          match o2 with
                          | SOnormal => [inr q] | SObreak => [inl (sl2, sg2, SOnormal)]
                          | SOreturn _ => [inl q] | SOcontinue => nil end) ps2).
      { inv HN0; destruct so1; cbn in O1; try contradiction; cbv beta iota in F1;
          destruct (sx_stmt fuel se sl1 sg1 s2); inv F1; eauto. }
      destruct F1' as [F1' | (ps2 & P2 & ->)].
      { exfalso. inv HN0; destruct so1; cbn in O1; try contradiction; cbv beta iota in F1;
          rewrite F1' in F1; discriminate. }
      destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ P2 MM1 EM2 TM1 H20) as ([[sl2 sg2] so2] & I2 & PM2).
      rewrite G1 in PM2. pose proof (PM_trans _ _ _ _ _ _ _ _ _ PM2 X1 L1) as PM2'.
      assert (so2 = SOnormal) by (destruct PM2' as (Ex & _ & _ & _ & O2 & _); destruct so2; cbn in O2; tauto).
      subst so2.
      assert (IB : In (sl2, sg2, SOnormal) (lbacks rs)).
      { unfold lbacks. apply in_flat_map. exists (inr (sl2, sg2, SOnormal)). split; [ | left; reflexivity ].
        apply Incp, Inc1, in_flat_map. exists (sl2, sg2, SOnormal). split; [ exact I2 | left; reflexivity ]. }
      match type of H30 with exec_stmt _ _ _ ?tl ?mm _ _ _ _ _ =>
        assert (IB' : exists q, In q (if jloops then jgroup (lbacks rs) else lbacks rs)
                                /\ PM E0 n0 (g_loc g) tl mm Out_normal q)
          by (destruct jloops; [ eapply jgroup_PM; eauto | eauto ]) end.
      destruct (IHl _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Em EM LT IB' H30) as (q & Iq & Pq).
      apply (FIN q); [ apply in_or_app; right; exact Iq | exact Pq ].
  (* ============ calls ============ *)
  - intros g fd args cps E m vargs t m' vres Hc MM FA Hx.
    destruct fd as [f|]; simpl sx_call in Hc; [ | discriminate ].
    destruct (list_norepet_dec _ _); [ | discriminate ].
    destruct (list_norepet_dec _ _); [ | discriminate ].
    destruct (list_disjoint_dec _ _ _); [ | discriminate ].
    destruct (salloc (fn_vars f) (PTree.empty _) g) as [se g1] eqn:Sa.
    destruct (sbind (fn_params f) args (sundef (fn_temps f))) as [le|] eqn:Eb; [ | discriminate ].
    destruct (sx_stmt fuel se le g1 (fn_body f)) as [ps|] eqn:Ep; [ | discriminate ].
    inv Hx.
    match goal with
    | HE : function_entry2 _ _ _ _ _ _ _, HB : exec_stmt _ _ _ _ _ _ _ _ _ _,
      HR : outcome_result_value _ _ _ _, HF : Mem.free_list _ _ = Some _ |- _ =>
      inversion HE as [N1 N2 N3 HA HBd]; subst;
      rename HB into HB0; rename HR into HR0; rename HF into HF0
    end.
    assert (EM0 : env_match E (g_loc g) (PTree.empty _) empty_env)
      by (intros id; rewrite !PTree.gempty; exact I).
    destruct (salloc_sound _ _ _ _ _ _ _ _ _ _ Sa HA MM EM0)
      as (E1 & newl & X1 & MM1 & EM1 & L1 & G1 & NW & SE).
    match type of HBd with _ = Some ?tl =>
      assert (TM1 : temps_ok E1 (g_nx g1) tl le)
        by (eapply sbind_ok; [ eapply Forall2_den_ext; eauto | apply sundef_ok | exact Eb | exact HBd ]) end.
    destruct (IHs _ _ _ _ _ _ _ _ _ _ _ _ _ Ep MM1 EM1 TM1 HB0)
      as ([[le' g2] so] & Hin & (E2 & X2 & MM2 & TM2 & O & L2 & G2)).
    destruct (omap_in _ _ _ _ Hc Hin) as (y & Fy & Iy). cbv beta iota in Fy.
    destruct (sresult so (fn_return f)) as [r|] eqn:Sr; [ | discriminate ]. inv Fy.
    destruct (sresult_sound E2 _ g2 _ _ _ _ _ MM2 O Sr HR0) as [Dr Srk].
    exists (sfree (g_loc g) g2, r). split; [ exact Iy | ].
    exists E2. split; [ eapply Ext_trans; [ exact X1 | exact X2 | exact L1 ] | ].
    split; [ | split; [ exact Dr | split; [ exact Srk | split; [ eapply Ple_trans; eauto | reflexivity ] ] ] ].
    eapply sfree_sound; [ exact MM2 | | exact HF0 | ].
    + rewrite G2, G1. intros x Ix. apply in_or_app. right. exact Ix.
    + intros b lo hi Ib. destruct (blocks_of_env_in _ _ _ _ Ib) as (id & ty & Eid).
      specialize (EM1 id). rewrite Eid in EM1.
      destruct (se ! id) as [[r0 ty0]|] eqn:Sid; [ | contradiction ].
      destruct EM1 as (-> & _ & Ir0). exists r0.
      destruct (SE id r0 ty0 Sid) as [Hn | Hn]; [ rewrite PTree.gempty in Hn; discriminate | ].
      split; [ rewrite G2; exact Ir0 | split ].
      * intro Ig. pose proof (MM_loc_lt _ _ _ _ MM Ig). pose proof (NW r0 Hn).
        unfold Plt, Ple in *. lia.
      * pose proof (MM_loc_lt _ _ _ _ MM1 Ir0) as P. destruct (X2 r0 P) as (B & _). auto.
Qed.

Corollary sx_call_sound : forall fuel g fd args cps E m vargs t m' vres,
  sx_call fuel g fd args = Some cps -> MMg E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m fd vargs t m' vres ->
  exists c, In c cps /\ CM E (g_nx g) (g_loc g) m' vres c.
Proof. intros fuel. exact (proj2 (proj2 (sx_sound fuel))). Qed.

(* the start: no writes, no locals, facts that hold at m0 *)
Lemma MMg_init : forall E pc nx, env_ok E -> Ple nbase nx ->
  (forall f, In f pc -> fact_nlt nx f /\ fact_holds E f) ->
  MMg E m0 (mkg nil pc nx nil nil).
Proof.
  intros E pc nx EO L PC. unfold MMg; cbn [g_nx g_loc g_sm g_pc].
  split; [ exact EO | split; [ exact L | split; [ intros r o ch sv [] | split; [ intros; reflexivity | ] ] ] ].
  split; [ intros b o k p _; reflexivity | split; [ apply Ple_refl | split; [ exact PC | ] ] ].
  split; [ intros r [] | intros r r' [] ].
Qed.

End SYMEX.
