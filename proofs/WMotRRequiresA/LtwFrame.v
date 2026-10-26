(* kept: level_trigger_warp's contract, staged for the two open rows that call it
   (update_mario_inputs, mario_handle_special_floors; NaSplit.na_open) *)
(* ====================================================================== *)
(* LtwFrame (GOAL 2, 2026-10-26): level_trigger_warp's contract, proved   *)
(* from its real body (level_update.c:699) and its callees' real bodies.  *)
(*                                                                        *)
(* Two Mario-side calls reach it inside WMotR:                             *)
(*   - update_mario_geometry_inputs (mario.c:1366), on the double miss    *)
(*     (no floor under pos nor under gfx.pos): WARP_OP_DEATH (0x12);      *)
(*   - check_death_barrier (interaction.c:1821), from                     *)
(*     mario_handle_special_floors on the death plane: WARP_OP_WARP_FLOOR *)
(*     (0x13).                                                            *)
(*                                                                        *)
(* 1. THE FOOTPRINT (ltw_frame, any op): a call changes only the blocks   *)
(*    of ltw_ws -- the five level_update statics it stores (sDelayedWarp- *)
(*    Op / Arg / Timer, sSourceWarpNodeId, gSavedCourseNum) and the       *)
(*    globals its callees store (play_transition: gWarpTransition and the *)
(*    transition colour; play_sound: the sound request queue;            *)
(*    fadeout_music: the music ids, sHasStartedFadeOut, gSequencePlayers, *)
(*    D_80360928) -- and Mario's m->invincTimer (offset 38, 2 bytes).     *)
(*    Memory may grow (callee frames), new blocks are freed (Q2).         *)
(*    Walked by CapAudio's generic walker, extended by the one Mario      *)
(*    field store (the afi_ lemmas).                                      *)
(*                                                                        *)
(* 2. THE WARP CELLS (ltw_cells, op DEATH or WARP_FLOOR): if a warp was   *)
(*    already pending (sDelayedWarpOp <> 0) memory is unchanged; else     *)
(*    afterwards sDelayedWarpOp is the op or GAME_OVER (0x14) and          *)
(*    sSourceWarpNodeId is WARP_NODE_DEATH (0xF1) or WARP_NODE_WARP_FLOOR *)
(*    (0xF3).  Walked by hand through the selected switch arm.            *)
(*                                                                        *)
(* 3. warp_w KEPT (ltw_warp_w): with 1 and 2, FfWorld.warp_w (incl. its   *)
(*    fifth clause: the pending op is no credits op 0x17 / 0x18) holds    *)
(*    after the call.                                                     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require audio_external sound_init level_update area mario.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface
  FloorsSurface MathBodies BullyBodies LinkedTwelve MtxfBody SaveFileBody
  ObjHelpersBodies ObjExtBodies AudioBodies.
From SM64.Proofs Require Import FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame LsContract CapAudio.
From SM64.Proofs.WMotRRequiresA Require RenderAnim LevelWarp FfWorld.

Import ListNotations.

Module AX := audio_external.
Module SI := sound_init.
Module LU := level_update.
Module AR := area.

(* ---------------------------------------------------------------------- *)
(* 1. The footprint lists.                                                *)
(* ---------------------------------------------------------------------- *)

(* the globals level_trigger_warp's callees store *)
Definition ltw_cids : list ident :=
  [AR._gWarpTransition; AR._gWarpTransFBSetColor; AR._gWarpTransRed; AR._gWarpTransGreen;
   AR._gWarpTransBlue; AX._sSoundRequests; AX._sSoundRequestCount; SI._sCurrentMusic;
   SI._sCurrentShellMusic; SI._sCurrentCapMusic; AX._sHasStartedFadeOut;
   AX._gSequencePlayers; AX._D_80360928].

(* the two warp cells warp_w reads, and the other statics the body stores *)
Definition ltw_rest : list ident :=
  [LU._sDelayedWarpArg; LU._sDelayedWarpTimer; LU._gSavedCourseNum] ++ ltw_cids.
Definition ltw_ws : list ident := [LU._sDelayedWarpOp; LU._sSourceWarpNodeId] ++ ltw_rest.

(* ---------------------------------------------------------------------- *)
(* 2. The callees' frames (CapAudio's walker at ltw_cids).                *)
(* ---------------------------------------------------------------------- *)

Section Callees.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  Let afp := af_pres lp ltw_cids.
  Let LOx := linked12_LO_audio_external lp H12.
  Let LOs := linked12_LO_sound_init lp H12.
  Let LOa := linked12_LO_area lp H12.
  Let LOl := linked12_LO_lvl lp H12.

  Ltac ids_af :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg; cbn [mem_id existsb] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  Ltac af_sym q LO f gt ids :=
    refine (af_of_body lp ltw_cids q _ f LO _ _);
    [ vm_compute; reflexivity
    | apply (af_body lp ltw_cids gt ids f); [ vm_compute; reflexivity | ids_af ] ].

  Lemma lf_rgb : afp AR._set_warp_transition_rgb.
  Proof. af_sym AR.prog LOa AR.f_set_warp_transition_rgb (@nil (ident * ident)) (@nil ident). Qed.
  Lemma lf_pt : afp AR._play_transition.
  Proof.
    pose proof lf_rgb.
    af_sym AR.prog LOa AR.f_play_transition (@nil (ident * ident)) [AR._set_warp_transition_rgb].
  Qed.
  Lemma lf_agwn : afp AR._area_get_warp_node.
  Proof. af_sym AR.prog LOa AR.f_area_get_warp_node (@nil (ident * ident)) (@nil ident). Qed.
  Lemma lf_ps : afp AX._play_sound.
  Proof. af_sym AX.prog LOx AX.f_play_sound (@nil (ident * ident)) (@nil ident). Qed.
  Lemma lf_gcbm : afp AX._get_current_background_music.
  Proof. af_sym AX.prog LOx AX.f_get_current_background_music (@nil (ident * ident)) (@nil ident). Qed.
  Lemma lf_mctw : afp LU._music_changed_through_warp.
  Proof.
    pose proof lf_agwn. pose proof lf_gcbm.
    af_sym LU.prog LOl LU.f_music_changed_through_warp (@nil (ident * ident))
      [AR._area_get_warp_node; AX._get_current_background_music].
  Qed.
  Lemma lf_fade_to_zero : afp AX._seq_player_fade_to_zero_volume.
  Proof. af_sym AX.prog LOx AX.f_seq_player_fade_to_zero_volume gt_sp (@nil ident). Qed.
  Lemma lf_fcvs : afp AX._fade_channel_volume_scale.
  Proof. af_sym AX.prog LOx AX.f_fade_channel_volume_scale gt_fcvs (@nil ident). Qed.
  Lemma lf_803210D4 : afp AX._func_803210D4.
  Proof.
    pose proof lf_fcvs. pose proof lf_fade_to_zero.
    af_sym AX.prog LOx AX.f_func_803210D4 (@nil (ident * ident))
      [AX._fade_channel_volume_scale; AX._seq_player_fade_to_zero_volume].
  Qed.
  Lemma lf_fadeout_music : afp SI._fadeout_music.
  Proof.
    pose proof lf_803210D4.
    af_sym SI.prog LOs SI.f_fadeout_music (@nil (ident * ident)) [AX._func_803210D4].
  Qed.

  (* the five callees of level_trigger_warp *)
  Definition ltw_callees : list ident :=
    [AR._play_transition; AX._play_sound; SI._fadeout_music; AR._area_get_warp_node;
     LU._music_changed_through_warp].

  Lemma ltw_callees_af : forall g, mem_id g ltw_callees = true -> afp g.
  Proof.
    pose proof lf_pt. pose proof lf_ps. pose proof lf_fadeout_music. pose proof lf_agwn.
    pose proof lf_mctw. ids_af.
  Qed.
End Callees.

(* ---------------------------------------------------------------------- *)
(* 3. The walker with Mario's m->invincTimer store.                       *)
(* ---------------------------------------------------------------------- *)

Definition OFS_INV : Z := 38.

Lemma inv_fo : mario_fo mario._MarioState mario._invincTimer = Some (OFS_INV, Full).
Proof. vm_compute. reflexivity. Qed.

(* `m->invincTimer` through the never-reassigned parameter m *)
Definition inv_lv (lv : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) (Tstruct sid (mk_attr false None))) f
      (Tint I16 Signed (mk_attr false None)) =>
      Pos.eqb x LU._m && Pos.eqb sid mario._MarioState && Pos.eqb f mario._invincTimer
  | _ => false
  end.

Section AFI.
  Variable lp : Clight.program.
  Hypothesis LO : linkorder mario.prog lp.
  Variable ws : list ident.
  Variable bm : block.

  (* the bytes a call keeps: outside ws' blocks and Mario's invincTimer *)
  Definition aki (b : block) (z : Z) : Prop :=
    ~ gblk (lp_ge lp) ws b /\ ~ (b = bm /\ OFS_INV <= z < OFS_INV + 2).

  Definition afi_P (gt : list (ident * ident)) (le : temp_env) : Prop :=
    au_P lp gt le /\ le ! LU._m = Some (Vptr bm Ptrofs.zero).

  Definition afi_set_ok (gt : list (ident * ident)) (id : ident) (a : expr) : bool :=
    negb (Pos.eqb id LU._m) && au_set_ok gt id a.

  Definition afi_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
    af_store_ok ws gt lv rhs || inv_lv lv.

  Definition afi_call_ok (gt : list (ident * ident)) (ids : list ident)
      (optid : option ident) (a : expr) (al : list expr) : bool :=
    au_call_ok gt ids optid a al
    && match optid with Some t => negb (Pos.eqb t LU._m) | None => true end.

  Lemma aki_ak : forall b z, aki b z -> ak lp ws b z.
  Proof. intros b z (H & _). exact H. Qed.

  Lemma afi_set : forall gt id a le m v,
      afi_set_ok gt id a = true -> afi_P gt le ->
      eval_expr (lp_ge lp) empty_env le m a v -> afi_P gt (PTree.set id v le).
  Proof.
    intros gt id a le m v Hok (HP & Hm) Hev. unfold afi_set_ok in Hok.
    apply andb_prop in Hok as [Hn Hok]. split.
    - eapply af_set; eassumption.
    - destruct (peq LU._m id) as [E | Hne].
      + rewrite E, Pos.eqb_refl in Hn. discriminate Hn.
      + rewrite PTree.gso by exact Hne. exact Hm.
  Qed.

  Lemma afi_store : forall gt lv rhs le m t le' m' out,
      afi_store_ok gt lv rhs = true -> afi_P gt le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      Q2 aki m m'.
  Proof.
    intros gt lv rhs le m t le' m' out Hok (HP & Hm) Hx.
    unfold afi_store_ok in Hok. apply orb_true_iff in Hok as [Ha | Hc].
    - exact (Q2_mono _ _ m m' aki_ak (af_store lp ws gt lv rhs le m t le' m' out Ha HP Hx)).
    - unfold inv_lv in Hc.
      repeat match type of Hc with
      | match ?x with _ => _ end = true => destruct x; try discriminate Hc
      end.
      repeat rewrite andb_true_iff in Hc. destruct Hc as ((E1 & E2) & E3).
      apply Pos.eqb_eq in E1, E2, E3. subst.
      inv Hx.
      match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
      destruct (lv_field lp LO _ _ _ _ _ _ _ _ _ _ L1 eq_refl inv_fo) as (o0 & E0 & -> & Hbf).
      cbn [fst snd] in Hbf. subst.
      destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
      apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
      rewrite Hm in L0. injection L0 as <- <-.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
        match goal with Hm' : access_mode _ = _ |- _ => cbn in Hm'; try discriminate Hm' end.
      match goal with Hm' : By_value _ = By_value _ |- _ => injection Hm' as Hch; subst end.
      match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
      cbn [Mem.storev] in Hst. rewrite Ptrofs.add_zero_l in Hst.
      change (Ptrofs.unsigned (Ptrofs.repr OFS_INV)) with OFS_INV in Hst.
      apply (st_q2 _ _ _ _ _ _ _ Hst).
      intros j Hj (_ & Hn). apply Hn. split; [reflexivity |]. cbn [size_chunk] in Hj. exact Hj.
  Qed.

  Lemma afi_call : forall gt ids,
      (forall g, mem_id g ids = true -> af_pres lp ws g) ->
      forall optid a al le m t le' m' out,
        afi_call_ok gt ids optid a al = true -> afi_P gt le ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
        Q2 aki m m' /\ afi_P gt le'.
  Proof.
    intros gt ids Hids optid a al le m t le' m' out Hok (HP & Hm) Hx.
    unfold afi_call_ok in Hok. apply andb_prop in Hok as [Hok Ho].
    destruct (af_call lp ws gt ids Hids optid a al le m t le' m' out Hok HP Hx) as (Hq & HP').
    split; [ exact (Q2_mono _ _ m m' aki_ak Hq) | split; [ exact HP' | ] ].
    inv Hx. destruct optid as [ti|]; cbn [set_opttemp]; [ | exact Hm ].
    destruct (peq LU._m ti) as [E | Hne].
    - rewrite E, Pos.eqb_refl in Ho. discriminate Ho.
    - rewrite PTree.gso by exact Hne. exact Hm.
  Qed.

  (* a walked statement *)
  Lemma afi_walk : forall gt ids,
      (forall g, mem_id g ids = true -> af_pres lp ws g) ->
      forall s le m t le' m' out,
        lw_chk (afi_set_ok gt) (afi_store_ok gt) (afi_call_ok gt ids) s = true ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m s t le' m' out ->
        afi_P gt le -> Q2 aki m m' /\ afi_P gt le'.
  Proof.
    intros gt ids Hids s le m t le' m' out Hchk Hx HP.
    refine (lw_walk (lp_ge lp) empty_env (Q2 aki m) (afi_P gt) (afi_set_ok gt) (afi_store_ok gt)
              (afi_call_ok gt ids) _ _ _ _ _ _ _ _ _ _ _ Hx eq_refl Hchk HP (Q2_refl aki m)).
    - intros id a le0 m1 v Hok HP0 _ Hev. exact (afi_set gt id a le0 m1 v Hok HP0 Hev).
    - intros lv rhs le0 m1 t0 le1 m2 out0 Hok HP0 Hx0 Hq.
      exact (Q2_trans aki _ _ _ Hq (afi_store gt lv rhs le0 m1 t0 le1 m2 out0 Hok HP0 Hx0)).
    - intros optid a al le0 m1 t0 le1 m2 out0 Hok HP0 Hx0 Hq.
      destruct (afi_call gt ids Hids optid a al le0 m1 t0 le1 m2 out0 Hok HP0 Hx0) as (Hq' & HP').
      exact (conj (Q2_trans aki _ _ _ Hq Hq') HP').
  Qed.
End AFI.

(* ---------------------------------------------------------------------- *)
(* 4. The footprint of a call.                                            *)
(* ---------------------------------------------------------------------- *)

Section Frame.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Let LOm := linked12_LO_mario lp H12.

  (* the callees' frames, at any list containing ltw_cids *)
  Lemma callees_af : forall ws, (forall g, In g ltw_cids -> In g ws) ->
    forall g, mem_id g ltw_callees = true -> af_pres lp ws g.
  Proof.
    intros ws Hin g Hg b fd Hs Hf m1 vargs t1 m2 vr Hfc.
    refine (Q2_mono _ _ m1 m2 _ (ltw_callees_af lp H12 g Hg b fd Hs Hf m1 vargs t1 m2 vr Hfc)).
    intros b0 z Hk (g0 & Ig & Hg0). apply Hk. exists g0. exact (conj (Hin g0 Ig) Hg0).
  Qed.

  Lemma cids_rest : forall g, In g ltw_cids -> In g ltw_rest.
  Proof. intros g H. unfold ltw_rest. apply in_or_app. right. exact H. Qed.
  Lemma cids_ws : forall g, In g ltw_cids -> In g ltw_ws.
  Proof. intros g H. unfold ltw_ws. apply in_or_app. right. exact (cids_rest g H). Qed.

  Lemma ltw_le0 : forall w le1,
    bind_parameter_temps (fn_params LU.f_level_trigger_warp) [Vptr bm Ptrofs.zero; w]
      (create_undef_temps (fn_temps LU.f_level_trigger_warp)) = Some le1 ->
    le1 ! LU._m = Some (Vptr bm Ptrofs.zero) /\ le1 ! LU._warpOp = Some w.
  Proof.
    intros w le1 Hb. cbn in Hb. injection Hb as <-. split; reflexivity.
  Qed.

  Lemma afiP : forall le, le ! LU._m = Some (Vptr bm Ptrofs.zero) -> afi_P lp bm nil le.
  Proof. intros le H. split; [ intros t0 g b o Ht; discriminate Ht | exact H ]. Qed.

  (* THE FOOTPRINT *)
  Theorem ltw_frame : forall m w t m' vres,
    eval_funcall function_entry2 (lp_ge lp) m (Internal LU.f_level_trigger_warp)
      [Vptr bm Ptrofs.zero; w] t m' vres ->
    Q2 (aki lp ltw_ws bm) m m'.
  Proof.
    intros m w t m' vres Hev.
    pose proof (callees_af ltw_ws cids_ws) as Hc'.
    refine (lw_body_frame (lp_ge lp) (Q2 (aki lp ltw_ws bm) m) LU.f_level_trigger_warp
              (afi_P lp bm nil) (afi_set_ok nil) (afi_store_ok ltw_ws nil)
              (afi_call_ok nil ltw_callees) eq_refl ltac:(vm_compute; reflexivity)
              _ _ _ m _ t m' vres Hev _ (Q2_refl _ m)).
    - intros id a le m1 v Hok HP _ Hx. exact (afi_set lp bm nil id a le m1 v Hok HP Hx).
    - intros lv rhs le m1 t0 le' m2 out Hok HP Hx Hq.
      exact (Q2_trans _ _ _ _ Hq (afi_store lp LOm ltw_ws bm nil lv rhs le m1 t0 le' m2 out Hok HP Hx)).
    - intros optid a al le m1 t0 le' m2 out Hok HP Hx Hq.
      destruct (afi_call lp ltw_ws bm nil ltw_callees Hc' optid a al le m1 t0 le' m2 out Hok HP Hx)
        as (Hq' & HP').
      exact (conj (Q2_trans _ _ _ _ Hq Hq') HP').
    - intros le1 Hb. exact (afiP le1 (proj1 (ltw_le0 w le1 Hb))).
  Qed.
End Frame.

(* ---------------------------------------------------------------------- *)
(* 5. The warp cells, for DEATH and WARP_FLOOR.                           *)
(* ---------------------------------------------------------------------- *)

Lemma sb_eq_s : forall (ce : composite_env) a b m,
  sem_binary_operation ce Oeq (Vint a) tshort (Vint b) tint m = Some (Val.of_bool (Int.eq a b)).
Proof. reflexivity. Qed.

Lemma bv_ob : forall c m b, bool_val (Val.of_bool c) tint m = Some b -> b = c.
Proof. intros [|] m b H; cbn in H; injection H as <-; reflexivity. Qed.

Ltac mget := repeat rewrite PTree.gso by RenderAnim.neq; assumption.

Section Cells.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bo bs : block).
  Notation G := (lp_ge lp).
  Notation xs := (exec_stmt function_entry2 G empty_env).
  Hypothesis Hbm : Genv.find_symbol G LU._gMarioStates = Some bm.
  Hypothesis Hbo : Genv.find_symbol G LU._sDelayedWarpOp = Some bo.
  Hypothesis Hbs : Genv.find_symbol G LU._sSourceWarpNodeId = Some bs.
  Let LOm := linked12_LO_mario lp H12.
  Let RA := callees_af lp H12 ltw_rest cids_rest.

  Definition op_ok (m : mem) : Prop :=
    exists n, Mem.load Mint16signed m bo 0 = Some (Vint (Int.repr n)) /\ In n [18; 19; 20].
  Definition node_ok (m : mem) : Prop :=
    exists n, Mem.load Mint16signed m bs 0 = Some (Vint (Int.repr n)) /\ In n [241; 243].

  Lemma bs_bo : bs <> bo.
  Proof. refine (Genv.global_addresses_distinct G _ Hbs Hbo). RenderAnim.neq. Qed.
  Lemma bo_bs : bo <> bs.
  Proof. refine (Genv.global_addresses_distinct G _ Hbo Hbs). RenderAnim.neq. Qed.

  (* a global store *)
  Lemma gst : forall le m id ty rhs t le' m' out b ch,
    Genv.find_symbol G id = Some b -> access_mode ty = By_value ch ->
    xs le m (Sassign (Evar id ty) rhs) t le' m' out ->
    exists v2 v, eval_expr G empty_env le m rhs v2 /\ sem_cast v2 (typeof rhs) ty m = Some v
      /\ Mem.store ch m b 0 v = Some m' /\ le' = le.
  Proof.
    intros le m id ty rhs t le' m' out b ch Hs Ham Hx.
    apply RenderAnim.assign_inv in Hx as (b' & o & bf & v2 & v & Hl & He & Hc & Ha & -> & _).
    apply RenderAnim.lv_gvar in Hl as (Hs' & -> & ->); [| apply PTree.gempty].
    rewrite Hs in Hs'. injection Hs' as <-.
    apply (RenderAnim.store_by_value _ _ _ _ _ _ _ _ _ Ham eq_refl) in Ha.
    change (Ptrofs.unsigned Ptrofs.zero) with 0 in Ha.
    exists v2, v. cbn [typeof] in Hc. auto.
  Qed.

  (* a constant into an s16 global *)
  Lemma gst_c : forall le m id k t le' m' out b,
    Genv.find_symbol G id = Some b ->
    xs le m (Sassign (Evar id tshort) (Econst_int k tint)) t le' m' out ->
    Mem.store Mint16signed m b 0 (Vint (Int.sign_ext 16 k)) = Some m' /\ le' = le.
  Proof.
    intros le m id k t le' m' out b Hs Hx.
    destruct (gst _ _ _ tshort _ _ _ _ _ _ Mint16signed Hs eq_refl Hx) as (v2 & v & Ev & Cv & Sv & ->).
    apply RenderAnim.ev_const in Ev. subst v2. cbn [typeof] in Cv.
    rewrite RenderAnim.cast_i_s in Cv. injection Cv as <-. auto.
  Qed.

  Lemma st_other : forall ch m1 b z v m2 b' ch', Mem.store ch m1 b z v = Some m2 -> b <> b' ->
    Mem.load ch' m2 b' 0 = Mem.load ch' m1 b' 0.
  Proof.
    intros ch m1 b z v m2 b' ch' Hs Hne. eapply Mem.load_store_other; [ exact Hs |].
    left. intro E. apply Hne. symmetry. exact E.
  Qed.

  (* a walked statement keeps the two cells *)
  Lemma rk_keep : forall id b ch m1 m2, Genv.find_symbol G id = Some b ->
    mem_id id ltw_rest = false -> id <> LU._gMarioStates ->
    Q2 (aki lp ltw_rest bm) m1 m2 -> Mem.load ch m2 b 0 = Mem.load ch m1 b 0.
  Proof.
    intros id b ch m1 m2 Hs Hn Hne HQ. apply (Q2_load _ m1 m2 HQ). intros i _. split.
    - intros (g & Ig & Hg). destruct (peq id g) as [<- | Ne].
      + assert (T : mem_id id ltw_rest = true).
        { unfold mem_id. apply existsb_exists. exists id. split; [ exact Ig | apply Pos.eqb_refl ]. }
        congruence.
      + exact (Genv.global_addresses_distinct G Ne Hs Hg eq_refl).
    - intros (E & _). subst b. exact (Genv.global_addresses_distinct G Hne Hs Hbm eq_refl).
  Qed.

  Lemma op_keep : forall m1 m2, Q2 (aki lp ltw_rest bm) m1 m2 -> op_ok m1 -> op_ok m2.
  Proof.
    intros m1 m2 HQ (n & L & I). exists n.
    rewrite (rk_keep _ _ _ _ _ Hbo ltac:(vm_compute; reflexivity) ltac:(RenderAnim.neq) HQ). auto.
  Qed.
  Lemma node_keep : forall m1 m2, Q2 (aki lp ltw_rest bm) m1 m2 -> node_ok m1 -> node_ok m2.
  Proof.
    intros m1 m2 HQ (n & L & I). exists n.
    rewrite (rk_keep _ _ _ _ _ Hbs ltac:(vm_compute; reflexivity) ltac:(RenderAnim.neq) HQ). auto.
  Qed.

  Ltac wk H Hm Q Hm' :=
    lazymatch type of H with exec_stmt _ _ _ ?L ?M ?S _ ?L' ?M' _ =>
      destruct (afi_walk lp LOm ltw_rest bm nil ltw_callees RA S L M _ L' M' _
                  ltac:(vm_compute; reflexivity) H (afiP lp bm L Hm)) as (Q & (_ & Hm')) end.

  Ltac asg H :=
    let H' := fresh in pose proof H as H';
    apply RenderAnim.assign_inv in H' as (? & ? & ? & ? & ? & _ & _ & _ & _ & ? & _); subst.

  Ltac plain H a b c d H1 :=
    apply LevelWarp.seq_plain in H; [ | reflexivity ]; destruct H as (a & b & c & d & H1 & H).

  (* THE WARP CELLS *)
  Theorem ltw_cells : forall m w t m' vres, (w = Int.repr 18 \/ w = Int.repr 19) ->
    eval_funcall function_entry2 G m (Internal LU.f_level_trigger_warp)
      [Vptr bm Ptrofs.zero; Vint w] t m' vres ->
    exists i, Mem.load Mint16signed m bo 0 = Some (Vint i)
      /\ (i <> Int.zero -> m' = m) /\ (i = Int.zero -> op_ok m' /\ node_ok m').
  Proof.
    intros m w t m' vres Hw Hev.
    destruct (LevelWarp.fun_entry G LU.f_level_trigger_warp m _ t m' vres eq_refl Hev) as (le0 & le & out & Hb & Hx).
    destruct (ltw_le0 bm (Vint w) le0 Hb) as (Hm0 & Hw0).
    clear Hb Hev.
    unfold LU.f_level_trigger_warp in Hx. cbn [fn_body] in Hx.
    (* val04 = TRUE *)
    plain Hx t1 le1 m1 t2 H1.
    apply RenderAnim.set_inv in H1 as (v1 & _ & -> & -> & _).
    (* the guarded block; the return reads only *)
    lazymatch type of Hx with exec_stmt _ _ _ ?L ?M (Ssequence ?S _) _ _ ?M' _ =>
      assert (E : exists t3 le3 out3, xs L M S t3 le3 M' out3) end.
    { apply RenderAnim.seq_inv in Hx as [(t3 & le3 & m3 & t4 & H3 & H4) | (H3 & _)]; [ | eauto ].
      plain H4 t5 le5 m5 t6 H5.
      apply RenderAnim.set_inv in H5 as (? & _ & -> & -> & _).
      apply RenderAnim.ret_inv in H4 as (-> & _). eauto. }
    clear Hx. destruct E as (t3 & le3 & out3 & Hx).
    (* t'7 = sDelayedWarpOp; if (t'7 == 0) *)
    plain Hx t4 le4 m4 t5 H4.
    apply RenderAnim.set_inv in H4 as (v7 & E7 & -> & -> & _).
    apply (RenderAnim.ev_gvar G empty_env m _ _ tshort _ Mint16signed (PTree.gempty _ _) eq_refl) in E7.
    destruct E7 as (b7 & Hs7 & L7). rewrite Hbo in Hs7. injection Hs7 as <-.
    cbn [Mem.loadv] in L7. change (Ptrofs.unsigned Ptrofs.zero) with 0 in L7.
    apply RenderAnim.if_inv in Hx as (vc & bc & Ec & Bc & Hx).
    apply RenderAnim.ev_binop in Ec as (va & vb & Ea & Eb & Sc).
    apply RenderAnim.ev_temp in Ea. rewrite PTree.gss in Ea. injection Ea as <-.
    apply RenderAnim.ev_const in Eb. subst vb.
    cbn [typeof] in Sc, Bc.
    destruct v7 as [| i7 | | | | ]; try (vm_compute in Sc; discriminate Sc).
    rewrite sb_eq_s in Sc. injection Sc as <-.
    apply bv_ob in Bc. subst bc.
    exists i7. split; [ exact L7 |].
    revert Hx. destruct (Int.eq i7 (Int.repr 0)) eqn:Ei; intros Hx; cbv beta iota in Hx.
    2: { apply RenderAnim.skip_inv in Hx as (-> & _ & _). split.
         - intros _; reflexivity.
         - intros ->. vm_compute in Ei. discriminate Ei. }
    pose proof (Int.eq_spec i7 (Int.repr 0)) as Z7. rewrite Ei in Z7. subst i7.
    split; [ intros N; exfalso; exact (N eq_refl) |].
    intros _.
    lazymatch type of Hx with exec_stmt _ _ _ ?L _ _ _ _ _ _ =>
      assert (Hm4 : L ! LU._m = Some (Vptr bm Ptrofs.zero)) by mget end.
    (* m->invincTimer = -1; sDelayedWarpArg = 0 *)
    plain Hx t6 le6 m6 t7 H6. asg H6. wk H6 Hm4 Q6 Hm6.
    plain Hx t8 le8 m8 t9 H8. asg H8. wk H8 Hm6 Q8 Hm8.
    (* sDelayedWarpOp = warpOp *)
    plain Hx t10 le10 m10 t11 H10.
    destruct (gst _ _ _ tshort _ _ _ _ _ _ Mint16signed Hbo eq_refl H10) as (vo2 & vo & Eo & Co & So & ->).
    apply RenderAnim.ev_temp in Eo. RenderAnim.getnorm Eo. rewrite Hw0 in Eo. injection Eo as <-.
    cbn [typeof] in Co. rewrite RenderAnim.cast_i_s in Co. injection Co as <-.
    (* the switch; the music fade after it keeps the cells *)
    lazymatch type of Hx with exec_stmt _ _ _ ?L ?M (Ssequence ?SW _) _ _ _ _ =>
      assert (SWOK : forall t12 le12 m12 out12, xs L M SW t12 le12 m12 out12 ->
                op_ok m12 /\ node_ok m12 /\ le12 ! LU._m = Some (Vptr bm Ptrofs.zero)) end.
    2: { apply RenderAnim.seq_inv in Hx as [(t12 & le12 & m12 & t13 & H12' & H13) | (H12' & _)].
         - destruct (SWOK _ _ _ _ H12') as (O12 & N12 & Hm12).
           wk H13 Hm12 Q13 Hm13. exact (conj (op_keep _ _ Q13 O12) (node_keep _ _ Q13 N12)).
         - destruct (SWOK _ _ _ _ H12') as (O12 & N12 & _). exact (conj O12 N12). }
    intros t12 le12 m12 out12 H12'.
    apply LevelWarp.switch_inv in H12' as (vs & n & out13 & Es & Ss & Hs).
    apply RenderAnim.ev_temp in Es. RenderAnim.getnorm Es. rewrite Hw0 in Es. injection Es as <-.
    cbn in Ss. injection Ss as <-.
    destruct Hw as [-> | ->].
    - (* WARP_OP_DEATH *)
      lazymatch type of Hs with context [seq_of_labeled_statement (select_switch ?n ?sl)] =>
        let r := eval vm_compute in (seq_of_labeled_statement (select_switch n sl)) in
        change (seq_of_labeled_statement (select_switch n sl)) with r in Hs end.
      apply LevelWarp.seq_brk in Hs as (out14 & Hs); [ | reflexivity ].
      (* if (m->numLives == 0) sDelayedWarpOp = WARP_OP_GAME_OVER *)
      plain Hs t14 leA mA t15 HA.
      assert (OA : op_ok mA /\ leA ! LU._m = Some (Vptr bm Ptrofs.zero)).
      { plain HA t16 leA1 mA1 t17 HA1.
        apply RenderAnim.set_inv in HA1 as (? & _ & -> & -> & _).
        apply RenderAnim.if_inv in HA as (? & bA & _ & _ & HA). destruct bA; cbv beta iota in HA.
        - destruct (gst_c _ _ _ _ _ _ _ _ _ Hbo HA) as (SA & ->).
          split; [ exists 20; split; [ rewrite (Mem.load_store_same _ _ _ _ _ _ SA); vm_compute; reflexivity
                                     | cbn; tauto ] | mget ].
        - apply RenderAnim.skip_inv in HA as (-> & -> & _).
          split; [ exists 18; split; [ rewrite (Mem.load_store_same _ _ _ _ _ _ So); vm_compute; reflexivity
                                     | cbn; tauto ] | mget ]. }
      destruct OA as (OA & HmA).
      (* sDelayedWarpTimer = 48 *)
      plain Hs t18 leT mT t19 HT. asg HT. wk HT HmA QT HmT.
      (* sSourceWarpNodeId = WARP_NODE_DEATH *)
      plain Hs t20 leN mN t21 HN.
      destruct (gst_c _ _ _ _ _ _ _ _ _ Hbs HN) as (SN & ->).
      assert (ON : op_ok mN).
      { destruct (op_keep _ _ QT OA) as (n & L & I). exists n.
        rewrite (st_other _ _ _ _ _ _ _ _ SN bs_bo). exact (conj L I). }
      assert (NN : node_ok mN).
      { exists 241. split; [ rewrite (Mem.load_store_same _ _ _ _ _ _ SN); vm_compute; reflexivity | cbn; tauto ]. }
      (* play_transition; play_sound; break *)
      wk Hs HmT QR HmR.
      exact (conj (op_keep _ _ QR ON) (conj (node_keep _ _ QR NN) HmR)).
    - (* WARP_OP_WARP_FLOOR *)
      lazymatch type of Hs with context [seq_of_labeled_statement (select_switch ?n ?sl)] =>
        let r := eval vm_compute in (seq_of_labeled_statement (select_switch n sl)) in
        change (seq_of_labeled_statement (select_switch n sl)) with r in Hs end.
      apply LevelWarp.seq_brk in Hs as (out14 & Hs); [ | reflexivity ].
      (* sSourceWarpNodeId = WARP_NODE_WARP_FLOOR *)
      plain Hs t14 leN mN t15 HN.
      destruct (gst_c _ _ _ _ _ _ _ _ _ Hbs HN) as (SN & ->).
      assert (ON : op_ok mN).
      { exists 19. split; [ | cbn; tauto ].
        rewrite (st_other _ _ _ _ _ _ _ _ SN bs_bo), (Mem.load_store_same _ _ _ _ _ _ So). vm_compute. reflexivity. }
      assert (NN : node_ok mN).
      { exists 243. split; [ rewrite (Mem.load_store_same _ _ _ _ _ _ SN); vm_compute; reflexivity | cbn; tauto ]. }
      (* if (area_get_warp_node(..) == NULL) { GAME_OVER or WARP_NODE_DEATH } *)
      plain Hs t16 leB mB t17 HB.
      assert (OB : op_ok mB /\ node_ok mB /\ leB ! LU._m = Some (Vptr bm Ptrofs.zero)).
      { plain HB t18 leB1 mB1 t19 HB1.
        wk HB1 Hm8 QB1 HmB1.
        pose proof (op_keep _ _ QB1 ON) as OB1. pose proof (node_keep _ _ QB1 NN) as NB1.
        apply RenderAnim.if_inv in HB as (? & bB & _ & _ & HB). destruct bB; cbv beta iota in HB.
        - plain HB t20 leB2 mB2 t21 HB2.
          apply RenderAnim.set_inv in HB2 as (? & _ & -> & -> & _).
          apply RenderAnim.if_inv in HB as (? & bC & _ & _ & HB). destruct bC; cbv beta iota in HB.
          + destruct (gst_c _ _ _ _ _ _ _ _ _ Hbo HB) as (SC & ->).
            split; [ exists 20; split; [ rewrite (Mem.load_store_same _ _ _ _ _ _ SC); vm_compute; reflexivity
                                       | cbn; tauto ] |].
            split; [ | mget ].
            destruct NB1 as (n & L & I). exists n. rewrite (st_other _ _ _ _ _ _ _ _ SC bo_bs). auto.
          + destruct (gst_c _ _ _ _ _ _ _ _ _ Hbs HB) as (SC & ->).
            split; [ destruct OB1 as (n & L & I); exists n;
                     rewrite (st_other _ _ _ _ _ _ _ _ SC bs_bo); auto |].
            split; [ exists 241; split; [ rewrite (Mem.load_store_same _ _ _ _ _ _ SC); vm_compute; reflexivity
                                        | cbn; tauto ] | mget ].
        - apply RenderAnim.skip_inv in HB as (-> & -> & _). auto. }
      destruct OB as (OB & NB & HmB).
      (* sDelayedWarpTimer = 20; play_transition; break *)
      wk Hs HmB QR HmR.
      exact (conj (op_keep _ _ QR OB) (conj (node_keep _ _ QR NB) HmR)).
  Qed.
End Cells.

(* ---------------------------------------------------------------------- *)
(* 6. warp_w is kept.                                                     *)
(* ---------------------------------------------------------------------- *)

Section Warp.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bo bs : block).
  Notation G := (lp_ge lp).
  Hypothesis Hbm : Genv.find_symbol G LU._gMarioStates = Some bm.
  Hypothesis Hbo : Genv.find_symbol G LU._sDelayedWarpOp = Some bo.
  Hypothesis Hbs : Genv.find_symbol G LU._sSourceWarpNodeId = Some bs.

  (* a global outside ltw_ws keeps its cells *)
  Lemma ws_keep : forall id b ch z m1 m2, Genv.find_symbol G id = Some b ->
    mem_id id ltw_ws = false -> id <> LU._gMarioStates ->
    Q2 (aki lp ltw_ws bm) m1 m2 -> Mem.load ch m2 b z = Mem.load ch m1 b z.
  Proof.
    intros id b ch z m1 m2 Hs Hn Hne HQ. apply (Q2_load _ m1 m2 HQ). intros i _. split.
    - intros (g & Ig & Hg). destruct (peq id g) as [<- | Ne].
      + assert (T : mem_id id ltw_ws = true).
        { unfold mem_id. apply existsb_exists. exists id. split; [ exact Ig | apply Pos.eqb_refl ]. }
        congruence.
      + exact (Genv.global_addresses_distinct G Ne Hs Hg eq_refl).
    - intros (E & _). subst b. exact (Genv.global_addresses_distinct G Hne Hs Hbm eq_refl).
  Qed.

  (* THE CONTRACT the two rows use: DEATH / WARP_FLOOR keep warp_w,
     including "the pending op is no credits op" *)
  Theorem ltw_warp_w : forall m w t m' vres, (w = Int.repr 18 \/ w = Int.repr 19) ->
    eval_funcall function_entry2 G m (Internal LU.f_level_trigger_warp)
      [Vptr bm Ptrofs.zero; Vint w] t m' vres ->
    FfWorld.warp_w G m -> FfWorld.warp_w G m'.
  Proof.
    intros m w t m' vres Hw Hev HW.
    pose proof (ltw_frame lp H12 bm m (Vint w) t m' vres Hev) as HQ.
    destruct (ltw_cells lp H12 bm bo bs Hbm Hbo Hbs m w t m' vres Hw Hev) as (i & Li & Hne & Heq).
    destruct (Int.eq_dec i Int.zero) as [-> | Ni]; [ | rewrite (Hne Ni); exact HW ].
    destruct (Heq eq_refl) as ((n1 & L1 & I1) & (n2 & L2 & I2)).
    destruct HW as (W1 & W2 & W3 & W4 & W5).
    split; [ | split; [ | split; [ | split ] ] ].
    - intros bp bw Hp Hw' Lp.
      rewrite (ws_keep _ _ _ _ _ _ Hw' ltac:(vm_compute; reflexivity) ltac:(RenderAnim.neq) HQ).
      apply (W1 bp bw Hp Hw').
      rewrite <- (ws_keep _ _ _ _ _ _ Hp ltac:(vm_compute; reflexivity) ltac:(RenderAnim.neq) HQ).
      exact Lp.
    - intros b Hb.
      rewrite (ws_keep _ _ _ _ _ _ Hb ltac:(vm_compute; reflexivity) ltac:(RenderAnim.neq) HQ).
      exact (W2 b Hb).
    - intros b Hb.
      rewrite (ws_keep _ _ _ _ _ _ Hb ltac:(vm_compute; reflexivity) ltac:(RenderAnim.neq) HQ).
      exact (W3 b Hb).
    - intros bo' bs' Ho Hs _. rewrite Hbo in Ho. injection Ho as <-.
      rewrite Hbs in Hs. injection Hs as <-.
      exists n2. split; [ exact L2 | cbn in I2 |- *; tauto ].
    - intros bo' Ho n Ln. rewrite Hbo in Ho. injection Ho as <-.
      rewrite L1 in Ln. injection Ln as <-.
      cbn in I1. destruct I1 as [<- | [<- | [<- | []]]];
        split; intro E; apply (f_equal Int.unsigned) in E; vm_compute in E; discriminate E.
  Qed.
End Warp.
