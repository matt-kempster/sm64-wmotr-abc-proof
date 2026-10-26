(* ====================================================================== *)
(* LevelWarp (GOAL 2): the POST tail of play_mode_normal re-establishes   *)
(* FfWorld.warp_w, walked from the real code (2026-10-26).                *)
(*                                                                        *)
(* The tail is `initiate_delayed_warp(); <play-mode switch>; return 0`    *)
(* (LevelFlank.lv_tail).  warp_w at its start (PhiW's lvl_w, through the *)
(* frame) gives the pre facts: no credits run, no demo, and NORMAL play   *)
(* mode means sWarpDest.type = NOT_WARPING, and the pending warp op is no *)
(* credits op (warp_w's fifth clause).                                    *)
(*                                                                        *)
(* initiate_delayed_warp (idw_Q, its generated body):                     *)
(*   - not firing: only sDelayedWarpTimer moves;                          *)
(*   - the debug / GAME_OVER / CREDITS_END / DEMO_NEXT arms end in        *)
(*     warp_special: sCurrPlayMode = CHANGE_LEVEL (ws_val);               *)
(*   - the demo arm is dead (gCurrDemoInput NULL); the credits arms are   *)
(*     excluded (op is no credits op);                                    *)
(*   - the default arm calls initiate_warp (sWarpDest only), then either  *)
(*     reads type = CHANGE_LEVEL or calls level_set_transition(2, NULL)   *)
(*     (sTransitionTimer = 2, lst_val).                                   *)
(* So at its end (Qw): gCurrCreditsEntry is still NULL, and NORMAL play   *)
(* mode means type NOT_WARPING or CHANGE_LEVEL, or the transition timer   *)
(* is set.  The play-mode switch (tail_Q) then leaves NORMAL play mode in *)
(* the last two cases (set_play_mode, spm_val), so at the tail's end      *)
(* NORMAL play mode again means NOT_WARPING.  The other warp_w cells (the *)
(* demo pointer, the op, the source node) are outside the tail's          *)
(* footprint (LevelWalk.lvl_calls_lfun).                                  *)
(*                                                                        *)
(* Each callee's footprint comes from LevelWalk's walker at the narrower  *)
(* lists (lvl_safe_gvars, PMX = + sCurrPlayMode, WDX = + sWarpDest).      *)
(* ====================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Values AST Ctypes Cop Clight ClightBigstep Clightdefs
  Memory Maps Globalenvs Linking Events Errors.
From SM64.Generated Require level_update.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 MWFReal SpawnInit
  LinkedTwelve ActionValueFrame MathBodies MathGeomGated OsDmaFloor AudioBodies.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim LevelGvars LevelFlank LevelWalk.
From SM64.Proofs.WMotRRequiresA Require FfWorld.
Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. Statement helpers.                                                   *)
(* ---------------------------------------------------------------------- *)

(* a statement made of assignments, calls and ifs ends normally *)
Fixpoint plainw (s : statement) : bool :=
  match s with
  | Sskip | Sassign _ _ | Sset _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence a b | Sifthenelse _ a b => plainw a && plainw b
  | _ => false
  end.

Lemma plainw_normal : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> plainw s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hp; cbn [plainw] in Hp;
    try discriminate Hp; try reflexivity.
  - apply andb_prop in Hp as [_ A2]. exact (IHexec_stmt2 A2).
  - apply andb_prop in Hp as [A1 _]. exfalso. exact (H0 (IHexec_stmt A1)).
  - apply andb_prop in Hp as [A1 A2]. apply IHexec_stmt. destruct b; assumption.
Qed.

(* a statement whose last step is a break *)
Fixpoint brk (s : statement) : bool :=
  match s with Sbreak => true | Ssequence _ b => brk b | _ => false end.

Lemma brk_nn : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> brk s = true -> out <> Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hb; cbn [brk] in Hb; try discriminate Hb.
  all: first [ discriminate | exact (IHexec_stmt2 Hb) | assumption ].
Qed.

Section EX.
  Variable ge : genv.
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  Lemma seq_plain : forall le m s1 s2 t le' m' out, plainw s1 = true ->
    xs le m (Ssequence s1 s2) t le' m' out ->
    exists t1 le1 m1 t2, xs le m s1 t1 le1 m1 Out_normal /\ xs le1 m1 s2 t2 le' m' out.
  Proof.
    intros le m s1 s2 t le' m' out P H.
    apply seq_inv in H as [H | (H & N)]; [ exact H | ].
    exfalso. exact (N (plainw_normal _ _ _ _ _ _ _ _ _ H P)).
  Qed.

  Lemma seq_brk : forall le m s1 s2 t le' m' out, brk s1 = true ->
    xs le m (Ssequence s1 s2) t le' m' out -> exists out1, xs le m s1 t le' m' out1.
  Proof.
    intros le m s1 s2 t le' m' out B H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & _) | (H1 & _)]; [ | eauto ].
    exfalso. exact (brk_nn _ _ _ _ _ _ _ _ _ H1 B eq_refl).
  Qed.

  Lemma seq_last_brk : forall le m s t le' m' out, plainw s = true ->
    xs le m (Ssequence s Sbreak) t le' m' out -> exists t1 le1, xs le m s t1 le1 m' Out_normal.
  Proof.
    intros le m s t le' m' out P H.
    destruct (seq_plain _ _ _ _ _ _ _ _ P H) as (t1 & le1 & m1 & t2 & H1 & H2).
    inv H2. eauto.
  Qed.

  Lemma switch_inv : forall le m a sl t le' m' out, xs le m (Sswitch a sl) t le' m' out ->
    exists v n out1, eval_expr ge empty_env le m a v /\ sem_switch_arg v (typeof a) = Some n
      /\ xs le m (seq_of_labeled_statement (select_switch n sl)) t le' m' out1.
  Proof. intros. inv H. eauto 10. Qed.

  Lemma fun_entry : forall f m vargs t m' vres, fn_vars f = nil ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    exists le0 le out, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le0
      /\ xs le0 m (fn_body f) t le m' out.
  Proof.
    intros f m vargs t m' vres Hv H. inv H.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hv in Ha; inv Ha end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as <- end.
    eauto.
  Qed.
End EX.

(* the comparisons the walk reads symbolically *)
Lemma p64 : Archi.ptr64 = false.
Proof. vm_compute. reflexivity. Qed.

Lemma ne1_false : forall ge m v k vc,
  sem_binary_operation ge One v tuchar (Vint k) tint m = Some vc ->
  bool_val vc tint m = Some false -> v = Vint k.
Proof.
  intros ge m v k vc H Hb.
  destruct v; cbn in H; try discriminate H.
  unfold sem_binarith, sem_cast in H; cbn in H; rewrite p64 in H; cbn in H.
  injection H as <-.
  destruct (Int.eq i k) eqn:E; vm_compute in Hb; try discriminate Hb.
  pose proof (Int.eq_spec i k) as S. rewrite E in S. subst. reflexivity.
Qed.

Lemma ne0_false : forall ge m n k vc,
  sem_binary_operation ge One (Vint n) tshort (Vint k) tint m = Some vc ->
  bool_val vc tint m = Some false -> n = k.
Proof.
  intros ge m n k vc H Hb.
  cbn in H. unfold sem_binarith, sem_cast in H; cbn in H; rewrite p64 in H; cbn in H.
  injection H as <-.
  destruct (Int.eq n k) eqn:E; vm_compute in Hb; try discriminate Hb.
  pose proof (Int.eq_spec n k) as S. rewrite E in S. exact S.
Qed.

Lemma vint_ne : forall a b, Int.unsigned a <> Int.unsigned b -> Some (Vint a) <> Some (Vint b).
Proof. intros a b N E. injection E as E. apply N. rewrite E. reflexivity. Qed.

(* a protected copy: the frame tactic below moves only bare loads *)
Definition kept (P : Prop) : Prop := P.

(* the evaluation steps of a condition *)
Ltac g1 :=
  match goal with
  | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in H
  | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in H; subst
  | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
      apply ev_binop in H; destruct H as (? & ? & ? & ? & H); cbn [typeof] in H
  | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply ev_cast in H; destruct H as (? & ? & H); cbn [typeof] in H
  | H : (PTree.set _ _ _) ! _ = Some _ |- _ => progress getnorm H
  | H : Some _ = Some _ |- _ => injection H; clear H; intros; subst
  | H : bool_val _ (typeof _) _ = _ |- _ => progress cbn [typeof] in H
  | H : sem_cast (Vint _) _ _ _ = Some _ |- _ => vm_compute in H; injection H; clear H; intros; subst
  | H : sem_binary_operation _ _ (Vint _) _ (Vint _) _ _ = Some _ |- _ =>
      cbn [sem_binary_operation] in H; vm_compute in H; injection H; clear H; intros; subst
  | H : bool_val (Vint _) _ _ = Some _ |- _ => vm_compute in H; first [ discriminate H | clear H ]
  end.

(* ---------------------------------------------------------------------- *)
(* 2. On the link.                                                         *)
(* ---------------------------------------------------------------------- *)
Section Warp.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Hypothesis Hfloor : os_dma_floor.

  Notation G := (lp_ge lp).
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation OF := (ow_facts bm MWF).
  Notation xs := (exec_stmt function_entry2 G empty_env).

  Hypothesis Hbm_sym : Genv.find_symbol G LU._gMarioStates = Some bm.
  Variables (bp bw bt bcr bd bo : block).
  Hypothesis Hbp : Genv.find_symbol G LU._sCurrPlayMode = Some bp.
  Hypothesis Hbw : Genv.find_symbol G LU._sWarpDest = Some bw.
  Hypothesis Hbt : Genv.find_symbol G LU._sTransitionTimer = Some bt.
  Hypothesis Hbcr : Genv.find_symbol G LU._gCurrCreditsEntry = Some bcr.
  Hypothesis Hbd : Genv.find_symbol G LU._gCurrDemoInput = Some bd.
  Hypothesis Hbo : Genv.find_symbol G LU._sDelayedWarpOp = Some bo.

  Let LVS := lv_stmt lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor.
  Let SL := safe_ids_lfun lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor.
  Let PL := pm_ids_lfun lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor.
  Let WL := wd_ids_lfun lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor.

  (* what initiate_delayed_warp leaves *)
  Definition Qw (m : mem) : Prop :=
    Mem.load Mint32 m bcr 0 = Some (Vint Int.zero)
    /\ (Mem.load Mint16signed m bp 0 = Some (Vint Int.zero) ->
        Mem.load Mint8unsigned m bw 0 = Some (Vint Int.zero)
        \/ Mem.load Mint8unsigned m bw 0 = Some (Vint Int.one)
        \/ exists n, Mem.load Mint16signed m bt 0 = Some (Vint n) /\ n <> Int.zero).

  (* a global outside a footprint keeps its cells *)
  Lemma fx_keep : forall Xs id b ch z m m', Genv.find_symbol G id = Some b ->
    existsb (Pos.eqb id) Xs = false -> id <> LU._gMarioStates -> fx lp bm Xs m m' ->
    Mem.load ch m' b z = Mem.load ch m b z.
  Proof.
    intros Xs id b ch z m m' Hs Hn Hne Hfx. apply (fx_load lp bm Xs m m' ch b z Hfx).
    intros i _ [(id' & Hin & Hs') | (-> & _)].
    - destruct (peq id id') as [<- | Ne].
      + assert (E : existsb (Pos.eqb id) Xs = true)
          by (apply existsb_exists; exists id; split; [ exact Hin | apply Pos.eqb_refl ]).
        congruence.
      + exact (Genv.global_addresses_distinct G Ne Hs Hs' eq_refl).
    - exact (Genv.global_addresses_distinct G Hne Hs Hbm_sym eq_refl).
  Qed.

  (* move a load fact across a footprint *)
  Ltac kp1 Hfx H :=
    lazymatch type of Hfx with fx _ _ ?Xs ?M ?M' =>
    lazymatch type of H with Mem.load ?ch M ?b ?z = _ =>
    match goal with Hs : Genv.find_symbol _ ?id = Some b |- _ =>
      rewrite <- (fx_keep Xs id b ch z M M' Hs ltac:(vm_compute; reflexivity)
                    ltac:(let E := fresh in intro E; vm_compute in E; discriminate E) Hfx) in H
    end end end.
  Ltac kpa Hfx :=
    lazymatch type of Hfx with fx _ _ _ ?M _ =>
    repeat match goal with H : Mem.load _ M _ _ = _ |- _ => kp1 Hfx H end end.

  (* one walked statement: OF and the footprint *)
  Ltac lvs Xs HX ids Hids H Hok :=
    let r := fresh "R" in
    pose proof (fun c => LVS Xs HX ids _ c Hids _ _ _ _ _ _ H Hok) as r;
    specialize (r ltac:(vm_compute; reflexivity)).

  (* a global scalar read *)
  Ltac gread H Hsym :=
    eapply ev_gvar in H; [ | apply PTree.gempty | reflexivity ];
    let b := fresh "b" in let Hs := fresh "Hs" in
    destruct H as (b & Hs & H); rewrite Hsym in Hs; injection Hs as <-;
    cbn [Mem.loadv] in H; try change Mptr with Mint32 in H;
    change (Ptrofs.unsigned Ptrofs.zero) with 0 in H.
  (* sWarpDest.type *)
  Ltac gtype H :=
    eapply ev_gfld in H;
    [ | exact (PTree.gempty _ _) | exact (fo_wd_type G (lu_cenv lp H12)) | reflexivity ];
    let b := fresh "b" in let Hs := fresh "Hs" in
    destruct H as (b & Hs & H); rewrite Hbw in Hs; injection Hs as <-;
    cbn [Mem.loadv] in H;
    change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr OFS_WD_TYPE))) with 0 in H.

  (* a level_update callee *)
  Lemma lu_call : forall id f targs tres cc optid al le m t le' m' out,
    (prog_defmap LU.prog) ! id = Some (Gfun (Internal f)) ->
    xs le m (Scall optid (Evar id (Tfunction targs tres cc)) al) t le' m' out ->
    exists vargs t' vres, eval_exprlist G empty_env le m al targs vargs
      /\ eval_funcall function_entry2 G m (Internal f) vargs t' m' vres.
  Proof.
    intros id f targs tres cc optid al le m t le' m' out Hdm Hx.
    apply call_inv in Hx.
    destruct Hx as (tyargs & tyres & cc' & vf & vargs & fd & vres & Hcl & Hev & Hel & Hff & _ & Hfc & _ & _).
    cbn in Hcl. injection Hcl as <- <- <-.
    destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev (PTree.gempty _ _)) as (lf & Hsy & ->).
    destruct (linkorder_resolves_internal lp LU.prog id f (linked12_LO_lvl lp H12) Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hsy. rewrite Hsy in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hff. unfold lp_ge in Hff. rewrite Hf' in Hff.
    injection Hff as <-. eauto 10.
  Qed.

  Lemma dm_ws : (prog_defmap LU.prog) ! LU._warp_special = Some (Gfun (Internal LU.f_warp_special)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_spm : (prog_defmap LU.prog) ! LU._set_play_mode = Some (Gfun (Internal LU.f_set_play_mode)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_lst : (prog_defmap LU.prog) ! LU._level_set_transition
    = Some (Gfun (Internal LU.f_level_set_transition)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_idw : (prog_defmap LU.prog) ! LU._initiate_delayed_warp
    = Some (Gfun (Internal LU.f_initiate_delayed_warp)).
  Proof. vm_compute. reflexivity. Qed.

  (* a store into a global scalar *)
  Ltac st1 :=
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar _ _) ?b ?o ?bf, Ha : assign_loc _ _ _ ?b ?o ?bf _ _ |- _ =>
        apply lv_gvar in Hl; [ | apply PTree.gempty ];
        let Hs := fresh "Hs" in destruct Hl as (Hs & -> & ->);
        eapply store_by_value in Ha; [ | reflexivity | reflexivity ];
        change (Ptrofs.unsigned Ptrofs.zero) with 0 in Ha
    end.

  Lemma sym_ne : forall i1 i2 b1 b2, Genv.find_symbol G i1 = Some b1 -> Genv.find_symbol G i2 = Some b2 ->
    i1 <> i2 -> b1 <> b2.
  Proof. intros i1 i2 b1 b2 H1 H2 N E. subst b2. exact (Genv.global_addresses_distinct G N H1 H2 eq_refl). Qed.

  Ltac idne := let E := fresh in intro E; vm_compute in E; discriminate E.

  (* identify a found symbol's block with the section's *)
  Ltac sym_is id Hsym :=
    repeat match goal with S : Genv.find_symbol _ id = Some ?b1 |- _ =>
      tryif constr_eq S Hsym then fail else
        (rewrite Hsym in S; let E := fresh in injection S as E; subst b1) end.

  (* ---- the leaf values ---- *)
  Lemma ws_val : forall m vargs t m' vres,
    eval_funcall function_entry2 G m (Internal LU.f_warp_special) vargs t m' vres ->
    Mem.load Mint16signed m' bp 0 = Some (Vint (Int.repr 4)).
  Proof.
    intros m vargs t m' vres H.
    destruct (fun_entry G LU.f_warp_special _ _ _ _ _ eq_refl H) as (le0 & le & out & _ & Hx).
    cbn [LU.f_warp_special fn_body] in Hx.
    repeat walk1. repeat st1. sym_is LU._sCurrPlayMode Hbp.
    repeat g1.
    match goal with
    | H1 : Mem.store Mint16signed m bp 0 _ = Some ?m1,
      H2 : Mem.store _ ?m1 ?b2 0 _ = Some ?m2,
      H3 : Mem.store _ ?m2 ?b3 0 _ = Some m',
      S2 : Genv.find_symbol _ LU._D_80339ECA = Some ?b2,
      S3 : Genv.find_symbol _ LU._D_80339EE0 = Some ?b3 |- _ =>
        rewrite (Mem.load_store_other _ _ _ _ _ _ H3 _ _ _
                   (or_introl (sym_ne _ _ _ _ Hbp S3 ltac:(idne))));
        rewrite (Mem.load_store_other _ _ _ _ _ _ H2 _ _ _
                   (or_introl (sym_ne _ _ _ _ Hbp S2 ltac:(idne))));
        rewrite (Mem.load_store_same _ _ _ _ _ _ H1); first [ reflexivity | vm_compute; reflexivity ]
    end.
  Qed.

  Lemma spm_val : forall m x t m' vres,
    eval_funcall function_entry2 G m (Internal LU.f_set_play_mode) [Vint x] t m' vres ->
    Mem.load Mint16signed m' bp 0 = Some (Vint (Int.sign_ext 16 (Int.sign_ext 16 x))).
  Proof.
    intros m x t m' vres H.
    destruct (fun_entry G LU.f_set_play_mode _ _ _ _ _ eq_refl H) as (le0 & le & out & Hb & Hx).
    cbn [LU.f_set_play_mode fn_body fn_params fn_temps bind_parameter_temps create_undef_temps] in Hb.
    injection Hb as <-.
    cbn [LU.f_set_play_mode fn_body] in Hx.
    repeat walk1. repeat st1. sym_is LU._sCurrPlayMode Hbp.
    match goal with He : eval_expr _ _ _ _ (Etempvar LU._playMode _) _ |- _ =>
      apply ev_temp in He; rewrite PTree.gss in He; injection He as <- end.
    match goal with Hc : sem_cast (Vint x) _ _ _ = Some _ |- _ => cbn in Hc; injection Hc as <- end.
    match goal with
    | H1 : Mem.store Mint16signed m bp 0 _ = Some ?m1,
      H2 : Mem.store _ ?m1 ?b2 0 _ = Some m',
      S2 : Genv.find_symbol _ LU._D_80339ECA = Some ?b2 |- _ =>
        rewrite (Mem.load_store_other _ _ _ _ _ _ H2 _ _ _
                   (or_introl (sym_ne _ _ _ _ Hbp S2 ltac:(idne))));
        rewrite (Mem.load_store_same _ _ _ _ _ _ H1); reflexivity
    end.
  Qed.

  Lemma lst_val : forall m x f t m' vres,
    eval_funcall function_entry2 G m (Internal LU.f_level_set_transition) [Vint x; f] t m' vres ->
    Mem.load Mint16signed m' bt 0 = Some (Vint (Int.sign_ext 16 (Int.sign_ext 16 x))).
  Proof.
    intros m x f t m' vres H.
    destruct (fun_entry G LU.f_level_set_transition _ _ _ _ _ eq_refl H) as (le0 & le & out & Hb & Hx).
    cbn [LU.f_level_set_transition fn_body fn_params fn_temps bind_parameter_temps create_undef_temps] in Hb.
    injection Hb as <-.
    cbn [LU.f_level_set_transition fn_body] in Hx.
    repeat walk1. repeat st1. sym_is LU._sTransitionTimer Hbt.
    match goal with He : eval_expr _ _ _ _ (Etempvar LU._length _) _ |- _ =>
      apply ev_temp in He; getnorm He; injection He as <- end.
    match goal with Hc : sem_cast (Vint x) _ _ _ = Some _ |- _ => cbn in Hc; injection Hc as <- end.
    match goal with
    | H1 : Mem.store Mint16signed m bt 0 _ = Some ?m1,
      H2 : Mem.store _ ?m1 ?b2 0 _ = Some m',
      S2 : Genv.find_symbol _ LU._sTransitionUpdate = Some ?b2 |- _ =>
        rewrite (Mem.load_store_other _ _ _ _ _ _ H2 _ _ _
                   (or_introl (sym_ne _ _ _ _ Hbt S2 ltac:(idne))));
        rewrite (Mem.load_store_same _ _ _ _ _ _ H1); reflexivity
    end.
  Qed.

  (* `warp_special(k);` : OF, footprint PMX, CHANGE_LEVEL *)
  Lemma ws_step : forall le m al t le' m' out targs tres cc,
    xs le m (Scall None (Evar LU._warp_special (Tfunction targs tres cc)) al) t le' m' out ->
    OF m -> OF m' /\ fx lp bm PMX m m' /\ Mem.load Mint16signed m' bp 0 = Some (Vint (Int.repr 4)).
  Proof.
    intros le m al t le' m' out targs tres cc H Hok.
    lvs PMX sb_pm pm_ids PL H Hok. destruct R as (Hok' & Hfx).
    destruct (lu_call _ _ _ _ _ _ _ _ _ _ _ _ _ dm_ws H) as (vargs & t' & vres & _ & Hf).
    exact (conj Hok' (conj Hfx (ws_val _ _ _ _ _ Hf))).
  Qed.

  (* `set_play_mode(k);` *)
  Lemma spm_step : forall le m k t le' m' out tres cc,
    xs le m (Scall None (Evar LU._set_play_mode (Tfunction (tshort :: nil) tres cc)) [Econst_int (Int.repr k) tint]) t le' m' out ->
    OF m -> OF m' /\ fx lp bm PMX m m'
      /\ exists x, sem_cast (Vint (Int.repr k)) tint tshort m = Some (Vint x)
         /\ Mem.load Mint16signed m' bp 0 = Some (Vint (Int.sign_ext 16 (Int.sign_ext 16 x))).
  Proof.
    intros le m k t le' m' out tres cc H Hok.
    lvs PMX sb_pm pm_ids PL H Hok. destruct R as (Hok' & Hfx).
    destruct (lu_call _ _ _ _ _ _ _ _ _ _ _ _ _ dm_spm H) as (vargs & t' & vres & Hel & Hf).
    split; [ exact Hok' | split; [ exact Hfx | ] ].
    inv Hel. match goal with Hn : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hn end.
    match goal with He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in He; subst end.
    match goal with Hc : sem_cast (Vint _) _ _ _ = Some ?v |- _ =>
      pose proof Hc as Hc0; destruct v as [ | x | | | | ]; cbn in Hc; try discriminate Hc end.
    exists x. split; [ exact Hc0 | exact (spm_val _ _ _ _ _ Hf) ].
  Qed.

  (* set_play_mode(k) for k = 2, 3, 4: play mode leaves NORMAL *)
  Ltac spm_leaves Hx Hok Qc :=
    let Hfx := fresh "Hfx" in let x := fresh "x" in let Hcx := fresh "Hcx" in let Hm := fresh "Hm" in
    destruct (spm_step _ _ _ _ _ _ _ _ _ Hx Hok) as (_ & Hfx & x & Hcx & Hm); kpa Hfx;
    vm_compute in Hcx; injection Hcx as <-;
    split; [ exact Qc | ];
    let E := fresh "E" in intros E; rewrite Hm in E; exfalso; revert E; apply vint_ne; idne.

  (* ---- initiate_delayed_warp ---- *)
  Lemma idw_Q : forall m t m' vres vm vw vo,
    eval_funcall function_entry2 G m (Internal LU.f_initiate_delayed_warp) nil t m' vres ->
    OF m -> Mem.load Mint32 m bcr 0 = Some (Vint Int.zero) ->
    Mem.load Mint32 m bd 0 = Some (Vint Int.zero) ->
    Mem.load Mint16signed m bp 0 = vm -> Mem.load Mint8unsigned m bw 0 = vw ->
    Mem.load Mint16signed m bo 0 = vo ->
    (vm = Some (Vint Int.zero) -> vw = Some (Vint Int.zero)) ->
    (forall n, vo = Some (Vint n) -> n <> Int.repr 23 /\ n <> Int.repr 24) ->
    OF m' /\ Qw m'.
  Proof.
    intros m t m' vres vm vw vo Hf Hok Hc Hd Hm Hw Ho Hmw Hop.
    destruct (entry0 G LU.f_initiate_delayed_warp m t m' vres eq_refl eq_refl Hf) as (le & out & Hx).
    cbn [LU.f_initiate_delayed_warp fn_body] in Hx.
    (* the guard and the timer decrement *)
    apply seq_plain in Hx as (t1 & le1 & m1 & t2 & HA & Hx); [ | reflexivity ].
    lvs lvl_safe_gvars sb_safe safe_ids SL HA Hok. destruct R as (Hok1 & Hfx1). kpa Hfx1.
    apply if_inv in Hx as (v3 & b3 & _ & _ & Hx). destruct b3.
    2: { apply skip_inv in Hx as (-> & _ & _). split; [ exact Hok1 | split; [ exact Hc | ] ].
         intros E. left. rewrite Hw. apply Hmw. rewrite <- Hm. exact E. }
    (* reset_dialog_render_state *)
    apply seq_plain in Hx as (t3 & le2 & m2 & t4 & HR & Hx); [ | reflexivity ].
    lvs lvl_safe_gvars sb_safe safe_ids SL HR Hok1. destruct R as (Hok2 & Hfx2). kpa Hfx2.
    (* the debug guard: temps only *)
    apply seq_plain in Hx as (t5 & le3 & m3 & t6 & HD & Hx); [ | reflexivity ].
    destruct (sets_only_mem _ _ _ _ _ _ _ _ _ HD eq_refl) as (-> & _).
    apply if_inv in Hx as (v2 & b2 & _ & _ & Hx). destruct b2.
    { (* warp_special(-9) *)
      destruct (ws_step _ _ _ _ _ _ _ _ _ _ Hx Hok2) as (Hok3 & Hfx3 & Hm4). kpa Hfx3.
      split; [ exact Hok3 | split; [ exact Hc | ] ].
      intros E. rewrite Hm4 in E. exfalso. revert E; apply vint_ne; idne. }
    (* the demo guard: gCurrDemoInput is NULL *)
    apply seq_plain in Hx as (t7 & le4 & m4 & t8 & HS & Hx); [ | reflexivity ].
    apply set_inv in HS as (v5 & Hv5 & -> & -> & _).
    gread Hv5 Hbd. rewrite Hd in Hv5. injection Hv5 as <-.
    apply if_inv in Hx as (vc & bb & Hvc & Hbb & Hx).
    destruct bb; [ exfalso; repeat g1 | ].
    (* the switch on sDelayedWarpOp *)
    apply seq_plain in Hx as (t9 & le5 & m5 & t10 & HS & Hx); [ | reflexivity ].
    apply set_inv in HS as (v6 & Hv6 & -> & -> & _).
    gread Hv6 Hbo. subst vo.
    apply switch_inv in Hx as (v & n & out1 & Hv & Hn & Hx).
    apply ev_temp in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
    destruct v6 as [ | i | | | | ]; cbn in Hn; try discriminate Hn.
    injection Hn as <-.
    destruct (Hop i Hv6) as (N23 & N24).
    unfold select_switch in Hx. cbn [select_switch_case] in Hx.
    destruct (zeq 20 (Int.unsigned i)) as [_ | _].
    { (* GAME_OVER: save_file_reload(); warp_special(-3) *)
      cbv beta iota in Hx. cbn [seq_of_labeled_statement] in Hx.
      apply seq_brk in Hx as (o1 & Hx); [ | reflexivity ].
      apply seq_plain in Hx as (t11 & le6 & m6 & t12 & HC & Hx); [ | reflexivity ].
      lvs lvl_safe_gvars sb_safe safe_ids SL HC Hok2. destruct R as (Hok6 & Hfx6). kpa Hfx6.
      apply seq_last_brk in Hx as (t13 & le7 & Hx); [ | reflexivity ].
      destruct (ws_step _ _ _ _ _ _ _ _ _ _ Hx Hok6) as (Hok7 & Hfx7 & Hm7). kpa Hfx7.
      split; [ exact Hok7 | split; [ exact Hc | ] ].
      intros E. rewrite Hm7 in E. exfalso. revert E; apply vint_ne; idne. }
    destruct (zeq 21 (Int.unsigned i)) as [_ | _].
    { (* CREDITS_END: warp_special(-1); sound_banks_enable(..) *)
      cbv beta iota in Hx. cbn [seq_of_labeled_statement] in Hx.
      apply seq_brk in Hx as (o1 & Hx); [ | reflexivity ].
      apply seq_plain in Hx as (t11 & le6 & m6 & t12 & HC & Hx); [ | reflexivity ].
      destruct (ws_step _ _ _ _ _ _ _ _ _ _ HC Hok2) as (Hok6 & Hfx6 & Hm6). kpa Hfx6.
      apply seq_last_brk in Hx as (t13 & le7 & Hx); [ | reflexivity ].
      lvs lvl_safe_gvars sb_safe safe_ids SL Hx Hok6. destruct R as (Hok7 & Hfx7). kpa Hfx7.
      split; [ exact Hok7 | split; [ exact Hc | ] ].
      intros E. rewrite Hm6 in E. exfalso. revert E; apply vint_ne; idne. }
    destruct (zeq 22 (Int.unsigned i)) as [_ | _].
    { (* DEMO_NEXT: warp_special(-2) *)
      cbv beta iota in Hx. cbn [seq_of_labeled_statement] in Hx.
      apply seq_brk in Hx as (o1 & Hx); [ | reflexivity ].
      apply seq_last_brk in Hx as (t13 & le7 & Hx); [ | reflexivity ].
      destruct (ws_step _ _ _ _ _ _ _ _ _ _ Hx Hok2) as (Hok7 & Hfx7 & Hm7). kpa Hfx7.
      split; [ exact Hok7 | split; [ exact Hc | ] ].
      intros E. rewrite Hm7 in E. exfalso. revert E; apply vint_ne; idne. }
    destruct (zeq 23 (Int.unsigned i)) as [E23 | _].
    { exfalso. apply N23. rewrite <- (Int.repr_unsigned i), <- E23. reflexivity. }
    destruct (zeq 24 (Int.unsigned i)) as [E24 | _].
    { exfalso. apply N24. rewrite <- (Int.repr_unsigned i), <- E24. reflexivity. }
    (* default: the warp node's warp *)
    cbv beta iota in Hx. cbn [select_switch_default seq_of_labeled_statement] in Hx.
    apply seq_brk in Hx as (o1 & Hx); [ | reflexivity ].
    (* area_get_warp_node *)
    apply seq_plain in Hx as (t11 & le6 & m6 & t12 & HC & Hx); [ | reflexivity ].
    lvs lvl_safe_gvars sb_safe safe_ids SL HC Hok2. destruct R as (Hok6 & Hfx6). kpa Hfx6.
    (* initiate_warp *)
    apply seq_plain in Hx as (t13 & le7 & m7 & t14 & HC7 & Hx); [ | reflexivity ].
    lvs WDX sb_wd wd_ids WL HC7 Hok6. destruct R as (Hok7 & Hfx7). kpa Hfx7.
    (* check_if_should_set_warp_checkpoint *)
    apply seq_plain in Hx as (t15 & le8 & m8 & t16 & HC8 & Hx); [ | reflexivity ].
    lvs lvl_safe_gvars sb_safe safe_ids SL HC8 Hok7. destruct R as (Hok8 & Hfx8). kpa Hfx8.
    (* if (sWarpDest.type != CHANGE_LEVEL) level_set_transition(2, NULL) *)
    apply seq_last_brk in Hx as (t17 & le9 & Hx); [ | reflexivity ].
    apply seq_plain in Hx as (t18 & le10 & m10 & t19 & HS & Hx); [ | reflexivity ].
    apply set_inv in HS as (v7 & Hv7 & -> & -> & _).
    gtype Hv7.
    apply if_inv in Hx as (vc7 & bb7 & Hvc7 & Hbb7 & Hx).
    destruct bb7.
    - lvs lvl_safe_gvars sb_safe safe_ids SL Hx Hok8. destruct R as (Hok9 & Hfx9). kpa Hfx9.
      destruct (lu_call _ _ _ _ _ _ _ _ _ _ _ _ _ dm_lst Hx) as (vargs & t' & vres' & Hel & Hf').
      inv Hel.
      match goal with He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in He; subst end.
      match goal with Hc' : sem_cast (Vint _) _ _ _ = Some _ |- _ => vm_compute in Hc'; injection Hc' as <- end.
      match goal with Hn : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hn end.
      match goal with Hn : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hn end.
      pose proof (lst_val _ _ _ _ _ _ Hf') as Ht.
      split; [ exact Hok9 | split; [ exact Hc | ] ].
      intros _. right. right. eexists. split; [ exact Ht | ].
      intros E. apply (f_equal Int.unsigned) in E. vm_compute in E. discriminate E.
    - apply skip_inv in Hx as (-> & _ & _).
      apply ev_binop in Hvc7 as (x1 & x2 & Hx1 & Hx2 & Hop').
      apply ev_temp in Hx1. rewrite PTree.gss in Hx1. injection Hx1 as <-.
      apply ev_const in Hx2. subst x2. cbn [typeof] in Hop'.
      pose proof (ne1_false _ _ _ _ _ Hop' Hbb7) as ->.
      split; [ exact Hok8 | split; [ exact Hc | ] ].
      intros _. right. left. exact Hv7.
  Qed.

  (* ---- the whole tail ---- *)
  Lemma tail_Q : forall le m t le' m' out,
    xs le m lv_tail t le' m' out -> OF m -> FfWorld.warp_w G m ->
    Mem.load Mint32 m' bcr 0 = Some (Vint Int.zero)
    /\ (Mem.load Mint16signed m' bp 0 = Some (Vint Int.zero) ->
        Mem.load Mint8unsigned m' bw 0 = Some (Vint Int.zero)).
  Proof.
    intros le m t le' m' out Hx Hok (W1 & W2 & W3 & W4 & W5).
    cbv [lv_tail lv_post lv_r1 PMN sq1 sq2 fn_body LU.f_play_mode_normal] in Hx.
    (* initiate_delayed_warp *)
    apply seq_plain in Hx as (t1 & le1 & m1 & t2 & HI & Hx); [ | reflexivity ].
    destruct (lu_call _ _ _ _ _ _ _ _ _ _ _ _ _ dm_idw HI) as (vargs & t' & vres & Hel & Hf).
    inv Hel.
    destruct (idw_Q _ _ _ _ _ _ _ Hf Hok (W3 bcr Hbcr) (W2 bd Hbd) eq_refl eq_refl eq_refl
                (W1 bp bw Hbp Hbw)
                (fun n Hn => W5 bo Hbo n Hn)) as (Hok1 & Qc & Qm).
    (* the play-mode switch; return 0 *)
    apply seq_plain in Hx as (t3 & le2 & m2 & t4 & Hx & HR); [ | reflexivity ].
    apply ret_inv in HR as (-> & _).
    apply seq_plain in Hx as (t5 & le3 & m3 & t6 & HS & Hx); [ | reflexivity ].
    apply set_inv in HS as (v6 & Hv6 & -> & -> & _).
    gread Hv6 Hbp.
    assert (K6 : kept (Mem.load Mint16signed m1 bp 0 = Some v6)) by exact Hv6.
    apply if_inv in Hx as (vc6 & bb6 & Hvc6 & Hbb6 & Hx).
    destruct bb6.
    2: { apply skip_inv in Hx as (-> & _ & _). split; [ exact Qc | ].
         intros E. rewrite E in Hv6. injection Hv6 as <-. exfalso. repeat g1. }
    apply seq_plain in Hx as (t7 & le4 & m4 & t8 & HS & Hx); [ | reflexivity ].
    apply set_inv in HS as (v7 & Hv7 & -> & -> & _).
    gtype Hv7.
    assert (K7 : kept (Mem.load Mint8unsigned m1 bw 0 = Some v7)) by exact Hv7.
    apply if_inv in Hx as (vc7 & bb7 & Hvc7 & Hbb7 & Hx).
    destruct bb7.
    { (* CHANGE_LEVEL: set_play_mode(PLAY_MODE_CHANGE_LEVEL) *)
      spm_leaves Hx Hok1 Qc. }
    apply seq_plain in Hx as (t9 & le5 & m5 & t10 & HS & Hx); [ | reflexivity ].
    apply set_inv in HS as (v8 & Hv8 & -> & -> & _).
    gread Hv8 Hbt.
    apply if_inv in Hx as (vc8 & bb8 & Hvc8 & Hbb8 & Hx).
    destruct bb8.
    { (* a transition: set_play_mode(PLAY_MODE_CHANGE_AREA) *)
      spm_leaves Hx Hok1 Qc. }
    (* pressed_pause *)
    apply seq_plain in Hx as (t11 & le6 & m6 & t12 & HC & Hx); [ | reflexivity ].
    lvs lvl_safe_gvars sb_safe safe_ids SL HC Hok1. destruct R as (Hok6 & Hfx6). kpa Hfx6.
    apply if_inv in Hx as (vc5 & bb5 & _ & _ & Hx).
    destruct bb5.
    { (* paused: lower_background_noise(1); flags; set_play_mode(PLAY_MODE_PAUSED) *)
      apply seq_plain in Hx as (t13 & le7 & m7 & t14 & HC7 & Hx); [ | reflexivity ].
      lvs lvl_safe_gvars sb_safe safe_ids SL HC7 Hok6. destruct R as (Hok7 & Hfx7). kpa Hfx7.
      apply seq_plain in Hx as (t15 & le8 & m8 & t16 & HC8 & Hx); [ | reflexivity ].
      lvs lvl_safe_gvars sb_safe safe_ids SL HC8 Hok7. destruct R as (Hok8 & Hfx8). kpa Hfx8.
      spm_leaves Hx Hok8 Qc. }
    (* no warp, no pause: play mode stays NORMAL, so the type is NOT_WARPING *)
    apply skip_inv in Hx as (-> & _ & _).
    split; [ exact Qc | ].
    intros E. rewrite E in Hv6. injection Hv6 as <-.
    destruct (Qm K6) as [Q0 | [Q1 | (n & Qt & Qn)]].
    - rewrite Hv7. unfold kept in K7. rewrite K7 in Q0. exact Q0.
    - unfold kept in K7. rewrite K7 in Q1. injection Q1 as ->. exfalso. repeat g1.
    - rewrite Qt in Hv8. injection Hv8 as <-.
      apply ev_binop in Hvc8 as (x1 & x2 & Hx1 & Hx2 & Hop').
      apply ev_temp in Hx1. rewrite PTree.gss in Hx1. injection Hx1 as <-.
      apply ev_const in Hx2. subst x2. cbn [typeof] in Hop'.
      exfalso. exact (Qn (ne0_false _ _ _ _ _ Hop' Hbb8)).
  Qed.

  (* the theorem: the tail re-establishes warp_w *)
  Theorem tail_warp_w : forall le m t le' m' out,
    xs le m lv_tail t le' m' out -> OF m -> FfWorld.warp_w G m ->
    fx lp bm level_gvars m m' -> FfWorld.warp_w G m'.
  Proof.
    intros le m t le' m' out Hx Hok Hw Hfx.
    destruct (tail_Q _ _ _ _ _ _ Hx Hok Hw) as (Qc & Qm).
    destruct Hw as (W1 & W2 & W3 & W4 & W5).
    split; [ | split; [ | split; [ | split ] ] ].
    - intros bp' bw' Sp Sw. rewrite Hbp in Sp. injection Sp as <-. rewrite Hbw in Sw. injection Sw as <-.
      exact Qm.
    - intros b Sb. rewrite (fx_keep level_gvars _ b Mint32 0 m m' Sb ltac:(vm_compute; reflexivity) ltac:(idne) Hfx).
      exact (W2 b Sb).
    - intros b Sb. rewrite Hbcr in Sb. injection Sb as <-. exact Qc.
    - intros bo' bs Ho Hs.
      rewrite (fx_keep level_gvars _ bo' Mint16signed 0 m m' Ho ltac:(vm_compute; reflexivity) ltac:(idne) Hfx).
      rewrite (fx_keep level_gvars _ bs Mint16signed 0 m m' Hs ltac:(vm_compute; reflexivity) ltac:(idne) Hfx).
      exact (W4 bo' bs Ho Hs).
    - intros bo' Ho.
      rewrite (fx_keep level_gvars _ bo' Mint16signed 0 m m' Ho ltac:(vm_compute; reflexivity) ltac:(idne) Hfx).
      exact (W5 bo' Ho).
  Qed.
End Warp.
