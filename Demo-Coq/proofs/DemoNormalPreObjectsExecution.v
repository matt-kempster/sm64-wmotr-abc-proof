From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update.
From Demo.Proofs Require Import DemoStartExecution DemoStartWarpExecution
  DemoInstantWarpExecution DemoNormalTimerExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_level_update.

(** The contiguous caller interval immediately after the Start prefix and
    before area_update_objects. Each selected statement is from the real
    generated normal frame. *)
Definition normal_preobjects_prefix (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence warp (Ssequence instant (Ssequence timer _))) =>
      Ssequence warp (Ssequence instant timer)
  | _ => Sskip
  end.

Lemma generated_normal_preobjects_prefix_identical_us_jp :
  normal_preobjects_prefix (fn_body P.f_play_mode_normal) =
  normal_preobjects_prefix (fn_body jp_level_update.f_play_mode_normal).
Proof. reflexivity. Qed.

Lemma generated_normal_preobjects_prefix_is_nonempty :
  normal_preobjects_prefix (fn_body P.f_play_mode_normal) <> Sskip.
Proof. discriminate. Qed.

Definition normal_warp_area_callee (us : bool) : function :=
  if us then P.f_warp_area else jp_level_update.f_warp_area.

Ltac preobjects_call :=
  eapply exec_Scall with (vargs := []) (vres := Vundef);
    [reflexivity | demo_expr | constructor | cbn; eassumption |
     first [reflexivity | match goal with
       |- context [normal_warp_area_callee ?us] => destruct us; reflexivity
       | |- context [selected_instant_warp ?us] => destruct us; reflexivity
       end] | eassumption].

