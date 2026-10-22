(* ====================================================================== *)
(* THE LINKED ANY-ARGUMENT obj_ext / cut_ext ENTRIES, PROVED FROM THEIR    *)
(* REAL BODIES (SPINE: premise sweep, 2026-10-21).                         *)
(*                                                                        *)
(* Both capstones took two any-argument preservation rows,                *)
(* Hpres_obj_ext_open2 (NoAImpliesNoFlyTwelve.obj_ext_open2_ids) and      *)
(* Hpres_cut_ext_open (NoAImpliesNoFlyLinked.cut_ext_open_ids).  Several  *)
(* of their entries have linked bodies (save_file.c, object_helpers.c,    *)
(* behavior_actions.c).  Each such entry is a lemma here, walked over the *)
(* generated body:                                                         *)
(*  - save_file_get_flags / _get_star_flags / _get_total_star_count:      *)
(*    readers (the last two loop over the real callees                    *)
(*    save_file_get_course_star_count -> save_file_get_star_flags);       *)
(*  - save_file_set_flags / _clear_flags: store the current file's flags  *)
(*    and gSaveFileModified;                                               *)
(*  - save_file_collect_star_or_key: stores gLastCompletedCourseNum /     *)
(*    gLastCompletedStarNum / sUnusedGotGlobalCoinHiScore /               *)
(*    gGotFileCoinHiScore / gSaveFileModified and the file's coin score,  *)
(*    and calls the real get_flags / get_max_coin_score /                 *)
(*    get_course_coin_score / touch_coin_score_age (-> get / set           *)
(*    coin_score_age, gMainMenuDataModified) / set_flags / get_star_flags *)
(*    / set_star_flags;                                                    *)
(*  - enable_time_stop / disable_time_stop: read-modify-write             *)
(*    gTimeStopState;                                                      *)
(*    every store above is a global-rooted address chain into a           *)
(*    CensusV2.stored_globals symbol (SaveFileBody.groot_l), so it lands  *)
(*    in that global's block, whatever the arguments or the file / course *)
(*    numbers;                                                             *)
(*  - bhv_spawn_star_no_level_exit(starIndex): star =                     *)
(*    spawn_object(gCurrentObject, ..) (its gated row Hcp_spawn_real,     *)
(*    SpawnBodies.Hcp_spawn_sg: a SafeB object if a pointer; the parent   *)
(*    and behavior arguments pass spawn_args_ok), two integer stores      *)
(*    through star, and the real obj_set_angle(star, 0, 0, 0), whose four *)
(*    stores go through its SafeB arg0 with integer values.               *)
(* FINDING: the "for any argument" claim is TRUE of each of these bodies, *)
(* but only because the globals they write are stored globals: six of   *)
(* them (the four collect_star_or_key bytes, gMainMenuDataModified,      *)
(* gTimeStopState) were NOT, so the rows rested on unstated facts about  *)
(* those blocks.  They joined CensusV2.stored_globals (the Hglob_blk /   *)
(* SafeB_syms_ok class: nothing in the object graph points at them).     *)
(* save_file_do_save is proved in SaveDoSaveBody.v (2026-10-21), through *)
(* the linked libultra EEPROM C down to the OS / hardware floor (TRUST   *)
(* 3.5).                                                                 *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario memory math_util object_helpers save_file area
  behavior_actions interaction level_update mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface
  FloorsSurface MathBodies BullyBodies LinkedTwelve MtxfBody SaveFileBody
  ObjHelpersBodies WindSurface.
From SM64.Proofs Require ActWriterSurface.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The no-locals frozen-temps walk, with calls.                          *)
(* ---------------------------------------------------------------------- *)

Lemma nl_body_frame_c :
  forall (ge : genv) (MWF : mem -> Prop) bm (f : Clight.function) store_ok call_ok,
    fn_vars f = nil ->
    owf_chk nil store_ok call_ok (fn_body f) = true ->
    (forall lv rhs le m0 t0 le' m0' out,
       store_ok lv = true ->
       exec_stmt function_entry2 ge empty_env le m0 (Sassign lv rhs) t0 le' m0' out ->
       ow_facts bm MWF m0 -> ow_facts bm MWF m0') ->
    (forall optid a al le m0 t0 le' m0' out,
       call_ok a al = true ->
       exec_stmt function_entry2 ge empty_env le m0 (Scall optid a al) t0 le' m0' out ->
       ow_facts bm MWF m0 -> ow_facts bm MWF m0') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
Proof.
  intros ge MWF bm f store_ok call_ok Hvars Hchk Hst Hca m vargs t m' vres Hevf Hf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    destruct (owf_walk ge empty_env bm MWF nil LE store_ok call_ok
                (fun lv rhs le m0 t0 le' m0' out Hok _ Hx => Hst lv rhs le m0 t0 le' m0' out Hok Hx)
                (fun optid a al le m0 t0 le' m0' out Hok _ Hx =>
                   Hca optid a al le m0 t0 le' m0' out Hok Hx)
                _ _ _ _ _ _ _ _ Hbody eq_refl Hchk (fun _ _ => eq_refl) Hf) as (Hf1 & _)
  end.
  change (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-.
  exact Hf1.
Qed.

(* a direct call to one of the listed functions *)
Definition gcall_ok (ids : list ident) (a : expr) (al : list expr) : bool :=
  match a with
  | Evar f (Tfunction _ _ _) => mem_id f ids
  | _ => false
  end.

(* ---------------------------------------------------------------------- *)
(* 2. The SafeB-if-pointer temps walk (bhv_spawn_star / obj_set_angle).     *)
(* ---------------------------------------------------------------------- *)

(* expressions whose value is SafeB if it is a pointer, given the temps in
   sp are: integer literals, sp temps, the gCurrentObject load (a SafeB
   symbol, R7), and the binops that never yield a pointer *)
Definition val_ok (sp : list ident) (a : expr) : bool :=
  match a with
  | Econst_int _ _ => true
  | Etempvar t _ => mem_id t sp
  | Evar _ _ => gco_expr a
  | Ebinop _ _ _ _ => ActWriterSurface.nonptr_binop_head a
  | _ => false
  end.

Definition ox_set_ok (sp : list ident) (id : ident) (a : expr) : bool :=
  negb (mem_id id sp) || val_ok sp a.

Definition ox_store_ok (sp : list ident) (lv rhs : expr) : bool :=
  match chain_root_l lv with
  | Some t => mem_id t sp && MtxfBody.is_byval (typeof lv) && val_ok sp rhs
  | None => false
  end.

(* spawn_object(..) (the sr row), or obj_set_angle(<val_ok args>) *)
Definition ox_call_ok (sp : list ident) (optid : option ident) (a : expr)
    (al : list expr) : bool :=
  match a with
  | Evar f (Tfunction ps _ _) =>
      (Pos.eqb f behavior_actions._spawn_object
       && spawn_args_ok spawn_bhv_syms sp ps al)
      || (Pos.eqb f behavior_actions._obj_set_angle && forallb (val_ok sp) al
          && match optid with None => true | Some _ => false end)
  | _ => false
  end.

Definition bs_sp : list ident :=
  [behavior_actions._star; behavior_actions._t'1; behavior_actions._t'2].
Definition osa_sp : list ident :=
  [object_helpers._obj; object_helpers._pitch; object_helpers._yaw; object_helpers._roll].

(* NON-VACUITY: the recognizers accept the REAL generated bodies *)
Lemma bs_chk :
  tw_chk (ox_set_ok bs_sp) (ox_store_ok bs_sp) (ox_call_ok bs_sp)
    (fn_body behavior_actions.f_bhv_spawn_star_no_level_exit) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma osa_chk :
  tw_chk (ox_set_ok osa_sp) (ox_store_ok osa_sp) (fun _ _ _ => false)
    (fn_body object_helpers.f_obj_set_angle) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The generated-AST pins.                                               *)
(* ---------------------------------------------------------------------- *)

Lemma dm_osa :
  (prog_defmap object_helpers.prog) ! behavior_actions._obj_set_angle
    = Some (Gfun (Internal object_helpers.f_obj_set_angle)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_bs :
  (prog_defmap behavior_actions.prog) ! interaction._bhv_spawn_star_no_level_exit
    = Some (Gfun (Internal behavior_actions.f_bhv_spawn_star_no_level_exit)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ets :
  (prog_defmap object_helpers.prog) ! object_helpers._enable_time_stop
    = Some (Gfun (Internal object_helpers.f_enable_time_stop)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_dts :
  (prog_defmap object_helpers.prog) ! object_helpers._disable_time_stop
    = Some (Gfun (Internal object_helpers.f_disable_time_stop)).
Proof. vm_compute. reflexivity. Qed.

Local Notation sf_dm id f :=
  ((prog_defmap save_file.prog) ! id = Some (Gfun (Internal f))).

Lemma dm_get_flags : sf_dm save_file._save_file_get_flags save_file.f_save_file_get_flags.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_get_star_flags :
  sf_dm save_file._save_file_get_star_flags save_file.f_save_file_get_star_flags.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_course_star_count :
  sf_dm save_file._save_file_get_course_star_count
    save_file.f_save_file_get_course_star_count.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_total_star_count :
  sf_dm save_file._save_file_get_total_star_count
    save_file.f_save_file_get_total_star_count.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_set_flags : sf_dm save_file._save_file_set_flags save_file.f_save_file_set_flags.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_clear_flags :
  sf_dm save_file._save_file_clear_flags save_file.f_save_file_clear_flags.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_course_coin_score :
  sf_dm save_file._save_file_get_course_coin_score
    save_file.f_save_file_get_course_coin_score.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_get_age : sf_dm save_file._get_coin_score_age save_file.f_get_coin_score_age.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_set_age : sf_dm save_file._set_coin_score_age save_file.f_set_coin_score_age.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_touch_age :
  sf_dm save_file._touch_coin_score_age save_file.f_touch_coin_score_age.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_max_coin_score :
  sf_dm save_file._save_file_get_max_coin_score save_file.f_save_file_get_max_coin_score.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_set_star_flags :
  sf_dm save_file._save_file_set_star_flags save_file.f_save_file_set_star_flags.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_collect :
  sf_dm save_file._save_file_collect_star_or_key
    save_file.f_save_file_collect_star_or_key.
Proof. vm_compute. reflexivity. Qed.

(* the callee lists, and NON-VACUITY: the recognizer accepts each REAL body *)
Definition ids_course_star_count : list ident := [save_file._save_file_get_star_flags].
Definition ids_total_star_count : list ident := [save_file._save_file_get_course_star_count].
Definition ids_touch_age : list ident :=
  [save_file._get_coin_score_age; save_file._set_coin_score_age].
Definition ids_max_coin_score : list ident :=
  [save_file._save_file_get_star_flags; save_file._save_file_get_course_coin_score;
   save_file._get_coin_score_age].
Definition ids_collect : list ident :=
  [save_file._save_file_get_flags; save_file._save_file_get_max_coin_score;
   save_file._save_file_get_course_coin_score; save_file._touch_coin_score_age;
   save_file._save_file_set_flags; save_file._save_file_get_star_flags;
   save_file._save_file_set_star_flags].

Lemma chk_get_flags :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_save_file_get_flags) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_get_star_flags :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_save_file_get_star_flags) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_course_star_count :
  owf_chk nil gstore_ok (gcall_ok ids_course_star_count)
    (fn_body save_file.f_save_file_get_course_star_count) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_total_star_count :
  owf_chk nil gstore_ok (gcall_ok ids_total_star_count)
    (fn_body save_file.f_save_file_get_total_star_count) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_set_flags :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_save_file_set_flags) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_clear_flags :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_save_file_clear_flags) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_course_coin_score :
  owf_chk nil gstore_ok (gcall_ok nil)
    (fn_body save_file.f_save_file_get_course_coin_score) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_get_age :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_get_coin_score_age) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_set_age :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_set_coin_score_age) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_touch_age :
  owf_chk nil gstore_ok (gcall_ok ids_touch_age)
    (fn_body save_file.f_touch_coin_score_age) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_max_coin_score :
  owf_chk nil gstore_ok (gcall_ok ids_max_coin_score)
    (fn_body save_file.f_save_file_get_max_coin_score) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_set_star_flags :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body save_file.f_save_file_set_star_flags) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_collect :
  owf_chk nil gstore_ok (gcall_ok ids_collect)
    (fn_body save_file.f_save_file_collect_star_or_key) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_ets :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body object_helpers.f_enable_time_stop) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_dts :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body object_helpers.f_disable_time_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* binding parameters keeps "every temp is SafeB-if-pointer" *)
