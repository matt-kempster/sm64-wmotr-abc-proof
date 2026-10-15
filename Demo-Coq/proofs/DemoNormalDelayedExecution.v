From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
 Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update us_ingame_menu.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary
 DemoNormalPostCameraExecution DemoDelayedWarpTerminalExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module DT := us_level_update.
Module DM := us_ingame_menu.

(** This selector starts at the actual delayed-warp call after painting. *)
Definition normal_afterpainting_suffix (body:statement) : statement :=
 match normal_postcamera_suffix body with Ssequence _ suffix => suffix | _ => Sskip end.

Lemma generated_normal_afterpainting_suffix_identical_us_jp :
 normal_afterpainting_suffix (fn_body DT.f_play_mode_normal) <>
   Sskip /\
 normal_afterpainting_suffix (fn_body DT.f_play_mode_normal) =
 normal_afterpainting_suffix (fn_body jp_level_update.f_play_mode_normal).
Proof. split; [discriminate|reflexivity]. Qed.
Definition demo_normal_terminal_suffix_execution_claim : Prop :=
 forall (ge:Clight.genv) (us:bool) le before (r:dialog_reset_resources ge before)
   operation delayed_timer debug current stream record mode counter special reset_function warp_function delayed_function,
 Genv.find_symbol ge DT._sDelayedWarpOp = Some operation ->
 Genv.find_symbol ge DT._sDelayedWarpTimer = Some delayed_timer ->
 Genv.find_symbol ge DT._gDebugLevelSelect = Some debug ->
 Genv.find_symbol ge DT._gCurrDemoInput = Some current ->
 Genv.find_symbol ge DT._sCurrPlayMode = Some mode ->
 Genv.find_symbol ge DT._D_80339ECA = Some counter ->
 Genv.find_symbol ge DT._D_80339EE0 = Some special ->
 Genv.find_symbol ge DT._reset_dialog_render_state = Some reset_function ->
 Genv.find_funct_ptr ge reset_function = Some (Internal DM.f_reset_dialog_render_state) ->
 Genv.find_symbol ge DT._warp_special = Some warp_function ->
 Genv.find_funct_ptr ge warp_function = Some (Internal DT.f_warp_special) ->
 Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
 Mem.load Mint16signed before delayed_timer 0 = Some (Vint Int.one) ->
 Mem.load Mint8signed before debug 0 = Some Vzero ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.weak_valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.valid_access before Mint16signed delayed_timer 0 Writable ->
 Mem.valid_access before Mint16signed mode 0 Writable ->
 Mem.valid_access before Mint16unsigned counter 0 Writable ->
 Mem.valid_access before Mint16signed special 0 Writable ->
 mode <> counter -> mode <> special -> counter <> special ->
 reset_type ge before r <> delayed_timer ->
 (forall b, In b [operation;debug;current] ->
   ~ In b (terminal_delayed_written ge before r delayed_timer mode counter special)) ->
 (forall b, In b [delayed_timer; reset_timer ge before r; reset_update ge before r] ->
   ~ In b [mode;counter;special]) ->
 ~ In delayed_timer (dialog_reset_written ge before r) ->
 Genv.find_symbol ge DT._initiate_delayed_warp = Some delayed_function ->
 Genv.find_funct_ptr ge delayed_function = Some (Internal DT.f_initiate_delayed_warp) ->
 exists after,
  exec_stmt function_entry2 ge empty_env le before
   (normal_afterpainting_suffix (fn_body
     (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
   E0 (PTree.set DT._t'6 (Vint (Int.repr 4)) le) after
   (Out_return (Some (Vzero,tint))) /\
  Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
  Mem.load Mint16signed after delayed_timer 0 = Some Vzero /\
  Mem.load Mint16signed after mode 0 = Some (Vint (Int.repr 4)) /\
  Mem.load Mint16signed after special 0 = Some (Vint (Int.repr (-2))) /\
  Mem.load Mint16signed after (reset_timer ge before r) 0 = Some Vzero /\
  Mem.load Mptr after (reset_update ge before r) 0 = Some Vzero /\
  (forall chunk b ofs,
   ~ In b (terminal_delayed_written ge before r delayed_timer mode counter special) ->
   Mem.load chunk after b ofs = Mem.load chunk before b ofs) /\
  (forall chunk b ofs permission, Mem.valid_access before chunk b ofs permission ->
    Mem.valid_access after chunk b ofs permission) /\
  (forall b, Mem.valid_block before b -> Mem.valid_block after b).


Theorem generated_normal_terminal_suffix_executes_us_jp :
 demo_normal_terminal_suffix_execution_claim.
Proof.
 intros ge us le before r operation delayed_timer debug current stream record mode counter special
   reset_function warp_function delayed_function Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol
   Hmode_symbol Hcounter_symbol Hspecial_symbol Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body
   Hop Htimer Hdebug Hcurrent Hstream Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs
   Htype_separate Hread_separate Hwarp_separate Htimer_reset_separate Hdelayed_symbol Hdelayed_body.
 destruct (generated_terminal_delayed_warp_executes_us_jp ge true before r
   operation delayed_timer debug current stream record mode counter special reset_function warp_function
   Hop_symbol Htimer_symbol Hdebug_symbol Hcurrent_symbol Hmode_symbol Hcounter_symbol Hspecial_symbol
   Hreset_symbol Hreset_body Hwarp_symbol Hwarp_body Hop Htimer Hdebug Hcurrent Hstream
   Hwtimer Hwmode Hwcounter Hwspecial Hmc Hms Hcs Htype_separate Hread_separate Hwarp_separate
   Htimer_reset_separate)
   as (after & Hcall & Hop_after & Htimer_after & Hmode_after & Hspecial_after &
     Htransition_after & Hupdate_after & Hframe & Haccess & Hvalid).
 exists after. split.
 - assert (Hselected : normal_afterpainting_suffix (fn_body
       (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)) =
       normal_afterpainting_suffix (fn_body DT.f_play_mode_normal)) by (destruct us; reflexivity).
   rewrite Hselected.
   change (exec_stmt function_entry2 ge empty_env le before
     (Ssequence
       (Scall None (Evar DT._initiate_delayed_warp (Tfunction [] tvoid cc_default)) [])
       (normal_decision_suffix (fn_body DT.f_play_mode_normal)))
     E0 (PTree.set DT._t'6 (Vint (Int.repr 4)) le) after
     (Out_return (Some (Vzero,tint)))).
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0) (le1:=le) (m1:=after).
   + eapply exec_Scall with (vargs:=[]) (vres:=Vundef);
       [reflexivity|demo_expr|constructor|cbn; exact Hdelayed_body|reflexivity|exact Hcall].
   + exact (generated_normal_exit_decision_executes_us_jp ge true le after mode Hmode_symbol Hmode_after).
 - repeat first [assumption | split].
Qed.

Definition demo_normal_postcamera_countdown_execution_claim : Prop :=
  forall (ge : Clight.genv) (us : bool) le before
    current area area_co painting_function delayed_function
    operation timer mode warp warp_co transition_timer pause_function ticks,
    forall resources : normal_pause_resources ge before,
    Genv.find_symbol ge DT._gCurrentArea = Some current ->
    Mem.load Mptr before current 0 = Some (Vptr area Ptrofs.zero) ->
    (genv_cenv ge) ! DT._Area = Some area_co ->
    field_offset (genv_cenv ge) DT._paintingWarpNodes (co_members area_co) = OK (24, Full) ->
    Mem.load Mptr before area 24 = Some Vzero ->
    Genv.find_symbol ge DT._initiate_painting_warp = Some painting_function ->
    Genv.find_funct_ptr ge painting_function = Some (Internal DT.f_initiate_painting_warp) ->
    Genv.find_symbol ge DT._initiate_delayed_warp = Some delayed_function ->
    Genv.find_funct_ptr ge delayed_function = Some (Internal DT.f_initiate_delayed_warp) ->
    Genv.find_symbol ge DT._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge DT._sDelayedWarpTimer = Some timer ->
    operation <> timer -> 2 <= ticks <= 20 ->
    Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
    Mem.load Mint16signed before timer 0 = Some (Vint (Int.repr ticks)) ->
    Mem.valid_access before Mint16signed timer 0 Writable ->
    Genv.find_symbol ge DT._sCurrPlayMode = Some mode ->
    Mem.load Mint16signed before mode 0 = Some Vzero ->
    Genv.find_symbol ge DT._sWarpDest = Some warp ->
    (genv_cenv ge) ! DT._WarpDest = Some warp_co ->
    field_offset (genv_cenv ge) DT._type (co_members warp_co) = OK (0, Full) ->
    Mem.load Mint8unsigned before warp 0 = Some Vzero ->
    Genv.find_symbol ge DT._sTransitionTimer = Some transition_timer ->
    Mem.load Mint16signed before transition_timer 0 = Some Vzero ->
    Genv.find_symbol ge DT._pressed_pause = Some pause_function ->
    Genv.find_funct_ptr ge pause_function = Some (Internal DT.f_pressed_pause) ->
    mode <> timer -> warp <> timer -> transition_timer <> timer ->
    ~ In timer [decision_dialog_global ge before resources;
      decision_mario_global ge before resources; decision_mario ge before resources;
      decision_transition ge before resources; decision_operation ge before resources] ->
    exists after,
      exec_stmt function_entry2 ge empty_env le before
        (normal_postcamera_suffix (fn_body
          (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
        E0 (normal_unpaused_decision_temps le) after (Out_return (Some (Vzero, tint))) /\
      Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed after timer 0 = Some (Vint (Int.repr (ticks-1))) /\
      (forall chunk b ofs, Mem.valid_block before b -> b <> timer ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_normal_postcamera_countdown_interval_executes_us_jp :
  demo_normal_postcamera_countdown_execution_claim.
Proof.
  intros ge us le before current area area_co painting_function delayed_function
    operation timer mode warp warp_co transition_timer pause_function ticks resources
    Hcurrent Harea Harea_co Hpainting_offset Hnull Hpainting_symbol Hpainting_body
    Hdelayed_symbol Hdelayed_body Hoperation Htimer Hseparate Hbounds Hop Htick Hwritable
    Hmode_symbol Hmode Hwarp_symbol Hwarp_co Htype Hwarp Htransition_symbol
    Htransition Hpause_symbol Hpause_body Hmode_sep Hwarp_sep Htransition_sep Hresource_sep.
  destruct (generated_painting_null_complete_call ge before current area area_co
    Hcurrent Harea Harea_co Hpainting_offset Hnull)
    as (painted & Hpainting & Hpainting_frame & Hpainting_access).
  assert (Hpainting_reads : forall chunk b ofs v, Mem.load chunk before b ofs = Some v ->
    Mem.load chunk painted b ofs = Some v).
  { intros chunk b ofs v Hread. rewrite Hpainting_frame.
    - exact Hread.
    - eapply decision_loaded_block_valid; exact Hread. }
  destruct (generated_bounded_demo_countdown_executes_us_jp ge true painted operation timer ticks
    Hoperation Htimer Hseparate Hbounds (Hpainting_reads _ _ _ _ Hop)
    (Hpainting_reads _ _ _ _ Htick) (Hpainting_access _ _ _ _ Hwritable))
    as (after & Hdelayed & Hop_after & Htick_after & Hframe & Hcount_access).
  pose (Hpainted_resources := normal_pause_resources_preserved_reads ge before painted resources
    Hpainting_reads).
  assert (Hpainted_sep : ~ In timer
    [decision_dialog_global ge painted Hpainted_resources;
      decision_mario_global ge painted Hpainted_resources; decision_mario ge painted Hpainted_resources;
      decision_transition ge painted Hpainted_resources; decision_operation ge painted Hpainted_resources]).
  { unfold Hpainted_resources, normal_pause_resources_preserved_reads.
    destruct resources; exact Hresource_sep. }
  pose proof (normal_pause_resources_load_frame ge painted after timer Hpainted_resources
    Hpainted_sep Hframe) as Hafter_resources.
  assert (Hdecision : exec_stmt function_entry2 ge empty_env le after
    (normal_decision_suffix (fn_body DT.f_play_mode_normal)) E0
    (normal_unpaused_decision_temps le) after (Out_return (Some (Vzero, tint)))).
  { apply (generated_normal_pending_decision_executes_us_jp ge true le after mode warp
      warp_co transition_timer pause_function); try assumption;
      rewrite Hframe by assumption; apply Hpainting_reads; assumption. }
  exists after; split.
  - assert (Hselected : normal_postcamera_suffix (fn_body
      (if us then DT.f_play_mode_normal else jp_level_update.f_play_mode_normal)) =
      normal_postcamera_suffix (fn_body DT.f_play_mode_normal)).
    { destruct us; reflexivity. }
    rewrite Hselected.
    change (exec_stmt function_entry2 ge empty_env le before
      (Ssequence
        (Scall None (Evar DT._initiate_painting_warp (Tfunction [] tvoid cc_default)) [])
        (Ssequence
          (Scall None (Evar DT._initiate_delayed_warp (Tfunction [] tvoid cc_default)) [])
          (normal_decision_suffix (fn_body DT.f_play_mode_normal))))
      E0 (normal_unpaused_decision_temps le) after (Out_return (Some (Vzero, tint)))).
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0) (le1 := le) (m1 := painted).
    + eapply exec_Scall with (vargs := []) (vres := Vundef);
        [reflexivity | demo_expr | constructor | cbn; exact Hpainting_body |
         reflexivity | exact Hpainting].
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0) (le1 := le) (m1 := after).
      * eapply exec_Scall with (vargs := []) (vres := Vundef);
          [reflexivity | demo_expr | constructor | cbn; exact Hdelayed_body |
           reflexivity | exact Hdelayed].
      * exact Hdecision.
  - split; [exact Hop_after | split; [exact Htick_after |]].
    intros chunk b ofs Hvalid Hother.
    rewrite Hframe by exact Hother; apply Hpainting_frame; exact Hvalid.
Qed.

Definition demo_normal_delayed_execution_claim : Prop :=
 demo_normal_terminal_suffix_execution_claim /\
 demo_normal_postcamera_countdown_execution_claim.

Theorem generated_normal_delayed_execution_us_jp : demo_normal_delayed_execution_claim.
Proof. split; [exact generated_normal_terminal_suffix_executes_us_jp |
 exact generated_normal_postcamera_countdown_interval_executes_us_jp]. Qed.
