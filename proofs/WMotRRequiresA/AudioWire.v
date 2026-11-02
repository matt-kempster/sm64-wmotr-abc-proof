(* kept: AudioInv through load_sequence's consumers (2026-11-02).  The
   spine switches Hls to AudioInv.ls_frame_ai in the deferred root rebuild
   (FfWorld.lvl_w's aud_w); these are the carries it then consumes. *)
(* ====================================================================== *)
(* AudioWire.v -- the scoped load_sequence contract, wired through its    *)
(* consumers: the cap music path (CapAudio) and update_and_return_cap_flags.*)
(*                                                                        *)
(* aip g: a call of g from an AudioInv memory ends in an AudioInv memory. *)
(* The walk is CapAudio's (au_root: every store's root is a known global; *)
(* every call is to a function already shown), with one more check per    *)
(* store: its root is not an ls_ids global, or the stored value is never  *)
(* a pointer (a non-pointer scalar lvalue type, or a never-pointer rhs).  *)
(* Then the store adds no pointer to an audio block (Mem.load_pointer_    *)
(* store), so AudioInv holds after.  load_sequence itself is the scoped   *)
(* contract ls_frame_ai (TRUST 4.1).                                       *)
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
From SM64.Proofs Require EngineV2Consumer ActWriterSurface.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame LsContract CapAudio AudioInv.

Import ListNotations.

Module AX := audio_external.
Module SI := sound_init.

(* ---------------------------------------------------------------------- *)
(* 1. Stores.                                                              *)
(* ---------------------------------------------------------------------- *)

Section ST.
  Variable G : genv.

  Lemma ai_store_np : forall ch m b z v m', Mem.store ch m b z v = Some m' ->
      (forall bb oo, v <> Vptr bb oo) -> AudioInv G m -> AudioInv G m'.
  Proof.
    intros ch m b z v m' Hst Hv A b0 ch' z' b' o Hb Hl.
    destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hl) as [(Ev & _) | D];
      [ exfalso; exact (Hv _ _ Ev) | ].
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ D) in Hl. exact (A _ _ _ _ _ Hb Hl).
  Qed.

  Lemma ai_store_nls : forall ch m b z v m', Mem.store ch m b z v = Some m' ->
      ~ gblk G ls_ids b -> AudioInv G m -> AudioInv G m'.
  Proof.
    intros ch m b z v m' Hst Hn A b0 ch' z' b' o Hb Hl.
    assert (Nb : b0 <> b) by (intros ->; exact (Hn Hb)).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ (or_introl Nb)) in Hl.
    exact (A _ _ _ _ _ Hb Hl).
  Qed.

  Lemma ai_assign : forall ce ty m b ofs bf v m', assign_loc ce ty m b ofs bf v m' ->
      (~ gblk G ls_ids b \/ forall bb oo, v <> Vptr bb oo) -> AudioInv G m -> AudioInv G m'.
  Proof.
    intros ce ty m b ofs bf v m' Ha Hc A. inv Ha.
    - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs end.
      destruct Hc as [Hn | Hv]; [ eapply ai_store_nls | eapply ai_store_np ]; eassumption.
    - destruct Hc as [Hn | Hv]; [ | exfalso; exact (Hv _ _ eq_refl) ].
      intros b0 ch' z' b1 o Hb Hl.
      assert (Nb : b0 <> b) by (intros ->; exact (Hn Hb)).
      match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
        rewrite (Mem.load_storebytes_other _ _ _ _ _ Hs _ _ _ (or_introl Nb)) in Hl end.
      exact (A _ _ _ _ _ Hb Hl).
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs end.
      eapply ai_store_np; [ eassumption | intros bb oo E; discriminate E | exact A ].
  Qed.

  Lemma not_ls_of : forall g b, Genv.find_symbol G g = Some b -> mem_id g ls_ids = false ->
      ~ gblk G ls_ids b.
  Proof.
    intros g b Hs Hn (g' & Hin & Hg').
    assert (g' = g) by (eapply Genv.genv_vars_inj; [ exact Hg' | exact Hs ]). subst g'.
    assert (T : mem_id g ls_ids = true).
    { unfold mem_id. apply existsb_exists. exists g. split; [ exact Hin | apply Pos.eqb_refl ]. }
    rewrite T in Hn. discriminate Hn.
  Qed.
End ST.