Lemma bind_safe : forall (P : val -> Prop) ps vargs te le,
    bind_parameter_temps ps vargs te = Some le ->
    Forall P vargs -> (forall t v, te ! t = Some v -> P v) ->
    forall t v, le ! t = Some v -> P v.
Proof.
  intros P ps. induction ps as [| [id ty] ps IH];
    intros vargs te le Hb Hv Hte; destruct vargs as [| v0 vr]; cbn in Hb;
    try discriminate Hb.
  - injection Hb as <-. exact Hte.
  - inversion Hv as [| ? ? Hv0 Hvr]; subst.
    apply (IH vr _ _ Hb Hvr).
    intros t v Ht. destruct (peq t id) as [-> | Hne].
    + rewrite PTree.gss in Ht. injection Ht as <-. exact Hv0.
    + rewrite PTree.gso in Ht by exact Hne. exact (Hte _ _ Ht).
Qed.

(* ---------------------------------------------------------------------- *)
(* 3b. area.c (the 23rd TU, 2026-10-21): override_viewport_and_clip,       *)
(*     play_transition (-> set_warp_transition_rgb), area_get_warp_node.   *)
(* ---------------------------------------------------------------------- *)

(* the blocks MWF_real READS besides SafeB (its transfer rows): Mario's
   state, the controllers, the gMarioState cell, the timer, the handler
   table, the animation list, the knockback / landing tables *)
