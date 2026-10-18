(* ====================================================================== *)
(* ClosedMem: "memory points only into itself", as a FLAT partial self-     *)
(* injection.  closed_by g m says g maps each block to itself or nowhere   *)
(* and Mem.inject g m m: the g-mapped blocks are pointer-closed (every      *)
(* pointer stored in a mapped block targets a mapped block).  Blocks g     *)
(* leaves unmapped are PRIVATE: nothing mapped points at them.             *)
(*                                                                          *)
(* THE POINT: CompCert's external-call axioms say nothing directly about   *)
(* which blocks an external function writes.  But ec_mem_inject + ec_determ *)
(* do: from closed_by g m, an external call whose arguments are g-values   *)
(* leaves every g-unmapped block unchanged and ends closed again           *)
(* (ext_call_closed).  This is what lets a body that calls an external    *)
(* (vec3f_normalize -> sqrtf) keep its private stack shadow -- PROVED from *)
(* CompCert's own axioms, not trusted.                                     *)
(* ====================================================================== *)

From Coq Require Import ZArith Classical_Prop.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events Globalenvs.

Definition flat_part (g : meminj) : Prop :=
  forall b b' d, g b = Some (b', d) -> b' = b /\ d = 0.

Definition closed_by (g : meminj) (m : mem) : Prop :=
  flat_part g /\ Mem.inject g m m.

(* the flat shadow of any injection: same domain, identity image *)
Definition flatten (f : meminj) : meminj :=
  fun b => match f b with Some _ => Some (b, 0) | None => None end.

Lemma flatten_flat : forall f, flat_part (flatten f).
Proof.
  intros f b b' d H. unfold flatten in H.
  destruct (f b) as [[]|]; [injection H as <- <-; auto | discriminate].
Qed.

Lemma flatten_val : forall f v v',
    Val.inject f v v' -> Val.inject (flatten f) v v.
Proof.
  intros f v v' H. inv H; try constructor.
  econstructor; [unfold flatten; rewrite H0; reflexivity |].
  rewrite Ptrofs.add_zero. reflexivity.
Qed.

Lemma flatten_memval : forall f mv mv',
    memval_inject f mv mv' -> memval_inject (flatten f) mv mv.
Proof.
  intros f mv mv' H. inv H; constructor.
  exact (flatten_val _ _ _ H0).
Qed.

(* a SELF-injection flattens: the domain of any f with Mem.inject f m m is
   pointer-closed, so the identity on that domain is a self-injection too *)
Lemma flatten_inject : forall f m, Mem.inject f m m -> Mem.inject (flatten f) m m.
Proof.
  intros f m Hi.
  assert (Hdom : forall b b' d, flatten f b = Some (b', d) ->
                   b' = b /\ d = 0 /\ exists bd, f b = Some bd).
  { intros b b' d H. unfold flatten in H.
    destruct (f b) as [bd|] eqn:E; [injection H as <- <-; eauto | discriminate]. }
  constructor.
  - constructor.
    + intros b1 b2 d ofs k p H Hp.
      destruct (Hdom _ _ _ H) as (-> & -> & _). rewrite Z.add_0_r. exact Hp.
    + intros b1 b2 d ch ofs p H _.
      destruct (Hdom _ _ _ H) as (_ & -> & _). apply Z.divide_0_r.
    + intros b1 ofs b2 d H Hp.
      destruct (Hdom _ _ _ H) as (-> & -> & [[b' d'] Ef]).
      rewrite Z.add_0_r.
      exact (flatten_memval _ _ _ (Mem.mi_memval _ _ _ (Mem.mi_inj _ _ _ Hi) _ _ _ _ Ef Hp)).
  - intros b Hnv. unfold flatten. rewrite (Mem.mi_freeblocks _ _ _ Hi b Hnv). reflexivity.
  - intros b b' d H.
    destruct (Hdom _ _ _ H) as (-> & -> & [[b2 d2] Ef]).
    destruct (Classical_Prop.classic (Mem.valid_block m b)) as [Hv | Hnv]; [exact Hv |].
    rewrite (Mem.mi_freeblocks _ _ _ Hi b Hnv) in Ef. discriminate.
  - intros b1 b1' d1 b2 b2' d2 ofs1 ofs2 Hne H1 H2 _ _.
    destruct (Hdom _ _ _ H1) as (-> & -> & _).
    destruct (Hdom _ _ _ H2) as (-> & -> & _). left. exact Hne.
  - intros b b' d ofs H _.
    destruct (Hdom _ _ _ H) as (_ & -> & _).
    pose proof (Ptrofs.unsigned_range_2 ofs). lia.
  - intros b1 ofs b2 d k p H Hp.
    destruct (Hdom _ _ _ H) as (-> & -> & _). left. rewrite Z.add_0_r in Hp. exact Hp.
Qed.

Lemma flatten_incr : forall g f,
    flat_part g -> inject_incr g f -> inject_incr g (flatten f).
Proof.
  intros g f Hg Hinc b b' d H.
  destruct (Hg _ _ _ H) as (-> & ->).
  unfold flatten. rewrite (Hinc _ _ _ H). reflexivity.
Qed.

(* THE EXTERNAL-CALL LEMMA *)
Theorem ext_call_closed :
  forall ef (ge : Senv.t) vargs m t vres m' g,
    closed_by g m -> symbols_inject g ge ge -> Val.inject_list g vargs vargs ->
    external_call ef ge vargs m t vres m' ->
    exists g', closed_by g' m' /\ inject_incr g g' /\ Val.inject g' vres vres
               /\ Mem.unchanged_on (loc_unmapped g) m m'.
Proof.
  intros ef ge vargs m t vres m' g (Hflat & Hi) Hsym Hargs Hx.
  destruct (@external_call_mem_inject_gen ef ge ge vargs m t vres m' g m vargs
              Hsym Hx Hi Hargs)
    as (f' & vres' & m2' & Hx' & Hvi & Hi' & Hun & _ & Hinc & _).
  destruct (@external_call_determ ef ge vargs m t vres m' t vres' m2' Hx Hx')
    as (_ & Heq).
  destruct (Heq eq_refl) as (<- & <-).
  exists (flatten f'). split; [split; [apply flatten_flat | exact (flatten_inject _ _ Hi')] |].
  split; [exact (flatten_incr _ _ Hflat Hinc) |].
  split; [exact (flatten_val _ _ _ Hvi) | exact Hun].
