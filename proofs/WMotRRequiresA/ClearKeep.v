(* ===================================================================== *)
(* ClearKeep (GOAL 2): the object phase's clear_dynamic_surfaces call,    *)
(* PROVED from the real code (2026-11-03).                                *)
(*                                                                       *)
(* ClearRun.cds_run inverts the generated body: under a time stop         *)
(* nothing changes; otherwise three kinds of store, in order:             *)
(*   gSurfacesAllocated = gNumStaticSurfaces (obj_w's ow_spool pins it    *)
(*     to NS, so ow_ctr holds with the value NS: post_clear);             *)
(*   gSurfaceNodesAllocated = gNumStaticSurfaceNodes (a cell no invariant *)
(*     reads);                                                            *)
(*   NULL into each of the 768 list heads of gDynamicSurfacePartition.    *)
(* Each store keeps the object phase's invariant (Pobjl's components):    *)
(*   - a store into a global no invariant reads (gstore_keep: the cell is *)
(*     off RenderKeep's footprint, off MWF's globals, off obj_w's);       *)
(*   - a NULL head (pstore_keep): a partition list either keeps its old   *)
(*     head or becomes empty, and every list node and listed surface is a *)
(*     dynamic block (FloorExec.dyn_list), so each list the invariants    *)
(*     walk (the world fact Wff, the floor data, the animation table's    *)
(*     apartness, obj_w's surface objects) is an old list or empty.       *)
(* PHANTOM CHECK: no premise beyond the object phase's invariant Pobjl    *)
(* (mem_ok, PhiW, a_down, plat_still, obj_w); every block and value is   *)
(* read off the real memory.                                              *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  platform_displacement area.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require NoAImpliesNoFlyTwelve ObjExtBodies.
From SM64.Proofs Require Import Generic.ClosedMem.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorExec AirMatch FfWorld AnimData AnimWorld
  RenderKeep ClearRun.
From SM64.Proofs.WMotRRequiresA Require ObjWorld PollKeep PlatformKeep ObjPhase FfComplete BhvVM RenderAnim.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.
Module SC := surface_collision.
Module PD := platform_displacement.
Module OLP := object_list_processor.

(* ---------------------------------------------------------------------- *)
(* 1. A partition change that only empties lists keeps the list facts.    *)
(* ---------------------------------------------------------------------- *)
Section K3.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variables (m m2 : mem) (bx : block).
  Hypothesis Sbx : Genv.find_symbol G SC._gDynamicSurfacePartition = Some bx.
  Hypothesis Hnb : Mem.nextblock m2 = Mem.nextblock m.
  Hypothesis Hperm : forall b o k p, Mem.perm m b o k p -> Mem.perm m2 b o k p.
  Hypothesis Hld : forall ch b z, b <> bx -> Mem.load ch m2 b z = Mem.load ch m b z.
  Hypothesis Hbx : forall z v, Mem.load Mint32 m2 bx z = Some v ->
    Mem.load Mint32 m bx z = Some v \/ v = Vint Int.zero.

  Lemma bx_glob : Plt bx (Genv.genv_next G).
  Proof. exact (Genv.genv_symb_range _ _ Sbx). Qed.

  Lemma dyn_ne : forall b, ~ Plt b (Genv.genv_next G) -> b <> bx.
  Proof. intros b H ->. exact (H bx_glob). Qed.

  Lemma ph_back : forall hd, part_head G m2 hd -> part_head G m hd \/ hd = Vint Int.zero.
  Proof.
    intros hd (id & bp & o & Hin & Hs & Hl). cbn [Mem.loadv] in Hl.
    destruct (peq bp bx) as [-> | Ne].
    - destruct (Hbx _ _ Hl) as [H | H]; [ left | right; exact H ].
      exists id, bx, o. split; [ exact Hin | split; [ exact Hs | exact H ] ].
    - left. exists id, bp, o. split; [ exact Hin | split; [ exact Hs | ] ].
      cbn [Mem.loadv]. rewrite <- (Hld _ _ _ Ne). exact Hl.
  Qed.

  Lemma fh_back : forall hd, floor_head G m2 hd -> floor_head G m hd \/ hd = Vint Int.zero.
  Proof.
    intros hd (id & bp & z & x & Hin & Hs & Hz & Hx & Hl). cbn [Mem.loadv] in Hl.
    destruct (peq bp bx) as [-> | Ne].
    - destruct (Hbx _ _ Hl) as [H | H]; [ left | right; exact H ].
      exists id, bx, z, x. auto.
    - left. exists id, bp, z, x. split; [ exact Hin | split; [ exact Hs | split; [ exact Hz | split; [ exact Hx | ] ] ] ].
      cbn [Mem.loadv]. rewrite <- (Hld _ _ _ Ne). exact Hl.
  Qed.

  Lemma valid_fwd : forall b, Mem.valid_block m b -> Mem.valid_block m2 b.
  Proof. intros b H. unfold Mem.valid_block in *. rewrite Hnb. exact H. Qed.

  Lemma wf_fwd3 : forall (A : block -> Prop) hd, (forall b, ~ A b -> b <> bx) ->
    wf_list m A hd -> wf_list m2 A hd.
  Proof.
    intros A hd HA W. induction W as [| bn on nx Hv Hav Hl W IH]; [ constructor | ].
    apply wf_cons with nx; [ exact (valid_fwd _ Hv) | exact Hav | | exact IH ].
    cbn [Mem.loadv] in *. rewrite (Hld _ _ _ (HA _ Hav)). exact Hl.
  Qed.

  Lemma ol_back3 : forall hd s, wf_list m (fun b => Plt b (Genv.genv_next G)) hd ->
    on_list m2 hd s -> on_list m hd s.
  Proof.
    intros hd s W Ho. apply (ol_transfer_v m _ hd W m2 s); [ | exact Ho ].
    intros b z Hb _. exact (Hld _ _ _ (dyn_ne b Hb)).
  Qed.

  Lemma no_list0 : forall s, ~ on_list m2 (Vint Int.zero) s.
  Proof. intros s H. inversion H. Qed.

  Section W.
    Variables (gp : meminj) (rl : list (option val)).
    Hypothesis W : Wff G m gp SZ_SURFACE rl.

    Lemma W_dyn : forall hd, part_head G m hd -> dyn_list G m hd.
    Proof. destruct W as (_ & _ & _ & _ & _ & W6 & _). exact W6. Qed.

    Lemma W_old : forall hd, part_head G m hd -> wf_list m (fun b => Plt b (Genv.genv_next G)) hd.
    Proof. intros hd H. exact (proj1 (W_dyn hd H)). Qed.

    Lemma W_surf : forall hd b o, part_head G m hd -> on_list m hd (Vptr b o) -> b <> bx.
    Proof.
      intros hd b o H Ho. pose proof (proj2 (W_dyn hd H) b o Ho) as P.
      apply dyn_ne. unfold Plt, Ple in *. lia.
    Qed.

    Lemma OL3 : forall hd s, part_head G m2 hd -> on_list m2 hd s -> part_head G m hd /\ on_list m hd s.
    Proof.
      intros hd s Hh Ho. destruct (ph_back hd Hh) as [H0 | ->]; [ | exfalso; exact (no_list0 s Ho) ].
      exact (conj H0 (ol_back3 hd s (W_old hd H0) Ho)).
    Qed.

    (* a list predicate over the old lists: nodes avoid A and are dynamic *)
    Lemma wf_keep3 : forall (A : block -> Prop) hd, part_head G m2 hd ->
      (part_head G m hd -> wf_list m A hd) -> wf_list m2 A hd.
    Proof.
      intros A hd Hh HA. destruct (ph_back hd Hh) as [H0 | ->]; [ | constructor ].
      apply (wf_list_mono m2 (fun b => A b \/ Plt b (Genv.genv_next G))); [ intros b Hb; left; exact Hb | ].
      apply (wf_fwd3 _ hd).
      - intros b Hb. apply dyn_ne. intros Hp. apply Hb. right. exact Hp.
      - exact (wf_list_or m _ _ hd (HA H0) (W_old hd H0)).
    Qed.

    Lemma Wff_keep3 : forall gp', (forall b, gp b <> None -> gp' b <> None) -> Wff G m2 gp' SZ_SURFACE rl.
    Proof.
      intros gp' Hg. pose proof W as (W1 & W2 & W3 & W4 & W5 & W6 & W7).
      split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ].
      - intros id sz Hi. destruct (W1 id sz Hi) as (b & Hs & Hr). exists b. split; [ exact Hs | ].
        intros ofs Hofs. exact (Hperm _ _ _ _ (Hr ofs Hofs)).
      - intros id bp Hi Hs. destruct (W2 id bp Hi Hs) as (A & B & C).
        split; [ unfold Plt in *; rewrite Hnb; exact A | split; assumption ].
      - intros hd Hh. exact (wf_keep3 _ hd Hh (W3 hd)).
      - intros hd s Hh Ho. destruct (OL3 hd s Hh Ho) as (Hh0 & Ho0).
        destruct (W4 hd s Hh0 Ho0) as (b & o & -> & Hpl & Hsz & Hr & Hgb).
        exists b, o. split; [ reflexivity | ]. split; [ unfold Plt in *; rewrite Hnb; exact Hpl | ].
        split; [ exact Hsz | ]. split; [ exact Hr | exact (Hg _ Hgb) ].
      - intros hd b o Hh Ho. destruct (OL3 hd _ Hh Ho) as (Hh0 & Ho0).
        destruct (W5 hd b o Hh0 Ho0) as (t & Hl & Hin). exists t. split; [ | exact Hin ].
        rewrite (Hld _ _ _ (W_surf hd b o Hh0 Ho0)). exact Hl.
      - intros hd Hh. split.
        + exact (wf_keep3 _ hd Hh (fun H => proj1 (W6 hd H))).
        + intros b o Ho. destruct (OL3 hd _ Hh Ho) as (Hh0 & Ho0). exact (proj2 (W6 hd Hh0) b o Ho0).
      - destruct W7 as (Wsz & Wdp). split; [ exact Wsz | ].
        apply (FfComplete.dp_lists_keep G m m2 (fun b => b = bx)); [ | | | | exact Wdp ].
        + intros ch b z _ Hb. exact (Hld ch b z Hb).
        + intros bp Hs E. subst bp.
          refine (Genv.global_addresses_distinct G _ Hs Sbx eq_refl). vm_compute. discriminate.
        + intros hd Hh. apply (wf_list_mono m (fun b => Plt b (Genv.genv_next G))); [ | exact (W_old hd Hh) ].
          intros b ->. exact bx_glob.
        + intros hd b o Hh Ho. exact (W_surf hd b o Hh Ho).
    Qed.

    Lemma floor_data_keep3 : floor_data G m -> floor_data G m2.
    Proof.
      intros FD h (hd & s & xv & zv & Hh & Hol & Hhit).
      destruct (fh_back hd Hh) as [Hh0 | ->]; [ | exfalso; exact (no_list0 s Hol) ].
      pose proof (floor_head_part _ _ _ Hh0) as Hp0.
      assert (Hol0 : on_list m hd s) by exact (ol_back3 hd s (W_old hd Hp0) Hol).
      pose proof W as (_ & _ & _ & W4 & _).
      destruct (W4 hd s Hp0 Hol0) as (b & o & -> & _).
      apply FD. exists hd, (Vptr b o), xv, zv. split; [ exact Hh0 | split; [ exact Hol0 | ] ].
      apply (hit16_transfer m2 m b o xv zv h); [ | exact Hhit ].
      intros ch z. exact (Hld ch b z (W_surf hd b o Hp0 Hol0)).
    Qed.

    Lemma tab_apart_keep3 : forall bt, tab_apart G m bt -> tab_apart G m2 bt.
    Proof.
      intros bt TA hd Hh. split.
      - exact (wf_keep3 _ hd Hh (fun H => proj1 (TA hd H))).
      - intros b o Ho. destruct (OL3 hd _ Hh Ho) as (Hh0 & Ho0). exact (proj2 (TA hd Hh0) b o Ho0).
    Qed.
  End W.

  (* a global other than the partition is not bx *)
  Lemma sym_nx : forall id b, Genv.find_symbol G id = Some b ->
    Pos.eqb id SC._gDynamicSurfacePartition = false -> b <> bx.
  Proof.
    intros id b Hs Hn ->.
    assert (E : id = SC._gDynamicSurfacePartition) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Sbx ]).
    subst id. rewrite Pos.eqb_refl in Hn. discriminate Hn.
  Qed.

  Variable bm : block.
  Hypothesis Sbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
  (* a head store keeps a closed memory closed *)
  Hypothesis CLk : forall gp, closed_by gp m -> gp bx <> None -> closed_by gp m2.

  Lemma Nbm : bm <> bx.
  Proof. exact (sym_nx _ _ Sbm eq_refl). Qed.

  (* ---- the animation world ---- *)
  Lemma anim_base_keep3 : forall gp rl ab bga bauc btab otab bt ot mb mo,
    Wff G m gp SZ_SURFACE rl ->
    anim_base G bm m ab bga bauc btab otab bt ot mb mo -> anim_base G bm m2 ab bga bauc btab otab bt ot mb mo.
  Proof.
    intros gp rl ab bga bauc btab otab bt ot mb mo W
      (S1 & S2 & S3 & L0 & L8 & Lm & Sy & D1 & D2 & D3 & D4 & (D5 & RG) & Z1 & Z2 & Z3 & P & T & GA & TA & AC & SM).
    assert (Nab : ab <> bx) by exact (sym_nx _ _ S1 eq_refl).
    assert (Nga : bga <> bx) by exact (sym_nx _ _ S2 eq_refl).
    assert (Ntab : btab <> bx) by exact (not_eq_sym (proj1 (Sy _ _ Sbx))).
    refine (conj S1 (conj S2 (conj S3 (conj _ (conj _ (conj _ (conj Sy (conj D1 (conj D2 (conj D3 (conj D4
           (conj (conj D5 _) (conj Z1 (conj Z2 (conj Z3 (conj _ (conj _ (conj _ (conj _ (conj _ SM)))))))))))))))))))).
    - rewrite (Hld _ _ _ Nab). exact L0.
    - rewrite (Hld _ _ _ Nab). exact L8.
    - rewrite (Hld _ _ _ Nbm). exact Lm.
    - intros id b Hin Hs. destruct (RG id b Hin Hs) as (Ne & TAb).
      split; [ exact Ne | exact (tab_apart_keep3 gp rl W b TAb) ].
    - intros i Hi. exact (Hperm _ _ _ _ (P i Hi)).
    - destruct T as (T1 & T2 & T3). unfold tab_ok. rewrite !(Hld _ _ _ Ntab).
      refine (conj T1 (conj T2 _)). intros j o s' Hj. rewrite !(Hld _ _ _ Ntab). exact (T3 j o s' Hj).
    - destruct GA as (G1 & G2). split.
      + intros o ch z Hin. rewrite (Hld _ _ _ Nga). exact (G1 o ch z Hin).
      + intros i Hi. exact (Hperm _ _ _ _ (G2 i Hi)).
    - exact (tab_apart_keep3 gp rl W btab TA).
    - intros off b o Hoff Hl. apply (AC off b o Hoff). rewrite <- (Hld _ _ _ Nbm). exact Hl.
  Qed.

  Lemma anim_w_keep3 : forall gp rl, Wff G m gp SZ_SURFACE rl ->
    (forall mb mo, Mem.load Mint32 m bm 136 = Some (Vptr mb mo) -> mb <> bx) ->
    AnimWorld.anim_w G bm m -> AnimWorld.anim_w G bm m2.
  Proof.
    intros gp rl W Hmb (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & ST).
    pose proof B as (S1 & _ & _ & _ & _ & Lm & Sy & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & SM).
    exists ab, bga, bauc, btab, otab, bt, ot, mb, mo.
    split; [ exact (anim_base_keep3 gp rl ab bga bauc btab otab bt ot mb mo W B) | ].
    intros a La Ia. rewrite (Hld _ _ _ Nbm) in La.
    eapply anim_st_keep; [ exact (ST a La Ia) | | | ].
    - apply Hld. exact (sym_nx _ _ S1 eq_refl).
    - intros o ch _. apply Hld. exact (Hmb mb mo Lm).
    - intros k rel ch v _ _. apply Hld. exact (not_eq_sym (proj2 (Sy _ _ Sbx))).
  Qed.

  Lemma anim_apart_keep3 :
    (forall mb mo, Mem.load Mint32 m bm 136 = Some (Vptr mb mo) -> mb <> bx) ->
    FrameSplit.anim_apart lp bm m -> FrameSplit.anim_apart lp bm m2.
  Proof.
    intros Hmb Han ab bt ot Hs Hl.
    rewrite (Hld _ _ _ (sym_nx _ _ Hs eq_refl)) in Hl.
    destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
    - intros off sb so Hoff Hl'. rewrite (Hld _ _ _ Nbm) in Hl'. exact (A1 off sb so Hoff Hl').
    - intros mb mo i cb co Hl' Hi Hl2. rewrite (Hld _ _ _ Nbm) in Hl'.
      rewrite (Hld _ _ _ (Hmb mb mo Hl')) in Hl2. exact (A2 mb mo i cb co Hl' Hi Hl2).
  Qed.

  (* ---- the frame world ---- *)
  Lemma ffw_keep3 : ffw G bm m -> ffw G bm m2.
  Proof.
    intros (Hgn & (d & FWF) & FD).
    assert (Nbo : fw_bo d <> bx) by exact (sym_nx _ _ (ff_Spool _ _ _ _ FWF) eq_refl).
    assert (Nab : fw_ab d <> bx) by exact (sym_nx _ _ (ff_S5 _ _ _ _ FWF) eq_refl).
    pose proof (ff_W _ _ _ _ FWF) as W.
    assert (Gx : fw_gp d bx <> None) by exact (ff_HS _ _ _ _ FWF _ _ Sbx).
    apply (ffw_rebuild G bm m m2 d (fw_gp d) FWF).
    - unfold Ple in *. rewrite Hnb. exact Hgn.
    - unfold Ple. rewrite Hnb. apply Pos.le_refl.
    - intros b H. exact H.
    - exact (CLk _ (ff_HC _ _ _ _ FWF) Gx).
    - exact (Wff_keep3 _ _ W _ (fun b H => H)).
    - exact (floor_data_keep3 _ _ W FD).
    - intros ch b z H. apply Hld.
      destruct H as [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]];
        first [ exact Nbm | exact Nab | exact Nbo ].
    - split; [ | split ].
      + exists (fw_fl d). rewrite (Hld _ _ _ Nbm). exact (conj (ff_Lf _ _ _ _ FWF) (ff_Wf _ _ _ _ FWF)).
      + intros off sb so Hoff Hl. rewrite (Hld _ _ _ Nbm) in Hl. exact (ff_Wc0 _ _ _ _ FWF off sb so Hoff Hl).
      + intros off sb so Hoff Hl. rewrite (Hld _ _ _ Nbm) in Hl. exact (ff_Spl _ _ _ _ FWF off sb so Hoff Hl).
  Qed.

  (* ---- the level cells: none is the partition ---- *)
  Lemma lvl_keep3 : lvl_w G m -> lvl_w G m2.
  Proof.
    intros LW. apply (lvl_w_unch G m m2); [ | | exact LW ].
    - intros b ch z Hb. apply Hld.
      destruct (lvl_rd_cases G m b LW (or_introl Hb)) as [(id & Hin & Hs) | Hn].
      + apply (sym_nx id b Hs).
        pose proof (avoid_of lvl_rd_ids [SC._gDynamicSurfacePartition] ltac:(vm_compute; reflexivity) id Hin) as E.
        cbn [existsb] in E. rewrite orb_false_r in E. exact E.
      + intros ->. exact (Hn _ Sbx).
    - intros ab Hs. apply Hld. exact (sym_nx _ _ Hs eq_refl).
  Qed.

  (* ---- PhiW ---- *)
  Definition XD : list ident := [SC._gDynamicSurfacePartition].

  Lemma phiw_keep3 : phiw lp bm m -> phiw lp bm m2.
  Proof.
    intros Hphi. pose proof Hphi as (Hh & Hw & Han & Hmo & Hf & Hu & Haw & Hl).
    pose proof Hf as (Hgn & (d & FWF) & FD).
    pose proof (ff_Lo _ _ _ _ FWF) as Lmo. unfold FFW_OBJ in Lmo.
    assert (Nbo : fw_bo d <> bx) by exact (sym_nx _ _ (ff_Spool _ _ _ _ FWF) eq_refl).
    assert (Hmb : forall mb mo, Mem.load Mint32 m bm 136 = Some (Vptr mb mo) -> mb <> bx)
      by (intros mb mo H; rewrite Lmo in H; injection H as <- _; exact Nbo).
    assert (Bmb : bm <> fw_bo d) by exact (not_eq_sym (ff_D1 _ _ _ _ FWF)).
    assert (LD : forall ch b z, ~ rgb lp XD b -> b <> bm -> (b <> fw_bo d \/ owin (fw_oo d) ch z) ->
              Mem.load ch m2 b z = Mem.load ch m b z).
    { intros ch b z Nr _ _. apply Hld. intros ->. apply Nr.
      exists SC._gDynamicSurfacePartition. split; [ left; reflexivity | exact Sbx ]. }
    assert (LM : forall ch z, bmk ch z -> Mem.load ch m2 bm z = Mem.load ch m bm z)
      by (intros ch z _; exact (Hld _ _ _ Nbm)).
    assert (RGa : forall b, rgb lp XD b -> b <> fw_bo d /\ tab_apart G m b).
    { intros b (id & Hin & Hs). destruct Hin as [<- | []]. rewrite Sbx in Hs. injection Hs as <-.
      split; [ exact (not_eq_sym Nbo) | exact (tab_apart_global G m _ _ _ bx bx_glob (ff_W _ _ _ _ FWF)) ]. }
    assert (SNB : forall off sb so, (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
              Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm).
    { intros off sb so Hoff Hl0 ->.
      pose proof (ff_Spl _ _ _ _ FWF off bm so Hoff Hl0) as P.
      pose proof (Genv.genv_symb_range _ _ Sbm) as Q. unfold Plt, Ple in *. lia. }
    assert (Co : forall i cb co, 0 <= i < 4 ->
              Mem.load Mint32 m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + FFW_COLL + 4 * i) = Some (Vptr cb co) ->
              cb = fw_bo d)
      by exact (ff_Co _ _ _ _ FWF).
    pose proof (phiw_surf_apart lp bm XD m Hphi) as RSA.
    split; [ exact (k_hi lp bm XD m m2 _ _ (fun _ => True) Lmo (LD1 lp bm XD m m2 _ _ LD) LM Bmb RGa Hh) | ].
    split; [ exact (k_world lp bm XD m m2 _ _ Lmo LD LM Bmb RGa Hw Hmo RSA SNB Co) | ].
    split; [ exact (anim_apart_keep3 Hmb Han) | ].
    split; [ exact (k_mobj lp bm XD m m2 _ _ (fun _ => True) Lmo (LD1 lp bm XD m m2 _ _ LD) LM Bmb RGa Hmo) | ].
    split; [ exact (ffw_keep3 Hf) | ].
    split; [ exact (k_used lp bm XD m m2 _ _ Lmo LD LM Bmb RGa Hu) | ].
    split; [ exact (anim_w_keep3 _ _ (ff_W _ _ _ _ FWF) Hmb Haw) | ].
    exact (lvl_keep3 Hl).
  Qed.
End K3.

(* one NULL head store is such a change *)
Lemma head_store_k3 : forall m bx w m2, 0 <= w ->
  Mem.store Mint32 m bx (8 * w) (Vint Int.zero) = Some m2 ->
  Mem.nextblock m2 = Mem.nextblock m
  /\ (forall b o k p, Mem.perm m b o k p -> Mem.perm m2 b o k p)
  /\ (forall ch b z, b <> bx -> Mem.load ch m2 b z = Mem.load ch m b z)
  /\ (forall z v, Mem.load Mint32 m2 bx z = Some v -> Mem.load Mint32 m bx z = Some v \/ v = Vint Int.zero).
Proof.
  intros m bx w m2 Hw S.
  split; [ exact (Mem.nextblock_store _ _ _ _ _ _ S) | split; [ | split ] ].
  - intros b o k p H. exact (Mem.perm_store_1 _ _ _ _ _ _ S _ _ _ _ H).
  - intros ch b z Ne. apply (Mem.load_store_other _ _ _ _ _ _ S). left. exact Ne.
  - intros z v Hl. destruct (Z.eq_dec z (8 * w)) as [-> | Ne].
    + right. rewrite (Mem.load_store_same _ _ _ _ _ _ S) in Hl. injection Hl as <-. reflexivity.
    + left. rewrite <- Hl. symmetry. apply (Mem.load_store_other _ _ _ _ _ _ S). right.
      pose proof (Mem.load_valid_access _ _ _ _ _ Hl) as (_ & (k & Hk)).
      cbn [align_chunk size_chunk] in *. lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. A store into a global no invariant of the frame reads.              *)
(* ---------------------------------------------------------------------- *)
(* the globals a store must avoid: RenderKeep's footprint (core_ids, the  *)
(* level cells' read set), MWF's globals, the controllers (a_down), and   *)
(* gMarioPlatform's fact (plat_still) *)
Definition gs_bad : list ident :=
  core_ids ++ lvl_rd_ids ++ ObjExtBodies.mwf_syms
  ++ [mario._gControllers; PD._gMarioPlatform; OLP._gObjectPool].
Definition gs_ok (id : ident) : bool := negb (existsb (Pos.eqb id) gs_bad).

Lemma ne_of_ex : forall id x l, existsb (Pos.eqb id) l = false -> In x l -> id <> x.
Proof.
  intros id x l H Hin ->.
  assert (E : existsb (Pos.eqb x) l = true)
    by (apply existsb_exists; exists x; split; [ exact Hin | apply Pos.eqb_refl ]).
  congruence.
Qed.

Lemma gs_parts : forall id, gs_ok id = true ->
  existsb (Pos.eqb id) core_ids = false /\ existsb (Pos.eqb id) lvl_rd_ids = false
  /\ mem_id id ObjExtBodies.mwf_syms = false
  /\ existsb (Pos.eqb id) [mario._gControllers; PD._gMarioPlatform; OLP._gObjectPool] = false.
Proof.
  intros id H. unfold gs_ok, gs_bad in H. apply negb_true_iff in H.
  rewrite !existsb_app in H. apply orb_false_iff in H as (H1 & H).
  apply orb_false_iff in H as (H2 & H). apply orb_false_iff in H as (H3 & H4).
  exact (conj H1 (conj H2 (conj H3 H4))).
Qed.

Lemma In_of_ex : forall x l, existsb (Pos.eqb x) l = true -> In x l.
Proof.
  intros x l H. apply existsb_exists in H as (y & Hin & E). apply Pos.eqb_eq in E. subst y. exact Hin.
Qed.

Lemma vint_np : forall i b o, Vint i <> Vptr b o.
Proof. intros i b o E. discriminate E. Qed.

Lemma inj_nonptr : forall gp v, (forall b o, v <> Vptr b o) -> Val.inject gp v v.
Proof. intros gp v H. destruct v; try constructor. exfalso. exact (H b i eq_refl). Qed.

Lemma flat_bg : forall gp m b, closed_by gp m -> gp b <> None -> gp b = Some (b, 0).
Proof.
  intros gp m b (Hflat & _) H. destruct (gp b) as [[b' d] |] eqn:E; [ | contradiction ].
  destruct (Hflat _ _ _ E) as (-> & ->). reflexivity.
Qed.

(* a value whose pointer (if any) is mapped injects into itself (flat) *)
Lemma inj_symv : forall gp m v, closed_by gp m -> (forall b o, v = Vptr b o -> gp b <> None) ->
  Val.inject gp v v.
Proof.
  intros gp m v HC H. destruct v; try constructor.
  econstructor; [ exact (flat_bg gp m b HC (H b i eq_refl)) | ].
  change (Ptrofs.repr 0) with Ptrofs.zero. rewrite Ptrofs.add_zero. reflexivity.
Qed.

Section GS.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  Lemma Hsp : exists init, spawn_ok lp init bm bc oc0.
  Proof. exact (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0). Qed.

  Lemma symne : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 Ne E. subst b2. exact (Genv.global_addresses_distinct G Ne H1 H2 eq_refl). Qed.

  (* mem_ok across a store into a global MWF does not read, whose value is
     no pointer or (when the global's block is SafeB) a SafeB pointer:
     ObjExtBodies.safe_store_pres with R7's premise asked only of a SafeB
     target (2026-11-03) *)
  Lemma safe_store_g : forall g bg ch z v m1 m2,
      mem_id g ObjExtBodies.mwf_syms = false -> Genv.find_symbol G g = Some bg ->
      (SafeB bg -> forall bb oo, v = Vptr bb oo -> SafeB bb) ->
      Mem.store ch m1 bg z v = Some m2 ->
      mem_ok_lp bm MWF m1 -> mem_ok_lp bm MWF m2.
  Proof.
    intros g bg ch z v m1 m2 Hg Hfs Hsv Hst (Hvb & Hsat & HM).
    pose proof Hsp as Hsp0. pose proof Hsp as (init & _ & Hbm & Hbc & _).
    assert (Hne : forall id b, mem_id id ObjExtBodies.mwf_syms = true ->
                 Genv.find_symbol G id = Some b -> bg <> b)
      by (intros id b; exact (ObjExtBodies.np_ne lp g bg id b Hg Hfs)).
    assert (Hnbm : bg <> bm) by exact (Hne level_update._gMarioStates bm eq_refl Hbm).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (Hnbm Hb).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB (ObjExtBodies.ox_Hbc_bm lp bm bc oc0 Hsp0) m1 m2); [ .. | exact HM ].
      + intros b Hv. eapply Mem.store_valid_block_1; eauto.
      + intros v0 Hld. pose proof HM as (_ & R1 & _). apply R1.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left; congruence ].
      + intros ch1 b ofs v0 Hrow Hld.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left ].
        intro E. subst b.
        destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | [ Hfs2 | [ Hkt | Hab ] ] ] ] ] ].
        * exact (Hnbm Eb).
        * exact (Hne mario._gControllers bc eq_refl Hbc Eb).
        * exact (Hne mario._gMarioState bg eq_refl Hfs2 eq_refl).
        * exact (Hne interaction._gGlobalTimer bg eq_refl Hfs2 eq_refl).
        * exact (Hne interaction._sInteractionHandlers bg eq_refl Hfs2 eq_refl).
        * destruct Hkt as (gid2 & Hg2 & Hfs2).
          refine (Hne gid2 bg _ Hfs2 eq_refl).
          unfold ObjExtBodies.mwf_syms. rewrite ObjExtBodies.mem_id_app, Hg2. apply orb_true_r.
        * exact (Hne mario._gMarioAnimsBuf bg eq_refl Hab eq_refl).
      + intros b ofs b' o' Hs Hld.
        pose proof HM as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
        cbn in Hld.
        destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
          as [ (Evv & _ & Eb & _) | Hdis ].
        * subst b. exact (Hsv Hs _ _ Evv).
        * apply (R7 b ofs b' o' Hs). cbn.
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | exact Hdis ].
  Qed.

  (* mem_ok across an int store into a dynamic block (past every global):
     every MWF row is a global's block, and an int is no pointer
     (2026-11-06, for unload's respawn OR into a SpawnInfo cell) *)
  Lemma safe_store_dyn : forall bP ch z i m1 m2,
      Ple (Genv.genv_next G) bP ->
      Mem.store ch m1 bP z (Vint i) = Some m2 ->
      mem_ok_lp bm MWF m1 -> mem_ok_lp bm MWF m2.
  Proof.
    intros bP ch z i m1 m2 HP Hst (Hvb & Hsat & HM).
    pose proof Hsp as Hsp0. pose proof Hsp as (init & _ & Hbm & Hbc & _).
    assert (Hne : forall id b, Genv.find_symbol G id = Some b -> bP <> b).
    { intros id b Hs ->. pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Plt, Ple in *. lia. }
    assert (Hnbm : bP <> bm) by exact (Hne _ _ Hbm).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i0 _ [Hb _]. exact (Hnbm Hb).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB (ObjExtBodies.ox_Hbc_bm lp bm bc oc0 Hsp0) m1 m2); [ .. | exact HM ].
      + intros b Hv. eapply Mem.store_valid_block_1; eauto.
      + intros v0 Hld. pose proof HM as (_ & R1 & _). apply R1.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left; congruence ].
      + intros ch1 b ofs v0 Hrow Hld.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left ].
        intro E. subst b.
        destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | [ Hfs2 | [ Hkt | Hab ] ] ] ] ] ].
        * exact (Hnbm Eb).
        * exact (Hne _ _ Hbc Eb).
        * exact (Hne _ _ Hfs2 eq_refl).
        * exact (Hne _ _ Hfs2 eq_refl).
        * exact (Hne _ _ Hfs2 eq_refl).
        * destruct Hkt as (gid2 & _ & Hfs2). exact (Hne _ _ Hfs2 eq_refl).
        * exact (Hne _ _ Hab eq_refl).
      + intros b ofs b' o' Hs Hld.
        pose proof HM as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
        cbn in Hld.
        destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
          as [ (Evv & _) | Hdis ].
        * discriminate Evv.
        * apply (R7 b ofs b' o' Hs). cbn.
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | exact Hdis ].
  Qed.

  (* THE GLOBAL STORE: everything of Pobjl but obj_w, and the store's
     footprint (only bg changed).  2026-11-03: the value may be a pointer
     to a global's block that is SafeB whenever bg is (the update_objects
     store gObjectLists = gObjectListArray, ObjStores) *)
  Theorem gstore_core_p : forall id bg ch z v m m2,
    Genv.find_symbol G id = Some bg -> gs_ok id = true ->
    (forall b o, v = Vptr b o -> (exists idv, Genv.find_symbol G idv = Some b) /\ (SafeB bg -> SafeB b)) ->
    Mem.store ch m bg z v = Some m2 ->
    mem_ok_lp bm MWF m -> phiw lp bm m -> a_down_real bm m = false -> PlatformKeep.plat_still lp m ->
    mem_ok_lp bm MWF m2 /\ phiw lp bm m2 /\ a_down_real bm m2 = false /\ PlatformKeep.plat_still lp m2
    /\ (forall ch' b z', b <> bg -> Mem.load ch' m2 b z' = Mem.load ch' m b z').
  Proof.
    intros id bg ch z v m m2 Hs Hok Hv St Ok Hphi HD Hst.
    destruct (gs_parts id Hok) as (Hc & Hl & Hmw & Hx).
    assert (LO : forall ch' b z', b <> bg -> Mem.load ch' m2 b z' = Mem.load ch' m b z')
      by (intros ch' b z' Ne; apply (Mem.load_store_other _ _ _ _ _ _ St); left; exact Ne).
    assert (Nbm : bm <> bg)
      by (refine (symne _ _ _ _ Hbm_sym Hs (not_eq_sym (ne_of_ex _ _ _ Hc _))); apply In_of_ex; vm_compute; reflexivity).
    assert (Nbc : bc <> bg)
      by (refine (symne _ _ _ _ Hbc_sym Hs (not_eq_sym (ne_of_ex _ _ _ Hx _))); apply In_of_ex; vm_compute; reflexivity).
    destruct (PlatformKeep.plat_p_sym lp H12) as (bgp & Hgp).
    assert (Ngp : bgp <> bg)
      by (refine (symne _ _ _ _ Hgp Hs (not_eq_sym (ne_of_ex _ _ _ Hx _))); apply In_of_ex; vm_compute; reflexivity).
    split.
    { exact (safe_store_g id bg ch z v m m2 Hmw Hs (fun Hsb bb oo E => proj2 (Hv bb oo E) Hsb) St Ok). }
    split.
    { pose proof Hphi as (_ & _ & _ & _ & Hf & _).
      pose proof Hf as (Hgn & (d & FWF) & FD).
      pose proof (ff_Lo _ _ _ _ FWF) as Lmo. unfold FFW_OBJ in Lmo.
      assert (Nbo : fw_bo d <> bg)
        by (refine (symne _ _ _ _ (ff_Spool _ _ _ _ FWF) Hs (not_eq_sym (ne_of_ex _ _ _ Hx _))); apply In_of_ex; vm_compute; reflexivity).
      assert (HXs : forall id', In id' [id] -> existsb (Pos.eqb id') core_ids = false)
        by (intros id' [<- | []]; exact Hc).
      assert (HXl : forall id', In id' [id] -> existsb (Pos.eqb id') lvl_rd_ids = false)
        by (intros id' [<- | []]; exact Hl).
      assert (NB : Ple (Mem.nextblock m) (Mem.nextblock m2))
        by (rewrite (Mem.nextblock_store _ _ _ _ _ _ St); apply Ple_refl).
      assert (PM : forall b o k p, Plt b (Mem.nextblock m) -> Mem.perm m b o k p -> Mem.perm m2 b o k p)
        by (intros b o k p _ Hp; exact (Mem.perm_store_1 _ _ _ _ _ _ St _ _ _ _ Hp)).
      assert (LD : forall ch' b z', ~ rgb lp [id] b -> b <> bm -> (b <> fw_bo d \/ owin (fw_oo d) ch' z') ->
                Mem.load ch' m2 b z' = Mem.load ch' m b z').
      { intros ch' b z' Nr _ _. apply LO. intros ->. apply Nr. exists id. split; [ left; reflexivity | exact Hs ]. }
      assert (LM : forall ch' z', bmk ch' z' -> Mem.load ch' m2 bm z' = Mem.load ch' m bm z')
        by (intros ch' z' _; exact (LO _ _ _ Nbm)).
      assert (Nr : ~ rgb lp [id] bm) by exact (rgb_not lp [id] HXs _ bm Hbm_sym ltac:(vm_compute; reflexivity)).
      assert (Bmb : bm <> fw_bo d) by exact (not_eq_sym (ff_D1 _ _ _ _ FWF)).
      assert (RGa : forall b, rgb lp [id] b -> b <> fw_bo d /\ tab_apart G m b).
      { intros b (id' & Hin & Hs'). destruct Hin as [<- | []]. rewrite Hs in Hs'. injection Hs' as <-.
        split; [ exact (not_eq_sym Nbo) |
                 exact (tab_apart_global G m _ _ _ bg (Genv.genv_symb_range _ _ Hs) (ff_W _ _ _ _ FWF)) ]. }
      assert (CL : forall gp0, closed_by gp0 m -> gp0 (fw_bo d) <> None ->
                (forall id0 b, Genv.find_symbol G id0 = Some b -> gp0 b <> None) ->
                exists gp', (forall b, gp0 b <> None -> gp' b <> None) /\ closed_by gp' m2).
      { intros gp0 HC0 _ HS0. exists gp0. split; [ intros b H; exact H | ].
        refine (store_mapped_closed gp0 m ch bg z v m2 HC0 (flat_bg gp0 m bg HC0 (HS0 _ _ Hs)) _ St).
        apply (inj_symv gp0 m v HC0). intros b o E. destruct (proj1 (Hv b o E)) as (idv & Hsv).
        exact (HS0 _ _ Hsv). }
      assert (FR : forall bt0 ot0 k0, In k0 hs_ids ->
                Mem.load Mint32 m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 60) = Some (Vptr bt0 ot0) ->
                Mem.load Mint32 m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 72) = Some (Vint Int.zero) ->
                (exists f, -1 <= f <= hs_le k0
                   /\ Mem.load Mint16signed m (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 64) = Some (Vint (Int.repr f))) ->
                buf_ok m bt0 ot0 k0 -> Ptrofs.unsigned ot0 + BUFSZ < Ptrofs.modulus ->
                exists f, -1 <= f <= hs_le k0
                  /\ Mem.load Mint16signed m2 (fw_bo d) (Ptrofs.unsigned (fw_oo d) + 64) = Some (Vint (Int.repr f))).
      { intros bt0 ot0 k0 _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ]. rewrite (LO _ _ _ Nbo). exact L64. }
      exact (k_all_w lp bm [id] HXs HXl m m2 (fw_bo d) (fw_oo d) Lmo NB PM LD LM Hbm_sym Nr Bmb RGa CL FR Hphi
               (phiw_surf_apart lp bm _ m Hphi)). }
    split.
    { pose proof Ok as (_ & _ & HM).
      pose proof HM as (_ & _ & R2 & _).
      rewrite <- HD. unfold a_down_real. rewrite (LO Mptr bm 156 Nbm).
      destruct (Mem.load Mptr m bm 156) as [v' |] eqn:E; [ | reflexivity ].
      destruct v'; try reflexivity.
      destruct (R2 _ _ eq_refl) as (-> & _).
      rewrite (LO _ _ _ Nbc). reflexivity. }
    split.
    { intros bp v' Hbp Hl0. rewrite Hgp in Hbp. injection Hbp as <-.
      rewrite (LO _ _ _ Ngp) in Hl0.
      destruct (Hst bgp v' Hgp Hl0) as [Hz | (pb & po & -> & Hpb & Hk & Hal)]; [ left; exact Hz | right ].
      assert (Npb : pb <> bg)
        by (refine (symne _ _ _ _ Hpb Hs (not_eq_sym (ne_of_ex _ _ _ Hx _))); apply In_of_ex; vm_compute; reflexivity).
      exists pb, po. split; [ reflexivity | split; [ exact Hpb | split; [ | exact Hal ] ] ].
      intros k Hk0. cbn [Mem.loadv] in *. rewrite (LO _ _ _ Npb). exact (Hk k Hk0). }
    exact LO.
  Qed.

  Theorem gstore_core : forall id bg ch z v m m2,
    Genv.find_symbol G id = Some bg -> gs_ok id = true -> (forall b o, v <> Vptr b o) ->
    Mem.store ch m bg z v = Some m2 ->
    mem_ok_lp bm MWF m -> phiw lp bm m -> a_down_real bm m = false -> PlatformKeep.plat_still lp m ->
    mem_ok_lp bm MWF m2 /\ phiw lp bm m2 /\ a_down_real bm m2 = false /\ PlatformKeep.plat_still lp m2
    /\ (forall ch' b z', b <> bg -> Mem.load ch' m2 b z' = Mem.load ch' m b z').
  Proof.
    intros id bg ch z v m m2 Hs Hok Hv.
    exact (gstore_core_p id bg ch z v m m2 Hs Hok (fun b o E => False_ind _ (Hv b o E))).
  Qed.
End GS.

(* ---------------------------------------------------------------------- *)
(* 3. obj_w's surface clause across a NULL head: each listed surface's    *)
(*    object is read off the pools' block and the object pool, neither    *)
(*    the partition; a cleared head walks to the empty list.              *)
(* ---------------------------------------------------------------------- *)
Lemma surf_keep_hd : forall (ge : genv) bx m m2 pool,
  Genv.find_symbol ge SC._gDynamicSurfacePartition = Some bx ->
  Genv.find_symbol ge OLP._gObjectPool = Some pool ->
  (forall ch b z, b <> bx -> Mem.load ch m2 b z = Mem.load ch m b z) ->
  (forall z v, Mem.load Mint32 m2 bx z = Some v -> Mem.load Mint32 m bx z = Some v \/ v = Vint Int.zero) ->
  OW.surf_obj_ok ge pool m -> OW.surf_obj_ok ge pool m2.
Proof.
  intros ge bx m m2 pool Sbx Spool Hld Hbx (P & HP & G1 & G2 & W).
  assert (NP : P <> bx)
    by (intros ->; pose proof (Genv.genv_symb_range _ _ Sbx) as R; unfold Plt, Ple in *; lia).
  assert (Npo : pool <> bx)
    by (intros ->; refine (Genv.global_addresses_distinct ge _ Spool Sbx eq_refl); vm_compute; discriminate).
  assert (Kc : forall id ch v, Pos.eqb id SC._gDynamicSurfacePartition = false ->
             OW.gcell ge id ch v m -> OW.gcell ge id ch v m2).
  { intros id ch v Ne (b & Hsb & Lb). exists b. split; [ exact Hsb | ]. rewrite Hld; [ exact Lb | ].
    intros ->. assert (E : id = SC._gDynamicSurfacePartition) by (eapply Genv.genv_vars_inj; eauto).
    subst id. rewrite Pos.eqb_refl in Ne. discriminate Ne. }
  exists P. split; [ exact HP | ].
  split; [ exact (Kc surface_load._sSurfacePool _ _ eq_refl G1) | split; [ exact (Kc surface_load._sSurfaceNodePool _ _ eq_refl G2) | ] ].
  assert (SW : forall f v, OW.swalk P m2 f v = OW.swalk P m f v)
    by (apply OW.swalk_ext; intros ch z _ _; exact (Hld _ _ _ NP)).
  assert (SA : forall s, OW.surf_obj_at P pool m s -> OW.surf_obj_at P pool m2 s).
  { intros s (o & -> & N & H). exists o. split; [ reflexivity | split; [ exact N | ] ].
    rewrite (Hld _ _ _ NP).
    destruct H as [H | (k & Hk & Lk & A)]; [ left; exact H | right ].
    exists k. split; [ exact Hk | split; [ exact Lk | ] ].
    intros j Hj. rewrite (Hld _ _ _ Npo). exact (A j Hj). }
  intros id bp z hd Hin Hs L.
  assert (Lold : Mem.load Mint32 m bp z = Some hd \/ hd = Vint Int.zero).
  { destruct (peq bp bx) as [-> | Ne]; [ exact (Hbx z hd L) | left; rewrite <- (Hld _ _ _ Ne); exact L ]. }
  destruct Lold as [L0 | ->].
  - destruct (W id bp z hd Hin Hs L0) as (l & Hw & F). exists l. rewrite SW.
    split; [ exact Hw | exact (Forall_impl _ SA F) ].
  - exists nil. split; [ vm_compute; reflexivity | constructor ].
Qed.

(* the class tie's walk half (ObjWorld 3h) across the same store: a
   zeroed head walks to nothing, every other read is unchanged *)
Lemma cls_keep_hd : forall (ge : genv) bx m m2 pool mv,
  Genv.find_symbol ge SC._gDynamicSurfacePartition = Some bx ->
  (forall ch b z, b <> bx -> Mem.load ch m2 b z = Mem.load ch m b z) ->
  (forall z v, Mem.load Mint32 m2 bx z = Some v -> Mem.load Mint32 m bx z = Some v \/ v = Vint Int.zero) ->
  OW.cls_surf_at ge pool m mv -> OW.cls_surf_at ge pool m2 mv.
Proof.
  intros ge bx m m2 pool mv Sbx Hld Hbx C P id bp z hd l o k HP G1 G2 Hin Hs L Hw Ho N Hk Lo.
  assert (NP : P <> bx)
    by (intros ->; pose proof (Genv.genv_symb_range _ _ Sbx) as R; unfold Plt, Ple in *; lia).
  assert (Kc : forall id ch v, Pos.eqb id SC._gDynamicSurfacePartition = false ->
             OW.gcell ge id ch v m2 -> OW.gcell ge id ch v m).
  { intros id' ch v Ne (b & Hsb & Lb). exists b. split; [ exact Hsb | ]. rewrite <- Hld; [ exact Lb | ].
    intros ->. assert (E : id' = SC._gDynamicSurfacePartition) by (eapply Genv.genv_vars_inj; eauto).
    subst id'. rewrite Pos.eqb_refl in Ne. discriminate Ne. }
  rewrite (OW.swalk_ext P m m2 (fun ch z _ _ => Hld _ _ _ NP)) in Hw.
  rewrite (Hld _ _ _ NP) in Lo.
  assert (Lold : Mem.load Mint32 m bp z = Some hd \/ hd = Vint Int.zero).
  { destruct (peq bp bx) as [-> | Ne]; [ exact (Hbx z hd L) | left; rewrite <- (Hld _ _ _ Ne); exact L ]. }
  destruct Lold as [L0 | ->].
  - exact (C P id bp z hd l o k HP (Kc surface_load._sSurfacePool _ _ eq_refl G1) (Kc surface_load._sSurfaceNodePool _ _ eq_refl G2) Hin Hs L0 Hw Ho N Hk Lo).
  - assert (E : OW.swalk P m OW.SFUEL (Vint Int.zero) = Some nil) by (vm_compute; reflexivity).
    rewrite E in Hw. injection Hw as <-. destruct Ho.
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. THE CLEAR.                                                           *)
(* ---------------------------------------------------------------------- *)
Module SL := surface_load.

Lemma dm_cds : (prog_defmap SL.prog) ! OLP._clear_dynamic_surfaces
  = Some (Gfun (Internal SL.f_clear_dynamic_surfaces)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_csp : (prog_defmap SL.prog) ! SL._clear_spatial_partition
  = Some (Gfun (Internal SL.f_clear_spatial_partition)).
Proof. vm_compute. reflexivity. Qed.

Lemma scr_nx : forall s, In s (map BhvVM.v_s BhvVM.vm_tab) -> Pos.eqb s SC._gDynamicSurfacePartition = false.
Proof.
  intros s Hin. destruct (Pos.eqb s SC._gDynamicSurfacePartition) eqn:E; [ | reflexivity ].
  apply Pos.eqb_eq in E. subst s. exfalso.
  exact (PollKeep.not_in_of_existsb SC._gDynamicSurfacePartition (map BhvVM.v_s BhvVM.vm_tab)
           ltac:(vm_compute; reflexivity) Hin).
Qed.

Lemma eqb_of_notin : forall x l s, existsb (Pos.eqb x) l = false -> In s l -> Pos.eqb s x = false.
Proof.
  intros x l s H Hin. destruct (Pos.eqb s x) eqn:E; [ | reflexivity ].
  apply Pos.eqb_eq in E. subst s. exfalso. exact (ne_of_ex x x l H Hin eq_refl).
Qed.

Lemma symne_b : forall (ge : genv) id0 b0 id b, Genv.find_symbol ge id0 = Some b0 -> Genv.find_symbol ge id = Some b ->
  Pos.eqb id id0 = false -> b <> b0.
Proof.
  intros ge id0 b0 id b H0 H Hn ->. assert (E : id = id0) by (eapply Genv.genv_vars_inj; eauto).
  subst id. rewrite Pos.eqb_refl in Hn. discriminate Hn.
Qed.

Lemma glob_ne_dyn : forall (ge : genv) id b P, Genv.find_symbol ge id = Some b -> Ple (Genv.genv_next ge) P -> P <> b.
Proof. intros ge id b P Hs HP ->. pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Plt, Ple in *. lia. Qed.

Lemma ns_signed : Int.signed (Int.repr OW.NS) = OW.NS.
Proof. apply Int.signed_repr. unfold OW.NS. change Int.min_signed with (-2147483648). change Int.max_signed with 2147483647. lia. Qed.

Lemma ns_ctr : OW.NS <= OW.NS <= OW.NS + OW.DS.
Proof. pose proof OW.ctr_fits as (E & _). apply (f_equal fst) in E. cbn [fst] in E. rewrite E. unfold OW.NS. lia. Qed.

Section CK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* the object phase's invariant, without the surface premise Pobj
     derives from PhiW *)
  Definition Pc (m : mem) : Prop :=
    mem_ok_lp bm MWF m /\ phiw lp bm m /\ a_down_real bm m = false /\ PlatformKeep.plat_still lp m
    /\ OW.obj_w G bm m.

  (* the objects phase's carried fact at the link, HeightFrame.Pobj lp bm MWF
     (PhiW lp bm) obj_w, stated without HeightFrame (2026-11-07) so the
     objects step (ObjInv .. ObjStep) can sit below it: the same conjunction,
     convertible to it (PhiW's body is phiw's) *)
  Definition Pobjc (m : mem) : Prop :=
    mem_ok_lp bm MWF m /\ phiw lp bm m /\ a_down_real bm m = false /\ PlatformKeep.plat_still lp m
    /\ RenderKeep.surf_apart lp bm PlatformKeep.plat_gvars m /\ OW.obj_w G bm m.

  Lemma hsp : exists init, spawn_ok lp init bm bc oc0.
  Proof. exact (Hsp lp H12 bm Hbm_sym bc oc0 Hbc_sym Hoc0). Qed.

  (* ---- one NULL head ---- *)
  Lemma hstore_keep : forall bx m w m2,
    Genv.find_symbol G SC._gDynamicSurfacePartition = Some bx -> 0 <= w < 768 ->
    Mem.store Mint32 m bx (8 * w) (Vint Int.zero) = Some m2 -> Pc m -> Pc m2.
  Proof.
    intros bx m w m2 Sbx Hw St (Ok & Hphi & HD & Hst & How).
    destruct (head_store_k3 m bx w m2 (proj1 Hw) St) as (Hnb & Hperm & Hld & Hbx).
    assert (CLk : forall gp, closed_by gp m -> gp bx <> None -> closed_by gp m2)
      by (intros gp HC Hg; exact (store_mapped_closed gp m Mint32 bx (8 * w) _ m2 HC (flat_bg gp m bx HC Hg)
                                    (inj_nonptr gp _ (vint_np Int.zero)) St)).
    assert (NX : forall id b, Genv.find_symbol G id = Some b -> Pos.eqb id SC._gDynamicSurfacePartition = false ->
               b <> bx).
    { intros id b Hs Hn ->. assert (E : id = SC._gDynamicSurfacePartition) by (eapply Genv.genv_vars_inj; eauto).
      subst id. rewrite Pos.eqb_refl in Hn. discriminate Hn. }
    assert (Nbm : bm <> bx) by exact (NX _ _ Hbm_sym eq_refl).
    split.
    { exact (ObjExtBodies.safe_store_pres lp bm bc oc0 SafeB hsp SC._gDynamicSurfacePartition bx Mint32 (8 * w)
               _ m m2 ltac:(vm_compute; reflexivity) Sbx (fun bb oo E => False_ind _ (vint_np Int.zero bb oo E)) St Ok). }
    split; [ exact (phiw_keep3 lp m m2 bx Sbx Hnb Hperm Hld Hbx bm Hbm_sym CLk Hphi) | ].
    split.
    { pose proof Ok as (_ & _ & HM). pose proof HM as (_ & _ & R2 & _).
      rewrite <- HD. unfold a_down_real. rewrite (Hld Mptr bm 156 Nbm).
      destruct (Mem.load Mptr m bm 156) as [v' |] eqn:E; [ | reflexivity ].
      destruct v'; try reflexivity.
      destruct (R2 _ _ eq_refl) as (-> & _).
      rewrite (Hld _ _ _ (NX _ _ Hbc_sym eq_refl)). reflexivity. }
    split.
    { intros bp v' Hbp Hl0. rewrite (Hld _ _ _ (NX _ _ Hbp eq_refl)) in Hl0.
      destruct (Hst bp v' Hbp Hl0) as [Hz | (pb & po & -> & Hpb & Hk & Hal)]; [ left; exact Hz | right ].
      exists pb, po. split; [ reflexivity | split; [ exact Hpb | split; [ | exact Hal ] ] ].
      intros k Hk0. cbn [Mem.loadv] in *. rewrite (Hld _ _ _ (NX _ _ Hpb eq_refl)). exact (Hk k Hk0). }
    apply (PollKeep.obj_w_slots_g m m2 G bm); [ | | | | | | exact How ].
    - intros id b Hin Hn Hs ch z. apply Hld. apply (NX id b Hs).
      cbn [PollKeep.ow_xc existsb] in Hn. apply orb_false_iff in Hn as (_ & Hn).
      apply orb_false_iff in Hn as (_ & Hn). apply orb_false_iff in Hn as (Hn & _). exact Hn.
    - intros pool Hs. apply PollKeep.SKp_full. intros ch z. apply Hld. exact (NX _ _ Hs eq_refl).
    - intros pool Hs. split; [ exact (surf_keep_hd G bx m m2 pool Sbx Hs Hld Hbx) | ].
      intros mv. exact (cls_keep_hd G bx m m2 pool mv Sbx Hld Hbx).
    - intros (a & (b & Hsb & Lb) & Hb). exists a. split; [ | exact Hb ].
      exists b. split; [ exact Hsb | ]. rewrite (Hld _ _ _ (NX _ _ Hsb eq_refl)). exact Lb.
    - intros z _. exact (Hld _ _ _ Nbm).
    - intros s b Hin Hs ch z. apply Hld. exact (NX s b Hs (scr_nx s Hin)).
  Qed.
  Lemma cenv_G : forall id co, (prog_comp_env SL.prog) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof.
    intros id co Hco. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp SL.prog id co (linked12_LO_surface_load lp H12) Hco).
  Qed.
  Lemma csp_G : forall b fd, Genv.find_symbol G SL._clear_spatial_partition = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SL.f_clear_spatial_partition.
  Proof. exact (ObjPhase.fun_of lp SL.prog _ _ (linked12_LO_surface_load lp H12) dm_csp). Qed.

  Lemma sc_int : forall i mm, sem_cast (Vint i) tint tint mm = Some (Vint i).
  Proof. intros i mm. reflexivity. Qed.

  (* THE CLEAR: the real clear_dynamic_surfaces keeps the invariant and
     leaves the counter at NS, unless a time stop is on *)
  Theorem clear_keeps : forall m t m' vr,
    eval_funcall function_entry2 G m (Internal SL.f_clear_dynamic_surfaces) [] t m' vr ->
    Pc m -> Pc m' /\ OW.post_clear G m'.
  Proof.
    intros m t m' vr Hev HP.
    destruct (cds_run G cenv_G csp_G m t m' vr Hev)
      as [(-> & bts & x & Sts & Lts & Ex)
         | (bns & bsa & v1 & w1 & m1 & bnn & bna & v2 & w2 & m2 & bdp
            & Sns & Ssa & L1 & C1 & St1 & Snn & Sna & L2 & C2 & St2 & Sdp & CD)].
    { split; [ exact HP | left ]. unfold OW.tsa. rewrite Sts, Lts, Ex. reflexivity. }
    destruct HP as (Ok & Hphi & HD & Hst & How).
    pose proof How as (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & _ & _ & _ & _ & _ & _ & C).
    pose proof (OW.ow_spool _ _ _ _ _ _ _ _ _ _ _ _ C) as (P & HP & _ & _ & _ & (b4 & S4 & L4) & (b5 & S5 & L5)).
    rewrite Sns in S4. injection S4 as <-. rewrite Snn in S5. injection S5 as <-.
    rewrite L4 in L1. injection L1 as <-. rewrite sc_int in C1. injection C1 as <-.
    (* ---- gSurfacesAllocated = NS ---- *)
    destruct (gstore_core lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 SL._gSurfacesAllocated bsa Mint32 0 _ m m1
                Ssa ltac:(vm_compute; reflexivity) (vint_np _) St1 Ok Hphi HD Hst)
      as (Ok1 & Hphi1 & HD1 & Hst1 & LO1).
    assert (NA : forall id b, Genv.find_symbol G id = Some b -> Pos.eqb id SL._gSurfacesAllocated = false -> b <> bsa)
      by (intros id b Hs Hn; exact (symne_b G _ _ id b Ssa Hs Hn)).
    assert (Lsa1 : Mem.load Mint32 m1 bsa 0 = Some (Vint (Int.repr OW.NS)))
      by (rewrite (Mem.load_store_same _ _ _ _ _ _ St1); reflexivity).
    assert (How1 : OW.obj_w G bm m1).
    { apply (PollKeep.obj_w_slots_g m m1 G bm); [ | | | | | | exact How ].
      - intros id b Hin Hn Hs ch z. apply LO1. apply (NA id b Hs).
        cbn [PollKeep.ow_xc existsb] in Hn. apply orb_false_iff in Hn as (_ & Hn).
        apply orb_false_iff in Hn as (Hn & _). exact Hn.
      - intros pool' Hs. apply PollKeep.SKp_full. intros ch z. apply LO1. exact (NA _ _ Hs eq_refl).
      - intros pool' Hs.
        assert (K1 : forall id b, In id OW.surf_gids -> Genv.find_symbol G id = Some b ->
                       forall ch z, Mem.load ch m1 b z = Mem.load ch m b z).
        { intros id b Hin Hs' ch z. apply LO1. apply (NA id b Hs').
          unfold OW.surf_gids, FloorList.part_ids in Hin. cbn [In] in Hin.
          destruct Hin as [<- | [<- | [<- | [<- | []]]]]; reflexivity. }
        split.
        + apply (OW.surf_obj_ok_ext G pool' m m1 K1).
          * intros P0 HP0 _ _ ch z _. apply LO1. exact (glob_ne_dyn G _ _ P0 Ssa HP0).
          * intros k j _ _. apply LO1. exact (NA _ _ Hs eq_refl).
        + intros mv. apply (OW.cls_surf_ext G pool' m m1 mv K1).
          intros P0 HP0 _ _ ch z _. apply LO1. exact (glob_ne_dyn G _ _ P0 Ssa HP0).
      - intros _. exists (Int.repr OW.NS). split; [ exists bsa; exact (conj Ssa Lsa1) | ].
        rewrite ns_signed. exact ns_ctr.
      - intros z _. apply LO1. exact (NA _ _ Hbm_sym eq_refl).
      - intros s b Hin Hs ch z. apply LO1. apply (NA s b Hs).
        exact (eqb_of_notin SL._gSurfacesAllocated (map BhvVM.v_s BhvVM.vm_tab) s ltac:(vm_compute; reflexivity) Hin). }
    (* ---- gSurfaceNodesAllocated = NN ---- *)
    assert (Nnn : bnn <> bsa) by exact (NA _ _ Snn eq_refl).
    rewrite (LO1 _ _ _ Nnn), L5 in L2. injection L2 as <-. rewrite sc_int in C2. injection C2 as <-.
    destruct (gstore_core lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 SL._gSurfaceNodesAllocated bna Mint32 0 _ m1 m2
                Sna ltac:(vm_compute; reflexivity) (vint_np _) St2 Ok1 Hphi1 HD1 Hst1)
      as (Ok2 & Hphi2 & HD2 & Hst2 & LO2).
    assert (NN : forall id b, Genv.find_symbol G id = Some b -> Pos.eqb id SL._gSurfaceNodesAllocated = false -> b <> bna)
      by (intros id b Hs Hn; exact (symne_b G _ _ id b Sna Hs Hn)).
    assert (How2 : OW.obj_w G bm m2).
    { apply (PollKeep.obj_w_unch m1 m2 G bm); [ | | | | exact How1 ].
      - intros id b Hin Hs ch z. apply LO2. apply (NN id b Hs).
        exact (eqb_of_notin SL._gSurfaceNodesAllocated PollKeep.ow_ids id ltac:(vm_compute; reflexivity) Hin).
      - intros b Hb ch z. apply LO2. exact (glob_ne_dyn G _ _ b Sna Hb).
      - intros z _. apply LO2. exact (NN _ _ Hbm_sym eq_refl).
      - intros s b Hin Hs ch z. apply LO2. apply (NN s b Hs).
        exact (eqb_of_notin SL._gSurfaceNodesAllocated (map BhvVM.v_s BhvVM.vm_tab) s ltac:(vm_compute; reflexivity) Hin). }
    assert (Lsa2 : Mem.load Mint32 m2 bsa 0 = Some (Vint (Int.repr OW.NS)))
      by (rewrite LO2; [ exact Lsa1 | exact (NN _ _ Ssa eq_refl) ]).
    (* ---- the 768 NULL heads ---- *)
    pose proof CD as (_ & _ & _ & _ & R).
    assert (Nsd : bsa <> bdp) by exact (symne_b G _ _ _ _ Sdp Ssa eq_refl).
    destruct (R (fun mm => Pc mm /\ Mem.load Mint32 mm bsa 0 = Some (Vint (Int.repr OW.NS)))) as (Pm & Lsa).
    - intros mm w mm2 Hw (Hpc & L) St. split; [ exact (hstore_keep bdp mm w mm2 Sdp Hw St Hpc) | ].
      rewrite (Mem.load_store_other _ _ _ _ _ _ St) by (left; exact Nsd). exact L.
    - exact (conj (conj Ok2 (conj Hphi2 (conj HD2 (conj Hst2 How2)))) Lsa2).
    - split; [ exact Pm | right ]. unfold OW.ctrv. rewrite Ssa, Lsa. exact ns_signed.
  Qed.
  (* ---- a store of an int into a global no clause reads (2026-11-03:
     the object phase's own counters, gObjectCounter and
     gAreaUpdateCounter) ---- *)
  Theorem gstore_keep : forall id bg ch z i m m2,
    Genv.find_symbol G id = Some bg -> gs_ok id = true ->
    existsb (Pos.eqb id) PollKeep.ow_ids = false ->
    existsb (Pos.eqb id) (map BhvVM.v_s BhvVM.vm_tab) = false ->
    Mem.store ch m bg z (Vint i) = Some m2 -> Pc m -> Pc m2.
  Proof.
    intros id bg ch z i m m2 Hs Hok Hw Hsc St (Ok & Hphi & HD & Hst & How).
    destruct (gstore_core lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 id bg ch z _ m m2 Hs Hok (vint_np i) St
                Ok Hphi HD Hst) as (Ok2 & Hphi2 & HD2 & Hst2 & LO).
    destruct (gs_parts id Hok) as (Hc & _).
    assert (NI : forall id' b, Genv.find_symbol G id' = Some b -> Pos.eqb id' id = false -> b <> bg)
      by (intros id' b Hs' Hn; exact (symne_b G _ _ id' b Hs Hs' Hn)).
    refine (conj Ok2 (conj Hphi2 (conj HD2 (conj Hst2 _)))).
    apply (PollKeep.obj_w_unch m m2 G bm); [ | | | | exact How ].
    - intros id' b Hin Hs' ch' z'. apply LO. apply (NI id' b Hs'). exact (eqb_of_notin id PollKeep.ow_ids id' Hw Hin).
    - intros b Hb ch' z'. apply LO. exact (glob_ne_dyn G _ _ b Hs Hb).
    - intros z' _. apply LO. apply (NI _ _ Hbm_sym).
      apply (eqb_of_notin id core_ids _ Hc). apply In_of_ex. vm_compute. reflexivity.
    - intros s b Hin Hs' ch' z'. apply LO. apply (NI s b Hs'). exact (eqb_of_notin id _ s Hsc Hin).
  Qed.

  (* area_update_objects' counter statement: gAreaUpdateCounter++ is ONE
     u16 store of an int into gAreaUpdateCounter *)
  Lemma auo_counter_store : forall le m t le' m' out,
    exec_stmt function_entry2 G empty_env le m ObjPhase.auo_counter t le' m' out ->
    exists b i, Genv.find_symbol G area._gAreaUpdateCounter = Some b
      /\ Mem.store Mint16unsigned m b 0 (Vint i) = Some m'.
  Proof.
    intros le m t le' m' out Hx. unfold ObjPhase.auo_counter in Hx.
    apply RenderAnim.seq_inv in Hx as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
    - apply RenderAnim.set_inv in H1 as (v & _ & -> & -> & _).
      apply RenderAnim.assign_inv in H2 as (b & o & bf & v2 & v' & Hl & _ & Hc & Ha & _ & _).
      apply RenderAnim.lv_gvar in Hl as (Hs & -> & ->); [ | apply PTree.gempty ].
      cbn [typeof] in Hc, Ha.
      apply (RenderAnim.store_by_value G tushort _ _ _ _ _ _ Mint16unsigned eq_refl eq_refl) in Ha.
      destruct v2; cbn in Hc; try discriminate Hc. injection Hc as <-.
      eexists; eexists. split; [ exact Hs | exact Ha ].
    - apply RenderAnim.set_inv in H1 as (_ & _ & _ & _ & E). exfalso. exact (Hn E).
  Qed.

  Theorem counter_keeps : forall le m t le' m' out,
    exec_stmt function_entry2 G empty_env le m ObjPhase.auo_counter t le' m' out -> Pc m -> Pc m'.
  Proof.
    intros le m t le' m' out Hx HP. destruct (auo_counter_store le m t le' m' out Hx) as (b & i & Hs & St).
    exact (gstore_keep area._gAreaUpdateCounter b Mint16unsigned 0 i m m' Hs ltac:(vm_compute; reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) St HP).
  Qed.

  (* the walks' own store: gObjectCounter = <an int> *)
  Theorem ctr_keeps : forall m b c m',
    Genv.find_symbol G OLP._gObjectCounter = Some b -> Mem.store Mint32 m b 0 (Vint c) = Some m' -> Pc m -> Pc m'.
  Proof.
    intros m b c m' Hs St HP.
    exact (gstore_keep OLP._gObjectCounter b Mint32 0 c m m' Hs ltac:(vm_compute; reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) St HP).
  Qed.
End CK.
