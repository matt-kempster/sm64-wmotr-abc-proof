(* ====================================================================== *)
(* BlindKeep (GOAL 2 objects, 2026-11-07): the object phase's invariant   *)
(* is blind to a private frame block.                                     *)
(*                                                                        *)
(* The frame block b of update_objects (cycleCounts[30]) and of the list   *)
(* walks (filler[4]) is PRIVATE (ObjPhase.noref): a closing injection g   *)
(* maps every symbol and leaves b unmapped (Generic.ClosedMem.closed_by),  *)
(* so no readable byte of a block reached from a global by loads names b.  *)
(* Every fact of the invariant (ClearKeep.Pc plus the surface premise:    *)
(* GOAL 1's mem_ok, PhiW, a_down, plat_still, obj_w) reads globals and     *)
(* blocks reached from them by loads, and GOAL 1's chase set, which b is   *)
(* not in (a frame block is fresh, every SafeB block was valid before).   *)
(* So a change confined to b (alloc, the stores cycleCounts[i] = .., the  *)
(* free) keeps the invariant: blind_pobj.                                 *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Values AST Ctypes Clight ClightBigstep
  Memory Maps Globalenvs Linking Events Errors.
From SM64.Generated Require mario level_update object_list_processor area camera.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve
  ActionValueFrame NoAImpliesNoFlyLinked AGates MWFReal SpawnInit.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec FloorHeight AirMatch FfWorld AnimWorld.
From SM64.Proofs.WMotRRequiresA Require FfComplete.
From SM64.Proofs.WMotRRequiresA Require AnimKeep RenderKeep PlatformKeep ObjWorld PollKeep.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed Generic.ClosedFrame.
Import ListNotations.

Local Open Scope Z_scope.

Section BK.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* the private block and the change confined to it *)
  Variables (g : meminj) (m m' : mem) (b : block).
  Hypothesis Hc : closed_by g m.
  Hypothesis Hs : syms_mapped G g.
  Hypothesis Hgb : g b = None.
  Hypothesis U : Mem.unchanged_on (fun x _ => x <> b) m m'.
  Hypothesis Hsafe : ~ SafeB b.

  (* ---- 1. reading through the closing injection ---- *)
  Lemma mp_sym : forall id x, Genv.find_symbol G id = Some x -> g x <> None.
  Proof. intros id x H. exact (Hs id x H). Qed.

  Lemma ld : forall ch x z, g x <> None -> Mem.load ch m' x z = Mem.load ch m x z.
  Proof. exact (cf_load g m m' b Hc Hgb U). Qed.

  Lemma ld_sym : forall id x ch z, Genv.find_symbol G id = Some x -> Mem.load ch m' x z = Mem.load ch m x z.
  Proof. intros id x ch z H. exact (ld ch x z (mp_sym id x H)). Qed.

  Lemma rch : forall ch x z y o, g x <> None -> Mem.load ch m x z = Some (Vptr y o) -> g y <> None.
  Proof. exact (cf_reach g m Hc). Qed.

  Lemma Mbm : g bm <> None.
  Proof. exact (mp_sym _ _ Hbm_sym). Qed.

  Lemma Mbc : g bc <> None.
  Proof. exact (mp_sym _ _ Hbc_sym). Qed.

  Lemma nb : Ple (Mem.nextblock m) (Mem.nextblock m').
  Proof. exact (cf_nb m m' b U). Qed.

  Lemma vb : forall x, Mem.valid_block m x -> Mem.valid_block m' x.
  Proof. exact (cf_valid' m m' b U). Qed.

  (* a block valid in m other than b reads the same *)
  Lemma ld_ne : forall ch x z, Mem.valid_block m x -> x <> b -> Mem.load ch m' x z = Mem.load ch m x z.
  Proof.
    intros ch x z Hv Hne. eapply Mem.load_unchanged_on_1; [ exact U | exact Hv | ].
    intros i _. exact Hne.
  Qed.

  Lemma Hbc_bm : bc <> bm.
  Proof.
    intros E. pose proof (Genv.genv_vars_inj _ _ _ Hbc_sym (eq_trans Hbm_sym (f_equal Some (eq_sym E)))) as Ei.
    vm_compute in Ei. discriminate Ei.
  Qed.

  (* ---- 2. GOAL 1's mem_ok ---- *)
  Lemma blind_mem_ok : mem_ok_lp bm MWF m -> mem_ok_lp bm MWF m'.
  Proof.
    intros (Hv & Hnt & M). split; [ exact (vb _ Hv) | split ].
    - intros v L. rewrite (ld _ _ _ Mbm) in L. exact (Hnt v L).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB Hbc_bm m m' vb); [ | | | exact M ].
      + intros v L. rewrite (ld _ _ _ Mbm) in L. exact (mwf_real_inp lp bm bc oc0 SafeB m M v L).
      + intros ch x ofs v Hx L. rewrite ld in L; [ exact L | ].
        destruct Hx as [ (-> & _) | [ -> | [ H | [ H | [ H | [ (gid & _ & H) | H ] ] ] ] ] ];
          first [ exact Mbm | exact Mbc | exact (mp_sym _ _ H) ].
      + intros x ofs y o Hx L. apply (mwf_real_chase_step lp bm bc oc0 SafeB m x ofs y o M Hx).
        cbn [Mem.loadv] in L |- *. rewrite ld_ne in L; [ exact L | | ].
        * exact (mwf_real_safe_valid lp bm bc oc0 SafeB m M x Hx).
        * intros ->. exact (Hsafe Hx).
  Qed.

  (* ---- 3. PhiW: the height cells, the world, the apartness facts ---- *)
  Lemma blind_hi : forall R, height_invariant bm R m -> height_invariant bm R m'.
  Proof.
    intros R (A & c & (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8) & Hb).
    split; [ intros v L; rewrite (ld _ _ _ Mbm) in L; exact (A v L) | ].
    exists c. split; [ | exact Hb ].
    unfold read_cells. rewrite !(ld _ bm _ Mbm).
    split; [ exact H1 | split; [ exact H2 | split; [ exact H3 | split; [ exact H4 | split; [ exact H5 | split; [ exact H6 | ] ] ] ] ] ].
    exists bo, oo. split; [ exact H7 | ].
    rewrite (ld _ bo _ (rch _ _ _ _ _ Mbm H7)). exact H8.
  Qed.

  Lemma surf_k : forall sv, (forall sb so, sv = Vptr sb so -> g sb <> None) -> surface_ok m sv -> surface_ok m' sv.
  Proof.
    intros sv Hm [Hn | (x & o & t & -> & Hl & Hin)]; [ left; exact Hn | right ].
    exists x, o, t. rewrite (ld _ _ _ (Hm x o eq_refl)). auto.
  Qed.

  Lemma surf_nn_k : forall sv, (forall sb so, sv = Vptr sb so -> g sb <> None) ->
    surface_nonnull_ok m sv -> surface_nonnull_ok m' sv.
  Proof.
    intros sv Hm (x & o & t & -> & Hl & Hin).
    exists x, o, t. rewrite (ld _ _ _ (Hm x o eq_refl)). auto.
  Qed.

  Lemma coll_k : forall cv, (forall cb co, cv = Vptr cb co -> g cb <> None) -> coll_obj_ok m cv -> coll_obj_ok m' cv.
  Proof.
    intros cv Hm (x & o & t & -> & Hl & Hin & Hp & Hcn). pose proof (Hm x o eq_refl) as M.
    exists x, o, t. split; [ reflexivity | ]. rewrite (ld _ _ _ M). split; [ exact Hl | ]. split; [ exact Hin | ]. split.
    - intros Ht. destruct (Hp Ht) as (base & top & Hb & K1 & K2 & K3). exists base, top. rewrite !(ld _ x _ M). tauto.
    - intros Ht. destruct (Hcn Ht) as (y & Hy & K1). exists y. rewrite (ld _ x _ M). tauto.
  Qed.

  Lemma ptr_mp : forall ch x z v, g x <> None -> Mem.load ch m x z = Some v ->
    forall y o, v = Vptr y o -> g y <> None.
  Proof. intros ch x z v Mx L y o ->. exact (rch _ _ _ _ _ Mx L). Qed.

  Lemma blind_ww : wmotr_world bm m -> wmotr_world bm m'.
  Proof.
    intros (W1 & W2 & W3 & W4 & W5 & W6 & (mb & mo & s & n & L1 & L2 & L3 & L4 & L5 & L6)).
    assert (Mm : g mb <> None) by exact (rch _ _ _ _ _ Mbm L1).
    split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ].
    - revert W1; apply wall_ok_keep; intros W1. intros v L. rewrite (ld _ _ _ Mbm) in L. exact (surf_k v (ptr_mp _ _ _ _ Mbm L) (W1 v L)).
    - revert W2; apply ceil_ok_keep; intros W2. intros v L. rewrite (ld _ _ _ Mbm) in L. exact (surf_k v (ptr_mp _ _ _ _ Mbm L) (W2 v L)).
    - intros v L. rewrite (ld _ _ _ Mbm) in L. exact (surf_nn_k v (ptr_mp _ _ _ _ Mbm L) (W3 v L)).
    - rewrite (ld _ _ _ Mbm). exact W4.
    - rewrite (ld _ _ _ Mbm). exact W5.
    - rewrite (ld _ _ _ Mbm). exact W6.
    - exists mb, mo, s, n. rewrite (ld _ bm _ Mbm), !(ld _ mb _ Mm).
      split; [ exact L1 | split; [ exact L2 | split; [ exact L3 | split; [ exact L4 | split; [ exact L5 | ] ] ] ] ].
      intros i v Hi L. rewrite (ld _ _ _ Mm) in L. exact (coll_k v (ptr_mp _ _ _ _ Mm L) (L6 i v Hi L)).
  Qed.

  Lemma blind_aa : anim_apart lp bm m -> anim_apart lp bm m'.
  Proof.
    intros A ab bt ot Sab L. rewrite (ld_sym _ _ _ _ Sab) in L.
    destruct (A ab bt ot Sab L) as (A1 & A2). split.
    - intros off sb so Hoff L2. rewrite (ld _ _ _ Mbm) in L2. exact (A1 off sb so Hoff L2).
    - intros mb mo i cb co L1 Hi L2. rewrite (ld _ _ _ Mbm) in L1.
      rewrite (ld _ _ _ (rch _ _ _ _ _ Mbm L1)) in L2. exact (A2 mb mo i cb co L1 Hi L2).
  Qed.

  Lemma blind_ma : mobj_apart bm m -> mobj_apart bm m'.
  Proof.
    intros A mb mo L. rewrite (ld _ _ _ Mbm) in L. destruct (A mb mo L) as (A1 & A2 & A3).
    split; [ exact A1 | split ].
    - intros off sb so Hoff L2. rewrite (ld _ _ _ Mbm) in L2. exact (A2 off sb so Hoff L2).
    - intros i cb co Hi L2. rewrite (ld _ _ _ (rch _ _ _ _ _ Mbm L)) in L2. exact (A3 i cb co Hi L2).
  Qed.

  (* ---- 4. the frame world ffw: re-closed by g, the frame block a region ---- *)
  Lemma ph_mapped : forall hd, part_head G m hd -> forall x o, hd = Vptr x o -> g x <> None.
  Proof.
    intros hd (id & bp & o & _ & Hsy & L) x o' ->. cbn [Mem.loadv] in L.
    exact (rch _ _ _ _ _ (mp_sym _ _ Hsy) L).
  Qed.

  Lemma ol_mapped : forall hd s, on_list m hd s -> (forall x o, hd = Vptr x o -> g x <> None) ->
    forall y o, s = Vptr y o -> g y <> None.
  Proof.
    intros hd s OL. induction OL as [bn on s L | bn on nx s L OL IH]; intros Hh y o E; subst s.
    - cbn [Mem.loadv] in L. exact (rch _ _ _ _ _ (Hh bn on eq_refl) L).
    - refine (IH _ y o eq_refl). intros x o' ->. cbn [Mem.loadv] in L. exact (rch _ _ _ _ _ (Hh bn on eq_refl) L).
  Qed.

  Lemma wf_priv : forall (A : block -> Prop) hd, wf_list m A hd -> (forall x o, hd = Vptr x o -> g x <> None) ->
    wf_list m (fun x => x = b) hd.
  Proof.
    intros A hd W. induction W as [| bn on nx Hv Hav Hl W IH]; intros Hh; [ constructor | ].
    pose proof (Hh bn on eq_refl) as Mb.
    apply wf_cons with nx; [ exact Hv | exact (cf_ne g b Hgb bn Mb) | exact Hl | ].
    apply IH. intros x o ->. cbn [Mem.loadv] in Hl. exact (rch _ _ _ _ _ Mb Hl).
  Qed.

  Lemma Wff_regp : forall gp rl, Wff G m gp SZ_SURFACE rl -> Wff G m g SZ_SURFACE rl.
  Proof.
    intros gp rl (W1 & W2 & W3 & W4 & W5 & W6 & W7).
    refine (conj W1 (conj W2 (conj W3 (conj _ (conj W5 (conj W6 W7)))))).
    intros hd s Hh Ho. destruct (W4 hd s Hh Ho) as (x & o & -> & A & B & C & _).
    exists x, o. split; [ reflexivity | split; [ exact A | split; [ exact B | split; [ exact C | ] ] ] ].
    exact (ol_mapped hd _ Ho (ph_mapped hd Hh) x o eq_refl).
  Qed.

  Lemma tab_priv : forall gp rl, Wff G m gp SZ_SURFACE rl -> tab_apart G m b.
  Proof.
    intros gp rl (W1 & W2 & W3 & W4 & W5 & W6 & W7) hd Hh. split.
    - exact (wf_priv _ hd (W3 hd Hh) (ph_mapped hd Hh)).
    - intros x o Ho E. subst x. exact (ol_mapped hd _ Ho (ph_mapped hd Hh) b o eq_refl Hgb).
  Qed.

  Definition bblk : list (option val) := [Some (Vptr b Ptrofs.zero)].

  Lemma ne_rl : forall rl x, ~ rblk (rl ++ bblk) x -> x <> b.
  Proof. intros rl x H ->. apply H. exists Ptrofs.zero. apply in_or_app. right. left. reflexivity. Qed.

  Lemma ld_rl : forall rl ch x z, Plt x (Mem.nextblock m) -> ~ rblk (rl ++ bblk) x ->
    Mem.load ch m' x z = Mem.load ch m x z.
  Proof. intros rl ch x z Hv Hr. exact (ld_ne ch x z Hv (ne_rl rl x Hr)). Qed.

  (* FfWorld.Wff_keep2 over the regions rl ++ [b], without its permission
     premise on b (a free drops b's): only the globals' permissions are read *)
  Lemma Wff_keep_b : forall rl, Wff G m g SZ_SURFACE (rl ++ bblk) -> Wff G m' g SZ_SURFACE (rl ++ bblk).
  Proof.
    intros rl (W1 & W2 & W3 & W4 & W5 & W6 & W7).
    set (rl' := rl ++ bblk) in *.
    pose proof (ld_rl rl) as Hld. fold rl' in Hld.
    assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
              Plt bp (Mem.nextblock m) /\ ~ rblk rl' bp)
      by (intros id bp Hi Hsy; destruct (W2 id bp Hi Hsy) as (A & B & _); exact (conj A B)).
    assert (OL : forall hd s, part_head G m' hd -> on_list m' hd s -> part_head G m hd /\ on_list m hd s).
    { intros hd s Hh Ho'. pose proof (part_back2 G m m' rl' Hld hd Hp Hh) as Hh0. split; [ exact Hh0 | ].
      apply (ol_transfer_v m _ hd (W3 hd Hh0) m' s); [ | exact Ho' ].
      intros x z Hx Hv. apply Hld; [ exact Hv | ]. intros Hr. apply Hx. right. exact Hr. }
    split; [| split; [| split; [| split; [| split; [| split]]]]].
    - intros id sz Hi. destruct (W1 id sz Hi) as (x & Hsy & Hr). exists x. split; [ exact Hsy | ].
      exact (cf_range_perm g m m' b Hc Hgb U x 0 sz Cur Writable (mp_sym _ _ Hsy) Hr).
    - intros id bp Hi Hsy. destruct (W2 id bp Hi Hsy) as (A & B & C).
      split; [ exact (Plt_Ple_trans _ _ _ A nb) | split; assumption ].
    - intros hd Hh. apply (wf_fwd2 m m' rl' nb Hld _ hd); [ | exact (W3 hd (part_back2 G m m' rl' Hld hd Hp Hh)) ].
      intros x Hx Hr. apply Hx. right. exact Hr.
    - intros hd s Hh Ho'. destruct (OL hd s Hh Ho') as (Hh0 & Ho0).
      destruct (W4 hd s Hh0 Ho0) as (x & o & -> & Hpl & Hsz & Hr & Hgx).
      exists x, o. split; [ reflexivity | ]. split; [ exact (Plt_Ple_trans _ _ _ Hpl nb) | ].
      split; [ exact Hsz | ]. split; [ exact Hr | exact Hgx ].
    - intros hd x o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0).
      destruct (W5 hd x o Hh0 Ho0) as (t & Hl & Hin). exists t. split; [ | exact Hin ].
      destruct (W4 hd _ Hh0 Ho0) as (x' & o' & E & Hpl & _ & Hr & _). injection E as <- <-.
      rewrite Hld by assumption. exact Hl.
    - intros hd Hh. pose proof (part_back2 G m m' rl' Hld hd Hp Hh) as Hh0. split.
      + apply (wf_list_mono m' (fun x => (is_static G x \/ rblk rl' x) \/ Plt x (Genv.genv_next G))).
        * intros x H. right. exact H.
        * apply (wf_fwd2 m m' rl' nb Hld _ hd); [ intros x Hx Hr; apply Hx; left; right; exact Hr | ].
          exact (wf_list_or m _ _ hd (W3 hd Hh0) (proj1 (W6 hd Hh0))).
      + intros x o Ho'. destruct (OL hd _ Hh Ho') as (_ & Ho0). exact (proj2 (W6 hd Hh0) x o Ho0).
    - destruct W7 as (Wsz & Wdp). split; [ exact Wsz | ].
      apply (FfComplete.dp_lists_keep G m m' (rblk rl')); [ | | | | exact Wdp ].
      + intros ch x z Hv Hx. exact (Hld ch x z Hv Hx).
      + intros bp Hsy. exact (proj1 (proj2 (W2 _ _ (or_introl eq_refl) Hsy))).
      + intros hd Hh. apply (wf_list_mono m (fun x => is_static G x \/ rblk rl' x)); [ | exact (W3 hd Hh) ].
        intros x Hr. right. exact Hr.
      + intros hd x o Hh Hol.
        destruct (W4 hd _ Hh Hol) as (x' & o' & E & _ & _ & Hr & _). injection E as <- _. exact Hr.
  Qed.

  Lemma floor_data_b : forall gp rl, Wff G m gp SZ_SURFACE (rl ++ bblk) -> floor_data G m -> floor_data G m'.
  Proof.
    intros gp rl (W1 & W2 & W3 & W4 & _) FD h (hd & s & xv & zv & Hh & Hol & Hhit).
    set (rl' := rl ++ bblk) in *.
    pose proof (ld_rl rl) as Hld. fold rl' in Hld.
    assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
              Plt bp (Mem.nextblock m) /\ ~ rblk rl' bp)
      by (intros id bp Hi Hsy; destruct (W2 id bp Hi Hsy) as (A & B & _); exact (conj A B)).
    pose proof (floor_back2 G m m' rl' Hld hd Hp Hh) as Hh0.
    assert (Hol0 : on_list m hd s).
    { apply (ol_transfer_v m _ hd (W3 hd (floor_head_part _ _ _ Hh0)) m' s); [ | exact Hol ].
      intros x z Hx Hv. apply Hld; [ exact Hv | ]. intros Hr. apply Hx. right. exact Hr. }
    destruct (W4 hd s (floor_head_part _ _ _ Hh0) Hol0) as (x & o & -> & Hpl & _ & Hr & _).
    apply FD. exists hd, (Vptr x o), xv, zv. split; [ exact Hh0 | ]. split; [ exact Hol0 | ].
    apply (hit16_transfer m' m x o xv zv h); [ | exact Hhit ].
    intros ch z. apply Hld; assumption.
  Qed.

  (* FfWorld.ffw_rebuild, with the new closing injection mapping the
     symbols in place of growing the old one *)
  Theorem ffw_rebuild_g : forall d gp',
    ffw_facts G bm m d ->
    Ple (Genv.genv_next G) (Mem.nextblock m') ->
    syms_mapped G gp' -> closed_by gp' m' ->
    Wff G m' gp' SZ_SURFACE (ff_rl_of bm d) -> floor_data G m' ->
    ffw_kept bm d m m' -> ffw_surf_ok G bm d m m' ->
    ffw G bm m'.
  Proof.
    intros d gp' F Hgn HS' HC' W' FD' K ((fl' & Lf' & Wf') & WC' & SP').
    assert (KM : forall z ch, In (z, ch) ffw_bm_cells -> Mem.load ch m' bm z = Mem.load ch m bm z)
      by (intros z ch H; apply K; left; split; [ reflexivity | exact H ]).
    assert (HM' : gp' bm <> None) by exact (HS' _ _ Hbm_sym).
    split; [ exact Hgn | ]. split; [ | exact FD' ].
    exists (mk_ffw_wit gp' (fw_bfi d) (fw_bmiss d) (fw_bcalls d) (fw_bsin d) (fw_ab d) (fw_biom d)
              (fw_bmq d) (fw_brm d) (fw_blk d) (fw_bpc d) (fw_bsr d) (fw_bsrc d) (fw_bsms d) (fw_bbs d)
              (fw_bfa d) (fw_bo d) (fw_oo d) (fw_bt d) (fw_ot d) fl' (fw_ar d) (fw_inp d) (fw_ctl d)).
    pose proof F as F0. destruct F0.
    eapply mk_ffw_facts; ffw_simpl;
      first [ assumption | exact HC' | exact W' | exact Lf' | exact WC' | exact SP' | exact HM' | exact HS'
            | exact (wfl_mono _ _ _ _ nb Wf')
            | apply (wblk_mono _ _ _ _ _ nb); assumption
            | rewrite KM by (unfold ffw_bm_cells; cbn [In]; auto 10); assumption
            | rewrite K by (solve [ right; left; auto ]); assumption
            | rewrite K by (solve [ right; right; right; left; auto ]); assumption
            | rewrite K by (solve [ right; right; right; right; left; auto ]); assumption
            | rewrite K by (solve [ right; right; right; right; right; auto ]); assumption
            | let i := fresh "i" in let cb := fresh "cb" in let co := fresh "co" in
              let Hi := fresh "Hi" in let Hl := fresh "Hl" in
              intros i cb co Hi Hl; rewrite K in Hl;
              [ match goal with H : forall i' cb' co', 0 <= i' < 4 -> _ -> _ |- _ =>
                  exact (H i cb co Hi Hl) end
              | right; right; left; split; [ reflexivity | ]; split; [ reflexivity | ]; exists i; auto ] ].
  Qed.

  Lemma blind_ffw : ffw G bm m -> ffw G bm m'.
  Proof.
    intros (Hgn & (d & F) & FD).
    set (rl := ff_rl_of bm d).
    pose proof (Wff_regp _ _ (ff_W _ _ _ _ F)) as W0. fold rl in W0.
    assert (Sy : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp -> bp <> b)
      by (intros id bp _ Hsy E; subst bp; exact (mp_sym _ _ Hsy Hgb)).
    pose proof (Wff_blk G m g SZ_SURFACE rl b Ptrofs.zero Sy (tab_priv _ _ W0) W0) as W1.
    pose proof (Wff_keep_b rl W1) as W2.
    apply (ffw_rebuild_g d g F (Ple_trans _ _ _ Hgn nb) Hs (cf_closed g m m' b Hc Hgb U)).
    - refine (Wff_mono G m' g SZ_SURFACE (rl ++ bblk) rl _ W2).
      intros x (o & Ho). exists o. apply in_or_app. left. exact Ho.
    - exact (floor_data_b g rl W1 FD).
    - intros ch x z Hr. apply ld. ffw_read_split Hr;
        first [ exact Mbm | exact (mp_sym _ _ (ff_S5 _ _ _ _ F)) | exact (rch _ _ _ _ _ Mbm (ff_Lo _ _ _ _ F)) ].
    - apply (ffw_surf_ok_kept G bm m m' d F). intros z ch _. exact (ld ch bm z Mbm).
  Qed.

  (* ---- 5. the partition apartness, the animation world, the level cells ---- *)
  Lemma wf_k : forall (A : block -> Prop) hd, wf_list m A hd ->
    (forall x o, hd = Vptr x o -> g x <> None) -> wf_list m' A hd.
  Proof.
    intros A hd W. induction W as [| bn on nx Hv Hav Hl W IH]; intros Hh; [ constructor | ].
    pose proof (Hh bn on eq_refl) as Mb.
    apply wf_cons with nx; [ exact (vb _ Hv) | exact Hav | | ].
    - cbn [Mem.loadv] in *. rewrite (ld _ _ _ Mb). exact Hl.
    - apply IH. intros x o ->. cbn [Mem.loadv] in Hl. exact (rch _ _ _ _ _ Mb Hl).
  Qed.

  Lemma ol_back : forall hd s, on_list m' hd s -> (forall x o, hd = Vptr x o -> g x <> None) -> on_list m hd s.
  Proof.
    intros hd s OL. induction OL as [bn on s L | bn on nx s L OL IH]; intros Hh;
      pose proof (Hh bn on eq_refl) as Mb; cbn [Mem.loadv] in L; rewrite (ld _ _ _ Mb) in L.
    - apply ol_here. exact L.
    - apply ol_next with nx; [ exact L | ]. apply IH. intros x o ->. exact (rch _ _ _ _ _ Mb L).
  Qed.

  Lemma ph_back : forall hd, part_head G m' hd -> part_head G m hd.
  Proof.
    intros hd (id & bp & o & Hin & Hsy & L). exists id, bp, o. split; [ exact Hin | ]. split; [ exact Hsy | ].
    cbn [Mem.loadv] in *. rewrite (ld_sym _ _ _ _ Hsy) in L. exact L.
  Qed.

  Lemma tab_k : forall x, tab_apart G m x -> tab_apart G m' x.
  Proof.
    intros x T hd Hh. pose proof (ph_back hd Hh) as Hh0. destruct (T hd Hh0) as (T1 & T2). split.
    - exact (wf_k _ hd T1 (ph_mapped hd Hh0)).
    - intros y o Ho. exact (T2 y o (ol_back hd _ Ho (ph_mapped hd Hh0))).
  Qed.

  Lemma blind_aw : AnimWorld.anim_w G bm m -> AnimWorld.anim_w G bm m'.
  Proof.
    intros (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & St).
    destruct B as (S1 & S2 & S3 & L0 & L8 & Lm & Sy & D1 & D2 & D3 & D4 & (D5 & RG) & Z1 & Z2 & Z3 & P & T & GA & TA & AC & SM).
    assert (Mab : g ab <> None) by exact (mp_sym _ _ S1).
    assert (Mga : g bga <> None) by exact (mp_sym _ _ S2).
    assert (Mtab : g btab <> None) by exact (rch _ _ _ _ _ Mab L0).
    assert (Mbt : g bt <> None) by exact (rch _ _ _ _ _ Mab L8).
    assert (Mmb : g mb <> None) by exact (rch _ _ _ _ _ Mbm Lm).
    assert (Kt : forall ch o, Mem.load ch m' btab o = Mem.load ch m btab o) by (intros ch o; exact (ld _ _ _ Mtab)).
    assert (Kg : forall ch o, Mem.load ch m' bga o = Mem.load ch m bga o) by (intros ch o; exact (ld _ _ _ Mga)).
    exists ab, bga, bauc, btab, otab, bt, ot, mb, mo. split.
    - refine (conj S1 (conj S2 (conj S3 (conj _ (conj _ (conj _ (conj Sy (conj D1 (conj D2 (conj D3 (conj D4
               (conj (conj D5 _) (conj Z1 (conj Z2 (conj Z3 (conj _ (conj _ (conj _ (conj _ (conj _ SM)))))))))))))))))))).
      + rewrite (ld _ _ _ Mab). exact L0.
      + rewrite (ld _ _ _ Mab). exact L8.
      + rewrite (ld _ _ _ Mbm). exact Lm.
      + intros id x Hin Hsy. destruct (RG id x Hin Hsy) as (Ne & TAx). exact (conj Ne (tab_k x TAx)).
      + intros i Hi. exact (proj1 (cf_perm g m m' b Hc Hgb U bt i Cur Readable Mbt) (P i Hi)).
      + destruct T as (T1 & T2 & T3). unfold tab_ok. rewrite !Kt.
        refine (conj T1 (conj T2 _)). intros j o s' Hj. rewrite !Kt. exact (T3 j o s' Hj).
      + destruct GA as (G1 & G2). split.
        * intros o ch z Hin. rewrite Kg. exact (G1 o ch z Hin).
        * intros i Hi. exact (proj1 (cf_perm g m m' b Hc Hgb U bga i Cur Readable Mga) (G2 i Hi)).
      + exact (tab_k btab TA).
      + intros off x o Hoff Hl. rewrite (ld _ _ _ Mbm) in Hl. exact (AC off x o Hoff Hl).
    - intros a La Hin. rewrite (ld _ _ _ Mbm) in La.
      eapply anim_st_keep; [ exact (St a La Hin) | exact (ld _ _ _ Mab) | | ].
      + intros o ch _. exact (ld _ _ _ Mmb).
      + intros k rel ch v _ _. exact (ld _ _ _ Mbt).
  Qed.

  Lemma blind_uo : used_ok bm m -> used_ok bm m'.
  Proof.
    apply used_ok_keep.
    - intros o ch _. exact (ld _ _ _ Mbm).
    - intros ub uo L _ z _. exact (ld _ _ _ (rch _ _ _ _ _ Mbm L)).
    - intros mb mo L. exact (ld _ _ _ (rch _ _ _ _ _ Mbm L)).
    - intros mb mo L i _. exact (ld _ _ _ (rch _ _ _ _ _ Mbm L)).
  Qed.

  Lemma blind_lw : lvl_w G m -> lvl_w G m'.
  Proof.
    apply lvl_w_unch.
    - intros x ch z [ (id & _ & H) | [ (id & _ & H) | [ (co & ga & bad & o & Sg & Lg & Lc) | (id & _ & H) ] ] ];
        [ exact (ld_sym _ _ _ _ H) | exact (ld_sym _ _ _ _ H) | | exact (ld_sym _ _ _ _ H) ].
      exact (ld _ _ _ (rch _ _ _ _ _ (rch _ _ _ _ _ (mp_sym _ _ Sg) Lg) Lc)).
    - intros ab Sa. exact (ld_sym _ _ _ _ Sa).
  Qed.

  Lemma blind_phiw : RenderKeep.phiw lp bm m -> RenderKeep.phiw lp bm m'.
  Proof.
    intros (H1 & H2 & H3 & H4 & H5 & H6 & H7 & H8).
    exact (conj (blind_hi _ H1) (conj (blind_ww H2) (conj (blind_aa H3) (conj (blind_ma H4)
            (conj (blind_ffw H5) (conj (blind_uo H6) (conj (blind_aw H7) (blind_lw H8)))))))).
  Qed.

  (* ---- 6. the A gate, the platform, the object world ---- *)
  Lemma blind_ad : a_down_real bm m = false -> a_down_real bm m' = false.
  Proof.
    unfold a_down_real. rewrite (ld _ _ _ Mbm).
    destruct (Mem.load Mptr m bm 156) as [v|] eqn:L; [ | exact (fun H => H) ].
    destruct v as [ | i | l | f | s | xb xo ]; try exact (fun H => H).
    rewrite (ld _ _ _ (rch _ _ _ _ _ Mbm L)). exact (fun H => H).
  Qed.

  Lemma blind_ps : PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp m'.
  Proof.
    intros P bp v Hsy L. rewrite (ld_sym _ _ _ _ Hsy) in L.
    destruct (P bp v Hsy L) as [E | (pb & po & E & Sp & K & A)]; [ left; exact E | right ].
    exists pb, po. split; [ exact E | ]. split; [ exact Sp | ]. split; [ | exact A ].
    intros k Hk. cbn [Mem.loadv] in *. rewrite (ld_sym _ _ _ _ Sp). exact (K k Hk).
  Qed.

  Lemma blind_ow : ObjWorld.obj_w G bm m -> ObjWorld.obj_w G bm m'.
  Proof.
    apply (PollKeep.obj_w_slots_c m m' G bm).
    - intros id x _ _ Hsy ch z. exact (ld_sym _ _ _ _ Hsy).
    - intros pool Hsy ch k off _ _ _ _. exact (ld_sym _ _ _ _ Hsy).
    - intros pool Hsy. split.
      + apply ObjWorld.surf_obj_ok_ext; [ intros id x _ Hx ch z; exact (ld_sym _ _ _ _ Hx) | |
                                         intros k j _ _; exact (ld_sym _ _ _ _ Hsy) ].
        intros P _ (x & Hx & L) _ ch z _. exact (ld _ _ _ (rch _ _ _ _ _ (mp_sym _ _ Hx) L)).
      + intros mv. apply ObjWorld.cls_surf_ext; [ intros id x _ Hx ch z; exact (ld_sym _ _ _ _ Hx) | ].
        intros P _ (x & Hx & L) _ ch z _. exact (ld _ _ _ (rch _ _ _ _ _ (mp_sym _ _ Hx) L)).
    - intros (a & (x & Hx & L) & R). exists a. split; [ | exact R ].
      exists x. rewrite (ld_sym _ _ _ _ Hx). exact (conj Hx L).
    - intros z _. exact (ld _ _ _ Mbm).
    - intros s x _ Hx ch z. exact (ld_sym _ _ _ _ Hx).
    - intros pool rs Hsy C k Hk. destruct (C k Hk) as (n & Ln & Rn). exists n.
      rewrite (ld_sym _ _ _ _ Hsy). exact (conj Ln Rn).
    - intros pool gmo Hp Hg C k Hk Lg i Hi. rewrite (ld_sym _ _ _ _ Hg) in Lg.
      destruct (C k Hk Lg i Hi) as (v & Lv & Sv). exists v. rewrite (ld_sym _ _ _ _ Hp). exact (conj Lv Sv).
  Qed.

  (* THE LEMMA: the object phase's invariant (ClearKeep.Pc's conjunction)
     is blind to the private block b *)
  Theorem blind_pc :
    mem_ok_lp bm MWF m /\ RenderKeep.phiw lp bm m /\ a_down_real bm m = false
      /\ PlatformKeep.plat_still lp m /\ ObjWorld.obj_w G bm m ->
    mem_ok_lp bm MWF m' /\ RenderKeep.phiw lp bm m' /\ a_down_real bm m' = false
      /\ PlatformKeep.plat_still lp m' /\ ObjWorld.obj_w G bm m'.
  Proof.
    intros (M & Ph & A & P & O).
    exact (conj (blind_mem_ok M) (conj (blind_phiw Ph) (conj (blind_ad A) (conj (blind_ps P) (blind_ow O))))).
  Qed.
End BK.
