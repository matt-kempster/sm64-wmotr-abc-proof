(* spine-root: OBJECTS phase S3 -- the FRAME of the code a non-Mario object
   slot runs: ObjWalk's extended walker over ObjKit's 387 bodies plus the
   three Mario-writing bodies UcKit could not walk.  Consumed by S2's
   obj_w / PhiW. *)
(* ====================================================================== *)
(* ObjFrame.v                                                             *)
(*                                                                        *)
(* 1. THE WALK: ObjTable's 387 bodies plus start_object_cutscene,         *)
(*    bhv_1up_interact, cur_obj_push_mario_away and cur_obj_update_floor  *)
(*    (its getter's out-cell is an ObjWalk S-local, so it returns kS),    *)
(*    re-checked with ObjWalk.xchk at the Mario cells mcells (one vm      *)
(*    sweep).                                                             *)
(* 2. THE NAMED SUB-CONTRACTS (premise-free beyond the FPU floor and the  *)
(*    walk's SafeB globals), each a walk of the real body with its own    *)
(*    cell list:                                                           *)
(*      push_mario_away_contract   writes Mario only at pos[0] / pos[2]   *)
(*      one_up_contract            writes Mario only at numLives          *)
(*      object_cutscene_contract   writes no Mario cell (gCutsceneFocus  *)
(*                                 is a stored global: MWF keeps)         *)
(* 3. THE WHOLE-WALK FRAME (obj_body_frame): every walked nullary body     *)
(*    keeps ow_facts and changes memory only in SafeB, blocks allocated   *)
(*    during the call, globals MWF does not read, and the Mario cells MC  *)
(*    (any MC containing mcells).  Its premises are the leaves the walk   *)
(*    stops at, each named:                                               *)
(*      Hlsc (TRUST 4.1, ls_contract)   load_sequence (audio): GOAL 1's   *)
(*                                      row + its footprint (LsContract)  *)
(*      HMCn                            MC holds NpcFrame.npc_cells: the  *)
(*                                      Mario cells set_mario_npc_dialog  *)
(*                                      writes (its frame: NpcFrame)      *)
(*      Hopen2                          cur_obj_call_action_function      *)
(*                                      (writable action table)           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario audio_external math_util mario_actions_cutscene camera level_update
  object_helpers obj_behaviors.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 MWFReal SpawnInit MathBodies LinkedTwelve
  UcKit FpuFloor.
From SM64.Proofs Require MtxfBody AudioBodies ObjExtBodies FloorsSurface
  NpcDialogBody UpdateCameraBody SaveFileBody SpawnBodies CameraModeBody.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable ObjKit ObjWalk BodyFrame LsContract NpcFrame.
From SM64.Proofs Require EngineV2Consumer.
From SM64.Proofs.WMotRRequiresA Require BehaviorScripts.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. The tables.                                                           *)
(* ---------------------------------------------------------------------- *)

Definition tab_ut (l : list (ident * nat * usig)) : utab :=
  map (fun e => let '(fid, _, s) := e in (fid, s)) l.

Definition xt_ent_ok (cl : list (Z * Z)) (gs : list ident) (ut : utab) (e : ident * nat * usig) : bool :=
  let '(fid, i, s) := e in
  match nth_error lprogs i with
  | Some p =>
      match (prog_defmap p) ! fid with
      | Some (Gfun (Internal f)) => xchk cl gs ut oit s f
      | _ => false
      end
  | None => false
  end.

(* the three bodies UcKit left open, now walked *)
Definition x_cutscene : ident * nat * usig := (camera._start_object_cutscene, 34%nat, ([kN; kS], kA, false)).
Definition x_1up : ident * nat * usig := (obj_behaviors._bhv_1up_interact, 43%nat, ([], kA, false)).
Definition x_push : ident * nat * usig := (object_helpers._cur_obj_push_mario_away, 21%nat, ([kN], kA, false)).
Definition x_coll : ident * nat * usig :=
  (object_helpers._obj_check_if_collided_with_object, 21%nat, ([kS; kS], kN, false)).

(* cur_obj_update_floor, walked: its getter's out-cell `floor` is an S-local
   (ObjWalk.sl_of), find_floor is a restarting call, so the getter returns kS
   (UcKit's table, without S-locals, says only kW) *)
Definition x_getfloor : ident * nat * usig :=
  (object_helpers._cur_obj_update_floor_height_and_get_floor, 21%nat, ([], kS, false)).
Definition x_updfloor : ident * nat * usig := (object_helpers._cur_obj_update_floor, 21%nat, ([], kA, false)).

Definition xotab : list (ident * nat * usig) :=
  [x_getfloor; x_updfloor] ++ otab ++ [x_cutscene; x_1up; x_push].

Definition sq_leaf : ident * usig := (math_util._sqrtf, ([kN], kA, false)).
Definition ps_leaf : ident * usig := (audio_external._play_sound, ([kA; kA], kA, false)).

(* the leaves of the whole walk *)
Definition xleaf : utab := [
  sq_leaf; ps_leaf;
  (audio_external._load_sequence, ([kN; kN; kN], kA, true));
  (mario_actions_cutscene._set_mario_npc_dialog, ([kN], kA, true));
  (object_helpers._cur_obj_call_action_function, ([kS], kA, true)) ].

Definition xout : utab := tab_ut xotab ++ xleaf.

(* THE WALK (vm, against the generated AST) *)
Lemma xt_walk_ok : forallb (xt_ent_ok mcells obj_gs xout) xotab = true.
Proof. vm_compute. reflexivity. Qed.

(* the sub-contract walks: each body with its own cells *)
Lemma push_walk_ok : forallb (xt_ent_ok pos_cells obj_gs (tab_ut [x_push] ++ [sq_leaf])) [x_push] = true.
Proof. vm_compute. reflexivity. Qed.

Lemma one_up_walk_ok :
  forallb (xt_ent_ok lives_cells obj_gs (tab_ut [x_1up; x_coll] ++ [ps_leaf])) [x_1up; x_coll] = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cutscene_walk_ok : forallb (xt_ent_ok [] obj_gs (tab_ut [x_cutscene] ++ [])) [x_cutscene] = true.
Proof. vm_compute. reflexivity. Qed.

(* cur_obj_update_floor's closure: writes no Mario cell *)
Definition x_ff : ident * nat * usig := (surface_collision._find_floor, 12%nat, ([kN; kN; kN; kT], kN, false)).
Definition x_ffl : ident * nat * usig :=
  (surface_collision._find_floor_from_list, 12%nat, ([kS; kN; kN; kN; kL], kS, false)).
Definition uf_tab : list (ident * nat * usig) := [x_updfloor; x_getfloor; x_ff; x_ffl].
Lemma updfloor_walk_ok : forallb (xt_ent_ok [] obj_gs (tab_ut uf_tab ++ [])) uf_tab = true.
Proof. vm_compute. reflexivity. Qed.

(* play_sound's stores are all rooted at globals MWF does not read *)
Definition gstore_nm (f : Clight.function) : bool :=
  match fn_vars f with nil => true | _ => false end &&
  SpawnBodies.sw_chk (fun _ _ => true)
    (fun l _ => match SaveFileBody.groot_l l with
                | Some g => negb (mem_id g ObjExtBodies.mwf_syms)
                | None => false
                end)
    (fun _ _ _ => false) (fun _ => true) (fn_body f).

Lemma gnm_ps : gstore_nm audio_external.f_play_sound = true.
Proof. vm_compute. reflexivity. Qed.

Lemma gms_in_mwf : mem_id level_update._gMarioStates ObjExtBodies.mwf_syms = true.
Proof. vm_compute. reflexivity. Qed.

(* the frame is monotone in its fresh-block threshold *)
Lemma FR_mono : forall lp bm SafeB MC nl nl' m m',
    Ple nl nl' -> FR lp bm SafeB nl' MC m m' -> FR lp bm SafeB nl MC m m'.
Proof.
  intros lp bm SafeB MC nl nl' m m' Hle H. unfold FR in *.
  eapply Mem.unchanged_on_implies; [ exact H | ].
  intros b ofs Hn _ Hfp. apply Hn. unfold FP in *.
  destruct Hfp as [H1 | [H1 | H1]];
    [ left; exact H1 | right; left; exact (Ple_trans _ _ _ Hle H1) | right; right; exact H1 ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. A checked table meets xspec.                                          *)
(* ---------------------------------------------------------------------- *)

Section INST.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Let ge := lp_ge lp.
  Hypothesis Hgs : forall x b, mem_id x obj_gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Variable nl : block.
  Hypothesis HNL : HnB lp bm SafeB nl.
  Variable MC : Z -> Prop.
  Variable cl : list (Z * Z).
  Hypothesis HMC : forall ofs, in_mcells cl ofs -> MC ofs.
  Variable tab : list (ident * nat * usig).
  Variable lf : utab.
  Hypothesis Hwalk : forallb (xt_ent_ok cl obj_gs (tab_ut tab ++ lf)) tab = true.
  Hypothesis Hlf : forall fid s b fd, ut_find fid lf = Some s ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      xspec lp bm bc oc0 SafeB nl MC fd s.

  Definition iLeaf (fd : Clight.fundef) (s : usig) : Prop :=
    exists fid b, ut_find fid lf = Some s /\ Genv.find_symbol ge fid = Some b /\
                  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd.

  Lemma i_tab_good : xTabGood lp cl obj_gs (tab_ut tab ++ lf) oit iLeaf.
  Proof.
    intros fid s Hf b fd Hs Hff.
    destruct (UpdateCameraBody.ut_find_app _ _ _ _ Hf) as [Hw | Hl].
    - unfold tab_ut in Hw. destruct (ut_find_otab _ _ _ Hw) as (i & Hin).
      pose proof (proj1 (forallb_forall _ _) Hwalk _ Hin) as Hc.
      unfold xt_ent_ok in Hc.
      destruct (nth_error lprogs i) as [p|] eqn:Hn; [ | discriminate Hc ].
      destruct ((prog_defmap p) ! fid) as [[[f|ef]|v]|] eqn:Edm; try discriminate Hc.
      left. exists f. split; [ | exact Hc ].
      destruct (linkorder_resolves_funct lp _ _ _ (oLO lp H12 i p Hn) Edm) as (b' & Hs' & Hff').
      unfold ge, lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-. reflexivity.
    - right. exists fid, b. split; [ exact Hl | split; [ exact Hs | exact Hff ] ].
  Qed.

  Lemma i_it_good : xItGood lp cl obj_gs (tab_ut tab ++ lf) oit iLeaf.
  Proof. intros ty s Hf. discriminate Hf. Qed.

  Lemma i_leaf_ok : forall fd s, iLeaf fd s -> xspec lp bm bc oc0 SafeB nl MC fd s.
  Proof. intros fd s (fid & b & Hf & Hs & Hff). exact (Hlf fid s b fd Hf Hs Hff). Qed.

  Theorem tab_xspec : forall fid s b fd, ut_find fid (tab_ut tab ++ lf) = Some s ->
      Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      xspec lp bm bc oc0 SafeB nl MC fd s.
  Proof.
    intros fid s b fd Hf Hs Hff.
    exact (xgood_spec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn nl HNL MC cl HMC obj_gs Hgs
             _ oit iLeaf i_leaf_ok i_tab_good i_it_good fd s (i_tab_good fid s Hf b fd Hs Hff)).
  Qed.
End INST.

(* ---------------------------------------------------------------------- *)
(* 3. The leaves, the sub-contracts, the whole-walk frame.                  *)
(* ---------------------------------------------------------------------- *)

Definition open2 : utab := [
  (object_helpers._cur_obj_call_action_function, ([kS], kA, true)) ].

Section FRAME.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.

  (* the FPU floor (TRUST 3.5) *)
  Hypothesis Hsq : sqrtf_spec.
  (* every linked variable outside non_safeb_syms is SafeB (ObjKit.obj_gs_safe_wit) *)
  Hypothesis Hgs : forall x b, mem_id x obj_gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.

  Section NL.
    Variable nl : block.
    Hypothesis HNL : HnB lp bm SafeB nl.

    Lemma xleaf_sqrtf : forall MC b fd,
        Genv.find_symbol ge math_util._sqrtf = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl MC fd ([kN], kA, false).
    Proof.
      intros MC b fd Hs Hff nb0 HN m vargs t m' vres Hevf _ Hi.
      rewrite (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hevf).
      split; [ exact Hi | split; [ intros bb oo _; exact I | ] ].
      split; [ exact (Mem.unchanged_on_refl _ _) | apply XS_refl ].
    Qed.

    (* a frame at nextblock m fixes the blocks in [nl, nb0) *)
    Lemma FR_XS : forall MC nb0 m m', Ple nb0 (Mem.nextblock m) ->
        FR lp bm SafeB (Mem.nextblock m) MC m m' -> XS SafeB nl nb0 m m'.
    Proof.
      intros MC nb0 m m' Hnb HF. apply (XS_unch SafeB nl nb0 m m' Hnb).
      unfold FR in HF. eapply Mem.unchanged_on_implies; [ exact HF | ].
      intros b ofs (Hl & Hlt) _ Hfp. pose proof HNL as (Hbm & Hsf & Hgl).
      destruct Hfp as [Hs | [Hp | [(g & Hg & _) | (-> & _)]]].
      - exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Hsf _ Hs) Hl)).
      - exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Plt_Ple_trans _ _ _ Hlt Hnb) Hp)).
      - exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Hgl _ _ Hg) Hl)).
      - exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hbm Hl)).
    Qed.

    Lemma xleaf_play_sound : forall MC b fd,
        Genv.find_symbol ge audio_external._play_sound = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl MC fd ([kA; kA], kA, false).
    Proof.
      intros MC b fd Hsy Hff nb0 HN m vargs t m' vres Hevf Hva Hi.
      destruct (UpdateCameraBody.leaf_play_sound lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn nl HNL
                  b fd Hsy Hff nb0 HN m vargs t m' vres Hevf Hva Hi) as (Hi' & Hr).
      split; [ exact Hi' | split; [ exact Hr | ] ].
      cut (Mem.unchanged_on (fun b _ => ~ GBu lp b) m m').
      { intros HG. split.
        - unfold FR. eapply Mem.unchanged_on_implies; [ exact HG | ].
          intros b0 ofs Hn0 _ Hg0. apply Hn0. right; right; left. exact Hg0.
        - apply (XS_unch SafeB nl nb0 m m' (proj1 (proj2 Hi))).
          eapply Mem.unchanged_on_implies; [ exact HG | ].
          intros b0 ofs (Hl & _) _ (g & Hg & _). pose proof HNL as (_ & _ & Hgl).
          exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Hgl _ _ Hg) Hl)). }
      destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_audio_external lp H12)
                  CameraModeBody.dm_ps) as (b' & Hs' & Hff').
      change camera._play_sound with audio_external._play_sound in Hs'.
      unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-.
      pose proof gnm_ps as Hchk.
      unfold gstore_nm in Hchk. apply andb_prop in Hchk as [Hv Hw].
      assert (Hvars : fn_vars audio_external.f_play_sound = nil)
        by (destruct (fn_vars audio_external.f_play_sound); [ reflexivity | discriminate Hv ]).
      inv Hevf.
      match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
      match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hvars in Ha; inv Ha end.
      match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
      replace (blocks_of_env _ empty_env) with (@nil (block * Z * Z)) in Hfree by reflexivity.
      cbn [Mem.free_list] in Hfree. injection Hfree as <-.
      lazymatch goal with Hb : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _ |- _ =>
        refine (proj1 (SpawnBodies.sw_walk (lp_ge lp) E
                    (fun mm => Mem.unchanged_on (fun b _ => ~ GBu lp b) M1 mm)
                    (fun _ => True) (fun _ => True)
                    (fun _ _ => true)
                    (fun l _ => match SaveFileBody.groot_l l with
                                | Some g => negb (mem_id g ObjExtBodies.mwf_syms)
                                | None => false
                                end)
                    (fun _ _ _ => false) (fun _ => true)
                    ltac:(intros; exact I)
                    _
                    ltac:(intros ? ? ? ? ? ? ? ? ? J1; discriminate J1)
                    ltac:(intros; exact I)
                    _ _ _ _ _ _ _ _ Hb eq_refl Hw I (Mem.unchanged_on_refl _ _)))
      end.
      intros l0 r0 le0 m0 t0 le0' m0' out0 Hok _ Hx HF0.
      cbv beta in Hok.
      destruct (SaveFileBody.groot_l l0) as [g|] eqn:Hg; [ | discriminate Hok ].
      apply negb_true_iff in Hok.
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
        pose proof (SaveFileBody.groot_l_blk _ _ _ _ _ _ _ _ Hg Hl) as Hgs' end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
      eapply Mem.unchanged_on_trans; [ exact HF0 | ].
      apply (assign_loc_unch _ _ _ _ _ _ _ _ _ Hal).
      intros i Hn'. apply Hn'. exists g. split; [ exact Hgs' | exact Hok ].
    Qed.

    (* Mario's block is not SafeB, not fresh, not a non-MWF global: the
       frame pins every Mario cell outside MC *)
    Lemma FR_mario : forall MC m m', FR lp bm SafeB nl MC m m' ->
        Mem.unchanged_on (fun b ofs => b = bm /\ ~ MC ofs) m m'.
    Proof.
      intros MC m m' H. unfold FR in H.
      eapply Mem.unchanged_on_implies; [ exact H | ].
      intros b ofs (-> & Hmc) _ Hfp. unfold FP in Hfp.
      destruct HNL as (Hbm & _ & _).
      destruct Hfp as [Hs | [Hp | [(g & Hg & Hnm) | (_ & Hm)]]].
      - exact (uk_not_bm lp bm bc oc0 SafeB HSafeB_syms Hspawn bm Hs eq_refl).
      - exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hbm Hp)).
      - pose proof (x_gms_bm lp bm bc oc0 Hspawn) as Hgb.
        destruct (peq g level_update._gMarioStates) as [-> | Hne];
          [ rewrite gms_in_mwf in Hnm; discriminate Hnm | ].
        exact (Genv.global_addresses_distinct _ Hne Hg Hgb eq_refl).
      - exact (Hmc Hm).
    Qed.
    (* the three bodies UcKit left open, each walked with its own cells *)
    Lemma push_xspec : forall b fd,
        Genv.find_symbol ge object_helpers._cur_obj_push_mario_away = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl (in_mcells pos_cells) fd ([kN], kA, false).
    Proof.
      intros b fd Hs Hff.
      assert (Hlf : forall fid s b0 fd0, ut_find fid [sq_leaf] = Some s ->
                 Genv.find_symbol ge fid = Some b0 -> Genv.find_funct ge (Vptr b0 Ptrofs.zero) = Some fd0 ->
                 xspec lp bm bc oc0 SafeB nl (in_mcells pos_cells) fd0 s).
      { intros fid s b0 fd0 Hf Hs0 Hff0. unfold ut_find, sq_leaf in Hf. cbn [find fst] in Hf.
        destruct (Pos.eqb math_util._sqrtf fid) eqn:E; [ | discriminate Hf ].
        apply Pos.eqb_eq in E. subst fid. cbv beta iota in Hf. injection Hf as <-.
        exact (xleaf_sqrtf _ b0 fd0 Hs0 Hff0). }
      exact (tab_xspec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hgs nl HNL
               (in_mcells pos_cells) pos_cells (fun o H => H) [x_push] [sq_leaf] push_walk_ok Hlf
               object_helpers._cur_obj_push_mario_away _ b fd eq_refl Hs Hff).
    Qed.

    Lemma one_up_xspec : forall b fd,
        Genv.find_symbol ge obj_behaviors._bhv_1up_interact = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl (in_mcells lives_cells) fd ([], kA, false).
    Proof.
      intros b fd Hs Hff.
      assert (Hlf : forall fid s b0 fd0, ut_find fid [ps_leaf] = Some s ->
                 Genv.find_symbol ge fid = Some b0 -> Genv.find_funct ge (Vptr b0 Ptrofs.zero) = Some fd0 ->
                 xspec lp bm bc oc0 SafeB nl (in_mcells lives_cells) fd0 s).
      { intros fid s b0 fd0 Hf Hs0 Hff0. unfold ut_find, ps_leaf in Hf. cbn [find fst] in Hf.
        destruct (Pos.eqb audio_external._play_sound fid) eqn:E; [ | discriminate Hf ].
        apply Pos.eqb_eq in E. subst fid. cbv beta iota in Hf. injection Hf as <-.
        exact (xleaf_play_sound _ b0 fd0 Hs0 Hff0). }
      exact (tab_xspec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hgs nl HNL
               (in_mcells lives_cells) lives_cells (fun o H => H) [x_1up; x_coll] [ps_leaf]
               one_up_walk_ok Hlf obj_behaviors._bhv_1up_interact _ b fd eq_refl Hs Hff).
    Qed.

    Lemma cutscene_xspec : forall b fd,
        Genv.find_symbol ge camera._start_object_cutscene = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl (in_mcells []) fd ([kN; kS], kA, false).
    Proof.
      intros b fd Hs Hff.
      assert (Hlf : forall fid s b0 fd0, ut_find fid [] = Some s ->
                 Genv.find_symbol ge fid = Some b0 -> Genv.find_funct ge (Vptr b0 Ptrofs.zero) = Some fd0 ->
                 xspec lp bm bc oc0 SafeB nl (in_mcells []) fd0 s).
      { intros fid s b0 fd0 Hf. discriminate Hf. }
      exact (tab_xspec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hgs nl HNL
               (in_mcells []) [] (fun o H => H) [x_cutscene] [] cutscene_walk_ok Hlf
               camera._start_object_cutscene _ b fd eq_refl Hs Hff).
    Qed.

    Lemma updfloor_xspec : forall b fd,
        Genv.find_symbol ge object_helpers._cur_obj_update_floor = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl (in_mcells []) fd ([], kA, false).
    Proof.
      intros b fd Hs Hff.
      assert (Hlf : forall fid s b0 fd0, ut_find fid [] = Some s ->
                 Genv.find_symbol ge fid = Some b0 -> Genv.find_funct ge (Vptr b0 Ptrofs.zero) = Some fd0 ->
                 xspec lp bm bc oc0 SafeB nl (in_mcells []) fd0 s).
      { intros fid s b0 fd0 Hf. discriminate Hf. }
      exact (tab_xspec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hgs nl HNL
               (in_mcells []) [] (fun o H => H) uf_tab [] updfloor_walk_ok Hlf
               object_helpers._cur_obj_update_floor _ b fd eq_refl Hs Hff).
    Qed.
  End NL.

  Lemma x2u : forall nl MC fd s, xspec lp bm bc oc0 SafeB nl MC fd s -> uspec lp bm bc oc0 SafeB nl fd s.
  Proof.
    intros nl MC fd [[pcs rc] dm] H nb0 HN m vargs t m' vres Hev Hva Hi.
    destruct (H nb0 HN m vargs t m' vres Hev Hva Hi) as (A & B & _). exact (conj A B).
  Qed.

  Lemma ui0 : forall m dm, ow_facts bm MWF m ->
      UInv lp bm bc oc0 SafeB (Mem.nextblock m) dm (Mem.nextblock m) m.
  Proof.
    intros m dm Hof. split; [ exact Hof | split; [ apply Ple_refl | ] ].
    intros _. exact (rl_fresh lp SafeB _ _ m eq_refl).
  Qed.

  (* ==================================================================== *)
  (* THE NAMED SUB-CONTRACTS (Mario-state escapes, each tied to its body) *)
  (* ==================================================================== *)

  (* cur_obj_push_mario_away(radius): keeps mem_ok; of Mario's state it
     writes only pos[0] and pos[2] *)
  Theorem push_mario_away_contract : forall b fd m v t m' vres,
      Genv.find_symbol ge object_helpers._cur_obj_push_mario_away = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd [v] t m' vres ->
      (forall bb oo, v <> Vptr bb oo) ->
      ow_facts bm MWF m ->
      ow_facts bm MWF m'
      /\ FR lp bm SafeB (Mem.nextblock m) (in_mcells pos_cells) m m'
      /\ Mem.unchanged_on (fun b ofs => b = bm /\ ~ in_mcells pos_cells ofs) m m'.
  Proof.
    intros b fd m v t m' vres Hs Hff Hevf Hv Hof.
    pose proof (UpdateCameraBody.uc_HnB lp bm bc oc0 SafeB m Hof) as HNL.
    assert (Hva : Forall2 (uvok lp SafeB (Mem.nextblock m) (Mem.nextblock m)) [kN] [v]).
    { constructor; [ | constructor ]. intros bb oo E. exact (Hv bb oo E). }
    destruct (push_xspec _ HNL b fd Hs Hff _ (Ple_refl _) m [v] t m' vres Hevf Hva (ui0 m false Hof))
      as ((Hof' & _) & _ & HF & _).
    exact (conj Hof' (conj HF (FR_mario _ HNL _ m m' HF))).
  Qed.

  (* bhv_1up_interact(): keeps mem_ok; of Mario's state it writes only
     numLives (gMarioState->numLives++) *)
  Theorem one_up_contract : forall b fd m t m' vres,
      Genv.find_symbol ge obj_behaviors._bhv_1up_interact = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd [] t m' vres ->
      ow_facts bm MWF m ->
      ow_facts bm MWF m'
      /\ FR lp bm SafeB (Mem.nextblock m) (in_mcells lives_cells) m m'
      /\ Mem.unchanged_on (fun b ofs => b = bm /\ ~ in_mcells lives_cells ofs) m m'.
  Proof.
    intros b fd m t m' vres Hs Hff Hevf Hof.
    pose proof (UpdateCameraBody.uc_HnB lp bm bc oc0 SafeB m Hof) as HNL.
    destruct (one_up_xspec _ HNL b fd Hs Hff _ (Ple_refl _) m [] t m' vres Hevf (Forall2_nil _)
                (ui0 m false Hof)) as ((Hof' & _) & _ & HF & _).
    exact (conj Hof' (conj HF (FR_mario _ HNL _ m m' HF))).
  Qed.

  (* start_object_cutscene(cutscene, o): keeps mem_ok; writes no Mario cell
     (gCutsceneFocus := o is a stored global) *)
  Theorem object_cutscene_contract : forall b fd m v1 v2 t m' vres,
      Genv.find_symbol ge camera._start_object_cutscene = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd [v1; v2] t m' vres ->
      (forall bb oo, v1 <> Vptr bb oo) ->
      (forall bb oo, v2 = Vptr bb oo -> SafeB bb) ->
      ow_facts bm MWF m ->
      ow_facts bm MWF m'
      /\ FR lp bm SafeB (Mem.nextblock m) (in_mcells []) m m'
      /\ Mem.unchanged_on (fun b ofs => b = bm) m m'.
  Proof.
    intros b fd m v1 v2 t m' vres Hs Hff Hevf Hv1 Hv2 Hof.
    pose proof (UpdateCameraBody.uc_HnB lp bm bc oc0 SafeB m Hof) as HNL.
    assert (Hva : Forall2 (uvok lp SafeB (Mem.nextblock m) (Mem.nextblock m)) [kN; kS] [v1; v2]).
    { constructor; [ intros bb oo E; exact (Hv1 bb oo E) | constructor; [ | constructor ] ].
      intros bb oo E. exact (Hv2 bb oo E). }
    destruct (cutscene_xspec _ HNL b fd Hs Hff _ (Ple_refl _) m [v1; v2] t m' vres Hevf Hva
                (ui0 m false Hof)) as ((Hof' & _) & _ & HF & _).
    split; [ exact Hof' | split; [ exact HF | ] ].
    eapply Mem.unchanged_on_implies; [ exact (FR_mario _ HNL _ m m' HF) | ].
    intros b0 ofs E _. split; [ exact E | intros (c & Hin & _); destruct Hin ].
  Qed.

  (* ObjKit's mem_ok theorem with its open leaves cut from five to two *)
  Section PRES.
    Hypothesis Hls : FloorsSurface.call_pres_ext lp bm (fun m => AGates.ctl_a_clear m bm) MWF
                       audio_external._load_sequence.
    Hypothesis Hopen2u : forall nl, HnB lp bm SafeB nl ->
        forall fid s b fd, ut_find fid open2 = Some s ->
        Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        uspec lp bm bc oc0 SafeB nl fd s.

    Theorem obj_body_pres2 : forall fid rc dm b fd m t m' vres,
        ut_find fid out = Some (nil, rc, dm) ->
        Genv.find_symbol ge fid = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        eval_funcall function_entry2 ge m fd nil t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
    Proof.
      apply (obj_body_pres lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hsq Hls Hgs).
      intros nl HNL fid s b fd Hf Hs Hff.
      unfold ut_find, open_leaf in Hf. cbn [find fst] in Hf.
      destruct (Pos.eqb camera._start_object_cutscene fid) eqn:E1.
      { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (x2u _ _ _ _ (cutscene_xspec nl HNL b fd Hs Hff)). }
      destruct (Pos.eqb object_helpers._cur_obj_update_floor fid) eqn:E2.
      { apply Pos.eqb_eq in E2. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (x2u _ _ _ _ (updfloor_xspec nl HNL b fd Hs Hff)). }
      destruct (Pos.eqb object_helpers._cur_obj_call_action_function fid) eqn:E3.
      { apply Pos.eqb_eq in E3. subst fid. cbv beta iota in Hf; injection Hf as <-.
        apply (Hopen2u nl HNL object_helpers._cur_obj_call_action_function _ b fd); [ reflexivity | exact Hs | exact Hff ]. }
      destruct (Pos.eqb obj_behaviors._bhv_1up_interact fid) eqn:E4.
      { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (x2u _ _ _ _ (one_up_xspec nl HNL b fd Hs Hff)). }
      destruct (Pos.eqb object_helpers._cur_obj_push_mario_away fid) eqn:E5.
      { apply Pos.eqb_eq in E5. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (x2u _ _ _ _ (push_xspec nl HNL b fd Hs Hff)). }
      discriminate Hf.
    Qed.
  End PRES.

  (* ==================================================================== *)
  (* THE WHOLE-WALK FRAME                                                  *)
  (* ==================================================================== *)
  (* load_sequence's footprint (LsContract.ls_frame) is a frame: its blocks
     are non-MWF globals *)
  Lemma ls_FR : forall MC, ls_frame lp ->
      forall b fd, Genv.find_symbol ge audio_external._load_sequence = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres ->
      FR lp bm SafeB (Mem.nextblock m) MC m m'.
  Proof.
    intros MC Hlf b fd Hs Hff m vargs t m' vres Hevf.
    assert (Hres : EngineV2Consumer.resolves_lp lp audio_external._load_sequence fd)
      by (exists b; split; [ exact Hs | exact Hff ]).
    destruct (Hlf fd m vargs t m' vres Hevf Hres) as (HU & _).
    unfold FR. eapply Mem.unchanged_on_implies; [ exact HU | ].
    intros b0 ofs Hn _ (g & Hg & Hgb). apply Hn. right; right; left.
    exists g. split; [ exact Hgb | exact (ls_ids_nm g Hg) ].
  Qed.

  Section WHOLE.
    (* THE LABELED AUDIO PREMISE (TRUST 4.1): GOAL 1's row and load_sequence's
       footprint (LsContract) *)
    Hypothesis Hlsc : ls_contract lp bm (fun m => AGates.ctl_a_clear m bm) MWF.
    Let Hls := proj1 Hlsc.
    (* the Mario cells the frame allows: at least the walked bodies' *)
    Variable MC : Z -> Prop.
    Hypothesis HMC : forall ofs, in_mcells mcells ofs -> MC ofs.
    (* set_mario_npc_dialog's Mario writes (NpcFrame.npc_cells, through
       set_mario_action): MC must hold them *)
    Hypothesis HMCn : forall ofs, in_mcells npc_cells ofs -> MC ofs.
    Let Hnpc_fr := npc_dialog_frame lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn MC HMCn.

    Lemma Hfr_open : forall fid b fd,
        (fid = audio_external._load_sequence \/ fid = mario_actions_cutscene._set_mario_npc_dialog) ->
        Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres ->
        ow_facts bm MWF m -> FR lp bm SafeB (Mem.nextblock m) MC m m'.
    Proof.
      intros fid b fd [-> | ->] Hs Hff m vargs t m' vres Hevf Hof.
      - exact (ls_FR MC (proj2 Hlsc) b fd Hs Hff m vargs t m' vres Hevf).
      - exact (Hnpc_fr b fd Hs Hff m vargs t m' vres Hevf Hof).
    Qed.
    (* OPEN: cur_obj_call_action_function (its table is a writable global) *)
    Hypothesis Hopen2 : forall nl, HnB lp bm SafeB nl ->
        forall fid s b fd, ut_find fid open2 = Some s ->
        Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        xspec lp bm bc oc0 SafeB nl MC fd s.

    Section NL2.
      Variable nl : block.
      Hypothesis HNL : HnB lp bm SafeB nl.

      Lemma xleaf_dirty : forall fid b fd pcs,
          ObjExtBodies.sym_pres lp bm bc oc0 SafeB fid ->
          (fid = audio_external._load_sequence \/ fid = mario_actions_cutscene._set_mario_npc_dialog) ->
          Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
          xspec lp bm bc oc0 SafeB nl MC fd (pcs, kA, true).
      Proof.
        intros fid b fd pcs Hsp Hid Hs Hff nb0 HN m vargs t m' vres Hevf Hva Hi.
        destruct (UpdateCameraBody.leaf_dirty lp bm bc oc0 SafeB nl fid b fd pcs Hsp Hs Hff
                    nb0 HN m vargs t m' vres Hevf Hva Hi) as (Hi' & Hr).
        split; [ exact Hi' | split; [ exact Hr | ] ].
        destruct Hi as (Hof & Hnb & _).
        pose proof (Hfr_open fid b fd Hid Hs Hff m vargs t m' vres Hevf Hof) as HF.
        split; [ | exact (FR_XS nl HNL MC nb0 m m' Hnb HF) ].
        apply (FR_mono lp bm SafeB MC nl (Mem.nextblock m)); [ exact (Ple_trans _ _ _ HN Hnb) | ].
        exact HF.
      Qed.

      Lemma xleaf_ok : forall fid s b fd, ut_find fid xleaf = Some s ->
          Genv.find_symbol ge fid = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
          xspec lp bm bc oc0 SafeB nl MC fd s.
      Proof.
        intros fid s b fd Hf Hs Hff.
        unfold ut_find, xleaf, sq_leaf, ps_leaf in Hf. cbn [find fst] in Hf.
        destruct (Pos.eqb math_util._sqrtf fid) eqn:E1.
        { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
          exact (xleaf_sqrtf nl MC b fd Hs Hff). }
        destruct (Pos.eqb audio_external._play_sound fid) eqn:E2.
        { apply Pos.eqb_eq in E2. subst fid. cbv beta iota in Hf; injection Hf as <-.
          exact (xleaf_play_sound nl HNL MC b fd Hs Hff). }
        destruct (Pos.eqb audio_external._load_sequence fid) eqn:E3.
        { apply Pos.eqb_eq in E3. subst fid. cbv beta iota in Hf; injection Hf as <-.
          exact (xleaf_dirty _ b fd _ (AudioBodies.sp_ls lp bm bc oc0 SafeB Hls)
                   (or_introl eq_refl) Hs Hff). }
        destruct (Pos.eqb mario_actions_cutscene._set_mario_npc_dialog fid) eqn:E4.
        { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
          exact (xleaf_dirty _ b fd _
                   (NpcDialogBody.sp_npc_dialog lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn)
                   (or_intror eq_refl) Hs Hff). }
        apply (Hopen2 nl HNL fid s b fd); [ | exact Hs | exact Hff ].
        unfold ut_find, open2. cbn [find fst]. exact Hf.
      Qed.
    End NL2.

    (* THE RESULT.  Every walked nullary body (the live natives, the
       behavior command functions, ...) run from a memory with GOAL 1's
       carried facts keeps them, and changes memory only in SafeB blocks,
       blocks it allocates, globals MWF does not read, and Mario cells in
       MC.  In particular (FR_mario) Mario's state changes only in MC. *)
    Theorem obj_body_frame : forall fid rc dm b fd m t m' vres,
        ut_find fid xout = Some (nil, rc, dm) ->
        Genv.find_symbol ge fid = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        eval_funcall function_entry2 ge m fd nil t m' vres ->
        ow_facts bm MWF m ->
        ow_facts bm MWF m' /\ FR lp bm SafeB (Mem.nextblock m) MC m m'
        /\ Mem.unchanged_on (fun b ofs => b = bm /\ ~ MC ofs) m m'.
    Proof.
      intros fid rc dm b fd m t m' vres Hf Hs Hff Hevf Hof.
      set (nl := Mem.nextblock m).
      pose proof (UpdateCameraBody.uc_HnB lp bm bc oc0 SafeB m Hof) as HNL.
      pose proof (tab_xspec lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hgs nl HNL MC mcells HMC
                    xotab xleaf xt_walk_ok (xleaf_ok nl HNL) fid _ b fd Hf Hs Hff) as Hsp.
      assert (Hi : UInv lp bm bc oc0 SafeB nl dm nl m)
        by (split; [ exact Hof | split; [ apply Ple_refl | intros _; exact (rl_fresh lp SafeB nl nl m eq_refl) ] ]).
      destruct (Hsp nl (Ple_refl _) m nil t m' vres Hevf (Forall2_nil _) Hi) as ((Hof' & _) & _ & HF & _).
      exact (conj Hof' (conj HF (FR_mario nl HNL MC m m' HF))).
    Qed.
  End WHOLE.
End FRAME.

(* ---------------------------------------------------------------------- *)
(* 4. NON-VACUITY: what the frame covers.                                   *)
(* ---------------------------------------------------------------------- *)

Definition xnullary (x : ident) : bool :=
  match ut_find x xout with Some (nil, _, _) => true | _ => false end.

(* the same 104 live natives as ObjKit, now with the frame *)
Lemma frame_natives_count :
  List.length (filter xnullary BehaviorScripts.wmotr_live_natives) = 104%nat.
Proof. vm_compute. reflexivity. Qed.

(* 392 entries, 391 bodies: the getter is walked twice (kS here, kW in otab) *)
Lemma xotab_count : List.length xotab = 392%nat.
Proof. reflexivity. Qed.
