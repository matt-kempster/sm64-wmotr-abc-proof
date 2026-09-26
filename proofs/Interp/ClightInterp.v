(* kept: general tool -- an executable, fuel-bounded interpreter for CompCert
   Clight, PROVED SOUND against ClightBigstep (function_entry2).  Uses:
   run real generated SM64 functions inside Rocq (vm_compute), build
   non-vacuity / positive-control witnesses by reflection, and extract a CLI. *)

(* Design.
   - [ev_expr]/[ev_lvalue]: structural, total functions mirroring
     Clight.eval_expr/eval_lvalue rule-for-rule.
   - [ex_stmt]/[ex_call]: mutual, fuel-bounded, mirroring exec_stmt/eval_funcall.
     A [Stuck] result (unsupported construct, oracle refusal, UB, out of fuel)
     is a debugging report, never a claim about the program.  Only [Done]
     results carry meaning.
   - External calls go through an ORACLE [extcall].  Soundness requires the oracle
     to agree with CompCert's [external_call]; that premise is the one explicit
     trust point, and is exactly the "what do black-box functions do" assumption.
   - Unsupported (reported as Stuck, which is sound): bitfields, Slabel/Sgoto. *)

From Coq Require Import String.
From compcert Require Import Coqlib Errors Maps Integers Floats Values AST Memory
  Events Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Interp.CMem.
Module CM := SM64.Proofs.Interp.CMem.

Local Notation "'let?' x := a 'in' b" :=
  (match a with Some x => b | None => None end)
  (at level 200, x ident, a at level 100, b at level 200).

Section INTERP.

Variable ge : genv.
Variable extcall : external_function -> list val -> mem -> option (trace * val * mem).

(* ---------------------------------------------------------------- *)
(* Loads and stores                                                   *)
(* ---------------------------------------------------------------- *)

Definition ev_deref (ty : type) (m : mem) (b : block) (ofs : ptrofs)
    (bf : bitfield) : option val :=
  match bf with
  | Full =>
      match access_mode ty with
      | By_value chunk => CM.loadv chunk m (Vptr b ofs)
      | By_reference | By_copy => Some (Vptr b ofs)
      | By_nothing => None
      end
  | Bits _ _ _ _ => None
  end.

