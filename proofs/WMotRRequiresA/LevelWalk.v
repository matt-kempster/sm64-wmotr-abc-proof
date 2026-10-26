(* ====================================================================== *)
(* LevelWalk (GOAL 2): the level phase's callees, walked from their real  *)
(* bodies for the frame's footprint (2026-10-24).                         *)
(*                                                                        *)
(* The level phase of play_mode_normal (LevelFlank) calls, besides the    *)
(* camera: update_hud_values, initiate_painting_warp,                    *)
(* initiate_delayed_warp, set_play_mode, pressed_pause,                   *)
(* lower_background_noise, and through them the warp / transition /      *)
(* dialog / cutscene / save-reload / sound helpers.  Each body here is    *)
(* walked by AudioBodies' generic walker (lw_chk) with a COMBINED carried *)
(* invariant: GOAL 1's facts (ow_facts: Mario's block valid, its action   *)
(* untainted, MWF_real) AND the footprint fx m0 m:                        *)
(*   memory changed only in the blocks of a global list Xs (the walks use *)
(*   LevelGvars.level_gvars, or lvl_safe_gvars: those minus the warp      *)
(*   cells FfWorld.lvl_w pins) and in gMarioStates' numCoins / numLives   *)
(*   cells (168..169, 173), every old permission kept, every new block    *)
(*   left without permissions.                                            *)
(* The walk accepts a body whose                                          *)
(*  - stores pass AudioBodies' class (a global-rooted chain into a stored *)
(*    global, or a non-pointer into a global MWF does not read) AND land  *)
(*    in an Xs block, or are update_hud_values' clamps                    *)
(*    `gMarioState->numLives = 100` / `->numCoins = 999` through a temp   *)
(*    that only holds gMarioState's value (MWF_real's R5: &gMarioStates);  *)
(*  - calls are to the listed (bottom-up proved) callees, or save_file's  *)
(*    bcopy into gSaveBuffer (save_file_reload; the bcopy floor spec,     *)
(*    OsDmaFloor, TRUST 3.5).                                             *)
(* A second, plain walk (the cl_ one) gives the closedness carry for the        *)
(* calls-with-constant-arguments statements of the phase.                *)
(* ====================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario level_update audio_external sound_init ingame_menu
  save_file camera area.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated MathBodies LinkedTwelve MtxfBody SaveFileBody
  ObjExtBodies AudioBodies OsDmaFloor.
From SM64.Proofs Require ActWriterSurface SaveDoSaveBody.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim LevelGvars LevelFlank.
Import ListNotations.
Local Open Scope Z_scope.

Module SFL := save_file.
Module CAL := camera.
Module IML := ingame_menu.
Module ARL := area.

(* ---------------------------------------------------------------------- *)
(* 1. The footprint.                                                       *)
(* ---------------------------------------------------------------------- *)

Section FX.
  Variable lp : Clight.program.
  Variable bm : block.
  Variable Xs : list ident.
  Notation G := (lp_ge lp).

  (* a written global's block *)
  Definition lvl_blk (b : block) : Prop :=
    exists id, In id Xs /\ Genv.find_symbol G id = Some b.

  (* the cells the level phase may write *)
  Definition lvW (b : block) (z : Z) : Prop :=
    lvl_blk b \/ (b = bm /\ (168 <= z < 170 \/ z = 173)).

  Definition fx (m m' : mem) : Prop :=
    Mem.unchanged_on (fun b z => ~ lvW b z) m m'
    /\ (forall b o k p, Mem.valid_block m b -> (Mem.perm m b o k p <-> Mem.perm m' b o k p))
    /\ (forall b o k p, ~ Mem.valid_block m b -> ~ Mem.perm m' b o k p).

  Lemma fx_refl : forall m, fx m m.
  Proof.
    intros m. split; [ apply Mem.unchanged_on_refl | split ].
    - tauto.
    - intros b o k p Hv Hp. exact (Hv (Mem.perm_valid_block _ _ _ _ _ Hp)).
  Qed.

  Lemma fx_trans : forall m1 m2 m3, fx m1 m2 -> fx m2 m3 -> fx m1 m3.
  Proof.
    intros m1 m2 m3 (U1 & P1 & F1) (U2 & P2 & F2).
    split; [ exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) | split ].
    - intros b o k p Hv. rewrite (P1 b o k p Hv).
      apply P2. eapply Mem.valid_block_unchanged_on; eauto.
    - intros b o k p Hv Hp.
      destruct (plt b (Mem.nextblock m2)) as [Hv2 | Hv2].
      + apply (F1 b o k p Hv). apply (P2 b o k p Hv2). exact Hp.
      + exact (F2 b o k p Hv2 Hp).
  Qed.

  Lemma fx_store : forall m ch b z v m',
    Mem.store ch m b z v = Some m' ->
    (forall i, z <= i < z + size_chunk ch -> lvW b i) -> fx m m'.
  Proof.
    intros m ch b z v m' Hs Hw.
    split; [ | split ].
    - eapply Mem.store_unchanged_on; [ exact Hs | ]. intros i Hi N. exact (N (Hw i Hi)).
    - intros b' o k p _. split; [ eapply Mem.perm_store_1 | eapply Mem.perm_store_2 ]; eauto.
    - intros b' o k p Hv Hp. apply Hv.
      eapply Mem.store_valid_block_2; [ exact Hs | exact (Mem.perm_valid_block _ _ _ _ _ Hp) ].
  Qed.

  Lemma fx_load : forall m m' ch b z, fx m m' ->
    (forall i, z <= i < z + size_chunk ch -> ~ lvW b i) ->
    Mem.load ch m' b z = Mem.load ch m b z.
  Proof.
    intros m m' ch b z (U & P & F) Hn.
    destruct (plt b (Mem.nextblock m)) as [Hv | Hv].
    - eapply Mem.load_unchanged_on_1; [ exact U | exact Hv | exact Hn ].
    - destruct (Mem.load ch m b z) eqn:E.
      + exfalso. apply Hv. apply Mem.load_valid_access in E.
        eapply Mem.valid_access_valid_block.
        eapply Mem.valid_access_implies; [ exact E | constructor ].
      + destruct (Mem.load ch m' b z) eqn:E'; [ | reflexivity ].
        exfalso. apply Mem.load_valid_access in E' as (Hr & _).
        apply (F b z Cur Readable Hv). apply Hr. pose proof (size_chunk_pos ch). lia.
  Qed.

  Lemma fx_valid : forall m m' b, fx m m' -> Mem.valid_block m b -> Mem.valid_block m' b.
  Proof. intros m m' b (U & _) Hv. eapply Mem.valid_block_unchanged_on; eauto. Qed.

  (* a fresh block allocated and freed again *)
  Lemma fx_alloc_free : forall m lo hi m1 b m2,
    Mem.alloc m lo hi = (m1, b) -> Mem.free m1 b lo hi = Some m2 -> fx m m2.
  Proof.
    intros m lo hi m1 b m2 Ha Hf.
    pose proof (Mem.fresh_block_alloc _ _ _ _ _ Ha) as Hfr.
    split; [ | split ].
    - assert (U : Mem.unchanged_on (fun b' _ => Mem.valid_block m b') m m2).
      { eapply Mem.unchanged_on_trans.
        - eapply Mem.alloc_unchanged_on; exact Ha.
        - eapply Mem.free_unchanged_on; [ exact Hf | ]. intros i _ Hv. exact (Hfr Hv). }
      eapply Mem.unchanged_on_implies; [ exact U | ]. intros b' z _ Hv. exact Hv.
    - intros b' o k p Hv.
      assert (Ne : b' <> b) by (intros ->; exact (Hfr Hv)).
      split; intros Hp.
      + eapply Mem.perm_free_1; [ exact Hf | left; exact Ne | ].
        eapply Mem.perm_alloc_1; eauto.
      + eapply Mem.perm_alloc_4; [ exact Ha | | exact Ne ].
        eapply Mem.perm_free_3; eauto.
    - intros b' o k p Hv Hp.
      pose proof (Mem.perm_free_3 _ _ _ _ _ Hf _ _ _ _ Hp) as Hp1.
      destruct (eq_block b' b) as [-> | Ne].
      + pose proof (Mem.perm_alloc_3 _ _ _ _ _ Ha _ _ _ Hp1) as Hr.
        exact (Mem.perm_free_2 _ _ _ _ _ Hf o k p Hr Hp).
      + apply (Mem.perm_valid_block) in Hp1.
        destruct (Mem.valid_block_alloc_inv _ _ _ _ _ Ha _ Hp1) as [E | V]; [ exact (Ne E) | exact (Hv V) ].
  Qed.
End FX.

(* the POST tail's narrower footprints (2026-10-26, LevelWarp): the safe
   list plus ONE warp cell *)
Definition PMX : list ident := LU._sCurrPlayMode :: lvl_safe_gvars.
Definition WDX : list ident := LU._sWarpDest :: lvl_safe_gvars.

(* ---------------------------------------------------------------------- *)
(* 2. The recognizers.                                                     *)
(* ---------------------------------------------------------------------- *)

Definition ms_ty : type := Tstruct LU._MarioState noattr.
Definition ms_ptr : type := tptr ms_ty.

(* `t = gMarioState` *)
Definition is_gms_rhs (a : expr) : bool :=
  match a with Evar g ty => Pos.eqb g LU._gMarioState && type_eqb ty ms_ptr | _ => false end.

(* gt: AudioBodies' tracked address temps; gms: temps that only hold
   gMarioState's value *)
Definition lv_set_ok (gt : list (ident * ident)) (gms : list ident) (id : ident) (a : expr) : bool :=
  au_set_ok gt id a && (negb (mem_id id gms) || is_gms_rhs a).

(* `t->numLives = c` / `t->numCoins = c`, t a gms temp *)
Definition gms_store_ok (gms : list ident) (lv rhs : expr) : bool :=
  match lv, rhs with
  | Efield (Ederef (Etempvar t tp) ts) f ty, Econst_int _ _ =>
      mem_id t gms && type_eqb tp ms_ptr && type_eqb ts ms_ty
      && ((Pos.eqb f LU._numLives && type_eqb ty tschar)
          || (Pos.eqb f LU._numCoins && type_eqb ty tshort))
  | _, _ => false
  end.

Definition lv_store_ok (Xs : list ident) (gt : list (ident * ident)) (gms : list ident) (lv rhs : expr) : bool :=
  match au_root gt lv with
  | Some g => au_store_ok gt lv rhs && mem_id g Xs
  | None => gms_store_ok gms lv rhs
  end.

Definition untracked (gt : list (ident * ident)) (gms : list ident) (o : option ident) : bool :=
  match o with
  | Some t => match gt_of gt t with Some _ => false | None => negb (mem_id t gms) end
  | None => true
  end.

(* bcopy(src, dst, n) with dst inside gSaveBuffer *)
Definition bcopy_ok (a : expr) (al : list expr) : bool :=
  match a, al with
  | Evar f (Tfunction _ _ _), [_; d; _] =>
      Pos.eqb f SFL._bcopy
      && match groot_e d with Some g => Pos.eqb g SFL._gSaveBuffer | None => false end
  | _, _ => false
  end.

Definition lv_call_ok (gt : list (ident * ident)) (gms ids : list ident)
    (o : option ident) (a : expr) (al : list expr) : bool :=
  untracked gt gms o && (gcall_ok ids a al || bcopy_ok a al).

Definition lv_params_ok (gt : list (ident * ident)) (gms : list ident) (f : Clight.function) : bool :=
  forallb (fun p => match gt_of gt (fst p) with Some _ => false | None => negb (mem_id (fst p) gms) end)
    (fn_params f).

Definition lv_chk (Xs : list ident) (gt : list (ident * ident)) (gms ids : list ident) (f : Clight.function) : bool :=
  match fn_vars f with nil => true | _ => false end
  && lv_params_ok gt gms f
  && lw_chk (lv_set_ok gt gms) (lv_store_ok Xs gt gms) (lv_call_ok gt gms ids) (fn_body f).

(* a statement of the level slice itself (no tracked temps) *)
Definition lv_stmt_chk (Xs ids : list ident) (s : statement) : bool :=
  lw_chk (lv_set_ok nil nil) (lv_store_ok Xs nil nil) (lv_call_ok nil nil ids) s.

Lemma lv_params_notin : forall gt gms f t, lv_params_ok gt gms f = true ->
  (gt_of gt t <> None \/ mem_id t gms = true) ->
  forallb (fun p => negb (Pos.eqb (fst p) t)) (fn_params f) = true.
Proof.
  intros gt gms f t Hok Ht. unfold lv_params_ok in Hok.
  apply forallb_forall. intros p Hp.
  pose proof (proj1 (forallb_forall _ _) Hok p Hp) as Hq.
  destruct p as [pid pty]. cbn [fst] in Hq |- *.
  destruct (Pos.eqb pid t) eqn:E; [ | reflexivity ].
  apply Pos.eqb_eq in E. subst pid.
  destruct Ht as [Ht | Ht].
  - destruct (gt_of gt t); [ discriminate Hq | congruence ].
  - destruct (gt_of gt t); [ discriminate Hq | ]. rewrite Ht in Hq. discriminate Hq.
Qed.

(* a by-value assignment is one store *)
Lemma assign_store : forall (ge : genv) ty m loc ofs bf v m',
  MtxfBody.is_byval ty = true -> assign_loc ge ty m loc ofs bf v m' ->
  exists ch z v', Mem.store ch m loc z v' = Some m'.
Proof.
  intros ge ty m loc ofs bf v m' Hbv Ha. inv Ha.
  - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs; eauto end.
  - unfold MtxfBody.is_byval in Hbv.
    match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
  - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs; eauto end.
Qed.

Lemma exprlist_2nd : forall (ge : genv) e le m a1 a2 a3 tys v1 v2 v3,
  eval_exprlist ge e le m (a1 :: a2 :: a3 :: nil) tys (v1 :: v2 :: v3 :: nil) ->
  exists ty2 w, eval_expr ge e le m a2 w /\ sem_cast w (typeof a2) ty2 m = Some v2.
Proof.
  intros ge e le m a1 a2 a3 tys v1 v2 v3 H.
  inv H. match goal with H' : eval_exprlist _ _ _ _ (a2 :: _) _ _ |- _ => inv H' end. eauto.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The walk's soundness, on the link.                                   *)
(* ---------------------------------------------------------------------- *)

Section LW.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  (* the libultra / hardware floor (TRUST 3.5): bcopy's spec *)
  Hypothesis Hfloor : os_dma_floor.

  Notation G := (lp_ge lp).
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation OF := (ow_facts bm MWF).

  Lemma lu_cenv : forall id co, (prog_comp_env LU.prog) ! id = Some co -> (genv_cenv G) ! id = Some co.
  Proof.
    intros id co Hco. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp LU.prog id co (linked12_LO_lvl lp H12) Hco).
  Qed.

  Lemma fo_lives : forall co, (genv_cenv G) ! LU._MarioState = Some co ->
    field_offset G LU._numLives (co_members co) = OK (173, Full).
  Proof. apply (fo_ok_lift (prog_comp_env LU.prog)); [ vm_compute; reflexivity | exact lu_cenv ]. Qed.
  Lemma fo_coins : forall co, (genv_cenv G) ! LU._MarioState = Some co ->
    field_offset G LU._numCoins (co_members co) = OK (168, Full).
  Proof. apply (fo_ok_lift (prog_comp_env LU.prog)); [ vm_compute; reflexivity | exact lu_cenv ]. Qed.

  Definition gms_P (gms : list ident) (le : temp_env) : Prop :=
    forall t b o, mem_id t gms = true -> le ! t = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.

  Definition lv_P (gt : list (ident * ident)) (gms : list ident) (le : temp_env) : Prop :=
    au_P lp gt le /\ gms_P gms le.

  Lemma lv_P_nil : forall le, lv_P nil nil le.
  Proof. intros le. split; [ exact (au_P_nil lp le) | intros t b o H; discriminate H ]. Qed.

  Lemma lv_set : forall gt gms id a le m v,
      lv_set_ok gt gms id a = true -> lv_P gt gms le -> OF m ->
      eval_expr G empty_env le m a v -> lv_P gt gms (PTree.set id v le).
  Proof.
    intros gt gms id a le m v Hok (HP & HG) Hf Hev.
    unfold lv_set_ok in Hok. apply andb_prop in Hok as [Ha Hg].
    split.
    - intros t g b o Ht Hle.
      destruct (peq t id) as [-> | Hne].
      + rewrite PTree.gss in Hle. injection Hle as ->.
        unfold au_set_ok in Ha. rewrite Ht in Ha.
        destruct (groot_e a) as [g'|] eqn:Hge; [ | discriminate Ha ].
        apply Pos.eqb_eq in Ha. subst g'.
        destruct (groot_e_val _ _ _ _ _ _ Hge Hev) as (b' & o' & E & Hs).
        injection E as -> ->. exact Hs.
      + rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
    - intros t b o Ht Hle.
      destruct (peq t id) as [-> | Hne].
      + rewrite PTree.gss in Hle. injection Hle as ->.
        rewrite Ht in Hg. cbn [negb orb] in Hg.
        destruct a as [ | | | | g ty | | | | | | | | | ]; try discriminate Hg.
        cbn [is_gms_rhs] in Hg. apply andb_prop in Hg as [Hg Hty].
        apply Pos.eqb_eq in Hg. apply type_eqb_eq in Hty. subst g ty.
        unfold ms_ptr, ms_ty in Hev.
        eapply ev_gvar in Hev; [ | apply PTree.gempty | reflexivity ].
        destruct Hev as (gb & Hs & Hl).
        pose proof Hf as (_ & _ & HM).
        exact (mwf_real_pgms lp bm bc oc0 SafeB m gb b o HM Hs Hl).
      + rewrite PTree.gso in Hle by exact Hne. exact (HG _ _ _ Ht Hle).
  Qed.

  (* a store into gMarioStates at a numCoins / numLives cell *)
  Lemma bm_cell_store : forall Xs m ch z v m' m0,
      Mem.store ch m bm z v = Some m' ->
      (forall i, z <= i < z + size_chunk ch -> 168 <= i < 170 \/ i = 173) ->
      store_window_ok z (size_chunk ch) = true ->
      OF m /\ fx lp bm Xs m0 m -> OF m' /\ fx lp bm Xs m0 m'.
  Proof.
    intros Xs m ch z v m' m0 Hst Hc Hw ((Hv & Hsat & HM) & Hfx).
    split; [ split; [ | split ] | ].
    - eapply Mem.store_valid_block_1; eauto.
    - eapply action_sat_unchanged_on with (m := m); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i Hi [_ Hi2]. destruct (Hc i Hi) as [H | H]; cbn in Hi2; lia.
    - destruct Hspawn as (init & Hs).
      exact (mwf_real_window lp bm bc oc0 SafeB (spawn_Hbc_bm lp init bm bc oc0 Hs)
               (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms)
               (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
               (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
               (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms)
               (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms) m m' ch z v HM Hw Hst).
    - apply (fx_trans lp bm Xs m0 m m' Hfx).
      apply (fx_store lp bm Xs m ch bm z v m' Hst).
      intros i Hi. right. split; [ reflexivity | exact (Hc i Hi) ].
  Qed.

  Section XS.
  (* the written globals; save_file_reload's bcopy lands in gSaveBuffer *)
  Variable Xs : list ident.
  Hypothesis Hsb : In SFL._gSaveBuffer Xs.
  Notation fx := (fx lp bm Xs).

  Lemma lv_store : forall gt gms lv rhs le m t le' m' out m0,
      lv_store_ok Xs gt gms lv rhs = true -> lv_P gt gms le ->
      exec_stmt function_entry2 G empty_env le m (Sassign lv rhs) t le' m' out ->
      OF m /\ fx m0 m -> OF m' /\ fx m0 m'.
  Proof.
    intros gt gms lv rhs le m t le' m' out m0 Hok (HP & HG) Hx (Hf & Hfx).
    unfold lv_store_ok in Hok.
    destruct (au_root gt lv) as [g|] eqn:Hr.
    - apply andb_prop in Hok as [Hau Hlg].
      split; [ exact (au_store lp bm bc oc0 SafeB HSafeB_syms Hspawn gt lv rhs le m t le' m' out Hau HP Hx Hf) | ].
      apply (fx_trans lp bm Xs m0 m m' Hfx).
      pose proof Hau as Hau'. unfold au_store_ok in Hau'. rewrite Hr in Hau'.
      apply andb_prop in Hau' as [Hbv _].
      apply assign_inv in Hx. destruct Hx as (loc & ofs & bf & v2 & v & Hl & _ & _ & Ha & _ & _).
      pose proof (au_root_blk lp gt lv le m loc ofs bf g Hr HP Hl) as Hs.
      destruct (assign_store _ _ _ _ _ _ _ _ Hbv Ha) as (ch & z & v' & Hst).
      apply (fx_store lp bm Xs m ch loc z v' m' Hst).
      intros i _. left. exists g. split; [ exact (mem_id_In _ _ Hlg) | exact Hs ].
    - destruct lv as [ | | | | | | | | | | | lv0 f ty | | ]; try discriminate Hok.
      destruct lv0 as [ | | | | | | e1 ts | | | | | | | ]; try discriminate Hok.
      destruct e1 as [ | | | | | t1 tp | | | | | | | | ]; try discriminate Hok.
      destruct rhs as [ i rty | | | | | | | | | | | | | ]; try discriminate Hok.
      cbn [gms_store_ok] in Hok.
      apply andb_prop in Hok as [Hok Hfb]. apply andb_prop in Hok as [Hok Hts].
      apply andb_prop in Hok as [Hmt Htp].
      apply type_eqb_eq in Hts. apply type_eqb_eq in Htp. subst ts tp.
      apply assign_inv in Hx. destruct Hx as (loc & ofs & bf & v2 & v & Hl & _ & _ & Ha & _ & _).
      unfold ms_ptr, ms_ty in Hl.
      apply orb_true_iff in Hfb as [Hfb | Hfb]; apply andb_prop in Hfb as [Hfn Hty];
        apply Pos.eqb_eq in Hfn; apply type_eqb_eq in Hty; subst f ty.
      + destruct (lv_fld _ _ _ _ _ _ _ _ _ _ _ _ fo_lives Hl) as (o & Hle & -> & ->).
        destruct (HG t1 loc o Hmt Hle) as (-> & ->).
        pose proof Ha as Hst.
        eapply store_by_value with (ch := Mint8signed) in Hst; [ | reflexivity | reflexivity ].
        assert (E : Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 173)) = 173) by reflexivity.
        rewrite E in Hst.
        refine (bm_cell_store Xs m Mint8signed 173 v m' m0 Hst _ ltac:(vm_compute; reflexivity) (conj Hf Hfx)).
        intros i0 Hi. cbn in Hi. right. lia.
      + destruct (lv_fld _ _ _ _ _ _ _ _ _ _ _ _ fo_coins Hl) as (o & Hle & -> & ->).
        destruct (HG t1 loc o Hmt Hle) as (-> & ->).
        pose proof Ha as Hst.
        eapply store_by_value with (ch := Mint16signed) in Hst; [ | reflexivity | reflexivity ].
        assert (E : Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 168)) = 168) by reflexivity.
        rewrite E in Hst.
        refine (bm_cell_store Xs m Mint16signed 168 v m' m0 Hst _ ltac:(vm_compute; reflexivity) (conj Hf Hfx)).
        intros i0 Hi. cbn in Hi. left. lia.
  Qed.

  (* every function the symbol g resolves to keeps the facts within the footprint *)
  Definition lfun (g : ident) : Prop :=
    forall b fd, Genv.find_symbol G g = Some b -> Genv.find_funct_ptr G b = Some fd ->
      forall m vargs t m' vres, eval_funcall function_entry2 G m fd vargs t m' vres ->
        OF m -> OF m' /\ fx m m'.

  Lemma gsb_sg : mem_id SFL._gSaveBuffer stored_globals = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma lv_call : forall gt gms ids, (forall g, mem_id g ids = true -> lfun g) ->
      forall optid a al le m t le' m' out m0,
      lv_call_ok gt gms ids optid a al = true -> lv_P gt gms le ->
      exec_stmt function_entry2 G empty_env le m (Scall optid a al) t le' m' out ->
      OF m /\ fx m0 m -> (OF m' /\ fx m0 m') /\ lv_P gt gms le'.
  Proof.
    intros gt gms ids Hids optid a al le m t le' m' out m0 Hok (HP & HG) Hx (Hf & Hfx).
    unfold lv_call_ok in Hok. apply andb_prop in Hok as [Hu Hc].
    apply call_inv in Hx.
    destruct Hx as (tyargs & tyres & cc & vf & vargs & fd & vres & _ & Hev & Hel & Hff & _ & Hfc & -> & ->).
    assert (HPo : lv_P gt gms (set_opttemp optid vres le)).
    { destruct optid as [ti|]; cbn [set_opttemp]; [ | exact (conj HP HG) ].
      cbn [untracked] in Hu.
      destruct (gt_of gt ti) eqn:Eg; [ discriminate Hu | ]. apply negb_true_iff in Hu.
      split.
      - intros t0 g b o Ht Hle. destruct (peq t0 ti) as [-> | Hne]; [ congruence | ].
        rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
      - intros t0 b o Ht Hle. destruct (peq t0 ti) as [-> | Hne]; [ congruence | ].
        rewrite PTree.gso in Hle by exact Hne. exact (HG _ _ _ Ht Hle). }
    split; [ | exact HPo ].
    apply orb_true_iff in Hc as [Hc | Hc].
    - (* a listed callee *)
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hc.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hc.
      cbn [gcall_ok] in Hc.
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev (PTree.gempty _ _)) as (lf & Hsy & ->).
      rewrite Genv.find_funct_find_funct_ptr in Hff.
      destruct (Hids fid Hc lf fd Hsy Hff _ _ _ _ _ Hfc Hf) as (Hf' & Hfx').
      exact (conj Hf' (fx_trans lp bm Xs _ _ _ Hfx Hfx')).
    - (* bcopy into gSaveBuffer *)
      unfold bcopy_ok in Hc.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hc.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hc.
      destruct al as [ | asrc [ | ad [ | an [ | ] ] ] ]; try discriminate Hc.
      apply andb_prop in Hc as [Hb Hd]. apply Pos.eqb_eq in Hb. subst fid.
      destruct (groot_e ad) as [g|] eqn:Hgd; [ | discriminate Hd ].
      apply Pos.eqb_eq in Hd. subst g.
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev (PTree.gempty _ _)) as (lf & Hsy & ->).
      destruct (MtxfBody.xresolve lp SFL.prog SFL._bcopy [SFL._bcopy] "bcopy" lf fd H12
                  (linked12_LO_save lp H12) ltac:(vm_compute; reflexivity)
                  ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) Hsy Hff)
        as (sg & targs' & tres' & cc' & ->).
      inv Hfc.
      match goal with Hx : external_call _ _ _ _ _ _ _ |- _ => rename Hx into Hext end.
      pose proof Hfloor as (_ & _ & _ & _ & _ & _ & Hbc).
      destruct (Hbc _ _ _ _ _ _ _ Hext) as (bs & os & bd & od & n & Hva & UO & (NB & SP) & _).
      subst vargs.
      destruct (exprlist_2nd _ _ _ _ _ _ _ _ _ _ _ Hel) as (ty2 & w & Hw & Hcw).
      apply ActWriterSurface.sem_cast_vptr_inv in Hcw. subst w.
      destruct (groot_e_val _ _ _ _ _ _ Hgd Hw) as (b0 & o0 & E & Hsb0).
      injection E as <- <-.
      split.
      + apply (SaveDoSaveBody.harm_change lp bm bc oc0 SafeB Hspawn m m' Hf).
        eapply Mem.unchanged_on_implies; [ exact UO | ].
        intros b z Hnh _. left. intros ->.
        exact (Hnh (SaveDoSaveBody.harm_sglob lp bm bc oc0 SafeB HSafeB_syms Hspawn _ _ gsb_sg Hsb0)).
      + apply (fx_trans lp bm Xs m0 m m' Hfx).
        split; [ | split ].
        * eapply Mem.unchanged_on_implies; [ exact UO | ].
          intros b z Hnw _. left. intros ->. apply Hnw. left. exists SFL._gSaveBuffer.
          exact (conj Hsb Hsb0).
        * intros b o k p _. rewrite (SP b o k p). tauto.
        * intros b o k p Hv Hp. apply Hv. unfold Mem.valid_block. rewrite <- NB.
          exact (Mem.perm_valid_block _ _ _ _ _ Hp).
  Qed.

  (* THE BODY BRICK *)
  Lemma lv_body : forall gt gms ids f,
      lv_chk Xs gt gms ids f = true -> (forall g, mem_id g ids = true -> lfun g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 G m (Internal f) vargs t m' vres ->
        OF m -> OF m' /\ fx m m'.
  Proof.
    intros gt gms ids f Hchk Hids m vargs t m' vres Hevf Hf.
    unfold lv_chk in Hchk.
    apply andb_prop in Hchk as [Hchk Hw]. apply andb_prop in Hchk as [Hv Hpar].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    refine (lw_body_frame G (fun mm => OF mm /\ fx m mm) f (lv_P gt gms) (lv_set_ok gt gms)
              (lv_store_ok Xs gt gms) (lv_call_ok gt gms ids) Hvars Hw _ _ _ m vargs t m' vres Hevf _
              (conj Hf (fx_refl lp bm Xs m))).
    - intros id a le mm v Hok HP (Hq & _) Hev. exact (lv_set gt gms id a le mm v Hok HP Hq Hev).
    - intros lv rhs le mm t0 le' mm' out Hok HP Hx Hq.
      exact (lv_store gt gms lv rhs le mm t0 le' mm' out m Hok HP Hx Hq).
    - intros optid a al le mm t0 le' mm' out Hok HP Hx Hq.
      exact (lv_call gt gms ids Hids optid a al le mm t0 le' mm' out m Hok HP Hx Hq).
    - intros le1 Hb. split.
      + intros t0 g b o Ht Hle.
        assert (Ht' : gt_of gt t0 <> None) by (rewrite Ht; discriminate).
        rewrite (bind_notin _ _ _ _ _ Hb (lv_params_notin gt gms f t0 Hpar (or_introl Ht'))) in Hle.
        apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
      + intros t0 b o Ht Hle.
        rewrite (bind_notin _ _ _ _ _ Hb (lv_params_notin gt gms f t0 Hpar (or_intror Ht))) in Hle.
        apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  Qed.

  (* a statement of the level slice, from any temps *)
  Lemma lv_stmt : forall ids s, lv_stmt_chk Xs ids s = true ->
      (forall g, mem_id g ids = true -> lfun g) ->
      forall le m t le' m' out,
        exec_stmt function_entry2 G empty_env le m s t le' m' out ->
        OF m -> OF m' /\ fx m m'.
  Proof.
    intros ids s Hchk Hids le m t le' m' out Hx Hf.
    refine (proj1 (lw_walk G empty_env (fun mm => OF mm /\ fx m mm) (lv_P nil nil)
              (lv_set_ok nil nil) (lv_store_ok Xs nil nil) (lv_call_ok nil nil ids) _ _ _
              empty_env le m s t le' m' out Hx eq_refl Hchk (lv_P_nil le) (conj Hf (fx_refl lp bm Xs m)))).
    - intros id a le0 mm v Hok HP (Hq & _) Hev. exact (lv_set nil nil id a le0 mm v Hok HP Hq Hev).
    - intros lv rhs le0 mm t0 le1 mm' out0 Hok HP Hx0 Hq.
      exact (lv_store nil nil lv rhs le0 mm t0 le1 mm' out0 m Hok HP Hx0 Hq).
    - intros optid a al le0 mm t0 le1 mm' out0 Hok HP Hx0 Hq.
      exact (lv_call nil nil ids Hids optid a al le0 mm t0 le1 mm' out0 m Hok HP Hx0 Hq).
  Qed.

  Lemma lfun_of_body : forall (q : Clight.program) g f, linkorder q lp ->
      (prog_defmap q) ! g = Some (Gfun (Internal f)) ->
      (forall m vargs t m' vres, eval_funcall function_entry2 G m (Internal f) vargs t m' vres ->
         OF m -> OF m' /\ fx m m') -> lfun g.
  Proof.
    intros q g f LO Hdm Hb b fd Hs Hfp.
    destruct (linkorder_resolves_funct lp _ g f LO Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hfp. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. rewrite Hfp in Hf'.
    injection Hf' as ->. exact Hb.
  Qed.

  End XS.

  Definition AllX : list ident := level_gvars.
  Lemma sb_all : In SFL._gSaveBuffer level_gvars.
  Proof. apply mem_id_In. vm_compute. reflexivity. Qed.
  Lemma sb_safe : In SFL._gSaveBuffer lvl_safe_gvars.
  Proof. apply mem_id_In. vm_compute. reflexivity. Qed.

  Ltac ids_lfun :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg; cbn [mem_id existsb] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  Ltac lv_symX Xs HX q LO f gt gms ids :=
    refine (lfun_of_body Xs q _ f LO _ _);
    [ vm_compute; reflexivity
    | apply (lv_body Xs HX gt gms ids f); [ vm_compute; reflexivity | ids_lfun ] ].
  Ltac lv_sym q LO f gt gms ids := lv_symX level_gvars sb_all q LO f gt gms ids.

  Let LOx := linked12_LO_audio_external lp H12.
  Let LOs := linked12_LO_sound_init lp H12.
  Let LOc := linked12_LO_camera lp H12.
  Let LOi := linked12_LO_ingame_menu lp H12.
  Let LOf := linked12_LO_save lp H12.
  Let LOa := linked12_LO_area lp H12.
  Let LOl := linked12_LO_lvl lp H12.

  Definition NOGT : list (ident * ident) := nil.
  Definition NOID : list ident := nil.

  (* ---- the audio leaves ---- *)
  Lemma lf_play_sound : lfun level_gvars AX._play_sound.
  Proof. lv_sym AX.prog LOx AX.f_play_sound NOGT NOID NOID. Qed.
  Lemma lf_set_audio_muted : lfun level_gvars AX._set_audio_muted.
  Proof. lv_sym AX.prog LOx AX.f_set_audio_muted NOGT NOID NOID. Qed.
  Lemma lf_fade_pct : lfun level_gvars AX._seq_player_fade_to_percentage_of_volume.
  Proof. lv_sym AX.prog LOx AX.f_seq_player_fade_to_percentage_of_volume gt_sp NOID NOID. Qed.
  Lemma lf_fade_normal : lfun level_gvars AX._seq_player_fade_to_normal_volume.
  Proof. lv_sym AX.prog LOx AX.f_seq_player_fade_to_normal_volume gt_sp NOID NOID. Qed.
  Lemma lf_fade_target : lfun level_gvars AX._seq_player_fade_to_target_volume.
  Proof. lv_sym AX.prog LOx AX.f_seq_player_fade_to_target_volume gt_sp NOID NOID. Qed.
  Lemma lf_banks_disable : lfun level_gvars AX._sound_banks_disable.
  Proof. lv_sym AX.prog LOx AX.f_sound_banks_disable NOGT NOID NOID. Qed.
  Lemma lf_banks_enable : lfun level_gvars AX._sound_banks_enable.
  Proof. lv_sym AX.prog LOx AX.f_sound_banks_enable NOGT NOID NOID. Qed.
  Lemma lf_bbmf : lfun level_gvars AX._begin_background_music_fade.
  Proof.
    pose proof lf_fade_normal. pose proof lf_fade_target.
    lv_sym AX.prog LOx AX.f_begin_background_music_fade NOGT NOID
      [AX._seq_player_fade_to_normal_volume; AX._seq_player_fade_to_target_volume].
  Qed.
  Lemma lf_lower_volume : lfun level_gvars AX._seq_player_lower_volume.
  Proof.
    pose proof lf_bbmf. pose proof lf_fade_pct.
    lv_sym AX.prog LOx AX.f_seq_player_lower_volume NOGT NOID
      [AX._begin_background_music_fade; AX._seq_player_fade_to_percentage_of_volume].
  Qed.
  Lemma lf_lower_bgn : lfun level_gvars SI._lower_background_noise.
  Proof.
    pose proof lf_lower_volume. pose proof lf_set_audio_muted.
    lv_sym SI.prog LOs SI.f_lower_background_noise NOGT NOID
      [AX._seq_player_lower_volume; AX._set_audio_muted].
  Qed.

  (* ---- camera / dialog ---- *)
  Lemma lf_socwf : lfun level_gvars CAL._start_object_cutscene_without_focus.
  Proof. lv_sym CAL.prog LOc CAL.f_start_object_cutscene_without_focus NOGT NOID NOID. Qed.
  Lemma lf_tcd : lfun level_gvars CAL._trigger_cutscene_dialog.
  Proof.
    pose proof lf_socwf.
    lv_sym CAL.prog LOc CAL.f_trigger_cutscene_dialog NOGT NOID
      [CAL._start_object_cutscene_without_focus].
  Qed.
  Lemma lf_get_dialog_id : lfun level_gvars IML._get_dialog_id.
  Proof. lv_sym IML.prog LOi IML.f_get_dialog_id NOGT NOID NOID. Qed.

  (* ---- level_update leaves ---- *)
  Lemma lf_set_play_mode : lfun level_gvars LU._set_play_mode.
  Proof. lv_sym LU.prog LOl LU.f_set_play_mode NOGT NOID NOID. Qed.
  Lemma lf_warp_special : lfun level_gvars LU._warp_special.
  Proof. lv_sym LU.prog LOl LU.f_warp_special NOGT NOID NOID. Qed.
  Lemma lf_lst : lfun level_gvars LU._level_set_transition.
  Proof. lv_sym LU.prog LOl LU.f_level_set_transition NOGT NOID NOID. Qed.
  Lemma lf_initiate_warp : lfun level_gvars LU._initiate_warp.
  Proof. lv_sym LU.prog LOl LU.f_initiate_warp NOGT NOID NOID. Qed.
  Lemma lf_pressed_pause : lfun level_gvars LU._pressed_pause.
  Proof.
    pose proof lf_get_dialog_id.
    lv_sym LU.prog LOl LU.f_pressed_pause NOGT NOID [IML._get_dialog_id].
  Qed.

  Lemma lf_rdrs : lfun level_gvars IML._reset_dialog_render_state.
  Proof.
    pose proof lf_lst. pose proof lf_tcd.
    lv_sym IML.prog LOi IML.f_reset_dialog_render_state NOGT NOID
      [LU._level_set_transition; CAL._trigger_cutscene_dialog].
  Qed.

  (* ---- save file / area ---- *)
  Lemma lf_cisswc : lfun level_gvars SFL._check_if_should_set_warp_checkpoint.
  Proof. lv_sym SFL.prog LOf SFL.f_check_if_should_set_warp_checkpoint NOGT NOID NOID. Qed.
  Lemma lf_sfr : lfun level_gvars SFL._save_file_reload.
  Proof. lv_sym SFL.prog LOf SFL.f_save_file_reload NOGT NOID NOID. Qed.
  Lemma lf_agwn : lfun level_gvars ARL._area_get_warp_node.
  Proof. lv_sym ARL.prog LOa ARL.f_area_get_warp_node NOGT NOID NOID. Qed.

  (* ---- the level slice's own callees ---- *)
  Definition hud_gms : list ident := [LU._t'17; LU._t'20].

  Lemma lf_hud : lfun level_gvars LU._update_hud_values.
  Proof.
    pose proof lf_play_sound.
    lv_sym LU.prog LOl LU.f_update_hud_values NOGT hud_gms [AX._play_sound].
  Qed.

  Lemma lf_idw : lfun level_gvars LU._initiate_delayed_warp.
  Proof.
    pose proof lf_rdrs. pose proof lf_warp_special. pose proof lf_sfr.
    pose proof lf_banks_enable. pose proof lf_banks_disable. pose proof lf_initiate_warp.
    pose proof lf_agwn. pose proof lf_cisswc. pose proof lf_lst.
    lv_sym LU.prog LOl LU.f_initiate_delayed_warp NOGT NOID
      [IML._reset_dialog_render_state; LU._warp_special; SFL._save_file_reload;
       AX._sound_banks_enable; AX._sound_banks_disable; LU._initiate_warp;
       ARL._area_get_warp_node; SFL._check_if_should_set_warp_checkpoint;
       LU._level_set_transition].
  Qed.

  (* update_hud_values (and play_sound) also within the smaller footprint:
     no warp cell *)
  Lemma lf_play_sound_s : lfun lvl_safe_gvars AX._play_sound.
  Proof. lv_symX lvl_safe_gvars sb_safe AX.prog LOx AX.f_play_sound NOGT NOID NOID. Qed.
  Lemma lf_hud_s : lfun lvl_safe_gvars LU._update_hud_values.
  Proof.
    pose proof lf_play_sound_s.
    lv_symX lvl_safe_gvars sb_safe LU.prog LOl LU.f_update_hud_values NOGT hud_gms [AX._play_sound].
  Qed.
  Definition hud_ids : list ident := [LU._update_hud_values].
  Lemma hud_ids_lfun : forall g, mem_id g hud_ids = true -> lfun lvl_safe_gvars g.
  Proof. pose proof lf_hud_s. ids_lfun. Qed.

  (* the slice's statements call these *)
  Definition lvl_calls : list ident :=
    [LU._update_hud_values; LU._initiate_delayed_warp; LU._set_play_mode;
     LU._pressed_pause; SI._lower_background_noise].

  Lemma lvl_calls_lfun : forall g, mem_id g lvl_calls = true -> lfun level_gvars g.
  Proof.
    pose proof lf_hud. pose proof lf_idw. pose proof lf_set_play_mode.
    pose proof lf_pressed_pause. pose proof lf_lower_bgn.
    ids_lfun.
  Qed.
  (* ---- 2026-10-26: the POST tail's callees within narrower footprints
     (LevelWarp's value walk of initiate_delayed_warp and the mode
     switch): the safe ones write no warp cell, warp_special /
     set_play_mode only sCurrPlayMode of them, initiate_warp only
     sWarpDest ---- *)
  Ltac lv_safe q LO f gt gms ids := lv_symX lvl_safe_gvars sb_safe q LO f gt gms ids.

  Lemma lfs_set_audio_muted : lfun lvl_safe_gvars AX._set_audio_muted.
  Proof. lv_safe AX.prog LOx AX.f_set_audio_muted NOGT NOID NOID. Qed.
  Lemma lfs_fade_pct : lfun lvl_safe_gvars AX._seq_player_fade_to_percentage_of_volume.
  Proof. lv_safe AX.prog LOx AX.f_seq_player_fade_to_percentage_of_volume gt_sp NOID NOID. Qed.
  Lemma lfs_fade_normal : lfun lvl_safe_gvars AX._seq_player_fade_to_normal_volume.
  Proof. lv_safe AX.prog LOx AX.f_seq_player_fade_to_normal_volume gt_sp NOID NOID. Qed.
  Lemma lfs_fade_target : lfun lvl_safe_gvars AX._seq_player_fade_to_target_volume.
  Proof. lv_safe AX.prog LOx AX.f_seq_player_fade_to_target_volume gt_sp NOID NOID. Qed.
  Lemma lfs_banks_enable : lfun lvl_safe_gvars AX._sound_banks_enable.
  Proof. lv_safe AX.prog LOx AX.f_sound_banks_enable NOGT NOID NOID. Qed.
  Lemma lfs_bbmf : lfun lvl_safe_gvars AX._begin_background_music_fade.
  Proof.
    pose proof lfs_fade_normal. pose proof lfs_fade_target.
    lv_safe AX.prog LOx AX.f_begin_background_music_fade NOGT NOID
      [AX._seq_player_fade_to_normal_volume; AX._seq_player_fade_to_target_volume].
  Qed.
  Lemma lfs_lower_volume : lfun lvl_safe_gvars AX._seq_player_lower_volume.
  Proof.
    pose proof lfs_bbmf. pose proof lfs_fade_pct.
    lv_safe AX.prog LOx AX.f_seq_player_lower_volume NOGT NOID
      [AX._begin_background_music_fade; AX._seq_player_fade_to_percentage_of_volume].
  Qed.
  Lemma lfs_lower_bgn : lfun lvl_safe_gvars SI._lower_background_noise.
  Proof.
    pose proof lfs_lower_volume. pose proof lfs_set_audio_muted.
    lv_safe SI.prog LOs SI.f_lower_background_noise NOGT NOID
      [AX._seq_player_lower_volume; AX._set_audio_muted].
  Qed.
  Lemma lfs_socwf : lfun lvl_safe_gvars CAL._start_object_cutscene_without_focus.
  Proof. lv_safe CAL.prog LOc CAL.f_start_object_cutscene_without_focus NOGT NOID NOID. Qed.
  Lemma lfs_tcd : lfun lvl_safe_gvars CAL._trigger_cutscene_dialog.
  Proof.
    pose proof lfs_socwf.
    lv_safe CAL.prog LOc CAL.f_trigger_cutscene_dialog NOGT NOID
      [CAL._start_object_cutscene_without_focus].
  Qed.
  Lemma lfs_get_dialog_id : lfun lvl_safe_gvars IML._get_dialog_id.
  Proof. lv_safe IML.prog LOi IML.f_get_dialog_id NOGT NOID NOID. Qed.
  Lemma lfs_lst : lfun lvl_safe_gvars LU._level_set_transition.
  Proof. lv_safe LU.prog LOl LU.f_level_set_transition NOGT NOID NOID. Qed.
  Lemma lfs_pressed_pause : lfun lvl_safe_gvars LU._pressed_pause.
  Proof.
    pose proof lfs_get_dialog_id.
    lv_safe LU.prog LOl LU.f_pressed_pause NOGT NOID [IML._get_dialog_id].
  Qed.
  Lemma lfs_rdrs : lfun lvl_safe_gvars IML._reset_dialog_render_state.
  Proof.
    pose proof lfs_lst. pose proof lfs_tcd.
    lv_safe IML.prog LOi IML.f_reset_dialog_render_state NOGT NOID
      [LU._level_set_transition; CAL._trigger_cutscene_dialog].
  Qed.
  Lemma lfs_cisswc : lfun lvl_safe_gvars SFL._check_if_should_set_warp_checkpoint.
  Proof. lv_safe SFL.prog LOf SFL.f_check_if_should_set_warp_checkpoint NOGT NOID NOID. Qed.
  Lemma lfs_sfr : lfun lvl_safe_gvars SFL._save_file_reload.
  Proof. lv_safe SFL.prog LOf SFL.f_save_file_reload NOGT NOID NOID. Qed.
  Lemma lfs_agwn : lfun lvl_safe_gvars ARL._area_get_warp_node.
  Proof. lv_safe ARL.prog LOa ARL.f_area_get_warp_node NOGT NOID NOID. Qed.

  Lemma sb_pm : In SFL._gSaveBuffer PMX.
  Proof. right. exact sb_safe. Qed.
  Lemma sb_wd : In SFL._gSaveBuffer WDX.
  Proof. right. exact sb_safe. Qed.

  Lemma lfp_set_play_mode : lfun PMX LU._set_play_mode.
  Proof. lv_symX PMX sb_pm LU.prog LOl LU.f_set_play_mode NOGT NOID NOID. Qed.
  Lemma lfp_warp_special : lfun PMX LU._warp_special.
  Proof. lv_symX PMX sb_pm LU.prog LOl LU.f_warp_special NOGT NOID NOID. Qed.
  Lemma lfw_initiate_warp : lfun WDX LU._initiate_warp.
  Proof. lv_symX WDX sb_wd LU.prog LOl LU.f_initiate_warp NOGT NOID NOID. Qed.

  Definition safe_ids : list ident :=
    [IML._reset_dialog_render_state; SFL._save_file_reload; AX._sound_banks_enable;
     ARL._area_get_warp_node; SFL._check_if_should_set_warp_checkpoint;
     LU._level_set_transition; LU._pressed_pause; SI._lower_background_noise].
  Definition pm_ids : list ident := [LU._warp_special; LU._set_play_mode].
  Definition wd_ids : list ident := [LU._initiate_warp].

  Lemma safe_ids_lfun : forall g, mem_id g safe_ids = true -> lfun lvl_safe_gvars g.
  Proof.
    pose proof lfs_rdrs. pose proof lfs_sfr. pose proof lfs_banks_enable. pose proof lfs_agwn.
    pose proof lfs_cisswc. pose proof lfs_lst. pose proof lfs_pressed_pause. pose proof lfs_lower_bgn.
    ids_lfun.
  Qed.
  Lemma pm_ids_lfun : forall g, mem_id g pm_ids = true -> lfun PMX g.
  Proof. pose proof lfp_set_play_mode. pose proof lfp_warp_special. ids_lfun. Qed.
  Lemma wd_ids_lfun : forall g, mem_id g wd_ids = true -> lfun WDX g.
  Proof. pose proof lfw_initiate_warp. ids_lfun. Qed.
End LW.

(* ---------------------------------------------------------------------- *)
(* 4. Closedness: a walk whose stores put non-pointers into globals and   *)
(*    whose calls pass constants keeps memory closed (ClightClosed).       *)
(* ---------------------------------------------------------------------- *)

Definition is_const (a : expr) : bool := match a with Econst_int _ _ => true | _ => false end.

Definition cl_store_ok (lv rhs : expr) : bool :=
  match groot_l lv with
  | Some _ => MtxfBody.is_byval (typeof lv) && (nonptr_scalar (typeof lv) || au_np_rhs rhs)
  | None => false
  end.

Definition cl_call_ok (o : option ident) (a : expr) (al : list expr) : bool :=
  match a with Evar _ (Tfunction _ _ _) => forallb is_const al | _ => false end.

Definition cl_chk (s : statement) : bool := lw_chk (fun _ _ => true) cl_store_ok cl_call_ok s.

Section CLW.
  Variable ge : genv.

  Definition cl_rel (m0 m : mem) : Prop :=
    forall g, closed_by g m0 -> syms_mapped ge g ->
      exists g', inject_incr g g' /\ closed_by g' m /\ syms_mapped ge g'.

  Lemma cl_refl : forall m, cl_rel m m.
  Proof. intros m g Hc Hs. exists g. split; [ apply incr_refl | auto ]. Qed.

  Lemma cl_trans : forall m1 m2 m3, cl_rel m1 m2 -> cl_rel m2 m3 -> cl_rel m1 m3.
  Proof.
    intros m1 m2 m3 A B g Hc Hs.
    destruct (A g Hc Hs) as (g1 & I1 & Hc1 & Hs1).
    destruct (B g1 Hc1 Hs1) as (g2 & I2 & Hc2 & Hs2).
    exists g2. split; [ exact (incr_trans _ _ _ I1 I2) | auto ].
  Qed.

  Lemma vok_nonptr : forall g v, (forall b o, v <> Vptr b o) -> vok g v.
  Proof. intros g v H. destruct v; try constructor. exfalso. exact (H _ _ eq_refl). Qed.

  Lemma consts_vok : forall e le m g al tys vs, forallb is_const al = true ->
    eval_exprlist ge e le m al tys vs -> Forall (vok g) vs.
  Proof.
    intros e le m g al. induction al as [| a al IH]; intros tys vs Hc Hev; inv Hev; [ constructor |].
    cbn [forallb] in Hc. apply andb_prop in Hc as [Ha Hc].
    constructor; [ | exact (IH _ _ Hc ltac:(eassumption)) ].
    destruct a; try discriminate Ha.
    match goal with He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in He; subst end.
    apply vok_nonptr. eapply sem_cast_vint_not_vptr; eassumption.
  Qed.

  Lemma cl_stmt : forall s, cl_chk s = true ->
    forall le m t le' m' out,
      exec_stmt function_entry2 ge empty_env le m s t le' m' out -> cl_rel m m'.
  Proof.
    intros s Hchk le m t le' m' out Hx.
    refine (proj1 (lw_walk ge empty_env (cl_rel m) (fun _ => True) (fun _ _ => true)
              cl_store_ok cl_call_ok _ _ _ empty_env le m s t le' m' out Hx eq_refl Hchk I (cl_refl m))).
    - intros; exact I.
    - intros lv rhs le0 mm t0 le1 mm' out0 Hok _ Hx0 Hq.
      apply (cl_trans m mm mm' Hq). intros g Hc Hs.
      unfold cl_store_ok in Hok.
      destruct (groot_l lv) as [gid|] eqn:Hr; [ | discriminate Hok ].
      apply andb_prop in Hok as [Hbv Hval].
      apply assign_inv in Hx0. destruct Hx0 as (loc & ofs & bf & v2 & v & Hl & Hr2 & Hca & Ha & _ & _).
      pose proof (groot_l_blk _ _ _ _ _ _ _ _ Hr Hl) as Hsy.
      assert (Hnp : forall bb oo, v <> Vptr bb oo).
      { apply orb_true_iff in Hval as [Hsc | Hbo].
        - exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hsc Hca).
        - exact (ActWriterSurface.sem_cast_nonptr_pres _ _ _ _ _ Hca (au_np_rhs_eval _ _ _ _ _ _ Hbo Hr2)). }
      exists g. split; [ apply incr_refl | split; [ | exact Hs ] ].
      refine (assign_loc_closed ge g mm _ loc ofs bf v mm' Hc _ (vok_nonptr g v Hnp) Ha).
      exact (closed_mapped_flat g mm loc Hc (Hs _ _ Hsy)).
    - intros optid a al le0 mm t0 le1 mm' out0 Hok _ Hx0 Hq. split; [ | exact I ].
      apply (cl_trans m mm mm' Hq). intros g Hc Hs.
      unfold cl_call_ok in Hok.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
      apply call_inv in Hx0.
      destruct Hx0 as (tyargs & tyres & cc & vf & vargs & fd & vres & _ & _ & Hel & _ & _ & Hfc & _ & _).
      destruct (funcall_closed ge mm fd vargs t0 mm' vres g Hfc Hc Hs (consts_vok _ _ _ g _ _ _ Hok Hel))
        as (g' & I & Hc' & Hs' & _).
      exists g'. auto.
  Qed.
End CLW.
