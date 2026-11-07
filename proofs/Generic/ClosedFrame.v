(* ====================================================================== *)
(* ClosedFrame: a change confined to one PRIVATE block.                    *)
(*                                                                          *)
(* closed_by g m (Generic.ClosedMem) with g b = None: no readable byte of a *)
(* g-mapped block names b.  If m' differs from m only in b                 *)
(* (Mem.unchanged_on (fun x _ => x <> b) m m'), then every g-mapped block  *)
(* reads and permits the same in m' as in m, m' is closed by the same g,   *)
(* and a pointer loaded from a g-mapped block names a g-mapped block (so   *)
(* never b).  A fact that reads only blocks reached from the globals by     *)
(* loads is therefore blind to b.                                          *)
(* ====================================================================== *)

From Coq Require Import ZArith.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs.
From SM64.Proofs Require Import Generic.ClosedMem.

Section CF.
  Variables (g : meminj) (m m' : mem) (b : block).
  Hypothesis Hc : closed_by g m.
  Hypothesis Hgb : g b = None.
  Hypothesis U : Mem.unchanged_on (fun x _ => x <> b) m m'.

  Lemma cf_ne : forall x, g x <> None -> x <> b.
  Proof. intros x H E. subst x. exact (H Hgb). Qed.

  Lemma cf_valid : forall x, g x <> None -> Mem.valid_block m x.
  Proof.
    intros x H. destruct (g x) as [[x' d]|] eqn:E; [ | congruence ].
    exact (closed_valid_mapped _ _ _ _ _ Hc E).
  Qed.

  Lemma cf_nb : Ple (Mem.nextblock m) (Mem.nextblock m').
  Proof. eapply Mem.unchanged_on_nextblock; eassumption. Qed.

  Lemma cf_valid' : forall x, Mem.valid_block m x -> Mem.valid_block m' x.
  Proof. intros x H. eapply Mem.valid_block_unchanged_on; eassumption. Qed.

  Lemma cf_load : forall ch x z, g x <> None -> Mem.load ch m' x z = Mem.load ch m x z.
  Proof.
    intros ch x z H. eapply Mem.load_unchanged_on_1; [ exact U | exact (cf_valid x H) | ].
    intros i _. exact (cf_ne x H).
  Qed.

  Lemma cf_loadv : forall ch x o, g x <> None -> Mem.loadv ch m' (Vptr x o) = Mem.loadv ch m (Vptr x o).
  Proof. intros ch x o H. exact (cf_load ch x _ H). Qed.

  Lemma cf_perm : forall x o k p, g x <> None -> (Mem.perm m x o k p <-> Mem.perm m' x o k p).
  Proof. intros x o k p H. eapply Mem.unchanged_on_perm; [ exact U | exact (cf_ne x H) | exact (cf_valid x H) ]. Qed.

  Lemma cf_range_perm : forall x lo hi k p, g x <> None ->
    Mem.range_perm m x lo hi k p -> Mem.range_perm m' x lo hi k p.
  Proof. intros x lo hi k p H R o Ho. exact (proj1 (cf_perm x o k p H) (R o Ho)). Qed.

  (* a pointer loaded from a mapped block names a mapped block *)
  Lemma cf_reach : forall ch x z y o, g x <> None -> Mem.load ch m x z = Some (Vptr y o) -> g y <> None.
  Proof. intros ch x z y o H L. exact (closed_load _ _ _ _ _ _ Hc H L). Qed.

  Lemma cf_reachv : forall ch x o y o', g x <> None ->
    Mem.loadv ch m (Vptr x o) = Some (Vptr y o') -> g y <> None.
  Proof. intros ch x o y o' H L. exact (cf_reach ch x _ y o' H L). Qed.

  (* m' is closed by the same g *)
  Lemma cf_closed : closed_by g m'.
  Proof.
    destruct Hc as (Hflat & Hi). split; [ exact Hflat | ].
    assert (Fm : forall x x' d, g x = Some (x', d) -> g x <> None) by congruence.
    constructor.
    - constructor.
      + intros b1 b2 d ofs k p E Hp.
        destruct (Hflat _ _ _ E) as (-> & ->). rewrite Z.add_0_r. exact Hp.
      + intros b1 b2 d ch ofs p E _. destruct (Hflat _ _ _ E) as (_ & ->). apply Z.divide_0_r.
      + intros b1 ofs b2 d E Hp. destruct (Hflat _ _ _ E) as (-> & ->). rewrite Z.add_0_r.
        assert (Hp0 : Mem.perm m b1 ofs Cur Readable) by exact (proj2 (cf_perm b1 ofs Cur Readable (Fm _ _ _ E)) Hp).
        erewrite (Mem.unchanged_on_contents _ _ _ U b1 ofs); [ | exact (cf_ne b1 (Fm _ _ _ E)) | exact Hp0 ].
        pose proof (Mem.mi_memval _ _ _ (Mem.mi_inj _ _ _ Hi) b1 ofs b1 0 E Hp0) as Mv.
        rewrite Z.add_0_r in Mv. exact Mv.
    - intros x Hnv. apply (Mem.mi_freeblocks _ _ _ Hi). intros Hv. exact (Hnv (cf_valid' x Hv)).
    - intros x x' d E. apply cf_valid'. exact (Mem.mi_mappedblocks _ _ _ Hi x x' d E).
    - intros b1 b1' d1 b2 b2' d2 o1 o2 Hne E1 E2 _ _. left.
      destruct (Hflat _ _ _ E1) as (-> & _). destruct (Hflat _ _ _ E2) as (-> & _). exact Hne.
    - intros x x' d ofs E _. destruct (Hflat _ _ _ E) as (_ & ->).
      pose proof (Ptrofs.unsigned_range_2 ofs). lia.
    - intros b1 ofs b2 d k p E Hp. left. destruct (Hflat _ _ _ E) as (-> & ->).
      rewrite Z.add_0_r in Hp. exact Hp.
  Qed.
End CF.