(* ---------------------------------------------------------------------- *)
(* 2. The walk: CapAudio's frame (Q2 over the blocks of ws) and AudioInv, *)
(*    together, from the scoped contract.                                  *)
(* ---------------------------------------------------------------------- *)

Section AIW.
  Variable lp : Clight.program.
  Variable ws : list ident.
  Let ge := lp_ge lp.

  (* a call of g, from an AudioInv memory, changes only the blocks of ws
     and ends in an AudioInv memory *)
  Definition afi (g : ident) : Prop :=
    forall b fd, Genv.find_symbol ge g = Some b -> Genv.find_funct_ptr ge b = Some fd ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 ge m fd vargs t m' vres -> AudioInv ge m ->
        Q2 (ak lp ws) m m' /\ AudioInv ge m'.

  Definition ai_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
    match au_root gt lv with
    | Some g => negb (mem_id g ls_ids) || nonptr_scalar (typeof lv) || au_np_rhs rhs
    | None => false
    end.

  Definition afi_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
    af_store_ok ws gt lv rhs && ai_store_ok gt lv rhs.

  Definition afi_chk (gt : list (ident * ident)) (ids : list ident) (f : Clight.function) : bool :=
    match fn_vars f with nil => true | _ => false end
    && au_params_ok gt f
    && lw_chk (au_set_ok gt) (afi_store_ok gt) (au_call_ok gt ids) (fn_body f).

  Lemma ai_store : forall gt lv rhs le m t le' m' out,
      ai_store_ok gt lv rhs = true -> au_P lp gt le ->
      exec_stmt function_entry2 ge empty_env le m (Sassign lv rhs) t le' m' out ->
      AudioInv ge m -> AudioInv ge m'.
  Proof.
    intros gt lv rhs le m t le' m' out Hok HP Hx A.
    unfold ai_store_ok in Hok.
    destruct (au_root gt lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
      pose proof (au_root_blk lp gt lv _ _ _ _ _ g Hg HP Hl) as Hfs end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => refine (ai_assign ge _ _ _ _ _ _ _ _ Ha _ A) end.
    apply orb_true_iff in Hok as [Hok | Hnp]; [ apply orb_true_iff in Hok as [Hn | Hsc] | ].
    - left. apply negb_true_iff in Hn. exact (not_ls_of ge g _ Hfs Hn).
    - right. match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hsc Hc) end.
    - right. match goal with
             | Hr : eval_expr _ _ _ _ rhs ?v2, Hc : sem_cast ?v2 _ _ _ = Some _ |- _ =>
               exact (ActWriterSurface.sem_cast_nonptr_pres _ _ _ _ _ Hc (au_np_rhs_eval _ _ _ _ _ _ Hnp Hr))
             end.
  Qed.

  Lemma afi_call : forall gt ids,
      (forall g, mem_id g ids = true -> afi g) ->
      forall optid a al le m t le' m' out,
        au_call_ok gt ids optid a al = true -> au_P lp gt le ->
        exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
        AudioInv ge m -> (Q2 (ak lp ws) m m' /\ AudioInv ge m') /\ au_P lp gt le'.
  Proof.
    intros gt ids Hids optid a al le m t le' m' out Hok HP Hx A.
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
        exact (Hids fid Hc lf fd Hsy Hfp _ _ _ _ _ Hfc A) end.
    - destruct optid as [ti|]; cbn [set_opttemp]; [ | exact HP ].
      intros t0 g b o Ht Hle.
      destruct (peq t0 ti) as [-> | Hne].
      + rewrite Ht in Ho. discriminate Ho.
      + rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
  Qed.

  Lemma afi_body : forall gt ids f,
      afi_chk gt ids f = true ->
      (forall g, mem_id g ids = true -> afi g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
        AudioInv ge m -> Q2 (ak lp ws) m m' /\ AudioInv ge m'.
  Proof.
    intros gt ids f Hchk Hids m vargs t m' vres Hevf A.
    unfold afi_chk in Hchk.
    apply andb_prop in Hchk as [Hchk Hw]. apply andb_prop in Hchk as [Hv Hpar].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    refine (lw_body_frame ge (fun m1 => Q2 (ak lp ws) m m1 /\ AudioInv ge m1) f (au_P lp gt)
              (au_set_ok gt) (afi_store_ok gt)
              (au_call_ok gt ids) Hvars Hw _ _ _ _ _ _ _ _ Hevf _ (conj (Q2_refl _ m) A)).
    - intros id a le m1 v Hok HP _ Hev. exact (af_set lp gt id a le m1 v Hok HP Hev).
    - intros lv rhs le m1 t0 le' m2 out Hok HP Hx (Hq & A1).
      apply andb_prop in Hok as [Hof Hoi].
      split; [ exact (Q2_trans _ _ _ _ Hq (af_store lp ws gt lv rhs le m1 t0 le' m2 out Hof HP Hx)) | ].
      exact (ai_store gt lv rhs le m1 t0 le' m2 out Hoi HP Hx A1).
    - intros optid a al le m1 t0 le' m2 out Hok HP Hx (Hq & A1).
      destruct (afi_call gt ids Hids optid a al le m1 t0 le' m2 out Hok HP Hx A1) as ((Hq' & A2) & HP').
      exact (conj (conj (Q2_trans _ _ _ _ Hq Hq') A2) HP').
    - intros le1 Hb t0 g b o Ht Hle.
      rewrite (bind_notin _ _ _ _ _ Hb (au_params_notin _ _ _ _ Hpar Ht)) in Hle.
      apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  Qed.

  Lemma afi_of_body : forall (q : Clight.program) g f,
      linkorder q lp ->
      (prog_defmap q) ! g = Some (Gfun (Internal f)) ->
      (forall m vargs t m' vres,
         eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
         AudioInv ge m -> Q2 (ak lp ws) m m' /\ AudioInv ge m') ->
      afi g.
  Proof.
    intros q g f LO Hdm Hb b fd Hs Hfp.
    destruct (linkorder_resolves_funct lp _ g f LO Hdm) as (b' & Hs' & Hf').
    unfold ge, lp_ge in Hs, Hfp. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. rewrite Hfp in Hf'.
    injection Hf' as ->. exact Hb.
  Qed.
End AIW.

(* ---------------------------------------------------------------------- *)
(* 3. The cap music path (CapAudio's section 3), from the scoped contract. *)
(* ---------------------------------------------------------------------- *)

Section Cap.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hlsai : ls_frame_ai lp.

  Let afip := afi lp cap_ids.
  Let LOx := linked12_LO_audio_external lp H12.
  Let LOs := linked12_LO_sound_init lp H12.

  Ltac ids_ai :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg; cbn [mem_id existsb] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  Ltac ai_sym q LO f gt ids :=
    refine (afi_of_body lp cap_ids q _ f LO _ _);
    [ vm_compute; reflexivity
    | apply (afi_body lp cap_ids gt ids f); [ vm_compute; reflexivity | ids_ai ] ].

  (* load_sequence: the scoped contract (its blocks are among cap_ids) *)
  Lemma ai_ls : afip AX._load_sequence.
  Proof.
    intros b fd Hs Hfp m vargs t m' vres Hevf A.
    assert (Hres : EngineV2Consumer.resolves_lp lp AX._load_sequence fd).
    { exists b. split; [ exact Hs | rewrite Genv.find_funct_find_funct_ptr; exact Hfp ]. }
    destruct (Hlsai fd m vargs t m' vres Hevf Hres A) as (Hq & A').
    split; [ | exact A' ].
    refine (Q2_mono _ _ m m' _ Hq).
    intros b0 z Hk (g & Ig & Hg). apply Hk. exists g. split; [ | exact Hg ].
    unfold cap_ids. apply in_or_app. right. exact Ig.
  Qed.

  Lemma ai_fade_to_zero : afip AX._seq_player_fade_to_zero_volume.
  Proof. ai_sym AX.prog LOx AX.f_seq_player_fade_to_zero_volume gt_sp (@nil ident). Qed.
  Lemma ai_8031D690 : afip AX._func_8031D690.
  Proof. ai_sym AX.prog LOx AX.f_func_8031D690 gt_sp (@nil ident). Qed.
  Lemma ai_fade_to_normal : afip AX._seq_player_fade_to_normal_volume.
  Proof. ai_sym AX.prog LOx AX.f_seq_player_fade_to_normal_volume gt_sp (@nil ident). Qed.
  Lemma ai_fade_to_target : afip AX._seq_player_fade_to_target_volume.
  Proof. ai_sym AX.prog LOx AX.f_seq_player_fade_to_target_volume gt_sp (@nil ident). Qed.

  Lemma ai_fade_out : afip AX._seq_player_fade_out.
  Proof.
    pose proof ai_fade_to_zero.
    ai_sym AX.prog LOx AX.f_seq_player_fade_out (@nil (ident * ident))
      [AX._seq_player_fade_to_zero_volume].
  Qed.
  Lemma ai_bbmf : afip AX._begin_background_music_fade.
  Proof.
    pose proof ai_fade_to_normal. pose proof ai_fade_to_target.
    ai_sym AX.prog LOx AX.f_begin_background_music_fade (@nil (ident * ident))
      [AX._seq_player_fade_to_normal_volume; AX._seq_player_fade_to_target_volume].
  Qed.
  Lemma ai_play_seq : afip AX._seq_player_play_sequence.
  Proof.
    pose proof ai_bbmf. pose proof ai_8031D690. pose proof ai_ls.
    ai_sym AX.prog LOx AX.f_seq_player_play_sequence (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._func_8031D690; AX._load_sequence].
  Qed.
  Lemma ai_stop_bgm : afip AX._stop_background_music.
  Proof.
    pose proof ai_fade_out. pose proof ai_play_seq.
    ai_sym AX.prog LOx AX.f_stop_background_music (@nil (ident * ident))
      [AX._seq_player_fade_out; AX._seq_player_play_sequence].
  Qed.
  Lemma ai_fadeout_bgm : afip AX._fadeout_background_music.
  Proof.
    pose proof ai_fade_out.
    ai_sym AX.prog LOx AX.f_fadeout_background_music (@nil (ident * ident))
      [AX._seq_player_fade_out].
  Qed.

  Lemma ai_stop_cap_music : afip SI._stop_cap_music.
  Proof.
    pose proof ai_stop_bgm.
    ai_sym SI.prog LOs SI.f_stop_cap_music (@nil (ident * ident)) [AX._stop_background_music].
  Qed.
  Lemma ai_fadeout_cap_music : afip SI._fadeout_cap_music.
  Proof.
    pose proof ai_fadeout_bgm.
    ai_sym SI.prog LOs SI.f_fadeout_cap_music (@nil (ident * ident))
      [AX._fadeout_background_music].
  Qed.
End Cap.

(* ---------------------------------------------------------------------- *)
(* 4. Bodies that also store through their MarioState parameter (CapAudio *)
(*    section 4): Mario's block is not an audio block.                    *)
(* ---------------------------------------------------------------------- *)

Section AIM.
  Variable lp : Clight.program.
  Variable ws : list ident.
  Let ge := lp_ge lp.
  Variable bm : block.
  Variable mt : ident.
  Hypothesis NLm : ~ gblk ge ls_ids bm.

  Definition aim_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
    afm_store_ok ws mt gt lv rhs
    && (ai_store_ok gt lv rhs
        || match chain_root_l lv with Some t => Pos.eqb t mt | None => false end).

  Definition aim_chk (gt : list (ident * ident)) (ids : list ident) (f : Clight.function) : bool :=
    match fn_vars f with nil => true | _ => false end
    && au_params_ok gt f
    && lw_chk (afm_set_ok mt gt) (aim_store_ok gt) (afm_call_ok mt gt ids) (fn_body f).

  Lemma aim_store : forall gt lv rhs le m t le' m' out,
      aim_store_ok gt lv rhs = true -> afm_P lp bm mt gt le ->
      exec_stmt function_entry2 ge empty_env le m (Sassign lv rhs) t le' m' out ->
      AudioInv ge m -> Q2 (akm lp ws bm) m m' /\ AudioInv ge m'.
  Proof.
    intros gt lv rhs le m t le' m' out Hok HPm Hx A.
    unfold aim_store_ok in Hok. apply andb_prop in Hok as [Hof Hok].
    split; [ exact (afm_store lp ws bm mt gt lv rhs le m t le' m' out Hof HPm Hx) | ].
    destruct HPm as (HP & Hm).
    apply orb_true_iff in Hok as [Ha | Hc].
    - exact (ai_store lp gt lv rhs le m t le' m' out Ha HP Hx A).
    - destruct (chain_root_l lv) as [t0|] eqn:Hr; [| discriminate Hc].
      apply Pos.eqb_eq in Hc. subst t0.
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
        destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hr Hl) as (o0 & Hle) end.
      pose proof (Hm _ _ Hle) as Eb. subst.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        exact (ai_assign ge _ _ _ _ _ _ _ _ Ha (or_introl NLm) A) end.
  Qed.

  Lemma aim_call : forall gt ids,
      (forall g, mem_id g ids = true -> afi lp ws g) ->
      forall optid a al le m t le' m' out,
        afm_call_ok mt gt ids optid a al = true -> afm_P lp bm mt gt le ->
        exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
        AudioInv ge m -> (Q2 (akm lp ws bm) m m' /\ AudioInv ge m') /\ afm_P lp bm mt gt le'.
  Proof.
    intros gt ids Hids optid a al le m t le' m' out Hok (HP & Hm) Hx A.
    unfold afm_call_ok in Hok. apply andb_prop in Hok as [Hok Ho].
    destruct (afi_call lp ws gt ids Hids optid a al le m t le' m' out Hok HP Hx A) as ((Hq & A') & HP').
    split; [ exact (conj (Q2_mono _ _ m m' (akm_ak lp ws bm) Hq) A') | split; [ exact HP' | ] ].
    inv Hx. destruct optid as [ti|]; cbn [set_opttemp]; [ | exact Hm ].
    intros b o Hl. destruct (peq mt ti) as [E | Hne].
    - rewrite E, Pos.eqb_refl in Ho. discriminate Ho.
    - rewrite PTree.gso in Hl by exact Hne. exact (Hm b o Hl).
  Qed.

  Lemma aim_body : forall gt ids f,
      aim_chk gt ids f = true ->
      (forall g, mem_id g ids = true -> afi lp ws g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
        (forall le1, bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le1 ->
           forall b o, le1 ! mt = Some (Vptr b o) -> b = bm) ->
        AudioInv ge m -> Q2 (akm lp ws bm) m m' /\ AudioInv ge m'.
  Proof.
    intros gt ids f Hchk Hids m vargs t m' vres Hevf Hm0 A.
    unfold aim_chk in Hchk.
    apply andb_prop in Hchk as [Hchk Hw]. apply andb_prop in Hchk as [Hv Hpar].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    refine (lw_body_frame ge (fun m1 => Q2 (akm lp ws bm) m m1 /\ AudioInv ge m1) f
              (afm_P lp bm mt gt) (afm_set_ok mt gt) (aim_store_ok gt)
              (afm_call_ok mt gt ids) Hvars Hw _ _ _ _ _ _ _ _ Hevf _ (conj (Q2_refl _ m) A)).
    - intros id a le m1 v Hok HP _ Hev. exact (afm_set lp bm mt gt id a le m1 v Hok HP Hev).
    - intros lv rhs le m1 t0 le' m2 out Hok HP Hx (Hq & A1).
      destruct (aim_store gt lv rhs le m1 t0 le' m2 out Hok HP Hx A1) as (Hq' & A2).
      exact (conj (Q2_trans _ _ _ _ Hq Hq') A2).
    - intros optid a al le m1 t0 le' m2 out Hok HP Hx (Hq & A1).
      destruct (aim_call gt ids Hids optid a al le m1 t0 le' m2 out Hok HP Hx A1) as ((Hq' & A2) & HP').
      exact (conj (conj (Q2_trans _ _ _ _ Hq Hq') A2) HP').
    - intros le1 Hb. split; [ | exact (Hm0 le1 Hb) ].
      intros t0 g b o Ht Hle.
      rewrite (bind_notin _ _ _ _ _ Hb (au_params_notin _ _ _ _ Hpar Ht)) in Hle.
      apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  Qed.
End AIM.

(* ---------------------------------------------------------------------- *)
(* 5. update_and_return_cap_flags (CapAudio.ucf_frame), from the scoped    *)
(*    contract: its frame and AudioInv.                                     *)
(* ---------------------------------------------------------------------- *)

Section CapFlags.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hlsai : ls_frame_ai lp.
  Variable bm : block.
  Hypothesis NLm : ~ gblk (lp_ge lp) ls_ids bm.

  Theorem ucf_frame_ai : forall m v t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m (Internal mario.f_update_and_return_cap_flags)
        [v] t m' vres ->
      (forall b o, v = Vptr b o -> b = bm) ->
      AudioInv (lp_ge lp) m -> Q2 (akm lp cap_ids bm) m m' /\ AudioInv (lp_ge lp) m'.
  Proof.
    intros m v t m' vres Hev Hv.
    pose proof (ai_stop_cap_music lp H12 Hlsai) as A1.
    pose proof (ai_fadeout_cap_music lp H12) as A2.
    refine (aim_body lp cap_ids bm mario._m NLm nil [SI._stop_cap_music; SI._fadeout_cap_music]
              mario.f_update_and_return_cap_flags _ _ m _ t m' vres Hev _).
    - vm_compute. reflexivity.
    - intros g Hg. cbn [mem_id existsb] in Hg.
      repeat (apply orb_true_iff in Hg as [Hg | Hg];
              [ apply Pos.eqb_eq in Hg; subst g; assumption | ]).
      discriminate Hg.
    - intros le1 Hb b o' Hl. cbn in Hb. injection Hb as <-.
      rewrite PTree.gss in Hl. injection Hl as ->. exact (Hv _ _ eq_refl).
  Qed.
End CapFlags.
