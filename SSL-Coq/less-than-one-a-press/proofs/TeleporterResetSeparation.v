(** The held-object store and the platform store are different memory events.
    This file consumes actual generated reset executions. A later effective
    displacement after a real spawn reset requires replacing its null value;
    it does not assume that all intervening callbacks preserve that value. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario us_platform_displacement
  us_object_list_processor.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  TeleporterWrongWarpBoundary TeleporterDestinationReset
  TeleporterPlatformResetExecution InkPlatformSource InkPlatformDeparture
  SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Definition TRSHeldResetPreservesSeparatePlatform : Prop :=
  forall version e le before mb mo pb pointer trace last after out,
  le ! us_mario._t'90 = Some (Vptr mb mo) ->
  mb <> pb ->
  Mem.load Mptr before pb 0 = Some pointer ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tww_held_object_reset_statement trace last after out ->
  Mem.load Mptr after mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) =
    Some (Vint Int.zero) /\
  Mem.load Mptr after pb 0 = Some pointer.

Theorem trs_held_reset_preserves_separate_platform :
  TRSHeldResetPreservesSeparatePlatform.
Proof.
  unfold TRSHeldResetPreservesSeparatePlatform.
  intros version e le before mb mo pb pointer trace last after out
    Htemp Hseparate Hload Hrun.
  destruct (tdr_reached_held_reset_stores_null version e le before mb mo
    trace last after out Htemp Hrun) as (_ & _ & _ & Hstore & Hnull).
  split; [exact Hnull|].
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore
    Mptr pb 0 ltac:(left; congruence)). exact Hload.
Qed.

(** In particular, reaching the actual held-object reset is not evidence of
    platform clearing. This is conditional local retention, not a reachable
    full-warp counterexample. *)
Theorem trs_held_reset_can_leave_platform_nonnull :
  forall version e le before mb mo pb ob ofs trace last after out,
  le ! us_mario._t'90 = Some (Vptr mb mo) ->
  mb <> pb ->
  Mem.load Mptr before pb 0 = Some (Vptr ob ofs) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tww_held_object_reset_statement trace last after out ->
  Mem.load Mptr after mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) =
    Some (Vint Int.zero) /\
  Mem.load Mptr after pb 0 <> Some (Vint Int.zero).
Proof.
  intros version e le before mb mo pb ob ofs trace last after out
    Htemp Hseparate Hload Hrun.
  destruct (trs_held_reset_preserves_separate_platform version e le before
    mb mo pb (Vptr ob ofs) trace last after out
    Htemp Hseparate Hload Hrun) as [Hheld Hplatform].
  split; [exact Hheld|]. rewrite Hplatform. discriminate.
Qed.

(** This consumes a complete actual non-JP spawn funcall and the complete
    actual displacement dispatcher. It retains the reset checkpoint inside
    spawn, rather than pretending the later allocation suffix preserves it.
    An effective later dispatcher therefore needs a different platform load.
    Whether the first relevant arrival reaches these calls is still separate. *)
Definition TRSSpawnNullCheckpoint before args spawn_trace spawned spawn_result
    platform_cell reset_memory : Prop :=
  exists e le allocated body_last body_after body_out clear_le clear_m
    done_le pre clear_t suf,
    function_entry2 (Clight.globalenv (selected_clight_target VersionUS))
      us_object_list_processor.f_spawn_objects_from_info
      args before e le allocated /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le allocated
      (fn_body us_object_list_processor.f_spawn_objects_from_info)
      spawn_trace body_last body_after body_out /\
    outcome_result_value body_out
      (fn_return us_object_list_processor.f_spawn_objects_from_info)
      spawn_result body_after /\
    Mem.free_list body_after
      (blocks_of_env (Clight.globalenv (selected_clight_target VersionUS)) e) =
      Some spawned /\
    spawn_trace = pre ++ (clear_t ++ suf) /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le allocated
      (ocn_prepend tpr_spawn_prefix Sskip) pre clear_le clear_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e clear_le clear_m
      tww_clear_platform_call clear_t done_le reset_memory Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e done_le reset_memory
      tpr_spawn_after_clear suf body_last body_after body_out /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target VersionUS))
      us_platform_displacement._gMarioPlatform = Some platform_cell /\
    Mem.load Mptr reset_memory platform_cell 0 = Some (Vint Int.zero).

Definition TRSSpawnResetMakesReplacementNecessary : Prop :=
  forall before args spawn_trace spawned spawn_result next apply_trace
    after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target VersionUS)) before
    (Internal us_object_list_processor.f_spawn_objects_from_info)
    args spawn_trace spawned spawn_result ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target VersionUS)) next
    (Internal (ipd_body VersionUS IPDApply)) [] apply_trace after result ->
  after <> next ->
  exists platform_cell reset_memory,
    TRSSpawnNullCheckpoint before args spawn_trace spawned spawn_result
      platform_cell reset_memory /\
    Mem.load Mptr next platform_cell 0 <>
      Mem.load Mptr reset_memory platform_cell 0.

Theorem trs_spawn_reset_makes_effective_apply_require_replacement :
  TRSSpawnResetMakesReplacementNecessary.
Proof.
  unfold TRSSpawnResetMakesReplacementNecessary.
  intros before args spawn_trace spawned spawn_result next apply_trace
    after result Hspawn Happly Heffect.
  destruct (tpr_actual_us_spawn_function_has_null_checkpoint
    before args spawn_trace spawned spawn_result Hspawn)
    as (e & le & allocated & body_last & body_after & body_out &
      Hentry & Hbody & Hresult & Hfree & Hcheckpoint).
  destruct Hcheckpoint as
    (clear_le & clear_m & done_le & cleared_m & pb & pre & clear_t & suf &
      Htrace & Hprefix & Hclear & Hsymbol & Hnull & Hsuffix).
  exists pb, cleared_m. split.
  - unfold TRSSpawnNullCheckpoint.
    exists e, le, allocated, body_last, body_after, body_out,
      clear_le, clear_m, done_le, pre, clear_t, suf.
    split; [exact Hentry|].
    split; [exact Hbody|].
    split; [exact Hresult|].
    split; [exact Hfree|].
    split; [exact Htrace|].
    split; [exact Hprefix|].
    split; [exact Hclear|].
    split; [exact Hsuffix|].
    split; [exact Hsymbol|exact Hnull].
  -
  intro Hsame. rewrite Hnull in Hsame.
  destruct (ipd_null_platform_call_cannot_depart VersionUS next pb
    apply_trace after result Hsymbol Hsame Happly) as [_ Hidentity].
  exact (Heffect Hidentity).
Qed.

Definition TeleporterResetSeparationBoundary : Prop :=
  TRSHeldResetPreservesSeparatePlatform /\
  TRSSpawnResetMakesReplacementNecessary.

Theorem teleporter_reset_separation_boundary_checked :
  TeleporterResetSeparationBoundary.
Proof.
  split; [exact trs_held_reset_preserves_separate_platform|].
  exact trs_spawn_reset_makes_effective_apply_require_replacement.
Qed.
