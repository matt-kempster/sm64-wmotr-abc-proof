(* ====================================================================== *)
(* SmaFoot (unwired, GOAL 2): the write footprint of the REAL              *)
(* set_mario_animation (mario.c), with load_patchable_table and dma_read  *)
(* (memory.c) run from their generated bodies, down to the libultra DMA   *)
(* floor (OsDmaFloor, TRUST 3.5).                                         *)
(*                                                                        *)
(* sma_foot: a call set_mario_animation(m, id), with m->animList the      *)
(* pinned list &gMarioAnimsBuf (offset 0), m->marioObj = (bo, oo) and     *)
(* the list's bufTarget = (bt, ot), changes memory only                   *)
(*   - inside the DMA buffer block bt,                                    *)
(*   - in the list's currentAddr cell (ab, [4,8)),                        *)
(*   - in the three DMA globals (gDmaIoMesg, gDmaMesgQueue,               *)
(*     gMainReceivedMesg), and                                            *)
(*   - only if the animation changed: in Mario's object's animInfo cells  *)
(*     animID / animYTrans / curAnim / animFrame / animAccel, after which *)
(*     curAnim = (bt, ot) and animAccel = 0;                              *)
(* keeps every block and permission, and returns a non-pointer.  This is  *)
(* what the symbolic walk of act_freefall needs to answer the call         *)
(* (SymExec2 contract c_sma).                                              *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Classical_Prop String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Memdata Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario memory.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked RealFrameValue CensusV2
  OsDmaFloor ActWriterSurface LinkedTwelve LptBody.
From SM64.Proofs Require RestSurface OutParamSurface.

Import ListNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* Footprints                                                             *)
(* ---------------------------------------------------------------------- *)

(* m differs from m0 only on W, with the same blocks and permissions *)
Definition foot (W : block -> Z -> Prop) (m0 m : mem) : Prop :=
  Mem.unchanged_on (fun b z => ~ W b z) m0 m /\ same_perms m0 m.

Lemma foot_refl : forall W m, foot W m m.
Proof. intros W m. split; [ apply Mem.unchanged_on_refl | split; [ reflexivity | tauto ] ]. Qed.

Lemma foot_step : forall W m0 m m', foot W m0 m ->
  Mem.unchanged_on (fun b z => ~ W b z) m m' -> same_perms m m' -> foot W m0 m'.
Proof.
  intros W m0 m m' (U & N & P) U' (N' & P'). split; [ eapply Mem.unchanged_on_trans; eauto | ].
  split; [ congruence | intros b z k p; rewrite P'; apply P ].
Qed.

Lemma foot_mono : forall (W W' : block -> Z -> Prop) m0 m,
  (forall b z, W b z -> W' b z) -> foot W m0 m -> foot W' m0 m.
Proof.
  intros W W' m0 m H (U & SP). split; [ | exact SP ].
  eapply Mem.unchanged_on_implies; [ exact U | ]. intros b z N _ Wz. exact (N (H b z Wz)).
Qed.

Lemma store_perms : forall ch m b z v m', Mem.store ch m b z v = Some m' -> same_perms m m'.
Proof.
  intros ch m b z v m' S. split; [ exact (Mem.nextblock_store _ _ _ _ _ _ S) | ].
  intros b' z' k p. split; [ eapply Mem.perm_store_2; eauto | eapply Mem.perm_store_1; eauto ].
Qed.

Lemma store_foot : forall (W : block -> Z -> Prop) m0 m ch b z v m',
  Mem.store ch m b z v = Some m' -> (forall i, z <= i < z + size_chunk ch -> W b i) ->
  foot W m0 m -> foot W m0 m'.
Proof.
  intros W m0 m ch b z v m' S IN F. eapply foot_step; [ exact F | | exact (store_perms _ _ _ _ _ _ S) ].
  eapply Mem.store_unchanged_on; [ exact S | ]. intros i R N. exact (N (IN i R)).
Qed.

(* a cell outside the footprint reads the same *)
Lemma foot_load : forall W m0 m ch b z v, foot W m0 m ->
  (forall i, z <= i < z + size_chunk ch -> ~ W b i) ->
  Mem.load ch m0 b z = Some v -> Mem.load ch m b z = Some v.
Proof.
  intros W m0 m ch b z v (U & _) N L. eapply Mem.load_unchanged_on; [ exact U | | exact L ].
  intros i R. exact (N i R).
Qed.

(* ---------------------------------------------------------------------- *)
(* Plain statements always finish normally                                *)
(* ---------------------------------------------------------------------- *)

Fixpoint plain (s : statement) : bool :=
  match s with
  | Sskip | Sassign _ _ | Sset _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence a b | Sifthenelse _ a b => plain a && plain b
  | _ => false
  end.

Lemma plain_normal : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> plain s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros P; cbn [plain] in P; try reflexivity;
    try discriminate P.
  - apply andb_prop in P as [_ P2]. exact (IHexec_stmt2 P2).
  - apply andb_prop in P as [P1 _]. exfalso. exact (H0 (IHexec_stmt P1)).
  - apply andb_prop in P as [P1 P2]. destruct b; [ exact (IHexec_stmt P1) | exact (IHexec_stmt P2) ].
Qed.

Lemma seq_plain : forall ge e le m s1 s2 t le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out -> plain s1 = true ->
  exists t1 le1 m1 t2, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal
    /\ exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out.
Proof.
  intros ge e le m s1 s2 t le' m' out H P. inv H.
  - do 4 eexists. split; eassumption.
  - exfalso. match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, N : ?o <> Out_normal |- _ =>
      exact (N (plain_normal _ _ _ _ _ _ _ _ _ H1 P)) end.
Qed.

(* ---------------------------------------------------------------------- *)
(* Field paths: p->f1.f2...fk, with its offset in a composite env          *)
(* ---------------------------------------------------------------------- *)

Fixpoint fpath (ce : composite_env) (a : expr) : option (ident * Z) :=
  match a with
  | Ederef (Etempvar p _) (Tstruct _ _) => Some (p, 0)
  | Efield a' f _ =>
      match typeof a' with
      | Tstruct sid _ =>
          match ce ! sid with
          | Some co =>
              if complete_members ce (co_members co) then
                match field_offset ce f (co_members co), fpath ce a' with
                | OK (d, Full), Some (p, d0) => Some (p, d0 + d)
                | _, _ => None
                end
              else None
          | None => None
          end
      | _ => None
      end
  | _ => None
  end.

Lemma complete_members_stable : forall (env env' : composite_env),
  (forall id co, env ! id = Some co -> env' ! id = Some co) ->
  forall ms, complete_members env ms = true -> complete_members env' ms = true.
Proof.
  intros env env' Hext ms. induction ms as [| m ms IH]; intros H; [ reflexivity | ].
  cbn in *. apply andb_prop in H as [H1 H2]. rewrite (complete_type_stable env env' Hext _ H1).
  exact (IH H2).
Qed.

Lemma fpath_agree : forall (q lp : Clight.program) a x, linkorder q lp ->
  fpath (prog_comp_env q) a = Some x -> fpath (prog_comp_env lp) a = Some x.
Proof.
  intros q lp a. induction a; intros x LO H; cbn [fpath] in *; try discriminate H.
  - destruct a; try discriminate H. destruct t; try discriminate H. exact H.
  - destruct (typeof a) eqn:Ta; try discriminate H.
    destruct ((prog_comp_env q) ! i0) as [co|] eqn:Hco; try discriminate H.
    rewrite (linkorder_comp_env_extends lp q i0 co LO Hco).
    destruct (complete_members (prog_comp_env q) (co_members co)) eqn:Hc; try discriminate H.
    rewrite (complete_members_stable _ _ (fun id co' => linkorder_comp_env_extends lp q id co' LO) _ Hc).
    rewrite (linkorder_field_offset_agree lp q i (co_members co) LO Hc).
    destruct (field_offset (prog_comp_env q) i (co_members co)) as [[d bf]|]; try discriminate H.
    destruct bf; try discriminate H.
    destruct (fpath (prog_comp_env q) a) as [[p d0]|] eqn:Hp; try discriminate H.
    rewrite (IHa _ LO eq_refl). exact H.
Qed.

Lemma ptrofs_add_repr2 : forall o d1 d2,
  Ptrofs.add (Ptrofs.add o (Ptrofs.repr d1)) (Ptrofs.repr d2) = Ptrofs.add o (Ptrofs.repr (d1 + d2)).
Proof.
  intros o d1 d2. rewrite Ptrofs.add_assoc. f_equal.
  unfold Ptrofs.add at 1. apply Ptrofs.eqm_samerepr.
  apply Ptrofs.eqm_add; apply Ptrofs.eqm_sym; apply Ptrofs.eqm_unsigned_repr.
Qed.

(* a field path evaluates, as an lvalue, to the root pointer plus its offset *)
Lemma fpath_lvalue : forall (ge : genv) e le m a p d loc ofs bf,
  fpath (genv_cenv ge) a = Some (p, d) ->
  eval_lvalue ge e le m a loc ofs bf ->
  exists o, le ! p = Some (Vptr loc o) /\ ofs = Ptrofs.add o (Ptrofs.repr d) /\ bf = Full.
Proof.
  intros ge e le m a. induction a; intros p d loc ofs bf HP HL; cbn [fpath] in HP; try discriminate HP.
  - destruct a; try discriminate HP. destruct t; try discriminate HP. injection HP as <- <-.
    inv HL. match goal with Hx : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hx; exists ofs; split; [ exact Hx | ] end.
    split; [ rewrite Ptrofs.add_zero; reflexivity | reflexivity ].
  - destruct (typeof a) eqn:Ta; try discriminate HP.
    destruct ((genv_cenv ge) ! i0) as [co|] eqn:Hco; try discriminate HP.
    destruct (complete_members (genv_cenv ge) (co_members co)); try discriminate HP.
    destruct (field_offset (genv_cenv ge) i (co_members co)) as [[d1 bf1]|] eqn:Hfo; try discriminate HP.
    destruct bf1; try discriminate HP.
    destruct (fpath (genv_cenv ge) a) as [[p0 d0]|] eqn:Hp; try discriminate HP.
    injection HP as <- <-.
    apply eval_lvalue_Efield_inv in HL as (o0 & id & att & co' & delta & Hbase & Hco' & Hofs & Hcase).
    destruct Hcase as [(Hty & Hfo') | (Hty & _)]; rewrite Ta in Hty; [ | discriminate Hty ].
    injection Hty as <- <-. rewrite Hco in Hco'. injection Hco' as <-. rewrite Hfo in Hfo'.
    injection Hfo' as <- <-.
    (* the base is a struct-typed path: evaluated by address *)
    assert (BL : exists l1 o1 b1, eval_lvalue ge e le m a l1 o1 b1 /\ loc = l1 /\ o0 = o1).
    { destruct a; cbn [fpath] in Hp; try discriminate Hp.
      - apply eval_expr_Ederef_load in Hbase as (l1 & o1 & b1 & HL1 & HD).
        pose proof Ta as Ta'; cbn [typeof] in Ta'; rewrite Ta' in HD.
        apply deref_loc_aggregate_eq in HD as [-> ->]; [ | right; reflexivity ].
        exists l1, o1, b1. auto.
      - apply eval_expr_Efield_load in Hbase as (l1 & o1 & b1 & HL1 & HD).
        pose proof Ta as Ta'; cbn [typeof] in Ta'; rewrite Ta' in HD.
        apply deref_loc_aggregate_eq in HD as [-> ->]; [ | right; reflexivity ].
        exists l1, o1, b1. auto. }
    destruct BL as (l1 & o1 & b1 & HL1 & -> & ->).
    destruct (IHa _ _ _ _ _ eq_refl HL1) as (o & Hg & -> & _).
    exists o. split; [ exact Hg | split; [ subst ofs; apply ptrofs_add_repr2 | reflexivity ] ].
Qed.

(* a by-value field path, read *)
Lemma fpath_load : forall (ge : genv) e le m a p d ch v b o,
  fpath (genv_cenv ge) a = Some (p, d) -> access_mode (typeof a) = By_value ch ->
  le ! p = Some (Vptr b o) ->
  eval_expr ge e le m a v ->
  Mem.loadv ch m (Vptr b (Ptrofs.add o (Ptrofs.repr d))) = Some v.
Proof.
  intros ge e le m a p d ch v b o HP Hac Hg Hev.
  assert (LV : exists loc ofs bf, eval_lvalue ge e le m a loc ofs bf /\ deref_loc (typeof a) m loc ofs bf v).
  { destruct a; cbn [fpath] in HP; try discriminate HP.
    - destruct a; try discriminate HP. destruct t; try discriminate HP.
      cbn [typeof] in Hac. discriminate Hac.
    - apply eval_expr_Efield_load in Hev. exact Hev. }
  destruct LV as (loc & ofs & bf & HL & HD).
  destruct (fpath_lvalue _ _ _ _ _ _ _ _ _ _ HP HL) as (o' & Hg' & -> & ->).
  rewrite Hg in Hg'. injection Hg' as -> ->.
  inv HD; rewrite Hac in *; try discriminate.
  match goal with H : By_value _ = By_value _ |- _ => injection H as <- end. assumption.
Qed.

(* a by-value field path, written *)
Lemma fpath_store : forall (ge : genv) e le m a1 a2 t le' m' out p d ch b o,
  fpath (genv_cenv ge) a1 = Some (p, d) -> access_mode (typeof a1) = By_value ch ->
  le ! p = Some (Vptr b o) ->
  exec_stmt function_entry2 ge e le m (Sassign a1 a2) t le' m' out ->
  exists v v', eval_expr ge e le m a2 v /\ sem_cast v (typeof a2) (typeof a1) m = Some v'
    /\ Mem.store ch m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d))) v' = Some m'
    /\ le' = le /\ out = Out_normal.
Proof.
  intros ge e le m a1 a2 t le' m' out p d ch b o HP Hac Hg H. inv H.
  match goal with HL : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
    destruct (fpath_lvalue _ _ _ _ _ _ _ _ _ _ HP HL) as (o' & Hg' & -> & ->) end.
  rewrite Hg in Hg'. injection Hg' as -> ->.
  match goal with H2 : eval_expr _ _ _ _ a2 ?v2, H3 : sem_cast ?v2 _ _ _ = Some ?v |- _ =>
    exists v2, v; split; [ exact H2 | split; [ exact H3 | ] ] end.
  split; [ | auto ].
  match goal with HA : assign_loc _ _ _ _ _ _ _ _ |- _ => inv HA end; rewrite Hac in *; try discriminate.
  match goal with H : By_value _ = By_value _ |- _ => injection H as <- end. assumption.
Qed.

(* ---------------------------------------------------------------------- *)
(* The libultra calls and dma_read, under the floor                      *)
(* ---------------------------------------------------------------------- *)

Ltac crush_match H :=
  repeat match type of H with
         | context [ match ?x with _ => _ end ] => destruct x; try discriminate H
         end;
  repeat match goal with
         | E : (_ && _)%bool = true |- _ => apply andb_prop in E as [? ?]
         end;
  repeat match goal with
         | E : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in E; subst
         end.

Section SF.
Variable lp : Clight.program.
Hypothesis Hlink : linked12 lp.
Hypothesis Hfloor : os_dma_floor.
Variables ab bt biom bmq brm : block.
Variable ot : ptrofs.
Hypothesis Hab : Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab.
Hypothesis Hiom : Genv.find_symbol (lp_ge lp) memory._gDmaIoMesg = Some biom.
Hypothesis Hmq : Genv.find_symbol (lp_ge lp) memory._gDmaMesgQueue = Some bmq.
Hypothesis Hrm : Genv.find_symbol (lp_ge lp) memory._gMainReceivedMesg = Some brm.

Let LO_memory : linkorder memory.prog lp := linked12_LO_memory lp Hlink.
Let LO_mario : linkorder mario.prog lp := linked12_LO_mario lp Hlink.

(* the DMA footprint: the buffer block, the three DMA globals *)
Definition Wd (b : block) (z : Z) : Prop :=
  (b = bt /\ 0 <= z < Ptrofs.modulus) \/ (b = biom /\ 0 <= z < SZ_IOMESG)
  \/ (b = bmq /\ 0 <= z < SZ_MESGQ) \/ (b = brm /\ 0 <= z < 4).
(* ... and the list's currentAddr cell *)
Definition Wl (b : block) (z : Z) : Prop := Wd b z \/ (b = ab /\ 4 <= z < 8).

Lemma out_rng : forall b0 o n b z,
  (forall z', Ptrofs.unsigned o <= z' < Ptrofs.unsigned o + n -> Wl b0 z') ->
  ~ Wl b z -> outside b0 o n b z.
Proof.
  intros b0 o n b z H N. unfold outside.
  destruct (peq b b0) as [-> | NE]; [ | left; exact NE ].
  right. destruct (Z_lt_le_dec z (Ptrofs.unsigned o)) as [L | L]; [ left; exact L | right ].
  destruct (Z_lt_le_dec z (Ptrofs.unsigned o + n)) as [L' | L']; [ | exact L' ].
  exfalso. exact (N (H z (conj L L'))).
Qed.

Lemma rng_bt : forall o n, Ptrofs.unsigned o + n <= Ptrofs.modulus ->
  forall z', Ptrofs.unsigned o <= z' < Ptrofs.unsigned o + n -> Wl bt z'.
Proof.
  intros o n B z' R. left. left. split; [ reflexivity | ].
  pose proof (Ptrofs.unsigned_range o). lia.
Qed.

Lemma rng_iom : forall z', Ptrofs.unsigned Ptrofs.zero <= z' < Ptrofs.unsigned Ptrofs.zero + SZ_IOMESG ->
  Wl biom z'.
Proof. intros z' R. left. right. left. split; [ reflexivity | exact R ]. Qed.
Lemma rng_mq : forall z', Ptrofs.unsigned Ptrofs.zero <= z' < Ptrofs.unsigned Ptrofs.zero + SZ_MESGQ ->
  Wl bmq z'.
Proof. intros z' R. left. right. right. left. split; [ reflexivity | exact R ]. Qed.
Lemma rng_rm : forall z', Ptrofs.unsigned Ptrofs.zero <= z' < Ptrofs.unsigned Ptrofs.zero + 4 ->
  Wl brm z'.
Proof. intros z' R. left. right. right. right. split; [ reflexivity | exact R ]. Qed.

Lemma glob_arg : forall le m g ty ty0 ty' v b o bg,
  Genv.find_symbol (lp_ge lp) g = Some bg ->
  eval_expr (lp_ge lp) empty_env le m (Eaddrof (Evar g ty) ty0) v ->
  sem_cast v ty0 ty' m = Some (Vptr b o) -> b = bg /\ o = Ptrofs.zero.
Proof.
  intros le m g ty ty0 ty' v b o bg Hs Hv Hc.
  apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v.
  destruct (addrof_glob_val lp _ _ _ _ _ _ Hv) as (bg' & Hs' & E). injection E as <- <-.
  rewrite Hs in Hs'. injection Hs' as ->. auto.
Qed.

Lemma dest_arg : forall le m d ty ty' v b o,
  (forall b0 o0, le ! d = Some (Vptr b0 o0) -> b0 = bt) ->
  eval_expr (lp_ge lp) empty_env le m (Etempvar d ty) v ->
  sem_cast v ty ty' m = Some (Vptr b o) -> b = bt.
Proof.
  intros le m d ty ty' v b o Hs Hv Hc.
  apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v.
  exact (Hs _ _ (tempvar_val lp _ _ _ _ _ Hv)).
Qed.

Lemma call_inval_foot : forall m0 le m t le' m' out tl tr cc ty0 x1,
    exec_stmt function_entry2 (lp_ge lp) empty_env le m
      (Scall None (Evar memory._osInvalDCache (Tfunction tl tr cc))
         [Etempvar memory._dest ty0; x1]) t le' m' out ->
    (forall b o, le ! memory._dest = Some (Vptr b o) -> b = bt) ->
    foot Wl m0 m -> foot Wl m0 m'.
Proof.
  intros m0 le m t le' m' out tl tr cc ty0 x1 H Hs F.
  destruct (os_call_ext lp Hlink memory._osInvalDCache "osInvalDCache" _ _ _ _ _ _ _ _ eq_refl
              os_inval_named H eq_refl) as (sg & tyargs & vargs & vres & Hel & Hx).
  destruct Hfloor as (Hinv & _ & _).
  destruct (Hinv _ _ _ _ _ _ _ Hx) as (bp & op & n & -> & UO & SP & _ & BND).
  inv Hel.
  match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                  Hc : sem_cast _ _ _ _ = Some (Vptr bp op) |- _ =>
    pose proof (dest_arg _ _ _ _ _ _ _ _ Hs Hv Hc) as -> end.
  eapply foot_step; [ exact F | | exact SP ].
  eapply Mem.unchanged_on_implies; [ exact UO | ]. intros b z N _.
  exact (out_rng _ _ _ _ _ (rng_bt _ _ BND) N).
Qed.

Lemma call_pidma_foot : forall m0 le m t le' m' out tl tr cc g1t g1t' x1 x2 x3 ty0 x5 g2t g2t',
    exec_stmt function_entry2 (lp_ge lp) empty_env le m
      (Scall None (Evar memory._osPiStartDma (Tfunction tl tr cc))
         [Eaddrof (Evar memory._gDmaIoMesg g1t) g1t'; x1; x2; x3;
          Etempvar memory._dest ty0; x5;
          Eaddrof (Evar memory._gDmaMesgQueue g2t) g2t']) t le' m' out ->
    (forall b o, le ! memory._dest = Some (Vptr b o) -> b = bt) ->
    foot Wl m0 m -> foot Wl m0 m'.
Proof.
  intros m0 le m t le' m' out tl tr cc g1t g1t' x1 x2 x3 ty0 x5 g2t g2t' H Hs F.
  destruct (os_call_ext lp Hlink memory._osPiStartDma "osPiStartDma" _ _ _ _ _ _ _ _ eq_refl
              os_pidma_named H eq_refl) as (sg & tyargs & vargs & vres & Hel & Hx).
  destruct Hfloor as (_ & Hpi & _).
  destruct (Hpi _ _ _ _ _ _ _ Hx)
    as (bmb & omb & pri & dir & dev & bd & od & n & bq & oq & -> & UO & SP & _ & BND).
  inv Hel.
  match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gDmaIoMesg _) _) _,
                  Hc : sem_cast _ _ _ _ = Some (Vptr bmb omb) |- _ =>
    destruct (glob_arg _ _ _ _ _ _ _ _ _ _ Hiom Hv Hc) as [-> ->] end.
  repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
  match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                  Hc : sem_cast _ _ _ _ = Some (Vptr bd od) |- _ =>
    pose proof (dest_arg _ _ _ _ _ _ _ _ Hs Hv Hc) as -> end.
  match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gDmaMesgQueue _) _) _,
                  Hc : sem_cast _ _ _ _ = Some (Vptr bq oq) |- _ =>
    destruct (glob_arg _ _ _ _ _ _ _ _ _ _ Hmq Hv Hc) as [-> ->] end.
  eapply foot_step; [ exact F | | exact SP ].
  eapply Mem.unchanged_on_implies; [ exact UO | ]. intros b z N _.
  split; [ exact (out_rng _ _ _ _ _ (rng_bt _ _ BND) N) | ].
  split; [ exact (out_rng _ _ _ _ _ rng_iom N) | exact (out_rng _ _ _ _ _ rng_mq N) ].
Qed.

Lemma call_recv_foot : forall m0 le m t le' m' out tl tr cc g1t g1t' g2t g2t' x2,
    exec_stmt function_entry2 (lp_ge lp) empty_env le m
      (Scall None (Evar memory._osRecvMesg (Tfunction tl tr cc))
         [Eaddrof (Evar memory._gDmaMesgQueue g1t) g1t';
          Eaddrof (Evar memory._gMainReceivedMesg g2t) g2t'; x2]) t le' m' out ->
    foot Wl m0 m -> foot Wl m0 m'.
Proof.
  intros m0 le m t le' m' out tl tr cc g1t g1t' g2t g2t' x2 H F.
  destruct (os_call_ext lp Hlink memory._osRecvMesg "osRecvMesg" _ _ _ _ _ _ _ _ eq_refl
              os_recv_named H eq_refl) as (sg & tyargs & vargs & vres & Hel & Hx).
  destruct Hfloor as (_ & _ & Hrv & _).
  destruct (Hrv _ _ _ _ _ _ _ Hx) as (bq & oq & cell & fl & -> & _ & SP & UOq).
  inv Hel.
  match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gDmaMesgQueue _) _) _,
                  Hc : sem_cast _ _ _ _ = Some (Vptr bq oq) |- _ =>
    destruct (glob_arg _ _ _ _ _ _ _ _ _ _ Hmq Hv Hc) as [-> ->] end.
  (* the DMA queue's row of q_side: nothing besides the queue and the cell *)
  pose proof (UOq memory._gDmaMesgQueue [] eq_refl Hmq) as UO.
  repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
  assert (Gm : forall bk ok, cell = Vptr bk ok -> bk = brm /\ ok = Ptrofs.zero).
  { intros bk ok ->.
    match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gMainReceivedMesg _) _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr bk ok) |- _ =>
      exact (glob_arg _ _ _ _ _ _ _ _ _ _ Hrm Hv Hc) end. }
  eapply foot_step; [ exact F | | exact SP ].
  eapply Mem.unchanged_on_implies; [ exact UO | ]. intros b z N _.
  split; [ exact (out_rng _ _ _ _ _ rng_mq N) | split; [ | intros s [] ] ].
  destruct cell as [ | | | | | bk ok ]; try exact I.
  destruct (Gm _ _ eq_refl) as [-> ->]. exact (out_rng _ _ _ _ _ rng_rm N).
Qed.

(* ---- dma_read: its real body ---- *)
Definition dsafe : block -> Prop := fun b => b = bt.
Definition dset_ok (id : ident) (a : expr) : bool :=
  negb (mem_id id dma_cact) || ptr_arith_e dma_cact a.

Lemma dset_sound : forall m0 id a le m v,
    dset_ok id a = true -> chase_inv dsafe dma_cact le -> foot Wl m0 m ->
    eval_expr (lp_ge lp) empty_env le m a v -> chase_inv dsafe dma_cact (PTree.set id v le).
Proof.
  intros m0 id a le m v Hok Hci _ Hev t Ht b o Hg.
  destruct (peq t id) as [-> | NE].
  - rewrite PTree.gss in Hg. injection Hg as Ev. subst v.
    unfold dset_ok in Hok. rewrite Ht in Hok. cbn [negb orb] in Hok.
    exact (ptr_arith_safe dsafe dma_cact _ empty_env le m a _ Hci Hok Hev b o eq_refl).
  - rewrite PTree.gso in Hg by exact NE. exact (Hci t Ht b o Hg).
Qed.

Lemma dcall_sound : forall m0 o a al le m t le' m' out,
    dma_call_ok o a al = true -> chase_inv dsafe dma_cact le ->
    exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall o a al) t le' m' out ->
    foot Wl m0 m -> foot Wl m0 m' /\ chase_inv dsafe dma_cact le'.
Proof.
  intros m0 o a al le m t le' m' out Hok Hci H F.
  destruct o as [i|]; [ discriminate Hok | ].
  rewrite (scall_none_le _ _ _ _ _ _ _ _ _ _ H). split; [ | exact Hci ].
  assert (Hs : forall b o, le ! memory._dest = Some (Vptr b o) -> b = bt)
    by (intros b o; apply (Hci memory._dest eq_refl)).
  unfold dma_call_ok in Hok. apply orb_true_iff in Hok as [Hok | Hok];
    [ apply orb_true_iff in Hok as [Hok | Hok] | ].
  - unfold is_inval_call in Hok. crush_match Hok. eapply call_inval_foot; eassumption.
  - unfold is_pidma_call in Hok. crush_match Hok. eapply call_pidma_foot; eassumption.
  - unfold is_recv_call in Hok. crush_match Hok. eapply call_recv_foot; eassumption.
Qed.

Lemma dma_read_chk' :
  cw_chk dset_ok (fun _ _ => false) dma_call_ok (fn_body memory.f_dma_read) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma dma_read_foot : forall m0 m vargs t m' vres,
    eval_funcall function_entry2 (lp_ge lp) m (Internal memory.f_dma_read) vargs t m' vres ->
    (forall b o, hd_error vargs = Some (Vptr b o) -> b = bt) ->
    foot Wl m0 m -> foot Wl m0 m'.
Proof.
  intros m0 m vargs t m' vres Hevf Hhd F.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    change (fn_vars memory.f_dma_read) with (@nil (ident * type)) in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ => rename Hb into Hbind; set (le := L) in * end.
  match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
  assert (Hci : chase_inv dsafe dma_cact le).
  { intros tv Ht b o Hg.
    destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
      [ apply undef_temps_get in G0; discriminate G0 | ].
    destruct n as [| [| [| n]]]; cbv [memory.f_dma_read fn_params map fst nth_error] in N1; try (destruct n; discriminate N1); try discriminate N1;
      injection N1 as Et; subst tv; try discriminate Ht.
    destruct vargs as [| v0 vl]; [ discriminate N2 | ].
    cbn in N2. injection N2 as ->. apply (Hhd b o). reflexivity. }
  destruct (cw_walk (lp_ge lp) empty_env (foot Wl m0) (chase_inv dsafe dma_cact)
              dset_ok (fun _ _ => false) dma_call_ok
              (dset_sound m0)
              (fun _ _ _ _ _ _ _ _ Hno => ltac:(discriminate Hno))
              (dcall_sound m0)
              _ _ _ _ _ _ _ _ Hbody eq_refl dma_read_chk' Hci F)
    as [F' _].
  change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
  inv Hfree. exact F'.
Qed.

(* ---- load_patchable_table: its real body ---- *)

Lemma cenv_lp : genv_cenv (lp_ge lp) = prog_comp_env lp.
Proof. reflexivity. Qed.

Lemma ab_apart : forall i, 8 <= i < 12 -> bt <> ab -> ~ Wl ab i.
Proof.
  intros i R Nbt W. destruct W as [[(E & _) | [(E & _) | [(E & _) | (E & _)]]] | (_ & R')].
  - exact (Nbt (eq_sym E)).
  - refine (Genv.global_addresses_distinct (lp_ge lp) (id1 := mario._gMarioAnimsBuf) (id2 := memory._gDmaIoMesg) _ Hab Hiom E); discriminate.
  - refine (Genv.global_addresses_distinct (lp_ge lp) (id1 := mario._gMarioAnimsBuf) (id2 := memory._gDmaMesgQueue) _ Hab Hmq E); discriminate.
  - refine (Genv.global_addresses_distinct (lp_ge lp) (id1 := mario._gMarioAnimsBuf) (id2 := memory._gMainReceivedMesg) _ Hab Hrm E); discriminate.
  - lia.
Qed.

Definition is_buf_load (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar l _) (Tstruct sid _)) f (Tpointer _ _) =>
      Pos.eqb l memory._list && Pos.eqb sid memory._DmaHandlerList && Pos.eqb f memory._bufTarget
  | _ => false
  end.

Lemma buf_path : forall pt att ty,
  fpath (prog_comp_env memory.prog)
    (Efield (Ederef (Etempvar memory._list pt) (Tstruct memory._DmaHandlerList att))
       memory._bufTarget ty) = Some (memory._list, 8).
Proof. intros. vm_compute. reflexivity. Qed.

Lemma cur_path : forall pt att ty,
  fpath (prog_comp_env memory.prog)
    (Efield (Ederef (Etempvar memory._list pt) (Tstruct memory._DmaHandlerList att))
       memory._currentAddr ty) = Some (memory._list, 4).
Proof. intros. vm_compute. reflexivity. Qed.

Definition lG (le : temp_env) : Prop :=
  (forall b o, le ! memory._list = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero)
  /\ (forall b o, le ! memory._t'3 = Some (Vptr b o) -> b = bt).

Definition lset_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id memory._list) && (negb (Pos.eqb id memory._t'3) || is_buf_load a).

Section LPT.
Variable m0 : mem.
Hypothesis Hbuf0 : Mem.load Mptr m0 ab 8 = Some (Vptr bt ot).
Hypothesis Hbt_ab : bt <> ab.

Lemma ab_buf_apart : forall i, 8 <= i < 8 + size_chunk Mptr -> ~ Wl ab i.
Proof. intros i R. change (size_chunk Mptr) with 4 in R. apply ab_apart; [ lia | exact Hbt_ab ]. Qed.

Lemma lset_sound : forall id a le m v,
    lset_ok id a = true -> lG le -> foot Wl m0 m ->
    eval_expr (lp_ge lp) empty_env le m a v -> lG (PTree.set id v le).
Proof.
  intros id a le m v Hok (Hl & H3) F Hev.
  unfold lset_ok in Hok. apply andb_prop in Hok as [Hn Hok]. apply negb_true_iff in Hn.
  apply Pos.eqb_neq in Hn.
  split.
  - intros b o Hg. rewrite PTree.gso in Hg by congruence. exact (Hl b o Hg).
  - intros b o Hg. destruct (peq id memory._t'3) as [-> | NE].
    + rewrite PTree.gss in Hg. injection Hg as ->.
      rewrite Pos.eqb_refl in Hok. cbn [negb orb] in Hok.
      unfold is_buf_load in Hok. crush_match Hok.
      match type of Hev with eval_expr _ _ _ _ (Efield (Ederef (Etempvar _ ?pt) (Tstruct _ ?att)) _ ?ty) _ =>
        pose proof (fpath_agree _ _ _ _ LO_memory (buf_path pt att ty)) as HP end.
      rewrite <- cenv_lp in HP.
      apply eval_expr_Efield_load in Hev as (loc & ofs & bf & HL & HD).
      destruct (fpath_lvalue _ _ _ _ _ _ _ _ _ _ HP HL) as (o' & Hg' & -> & ->).
      destruct (Hl _ _ Hg') as [-> ->].
      inv HD; match goal with Hac : access_mode _ = _ |- _ => cbn [access_mode] in Hac; try discriminate Hac end.
      match goal with H : By_value _ = By_value _ |- _ => injection H as <- end.
      match goal with H : Mem.loadv _ _ _ = Some _ |- _ => rename H into HLd end.
      change (Mem.loadv Mptr m (Vptr ab (Ptrofs.add Ptrofs.zero (Ptrofs.repr 8))))
        with (Mem.load Mptr m ab 8) in HLd.
      rewrite (foot_load _ _ _ Mptr ab 8 _ F ab_buf_apart Hbuf0) in HLd.
      injection HLd as -> ->. reflexivity.
    + rewrite PTree.gso in Hg by congruence. exact (H3 b o Hg).
Qed.

Definition lstore_ok (a1 a2 : expr) : bool :=
  match a1 with
  | Efield (Ederef (Etempvar l _) (Tstruct sid _)) f (Tpointer _ _) =>
      Pos.eqb l memory._list && Pos.eqb sid memory._DmaHandlerList && Pos.eqb f memory._currentAddr
  | _ => false
  end.

Lemma lstore_sound : forall a1 a2 le m t le' m' out,
    lstore_ok a1 a2 = true -> lG le ->
    exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2) t le' m' out ->
    foot Wl m0 m -> foot Wl m0 m'.
Proof.
  intros a1 a2 le m t le' m' out Hok (Hl & _) H F.
  unfold lstore_ok in Hok. crush_match Hok.
  match type of H with exec_stmt _ _ _ _ _ (Sassign (Efield (Ederef (Etempvar _ ?pt) (Tstruct _ ?att)) _ ?ty) _) _ _ _ _ =>
    pose proof (fpath_agree _ _ _ _ LO_memory (cur_path pt att ty)) as HP end.
  rewrite <- cenv_lp in HP.
  assert (HR : exists b o, le ! memory._list = Some (Vptr b o)).
  { inv H. match goal with HL : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
      destruct (fpath_lvalue _ _ _ _ _ _ _ _ _ _ HP HL) as (o' & Hg & _) end. eauto. }
  destruct HR as (b & o & Hg). destruct (Hl _ _ Hg) as [-> ->].
  destruct (fpath_store _ _ _ _ _ _ _ _ _ _ _ _ Mptr _ _ HP eq_refl Hg H)
    as (v & v' & _ & _ & S & _).
  change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 4))) with 4 in S.
  eapply store_foot; [ exact S | | exact F ].
  intros i R. right. split; [ reflexivity | ]. change (size_chunk Mptr) with 4 in R. lia.
Qed.

Definition lcall_ok (o : option ident) (a : expr) (al : list expr) : bool :=
  match o, a, al with
  | None, Evar f (Tfunction _ _ _), Etempvar t0 _ :: _ =>
      Pos.eqb f memory._dma_read && Pos.eqb t0 memory._t'3
  | _, _, _ => false
  end.

Lemma lcall_sound : forall o a al le m t le' m' out,
    lcall_ok o a al = true -> lG le ->
    exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall o a al) t le' m' out ->
    foot Wl m0 m -> foot Wl m0 m' /\ lG le'.
Proof.
  intros o a al le m t le' m' out Hok HG H F.
  destruct o as [i|]; [ discriminate Hok | ].
  rewrite (scall_none_le _ _ _ _ _ _ _ _ _ _ H). split; [ | exact HG ].
  destruct HG as (_ & H3).
  unfold lcall_ok in Hok. crush_match Hok.
  destruct (scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ H (PTree.gempty _ _) eq_refl)
    as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hfd & _ & Hel & Hev & _ & _).
  assert (Efd : fd = Internal memory.f_dma_read).
  { eapply RestSurface.resolves_pin_fd;
      [ exact LO_memory | exact memory_defmap_dma_read | exists b; split; eassumption ]. }
  subst fd. eapply dma_read_foot; [ exact Hev | | exact F ].
  intros b0 o0 Hhd. inv Hel. cbn in Hhd. injection Hhd as ->.
  match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                  Hc : sem_cast _ _ _ _ = Some (Vptr b0 o0) |- _ =>
    exact (dest_arg _ _ _ _ _ _ _ _ H3 Hv Hc) end.
Qed.

Lemma lpt_chk' :
  cw_chk lset_ok lstore_ok lcall_ok (fn_body memory.f_load_patchable_table) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma lpt_foot : forall m vargs t m' vres,
    eval_funcall function_entry2 (lp_ge lp) m
      (Internal memory.f_load_patchable_table) vargs t m' vres ->
    (forall b o, hd_error vargs = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero) ->
    foot Wl m0 m -> foot Wl m0 m'.
Proof.
  intros m vargs t m' vres Hevf Hhd F.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    change (fn_vars memory.f_load_patchable_table) with (@nil (ident * type)) in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ => rename Hb into Hbind; set (le := L) in * end.
  match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
  assert (HG : lG le).
  { split.
    - intros b o Hg.
      destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
        [ apply undef_temps_get in G0; discriminate G0 | ].
      destruct n as [| [| n]]; cbv [memory.f_load_patchable_table fn_params map fst nth_error] in N1; try (destruct n; discriminate N1); try discriminate N1.
      destruct vargs as [| v0 vl]; [ discriminate N2 | ].
      cbn in N2. injection N2 as ->. apply (Hhd b o). reflexivity.
    - intros b o Hg.
      destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
        [ apply undef_temps_get in G0; discriminate G0 | ].
      destruct n as [| [| n]]; cbv [memory.f_load_patchable_table fn_params map fst nth_error] in N1; try (destruct n; discriminate N1); try discriminate N1. }
  destruct (cw_walk (lp_ge lp) empty_env (foot Wl m0) lG lset_ok lstore_ok lcall_ok
              lset_sound lstore_sound lcall_sound
              _ _ _ _ _ _ _ _ Hbody eq_refl lpt_chk' HG F)
    as [F' _].
  change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
  inv Hfree. exact F'.
Qed.
End LPT.

(* ---- stores through one tracked pointer temp, at listed cells ---- *)
Section PW.
Variable W : block -> Z -> Prop.
Variable m0 : mem.
Variable p : ident.
Variables (b : block) (o : ptrofs).
Variable cells : list (Z * memory_chunk).
Variable Extra : mem -> Prop.
Variable keep : list (ident * val).
Hypothesis Hcells : forall d ch i, In (d, ch) cells ->
  Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) <= i
    < Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) + size_chunk ch -> W b i.
Hypothesis Hextra : forall d ch m v m', In (d, ch) cells ->
  Mem.store ch m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d))) v = Some m' -> Extra m -> Extra m'.

Definition pF (m : mem) : Prop := foot W m0 m /\ Extra m.
Definition pG (le : temp_env) : Prop :=
  le ! p = Some (Vptr b o) /\ (forall x v, In (x, v) keep -> le ! x = Some v).
Definition pset_ok (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id p) && forallb (fun kv => negb (Pos.eqb (fst kv) id)) keep.
Definition pstore_ok (a1 a2 : expr) : bool :=
  match fpath (prog_comp_env mario.prog) a1, access_mode (typeof a1) with
  | Some (p', d), By_value ch =>
      Pos.eqb p' p && existsb (fun c => Z.eqb (fst c) d && proj_sumbool (chunk_eq (snd c) ch)) cells
  | _, _ => false
  end.

Lemma pset_sound : forall id a le m v,
    pset_ok id a = true -> pG le -> pF m ->
    eval_expr (lp_ge lp) empty_env le m a v -> pG (PTree.set id v le).
Proof.
  intros id a le m v Hok (HG & HK) _ _. unfold pset_ok in Hok. apply andb_prop in Hok as [Hok Hk].
  apply negb_true_iff, Pos.eqb_neq in Hok. rewrite forallb_forall in Hk.
  split; [ rewrite PTree.gso by congruence; exact HG | ].
  intros x w I. specialize (Hk _ I). cbn [fst] in Hk. apply negb_true_iff, Pos.eqb_neq in Hk.
  rewrite PTree.gso by congruence. exact (HK x w I).
Qed.

Lemma pstore_sound : forall a1 a2 le m t le' m' out,
    pstore_ok a1 a2 = true -> pG le ->
    exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2) t le' m' out ->
    pF m -> pF m'.
Proof.
  intros a1 a2 le m t le' m' out Hok (HG & _) H (F & X).
  unfold pstore_ok in Hok.
  destruct (fpath (prog_comp_env mario.prog) a1) as [[p' d]|] eqn:HP; [ | discriminate Hok ].
  destruct (access_mode (typeof a1)) eqn:Hac; try discriminate Hok.
  apply andb_prop in Hok as [Hp Hc]. apply Pos.eqb_eq in Hp. subst p'.
  apply existsb_exists in Hc as ([d' ch'] & Hin & Hc). cbn [fst snd] in Hc.
  apply andb_prop in Hc as [Hd Hch]. apply Z.eqb_eq in Hd. subst d'.
  destruct (chunk_eq ch' m1) as [<- | ]; [ | discriminate Hch ].
  pose proof (fpath_agree _ _ _ _ LO_mario HP) as HP'. rewrite <- cenv_lp in HP'.
  destruct (fpath_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ HP' Hac HG H) as (v & v' & _ & _ & S & _).
  split; [ eapply store_foot; [ exact S | | exact F ] | exact (Hextra _ _ _ _ _ Hin S X) ].
  intros i R. exact (Hcells _ _ _ Hin R).
Qed.

Lemma pw_walk : forall le m s t le' m' out,
    exec_stmt function_entry2 (lp_ge lp) empty_env le m s t le' m' out ->
    cw_chk pset_ok pstore_ok (fun _ _ _ => false) s = true -> pG le -> pF m -> pF m' /\ pG le'.
Proof.
  intros le m s t le' m' out H C HG HF.
  exact (cw_walk (lp_ge lp) empty_env pF pG pset_ok pstore_ok (fun _ _ _ => false)
                  pset_sound pstore_sound
                  (fun _ _ _ _ _ _ _ _ _ Hno => ltac:(discriminate Hno))
                  _ _ _ _ _ _ _ _ H eq_refl C HG HF).
Qed.
End PW.

(* ---------------------------------------------------------------------- *)
(* set_mario_animation                                                    *)
(* ---------------------------------------------------------------------- *)

(* Mario's object's animInfo cells the body may write *)
Definition AIc (bo : block) (oo : ptrofs) (b : block) (z : Z) : Prop :=
  b = bo /\ (Ptrofs.unsigned oo + 56 <= z < Ptrofs.unsigned oo + 66
             \/ Ptrofs.unsigned oo + 72 <= z < Ptrofs.unsigned oo + 76).
Definition Wa (bo : block) (oo : ptrofs) (b : block) (z : Z) : Prop := Wl b z \/ AIc bo oo b z.

Lemma uadd : forall o d, 0 <= d -> Ptrofs.unsigned o + d < Ptrofs.modulus ->
  Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) = Ptrofs.unsigned o + d.
Proof.
  intros o d D B. unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr d).
  - apply Ptrofs.unsigned_repr. pose proof (Ptrofs.unsigned_range o). unfold Ptrofs.max_unsigned. lia.
  - pose proof (Ptrofs.unsigned_range o). unfold Ptrofs.max_unsigned. lia.
Qed.

Lemma path_load : forall q a p d ch le m v b o, linkorder q lp ->
  fpath (prog_comp_env q) a = Some (p, d) -> access_mode (typeof a) = By_value ch ->
  le ! p = Some (Vptr b o) -> eval_expr (lp_ge lp) empty_env le m a v ->
  Mem.loadv ch m (Vptr b (Ptrofs.add o (Ptrofs.repr d))) = Some v.
Proof.
  intros q a p d ch le m v b o LO HP Hac Hg Hev.
  eapply fpath_load; [ rewrite cenv_lp; eapply fpath_agree; eassumption | exact Hac | exact Hg | exact Hev ].
Qed.

Lemma path_store : forall q a1 a2 le m t le' m' out p d ch b o, linkorder q lp ->
  fpath (prog_comp_env q) a1 = Some (p, d) -> access_mode (typeof a1) = By_value ch ->
  le ! p = Some (Vptr b o) ->
  exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2) t le' m' out ->
  exists v v', eval_expr (lp_ge lp) empty_env le m a2 v /\ sem_cast v (typeof a2) (typeof a1) m = Some v'
    /\ Mem.store ch m b (Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d))) v' = Some m'
    /\ le' = le /\ out = Out_normal.
Proof.
  intros q a1 a2 le m t le' m' out p d ch b o LO HP Hac Hg H.
  eapply fpath_store; [ rewrite cenv_lp; eapply fpath_agree; eassumption | exact Hac | exact Hg | exact H ].
Qed.

Lemma cast_ptr_ptr : forall b o t1 a1 t2 a2 m v',
  sem_cast (Vptr b o) (Tpointer t1 a1) (Tpointer t2 a2) m = Some v' -> v' = Vptr b o.
Proof. intros. cbn in H. inv H. reflexivity. Qed.

Lemma short_cast_np : forall v a a' m b o,
  sem_cast v (Tint I16 Signed a) (Tint I16 Signed a') m = Some (Vptr b o) -> False.
Proof. intros. cbn in H. destruct v; discriminate H. Qed.

Lemma load_short_np : forall m b z v, Mem.load Mint16signed m b z = Some v -> forall bb oo, v <> Vptr bb oo.
Proof.
  intros m b z v L bb oo ->. apply Mem.load_cast in L. cbn in L. discriminate L.
Qed.

Lemma keep1 : forall (le : temp_env) x0 v0, le ! x0 = Some v0 ->
  forall x v, In (x, v) [(x0, v0)] -> le ! x = Some v.
Proof. intros le x0 v0 H x v [E | []]. injection E as <- <-. exact H. Qed.

Lemma ret_short : forall (ge : genv) e le mm x a t le' m'' out vres,
  exec_stmt function_entry2 ge e le mm (Ssequence (Sset x a) (Sreturn (Some (Etempvar x tshort))))
    t le' m'' out ->
  outcome_result_value out tshort vres m'' -> m'' = mm /\ (forall b o, vres <> Vptr b o).
Proof.
  intros ge e le mm x a t le' m'' out vres H Hr. inv H.
  - match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1 end.
    match goal with H2 : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H2 end.
    cbn [outcome_result_value typeof] in Hr. destruct Hr as [_ Hc].
    split; [ reflexivity | intros b o E; subst; exact (short_cast_np _ _ _ _ _ _ Hc) ].
  - match goal with H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1 end. congruence.
Qed.

Section SMA.
Variables (m : mem) (bM : block) (oM : ptrofs) (bo : block) (oo : ptrofs).
Hypothesis Hal : Mem.loadv Mptr m (Vptr bM (Ptrofs.add oM (Ptrofs.repr 160))) = Some (Vptr ab Ptrofs.zero).
Hypothesis Hmo : Mem.loadv Mptr m (Vptr bM (Ptrofs.add oM (Ptrofs.repr 136))) = Some (Vptr bo oo).
Hypothesis Hbuf : Mem.load Mptr m ab 8 = Some (Vptr bt ot).
Hypothesis Hbt_ab : bt <> ab.
Hypothesis Hot : Ptrofs.unsigned ot + 24 <= Ptrofs.modulus.
Hypothesis Hoo : Ptrofs.unsigned oo + 76 <= Ptrofs.modulus.

Definition sma_extra (m' : mem) : Prop :=
  Mem.load Mptr m' bo (Ptrofs.unsigned oo + 60) = Some (Vptr bt ot)
  /\ Mem.load Mint32 m' bo (Ptrofs.unsigned oo + 72) = Some (Vint Int.zero).

Ltac lk H x v Hn := match type of H with exec_stmt _ _ _ ?le _ _ _ _ _ _ =>
  assert (Hn : le ! x = Some v) by reflexivity end.

Lemma vals_cells : forall d ch i, In (d, ch) [(12, Mptr); (16, Mptr)] ->
  Ptrofs.unsigned (Ptrofs.add ot (Ptrofs.repr d)) <= i
    < Ptrofs.unsigned (Ptrofs.add ot (Ptrofs.repr d)) + size_chunk ch -> Wl bt i.
Proof.
  intros d ch i I R. pose proof (Ptrofs.unsigned_range ot).
  destruct I as [E | [E | []]]; injection E as <- <-; rewrite uadd in R by lia;
    change (size_chunk Mptr) with 4 in R; left; left; split; [ reflexivity | lia | reflexivity | lia ].
Qed.

Lemma rest_cells : forall d ch i, In (d, ch) [(58, Mint16signed); (64, Mint16signed)] ->
  Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr d)) <= i
    < Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr d)) + size_chunk ch -> Wa bo oo bo i.
Proof.
  intros d ch i I R. pose proof (Ptrofs.unsigned_range oo).
  destruct I as [E | [E | []]]; injection E as <- <-; rewrite uadd in R by lia; cbn [size_chunk] in R;
    right; split; [ reflexivity | left; lia | reflexivity | left; lia ].
Qed.

Lemma rest_extra : forall d ch m1 v m2, In (d, ch) [(58, Mint16signed); (64, Mint16signed)] ->
  Mem.store ch m1 bo (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr d))) v = Some m2 ->
  sma_extra m1 -> sma_extra m2.
Proof.
  intros d ch m1 v m2 I S (X1 & X2). pose proof (Ptrofs.unsigned_range oo).
  destruct I as [E | [E | []]]; injection E as <- <-; rewrite uadd in S by lia;
    (split; [ rewrite (Mem.load_store_other _ _ _ _ _ _ S) by (right; cbn [size_chunk]; change (size_chunk Mptr) with 4; lia); exact X1
            | rewrite (Mem.load_store_other _ _ _ _ _ _ S) by (right; cbn [size_chunk]; lia); exact X2 ]).
Qed.

Ltac pl Hv q LO p d ch Hle L :=
  match type of Hv with eval_expr _ _ _ _ ?a _ =>
    pose proof (path_load q a p d ch _ _ _ _ _ LO eq_refl eq_refl Hle Hv) as L end.

Ltac sset H := inv H;
  match goal with Hx : eval_expr _ _ _ _ _ _ |- _ => rename Hx into Hv end.

Theorem sma_foot : forall v2 t m' vres,
  eval_funcall function_entry2 (lp_ge lp) m (Internal mario.f_set_mario_animation)
    [Vptr bM oM; v2] t m' vres ->
  (forall b o, vres <> Vptr b o) /\ (foot Wl m m' \/ (foot (Wa bo oo) m m' /\ sma_extra m')).
Proof.
  intros v2 t m' vres Hev.
  inv Hev.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    change (fn_vars mario.f_set_mario_animation) with (@nil (ident * type)) in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
  match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
  match goal with Hr : outcome_result_value _ _ _ _ |- _ => rename Hr into Hres end.
  change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
  inv Hfree.
  cbn [bind_parameter_temps mario.f_set_mario_animation fn_params] in Hbind.
  injection Hbind as <-.
  assert (Hm : (PTree.set mario._targetAnimID v2 (PTree.set mario._m (Vptr bM oM)
                 (create_undef_temps (fn_temps mario.f_set_mario_animation)))) ! mario._m
               = Some (Vptr bM oM)) by (rewrite PTree.gso by discriminate; apply PTree.gss).
  (* o = m->marioObj *)
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ Hbody eq_refl) as (?tA & ?leA & ?mA & ?tB & HA & HB).
  sset HA.
  pl Hv mario.prog LO_mario mario._m 136 Mptr Hm L.
  rewrite Hmo in L. injection L as <-. clear Hv.
  (* t'13 = m->animList; targetAnim = t'13->bufTarget *)
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HB eq_refl) as (?tA & ?leA & ?mA & ?tB & HC & HD).
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HC eq_refl) as (?tA & ?leA & ?mA & ?tB & HC1 & HC2).
  lk HC1 mario._m (Vptr bM oM) Hm1.
  sset HC1. pl Hv mario.prog LO_mario mario._m 160 Mptr Hm1 L. rewrite Hal in L. injection L as <-. clear Hv.
  lk HC2 mario._t'13 (Vptr ab Ptrofs.zero) H13.
  sset HC2. pl Hv mario.prog LO_mario mario._t'13 8 Mptr H13 L.
  match type of L with Mem.loadv Mptr ?mm _ = _ =>
    change (Mem.loadv Mptr mm (Vptr ab (Ptrofs.add Ptrofs.zero (Ptrofs.repr 8)))) with (Mem.load Mptr mm ab 8) in L end.
  rewrite Hbuf in L. injection L as <-. clear Hv.
  (* the call load_patchable_table(m->animList, id) *)
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HD eq_refl) as (?tA & ?leA & ?mA & ?tB & HE & HF).
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HE eq_refl) as (?tA & ?leA & ?mA & ?tB & HG & HH).
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HG eq_refl) as (?tA & ?leA & ?mA & ?tB & HG1 & HG2).
  lk HG1 mario._m (Vptr bM oM) Hm2.
  sset HG1. pl Hv mario.prog LO_mario mario._m 160 Mptr Hm2 L. rewrite Hal in L. injection L as <-. clear Hv.
  lk HG2 mario._t'12 (Vptr ab Ptrofs.zero) H12.
  destruct (scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ HG2 (PTree.gempty _ _) eq_refl)
    as (bl & fd & tyargs & tyres & cc & vargs & vres1 & Hs & Hfd & _ & Hel & Hevl & -> & _).
  assert (Efd : fd = Internal memory.f_load_patchable_table).
  { eapply RestSurface.resolves_pin_fd;
      [ exact LO_memory | exact memory_defmap_lpt | exists bl; split; eassumption ]. }
  subst fd.
  assert (FC := lpt_foot _ Hbuf Hbt_ab _ _ _ _ _ Hevl).
  assert (HD0 : forall b o, hd_error vargs = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero).
  { intros b0 o0 Hhd. inv Hel. cbn in Hhd. injection Hhd as ->.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _, Hc : sem_cast _ _ _ _ = Some (Vptr b0 o0) |- _ =>
      apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc; subst;
      apply eval_expr_Etempvar_val in Hv; rewrite H12 in Hv; injection Hv as -> ->; auto end. }
  specialize (FC HD0 (foot_refl _ _)). clear HD0 Hel.
  (* if (t'1) { targetAnim->values = ..; targetAnim->index = ..; } *)
  lk HH mario._targetAnim (Vptr bt ot) Htg.
  lk HH mario._o (Vptr bo oo) Ho0.
  destruct (pw_walk Wl _ mario._targetAnim bt ot [(12, Mptr); (16, Mptr)] (fun _ => True)
              [(mario._o, Vptr bo oo)] vals_cells (fun _ _ _ _ _ _ _ X => X) _ _ _ _ _ _ _ HH eq_refl
              (conj Htg (keep1 _ _ _ Ho0))
              (conj FC I)) as [[FP1 _] [HtgP HkP]].
  pose proof (HkP mario._o (Vptr bo oo) (or_introl eq_refl)) as HoP.
  clear HkP.
  clear FC.
  (* t'3 = o->animInfo.animID; if (t'3 != id) { the five stores } *)
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HF eq_refl) as (?tA & ?leA & ?mA & ?tB & HI & HJ).
  destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HI eq_refl) as (?tA & ?leA & ?mA & ?tB & HI1 & HI2).
  sset HI1. clear Hv.
  inv HI2.
  match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ => rename Hx into HK; destruct b end.
  - (* the animation changed: animID, curAnim, animAccel, then animYTrans / animFrame *)
    pose proof (Ptrofs.unsigned_range oo) as Ro.
    destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HK eq_refl) as (?tA & ?leA & ?mA & ?tB & HK1 & HK2).
    assert (Ho1 : (PTree.set mario._t'3 v leA) ! mario._o = Some (Vptr bo oo))
      by (rewrite PTree.gso by discriminate; exact HoP).
    assert (Ht1 : (PTree.set mario._t'3 v leA) ! mario._targetAnim = Some (Vptr bt ot))
      by (rewrite PTree.gso by discriminate; exact HtgP).
    match type of HK1 with exec_stmt _ _ _ _ _ (Sassign ?a1 _) _ _ _ _ =>
      destruct (path_store mario.prog a1 _ _ _ _ _ _ _ mario._o 56 Mint16signed bo oo LO_mario
                  eq_refl eq_refl Ho1 HK1) as (w1 & w1' & _ & _ & S1 & -> & _) end.
    destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HK2 eq_refl) as (?tA & ?leA & ?mA & ?tB & HK3 & HK4).

    match type of HK3 with exec_stmt _ _ _ _ _ (Sassign ?a1 _) _ _ _ _ =>
      destruct (path_store mario.prog a1 _ _ _ _ _ _ _ mario._o 60 Mptr bo oo LO_mario
                  eq_refl eq_refl Ho1 HK3) as (w2 & w2' & Hw2 & Hc2 & S2 & -> & _) end.
    apply eval_expr_Etempvar_val in Hw2. rewrite Ht1 in Hw2. injection Hw2 as <-.
    apply cast_ptr_ptr in Hc2. subst w2'.
    destruct (seq_plain _ _ _ _ _ _ _ _ _ _ HK4 eq_refl) as (?tA & ?leA & ?mA & ?tB & HK5 & HK6).
    match type of HK5 with exec_stmt _ _ _ _ _ (Sassign ?a1 _) _ _ _ _ =>
      destruct (path_store mario.prog a1 _ _ _ _ _ _ _ mario._o 72 Mint32 bo oo LO_mario
                  eq_refl eq_refl Ho1 HK5) as (w3 & w3' & Hw3 & Hc3 & S3 & -> & _) end.
    inv Hw3; [ | match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end ].
    cbn in Hc3. inv Hc3.
    rewrite uadd in S1, S2, S3 by lia.
    match type of S3 with Mem.store _ _ _ _ _ = Some ?m3 => match type of FP1 with foot _ ?m0 _ =>
      assert (F3 : foot (Wa bo oo) m0 m3); [ | assert (X3 : sma_extra m3) ] end end.
    { refine (store_foot _ _ _ _ _ _ _ _ S3 _ _);
        [ intros i R; cbn [size_chunk] in R; right; split; [ reflexivity | right; lia ] | ].
      refine (store_foot _ _ _ _ _ _ _ _ S2 _ _);
        [ intros i R; change (size_chunk Mptr) with 4 in R; right; split; [ reflexivity | left; lia ] | ].
      refine (store_foot _ _ _ _ _ _ _ _ S1 _ _);
        [ intros i R; cbn [size_chunk] in R; right; split; [ reflexivity | left; lia ] | ].
      apply (foot_mono Wl); [ intros b z Hw; left; exact Hw | exact FP1 ]. }
    { split.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ S3) by (right; left; change (size_chunk Mptr) with 4; lia).
        rewrite (Mem.load_store_same _ _ _ _ _ _ S2). reflexivity.
      - rewrite (Mem.load_store_same _ _ _ _ _ _ S3). reflexivity. }
    destruct (pw_walk (Wa bo oo) _ mario._o bo oo [(58, Mint16signed); (64, Mint16signed)] sma_extra
                [] rest_cells rest_extra _ _ _ _ _ _ _ HK6 eq_refl
                (conj Ho1 (fun x w (I : In (x, w) []) => match I with end)) (conj F3 X3)) as [[FB XB] _].
    destruct (ret_short _ _ _ _ _ _ _ _ _ _ _ HJ Hres) as [-> NP].
    split; [ exact NP | right; split; [ exact FB | exact XB ] ].
  - (* unchanged *)
    inv HK.
    destruct (ret_short _ _ _ _ _ _ _ _ _ _ _ HJ Hres) as [-> NP].
    split; [ exact NP | left; exact FP1 ].
Qed.

End SMA.

End SF.
