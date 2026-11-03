(* spine (2026-11-02): the camera's footprint and its AudioInv carry; the
   camera rows (HeightFrame's cam_phi_row / cam_ow_fp) are derived from it
   in CamRows. *)
(* ====================================================================== *)
(* CamFootInst.v -- THE CAMERA'S BYTE-LEVEL FOOTPRINT (R1 interim).       *)
(*                                                                        *)
(* THEOREM (update_camera_foot): the real update_camera(c), with c the    *)
(* area's Camera (block cb, offset co; no global's block) or NULL, run    *)
(* from ANY memory whose five pins hold (gCamera = the Camera or NULL;    *)
(* sMarioCamState and sLuigiCamState point into an FP global (in the      *)
(* game: gPlayerCameraState[0] / [1], CamPinCensus); gSecondCameraFocus = *)
(* no pointer (NULL); gMarioState points into an FP global                 *)
(* (gMarioStates)) and whose audio state is AudioInv,                     *)
(*   - changes memory only in the blocks of cf_FP's 110 globals and       *)
(*     cf_XP's 5 audio globals (LsContract.ls_ids), the Camera's          *)
(*     sizeof(struct Camera) = 108 bytes, and the pins' cells;            *)
(*   - keeps every old permission, and leaves new blocks permissionless;  *)
(*   - keeps the pins and AudioInv.                                       *)
(* No state is pruned: every one of the 496 walked bodies of the          *)
(* all-states call tree passes the walk (cf_walk_ok), indirect calls      *)
(* range over every function of the call's type                            *)
(* (UpdateCameraBody.all_evt_ok, CameraModeBody.trans_fd_ids).  No walked *)
(* body stores into an audio global (they are not FP); the bodies that do *)
(* are leaves, walked by AudioWire (store roots, AudioInv per store).     *)
(*                                                                        *)
(* THE LEAVES, all proved or floors (no open premise beyond the pins):    *)
(*   the five AVOID_UB vec helpers (CamFootSound.shadow_leaf);            *)
(*   sqrtf from the FPU floor (TRUST 3.5);                                *)
(*   load_sequence from AudioInv.ls_frame_ai (the scoped audio contract,  *)
(*     TRUST 4.1);                                                        *)
(*   the seven sequence-player bodies that store into gSequencePlayers    *)
(*     (fade_to_zero / normal / target / percentage, func_8031D690,       *)
(*     play_sequence, begin_background_music_fade), from their real       *)
(*     bodies: AudioWire.cai_* (footprint cam_aud_ids, AudioInv kept);    *)
(*   save_file_do_save, for any argument, from the real bodies of its     *)
(*     whole tree down to the OS floor (TRUST 3.5): CamFootSave.sds_foot; *)
(*   set_mario_npc_dialog, for any argument, from the real bodies:        *)
(*     CamFootNpc.npc_spec (its set_mario_action call passes the literal  *)
(*     ACT_READING_NPC_DIALOG, so only the cutscene arm of the switch     *)
(*     runs -- the one argument-constant specialization, sma_prune).      *)
(* ====================================================================== *)

From Coq Require Import String List ZArith Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Linking Clightdefs.
From SM64.Generated Require mario camera math_util audio_external.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 Generic.PermWalk.
From SM64.Proofs.WMotRRequiresA Require Import CamFootKit CamFootSound CamFootTable ObjTable.
From SM64.Proofs Require UcTable UpdateCameraBody CameraModeBody MtxfBody FpuFloor
  EngineV2Consumer.
From SM64.Proofs.WMotRRequiresA Require LsContract BodyFrame CamFootSave CamFootNpc FootWalk
  AudioInv CapAudio AudioWire.
From SM64.Proofs Require OsDmaFloor.
Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. The tables, checked.                                                 *)
(* ---------------------------------------------------------------------- *)

Definition cf_it : fitab :=
  [(UcTable.evt_ty, ([fC cf_SZ], fN));
   (CameraModeBody.trans_ty, ([fC cf_SZ; fFC 104; fFC 92], fN))].

Lemma cf_SZ_ok : match (prog_comp_env camera.prog) ! camera._Camera with
                 | Some co => co_sizeof co | None => 0 end = cf_SZ.
Proof. vm_compute. reflexivity. Qed.

Definition cf_ent_ok (e : ident * nat * fsig) : bool :=
  let '(fid, i, s) := e in
  match nth_error lprogs i with
  | Some p =>
      match (prog_defmap p) ! fid with
      | Some (Gfun (Internal f)) => fchk (prog_comp_env p) cf_FP cf_pins cf_tab cf_it s f
      | _ => false
      end
  | None => false
  end.

(* THE WALK: every one of the 503 bodies passes its footprint check *)
Lemma cf_walk_ok : forallb cf_ent_ok cf_walk = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_walk_count : List.length cf_walk = 496%nat.
Proof. vm_compute. reflexivity. Qed.

Definition cf_fits_in (sg : fsig) (id : ident) : bool :=
  match ft_find id cf_tab with Some se => ffits se sg | None => false end.

Lemma cf_evt_fit : forallb (cf_fits_in ([fC cf_SZ], fN)) UcTable.evt_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_trans_fit : forallb (cf_fits_in ([fC cf_SZ; fFC 104; fFC 92], fN)) CameraModeBody.trans_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* NON-VACUITY: update_camera is walked, at the Camera's class *)
Lemma cf_entry_sig : ft_find camera._update_camera cf_tab = Some ([fC cf_SZ], fN).
Proof. vm_compute. reflexivity. Qed.

(* the pins are not FP globals *)
Lemma pin_of_in : forall x l c, pin_of x l = Some c -> In x (map fst l).
Proof.
  intros x l c. induction l as [| [g c0] l IH]; cbn [pin_of map fst]; [ discriminate | ].
  destruct (Pos.eqb g x) eqn:E; intros H.
  - apply Pos.eqb_eq in E. left. exact E.
  - right. exact (IH H).
Qed.

(* save_file_do_save's globals are footprint globals *)
Lemma cf_sds_fp : forallb (fun g => mem_idf g cf_FP) CamFootSave.sds_gvars = true.
Proof. vm_compute. reflexivity. Qed.

(* the leaves' extra footprint is the audio globals; none is an FP global
   or a pin; the camera's audio leaves' footprint is within FP and XP *)
Lemma cf_XP_eq : cf_XP = LsContract.ls_ids.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_ls_not_fp : forallb (fun g => negb (mem_idf g cf_FP)) LsContract.ls_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_ls_not_pin : forallb (fun g => negb (mem_idf g (map fst cf_pins))) LsContract.ls_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_aud_in : forallb (fun g => mem_idf g cf_FP || mem_idf g cf_XP) AudioWire.cam_aud_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_aud_not_pin : forallb (fun g => negb (mem_idf g (map fst cf_pins))) AudioWire.cam_aud_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma In_mem_idf : forall g l, In g l -> mem_idf g l = true.
Proof.
  intros g l H. unfold mem_idf. apply existsb_exists. exists g. split; [ exact H | apply Pos.eqb_refl ].
Qed.

Lemma cf_pins_fp_chk :forallb (fun x => negb (mem_idf x cf_FP)) (map fst cf_pins) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cf_pins_not_fp : forall x c, pin_of x cf_pins = Some c -> mem_idf x cf_FP = false.
Proof.
  intros x c H.
  pose proof (proj1 (forallb_forall _ _) cf_pins_fp_chk x (pin_of_in _ _ _ H)) as E.
  apply negb_true_iff in E. exact E.
Qed.

Lemma ft_find_app : forall fid l1 l2 s, ft_find fid (l1 ++ l2) = Some s ->
    ft_find fid l1 = Some s \/ ft_find fid l2 = Some s.
Proof.
  intros fid l1 l2 s. unfold ft_find. induction l1 as [| [x s0] l1 IH]; intros H.
  - right. exact H.
  - cbn [app find fst] in H |- *. destruct (Pos.eqb x fid); [ left; exact H | exact (IH H) ].
Qed.

Lemma ft_find_walk : forall (l : list (ident * nat * fsig)) fid s,
    ft_find fid (map (fun e => let '(fid, _, s) := e in (fid, s)) l) = Some s ->
    exists i, In (fid, i, s) l.
Proof.
  induction l as [| [[f0 i0] s0] l IH]; intros fid s H; [ discriminate H | ].
  unfold ft_find in H. cbn [map find fst] in H.
  destruct (Pos.eqb f0 fid) eqn:E.
  - apply Pos.eqb_eq in E. subst f0. injection H as <-. exists i0. left. reflexivity.
  - destruct (IH fid s H) as (i & Hi). exists i. right. exact Hi.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. On the link.                                                         *)
(* ---------------------------------------------------------------------- *)

Import Clightdefs.ClightNotations.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Section CF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Let ge := lp_ge lp.

  (* the FPU floor (TRUST 3.5) *)
  Hypothesis Hsq : FpuFloor.sqrtf_spec.
  (* the scoped audio contract (TRUST 4.1, the labeled audio premise's
     footprint half): from an AudioInv memory, load_sequence changes only
     the audio blocks and keeps AudioInv *)
  Hypothesis Hlsai : AudioInv.ls_frame_ai lp.

  (* the Camera: no global's block (in the game a main-pool block; FfWorld's
     cam_w: Ple genv_next cb) *)
  Variables (cb : block) (co : Z).
  Hypothesis HSZ : 0 <= co /\ co + cf_SZ <= Ptrofs.max_unsigned.
  Hypothesis Hgcb : forall g b, Genv.find_symbol ge g = Some b -> b <> cb.

  Lemma HPcb : forall x c b, pin_of x cf_pins = Some c -> Genv.find_symbol ge x = Some b -> b <> cb.
  Proof. intros x c b _ Hs. exact (Hgcb _ _ Hs). Qed.

  (* the libultra OS / hardware floor (TRUST 3.5): save_file_do_save's
     EEPROM write (CamFootSave) *)
  Hypothesis Hfloor : OsDmaFloor.os_dma_floor.

  Notation AI := (AudioInv.AudioInv ge).

  Definition cfLeaf (fd : Clight.fundef) (s : fsig) : Prop :=
    exists fid b, ft_find fid cf_leaf = Some s /\ Genv.find_symbol ge fid = Some b /\
                  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd.

  Lemma cfLO : forall i p, nth_error lprogs i = Some p -> linkorder p lp.
  Proof.
    intros i p Hn. pose proof (nth_error_In _ _ Hn) as Hin.
    unfold lprogs in Hin. destruct Hin as [<- | Hin].
    - exact (linked12_LO_mario lp H12).
    - exact (link_chain_linkorder_in _ _ _ _ Hin H12).
  Qed.

  Lemma math_resolve : forall fid f b fd,
      (prog_defmap math_util.prog) ! fid = Some (Gfun (Internal f)) ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      fd = Internal f.
  Proof.
    intros fid f b fd Hdm Hs Hff.
    destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_math lp H12) Hdm) as (b' & Hs' & Hff').
    unfold ge, lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Hff' in Hff. injection Hff as <-. reflexivity.
  Qed.

  (* a global's block named by a list: the global is in the list *)
  Lemma gblk_mem : forall g l b, Genv.find_symbol ge g = Some b -> LsContract.gblk ge l b -> In g l.
  Proof.
    intros g l b Hs (g' & Hin & Hs').
    assert (E : g' = g) by (eapply Genv.genv_vars_inj; eassumption). subst g'. exact Hin.
  Qed.

  Section Leaves.
    Variable nl : block.
    Hypothesis HG : forall g b, Genv.find_symbol ge g = Some b -> Plt b nl.
    Hypothesis Hcbnl : Plt cb nl.

    (* THE CARRIED INVARIANT: AudioInv reads only the audio blocks, which
       are none of the walk's own store targets (not FP globals, not new,
       not the Camera's block, not pins) *)
    Lemma cf_HInv : forall m m', Ple nl (Mem.nextblock m) ->
        Mem.unchanged_on (fun b z => ~ (FB0 ge cf_FP b \/ Ple nl b \/ (b = cb /\ co <= z < co + cf_SZ)) /\
                                      ~ (exists x c, pin_of x cf_pins = Some c /\ Genv.find_symbol ge x = Some b /\ 0 <= z < 4))
          m m' -> AI m -> AI m'.
    Proof.
      intros m m' Hnl U. apply AudioInv.AudioInv_unch.
      intros b ch z (g & Hg & Hs).
      apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U).
      - unfold Mem.valid_block. exact (Plt_Ple_trans _ _ _ (HG _ _ Hs) Hnl).
      - intros i _. split.
        + intros [(g' & Hg' & Hs') | [Hl | (E & _)]].
          * assert (E : g' = g) by (eapply Genv.genv_vars_inj; eassumption). subst g'.
            pose proof (proj1 (forallb_forall _ _) cf_ls_not_fp g Hg) as N. cbv beta in N.
            rewrite Hg' in N. cbn in N. discriminate N.
          * exact (Plt_strict _ (Plt_Ple_trans _ _ _ (HG _ _ Hs) Hl)).
          * exact (Hgcb _ _ Hs E).
        + intros (x & c & Hp & Hs' & _).
          assert (E : x = g) by (eapply Genv.genv_vars_inj; eassumption). subst x.
          pose proof (proj1 (forallb_forall _ _) cf_ls_not_pin g Hg) as N. cbv beta in N.
          rewrite (In_mem_idf _ _ (pin_of_in _ _ _ Hp)) in N. cbn in N. discriminate N.
    Qed.

    Notation fspecC := (fspec ge cf_FP cf_pins cb co cf_SZ nl cf_XP AI).

    Definition ptr_temps (f : Clight.function) : list ident :=
      map fst (filter (fun p => match snd p with Tpointer _ _ => true | _ => false end) (fn_temps f)).

    Let shadow := shadow_leaf ge cf_FP cf_pins cb co cf_SZ nl HSZ HG cf_pins_not_fp HPcb
                    cf_XP AI cf_HInv Hcbnl.

    (* THE AUDIO LEAVES: a sequence-player body (or load_sequence) whose
       AudioWire walk bounds it to cam_aud_ids (cf_FP's music globals and
       cf_XP's audio globals) and keeps AudioInv *)
    Lemma aud_leaf : forall g b fd pcs,
        AudioWire.afi lp AudioWire.cam_aud_ids g ->
        Genv.find_symbol ge g = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        fspecC fd (pcs, fA).
    Proof.
      intros g b fd pcs Ha Hs Hff m vargs t m' vres Hevf _ ((HPv & HI) & Hnl).
      rewrite Genv.find_funct_find_funct_ptr in Hff.
      destruct (Ha b fd Hs Hff m vargs t m' vres Hevf HI) as ((U & N & P & F) & HI').
      assert (Hk : forall b0, LsContract.gblk ge AudioWire.cam_aud_ids b0 -> FB0 ge cf_FP b0 \/ FB0 ge cf_XP b0).
      { intros b0 (g0 & Hg0 & Hs0).
        pose proof (proj1 (forallb_forall _ _) cf_aud_in g0 Hg0) as E. cbv beta in E.
        apply orb_true_iff in E as [E | E]; [ left | right ]; exists g0; split; assumption. }
      assert (Hpin : forall b0 z, PCell ge cf_pins b0 z -> ~ LsContract.gblk ge AudioWire.cam_aud_ids b0).
      { intros b0 z (x & c & Hp & Hs0 & _) Hb.
        pose proof (gblk_mem _ _ _ Hs0 Hb) as Hin.
        pose proof (proj1 (forallb_forall _ _) cf_aud_not_pin x Hin) as E. cbv beta in E.
        rewrite (In_mem_idf _ _ (pin_of_in _ _ _ Hp)) in E. cbn in E. discriminate E. }
      split; [ split | split; [ split; [ split | ] | intros bb oo _; exact I ] ].
      - split; [ exact N | split ].
        + intros b0 o k p Hv. symmetry. exact (P b0 o k p Hv).
        + exact F.
      - eapply Mem.unchanged_on_implies; [ exact U | ].
        intros b0 z (N0 & _ & N2) _. unfold CapAudio.ak. intros Hb.
        destruct (Hk _ Hb) as [H0 | H0]; [ apply N0; left; exact H0 | exact (N2 H0) ].
      - refine (pinsV_unch ge cf_FP cf_pins cb co cf_SZ nl HG m m' HPv Hnl _).
        eapply Mem.unchanged_on_implies; [ exact U | ].
        intros b0 z Hc _. unfold CapAudio.ak. exact (Hpin _ _ Hc).
      - exact HI'.
      - exact (Ple_trans _ _ _ Hnl N).
    Qed.

    Ltac aud_case E fid Hf Hs Hff lem :=
      apply Pos.eqb_eq in E; subst fid; cbv beta iota in Hf; injection Hf as <-;
      eapply aud_leaf; [ apply lem; assumption | exact Hs | exact Hff ].

    Lemma cf_leaf_ok : forall fd s, cfLeaf fd s -> fspecC fd s.
    Proof.
      intros fd s (fid & b & Hf & Hs & Hff).
      unfold ft_find, cf_leaf in Hf. cbn [find fst] in Hf.
      destruct (Pos.eqb $"sqrtf" fid) eqn:E1.
      { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
        intros m vargs t m' vres Hevf _ Hst.
        pose proof (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hevf) as ->.
        split; [ apply FR_refl | split; [ exact Hst | intros bb oo _; exact I ] ]. }
      destruct (Pos.eqb $"load_sequence" fid) eqn:E2.
      { aud_case E2 fid Hf Hs Hff AudioWire.cai_ls. }
      destruct (Pos.eqb $"seq_player_fade_to_zero_volume" fid) eqn:Ea1.
      { aud_case Ea1 fid Hf Hs Hff AudioWire.cai_fade_to_zero. }
      destruct (Pos.eqb $"func_8031D690" fid) eqn:Ea2.
      { aud_case Ea2 fid Hf Hs Hff AudioWire.cai_8031D690. }
      destruct (Pos.eqb $"seq_player_play_sequence" fid) eqn:Ea3.
      { aud_case Ea3 fid Hf Hs Hff AudioWire.cai_play_seq. }
      destruct (Pos.eqb $"seq_player_fade_to_target_volume" fid) eqn:Ea4.
      { aud_case Ea4 fid Hf Hs Hff AudioWire.cai_fade_to_target. }
      destruct (Pos.eqb $"seq_player_fade_to_normal_volume" fid) eqn:Ea5.
      { aud_case Ea5 fid Hf Hs Hff AudioWire.cai_fade_to_normal. }
      destruct (Pos.eqb $"seq_player_fade_to_percentage_of_volume" fid) eqn:Ea6.
      { aud_case Ea6 fid Hf Hs Hff AudioWire.cai_fade_to_pct. }
      destruct (Pos.eqb $"begin_background_music_fade" fid) eqn:Ea7.
      { aud_case Ea7 fid Hf Hs Hff AudioWire.cai_bbmf. }
      destruct (Pos.eqb $"save_file_do_save" fid) eqn:E3.
      { apply Pos.eqb_eq in E3. subst fid. cbv beta iota in Hf; injection Hf as <-.
        intros m vargs t m' vres Hevf _ (HP & Hnl).
        destruct (CamFootSave.sds_foot lp H12 Hfloor b fd m vargs t m' vres Hs Hff Hevf) as (PKm & U).
        assert (U' : Mem.unchanged_on (fun b0 z => ~ A0 ge cf_FP cb co cf_SZ nl b0 z) m m').
        { eapply Mem.unchanged_on_implies; [ exact U | ].
          intros b0 z N0 _ (g & Hg & Hsg). apply N0. left. exists g. split; [ | exact Hsg ].
          exact (proj1 (forallb_forall _ _) cf_sds_fp g Hg). }
        split; [ split | split; [ split | intros bb oo _; exact I ] ].
        - exact PKm.
        - eapply Mem.unchanged_on_implies; [ exact U' | ]. intros b0 z (H0 & _) _. exact H0.
        - exact (pins_unch ge cf_FP cf_pins cb co cf_SZ nl HG cf_pins_not_fp HPcb AI cf_HInv m m' HP Hnl U').
        - exact (Ple_trans _ _ _ Hnl (proj1 PKm)). }
      destruct (Pos.eqb $"set_mario_npc_dialog" fid) eqn:E4.
      { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (CamFootNpc.npc_spec lp H12 cb co nl HSZ HG cf_pins_not_fp HPcb cf_XP AI cf_HInv b fd Hs Hff). }
      destruct (Pos.eqb $"vec3f_copy" fid) eqn:E5.
      { apply Pos.eqb_eq in E5. subst fid. cbv beta iota in Hf; injection Hf as <-.
        rewrite (math_resolve $"vec3f_copy" math_util.f_vec3f_copy b fd ltac:(vm_compute; reflexivity) Hs Hff).
        refine (shadow math_util.f_vec3f_copy _ _ 12 (ptr_temps math_util.f_vec3f_copy) _ _
                  (match fn_body math_util.f_vec3f_copy with Ssequence _ r => r | _ => Sskip end)
                  eq_refl eq_refl eq_refl _ _ _ _); vm_compute; reflexivity. }
      destruct (Pos.eqb $"vec3f_set" fid) eqn:E6.
      { apply Pos.eqb_eq in E6. subst fid. cbv beta iota in Hf; injection Hf as <-.
        rewrite (math_resolve $"vec3f_set" math_util.f_vec3f_set b fd ltac:(vm_compute; reflexivity) Hs Hff).
        refine (shadow math_util.f_vec3f_set _ _ 12 (ptr_temps math_util.f_vec3f_set) _ _
                  (match fn_body math_util.f_vec3f_set with Ssequence _ r => r | _ => Sskip end)
                  eq_refl eq_refl eq_refl _ _ _ _); vm_compute; reflexivity. }
      destruct (Pos.eqb $"vec3f_add" fid) eqn:E7.
      { apply Pos.eqb_eq in E7. subst fid. cbv beta iota in Hf; injection Hf as <-.
        rewrite (math_resolve $"vec3f_add" math_util.f_vec3f_add b fd ltac:(vm_compute; reflexivity) Hs Hff).
        refine (shadow math_util.f_vec3f_add _ _ 12 (ptr_temps math_util.f_vec3f_add) _ _
                  (match fn_body math_util.f_vec3f_add with Ssequence _ r => r | _ => Sskip end)
                  eq_refl eq_refl eq_refl _ _ _ _); vm_compute; reflexivity. }
      destruct (Pos.eqb $"vec3s_copy" fid) eqn:E8.
      { apply Pos.eqb_eq in E8. subst fid. cbv beta iota in Hf; injection Hf as <-.
        rewrite (math_resolve $"vec3s_copy" math_util.f_vec3s_copy b fd ltac:(vm_compute; reflexivity) Hs Hff).
        refine (shadow math_util.f_vec3s_copy _ _ 6 (ptr_temps math_util.f_vec3s_copy) _ _
                  (match fn_body math_util.f_vec3s_copy with Ssequence _ r => r | _ => Sskip end)
                  eq_refl eq_refl eq_refl _ _ _ _); vm_compute; reflexivity. }
      destruct (Pos.eqb $"vec3s_set" fid) eqn:E9.
      { apply Pos.eqb_eq in E9. subst fid. cbv beta iota in Hf; injection Hf as <-.
        rewrite (math_resolve $"vec3s_set" math_util.f_vec3s_set b fd ltac:(vm_compute; reflexivity) Hs Hff).
        refine (shadow math_util.f_vec3s_set _ _ 6 (ptr_temps math_util.f_vec3s_set) _ _
                  (match fn_body math_util.f_vec3s_set with Ssequence _ r => r | _ => Sskip end)
                  eq_refl eq_refl eq_refl _ _ _ _); vm_compute; reflexivity. }
      cbv beta iota in Hf; discriminate Hf.
    Qed.
  End Leaves.

  Lemma cf_tab_good : TabGood ge cf_FP cf_pins cf_tab cf_it cfLeaf.
  Proof.
    intros fid s Hf b fd Hs Hff.
    unfold cf_tab in Hf. destruct (ft_find_app _ _ _ _ Hf) as [Hw | Hl].
    - destruct (ft_find_walk _ _ _ Hw) as (i & Hin).
      pose proof (proj1 (forallb_forall _ _) cf_walk_ok _ Hin) as Hc.
      unfold cf_ent_ok in Hc.
      destruct (nth_error lprogs i) as [p|] eqn:Hn; [ | discriminate Hc ].
      destruct ((prog_defmap p) ! fid) as [[[f|ef]|v]|] eqn:Edm; try discriminate Hc.
      left. exists f, (prog_comp_env p). split; [ | split; [ | exact Hc ] ].
      + destruct (linkorder_resolves_funct lp _ _ _ (cfLO i p Hn) Edm) as (b' & Hs' & Hff').
        unfold ge, lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
        rewrite Hff' in Hff. injection Hff as <-. reflexivity.
      + intros id c Hc'. exact (linkorder_comp_env_extends lp p id c (cfLO i p Hn) Hc').
    - right. exists fid, b. split; [ exact Hl | split; [ exact Hs | exact Hff ] ].
  Qed.

  Lemma cf_fits_good : forall sg ids id b fd,
      forallb (cf_fits_in sg) ids = true -> mem_id id ids = true ->
      Genv.find_symbol ge id = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      exists se, Good ge cf_FP cf_pins cf_tab cf_it cfLeaf fd se /\ ffits se sg = true.
  Proof.
    intros sg ids id b fd Hall Hid Hs Hff.
    pose proof (proj1 (forallb_forall _ _) Hall id (MtxfBody.mem_id_In _ _ Hid)) as Hfit.
    unfold cf_fits_in in Hfit.
    destruct (ft_find id cf_tab) as [se|] eqn:Ese; [ | discriminate Hfit ].
    exists se. split; [ exact (cf_tab_good id se Ese b fd Hs Hff) | exact Hfit ].
  Qed.

  Lemma cf_it_good : ItGood ge cf_FP cf_pins cf_tab cf_it cfLeaf.
  Proof.
    intros ty s Hf vf fd Hff Hty.
    destruct (Genv.find_funct_inv _ _ Hff) as (b & ->).
    pose proof Hff as Hfp. rewrite Genv.find_funct_find_funct_ptr in Hfp.
    unfold fit_find, cf_it in Hf. cbn [find fst] in Hf.
    destruct (type_eq UcTable.evt_ty ty) as [<- | N1]; cbv beta iota delta [proj_sumbool] in Hf.
    - cbv beta iota in Hf; injection Hf as <-.
      destruct (UpdateCameraBody.ty_fd_ids _ _ UpdateCameraBody.all_evt_ok lp H12 b fd Hfp Hty) as (id & Hid & Hdm).
      destruct (proj1 (Genv.find_def_symbol _ _ _) Hdm) as (b' & Hs' & Hd').
      refine (cf_fits_good _ _ id b' fd cf_evt_fit Hid Hs' _).
      rewrite Genv.find_funct_find_funct_ptr. apply Genv.find_funct_ptr_iff. exact Hd'.
    - destruct (type_eq CameraModeBody.trans_ty ty) as [<- | N2]; cbv beta iota delta [proj_sumbool] in Hf;
        [ | discriminate Hf ].
      cbv beta iota in Hf; injection Hf as <-.
      destruct (CameraModeBody.trans_fd_ids lp H12 b fd Hfp Hty) as (id & Hid & Hdm).
      destruct (proj1 (Genv.find_def_symbol _ _ _) Hdm) as (b' & Hs' & Hd').
      refine (cf_fits_good _ _ id b' fd cf_trans_fit Hid Hs' _).
      rewrite Genv.find_funct_find_funct_ptr. apply Genv.find_funct_ptr_iff. exact Hd'.
  Qed.

  (* ==================================================================== *)
  (* 3. THE RESULT.                                                        *)
  (* ==================================================================== *)
  Theorem update_camera_foot : forall b fd m c t m' vres,
      Genv.find_symbol ge camera._update_camera = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd [c] t m' vres ->
      (forall bb oo, c = Vptr bb oo -> bb = cb /\ Ptrofs.unsigned oo = co) ->
      Plt cb (Mem.nextblock m) ->
      (forall g bg, Genv.find_symbol ge g = Some bg -> Plt bg (Mem.nextblock m)) ->
      Pins ge cf_FP cf_pins cb co cf_SZ (Mem.nextblock m) AI m ->
      PK m m'
      /\ Mem.unchanged_on (fun b z => ~ (FB0 ge cf_FP b \/ FB0 ge cf_XP b
                                          \/ (b = cb /\ co <= z < co + cf_SZ)
                                          \/ PCell ge cf_pins b z)) m m'
      /\ Pins ge cf_FP cf_pins cb co cf_SZ (Mem.nextblock m) AI m'.
  Proof.
    intros b fd m c t m' vres Hs Hff Hevf Hc Hcb HG Hpins.
    set (nl := Mem.nextblock m).
    pose proof (cf_good_spec ge cf_FP cf_pins cb co cf_SZ nl HSZ HG cf_pins_not_fp HPcb
                  cf_XP AI (cf_HInv nl HG)
                  cf_tab cf_it cfLeaf (cf_leaf_ok nl HG Hcb) cf_tab_good cf_it_good fd _
                  (cf_tab_good _ _ cf_entry_sig b fd Hs Hff)) as Hsp.
    assert (Hva : Forall2 (vokm ge cf_FP cb co cf_SZ nl m) [fC cf_SZ] [c]).
    { constructor; [ | constructor ].
      intros bb oo E. destruct (Hc bb oo E) as (-> & Ho). cbn [fpc].
      split; [ reflexivity | lia ]. }
    destruct (Hsp m [c] t m' vres Hevf Hva (conj Hpins (Ple_refl _))) as ((PKm & U) & (HP' & _) & _).
    split; [ exact PKm | split; [ | exact HP' ] ].
    eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b0 z N Hv. split; [ | split ].
    - intros [A | [A | A]].
      + apply N. left. exact A.
      + unfold Mem.valid_block in Hv. exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv A)).
      + apply N. right. right. left. exact A.
    - intros A. apply N. right. right. right. exact A.
    - intros A. apply N. right. left. exact A.
  Qed.
End CF.
