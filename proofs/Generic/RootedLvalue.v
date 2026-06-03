(* RootedLvalue.v -- the GENERAL "store rooted at temp p lands in p's block"
 * inverter, genv-GENERIC (works for every TU). Unblocks the deeply-nested chase
 * stores (o->header.gfx.pos[i], t->throwMatrix[i][j], ...) that the single-level
 * inverters (exec_field_store_block, ArrayStore) cannot reach.
 *
 * IDEA: an expression "rooted at p" is one built from the temp p by struct/array
 * accessors only (Efield on an aggregate, Ederef of an aggregate, Ebinop Oadd for
 * array indexing). Every such accessor PRESERVES the block (struct fields are read
 * By_copy, arrays By_reference, ptr+int keeps the pointer's block). So a rooted
 * expression always evaluates to a pointer in p's block -- proven by mutual
 * induction over eval_expr/eval_lvalue. A store whose lvalue is rooted at p thus
 * lands in p's block.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From Coq Require Import Bool.

(* aggregate types are accessed By_copy (struct/union) or By_reference (array) --
   never By_value, so dereferencing one yields the address (block preserved). *)
Definition is_aggregate (ty : type) : bool :=
  match ty with
  | Tstruct _ _ | Tunion _ _ | Tarray _ _ _ => true
  | _ => false
  end.

(* pointer/array types: the left operand of array-index pointer arithmetic. *)
Definition is_ptr_or_arr (ty : type) : bool :=
  match ty with
  | Tpointer _ _ | Tarray _ _ _ => true
  | _ => false
  end.

(* an expression that, evaluated as an rvalue, is a pointer into p's block. The
   Ebinop Oadd case guards typeof a' as ptr/array so the add is genuinely ptr+int
   (classify_add = add_case_pi/pl), the only shapes that keep the pointer's block. *)
Fixpoint rooted_rv (p : ident) (a : expr) : bool :=
  match a with
  | Etempvar q _        => Pos.eqb q p
  | Efield a' _ ty      => is_aggregate ty && rooted_rv p a'
  | Ederef a' ty        => is_aggregate ty && rooted_rv p a'
  | Ebinop Oadd a' _ _  => is_ptr_or_arr (typeof a') && rooted_rv p a'
  | _                   => false
  end.

(* an lvalue whose location is in p's block. eval_lvalue (Ederef a)/(Efield a)
   both evaluate a as an rvalue, so this defers to rooted_rv on the sub-expr. *)
Definition rooted_lv (p : ident) (a : expr) : bool :=
  match a with
  | Ederef a' _   => rooted_rv p a'
  | Efield a' _ _ => rooted_rv p a'
  | _             => false
  end.

(* Dereferencing an aggregate yields the address unchanged. *)
Lemma deref_loc_aggregate_inv :
  forall ty m b o bf v,
    is_aggregate ty = true ->
    deref_loc ty m b o bf v ->
    v = Vptr b o.
Proof.
  intros ty m b o bf v Hagg Hdl.
  destruct ty; simpl in Hagg; try discriminate;
  inv Hdl; try reflexivity;
  try (match goal with Hac : access_mode _ = By_value _ |- _ => discriminate Hac end);
  try (match goal with H : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv H end).
Qed.

(* A pointer-typed left operand added to anything that succeeds yields a pointer
   in the left operand's block. With t1 a pointer/array type, classify_add is
   add_case_pi / add_case_pl (the int+ptr/long+ptr/arith cases need t1 numeric and
   are ruled out). *)
Lemma sem_add_l_ptr :
  forall cenv b1 o1 t1 v2 t2 m v,
    is_ptr_or_arr t1 = true ->
    sem_binary_operation cenv Oadd (Vptr b1 o1) t1 v2 t2 m = Some v ->
    exists blk ofs, v = Vptr blk ofs /\ blk = b1.
Proof.
  intros cenv b1 o1 t1 v2 t2 m v Hptr Hsem.
  unfold sem_binary_operation, sem_add in Hsem.
  destruct (classify_add t1 t2) eqn:Hc.
  - unfold sem_add_ptr_int in Hsem. destruct v2; try discriminate;
      try (destruct Archi.ptr64); try discriminate; inv Hsem; eauto.
  - unfold sem_add_ptr_long in Hsem. destruct v2; try discriminate;
      try (destruct Archi.ptr64); try discriminate; inv Hsem; eauto.
  - exfalso. destruct t1; simpl in Hptr; try discriminate;
      unfold classify_add in Hc; simpl in Hc; destruct (typeconv t2); discriminate.
  - exfalso. destruct t1; simpl in Hptr; try discriminate;
      unfold classify_add in Hc; simpl in Hc; destruct (typeconv t2); discriminate.
  - exfalso. destruct t1; simpl in Hptr; try discriminate;
      unfold sem_binarith in Hsem; simpl in Hsem; discriminate.
Qed.

(* THE MAIN LEMMA. Every expression rooted at p evaluates (as rvalue) to a pointer
   in p's block; every lvalue rooted at p has its location in p's block. By mutual
   induction over eval_expr / eval_lvalue. *)
Lemma rooted_block :
  forall ge e le m p pb po,
    le ! p = Some (Vptr pb po) ->
    (forall a v, eval_expr ge e le m a v -> rooted_rv p a = true ->
        exists blk ofs, v = Vptr blk ofs /\ blk = pb)
    /\ (forall a loc ofs bf, eval_lvalue ge e le m a loc ofs bf -> rooted_lv p a = true ->
        loc = pb).
Proof.
  intros ge e le m p pb po Hp.
  apply eval_expr_lvalue_ind; intros.
  all: try (solve [ simpl in *; discriminate ]).
  - (* Etempvar *)
    match goal with Hr : rooted_rv _ (Etempvar _ _) = true |- _ =>
      simpl in Hr; apply Pos.eqb_eq in Hr; subst end;
    match goal with H : _ ! _ = Some _ |- _ => rewrite Hp in H; inv H end; eauto.
  - (* Ebinop Oadd *)
    match goal with Hr : rooted_rv _ (Ebinop ?op _ _ _) = true |- _ =>
      simpl in Hr; destruct op; try discriminate Hr;
      apply andb_true_iff in Hr; destruct Hr as [Hpt Hrv] end;
    match goal with
    | Hrv' : rooted_rv ?pp ?x = true, IH1 : rooted_rv ?pp ?x = true -> _ |- _ =>
        specialize (IH1 Hrv'); destruct IH1 as (blk1 & ofs1 & Hv1 & Hb1); subst end;
    match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
      eapply sem_add_l_ptr in Hsem; [ exact Hsem | exact Hpt ] end.
  - (* Elvalue: deref of an aggregate keeps the block *)
    match goal with Hr : rooted_rv _ ?a0 = true |- _ =>
      destruct a0;
        try (match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inv Hlv] end);
        simpl in Hr; try discriminate Hr;
        apply andb_true_iff in Hr; destruct Hr as [Hagg Hrv] end;
    match goal with Hdl : deref_loc _ _ _ _ _ _ |- _ =>
      cbn [typeof] in Hdl; apply deref_loc_aggregate_inv in Hdl; [ | exact Hagg ] end;
    match goal with IH0 : rooted_lv _ _ = true -> _ |- _ =>
      simpl in IH0; specialize (IH0 Hrv) end;
    subst; eauto.
  - (* Ederef P0 *)
    match goal with Hlv : rooted_lv _ _ = true |- _ => simpl in Hlv end;
    match goal with
    | Hlv : rooted_rv _ _ = true, H0 : _ -> _ |- _ =>
        let X := fresh "X" in pose proof (H0 Hlv) as X;
        destruct X as (blk & o' & Heq & Hb); congruence
    end.
  - (* Efield_struct P0 *)
    match goal with Hlv : rooted_lv _ _ = true |- _ => simpl in Hlv end;
    match goal with
    | Hlv : rooted_rv _ _ = true, H0 : _ -> _ |- _ =>
        let X := fresh "X" in pose proof (H0 Hlv) as X;
        destruct X as (blk & o' & Heq & Hb); congruence
    end.
  - (* Efield_union P0 *)
    match goal with Hlv : rooted_lv _ _ = true |- _ => simpl in Hlv end;
    match goal with
    | Hlv : rooted_rv _ _ = true, H0 : _ -> _ |- _ =>
        let X := fresh "X" in pose proof (H0 Hlv) as X;
        destruct X as (blk & o' & Heq & Hb); congruence
    end.
Qed.

(* Directly usable: an lvalue rooted at p resolves to a location in p's block. *)
Corollary eval_lvalue_rooted :
  forall ge e le m p pb po a loc ofs bf,
    le ! p = Some (Vptr pb po) ->
    eval_lvalue ge e le m a loc ofs bf ->
    rooted_lv p a = true ->
    loc = pb.
Proof.
  intros ge e le m p pb po a loc ofs bf Hp Hev Hr.
  eapply (proj2 (rooted_block ge e le m p pb po Hp)); eauto.
Qed.

(* If a pointer-typed add yields a pointer, the LEFT operand was a pointer. *)
Lemma sem_add_l_implies_l_ptr :
  forall cenv v1 t1 v2 t2 m blk ofs,
    is_ptr_or_arr t1 = true ->
    sem_binary_operation cenv Oadd v1 t1 v2 t2 m = Some (Vptr blk ofs) ->
    exists b o, v1 = Vptr b o.
Proof.
  intros cenv v1 t1 v2 t2 m blk ofs Hptr Hsem.
  unfold sem_binary_operation, sem_add in Hsem.
  destruct (classify_add t1 t2) eqn:Hc.
  - unfold sem_add_ptr_int in Hsem. destruct v1; try (do 2 eexists; reflexivity);
      destruct v2; try (destruct Archi.ptr64); discriminate.
  - unfold sem_add_ptr_long in Hsem. destruct v1; try (do 2 eexists; reflexivity);
      destruct v2; try (destruct Archi.ptr64); discriminate.
  - exfalso. destruct t1; simpl in Hptr; try discriminate;
      unfold classify_add in Hc; simpl in Hc; destruct (typeconv t2); discriminate.
  - exfalso. destruct t1; simpl in Hptr; try discriminate;
      unfold classify_add in Hc; simpl in Hc; destruct (typeconv t2); discriminate.
  - exfalso. destruct t1; simpl in Hptr; try discriminate;
      unfold sem_binarith in Hsem; simpl in Hsem; discriminate.
Qed.

(* The root temp of a rooted lvalue that evaluates IS a pointer in memory. So a
   chase store always has le!p = Vptr .. -- the frame needs this to extract the
   root block. *)
Lemma rooted_root_exists :
  forall ge e le m p,
    (forall a v, eval_expr ge e le m a v -> rooted_rv p a = true ->
        forall blk ofs, v = Vptr blk ofs -> exists pb po, le ! p = Some (Vptr pb po))
    /\ (forall a loc ofs bf, eval_lvalue ge e le m a loc ofs bf -> rooted_lv p a = true ->
        exists pb po, le ! p = Some (Vptr pb po)).
Proof.
  intros ge e le m p.
  apply eval_expr_lvalue_ind; intros.
  all: try (solve [ simpl in *; discriminate ]).
  - (* Etempvar *)
    match goal with Hr : rooted_rv _ (Etempvar _ _) = true |- _ =>
      simpl in Hr; apply Pos.eqb_eq in Hr; subst end;
    match goal with H : _ ! p = Some (Vptr _ _) |- _ => do 2 eexists; exact H end.
  - (* Ebinop Oadd *)
    match goal with Hr : rooted_rv _ (Ebinop ?op _ _ _) = true |- _ =>
      simpl in Hr; destruct op; try discriminate Hr;
      apply andb_true_iff in Hr; destruct Hr as [Hpt Hrv] end.
    match goal with Hsem : sem_binary_operation _ _ ?v1 _ _ _ _ = Some _, Hv : _ = Vptr _ _ |- _ =>
      subst; eapply sem_add_l_implies_l_ptr in Hsem; [ | exact Hpt ];
      destruct Hsem as (b1 & o1 & Hv1) end.
    match goal with
    | Hrv' : rooted_rv ?pp ?x = true, IH1 : rooted_rv ?pp ?x = true -> _ |- _ =>
        specialize (IH1 Hrv'); exact (IH1 b1 o1 Hv1) end.
  - (* Elvalue *)
    match goal with Hr : rooted_rv _ ?a0 = true |- _ =>
      destruct a0;
        try (match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inv Hlv] end);
        simpl in Hr; try discriminate Hr;
        apply andb_true_iff in Hr; destruct Hr as [Hagg Hrv] end;
    match goal with IH0 : rooted_lv _ _ = true -> _ |- _ =>
      simpl in IH0; apply IH0; exact Hrv end.
  - (* Ederef P0 *)
    match goal with Hr : rooted_lv _ _ = true |- _ => simpl in Hr end;
    match goal with Hrv : rooted_rv ?pp ?x = true, IH : rooted_rv ?pp ?x = true -> _ |- _ =>
      specialize (IH Hrv); eapply IH; reflexivity end.
  - (* Efield_struct P0 *)
    match goal with Hr : rooted_lv _ _ = true |- _ => simpl in Hr end;
    match goal with Hrv : rooted_rv ?pp ?x = true, IH : rooted_rv ?pp ?x = true -> _ |- _ =>
      specialize (IH Hrv); eapply IH; reflexivity end.
  - (* Efield_union P0 *)
    match goal with Hr : rooted_lv _ _ = true |- _ => simpl in Hr end;
    match goal with Hrv : rooted_rv ?pp ?x = true, IH : rooted_rv ?pp ?x = true -> _ |- _ =>
      specialize (IH Hrv); eapply IH; reflexivity end.
Qed.

(* Usable corollary: an executing chase store has le!p a pointer. *)
Corollary rooted_lv_root_value :
  forall ge e le m p a loc ofs bf,
    eval_lvalue ge e le m a loc ofs bf ->
    rooted_lv p a = true ->
    exists pb po, le ! p = Some (Vptr pb po).
Proof.
  intros ge e le m p a loc ofs bf Hev Hr.
  eapply (proj2 (rooted_root_exists ge e le m p)); eauto.
Qed.