Definition demo_normal_preobjects_execution_claim : Prop :=
  forall (ge : Clight.genv) (us : bool) le m
      warp_function instant_function warp warp_co
      level_global level mario_global mario mario_co
      floor floor_co floor_type current area area_co
      running_global running hud hud_co tick operation pending_timer,
    Genv.find_symbol ge P._warp_area = Some warp_function ->
    Genv.find_funct_ptr ge warp_function = Some (Internal (normal_warp_area_callee us)) ->
    Genv.find_symbol ge P._check_instant_warp = Some instant_function ->
    Genv.find_funct_ptr ge instant_function = Some (Internal (selected_instant_warp us)) ->
    Genv.find_symbol ge P._sWarpDest = Some warp ->
    (genv_cenv ge) ! P._WarpDest = Some warp_co ->
    field_offset (genv_cenv ge) P._type (co_members warp_co) = OK (0, Full) ->
    Mem.load Mint8unsigned m warp 0 = Some Vzero ->
    Genv.find_symbol ge P._gCurrLevelNum = Some level_global ->
    Mem.load Mint16signed m level_global 0 = Some (Vint level) ->
    Int.eq level (Int.repr 6) = false ->
    Genv.find_symbol ge P._gMarioState = Some mario_global ->
    Mem.load Mptr m mario_global 0 = Some (Vptr mario Ptrofs.zero) ->
    (genv_cenv ge) ! P._MarioState = Some mario_co ->
    field_offset (genv_cenv ge) P._floor (co_members mario_co) = OK (104, Full) ->
    Mem.load Mptr m mario 104 = Some (Vptr floor Ptrofs.zero) ->
    Mem.weak_valid_pointer m floor (Ptrofs.unsigned Ptrofs.zero) = true ->
    (genv_cenv ge) ! P._Surface = Some floor_co ->
    field_offset (genv_cenv ge) P._type (co_members floor_co) = OK (0, Full) ->
    Mem.load Mint16signed m floor 0 = Some (Vint floor_type) ->
    Genv.find_symbol ge P._gCurrentArea = Some current ->
    Mem.load Mptr m current 0 = Some (Vptr area Ptrofs.zero) ->
    (genv_cenv ge) ! P._Area = Some area_co ->
    field_offset (genv_cenv ge) P._instantWarps (co_members area_co) = OK (28, Full) ->
    Mem.load Mptr m area 28 = Some Vzero ->
    Genv.find_symbol ge P._sTimerRunning = Some running_global ->
    Mem.load Mint8signed m running_global 0 = Some (Vint running) ->
    Genv.find_symbol ge P._gHudDisplay = Some hud ->
    (genv_cenv ge) ! P._HudDisplay = Some hud_co ->
    field_offset (genv_cenv ge) P._timer (co_members hud_co) = OK (12, Full) ->
    Mem.load Mint16unsigned m hud 12 = Some (Vint tick) ->
    Mem.valid_access m Mint16unsigned hud 12 Writable ->
    Genv.find_symbol ge P._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge P._sDelayedWarpTimer = Some pending_timer ->
    operation <> hud -> pending_timer <> hud ->
    Mem.load Mint16signed m operation 0 = Some (Vint (Int.repr 22)) ->
    Mem.load Mint16signed m pending_timer 0 = Some (Vint (Int.repr 20)) ->
    exists le' after,
      exec_stmt function_entry2 ge empty_env le m
        (normal_preobjects_prefix (fn_body
          (if us then P.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
        E0 le' after Out_normal /\
      Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed after pending_timer 0 = Some (Vint (Int.repr 20)) /\
      (forall chunk b ofs, b <> hud -> Mem.load chunk after b ofs = Mem.load chunk m b ofs) /\
      (forall chunk b ofs permission, Mem.valid_access m chunk b ofs permission ->
        Mem.valid_access after chunk b ofs permission).

Theorem generated_normal_preobjects_interval_executes :
  demo_normal_preobjects_execution_claim.
Proof.
  intros ge us le m warp_function instant_function warp warp_co
    level_global level mario_global mario mario_co floor floor_co floor_type
    current area area_co running_global running hud hud_co tick operation pending_timer
    Hwarp_symbol Hwarp_function Hinstant_symbol Hinstant_function
    Hdest_symbol Hdest_co Hdest_offset Hdest_zero Hlevel_symbol Hlevel Hnotcastle
    Hmario_symbol Hmario Hmario_co Hfloor_offset Hfloor Hfloor_valid
    Hfloor_co Htype_offset Hfloor_type Hcurrent Harea Harea_co Hinstant_offset Hnull
    Hrunning_symbol Hrunning Hhud_symbol Hhud_co Htimer_offset Htick Hwritable
    Hop_symbol Hpending_symbol Hop_separate Hpending_separate Hop Hpending.
  destruct (generated_zero_destination_warp_area_skips_us_jp ge m warp warp_co
    Hdest_symbol Hdest_co Hdest_offset Hdest_zero) as [Hwarp_us Hwarp_jp].
  assert (Hwarp : eval_funcall function_entry2 ge m
    (Internal (normal_warp_area_callee us)) [] E0 m Vundef).
  { destruct us; [exact Hwarp_us | exact Hwarp_jp]. }
  pose proof (generated_instant_warp_null_table_skips_us_jp ge m
    level_global level mario_global mario mario_co floor floor_co floor_type current
    area area_co Hlevel_symbol Hlevel Hnotcastle Hmario_symbol Hmario Hmario_co
    Hfloor_offset Hfloor Hfloor_valid Hfloor_co Htype_offset Hfloor_type Hcurrent
    Harea Harea_co Hinstant_offset Hnull us) as Hinstant.
  destruct (generated_normal_timer_executes_us_jp ge le m running_global running
    hud hud_co tick Hrunning_symbol Hrunning Hhud_symbol Hhud_co Htimer_offset
    Htick Hwritable) as (le' & after & Htimer & Heffect & Hframe & Haccess).
  exists le', after; split.
  - assert (Hselected : normal_preobjects_prefix (fn_body
       (if us then P.f_play_mode_normal else jp_level_update.f_play_mode_normal)) =
       normal_preobjects_prefix (fn_body P.f_play_mode_normal)).
    { destruct us; reflexivity. }
    rewrite Hselected.
    change (exec_stmt function_entry2 ge empty_env le m
      (Ssequence
        (Scall None (Evar P._warp_area (Tfunction [] tvoid cc_default)) [])
        (Ssequence
          (Scall None (Evar P._check_instant_warp (Tfunction [] tvoid cc_default)) [])
          (normal_timer_statement (fn_body P.f_play_mode_normal))))
      E0 le' after Out_normal).
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0) (m1 := m) (le1 := le).
    + preobjects_call.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0) (m1 := m) (le1 := le).
      * preobjects_call.
      * exact (Htimer true).
  - split.
    + rewrite Hframe by exact Hop_separate; exact Hop.
    + split.
      * rewrite Hframe by exact Hpending_separate; exact Hpending.
      * split; assumption.
Qed.