Definition copy_ok (ty : type) (b : block) (ofs : ptrofs) (b' : block)
    (ofs' : ptrofs) : bool :=
  let sz := sizeof ge ty in
  let al := alignof_blockcopy ge ty in
  (if zlt 0 sz then
     (if Znumtheory.Zdivide_dec al (Ptrofs.unsigned ofs') then true else false)
     && (if Znumtheory.Zdivide_dec al (Ptrofs.unsigned ofs) then true else false)
   else true)
  && (negb (eq_block b' b)
      || zeq (Ptrofs.unsigned ofs') (Ptrofs.unsigned ofs)
      || zle (Ptrofs.unsigned ofs' + sz) (Ptrofs.unsigned ofs)
      || zle (Ptrofs.unsigned ofs + sz) (Ptrofs.unsigned ofs')).

Definition ev_assign (ty : type) (m : mem) (b : block) (ofs : ptrofs)
    (bf : bitfield) (v : val) : option mem :=
  match bf with
  | Full =>
      match access_mode ty with
      | By_value chunk => CM.storev chunk m (Vptr b ofs) v
      | By_copy =>
          match v with
          | Vptr b' ofs' =>
              if copy_ok ty b ofs b' ofs' then
                let? bytes := CM.loadbytes m b' (Ptrofs.unsigned ofs') (sizeof ge ty) in
                CM.storebytes m b (Ptrofs.unsigned ofs) bytes
              else None
          | _ => None
          end
      | _ => None
      end
  | Bits _ _ _ _ => None
  end.

(* ---------------------------------------------------------------- *)
(* Expressions                                                        *)
(* ---------------------------------------------------------------- *)

Definition var_loc (e : env) (id : ident) (ty : type) : option (block * ptrofs * bitfield) :=
  match e ! id with
  | Some (l, ty') => if type_eq ty' ty then Some (l, Ptrofs.zero, Full) else None
  | None =>
      match Genv.find_symbol ge id with
      | Some l => Some (l, Ptrofs.zero, Full)
      | None => None
      end
  end.

Definition field_loc (tya : type) (i : ident) (l : block) (ofs : ptrofs)
    : option (block * ptrofs * bitfield) :=
  match tya with
  | Tstruct id _ =>
      match (genv_cenv ge) ! id with
      | Some co =>
          match field_offset ge i (co_members co) with
          | OK (delta, bf) => Some (l, Ptrofs.add ofs (Ptrofs.repr delta), bf)
          | Error _ => None
          end
      | None => None
      end
  | Tunion id _ =>
      match (genv_cenv ge) ! id with
      | Some co =>
          match union_field_offset ge i (co_members co) with
          | OK (delta, bf) => Some (l, Ptrofs.add ofs (Ptrofs.repr delta), bf)
          | Error _ => None
          end
      | None => None
      end
  | _ => None
  end.

Section EXPR.
Variables (e : env) (le : temp_env) (m : mem).

Fixpoint ev_expr (a : expr) : option val :=
  match a with
  | Econst_int i _ => Some (Vint i)
  | Econst_float f _ => Some (Vfloat f)
  | Econst_single f _ => Some (Vsingle f)
  | Econst_long i _ => Some (Vlong i)
  | Etempvar id _ => le ! id
  | Eaddrof a1 _ =>
      match ev_lvalue a1 with
      | Some (l, ofs, Full) => Some (Vptr l ofs)
      | _ => None
      end
  | Eunop op a1 _ =>
      let? v1 := ev_expr a1 in sem_unary_operation op v1 (typeof a1) m
  | Ebinop op a1 a2 _ =>
      let? v1 := ev_expr a1 in
      let? v2 := ev_expr a2 in
      sem_binary_operation ge op v1 (typeof a1) v2 (typeof a2) m
  | Ecast a1 ty => let? v1 := ev_expr a1 in sem_cast v1 (typeof a1) ty m
  | Esizeof ty1 _ => Some (Vptrofs (Ptrofs.repr (sizeof ge ty1)))
  | Ealignof ty1 _ => Some (Vptrofs (Ptrofs.repr (alignof ge ty1)))
  | Evar id ty =>
      match var_loc e id ty with
      | Some (l, ofs, bf) => ev_deref ty m l ofs bf
      | None => None
      end
  | Ederef a1 ty =>
      match ev_expr a1 with
      | Some (Vptr l ofs) => ev_deref ty m l ofs Full
      | _ => None
      end
  | Efield a1 i ty =>
      match ev_expr a1 with
      | Some (Vptr l ofs) =>
          match field_loc (typeof a1) i l ofs with
          | Some (l', ofs', bf) => ev_deref ty m l' ofs' bf
          | None => None
          end
      | _ => None
      end
  end

with ev_lvalue (a : expr) : option (block * ptrofs * bitfield) :=
  match a with
  | Evar id ty => var_loc e id ty
  | Ederef a1 _ =>
      match ev_expr a1 with
      | Some (Vptr l ofs) => Some (l, ofs, Full)
      | _ => None
      end
  | Efield a1 i _ =>
      match ev_expr a1 with
      | Some (Vptr l ofs) => field_loc (typeof a1) i l ofs
      | _ => None
      end
  | _ => None
  end.

Fixpoint ev_exprlist (al : list expr) (tyl : list type) : option (list val) :=
  match al, tyl with
  | nil, nil => Some nil
  | a :: bl, ty :: tyl' =>
      let? v1 := ev_expr a in
      let? v2 := sem_cast v1 (typeof a) ty m in
      let? vl := ev_exprlist bl tyl' in
      Some (v2 :: vl)
  | _, _ => None
  end.

End EXPR.

(* ---------------------------------------------------------------- *)
(* Function entry                                                     *)
(* ---------------------------------------------------------------- *)

Fixpoint ev_alloc (e : env) (m : mem) (vars : list (ident * type)) : env * mem :=
  match vars with
  | nil => (e, m)
  | (id, ty) :: vars' =>
      let (m1, b1) := Mem.alloc m 0 (sizeof ge ty) in
      ev_alloc (PTree.set id (b1, ty) e) m1 vars'
  end.

Definition ev_entry (f : function) (vargs : list val) (m : mem)
    : option (env * temp_env * mem) :=
  if list_norepet_dec ident_eq (var_names f.(fn_vars)) then
  if list_norepet_dec ident_eq (var_names f.(fn_params)) then
  if list_disjoint_dec ident_eq (var_names f.(fn_params)) (var_names f.(fn_temps)) then
    let (e, m') := ev_alloc empty_env m f.(fn_vars) in
    let? le := bind_parameter_temps f.(fn_params) vargs (create_undef_temps f.(fn_temps)) in
    Some (e, le, m')
  else None else None else None.

Definition ev_result (out : outcome) (t : type) (m : mem) : option val :=
  match out, t with
  | Out_normal, Tvoid => Some Vundef
  | Out_return None, Tvoid => Some Vundef
  | Out_return (Some (v', t')), ty =>
      if type_eq ty Tvoid then None else sem_cast v' t' ty m
  | _, _ => None
  end.

(* ---------------------------------------------------------------- *)
(* Statements and calls                                               *)
(* ---------------------------------------------------------------- *)

(* A run either finishes, or reports WHERE it got stuck: the call stack (callee
   idents, innermost first), the statement it could not execute, and why.  The
   report is small, so vm_compute readback stays cheap even over huge programs. *)
Inductive res (A : Type) : Type :=
  | Done (a : A)
  | Stuck (stack : list ident) (s : statement) (why : String.string).
Arguments Done {A}.
Arguments Stuck {A}.

Definition need {A} (o : option A) (s : statement) (why : String.string) : res A :=
  match o with Some a => Done a | None => Stuck nil s why end.

Local Notation "'do?' x <- a ; b" :=
  (match a with Done x => b | Stuck st s w => Stuck st s w end)
  (at level 200, x ident, a at level 100, b at level 200).

Definition ef_label (ef : external_function) : String.string :=
  match ef with
  | EF_external n _ => n
  | EF_builtin n _ | EF_runtime n _ => n
  | EF_memcpy _ _ => "memcpy"
  | _ => "other builtin"
  end.

Definition callee_id (a : expr) : ident :=
  match a with Evar id _ => id | _ => 1%positive end.

Local Open Scope string_scope.

Fixpoint ex_stmt (fuel : nat) (e : env) (le : temp_env) (m : mem) (s : statement)
    {struct fuel} : res (trace * temp_env * mem * outcome) :=
  match fuel with
  | O => Stuck nil s "out of fuel"
  | S fuel' =>
  match s with
  | Sskip => Done (E0, le, m, Out_normal)
  | Sassign a1 a2 =>
      do? lv <- need (ev_lvalue e le m a1) s "lvalue";
      let '(loc, ofs, bf) := lv in
      do? v2 <- need (ev_expr e le m a2) s "rhs";
      do? v <- need (sem_cast v2 (typeof a2) (typeof a1) m) s "cast";
      do? m' <- need (ev_assign (typeof a1) m loc ofs bf v) s "store";
      Done (E0, le, m', Out_normal)
  | Sset id a =>
      do? v <- need (ev_expr e le m a) s "expr";
      Done (E0, PTree.set id v le, m, Out_normal)
  | Scall optid a al =>
      match classify_fun (typeof a) with
      | fun_case_f tyargs tyres cconv =>
          do? vf <- need (ev_expr e le m a) s "callee";
          do? vargs <- need (ev_exprlist e le m al tyargs) s "args";
          do? f <- need (Genv.find_funct ge vf) s "no such function";
          if type_eq (type_of_fundef f) (Tfunction tyargs tyres cconv) then
            match ex_call fuel' m f vargs with
            | Done (t, m', vres) => Done (t, set_opttemp optid vres le, m', Out_normal)
            | Stuck st s' w => Stuck (callee_id a :: st) s' w
            end
          else Stuck nil s "callee type mismatch"
      | _ => Stuck nil s "not a function type"
      end
  | Sbuiltin optid ef tyargs al =>
      do? vargs <- need (ev_exprlist e le m al tyargs) s "args";
      match extcall ef vargs m with
      | Some (t, vres, m') => Done (t, set_opttemp optid vres le, m', Out_normal)
      | None => Stuck nil s ("oracle refused builtin " ++ ef_label ef)
      end
  | Ssequence s1 s2 =>
      match ex_stmt fuel' e le m s1 with
      | Done (t1, le1, m1, Out_normal) =>
          match ex_stmt fuel' e le1 m1 s2 with
          | Done (t2, le2, m2, out) => Done (t1 ** t2, le2, m2, out)
          | Stuck st s' w => Stuck st s' w
          end
      | r => r
      end
  | Sifthenelse a s1 s2 =>
      do? v1 <- need (ev_expr e le m a) s "condition";
      do? b <- need (bool_val v1 (typeof a) m) s "bool_val";
      ex_stmt fuel' e le m (if b then s1 else s2)
  | Sreturn None => Done (E0, le, m, Out_return None)
  | Sreturn (Some a) =>
      do? v <- need (ev_expr e le m a) s "return value";
      Done (E0, le, m, Out_return (Some (v, typeof a)))
  | Sbreak => Done (E0, le, m, Out_break)
  | Scontinue => Done (E0, le, m, Out_continue)
  | Sloop s1 s2 =>
      match ex_stmt fuel' e le m s1 with
      | Done (t1, le1, m1, Out_break) => Done (t1, le1, m1, Out_normal)
      | Done (t1, le1, m1, Out_return ov) => Done (t1, le1, m1, Out_return ov)
      | Done (t1, le1, m1, _) =>
          match ex_stmt fuel' e le1 m1 s2 with
          | Done (t2, le2, m2, Out_break) => Done (t1 ** t2, le2, m2, Out_normal)
          | Done (t2, le2, m2, Out_return ov) => Done (t1 ** t2, le2, m2, Out_return ov)
          | Done (t2, le2, m2, Out_normal) =>
              match ex_stmt fuel' e le2 m2 (Sloop s1 s2) with
              | Done (t3, le3, m3, out) => Done (t1 ** t2 ** t3, le3, m3, out)
              | Stuck st s' w => Stuck st s' w
              end
          | Done _ => Stuck nil s "continue in loop increment"
          | Stuck st s' w => Stuck st s' w
          end
      | Stuck st s' w => Stuck st s' w
      end
  | Sswitch a sl =>
      do? v <- need (ev_expr e le m a) s "switch scrutinee";
      do? n <- need (sem_switch_arg v (typeof a)) s "switch arg";
      match ex_stmt fuel' e le m (seq_of_labeled_statement (select_switch n sl)) with
      | Done (t, le1, m1, out) => Done (t, le1, m1, outcome_switch out)
      | Stuck st s' w => Stuck st s' w
      end
  | Slabel _ _ | Sgoto _ => Stuck nil s "goto/label unsupported"
  end
  end

with ex_call (fuel : nat) (m : mem) (f : fundef) (vargs : list val)
    {struct fuel} : res (trace * mem * val) :=
  match fuel with
  | O => Stuck nil Sskip "out of fuel (call)"
  | S fuel' =>
  match f with
  | Internal fn =>
      do? ent <- need (ev_entry fn vargs m) fn.(fn_body) "function entry";
      let '(e, le1, m1) := ent in
      match ex_stmt fuel' e le1 m1 fn.(fn_body) with
      | Done (t, le2, m2, out) =>
          do? vres <- need (ev_result out fn.(fn_return) m2) Sskip "result value";
          do? m3 <- need (CM.free_list m2 (blocks_of_env ge e)) Sskip "free locals";
          Done (t, m3, vres)
      | Stuck st s' w => Stuck st s' w
      end
  | External ef _ _ _ =>
      match extcall ef vargs m with
      | Some (t, vres, m') => Done (t, m', vres)
      | None => Stuck nil Sskip ("oracle refused " ++ ef_label ef)
      end
  end
  end.

(* ================================================================ *)
(* SOUNDNESS                                                          *)
(* ================================================================ *)

Hypothesis extcall_sound :
  forall ef vargs m t v m',
    extcall ef vargs m = Some (t, v, m') -> external_call ef ge vargs m t v m'.

Lemma ev_deref_sound : forall ty m b ofs bf v,
    ev_deref ty m b ofs bf = Some v -> deref_loc ty m b ofs bf v.
Proof.
  unfold ev_deref; intros ty m b ofs bf v H.
  destruct bf; [ | discriminate].
  destruct (access_mode ty) eqn:Ham; try discriminate.
  - rewrite CM.loadv_eq in H. eapply deref_loc_value; eauto.
  - inv H. eapply deref_loc_reference; eauto.
  - inv H. eapply deref_loc_copy; eauto.
Qed.

Lemma ev_assign_sound : forall ty m b ofs bf v m',
    ev_assign ty m b ofs bf v = Some m' -> assign_loc ge ty m b ofs bf v m'.
Proof.
  unfold ev_assign; intros ty m b ofs bf v m' H.
  destruct bf; [ | discriminate].
  destruct (access_mode ty) eqn:Ham; try discriminate.
  - rewrite CM.storev_eq in H. eapply assign_loc_value; eauto.
  - destruct v; try discriminate.
    destruct (copy_ok ty b ofs b0 i) eqn:Hok; [ | discriminate].
    destruct (CM.loadbytes m b0 (Ptrofs.unsigned i) (sizeof ge ty)) as [bytes|] eqn:Hlb;
      [ | discriminate].
    rewrite CM.loadbytes_eq in Hlb. rewrite CM.storebytes_eq in H.
    unfold copy_ok in Hok.
    repeat rewrite andb_true_iff in Hok. destruct Hok as [Hal Hdisj].
    eapply assign_loc_copy; eauto.
    + intros Hpos. destruct (zlt 0 (sizeof ge ty)); [ | lia].
      apply andb_true_iff in Hal. destruct Hal as [H1 _].
      destruct (Znumtheory.Zdivide_dec _ _); [assumption | discriminate].
    + intros Hpos. destruct (zlt 0 (sizeof ge ty)); [ | lia].
      apply andb_true_iff in Hal. destruct Hal as [_ H2].
      destruct (Znumtheory.Zdivide_dec _ _); [assumption | discriminate].
    + repeat rewrite orb_true_iff in Hdisj.
      destruct Hdisj as [[[Hb | Hz] | Hl1] | Hl2].
      * left. destruct (eq_block b0 b); [discriminate | assumption].
      * right; left. destruct (zeq _ _); [assumption | discriminate].
      * right; right; left. destruct (zle _ _); [assumption | discriminate].
      * right; right; right. destruct (zle _ _); [assumption | discriminate].
Qed.

Lemma var_loc_sound : forall e le m id ty l ofs bf,
    var_loc e id ty = Some (l, ofs, bf) -> eval_lvalue ge e le m (Evar id ty) l ofs bf.
Proof.
  unfold var_loc; intros e le m id ty l ofs bf H.
  destruct (e ! id) as [[l' ty']|] eqn:He.
  - destruct (type_eq ty' ty); [ | discriminate]. inv H.
    apply eval_Evar_local; auto.
  - destruct (Genv.find_symbol ge id) eqn:Hs; [ | discriminate]. inv H.
    apply eval_Evar_global; auto.
Qed.

Lemma field_loc_sound : forall e le m a i ty l ofs l' ofs' bf,
    eval_expr ge e le m a (Vptr l ofs) ->
    field_loc (typeof a) i l ofs = Some (l', ofs', bf) ->
    eval_lvalue ge e le m (Efield a i ty) l' ofs' bf.
Proof.
  unfold field_loc; intros e le m a i ty l ofs l' ofs' bf Hev H.
  destruct (typeof a) eqn:Hty; try discriminate.
  - destruct ((genv_cenv ge) ! i0) as [co|] eqn:Hco; [ | discriminate].
    destruct (field_offset ge i (co_members co)) as [[delta bf']|] eqn:Hfo; [ | discriminate].
    inv H. eapply eval_Efield_struct; eauto.
  - destruct ((genv_cenv ge) ! i0) as [co|] eqn:Hco; [ | discriminate].
    destruct (union_field_offset ge i (co_members co)) as [[delta bf']|] eqn:Hfo; [ | discriminate].
    inv H. eapply eval_Efield_union; eauto.
Qed.

Lemma ev_expr_lvalue_sound : forall e le m a,
    (forall v, ev_expr e le m a = Some v -> eval_expr ge e le m a v) /\
    (forall l ofs bf, ev_lvalue e le m a = Some (l, ofs, bf) -> eval_lvalue ge e le m a l ofs bf).
Proof.
  intros e le m a.
  induction a; split; intros; simpl in *; try discriminate.
  - inv H; constructor.
  - inv H; constructor.
  - inv H; constructor.
  - inv H; constructor.
  - (* Evar rvalue *)
    destruct (var_loc e i t) as [[[l ofs] bf]|] eqn:Hvl; [ | discriminate].
    eapply eval_Elvalue.
    + eapply var_loc_sound; eauto.
    + apply ev_deref_sound; auto.
  - (* Evar lvalue *) eapply var_loc_sound; eauto.
  - (* Etempvar *) constructor; auto.
  - (* Ederef rvalue *)
    destruct IHa as [IHe _].
    destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    destruct v1; try discriminate.
    eapply eval_Elvalue.
    + apply eval_Ederef. apply IHe; auto.
    + apply ev_deref_sound; auto.
  - (* Ederef lvalue *)
    destruct IHa as [IHe _].
    destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    destruct v1; try discriminate. inv H.
    apply eval_Ederef. apply IHe; auto.
  - (* Eaddrof *)
    destruct IHa as [_ IHl].
    destruct (ev_lvalue e le m a) as [[[l ofs] bf]|] eqn:Ha; [ | discriminate].
    destruct bf; [ | discriminate]. inv H.
    constructor. apply IHl; auto.
  - (* Eunop *)
    destruct IHa as [IHe _].
    destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    econstructor; eauto.
  - (* Ebinop *)
    destruct IHa1 as [IHe1 _]. destruct IHa2 as [IHe2 _].
    destruct (ev_expr e le m a1) as [v1|] eqn:Ha1; [ | discriminate].
    destruct (ev_expr e le m a2) as [v2|] eqn:Ha2; [ | discriminate].
    econstructor; eauto.
  - (* Ecast *)
    destruct IHa as [IHe _].
    destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    econstructor; eauto.
  - (* Efield rvalue *)
    destruct IHa as [IHe _].
    destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    destruct v1; try discriminate.
    destruct (field_loc (typeof a) i b i0) as [[[l' ofs'] bf]|] eqn:Hfl; [ | discriminate].
    eapply eval_Elvalue.
    + eapply field_loc_sound; eauto.
    + apply ev_deref_sound; auto.
  - (* Efield lvalue *)
    destruct IHa as [IHe _].
    destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    destruct v1; try discriminate.
    eapply field_loc_sound; eauto.
  - inv H; constructor.
  - inv H; constructor.
Qed.

Lemma ev_expr_sound : forall e le m a v,
    ev_expr e le m a = Some v -> eval_expr ge e le m a v.
Proof. intros. apply (ev_expr_lvalue_sound e le m a); auto. Qed.

Lemma ev_lvalue_sound : forall e le m a l ofs bf,
    ev_lvalue e le m a = Some (l, ofs, bf) -> eval_lvalue ge e le m a l ofs bf.
Proof. intros. apply (ev_expr_lvalue_sound e le m a); auto. Qed.

Lemma ev_exprlist_sound : forall e le m al tyl vl,
    ev_exprlist e le m al tyl = Some vl -> eval_exprlist ge e le m al tyl vl.
Proof.
  induction al; destruct tyl; intros vl H; simpl in H; try discriminate.
  - inv H. constructor.
  - destruct (ev_expr e le m a) as [v1|] eqn:Ha; [ | discriminate].
    destruct (sem_cast v1 (typeof a) t m) as [v2|] eqn:Hc; [ | discriminate].
    destruct (ev_exprlist e le m al tyl) as [vl'|] eqn:Hl; [ | discriminate].
    inv H. econstructor; eauto using ev_expr_sound.
Qed.

Lemma ev_alloc_sound : forall vars e m e' m',
    ev_alloc e m vars = (e', m') -> alloc_variables ge e m vars e' m'.
Proof.
  induction vars as [|[id ty] vars IH]; intros e m e' m' H; simpl in H.
  - inv H. constructor.
  - destruct (Mem.alloc m 0 (sizeof ge ty)) as [m1 b1] eqn:Ha.
    econstructor; eauto.
Qed.

Lemma ev_entry_sound : forall f vargs m e le m',
    ev_entry f vargs m = Some (e, le, m') -> function_entry2 ge f vargs m e le m'.
Proof.
  unfold ev_entry; intros f vargs m e le m' H.
  destruct (list_norepet_dec _ _) as [H1|]; [ | discriminate].
  destruct (list_norepet_dec _ _) as [H2|]; [ | discriminate].
  destruct (list_disjoint_dec _ _ _) as [H3|]; [ | discriminate].
  destruct (ev_alloc empty_env m (fn_vars f)) as [e0 m0] eqn:Ha.
  destruct (bind_parameter_temps _ _ _) as [le0|] eqn:Hb; [ | discriminate].
  inv H. constructor; auto. apply ev_alloc_sound; auto.
Qed.

Lemma ev_result_sound : forall out t m v,
    ev_result out t m = Some v -> outcome_result_value out t v m.
Proof.
  unfold ev_result, outcome_result_value; intros out t m v H.
  destruct out as [ | | | [[v' t']|] ]; destruct t; try discriminate;
    try (inv H; reflexivity);
    (destruct (type_eq _ Tvoid) as [Heq|Hne]; [discriminate | split; auto]).
Qed.


Lemma need_ok : forall A (o : option A) s w a, need o s w = Done a -> o = Some a.
Proof. unfold need; intros; destruct o; congruence. Qed.

Ltac needs :=
  repeat match goal with
  | H : need ?o _ _ = Done _ |- _ => apply need_ok in H
  end.

Theorem ex_sound : forall fuel,
    (forall e le m s t le' m' out,
        ex_stmt fuel e le m s = Done (t, le', m', out) ->
        exec_stmt function_entry2 ge e le m s t le' m' out) /\
    (forall m f vargs t m' vres,
        ex_call fuel m f vargs = Done (t, m', vres) ->
        eval_funcall function_entry2 ge m f vargs t m' vres).
Proof.
  induction fuel as [|fuel IH]; split; intros; simpl in H; try discriminate;
    destruct IH as [IHs IHc].
  - (* statements *)
    destruct s; simpl in H; try discriminate.
    + inv H. constructor.
    + (* Sassign *)
      destruct (need (ev_lvalue e le m e0) _ _) as [[[loc ofs] bf]| ? ? ?] eqn:Hl; [ | discriminate].
      destruct (need (ev_expr e le m e1) _ _) as [v2| ? ? ?] eqn:He; [ | discriminate].
      destruct (need (sem_cast v2 _ _ m) _ _) as [v| ? ? ?] eqn:Hc; [ | discriminate].
      destruct (need (ev_assign _ m loc ofs bf v) _ _) as [m1| ? ? ?] eqn:Has; [ | discriminate].
      needs. inv H. econstructor; eauto using ev_lvalue_sound, ev_expr_sound, ev_assign_sound.
    + (* Sset *)
      destruct (need (ev_expr e le m e0) _ _) as [v| ? ? ?] eqn:He; [ | discriminate].
      needs. inv H. constructor. apply ev_expr_sound; auto.
    + (* Scall *)
      destruct (classify_fun (typeof e0)) as [tyargs tyres cconv| ] eqn:Hcf; try discriminate.
      destruct (need (ev_expr e le m e0) _ _) as [vf| ? ? ?] eqn:He; [ | discriminate].
      destruct (need (ev_exprlist e le m l tyargs) _ _) as [vargs| ? ? ?] eqn:Hel; [ | discriminate].
      destruct (need (Genv.find_funct ge vf) _ _) as [f| ? ? ?] eqn:Hf; [ | discriminate].
      destruct (type_eq (type_of_fundef f) (Tfunction tyargs tyres cconv)); [ | discriminate].
      destruct (ex_call fuel m f vargs) as [[[t0 m1] vres]| ? ? ?] eqn:Hcall; [ | discriminate].
      needs. inv H. econstructor; eauto using ev_expr_sound, ev_exprlist_sound.
    + (* Sbuiltin *)
      destruct (need (ev_exprlist e le m l0 l) _ _) as [vargs| ? ? ?] eqn:Hel; [ | discriminate].
      destruct (extcall e0 vargs m) as [[[t0 vres] m1]|] eqn:Hx; [ | discriminate].
      needs. inv H. econstructor; eauto using ev_exprlist_sound.
    + (* Ssequence *)
      destruct (ex_stmt fuel e le m s1) as [[[[t1 le1] m1] out1]| ? ? ?] eqn:H1; [ | discriminate].
      destruct out1.
      * inv H. eapply exec_Sseq_2; eauto. discriminate.
      * inv H. eapply exec_Sseq_2; eauto. discriminate.
      * destruct (ex_stmt fuel e le1 m1 s2) as [[[[t2 le2] m2] out2]| ? ? ?] eqn:H2; [ | discriminate].
        inv H. eapply exec_Sseq_1; eauto.
      * inv H. eapply exec_Sseq_2; eauto. discriminate.
    + (* Sifthenelse *)
      destruct (need (ev_expr e le m e0) _ _) as [v1| ? ? ?] eqn:He; [ | discriminate].
      destruct (need (bool_val v1 (typeof e0) m) _ _) as [b| ? ? ?] eqn:Hb; [ | discriminate].
      needs. econstructor; eauto using ev_expr_sound.
    + (* Sloop *)
      destruct (ex_stmt fuel e le m s1) as [[[[t1 le1] m1] out1]| ? ? ?] eqn:H1; [ | discriminate].
      destruct out1.
      * inv H. eapply exec_Sloop_stop1; eauto. constructor.
      * destruct (ex_stmt fuel e le1 m1 s2) as [[[[t2 le2] m2] out2]| ? ? ?] eqn:H2; [ | discriminate].
        destruct out2; try discriminate.
        -- inv H. eapply exec_Sloop_stop2; eauto. constructor. constructor.
        -- destruct (ex_stmt fuel e le2 m2 (Sloop s1 s2)) as [[[[t3 le3] m3] out3]| ? ? ?] eqn:H3;
             [ | discriminate].
           inv H. eapply exec_Sloop_loop; eauto. constructor.
        -- inv H. eapply exec_Sloop_stop2; eauto. constructor. constructor.
      * destruct (ex_stmt fuel e le1 m1 s2) as [[[[t2 le2] m2] out2]| ? ? ?] eqn:H2; [ | discriminate].
        destruct out2; try discriminate.
        -- inv H. eapply exec_Sloop_stop2; eauto. constructor. constructor.
        -- destruct (ex_stmt fuel e le2 m2 (Sloop s1 s2)) as [[[[t3 le3] m3] out3]| ? ? ?] eqn:H3;
             [ | discriminate].
           inv H. eapply exec_Sloop_loop; eauto. constructor.
        -- inv H. eapply exec_Sloop_stop2; eauto. constructor. constructor.
      * inv H. eapply exec_Sloop_stop1; eauto. constructor.
    + inv H. constructor.
    + inv H. constructor.
    + (* Sreturn *)
      destruct o as [a|].
      * destruct (need (ev_expr e le m a) _ _) as [v| ? ? ?] eqn:He; [ | discriminate].
        needs. inv H. constructor. apply ev_expr_sound; auto.
      * inv H. constructor.
    + (* Sswitch *)
      destruct (need (ev_expr e le m e0) _ _) as [v| ? ? ?] eqn:He; [ | discriminate].
      destruct (need (sem_switch_arg v (typeof e0)) _ _) as [n| ? ? ?] eqn:Hsw; [ | discriminate].
      destruct (ex_stmt fuel e le m (seq_of_labeled_statement (select_switch n l)))
        as [[[[t1 le1] m1] out1]| ? ? ?] eqn:H1; [ | discriminate].
      needs. inv H. econstructor; eauto using ev_expr_sound.
  - (* calls *)
    destruct f as [fn | ef targs tres cconv].
    + destruct (need (ev_entry fn vargs m) _ _) as [[[e le1] m1]| ? ? ?] eqn:Hen; [ | discriminate].
      destruct (ex_stmt fuel e le1 m1 (fn_body fn)) as [[[[t1 le2] m2] out]| ? ? ?] eqn:Hb;
        [ | discriminate].
      destruct (need (ev_result out (fn_return fn) m2) _ _) as [v| ? ? ?] eqn:Hr; [ | discriminate].
      destruct (need (CM.free_list m2 (blocks_of_env ge e)) _ _) as [m3| ? ? ?] eqn:Hfr;
        [ | discriminate].
      needs. rewrite CM.free_list_eq in Hfr.
      inv H. econstructor; eauto using ev_entry_sound, ev_result_sound.
    + destruct (extcall ef vargs m) as [[[t0 v] m1]|] eqn:Hx; [ | discriminate].
      inv H. constructor. auto.
Qed.

Corollary ex_call_sound : forall fuel m f vargs t m' vres,
    ex_call fuel m f vargs = Done (t, m', vres) ->
    eval_funcall function_entry2 ge m f vargs t m' vres.
Proof. intros. apply (ex_sound fuel); auto. Qed.

End INTERP.
