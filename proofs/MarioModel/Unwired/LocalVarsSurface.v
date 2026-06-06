(* ====================================================================== *)
(* THE LOCAL-VARS WALKER ARC (task #32) -- FOUNDATIONAL LAYER.             *)
(*                                                                        *)
(* The walker engine wwalk_pres (ActWriterSurface) hardcodes e=empty_env, *)
(* so it cannot walk a function with fn_vars<>nil (a stack-allocated      *)
(* local).  That blocks ~every remaining act-leaf in every family:        *)
(* perform_water_step / perform_water_full_step (submerged: _filler/      *)
(* _nextPos/_step arrays), set_pole_position (aut pole), let_go_of_ledge  *)
(* (aut ledge), update_hang_moving, act_tornado_twirling.                 *)
(*                                                                        *)
(* The semantic content of the arc is small and local: a stack block is   *)
(* allocated FRESH at function entry, so it is watched-disjoint (distinct  *)
(* from bm, from every global block, and from every SafeB chase block);    *)
(* hence allocating it, storing into it, and freeing it at exit all leave  *)
(* the watched cells (MWF / action_sat / valid_block bm) untouched.        *)
(*                                                                        *)
(* This file proves that frame layer: alloc / alloc_variables (entry),     *)
(* store-to-local, and free / free_list (exit) all preserve the carried    *)
(* run facts.  It is the brick the generalized engine (next step) consumes *)
(* at the entry and exit of a local-var funcall.  Until that engine lands  *)
(* this file is Unwired; the wiring target is body_pres for                *)
(* perform_water_step -> the submerged leaf harvest (B10).                 *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Memory
  Globalenvs Ctypes Clight.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame RealFrameLinked Taint.

Import ListNotations.

Section LocalVarsArc.
  Variable lp : Clight.program.
  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  (* a "local" stack block: watched-disjoint from everything MWF and
     action_sat depend on.  Established at entry from freshness; a fact
     about block identities, hence stable through the whole body. *)
  Definition local_blk (b : block) : Prop :=
    b <> bm /\ ~ SafeB b /\
    (forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg -> b <> bg).

  (* ---- the abstract MWF frame rows for the stack frame (discharged by
     MWFReal: alloc/free/store on a watched-disjoint block leave every
     watched cell -- bm window, globals, SafeB chase -- untouched). ---- *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_freeb : forall m b lo hi m',
      local_blk b -> Mem.free m b lo hi = Some m' -> MWF m -> MWF m'.
  Hypothesis HMWF_localstore : forall m ch b d v m',
      local_blk b -> Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.

  (* ================================================================== *)
  (* action_sat / valid_block frame: any memory op that leaves the load  *)
  (* at (bm,12) unchanged preserves action_sat.                          *)
  (* ================================================================== *)

  Lemma action_sat_load_eq : forall (Q : int -> Prop) m m',
      Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12 ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q m m' Heq HS v Hl. apply HS. rewrite <- Heq. exact Hl.
  Qed.

  Lemma alloc_action_sat : forall (Q : int -> Prop) m lo hi m' b,
      Mem.alloc m lo hi = (m', b) ->
      Mem.valid_block m bm ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q m lo hi m' b Ha Hv.
    apply action_sat_load_eq.
    eapply Mem.load_alloc_unchanged; eauto.
  Qed.

  Lemma free_action_sat : forall (Q : int -> Prop) m b lo hi m',
      Mem.free m b lo hi = Some m' -> b <> bm ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q m b lo hi m' Hf Hne.
    apply action_sat_load_eq.
    eapply Mem.load_free; [ exact Hf | left; exact (not_eq_sym Hne) ].
  Qed.

  Lemma store_action_sat : forall (Q : int -> Prop) ch m b d v m',
      Mem.store ch m b d v = Some m' -> b <> bm ->
      action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    intros Q ch m b d v m' Hst Hne.
    apply action_sat_load_eq.
    eapply Mem.load_store_other; [ exact Hst | left; exact (not_eq_sym Hne) ].
  Qed.

  Lemma alloc_valid : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) ->
      Mem.valid_block m bm -> Mem.valid_block m' bm.
  Proof. intros m lo hi m' b Ha Hv. eapply Mem.valid_block_alloc; eauto. Qed.

  Lemma free_valid : forall m b lo hi m',
      Mem.free m b lo hi = Some m' ->
      Mem.valid_block m bm -> Mem.valid_block m' bm.
  Proof. intros m b lo hi m' Hf Hv. eapply Mem.valid_block_free_1; eauto. Qed.

  Lemma store_valid : forall ch m b d v m',
      Mem.store ch m b d v = Some m' ->
      Mem.valid_block m bm -> Mem.valid_block m' bm.
  Proof. intros ch m b d v m' Hst Hv. eapply Mem.store_valid_block_1; eauto. Qed.

  (* ================================================================== *)
  (* the combined carried-facts bundle and its single-op frame lemmas.   *)
  (* ================================================================== *)

  Definition carried (m : mem) : Prop :=
    Mem.valid_block m bm /\ action_sat not_tainted m bm /\ MWF m /\ NoA m.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.

  Lemma alloc_carried : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> carried m -> carried m'.
  Proof.
    intros m lo hi m' b Ha (Hv & Hs & Hm & Hn).
    split; [ eapply alloc_valid; eauto | ].
    split; [ eapply alloc_action_sat; eauto | ].
    assert (Hm' : MWF m') by (eapply HMWF_alloc; eauto).
    split; [ exact Hm' | apply HNoA_of_MWF; exact Hm' ].
  Qed.

  Lemma freeb_carried : forall m b lo hi m',
      local_blk b -> Mem.free m b lo hi = Some m' -> carried m -> carried m'.
  Proof.
    intros m b lo hi m' Hlb Hf (Hv & Hs & Hm & Hn).
    assert (Hne : b <> bm) by (destruct Hlb as (Hne & _ & _); exact Hne).
    split; [ eapply free_valid; eauto | ].
    split; [ eapply free_action_sat; eauto | ].
    assert (Hm' : MWF m') by (eapply HMWF_freeb; eauto).
    split; [ exact Hm' | apply HNoA_of_MWF; exact Hm' ].
  Qed.

  Lemma localstore_carried : forall ch m b d v m',
      local_blk b -> Mem.store ch m b d v = Some m' -> carried m -> carried m'.
  Proof.
    intros ch m b d v m' Hlb Hst (Hv & Hs & Hm & Hn).
    assert (Hne : b <> bm) by (destruct Hlb as (Hne & _ & _); exact Hne).
    split; [ eapply store_valid; eauto | ].
    split; [ eapply store_action_sat; eauto | ].
    assert (Hm' : MWF m') by (eapply HMWF_localstore; eauto).
    split; [ exact Hm' | apply HNoA_of_MWF; exact Hm' ].
  Qed.

  (* ================================================================== *)
  (* ENTRY: alloc_variables preserves carried (the var blocks are fresh, *)
  (* so each alloc preserves; the env it builds is consumed by the engine *)
  (* -- block freshness -> local_blk derivation is the next lemma).       *)
  (* ================================================================== *)

  Lemma alloc_variables_carried :
    forall ge e m vars e' m',
      alloc_variables ge e m vars e' m' -> carried m -> carried m'.
  Proof.
    intros ge e m vars e' m' Hav.
    induction Hav as [ e0 m0 | e0 m0 id ty vars0 m1 b1 m2 e2 Halloc Hrest IH ];
      intros Hc.
    - exact Hc.
    - apply IH. eapply alloc_carried; eauto.
  Qed.

  (* ================================================================== *)
  (* EXIT: free_list of stack blocks preserves carried, given every block *)
  (* in the list is a local_blk.                                          *)
  (* ================================================================== *)

  Lemma free_list_carried :
    forall l m m',
      Forall (fun blh => local_blk (fst (fst blh))) l ->
      Mem.free_list m l = Some m' -> carried m -> carried m'.
  Proof.
    induction l as [ | [[b lo] hi] rest IH ]; intros m m' Hall Hfl Hc.
    - cbn [Mem.free_list] in Hfl. injection Hfl as <-. exact Hc.
    - cbn [Mem.free_list] in Hfl.
      destruct (Mem.free m b lo hi) as [ m1 | ] eqn:Hf; [ | discriminate Hfl ].
      inversion Hall as [ | x xs Hhd Htl ]; subst.
      cbn in Hhd.
      apply (IH m1 m'); [ exact Htl | exact Hfl | ].
      eapply freeb_carried; eauto.
  Qed.

  (* ================================================================== *)
  (* FRESHNESS -> local_blk: every block alloc_variables binds from the   *)
  (* EMPTY env is fresh w.r.t. the entry memory m, hence watched-disjoint *)
  (* (bm / SafeB / globals are all valid in m).  This is what makes the   *)
  (* entry env's blocks consumable by the local-store brick and the exit  *)
  (* free_list.                                                           *)
  (* ================================================================== *)

  (* every block in the resulting env is either inherited from the start
     env or fresh (invalid) w.r.t. the start memory. *)
  Lemma alloc_variables_not_valid :
    forall ge e m vars e' m',
      alloc_variables ge e m vars e' m' ->
      forall id b ty, e' ! id = Some (b, ty) ->
        (exists ty0, e ! id = Some (b, ty0)) \/ ~ Mem.valid_block m b.
  Proof.
    intros ge e m vars e' m' Hav.
    induction Hav as [ e0 m0
                     | e0 m0 id0 ty0 vars0 m1 b1 m2 e2 Halloc Hrest IH ];
      intros id b ty He'.
    - left. exists ty. exact He'.
    - destruct (IH _ _ _ He') as [ [ty1 Hset] | Hnv1 ].
      + destruct (Pos.eq_dec id id0) as [ -> | Hne ].
        * right. rewrite PTree.gss in Hset.
          injection Hset as Eb Ety. subst b.
          exact (Mem.fresh_block_alloc _ _ _ _ _ Halloc).
        * left. rewrite PTree.gso in Hset by exact Hne.
          exists ty1. exact Hset.
      + right. intro Hvm. apply Hnv1.
        eapply Mem.valid_block_alloc; eauto.
  Qed.

  Lemma alloc_variables_local_blk :
    forall m vars e' m',
      alloc_variables (lp_ge lp) empty_env m vars e' m' ->
      Mem.valid_block m bm ->
      (forall b, SafeB b -> Mem.valid_block m b) ->
      (forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
                      Mem.valid_block m bg) ->
      forall id b ty, e' ! id = Some (b, ty) -> local_blk b.
  Proof.
    intros m vars e' m' Hav Hbm HSv HGv id b ty He'.
    destruct (alloc_variables_not_valid _ _ _ _ _ _ Hav _ _ _ He')
      as [ [ty0 He0] | Hnv ].
    - rewrite PTree.gempty in He0. discriminate He0.
    - split; [ | split ].
      + intro Heq. apply Hnv. rewrite Heq. exact Hbm.
      + intro HS. apply Hnv. exact (HSv _ HS).
      + intros gid bg Hsym Heq. apply Hnv. rewrite Heq.
        exact (HGv _ _ Hsym).
  Qed.

  (* the exit obligation, assembled: every block free_list will free is a
     local_blk -- so free_list_carried applies at function exit. *)
  Lemma blocks_of_env_local_blk :
    forall m vars e' m',
      alloc_variables (lp_ge lp) empty_env m vars e' m' ->
      Mem.valid_block m bm ->
      (forall b, SafeB b -> Mem.valid_block m b) ->
      (forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
                      Mem.valid_block m bg) ->
      Forall (fun blh => local_blk (fst (fst blh)))
             (blocks_of_env (lp_ge lp) e').
  Proof.
    intros m vars e' m' Hav Hbm HSv HGv.
    apply Forall_forall. intros x Hx.
    unfold blocks_of_env in Hx.
    apply in_map_iff in Hx. destruct Hx as [[id [b ty]] [Heq Hin]].
    subst x. cbn [block_of_binding fst].
    apply PTree.elements_complete in Hin.
    eapply alloc_variables_local_blk; eauto.
  Qed.

End LocalVarsArc.
