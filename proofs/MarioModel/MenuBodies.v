(* ====================================================================== *)
(* MenuBodies.v -- the ingame_menu.c / audio entries of the any-argument  *)
(* external lists, proved from their REAL bodies (SPINE: GOAL 1 premise   *)
(* sweep, 2026-10-23).                                                     *)
(*                                                                        *)
(* ingame_menu.c (the 37th TU, linked 2026-10-22) and audio/external.c    *)
(* (TU 40, 2026-10-23) define nine functions still named by the capstones' *)
(* any-argument lists, so those rows were claims about real code:         *)
(*  - cut_ext_open2_ids: create_dialog_box / _with_var / _inverted_box /   *)
(*    _with_response, get_dialog_id, set_menu_mode, set_cutscene_message; *)
(*  - obj_ext_open2_ids: reset_cutscene_msg_fade,                         *)
(*    drop_queued_background_music.                                       *)
(* Each body is a read of a menu global and at most six stores into menu  *)
(* / audio globals no MWF row reads (gDialogID, gDialogBoxType,           *)
(* gDialogWithChoice, gMenuMode, gCutsceneMsg*, sBackgroundMusicQueueSize) *)
(* of s8 / s16 / u8 values or constants: ObjExtBodies.ast_ok's            *)
(* non-pointer class (np_store_pres).                                      *)
(* FOUND FALSE (as stated, any argument and any SafeB):                    *)
(* create_dialog_box_with_var stores its s32 argument dialogVar into the  *)
(* s32 global gDialogVariable.  A pointer dialogVar (32-bit ptrs: the     *)
(* cast passes a Vptr through) lands in gDialogVariable's block, and      *)
(* nothing kept that block out of SafeB, so a SafeB containing it plus a  *)
(* dialogVar pointing into Mario's block breaks MWF's load closure (R7).  *)
(* REPAIRED: gDialogVariable joins CensusV2.stored_globals (the Hglob_blk *)
(* class, TRUST 4.1: SafeB_syms_ok keeps SafeB off it), so its store is a *)
(* stored-global store for any value.                                      *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario ingame_menu audio_external interaction
  mario_actions_cutscene camera behavior_script.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit
  FloorsSurface MathBodies LinkedTwelve.
From SM64.Proofs Require SpawnBodies ObjExtBodies MtxfBody ActWriterSurface SaveFileBody.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The generated-AST pins and the recognizer runs.                       *)
(* ---------------------------------------------------------------------- *)

Local Notation im_dm id f :=
  ((prog_defmap ingame_menu.prog) ! id = Some (Gfun (Internal f))).

Lemma dm_gdi : im_dm ingame_menu._get_dialog_id ingame_menu.f_get_dialog_id.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cdb : im_dm ingame_menu._create_dialog_box ingame_menu.f_create_dialog_box.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cdbv :
  im_dm ingame_menu._create_dialog_box_with_var ingame_menu.f_create_dialog_box_with_var.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cdib :
  im_dm ingame_menu._create_dialog_inverted_box ingame_menu.f_create_dialog_inverted_box.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cdbr :
  im_dm ingame_menu._create_dialog_box_with_response
    ingame_menu.f_create_dialog_box_with_response.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_smm : im_dm ingame_menu._set_menu_mode ingame_menu.f_set_menu_mode.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_rcmf :
  im_dm ingame_menu._reset_cutscene_msg_fade ingame_menu.f_reset_cutscene_msg_fade.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_scm : im_dm ingame_menu._set_cutscene_message ingame_menu.f_set_cutscene_message.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_dqbm :
  (prog_defmap audio_external.prog) ! audio_external._drop_queued_background_music
    = Some (Gfun (Internal audio_external.f_drop_queued_background_music)).
Proof. vm_compute. reflexivity. Qed.

(* the walk: every Sset / return is free, every store is ast_ok, no call *)
Definition menu_chk_c (ids : list ident) (f : Clight.function) : bool :=
  SpawnBodies.sw_chk (fun _ _ => true) ObjExtBodies.ast_ok (ObjExtBodies.a_call_ok ids)
    (fun _ => true) (fn_body f).
Notation menu_chk := (menu_chk_c nil).

(* engine/behavior_script.c (the 43rd TU, linked 2026-10-23): the object RNG.
   random_u16 is a read-modify-write of the u16 gRandomSeed16; random_float
   calls it and converts. *)
Lemma dm_ru16 :
  (prog_defmap behavior_script.prog) ! behavior_script._random_u16
    = Some (Gfun (Internal behavior_script.f_random_u16)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_rf :
  (prog_defmap behavior_script.prog) ! behavior_script._random_float
    = Some (Gfun (Internal behavior_script.f_random_float)).
Proof. vm_compute. reflexivity. Qed.
Definition ids_rf : list ident := [behavior_script._random_u16].
Lemma chk_ru16 : menu_chk behavior_script.f_random_u16 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_rf : menu_chk_c ids_rf behavior_script.f_random_float = true.
Proof. vm_compute. reflexivity. Qed.

(* NON-VACUITY: the recognizer accepts each REAL body *)
Lemma chk_gdi : menu_chk ingame_menu.f_get_dialog_id = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cdb : menu_chk ingame_menu.f_create_dialog_box = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cdbv : menu_chk ingame_menu.f_create_dialog_box_with_var = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cdib : menu_chk ingame_menu.f_create_dialog_inverted_box = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cdbr : menu_chk ingame_menu.f_create_dialog_box_with_response = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_smm : menu_chk ingame_menu.f_set_menu_mode = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_rcmf : menu_chk ingame_menu.f_reset_cutscene_msg_fade = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_scm : menu_chk ingame_menu.f_set_cutscene_message = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_dqbm : menu_chk audio_external.f_drop_queued_background_music = true.
Proof. vm_compute. reflexivity. Qed.
(* the store class is not decorative: without the stored-global clause
   create_dialog_box_with_var's gDialogVariable = dialogVar (an s32, which
   can carry a pointer) is REJECTED -- the finding above *)
Example chk_cdbv_needs_stored :
  SpawnBodies.sw_chk (fun _ _ => true)
    (fun lv rhs => match SaveFileBody.groot_l lv with
                   | Some g => MtxfBody.is_byval (typeof lv)
                               && negb (mem_id g ObjExtBodies.mwf_syms)
                               && (nonptr_scalar (typeof lv)
                                   || ActWriterSurface.nonptr_binop_head rhs)
                   | None => false end)
    (ObjExtBodies.a_call_ok nil) (fun _ => true)
    (fn_body ingame_menu.f_create_dialog_box_with_var) = false.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The rows, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

Section MenuRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.
  Let sym_pres := ObjExtBodies.sym_pres lp bm bc oc0 SafeB.

  Lemma m_store : forall lv rhs le m0 t0 le' m0' out,
      ObjExtBodies.ast_ok lv rhs = true ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0 (Sassign lv rhs) t0 le' m0' out ->
      ow_facts bm MWF m0 -> ow_facts bm MWF m0'.
  Proof. intros. eapply ObjExtBodies.ast_store_pres; eassumption. Qed.

  Lemma m_call : forall ids,
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall optid a al le m0 t0 le' m0' out,
        ObjExtBodies.a_call_ok ids optid a al = true ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m0 (Scall optid a al) t0 le' m0' out ->
        ow_facts bm MWF m0 -> ow_facts bm MWF m0'.
  Proof. intros. eapply ObjExtBodies.gcall_pres; eassumption. Qed.

  Lemma no_ids : forall g, mem_id g (@nil ident) = true -> sym_pres g.
  Proof. intros g Hg. discriminate Hg. Qed.

  (* a no-locals body that passes menu_chk_c ids keeps the carried facts *)
  Lemma menu_body_pres_c : forall ids f,
      fn_vars f = nil -> menu_chk_c ids f = true ->
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros ids f Hvars Hchk Hids m vargs t m' vres Hevf Hf0.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite Hvars in Ha; inv Ha end.
    destruct (SpawnBodies.sw_walk (lp_ge lp) empty_env (ow_facts bm MWF)
                (fun _ => True) (fun _ => True)
                (fun _ _ => true) ObjExtBodies.ast_ok (ObjExtBodies.a_call_ok ids)
                (fun _ => true)
                (fun _ _ _ _ _ _ _ _ _ => I)
                (fun lv rhs le m0 t0 le' m0' out Hok _ Hx Hf =>
                   m_store lv rhs le m0 t0 le' m0' out Hok Hx Hf)
                (fun optid a al le m0 t0 le' m0' out Hok _ Hx Hf =>
                   conj (m_call ids Hids optid a al le m0 t0 le' m0' out Hok Hx Hf) I)
                (fun _ _ _ _ _ _ _ _ => I)
                _ _ _ _ _ _ _ _ Hbody eq_refl Hchk I Hf0) as (Hf1 & _).
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact Hf1.
  Qed.

  Lemma menu_body_pres : forall f,
      fn_vars f = nil -> menu_chk f = true ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof. intros f Hv Hc. exact (menu_body_pres_c nil f Hv Hc no_ids). Qed.

  Ltac menu_row LO dm chk :=
    eapply ObjExtBodies.row_of_sym;
    eapply ObjExtBodies.sym_pres_of_body; [ exact LO | exact dm | ];
    apply menu_body_pres; [ reflexivity | exact chk ].

  Lemma sp_ru16 : sym_pres behavior_script._random_u16.
  Proof.
    eapply ObjExtBodies.sym_pres_of_body;
      [ exact (linked12_LO_behavior_script lp H12) | exact dm_ru16 | ].
    apply menu_body_pres; [ reflexivity | exact chk_ru16 ].
  Qed.
  Lemma sp_rf : sym_pres behavior_script._random_float.
  Proof.
    eapply ObjExtBodies.sym_pres_of_body;
      [ exact (linked12_LO_behavior_script lp H12) | exact dm_rf | ].
    apply (menu_body_pres_c ids_rf); [ reflexivity | exact chk_rf | ].
    intros g Hg. cbn [mem_id existsb ids_rf] in Hg.
    apply orb_true_iff in Hg as [Hg | Hg]; [ | discriminate Hg ].
    apply Pos.eqb_eq in Hg. subst g. exact sp_ru16.
  Qed.
  (* random_float: the last any-argument object-external row *)
  Lemma Hpx_rf : call_pres_ext lp bm NoA MWF camera._random_float.
  Proof. eapply ObjExtBodies.row_of_sym; exact sp_rf. Qed.

  (* ---- THE ROWS ---- *)
  Lemma Hpx_gdi : call_pres_ext lp bm NoA MWF mario_actions_cutscene._get_dialog_id.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_gdi chk_gdi. Qed.
  Lemma Hpx_cdb : call_pres_ext lp bm NoA MWF mario_actions_cutscene._create_dialog_box.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_cdb chk_cdb. Qed.
  Lemma Hpx_cdbv :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._create_dialog_box_with_var.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_cdbv chk_cdbv. Qed.
  Lemma Hpx_cdib :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._create_dialog_inverted_box.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_cdib chk_cdib. Qed.
  Lemma Hpx_cdbr :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._create_dialog_box_with_response.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_cdbr chk_cdbr. Qed.
  Lemma Hpx_smm : call_pres_ext lp bm NoA MWF mario_actions_cutscene._set_menu_mode.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_smm chk_smm. Qed.
  Lemma Hpx_scm :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._set_cutscene_message.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_scm chk_scm. Qed.
  Lemma Hpx_rcmf :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._reset_cutscene_msg_fade.
  Proof. menu_row (linked12_LO_ingame_menu lp H12) dm_rcmf chk_rcmf. Qed.
  Lemma Hpx_dqbm :
    call_pres_ext lp bm NoA MWF interaction._drop_queued_background_music.
  Proof. menu_row (linked12_LO_audio_external lp H12) dm_dqbm chk_dqbm. Qed.
End MenuRows.
