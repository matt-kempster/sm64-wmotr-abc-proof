(* ====================================================================== *)
(* THE LOCAL-VARS WALKER ARC (task #32) -- FOUNDATIONAL FRAME LAYER.       *)
(*                                                                        *)
(* The walker engine wwalk_pres (ActWriterSurface) is now e-parametric,   *)
(* so it CAN walk a function with fn_vars<>nil (a stack-allocated local)   *)
(* once it is handed the entry env e_loc + the carried run facts at the   *)
(* post-alloc memory.  This file supplies that frame layer.  It unblocks   *)
(* ~every remaining act-leaf in every family:                             *)
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
(* run facts.  SPINE: consumed by ActWriterSurface.call_pres_of_lwalk,     *)
(* which composes entry alloc_variables + the e-parametric writer-walk     *)
(* engine + exit free_list into a call_pres for a function with            *)
(* fn_vars <> nil.  The abstract MWF frame rows below are discharged from   *)
(* MWFReal (mwf_real_entry / mwf_real_free / MWF_real_transfer) at the      *)
(* capstone.  Wiring target = the aut ledge/pole + submerged leaves.        *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame RealFrameLinked Taint CensusV2.

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
  (* the whole-stack-frame free row: free_list preserves MWF UNCONDITIONALLY
     (freeing only weakens loads + leaves nextblock) -- discharged directly by
     MWFReal.mwf_real_free.  Used by the Tier-1 exit, which needs nothing about
     the freed blocks beyond <> bm (for action_sat). *)
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.

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

  (* ---- the TIER-1 exit: a function with stack locals but NO direct store
     into them (the locals are only written by external out-param calls, e.g.
     find_floor(&floor)).  Its exit free_list needs NOTHING about the freed
     blocks beyond <> bm: MWF survives free_list UNCONDITIONALLY (HMWF_free),
     valid_block bm and action_sat survive because the freed blocks miss bm. *)
  Lemma free_list_action_sat : forall (Q : int -> Prop) l m m',
      Forall (fun blh => fst (fst blh) <> bm) l ->
      Mem.free_list m l = Some m' -> action_sat Q m bm -> action_sat Q m' bm.
  Proof.
    induction l as [ | [[b lo] hi] rest IH ]; intros m m' Hall Hfl Hs.
    - cbn [Mem.free_list] in Hfl. injection Hfl as <-. exact Hs.
    - cbn [Mem.free_list] in Hfl.
      destruct (Mem.free m b lo hi) as [ m1 | ] eqn:Hf; [ | discriminate Hfl ].
      inversion Hall as [ | x xs Hhd Htl ]; subst. cbn in Hhd.
      apply (IH m1 m'); [ exact Htl | exact Hfl | ].
      eapply free_action_sat; [ exact Hf | exact Hhd | exact Hs ].
  Qed.

  Lemma free_list_valid_bm : forall l m m',
      Mem.free_list m l = Some m' ->
      Mem.valid_block m bm -> Mem.valid_block m' bm.
  Proof.
    induction l as [ | [[b lo] hi] rest IH ]; intros m m' Hfl Hv.
    - cbn [Mem.free_list] in Hfl. injection Hfl as <-. exact Hv.
    - cbn [Mem.free_list] in Hfl.
      destruct (Mem.free m b lo hi) as [ m1 | ] eqn:Hf; [ | discriminate Hfl ].
      eapply IH; [ exact Hfl | exact (free_valid _ _ _ _ _ Hf Hv) ].
  Qed.

  Lemma free_list_carried_bm : forall l m m',
      Forall (fun blh => fst (fst blh) <> bm) l ->
      Mem.free_list m l = Some m' -> carried m -> carried m'.
  Proof.
    intros l m m' Hall Hfl (Hv & Hs & Hm & Hn).
    split; [ eapply free_list_valid_bm; eauto | ].
    split; [ eapply free_list_action_sat; eauto | ].
    assert (Hm' : MWF m') by (eapply HMWF_free; eauto).
    split; [ exact Hm' | apply HNoA_of_MWF; exact Hm' ].
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

  (* env-side freshness: alloc_variables only BINDS the var idents; any ident
     NOT among the function's locals keeps its prior binding.  From empty_env
     that means e'!g = None for every g disjoint from (map fst vars) -- this is
     what discharges the engine's census-keyed `e!g = None` premises for the
     stack-frame env (census idents are global, never local). *)
  Lemma alloc_variables_unbound :
    forall ge m vars e e' m',
      alloc_variables ge e m vars e' m' ->
      forall g, ~ In g (map fst vars) -> e' ! g = e ! g.
  Proof.
    intros ge m vars e e' m' Hav.
    induction Hav as [ e0 m0
                     | e0 m0 id ty vars0 m1 b1 m2 e2 Halloc Hrest IH ];
      intros g Hnin.
    - reflexivity.
    - cbn [map fst] in Hnin.
      assert (Hni0 : ~ In g (map fst vars0))
        by (intro Hin; apply Hnin; right; exact Hin).
      rewrite (IH g Hni0).
      apply PTree.gso. intro Heq. apply Hnin. rewrite Heq. apply in_eq.
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

  (* the TIER-1 version: the freed stack blocks merely miss bm (they are fresh
     >= nextblock m, and bm is valid in m).  Needs ONLY bm validity -- no SafeB,
     no globals.  This is what the Tier-1 exit (free_list_carried_bm) consumes. *)
  Lemma blocks_of_env_bm :
    forall m vars e' m',
      alloc_variables (lp_ge lp) empty_env m vars e' m' ->
      Mem.valid_block m bm ->
      Forall (fun blh => fst (fst blh) <> bm) (blocks_of_env (lp_ge lp) e').
  Proof.
    intros m vars e' m' Hav Hbm.
    apply Forall_forall. intros x Hx.
    unfold blocks_of_env in Hx.
    apply in_map_iff in Hx. destruct Hx as [[id [b ty]] [Heq Hin]].
    subst x. cbn [block_of_binding fst].
    apply PTree.elements_complete in Hin.
    destruct (alloc_variables_not_valid _ _ _ _ _ _ Hav _ _ _ Hin)
      as [ [ty0 He0] | Hnv ].
    - rewrite PTree.gempty in He0. discriminate He0.
    - intro Heq. apply Hnv. rewrite Heq. exact Hbm.
  Qed.

  (* ================================================================== *)
  (* THE LOCAL-ARRAY STORE BRICK -- the one genuinely-new semantic       *)
  (* content of the arc.  A store into nextPos[i] / step[i] / etc., i.e. *)
  (* an indexed store whose base is a stack-allocated array Evar:         *)
  (*   Sassign (Ederef (Ebinop Oadd (Evar lid (Tarray ..)) (idx) ..) t) r *)
  (* preserves carried, because the local block is watched-disjoint       *)
  (* (local_blk lblk) -- so the underlying Mem.store hits neither bm's    *)
  (* action cell, a global, nor a SafeB chase block.  The generalized     *)
  (* walker engine (next step) dispatches local Sassigns here.            *)
  (* ================================================================== *)

  (* eval_lvalue of an Evar whose id is BOUND in the local env resolves to
     that env block (the eval_Evar_global branch is refuted by the binding);
     the bitfield is always Full.  Pins the store base for the brick below. *)
  Lemma eval_lvalue_Evar_local_pin :
    forall e le m id ty b l of bf,
      e ! id = Some (b, ty) ->
      eval_lvalue (lp_ge lp) e le m (Evar id ty) l of bf ->
      l = b /\ bf = Full.
  Proof.
    intros e le m id ty b l of bf He Hev.
    inversion Hev; subst.
    - split; [ congruence | reflexivity ].
    - split; [ congruence | reflexivity ].
  Qed.

  Lemma local_idx_assign_pres :
    forall e lid ety sz attr idxN itya ety2 a2 le m0 tr le' m' out lblk ch,
      e ! lid = Some (lblk, Tarray ety sz attr) ->
      local_blk lblk ->
      access_mode ety2 = By_value ch ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Ederef (Ebinop Oadd (Evar lid (Tarray ety sz attr))
                            (Econst_int idxN tint) itya) ety2) a2)
        tr le' m' out ->
      carried m0 ->
      carried m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros e lid ety sz attr idxN itya ety2 a2 le m0 tr le' m' out lblk ch
           Hlid Hlb Hacc Hexec Hc.
    inv Hexec.
    (* the Ederef lvalue: store address = value of the Ebinop *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    (* the Ebinop pointer add (its lvalue branch is impossible) *)
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    (* the index literal: v2 = Vint idxN *)
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    (* the local array base: eval_Elvalue -> eval_lvalue (Evar) + deref_loc *)
    match goal with
    | Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha
    end.
    (* pin the base block = lblk (the local binding) and bitfield = Full *)
    match goal with
    | Hev : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
        destruct (eval_lvalue_Evar_local_pin _ _ _ _ _ _ _ _ _ Hlid Hev)
          as [-> ->]
    end.
    (* the array deref is By_reference -> base value = Vptr lblk _ *)
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (Tarray _ _ _) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Har : access_mode (Tarray _ _ _) = _ |- _ =>
                 cbn in Har; discriminate Har
             end)
    end.
    (* the pointer add preserves the block: store target = lblk *)
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some (Vptr ?l2 _) |- _ =>
        cbn in Hsem; injection Hsem as Hbl Hof; subst l2
    end.
    (* the store into the (now pinned) local block *)
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has; inv Has
    end;
    [ (* By_value: the real store, on local block lblk *)
      split; [ | split; reflexivity ];
      match goal with
      | Hstv : Mem.storev _ _ (Vptr lblk _) _ = Some m' |- _ =>
          unfold Mem.storev in Hstv;
          eapply localstore_carried; [ exact Hlb | exact Hstv | exact Hc ]
      end
    | (* By_copy: refuted -- the deref type is By_value *)
      match goal with
      | Hco : access_mode ety2 = By_copy |- _ =>
          rewrite Hacc in Hco; discriminate Hco
      end ].
  Qed.

  (* ---- the TYPE-TOLERANT block-pin: the engine learns the local binding
     from alloc_variables (at the DECLARED fn_var type), but the body's
     Evar annotation is whatever clightgen wrote.  In CompCert these
     coincide, but rather than thread that equality we pin the block from
     ANY env type: eval_Evar_local forces e!id=Some(l, annotation), and
     determinism with the carried binding e!id=Some(b, tyenv) gives l=b. *)
  Lemma eval_lvalue_Evar_local_pin' :
    forall e le m id tya b tyenv l of bf,
      e ! id = Some (b, tyenv) ->
      eval_lvalue (lp_ge lp) e le m (Evar id tya) l of bf ->
      l = b /\ bf = Full.
  Proof.
    intros e le m id tya b tyenv l of bf He Hev.
    inversion Hev; subst.
    - split; [ congruence | reflexivity ].
    - split; [ congruence | reflexivity ].
  Qed.

  (* ================================================================== *)
  (* The Hlocal CONSTRUCTOR for the Tier-2 producer: every censused local  *)
  (* array id is BOUND by the entry alloc_variables (to a fresh, hence     *)
  (* watched-disjoint, block).  Packages binding-existence + local_blk     *)
  (* into the exact premise wwalk_pres's lids case consumes.               *)
  (* ================================================================== *)

  (* alloc_variables only ADDS bindings: a Some binding in the start env,
     or membership in the var list, survives to the result env. *)
  Lemma alloc_variables_set_some :
    forall ge e m vars e' m',
      alloc_variables ge e m vars e' m' ->
      forall id,
        ((exists b ty, e ! id = Some (b, ty)) \/ In id (map fst vars)) ->
        exists b ty, e' ! id = Some (b, ty).
  Proof.
    intros ge e m vars e' m' Hav.
    induction Hav as [ e0 m0
                     | e0 m0 id0 ty0 vars0 m1 b1 m2 e2 Halloc Hrest IH ];
      intros id Hor.
    - destruct Hor as [ Hsome | Hin ].
      + exact Hsome.
      + destruct Hin.
    - apply IH.
      destruct Hor as [ (b & ty & He0) | Hin ].
      + left. destruct (Pos.eq_dec id id0) as [ -> | Hne ].
        * exists b1, ty0. apply PTree.gss.
        * exists b, ty. rewrite PTree.gso by exact Hne. exact He0.
      + cbn [map fst] in Hin. destruct Hin as [ -> | Hin' ].
        * left. exists b1, ty0. apply PTree.gss.
        * right. exact Hin'.
  Qed.

  Lemma alloc_variables_in_bound :
    forall ge e m vars e' m',
      alloc_variables ge e m vars e' m' ->
      forall id, In id (map fst vars) ->
        exists b ty, e' ! id = Some (b, ty).
  Proof.
    intros ge e m vars e' m' Hav id Hin.
    eapply alloc_variables_set_some; eauto.
  Qed.

  Lemma alloc_variables_hlocal :
    forall m vars e' m' (lids : list ident),
      alloc_variables (lp_ge lp) empty_env m vars e' m' ->
      Mem.valid_block m bm ->
      (forall b, SafeB b -> Mem.valid_block m b) ->
      (forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
                      Mem.valid_block m bg) ->
      (forall lid, mem_id lid lids = true -> In lid (map fst vars)) ->
      forall lid, mem_id lid lids = true ->
        exists lblk tyenv, e' ! lid = Some (lblk, tyenv) /\ local_blk lblk.
  Proof.
    intros m vars e' m' lids Hav Hbm HSv HGv Hsub lid Hmem.
    destruct (alloc_variables_in_bound _ _ _ _ _ _ Hav lid (Hsub lid Hmem))
      as (b & ty & Hbind).
    exists b, ty. split; [ exact Hbind | ].
    eapply alloc_variables_local_blk; eauto.
  Qed.

  (* The TYPE-TOLERANT indexed-local store brick: identical to
     local_idx_assign_pres, but the carried env binding e!lid may be at any
     type tyenv (the store target block is pinned from the binding, and the
     array deref uses the Evar ANNOTATION type, not the binding type). This
     is what the e-parametric engine consumes: its Hlocal premise supplies
     the binding at the declared type, which need not be re-matched against
     each Evar occurrence's annotation. *)
  Lemma local_idx_assign_pres' :
    forall e lid ety sz attr idxN itya ety2 a2 le m0 tr le' m' out lblk tyenv ch,
      e ! lid = Some (lblk, tyenv) ->
      local_blk lblk ->
      access_mode ety2 = By_value ch ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Ederef (Ebinop Oadd (Evar lid (Tarray ety sz attr))
                            (Econst_int idxN tint) itya) ety2) a2)
        tr le' m' out ->
      carried m0 ->
      carried m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros e lid ety sz attr idxN itya ety2 a2 le m0 tr le' m' out lblk tyenv ch
           Hlid Hlb Hacc Hexec Hc.
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    match goal with
    | Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha
    end.
    match goal with
    | Hev : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
        destruct (eval_lvalue_Evar_local_pin' _ _ _ _ _ _ _ _ _ _ Hlid Hev)
          as [-> ->]
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (Tarray _ _ _) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Har : access_mode (Tarray _ _ _) = _ |- _ =>
                 cbn in Har; discriminate Har
             end)
    end.
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some (Vptr ?l2 _) |- _ =>
        cbn in Hsem; injection Hsem as Hbl Hof; subst l2
    end.
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has; inv Has
    end;
    [ split; [ | split; reflexivity ];
      match goal with
      | Hstv : Mem.storev _ _ (Vptr lblk _) _ = Some m' |- _ =>
          unfold Mem.storev in Hstv;
          eapply localstore_carried; [ exact Hlb | exact Hstv | exact Hc ]
      end
    | match goal with
      | Hco : access_mode ety2 = By_copy |- _ =>
          rewrite Hacc in Hco; discriminate Hco
      end ].
  Qed.

  (* ================================================================== *)
  (* The TEMPVAR-POINTER indexed-store twin of local_idx_assign_pres'.   *)
  (* Here the store target's base is a POINTER VALUE held in a temp      *)
  (* (le!q = Vptr lblk ofs, local_blk lblk) -- e.g. the out-param        *)
  (* `nextPos` of perform_hanging_step, written as nextPos[idx] = <float>*)
  (* (Sassign (Ederef (Ebinop Oadd (Etempvar nextPos) idx)) rhs).  No    *)
  (* array-decay deref_loc step (Etempvar reads the temp directly), so   *)
  (* it is SIMPLER than the Evar version.  localstore_carried needs only *)
  (* local_blk of the (offset-shifted) block -- the stored value is      *)
  (* unconstrained (a local block is fully watched-disjoint).            *)
  (* ================================================================== *)
  Lemma local_ptr_idx_assign_pres :
    forall e q idxN itya ety2 a2 le m0 tr le' m' out lblk ofs ch,
      le ! q = Some (Vptr lblk ofs) ->
      local_blk lblk ->
      access_mode ety2 = By_value ch ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Ederef (Ebinop Oadd (Etempvar q (tptr tfloat))
                            (Econst_int idxN tint) itya) ety2) a2)
        tr le' m' out ->
      carried m0 ->
      carried m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros e q idxN itya ety2 a2 le m0 tr le' m' out lblk ofs ch
           Hq Hlb Hacc Hexec Hc.
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    (* the index: Econst_int -> Vint *)
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    (* the base: Etempvar q -> read le!q = Vptr lblk ofs.  (inv Hexec
       substituted le -> le', so match the env by a shared metavar.) *)
    match goal with
    | Ha : eval_expr _ _ ?L _ (Etempvar ?Q _) ?V,
      Hq0 : ?L ! ?Q = Some (Vptr ?lb ?of) |- _ =>
        apply RealFrameValue.eval_expr_Etempvar_val in Ha;
        rewrite Hq0 in Ha; injection Ha as Hv; subst V
    end.
    (* sem_add (Vptr lblk ofs) (Vint idxN): block is preserved *)
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some (Vptr ?l2 _) |- _ =>
        cbn in Hsem; injection Hsem as Hbl Hof; subst l2
    end.
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has; inv Has
    end;
    [ split; [ | split; reflexivity ];
      match goal with
      | Hstv : Mem.storev _ _ (Vptr lblk _) _ = Some m' |- _ =>
          unfold Mem.storev in Hstv;
          eapply localstore_carried; [ exact Hlb | exact Hstv | exact Hc ]
      end
    | match goal with
      | Hco : access_mode ety2 = By_copy |- _ =>
          rewrite Hacc in Hco; discriminate Hco
      end ].
  Qed.

End LocalVarsArc.