Qed.

(* ---- the internal memory operations ---- *)

Lemma closed_valid_mapped : forall g m b b' d,
    closed_by g m -> g b = Some (b', d) -> Mem.valid_block m b.
Proof.
  intros g m b b' d (_ & Hi) H.
  destruct (Classical_Prop.classic (Mem.valid_block m b)) as [Hv | Hnv]; [exact Hv |].
  rewrite (Mem.mi_freeblocks _ _ _ Hi b Hnv) in H. discriminate.
Qed.

(* a fresh block left PRIVATE (unmapped) *)
Lemma alloc_private : forall g m lo hi m' b,
    closed_by g m -> Mem.alloc m lo hi = (m', b) ->
    closed_by g m' /\ g b = None.
Proof.
  intros g m lo hi m' b (Hflat & Hi) Ha.
  assert (Hgb : g b = None)
    by (apply (Mem.mi_freeblocks _ _ _ Hi); exact (Mem.fresh_block_alloc _ _ _ _ _ Ha)).
  destruct (Mem.alloc_left_unmapped_inject _ _ _ _ _ _ _ Hi Ha)
    as (f' & Hi1 & Hinc & Hf'b & Hf'o).
  assert (Hfeq : forall x, f' x = g x).
  { intros x. destruct (peq x b) as [-> | Hne]; [rewrite Hf'b, Hgb; reflexivity | exact (Hf'o x Hne)]. }
  pose proof (Mem.alloc_right_inject _ _ _ _ _ _ _ Hi1 Ha) as Hi2.
  split; [split; [exact Hflat |] | exact Hgb].
  replace g with f' by (apply Axioms.extensionality; exact Hfeq).
  exact Hi2.
Qed.

(* a fresh block made PUBLIC (mapped to itself) *)
Lemma alloc_public : forall g m lo hi m' b,
    closed_by g m -> Mem.alloc m lo hi = (m', b) ->
    closed_by (fun x => if peq x b then Some (b, 0) else g x) m'.
Proof.
  intros g m lo hi m' b (Hflat & Hi) Ha.
  destruct (Mem.alloc_parallel_inject _ _ _ _ _ _ _ _ _ Hi Ha (Z.le_refl lo) (Z.le_refl hi))
    as (f' & m2' & b2 & Ha2 & Hi' & Hinc & Hf'b & Hf'o).
  rewrite Ha in Ha2. injection Ha2 as <- <-.
  assert (Hfeq : forall x, f' x = (if peq x b then Some (b, 0) else g x)).
  { intros x. destruct (peq x b) as [-> | Hne]; [exact Hf'b | exact (Hf'o x Hne)]. }
  split.
  - intros x x' d H. destruct (peq x b) as [-> | Hne];
      [injection H as <- <-; auto | exact (Hflat _ _ _ H)].
  - assert (E : f' = (fun x => if peq x b then Some (b, 0) else g x))
      by (apply Axioms.extensionality; exact Hfeq).
    rewrite <- E. exact Hi'.
Qed.

(* a store into a MAPPED block of a closed value *)
Lemma store_mapped_closed : forall g m ch b ofs v m',
    closed_by g m -> g b = Some (b, 0) -> Val.inject g v v ->
    Mem.store ch m b ofs v = Some m' -> closed_by g m'.
Proof.
  intros g m ch b ofs v m' (Hflat & Hi) Hgb Hv Hs.
  edestruct Mem.store_mapped_inject as (n2 & Hs2 & Hi2);
    [exact Hi | exact Hs | exact Hgb | exact Hv |].
  rewrite Z.add_0_r, Hs in Hs2. injection Hs2 as <-.
  split; [exact Hflat | exact Hi2].
Qed.

(* a store into a PRIVATE block: any value *)
Lemma store_private_closed : forall g m ch b ofs v m',
    closed_by g m -> g b = None ->
    Mem.store ch m b ofs v = Some m' -> closed_by g m'.
Proof.
  intros g m ch b ofs v m' (Hflat & Hi) Hgb Hs.
  assert (Hi1 : Mem.inject g m' m) by (eapply Mem.store_unmapped_inject; eassumption).
  split; [exact Hflat |].
  eapply Mem.store_outside_inject; [exact Hi1 | | exact Hs].
  intros b' d ofs' H _ _.
  destruct (Hflat _ _ _ H) as (-> & ->). congruence.
Qed.
