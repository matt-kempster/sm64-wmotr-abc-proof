(* kept: R1 (2026-11-02), the camera's footprint; restated into the camera
   rows in the deferred cam_w pin rebuild. *)
(* ====================================================================== *)
(* CamFootInst.v -- THE CAMERA'S BYTE-LEVEL FOOTPRINT (R1 interim).       *)
(*                                                                        *)
(* THEOREM (update_camera_foot): the real update_camera(c), with c the    *)
(* area's Camera (block cb, offset co) or NULL, run from ANY memory whose *)
(* five pins hold (gCamera = the Camera or NULL; sMarioCamState and       *)
(* sLuigiCamState point into an FP global (in the game: gPlayerCameraState*)
(* [0] / [1], CamPinCensus); gSecondCameraFocus = no pointer (NULL);      *)
(* gMarioState points into an FP global (gMarioStates)),                  *)
(*   - changes memory only in the blocks of cf_FP's 105 globals, the      *)
(*     Camera's sizeof(struct Camera) = 108 bytes, and the pins' cells;   *)
(*   - keeps every old permission, and leaves new blocks permissionless;  *)
(*   - keeps the pins.                                                    *)
(* No state is pruned: every one of the 503 bodies of the all-states call *)
(* tree passes the walk (cf_walk_ok), indirect calls range over every     *)
(* function of the call's type (UpdateCameraBody.all_evt_ok,               *)
(* CameraModeBody.trans_fd_ids).                                           *)
(*                                                                        *)
(* THE LEAVES.  The five AVOID_UB vec helpers are PROVED                  *)
(* (CamFootSound.shadow_leaf); sqrtf from the FPU floor (TRUST 3.5);      *)
(* load_sequence from LsContract.ls_frame (the labeled audio premise,     *)
(* TRUST 4.1 -- FALSE as stated (unscoped), restated with AudioInv next); *)
(* OPEN (premises, TRUE in every state given the pins):                   *)
(*   set_mario_npc_dialog writes only Mario's state (gMarioStates, through*)
(*     the gMarioState pin; its set_mario_action is the cutscene group);  *)
(*   save_file_do_save writes only gSaveBuffer / gSaveFileModified (and   *)
(*     the EEPROM through the OS floor).                                   *)
(* ====================================================================== *)

From Coq Require Import String List ZArith Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Linking Clightdefs.
From SM64.Generated Require mario camera math_util audio_external.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 Generic.PermWalk.
From SM64.Proofs.WMotRRequiresA Require Import CamFootKit CamFootSound CamFootTable ObjTable.
From SM64.Proofs Require UcTable UpdateCameraBody CameraModeBody MtxfBody FpuFloor
  EngineV2Consumer.
From SM64.Proofs.WMotRRequiresA Require LsContract BodyFrame.
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

Lemma cf_walk_count : List.length cf_walk = 503%nat.
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

Lemma cf_pins_fp_chk : forallb (fun x => negb (mem_idf x cf_FP)) (map fst cf_pins) = true.
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
  (* the labeled audio premise's footprint half (TRUST 4.1) *)
  Hypothesis Hls_frame : LsContract.ls_frame lp.

  (* the Camera *)
  Variables (cb : block) (co : Z).
  Hypothesis HSZ : 0 <= co /\ co + cf_SZ <= Ptrofs.max_unsigned.
  Hypothesis HPcb : forall x c b, pin_of x cf_pins = Some c -> Genv.find_symbol ge x = Some b -> b <> cb.

  Definition cf_open : ftab := [($"set_mario_npc_dialog", ([fA], fA)); ($"save_file_do_save", ([fA], fA))].

  (* OPEN (TRUE in every state given the pins): set_mario_npc_dialog
     writes Mario's state only; save_file_do_save the save buffer only *)
  Hypothesis Hopen : forall nl fid s b fd, ft_find fid cf_open = Some s ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      fspec ge cf_FP cf_pins cb co cf_SZ nl fd s.

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

  Section Leaves.
    Variable nl : block.
    Hypothesis HG : forall g b, Genv.find_symbol ge g = Some b -> Plt b nl.
    Hypothesis Hcbnl : Plt cb nl.

    Let shadow := shadow_leaf ge cf_FP cf_pins cb co cf_SZ nl HSZ HG cf_pins_not_fp HPcb Hcbnl.

    Definition ptr_temps (f : Clight.function) : list ident :=
      map fst (filter (fun p => match snd p with Tpointer _ _ => true | _ => false end) (fn_temps f)).

    Lemma cf_leaf_ok : forall fd s, cfLeaf fd s -> fspec ge cf_FP cf_pins cb co cf_SZ nl fd s.
    Proof.
      intros fd s (fid & b & Hf & Hs & Hff).
      unfold ft_find, cf_leaf in Hf. cbn [find fst] in Hf.
      destruct (Pos.eqb $"sqrtf" fid) eqn:E1.
      { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
        intros m vargs t m' vres Hevf _ Hst.
        pose proof (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hevf) as ->.
        split; [ apply FR_refl | split; [ exact Hst | intros bb oo _; exact I ] ]. }
      destruct (Pos.eqb $"load_sequence" fid) eqn:E2.
      { apply Pos.eqb_eq in E2. subst fid. cbv beta iota in Hf; injection Hf as <-.
        intros m vargs t m' vres Hevf _ (HP & Hnl).
        destruct (Hls_frame fd m vargs t m' vres Hevf (ex_intro _ b (conj Hs Hff))) as (U & N & P & F).
        assert (Hin : forall b0 z, ~ A0 ge cf_FP cb co cf_SZ nl b0 z -> ~ LsContract.gblk ge LsContract.ls_ids b0).
        { intros b0 z N0 (g & Hg & Hsg). apply N0. left. exists g. split; [ | exact Hsg ].
          revert Hg. vm_compute. intros Hg.
          repeat (destruct Hg as [<- | Hg]; [ reflexivity | ]). destruct Hg. }
        assert (U' : Mem.unchanged_on (fun b0 z => ~ A0 ge cf_FP cb co cf_SZ nl b0 z) m m').
        { eapply Mem.unchanged_on_implies; [ exact U | ]. intros b0 z H0 _. exact (Hin _ _ H0). }
        split; [ split | split; [ split | intros bb oo _; exact I ] ].
        - split; [ exact N | split ].
          + intros b0 o k p Hv. symmetry. exact (P b0 o k p Hv).
          + exact F.
        - eapply Mem.unchanged_on_implies; [ exact U' | ]. intros b0 z (H0 & _) _. exact H0.
        - exact (pins_unch ge cf_FP cf_pins cb co cf_SZ nl HG cf_pins_not_fp HPcb m m' HP Hnl U').
        - exact (Ple_trans _ _ _ Hnl N). }
      destruct (Pos.eqb $"save_file_do_save" fid) eqn:E3.
      { apply Pos.eqb_eq in E3. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (Hopen nl $"save_file_do_save" ([fA], fA) b fd eq_refl Hs Hff). }
      destruct (Pos.eqb $"set_mario_npc_dialog" fid) eqn:E4.
      { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (Hopen nl $"set_mario_npc_dialog" ([fA], fA) b fd eq_refl Hs Hff). }
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
      Pins ge cf_FP cf_pins cb co cf_SZ (Mem.nextblock m) m ->
      PK m m'
      /\ Mem.unchanged_on (fun b z => ~ (FB0 ge cf_FP b \/ (b = cb /\ co <= z < co + cf_SZ)
                                          \/ PCell ge cf_pins b z)) m m'
      /\ Pins ge cf_FP cf_pins cb co cf_SZ (Mem.nextblock m) m'.
  Proof.
    intros b fd m c t m' vres Hs Hff Hevf Hc Hcb HG Hpins.
    set (nl := Mem.nextblock m).
    pose proof (cf_good_spec ge cf_FP cf_pins cb co cf_SZ nl HSZ HG cf_pins_not_fp HPcb
                  cf_tab cf_it cfLeaf (cf_leaf_ok nl HG Hcb) cf_tab_good cf_it_good fd _
                  (cf_tab_good _ _ cf_entry_sig b fd Hs Hff)) as Hsp.
    assert (Hva : Forall2 (vokm ge cf_FP cb co cf_SZ nl m) [fC cf_SZ] [c]).
    { constructor; [ | constructor ].
      intros bb oo E. destruct (Hc bb oo E) as (-> & Ho). cbn [fpc].
      split; [ reflexivity | lia ]. }
    destruct (Hsp m [c] t m' vres Hevf Hva (conj Hpins (Ple_refl _))) as ((PKm & U) & (HP' & _) & _).
    split; [ exact PKm | split; [ | exact HP' ] ].
    eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b0 z N Hv. split.
    - intros [A | [A | A]].
      + apply N. left. exact A.
      + unfold Mem.valid_block in Hv. exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hv A)).
      + apply N. right. left. exact A.
    - intros A. apply N. right. right. exact A.
  Qed.
End CF.
