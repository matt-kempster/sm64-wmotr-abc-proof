(* ====================================================================== *)
(* CapAudio (GOAL 2, 2026-10-24): the audio-only footprint of the cap     *)
(* music path, proved from the real external.c / sound_init.c bodies.    *)
(*                                                                        *)
(* STAGED (Unwired): its consumer, NaSplit's row for                      *)
(* mario_update_hitbox_and_cap_model, needs the written globals to be     *)
(* holes ProRows can frame the world around, i.e. blocks no world object  *)
(* (surface, area, controller) can live in.  Promote together with that   *)
(* row and with HeightFrame's Hls strengthened to ls_contract (TRUST 4.1). *)
(*                                                                        *)
(* mario_update_hitbox_and_cap_model -> update_and_return_cap_flags calls *)
(* stop_cap_music (capTimer reaches 0) and fadeout_cap_music (capTimer is *)
(* 60).  Those reach stop_background_music / fadeout_background_music,   *)
(* seq_player_play_sequence, seq_player_fade_out and load_sequence.       *)
(*                                                                        *)
(* 1. THE LOAD_SEQUENCE CONTRACT (ls_contract; TRUST 4.1, the labeled     *)
(*    audio premise Hls).  load_sequence (audio/load.c) is not linked.    *)
(*    The contract is GOAL 1's row (call_pres_ext: the carried facts)     *)
(*    plus its footprint: the call changes only the blocks of ls_ids, the *)
(*    load.c / buffers.c globals that have a block in the model.  Memory  *)
(*    may grow (its frames: load_sequence_internal's defaultBank, bank_   *)
(*    load_immediate's buf), the new blocks are freed (Q2).                *)
(*    Read off the real US code (load.c, heap.c, seqplayer.c, playback.c, *)
(*    synthesis.c; checked 2026-10-24): every store goes to                *)
(*      gAudioLoadLock, gSequencePlayers, gSeqLoadedPool, gBankLoadedPool,*)
(*      gAudioHeap (buffers.c: the pools, the notes, the loaded banks and *)
(*        sequences, all soundAlloc'd from it),                            *)
(*    or to load.c globals no linked TU declares, so no block in this     *)
(*    model: gSequenceChannels, gSequenceLayers, gSeqLoadStatus,          *)
(*    gBankLoadStatus, gCtlEntries, gNoteFreeLists, gLayerFreeList,       *)
(*    gAudioDmaMesgQueue, gAudioDmaIoMesg.  Pointer stores (note lists,   *)
(*    layer and bank-patch pointers) stay inside those, given the audio   *)
(*    driver's own invariants.  The DMA / message calls are libultra      *)
(*    (TRUST 3.5; gAudioDmaMesgQueue is not one of os_dma_floor's queues). *)
(*    Discharge path: link load.c / heap.c / seqplayer.c / playback.c and *)
(*    walk them as below (then the unlinked globals join ls_ids).          *)
(*                                                                        *)
(* 2. THE FRAMES (af_pres): a call of each function on the path changes   *)
(*    only the blocks of cap_ids, by the same lw_chk walk as AudioBodies  *)
(*    (every store's root is a cap_ids global, every call is to a         *)
(*    function already framed), with Q2 as the carried relation.          *)
(*                                                                        *)
(* 3. THE CAP FLAGS CALL (ucf_frame, 2026-10-25): update_and_return_cap_  *)
(*    flags itself, the hitbox body's call, changes only Mario's block    *)
(*    (m->capTimer, m->flags, stored through its MarioState parameter)    *)
(*    and the cap_ids blocks: the walk of 2 extended by stores whose     *)
(*    chain root is the never-reassigned parameter (the afm_ lemmas).     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require audio_external sound_init buffers mario.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface
  FloorsSurface MathBodies BullyBodies LinkedTwelve MtxfBody SaveFileBody
  ObjHelpersBodies ObjExtBodies AudioBodies.
From SM64.Proofs Require EngineV2Consumer.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame.

Import ListNotations.

Module AX := audio_external.
Module SI := sound_init.

(* ---------------------------------------------------------------------- *)
(* 1. The contract.                                                       *)
(* ---------------------------------------------------------------------- *)

(* the blocks of a list of globals *)
Definition gblk (G : genv) (ids : list ident) (b : block) : Prop :=
  exists g, In g ids /\ Genv.find_symbol G g = Some b.

(* load_sequence's written globals with a block in the model (see above) *)
Definition ls_ids : list ident :=
  [AX._gAudioLoadLock; AX._gSequencePlayers; AX._gSeqLoadedPool; AX._gBankLoadedPool;
   buffers._gAudioHeap].

Definition ls_frame (lp : Clight.program) : Prop :=
  forall fd m vargs t m' vres,
    eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
    EngineV2Consumer.resolves_lp lp AX._load_sequence fd ->
    Q2 (fun b _ => ~ gblk (lp_ge lp) ls_ids b) m m'.

(* THE LABELED AUDIO PREMISE (TRUST 4.1): GOAL 1's row and the footprint
   (HeightFrame takes NoA := NoA_real bm) *)
Definition ls_contract (lp : Clight.program) (bm : block) (NoA MWF : mem -> Prop) : Prop :=
  call_pres_ext lp bm NoA MWF AX._load_sequence /\ ls_frame lp.

(* every global the cap music path writes (the frame lemmas' footprint) *)
Definition cap_ids : list ident :=
  [SI._sCurrentCapMusic; AX._sBackgroundMusicQueueSize; AX._sBackgroundMusicQueue;
   AX._sCurrentBackgroundMusicSeqId; AX._sBackgroundMusicForDynamics;
   AX._sCurrentMusicDynamic; AX._sMusicDynamicDelay; AX._D_80360928] ++ ls_ids.

(* ---------------------------------------------------------------------- *)
(* 2. The frame walk.                                                     *)
(* ---------------------------------------------------------------------- *)

Section AF.
  Variable lp : Clight.program.
  Variable ws : list ident.

  Definition ak (b : block) (z : Z) : Prop := ~ gblk (lp_ge lp) ws b.

  Definition af_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
    match au_root gt lv with
    | Some g => mem_id g ws && MtxfBody.is_byval (typeof lv)
    | None => false
    end.

  Definition af_chk (gt : list (ident * ident)) (ids : list ident) (f : Clight.function) : bool :=
    match fn_vars f with nil => true | _ => false end
    && au_params_ok gt f
    && lw_chk (au_set_ok gt) (af_store_ok gt) (au_call_ok gt ids) (fn_body f).

  Definition af_pres (g : ident) : Prop :=
    forall b fd, Genv.find_symbol (lp_ge lp) g = Some b ->
      Genv.find_funct_ptr (lp_ge lp) b = Some fd ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres -> Q2 ak m m'.

  Lemma af_set : forall gt id a le m v,
      au_set_ok gt id a = true -> au_P lp gt le ->
      eval_expr (lp_ge lp) empty_env le m a v -> au_P lp gt (PTree.set id v le).
  Proof.
    intros gt id a le m v Hok HP Hev t g b o Ht Hle.
    destruct (peq t id) as [-> | Hne].
    - rewrite PTree.gss in Hle. injection Hle as ->.
      unfold au_set_ok in Hok. rewrite Ht in Hok.
      destruct (groot_e a) as [g'|] eqn:Hg; [ | discriminate Hok ].
      apply Pos.eqb_eq in Hok. subst g'.
      destruct (groot_e_val _ _ _ _ _ _ Hg Hev) as (b' & o' & E & Hs).
      injection E as -> ->. exact Hs.
    - rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
  Qed.

  Lemma af_store : forall gt lv rhs le m t le' m' out,
      af_store_ok gt lv rhs = true -> au_P lp gt le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      Q2 ak m m'.
  Proof.
    intros gt lv rhs le m t le' m' out Hok HP Hx.
    unfold af_store_ok in Hok.
    destruct (au_root gt lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hm _].
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
      pose proof (au_root_blk lp gt lv _ _ _ _ _ g Hg HP Hl) as Hfs end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      refine (al_q2 ak _ _ _ _ _ _ _ _ Ha _) end.
    intros i Hk. apply Hk. exists g. split; [ | exact Hfs ].
    unfold mem_id in Hm. apply existsb_exists in Hm as (x & Ix & Ex).
    apply Pos.eqb_eq in Ex. subst x. exact Ix.
  Qed.

  Lemma af_call : forall gt ids,
      (forall g, mem_id g ids = true -> af_pres g) ->
      forall optid a al le m t le' m' out,
        au_call_ok gt ids optid a al = true -> au_P lp gt le ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
        Q2 ak m m' /\ au_P lp gt le'.
  Proof.
    intros gt ids Hids optid a al le m t le' m' out Hok HP Hx.
    unfold au_call_ok in Hok. apply andb_prop in Hok as [Hc Ho].
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hc.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hc.
    cbn [ObjExtBodies.gcall_ok] in Hc.
    inv Hx.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
      rewrite Genv.find_funct_find_funct_ptr in Hff end.
    split.
    - match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
        exact (Hids fid Hc lf fd Hsy Hfp _ _ _ _ _ Hfc) end.
    - destruct optid as [ti|]; cbn [set_opttemp]; [ | exact HP ].
      intros t0 g b o Ht Hle.
      destruct (peq t0 ti) as [-> | Hne].
      + rewrite Ht in Ho. discriminate Ho.
      + rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
  Qed.

  Lemma af_body : forall gt ids f,
      af_chk gt ids f = true ->
      (forall g, mem_id g ids = true -> af_pres g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        Q2 ak m m'.
  Proof.
    intros gt ids f Hchk Hids m vargs t m' vres Hevf.
    unfold af_chk in Hchk.
    apply andb_prop in Hchk as [Hchk Hw]. apply andb_prop in Hchk as [Hv Hpar].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    refine (lw_body_frame (lp_ge lp) (Q2 ak m) f (au_P lp gt) (au_set_ok gt) (af_store_ok gt)
              (au_call_ok gt ids) Hvars Hw _ _ _ _ _ _ _ _ Hevf _ (Q2_refl ak m)).
    - intros id a le m1 v Hok HP _ Hev. exact (af_set gt id a le m1 v Hok HP Hev).
    - intros lv rhs le m1 t0 le' m2 out Hok HP Hx Hq.
      exact (Q2_trans ak _ _ _ Hq (af_store gt lv rhs le m1 t0 le' m2 out Hok HP Hx)).
    - intros optid a al le m1 t0 le' m2 out Hok HP Hx Hq.
      destruct (af_call gt ids Hids optid a al le m1 t0 le' m2 out Hok HP Hx) as (Hq' & HP').
      exact (conj (Q2_trans ak _ _ _ Hq Hq') HP').
    - intros le1 Hb t0 g b o Ht Hle.
      rewrite (bind_notin _ _ _ _ _ Hb (au_params_notin _ _ _ _ Hpar Ht)) in Hle.
      apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  Qed.

  Lemma af_of_body : forall (q : Clight.program) g f,
      linkorder q lp ->
      (prog_defmap q) ! g = Some (Gfun (Internal f)) ->
      (forall m vargs t m' vres,
         eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres -> Q2 ak m m') ->
      af_pres g.
  Proof.
    intros q g f LO Hdm Hb b fd Hs Hfp.
    destruct (linkorder_resolves_funct lp _ g f LO Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hfp. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. rewrite Hfp in Hf'.
    injection Hf' as ->. exact Hb.
  Qed.
End AF.

(* ---------------------------------------------------------------------- *)
(* 3. The cap music path.                                                 *)
(* ---------------------------------------------------------------------- *)

Section Cap.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hlsf : ls_frame lp.

  Let afp := af_pres lp cap_ids.
  Let LOx := linked12_LO_audio_external lp H12.
  Let LOs := linked12_LO_sound_init lp H12.

  Ltac ids_af :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg; cbn [mem_id existsb] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  Ltac af_sym q LO f gt ids :=
    refine (af_of_body lp cap_ids q _ f LO _ _);
    [ vm_compute; reflexivity
    | apply (af_body lp cap_ids gt ids f); [ vm_compute; reflexivity | ids_af ] ].

  (* load_sequence, from the contract's footprint *)
  Lemma af_ls : afp AX._load_sequence.
  Proof.
    intros b fd Hs Hfp m vargs t m' vres Hevf.
    assert (Hres : EngineV2Consumer.resolves_lp lp AX._load_sequence fd).
    { exists b. split; [ exact Hs | rewrite Genv.find_funct_find_funct_ptr; exact Hfp ]. }
    refine (Q2_mono _ _ m m' _ (Hlsf fd m vargs t m' vres Hevf Hres)).
    intros b0 z Hk (g & Ig & Hg). apply Hk. exists g. split; [ | exact Hg ].
    unfold cap_ids. apply in_or_app. right. exact Ig.
  Qed.

  Lemma af_fade_to_zero : afp AX._seq_player_fade_to_zero_volume.
  Proof. af_sym AX.prog LOx AX.f_seq_player_fade_to_zero_volume gt_sp (@nil ident). Qed.
  Lemma af_8031D690 : afp AX._func_8031D690.
  Proof. af_sym AX.prog LOx AX.f_func_8031D690 gt_sp (@nil ident). Qed.
  Lemma af_fade_to_normal : afp AX._seq_player_fade_to_normal_volume.
  Proof. af_sym AX.prog LOx AX.f_seq_player_fade_to_normal_volume gt_sp (@nil ident). Qed.
  Lemma af_fade_to_target : afp AX._seq_player_fade_to_target_volume.
  Proof. af_sym AX.prog LOx AX.f_seq_player_fade_to_target_volume gt_sp (@nil ident). Qed.

  Lemma af_fade_out : afp AX._seq_player_fade_out.
  Proof.
    pose proof af_fade_to_zero.
    af_sym AX.prog LOx AX.f_seq_player_fade_out (@nil (ident * ident))
      [AX._seq_player_fade_to_zero_volume].
  Qed.
  Lemma af_bbmf : afp AX._begin_background_music_fade.
  Proof.
    pose proof af_fade_to_normal. pose proof af_fade_to_target.
    af_sym AX.prog LOx AX.f_begin_background_music_fade (@nil (ident * ident))
      [AX._seq_player_fade_to_normal_volume; AX._seq_player_fade_to_target_volume].
  Qed.
  Lemma af_play_seq : afp AX._seq_player_play_sequence.
  Proof.
    pose proof af_bbmf. pose proof af_8031D690. pose proof af_ls.
    af_sym AX.prog LOx AX.f_seq_player_play_sequence (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._func_8031D690; AX._load_sequence].
  Qed.
  Lemma af_stop_bgm : afp AX._stop_background_music.
  Proof.
    pose proof af_fade_out. pose proof af_play_seq.
    af_sym AX.prog LOx AX.f_stop_background_music (@nil (ident * ident))
      [AX._seq_player_fade_out; AX._seq_player_play_sequence].
  Qed.
  Lemma af_fadeout_bgm : afp AX._fadeout_background_music.
  Proof.
    pose proof af_fade_out.
    af_sym AX.prog LOx AX.f_fadeout_background_music (@nil (ident * ident))
      [AX._seq_player_fade_out].
  Qed.

  (* the two calls update_and_return_cap_flags makes *)
  Lemma af_stop_cap_music : afp SI._stop_cap_music.
  Proof.
    pose proof af_stop_bgm.
    af_sym SI.prog LOs SI.f_stop_cap_music (@nil (ident * ident)) [AX._stop_background_music].
  Qed.
  Lemma af_fadeout_cap_music : afp SI._fadeout_cap_music.
  Proof.
    pose proof af_fadeout_bgm.
    af_sym SI.prog LOs SI.f_fadeout_cap_music (@nil (ident * ident))
      [AX._fadeout_background_music].
  Qed.
End Cap.

(* ---------------------------------------------------------------------- *)
(* 4. Frames with Mario's block: a body that also stores through its      *)
(*    MarioState parameter (mt, holding &gMarioStates[0] = bm, never      *)
(*    reassigned) changes only bm and the blocks of ws.                   *)
(* ---------------------------------------------------------------------- *)

Section AFM.
  Variable lp : Clight.program.
  Variable ws : list ident.
  Variable bm : block.
  Variable mt : ident.

  Definition akm (b : block) (z : Z) : Prop := ~ gblk (lp_ge lp) ws b /\ b <> bm.

  Definition afm_P (gt : list (ident * ident)) (le : temp_env) : Prop :=
    au_P lp gt le /\ forall b o, le ! mt = Some (Vptr b o) -> b = bm.

  Definition afm_set_ok (gt : list (ident * ident)) (id : ident) (a : expr) : bool :=
    negb (Pos.eqb id mt) && au_set_ok gt id a.

  Definition afm_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
    af_store_ok ws gt lv rhs
    || match chain_root_l lv with Some t => Pos.eqb t mt | None => false end.

  Definition afm_call_ok (gt : list (ident * ident)) (ids : list ident)
      (optid : option ident) (a : expr) (al : list expr) : bool :=
    au_call_ok gt ids optid a al
    && match optid with Some t => negb (Pos.eqb t mt) | None => true end.

  Definition afm_chk (gt : list (ident * ident)) (ids : list ident) (f : Clight.function) : bool :=
    match fn_vars f with nil => true | _ => false end
    && au_params_ok gt f
    && lw_chk (afm_set_ok gt) (afm_store_ok gt) (afm_call_ok gt ids) (fn_body f).

  Lemma akm_ak : forall b z, akm b z -> ak lp ws b z.
  Proof. intros b z (H & _). exact H. Qed.

  Lemma afm_set : forall gt id a le m v,
      afm_set_ok gt id a = true -> afm_P gt le ->
      eval_expr (lp_ge lp) empty_env le m a v -> afm_P gt (PTree.set id v le).
  Proof.
    intros gt id a le m v Hok (HP & Hm) Hev. unfold afm_set_ok in Hok.
    apply andb_prop in Hok as [Hn Hok]. split.
    - eapply af_set; eassumption.
    - intros b o Hl. destruct (peq mt id) as [E | Hne].
      + rewrite E, Pos.eqb_refl in Hn. discriminate Hn.
      + rewrite PTree.gso in Hl by exact Hne. exact (Hm b o Hl).
  Qed.

  Lemma afm_store : forall gt lv rhs le m t le' m' out,
      afm_store_ok gt lv rhs = true -> afm_P gt le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      Q2 akm m m'.
  Proof.
    intros gt lv rhs le m t le' m' out Hok (HP & Hm) Hx.
    unfold afm_store_ok in Hok. apply orb_true_iff in Hok as [Ha | Hc].
    - exact (Q2_mono _ _ m m' akm_ak (af_store lp ws gt lv rhs le m t le' m' out Ha HP Hx)).
    - destruct (chain_root_l lv) as [t0|] eqn:Hr; [| discriminate Hc].
      apply Pos.eqb_eq in Hc. subst t0.
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hr Hl) as (o0 & Hle) end.
      pose proof (Hm _ _ Hle) as Eb. subst.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        refine (al_q2 akm _ _ _ _ _ _ _ _ Ha _) end.
      intros i (_ & N). exact (N eq_refl).
  Qed.

  Lemma afm_call : forall gt ids,
      (forall g, mem_id g ids = true -> af_pres lp ws g) ->
      forall optid a al le m t le' m' out,
        afm_call_ok gt ids optid a al = true -> afm_P gt le ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
        Q2 akm m m' /\ afm_P gt le'.
  Proof.
    intros gt ids Hids optid a al le m t le' m' out Hok (HP & Hm) Hx.
    unfold afm_call_ok in Hok. apply andb_prop in Hok as [Hok Ho].
    destruct (af_call lp ws gt ids Hids optid a al le m t le' m' out Hok HP Hx) as (Hq & HP').
    split; [ exact (Q2_mono _ _ m m' akm_ak Hq) | split; [ exact HP' | ] ].
    inv Hx. destruct optid as [ti|]; cbn [set_opttemp]; [ | exact Hm ].
    intros b o Hl. destruct (peq mt ti) as [E | Hne].
    - rewrite E, Pos.eqb_refl in Ho. discriminate Ho.
    - rewrite PTree.gso in Hl by exact Hne. exact (Hm b o Hl).
  Qed.

  Lemma afm_body : forall gt ids f,
      afm_chk gt ids f = true ->
      (forall g, mem_id g ids = true -> af_pres lp ws g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        (forall le1, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le1 ->
           forall b o, le1 ! mt = Some (Vptr b o) -> b = bm) ->
        Q2 akm m m'.
  Proof.
    intros gt ids f Hchk Hids m vargs t m' vres Hevf Hm0.
    unfold afm_chk in Hchk.
    apply andb_prop in Hchk as [Hchk Hw]. apply andb_prop in Hchk as [Hv Hpar].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    refine (lw_body_frame (lp_ge lp) (Q2 akm m) f (afm_P gt) (afm_set_ok gt) (afm_store_ok gt)
              (afm_call_ok gt ids) Hvars Hw _ _ _ _ _ _ _ _ Hevf _ (Q2_refl akm m)).
    - intros id a le m1 v Hok HP _ Hev. exact (afm_set gt id a le m1 v Hok HP Hev).
    - intros lv rhs le m1 t0 le' m2 out Hok HP Hx Hq.
      exact (Q2_trans akm _ _ _ Hq (afm_store gt lv rhs le m1 t0 le' m2 out Hok HP Hx)).
    - intros optid a al le m1 t0 le' m2 out Hok HP Hx Hq.
      destruct (afm_call gt ids Hids optid a al le m1 t0 le' m2 out Hok HP Hx) as (Hq' & HP').
      exact (conj (Q2_trans akm _ _ _ Hq Hq') HP').
    - intros le1 Hb. split; [ | exact (Hm0 le1 Hb) ].
      intros t0 g b o Ht Hle.
      rewrite (bind_notin _ _ _ _ _ Hb (au_params_notin _ _ _ _ Hpar Ht)) in Hle.
      apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  Qed.
End AFM.

(* ---------------------------------------------------------------------- *)
(* 5. update_and_return_cap_flags (mario.c), the call                     *)
(*    mario_update_hitbox_and_cap_model makes: it writes m->capTimer and  *)
(*    m->flags (Mario's block), reads sCapFlickerFrames, and calls        *)
(*    stop_cap_music / fadeout_cap_music (section 3).  Its frame: only bm *)
(*    and the cap music path's globals change.                            *)
(* ---------------------------------------------------------------------- *)

Section CapFlags.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hlsf : ls_frame lp.
  Variable bm : block.

  Theorem ucf_frame : forall m o t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m (Internal mario.f_update_and_return_cap_flags)
        [Vptr bm o] t m' vres ->
      Q2 (akm lp cap_ids bm) m m'.
  Proof.
    intros m o t m' vres Hev.
    pose proof (af_stop_cap_music lp H12 Hlsf) as A1.
    pose proof (af_fadeout_cap_music lp H12) as A2.
    refine (afm_body lp cap_ids bm mario._m nil [SI._stop_cap_music; SI._fadeout_cap_music]
              mario.f_update_and_return_cap_flags _ _ m _ t m' vres Hev _).
    - vm_compute. reflexivity.
    - intros g Hg. cbn [mem_id existsb] in Hg.
      repeat (apply orb_true_iff in Hg as [Hg | Hg];
              [ apply Pos.eqb_eq in Hg; subst g; assumption | ]).
      discriminate Hg.
    - intros le1 Hb b o' Hl. cbn in Hb. injection Hb as <-.
      rewrite PTree.gss in Hl. congruence.
  Qed.
End CapFlags.
