(* ====================================================================== *)
(* DmaXc (GOAL 2): the executor's contract for the REAL dma_read when it  *)
(* copies Mario's animation data, PROVED SOUND from its generated body    *)
(* (DmaContent.dma_read_content: the loop walked to the DMA floor, TRUST  *)
(* 3.5, with the floor's content clause pi_dma_anim_spec, TRUST 0.8(f)).  *)
(*                                                                        *)
(* c_dma answers dma_read(&buffer, &gMarioAnims + a, &gMarioAnims + e)    *)
(* when                                                                   *)
(*   - the buffer region rbuf is BUFSZ bytes, and a path fact             *)
(*     Fuser kBUF [&buffer] says it is no global's block, readable,      *)
(*     4-aligned and below the top of the address space;                  *)
(*   - a path fact Fuser kGA [&gMarioAnims] says gMarioAnims' cells      *)
(*     (AnimData.ga_cells) hold their values at the frame start, and     *)
(*     Fworld facts say every cell copied is still the frame start's;   *)
(*   - a is 4-aligned and the rounded size n fits both blocks.            *)
(* Afterwards the buffer region and the three DMA globals are clobbered,  *)
(* and then the buffer holds every ga_cells cell of [a, a + n) at its     *)
(* offset - a, as the constant it is in gMarioAnims.  The result is a    *)
(* fresh value (in fact Vundef).                                          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Memdata Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario memory game_init.
From SM64.Proofs Require Import Interp.SymExec2 MarioModel.LinkedTwelve MarioModel.RealFrameLinked
  MarioModel.OsDmaFloor WMotRRequiresA.WallExec WMotRRequiresA.SmaXc
  WMotRRequiresA.DmaContent WMotRRequiresA.AnimData WMotRRequiresA.AnimWorld.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

(* ---------------------------------------------------------------------- *)
(* Dropping and clobbering whole regions                                  *)
(* ---------------------------------------------------------------------- *)

Definition gdrop (cls : list positive) (g : gst) : gst :=
  mkg (filter (fun e => negb (existsb (Pos.eqb (sreg e)) cls)) (g_sm g))
      (g_pc g) (g_nx g) (g_loc g) (cls ++ g_cl g).

Section DROP.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Local Notation MM := (MMg ge nbase R0 gtab kv m0 uf gp).

(* forgetting the entries of sized regions, and clobbering them, keeps
   the description *)
Lemma MM_gdrop : forall cls E m g, MM E m g ->
  (forall rc, In rc cls -> exists sz, r0_size R0 rc = Some sz) -> MM E m (gdrop cls g).
Proof.
  intros cls E m g MMh CS. pose proof MMh as (EO & NB & ENT & FR & VP & NX & PC & LOC & LINJ).
  pose proof EO as (A1 & A2 & _).
  unfold gdrop, MMg; cbn [g_sm g_pc g_nx g_loc g_cl].
  split; [exact EO | split; [exact NB | split; [| split; [| split; [exact VP | split; [exact NX | split; [exact PC | split; [exact LOC | exact LINJ]]]]]]]].
  - intros r o ch sv I. apply filter_In in I as [I _]. destruct (ENT r o ch sv I) as (IB & SK & L).
    split; [rewrite <- IB; apply inb_loc; reflexivity | auto].
  - intros b z ch OLD D CLD. apply FR; [exact OLD | | intros r I; apply CLD; apply in_or_app; right; exact I].
    intros e Ie.
    destruct (existsb (Pos.eqb (sreg e)) cls) eqn:X.
    + apply existsb_exists in X as (rc & Ic & Erc). apply Pos.eqb_eq in Erc.
      destruct (CS rc Ic) as (sz & Sz).
      pose proof (CLD rc (in_or_app _ _ _ (or_introl Ic))) as RD. unfold rng_disj in RD. rewrite Sz in RD.
      destruct e as [[[r o] ch'] sv]. cbn [sreg fst] in Erc. subst rc.
      destruct (ENT r o ch' sv Ie) as (IB & _).
      destruct (inb_spec nbase R0 _ _ _ _ IB) as [(L & sz' & Sz' & O1 & O2) | (NP & _)].
      * rewrite Sz in Sz'. injection Sz' as <-. cbn [skey cell_disj]. unfold addr.
        pose proof (size_chunk_pos ch'). lia.
      * exfalso. exact (NP (proj1 (A2 _ _ Sz))).
    + apply D. apply filter_In. split; [exact Ie | rewrite X; reflexivity].
Qed.
End DROP.

(* ---------------------------------------------------------------------- *)
(* The contract                                                           *)
(* ---------------------------------------------------------------------- *)

(* a path fact Fuser k [&region r] *)
Definition is_ufact (k r : positive) (f : fact) : bool :=
  match f with
  | Fuser k' [Sptr r' o] => Pos.eqb k' k && Pos.eqb r' r && Ptrofs.eq o Ptrofs.zero
  | _ => false
  end.

Lemma is_ufact_spec : forall k r f, is_ufact k r f = true -> f = Fuser k [Sptr r Ptrofs.zero].
Proof.
  intros k r f H. destruct f as [| | | k' a]; try discriminate H.
  destruct a as [| s [| x a]]; [discriminate H | | destruct s; discriminate H].
  destruct s; try discriminate H.
  cbn [is_ufact] in H. repeat rewrite andb_true_iff in H. destruct H as [[E1 E2] E3].
  apply Pos.eqb_eq in E1, E2. pose proof (Ptrofs.eq_spec ofs Ptrofs.zero) as Z0. rewrite E3 in Z0.
  subst. reflexivity.
Qed.

Section CDMA.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variables rbuf riom rmq rrm rga kBUF kGA : positive.
Variable cells : list (Z * memory_chunk * Z).   (* AnimData.ga_cells *)

Definition dma_cls : list positive := [rbuf; riom; rmq; rrm].

Definition dma_static_ok : bool :=
  match gfind gtab game_init._gMarioAnims, gfind gtab memory._gDmaIoMesg,
        gfind gtab memory._gDmaMesgQueue, gfind gtab memory._gMainReceivedMesg,
        r0_size R0 rbuf, r0_size R0 riom, r0_size R0 rmq, r0_size R0 rrm with
  | Some a, Some i, Some q, Some r, Some sb, Some si, Some sq, Some sr =>
      Pos.eqb a rga && Pos.eqb i riom && Pos.eqb q rmq && Pos.eqb r rrm
      && Z.eqb sb BUFSZ && Z.eqb si SZ_IOMESG && Z.eqb sq SZ_MESGQ && Z.eqb sr 4
  | _, _, _, _, _, _, _, _ => false
  end.

(* the cells of gMarioAnims a copy of [off, off + n) carries *)
(* (the cell list is a parameter, not AnimData.ga_cells itself: a kernel
   conversion that unfolds filter over the concrete 270-cell list takes
   time exponential in its length) *)
Definition dsel (off n : Z) (x : Z * memory_chunk * Z) : bool :=
  let '(o, ch, _) := x in (off <=? o) && (o + size_chunk ch <=? off + n).
Definition dcells (off n : Z) : list (Z * memory_chunk * Z) := filter (dsel off n) cells.
Definition dent (off : Z) (x : Z * memory_chunk * Z) : sentry :=
  let '(o, ch, z) := x in (rbuf, o - off, ch, Sconst (Vint (Int.repr z))).
Definition dentries (off : Z) (cs : list (Z * memory_chunk * Z)) : list sentry := map (dent off) cs.
(* the source cell is the frame start's, and its chunk's alignment divides 4 *)
Definition cell_src_ok (pc : list fact) (x : Z * memory_chunk * Z) : bool :=
  let '(o, ch, _) := x in
  world_ok pc (Sptr rga Ptrofs.zero) o ch && Z.eqb (Z.modulo 4 (align_chunk ch)) 0.

(* the contract for a list cs of copied cells (c_dma passes dcells) *)
Definition c_dma_k (rb : positive) (ob : ptrofs) (ra : positive) (oa : ptrofs) (ra' : positive) (oe : ptrofs)
    (g : gst) (cs : list (Z * memory_chunk * Z)) : option (list cpath) :=
  if dma_static_ok && Pos.eqb rb rbuf && Ptrofs.eq ob Ptrofs.zero && Pos.eqb ra rga && Pos.eqb ra' rga
     && existsb (is_ufact kBUF rbuf) (g_pc g) && existsb (is_ufact kGA rga) (g_pc g)
     && Z.eqb (Z.modulo (Ptrofs.unsigned oa) 4) 0
     && (Int.unsigned (dma_n oa oe) <=? BUFSZ)
     && (Ptrofs.unsigned oa + Int.unsigned (dma_n oa oe) <=? GA_SIZE)
     && forallb (cell_src_ok (g_pc g)) cs
  then match sstores nbase R0 (gdrop dma_cls g) (dentries (Ptrofs.unsigned oa) cs) with
       | Some g' => Some [(gfresh g', Sfresh (g_nx g'))]
       | None => None
       end
  else None.

Definition c_dma : xcontract := fun args g =>
  match args with
  | [Sptr rb ob; Sptr ra oa; Sptr ra' oe] =>
      c_dma_k rb ob ra oa ra' oe g (dcells (Ptrofs.unsigned oa) (Int.unsigned (dma_n oa oe)))
  | _ => None
  end.
End CDMA.

Lemma dcells_in : forall cells off n o ch z, In (o, ch, z) (dcells cells off n) ->
  In (o, ch, z) cells /\ off <= o /\ o + size_chunk ch <= off + n.
Proof.
  intros cells off n o ch z H.
  destruct (proj1 (filter_In (dsel off n) (o, ch, z) cells) H) as [Ig Rg].
  unfold dsel in Rg.
  apply andb_true_iff in Rg as [R1 R2]. apply Z.leb_le in R1, R2.
  split; [exact Ig | split; [exact R1 | exact R2]].
Qed.

Lemma dentries_in : forall rb off cs r o ch sv, In (r, o, ch, sv) (dentries rb off cs) ->
  exists o0 z0, In (o0, ch, z0) cs /\ r = rb /\ o = o0 - off /\ sv = Sconst (Vint (Int.repr z0)).
Proof.
  intros rb off cs r o ch sv I. unfold dentries in I.
  apply in_map_iff in I as ([[o0 ch0] z0] & Ex & Ic).
  unfold dent in Ex. injection Ex as <- <- <- <-. exists o0, z0. auto.
Qed.

(* ---------------------------------------------------------------------- *)
(* Byte copies carry loads                                                *)
(* ---------------------------------------------------------------------- *)

Lemma getN_shift : forall k p q c c',
  (forall i, 0 <= i < Z.of_nat k -> ZMap.get (p + i) c = ZMap.get (q + i) c') ->
  Mem.getN k p c = Mem.getN k q c'.
Proof.
  induction k as [| k IH]; intros p q c c' H; cbn [Mem.getN]; [reflexivity |].
  f_equal.
  - specialize (H 0). rewrite !Z.add_0_r in H. apply H. lia.
  - apply IH. intros i Hi.
    replace (p + 1 + i) with (p + (1 + i)) by lia. replace (q + 1 + i) with (q + (1 + i)) by lia.
    apply H. lia.
Qed.

Local Transparent Mem.loadbytes.
Lemma load_copy : forall ch m m' b z b' z' v,
  Mem.load ch m b z = Some v ->
  Mem.range_perm m' b' z' (z' + size_chunk ch) Cur Readable ->
  (align_chunk ch | z') ->
  (forall i, 0 <= i < size_chunk ch -> cont m' b' (z' + i) = cont m b (z + i)) ->
  Mem.load ch m' b' z' = Some v.
Proof.
  intros ch m m' b z b' z' v L P A C.
  destruct (Mem.load_loadbytes _ _ _ _ _ L) as (bytes & LB & ->).
  apply Mem.loadbytes_load; [| exact A].
  unfold Mem.loadbytes in *.
  destruct (Mem.range_perm_dec m b z (z + size_chunk ch) Cur Readable); [| discriminate LB].
  injection LB as <-.
  destruct (Mem.range_perm_dec m' b' z' (z' + size_chunk ch) Cur Readable); [| contradiction].
  f_equal. apply getN_shift. intros i Hi.
  rewrite Z2Nat.id in Hi by (pose proof (size_chunk_pos ch); lia).
  exact (C i Hi).
Qed.
Local Opaque Mem.loadbytes.

Lemma divide_4 : forall a, Z.modulo 4 a = 0 -> a > 0 -> (a | 4).
Proof. intros a H P. apply Z.mod_divide; lia. Qed.

(* ---------------------------------------------------------------------- *)
(* Soundness                                                              *)
(* ---------------------------------------------------------------------- *)

Section SND.
Variable lp : Clight.program.
Hypothesis Hlink : linked12 lp.
Hypothesis Hfloor : os_dma_floor.
Hypothesis Hanim : pi_dma_anim_spec.
Local Notation G := (globalenv lp).
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables rbuf riom rmq rrm rga kBUF kGA : positive.
Variable cells : list (Z * memory_chunk * Z).
(* the facts' meanings *)
Hypothesis HUBUF : forall vs, uf kBUF vs -> exists b o, vs = [Some (Vptr b o)]
  /\ (forall id b', Genv.find_symbol G id = Some b' -> b' <> b)
  /\ Mem.range_perm m0 b (Ptrofs.unsigned o) (Ptrofs.unsigned o + BUFSZ) Cur Readable
  /\ Z.modulo (Ptrofs.unsigned o) 4 = 0 /\ Ptrofs.unsigned o + BUFSZ < Ptrofs.modulus.
Hypothesis HUGA : forall vs, uf kGA vs -> exists b, vs = [Some (Vptr b Ptrofs.zero)]
  /\ forall o ch z, In (o, ch, z) cells -> Mem.load ch m0 b o = Some (Vint (Int.repr z)).

Local Notation MM := (MMg G nbase R0 gtab kv m0 uf gp).

Lemma mod32 : Ptrofs.modulus = 4294967296.
Proof. reflexivity. Qed.

(* the contract for any list of copied cells within the copy *)
Lemma c_dma_k_sound : forall rb ob ra oa ra' oe g cs cps E m vargs t m' vres,
  (forall o ch z, In (o, ch, z) cs -> In (o, ch, z) cells /\ Ptrofs.unsigned oa <= o
     /\ o + size_chunk ch <= Ptrofs.unsigned oa + Int.unsigned (dma_n oa oe)) ->
  c_dma_k nbase R0 gtab rbuf riom rmq rrm rga kBUF kGA rb ob ra oa ra' oe g cs = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok nbase (g_nx g) a)
    [Sptr rb ob; Sptr ra oa; Sptr ra' oe] vargs ->
  eval_funcall function_entry2 G m (Internal memory.f_dma_read) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros rb ob ra oa ra' oe g cs cps E m vargs t m' vres CSI Hc MMh HF Hev.
  unfold c_dma_k in Hc.
  match type of Hc with (if ?b then _ else _) = _ => destruct b eqn:CK; [| discriminate Hc] end.
  match type of Hc with (match ?x with _ => _ end) = _ => destruct x as [g' |] eqn:S; [| discriminate Hc] end.
  injection Hc as <-.
  repeat rewrite andb_true_iff in CK.
  destruct CK as [[[[[[[[[[ST Erb] Eob] Era] Era'] FB] FG] OM] NBf] NG] CSo].
  unfold dma_static_ok in ST.
  destruct (gfind gtab game_init._gMarioAnims) as [a |] eqn:Ga; [| discriminate ST].
  destruct (gfind gtab memory._gDmaIoMesg) as [i |] eqn:Gi; [| discriminate ST].
  destruct (gfind gtab memory._gDmaMesgQueue) as [q |] eqn:Gq; [| discriminate ST].
  destruct (gfind gtab memory._gMainReceivedMesg) as [r |] eqn:Gr; [| discriminate ST].
  destruct (r0_size R0 rbuf) as [sb |] eqn:Sb; [| discriminate ST].
  destruct (r0_size R0 riom) as [si |] eqn:Si; [| discriminate ST].
  destruct (r0_size R0 rmq) as [sq |] eqn:Sq; [| discriminate ST].
  destruct (r0_size R0 rrm) as [sr |] eqn:Sr; [| discriminate ST].
  repeat rewrite andb_true_iff in ST.
  destruct ST as [[[[[[[Ea Ei] Eq] Er] Esb] Esi] Esq] Esr].
  apply Pos.eqb_eq in Ea, Ei, Eq, Er. apply Z.eqb_eq in Esb, Esi, Esq, Esr. subst a i q r sb si sq sr.
  apply Pos.eqb_eq in Erb, Era, Era'. subst rb ra ra'.
  pose proof (Ptrofs.eq_spec ob Ptrofs.zero) as Zob. rewrite Eob in Zob. subst ob.
  apply Z.eqb_eq in OM. apply Z.leb_le in NBf, NG.
  set (off := Ptrofs.unsigned oa) in *.
  set (n := Int.unsigned (dma_n oa oe)) in *.
  pose proof MMh as (EO & NBg & _ & _ & VP & NXm & PCh & _).
  pose proof EO as (A1 & A2 & A3 & A4 & _).
  destruct (A4 _ _ Ga) as (Lga & Bga & Hga).
  destruct (A4 _ _ Gi) as (_ & Bi & Hiom).
  destruct (A4 _ _ Gq) as (_ & Bq & Hmq).
  destruct (A4 _ _ Gr) as (_ & Br & Hrm).
  (* the facts *)
  apply existsb_exists in FB as (f1 & If1 & Hf1). apply is_ufact_spec in Hf1. subst f1.
  destruct (PCh _ If1) as [_ FH1]. cbn [fact_holds map SymExec2.den] in FH1.
  destruct (HUBUF _ FH1) as (bt & ot & Evs & NSb & Pb & Ab & Mb).
  injection Evs as <- <-. rewrite Ptrofs.add_zero in Pb, Ab, Mb.
  apply existsb_exists in FG as (f2 & If2 & Hf2). apply is_ufact_spec in Hf2. subst f2.
  destruct (PCh _ If2) as [_ FH2]. cbn [fact_holds map SymExec2.den] in FH2.
  destruct (HUGA _ FH2) as (bg & Evs2 & GAc).
  injection Evs2 as <- _.
  (* the arguments *)
  inversion HF as [| ? v1 ? vr1 [D1 _] HF1]; subst; clear HF.
  inversion HF1 as [| ? v2 ? vr2 [D2 _] HF2]; subst; clear HF1.
  inversion HF2 as [| ? v3 ? vr3 [D3 _] HF3]; subst; clear HF2.
  inversion HF3; subst; clear HF3.
  cbn [SymExec2.den] in D1, D2, D3. injection D1 as <-. injection D2 as <-. injection D3 as <-.
  rewrite Bga, Ptrofs.add_zero, !Ptrofs.add_zero_l in Hev.
  set (bt := e_blk E rbuf) in *. set (od := e_base E rbuf) in *. set (bga := e_blk E rga) in *.
  assert (OLDb : Plt bt (Mem.nextblock m0)).
  { apply (Mem.perm_valid_block m0 bt (Ptrofs.unsigned od) Cur Readable). apply Pb. unfold BUFSZ; lia. }
  assert (Pm : forall z, Ptrofs.unsigned od <= z < Ptrofs.unsigned od + BUFSZ -> Mem.perm m bt z Cur Readable).
  { intros z Hz. apply (proj2 (VP bt z Cur Readable OLDb)). apply Pb. exact Hz. }
  pose proof (Ptrofs.unsigned_range od) as Rod. pose proof (Ptrofs.unsigned_range oa) as Roa.
  assert (Rn : 0 <= n) by (unfold n; pose proof (Int.unsigned_range (dma_n oa oe)); lia).
  (* THE COPY *)
  destruct (dma_read_content lp Hlink Hfloor Hanim bga (e_blk E riom) (e_blk E rmq) (e_blk E rrm)
              Hga Hiom Hmq Hrm m bt od oa oe t m' vres Hev
              (fun X => NSb _ _ Hga (eq_sym X)) (fun X => NSb _ _ Hiom (eq_sym X))
              (fun X => NSb _ _ Hmq (eq_sym X)) (fun X => NSb _ _ Hrm (eq_sym X))
              ltac:(fold n; lia) ltac:(fold off n; rewrite mod32; unfold GA_SIZE in NG; lia)
              ltac:(fold n; intros z Hz; apply Pm; lia))
    as (-> & UO & (NBe & SP) & CT).
  fold n off in UO, CT.
  (* the clobbered state *)
  assert (CSZ : forall rc, In rc (dma_cls rbuf riom rmq rrm) -> exists sz, r0_size R0 rc = Some sz).
  { intros rc Ic. destruct Ic as [<- | [<- | [<- | [<- | []]]]]; eauto. }
  pose proof (MM_gdrop G nbase R0 gtab kv m0 uf gp _ E m g MMh CSZ) as M1.
  assert (HL : forall r o ch sv, In (r, o, ch, sv) (dentries rbuf off cs) ->
            sok nbase (g_nx (gdrop (dma_cls rbuf riom rmq rrm) g)) sv
            /\ Mem.load ch m' (e_blk E r) (addr E r o) = den G m0 E sv).
  { intros r0 o ch0 sv I. destruct (dentries_in _ _ _ _ _ _ _ I) as (o0 & z0 & Ic & -> & -> & ->).
    split; [split; [exact Logic.I | reflexivity] |].
    pose proof (proj1 (forallb_forall _ _) CSo _ Ic) as CO.
    destruct (CSI _ _ _ Ic) as (Ig & R1 & R2).
    cbn [cell_src_ok] in CO. apply andb_true_iff in CO as [WO AL]. apply Z.eqb_eq in AL.
    pose proof (size_chunk_pos ch0) as SP0.
    assert (Ro0 : 0 <= o0 /\ o0 + size_chunk ch0 <= GA_SIZE) by lia.
    assert (UR : Ptrofs.unsigned (Ptrofs.repr o0) = o0)
      by (apply Ptrofs.unsigned_repr; unfold Ptrofs.max_unsigned; rewrite mod32; unfold GA_SIZE in Ro0; lia).
    (* the source cell, at m: the frame start's *)
    assert (W : wload g (Sptr rga Ptrofs.zero) o0 ch0 = Some (Swld (Sptr rga Ptrofs.zero) o0 ch0)).
    { unfold wload. rewrite WO. reflexivity. }
    assert (Dq : den G m0 E (Sptr rga Ptrofs.zero) = Some (Vptr bga Ptrofs.zero))
      by (cbn [SymExec2.den]; rewrite Bga, Ptrofs.add_zero; reflexivity).
    assert (Skq : sok nbase (g_nx g) (Sptr rga Ptrofs.zero))
      by (split; [cbn; eapply Plt_Ple_trans; [exact Lga | exact NBg] | exact Logic.I]).
    destruct (wload_sound G nbase R0 gtab kv m0 uf gp E m g
                (Sptr rga Ptrofs.zero) o0 ch0 _ bga Ptrofs.zero MMh W Dq Skq Lga) as (LSm & _).
    cbn [SymExec2.den] in LSm. fold bga in LSm. rewrite Bga, Ptrofs.add_zero, !Ptrofs.add_zero_l, UR in LSm.
    rewrite (GAc _ _ _ Ig) in LSm.
    (* the copy *)
    cbn [SymExec2.den]. unfold addr. fold bt od.
    apply (load_copy ch0 m m' bga o0).
    - exact LSm.
    - intros zz Hz. apply (proj2 (SP bt zz Cur Readable)). apply Pm. unfold BUFSZ in NBf |- *. lia.
    - pose proof (Mem.load_valid_access _ _ _ _ _ LSm) as (_ & AL0).
      pose proof (align_chunk_pos ch0) as AP.
      assert (D4 : (align_chunk ch0 | 4)) by (apply divide_4; lia).
      apply Z.divide_add_r; [apply (Z.divide_trans _ 4); [exact D4 | apply Z.mod_divide; [lia | exact Ab]] |].
      apply Z.divide_sub_r; [exact AL0 |].
      apply (Z.divide_trans _ 4); [exact D4 | apply Z.mod_divide; [lia | exact OM]].
    - intros j Hj.
      replace (Ptrofs.unsigned od + (o0 - off) + j) with (Ptrofs.unsigned od + (o0 - off + j)) by lia.
      replace (o0 + j) with (off + (o0 - off + j)) by lia.
      apply CT; [lia |].
      replace (off + (o0 - off + j)) with (o0 + j) by lia.
      pose proof (Mem.load_valid_access _ _ _ _ _ LSm) as (RP & _). apply RP. lia. }
  (* everything else is unchanged *)
  assert (HD : forall b z ch, Mem.valid_block m b ->
            (forall k, In k (dentries rbuf off cs) -> cell_disj E (skey k) b z ch) ->
            (forall rc, In rc (dma_cls rbuf riom rmq rrm) -> rng_disj R0 E rc b z ch) ->
            Mem.load ch m' b z = Mem.load ch m b z).
  { intros b z ch V _ C. pose proof (size_chunk_pos ch).
    eapply Mem.load_unchanged_on_1; [exact UO | exact V |].
    intros i Hi.
    pose proof (C rbuf ltac:(left; reflexivity)) as C1.
    pose proof (C riom ltac:(right; left; reflexivity)) as C2.
    pose proof (C rmq ltac:(right; right; left; reflexivity)) as C3.
    pose proof (C rrm ltac:(right; right; right; left; reflexivity)) as C4.
    unfold rng_disj in C1, C2, C3, C4. rewrite Sb in C1. rewrite Si in C2. rewrite Sq in C3. rewrite Sr in C4.
    rewrite Bi in C2. rewrite Bq in C3. rewrite Br in C4. fold bt od in C1.
    unfold dfoot, outside, SZ_IOMESG, SZ_MESGQ, BUFSZ in *. rewrite !Ptrofs.unsigned_zero in *.
    split; [| split; [| split]].
    - destruct C1 as [C1 | [C1 | C1]];
        [left; intros X; exact (C1 (eq_sym X)) | right; clear -Hi C1 NBf; lia | right; clear -Hi C1; lia].
    - destruct C2 as [C2 | [C2 | C2]];
        [left; intros X; exact (C2 (eq_sym X)) | right; clear -Hi C2; lia | right; clear -Hi C2; lia].
    - destruct C3 as [C3 | [C3 | C3]];
        [left; intros X; exact (C3 (eq_sym X)) | right; clear -Hi C3; lia | right; clear -Hi C3; lia].
    - destruct C4 as [C4 | [C4 | C4]];
        [left; intros X; exact (C4 (eq_sym X)) | right; clear -Hi C4; lia | right; clear -Hi C4; lia]. }
  assert (CLS : forall rc, In rc (dma_cls rbuf riom rmq rrm) ->
            In rc (g_cl (gdrop (dma_cls rbuf riom rmq rrm) g)) /\ exists sz, r0_size R0 rc = Some sz).
  { intros rc Ic. split; [cbn [gdrop g_cl]; apply in_or_app; left; exact Ic | exact (CSZ rc Ic)]. }
  assert (NCL : forall e, In e (g_sm (gdrop (dma_cls rbuf riom rmq rrm) g)) ->
            ~ In (sreg e) (dma_cls rbuf riom rmq rrm)).
  { intros e Ie Ic. cbn [gdrop g_sm] in Ie. apply filter_In in Ie as [_ X]. apply negb_true_iff in X.
    assert (Y : existsb (Pos.eqb (sreg e)) (dma_cls rbuf riom rmq rrm) = true)
      by (apply existsb_exists; exists (sreg e); split; [exact Ic | apply Pos.eqb_refl]).
    congruence. }
  destruct (sstores_havoc_cl G nbase R0 gtab kv m0 uf gp gp_old (dma_cls rbuf riom rmq rrm) E m
              (gdrop (dma_cls rbuf riom rmq rrm) g) _ g' m' M1 CLS NCL S HL HD
              ltac:(rewrite NBe; apply Ple_refl) ltac:(intros b o k p _; apply SP))
    as (M' & NXg & LCg & _).
  destruct (fresh_cm G nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m' g' Vundef M' Logic.I)
    as (E3 & X3 & M3 & D3 & SK3 & PL3 & LC3).
  exists (gfresh g', Sfresh (g_nx g')). split; [left; reflexivity |].
  exists E3. split; [| split; [exact M3 | split; [exact D3 | split; [exact SK3 | split]]]].
  - rewrite NXg in X3. exact X3.
  - eapply Ple_trans; [| exact PL3]. rewrite NXg. apply Ple_refl.
  - rewrite LC3, LCg. reflexivity.
Qed.

(* THE CONTRACT for dma_read is sound *)
Theorem c_dma_sound : forall args g cps E m vargs t m' vres,
  c_dma nbase R0 gtab rbuf riom rmq rrm rga kBUF kGA cells args g = Some cps ->
  MM E m g ->
  Forall2 (fun a v => den G m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 G m (Internal memory.f_dma_read) vargs t m' vres ->
  exists c, In c cps /\ CM G nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros args g cps E m vargs t m' vres Hc MMh HF Hev.
  unfold c_dma in Hc.
  destruct args as [| a1 args]; [discriminate Hc |].
  destruct a1 as [ | rb ob | | | | | | | | ]; try discriminate Hc.
  destruct args as [| a2 args]; [discriminate Hc |].
  destruct a2 as [ | ra oa | | | | | | | | ]; try discriminate Hc.
  destruct args as [| a3 args]; [discriminate Hc |].
  destruct a3 as [ | ra' oe | | | | | | | | ]; try discriminate Hc.
  destruct args as [| a4 args]; [| discriminate Hc].
  exact (c_dma_k_sound rb ob ra oa ra' oe g _ cps E m vargs t m' vres
           (dcells_in cells (Ptrofs.unsigned oa) (Int.unsigned (dma_n oa oe))) Hc MMh HF Hev).
Qed.
End SND.
