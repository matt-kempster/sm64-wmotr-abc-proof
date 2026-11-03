(* ====================================================================== *)
(* spine (via ObjSpawnAt / BhvStep's spawn rows): OBJECTS -- the graph    *)
(* node half of a spawn.  geo_obj_init (graph_node.c), run by its real    *)
(* body on a fresh slot's GraphNodeObject:                                *)
(*   - vec3f_set / vec3f_copy / vec3s_copy (math_util.c): BYTE-PRECISE    *)
(*     frames -- a call with dest = (l, ofs) changes only [ofs, ofs + 12) *)
(*     of l, plus its own freed `dest` frame (BodyFrame.v3set_frame for   *)
(*     the set; v3c_frame here for the two copies);                       *)
(*   - the stores after them (sharedChild, unk4C, throwMatrix, curAnim,   *)
(*     the four node.flags updates) through ObjCreate's slot walker (fx). *)
(* Result: geo_ok -- the call changes only slot k's non-link bytes (KP)   *)
(* and keeps every value fact outside [0, 96) (the GraphNodeObject).      *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Globalenvs
  Ctypes Cop Clight ClightBigstep Events Clightdefs.
From SM64.Generated Require math_util graph_node.
From SM64.Proofs Require Import RealFrameValue MarioModel.AudioBodies.
From SM64.Proofs Require MarioModel.MathGeomBodies.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame.
Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. vec3f_copy / vec3s_copy: byte-precise.                               *)
(* ---------------------------------------------------------------------- *)
Definition v3c_store_ok (lv rhs : expr) : bool :=
  match lv with
  | Evar x (Tpointer _ _) =>
      Pos.eqb x math_util._dest
      && match rhs with Etempvar y (Tpointer _ _) => Pos.eqb y math_util._dest | _ => false end
  | Ederef (Ebinop Oadd (Etempvar x (Tpointer (Tfloat F32 _) _)) (Econst_int i (Tint _ _ _))
                   (Tpointer (Tfloat F32 _) _)) (Tfloat F32 _) =>
      existsb (Pos.eqb x) V3T && (Int.unsigned i <? 3)
  | Ederef (Ebinop Oadd (Etempvar x (Tpointer (Tint I16 Signed _) _)) (Econst_int i (Tint _ _ _))
                   (Tpointer (Tint I16 Signed _) _)) (Tint I16 Signed _) =>
      existsb (Pos.eqb x) V3T && (Int.unsigned i <? 3)
  | _ => false
  end.

Lemma v3cs_chk : lw_chk v3_set_ok v3c_store_ok no_call (fn_body math_util.f_vec3s_copy) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma v3cf_chk : lw_chk v3_set_ok v3c_store_ok no_call (fn_body math_util.f_vec3f_copy) = true.
Proof. vm_compute. reflexivity. Qed.

(* p + i for a short pointer p, 0 <= i < 3 *)
Lemma add_ps : forall (ce : composite_env) l o a a1 n sz sg a' mm loc o',
  sem_binary_operation ce Oadd (Vptr l o) (Tpointer (Tint I16 Signed a) a1) (Vint n) (Tint sz sg a') mm
    = Some (Vptr loc o') ->
  Int.unsigned n < 3 -> Ptrofs.unsigned o + 12 <= Ptrofs.modulus ->
  loc = l /\ Ptrofs.unsigned o' = Ptrofs.unsigned o + 2 * Int.unsigned n.
Proof.
  intros ce l o a a1 n sz sg a' mm loc o' H Hn Ho.
  assert (Hs : Int.signed n = Int.unsigned n)
    by (apply Int.signed_eq_unsigned; change Int.max_signed with 2147483647; lia).
  destruct sz; cbn -[Ptrofs.add Ptrofs.mul Ptrofs.repr] in H; injection H as <- <-; split; try reflexivity;
    unfold ptrofs_of_int in *; try destruct sg; unfold Ptrofs.of_ints, Ptrofs.of_intu, Ptrofs.of_int in *; rewrite ?Hs;
    pose proof (Int.unsigned_range n) as Rn; pose proof (Ptrofs.unsigned_range o) as Ro;
    unfold Ptrofs.add, Ptrofs.mul;
    assert (Mx : 11 <= Ptrofs.max_unsigned) by (unfold Ptrofs.max_unsigned; lia);
    rewrite (Ptrofs.unsigned_repr 2) by lia;
    rewrite ?(Ptrofs.unsigned_repr (Int.unsigned n)) by lia;
    rewrite (Ptrofs.unsigned_repr (2 * Int.unsigned n)) by lia;
    rewrite Ptrofs.unsigned_repr by (unfold Ptrofs.max_unsigned; lia); reflexivity.
Qed.

Section V3C.
  Variable ge : genv.
  Variables (m me : mem) (l bb : block) (ofs : ptrofs).
  Let lo := Ptrofs.unsigned ofs.

  Definition v3cQ (mm : mem) : Prop :=
    Mem.unchanged_on (fun b z => ~ (b = l /\ lo <= z < lo + 12) /\ Plt b (Mem.nextblock m)) me mm
    /\ Mem.nextblock mm = Mem.nextblock me
    /\ (forall b o k p, Mem.perm mm b o k p <-> Mem.perm me b o k p)
    /\ (Mem.load Mint32 mm bb 0 = Some Vundef \/ Mem.load Mint32 mm bb 0 = Some (Vptr l ofs)).

  Definition v3cP (le : temp_env) : Prop :=
    le ! math_util._dest = Some (Vptr l ofs)
    /\ (forall x p, In x V3T -> le ! x = Some p -> p = Vundef \/ p = Vptr l ofs).

  Variable e : env.
  Variable ty0 : type.
  Hypothesis He : e ! math_util._dest = Some (bb, ty0).
  Hypothesis Nlb : l <> bb.
  Hypothesis Fbb : ~ Plt bb (Mem.nextblock m).
  Hypothesis Vbb : Plt bb (Mem.nextblock me).
  Hypothesis Hlo : lo + 12 <= Ptrofs.modulus.

  Lemma v3c_set : forall id a le mm v,
    v3_set_ok id a = true -> v3cP le -> v3cQ mm ->
    eval_expr ge e le mm a v -> v3cP (PTree.set id v le).
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

  Lemma v3c_store : forall lv rhs le mm t le' mm' out,
    v3c_store_ok lv rhs = true -> v3cP le ->
    exec_stmt function_entry2 ge e le mm (Sassign lv rhs) t le' mm' out ->
    v3cQ mm -> v3cQ mm'.
  Proof.
    intros lv rhs le mm t le' mm' out Hs (Hd & Ht) Hx (U & N & P & Hbb).
    assert (Vbb' : Mem.valid_block mm bb) by (unfold Mem.valid_block; rewrite N; exact Vbb).
    inv Hx.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    unfold v3c_store_ok in Hs.
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
    - (* *(t + i) = ... (shorts), t one of V3T, i < 3 *)
      apply andb_true_iff in Hs as (Hs & Hi). apply Z.ltb_lt in Hi.
      apply existsb_exists in Hs as (x' & Hin & Ex). apply Pos.eqb_eq in Ex. subst x'.
      match goal with L : eval_lvalue _ _ _ _ (Ederef _ _) _ _ ?bf |- _ =>
        assert (Ebf : bf = Full) by (inv L; reflexivity); subst bf;
        apply eval_lvalue_Ederef_base in L; apply eval_expr_Ebinop_inv in L as (w1 & w2 & E1 & E2 & Sb) end.
      apply eval_expr_Etempvar_val in E1. apply eval_expr_Econst_int_val in E2. subst w2.
      cbn [typeof] in Sb.
      destruct (Ht _ _ Hin E1) as [E | E]; [subst w1; match type of Sb with sem_binary_operation _ _ _ _ _ (Tint ?s _ _) _ = _ => destruct s; cbn in Sb; discriminate Sb end |].
      subst w1.
      destruct (add_ps _ _ _ _ _ _ _ _ _ _ _ _ Sb Hi Hlo) as (-> & Eo).
      inv Hal;
        match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
      match goal with Hm : By_value _ = By_value _, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
        injection Hm as <-; cbn [Mem.storev] in Hs; rename Hs into Hst end.
      destruct (st_gen _ _ _ _ _ _ Hst) as (N2 & P2).
      split; [| split; [| split]].
      + eapply Mem.unchanged_on_trans; [exact U |].
        eapply Mem.store_unchanged_on; [exact Hst |]. intros z Hz (A & _). apply A.
        rewrite Eo in Hz. cbn [size_chunk] in Hz. unfold lo. match type of Eo with _ = _ + 2 * Int.unsigned ?n => pose proof (Int.unsigned_range n) end. split; [reflexivity | lia].
      + rewrite N2. exact N.
      + intros b o k p. rewrite P2. exact (P b o k p).
      + erewrite Mem.load_store_other; [exact Hbb | exact Hst |]. left. exact (not_eq_sym Nlb).
    - (* *(t + i) = ... (floats), t one of V3T, i < 3 *)
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
End V3C.

Lemma v3c_frame : forall (ge : genv) f m l ofs vs t m' vr,
  f = math_util.f_vec3s_copy \/ f = math_util.f_vec3f_copy ->
  eval_funcall function_entry2 ge m (Internal f) (Vptr l ofs :: vs) t m' vr ->
  Mem.valid_block m l -> Ptrofs.unsigned ofs + 12 <= Ptrofs.modulus ->
  Q2 (fun b z => ~ (b = l /\ Ptrofs.unsigned ofs <= z < Ptrofs.unsigned ofs + 12)) m m'.
Proof.
  intros ge f m l ofs vs t m' vr Hf Hev Vl Hlo.
  assert (Hchk : lw_chk v3_set_ok v3c_store_ok no_call (fn_body f) = true)
    by (destruct Hf as [-> | ->]; [exact v3cs_chk | exact v3cf_chk]).
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
  assert (HP0 : v3cP l ofs le0).
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
  assert (HQ0 : v3cQ m me l bb ofs me).
  { split; [apply Mem.unchanged_on_refl |]. split; [reflexivity |]. split; [tauto |].
    left. eapply Mem.load_alloc_same'; [exact HA | lia | cbn; destruct Archi.ptr64; lia | apply Z.divide_0_r]. }
  destruct (lw_walk ge (PTree.set math_util._dest (bb, tptr T) empty_env)
              (v3cQ m me l bb ofs) (v3cP l ofs) v3_set_ok v3c_store_ok no_call
              ltac:(intros; eapply v3c_set; eassumption)
              ltac:(intros; eapply v3c_store; eassumption)
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

(* ---------------------------------------------------------------------- *)
(* 2. geo_obj_init on a slot's GraphNodeObject.                            *)
(* ---------------------------------------------------------------------- *)
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc ObjCreate.
From SM64.Proofs.WMotRRequiresA Require ObjSelf RenderAnim ObjLoop.
Local Transparent Archi.ptr64.
Module RA := RenderAnim.
Module GN := SM64.Generated.graph_node.
Module MU := SM64.Generated.math_util.

(* the walker's None-ness does not depend on the incoming facts *)
Lemma fx_none : forall ce x s F G, fx ce x s F = None -> fx ce x s G = None.
Proof.
  intros ce x. induction s; intros F G H; cbn [fx] in *; try reflexivity; try discriminate H.
  - revert H.
    match goal with |- context [ObjSelf.lad ce [x] ?l] => destruct (ObjSelf.lad ce [x] l) as [d|]; [ | reflexivity ] end.
    match goal with |- context [access_mode ?t] => destruct (access_mode t) as [ch| | | ]; try reflexivity end.
    destruct (wr_ok d (size_chunk ch)); [ discriminate | reflexivity ].
  - revert H. match goal with |- context [Pos.eqb ?i x] => destruct (Pos.eqb i x) end; [ reflexivity | discriminate ].
  - destruct (fx ce x s1 F) as [F1|] eqn:E1.
    + destruct (fx ce x s1 G) as [G1|] eqn:E2; [ exact (IHs2 F1 G1 H) | reflexivity ].
    + rewrite (IHs1 F G E1). reflexivity.
  - destruct (fx ce x s1 F) as [Fa|] eqn:E1.
    + destruct (fx ce x s2 F) as [Fb|] eqn:E2; [ discriminate H | ].
      destruct (fx ce x s1 G) as [Ga|]; [ | reflexivity ].
      rewrite (IHs2 F G E2). reflexivity.
    + rewrite (IHs1 F G E1). reflexivity.
Qed.

Definition GNO : type := Tstruct GN._GraphNodeObject noattr.
Definition GP : expr := Etempvar GN._graphNode (tptr GNO).
Definition CEG : composite_env := prog_comp_env GN.prog.
Definition ONE : expr := Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat.
Definition A_SC : expr := Efield (Ederef GP GNO) GN._scale (tarray tfloat 3).
Definition A_PS : expr := Efield (Ederef GP GNO) GN._pos (tarray tfloat 3).
Definition A_AN : expr := Efield (Ederef GP GNO) GN._angle (tarray tshort 3).
Definition C1 : statement :=
  Scall None (Evar GN._vec3f_set (Tfunction [tptr tfloat; tfloat; tfloat; tfloat] (tptr tvoid) cc_default))
    [A_SC; ONE; ONE; ONE].
Definition C2 : statement :=
  Scall None (Evar GN._vec3f_copy (Tfunction [tptr tfloat; tptr tfloat] (tptr tvoid) cc_default))
    [A_PS; Etempvar GN._pos (tptr tfloat)].
Definition C3 : statement :=
  Scall None (Evar GN._vec3s_copy (Tfunction [tptr tshort; tptr tshort] (tptr tvoid) cc_default))
    [A_AN; Etempvar GN._angle (tptr tshort)].
Definition GTAIL : statement := sdrop 3 (fn_body GN.f_geo_obj_init).

Lemma GB_eq : fn_body GN.f_geo_obj_init = Ssequence C1 (Ssequence C2 (Ssequence C3 GTAIL)).
Proof. reflexivity. Qed.

Definition D_SC : Z := 44.
Definition D_PS : Z := 32.
Definition D_AN : Z := 26.
Lemma lad_SC : ObjSelf.lad CEG [GN._graphNode] A_SC = Some D_SC.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_PS : ObjSelf.lad CEG [GN._graphNode] A_PS = Some D_PS.
Proof. vm_compute. reflexivity. Qed.
Lemma lad_AN : ObjSelf.lad CEG [GN._graphNode] A_AN = Some D_AN.
Proof. vm_compute. reflexivity. Qed.
Lemma d_ok : (20 <= D_SC /\ D_SC + 12 <= 96) /\ (20 <= D_PS /\ D_PS + 12 <= 96) /\ (20 <= D_AN /\ D_AN + 12 <= 96).
Proof. unfold D_SC, D_PS, D_AN. lia. Qed.

Lemma gtail_some : fx CEG GN._graphNode GTAIL [] <> None.
Proof. vm_compute. discriminate. Qed.

Definition ffx (F : list fact) : list fact :=
  match fx CEG GN._graphNode GTAIL F with Some F' => F' | None => [] end.

Lemma ffx_ok : forall F, fx CEG GN._graphNode GTAIL F = Some (ffx F).
Proof.
  intros F. unfold ffx. destruct (fx CEG GN._graphNode GTAIL F) eqn:E; [ reflexivity | ].
  exfalso. apply gtail_some. exact (fx_none _ _ _ _ _ E).
Qed.

(* what survives geo_obj_init: the three vectors' 12-byte windows killed,
   then the tail's stores (sharedChild / flags killed; unk4C, throwMatrix,
   animInfo.curAnim := 0) *)
Definition geo_facts (F : list fact) : list fact :=
  ffx (kill D_AN 12 (kill D_PS 12 (kill D_SC 12 F))).

Lemma exl_hd : forall (G : genv) e le m a al tys vs, eval_exprlist G e le m (a :: al) tys vs ->
  exists ty tys' v w vs', tys = ty :: tys' /\ vs = w :: vs' /\ eval_expr G e le m a v
    /\ sem_cast v (typeof a) ty m = Some w.
Proof. intros G e le m a al tys vs H. inv H. eauto 10. Qed.

Section GEO.
  Variable ge : genv.
  Variables pool gB : block.
  Hypothesis Hpool : Genv.find_symbol ge ObjSelf.POOL = Some pool.
  Hypothesis HgB : Genv.find_symbol ge ObjSelf.GCO = Some gB.
  Hypothesis Hce : ObjSelf.cext ge CEG.
  Hypothesis Hset : forall b fd, Genv.find_symbol ge GN._vec3f_set = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal MU.f_vec3f_set.
  Hypothesis Hfc : forall b fd, Genv.find_symbol ge GN._vec3f_copy = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal MU.f_vec3f_copy.
  Hypothesis Hsc : forall b fd, Genv.find_symbol ge GN._vec3s_copy = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal MU.f_vec3s_copy.
  Variable k : Z.
  Hypothesis Hk : 0 <= k < NSLOT.
  Notation b0 := (k * OSZ).
  Notation ov := (slot_v pool k).
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  (* a 12-byte window [d, d + 12) of the GraphNodeObject, clear of the links *)
  Lemma win_kp : forall d, 20 <= d -> d + 12 <= 96 ->
    forall b z, KP pool b0 b z -> ~ (b = pool /\ b0 + d <= z < b0 + d + 12).
  Proof. intros d H1 H2 b z Hz (-> & Hz'). unfold KP, OSZ in *. lia. Qed.

  (* one vector call: dest = &graphNode->f, f's window at d *)
  Lemma vcall : forall fid T targs tres a2 al d f le m t le' m' out F,
    ObjSelf.lad CEG [GN._graphNode] (Efield (Ederef GP GNO) a2 (tarray T 3)) = Some d -> 20 <= d -> d + 12 <= 96 ->
    (forall b fd, Genv.find_symbol ge fid = Some b ->
       Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal f) ->
    (forall m0 l ofs vs t0 m1 vr, eval_funcall function_entry2 ge m0 (Internal f) (Vptr l ofs :: vs) t0 m1 vr ->
       Mem.valid_block m0 l -> Ptrofs.unsigned ofs + 12 <= Ptrofs.modulus ->
       Q2 (fun b z => ~ (b = l /\ Ptrofs.unsigned ofs <= z < Ptrofs.unsigned ofs + 12)) m0 m1) ->
    le ! GN._graphNode = Some ov -> Mem.valid_block m pool -> facts m pool b0 ov F ->
    xs le m (Scall None (Evar fid (Tfunction (tptr T :: targs) tres cc_default))
               (Efield (Ederef GP GNO) a2 (tarray T 3) :: al)) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.unchanged_on (KP pool b0) m m' /\ facts m' pool b0 ov (kill d 12 F).
  Proof.
    intros fid T targs tres a2 al d f le m t le' m' out F Hd H1 H2 Hres Hfr Hx Hv HF H.
    apply RA.call_inv in H as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hc & -> & ->).
    cbn in Hcf. injection Hcf as <- <- <-.
    destruct (RA.ev_fun ge empty_env _ _ _ (Tfunction (tptr T :: targs) tres cc_default) vf
                (PTree.gempty _ _) eq_refl Evf) as (bf & Hsf & ->).
    rewrite (Hres bf fd Hsf Hff) in Hc.
    destruct (exl_hd _ _ _ _ _ _ _ _ Eal) as (ty1 & tys' & v & w & vs' & Ety & -> & Ev & Cv).
    injection Ety as <- _.
    destruct (ev_arr ge _ _ _ _ _ _ _ _ _ Ev) as (loc & o & bf' & Hl & ->).
    destruct (lad_at ge pool gB Hpool HgB CEG Hce GN._graphNode k le m _ loc o bf' d Hx Hl Hd) as (-> & -> & ->).
    cbn [typeof] in Cv. apply cast_ap in Cv. subst w.
    assert (Eo : Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr b0) (Ptrofs.repr d)) = b0 + d)
      by (apply slot_fld; [ exact Hk | unfold OSZ; lia ]).
    assert (Hlo : Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr b0) (Ptrofs.repr d)) + 12 <= Ptrofs.modulus).
    { rewrite Eo. pose proof maxu32 as M. unfold Ptrofs.max_unsigned in M. unfold OSZ, NSLOT in *. lia. }
    destruct (Hfr _ _ _ _ _ _ _ Hc Hv Hlo) as (U & _).
    rewrite Eo in U.
    refine (conj eq_refl (conj eq_refl (conj _ _))).
    - eapply Mem.unchanged_on_implies; [ exact U | ]. intros b z Hz _. exact (win_kp d H1 H2 b z Hz).
    - apply (facts_kill_unch m m' pool b0 ov F d 12); [ | exact HF ].
      eapply Mem.unchanged_on_implies; [ exact U | ]. intros b z Hz _ (-> & Hz'). destruct Hz as [Hz | Hz]; [ apply Hz; reflexivity | lia ].
  Qed.

  (* GEO_OBJ_INIT ON SLOT k: only slot k's non-link bytes change; every value
     fact outside the three vector windows survives, then the tail's *)
  Theorem geo_ok : forall m sc pv av t m' vr F,
    eval_funcall function_entry2 ge m (Internal GN.f_geo_obj_init) [ov; sc; pv; av] t m' vr ->
    Mem.valid_block m pool -> facts m pool b0 ov F ->
    Mem.unchanged_on (KP pool b0) m m' /\ facts m' pool b0 ov (geo_facts F).
  Proof.
    intros m sc pv av t m' vr F H Hv HF.
    destruct (fcall_inv0 ge GN.f_geo_obj_init m _ t m' vr eq_refl H) as (le & le' & out & Hbd & Hx & _).
    cbn [fn_params GN.f_geo_obj_init bind_parameter_temps] in Hbd. injection Hbd as Hle.
    assert (Hg : le ! GN._graphNode = Some ov).
    { rewrite <- Hle. rewrite !PTree.gso by RA.neq. apply PTree.gss. }
    destruct d_ok as ((S1 & S2) & (P1 & P2) & (A1 & A2)).
    rewrite GB_eq in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Hne)].
    2:{ apply RA.call_inv in X1 as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E). contradiction. }
    destruct (vcall GN._vec3f_set tfloat [tfloat; tfloat; tfloat] (tptr tvoid) GN._scale [ONE; ONE; ONE] D_SC
                MU.f_vec3f_set le m t1 le1 m1 Out_normal F lad_SC S1 S2 Hset
                (fun m0 l ofs vs t0 m1 vr H Vl Hlo => v3set_frame ge m0 l ofs vs t0 m1 vr H Vl Hlo)
                Hg Hv HF X1) as (-> & _ & U1 & HF1).
    pose proof (Mem.valid_block_unchanged_on _ _ _ _ U1 Hv) as Hv1.
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Hne)].
    2:{ apply RA.call_inv in X3 as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E). contradiction. }
    destruct (vcall GN._vec3f_copy tfloat [tptr tfloat] (tptr tvoid) GN._pos [Etempvar GN._pos (tptr tfloat)] D_PS
                MU.f_vec3f_copy le m1 t3 le3 m3 Out_normal _ lad_PS P1 P2 Hfc
                (fun m0 l ofs vs t0 m1 vr H Vl Hlo => v3c_frame ge MU.f_vec3f_copy m0 l ofs vs t0 m1 vr (or_intror eq_refl) H Vl Hlo)
                Hg Hv1 HF1 X3) as (-> & _ & U3 & HF3).
    pose proof (Mem.valid_block_unchanged_on _ _ _ _ U3 Hv1) as Hv3.
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Hne)].
    2:{ apply RA.call_inv in X5 as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & E). contradiction. }
    destruct (vcall GN._vec3s_copy tshort [tptr tshort] (tptr tvoid) GN._angle [Etempvar GN._angle (tptr tshort)] D_AN
                MU.f_vec3s_copy le m3 t5 le5 m5 Out_normal _ lad_AN A1 A2 Hsc
                (fun m0 l ofs vs t0 m1 vr H Vl Hlo => v3c_frame ge MU.f_vec3s_copy m0 l ofs vs t0 m1 vr (or_introl eq_refl) H Vl Hlo)
                Hg Hv3 HF3 X5) as (-> & _ & U5 & HF5).
    destruct (fx_sound ge pool gB Hpool HgB CEG Hce GN._graphNode k Hk GTAIL _ _ (ffx_ok _)
                _ _ _ _ _ _ X6 Hg HF5) as (_ & _ & HF6 & U6).
    split; [ | exact HF6 ].
    exact (Mem.unchanged_on_trans _ _ _ _ U1 (Mem.unchanged_on_trans _ _ _ _ U3
             (Mem.unchanged_on_trans _ _ _ _ U5 U6))).
  Qed.
End GEO.
