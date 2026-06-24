(* ====================================================================== *)
(* THE RETURN-VALUE SURFACE: a reached function never RETURNS a pointer    *)
(* into Mario's block UNLESS its return type can carry one (SPINE:         *)
(* consumed by the MWF-grounded capstone to discharge the bulk of          *)
(* Hret_call with ZERO new trust).                                         *)
(*                                                                        *)
(* The bottom line.  The v2 engine's Hret_call leaf asks: for every        *)
(* reached funcall whose result is a pointer Vptr b o, b <> bm.  On        *)
(* ptr64 = false a Vptr can only survive a return cast through             *)
(* cast_case_pointer, and classify_cast picks cast_case_pointer ONLY when  *)
(* the TARGET (= fn_return) is Tint I32 or a pointer type.  So a reached   *)
(* Internal whose fn_return is Tvoid / Tint I8/I16/IBool / Tfloat can      *)
(* NEVER return a Vptr at all -- its Hret_call obligation is vacuous,      *)
(* discharged here with no assumption about the program.                   *)
(*                                                                        *)
(* This eliminates the ~17 void/sub-word-int-returning reached functions   *)
(* (11 void censused + update_mario_button_inputs + the void rest          *)
(* dispatch helpers + level_trigger_warp's s16 return) from the residual   *)
(* surface.  Of the remaining Tint I32 returns, fd_is_vint discharges the   *)
(* "computed int" functions with ZERO program assumption, via TWO arms:     *)
(*   - the TEMP arm (fn_vint_temp): a return temp only ever assigned a      *)
(*     vint_expr (getters, predicates like mario_facing_downhill);          *)
(*   - the CONSTANT arm (ret_const_chk, added 2026-06-24): every return     *)
(*     site is a vint_expr directly, no temp -- e.g. mario_floor_is_        *)
(*     slippery (return 0 / return 1 in separate branches), a REACHED       *)
(*     predicate the temp arm misses.                                       *)
(* What STILL remains -- ret_fd_safe = false AND fd_is_vint = false -- is   *)
(* the I32 dispatchers whose result is a CALL result or a field load        *)
(* (execute_mario_action returns gMarioState->particleFlags; the 6 per-     *)
(* category mario_execute_*_action return the _cancel call-result) and the  *)
(* External fundefs (the honest terminal-external boundary, e.g. EF_vload). *)
(* Those stay as Hret_unsafe at the capstone -- the call-result/field-load  *)
(* cases need the value/MWF return engine (see hret-dispatcher-closure).    *)
(* ====================================================================== *)

From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Events Globalenvs Ctypes Cop Clight ClightBigstep.

(* A return type that can NEVER let a Vptr through sem_cast on ptr64=false:
   only Tint I32 and Tpointer select cast_case_pointer (the sole Vptr-
   producing cast case besides the struct/union/void passthroughs, which
   classify_cast never picks for an int/float target). *)
Definition ret_ty_safe (t : type) : bool :=
  match t with
  | Tvoid => true
  | Tint I32 _ _ => false
  | Tint _ _ _ => true        (* I8 / I16 / IBool *)
  | Tfloat _ _ => true
  | _ => false                (* Tint I32, Tlong, Tpointer, struct/union/... *)
  end.

Definition ret_fd_safe (fd : Clight.fundef) : bool :=
  match fd with
  | Internal f => ret_ty_safe (fn_return f)
  | External _ _ _ _ => false
  end.

(* ---------------------------------------------------------------------- *)
(* sem_cast into a non-I32 int / float target never produces a Vptr.      *)
(* ---------------------------------------------------------------------- *)

(* classify_cast into a sub-word int target is one of the numeric cast
   cases -- never pointer / struct / union / void. *)
Lemma classify_cast_to_subint_numeric : forall t1 sz si a,
  sz <> I32 ->
  match classify_cast t1 (Tint sz si a) with
  | cast_case_pointer => False
  | cast_case_struct _ _ => False
  | cast_case_union _ _ => False
  | cast_case_void => False
  | _ => True
  end.
Proof.
  intros t1 sz si a Hsz.
  destruct sz; try (exfalso; apply Hsz; reflexivity);
  destruct t1; cbn;
  first
    [ exact I
    | match goal with
      | |- context[match ?ff with F32 => _ | F64 => _ end] => destruct ff; cbn; exact I
      end
    | destruct Archi.ptr64; cbn; exact I ].
Qed.

Lemma classify_cast_to_float_numeric : forall t1 sz a,
  match classify_cast t1 (Tfloat sz a) with
  | cast_case_pointer => False
  | cast_case_struct _ _ => False
  | cast_case_union _ _ => False
  | cast_case_void => False
  | _ => True
  end.
Proof.
  intros t1 sz a.
  destruct sz; destruct t1; cbn;
  first
    [ exact I
    | match goal with
      | |- context[match ?ff with F32 => _ | F64 => _ end] => destruct ff; cbn; exact I
      end
    | destruct Archi.ptr64; cbn; exact I ].
Qed.

(* A cast that OUTPUTS a Vptr must have had a Vptr INPUT: every sem_cast
   case but the pointer / struct / union / void passthroughs builds a
   fresh non-pointer value. *)
Lemma sem_cast_Vptr_through : forall v t1 t2 m b o,
  sem_cast v t1 t2 m = Some (Vptr b o) -> v = Vptr b o.
Proof.
  intros v t1 t2 m b o Hsc.
  unfold sem_cast in Hsc.
  destruct (classify_cast t1 t2); destruct v;
    repeat (match type of Hsc with
            | context[match ?x with Some _ => _ | None => _ end] => destruct x
            | context[if ?c then _ else _] => destruct c
            end);
    try discriminate Hsc; try (inversion Hsc; reflexivity).
Qed.

Lemma sem_cast_int_not_ptr : forall v t1 sz si a m b o,
  sz <> I32 -> sem_cast v t1 (Tint sz si a) m = Some (Vptr b o) -> False.
Proof.
  intros v t1 sz si a m b o Hsz Hsc.
  pose proof (sem_cast_Vptr_through _ _ _ _ _ _ Hsc) as Hv. subst v.
  pose proof (classify_cast_to_subint_numeric t1 sz si a Hsz) as Hnum.
  unfold sem_cast in Hsc.
  destruct (classify_cast t1 (Tint sz si a)); cbn in Hnum; try exact Hnum;
    (repeat (match type of Hsc with
             | context[if ?c then _ else _] => destruct c
             end);
     discriminate Hsc).
Qed.

Lemma sem_cast_float_not_ptr : forall v t1 sz a m b o,
  sem_cast v t1 (Tfloat sz a) m = Some (Vptr b o) -> False.
Proof.
  intros v t1 sz a m b o Hsc.
  pose proof (sem_cast_Vptr_through _ _ _ _ _ _ Hsc) as Hv. subst v.
  pose proof (classify_cast_to_float_numeric t1 sz a) as Hnum.
  unfold sem_cast in Hsc.
  destruct (classify_cast t1 (Tfloat sz a)); cbn in Hnum; try exact Hnum;
    (repeat (match type of Hsc with
             | context[if ?c then _ else _] => destruct c
             end);
     discriminate Hsc).
Qed.

(* ---------------------------------------------------------------------- *)
(* THE STRUCTURAL LEMMA: a safe-return-type Internal funcall never         *)
(* returns a Vptr.                                                         *)
(* ---------------------------------------------------------------------- *)

Lemma eval_funcall_ret_safe :
  forall fe ge m f vargs t m' vres,
    eval_funcall fe ge m (Internal f) vargs t m' vres ->
    ret_ty_safe (fn_return f) = true ->
    forall b o, vres <> Vptr b o.
Proof.
  intros fe ge m f vargs t m' vres Hev Hsafe b o Hvp. subst vres.
  inv Hev.
  match goal with
  | H : outcome_result_value ?out ?rt (Vptr b o) ?mm |- _ => rename H into Hout
  end.
  unfold ret_ty_safe in Hsafe.
  unfold outcome_result_value in Hout.
  destruct (fn_return f) eqn:Eret; try discriminate Hsafe.
  - (* Tvoid *)
    destruct out as [ | | | [[v' t']| ]];
      try (exact Hout); try discriminate Hout.
    destruct Hout as [Hne _]. exact (Hne eq_refl).
  - (* Tint i s a, i <> I32 *)
    destruct i; try discriminate Hsafe;
      destruct out as [ | | | [[v' t']| ]];
      try (exact Hout);
      destruct Hout as [_ Hsc];
      (eapply sem_cast_int_not_ptr; [ | exact Hsc ]); discriminate.
  - (* Tfloat f a *)
    destruct out as [ | | | [[v' t']| ]];
      try (exact Hout);
      destruct Hout as [_ Hsc];
      eapply sem_cast_float_not_ptr; exact Hsc.
Qed.

(* ---------------------------------------------------------------------- *)
(* THE ASSEMBLY: Hret_call for ANY reached predicate reduces to the        *)
(* SHARPER residual restricted to ret_fd_safe fd = false (Tint I32 / ptr   *)
(* returning Internals + all Externals).                                   *)
(* ---------------------------------------------------------------------- *)

Lemma ret_avoids_bm_of_unsafe :
  forall fe ge bm (reached : Clight.fundef -> Prop),
    (forall fd m0 vargs0 t0 m0' vres0,
        reached fd -> ret_fd_safe fd = false ->
        eval_funcall fe ge m0 fd vargs0 t0 m0' vres0 ->
        forall b o, vres0 = Vptr b o -> b <> bm) ->
    forall fd m0 vargs0 t0 m0' vres0,
      reached fd ->
      eval_funcall fe ge m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
Proof.
  intros fe ge bm reached Hunsafe fd m0 vargs0 t0 m0' vres0 Hr Hev b o Hvp.
  destruct (ret_fd_safe fd) eqn:Esafe.
  - (* safe-return: the structural lemma rules out vres0 = Vptr *)
    exfalso. destruct fd as [f | ef targs tres cc].
    + cbn in Esafe.
      exact (eval_funcall_ret_safe fe ge m0 f vargs0 t0 m0' vres0 Hev Esafe b o Hvp).
    + cbn in Esafe. discriminate Esafe.
  - (* unsafe-return: the sharper residual *)
    exact (Hunsafe fd m0 vargs0 t0 m0' vres0 Hr Esafe Hev b o Hvp).
Qed.

(* ====================================================================== *)
(* SHARPER STILL: a "computed-int" return temp.                            *)
(*                                                                        *)
(* An I32-returning Internal whose RETURN TEMP is only ever assigned an     *)
(* integer computation (an int constant, a bitwise/shift op, a comparison,  *)
(* or a sub-word cast -- never pointer arithmetic, never a call result)     *)
(* NEVER returns a Vptr, so its Hret obligation is vacuous with ZERO        *)
(* program assumption.  This discharges the "computed-int getters" half of  *)
(* the ret_fd_safe=false residual (mario_get_floor_class /                  *)
(* mario_get_terrain_sound_addend): their result temp is built only from    *)
(* int constants, shifts and comparisons, and the body returns that temp.   *)
(* (The dispatchers, whose result IS a call temp, need an eval_funcall      *)
(* closure -- a later slice -- and stay in Hret_unsafe.)                    *)
(* ====================================================================== *)

Definition no_vptr_val (v : val) : Prop := forall b o, v <> Vptr b o.
Definition no_vptr_opt (ov : option val) : Prop :=
  forall b o, ov <> Some (Vptr b o).

(* binary ops whose result, when defined, is never a pointer: bitwise ops,
   shifts and comparisons all build a Vint/Vlong/Vfloat/Vsingle or fail --
   unlike Oadd/Osub, which on a pointer operand yield a Vptr. *)
Definition vint_binop (op : binary_operation) : bool :=
  match op with
  | Oand | Oor | Oxor | Oshl | Oshr => true
  | Oeq | One | Olt | Ogt | Ole | Oge => true
  | _ => false
  end.

(* expressions whose eval, when it succeeds, is never a Vptr. *)
Definition vint_expr (e : expr) : bool :=
  match e with
  | Econst_int _ _ => true
  | Ebinop op _ _ _ => vint_binop op
  | Ecast _ (Tint I8 _ _) => true
  | Ecast _ (Tint I16 _ _) => true
  | Ecast _ (Tint IBool _ _) => true
  | _ => false
  end.

Definition expr_is_temp (e : expr) (vt : ident) : bool :=
  match e with Etempvar id _ => Pos.eqb id vt | _ => false end.

(* ---- expression soundness: a vint_expr never evaluates to a pointer ---- *)

(* a result built by sem_binarith is one of the combiner outputs -- never a
   pointer, as long as each combiner returns a non-pointer (or None). *)
Lemma sem_binarith_not_vptr :
  forall si sl sf ss v1 t1 v2 t2 m v,
    sem_binarith si sl sf ss v1 t1 v2 t2 m = Some v ->
    (forall s n1 n2 r, si s n1 n2 = Some r -> no_vptr_val r) ->
    (forall s n1 n2 r, sl s n1 n2 = Some r -> no_vptr_val r) ->
    (forall n1 n2 r, sf n1 n2 = Some r -> no_vptr_val r) ->
    (forall n1 n2 r, ss n1 n2 = Some r -> no_vptr_val r) ->
    no_vptr_val v.
Proof.
  intros si sl sf ss v1 t1 v2 t2 m v Hsb Hi Hl Hf Hs.
  unfold sem_binarith in Hsb.
  destruct (sem_cast v1 t1 _ m) as [v1'|]; [ | discriminate Hsb ].
  destruct (sem_cast v2 t2 _ m) as [v2'|]; [ | discriminate Hsb ].
  destruct (classify_binarith t1 t2);
    destruct v1'; try discriminate Hsb; destruct v2'; try discriminate Hsb;
    first [ eapply Hi; exact Hsb | eapply Hl; exact Hsb
          | eapply Hf; exact Hsb | eapply Hs; exact Hsb ].
Qed.

(* sem_cmp always builds Val.of_bool (= a Vint) or fails. *)
Lemma cmp_ptr_not_vptr :
  forall m c v1 v2 v, cmp_ptr m c v1 v2 = Some v -> no_vptr_val v.
Proof.
  intros m c v1 v2 v H b o ->.
  unfold cmp_ptr, option_map in H.
  destruct (if Archi.ptr64
            then Val.cmplu_bool (Mem.valid_pointer m) c v1 v2
            else Val.cmpu_bool (Mem.valid_pointer m) c v1 v2) as [bb|];
    [ inv H; destruct bb; discriminate | discriminate H ].
Qed.

Lemma sem_cmp_not_vptr :
  forall c v1 t1 v2 t2 m v,
    sem_cmp c v1 t1 v2 t2 m = Some v -> no_vptr_val v.
Proof.
  intros c v1 t1 v2 t2 m v Hsc.
  unfold sem_cmp in Hsc.
  destruct (classify_cmp t1 t2);
    repeat (match type of Hsc with
            | context[match ?x with _ => _ end] => destruct x
            | context[if ?b then _ else _] => destruct b
            end);
    try discriminate Hsc;
    try (eapply cmp_ptr_not_vptr; exact Hsc);
    try (eapply sem_binarith_not_vptr; [ exact Hsc | | | | ];
         intros until r; intro Hr; inv Hr; intros bb oo HH;
         unfold Val.of_bool in HH;
         match type of HH with context[if ?c then _ else _] => destruct c end;
         discriminate HH).
Qed.

(* a shift always builds a Vint/Vlong or fails. *)
Lemma sem_shift_not_vptr :
  forall si sl v1 t1 v2 t2 v,
    sem_shift si sl v1 t1 v2 t2 = Some v -> no_vptr_val v.
Proof.
  intros si sl v1 t1 v2 t2 v Hsh.
  unfold sem_shift in Hsh.
  destruct (classify_shift t1 t2);
    destruct v1; try discriminate Hsh; destruct v2; try discriminate Hsh;
    repeat (match type of Hsh with
            | context[if ?c then _ else _] => destruct c
            end); try discriminate Hsh;
    inv Hsh; intros bb oo HH; discriminate HH.
Qed.

Lemma sem_binop_vint_not_vptr :
  forall cenv op v1 t1 v2 t2 m v,
    vint_binop op = true ->
    sem_binary_operation cenv op v1 t1 v2 t2 m = Some v ->
    no_vptr_val v.
Proof.
  intros cenv op v1 t1 v2 t2 m v Hop Hsem.
  destruct op; cbn in Hop; try discriminate Hop; cbn in Hsem.
  - (* Oand *) unfold sem_and in Hsem.
    eapply sem_binarith_not_vptr; [ exact Hsem | | | | ];
      intros until r; intro Hr;
      first [ discriminate Hr | (inv Hr; intros bb oo HH; discriminate HH) ].
  - (* Oor *) unfold sem_or in Hsem.
    eapply sem_binarith_not_vptr; [ exact Hsem | | | | ];
      intros until r; intro Hr;
      first [ discriminate Hr | (inv Hr; intros bb oo HH; discriminate HH) ].
  - (* Oxor *) unfold sem_xor in Hsem.
    eapply sem_binarith_not_vptr; [ exact Hsem | | | | ];
      intros until r; intro Hr;
      first [ discriminate Hr | (inv Hr; intros bb oo HH; discriminate HH) ].
  - (* Oshl *) unfold sem_shl in Hsem. eapply sem_shift_not_vptr; exact Hsem.
  - (* Oshr *) unfold sem_shr in Hsem. eapply sem_shift_not_vptr; exact Hsem.
  - (* Oeq *) eapply sem_cmp_not_vptr; exact Hsem.
  - (* One *) eapply sem_cmp_not_vptr; exact Hsem.
  - (* Olt *) eapply sem_cmp_not_vptr; exact Hsem.
  - (* Ogt *) eapply sem_cmp_not_vptr; exact Hsem.
  - (* Ole *) eapply sem_cmp_not_vptr; exact Hsem.
  - (* Oge *) eapply sem_cmp_not_vptr; exact Hsem.
Qed.

Lemma vint_expr_not_vptr :
  forall ge e le m a v,
    eval_expr ge e le m a v ->
    vint_expr a = true ->
    no_vptr_val v.
Proof.
  intros ge e le m a v Hev Hve.
  destruct a; cbn in Hve; try discriminate Hve.
  - (* Econst_int *) inv Hev;
      try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
      intros b o HH; discriminate HH.
  - (* Ebinop *) inv Hev;
      try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
      match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        eapply sem_binop_vint_not_vptr; [ exact Hve | exact Hsem ] end.
  - (* Ecast *) destruct t as [ | isz isg iat | lsg lat | fsz fat | pt pat | at1 az aat | ftl frt fcc | sid sat | uid uat ];
      try (cbn in Hve; discriminate Hve);
      destruct isz; try (cbn in Hve; discriminate Hve);
      inv Hev;
      try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
      intros b o ->;
      match goal with Hsc : sem_cast _ _ (Tint ?sz _ _) _ = Some _ |- _ =>
        eapply (sem_cast_int_not_ptr _ _ sz); [ discriminate | exact Hsc ] end.
Qed.

(* ---- the body walker: every assignment to the result temp vt is a
   vint_expr, vt is never a call target, and every return is `return vt`
   or a vint_expr. ---- *)

Fixpoint vint_body_chk (vt : ident) (s : statement) : bool :=
  match s with
  | Sskip => true
  | Sassign _ _ => true
  | Sset id e => if Pos.eqb id vt then vint_expr e else true
  | Scall optid _ _ =>
      match optid with Some id => negb (Pos.eqb id vt) | None => true end
  | Sbuiltin optid _ _ _ =>
      match optid with Some id => negb (Pos.eqb id vt) | None => true end
  | Ssequence s1 s2 => vint_body_chk vt s1 && vint_body_chk vt s2
  | Sifthenelse _ s1 s2 => vint_body_chk vt s1 && vint_body_chk vt s2
  | Sloop s1 s2 => vint_body_chk vt s1 && vint_body_chk vt s2
  | Sbreak => true
  | Scontinue => true
  | Sreturn None => true
  | Sreturn (Some e) => expr_is_temp e vt || vint_expr e
  | Sswitch _ ls => vint_body_chk_ls vt ls
  | Slabel _ s1 => vint_body_chk vt s1
  | Sgoto _ => true
  end
with vint_body_chk_ls (vt : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s ls' => vint_body_chk vt s && vint_body_chk_ls vt ls'
  end.

(* the switch selection of a chk'd list is chk'd (a tail / concatenation). *)
Lemma select_switch_case_vint : forall vt n ls sl',
  vint_body_chk_ls vt ls = true ->
  select_switch_case n ls = Some sl' ->
  vint_body_chk_ls vt sl' = true.
Proof.
  intros vt n ls. induction ls as [|olbl s ls' IH]; intros sl' Hchk Hsel; cbn in *.
  - discriminate Hsel.
  - destruct olbl as [z|].
    + destruct (zeq z n).
      * inv Hsel. exact Hchk.
      * apply andb_true_iff in Hchk. apply IH; [ apply Hchk | exact Hsel ].
    + apply andb_true_iff in Hchk. apply IH; [ apply Hchk | exact Hsel ].
Qed.

Lemma select_switch_default_vint : forall vt ls,
  vint_body_chk_ls vt ls = true ->
  vint_body_chk_ls vt (select_switch_default ls) = true.
Proof.
  intros vt ls. induction ls as [|olbl s ls' IH]; intros Hchk; cbn in *.
  - exact Hchk.
  - destruct olbl as [z|].
    + apply andb_true_iff in Hchk. apply IH. apply Hchk.
    + cbn. exact Hchk.
Qed.

Lemma select_switch_vint : forall vt n ls,
  vint_body_chk_ls vt ls = true ->
  vint_body_chk_ls vt (select_switch n ls) = true.
Proof.
  intros vt n ls Hchk. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - eapply select_switch_case_vint; [ exact Hchk | exact E ].
  - apply select_switch_default_vint; exact Hchk.
Qed.

Lemma seq_of_ls_vint : forall vt ls,
  vint_body_chk_ls vt ls = true ->
  vint_body_chk vt (seq_of_labeled_statement ls) = true.
Proof.
  intros vt ls. induction ls as [|olbl s ls' IH]; intros Hchk; cbn in *.
  - reflexivity.
  - apply andb_true_iff in Hchk. destruct Hchk as [Hs Hls].
    apply andb_true_iff. split; [ exact Hs | apply IH; exact Hls ].
Qed.

Definition no_vptr_ret (out : outcome) : Prop :=
  forall v ty, out = Out_return (Some (v, ty)) -> no_vptr_val v.

(* out_break_or_return: if the OUTER outcome is a value-return, so is the inner. *)
Lemma obor_return : forall out1 out v ty,
  out_break_or_return out1 out ->
  out = Out_return (Some (v, ty)) ->
  out1 = Out_return (Some (v, ty)).
Proof. intros out1 out v ty H Hc. inv H; congruence. Qed.

(* ---- the exec_stmt invariant: a vint_body_chk'd statement keeps vt
   non-pointer and, if it returns, returns a non-pointer. ---- *)

Lemma exec_stmt_vint :
  forall vt ge e le m s t le' m' out,
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    vint_body_chk vt s = true ->
    no_vptr_opt (le ! vt) ->
    no_vptr_opt (le' ! vt) /\ no_vptr_ret out.
Proof.
  intros vt ge.
  set (P := fun (e:env) (le:temp_env) (m:mem) (s:statement) (t:trace)
                (le':temp_env) (m':mem) (out:outcome) =>
              vint_body_chk vt s = true -> no_vptr_opt (le ! vt) ->
              no_vptr_opt (le' ! vt) /\ no_vptr_ret out).
  set (Q := fun (m:mem) (fd:fundef) (vargs:list val) (t:trace)
                (m':mem) (vres:val) => True).
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> P e le m s t le' m' out)
    /\ (forall m fd vargs t m' vres,
          eval_funcall function_entry2 ge m fd vargs t m' vres -> Q m fd vargs t m' vres)).
  { apply (exec_stmt_funcall_ind function_entry2 ge P Q); unfold P, Q; clear P Q.
    - (* Sskip *) intros e le m _ Hnp.
      split; [ exact Hnp | intros v ty Hc; discriminate Hc ].
    - (* Sassign *) intros e le m a1 a2 loc ofs bf v2 v mm' Hlv Hee Hcast Hassign _ Hnp.
      split; [ exact Hnp | intros v0 ty Hc; discriminate Hc ].
    - (* Sset *) intros e le m id a v Hee Hchk Hnp.
      cbn in Hchk. split; [ | intros v0 ty Hc; discriminate Hc ].
      destruct (Pos.eqb id vt) eqn:E.
      + apply Pos.eqb_eq in E. subst id.
        intros b o HH. rewrite PTree.gss in HH.
        apply (vint_expr_not_vptr ge e le m a v Hee Hchk b o). congruence.
      + apply Pos.eqb_neq in E. intros b o HH.
        rewrite PTree.gso in HH by (intro; apply E; congruence). exact (Hnp b o HH).
    - (* Scall *) intros e le m optid a al tyargs tyres cconv vf vargs fd t' mm' vres
        Hcf Hee Hel Hff Htof Hfd _ Hchk Hnp.
      cbn in Hchk. split; [ | intros v0 ty Hc; discriminate Hc ].
      destruct optid as [id|].
      + apply negb_true_iff in Hchk. apply Pos.eqb_neq in Hchk.
        cbn. intros b o HH. rewrite PTree.gso in HH by (intro; apply Hchk; congruence).
        exact (Hnp b o HH).
      + cbn. exact Hnp.
    - (* Sbuiltin *) intros e le m optid ef tyargs al vargs t' mm' vres Hel Hec Hchk Hnp.
      cbn in Hchk. split; [ | intros v0 ty Hc; discriminate Hc ].
      destruct optid as [id|].
      + apply negb_true_iff in Hchk. apply Pos.eqb_neq in Hchk.
        cbn. intros b o HH. rewrite PTree.gso in HH by (intro; apply Hchk; congruence).
        exact (Hnp b o HH).
      + cbn. exact Hnp.
    - (* Sseq_1 *) intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 Hchk Hnp.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 Hc2].
      destruct (IH1 Hc1 Hnp) as [Hnp1 _].
      exact (IH2 Hc2 Hnp1).
    - (* Sseq_2 *) intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout Hchk Hnp.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 _].
      exact (IH1 Hc1 Hnp).
    - (* Sifthenelse *) intros e le m a s1 s2 v1 bb t' lee m' out Hee Hbool Hexec IH Hchk Hnp.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 Hc2].
      apply IH; [ destruct bb; [ exact Hc1 | exact Hc2 ] | exact Hnp ].
    - (* Sreturn_none *) intros e le m _ Hnp.
      split; [ exact Hnp | intros v ty Hc; discriminate Hc ].
    - (* Sreturn_some *) intros e le m a v Hee Hchk Hnp.
      cbn in Hchk. split; [ exact Hnp | ].
      assert (Hnv : no_vptr_val v).
      { apply orb_true_iff in Hchk. destruct Hchk as [Het | Hvi].
        - unfold expr_is_temp in Het. destruct a; cbn in Het; try discriminate Het.
          apply Pos.eqb_eq in Het. subst i.
          intros b o HH. subst v. inv Hee;
            [ match goal with H : le ! vt = Some (Vptr b o) |- _ => exact (Hnp b o H) end
            | match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end ].
        - exact (vint_expr_not_vptr ge e le m a v Hee Hvi). }
      intros v0 ty Hc. inv Hc. exact Hnv.
    - (* Sbreak *) intros e le m _ Hnp.
      split; [ exact Hnp | intros v ty Hc; discriminate Hc ].
    - (* Scontinue *) intros e le m _ Hnp.
      split; [ exact Hnp | intros v ty Hc; discriminate Hc ].
    - (* Sloop_stop1 *) intros e le m s1 s2 t' lee m' out1 out He1 IH1 Hbor Hchk Hnp.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 _].
      destruct (IH1 Hc1 Hnp) as [Hnp1 Hret1].
      split; [ exact Hnp1 | ].
      intros v ty Hc. exact (Hret1 v ty (obor_return _ _ _ _ Hbor Hc)).
    - (* Sloop_stop2 *) intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
        He1 IH1 Hnc He2 IH2 Hbor Hchk Hnp.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 Hc2].
      destruct (IH1 Hc1 Hnp) as [Hnp1 _].
      destruct (IH2 Hc2 Hnp1) as [Hnp2 Hret2].
      split; [ exact Hnp2 | ].
      intros v ty Hc. exact (Hret2 v ty (obor_return _ _ _ _ Hbor Hc)).
    - (* Sloop_loop *) intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
        He1 IH1 Hnc1 He2 IH2 He3 IH3 Hchk Hnp.
      cbn in Hchk. pose proof Hchk as Hchk'. apply andb_true_iff in Hchk.
      destruct Hchk as [Hc1 Hc2].
      destruct (IH1 Hc1 Hnp) as [Hnp1 _].
      destruct (IH2 Hc2 Hnp1) as [Hnp2 _].
      exact (IH3 Hchk' Hnp2).
    - (* Sswitch *) intros e le m a t' v n sl le1 m1 out1 Hee Hsel Hexec IH Hchk Hnp.
      cbn in Hchk.
      assert (Hcsel : vint_body_chk vt (seq_of_labeled_statement (select_switch n sl)) = true).
      { apply seq_of_ls_vint. apply select_switch_vint. exact Hchk. }
      destruct (IH Hcsel Hnp) as [Hnp1 Hret1].
      split; [ exact Hnp1 | ].
      intros v0 ty Hc. unfold outcome_switch in Hc.
      destruct out1; try discriminate Hc.
      exact (Hret1 v0 ty Hc).
    - (* eval_funcall_internal *) intros; exact I.
    - (* eval_funcall_external *) intros; exact I. }
  intros e le m s t le' m' out Hexec Hchk Hnp.
  exact (proj1 MAIN e le m s t le' m' out Hexec Hchk Hnp).
Qed.

(* a non-parameter temp keeps its base-environment value after binding. *)
Lemma bind_parameter_temps_other :
  forall params vargs base le id,
    bind_parameter_temps params vargs base = Some le ->
    ~ In id (var_names params) ->
    le ! id = base ! id.
Proof.
  induction params as [|[p ty] params' IH]; intros vargs base le id Hbind Hnin; cbn in Hbind.
  - destruct vargs; [ | discriminate Hbind ]. inv Hbind. reflexivity.
  - destruct vargs as [|v vargs']; [ discriminate Hbind | ].
    cbn in Hnin.
    assert (Hne : p <> id) by (intro He; apply Hnin; left; exact He).
    assert (Hnin' : ~ In id (var_names params'))
      by (intro Hin; apply Hnin; right; exact Hin).
    erewrite IH; [ | exact Hbind | exact Hnin' ].
    rewrite PTree.gso by congruence. reflexivity.
Qed.

(* a non-parameter temp is non-pointer at function entry (it is Vundef from
   create_undef_temps, or absent). *)
Lemma entry_temp_no_vptr : forall vt f vargs le,
  ~ In vt (var_names (fn_params f)) ->
  bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le ->
  no_vptr_opt (le ! vt).
Proof.
  intros vt f vargs le Hnin Hbind.
  erewrite bind_parameter_temps_other; [ | exact Hbind | exact Hnin ].
  assert (Hcu : forall l, (create_undef_temps l) ! vt = None
                          \/ (create_undef_temps l) ! vt = Some Vundef).
  { induction l as [|[p ty] l' IH]; cbn.
    - left. apply PTree.gempty.
    - destruct (Pos.eq_dec p vt).
      + subst p. right. rewrite PTree.gss. reflexivity.
      + rewrite PTree.gso by congruence. exact IH. }
  intros b o HH.
  destruct (Hcu (fn_temps f)) as [HN | HV];
    rewrite HH in HN || rewrite HH in HV; [ discriminate HN | discriminate HV ].
Qed.

(* THE FUNCALL LEMMA: an I32-returning Internal with a vint-tracked result
   temp never returns a Vptr. *)
Lemma eval_funcall_ret_vint :
  forall ge f vargs m t m' vres vt,
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    fn_vars f = nil ->
    ~ In vt (var_names (fn_params f)) ->
    vint_body_chk vt (fn_body f) = true ->
    fn_return f <> Tvoid ->
    no_vptr_val vres.
Proof.
  intros ge f vargs m t m' vres vt Hfun Hvars Hnin Hchk Hretty.
  inv Hfun.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Hav; inv Hav end.
  match goal with
  | Hexec : exec_stmt function_entry2 ge empty_env ?le _ (fn_body f) _ ?lez _ ?out,
    Hbind : bind_parameter_temps _ _ _ = Some ?le,
    Hout : outcome_result_value ?out _ vres _ |- _ =>
      assert (Hentry : no_vptr_opt (le ! vt))
        by (eapply entry_temp_no_vptr; [ exact Hnin | exact Hbind ]);
      destruct (exec_stmt_vint vt ge empty_env le _ (fn_body f) _ lez _ out
                  Hexec Hchk Hentry) as [_ Hret];
      destruct out as [ | | | [[v0 ty0]| ]]; cbn in Hout;
      [ (* Out_normal *) destruct (fn_return f); cbn in Hout;
          solve [ contradiction | exfalso; apply Hretty; reflexivity ]
      | (* Out_break *) destruct (fn_return f); cbn in Hout; contradiction
      | (* Out_continue *) destruct (fn_return f); cbn in Hout; contradiction
      | (* Out_return (Some (v0, ty0)) *)
          destruct Hout as [_ Hcast];
          intros b o ->;
          assert (Hnp : no_vptr_val v0) by (eapply Hret; reflexivity);
          pose proof (sem_cast_Vptr_through v0 ty0 _ _ b o Hcast) as Hv0;
          exact (Hnp b o Hv0)
      | (* Out_return None *) destruct (fn_return f); cbn in Hout;
          solve [ contradiction | exfalso; apply Hretty; reflexivity ] ]
  end.
Qed.

(* ---------------------------------------------------------------------- *)
(* THE CONSTANT-RETURN WALKER.  Some I32-returning reached functions never  *)
(* return a temp at all: every `return` site is a vint_expr (a literal /    *)
(* bitwise / comparison / sub-word cast).  The canonical case is            *)
(* execute_mario_action, whose SOLE return is `return 0` -- the per-        *)
(* category dispatcher results are consumed into the do-while loop flag,    *)
(* never returned.  Such a body needs NO return-temp tracking (hence no     *)
(* fn_vars / param side-conditions): every value-return is directly a       *)
(* vint_expr, so the result is never a Vptr.  ZERO program assumption.      *)
(* ---------------------------------------------------------------------- *)

Fixpoint ret_const_chk (s : statement) : bool :=
  match s with
  | Sreturn (Some e) => vint_expr e
  | Sreturn None => true
  | Ssequence s1 s2 => ret_const_chk s1 && ret_const_chk s2
  | Sifthenelse _ s1 s2 => ret_const_chk s1 && ret_const_chk s2
  | Sloop s1 s2 => ret_const_chk s1 && ret_const_chk s2
  | Sswitch _ ls => ret_const_chk_ls ls
  | Slabel _ s1 => ret_const_chk s1
  | _ => true   (* Sskip/Sassign/Sset/Scall/Sbuiltin/Sbreak/Scontinue/Sgoto *)
  end
with ret_const_chk_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s ls' => ret_const_chk s && ret_const_chk_ls ls'
  end.

Lemma select_switch_case_vconst : forall n ls sl',
  ret_const_chk_ls ls = true ->
  select_switch_case n ls = Some sl' ->
  ret_const_chk_ls sl' = true.
Proof.
  intros n ls. induction ls as [|olbl s ls' IH]; intros sl' Hchk Hsel; cbn in *.
  - discriminate Hsel.
  - destruct olbl as [z|].
    + destruct (zeq z n).
      * inv Hsel. exact Hchk.
      * apply andb_true_iff in Hchk. apply IH; [ apply Hchk | exact Hsel ].
    + apply andb_true_iff in Hchk. apply IH; [ apply Hchk | exact Hsel ].
Qed.

Lemma select_switch_default_vconst : forall ls,
  ret_const_chk_ls ls = true ->
  ret_const_chk_ls (select_switch_default ls) = true.
Proof.
  intros ls. induction ls as [|olbl s ls' IH]; intros Hchk; cbn in *.
  - exact Hchk.
  - destruct olbl as [z|].
    + apply andb_true_iff in Hchk. apply IH. apply Hchk.
    + cbn. exact Hchk.
Qed.

Lemma select_switch_vconst : forall n ls,
  ret_const_chk_ls ls = true ->
  ret_const_chk_ls (select_switch n ls) = true.
Proof.
  intros n ls Hchk. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - eapply select_switch_case_vconst; [ exact Hchk | exact E ].
  - apply select_switch_default_vconst; exact Hchk.
Qed.

Lemma seq_of_ls_vconst : forall ls,
  ret_const_chk_ls ls = true ->
  ret_const_chk (seq_of_labeled_statement ls) = true.
Proof.
  intros ls. induction ls as [|olbl s ls' IH]; intros Hchk; cbn in *.
  - reflexivity.
  - apply andb_true_iff in Hchk. destruct Hchk as [Hs Hls].
    apply andb_true_iff. split; [ exact Hs | apply IH; exact Hls ].
Qed.

(* exec of a ret_const_chk'd statement: if it returns a value, that value is
   never a Vptr.  No temp threading -- the precondition is purely syntactic. *)
Lemma exec_stmt_vconst :
  forall ge e le m s t le' m' out,
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    ret_const_chk s = true ->
    no_vptr_ret out.
Proof.
  intros ge.
  set (P := fun (e:env) (le:temp_env) (m:mem) (s:statement) (t:trace)
                (le':temp_env) (m':mem) (out:outcome) =>
              ret_const_chk s = true -> no_vptr_ret out).
  set (Q := fun (m:mem) (fd:fundef) (vargs:list val) (t:trace)
                (m':mem) (vres:val) => True).
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> P e le m s t le' m' out)
    /\ (forall m fd vargs t m' vres,
          eval_funcall function_entry2 ge m fd vargs t m' vres -> Q m fd vargs t m' vres)).
  { apply (exec_stmt_funcall_ind function_entry2 ge P Q); unfold P, Q; clear P Q.
    - (* Sskip *) intros e le m _; intros v ty Hc; discriminate Hc.
    - (* Sassign *) intros e le m a1 a2 loc ofs bf v2 v mm' Hlv Hee Hcast Hassign _; intros v0 ty Hc; discriminate Hc.
    - (* Sset *) intros e le m id a v Hee _; intros v0 ty Hc; discriminate Hc.
    - (* Scall *) intros e le m optid a al tyargs tyres cconv vf vargs fd t' mm' vres
        Hcf Hee Hel Hff Htof Hfd _ _; intros v0 ty Hc; discriminate Hc.
    - (* Sbuiltin *) intros e le m optid ef tyargs al vargs t' mm' vres Hel Hec _; intros v0 ty Hc; discriminate Hc.
    - (* Sseq_1 *) intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 Hchk.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [_ Hc2].
      exact (IH2 Hc2).
    - (* Sseq_2 *) intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout Hchk.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 _].
      exact (IH1 Hc1).
    - (* Sifthenelse *) intros e le m a s1 s2 v1 bb t' lee m' out Hee Hbool Hexec IH Hchk.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 Hc2].
      apply IH; destruct bb; [ exact Hc1 | exact Hc2 ].
    - (* Sreturn_none *) intros e le m _; intros v ty Hc; discriminate Hc.
    - (* Sreturn_some *) intros e le m a v Hee Hchk.
      cbn in Hchk.
      assert (Hnv : no_vptr_val v) by exact (vint_expr_not_vptr ge e le m a v Hee Hchk).
      intros v0 ty Hc. inv Hc. exact Hnv.
    - (* Sbreak *) intros e le m _; intros v ty Hc; discriminate Hc.
    - (* Scontinue *) intros e le m _; intros v ty Hc; discriminate Hc.
    - (* Sloop_stop1 *) intros e le m s1 s2 t' lee m' out1 out He1 IH1 Hbor Hchk.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [Hc1 _].
      intros v ty Hc. exact (IH1 Hc1 v ty (obor_return _ _ _ _ Hbor Hc)).
    - (* Sloop_stop2 *) intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
        He1 IH1 Hnc He2 IH2 Hbor Hchk.
      cbn in Hchk. apply andb_true_iff in Hchk. destruct Hchk as [_ Hc2].
      intros v ty Hc. exact (IH2 Hc2 v ty (obor_return _ _ _ _ Hbor Hc)).
    - (* Sloop_loop *) intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
        He1 IH1 Hnc1 He2 IH2 He3 IH3 Hchk.
      exact (IH3 Hchk).
    - (* Sswitch *) intros e le m a t' v n sl le1 m1 out1 Hee Hsel Hexec IH Hchk.
      cbn in Hchk.
      assert (Hcsel : ret_const_chk (seq_of_labeled_statement (select_switch n sl)) = true).
      { apply seq_of_ls_vconst. apply select_switch_vconst. exact Hchk. }
      intros v0 ty Hc. unfold outcome_switch in Hc.
      destruct out1; try discriminate Hc.
      exact (IH Hcsel v0 ty Hc).
    - (* eval_funcall_internal *) intros; exact I.
    - (* eval_funcall_external *) intros; exact I. }
  intros e le m s t le' m' out Hexec Hchk.
  exact (proj1 MAIN e le m s t le' m' out Hexec Hchk).
Qed.

(* THE FUNCALL LEMMA: an I32-returning Internal whose every return is a
   vint_expr constant never returns a Vptr. *)
Lemma eval_funcall_ret_vconst :
  forall ge f vargs m t m' vres,
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    ret_const_chk (fn_body f) = true ->
    fn_return f <> Tvoid ->
    no_vptr_val vres.
Proof.
  intros ge f vargs m t m' vres Hfun Hchk Hretty.
  inv Hfun.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with
  | Hexec : exec_stmt function_entry2 ge ?ee ?lee _ (fn_body f) _ ?lez _ ?out,
    Hout : outcome_result_value ?out _ vres _ |- _ =>
      pose proof (exec_stmt_vconst ge ee lee _ (fn_body f) _ lez _ out Hexec Hchk) as Hret;
      destruct out as [ | | | [[v0 ty0]| ]]; cbn in Hout;
      [ (* Out_normal *) destruct (fn_return f); cbn in Hout;
          solve [ contradiction | exfalso; apply Hretty; reflexivity ]
      | (* Out_break *) destruct (fn_return f); cbn in Hout; contradiction
      | (* Out_continue *) destruct (fn_return f); cbn in Hout; contradiction
      | (* Out_return (Some (v0, ty0)) *)
          destruct Hout as [_ Hcast];
          intros b o ->;
          assert (Hnp : no_vptr_val v0) by (eapply Hret; reflexivity);
          pose proof (sem_cast_Vptr_through v0 ty0 _ _ b o Hcast) as Hv0;
          exact (Hnp b o Hv0)
      | (* Out_return None *) destruct (fn_return f); cbn in Hout;
          solve [ contradiction | exfalso; apply Hretty; reflexivity ] ]
  end.
Qed.

(* ---------------------------------------------------------------------- *)
(* A DECIDABLE predicate identifying an Internal whose return value is a   *)
(* "computed int": EITHER a return temp vt that the body vint-tracks       *)
(* (fn_vars empty, vt not a param), OR every return site is a vint_expr    *)
(* constant (ret_const_chk -- the dispatcher case, no temp).  Either way   *)
(* eval_funcall never returns a Vptr.  ZERO program assumption.            *)
(* ---------------------------------------------------------------------- *)

Fixpoint ret_temp_of (s : statement) : option ident :=
  match s with
  | Sreturn (Some (Etempvar id _)) => Some id
  | Ssequence _ s2 => ret_temp_of s2
  | _ => None
  end.

Definition ret_ty_nonvoid (t : type) : bool :=
  match t with Tvoid => false | _ => true end.

Lemma ret_ty_nonvoid_neq : forall t, ret_ty_nonvoid t = true -> t <> Tvoid.
Proof. intros t H; destruct t; cbn in H; try discriminate H; intro Hc; discriminate Hc. Qed.

(* the temp-tracked arm: fn_vars empty, a return temp vt that is not a param
   and is vint-tracked through the body. *)
Definition fn_vint_temp (f : function) : bool :=
  (match fn_vars f with nil => true | _ => false end)
  && (match ret_temp_of (fn_body f) with
      | Some vt =>
          negb (existsb (fun p => Pos.eqb p vt) (var_names (fn_params f)))
          && vint_body_chk vt (fn_body f)
      | None => false
      end).

Definition fn_is_vint (f : function) : bool :=
  ret_ty_nonvoid (fn_return f)
  && (fn_vint_temp f || ret_const_chk (fn_body f)).

Definition fd_is_vint (fd : Clight.fundef) : bool :=
  match fd with Internal f => fn_is_vint f | External _ _ _ _ => false end.

Lemma existsb_eqb_false_not_in : forall vt l,
  existsb (fun p => Pos.eqb p vt) l = false -> ~ In vt l.
Proof.
  intros vt l H Hin.
  assert (Htrue : existsb (fun p => Pos.eqb p vt) l = true).
  { apply existsb_exists. exists vt. split; [ exact Hin | apply Pos.eqb_refl ]. }
  rewrite H in Htrue. discriminate Htrue.
Qed.

(* fd_is_vint fd = true  =>  the return value is never a Vptr. *)
Lemma ret_avoids_bm_of_vint :
  forall ge bm m fd vargs t m' vres,
    fd_is_vint fd = true ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    forall b o, vres = Vptr b o -> b <> bm.
Proof.
  intros ge bm m fd vargs t m' vres Hvint Hfun b o Hvp.
  destruct fd as [f | ]; [ | discriminate Hvint ].
  cbn in Hvint. unfold fn_is_vint in Hvint.
  apply andb_true_iff in Hvint. destruct Hvint as [Hnv Hdisj].
  pose proof (ret_ty_nonvoid_neq _ Hnv) as Hretty.
  apply orb_true_iff in Hdisj. destruct Hdisj as [Htemp | Hconst].
  - (* temp-tracked arm *)
    unfold fn_vint_temp in Htemp.
    apply andb_true_iff in Htemp. destruct Htemp as [Hvars Hbody3].
    destruct (ret_temp_of (fn_body f)) as [vt | ] eqn:Hrt; [ | discriminate Hbody3 ].
    apply andb_true_iff in Hbody3. destruct Hbody3 as [Hnotin Hbody].
    assert (Hvars' : fn_vars f = nil)
      by (destruct (fn_vars f); [ reflexivity | discriminate Hvars ]).
    apply negb_true_iff in Hnotin.
    pose proof (existsb_eqb_false_not_in vt (var_names (fn_params f)) Hnotin) as Hnin.
    pose proof (eval_funcall_ret_vint ge f vargs m t m' vres vt
                  Hfun Hvars' Hnin Hbody Hretty) as Hnvptr.
    exfalso. exact (Hnvptr b o Hvp).
  - (* constant-return arm *)
    pose proof (eval_funcall_ret_vconst ge f vargs m t m' vres Hfun Hconst Hretty) as Hnvptr.
    exfalso. exact (Hnvptr b o Hvp).
Qed.

(* THE SHARPER ASSEMBLY: Hret_call for any reached predicate reduces to the *)
(* residual restricted to ret_fd_safe fd = false AND fd_is_vint fd = false  *)
(* (the I32-returning dispatchers + all Externals -- the getters are gone). *)
Lemma ret_avoids_bm_of_unsafe_vint :
  forall ge bm (reached : Clight.fundef -> Prop),
    (forall fd m0 vargs0 t0 m0' vres0,
        reached fd -> ret_fd_safe fd = false -> fd_is_vint fd = false ->
        eval_funcall function_entry2 ge m0 fd vargs0 t0 m0' vres0 ->
        forall b o, vres0 = Vptr b o -> b <> bm) ->
    forall fd m0 vargs0 t0 m0' vres0,
      reached fd ->
      eval_funcall function_entry2 ge m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
Proof.
  intros ge bm reached Hres fd m0 vargs0 t0 m0' vres0 Hr Hev b o Hvp.
  destruct (ret_fd_safe fd) eqn:Esafe.
  - (* safe-return: structurally impossible to be a Vptr *)
    exfalso. destruct fd as [f | ef targs tres cc].
    + cbn in Esafe.
      exact (eval_funcall_ret_safe function_entry2 ge m0 f vargs0 t0 m0' vres0 Hev Esafe b o Hvp).
    + cbn in Esafe. discriminate Esafe.
  - destruct (fd_is_vint fd) eqn:Evint.
    + (* vint getter: discharged with zero trust *)
      exact (ret_avoids_bm_of_vint ge bm m0 fd vargs0 t0 m0' vres0 Evint Hev b o Hvp).
    + (* the sharper remaining residual *)
      exact (Hres fd m0 vargs0 t0 m0' vres0 Hr Esafe Evint Hev b o Hvp).
Qed.
