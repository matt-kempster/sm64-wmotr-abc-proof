(* ===================================================================== *)
(* RenderAnim: the render step's animation-frame advance, from the real   *)
(* generated Clight (graph_node.c, rendering_graph_node.c).               *)
(*                                                                       *)
(* Between two of Mario's frames the game renders the scene graph:       *)
(* geo_process_object -> geo_set_animation_globals(&obj->...animInfo,    *)
(* hasAnimation) -> geo_update_animation_frame(node,                     *)
(* &node->animFrameAccelAssist).  These are the only render-step writes  *)
(* into an object's animation state.  This file proves, of the real      *)
(* bodies:                                                               *)
(*   - FOOTPRINT: geo_update_animation_frame writes at most the one int  *)
(*     its second argument points at; geo_set_animation_globals writes   *)
(*     only node->animFrame / animTimer / animFrameAccelAssist and the   *)
(*     six gCurrAnim* render globals (and the values it stores into the  *)
(*     two pointer globals were loaded from the node's current Animation *)
(*     header);                                                          *)
(*   - RANGE: with animAccel = 0 and a header with                       *)
(*     -1 <= loopStart < loopEnd <= 32766, the advance keeps             *)
(*     -1 <= animFrame <= loopEnd (both the loop and the NOLOOP clamp,   *)
(*     forward and BACKWARD, and the already-updated / FLAG_2 early      *)
(*     return).                                                          *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors.
From SM64.Generated Require graph_node rendering_graph_node memory.
Import ListNotations.

Local Open Scope Z_scope.

(* ----------------------------------------------------------------------- *)
(* 1. Bit facts for the 16.16 frame word.                                  *)
(* ----------------------------------------------------------------------- *)

Lemma sext16_small : forall x, -32768 <= Int.signed x < 32768 -> Int.sign_ext 16 x = x.
Proof.
  intros x Hx.
  destruct (Int.eqmod_sign_ext 16 x ltac:(cbn; lia)) as (k & Ek).
  pose proof (Int.sign_ext_range 16 x ltac:(cbn; lia)) as R.
  pose proof (Int.unsigned_signed x) as U.
  change (two_p 16) with 65536 in Ek. change (two_p (16 - 1)) with 32768 in R.
  assert (S : Int.signed (Int.sign_ext 16 x) = Int.signed x).
  { destruct (Int.lt x Int.zero); rewrite U in Ek; change Int.modulus with 4294967296 in Ek; lia. }
  rewrite <- (Int.repr_signed (Int.sign_ext 16 x)), S. apply Int.repr_signed.
Qed.

Lemma sext16_range : forall x, -32768 <= Int.signed (Int.sign_ext 16 x) < 32768.
Proof.
  intros x. pose proof (Int.sign_ext_range 16 x ltac:(cbn; lia)) as R.
  change (two_p (16 - 1)) with 32768 in R. exact R.
Qed.

Lemma sext16_idem : forall x, Int.sign_ext 16 (Int.sign_ext 16 x) = Int.sign_ext 16 x.
Proof. intros. apply Int.sign_ext_idem. lia. Qed.

(* (short)((x << 16) >> 16) = (short)x *)
Lemma fr_shl : forall x,
  Int.sign_ext 16 (Int.shr (Int.shl x (Int.repr 16)) (Int.repr 16)) = Int.sign_ext 16 x.
Proof.
  intros x. apply Int.same_bits_eq. intros i Hi.
  change Int.zwordsize with 32 in Hi.
  rewrite !Int.bits_sign_ext by (change Int.zwordsize with 32; lia).
  set (j := if zlt i 16 then i else 16 - 1).
  assert (Hj : 0 <= j < 16) by (unfold j; destruct (zlt i 16); lia).
  rewrite Int.bits_shr by (change Int.zwordsize with 32; lia).
  change (Int.unsigned (Int.repr 16)) with 16. change Int.zwordsize with 32.
  rewrite zlt_true by lia.
  rewrite Int.bits_shl by (change Int.zwordsize with 32; lia).
  change (Int.unsigned (Int.repr 16)) with 16. rewrite zlt_false by lia.
  f_equal. lia.
Qed.

(* (short)(((r & 0xFFFF) | (L << 16)) >> 16) = (short)L *)
Lemma fr_or : forall r L,
  Int.sign_ext 16 (Int.shr (Int.or (Int.and r (Int.repr 65535)) (Int.shl L (Int.repr 16)))
                           (Int.repr 16)) = Int.sign_ext 16 L.
Proof.
  intros r L. apply Int.same_bits_eq. intros i Hi.
  change Int.zwordsize with 32 in Hi.
  rewrite !Int.bits_sign_ext by (change Int.zwordsize with 32; lia).
  set (j := if zlt i 16 then i else 16 - 1).
  assert (Hj : 0 <= j < 16) by (unfold j; destruct (zlt i 16); lia).
  rewrite Int.bits_shr by (change Int.zwordsize with 32; lia).
  change (Int.unsigned (Int.repr 16)) with 16. change Int.zwordsize with 32.
  rewrite zlt_true by lia.
  rewrite Int.bits_or, Int.bits_and, Int.bits_shl by (change Int.zwordsize with 32; lia).
  change (Int.unsigned (Int.repr 16)) with 16. rewrite zlt_false by lia.
  rewrite Int.testbit_repr by (change Int.zwordsize with 32; lia).
  change 65535 with (two_p 16 - 1). rewrite Zbits.Ztestbit_two_p_m1 by lia.
  rewrite zlt_false by lia. rewrite andb_false_r, orb_false_l. f_equal. lia.
Qed.

(* ----------------------------------------------------------------------- *)
(* 2. Expression inversions.                                               *)
(* ----------------------------------------------------------------------- *)

(* a field offset computed in a TU's own composite env, checked by vm_compute *)
Definition fo_ok (ce : composite_env) (S f : ident) (d : Z) : bool :=
  match ce ! S with
  | Some co => complete_members ce (co_members co) &&
      match field_offset ce f (co_members co) with
      | OK (d', Full) => Z.eqb d d'
      | _ => false
      end
  | None => false
  end.

Lemma fo_ok_lift : forall ce ce' S f d, fo_ok ce S f d = true ->
  (forall id co, ce ! id = Some co -> ce' ! id = Some co) ->
  forall co, ce' ! S = Some co -> field_offset ce' f (co_members co) = OK (d, Full).
Proof.
  unfold fo_ok. intros ce ce' S f d H Hext co Hco.
  destruct (ce ! S) as [co0|] eqn:E; [| discriminate].
  apply andb_prop in H as [Hc Hf].
  rewrite (Hext _ _ E) in Hco. injection Hco as <-.
  rewrite (field_offset_stable ce ce' Hext _ _ Hc).
  destruct (field_offset ce f (co_members co0)) as [[d' []]|]; try discriminate.
  apply Z.eqb_eq in Hf. subst. reflexivity.
Qed.

Section EV.
Variable ge : genv.
Variable e : env.
Variable m : mem.

Lemma ev_temp : forall le x ty v, eval_expr ge e le m (Etempvar x ty) v -> le ! x = Some v.
Proof. intros. inv H; [ auto | inv H0 ]. Qed.
Lemma ev_const : forall le i ty v, eval_expr ge e le m (Econst_int i ty) v -> v = Vint i.
Proof. intros. inv H; [ auto | inv H0 ]. Qed.
Lemma ev_single : forall le f ty v, eval_expr ge e le m (Econst_single f ty) v -> v = Vsingle f.
Proof. intros. inv H; [ auto | inv H0 ]. Qed.
Lemma ev_binop : forall le op a1 a2 ty v, eval_expr ge e le m (Ebinop op a1 a2 ty) v ->
  exists v1 v2, eval_expr ge e le m a1 v1 /\ eval_expr ge e le m a2 v2 /\
    sem_binary_operation ge op v1 (typeof a1) v2 (typeof a2) m = Some v.
Proof. intros. inv H; [ eauto | inv H0 ]. Qed.
Lemma ev_cast : forall le a ty v, eval_expr ge e le m (Ecast a ty) v ->
  exists v1, eval_expr ge e le m a v1 /\ sem_cast v1 (typeof a) ty m = Some v.
Proof. intros. inv H; [ eauto | inv H0 ]. Qed.

(* p->f, p a temp holding a struct pointer *)
Lemma ev_fld : forall le x S f ty v ch d,
  (forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full)) ->
  access_mode ty = By_value ch ->
  eval_expr ge e le m (Efield (Ederef (Etempvar x (tptr (Tstruct S noattr))) (Tstruct S noattr)) f ty) v ->
  exists b o, le ! x = Some (Vptr b o) /\ Mem.loadv ch m (Vptr b (Ptrofs.add o (Ptrofs.repr d))) = Some v.
Proof.
  intros le x S f ty v ch d Hfo Ham H.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
  all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
  match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (Hfo _ Hc) in Hf; injection Hf; intros; subst end.
  match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  cbn [typeof] in *.
  match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
    cbn in *; try discriminate.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end.
  do 2 eexists; split; [ eassumption |].
  match goal with Hd : deref_loc ty _ _ _ _ _ |- _ => inv Hd end; try congruence.
  repeat match goal with H1 : access_mode _ = By_value ?c |- _ =>
    tryif constr_eq H1 Ham then fail else (rewrite Ham in H1; injection H1; intros; subst; clear H1) end.
  assumption.
Qed.

(* &p->f *)
Lemma ev_addr_fld : forall le x S f ty v d,
  (forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full)) ->
  eval_expr ge e le m (Eaddrof (Efield (Ederef (Etempvar x (tptr (Tstruct S noattr))) (Tstruct S noattr)) f ty) (tptr ty)) v ->
  exists b o, le ! x = Some (Vptr b o) /\ v = Vptr b (Ptrofs.add o (Ptrofs.repr d)).
Proof.
  intros le x S f ty v d Hfo H.
  inv H. all: try (match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end).
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
  all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
  match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (Hfo _ Hc) in Hf; injection Hf; intros; subst end.
  match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  cbn [typeof] in *.
  match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
    cbn in *; try discriminate.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end.
  eauto.
Qed.

(* a global scalar, read: only its existence matters here *)
Lemma ev_gvar : forall le id ty v ch, e ! id = None -> access_mode ty = By_value ch ->
  eval_expr ge e le m (Evar id ty) v ->
  exists b, Genv.find_symbol ge id = Some b /\ Mem.loadv ch m (Vptr b Ptrofs.zero) = Some v.
Proof.
  intros le id ty v ch He Ham H. inv H. cbn [typeof] in *.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [ congruence |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; try congruence.
  repeat match goal with H1 : access_mode _ = By_value ?c |- _ =>
    tryif constr_eq H1 Ham then fail else (rewrite Ham in H1; injection H1; intros; subst; clear H1) end.
  eauto.
Qed.

(* a function designator *)
Lemma ev_fun : forall le id ty v, e ! id = None -> access_mode ty = By_reference ->
  eval_expr ge e le m (Evar id ty) v ->
  exists b, Genv.find_symbol ge id = Some b /\ v = Vptr b Ptrofs.zero.
Proof.
  intros le id ty v He Ham H. inv H. cbn [typeof] in *.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end; [ congruence |].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; try congruence. eauto.
Qed.

(* lvalues written by the two bodies *)
Lemma lv_fld : forall le x S f ty b' o' bf d,
  (forall co, (genv_cenv ge) ! S = Some co -> field_offset ge f (co_members co) = OK (d, Full)) ->
  eval_lvalue ge e le m (Efield (Ederef (Etempvar x (tptr (Tstruct S noattr))) (Tstruct S noattr)) f ty) b' o' bf ->
  exists o, le ! x = Some (Vptr b' o) /\ o' = Ptrofs.add o (Ptrofs.repr d) /\ bf = Full.
Proof.
  intros le x S f ty b' o' bf d Hfo H.
  inv H. all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
  match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  match goal with Hc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (Hfo _ Hc) in Hf; injection Hf; intros; subst end.
  match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  cbn [typeof] in *.
  match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end;
    cbn in *; try discriminate.
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end.
  eauto.
Qed.

Lemma lv_gvar : forall le id ty b' o' bf, e ! id = None ->
  eval_lvalue ge e le m (Evar id ty) b' o' bf ->
  Genv.find_symbol ge id = Some b' /\ o' = Ptrofs.zero /\ bf = Full.
Proof. intros. inv H0; [ congruence | auto ]. Qed.

(* *(p + 0), p a temp *)
Lemma lv_deref0 : forall le x ty b' o' bf,
  eval_lvalue ge e le m (Ederef (Ebinop Oadd (Etempvar x (tptr ty)) (Econst_int (Int.repr 0) tint) (tptr ty)) ty) b' o' bf ->
  exists o, le ! x = Some (Vptr b' o) /\ bf = Full /\
    Vptr b' o' = Vptr b' (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr (sizeof ge ty)) (Ptrofs.of_ints (Int.repr 0)))).
Proof.
  intros le x ty b' o' bf H. inv H.
  match goal with H4 : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in H4; destruct H4 as (v1 & v2 & H1 & H2 & H3) end.
  apply ev_temp in H1. apply ev_const in H2. subst v2.
  cbn [typeof] in H3. unfold sem_binary_operation, sem_add in H3.
  destruct v1; cbn in H3; try discriminate.
  injection H3 as E1 E2. subst. eauto.
Qed.

End EV.

Lemma ptr_add0 : forall sz o, Ptrofs.add o (Ptrofs.mul sz (Ptrofs.of_ints (Int.repr 0))) = o.
Proof.
  intros. change (Ptrofs.of_ints (Int.repr 0)) with Ptrofs.zero.
  rewrite Ptrofs.mul_zero. apply Ptrofs.add_zero.
Qed.

(* ----------------------------------------------------------------------- *)
(* 3. Statement inversions.                                                *)
(* ----------------------------------------------------------------------- *)
Section EXEC.
Variable ge : genv.
Variable e : env.
Notation xs := (exec_stmt function_entry2 ge e).

Lemma seq_inv : forall le m s1 s2 t le' m' out,
  xs le m (Ssequence s1 s2) t le' m' out ->
  (exists t1 le1 m1 t2, xs le m s1 t1 le1 m1 Out_normal /\ xs le1 m1 s2 t2 le' m' out) \/
  (xs le m s1 t le' m' out /\ out <> Out_normal).
Proof. intros. inv H; [ left; eauto 10 | right; auto ]. Qed.

Lemma set_inv : forall le m x a t le' m' out,
  xs le m (Sset x a) t le' m' out ->
  exists v, eval_expr ge e le m a v /\ le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
Proof. intros. inv H. eauto. Qed.

Lemma if_inv : forall le m c s1 s2 t le' m' out,
  xs le m (Sifthenelse c s1 s2) t le' m' out ->
  exists v b, eval_expr ge e le m c v /\ bool_val v (typeof c) m = Some b /\
              xs le m (if b then s1 else s2) t le' m' out.
Proof. intros. inv H. eauto. Qed.

Lemma ret_inv : forall le m a t le' m' out,
  xs le m (Sreturn (Some a)) t le' m' out ->
  m' = m /\ exists v, eval_expr ge e le m a v /\ out = Out_return (Some (v, typeof a)).
Proof. intros. inv H. eauto. Qed.

Lemma skip_inv : forall le m t le' m' out,
  xs le m Sskip t le' m' out -> m' = m /\ le' = le /\ out = Out_normal.
Proof. intros. inv H. auto. Qed.

Lemma assign_inv : forall le m a1 a2 t le' m' out,
  xs le m (Sassign a1 a2) t le' m' out ->
  exists b o bf v2 v, eval_lvalue ge e le m a1 b o bf /\ eval_expr ge e le m a2 v2 /\
    sem_cast v2 (typeof a2) (typeof a1) m = Some v /\
    assign_loc ge (typeof a1) m b o bf v m' /\ le' = le /\ out = Out_normal.
Proof. intros. inv H. eauto 12. Qed.

Lemma call_inv : forall le m ret f al t le' m' out,
  xs le m (Scall ret f al) t le' m' out ->
  exists tyargs tyres cconv vf vargs fd vres,
    classify_fun (typeof f) = fun_case_f tyargs tyres cconv /\
    eval_expr ge e le m f vf /\ eval_exprlist ge e le m al tyargs vargs /\
    Genv.find_funct ge vf = Some fd /\ type_of_fundef fd = Tfunction tyargs tyres cconv /\
    eval_funcall function_entry2 ge m fd vargs t m' vres /\
    le' = set_opttemp ret vres le /\ out = Out_normal.
Proof. intros. inv H. eauto 20. Qed.

End EXEC.

Lemma store_by_value : forall (ge : genv) ty m b o bf v m' ch,
  access_mode ty = By_value ch -> bf = Full ->
  assign_loc ge ty m b o bf v m' -> Mem.store ch m b (Ptrofs.unsigned o) v = Some m'.
Proof.
  intros ge ty m b o bf v m' ch Ham -> H. inv H; try congruence.
  rewrite Ham in H0. injection H0 as ->. exact H1.
Qed.

Ltac neq := let Hq := fresh in intro Hq; vm_compute in Hq; discriminate.
Ltac getnorm H := repeat first [ rewrite PTree.gss in H | rewrite PTree.gso in H by neq ].

(* ----------------------------------------------------------------------- *)
(* 4. Value facts of the C operators on the frame word.                    *)
(* ----------------------------------------------------------------------- *)
Section OPS.
Variable ge : genv.
Variable m : mem.

Lemma op_sub_s : forall a b, sem_binary_operation ge Osub (Vint a) tshort (Vint b) tint m = Some (Vint (Int.sub a b)).
Proof. reflexivity. Qed.
Lemma op_add_s : forall a b, sem_binary_operation ge Oadd (Vint a) tshort (Vint b) tint m = Some (Vint (Int.add a b)).
Proof. reflexivity. Qed.
Lemma op_shl16 : forall a, sem_binary_operation ge Oshl (Vint a) tint (Vint (Int.repr 16)) tint m = Some (Vint (Int.shl a (Int.repr 16))).
Proof. reflexivity. Qed.
Lemma op_shl16_s : forall a, sem_binary_operation ge Oshl (Vint a) tshort (Vint (Int.repr 16)) tint m = Some (Vint (Int.shl a (Int.repr 16))).
Proof. reflexivity. Qed.
Lemma op_shr16 : forall a, sem_binary_operation ge Oshr (Vint a) tint (Vint (Int.repr 16)) tint m = Some (Vint (Int.shr a (Int.repr 16))).
Proof. reflexivity. Qed.
Lemma op_and : forall a b, sem_binary_operation ge Oand (Vint a) tint (Vint b) tint m = Some (Vint (Int.and a b)).
Proof. reflexivity. Qed.
Lemma op_or : forall a b, sem_binary_operation ge Oor (Vint a) tint (Vint b) tint m = Some (Vint (Int.or a b)).
Proof. reflexivity. Qed.
Lemma op_lt_s : forall a b, sem_binary_operation ge Olt (Vint a) tshort (Vint b) tshort m = Some (Val.of_bool (Int.lt a b)).
Proof. reflexivity. Qed.
Lemma op_ge_s : forall a b, sem_binary_operation ge Oge (Vint a) tshort (Vint b) tshort m = Some (Val.of_bool (negb (Int.lt a b))).
Proof. reflexivity. Qed.
Lemma op_ne_i : forall a b, sem_binary_operation ge One (Vint a) tint (Vint b) tint m = Some (Val.of_bool (negb (Int.eq a b))).
Proof. reflexivity. Qed.
Lemma cast_i_s : forall a, sem_cast (Vint a) tint tshort m = Some (Vint (Int.sign_ext 16 a)).
Proof. reflexivity. Qed.
Lemma cast_s_s : forall a, sem_cast (Vint a) tshort tshort m = Some (Vint (Int.sign_ext 16 a)).
Proof. reflexivity. Qed.
Lemma bool_of_bool : forall c, bool_val (Val.of_bool c) tint m = Some c.
Proof. destruct c; reflexivity. Qed.
End OPS.

Lemma lt_true : forall x y, Int.lt x y = true -> Int.signed x < Int.signed y.
Proof. unfold Int.lt. intros x y H. destruct (zlt (Int.signed x) (Int.signed y)); congruence. Qed.
Lemma lt_false : forall x y, Int.lt x y = false -> Int.signed y <= Int.signed x.
Proof. unfold Int.lt. intros x y H. destruct (zlt (Int.signed x) (Int.signed y)); [congruence | lia]. Qed.

Lemma sx_sub1 : forall a, -32767 <= Int.signed a <= 32767 ->
  Int.signed (Int.sign_ext 16 (Int.sub a (Int.repr 1))) = Int.signed a - 1.
Proof.
  intros a Ha. rewrite Int.sub_signed. change (Int.signed (Int.repr 1)) with 1.
  rewrite sext16_small; rewrite Int.signed_repr; cbn; lia.
Qed.
Lemma sx_add1 : forall a, -32768 <= Int.signed a <= 32766 ->
  Int.signed (Int.sign_ext 16 (Int.add a (Int.repr 1))) = Int.signed a + 1.
Proof.
  intros a Ha. rewrite Int.add_signed. change (Int.signed (Int.repr 1)) with 1.
  rewrite sext16_small; rewrite Int.signed_repr; cbn; lia.
Qed.

(* ----------------------------------------------------------------------- *)
(* 5. geo_update_animation_frame (graph_node.c).                           *)
(* ----------------------------------------------------------------------- *)
Ltac funcall_entry Hevf :=
  inv Hevf;
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end;
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.

Ltac walk1 :=
  match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      apply seq_inv in H; destruct H as [(? & ? & ? & ? & ? & ?) | (? & ?)]
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
      apply set_inv in H; destruct H as (? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      apply skip_inv in H; destruct H as (? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ |- _ =>
      apply ret_inv in H; destruct H as (? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
      apply assign_inv in H; destruct H as (? & ? & ? & ? & ? & ? & ? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
      apply if_inv in H; destruct H as (? & [|] & ? & ? & H); cbv beta iota in H
  end; try congruence.

Lemma cast_tint_id : forall v v' m, sem_cast v tint tint m = Some v' -> v' = v.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; reflexivity. Qed.

Lemma cast_ptr_id : forall a b v v' m, sem_cast v (tptr a) (tptr b) m = Some v' -> v' = v.
Proof. intros a b v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; reflexivity. Qed.

Lemma op_add_ii : forall ge m a b, sem_binary_operation ge Oadd (Vint a) tint (Vint b) tint m = Some (Vint (Int.add a b)).
Proof. reflexivity. Qed.
Lemma op_sub_ii : forall ge m a b, sem_binary_operation ge Osub (Vint a) tint (Vint b) tint m = Some (Vint (Int.sub a b)).
Proof. reflexivity. Qed.
Lemma op_or_ii : forall ge m a b, sem_binary_operation ge Oor (Vint a) tint (Vint b) tint m = Some (Vint (Int.or a b)).
Proof. reflexivity. Qed.

Lemma op_int : forall ge m op v1 v2 v, In op [Oadd; Osub; Oshl; Oor] ->
  sem_binary_operation ge op v1 tint v2 tint m = Some v -> exists i, v = Vint i.
Proof.
  intros ge m op v1 v2 v Hop H.
  destruct Hop as [<- | [<- | [<- | [<- | []]]]]; destruct v1, v2;
    first [ rewrite op_add_ii in H | rewrite op_sub_ii in H | rewrite op_or_ii in H
          | cbn in H ]; try discriminate.
  all: repeat match type of H with context [if ?c then _ else _] => destruct c end.
  all: try discriminate; injection H; intros <-; eauto.
Qed.

Section GUAF.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env graph_node.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.

Ltac fo_ok_tac := apply (fo_ok_lift (prog_comp_env graph_node.prog)); [ vm_compute; reflexivity | exact Hcenv ].

Lemma fo_curAnim : forall co, (genv_cenv ge) ! graph_node._AnimInfo = Some co ->
  field_offset ge graph_node._curAnim (co_members co) = OK (4, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_animFrame : forall co, (genv_cenv ge) ! graph_node._AnimInfo = Some co ->
  field_offset ge graph_node._animFrame (co_members co) = OK (8, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_animTimer : forall co, (genv_cenv ge) ! graph_node._AnimInfo = Some co ->
  field_offset ge graph_node._animTimer (co_members co) = OK (10, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_accelAssist : forall co, (genv_cenv ge) ! graph_node._AnimInfo = Some co ->
  field_offset ge graph_node._animFrameAccelAssist (co_members co) = OK (12, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_animAccel : forall co, (genv_cenv ge) ! graph_node._AnimInfo = Some co ->
  field_offset ge graph_node._animAccel (co_members co) = OK (16, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_animYTrans : forall co, (genv_cenv ge) ! graph_node._AnimInfo = Some co ->
  field_offset ge graph_node._animYTrans (co_members co) = OK (2, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_flags : forall co, (genv_cenv ge) ! graph_node._Animation = Some co ->
  field_offset ge graph_node._flags (co_members co) = OK (0, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_divisor : forall co, (genv_cenv ge) ! graph_node._Animation = Some co ->
  field_offset ge graph_node._animYTransDivisor (co_members co) = OK (2, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_loopStart : forall co, (genv_cenv ge) ! graph_node._Animation = Some co ->
  field_offset ge graph_node._loopStart (co_members co) = OK (6, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_loopEnd : forall co, (genv_cenv ge) ! graph_node._Animation = Some co ->
  field_offset ge graph_node._loopEnd (co_members co) = OK (8, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_values : forall co, (genv_cenv ge) ! graph_node._Animation = Some co ->
  field_offset ge graph_node._values (co_members co) = OK (12, Full).
Proof. fo_ok_tac. Qed.
Lemma fo_index : forall co, (genv_cenv ge) ! graph_node._Animation = Some co ->
  field_offset ge graph_node._index (co_members co) = OK (16, Full).
Proof. fo_ok_tac. Qed.

Ltac fo_any := first [ exact fo_curAnim | exact fo_animFrame | exact fo_animTimer
  | exact fo_accelAssist | exact fo_animAccel | exact fo_animYTrans | exact fo_flags
  | exact fo_divisor | exact fo_loopStart | exact fo_loopEnd | exact fo_values | exact fo_index ].

Ltac norm1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
      eapply ev_fld in H; [ destruct H as (? & ? & ? & H) | fo_any | reflexivity ]
  | H : eval_expr _ _ _ _ (Evar _ _) _ |- _ => clear H
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : Vptr _ _ = Vptr _ _ |- _ => injection H; clear H; intros; subst
  end.

(* the footprint: at most the one int the second argument points at *)
Theorem guaf_footprint : forall m ob oi ab ao t m' vres,
  eval_funcall function_entry2 ge m (Internal graph_node.f_geo_update_animation_frame)
    [Vptr ob oi; Vptr ab ao] t m' vres ->
  m' = m \/ exists v, Mem.store Mint32 m ab (Ptrofs.unsigned ao) v = Some m' /\
    ((exists i, v = Vint i)
     \/ Mem.loadv Mint32 m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 12))) = Some v).
Proof.
  intros m ob oi ab ao t m' vres H.
  funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps graph_node.f_geo_update_animation_frame fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [graph_node.f_geo_update_animation_frame fn_body] in Hx end.
  repeat walk1.
  all: try (left; reflexivity).
  all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
         apply lv_deref0 in Hl; destruct Hl as (? & Hl & -> & Ep);
         getnorm Hl; injection Hl; intros; subst;
         injection Ep; intros Eo; rewrite ptr_add0 in Eo; subst end.
  all: cbn [typeof] in *.
  all: match goal with Hc : sem_cast _ tint tint _ = Some _ |- _ => apply cast_tint_id in Hc; subst end.
  all: right; eexists; split; [ match goal with Ha : assign_loc _ ?ty _ _ _ _ _ _ |- _ =>
         eapply (store_by_value _ ty); [ reflexivity | reflexivity | exact Ha ] end |].
  all: repeat norm1.
  all: first [ left; match goal with Hs : sem_binary_operation _ _ _ tint _ tint _ = Some ?x
                                     |- exists i, ?x = Vint i =>
                       eapply op_int; [ | exact Hs ]; cbn; tauto end
             | right; assumption ].
Qed.

Ltac pin1 :=
  match goal with
  | H : Mem.loadv ?ch ?mm ?a = Some ?v, P : Mem.loadv ?ch ?mm ?a = Some ?w |- _ =>
      tryif constr_eq H P then fail else
      (rewrite P in H; injection H; clear H; intros; subst)
  | H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
      first [ rewrite op_sub_s in H | rewrite op_add_s in H | rewrite op_shl16 in H
            | rewrite op_shl16_s in H | rewrite op_shr16 in H | rewrite op_and in H
            | rewrite op_or in H | rewrite op_lt_s in H | rewrite op_ge_s in H
            | rewrite op_ne_i in H ];
      injection H; clear H; intros; subst
  | H : sem_cast _ _ _ _ = Some _ |- _ =>
      first [ rewrite cast_i_s in H | rewrite cast_s_s in H ]; injection H; clear H; intros; subst
  | H : bool_val (Val.of_bool _) tint _ = Some _ |- _ =>
      rewrite bool_of_bool in H; injection H; clear H; intros; subst
  | H : negb _ = true |- _ => apply negb_true_iff in H
  | H : negb _ = false |- _ => apply negb_false_iff in H
  | H : Int.eq Int.zero (Int.repr 0) = _ |- _ => vm_compute in H; discriminate H
  | H : Int.eq (Int.repr 0) (Int.repr 0) = _ |- _ => vm_compute in H; discriminate H
  end.

(* the frame range: with no acceleration, -1 <= loopStart < loopEnd <= 32766
   and -1 <= animFrame <= loopEnd, the returned frame is again in
   [-1, loopEnd].  The second argument may alias nothing the body reads
   after writing it (the caller's &node->animFrameAccelAssist, 4 bytes past
   animFrame). *)
Theorem guaf_range : forall m ob oi ab ao t m' vres bt ot fr ls lend,
  eval_funcall function_entry2 ge m (Internal graph_node.f_geo_update_animation_frame)
    [Vptr ob oi; Vptr ab ao] t m' vres ->
  Mem.loadv Mptr m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 4))) = Some (Vptr bt ot) ->
  Mem.loadv Mint16signed m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint fr) ->
  (forall v m1, Mem.store Mint32 m ab (Ptrofs.unsigned ao) v = Some m1 ->
     Mem.loadv Mint16signed m1 (Vptr ob (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint fr)) ->
  Mem.loadv Mint32 m (Vptr ob (Ptrofs.add oi (Ptrofs.repr 16))) = Some (Vint Int.zero) ->
  Mem.loadv Mint16signed m (Vptr bt (Ptrofs.add ot (Ptrofs.repr 6))) = Some (Vint ls) ->
  Mem.loadv Mint16signed m (Vptr bt (Ptrofs.add ot (Ptrofs.repr 8))) = Some (Vint lend) ->
  -1 <= Int.signed ls < Int.signed lend -> Int.signed lend <= 32766 ->
  -1 <= Int.signed fr <= Int.signed lend ->
  exists r, vres = Vint r /\ -1 <= Int.signed r <= Int.signed lend.
Proof.
  intros m ob oi ab ao t m' vres bt ot fr ls lend H Pcur Pfr Pfr1 Pacc Pls Ple Rl Rle Rfr.
  funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps graph_node.f_geo_update_animation_frame fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [graph_node.f_geo_update_animation_frame fn_body] in Hx end.
  repeat walk1.
  (* the accelAssist store, then the re-read of animFrame after it *)
  all: try match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
         apply lv_deref0 in Hl; destruct Hl as (? & Hl & -> & Ep);
         getnorm Hl; injection Hl; intros; subst;
         injection Ep; intros Eo; rewrite ptr_add0 in Eo; subst;
         match goal with Ha : assign_loc _ ?ty _ _ _ _ _ _ |- _ =>
           let Hs := fresh "Hs" in
           assert (Hs : Mem.store Mint32 _ _ _ _ = Some _)
             by (eapply (store_by_value _ ty); [ reflexivity | reflexivity | exact Ha ]);
           pose proof (Pfr1 _ _ Hs); clear Ha end end.
  all: match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
         cbn [outcome_result_value typeof fn_return graph_node.f_geo_update_animation_frame] in Ho;
         destruct Ho as [_ Ho] end.
  all: cbn [typeof] in *.
  all: repeat norm1.
  all: repeat pin1.
  all: eexists; split; [ reflexivity |].
  all: repeat match goal with
       | H : Int.lt _ _ = true |- _ => apply lt_true in H
       | H : Int.lt _ _ = false |- _ => apply lt_false in H
       end.
  all: rewrite ?sext16_idem, ?fr_shl, ?fr_or in *.
  all: rewrite ?(sext16_small ls), ?(sext16_small lend), ?(sext16_small fr) in * by lia.
  all: rewrite ?sx_sub1, ?sx_add1 in * by lia.
  all: lia.
Qed.
End GUAF.

(* ----------------------------------------------------------------------- *)
(* 6. segmented_to_virtual (memory.c): the identity, no write.             *)
(* ----------------------------------------------------------------------- *)
Lemma stv_run : forall ge m v t m' vres,
  eval_funcall function_entry2 ge m (Internal memory.f_segmented_to_virtual) [v] t m' vres ->
  m' = m /\ vres = v.
Proof.
  intros ge m v t m' vres H. funcall_entry H.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps memory.f_segmented_to_virtual fn_params] in Hb;
    injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    cbn [memory.f_segmented_to_virtual fn_body] in Hx;
    apply ret_inv in Hx; destruct Hx as (-> & v1 & Hv & ->) end.
  apply ev_cast in Hv. destruct Hv as (v2 & Hv & Hc). apply ev_temp in Hv.
  rewrite PTree.gss in Hv. injection Hv as <-.
  cbn [typeof] in Hc. apply cast_ptr_id in Hc. subst v1.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [outcome_result_value typeof fn_return memory.f_segmented_to_virtual] in Ho;
    destruct Ho as [_ Ho]; apply cast_ptr_id in Ho end.
  auto.
Qed.

(* ----------------------------------------------------------------------- *)
(* 7. geo_set_animation_globals (rendering_graph_node.c).                  *)
(* ----------------------------------------------------------------------- *)

(* the six render globals it sets *)
Definition render_gvars : list ident :=
  [ rendering_graph_node._gCurrAnimType; rendering_graph_node._gCurrAnimFrame;
    rendering_graph_node._gCurrAnimEnabled; rendering_graph_node._gCurrAnimAttribute;
    rendering_graph_node._gCurrAnimData; rendering_graph_node._gCurrAnimTranslationMultiplier ].

(* a chain of stores, each allowed by P (P sees the memory it lands on) *)
Inductive stores_by (P : mem -> block -> Z -> memory_chunk -> val -> Prop) : mem -> mem -> Prop :=
  | sb_refl : forall m, stores_by P m m
  | sb_step : forall m m1 m2 ch b z v, P m b z ch v -> Mem.store ch m b z v = Some m1 ->
      stores_by P m1 m2 -> stores_by P m m2.

(* the render step's allowed store into memory mm, for node (ob, oi) in the
   memory m0 it started from: one of the node's three advance cells
   (animFrame, animTimer, animFrameAccelAssist) or one of the six render
   globals; a stored pointer was read (as a 32-bit word) in mm, either from
   the node's own block or from the Animation header the node pointed at
   in m0. *)
Definition rstore (ge : genv) (ob : block) (oi : ptrofs) (m0 mm : mem)
    (b : block) (z : Z) (ch : memory_chunk) (v : val) : Prop :=
  ((b = ob /\ ((z = Ptrofs.unsigned (Ptrofs.add oi (Ptrofs.repr 8)) /\ ch = Mint16signed)
              \/ (z = Ptrofs.unsigned (Ptrofs.add oi (Ptrofs.repr 10)) /\ ch = Mint16unsigned)
              \/ (z = Ptrofs.unsigned (Ptrofs.add oi (Ptrofs.repr 12)) /\ ch = Mint32)))
   \/ (exists id, In id render_gvars /\ Genv.find_symbol ge id = Some b /\ z = 0))
  /\ (forall b' o', v = Vptr b' o' ->
        exists b0 o0, Mem.loadv Mptr mm (Vptr b0 o0) = Some v /\
          (b0 = ob \/ exists ot, Mem.loadv Mptr m0 (Vptr ob (Ptrofs.add oi (Ptrofs.repr 4)))
                                 = Some (Vptr b0 ot))).

Lemma cast_us_int : forall v v' m, sem_cast v tushort tushort m = Some v' -> exists i, v' = Vint i.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; eauto. Qed.
Lemma cast_ss_int : forall v v' m, sem_cast v tshort tshort m = Some v' -> exists i, v' = Vint i.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; eauto. Qed.
Lemma cast_iuc_int : forall v v' m, sem_cast v tint tuchar m = Some v' -> exists i, v' = Vint i.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; eauto. Qed.
Lemma cast_ff_single : forall v v' m, sem_cast v tfloat tfloat m = Some v' -> exists f, v' = Vsingle f.
Proof. intros v v' m H. destruct v; cbn in H; try discriminate; injection H; intros <-; eauto. Qed.
