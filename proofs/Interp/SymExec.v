(* kept: general tool -- a path-splitting SYMBOLIC executor for CompCert Clight,
   PROVED TO COVER every big-step execution (ClightBigstep, function_entry2).
   First Coq slice of the GOAL-2 value walk (docs/goal2-value-walk-plan.md §4);
   its first consumer is WMotRRequiresA/Unwired/GravitySlice.v. *)

(* Design.
   - A symbolic value [sval] is a term over the INITIAL memory [m0]: constants,
     region pointers [Sptr r o] (region r is the block [sigma r]), initial cells
     [Sinit r o ch] (= Mem.load ch m0 (sigma r) o), and the Clight operators.
     Its meaning [den] never looks at the CURRENT memory: operators are
     evaluated at m0.  That is sound because the executor supports only stores
     (no alloc/free yet), which keep every valid_pointer answer, so
     [vp_agree m] holds along the run and the Cop injection lemmas transfer
     each operator from m to m0 exactly.
   - The symbolic memory is a list of written cells.  A load of an unwritten
     cell is [Sinit]; a load of a written cell must match it exactly (else the
     run is refused).  [frame] says every unwritten cell still holds its m0
     value.
   - Branches on an undecided condition FORK and record a path condition
     [(c, ty, b)] meaning bool_val (den c) ty m0 = Some b.  Constants and
     conditions already on the path are decided without forking.
   - Constant operators are FOLDED by evaluating them in [Mem.empty]; a result
     there is the result in any memory (Cop's generic injection lemmas, whose
     validity premises are vacuous in Mem.empty).  Pointer + int on a region
     pointer folds the same way through a dummy block.
   - [None] means the executor refused (unsupported construct, local
     variables, externals, loops, fuel).  Only a [Some] run carries meaning.

   THE THEOREM ([sx_call_sound]): if the executor returns paths [cps] for a
   call, then EVERY big-step execution of that call from a memory matching
   the symbolic start ends in a memory described by one of the paths.  This
   is the direction a proof about the real program needs: the paths cover
   the program, so a property of every path is a property of every run. *)

From Coq Require Import String List Lia.
From compcert Require Import Coqlib Errors Maps Integers Floats Values AST Memory
  Events Globalenvs Ctypes Cop Clight ClightBigstep.
Import ListNotations.

Local Notation "'let?' x := a 'in' b" :=
  (match a with Some x => b | None => None end)
  (at level 200, x ident, a at level 100, b at level 200).

(* ---------------------------------------------------------------- *)
(* Symbolic values                                                    *)
(* ---------------------------------------------------------------- *)

Inductive sval : Type :=
  | Sconst (v : val)
  | Sptr (r : positive) (ofs : ptrofs)
  | Sinit (r : positive) (ofs : Z) (ch : memory_chunk)
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

(* symbolic memory: written cells (region, offset, chunk, value) *)
Definition sentry : Type := (positive * Z * memory_chunk * sval)%type.
Definition smem : Type := list sentry.
(* path conditions: bool_val (den c) ty m0 = Some b *)
Definition spc : Type := list (sval * type * bool).

Definition ovl (r : positive) (o : Z) (ch : memory_chunk) (e : sentry) : bool :=
  let '(r', o', ch', _) := e in
  Pos.eqb r r' && Z.ltb o (o' + size_chunk ch') && Z.ltb o' (o + size_chunk ch).

