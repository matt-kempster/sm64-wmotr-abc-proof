(* ====================================================================== *)
(* WallExec (unwired, GOAL 2): the GOAL-2 executor's contract for the      *)
(* real find_wall_collisions, PROVED SOUND against its generated Clight    *)
(* body (through WallFind.fwc_contract).                                   *)
(*                                                                          *)
(* First, a general tool: sstores_havoc.  A contract that cannot replay    *)
(* the callee's stores on the caller's memory (it does not know the cells  *)
(* are writable, e.g. cells the callee may leave untouched) can still      *)
(* describe the result memory, given only what each written cell now holds *)
(* and that every other cell is unchanged.                                 *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs Require Import Interp.SymExec2 WMotRRequiresA.Unwired.FloorList
  WMotRRequiresA.Unwired.FloorExec WMotRRequiresA.Unwired.WallList WMotRRequiresA.Unwired.WallFind.
Import ListNotations.

(* a run of executor stores *)
Fixpoint sstores (nbase : positive) (R0 : list (positive * Z)) (g : gst) (l : list sentry)
    : option gst :=
  match l with
  | nil => Some g
  | (r, o, ch, sv) :: l' =>
      match sstore nbase R0 g r o ch sv with
      | Some g1 => sstores nbase R0 g1 l'
      | None => None
      end
  end.

Section HV.
Variable nbase : positive.
Variable R0 : list (positive * Z).

Lemma sstore_meta : forall g r o ch sv g',
  sstore nbase R0 g r o ch sv = Some g' ->
  g_nx g' = g_nx g /\ g_loc g' = g_loc g /\ g_pc g' = g_pc g.
Proof.
  intros g r o ch sv g' S. unfold sstore in S.
  destruct (inb nbase R0 g r o ch); [| discriminate].
  destruct (forallb _ (g_sm g)); [| discriminate]. inv S. auto.
Qed.

Lemma sstores_meta : forall l g g', sstores nbase R0 g l = Some g' ->
  g_nx g' = g_nx g /\ g_loc g' = g_loc g /\ g_pc g' = g_pc g.
Proof.
  induction l as [| [[[r o] ch] sv] l IH]; intros g g' S; cbn [sstores] in S.
  - injection S as <-. auto.
  - destruct (sstore nbase R0 g r o ch sv) as [g1 |] eqn:S1; [| discriminate].
    destruct (sstore_meta _ _ _ _ _ _ S1) as (A & B & C).
    destruct (IH _ _ S) as (A' & B' & C'). rewrite A', B', C'. auto.
Qed.

(* every written cell's key is in the result *)
Lemma sstore_drop : forall g r o ch sv g' e, sstore nbase R0 g r o ch sv = Some g' ->
  In e (g_sm g) -> In e (g_sm g') \/ skey e = (r, o, ch).
Proof.
  intros g r o ch sv g' e S I. unfold sstore in S.
  destruct (inb nbase R0 g r o ch); [| discriminate].
  destruct (forallb _ (g_sm g)) eqn:ALL; [| discriminate]. inv S.
  rewrite forallb_forall in ALL.
  destruct (ovl r o ch e) eqn:OV.
  - right. pose proof (ALL e I) as X. rewrite OV in X. cbn [negb orb] in X.
    destruct e as [[[r' o'] ch'] sv']. apply exact_true in X. destruct X as (-> & -> & ->).
    reflexivity.
  - left. cbn [g_sm]. right. apply filter_In. split; [exact I | rewrite OV; reflexivity].
Qed.

Lemma sstores_drop : forall l g g' e, sstores nbase R0 g l = Some g' ->
  In e (g_sm g) -> In e (g_sm g') \/ exists k, In k l /\ skey k = skey e.
Proof.
  induction l as [| [[[r o] ch] sv] l IH]; intros g g' e S I; cbn [sstores] in S.
  - injection S as <-. auto.
  - destruct (sstore nbase R0 g r o ch sv) as [g1 |] eqn:S1; [| discriminate].
    destruct (sstore_drop _ _ _ _ _ _ _ S1 I) as [I1 | K].
    + destruct (IH _ _ _ S I1) as [? | (k & Ik & Ek)]; [auto | right; exists k; split; [right; exact Ik | exact Ek]].
    + right. exists (r, o, ch, sv). split; [left; reflexivity | rewrite K; reflexivity].
Qed.

Lemma sstores_key : forall l g g' k, sstores nbase R0 g l = Some g' -> In k l ->
  exists e, In e (g_sm g') /\ skey e = skey k.
Proof.
  induction l as [| [[[r o] ch] sv] l IH]; intros g g' k S Ik; cbn [sstores] in S; [destruct Ik |].
  destruct (sstore nbase R0 g r o ch sv) as [g1 |] eqn:S1; [| discriminate].
  destruct Ik as [<- | Ik]; [| exact (IH _ _ _ S Ik)].
  assert (H1 : In (r, o, ch, sv) (g_sm g1)).
  { unfold sstore in S1. destruct (inb nbase R0 g r o ch); [| discriminate].
    destruct (forallb _ (g_sm g)); [| discriminate]. inv S1. left; reflexivity. }
  destruct (sstores_drop _ _ _ _ S H1) as [I' | (k & Ik & Ek)].
  - exists (r, o, ch, sv). auto.
  - destruct (IH _ _ _ S Ik) as (e & Ie & Ee). exists e. split; [exact Ie | congruence].
Qed.

Lemma sstores_in : forall l g g' e, sstores nbase R0 g l = Some g' -> In e (g_sm g') ->
  In e l \/ (In e (g_sm g) /\ forall k, In k l -> let '(r, o, ch) := skey k in ovl r o ch e = false).
Proof.
  induction l as [| [[[r o] ch] sv] l IH]; intros g g' e S I; cbn [sstores] in S.
  - injection S as <-. right. split; [exact I | intros k []].
  - destruct (sstore nbase R0 g r o ch sv) as [g1 |] eqn:S1; [| discriminate].
    destruct (IH _ _ _ S I) as [Il | (I1 & N1)]; [left; right; exact Il |].
    destruct (sstore_in _ _ _ _ _ _ _ _ _ S1 I1) as [-> | (I0 & N0)]; [left; left; reflexivity |].
    right. split; [exact I0 |]. intros k [<- | Ik]; [exact N0 | exact (N1 k Ik)].
Qed.

Lemma sstores_inb : forall l g g' k, sstores nbase R0 g l = Some g' -> In k l ->
  let '(r, o, ch) := skey k in inb nbase R0 g r o ch = true.
Proof.
  induction l as [| [[[r o] ch] sv] l IH]; intros g g' k S Ik; cbn [sstores] in S; [destruct Ik |].
  destruct (sstore nbase R0 g r o ch sv) as [g1 |] eqn:S1; [| discriminate].
  destruct Ik as [<- | Ik]; [exact (sstore_inb _ _ _ _ _ _ _ _ S1) |].
  pose proof (IH _ _ _ S Ik) as X. destruct k as [[[r' o'] ch'] sv']. cbn [skey] in X |- *.
  rewrite <- X. apply inb_loc. symmetry. exact (proj1 (proj2 (sstore_meta _ _ _ _ _ _ S1))).
Qed.

Variable ge : genv.
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf).
Local Notation nb0 := (Mem.nextblock m0).
Local Notation den := (den ge m0).

Lemma inb_valid : forall E m g r o ch, MM E m g -> inb nbase R0 g r o ch = true ->
  Mem.valid_block m (e_blk E r).
Proof.
  intros E m g r o ch MMh IB.
  pose proof MMh as ((A1 & _) & _ & _ & _ & _ & NX & _ & LOC & _).
  destruct (inb_spec _ _ _ _ _ _ IB) as [(Lr & _) | (_ & Il & _)].
  - eapply Plt_Ple_trans; [exact (A1 r Lr) | exact NX].
  - destruct (LOC r Il) as (_ & _ & _ & _ & P). exact P.
Qed.

(* THE HAVOC LEMMA *)
Theorem sstores_havoc : forall E m g l g' m',
  MM E m g -> sstores nbase R0 g l = Some g' ->
  (forall r o ch sv, In (r, o, ch, sv) l ->
     sok nbase (g_nx g) sv /\ Mem.load ch m' (e_blk E r) (addr E r o) = den E sv) ->
  (forall b z ch, Mem.valid_block m b ->
     (forall k, In k l -> cell_disj E (skey k) b z ch) -> Mem.load ch m' b z = Mem.load ch m b z) ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b o k p, Plt b nb0 -> (Mem.perm m' b o k p <-> Mem.perm m b o k p)) ->
  MM E m' g' /\ g_nx g' = g_nx g /\ g_loc g' = g_loc g /\ g_pc g' = g_pc g.
Proof.
  intros E m g l g' m' MMh S HL HD NXm P.
  destruct (sstores_meta _ _ _ S) as (NXg & LCg & PCg).
  split; [| auto].
  pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  (* a key of l, as a cell, is disjoint from any entry of g that does not overlap it *)
  assert (KD : forall k r o ch, In k l -> inb nbase R0 g r o ch = true ->
            (let '(r1, o1, ch1) := skey k in
             r1 <> r \/ o1 + size_chunk ch1 <= o \/ o + size_chunk ch <= o1) ->
            cell_disj E (skey k) (e_blk E r) (addr E r o) ch).
  { intros [[[r1 o1] ch1] sv1] r o ch Ik IB D.
    pose proof (sstores_inb _ _ _ _ S Ik) as IB1. cbn [skey] in IB1, D |- *.
    exact (inb_disj _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ MMh IB1 IB D). }
  split; [exact EO | split; [rewrite NXg; exact NB |]].
  split; [| split; [| split; [| split; [| split; [| split; [| let I1 := fresh in let I2 := fresh in intros ? ? I1 I2; rewrite LCg in I1, I2; exact (LINJ _ _ I1 I2)]]]]]].
  - (* entries *)
    intros r o ch sv I. rewrite (inb_loc _ _ g g' r o ch LCg), NXg.
    destruct (sstores_in _ _ _ _ S I) as [Il | (I0 & N0)].
    + pose proof (sstores_inb _ _ _ _ S Il) as IB. cbn [skey] in IB.
      destruct (HL _ _ _ _ Il) as (SK & L). auto.
    + destruct (ENT _ _ _ _ I0) as (IB & SK & L). split; [exact IB | split; [exact SK |]].
      rewrite <- L. apply HD; [exact (inb_valid _ _ _ _ _ _ MMh IB) |].
      intros k Ik. apply (KD k r o ch Ik IB).
      pose proof (N0 k Ik) as N. destruct k as [[[r1 o1] ch1] sv1]. cbn [skey] in N |- *.
      apply ovl_false in N. destruct N as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
  - (* frame *)
    intros b z ch OLD D.
    assert (Vb : Mem.valid_block m b) by (eapply Plt_Ple_trans; [exact OLD | exact NX]).
    rewrite (HD b z ch Vb).
    + apply FR; [exact OLD |]. intros e Ie.
      destruct (sstores_drop _ _ _ _ S Ie) as [Ie' | (k & Ik & Ek)]; [exact (D e Ie') |].
      destruct (sstores_key _ _ _ _ S Ik) as (e' & Ie' & Ee'). rewrite <- Ek, <- Ee'. exact (D e' Ie').
    + intros k Ik. destruct (sstores_key _ _ _ _ S Ik) as (e' & Ie' & Ee'). rewrite <- Ee'. exact (D e' Ie').
  - intros b o k p OLD. rewrite (P b o k p OLD). exact (VP b o k p OLD).
  - eapply Ple_trans; [exact NX | exact NXm].
  - rewrite PCg, NXg. exact PC.
  - intros r I. rewrite LCg in I. destruct (LOC r I) as (A & B & C & D & F).
    rewrite NXg. split; [exact A | split; [exact B | split; [exact C | split; [exact D |]]]].
    eapply Plt_Ple_trans; [exact F | exact NXm].
Qed.

End HV.

Lemma uo_or : forall (P Q : block -> Z -> Prop) m1 m2,
  Mem.unchanged_on P m1 m2 -> Mem.unchanged_on Q m1 m2 ->
  Mem.unchanged_on (fun b i => P b i \/ Q b i) m1 m2.
Proof.
  intros P Q m1 m2 UP UQ. constructor.
  - exact (Mem.unchanged_on_nextblock _ _ _ UP).
  - intros b i k p [H | H] Hv; [exact (Mem.unchanged_on_perm _ _ _ UP b i k p H Hv)
                               | exact (Mem.unchanged_on_perm _ _ _ UQ b i k p H Hv)].
  - intros b i [H | H] Hp; [exact (Mem.unchanged_on_contents _ _ _ UP b i H Hp)
                           | exact (Mem.unchanged_on_contents _ _ _ UQ b i H Hp)].
Qed.

Definition addfs (g : gst) (fs : list fact) : gst := fold_left add_fact fs g.

Lemma addfs_meta : forall fs g, g_nx (addfs g fs) = g_nx g /\ g_loc (addfs g fs) = g_loc g.
Proof.
  unfold addfs. induction fs as [| f fs IH]; intros g; [auto |].
  cbn [fold_left]. destruct (IH (add_fact g f)) as (A & B). rewrite A, B. split; reflexivity.
Qed.

Lemma MMg_addfs : forall ge nbase R0 gtab kv m0 uf E m fs g,
  MMg ge nbase R0 gtab kv m0 uf E m g ->
  (forall f, In f fs -> fact_nlt (g_nx g) f /\ fact_holds ge R0 m0 uf E f) ->
  MMg ge nbase R0 gtab kv m0 uf E m (addfs g fs).
Proof.
  intros ge nbase R0 gtab kv m0 uf E m fs. induction fs as [| f fs IH]; intros g M F; [exact M |].
  cbn [addfs fold_left]. apply IH.
  - destruct (F f (or_introl eq_refl)) as (N & H). eapply MMg_add_fact; eassumption.
  - intros f' I. exact (F f' (or_intror I)).
Qed.

Lemma ldf_old : forall (m0 : mem) M b z v, Mem.load Mfloat32 M b z = Some v -> val_old m0 v.
Proof.
  intros m0 M b z v H. apply Mem.load_type in H. destruct v; cbn in *; auto. destruct H.
Qed.

(* ---- THE CONTRACT ---- *)
(* names: nm n0 0 = x, 1 = z, 2 = gNumCalls.wall, 3..6 = the wall slots, 7 = the count *)
Fixpoint nm (n0 : positive) (j : nat) : positive :=
  match j with O => n0 | S j' => Pos.succ (nm n0 j') end.

Definition wcell (rp : positive) (o0 : Z) (n0 : positive) (i : nat) : sentry :=
  (rp, o0 + 24 + 4 * Z.of_nat i, Mint32, Sfresh (nm n0 (3 + i))).

Definition fcells (rCL rp : positive) (o0 : Z) (n0 : positive) (n : nat) : list sentry :=
  (rCL, 4, Mint16signed, Sfresh (nm n0 2)) :: (rp, o0, Mfloat32, Sfresh (nm n0 0))
  :: (rp, o0 + 8, Mfloat32, Sfresh (nm n0 1))
  :: (rp, o0 + 22, Mint16signed, Sconst (Vint (Int.repr (Z.of_nat n))))
  :: map (wcell rp o0 n0) (seq 0 n).

Definition wfacts (n0 : positive) (szS : Z) (n : nat) : list fact :=
  map (fun i => Fworld (Sfresh (nm n0 (3 + i))) szS) (seq 0 n).

Definition fresh8 (g : gst) : gst :=
  gfresh (gfresh (gfresh (gfresh (gfresh (gfresh (gfresh (gfresh g))))))).

(* the outcome with n recorded walls (n = min(count, 4)) *)
Definition fwc_out (nbase : positive) (R0 : list (positive * Z)) (rCL rp : positive) (o0 : Z)
    (szS : Z) (g : gst) (n : nat) : option (gst * sval) :=
  match sstores nbase R0 (fresh8 g) (fcells rCL rp o0 (g_nx g) n) with
  | Some gS => Some (addfs gS (wfacts (g_nx g) szS n),
                     if Nat.ltb n 4 then Sconst (Vint (Int.repr (Z.of_nat n))) else Sfresh (nm (g_nx g) 7))
  | None => None
  end.

Definition c_fwc (nbase : positive) (R0 : list (positive * Z)) (rCL kW : positive) (szS : Z)
    : xcontract := fun args g =>
  match args with
  | [Sptr rp op] =>
      if existsb (Pos.eqb rp) (g_loc g) && existsb (is_fact_W kW (wargs R0)) (g_pc g) then
        match fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 0,
              fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 1,
              fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 2,
              fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 3,
              fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 4 with
        | Some c0, Some c1, Some c2, Some c3, Some c4 => Some [c0; c1; c2; c3; c4]
        | _, _, _, _, _ => None
        end
      else None
  | _ => None
  end.

Lemma fcells_wall : forall rCL rp o0 n0 n i, (i < n)%nat -> In (wcell rp o0 n0 i) (fcells rCL rp o0 n0 n).
Proof.
  intros. unfold fcells. do 4 right. apply in_map. apply in_seq. lia.
Qed.

Lemma fcells_in : forall rCL rp o0 n0 n e, In e (fcells rCL rp o0 n0 n) ->
  e = (rCL, 4, Mint16signed, Sfresh (nm n0 2)) \/ e = (rp, o0, Mfloat32, Sfresh (nm n0 0))
  \/ e = (rp, o0 + 8, Mfloat32, Sfresh (nm n0 1))
  \/ e = (rp, o0 + 22, Mint16signed, Sconst (Vint (Int.repr (Z.of_nat n))))
  \/ exists i, (i < n)%nat /\ e = wcell rp o0 n0 i.
Proof.
  intros rCL rp o0 n0 n e I. unfold fcells in I.
  destruct I as [<- | [<- | [<- | [<- | I]]]]; auto.
  apply in_map_iff in I. destruct I as (i & <- & Ii). apply in_seq in Ii.
  do 4 right. exists i. split; [lia | reflexivity].
Qed.

Section WCE.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variables rCL kW : positive.
Variable szS : Z.

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf).
Local Notation nb0 := (Mem.nextblock m0).
Local Notation den := (den ge m0).

Hypothesis HC : cenv_has ge.
Hypothesis Hpin : wfl_pinned ge.
Hypothesis HgCL : gfind gtab surface_collision._gNumCalls = Some rCL.
Hypothesis HU : forall vs, uf kW vs -> Wff ge m0 szS vs.

(* THE SOUNDNESS of c_fwc against the real find_wall_collisions *)
Theorem c_fwc_sound : forall args g cps E m vargs t m' vres,
  c_fwc nbase R0 rCL kW szS args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m (Internal surface_collision.f_find_wall_collisions) vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_fwc in Hc.
  destruct args as [| a1 [| a2 l]]; try discriminate Hc; [| destruct a1; discriminate Hc].
  destruct a1 as [ | rp op | | | | | | | | ]; try discriminate Hc.
  destruct (existsb (Pos.eqb rp) (g_loc g) && existsb (is_fact_W kW (wargs R0)) (g_pc g)) eqn:CK;
    [| discriminate Hc].
  apply andb_true_iff in CK as [CL CW].
  apply existsb_exists in CL as (rp' & Il & Erp). apply Pos.eqb_eq in Erp. subst rp'.
  apply existsb_exists in CW as (fW & IW & EW).
  destruct fW as [ | | | k wa]; try discriminate EW.
  apply andb_true_iff in EW as [Ek Ewa]. apply Pos.eqb_eq in Ek. subst k.
  destruct (list_eq_dec sval_eq wa (wargs R0)) as [-> | ]; [| discriminate Ewa].
  destruct (fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 0) as [c0 |] eqn:O0; [| discriminate Hc].
  destruct (fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 1) as [c1 |] eqn:O1; [| discriminate Hc].
  destruct (fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 2) as [c2 |] eqn:O2; [| discriminate Hc].
  destruct (fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 3) as [c3 |] eqn:O3; [| discriminate Hc].
  destruct (fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g 4) as [c4 |] eqn:O4; [| discriminate Hc].
  injection Hc as <-.
  (* the argument *)
  inv HF. match goal with H : Forall2 _ _ _ |- _ => inv H end.
  match goal with H : den E (Sptr rp op) = Some _ /\ _ |- _ => destruct H as (Dp & _) end.
  cbn [SymExec2.den] in Dp. injection Dp as <-.
  pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  destruct (LOC rp Il) as (NBrp & _ & Hb0 & Hnew & Hvm).
  rewrite Hb0, Ptrofs.add_zero_l in Hev.
  set (bpf := e_blk E rp) in *.
  (* the world fact *)
  destruct (PC _ IW) as (_ & HW). cbn [fact_holds] in HW. apply HU in HW.
  set (vs := map (den E) (wargs R0)) in *.
  pose proof HW as (WS & WP & WL & WSurf & Wsz).
  (* the static block *)
  destruct EO as (_ & _ & _ & EG & _ & _).
  destruct (EG _ _ HgCL) as (_ & BCL & SCL).
  set (bCL := e_blk E rCL) in *.
  assert (WCL : Mem.range_perm m0 bCL 0 6 Cur Writable).
  { destruct (WS surface_collision._gNumCalls 6 ltac:(cbn; auto)) as (b & Hs & Hr).
    rewrite SCL in Hs. injection Hs as <-. exact Hr. }
  assert (StCL : is_static ge bCL)
    by (exists surface_collision._gNumCalls; split; [cbn; auto | exact SCL]).
  assert (OCL : Plt bCL nb0) by (eapply statics_old; [exact HW | exact StCL]).
  assert (NpC : bpf <> bCL) by (intros E'; rewrite E' in Hnew; exact (Hnew OCL)).
  (* the data block fits: the last wall slot is in bounds *)
  assert (Hro : Ptrofs.unsigned op + 40 <= Ptrofs.modulus).
  { unfold fwc_out in O4.
    destruct (sstores nbase R0 (fresh8 g) (fcells rCL rp (Ptrofs.unsigned op) (g_nx g) 4)) as [g4 |] eqn:S4;
      [| discriminate O4].
    pose proof (sstores_inb nbase R0 _ _ _ _ S4 (fcells_wall rCL rp (Ptrofs.unsigned op) (g_nx g) 4 3 ltac:(lia)))
      as IB.
    cbn [skey wcell] in IB.
    destruct (inb_spec _ _ _ _ _ _ IB) as [(Lr & _) | (_ & _ & _ & Hb)]; [contradiction |].
    cbn [size_chunk Z.of_nat Pos.of_succ_nat] in Hb. lia. }
  (* the memory-level contract *)
  set (avoid := fun b => is_static ge b \/ b = bpf).
  assert (Hcl : forall b, Genv.find_symbol ge surface_collision._gNumCalls = Some b ->
            avoid b /\ b <> bpf).
  { intros b Hs. rewrite SCL in Hs. injection Hs as <-. split; [left; exact StCL | congruence]. }
  destruct (fwc_contract ge avoid m bpf op HC Hpin (or_intror eq_refl) Hro Hcl
              ltac:(intros id bp Hin Hs; destruct (WP id bp Hin Hs) as (Old & NR & NS);
                    split; [eapply Plt_Ple_trans; [exact Old | exact NX] |];
                    intros [H | ->]; [exact (NS H) | exact (Hnew Old)])
              ltac:(intros hd PH; apply (wf_to_m ge nbase R0 gtab kv m0 uf E m g MMh bpf hd Hnew);
                    apply WL; exact (part_head_to_m0 ge nbase R0 gtab kv m0 uf szS E m g MMh hd HW PH))
              t m' vres Hev)
    as (c & Hc0 & -> & (U & UP) & Hl & (HW1 & HW2) & (vx0 & RX) & (vz0 & RZ)).
  (* old blocks are valid in m *)
  assert (Vm : forall b, Plt b nb0 -> Mem.valid_block m b)
    by (intros b Hb; eapply Plt_Ple_trans; [exact Hb | exact NX]).
  assert (RDm : forall b z ch v0, Mem.valid_block m b -> Mem.load ch m b z = Some v0 ->
            exists v, Mem.load ch m' b z = Some v).
  { intros b z ch v0 Hv L. apply Mem.load_valid_access in L. apply Mem.valid_access_load.
    destruct L as (Hr & Ha). split; [| exact Ha].
    intros i Hi. apply (proj1 (UP b i Cur Readable Hv)). exact (Hr i Hi). }
  (* the values the written cells hold in m' *)
  destruct (RDm _ _ _ _ Hvm RX) as (vx & LX).
  destruct (RDm _ _ _ _ Hvm RZ) as (vz & LZ).
  assert (RCL : Mem.valid_access m' Mint16signed bCL 4 Readable).
  { split; [| exists 2; reflexivity]. intros i Hi. cbn [size_chunk] in Hi.
    apply (proj1 (UP bCL i Cur Readable (Vm _ OCL))).
    apply (proj2 (VP bCL i Cur Readable OCL)). eapply Mem.perm_implies; [apply WCL; lia | constructor]. }
  destruct (Mem.valid_access_load m' Mint16signed bCL 4 RCL) as (vcl & LCL).
  destruct (ld16 _ _ _ _ m0 LCL) as (Ocl & _).
  assert (PICK : forall i, exists w, val_old m0 w /\
            (Z.of_nat i < Z.min c 4 ->
               Mem.load Mint32 m' bpf (Ptrofs.unsigned op + 24 + 4 * Z.of_nat i) = Some w
               /\ exists bs os, w = Vptr bs os /\ Plt bs nb0
                    /\ Ptrofs.unsigned os + szS <= Ptrofs.modulus /\ ~ rblk vs bs)).
  { intros i. destruct (Z_lt_dec (Z.of_nat i) (Z.min c 4)) as [Lt | Ge].
    - destruct (HW1 (Z.of_nat i) ltac:(lia)) as (s & Ls & (hd & PH & OL)).
      pose proof (part_head_to_m0 ge nbase R0 gtab kv m0 uf szS E m g MMh hd HW PH) as PH0.
      destruct (WSurf hd s PH0 (on_list_to_m0 ge nbase R0 gtab kv m0 uf E m g MMh hd s (WL hd PH0) OL))
        as (bs & os & -> & Ob & Ro & NR).
      exists (Vptr bs os). split; [exact Ob |]. intros _. split; [exact Ls |].
      exists bs, os. auto.
    - exists Vundef. split; [exact I | intros; lia]. }
  destruct (PICK 0%nat) as (w0 & Ow0 & Pw0). destruct (PICK 1%nat) as (w1 & Ow1 & Pw1).
  destruct (PICK 2%nat) as (w2 & Ow2 & Pw2). destruct (PICK 3%nat) as (w3 & Ow3 & Pw3).
  (* the names *)
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf E m g vx MMh
                (ldf_old m0 _ _ _ _ LX)) as M1.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _ vz M1
                (ldf_old m0 _ _ _ _ LZ)) as M2.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _ vcl M2 Ocl) as M3.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _ w0 M3 Ow0) as M4.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _ w1 M4 Ow1) as M5.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _ w2 M5 Ow2) as M6.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _ w3 M6 Ow3) as M7.
  pose proof (MMg_fresh ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf _ m _
                (Vint (Int.repr c)) M7 I) as M8.
  change (gfresh (gfresh (gfresh (gfresh (gfresh (gfresh (gfresh (gfresh g))))))))
    with (fresh8 g) in M8.
  match type of M8 with MMg _ _ _ _ _ _ _ ?EE _ _ => set (E8 := EE) in M8 end.
  assert (NX8 : g_nx (fresh8 g) = nm (g_nx g) 8) by reflexivity.
  assert (RX8 : Rx E E8 (g_nx g)).
  { unfold E8. cbn [g_nx gfresh].
    do 7 (eapply Rx_trans; [| apply Rx_upd | cbn [nm]; unfold Ple; lia]).
    apply Rx_upd. }
  assert (BK : forall r, e_blk E8 r = e_blk E r) by reflexivity.
  assert (AD : forall r o, addr E8 r o = addr E r o) by reflexivity.
  assert (D0 : den E8 (Sfresh (nm (g_nx g) 0)) = Some vx) by (unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity).
  assert (D1 : den E8 (Sfresh (nm (g_nx g) 1)) = Some vz) by (unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity).
  assert (D2 : den E8 (Sfresh (nm (g_nx g) 2)) = Some vcl) by (unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity).
  assert (D7 : den E8 (Sfresh (nm (g_nx g) 7)) = Some (Vint (Int.repr c))) by (unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity).
  assert (DW : forall i, (i < 4)%nat ->
            exists w, den E8 (Sfresh (nm (g_nx g) (3 + i))) = Some w /\
              (Z.of_nat i < Z.min c 4 ->
                 Mem.load Mint32 m' bpf (Ptrofs.unsigned op + 24 + 4 * Z.of_nat i) = Some w
                 /\ exists bs os, w = Vptr bs os /\ Plt bs nb0
                      /\ Ptrofs.unsigned os + szS <= Ptrofs.modulus /\ ~ rblk vs bs)).
  { intros i Hi. destruct i as [| [| [| [| i]]]]; [| | | | lia].
    - exists w0. split; [(unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity) | exact Pw0].
    - exists w1. split; [(unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity) | exact Pw1].
    - exists w2. split; [(unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity) | exact Pw2].
    - exists w3. split; [(unfold E8; cbn [SymExec2.den nm Nat.add g_nx gfresh]; repeat (first [rewrite upd_same | rewrite upd_other by lia]); reflexivity) | exact Pw3]. }
  (* THE STATE with nn recorded walls *)
  assert (GEN : forall nn gS, Z.of_nat nn = Z.min c 4 ->
            sstores nbase R0 (fresh8 g) (fcells rCL rp (Ptrofs.unsigned op) (g_nx g) nn) = Some gS ->
            MM E8 m' (addfs gS (wfacts (g_nx g) szS nn)) /\ g_nx gS = nm (g_nx g) 8
            /\ g_loc gS = g_loc g).
  { intros nn gS En S.
    assert (Hnn : (nn <= 4)%nat) by lia.
    (* every cell off the written ones reads the same in m' and m *)
    assert (HD : forall b z ch, Mem.valid_block m b ->
              (forall k, In k (fcells rCL rp (Ptrofs.unsigned op) (g_nx g) nn) ->
                 cell_disj E8 (skey k) b z ch) ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros b z ch Hv D.
      pose proof (D _ (or_introl eq_refl)) as DCL.
      pose proof (D _ (or_intror (or_introl eq_refl))) as DX.
      pose proof (D _ (or_intror (or_intror (or_introl eq_refl)))) as DZ.
      pose proof (D _ (or_intror (or_intror (or_intror (or_introl eq_refl))))) as DN.
      assert (DWl : forall j, (j < nn)%nat ->
                e_blk E rp <> b \/ Ptrofs.unsigned op + 24 + 4 * Z.of_nat j + 4 <= z
                \/ z + size_chunk ch <= Ptrofs.unsigned op + 24 + 4 * Z.of_nat j).
      { intros j Hj. pose proof (D _ (fcells_wall rCL rp (Ptrofs.unsigned op) (g_nx g) nn j Hj)) as DJ.
        cbn [skey wcell cell_disj] in DJ. rewrite BK, AD in DJ. unfold addr in DJ.
        rewrite Hb0, Ptrofs.unsigned_zero in DJ. cbn [size_chunk] in DJ. exact DJ. }
      cbn [skey cell_disj] in DCL, DX, DZ, DN. rewrite !BK, !AD in DCL, DX, DZ, DN. unfold addr in DCL, DX, DZ, DN.
      rewrite Hb0, Ptrofs.unsigned_zero in DX, DZ, DN. rewrite BCL, Ptrofs.unsigned_zero in DCL.
      cbn [size_chunk] in DCL, DX, DZ, DN.
      fold bpf in DX, DZ, DN, DWl. fold bCL in DCL.
      eapply Mem.load_unchanged_on_1; [exact (uo_or _ _ _ _ U HW2) | exact Hv |].
      intros i Hi. cbv beta.
      destruct (eq_block b bpf) as [-> | Nb].
      - destruct (Z_le_dec (Ptrofs.unsigned op + 24 + 4 * Z.min c 4) i) as [L1 | L1];
          [destruct (Z_lt_dec i (Ptrofs.unsigned op + 40)) as [L2 | L2] |].
        + right. split; [reflexivity | lia].
        + left. split; [exact Hv |]. intros [(_ & R) | (Hs & R)].
          * destruct DX as [DX | [DX | DX]]; [congruence | |];
            destruct DZ as [DZ | [DZ | DZ]]; try congruence; lia.
          * rewrite SCL in Hs. injection Hs as Hs. exact (NpC (eq_sym Hs)).
        + left. split; [exact Hv |]. intros [(_ & R) | (Hs & R)].
          * destruct (Z_lt_dec i (Ptrofs.unsigned op + 24)) as [L3 | L3].
            -- destruct DX as [DX | [DX | DX]]; [congruence | |];
               destruct DZ as [DZ | [DZ | DZ]]; try congruence;
               destruct DN as [DN | [DN | DN]]; try congruence; lia.
            -- assert (exists j, (j < nn)%nat /\ Ptrofs.unsigned op + 24 + 4 * Z.of_nat j <= i
                          < Ptrofs.unsigned op + 24 + 4 * Z.of_nat j + 4) as (j & Hj & Rj).
               { destruct (Z_lt_dec i (Ptrofs.unsigned op + 28)); [exists 0%nat; split; cbn [Z.of_nat]; lia |].
                 destruct (Z_lt_dec i (Ptrofs.unsigned op + 32)); [exists 1%nat; split; cbn [Z.of_nat Pos.of_succ_nat]; lia |].
                 destruct (Z_lt_dec i (Ptrofs.unsigned op + 36)); [exists 2%nat; split; cbn [Z.of_nat Pos.of_succ_nat Pos.succ]; lia |].
                 exists 3%nat; split; cbn [Z.of_nat Pos.of_succ_nat Pos.succ]; lia. }
               destruct (DWl j Hj) as [DJ | [DJ | DJ]]; [congruence | lia | lia].
          * rewrite SCL in Hs. injection Hs as Hs. exact (NpC (eq_sym Hs)).
      - left. split; [exact Hv |]. intros [(Eb & _) | (Hs & R)]; [congruence |].
        rewrite SCL in Hs. injection Hs as <-.
        destruct DCL as [DCL | [DCL | DCL]]; [congruence | lia | lia]. }
    (* the written cells hold their names' values *)
    assert (SK : forall j, (j < 8)%nat -> sok nbase (nm (g_nx g) 8) (Sfresh (nm (g_nx g) j))).
    { intros j Hj. split; [| exact Logic.I].
      change (Plt (nm (g_nx g) j) (nm (g_nx g) 8)).
      destruct j as [|[|[|[|[|[|[|[|j]]]]]]]]; cbn [nm]; unfold Plt; lia. }
    assert (HL : forall r o ch sv, In (r, o, ch, sv) (fcells rCL rp (Ptrofs.unsigned op) (g_nx g) nn) ->
              sok nbase (g_nx (fresh8 g)) sv /\ Mem.load ch m' (e_blk E8 r) (addr E8 r o) = den E8 sv).
    { intros r o ch sv Hin. rewrite BK, AD, NX8. unfold addr.
      destruct (fcells_in _ _ _ _ _ _ Hin) as [Eq | [Eq | [Eq | [Eq | (i & Hi & Eq)]]]].
      - injection Eq as -> -> -> ->. split; [apply (SK 2%nat); lia |].
        rewrite BCL, Ptrofs.unsigned_zero. transitivity (Some vcl); [exact LCL | symmetry; exact D2].
      - injection Eq as -> -> -> ->. split; [apply (SK 0%nat); lia |].
        rewrite Hb0, Ptrofs.unsigned_zero. transitivity (Some vx); [exact LX | symmetry; exact D0].
      - injection Eq as -> -> -> ->. split; [apply (SK 1%nat); lia |].
        rewrite Hb0, Ptrofs.unsigned_zero. transitivity (Some vz); [exact LZ | symmetry; exact D1].
      - injection Eq as -> -> -> ->. split; [apply sok_const; reflexivity |].
        rewrite Hb0, Ptrofs.unsigned_zero. cbn [SymExec2.den]. rewrite En. exact Hl.
      - unfold wcell in Eq. injection Eq as -> -> -> ->.
        destruct (DW i ltac:(lia)) as (w & Dw & Pw). split; [apply (SK (3 + i)%nat); lia |].
        rewrite Hb0, Ptrofs.unsigned_zero. destruct (Pw ltac:(lia)) as (Lw & _).
        transitivity (Some w); [exact Lw | symmetry; exact Dw]. }
    destruct (sstores_havoc nbase R0 ge gtab kv m0 uf E8 m (fresh8 g) _ gS m' M8 S HL HD
                (Mem.unchanged_on_nextblock _ _ _ U)
                ltac:(intros b o k p OLD; symmetry; exact (UP b o k p (Vm b OLD))))
      as (MS & NXS & LCS & _).
    split; [| split; [rewrite NXS; exact NX8 | rewrite LCS; reflexivity]].
    apply MMg_addfs; [exact MS |].
    intros f If. unfold wfacts in If. apply in_map_iff in If. destruct If as (i & <- & Ii). apply in_seq in Ii.
    destruct (DW i ltac:(lia)) as (w & Dw & Pw).
    destruct (Pw ltac:(lia)) as (_ & bs & os & -> & Ob & Ro & NR).
    split.
    - change (Plt (nm (g_nx g) (3 + i)) (g_nx gS)). rewrite NXS, NX8.
      destruct i as [|[|[|[|i]]]]; [| | | | lia]; cbn [nm Nat.add]; unfold Plt; lia.
    - cbn [fact_holds]. exists bs, os. split; [exact Dw |].
      split; [exact Ob | split; [exact Wsz | split; [exact Ro |]]].
      intros r sz Hsz. left. rewrite BK. intros Eb. apply NR. rewrite <- Eb.
      exact (r0_rblk ge R0 m0 E r sz Hsz). }
  (* each outcome is the right one when min(count, 4) is its n *)
  assert (FIN : forall nn cn, Z.of_nat nn = Z.min c 4 ->
            fwc_out nbase R0 rCL rp (Ptrofs.unsigned op) szS g nn = Some cn ->
            CM ge nbase R0 gtab kv m0 uf E (g_nx g) (g_loc g) m' (Vint (Int.repr c)) cn).
  { intros nn cn En O. unfold fwc_out in O.
    destruct (sstores nbase R0 (fresh8 g) (fcells rCL rp (Ptrofs.unsigned op) (g_nx g) nn)) as [gS |] eqn:S;
      [| discriminate O].
    injection O as <-.
    destruct (GEN nn gS En S) as (MF & NXS & LCS).
    destruct (addfs_meta (wfacts (g_nx g) szS nn) gS) as (NXF & LCF).
    unfold CM. exists E8. split; [exact (Rx_Ext _ _ _ RX8) |]. split; [exact MF |].
    rewrite NXF, NXS, LCF, LCS.
    destruct (Nat.ltb nn 4) eqn:Lt.
    - apply Nat.ltb_lt in Lt.
      split; [cbn [SymExec2.den]; do 3 f_equal; lia |].
      split; [apply sok_const; reflexivity |]. split; [cbn [nm]; unfold Ple; lia | reflexivity].
    - apply Nat.ltb_ge in Lt.
      split; [exact D7 |].
      split; [split; [change (Plt (nm (g_nx g) 7) (nm (g_nx g) 8)); cbn [nm]; unfold Plt; lia | exact Logic.I] |].
      split; [cbn [nm]; unfold Ple; lia | reflexivity]. }
  assert (Hn : 0 <= Z.min c 4 <= 4) by lia.
  destruct (k5 _ Hn) as [Ez | [Ez | [Ez | [Ez | Ez]]]].
  - exists c0. split; [left; reflexivity | exact (FIN 0%nat c0 ltac:(rewrite Ez; reflexivity) O0)].
  - exists c1. split; [right; left; reflexivity | exact (FIN 1%nat c1 ltac:(rewrite Ez; reflexivity) O1)].
  - exists c2. split; [do 2 right; left; reflexivity | exact (FIN 2%nat c2 ltac:(rewrite Ez; reflexivity) O2)].
  - exists c3. split; [do 3 right; left; reflexivity | exact (FIN 3%nat c3 ltac:(rewrite Ez; reflexivity) O3)].
  - exists c4. split; [do 4 right; left; reflexivity | exact (FIN 4%nat c4 ltac:(rewrite Ez; reflexivity) O4)].
Qed.

End WCE.
