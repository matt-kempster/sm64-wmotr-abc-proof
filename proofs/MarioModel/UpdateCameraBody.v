(* ====================================================================== *)
(* UpdateCameraBody.v -- update_camera(gCurrentArea->camera) keeps GOAL   *)
(* 1's carried facts, proved from the REAL camera.c and its callees.      *)
(*                                                                        *)
(* The call tree (camera.c:3011 and down): 507 walked bodies -- camera.c  *)
(* 467, audio_external 12, math_util 10, surface_collision 9, ingame_menu *)
(* 3, behavior_script 2, object_helpers 2, save_file 1, hud 1 (TU 51:    *)
(* set_hud_camera_status stores the hud.c static sCameraHUDStatus, a     *)
(* global MWF does not read: class kW) -- including every                 *)
(* member of the two writable function-pointer tables' types:             *)
(*   CameraEvent      void ( * )(struct Camera * )   336 functions        *)
(*     (sCutsceneShots / the area trigger tables / play_cutscene; it      *)
(*      contains update_camera itself, so the tree is cyclic);            *)
(*   CameraTransition s32 ( * )(struct Camera *, Vec3f, Vec3f)  14.       *)
(* A writable table may hold ANY function of its type in an arbitrary    *)
(* memory, so the indirect call is covered by a TYPE CERTIFICATE: every   *)
(* linked function of that type is one of the listed ids (all_evt_ok,     *)
(* CameraModeBody.all_trans_ok, one vm sweep over every linked TU).       *)
(*                                                                        *)
(* The walk is UcKit's recursive two-mode class walker; the signatures   *)
(* are UcTable's (generated, re-checked here by uc_walk_ok).  Five leaves *)
(* are proved outside the walk (section 3):                               *)
(*   sqrtf                  the FPU floor sqrtf_spec (TRUST 3.5)          *)
(*   play_sound             AudioBodies + its global-only stores          *)
(*   save_file_do_save      SaveDoSaveBody, on the OS / DMA floor         *)
(*   load_sequence          the labeled audio premise Hls (TRUST 4.1)     *)
(*   set_mario_npc_dialog   NpcDialogBody, from its real body (its        *)
(*                          gMarioState stores + GOAL 1's set_mario_action *)
(*                          keystone row)                                 *)
(*                                                                        *)
(* Section 5 is the vm-pinned STORE CENSUS: which stores of the walked    *)
(* bodies land outside the camera-private class (cam_store_ids + the     *)
(* Camera struct + stack locals).  Those are where a carry of a GOAL-2   *)
(* invariant across update_camera can fail.                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario camera math_util surface_collision audio_external
  behavior_script ingame_menu object_helpers save_file mario_actions_cutscene hud.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathBodies
  LinkedTwelve LocalVarsSurface SpawnBodies MathGeomGated FpuFloor UcKit UcTable.
From SM64.Proofs Require CameraModeBody MtxfBody SaveDoSaveBody AudioBodies
  ObjExtBodies PrintBodies InitMemSat OsDmaFloor SaveFileBody FloorsSurface NpcDialogBody.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. The CameraEvent type certificate.                                     *)
(* ---------------------------------------------------------------------- *)

(* per TU: a function of type ty is one of ids *)
Definition tu_ty_ok (ty : type) (ids : list ident) (q : Clight.program) : bool :=
  PTree_Properties.for_all (prog_defmap q) (fun id gd =>
    match gd with
    | Gfun fd => if type_eq (type_of_fundef fd) ty then mem_id id ids else true
    | Gvar _ => true
    end).

(* THE CERTIFICATE: every linked function of the CameraEvent type is one of
   the 336 (one vm sweep over every linked TU) *)
Lemma all_evt_ok : forallb (tu_ty_ok evt_ty evt_ids) (mario.prog :: tu_rest) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma tu_ty_ok_fd : forall ty ids q id fd,
    tu_ty_ok ty ids q = true -> (prog_defmap q) ! id = Some (Gfun fd) ->
    type_of_fundef fd = ty -> mem_id id ids = true.
Proof.
  intros ty ids q id fd Hok Hdm Hty. unfold tu_ty_ok in Hok.
  pose proof (proj1 (PTree_Properties.for_all_correct _ _) Hok id (Gfun fd) Hdm) as Hrow.
  cbv beta iota in Hrow. rewrite Hty in Hrow.
  destruct (type_eq ty ty) as [_ | N]; [ exact Hrow | exact (False_ind _ (N eq_refl)) ].
Qed.

Lemma ty_fd_ids : forall ty ids, forallb (tu_ty_ok ty ids) (mario.prog :: tu_rest) = true ->
    forall lp, linked12 lp -> forall b fd,
    Genv.find_funct_ptr (lp_ge lp) b = Some fd -> type_of_fundef fd = ty ->
    exists id, mem_id id ids = true /\ (prog_defmap lp) ! id = Some (Gfun fd).
Proof.
  intros ty ids Hall lp H12 b fd Hfp Hty.
  apply Genv.find_funct_ptr_iff in Hfp.
  destruct (Genv.find_def_inversion _ _ Hfp) as (id & Hin).
  assert (Hnr : list_norepet (prog_defs_names lp)).
  { unfold linked12 in H12.
    apply (InitMemSat.link_chain_norepet tu_rest mario.prog lp); [ discriminate | exact H12 ]. }
  assert (Hdm : (prog_defmap lp) ! id = Some (Gfun fd))
    by (apply prog_defmap_norepet; assumption).
  exists id. split; [ | exact Hdm ].
  cbn [forallb] in Hall. apply andb_prop in Hall as [Hm Hr].
  unfold linked12 in H12.
  destruct (CameraModeBody.link_chain_def_origin _ _ _ _ _ H12 Hdm) as [Hq | (q & Hq & Hqd)].
  - exact (tu_ty_ok_fd _ _ _ _ _ Hm Hq Hty).
  - exact (tu_ty_ok_fd _ _ _ _ _ (proj1 (forallb_forall _ _) Hr q Hq) Hqd Hty).
Qed.

(* NON-VACUITY: the real tables hold these functions (every addrof target
   of the cutscene-shot tables is a CameraEvent id) *)
Example cutscene_shots_cover :
  forallb (fun ini => match ini with
                      | Init_addrof f _ => mem_id f evt_ids
                      | _ => true end)
    (gvar_init camera.v_sCutsceneEnterCannon) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. THE WALK: every one of the 507 bodies passes its class check against *)
(*    the one table (the whole recursive tree, the caller itself          *)
(*    included), and every table member fits its indirect signature.      *)
(* ---------------------------------------------------------------------- *)

Definition uc_gs : list ident := camera_safe_syms.

Definition uc_ent_ok (e : ident * utu * usig) : bool :=
  let '(fid, tu, s) := e in
  match (prog_defmap (uprog tu)) ! fid with
  | Some (Gfun (Internal f)) => uchk uc_gs uc_ut uc_it s f
  | _ => false
  end.

Lemma uc_walk_ok : forallb uc_ent_ok uc_walk = true.
Proof. vm_compute. reflexivity. Qed.

Definition fits_in (sg : usig) (id : ident) : bool :=
  match ut_find id uc_ut with Some se => fitsb se sg | None => false end.

Lemma evt_fit_ok : forallb (fits_in evt_sig) evt_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma trans_fit_ok : forallb (fits_in trans_sig) CameraModeBody.trans_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* NON-VACUITY: update_camera is walked, at its real signature *)
Lemma uc_entry_sig : ut_find camera._update_camera uc_ut = Some ([kS], kN, true).
Proof. vm_compute. reflexivity. Qed.

(* list facts, over abstract lists (no lookup into a vm-computed list) *)
Lemma ut_find_app : forall fid l1 l2 s,
    ut_find fid (l1 ++ l2) = Some s ->
    ut_find fid l1 = Some s \/ ut_find fid l2 = Some s.
Proof.
  intros fid l1 l2 s. induction l1 as [| [f s1] l1 IH]; intros H.
  - right. exact H.
  - unfold ut_find in H |- *. simpl in H |- *.
    destruct (Pos.eqb f fid).
    + left. exact H.
    + exact (IH H).
Qed.

Lemma ut_find_walk : forall (l : list (ident * utu * usig)) fid s,
    ut_find fid (map (fun e => let '(fid, _, s) := e in (fid, s)) l) = Some s ->
    exists tu, In (fid, tu, s) l.
Proof.
  induction l as [| [[f t] s'] l IH]; intros fid s H; [ discriminate H | ].
  unfold ut_find in H. simpl in H.
  destruct (Pos.eqb f fid) eqn:E.
  - apply Pos.eqb_eq in E. subst f. simpl in H. injection H as <-. exists t. left. reflexivity.
  - destruct (IH fid s H) as (tu & Hin). exists tu. right. exact Hin.
Qed.

Lemma mem_id_app_r : forall x l1 l2, mem_id x l2 = true -> mem_id x (l1 ++ l2) = true.
Proof.
  intros x l1 l2 H. induction l1 as [| y l1 IH]; [ exact H | ].
  unfold mem_id in *. cbn [app existsb]. rewrite IH. apply orb_true_r.
Qed.

Lemma mem_id_cons_r : forall x y l, mem_id x l = true -> mem_id x (y :: l) = true.
Proof.
  intros x y l H. unfold mem_id in *. cbn [existsb]. rewrite H. apply orb_true_r.
Qed.

(* ---------------------------------------------------------------------- *)
(* generic: a call never shrinks nextblock                               *)
(* ---------------------------------------------------------------------- *)

Lemma av_nextblock : forall ge e m vars e' m',
    alloc_variables ge e m vars e' m' -> Ple (Mem.nextblock m) (Mem.nextblock m').
Proof.
  intros ge e m vars e' m' H. induction H; [ apply Ple_refl | ].
  eapply Ple_trans; [ | exact IHalloc_variables ].
  rewrite (Mem.nextblock_alloc _ _ _ _ _ H). apply Ple_succ.
Qed.

Lemma free_list_nextblock : forall l m m',
    Mem.free_list m l = Some m' -> Mem.nextblock m' = Mem.nextblock m.
Proof.
  induction l as [| [[b lo] hi] l IH]; intros m m' H; cbn in H.
  - injection H as <-. reflexivity.
  - destruct (Mem.free m b lo hi) as [m1|] eqn:Hf; [ | discriminate H ].
    rewrite (IH _ _ H). exact (Mem.nextblock_free _ _ _ _ _ Hf).
Qed.

Lemma funcall_nextblock : forall ge,
    (forall e le m s t le' m' out, exec_stmt function_entry2 ge e le m s t le' m' out ->
       Ple (Mem.nextblock m) (Mem.nextblock m')) /\
    (forall m fd vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres ->
       Ple (Mem.nextblock m) (Mem.nextblock m')).
Proof.
  intros ge.
  apply (exec_stmt_funcall_ind function_entry2 ge
           (fun _ _ m _ _ _ m' _ => Ple (Mem.nextblock m) (Mem.nextblock m'))
           (fun m _ _ _ m' _ => Ple (Mem.nextblock m) (Mem.nextblock m')));
    intros; cbv beta;
    first
      [ apply Ple_refl
      | match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
          rewrite (CameraModeBody.assign_loc_nextblock _ _ _ _ _ _ _ _ Ha); apply Ple_refl end
      | match goal with H : external_call _ _ _ _ _ _ _ |- _ =>
          exact (external_call_nextblock _ _ _ _ _ _ _ H) end
      | match goal with He : function_entry2 _ _ _ _ _ _ _,
                        Hf : Mem.free_list _ _ = Some _ |- _ =>
          inv He; rewrite (free_list_nextblock _ _ _ Hf);
          match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
            eapply Ple_trans; [ exact (av_nextblock _ _ _ _ _ _ Ha) | assumption ] end end
      | assumption
      | solve [ eauto 4 using Ple_trans ] ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The section: the leaves, the table, the result.                       *)
(* ---------------------------------------------------------------------- *)

Section UC.
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
  (* the OS / DMA floor under save_file_do_save (TRUST 3.5) *)
  Hypothesis Hfloor : OsDmaFloor.os_dma_floor.
  (* the labeled audio premise (TRUST 4.1), as GOAL 1 carries it *)
  Hypothesis Hls : FloorsSurface.call_pres_ext lp bm (fun m => AGates.ctl_a_clear m bm) MWF
                     audio_external._load_sequence.

  (* the walk's SafeB globals *)
  Lemma uc_gs_safe : forall x b, mem_id x uc_gs = true ->
      Genv.find_symbol ge x = Some b -> SafeB b.
  Proof.
    intros x b Hx Hs. destruct HSafeB_syms as (_ & _ & Hc). apply (Hc x b); [ | exact Hs ].
    unfold safe_ptr_syms. apply mem_id_cons_r. repeat apply mem_id_app_r. exact Hx.
  Qed.

  (* nl: everything that exists when update_camera is entered lies below it *)
  Lemma uc_HnB : forall m, ow_facts bm MWF m -> HnB lp bm SafeB (Mem.nextblock m).
  Proof.
    intros m (Hv & _ & HM). split; [ exact Hv | split ].
    - intros b Hs. exact (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs).
    - intros gid bg Hg.
      exact (glob_valid_of_nextbound lp m (mwf_real_nextbound lp bm bc oc0 SafeB m HM) gid bg Hg).
  Qed.

  (* ---- the leaves ---- *)
  Definition uLeaf (fd : Clight.fundef) (s : usig) : Prop :=
    exists fid b, ut_find fid uc_leaf = Some s /\ Genv.find_symbol ge fid = Some b /\
                  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd.

  Section Leaves.
    Variable nl : block.
    Hypothesis HNL : HnB lp bm SafeB nl.

    (* a leaf that keeps the carried facts (sym_pres), in the dirty mode *)
    Lemma leaf_dirty : forall g b fd pcs,
        ObjExtBodies.sym_pres lp bm bc oc0 SafeB g ->
        Genv.find_symbol ge g = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        uspec lp bm bc oc0 SafeB nl fd (pcs, kA, true).
    Proof.
      intros g b fd pcs Hsp Hs Hff nb0 HN m vargs t m' vres Hevf _ (Hf & Hnb & _).
      assert (Hfp : Genv.find_funct_ptr ge b = Some fd)
        by (rewrite <- Genv.find_funct_find_funct_ptr; exact Hff).
      split; [ | intros bb oo _; exact I ].
      split; [ exact (Hsp b fd Hs Hfp m vargs t m' vres Hevf Hf) | split ].
      - exact (Ple_trans _ _ _ Hnb (proj2 (funcall_nextblock _) _ _ _ _ _ _ Hevf)).
      - intros E. discriminate E.
    Qed.

    (* a leaf that changes no memory: any mode *)
    Lemma leaf_memid : forall fd pcs dm,
        (forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres -> m' = m) ->
        uspec lp bm bc oc0 SafeB nl fd (pcs, kA, dm).
    Proof.
      intros fd pcs dm Hid nb0 HN m vargs t m' vres Hevf _ Hi.
      rewrite (Hid _ _ _ _ _ Hevf). split; [ exact Hi | intros bb oo _; exact I ].
    Qed.

    (* play_sound: keeps the carried facts (AudioBodies); no locals, no
       calls, every store global-rooted (below nb0): the clean mode *)
    Lemma leaf_play_sound : forall b fd,
        Genv.find_symbol ge audio_external._play_sound = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
        uspec lp bm bc oc0 SafeB nl fd ([kA; kA], kA, false).
    Proof.
      intros b fd Hsy Hff nb0 HN m vargs t m' vres Hevf _ (Hf & Hnb & HL).
      assert (Hfp : Genv.find_funct_ptr ge b = Some fd)
        by (rewrite <- Genv.find_funct_find_funct_ptr; exact Hff).
      pose proof (AudioBodies.sp_play_sound lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn
                    b fd Hsy Hfp m vargs t m' vres Hevf Hf) as Hf'.
      split; [ split; [ exact Hf' | ] | intros bb oo _; exact I ].
      destruct (hn_base lp bm SafeB nl HNL nb0 HN) as (_ & _ & Hn_glob).
      specialize (HL eq_refl).
      cut (Ple nb0 (Mem.nextblock m') /\ RLu lp SafeB nl nb0 m').
      { intros (A & B). split; [ exact A | intros _; exact B ]. }
      destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_audio_external lp H12)
                  CameraModeBody.dm_ps) as (b' & Hs' & Hff').
      change camera._play_sound with audio_external._play_sound in Hs'.
      unfold ge, lp_ge in Hsy, Hff. rewrite Hsy in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-.
      pose proof CameraModeBody.gso_ps as Hchk.
      unfold CameraModeBody.gstore_only in Hchk. apply andb_prop in Hchk as [Hv Hw].
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
                    (fun mm => Ple nb0 (Mem.nextblock mm) /\ RLu lp SafeB nl nb0 mm)
                    (fun _ => True) (fun _ => True)
                    (fun _ _ => true)
                    (fun l _ => match SaveFileBody.groot_l l with Some _ => true | None => false end)
                    (fun _ _ _ => false) (fun _ => true)
                    ltac:(intros; exact I)
                    _
                    ltac:(intros ? ? ? ? ? ? ? ? ? J1; discriminate J1)
                    ltac:(intros; exact I)
                    _ _ _ _ _ _ _ _ Hb eq_refl Hw I (conj Hnb HL)))
      end.
      intros l0 r0 le0 m0 t0 le0' m0' out0 Hok _ Hx (Hn0 & HL0).
      destruct (SaveFileBody.groot_l l0) as [g|] eqn:Hg; [ | discriminate Hok ].
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ l0 ?loc _ _ |- _ =>
        pose proof (SaveFileBody.groot_l_blk _ _ _ _ _ _ _ _ Hg Hl) as Hgs end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
      split; [ rewrite (CameraModeBody.assign_loc_nextblock _ _ _ _ _ _ _ _ Hal); exact Hn0 | ].
      intros b1 ofs1 b'' o'' Hb1 Hld.
      rewrite (MtxfBody.assign_loc_load_other _ _ _ _ _ _ _ _ _ _ _ Hal) in Hld.
      + exact (HL0 _ _ _ _ Hb1 Hld).
      + exact (ufresh_ne _ _ _ Hb1 (Hn_glob _ _ Hgs)).
    Qed.

    Lemma uc_leaf_ok : forall fd s, uLeaf fd s -> uspec lp bm bc oc0 SafeB nl fd s.
    Proof.
      intros fd s (fid & b & Hf & Hs & Hff).
      unfold ut_find, uc_leaf in Hf. cbn [find fst] in Hf.
      destruct (Pos.eqb math_util._sqrtf fid) eqn:E1.
      { apply Pos.eqb_eq in E1. subst fid. cbv beta iota in Hf; injection Hf as <-.
        apply leaf_memid. intros m vargs t m' vres Hevf.
        exact (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hff Hevf). }
      destruct (Pos.eqb audio_external._play_sound fid) eqn:E2.
      { apply Pos.eqb_eq in E2. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (leaf_play_sound b fd Hs Hff). }
      destruct (Pos.eqb save_file._save_file_do_save fid) eqn:E4.
      { apply Pos.eqb_eq in E4. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (leaf_dirty _ b fd _ (SaveDoSaveBody.sp_sds lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor)
                 Hs Hff). }
      destruct (Pos.eqb mario_actions_cutscene._set_mario_npc_dialog fid) eqn:E5.
      { apply Pos.eqb_eq in E5. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (leaf_dirty _ b fd _
                 (NpcDialogBody.sp_npc_dialog lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn) Hs Hff). }
      destruct (Pos.eqb audio_external._load_sequence fid) eqn:E6.
      { apply Pos.eqb_eq in E6. subst fid. cbv beta iota in Hf; injection Hf as <-.
        exact (leaf_dirty _ b fd _ (AudioBodies.sp_ls lp bm bc oc0 SafeB Hls) Hs Hff). }
      cbv beta iota in Hf; discriminate Hf.
    Qed.
  End Leaves.

  (* ---- the table ---- *)
  Lemma uLO : forall tu, linkorder (uprog tu) lp.
  Proof.
    destruct tu; cbn [uprog].
    - exact (linked12_LO_camera lp H12).
    - exact (linked12_LO_audio_external lp H12).
    - exact (linked12_LO_math lp H12).
    - exact (linked12_LO_surf lp H12).
    - exact (linked12_LO_ingame_menu lp H12).
    - exact (linked12_LO_behavior_script lp H12).
    - exact (linked12_LO_object_helpers lp H12).
    - exact (linked12_LO_save lp H12).
    - exact (linked12_LO_hud lp H12).
  Qed.

  Lemma uc_tab_good : TabGood lp uc_gs uc_ut uc_it uLeaf.
  Proof.
    intros fid s Hf b fd Hs Hff.
    unfold uc_ut in Hf. destruct (ut_find_app _ _ _ _ Hf) as [Hw | Hl].
    - destruct (ut_find_walk _ _ _ Hw) as (tu & Hin).
      pose proof (proj1 (forallb_forall _ _) uc_walk_ok _ Hin) as Hc.
      unfold uc_ent_ok in Hc.
      destruct ((prog_defmap (uprog tu)) ! fid) as [[[f|ef]|v]|] eqn:Edm; try discriminate Hc.
      left. exists f. split; [ | exact Hc ].
      destruct (linkorder_resolves_funct lp _ _ _ (uLO tu) Edm) as (b' & Hs' & Hff').
      unfold ge, lp_ge in Hs, Hff. rewrite Hs in Hs'. injection Hs' as <-.
      rewrite Hff' in Hff. injection Hff as <-. reflexivity.
    - right. exists fid, b. split; [ exact Hl | split; [ exact Hs | exact Hff ] ].
  Qed.

  Lemma fits_good : forall sg ids id b fd,
      forallb (fits_in sg) ids = true -> mem_id id ids = true ->
      Genv.find_symbol ge id = Some b -> Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      exists se, Good uc_gs uc_ut uc_it uLeaf fd se /\ fitsb se sg = true.
  Proof.
    intros sg ids id b fd Hall Hid Hs Hff.
    pose proof (proj1 (forallb_forall _ _) Hall id (MtxfBody.mem_id_In _ _ Hid)) as Hfit.
    unfold fits_in in Hfit.
    destruct (ut_find id uc_ut) as [se|] eqn:Ese; [ | discriminate Hfit ].
    exists se. split; [ exact (uc_tab_good id se Ese b fd Hs Hff) | exact Hfit ].
  Qed.

  Lemma uc_it_good : ItGood lp uc_gs uc_ut uc_it uLeaf.
  Proof.
    intros ty s Hf vf fd Hff Hty.
    destruct (Genv.find_funct_inv _ _ Hff) as (b & ->).
    pose proof Hff as Hfp. rewrite Genv.find_funct_find_funct_ptr in Hfp.
    unfold uit_find, uc_it in Hf. cbn [find fst] in Hf.
    destruct (type_eq evt_ty ty) as [<- | N1]; cbv beta iota delta [proj_sumbool] in Hf.
    - cbv beta iota in Hf; injection Hf as <-.
      destruct (ty_fd_ids _ _ all_evt_ok lp H12 b fd Hfp Hty) as (id & Hid & Hdm).
      destruct (proj1 (Genv.find_def_symbol _ _ _) Hdm) as (b' & Hs' & Hd').
      refine (fits_good _ _ id b' fd evt_fit_ok Hid Hs' _).
      rewrite Genv.find_funct_find_funct_ptr. apply Genv.find_funct_ptr_iff. exact Hd'.
    - destruct (type_eq CameraModeBody.trans_ty ty) as [<- | N2]; cbv beta iota delta [proj_sumbool] in Hf;
        [ | discriminate Hf ].
      cbv beta iota in Hf; injection Hf as <-.
      destruct (CameraModeBody.trans_fd_ids lp H12 b fd Hfp Hty) as (id & Hid & Hdm).
      destruct (proj1 (Genv.find_def_symbol _ _ _) Hdm) as (b' & Hs' & Hd').
      refine (fits_good _ _ id b' fd trans_fit_ok Hid Hs' _).
      rewrite Genv.find_funct_find_funct_ptr. apply Genv.find_funct_ptr_iff. exact Hd'.
  Qed.

  (* ==================================================================== *)
  (* 4. THE RESULT.  The real update_camera(c), called on any memory that *)
  (*    satisfies GOAL 1's carried facts with c a SafeB pointer (it is    *)
  (*    gCurrentArea->camera, a chase-reachable block) or no pointer,     *)
  (*    returns in a memory that still satisfies them.                     *)
  (* ==================================================================== *)
  Theorem update_camera_pres : forall b fd m c t m' vres,
      Genv.find_symbol ge camera._update_camera = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd [c] t m' vres ->
      (forall bb oo, c = Vptr bb oo -> SafeB bb) ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros b fd m c t m' vres Hs Hff Hevf Hc Hof.
    set (nl := Mem.nextblock m).
    pose proof (uc_HnB m Hof) as HNL.
    pose proof (good_spec lp bm bc oc0 SafeB HSafeB_syms Hspawn nl HNL uc_gs uc_gs_safe
                  uc_ut uc_it uLeaf (uc_leaf_ok nl HNL) uc_tab_good uc_it_good fd _
                  (uc_tab_good _ _ uc_entry_sig b fd Hs Hff)) as Hsp.
    assert (Hva : Forall2 (uvok lp SafeB nl nl) [kS] [c]).
    { constructor; [ intros bb oo E; exact (Hc bb oo E) | constructor ]. }
    assert (Hi : UInv lp bm bc oc0 SafeB nl true nl m).
    { split; [ exact Hof | split; [ apply Ple_refl | intros E; discriminate E ] ]. }
    destruct (Hsp nl (Ple_refl _) m [c] t m' vres Hevf Hva Hi) as ((Hof' & _) & _).
    exact Hof'.
  Qed.
End UC.
(* ---------------------------------------------------------------------- *)
(* 5. THE STORE CENSUS (syntactic, vm-pinned).  The camera-private class:   *)
(*    the stack locals, the Camera struct (a Camera-typed parameter, or     *)
(*    through gCamera), and cam_store_ids -- the camera.c globals no other *)
(*    source file names.  For every walked body, uc_census lists the roots  *)
(*    of its stores AND of the pointers it passes to callees that are NOT  *)
(*    in that class.  A root is resolved through the body's own temp       *)
(*    definitions; RPtr / RUnk are roots it could not resolve (pointers     *)
(*    loaded from memory or returned by calls).  Stores through a          *)
(*    non-Camera parameter are charged to the callers' arguments.  The     *)
(*    five leaves' effects are listed in UcTable.uc_leaf's comment and the  *)
(*    section-3 premises.  This is a census, not a proof obligation: the   *)
(*    theorem above holds whatever it says; the census says where a GOAL-2 *)
(*    invariant carried across update_camera can be broken.                *)
(* ---------------------------------------------------------------------- *)

Inductive sroot : Type :=
  | RLoc | RGlob (g : ident) | RVia (g : ident) | RParam (t : ident) | RPtr | RUnk.

Definition sroot_beq (a b : sroot) : bool :=
  match a, b with
  | RLoc, RLoc | RPtr, RPtr | RUnk, RUnk => true
  | RGlob x, RGlob y | RVia x, RVia y | RParam x, RParam y => Pos.eqb x y
  | _, _ => false
  end.

Fixpoint snodup (l : list sroot) : list sroot :=
  match l with
  | nil => nil
  | r :: l' => let t := snodup l' in if existsb (sroot_beq r) t then t else r :: t
  end.

Fixpoint c_sets (s : statement) : list (ident * expr) :=
  match s with
  | Sset t a => [(t, a)]
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => c_sets s1 ++ c_sets s2
  | Slabel _ s1 => c_sets s1
  | Sswitch _ sl => c_sets_ls sl
  | _ => nil
  end
with c_sets_ls (sl : labeled_statements) : list (ident * expr) :=
  match sl with LSnil => nil | LScons _ s sl' => c_sets s ++ c_sets_ls sl' end.

(* the lvalues stored to, and the pointer-typed call arguments *)
Fixpoint c_targets (s : statement) : list expr :=
  match s with
  | Sassign l _ => [Eaddrof l (Tpointer (typeof l) noattr)]
  | Scall _ _ al | Sbuiltin _ _ _ al =>
      filter (fun a => match typeof a with Tpointer _ _ | Tarray _ _ _ => true | _ => false end) al
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => c_targets s1 ++ c_targets s2
  | Slabel _ s1 => c_targets s1
  | Sswitch _ sl => c_targets_ls sl
  | _ => nil
  end
with c_targets_ls (sl : labeled_statements) : list expr :=
  match sl with LSnil => nil | LScons _ s sl' => c_targets s ++ c_targets_ls sl' end.

Section ROOT.
  Variable lv ps : list ident.
  Variable defs : list (ident * expr).
  (* the root block of a pointer-valued expression, depth-bounded *)
  Fixpoint proot (n : nat) (a : expr) : sroot :=
    match n with O => RUnk | S n' =>
    match a with
    | Evar x _ => if mem_id x lv then RLoc else RGlob x
    | Eaddrof a1 _ => lroot n' a1
    | Ecast a1 _ => proot n' a1
    | Ebinop _ a1 _ _ => proot n' a1
    | Etempvar t _ =>
        if mem_id t ps then RParam t else
        match find (fun p => Pos.eqb (fst p) t) defs with
        | Some (_, d) => proot n' d
        | None => RPtr
        end
    | Efield a1 _ _ => match lroot n' a1 with RGlob g => RVia g | r => r end
    | Ederef a1 _ => match proot n' a1 with RGlob g => RVia g | r => r end
    | _ => RUnk
    end end
  with lroot (n : nat) (l : expr) : sroot :=
    match n with O => RUnk | S n' =>
    match l with
    | Evar x _ => if mem_id x lv then RLoc else RGlob x
    | Efield a1 _ _ => lroot n' a1
    | Ederef a1 _ => proot n' a1
    | _ => RUnk
    end end.
End ROOT.

(* the camera.c globals no other source file names (vendor grep, re-checkable:
   each is a camera.c static or a camera.c global with no extern user) *)
Definition cam_store_ids : list ident :=
  [ camera._gCameraZoomDist; camera._gCurrLevelArea; camera._gPrevLevel;
    camera._s2ndRotateFlags; camera._s8DirModeBaseYaw; camera._s8DirModeYawOffset;
    camera._sAreaYaw; camera._sAreaYawChange; camera._sAvoidYawVel;
    camera._sBehindMarioSoundTimer; camera._sCButtonsPressed; camera._sCSideButtonYaw;
    camera._sCUpCameraPitch; camera._sCameraSoundFlags; camera._sCameraStoreCutscene;
    camera._sCameraYawAfterDoorCutscene; camera._sCannonYOffset;
    camera._sCreditsPlayer2Pitch; camera._sCreditsPlayer2Yaw;
    camera._sCurCreditsSplineFocus; camera._sCurCreditsSplinePos;
    camera._sCutsceneDialogResponse; camera._sCutsceneShot;
    camera._sCutsceneSplineSegment; camera._sCutsceneSplineSegmentProgress;
    camera._sFOVState; camera._sFramesPaused; camera._sFramesSinceCutsceneEnded;
    camera._sHandheldShakeInc; camera._sHandheldShakeMag; camera._sHandheldShakePitch;
    camera._sHandheldShakeRoll; camera._sHandheldShakeSpline; camera._sHandheldShakeTimer;
    camera._sHandheldShakeYaw; camera._sLakituDist; camera._sLakituPitch;
    camera._sMarioGeometry; camera._sModeInfo; camera._sModeOffsetYaw;
    camera._sModeTransition; camera._sObjectCutscene; camera._sPanDistance;
    camera._sParTrackIndex; camera._sParTrackPath; camera._sParTrackTransOff;
    camera._sSelectionFlags; camera._sSpiralStairsYawOffset; camera._sStatusFlags;
    camera._sYawSpeed; camera._sZeroZoomDist; camera._sZoomAmount;
    camera._unused8032CFC8; camera._unused8032CFCC; camera._unused8033B30C;
    camera._unused8033B310; camera._unused8033B316; camera._unused8033B31A;
    camera._unused8033B6E8; camera._unusedFreeRoamWallYaw; camera._unusedSplinePitch;
    camera._unusedSplineYaw;
    camera._gEndWavingFocus; camera._gEndWavingPos; camera._sBBHLibraryParTrackPath;
    camera._sBoBCreditsSplineFocus; camera._sBoBCreditsSplinePositions;
    camera._sCameraStoreCUp; camera._sCastleEntranceOffset;
    camera._sEndingFlyToWindowFocus; camera._sEndingFlyToWindowPos;
    camera._sEndingLookAtSkyFocus; camera._sEndingLookUpAtCastle;
    camera._sEndingMarioToPeachFocus; camera._sEndingMarioToPeachPos;
    camera._sEndingPeachDescentCamPos; camera._sFixedModeBasePosition;
    camera._sIntroPipeToDialogFocus; camera._sIntroPipeToDialogPosition;
    camera._sIntroStartToPipeFocus; camera._sIntroStartToPipePosition;
    camera._sOldFocus; camera._sOldPosition; camera._sPlayer2FocusOffset ].

Definition cam_ty : type := tptr (Tstruct camera._Camera noattr).

Definition in_class (cps : list ident) (r : sroot) : bool :=
  match r with
  | RLoc => true
  | RParam t => mem_id t cps
  | RGlob g => mem_id g cam_store_ids
  | RVia g => Pos.eqb g camera._gCamera || mem_id g cam_store_ids
  | RPtr | RUnk => false
  end.

(* non-Camera parameters: their stores are charged to the callers *)
Definition param_root (r : sroot) : bool := match r with RParam _ => true | _ => false end.

Definition out_roots (f : Clight.function) : list sroot :=
  let lv := map fst (fn_vars f) in
  let ps := map fst (fn_params f) in
  let cps := map fst (filter (fun p => if type_eq (snd p) cam_ty then true else false) (fn_params f)) in
  let ds := c_sets (fn_body f) in
  snodup (filter (fun r => negb (in_class cps r || param_root r))
            (map (proot lv ps ds 16) (c_targets (fn_body f)))).

Definition census_of (e : ident * utu * usig) : list (ident * list sroot) :=
  let '(fid, tu, _) := e in
  match (prog_defmap (uprog tu)) ! fid with
  | Some (Gfun (Internal f)) => match out_roots f with nil => nil | l => [(fid, l)] end
  | _ => nil
  end.

(* THE CENSUS, pinned: the 202 walked bodies with a store or pointer argument
   outside the camera-private class, each with those roots (the order is the
   body's, deduplicated).  RGlob g: the global g itself (or a field / an
   array cell of it, or its address passed on); RVia g: a block reached
   through the pointer held in g (sMarioCamState / sLuigiCamState:
   gPlayerCameraState, Mario's camera state; gSecondCameraFocus: an object). *)
Definition uc_census : list (ident * list sroot) := [
  (camera._update_camera, [RGlob camera._gCamera; RGlob camera._gRecentCutscene; RGlob camera._gCheckingSurfaceCollisionsForCamera; RVia camera._gLakituState; RGlob camera._gCameraMovementFlags; RGlob camera._gLakituState]);
  (camera._update_lakitu, [RGlob camera._gCheckingSurfaceCollisionsForCamera; RVia camera._sMarioCamState; RVia camera._gLakituState; RGlob camera._gLakituState]);
  (surface_collision._find_floor, [RVia surface_collision._gDynamicSurfacePartition; RGlob surface_collision._gFindFloorIncludeSurfaceIntangible; RGlob surface_collision._gNumFindFloorMisses; RGlob surface_collision._gNumCalls]);
  (camera._set_camera_shake_from_hit, [RGlob camera._gLakituState]);
  (camera._set_camera_yaw_shake, [RVia camera._gLakituState; RGlob camera._gLakituState]);
  (behavior_script._random_u16, [RGlob behavior_script._gRandomSeed16]);
  (camera._set_camera_pitch_shake, [RVia camera._gLakituState; RGlob camera._gLakituState]);
  (camera._set_camera_roll_shake, [RVia camera._gLakituState; RGlob camera._gLakituState]);
  (camera._shake_camera_roll, [RVia camera._gLakituState; RGlob camera._gLakituState]);
  (camera._shake_camera_yaw, [RVia camera._gLakituState; RGlob camera._gLakituState]);
  (camera._shake_camera_pitch, [RVia camera._gLakituState; RGlob camera._gLakituState]);
  (camera._next_lakitu_state, [RVia camera._sMarioCamState]);
  (surface_collision._find_wall_collisions, [RVia surface_collision._gDynamicSurfacePartition; RGlob surface_collision._gNumCalls]);
  (camera._play_sound_button_change_blocked, [RGlob camera._gGlobalSoundSource]);
  (camera._set_cam_angle, [RGlob camera._gCameraMovementFlags]);
  (camera._play_sound_rbutton_changed, [RGlob camera._gGlobalSoundSource]);
  (camera._clear_cutscene_vars, [RVia camera._sCutsceneVars; RGlob camera._sCutsceneVars]);
  (camera._handle_c_button_movement, [RGlob camera._gCameraMovementFlags]);
  (camera._play_sound_cbutton_side, [RGlob camera._gGlobalSoundSource]);
  (camera._play_sound_cbutton_down, [RGlob camera._gGlobalSoundSource]);
  (camera._set_mode_c_up, [RGlob camera._gCameraMovementFlags]);
  (camera._store_lakitu_cam_info_for_c_up, [RVia camera._sMarioCamState]);
  (camera._play_sound_cbutton_up, [RGlob camera._gGlobalSoundSource]);
  (camera._pan_ahead_of_player, [RVia camera._sMarioCamState]);
  (camera._update_fixed_camera, [RVia camera._sMarioCamState]);
  (surface_collision._find_ceil, [RVia surface_collision._gDynamicSurfacePartition; RGlob surface_collision._gNumCalls]);
  (camera._mode_slide_camera, [RGlob camera._gCameraMovementFlags]);
  (camera._update_slide_camera, [RVia camera._sMarioCamState]);
  (camera._update_default_camera, [RGlob camera._gCameraMovementFlags; RVia camera._sMarioCamState]);
  (camera._rotate_camera_around_walls, [RVia camera._sMarioCamState]);
  (camera._is_mario_behind_surface, [RVia camera._sMarioCamState]);
  (camera._radial_camera_input, [RGlob camera._gCameraMovementFlags]);
  (camera._update_boss_fight_camera, [RGlob camera._sMarioCamState; RGlob camera._gSecondCameraFocus; RVia camera._sMarioCamState]);
  (camera._radial_camera_move, [RVia camera._sMarioCamState; RGlob camera._gCameraMovementFlags]);
  (camera._offset_yaw_outward_radial, [RVia camera._sMarioCamState]);
  (camera._update_yaw_and_dist_from_c_up, [RGlob camera._gCameraMovementFlags]);
  (camera._mode_cannon_camera, [RGlob camera._gCameraMovementFlags]);
  (camera._set_camera_mode, [RGlob camera._gCameraMovementFlags; RGlob camera._gLakituState; RVia camera._gLakituState; RVia camera._sMarioCamState]);
  (camera._update_behind_mario_camera, [RVia camera._sMarioCamState]);
  (camera._mode_behind_mario, [RGlob camera._gCameraMovementFlags]);
  (camera._mode_c_up_camera, [RVia camera._sMarioCamState; RGlob camera._gCameraMovementFlags]);
  (camera._exit_c_up, [RVia camera._sMarioCamState; RGlob camera._gCameraMovementFlags]);
  (camera._move_mario_head_c_up, [RVia camera._sMarioCamState]);
  (camera._move_into_c_up, [RVia camera._sMarioCamState; RGlob camera._gCameraMovementFlags]);
  (camera._play_cutscene, [RGlob camera._gCameraMovementFlags; RGlob camera._sMarioCamState; RGlob camera._gCutsceneTimer; RGlob camera._gRecentCutscene]);
  (camera._cutscene_door_mode, [RGlob camera._gCutsceneTimer]);
  (camera._camera_course_processing, [RVia camera._sMarioCamState; RGlob camera._gLakituState]);
  (camera._cutscene_door_end, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_door_move_behind_mario, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_door_loop, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_door_fix_cam, [RVia camera._sCutsceneVars]);
  (camera._cutscene_door_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_enter_cannon_start, [RGlob camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_enter_cannon_raise, [RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_painting_end, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_unused_exit_start, [RVia camera._sMarioCamState]);
  (camera._cutscene_exit_painting_move_to_floor, [RVia camera._sMarioCamState]);
  (camera._cutscene_exit_painting_move_to_mario, [RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_painting_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_enter_painting, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_sliding_doors_follow_mario, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_sliding_doors_fly_back_up, [RVia camera._sCutsceneVars]);
  (camera._cutscene_sliding_doors_go_under_doorway, [RVia camera._sCutsceneVars]);
  (camera._cutscene_sliding_doors_open_set_cvars, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_sliding_doors_open_start, [RVia camera._sMarioCamState]);
  (camera._cutscene_spawn_obj, [RGlob camera._gCutsceneObjSpawn]);
  (camera._cutscene_intro_peach_letter, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_intro_peach_mario_appears, [RGlob camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_intro_peach_fly_to_pipe, [RVia camera._sCutsceneVars]);
  (ingame_menu._create_dialog_box, [RGlob ingame_menu._gDialogID; RGlob ingame_menu._gDialogBoxType]);
  (camera._cutscene_intro_peach_clear_cutscene_status, [RGlob camera._sMarioCamState]);
  (camera._cutscene_intro_peach_dialog, [RVia camera._gLakituState; RGlob camera._gCutsceneTimer]);
  (camera._cutscene_intro_peach_start_to_pipe_spline, [RGlob camera._gCameraMovementFlags; RGlob camera._gCutsceneTimer]);
  (camera._play_sound_peach_reading_letter, [RGlob camera._gGlobalSoundSource]);
  (camera._cutscene_unlock_key_door_fly_back, [RVia camera._sCutsceneVars]);
  (camera._cutscene_unlock_key_door_focus_lock, [RVia camera._sCutsceneVars]);
  (camera._cutscene_unlock_key_door_approach_mario, [RVia camera._sCutsceneVars]);
  (camera._cutscene_unlock_key_door_start, [RVia camera._sCutsceneVars; RVia camera._sMarioCamState]);
  (camera._cutscene_cap_switch_press, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._stop_cutscene_and_retrieve_stored_info, [RGlob camera._gCutsceneTimer]);
  (ingame_menu._create_dialog_box_with_response, [RGlob ingame_menu._gDialogID; RGlob ingame_menu._gDialogBoxType; RGlob ingame_menu._gDialogWithChoice]);
  (camera._cutscene_cap_switch_press_pan_left, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_cap_switch_press_approach_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_cap_switch_press_lower_cam, [RVia camera._sMarioCamState]);
  (camera._cutscene_cap_switch_press_rotate_around_mario, [RVia camera._sCutsceneVars; RVia camera._sMarioCamState]);
  (camera._cutscene_cap_switch_press_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_non_painting_death_override_offset, [RVia camera._sCutsceneVars]);
  (camera._cutscene_non_painting_death_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_non_painting_succ_override_cvar, [RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_bowser_succ_focus_left, [RVia camera._sCutsceneVars]);
  (camera._cutscene_non_painting_set_cam_focus, [RVia camera._sCutsceneVars]);
  (camera._cutscene_non_painting_set_cam_pos, [RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_succ_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_read_message, [RVia camera._sCutsceneVars; RGlob camera._gCutsceneTimer]);
  (audio_external._seq_player_unlower_volume, [RGlob audio_external._sLowerBackgroundMusicVolume]);
  (audio_external._seq_player_fade_to_normal_volume, [RGlob audio_external._gSequencePlayers]);
  (audio_external._begin_background_music_fade, [RGlob audio_external._gSequencePlayers]);
  (audio_external._seq_player_fade_to_target_volume, [RGlob audio_external._gSequencePlayers]);
  (object_helpers._clear_time_stop_flags, [RGlob object_helpers._gTimeStopState]);
  (object_helpers._set_time_stop_flags, [RGlob object_helpers._gTimeStopState]);
  (camera._cutscene_read_message_start, [RVia camera._sCutsceneVars]);
  (audio_external._seq_player_lower_volume, [RGlob audio_external._sLowerBackgroundMusicVolume]);
  (audio_external._seq_player_fade_to_percentage_of_volume, [RGlob audio_external._gSequencePlayers]);
  (camera._cutscene_dialog, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_dialog_create_dialog_box, [RVia camera._sCutsceneVars]);
  (camera._cutscene_dialog_move_mario_shoulder, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_dialog_start, [RGlob camera._gCutsceneFocus; RVia camera._sMarioCamState; RVia camera._gLakituState; RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_to_castle_grounds_end, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_goto_cvar_pos, [RVia camera._sCutsceneVars]);
  (camera._cutscene_enter_pyramid_top_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_pyramid_top_explode_warp_back, [RVia camera._sCutsceneVars]);
  (camera._cutscene_pyramid_top_explode_closeup, [RVia camera._sCutsceneVars]);
  (camera._cutscene_pyramid_top_explode_warp, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_pyramid_top_explode_focus, [RVia camera._sCutsceneVars]);
  (camera._cutscene_pyramid_top_explode_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_enter_pool_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_suffocation_rotate, [RVia camera._sMarioCamState]);
  (camera._cutscene_suffocation_fly_away, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_quicksand_death, [RVia camera._sCutsceneVars]);
  (camera._water_death_move_to_mario_side, [RVia camera._sMarioCamState]);
  (camera._cutscene_quicksand_death_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bbh_death_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_death_stomach_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_death_standing_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_prepare_cannon_end, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_prepare_cannon_fly_back, [RVia camera._sCutsceneVars]);
  (camera._cutscene_prepare_cannon_fly_to_cannon, [RVia camera._sCutsceneVars]);
  (camera._cutscene_prepare_cannon_start, [RGlob camera._gCutsceneFocus; RVia camera._sCutsceneVars]);
  (camera._cutscene_red_coin_star_end, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_red_coin_star, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_red_coin_star_warp, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_red_coin_star_start, [RGlob camera._gCutsceneFocus; RVia camera._sCutsceneVars]);
  (camera._cutscene_exit_to_castle_grounds_focus_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_star_spawn_end, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_star_spawn, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_star_spawn_focus_star, [RGlob camera._gCutsceneFocus]);
  (camera._cutscene_bowser_arena_end, [RVia camera._gSecondCameraFocus]);
  (camera._cutscene_bowser_arena_dialog, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_bowser_arena_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bowser_arena_set_focus, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bowser_arena_set_pos, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bowser_arena_pan_left, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bowser_arena_adjust_offsets, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bowser_arena_focus_sine, [RVia camera._sCutsceneVars]);
  (camera._cutscene_bowser_area_start_bowser_walking, [RVia camera._gSecondCameraFocus]);
  (camera._focus_in_front_of_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_key_dance_jump_last, [RGlob camera._gLakituState; RVia camera._sCutsceneVars]);
  (camera._cutscene_key_dance_jump_above, [RGlob camera._gLakituState; RVia camera._sCutsceneVars]);
  (camera._cutscene_key_dance_jump_lower_left, [RVia camera._sCutsceneVars]);
  (camera._cutscene_key_dance_jump_closeup, [RVia camera._sCutsceneVars]);
  (camera._cutscene_key_dance_jump_cvar, [RVia camera._sCutsceneVars; RVia camera._sMarioCamState]);
  (camera._cutscene_dance_fly_away_rotate_while_flying, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_fly_rotate_around_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_pan_cvar9, [RVia camera._sCutsceneVars]);
  (camera._cutscene_dance_fly_away_focus_mario, [RVia camera._sCutsceneVars]);
  (camera._cutscene_dance_fly_away_approach_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_fly_away_start, [RVia camera._sCutsceneVars]);
  (camera._star_dance_bound_yaw, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_closeup_fly_closer, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_closeup_fly_above, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_closeup_focus_mario, [RVia camera._sCutsceneVars]);
  (camera._cutscene_dance_closeup_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_dance_default_rotate, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_dance_rotate_move_towards_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_rotate_move_back, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_rotate, [RVia camera._sMarioCamState]);
  (camera._cutscene_dance_move_to_mario, [RVia camera._sMarioCamState]);
  (camera._cutscene_grand_star_fly_app_cvars, [RVia camera._sCutsceneVars; RVia camera._sMarioCamState]);
  (camera._cutscene_grand_star_fly_mario_offscreen, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_fly_move_to_mario, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_fly_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_move_cvar2, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_approach_mario, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_accel_cvar2, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_mario_jump, [RVia camera._sCutsceneVars]);
  (camera._cutscene_grand_star_front_of_mario, [RVia camera._sCutsceneVars; RVia camera._sMarioCamState]);
  (camera._cutscene_grand_star_start, [RVia camera._sMarioCamState; RVia camera._sCutsceneVars]);
  (camera._cutscene_ending_stop, [RGlob camera._gCutsceneTimer]);
  (camera._cutscene_ending_peach_descent_lower_focus, [RVia camera._sCutsceneVars]);
  (camera._cutscene_ending_peach_descends_start, [RVia camera._sCutsceneVars]);
  (camera._cutscene_ending_reset_spline, [RVia camera._sCutsceneVars]);
  (camera._cutscene_ending_mario_fall_focus_mario, [RVia camera._sMarioCamState]);
  (audio_external._play_music, [RGlob audio_external._sBackgroundMusicQueueSize; RGlob audio_external._sBackgroundMusicQueue]);
  (audio_external._seq_player_play_sequence, [RGlob audio_external._sCurrentBackgroundMusicSeqId; RGlob audio_external._sBackgroundMusicForDynamics; RGlob audio_external._sCurrentMusicDynamic; RGlob audio_external._sMusicDynamicDelay; RVia audio_external._D_80360928; RGlob audio_external._gSequencePlayers]);
  (audio_external._func_8031D690, [RGlob audio_external._gSequencePlayers]);
  (audio_external._stop_background_music, [RGlob audio_external._sBackgroundMusicQueueSize; RGlob audio_external._sBackgroundMusicQueue]);
  (audio_external._seq_player_fade_out, [RGlob audio_external._sCurrentBackgroundMusicSeqId]);
  (audio_external._seq_player_fade_to_zero_volume, [RGlob audio_external._gSequencePlayers]);
  (camera._cutscene_mario_dialog, [RGlob camera._gCutsceneTimer]);
  (camera._transition_to_camera_mode, [RGlob camera._gCameraMovementFlags]);
  (camera._cam_bbh_elevator, [RVia camera._gLakituState]);
  (camera._cam_bbh_fall_into_pool, [RVia camera._sMarioCamState; RVia camera._gLakituState]);
  (camera._move_camera_through_floor_while_descending, [RVia camera._gLakituState]);
  (camera._cam_hmc_enter_maze, [RVia camera._gLakituState]);
  (camera._cam_cotmc_exit_waterfall, [RGlob camera._gCameraMovementFlags]);
  (camera._cam_rr_exit_building_top, [RVia camera._gLakituState]);
  (camera._init_camera, [RVia camera._gSecondCameraFocus; RGlob camera._gCameraMovementFlags; RVia camera._sMarioCamState; RVia camera._gLakituState; RGlob camera._gLakituState]);
  (camera._is_within_100_units_of_mario, [RVia camera._sMarioCamState]);
  (camera._find_mario_floor_and_ceil, [RGlob camera._gCheckingSurfaceCollisionsForCamera]);
  (camera._reset_camera, [RGlob camera._gCamera; RGlob camera._gCutsceneTimer; RGlob camera._gCutsceneObjSpawn; RGlob camera._gObjCutsceneDone; RGlob camera._gCutsceneFocus; RGlob camera._gSecondCameraFocus; RGlob camera._gCameraMovementFlags; RVia camera._sMarioCamState; RVia camera._sLuigiCamState; RGlob camera._sMarioCamState; RVia camera._gLakituState; RGlob camera._gLakituState; RGlob camera._gRecentCutscene]);
  (camera._set_camera_mode_radial, [RVia camera._sMarioCamState]);
  (hud._set_hud_camera_status, [RGlob hud._sCameraHUDStatus]) ].

Lemma uc_census_ok : flat_map census_of uc_walk = uc_census.
Proof. vm_compute. reflexivity. Qed.