Definition mwf_syms : list ident :=
  [level_update._gMarioStates; mario._gControllers; mario._gMarioState;
   interaction._gGlobalTimer; interaction._sInteractionHandlers;
   mario._gMarioAnimsBuf] ++ knockback_table_ids.

(* a by-value store into a global-rooted chain whose root is either a
   stored global (any value), or any global MWF does not read, with a value
   that cannot be a pointer: a small-int / float lvalue type, or a
   never-pointer binop on the right *)
Definition ast_ok (lv rhs : expr) : bool :=
  match groot_l lv with
  | Some g =>
      MtxfBody.is_byval (typeof lv)
      && (mem_id g stored_globals
          || (negb (mem_id g mwf_syms)
              && (nonptr_scalar (typeof lv) || ActWriterSurface.nonptr_binop_head rhs)))
  | None => false
  end.

Definition a_call_ok (ids : list ident) (optid : option ident) (a : expr)
    (al : list expr) : bool := gcall_ok ids a al.

Lemma dm_ovac :
  (prog_defmap area.prog) ! area._override_viewport_and_clip
    = Some (Gfun (Internal area.f_override_viewport_and_clip)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_swtr :
  (prog_defmap area.prog) ! area._set_warp_transition_rgb
    = Some (Gfun (Internal area.f_set_warp_transition_rgb)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ptr :
  (prog_defmap area.prog) ! area._play_transition
    = Some (Gfun (Internal area.f_play_transition)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_agwn :
  (prog_defmap area.prog) ! area._area_get_warp_node
    = Some (Gfun (Internal area.f_area_get_warp_node)).
Proof. vm_compute. reflexivity. Qed.

Definition ids_ptr : list ident := [area._set_warp_transition_rgb].

(* NON-VACUITY: the recognizers accept the REAL generated bodies *)
Lemma chk_ovac :
  tw_chk (fun _ _ => true) ast_ok (a_call_ok nil)
    (fn_body area.f_override_viewport_and_clip) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_swtr :
  tw_chk (fun _ _ => true) ast_ok (a_call_ok nil)
    (fn_body area.f_set_warp_transition_rgb) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_ptr :
  tw_chk (fun _ _ => true) ast_ok (a_call_ok ids_ptr)
    (fn_body area.f_play_transition) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_agwn :
  owf_chk nil gstore_ok (gcall_ok nil) (fn_body area.f_area_get_warp_node) = true.
Proof. vm_compute. reflexivity. Qed.
(* and the class is not vacuous: without the non-pointer clause the
   gFBSetColor store (a u32, not a stored global) is rejected *)
Example chk_ovac_needs_np :
  tw_chk (fun _ _ => true)
    (fun lv _ => match groot_l lv with
                 | Some g => MtxfBody.is_byval (typeof lv) && mem_id g stored_globals
                 | None => false end)
    (a_call_ok nil) (fn_body area.f_override_viewport_and_clip) = false.
Proof. vm_compute. reflexivity. Qed.

Lemma mem_id_app : forall g l1 l2, mem_id g (l1 ++ l2) = mem_id g l1 || mem_id g l2.
Proof. intros g l1 l2. unfold mem_id. apply existsb_app. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The rows, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

Section ObjExtRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  (* the Twelve capstone's own facts *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  Lemma ox_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.
  Lemma ox_glob : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Proof. destruct Hspawn as (init & Hs). exact (glob_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma ox_not_bm : forall b, SafeB b -> b <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bm lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma ox_not_bc : ~ SafeB bc.
  Proof. destruct Hspawn as (init & Hs). exact (safeb_not_bc lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma ox_gms : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gms_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma ox_gtimer : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Proof. destruct Hspawn as (init & Hs). exact (gtimer_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma ox_table : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Proof. destruct Hspawn as (init & Hs). exact (table_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.
  Lemma ox_ktab : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
  Proof. destruct Hspawn as (init & Hs). exact (ktab_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.

  (* a stored global's block: any store keeps the carried facts *)
  Lemma ox_glob_pres : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      blk_pres not_tainted bm MWF bg.
  Proof.
    intros gid bg Hg Hfs.
    destruct (mwf_real_glob lp bm bc oc0 SafeB ox_Hbc_bm ox_glob gid Hg bg Hfs) as (Hne & Hst).
    intros ch o v m1 m2 Hs Hv Hsat HM.
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hs | ].
      intros i _ [Hb _]. exact (Hne Hb).
    - exact (Hst _ _ _ _ _ HM Hs).
  Qed.

  (* a SafeB-if-pointer store into a SafeB block keeps the carried facts *)
  Lemma ox_safe_store : forall b ch z v m1 m2,
      SafeB b -> (forall bb oo, v = Vptr bb oo -> SafeB bb) ->
      Mem.store ch m1 b z v = Some m2 -> ow_facts bm MWF m1 -> ow_facts bm MWF m2.
  Proof.
    intros b ch z v m1 m2 Hs Hv Hst (Hvb & Hsat & HM).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (ox_not_bm b Hs Hb).
    - exact (mwf_real_chase_ptr lp bm bc oc0 SafeB ox_Hbc_bm ox_not_bm ox_not_bc ox_gms
               ox_gtimer ox_table ox_ktab _ _ _ _ _ _ HM Hs Hv Hst).
  Qed.

  (* ---- 4a. global-rooted stores and listed calls ---- *)

  Lemma gstore_pres : forall lv rhs le m t le' m' out,
      gstore_ok lv = true ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros lv rhs le m0 t0 le' m0' out Hok Hx Hf0.
    unfold gstore_ok in Hok.
    destruct (groot_l lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hgm Hbv].
    apply (assign_blk_pres bm MWF (lp_ge lp) empty_env le m0 lv rhs t0 le' m0' out);
      [ | exact Hbv | exact Hx | exact Hf0 ].
    intros loc ofs bf Hl.
    exact (ox_glob_pres g loc Hgm (groot_l_blk _ _ _ _ _ _ _ _ Hg Hl)).
  Qed.

  (* every function the symbol g resolves to keeps the carried facts *)
  Definition sym_pres (g : ident) : Prop :=
    forall b fd, Genv.find_symbol (lp_ge lp) g = Some b ->
      Genv.find_funct_ptr (lp_ge lp) b = Some fd ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.

  Lemma sym_pres_of_body : forall (q : Clight.program) g f,
      linkorder q lp ->
      (prog_defmap q) ! g = Some (Gfun (Internal f)) ->
      (forall m vargs t m' vres,
         eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
         ow_facts bm MWF m -> ow_facts bm MWF m') ->
      sym_pres g.
  Proof.
    intros q g f LO Hdm Hb b fd Hs Hfp.
    destruct (linkorder_resolves_funct lp _ g f LO Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hfp. rewrite Hs in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hf'. rewrite Hfp in Hf'.
    injection Hf' as ->. exact Hb.
  Qed.

  Lemma gcall_pres : forall ids,
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall optid a al le m t le' m' out,
        gcall_ok ids a al = true ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros ids Hids optid a al le m t le' m' out Hok Hx Hf.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [gcall_ok] in Hok.
    inv Hx.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    match goal with Hff : Genv.find_funct _ _ = Some _ |- _ =>
      rewrite Genv.find_funct_find_funct_ptr in Hff end.
    match goal with Hfp : Genv.find_funct_ptr _ _ = Some ?fd,
                    Hfc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
      exact (Hids fid Hok lf fd Hsy Hfp _ _ _ _ _ Hfc Hf) end.
  Qed.

  Lemma gbody_pres : forall ids f,
      fn_vars f = nil ->
      owf_chk nil gstore_ok (gcall_ok ids) (fn_body f) = true ->
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros ids f Hv Hchk Hids.
    exact (nl_body_frame_c (lp_ge lp) MWF bm f gstore_ok (gcall_ok ids) Hv Hchk
             gstore_pres (gcall_pres ids Hids)).
  Qed.

  (* the any-argument row from the symbol fact *)
  Lemma row_of_sym : forall fid, sym_pres fid -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid Hp fd m0 vargs0 t0 m1 vres0 Hevf (b & Hs & Hff) _ HM Hv Hsat.
    rewrite Genv.find_funct_find_funct_ptr in Hff.
    destruct (Hp b fd Hs Hff _ _ _ _ _ Hevf (conj Hv (conj Hsat HM))) as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.

  Ltac ids_pres :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg;
    cbn [mem_id existsb ids_course_star_count ids_total_star_count ids_touch_age
         ids_max_coin_score ids_collect] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  Ltac sf_sym dm chk ids :=
    apply (sym_pres_of_body save_file.prog _ _ (linked12_LO_save lp H12) dm);
    apply (gbody_pres ids); [ reflexivity | exact chk | ids_pres ].

  (* ---- 4b. the save_file.c bodies ---- *)

  Lemma sp_get_flags : sym_pres save_file._save_file_get_flags.
  Proof. sf_sym dm_get_flags chk_get_flags (@nil ident). Qed.
  Lemma sp_get_star_flags : sym_pres save_file._save_file_get_star_flags.
  Proof. sf_sym dm_get_star_flags chk_get_star_flags (@nil ident). Qed.
  Lemma sp_course_star_count : sym_pres save_file._save_file_get_course_star_count.
  Proof.
    pose proof sp_get_star_flags.
    sf_sym dm_course_star_count chk_course_star_count ids_course_star_count.
  Qed.
  Lemma sp_total_star_count : sym_pres save_file._save_file_get_total_star_count.
  Proof.
    pose proof sp_course_star_count.
    sf_sym dm_total_star_count chk_total_star_count ids_total_star_count.
  Qed.
  Lemma sp_set_flags : sym_pres save_file._save_file_set_flags.
  Proof. sf_sym dm_set_flags chk_set_flags (@nil ident). Qed.
  Lemma sp_clear_flags : sym_pres save_file._save_file_clear_flags.
  Proof. sf_sym dm_clear_flags chk_clear_flags (@nil ident). Qed.
  Lemma sp_course_coin_score : sym_pres save_file._save_file_get_course_coin_score.
  Proof. sf_sym dm_course_coin_score chk_course_coin_score (@nil ident). Qed.
  Lemma sp_get_age : sym_pres save_file._get_coin_score_age.
  Proof. sf_sym dm_get_age chk_get_age (@nil ident). Qed.
  Lemma sp_set_age : sym_pres save_file._set_coin_score_age.
  Proof. sf_sym dm_set_age chk_set_age (@nil ident). Qed.
  Lemma sp_touch_age : sym_pres save_file._touch_coin_score_age.
  Proof.
    pose proof sp_get_age. pose proof sp_set_age.
    sf_sym dm_touch_age chk_touch_age ids_touch_age.
  Qed.
  Lemma sp_max_coin_score : sym_pres save_file._save_file_get_max_coin_score.
  Proof.
    pose proof sp_get_star_flags. pose proof sp_course_coin_score. pose proof sp_get_age.
    sf_sym dm_max_coin_score chk_max_coin_score ids_max_coin_score.
  Qed.
  Lemma sp_set_star_flags : sym_pres save_file._save_file_set_star_flags.
  Proof. sf_sym dm_set_star_flags chk_set_star_flags (@nil ident). Qed.
  Lemma sp_collect : sym_pres save_file._save_file_collect_star_or_key.
  Proof.
    pose proof sp_get_flags. pose proof sp_max_coin_score. pose proof sp_course_coin_score.
    pose proof sp_touch_age. pose proof sp_set_flags. pose proof sp_get_star_flags.
    pose proof sp_set_star_flags.
    sf_sym dm_collect chk_collect ids_collect.
  Qed.

  (* ---- 4c. object_helpers.c's time-stop pair ---- *)

  Lemma sp_ets : sym_pres object_helpers._enable_time_stop.
  Proof.
    apply (sym_pres_of_body object_helpers.prog _ _ (linked12_LO_object_helpers lp H12) dm_ets).
    apply (gbody_pres nil); [ reflexivity | exact chk_ets | ids_pres ].
  Qed.
  Lemma sp_dts : sym_pres object_helpers._disable_time_stop.
  Proof.
    apply (sym_pres_of_body object_helpers.prog _ _ (linked12_LO_object_helpers lp H12) dm_dts).
    apply (gbody_pres nil); [ reflexivity | exact chk_dts | ids_pres ].
  Qed.

  (* ---- 4d. bhv_spawn_star_no_level_exit ---- *)

  Definition sp_P (sp : list ident) (le : temp_env) : Prop :=
    forall t b o, mem_id t sp = true -> le ! t = Some (Vptr b o) -> SafeB b.

  Lemma val_ok_safe : forall sp le m a v,
      val_ok sp a = true -> sp_P sp le -> MWF m ->
      eval_expr (lp_ge lp) empty_env le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros sp le m a v Hok HP HM Hev b o ->.
    destruct a as [ i ity | | | | x xty | t tty | | | | op a1 a2 bty | | | | ];
      try discriminate Hok.
    - (* Econst_int *)
      inversion Hev; subst;
        match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
          inversion Hl end.
    - (* Evar: the gCurrentObject load *)
      destruct xty as [ | | | | pt pa | | | | ]; try discriminate Hok.
      cbn [val_ok gco_expr] in Hok. apply Pos.eqb_eq in Hok. subst x.
      inversion Hev; subst.
      match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inversion Hl; subst end.
      + match goal with Hz : empty_env ! _ = Some _ |- _ =>
          rewrite PTree.gempty in Hz; discriminate Hz end.
      + match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inversion Hd; subst end.
        * match goal with Ha : access_mode _ = By_value _ |- _ => cbn in Ha; injection Ha as <- end.
          match goal with Hs : Genv.find_symbol _ _ = Some ?gb,
                          Hld : Mem.loadv _ _ _ = Some (Vptr b o) |- _ =>
            pose proof (proj2 (proj2 HSafeB_syms) _ _ gco_safe_sym Hs) as Hgs;
            exact (mwf_real_chase_step lp bm bc oc0 SafeB _ _ _ _ _ HM Hgs Hld) end.
        * match goal with Ha : access_mode _ = By_reference |- _ => discriminate Ha end.
        * match goal with Ha : access_mode _ = By_copy |- _ => discriminate Ha end.
    - (* Etempvar *)
      cbn [val_ok] in Hok.
      inversion Hev; subst;
        [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
              inversion Hl end ].
      match goal with Hg : _ ! _ = Some (Vptr b o) |- _ => exact (HP _ _ _ Hok Hg) end.
    - (* a never-pointer binop *)
      exfalso.
      exact (ActWriterSurface.eval_nonptr_binop_head _ _ _ _ _ _ _ _ _ Hok Hev b o eq_refl).
  Qed.

  Lemma ox_set : forall sp id a le m v,
      ox_set_ok sp id a = true -> sp_P sp le -> ow_facts bm MWF m ->
      eval_expr (lp_ge lp) empty_env le m a v -> sp_P sp (PTree.set id v le).
  Proof.
    intros sp id a le m v Hok HP (_ & _ & HM) Hev t b o Ht Hle.
    destruct (peq t id) as [-> | Hne].
    - rewrite PTree.gss in Hle. injection Hle as ->.
      unfold ox_set_ok in Hok. rewrite Ht in Hok. cbn [negb orb] in Hok.
      exact (val_ok_safe sp le m a _ Hok HP HM Hev b o eq_refl).
    - rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ Ht Hle).
  Qed.

  Lemma ox_store : forall sp lv rhs le m t le' m' out,
      ox_store_ok sp lv rhs = true -> sp_P sp le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros sp lv rhs le m t le' m' out Hok HP Hx Hf.
    unfold ox_store_ok in Hok.
    destruct (chain_root_l lv) as [tr|] eqn:Hcr; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hok Hval]. apply andb_prop in Hok as [Ht Hbv].
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lv _ _ _ |- _ =>
      destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hl) as (o0 & Hle) end.
    pose proof (HP tr _ _ Ht Hle) as Hsb.
    match goal with
    | Hr : eval_expr _ _ _ _ rhs ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?v |- _ =>
      assert (Hsv : forall bb oo, v = Vptr bb oo -> SafeB bb);
      [ intros bb oo Ebb; rewrite Ebb in Hc;
        pose proof (sem_cast_vptr_inv _ _ _ _ _ _ Hc) as Ev; rewrite Ev in Hr;
        exact (val_ok_safe sp _ _ rhs _ Hval HP (proj2 (proj2 Hf)) Hr bb oo eq_refl)
      | ]
    end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
    - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hst; exact (ox_safe_store _ _ _ _ _ _ Hsb Hsv Hst Hf) end.
    - unfold MtxfBody.is_byval in Hbv.
      match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hst;
        refine (ox_safe_store _ _ _ _ _ _ Hsb _ Hst Hf); intros bb oo E; discriminate E end.
  Qed.

  (* every argument value is SafeB-if-pointer *)
  Lemma args_safe : forall sp le m al tyl vl,
      eval_exprlist (lp_ge lp) empty_env le m al tyl vl ->
      forallb (val_ok sp) al = true -> sp_P sp le -> MWF m ->
      Forall (fun v => forall b o, v = Vptr b o -> SafeB b) vl.
  Proof.
    intros sp le m al tyl vl Hel. induction Hel; intros Hok HP HM; [ constructor | ].
    cbn [forallb] in Hok. apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel H2 HP HM) ].
    intros b o ->.
    match goal with Hc : sem_cast ?v1 _ _ _ = Some (Vptr b o),
                    He : eval_expr _ _ _ _ ?a ?v1 |- _ =>
      pose proof (sem_cast_vptr_inv _ _ _ _ _ _ Hc) as Ev; subst v1;
      exact (val_ok_safe sp le m a _ H1 HP HM He b o eq_refl) end.
  Qed.

  (* obj_set_angle(obj, pitch, yaw, roll): four integer stores through obj *)
  Lemma osa_frame : forall m vargs t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m
        (Internal object_helpers.f_obj_set_angle) vargs t m' vres ->
      Forall (fun v => forall b o, v = Vptr b o -> SafeB b) vargs ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros m vargs t m' vres Hevf Hva Hf.
    refine (tw_body_frame (lp_ge lp) MWF bm object_helpers.f_obj_set_angle (sp_P osa_sp)
              (ox_set_ok osa_sp) (ox_store_ok osa_sp) (fun _ _ _ => false)
              eq_refl osa_chk (ox_set osa_sp) (ox_store osa_sp) _ _ _ _ _ _ Hevf _ Hf).
    - intros ? ? ? ? ? ? ? ? ? Hno. discriminate Hno.
    - intros le1 Hb t0 b o _ Hle.
      refine (bind_safe (fun v => forall b o, v = Vptr b o -> SafeB b) _ _ _ _ Hb Hva _
                t0 _ Hle b o eq_refl).
      intros t1 v1 Ht1 b1 o1 ->.
      apply MtxfBody.create_undef_temps_get in Ht1. discriminate Ht1.
  Qed.

  (* spawn_object's gated row (SpawnBodies.Hcp_spawn_sg at the capstone):
     every argument SafeB-if-pointer or a spawn_bhv_syms script *)
  Hypothesis Hcp_spawn :
    call_pres_ext_sg lp bm NoA MWF SafeB behavior_actions._spawn_object.

  Lemma ox_call : forall sp optid a al le m t le' m' out,
      ox_call_ok sp optid a al = true -> sp_P sp le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m' /\ sp_P sp le'.
  Proof.
    intros sp optid a al le m t le' m' out Hok HP Hx Hf.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [ox_call_ok] in Hok.
    inv Hx.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    apply orb_true_iff in Hok as [Hsp | Hosa].
    - (* spawn_object: the gated sg row *)
      apply andb_prop in Hsp as [Hsp Hsa].
      apply Pos.eqb_eq in Hsp. subst fid.
      destruct Hf as (Hv & Hs & HM).
      match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ => cbn in Hcf; injection Hcf as E1 E2 E3; subst end.
      match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
        pose proof (spawn_args_sound lp SafeB empty_env le m spawn_bhv_syms sp _ _ _
                      (fun g _ => PTree.gempty _ g)
                      (fun t Ht b o Hg => HP t b o Ht Hg) Hsa Hel) as Hva end.
      match goal with Hff : Genv.find_funct _ _ = Some ?fd,
                      Hfc : eval_funcall _ _ _ ?fd _ _ _ ?vr |- _ =>
        destruct (Hcp_spawn _ _ _ _ _ _ Hfc (ex_intro _ lf (conj Hsy Hff)) Hva
                    (mwf_real_ctl lp bm bc oc0 SafeB _ HM) HM Hv Hs)
          as (Hv' & Hs' & HM' & Hr)
      end.
      split; [ exact (conj Hv' (conj Hs' HM')) | ].
      intros t0 b o Ht0 Hle.
      destruct optid as [ti|]; cbn [set_opttemp] in Hle; [ | exact (HP _ _ _ Ht0 Hle) ].
      destruct (peq t0 ti) as [-> | Hne].
      + rewrite PTree.gss in Hle. injection Hle as Ev. exact (Hr b o Ev).
      + rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ Ht0 Hle).
    - (* obj_set_angle: the real object_helpers body *)
      apply andb_prop in Hosa as [Hosa Hopt]. apply andb_prop in Hosa as [Hid Hal].
      apply Pos.eqb_eq in Hid. subst fid.
      destruct optid as [ti|]; [ discriminate Hopt | ].
      destruct (linkorder_resolves_funct lp _ _ _ (linked12_LO_object_helpers lp H12) dm_osa)
        as (b' & Hs' & Hff').
      unfold lp_ge in Hsy. rewrite Hsy in Hs'. injection Hs' as <-.
      match goal with Hff : Genv.find_funct _ _ = Some ?fd |- _ =>
        unfold lp_ge in Hff; rewrite Hff' in Hff; injection Hff as <- end.
      match goal with Hel : eval_exprlist _ _ _ _ _ _ _,
                      Hfc : eval_funcall _ _ _ (Internal object_helpers.f_obj_set_angle) _ _ _ _ |- _ =>
        pose proof (args_safe sp _ _ _ _ _ Hel Hal HP (proj2 (proj2 Hf))) as Hva;
        exact (conj (osa_frame _ _ _ _ _ Hfc Hva Hf) HP)
      end.
  Qed.

  Lemma sp_bs : sym_pres interaction._bhv_spawn_star_no_level_exit.
  Proof.
    apply (sym_pres_of_body behavior_actions.prog _ _ (linked12_LO_beh lp H12) dm_bs).
    intros m vargs t m' vres Hevf Hf.
    refine (tw_body_frame (lp_ge lp) MWF bm behavior_actions.f_bhv_spawn_star_no_level_exit
              (sp_P bs_sp) (ox_set_ok bs_sp) (ox_store_ok bs_sp) (ox_call_ok bs_sp)
              eq_refl bs_chk (ox_set bs_sp) (ox_store bs_sp) (ox_call bs_sp)
              _ _ _ _ _ Hevf _ Hf).
    (* entry: the three pointer temps start undefined (the u32 starIndex is
       not one of them) *)
    intros le1 Hb t0 b o Ht0 Hle.
    rewrite (bind_parameter_temps_gso _ _ _ _ t0 Hb) in Hle.
    - apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
    - cbn [var_names map fst fn_params behavior_actions.f_bhv_spawn_star_no_level_exit].
      intros [E | []]. subst t0. vm_compute in Ht0. discriminate Ht0.
  Qed.

  (* ---- 4e. THE ROWS ---- *)

  Lemma Hpx_get_flags : call_pres_ext lp bm NoA MWF interaction._save_file_get_flags.
  Proof. exact (row_of_sym _ sp_get_flags). Qed.
  Lemma Hpx_get_star_flags :
    call_pres_ext lp bm NoA MWF level_update._save_file_get_star_flags.
  Proof. exact (row_of_sym _ sp_get_star_flags). Qed.
  Lemma Hpx_total_star_count :
    call_pres_ext lp bm NoA MWF interaction._save_file_get_total_star_count.
  Proof. exact (row_of_sym _ sp_total_star_count). Qed.
  Lemma Hpx_collect :
    call_pres_ext lp bm NoA MWF interaction._save_file_collect_star_or_key.
  Proof. exact (row_of_sym _ sp_collect). Qed.
  Lemma Hpx_set_flags : call_pres_ext lp bm NoA MWF interaction._save_file_set_flags.
  Proof. exact (row_of_sym _ sp_set_flags). Qed.
  Lemma Hpx_clear_flags : call_pres_ext lp bm NoA MWF interaction._save_file_clear_flags.
  Proof. exact (row_of_sym _ sp_clear_flags). Qed.
  Lemma Hpx_ets : call_pres_ext lp bm NoA MWF mario_actions_cutscene._enable_time_stop.
  Proof. exact (row_of_sym _ sp_ets). Qed.
  Lemma Hpx_dts : call_pres_ext lp bm NoA MWF mario_actions_cutscene._disable_time_stop.
  Proof. exact (row_of_sym _ sp_dts). Qed.
  Lemma Hpx_bs :
    call_pres_ext lp bm NoA MWF interaction._bhv_spawn_star_no_level_exit.
  Proof. exact (row_of_sym _ sp_bs). Qed.

  (* ---- 4f. area.c: the viewport override, the warp transition, the
     warp-node lookup ---- *)

  (* a global MWF does not read is apart from every block it does read *)
  Lemma np_ne : forall g bg id b,
      mem_id g mwf_syms = false -> Genv.find_symbol (lp_ge lp) g = Some bg ->
      mem_id id mwf_syms = true -> Genv.find_symbol (lp_ge lp) id = Some b ->
      bg <> b.
  Proof.
    intros g bg id b Hg Hfs Hid Hfs2.
    eapply Genv.global_addresses_distinct; [ | exact Hfs | exact Hfs2 ].
    intro E. subst id. rewrite Hg in Hid. discriminate Hid.
  Qed.

  (* a NON-pointer store into such a global keeps the carried facts: no
     transfer row reads the block, and R7 cannot gain a pointer *)
  Lemma np_store_pres : forall g bg ch z v m1 m2,
      mem_id g mwf_syms = false -> Genv.find_symbol (lp_ge lp) g = Some bg ->
      (forall bb oo, v <> Vptr bb oo) ->
      Mem.store ch m1 bg z v = Some m2 ->
      ow_facts bm MWF m1 -> ow_facts bm MWF m2.
  Proof.
    intros g bg ch z v m1 m2 Hg Hfs Hnp Hst (Hvb & Hsat & HM).
    pose proof Hspawn as (init & _ & Hbm & Hbc & _).
    assert (Hne : forall id b, mem_id id mwf_syms = true ->
                 Genv.find_symbol (lp_ge lp) id = Some b -> bg <> b)
      by (intros id b; exact (np_ne g bg id b Hg Hfs)).
    assert (Hnbm : bg <> bm) by exact (Hne level_update._gMarioStates bm eq_refl Hbm).
    split; [ eauto using Mem.store_valid_block_1 | split ].
    - eapply action_sat_unchanged_on with (m := m1); [ | exact Hvb | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb _]. exact (Hnbm Hb).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB ox_Hbc_bm m1 m2); [ .. | exact HM ].
      + intros b Hv. eapply Mem.store_valid_block_1; eauto.
      + intros v0 Hld. pose proof HM as (_ & R1 & _). apply R1.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left; congruence ].
      + intros ch1 b ofs v0 Hrow Hld.
        rewrite <- Hld. symmetry.
        eapply Mem.load_store_other; [ exact Hst | left ].
        intro E. subst b.
        destruct Hrow as [ [Eb _] | [ Eb | [ Hfs2 | [ Hfs2 | [ Hfs2 | [ Hkt | Hab ] ] ] ] ] ].
        * exact (Hnbm Eb).
        * exact (Hne mario._gControllers bc eq_refl Hbc Eb).
        * exact (Hne mario._gMarioState bg eq_refl Hfs2 eq_refl).
        * exact (Hne interaction._gGlobalTimer bg eq_refl Hfs2 eq_refl).
        * exact (Hne interaction._sInteractionHandlers bg eq_refl Hfs2 eq_refl).
        * destruct Hkt as (gid2 & Hg2 & Hfs2).
          refine (Hne gid2 bg _ Hfs2 eq_refl).
          unfold mwf_syms. rewrite mem_id_app, Hg2. apply orb_true_r.
        * exact (Hne mario._gMarioAnimsBuf bg eq_refl Hab eq_refl).
      + intros b ofs b' o' Hs Hld.
        pose proof HM as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
        cbn in Hld.
        destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
          as [ (Evv & _) | Hdis ].
        * exfalso. exact (Hnp _ _ Evv).
        * apply (R7 b ofs b' o' Hs). cbn.
          rewrite <- Hld. symmetry.
          eapply Mem.load_store_other; [ exact Hst | exact Hdis ].
  Qed.

  Lemma ast_store_pres : forall lv rhs le m t le' m' out,
      ast_ok lv rhs = true ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros lv rhs le m0 t0 le' m0' out Hok Hx Hf0.
    unfold ast_ok in Hok.
    destruct (groot_l lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hbv Hor].
    apply orb_true_iff in Hor as [Hsg | Hnp].
    - (* a stored global *)
      refine (gstore_pres lv rhs le m0 t0 le' m0' out _ Hx Hf0).
      unfold gstore_ok. rewrite Hg, Hsg. exact Hbv.
    - (* a global MWF does not read, non-pointer value *)
      apply andb_prop in Hnp as [Hng Hval]. apply negb_true_iff in Hng.
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
        pose proof (groot_l_blk _ _ _ _ _ _ _ _ Hg Hl) as Hfs end.
      match goal with
      | Hr : eval_expr _ _ _ _ rhs ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?v |- _ =>
        assert (Hvnp : forall bb oo, v <> Vptr bb oo);
        [ apply orb_true_iff in Hval as [Hsc | Hbo];
          [ exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hsc Hc)
          | destruct rhs as [ | | | | | | | | | op r1 r2 rty | | | | ]; try discriminate Hbo;
            exact (ActWriterSurface.sem_cast_nonptr_pres _ _ _ _ _ Hc
                     (ActWriterSurface.eval_nonptr_binop_head _ _ _ _ _ _ _ _ _ Hbo Hr)) ]
        | ]
      end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      + match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst; exact (np_store_pres _ _ _ _ _ _ _ Hng Hfs Hvnp Hst Hf0) end.
      + unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
      + match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          refine (np_store_pres _ _ _ _ _ _ _ Hng Hfs _ Hst Hf0); intros bb oo E; discriminate E end.
  Qed.

  Lemma abody_pres : forall ids f,
      fn_vars f = nil ->
      tw_chk (fun _ _ => true) ast_ok (a_call_ok ids) (fn_body f) = true ->
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros ids f Hv Hchk Hids m vargs t m' vres Hevf Hf.
    refine (tw_body_frame (lp_ge lp) MWF bm f (fun _ => True) (fun _ _ => true) ast_ok
              (a_call_ok ids) Hv Hchk _ _ _ _ _ _ _ _ Hevf _ Hf).
    - intros; exact I.
    - intros lv rhs le m0 t0 le' m0' out Hok _ Hx Hf0.
      exact (ast_store_pres lv rhs le m0 t0 le' m0' out Hok Hx Hf0).
    - intros optid a al le m0 t0 le' m0' out Hok _ Hx Hf0.
      split; [ | exact I ].
      exact (gcall_pres ids Hids optid a al le m0 t0 le' m0' out Hok Hx Hf0).
    - intros; exact I.
  Qed.

  Lemma sp_ovac : sym_pres area._override_viewport_and_clip.
  Proof.
    apply (sym_pres_of_body area.prog _ _ (linked12_LO_area lp H12) dm_ovac).
    apply (abody_pres nil); [ reflexivity | exact chk_ovac | ids_pres ].
  Qed.
  Lemma sp_swtr : sym_pres area._set_warp_transition_rgb.
  Proof.
    apply (sym_pres_of_body area.prog _ _ (linked12_LO_area lp H12) dm_swtr).
    apply (abody_pres nil); [ reflexivity | exact chk_swtr | ids_pres ].
  Qed.
  Lemma sp_ptr : sym_pres area._play_transition.
  Proof.
    pose proof sp_swtr.
    apply (sym_pres_of_body area.prog _ _ (linked12_LO_area lp H12) dm_ptr).
    apply (abody_pres ids_ptr); [ reflexivity | exact chk_ptr | ].
    intros g Hg. cbn [mem_id existsb ids_ptr] in Hg.
    apply orb_true_iff in Hg as [Hg | Hg]; [ | discriminate Hg ].
    apply Pos.eqb_eq in Hg. subst g. assumption.
  Qed.
  Lemma sp_agwn : sym_pres area._area_get_warp_node.
  Proof.
    apply (sym_pres_of_body area.prog _ _ (linked12_LO_area lp H12) dm_agwn).
    apply (gbody_pres nil); [ reflexivity | exact chk_agwn | ids_pres ].
  Qed.

  Lemma Hpx_ovac :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._override_viewport_and_clip.
  Proof. exact (row_of_sym _ sp_ovac). Qed.
  Lemma Hpx_ptr : call_pres_ext lp bm NoA MWF level_update._play_transition.
  Proof. exact (row_of_sym _ sp_ptr). Qed.
  Lemma Hpx_agwn : call_pres_ext lp bm NoA MWF level_update._area_get_warp_node.
  Proof. exact (row_of_sym _ sp_agwn). Qed.
End ObjExtRows.
