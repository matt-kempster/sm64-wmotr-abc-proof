(* ===================================================================== *)
(* PlatformEff (GOAL 2): the memory effect of the platform step, as a    *)
(* relation over CompCert memories (2026-10-23).                         *)
(*                                                                       *)
(* The real apply_platform_displacement (PlatformWalk) allocates its     *)
(* eight locals, stores into them, into platform_displacement.c's        *)
(* D_8032FEC0 and into Mario's pos[0..2], and frees the locals.  The y   *)
(* store writes back the value it read three statements earlier         *)
(* (get_mario_pos then set_mario_pos with y untouched).  plat_eff is     *)
(* what such a run leaves: the old blocks keep their permissions and,    *)
(* off D's block and Mario's x / z cells, their loads; the locals are    *)
(* gone (no permission on a block the entry memory did not have).       *)
(* bmw is the part of gMarioStates that is kept: everything but          *)
(* pos[0] (60) and pos[2] (68), with pos[1] (64) kept as a float load.   *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Floats Values AST Memory Ctypes Clight Maps.
Import ListNotations.
Local Open Scope Z_scope.

Definition bmw (ch : memory_chunk) (z : Z) : Prop :=
  z + size_chunk ch <= 60 \/ 72 <= z \/ (ch = Mfloat32 /\ z = 64).

Lemma bmw_y : bmw Mfloat32 64.
Proof. right. right. split; reflexivity. Qed.
Lemma bmw_lo : forall ch z, z + size_chunk ch <= 60 -> bmw ch z.
Proof. intros ch z H. left. exact H. Qed.
Lemma bmw_hi : forall ch z, 72 <= z -> bmw ch z.
Proof. intros ch z H. right. left. exact H. Qed.

(* the window as a checker: a numeral cell is decided by vm_compute on a
   bool (unifying against bmw_y / the Z.le bodies normalises the offsets
   inside the unifier and can run for hours) *)
Definition bmwb (ch : memory_chunk) (z : Z) : bool :=
  (z + size_chunk ch <=? 60) || (72 <=? z)
  || (if chunk_eq ch Mfloat32 then Z.eqb z 64 else false).

Lemma bmwb_ok : forall ch z, bmwb ch z = true -> bmw ch z.
Proof.
  intros ch z H. unfold bmwb in H. apply orb_true_iff in H as [H | H].
  - apply orb_true_iff in H as [H | H].
    + left. apply Z.leb_le. exact H.
    + right. left. apply Z.leb_le. exact H.
  - destruct (chunk_eq ch Mfloat32) as [-> | _]; [| discriminate H].
    right. right. split; [ reflexivity | apply Z.eqb_eq; exact H ].
Qed.

(* a cell at a numeral offset (or at one of a few, by a disjunction in
   the context) is in the window *)
Ltac bmw_c := apply bmwb_ok; vm_compute; reflexivity.
Ltac bmw_t := first
  [ bmw_c
  | match goal with
    | H : ?z = _ \/ _ |- bmw _ ?z => destruct H as [-> | [-> | ->]]; bmw_c
    | H : ?z = _ \/ _ |- bmw _ ?z => destruct H as [-> | ->]; bmw_c
    end ].

Section EFF.
Variables (bm bD nb : block).

(* the stores of the platform step's body *)
Inductive sop : mem -> mem -> Prop :=
  | sop_local : forall m ch b z v m', Ple nb b -> Mem.store ch m b z v = Some m' -> sop m m'
  | sop_D : forall m ch z v m', (forall b o, v <> Vptr b o) -> Mem.store ch m bD z v = Some m' -> sop m m'
  | sop_xz : forall m z v m', (z = 60 \/ z = 68) -> Mem.store Mfloat32 m bm z v = Some m' -> sop m m'
  | sop_y : forall m f m', Mem.load Mfloat32 m bm 64 = Some (Vsingle f) ->
      Mem.store Mfloat32 m bm 64 (Vsingle f) = Some m' -> sop m m'.

Inductive sruns : mem -> mem -> Prop :=
  | sr_refl : forall m, sruns m m
  | sr_step : forall m m1 m2, sop m m1 -> sruns m1 m2 -> sruns m m2.

Lemma sop_nb : forall m m', sop m m' -> Mem.nextblock m' = Mem.nextblock m.
Proof. intros m m' H; inversion H; subst; eapply Mem.nextblock_store; eauto. Qed.

Lemma sop_perm : forall m m', sop m m' ->
  forall b ofs k p, Mem.perm m b ofs k p <-> Mem.perm m' b ofs k p.
Proof.
  intros m m' H b ofs k p; inversion H; subst; split; intros;
    solve [ eapply Mem.perm_store_1; eassumption | eapply Mem.perm_store_2; eassumption ].
Qed.

Lemma sop_ld : forall m m', sop m m' ->
  forall ch b z, Plt b nb -> b <> bD -> b <> bm -> Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros m m' H ch b z Hb HD Hm; inversion H; subst;
    (eapply Mem.load_store_other; [ eassumption | left ]).
  - intro E; subst; match goal with Hp : Ple nb ?x, Hq : Plt ?x nb |- _ =>
      exact (Plt_strict x (Plt_Ple_trans _ _ _ Hq Hp)) end.
  - exact HD.
  - exact Hm.
  - exact Hm.
Qed.

Lemma sop_lm : forall m m', sop m m' -> Plt bm nb -> bm <> bD ->
  forall ch z, bmw ch z -> Mem.load ch m' bm z = Mem.load ch m bm z.
Proof.
  intros m m' H Hb HD ch z Hw; inversion H; subst.
  - eapply Mem.load_store_other; [ eassumption | left ].
    intro E; subst; match goal with Hp : Ple nb ?x, Hq : Plt ?x nb |- _ =>
      exact (Plt_strict x (Plt_Ple_trans _ _ _ Hq Hp)) end.
  - eapply Mem.load_store_other; [ eassumption | left; exact HD ].
  - eapply Mem.load_store_other; [ eassumption | right ].
    unfold bmw in Hw. cbn [size_chunk].
    destruct Hw as [Hw | [Hw | (-> & ->)]]; cbn [size_chunk]; lia.
  - destruct Hw as [Hw | [Hw | (-> & ->)]].
    + eapply Mem.load_store_other; [ eassumption | right; left; cbn [size_chunk]; lia ].
    + eapply Mem.load_store_other; [ eassumption | right; right; cbn [size_chunk]; lia ].
    + erewrite Mem.load_store_same by eassumption. symmetry. assumption.
Qed.

(* a pointer read from bD after the step was there before (bD only gets an integer) *)
Lemma sop_pD : forall m m', sop m m' -> Plt bD nb -> bm <> bD ->
  forall ch z b' o', Mem.load ch m' bD z = Some (Vptr b' o') -> Mem.load ch m bD z = Some (Vptr b' o').
Proof.
  intros m m' H HD Nbm ch z b' o' Hl; inversion H; subst.
  - rewrite <- Hl. symmetry. eapply Mem.load_store_other; [ eassumption | left ].
    intro E; subst; match goal with Hp : Ple nb ?x, Hq : Plt ?x nb |- _ =>
      exact (Plt_strict x (Plt_Ple_trans _ _ _ Hq Hp)) end.
  - match goal with Hs : Mem.store _ _ _ _ _ = Some _, Hv : forall b o, _ <> Vptr b o |- _ =>
      destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hs Hl) as [(Ev & _) | Ho];
      [ exfalso; exact (Hv _ _ Ev)
      | rewrite <- Hl; symmetry; exact (Mem.load_store_other _ _ _ _ _ _ Hs _ _ _ Ho) ] end.
  - rewrite <- Hl. symmetry. eapply Mem.load_store_other; [ eassumption | left; exact (not_eq_sym Nbm) ].
  - rewrite <- Hl. symmetry. eapply Mem.load_store_other; [ eassumption | left; exact (not_eq_sym Nbm) ].
Qed.

Lemma sruns_pD : forall m m', sruns m m' -> Plt bD nb -> bm <> bD ->
  forall ch z b' o', Mem.load ch m' bD z = Some (Vptr b' o') -> Mem.load ch m bD z = Some (Vptr b' o').
Proof.
  intros m m' H; induction H; intros HD Nbm ch z b' o' Hl; [ exact Hl |].
  eapply sop_pD; eauto.
Qed.

Lemma sruns_nb : forall m m', sruns m m' -> Mem.nextblock m' = Mem.nextblock m.
Proof. intros m m' H; induction H; [ reflexivity | rewrite IHsruns; eapply sop_nb; eauto ]. Qed.

Lemma sruns_perm : forall m m', sruns m m' ->
  forall b ofs k p, Mem.perm m b ofs k p <-> Mem.perm m' b ofs k p.
Proof.
  intros m m' H; induction H; intros b ofs k p; [ tauto |].
  rewrite (sop_perm _ _ H b ofs k p). apply IHsruns.
Qed.

Lemma sruns_ld : forall m m', sruns m m' ->
  forall ch b z, Plt b nb -> b <> bD -> b <> bm -> Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros m m' H; induction H; intros ch b z Hb HD Hm; [ reflexivity |].
  rewrite IHsruns by assumption. eapply sop_ld; eauto.
Qed.

Lemma sruns_lm : forall m m', sruns m m' -> Plt bm nb -> bm <> bD ->
  forall ch z, bmw ch z -> Mem.load ch m' bm z = Mem.load ch m bm z.
Proof.
  intros m m' H; induction H; intros Hb HD ch z Hw; [ reflexivity |].
  rewrite IHsruns by assumption. eapply sop_lm; eauto.
Qed.
End EFF.

(* ---- the call's frame: the locals' release ---- *)

(* a released block's freed range stays without permission through further frees *)
Lemma free_list_gone : forall l m m' b lo hi ofs k p,
  Mem.free_list m l = Some m' -> In (b, lo, hi) l -> lo <= ofs < hi -> ~ Mem.perm m' b ofs k p.
Proof.
  induction l as [| [[b1 lo1] hi1] l IH]; intros m m' b lo hi ofs k p Hf Hin Ho; [ destruct Hin |].
  cbn in Hf. destruct (Mem.free m b1 lo1 hi1) as [m1|] eqn:E; [| discriminate].
  destruct Hin as [Eq | Hin].
  - injection Eq as -> -> ->. intros Hp.
    assert (Hfp : forall l' mm mm', Mem.free_list mm l' = Some mm' -> Mem.perm mm' b ofs k p ->
                    Mem.perm mm b ofs k p).
    { induction l' as [| [[b2 lo2] hi2] l' IH']; intros mm mm' H H'; cbn in H.
      - injection H as <-. exact H'.
      - destruct (Mem.free mm b2 lo2 hi2) as [mm1|] eqn:E2; [| discriminate].
        eapply Mem.perm_free_3; [ exact E2 | eapply IH'; eauto ]. }
    exact (Mem.perm_free_2 _ _ _ _ _ E ofs k p Ho (Hfp _ _ _ Hf Hp)).
  - eapply IH; eauto.
Qed.

Lemma free_list_perm_back : forall l m m' b ofs k p,
  Mem.free_list m l = Some m' -> Mem.perm m' b ofs k p -> Mem.perm m b ofs k p.
Proof.
  induction l as [| [[b1 lo1] hi1] l IH]; intros m m' b ofs k p Hf Hp; cbn in Hf.
  - injection Hf as <-. exact Hp.
  - destruct (Mem.free m b1 lo1 hi1) as [m1|] eqn:E; [| discriminate].
    eapply Mem.perm_free_3; [ exact E | eapply IH; eauto ].
Qed.

Lemma free_list_nb : forall l m m', Mem.free_list m l = Some m' -> Mem.nextblock m' = Mem.nextblock m.
Proof.
  induction l as [| [[b1 lo1] hi1] l IH]; intros m m' Hf; cbn in Hf.
  - injection Hf as <-. reflexivity.
  - destruct (Mem.free m b1 lo1 hi1) as [m1|] eqn:E; [| discriminate].
    rewrite (IH _ _ Hf). eapply Mem.nextblock_free; eauto.
Qed.

(* freeing blocks at or above nb keeps the blocks below *)
Lemma free_list_old : forall nb l m m',
  Mem.free_list m l = Some m' -> (forall b lo hi, In (b, lo, hi) l -> Ple nb b) ->
  (forall b ofs k p, Plt b nb -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
  /\ (forall ch b z, Plt b nb -> Mem.load ch m' b z = Mem.load ch m b z).
Proof.
  intros nb. induction l as [| [[b1 lo1] hi1] l IH]; intros m m' Hf Hl; cbn in Hf.
  - injection Hf as <-. split; auto.
  - destruct (Mem.free m b1 lo1 hi1) as [m1|] eqn:E; [| discriminate].
    assert (N : forall b, Plt b nb -> b <> b1).
    { intros b Hb ->. apply (Plt_strict b1).
      eapply Plt_Ple_trans; [ exact Hb | exact (Hl b1 lo1 hi1 (or_introl eq_refl)) ]. }
    destruct (IH m1 m' Hf (fun b lo hi H => Hl b lo hi (or_intror H))) as (P1 & L1).
    split.
    + intros b ofs k p Hb Hp. apply P1; [ exact Hb |]. eapply Mem.perm_free_1; eauto.
    + intros ch b z Hb. rewrite L1 by exact Hb. eapply Mem.load_free; eauto.
Qed.

(* ---- the call's frame: the locals' allocation ---- *)
Section AV.
Variable ge : genv.

Lemma av_other : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
  forall id, ~ In id (map fst vars) -> e ! id = e0 ! id.
Proof.
  intros e0 m vars e m1 H. induction H; intros id0 Hn; [ reflexivity |].
  cbn in Hn. rewrite IHalloc_variables by tauto. apply PTree.gso. intros ->. tauto.
Qed.

Lemma av_nb : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
  Ple (Mem.nextblock m) (Mem.nextblock m1).
Proof.
  intros e0 m vars e m1 H. induction H; [ apply Ple_refl |].
  eapply Ple_trans; [| exact IHalloc_variables ].
  rewrite (Mem.nextblock_alloc _ _ _ _ _ H). apply Ple_succ.
Qed.

Lemma av_old : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
  (forall b ofs k p, Mem.perm m b ofs k p -> Mem.perm m1 b ofs k p)
  /\ (forall ch b z, Plt b (Mem.nextblock m) -> Mem.load ch m1 b z = Mem.load ch m b z).
Proof.
  intros e0 m vars e m1 H. induction H; [ split; auto |].
  destruct IHalloc_variables as (P1 & L1). split.
  - intros b0 ofs k p Hp. apply P1. eapply Mem.perm_alloc_1; eauto.
  - intros ch b0 z Hb. rewrite L1.
    + eapply Mem.load_alloc_unchanged; eauto.
    + rewrite (Mem.nextblock_alloc _ _ _ _ _ H). apply Plt_trans_succ. exact Hb.
Qed.

Lemma av_fresh : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
  forall nb, Ple nb (Mem.nextblock m) -> (forall id b ty, e0 ! id = Some (b, ty) -> Ple nb b) ->
  forall id b ty, e ! id = Some (b, ty) -> Ple nb b.
Proof.
  intros e0 m vars e m1 H. induction H; intros nb Hnb He0; [ exact He0 |].
  apply IHalloc_variables.
  - rewrite (Mem.nextblock_alloc _ _ _ _ _ H). eapply Ple_trans; [ exact Hnb | apply Ple_succ ].
  - intros id0 b0 ty0 Hg. destruct (peq id0 id) as [-> | Ne].
    + rewrite PTree.gss in Hg. injection Hg as <- <-.
      rewrite (Mem.alloc_result _ _ _ _ _ H). exact Hnb.
    + rewrite PTree.gso in Hg by exact Ne. exact (He0 _ _ _ Hg).
Qed.

Lemma av_perm : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
  list_norepet (map fst vars) ->
  forall b ofs k p, Mem.perm m1 b ofs k p ->
    Mem.perm m b ofs k p \/ exists id ty, e ! id = Some (b, ty) /\ 0 <= ofs < sizeof ge ty.
Proof.
  intros e0 m vars e m1 H. induction H; intros Hnr b0 ofs k p Hp; [ left; exact Hp |].
  cbn in Hnr. inversion Hnr as [| ? ? Hni Hnr']; subst.
  destruct (IHalloc_variables Hnr' b0 ofs k p Hp) as [Hp1 | Hx]; [| right; exact Hx ].
  pose proof (Mem.perm_alloc_inv _ _ _ _ _ H _ _ _ _ Hp1) as Hi.
  destruct (eq_block b0 b1) as [-> | Ne].
  - right. exists id, ty. split; [| exact Hi ].
    rewrite (av_other _ _ _ _ _ H0 id Hni). apply PTree.gss.
  - left. exact Hi.
Qed.

Lemma boe_in : forall e id b ty, e ! id = Some (b, ty) -> In (b, 0, sizeof ge ty) (blocks_of_env ge e).
Proof.
  intros e id b ty H. unfold blocks_of_env. apply in_map_iff.
  exists (id, (b, ty)). split; [ reflexivity | apply PTree.elements_correct; exact H ].
Qed.

Lemma boe_inv : forall e b lo hi, In (b, lo, hi) (blocks_of_env ge e) -> exists id ty, e ! id = Some (b, ty).
Proof.
  intros e b lo hi H. unfold blocks_of_env in H. apply in_map_iff in H as ((id & (b' & ty)) & E & Hin).
  cbn in E. injection E as -> _ _. exists id, ty. apply PTree.elements_complete. exact Hin.
Qed.
End AV.

(* ---- the platform step's whole effect ---- *)
Definition plat_eff (bm bD : block) (m m' : mem) : Prop :=
  Ple (Mem.nextblock m) (Mem.nextblock m')
  /\ (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
  /\ (forall b ofs k p, Mem.perm m' b ofs k p -> Plt b (Mem.nextblock m))
  /\ (forall ch b z, b <> bD -> b <> bm -> Mem.load ch m' b z = Mem.load ch m b z)
  /\ (forall ch z, bmw ch z -> Mem.load ch m' bm z = Mem.load ch m bm z)
  /\ (forall ch z b' o', Mem.load ch m' bD z = Some (Vptr b' o') -> Mem.load ch m bD z = Some (Vptr b' o')).

Lemma plat_eff_refl : forall bm bD m, plat_eff bm bD m m.
Proof.
  intros bm bD m. split; [ apply Ple_refl |]. split; [ auto |]. split; [| split; [| split]; auto ].
  intros b ofs k p Hp. exact (Mem.perm_valid_block _ _ _ _ _ Hp).
Qed.

(* allocate the locals, store, release them: plat_eff *)
Lemma plat_eff_frame : forall (ge : genv) bm bD m vars e m1 m2 m',
  alloc_variables ge empty_env m vars e m1 -> list_norepet (map fst vars) ->
  sruns bm bD (Mem.nextblock m) m1 m2 ->
  Mem.free_list m2 (blocks_of_env ge e) = Some m' ->
  Plt bm (Mem.nextblock m) -> Plt bD (Mem.nextblock m) -> bm <> bD ->
  plat_eff bm bD m m'.
Proof.
  intros ge bm bD m vars e m1 m2 m' Ha Hnr Hs Hf Vbm VbD Nbm.
  set (nb := Mem.nextblock m) in *.
  pose proof (av_old ge _ _ _ _ _ Ha) as (AP & AL).
  assert (Fresh : forall b lo hi, In (b, lo, hi) (blocks_of_env ge e) -> Ple nb b).
  { intros b lo hi Hin. destruct (boe_inv ge e b lo hi Hin) as (id & ty & Hg).
    refine (av_fresh ge _ _ _ _ _ Ha nb (Ple_refl _) _ id b ty Hg).
    intros id0 b0 ty0 E. rewrite PTree.gempty in E. discriminate. }
  destruct (free_list_old nb _ _ _ Hf Fresh) as (FP & FL).
  assert (NP : forall b ofs k p, Mem.perm m' b ofs k p -> Plt b nb).
  { intros b ofs k p Hp.
    pose proof (free_list_perm_back _ _ _ _ _ _ _ Hf Hp) as Hp2.
    apply (sruns_perm _ _ _ _ _ Hs) in Hp2.
    destruct (av_perm ge _ _ _ _ _ Ha Hnr b ofs k p Hp2) as [Hp0 | (id & ty & Hg & Ho)].
    - exact (Mem.perm_valid_block _ _ _ _ _ Hp0).
    - exfalso. exact (free_list_gone _ _ _ _ _ _ _ _ _ Hf (boe_in ge e id b ty Hg) Ho Hp). }
  split; [| split; [| split; [ exact NP | split ]]].
  - rewrite (free_list_nb _ _ _ Hf), (sruns_nb _ _ _ _ _ Hs). exact (av_nb ge _ _ _ _ _ Ha).
  - intros b ofs k p Hb Hp. apply FP; [ exact Hb |]. apply (sruns_perm _ _ _ _ _ Hs). exact (AP _ _ _ _ Hp).
  - intros ch b z HD Hm. destruct (plt b nb) as [Hb | Hb].
    + rewrite (FL ch b z Hb), (sruns_ld _ _ _ _ _ Hs ch b z Hb HD Hm). exact (AL ch b z Hb).
    + destruct (Mem.load ch m b z) eqn:E0.
      { exfalso. apply Hb. apply Mem.load_valid_access in E0. destruct E0 as (Hr & _).
        apply (Mem.perm_valid_block m b z Cur Readable). apply Hr. destruct ch; cbn; lia. }
      destruct (Mem.load ch m' b z) eqn:E1; [| reflexivity ].
      exfalso. apply Hb. apply Mem.load_valid_access in E1. destruct E1 as (Hr & _).
      apply (NP b z Cur Readable). apply Hr. destruct ch; cbn; lia.
  - split.
    + intros ch z Hw. rewrite (FL ch bm z Vbm), (sruns_lm _ _ _ _ _ Hs Vbm Nbm ch z Hw). exact (AL ch bm z Vbm).
    + intros ch z b' o' Hl. rewrite (FL ch bD z VbD) in Hl.
      rewrite <- (AL ch bD z VbD). exact (sruns_pD _ _ _ _ _ Hs VbD Nbm ch z b' o' Hl).
Qed.
