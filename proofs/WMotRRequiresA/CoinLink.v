(* spine-root: GOAL 2's coin link, the collision half -- the real
   detect_object_hitbox_overlap (generated/object_collision.v) cannot register
   a touch between two objects when the first one's hitbox top is below the
   second one's bottom.  Consumed by the coin-link row (TRUST.md 0.3) when
   it is composed into the capstone; the capstone does not state the coin yet. *)
(* ======================================================================= *)
(* GOAL 2: MARIO BELOW 2980 CANNOT TOUCH COIN #2 -- the collision rule.     *)
(*                                                                          *)
(* Object-object contact is decided by detect_object_hitbox_overlap(a, b)   *)
(* (object_collision.c).  When it registers a contact it stores b into      *)
(* a->collidedObjs and ORs b's interaction type into                        *)
(* a->collidedObjInteractTypes; interactions (collecting a coin) read only  *)
(* those.  overlap_no_contact proves, over the generated Clight body, that  *)
(*      a.hitboxHeight + (a.oPosY - a.hitboxDownOffset) + 1                 *)
(*        <= b.oPosY - b.hitboxDownOffset                                    *)
(* makes EVERY execution of the body return (through a `return 0`) with    *)
(* memory unchanged: nothing is registered.  The returned value is left     *)
(* out: on the horizontal-miss path the ROM returns garbage (no return      *)
(* statement; TRUST.md 2.2 register).  (The +1 absorbs binary32 rounding.)  *)
(* Its own                                                                  *)
(* assumptions: sqrtf leaves memory alone (TRUST 4.1) and the linked        *)
(* composite env extends object_collision.c's.                              *)
(*                                                                          *)
(* mario_coin2_no_contact instantiates it: Mario (a) with hitboxHeight      *)
(* <= 160, no down offset and y <= 2796 (the height capstone), against      *)
(* coin #2 (b) at 3140.                                                      *)
(* ======================================================================= *)

From Coq Require Import ZArith Reals Lra Lia List.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight Memory Maps
  Globalenvs Events ClightBigstep Ctypesdefs.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT Ulp Round_NE.
From SM64.Generated Require object_collision.
From SM64.Proofs Require Import ClightDeterm.
From SM64.Proofs Require Import HeightInvariant HeightFloatSteps.
Import ListNotations.

Local Open Scope Z_scope.

(* ----------------------------------------------------------------------- *)
(* 1. Object layout, pinned against object_collision.prog's composite env. *)
(* ----------------------------------------------------------------------- *)
Definition ce := prog_comp_env object_collision.prog.
Definition obj_co : option composite := ce ! object_collision._Object.
Definition obj_members : members :=
  match obj_co with Some co => co_members co | None => nil end.

Definition OFF_RAW : Z := 136.
Definition OFF_POSY : Z := 164.       (* rawData.asF32[6 + 1] = oPosY *)
Definition OFF_DOWN : Z := 520.       (* hitboxDownOffset *)
Definition OFF_HEIGHT : Z := 508.     (* hitboxHeight *)

Lemma object_offsets :
  field_offset ce object_collision._rawData obj_members = Errors.OK (OFF_RAW, Full) /\
  field_offset ce object_collision._hitboxDownOffset obj_members = Errors.OK (OFF_DOWN, Full) /\
  field_offset ce object_collision._hitboxHeight obj_members = Errors.OK (OFF_HEIGHT, Full).
Proof. vm_compute. auto. Qed.

Lemma obj_co_fields : exists co, ce ! object_collision._Object = Some co /\
  complete_members ce (co_members co) = true /\
  field_offset ce object_collision._rawData (co_members co) = Errors.OK (OFF_RAW, Full) /\
  field_offset ce object_collision._hitboxDownOffset (co_members co) = Errors.OK (OFF_DOWN, Full) /\
  field_offset ce object_collision._hitboxHeight (co_members co) = Errors.OK (OFF_HEIGHT, Full).
Proof.
  pose proof object_offsets as O. unfold obj_members, obj_co in O.
  assert (C : complete_members ce obj_members = true) by (vm_compute; reflexivity).
  unfold obj_members, obj_co in C.
  assert (P : match ce ! object_collision._Object with Some _ => true | None => false end = true)
    by (vm_compute; reflexivity).
  destruct (ce ! object_collision._Object) as [co|]; [ exists co; auto | discriminate ].
Qed.

Lemma union_asF32 : exists co, ce ! object_collision.__764 = Some co /\
  complete_members ce (co_members co) = true /\
  union_field_offset ce object_collision._asF32 (co_members co) = Errors.OK (0, Full).
Proof.
  assert (U : union_field_offset ce object_collision._asF32
                (match ce ! object_collision.__764 with Some co => co_members co | None => nil end)
              = Errors.OK (0, Full)) by (vm_compute; reflexivity).
  assert (C : complete_members ce
                (match ce ! object_collision.__764 with Some co => co_members co | None => nil end)
              = true) by (vm_compute; reflexivity).
  assert (P : match ce ! object_collision.__764 with Some _ => true | None => false end = true)
    by (vm_compute; reflexivity).
  destruct (ce ! object_collision.__764) as [co|]; [ exists co; auto | discriminate ].
Qed.

(* ----------------------------------------------------------------------- *)
(* 2. Big-step inversion helpers.                                          *)
(* ----------------------------------------------------------------------- *)
Section EXEC.
Variable fe : genv -> function -> list val -> mem -> env -> temp_env -> mem -> Prop.
Variable ge : genv.
Variable e : env.

Lemma seq_inv : forall le m s1 s2 t le' m' out,
  exec_stmt fe ge e le m (Ssequence s1 s2) t le' m' out ->
  (exists t1 le1 m1 t2, exec_stmt fe ge e le m s1 t1 le1 m1 Out_normal /\
                        exec_stmt fe ge e le1 m1 s2 t2 le' m' out) \/
  (exec_stmt fe ge e le m s1 t le' m' out /\ out <> Out_normal).
Proof. intros. inv H; [ left; eauto 10 | right; auto ]. Qed.

Lemma set_inv : forall le m x a t le' m' out,
  exec_stmt fe ge e le m (Sset x a) t le' m' out ->
  exists v, eval_expr ge e le m a v /\ le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
Proof. intros. inv H. eauto. Qed.

Lemma if_inv : forall le m c s1 s2 t le' m' out,
  exec_stmt fe ge e le m (Sifthenelse c s1 s2) t le' m' out ->
  exists v b, eval_expr ge e le m c v /\ bool_val v (typeof c) m = Some b /\
              exec_stmt fe ge e le m (if b then s1 else s2) t le' m' out.
Proof. intros. inv H. eauto. Qed.

Lemma ret_inv : forall le m a t le' m' out,
  exec_stmt fe ge e le m (Sreturn (Some a)) t le' m' out ->
  m' = m /\ exists v, eval_expr ge e le m a v /\ out = Out_return (Some (v, typeof a)).
Proof. intros. inv H. eauto. Qed.

Lemma skip_inv : forall le m t le' m' out,
  exec_stmt fe ge e le m Sskip t le' m' out -> m' = m /\ le' = le /\ out = Out_normal.
Proof. intros. inv H. auto. Qed.

Lemma call_inv : forall le m ret f al t le' m' out,
  exec_stmt fe ge e le m (Scall ret f al) t le' m' out ->
  exists tyargs tyres cconv vf vargs fd vres,
    classify_fun (typeof f) = fun_case_f tyargs tyres cconv /\
    eval_expr ge e le m f vf /\ eval_exprlist ge e le m al tyargs vargs /\
    Genv.find_funct ge vf = Some fd /\ type_of_fundef fd = Tfunction tyargs tyres cconv /\
    eval_funcall fe ge m fd vargs t m' vres /\ le' = set_opttemp ret vres le /\ out = Out_normal.
Proof. intros. inv H. eauto 20. Qed.

End EXEC.

(* ----------------------------------------------------------------------- *)
(* 3. The theorem.                                                          *)
(* ----------------------------------------------------------------------- *)
(* ----------------------------------------------------------------------- *)
(* The binary32 comparison: one unit of slack absorbs the three roundings. *)
(* ----------------------------------------------------------------------- *)
Section FCMP.
Local Open Scope R_scope.
Local Transparent Float32.cmp Float32.compare.

Lemma bnd_sub : forall a b, Rabs (R2 a) <= 8192 -> Rabs (R2 b) <= 8192 ->
  Rabs (R2 a - R2 b) <= bpow radix2 14.
Proof.
  intros a b Ha Hb. apply Rabs_le_inv in Ha, Hb. simpl. apply Rabs_le. lra.
Qed.

Lemma cmp_below : forall ha ya da yb db,
  F32 ha = true -> F32 ya = true -> F32 da = true -> F32 yb = true -> F32 db = true ->
  Rabs (R2 ha) <= 8192 -> Rabs (R2 ya) <= 8192 -> Rabs (R2 da) <= 8192 ->
  Rabs (R2 yb) <= 8192 -> Rabs (R2 db) <= 8192 ->
  R2 ha + (R2 ya - R2 da) + 1 <= R2 yb - R2 db ->
  Float32.cmp Clt (Float32.add ha (Float32.sub ya da)) (Float32.sub yb db) = true.
Proof.
  intros ha ya da yb db Fh Fy Fd Fy' Fd' Bh By Bd By' Bd' Hbelow.
  pose proof (bnd_sub ya da By Bd) as S1. pose proof (bnd_sub yb db By' Bd') as S2.
  destruct (f32_sub_val ya da Fy Fd) as [V1 F1].
  { eapply Rle_trans; [ exact S1 | apply bpow_le; lia ]. }
  destruct (f32_sub_val yb db Fy' Fd') as [V2 F2].
  { eapply Rle_trans; [ exact S2 | apply bpow_le; lia ]. }
  pose proof (rnd_err _ 14 ltac:(lia) S1) as E1.
  pose proof (rnd_err _ 14 ltac:(lia) S2) as E2.
  replace (bpow radix2 (14 - 24)) with (/ 1024) in E1, E2 by (simpl; lra).
  rewrite <- V1 in E1. rewrite <- V2 in E2.
  assert (S3 : Rabs (R2 ha + R2 (Float32.sub ya da)) <= bpow radix2 15).
  { simpl. apply Rabs_le_inv in Bh, By, Bd, E1. apply Rabs_le. lra. }
  destruct (f32_add_val ha _ Fh F1) as [V3 F3].
  { eapply Rle_trans; [ exact S3 | apply bpow_le; lia ]. }
  pose proof (rnd_err _ 15 ltac:(lia) S3) as E3.
  replace (bpow radix2 (15 - 24)) with (/ 512) in E3 by (simpl; lra).
  rewrite <- V3 in E3.
  unfold Float32.cmp, Float32.compare.
  rewrite Binary.Bcompare_correct by assumption.
  apply Rabs_le_inv in E1, E2, E3.
  destruct (Rcompare_spec (R2 (Float32.add ha (Float32.sub ya da))) (R2 (Float32.sub yb db)))
    as [H | H | H]; [ reflexivity | exfalso; lra | exfalso; lra ].
Qed.
End FCMP.

(* binary32 operators at float type, as Clight evaluates them              *)
Lemma sub_ss : forall cenv a b m v,
  sem_binary_operation cenv Osub (Vsingle a) tfloat (Vsingle b) tfloat m = Some v ->
  v = Vsingle (Float32.sub a b).
Proof. intros. cbv [sem_binary_operation sem_sub] in H. unfold sem_binarith in H. simpl in H. congruence. Qed.
Lemma add_ss : forall cenv a b m v,
  sem_binary_operation cenv Oadd (Vsingle a) tfloat (Vsingle b) tfloat m = Some v ->
  v = Vsingle (Float32.add a b).
Proof. intros. cbv [sem_binary_operation sem_add] in H. unfold sem_binarith in H. simpl in H. congruence. Qed.
Lemma lt_ss : forall cenv a b m v,
  sem_binary_operation cenv Olt (Vsingle a) tfloat (Vsingle b) tfloat m = Some v ->
  v = Val.of_bool (Float32.cmp Clt a b).
Proof. intros. cbv [sem_binary_operation sem_cmp] in H. unfold sem_binarith in H. simpl in H. congruence. Qed.

Global Opaque ce.

Section OVERLAP.
Variable fe : genv -> function -> list val -> mem -> env -> temp_env -> mem -> Prop.
Variable ge : genv.
(* the linked program keeps object_collision.c's composites verbatim       *)
(* (SymbolicLinking.linkorder_comp_env_extends), so offsets carry over     *)
Hypothesis Hcenv : forall id co, ce ! id = Some co -> (genv_cenv ge) ! id = Some co.
Variable e : env.
Variable le : temp_env.
Variable m : mem.
Variables (ba bb : block) (oa ob : ptrofs).
Hypothesis Ha : le ! object_collision._a = Some (Vptr ba oa).
Hypothesis Hb : le ! object_collision._b = Some (Vptr bb ob).

(* the body's one call is sqrtf (the horizontal distance): the function   *)
(* at the global symbol sqrtf does not touch memory -- the terminal-       *)
(* external math row (TRUST.md 4.1).  No local shadows it (fn_vars = nil). *)
Hypothesis He : e ! object_collision._sqrtf = None.
Hypothesis Hsqrt : forall b fd vargs t m' v,
  Genv.find_symbol ge object_collision._sqrtf = Some b ->
  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
  eval_funcall fe ge m fd vargs t m' v -> m' = m.

Variables (ya da ha yb db : float32).
Definition ld (b : block) (o : ptrofs) (off : Z) (f : float32) : Prop :=
  Mem.loadv Mfloat32 m (Vptr b (Ptrofs.add o (Ptrofs.repr off))) = Some (Vsingle f).
Hypothesis Lya : ld ba oa OFF_POSY ya.
Hypothesis Lda : ld ba oa OFF_DOWN da.
Hypothesis Lha : ld ba oa OFF_HEIGHT ha.
Hypothesis Lyb : ld bb ob OFF_POSY yb.
Hypothesis Ldb : ld bb ob OFF_DOWN db.


Definition OBJ := Tstruct object_collision._Object noattr.

(* the value a body temp can pick up from [le ! x] *)
Lemma ev_posy : forall le0 x bx ox f, le0 ! x = Some (Vptr bx ox) -> ld bx ox OFF_POSY f ->
  forall v, eval_expr ge e le0 m
    (Ederef
      (Ebinop Oadd
        (Efield
          (Efield (Ederef (Etempvar x (tptr OBJ)) OBJ) object_collision._rawData
            (Tunion object_collision.__764 noattr))
          object_collision._asF32 (tarray tfloat 80))
        (Ebinop Oadd (Econst_int (Int.repr 6) tint) (Econst_int (Int.repr 1) tint) tint)
        (tptr tfloat)) tfloat) v -> v = Vsingle f.
Proof.
  intros le0 x bx ox f Hx Hl v Hv.
  destruct obj_co_fields as (co & Hco & Cco & Hraw & _ & _).
  destruct union_asF32 as (cu & Hcu & Ccu & Hu).
  eapply eval_expr_determ; [ exact Hv | ].
  eapply eval_Elvalue.
  - eapply eval_Ederef. eapply eval_Ebinop.
    + eapply eval_Elvalue.
      * eapply eval_Efield_union.
        -- eapply eval_Elvalue.
           ++ eapply eval_Efield_struct.
              ** eapply eval_Elvalue.
                 --- eapply eval_Ederef. eapply eval_Etempvar. exact Hx.
                 --- eapply deref_loc_copy. reflexivity.
              ** reflexivity.
              ** apply Hcenv. exact Hco.
              ** rewrite (field_offset_stable ce _ Hcenv _ _ Cco). exact Hraw.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- apply Hcenv. exact Hcu.
        -- rewrite (union_field_offset_stable ce _ Hcenv _ _ Ccu). exact Hu.
      * eapply deref_loc_reference. reflexivity.
    + eapply eval_Ebinop; [ eapply eval_Econst_int | eapply eval_Econst_int | reflexivity ].
    + reflexivity.
  - eapply deref_loc_value; [ reflexivity | ].
    unfold ld in Hl. rewrite <- Hl. f_equal. f_equal.
    rewrite Ptrofs.add_assoc, Ptrofs.add_assoc. f_equal.
Qed.

Lemma ev_field : forall le0 x bx ox fid off f, le0 ! x = Some (Vptr bx ox) ->
  (exists co, ce ! object_collision._Object = Some co /\
              complete_members ce (co_members co) = true /\
              field_offset ce fid (co_members co) = Errors.OK (off, Full)) ->
  ld bx ox off f ->
  forall v, eval_expr ge e le0 m
    (Efield (Ederef (Etempvar x (tptr OBJ)) OBJ) fid tfloat) v -> v = Vsingle f.
Proof.
  intros le0 x bx ox fid off f Hx (co & Hco & Cco & Hoff) Hl v Hv.
  eapply eval_expr_determ; [ exact Hv | ].
  eapply eval_Elvalue.
  - eapply eval_Efield_struct.
    + eapply eval_Elvalue.
      * eapply eval_Ederef. eapply eval_Etempvar. exact Hx.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + apply Hcenv. exact Hco.
    + rewrite (field_offset_stable ce _ Hcenv _ _ Cco). exact Hoff.
  - eapply deref_loc_value; [ reflexivity | exact Hl ].
Qed.

Lemma field_down : exists co, ce ! object_collision._Object = Some co /\
  complete_members ce (co_members co) = true /\ field_offset ce object_collision._hitboxDownOffset (co_members co) = Errors.OK (OFF_DOWN, Full).
Proof. destruct obj_co_fields as (co & ? & ? & _ & ? & _). eauto. Qed.
Lemma field_height : exists co, ce ! object_collision._Object = Some co /\
  complete_members ce (co_members co) = true /\ field_offset ce object_collision._hitboxHeight (co_members co) = Errors.OK (OFF_HEIGHT, Full).
Proof. destruct obj_co_fields as (co & ? & ? & _ & _ & ?). eauto. Qed.

(* the premises: finite, in-range fields, and a's top below b's bottom      *)
Hypotheses (Fya : F32 ya = true) (Fda : F32 da = true) (Fha : F32 ha = true)
           (Fyb : F32 yb = true) (Fdb : F32 db = true).
Hypotheses (Bya : (Rabs (R2 ya) <= 8192)%R) (Bda : (Rabs (R2 da) <= 8192)%R)
           (Bha : (Rabs (R2 ha) <= 8192)%R) (Byb : (Rabs (R2 yb) <= 8192)%R)
           (Bdb : (Rabs (R2 db) <= 8192)%R).
Hypothesis Hbelow : (R2 ha + (R2 ya - R2 da) + 1 <= R2 yb - R2 db)%R.

Lemma ev_sqrtf : forall le0 vf,
  eval_expr ge e le0 m (Evar object_collision._sqrtf (Tfunction (tfloat :: nil) tfloat cc_default)) vf ->
  exists b, Genv.find_symbol ge object_collision._sqrtf = Some b /\ vf = Vptr b Ptrofs.zero.
Proof.
  intros le0 vf H. inv H.
  match goal with H0 : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H0 end; [ congruence | ].
  match goal with H1 : deref_loc _ _ _ _ _ _ |- _ => inv H1 end;
    cbn [access_mode] in *; try discriminate; eauto.
Qed.

Ltac neq := let Hq := fresh in intro Hq; vm_compute in Hq; discriminate.
Ltac getnorm H := repeat first [ rewrite PTree.gss in H | rewrite PTree.gso in H by neq ].
Ltac getgoal := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq ].

Ltac walk1 :=
  match reverse goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      apply seq_inv in H; destruct H as [(? & ? & ? & ? & ? & ?) | (? & ?)]
  | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
      apply set_inv in H; destruct H as (? & ? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      apply skip_inv in H; destruct H as (? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ |- _ =>
      apply ret_inv in H; destruct H as (? & ? & ? & ?); subst
  | H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
      apply call_inv in H;
      destruct H as (? & ? & ? & ? & ? & ? & ? & ? & Hvf & ? & Hff & ? & Hfc & ? & ?);
      apply ev_sqrtf in Hvf; destruct Hvf as (? & ? & ?); subst;
      match type of Hfc with eval_funcall _ _ _ _ _ _ ?m1 _ =>
        assert (m1 = m) by (eapply Hsqrt; eassumption) end;
      cbn [set_opttemp] in *; subst
  | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
      apply if_inv in H; destruct H as (? & [|] & ? & ? & H); cbv beta iota in H
  end; try congruence.

Lemma ev_temp : forall le0 x ty v, eval_expr ge e le0 m (Etempvar x ty) v -> le0 ! x = Some v.
Proof. intros. inv H; [ auto | inv H0 ]. Qed.
Lemma ev_const : forall le0 i ty v, eval_expr ge e le0 m (Econst_int i ty) v -> v = Vint i.
Proof. intros. inv H; [ auto | inv H0 ]. Qed.
Lemma ev_binop : forall le0 op a1 a2 ty v, eval_expr ge e le0 m (Ebinop op a1 a2 ty) v ->
  exists v1 v2, eval_expr ge e le0 m a1 v1 /\ eval_expr ge e le0 m a2 v2 /\
    sem_binary_operation ge op v1 (typeof a1) v2 (typeof a2) m = Some v.
Proof. intros. inv H; [ eauto | inv H0 ]. Qed.

Ltac norm1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : le ! object_collision._a = Some ?v |- _ =>
      tryif constr_eq H Ha then fail else (rewrite Ha in H; injection H as H; subst)
  | H : le ! object_collision._b = Some ?v |- _ =>
      tryif constr_eq H Hb then fail else (rewrite Hb in H; injection H as H; subst)
  | H : eval_expr _ _ ?L _ (Efield (Ederef (Etempvar ?x _) _) ?f tfloat) _ |- _ =>
      let G := fresh in
      first [ unify x object_collision._a; unify f object_collision._hitboxHeight;
              assert (G : L ! x = Some (Vptr ba oa)) by (getgoal; exact Ha);
              apply (ev_field L x _ _ _ _ _ G field_height Lha) in H
            | unify x object_collision._a; unify f object_collision._hitboxDownOffset;
              assert (G : L ! x = Some (Vptr ba oa)) by (getgoal; exact Ha);
              apply (ev_field L x _ _ _ _ _ G field_down Lda) in H
            | unify x object_collision._b; unify f object_collision._hitboxDownOffset;
              assert (G : L ! x = Some (Vptr bb ob)) by (getgoal; exact Hb);
              apply (ev_field L x _ _ _ _ _ G field_down Ldb) in H ]; subst
  | H : eval_expr _ _ ?L _ (Ederef (Ebinop Oadd (Efield (Efield (Ederef (Etempvar ?x _) _) _ _) _ _)
          (Ebinop Oadd (Econst_int (Int.repr 6) _) (Econst_int (Int.repr 1) _) _) _) _) _ |- _ =>
      let G := fresh in
      first [ unify x object_collision._a;
              assert (G : L ! x = Some (Vptr ba oa)) by (getgoal; exact Ha);
              apply (ev_posy L x _ _ _ G Lya) in H
            | unify x object_collision._b;
              assert (G : L ! x = Some (Vptr bb ob)) by (getgoal; exact Hb);
              apply (ev_posy L x _ _ _ G Lyb) in H ]; subst
  | H : Some _ = Some _ |- _ => injection H as H; subst
  | H : sem_binary_operation _ Osub (Vsingle _) _ (Vsingle _) _ _ = Some _ |- _ => apply sub_ss in H; subst
  | H : sem_binary_operation _ Oadd (Vsingle _) _ (Vsingle _) _ _ = Some _ |- _ => apply add_ss in H; subst
  | H : sem_binary_operation _ Olt (Vsingle _) _ (Vsingle _) _ _ = Some _ |- _ => apply lt_ss in H; subst
  end.

Theorem overlap_no_contact : forall t le' m' out,
  exec_stmt fe ge e le m (fn_body object_collision.f_detect_object_hitbox_overlap) t le' m' out ->
  m' = m /\ exists v, out = Out_return (Some (v, tint)).
Proof.
  intros t le' m' out H.
  pose proof (cmp_below ha ya da yb db Fha Fya Fda Fyb Fdb Bha Bya Bda Byb Bdb Hbelow) as Hcmp.
  unfold object_collision.f_detect_object_hitbox_overlap in H. cbn [fn_body] in H.
  repeat walk1.
  all: try (match goal with H : eval_expr _ _ _ _ (Econst_int (Int.repr 0) _) _ |- _ =>
              split; [ reflexivity | eexists; reflexivity ] end).
  all: repeat norm1.
  all: rewrite Hcmp in *; discriminate.
Qed.

End OVERLAP.

(* ----------------------------------------------------------------------- *)
(* 4. Mario and coin #2.  In check_player_object_collision Mario is always *)
(* the first argument (a) and the coin (OBJ_LIST_LEVEL) the second (b).    *)
(* With Mario's hitbox height at most 160 (100 crouching), no down offset, *)
(* and the height capstone's y <= PHI_YMAX = 2796, against the coin at     *)
(* 3140 with no down offset, the real body registers nothing.             *)
(* ----------------------------------------------------------------------- *)
Section MARIO_COIN2.
Variable fe : genv -> function -> list val -> mem -> env -> temp_env -> mem -> Prop.
Variable ge : genv.
Hypothesis Hcenv : forall id co, ce ! id = Some co -> (genv_cenv ge) ! id = Some co.
Variable e : env.
Variable le : temp_env.
Variable m : mem.
Variables (ba bb : block) (oa ob : ptrofs).
Hypothesis Ha : le ! object_collision._a = Some (Vptr ba oa).
Hypothesis Hb : le ! object_collision._b = Some (Vptr bb ob).
Hypothesis He : e ! object_collision._sqrtf = None.
Hypothesis Hsqrt : forall b fd vargs t m' v,
  Genv.find_symbol ge object_collision._sqrtf = Some b ->
  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
  eval_funcall fe ge m fd vargs t m' v -> m' = m.
Variables (ya da ha yb db : float32).
Hypothesis Lya : ld m ba oa OFF_POSY ya.
Hypothesis Lda : ld m ba oa OFF_DOWN da.
Hypothesis Lha : ld m ba oa OFF_HEIGHT ha.
Hypothesis Lyb : ld m bb ob OFF_POSY yb.
Hypothesis Ldb : ld m bb ob OFF_DOWN db.
Hypotheses (Fya : F32 ya = true) (Fda : F32 da = true) (Fha : F32 ha = true)
           (Fyb : F32 yb = true) (Fdb : F32 db = true).
Hypothesis Hmario_y : (-8192 <= R2 ya <= 2796)%R.
Hypothesis Hmario_down : R2 da = 0%R.
Hypothesis Hmario_height : (0 <= R2 ha <= 160)%R.
Hypothesis Hcoin_y : R2 yb = 3140%R.
Hypothesis Hcoin_down : R2 db = 0%R.

Theorem mario_coin2_no_contact : forall t le' m' out,
  exec_stmt fe ge e le m (fn_body object_collision.f_detect_object_hitbox_overlap) t le' m' out ->
  m' = m /\ exists v, out = Out_return (Some (v, tint)).
Proof.
  intros t le' m' out H.
  eapply overlap_no_contact with (ya := ya) (da := da) (ha := ha) (yb := yb) (db := db);
    eauto; try (apply Rabs_le; lra); lra.
Qed.
End MARIO_COIN2.
