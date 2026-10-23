(* ======================================================================= *)
(* ProRows (GOAL 2): two of HeightFrame's frame rows, PROVED from the real *)
(* generated bodies (2026-10-23).                                          *)
(*                                                                         *)
(*  - FrameSplit.seg_any_rows: the one live non-gMarioState call of        *)
(*    execute_mario_action, play_infinite_stairs_music() (sound_init.c,    *)
(*    linked).  In WMotR (FfWorld.lvl_w: gCurrLevelNum = LEVEL_WMOTR and  *)
(*    sPlayingInfiniteStairs = FALSE) its body only reads: shouldPlay     *)
(*    stays FALSE (the level is not the castle, 6), and so does the       *)
(*    playing flag, so neither audio call runs and memory is unchanged.   *)
(*  - AirSplit.air_pro_rows: the dispatchers' prologue calls.              *)
(*      check_common_automatic_cancels: pos[1] >= -11000 > waterLevel-100 *)
(*        (FfWorld.inputs_ok: waterLevel = -11000), so no water plunge;    *)
(*        memory unchanged.                                                *)
(*      check_common_airborne_cancels: the same plunge test, no            *)
(*        INPUT_SQUISHED (inputs_ok), the floor is a WMotR surface (no     *)
(*        SURFACE_VERTICAL_WIND, 56), then quicksandDepth = 0              *)
(*        (AutoSplit's store lemmas).                                      *)
(*      play_far_fall_sound: a walk (AudioBodies.lw_body_frame) whose     *)
(*        footprint is the real play_sound's (sSoundRequests and its      *)
(*        count, SndXc.ps_walk) and m->flags; the frame world, the cells   *)
(*        and the floor refresh live elsewhere (hole_fworld).              *)
(* Both rows were FALSE as first stated (phantom forall; FfWorld's FOUND   *)
(* notes on lvl_w and inputs_ok).                                         *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations Reals Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne mario_actions_automatic
  audio_external sound_init level_update.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface AirborneSurface.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FloorExec FfWorld AirSplit AutoSplit
  PoleFloat FloorBound SndXc.
From SM64.Proofs.WMotRRequiresA Require AnimWorld AnimKeep.
From SM64.Proofs Require Import MarioModel.AudioBodies MarioModel.LinkedTwelve.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
Import ListNotations.

Module AIR := mario_actions_airborne.
Module AUT := mario_actions_automatic.
Module AX := audio_external.
Module SI := sound_init.

(* ---------------------------------------------------------------------- *)
(* 1. Small inversions and the binary operations the bodies use.          *)
(* ---------------------------------------------------------------------- *)

Section X.
  Variable ge : genv.
  Variable e : env.

  Lemma x_set : forall le m x a t le' m' out,
    exec_stmt function_entry2 ge e le m (Sset x a) t le' m' out ->
    exists v, eval_expr ge e le m a v /\ le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
  Proof. intros. inv H. eauto. Qed.

  Lemma x_if : forall le m c s1 s2 t le' m' out,
    exec_stmt function_entry2 ge e le m (Sifthenelse c s1 s2) t le' m' out ->
    exists v b, eval_expr ge e le m c v /\ bool_val v (typeof c) m = Some b /\
                exec_stmt function_entry2 ge e le m (if b then s1 else s2) t le' m' out.
  Proof. intros. inv H. eauto. Qed.

  Lemma x_skip : forall le m t le' m' out,
    exec_stmt function_entry2 ge e le m Sskip t le' m' out -> le' = le /\ m' = m /\ out = Out_normal.
  Proof. intros. inv H. auto. Qed.

  Lemma x_ret : forall le m a t le' m' out,
    exec_stmt function_entry2 ge e le m (Sreturn a) t le' m' out -> m' = m.
  Proof. intros. inv H; reflexivity. Qed.

  Lemma ev_cast : forall le m a ty v,
    eval_expr ge e le m (Ecast a ty) v ->
    exists v1, eval_expr ge e le m a v1 /\ sem_cast v1 (typeof a) ty m = Some v.
  Proof.
    intros le m a ty v H. inv H; [eauto |].
    match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end.
  Qed.

  (* a no-locals function's call is its body's execution *)
  Lemma fc_entry : forall m f vargs t m' vres,
    fn_vars f = nil ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
    exists le le' t' out, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le
      /\ exec_stmt function_entry2 ge empty_env le m (fn_body f) t' le' m' out.
  Proof.
    intros m f vargs t m' vres Hv H. inv H.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hv in Ha; inv Ha end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      change (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hf;
      cbn [Mem.free_list] in Hf; injection Hf as <- end.
    do 4 eexists. split; eassumption.
  Qed.

  Lemma ev_fun : forall le m f tyl rty cc vf,
    eval_expr ge empty_env le m (Evar f (Tfunction tyl rty cc)) vf ->
    exists b, Genv.find_symbol ge f = Some b /\ vf = Vptr b Ptrofs.zero.
  Proof.
    intros le m f tyl rty cc vf H. inv H;
      match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end.
    - match goal with He : empty_env ! _ = Some _ |- _ =>
        rewrite PTree.gempty in He; discriminate He end.
    - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
        match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; try discriminate Ha end.
      eauto.
  Qed.

  (* a global read *)
  Lemma ev_gvar : forall le m id ty ch v,
    access_mode ty = By_value ch ->
    eval_expr ge empty_env le m (Evar id ty) v ->
    exists b, Genv.find_symbol ge id = Some b /\ Mem.load ch m b 0 = Some v.
  Proof.
    intros le m id ty ch v Ham H.
    apply eval_expr_Evar_load in H as (loc & ofs & bf & L & D).
    inv L; [rewrite PTree.gempty in *; discriminate |].
    exists loc. split; [assumption |].
    inv D; try congruence.
    match goal with Hm : access_mode _ = By_value ?c, Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
      rewrite Ham in Hm; injection Hm as <-; exact Hl end.
  Qed.
End X.

Lemma bv_int : forall i m b, bool_val (Vint i) tint m = Some b -> b = negb (Int.eq i Int.zero).
Proof. intros i m b H. cbn in H. injection H as <-. reflexivity. Qed.

Lemma bv_of_bool : forall c m b, bool_val (Val.of_bool c) tint m = Some b -> b = c.
Proof. intros [|] m b H; cbn in H; injection H as <-; reflexivity. Qed.

Lemma sb_eq_si : forall (ce : composite_env) a b m,
  sem_binary_operation ce Oeq (Vint a) tshort (Vint b) tint m = Some (Val.of_bool (Int.eq a b)).
Proof. reflexivity. Qed.

Lemma sb_sub_si : forall (ce : composite_env) a b m,
  sem_binary_operation ce Osub (Vint a) tshort (Vint b) tint m = Some (Vint (Int.sub a b)).
Proof. reflexivity. Qed.

Lemma sb_and_usi : forall (ce : composite_env) a b m,
  sem_binary_operation ce Oand (Vint a) tushort (Vint b) tint m = Some (Vint (Int.and a b)).
Proof. reflexivity. Qed.

Lemma sb_xor_uc : forall (ce : composite_env) a b m,
  sem_binary_operation ce Oxor (Vint a) tuchar (Vint b) tuchar m = Some (Vint (Int.xor a b)).
Proof. reflexivity. Qed.

Lemma sb_lt_fi : forall (ce : composite_env) y w m,
  sem_binary_operation ce Olt (Vsingle y) tfloat (Vint w) tint m
  = Some (Val.of_bool (Float32.cmp Clt y (Float32.of_int w))).
Proof. reflexivity. Qed.

Lemma sb_add_pf : forall (ce : composite_env) b o i m,
  sem_binary_operation ce Oadd (Vptr b o) (tarray tfloat 3) (Vint i) tint m
  = Some (Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 4) (Ptrofs.of_ints i)))).
Proof. reflexivity. Qed.

Lemma sc_int_uchar : forall i m, sem_cast (Vint i) tint tuchar m = Some (Vint (Int.zero_ext 8 i)).
Proof. reflexivity. Qed.

(* the water-plunge test: pos[1] >= -11000 is not below waterLevel - 100 *)
Lemma plunge_false : forall y, F32 y = true -> (-11000 <= R2 y)%R ->
  Float32.cmp Clt y (Float32.of_int (Int.sub (Int.repr (-11000)) (Int.repr 100))) = false.
Proof.
  intros y Fy Hy.
  destruct (Float32.cmp Clt _ _) eqn:E; [| reflexivity].
  assert (Hs : Int.signed (Int.sub (Int.repr (-11000)) (Int.repr 100)) = (-11100)%Z)
    by (vm_compute; reflexivity).
  destruct (of_int_val (Int.sub (Int.repr (-11000)) (Int.repr 100))) as (R & F).
  { rewrite Hs. rewrite Rabs_left; lra. }
  pose proof (cmp_lt_true _ _ Fy F E) as L. rewrite R, Hs in L. lra.
Qed.

Lemma fo_pos : FrameSplit.mario_fo mario._MarioState mario._pos = Some (60, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma fo_wl : FrameSplit.mario_fo mario._MarioState mario._waterLevel = Some (WL_OFF, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma fo_input : FrameSplit.mario_fo mario._MarioState mario._input = Some (2, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma fo_floor : FrameSplit.mario_fo mario._MarioState mario._floor = Some (104, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma fo_flags : FrameSplit.mario_fo mario._MarioState mario._flags = Some (4, Full).
Proof. vm_compute. reflexivity. Qed.
Lemma fo_stype : FrameSplit.mario_fo mario._Surface mario._type = Some (0, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_pism : (prog_defmap SI.prog) ! mario._play_infinite_stairs_music
  = Some (Gfun (Internal SI.f_play_infinite_stairs_music)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ccac : (prog_defmap AUT.prog) ! AUT._check_common_automatic_cancels
  = Some (Gfun (Internal AUT.f_check_common_automatic_cancels)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ccairc : (prog_defmap AIR.prog) ! AIR._check_common_airborne_cancels
  = Some (Gfun (Internal AIR.f_check_common_airborne_cancels)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_pffs : (prog_defmap AIR.prog) ! AIR._play_far_fall_sound
  = Some (Gfun (Internal AIR.f_play_far_fall_sound)).
Proof. vm_compute. reflexivity. Qed.

Ltac le_simp :=
  repeat first [ rewrite PTree.gss
               | rewrite PTree.gso by (apply Pos.eqb_neq; vm_compute; reflexivity) ].
Ltac le_simp_in H :=
  repeat first [ rewrite PTree.gss in H
               | rewrite PTree.gso in H by (apply Pos.eqb_neq; vm_compute; reflexivity) ].

(* the cells a write at Mario's flags (bytes 4..7) misses *)
Ltac hside := unfold OFS_ACTION, OFS_ASTATE, OFS_ATIMER, OFS_POSY, OFS_VELY, OFS_FLOORH,
  OFS_MARIOOBJ, FFW_OBJ, FFW_ANIM, FFW_FLOOR, FFW_AREA, FFW_CTL, FFW_WALL, FFW_CEIL, FFW_PCS, WALL_OFF,
  CEIL_OFF, FLOOR_OFF, HELD_OFF, RIDDEN_OFF, MARIOOBJ_OFF, USED_OFF, WL_OFF, QSD_OFF;
  try change (size_chunk Mptr) with 4;
  simpl; lia.

Lemma load_invalid : forall m ch b z, ~ Mem.valid_block m b -> Mem.load ch m b z = None.
Proof.
  intros m ch b z V. destruct (Mem.load ch m b z) eqn:E; [| reflexivity].
  exfalso. apply V. apply Mem.load_valid_access in E. destruct E as (Hr & _).
  eapply Mem.perm_valid_block. apply (Hr z). destruct ch; cbn; lia.
Qed.

(* play_far_fall_sound's walk: its one store is m->flags, its one call play_sound *)
Definition pffs_store_ok (lv rhs : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) (Tstruct sid (mk_attr false None))) f (Tint I32 Unsigned _) =>
      Pos.eqb x AIR._m && Pos.eqb sid mario._MarioState && Pos.eqb f AIR._flags
  | _ => false
  end.

Definition pffs_call_ok (optid : option ident) (a : expr) (al : list expr) : bool :=
  match optid, a with
  | None, Evar f (Tfunction _ _ _) => Pos.eqb f AIR._play_sound
  | _, _ => false
  end.

Lemma pffs_chk : lw_chk (fun id _ => negb (Pos.eqb id AIR._m)) pffs_store_ok pffs_call_ok
                   (fn_body AIR.f_play_far_fall_sound) = true.
Proof. vm_compute. reflexivity. Qed.

Section PR.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Variable MWF : mem -> Prop.

  Notation ge := (lp_ge lp).
  Notation MC := (MoveChain wmotr_floor wmotr_pole wmotr_cannon).

  Let LO_mario := linked12_LO_mario lp H12.

  (* ==================================================================== *)
  (* 2. play_infinite_stairs_music: memory unchanged in WMotR.            *)
  (* ==================================================================== *)

  Lemma pism_mem : forall m vargs t m' vr,
    lvl_w ge m ->
    eval_funcall function_entry2 ge m (Internal SI.f_play_infinite_stairs_music) vargs t m' vr ->
    m' = m.
  Proof.
    intros m vargs t m' vr (LV1 & LV2) Hev.
    destruct (fc_entry ge m SI.f_play_infinite_stairs_music vargs t m' vr eq_refl Hev) as (le0 & le' & t' & out & _ & H).
    unfold SI.f_play_infinite_stairs_music in H. cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & Hn)].
    2: { apply x_set in H1 as (_ & _ & _ & _ & ->). congruence. }
    apply x_set in H1 as (v1 & E1 & -> & -> & _).
    apply ev_cast in E1 as (v0 & E0 & Hc).
    apply eval_expr_Econst_int_val in E0. subst v0.
    cbn [typeof] in Hc. rewrite sc_int_uchar in Hc. injection Hc as <-.
    apply seq_inv in H2 as [(t3 & le2 & m3 & t4 & H3 & H4) | (t3 & H3 & Hn)].
    2: { exact (fs_pure_mem _ _ _ _ _ _ _ _ _ H3 eq_refl). }
    (* the middle part: shouldPlay stays 0 *)
    pose proof (fs_pure_mem _ _ _ _ _ _ _ _ _ H3 eq_refl) as ->.
    apply seq_inv in H3 as [(t5 & le3 & m5 & t6 & H5 & H6) | (t5 & H5 & Hn)]; [| congruence].
    pose proof (fs_pure_mem _ _ _ _ _ _ _ _ _ H5 eq_refl) as ->.
    apply seq_inv in H5 as [(t7 & le4 & m7 & t8 & H7 & H8) | (t7 & H7 & Hn)]; [| congruence].
    pose proof (fs_pure_mem _ _ _ _ _ _ _ _ _ H7 eq_refl) as ->.
    (* t'14 = gCurrLevelNum = 31; the test with the castle (6) is false *)
    apply (seq_set_inv lp) in H7 as (v14 & E14 & H9).
    apply (ev_gvar _ _ _ _ _ Mint16signed) in E14 as (bl & Sl & Ll); [| reflexivity].
    rewrite (LV1 bl Sl) in Ll. injection Ll as <-.
    apply x_if in H9 as (vc & bc & Ec & Bc & H9).
    apply eval_expr_Ebinop_inv in Ec as (va & vb & Ea & Eb & Sb).
    apply eval_expr_Etempvar_val in Ea. le_simp_in Ea. injection Ea as <-.
    apply eval_expr_Econst_int_val in Eb. subst vb.
    cbn [typeof] in Sb, Bc. rewrite sb_eq_si in Sb. injection Sb as <-.
    apply bv_of_bool in Bc. subst bc.
    change (Int.eq (Int.repr LEVEL_WMOTR) (Int.repr 6)) with false in H9.
    cbv iota in H9.
    apply x_set in H9 as (v2 & E2 & -> & _ & _).
    apply eval_expr_Econst_int_val in E2. subst v2.
    (* t'2 = 0, so t'3 = 0 *)
    apply x_if in H8 as (vc & bc & Ec & Bc & H8).
    apply eval_expr_Etempvar_val in Ec. le_simp_in Ec. injection Ec as <-.
    cbn [typeof] in Bc. apply bv_int in Bc. subst bc.
    change (negb (Int.eq (Int.repr 0) Int.zero)) with false in H8. cbv iota in H8.
    apply x_set in H8 as (v3 & E3 & -> & _ & _).
    apply eval_expr_Econst_int_val in E3. subst v3.
    (* t'3 = 0: the room / height test is skipped *)
    apply x_if in H6 as (vc & bc & Ec & Bc & H6).
    apply eval_expr_Etempvar_val in Ec. le_simp_in Ec. injection Ec as <-.
    cbn [typeof] in Bc. apply bv_int in Bc. subst bc.
    change (negb (Int.eq (Int.repr 0) Int.zero)) with false in H6. cbv iota in H6.
    apply x_skip in H6 as (-> & _ & _).
    (* t'4 = sPlayingInfiniteStairs = 0; 0 ^ 0 is false *)
    apply (seq_set_inv lp) in H4 as (v4 & E4 & H10).
    apply (ev_gvar _ _ _ _ _ Mint8unsigned) in E4 as (bp & Sp & Lp); [| reflexivity].
    rewrite (LV2 bp Sp) in Lp. injection Lp as <-.
    apply x_if in H10 as (vc & bc & Ec & Bc & H10).
    apply eval_expr_Ebinop_inv in Ec as (va & vb & Ea & Eb & Sb).
    apply eval_expr_Etempvar_val in Ea. le_simp_in Ea. injection Ea as <-.
    apply eval_expr_Etempvar_val in Eb. le_simp_in Eb. injection Eb as <-.
    cbn [typeof] in Sb, Bc. rewrite sb_xor_uc in Sb. injection Sb as <-.
    apply bv_int in Bc. subst bc.
    change (negb (Int.eq (Int.xor Int.zero (Int.zero_ext 8 (Int.repr 0))) Int.zero)) with false in H10.
    cbv iota in H10.
    apply x_skip in H10 as (_ & -> & _). reflexivity.
  Qed.

  Theorem seg_any_rows_proved : seg_any_rows lp bm MWF.
  Proof.
    intros f fty al fd vargs Hin Hr.
    assert (Hf : In f [mario._play_infinite_stairs_music]).
    { (* explicit instance: unifying against the computed ema_live hangs *)
      pose proof (proj2 (in_flat_map (fun o => match o with OAny f _ _ => [f] | _ => [] end)
                           ema_live f)) as I.
      rewrite ema_live_anys in I. apply I. clear I.
      exists (OAny f fty al). split; [exact Hin | left; reflexivity]. }
    destruct Hf as [<- | []].
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_sound_init lp H12) dm_pism Hr) as ->.
    intros m t m' vr c Hok Hw _ Hok' Hc Hb Hev.
    pose proof Hw as (_ & _ & _ & _ & _ & _ & _ & _ & Hl).
    rewrite (pism_mem m vargs t m' vr Hl Hev).
    split; [exact Hw |]. exists c. split; [exact Hc | apply rt_refl].
  Qed.

  (* ==================================================================== *)
  (* 3. Reading Mario's fields through the parameter.                     *)
  (* ==================================================================== *)

  Lemma ev_fld : forall x le m v f ty ch d v',
    le ! x = Some v -> marg_ok bm [v] ->
    FrameSplit.mario_fo mario._MarioState f = Some (d, Full) -> 0 <= d < 1024 ->
    access_mode ty = By_value ch ->
    eval_expr ge empty_env le m (Efield (Ederef (Etempvar x tyMSp) (Tstruct mario._MarioState noattr)) f ty) v' ->
    v = Vptr bm Ptrofs.zero /\ Mem.load ch m bm d = Some v'.
  Proof.
    intros x le m v f ty ch d v' Hle Hmarg Hfo Hd Ham H.
    apply eval_expr_Efield_load in H as (loc & ofs & bf & L & D).
    destruct (lv_field lp LO_mario _ _ _ _ _ _ _ _ _ _ L eq_refl Hfo) as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst bf.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->]. split; [reflexivity |].
    inv D; try congruence.
    match goal with Hm : access_mode _ = By_value ?c, Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
      rewrite Ham in Hm; injection Hm as <-; cbn [fst Mem.loadv] in Hl;
      rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in Hl
        by (change Ptrofs.max_unsigned with 4294967295; lia);
      exact Hl end.
  Qed.

  Lemma ev_pos1 : forall x le m v v',
    le ! x = Some v -> marg_ok bm [v] ->
    eval_expr ge empty_env le m
      (Ederef (Ebinop Oadd (Efield (Ederef (Etempvar x tyMSp) (Tstruct mario._MarioState noattr))
                                   mario._pos (tarray tfloat 3))
                      (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat) v' ->
    v = Vptr bm Ptrofs.zero /\ Mem.load Mfloat32 m bm OFS_POSY = Some v'.
  Proof.
    intros x le m v v' Hle Hmarg H.
    apply eval_expr_Ederef_load in H as (loc & ofs & bf & L & D).
    inv L.
    match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => rename Hb into E1 end.
    apply eval_expr_Ebinop_inv in E1 as (v1 & v2 & E2 & E3 & Sb).
    apply eval_expr_Econst_int_val in E3. subst v2.
    apply eval_expr_Efield_load in E2 as (loc2 & ofs2 & bf2 & L2 & D2).
    destruct (lv_field lp LO_mario _ _ _ _ _ _ _ _ _ _ L2 eq_refl fo_pos) as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst bf2.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->]. split; [reflexivity |].
    inv D2; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    cbn [typeof] in Sb. rewrite sb_add_pf in Sb. injection Sb as <- <-.
    inv D; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    match goal with Hl : Mem.loadv _ _ _ = Some _ |- _ => cbn [Mem.loadv] in Hl; exact Hl end.
  Qed.

  Lemma ev_stype : forall x le m sb so v',
    le ! x = Some (Vptr sb so) ->
    eval_expr ge empty_env le m
      (Efield (Ederef (Etempvar x (tptr (Tstruct mario._Surface noattr))) (Tstruct mario._Surface noattr))
              mario._type tshort) v' ->
    Mem.load Mint16signed m sb (Ptrofs.unsigned so) = Some v'.
  Proof.
    intros x le m sb so v' Hle H.
    apply eval_expr_Efield_load in H as (loc & ofs & bf & L & D).
    destruct (lv_field lp LO_mario _ _ _ _ _ _ _ _ _ _ L eq_refl fo_stype) as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst bf.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as -> ->.
    inv D; match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as <- end.
    match goal with Hl : Mem.loadv _ _ _ = Some _ |- _ =>
      cbn [fst Mem.loadv] in Hl; rewrite Ptrofs.add_zero in Hl; exact Hl end.
  Qed.

  (* the water plunge test of both cancels: pos[1] vs waterLevel - 100 *)
  Lemma plunge_skip : forall x ta tb s le m t le' m' out v c,
    le ! x = Some v -> marg_ok bm [v] ->
    Mem.load Mint16signed m bm WL_OFF = Some (Vint (Int.repr (-11000))) ->
    read_cells bm m c -> budget_ok c ->
    exec_stmt function_entry2 ge empty_env le m
      (Ssequence
        (Sset ta (Ederef (Ebinop Oadd (Efield (Ederef (Etempvar x tyMSp) (Tstruct mario._MarioState noattr))
                                              mario._pos (tarray tfloat 3))
                                 (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset tb (Efield (Ederef (Etempvar x tyMSp) (Tstruct mario._MarioState noattr))
                           mario._waterLevel tshort))
          (Sifthenelse (Ebinop Olt (Etempvar ta tfloat)
                          (Ebinop Osub (Etempvar tb tshort) (Econst_int (Int.repr 100) tint) tint) tint)
             s Sskip)))
      t le' m' out ->
    Pos.eqb x ta = false -> Pos.eqb x tb = false -> Pos.eqb ta tb = false ->
    m' = m /\ out = Out_normal /\ v = Vptr bm Ptrofs.zero /\ le' ! x = Some v.
  Proof.
    intros x ta tb s le m t le' m' out v c Hle Hmarg WL Hc Hb H Hxa Hxb Hab.
    apply Pos.eqb_neq in Hxa, Hxb, Hab.
    apply (seq_set_inv lp) in H as (vy & Ey & H).
    destruct (ev_pos1 _ _ _ _ _ Hle Hmarg Ey) as (-> & Ly).
    pose proof Hc as (_ & _ & _ & Hy & _). rewrite Hy in Ly. injection Ly as <-.
    apply (seq_set_inv lp) in H as (vw & Ew & H).
    assert (Hle1 : (PTree.set ta (Vsingle (c_posy c)) le) ! x = Some (Vptr bm Ptrofs.zero))
      by (rewrite PTree.gso by congruence; exact Hle).
    destruct (ev_fld x _ m _ mario._waterLevel tshort Mint16signed WL_OFF vw Hle1 Hmarg fo_wl
                ltac:(unfold WL_OFF; lia) eq_refl Ew) as (_ & Lw).
    rewrite WL in Lw. injection Lw as <-.
    apply x_if in H as (vc & bc & Ec & Bc & H).
    apply eval_expr_Ebinop_inv in Ec as (va & vb & Ea & Eb & Sb).
    apply eval_expr_Etempvar_val in Ea. rewrite PTree.gso in Ea by congruence.
    rewrite PTree.gss in Ea. injection Ea as <-.
    apply eval_expr_Ebinop_inv in Eb as (vd & ve & Ed & Ee & Sd).
    apply eval_expr_Etempvar_val in Ed. rewrite PTree.gss in Ed. injection Ed as <-.
    apply eval_expr_Econst_int_val in Ee. subst ve.
    cbn [typeof] in Sd. rewrite sb_sub_si in Sd. injection Sd as <-.
    cbn [typeof] in Sb, Bc. rewrite sb_lt_fi in Sb. injection Sb as <-.
    apply bv_of_bool in Bc. subst bc.
    destruct Hb as ((Fy & _ & _ & Hy0 & _) & _).
    rewrite (plunge_false _ Fy Hy0) in H.
    apply x_skip in H as (-> & -> & ->).
    split; [reflexivity |]. split; [reflexivity |]. split; [reflexivity |].
    rewrite !PTree.gso by congruence. exact Hle.
  Qed.

  (* ==================================================================== *)
  (* 4. check_common_automatic_cancels: memory unchanged.                 *)
  (* ==================================================================== *)

  Lemma ccac_row : forall v,
    seg_okR lp bm MWF (Internal AUT.f_check_common_automatic_cancels) [v]
      (fun m => marg_ok bm [v] /\ fresh_at bm m) (fun m' _ => fresh_at bm m').
  Proof.
    intros v m t m' vr c Hok Hw (Hmarg & Hfr) Hok' Hc Hb Hev.
    destruct (fc_entry ge m AUT.f_check_common_automatic_cancels [v] t m' vr eq_refl Hev) as (le0 & le' & t' & out & Hbind & H).
    assert (Hle : le0 ! AUT._m = Some v).
    { change (fn_params AUT.f_check_common_automatic_cancels) with [(AUT._m, tyMSp)] in Hbind.
      cbn [bind_parameter_temps] in Hbind. injection Hbind as <-. apply PTree.gss. }
    pose proof Hfr as (_ & (WL & _)).
    unfold AUT.f_check_common_automatic_cancels in H. cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & Hn)].
    2: { destruct (plunge_skip _ _ _ _ _ _ _ _ _ _ _ c Hle Hmarg WL Hc Hb H1 eq_refl eq_refl eq_refl)
           as (_ & -> & _). congruence. }
    destruct (plunge_skip _ _ _ _ _ _ _ _ _ _ _ c Hle Hmarg WL Hc Hb H1 eq_refl eq_refl eq_refl)
      as (-> & _ & _).
    rewrite (x_ret _ _ _ _ _ _ _ _ _ H2).
    split; [exact Hw |]. split; [exists c; split; [exact Hc | apply rt_refl] |]. exact Hfr.
  Qed.

  (* ==================================================================== *)
  (* 5. check_common_airborne_cancels: the plunge, the squish and the      *)
  (*    vertical-wind tests are false; then quicksandDepth = 0.           *)
  (* ==================================================================== *)

  Lemma ccairc_row : forall v,
    seg_okR lp bm MWF (Internal AIR.f_check_common_airborne_cancels) [v]
      (fun m => marg_ok bm [v] /\ fresh_at bm m) (fun m' _ => fresh_at bm m').
  Proof.
    intros v m t m' vr c Hok Hw (Hmarg & Hfr) Hok' Hc Hb Hev.
    destruct (fc_entry ge m AIR.f_check_common_airborne_cancels [v] t m' vr eq_refl Hev) as (le0 & le' & t' & out & Hbind & H).
    assert (Hle : le0 ! AIR._m = Some v).
    { change (fn_params AIR.f_check_common_airborne_cancels) with [(AIR._m, tyMSp)] in Hbind.
      cbn [bind_parameter_temps] in Hbind. injection Hbind as <-. apply PTree.gss. }
    pose proof Hfr as (_ & (WL & INP)).
    pose proof Hw as (_ & HW & _ & _ & _ & Hf & _).
    unfold AIR.f_check_common_airborne_cancels in H. cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & Hn)].
    2: { destruct (plunge_skip _ _ _ _ _ _ _ _ _ _ _ c Hle Hmarg WL Hc Hb H1 eq_refl eq_refl eq_refl)
           as (_ & -> & _). congruence. }
    destruct (plunge_skip _ _ _ _ _ _ _ _ _ _ _ c Hle Hmarg WL Hc Hb H1 eq_refl eq_refl eq_refl)
      as (-> & _ & -> & Hle1).
    clear H1 Hle.
    (* INPUT_SQUISHED is clear *)
    match type of H2 with exec_stmt _ _ _ _ _ (Ssequence ?p2 _) _ _ _ _ =>
      assert (K2 : forall le t le' m' out, le ! AIR._m = Some (Vptr bm Ptrofs.zero) ->
                exec_stmt function_entry2 ge empty_env le m p2 t le' m' out ->
                m' = m /\ out = Out_normal /\ le' ! AIR._m = Some (Vptr bm Ptrofs.zero)) end.
    { intros le t0 le2 m2 out0 Hl0 H0.
      apply (seq_set_inv lp) in H0 as (vi & Ei & H0).
      destruct (ev_fld AIR._m le m _ mario._input tushort Mint16unsigned 2 vi Hl0 (conj eq_refl eq_refl)
                  fo_input ltac:(lia) eq_refl Ei) as (_ & Li).
      apply x_if in H0 as (vc & bc & Ec & Bc & H0).
      apply eval_expr_Ebinop_inv in Ec as (va & vb & Ea & Eb & Sb).
      apply eval_expr_Etempvar_val in Ea. rewrite PTree.gss in Ea. injection Ea as <-.
      apply eval_expr_Econst_int_val in Eb. subst vb.
      cbn [typeof] in Sb, Bc.
      pose proof (Mem.load_cast _ _ _ _ _ Li) as Hz. cbn in Hz.
      destruct vi; try (cbn in Hz; discriminate Hz); try (cbn in Sb; discriminate Sb).
      rewrite sb_and_usi in Sb. injection Sb as <-.
      rewrite (INP _ Li) in Bc. apply bv_int in Bc. subst bc.
      change (negb (Int.eq Int.zero Int.zero)) with false in H0. cbv iota in H0.
      apply x_skip in H0 as (-> & -> & ->).
      split; [reflexivity |]. split; [reflexivity |].
      rewrite PTree.gso by (apply Pos.eqb_neq; vm_compute; reflexivity). exact Hl0. }
    apply seq_inv in H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | (t3 & H3 & Hn)].
    2: { destruct (K2 _ _ _ _ _ Hle1 H3) as (_ & -> & _). congruence. }
    destruct (K2 _ _ _ _ _ Hle1 H3) as (-> & _ & Hle3). clear H3 K2.
    (* the floor is a WMotR surface: not SURFACE_VERTICAL_WIND (56) *)
    match type of H4 with exec_stmt _ _ _ _ _ (Ssequence ?p3 _) _ _ _ _ =>
      assert (K3 : forall le t le' m' out, le ! AIR._m = Some (Vptr bm Ptrofs.zero) ->
                exec_stmt function_entry2 ge empty_env le m p3 t le' m' out ->
                m' = m /\ out = Out_normal /\ le' ! AIR._m = Some (Vptr bm Ptrofs.zero)) end.
    { intros le t0 le2 m2 out0 Hl0 H0.
      apply seq_inv in H0 as [(ta & lea & ma & tb & Ha & Hb') | (ta & Ha & Hn)].
      all: apply (seq_set_inv lp) in Ha as (vf & Ef & Ha).
      all: destruct (ev_fld AIR._m le m _ mario._floor (tptr (Tstruct mario._Surface noattr)) Mint32 104 vf Hl0
                       (conj eq_refl eq_refl) fo_floor ltac:(lia) eq_refl Ef) as (_ & Lf).
      all: destruct HW as (_ & _ & Hfl & _).
      all: destruct (Hfl vf Lf) as (sb & so & ty & -> & Lty & Hin).
      all: apply (seq_set_inv lp) in Ha as (vt & Et & Ha).
      all: pose proof (ev_stype _ _ _ _ _ _ ltac:(apply PTree.gss) Et) as Lt.
      all: rewrite Lty in Lt; injection Lt as <-.
      all: assert (Hne : Int.eq ty (Int.repr 56) = false)
             by (rewrite <- (Int.repr_signed ty);
                 rewrite wmotr_surface_types_value in Hin;
                 destruct Hin as [X|[X|[X|[X|[X|[]]]]]]; rewrite <- X; reflexivity).
      all: apply x_if in Ha as (vc & bc & Ec & Bc & Ha).
      all: apply eval_expr_Ebinop_inv in Ec as (va & vb & Ea & Eb & Sb).
      all: apply eval_expr_Etempvar_val in Ea; rewrite PTree.gss in Ea; injection Ea as <-.
      all: apply eval_expr_Econst_int_val in Eb; subst vb.
      all: cbn [typeof] in Sb, Bc; rewrite sb_eq_si in Sb; injection Sb as <-.
      all: apply bv_of_bool in Bc; subst bc; rewrite Hne in Ha; cbv iota in Ha.
      all: apply x_set in Ha as (v4 & E4 & -> & -> & Eo).
      all: apply eval_expr_Econst_int_val in E4; subst v4.
      2: { congruence. }
      apply x_if in Hb' as (vc & bc & Ec & Bc & Hb').
      apply eval_expr_Etempvar_val in Ec. rewrite PTree.gss in Ec. injection Ec as <-.
      cbn [typeof] in Bc. apply bv_int in Bc. subst bc.
      change (negb (Int.eq (Int.repr 0) Int.zero)) with false in Hb'. cbv iota in Hb'.
      apply x_skip in Hb' as (-> & -> & ->).
      split; [reflexivity |]. split; [reflexivity |]. le_simp. exact Hl0. }
    apply seq_inv in H4 as [(t5 & le5 & m5 & t6 & H5 & H6) | (t5 & H5 & Hn)].
    2: { destruct (K3 _ _ _ _ _ Hle3 H5) as (_ & -> & _). congruence. }
    destruct (K3 _ _ _ _ _ Hle3 H5) as (-> & _ & Hle5). clear H5 K3.
    (* quicksandDepth = 0, then return 0 *)
    apply seq_inv in H6 as [(t7 & le7 & m7 & t8 & H7 & H8) | (t7 & H7 & Hn)].
    2: { destruct (qsd_eff lp LO_mario bm _ _ _ _ _ _ _ Hle5 (conj eq_refl eq_refl) H7) as (_ & -> & _).
         congruence. }
    destruct (qsd_eff lp LO_mario bm _ _ _ _ _ _ _ Hle5 (conj eq_refl eq_refl) H7) as (_ & _ & Hst).
    rewrite (x_ret _ _ _ _ _ _ _ _ _ H8).
    split; [exact (qsd_fworld lp bm _ _ Hst Hw) |].
    split; [exists c; split; [exact (qsd_cells lp bm _ _ Hst c Hf Hc) | apply rt_refl] |].
    exact (qsd_fresh_at bm _ _ Hst Hfr).
  Qed.

  (* ==================================================================== *)
  (* 6. play_far_fall_sound: a change in play_sound's globals and in       *)
  (*    m->flags keeps the frame world, the cells and the floor refresh.  *)
  (* ==================================================================== *)

  Definition PH (bsr bsrc : block) (b : block) (z : Z) : Prop :=
    b <> bsr /\ b <> bsrc /\ ~ (b = bm /\ 4 <= z < 8).
  Definition Qrel (bsr bsrc : block) (m0 m1 : mem) : Prop :=
    Mem.unchanged_on (PH bsr bsrc) m0 m1 /\ Mem.nextblock m1 = Mem.nextblock m0
    /\ (forall b o k p, Mem.perm m1 b o k p <-> Mem.perm m0 b o k p).

  Section HOLE.
    Variables (m m' : mem) (bsr bsrc : block).
    Hypothesis SR0 : Genv.find_symbol ge AX._sSoundRequests = Some bsr.
    Hypothesis SRC0 : Genv.find_symbol ge AX._sSoundRequestCount = Some bsrc.
    Hypothesis NB : Mem.nextblock m' = Mem.nextblock m.
    Hypothesis PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p.
    Hypothesis LD : forall ch b z, b <> bsr -> b <> bsrc -> (b <> bm \/ z + size_chunk ch <= 4 \/ 8 <= z) ->
      Mem.load ch m' b z = Mem.load ch m b z.
    Hypothesis CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp'.
    Hypothesis NBR : bm <> bsr.
    Hypothesis NBRC : bm <> bsrc.

    Lemma LHb : forall ch b z, b <> bm -> b <> bsr -> b <> bsrc -> Mem.load ch m' b z = Mem.load ch m b z.
    Proof. intros ch b z H1 H2 H3. exact (LD ch b z H2 H3 (or_introl H1)). Qed.

    Lemma LHm : forall ch z, z + size_chunk ch <= 4 \/ 8 <= z -> Mem.load ch m' bm z = Mem.load ch m bm z.
    Proof. intros ch z H. exact (LD ch bm z NBR NBRC (or_intror H)). Qed.

    Ltac hm := rewrite LHm by hside.
    Ltac hm_in H := rewrite LHm in H by hside.

    Lemma hole_apart : ffw ge bm m ->
      (forall bo oo, Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo) -> bo <> bm /\ bo <> bsr /\ bo <> bsrc)
      /\ (forall off sb so, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
            Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm /\ sb <> bsr /\ sb <> bsrc)
      /\ (forall bc oc, Mem.load Mint32 m bm FFW_CTL = Some (Vptr bc oc) -> bc <> bm /\ bc <> bsr /\ bc <> bsrc).
    Proof.
      intros (_ & EX & _).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr' & bsrc' & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                      HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                      W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
      assert (bsr' = bsr) by congruence. assert (bsrc' = bsrc) by congruence. subst bsr' bsrc'.
      set (rl := ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) in *.
      assert (NR : forall b, ~ rblk rl b -> b <> bm /\ b <> bsr /\ b <> bsrc).
      { intros b Hn. split; [| split]; intros ->; apply Hn; exists Ptrofs.zero; unfold rl, ff_rl; cbn; auto 20. }
      split; [| split].
      - intros bo' oo' Hl. change MARIOOBJ_OFF with FFW_OBJ in Hl. rewrite Lo in Hl. injection Hl as <- _.
        destruct (D4 bsr (or_introl (ltac:(cbn; repeat (first [left; reflexivity | right])) : In bsr [bfi; bmiss; bcalls; bsin; ab; biom; bmq; brm; blk; bpc; bsr; bsrc; bsms]))) as (A & _).
        destruct (D4 bsrc (or_introl (ltac:(cbn; repeat (first [left; reflexivity | right])) : In bsrc [bfi; bmiss; bcalls; bsin; ab; biom; bmq; brm; blk; bpc; bsr; bsrc; bsms]))) as (B & _).
        split; [exact D1 | split; congruence].
      - intros off sb so Hoff Hl. apply NR. destruct Hoff as [-> | [-> | ->]].
        + exact (Wc0 FFW_WALL sb so (or_introl eq_refl) Hl).
        + exact (Wc0 FFW_CEIL sb so (or_intror eq_refl) Hl).
        + change FLOOR_OFF with FFW_FLOOR in Hl. rewrite Lf in Hl. injection Hl as ->.
          destruct Wf as (b' & o' & E & _ & _ & _ & Nr). injection E as <- _. exact Nr.
      - intros bc oc Hl. apply NR. rewrite Lc in Hl. injection Hl as ->.
        destruct Wc as (b' & o' & E & _ & _ & _ & Nr). injection E as <- _. exact Nr.
    Qed.

    Lemma hole_obj : ffw ge bm m -> exists bo oo, Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo).
    Proof.
      intros (_ & EX & _).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr' & bsrc' & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                      HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & _).
      exists bo, oo. exact Lo.
    Qed.

    Lemma hole_cells : forall c, ffw ge bm m -> read_cells bm m c -> read_cells bm m' c.
    Proof.
      intros c Hf (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8).
      destruct (hole_apart Hf) as (Ao & _).
      split; [hm; exact H1 |]. split; [hm; exact H2 |]. split; [hm; exact H3 |].
      split; [hm; exact H4 |]. split; [hm; exact H5 |]. split; [hm; exact H6 |].
      exists bo, oo. split; [hm; exact H7 |].
      destruct (Ao bo oo H7) as (N1 & N2 & N3). rewrite LHb by assumption. exact H8.
    Qed.

    Lemma hole_fresh_at : fresh_at bm m -> fresh_at bm m'.
    Proof.
      intros (H & I). split.
      - intros a La Hg. hm_in La. intros y fh Ly Lf. hm_in Ly. hm_in Lf.
        destruct (H a La Hg y fh Ly Lf) as (A & [B | B]); (split; [exact A |]);
          [left; hm; exact B | right; exact B].
      - apply (inputs_ok_keep bm m m'); [hm; reflexivity | hm; reflexivity | exact I].
    Qed.

    Lemma hole_ffw : ffw ge bm m -> ffw ge bm m'.
    Proof.
      intros (Hgn & EX & FD).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr' & bsrc' & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                      HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                      W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
      assert (bsr' = bsr) by congruence. assert (bsrc' = bsrc) by congruence. subst bsr' bsrc'.
      set (rl := ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) in *.
      assert (NR : forall b, ~ rblk rl b -> b <> bm /\ b <> bsr /\ b <> bsrc).
      { intros b Hn. split; [| split]; intros ->; apply Hn; exists Ptrofs.zero; unfold rl, ff_rl; cbn; auto 20. }
      assert (NBo : bo <> bm /\ bo <> bsr /\ bo <> bsrc).
      { destruct (D4 bsr (or_introl (ltac:(cbn; repeat (first [left; reflexivity | right])) : In bsr [bfi; bmiss; bcalls; bsin; ab; biom; bmq; brm; blk; bpc; bsr; bsrc; bsms]))) as (A & _).
        destruct (D4 bsrc (or_introl (ltac:(cbn; repeat (first [left; reflexivity | right])) : In bsrc [bfi; bmiss; bcalls; bsin; ab; biom; bmq; brm; blk; bpc; bsr; bsrc; bsms]))) as (B & _).
        split; [exact D1 | split; congruence]. }
      destruct NBo as (O1 & O2 & O3).
      assert (Nab1 : ab <> bsr) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 SR eq_refl).
      assert (Nab2 : ab <> bsrc) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 SRC eq_refl).
      assert (Hnb : Ple (Mem.nextblock m) (Mem.nextblock m')) by (rewrite NB; apply Ple_refl).
      assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
        by (intros b ofs k p _ Hp; exact (PM b ofs k p Hp)).
      assert (Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk rl b -> Mem.load ch m' b z = Mem.load ch m b z)
        by (intros ch b z _ Nr; destruct (NR b Nr) as (A & B & C); exact (LHb ch b z A B C)).
      destruct (CLK gp HC HS HM) as (gp' & Hinc & HC' & HS').
      split; [rewrite NB; exact Hgn |].
      split.
      - exists gp', bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, blk, bpc, bsr, bsrc, bsms, bo, oo, bt, ot, fl, ar, inp, ctl.
        split; [exact HC' |]. split; [exact HS' |]. split; [exact (Hinc _ HM) |].
        do 13 (split; [assumption |]).
        split; [hm; exact Lo |]. split; [exact Soo |]. split; [hm; exact La |].
        split; [rewrite (LD Mint32 ab 8 Nab1 Nab2 (or_intror (or_intror (Z.le_refl 8)))); exact Lb |].
        do 5 (split; [assumption |]).
        split; [exact (Wff_keep2 ge m m' rl Hnb Hperm Hld gp gp' Hinc W) |].
        split; [hm; exact Lf |]. split; [exact (wblk_keep2 m m' rl Hnb Hperm Hld _ _ _ Wf) |].
        split; [intros off sb so Hoff Hl;
                destruct Hoff as [-> | ->]; hm_in Hl;
                [exact (Wc0 FFW_WALL sb so (or_introl eq_refl) Hl)
                | exact (Wc0 FFW_CEIL sb so (or_intror eq_refl) Hl)] |].
        split; [hm; exact Lar |]. split; [exact (wblk_keep2 m m' rl Hnb Hperm Hld _ _ _ War) |].
        split; [hm; exact Li |]. split; [exact Ai |].
        split; [hm; exact Lc |]. split; [exact (wblk_keep2 m m' rl Hnb Hperm Hld _ _ _ Wc) |].
        split; [intros i cb co Hi Hl; rewrite LHb in Hl by assumption; exact (Co i cb co Hi Hl) |].
        hm; exact LPC.
      - exact (floor_data_keep2 ge m m' rl Hnb Hperm Hld gp W FD).
    Qed.

    Lemma hole_coll : forall v, (forall b o, v = Vptr b o -> b <> bm /\ b <> bsr /\ b <> bsrc) ->
      coll_obj_ok m v -> coll_obj_ok m' v.
    Proof.
      intros v Hb (b & o & t & -> & Lt & Hin & Hp & Hc).
      destruct (Hb b o eq_refl) as (N1 & N2 & N3).
      exists b, o, t. split; [reflexivity |]. split; [rewrite LHb by assumption; exact Lt |].
      split; [exact Hin |]. split.
      - intros Ht. destruct (Hp Ht) as (base & top & Hi & P1 & P2 & P3).
        exists base, top. split; [exact Hi |]. rewrite !LHb by assumption. tauto.
      - intros Ht. destruct (Hc Ht) as (y & Hi & P1).
        exists y. split; [exact Hi |]. rewrite LHb by assumption. exact P1.
    Qed.

    Lemma hole_world : ffw ge bm m -> wmotr_world bm m -> wmotr_world bm m'.
    Proof.
      intros Hf (Hw & Hc & Hfl & Hh & Hr & Hq & Ho).
      pose proof Hf as (_ & EX & _).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr' & bsrc' & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                      HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                      W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
      destruct (hole_apart Hf) as (Ao & As & _).
      split; [| split; [| split; [| split; [| split; [| split]]]]].
      - intros v Hl. hm_in Hl. destruct (Hw v Hl) as [-> | (b & o & t & -> & Lt & Hin)]; [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        destruct (As WALL_OFF b o (or_introl eq_refl) Hl) as (N1 & N2 & N3).
        rewrite LHb by assumption. exact Lt.
      - intros v Hl. hm_in Hl. destruct (Hc v Hl) as [-> | (b & o & t & -> & Lt & Hin)]; [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        destruct (As CEIL_OFF b o (or_intror (or_introl eq_refl)) Hl) as (N1 & N2 & N3).
        rewrite LHb by assumption. exact Lt.
      - intros v Hl. hm_in Hl. destruct (Hfl v Hl) as (b & o & t & -> & Lt & Hin).
        exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        destruct (As FLOOR_OFF b o (or_intror (or_intror eq_refl)) Hl) as (N1 & N2 & N3).
        rewrite LHb by assumption. exact Lt.
      - hm. exact Hh.
      - hm. exact Hr.
      - hm. exact Hq.
      - destruct Ho as (mb & mo & s & n & Hl & Ls & Hs & Ln & Hn & Hall).
        destruct (Ao mb mo Hl) as (N1 & N2 & N3).
        exists mb, mo, s, n. split; [hm; exact Hl |].
        split; [rewrite LHb by assumption; exact Ls |]. split; [exact Hs |].
        split; [rewrite LHb by assumption; exact Ln |]. split; [exact Hn |].
        intros i v Hi Hl2. rewrite LHb in Hl2 by assumption.
        apply hole_coll; [| exact (Hall i v Hi Hl2)].
        intros cb co ->. change MARIOOBJ_OFF with FFW_OBJ in Hl. rewrite Lo in Hl.
        injection Hl as <- <-.
        rewrite (Co i cb co ltac:(lia) Hl2). exact (conj N1 (conj N2 N3)).
    Qed.

    Lemma hole_anim : ffw ge bm m -> anim_apart lp bm m -> anim_apart lp bm m'.
    Proof.
      intros Hf Han ab bt ot Hs Hl.
      destruct (hole_apart Hf) as (Ao & _ & _).
      assert (N1 : ab <> bsr) by exact (AnimKeep.symne_ids ge _ _ _ _ Hs SR0 eq_refl).
      assert (N2 : ab <> bsrc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hs SRC0 eq_refl).
      rewrite (LD Mptr ab 8 N1 N2 (or_intror (or_intror (Z.le_refl 8)))) in Hl.
      destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
      - intros off sb so Hoff Hl'.
        destruct Hoff as [-> | [-> | ->]]; hm_in Hl';
          [exact (A1 WALL_OFF sb so (or_introl eq_refl) Hl')
          | exact (A1 CEIL_OFF sb so (or_intror (or_introl eq_refl)) Hl')
          | exact (A1 FLOOR_OFF sb so (or_intror (or_intror eq_refl)) Hl')].
      - intros mb mo i cb co Hl' Hi Hl2. hm_in Hl'.
        destruct (Ao mb mo Hl') as (M1 & M2 & M3).
        rewrite LHb in Hl2 by assumption.
        exact (A2 mb mo i cb co Hl' Hi Hl2).
    Qed.

    Lemma hole_mobj : ffw ge bm m -> mobj_apart bm m -> mobj_apart bm m'.
    Proof.
      intros Hf Hmo mb mo Hl.
      destruct (hole_apart Hf) as (Ao & _ & _).
      hm_in Hl.
      destruct (Ao mb mo Hl) as (M1 & M2 & M3).
      destruct (Hmo mb mo Hl) as (P1 & P2 & P3).
      split; [exact P1 |]. split.
      - intros off sb so Hoff Hl'.
        destruct Hoff as [-> | [-> | ->]]; hm_in Hl';
          [exact (P2 WALL_OFF sb so (or_introl eq_refl) Hl')
          | exact (P2 CEIL_OFF sb so (or_intror (or_introl eq_refl)) Hl')
          | exact (P2 FLOOR_OFF sb so (or_intror (or_intror eq_refl)) Hl')].
      - intros i cb co Hi Hl'. rewrite LHb in Hl' by assumption.
        exact (P3 i cb co Hi Hl').
    Qed.

    Lemma hole_adown : ffw ge bm m -> a_down_real bm m' = a_down_real bm m.
    Proof.
      intros Hf. destruct (hole_apart Hf) as (_ & _ & Ac).
      unfold a_down_real. hm.
      destruct (Mem.load Mptr m bm 156) as [[] |] eqn:E; try reflexivity.
      destruct (Ac _ _ E) as (N1 & N2 & N3). rewrite LHb by assumption. reflexivity.
    Qed.

    Lemma hole_used : ffw ge bm m -> used_ok bm m -> used_ok bm m'.
    Proof.
      intros Hf U a La. hm_in La. destruct (U a La) as (U1 & U2).
      destruct (hole_apart Hf) as (Ao & _ & _).
      destruct (hole_obj Hf) as (bo & oo & Lo).
      destruct (Ao bo oo Lo) as (N1 & N2 & N3).
      assert (K136 : Mem.load Mint32 m' bm MARIOOBJ_OFF = Mem.load Mint32 m bm MARIOOBJ_OFF) by (hm; reflexivity).
      assert (Ap : forall ub uo, used_apart bm m ub uo -> used_apart bm m' ub uo).
      { intros ub uo A. split; [exact (proj1 A) |]. intros mb mo Hl. rewrite K136 in Hl. exact (proj2 A mb mo Hl). }
      split.
      - intros Hp. destruct (U1 Hp) as (ub & uo & Lu & (base & top & Hin & Ht & P1 & P2 & P3) & A & (S & PP) & V).
        destruct (PP bo oo Lo) as (Eu & p & Lp & Fp & Rp). subst ub.
        exists bo, uo. split; [hm; exact Lu |].
        split; [| split; [exact (Ap _ _ A) | split]].
        + exists base, top. split; [exact Hin |]. split; [exact Ht |].
          rewrite !LHb by assumption. auto.
        + split; [exact S |]. intros mb mo Hl. rewrite K136, Lo in Hl. injection Hl as <- <-.
          split; [reflexivity |]. exists p. rewrite LHb by assumption. exact (conj Lp (conj Fp Rp)).
        + intros w Lv. hm_in Lv. exact (V w Lv).
      - intros Hcn. destruct (U2 Hcn) as (ub & uo & Lu & (y & Hin & P1) & A & (S & CP)).
        destruct (CP bo oo Lo) as (Eu & CC). subst ub.
        exists bo, uo. split; [hm; exact Lu |]. split; [| split; [exact (Ap _ _ A) |]].
        + exists y. split; [exact Hin |]. rewrite LHb by assumption. exact P1.
        + split; [exact S |]. intros mb mo Hl. rewrite K136, Lo in Hl. injection Hl as <- <-.
          split; [reflexivity |]. intros i cb co Hi Hl2. rewrite LHb in Hl2 by assumption.
          exact (CC i cb co Hi Hl2).
    Qed.

    Lemma hole_anim_w : ffw ge bm m -> AnimWorld.anim_w ge bm m -> AnimWorld.anim_w ge bm m'.
    Proof.
      intros Hf AW. pose proof Hf as (Hgn & EX & FD).
      destruct (hole_apart Hf) as (Ao & _ & _).
      destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr' & bsrc' & bsms & bo & oo & bt & ot
                      & fl & ar & inp & ctl & HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS
                      & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 & W & _).
      assert (bsr' = bsr) by congruence. assert (bsrc' = bsrc) by congruence. subst bsr' bsrc'.
      pose proof AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & _).
      pose proof B as (Sab & _ & _ & _ & L8 & _ & Sy & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & Hbm0).
      assert (ab' = ab) by congruence. subst ab'.
      rewrite Lb in L8. injection L8 as <- <-.
      assert (Nab : ab <> bm) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 Hbm0 eq_refl).
      assert (N1 : ab <> bsr) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 SR eq_refl).
      assert (N2 : ab <> bsrc) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 SRC eq_refl).
      destruct (Ao bo oo Lo) as (O1 & O2 & O3).
      assert (T1 : bt <> bsr) by exact (not_eq_sym (proj2 (Sy _ _ SR))).
      assert (T2 : bt <> bsrc) by exact (not_eq_sym (proj2 (Sy _ _ SRC))).
      apply (AnimKeep.anim_w_keep ge bm m m' gp bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bo oo bt ot
               S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS Lo Lb W AW).
      - rewrite NB. apply Ple_refl.
      - intros b ofs k p _ Hp. exact (PM b ofs k p Hp).
      - intros ch b z _ Hr. apply LHb; intros ->; apply Hr; exists Ptrofs.zero; unfold ff_rl; cbn; auto 20.
      - hm. reflexivity.
      - rewrite (LD Mint32 ab 0 N1 N2 (or_introl Nab)). reflexivity.
      - rewrite (LD Mint32 ab 8 N1 N2 (or_introl Nab)). reflexivity.
      - hm. reflexivity.
      - hm. reflexivity.
      - right. split; [hm; reflexivity |].
        split; [rewrite (LD Mint32 ab 4 N1 N2 (or_introl Nab)); reflexivity |]. split.
        + intros o ch _. apply LHb; assumption.
        + intros k rel ch v0 _ _. apply LHb; assumption.
    Qed.

    Lemma hole_lvl : AnimWorld.anim_w ge bm m -> lvl_w ge m -> lvl_w ge m'.
    Proof.
      intros AW Hl.
      apply (AnimKeep.lvl_w_keep_ne ge m m' (fun b => b <> bm /\ b <> bsr /\ b <> bsrc)); [| | exact Hl].
      - intros b Hs. split; [exact (AnimKeep.lvl_ne_bm ge bm m AW b Hs) |].
        destruct Hs as [Hs | Hs]; split;
          first [ exact (AnimKeep.symne_ids ge _ _ _ _ Hs SR0 eq_refl)
                | exact (AnimKeep.symne_ids ge _ _ _ _ Hs SRC0 eq_refl) ].
      - intros ch b z (A & B & C). exact (LHb ch b z A B C).
    Qed.

    Lemma hole_fworld : fworld lp bm m -> fworld lp bm m'.
    Proof.
      intros (Ha & Hw & Han & Hmo & Hd & Hf & Hu & Haw & Hl).
      split; [intros v Hl'; apply Ha; hm_in Hl'; exact Hl' |].
      split; [exact (hole_world Hf Hw) |]. split; [exact (hole_anim Hf Han) |].
      split; [exact (hole_mobj Hf Hmo) |]. split; [rewrite (hole_adown Hf); exact Hd |].
      split; [exact (hole_ffw Hf) |]. split; [exact (hole_used Hf Hu) |].
      split; [exact (hole_anim_w Hf Haw) |]. exact (hole_lvl Haw Hl).
    Qed.
  End HOLE.

  (* the walk's store: m->flags *)
  Lemma pffs_store : forall v lv rhs le m0 m1 t le' m2 out bsr bsrc,
    pffs_store_ok lv rhs = true -> le ! AIR._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Qrel bsr bsrc m0 m1 -> Qrel bsr bsrc m0 m2.
  Proof.
    intros v lv rhs le m0 m1 t le' m2 out bsr bsrc Hok Hle Hmarg Hx (U & N & P).
    unfold pffs_store_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Pos.eqb_eq in E1, E2, E3. subst.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp LO_mario _ _ _ _ _ _ _ _ _ _ L1 eq_refl fo_flags) as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->].
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as Hch; subst end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    change (Ptrofs.add Ptrofs.zero (Ptrofs.repr 4)) with (Ptrofs.repr 4) in Hst.
    cbn [Mem.storev] in Hst. change (Ptrofs.unsigned (Ptrofs.repr 4)) with 4 in Hst.
    split; [| split].
    - eapply Mem.unchanged_on_trans; [exact U |].
      eapply Mem.store_unchanged_on; [exact Hst |].
      intros i Hi (_ & _ & Hn). apply Hn. split; [reflexivity |].
      rewrite ?Ptrofs.add_zero_l in Hi. change (Ptrofs.unsigned (Ptrofs.repr 4)) with 4 in Hi.
      change (Ptrofs.unsigned (Ptrofs.repr (fst (4, Full)))) with 4 in Hi. cbn [size_chunk] in Hi. lia.
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact N.
    - intros b o k p. rewrite <- P. split.
      + eapply Mem.perm_store_2; eassumption.
      + eapply Mem.perm_store_1; eassumption.
  Qed.

  (* the walk's call: the real play_sound (SndXc.ps_walk) *)
  Lemma pffs_call : forall v optid a al le m0 m1 t le' m2 out bsr bsrc,
    Genv.find_symbol ge AX._sSoundRequests = Some bsr ->
    Genv.find_symbol ge AX._sSoundRequestCount = Some bsrc ->
    pffs_call_ok optid a al = true -> le ! AIR._m = Some v ->
    exec_stmt function_entry2 ge empty_env le m1 (Scall optid a al) t le' m2 out ->
    Qrel bsr bsrc m0 m1 -> Qrel bsr bsrc m0 m2 /\ le' ! AIR._m = Some v.
  Proof.
    intros v optid a al le m0 m1 t le' m2 out bsr bsrc SR SRC Hok Hle Hx (U & N & P).
    unfold pffs_call_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    apply Pos.eqb_eq in Hok. subst.
    inv Hx.
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (ev_fun _ _ _ _ _ _ _ _ He) as (b & Hs & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some ?fd, Hf : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
      pose proof (resolve_pin_fd lp _ _ _ fd (linked12_LO_audio_external lp H12) ps_defmap
                    (ex_intro _ b (conj Hs Hff))) as ->;
      rename Hf into Hev end.
    assert (Hblks : forall g b0, mem_id g ps_globals = true -> Genv.find_symbol ge g = Some b0 ->
                      In b0 [bsr; bsrc]).
    { intros g b0 Hm Hs0. unfold mem_id in Hm. apply existsb_exists in Hm as (x & Ix & Ex).
      apply Pos.eqb_eq in Ex. subst x. destruct Ix as [<- | [<- | []]].
      - left. congruence.
      - right. left. congruence. }
    destruct (fp_body lp ps_globals [bsr; bsrc] Hblks m1 AX.f_play_sound eq_refl ps_walk _ _ _ _ Hev)
      as (U2 & N2 & P2).
    split; [| exact Hle].
    split; [| split].
    - eapply Mem.unchanged_on_trans; [exact U |].
      eapply Mem.unchanged_on_implies; [exact U2 |].
      intros b0 z (Nr & Nrc & _) _ (Hin & _). destruct Hin as [-> | [-> | []]]; contradiction.
    - rewrite N2. exact N.
    - intros b0 o k p. rewrite P2. exact (P b0 o k p).
  Qed.

  Lemma pffs_row : forall v,
    seg_okR lp bm MWF (Internal AIR.f_play_far_fall_sound) [v]
      (fun m => marg_ok bm [v] /\ fresh_at bm m) (fun m' _ => fresh_at bm m').
  Proof.
    intros v m t m' vr c Hok Hw (Hmarg & Hfr) Hok' Hc Hb Hev.
    pose proof Hw as (_ & _ & _ & _ & _ & Hf & _ & Haw & _).
    pose proof Hf as (Hgn & EX & _).
    destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                    HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & _).
    assert (HQ : Qrel bsr bsrc m m').
    { refine (lw_body_frame ge (Qrel bsr bsrc m) AIR.f_play_far_fall_sound (fun le => le ! AIR._m = Some v)
                (fun id _ => negb (Pos.eqb id AIR._m)) pffs_store_ok pffs_call_ok eq_refl pffs_chk
                _ _ _ m [v] t m' vr Hev _ _).
      - intros id a le m1 v1 Hs Hp _ _. cbv beta in *.
        rewrite PTree.gso; [exact Hp |]. intros E. rewrite E, Pos.eqb_refl in Hs. discriminate Hs.
      - intros lv rhs le m1 t1 le1 m2 out Hs Hp Hx HQ1.
        exact (pffs_store v lv rhs le m m1 t1 le1 m2 out bsr bsrc Hs Hp Hmarg Hx HQ1).
      - intros optid a al le m1 t1 le1 m2 out Hs Hp Hx HQ1.
        exact (pffs_call v optid a al le m m1 t1 le1 m2 out bsr bsrc SR SRC Hs Hp Hx HQ1).
      - intros le1 Hb1. change (fn_params AIR.f_play_far_fall_sound) with [(AIR._m, tyMSp)] in Hb1.
        cbn [bind_parameter_temps] in Hb1. injection Hb1 as <-. apply PTree.gss.
      - split; [apply Mem.unchanged_on_refl | split; [reflexivity | tauto]]. }
    destruct HQ as (U & N & P).
    assert (NB : Mem.nextblock m' = Mem.nextblock m) by exact N.
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p)
      by (intros b o k p Hp; exact (proj2 (P b o k p) Hp)).
    assert (LD : forall ch b z, b <> bsr -> b <> bsrc -> (b <> bm \/ z + size_chunk ch <= 4 \/ 8 <= z) ->
               Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z N1 N2 Hz.
      destruct (plt b (Mem.nextblock m)) as [V | V].
      - eapply Mem.load_unchanged_on_1; [exact U | exact V |].
        intros i Hi. split; [exact N1 | split; [exact N2 |]].
        intros (-> & Hi'). destruct Hz as [Hz | Hz]; [exact (Hz eq_refl) | lia].
      - rewrite (load_invalid m ch b z V). apply load_invalid.
        unfold Mem.valid_block. rewrite N. exact V. }
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    pose proof Haw as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & _).
    pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                     & _ & _ & _ & _ & _ & _ & _ & _ & Hbm0).
    assert (NBR : bm <> bsr) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SR eq_refl).
    assert (NBRC : bm <> bsrc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SRC eq_refl).
    split; [eapply hole_fworld; eassumption |].
    split; [exists c; split; [eapply hole_cells; eassumption | apply rt_refl] |].
    eapply hole_fresh_at; eassumption.
  Qed.

  (* ==================================================================== *)
  (* THE TWO ROWS                                                          *)
  (* ==================================================================== *)

  Theorem air_pro_rows_proved : air_pro_rows lp bm MWF.
  Proof.
    intros f fd v [-> | [-> | ->]] Hr.
    - pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_ccairc Hr) as ->.
      exact (ccairc_row v).
    - pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_pffs Hr) as ->.
      exact (pffs_row v).
    - pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_aut lp H12) dm_ccac Hr) as ->.
      exact (ccac_row v).
  Qed.
End PR.
