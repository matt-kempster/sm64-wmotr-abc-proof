(* ====================================================================== *)
(* UnloadSi (GOAL 2 objects, 2026-11-06): the respawn OR of               *)
(* unload_deactivated_objects into a SpawnInfo behaviorArg cell of the    *)
(* main-pool block P (ObjWorld.SI_OFFS, below the node pool) keeps the    *)
(* object phase's invariant (ClearKeep.Pc): UnloadRows.si_row.            *)
(*                                                                        *)
(* The store changes P at one cell below NP_OFF; every other block keeps  *)
(* every load.  What reads P:                                             *)
(*   - the partition lists (Wff, floor_data, dp_lists, tab_apart): their  *)
(*     nodes are node-pool slots and their surfaces surface-pool slots of *)
(*     P (ObjWorld.surf_obj_ok), all at or past NP_OFF;                   *)
(*   - Mario's wall / ceiling / floor: off P or surface-pool slots        *)
(*     (ObjWorld.msurf_ok);                                               *)
(*   - the Camera's cutscene byte: the Camera is off the SI cells         *)
(*     (FfWorld.cam_si);                                                  *)
(*   - the frame's regions (Mario's object, the anim buffer, ...) and the *)
(*     anim table: none is P, since P holds a surface of a partition list *)
(*     and no region / table block does (Wff, tab_apart).                 *)
(* mem_ok by ClearKeep.safe_store_dyn.                                    *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  area camera.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import Generic.ClosedMem.
From SM64.Proofs Require Import HeightInvariant WMotRWorld NoAActions FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec FloorHeight AirMatch FfWorld
  AnimData AnimWorld RenderKeep.
From SM64.Proofs.WMotRRequiresA Require ObjWorld PollKeep PlatformKeep ClearKeep UnloadRows
  FfComplete AudioInv.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.

Notation u := Ptrofs.unsigned.

(* the SI cells lie under 2640 (and the node pool starts at NP_OFF = 2672) *)
Lemma si_low : forall zs, In zs OW.SI_OFFS -> 0 <= zs /\ zs + 4 <= 2640.
Proof.
  intros zs H. unfold OW.SI_OFFS in H. cbn [In] in H.
  repeat (destruct H as [<- | H]; [ lia | ]). destruct H.
Qed.

Lemma hi_np : forall o d, OW.in_np (u o) = true -> 0 <= d <= 8 -> 2640 <= u (Ptrofs.add o (Ptrofs.repr d)).
Proof.
  intros o d N Hd. destruct (OW.in_np_spec _ N) as (N1 & N2). pose proof OW.sp_end_small as Sm.
  rewrite OW.uadd_small by (unfold OW.NP_END, OW.SP_END, OW.NP_OFF, OW.NP_CAP, OW.SNODE_SZ, OW.SP_OFF,
                             OW.SP_CAP, OW.SURF_SZ in *; lia).
  unfold OW.NP_OFF in N1. lia.
Qed.

Lemma hi_sp : forall o d, OW.in_sp (u o) = true -> 0 <= d <= 48 -> 2640 <= u (Ptrofs.add o (Ptrofs.repr d)).
Proof.
  intros o d N Hd. destruct (OW.in_sp_spec _ N) as (N1 & N2). pose proof OW.sp_end_small as Sm.
  rewrite OW.uadd_small by (unfold OW.SP_END, OW.SP_OFF, OW.SP_CAP, OW.SURF_SZ in *; lia).
  unfold OW.SP_OFF in N1. lia.
Qed.

Lemma hi_sp0 : forall o, OW.in_sp (u o) = true -> 2640 <= u o.
Proof. intros o N. destruct (OW.in_sp_spec _ N) as (N1 & _). unfold OW.SP_OFF in N1. lia. Qed.

Section SI.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variables (P pool : block) (zs : Z) (i : int) (m m2 : mem).
  Hypothesis HP : Ple (Genv.genv_next G) P.
  Hypothesis Hzs : In zs OW.SI_OFFS.
  Hypothesis Hst : Mem.store Mint32 m P zs (Vint i) = Some m2.
  (* the surface clause of obj_w, at P *)
  Hypothesis HSW : forall id bp z hd, In id part_ids -> Genv.find_symbol G id = Some bp ->
    Mem.load Mint32 m bp z = Some hd ->
    exists l, OW.swalk P m OW.SFUEL hd = Some l /\ Forall (OW.surf_obj_at P pool m) l.

  Lemma LU : forall ch b z, b <> P -> Mem.load ch m2 b z = Mem.load ch m b z.
  Proof. intros ch b z N. eapply Mem.load_store_other; [ exact Hst | left; exact N ]. Qed.

  Lemma LHi : forall ch z, 2640 <= z -> Mem.load ch m2 P z = Mem.load ch m P z.
  Proof.
    intros ch z H. pose proof (si_low zs Hzs) as S.
    eapply Mem.load_store_other; [ exact Hst | right; right; cbn [size_chunk]; lia ].
  Qed.

  Lemma LG : forall ch b z, b <> P \/ 2640 <= z -> Mem.load ch m2 b z = Mem.load ch m b z.
  Proof.
    intros ch b z [N | H]; [ exact (LU ch b z N) | ].
    destruct (eq_block b P) as [-> | N]; [ exact (LHi ch z H) | exact (LU ch b z N) ].
  Qed.

  Lemma NB : Mem.nextblock m2 = Mem.nextblock m.
  Proof. exact (Mem.nextblock_store _ _ _ _ _ _ Hst). Qed.

  Lemma VB : forall b, Mem.valid_block m2 b <-> Mem.valid_block m b.
  Proof. intros b. unfold Mem.valid_block. rewrite NB. tauto. Qed.

  Lemma PM1 : forall b o k p, Mem.perm m b o k p -> Mem.perm m2 b o k p.
  Proof. intros b o k p H. exact (Mem.perm_store_1 _ _ _ _ _ _ Hst _ _ _ _ H). Qed.

  Lemma sym_ne : forall id b, Genv.find_symbol G id = Some b -> b <> P.
  Proof. intros id b Hs ->. pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Plt, Ple in *. lia. Qed.

  (* ---- the lists ---- *)
  Lemma swalk_eq : forall f v, OW.swalk P m2 f v = OW.swalk P m f v.
  Proof.
    apply OW.swalk_ext. intros ch z H1 _. apply LHi. unfold OW.NP_OFF in H1. lia.
  Qed.

  Ltac sw_open Hw :=
    cbn [OW.swalk] in Hw;
    match type of Hw with context [Pos.eqb ?bn P && OW.in_np (u ?on)] =>
      let E := fresh "E" in
      destruct (Pos.eqb bn P && OW.in_np (u on)) eqn:E; [ | discriminate Hw ];
      let E1 := fresh "E1" in let N := fresh "N" in
      apply andb_prop in E as [E1 N]; apply Pos.eqb_eq in E1; subst bn
    end.

  Lemma wf_tr : forall (A : block -> Prop) f hd l, OW.swalk P m f hd = Some l ->
    wf_list m A hd -> wf_list m2 A hd.
  Proof.
    intros A f. induction f as [| f IH]; intros hd l Hw W; [ discriminate Hw | ].
    destruct W as [| bn on nx Hv Ha Hl W]; [ constructor | ].
    sw_open Hw. rewrite !OW.CM.load_eq in Hw. cbn [Mem.loadv] in Hl. rewrite Hl in Hw.
    destruct (Mem.load Mint32 m P (u (Ptrofs.add on (Ptrofs.repr SN_SURF)))); [ | discriminate Hw ].
    destruct (OW.swalk P m f nx) as [l' |] eqn:Hw'; [ | discriminate Hw ].
    apply wf_cons with nx; [ apply VB; exact Hv | exact Ha | | exact (IH nx l' Hw' W) ].
    cbn [Mem.loadv]. rewrite LHi; [ exact Hl | apply hi_np; [ exact N | unfold SN_NEXT; lia ] ].
  Qed.

  Lemma ol_back : forall f hd l s, OW.swalk P m f hd = Some l -> on_list m2 hd s -> on_list m hd s.
  Proof.
    intros f. induction f as [| f IH]; intros hd l s Hw O; [ discriminate Hw | ].
    destruct O as [bn on s Hl | bn on nx s Hl O].
    - sw_open Hw. apply ol_here. cbn [Mem.loadv] in *.
      rewrite LHi in Hl; [ exact Hl | apply hi_np; [ exact N | unfold SN_SURF; lia ] ].
    - sw_open Hw. cbn [Mem.loadv] in Hl.
      rewrite LHi in Hl by (apply hi_np; [ exact N | unfold SN_NEXT; lia ]).
      rewrite !OW.CM.load_eq, Hl in Hw.
      destruct (Mem.load Mint32 m P (u (Ptrofs.add on (Ptrofs.repr SN_SURF)))); [ | discriminate Hw ].
      destruct (OW.swalk P m f nx) as [l' |] eqn:Hw'; [ | discriminate Hw ].
      apply ol_next with nx; [ exact Hl | exact (IH nx l' s Hw' O) ].
  Qed.

  Lemma ol_fwd : forall f hd l s, OW.swalk P m f hd = Some l -> on_list m hd s -> on_list m2 hd s.
  Proof.
    intros f. induction f as [| f IH]; intros hd l s Hw O; [ discriminate Hw | ].
    destruct O as [bn on s Hl | bn on nx s Hl O].
    - sw_open Hw. apply ol_here. cbn [Mem.loadv] in *.
      rewrite LHi; [ exact Hl | apply hi_np; [ exact N | unfold SN_SURF; lia ] ].
    - sw_open Hw. cbn [Mem.loadv] in Hl.
      rewrite !OW.CM.load_eq, Hl in Hw.
      destruct (Mem.load Mint32 m P (u (Ptrofs.add on (Ptrofs.repr SN_SURF)))); [ | discriminate Hw ].
      destruct (OW.swalk P m f nx) as [l' |] eqn:Hw'; [ | discriminate Hw ].
      apply ol_next with nx; [ | exact (IH nx l' s Hw' O) ].
      cbn [Mem.loadv]. rewrite LHi; [ exact Hl | apply hi_np; [ exact N | unfold SN_NEXT; lia ] ].
  Qed.

  Lemma ph_back : forall hd, part_head G m2 hd -> part_head G m hd.
  Proof.
    intros hd (id & bp & o & Hin & Hs & Hl). exists id, bp, o. split; [ exact Hin | split; [ exact Hs | ] ].
    cbn [Mem.loadv] in *. rewrite LU in Hl by exact (sym_ne _ _ Hs). exact Hl.
  Qed.

  Lemma ph_walk : forall hd, part_head G m hd ->
    exists l, OW.swalk P m OW.SFUEL hd = Some l /\ Forall (OW.surf_obj_at P pool m) l.
  Proof. intros hd (id & bp & o & Hin & Hs & Hl). exact (HSW id bp (u o) hd Hin Hs Hl). Qed.

  (* a surface on a partition list is a surface-pool slot of P *)
  Lemma ph_surf : forall hd s, part_head G m hd -> on_list m hd s ->
    exists o, s = Vptr P o /\ OW.in_sp (u o) = true.
  Proof.
    intros hd s H O. destruct (ph_walk hd H) as (l & Hw & Fa).
    pose proof (OW.swalk_on_list P m hd s O _ _ Hw) as Hin.
    destruct (proj1 (Forall_forall _ _) Fa s Hin) as (o & E & N & _). exists o. exact (conj E N).
  Qed.

  (* some partition list holds a surface (the death plane, dp_lists) *)
  Lemma some_surf : FfComplete.dp_lists G m -> exists hd o, part_head G m hd /\ on_list m hd (Vptr P o).
  Proof.
    intros D. destruct (D 0 0 ltac:(lia) ltac:(lia)) as (bp & hd & Hs & Hl & (s & O & _) & _).
    assert (Hph : part_head G m hd).
    { exists surface_collision._gStaticSurfacePartition, bp, (Ptrofs.repr (384 * 0 + 24 * 0)).
      split; [ cbn; auto | exact (conj Hs Hl) ]. }
    destruct (ph_surf hd s Hph O) as (o & -> & _). exists hd, o. exact (conj Hph O).
  Qed.

  (* so P is none of the world fact's regions *)
  Lemma P_not_reg : forall gp sz vs, Wff G m gp sz vs -> ~ rblk vs P.
  Proof.
    intros gp sz vs (W1 & W2 & W3 & W4 & W5 & W6 & W7 & W8).
    destruct (some_surf W8) as (hd & o & Hph & O).
    destruct (W4 hd (Vptr P o) Hph O) as (b & o' & E & _ & _ & Nr & _).
    injection E as <- _. exact Nr.
  Qed.

  (* ---- the frame's world fact and the floor data ---- *)
  Lemma Wff_si : forall gp vs, Wff G m gp SZ_SURFACE vs -> Wff G m2 gp SZ_SURFACE vs.
  Proof.
    intros gp vs W. pose proof W as (W1 & W2 & W3 & W4 & W5 & W6 & W7 & W8).
    assert (OB : forall hd s, part_head G m2 hd -> on_list m2 hd s -> part_head G m hd /\ on_list m hd s).
    { intros hd s H O. pose proof (ph_back hd H) as H0. split; [ exact H0 | ].
      destruct (ph_walk hd H0) as (l & Hw & _). exact (ol_back _ _ _ _ Hw O). }
    split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ] ].
    - intros id sz Hin. destruct (W1 id sz Hin) as (b & Hs & R). exists b. split; [ exact Hs | ].
      intros z Hz. exact (PM1 _ _ _ _ (R z Hz)).
    - intros id bp Hin Hs. rewrite NB. exact (W2 id bp Hin Hs).
    - intros hd H. pose proof (ph_back hd H) as H0. destruct (ph_walk hd H0) as (l & Hw & _).
      exact (wf_tr _ _ _ _ Hw (W3 hd H0)).
    - intros hd s H O. destruct (OB hd s H O) as (H0 & O0). rewrite NB. exact (W4 hd s H0 O0).
    - intros hd b o H O. destruct (OB hd _ H O) as (H0 & O0).
      destruct (W5 hd b o H0 O0) as (t & Lt & Ht).
      destruct (ph_surf hd _ H0 O0) as (o' & E & Ns). injection E as -> ->.
      exists t. rewrite LHi by exact (hi_sp0 o' Ns). exact (conj Lt Ht).
    - intros hd H. pose proof (ph_back hd H) as H0. destruct (ph_walk hd H0) as (l & Hw & _).
      destruct (W6 hd H0) as (Dw & Dp). split.
      + exact (wf_tr _ _ _ _ Hw Dw).
      + intros b o O. exact (Dp b o (ol_back _ _ _ _ Hw O)).
    - exact W7.
    - intros cz cx Hz Hx. destruct (W8 cz cx Hz Hx) as (bp & hd & Hs & Hl & (s1 & O1 & A1) & (s2 & O2 & A2)).
      assert (Hph : part_head G m hd).
      { exists surface_collision._gStaticSurfacePartition, bp, (Ptrofs.repr (384 * cz + 24 * cx)).
        split; [ cbn; auto | exact (conj Hs Hl) ]. }
      destruct (ph_walk hd Hph) as (l & Hw & _).
      exists bp, hd. split; [ exact Hs | split ].
      + cbn [Mem.loadv] in *. rewrite LU by exact (sym_ne _ _ Hs). exact Hl.
      + assert (DT : forall s x1 z1 x2 z2 x3 z3, on_list m hd s ->
                  FfComplete.dp_tri m s x1 z1 x2 z2 x3 z3 -> FfComplete.dp_tri m2 s x1 z1 x2 z2 x3 z3).
        { intros s x1 z1 x2 z2 x3 z3 O (bs & os & ty & fl & -> & R).
          destruct (ph_surf hd _ Hph O) as (o' & E & Ns). injection E as -> ->.
          exists P, o', ty, fl. split; [ reflexivity | ]. cbn [Mem.loadv] in *.
          rewrite !LHi by (apply hi_sp; [ exact Ns | lia ]). exact R. }
        split.
        * exists s1. exact (conj (ol_fwd _ _ _ _ Hw O1) (DT _ _ _ _ _ _ _ O1 A1)).
        * exists s2. exact (conj (ol_fwd _ _ _ _ Hw O2) (DT _ _ _ _ _ _ _ O2 A2)).
  Qed.

  Lemma floor_data_si : floor_data G m -> floor_data G m2.
  Proof.
    intros FD h (hd & s & xv & zv & Hh & O & Hit).
    assert (Hh0 : floor_head G m hd).
    { destruct Hh as (id & bp & z & x & Hin & Hs & Hz & Hx & Hl). exists id, bp, z, x.
      do 4 (split; [ assumption | ]). cbn [Mem.loadv] in *. rewrite LU in Hl by exact (sym_ne _ _ Hs). exact Hl. }
    pose proof (floor_head_part _ _ _ Hh0) as Hph.
    destruct (ph_walk hd Hph) as (l & Hw & _).
    pose proof (ol_back _ _ _ _ Hw O) as O0.
    apply FD. exists hd, s, xv, zv. split; [ exact Hh0 | split; [ exact O0 | ] ].
    destruct (ph_surf hd s Hph O0) as (o & -> & Ns).
    destruct Hit as ((bs & os & X & Z & x1 & z1 & x2 & z2 & x3 & z3 & nx & ny & nz & oo & Es & R) & S).
    injection Es as <- <-. split; [ | exact S ].
    exists P, o, X, Z, x1, z1, x2, z2, x3, z3, nx, ny, nz, oo. split; [ reflexivity | ].
    cbn [Mem.loadv] in R |- *. rewrite !LHi in R by (apply hi_sp; [ exact Ns | lia ]). exact R.
  Qed.

  Lemma closed_si : forall gp, closed_by gp m -> closed_by gp m2.
  Proof.
    intros gp HC. destruct (gp P) as [[b' d] |] eqn:E.
    - destruct (closed_flat _ _ _ _ _ HC E) as (-> & ->).
      exact (store_mapped_closed gp m Mint32 P zs (Vint i) m2 HC E (Val.inject_int _ _) Hst).
    - exact (store_private_closed gp m Mint32 P zs (Vint i) m2 HC E Hst).
  Qed.

  Lemma tab_apart_si : forall x, tab_apart G m x -> tab_apart G m2 x.
  Proof.
    intros x TA hd H. pose proof (ph_back hd H) as H0. destruct (ph_walk hd H0) as (l & Hw & _).
    destruct (TA hd H0) as (W & N). split; [ exact (wf_tr _ _ _ _ Hw W) | ].
    intros b o O. exact (N b o (ol_back _ _ _ _ Hw O)).
  Qed.

  Lemma tab_not_P : forall x, FfComplete.dp_lists G m -> tab_apart G m x -> x <> P.
  Proof.
    intros x D TA ->. destruct (some_surf D) as (hd & o & Hph & O).
    exact (proj2 (TA hd Hph) P o O eq_refl).
  Qed.

  (* ---- PhiW ---- *)
  Variable bm : block.
  Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Hypothesis Gsp : OW.gcell G surface_load._sSurfacePool Mint32 (Vptr P (Ptrofs.repr OW.SP_OFF)) m.

  Lemma Nbm : bm <> P.
  Proof. exact (sym_ne _ _ Hbm). Qed.

  Lemma LB : forall ch z, Mem.load ch m2 bm z = Mem.load ch m bm z.
  Proof. intros ch z. apply LU. exact Nbm. Qed.

  (* Mario's object and his collided objects are gObjectPool slots *)
  Lemma mobj_np : ffw G bm m -> forall mb mo, Mem.load Mint32 m bm 136 = Some (Vptr mb mo) ->
    mb <> P /\ forall i0 cb co, 0 <= i0 < 4 ->
      Mem.load Mint32 m mb (u mo + 120 + 4 * i0) = Some (Vptr cb co) -> cb <> P.
  Proof.
    intros (_ & (d & F) & _) mb mo Hl.
    pose proof (ff_Lo _ _ _ _ F) as Lo. change FFW_OBJ with 136 in Lo. rewrite Hl in Lo.
    injection Lo as Emb Emo.
    pose proof (sym_ne _ _ (ff_Spool _ _ _ _ F)) as N. rewrite <- Emb in N. split; [ exact N | ].
    intros i0 cb co Hi Hc. rewrite Emb, Emo in Hc. rewrite (ff_Co _ _ _ _ F i0 cb co Hi Hc), <- Emb. exact N.
  Qed.

  Lemma mobj_ex : ffw G bm m -> exists mb mo, Mem.load Mint32 m bm 136 = Some (Vptr mb mo) /\ mb <> P.
  Proof.
    intros Hf. pose proof Hf as (_ & (d & F) & _).
    pose proof (ff_Lo _ _ _ _ F) as Lo. change FFW_OBJ with 136 in Lo.
    exists (fw_bo d), (fw_oo d). split; [ exact Lo | exact (proj1 (mobj_np Hf _ _ Lo)) ].
  Qed.

  Lemma ffw_si : ffw G bm m -> ffw G bm m2.
  Proof.
    intros (Hgn & (d & F) & FD).
    assert (NR : ~ rblk (ff_rl_of bm d) P) by exact (P_not_reg _ _ _ (ff_W _ _ _ _ F)).
    assert (NRb : forall b, rblk (ff_rl_of bm d) b -> b <> P) by (intros b Hb ->; exact (NR Hb)).
    apply (ffw_rebuild G bm m m2 d (fw_gp d) F).
    - rewrite NB. exact Hgn.
    - rewrite NB. apply Ple_refl.
    - intros b H. exact H.
    - exact (closed_si _ (ff_HC _ _ _ _ F)).
    - exact (Wff_si _ _ (ff_W _ _ _ _ F)).
    - exact (floor_data_si FD).
    - intros ch b z Hr. apply LU. apply NRb.
      destruct Hr as [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]];
        first [ apply ffw_rl_bm | apply ffw_rl_bo | exists Ptrofs.zero; cbn; auto 20 ].
    - apply (ffw_surf_ok_kept G bm m m2 d F). intros z ch _. apply LB.
  Qed.

  Lemma anim_w_si : ffw G bm m -> AnimWorld.anim_w G bm m -> AnimWorld.anim_w G bm m2.
  Proof.
    intros Hf AW. pose proof Hf as (Hgn & (d & F) & FD).
    pose proof (Wff_dp _ _ _ _ _ (ff_W _ _ _ _ F)) as Dp.
    assert (NR : ~ rblk (ff_rl_of bm d) P) by exact (P_not_reg _ _ _ (ff_W _ _ _ _ F)).
    destruct AW as (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & ST).
    pose proof B as (Sab & Sga & Sau & L0 & L8 & Lm & Sy & E1 & E2 & E3 & E4 & (E5 & RG) & Z1 & Z2 & Z3
                     & PR & T & GA & TA & AC & Hbm').
    assert (Eab : fw_ab d = ab) by (pose proof (ff_S5 _ _ _ _ F); congruence).
    pose proof (ff_Lb _ _ _ _ F) as Lb. rewrite Eab, L8 in Lb. injection Lb as Ebt _.
    assert (Nbt : bt <> P) by (intros E; apply NR; rewrite <- E, Ebt; apply ffw_rl_bt).
    assert (Nmb : mb <> P) by exact (proj1 (mobj_np Hf mb mo Lm)).
    assert (Nab : ab <> P) by exact (sym_ne _ _ Sab).
    assert (Nga : bga <> P) by exact (sym_ne _ _ Sga).
    assert (Ntab : btab <> P) by exact (tab_not_P btab Dp TA).
    assert (B' : anim_base G bm m2 ab bga bauc btab otab bt ot mb mo).
    { refine (conj Sab (conj Sga (conj Sau (conj _ (conj _ (conj _ (conj Sy (conj E1 (conj E2 (conj E3 (conj E4
             (conj (conj E5 _) (conj Z1 (conj Z2 (conj Z3 (conj _ (conj _ (conj _ (conj _ (conj _ Hbm')))))))))))))))))))).
      - rewrite LU by exact Nab. exact L0.
      - rewrite LU by exact Nab. exact L8.
      - rewrite LB. exact Lm.
      - intros id b Hin Hs. destruct (RG id b Hin Hs) as (Ne & TAb). exact (conj Ne (tab_apart_si b TAb)).
      - intros z Hz. exact (PM1 _ _ _ _ (PR z Hz)).
      - destruct T as (T1 & T2 & T3). unfold tab_ok. rewrite !(LU _ btab) by exact Ntab.
        refine (conj T1 (conj T2 _)). intros j o s' Hj. rewrite !(LU _ btab) by exact Ntab. exact (T3 j o s' Hj).
      - destruct GA as (G1 & G2). split.
        + intros o ch z Hin. rewrite LU by exact Nga. exact (G1 o ch z Hin).
        + intros z Hz. exact (PM1 _ _ _ _ (G2 z Hz)).
      - exact (tab_apart_si btab TA).
      - intros off b o Hoff Hl. rewrite LB in Hl. exact (AC off b o Hoff Hl). }
    exists ab, bga, bauc, btab, otab, bt, ot, mb, mo. split; [ exact B' | ].
    intros a La Ia. rewrite LB in La.
    apply (anim_st_keep m m2 ab bga bt ot mb mo (ST a La Ia)).
    - apply LU. exact Nab.
    - intros o ch _. apply LU. exact Nmb.
    - intros k rel ch v _ _. apply LU. exact Nbt.
  Qed.

  Lemma hi_si : Mem.valid_block m bm -> ffw G bm m ->
    height_invariant bm R_noA m -> height_invariant bm R_noA m2.
  Proof.
    intros Vb Hf (Hs & c & (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8) & Hb). split.
    - eapply action_sat_unchanged_on; [ | exact Vb | exact Hs ].
      eapply Mem.store_unchanged_on; [ exact Hst | ]. intros z _ [E _]. exact (Nbm (eq_sym E)).
    - exists c. split; [ | exact Hb ].
      change Mptr with Mint32 in H7.
      destruct (mobj_np Hf bo oo H7) as (Nbo & _).
      unfold read_cells. rewrite !LB. do 6 (split; [ assumption | ]).
      exists bo, oo. change Mptr with Mint32. rewrite (LU _ bo) by exact Nbo. exact (conj H7 H8).
  Qed.

  Lemma aa_si : ffw G bm m -> anim_apart lp bm m -> anim_apart lp bm m2.
  Proof.
    intros Hf Han ab bt ot Hs Hl. rewrite LU in Hl by exact (sym_ne _ _ Hs).
    destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
    - intros off sb so Hoff Hl'. rewrite LB in Hl'. exact (A1 off sb so Hoff Hl').
    - intros mb mo i0 cb co Hl' Hi Hl2. rewrite LB in Hl'.
      destruct (mobj_np Hf mb mo Hl') as (Nmb & _). rewrite LU in Hl2 by exact Nmb.
      exact (A2 mb mo i0 cb co Hl' Hi Hl2).
  Qed.

  Lemma mo_si : ffw G bm m -> mobj_apart bm m -> mobj_apart bm m2.
  Proof.
    intros Hf Hmo mb mo Hl. rewrite LB in Hl.
    destruct (mobj_np Hf mb mo Hl) as (Nmb & _).
    destruct (Hmo mb mo Hl) as (P1 & P2 & P3). split; [ exact P1 | split ].
    - intros off sb so Hoff Hl'. rewrite LB in Hl'. exact (P2 off sb so Hoff Hl').
    - intros i0 cb co Hi Hl'. rewrite LU in Hl' by exact Nmb. exact (P3 i0 cb co Hi Hl').
  Qed.

  Lemma used_si : ffw G bm m -> used_ok bm m -> used_ok bm m2.
  Proof.
    intros Hf U a La. rewrite LB in La. destruct (U a La) as (U1 & U2).
    destruct (mobj_ex Hf) as (mb & mo & Lmo & Nmb).
    assert (LM : forall ch z, Mem.load ch m2 mb z = Mem.load ch m mb z) by (intros; apply LU; exact Nmb).
    assert (Ap : forall ub uo, used_apart bm m ub uo -> used_apart bm m2 ub uo).
    { intros ub uo (A1 & A2). split; [ exact A1 | ]. intros mb' mo' Hl. rewrite LB in Hl. exact (A2 mb' mo' Hl). }
    split.
    - intros Hp. destruct (U1 Hp) as (ub & uo & Lu & Lp & A & (S & PP) & V).
      destruct (PP mb mo Lmo) as (-> & _).
      exists mb, uo. split; [ rewrite LB; exact Lu | ].
      split; [ | split; [ exact (Ap _ _ A) | split ] ].
      + destruct Lp as (base & top & Hin & Ht & P1 & P2 & P3). exists base, top. rewrite !LM. auto.
      + split; [ exact S | ]. intros mb' mo' Hl. rewrite LB in Hl. change MARIOOBJ_OFF with 136 in Hl. rewrite Lmo in Hl. injection Hl as <- <-.
        destruct (PP mb mo Lmo) as (E & p & Lp2 & Fp & Rp). split; [ exact E | ].
        exists p. rewrite LM. exact (conj Lp2 (conj Fp Rp)).
      + intros w Lv. rewrite LB in Lv. exact (V w Lv).
    - intros Hcn. destruct (U2 Hcn) as (ub & uo & Lu & (y & Hin & P1) & A & (S & CP)).
      destruct (CP mb mo Lmo) as (-> & _).
      exists mb, uo. split; [ rewrite LB; exact Lu | ].
      split; [ exists y; rewrite LM; exact (conj Hin P1) | split; [ exact (Ap _ _ A) | ] ].
      split; [ exact S | ]. intros mb' mo' Hl. rewrite LB in Hl. change MARIOOBJ_OFF with 136 in Hl. rewrite Lmo in Hl. injection Hl as <- <-.
      destruct (CP mb mo Lmo) as (E & CC). split; [ exact E | ].
      intros i0 cb co Hi Hl2. rewrite LM in Hl2. exact (CC i0 cb co Hi Hl2).
  Qed.

  Lemma surf_tr : forall z v, OW.msurf_ok G bm m -> In z OW.MSURF -> Mem.load Mint32 m bm z = Some v ->
    forall b o, v = Vptr b o -> forall ch, Mem.load ch m2 b (u o) = Mem.load ch m b (u o).
  Proof.
    intros z v MS Hz Hl b o -> ch. destruct (MS z _ Hz Hl) as [E | (b' & o' & E & Hb)]; [ discriminate E | ].
    injection E as <- <-. apply LG. destruct (Hb P Gsp) as [N | N]; [ left; exact N | right; exact (hi_sp0 o N) ].
  Qed.

  Lemma world_si : OW.msurf_ok G bm m -> ffw G bm m -> wmotr_world bm m -> wmotr_world bm m2.
  Proof.
    intros MS Hf (Hw & Hc & Hfl & Hh & Hr & Hq & Ho).
    assert (SO : forall z, In z OW.MSURF -> forall v, Mem.load Mint32 m bm z = Some v ->
                   surface_ok m v -> surface_ok m2 v).
    { intros z Hz v Hl [E | (b & o & t & -> & Lt & Hin)]; [ left; exact E | right ].
      exists b, o, t. rewrite (surf_tr z _ MS Hz Hl b o eq_refl). exact (conj eq_refl (conj Lt Hin)). }
    split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ].
    - intros v Hl. rewrite LB in Hl. exact (SO WALL_OFF ltac:(cbn; auto) v Hl (Hw v Hl)).
    - intros v Hl. rewrite LB in Hl. exact (SO CEIL_OFF ltac:(cbn; auto) v Hl (Hc v Hl)).
    - intros v Hl. rewrite LB in Hl. destruct (Hfl v Hl) as (b & o & t & -> & Lt & Hin).
      exists b, o, t. rewrite (surf_tr FLOOR_OFF _ MS ltac:(cbn; auto) Hl b o eq_refl).
      exact (conj eq_refl (conj Lt Hin)).
    - rewrite LB. exact Hh.
    - rewrite LB. exact Hr.
    - rewrite LB. exact Hq.
    - destruct Ho as (mb & mo & s & n & Hl & Ls & Hs & Ln & Hn & Hall).
      destruct (mobj_np Hf mb mo Hl) as (Nmb & Ncb).
      exists mb, mo, s, n. rewrite LB, !(LU _ mb) by exact Nmb.
      do 5 (split; [ assumption | ]).
      intros i0 v Hi Hl2. rewrite LU in Hl2 by exact Nmb. pose proof (Hall i0 v Hi Hl2) as Hok.
      destruct Hok as (cb & co & t & -> & Lt & Hin & Hp & Hc').
      assert (N : cb <> P) by (apply (Ncb i0 cb co); [ lia | exact Hl2 ]).
      assert (LC : forall ch z, Mem.load ch m2 cb z = Mem.load ch m cb z) by (intros; apply LU; exact N).
      exists cb, co, t. split; [ reflexivity | ]. rewrite LC. split; [ exact Lt | split; [ exact Hin | split ] ].
      + intros Ht. destruct (Hp Ht) as (base & top & Hi' & P1 & P2 & P3). exists base, top. rewrite !LC. auto.
      + intros Ht. destruct (Hc' Ht) as (y & Hi' & P1). exists y. rewrite LC. auto.
  Qed.

  (* the Camera: its cutscene byte is off the SI cells (cam_si) *)
  Lemma cam_w_si : area_w G m -> cam_w G m -> cam_w G m2.
  Proof.
    intros AW (C1 & C2 & (P1 & P2 & P3)).
    assert (US : forall b ch z, cam_sym G b -> Mem.load ch m2 b z = Mem.load ch m b z).
    { intros b ch z (id & _ & Hs). apply LU. exact (sym_ne _ _ Hs). }
    assert (UG : forall ga, Genv.find_symbol G level_update._gCurrentArea = Some ga ->
               Mem.load Mint32 m2 ga 0 = Mem.load Mint32 m ga 0)
      by (intros ga Hs; apply LU; exact (sym_ne _ _ Hs)).
    split; [ | split ].
    - intros b Hs. rewrite (US b Mint8unsigned 0 (cam_sym_of G camera._sObjectCutscene b ltac:(cam_in) Hs)).
      exact (C1 b Hs).
    - intros ga bad o Sg Lg.
      rewrite (UG ga Sg) in Lg.
      destruct (AW ga Sg) as (bad' & o' & Sad & Lg').
      rewrite Lg in Lg'. injection Lg' as <- <-.
      destruct (C2 ga bad o Sg Lg) as (cb & co & Lc & Pg & Ab & (n & Ln & Cn) & Sz & R3 & RS).
      exists cb, co.
      split; [ rewrite (US bad Mint32 _ (cam_sym_of G area._gAreaData bad ltac:(cam_in) Sad)); exact Lc | ].
      split; [ exact Pg | ].
      split; [ intros ab bt ot Sa La; rewrite LU in La by exact (sym_ne _ _ Sa); exact (Ab ab bt ot Sa La) | ].
      split; [ | split; [ exact Sz | split ] ].
      + exists n. split; [ | exact Cn ].
        destruct (eq_block cb P) as [-> | N]; [ | rewrite LU by exact N; exact Ln ].
        destruct Gsp as (bs & Ss & Ls).
        destruct (RS bs P (Ptrofs.repr OW.SP_OFF) Ss Ls) as [N | Ap]; [ exfalso; exact (N eq_refl) | ].
        assert (Hz : In zs CAM_SI) by exact Hzs.
        pose proof (Ap zs Hz) as D. unfold CAM_SZ in D. pose proof (si_low zs Hzs) as Sl.
        rewrite <- Ln. eapply Mem.load_store_other; [ exact Hst | right; cbn [size_chunk]; lia ].
      + intros id k bs bp op Hin Hs Hl.
        assert (Hid : In id cam_ids).
        { unfold cam_pools in Hin. cbn [In] in Hin.
          destruct Hin as [E | [E | []]]; injection E as <- _; cam_in. }
        rewrite (US bs Mint32 0 (cam_sym_of G _ bs Hid Hs)) in Hl.
        exact (R3 id k bs bp op Hin Hs Hl).
      + intros bs bp op Hs Hl.
        rewrite (US bs Mint32 0 (cam_sym_of G surface_load._sSurfacePool bs ltac:(cam_in) Hs)) in Hl.
        exact (RS bs bp op Hs Hl).
    - split; [ | split ].
      + intros b Hs bb oo Hl.
        rewrite (US b Mint32 0 (cam_sym_of G camera._gCamera b ltac:(cam_in) Hs)) in Hl.
        exact (cam_cb_unch G m m2 bb oo UG US AW (P1 b Hs bb oo Hl)).
      + intros x b Hx Hs bb oo Hl.
        assert (Hid : In x cam_ids) by (cbn [In] in Hx; destruct Hx as [<- | [<- | []]]; cam_in).
        rewrite (US b Mint32 0 (cam_sym_of G _ b Hid Hs)) in Hl.
        exact (P2 x b Hx Hs bb oo Hl).
      + intros b Hs bb oo.
        rewrite (US b Mint32 0 (cam_sym_of G camera._gSecondCameraFocus b ltac:(cam_in) Hs)).
        exact (P3 b Hs bb oo).
  Qed.

  Lemma lvl_w_si : lvl_w G m -> lvl_w G m2.
  Proof.
    intros (L1 & L2 & (W1 & W2 & W3 & W4 & W5) & CW & AW & EW & CMW & AD).
    assert (CM' : cam_w G m2) by exact (cam_w_si AW CMW).
    assert (AD' : aud_w G m2).
    { apply (aud_w_unch G m m2); [ | exact AD ]. intros b ch z (g & _ & Hs). apply LU. exact (sym_ne _ _ Hs). }
    assert (U' : forall id b, Genv.find_symbol G id = Some b -> In id lvl_ids -> forall ch z,
               Mem.load ch m2 b z = Mem.load ch m b z)
      by (intros id b Hs _ ch z; apply LU; exact (sym_ne _ _ Hs)).
    clear CMW.
    split; [| split; [| split; [| split]]].
    - intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (L1 b Hs).
    - intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (L2 b Hs).
    - split; [| split; [| split; [| split]]].
      + intros bp bw Hp Hw. rewrite (U' _ bp Hp ltac:(unfold lvl_ids; cbn [In]; auto 20)), (U' _ bw Hw ltac:(unfold lvl_ids; cbn [In]; auto 20)).
        exact (W1 bp bw Hp Hw).
      + intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (W2 b Hs).
      + intros b Hs. rewrite (U' _ b Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (W3 b Hs).
      + intros bo bs Ho Hs. rewrite (U' _ bo Ho ltac:(unfold lvl_ids; cbn [In]; auto 20)), (U' _ bs Hs ltac:(unfold lvl_ids; cbn [In]; auto 20)).
        exact (W4 bo bs Ho Hs).
      + intros bo Ho. rewrite (U' _ bo Ho ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (W5 bo Ho).
    - intros bc bp Sc Sp.
      destruct (CW bc bp Sc Sp) as (L24 & B16 & PA & P1 & P3 & DM & MX).
      pose proof (U' _ bc Sc ltac:(unfold lvl_ids; cbn [In]; auto 20)) as Kc.
      pose proof (U' _ bp Sp ltac:(unfold lvl_ids; cbn [In]; auto 20)) as Kp.
      split; [intros j Hj; rewrite !Kc; exact (L24 j Hj) |].
      split; [intros z Hz; rewrite Kc; exact (B16 z Hz) |].
      split; [intros k' n Hk' Hl; rewrite Kp in Hl; exact (PA k' n Hk' Hl) |].
      split; [intros b1 S1; rewrite (U' _ b1 S1 ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (P1 b1 S1) |].
      split; [intros b3 S3; rewrite (U' _ b3 S3 ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (P3 b3 S3) |].
      split; [intros bd Sd; rewrite (U' _ bd Sd ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (DM bd Sd) |].
      intros bx Sx; rewrite (U' _ bx Sx ltac:(unfold lvl_ids; cbn [In]; auto 20)); exact (MX bx Sx).
    - split; [ | split; [ split | exact (conj CM' AD') ] ].
      + intros ga Sa. rewrite (U' _ ga Sa ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (AW ga Sa).
      + intros be Se. rewrite (U' _ be Se ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (proj1 EW be Se).
      + intros be Se. rewrite (U' _ be Se ltac:(unfold lvl_ids; cbn [In]; auto 20)). exact (proj2 EW be Se).
  Qed.

  Lemma phiw_si : Mem.valid_block m bm -> OW.msurf_ok G bm m -> phiw lp bm m -> phiw lp bm m2.
  Proof.
    intros Vb MS (Hh & Hw & Han & Hmo & Hf & Hu & Haw & Hlvl).
    exact (conj (hi_si Vb Hf Hh) (conj (world_si MS Hf Hw) (conj (aa_si Hf Han) (conj (mo_si Hf Hmo)
           (conj (ffw_si Hf) (conj (used_si Hf Hu) (conj (anim_w_si Hf Haw) (lvl_w_si Hlvl)))))))).
  Qed.

  Lemma obj_w_si : OW.obj_w G bm m -> OW.obj_w G bm m2.
  Proof.
    assert (KR : forall P', Ple (Genv.genv_next G) P' ->
               OW.gcell G surface_load._sSurfacePool Mint32 (Vptr P' (Ptrofs.repr OW.SP_OFF)) m ->
               OW.gcell G surface_load._sSurfaceNodePool Mint32 (Vptr P' (Ptrofs.repr OW.NP_OFF)) m ->
               forall ch z, (OW.NP_OFF <= z /\ z + size_chunk ch <= OW.NP_END)
                            \/ (OW.SP_OFF <= z /\ z + size_chunk ch <= OW.SP_END) ->
               Mem.load ch m2 P' z = Mem.load ch m P' z).
    { intros P' _ _ _ ch z Hz. apply LG. right.
      destruct Hz as [(Hz & _) | (Hz & _)]; unfold OW.NP_OFF, OW.SP_OFF in Hz; lia. }
    assert (KG : forall id b, In id OW.surf_gids -> Genv.find_symbol G id = Some b ->
               forall ch z, Mem.load ch m2 b z = Mem.load ch m b z)
      by (intros id b _ Hs ch z; apply LU; exact (sym_ne _ _ Hs)).
    apply (PollKeep.obj_w_unch_s m m2 G bm).
    - intros id b _ Hs ch z. apply LU. exact (sym_ne _ _ Hs).
    - intros pl Hpl. split.
      + apply (OW.surf_obj_ok_ext G pl m m2 KG KR).
        intros k j _ _. apply LU. exact (sym_ne _ _ Hpl).
      + intros mv. apply (OW.cls_surf_ext G pl m m2 mv KG KR).
    - intros z _. apply LB.
    - intros s b _ Hs ch z. apply LU. exact (sym_ne _ _ Hs).
  Qed.

  Lemma plat_si : PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp m2.
  Proof.
    intros Hs bp v Hbp Hl. rewrite LU in Hl by exact (sym_ne _ _ Hbp).
    destruct (Hs bp v Hbp Hl) as [Hz | (pb & po & -> & Hpb & Hk & Hal)]; [ left; exact Hz | right ].
    exists pb, po. split; [ reflexivity | split; [ exact Hpb | split; [ | exact Hal ] ] ].
    intros k Hk0. cbn [Mem.loadv] in *. rewrite LU by exact (sym_ne _ _ Hpb). exact (Hk k Hk0).
  Qed.
End SI.

(* ---- THE ROW ---- *)
Section ROW.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.

  Theorem si_row_proved : UnloadRows.si_row lp bm bc oc0 SafeB.
  Proof.
    intros m bP o i m2 HPc Gsp Ho Hst.
    pose proof HPc as (Ok & Hphi & HD & Hpl & How).
    pose proof Ok as (Vb & _ & HM).
    pose proof How as (pool & la & fl & gol & gmo & sdp & gdi & rs0 & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    destruct (OW.ow_surf_obj _ _ _ _ _ _ _ _ _ _ _ _ C) as (P' & HP & G1 & _ & W).
    assert (E : P' = bP).
    { destruct G1 as (b1 & Hs1 & L1). destruct Gsp as (b2 & Hs2 & L2).
      rewrite Hs1 in Hs2. injection Hs2 as <-. rewrite L1 in L2. injection L2 as E2. exact E2. }
    subst P'.
    pose proof (OW.ow_msurf _ _ _ _ _ _ _ _ _ _ _ _ C) as MS.
    assert (LU' : forall ch b z, b <> bP -> Mem.load ch m2 b z = Mem.load ch m b z)
      by (intros ch b z N; eapply LU; eassumption).
    assert (SN : forall id b, Genv.find_symbol G id = Some b -> b <> bP)
      by (intros id b Hs; eapply sym_ne; eassumption).
    refine (conj _ (conj _ (conj _ (conj _ _)))).
    - eapply ClearKeep.safe_store_dyn; eassumption.
    - eapply phiw_si; eassumption.
    - pose proof HM as (_ & _ & R2 & _).
      rewrite <- HD. unfold a_down_real.
      rewrite (LU' Mptr bm 156 (SN _ _ Hbm_sym)).
      destruct (Mem.load Mptr m bm 156) as [v |] eqn:E; [| reflexivity ].
      destruct v; try reflexivity.
      destruct (R2 _ _ eq_refl) as (-> & _).
      rewrite (LU' _ bc _ (SN _ _ Hbc_sym)). reflexivity.
    - eapply plat_si; eassumption.
    - eapply obj_w_si; eassumption.
  Qed.
End ROW.
