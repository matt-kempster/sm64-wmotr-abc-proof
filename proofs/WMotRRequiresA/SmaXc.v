(* ====================================================================== *)
(* SmaXc (unwired, GOAL 2): the executor's contract for the REAL          *)
(* set_mario_animation, PROVED SOUND from its generated body              *)
(* (SmaFoot.sma_foot: load_patchable_table and dma_read walked down to    *)
(* the DMA floor, TRUST 3.5).                                              *)
(*                                                                        *)
(* c_sma answers set_mario_animation(m, anim) when m->animList is the     *)
(* list global's address, m->marioObj is a region address, and the       *)
(* list's bufTarget cell holds a pointer into the whole-block buffer      *)
(* region, with 24 bytes of room.  That last one is a path fact           *)
(* Fuser kB [bufTarget; &buffer region], not a known constant: the real   *)
(* buffer comes from main_pool_alloc, at an offset nobody pins.          *)
(* Afterwards:                                                             *)
(*   - the buffer region and the three DMA globals are clobbered (their   *)
(*     contents are unknown);                                              *)
(*   - the object's animation cells (animID .. animFrame, animAccel) and  *)
(*     the list's currentAddr cell hold fresh values, named as 16-bit     *)
(*     halves so a fresh value is never a pointer;                         *)
(*   - every other cell is unchanged, and the result is a fresh value.   *)
(*                                                                        *)
(* The general tool first: sstores_havoc_cl is WallExec.sstores_havoc for *)
(* a callee that also changes whole clobbered regions.                    *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario memory.
From SM64.Proofs Require Import Interp.SymExec2 MarioModel.LinkedTwelve MarioModel.RealFrameLinked
  MarioModel.OsDmaFloor WMotRRequiresA.WallExec WMotRRequiresA.AirWr
  WMotRRequiresA.SmaFoot.
Import ListNotations.

Definition sreg (e : sentry) : positive := fst (fst (fst e)).

Section HC.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).

Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).
Local Notation nb0 := (Mem.nextblock m0).

(* a cell of a region other than rc lies outside rc's range *)
Lemma inb_rng : forall E m g r o ch rc sz, MM E m g -> inb nbase R0 g r o ch = true -> r <> rc ->
  r0_size R0 rc = Some sz -> rng_disj R0 E rc (e_blk E r) (addr E r o) ch.
Proof.
  intros E m g r o ch rc sz MMh IB NE Sz.
  pose proof MMh as ((A1 & A2 & A3 & _) & _ & _ & _ & _ & _ & _ & LOC & _).
  unfold rng_disj. rewrite Sz.
  destruct (inb_spec nbase R0 _ _ _ _ IB) as [(L & szr & Sr & O1 & O2) | (L & IN & O1 & O2)].
  - destruct (A3 r szr rc sz Sr Sz NE) as [B | [B | B]];
      [ left; congruence | right; right; unfold addr; lia | right; left; unfold addr; lia ].
  - left. intros Eb. destruct (LOC r IN) as (_ & _ & _ & NP & _).
    destruct (A2 rc sz Sz) as (Lc & _).
    pose proof (A1 rc Lc) as G. destruct (gp (e_blk E rc)) as [x|] eqn:Gx; [| congruence].
    apply NP. rewrite <- Eb. exact (gp_old _ _ Gx).
Qed.

(* THE HAVOC LEMMA, with clobbered regions: the cells of l hold what l
   says, the regions cls (already clobbered in g, holding no entry of g)
   may have changed anyhow, and every other cell is unchanged *)
Theorem sstores_havoc_cl : forall cls E m g l g' m',
  MM E m g ->
  (forall rc, In rc cls -> In rc (g_cl g) /\ exists sz, r0_size R0 rc = Some sz) ->
  (forall e, In e (g_sm g) -> ~ In (sreg e) cls) ->
  sstores nbase R0 g l = Some g' ->
  (forall r o ch sv, In (r, o, ch, sv) l ->
     sok nbase (g_nx g) sv /\ Mem.load ch m' (e_blk E r) (addr E r o) = den ge m0 E sv) ->
  (forall b z ch, Mem.valid_block m b ->
     (forall k, In k l -> cell_disj E (skey k) b z ch) ->
     (forall rc, In rc cls -> rng_disj R0 E rc b z ch) ->
     Mem.load ch m' b z = Mem.load ch m b z) ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b o k p, Plt b nb0 -> (Mem.perm m' b o k p <-> Mem.perm m b o k p)) ->
  MM E m' g' /\ g_nx g' = g_nx g /\ g_loc g' = g_loc g /\ g_pc g' = g_pc g.
Proof.
  intros cls E m g l g' m' MMh CLS NCL S HL HD NXm P.
  destruct (sstores_meta _ _ _ _ _ S) as (NXg & LCg & PCg).
  split; [| auto].
  pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  assert (KD : forall k r o ch, In k l -> inb nbase R0 g r o ch = true ->
            (let '(r1, o1, ch1) := skey k in
             r1 <> r \/ o1 + size_chunk ch1 <= o \/ o + size_chunk ch <= o1) ->
            cell_disj E (skey k) (e_blk E r) (addr E r o) ch).
  { intros [[[r1 o1] ch1] sv1] r o ch Ik IB D.
    pose proof (sstores_inb _ _ _ _ _ _ S Ik) as IB1. cbn [skey] in IB1, D |- *.
    exact (inb_disj ge nbase R0 gtab kv m0 uf gp gp_old _ _ _ _ _ _ _ _ _ MMh IB1 IB D). }
  split; [exact EO | split; [rewrite NXg; exact NB |]].
  split; [| split; [| split; [| split; [| split; [| split; [| let I1 := fresh in let I2 := fresh in intros ? ? I1 I2; rewrite LCg in I1, I2; exact (LINJ _ _ I1 I2)]]]]]].
  - (* entries *)
    intros r o ch sv I. rewrite (inb_loc nbase R0 g g' r o ch LCg), NXg.
    destruct (sstores_in _ _ _ _ _ _ S I) as [Il | (I0 & N0)].
    + pose proof (sstores_inb _ _ _ _ _ _ S Il) as IB. cbn [skey] in IB.
      destruct (HL _ _ _ _ Il) as (SK & L). auto.
    + destruct (ENT _ _ _ _ I0) as (IB & SK & L). split; [exact IB | split; [exact SK |]].
      rewrite <- L. apply HD; [exact (inb_valid nbase R0 ge gtab kv m0 uf gp gp_old _ _ _ _ _ _ MMh IB) | |].
      * intros k Ik. apply (KD k r o ch Ik IB).
        pose proof (N0 k Ik) as N. destruct k as [[[r1 o1] ch1] sv1]. cbn [skey] in N |- *.
        apply ovl_false in N. destruct N as [N | [N | N]]; [left; exact N | right; right; exact N | right; left; exact N].
      * intros rc Ic. destruct (CLS rc Ic) as (_ & sz & Sz).
        apply (inb_rng E m g r o ch rc sz MMh IB); [| exact Sz].
        intros ->. exact (NCL _ I0 Ic).
  - (* frame *)
    intros b z ch OLD D CLD.
    assert (Vb : Mem.valid_block m b) by (eapply Plt_Ple_trans; [exact OLD | exact NX]).
    rewrite (HD b z ch Vb).
    + apply FR; [exact OLD | | intros r I; apply CLD; rewrite (sstores_cl _ _ _ _ _ S); exact I].
      intros e Ie.
      destruct (sstores_drop _ _ _ _ _ _ S Ie) as [Ie' | (k & Ik & Ek)]; [exact (D e Ie') |].
      destruct (sstores_key _ _ _ _ _ _ S Ik) as (e' & Ie' & Ee'). rewrite <- Ek, <- Ee'. exact (D e' Ie').
    + intros k Ik. destruct (sstores_key _ _ _ _ _ _ S Ik) as (e' & Ie' & Ee'). rewrite <- Ee'. exact (D e' Ie').
    + intros rc Ic. apply CLD. rewrite (sstores_cl _ _ _ _ _ S). exact (proj1 (CLS rc Ic)).
  - intros b o k p OLD. rewrite (P b o k p OLD). exact (VP b o k p OLD).
  - eapply Ple_trans; [exact NX | exact NXm].
  - rewrite PCg, NXg. exact PC.
  - intros r I. rewrite LCg in I. destruct (LOC r I) as (A & B & C & D & F).
    rewrite NXg. split; [exact A | split; [exact B | split; [exact C | split; [exact D |]]]].
    eapply Plt_Ple_trans; [exact F | exact NXm].
Qed.

(* clobbering regions that hold no entry keeps the description *)
Definition gcl (cls : list positive) (g : gst) : gst :=
  mkg (g_sm g) (g_pc g) (g_nx g) (g_loc g) (cls ++ g_cl g).

Lemma MM_gcl : forall cls E m g, MM E m g -> MM E m (gcl cls g).
Proof.
  intros cls E m g MMh. pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  unfold gcl, MMg; cbn [g_sm g_pc g_nx g_loc g_cl].
  split; [exact EO | split; [exact NB | split; [| split; [| split; [exact VP | split; [exact NX | split; [exact PC | split; [exact LOC | exact LINJ]]]]]]]].
  - intros r o ch sv I. destruct (ENT r o ch sv I) as (IB & SK & L).
    split; [rewrite <- IB; apply inb_loc; reflexivity | auto].
  - intros b z ch OLD D CLD. apply FR; [exact OLD | exact D |].
    intros r I. apply CLD. apply in_or_app. right. exact I.
Qed.
End HC.

(* ---------------------------------------------------------------------- *)
(* The contract                                                           *)
(* ---------------------------------------------------------------------- *)

(* the object's animation cells animID(56) animYTrans(58) curAnim(60..64)
   animFrame(64) animAccel(72..76), and the list's currentAddr (4..8), as
   16-bit halves *)
Definition ws_obj : wset :=
  [(56, Mint16signed); (58, Mint16signed); (60, Mint32);
   (64, Mint16signed); (72, Mint16signed); (74, Mint16signed)].
Definition ws_lst : wset := [(4, Mint16signed); (6, Mint16signed)].

(* set_mario_anim_with_accel: the same contract over the whole animInfo
   window animID .. animAccel (it also writes animFrameAccelAssist, 68, and
   animAccel on every call) *)
Definition ws_obj2 : wset :=
  [(56, Mint16signed); (58, Mint16signed); (60, Mint32); (64, Mint16signed); (66, Mint16signed);
   (68, Mint16signed); (70, Mint16signed); (72, Mint16signed); (74, Mint16signed)].

Section CSMA.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variables rl rbuf riom rmq rrm kB : positive.

Definition sma_cls : list positive := [rbuf; riom; rmq; rrm].

Definition sma_static_ok : bool :=
  match gfind gtab mario._gMarioAnimsBuf, gfind gtab memory._gDmaIoMesg,
        gfind gtab memory._gDmaMesgQueue, gfind gtab memory._gMainReceivedMesg,
        r0_size R0 rbuf, r0_size R0 riom, r0_size R0 rmq, r0_size R0 rrm with
  | Some a, Some i, Some q, Some r, Some sb, Some si, Some sq, Some sr =>
      Pos.eqb a rl && Pos.eqb i riom && Pos.eqb q rmq && Pos.eqb r rrm
      && Z.eqb sb Ptrofs.modulus && Z.eqb si SZ_IOMESG && Z.eqb sq SZ_MESGQ && Z.eqb sr 4
      && negb (Pos.eqb rbuf rl)
  | _, _, _, _, _, _, _, _ => false
  end.

(* the list's bufTarget value s3 points into the buffer region's block with
   24 bytes of room: a path fact Fuser kB [s3; &buffer region] (its meaning,
   [HUB] below, is a premise of the soundness theorem; the walk's start
   state proves it from the frame memory) *)
Definition is_buf_fact (s3 : sval) (f : fact) : bool :=
  match f with
  | Fuser k [a; Sptr r o] => Pos.eqb k kB && sbeq a s3 && Pos.eqb r rbuf && Ptrofs.eq o Ptrofs.zero
  | _ => false
  end.

Definition c_sma : xcontract :=
  fun args g =>
  match args with
  | Sptr rm om :: _ =>
      match sload nbase R0 kv g rm (Ptrofs.unsigned om + 160) Mint32,
            sload nbase R0 kv g rm (Ptrofs.unsigned om + 136) Mint32,
            sload nbase R0 kv g rl 8 Mint32 with
      | Some (Sptr rl' zl), Some (Sptr ro oo), Some s3 =>
          match sload nbase R0 kv g ro (Ptrofs.unsigned oo + 60) Mint32 with
          | Some s60 =>
          if sma_static_ok && Pos.eqb rl' rl && Ptrofs.eq zl Ptrofs.zero
             && negb (loc_ptr nbase s60) && negb (existsb (Pos.eqb ro) (rl :: sma_cls))
             && existsb (is_buf_fact s3) (g_pc g)
             && forallb (fun e => negb (existsb (Pos.eqb (sreg e)) sma_cls)) (g_sm g)
          then
            let g1 := gcl sma_cls g in
            let g2 := freshn (length ws_obj) g1 in
            let g3 := freshn (length ws_lst) g2 in
            match sstores nbase R0 g3 (wentries ro (Ptrofs.unsigned oo) (g_nx g1) ws_obj
                                        ++ wentries rl 0 (g_nx g2) ws_lst) with
            | Some g' => Some [(gfresh g', Sfresh (g_nx g'))]
            | None => None
            end
          else None
          | None => None
          end
      | _, _, _ => None
      end
  | _ => None
  end.
Definition c_smawa : xcontract :=
  fun args g =>
  match args with
  | Sptr rm om :: _ =>
      match sload nbase R0 kv g rm (Ptrofs.unsigned om + 160) Mint32,
            sload nbase R0 kv g rm (Ptrofs.unsigned om + 136) Mint32,
            sload nbase R0 kv g rl 8 Mint32 with
      | Some (Sptr rl' zl), Some (Sptr ro oo), Some s3 =>
          match sload nbase R0 kv g ro (Ptrofs.unsigned oo + 60) Mint32 with
          | Some s60 =>
          if sma_static_ok && Pos.eqb rl' rl && Ptrofs.eq zl Ptrofs.zero
             && negb (loc_ptr nbase s60) && negb (existsb (Pos.eqb ro) (rl :: sma_cls))
             && existsb (is_buf_fact s3) (g_pc g)
             && forallb (fun e => negb (existsb (Pos.eqb (sreg e)) sma_cls)) (g_sm g)
          then
            let g1 := gcl sma_cls g in
            let g2 := freshn (length ws_obj2) g1 in
            let g3 := freshn (length ws_lst) g2 in
            match sstores nbase R0 g3 (wentries ro (Ptrofs.unsigned oo) (g_nx g1) ws_obj2
                                        ++ wentries rl 0 (g_nx g2) ws_lst) with
            | Some g' => Some [(gfresh g', Sfresh (g_nx g'))]
            | None => None
            end
          else None
          | None => None
          end
      | _, _, _ => None
      end
  | _ => None
  end.
End CSMA.



(* ---------------------------------------------------------------------- *)
(* Soundness, from the proved footprint                                   *)
(* ---------------------------------------------------------------------- *)

Lemma funcall_two_args : forall (ge : genv) f m v rest t m' vres x tx y ty,
  fn_params f = [(x, tx); (y, ty)] ->
  eval_funcall function_entry2 ge m (Internal f) (v :: rest) t m' vres -> exists v2, rest = [v2].
Proof.
  intros ge f m v rest t m' vres x tx y ty Hp Hev. inv Hev.
  match goal with H : function_entry2 _ _ _ _ _ _ _ |- _ => inv H end.
  rewrite Hp in *.
  match goal with H : bind_parameter_temps _ _ _ = Some _ |- _ => rename H into B end.
  destruct rest as [| v2 [| v3 r]]; [cbn in B; discriminate B | eauto | cbn in B; discriminate B].
Qed.

Lemma sload_inb : forall nbase R0 kv g r o ch sa,
  sload nbase R0 kv g r o ch = Some sa -> inb nbase R0 g r o ch = true.
Proof. intros nbase R0 kv g r o ch sa H. unfold sload in H. destruct (inb nbase R0 g r o ch); [reflexivity | discriminate]. Qed.

Lemma uadd2 : forall a b, Ptrofs.unsigned a + Ptrofs.unsigned b < Ptrofs.modulus ->
  Ptrofs.unsigned (Ptrofs.add a b) = Ptrofs.unsigned a + Ptrofs.unsigned b.
Proof.
  intros a b H. unfold Ptrofs.add. pose proof (Ptrofs.unsigned_range a). pose proof (Ptrofs.unsigned_range b).
  rewrite Ptrofs.unsigned_repr; [reflexivity | unfold Ptrofs.max_unsigned; lia].
Qed.

Lemma base_full : forall p, Ptrofs.unsigned p + Ptrofs.modulus <= Ptrofs.modulus -> p = Ptrofs.zero.
Proof.
  intros p H. pose proof (Ptrofs.unsigned_range p).
  rewrite <- (Ptrofs.repr_unsigned p). replace (Ptrofs.unsigned p) with 0 by lia. reflexivity.
Qed.

Lemma ws_lst_np : forallb (fun c => chunk_np (snd c)) ws_lst = true.
Proof. reflexivity. Qed.
Lemma ws_obj_nd : NoDup (map fst ws_obj).
Proof. apply znodup_ok. reflexivity. Qed.
Lemma ws_lst_nd : NoDup (map fst ws_lst).
Proof. apply znodup_ok. reflexivity. Qed.


Lemma funcall_three_args : forall (ge : genv) f m v rest t m' vres x tx y ty z tz,
  fn_params f = [(x, tx); (y, ty); (z, tz)] ->
  eval_funcall function_entry2 ge m (Internal f) (v :: rest) t m' vres -> exists v2 v3, rest = [v2; v3].
Proof.
  intros ge f m v rest t m' vres x tx y ty z tz Hp Hev. inv Hev.
  match goal with H : function_entry2 _ _ _ _ _ _ _ |- _ => inv H end.
  rewrite Hp in *.
  match goal with H : bind_parameter_temps _ _ _ = Some _ |- _ => rename H into B end.
  destruct rest as [| v2 [| v3 [| v4 r]]]; cbn in B; try discriminate B; eauto.
Qed.
Lemma ws_obj2_nd : NoDup (map fst ws_obj2).
Proof. apply znodup_ok. reflexivity. Qed.

Section SND.
Variable lp : Clight.program.
Hypothesis Hlink : linked12 lp.
Hypothesis Hfloor : os_dma_floor.
Local Notation G := (globalenv lp).
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Hypothesis m0_closed : forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v.
Variables rl rbuf riom rmq rrm kB : positive.
(* the buffer fact's meaning: two pointers into one block, the first with
   24 bytes of room *)
Hypothesis HUB : forall vs, uf kB vs ->
  exists b o o2, vs = [Some (Vptr b o); Some (Vptr b o2)] /\ Ptrofs.unsigned o + 24 <= Ptrofs.modulus.

Local Notation MM := (MMg G nbase R0 gtab kv m0 uf gp).

(* THE CONTRACT for set_mario_animation is sound *)
Theorem c_sma_sound : forall args g cps E m vargs t m' vres,
  c_sma nbase R0 gtab kv rl rbuf riom rmq rrm kB args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m (Internal mario.f_set_mario_animation) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_sma in Hc.
  destruct args as [| a1 rest]; [discriminate Hc |].
  destruct a1 as [ | rm om | | | | | | | | ]; try discriminate Hc.
  destruct (sload nbase R0 kv g rm (Ptrofs.unsigned om + 160) Mint32) as [s1 |] eqn:L1; [| discriminate Hc].
  destruct (sload nbase R0 kv g rm (Ptrofs.unsigned om + 136) Mint32) as [s2 |] eqn:L2;
    [| destruct s1; discriminate Hc].
  destruct (sload nbase R0 kv g rl 8 Mint32) as [s3 |] eqn:L3;
    [| destruct s1, s2; discriminate Hc].
  destruct s1 as [ | rl' zl | | | | | | | | ]; try discriminate Hc.
  destruct s2 as [ | ro oo | | | | | | | | ]; try discriminate Hc.
  destruct (sload nbase R0 kv g ro (Ptrofs.unsigned oo + 60) Mint32) as [s60 |] eqn:L60; [| discriminate Hc].
  destruct (sma_static_ok R0 gtab rl rbuf riom rmq rrm && Pos.eqb rl' rl && Ptrofs.eq zl Ptrofs.zero
            && negb (loc_ptr nbase s60) && negb (existsb (Pos.eqb ro) (rl :: sma_cls rbuf riom rmq rrm))
            && existsb (is_buf_fact rbuf kB s3) (g_pc g)
            && forallb (fun e => negb (existsb (Pos.eqb (sreg e)) (sma_cls rbuf riom rmq rrm))) (g_sm g))
    eqn:CK; [| discriminate Hc].
  set (g1 := gcl (sma_cls rbuf riom rmq rrm) g) in Hc.
  set (g2 := freshn (length ws_obj) g1) in Hc.
  set (g3 := freshn (length ws_lst) g2) in Hc.
  set (l := wentries ro (Ptrofs.unsigned oo) (g_nx g1) ws_obj ++ wentries rl 0 (g_nx g2) ws_lst) in Hc.
  destruct (sstores nbase R0 g3 l) as [g' |] eqn:S; [| discriminate Hc].
  injection Hc as <-.
  apply andb_true_iff in CK as [CK NCLb]. apply andb_true_iff in CK as [CK Hbf].
  apply andb_true_iff in CK as [CK NRO]. apply andb_true_iff in CK as [CK NL60].
  apply andb_true_iff in CK as [CK Ezl].
  apply negb_true_iff in NL60, NRO.
  apply andb_true_iff in CK as [ST Erl].
  apply Pos.eqb_eq in Erl. subst rl'.
  pose proof (Ptrofs.eq_spec zl Ptrofs.zero) as Zl. rewrite Ezl in Zl. subst zl.
  unfold sma_static_ok in ST.
  destruct (gfind gtab mario._gMarioAnimsBuf) as [a |] eqn:Ga; [| discriminate ST].
  destruct (gfind gtab memory._gDmaIoMesg) as [i |] eqn:Gi; [| discriminate ST].
  destruct (gfind gtab memory._gDmaMesgQueue) as [q |] eqn:Gq; [| discriminate ST].
  destruct (gfind gtab memory._gMainReceivedMesg) as [r |] eqn:Gr; [| discriminate ST].
  destruct (r0_size R0 rbuf) as [sb |] eqn:Sb; [| discriminate ST].
  destruct (r0_size R0 riom) as [si |] eqn:Si; [| discriminate ST].
  destruct (r0_size R0 rmq) as [sq |] eqn:Sq; [| discriminate ST].
  destruct (r0_size R0 rrm) as [sr |] eqn:Sr; [| discriminate ST].
  repeat rewrite andb_true_iff in ST.
  destruct ST as [[[[[[[[Ea Ei] Eq] Er] Esb] Esi] Esq] Esr] NE].
  apply Pos.eqb_eq in Ea, Ei, Eq, Er. apply Z.eqb_eq in Esb, Esi, Esq, Esr. subst a i q r sb si sq sr.
  apply negb_true_iff in NE. apply Pos.eqb_neq in NE.
  pose proof MMh as (EO & _). pose proof EO as (A1 & A2 & A3 & A4 & _).
  destruct (A4 _ _ Ga) as (Plt_rl & Bl & Hab).
  destruct (A4 _ _ Gi) as (_ & Bi & Hiom).
  destruct (A4 _ _ Gq) as (_ & Bq & Hmq).
  destruct (A4 _ _ Gr) as (_ & Br & Hrm).
  assert (Bb : e_base E rbuf = Ptrofs.zero) by (apply base_full; exact (proj2 (proj2 (A2 _ _ Sb)))).
  (* the buffer pointer, from the path fact *)
  apply existsb_exists in Hbf as (f & If & Hf).
  destruct f as [ | | | k fargs]; cbn [is_buf_fact] in Hf; try discriminate Hf.
  destruct fargs as [| a [| sp [| ]]]; try (cbv iota in Hf; discriminate Hf); try (destruct sp; discriminate Hf).
  destruct sp as [ | rb ob | | | | | | | | ]; try (cbv iota in Hf; discriminate Hf).
  repeat rewrite andb_true_iff in Hf. destruct Hf as [[[Ek Ea3] Erb] Eob].
  apply Pos.eqb_eq in Ek, Erb. subst k rb.
  unfold sbeq in Ea3. destruct (sval_eq a s3) as [-> |]; [| discriminate Ea3].
  pose proof (Ptrofs.eq_spec ob Ptrofs.zero) as Zob. rewrite Eob in Zob. subst ob.
  pose proof MMh as (_ & _ & _ & _ & _ & _ & PCh & _).
  destruct (PCh _ If) as [_ FH]. cbn [fact_holds map] in FH.
  destruct (HUB _ FH) as (bb & ot & o2 & Evs & Hot).
  cbn [SymExec2.den] in Evs. injection Evs as Dbuf Ebb _. subst bb.
  (* the arguments *)
  inversion HF as [| a v rest' vrest [Dp _] HF']; subst.
  cbn [SymExec2.den] in Dp. injection Dp as <-.
  destruct (funcall_two_args _ mario.f_set_mario_animation _ _ _ _ _ _ _ _ _ _ eq_refl Hev) as (v2 & ->).
  (* the states *)
  assert (LC1 : g_loc g3 = g_loc g).
  { unfold g3, g2. rewrite (proj1 (proj2 (proj2 (freshn_meta _ _)))), (proj1 (proj2 (proj2 (freshn_meta _ _)))). reflexivity. }
  assert (NX12 : g_nx g1 = g_nx g) by reflexivity.
  assert (P12 : Ple (g_nx g1) (g_nx g2)) by exact (proj2 (proj2 (proj2 (proj2 (freshn_meta _ _))))).
  assert (P23 : Ple (g_nx g2) (g_nx g3)) by exact (proj2 (proj2 (proj2 (proj2 (freshn_meta _ _))))).
  assert (IB : forall k, In k l -> inb nbase R0 g (fst (fst (fst k))) (snd (fst (fst k))) (snd (fst k)) = true).
  { intros [[[r1 o1] ch1] sv1] Ik. pose proof (sstores_inb _ _ _ _ _ _ S Ik) as X. cbn [skey] in X.
    rewrite (inb_loc nbase R0 g g3) in X by exact LC1. exact X. }
  (* the three loads, as the footprint theorem wants them *)
  destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L1) as (LD1 & _).
  destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L2) as (LD2 & _).
  destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L3) as (LD3 & _).
  destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh (sload_inb _ _ _ _ _ _ _ _ L1)) as (_ & Q1 & Q1').
  destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh (sload_inb _ _ _ _ _ _ _ _ L2)) as (_ & Q2 & Q2').
  unfold addr in Q1, Q1', Q2, Q2'.
  pose proof (Ptrofs.unsigned_range (e_base E rm)). pose proof (Ptrofs.unsigned_range om).
  pose proof (Ptrofs.unsigned_range (e_base E ro)). pose proof (Ptrofs.unsigned_range oo).
  change (size_chunk Mint32) with 4 in Q1', Q2'.
  assert (UM : Ptrofs.unsigned (Ptrofs.add (e_base E rm) om) = Ptrofs.unsigned (e_base E rm) + Ptrofs.unsigned om)
    by (apply uadd2; lia).
  assert (Hal : Mem.loadv Mptr m (Vptr (e_blk E rm) (Ptrofs.add (Ptrofs.add (e_base E rm) om) (Ptrofs.repr 160)))
                = Some (Vptr (e_blk E rl) Ptrofs.zero)).
  { cbn [Mem.loadv]. rewrite uadd_small by lia. rewrite UM.
    cbn [SymExec2.den] in LD1. rewrite Bl, Ptrofs.add_zero in LD1. unfold addr in LD1.
    rewrite <- LD1. f_equal. lia. }
  assert (Hmo : Mem.loadv Mptr m (Vptr (e_blk E rm) (Ptrofs.add (Ptrofs.add (e_base E rm) om) (Ptrofs.repr 136)))
                = Some (Vptr (e_blk E ro) (Ptrofs.add (e_base E ro) oo))).
  { cbn [Mem.loadv]. rewrite uadd_small by lia. rewrite UM.
    cbn [SymExec2.den] in LD2. unfold addr in LD2. rewrite <- LD2. f_equal. lia. }
  assert (Hbuf : Mem.load Mptr m (e_blk E rl) 8 = Some (Vptr (e_blk E rbuf) ot)).
  { unfold addr in LD3. rewrite Bl in LD3. rewrite Dbuf in LD3. exact LD3. }
  (* the list region has a size; the buffer is another block *)
  assert (Ilst : In (rl, 0 + 6, Mint16signed, Sfresh (Pos.succ (g_nx g2))) l).
  { apply in_or_app. right. right. left. reflexivity. }
  destruct (inb_spec nbase R0 _ _ _ _ (IB _ Ilst)) as [(_ & szl & Szl & _ & Ol) | (NP & _)]; [| contradiction]; cbn [fst snd] in Szl, Ol.
  assert (Hbt_ab : e_blk E rbuf <> e_blk E rl).
  { destruct (A3 _ _ _ _ Sb Szl NE) as [B | [B | B]]; [exact B | |]; rewrite ?Bb, ?Bl in B; change (Ptrofs.unsigned Ptrofs.zero) with 0 in B; pose proof Ptrofs.modulus_pos;
      change (size_chunk Mint16signed) with 2 in Ol; lia. }
  (* the object window fits *)
  assert (Iob : In (ro, Ptrofs.unsigned oo + 74, Mint16signed,
                    Sfresh (Pos.succ (Pos.succ (Pos.succ (Pos.succ (Pos.succ (g_nx g1))))))) l).
  { apply in_or_app. left. do 5 right. left. reflexivity. }
  destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh (IB _ Iob)) as (_ & _ & Q3).
  cbn [fst snd] in Q3. unfold addr in Q3. change (size_chunk Mint16signed) with 2 in Q3.
  assert (UO : Ptrofs.unsigned (Ptrofs.add (e_base E ro) oo) = Ptrofs.unsigned (e_base E ro) + Ptrofs.unsigned oo)
    by (apply uadd2; lia).
  assert (Hoo : Ptrofs.unsigned (Ptrofs.add (e_base E ro) oo) + 76 <= Ptrofs.modulus) by lia.
  (* THE FOOTPRINT *)
  destruct (sma_foot lp Hlink Hfloor (e_blk E rl) (e_blk E rbuf) (e_blk E riom) (e_blk E rmq) (e_blk E rrm) ot
              Hab Hiom Hmq Hrm m (e_blk E rm) (Ptrofs.add (e_base E rm) om)
              (e_blk E ro) (Ptrofs.add (e_base E ro) oo) Hal Hmo Hbuf Hbt_ab Hot Hoo v2 t m' vres Hev)
    as (NPr & FT0).
  assert (FT : foot (Wa (e_blk E rl) (e_blk E rbuf) (e_blk E riom) (e_blk E rmq) (e_blk E rrm)
                        (e_blk E ro) (Ptrofs.add (e_base E ro) oo)) m m').
  { destruct FT0 as [F | (F & _)]; [| exact F]. eapply foot_mono; [| exact F]. intros b z W. left. exact W. }
  destruct FT as (U & NBm & PP).
  (* the fresh names *)
  set (bo := e_blk E ro). set (base_o := Ptrofs.unsigned (e_base E ro) + Ptrofs.unsigned oo).
  set (E1 := updw bo base_o m' E (g_nx g1) ws_obj).
  set (E2 := updw (e_blk E rl) 0 m' E1 (g_nx g2) ws_lst).
  destruct (updw_blk bo base_o m' ws_obj E (g_nx g1)) as (EB1 & EBs1).
  destruct (updw_blk (e_blk E rl) 0 m' ws_lst E1 (g_nx g2)) as (EB2 & EBs2).
  fold E1 in EB1, EBs1. fold E2 in EB2, EBs2.
  assert (EB : e_blk E2 = e_blk E) by congruence.
  assert (EBs : e_base E2 = e_base E) by congruence.
  (* curAnim: unchanged (an old value, as the description says), or the
     buffer pointer the list holds *)
  assert (OLD60 : forall v, Mem.load Mint32 m' bo (base_o + 60) = Some v -> val_old gp v).
  { intros v Lv.
    destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L60)
      as (LD60 & SK60).
    destruct FT0 as [(U0 & _ & _) | (_ & EX)].
    - assert (IB60 := sload_inb _ _ _ _ _ _ _ _ L60).
      destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh IB60) as (_ & _ & Q60).
      unfold addr in Q60. change (size_chunk Mint32) with 4 in Q60.
      assert (NW : forall i, base_o + 60 <= i < base_o + 60 + size_chunk Mint32 ->
                 ~ Wl (e_blk E rl) (e_blk E rbuf) (e_blk E riom) (e_blk E rmq) (e_blk E rrm) bo i).
      { intros i Hi Wi. change (size_chunk Mint32) with 4 in Hi.
        assert (DJ : forall rc szc, (rc = rl \/ In rc (sma_cls rbuf riom rmq rrm)) -> r0_size R0 rc = Some szc ->
                  e_base E rc = Ptrofs.zero -> bo <> e_blk E rc \/ szc <= base_o).
        { intros rc szc Hrc Szc Bz.
          assert (NE' : ro <> rc).
          { intros ->. assert (X : existsb (Pos.eqb rc) (rl :: sma_cls rbuf riom rmq rrm) = true)
              by (apply existsb_exists; exists rc; split; [destruct Hrc as [-> | Hrc]; [left; reflexivity | right; exact Hrc] | apply Pos.eqb_refl]).
            congruence. }
          destruct (inb_spec nbase R0 _ _ _ _ IB60) as [(Lo & szo & Szo & O1 & O2) | (NPo & INo & _)].
          - destruct (A3 _ _ _ _ Szo Szc NE') as [B | [B | B]]; [left; exact B | |];
              rewrite Bz in B; change (Ptrofs.unsigned Ptrofs.zero) with 0 in B;
              change (size_chunk Mint32) with 4 in O2; unfold base_o; lia.
          - left. intros Eb. pose proof MMh as (_ & _ & _ & _ & _ & _ & _ & LOC & _).
            destruct (LOC ro INo) as (_ & _ & _ & NP & _).
            destruct (A2 rc szc Szc) as (Lc & _).
            pose proof (A1 rc Lc) as Gc. destruct (gp (e_blk E rc)) as [x|] eqn:Gx; [| congruence].
            apply NP. unfold bo in Eb. rewrite Eb. exact (gp_old _ _ Gx). }
        unfold Wl, Wd, SZ_IOMESG, SZ_MESGQ in Wi.
        destruct Wi as [[Wi | [Wi | [Wi | Wi]]] | Wi]; destruct Wi as [Eb Wi].
        - destruct (DJ rbuf _ ltac:(right; left; reflexivity) Sb Bb) as [X | X]; [congruence | lia].
        - destruct (DJ riom _ ltac:(right; right; left; reflexivity) Si Bi) as [X | X]; [congruence | lia].
        - destruct (DJ rmq _ ltac:(right; right; right; left; reflexivity) Sq Bq) as [X | X]; [congruence | lia].
        - destruct (DJ rrm _ ltac:(right; right; right; right; left; reflexivity) Sr Br) as [X | X]; [congruence | lia].
        - destruct (DJ rl _ ltac:(left; reflexivity) Szl Bl) as [X | X]; [congruence |].
          change (size_chunk Mint16signed) with 2 in Ol. lia. }
      rewrite (Mem.load_unchanged_on_1 _ m m' Mint32 bo (base_o + 60) U0) in Lv;
        [ | exact (inb_valid nbase R0 G gtab kv m0 uf gp gp_old _ _ _ _ _ _ MMh IB60) | exact NW ].
      unfold addr in LD60. unfold bo, base_o in Lv. rewrite <- Z.add_assoc, LD60 in Lv.
      eapply den_old; try exact EO; try exact (sok_dold nbase _ _ SK60 NL60); try exact Lv; try exact m0_closed; try exact gp_old.
    - unfold sma_extra in EX. destruct EX as [EX _]. change Mptr with Mint32 in EX. rewrite UO in EX. fold base_o in EX.
      unfold bo in Lv. rewrite EX in Lv. injection Lv as <-. cbn.
      destruct (A2 _ _ Sb) as (Lb & _). exact (A1 _ Lb). }
  assert (M1 : MM E1 m g2).
  { unfold E1, g2. apply (updw_MM_old G nbase R0 gtab kv m0 uf gp).
    - exact (MM_gcl G nbase R0 gtab kv m0 uf gp _ _ _ _ MMh).
    - intros d ch Iw v Lv.
      destruct Iw as [E' | [E' | [E' | [E' | [E' | [E' | []]]]]]]; injection E' as <- <-;
        try (match type of Lv with Mem.load ?c _ _ ?z = Some _ => apply (np_load_old gp c m' bo z v); [reflexivity | exact Lv] end).
      exact (OLD60 v Lv). }
  assert (M2 : MM E2 m g3).
  { unfold E2, g3. apply (updw_MM G nbase R0 gtab kv m0 uf gp); [exact M1 | exact ws_lst_np]. }
  assert (RX : Rx E E2 (g_nx g)).
  { eapply Rx_trans; [| | exact P12]; [ unfold E1; apply updw_Rx | unfold E2; apply updw_Rx ]. }
  (* every cell the footprint may change is a written cell or a clobbered region *)
  assert (HD : forall b z ch, Mem.valid_block m b ->
            (forall k, In k l -> cell_disj E2 (skey k) b z ch) ->
            (forall rc, In rc (sma_cls rbuf riom rmq rrm) -> rng_disj R0 E2 rc b z ch) ->
            Mem.load ch m' b z = Mem.load ch m b z).
  { intros b z ch V D C. unfold SZ_IOMESG, SZ_MESGQ in *.
    assert (KO : forall d c, In (d, c) ws_obj ->
              bo <> b \/ base_o + d + size_chunk c <= z \/ z + size_chunk ch <= base_o + d).
    { intros d c Hd. destruct (wentries_has ro (Ptrofs.unsigned oo) ws_obj (g_nx g1) d c Hd) as (k & Ik).
      pose proof (D _ (in_or_app _ _ _ (or_introl Ik))) as X. cbn [skey cell_disj] in X.
      unfold addr in X. rewrite EB, EBs in X.
      unfold bo, base_o. lia. }
    assert (KL : forall d, In (d, Mint16signed) ws_lst ->
              e_blk E rl <> b \/ d + 2 <= z \/ z + size_chunk ch <= d).
    { intros d Hd. destruct (wentries_has rl 0 ws_lst (g_nx g2) d Mint16signed Hd) as (k & Ik).
      pose proof (D _ (in_or_app _ _ _ (or_intror Ik))) as X. cbn [skey cell_disj] in X.
      unfold addr in X. rewrite EB, EBs, Bl in X. change (size_chunk Mint16signed) with 2 in X.
      change (Ptrofs.unsigned Ptrofs.zero) with 0 in X. lia. }
    assert (KC : forall rc sz, In rc (sma_cls rbuf riom rmq rrm) -> r0_size R0 rc = Some sz ->
              e_base E rc = Ptrofs.zero ->
              e_blk E rc <> b \/ sz <= z \/ z + size_chunk ch <= 0).
    { intros rc sz Ic Sz Bz. pose proof (C rc Ic) as X. unfold rng_disj in X. rewrite Sz, EB, EBs, Bz in X.
      exact X. }
    pose proof (size_chunk_pos ch).
    eapply Mem.load_unchanged_on_1; [exact U | exact V |].
    intros i Hi Wi. unfold Wa, Wl, Wd, AIc, SZ_IOMESG, SZ_MESGQ in Wi.
    destruct Wi as [[[Wi | [Wi | [Wi | Wi]]] | Wi] | Wi].
    - destruct Wi as [-> Wi]. destruct (KC rbuf _ ltac:(left; reflexivity) Sb Bb) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi]. destruct (KC riom _ ltac:(right; left; reflexivity) Si Bi) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi]. destruct (KC rmq _ ltac:(right; right; left; reflexivity) Sq Bq) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi]. destruct (KC rrm _ ltac:(right; right; right; left; reflexivity) Sr Br) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi].
      destruct (KL 4 ltac:(left; reflexivity)) as [X | X]; [congruence |].
      destruct (KL 6 ltac:(right; left; reflexivity)) as [Y | Y]; [congruence | lia].
    - destruct Wi as [-> Wi]. rewrite UO in Wi. fold base_o in Wi. unfold bo in KO.
      destruct (KO 56 _ ltac:(left; reflexivity)) as [X1 | X1]; [congruence |].
      destruct (KO 58 _ ltac:(do 1 right; left; reflexivity)) as [X2 | X2]; [congruence |].
      destruct (KO 60 _ ltac:(do 2 right; left; reflexivity)) as [X3 | X3]; [congruence |].
      destruct (KO 64 _ ltac:(do 3 right; left; reflexivity)) as [X5 | X5]; [congruence |].
      destruct (KO 72 _ ltac:(do 4 right; left; reflexivity)) as [X6 | X6]; [congruence |].
      destruct (KO 74 _ ltac:(do 5 right; left; reflexivity)) as [X7 | X7]; [congruence |].
      cbn [size_chunk] in X1, X2, X3, X5, X6, X7. lia. }
  (* what each written cell now holds *)
  assert (HL : forall r o ch sv, In (r, o, ch, sv) l ->
            sok nbase (g_nx g3) sv /\ Mem.load ch m' (e_blk E2 r) (addr E2 r o) = den G m0 E2 sv).
  { intros r0 o ch sv I. apply in_app_iff in I as [I | I].
    - destruct (wentries_in ro _ ws_obj (g_nx g1) g1 _ eq_refl I) as (d & ch' & k & Eq & Iw & K1 & K2).
      injection Eq as -> -> <- ->. fold g2 in K2.
      split; [cbn; split; [eapply Plt_Ple_trans; [exact K2 | exact P23] | exact Logic.I] |].
      cbn [SymExec2.den]. unfold addr. rewrite EB, EBs. unfold E2. rewrite updw_other by exact K2.
      unfold E1. rewrite (updw_den bo base_o m' ws_obj E (g_nx g1) _ ro d ch k I ws_obj_nd).
      f_equal. unfold base_o. lia.
    - destruct (wentries_in rl 0 ws_lst (g_nx g2) g2 _ eq_refl I) as (d & ch' & k & Eq & Iw & K1 & K2).
      injection Eq as -> -> <- ->. fold g3 in K2.
      split; [cbn; split; [exact K2 | exact Logic.I] |].
      cbn [SymExec2.den]. unfold addr. rewrite EB, EBs, Bl.
      unfold E2. rewrite (updw_den (e_blk E rl) 0 m' ws_lst E1 (g_nx g2) _ rl d ch k I ws_lst_nd).
      reflexivity. }
  assert (CLS : forall rc, In rc (sma_cls rbuf riom rmq rrm) -> In rc (g_cl g3) /\ exists sz, r0_size R0 rc = Some sz).
  { intros rc Ic. split.
    - unfold g3, g2. rewrite (proj1 (proj2 (proj2 (proj2 (freshn_meta _ _))))), (proj1 (proj2 (proj2 (proj2 (freshn_meta _ _))))).
      cbn [gcl g_cl]. apply in_or_app. left. exact Ic.
    - destruct Ic as [<- | [<- | [<- | [<- | []]]]]; eauto. }
  assert (NCL : forall e, In e (g_sm g3) -> ~ In (sreg e) (sma_cls rbuf riom rmq rrm)).
  { intros e Ie Ic. unfold g3, g2 in Ie. rewrite (proj1 (freshn_meta _ _)), (proj1 (freshn_meta _ _)) in Ie.
    cbn [gcl g_sm] in Ie. pose proof (proj1 (forallb_forall _ _) NCLb e Ie) as X.
    apply negb_true_iff in X.
    assert (Y : existsb (Pos.eqb (sreg e)) (sma_cls rbuf riom rmq rrm) = true)
      by (apply existsb_exists; exists (sreg e); split; [exact Ic | apply Pos.eqb_refl]).
    congruence. }
  destruct (sstores_havoc_cl G nbase R0 gtab kv m0 uf gp gp_old (sma_cls rbuf riom rmq rrm) E2 m g3 l g' m'
              M2 CLS NCL S HL HD ltac:(rewrite NBm; apply Ple_refl) ltac:(intros b o k p _; apply PP))
    as (M' & NXg & LCg & _).
  assert (VO : val_old gp vres) by (destruct vres; cbn; auto; exfalso; exact (NPr _ _ eq_refl)).
  destruct (fresh_cm G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E2 m' g' vres M' VO)
    as (E3 & X3 & M3 & D3 & SK3 & PL3 & LC3).
  exists (gfresh g', Sfresh (g_nx g')). split; [left; reflexivity |].
  exists E3. split; [| split; [exact M3 | split; [exact D3 | split; [exact SK3 | split]]]].
  - eapply Ext_trans; [exact (Rx_Ext _ _ _ RX) | exact X3 |].
    rewrite NXg. eapply Ple_trans; [exact P12 | exact P23].
  - eapply Ple_trans; [| exact PL3]. rewrite NXg. eapply Ple_trans; [exact P12 | exact P23].
  - rewrite LC3, LCg. exact LC1.
Qed.
(* THE CONTRACT for set_mario_anim_with_accel is sound *)
Theorem c_smawa_sound : forall args g cps E m vargs t m' vres,
  c_smawa nbase R0 gtab kv rl rbuf riom rmq rrm kB args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m (Internal mario.f_set_mario_anim_with_accel) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_smawa in Hc.
  destruct args as [| a1 rest]; [discriminate Hc |].
  destruct a1 as [ | rm om | | | | | | | | ]; try discriminate Hc.
  destruct (sload nbase R0 kv g rm (Ptrofs.unsigned om + 160) Mint32) as [s1 |] eqn:L1; [| discriminate Hc].
  destruct (sload nbase R0 kv g rm (Ptrofs.unsigned om + 136) Mint32) as [s2 |] eqn:L2;
    [| destruct s1; discriminate Hc].
  destruct (sload nbase R0 kv g rl 8 Mint32) as [s3 |] eqn:L3;
    [| destruct s1, s2; discriminate Hc].
  destruct s1 as [ | rl' zl | | | | | | | | ]; try discriminate Hc.
  destruct s2 as [ | ro oo | | | | | | | | ]; try discriminate Hc.
  destruct (sload nbase R0 kv g ro (Ptrofs.unsigned oo + 60) Mint32) as [s60 |] eqn:L60; [| discriminate Hc].
  destruct (sma_static_ok R0 gtab rl rbuf riom rmq rrm && Pos.eqb rl' rl && Ptrofs.eq zl Ptrofs.zero
            && negb (loc_ptr nbase s60) && negb (existsb (Pos.eqb ro) (rl :: sma_cls rbuf riom rmq rrm))
            && existsb (is_buf_fact rbuf kB s3) (g_pc g)
            && forallb (fun e => negb (existsb (Pos.eqb (sreg e)) (sma_cls rbuf riom rmq rrm))) (g_sm g))
    eqn:CK; [| discriminate Hc].
  set (g1 := gcl (sma_cls rbuf riom rmq rrm) g) in Hc.
  set (g2 := freshn (length ws_obj2) g1) in Hc.
  set (g3 := freshn (length ws_lst) g2) in Hc.
  set (l := wentries ro (Ptrofs.unsigned oo) (g_nx g1) ws_obj2 ++ wentries rl 0 (g_nx g2) ws_lst) in Hc.
  destruct (sstores nbase R0 g3 l) as [g' |] eqn:S; [| discriminate Hc].
  injection Hc as <-.
  apply andb_true_iff in CK as [CK NCLb]. apply andb_true_iff in CK as [CK Hbf].
  apply andb_true_iff in CK as [CK NRO]. apply andb_true_iff in CK as [CK NL60].
  apply andb_true_iff in CK as [CK Ezl].
  apply negb_true_iff in NL60, NRO.
  apply andb_true_iff in CK as [ST Erl].
  apply Pos.eqb_eq in Erl. subst rl'.
  pose proof (Ptrofs.eq_spec zl Ptrofs.zero) as Zl. rewrite Ezl in Zl. subst zl.
  unfold sma_static_ok in ST.
  destruct (gfind gtab mario._gMarioAnimsBuf) as [a |] eqn:Ga; [| discriminate ST].
  destruct (gfind gtab memory._gDmaIoMesg) as [i |] eqn:Gi; [| discriminate ST].
  destruct (gfind gtab memory._gDmaMesgQueue) as [q |] eqn:Gq; [| discriminate ST].
  destruct (gfind gtab memory._gMainReceivedMesg) as [r |] eqn:Gr; [| discriminate ST].
  destruct (r0_size R0 rbuf) as [sb |] eqn:Sb; [| discriminate ST].
  destruct (r0_size R0 riom) as [si |] eqn:Si; [| discriminate ST].
  destruct (r0_size R0 rmq) as [sq |] eqn:Sq; [| discriminate ST].
  destruct (r0_size R0 rrm) as [sr |] eqn:Sr; [| discriminate ST].
  repeat rewrite andb_true_iff in ST.
  destruct ST as [[[[[[[[Ea Ei] Eq] Er] Esb] Esi] Esq] Esr] NE].
  apply Pos.eqb_eq in Ea, Ei, Eq, Er. apply Z.eqb_eq in Esb, Esi, Esq, Esr. subst a i q r sb si sq sr.
  apply negb_true_iff in NE. apply Pos.eqb_neq in NE.
  pose proof MMh as (EO & _). pose proof EO as (A1 & A2 & A3 & A4 & _).
  destruct (A4 _ _ Ga) as (Plt_rl & Bl & Hab).
  destruct (A4 _ _ Gi) as (_ & Bi & Hiom).
  destruct (A4 _ _ Gq) as (_ & Bq & Hmq).
  destruct (A4 _ _ Gr) as (_ & Br & Hrm).
  assert (Bb : e_base E rbuf = Ptrofs.zero) by (apply base_full; exact (proj2 (proj2 (A2 _ _ Sb)))).
  (* the buffer pointer, from the path fact *)
  apply existsb_exists in Hbf as (f & If & Hf).
  destruct f as [ | | | k fargs]; cbn [is_buf_fact] in Hf; try discriminate Hf.
  destruct fargs as [| a [| sp [| ]]]; try (cbv iota in Hf; discriminate Hf); try (destruct sp; discriminate Hf).
  destruct sp as [ | rb ob | | | | | | | | ]; try (cbv iota in Hf; discriminate Hf).
  repeat rewrite andb_true_iff in Hf. destruct Hf as [[[Ek Ea3] Erb] Eob].
  apply Pos.eqb_eq in Ek, Erb. subst k rb.
  unfold sbeq in Ea3. destruct (sval_eq a s3) as [-> |]; [| discriminate Ea3].
  pose proof (Ptrofs.eq_spec ob Ptrofs.zero) as Zob. rewrite Eob in Zob. subst ob.
  pose proof MMh as (_ & _ & _ & _ & _ & _ & PCh & _).
  destruct (PCh _ If) as [_ FH]. cbn [fact_holds map] in FH.
  destruct (HUB _ FH) as (bb & ot & o2 & Evs & Hot).
  cbn [SymExec2.den] in Evs. injection Evs as Dbuf Ebb _. subst bb.
  (* the arguments *)
  inversion HF as [| a v rest' vrest [Dp _] HF']; subst.
  cbn [SymExec2.den] in Dp. injection Dp as <-.
  destruct (funcall_three_args _ mario.f_set_mario_anim_with_accel _ _ _ _ _ _ _ _ _ _ _ _ eq_refl Hev) as (v2 & v3 & ->).
  (* the states *)
  assert (LC1 : g_loc g3 = g_loc g).
  { unfold g3, g2. rewrite (proj1 (proj2 (proj2 (freshn_meta _ _)))), (proj1 (proj2 (proj2 (freshn_meta _ _)))). reflexivity. }
  assert (NX12 : g_nx g1 = g_nx g) by reflexivity.
  assert (P12 : Ple (g_nx g1) (g_nx g2)) by exact (proj2 (proj2 (proj2 (proj2 (freshn_meta _ _))))).
  assert (P23 : Ple (g_nx g2) (g_nx g3)) by exact (proj2 (proj2 (proj2 (proj2 (freshn_meta _ _))))).
  assert (IB : forall k, In k l -> inb nbase R0 g (fst (fst (fst k))) (snd (fst (fst k))) (snd (fst k)) = true).
  { intros [[[r1 o1] ch1] sv1] Ik. pose proof (sstores_inb _ _ _ _ _ _ S Ik) as X. cbn [skey] in X.
    rewrite (inb_loc nbase R0 g g3) in X by exact LC1. exact X. }
  (* the three loads, as the footprint theorem wants them *)
  destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L1) as (LD1 & _).
  destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L2) as (LD2 & _).
  destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L3) as (LD3 & _).
  destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh (sload_inb _ _ _ _ _ _ _ _ L1)) as (_ & Q1 & Q1').
  destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh (sload_inb _ _ _ _ _ _ _ _ L2)) as (_ & Q2 & Q2').
  unfold addr in Q1, Q1', Q2, Q2'.
  pose proof (Ptrofs.unsigned_range (e_base E rm)). pose proof (Ptrofs.unsigned_range om).
  pose proof (Ptrofs.unsigned_range (e_base E ro)). pose proof (Ptrofs.unsigned_range oo).
  change (size_chunk Mint32) with 4 in Q1', Q2'.
  assert (UM : Ptrofs.unsigned (Ptrofs.add (e_base E rm) om) = Ptrofs.unsigned (e_base E rm) + Ptrofs.unsigned om)
    by (apply uadd2; lia).
  assert (Hal : Mem.loadv Mptr m (Vptr (e_blk E rm) (Ptrofs.add (Ptrofs.add (e_base E rm) om) (Ptrofs.repr 160)))
                = Some (Vptr (e_blk E rl) Ptrofs.zero)).
  { cbn [Mem.loadv]. rewrite uadd_small by lia. rewrite UM.
    cbn [SymExec2.den] in LD1. rewrite Bl, Ptrofs.add_zero in LD1. unfold addr in LD1.
    rewrite <- LD1. f_equal. lia. }
  assert (Hmo : Mem.loadv Mptr m (Vptr (e_blk E rm) (Ptrofs.add (Ptrofs.add (e_base E rm) om) (Ptrofs.repr 136)))
                = Some (Vptr (e_blk E ro) (Ptrofs.add (e_base E ro) oo))).
  { cbn [Mem.loadv]. rewrite uadd_small by lia. rewrite UM.
    cbn [SymExec2.den] in LD2. unfold addr in LD2. rewrite <- LD2. f_equal. lia. }
  assert (Hbuf : Mem.load Mptr m (e_blk E rl) 8 = Some (Vptr (e_blk E rbuf) ot)).
  { unfold addr in LD3. rewrite Bl in LD3. rewrite Dbuf in LD3. exact LD3. }
  (* the list region has a size; the buffer is another block *)
  assert (Ilst : In (rl, 0 + 6, Mint16signed, Sfresh (Pos.succ (g_nx g2))) l).
  { apply in_or_app. right. right. left. reflexivity. }
  destruct (inb_spec nbase R0 _ _ _ _ (IB _ Ilst)) as [(_ & szl & Szl & _ & Ol) | (NP & _)]; [| contradiction]; cbn [fst snd] in Szl, Ol.
  assert (Hbt_ab : e_blk E rbuf <> e_blk E rl).
  { destruct (A3 _ _ _ _ Sb Szl NE) as [B | [B | B]]; [exact B | |]; rewrite ?Bb, ?Bl in B; change (Ptrofs.unsigned Ptrofs.zero) with 0 in B; pose proof Ptrofs.modulus_pos;
      change (size_chunk Mint16signed) with 2 in Ol; lia. }
  (* the object window fits *)
  assert (Iob : In (ro, Ptrofs.unsigned oo + 74, Mint16signed,
                    Sfresh (Pos.succ (Pos.succ (Pos.succ (Pos.succ (Pos.succ (Pos.succ (Pos.succ (Pos.succ (g_nx g1)))))))))) l).
  { apply in_or_app. left. do 8 right. left. reflexivity. }
  destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh (IB _ Iob)) as (_ & _ & Q3).
  cbn [fst snd] in Q3. unfold addr in Q3. change (size_chunk Mint16signed) with 2 in Q3.
  assert (UO : Ptrofs.unsigned (Ptrofs.add (e_base E ro) oo) = Ptrofs.unsigned (e_base E ro) + Ptrofs.unsigned oo)
    by (apply uadd2; lia).
  assert (Hoo : Ptrofs.unsigned (Ptrofs.add (e_base E ro) oo) + 76 <= Ptrofs.modulus) by lia.
  (* THE FOOTPRINT *)
  destruct (smaa_foot lp Hlink Hfloor (e_blk E rl) (e_blk E rbuf) (e_blk E riom) (e_blk E rmq) (e_blk E rrm) ot
              Hab Hiom Hmq Hrm m (e_blk E rm) (Ptrofs.add (e_base E rm) om)
              (e_blk E ro) (Ptrofs.add (e_base E ro) oo) Hal Hmo Hbuf Hbt_ab Hot Hoo v2 v3 t m' vres Hev)
    as (NPr & FT0).
  assert (FT : foot (Wa2 (e_blk E rl) (e_blk E rbuf) (e_blk E riom) (e_blk E rmq) (e_blk E rrm)
                        (e_blk E ro) (Ptrofs.add (e_base E ro) oo)) m m').
  { destruct FT0 as [F | (F & _)]; [| exact F]. eapply foot_mono; [| exact F].
    intros b z [W | (Eb & Wz)]; [left; exact W | right; split; [exact Eb | lia]]. }
  destruct FT as (U & NBm & PP).
  (* the fresh names *)
  set (bo := e_blk E ro). set (base_o := Ptrofs.unsigned (e_base E ro) + Ptrofs.unsigned oo).
  set (E1 := updw bo base_o m' E (g_nx g1) ws_obj2).
  set (E2 := updw (e_blk E rl) 0 m' E1 (g_nx g2) ws_lst).
  destruct (updw_blk bo base_o m' ws_obj2 E (g_nx g1)) as (EB1 & EBs1).
  destruct (updw_blk (e_blk E rl) 0 m' ws_lst E1 (g_nx g2)) as (EB2 & EBs2).
  fold E1 in EB1, EBs1. fold E2 in EB2, EBs2.
  assert (EB : e_blk E2 = e_blk E) by congruence.
  assert (EBs : e_base E2 = e_base E) by congruence.
  (* curAnim: unchanged (an old value, as the description says), or the
     buffer pointer the list holds *)
  assert (OLD60 : forall v, Mem.load Mint32 m' bo (base_o + 60) = Some v -> val_old gp v).
  { intros v Lv.
    destruct (sload_sound G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old _ _ _ _ _ _ _ MMh L60)
      as (LD60 & SK60).
    destruct FT0 as [(U0 & _ & _) | (_ & EX)].
    - assert (IB60 := sload_inb _ _ _ _ _ _ _ _ L60).
      destruct (inb_abs G nbase R0 gtab kv m0 uf gp _ _ _ _ _ _ MMh IB60) as (_ & _ & Q60).
      unfold addr in Q60. change (size_chunk Mint32) with 4 in Q60.
      assert (NW : forall i, base_o + 60 <= i < base_o + 60 + size_chunk Mint32 ->
                 ~ Wl72 (e_blk E rl) (e_blk E rbuf) (e_blk E riom) (e_blk E rmq) (e_blk E rrm)
                     bo (Ptrofs.add (e_base E ro) oo) bo i).
      { intros i Hi Wi0. change (size_chunk Mint32) with 4 in Hi.
        destruct Wi0 as [Wi | (_ & Wi)];
          [ | rewrite UO in Wi; fold base_o in Wi; lia ].
        assert (DJ : forall rc szc, (rc = rl \/ In rc (sma_cls rbuf riom rmq rrm)) -> r0_size R0 rc = Some szc ->
                  e_base E rc = Ptrofs.zero -> bo <> e_blk E rc \/ szc <= base_o).
        { intros rc szc Hrc Szc Bz.
          assert (NE' : ro <> rc).
          { intros ->. assert (X : existsb (Pos.eqb rc) (rl :: sma_cls rbuf riom rmq rrm) = true)
              by (apply existsb_exists; exists rc; split; [destruct Hrc as [-> | Hrc]; [left; reflexivity | right; exact Hrc] | apply Pos.eqb_refl]).
            congruence. }
          destruct (inb_spec nbase R0 _ _ _ _ IB60) as [(Lo & szo & Szo & O1 & O2) | (NPo & INo & _)].
          - destruct (A3 _ _ _ _ Szo Szc NE') as [B | [B | B]]; [left; exact B | |];
              rewrite Bz in B; change (Ptrofs.unsigned Ptrofs.zero) with 0 in B;
              change (size_chunk Mint32) with 4 in O2; unfold base_o; lia.
          - left. intros Eb. pose proof MMh as (_ & _ & _ & _ & _ & _ & _ & LOC & _).
            destruct (LOC ro INo) as (_ & _ & _ & NP & _).
            destruct (A2 rc szc Szc) as (Lc & _).
            pose proof (A1 rc Lc) as Gc. destruct (gp (e_blk E rc)) as [x|] eqn:Gx; [| congruence].
            apply NP. unfold bo in Eb. rewrite Eb. exact (gp_old _ _ Gx). }
        unfold Wl, Wd, SZ_IOMESG, SZ_MESGQ in Wi.
        destruct Wi as [[Wi | [Wi | [Wi | Wi]]] | Wi]; destruct Wi as [Eb Wi].
        - destruct (DJ rbuf _ ltac:(right; left; reflexivity) Sb Bb) as [X | X]; [congruence | lia].
        - destruct (DJ riom _ ltac:(right; right; left; reflexivity) Si Bi) as [X | X]; [congruence | lia].
        - destruct (DJ rmq _ ltac:(right; right; right; left; reflexivity) Sq Bq) as [X | X]; [congruence | lia].
        - destruct (DJ rrm _ ltac:(right; right; right; right; left; reflexivity) Sr Br) as [X | X]; [congruence | lia].
        - destruct (DJ rl _ ltac:(left; reflexivity) Szl Bl) as [X | X]; [congruence |].
          change (size_chunk Mint16signed) with 2 in Ol. lia. }
      rewrite (Mem.load_unchanged_on_1 _ m m' Mint32 bo (base_o + 60) U0) in Lv;
        [ | exact (inb_valid nbase R0 G gtab kv m0 uf gp gp_old _ _ _ _ _ _ MMh IB60) | exact NW ].
      unfold addr in LD60. unfold bo, base_o in Lv. rewrite <- Z.add_assoc, LD60 in Lv.
      eapply den_old; try exact EO; try exact (sok_dold nbase _ _ SK60 NL60); try exact Lv; try exact m0_closed; try exact gp_old.
    - unfold smaa_extra in EX. change Mptr with Mint32 in EX. rewrite UO in EX. fold base_o in EX.
      unfold bo in Lv. rewrite EX in Lv. injection Lv as <-. cbn.
      destruct (A2 _ _ Sb) as (Lb & _). exact (A1 _ Lb). }
  assert (M1 : MM E1 m g2).
  { unfold E1, g2. apply (updw_MM_old G nbase R0 gtab kv m0 uf gp).
    - exact (MM_gcl G nbase R0 gtab kv m0 uf gp _ _ _ _ MMh).
    - intros d ch Iw v Lv.
      destruct Iw as [E' | [E' | [E' | [E' | [E' | [E' | [E' | [E' | [E' | []]]]]]]]]]; injection E' as <- <-;
        try (match type of Lv with Mem.load ?c _ _ ?z = Some _ => apply (np_load_old gp c m' bo z v); [reflexivity | exact Lv] end).
      exact (OLD60 v Lv). }
  assert (M2 : MM E2 m g3).
  { unfold E2, g3. apply (updw_MM G nbase R0 gtab kv m0 uf gp); [exact M1 | exact ws_lst_np]. }
  assert (RX : Rx E E2 (g_nx g)).
  { eapply Rx_trans; [| | exact P12]; [ unfold E1; apply updw_Rx | unfold E2; apply updw_Rx ]. }
  (* every cell the footprint may change is a written cell or a clobbered region *)
  assert (HD : forall b z ch, Mem.valid_block m b ->
            (forall k, In k l -> cell_disj E2 (skey k) b z ch) ->
            (forall rc, In rc (sma_cls rbuf riom rmq rrm) -> rng_disj R0 E2 rc b z ch) ->
            Mem.load ch m' b z = Mem.load ch m b z).
  { intros b z ch V D C. unfold SZ_IOMESG, SZ_MESGQ in *.
    assert (KO : forall d c, In (d, c) ws_obj2 ->
              bo <> b \/ base_o + d + size_chunk c <= z \/ z + size_chunk ch <= base_o + d).
    { intros d c Hd. destruct (wentries_has ro (Ptrofs.unsigned oo) ws_obj2 (g_nx g1) d c Hd) as (k & Ik).
      pose proof (D _ (in_or_app _ _ _ (or_introl Ik))) as X. cbn [skey cell_disj] in X.
      unfold addr in X. rewrite EB, EBs in X.
      unfold bo, base_o. lia. }
    assert (KL : forall d, In (d, Mint16signed) ws_lst ->
              e_blk E rl <> b \/ d + 2 <= z \/ z + size_chunk ch <= d).
    { intros d Hd. destruct (wentries_has rl 0 ws_lst (g_nx g2) d Mint16signed Hd) as (k & Ik).
      pose proof (D _ (in_or_app _ _ _ (or_intror Ik))) as X. cbn [skey cell_disj] in X.
      unfold addr in X. rewrite EB, EBs, Bl in X. change (size_chunk Mint16signed) with 2 in X.
      change (Ptrofs.unsigned Ptrofs.zero) with 0 in X. lia. }
    assert (KC : forall rc sz, In rc (sma_cls rbuf riom rmq rrm) -> r0_size R0 rc = Some sz ->
              e_base E rc = Ptrofs.zero ->
              e_blk E rc <> b \/ sz <= z \/ z + size_chunk ch <= 0).
    { intros rc sz Ic Sz Bz. pose proof (C rc Ic) as X. unfold rng_disj in X. rewrite Sz, EB, EBs, Bz in X.
      exact X. }
    pose proof (size_chunk_pos ch).
    eapply Mem.load_unchanged_on_1; [exact U | exact V |].
    intros i Hi Wi. unfold Wa2, Wl, Wd, AIc2, SZ_IOMESG, SZ_MESGQ in Wi.
    destruct Wi as [[[Wi | [Wi | [Wi | Wi]]] | Wi] | Wi].
    - destruct Wi as [-> Wi]. destruct (KC rbuf _ ltac:(left; reflexivity) Sb Bb) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi]. destruct (KC riom _ ltac:(right; left; reflexivity) Si Bi) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi]. destruct (KC rmq _ ltac:(right; right; left; reflexivity) Sq Bq) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi]. destruct (KC rrm _ ltac:(right; right; right; left; reflexivity) Sr Br) as [X | X]; [congruence | lia].
    - destruct Wi as [-> Wi].
      destruct (KL 4 ltac:(left; reflexivity)) as [X | X]; [congruence |].
      destruct (KL 6 ltac:(right; left; reflexivity)) as [Y | Y]; [congruence | lia].
    - destruct Wi as [-> Wi]. rewrite UO in Wi. fold base_o in Wi. unfold bo in KO.
      destruct (KO 56 _ ltac:(left; reflexivity)) as [X1 | X1]; [congruence |].
      destruct (KO 58 _ ltac:(do 1 right; left; reflexivity)) as [X2 | X2]; [congruence |].
      destruct (KO 60 _ ltac:(do 2 right; left; reflexivity)) as [X3 | X3]; [congruence |].
      destruct (KO 64 _ ltac:(do 3 right; left; reflexivity)) as [X5 | X5]; [congruence |].
      destruct (KO 66 _ ltac:(do 4 right; left; reflexivity)) as [X4 | X4]; [congruence |].
      destruct (KO 68 _ ltac:(do 5 right; left; reflexivity)) as [X8 | X8]; [congruence |].
      destruct (KO 70 _ ltac:(do 6 right; left; reflexivity)) as [X9 | X9]; [congruence |].
      destruct (KO 72 _ ltac:(do 7 right; left; reflexivity)) as [X6 | X6]; [congruence |].
      destruct (KO 74 _ ltac:(do 8 right; left; reflexivity)) as [X7 | X7]; [congruence |].
      cbn [size_chunk] in X1, X2, X3, X4, X5, X6, X7, X8, X9. lia. }
  (* what each written cell now holds *)
  assert (HL : forall r o ch sv, In (r, o, ch, sv) l ->
            sok nbase (g_nx g3) sv /\ Mem.load ch m' (e_blk E2 r) (addr E2 r o) = den G m0 E2 sv).
  { intros r0 o ch sv I. apply in_app_iff in I as [I | I].
    - destruct (wentries_in ro _ ws_obj2 (g_nx g1) g1 _ eq_refl I) as (d & ch' & k & Eq & Iw & K1 & K2).
      injection Eq as -> -> <- ->. fold g2 in K2.
      split; [cbn; split; [eapply Plt_Ple_trans; [exact K2 | exact P23] | exact Logic.I] |].
      cbn [SymExec2.den]. unfold addr. rewrite EB, EBs. unfold E2. rewrite updw_other by exact K2.
      unfold E1. rewrite (updw_den bo base_o m' ws_obj2 E (g_nx g1) _ ro d ch k I ws_obj2_nd).
      f_equal. unfold base_o. lia.
    - destruct (wentries_in rl 0 ws_lst (g_nx g2) g2 _ eq_refl I) as (d & ch' & k & Eq & Iw & K1 & K2).
      injection Eq as -> -> <- ->. fold g3 in K2.
      split; [cbn; split; [exact K2 | exact Logic.I] |].
      cbn [SymExec2.den]. unfold addr. rewrite EB, EBs, Bl.
      unfold E2. rewrite (updw_den (e_blk E rl) 0 m' ws_lst E1 (g_nx g2) _ rl d ch k I ws_lst_nd).
      reflexivity. }
  assert (CLS : forall rc, In rc (sma_cls rbuf riom rmq rrm) -> In rc (g_cl g3) /\ exists sz, r0_size R0 rc = Some sz).
  { intros rc Ic. split.
    - unfold g3, g2. rewrite (proj1 (proj2 (proj2 (proj2 (freshn_meta _ _))))), (proj1 (proj2 (proj2 (proj2 (freshn_meta _ _))))).
      cbn [gcl g_cl]. apply in_or_app. left. exact Ic.
    - destruct Ic as [<- | [<- | [<- | [<- | []]]]]; eauto. }
  assert (NCL : forall e, In e (g_sm g3) -> ~ In (sreg e) (sma_cls rbuf riom rmq rrm)).
  { intros e Ie Ic. unfold g3, g2 in Ie. rewrite (proj1 (freshn_meta _ _)), (proj1 (freshn_meta _ _)) in Ie.
    cbn [gcl g_sm] in Ie. pose proof (proj1 (forallb_forall _ _) NCLb e Ie) as X.
    apply negb_true_iff in X.
    assert (Y : existsb (Pos.eqb (sreg e)) (sma_cls rbuf riom rmq rrm) = true)
      by (apply existsb_exists; exists (sreg e); split; [exact Ic | apply Pos.eqb_refl]).
    congruence. }
  destruct (sstores_havoc_cl G nbase R0 gtab kv m0 uf gp gp_old (sma_cls rbuf riom rmq rrm) E2 m g3 l g' m'
              M2 CLS NCL S HL HD ltac:(rewrite NBm; apply Ple_refl) ltac:(intros b o k p _; apply PP))
    as (M' & NXg & LCg & _).
  assert (VO : val_old gp vres) by (destruct vres; cbn; auto; exfalso; exact (NPr _ _ eq_refl)).
  destruct (fresh_cm G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E2 m' g' vres M' VO)
    as (E3 & X3 & M3 & D3 & SK3 & PL3 & LC3).
  exists (gfresh g', Sfresh (g_nx g')). split; [left; reflexivity |].
  exists E3. split; [| split; [exact M3 | split; [exact D3 | split; [exact SK3 | split]]]].
  - eapply Ext_trans; [exact (Rx_Ext _ _ _ RX) | exact X3 |].
    rewrite NXg. eapply Ple_trans; [exact P12 | exact P23].
  - eapply Ple_trans; [| exact PL3]. rewrite NXg. eapply Ple_trans; [exact P12 | exact P23].
  - rewrite LC3, LCg. exact LC1.
Qed.
End SND.
