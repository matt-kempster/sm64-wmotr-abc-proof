(* ====================================================================== *)
(* THE WARP-TRIGGER SURFACE: Hpres_warp DISCHARGED DOWN TO ITS FIVE       *)
(* EXTERNAL LEAF CALLEES (SPINE: consumed by the MWF-grounded capstone,   *)
(* both directly and as FloorsSurface's shared fifth leaf).               *)
(*                                                                        *)
(* f_level_trigger_warp (level_update.prog, ~690 lines) makes 33 stores:  *)
(* 32 at the five whitelisted level_update statics (sDelayedWarpOp/Arg/   *)
(* Timer, sSourceWarpNodeId, gSavedCourseNum -- stored_globals, store     *)
(* class G) + 1 at m->invincTimer (the window class).  It calls FIVE      *)
(* leaves: play_transition / play_sound / fadeout_music /                 *)
(* area_get_warp_node -- External in lp -- and ONE internal helper,       *)
(* music_changed_through_warp (level_update.prog, store-free), which is   *)
(* itself WALKED here down to its own two external callees                *)
(* (area_get_warp_node + get_current_background_music).                   *)
(*                                                                        *)
(* None of the five externals takes Mario's pointer first, so the         *)
(* per-callee residual is the marg-FREE call_pres_ext shape: any call     *)
(* site fits, and each row is a link-time fact about one named sound/     *)
(* transition/warp-node helper.                                           *)
(*                                                                        *)
(* The walk is the SAME generic walker as FloorsSurface (walk_chk with    *)
(* the xids external census + the glob_store_chk Sassign arm): ONE        *)
(* vm_compute body pin covers each body.                                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_airborne level_update.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.

Import ListNotations.

(* ====================================================================== *)
(* The warp-trigger censuses.                                             *)
(* ====================================================================== *)

(* THE RESIDUAL CENSUS: the five External-in-lp leaves. *)
Definition warp_ext_ids : list ident :=
  level_update._area_get_warp_node ::
  level_update._fadeout_music ::
  level_update._play_sound ::
  level_update._play_transition ::
  level_update._get_current_background_music :: nil.

(* the warp body's callees = the externals + the WALKED internal helper *)
Definition warp_callee_ids : list ident :=
  level_update._music_changed_through_warp :: warp_ext_ids.

(* THE BODY PINS: each body passes the walker recognizer. *)
Example mctw_body_ok :
  walk_chk nil warp_ext_ids
    (fn_body level_update.f_music_changed_through_warp) = true.
Proof. vm_compute. reflexivity. Qed.

Example warp_body_ok :
  walk_chk nil warp_callee_ids
    (fn_body level_update.f_level_trigger_warp) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROLS: with an empty external census each body FAILS the
   recognizer (the call sites are real obligations). *)
Example mctw_body_census_not_vacuous :
  walk_chk nil nil (fn_body level_update.f_music_changed_through_warp) = false.
Proof. vm_compute. reflexivity. Qed.

Example warp_body_census_not_vacuous :
  walk_chk nil nil (fn_body level_update.f_level_trigger_warp) = false.
Proof. vm_compute. reflexivity. Qed.

(* the internal helper resolves to THE real level_update body *)
Example mctw_internal :
  (prog_defmap level_update.prog) ! level_update._music_changed_through_warp
  = Some (Gfun (Internal level_update.f_music_changed_through_warp)).
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walks.                                                             *)
(* ====================================================================== *)

Section WarpSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_lvl : linkorder level_update.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  (* the whitelisted-global store row (MWFReal.mwf_real_glob's shape) *)
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').

  (* THE RESIDUAL: the five external leaves, keyed by the census. *)
  Hypothesis Hpres_ext : forall fid,
      mem_id fid warp_ext_ids = true ->
      call_pres_ext lp bm NoA MWF fid.

  (* neither body has a Mario-arg internal census; the walker's ids
     slot gets the trivially-true empty residual. *)
  Lemma warp_no_int_calls :
    forall fid, mem_id fid (@nil ident) = true ->
      call_pres lp bm NoA MWF fid.
  Proof. intros fid H. cbn in H. discriminate H. Qed.

  (* ================================================================== *)
  (* The internal helper, WALKED: music_changed_through_warp is         *)
  (* store-free (loads + branches + two external calls), takes no       *)
  (* Mario pointer (no _m temp at all: the provenance fact is vacuous), *)
  (* and resolves to its real level_update body via linkorder.          *)
  (* ================================================================== *)
  Lemma mctw_call_pres_ext :
    call_pres_ext lp bm NoA MWF level_update._music_changed_through_warp.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres HN HM HV HS.
    pose proof (resolve_pin_fd lp _ _ _ _ LO_lvl mctw_internal Hres) as ->.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars level_update.f_music_changed_through_warp)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params level_update.f_music_changed_through_warp)
      with ((level_update._arg, tshort) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs0 as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the helper has NO _m temp: the provenance fact holds vacuously *)
    assert (Htat0 : forall b o,
               (PTree.set level_update._arg v0
                  (create_undef_temps
                     (fn_temps level_update.f_music_changed_through_warp)))
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      vm_compute in Hg. discriminate Hg. }
    destruct (walk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob nil warp_ext_ids warp_no_int_calls Hpres_ext
                _ _ _ _ _ _ _ _ Hbody eq_refl mctw_body_ok
                Htat0 HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* the warp body's per-callee residuals: the five externals come from
     the census hypothesis; the internal helper's row is PROVED above. *)
  Lemma warp_call_pres_ext :
    forall fid, mem_id fid warp_callee_ids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid Hmem.
    unfold warp_callee_ids in Hmem. cbn [mem_id existsb] in Hmem.
    apply orb_true_iff in Hmem as [Hm | Hrest].
    - apply Pos.eqb_eq in Hm. subst fid. exact mctw_call_pres_ext.
    - exact (Hpres_ext fid Hrest).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_warp itself, PROVED from the five per-external   *)
  (* residuals.                                                         *)
  (* ================================================================== *)
  Theorem warp_pres :
    body_pres lp NoA MWF bm level_update.f_level_trigger_warp.
  Proof.
    intros m vargs t m' vres Hmargp Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs).
    { apply Hmargp. vm_compute. reflexivity. }
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars level_update.f_level_trigger_warp)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params level_update.f_level_trigger_warp)
      with ((mario_actions_airborne._m, tyMSp)
              :: (level_update._warpOp, tint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest as [| v1 vrest2]; [ discriminate Hbind | ].
    destruct vrest2; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps level_update.f_level_trigger_warp)) in *.
    assert (Htat0 : forall b o,
               (PTree.set level_update._warpOp v1
                  (PTree.set mario_actions_airborne._m v0 base))
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    destruct (walk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob nil warp_callee_ids warp_no_int_calls
                warp_call_pres_ext
                _ _ _ _ _ _ _ _ Hbody eq_refl warp_body_ok
                Htat0 HN HM HV HS)
      as (HV' & HS' & HM' & _ & _).
    repeat split; assumption.
  Qed.

End WarpSurface.