Definition exact (r : positive) (o : Z) (ch : memory_chunk) (e : sentry) : bool :=
  let '(r', o', ch', _) := e in
  Pos.eqb r r' && Z.eqb o o' && (if chunk_eq ch ch' then true else false).

Definition sstore (sm : smem) (r : positive) (o : Z) (ch : memory_chunk) (v : sval)
    : option smem :=
  if forallb (fun e => negb (ovl r o ch e) || exact r o ch e) sm
  then Some ((r, o, ch, v) :: filter (fun e => negb (ovl r o ch e)) sm)
  else None.

Fixpoint pc_lookup (pc : spc) (c : sval) (ty : type) : option bool :=
  match pc with
  | nil => None
  | (a, t, b) :: pc' =>
      if sval_eq a c then if type_eq t ty then Some b else pc_lookup pc' c ty
      else pc_lookup pc' c ty
  end.

Inductive sout : Type :=
  | SOnormal | SObreak | SOcontinue | SOreturn (r : option (sval * type)).

Definition spath : Type := (PTree.t sval * smem * spc * sout)%type.
Definition cpath : Type := (smem * spc * sval)%type.

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

Lemma filter_nil_iff : forall {A : Type} (f : A -> bool) l,
  filter f l = nil <-> (forall x, In x l -> f x = false).
Proof.
  intros A f l. induction l as [|a l IH]; cbn; [ tauto | ].
  destruct (f a) eqn:Fa; split; intros H.
  - discriminate.
  - rewrite (H a (or_introl eq_refl)) in Fa. discriminate.
  - intros x [<- | Hx]; [ exact Fa | apply IH; auto ].
  - apply IH. intros x Hx. apply H. right. exact Hx.
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

Section SYMEX.

Variable ge : genv.

(* Known-zero bits of initial cells: (r, o, ch, mask) says the cell holds an
   int whose [mask] bits are 0.  This is how a premise such as "A is not held"
   (m->input & INPUT_A_DOWN == 0) enters the run: every [cell & k] with k
   inside the mask folds to 0, whatever cast or ! wraps it afterwards. *)
Variable kz : list (positive * Z * memory_chunk * int).

Definition known_zero (r : positive) (o : Z) (ch : memory_chunk) (k : int) : bool :=
  existsb (fun (x : positive * Z * memory_chunk * int) =>
             let '(r', o', ch', mask) := x in
             Pos.eqb r r' && Z.eqb o o' && (if chunk_eq ch ch' then true else false)
             && Int.eq (Int.and k (Int.not mask)) Int.zero) kz.

Definition is_tint (t : type) : bool := match t with Tint _ _ _ => true | _ => false end.

(* Known values of initial cells: (r, o, ch, v) says the cell holds v in m0
   (e.g. the action a frame starts in).  An unwritten known cell reads as the
   constant, so branches on it are decided instead of forked. *)
Variable kv : list (positive * Z * memory_chunk * val).

Definition init_cell (r : positive) (o : Z) (ch : memory_chunk) : sval :=
  match find (fun (x : positive * Z * memory_chunk * val) =>
                let '(r', o', ch', _) := x in
                Pos.eqb r r' && Z.eqb o o' && (if chunk_eq ch ch' then true else false)) kv with
  | Some (_, _, _, v) => Sconst v
  | None => Sinit r o ch
  end.

Definition sload (sm : smem) (r : positive) (o : Z) (ch : memory_chunk) : option sval :=
  match filter (ovl r o ch) sm with
  | nil => Some (init_cell r o ch)
  | e :: nil => if exact r o ch e then Some (snd e) else None
  | _ => None
  end.

(* ---------------------------------------------------------------- *)
(* Folding                                                            *)
(* ---------------------------------------------------------------- *)

Definition fold_ptr_res (r : positive) (res : option val) (dflt : sval) : sval :=
  match res with
  | Some (Vptr b o') => if eq_block b dummy_b then Sptr r o' else dflt
  | _ => dflt
  end.

Definition fold_bin (op : binary_operation) (a1 : sval) (t1 : type) (a2 : sval) (t2 : type)
    : sval :=
  let dflt := Sbinop op a1 t1 a2 t2 in
  match a1, a2 with
  | Sinit r o ch, Sconst (Vint k) =>
      match op with
      | Oand => if is_tint t1 && is_tint t2 && known_zero r o ch k
                then Sconst (Vint Int.zero) else dflt
      | _ => dflt
      end
  | Sconst v1, Sconst v2 =>
      match sem_binary_operation ge op v1 t1 v2 t2 Mem.empty with
      | Some v => if non_undef v then Sconst v else dflt
      | None => dflt
      end
  | Sptr r o, Sconst v2 =>
      if non_ptr v2
      then fold_ptr_res r (sem_binary_operation ge op (Vptr dummy_b o) t1 v2 t2 Mem.empty) dflt
      else dflt
  | Sconst v1, Sptr r o =>
      if non_ptr v1
      then fold_ptr_res r (sem_binary_operation ge op v1 t1 (Vptr dummy_b o) t2 Mem.empty) dflt
      else dflt
  | _, _ => dflt
  end.

Definition fold_un (op : unary_operation) (a : sval) (ty : type) : sval :=
  let dflt := Sunop op a ty in
  match a with
  | Sconst v =>
      match sem_unary_operation op v ty Mem.empty with
      | Some v' => if non_undef v' then Sconst v' else dflt
      | None => dflt
      end
  | _ => dflt
  end.

Definition fold_cast (a : sval) (t1 t2 : type) : sval :=
  let dflt := Scast a t1 t2 in
  match a with
  | Sconst v =>
      match sem_cast v t1 t2 Mem.empty with
      | Some v' => if non_undef v' then Sconst v' else dflt
      | None => dflt
      end
  | Sptr r o => fold_ptr_res r (sem_cast (Vptr dummy_b o) t1 t2 Mem.empty) dflt
  | _ => dflt
  end.

Definition fold_ldres (ch : memory_chunk) (a : sval) : sval :=
  match a with
  | Sconst v => Sconst (Val.load_result ch v)
  | _ => Sldres ch a
  end.

Definition decide (pc : spc) (c : sval) (ty : type) : option bool :=
  match c with
  | Sconst v => bool_val v ty Mem.empty
  | _ => pc_lookup pc c ty
  end.

(* ---------------------------------------------------------------- *)
(* Expressions                                                        *)
(* ---------------------------------------------------------------- *)

Definition sderef (ty : type) (sm : smem) (r : positive) (o : ptrofs) : option sval :=
  match access_mode ty with
  | By_value ch => sload sm r (Ptrofs.unsigned o) ch
  | By_reference | By_copy => Some (Sptr r o)
  | By_nothing => None
  end.

Definition sfield_loc (tya : type) (i : ident) (r : positive) (o : ptrofs)
    : option (positive * ptrofs) :=
  match tya with
  | Tstruct id _ =>
      match (genv_cenv ge) ! id with
      | Some co =>
          match field_offset ge i (co_members co) with
          | OK (delta, Full) => Some (r, Ptrofs.add o (Ptrofs.repr delta))
          | _ => None
          end
      | None => None
      end
  | Tunion id _ =>
      match (genv_cenv ge) ! id with
      | Some co =>
          match union_field_offset ge i (co_members co) with
          | OK (delta, Full) => Some (r, Ptrofs.add o (Ptrofs.repr delta))
          | _ => None
          end
      | None => None
      end
  | _ => None
  end.

Section SEXPR.
Variables (le : PTree.t sval) (sm : smem).

Fixpoint sx_expr (a : expr) : option sval :=
  match a with
  | Econst_int i _ => Some (Sconst (Vint i))
  | Econst_float f _ => Some (Sconst (Vfloat f))
  | Econst_single f _ => Some (Sconst (Vsingle f))
  | Econst_long i _ => Some (Sconst (Vlong i))
  | Etempvar id _ => le ! id
  | Eaddrof a1 _ =>
      match sx_lvalue a1 with Some (r, o) => Some (Sptr r o) | None => None end
  | Eunop op a1 _ => let? v1 := sx_expr a1 in Some (fold_un op v1 (typeof a1))
  | Ebinop op a1 a2 _ =>
      let? v1 := sx_expr a1 in
      let? v2 := sx_expr a2 in
      Some (fold_bin op v1 (typeof a1) v2 (typeof a2))
  | Ecast a1 ty => let? v1 := sx_expr a1 in Some (fold_cast v1 (typeof a1) ty)
  | Esizeof ty1 _ => Some (Sconst (Vptrofs (Ptrofs.repr (sizeof ge ty1))))
  | Ealignof ty1 _ => Some (Sconst (Vptrofs (Ptrofs.repr (alignof ge ty1))))
  | Evar _ _ => None
  | Ederef a1 ty =>
      match sx_expr a1 with Some (Sptr r o) => sderef ty sm r o | _ => None end
  | Efield a1 i ty =>
      match sx_expr a1 with
      | Some (Sptr r o) =>
          match sfield_loc (typeof a1) i r o with
          | Some (r', o') => sderef ty sm r' o'
          | None => None
          end
      | _ => None
      end
  end

with sx_lvalue (a : expr) : option (positive * ptrofs) :=
  match a with
  | Ederef a1 _ =>
      match sx_expr a1 with Some (Sptr r o) => Some (r, o) | _ => None end
  | Efield a1 i _ =>
      match sx_expr a1 with Some (Sptr r o) => sfield_loc (typeof a1) i r o | _ => None end
  | _ => None
  end.

Fixpoint sx_exprlist (al : list expr) (tyl : list type) : option (list sval) :=
  match al, tyl with
  | nil, nil => Some nil
  | a :: bl, ty :: tyl' =>
      let? v1 := sx_expr a in
      let? vl := sx_exprlist bl tyl' in
      Some (fold_cast v1 (typeof a) ty :: vl)
  | _, _ => None
  end.

End SEXPR.

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

Definition sresult (out : sout) (t : type) : option sval :=
  match out, t with
  | SOnormal, Tvoid => Some (Sconst Vundef)
  | SOreturn None, Tvoid => Some (Sconst Vundef)
  | SOreturn (Some (v, t')), ty => if type_eq ty Tvoid then None else Some (fold_cast v t' ty)
  | _, _ => None
  end.

Definition sset_opt (optid : option ident) (v : sval) (le : PTree.t sval) : PTree.t sval :=
  match optid with None => le | Some id => PTree.set id v le end.

Fixpoint sx_stmt (fuel : nat) (le : PTree.t sval) (sm : smem) (pc : spc) (s : statement)
    {struct fuel} : option (list spath) :=
  match fuel with
  | O => None
  | S fuel' =>
  match s with
  | Sskip => Some [(le, sm, pc, SOnormal)]
  | Sassign a1 a2 =>
      match sx_lvalue le sm a1 with
      | Some (r, o) =>
          let? v2 := sx_expr le sm a2 in
          match access_mode (typeof a1) with
          | By_value ch =>
              let? sm' := sstore sm r (Ptrofs.unsigned o) ch
                             (fold_ldres ch (fold_cast v2 (typeof a2) (typeof a1))) in
              Some [(le, sm', pc, SOnormal)]
          | _ => None
          end
      | None => None
      end
  | Sset id a => let? v := sx_expr le sm a in Some [(PTree.set id v le, sm, pc, SOnormal)]
  | Scall optid (Evar id (Tfunction tyargs tyres cconv)) al =>
      let? fd := sfun_lookup id in
      if type_eq (type_of_fundef fd) (Tfunction tyargs tyres cconv) then
        let? args := sx_exprlist le sm al tyargs in
        let? cps := sx_call fuel' sm pc fd args in
        Some (map (fun (x : cpath) => let '(sm', pc', r) := x in
                                      (sset_opt optid r le, sm', pc', SOnormal)) cps)
      else None
  | Ssequence s1 s2 =>
      let? ps := sx_stmt fuel' le sm pc s1 in
      oflat (fun (p : spath) =>
               match p with
               | (le1, sm1, pc1, SOnormal) => sx_stmt fuel' le1 sm1 pc1 s2
               | _ => Some [p]
               end) ps
  | Sifthenelse a s1 s2 =>
      let? c := sx_expr le sm a in
      match decide pc c (typeof a) with
      | Some b => sx_stmt fuel' le sm pc (if b then s1 else s2)
      | None =>
          let? p1 := sx_stmt fuel' le sm ((c, typeof a, true) :: pc) s1 in
          let? p2 := sx_stmt fuel' le sm ((c, typeof a, false) :: pc) s2 in
          Some (p1 ++ p2)
      end
  | Sreturn None => Some [(le, sm, pc, SOreturn None)]
  | Sreturn (Some a) =>
      let? v := sx_expr le sm a in Some [(le, sm, pc, SOreturn (Some (v, typeof a)))]
  | Sbreak => Some [(le, sm, pc, SObreak)]
  | Scontinue => Some [(le, sm, pc, SOcontinue)]
  | _ => None
  end
  end

with sx_call (fuel : nat) (sm : smem) (pc : spc) (fd : fundef) (args : list sval)
    {struct fuel} : option (list cpath) :=
  match fuel with
  | O => None
  | S fuel' =>
  match fd with
  | Internal f =>
      match f.(fn_vars) with
      | nil =>
          if list_norepet_dec ident_eq (var_names f.(fn_params)) then
          if list_disjoint_dec ident_eq (var_names f.(fn_params)) (var_names f.(fn_temps)) then
            let? le := sbind f.(fn_params) args (sundef f.(fn_temps)) in
            let? ps := sx_stmt fuel' le sm pc f.(fn_body) in
            omap (fun (p : spath) =>
                    let '(_, sm', pc', out) := p in
                    let? r := sresult out f.(fn_return) in Some (sm', pc', r)) ps
          else None else None
      | _ => None
      end
  | External _ _ _ _ => None
  end
  end.

(* ================================================================ *)
(* SOUNDNESS (coverage)                                               *)
(* ================================================================ *)

Variable sigma : positive -> block.
Hypothesis sigma_inj : forall r r', sigma r = sigma r' -> r = r'.
Variable m0 : mem.
Hypothesis kz_sound : forall r o ch mask, In (r, o, ch, mask) kz ->
  exists i, Mem.load ch m0 (sigma r) o = Some (Vint i) /\ Int.and i mask = Int.zero.
Hypothesis kv_sound : forall r o ch v, In (r, o, ch, v) kv -> Mem.load ch m0 (sigma r) o = Some v.

Fixpoint den (a : sval) : option val :=
  match a with
  | Sconst v => Some v
  | Sptr r o => Some (Vptr (sigma r) o)
  | Sinit r o ch => Mem.load ch m0 (sigma r) o
  | Sunop op a ty => let? v := den a in sem_unary_operation op v ty m0
  | Sbinop op a1 t1 a2 t2 =>
      let? v1 := den a1 in let? v2 := den a2 in sem_binary_operation ge op v1 t1 v2 t2 m0
  | Scast a t1 t2 => let? v := den a in sem_cast v t1 t2 m0
  | Sldres ch a => let? v := den a in Some (Val.load_result ch v)
  end.

Definition mem_match (m : mem) (sm : smem) : Prop :=
  forall r o ch sv, In (r, o, ch, sv) sm -> Mem.load ch m (sigma r) o = den sv.

Definition frame (m : mem) (sm : smem) : Prop :=
  forall b o ch, (forall r, sigma r = b -> filter (ovl r o ch) sm = nil) ->
                 Mem.load ch m b o = Mem.load ch m0 b o.

Definition vp_agree (m1 m2 : mem) : Prop :=
  forall b o, Mem.valid_pointer m1 b o = Mem.valid_pointer m2 b o.

Definition pc_holds (x : sval * type * bool) : Prop :=
  let '(a, ty, b) := x in exists v, den a = Some v /\ bool_val v ty m0 = Some b.

Definition MM (m : mem) (sm : smem) (pc : spc) : Prop :=
  mem_match m sm /\ frame m sm /\ vp_agree m m0 /\ Forall pc_holds pc.

Definition temps_match (tle : temp_env) (le : PTree.t sval) : Prop :=
  forall id, tle ! id = match le ! id with Some a => den a | None => None end.

Definition out_match (out : outcome) (so : sout) : Prop :=
  match out, so with
  | Out_normal, SOnormal | Out_break, SObreak | Out_continue, SOcontinue => True
  | Out_return None, SOreturn None => True
  | Out_return (Some (v, t)), SOreturn (Some (a, t')) => t = t' /\ den a = Some v
  | _, _ => False
  end.

(* ---------------------------------------------------------------- *)
(* Memory independence of the operators                              *)
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

Section VPH.
Variables m1 m2 : mem.
Hypothesis A : vp_agree m1 m2.

Lemma vph1 : forall b1 ofs b2 delta, inject_id b1 = Some (b2, delta) ->
  Mem.valid_pointer m1 b1 (Ptrofs.unsigned ofs) = true ->
  Mem.valid_pointer m2 b2 (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr delta))) = true.
Proof.
  unfold inject_id; intros b1 ofs b2 delta H V. inv H.
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. rewrite <- A. exact V.
Qed.

Lemma vph2 : forall b1 ofs b2 delta, inject_id b1 = Some (b2, delta) ->
  Mem.weak_valid_pointer m1 b1 (Ptrofs.unsigned ofs) = true ->
  Mem.weak_valid_pointer m2 b2 (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr delta))) = true.
Proof.
  unfold inject_id, Mem.weak_valid_pointer; intros b1 ofs b2 delta H V. inv H.
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. rewrite <- !A. exact V.
Qed.

Lemma vph3 : forall b1 ofs b2 delta, inject_id b1 = Some (b2, delta) ->
  Mem.weak_valid_pointer m1 b1 (Ptrofs.unsigned ofs) = true ->
  0 <= Ptrofs.unsigned ofs + Ptrofs.unsigned (Ptrofs.repr delta) <= Ptrofs.max_unsigned.
Proof.
  unfold inject_id; intros b1 ofs b2 delta H V. inv H.
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.unsigned_zero.
  pose proof (Ptrofs.unsigned_range_2 ofs). lia.
Qed.

Lemma vph4 : forall b1 ofs1 b2 ofs2 b1' delta1 b2' delta2, b1 <> b2 ->
  Mem.valid_pointer m1 b1 (Ptrofs.unsigned ofs1) = true ->
  Mem.valid_pointer m1 b2 (Ptrofs.unsigned ofs2) = true ->
  inject_id b1 = Some (b1', delta1) -> inject_id b2 = Some (b2', delta2) ->
  b1' <> b2' \/
  Ptrofs.unsigned (Ptrofs.add ofs1 (Ptrofs.repr delta1)) <>
  Ptrofs.unsigned (Ptrofs.add ofs2 (Ptrofs.repr delta2)).
Proof. unfold inject_id; intros. inv H2. inv H3. left. exact H. Qed.

End VPH.

Lemma vp_agree_sym : forall m1 m2, vp_agree m1 m2 -> vp_agree m2 m1.
Proof. unfold vp_agree; intros; symmetry; auto. Qed.

Lemma inj_id_refl : forall v, Val.inject inject_id v v.
Proof.
  destruct v; econstructor; eauto. unfold inject_id; reflexivity.
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma inj_id_def : forall v w, Val.inject inject_id v w -> v <> Vundef -> v = w.
Proof.
  intros v w H N. inv H; auto; [ | congruence ].
  unfold inject_id in H0. inv H0.
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma inj_id_antisym : forall v w,
  Val.inject inject_id v w -> Val.inject inject_id w v -> v = w.
Proof.
  intros v w H1 H2.
  destruct v; try (apply inj_id_def; [ exact H1 | discriminate ]).
  inv H2; reflexivity.
Qed.

Lemma bin_vp : forall m1 m2 op v1 t1 v2 t2 v, vp_agree m1 m2 ->
  sem_binary_operation ge op v1 t1 v2 t2 m1 = Some v ->
  sem_binary_operation ge op v1 t1 v2 t2 m2 = Some v.
Proof.
  intros m1 m2 op v1 t1 v2 t2 v A H.
  destruct (sem_binary_operation_inj inject_id m1 m2 (vph1 _ _ A) (vph2 _ _ A) (vph3 m1)
              (vph4 m1) ge op v1 t1 v2 t2 v v1 v2 H (inj_id_refl _) (inj_id_refl _))
    as [w [Hw Iw]].
  pose proof (vp_agree_sym _ _ A) as A'.
  destruct (sem_binary_operation_inj inject_id m2 m1 (vph1 _ _ A') (vph2 _ _ A') (vph3 m2)
              (vph4 m2) ge op v1 t1 v2 t2 w v1 v2 Hw (inj_id_refl _) (inj_id_refl _))
    as [w' [Hw' Iw']].
  rewrite H in Hw'. inv Hw'.
  rewrite (inj_id_antisym _ _ Iw Iw'). exact Hw.
Qed.

Lemma un_vp : forall m1 m2 op v1 ty v, vp_agree m1 m2 ->
  sem_unary_operation op v1 ty m1 = Some v -> sem_unary_operation op v1 ty m2 = Some v.
Proof.
  intros m1 m2 op v1 ty v A H.
  destruct (sem_unary_operation_inj inject_id m1 m2 (vph2 _ _ A) op v1 ty v v1 H (inj_id_refl _))
    as [w [Hw Iw]].
  pose proof (vp_agree_sym _ _ A) as A'.
  destruct (sem_unary_operation_inj inject_id m2 m1 (vph2 _ _ A') op v1 ty w v1 Hw (inj_id_refl _))
    as [w' [Hw' Iw']].
  rewrite H in Hw'. inv Hw'.
  rewrite (inj_id_antisym _ _ Iw Iw'). exact Hw.
Qed.

Lemma cast_vp : forall m1 m2 v1 t1 t2 v, vp_agree m1 m2 ->
  sem_cast v1 t1 t2 m1 = Some v -> sem_cast v1 t1 t2 m2 = Some v.
Proof.
  intros m1 m2 v1 t1 t2 v A H.
  destruct (sem_cast_inj inject_id m1 m2 (vph2 _ _ A) v1 t1 t2 v v1 H (inj_id_refl _))
    as [w [Hw Iw]].
  pose proof (vp_agree_sym _ _ A) as A'.
  destruct (sem_cast_inj inject_id m2 m1 (vph2 _ _ A') v1 t1 t2 w v1 Hw (inj_id_refl _))
    as [w' [Hw' Iw']].
  rewrite H in Hw'. inv Hw'.
  rewrite (inj_id_antisym _ _ Iw Iw'). exact Hw.
Qed.

Lemma bool_vp : forall m1 m2 v ty b, vp_agree m1 m2 ->
  bool_val v ty m1 = Some b -> bool_val v ty m2 = Some b.
Proof.
  intros m1 m2 v ty b A H.
  exact (bool_val_inj inject_id m1 m2 (vph2 _ _ A) v ty b v H (inj_id_refl _)).
Qed.

(* ---------------------------------------------------------------- *)
(* Folding is sound                                                   *)
(* ---------------------------------------------------------------- *)

Definition ptr_inj (r : positive) : meminj :=
  fun b => if eq_block b dummy_b then Some (sigma r, 0) else None.

Lemma ptr_inj_dummy : forall r o, Val.inject (ptr_inj r) (Vptr dummy_b o) (Vptr (sigma r) o).
Proof.
  intros. econstructor. unfold ptr_inj. rewrite dec_eq_true. reflexivity.
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma inj_nonptr : forall f v, non_ptr v = true -> Val.inject f v v.
Proof. intros f v H. destruct v; try discriminate; constructor. Qed.

Lemma fold_ptr_res_sound : forall r res dflt w,
  (forall v, res = Some v -> Val.inject (ptr_inj r) v w) ->
  den dflt = Some w ->
  den (fold_ptr_res r res dflt) = Some w.
Proof.
  intros r res dflt w H D. unfold fold_ptr_res.
  destruct res as [[| | | | | b o']|]; auto.
  destruct (eq_block b dummy_b); auto. subst.
  specialize (H _ eq_refl).
  inversion H as [ | | | | b1 ofs1 b2 ofs2 delta Hf Ho | ]; subst.
  unfold ptr_inj in Hf. rewrite dec_eq_true in Hf. inv Hf.
  cbn [den]. change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. reflexivity.
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

Lemma known_zero_sound : forall r o ch k, known_zero r o ch k = true ->
  exists i, Mem.load ch m0 (sigma r) o = Some (Vint i) /\ Int.and i k = Int.zero.
Proof.
  unfold known_zero; intros r o ch k H.
  apply existsb_exists in H. destruct H as [[[[r' o'] ch'] mask] [Hin Hc]].
  destruct (Pos.eqb_spec r r'); [ | discriminate]. subst.
  destruct (Z.eqb_spec o o'); [ | discriminate]. subst.
  destruct (chunk_eq ch ch'); [ | discriminate]. subst.
  cbn [andb] in Hc.
  destruct (kz_sound _ _ _ _ Hin) as [i [L M]].
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

Lemma fold_bin_sound : forall m op a1 t1 a2 t2 v1 v2 v,
  vp_agree m m0 -> den a1 = Some v1 -> den a2 = Some v2 ->
  sem_binary_operation ge op v1 t1 v2 t2 m = Some v ->
  den (fold_bin op a1 t1 a2 t2) = Some v.
Proof.
  intros m op a1 t1 a2 t2 v1 v2 v A D1 D2 H.
  assert (DF : den (Sbinop op a1 t1 a2 t2) = Some v).
  { cbn [den]. rewrite D1, D2. eapply bin_vp; eauto. }
  unfold fold_bin.
  destruct a1 as [c1 | r1 o1 | r1 o1 ch1 | | | | ]; try exact DF;
    destruct a2 as [c2 | r2 o2 | | | | | ]; try exact DF.
  - (* const, const *)
    cbn [den] in D1, D2. injection D1 as <-. injection D2 as <-.
    destruct (sem_binary_operation ge op c1 t1 c2 t2 Mem.empty) as [v'|] eqn:E; [ | exact DF].
    destruct (non_undef v') eqn:NU; [ | exact DF].
    destruct (sem_binary_operation_inj inject_id Mem.empty m ltac:(empty_side) ltac:(empty_side)
                ltac:(empty_side) ltac:(empty_side) ge op c1 t1 c2 t2 v' c1 c2 E
                (inj_id_refl _) (inj_id_refl _)) as [w [Hw Iw]].
    rewrite H in Hw. injection Hw as <-. cbn [den]. f_equal.
    apply inj_id_def; auto. destruct v'; discriminate.
  - (* const, ptr *)
    cbn [den] in D1, D2. injection D1 as <-. injection D2 as <-.
    destruct (non_ptr c1) eqn:NP; [ | exact DF].
    apply fold_ptr_res_sound; [ | exact DF].
    intros v' E.
    destruct (sem_binary_operation_inj (ptr_inj r2) Mem.empty m ltac:(empty_side)
                ltac:(empty_side) ltac:(empty_side) ltac:(empty_side) ge op c1 t1
                (Vptr dummy_b o2) t2 v' c1 (Vptr (sigma r2) o2) E
                (inj_nonptr _ _ NP) (ptr_inj_dummy _ _)) as [w [Hw Iw]].
    rewrite H in Hw. injection Hw as <-. exact Iw.
  - (* ptr, const *)
    cbn [den] in D1, D2. injection D1 as <-. injection D2 as <-.
    destruct (non_ptr c2) eqn:NP; [ | exact DF].
    apply fold_ptr_res_sound; [ | exact DF].
    intros v' E.
    destruct (sem_binary_operation_inj (ptr_inj r1) Mem.empty m ltac:(empty_side)
                ltac:(empty_side) ltac:(empty_side) ltac:(empty_side) ge op
                (Vptr dummy_b o1) t1 c2 t2 v' (Vptr (sigma r1) o1) c2 E
                (ptr_inj_dummy _ _) (inj_nonptr _ _ NP)) as [w [Hw Iw]].
    rewrite H in Hw. injection Hw as <-. exact Iw.
  - (* initial cell & k, k inside a known-zero mask *)
    destruct c2 as [ | k | | | | ]; try exact DF.
    destruct op; try exact DF.
    destruct (is_tint t1 && is_tint t2 && known_zero r1 o1 ch1 k) eqn:KZ; [ | exact DF].
    apply andb_true_iff in KZ as [KT KZ]. apply andb_true_iff in KT as [T1 T2].
    destruct t1; try discriminate. destruct t2; try discriminate.
    destruct (known_zero_sound _ _ _ _ KZ) as [x [Lx Ax]].
    cbn [den] in D1, D2. rewrite Lx in D1. injection D1 as <-. injection D2 as <-.
    apply sem_and_tint in H. subst v. rewrite Ax. reflexivity.
Qed.

Lemma fold_un_sound : forall m op a ty v1 v,
  vp_agree m m0 -> den a = Some v1 ->
  sem_unary_operation op v1 ty m = Some v -> den (fold_un op a ty) = Some v.
Proof.
  intros m op a ty v1 v A D H.
  assert (DF : den (Sunop op a ty) = Some v).
  { cbn [den]. rewrite D. eapply un_vp; eauto. }
  unfold fold_un. destruct a; try exact DF.
  cbn [den] in D. inv D.
  destruct (sem_unary_operation op v1 ty Mem.empty) as [v'|] eqn:E; [ | exact DF].
  destruct (non_undef v') eqn:NU; [ | exact DF].
  destruct (sem_unary_operation_inj inject_id Mem.empty m ltac:(empty_side) op v1 ty v' v1 E
              (inj_id_refl _)) as [w [Hw Iw]].
  rewrite H in Hw. inv Hw. cbn [den]. f_equal.
  apply inj_id_def; auto. destruct v'; discriminate.
Qed.

Lemma fold_cast_sound : forall m a t1 t2 v1 v,
  vp_agree m m0 -> den a = Some v1 ->
  sem_cast v1 t1 t2 m = Some v -> den (fold_cast a t1 t2) = Some v.
Proof.
  intros m a t1 t2 v1 v A D H.
  assert (DF : den (Scast a t1 t2) = Some v).
  { cbn [den]. rewrite D. eapply cast_vp; eauto. }
  unfold fold_cast. destruct a; try exact DF.
  - cbn [den] in D. inv D.
    destruct (sem_cast v1 t1 t2 Mem.empty) as [v'|] eqn:E; [ | exact DF].
    destruct (non_undef v') eqn:NU; [ | exact DF].
    destruct (sem_cast_inj inject_id Mem.empty m ltac:(empty_side) v1 t1 t2 v' v1 E
                (inj_id_refl _)) as [w [Hw Iw]].
    rewrite H in Hw. inv Hw. cbn [den]. f_equal.
    apply inj_id_def; auto. destruct v'; discriminate.
  - cbn [den] in D. inv D.
    apply fold_ptr_res_sound; [ | exact DF].
    intros v' E.
    destruct (sem_cast_inj (ptr_inj r) Mem.empty m ltac:(empty_side) (Vptr dummy_b ofs) t1 t2
                v' (Vptr (sigma r) ofs) E (ptr_inj_dummy _ _)) as [w [Hw Iw]].
    rewrite H in Hw. inv Hw. exact Iw.
Qed.

Lemma fold_ldres_den : forall ch a v, den a = Some v ->
  den (fold_ldres ch a) = Some (Val.load_result ch v).
Proof.
  intros ch a v D.
  assert (G : forall x, den (Sldres ch x) =
                        match den x with Some v => Some (Val.load_result ch v) | None => None end)
    by reflexivity.
  unfold fold_ldres. destruct a; try (rewrite G, D; reflexivity).
  cbn [den] in D. inv D. reflexivity.
Qed.

Lemma decide_sound : forall m pc c ty v b b',
  vp_agree m m0 -> Forall pc_holds pc -> den c = Some v ->
  bool_val v ty m = Some b -> decide pc c ty = Some b' -> b' = b.
Proof.
  intros m pc c ty v b b' A P D B H. unfold decide in H.
  assert (L : forall pc, Forall pc_holds pc -> pc_lookup pc c ty = Some b' -> b' = b).
  { induction pc0 as [|[[a t] bb] pc' IH]; intros P' Hl; cbn [pc_lookup] in Hl; [ discriminate | ].
    inversion P' as [| x xs Hx Hxs]; subst.
    destruct (sval_eq a c); [ destruct (type_eq t ty) | ]; auto.
    subst. inv Hl. destruct Hx as [v' [D' B']]. rewrite D in D'. inv D'.
    apply (bool_vp _ _ _ _ _ A) in B. congruence. }
  destruct c; try (apply (L pc P H)).
  cbn [den] in D. inv D.
  pose proof (bool_val_inj inject_id Mem.empty m ltac:(empty_side) v ty b' v H (inj_id_refl _)).
  congruence.
Qed.

(* ---------------------------------------------------------------- *)
(* Symbolic memory is sound                                           *)
(* ---------------------------------------------------------------- *)

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

Lemma ovl_exact : forall r o ch e, exact r o ch e = true -> ovl r o ch e = true.
Proof.
  intros r o ch [[[r' o'] ch'] sv] H. apply exact_true in H. destruct H as (-> & -> & ->).
  unfold ovl. rewrite Pos.eqb_refl. pose proof (size_chunk_pos ch').
  apply andb_true_intro; split; [ apply andb_true_intro; split; [reflexivity | ] | ];
    apply Z.ltb_lt; lia.
Qed.

Lemma init_cell_den : forall r o ch, den (init_cell r o ch) = Mem.load ch m0 (sigma r) o.
Proof.
  intros r o ch. unfold init_cell.
  destruct (find _ kv) as [[[[r' o'] ch'] v]|] eqn:F; [ | reflexivity].
  apply find_some in F. destruct F as [IN Hk].
  destruct (Pos.eqb_spec r r'); [ | discriminate]. subst.
  destruct (Z.eqb_spec o o'); [ | discriminate]. subst.
  destruct (chunk_eq ch ch'); [ | discriminate]. subst.
  cbn [den]. symmetry. apply kv_sound. exact IN.
Qed.

Lemma sload_sound : forall m sm r o ch sa v,
  mem_match m sm -> frame m sm ->
  sload sm r o ch = Some sa -> Mem.load ch m (sigma r) o = Some v -> den sa = Some v.
Proof.
  intros m sm r o ch sa v MMt Fr H L. unfold sload in H.
  destruct (filter (ovl r o ch) sm) as [|e [|e' l]] eqn:F.
  - inv H. rewrite init_cell_den. rewrite <- L. symmetry. apply Fr.
    intros r' E. apply sigma_inj in E. subst. exact F.
  - destruct (exact r o ch e) eqn:X; [ | discriminate]. inv H.
    destruct e as [[[r' o'] ch'] sv]. apply exact_true in X. destruct X as (-> & -> & ->).
    assert (In (r', o', ch', sv) sm) by (apply (filter_In (ovl r' o' ch')); rewrite F; left; auto).
    cbn [snd]. rewrite <- (MMt _ _ _ _ H). exact L.
  - discriminate.
Qed.

Lemma store_vp : forall ch m b o v m', Mem.store ch m b o v = Some m' -> vp_agree m' m.
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

Lemma sstore_sound : forall m sm r o ch sa v m' sm',
  mem_match m sm -> frame m sm -> vp_agree m m0 ->
  sstore sm r o ch sa = Some sm' -> den sa = Some (Val.load_result ch v) ->
  Mem.store ch m (sigma r) o v = Some m' ->
  mem_match m' sm' /\ frame m' sm' /\ vp_agree m' m0.
Proof.
  intros m sm r o ch sa v m' sm' MMt Fr VP SS D ST.
  unfold sstore in SS. destruct (forallb _ sm) eqn:ALL; [ | discriminate]. inv SS.
  rewrite forallb_forall in ALL.
  split; [ | split ].
  - (* mem_match *)
    intros r' o' ch' sv IN. destruct IN as [E | IN].
    + inv E. rewrite (Mem.load_store_same _ _ _ _ _ _ ST). rewrite D. reflexivity.
    + apply filter_In in IN. destruct IN as [IN NO].
      apply negb_true_iff in NO. apply ovl_false in NO.
      rewrite (Mem.load_store_other _ _ _ _ _ _ ST).
      * apply MMt; auto.
      * destruct NO as [NE | NO];
          [ left; intro E; apply NE; apply sigma_inj; auto | right; lia ].
  - (* frame *)
    intros b o' ch' NOV.
    assert (L1 : Mem.load ch' m' b o' = Mem.load ch' m b o').
    { eapply Mem.load_store_other; eauto.
      destruct (eq_block b (sigma r)) as [E | NE]; [ | left; auto ].
      right. specialize (NOV r (eq_sym E)). cbn [filter] in NOV.
      destruct (ovl r o' ch' (r, o, ch, sa)) eqn:OV; [ discriminate | ].
      apply ovl_false in OV. destruct OV as [C | C]; [ congruence | lia ]. }
    rewrite L1. apply Fr. intros r' E. specialize (NOV r' E).
    apply filter_nil_iff. intros e IN.
    rewrite filter_nil_iff in NOV.
    destruct (ovl r o ch e) eqn:OV.
    + pose proof (ALL e IN) as X. rewrite OV in X. cbn [negb orb] in X.
      destruct e as [[[re oe] che] sve]. apply exact_true in X. destruct X as (<- & <- & <-).
      specialize (NOV (r, o, ch, sa) (or_introl eq_refl)).
      unfold ovl in NOV |- *. exact NOV.
    + apply NOV. right. apply filter_In. split; auto. rewrite OV. reflexivity.
  - (* valid pointers *)
    intros b' o'. rewrite (store_vp _ _ _ _ _ _ ST). apply VP.
Qed.

(* ---------------------------------------------------------------- *)
(* Expressions are sound                                              *)
(* ---------------------------------------------------------------- *)

Lemma sderef_sound : forall m sm ty r o sa v,
  mem_match m sm -> frame m sm ->
  sderef ty sm r o = Some sa -> deref_loc ty m (sigma r) o Full v -> den sa = Some v.
Proof.
  intros m sm ty r o sa v MMt Fr H DL. unfold sderef in H.
  inversion DL as [ch v' AM LD | AM | AM | ]; subst; rewrite AM in H.
  - eapply sload_sound; eauto.
  - inv H. reflexivity.
  - inv H. reflexivity.
Qed.

Lemma sx_expr_lvalue_sound : forall tle le m sm pc, temps_match tle le -> MM m sm pc ->
  (forall a v, eval_expr ge empty_env tle m a v ->
     forall sa, sx_expr le sm a = Some sa -> den sa = Some v)
  /\ (forall a b o bf, eval_lvalue ge empty_env tle m a b o bf ->
     forall r so, sx_lvalue le sm a = Some (r, so) -> b = sigma r /\ o = so /\ bf = Full).
Proof.
  intros tle le m sm pc TM (MMt & Fr & VP & PC).
  apply (eval_expr_lvalue_ind ge empty_env tle m
           (fun a v => forall sa, sx_expr le sm a = Some sa -> den sa = Some v)
           (fun a b o bf => forall r so, sx_lvalue le sm a = Some (r, so) ->
                              b = sigma r /\ o = so /\ bf = Full));
    intros; cbv beta in *; simpl sx_expr in *; simpl sx_lvalue in *.
  - inv H. reflexivity.
  - inv H. reflexivity.
  - inv H. reflexivity.
  - inv H. reflexivity.
  - (* Etempvar *) rewrite TM in H. rewrite H0 in H. exact H.
  - (* Eaddrof *)
    destruct (sx_lvalue le sm a) as [[r so]|] eqn:E; [ | discriminate]. inv H1.
    destruct (H0 r so eq_refl) as (-> & -> & _). reflexivity.
  - (* Eunop *)
    destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate]. inv H2.
    eapply fold_un_sound; eauto.
  - (* Ebinop *)
    destruct (sx_expr le sm a1) as [s1|] eqn:E1; [ | discriminate].
    destruct (sx_expr le sm a2) as [s2|] eqn:E2; [ | discriminate]. inv H4.
    eapply fold_bin_sound; eauto.
  - (* Ecast *)
    destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate]. inv H2.
    eapply fold_cast_sound; eauto.
  - inv H. reflexivity.
  - inv H. reflexivity.
  - (* Elvalue *)
    destruct a; try discriminate; try (inv H; fail).
    + (* Ederef *)
      simpl sx_expr in *; simpl sx_lvalue in *; simpl typeof in *.
      destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate].
      destruct s1; try discriminate.
      destruct (H0 r ofs0 eq_refl) as (-> & -> & ->).
      eapply sderef_sound; eauto.
    + (* Efield *)
      simpl sx_expr in *; simpl sx_lvalue in *; simpl typeof in *.
      destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate].
      destruct s1; try discriminate.
      destruct (sfield_loc (typeof a) i r ofs0) as [[r' o']|] eqn:F; [ | discriminate].
      destruct (H0 r' o' eq_refl) as (-> & -> & ->).
      eapply sderef_sound; eauto.
  - (* Evar local *) discriminate.
  - (* Evar global *) discriminate.
  - (* Ederef *)
    destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate].
    destruct s1; try discriminate. inv H1.
    specialize (H0 _ eq_refl). cbn [den] in H0. inv H0. auto.
  - (* Efield struct *)
    destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate].
    destruct s1 as [ | r1 o1 | | | | | ]; try discriminate.
    specialize (H0 _ eq_refl). cbn [den] in H0. injection H0 as <- <-.
    match goal with Hs : sfield_loc _ _ _ _ = Some _ |- _ =>
      unfold sfield_loc in Hs; rewrite H1, H2, H3 in Hs;
      destruct bf; [ injection Hs as <- <-; auto | discriminate ] end.
  - (* Efield union *)
    destruct (sx_expr le sm a) as [s1|] eqn:E; [ | discriminate].
    destruct s1 as [ | r1 o1 | | | | | ]; try discriminate.
    specialize (H0 _ eq_refl). cbn [den] in H0. injection H0 as <- <-.
    match goal with Hs : sfield_loc _ _ _ _ = Some _ |- _ =>
      unfold sfield_loc in Hs; rewrite H1, H2, H3 in Hs;
      destruct bf; [ injection Hs as <- <-; auto | discriminate ] end.
Qed.

Lemma sx_expr_sound : forall tle le m sm pc a v sa, temps_match tle le -> MM m sm pc ->
  eval_expr ge empty_env tle m a v -> sx_expr le sm a = Some sa -> den sa = Some v.
Proof. intros. eapply (sx_expr_lvalue_sound tle le m sm pc); eauto. Qed.

Lemma sx_lvalue_sound : forall tle le m sm pc a b o bf r so, temps_match tle le -> MM m sm pc ->
  eval_lvalue ge empty_env tle m a b o bf -> sx_lvalue le sm a = Some (r, so) ->
  b = sigma r /\ o = so /\ bf = Full.
Proof. intros. eapply (sx_expr_lvalue_sound tle le m sm pc); eauto. Qed.

Lemma sx_exprlist_sound : forall tle le m sm pc al tyl vl sl,
  temps_match tle le -> MM m sm pc ->
  eval_exprlist ge empty_env tle m al tyl vl -> sx_exprlist le sm al tyl = Some sl ->
  Forall2 (fun a v => den a = Some v) sl vl.
Proof.
  intros tle le m sm pc al tyl vl sl TM MMm H. revert sl.
  induction H as [| a bl ty tyl v1 v2 vl Ha Hc Hl IH]; intros sl E; cbn [sx_exprlist] in E.
  - inv E. constructor.
  - destruct (sx_expr le sm a) as [s1|] eqn:E1; [ | discriminate].
    destruct (sx_exprlist le sm bl tyl) as [sl'|] eqn:E2; [ | discriminate]. inv E.
    constructor; [ | apply IH; reflexivity ].
    pose proof MMm as (_ & _ & VP & _).
    eapply fold_cast_sound; eauto. eapply sx_expr_sound; eauto.
Qed.

(* ---------------------------------------------------------------- *)
(* Statements and calls are sound                                     *)
(* ---------------------------------------------------------------- *)

Lemma temps_set : forall tle le id v a, temps_match tle le -> den a = Some v ->
  temps_match (PTree.set id v tle) (PTree.set id a le).
Proof.
  unfold temps_match; intros tle le id v a T D x.
  rewrite !PTree.gsspec. destruct (peq x id); auto.
Qed.

Lemma sundef_match : forall temps, temps_match (create_undef_temps temps) (sundef temps).
Proof.
  induction temps as [|[id t] temps IH]; intros x; cbn [create_undef_temps sundef].
  - rewrite !PTree.gempty. reflexivity.
  - rewrite !PTree.gsspec. destruct (peq x id); [ reflexivity | apply IH ].
Qed.

Lemma sbind_sound : forall params sargs vargs sle tle sle' tle',
  Forall2 (fun a v => den a = Some v) sargs vargs -> temps_match tle sle ->
  sbind params sargs sle = Some sle' -> bind_parameter_temps params vargs tle = Some tle' ->
  temps_match tle' sle'.
Proof.
  induction params as [|[id t] params IH]; intros sargs vargs sle tle sle' tle' F T S B;
    inversion F as [| a v sargs' vargs' Hd F']; subst; cbn [sbind bind_parameter_temps] in S, B;
    try discriminate.
  - inv S. inv B. exact T.
  - eapply IH; [ exact F' | apply temps_set; eauto | exact S | exact B ].
Qed.

Lemma eval_Evar_fun : forall tle m id targs tres cc vf,
  eval_expr ge empty_env tle m (Evar id (Tfunction targs tres cc)) vf ->
  exists b, Genv.find_symbol ge id = Some b /\ vf = Vptr b Ptrofs.zero.
Proof.
  intros tle m id targs tres cc vf H. inv H.
  match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv HL end.
  - match goal with HE : empty_env ! _ = Some _ |- _ =>
      unfold empty_env in HE; rewrite PTree.gempty in HE; discriminate end.
  - match goal with HD : deref_loc _ _ _ _ _ _ |- _ => inv HD end; cbn in *; try discriminate.
    eexists; split; eauto.
Qed.

Lemma out_match_normal_l : forall so, out_match Out_normal so -> so = SOnormal.
Proof. intros [| | | [[? ?]|]]; cbn; tauto. Qed.

Lemma out_match_normal_r : forall out, out_match out SOnormal -> out = Out_normal.
Proof. intros [| | | [[? ?]|]]; cbn; tauto. Qed.

Ltac triv_path :=
  split; [ left; reflexivity | split; [ assumption | split; [ assumption | cbn; auto ] ] ].

Theorem sx_sound : forall fuel,
  (forall le sm pc s ps tle m t tle' m' out,
     sx_stmt fuel le sm pc s = Some ps -> temps_match tle le -> MM m sm pc ->
     exec_stmt function_entry2 ge empty_env tle m s t tle' m' out ->
     exists le' sm' pc' so, In (le', sm', pc', so) ps /\ temps_match tle' le'
                            /\ MM m' sm' pc' /\ out_match out so)
  /\ (forall sm pc fd sargs cps m args t m' vres,
     sx_call fuel sm pc fd sargs = Some cps ->
     Forall2 (fun a v => den a = Some v) sargs args -> MM m sm pc ->
     eval_funcall function_entry2 ge m fd args t m' vres ->
     exists sm' pc' r, In (sm', pc', r) cps /\ MM m' sm' pc' /\ den r = Some vres).
Proof.
  induction fuel as [|fuel IH]; split.
  - intros. simpl in H. discriminate.
  - intros. simpl in H. discriminate.
  - destruct IH as [IHs IHc].
    intros le sm pc s ps tle m t tle' m' out Hs TM MMm Hx.
    destruct s; simpl sx_stmt in Hs; try discriminate.
    + (* Sskip *)
      inv Hs. inv Hx. exists le, sm, pc, SOnormal. triv_path.
    + (* Sassign *)
      destruct (sx_lvalue le sm e) as [[r o]|] eqn:El; [ | discriminate].
      destruct (sx_expr le sm e0) as [v2s|] eqn:Ev; [ | discriminate].
      destruct (access_mode (typeof e)) as [ch| | | ] eqn:AM; try discriminate.
      destruct (sstore sm r (Ptrofs.unsigned o) ch
                  (fold_ldres ch (fold_cast v2s (typeof e0) (typeof e)))) as [sm'|] eqn:Ss;
        [ | discriminate].
      inv Hs. pose proof MMm as (MMt & Fr & VP & PC). inv Hx.
      match goal with
      | HL : eval_lvalue _ _ _ _ e _ _ _, HE : eval_expr _ _ _ _ e0 _,
        HC : sem_cast _ _ _ _ = Some _, HA : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        destruct (sx_lvalue_sound _ _ _ _ _ _ _ _ _ _ _ TM MMm HL El) as (-> & -> & ->);
        pose proof (sx_expr_sound _ _ _ _ _ _ _ _ TM MMm HE Ev) as D2;
        pose proof (fold_cast_sound _ _ _ _ _ _ VP D2 HC) as D3;
        inversion HA as [vv ch' mm AM' ST | | ]; subst;
          [ | congruence ];
        rewrite AM in AM'; injection AM' as <-; cbn [Mem.storev] in ST;
        destruct (sstore_sound _ _ _ _ _ _ _ _ _ MMt Fr VP Ss (fold_ldres_den _ _ _ D3) ST)
          as (A & B & C)
      end.
      exists le, sm', pc, SOnormal.
      split; [ left; reflexivity | split; [ exact TM | split; [ | exact I ] ] ].
      split; [ exact A | split; [ exact B | split; [ exact C | exact PC ] ] ].
    + (* Sset *)
      destruct (sx_expr le sm e) as [vs|] eqn:Ev; [ | discriminate]. inv Hs. inv Hx.
      exists (PTree.set i vs le), sm, pc, SOnormal.
      split; [ left; reflexivity | split; [ | split; [ exact MMm | exact I ] ] ].
      apply temps_set; auto. eapply sx_expr_sound; eauto.
    + (* Scall *)
      destruct e; try discriminate.
      destruct t0 as [ | | | | | | targs tres cc | | ]; try discriminate.
      destruct (sfun_lookup i) as [fd|] eqn:Fl; [ | discriminate].
      destruct (type_eq (type_of_fundef fd) (Tfunction targs tres cc)); [ | discriminate].
      destruct (sx_exprlist le sm l targs) as [sargs|] eqn:Ea; [ | discriminate].
      destruct (sx_call fuel sm pc fd sargs) as [cps|] eqn:Ec; [ | discriminate].
      inv Hs. inv Hx.
      match goal with
      | HCF : classify_fun _ = fun_case_f _ _ _, HF : eval_expr _ _ _ _ _ ?vf,
        HL : eval_exprlist _ _ _ _ _ _ _, HFF : Genv.find_funct _ ?vf = Some _,
        HEV : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        cbn in HCF; inv HCF;
        destruct (eval_Evar_fun _ _ _ _ _ _ _ HF) as (b & Hb & ->);
        rewrite Genv.find_funct_find_funct_ptr in HFF;
        unfold sfun_lookup in Fl; rewrite Hb in Fl; rewrite Fl in HFF; inv HFF;
        pose proof (sx_exprlist_sound _ _ _ _ _ _ _ _ _ TM MMm HL Ea) as FA;
        destruct (IHc _ _ _ _ _ _ _ _ _ _ Ec FA MMm HEV) as (sm' & pc' & r & Hin & MM' & Dr)
      end.
      exists (sset_opt o r le), sm', pc', SOnormal.
      split; [ | split; [ | split; [ exact MM' | exact I ] ] ].
      * apply in_map_iff. exists (sm', pc', r). split; auto.
      * destruct o; cbn [set_opttemp sset_opt]; auto. apply temps_set; auto.
    + (* Ssequence *)
      destruct (sx_stmt fuel le sm pc s1) as [ps1|] eqn:E1; [ | discriminate].
      inv Hx.
      * (* s1 normal *)
        match goal with
        | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ Out_normal, H2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
          destruct (IHs _ _ _ _ _ _ _ _ _ _ _ E1 TM MMm H1) as (sle1 & sm1 & pc1 & so1 & In1 & TM1 & MM1 & O1);
          apply out_match_normal_l in O1; subst so1;
          destruct (oflat_in _ _ _ _ Hs In1) as (rx & Fx & Inc);
          cbv beta iota in Fx;
          destruct (IHs _ _ _ _ _ _ _ _ _ _ _ Fx TM1 MM1 H2) as (le2 & sm2 & pc2 & so2 & In2 & TM2 & MM2 & O2)
        end.
        exists le2, sm2, pc2, so2. split; [ apply Inc; exact In2 | auto ].
      * (* s1 abrupt *)
        match goal with
        | H1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, HN : ?out <> Out_normal |- _ =>
          destruct (IHs _ _ _ _ _ _ _ _ _ _ _ E1 TM MMm H1) as (sle1 & sm1 & pc1 & so1 & In1 & TM1 & MM1 & O1);
          destruct (oflat_in _ _ _ _ Hs In1) as (rx & Fx & Inc)
        end.
        exists sle1, sm1, pc1, so1. split; [ | auto ].
        apply Inc. destruct so1; cbv beta iota in Fx; try (inv Fx; left; reflexivity).
        apply out_match_normal_r in O1. congruence.
    + (* Sifthenelse *)
      destruct (sx_expr le sm e) as [c|] eqn:Ec; [ | discriminate].
      inv Hx.
      match goal with
      | HE : eval_expr _ _ _ _ e _, HB : bool_val _ _ _ = Some _,
        HX : exec_stmt _ _ _ _ _ (if _ then _ else _) _ _ _ _ |- _ =>
        rename HE into HE0; rename HB into HB0; rename HX into HX0
      end.
      pose proof (sx_expr_sound _ _ _ _ _ _ _ _ TM MMm HE0 Ec) as Dc.
      destruct (decide pc c (typeof e)) as [b'|] eqn:Dd.
      * pose proof MMm as (_ & _ & VP & PC).
        rewrite (decide_sound _ _ _ _ _ _ _ VP PC Dc HB0 Dd) in Hs.
        exact (IHs _ _ _ _ _ _ _ _ _ _ _ Hs TM MMm HX0).
      * destruct (sx_stmt fuel le sm ((c, typeof e, true) :: pc) s1) as [p1|] eqn:P1;
          [ | discriminate].
        destruct (sx_stmt fuel le sm ((c, typeof e, false) :: pc) s2) as [p2|] eqn:P2;
          [ | discriminate].
        inv Hs.
        match type of HB0 with
        | bool_val ?v1 _ _ = Some ?b =>
          assert (MMb : MM m sm ((c, typeof e, b) :: pc))
            by (destruct MMm as (A & B & C & D);
                split; [ exact A | split; [ exact B | split; [ exact C | ] ] ];
                constructor; [ exists v1; split; [ exact Dc | eapply bool_vp; eauto ] | exact D ]);
          destruct b
        end.
        -- destruct (IHs _ _ _ _ _ _ _ _ _ _ _ P1 TM MMb HX0) as (le' & sm' & pc' & so & Hin & R).
           exists le', sm', pc', so. split; [ apply in_or_app; left; exact Hin | exact R ].
        -- destruct (IHs _ _ _ _ _ _ _ _ _ _ _ P2 TM MMb HX0) as (le' & sm' & pc' & so & Hin & R).
           exists le', sm', pc', so. split; [ apply in_or_app; right; exact Hin | exact R ].
    + (* Sbreak *)
      inv Hs. inv Hx. exists le, sm, pc, SObreak. triv_path.
    + (* Scontinue *)
      inv Hs. inv Hx. exists le, sm, pc, SOcontinue. triv_path.
    + (* Sreturn *)
      match type of Hx with exec_stmt _ _ _ _ _ (Sreturn ?x) _ _ _ _ => destruct x as [a|] end.
      * destruct (sx_expr le sm a) as [vs|] eqn:Ev; [ | discriminate]. inv Hs. inv Hx.
        exists le, sm, pc, (SOreturn (Some (vs, typeof a))).
        split; [ left; reflexivity | split; [ exact TM | split; [ exact MMm | ] ] ].
        cbn. split; [ reflexivity | eapply sx_expr_sound; eauto ].
      * inv Hs. inv Hx. exists le, sm, pc, (SOreturn None). triv_path.
  - destruct IH as [IHs IHc].
    intros sm pc fd sargs cps m args t m' vres Hc FA MMm Hx.
    destruct fd as [f|]; simpl sx_call in Hc; [ | discriminate].
    destruct (fn_vars f) eqn:FV; [ | discriminate].
    destruct (list_norepet_dec _ _); [ | discriminate].
    destruct (list_disjoint_dec _ _ _); [ | discriminate].
    destruct (sbind (fn_params f) sargs (sundef (fn_temps f))) as [le|] eqn:Eb; [ | discriminate].
    destruct (sx_stmt fuel le sm pc (fn_body f)) as [ps|] eqn:Ep; [ | discriminate].
    inv Hx.
    match goal with
    | HE : function_entry2 _ _ _ _ _ _ _, HB : exec_stmt _ _ _ _ _ _ _ _ _ _,
      HR : outcome_result_value _ _ _ _, HF : Mem.free_list _ _ = Some _ |- _ =>
      inversion HE as [N1 N2 N3 HA HBd]; subst;
      rewrite FV in HA; inv HA;
      assert (TM : temps_match _ le) by (eapply sbind_sound; eauto; apply sundef_match);
      destruct (IHs _ _ _ _ _ _ _ _ _ _ _ Ep TM MMm HB)
        as (le' & sm' & pc' & so & Hin & TM' & MM' & O);
      destruct (omap_in _ _ _ _ Hc Hin) as (y & Fy & Iy);
      rename HR into HRv; cbn in HF; inv HF
    end.
    destruct (sresult so (fn_return f)) as [r|] eqn:Sr; [ | discriminate]. inv Fy.
    exists sm', pc', r. split; [ exact Iy | split; [ exact MM' | ] ].
    pose proof MM' as (_ & _ & VP & _).
    unfold outcome_result_value in HRv.
    destruct out as [| | | [[v' t']|]]; destruct so as [| | | [[a' t'']|]]; cbn in O; try contradiction;
      unfold sresult in Sr; destruct (fn_return f); try discriminate; try contradiction;
      try (inv Sr; subst; reflexivity);
      destruct O as [<- Da]; destruct HRv as [HN HC];
      destruct (type_eq _ Tvoid); try discriminate; inv Sr; eapply fold_cast_sound; eauto.
Qed.

Corollary sx_call_sound : forall fuel sm pc fd sargs cps m args t m' vres,
  sx_call fuel sm pc fd sargs = Some cps ->
  Forall2 (fun a v => den a = Some v) sargs args -> MM m sm pc ->
  eval_funcall function_entry2 ge m fd args t m' vres ->
  exists sm' pc' r, In (sm', pc', r) cps /\ MM m' sm' pc' /\ den r = Some vres.
Proof. intros fuel. exact (proj2 (sx_sound fuel)). Qed.

Lemma MM_init : MM m0 nil nil.
Proof.
  split; [ intros r o ch sv [] | ].
  split; [ intros b o ch _; reflexivity | ].
  split; [ intros b o; reflexivity | constructor ].
Qed.

End SYMEX.
