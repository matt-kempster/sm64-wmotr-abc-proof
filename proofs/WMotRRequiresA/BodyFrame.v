(* ======================================================================= *)
(* BodyFrame (GOAL 2, 2026-10-23): the memory relation behind NaSplit's    *)
(* mario_reset_bodystate and update_mario_info_for_cam rows, and the frame *)
(* of the latter's two math_util callees (vec3s_copy, vec3f_copy), read    *)
(* off their generated bodies (AudioBodies.lw_walk).                       *)
(*                                                                         *)
(*   Q2 PHk m0 m1: the bytes PHk keeps are unchanged, memory may grow, the *)
(*   old blocks keep their permissions and the new ones have none (a       *)
(*   callee's frame, allocated and freed).  Q2 composes (Q2_trans), so a   *)
(*   body walk proves it one statement at a time.                          *)
(*                                                                         *)
(*   v3_frame: a call of the real vec3s_copy / vec3f_copy with dest a      *)
(*   pointer into block l changes nothing outside l (its address-taken     *)
(*   `dest` copy lives in its own frame, freed on return).                 *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Globalenvs
  Ctypes Cop Clight ClightBigstep Events Clightdefs.
From SM64.Generated Require math_util.
From SM64.Proofs Require Import RealFrameValue MarioModel.AudioBodies.
From SM64.Proofs Require MarioModel.MathGeomBodies.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. A single assign_loc changes only its own block.                     *)
(* ---------------------------------------------------------------------- *)
Lemma st_gen : forall ch m1 b z v m2, Mem.store ch m1 b z v = Some m2 ->
  Mem.nextblock m2 = Mem.nextblock m1 /\ (forall b' o k p, Mem.perm m2 b' o k p <-> Mem.perm m1 b' o k p).
Proof.
  intros ch m1 b z v m2 Hst. split; [exact (Mem.nextblock_store _ _ _ _ _ _ Hst) |].
  intros b' o k p. split.
  - exact (Mem.perm_store_2 _ _ _ _ _ _ Hst b' o k p).
  - exact (Mem.perm_store_1 _ _ _ _ _ _ Hst b' o k p).
Qed.

Lemma al_gen : forall ce ty m1 loc ofs bf v m2,
  assign_loc ce ty m1 loc ofs bf v m2 ->
  Mem.unchanged_on (fun b _ => b <> loc) m1 m2 /\ Mem.nextblock m2 = Mem.nextblock m1
  /\ (forall b o k p, Mem.perm m2 b o k p <-> Mem.perm m1 b o k p).
Proof.
  intros ce ty m1 loc ofs bf v m2 Hal. inv Hal.
  - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => cbn [Mem.storev] in Hs; rename Hs into Hst end.
    split; [eapply Mem.store_unchanged_on; [exact Hst | intros i _ N; exact (N eq_refl)] |].
    exact (st_gen _ _ _ _ _ _ Hst).
  - match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ => rename Hs into Hsb end.
    split; [eapply Mem.storebytes_unchanged_on; [exact Hsb | intros i _ N; exact (N eq_refl)] |].
    split; [exact (Mem.nextblock_storebytes _ _ _ _ _ Hsb) |].
    intros b o k p. split.
    + exact (Mem.perm_storebytes_2 _ _ _ _ _ Hsb b o k p).
    + exact (Mem.perm_storebytes_1 _ _ _ _ _ Hsb b o k p).
  - match goal with Hs : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hs end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => cbn [Mem.storev] in Hs; rename Hs into Hst end.
    split; [eapply Mem.store_unchanged_on; [exact Hst | intros i _ N; exact (N eq_refl)] |].
    exact (st_gen _ _ _ _ _ _ Hst).
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Q2.                                                                 *)
(* ---------------------------------------------------------------------- *)
Section QF.
  Variable PHk : block -> Z -> Prop.

  Definition Q2 (m0 m1 : mem) : Prop :=
    Mem.unchanged_on PHk m0 m1 /\ Ple (Mem.nextblock m0) (Mem.nextblock m1)
    /\ (forall b o k p, Plt b (Mem.nextblock m0) -> (Mem.perm m1 b o k p <-> Mem.perm m0 b o k p))
    /\ (forall b o k p, ~ Plt b (Mem.nextblock m0) -> ~ Mem.perm m1 b o k p).

  Lemma Q2_refl : forall m, Q2 m m.
  Proof.
    intros m. split; [apply Mem.unchanged_on_refl |]. split; [apply Ple_refl |].
    split; [intros b o k p _; tauto |].
    intros b o k p N Hp. exact (N (Mem.perm_valid_block _ _ _ _ _ Hp)).
  Qed.

  Lemma Q2_trans : forall m0 m1 m2, Q2 m0 m1 -> Q2 m1 m2 -> Q2 m0 m2.
  Proof.
    intros m0 m1 m2 (U1 & N1 & P1 & F1) (U2 & N2 & P2 & F2).
    split; [exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) |].
    split; [exact (Ple_trans _ _ _ N1 N2) |].
    split.
    - intros b o k p V.
      assert (V1 : Plt b (Mem.nextblock m1)) by exact (Plt_Ple_trans _ _ _ V N1).
      rewrite (P2 b o k p V1). exact (P1 b o k p V).
    - intros b o k p V Hp. destruct (plt b (Mem.nextblock m1)) as [V1 | V1].
      + exact (F1 b o k p V (proj1 (P2 b o k p V1) Hp)).
      + exact (F2 b o k p V1 Hp).
  Qed.

  Lemma Q2_load : forall m0 m1, Q2 m0 m1 ->
    forall ch b z, (forall i, z <= i < z + size_chunk ch -> PHk b i) ->
    Mem.load ch m1 b z = Mem.load ch m0 b z.
  Proof.
    intros m0 m1 (U & N & P & F) ch b z Hk.
    destruct (plt b (Mem.nextblock m0)) as [V | V].
    - eapply Mem.load_unchanged_on_1; [exact U | exact V | exact Hk].
    - destruct (Mem.load ch m0 b z) eqn:E0.
      + exfalso. apply Mem.load_valid_access in E0 as (Rp & _).
        apply V. apply (Mem.perm_valid_block _ _ z Cur Readable). apply Rp.
        pose proof (size_chunk_pos ch). lia.
      + destruct (Mem.load ch m1 b z) eqn:E1; [| reflexivity].
        exfalso. apply Mem.load_valid_access in E1 as (Rp & _).
        apply (F b z Cur Readable V). apply Rp. pose proof (size_chunk_pos ch). lia.
  Qed.

  Lemma Q2_perm : forall m0 m1, Q2 m0 m1 ->
    forall b o k p, Mem.perm m0 b o k p -> Mem.perm m1 b o k p.
  Proof.
    intros m0 m1 (_ & _ & P & _) b o k p Hp.
    exact (proj2 (P b o k p (Mem.perm_valid_block _ _ _ _ _ Hp)) Hp).
  Qed.

  (* a store away from PHk *)
  Lemma st_q2 : forall ch m1 b z v m2, Mem.store ch m1 b z v = Some m2 ->
    (forall i, z <= i < z + size_chunk ch -> ~ PHk b i) -> Q2 m1 m2.
  Proof.
    intros ch m1 b z v m2 Hst Hav.
    destruct (st_gen _ _ _ _ _ _ Hst) as (N & P).
    split; [eapply Mem.store_unchanged_on; [exact Hst | exact Hav] |].
    split; [rewrite N; apply Ple_refl |].
    split; [intros b' o k p _; exact (P b' o k p) |].
    intros b' o k p V Hp. apply V. exact (Mem.perm_valid_block _ _ _ _ _ (proj1 (P _ _ _ _) Hp)).
  Qed.

  (* an assign_loc into a block PHk does not keep *)
  Lemma al_q2 : forall ce ty m1 loc ofs bf v m2,
    assign_loc ce ty m1 loc ofs bf v m2 -> (forall i, ~ PHk loc i) -> Q2 m1 m2.
  Proof.
    intros ce ty m1 loc ofs bf v m2 Hal Hav.
    destruct (al_gen _ _ _ _ _ _ _ _ Hal) as (U & N & P).
    split.
    - eapply Mem.unchanged_on_implies; [exact U |].
      intros b z Hk _ E. subst b. exact (Hav z Hk).
    - split; [rewrite N; apply Ple_refl |].
      split; [intros b' o k p _; exact (P b' o k p) |].
      intros b' o k p V Hp. apply V. exact (Mem.perm_valid_block _ _ _ _ _ (proj1 (P _ _ _ _) Hp)).
  Qed.
End QF.

Lemma Q2_mono : forall (P1 P2 : block -> Z -> Prop) m0 m1,
  (forall b z, P2 b z -> P1 b z) -> Q2 P1 m0 m1 -> Q2 P2 m0 m1.
Proof.
  intros P1 P2 m0 m1 Hi (U & N & P & F).
  split; [| exact (conj N (conj P F))].
  eapply Mem.unchanged_on_implies; [exact U |]. intros b z H _. exact (Hi b z H).
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. Small evaluation facts.                                             *)
(* ---------------------------------------------------------------------- *)
Lemma cut_undef : forall l x p, (create_undef_temps l) ! x = Some p -> p = Vundef.
Proof.
  induction l as [| [y ty] l IH]; intros x p H; cbn [create_undef_temps] in H.
  - rewrite PTree.gempty in H. discriminate H.
  - rewrite PTree.gsspec in H. destruct (peq x y); [injection H as <-; reflexivity | exact (IH x p H)].
Qed.

Lemma cast_pp : forall t1 a1 t2 a2 b o v m,
  sem_cast (Vptr b o) (Tpointer t1 a1) (Tpointer t2 a2) m = Some v -> v = Vptr b o.
Proof. intros t1 a1 t2 a2 b o v m H. cbn in H. congruence. Qed.

Lemma cast_ap : forall t1 n a1 t2 a2 b o v m,
  sem_cast (Vptr b o) (Tarray t1 n a1) (Tpointer t2 a2) m = Some v -> v = Vptr b o.
Proof. intros t1 n a1 t2 a2 b o v m H. cbn in H. congruence. Qed.

Lemma add_pi : forall (ce : composite_env) v1 t a n sz sg a' m b o,
  sem_binary_operation ce Oadd v1 (Tpointer t a) (Vint n) (Tint sz sg a') m = Some (Vptr b o) ->
  exists o1, v1 = Vptr b o1.
Proof.
  intros ce v1 t a n sz sg a' m b o H.
  destruct v1, sz; cbn in H; try discriminate H; injection H as -> _; eexists; reflexivity.
Qed.

Section EV.
  Variable ge : genv.

  Lemma ev_evar_ptr : forall e le m x b ty0 t a v,
    e ! x = Some (b, ty0) -> eval_expr ge e le m (Evar x (Tpointer t a)) v ->
    Mem.load Mint32 m b 0 = Some v.
  Proof.
    intros e le m x b ty0 t a v He H.
    inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end;
      [| congruence].
    match goal with Hx : e ! x = Some (?l, _) |- _ => rewrite He in Hx; injection Hx as <- _ end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      match goal with Ha : access_mode _ = _ |- _ => vm_compute in Ha; try discriminate Ha end.
    match goal with Ha : By_value _ = By_value _, Hl : Mem.loadv _ _ _ = Some _ |- _ =>
      injection Ha as <-; exact Hl end.
  Qed.

  Lemma ev_lv_evar : forall e le m x b ty0 ty loc ofs bf,
    e ! x = Some (b, ty0) -> eval_lvalue ge e le m (Evar x ty) loc ofs bf ->
    loc = b /\ ofs = Ptrofs.zero /\ bf = Full.
  Proof.
    intros e le m x b ty0 ty loc ofs bf He H. inv H; [| congruence].
    split; [congruence | split; reflexivity].
  Qed.

  (* an array-typed field evaluates to its address *)
  Lemma ev_arr : forall e le m a f t n att v,
    eval_expr ge e le m (Efield a f (Tarray t n att)) v ->
    exists loc ofs bf, eval_lvalue ge e le m (Efield a f (Tarray t n att)) loc ofs bf /\ v = Vptr loc ofs.
  Proof.
    intros e le m a f t n att v H. inv H.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
      try match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end;
      try match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    do 3 eexists. split; [eassumption | reflexivity].
  Qed.
End EV.

(* ---------------------------------------------------------------------- *)
(* 4. The callees: vec3s_copy / vec3f_copy.                               *)
(* ---------------------------------------------------------------------- *)
Definition V3T : list ident := [math_util._t'5; math_util._t'3; math_util._t'1].

Definition v3_set_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id math_util._dest)
  && (negb (existsb (Pos.eqb id) V3T)
      || match a with Evar x (Tpointer _ _) => Pos.eqb x math_util._dest | _ => false end).

Definition v3_store_ok (lv rhs : expr) : bool :=
  match lv with
  | Evar x (Tpointer _ _) =>
      Pos.eqb x math_util._dest
      && match rhs with Etempvar y (Tpointer _ _) => Pos.eqb y math_util._dest | _ => false end
  | Ederef (Ebinop Oadd (Etempvar x (Tpointer _ _)) (Econst_int _ (Tint _ _ _)) (Tpointer _ _)) _ =>
      existsb (Pos.eqb x) V3T
  | _ => false
  end.

Definition no_call (_ : option ident) (_ : expr) (_ : list expr) : bool := false.

Lemma v3s_chk : lw_chk v3_set_ok v3_store_ok no_call (fn_body math_util.f_vec3s_copy) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma v3f_chk : lw_chk v3_set_ok v3_store_ok no_call (fn_body math_util.f_vec3f_copy) = true.
Proof. vm_compute. reflexivity. Qed.

Section V3.
  Variable ge : genv.
  (* m: the caller's memory; me: after the frame's allocation; bb: the
     frame (dest's address-taken copy); l, ofs: the dest pointer *)
  Variables (m me : mem) (l bb : block) (ofs : ptrofs).

  Definition v3Q (mm : mem) : Prop :=
    Mem.unchanged_on (fun b _ => b <> l /\ Plt b (Mem.nextblock m)) me mm
    /\ Mem.nextblock mm = Mem.nextblock me
    /\ (forall b o k p, Mem.perm mm b o k p <-> Mem.perm me b o k p)
    /\ (Mem.load Mint32 mm bb 0 = Some Vundef \/ Mem.load Mint32 mm bb 0 = Some (Vptr l ofs)).

  Definition v3P (le : temp_env) : Prop :=
    le ! math_util._dest = Some (Vptr l ofs)
    /\ (forall x p, In x V3T -> le ! x = Some p -> p = Vundef \/ p = Vptr l ofs).

  Variable e : env.
  Variable ty0 : type.
  Hypothesis He : e ! math_util._dest = Some (bb, ty0).
  Hypothesis Nlb : l <> bb.
  Hypothesis Fbb : ~ Plt bb (Mem.nextblock m).
  Hypothesis Vbb : Plt bb (Mem.nextblock me).

  Lemma v3_set : forall id a le mm v,
    v3_set_ok id a = true -> v3P le -> v3Q mm ->
    eval_expr ge e le mm a v -> v3P (PTree.set id v le).
  Proof.
    intros id a le mm v Hs (Hd & Ht) (_ & _ & _ & Hbb) Ea.
    unfold v3_set_ok in Hs. apply andb_true_iff in Hs as (Hs1 & Hs2).
    apply negb_true_iff, Pos.eqb_neq in Hs1.
    split; [rewrite PTree.gso by congruence; exact Hd |].
    intros x p Hin Hx.
    destruct (peq x id) as [-> | Nx].
    - rewrite PTree.gss in Hx. injection Hx as <-.
      assert (T : existsb (Pos.eqb id) V3T = true)
        by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
      rewrite T in Hs2. cbn [negb orb] in Hs2.
      repeat match type of Hs2 with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
      end.
      apply Pos.eqb_eq in Hs2. subst.
      rewrite (ev_evar_ptr ge _ _ _ _ _ _ _ _ _ He Ea) in Hbb.
      destruct Hbb as [E | E]; injection E as ->; [left | right]; reflexivity.
    - rewrite PTree.gso in Hx by exact Nx. exact (Ht x p Hin Hx).
  Qed.

  Lemma v3_store : forall lv rhs le mm t le' mm' out,
    v3_store_ok lv rhs = true -> v3P le ->
    exec_stmt function_entry2 ge e le mm (Sassign lv rhs) t le' mm' out ->
    v3Q mm -> v3Q mm'.
  Proof.
    intros lv rhs le mm t le' mm' out Hs (Hd & Ht) Hx (U & N & P & Hbb).
    assert (Vbb' : Mem.valid_block mm bb) by (unfold Mem.valid_block; rewrite N; exact Vbb).
    inv Hx.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    unfold v3_store_ok in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    - (* dest's own copy: dest := (the parameter) *)
      apply andb_true_iff in Hs as (Hs1 & Hs2).
      repeat match type of Hs2 with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
      end.
      apply Pos.eqb_eq in Hs1, Hs2. subst.
      match goal with L : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
        destruct (ev_lv_evar ge _ _ _ _ _ _ _ _ _ _ He L) as (-> & -> & ->) end.
      match goal with Ev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Ev; rewrite Hd in Ev; injection Ev as <- end.
      match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => apply cast_pp in Hc; subst end.
      inv Hal;
        match goal with Hm : access_mode _ = _ |- _ => vm_compute in Hm; try discriminate Hm end.
      match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
        injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
      destruct (st_gen _ _ _ _ _ _ Hst) as (N2 & P2).
      split; [| split; [| split]].
      + eapply Mem.unchanged_on_trans; [exact U |].
        eapply Mem.store_unchanged_on; [exact Hst |]. intros i _ (_ & V). exact (Fbb V).
      + rewrite N2. exact N.
      + intros b o k p. rewrite P2. exact (P b o k p).
      + right. rewrite Ptrofs.unsigned_zero in Hst. rewrite (Mem.load_store_same _ _ _ _ _ _ Hst). reflexivity.
    - (* *(t + i) = ... with t one of V3T: a store into l *)
      apply existsb_exists in Hs as (x' & Hin & Ex). apply Pos.eqb_eq in Ex. subst x'.
      match goal with L : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
        apply eval_lvalue_Ederef_base in L; apply eval_expr_Ebinop_inv in L as (w1 & w2 & E1 & E2 & Sb) end.
      apply eval_expr_Etempvar_val in E1. apply eval_expr_Econst_int_val in E2. subst w2.
      cbn [typeof] in Sb.
      destruct (add_pi _ _ _ _ _ _ _ _ _ _ _ Sb) as (o1 & ->).
      destruct (Ht _ _ Hin E1) as [E | E]; [discriminate E | injection E as -> _].
      destruct (al_gen _ _ _ _ _ _ _ _ Hal) as (U2 & N2 & P2).
      split; [| split; [| split]].
      + eapply Mem.unchanged_on_trans; [exact U |].
        eapply Mem.unchanged_on_implies; [exact U2 |]. intros b z (A & _) _. exact A.
      + rewrite N2. exact N.
      + intros b o k p. rewrite P2. exact (P b o k p).
      + erewrite Mem.load_unchanged_on_1; [exact Hbb | exact U2 | exact Vbb' |].
        intros z _. exact (not_eq_sym Nlb).
  Qed.
End V3.

Lemma v3_frame : forall (ge : genv) f m l ofs vs t m' vr,
  f = math_util.f_vec3s_copy \/ f = math_util.f_vec3f_copy ->
  eval_funcall function_entry2 ge m (Internal f) (Vptr l ofs :: vs) t m' vr ->
  Mem.valid_block m l ->
  Q2 (fun b _ => b <> l) m m'.
Proof.
  intros ge f m l ofs vs t m' vr Hf Hev Vl.
  assert (Hchk : lw_chk v3_set_ok v3_store_ok no_call (fn_body f) = true)
    by (destruct Hf as [-> | ->]; [exact v3s_chk | exact v3f_chk]).
  assert (Hvars : exists T, fn_vars f = [(math_util._dest, tptr T)])
    by (destruct Hf as [-> | ->]; eexists; reflexivity).
  assert (Hpar : exists T, fn_params f = [(math_util._dest, tptr T); (math_util._src, tptr T)])
    by (destruct Hf as [-> | ->]; eexists; reflexivity).
  destruct Hvars as (T & Hvars). destruct Hpar as (T' & Hpar).
  inv Hev.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hvars in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc m 0 _ = (?m1, ?b1) |- _ =>
    rename Halc into HA; rename m1 into me; rename b1 into bb end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    rename Hb into Hbp; rename LE into le0 end.
  rewrite Hpar in Hbp.
  assert (Fbb : ~ Plt bb (Mem.nextblock m)) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA).
  assert (Nlb : l <> bb) by (intros ->; exact (Fbb Vl)).
  assert (Vbb : Plt bb (Mem.nextblock me)) by exact (Mem.valid_new_block _ _ _ _ _ HA).
  assert (He : (PTree.set math_util._dest (bb, tptr T) empty_env) ! math_util._dest = Some (bb, tptr T))
    by apply PTree.gss.
  (* the walk *)
  assert (HP0 : v3P l ofs le0).
  { split.
    - eapply MarioModel.MathGeomBodies.bind_parameter_temps_head; [| exact Hbp].
      cbn. intros [E | []]. discriminate E.
    - intros x p Hin Hx.
      cbn [bind_parameter_temps] in Hbp.
      destruct vs as [| v2 [| v3 vs]]; try discriminate Hbp.
      injection Hbp as <-.
      rewrite PTree.gso in Hx by (intros ->; destruct Hin as [E | [E | [E | []]]]; discriminate E).
      rewrite PTree.gso in Hx by (intros ->; destruct Hin as [E | [E | [E | []]]]; discriminate E).
      left; exact (cut_undef _ _ _ Hx). }
  assert (HQ0 : v3Q m me l bb ofs me).
  { split; [apply Mem.unchanged_on_refl |]. split; [reflexivity |]. split; [tauto |].
    left. eapply Mem.load_alloc_same'; [exact HA | lia | cbn; destruct Archi.ptr64; lia | apply Z.divide_0_r]. }
  destruct (lw_walk ge (PTree.set math_util._dest (bb, tptr T) empty_env)
              (v3Q m me l bb ofs) (v3P l ofs) v3_set_ok v3_store_ok no_call
              ltac:(intros; eapply v3_set; eassumption)
              ltac:(intros; eapply v3_store; eassumption)
              ltac:(intros; discriminate)
              _ _ _ _ _ _ _ _ Hbody eq_refl Hchk HP0 HQ0) as ((U & N & P & _) & _).
  try (match type of U with Mem.unchanged_on _ _ ?mm => rename mm into m2 end).

  rewrite MarioModel.MathGeomBodies.blocks_of_env_mu_dest in Hfree.
  cbn [Mem.free_list] in Hfree.
  match type of Hfree with
  | match Mem.free ?mm ?b ?lo ?hi with _ => _ end = Some _ =>
      destruct (Mem.free mm b lo hi) as [m3 |] eqn:Hfr; [| discriminate Hfree]
  end.
  injection Hfree as <-.
  assert (U1 : Mem.unchanged_on (fun b _ => b <> l /\ Plt b (Mem.nextblock m)) m me)
    by exact (Mem.alloc_unchanged_on _ _ _ _ _ _ HA).
  assert (U3 : Mem.unchanged_on (fun b _ => b <> l /\ Plt b (Mem.nextblock m)) m2 m3).
  { eapply Mem.free_unchanged_on; [exact Hfr |]. intros i _ (_ & V). exact (Fbb V). }
  assert (NA : Mem.nextblock me = Pos.succ (Mem.nextblock m)) by exact (Mem.nextblock_alloc _ _ _ _ _ HA).
  assert (NF : Mem.nextblock m3 = Mem.nextblock m2) by exact (Mem.nextblock_free _ _ _ _ _ Hfr).
  split.
  - eapply Mem.unchanged_on_implies.
    + exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U1 U) U3).
    + intros b z Nb Vb. exact (conj Nb Vb).
  - split; [rewrite NF, N, NA; apply Ple_succ |].
    split.
    + intros b o k p V.
      assert (Nbb : b <> bb) by (intros ->; exact (Fbb V)).
      split.
      * intros Hp. apply (Mem.perm_free_3 _ _ _ _ _ Hfr) in Hp. apply P in Hp.
        exact (Mem.perm_alloc_4 _ _ _ _ _ HA _ _ _ _ Hp Nbb).
      * intros Hp. apply (Mem.perm_free_1 _ _ _ _ _ Hfr); [left; exact Nbb |].
        apply P. exact (Mem.perm_alloc_1 _ _ _ _ _ HA _ _ _ _ Hp).
    + intros b o k p V Hp.
      pose proof (Mem.perm_free_3 _ _ _ _ _ Hfr _ _ _ _ Hp) as Hp2.
      apply P in Hp2.
      destruct (peq b bb) as [-> | Nbb].
      * pose proof (Mem.perm_alloc_3 _ _ _ _ _ HA _ _ _ Hp2) as R.
        exact (Mem.perm_free_2 _ _ _ _ _ Hfr o k p R Hp).
      * apply V. exact (Mem.perm_valid_block _ _ _ _ _ (Mem.perm_alloc_4 _ _ _ _ _ HA _ _ _ _ Hp2 Nbb)).
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. vec3f_set (2026-10-24, squish_mario_model): byte-precise.  A call   *)
(*    with dest = (l, ofs) changes only the 12 bytes [ofs, ofs + 12) of   *)
(*    l, plus its own freed `dest` frame.                                 *)
(* ---------------------------------------------------------------------- *)
Definition V3S : list ident := [math_util._t'3; math_util._t'2; math_util._t'1].

Definition v3s_set_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id math_util._dest)
  && (negb (existsb (Pos.eqb id) V3S)
      || match a with Evar x (Tpointer _ _) => Pos.eqb x math_util._dest | _ => false end).

Definition v3s_store_ok (lv rhs : expr) : bool :=
  match lv with
  | Evar x (Tpointer _ _) =>
      Pos.eqb x math_util._dest
      && match rhs with Etempvar y (Tpointer _ _) => Pos.eqb y math_util._dest | _ => false end
  | Ederef (Ebinop Oadd (Etempvar x (Tpointer (Tfloat F32 _) _)) (Econst_int i (Tint _ _ _))
                   (Tpointer (Tfloat F32 _) _)) (Tfloat F32 _) =>
      existsb (Pos.eqb x) V3S && (Int.unsigned i <? 3)
  | _ => false
  end.

Lemma v3set_chk : lw_chk v3s_set_ok v3s_store_ok no_call (fn_body math_util.f_vec3f_set) = true.
Proof. vm_compute. reflexivity. Qed.

(* p + i for a float pointer p, 0 <= i < 3, inside the address space *)
Lemma add_pf : forall (ce : composite_env) l o a a1 n sz sg a' mm loc o',
  sem_binary_operation ce Oadd (Vptr l o) (Tpointer (Tfloat F32 a) a1) (Vint n) (Tint sz sg a') mm
    = Some (Vptr loc o') ->
  Int.unsigned n < 3 -> Ptrofs.unsigned o + 12 <= Ptrofs.modulus ->
  loc = l /\ Ptrofs.unsigned o' = Ptrofs.unsigned o + 4 * Int.unsigned n.
Proof.
  intros ce l o a a1 n sz sg a' mm loc o' H Hn Ho.
  assert (Hs : Int.signed n = Int.unsigned n)
    by (apply Int.signed_eq_unsigned; change Int.max_signed with 2147483647; lia).
  destruct sz; cbn -[Ptrofs.add Ptrofs.mul Ptrofs.repr] in H; injection H as <- <-; split; try reflexivity;
    unfold ptrofs_of_int in *; try destruct sg; unfold Ptrofs.of_ints, Ptrofs.of_intu, Ptrofs.of_int in *; rewrite ?Hs;
    pose proof (Int.unsigned_range n) as Rn; pose proof (Ptrofs.unsigned_range o) as Ro;
    unfold Ptrofs.add, Ptrofs.mul;
    assert (Mx : 11 <= Ptrofs.max_unsigned) by (unfold Ptrofs.max_unsigned; lia);
    rewrite (Ptrofs.unsigned_repr 4) by lia;
    rewrite ?(Ptrofs.unsigned_repr (Int.unsigned n)) by lia;
    rewrite (Ptrofs.unsigned_repr (4 * Int.unsigned n)) by lia;
    rewrite Ptrofs.unsigned_repr by (unfold Ptrofs.max_unsigned; lia); reflexivity.
Qed.

(* the same for a float array decayed to a pointer (a[i], squish_mario_model) *)
Lemma add_af : forall (ce : composite_env) l o a k a1 n sz sg a' mm loc o',
  sem_binary_operation ce Oadd (Vptr l o) (Tarray (Tfloat F32 a) k a1) (Vint n) (Tint sz sg a') mm
    = Some (Vptr loc o') ->
  Int.unsigned n < 3 -> Ptrofs.unsigned o + 12 <= Ptrofs.modulus ->
  loc = l /\ Ptrofs.unsigned o' = Ptrofs.unsigned o + 4 * Int.unsigned n.
Proof.
  intros ce l o a k a1 n sz sg a' mm loc o' H Hn Ho.
  assert (Hs : Int.signed n = Int.unsigned n)
    by (apply Int.signed_eq_unsigned; change Int.max_signed with 2147483647; lia).
  destruct sz; cbn -[Ptrofs.add Ptrofs.mul Ptrofs.repr] in H; injection H as <- <-; split; try reflexivity;
    unfold ptrofs_of_int in *; try destruct sg; unfold Ptrofs.of_ints, Ptrofs.of_intu, Ptrofs.of_int in *; rewrite ?Hs;
    pose proof (Int.unsigned_range n) as Rn; pose proof (Ptrofs.unsigned_range o) as Ro;
    unfold Ptrofs.add, Ptrofs.mul;
    assert (Mx : 11 <= Ptrofs.max_unsigned) by (unfold Ptrofs.max_unsigned; lia);
    rewrite (Ptrofs.unsigned_repr 4) by lia;
    rewrite ?(Ptrofs.unsigned_repr (Int.unsigned n)) by lia;
    rewrite (Ptrofs.unsigned_repr (4 * Int.unsigned n)) by lia;
    rewrite Ptrofs.unsigned_repr by (unfold Ptrofs.max_unsigned; lia); reflexivity.
Qed.

Section V3SET.
  Variable ge : genv.
  Variables (m me : mem) (l bb : block) (ofs : ptrofs).
  Let lo := Ptrofs.unsigned ofs.

  Definition v3sQ (mm : mem) : Prop :=
    Mem.unchanged_on (fun b z => ~ (b = l /\ lo <= z < lo + 12) /\ Plt b (Mem.nextblock m)) me mm
    /\ Mem.nextblock mm = Mem.nextblock me
    /\ (forall b o k p, Mem.perm mm b o k p <-> Mem.perm me b o k p)
    /\ (Mem.load Mint32 mm bb 0 = Some Vundef \/ Mem.load Mint32 mm bb 0 = Some (Vptr l ofs)).

  Definition v3sP (le : temp_env) : Prop :=
    le ! math_util._dest = Some (Vptr l ofs)
    /\ (forall x p, In x V3S -> le ! x = Some p -> p = Vundef \/ p = Vptr l ofs).

  Variable e : env.
  Variable ty0 : type.
  Hypothesis He : e ! math_util._dest = Some (bb, ty0).
  Hypothesis Nlb : l <> bb.
  Hypothesis Fbb : ~ Plt bb (Mem.nextblock m).
  Hypothesis Vbb : Plt bb (Mem.nextblock me).
  Hypothesis Hlo : lo + 12 <= Ptrofs.modulus.

  Lemma v3s_set : forall id a le mm v,
    v3s_set_ok id a = true -> v3sP le -> v3sQ mm ->
    eval_expr ge e le mm a v -> v3sP (PTree.set id v le).
  Proof.
    intros id a le mm v Hs (Hd & Ht) (_ & _ & _ & Hbb) Ea.
    unfold v3s_set_ok in Hs. apply andb_true_iff in Hs as (Hs1 & Hs2).
    apply negb_true_iff, Pos.eqb_neq in Hs1.
    split; [rewrite PTree.gso by congruence; exact Hd |].
    intros x p Hin Hx.
    destruct (peq x id) as [-> | Nx].
    - rewrite PTree.gss in Hx. injection Hx as <-.
      assert (T : existsb (Pos.eqb id) V3S = true)
        by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
      rewrite T in Hs2. cbn [negb orb] in Hs2.
      repeat match type of Hs2 with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
      end.
      apply Pos.eqb_eq in Hs2. subst.
      rewrite (ev_evar_ptr ge _ _ _ _ _ _ _ _ _ He Ea) in Hbb.
      destruct Hbb as [E | E]; injection E as ->; [left | right]; reflexivity.
    - rewrite PTree.gso in Hx by exact Nx. exact (Ht x p Hin Hx).
  Qed.

  Lemma v3s_store : forall lv rhs le mm t le' mm' out,
    v3s_store_ok lv rhs = true -> v3sP le ->
    exec_stmt function_entry2 ge e le mm (Sassign lv rhs) t le' mm' out ->
    v3sQ mm -> v3sQ mm'.
  Proof.
    intros lv rhs le mm t le' mm' out Hs (Hd & Ht) Hx (U & N & P & Hbb).
    assert (Vbb' : Mem.valid_block mm bb) by (unfold Mem.valid_block; rewrite N; exact Vbb).
    inv Hx.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    unfold v3s_store_ok in Hs.
    repeat match type of Hs with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hs
    end.
    - (* dest's own copy: dest := (the parameter) *)
      apply andb_true_iff in Hs as (Hs1 & Hs2).
      repeat match type of Hs2 with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hs2
      end.
      apply Pos.eqb_eq in Hs1, Hs2. subst.
      match goal with L : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
        destruct (ev_lv_evar ge _ _ _ _ _ _ _ _ _ _ He L) as (-> & -> & ->) end.
      match goal with Ev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Ev; rewrite Hd in Ev; injection Ev as <- end.
      match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => apply cast_pp in Hc; subst end.
      inv Hal;
        match goal with Hm : access_mode _ = _ |- _ => vm_compute in Hm; try discriminate Hm end.
      match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
        injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
      destruct (st_gen _ _ _ _ _ _ Hst) as (N2 & P2).
      split; [| split; [| split]].
      + eapply Mem.unchanged_on_trans; [exact U |].
        eapply Mem.store_unchanged_on; [exact Hst |]. intros i _ (_ & V). exact (Fbb V).
      + rewrite N2. exact N.
      + intros b o k p. rewrite P2. exact (P b o k p).
      + right. rewrite Ptrofs.unsigned_zero in Hst. rewrite (Mem.load_store_same _ _ _ _ _ _ Hst). reflexivity.
    - (* *(t + i) = ... with t one of V3S, i < 3: a store into [lo, lo + 12) of l *)
      apply andb_true_iff in Hs as (Hs & Hi). apply Z.ltb_lt in Hi.
      apply existsb_exists in Hs as (x' & Hin & Ex). apply Pos.eqb_eq in Ex. subst x'.
      match goal with L : eval_lvalue _ _ _ _ (Ederef _ _) _ _ ?bf |- _ =>
        assert (Ebf : bf = Full) by (inv L; reflexivity); subst bf;
        apply eval_lvalue_Ederef_base in L; apply eval_expr_Ebinop_inv in L as (w1 & w2 & E1 & E2 & Sb) end.
      apply eval_expr_Etempvar_val in E1. apply eval_expr_Econst_int_val in E2. subst w2.
      cbn [typeof] in Sb.
      destruct (Ht _ _ Hin E1) as [E | E]; [subst w1; match type of Sb with sem_binary_operation _ _ _ _ _ (Tint ?s _ _) _ = _ => destruct s; cbn in Sb; discriminate Sb end |].
      subst w1.
      destruct (add_pf _ _ _ _ _ _ _ _ _ _ _ _ Sb Hi Hlo) as (-> & Eo).
      inv Hal;
        match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
      match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
        injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
      destruct (st_gen _ _ _ _ _ _ Hst) as (N2 & P2).
      split; [| split; [| split]].
      + eapply Mem.unchanged_on_trans; [exact U |].
        eapply Mem.store_unchanged_on; [exact Hst |]. intros z Hz (A & _). apply A.
        rewrite Eo in Hz. cbn [size_chunk] in Hz. unfold lo. match type of Eo with _ = _ + 4 * Int.unsigned ?n => pose proof (Int.unsigned_range n) end. split; [reflexivity | lia].
      + rewrite N2. exact N.
      + intros b o k p. rewrite P2. exact (P b o k p).
      + erewrite Mem.load_store_other; [exact Hbb | exact Hst |]. left. exact (not_eq_sym Nlb).
  Qed.
End V3SET.

Lemma v3set_frame : forall (ge : genv) m l ofs vs t m' vr,
  eval_funcall function_entry2 ge m (Internal math_util.f_vec3f_set) (Vptr l ofs :: vs) t m' vr ->
  Mem.valid_block m l -> Ptrofs.unsigned ofs + 12 <= Ptrofs.modulus ->
  Q2 (fun b z => ~ (b = l /\ Ptrofs.unsigned ofs <= z < Ptrofs.unsigned ofs + 12)) m m'.
Proof.
  intros ge m l ofs vs t m' vr Hev Vl Hlo.
  inv Hev.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars math_util.f_vec3f_set] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc m 0 _ = (?m1, ?b1) |- _ =>
    rename Halc into HA; rename m1 into me; rename b1 into bb end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    rename Hb into Hbp; rename LE into le0 end.
  assert (Fbb : ~ Plt bb (Mem.nextblock m)) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA).
  assert (Nlb : l <> bb) by (intros ->; exact (Fbb Vl)).
  assert (Vbb : Plt bb (Mem.nextblock me)) by exact (Mem.valid_new_block _ _ _ _ _ HA).
  assert (He : (PTree.set math_util._dest (bb, tptr tfloat) empty_env) ! math_util._dest = Some (bb, tptr tfloat))
    by apply PTree.gss.
  assert (HP0 : v3sP l ofs le0).
  { split.
    - eapply MarioModel.MathGeomBodies.bind_parameter_temps_head; [| exact Hbp].
      cbn. intros [E | [E | [E | []]]]; discriminate E.
    - intros x p Hin Hx.
      cbn [bind_parameter_temps fn_params math_util.f_vec3f_set] in Hbp.
      destruct vs as [| v2 [| v3 [| v4 [| v5 vs]]]]; try discriminate Hbp.
      injection Hbp as <-.
      do 4 (rewrite PTree.gso in Hx by (intros ->; destruct Hin as [E | [E | [E | []]]]; discriminate E)).
      left; exact (cut_undef (fn_temps math_util.f_vec3f_set) _ _ Hx). }
  assert (HQ0 : v3sQ m me l bb ofs me).
  { split; [apply Mem.unchanged_on_refl |]. split; [reflexivity |]. split; [tauto |].
    left. eapply Mem.load_alloc_same'; [exact HA | lia | cbn; destruct Archi.ptr64; lia | apply Z.divide_0_r]. }
  destruct (lw_walk ge (PTree.set math_util._dest (bb, tptr tfloat) empty_env)
              (v3sQ m me l bb ofs) (v3sP l ofs) v3s_set_ok v3s_store_ok no_call
              ltac:(intros; eapply v3s_set; eassumption)
              ltac:(intros; eapply v3s_store; eassumption)
              ltac:(intros; discriminate)
              _ _ _ _ _ _ _ _ Hbody eq_refl v3set_chk HP0 HQ0) as ((U & N & P & _) & _).
  try (match type of U with Mem.unchanged_on _ _ ?mm => rename mm into m2 end).
  rewrite MarioModel.MathGeomBodies.blocks_of_env_mu_dest in Hfree.
  cbn [Mem.free_list] in Hfree.
  match type of Hfree with
  | match Mem.free ?mm ?b ?lo ?hi with _ => _ end = Some _ =>
      destruct (Mem.free mm b lo hi) as [m3 |] eqn:Hfr; [| discriminate Hfree]
  end.
  injection Hfree as <-.
  set (K := fun b z => ~ (b = l /\ Ptrofs.unsigned ofs <= z < Ptrofs.unsigned ofs + 12)).
  assert (U1 : Mem.unchanged_on (fun b z => K b z /\ Plt b (Mem.nextblock m)) m me)
    by exact (Mem.alloc_unchanged_on _ _ _ _ _ _ HA).
  assert (U3 : Mem.unchanged_on (fun b z => K b z /\ Plt b (Mem.nextblock m)) m2 m3).
  { eapply Mem.free_unchanged_on; [exact Hfr |]. intros i _ (_ & V). exact (Fbb V). }
  assert (NA : Mem.nextblock me = Pos.succ (Mem.nextblock m)) by exact (Mem.nextblock_alloc _ _ _ _ _ HA).
  assert (NF : Mem.nextblock m3 = Mem.nextblock m2) by exact (Mem.nextblock_free _ _ _ _ _ Hfr).
  split.
  - eapply Mem.unchanged_on_implies.
    + exact (Mem.unchanged_on_trans _ _ _ _ (Mem.unchanged_on_trans _ _ _ _ U1 U) U3).
    + intros b z Nb Vb. exact (conj Nb Vb).
  - split; [rewrite NF, N, NA; apply Ple_succ |].
    split.
    + intros b o k p V.
      assert (Nbb : b <> bb) by (intros ->; exact (Fbb V)).
      split.
      * intros Hp. apply (Mem.perm_free_3 _ _ _ _ _ Hfr) in Hp. apply P in Hp.
        exact (Mem.perm_alloc_4 _ _ _ _ _ HA _ _ _ _ Hp Nbb).
      * intros Hp. apply (Mem.perm_free_1 _ _ _ _ _ Hfr); [left; exact Nbb |].
        apply P. exact (Mem.perm_alloc_1 _ _ _ _ _ HA _ _ _ _ Hp).
    + intros b o k p V Hp.
      pose proof (Mem.perm_free_3 _ _ _ _ _ Hfr _ _ _ _ Hp) as Hp2.
      apply P in Hp2.
      destruct (peq b bb) as [-> | Nbb].
      * pose proof (Mem.perm_alloc_3 _ _ _ _ _ HA _ _ _ Hp2) as R.
        exact (Mem.perm_free_2 _ _ _ _ _ Hfr o k p R Hp).
      * apply V. exact (Mem.perm_valid_block _ _ _ _ _ (Mem.perm_alloc_4 _ _ _ _ _ HA _ _ _ _ Hp2 Nbb)).
Qed.
