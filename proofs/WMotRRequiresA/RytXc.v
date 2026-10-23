(* ====================================================================== *)
(* RytXc (GOAL 2): the walker's contract for the REAL                      *)
(* return_mario_anim_y_translation (mario.c:216), proved sound from its    *)
(* generated body by running the walker on it.                             *)
(*                                                                        *)
(* The y translation reads the animation frame (animFrame, an s16 cell of *)
(* Mario's object) and indexes the animation's index and value tables     *)
(* with it.  The walker cannot index with an unknown frame, so c_ryt      *)
(* enumerates the frame: the frame cell's value is a constant, or a path   *)
(* fact Fuser kF [frame; lo; hi] bounds it, and c_ryt walks the real body *)
(* once per frame value in [lo, hi].  Every outcome of every walk must    *)
(*   - leave the description as it was (the same entries, the same        *)
(*     clobbered regions, no fact lost): the call changes no cell the      *)
(*     caller can see;                                                     *)
(*   - return a constant y with -1 <= y <= 174.                            *)
(* The call is then ONE outcome: the caller's state, a fresh result and   *)
(* the fact Fuser kY [result] (the result is an int in [-1, 174]).        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Interp.SymExec2 WMotRRequiresA.WallExec WMotRRequiresA.SmaXc.
Import ListNotations.

(* the frame cell: animInfo.animFrame of Mario's object *)
Definition FRAME_OFF : Z := 64.

Definition kent (k : positive * Z * memory_chunk) (v : sval) : sentry :=
  let '(r, o, ch) := k in (r, o, ch, v).

(* replace the value of the entry at key k *)
Definition setv (k : positive * Z * memory_chunk) (v : sval) (l : smem) : smem :=
  map (fun e => if key_eq (skey e) k then kent k v else e) l.

Definition seqb (a b : sentry) : bool := key_eq (skey a) (skey b) && sbeq (snd a) (snd b).
Fixpoint smeqb (l1 l2 : smem) : bool :=
  match l1, l2 with
  | nil, nil => true
  | a :: l1', b :: l2' => seqb a b && smeqb l1' l2'
  | _, _ => false
  end.
Fixpoint poseqb (l1 l2 : list positive) : bool :=
  match l1, l2 with
  | nil, nil => true
  | a :: l1', b :: l2' => Pos.eqb a b && poseqb l1' l2'
  | _, _ => false
  end.

(* the integers lo .. hi *)
Definition zrange (lo hi : Z) : list Z :=
  map (fun n => lo + Z.of_nat n) (seq 0 (Z.to_nat (hi - lo + 1))).

(* a y in [-1, 174] *)
Definition ycon (r : sval) : bool :=
  match r with
  | Sconst (Vint y) => (-1 <=? Int.signed y) && (Int.signed y <=? 174)
  | _ => false
  end.

Section CRYT.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)).
Variables (jkI : list (positive * Z * memory_chunk)) (fuel : nat) (rO kF kY : positive).

Definition fkey : positive * Z * memory_chunk := (rO, FRAME_OFF, Mint16signed).

(* the frame values: the constant, or [lo, hi] from a path fact *)
Definition kF_bounds (sf : sval) (f : fact) : option (int * int) :=
  match f with
  | Fuser k [s; Sconst (Vint lo); Sconst (Vint hi)] =>
      if Pos.eqb k kF && sbeq s sf then Some (lo, hi) else None
  | _ => None
  end.
Fixpoint kF_find (sf : sval) (pc : list fact) : option (int * int) :=
  match pc with
  | nil => None
  | f :: pc' => match kF_bounds sf f with Some x => Some x | None => kF_find sf pc' end
  end.
Definition frange_f (pc : list fact) (sf : sval) : option (list Z) :=
  match kF_find sf pc with
  | Some (lo, hi) => Some (zrange (Int.signed lo) (Int.signed hi))
  | None => None
  end.
Definition frange (pc : list fact) (sf : sval) : option (list Z) :=
  match sf with
  | Sconst (Vint i) => Some [Int.signed i]
  | _ => frange_f pc sf
  end.

(* the state with the frame cell at f *)
Definition gset (f : Z) (g1 : gst) : gst :=
  mkg (setv fkey (Sconst (Vint (Int.repr f))) (g_sm g1)) (g_pc g1) (g_nx g1) (g_loc g1) (g_cl g1).

(* an outcome of the walk at gf: nothing the caller sees changed, a y *)
Definition ryt_out_ok (gf : gst) (c : cpath) : bool :=
  let '(gs, r) := c in
  smeqb (g_sm gs) (g_sm gf) && poseqb (g_cl gs) (g_cl gf)
  && forallb (fun f => existsb (fbeq f) (g_pc gs)) (g_pc gf)
  && ycon r.

Definition ryt_walk (args : list sval) (g1 : gst) (f : Z) : bool :=
  match sx_call ge nbase R0 gtab kv (fun _ => None) jkI (fun _ => false) true fuel (gset f g1)
          (Internal mario.f_return_mario_anim_y_translation) args with
  | Some cs => forallb (ryt_out_ok (gset f g1)) cs
  | None => false
  end.

Definition c_ryt : xcontract := fun args g =>
  match sload nbase R0 kv g rO FRAME_OFF Mint16signed with
  | Some sf =>
      match sstore nbase R0 g rO FRAME_OFF Mint16signed sf, frange (g_pc g) sf with
      | Some g1, Some fs =>
          if forallb (ryt_walk args g1) fs
          then Some [(add_fact (gfresh g1) (Fuser kY [Sfresh (g_nx g1)]), Sfresh (g_nx g1))]
          else None
      | _, _ => None
      end
  | None => None
  end.
End CRYT.

(* ---------------------------------------------------------------------- *)
(* List facts                                                             *)
(* ---------------------------------------------------------------------- *)

Lemma kent_skey : forall k v, skey (kent k v) = k.
Proof. intros [[r o] ch] v. reflexivity. Qed.

Lemma setv_skeys : forall k v l, map skey (setv k v l) = map skey l.
Proof.
  intros k v l. unfold setv. rewrite map_map. apply map_ext. intros e.
  destruct (key_eq (skey e) k) eqn:K; [| reflexivity].
  apply key_eq_true in K. rewrite K. apply kent_skey.
Qed.

Lemma setv_in : forall k v l e', In e' (setv k v l) ->
  (exists e, In e l /\ skey e = k /\ e' = kent k v) \/ (In e' l /\ key_eq (skey e') k = false).
Proof.
  intros k v l e' H. unfold setv in H. apply in_map_iff in H. destruct H as (e & <- & I).
  destruct (key_eq (skey e) k) eqn:K.
  - left. exists e. split; [exact I |]. split; [exact (key_eq_true _ _ K) | reflexivity].
  - right. split; [exact I | exact K].
Qed.

Lemma key_eq_refl : forall k, key_eq k k = true.
Proof.
  intros [[r o] ch]. cbn. rewrite Pos.eqb_refl, Z.eqb_refl. destruct (chunk_eq ch ch); [reflexivity | congruence].
Qed.

Lemma setv_setv : forall k a b l, setv k a (setv k b l) = setv k a l.
Proof.
  intros k a b l. unfold setv. rewrite map_map. apply map_ext. intros e.
  destruct (key_eq (skey e) k) eqn:K; [| rewrite K; reflexivity].
  rewrite kent_skey, key_eq_refl. reflexivity.
Qed.

Lemma setv_id : forall k v l, (forall e, In e l -> skey e = k -> e = kent k v) -> setv k v l = l.
Proof.
  intros k v l. unfold setv. induction l as [| e l IH]; intros H; [reflexivity |]. cbn [map].
  rewrite IH by (intros e' I; apply H; right; exact I).
  destruct (key_eq (skey e) k) eqn:K; [| reflexivity].
  rewrite <- (H e (or_introl eq_refl) (key_eq_true _ _ K)). reflexivity.
Qed.

Lemma smeqb_eq : forall l1 l2, smeqb l1 l2 = true -> l1 = l2.
Proof.
  induction l1 as [| a l1 IH]; intros [| b l2] H; try discriminate H; [reflexivity |].
  cbn [smeqb] in H. apply andb_true_iff in H as [H1 H2]. rewrite (IH _ H2). f_equal.
  unfold seqb in H1. apply andb_true_iff in H1 as [K S]. apply key_eq_true in K.
  unfold sbeq in S. destruct (sval_eq (snd a) (snd b)) as [E |]; [| discriminate S].
  destruct a as [[[r o] ch] v]. destruct b as [[[r' o'] ch'] v']. cbn in K, E.
  injection K as -> -> ->. subst. reflexivity.
Qed.

Lemma poseqb_eq : forall l1 l2, poseqb l1 l2 = true -> l1 = l2.
Proof.
  induction l1 as [| a l1 IH]; intros [| b l2] H; try discriminate H; [reflexivity |].
  cbn [poseqb] in H. apply andb_true_iff in H as [H1 H2]. apply Pos.eqb_eq in H1.
  rewrite (IH _ H2), H1. reflexivity.
Qed.

Lemma zrange_in : forall lo hi x, lo <= x <= hi -> In x (zrange lo hi).
Proof.
  intros lo hi x H. unfold zrange. apply in_map_iff. exists (Z.to_nat (x - lo)).
  split; [rewrite Z2Nat.id by lia; lia |]. apply in_seq. split; [lia |].
  cbn. apply Nat2Z.inj_lt. rewrite !Z2Nat.id by lia. lia.
Qed.

Lemma ycon_spec : forall r, ycon r = true ->
  exists y, r = Sconst (Vint y) /\ -1 <= Int.signed y <= 174.
Proof.
  intros r H. destruct r as [v | | | | | | | | |]; try discriminate H.
  destruct v; try discriminate H. cbn in H. apply andb_true_iff in H as [A B].
  apply Z.leb_le in A, B. exists i. split; [reflexivity | lia].
Qed.

Lemma kF_bounds_spec : forall kF sf f lo hi, kF_bounds kF sf f = Some (lo, hi) ->
  f = Fuser kF [sf; Sconst (Vint lo); Sconst (Vint hi)].
Proof.
  intros kF sf f lo hi H.
  destruct f as [| | | k a]; try (cbn in H; discriminate H).
  destruct a as [| s a]; try (cbn in H; discriminate H).
  destruct a as [| c1 a]; try (cbn in H; discriminate H).
  destruct c1 as [v1 | | | | | | | | |]; try (cbn in H; discriminate H).
  destruct v1; try (cbn in H; discriminate H).
  destruct a as [| c2 a]; try (cbn in H; discriminate H).
  destruct c2 as [v2 | | | | | | | | |]; try (cbn in H; discriminate H).
  destruct v2; try (cbn in H; discriminate H).
  destruct a; [| cbn in H; discriminate H].
  cbn [kF_bounds] in H.
  destruct (Pos.eqb_spec k kF) as [-> |]; [| discriminate H].
  unfold sbeq in H. destruct (sval_eq s sf) as [-> |]; [| discriminate H].
  cbn in H. injection H as <- <-. reflexivity.
Qed.

Lemma kF_find_spec : forall kF sf pc lo hi, kF_find kF sf pc = Some (lo, hi) ->
  In (Fuser kF [sf; Sconst (Vint lo); Sconst (Vint hi)]) pc.
Proof.
  intros kF sf pc lo hi. induction pc as [| f pc IH]; intros H; [discriminate H |].
  cbn [kF_find] in H. destruct (kF_bounds kF sf f) as [[l h] |] eqn:B.
  - injection H as -> ->. left. exact (kF_bounds_spec _ _ _ _ _ B).
  - right. exact (IH H).
Qed.

Lemma frange_spec : forall kF pc sf fs, frange kF pc sf = Some fs ->
  (exists i, sf = Sconst (Vint i) /\ fs = [Int.signed i])
  \/ (exists lo hi, In (Fuser kF [sf; Sconst (Vint lo); Sconst (Vint hi)]) pc
        /\ fs = zrange (Int.signed lo) (Int.signed hi)).
Proof.
  intros kF pc sf fs H.
  assert (FF : frange_f kF pc sf = Some fs ->
            exists lo hi, In (Fuser kF [sf; Sconst (Vint lo); Sconst (Vint hi)]) pc
              /\ fs = zrange (Int.signed lo) (Int.signed hi)).
  { intros H'. unfold frange_f in H'. destruct (kF_find kF sf pc) as [[lo hi] |] eqn:Fk; [| discriminate H'].
    injection H' as <-. exists lo, hi. split; [exact (kF_find_spec _ _ _ _ _ Fk) | reflexivity]. }
  destruct sf as [v | | | | | | | | |]; cbn [frange] in H; try (right; exact (FF H)).
  destruct v; try (right; exact (FF H)).
  left. injection H as <-. exists i. auto.
Qed.

(* ---------------------------------------------------------------------- *)
(* Soundness                                                              *)
(* ---------------------------------------------------------------------- *)

Section SND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)).
Variables (m0 : mem) (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis m0_closed : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation den := (den ge m0).

Lemma Ext_sym : forall E E' n, Ext E E' n -> Ext E' E n.
Proof. intros E E' n X k K. destruct (X k K) as (A & B & C). auto. Qed.

(* one entry's value replaced by another that describes the same cell *)
Lemma MMg_setv : forall E m g r o ch v,
  MM E m g ->
  (forall e, In e (g_sm g) -> skey e = (r, o, ch) ->
     Mem.load ch m (e_blk E r) (addr E r o) = den E v /\ sok nbase (g_nx g) v) ->
  MM E m (mkg (setv (r, o, ch) v (g_sm g)) (g_pc g) (g_nx g) (g_loc g) (g_cl g)).
Proof.
  intros E m g r o ch v MMh HV.
  pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  unfold MMg; cbn [g_sm g_pc g_nx g_loc g_cl].
  split; [exact EO | split; [exact NB |]].
  split; [| split; [| split; [exact VP | split; [exact NX | split; [exact PC | split; [exact LOC | exact LINJ]]]]]].
  - intros r1 o1 ch1 sv1 I. destruct (setv_in _ _ _ _ I) as [(e & Ie & Ke & Ee) | (Ie & _)].
    + cbn [kent] in Ee. injection Ee as -> -> -> ->.
      destruct e as [[[re oe] che] sve]. cbn [skey] in Ke. injection Ke as -> -> ->.
      destruct (ENT _ _ _ _ Ie) as (IB & _ & _). destruct (HV _ Ie eq_refl) as (L & S).
      split; [rewrite <- IB; apply inb_loc; reflexivity | split; [exact S | exact L]].
    + destruct (ENT _ _ _ _ Ie) as (IB & S & L).
      split; [rewrite <- IB; apply inb_loc; reflexivity | split; [exact S | exact L]].
  - intros b z ch1 OLD D CLD. apply FR; [exact OLD | | exact CLD].
    intros e Ie. assert (Ik : In (skey e) (map skey (setv (r, o, ch) v (g_sm g)))).
    { rewrite setv_skeys. apply in_map. exact Ie. }
    apply in_map_iff in Ik. destruct Ik as (e2 & Ee & Ie2). rewrite <- Ee. exact (D e2 Ie2).
Qed.

(* a description of a later memory, with the same entries and clobbers
   and no fewer facts, describes it under the earlier names *)
Lemma MMg_back : forall E E' m m' gf gs,
  MM E m gf -> MM E' m' gs -> Ext E E' (g_nx gf) ->
  g_sm gs = g_sm gf -> g_cl gs = g_cl gf -> g_loc gs = g_loc gf ->
  (forall f, In f (g_pc gf) -> In f (g_pc gs)) ->
  MM E m' gf.
Proof.
  intros E E' m m' gf gs MMf MMs X SM CL LC PCi.
  pose proof MMf as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  pose proof MMs as (EO' & NB' & ENT' & FR' & VP' & NX' & PC' & LOC' & LINJ').
  assert (XR : forall r, Plt r (g_nx gf) -> e_blk E' r = e_blk E r /\ e_base E' r = e_base E r)
    by (intros r Hr; destruct (X r Hr) as (A & B & _); exact (conj A B)).
  assert (KR : forall r o ch sv, In (r, o, ch, sv) (g_sm gf) -> Plt r (g_nx gf)).
  { intros r o ch sv I. destruct (ENT _ _ _ _ I) as (IB & _).
    unfold inb in IB. destruct (Pos.ltb r nbase) eqn:Lr.
    - apply Pos.ltb_lt in Lr. unfold Plt, Ple in *. lia.
    - apply andb_true_iff in IB as [IB _]. apply andb_true_iff in IB as [IB _].
      apply existsb_exists in IB. destruct IB as (r' & Ir & Er). apply Pos.eqb_eq in Er. subst r'.
      exact (proj1 (proj2 (LOC r Ir))). }
  split; [exact EO | split; [exact NB |]].
  split; [| split; [| split; [exact VP' | split; [exact NX' | split; [| split]]]]].
  - intros r o ch sv I. destruct (ENT _ _ _ _ I) as (IB & S & _).
    split; [exact IB | split; [exact S |]].
    assert (I' : In (r, o, ch, sv) (g_sm gs)) by (rewrite SM; exact I).
    destruct (ENT' _ _ _ _ I') as (_ & _ & L).
    destruct (XR r (KR _ _ _ _ I)) as (B1 & B2). unfold addr in L |- *. rewrite B1, B2 in L.
    rewrite L. apply (den_ext ge m0 E E' (g_nx gf)); [exact (proj1 S) | exact X].
  - intros b z ch OLD D CLD. apply FR'; [exact OLD | |].
    + intros e Ie. rewrite SM in Ie. pose proof (D e Ie) as De.
      destruct e as [[[r o] ch1] sv]. cbn [skey cell_disj] in De |- *.
      destruct (XR r (KR _ _ _ _ Ie)) as (B1 & B2). unfold addr in De |- *. rewrite B1, B2. exact De.
    + intros rc Ic. rewrite CL in Ic.
      apply (proj2 (rng_disj_Ext ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E E'
                      (g_nx gf) rc b z ch EO NB X)).
      exact (CLD rc Ic).
  - intros f I. destruct (PC f I) as (N & _). split; [exact N |].
    destruct (PC' f (PCi f I)) as (_ & H).
    exact (fact_holds_ext ge nbase R0 gtab kv m0 uf gp E' E (g_nx gf) f EO' (Ext_sym _ _ _ X) NB N H).
  - intros r I. destruct (LOC r I) as (A & B & C & D & _).
    split; [exact A | split; [exact B | split; [exact C | split; [exact D |]]]].
    rewrite LC in LOC'. destruct (LOC' r I) as (_ & _ & _ & _ & F).
    destruct (XR r B) as (B1 & _). rewrite <- B1. exact F.
  - exact LINJ.
Qed.

Lemma sstore_sm : forall g r o ch v g1, sstore nbase R0 g r o ch v = Some g1 ->
  g_sm g1 = (r, o, ch, v) :: filter (fun e => negb (ovl r o ch e)) (g_sm g)
  /\ g_pc g1 = g_pc g /\ g_nx g1 = g_nx g /\ g_loc g1 = g_loc g /\ g_cl g1 = g_cl g.
Proof.
  intros g r o ch v g1 S. unfold sstore in S.
  destruct (inb nbase R0 g r o ch); [| discriminate S].
  destruct (forallb _ (g_sm g)); [| discriminate S]. injection S as <-. cbn. auto.
Qed.

Variables (jkI : list (positive * Z * memory_chunk)) (fuel : nat) (rO kF kY : positive).
Hypothesis HF : forall v lo hi, uf kF [v; Some (Vint lo); Some (Vint hi)] ->
  exists i, v = Some (Vint i) /\ Int.signed lo <= Int.signed i <= Int.signed hi.
Hypothesis HY : forall y, -1 <= Int.signed y <= 174 -> uf kY [Some (Vint y)].

Theorem c_ryt_sound : forall args g cps E m vargs t m' vres,
  c_ryt ge nbase R0 gtab kv jkI fuel rO kF kY args g = Some cps -> MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal mario.f_return_mario_anim_y_translation) vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres H MMh HA EV. unfold c_ryt in H.
  destruct (sload nbase R0 kv g rO FRAME_OFF Mint16signed) as [sf |] eqn:LS; [| discriminate H].
  destruct (sstore nbase R0 g rO FRAME_OFF Mint16signed sf) as [g1 |] eqn:SS; [| discriminate H].
  destruct (frange kF (g_pc g) sf) as [fs |] eqn:FRg; [| discriminate H].
  destruct (forallb (ryt_walk ge nbase R0 gtab kv jkI fuel rO args g1) fs) eqn:FA; [| discriminate H].
  injection H as <-.
  destruct (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
              E m g rO FRAME_OFF Mint16signed sf MMh LS) as (Lf & Sf).
  destruct (sstore_sm _ _ _ _ _ _ SS) as (SM1 & PC1 & NX1 & LC1 & CL1).
  (* the description with the frame cell written down *)
  assert (MM1 : MM E m g1).
  { assert (SS' : sstores nbase R0 g [(rO, FRAME_OFF, Mint16signed, sf)] = Some g1)
      by (cbn [sstores]; rewrite SS; reflexivity).
    refine (proj1 (sstores_havoc_cl ge nbase R0 gtab kv m0 uf gp gp_old [] E m g _ g1 m MMh
                    (fun rc I => match I with end) (fun e _ I => match I with end) SS' _ _ (Ple_refl _) _)).
    - intros r o ch sv [Ie | []]. injection Ie as <- <- <- <-. split; [exact Sf | exact Lf].
    - intros b z ch _ _ _. reflexivity.
    - intros b o k p _. tauto. }
  (* its entries at the frame key: only sf *)
  assert (K1 : forall e, In e (g_sm g1) -> skey e = (rO, FRAME_OFF, Mint16signed) ->
                 e = kent (rO, FRAME_OFF, Mint16signed) sf).
  { intros e Ie Ke. rewrite SM1 in Ie. destruct Ie as [<- | Ie]; [reflexivity |].
    apply filter_In in Ie. destruct Ie as (_ & N).
    destruct e as [[[r o] ch] v]. cbn [skey] in Ke. injection Ke as -> -> ->.
    cbn [ovl] in N. rewrite Pos.eqb_refl in N. cbn in N. discriminate N. }
  (* the frame's value *)
  assert (FV : exists i, den E sf = Some (Vint i) /\ In (Int.signed i) fs).
  { destruct (frange_spec _ _ _ _ FRg) as [(i & -> & ->) | (lo & hi & If & ->)].
    - exists i. split; [reflexivity | left; reflexivity].
    - pose proof MMh as (_ & _ & _ & _ & _ & _ & PC & _).
      destruct (PC _ If) as (_ & Hh). cbn [fact_holds map SymExec2.den] in Hh.
      destruct (HF _ _ _ Hh) as (i & Di & Ri). exists i. split; [exact Di |].
      apply zrange_in. exact Ri. }
  destruct FV as (i & Di & Ii).
  pose proof (proj1 (forallb_forall _ _) FA _ Ii) as W. unfold ryt_walk in W.
  set (gf := gset rO (Int.signed i) g1) in W.
  (* the walk's start: the frame at its value *)
  assert (MMf : MM E m gf).
  { unfold gf, gset. apply MMg_setv; [exact MM1 |].
    intros e Ie Ke. rewrite Lf, Di. cbn [SymExec2.den]. rewrite Int.repr_signed.
    split; [reflexivity | split; [exact I | reflexivity]]. }
  assert (HAf : Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx gf) a) args vargs).
  { unfold gf, gset; cbn [g_nx]. rewrite NX1. exact HA. }
  destruct (sx_call ge nbase R0 gtab kv (fun _ => None) jkI (fun _ => false) true fuel gf
              (Internal mario.f_return_mario_anim_y_translation) args) as [cs |] eqn:RUN; [| discriminate W].
  destruct (sx_call_sound ge nbase R0 gtab kv (fun _ => None) jkI (fun _ => false) true m0 uf gp gp_old m0_closed
              (fun id k args0 g0 cps0 fd E0 m1 vargs0 t0 m2 vres0 Hx => ltac:(discriminate Hx))
              fuel gf _ args cs E m vargs t m' vres RUN MMf HAf EV) as ([gs r] & Ic & CMc).
  pose proof (proj1 (forallb_forall _ _) W _ Ic) as OK. cbn [ryt_out_ok] in OK.
  apply andb_true_iff in OK as [OK Yc]. apply andb_true_iff in OK as [OK Pc].
  apply andb_true_iff in OK as [Sm Cl].
  apply smeqb_eq in Sm. apply poseqb_eq in Cl.
  destruct (ycon_spec r Yc) as (y & -> & Ry).
  destruct CMc as (E' & X & MMs & Dr & _ & _ & LCs).
  cbn [SymExec2.den] in Dr. injection Dr as <-.
  (* the memory after, under the caller's names *)
  assert (MMf' : MM E m' gf).
  { apply (MMg_back E E' m m' gf gs MMf MMs X Sm Cl LCs).
    intros f If. pose proof (proj1 (forallb_forall _ _) Pc f If) as Ef.
    apply existsb_exists in Ef. destruct Ef as (f' & If' & Eq).
    unfold fbeq in Eq. destruct (fact_eq f f') as [<- |]; [exact If' | discriminate Eq]. }
  assert (MM1' : MM E m' g1).
  { assert (G1 : g1 = mkg (setv (rO, FRAME_OFF, Mint16signed) sf (g_sm gf)) (g_pc gf) (g_nx gf)
                         (g_loc gf) (g_cl gf)).
    { unfold gf, gset; cbn [g_sm g_pc g_nx g_loc g_cl]. unfold fkey. rewrite setv_setv.
      rewrite (setv_id _ _ _ K1). destruct g1; reflexivity. }
    rewrite G1. apply MMg_setv; [exact MMf' |].
    intros e Ie Ke.
    pose proof MMf' as (_ & _ & ENT & _).
    destruct e as [[[re oe] che] sve]. cbn [skey] in Ke. injection Ke as -> -> ->.
    destruct (ENT _ _ _ _ Ie) as (_ & _ & Le).
    unfold gf, gset in Ie; cbn [g_sm] in Ie.
    destruct (setv_in _ _ _ _ Ie) as [(e0 & _ & _ & Ee) | (_ & Kn)].
    + cbn [kent] in Ee. injection Ee as ->. rewrite Le. cbn [SymExec2.den].
      rewrite Di, Int.repr_signed. split; [reflexivity |].
      unfold gf, gset; cbn [g_nx]. rewrite NX1. exact Sf.
    + exfalso. cbn [skey] in Kn. unfold fkey in Kn. rewrite key_eq_refl in Kn. discriminate Kn. }
  (* the outcome *)
  eexists. split; [left; reflexivity |].
  destruct (fresh_cm ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m' g1 (Vint y)
              MM1' I) as (E2 & X2 & MM2 & D2 & S2 & L2 & G2).
  exists E2. rewrite <- NX1, <- LC1.
  split; [exact X2 |].
  split.
  - apply MMg_add_fact; [exact MM2 | |].
    + cbn [fact_nlt gfresh g_nx]. constructor; [cbn [nlt]; apply Plt_succ | constructor].
    + cbn [fact_holds map]. rewrite D2. apply HY. exact Ry.
  - split; [exact D2 |]. split; [exact S2 |]. split; [exact L2 | exact G2].
Qed.
End SND.
